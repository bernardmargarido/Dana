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

Static _nTProd  := TamSx3("B1_COD")[1]
Static _nTCNPJ  := TamSx3("A1_CGC")[1]
Static _nTPedD  := TamSx3("C5_XNUMDL")[1]
Static _nTNota  := TamSx3("F1_DOC")[1]
Static _nTSerie := TamSx3("F1_SERIE")[1]
Static _nTDoc   := TamSx3("F2_DOC")[1]

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
    Data cCodigo    As String
    Data cIdCliente As String
    Data cPage      As String 
    Data cPerPage   As String
    Data cCnpj      As String
    Data cNota      As String 
    Data cSerie     As String

    Data nCodeHttp  As Integer 
    Data nTExpires  As Integer
    Data nTotPage   As Integer
    Data nTotQry    As Integer

    Data dDtaExp    As Date 

    Method New() Constructor
    Method Token()
    Method SetToken()
    Method ValidaToken()
    Method GetJSon()
    Method GetUserID()
    Method GeraToken()
    Method Produtos()
    Method Clientes()
    Method Fornecedor()
    Method Transportadora()
    Method Recebimento()
    Method Pedido()
    Method Remessa()
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
    ::cCodigo   := ""
    ::cIdCliente:= ""
    ::cPage     := ""
    ::cPerPage  := ""
    ::cCnpj     := ""

    ::nTotPage  := 0
    ::nTotQry   := 0
    ::nCodeHttp := 0
    ::nTExpires := 0

    ::dDtaExp   := Nil 

Return Nil 

/****************************************************************************************/
/*/{Protheus.doc} GetJSon
    @description Metodo - Monta JSON de retorno 
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method GetJSon() Class DanaLog
Local _nX       := 0

Local _oJSon    := Nil 
Local _oMessage := Nil 

_oJSon                  := Array(#)
_oJSon[#"messages"]     := {}
For _nX := 1 To Len(_aMsgErro)
    aAdd(_oJson[#"messages"],Array(#))
    _oMessage                   := aTail(_oJson[#"messages"])
    _oMessage[#"status"]        := _aMsgErro[_nX][1]
    _oMessage[#"codigo"]        := _aMsgErro[_nX][2]
    _oMessage[#"message"]       := _aMsgErro[_nX][3]
Next _nX 

::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
::cError                := ""
::nCodeHttp             := SUCESS

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

    _oJSon                              := Array(#)
    _oJSon[#"messages"]                 := Array(#)
    _oJSon[#"messages"][#"status"]      := "1"
    _oJSon[#"messages"][#"message"]     := "Usuário e senha não informados."

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

    _oJSon                          := Array(#)
    _oJSon[#"messages"]             := Array(#)
    _oJSon[#"messages"][#"status"]  := "1"
    _oJSon[#"messages"][#"message"] := "Usuário ou senha não informados."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Usuário ou senha não informados."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.
EndIf

//------------------------+
// Valida usuário e senha | 
//------------------------+
If !::GetUserID(_oJSon[#"user"],_oJSon[#"password"])
    _oJSon                              := Array(#)
    _oJSon[#"messages"]                 := Array(#)
    _oJSon[#"messages"][#"status"]      := "1"
    _oJSon[#"messages"][#"message"]     := "Usuário ou senha incorreto."

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
        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "0"
        _oJSon[#"messages"][#"message"] := "Usuário sem autorização."

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
Local _cTime	:= Time()

Local _dDta		:= dTos(Date())

Local _aToken   := {}

Local _oJson    := Nil 
Local _oJSonRet := Nil 

//-------------------------------------------------+
// Valida se tipo de autenticação é do tipo Bearer |
//-------------------------------------------------+
If At("Bearer",::cAuth) == 0
    _oJSonRet                          := Array(#)
    _oJSonRet[#"messages"]             := Array(#)
    _oJSonRet[#"messages"][#"status"]  := "1"
    _oJSonRet[#"messages"][#"message"] := "Tipo de autenticação inválida."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSonRet))
    ::cError                := "Tipo de autenticação inválida."
    ::nCodeHttp             := BADREQUEST

    CoNout("<< DANALOG >> VALIDATOKEN - TIPO DE AUTENTICACAO INVALIDA")    

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
::cIdCliente        := _oJson[#"sub"]

//--------------------+
// Valida data e hora | 
//--------------------+
If ( _dDta > _oJson[#"dtf"] ) .Or. ( _cTime > _oJson[#"hrf"] )
    _oJSonRet                          := Array(#)
    _oJSonRet[#"messages"]             := Array(#)
    _oJSonRet[#"messages"][#"status"]  := "1"
    _oJSonRet[#"messages"][#"message"] := "Token expirado."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSonRet))
    ::cError                := "Token expirado."
    ::nCodeHttp             := BADREQUEST

    CoNout("<< DANALOG >> VALIDATOKEN - TOKEN EXPIRADO")    

    Return .F.
EndIf

//----------------+
// Valida usuário | 
//----------------+
dbSelectArea("XT2")
XT2->( dbSetOrder(1) )
If !XT2->( dbSeek(xFilial("XT2") + ::cIdCliente) )
    _oJSonRet                          := Array(#)
    _oJSonRet[#"messages"]             := Array(#)
    _oJSonRet[#"messages"][#"status"]  := "1"
    _oJSonRet[#"messages"][#"message"] := "Dados do token inválidos."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSonRet))
    ::cError                := "Dados do token inválidos."
    ::nCodeHttp             := BADREQUEST
    
    CoNout("<< DANALOG >> VALIDATOKEN - DADOS DO TOKEN INVALIDO")    

    Return .F.
EndIf

//--------------+
// Valida Token |
//--------------+
If RTrim(SubStr(::cAuth,8)) <> RTrim(XT2->XT2_TOKEN)
    _oJSonRet                          := Array(#)
    _oJSonRet[#"messages"]             := Array(#)
    _oJSonRet[#"messages"][#"status"]  := "1"
    _oJSonRet[#"messages"][#"message"] := "Token inválido."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSonRet))
    ::cError                := "Token inválido."
    ::nCodeHttp             := BADREQUEST

    CoNout("<< DANALOG >> VALIDATOKEN - TOKEN INVALIDO")    

    Return .F.
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Produtos
    @description Metodo - Grava / Atualiza e consulta produtos DanaLog
    @author    Bernard M. Margarido
    @since     22/11/2020
/*/
/****************************************************************************************/
Method Produtos() Class DanaLog
Local _aArea        := GetArea()

Local _cRest        := ""

Local _lRet         := .T.

Private _aMsgErro   := {}

//--------------+
// Valida Token | 
//--------------+
If !::ValidaToken()
    RestArea(_aArea)
    Return .F.
EndIf

//---------------+
// Metodo - POST |
//---------------+
If ::cMetodo == "POST"
    CoNout("<< DANALOG >> PRODUTOS - METODO POST ")    

    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)
        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST
        
        RestArea(_aArea)
        Return .F.

        CoNout("<< DANALOG >> PRODUTOS - JSON NAO ENVIADO ")    

    EndIf

    Begin Transaction 
        ProdutoPost(::cJSon,3)
    End Transaction 
//--------------+
// Metodo - PUT |
//--------------+
ElseIf ::cMetodo == "PUT"
    CoNout("<< DANALOG >> PRODUTOS - METODO PUT ")    

    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)
        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST

        RestArea(_aArea)
        Return .F.

        CoNout("<< DANALOG >> PRODUTOS - JSON NAO ENVIADO ")    

    EndIf

    Begin Transaction 
        ProdutoPost(::cJSon,4)
    End Transaction
//--------------+
// Metodo - GET |
//--------------+
ElseIf ::cMetodo == "GET"
    CoNout("<< DANALOG >> PRODUTOS - METODO GET ")    
    //------------------------------+
    // Valida se ID veio preenchido | 
    //------------------------------+
    If Empty(::cIdCliente)
        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "ID cliente não preenchido."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "ID cliente não preenchido."
        ::nCodeHttp             := BADREQUEST

        RestArea(_aArea)
        Return .F.

        CoNout("<< DANALOG >> PRODUTOS - JSON NAO ENVIADO ")    

    EndIf
    ProdutoGet(::cCodigo,::cIdCliente,::cPage,::cPerPage,@_cRest)
EndIf

//----------------+
// Array de erros |
//----------------+
If Len(_aMsgErro) > 0 .And. Empty(_cRest)
    ::GetJSon()
ElseIf !Empty(_cRest) .And. Len(_aMsgErro) == 0
    ::cJSonRet              := _cRest
    ::cError                := ""
    ::nCodeHttp             := SUCESS
EndIf

RestArea(_aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Clientes
    @description Realiza a atualização dos clientes logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/****************************************************************************************/
Method Clientes() Class DanaLog
Local _aArea        := GetArea()

Local _cRest        := ""

Local _lRet         := .T.

Private _aMsgErro   := {}

//--------------+
// Valida Token | 
//--------------+
If !::ValidaToken()
    RestArea(_aArea)
    Return .F.
EndIf

//---------------+
// Metodo - POST |
//---------------+
If ::cMetodo == "POST"
    CoNout("<< DANALOG >> CLIENTES - METODO POST ")    

    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)
        CoNout("<< DANALOG >> CLIENTES - JSON NAO ENVIADO ")    

        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST

        RestArea(_aARea)
        Return .F.
    EndIf

    Begin Transaction 
        ClientesP(::cJSon,3)
    End Transaction 
//--------------+
// Metodo - PUT |
//--------------+
ElseIf ::cMetodo == "PUT"
    CoNout("<< DANALOG >> CLIENTES - METODO PUT ")    

    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)
        CoNout("<< DANALOG >> CLIENTES - JSON NAO ENVIADO ")    

        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST

        RestArea(_aARea)
        Return .F.
    EndIf

    Begin Transaction 
        ClientesP(::cJSon,4)
    End Transaction
//--------------+
// Metodo - GET |
//--------------+
ElseIf ::cMetodo == "GET"
    CoNout("<< DANALOG >> CLIENTES - METODO GET ")    
    ClientesG(::cCnpj,::cIdCliente,::cPage,::cPerPage,@_cRest)
EndIf

//----------------+
// Array de erros |
//----------------+
If Len(_aMsgErro) > 0 .And. Empty(_cRest)
    ::GetJSon()
ElseIf !Empty(_cRest) .And. Len(_aMsgErro) == 0
    ::cJSonRet              := _cRest
    ::cError                := ""
    ::nCodeHttp             := SUCESS
EndIf

RestArea(_aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Fornecedor
    @description Realiza a atualização dos fornecedores logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/****************************************************************************************/
Method Fornecedor() Class DanaLog
Local _aArea        := GetArea()

Local _cRest        := ""

Local _lRet         := .T.

Private _aMsgErro   := {}

//--------------+
// Valida Token | 
//--------------+
If !::ValidaToken()
    RestArea(_aArea)
    Return .F.
EndIf

//---------------+
// Metodo - POST |
//---------------+
If ::cMetodo == "POST"
    CoNout("<< DANALOG >> FORNECEDOR - METODO POST ")    

    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)   
        CoNout("<< DANALOG >> FORNECEDOR - JSON NAO ENVIADO ")    

        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST
        
        RestArea(_aArea)
        Return .F.
    EndIf

    Begin Transaction 
        ForneceP(::cJSon,3)
    End Transaction 
//--------------+
// Metodo - PUT |
//--------------+
ElseIf ::cMetodo == "PUT"
    CoNout("<< DANALOG >> FORNECEDOR - METODO PUT ")    

    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)   
        CoNout("<< DANALOG >> FORNECEDOR - JSON NAO ENVIADO ")    
        
        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST
        
        RestArea(_aArea)
        Return .F.
    EndIf

    Begin Transaction 
        ForneceP(::cJSon,4)
    End Transaction
//--------------+
// Metodo - GET |
//--------------+
ElseIf ::cMetodo == "GET"
    CoNout("<< DANALOG >> FORNECEDOR - METODO GET ")    
    ForneceG(::cCnpj,::cIdCliente,::cPage,::cPerPage,@_cRest)
EndIf

//----------------+
// Array de erros |
//----------------+
If Len(_aMsgErro) > 0 .And. Empty(_cRest)
    ::GetJSon()
ElseIf !Empty(_cRest) .And. Len(_aMsgErro) == 0
    ::cJSonRet              := _cRest
    ::cError                := ""
    ::nCodeHttp             := SUCESS
EndIf

RestArea(_aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Transportadora
    @description Metodo realiza a gravação/atualização das transportadoras logisticas
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/****************************************************************************************/
Method Transportadora() Class DanaLog
Local _aArea        := GetArea()

Local _cRest        := ""

Local _lRet         := .T.

Private _aMsgErro   := {}

//--------------+
// Valida Token | 
//--------------+
If !::ValidaToken()
    RestArea(_aArea)
    Return .F.
EndIf

//---------------+
// Metodo - POST |
//---------------+
If ::cMetodo == "POST"
    CoNout("<< DANALOG >> TRANSPORTADORA - METODO POST ")    
    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)
        CoNout("<< DANALOG >> TRANSPORTADORA - JSON NAO ENVIADO ")    

        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST
        
        RestArea(_aArea)
        Return .F.  

    EndIf

    Begin Transaction 
        TransportP(::cJSon,3)
    End Transaction 
//--------------+
// Metodo - PUT |
//--------------+
ElseIf ::cMetodo == "PUT"
    CoNout("<< DANALOG >> TRANSPORTADORA - METODO PUT ")    

    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)
        CoNout("<< DANALOG >> TRANSPORTADORA - JSON NAO ENVIADO ")    

        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST
        
        RestArea(_aArea)
        Return .F.  

    EndIf

    Begin Transaction 
        TransportP(::cJSon,4)
    End Transaction
//--------------+
// Metodo - GET |
//--------------+
ElseIf ::cMetodo == "GET"
    CoNout("<< DANALOG >> TRANSPORTADORA - METODO GET ")    
    TransportG(::cCnpj,::cIdCliente,::cPage,::cPerPage,@_cRest)
EndIf

//----------------+
// Array de erros |
//----------------+
If Len(_aMsgErro) > 0 .And. Empty(_cRest)
    ::GetJSon()
ElseIf !Empty(_cRest) .And. Len(_aMsgErro) == 0
    ::cJSonRet              := _cRest
    ::cError                := ""
    ::nCodeHttp             := SUCESS
EndIf

RestArea(_aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Recebimento
    @description Realiza a gravação do produto cliente logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/****************************************************************************************/
Method Recebimento() Class DanaLog
Local _aArea        := GetArea()

Local _cRest        := ""

Local _lRet         := .T.

Private _aMsgErro   := {}

//--------------+
// Valida Token | 
//--------------+
If !::ValidaToken()
    RestArea(_aArea)
    Return .F.
EndIf

//---------------+
// Metodo - POST |
//---------------+
If ::cMetodo == "POST"
    CoNout("<< DANALOG >> RECEBIMENTO - METODO POST ")    

    //--------------------------------+
    // Valida se JSON veio preenchido | 
    //--------------------------------+
    If Empty(::cJSon)
        CoNout("<< DANALOG >> RECEBIMENTO - JSON NAO ENVIADO ")    

        _oJSon                          := Array(#)
        _oJSon[#"messages"]             := Array(#)
        _oJSon[#"messages"][#"status"]  := "1"
        _oJSon[#"messages"][#"message"] := "JSON não enviado."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "JSON não enviado."
        ::nCodeHttp             := BADREQUEST

        RestArea(_aArea)
        Return .F.   
    EndIf

    Begin Transaction 
        EntradaP(::cJSon,3)
    End Transaction 
//--------------+
// Metodo - GET |
//--------------+
ElseIf ::cMetodo == "GET"
    CoNout("<< DANALOG >> RECEBIMENTO - METODO GET ")    
    EntradaG(::cNota,::cSerie,::cIdCliente,::cPage,::cPerPage,@_cRest)
EndIf

//----------------+
// Array de erros |
//----------------+
If Len(_aMsgErro) > 0 .And. Empty(_cRest)
    ::GetJSon()
ElseIf !Empty(_cRest) .And. Len(_aMsgErro) == 0
    ::cJSonRet              := _cRest
    ::cError                := ""
    ::nCodeHttp             := SUCESS
EndIf

RestArea(_aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Pedido
    @description Realiza a gravação de pedidos de remessa
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/****************************************************************************************/
Method Pedido() Class DanaLog
Local _aArea        := GetArea()

Local _cRest        := ""

Local _lRet         := .T.

Private _aMsgErro   := {}

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
    _oJSon                          := Array(#)
    _oJSon[#"messages"]             := Array(#)
    _oJSon[#"messages"][#"status"]  := "1"
    _oJSon[#"messages"][#"message"] := "JSON não enviado."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "JSON não enviado."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.

    CoNout("<< DANALOG >> PEDIDOREMESSA - JSON NAO ENVIADO ")    

EndIf

//---------------+
// Metodo - POST |
//---------------+
If ::cMetodo == "POST"
    CoNout("<< DANALOG >> PEDIDOREMESSA - METODO POST ")    
    Begin Transaction 
        PedidoP(::cJSon,3)
    End Transaction 
//--------------+
// Metodo - GET |
//--------------+
ElseIf ::cMetodo == "GET"
    CoNout("<< DANALOG >> PEDIDOREMESSA - METODO GET ")    
    PedidoG(::cPedido,::cIdCliente,@_cRest)
EndIf

//----------------+
// Array de erros |
//----------------+
If Len(_aMsgErro) > 0 .And. Empty(_cRest)
    ::GetJSon()
ElseIf !Empty(_cRest) .And. Len(_aMsgErro) == 0
    ::cJSonRet              := _cRest
    ::cError                := ""
    ::nCodeHttp             := SUCESS
EndIf

RestArea(_aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Remessa
    @description Realiza a remessa dos pedidos DanaLog
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/****************************************************************************************/
Method Remessa() Class DanaLog
Local _aArea        := GetArea()

Local _cRest        := ""

Local _lRet         := .T.

Private _aMsgErro   := {}

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
    _oJSon                          := Array(#)
    _oJSon[#"messages"]             := Array(#)
    _oJSon[#"messages"][#"status"]  := "1"
    _oJSon[#"messages"][#"message"] := "JSON não enviado."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "JSON não enviado."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.

    CoNout("<< DANALOG >> REMESSA - JSON NAO ENVIADO ")    

EndIf

//---------------+
// Metodo - POST |
//---------------+
If ::cMetodo == "POST"
    CoNout("<< DANALOG >> REMESSA - METODO POST ")    
    Begin Transaction 
        RemessaP(::cJSon,3)
    End Transaction 
//--------------+
// Metodo - GET |
//--------------+
ElseIf ::cMetodo == "GET"
    CoNout("<< DANALOG >> REMESSA - METODO GET ")    
    RemessaG(::cPedido,::cIdCliente,@_cRest)
EndIf

//----------------+
// Array de erros |
//----------------+
If Len(_aMsgErro) > 0 .And. Empty(_cRest)
    ::GetJSon()
ElseIf !Empty(_cRest) .And. Len(_aMsgErro) == 0
    ::cJSonRet              := _cRest
    ::cError                := ""
    ::nCodeHttp             := SUCESS
EndIf

RestArea(_aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} CriaArmazem
    @description Realiza a gravação do produto cliente logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/****************************************************************************************/
Static Function CriaArmazem(_cCodProd,_cLocal,_cIDCliente)
Local _lRet     := .T.

dbSelectArea("SB2")
SB2->( dbSetOrder(1) )
If !SB2->( dbSeek(xFilial("SB2") + _cCodProd + _cLocal) )
    CriaSB2(_cCodProd,_cLocal)
EndIf

If SB2->( dbSeek(xFilial("SB2") + _cCodProd + _cLocal) )
    RecLock("SB2",.F.)
        SB2->B2_XIDLOGI := _cIDCliente
    SB2->( MsUnLock() )
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} ProdutoPost
    @description Realiza a gravação do produto cliente logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/****************************************************************************************/
Static Function ProdutoPost(_cJSon,_nOpc)
Local _cIDCliente       := ""
Local _cCodProd         := ""
Local _cDescri          := ""
Local _cTpProd          := ""
Local _cUnidade_1       := ""
Local _cUnidade_2       := ""
Local _cTpConv          := ""
Local _cCodBar          := ""
Local _cCodCaixa        := ""
Local _cArmazem         := ""
Local _cLote            := ""
Local _cNCM             := ""
Local _cTpEmb           := ""
Local _cBloq            := ""
Local _cMsgErro         := ""

Local _nFator           := 0
Local _nPesoLiq         := 0
Local _nPesoBru         := 0
Local _nAltura          := 0
Local _nLargura         := 0
Local _nCompr           := 0
Local _nPesLEmb         := 0
Local _nPesBEmb         := 0
Local _nAlturaE         := 0
Local _nLarguraE        := 0
Local _nComprE          := 0
Local _nQtdEmb          := 0
Local _nTotEmp          := 0
Local _nTotPalet        := 0
Local _nX               := 0 

Local _lRet             := .T.

Local _aArray           := {}
Local _aErroAuto        := {}

Local _oJSon            := Nil 
Local _oProduto         := Nil 

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

Default _nOpc           := 3

//------------------+
// Dados do produto |
//------------------+
_oJSon      := xFromJson(_cJSon)
_cIDCliente := _oJSon[#"id_cliente"]
_oProduto   := _oJSon[#"produtos"]

If ValType(_oProduto) == "A"

    //----------------+
    // SB1 - Produtos |
    //----------------+
    dbSelectArea("SB1")
    SB1->( dbOrderNickname("DANALOG") )

    //---------------------------------+
    // XT3 - Armazens Cliente Dana LOG |
    //---------------------------------+
    dbSelectArea("XT3")
    XT3->( dbSetOrder(1))

    For _nX := 1 To Len(_oProduto)
        
        _aArray     := {}

        _cCodProd   := _oProduto[_nX][#"codigo"]
        _cDescri    := _oProduto[_nX][#"descricao"]
        _cTpProd    := _oProduto[_nX][#"tipo_produto"]
        _cUnidade_1 := _oProduto[_nX][#"unidade"]
        _cUnidade_2 := _oProduto[_nX][#"unidade_2"]
        _nFator     := _oProduto[_nX][#"fator_conv"]
        _cTpConv    := _oProduto[_nX][#"tipo_conv"]
        _cCodBar    := _oProduto[_nX][#"codigo_barras"]
        _cCodCaixa  := _oProduto[_nX][#"codigo_barras_caixa"]
        _cArmazem   := GetArmazem(_cIDCliente,"1")
        _cLote      := _oProduto[_nX][#"lote"]
        _cNCM       := _oProduto[_nX][#"ncm"]
        _cBloq      := _oProduto[_nX][#"situacao"]
        _cOrigem    := _oProduto[_nX][#"origem"]
        _nPesoLiq   := _oProduto[_nX][#"peso_liquido"]
        _nPesoBru   := _oProduto[_nX][#"peso_bruto"]
        _nAltura    := _oProduto[_nX][#"altura"]
        _nLargura   := _oProduto[_nX][#"largura"]
        _nCompr     := _oProduto[_nX][#"comprimento"]
        _nPesLEmb   := _oProduto[_nX][#"peso_liquido_emb"]
        _nPesBEmb   := _oProduto[_nX][#"peso_bruto_emb"]
        _nAlturaE   := _oProduto[_nX][#"altura_embalagem"]
        _nLarguraE  := _oProduto[_nX][#"largura_embalagem"]
        _nComprE    := _oProduto[_nX][#"comprimento_embalagem"]
        _cTpEmb     := _oProduto[_nX][#"tipo_embalagem"]
        _nQtdEmb    := _oProduto[_nX][#"quantidade_embalagem"]
        _nTotEmp    := _oProduto[_nX][#"empilhamento_maximo"]
        _nTotPalet  := _oProduto[_nX][#"total_pallet"]

        //-----------------------------------+
        // Valida se produto está cadastrado | 
        //-----------------------------------+
        If SB1->( dbSeek(xFilial("SB1") + _cCodProd + _cIDCliente) ) .And. _nOpc == 3
            aAdd(_aMsgErro,{"1",RTrim(_cCodProd), "Produto já cadastrado favor utilizar o método PUT para atualização."})
            Loop 
        EndIf

        aAdd(_aArray, {"B1_FILIAL"  , xFilial("SB1")              , Nil })
        aAdd(_aArray, {"B1_COD"     , _cCodProd                   , Nil })
        aAdd(_aArray, {"B1_DESC"    , _cDescri                    , Nil })
        aAdd(_aArray, {"B1_TIPO"    , _cTpProd                    , Nil })
        aAdd(_aArray, {"B1_UM"      , _cUnidade_1                 , Nil })
        aAdd(_aArray, {"B1_SEGUM"   , _cUnidade_2                 , Nil })
        aAdd(_aArray, {"B1_CONV"    , _nFator                     , Nil })
        aAdd(_aArray, {"B1_TIPCONV" , _cTpConv                    , Nil })
        aAdd(_aArray, {"B1_CODGTIN" , _cCodBar                    , Nil })
        aAdd(_aArray, {"B1_XEANCX"  , _cCodCaixa                  , Nil })
        aAdd(_aArray, {"B1_LOCPAD"  , _cArmazem                   , Nil })
        aAdd(_aArray, {"B1_RASTRO"  , _cLote                      , Nil })
        aAdd(_aArray, {"B1_POSIPI"  , _cNCM                       , Nil })
        aAdd(_aArray, {"B1_PESO"    , _nPesoLiq                   , Nil })
        aAdd(_aArray, {"B1_PESBRU"  , _nPesoBru                   , Nil })
        aAdd(_aArray, {"B1_MSBLQL"  , IIF(_cBloq == "A","2","1")  , Nil })
        aAdd(_aArray, {"B1_ORIGEM"  , _cOrigem                    , Nil })
        aAdd(_aArray, {"B1_XIDLOGI" , _cIDCliente                 , Nil })

        lMsErroAuto := .F.
        MSExecAuto({|x,y| Mata010(x,y)}, _aArray, _nOpc)

        //--------------------------+
        // Erro gravação de produto | 
        //--------------------------+
        If lMsErroAuto  
            //-------------------+
            // Log erro ExecAuto |
            //-------------------+
            _aErroAuto := GetAutoGRLog()

            //------------------------------------+
            // Retorna somente a linha com o erro | 
            //------------------------------------+
            ErroAuto(_aErroAuto,@_cMsgErro)
            
            //------------------------+
            // Grava array de retorno | 
            //------------------------+
            aAdd(_aMsgErro,{"1",RTrim(_cCodProd), Alltrim(_cMsgErro)})
        //-----------------------------+
        // Produto gravado com sucesso | 
        //-----------------------------+
        Else
            
            //---------------------------------+ 
            // Adiciona complemento do produto | 
            //---------------------------------+
            If ProdutoCompl(_cIDCliente,_cCodProd,_cDescri,_nPesoLiq,_nPesoBru,_nAltura,_nLargura,;
                            _nCompr,_nPesLEmb,_nPesBEmb,_nAlturaE,_nLarguraE,_nComprE,;
                            _cTpEmb,_nQtdEmb,_nTotEmp,_nTotPalet,@_cMsgErro)
                //------------------------+
                // Grava array de retorno | 
                //------------------------+
                aAdd(_aMsgErro,{"0",RTrim(_cCodProd), "Produto gravado com sucesso."})
            EndIf

        EndIf
           
    Next _nX

EndIf

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} ProdutoGet
    @description Retorna dados do produto
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/11/2020
/*/
/*************************************************************************************/
Static Function ProdutoGet(_cCodigo,_cIdCliente,_cPage,_cPerPage,_cRest)
Local _cAlias       := ""

Local _lRet         := .T.

Local _oJSon        := Nil 
Local _oProduto     := Nil 

Private _nTotQry    := 0
Private _nTotPag    := 0

//------------------+
// Consulta produto |
//------------------+
If !PrdGetQry(@_cAlias,_cCodigo,_cIdCliente,_cPage,_cPerPage)
    aAdd(_aMsgErro,{"1",RTrim(_cCodigo), "Produto não localizado."})
    Return .F.
EndIf 

_oJSon              := Array(#)
_oJSon[#"produtos"] := {}

While (_cAlias)->( !Eof() )

    aAdd(_oJSon[#"produtos"],Array(#))
    _oProduto := aTail(_oJSon[#"produtos"])

    _oProduto[#"codigo"]                := (_cAlias)->CODIGO
	_oProduto[#"descricao"]             := (_cAlias)->DESCRICAO
	_oProduto[#"tipo_produto"]          := (_cAlias)->TIPO
	_oProduto[#"unidade"]               := (_cAlias)->UNIDADE
	_oProduto[#"unidade_2"]             := (_cAlias)->SEG_UNIDADE
	_oProduto[#"fator_conv"]            := (_cAlias)->FATOR
	_oProduto[#"tipo_conv"]             := (_cAlias)->TIPO_FATOR
	_oProduto[#"codigo_barras"]         := (_cAlias)->COD_BARRAS
	_oProduto[#"codigo_barras_caixa"]   := (_cAlias)->COD_CAIXA
	_oProduto[#"lote"]                  := (_cAlias)->RASTRO
	_oProduto[#"ncm"]                   := (_cAlias)->NCM
	_oProduto[#"situacao"]              := IIF((_cAlias)->SITUACAO == "1","I","A")
	_oProduto[#"origem"]                := (_cAlias)->ORIGEM
	_oProduto[#"peso_liquido"]          := (_cAlias)->PESO_LIQUIDO
	_oProduto[#"peso_bruto"]            := (_cAlias)->PESO_BRUTO
	_oProduto[#"altura"]                := (_cAlias)->ALTURA_PRODUTO
	_oProduto[#"largura"]               := (_cAlias)->LARGURA_PRODUTO
	_oProduto[#"comprimento"]           := (_cAlias)->COMP_PRODUTO
	_oProduto[#"peso_liquido_emb"]      := (_cAlias)->PESO_LIQUIDO
	_oProduto[#"peso_bruto_emb"]        := (_cAlias)->PESO_BRUTO
	_oProduto[#"altura_embalagem"]      := (_cAlias)->ALTURA_CAIXA
	_oProduto[#"largura_embalagem"]     := (_cAlias)->LARGURA_CAIXA
	_oProduto[#"comprimento_embalagem"] := (_cAlias)->COMP_CAIXA
	_oProduto[#"tipo_embalagem"]        := (_cAlias)->QTD_EMB
	_oProduto[#"quantidade_embalagem"]  := (_cAlias)->QTD_QE
    _oProduto[#"caixas_camada"]         := (_cAlias)->FATARMA
	_oProduto[#"empilhamento_maximo"]   := (_cAlias)->EMPMAX0
	_oProduto[#"total_pallet"]          := (_cAlias)->EMPMAX0 * (_cAlias)->FATARMA

    (_cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
_oJSon[#"pagina"]								:= Array(#)
_oJSon[#"pagina"][#"total_itens_pagina"]		:= Val(_cPerPage)
_oJSon[#"pagina"][#"total_produtos"]			:= _nTotQry
_oJSon[#"pagina"][#"total_paginas"]				:= _nTotPag
_oJSon[#"pagina"][#"pagina_atual"]				:= Val(_cPage)
//--------------+
// Cria retorno | 
//--------------+
_cRest  := EncodeUTF8(xToJson(_oJSon))

//---------------------+
// Encerra temposrário |
//---------------------+
(_cAlias)->( dbCloseArea() )

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} ClientesP
    @description Realiza a gravação e atualização de clientes logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/11/2020
/*/
/*************************************************************************************/
Static Function ClientesP(_cJSon,_nOpc)
Local _cCodCli          := ""
Local _cLoja            := ""
Local _cTipo            := ""
Local _cTipo_Cli        := ""
Local _cCnpj            := ""
Local _cNome            := ""
Local _cFantasia        := ""
Local _cInscR           := ""
Local _cCep             := ""
Local _cEndereco        := ""
Local _cNumero          := ""
Local _cComple          := ""
Local _cBairro          := ""
Local _cMunicipio       := ""
Local _cUF              := ""
Local _cDDD             := ""
Local _cTelefone        := ""
Local _cEMail           := ""
Local _cSituacao        := ""
Local _cMsgErro         := ""
Local _cClassif         := "001"
Local _cAtivo           := "S"

Local _nFatorPr         := 1
Local _nX               := 0

Local _lRet             := .T.

Local _aArray           := {}
Local _aErroAuto        := {}

Local _oJSon            := Nil 
Local _oCliente         := Nil 

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

Default _nOpc           := 3

//--------------------------+
// SA1 - Tabela de Clientes |
//--------------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(3) )

//------------------+
// Dados do produto |
//------------------+
_oJSon      := xFromJson(DecodeUTF8(_cJSon))
_cIDCliente := _oJSon[#"id_cliente"]
_oCliente   := _oJSon[#"clientes"]

If ValType(_oCliente) == "A"

    //----------------+
    // SB1 - Produtos |
    //----------------+
    dbSelectArea("SA1")
    SA1->( dbSetOrder(1) )

    For _nX := 1 To Len(_oCliente)
        
        _aArray     := {}
        
        _cCnpj      := u_EcFormat(_oCliente[_nX][#"cnpj_cpf"],"A1_CGC",.T.)
        _cTipo      := IIF(Len(Alltrim(_cCnpj)) < 14, "F", "J") 
        _cTipo_Cli  := _oCliente[_nX][#"tipo_cli"]
        _cNome      := u_EcAcento(_oCliente[_nX][#"nome"],.T.)
        _cFantasia  := u_EcAcento(_oCliente[_nX][#"fantasia"],.T.)
        _cInscR     := _oCliente[_nX][#"inscricao"]
        _cCep       := u_EcFormat(_oCliente[_nX][#"cep"],"A1_CEP",.T.)
        _cEndereco  := u_EcAcento(_oCliente[_nX][#"endereco"],.T.)
        _cNumero    := _oCliente[_nX][#"numero"]
        _cComple    := u_EcAcento(_oCliente[_nX][#"complemento"],.T.)
        _cBairro    := u_EcAcento(_oCliente[_nX][#"bairro"],.T.)
        _cMunicipio := u_EcAcento(_oCliente[_nX][#"municipio"],.T.)
        _cUF        := _oCliente[_nX][#"uf"]
        _cDDD       := _oCliente[_nX][#"ddd"]
        _cTelefone  := u_EcFormat(_oCliente[_nX][#"telefone"],"A1_TEL",.T.)
        _cEMail     := _oCliente[_nX][#"email"]
        _cSituacao  := _oCliente[_nX][#"situacao"]
        _cCodMun    := EcCodMun(_cUF,_cMunicipio)
        _cPais      := "105"
        _cPaisB     := "01058"

        //-----------------------------------+
        // Valida se produto está cadastrado | 
        //-----------------------------------+
        If SA1->( dbSeek(xFilial("SA1") + _cCnpj) ) 
            If _nOpc == 3
                aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Cliente já cadastrado favor utilizar o método PUT para atualização."})
                Loop 
            ElseIf _nOpc == 4
                _cCodCli    := SA1->A1_COD
                _cLoja      := SA1->A1_LOJA
            EndIf
        Else
            ClienteCod(_cCnpj,@_cCodCli,@_cLoja)          
        EndIf
                
        aAdd(_aArray, {"A1_COD"     , _cCodCli                          , Nil })
        aAdd(_aArray, {"A1_LOJA"    , _cLoja                            , Nil })
        aAdd(_aArray, {"A1_NOME"    , _cNome                            , Nil })
        aAdd(_aArray, {"A1_NREDUZ"  , _cFantasia                        , Nil })
        aAdd(_aArray, {"A1_PESSOA"  , _cTipo                            , Nil })
        aAdd(_aArray, {"A1_TIPO"    , _cTipo_Cli                        , Nil })
        aAdd(_aArray, {"A1_END"     , _cEndereco + ", " + _cNumero      , Nil })
        aAdd(_aArray, {"A1_EST"     , _cUF                              , Nil })
        aAdd(_aArray, {"A1_COD_MUN" , _cCodMun                          , Nil })
        aAdd(_aArray, {"A1_MUN"     , _cMunicipio                       , Nil })
        aAdd(_aArray, {"A1_BAIRRO"  , _cBairro                          , Nil })
        aAdd(_aArray, {"A1_CEP"     , _cCep                             , Nil })
        aAdd(_aArray, {"A1_DDD"     , _cDDD                             , Nil })
        aAdd(_aArray, {"A1_TEL"     , _cTelefone                        , Nil })
        aAdd(_aArray, {"A1_CGC"     , _cCnpj                            , Nil })
        aAdd(_aArray, {"A1_MSBLQL"  , IIF(_cSituacao == "A","2","1")    , Nil })
        aAdd(_aArray, {"A1_INSCR"   , _cInscR                           , Nil })
        aAdd(_aArray, {"A1_EMAIL"   , _cEMail                           , Nil })
        aAdd(_aArray, {"A1_XIDLOGI" , _cIDCliente                       , Nil })
        aAdd(_aArray, {"A1_CLASSIF" , _cClassif                         , Nil })
        aAdd(_aArray, {"A1_FATORPR" , _nFatorPr                         , Nil })
        aAdd(_aArray, {"A1_ATIVO"   , _cAtivo                           , Nil })
        aAdd(_aArray, {"A1_CODPAIS"	, _cPaisB							, Nil })
        aAdd(_aArray, {"A1_PAIS"	, _cPais							, Nil })

        lMsErroAuto := .F.
        _aArray     := FWVetByDic(_aArray, "SA1")
        MSExecAuto({|x,y| Mata030(x,y)}, _aArray, _nOpc)

        //--------------------------+
        // Erro gravação de produto | 
        //--------------------------+
        If lMsErroAuto  
            //-------------------+
            // Retorna numeracao |
            //-------------------+
            RollBackSx8()

            //-------------------+
            // Log erro ExecAuto |
            //-------------------+
            _aErroAuto := GetAutoGRLog()

            //------------------------------------+
            // Retorna somente a linha com o erro | 
            //------------------------------------+
            ErroAuto(_aErroAuto,@_cMsgErro)
            
            //------------------------+
            // Grava array de retorno | 
            //------------------------+
            aAdd(_aMsgErro,{"1",RTrim(_cCnpj), Alltrim(_cMsgErro)})
        //-----------------------------+
        // Produto gravado com sucesso | 
        //-----------------------------+
        Else

            //--------------------+
            // Confirma numeracao |
            //--------------------+
            ConfirmSx8()            
            
            //------------------------+
            // Grava array de retorno | 
            //------------------------+
            aAdd(_aMsgErro,{"0",RTrim(_cCnpj), "Cliente gravado com sucesso."})

        EndIf
           
    Next _nX

EndIf

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} ClientesG
    @description Realiza a consulta dos clientes DanaLog
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/11/2020
/*/
/*************************************************************************************/
Static Function ClientesG(_cCnpj,_cIdCliente,_cPage,_cPerPage,_cRest)
Local _cAlias       := ""

Local _lRet         := .T.

Local _oJSon        := Nil 
Local _oClientes    := Nil 

Private _nTotQry    := 0
Private _nTotPag    := 0

//------------------+
// Consulta produto |
//------------------+
If !CliGetQry(@_cAlias,_cCnpj,_cIdCliente,_cPage,_cPerPage)
    aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Cliente não localizado."})
    Return .F.
EndIf 

_oJSon              := Array(#)
_oJSon[#"clientes"] := {}

While (_cAlias)->( !Eof() )

    aAdd(_oJSon[#"clientes"],Array(#))
    _oClientes := aTail(_oJSon[#"clientes"])

    _oClientes[#"cnpj_cpf"]     := (_cAlias)->CNPJ_CPF
	_oClientes[#"tipo_cli"]     := (_cAlias)->TIPO
	_oClientes[#"nome"]         := (_cAlias)->RAZAO
	_oClientes[#"fantasia"]     := (_cAlias)->NREDUZ
	_oClientes[#"inscricao"]    := (_cAlias)->INSCRICAO
	_oClientes[#"cep"]          := (_cAlias)->CEP
	_oClientes[#"endereco"]     := (_cAlias)->ENDERECO
	_oClientes[#"numero"]       := IIF(At(",",(_cAlias)->ENDERECO) > 0,SubStr((_cAlias)->ENDERECO,At(",",(_cAlias)->ENDERECO) + 1),"")
	_oClientes[#"complemento"]  := (_cAlias)->COMPLEMENTO
	_oClientes[#"bairro"]       := (_cAlias)->BAIRRO
	_oClientes[#"municipio"]    := (_cAlias)->MUNICIPIO
	_oClientes[#"uf"]           := (_cAlias)->ESTADO
	_oClientes[#"ddd"]          := (_cAlias)->DDD
	_oClientes[#"telefone"]     := (_cAlias)->TELEFONE
	_oClientes[#"email"]        := (_cAlias)->EMAIL
	_oClientes[#"situacao"]     := IIF((_cAlias)->SITUACAO == "1","I","A")

    (_cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
_oJSon[#"pagina"]								:= Array(#)
_oJSon[#"pagina"][#"total_itens_pagina"]		:= Val(_cPerPage)
_oJSon[#"pagina"][#"total_clientes"]			:= _nTotQry
_oJSon[#"pagina"][#"total_paginas"]				:= _nTotPag
_oJSon[#"pagina"][#"pagina_atual"]				:= Val(_cPage)

//--------------+
// Cria retorno | 
//--------------+
_cRest  := EncodeUTF8(xToJson(_oJSon))

//---------------------+
// Encerra temposrário |
//---------------------+
(_cAlias)->( dbCloseArea() )

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} ForneceP
    @description Realiza a gravação e atualização de fornecedores logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/11/2020
/*/
/*************************************************************************************/
Static Function ForneceP(_cJSon,_nOpc)
Local _cCodFor          := ""
Local _cLoja            := ""
Local _cTipo            := ""
Local _cCnpj            := ""
Local _cNome            := ""
Local _cFantasia        := ""
Local _cInscR           := ""
Local _cCep             := ""
Local _cEndereco        := ""
Local _cNumero          := ""
Local _cComple          := ""
Local _cBairro          := ""
Local _cMunicipio       := ""
Local _cUF              := ""
Local _cDDD             := ""
Local _cTelefone        := ""
Local _cEMail           := ""
Local _cSituacao        := ""
Local _cMsgErro         := ""

Local _nX               := 0

Local _lRet             := .T.

Local _aArray           := {}
Local _aErroAuto        := {}

Local _oJSon            := Nil 
Local _oFornece         := Nil 

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

Default _nOpc           := 3

//--------------------------+
// SA1 - Tabela de Clientes |
//--------------------------+
dbSelectArea("SA2")
SA2->( dbSetOrder(3) )

//------------------+
// Dados do produto |
//------------------+
_oJSon      := xFromJson(DecodeUTF8(_cJSon))
_cIDCliente := _oJSon[#"id_cliente"]
_oFornece   := _oJSon[#"fornecedores"]

If ValType(_oFornece) == "A"

    //----------------+
    // SB1 - Produtos |
    //----------------+
    dbSelectArea("SA2")
    SA2->( dbSetOrder(1) )

    For _nX := 1 To Len(_oFornece)
        
        _aArray     := {}
        
        _cCnpj      := u_EcFormat(_oFornece[_nX][#"cnpj_cpf"],"A2_CGC",.T.)
        _cTipo      := IIF(Len(Alltrim(_cCnpj)) < 14, "F", "J") 
        _cNome      := u_EcAcento(_oFornece[_nX][#"nome"],.T.)
        _cFantasia  := u_EcAcento(_oFornece[_nX][#"fantasia"],.T.)
        _cInscR     := _oFornece[_nX][#"inscricao"]
        _cCep       := u_EcFormat(_oFornece[_nX][#"cep"],"A2_CEP",.T.)
        _cEndereco  := u_EcAcento(_oFornece[_nX][#"endereco"],.T.)
        _cNumero    := _oFornece[_nX][#"numero"]
        _cComple    := u_EcAcento(_oFornece[_nX][#"complemento"],.T.)
        _cBairro    := u_EcAcento(_oFornece[_nX][#"bairro"],.T.)
        _cMunicipio := u_EcAcento(_oFornece[_nX][#"municipio"],.T.)
        _cUF        := _oFornece[_nX][#"uf"]
        _cDDD       := _oFornece[_nX][#"ddd"]
        _cTelefone  := u_EcFormat(_oFornece[_nX][#"telefone"],"A2_TEL",.T.)
        _cEMail     := _oFornece[_nX][#"email"]
        _cSituacao  := _oFornece[_nX][#"situacao"]
        _cCodMun    := EcCodMun(_cUF,_cMunicipio)

        //-----------------------------------+
        // Valida se produto está cadastrado | 
        //-----------------------------------+
        If SA2->( dbSeek(xFilial("SA2") + _cCnpj) ) 
            If _nOpc == 3
                aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Fornecedor já cadastrado favor utilizar o método PUT para atualização."})
                Loop 
            ElseIf _nOpc == 4
                _cCodFor    := SA2->A2_COD
                _cLoja      := SA2->A2_LOJA
            EndIf
        Else
            ForneceCod(_cCnpj,@_cCodFor,@_cLoja)          
        EndIf
                
        aAdd(_aArray, {"A2_COD"     , _cCodFor                          , Nil })
        aAdd(_aArray, {"A2_LOJA"    , _cLoja                            , Nil })
        aAdd(_aArray, {"A2_NOME"    , _cNome                            , Nil })
        aAdd(_aArray, {"A2_NREDUZ"  , _cFantasia                        , Nil })
        aAdd(_aArray, {"A2_TIPO"    , _cTipo                            , Nil })
        aAdd(_aArray, {"A2_END"     , _cEndereco + ", " + _cNumero      , Nil })
        aAdd(_aArray, {"A2_EST"     , _cUF                              , Nil })
        aAdd(_aArray, {"A2_COD_MUN" , _cCodMun                          , Nil })
        aAdd(_aArray, {"A2_MUN"     , _cMunicipio                       , Nil })
        aAdd(_aArray, {"A2_BAIRRO"  , _cBairro                          , Nil })
        aAdd(_aArray, {"A2_CEP"     , _cCep                             , Nil })
        aAdd(_aArray, {"A2_DDD"     , _cDDD                             , Nil })
        aAdd(_aArray, {"A2_TEL"     , _cTelefone                        , Nil })
        aAdd(_aArray, {"A2_CGC"     , _cCnpj                            , Nil })
        aAdd(_aArray, {"A2_MSBLQL"  , IIF(_cSituacao == "A","2","1")    , Nil })
        aAdd(_aArray, {"A2_INSCR"   , _cInscR                           , Nil })
        aAdd(_aArray, {"A2_EMAIL"   , _cEMail                           , Nil })
        aAdd(_aArray, {"A2_CODPAIS" , "01058"                           , Nil })
        aAdd(_aArray, {"A2_XIDLOGI" , _cIDCliente                       , Nil })
        
        lMsErroAuto := .F.
        _aArray     := FWVetByDic(_aArray, "SA2")
        MSExecAuto({|x,y| Mata020(x,y)}, _aArray, _nOpc)

        //--------------------------+
        // Erro gravação de produto | 
        //--------------------------+
        If lMsErroAuto  
            //-------------------+
            // Retorna numeracao |
            //-------------------+
            RollBackSx8()

            //-------------------+
            // Log erro ExecAuto |
            //-------------------+
            _aErroAuto := GetAutoGRLog()

            //------------------------------------+
            // Retorna somente a linha com o erro | 
            //------------------------------------+
            ErroAuto(_aErroAuto,@_cMsgErro)
            
            //------------------------+
            // Grava array de retorno | 
            //------------------------+
            aAdd(_aMsgErro,{"1",RTrim(_cCnpj), Alltrim(_cMsgErro)})
        //-----------------------------+
        // Produto gravado com sucesso | 
        //-----------------------------+
        Else

            //--------------------+
            // Confirma numeracao |
            //--------------------+
            ConfirmSx8()            
            
            //------------------------+
            // Grava array de retorno | 
            //------------------------+
            aAdd(_aMsgErro,{"0",RTrim(_cCnpj), "Fornecedor gravado com sucesso."})

        EndIf
           
    Next _nX

EndIf

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} ForneceG
    @description Realiza a consulta de fornecedores logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/11/2020
/*/
/*************************************************************************************/
Static Function ForneceG(_cCnpj,_cIdCliente,_cPage,_cPerPage,_cRest)
Local _cAlias       := ""

Local _lRet         := .T.

Local _oJSon        := Nil 
Local _oFornece     := Nil 

Private _nTotQry    := 0
Private _nTotPag    := 0

//------------------+
// Consulta produto |
//------------------+
If !ForGetQry(@_cAlias,_cCnpj,_cIdCliente,_cPage,_cPerPage)
    aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Fornecedor não localizado."})
    Return .F.
EndIf 

_oJSon              := Array(#)
_oJSon[#"fornecedores"] := {}

While (_cAlias)->( !Eof() )

    aAdd(_oJSon[#"fornecedores"],Array(#))
    _oFornece := aTail(_oJSon[#"fornecedores"])

    _oFornece[#"cnpj_cpf"]     := (_cAlias)->CNPJ_CPF
	_oFornece[#"tipo"]         := (_cAlias)->TIPO
	_oFornece[#"nome"]         := (_cAlias)->RAZAO
	_oFornece[#"fantasia"]     := (_cAlias)->NREDUZ
	_oFornece[#"inscricao"]    := (_cAlias)->INSCRICAO
	_oFornece[#"cep"]          := (_cAlias)->CEP
	_oFornece[#"endereco"]     := (_cAlias)->ENDERECO
	_oFornece[#"numero"]       := IIF(At(",",(_cAlias)->ENDERECO) > 0,SubStr((_cAlias)->ENDERECO,At(",",(_cAlias)->ENDERECO) + 1),"")
	_oFornece[#"complemento"]  := (_cAlias)->COMPLEMENTO
	_oFornece[#"bairro"]       := (_cAlias)->BAIRRO
	_oFornece[#"municipio"]    := (_cAlias)->MUNICIPIO
	_oFornece[#"uf"]           := (_cAlias)->ESTADO
	_oFornece[#"ddd"]          := (_cAlias)->DDD
	_oFornece[#"telefone"]     := (_cAlias)->TELEFONE
	_oFornece[#"email"]        := (_cAlias)->EMAIL
	_oFornece[#"situacao"]     := IIF((_cAlias)->SITUACAO == "1","I","A")

    (_cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
_oJSon[#"pagina"]								:= Array(#)
_oJSon[#"pagina"][#"total_itens_pagina"]		:= Val(_cPerPage)
_oJSon[#"pagina"][#"total_fornecedores"]		:= _nTotQry
_oJSon[#"pagina"][#"total_paginas"]				:= _nTotPag
_oJSon[#"pagina"][#"pagina_atual"]				:= Val(_cPage)

//--------------+
// Cria retorno | 
//--------------+
_cRest  := EncodeUTF8(xToJson(_oJSon))

//---------------------+
// Encerra temposrário |
//---------------------+
(_cAlias)->( dbCloseArea() )
Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} TransportP
    @description Realiza cadastro/atualização de transportadoras
    @type  Static Function
    @author Bernard M. Margarido
    @since 02/12/2020
/*/
/*************************************************************************************/
Static Function TransportP(_cJSon,_nOpc)
Local _cCodigo          := ""
Local _cCnpj            := ""
Local _cNome            := ""
Local _cFantasia        := ""
Local _cInscR           := ""
Local _cCep             := ""
Local _cEndereco        := ""
Local _cNumero          := ""
Local _cComple          := ""
Local _cBairro          := ""
Local _cMunicipio       := ""
Local _cUF              := ""
Local _cDDD             := ""
Local _cTelefone        := ""
Local _cEMail           := ""
Local _cSituacao        := ""
Local _cMsgErro         := ""

Local _nX               := 0

Local _lRet             := .T.

Local _aArray           := {}
Local _aErroAuto        := {}

Local _oJSon            := Nil 
Local _oTransp          := Nil 

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

Default _nOpc           := 3

//--------------------------+
// SA1 - Tabela de Clientes |
//--------------------------+
dbSelectArea("SA4")
SA4->( dbSetOrder(3) )

//------------------+
// Dados do produto |
//------------------+
_oJSon      := xFromJson(DecodeUTF8(_cJSon))
_cIDCliente := _oJSon[#"id_cliente"]
_oTransp   := _oJSon[#"transportadoras"]

If ValType(_oTransp) == "A"

    For _nX := 1 To Len(_oTransp)
        
        _aArray     := {}
        
        _cCnpj      := u_EcFormat(_oTransp[_nX][#"cnpj_cpf"],"A4_CGC",.T.)
        _cNome      := u_EcAcento(_oTransp[_nX][#"nome"],.T.)
        _cFantasia  := u_EcAcento(_oTransp[_nX][#"fantasia"],.T.)
        _cInscR     := _oTransp[_nX][#"inscricao"]
        _cCep       := u_EcFormat(_oTransp[_nX][#"cep"],"A4_CEP",.T.)
        _cEndereco  := u_EcAcento(_oTransp[_nX][#"endereco"],.T.)
        _cNumero    := _oTransp[_nX][#"numero"]
        _cComple    := u_EcAcento(_oTransp[_nX][#"complemento"],.T.)
        _cBairro    := u_EcAcento(_oTransp[_nX][#"bairro"],.T.)
        _cMunicipio := u_EcAcento(_oTransp[_nX][#"municipio"],.T.)
        _cUF        := _oTransp[_nX][#"uf"]
        _cDDD       := _oTransp[_nX][#"ddd"]
        _cTelefone  := u_EcFormat(_oTransp[_nX][#"telefone"],"A4_TEL",.T.)
        _cEMail     := _oTransp[_nX][#"email"]
        _cSituacao  := _oTransp[_nX][#"situacao"]
        _cCodMun    := EcCodMun(_cUF,_cMunicipio)

        //-----------------------------------+
        // Valida se produto está cadastrado | 
        //-----------------------------------+
        If SA4->( dbSeek(xFilial("SA4") + _cCnpj) ) 
            If _nOpc == 3
                aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Transportadora já cadastrada favor utilizar o método PUT para atualização."})
                Loop 
            ElseIf _nOpc == 4
                _cCodigo    := SA4->A4_COD
            EndIf
        Else
            TranspCod(_cCnpj,@_cCodigo)          
        EndIf
                
        aAdd(_aArray, {"A4_COD"     , _cCodigo                          , Nil })
        aAdd(_aArray, {"A4_NOME"    , _cNome                            , Nil })
        aAdd(_aArray, {"A4_NREDUZ"  , _cFantasia                        , Nil })
        aAdd(_aArray, {"A4_END"     , _cEndereco + ", " + _cNumero      , Nil })
        aAdd(_aArray, {"A4_EST"     , _cUF                              , Nil })
        aAdd(_aArray, {"A4_COD_MUN" , _cCodMun                          , Nil })
        aAdd(_aArray, {"A4_MUN"     , _cMunicipio                       , Nil })
        aAdd(_aArray, {"A4_BAIRRO"  , _cBairro                          , Nil })
        aAdd(_aArray, {"A4_CEP"     , _cCep                             , Nil })
        aAdd(_aArray, {"A4_DDD"     , _cDDD                             , Nil })
        aAdd(_aArray, {"A4_TEL"     , _cTelefone                        , Nil })
        aAdd(_aArray, {"A4_CGC"     , _cCnpj                            , Nil })
        aAdd(_aArray, {"A4_MSBLQL"  , IIF(_cSituacao == "A","2","1")    , Nil })
        aAdd(_aArray, {"A4_INSCR"   , _cInscR                           , Nil })
        aAdd(_aArray, {"A4_EMAIL"   , _cEMail                           , Nil })
        aAdd(_aArray, {"A4_CODPAIS" , "0105"                            , Nil })
        aAdd(_aArray, {"A4_XIDLOGI" , _cIDCliente                       , Nil })
        
        lMsErroAuto     := .F.
        lAutoErrNoFile  := .T.
        _aArray         := FWVetByDic(_aArray, "SA4")
        MSExecAuto({|x,y| Mata050(x,y)}, _aArray, _nOpc)

        //--------------------------+
        // Erro gravação de produto | 
        //--------------------------+
        If lMsErroAuto  
            //-------------------+
            // Retorna numeracao |
            //-------------------+
            RollBackSx8()

            //-------------------+
            // Log erro ExecAuto |
            //-------------------+
            _aErroAuto := GetAutoGRLog()

            //------------------------------------+
            // Retorna somente a linha com o erro | 
            //------------------------------------+
            ErroAuto(_aErroAuto,@_cMsgErro)
            
            //------------------------+
            // Grava array de retorno | 
            //------------------------+
            aAdd(_aMsgErro,{"1",RTrim(_cCnpj), Alltrim(_cMsgErro)})
        //-----------------------------+
        // Produto gravado com sucesso | 
        //-----------------------------+
        Else

            //--------------------+
            // Confirma numeracao |
            //--------------------+
            ConfirmSx8()            
            
            //------------------------+
            // Grava array de retorno | 
            //------------------------+
            aAdd(_aMsgErro,{"0",RTrim(_cCnpj), "Transportadora gravada com sucesso."})

        EndIf
           
    Next _nX

EndIf

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} TransportG
    @description Realiza consulta das transportadoras
    @type  Static Function
    @author Bernard M. Margarido
    @since 02/12/2020
/*/
/*************************************************************************************/
Static Function TransportG(_cCnpj,_cIdCliente,_cPage,_cPerPage,_cRest)
Local _cAlias       := ""

Local _lRet         := .T.

Local _oJSon        := Nil 
Local _oTransp      := Nil 

Private _nTotQry    := 0
Private _nTotPag    := 0

//------------------+
// Consulta produto |
//------------------+
If !TraGetQry(@_cAlias,_cCnpj,_cIdCliente,_cPage,_cPerPage)
    aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Transportadora não localizado."})
    Return .F.
EndIf 

_oJSon              := Array(#)
_oJSon[#"transportadoras"] := {}

While (_cAlias)->( !Eof() )

    aAdd(_oJSon[#"transportadoras"],Array(#))
    _oTransp := aTail(_oJSon[#"transportadoras"])

    _oTransp[#"cnpj_cpf"]     := (_cAlias)->CNPJ_CPF
	_oTransp[#"nome"]         := (_cAlias)->RAZAO
	_oTransp[#"fantasia"]     := (_cAlias)->NREDUZ
	_oTransp[#"cep"]          := (_cAlias)->CEP
	_oTransp[#"endereco"]     := (_cAlias)->ENDERECO
	_oTransp[#"numero"]       := IIF(At(",",(_cAlias)->ENDERECO) > 0,SubStr((_cAlias)->ENDERECO,At(",",(_cAlias)->ENDERECO) + 1),"")
	_oTransp[#"complemento"]  := (_cAlias)->COMPLEMENTO
	_oTransp[#"bairro"]       := (_cAlias)->BAIRRO
	_oTransp[#"municipio"]    := (_cAlias)->MUNICIPIO
	_oTransp[#"uf"]           := (_cAlias)->ESTADO
	_oTransp[#"ddd"]          := (_cAlias)->DDD
	_oTransp[#"telefone"]     := (_cAlias)->TELEFONE
	_oTransp[#"email"]        := (_cAlias)->EMAIL
	_oTransp[#"situacao"]     := IIF((_cAlias)->SITUACAO == "1","I","A")

    (_cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
_oJSon[#"pagina"]								:= Array(#)
_oJSon[#"pagina"][#"total_itens_pagina"]		:= Val(_cPerPage)
_oJSon[#"pagina"][#"total_transportadoras"]		:= _nTotQry
_oJSon[#"pagina"][#"total_paginas"]				:= _nTotPag
_oJSon[#"pagina"][#"pagina_atual"]				:= Val(_cPage)

//--------------+
// Cria retorno | 
//--------------+
_cRest  := EncodeUTF8(xToJson(_oJSon))

//---------------------+
// Encerra temposrário |
//---------------------+
(_cAlias)->( dbCloseArea() )
Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} EntradaP
    @description Recebimento mercadorias DanaLog
    @type  Static Function
    @author Bernard M. Margarido
    @since 08/12/2020
/*/
/*************************************************************************************/
Static Function EntradaP(_cJSon,_nOpc)
Local _aArea            := GetArea()

Local _aCabec           := {}
Local _aItem            := {}
Local _aItems           := {}

Local _cItem            := StrZero(0,TamSx3("D1_ITEM")[1])
Local _cTesDLog         := GetNewPar("DN_TESDLOG","007")
Local _cIDCliente       := ""
Local _cItemNF          := ""
Local _cTipo            := ""
Local _cCnpj            := ""
Local _cCnpjT           := ""
Local _cNota            := ""
Local _cSerie           := ""
Local _cCliFor          := ""
Local _cLoja            := ""
Local _cTransp          := ""
Local _cCondPg          := ""
Local _cUM              := ""
Local _cLocal           := ""
Local _cLote            := ""
Local _cTes             := ""
Local _cDocOri          := ""
Local _cSerOri          := ""
Local _cItemOri         := ""
Local _cMsgErro         := ""
Local _cSituacao        := ""

Local _dDtEmiss         := ""
Local _dDtVldLote       := ""

Local _nOpcA            := 0
Local _nX               := 0    
Local _nQuant           := 0
Local _nVlrUni          := 0
Local _nVlrTot          := 0
Local _nDecTot          := TamSx3("D1_TOTAL")[2]

Local _lUsaLote         := .F.
Local _lRet             := .T.
Local _lClassif         := .F.

Local _oJSon            := Nil 
Local _oPNfe            := Nil 
Local _oItems           := Nil 

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .F.

//--------------------+
// SA2 - Fornecedores |
//--------------------+
dbSelectArea("SA2")
SA2->( dbOrderNickname("DANALOGFOR") )

//----------------+
// SA1 - Clientes |
//----------------+
dbSelectArea("SA1")
SA1->( dbOrderNickname("DANALOGCLI") )

//----------------------+
// SA4 - Transportadora |
//----------------------+
dbSelectArea("SA4")
SA4->( dbOrderNickname("DANALOGTRA") )

//-----------------------+
// SF1 - Nota de Entrada | 
//-----------------------+
dbSelectArea("SF1")
SF1->( dbSetOrder(1) )

//----------------+
// SB1 - Produtos |
//----------------+
dbSelectArea("SB1")
SB1->( dbOrderNickname("DANALOG") )

//-----------------------+
// JSON - Desesserializa |
//-----------------------+
_oJSon      := xFromJson(DecodeUTF8(_cJSon))
_cIDCliente := _oJSon[#"id_cliente"]
_oPNfe      := _oJSon[#"recebimento"]
_oItems     := _oPNfe[#"items"]

//--------------+
// Tipo de Nota | 
//--------------+
_cTipo      := IIF(_oPNfe[#"tipo"] == "FOR","N","D")
_cCnpj      := PadR(_oPNfe[#"cnpj_cpf"],_nTCNPJ)
_cCnpjT     := PadR(_oPNfe[#"transportadora"],_nTCNPJ)
_cSituacao  := _oPNfe[#"situacao"] 
_cNota      := PadR(_oPNfe[#"nota"],_nTNota)
_cSerie     := PadR(_oPNfe[#"serie"],_nTSerie)
_dDtEmiss   := cTod(_oPNfe[#"dt_emissao"])

//---------------------------+
// Valida cliente/fornecedor |
//---------------------------+
If _cTipo == "N"
    If !SA2->( dbSeek(xFilial("SA2") + _cCnpj + _cIDCliente) )
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Fornecedor não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf
ElseIf _cTipo == "D"
    If !SA1->( dbSeek(xFilial("SA1") + _cCnpj + _cIDCliente) )
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Cliente não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf
EndIf

//-----------------------+
// Valida transportadora |
//-----------------------+
If !SA4->( dbSeek(xFilial("SA4") + _cCnpjT + _cIDCliente) )
    aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Transportadora não localizado."})
    RestArea(_aArea)
    Return .F.
EndIf

//-----------------------------------------+
// Dados Cliente/Fornecedor/Transportadora |
//-----------------------------------------+
_cCliFor          := IIF(_cTipo == "N", SA2->A2_COD, SA1->A1_COD)
_cLoja            := IIF(_cTipo == "N", SA2->A2_LOJA, SA1->A1_LOJA)
_cTransp          := SA4->A4_COD

//-----------------+
// Inclui pré nota |
//-----------------+
If _cSituacao == "1"
    //------------------------------+
    // Valida se já existe pré nota |
    //------------------------------+
    If SF1->( dbSeek(xFilial("SF1") + _cNota + _cSerie + _cCliFor + _cLoja) )
        If Rtrim(SF1->F1_XIDLOGI) == RTrim(_cIDCliente)
            aAdd(_aMsgErro,{"1",RTrim(_cNota) + Rtrim(_cSerie), "Nota já cadastrada."})
            RestArea(_aArea)
            Return .F.
        EndIf
    EndIf
    
    _nOpcA := 3

//-----------------------------+
// Estorna pré nota de entrada |
//-----------------------------+
ElseIf _cSituacao == "2"

    //---------------------------+
    // Valida se existe pré nota |
    //---------------------------+
    If !SF1->( dbSeek(xFilial("SF1") + _cNota + _cSerie + _cCliFor + _cLoja) )
        aAdd(_aMsgErro,{"1",RTrim(_cNota) + Rtrim(_cSerie), "Nota nao localizada."})
        RestArea(_aArea)
        Return .F.
    EndIf

    //--------------------------------------------------+
    // Valida se nota pertence ao ID do Cliente DanaLog |
    //--------------------------------------------------+
    If Rtrim(SF1->F1_XIDLOGI) <> RTrim(_cIDCliente)
        aAdd(_aMsgErro,{"1",RTrim(_cNota) + Rtrim(_cSerie), "Nota nao pertence ao seu ID."})
        RestArea(_aArea)
        Return .F.
    EndIf

    //----------------------+
    // Nota já classificada |
    //----------------------+
    If !Empty(SF1->F1_STATUS)
        _lClassif   := .T.
    EndIf

    _nOpcA := 5
EndIf

//-------------------------+
// Cria cabeçalho pré nota |
//-------------------------+
aAdd(_aCabec, {"F1_DOC"     , _cNota            , Nil   })
aAdd(_aCabec, {"F1_SERIE"   , _cSerie           , Nil   })
aAdd(_aCabec, {"F1_TIPO"    , _cTipo            , Nil   })
aAdd(_aCabec, {"F1_FORNECE" , _cCliFor          , Nil   })
aAdd(_aCabec, {"F1_LOJA"    , _cLoja            , Nil   })
aAdd(_aCabec, {"F1_EMISSAO" , _dDtEmiss         , Nil   })
aAdd(_aCabec, {"F1_FORMUL"  , "N"               , Nil   })
aAdd(_aCabec, {"F1_ESPECIE"	, "SPED"			, Nil   })
aAdd(_aCabec, {"F1_COND"	, _cCondPg			, Nil   })
aAdd(_aCabec, {"F1_TRANSP"	, _cTransp			, Nil   })
aAdd(_aCabec, {"F1_XENVWMS" , "1"			    , Nil   })
aAdd(_aCabec, {"F1_XDTALT"  , Date()		    , Nil   })
aAdd(_aCabec, {"F1_XHRALT"  , Time()		    , Nil   })
aAdd(_aCabec, {"F1_XIDLOGI" , _cIDCliente       , Nil   })

//---------------------+
// Cria itens pré nota |
//---------------------+
For _nX := 1 To Len(_oItems)
    _aItem  := {}

    //---------------------+
    // Dados itens da nota | 
    //---------------------+
    _cProduto   := PadR(_oItems[_nX][#"produto"],_nTProd)
    
    //----------------+
    // Valida produto |
    //----------------+
    If !SB1->( dbSeek(xFilial("SB1") + _cProduto) )
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Produto não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf

    _cItemNF    := Soma1(_cItem,1)
    _cUM        := SB1->B1_UM
    _cLocal     := GetArmazem(_cIDCliente,"1")
    _cLote      := _oItems[_nX][#"lote"]
    _cTes       := _cTesDLog
    _cDocOri    := ""
    _cSerOri    := ""
    _cItemOri   := ""
    _dDtVldLote := cToD(_oItems[_nX][#"dt_vld_lote"])
    _nQuant     := _oItems[_nX][#"quantidade"]
    _nVlrUni    := _oItems[_nX][#"valor_unitario"]
    _nVlrTot    := Round(_nQuant * _nVlrUni,_nDecTot)
    _lUsaLote   := IIF(SB1->B1_RASTRO == "L",.T.,.F.)

    //-------------------------------------+
    // Valida se existe armazem criado SB2 |
    //-------------------------------------+
    CriaArmazem(_cProduto,_cLocal,_cIDCliente)

    aAdd(_aItem, { "D1_ITEM"    , _cItemNF          , Nil })
    aAdd(_aItem, { "D1_COD" 	, _cProduto			, Nil })
    aAdd(_aItem, { "D1_QUANT" 	, _nQuant			, Nil })
    aAdd(_aItem, { "D1_VUNIT" 	, _nVlrUni 			, Nil })
    aAdd(_aItem, { "D1_TOTAL" 	, _nVlrTot 	        , Nil })
    aAdd(_aItem, { "D1_TES" 	, _cTes 			, Nil })
    aAdd(_aItem, { "D1_UM"    	, _cUM				, Nil })
    aAdd(_aItem, { "D1_LOCAL" 	, _cLocal			, Nil })

    //---------------------+    
    // Se produto usa lote | 
    //---------------------+
    If _lUsaLote
        aAdd(_aItem, { "D1_LOTECTL"	, _cLote		, Nil })
        aAdd(_aItem, { "D1_DTVALID"	, _dDtVldLote	, Nil })
    EndIf

    //-------------------+
    // Nota de Devolucao |
    //-------------------+
    If _cTipo == "D"
        aAdd(_aItem, { "D1_NFORI" 	, _cDocOri  	, Nil })
        aAdd(_aItem, { "D1_SERIORI"	, _cSerOri		, Nil }) 
        aAdd(_aItem, { "D1_ITEMORI"	, _cItem		, Nil })
    EndIf

    //----------------------------+
    // Adiciona itens da Pré nota |
    //----------------------------+
    aAdd(_aItems,_aItem)
Next _nX

//---------------+
// Cria pré nota | 
//---------------+
If Len(_aCabec) > 0 .And. Len(_aItems) > 0 

    lMsErroAuto     := .F. 
    lAutoErrNoFile  := .T.
    
    _aCabec         := FWVetByDic(_aCabec, "SF1")
    _aItems         := FWVetByDic(_aItems, "SD1",.T.)

    If _lClassif .And. _cSituacao == "2"
        MSExecAuto({|x,y,z| mata103(x,y,z) }, _aCabec, _aItems, _nOpcA)
    Else
        MSExecAuto({|x,y,z| Mata140(x,y,z) }, _aCabec, _aItems, _nOpcA)
    EndIf

    //--------------------------+
    // Erro gravação de produto | 
    //--------------------------+
    If lMsErroAuto  
        //-------------------+
        // Retorna numeracao |
        //-------------------+
        RollBackSx8()

        //-------------------+
        // Log erro ExecAuto |
        //-------------------+
        _aErroAuto := GetAutoGRLog()

        //------------------------------------+
        // Retorna somente a linha com o erro | 
        //------------------------------------+
        ErroAuto(_aErroAuto,@_cMsgErro)
        
        //------------------------+
        // Grava array de retorno | 
        //------------------------+
        aAdd(_aMsgErro,{"1",RTrim(_cNota) + RTrim(_cSerie) , Alltrim(_cMsgErro)})
    //-----------------------------+
    // Produto gravado com sucesso | 
    //-----------------------------+
    Else

        //--------------------+
        // Confirma numeracao |
        //--------------------+
        ConfirmSx8()            
        
        //------------------------+
        // Grava array de retorno | 
        //------------------------+
        aAdd(_aMsgErro,{"0",RTrim(_cNota) + RTrim(_cSerie), IIF(_nOpcA == 3,"Dados gravados com sucesso.","Nota cancelada com sucesso.")})

    EndIf

EndIf

RestArea(_aArea)
Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} EntradaG
    @description Gera pedidos de remessa DanaLog
    @type  Static Function
    @author Bernard M. Margarido
    @since 16/12/2020
/*/
/*************************************************************************************/
Static Function EntradaG(_cNota,_cSerie,_cIdCliente,_cPage,_cPerPage,_cRest)
Local _cAlias       := ""
Local _cNotaR       := ""
Local _cSerieR      := ""
Local _cCliFor      := ""
Local _cLoja        := ""
Local _cSituacao    := ""
Local _cTipo        := ""
Local _cCnpj        := ""
Local _cRazao       := ""
Local _cCnpj_Trans  := ""
Local _cNome_Trans  := ""

Local _dDtEmissao   := ""
Local _dDtEntrada   := ""

Local _lRet         := .T.

Local _oJSon        := Nil 
Local _oEntrada     := Nil 
Local _oItems       := Nil 

Private _nTotQry    := 0
Private _nTotPag    := 0

//------------------+
// Consulta produto |
//------------------+
If !NfeGetQry(@_cAlias,_cNota,_cSerie,_cIdCliente,_cPage,_cPerPage)
    aAdd(_aMsgErro,{"1",RTrim(_cNota) + RTrim(_cSerie) , "Nota não localizado."})
    Return .F.
EndIf 

_oJSon                  := Array(#)
_oJSon[#"recebimentos"] := {}

While (_cAlias)->( !Eof() )

    aAdd(_oJSon[#"recebimentos"],Array(#))
    _oEntrada := aTail(_oJSon[#"recebimentos"])
    
    _cNotaR         := (_cAlias)->DOCUMENTO
    _cSerieR        := (_cAlias)->SERIE
    _cCliFor        := (_cAlias)->CODIGO
    _cLoja          := (_cAlias)->LOJA
    _cSituacao      := (_cAlias)->SITUACAO
    _cTipo          := (_cAlias)->TIPO
    _cCnpj          := (_cAlias)->CNPJ_CPF
    _cRazao         := (_cAlias)->NOME_CLIFOR
    _cCnpj_Trans    := (_cAlias)->CNPJ_TRANSP
    _cNome_Trans    := (_cAlias)->NOME_TRANSP
    _dDtEmissao     := dToc(sTod((_cAlias)->DT_EMISSAO))
    _dDtEntrada     := dToc(sTod((_cAlias)->DT_ENTRADA))

    _oEntrada[#"situacao"]              := _cSituacao
    _oEntrada[#"cnpj_cpf"]              := _cCnpj
    _oEntrada[#"nome_for"]              := _cRazao
    _oEntrada[#"tipo"]                  := IIF(_cTipo == "N", "FOR","DEV")
    _oEntrada[#"nota"]                  := _cNotaR
    _oEntrada[#"serie"]                 := _cSerieR
    _oEntrada[#"transportadora"]        := _cCnpj_Trans
    _oEntrada[#"nome_transportadora"]   := _cNome_Trans
    _oEntrada[#"dt_emissao"]            := _dDtEmissao
    _oEntrada[#"dt_entrada"]            := _dDtEntrada

    _oEntrada[#"items"]                 := {}

    If SD1->( dbSeek(xFilial("SD1") + _cNotaR + _cSerieR + _cCliFor + _cLoja) )

		While SD1->( !Eof() .And. xFilial("SD1") + _cNotaR + _cSerieR + _cCliFor + _cLoja == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA )
            //---------------+
			// Itens da Nota |
			//---------------+
			aAdd(_oEntrada[#"items"],Array(#))
			_oItems := aTail(_oEntrada[#"items"])

            _oItems[#"item"]            := SD1->D1_ITEM
            _oItems[#"produto"]         := SD1->D1_COD
            _oItems[#"desc_prod"]       := Posicione("SB1",1,xFilial("SB1") + SD1->D1_COD,"B1_DESC")
            _oItems[#"qtd_nota"]        := SD1->D1_QUANT
            _oItems[#"qtd_conferida"]   := 0
            _oItems[#"armazem"]         := SD1->D1_LOCAL
            _oItems[#"lote"]            := SD1->D1_LOTECTL
            _oItems[#"dt_vld_lote"]     := SD1->D1_DTVALID

            SD1->( dbSkip() )
        EndDo
    EndIf

    (_cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
_oJSon[#"pagina"]								:= Array(#)
_oJSon[#"pagina"][#"total_itens_pagina"]		:= Val(_cPerPage)
_oJSon[#"pagina"][#"total_recebimentos"]		:= _nTotQry
_oJSon[#"pagina"][#"total_paginas"]				:= _nTotPag
_oJSon[#"pagina"][#"pagina_atual"]				:= Val(_cPage)

//--------------+
// Cria retorno | 
//--------------+
_cRest  := EncodeUTF8(xToJson(_oJSon))

//---------------------+
// Encerra temposrário |
//---------------------+
(_cAlias)->( dbCloseArea() )

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} PedidoP
    @description Gera pedidos de remessa DanaLog
    @type  Static Function
    @author Bernard M. Margarido
    @since 16/12/2020
/*/
/*************************************************************************************/
Static Function PedidoP(_cJSon,_nOpc)
Local _aArea            := GetArea()

Local _aCabec           := {}
Local _aItem            := {}
Local _aItems           := {}

Local _cItem            := StrZero(0,TamSx3("D2_ITEM")[1])
Local _cTesDLog         := GetNewPar("DN_TSDLOG","700")
Local _cIDCliente       := ""
Local _cSituacao        := ""
Local _cTipo            := ""
Local _cCnpj            := ""
Local _cCnpjT           := ""
Local _cNumero          := ""
Local _cNumPedD         := ""
Local _cCliFor          := ""
Local _cLoja            := ""
Local _cTransp          := ""
Local _cCondPg          := "001"
Local _cUM              := ""
Local _cLocal           := ""
Local _cLote            := ""
Local _cTes             := ""
Local _cItemPv          := ""
Local _cMsgErro         := ""

Local _dDtEmiss         := ""
Local _dDtVldLote       := ""

Local _nOpcA            := 0
Local _nX               := 0    
Local _nQuant           := 0
Local _nVlrUni          := 0
Local _nVlrTot          := 0
Local _nDecTot          := TamSx3("D2_TOTAL")[2]

Local _lUsaLote         := .F.
Local _lRet             := .T.

Local _oJSon            := Nil 
Local _oPedido          := Nil 
Local _oItems           := Nil 

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .F.

//--------------------+
// SA2 - Fornecedores |
//--------------------+
dbSelectArea("SA2")
SA2->( dbOrderNickname("DANALOGFOR") )

//----------------+
// SA1 - Clientes |
//----------------+
dbSelectArea("SA1")
SA1->( dbOrderNickname("DANALOGCLI") )

//----------------------+
// SA4 - Transportadora |
//----------------------+
dbSelectArea("SA4")
SA4->( dbOrderNickname("DANALOGTRA") )

//-----------------------+
// SC5 - Pedido de Venda | 
//-----------------------+
dbSelectArea("SC5")
SC5->( dbOrderNickname("DANALOGPED") )

//----------------+
// SB1 - Produtos |
//----------------+
dbSelectArea("SB1")
SB1->( dbOrderNickname("DANALOG") )

//-----------------------+
// JSON - Desesserializa |
//-----------------------+
_oJSon      := xFromJson(DecodeUTF8(_cJSon))
_cIDCliente := _oJSon[#"id_cliente"]
_oPedido    := _oJSon[#"pedido"]
_oItems     := _oPedido[#"items"]

//--------------+
// Tipo de Nota | 
//--------------+
_cSituacao  := _oPedido[#"situacao"]
_cTipo      := IIF(_oPedido[#"tipo"] == "CLI","N","D")
_cNumPedD   := PadR(_oPedido[#"numero"],_nTPedD)
_cCnpj      := PadR(_oPedido[#"cnpj_cpf"],_nTCNPJ)
_cCnpjT     := PadR(_oPedido[#"transportadora"],_nTCNPJ)
_dDtEmiss   := cTod(_oPedido[#"dt_emissao"])

//---------------------------+
// Valida cliente/fornecedor |
//---------------------------+
If _cTipo == "D"
    If !SA2->( dbSeek(xFilial("SA2") + _cCnpj + _cIDCliente) )
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Fornecedor não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf
ElseIf _cTipo == "N"
    If !SA1->( dbSeek(xFilial("SA1") + _cCnpj + _cIDCliente) )
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Cliente não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf
EndIf

//-----------------------+
// Valida transportadora |
//-----------------------+
If !SA4->( dbSeek(xFilial("SA4") + _cCnpjT + _cIDCliente) )
    aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Transportadora não localizado."})
    RestArea(_aArea)
    Return .F.
EndIf

//-----------------------------------------+
// Dados Cliente/Fornecedor/Transportadora |
//-----------------------------------------+
_cCliFor          := IIF(_cTipo == "D", SA2->A2_COD, SA1->A1_COD)
_cLoja            := IIF(_cTipo == "D", SA2->A2_LOJA, SA1->A1_LOJA)
_cTipoCli         := IIF(_cTipo == "D", SA2->A2_TIPO, SA1->A1_TIPO)
_cTransp          := SA4->A4_COD

//-----------------------+
// Cria pedido separação | 
//-----------------------+
If _cSituacao == "1"
    //----------------------------+
    // Valida se já existe pedido |
    //----------------------------+
    If SC5->( dbSeek(xFilial("SC5") + _cNumPedD + _cIDCliente) )
        If Rtrim(SC5->C5_XIDLOGI) == RTrim(_cIDCliente) 
            aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido já cadastrada."})
            RestArea(_aArea)
            Return .F.
        EndIf
    EndIf    

    //--------------------------+
    // Proximo numero do pedido |
    //--------------------------+
    PedidoNum(@_cNumero)

    //-------------------------+
    // Opção de incluir pedido |
    //-------------------------+
    _nOpcA := 3

//-------------------+
// Cancela separação | 
//-------------------+
ElseIf _cSituacao == "2"
    //----------------------------+
    // Valida se já existe pedido |
    //----------------------------+
    If !SC5->( dbSeek(xFilial("SC5") + _cNumPedD + _cIDCliente) )
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf  

    //------------------+
    // Numero do pedido | 
    //------------------+
    _cNumero := SC5->C5_NUM     

    //-------------------------+
    // Opção de incluir pedido |
    //-------------------------+
    _nOpcA := 5

    //------------------------------------+
    // Valida se pedido pode se cancelado |
    //------------------------------------+
    If SC5->C5_XENVWMS == "9" .And. RTrim(SC5->C5_NOTA) == "XXXXXX"
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido já cancelado."})
        RestArea(_aArea)
        Return .F.
    EndIf

    //--------------------------+
    // Valida se já existe nota |
    //--------------------------+
    dbSelectArea("SF2")
    SF2->( dbSetOrder(1) )
    If SF2->( dbSeek(xFilial("SF2") + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido já separado. Não poderá ser cancelado."})
        RestArea(_aArea)
        Return .F.
    EndIf

    //-------------------+
    // Estorna liberação |
    //-------------------+
    PedidoL(_cNumero,.T.)

EndIf

//-------------------------+
// Cria cabeçalho pré nota |
//-------------------------+
aAdd(_aCabec, {"C5_NUM"     , _cNumero          , Nil   })
aAdd(_aCabec, {"C5_TIPO"    , _cTipo            , Nil   })
aAdd(_aCabec, {"C5_CLIENTE" , _cCliFor          , Nil   })
aAdd(_aCabec, {"C5_LOJACLI" , _cLoja            , Nil   })
aAdd(_aCabec, {"C5_TIPOCLI" , _cTipoCli         , Nil   })
aAdd(_aCabec, {"C5_EMISSAO" , _dDtEmiss         , Nil   })
aAdd(_aCabec, {"C5_TPFRETE" , "F"               , Nil   })
aAdd(_aCabec, {"C5_CONDPAG"	, _cCondPg			, Nil   })
//aAdd(_aCabec, {"C5_TRANSP"	, _cTransp			, Nil   })
aAdd(_aCabec, {"C5_XENVWMS" , "1"			    , Nil   })
aAdd(_aCabec, {"C5_XIDLOGI" , _cIDCliente       , Nil   })
aAdd(_aCabec, {"C5_XNUMDL " , _cNumPedD         , Nil   })

//---------------------+
// Cria itens pré nota |
//---------------------+
For _nX := 1 To Len(_oItems)
    _aItem  := {}

    //---------------------+
    // Dados itens da nota | 
    //---------------------+
    _cProduto   := PadR(_oItems[_nX][#"produto"],_nTProd)
    
    //----------------+
    // Valida produto |
    //----------------+
    If !SB1->( dbSeek(xFilial("SB1") + _cProduto) )
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Produto não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf

    _cItemPv    := Soma1(_cItem,1)
    _cUM        := SB1->B1_UM
    _cLocal     := GetArmazem(_cIDCliente,"1")
    _cLote      := _oItems[_nX][#"lote"]
    _cTes       := _cTesDLog
    _dDtVldLote := cToD(_oItems[_nX][#"dt_vld_lote"])
    _nQuant     := _oItems[_nX][#"quantidade"]
    _nVlrUni    := _oItems[_nX][#"valor_unitario"]
    _nVlrTot    := Round(_nQuant * _nVlrUni,_nDecTot)
    _lUsaLote   := IIF(SB1->B1_RASTRO == "L",.T.,.F.)

    //-------------------------------------+
    // Valida se existe armazem criado SB2 |
    //-------------------------------------+
    CriaArmazem(_cProduto,_cLocal,_cIDCliente)

    aAdd(_aItem, { "C6_ITEM"    , _cItemPv          , Nil })
    aAdd(_aItem, { "C6_PRODUTO" , _cProduto			, Nil })
    aAdd(_aItem, { "C6_QTDVEN" 	, _nQuant			, Nil })
    aAdd(_aItem, { "C6_PRCVEN" 	, _nVlrUni 			, Nil })
    aAdd(_aItem, { "C6_PRUNIT" 	, _nVlrUni 			, Nil })
    aAdd(_aItem, { "C6_TES" 	, _cTes 			, Nil })
    aAdd(_aItem, { "C6_UM"    	, _cUM				, Nil })
    aAdd(_aItem, { "C6_LOCAL" 	, _cLocal			, Nil })

    //---------------------+    
    // Se produto usa lote | 
    //---------------------+
    If _lUsaLote
        aAdd(_aItem, { "C6_LOTECTL"	, _cLote		, Nil })
        aAdd(_aItem, { "C6_DTVALID"	, _dDtVldLote	, Nil })
    EndIf    

    //--------------------------+
    // Adiciona itens do pedido |
    //--------------------------+
    aAdd(_aItems,_aItem)
Next _nX

//-----------------------+
// Cria pedido separacao | 
//-----------------------+
If Len(_aCabec) > 0 .And. Len(_aItems) > 0 

    lMsErroAuto     := .F. 
    lAutoErrNoFile  := .T.
    
    _aCabec         := FWVetByDic(_aCabec, "SC5")
    _aItems         := FWVetByDic(_aItems, "SC6",.T.)

    MSExecAuto({|x,y,z| Mata410(x,y,z) }, _aCabec, _aItems, _nOpcA)

    //--------------------------+
    // Erro gravação de produto | 
    //--------------------------+
    If lMsErroAuto  
        //-------------------+
        // Retorna numeracao |
        //-------------------+
        RollBackSx8()

        //-------------------+
        // Log erro ExecAuto |
        //-------------------+
        _aErroAuto := GetAutoGRLog()

        //------------------------------------+
        // Retorna somente a linha com o erro | 
        //------------------------------------+
        ErroAuto(_aErroAuto,@_cMsgErro)
        
        //------------------------+
        // Grava array de retorno | 
        //------------------------+
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), Alltrim(_cMsgErro)})
    //-----------------------------+
    // Produto gravado com sucesso | 
    //-----------------------------+
    Else

        //--------------------+
        // Confirma numeracao |
        //--------------------+
        ConfirmSx8()            

        //---------------+    
        // Libera pedido | 
        //---------------+
        PedidoL(SC5->C5_NUM)

        //------------------------+
        // Grava array de retorno | 
        //------------------------+
        aAdd(_aMsgErro,{"0",RTrim(_cNumPedD), IIF(_nOpcA == 3,"Dados gravados com sucesso.","Pedido cancelado com sucesso.")})

    EndIf

EndIf

RestArea(_aArea)
Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} RemessaP
    @description Realiza a remessa dos pedidos DanaLog
    @type  Static Function
    @author Bernard M. Margarido
    @since 23/12/2020
/*/
/*************************************************************************************/
Static Function RemessaP(_cJSon,_nOpc)
Local _aArea            := GetArea()

Local aPvlNfs	        := {}
Local _aNotas	        := {}
Local _aNfGerada        := {}

Local _cNota            := ""
Local _cSerie           := ""
Local _cSituacao        := ""
Local _cNumPedD         := ""
Local _cPedido          := ""
Local _cDocCli          := ""
Local _cSerCli          := ""
Local _cChaveNFe        := ""
Local _cCnpjT           := ""
Local _cTipo            := ""
Local _cCliFor          := ""
Local _cLoja            := ""
Local _cPDFNfe          := ""
Local _cArqPDF          := ""
Local _cDirArq          := ""

Local _dDtEmiss         := ""

Local _nBytes           := 0
Local _nHdl             := 0
Local _nX               := 0
Local _nItemNf	        := 0
Local _nCalAcrs   	    := 1	
Local _nArredPrcLis	    := 1

Local _lBlqEst          := .F.
Local _lBlqCred         := .F.
Local _lRet			    := .F.
Local _lMostraCtb	    := .F.
Local _lAglutCtb	    := .F.
Local _lCtbOnLine	    := .F.
Local _lCtbCusto	    := .F.
Local _lReajuste	    := .F.
Local _lECF			    := .F.

Local _dDataMoe		    := Nil

Local _oJSon            := Nil 
Local _oRemessa         := Nil 

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .F.

//--------------------+
// SA2 - Fornecedores |
//--------------------+
dbSelectArea("SA2")
SA2->( dbSetOrder(1) )

//----------------+
// SA1 - Clientes |
//----------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )

//----------------------+
// SA4 - Transportadora |
//----------------------+
dbSelectArea("SA4")
SA4->( dbOrderNickname("DANALOGTRA") )

//-----------------------+
// SC5 - Pedido de Venda | 
//-----------------------+
dbSelectArea("SC5")
SC5->( dbOrderNickname("DANALOGPED") )

//-------------------------+
// Pedido de Venda - Itens |
//-------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

//----------------------------------+
// Pedido de Venda - Itens Liberado |
//----------------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//-----------------------+
// Condição de Pagamento |
//-----------------------+
dbSelectArea("SE4")
SE4->( dbSetOrder(1) )

//----------+
// Produtos |
//----------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//---------+
// Estoque |
//---------+
dbSelectArea("SB2")
SB2->( dbSetOrder(1) )

//--------------------------+
// Tipos de Entrada e Saida |
//--------------------------+
dbSelectArea("SF4")
SF4->( dbSetOrder(1) )

//-----------------------+
// JSON - Desesserializa |
//-----------------------+
_oJSon      := xFromJson(DecodeUTF8(_cJSon))
_cIDCliente := _oJSon[#"id_cliente"]
_oRemessa   := _oJSon[#"remessa"]

//--------------+
// Dados Remessa| 
//--------------+
_cSituacao  := _oRemessa[#"situacao"]
_cNumPedD   := PadR(_oRemessa[#"pedido"],_nTPedD)
_cDocCli    := _oRemessa[#"nota"]
_cSerCli    := _oRemessa[#"serie"]
_cChaveNFe  := _oRemessa[#"chave_nfe"]
_cPDFNfe    := Decode64(_oRemessa[#"pdf_nfe"])
_cDirArq    := "/" + _cIDCliente + "/"
_cArqPDF    := _cDocCli + "_" + _cSerCli + ".pdf"
_cCnpjT     := PadR(_oRemessa[#"transportadora"],_nTCNPJ)
_dDtEmiss   := cTod(_oRemessa[#"dt_emissao"])

//----------------+
// Cria diretorio |
//----------------+
MakeDir(_cDirArq)

//-----------------------+
// Cria pedido separação | 
//-----------------------+
If _cSituacao == "1"

    //----------------------------+
    // Valida se já existe pedido |
    //----------------------------+
    If !SC5->( dbSeek(xFilial("SC5") + _cNumPedD + _cIDCliente) )
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf   

    //---------------------------------------+
    // Valida se pedido pertence ao mesmo ID |
    //---------------------------------------+
    If Rtrim(SC5->C5_XIDLOGI) <> RTrim(_cIDCliente) 
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf 

    If ( !Empty(SC5->C5_NOTA) .And. !Empty(SC5->C5_SERIE) ) .And. ( RTrim(SC5->C5_NOTA) <> "XXXXXX" .And.  RTrim(SC5->C5_SERIE) <> "XXX" ) 
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido já expedido."})
        RestArea(_aArea)
        Return .F.
    EndIf

    //----------------+
    // Tipo de pedido | 
    //----------------+
    _cTipo  := SC5->C5_TIPO 
    _cCliFor:= SC5->C5_CLIENTE
    _cLoja  := SC5->C5_LOJACLI
    _cPedido:= SC5->C5_NUM 

    //----------------+
    // Salva PDF nota | 
    //----------------+
    If File(_cDirArq + _cArqPDF)
        FErase(_cDirArq + _cArqPDF)
    EndIf

    _nHdl := MsFCreate( _cDirArq + _cArqPDF,,,.F.)
    If _nHdl <= 0 
        aAdd(_aMsgErro,{"1",RTrim(_cIDCliente), "Erro ao salvar PDF da nota."})
        RestArea(_aArea)
        Return .F.
    EndIf

    //---------------+
    // Grava Arquivo |
    //---------------+
    _nBytes := FWrite(_nHdl, _cPDFNfe, Len(_cPDFNfe) + 2) 

    If _nBytes <= 0 
        aAdd(_aMsgErro,{"1",RTrim(_cIDCliente), "Erro ao salvar PDF da nota."})
        RestArea(_aArea)
        Return .F.
    EndIf
    
    //---------------+
    // Fecha Arquivo |
    //---------------+
    FClose(_nHdl)

//-------------------+
// Cancela separação | 
//-------------------+
ElseIf _cSituacao == "2"

    //----------------------------+
    // Valida se já existe pedido |
    //----------------------------+
    If !SC5->( dbSeek(xFilial("SC5") + _cNumPedD + _cIDCliente) )
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf  

    //---------------------------------------+
    // Valida se pedido pertence ao mesmo ID |
    //---------------------------------------+
    If Rtrim(SC5->C5_XIDLOGI) <> RTrim(_cIDCliente) 
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf 

    If ( !Empty(SC5->C5_NOTA) .And. !Empty(SC5->C5_SERIE) ) .And. ( RTrim(SC5->C5_NOTA) <> "XXXXXX" .And.  RTrim(SC5->C5_SERIE) <> "XXX" ) 
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido já expedido."})
        RestArea(_aArea)
        Return .F.
    EndIf

    //------------------------------------+
    // Valida se pedido pode se cancelado |
    //------------------------------------+
    If SC5->C5_XENVWMS == "9" .And. Rtrim(SC5->C5_NOTA) == "XXXXXX"
        aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Pedido já cancelado."})
        RestArea(_aArea)
        Return .F.
    EndIf

    //--------------------+
    // Deleta PDF da nota | 
    //--------------------+
    If File(_cDirArq + _cArqPDF)
       FErase(_cDirArq + _cArqPDF)
    EndIf

EndIf

//---------------------------+
// Valida cliente/fornecedor |
//---------------------------+
If _cTipo == "D"
    If !SA2->( dbSeek(xFilial("SA2") + _cCliFor + _cLoja) )
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Fornecedor não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf

    If RTrim(SA2->A2_XIDLOGI) <> RTrim(_cIDCliente)
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Fornecedor não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf

ElseIf _cTipo == "N"
    If !SA1->( dbSeek(xFilial("SA1") + _cCliFor + _cLoja) )
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Cliente não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf

    If RTrim(SA1->A1_XIDLOGI) <> RTrim(_cIDCliente)
        aAdd(_aMsgErro,{"1",RTrim(_cCnpj), "Cliente não localizado."})
        RestArea(_aArea)
        Return .F.
    EndIf

EndIf

//-----------------------+
// Valida transportadora |
//-----------------------+
If !SA4->( dbSeek(xFilial("SA4") + _cCnpjT + _cIDCliente) )
    aAdd(_aMsgErro,{"1",RTrim(_cCnpjT), "Transportadora não localizado."})
    RestArea(_aArea)
    Return .F.
EndIf

//--------------------------------+
// Valida se mudou transportadora | 
//--------------------------------+
If SC5->C5_TRANSP <> SA4->A4_COD
    RecLock("SC5",.F.)
        SC5->C5_TRANSP := SA4->A4_COD
    SC5->( MsUnLock() )
EndIf

//-----------------+
// Parametros Nota | 
//-----------------+
_cTransp    := SA4->A4_COD
_cSerie     := GetSerie(_cIDCliente)

//-------------------------------------------+
// Se não existe serie nao permite continuar | 
//-------------------------------------------+
If Empty(_cSerie)
    aAdd(_aMsgErro,{"1",RTrim(_cIDCliente), "Serie da nota nao localizada."})
    RestArea(_aArea)
    Return .F.
EndIf

_nItemNf	:= a460NumIt(_cSerie)

//-----------------------+
// SC5 - Pedido de Venda | 
//-----------------------+
SC5->( dbSetOrder(1) ) 
SC5->( dbSeek(xFilial("SC5") + _cPedido) )

//---------------------------+
// Posiciona Itens liberados |
//---------------------------+
SC9->( dbSeek(xFilial("SC9") + _cPedido) )
While SC9->( !Eof() .And. xFilial("SC9") + _cPedido == SC9->C9_FILIAL + SC9->C9_PEDIDO )

	//----------------------------------------+
	// Valida se está com bloqueio de estoque | 
	//----------------------------------------+
	If ( SC9->C9_BLEST <> "10" ) .AND. !Empty(SC9->C9_BLEST)
		CoNout("<< DANALOG >> REMESSA - PEDIDO " + _cNumPedD + " PRODUTO " + SC9->C9_PRODUTO + " SEM SALDO EM ESTOQUE.")
		_lBlqEst := .T.
		Exit
	EndIf
				
	//----------------------------------------+
	// Valida se está com bloqueio de credito | 
	//----------------------------------------+			
	If (SC9->C9_BLCRED <> "10") .AND. !Empty(SC9->C9_BLCRED)
		CoNout("<< DANALOG >> REMESSA - PEDIDO " + _cNumPedD + " PRODUTO " + SC9->C9_PRODUTO + " SEM CREDITO.")
		_lBlqCred := .T.
		Exit
	EndIf

	//--------------------------+
	// Posiciona Item do Pedido |   
	//--------------------------+
	SC6->( dbSetOrder(1) )
	SC6->( dbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO) )

	//---------------------------------+
	// Posiciona Condição de Pagamento |   
	//---------------------------------+
	SE4->( dbSetOrder(1) )
	SE4->( dbSeek(xFilial("SE4") + SC5->C5_CONDPAG) )

	//-------------------+
	// Posiciona Produto |   
	//-------------------+
	SB1->( dbSetOrder(1) )
	SB1->( dbSeek(xFilial("SB1") + SC9->C9_PRODUTO) )

	//------------------------------+
	// Posiciona Estoque de Produto |   
	//------------------------------+
	SB2->( dbSetOrder(1) )
	SB2->( dbSeek(xFilial("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL) )

	//---------------+
	// Posiciona Tes |   
	//---------------+
	SF4->( dbSetOrder(1) )
	SF4->( dbSeek(xFilial("SF4") + SC6->C6_TES) )

	//----------------------------------+
	// Adiciona itens a serem faturados |
	//----------------------------------+
	aAdd(aPvlNfs,{ 	SC9->C9_PEDIDO,;
					SC9->C9_ITEM,;
					SC9->C9_SEQUEN,;
					SC9->C9_QTDLIB,;
					SC9->C9_PRCVEN,;
					SC9->C9_PRODUTO,;
					.F.,;
					SC9->(RecNo()),;
					SC5->(RecNo()),;
					SC6->(RecNo()),;
					SE4->(RecNo()),;
					SB1->(RecNo()),;
					SB2->(RecNo()),;
					SF4->(RecNo())})


	SC9->( dbSkip() )
EndDo

//----------------------------------------------+
// Exibe parametros para geração da Nota Fiscal |
//----------------------------------------------+
If !_lBlqCred .And. !_lBlqEst .And. Len(aPvlNfs) > 0
	
	//---------------------------+
	// Cria array de notas vazio |
	//---------------------------+
	aAdd(_aNotas,{})

	//----------------------------------------------------+
	// Separa notas caso ultrapasse maximo total de itens |  
	//----------------------------------------------------+
	For _nX := 1 To Len(aPvlNfs)
		If Len(_aNotas[Len(_aNotas)]) >= _nItemNf
			aAdd(_aNotas,{})
		EndIf
		aAdd(_aNotas[Len(_aNotas)], aClone(aPvlNfs[_nX] ))
	Next _nX
	
	//-----------------------+
	// Gera notas e-Commerce |
	//-----------------------+
	For _nX := 1 To Len(_aNotas)	
		_cNota := MaPvlNfs(_aNotas[_nX],_cSerie,_lMostraCtb,_lAglutCtb,_lCtbOnLine,_lCtbCusto,_lReajuste,_nCalAcrs,_nArredPrcLis,.F.,_lECF,,,,,,_dDataMoe)
		_cSerie:= PadR(_cSerie,_nTSerie)
		aAdd(_aNfGerada,PadR(_cNota,_nTDoc))
	Next _nX

	//----------------------+
	// Valida notas geradas |
	//----------------------+
	dbSelectArea("SF2")
	SF2->( dbSetOrder(1) )
    
	For _nX := 1 To Len(_aNfGerada)	
		If Empty(_aNfGerada[_nX])
			CoNout("<< DANALOG >> REMESSA - ERRO AO GERAR A NOTA PEDIDO " + _cNumPedD + " NOTA NAO GERADA.")
            aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Processo nao concluido. Nota nao processada."})            
			_lRet	:= .F.
		Else
			If !SF2->( dbSeek(xFilial("SF2") + _aNfGerada[_nX] + PadR(_cSerie,_nTSerie)) )
				CoNout("<< DANALOG >> REMESSA - NOTA " + _aNfGerada[_nX] + " SERIE " + _cSerie + " NAO LOCALIZADA PARA O PEDIDO " + _cNumPedD + " .")
                aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Processo nao concluido. Nota nao processada"})            
				_lRet	:= .F.
            Else
                _lRet   := .T.
                RecLock("SF2",.F.)
                    SF2->F2_XCHVNFE := _cChaveNFe
                    SF2->F2_XIDLOGI := _cIDCliente
                SF2->( MsUnLock() )
			EndIf
		EndIf
	Next _nX
Else
    aAdd(_aMsgErro,{"1",RTrim(_cNumPedD), "Processo nao concluido. Pedido com bloqueio de saldo."})            
	CoNout("<< DANALOG >> REMESSA - PEDIDO " + _cNumPedD + " COM BLOQUEIO DE SALDO.")
	_lRet	:= .F.
EndIf

If _lRet
    aAdd(_aMsgErro,{"0",RTrim(_cNumPedD), "Nota processada com sucesso. "})
EndIF

RestArea(_aArea)
Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} PedidoL
    @description Realiza a liberação do pedido de venda
    @type  Static Function
    @author Bernard M. Margarido
    @since 23/12/2020
/*/
/*************************************************************************************/
Static Function PedidoL(_cNumPV,_lEstorna)
Local _aArea        := GetArea()

Local _nCredito     := 0

Local _lCredito 	:= .T.
Local _lEstoque		:= .T.
Local _lLiber		:= .T.
Local _lTransf   	:= .F.

Default _lEstorna   := .F.

//-------------------+
// Estorna liberação |
//-------------------+
If _lEstorna
    //-----------------------+
    // Itens pedido de venda |
    //-----------------------+
    dbSelectArea("SC6")
    SC6->( dbSetOrder(1) )
    SC6->( dbSeeK(xFilial("SC6") + _cNumPV) )
    While SC6->( !Eof() .And. xFilial("SC6") + _cNumPV == SC6->C6_FILIAL + SC6->C6_NUM )
        MaAvalSC6("SC6",4,"SC5",Nil,Nil,Nil,Nil,Nil,Nil,@_nCredito)
        SC6->( dbSkip() )
    EndDo

//-------------------+
// Realiza liberação |
//-------------------+
Else
    //-----------------------+
    // Itens pedido de venda |
    //-----------------------+
    dbSelectArea("SC6")
    SC6->( dbSetOrder(1) )
    SC6->( dbSeeK(xFilial("SC6") + _cNumPV) )
    While SC6->( !Eof() .And. xFilial("SC6") + _cNumPV == SC6->C6_FILIAL + SC6->C6_NUM )
        MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,@_lCredito,@_lEstoque,.F.,.F.,_lLiber,_lTransf)
        SC6->( dbSkip() )
    EndDo

    //---------------------------+
    // Grava liberação do Pedido |
    //---------------------------+
    MaLiberOk({_cNumPV},.T.) 

    //-----------------------------+
    // Destrava todos os registros |
    //-----------------------------+
    MsUnLockAll()

EndIf

RestArea(_aARea)
Return Nil 

/*************************************************************************************/
/*/{Protheus.doc} PrdGetQry
    @description Consulta produto 
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/11/2020
/*/
/*************************************************************************************/
Static Function PrdGetQry(_cAlias,_cCodigo,_cIdCliente,_cPage,_cPerPage)

Local _cQuery := ""

If !PrdGetQryT(_cCodigo,_cIdCliente,_cPage,_cPerPage)
    Return .F.
EndIf

_cQuery := " SELECT " + CRLF
_cQuery += "	TOP(" + _cPerPage + ") RNUM, " + CRLF
_cQuery += "	CODIGO, " + CRLF
_cQuery += "	DESCRICAO, " + CRLF
_cQuery += "	TIPO, " + CRLF
_cQuery += "	UNIDADE, " + CRLF
_cQuery += "	SEG_UNIDADE, " + CRLF
_cQuery += "	FATOR, " + CRLF
_cQuery += "	TIPO_FATOR, " + CRLF
_cQuery += "	COD_BARRAS, " + CRLF
_cQuery += "	COD_CAIXA, " + CRLF
_cQuery += "	ARMAZEM, " + CRLF
_cQuery += "	RASTRO, " + CRLF
_cQuery += "	NCM, " + CRLF
_cQuery += "	PESO_LIQUIDO, " + CRLF
_cQuery += "	PESO_BRUTO, " + CRLF
_cQuery += "	SITUACAO, " + CRLF
_cQuery += "	ORIGEM, " + CRLF
_cQuery += "	COMP_PRODUTO, " + CRLF
_cQuery += "	ALTURA_PRODUTO, " + CRLF
_cQuery += "	LARGURA_PRODUTO, " + CRLF
_cQuery += "	QTD_EMB, " + CRLF
_cQuery += "	QTD_QE, " + CRLF
_cQuery += "	COMP_CAIXA, " + CRLF
_cQuery += "	LARGURA_CAIXA, " + CRLF
_cQuery += "	ALTURA_CAIXA, " + CRLF
_cQuery += "	FATARMA, " + CRLF
_cQuery += "	EMPMAX0 " + CRLF
_cQuery += " FROM ( " + CRLF
_cQuery += "    SELECT " + CRLF
_cQuery += "		ROW_NUMBER() OVER(ORDER BY B1.B1_COD) RNUM, " + CRLF     
_cQuery += "	    B1.B1_COD CODIGO, " + CRLF
_cQuery += "	    B1.B1_DESC DESCRICAO, " + CRLF
_cQuery += "	    B1.B1_TIPO TIPO, " + CRLF
_cQuery += "	    B1.B1_UM UNIDADE, " + CRLF
_cQuery += "	    B1.B1_SEGUM SEG_UNIDADE, " + CRLF
_cQuery += "	    B1.B1_CONV FATOR, " + CRLF
_cQuery += "	    B1.B1_TIPCONV TIPO_FATOR, " + CRLF
_cQuery += "	    B1.B1_CODGTIN COD_BARRAS, " + CRLF 
_cQuery += "	    B1.B1_XEANCX COD_CAIXA, " + CRLF
_cQuery += "	    B1.B1_LOCPAD ARMAZEM, " + CRLF
_cQuery += "	    B1.B1_RASTRO RASTRO, " + CRLF
_cQuery += "	    B1.B1_POSIPI NCM, " + CRLF
_cQuery += "	    B1.B1_PESO PESO_LIQUIDO, " + CRLF
_cQuery += "	    B1.B1_PESBRU PESO_BRUTO, " + CRLF
_cQuery += "	    B1.B1_MSBLQL SITUACAO, " + CRLF
_cQuery += "	    B1.B1_ORIGEM ORIGEM, " + CRLF
_cQuery += "        COALESCE(B5.B5_COMPR,0) COMP_PRODUTO, " + CRLF
_cQuery += "	    COALESCE(B5.B5_ALTURA,0) ALTURA_PRODUTO, " + CRLF
_cQuery += "	    COALESCE(B5.B5_LARG,0) LARGURA_PRODUTO, " + CRLF
_cQuery += "	    COALESCE(B5.B5_EMB1,'') QTD_EMB, " + CRLF
_cQuery += "	    COALESCE(B5.B5_QE1,0) QTD_QE, " + CRLF
_cQuery += "	    COALESCE(B5.B5_COMPRLC,0) COMP_CAIXA, " + CRLF
_cQuery += "	    COALESCE(B5.B5_LARGLC,0) LARGURA_CAIXA, " + CRLF
_cQuery += "	    COALESCE(B5.B5_ALTURLC,0) ALTURA_CAIXA, " + CRLF
_cQuery += "	    COALESCE(B5.B5_FATARMA,0) FATARMA, " + CRLF
_cQuery += "	    COALESCE(B5.B5_EMPMAX,0) EMPMAX0 " + CRLF
_cQuery += "    FROM " + CRLF
_cQuery += "	    " + RetSqlName("SB1") + " B1 " + CRLF
_cQuery += "	    LEFT JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = B1.B1_COD AND B5.B5_XIDLOGI = B1.B1_XIDLOGI AND B5.D_E_L_E_T_ = '' " + CRLF
_cQuery += "    WHERE " + CRLF
_cQuery += "    	B1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
If !Empty(_cCodigo)
    _cQuery += "    	B1.B1_COD = '" + _cCodigo + "' AND " + CRLF
EndIf
_cQuery += "    	B1.B1_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "    	B1.D_E_L_E_T_ = '' "
_cQuery += "	) PRODUTOS " + CRLF
_cQuery += "	WHERE RNUM > " + _cPerPage + " * (" + _cPage + " - 1) " 
_cQuery += "	ORDER BY CODIGO "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} PrdGetQryT
    @description 
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function PrdGetQryT(_cCodigo,_cIdCliente,_cPage,_cPerPage)
Local _cAlias   := ""
Local _cQuery   := ""

_nTotQry        := 0
_nTotPag        := 0

_cQuery := " SELECT " + CRLF
_cQuery += "	COUNT(B1.B1_COD) TOTREG " + CRLF     
_cQuery += "    FROM " + CRLF
_cQuery += "	    " + RetSqlName("SB1") + " B1 " + CRLF
_cQuery += "	    LEFT JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = B1.B1_COD AND B5.B5_XIDLOGI = B1.B1_XIDLOGI AND B5.D_E_L_E_T_ = '' " + CRLF
_cQuery += "    WHERE " + CRLF
_cQuery += "    	B1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
If !Empty(_cCodigo)
    _cQuery += "    	B1.B1_COD = '" + _cCodigo + "' AND " + CRLF
EndIf
_cQuery += "    	B1.B1_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "    	B1.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

_nTotQry := (_cAlias)->TOTREG

If _nTotQry <= Val(_cPerPage)
	_nTotPag := 1 
Else
	If Mod(_nTotQry,Val(_cPerPage)) <> 0
		_nTotPag := Int(_nTotQry/Val(_cPerPage)) + 1
	Else
		_nTotPag := Int(_nTotQry/Val(_cPerPage))	
	EndIf
EndIf

(_cAlias)->( dbCloseArea() )

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} CliGetQry
    @description Consulta clientes DanaLog
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function CliGetQry(_cAlias,_cCnpj,_cIdCliente,_cPage,_cPerPage)
Local _cQuery := ""

If !CliGetQryT(_cCnpj,_cIdCliente,_cPage,_cPerPage)
    Return .F.
EndIf

_cQuery := " SELECT " + CRLF
_cQuery += "	TOP(" + _cPerPage + ") RNUM, " + CRLF
_cQuery += "	RAZAO, " + CRLF
_cQuery += "	NREDUZ, " + CRLF
_cQuery += "	CNPJ_CPF, " + CRLF
_cQuery += "	TIPO, " + CRLF
_cQuery += "	INSCRICAO, " + CRLF
_cQuery += "	ENDERECO, " + CRLF
_cQuery += "	BAIRRO, " + CRLF
_cQuery += "	MUNICIPIO, " + CRLF
_cQuery += "	CEP, " + CRLF
_cQuery += "	ESTADO, " + CRLF
_cQuery += "	COMPLEMENTO, " + CRLF
_cQuery += "	TELEFONE, " + CRLF
_cQuery += "	DDD, " + CRLF
_cQuery += "	EMAIL, " + CRLF
_cQuery += "	SITUACAO " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += " ( " + CRLF
_cQuery += "	SELECT " + CRLF 
_cQuery += "		ROW_NUMBER() OVER(ORDER BY A1.A1_CGC) RNUM, " + CRLF 
_cQuery += "		A1.A1_NOME RAZAO, " + CRLF
_cQuery += "		A1.A1_NREDUZ NREDUZ, " + CRLF
_cQuery += "		A1.A1_CGC CNPJ_CPF, " + CRLF
_cQuery += "		A1.A1_TIPO TIPO, " + CRLF
_cQuery += "		A1.A1_INSCR INSCRICAO, " + CRLF
_cQuery += "		A1.A1_END ENDERECO, " + CRLF
_cQuery += "		A1.A1_BAIRRO BAIRRO, " + CRLF
_cQuery += "		A1.A1_MUN MUNICIPIO, " + CRLF
_cQuery += "		A1.A1_CEP CEP, " + CRLF
_cQuery += "		A1.A1_EST ESTADO, " + CRLF
_cQuery += "		A1.A1_COMPLEM COMPLEMENTO, " + CRLF
_cQuery += "		A1.A1_TEL TELEFONE, " + CRLF
_cQuery += "		A1.A1_DDD DDD, " + CRLF
_cQuery += "		A1.A1_EMAIL EMAIL, " + CRLF
_cQuery += "		A1.A1_MSBLQL SITUACAO " + CRLF
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("SA1") + " A1 " + CRLF  
_cQuery += "	WHERE " + CRLF
_cQuery += "		A1.A1_FILIAL = '" + xFilial("SA1") + "' AND " + CRLF
If !Empty(_cCnpj)	 
    _cQuery += "			A1.A1_CGC = '" + _cCnpj + "' AND " + CRLF
EndIf
_cQuery += "	    A1.A1_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "	    A1.D_E_L_E_T_ = '' " + CRLF	
_cQuery += " ) CLIENTES " + CRLF
_cQuery += " WHERE RNUM > " + _cPerPage + " * (" + _cPage + " - 1) " + CRLF
_cQuery += " ORDER BY RAZAO "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} CliGetQryT
    @description Calcula total de registros para retorno dos dados dos clientes
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function CliGetQryT(_cCnpj,_cIdCliente,_cPage,_cPerPage)
Local _cAlias   := ""
Local _cQuery   := ""

_nTotQry        := 0
_nTotPag        := 0

_cQuery := " SELECT " + CRLF
_cQuery += "	COUNT(A1.A1_CGC) TOTREG " + CRLF     
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("SA1") + " A1 " + CRLF  
_cQuery += "	WHERE " + CRLF
_cQuery += "		A1.A1_FILIAL = '" + xFilial("SA1") + "' AND " + CRLF
If !Empty(_cCnpj)	 
    _cQuery += "			A1.A1_CGC = '" + _cCnpj + "' AND " + CRLF
EndIf
_cQuery += "	    A1.A1_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "	    A1.D_E_L_E_T_ = '' " 

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

_nTotQry := (_cAlias)->TOTREG

If _nTotQry <= Val(_cPerPage)
	_nTotPag := 1 
Else
	If Mod(_nTotQry,Val(_cPerPage)) <> 0
		_nTotPag := Int(_nTotQry/Val(_cPerPage)) + 1
	Else
		_nTotPag := Int(_nTotQry/Val(_cPerPage))	
	EndIf
EndIf

(_cAlias)->( dbCloseArea() )
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ForGetQry
    @description Consulta fornecedores DanaLog
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function ForGetQry(_cAlias,_cCnpj,_cIdCliente,_cPage,_cPerPage)
Local _cQuery := ""

If !ForGetQryT(_cCnpj,_cIdCliente,_cPage,_cPerPage)
    Return .F.
EndIf

_cQuery := " SELECT " + CRLF
_cQuery += "	TOP(" + _cPerPage + ") RNUM, " + CRLF
_cQuery += "	RAZAO, " + CRLF
_cQuery += "	NREDUZ, " + CRLF
_cQuery += "	CNPJ_CPF, " + CRLF
_cQuery += "	TIPO, " + CRLF
_cQuery += "	INSCRICAO, " + CRLF
_cQuery += "	ENDERECO, " + CRLF
_cQuery += "	BAIRRO, " + CRLF
_cQuery += "	MUNICIPIO, " + CRLF
_cQuery += "	CEP, " + CRLF
_cQuery += "	ESTADO, " + CRLF
_cQuery += "	COMPLEMENTO, " + CRLF
_cQuery += "	TELEFONE, " + CRLF
_cQuery += "	DDD, " + CRLF
_cQuery += "	EMAIL, " + CRLF
_cQuery += "	SITUACAO " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += " ( " + CRLF
_cQuery += "	SELECT " + CRLF 
_cQuery += "		ROW_NUMBER() OVER(ORDER BY A2.A2_CGC) RNUM, " + CRLF 
_cQuery += "		A2.A2_NOME RAZAO, " + CRLF
_cQuery += "		A2.A2_NREDUZ NREDUZ, " + CRLF
_cQuery += "		A2.A2_CGC CNPJ_CPF, " + CRLF
_cQuery += "		A2.A2_TIPO TIPO, " + CRLF
_cQuery += "		A2.A2_INSCR INSCRICAO, " + CRLF
_cQuery += "		A2.A2_END ENDERECO, " + CRLF
_cQuery += "		A2.A2_BAIRRO BAIRRO, " + CRLF
_cQuery += "		A2.A2_MUN MUNICIPIO, " + CRLF
_cQuery += "		A2.A2_CEP CEP, " + CRLF
_cQuery += "		A2.A2_EST ESTADO, " + CRLF
_cQuery += "		A2.A2_COMPLEM COMPLEMENTO, " + CRLF
_cQuery += "		A2.A2_TEL TELEFONE, " + CRLF
_cQuery += "		A2.A2_DDD DDD, " + CRLF
_cQuery += "		A2.A2_EMAIL EMAIL, " + CRLF
_cQuery += "		A2.A2_MSBLQL SITUACAO " + CRLF
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("SA2") + " A2 " + CRLF  
_cQuery += "	WHERE " + CRLF
_cQuery += "		A2.A2_FILIAL = '" + xFilial("SA2") + "' AND " + CRLF
If !Empty(_cCnpj)	 
    _cQuery += "			A2.A2_CGC = '" + _cCnpj + "' AND " + CRLF
EndIf
_cQuery += "	    A2.A2_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "	    A2.D_E_L_E_T_ = '' " + CRLF	
_cQuery += " ) FORNECEDORES " + CRLF
_cQuery += " WHERE RNUM > " + _cPerPage + " * (" + _cPage + " - 1) " + CRLF
_cQuery += " ORDER BY RAZAO "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ForGetQryT
    @description Calcula total de registros para retorno dos dados dos fornecedores
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function ForGetQryT(_cCnpj,_cIdCliente,_cPage,_cPerPage)
Local _cAlias   := ""
Local _cQuery   := ""

_nTotQry        := 0
_nTotPag        := 0

_cQuery := " SELECT " + CRLF
_cQuery += "	COUNT(A2.A2_CGC) TOTREG " + CRLF     
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("SA2") + " A2 " + CRLF  
_cQuery += "	WHERE " + CRLF
_cQuery += "		A2.A2_FILIAL = '" + xFilial("SA2") + "' AND " + CRLF
If !Empty(_cCnpj)	 
    _cQuery += "			A2.A2_CGC = '" + _cCnpj + "' AND " + CRLF
EndIf
_cQuery += "	    A2.A2_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "	    A2.D_E_L_E_T_ = '' " 

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

_nTotQry := (_cAlias)->TOTREG

If _nTotQry <= Val(_cPerPage)
	_nTotPag := 1 
Else
	If Mod(_nTotQry,Val(_cPerPage)) <> 0
		_nTotPag := Int(_nTotQry/Val(_cPerPage)) + 1
	Else
		_nTotPag := Int(_nTotQry/Val(_cPerPage))	
	EndIf
EndIf

(_cAlias)->( dbCloseArea() )
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} TraGetQry
    @description Calcula total de registros para retorno dos dados das transportadoras
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function TraGetQry(_cAlias,_cCnpj,_cIdCliente,_cPage,_cPerPage)
Local _cQuery := ""

If !TraGetQryT(_cCnpj,_cIdCliente,_cPage,_cPerPage)
    Return .F.
EndIf

_cQuery := " SELECT " + CRLF
_cQuery += "	TOP(" + _cPerPage + ") RNUM, " + CRLF
_cQuery += "	RAZAO, " + CRLF
_cQuery += "	NREDUZ, " + CRLF
_cQuery += "	CNPJ_CPF, " + CRLF
_cQuery += "	ENDERECO, " + CRLF
_cQuery += "	BAIRRO, " + CRLF
_cQuery += "	MUNICIPIO, " + CRLF
_cQuery += "	CEP, " + CRLF
_cQuery += "	ESTADO, " + CRLF
_cQuery += "	COMPLEMENTO, " + CRLF
_cQuery += "	TELEFONE, " + CRLF
_cQuery += "	DDD, " + CRLF
_cQuery += "	EMAIL, " + CRLF
_cQuery += "	SITUACAO " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += " ( " + CRLF
_cQuery += "	SELECT " + CRLF 
_cQuery += "		ROW_NUMBER() OVER(ORDER BY A4.A4_CGC) RNUM, " + CRLF 
_cQuery += "		A4.A4_NOME RAZAO, " + CRLF
_cQuery += "		A4.A4_NREDUZ NREDUZ, " + CRLF
_cQuery += "		A4.A4_CGC CNPJ_CPF, " + CRLF
_cQuery += "		A4.A4_END ENDERECO, " + CRLF
_cQuery += "		A4.A4_BAIRRO BAIRRO, " + CRLF
_cQuery += "		A4.A4_MUN MUNICIPIO, " + CRLF
_cQuery += "		A4.A4_CEP CEP, " + CRLF
_cQuery += "		A4.A4_EST ESTADO, " + CRLF
_cQuery += "		A4.A4_COMPLEM COMPLEMENTO, " + CRLF
_cQuery += "		A4.A4_TEL TELEFONE, " + CRLF
_cQuery += "		A4.A4_DDD DDD, " + CRLF
_cQuery += "		A4.A4_EMAIL EMAIL, " + CRLF
_cQuery += "		A4.A4_MSBLQL SITUACAO " + CRLF
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("SA4") + " A4 " + CRLF  
_cQuery += "	WHERE " + CRLF
_cQuery += "		A4.A4_FILIAL = '" + xFilial("SA4") + "' AND " + CRLF
If !Empty(_cCnpj)	 
    _cQuery += "			A4.A4_CGC = '" + _cCnpj + "' AND " + CRLF
EndIf
_cQuery += "	    A4.A4_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "	    A4.D_E_L_E_T_ = '' " + CRLF	
_cQuery += " ) FORNECEDORES " + CRLF
_cQuery += " WHERE RNUM > " + _cPerPage + " * (" + _cPage + " - 1) " + CRLF
_cQuery += " ORDER BY RAZAO "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} TraGetQryT
    @description Calcula total de registros para retorno dos dados das transportadoras
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function TraGetQryT(_cCnpj,_cIdCliente,_cPage,_cPerPage)
Local _cAlias   := ""
Local _cQuery   := ""

_nTotQry        := 0
_nTotPag        := 0

_cQuery := " SELECT " + CRLF
_cQuery += "	COUNT(A4.A4_CGC) TOTREG " + CRLF     
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("SA4") + " A4 " + CRLF  
_cQuery += "	WHERE " + CRLF
_cQuery += "		A4.A4_FILIAL = '" + xFilial("SA4") + "' AND " + CRLF
If !Empty(_cCnpj)	 
    _cQuery += "			A4.A4_CGC = '" + _cCnpj + "' AND " + CRLF
EndIf
_cQuery += "	    A4.A4_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "	    A4.D_E_L_E_T_ = '' " 

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

_nTotQry := (_cAlias)->TOTREG

If _nTotQry <= Val(_cPerPage)
	_nTotPag := 1 
Else
	If Mod(_nTotQry,Val(_cPerPage)) <> 0
		_nTotPag := Int(_nTotQry/Val(_cPerPage)) + 1
	Else
		_nTotPag := Int(_nTotQry/Val(_cPerPage))	
	EndIf
EndIf

(_cAlias)->( dbCloseArea() )
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} NfeGetQry
    @description Consulta nota de recebimento 
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function NfeGetQry(_cAlias,_cNota,_cSerie,_cIdCliente,_cPage,_cPerPage)
Local _cQuery := ""

If !NfeGetQryT(_cNota,_cSerie,_cIdCliente,_cPage,_cPerPage)
    Return .F.
EndIf

_cQuery := " SELECT " + CRLF
_cQuery += "	TOP(" + _cPerPage + ") RNUM, " + CRLF
_cQuery += "	DOCUMENTO, " + CRLF
_cQuery += "	SERIE, " + CRLF
_cQuery += "	SITUACAO, " + CRLF
_cQuery += "	TIPO, " + CRLF
_cQuery += "	DT_EMISSAO, " + CRLF
_cQuery += "	DT_ENTRADA, " + CRLF
_cQuery += "	CODIGO, " + CRLF
_cQuery += "	LOJA, " + CRLF
_cQuery += "	CNPJ_CPF, " + CRLF
_cQuery += "	NOME_CLIFOR, " + CRLF
_cQuery += "	CNPJ_TRANSP, " + CRLF
_cQuery += "	NOME_TRANSP " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += " ( " + CRLF
_cQuery += "	SELECT " + CRLF
_cQuery += "		ROW_NUMBER() OVER(ORDER BY F1.F1_DOC) RNUM, " + CRLF
_cQuery += "		F1.F1_DOC DOCUMENTO, " + CRLF
_cQuery += "		F1.F1_SERIE SERIE, " + CRLF
_cQuery += "		F1.F1_XENVWMS SITUACAO, " + CRLF
_cQuery += "		F1.F1_TIPO TIPO, " + CRLF
_cQuery += "		F1.F1_EMISSAO DT_EMISSAO, " + CRLF
_cQuery += "		F1.F1_DTDIGIT DT_ENTRADA, " + CRLF
_cQuery += "		CASE WHEN F1.F1_TIPO = 'N' THEN A2.A2_COD ELSE A1.A1_COD END CODIGO, " + CRLF
_cQuery += "		CASE WHEN F1.F1_TIPO = 'N' THEN A2.A2_LOJA ELSE A1.A1_LOJA END LOJA, " + CRLF
_cQuery += "		CASE WHEN F1.F1_TIPO = 'N' THEN A2.A2_CGC ELSE A1.A1_CGC END CNPJ_CPF, " + CRLF
_cQuery += "		CASE WHEN F1.F1_TIPO = 'N' THEN A2.A2_NOME ELSE A1.A1_NOME END NOME_CLIFOR, " + CRLF
_cQuery += "		A4.A4_CGC CNPJ_TRANSP, " + CRLF
_cQuery += "		A4.A4_NOME NOME_TRANSP " + CRLF			 
_cQuery += " FROM " + CRLF
_cQuery += "		" + RetSqlName("SF1") + " F1 " + CRLF
_cQuery += "		LEFT JOIN " + RetSqlName("SA2") + " A2 ON A2.A2_FILIAL = '" + xFilial("SA2") + "' AND A2.A2_COD = F1.F1_FORNECE AND A2.A2_LOJA = F1.F1_LOJA AND A2.A2_XIDLOGI = F1.F1_XIDLOGI AND A2.D_E_L_E_T_ = '' " + CRLF
_cQuery += "		LEFT JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = F1.F1_FORNECE AND A1.A1_LOJA = F1.F1_LOJA AND A1.A1_XIDLOGI = F1.F1_XIDLOGI AND A1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "		LEFT JOIN " + RetSqlName("SA4") + " A4 ON A4.A4_FILIAL = '" + xFilial("SA4") + "' AND A4.A4_COD = F1.F1_TRANSP AND A4.A4_XIDLOGI = F1.F1_XIDLOGI AND A1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "		F1.F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
_cQuery += "		F1.F1_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF 

If !Empty(_cNota) 
    _cQuery += "		F1.F1_DOC = '" + _cNota  + "' AND " + CRLF
EndIf
If !Empty(_cSerie) 
    _cQuery += "		F1.F1_SERIE = '" + _cSerie + "' AND " + CRLF
EndIf

_cQuery += "		F1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ) RECEBIMENTO " + CRLF
_cQuery += " ORDER BY DOCUMENTO,SERIE "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} NfeGetQryT
    @description Consulta nota de recebimento
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function NfeGetQryT(_cNota,_cSerie,_cIdCliente,_cPage,_cPerPage)
Local _cQuery   := ""
Local _cAlias   := ""

_cQuery := " SELECT 
_cQuery += "    COUNT(F1.F1_DOC) TOTREG
_cQuery += " FROM 
_cQuery += "    " + RetSqlName("SF1") + " F1 
_cQuery += "    LEFT JOIN " + RetSqlName("SA2") + " A2 ON A2.A2_FILIAL = '" + xFilial("SA2") + "' AND A2.A2_COD = F1.F1_FORNECE AND A2.A2_LOJA = F1.F1_LOJA AND A2.A2_XIDLOGI = F1.F1_XIDLOGI AND A2.D_E_L_E_T_ = ''
_cQuery += "    LEFT JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = F1.F1_FORNECE AND A1.A1_LOJA = F1.F1_LOJA AND A1.A1_XIDLOGI = F1.F1_XIDLOGI AND A1.D_E_L_E_T_ = ''
_cQuery += "    LEFT JOIN " + RetSqlName("SA4") + " A4 ON A4.A4_FILIAL = '" + xFilial("SA4") + "' AND A4.A4_COD = F1.F1_TRANSP AND A4.A4_XIDLOGI = F1.F1_XIDLOGI AND A1.D_E_L_E_T_ = ''
_cQuery += " WHERE 
_cQuery += "		F1.F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
_cQuery += "		F1.F1_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF 

If !Empty(_cNota) 
    _cQuery += "		F1.F1_DOC = '" + _cNota  + "' AND " + CRLF
EndIf
If !Empty(_cSerie) 
    _cQuery += "		F1.F1_SERIE = '" + _cSerie + "' AND " + CRLF
EndIf

_cQuery += "		F1.D_E_L_E_T_ = '' " + CRLF

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

_nTotQry := (_cAlias)->TOTREG

If _nTotQry <= Val(_cPerPage)
	_nTotPag := 1 
Else
	If Mod(_nTotQry,Val(_cPerPage)) <> 0
		_nTotPag := Int(_nTotQry/Val(_cPerPage)) + 1
	Else
		_nTotPag := Int(_nTotQry/Val(_cPerPage))	
	EndIf
EndIf

(_cAlias)->( dbCloseArea() )

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ProdutoCompl
    @description Grava informações de complemento de produto 
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function ProdutoCompl(_cIDCliente,_cCodProd,_cDescri,_nPesoLiq,_nPesoBru,_nAltura,_nLargura,;
                             _nCompr,_nPesLEmb,_nPesBEmb,_nAlturaE,_nLarguraE,_nComprE,;
                             _cTpEmb,_nQtdEmb,_nTotEmp,_nTotPalet,_cMsgErro)
Local _lRet     := .T.

Local _nFator   := Int(_nTotPalet/_nTotEmp)
Local _nOpc     := 3

Local _aCompPrd := {}

dbSelectArea("SB5")
SB5->( dbSetOrder(1) )
If SB5->( dbSeek(xFilial("SB5") + _cCodProd) )
    _nOpc := 4
EndIf

aAdd(_aCompPrd, {"B5_COD"       , _cCodProd     ,   Nil })
aAdd(_aCompPrd, {"B5_CEME"      , _cDescri      ,   Nil })
aAdd(_aCompPrd, {"B5_COMPR"     , _nCompr       ,   Nil })
aAdd(_aCompPrd, {"B5_ESPESS"    , _nCompr       ,   Nil })
aAdd(_aCompPrd, {"B5_ALTURA"    , _nAltura      ,   Nil })
aAdd(_aCompPrd, {"B5_LARG"      , _nLargura     ,   Nil })
aAdd(_aCompPrd, {"B5_EMB1"      , _cTpEmb       ,   Nil })
aAdd(_aCompPrd, {"B5_QE1"       , _nQtdEmb      ,   Nil })
aAdd(_aCompPrd, {"B5_COMPRLC"   , _nComprE      ,   Nil })
aAdd(_aCompPrd, {"B5_LARGLC"    , _nLarguraE    ,   Nil })
aAdd(_aCompPrd, {"B5_ALTURLC"   , _nAlturaE     ,   Nil })
aAdd(_aCompPrd, {"B5_FATARMA"   , _nFator       ,   Nil })
aAdd(_aCompPrd, {"B5_EMPMAX"    , _nTotEmp      ,   Nil })
aAdd(_aCompPrd, {"B5_XIDLOGI"   , _cIDCliente   ,  Nil  })

lMsErroAuto     := .F.
lAutoErrNoFile  := .T.

MSExecAuto({|x,y| Mata180(x,y)},_aCompPrd, _nOpc)

//--------------------------+
// Erro gravação de produto | 
//--------------------------+
If lMsErroAuto  
    //-------------------+
    // Log erro ExecAuto |
    //-------------------+
    _aErroAuto  := GetAutoGRLog()
    _lRet       := .F.
    //------------------------------------+
    // Retorna somente a linha com o erro | 
    //------------------------------------+
    ErroAuto(_aErroAuto,@_cMsgErro)
    
    //------------------------+
    // Grava array de retorno | 
    //------------------------+
    aAdd(_aMsgErro,{"1",RTrim(_cCodProd), Alltrim(_cMsgErro)})

EndIf

Return _lRet  

/*************************************************************************************/
/*/{Protheus.doc} GetArmazem
    @description Valida armazem padrao do cliente logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/11/2020
/*/
/*************************************************************************************/
Static Function GetArmazem(_cIDCliente,_cTipo)
Local _cQuery   := ""
Local _cAlias   := ""
Local _cArmazem := "01"

Default _cTipo  := "1"

_cQuery := " SELECT " + CRLF
_cQuery += "    XT3_CODIGO " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "    " + RetSqlName("XT3") + " " + CRLF 
_cQuery += " WHERE " + CRLF
_cQuery += "    XT3_FILIAL = '" + xFilial("XT3") + "' AND " + CRLF
_cQuery += "    XT3_IDLOG = '" + _cIDCliente + "' AND " + CRLF
_cQuery += "    XT3_TIPO   = '" + _cTipo + "' AND " + CRLF
_cQuery += "    D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return _cArmazem 
EndIf

_cArmazem   := (_cAlias)->XT3_CODIGO

Return _cArmazem

/***********************************************************************************/
/*/{Protheus.doc} GetSerie
    @description Cria codigo e loja cliente lojistico 
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/11/2020
/*/
/***********************************************************************************/
Static Function GetSerie(_cIDCliente)
Local _cQuery   := ""
Local _cAlias   := ""
Local _cSerie   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	XT1_SERIE " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("XT1") + " " + CRLF 
_cQuery += " WHERE " + CRLF
_cQuery += "	XT1_FILIAL = '" + xFilial("XT1") + "' AND " + CRLF
_cQuery += "	XT1_IDLOG = '" + _cIDCliente + "' AND " + CRLF
_cQuery += "	D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

_cSerie := (_cAlias)->XT1_SERIE

(_cAlias)->( dbCloseArea() )

Return _cSerie 

/***********************************************************************************/
/*/{Protheus.doc} ClienteCod
    @description Cria codigo e loja cliente lojistico 
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/11/2020
/*/
/***********************************************************************************/
Static Function ClienteCod(_cCnpj,_cCodCli,_cLoja) 
Local _aArea    := GetArea()
Local _cCodNew  := ""
Local _cLojaNew := PadL("1",TamSx3("A1_LOJA")[1],"0")

//---------------------------+
// Valida se é pessoa Fisica | 
//---------------------------+  
If Len(RTrim(_cCnpj)) <= 11
    dbSelectArea("SA1")
    SA1->( dbSetOrder(1) )

    _cCodNew := GetSxeNum("SA1","A1_COD")
    While SA1->( dbSeek(xFilial("SA1") + _cCodNew + _cLojaNew ) )
        ConfirmSx8()
        _cCodNew := GetSxeNum("SA1","A1_COD","",1)
    EndDo

//-----------------+
// Pessoa Juridica | 
//-----------------+
Else
    //--------------------------+
    // Posiciona CNPJ pela raiz |
    //--------------------------+
    dbSelectArea("SA1")
    SA1->( dbSetOrder(3) )
    If SA1->( dbSeek(xFilial("SA1") + SubStr(_cCnpj,1,8) ) )
        
        _cCodNew    := SA1->A1_COD

        While SA1->( !Eof() .And. xFilial("SA1") + SubStr(_cCnpj,1,8) == SA1->A1_FILIAL + SubStr(SA1->A1_CGC,1,8) )
            _cCodNew    := SA1->A1_COD
            Exit
            SA1->( dbSkip() )
        EndDo
        
        dbSelectArea("SA1")
        SA1->( dbSetOrder(1) )
        While SA1->( dbSeek(xFilial("SA1") + _cCodNew + _cLojaNew ) )
            ConfirmSx8()
            _cLojaNew := Soma1(_cLojaNew)
        EndDo
    Else
        dbSelectArea("SA1")
        SA1->( dbSetOrder(1) )

        _cCodNew := GetSxeNum("SA1","A1_COD")
        While SA1->( dbSeek(xFilial("SA1") + _cCodNew + _cLojaNew ) )
            ConfirmSx8()
            _cCodNew := GetSxeNum("SA1","A1_COD","",1)
        EndDo
    EndIf
EndIf

_cCodCli  := _cCodNew
_cLoja    := _cLojaNew

RestArea(_aArea)
Return Nil 

/***********************************************************************************/
/*/{Protheus.doc} ForneceCod
    @description Valida codigo e loja do fornecedor
    @type  Static Function
    @author Bernard M. Margarido
    @since 29/11/2020
/*/
/***********************************************************************************/
Static Function ForneceCod(_cCnpj,_cCodFor,_cLoja) 
Local _aArea    := GetArea()
Local _cCodNew  := ""
Local _cLojaNew := PadL("1",TamSx3("A2_LOJA")[1],"0")

//---------------------------+
// Valida se é pessoa Fisica | 
//---------------------------+  
If Len(RTrim(_cCnpj)) <= 11
    dbSelectArea("SA2")
    SA2->( dbSetOrder(1) )

    _cCodNew := GetSxeNum("SA2","A2_COD")
    While SA2->( dbSeek(xFilial("SA2") + _cCodNew + _cLojaNew ) )
        ConfirmSx8()
        _cCodNew := GetSxeNum("SA2","A2_COD","",1)
    EndDo

//-----------------+
// Pessoa Juridica | 
//-----------------+
Else
    //--------------------------+
    // Posiciona CNPJ pela raiz |
    //--------------------------+
    dbSelectArea("SA2")
    SA2->( dbSetOrder(3) )
    If SA2->( dbSeek(xFilial("SA2") + SubStr(_cCnpj,1,8) ) )
        
        _cCodNew    := SA2->A2_COD

        While SA2->( !Eof() .And. xFilial("SA2") + SubStr(_cCnpj,1,8) == SA2->A2_FILIAL + SubStr(SA2->A2_CGC,1,8) )
            _cCodNew    := SA2->A2_COD
            Exit
            SA2->( dbSkip() )
        EndDo
        
        dbSelectArea("SA2")
        SA2->( dbSetOrder(1) )
        While SA2->( dbSeek(xFilial("SA2") + _cCodNew + _cLojaNew ) )
            ConfirmSx8()
            _cLojaNew := Soma1(_cLojaNew)
        EndDo
    Else
        dbSelectArea("SA2")
        SA2->( dbSetOrder(1) )

        _cCodNew := GetSxeNum("SA2","A2_COD")
        While SA2->( dbSeek(xFilial("SA2") + _cCodNew + _cLojaNew ) )
            ConfirmSx8()
            _cCodNew := GetSxeNum("SA2","A2_COD","",1)
        EndDo
    EndIf
EndIf

_cCodFor  := _cCodNew
_cLoja    := _cLojaNew

RestArea(_aArea)
Return Nil

/***********************************************************************************/
/*/{Protheus.doc} TranspCod
    @description Valida codigo transportadora
    @type  Static Function
    @author Bernard M. Margarido
    @since 29/11/2020
/*/
/***********************************************************************************/
Static Function TranspCod(_cCnpj,_cCodigo)
Local _aArea    := GetArea()

dbSelectArea("SA4")
SA4->( dbSetOrder(1) )

_cCodigo := GetSxeNum("SA4","A4_COD")
While SA2->( dbSeek(xFilial("SA4") + _cCodigo) )
    ConfirmSx8()
    _cCodigo := GetSxeNum("SA4","A4_COD","",1)
EndDo

RestArea(_aArea)
Return Nil 

/***********************************************************************************/
/*/{Protheus.doc} PedidoNum
    @description Retorna codigo do pedido
    @author Bernard M. Margarido
    @since 30/01/2017
    @version undefined
    @type function
/*/
/***********************************************************************************/
Static Function PedidoNum(_cNumero)
Local _aArea    := GetArea()

Local _cPedido  := ""

dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
_cPedido := GetSxeNum("SC5","C5_NUM")
While SC5->( dbSeek(xFilial("SC5") + _cPedido) )
    ConfirmSx8()
    _cPedido := GetSxeNum("SC5","C5_NUM",,1)
EndDo

_cNumero    := _cPedido

RestArea(_aArea)
Return Nil 

/***********************************************************************************/
/*/{Protheus.doc} EcCodMun
    @description Retorna codigo do municipio
    @author Bernard M. Margarido
    @since 30/01/2017
    @version undefined
    @type function
/*/
/***********************************************************************************/
Static Function EcCodMun(cEstado,cMunicipio)
Local aArea		:= GetARea()

Local cAlias	:= ""
Local cQuery	:= ""
Local cIbge		:= ""

If At("(",cMunicipio) > 0
	cMunicipio := SubStr(cMunicipio,1,At("(",cMunicipio) -1)
EndIf

If At("'",cMunicipio) > 0
	cMunicipio := StrTran(cMunicipio,"'","''")
EndIf

//-----------------------------+
// Cosulta codigo de municipio |
//-----------------------------+
cQuery := "	SELECT " + CRLF 
cQuery += "		CC2_CODMUN " + CRLF 
cQuery += "	FROM " + CRLF 
cQuery += "		" + RetSqlName("CC2") + CRLF   
cQuery += "	WHERE " + CRLF 
cQuery += "		CC2_FILIAL = '" + xFilial("CC2") + "' AND " + CRLF 
cQuery += "		CC2_EST = '" + cEstado + "' AND " + CRLF 
cQuery += "		CC2_MUN = '" + cMunicipio + "' AND " + CRLF 
cQuery += "		D_E_L_E_T_ <> '*' " 

cAlias := MPSysOpenQuery(cQuery)

cIbge := (cAlias)->CC2_CODMUN

(cAlias)->( dbCloseArea() )	

RestArea(aArea)
Return cIbge 

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

/*************************************************************************************/
/*/{Protheus.doc} ErroAuto
    @description Tratamento da mensagem de erro ExecAuto 
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2020
/*/
/*************************************************************************************/
Static Function ErroAuto(_aErroAuto,_cMsgErro)
Local _lHelp    := .F.
Local _lTabela  := .F.
Local _lAjuda   := .F.
Local _lHelpMvc := .F.

Local _cLinha   := ""
Local _nX       := 0

For _nX := 1 To Len(_aErroAuto)

	_cLinha  := Upper(_aErroAuto[_nX])
	_cLinha  := StrTran( _cLinha, Chr(13), " " )
	_cLinha  := StrTran( _cLinha, Chr(10), " " )
	
	If SubStr( _cLinha, 1, 4 ) == 'HELP'
		_lHelp := .T.
	EndIf
	
	If SubStr( _cLinha, 1, 6 ) == 'TABELA'
		_lHelp   := .F.
		_lTabela := .T.
	EndIf

    If SubStr( _cLinha, 1, 5 ) == 'AJUDA'
		_lHelp   := .F.
		_lTabela := .F.
        _lAjuda  := .T.
	EndIf

    If  SubStr(_cLinha,1,82 ) == "  --------------------------------------------------------------------------------"
        _lHelp   := .F.
		_lTabela := .F.
        _lAjuda  := .F.
        _lHelpMvc:= .T.
    EndIf

	If (_lHelp .Or. _lTabela .Or. _lAjuda) 
        If ( '< -- INVALIDO' $ _cLinha )
		    _cMsgErro += _cLinha + CRLF
        ElseIf ( 'Inconsistencia' $ _cLinha )
            _cMsgErro += _cLinha + CRLF
        Else 
            _cMsgErro += _cLinha + CRLF
        EndIf
	EndIf

    If _lHelpMvc 
        _cMsgErro += SubStr(_cLinha,83) + CRLF
    EndIf
	
Next _nX

Return Nil 