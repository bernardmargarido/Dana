#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _cCodInt		:= "003"
Static _cDescInt	:= "CLIENTE"
Static _cDirRaiz 	:= "\danalog\"

/************************************************************************************/
/*/{Protheus.doc} 
    @description API - Cadastro de produtos cliente logistico
    @author Bernard M. Margarido
    @since 23/11/2020
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSRESTFUL API_CLIENTES DESCRIPTION " Servico DanaLog - Atualização clientes."
    
    WSDATA CNPJ_CPF 	AS STRING
	WSDATA CODIGO		AS STRING
	WSDATA LOJA			AS STRING	
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING

    WSMETHOD GET    DESCRIPTION "Realiza consulta dos clientes."    WSSYNTAX "/API_CLIENTES/GET"
	WSMETHOD POST   DESCRIPTION "Realiza gravação dos clientes."    WSSYNTAX "/API_CLIENTES/POST"
    WSMETHOD PUT    DESCRIPTION "Realiza atualização dos clientes." WSSYNTAX "/API_CLIENTES/PUT"
    
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} POST
    @description Metodo - realiza o cadastro de clientes
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE API_CLIENTES
Local _aArea    := GetArea()

Local _cBody        := ""
Local _cAuth        := ""

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//-----------------------+
// Abre empresa / filial |
//-----------------------+
If cEmpAnt == "01"
    RpcClearEnv()
EndIf

RPCSetType(3)
RPCSetEnv("02", "01", Nil, Nil, "FRT")

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_CLIENTES_POST" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE CLIENTES METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

If _oDLog:Clientes()
    LogExec("CLIENTE SALVO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO SALVAR CLIENTE")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE CLIENTE METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} GET
    @description Metodo - Consulta clientes cadastrados
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE CNPJ_CPF,CODIGO,LOJA,DATAHORA,PERPAGE,PAGE WSSERVICE API_CLIENTES
Local _aArea    := GetArea()

Local _cBody        := ""
Local _cAuth        := ""
Local _cCliCod      := IIF(Empty(::CODIGO),"",::CODIGO)
Local _cCliLoja     := IIF(Empty(::LOJA),"",::LOJA)
Local _cCnpj_Cpf    := IIF(Empty(::CNPJ_CPF),"",::CNPJ_CPF)

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//-----------------------+
// Abre empresa / filial |
//-----------------------+
If cEmpAnt == "01"
    RpcClearEnv()
EndIf

RPCSetType(3)
RPCSetEnv("02", "01", Nil, Nil, "FRT")

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_CLIENTE_GET" + cEmpAnt + cFilAnt + ".LOG"
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
_cBody  := Self:GetContent()
_cAuth	:= Self:GetHeader('Authorization')

//----------------+
// Classe Danalog | 
//----------------+
_oDLog  := DanaLog():New()
_oDLog:cAuth    := _cAuth
_oDLog:cJSon    := _cBody
_oDLog:cCliCod  := _cCliCod
_oDLog:cCliLoja := _cCliLoja
_oDLog:cCnpj    := _cCnpj_Cpf
_oDLog:cMetodo  := "GET"

If _oDLog:Clientes()
    LogExec("CLIENTE RETORNADO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO CONSULTAR CLIENTE")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE CLIENTE METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} PUT
    @description Metodo - realiza a atualização dos clientes
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD PUT WSSERVICE API_CLIENTES
Local _aArea        := GetArea()

Local _cBody        := ""
Local _cAuth        := ""

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//-----------------------+
// Abre empresa / filial |
//-----------------------+
If cEmpAnt == "01"
    RpcClearEnv()
EndIf

RPCSetType(3)
RPCSetEnv("02", "01", Nil, Nil, "FRT")

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_CLIENTE_PUT" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE CLIENTE METODO PUT - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

If _oDLog:Produtos()
    LogExec("CLIENTE SALVO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO ATUALIZAR CLIENTE")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE CLIENTE METODO PUT - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

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