#include "Protheus.ch"

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ LJ7099                                     Data: 18/06/2021¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de entrada para gerar tag <aComb>                    ¦¦¦
¦¦¦          ¦ O Ponto de Entrada não recebe nenhum parâmetro, porém no   ¦¦¦
¦¦¦			     ¦ momento da execução, o registro estará posicionado no item ¦¦¦
¦¦¦			     ¦ em questão (SL2)                                           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦TOTVS                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     
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
     
	   //- Orçamento
     dbSelectArea("SL1")
     dbSetOrder(1) 
     MsSeek(xFilial("SL1")+SL2->L2_NUM)

     //- Cliente
     dbSelectArea("SA1")
     dbSetOrder(1) 
     MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Para atender venda de óleo lubrificante(combustível)  na  versão 4.0 da NFC-e. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
