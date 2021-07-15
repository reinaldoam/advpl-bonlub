#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CadModVeic
Cadastro de Marca e Modelo de veiculos
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

User Function CadModVeic()

Local cAlias := "ZZ1"

Private cCadastro := "Cadastro de marca e modelo"

Private aRotina   := {}
AADD(aRotina, { "Pesquisar"  , "AxPesqui", 0, 1 })
AADD(aRotina, { "Visualizar" , "AxVisual", 0, 2 })
AADD(aRotina, { "Incluir"    , "AxInclui", 0, 3 })
AADD(aRotina, { "Alterar"    , "AxAltera", 0, 4 })
AADD(aRotina, { "Excluir"    , "AxDeleta", 0, 5 })

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse( 6,1,22,75,cAlias,,,,,,,,,,,,,,,)

Return


