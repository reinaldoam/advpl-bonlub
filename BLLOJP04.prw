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
  Local cDoc      := ""     
  Local cSerie    := ""  
  Local cCliefor  := ""
  Local cLoja     := ""    
  Local cAliasSD1 := "SD1"
  Local cAliasSD2 := "SD2" 
  
  //- Cadastro de produtos
  dbSelectArea("SB1")
  dbSetOrder(1)
  
  //= Complemento de combustíveis
  dbSelectArea("CD6")
  dbSetOrder(1) //- CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD+CD6_PLACA+CD6_TANQUE

  If cTpMov == "S" //- Saida 

     //- Item nota de saida
     DbSelectArea("SD2")
     dbSetOrder(3)

     //- Nota fiscal de saida  
     dbSelectArea("SF2")
     dbSetOrder(1)

     cDoc     := SF2->F2_DOC     
     cSerie   := SF2->F2_SERIE  
     cCliefor := SF2->F2_CLIENTE
     cLoja    := SF2->F2_LOJA    
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
  Else
     //- Nota de entrada
     cDoc     := SF1->F1_DOC     
     cSerie   := SF1->F1_SERIE  
     cCliefor := SF1->F1_FORNECE
     cLoja    := SF1->F1_LOJA    
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Gravando informações no CD6   ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	  dbSelectArea("SF1")
	  dbSetOrder(1)
	  MsSeek(xFilial("SF1")+cDoc+cSerie+cCliefor+cLoja)
         
     dbSelectArea("SD1")
	  dbSetOrder(1)	
     MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

     Do While !SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) ==  SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
              
        SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
              
        If !Empty(SB1->B1_XCODANP) //- Considera somente se tiver código ANP preenchido

           cItem   := SD1->D1_ITEM
           cCodigo := SD1->D1_COD  

  			  dbSelectArea("CD6")
			  dbSetOrder(1)
					  
           If MsSeek(xFilial("CD6")+"E"+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+Padr((cAliasSD1)->D1_ITEM,4)+(cAliasSD1)->D1_COD)
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
           CD6->CD6_UFCONS := SF1->F1_EST      //- UF onde será consumido
           CD6->(MsUnLock())
        Endif
        DbSelectArea("SD1")
        SD1->(DbSkip())
     Enddo
  Endif   
Return
