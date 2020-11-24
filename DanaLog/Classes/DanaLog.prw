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
    Data cAuth      As String
    Data cMetodo    As String
    Data cHoraExp   As String

    Data nCodeHttp  As Integer 
    Data nTExpires  As Integer

    Data dDtaExp    As Date 

    Method New() Constructor
    Method Token()
    Method SetToken()
    Method ValidaToken()
    Method GetUserID()
    Method GeraToken()
    Method Produto()
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
    ::cAuth     := ""
    ::cMetodo   := ""
    ::cHoraExp  := ""

    ::nCodeHttp := 0
    ::nTExpires := 0

    ::dDtaExp   := Nil 

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

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Usuário e senha não informados."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.
EndIf

//---------------------+
// Desesserializa JSON | 
//---------------------+
_oJSon  := xFromJson(::cJSon)

//--------------------------------------------------+
// Valida se usuário ou senha não estão preenchidos |
//--------------------------------------------------+
If Empty(_oJSon[#"user"]) .Or. Empty(_oJSon[#"password"])

    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "Usuário ou senha não informados."

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
_cQuery += "	" + RetSqlName("XT1") + " XT1 " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("XT2") + " XT2 ON XT2.XT2_FILIAL = '" + xFilial("XT2") + "' AND XT2.XT2_IDLOG  = XT1.XT1_IDLOG AND XT2.XT2_SENHA  = '" + RTrim(_cPassword) + "' AND XT2.D_E_L_E_T_ = '' " + CRLF
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

Local _cHoraIni := ""

Local _dDtaIni  := ""

Local _nTExpired:= 0
//-----------------------------------+
// Posiciona configurações de acesso |
//-----------------------------------+
dbSelectArea("XT2")
XT2->( dbSetOrder(1) )
If !XT2->(dbSeek(xFilial("XT2") + _cUser) )
    Return _lRet 
EndIf

//-------------------------------+
// Parametros para gerar o Token | 
//-------------------------------+
_cHoraIni   := Time()
_dDtaIni    := Date()
_nTExpired  := XT2->XT2_TMPAPI
::nTExpires := XT2->XT2_TMPAPI

//-------------------+
// Rotina cria token | 
//-------------------+
If ::GeraToken(_cUser,_cHoraIni,_dDtaIni,_nTExpired)
    RecLock("XT2",.F.)
        XT2->XT2_DATA := ::dDtaExp
        XT2->XT2_HORA := ::cHoraExp
        XT2->XT2_TOKEN:= ::cToken
    XT2->( MsUnLock() )
EndIf 

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} GeraToken
    @description Metodo - Gera novo token
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method GeraToken(_cUser,_cHoraIni,_dDtaIni,_nTExpired) Class DanaLog
Local _lRet         := .T.

Local _cHeader		:= ""
Local _cPayLoad		:= ""
Local _cSecret		:= ""
Local _cHoraFim		:= ""
Local _cHrAux		:= ""
Local _cToken		:= ""

Local _dDtaFim		:= Nil

Local _nTimeOut		:= _nTExpired
Local _nHoras		:= (_nTimeOut/3600)
Local _nSumDay		:= 0
Local _oHeader		:= Nil
Local _oPayLoad		:= Nil

//---------------------------+
// Calcula data e hora final |
//---------------------------+
_cHrAux 	:= Alltrim(StrZero(_nHoras,2)) + SubStr(_cHoraIni,3)
_cHoraFim	:= SumTime(_cHoraIni,_cHrAux,@_nSumDay)

//------------------------------+
// Calcula data que expira token| 
//------------------------------+
If _nSumDay > 0
	_dDtaFim	:= DaySum(Date(),_nSumDay)
Else
	_dDtaFim	:= Date()
EndIf	

//-------------+
// Cria Header |
//-------------+
_oHeader			:= Array(#)
_oHeader[#"alg"]	:= "HS256"
_oHeader[#"typ"]	:= "JWT"

_cHeader			:= xToJson(_oHeader)

//--------------+
// Cria Payload |
//--------------+
_oPayLoad			:= Array(#)
_oPayLoad[#"iss"]	:= GetServerIP()
_oPayLoad[#"iat"]	:= FWTimeStamp(4, _dDtaIni, Time())
_oPayLoad[#"exp"]	:= FWTimeStamp(4, _dDtaFim, Time())
_oPayLoad[#"sub"]	:= _cUser
_oPayLoad[#"dtf"]	:= dTos(_dDtaFim)
_oPayLoad[#"hrf"]	:=_cHoraFim

_cPayLoad			:= xToJson(_oPayLoad)

//---------------------------------------------------------------------------------------------------------+
// HMAC( < cContent >, < cKey >, < nCryptoType >, [ nRetType ], [ nContentType ], [ nKeyType ] )           |
// https://tdn.totvs.com/display/tec/HMAC                                                                  |
//---------------------------------------------------------------------------------------------------------+

//------------+
// Gera Token | 
//------------+
_cHeader	:= Encode64(_cHeader)
_cPayLoad	:= StrTran(Encode64(_cPayLoad),"=","")
_cSecret	:= HMAC(_cHeader + "." + _cPayLoad, _cHeader , 5, 2)
_cToken		:= _cHeader + "." + _cPayLoad + "." + _cSecret

::cToken    := _cToken
::cHoraExp  := _cHoraFim
::dDtaExp   := _dDtaFim

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} ValidaToken
    @description Metodo - Valida Token
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method ValidaToken() Class DanaLog
Local _lRet     := .T.

Local _cHeader  := ""
Local _cPayLoad := ""
Local _cSecret  := ""
Local _cUser    := ""
Local _cTime	:= Time()

Local _dDta		:= dTos(Date())

Local _aToken   := {}

Local _oJson    := Nil 

//-------------------------------------------------+
// Valida se tipo de autenticação é do tipo Bearer |
//-------------------------------------------------+
If At("Bearer",::cAuth) == 0
    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "Tipo de autenticação inválida."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Tipo de autenticação inválida."
    ::nCodeHttp             := BADREQUEST
    Return .F.
EndIf

//---------------------+
// Separa token JWT    |
// _aToken[1] = Header |
// _aToken[2] = Payload|
// _aToken[3] = Secret |
//---------------------+
_aToken     := Separa(SubStr(::cAuth,8),".")
_cHeader    := _aToken[1]
_cPayLoad   := _aToken[2]
_cSecret    := _aToken[3]

//----------------+
// Decode Payload |
//----------------+
_cPayLoad			:= Decode64(_aToken[2])
_oJson  			:= xFromJson(_cPayLoad)
_cUser              := _oJson[#"sub"]

//--------------------+
// Valida data e hora | 
//--------------------+
If _dDta >= _oJson[#"dtf"] .And. _cTime > _oJson[#"hrf"]
    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "Token expirado."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Token expirado."
    ::nCodeHttp             := BADREQUEST
    Return .F.
EndIf

//----------------+
// Valida usuário | 
//----------------+
dbSelectArea("XT2")
XT2->( dbSetOrder(1) )
If !XT2->( dbSeek(xFilial("XT2") + _cUser) )
    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "Dados do token inválidos."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Dados do token inválidos."
    ::nCodeHttp             := BADREQUEST
    Return .F.
EndIf

//--------------+
// Valida Token |
//--------------+
If RTrim(SubStr(::cAuth,8)) <> RTrim(XT2->XT2_TOKEN)
    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "Token inválido."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Token inválido."
    ::nCodeHttp             := BADREQUEST
    Return .F.
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} ValidaToken
    @description Metodo - Valida Token
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method Produto() Class DanaLog
Local _aArea    := GetArea()

Local _lRet     := .T.

//--------------+
// Valida Token | 
//--------------+
If !::ValidaToken()
    RestArea(_aArea)
    Return .F.
EndIf

//--------------------------------+
// Valida se JSON veio preenchido | 
//--------------------------------+
If Empty(::cJSon)
    _oJSon                  := Array(#)
    _oJSon[#"status"]       := "1"
    _oJSon[#"message"]      := "JSON não enviado."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "JSON não enviado."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.
EndIf



RestArea(_aArea)
Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} SumTime
	@description Soma Hora
	@type  Function
	@author Bernard M. Margarido
	@since 23/07/2019
	@version 1.0
/*/
/*************************************************************************************/
Static Function SumTime(_cHoraIni,_cHrAux,_nSumDay)
Local _cNewHora	:= ""
Local _cSegundo	:= ""
Local _cMinuto	:= ""
Local _cHora	:= ""

Local _nSeg01	:= 0
Local _nMin01	:= 0
Local _nHr01	:= 0
Local _nTotHr01	:= 0
Local _nSeg02	:= 0
Local _nMin02	:= 0
Local _nHr02	:= 0	
Local _nTotHr02	:= 0
Local _nTotHr  	:= 0

//----------------------------+
// Converte horas em segundos |
// Calcula total hora 01	  |	
//----------------------------+
_nHr01		:= Val(Left(_cHoraIni,2)) * 3600
_nMin01		:= Val(SubStr(_cHoraIni,4,2)) * 60
_nSeg01		:= Val(Right(_cHoraIni,2))
_nTotHr01	:= _nHr01 + _nMin01 + _nSeg01

//----------------------------+
// Converte horas em segundos |
// Calcula total hora 02	  |	
//----------------------------+
_nHr02		:= Val(Left(_cHrAux,2)) * 3600
_nMin02		:= Val(SubStr(_cHrAux,4,2)) * 60
_nSeg02		:= Val(Right(_cHrAux,2))
_nTotHr02	:= _nHr02 + _nMin02 + _nSeg02
_nTotHr		:= _nTotHr01 + _nTotHr02

//------------------+
// Calcula de Horas |
//------------------+
If Int(_nTotHr / 3600) > 24
	_nSumDay	:= 1
	_cHora		:= StrZero(Int(_nTotHr / 3600) - 24,2)
Else	
	_cHora		:= StrZero(Int(_nTotHr / 3600),2)
EndIf
_nTotHr		:= Mod(_nTotHr,3600)
_cMinuto	:= StrZero(Int(_nTotHr/60),2)
_cSegundo	:= StrZero(Int(Mod(_nTotHr,60)),2)
_cNewHora	:= _cHora + ":" + _cMinuto + ":" + _cSegundo

Return _cNewHora
