#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "rwmake.ch"

User function LJ7001()

Local lRet  := .T.
Local nOper := ExpN1 //1 - Orçamento / 2 - Venda / 3 - Pedido

If nOper == 2
    Conout("LJ7001")
Endif

RETURN(lRet)
