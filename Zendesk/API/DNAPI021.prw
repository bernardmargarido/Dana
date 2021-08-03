#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _cCodInt		:= "021"
Static _cDescInt	:= "CLIENTES_ZENDESK"
Static _cDirRaiz 	:= "\zendesk\"

/************************************************************************************/
/*/{Protheus.doc} 
    @description API - Consulta dados clientes Zendesk
    @author Bernard M. Margarido
    @since 03/08/2021
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSRESTFUL CLIENTES_ZENDESK DESCRIPTION " Servico Dana Cosméticos - Clientes Zendesk."
    
    WSDATA IDCLIENTE    AS STRING
	
    WSMETHOD GET    DESCRIPTION "Realiza consulta dos clientes VTex."    WSSYNTAX "/CLIENTES_ZENDESK/GET"
	    
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET
    @description Metodo - Consulta clientes ecommerce cadastrados
    @author Bernard M. Margarido
    @since 03/08/2021
    @version 1.0
    @type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE IDCLIENTE WSSERVICE CLIENTES_ZENDESK
Local _aArea    := GetArea()

Local _cAuth        := ""
Local _cIdCiente    := IIF(Empty(::IDCLIENTE),"",::IDCLIENTE)

Local _oZendesk     := Nil 

Private _cArqLog	:= ""

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(_cDirRaiz)
_cArqLog := _cDirRaiz + "API_CLIENTESDANA_GET" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA API DE CLIENTESDANA METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//------------------------------------------+
// Valida se existe arquivo no corpo do GET | 
//------------------------------------------+
//_cAuth	:= Self:GetHeader('Authorization')

//----------------+
// Classe Danalog | 
//----------------+
_oZendesk  := Zendesk():New()
_oZendesk:cIdCliente   := _cIdCiente

If _oZendesk:Clientes()
    LogExec("<< CLIENTESDANA >> - CLIENTE RETORNADO COM SUCESSO")
    ::SetResponse(_oZendesk:cJSon)
	HTTPSetStatus(_oZendesk:nCodeHttp,"OK")
Else
    LogExec("<< CLIENTESDANA >> - ERRO AO CONSULTAR CLIENTE")
    ::SetResponse(_oZendesk:cJSon)
	HTTPSetStatus(_oZendesk:nCodeHttp,_oZendesk:cError)
EndIf	

LogExec("FINALIZA API DE CLIENTESDANA METODO GET - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
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