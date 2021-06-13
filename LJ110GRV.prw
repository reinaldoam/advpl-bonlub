#INCLUDE "topconn.ch"     
#INCLUDE "rwmake.ch"

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LJ110GRV   ¦ Autor ¦TOTVS			  ¦ Data ¦ 28/12/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de Entrada na validacao da inclusao do produto       ¦¦¦
¦¦¦          ¦ Grupo + Sequencial                                         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦            
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
 
User Function LJ110GRV()

If Inclui 
	M->B1_COD := U_RETCODPRO(M->B1_GRUPO,M->B1_TIPO)
EndIf
               
Return(.t.)

User Function RETCODPRO(cGrupo,cTipo)
    Local cAlias := ""
    Local cQuery := ''
    Local QAux, nSeq, cRetorno, _cTMS
    Local nTam, nTamGrupo, nTamTipo  := 0

    nTamTipo  := TamSX3("B1_TIPO")[1]
    nTamGrupo := TamSX3("B1_GRUPO")[1]
	nTam      := TamSX3("B1_COD")[1] - nTamTipo - nTamGrupo

    cQuery := "SELECT MAX(b1_cod) as NSEQUEN "
    cQuery += " FROM "+RetSqlName('SB1')
    cQuery += " WHERE "
    cQuery +=        "D_E_L_E_T_ <> '*' "
    cQuery +=   " AND B1_FILIAL  =  '"+xfilial("SB1")+"'"
    cQuery +=   " AND B1_GRUPO   =  '"+cGrupo+"'"
    cQuery +=   " AND B1_TIPO   =  '"+cTipo+"'"
    /*Olhar sempre as posições do Substring conforme o tamanho do seu campo de código de produto*/
    cQuery +=   " AND SUBSTRING(B1_COD,1,4) = '"+cGrupo+"'"
    cQuery +=   " AND SUBSTRING(B1_COD,5,2) = '"+cTipo+"'"

    cQuery := Changequery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    nSeq := Soma1(substr((cAlias)->NSEQUEN,nTamGrupo+nTamTipo+1,nTam))
    (cAlias)->(dbCloseArea())

    if Empty(nSeq) 
        nSeq := Soma1("0",nTamGrupo+nTamTipo+1,nTam)
    EndIF


    cRetorno := AllTrim(cGrupo)+AllTrim(cTipo)+PADL(nSeq,nTam,"0")

    if Empty(cRetorno)
        cRetorno := AllTrim(cGrupo)+AllTrim(cTipo)+PADL("1",nTam,"0")
    EndIf

    
Return(cRetorno)
