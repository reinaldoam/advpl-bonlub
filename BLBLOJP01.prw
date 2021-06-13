#INCLUDE "protheus.ch"

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BLBLOJP01                                                  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Soma a quantidade de volumes e peso grava na SL1           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦TOTVS                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     
*/

User Function BLBLOJP01
  Local _aArea   := GetArea()
  Local _nVol    := 0
  Local _nPesoL  := 0
  Local _nPesoB  := 0
  Local _cFilPed := SL1->L1_FILIAL+SL1->L1_NUM
   
  DbSelectArea("SL2")
  
  SL2>(DbSetOrder(1))
  SB1->(DbSetOrder(1))
  SL2->(DbSeek(_cFilPed))
  
  Do While !SL2->(Eof()) .And. Alltrim(SL2->L2_FILIAL+SL2->L2_NUM) == _cFilPed
     SB1->(dbseek(xFilial("SB1")+SL2->L2_PRODUTO))
	   _nPesoB += SL2->L2_QUANT * SB1->B1_PESBRU //soma o peso bruto total
	   _nPesoL += SL2->L2_QUANT * SB1->B1_PESO //soma o peso liquido total   
	   SL2->(DbSkip())
  Enddo
  DbSelectArea("SL1")
  RecLock("SL1",.F.)
  SL1->L1_PBRUTO := _nPesoB
  SL1->L1_PLIQUI := _nPesoL
  MsUnlock()
  RestArea(_aArea)
Return
