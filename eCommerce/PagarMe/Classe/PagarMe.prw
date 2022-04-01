#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

/***************************************************************************************/
/*/{Protheus.doc} PagarMe
    @description Classe - API's PagarMe
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/***************************************************************************************/
Class PagarMe 

    Data aHeadOut       As Array 
    
    Data cUrl           As String 
    Data cUser          As String 
    Data cPassword      As String 
    Data cStatus        As String 
    Data cTipo          As String 
    Data cTID           As String 
    Data cRecepientID   As String 
    Data cJSon          As String 
    Data cRetJSon       As String
    Data cError         As String 

    Data _cCACertPath	As String
	Data _cPassword		As String
	Data _cCertPath		As String 
	Data _cKeyPath		As String

    Data dDtaPayment    As Date 

    Data _nSSL2		    As Integer 
	Data _nSSL3		    As Integer
	Data _nTLS1		    As Integer 
	Data _nHSM		    As Integer
	Data _nVerbose	    As Integer 
	Data _nBugs		    As Integer 
	Data _nState	    As Integer 

    Data oFwRest        As Object 
    Data oRetJSon       As Object

    Method New() Constructor 
    Method GetSSLCache()
    Method Saldo() 
    Method Historico()
    Method Recebivel() 
    Method Transferencia()
    Method Chargebacks()
    Method Recebedor() 

End Class

/***************************************************************************************/
/*/{Protheus.doc} New
    @description Metodo construtor da classe
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/***************************************************************************************/
Method New() Class PagarMe 

    ::cUrl          := GetNewPar("DN_URLPAME","https://api.pagar.me")
    ::cUser         := GetNewPar("DN_USRPAME","ak_live_ynOhPw24yWHAnimKV3kjKT04urbf8D")
    ::cPassword     := GetNewPar("DN_PASPAME","x")
    ::cStatus       := ""
    ::cTipo         := ""
    ::cTID          := ""
    ::cRecepientID  := ""
    ::cJSon         := ""
    ::cRetJSon      := ""
    ::_cPassword	:= ""
	::_cCertPath	:= "" 
	::_cKeyPath		:= "" 
	::_cCACertPath	:= ""
    ::cError        := ""

    ::dDtaPayment   := "" 

    ::_nSSL2		:= 0
	::_nSSL3		:= 0
	::_nTLS1		:= 3
	::_nHSM			:= 0
	::_nVerbose		:= 1
	::_nBugs		:= 1
	::_nState	    := 1

    ::aHeadOut      := {}

    ::oFwRest       := Nil 
    ::oRetJSon      := Nil 

Return Nil 

/****************************************************************************************/
/*/{Protheus.doc} GetSSLCache
    @description Define o uso em memoria da configuração SSL para integrações SIGEP
    @author Bernard M. Margarido
    @since 06/12/2019
    @version 1.0
    @type function
/*/
/****************************************************************************************/
Method GetSSLCache() Class PagarMe
Local _lRet 	:= .F.

//-------------------------------------+
// Utiliza configurações SSL via Cache |
//-------------------------------------+
If HTTPSSLClient( ::_nSSL2, ::_nSSL3, ::_nTLS1, ::_cPassword, ::_cCertPath, ::_cKeyPath, ::_nHSM, .F. , ::_nVerbose, ::_nBugs, ::_nState)
	_lRet := .T.
EndIf

Return _lRet 

/***************************************************************************************/
/*/{Protheus.doc} Saldo
    @description Metodo - Retorna saldo em conta PagarMe
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/***************************************************************************************/
Method Saldo() Class PagarMe 
Local _lRet := .T.

//---------------+
// Usa cache SSL |
//---------------+
::GetSSLCache()

//----------------------------------------+
// Array contendo parametros de cabeçalho |
//----------------------------------------+
::aHeadOut  := {}
aAdd(::aHeadOut,"Authorization: Basic " + Encode64(RTrim(::cUser) + ":" + RTrim(::cPassword)) )
aAdd(::aHeadOut,"Content-Type: application/json" )

//-------------------------+
// Instancia classe FwRest |
//-------------------------+
::oFwRest   := FWRest():New(::cUrl)

//---------------------+
// TimeOut do processo |
//---------------------+
::oFwRest:nTimeOut := 600

//-------------------------+
// Metodo a ser consultado |
//-------------------------+
::oFwRest:SetPath("/1/balance")

If ::oFwRest:Get(::aHeadOut)
    ::cRetJSon	:= DecodeUtf8(::oFwRest:GetResult())
    _lRet       := .T.
Else
    If ValType(::oFwRest:GetResult()) <> "U"
        ::cRetJSon	:= DecodeUtf8(::oFwRest:GetResult())
        ::oRetJSon	:= xFromJson(::cRetJSon)
        ::cError    := ::oRetJSon[#"errors"][1][#"message"] 
    ElseIf At("Unauthorized", ::oFwRest:cInternalError) > 0
        ::cError    := "Token de acesso expirado ou não autorizado."
    Else 
        ::cError    := "Não foi possivel conectar com as API's da Pagar.Me. Favor tentar mais tarde."
    EndIf
    _lRet   := .F.
EndIf

Return _lRet  

/***************************************************************************************/
/*/{Protheus.doc} Historico
    @description Metodo - Retorna historico de operações
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/***************************************************************************************/
Method Historico() Class PagarMe 
Local _lRet := .T.
Return _lRet 

/***************************************************************************************/
/*/{Protheus.doc} Recebivel
    @description Metodo Retorna pagamentos disponiveis 
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/***************************************************************************************/
Method Recebivel() Class PagarMe 
Local _lRet     := .T.

Local _cParam   := ""

//---------------+
// Usa cache SSL |
//---------------+
::GetSSLCache()

//----------------------------------------+
// Array contendo parametros de cabeçalho |
//----------------------------------------+
::aHeadOut  := {}
aAdd(::aHeadOut,"Authorization: Basic " + Encode64(RTrim(::cUser) + ":" + RTrim(::cPassword)) )
aAdd(::aHeadOut,"Content-Type: application/json" )

//-------------------------+
// Instancia classe FwRest |
//-------------------------+
::oFwRest   := FWRest():New(::cUrl)

//---------------------+
// TimeOut do processo |
//---------------------+
::oFwRest:nTimeOut := 600

//----------------------+
// Metodo a ser enviado | 
//----------------------+
If !Empty(::dDtaPayment)
    _cParam := "payment_date=" + ::dDtaPayment
EndIf

::oFwRest:SetPath("/1/payables?" + _cParam)

If ::oFwRest:Get(::aHeadOut)
    ::cRetJSon	:= DecodeUtf8(::oFwRest:GetResult())
    _lRet       := .T.
Else
    If ValType(::oFwRest:GetResult()) <> "U"
        ::cRetJSon	:= DecodeUtf8(::oFwRest:GetResult())
        ::oRetJSon	:= xFromJson(::cRetJSon)
        ::cError    := ::oRetJSon[#"errors"][1][#"message"] 
    ElseIf At("Unauthorized", ::oFwRest:cInternalError) > 0
        ::cError    := "Token de acesso expirado ou não autorizado."
    Else 
        ::cError    := "Não foi possivel conectar com as API's da Pagar.Me. Favor tentar mais tarde."
    EndIf
    _lRet   := .F.
EndIf
    
Return _lRet 

/***************************************************************************************/
/*/{Protheus.doc} Transferencia
    @description Metodo - Cria/Consulta/Estorna transferencia
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/***************************************************************************************/
Method Transferencia() Class PagarMe 
Local _lRet := .T.

//---------------+
// Usa cache SSL |
//---------------+
::GetSSLCache()

//----------------------------------------+
// Array contendo parametros de cabeçalho |
//----------------------------------------+
::aHeadOut  := {}
aAdd(::aHeadOut,"Authorization: Basic " + Encode64(RTrim(::cUser) + ":" + RTrim(::cPassword)) )
aAdd(::aHeadOut,"Content-Type: application/json" )

//-------------------------+
// Instancia classe FwRest |
//-------------------------+
::oFwRest   := FWRest():New(::cUrl)

//---------------------+
// TimeOut do processo |
//---------------------+
::oFwRest:nTimeOut := 600

::oFwRest:SetPath("/1/transfers")
::oFwRest:SetPostParams(EncodeUtf8(::cJSon))
If ::oFwRest:Post(::aHeadOut)
    ::cRetJSon	:= DecodeUtf8(::oFwRest:GetResult())
    _lRet       := .T.
Else
   If ValType(::oFwRest:GetResult()) <> "U"
        ::cRetJSon	:= DecodeUtf8(::oFwRest:GetResult())
        ::oRetJSon	:= xFromJson(::cRetJSon)
        ::cError    := ::oRetJSon[#"errors"][1][#"message"] 
    ElseIf At("Unauthorized", ::oFwRest:cInternalError) > 0
        ::cError    := "Token de acesso expirado ou não autorizado."
    Else 
        ::cError    := "Não foi possivel conectar com as API's da Pagar.Me. Favor tentar mais tarde."
    EndIf
    _lRet   := .F.
EndIf

Return _lRet 

/***************************************************************************************/
/*/{Protheus.doc} Chargebacks
    @description Metodo - Retorna estorno/reembolsos realizados pela pagarme 
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/***************************************************************************************/
Method Chargebacks() Class PagarMe 
Local _lRet := .T.

Return _lRet 

/***************************************************************************************/
/*/{Protheus.doc} Recebedor
    @description Metodo - Retorna contas bancárias recebedor 
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/***************************************************************************************/
Method Recebedor() Class PagarMe 
Local _lRet := .T.

Return _lRet 
