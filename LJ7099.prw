#include "Protheus.ch"

/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � LJ7099                                     Data: 18/06/2021���
��+----------+------------------------------------------------------------���
���Descri��o � Ponto de entrada para gerar tag <aComb>                    ���
���          � O Ponto de Entrada n�o recebe nenhum par�metro, por�m no   ���
���			     � momento da execu��o, o registro estar� posicionado no item ���
���			     � em quest�o (SL2)                                           ���
��+----------+------------------------------------------------------------���
��� Uso      �TOTVS                                                       ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
User Function LJ7099
  Local cString  := ""
  Local aSA1Area := SA1->(GetArea())
  Local aSB1Area := SB1->(GetArea())
  Local aSL1Area := SL1->(GetArea())
  
  //- Produtos
  dbSelectArea("SB1")
  dbSetOrder(1) 
  MsSeek(xFilial("SB1")+SL2->L2_PRODUTO)
  
  //--- Verifica se e combustivel!!!
  If !Empty(SB1->B1_XCODANP)
     
	   //- Or�amento
     dbSelectArea("SL1")
     dbSetOrder(1) 
     MsSeek(xFilial("SL1")+SL2->L2_NUM)

     //- Cliente
     dbSelectArea("SA1")
     dbSetOrder(1) 
     MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA)

     //��������������������������������������������������������������������������������Ŀ
     //�Para atender venda de �leo lubrificante(combust�vel)  na  vers�o 4.0 da NFC-e. �
     //���������������������������������������������������������������������������������
	   cString += "<comb>"
	   cString += "<cProdANP>"+Alltrim(SB1->B1_XCODANP)+"</cProdANP>"
	   cString += "<descANP>"+Alltrim(SB1->B1_XDESANP)+"</descANP>"
	   cString += "<UFCons>"+SA1->A1_EST+"</UFCons>"
	   cString += "</comb>"

	   //cString += "<comb>"
	   //cString += "<cProdAnp>"+Alltrim(SB1->B1_XCODANP)+"</cProdAnp>"
	   //cString += "<UFCons>"+SA1->A1_EST+"</UFCons>"
     //cString += "<descANP>"+Alltrim(SB1->B1_XDESANP)+"</descANP>"
	   //cString += "</comb>"
  Endif   
  RestArea(aSA1Area)
  RestArea(aSB1Area)
  RestArea(aSL1Area)
Return cString
