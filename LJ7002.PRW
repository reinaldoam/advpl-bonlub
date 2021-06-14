#Include "protheus.ch"
#Include "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7002    ºAutor  ³TOTVS		     º Data ³  13/05/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LJ7002()

	DbSelectArea("SE1")
	SE1->( DbSetOrder(1))

	If SE1->( DbSeek(xFilial("SE1")+ SL1->(L1_SERIE + SL1->L1_DOC)))
		//SE1->(dbGoTop())   // Avanca o primeiro ponteiro

		While !SE1->(EOF()) .And. SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM) = SL1->(L1_FILIAL + L1_SERIE + SL1->L1_DOC)
			RecLock("SE1",.F.) //EDIÇÃO
			SE1->E1_X_FORPG := SE1->E1_TIPO
			SE1->( DbUnLock() )
			SE1->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		EndDo
		SE1->(DbCloseArea())

	Endif
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravação do peso bruto e liquido no orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If ParamIXB[1] == 1
	   U_BLBLOJP01()
    Endif
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava reserva se o tipo da operação for 2=faturamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If ParamIXB[1] == 1  .And. SL1->L1_XTPOPER == "2"
       U_BLLOJP02()
	Endif   
	If ParamIXB[1] == 2     // Se for finalização de venda
	   If SL1->(FieldPos("L1_XMENNOT")) > 0 // Verifica se o campo existe na SL1
	 	  dbSelectArea("SF2") 
	 	  dbSetOrder(1)
		  If SF2->(DbSeek(xFilial("SF2")+SL1->(L1_DOC+L1_SERIE+L1_CLIENTE+L1_LOJA)))
			 RecLock("SF2", .F. )
			 SF2->F2_MENNOTA := SL1->L1_XMENNOT
			 MsUnLock()	
          Endif
	   Endif
   	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Ponto de entrada para gravação do complemento do produto na CD6 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If ExistBlock("MATUCOMP")
	      U_MATUCOMP()
       Endif
    Endif
	//If MsgYesNo("Deseja emitir relatório separação?")
	//	U_RLOJR001(SL1->L1_NUM,.F.) //chama o relatório de separação
	//EndIf
return
