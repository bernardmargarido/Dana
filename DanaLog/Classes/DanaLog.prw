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
/*/{Protheus.doc} DanaLog
    @description Classe utilizada para o processo da DanaLog
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Class DanaLog

    Data cJSon      As String
    Data cJSonRet   As String
    Data cError     As String
    Data cToken     As String

    Data nCodeHttp  As Integer 
    Data nTExpires  As Integer

    Method New() Constructor
    Method Token()
    Method SetToken()
    Method GetToken()
    Method GetUserID()
    Method ClearObj()
End Class

/****************************************************************************************/
/*/{Protheus.doc} New
    @description Método construtor da classe 
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method New() Class DanaLog
    ::cJSon     := ""
    ::cError    := ""
    ::cJSonRet  := ""
    ::cToken    := ""

    ::nCodeHttp := 0
    ::nTExpires := 0

Return Nil 

/****************************************************************************************/
/*/{Protheus.doc} Token
    @description Retorna Token 
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method Token() Class DanaLog
Local _lRet     := .T. 

Local _oJSon    := Nil 
//--------------------------------+
// Valida se JSON veio preenchido | 
//--------------------------------+
If Empty(::cJSon)

    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "Usuário e senha não informados."
    _oJSon[#"access_token"] := ""

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Usuário e senha não informados."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.
EndIf

//---------------------+
// Desesserializa JSON | 
//---------------------+
_oJSon  := xFromJson(::cJSon)

If Empty(_oJSon[#"user"]) .Or. Empty(_oJSon[#"password"])

    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "Usuário ou senha não informados."
    _oJSon[#"access_token"] := ""

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Usuário ou senha não informados."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.
EndIf

//------------------------+
// Valida usuário e senha | 
//------------------------+
If !::GetUserID(_oJSon[#"user"],_oJSon[#"password"])
    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "Usuário ou senha incorreto."
    _oJSon[#"access_token"] := ""

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Usuário ou senha incorreto."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.
EndIf

//---------------+
// Retorna Token |
//---------------+
If _lRet 
    If ::SetToken(_oJSon[#"user"])
        _oJSon                  := Array(#)
        _oJSon[#"access_token"] := ::cToken
        _oJSon[#"token_type"]   := "Bearer"
        _oJSon[#"expires_in"]   := ::nTExpires

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := Nil
        ::nCodeHttp             := SUCESS
        _lRet                   := .T.
    Else
        _oJSon                  := Array(#)
        _oJSon[#"status"]       := "0"
        _oJSon[#"message"]      := "Usuário sem autorização."
        _oJSon[#"access_token"] := ""

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "Usuário sem autorização."
        ::nCodeHttp             := BADREQUEST
        _lRet                   := .F.
    EndIf
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} GetUserID
    @description Metodo - Valida usuario e senha
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method GetUserID(_cUser,_cPassword) Class DanaLog
Local _cQuery   := ""
Local _cAlias   := ""

Local _lRet     := .T. 

_cQuery := " SELECT " + CRLF
_cQuery += "	XT1.R_E_C_N_O_ RECNOXT1, " + CRLF
_cQuery += "	XT2.R_E_C_N_O_ RECNOXT2 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	XT1020 XT1 " + CRLF
_cQuery += "	INNER JOIN XT2020 XT2 ON XT2.XT2_FILIAL = '" + xFilial("XT2") + "' AND XT2.XT2_IDLOG  = XT1.XT1_IDLOG AND XT2.XT2_SENHA  = '" + RTrim(_cPassword) + "' AND XT2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	XT1.XT1_FILIAL = '" + xFilial("XT1") + "' AND " + CRLF
_cQuery += "	XT1.XT1_IDLOG = '" + RTrim(_cUser) + "' AND " + CRLF
_cQuery += "	XT1.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    _lRet     := .F. 
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} SetToken
    @description Metodo - Gera um novo Token
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method SetToken(_cUser) Class DanaLog
Local _lRet     := .T.


Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} GetToken
    @description Metodo - Valida Token
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method GetToken() Class DanaLog
Return _lRet 