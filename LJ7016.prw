#include "Protheus.ch"
#include "Rwmake.ch"

User Function LJ7016

/*
Ponto de entrada para adicionar rotinas ao Toolbar da venda assistida.

Array bidimensional contendo:

[1] - Titulo para o menu
[2] - Titulo para botao (tip)
[3] - Resource
[4] - Funcao a ser executada
[5] - Aparece na toolbar lateral ? (TRUE / FALSE)
[6] - Habilitada ? (TRUE / FALSE)
[7] - Grupo (1- Gravacao, 2- Detalhes, 3- Estoque, 4- Outros)
[8] - Tecla de atalho
*/

Local aRet  := {}

aFuncoes[11][6] := .F.
aAdd( aRet, {'Pesquisa', 'Produto', 'SOLICITA', {|| U_LJCtrlj()}, .T., .T., 4, {10 ,'Ctrl+J'}  } )

Return aRet
