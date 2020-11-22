#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _cCodInt		:= "001"
Static _cDescInt	:= "TOKEN"
Static _cDirRaiz 	:= "\danalog\"
Static _nTCnpj 		:= TamSx3("A1_CGC")[1]

/************************************************************************************/
/*/{Protheus.doc} 
    @description API - Login do corretor
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSRESTFUL API_TOKEN DESCRIPTION " Servico DanaLog - Retorna Token."
						
	WSMETHOD POST  DESCRIPTION "Retorna Token." WSSYNTAX "/TOKEN"

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
Local _aRet			:= {.F.,""}

Local _cClientId	:= ""
Local _cSecret		:= ""
Local _cGrant		:= ""
Local _cToken		:= ""
Local _cBody        := ""

Local _nCodRet		:= 400

Local _oJson		:= Nil	
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
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
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