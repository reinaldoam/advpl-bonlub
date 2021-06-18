#INCLUDE "TOPCONN.CH"
#include "protheus.ch"

USER FUNCTION PE01NFESEFAZ()
  Local aProd     := PARAMIXB[1]
  Local cMensCli  := PARAMIXB[2]
  Local cMensFis  := PARAMIXB[3]
  Local aDest     := PARAMIXB[4]
  Local aNota     := PARAMIXB[5]
  Local aInfoItem := PARAMIXB[6]
  Local aDupl     := PARAMIXB[7]
  Local aTransp   := PARAMIXB[8]
  Local aEntrega  := PARAMIXB[9]
  Local aRetirada := PARAMIXB[10]
  Local aVeiculo  := PARAMIXB[11]
  Local aReboque  := PARAMIXB[12]
  Local aNfVincRur:= PARAMIXB[13]
  Local aEspVol   := PARAMIXB[14]
  Local aNfVinc   := PARAMIXB[15]
  Local AdetPag   := PARAMIXB[16]
  Local aObsCont  := PARAMIXB[17]
  Local aProcRef  := PARAMIXB[18]
  Local aComb     := PARAMIXB[19] 
  Local cTipo     := PARAMIXB[20] //- Tipo da NF -> 0=Entrada 1=Saida
  Local aRetorno  := {}

  Local cDoc     := ""     
  Local cSerie   := ""  
  Local cCliefor := ""
  Local cLoja    := ""    
  Local cItem    := ""
  Local cCodigo  := ""

  Local cAliasSD2:= "SD2"

  //- Cadastro de produtos
  dbSelectArea("SB1")
  dbSetOrder(1)
  
  //= Complemento de combustíveis
  dbSelectArea("CD6")
  dbSetOrder(1) //- CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD+CD6_PLACA+CD6_TANQUE

  //- Item nota de saida
  DbSelectArea("SD2")
  dbSetOrder(3)

  //O retorno deve ser exatamente nesta ordem e passando o conteúdo completo dos arrays
  //pois no rdmake nfesefaz é atribuido o retorno completo para as respectivas variáveis
  //Ordem:
  //      aRetorno[1] -> aProd
  //      aRetorno[2] -> cMensCli
  //      aRetorno[3] -> cMensFis
  //      aRetorno[4] -> aDest
  //      aRetorno[5] -> aNota
  //      aRetorno[6] -> aInfoItem
  //      aRetorno[7] -> aDupl
  //      aRetorno[8] -> aTransp
  //      aRetorno[9] -> aEntrega
  //      aRetorno[10] -> aRetirada
  //      aRetorno[11] -> aVeiculo
  //      aRetorno[12] -> aReboque
  //      aRetorno[13] -> aNfVincRur
  //      aRetorno[14] -> aEspVol
  //      aRetorno[15] -> aNfVinc
  //      aRetorno[16] -> AdetPag
  //      aRetorno[17] -> aObsCont 
  //      aRetorno[18] -> aProcRef 

  If cTipo == "1" //- Nota de saida
	   
     If AliasIndic("CD6")  .And. CD6->(FieldPos("CD6_QTAMB")) > 0 .And. CD6->(FieldPos("CD6_UFCONS")) > 0  .And. CD6->(FieldPos("CD6_BCCIDE")) > 0 .And. CD6->(FieldPos("CD6_VALIQ")) > 0 .And. CD6->(FieldPos("CD6_VCIDE")) > 0
		    
        U_BLLOJP04(cTipo) //- Chamada função para gravar dados ANP na tabela CD6

        cDoc     := SF2->F2_DOC     
        cSerie   := SF2->F2_SERIE  
        cCliefor := SF2->F2_CLIENTE
        cLoja    := SF2->F2_LOJA    
                
        SD2->(DbSeek(xFilial("SD2")+cDoc+cSerie+cCliefor+cLoja))

        Do While !SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) ==  xFilial("SD2")+cDoc+cSerie+cCliefor+cLoja
        
           cItem   := SD2->D2_ITEM
           cCodigo := SD2->D2_COD  
           
           SB1->(DbSeek(xFilial("SB1")+cCodigo))
          
           If !Empty(SB1->B1_XCODANP) //- Considera somente se tiver código ANP preenchido

  			     dbSelectArea("CD6")
				  dbSetOrder(1)
					  
              If MsSeek(xFilial("CD6")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+Padr((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD)
   
                 alert("Preenchendo aComb")

	 			     Aadd(aComb,{CD6->CD6_CODANP,;
						           CD6->CD6_SEFAZ,;
						           CD6->CD6_QTAMB,;
						           CD6->CD6_UFCONS,;
						           CD6->CD6_BCCIDE,;
						           CD6->CD6_VALIQ,;
						           CD6->CD6_VCIDE,;
						           IIf(CD6->(ColumnPos("CD6_MIXGN")) > 0,CD6->CD6_MIXGN,""),;
						           IIf(CD6->(ColumnPos("CD6_BICO")) > 0,CD6->CD6_BICO,""),;
						           IIf(CD6->(ColumnPos("CD6_BOMBA")) > 0,CD6->CD6_BOMBA,""),;
						           IIf(CD6->(ColumnPos("CD6_TANQUE")) > 0,CD6->CD6_TANQUE,""),;
						           IIf(CD6->(ColumnPos("CD6_ENCINI")) > 0,CD6->CD6_ENCINI,""),;
						           IIf(CD6->(ColumnPos("CD6_ENCFIN")) > 0,CD6->CD6_ENCFIN,""),;
						           IIf(CD6->(ColumnPos("CD6_DESANP")) > 0,CD6->CD6_DESANP,""),;
						           IIf(CD6->(ColumnPos("CD6_PGLP")) > 0,CD6->CD6_PGLP,""),;
						           IIf(CD6->(ColumnPos("CD6_PGNN")) > 0,CD6->CD6_PGNN,""),;
						           IIf(CD6->(ColumnPos("CD6_PGNI")) > 0,CD6->CD6_PGNI,""),;
						           IIf(CD6->(ColumnPos("CD6_VPART")) > 0,CD6->CD6_VPART,""),;
						           0,;
						           0,;
						           0,;
						           0,;
						        	  0})
              Endif
           Endif     
           DbSelectArea("SD2") 
           SD2->(DbSkip())
        Enddo
     Endif      
  Else
     //- Nota de entrada
  Endif         

  aadd(aRetorno,aProd)
  aadd(aRetorno,cMensCli)
  aadd(aRetorno,cMensFis)
  aadd(aRetorno,aDest)
  aadd(aRetorno,aNota)
  aadd(aRetorno,aInfoItem)
  aadd(aRetorno,aDupl)
  aadd(aRetorno,aTransp)
  aadd(aRetorno,aEntrega)
  aadd(aRetorno,aRetirada)
  aadd(aRetorno,aVeiculo)
  aadd(aRetorno,aReboque)
  aadd(aRetorno,aNfVincRur)
  aadd(aRetorno,aEspVol)
  aadd(aRetorno,aNfVinc)
  aadd(aRetorno,AdetPag)
  aadd(aRetorno,aObsCont)
  aadd(aRetorno,aProcRef)
  aadd(aRetorno,aComb)
 
RETURN aRetorno
