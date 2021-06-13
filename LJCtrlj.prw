#include "Protheus.ch"
#include "Rwmake.ch"

/*
   Objetivo.....: 
   Ponto de Entrada para Consulta Customizada de Produtos na Tela de Venda Assistida.
*/

User Function LJCtrlj
  Local cAlias := Alias()
  Local nOrd   := dbSetOrder()
  Local nReg   := Recno()
  Local lRet   := .F.
	
  Local oDlgMain,bOk,bCancel,cFile
	
  Local c_Pesq    := Space(60)
  	
  Local cFiltro,cChave,cIndSA21,aStru
	
  DEFINE Font oFnt3 Name "Ms Sans Serif" Bold
  DEFINE Font oFnt4 Name "Tahoma" BOLD Size 013,030
	
  DEFINE MSDIALOG oDlgMain Title "Consulta de Produtos" From 96,5 to 480-200,550 Pixel
	
     @040, 15 Say " Pesquisa:"  Size 35,8 Of oDlgMain Pixel Font oFnt3
     @040, 50 Get c_Pesq Picture "@!" Size 129,8 Pixel of oDlgMain

     bOk := {|| GravaItem(c_Pesq),lRet:= .t.,oDlgMain:End()}
     bCancel := {||oDlgMain:End()}
	
  ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,bOk,bCancel) CENTERED
	
  dbSelectArea(cAlias)
  dbSetOrder(nOrd)
  dbGoTo(nReg)
Return lRet

///////////////////////////////////
Static Function GravaItem(c_Pesq)
  Local cAlias := Alias()
  Local nOrd   := dbSetOrder()
  
  //- Pesquisa por descrição
  Local aDescr := {}
  Local bOk,bCancel,oDlgDescr,c_Cond:=""
  Local aStru,aCampos,cFile,lRet:= .t.,lPesquisa:= .f.,lCond:= .t.
  Local cAlmox := GetMv("MV_LOCPAD")
	
  aStru:= { { "WK_COD"    , "C", 15, 0 },; 
            { "WK_DESCR"  , "C", 60, 0 },;
            { "WK_PRECO1" , "C", 10, 2 },;
            { "WK_PRECO2" , "C", 10, 2 },;
            { "WK_PRECO3" , "C", 10, 2 },;
            { "WK_PRECO4" , "C", 10, 2 },;
            { "WK_SALDO"  , "N", 12, 2 }}
              
  aCampos:= { { "WK_COD"    ,,"Codigo"},;
              { "WK_DESCR"  ,,"Descrição"},;
              { "WK_SALDO"  ,,"Saldo"},;
              { "WK_PRECO1" ,,"Preco1"},;
              { "WK_PRECO2" ,,"Preco2"},;
              { "WK_PRECO3" ,,"Preco3"},;
              { "WK_PRECO4" ,,"Preco4"}}

  cFile:= CriaTrab(aStru,.T.)
  dbUseArea(.t.,,cFile,"wDesc",.F.,.F.)
  Index on WK_DESCR to &cFile
	
  //dbSelectArea("SB1")

  cFiltro := Alltrim(c_Pesq)
	
  lCond := .t.
  
  Do While lCond
     nPosAt:= At("%", cFiltro) 
     If nPosAt > 1 
   	    cPesq:= '%'+Substring(cFiltro, 1, nPosAt)
   	    cFiltro := StrTran(cFiltro,Substring(cFiltro, 1, nPosAt), "")
	  Else
	     cPesq:= "%"+Alltrim(cFiltro)+"%" 
	     lCond:= .f. 
	  Endif
     c_Cond+= " B1_DESC LIKE '" + ALLTRIM(cPesq) + Iif(lCond,"' AND","'") 
  Enddo
  cQry := "SELECT B1_COD,B1_DESC "
  cQry += "FROM "+RetSqlName("SB1")+" SB1 "
  cQry += "WHERE SB1.D_E_L_E_T_ <> '*' "
  cQry += "  AND B1_FILIAL = '"+xFilial("SB1")+"' "
  cQry += "  AND "+ ALLTRIM(c_Cond)+ " "  
  cQry += "ORDER BY B1_DESC "
		
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQry)),"SB1T",.T.,.T.)
  dbSelectArea("SB1T")		
  
  Do While !SB1T->(EOF())
			
     //- Saldo fisico e financeiro
	  SB2->(Dbseek(xFilial("SB2") + SB1T->B1_COD + cAlmox)) //ALLTRIM(GETMV("MV_LOCPAD"))))
			
	  //- Preço de venda
	  SB0->(Dbseek(xFilial("SB0") + SB1T->B1_COD))

     wDesc->(Dbappend())                                
     wDesc->WK_COD    := SB1T->B1_COD
     wDesc->WK_DESCR  := SB1T->B1_DESC
     wDesc->WK_SALDO  := SB2->B2_QATU - SB2->B2_RESERVA
     wDesc->WK_PRECO1 := Transform(SB0->B0_PRV1,"@E 999,999.99")
     wDesc->WK_PRECO2 := Transform(SB0->B0_PRV2,"@E 999,999.99")
     wDesc->WK_PRECO3 := Transform(SB0->B0_PRV3,"@E 999,999.99")
     wDesc->WK_PRECO4 := Transform(SB0->B0_PRV4,"@E 999,999.99")
     SB1T->(DbSkip())
  Enddo
  SB1T->(dbCloseArea())
	
  wDesc->(DbGotop())
  DEFINE MSDIALOG oDlgDescr Title "Consulta por descricao" From 96,5 to 410,920 Pixel
     oMark:= MsSelect():New("wDesc",,,aCampos,.F.,"",{35,1,(oDlgDescr:nHeight-30)/2,(oDlgDescr:nClientWidth-4)/2})
	  bOk := {||GravaAcols(),oDlgDescr:End()}
	  bCancel := {||oDlgDescr:End()}
  ACTIVATE MSDIALOG oDlgDescr On Init EnchoiceBar(oDlgDescr,bOk,bCancel) Centered
	
  dbSelectArea("wDesc")
  dbCloseArea()
	
  FERASE(cFile+GetDbExtension())
  FERASE(cFile+OrdBagExt())
	
  dbSelectArea(cAlias)
  dbSetOrder(nOrd)
Return

//////////////////////////
Static Function GravaAcols
  Local nUsado
  Local n_ColItem    := GdFieldPos("LR_ITEM", aHeader)
  Local n_ColProduto := GdFieldPos("LR_PRODUTO", aHeader)
  Local n_ColVend    := GdFieldPos("LR_VEND", aHeader)
  Local n_ColEntrega := GdFieldPos("LR_ENTREGA", aHeader)
    
  Local lMaisDeUm := !Empty(aCols[1,2]) //- Verifica se tem mais de um item no acols
  
  nUsado:= Len(aCols[1])-1                           
  
  If lMaisDeUm
     Aadd(aCols, Array(nUsado+1) )
  Endif
			
  nTam := Len(aCols)
  
  For c := 1 To nUsado
     If aHeader[c,8] == "C"
	     aCols[nTam,c]:= Space(aHeader[c,4])
	  Elseif aHeader[c,8] == "N"
	     aCols[nTam,c]:= 0
	  Elseif aHeader[c,8] == "D"
	     aCols[nTam,c]:= Ctod("  /  /  ")
	  Elseif aHeader[c,8] == "M"
	     aCols[nTam,c]:= ""
	  Else
	     aCols[nTam,c]:= .F.
	  Endif
  Next
  aCols[nTam,nUsado+1] := .F.
  aCols[nTam,n_ColItem]    := strzero(nTam,2)
  aCols[nTam,n_ColProduto] := wDesc->WK_COD
  aCols[nTam,n_ColVend]    := M->LQ_VEND
  //aCols[nTam,n_ColEntrega] := "1"
  n := nTam   

  oGetVA:oBrowse:lDisablePaint := .F.
  oGetVA:oBrowse:Refresh(.T.)

Return
