#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _cCodInt		:= "004"
Static _cDescInt	:= "FORNECEDORES"
Static _cDirRaiz 	:= "\danalog\"

/************************************************************************************/
/*/{Protheus.doc} 
    @description API - Cadastro de fornecedores logistico
    @author Bernard M. Margarido
    @since 23/11/2020
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSRESTFUL FORNECEDORES DESCRIPTION " Servico DanaLog - Atualização fornecedores."
    
    WSDATA CNPJ_CPF 	AS STRING
    WSDATA IDCLIENTE    AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING

    WSMETHOD GET    DESCRIPTION "Realiza consulta dos fornecedores."    WSSYNTAX "/FORNECEDORES/GET"
	WSMETHOD POST   DESCRIPTION "Realiza gravação dos fornecedores."    WSSYNTAX "/FORNECEDORES/POST"
    WSMETHOD PUT    DESCRIPTION "Realiza atualização dos fornecedores." WSSYNTAX "/FORNECEDORES/PUT"
    
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} POST
    @description Metodo - realiza o cadastro de fornecedores
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE FORNECEDORES
Local _aArea    := GetArea()

Local _cBody        := ""
Local _cAuth        := ""

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_FORNECEDOR_POST" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE FORNECEDOR METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//-------------------------------------------+
// Valida se existe arquivo no corpo do POST | 
//-------------------------------------------+
_cBody  := Self:GetContent()
_cAuth	:= Self:GetHeader('Authorization')

//----------------+
// Classe Danalog | 
//----------------+
_oDLog  := DanaLog():New()
_oDLog:cAuth    := _cAuth
_oDLog:cJSon    := _cBody
_oDLog:cMetodo  := "POST"

If _oDLog:Fornecedor()
    LogExec("FORNECEDOR SALVO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO SALVAR FORNECEDOR")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE FORNECEDOR METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} GET
    @description Metodo - Consulta fornecedores cadastrados
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE CNPJ_CPF,IDCLIENTE,PERPAGE,PAGE WSSERVICE FORNECEDORES
Local _aArea    := GetArea()

Local _cAuth        := ""
Local _cIdCiente    := IIF(Empty(::IDCLIENTE),"",::IDCLIENTE)
Local _cCnpj_Cpf    := IIF(Empty(::CNPJ_CPF),"",::CNPJ_CPF)
Local _cPage        := IIF(Empty(::PAGE),"1",::PAGE)
Local _cParPage     := IIF(Empty(::PERPAGE),"10",::PERPAGE)

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_FORNECEDOR_GET" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE CLIENTE METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//------------------------------------------+
// Valida se existe arquivo no corpo do GET | 
//------------------------------------------+
_cAuth	:= Self:GetHeader('Authorization')

//----------------+
// Classe Danalog | 
//----------------+
_oDLog  := DanaLog():New()
_oDLog:cAuth        := _cAuth
_oDLog:cIdCliente   := _cIdCiente
_oDLog:cCnpj        := _cCnpj_Cpf
_oDLog:cPage        := _cPage
_oDLog:cPerPage     := _cParPage
_oDLog:cMetodo      := "GET"

If _oDLog:Fornecedor()
    LogExec("FORNECEDOR RETORNADO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO CONSULTAR FORNECEDOR")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE FORNECEDOR METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} PUT
    @description Metodo - realiza a atualização dos fornecedores
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD PUT WSSERVICE FORNECEDORES
Local _aArea        := GetArea()

Local _cBody        := ""
Local _cAuth        := ""

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_FORNECEDOR_PUT" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE FORNECEDOR METODO PUT - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//-------------------------------------------+
// Valida se existe arquivo no corpo do POST | 
//-------------------------------------------+
_cBody  := Self:GetContent()
_cAuth	:= Self:GetHeader('Authorization')

//----------------+
// Classe Danalog | 
//----------------+
_oDLog  := DanaLog():New()
_oDLog:cAuth    := _cAuth
_oDLog:cJSon    := _cBody
_oDLog:cMetodo  := "PUT"

If _oDLog:Fornecedor()
    LogExec("FORNECEDOR SALVO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO ATUALIZAR FORNECEDOR")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE FORNECEDOR METODO PUT - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(_aArea)
Return .T. 

/************************************************************************************/
/*/{Protheus.doc} LogExec
    @description LogExec - grava arquivo de LOG
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(_cArqLog,cMsg)
Return .T.