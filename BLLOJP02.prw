#include "protheus.ch"

/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � BLLOJP02                                                   ���
��+----------+------------------------------------------------------------���
���Descri��o � Reserva de produtos.                                       ���
��+----------+------------------------------------------------------------���
��� Uso      �TOTVS                                                       ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
User Function BLLOJP02
  Local _aArea := GetArea()
  If Inclui
     //���������������������������������������������������������������Ŀ
     //�Chama a fun��o para incluir reserva dos produtos do or�amento �
     //����������������������������������������������������������������
     IncBLLOJP02() 
  Else
     If Altera //- Verifica se � uma altera��o (finaliza��o de vendas)
        //���������������������������������������������������������������Ŀ
        //�Chama a fun��o para alterar reserva dos produtos do or�amento �
        //����������������������������������������������������������������
        AltBLLOJP02() 
     Endif
  Endif   
  RestArea(_aArea)
Return

////////////////////////////
Static Function IncBLLOJP02
  Local _cFilPed := SL1->L1_FILIAL+SL1->L1_NUM
  Local aOperacao := {}
  Local cNumRes := ""
  Local nSaveSx8 := GetSx8Len()	//- Numeracao do SX8
  Local lFirst := .T.
  Local cProduto := ""
  Local cLocal := ""
  Local cObserv := ""
  Local cMsg := ""
  Local aLote := {}
  Local aPrdSemEst := {}
  Local lRet := .F.

  //- Clientes
  DbSelectArea("SA1")
  DbSetOrder(1)

  //- Vendedor
  DbSelectArea("SA3")
  DbSetOrder(1)

  //- Produtos
  DbSelectArea("SB1")
  DbSetOrder(1)

  //- Itens do or�amento
  DbSelectArea("SL2")
  DbSetOrder(1)

  //����������������������������������������������Ŀ
  //�Verifica se o cliente foi gravado corretamente�
  //������������������������������������������������
  SA1->(DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
  SA3->(DbSeek(xFilial("SA3")+SL1->L1_VEND))

  SL2->(DbSeek(_cFilPed))
  
  Do While !SL2->(Eof()) .And. Alltrim(SL2->L2_FILIAL+SL2->L2_NUM) == _cFilPed
     //������������������������������������������������Ŀ
     //�No primeiro registro pega um numero de reserva �
     //�������������������������������������������������
     If lFirst
        cNumRes := GetSx8Num("SC0","C0_NUM")
        While (GetSX8Len() > nSaveSx8)
           ConfirmSx8()
        Enddo
        lFirst := .F.
     Endif
     //-------------------------------------------------------------------------------
     //Fun�ao: a430Reserv(aOperacao, cNumRes, cProduto, cLocal, nQuant, aLote, {}, {}
     //-------------------------------------------------------------------------------
     //aOperacao                              *Obrigat�rio
     //-------------------------------------------------------------------------------
     //[1] -> [Operacao : 1 Inclui,2 Altera,3 Exclui]
     //[2] -> [Tipo da Reserva]
     //[3] -> [Documento que originou a Reserva]
     //[4] -> [Solicitante]
     //[5] -> [Filial da Reserva]
     //[6] -> [Observacao]
     //-------------------------------------------------------------------------------
     //cNUMERO	 -> N�mero da reserva          *Obrigat�rio				
     //cPRODUTO -> C�digo do produto			 *Obrigat�rio				
     //cLOCAL	 -> Almoxarifado da reserva    *Obrigat�rio				
     //nQUANT	 -> Quantidade reservada		 *Obrigat�rio
     //-------------------------------------------------------------------------------				
     //aLOTE			                         *Obrigat�rio			
     //[1] -> [Numero do Lote]             
     //[2] -> [Lote de Controle]
     //[3] -> [Localizacao]
     //[4] -> [Numero de Serie]						
     //------------------------------------------------------------------------------- 
     cProduto  := SL2->L2_PRODUTO
     cLocal    := SL2->L2_LOCAL
     nQuant    := SL2->L2_QUANT
     cObserv   := "Pedido:"+SL1->L1_NUM+" "+"Filial:"+xFilial("SL1")

     aOperacao := {1,"LJ", SA1->A1_COD, Left(SA3->A3_NREDUZ,20), xFilial("SC0"), cObserv} // 1=Inclus�o de reserva
     
     aLote     := {SL2->L2_NLOTE, SL2->L2_LOTECTL, SL2->L2_LOCALIZ, SL2->L2_NSERIE}
      
     //-------------------------------------------------------------------------------
     lRet := a430Reserv(aOperacao, cNumRes, cProduto, cLocal, nQuant, aLote, {}, {} )
     //-------------------------------------------------------------------------------
     If lRet
        //��������������������������������������Ŀ
        //� Atualiza campos de reservas na SL2  �
        //����������������������������������������
        RecLock("SL2",.F.)
        SL2->L2_RESERVA := cNumRes
        SL2->L2_LOJARES := xFilial("SL2")
        SL2->L2_FILRES  := xFilial("SL2")
        SL2->L2_ENTREGA := '1' //- Retira posterior 
        MsUnLock()
     Else
        SB1->(dbseek(xFilial("SB1")+SL2->L2_PRODUTO))
        Aadd( aPrdSemEst, AllTrim(cProduto) + " - " + AllTrim(SB1->B1_DESC))
     Endif   
     SL2->(DbSkip())
  Enddo
  If lRet
     RecLock("SL1",.F.)
     SL1->L1_RESERVA := "S"
     MsUnLock()	
  Else
     RecLock("SL1",.F.)
     SL1->L1_XTPOPER := "1" //- Volta para a situa��o de or�amento
     MsUnLock()	
     //������������������������������������������������������Ŀ
     //� Emite alerta com os itens que n�o foram reservados  �
     //�������������������������������������������������������
     If Len(aPrdSemEst) > 0
        cMsg := "N�o existe estoque suficiente para o(s) seguinte(s) produto(s):" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
        For nX:=1 To Len(aPrdSemEst)
           cMsg += aPrdSemEst[nX] + Chr(13) + Chr(10)
        Next nX
        Alert(cMsg)
     Endif
  Endif
Return

////////////////////////////
Static Function AltBLLOJP02
  Local lRet := .F.
  Local cCodUsu := RetCodUsr() //- Codigo do usuario logado
  Local _cCaixa := Posicione("SLF",1,xFilial("SLF")+cCodUsu,"LF_ACESSO")
  Local _cRet   := Substring(_cCaixa,3,1)
  
  //- Se usu�rio for caixa n�o faz nenhuma valida��o e continua encerrando a venda
  If _cRet == "S"
     Return
  Endif
  
  lRet := U_BLLOJP03("",.F.) //- Chama a rotina de cancelamento de reservas 
  
  If lRet
     IncBLLOJP02() //- Chama novamente a rotina de inclus�o para gravar a nova reserva 
  Endif
Return
