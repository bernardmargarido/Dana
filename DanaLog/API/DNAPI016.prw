#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _cCodInt		:= "005"
Static _cDescInt	:= "TRANSPORTADORA"
Static _cDirRaiz 	:= "\danalog\"

/************************************************************************************/
/*/{Protheus.doc} 
    @description API - Cadastro de transportadoras logistico
    @author Bernard M. Margarido
    @since 23/11/2020
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSRESTFUL TRANSPORTADORAS DESCRIPTION " Servico DanaLog - Atualização transportadoras."
    
    WSDATA CNPJ_CPF 	AS STRING
	WSDATA IDCLIENTE    AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING

    WSMETHOD GET    DESCRIPTION "Realiza consulta das transportadoras."    WSSYNTAX "/TRANSPORTADORAS/GET"
	WSMETHOD POST   DESCRIPTION "Realiza gravação das transportadoras."    WSSYNTAX "/TRANSPORTADORAS/POST"
    WSMETHOD PUT    DESCRIPTION "Realiza atualização das transportadoras." WSSYNTAX "/TRANSPORTADORAS/PUT"
    
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} POST
    @description Metodo - realiza o cadastro de transportadoras
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE TRANSPORTADORAS
Local _aArea        := GetArea()

Local _cBody        := ""
Local _cAuth        := ""

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_TRANSPORTADORA_POST" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE TRANSPORTADORA METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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
_oDLog:cAuth    := IIF(ValType(_cAuth) == "U", "", _cAuth)
_oDLog:cJSon    := IIF(ValType(_cBody) == "U", "", _cBody)
_oDLog:cMetodo  := "POST"

If _oDLog:Transportadora()
    LogExec("TRANSPORTADORA SALVA COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO SALVAR TRANSPORTADORA")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE TRANSPORTADORA METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} GET
    @description Metodo - Consulta transportadoras cadastrados
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE CNPJ_CPF,IDCLIENTE,PERPAGE,PAGE WSSERVICE TRANSPORTADORAS
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
_cArqLog := _cDirRaiz + "API_TRANSPORTADORA_GET" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE TRANSPORTADORA METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//------------------------------------------+
// Valida se existe arquivo no corpo do GET | 
//------------------------------------------+
_cBody  := Self:GetContent()
_cAuth	:= Self:GetHeader('Authorization')

//----------------+
// Classe Danalog | 
//----------------+
_oDLog  := DanaLog():New()
_oDLog:cAuth        := IIF(ValType(_cAuth) == "U", "", _cAuth)
_oDLog:cIdCliente   := _cIdCiente
_oDLog:cCnpj        := _cCnpj_Cpf
_oDLog:cPage        := _cPage
_oDLog:cPerPage     := _cParPage
_oDLog:cMetodo      := "GET"

If _oDLog:Transportadora()
    LogExec("TRANSPORTADORA RETORNADA COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO CONSULTAR TRANSPORTADORA")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE TRANSPORTADORA METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} PUT
    @description Metodo - realiza a atualização das transportadoras
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD PUT WSSERVICE TRANSPORTADORAS
Local _aArea        := GetArea()

Local _cBody        := ""
Local _cAuth        := ""

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_TRANSPORTADORA_PUT" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE TRANSPORTADORA METODO PUT - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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
_oDLog:cAuth    := IIF(ValType(_cAuth) == "U", "", _cAuth)
_oDLog:cJSon    := IIF(ValType(_cBody) == "U", "", _cBody)
_oDLog:cMetodo  := "PUT"

If _oDLog:Transportadora()
    LogExec("TRANSPORTADORA SALVO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO ATUALIZAR TRANSPORTADORA")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE TRANSPORTADORA METODO PUT - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
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