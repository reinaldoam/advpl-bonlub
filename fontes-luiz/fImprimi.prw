#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "rwmake.ch"

/*
+-----------+------------+----------------+--------------------+-------+---------------+
| Programa  | fImprimi 	 | Desenvolvedor  |Luiz Paulo Rodrigues| Data  | 			   |
+-----------+------------+----------------+--------------------+-------+---------------+
| Descricao | Relatório de veiculos x serviços realizados	 					   	   |
|           | 						   												   |
+-----------+--------------------------------------------------------------------------+
| Modulo    | SIGALOJA			                                                       |
+-----------+--------------------------------------------------------------------------+
*/

User Function fImprimi()

Local cPerg := "Z01IMP"

Private cErro

If !Pergunte(cPerg, .T.)
	Return(NIL)
EndIf

Private lGrafico	:= .t.
Private nRetorn

Private aItens := {}


cTitulo   := "Relatório de veiculo x serviços"
cDesc1    := "Emite " + cTitulo
cDesc2    := ""
cDesc3    := ""
aReturn   := {"Rotina",1,"Servicos",2,2,1,"",1}
nLastKey  := 0
lContinua := .T.
nL		  := 0


// Salva a Integridade dos dados de Saida
wnrel    := "fImprimi"
cString  := "Z01"

// Envia controle para a funcao SETPRINT
if !lGrafico
	wnrel := SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.T.)
	
	If nLastKey == 27
		Set Device to Screen
		Return
	Endif
	
	SetDefault(aReturn,cString)
Endif

RptStatus({|| cImp()},cTitulo)

Return

/*
+-----------+------------+----------------+--------------------+-------+---------------+
| Programa  | CIMP	 	 | Desenvolvedor  |Luiz Paulo Rodrigues| Data  | 			   |
+-----------+------------+----------------+--------------------+-------+---------------+
| Descricao | Gera a impressão do relatório									   		   |
+-----------+--------------------------------------------------------------------------+
| Modulo    | SIGAEST			                                                       |
+-----------+--------------------------------------------------------------------------+
*/

Static Function cImp()

Local cSql	  := ""
Local nVlTot  := 0

if lGrafico
	niCol := 100 	// incremento de coluna para ajuste
Else
	niCol := 0
Endif
if lGrafico
	nLimiteLin := 2949 // limite maximo da linha de detalhe
Else
	nLimiteLin := 39   // limite maximo da linha de detalhe
Endif

nILin := 0 			// incremento de linha para ajuste
nLimIteCol := 145   // qtde maxima de colunas na impressao do item

// Definicao de fontes
oFont1	 	 := TFont():New("Arial"      	    ,09,08,,.F.,,,,,.F.)
oFont2 		 := TFont():New("Arial"      	    ,09,10,,.F.,,,,,.F.)
oFont3Bold	 := TFont():New("Arial Black"	    ,10,14,,.T.,,,,,.F.)
oFont4 	 	 := TFont():New("Arial Black"	    ,09,08,,.T.,,,,,.F.)
oFont5 	 	 := TFont():New("Arial"      	    ,09,18,,.T.,,,,,.F.)
oFont6 	 	 := TFont():New("Arial"      	    ,09,14,,.T.,,,,,.F.)
oFont7 	 	 := TFont():New("Arial"        		,09,10,,.T.,,,,,.F.)
oFont8 	 	 := TFont():New("Arial"          	,09,09,,.F.,,,,,.F.)
oFont9 	 	 := TFont():New("Times New Roman"	,09,14,,.T.,,,,,.F.)
oFont10	  	 := TFont():New("Times New Roman"	,09,13,,.T.,,,,,.F.)
oFont11	 	 := TFont():New("Arial"	    		,09,08,,.T.,,,,,.F.)
oFont12  	 := TFont():New("Arial Black"	    ,09,10,,.T.,,,,,.F.)

//Cria o objeto do relatorio
oPrn:=TMSPrinter():New()

//Start nova pagina
oprn:startpage()

// Imprime Cabecalho
nL := ImpCabec()

//imprimi titulo do relatorio
nL+=290
oPrn:Say(nILin+nL,niCol+0800,"Relatório de veiculo x serviços ",oFont3Bold,100)

If (Select("REC"))
    dbSelectArea("REC")
    REC->(dbCloseArea ())
Endif

cSql := " SELECT * "
cSql += " FROM " +RetSQLName("Z01")+ " Z01 " 
cSql += " LEFT JOIN " +RetSQLName("Z02")+ " Z02 ON Z02_CODPAI=Z01_COD AND Z02.D_E_L_E_T_ = ' ' " 
cSql += " INNER JOIN " +RetSQLName("SA3")+ " SA3 ON A3_COD=Z02_VEND AND SA3.D_E_L_E_T_ = ' ' " 
cSql += " WHERE Z01.D_E_L_E_T_ = ' ' "
cSql += " AND Z01_CLIENT = '"+mv_par01+"' "
cSql += " AND Z02_DATA BETWEEN '" +dtos(mv_par02)+ "' AND '"+dtos(mv_par03)+ "' "

TCQUERY cSql NEW ALIAS "REC"
dbSelectArea("REC")
DbGoTop()

//Impressão dos dados do cliente
nL+=100
oPrn:Say(nILin+nL,niCol+0010,"Cliente: " +REC->Z01_CLIENT+ "-" +Alltrim(REC->Z01_NOME),oFont12,100)
nL+=100
oPrn:Say(nILin+nL,niCol+0010,"Veiculo: " +Alltrim(REC->Z01_DESCV)+" Marca: " +Alltrim(REC->Z01_MARCAV),oFont12,100)
nL+=100
oPrn:Say(nILin+nL,niCol+0010,"Placa: " +Alltrim(REC->Z01_PLACA),oFont12,100)
nL+=100
oPrn:Say(nILin+nL,niCol+0010,"Vendedor: " +Alltrim(REC->A3_NOME),oFont12,100)
nL+=60
oPrn:Say(nILin+nL,niCol+0010,Replicate("_",150),oFont12,100)

nL+=100
oPrn:Say(nILin+nL,niCol+0010,"Item "        ,oFont11,100)
oPrn:Say(nILin+nL,niCol+0080,"Produto "     ,oFont11,100)
oPrn:Say(nILin+nL,niCol+0250,"Descricao "   ,oFont11,100)
oPrn:Say(nILin+nL,niCol+0600,"Quantidade "  ,oFont11,100)
oPrn:Say(nILin+nL,niCol+0800,"Valor Unit. " ,oFont11,100)
oPrn:Say(nILin+nL,niCol+1000,"Total "       ,oFont11,100)
oPrn:Say(nILin+nL,niCol+1200,"Data "        ,oFont11,100)
oPrn:Say(nILin+nL,niCol+1350,"Tecnico "     ,oFont11,100)
nL += 60

dbSelectArea("REC")
dbGoTop()

//Grava a Query no array aProd para validações
While !REC->(EOF())
	aAdd (aItens,{REC->Z02_ITEM,;
	            REC->Z02_PROD,;
                REC->Z02_DESC,;
                REC->Z02_QUANT,;
                REC->Z02_VLUNIT,;
                REC->Z02_TOTAL,;
                REC->Z02_DATA,;
                REC->Z02_NTECNI})
    
    nVlTot += REC->Z02_TOTAL

	REC->(dbSkip())
Enddo

dbSelectArea("REC")
dbGoTop()

WHILE !EOF()
	
	IF LastKey()==286
		@ 00,01 PSAY "*** CANCELADO PELO OPERADOR ***"
		lContinua := .F.
		Exit
	Endif
	
	dbSkip()
	LOOP
EndDo

For nX:=1 to len(aItens)
	
	if nL > 3400
		nL := 0290
		oprn:endpage()
		oprn:startpage()
		
		nL+=100
        oPrn:Say(nILin+nL,niCol+0010,"Cliente: " +REC->Z01_CLIENT+ "-" +Alltrim(REC->Z01_NOME),oFont12,100)
        nL+=100
        oPrn:Say(nILin+nL,niCol+0010,"Veiculo: " +Alltrim(REC->Z01_DESCV)+" Marca: " +Alltrim(REC->Z01_MARCAV),oFont12,100)
        nL+=100
        oPrn:Say(nILin+nL,niCol+0010,"Placa: " +Alltrim(REC->Z01_PLACA),oFont12,100)
        nL+=100
        oPrn:Say(nILin+nL,niCol+0010,"Vendedor: " +Alltrim(REC->A3_NOME),oFont12,100)
        nL+=60
        oPrn:Say(nILin+nL,niCol+0010,Replicate("_",100),oFont12,100)

        nL+=100
        oPrn:Say(nILin+nL,niCol+0010,"Item "        ,oFont11,100)
        oPrn:Say(nILin+nL,niCol+0080,"Produto "     ,oFont11,100)
        oPrn:Say(nILin+nL,niCol+0250,"Descricao "   ,oFont11,100)
        oPrn:Say(nILin+nL,niCol+0600,"Quantidade "  ,oFont11,100)
        oPrn:Say(nILin+nL,niCol+0800,"Valor Unit. " ,oFont11,100)
        oPrn:Say(nILin+nL,niCol+1000,"Total "       ,oFont11,100)
        oPrn:Say(nILin+nL,niCol+1200,"Data "        ,oFont11,100)
        oPrn:Say(nILin+nL,niCol+1350,"Tecnico "     ,oFont11,100)
        nL += 60
		
        // Imprime Cabecalho
		nL := ImpCabec()
		
	Endif

    cData := SubStr(aItens[nX][7],7,2)+"/"+SubStr(aItens[nX][7],2,2)+"/"+SubStr(aItens[nX][7],1,4)
	
	oPrn:Say(nILin+nL,niCol+0010,aItens[nX][1],oFont1,100)  //item
	oPrn:Say(nILin+nL,niCol+0080,aItens[nX][2],oFont1,100)  //produto
	oPrn:Say(nILin+nL,niCol+0250,aItens[nX][3],oFont1,100)  //descrição
	oPrn:Say(nILin+nL,niCol+0600,transform(aItens[nX][4],"@E 99,999,999.99"),oFont1,100)  //Quantidade
    oPrn:Say(nILin+nL,niCol+0800,transform(aItens[nX][5],"@E 99,999,999.99"),oFont1,100)  //vl unitario
    oPrn:Say(nILin+nL,niCol+0970,transform(aItens[nX][6],"@E 99,999,999.99"),oFont1,100)  //total
    oPrn:Say(nILin+nL,niCol+1200,cData,oFont1,100)  //data    
    oPrn:Say(nILin+nL,niCol+1350,aItens[nX][8],oFont1,100)  //tecnico   
	nL+=40
Next nX

//Imprimi total dos serviços
nL+=60
oPrn:Say(nILin+nL,niCol+0010,Replicate("_",150),oFont12,100)
nL+=60
oPrn:Say(nILin+nL,niCol+0010,"Total dos serviços ------------- R$ "+transform(nVlTot,"@E 99,999,999.99") ,oFont11,100)

nL+=1

//Zera a variavel totalizadora
nVlTot := 0

DbCloseArea()


if lGrafico
	if type("oprn") <> "U"
		//Para Obter um preview da impressão, desabilite a linha abaixo
		oprn:PREVIEW()
		//oPrn:Print()
		oprn:end()
	Endif
Else
	@Prow(),0 PSAY CHR(18)
	Set Device To Screen
	
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif
Endif

MS_FLUSH()

Return()


/*
+-----------+------------+----------------+--------------------+-------+---------------+
| Programa  | ImpCabec 	 | Desenvolvedor  |Luiz Paulo Rodrigues| Data  | 			   |
+-----------+------------+----------------+--------------------+-------+---------------+
| Descricao | Gera a impressão do cabeçalho do relatório							   |
+-----------+--------------------------------------------------------------------------+
| Modulo    | SIGAEST			                                                       |
+-----------+--------------------------------------------------------------------------+
*/

STATIC FUNCTION ImpCabec()

LOCAL cLogo :=""

oPrn:Box(0020,0100,0240,2220)
cLogo := Upper(GetSrvProfString("STARTPATH",""))+"\logo_agro.bmp"
oPrn:SayBitmap(niLin+035,niCol+035,cLogo,580,170)

oPrn:Say(niLin+030,niCol+900,"BonLub Lubrificantes"				            ,oFont11,100)
oPrn:Say(niLin+065,niCol+900,"Avenida Mascarenhas de Morais, 2754"  		,oFont1,100)
oPrn:Say(niLin+100,niCol+900,"Fone: (0xx67)3314-2040"			            ,oFont1,100)
oPrn:Say(niLin+135,niCol+900,"CEP: 79010-500, Campo Grande - MS"			,oFont1,100)
//oPrn:Say(niLin+165,niCol+900,"CNPJ: 59.963.488/0001.03   Insc. Estadual: ISENTO"	,oFont1,100)
//oPrn:Say(niLin+195,niCol+900,"Insc. Municipal: 3.475/68        www.diarioweb.com.br",oFont1,100)
oPrn:Say(niLin+165,niCol+1700,"Usuário: "+CUSERNAME									,oFont1,100)
oPrn:Say(niLin+195,niCol+1700,"Data/Hora: "+DtoC(DDataBase)+" "+SUBS(Time(),1,2)+":"+SUBS(Time(),4,2)+":"+SUBS(Time(),7,2),oFont1,100)

Return(nL)




/*
+-----------+------------+----------------+--------------------+-------+---------------+
| Programa  | TiraSimb 	 | Desenvolvedor  |Luiz Paulo Rodrigues| Data  | 			   |
+-----------+------------+----------------+--------------------+-------+---------------+
| Descricao | Retira simbolos												   		   |
+-----------+--------------------------------------------------------------------------+
| Modulo    | SIGAEST			                                                       |
+-----------+--------------------------------------------------------------------------+
*/

STATIC FUNCTION TiraSimb(pTexto)
LOCAL cRet := pTexto
cRet := strtran(cRet,".","")
cRet := strtran(cRet,"-","")
cRet := strtran(cRet,"*","")
cRet := strtran(cRet,"\","")
cRet := strtran(cRet,"/","")
cRet := strtran(cRet,chr(13)," ")
cRet := strtran(cRet,chr(10)," ")
RETURN(cRet)
