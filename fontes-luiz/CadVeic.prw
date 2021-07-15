#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Vari�veis Est�ticas
Static cTitulo := "Cadastro de Veiculos x servicos"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CadVeic
Rotina desenvolvida para cadastro de ve�culos e servi�os (service car)
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------
 
User Function CadVeic()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de veiculos
    oBrowse:SetAlias("Z01")
 
    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cria��o do MenuDef
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.CadVeic' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.CadVeic' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.CadVeic' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.CadVeic' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Imprimir'   ACTION 'u_fImprimi' OPERATION 2 ACCESS 0 //OPERATION 2

 
Return aRot
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria��o do modelo de dados ModelDef
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------
 
Static Function ModelDef()
    
Local oModel      := Nil
Local oStPai      := FWFormStruct(1, 'Z01')
Local oStFilho    := FWFormStruct(1, 'Z02')

Local aZ02Rel     := {}
Local aGatCli     := {}   
Local aGatPrd     := {}
Local aGatTot     := {}
Local aGatCPai    := {}
Local aGatMarca   := {}
Local aGatTec     := {}
Local aGatVend    := {}

Local nAtual

//=======================
//Montagem dos gatilhos
//=======================

//Adicionando gatilho para preenchimento do nome do cliente	
aAdd(aGatCli, FWStruTriggger( "Z01_CLIENT",;                               //Campo Origem
                                "Z01_NOME",;                                //Campo Destino
                                "StaticCall(CadVeic, fNameCli)",;           //Regra de Preenchimento
                                .F.,;                                       //Ir� Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //�ndice de Posicionamento
                                "",;                                        //Chave de Posicionamento
                                NIL,;                                       //Condi��o para execu��o do gatilho
                                "01");                                     //Sequ�ncia do gatilho
    )

//Adicionando gatilho para preenchimento da descri��o do produto
aAdd(aGatPrd, FWStruTriggger( "Z02_PROD",;                               //Campo Origem
                                "Z02_DESC",;                                //Campo Destino
                                "StaticCall(CadVeic, fDescPrd)",;           //Regra de Preenchimento
                                .F.,;                                       //Ir� Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //�ndice de Posicionamento
                                "",;                                        //Chave de Posicionamento
                                NIL,;                                       //Condi��o para execu��o do gatilho
                                "01");                                     //Sequ�ncia do gatilho
    )


//Adicionando gatilho para calcular total da linha
aAdd(aGatTot, FWStruTriggger( "Z02_VLUNIT",;                               //Campo Origem
                                "Z02_TOTAL",;                                //Campo Destino
                                "StaticCall(CadVeic, fCalcTot)",;           //Regra de Preenchimento
                                .F.,;                                       //Ir� Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //�ndice de Posicionamento
                                "",;                                        //Chave de Posicionamento
                                NIL,;                                       //Condi��o para execu��o do gatilho
                                "01");                                     //Sequ�ncia do gatilho
    )

//Adicionando gatilho para gravar o codigo pai na tabela filho
aAdd(aGatCPai, FWStruTriggger( "Z02_PROD",;                               //Campo Origem
                                "Z02_CODPAI",;                                //Campo Destino
                                "StaticCall(CadVeic, fCodPai)",;           //Regra de Preenchimento
                                .F.,;                                       //Ir� Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //�ndice de Posicionamento
                                "",;                                        //Chave de Posicionamento
                                NIL,;                                       //Condi��o para execu��o do gatilho
                                "02");                                     //Sequ�ncia do gatilho
    )

aAdd(aGatCli, FWStruTriggger( "Z01_VEIC",;                               //Campo Origem
                                "Z01_MARCAV",;                                //Campo Destino
                                "StaticCall(CadVeic, fMarcaVeic)",;           //Regra de Preenchimento
                                .F.,;                                       //Ir� Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //�ndice de Posicionamento
                                "",;                                        //Chave de Posicionamento
                                NIL,;                                       //Condi��o para execu��o do gatilho
                                "01");  
) 

aAdd(aGatCli, FWStruTriggger( "Z01_VEIC",;                               //Campo Origem
                                "Z01_DESCV",;                                //Campo Destino
                                "StaticCall(CadVeic, fModelVeic)",;           //Regra de Preenchimento
                                .F.,;                                       //Ir� Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //�ndice de Posicionamento
                                "",;                                        //Chave de Posicionamento
                                NIL,;                                       //Condi��o para execu��o do gatilho
                                "01");                                     //Sequ�ncia do gatilho
    )

aAdd(aGatTec, FWStruTriggger( "Z02_TECNIC",;                               //Campo Origem
                                "Z02_NTECNI",;                                //Campo Destino
                                "StaticCall(CadVeic, fNameSA3)",;           //Regra de Preenchimento
                                .F.,;                                       //Ir� Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //�ndice de Posicionamento
                                "",;                                        //Chave de Posicionamento
                                NIL,;                                       //Condi��o para execu��o do gatilho
                                "01");                                     //Sequ�ncia do gatilho
    )

aAdd(aGatVend, FWStruTriggger( "Z02_VEND",;                               //Campo Origem
                                "Z02_NVEND",;                                //Campo Destino
                                "StaticCall(CadVeic, fNameSA3)",;           //Regra de Preenchimento
                                .F.,;                                       //Ir� Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //�ndice de Posicionamento
                                "",;                                        //Chave de Posicionamento
                                NIL,;                                       //Condi��o para execu��o do gatilho
                                "01");                                     //Sequ�ncia do gatilho
    )
 
//Percorrendo os gatilhos e adicionando na Struct
For nAtual := 1 To Len(aGatCli)
    oStPai:AddTrigger(  aGatCli[nAtual][01],; //Campo Origem
                        aGatCli[nAtual][02],; //Campo Destino
                        aGatCli[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
                        aGatCli[nAtual][04])  //Bloco de c�digo de execu��o do gatilho
Next

For nAtual := 1 To Len(aGatPrd)
    oStFilho:AddTrigger(  aGatPrd[nAtual][01],; //Campo Origem
                          aGatPrd[nAtual][02],; //Campo Destino
                          aGatPrd[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
                          aGatPrd[nAtual][04])  //Bloco de c�digo de execu��o do gatilho
Next

For nAtual := 1 To Len(aGatTot)
    oStFilho:AddTrigger(  aGatTot[nAtual][01],; //Campo Origem
                          aGatTot[nAtual][02],; //Campo Destino
                          aGatTot[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
                          aGatTot[nAtual][04])  //Bloco de c�digo de execu��o do gatilho
Next

For nAtual := 1 To Len(aGatCPai)
    oStFilho:AddTrigger(  aGatCPai[nAtual][01],; //Campo Origem
                          aGatCPai[nAtual][02],; //Campo Destino
                          aGatCPai[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
                          aGatCPai[nAtual][04])  //Bloco de c�digo de execu��o do gatilho
Next

For nAtual := 1 To Len(aGatMarca)
    oStFilho:AddTrigger(  aGatMarca[nAtual][01],; //Campo Origem
                          aGatMarca[nAtual][02],; //Campo Destino
                          aGatMarca[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
                          aGatMarca[nAtual][04])  //Bloco de c�digo de execu��o do gatilho
Next

For nAtual := 1 To Len(aGatTec)
    oStFilho:AddTrigger(  aGatTec[nAtual][01],; //Campo Origem
                          aGatTec[nAtual][02],; //Campo Destino
                          aGatTec[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
                          aGatTec[nAtual][04])  //Bloco de c�digo de execu��o do gatilho
Next

For nAtual := 1 To Len(aGatVend)
    oStFilho:AddTrigger(  aGatVend[nAtual][01],; //Campo Origem
                          aGatVend[nAtual][02],; //Campo Destino
                          aGatVend[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
                          aGatVend[nAtual][04])  //Bloco de c�digo de execu��o do gatilho
Next

//=============================
//Fim da montagem dos gatilhos
//=============================


    //Defini��es dos campos
    oStPai:SetProperty('Z01_COD',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edi��o
    oStPai:SetProperty('Z01_NOME',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.T.'))                                 //Modo de Edi��o
    oStPai:SetProperty('Z01_COD',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("Z01", "Z01_COD")'))       //Ini Padr�o
    oStPai:SetProperty('Z01_CLIENT',   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCpo("SA1", M->Z01_CLIENT)'))      //Valida��o de Campo
    
    oStFilho:SetProperty('Z02_DESC',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.T.'))                                 //Modo de Edi��o
    oStFilho:SetProperty('Z02_ITEM', MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'u_zIniMus()'))                         //Ini Padr�o
    
    //oStFilho:SetProperty('ZZ3_CODCD',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edi��o
    //oStFilho:SetProperty('ZZ3_CODCD',  MODEL_FIELD_OBRIGAT, .F. )                                                                          //Campo Obrigat�rio
    //oStFilho:SetProperty('ZZ3_CODART', MODEL_FIELD_OBRIGAT, .F. )                                                                          //Campo Obrigat�rio
    
        
    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('CadVeicM')
    oModel:AddFields('Z01MASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('Z02DETAIL','Z01MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner � para quem pertence
     
    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aZ02Rel, {'Z02_FILIAL','FWxFilial("Z02")'} )
    aAdd(aZ02Rel, {'Z02_CODPAI', 'Z01_COD'})
     
    oModel:SetRelation('Z02DETAIL', aZ02Rel, Z02->(IndexKey(1))) //IndexKey -> quero a ordena��o e depois filtrado
    //oModel:GetModel('Z02DETAIL'):SetUniqueLine({"Z02_FILIAL","Z02_CODPAI"})    //N�o repetir informa��es ou combina��es {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})
     
    //Setando as descri��es
    oModel:SetDescription("Veiculos - Mod. 3")
    oModel:GetModel('Z01MASTER'):SetDescription('Cadastro')
    oModel:GetModel('Z02DETAIL'):SetDescription('Itens')
Return oModel
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria��o da vis�o ViewDef
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------
 
Static Function ViewDef()
    Local oView      := Nil
    Local oModel     := FWLoadModel('CadVeic')
    Local oStPai     := FWFormStruct(2, 'Z01')
    Local oStFilho   := FWFormStruct(2, 'Z02')
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabe�alho e o grid dos filhos
    oView:AddField('VIEW_Z01',oStPai,'Z01MASTER')
    oView:AddGrid('VIEW_Z02',oStFilho,'Z02DETAIL')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_Z01','CABEC')
    oView:SetOwnerView('VIEW_Z02','GRID')
     
    //Habilitando t�tulo
    oView:EnableTitleView('VIEW_Z01','Cabe�alho - Cadastro')
    oView:EnableTitleView('VIEW_Z02','Grid - Itens')
     
    //For�a o fechamento da janela na confirma��o
    //oView:SetCloseOnOk({||.T.})
     
    //Remove os campos de C�digo do Artista e CD
    //oStFilho:RemoveField('ZZ3_CODART')
    //oStFilho:RemoveField('ZZ3_CODCD')
Return oView
 
//-------------------------------------------------------------------
/*/{Protheus.doc} zIniMus
Valida��o da sequencia no campo Z02_ITEM
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------
 
User Function zIniMus()
    Local aArea := GetArea()
    Local cCod  := StrTran(Space(TamSX3('Z02_ITEM')[1]), ' ', '0')
    Local oModelPad  := FWModelActive()
    Local oModelGrid := oModelPad:GetModel('Z02DETAIL')
    Local nOperacao  := oModelPad:nOperation
    Local nLinAtu    := oModelGrid:nLine
    Local nPosCod    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("Z02_ITEM")})
     
    
        //se for primeira linha, sen�o pega a linha
        //atual do modelo de dados +1
        If nLinAtu < 1
            cCod := Soma1(cCod)
        Else
            cCod := Strzero(oModelGrid:GoLine(nLinAtu)+1,4)
        EndIf   
     
    RestArea(aArea)
Return cCod


//-------------------------------------------------------------------
/*/{Protheus.doc} fNameCli
Fun��o para retornar o nome do cliente no gatilho
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------
 
Static Function fNameCli()

Local cRetorno := ""
Local cCliente := FWFldGet("Z01_CLIENT")
	
	
dbselectarea("SA1")
dbSetOrder(1)
If dbseek(xFilial("SA1")+cCliente)
	cRetorno := Alltrim(SA1->A1_NOME)
EndIf 

Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} fDescPrd
Fun��o para retornar a descri��o do produto no gatilho
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

Static function fDescPrd()

Local cRetorno := ""
Local cProduto := FWFldGet("Z02_PROD")

dbselectarea("SB1")
dbSetOrder(1)
If dbseek(xFilial("SB1")+cProduto)
	cRetorno := Alltrim(SB1->B1_DESC)
EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} fCalcTot
Fun��o para calcular o total por linha Z02_TOTAL
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

Static function fCalcTot()

Local nTotal := 0
Local nQuant := FWFldGet("Z02_QUANT")
Local nVlUnit := FWFldGet("Z02_VLUNIT")

nTotal := nQuant*nVlUnit

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} fCodPai
Fun��o para gravar o codigo pai na tabela filha
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

Static function fCodPai()

Local cRetorno := FWFldGet("Z01_COD")

Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} fMarcaVeic
Fun��o para retornar o modelo do veiculo, gatilho ZZ1
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

Static function fMarcaVeic()

Local cRetorno := Alltrim(ZZ1_MARCA)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} fModelVeic
Fun��o para retornar o modelo do veiculo, gatilho ZZ1
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

Static function fModelVeic()

Local cRetorno := Alltrim(ZZ1_MODELO)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} fNameSA3
Fun��o para retornar nome da SA3 (A3_NOME)
@param      Nenhum
@return Nenhum
@author     Luiz Paulo Rodrigues / WS
@version    12.1.17 / Superior
@since      / /
/*/
//-------------------------------------------------------------------

Static function fNameSA3()

Local cRetorno := Alltrim(A3_NOME)

Return cRetorno

