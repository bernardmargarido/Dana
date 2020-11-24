#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _cCodInt		:= "002"
Static _cDescInt	:= "PRODUTO"
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
WSRESTFUL API_PRODUTOS DESCRIPTION " Servico DanaLog - Atualização produtos."
    
    WSDATA CODIGO 	    AS STRING
    WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING

    WSMETHOD GET    DESCRIPTION "Realiza consulta dos produtos."    WSSYNTAX "/API_PRODUTOS/GET"
	WSMETHOD POST   DESCRIPTION "Realiza gravação dos produtos."    WSSYNTAX "/API_PRODUTOS/POST"
    WSMETHOD PUT    DESCRIPTION "Realiza atualização dos produtos." WSSYNTAX "/API_PRODUTOS/PUT"
    
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} POST
    @description Metodo - realiza o cadastro de produtos
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE API_PRODUTOS
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
_cArqLog := _cDirRaiz + "API_PRODUTO_POST" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE PRODUTO METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

If _oDLog:Produto()
    LogExec("PRODUTO SALVO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO SALVAR PRODUTO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE PRODUTO METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RestArea(_aArea)
Return .T.

WSMETHOD GET WSRECEIVE CODIGO,DATAHORA,PERPAGE,PAGE WSSERVICE API_PRODUTOS
Local _lRet     := .T.

Return _lRet 

WSMETHOD PUT WSSERVICE API_PRODUTOS
Local _lRet     := .T.

Return _lRet 


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