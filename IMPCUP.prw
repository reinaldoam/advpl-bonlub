#include "Protheus.ch"

User Function IMPCUP()
Local _sMsg := ""
    
    _sMsg += " "+Chr(13)+Chr(10)    
	_sMsg += "Cliente: "+SA1->A1_COD+"-"+SA1->A1_LOJA +Chr(13)+Chr(10)
	_sMsg += "Nome: "+AllTrim(SA1->A1_NOME) +Chr(13)+Chr(10)
	_sMsg +=  "CPF/CNPJ: "+ Transform(SA1->A1_CGC, iif(SA1->A1_PESSOA=="J", "@R 99.999.999/9999-99","@R 999.999.999-99") ) +Chr(13)+Chr(10)
	_sMsg +=  "Operador: "+__cUserID+"-"+upper(cUserName)+Chr(13)+Chr(10)
	_sMsg +=  "Vendedor: "+SA3->A3_COD+"-"+ substr(AllTrim(SA3->A3_NOME),1,25) +Chr(13)+Chr(10) 



Return (_sMsg)

/*"	Nome e CPF/ CNPJ do Cliente 
"	Nome e Código do operador de caixa.
"	Nome do Vendedor
"	NSU 
"	Numero do cartão
"	Numero de Autorização.
*/