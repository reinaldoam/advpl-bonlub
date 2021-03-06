#Include "protheus.ch"
#Include "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJ7002    �Autor  �TOTVS		     � Data �  13/05/21   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function LJ7002()
    
  //- Contas a receber
  DbSelectArea("SE1")
  DbSetOrder(1)

  If SE1->( DbSeek(xFilial("SE1")+ SL1->(L1_SERIE + SL1->L1_DOC)))
     Do While !SE1->(EOF()) .And. SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM) = SL1->(L1_FILIAL + L1_SERIE + SL1->L1_DOC)
	     RecLock("SE1",.F.) //EDI��O
		  SE1->E1_X_FORPG := SE1->E1_TIPO
		  SE1->( DbUnLock() )
		  SE1->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	  Enddo
  Endif
  //������������������������������������������������Ŀ
  //� Grava��o do peso bruto e liquido no orcamento �
  //��������������������������������������������������
  If ParamIXB[1] == 1
     U_BLBLOJP01()
  Endif
  //��������������������������������������������������������Ŀ
  //� Grava reserva se o tipo da opera��o for 2=faturamento �
  //����������������������������������������������������������
  If ParamIXB[1] == 1  .And. SL1->L1_XTPOPER == "2"
     U_BLLOJP02()
  Endif 
  If ParamIXB[1] == 2 //- Finalizado como venda
     //u_BLLOJP04("1") - Chamado para gravar a tabela CD6
     //If AllTrim(SF2->F2_SERIE) $ GetMV("MV_ESPECIE")
	  //   AutoNfeEnv(cEmpAnt, SF2->F2_FILIAL, "0", "1", SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_DOC)
	  //Endif
  Endif
Return
