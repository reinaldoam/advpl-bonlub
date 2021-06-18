#INCLUDE "topconn.ch"     
#INCLUDE "rwmake.ch"

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BLLOJP04   ¦ Autor ¦TOTVS        	   ¦ Data ¦ 03/06/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Utilizado para alterações automáticas nos complementos     ¦¦¦
¦¦¦          ¦ dos documentos fiscais após a emissão das Notas Fiscais.   ¦¦¦
¦¦¦          ¦ Especifico tabela Cobustivel. Colocar MV_ATUCOMP = .T.     ¦¦¦
¦¦¦          ¦ Também responsável por gravar a mensagem para NFE.         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦                                                                       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function BLLOJP04(cTipo)
  Local cTpMov    := IIF(cTipo == "0", "E", "S")
  Local cDoc      := SF2->F2_DOC     
  Local cSerie    := SF2->F2_SERIE  
  Local cCliefor  := SF2->F2_CLIENTE
  Local cLoja     := SF2->F2_LOJA    
  Local cAliasSD2 := "SD2" 
  
  //- Cadastro de produtos
  dbSelectArea("SB1")
  dbSetOrder(1)
  
  //= Complemento de combustíveis
  dbSelectArea("CD6")
  dbSetOrder(1) //- CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD+CD6_PLACA+CD6_TANQUE

  //- Item nota de saida
  DbSelectArea("SD2")
  dbSetOrder(3)

  //- Nota fiscal de saida  
  dbSelectArea("SF2")
  dbSetOrder(1)

  If cTpMov == "S" //- Saida 
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Gravando a mensagem da nota fiscal informada no orçamento  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If SL1->(FieldPos("L1_XMENNOT")) > 0 // Verifica se o campo existe na SL1
        If SF2->(DbSeek(xFilial("SF2")+SL1->(L1_DOC+L1_SERIE+L1_CLIENTE+L1_LOJA)))
	        RecLock("SF2", .F. )
		     SF2->F2_MENNOTA := SL1->L1_XMENNOT
		     MsUnLock()	
        Endif
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Gravando informações no CD6                                ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If SF2->(DbSeek(xFilial("SF2")+cDoc+cSerie+cClieFor+cLoja))
          
        If SD2->(DbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))

           Do While !SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) ==  SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
              
              SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
              
              If !Empty(SB1->B1_XCODANP) //- Considera somente se tiver código ANP preenchido

                 cItem   := SD2->D2_ITEM
                 cCodigo := SD2->D2_COD  

  					  dbSelectArea("CD6")
					  dbSetOrder(1)
					  
                 If MsSeek(xFilial("CD6")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+Padr((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD)
                    RecLock("CD6",.F.)
                 Else	
                    RecLock("CD6",.T.)	
                    CD6->CD6_FILIAL := xFilial("CD6") 
                    CD6->CD6_TPMOV  := cTpMov 
                    CD6->CD6_SERIE  := cSerie
                    CD6->CD6_DOC    := cDoc
                    CD6->CD6_CLIFOR := cCliefor
                    CD6->CD6_LOJA   := cLoja
                    CD6->CD6_ITEM   := cItem
                    CD6->CD6_COD    := cCodigo
                    CD6->CD6_PLACA  := ""
                    CD6->CD6_TANQUE := ""
                 EndIf
                 CD6->CD6_CODANP := SB1->B1_XCODANP  //- Código ANP 
                 CD6->CD6_DESANP := SB1->B1_XDESANP  //- Descrição conforme SIMP - https://simp.anp.gov.br/tabela-codigos.asp
                 CD6->CD6_UFCONS := SF2->F2_EST      //- UF onde será consumido
                 CD6->(MsUnLock())
              Endif
              DbSelectArea("SD2")
              SD2->(DbSkip())
           Enddo
        Endif   
     Endif   
  Endif     
Return
