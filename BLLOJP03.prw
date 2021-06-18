#include "protheus.ch"
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BLLOJP03                                                   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cancelamento de reservas de produtos.                      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦TOTVS                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     
*/
User Function BLLOJP03(cNumOrc,lMenu)
  Local _aArea := GetArea()
  Local _cFilPed  := SL1->L1_FILIAL+SL1->L1_NUM
  Local aOperacao := {}
  Local cNumRes   := ""
  Local cProduto := ""
  Local cLocal := ""
  Local cObserv := ""
  Local aLote := {}
  Local lRet := .T.
  Local lOk := .T.
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Desconsidera oçamentos sem reservas  ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  If lMenu
     If MsgYesNo("Confirma cancelamento da reserva ?")
	    lOk:= .T.
	 EndIf
  Endif     
  
  If !lOk  
     RestArea(_aArea) 
     lRet := .T.
     Return lRet
  Endif
  
  //- Clientes
  DbSelectArea("SA1")
  DbSetOrder(1)
  
  //- Vendedor
  DbSelectArea("SA3")
  DbSetOrder(1)

  //- Itens do orçamento
  DbSelectArea("SL2")
  DbSetOrder(1)
  
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Verifica se o cliente foi gravado corretamente³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SA1->(DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
  SA3->(DbSeek(xFilial("SA3")+SL1->L1_VEND))
  
  SL2->(DbSeek(_cFilPed))

  Do While !SL2->(Eof()) .And. Alltrim(SL2->L2_FILIAL+SL2->L2_NUM) == _cFilPed
     
     If !Empty(SL2->L2_RESERVA) //- Verifica se tem reserva
        cNumRes   := SL2->L2_RESERVA 
        cProduto  := SL2->L2_PRODUTO
        cLocal    := SL2->L2_LOCAL
        nQuant    := SL2->L2_QUANT
        cObserv   := "Pedido:"+SL1->L1_NUM+" "+"Filial:"+xFilial("SL1")
        
        aOperacao := {3,"LJ", SA1->A1_COD, Left(SA3->A3_NREDUZ,20), xFilial("SC0"), cObserv} //- 3=Exclusão reserva
        
        aLote     := {SL2->L2_NLOTE, SL2->L2_LOTECTL, SL2->L2_LOCALIZ, SL2->L2_NSERIE}
        
        //-------------------------------------------------------------------------------
        lRet := a430Reserv(aOperacao, cNumRes, cProduto, cLocal, nQuant, aLote, {}, {} )
        //-------------------------------------------------------------------------------
        If lRet
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Limpa campos de reserva  ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           RecLock("SL2",.F.)
           SL2->L2_RESERVA := ""
           SL2->L2_LOJARES := ""
           SL2->L2_FILRES  := ""
           SL2->L2_ENTREGA := '2' //- volta para retira
           MsUnLock()
        Endif
     Endif   
     SL2->(DbSkip())
  Enddo
  If lRet
     RecLock("SL1",.F.)
     SL1->L1_RESERVA := "" //- Limpa reserva
     MsUnLock()	
  Endif
  RestArea(_aArea)
Return lRet
