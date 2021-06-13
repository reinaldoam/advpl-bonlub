#Include 'Protheus.ch'

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
//Ponto de Entrada utilizado para realizar a Reserva dos produtos da venda sem a exibicao da interface para o usuario.
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
//Este Ponto de Entrada é executado em dois momentos.
// 1o. momento (opercao= "1"): Neste momento deve ser feita a selecao das "LOJAS" onde serao reservados os produtos e a selecao dos "PRODUTOS" que serao reservados
// 2o. momento (opercao= "2"): Neste momento deve ser feita a selecao do "ARMAZEM" (Local de Estoque) relacionado a loja onde serao reservados os produtos
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function LJRESERV()
  Local aRet := {} //Retorno da funcao
  Local cOperacao := PARAMIXB[1] //- Tipo de Operacao em execucao
  Local aLojas    := PARAMIXB[2] //- Lojas disponiveis para efetuar a Reserva
  Local aProdutos := PARAMIXB[3] //- Produtos da venda que a serem reservados
  Local aEstoque  := PARAMIXB[4] //- Saldos dos Estoques nas lojas/armazem
  Local aEstoqBKP := aClone(aEstoque)
  Local nX := 0
  Local nY := 0
  Local nZ := 0
  Local lConfirma := .F. //- Simula o botao "Confirmar" (.T.=Confirma; .F.=Cancela)
  Local nENTREGA := aScan( aHeader,{|x| Trim(x[2]) == "LR_ENTREGA" } ) //- Posicao do Campo "LR_ENTREGA"
  Local nITEM    := aScan( aHeader,{|x| Trim(x[2]) == "LR_ITEM" } )    //- Posicao do Campo "LR_ITEM"
  Local nPosAcols := 0
  Local lContinua := .F.
  Local cItem := ""
  Local cProduto := ""
  Local lTemEstoque := .T.
  Local aPrdSemEst := {} //- Produtos sem estoque
  Local cMsg := ""
  Local cCodFil := Substr(xFilial("SLJ"),1,2)
  Local cCodigo := Padl(xFilial("SLJ"),6)

  //---------------------------------------------------------------------------------------------
  // Estrutura do array aLojas
  //---------------------------------------------------------------------------------------------
  // Neste array esta a relacao de Lojas (SLJ) disponiveis para realizar reserva de produto
  // Devem ser selecionadas apenas as lojas na qual deseja fazer a reserva.
  //---------------------------------------------------------------------------------------------
  //[1] - .T. ou .F. (para selecao)
  //[2] - Codigo da loja (LJ_CODIGO)
  //[3] - Nome da loja (LJ_NOME)
  //---------------------------------------------------------------------------------------------

  //---------------------------------------------------------------------------------------------
  // Estrutura do array aProdutos
  //---------------------------------------------------------------------------------------------
  // Neste array estao os produtos da venda.
  // Devem ser selecionados apenas o produtos que desejar fazer a reserva.
  //---------------------------------------------------------------------------------------------
  //[1] - .T. ou .F. (para selecao)
  //[2] - Item do produto na aCols
  //[3] - Codigo do Produto
  //[4] - Descricao
  //[5] - Quantidade
  //---------------------------------------------------------------------------------------------
  
  //---------------------------------------------------------------------------------------------
  // Estrutura do array aEstoque
  //---------------------------------------------------------------------------------------------
  // Neste array estao as informacoes relacionadas ao saldo em estoque dos produtos selecionados.
  // Devem ser selecionados em qual Loja/Armazem deseja fazer a reserva do produto.
  //---------------------------------------------------------------------------------------------
  //[1] - .T. ou .F. (para selecao)
  //[2] - Codigo da Loja (SLJ->LJ_CODIGO)
  //[3] - Nome da Loja (SLJ->LJ_NOME)
  //[4] - Codigo do Produto
  //[5] - Array com a qtd em Estoque:
  // [1]-Local (Armazem)
  // [2]-Qtde Estoque (SB2)
  //[6] - Quantidade a Reservar
  //[7] - Texto para ser mostrado no ListBox da tela, quando utilizada a interface
  //[8] - Numero do item no aCols
  //[9] - Armazem
  //---------------------------------------------------------------------------------------------
  SCJ->(DbSetOrder(1))
  SCJ->(DbSeek(xFilial('SCJ')+cCodFil))

  alert('1->'+cCodFil)
  alert('2->'+cCodigo)
  
  alert('3->'+cCodFil)
  alert('4->'+SLJ->LJ_NOME)
  alert('5->'+SLJ->LJ_CODIGO)
  alert('6->'+cOperacao)

  Do Case
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Operacao 1: Selecao das "LOJAS" onde serao reservados os produtos e selecao dos "PRODUTOS" que serao reservados ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Case cOperacao == "1"
        //-------------------------------------------
        // Escolha da LOJA onde sera feita a reserva
        //-------------------------------------------
        alert(aLojas[1][1])
        alert(aLojas[1][2])
        alert(aLojas[1][3])

        aLojas[1][1] := .T. //- Neste exemplo, sempre considera a escolha (selecao) da primeira loja
        //-------------------------------------------
        // Escolha dos PRODUTOS que serao reservados
        //-------------------------------------------
        For nX:=1 To Len(aProdutos)
           //- Localiza o item no aCols
           nPosAcols := aScan( aCols, { |x| x[nITEM] == aProdutos[nX][2] } )
           //- Selecionando apenas os produtos, cujo a opcao do campo "LR_ENTREGA" seja "3-Entrega"
           If !Empty(aCols[nPosAcols][nENTREGA]) .And. aCols[nPosAcols][nENTREGA] == "1" //antes era 3=Entrega
              aProdutos[nX][1] := .T.
           EndIf
        Next nX
        lConfirma := .T. //Confirma as informacoes selecionadas.
   	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     //³ Operacao 2: Selecao do "ARMAZEM" (Local de Estoque) relacionado a loja onde serao reservados os produtos ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Case cOperacao == "2"
        //- Efetua a reserva dos produtos
        For nX:=1 To Len(aProdutos)
           cItem := aProdutos[nX][2] //Item da venda
           cProduto := aProdutos[nX][3] //Codigo do Produto
           //- Faz a Reserva no primeiro Local de Estoque (Armazem) encontrado para a loja escolhida que possua saldo
           For nY := 1 To Len(aEstoque)
              If aEstoque[nY][8] == cItem .And. aEstoque[nY][4] == cProduto
                 lTemEstoque := .F.
                 For nZ:=1 To Len(aEstoque[nY][5])
                    //- Verifica se tem a quantidade o suficiente em estoque para reservar
                    If aEstoque[nY][5][nZ][2] >= aEstoque[nY][6] .And. aEstoque[nY][5][nZ][1] == aEstoque[nY][9]
                       aEstoque[nY][5][nZ][2] -= aEstoque[nY][6] //- Subtrai a qtde
                       lTemEstoque := .T.
                       Exit
                    EndIf
                 Next nZ
                 If lTemEstoque
                    aEstoque[nY][1] := .T. //Seleciona
                    Exit
                 EndIf
              EndIf
           Next nY
           If !lTemEstoque
              aAdd( aPrdSemEst, AllTrim(cProduto) + " - " + AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")) )
           EndIf
        Next nX
        lConfirma := .T.
        //- Se nao tem estoque suficiente para reservar todos os produtos, entao aborta todas as reservas
        If Len(aPrdSemEst) > 0
           cMsg := "Não existe estoque suficiente para o(s) seguinte(s) produto(s):" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
           For nX:=1 To Len(aPrdSemEst)
               cMsg += aPrdSemEst[nX] + Chr(13) + Chr(10)
           Next nX
           Alert(cMsg)
           aEstoque := aEstoqBKP //Devolve o array sem alteracoes
           lConfirma := .F. //Cancela
        EndIf
  EndCase
  aRet := { lConfirma, aLojas, aProdutos, aEstoque }
Return aRet
