#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _cCodInt		:= "001"
Static _cDescInt	:= "TOKEN"
Static _cDirRaiz 	:= "\danalog\"

/************************************************************************************/
/*/{Protheus.doc} 
    @description API - Solicitação de Token
    @author Bernard M. Margarido
    @since 22/11/2020
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSRESTFUL API_TOKEN DESCRIPTION " Servico DanaLog - Retorna Token."
						
	WSMETHOD POST  DESCRIPTION "Retorna Token." WSSYNTAX "/API_TOKEN"

END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} POST
    @description Retorna token de segurança.
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE API_TOKEN
Local _aArea		:= GetArea()

Local _cBody        := ""

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_TOKEN" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA CONSULTA DE TOKEN - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//-------------------------------------------+
// Valida se existe arquivo no corpo do POST | 
//-------------------------------------------+
_cBody  := Self:GetContent()

//----------------+
// Classe Danalog | 
//----------------+
_oDLog  := DanaLog():New()
_oDLog:cJSon := _cBody

If _oDLog:Token()
    LogExec("TOKEN RETORNADO COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO GERAR TOKEN")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA CONSULTA DE TOKEN - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
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