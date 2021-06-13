#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"


User Function LJ7099()
Local aSL1Area := SL1->( GetArea() )
Local aSL2Area := SL2->( GetArea() )
Local aSB1Area := SB1->( GetArea() )
Local cXML := ""
Local aLeg := {}

//--- Posiciona SB1
SB1->( DbSetOrder(1), DbSeek( xFilial("SB1") + SL2->L2_PRODUTO ) )

//--- Verifica se e combustivel!!!
if Empty(SB1->B1_XCODANP)
	Return cXML
endif

cXML += "<comb>"

	cXML += "<cProdANP>" + SB1->B1_XCODANP + "</cProdANP>"  //consultar tabela de código ANP
	cXML += '<descANP>SEM DESCRICAO PARA ' + SB1->B1_XCODANP + '</descANP>'
	cXML += "<UFCons>" + ->M0_ESTCOB + "</UFCons>"

	/*if !Empty(SL2->L2_LEGCOD)
	
		cXML += "<encerrante>"

			cXML += "<nBico>" + SL2->L2_BICO + "</nBico>"
			cXML += "<nTanque>" + SL2->L2_LOCAL + "</nTanque>"
			
			aLeg := RetLEG(SL2->L2_LEGCOD)

			cXML += "<vEncIni>" + aLeg[01] + "</vEncIni>"
			cXML += "<vEncFin>" + aLeg[02] + "</vEncFin>"

		cXML += "</encerrante>"

	endif*/

cXML += "</comb>"

RestArea(aSL1Area)
RestArea(aSL2Area)
RestArea(aSB1Area)
Return cXML
