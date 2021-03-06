#INCLUDE "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJ7060    �Autor  �TOTVS               � Data �  03/06/2021 ���
�������������������������������������������������������������������������͹��
���Desc.     � O ponto de entrada LJ7060 tem como objetivo permitir que o ���
���          � cliente filtre os registros da mBrowse da Venda Assistida. ���
���          �          						                          ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function LJ7060()
	Local _cRet		:= ""
	Local cCodUsu   := RetCodUsr() //- Codigo do usuario logado
	Local cCodVend  := ""
	Local cFiltro 	:= ""
	Local _cCaixa	:= Posicione("SLF",1,XFILIAL("SLF")+cCodUsu,"LF_ACESSO")

	cCodVend := Posicione("SA3",7,xFilial("SA3")+cCodUsu,"A3_COD")
	_cCod 	:= __cUserId

	If !Empty(cCodVend)
		_cRet := SUBSTR(_cCaixa,3,1)

		IF _cRet == "S"
			cFiltro := ""

		Else
			cFiltro := "L1_VEND = "+ cCodVend

		EndIf
	EndIf


Return cFiltro
