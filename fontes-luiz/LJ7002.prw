#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ7002
Ponto de entrada na geração da nota e impressão do cupom fiscal
Para tratamento da comissão do vendedor 2 (técnico)
@param      Nenhum
@return     lRet
@author     Luiz Paulo Rodrigues / Totvs MS
@version    12.1.17 / Superior
@since
/*/
//-------------------------------------------------------------------

User function LJ7002()

Local lRet       := .T.
Local nOper      := ParamIXB[1] //1 - Orçamento / 2 - Venda / 3 - Pedido
Local nPosVend2  := aScan( aHeader, { |x| AllTrim( x[2] ) == "LR_VEND2" } )
Local nPosVlItem := aScan( aHeader, { |x| AllTrim( x[2] ) == "LR_VLRITEM" } )
Local nValorItem := 0
Local nPerComis  := 0
Local nZ         := 1
Local cNota      := SF2->F2_DOC
Local cSerie     := SF2->F2_SERIE
Local cCliente   := SF2->F2_CLIENTE
Local cLojaCli   := SF2->F2_LOJA


nValorItem := aCols[nZ][nPosVlItem]
cVend2     := aCols[nZ][nPosVend2]


If nOper == 2 .And. !Empty(cVend2)

    dbSelectArea("SF2")
    dbSetOrder(1)
    If DbSeek(xFilial("SL1")+cNota+cSerie+cCliente+cLojaCli)
        Begin Transaction
        RecLock("SF2",.F.)
        SF2->F2_VEND2 := cVend2
        SF2->(MsUnlock())
        End Transaction
    EndIf

    dbSelectArea("SD2")
    dbSetOrder(3)
    If DbSeek(xFilial("SL1")+cNota+cSerie+cCliente+cLojaCli)

        While !SD2->(EOF()) .And. SD2->D2_DOC == cNota .And. SD2->D2_SERIE == cSerie .And. SD2->D2_CLIENTE == cCliente .And. SD2->D2_LOJA == cLojaCli

            Begin Transaction
            RecLock("SD2",.F.)
            SD2->D2_COMIS2 := fGerComisD2(cVend2)
            SD2->(MsUnlock())
            End Transaction

            nPerComis := SD2->D2_COMIS2
            
            SD2->(DbSkip())
        End
    Endif

    dbSelectArea("SE1")
    dbSetOrder(2)
    If DbSeek(xFilial("SL1")+cCliente+cLojaCli+cSerie+cNota)
        While !SE1->(EOF()) .And. SE1->E1_CLIENTE == cCliente .And. SE1->E1_LOJA == cLojaCli .And. SE1->E1_NUM == cNota .And. SE1->E1_PREFIXO == cSerie
            
            For nZ:=nZ to len(aCols)

                Begin Transaction
                Reclock("SE1",.F.)
                SE1->E1_VEND2   := cVend2
                SE1->E1_COMIS2  := fGerComisD2(cVend2)
                SE1->E1_BASCOM2 := SE1->E1_BASCOM1
                SE1->E1_VALCOM2 := (SE1->E1_COMIS2/100) * SE1->E1_BASCOM2
                SE1->(MsUnlock())
                End Transaction
            
                nZ +=1
                Exit
            Next nZ
            SE1->(dbSkip())
        End

    Endif
    
Endif

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} fGerComisD2
Retorna o % de comissão do vendedor
@param      cVend
@return     Nenhum
@author     Luiz Paulo Rodrigues / Totvs MS
@version    12.1.17 / Superior
@since
/*/
//-------------------------------------------------------------------

Static function fGerComisD2(cVend)

Local nPerComis := 0
Local cSql := ""

If (Select("REC"))
    dbSelectArea("REC")
    REC->(dbCloseArea ())
Endif
cSql := " SELECT A3_COMIS PERCOMISVEND2 "
cSql += " FROM " +RetSqlName("SA3")+ " SA3 "
cSql += " WHERE A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.D_E_L_E_T_=' ' AND A3_COD='"+cVend2+"' " 
TCQUERY cSql NEW ALIAS "REC"
dbSelectArea("REC")
DbGoTop()

nPerComis := PERCOMISVEND2

Return(nPerComis)
