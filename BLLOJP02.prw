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
  Local _aArea    := GetArea()
  Local _cFilPed  := SL1->L1_FILIAL+SL1->L1_NUM
  Local aOperacao := {}
  Local cNumRes   := ""
  Local nSaveSx8  := GetSx8Len()	//- Numeracao do SX8
  Local lFirst    := .T.
  Local lConfirma := .T.
  Local cProduto := ""
  Local cLocal := ""
  Local aLote := {}
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

  //- Saldo em estoque
  DbSelectArea("SB2")
  DbSetOrder(1)

  //- Itens do or�amento
  DbSelectArea("SL2")
  DbSetOrder(1)

  //- Reservas
  DbSelectArea("SC0")
  DbSetOrder(1)

  //����������������������������������������������Ŀ
  //�Verifica se o cliente foi gravado corretamente�
  //������������������������������������������������
  SA1->(DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
  SA3->(DbSeek(xFilial("SA3")+SL1->L1_VEND))

  aOperacao := {1,"LJ", SA1->A1_COD, Left(SA3->A3_NREDUZ,20), xFilial("SC0")}

  SL2->(DbSeek(_cFilPed))
  
  Do While !SL2->(Eof()) .And. Alltrim(SL2->L2_FILIAL+SL2->L2_NUM) == _cFilPed

     SB1->(dbseek(xFilial("SB1")+SL2->L2_PRODUTO))
     
     //����������������������������������Ŀ
	 //� Recupera saldo atual do produto �
	 //�����������������������������������
     SB2->(DbSetOrder(1))
     SB2->(DbSeek(xFilial("SB2")+SL2->(L2_PRODUTO+L2_LOCAL)))
           
     nSaldo := SB2->B2_QATU - SB2->B2_RESERVA
     nQuant := SL2->L2_QUANT

     If nSaldo < nQuant //- Verifica se tem saldo
        lConfirma := .F.
        Exit   
     Endif   
     If lFirst
        //�������������������������������������������������������������������Ŀ
        //�Pega um numero de reserva                                          �
        //���������������������������������������������������������������������
        cNumRes := GetSx8Num("SC0","C0_NUM")
        While (GetSX8Len() > nSaveSx8)
           ConfirmSx8()
        Enddo
        lFirst := .F.
     Endif
     //�����������������������������������������������������������������������Ŀ
     //�Configura as variaveis para fazer a reserva                            �
     //�������������������������������������������������������������������������
     cProduto := SL2->L2_PRODUTO
     cLocal := SL2->L2_LOCAL
     
     aLote:= {SL2->L2_NLOTE,SL2->L2_LOTECTL,SL2->L2_LOCALIZ,SL2->L2_NSERIE}
    
     lRet := a430Reserv(aOperacao, cNumRes, cProduto, cLocal, nQuant, aLote, {}, {} )
     
     If lRet
        SC0->(DbSeek(xFilial("SC0")+cNumRes+cProduto+cLocal))
        RecLock("SC0",.F.) 
        SC0->C0_OBS := "Pedido:"+SL1->L1_DOC+" Filial:"+xFilial("SL1")
        MsUnLock()

        //��������������������������������������Ŀ
        //� Atualiza campos de reservas na SL2  �
        //����������������������������������������
        RecLock("SL2",.F.)
        SL2->L2_RESERVA := cNumRes
        SL2->L2_LOJARES := xFilial("SL2")
        SL2->L2_FILRES  := xFilial("SL2")
        SL2->L2_ENTREGA := '1' //- Retira posterior 
        MsUnLock()
        
        //��������������������������������������Ŀ
        //� Atualiza campo B2_RESERVA           �
        //����������������������������������������
        RecLock("SB2",.F.) 
        SB2->B2_RESERVA := SB2->B2_RESERVA + 1 
        MsUnLock()
     Endif   
     SL2->(DbSkip())
  Enddo
  If lRet
     RecLock("SL1",.F.)
     SL1->L1_RESERVA := "S"
     MsUnLock()	
  Endif
  RestArea(_aArea)
Return
