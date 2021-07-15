#INCLUDE "TOTVS.ch"
#INCLUDE "TOPCONN.CH"
//#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} WSLX01
Função WSLX01, cria um markbrowse editavel.
@param aCols, aHeader
@return Não retorna nada
@author Luiz Paulo Rodrigues
@version Protheus 12
@since Março | 2020
/*/

/* Detalhamento dos preços
Preço atual = Preços do produto na SB0

Preço sugerido = Custo do fechamento (B9_CM1) + % no cadastro de margem (WSL010)
*/
 
User Function WSLX01(aCols,aHeader)
  Private lMarker     := .T.
  Private aDespes     := {}
  Private aMarcados   := {}
  Private aTipo       := {}

  Private lPrcCusto := .F. //- Custo médio (default)
  Private lPrcRepos := .F. //- Custo reposição

  If MsgYesNo("Utilizar o Custo Médio","Custo","YESNO")
     lPrcCusto := .T.
  Else
     lPrcRepos := .T.
  EndIf

  DEFINE Font oFnt3 Name "Ms Sans Serif" Bold

  aadd(aTipo,{"VAREJAO"})
  aadd(aTipo,{"VAREJO" })
  aadd(aTipo,{"ATACADO"})
  aadd(aTipo,{"ESPECIAL"})
 
  //Alimenta o array
  BUSDATA(aCols,aHeader)
 
  DEFINE MSDIALOG o3Dlg TITLE 'Notas Fiscais [*Itens*]' From 0, 4 To 500, 1200 Pixel
     
     oPnMaster := tPanel():New(0,0,,o3Dlg,,,,,,0,0)
     
     @ 235, 000 MSPANEL oPnl SIZE 250, 025 OF o3Dlg //
     oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT
     oPnl:Align   := CONTROL_ALIGN_BOTTOM     //
 
     oDespesBrw := fwBrowse():New()
     oDespesBrw:setOwner( oPnMaster )
 
     oDespesBrw:setDataArray()
     oDespesBrw:setArray( aDespes )
     oDespesBrw:disableConfig()
     oDespesBrw:disableReport()
 
     oDespesBrw:SetLocate() // Habilita a Localização de registros
 
     //Create Mark Column
     oDespesBrw:AddMarkColumns({|| IIf(aDespes[oDespesBrw:nAt,01], "LBOK", "LBNO")},; //Code-Block image
        {|| SelectOne(oDespesBrw, aDespes)},; //Code-Block Double Click
        {|| SelectAll(oDespesBrw, 01, aDespes) }) //Code-Block Header Click
 
     oDespesBrw:addColumn({"Data"              , {||aDespes[oDespesBrw:nAt,02]}, "C", "@!",1, 10, , .F. , , .F.,, "aDespes[oDespesBrw:nAt,02]",, .F., .T.,                                    , "ETDESPES1"    })
     oDespesBrw:addColumn({"Fornecedor"        , {||aDespes[oDespesBrw:nAt,03]}, "C", "@!",1, 6 , , .F. , , .F.,, "aDespes[oDespesBrw:nAt,03]",, .F., .T.,                                    , "ETDESPES2"    })
     oDespesBrw:addColumn({"Nome"              , {||aDespes[oDespesBrw:nAt,04]}, "C", "@!",1, 25, , .F. , , .F.,, "aDespes[oDespesBrw:nAt,04]",, .F., .T.,                                    , "ETDESPES3"    })
     oDespesBrw:addColumn({"Serie"             , {||aDespes[oDespesBrw:nAt,05]}, "C", "@!",1, 3 , , .F. , , .F.,, "aDespes[oDespesBrw:nAt,05]",, .F., .T.,                                    , "ETDESPES4"    })
     oDespesBrw:addColumn({"Nota"              , {||aDespes[oDespesBrw:nAt,06]}, "C", "@!",1, 9 , , .F. , , .F.,, "aDespes[oDespesBrw:nAt,06]",, .F., .T.,                                    , "ETDESPES5"    })
     oDespesBrw:addColumn({"Item"              , {||aDespes[oDespesBrw:nAt,07]}, "C", "@!",1, 4 , , .F. , , .F.,, "aDespes[oDespesBrw:nAt,07]",, .F., .T.,                                    , "ETDESPES6"    })
     oDespesBrw:addColumn({"Produto"           , {||aDespes[oDespesBrw:nAt,08]}, "C", "@!",1, 15, , .F. , , .F.,, "aDespes[oDespesBrw:nAt,08]",, .F., .T.,                                    , "ETDESPES7"    })
     oDespesBrw:addColumn({"Descricao"         , {||aDespes[oDespesBrw:nAt,09]}, "C", "@!",1, 20, , .F. , , .F.,, "aDespes[oDespesBrw:nAt,09]",, .F., .T.,                                    , "ETDESPES8"    })
     oDespesBrw:addColumn({"Tipo"              , {||aDespes[oDespesBrw:nAt,10]}, "C", "@!",1, 1 , , .F. , , .F.,, "aDespes[oDespesBrw:nAt,10]",, .F., .T.,                                    , "ETDESPES9"    })
     oDespesBrw:addColumn({"Descricao"         , {||aDespes[oDespesBrw:nAt,11]}, "C", "@!",1, 8 , , .F. , , .F.,, "aDespes[oDespesBrw:nAt,11]",, .F., .T.,                                    , "ETDESPES10"    })
     oDespesBrw:addColumn({"Preco Base"        , {||aDespes[oDespesBrw:nAt,12]}, "N", "@E 99,999,999,999.99",1, 14 ,2 , .F. , , .F.,, "aDespes[oDespesBrw:nAt,12]",, .F., .T.,                , "ETDESPES11"    })
     oDespesBrw:addColumn({"Preco Atual"       , {||aDespes[oDespesBrw:nAt,13]}, "N", "@E 99,999,999,999.99",1, 14 ,2 , .F. , , .F.,, "aDespes[oDespesBrw:nAt,13]",, .F., .T.,                , "ETDESPES12"    })
     oDespesBrw:addColumn({"Preco Sugerido"    , {||aDespes[oDespesBrw:nAt,14]}, "N", "@E 99,999,999,999.99",1, 14 ,2 , .T. , , .F.,, "aDespes[oDespesBrw:nAt,14]",, .F., .T.,                , "ETDESPES13"    })
    
     oDespesBrw:setEditCell( .T. , { || .T. } ) //activa edit and code block for validation

     //oTButton1 := TButton():New( 265 , 15, "Confirmar",o3Dlg,{||(fConfirma(aDespes,oDespesBrw),o3Dlg:End())}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
     //oTButton2 := TButton():New( 265, 80,"Cancelar",o3Dlg,{||(o3Dlg:End())}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )

     oTButton1 := TButton():New( 2, 15, "Confirmar", oPnl,{||(fConfirma(aDespes,oDespesBrw),o3Dlg:End()),(oPnl:End())}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
     oTButton2 := TButton():New( 2, 80, "Cancelar" , oPnl,{||(o3Dlg:End()),(oPnl:End())}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
 
     /*
     oDespesBrw:acolumns[2]:ledit     := .T.
     oDespesBrw:acolumns[2]:cReadVar:= 'aDespes[oBrowse:nAt,2]'
     */
 
     oDespesBrw:Activate(.T.)
 
  ACTIVATE MsDialog o3Dlg
 
Return .t.
 
///////////////////////////////////////////// 
Static Function SelectOne(oBrowse, aArquivo)
  aArquivo[oDespesBrw:nAt,1] := !aArquivo[oDespesBrw:nAt,1]
  oBrowse:Refresh()
Return .T.
 
///////////////////////////////////////////////////
Static Function SelectAll(oBrowse, nCol, aArquivo)
  Local _ni := 1
  For _ni := 1 to len(aArquivo)
     aArquivo[_ni,1] := lMarker
  Next
  oBrowse:Refresh()
  lMarker:=!lMarker
Return .T.
 
///////////////////////////////////////
Static Function BUSDATA(aCols,aHeader)
  Local cQuery    as Character
  Local cQryT3    as Character
  Local nPosDoc   := aScan(aHeader, {|x| Alltrim(x[2]) = 'D1_DOC'} )
  Local nPosSerie := aScan(aHeader, {|x| Alltrim(x[2]) = 'D1_SERIE'} )
  Local nPosItem  := aScan(aHeader, {|x| Alltrim(x[2]) = 'D1_ITEM'} )
  Local nPosForn  := aScan(aHeader, {|x| Alltrim(x[2]) = 'D1_FORNECE'} )
  Local nPosCod   := aScan(aHeader, {|x| Alltrim(x[2]) = 'D1_COD'} )
  Local nPosQtd   := aScan(aHeader, {|x| Alltrim(x[2]) = 'D1_QUANT'} )
  
  Local nCusAtu   := 0
  Local nCusBase  := 0

  cDataEmis := dtos(DDEMISSAO)
  cDataEmis := SubStr(cDataEmis,7,2)+"/"+SubStr(cDataEmis,5,2)+"/"+SubStr(cDataEmis,1,4)
 
  cQuery      := ""
  cQryT3      := GetNextAlias()
  aDespes := {}
  
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Ler acol dos iten documento de entrada ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  For nX := 1 to len(aCols)	
     cDataEmis := dtos(DDEMISSAO)
	  cDataEmis := SubStr(cDataEmis,7,2)+"/"+SubStr(cDataEmis,5,2)+"/"+SubStr(cDataEmis,1,4)
     cNomeFor  := Alltrim(Posicione("SA2",1,xFilial("SA2")+CA100FOR,"A2_NOME"))
     cDescProd := Alltrim(Posicione("SB1",1,xFilial("SB1")+aCols[nX,nPosCod],"B1_DESC"))

	  For nZ := 1 to len(aTipo)
        cTipo := Str(nZ)
        cTipo := Alltrim(cTipo)
        
        //- Retorna o custo medio entre as lojas
        If lPrcCusto
           nCusBase := CustoMedio(aCols[nX,nPosCod]) //- Considera custo médio
        Endif
  
        If lPrcRepos
           nCusBase := Posicione("SB1",1,xFilial("SB1")+aCols[nX,nPosCod],"B1_UPRC") //- Considera o custo de reposição
        Endif
        
        nCustNovo := fCustoNovo(aCols[nX,nPosCod],aCols[nX,nPosQtd],cTipo) //- Preço calculado
        nCusAtu   := fCustoAtu(aCols[nX,nPosCod],cTipo)  //- Preço atual na SB0
        
        Aadd(aDespes,{.f.,cDataEmis,CA100FOR,cNomeFor,CSERIE,CNFISCAL,aCols[nX,nPosItem],aCols[nX,nPosCod],cDescProd,Alltrim(cTipo),aTipo[nZ,1],nCusBase,nCusAtu,nCustNovo })

	  Next nZ
  Next nX
Return .t.

/*/{Protheus.doc} fCustoNovo
Função para retornar o novo custo do produto
Baseado no B9_CM1 x margem cadastrada na tabela ZA1
@param 
@return nCusto
@author Luiz Paulo Rodrigues
@version Protheus 12
@since Março | 2020
/*/
Static Function fCustoNovo(cProd,nQtde,cOrdem)
  Local nIcms := (100 - GetMV("MV_ICMPAD")) / 100 // Calculo do ICMS
  Local cGrTrib := ""
  Local nCusto := 0
  Local cSql := ""
  Local aMargem:= {}
  Local cUM := ""
  Local nPosUM:= 0
  Local nMg1 := 0
  Local nMg2 := 0
  Local nMg3 := 0
  Local nMg4 := 0

  //If (Select("RET"))
  //   dbSelectArea("RET")
  //   RET->(dbCloseArea ())
  //Endif
  //cSql := " SELECT MAX(R_E_C_N_O_) RECNO "
  //cSql += " FROM " +RetSqlName("SB9")+ " SB9 "
  //cSql += " WHERE D_E_L_E_T_ =' ' AND B9_COD='"+cProd+"' "
  //TCQUERY cSql NEW ALIAS "RET"
  //dbSelectArea("RET")
  //dbGoTop()
  //Do While !RET->(EOF())
  //   dbSelectArea("SB9")
  //   dbGoTo(RET->RECNO)
  //   nCusto := SB9->B9_CM1
  //   RET->(dbSkip())
  //Enddo
    
  dbSelectArea("SB1")
  dbSetOrder(1)

  If SB1->(dbSeek(xFilial("SB1")+cProd))
     cMarca  := SB1->B1_GRUPO
     cGrTrib := Alltrim(SB1->B1_GRTRIB) //- Grupo de tributação
     cUM     := SB1->B1_UM
  Endif

  If lPrcCusto
     nCusto := CustoMedio(cProd) //- Considera custo médio
  Endif
  
  If lPrcRepos
     nCusto := SB1->B1_UPRC //- Considera o custo de reposição
  Endif
  
  dbSelectArea("ZA1")
  
  If ZA1->(dbSetOrder(1),dbSeek(xFilial("ZA1")+cMarca))

     Do While !ZA1->(Eof()) .And. ZA1->(ZA1_FILIAL+ZA1_MARCA) == xFilial("ZA1")+cMarca
        Aadd(aMargem, {ZA1->ZA1_UM, ZA1->ZA1_MARG1, ZA1->ZA1_MARG2, ZA1->ZA1_MARG3, ZA1->ZA1_MARG4})
        ZA1->(DbSkip())   
     Enddo      
     ASORT(aMargem,,, { |x, y| x < y } ) //- Ordena para garantir que caso exista UM em branco ela será a primeira 

     nPosUM := aScan(aMargem, {|x| x[1] == cUM } )
     
     //alert(str(nPosUM))

     If nPosUM > 0
        nMg1 := aMargem[nPosUM][2]
        nMg2 := aMargem[nPosUM][3]
        nMg3 := aMargem[nPosUM][4]
        nMg4 := aMargem[nPosUM][5]
     Else
        nMg1 := aMargem[1][2]
        nMg2 := aMargem[1][3]
        nMg3 := aMargem[1][4]
        nMg4 := aMargem[1][5]
     Endif 
      
     If cOrdem == "1" //- Preço 1
        nCusto := nCusto + (nCusto * nMg1)/100
     Endif
     If cOrdem == "2" //- Preço 2
        nCusto := nCusto + (nCusto * nMg2)/100
     Endif
     If cOrdem == "3" //- Preço 3
        nCusto := nCusto + (nCusto * nMg3)/100
     Endif
     If cOrdem == "4" //- Preço 4
        nCusto := nCusto + (nCusto * nMg4)/100
     Endif
     
     //- Tratar ICMS caso o produto seja tributado
     If cGrTrib == "001"
        nCusto := nCusto / nIcms   
     Endif

  Endif
Return(nCusto)

/*/{Protheus.doc} fCustoAtu
Função para retornar o custo atual do produto B9_CM1
@param 
@return nCusto
@author Luiz Paulo Rodrigues
@version Protheus 12
@since Março | 2020
/*/
Static function fCustoAtu(cProd,cOrdem)
  Local nCusto := 0
  Local cSql := ""

  If (Select("RET"))
     dbSelectArea("RET")
     RET->(dbCloseArea ())
  Endif
  cSql := " SELECT B0_PRV1,B0_PRV2,B0_PRV3,B0_PRV4 "
  cSql += " FROM " +RetSqlName("SB0")+ " SB0 "
  cSql += " WHERE D_E_L_E_T_ =' ' "
  cSql += " AND B0_FILIAL='"+xFilial("SB0")+"' "
  cSql += " AND B0_COD='"+cProd+"' "
  TCQUERY cSql NEW ALIAS "RET"
  
  dbSelectArea("RET")
  dbGoTop()

  Do While !RET->(EOF())
     
     If cOrdem == "1" //- Preço 1
        nCusto := RET->B0_PRV1
     Endif
     If cOrdem == "2" //- Preço 2
        nCusto := RET->B0_PRV2
     Endif
     If cOrdem == "3" //- Preço 3
        nCusto := RET->B0_PRV3
     Endif
     If cOrdem == "4" //- Preço 4
        nCusto := RET->B0_PRV4
     Endif
     RET->(dbSkip())
  Enddo
Return(nCusto)

////////////////////////////////////
Static Function CustoMedio(cProduto)
  Local cQry := ""
  Local cFil := Substr(xFilial("SB2"),1,2)
  Local nCM1 := 0

  cQry += "SELECT SUM(B2_QATU)B2_QATU,SUM(B2_VATU1)B2_VATU1 "
  cQry += "FROM "+RetSQLName("SB2")+" SB2 "
  cQry += "WHERE D_E_L_E_T_ <> '*' "
  cQry += "AND SUBSTRING(B2_FILIAL,1,2) = '"+cFil+"' " 
  cQry += "AND B2_COD = '"+cProduto+"' " 

  dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry)), "XXX", .T., .F. )    

  If !XXX->(Eof())
     nCM1 := XXX->B2_VATU1 / XXX->B2_QATU
  Endif

  XXX->(dbCloseArea())
Return nCM1

//////////////////////////////////////////////
Static function fConfirma(aDespes,oDespesBrw)
  Local lRet := .T.

  For nX := 1 to len(aDespes)
     //- Só entra se for marcado no markbrow
     If aDespes[nX,1] == .T.
        
        If SB0->(dbSetOrder(1),dbSeek(xFilial("SB0")+aDespes[nX,8]))
           RecLock("SB0",.F.)
        Else
           RecLock("SB0",.T.)
           SB0->B0_FILIAL := xFilial("SB0") 
           SB0->B0_COD    := aDespes[nX,8]
        Endif   
        If aDespes[nX,10] == "1" //- Preço 1
           SB0->B0_PRV1 := Round(aDespes[nX,14],0)
        EndIf
        If aDespes[nX,10] == "2" //- Preço 2
           SB0->B0_PRV2 := Round(aDespes[nX,14],0)
        EndIf
        If aDespes[nX,10] == "3" //- Preço 3
           SB0->B0_PRV3 := Round(aDespes[nX,14],0)
        EndIf
        If aDespes[nX,10] == "4" //- Preço 4
           SB0->B0_PRV4 := aDespes[nX,14] //Round(aDespes[nX,14],0)
        Endif
        SB0->(MsUnLock())
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Atualiza custo médio das lojas caso tenha sido escolhido custo de reposição ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lPrcCusto
           dbSelectArea("SB1")
           dbSetOrder(1)
           If SB1->(dbSeek(xFilial("SB1")+aDespes[nX,8]))
              RecLock("SB1",.F.)
              SB1->B1_XCUSFIL := aDespes[nX,12]    
              SB1->(MsUnLock())
           Endif
        Endif      
     Endif
  Next nX
Return
