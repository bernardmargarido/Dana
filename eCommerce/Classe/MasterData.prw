#INCLUDE "TOTVS.CH"

/*********************************************************************************************/
/*/{Protheus.doc} MasterData
    @description Classe - Responsavel pela conexão e integração de dados de clientes
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/*********************************************************************************************/
Class MasterData
    
    Data cIdLoja    As String
    Data cJSonRet   As String
    Data cId        As String 
    Data cMetodo    As String 
    Data cError     As String 
    Data cUrl       As String 
    Data cAppKey    As String 
    Data cAppToken  As String 

    Method New() Constructor 
    Method Token()
    Method Customer() 
    Method Address()

EndClass

/*********************************************************************************************/
/*/{Protheus.doc} New
    @description Metodo New - Contrutor da classe 
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/*********************************************************************************************/
Method New() Class MasterData
    
    Self:cIdLoja    := "001"
    Self:cJSonRet   := ""
    Self:cId        := ""
    Self:cMetodo    := ""
    Self:cError     := ""
    Self:cUrl       := ""
    Self:cAppKey    := ""
    Self:cAppToken  := ""

Return Nil 

/*********************************************************************************************/
/*/{Protheus.doc} Token
    @description Metodo - Busca token de acesso as API's VTEX
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/*********************************************************************************************/
Method Token() Class MasterData
Local _lRet     := .T.

dbSelectArea("XTC")
XTC->( dbSetOrder(1) )
If XTC->( dbSeek(xFilial("XTC") + Self:cIdLoja) )
    Self:cUrl       := RTrim(XTC->XTC_URL2)
    Self:cAppKey    := RTrim(XTC->XTC_APPKEY)
    Self:cAppToken  := RTrim(XTC->XTC_APPTOK)
EndIf 

Return _lRet 

/*********************************************************************************************/
/*/{Protheus.doc} Customer
    @description Metodo - Retorna dados dos clientes
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/*********************************************************************************************/
Method Customer() Class MasterData
Local _lRet     := .T.

Local _cParam   := ""

Local _aHeadOut := {}

Local _oFwRest  := Nil 
Local _oJSon    := Nil 

//---------------+
// Retorna Token |
//---------------+
Self:Token()

//--------------+
// Header Token |
//--------------+
aAdd(_aHeadOut,"Content-Type: application/json")
aAdd(_aHeadOut,"X-VTEX-API-AppKey: " + Self:cAppKey)
aAdd(_aHeadOut,"X-VTEX-API-AppToken: " + Self:cAppToken)

//----------+
// EndPoint |
//----------+
_oFwRest  := FWRest():New(Self:cUrl)

//---------+
// Timeout |
//---------+
_oFwRest:nTimeOut := 600

//----------------------+
// Método a ser chamado | 
//----------------------+
If Self:cMetodo == "GET"
    _cParam := "_where=document="+ RTrim(self:cId) + "&_fields=_all"
    _oFwRest:SetPath("/api/dataentities/CL/search?" + _cParam)

    If _oFwRest:Get(_aHeadOut)
        Self:cJSonRet	:= DecodeUtf8(_oFwRest:GetResult())
        _lRet           := .T.
    Else
        Self:cJSonRet	:= DecodeUtf8(_oFwRest:GetResult())
        _oJSon          := JSonObject():New()
        _oJSon:FromJson(Self:cJSonRet)
        Self:cError     := _oJSon['Message']
        _lRet           := .F.
    EndIf 
ElseIf Self:cMetodo == "PUT"

EndIf 

FreeObj(_oFwRest)
FreeObj(_oJSon)
Return _lRet 

/*********************************************************************************************/
/*/{Protheus.doc} Customer
    @description Metodo - Retorna dados dos clientes
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/*********************************************************************************************/
Method Address() Class MasterData
Local _lRet     := .T.

Local _cParam   := ""

Local _aHeadOut := {}

Local _oFwRest  := Nil 
Local _oJSon    := Nil 

//---------------+
// Retorna Token |
//---------------+
Self:Token()

//--------------+
// Header Token |
//--------------+
aAdd(_aHeadOut,"Content-Type: application/json")
aAdd(_aHeadOut,"X-VTEX-API-AppKey: " + Self:cAppKey)
aAdd(_aHeadOut,"X-VTEX-API-AppToken: " + Self:cAppToken)

//----------+
// EndPoint |
//----------+
_oFwRest  := FWRest():New(Self:cUrl)

//---------+
// Timeout |
//---------+
_oFwRest:nTimeOut := 600

//----------------------+
// Método a ser chamado | 
//----------------------+
If Self:cMetodo == "GET"
    _cParam := "_where=userId="+ RTrim(self:cId) + "&_fields=_all"
    _oFwRest:SetPath("/api/dataentities/AD/search?" + _cParam)

    If _oFwRest:Get(_aHeadOut)
        Self:cJSonRet	:= DecodeUtf8(_oFwRest:GetResult())
        _lRet           := .T.
    Else
        Self:cJSonRet	:= DecodeUtf8(_oFwRest:GetResult())
        _oJSon          := JSonObject():New()
        _oJSon:FromJson(Self:cJSonRet)
        Self:cError     := _oJSon['Message']
        _lRet           := .F.
    EndIf 
EndIf 

FreeObj(_oFwRest)
FreeObj(_oJSon)
Return _lRet 
