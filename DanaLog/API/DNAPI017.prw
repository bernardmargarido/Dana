#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _cCodInt		:= "006"
Static _cDescInt	:= "REMESSA_ENTRADA"
Static _cDirRaiz 	:= "\danalog\"

/************************************************************************************/
/*/{Protheus.doc} 
    @description API - Recebimento de mercadoria
    @author Bernard M. Margarido
    @since 23/11/2020
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSRESTFUL RECEBIMENTO DESCRIPTION " Servico DanaLog - Realiza recebimento de notas."
    
    WSDATA IDCLIENTE 	AS STRING
	WSDATA NOTA		    AS STRING
	WSDATA SERIE		AS STRING	
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING

    WSMETHOD GET    DESCRIPTION "Realiza consulta dos recebimentos."    WSSYNTAX "/RECEBIMENTO/GET"
	WSMETHOD POST   DESCRIPTION "Realiza gravação das recebimentos."    WSSYNTAX "/RECEBIMENTO/POST"
    
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} POST
    @description Metodo - realiza o cadastro do recebimento de mercadorias
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE RECEBIMENTO
Local _aArea        := GetArea()

Local _cBody        := ""
Local _cAuth        := ""

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_RECEBIMENTO_POST" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE RECEBIMENTO METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

If _oDLog:Recebimento()
    LogExec("RECEBIMENTO SALVA COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO SALVAR RECEBIMENTO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE RECEBIMENTO METODO POST - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")


RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} GET
    @description Metodo - Consulta recebimentos cadastrados
    @author Bernard M. Margarido
    @since 23/03/2018
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE IDCLIENTE,NOTA,SERIE,PERPAGE,PAGE WSSERVICE RECEBIMENTO
Local _aArea    := GetArea()

Local _cAuth        := ""
Local _cIdCiente    := IIF(Empty(::IDCLIENTE),"",::IDCLIENTE)
Local _cNota        := IIF(Empty(::NOTA),"",::NOTA)
Local _cSerie       := IIF(Empty(::SERIE),"",::SERIE)
Local _cPage        := IIF(Empty(::PAGE),"1",::PAGE)
Local _cParPage     := IIF(Empty(::PERPAGE),"10",::PERPAGE)

Local _oDLog        := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_RECEBIMENTO_GET" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE RECEBIMENTO METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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
_oDLog:cAuth        := IIF(ValType(_cAuth) == "U", "", _cAuth)
_oDLog:cIdCliente   := _cIdCiente
_oDLog:cNota        := _cNota
_oDLog:cSerie       := _cSerie
_oDLog:cPage        := _cPage
_oDLog:cPerPage     := _cParPage
_oDLog:cMetodo      := "GET"

If _oDLog:Recebimentos()
    LogExec("RECEBIMENTO RETORNADA COM SUCESSO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,"OK")
Else
    LogExec("ERRO AO CONSULTAR RECEBIMENTO")
    ::SetResponse(_oDLog:cJSonRet)
	HTTPSetStatus(_oDLog:nCodeHttp,_oDLog:cError)
EndIf	

LogExec("FINALIZA API DE RECEBIMENTO METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
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