#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} wWSL010
Cadastro de Marca/UM X % de Margem
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / TMS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

User Function WSL010()

Local cAlias := "ZA1"

Private cCadastro := "Cadastro de Marca/UM x % Margem"

Private aRotina   := {}
AADD(aRotina, { "Pesquisar"  , "AxPesqui", 0, 1 })
AADD(aRotina, { "Visualizar" , "AxVisual", 0, 2 })
AADD(aRotina, { "Incluir"    , "AxInclui", 0, 3 })
AADD(aRotina, { "Alterar"    , "AxAltera", 0, 4 })
AADD(aRotina, { "Excluir"    , "AxDeleta", 0, 5 })
AADD(aRotina, { "Processar"  , "u_fProcWsl010()", 0, 6 })

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse( 6,1,22,75,cAlias,,,,,,,,,,,,,,,)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fProcWsl010
Função para executar a rotina de processamento para garavação dos
Preços na tabela SB0.
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / TMS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

User function fProcWsl010()

Local _cSql := ""
Local cPerg := "WSL010"
Local nCM1  := 0

Private nPrcSB0 := 0

If !Pergunte(cPerg, .T.)
	Return(NIL)
EndIf

cGrupoDe    := MV_PAR01
cGrupoAte   := MV_PAR02
cUMDe       := MV_PAR03
cUMAte      := MV_PAR04
nTipoPrc    := MV_PAR05

If (Select("TMP"))
    dbSelectArea("TMP")
    TMP->(dbCloseArea ())
Endif

_cSql := " SELECT B1_COD,B1_GRUPO,B1_UM,B9_CM1,B1_GRTRIB,B1_UPRC "
_cSql += " FROM " +RetSQLName("SB9")+ " SB9 "
_cSql += " INNER JOIN " +RetSQLName("SB1")+ " SB1 ON B1_COD=B9_COD AND B1_COD <> ' ' AND SB1.D_E_L_E_T_ = ' ' "
_cSql += " WHERE SB9.D_E_L_E_T_ = ' ' "
_cSql += " AND B1_GRUPO BETWEEN '"+cGrupoDe+"' AND '"+cGrupoAte+"' "
_cSql += " AND B1_UM BETWEEN '"+cUMDe+"' AND '"+cUMAte+"' "
_cSql += " AND B9_CM1 > 0 "
_cSql += " AND B9_COD <> ' ' "
_cSql += " AND B9_FILIAL ='0101' "
_cSql += " ORDER BY B1_COD "

TCQUERY _cSql NEW ALIAS "TMP"
dbSelectArea("TMP")
DbGoTop()

nIcms := (100 - GetMV("MV_ICMPAD")) / 100

Do While !TMP->(EOF())
   cProduto  := TMP->B1_COD
   cGrupoSB1 := TMP->B1_GRUPO
   cUM       := TMP->B1_UM
   nCM1      := TMP->B9_CM1
   cGrTrib   := Alltrim(TMP->B1_GRTRIB)

   If nTipoPrc = 1 //- Custo médio
      nCM1 := CustoMedio(TMP->B1_COD) //TMP->B9_CM1   
   ElseIf cTipoPrc = 2 //- Custo reposição
      nCM1 := TMP->B1_UPRC
   Endif 
    
   SB0->(dbSetOrder(1))

   Begin Transaction
      If SB0->(dbSeek(xFilial("SB0")+cProduto))
         RecLock("SB0",.F.)
      Else           
         RecLock("SB0",.T.)
      Endif   
      SB0->B0_FILIAL := xFilial("SB0") 
      SB0->B0_COD    := cProduto
       
      //- Preço 1
      nPrcSB0 := 0
      Processa( {|| fPreco(@cGrupoSB1,@cUM,nCM1,"1")}, "Aguarde...", "Processando Preço 1",.F.)
      If cGrTrib == "001" //- ICMS Tributado integralmente
         nPrcSB0 := nPrcSB0 / nIcms 
      Endif
      SB0->B0_PRV1 := nPrcSB0
       
      //- Preço 2
      nPrcSB0 := 0
      Processa( {|| fPreco(@cGrupoSB1,@cUM,nCM1,"2")}, "Aguarde...", "Processando Preço 2",.F.)
      If cGrTrib == "001" //- Tributado integralmente
         nPrcSB0 := nPrcSB0 / nIcms 
      Endif
      SB0->B0_PRV2 := nPrcSB0
       
      //- Preço 3
      nPrcSB0 := 0
      Processa( {|| fPreco(@cGrupoSB1,@cUM,nCM1,"3")}, "Aguarde...", "Processando Preço 3",.F.)
      If cGrTrib == "001" //- Tributado integralmente
         nPrcSB0 := nPrcSB0 / nIcms 
      Endif
      SB0->B0_PRV3 := nPrcSB0
       
      //- Preço 4
      nPrcSB0 := 0
      Processa( {|| fPreco(@cGrupoSB1,@cUM,nCM1,"4")}, "Aguarde...", "Processando Preço 4",.F.)
      SB0->B0_PRV4 := nPrcSB0
      SB0->(MsUnlock())
   End Transaction
   TMP->(dbSkip())
Enddo

ApMsgInfo("Processamento concluido com sucesso!")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPreco
Função para retornar o preço conforme margem na tabela ZA1
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / TMS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

Static function fPreco(cGrupoSB1,cUM,nCusto,cPreco)

Local nCalc1 := 0

If ZA1->(dbSetOrder(1),dbSeek(xFilial("ZA1")+cGrupoSB1))

    If cPreco == "1"
        nCalc1 := ZA1->ZA1_MARG1/100
        nPrcSB0 := (nCalc1*nCusto)+nCusto
    Endif

    If cPreco == "2"
        nCalc1 := ZA1->ZA1_MARG2/100
        nPrcSB0 := (nCalc1*nCusto)+nCusto
    Endif

    If cPreco == "3"
        nCalc1 := ZA1->ZA1_MARG3/100
        nPrcSB0 := (nCalc1*nCusto)+nCusto
    Endif

    If cPreco == "4"
        nCalc1 := ZA1->ZA1_MARG4/100
        nPrcSB0 := (nCalc1*nCusto)+nCusto
    Endif

EndIf

//nPrcSB0 := Round(nPrcSB0,0)

Return

////////////////////////////////////
Static Function CustoMedio(cProduto)
  Local cQry :=""
  Local cFil := Substr(xFilial("SB2"),1,2)
  Local nCM1 := 0

  cQry += "SELECT SUM(B2_QATU)B2_QATU,SUM(B2_VATU1)B2_VATU1 "
  cQry += "FROM "+RetSQLName("SB2")+" SB2 "
  cQry += "WHERE D_E_L_E_T_ <> '*' "
  cQry += "AND SUBSTRING(B2_FILIAL,1,2) = '"+cFil+"' " 
  cQry += "AND B2_COD = '"+cProduto+"' " 

  dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry)), "XXX", .T., .F. )    

  If !XXX->(Eof())
     nCM1 := XXX->B2_VATU1 / XXX->B2_QATU
  Endif
  XXX->(dbCloseArea())
Return nCM1
