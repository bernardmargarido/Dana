#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE SUCESS          200 
#DEFINE CREATE          201 
#DEFINE ACCEPTED        202
#DEFINE BADREQUEST      400
#DEFINE UNAUTHORIZED    401
#DEFINE FORBIDDEN       403
#DEFINE NOTFOUND        404

#DEFINE CRLF            CHR(13) + CHR(10)

/****************************************************************************************/
/*/{Protheus.doc} Zendesk
    @description Classe realiza as integra��es Protheus X Zendesk
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Class Zendesk

    Data cToken     As String 
    Data cJSon      As String 
    Data cIDCliente As String    
    Data cDocument  As String  
    Data cURLVtex   As String 
    Data cAppKey    As String 
    Data cAppToken  As String 

    Data nCodeHttp  As Integer
    
    Method New() Constructor
    Method Token()
    Method SetToken()
    Method ValidaToken()
    Method Clientes()
    Method Pedidos()
    Method Boletos()

End Class 

/****************************************************************************************/
/*/{Protheus.doc} New
    @description M�todo contrutor da classe
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method New() Class Zendesk

    ::cToken        := ""
    ::cJSon         := ""
    ::cIDCliente    := ""
    ::cDocument     := ""
    ::cURLVtex      := GetMv("EC_URLRES2")
    ::cAppKey       := GetMv("EC_APPKEY")
    ::cAppToken     := GetMv("EC_APPTOKE")

    ::nCodeHttp     := 0

Return Nil 

/****************************************************************************************/
/*/{Protheus.doc} Token
    @description M�todo retrona token acesso as API's
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method Token() Class Zendesk
Return .T.

/****************************************************************************************/
/*/{Protheus.doc} SetToken
    @description M�todo gera token acesso as API's
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method SetToken() Class Zendesk
Return .T.

/****************************************************************************************/
/*/{Protheus.doc} Token
    @description M�todo valida token de acesso as API's 
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method ValidaToken() Class Zendesk
Return .T.

/****************************************************************************************/
/*/{Protheus.doc} Clientes
    @description M�todo retorna dados dos clientes
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method Clientes() Class Zendesk
Local aHeadOut      := {}

Local _cParam       := ""
Local _cRest        := ""
Local _cEMail       := ""
Local _cFirstName   := ""
Local _cLastName    := ""
Local _cDocument    := ""
Local _cUserID      := ""

Local _lRet         := .T.

Local _nX           := 0
Local _nTimeOut     := 400

Local _oRest        := Nil 
Local _oVtex        := Nil 

aAdd(aHeadOut,"Content-Type: application/json" )
aAdd(aHeadOut,"X-VTEX-API-AppKey:" + ::cAppKey )
aAdd(aHeadOut,"X-VTEX-API-AppToken:" + ::cAppToken ) 

//----------------------+
// Istancia classe REST |
//----------------------+
_oRest          := FWRest():New(::cURLVtex)
_oRest:nTimeOut := _nTimeOut
_cParam         := "_fields=email,firstName,lastName,document,accountId,userId,accountName,id,v-indexed&_where=userId=" + RTrim(::cIDCliente)
_oRest:SetPath("/danacosmeticos/dataentities/CL/search?" + _cParam)

If _oRest:Get(aHeadOut)

    _cRest := DecodeUtf8(_oRest:GetResult())
    If Empty(_cRest)
        _cRest := _oRest:GetResult()
    EndIf 
    
    _oVtex := xFromJson(_cRest)
    If ValType(_oVtex) <> "U"
        If ValType(_oVtex) == "A" .And. Len(_oVtex) > 0
            For _nX := 1 To Len(_oVtex)
                _cEMail       := IIF(ValType(_oVtex[_nX][#"email"]) <> "U", _oVtex[_nX][#"email"] ,"")
                _cFirstName   := IIF(ValType(_oVtex[_nX][#"firstName"]) <> "U", _oVtex[_nX][#"firstName"] ,"")
                _cLastName    := IIF(ValType(_oVtex[_nX][#"lastName"]) <> "U", _oVtex[_nX][#"lastName"] ,"")
                _cDocument    := IIF(ValType(_oVtex[_nX][#"document"]) <> "U",_oVtex[_nX][#"document"], ::cDocument)
                _cUserID      := IIF(ValType(_oVtex[_nX][#"userId"]) <> "U", _oVtex[_nX][#"userId"] ,"")
                //-----------------------+
                // Monta JSon de retorno |
                //-----------------------+
                ::cJson     := JSonRetCli(_cEMail,_cFirstName,_cLastName,_cDocument,_cUserID,.T.)
                ::nCodeHttp := SUCESS
            Next _nX 
        ElseIf ValType(_oVtex) == "A" .And. Len(_oVtex) == 0
            ::cJson     := JSonRetCli(_cEMail,_cFirstName,_cLastName,_cDocument,_cUserID,.F.)
            _lRet       := .F.
            ::nCodeHttp := NOTFOUND
        EndIf 
    EndIf 
Else 
    _cRest  := DecodeUtf8(_oRest:GetLastError())
    _lRet   := .F.
EndIf
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Pedido
    @description M�todo retorna status atual dos pedidos
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method Pedidos() Class Zendesk 
Local _lRet := .T.
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Boleto 
    @description M�todo retorna 2via do boleto 
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method Boletos() Class Zendesk
Local _lRet := .T.
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} JSonRetCli
    @description Cria Json de retorno com os dados do cliente 
    @type  Static Function
    @author Bernard M. Margarido
    @since 03/08/2021
/*/
/****************************************************************************************/
Static Function JSonRetCli(_cEMail,_cFirstName,_cLastName,_cDocument,_cUserID,_lOk)
Local _aArea    := GetArea()

Local _cJSon    := ""

Local _nTCGC    := TamSx3("A1_CGC")[1]

Local _oJSon    := Nil 

If _lOk
    //-------------------------------------+
    // SA1 - Posiciona cadastro de cliente |
    //-------------------------------------+
    dbSelectArea("SA1")
    SA1->( dbSetOrder(3) )
    If SA1->( dbSeek(xFilial("SA1") + PadR(_cDocument,_nTCGC)))
        _oJSon := Array(#)
        _oJSon[#"id_vtex"]      := _cUserID
        _oJSon[#"codigo"]       := RTrim(SA1->A1_COD)
        _oJSon[#"loja"]         := RTrim(SA1->A1_LOJA)
        _oJSon[#"nome"]         := RTrim(_cFirstName) + " " + RTrim(_cLastName)
        _oJSon[#"documento"]    := RTrim(SA1->A1_CGC)
        _oJSon[#"tipo"]         := RTrim(SA1->A1_PESSOA)
        _oJSon[#"email"]        := RTrim(_cEMail)
        _oJSon[#"enderecos"]    := {}
        aAdd(_oJSon[#"enderecos"],Array(#))
        _oAdress    := aTail(_oJSon[#"enderecos"])
        _oAdress[#"tipo"]       := "Residencial"
        _oAdress[#"endereco"]   := RTrim(SA1->A1_END)
        _oAdress[#"bairro"]     := RTrim(SA1->A1_BAIRRO)
        _oAdress[#"municipio"]  := RTrim(SA1->A1_MUN)
        _oAdress[#"uf"]         := RTrim(SA1->A1_EST)
        _oAdress[#"cep"]        := Transform(RTrim(SA1->A1_CEP),PesqPict("SA1","A1_CEP"))
        _oAdress[#"complemento"]:= RTrim(SA1->A1_COMPLEM)
    Else 
        _oJSon := Array(#)
        _oJSon[#"id_vtex"]      := _cUserID
        _oJSon[#"codigo"]       := Nil
        _oJSon[#"loja"]         := Nil 
        _oJSon[#"nome"]         := RTrim(_cFirstName) + " " + RTrim(_cLastName)
        _oJSon[#"documento"]    := RTrim(_cDocument)
        _oJSon[#"tipo"]         := Nil 
        _oJSon[#"email"]        := RTrim(_cEMail)
    EndIf 
Else 
    _oJSon := Array(#)
    _oJSon[#"error"]            := "Cliente n�o localizado"
EndIf 
//---------------------------------+
// Converte objeto em arquivo JSON |
//---------------------------------+
_cJSon := EncodeUTF8(xToJson(_oJSon))

RestArea(_aArea)
Return _cJson
