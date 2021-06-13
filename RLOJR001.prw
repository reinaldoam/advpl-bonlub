#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RLOJR001 º Autor ³ TOTVS              º Data ³  03/06/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ IMPRESSAO DA GUIA DE SEPARACAO.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RLOJR001(_cNORC, _lRIMP, lLoja)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Ordem de Separacao"
	Local cPict          := ""
	Local titulo       := "Ordem de Separacao"
	Local nLin         := 80

	Local Cabec1       := ""
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 130
	Private tamanho          := "M"
	Private nomeprog         := "RLOJR001" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       := "RLOJ001"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "RLOJR001" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SL1"
	Private _cnumorc := _cnorc
	Private _lreimp := iif(_lrimp == nil, .f., _lrimp)
	Private _cporta := subs(alltrim(getnewpar("MV_PORTGUI","")),1,4)

	Private _lporta := .f.
	Private _cCliPad:= GETMV("MV_CLIPAD")
	Private _lLoja	:= lLoja

	sb1->(dbsetorder(1))
	sA1->(dbsetorder(1))
	sA3->(dbsetorder(1))
	sB2->(dbsetorder(1))
	
	dbSelectArea("SL1")
	dbSetOrder(1)
	Dbseek(xFilial("SL1")+_CnORC)

	IF !EMPTY(_CPORTA) .AND. ALLTRIM(_CPORTA) <> 'DISC'
		if msgyesno("Imprime guia?")
			_lporta := .T.
		else
			return
		endif

	ENDIF

	IF _lporta

		// Impressao direta
		//Set( 24, "LPT1", .F. ) // Set Printer To Lpt1 e a mesma coisa
		SetPrint("SL1",'','','',,,,.F.,,.T.,,,,,'EPSON.DRV',.T.,,_CPORTA)
//	Set Printer To _CPORTA
		PrinterWin(.F.) // Impressao Dos/Windows
		setpgeject(.F.)
		PreparePrint(.F., "", .F., _CPORTA) // Prepara a impressao na porta especificada
		setpgeject(.F.)
		if InitPrint(1) <= 0 // Inicia Cliente/Servidor
			msgstop("Porta "+_CPORTA+" invalida para impressao! Verifique a configuracao da impressora ou o parametro MV_PORTGUI.")
			return(.f.)
		endif
		setpgeject(.F.)
	ELSE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a interface padrao com o usuario...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		wnrel := SetPrint(cString,NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)


		If nLastKey == 27
			Return
		Endif

		SetDefault(aReturn,cString)

		If nLastKey == 27
			Return
		Endif
	ENDIF

//nTipo := If(aReturn[4]==1,15,18)
	nTipo := 18

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  18/10/05   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
	±±º          ³ monta a janela com a regua de processamento.               º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Programa principal                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Local nLin       := 61
	Local aCondicoes := {}
	Local aFormaPgto := {}
	local _nqit := iif(_lreimp, 4, 6)
	local _nit := 0
	local _nItem:=0
	local _nPeso:=0
	LOCAL _cSC0NUM:=""
	Local _LCAB2 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Array com tipo de Forma de Pagamento						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lCabec := .T.


	IF _CNUMORC <> NIL
//	DBSELECTAREA("SL1")
//	SL1->(dbGoTop())
//	SL1->(DBSETORDER(1))
		_cRegra:=""
		if _lLoja
			_cRegra:= ALLTRIM(_CNUMORC) <> ALLTRIM(M->LQ_NUM)
		Else
			_cRegra:= !SL1->(DBSEEK(XFILIAL("SL1")+PADR(ALLTRIM(_CNUMORC),TAMSX3("L1_NUM")[1],"")))
		EndIf

		IF _cRegra //!SL1->(DBSEEK(XFILIAL("SL1")+PADR(ALLTRIM(_CNUMORC),TAMSX3("L1_NUM")[1],"")))
			msgstop("Orcamento nao encontrado!")
			MS_FLUSH()
			RETURN //(.F.)
		ENDIF
	ENDIF

//_QRYSD3(SL1->L1_NUM)//Busca os dados gerados no sd3 referente aos produtos,
//Buscar tambem os dados do servico realizado no orcamento.
	If _lLoja
		_QRYSL2(M->LQ_NUM)
	Else
		_QRYSL2(SL1->L1_NUM)
	EndIf
//_QRYSL2(_CNUMORC)

	DbSelectArea("TRBSL2")
	DbGoTop()

	_LCAB2 := .T.

	While !TRBSL2->(Eof())

		If nLin > 60
			lCabec := .T.
			NLIN := 1
		EndIf

		If lCabec
			If _lLoja //pelo loja 701
				SA1->(DBSEEK(XFILIAL("SA1")+M->(LQ_CLIENTE+LQ_LOJA)))
				SA3->(DBSEEK(XFILIAL("SA1")+M->LQ_VEND))
				SetPgEject(.F.)
				@ PROW(),00 PSAY chr(18)
				@ nLin, 000 PSAY Chr(27)+Chr(48)	//Configura a impressora para 1/8
				@ nLin, 000 PSAY Chr(15)			// Compressao de Impressao
				@ PROW()+1,000 PSAY PADC("M A P A   D E   E X P E D I C A O   D E   M E R C A D O R I A S", LIMITE)
				NLIN++
				@ PROW()+1,000 PSAY REPLICATE("-",LIMITE)
				NLIN++
				@ PROW()+1,000 PSAY "Num.Ordem..: "+M->lQ_num
				@ PROW(),0110 PSAY "Data.: "+dToC(dDataBase)  //dtoc(SL1->L1_EMISSAO)
				NLIN++
				@ PROW()+1,000 PSAY "Vendedor: "+M->LQ_VEND+" - "+subs(SA3->A3_NOME,1,20)
				@ PROW(),110 PSAY "Hora.: "+Time() //sl1->l1_hora
				NLIN++
				@ PROW()+1,000 PSAY "Cliente: "+TRANSFORM(SA1->A1_CGC, IIF(SA1->A1_PESSOA=='J',"@R 99.999.999/9999-99","@R 999.999.999-99"))+" - "+subs(SA1->A1_NOME,1,20)
				@ PROW(),110 PSAY "Usuario: "+UsrRetName()
				NLIN++
				@ PROW()+1,000 PSAY "Cidade: "+ALLTRIM(SA1->A1_MUN)
				NLIN++
				lCabec := .F.
			Else
				SA1->(DBSEEK(XFILIAL("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
				SA3->(DBSEEK(XFILIAL("SA1")+SL1->L1_VEND))
				SetPgEject(.F.)
				@ PROW(),00 PSAY chr(18)
				@ nLin, 000 PSAY Chr(27)+Chr(48)	//Configura a impressora para 1/8
				@ nLin, 000 PSAY Chr(15)			// Compressao de Impressao

				@ PROW()+1,000 PSAY PADC("M A P A   D E   E X P E D I C A O   D E   M E R C A D O R I A S", LIMITE)
				NLIN++
				@ PROW()+1,000 PSAY REPLICATE("-",LIMITE)
				NLIN++
				@ PROW()+1,000 PSAY "Num.Ordem..: "+SL1->L1_NUM
				@ PROW(),0110 PSAY "Data.: "+dToC(dDataBase)  //dtoc(SL1->L1_EMISSAO)
				NLIN++
				@ PROW()+1,000 PSAY "Vendedor: "+SL1->L1_VEND+" - "+subs(SA3->A3_NOME,1,20)
				@ PROW(),110 PSAY "Hora.: "+Time() //sl1->l1_hora
				NLIN++
				@ PROW()+1,000 PSAY "Cliente: "+TRANSFORM(SA1->A1_CGC, IIF(SA1->A1_PESSOA=='J',"@R 99.999.999/9999-99","@R 999.999.999-99"))+" - "+subs(SA1->A1_NOME,1,20)
				@ PROW(),110 PSAY "Usuario: "+UsrRetName()
				NLIN++
				@ PROW()+1,000 PSAY "Cidade: "+ALLTRIM(SA1->A1_MUN)
				NLIN++
				@ PROW()+1,00 PSAY "Veiculo: "+subs(posicione("DA3",3,XFILIAL("DA3")+SL1->L1_VEICUL1,"DA3_PLACA"),1,35)
				//@ PROW(),45 PSAY "Km: "+alltrim(str(SL1->L1_kmatual,9))+"    Placa: "+SL1->L1_PLACAcl
				NLIN++
				@ PROW()+1,00 PSAY "OBS: "+subs(SL1->L1_XMENNOT,1,100)
				lCabec := .F.
			EndIf
		EndIf

		IF _LCAB2
			NLIN++
			@ PROW()+1,00 PSAY REPLICATE("-",LIMITE)
			NLIN++
			_nit++
			//		@ NLIN,00 PSAY " Codigo          Descricao                                Loc   Qtd  UM  Conf"
			@ PROW()+1,00 PSAY "Codigo        Descricao                                 Un      Estoque  Peso Unit.  Peso Tot.  Qt.Atendida"
			//	   1     |     2   |    3    |    4    |    5    |    6    |    7    |    8    |    9    |   10    |    11   |   12    |    13   |    14   |
			//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
			NLIN++
			_nit++
			@ PROW()+1,00 PSAY REPLICATE("-",LIMITE)
			NLIN++
			_nit++

			_LCAB2 := .F.
			NLIN++
			_nit++
		ENDIF

		//Impressao dos produtos (Tes Movimenta Estoque=Sim)
		If TRBSL2->(!Eof())
			@ PROW()+1,000 PSAY SUBStr(ALLTRIM(TRBSL2->L2_PRODUTO),1,8)			// Produto
			SB1->(DBSEEK(XFILIAL("SB1")+TRBSL2->L2_PRODUTO))	   				// Posiciona Cadastro Produto
			@ PROW(),014 PSAY PADR(Substr(ALLTRIM(SB1->B1_DESC),1,40),40,"")	// Descricao produto
			@ PROW(),056 PSAY SB1->B1_UM										// Unidade Medida
			SB2->(DBSEEK(XFILIAL("SB2")+TRBSL2->L2_PRODUTO))	   				// Posiciona saldo dos produtos
			@ PROW(),061 PSAY SB2->B2_QATU	Picture "@E 999,999.99"				// Saldo produto
			@ PROW(),075 PSAY SB1->B1_PESO	Picture "@E 999.999" 				// Peso
			@ PROW(),085 PSAY (SB1->B1_PESO*TRBSL2->L2_QUANT) Picture "@E 999.999" 	// Peso Total
			@ PROW(),095 PSAY TRBSL2->L2_QUANT	Picture "@E 999,999.9999" 		// Quantidade do item

			nLin:=nLin+1
			_nit++
			_nItem++
			_nPeso+=SB1->B1_PESO*TRBSL2->L2_QUANT
		Endif

		//Impressao dos itens servicos(TES Movimenta Estoque =Nao)
		DbSelectArea("TRBSL2")
		TRBSL2->(dbSkip())
	EndDo

	if _nqit-_nit > 0
		for _ni := 1 to (_nqit-_nit)
			@ PROW()+1,limite PSAY " "
			nlin++
		next
	endif

	If !lCabec
		@ PROW()+1,00 PSAY replicate("-", limite)
		nlin++
		@ PROW()+1,limite PSAY " "
	EndIf


	@ PROW()+1,000 PSAY "Nr. Itens ..: "
	@ PROW(),015 PSAY STRZERO(_nItem,3)
	@ PROW(),020 PSAY "Peso do Pedido: "
	@ PROW(),036 PSAY _nPeso Picture "@E 999,999.999"
	NLIN++
	_cOPFRET:=""
	NLIN++
	_nit++
	@ PROW()+1,00 PSAY REPLICATE("-",LIMITE)
	NLIN++
	_nit++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	IF SELECT("TRBSL2") > 0
		TRBSL2->(DBCLOSEAREA())
	ENDIF

	SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


// caso seja impressao em disco
	IF !_lporta
		If aReturn[5]==1
			dbCommitAll()
			SET PRINTER TO
			OurSpool(wnrel)
		Endif
	ELSE
		@PROW()+20,000 *1.06 PSAY "."
		SetPrc(0,0)
		dbCommitAll()

	ENDIF

	MS_FLUSH()

Return

// GERA TRB COM AS MOVIMENTACOES DO ORCAMENTO
Static Function _QRYSL2(_cNumOrc)

	Local _cQry


	_cQry := " SELECT * FROM " + RetSqlName("SL2") +" L2, "+RetSqlName("SF4") +" F4 "
	_cQry += " WHERE L2.D_E_L_E_T_ <> '*' AND F4.D_E_L_E_T_ <> '*'"
	_cQry += " AND L2_TES = F4_CODIGO "
	_cQry += " AND L2_FILIAL= '" +xFilial("SL2") + "'
	_cQry += " AND F4_FILIAL= '" +xFilial("SF4") + "'
	_cQry += " AND F4_ESTOQUE='S' "
	_cQry += " AND L2_NUM='" + _cNumOrc +"'"
	_cQry += " ORDER BY L2_ITEM "

/* /
_cQry := " SELECT L2.* , BZ.BZ_XRUA, BZ.BZ_XLOTE "
_cQry += " FROM "+RetSqlName("SF4") +" F4, " + RetSqlName("SL2") +" L2 left join "+RetSqlName("SBZ") +" BZ "
_cQry += "         ON L2_PRODUTO = BZ_COD   "
_cQry += "         AND L2.D_E_L_E_T_ = BZ.D_E_L_E_T_ "
_cQry += "         AND L2.L2_FILIAL = BZ.BZ_FILIAL "
_cQry += " WHERE   L2.D_E_L_E_T_ <> '*' AND F4.D_E_L_E_T_ <> '*' "
_cQry += "         AND L2_TES = F4_CODIGO  "
_cQry += "         AND L2_FILIAL= '" +xFilial("SL2") + "' AND F4_ESTOQUE='S' AND L2_NUM = '" + _cNumOrc +"' "
_cQry += " ORDER BY BZ.BZ_XRUA, BZ.BZ_XLOTE "
/ */
MemoWrit("c:\temp\guia.txt",_cQry)
TCQUERY _cQry NEW ALIAS "TRBSL2"

Return

