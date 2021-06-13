/*
	Objetivo: Gatilho para informar o valor unitario na Venda Assistida
	          Campo disparador: LR_QUANT
	Data....: 23/11/2015
	LR_QUANT : IIF(IsInCallStack("FATA701"),FTVDVlItem( 1 ),Lj7VlItem( 1 ))    
	LR_VRUNIT : IIF(IsInCallStack("FATA701"),FTVDVlItem( 2 ),Lj7VlItem( 2 ))                                                                    
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"

User Function BLBLOJE01()

Local oDlg701,oGrp701,oPLst,oBold,oFnt,oFnt2,oFnt3,oFnt4,oFnt5
Local nX
Local aArea701	 := GetArea()
Local nAuxTotal := 0
Local nOpcB     := 0
Local cPictPrc  := PesqPict("SC7","C7_PRECO",14)
Local nDecPrc   := TamSX3("LR_VRUNIT")[2]             ///Nro de casas decimais do campo
Local	nPosPrd   := GdFieldPos("LR_PRODUTO", aHeader)
Local	nPosQtd   := GdFieldPos("LR_QUANT", aHeader)
Local	nPosVUn   := GdFieldPos("LR_VRUNIT", aHeader)
Local	nPosVItm  := GdFieldPos("LR_VLRITEM", aHeader)
Local	nPosDsc   := GdFieldPos("LR_DESC", aHeader)
Local	nPosVDsc  := GdFieldPos("LR_VALDESC", aHeader)
Local	nPosPTab  := GdFieldPos("LR_PRCTAB", aHeaderDet)
Local	nPosBIcm  := GdFieldPos("LR_BASEICM", aHeaderDet)
Local	nPosVIcm  := GdFieldPos("LR_VALICM", aHeaderDet)
Local	nPosTab   := GdFieldPos("LR_TABELA", aHeaderDet)

IF ( M->LR_QUANT < 0 )
	Return(.F.)
ENDIF

Private nPreco  := SB0->B0_PRV1

Private nPreco1 := SB0->B0_PRV1
Private nPreco2 := SB0->B0_PRV2
Private nPreco3 := SB0->B0_PRV3
Private nPreco4 := SB0->B0_PRV4

Private aPreco := {}

DEFINE FONT 	oBold NAME "Times New Roman"	SIZE 0,  18 BOLD  
DEFINE FONT 	oFnt  NAME "Arial"				SIZE 0, -16 BOLD	// "Times New Roman" Maior
DEFINE FONT 	oFnt4 NAME "Arial"				SIZE 0, -20 BOLD	// "Times New Roman" Maior
DEFINE FONT 	oFnt3 NAME "Arial"				SIZE 0, -18 BOLD	// "Times New Roman" Maior
DEFINE FONT 	oFnt2 NAME "Arial"				SIZE 0, -14 BOLD	// "Times New Roman" Menor
DEFINE FONT 	oFnt5 NAME "Arial"				SIZE 0, -26 BOLD	// "Times New Roman" Maior

//IF ( FUNNAME()=="LOJA701" )
//  	Return(nPreco)
//ENDIF

////
////Carrega preço
////
FOR nX:=1 TO 9
	 cPrv := "SB0->B0_PRV" + STR(nX,1)
	 AADD(aPreco , { STRZERO(nX,2) , &cPrv } )
NEXT

DEFINE MSDIALOG oDlg701 TITLE ":::... TABELA DE PREÇO ...:::" FROM 280, 590  TO 560, 900 PIXEL 

@ 005,010 Say   oPrcUnit           PROMPT OEMTOANSI("Preço Unitário")             Size 145,8  OF oDlg701 PIXEL COLOR CLR_HBLUE FONT oFnt2
@ 014,010 MsGet oPreco             VAR    nPreco    Picture cPictPrc              Size 80,12  OF oDlg701 PIXEL                 FONT oFnt5

oPLst := TCBrowse():New( 035 , 010, 90,100,,{"TABELA","PREÇO"},{30,40},oDlg701,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

oPLst:SetArray(aPreco)
oPLst:bldblclick := { || ( nOpcB := 1 , oDlg701:End() ) }  	
oPLst:bChange := { || f_chgpreco(oPLst:nAt) }  
oPLst:bLine   := { || { aPreco[oPLst:nAt,1] , ;
								aPreco[oPLst:nAt,2] } }
							
oPLst:lAdjustColsize := .F.

DEFINE SBUTTON FROM 005,124 TYPE 1 ACTION ( nOpcB := 1 , oDlg701:End() ) ENABLE OF oDlg701

oPLst:SetFocus()

ACTIVATE MSDIALOG oDlg701 VALID nOpcB <> 0

If nPreco < nPreco4
   MSGINFO( 'Preço abaixo da tabela 4', 'Preço' )
   nPreco := nPreco1 
Endif

M->LR_VRUNIT      := nPreco
M->LR_VLRITEM     := a410Arred( M->LR_QUANT * nPreco, "D2_TOTAL")
aCols[n,nPosVUn]  := nPreco
aCols[n,nPosVItm] := M->LR_VLRITEM
aCols[n,nPosDsc]  := 0
aCols[n,nPosVDsc] := 0

//IF ( SM0->M0_CODIGO <> '85' )
	nPercIcms := ROUND(aColsDet[n,nPosVIcm] / aColsDet[n,nPosBIcm] , 2 )
	aColsDet[n,nPosPTab] := nPreco
	aColsDet[n,nPosBIcm] := aCols[n,nPosVItm]
	aColsDet[n,nPosVIcm] := ROUND(aCols[n,nPosVItm] * nPercIcms , 2 )
//ENDIF
nAuxTotal := LJ7T_Subtotal(2) - If( MaFisFound("IT",n),MaFisRet( n, "IT_TOTAL" ),aCols[n][nPosVUn] )

LJ7Detalhe()    ///Atualiza browse

///
///Atualiza rodapé da tela
///
If !aCols[n][Len(aHeader) + 1]
	nAuxTotal := nAuxTotal + If( MaFisFound("IT",n),MaFisRet( n, "IT_TOTAL" ),aCols[n][nPosVlItem] )
EndIf

If !aCols[n][Len(aCols[n])]
	Lj7T_Subtotal	( 2, nAuxTotal )

	If Lj7T_DescV(2) > 0 .AND. nVlrDesc > 0
		Lj7T_DescV(2, 0)
		Lj7T_DescP(2, 0)
	EndIf
	Lj7T_Total( 2, Lj7T_Subtotal(2) - Lj7T_DescV(2) )

	If aTotais[4][2] <= 0
		Lj7T_DescV(2, 0)
		Lj7T_DescP(2, 0)				
		Lj7T_Total( 2, Lj7T_Subtotal(2) - Lj7T_DescV(2) )
	Endif

	Lj7ZeraPgtos()
	
EndIf

RestArea(aArea701)

Return(nPreco)

////////////////////////////////////////////////////////////////////////////
Static Function f_chgpreco(nItem)
////////////////////////////////////////////////////////////////////////////
  nPreco := aPreco[nItem,2]
  oPreco:Refresh()
Return
