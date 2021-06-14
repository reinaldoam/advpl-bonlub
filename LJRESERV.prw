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
  Local cOperacao  := PARAMIXB[1] //- Tipo de Operacao em execucao
  Local aLojas     := PARAMIXB[2] //- Lojas disponiveis para efetuar a Reserva
  Local aProdutos  := PARAMIXB[3] //- Produtos da venda que a serem reservados
  Local aEstoque   := PARAMIXB[4] //- Saldos dos Estoques nas lojas/armazem
  Local aEstoqBKP  := aClone(aEstoque)
  Local aLojasClone:= aClone(aLojas)
  Local cLocPad    := GetMv("MV_LOCPAD")
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
  Local cDescric := ""
  Local nQtde    := 0
  Local nSaldo   := 0
  Local aSaldoSB2 := {}
  Local lTemEstoque := .T.
  Local aPrdSemEst := {} //- Produtos sem estoque
  Local cMsg := ""
  Local nPosLoj:=0
  Local cCodFil := Padr(SM0->M0_CODFIL,6) //- Foi usado no código da loja na SLJ o mesmo código da filial do SIGAMAT

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
  nPosLoj := aScan(aLojasClone,{|x| x[2] == cCodFil }) //- Localiza a loja corrente no array aLojas 

  Do Case
     Case cOperacao == "1"
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     //³ Operacao 1: Selecao das "LOJAS" onde serao reservados os produtos e selecao dos "PRODUTOS" que serao reservados ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        //-------------------------------------------
        // Escolha da LOJA onde sera feita a reserva
        //-------------------------------------------
        aLojas[1][1] := .T. //- Neste exemplo, sempre considera a escolha (selecao) da primeira loja
        aLojas[1][2] := aLojasClone[nPosLoj][2] //- Cõdigo da loja
        aLojas[1][3] := aLojasClone[nPosLoj][3] //- Nome da loja

        alert(aLojas[1][1])
        alert('2->'+aLojas[1][2])
        alert('3->'+aLojas[1][3])

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

           alert(aProdutos[nX][1])
           alert('2->'+aProdutos[nX][2])
           alert('3->'+aProdutos[nX][3])
           alert('4->'+aProdutos[nX][4])
           alert('5->'+str(aProdutos[nX][5]))

        Next nX
        lConfirma := .T. //- Confirma as informacoes selecionadas.
     Case cOperacao == "2"
   	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     //³ Operacao 2: Selecao do "ARMAZEM" (Local de Estoque) relacionado a loja onde serao reservados os produtos ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        aEstoque := {} //Limpa o array aEstoque
   	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     //³ Preenchendo array aEstoque ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        For nY:= 1 To Len(aProdutos)
           cItem     := aProdutos[nY][2] //- Item da venda
           cProduto  := aProdutos[nY][3] //- Codigo do Produto
           nQtde     := aProdutos[nY][5] //- Quantidade
           
           lTemEstoque := .F.
           
           //- Gravando saldo em estoque no sub-array 
           SB2->(DbSetOrder(1))
           SB2->(DbSeek(xFilial("SB2")+cProduto+cLocPad))
           
           nSaldo := SB2->B2_QATU - SB2->B2_RESERVA
           
           aSaldoSB2 := {}
           Aadd(aSaldoSB2,{SB2->B2_LOCAL, nSaldo})

  			  aAdd( aEstoque, { .F., ;
                             aLojasClone[nPosLoj][2],; 
                             Trim(aLojasClone[nPosLoj][3]),;
                             cProduto,; 
                             aSaldoSB2,;                              
                             nQtde,;
                             Trim(aLojasClone[nPosLoj][3]),; 
                             cItem,; 
                             cLocPad }) 
           nPos := Len(aEstoque)
       
           //- Verifica se tem saldo o suficieente para o produto
           If aEstoque[nPos][5][1][2] >= nQtde
              aEstoque[nPos][5][1][2] -= nQtde
              aEstoque[nY][1] := .T. // Seleciona item
              lTemEstoque := .T.
           Endif
           
           alert(aEstoque[nY][1])
           alert('2->'+aEstoque[nY][2])
           alert('3->'+aEstoque[nY][3])
           alert('4->'+aEstoque[nY][4])
           alert('5.1->'+aEstoque[nY][5][1][1])
           alert('5.2->'+str(aEstoque[nY][5][1][2]))
           alert('6->'+str(aEstoque[nY][6]))
           alert('7->'+aEstoque[nY][7])
           alert('8->'+aEstoque[nY][8])
           alert('9->'+aEstoque[nY][9])
           
           If !lTemEstoque
              aAdd( aPrdSemEst, AllTrim(cProduto) + " - " + AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")) )
           EndIf
        Next
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
