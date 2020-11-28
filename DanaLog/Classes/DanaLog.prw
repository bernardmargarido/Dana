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
    Data cCodProd   As String
    Data cIdCliente As String

    Data nCodeHttp  As Integer 
    Data nTExpires  As Integer

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
    Method ClearObj()

End Class

/****************************************************************************************/
/*/{Protheus.doc} New
    @description M�todo construtor da classe 
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
    ::cCodProd  := ""
    ::cIdCliente:= ""

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
    _oJSon[#"messages"][#"message"]     := "Usu�rio e senha n�o informados."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Usu�rio e senha n�o informados."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.
EndIf

//---------------------+
// Desesserializa JSON | 
//---------------------+
_oJSon  := xFromJson(::cJSon)

//--------------------------------------------------+
// Valida se usu�rio ou senha n�o est�o preenchidos |
//--------------------------------------------------+
If Empty(_oJSon[#"user"]) .Or. Empty(_oJSon[#"password"])

    _oJSon                          := Array(#)
    _oJSon[#"messages"]             := Array(#)
    _oJSon[#"messages"][#"status"]  := "1"
    _oJSon[#"messages"][#"message"] := "Usu�rio ou senha n�o informados."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Usu�rio ou senha n�o informados."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.
EndIf

//------------------------+
// Valida usu�rio e senha | 
//------------------------+
If !::GetUserID(_oJSon[#"user"],_oJSon[#"password"])
    _oJSon                              := Array(#)
    _oJSon[#"messages"]                 := Array(#)
    _oJSon[#"messages"][#"status"]      := "1"
    _oJSon[#"messages"][#"message"]     := "Usu�rio ou senha incorreto."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "Usu�rio ou senha incorreto."
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
        _oJSon[#"messages"][#"message"] := "Usu�rio sem autoriza��o."

        ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
        ::cError                := "Usu�rio sem autoriza��o."
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
// Posiciona configura��es de acesso |
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
Local _oJSonRet := Nil 

//-------------------------------------------------+
// Valida se tipo de autentica��o � do tipo Bearer |
//-------------------------------------------------+
If At("Bearer",::cAuth) == 0
    _oJSonRet                          := Array(#)
    _oJSonRet[#"messages"]             := Array(#)
    _oJSonRet[#"messages"][#"status"]  := "1"
    _oJSonRet[#"messages"][#"message"] := "Tipo de autentica��o inv�lida."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSonRet))
    ::cError                := "Tipo de autentica��o inv�lida."
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
// Valida usu�rio | 
//----------------+
dbSelectArea("XT2")
XT2->( dbSetOrder(1) )
If !XT2->( dbSeek(xFilial("XT2") + ::cIdCliente) )
    _oJSonRet                          := Array(#)
    _oJSonRet[#"messages"]             := Array(#)
    _oJSonRet[#"messages"][#"status"]  := "1"
    _oJSonRet[#"messages"][#"message"] := "Dados do token inv�lidos."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSonRet))
    ::cError                := "Dados do token inv�lidos."
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
    _oJSonRet[#"messages"][#"message"] := "Token inv�lido."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSonRet))
    ::cError                := "Token inv�lido."
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

//--------------------------------+
// Valida se JSON veio preenchido | 
//--------------------------------+
If Empty(::cJSon)
    _oJSon                          := Array(#)
    _oJSon[#"messages"]             := Array(#)
    _oJSon[#"messages"][#"status"]  := "1"
    _oJSon[#"messages"][#"message"] := "JSON n�o enviado."

    ::cJSonRet              := EncodeUTF8(xToJson(_oJSon))
    ::cError                := "JSON n�o enviado."
    ::nCodeHttp             := BADREQUEST
    _lRet                   := .F.

    CoNout("<< DANALOG >> PRODUTOS - JSON NAO ENVIADO ")    

EndIf

//---------------+
// Metodo - POST |
//---------------+
If ::cMetodo == "POST"
    CoNout("<< DANALOG >> PRODUTOS - METODO POST ")    
    Begin Transaction 
        ProdutoPost(::cJSon,3)
    End Transaction 
//--------------+
// Metodo - PUT |
//--------------+
ElseIf ::cMetodo == "PUT"
    CoNout("<< DANALOG >> PRODUTOS - METODO PUT ")    
    Begin Transaction 
        ProdutoPost(::cJSon,4)
    End Transaction
//--------------+
// Metodo - GET |
//--------------+
ElseIf ::cMetodo == "GET"
    CoNout("<< DANALOG >> PRODUTOS - METODO GET ")    
    ProdutoGet(::cCodProd,::cIdCliente,@_cRest)
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
/*/{Protheus.doc} ProdutoPost
    @description Realiza a grava��o do produto cliente logistico
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
Local _lMvcMata010      := TableInDic( "G3Q", .F. )

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
    SB1->( dbSetOrder(1) )

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
        _cArmazem   := "01"
        _cLote      := _oProduto[_nX][#"lote"]
        _cNCM       := _oProduto[_nX][#"ncm"]
        _cBloq      := _oProduto[_nX][#"ativo"]
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
        // Valida se produto est� cadastrado | 
        //-----------------------------------+
        If SB1->( dbSeek(xFilial("SB1") + _cCodProd) ) .And. _nOpc == 3
            aAdd(_aMsgErro,{"1",RTrim(_cCodProd), "Produto j� cadastro utiliza o m�todo PUT para atualiza��o do produto."})
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
        // Erro grava��o de produto | 
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
/*/{Protheus.doc} nomeStaticFunction
    @description Retorna dados do produto
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/11/2020
/*/
/*************************************************************************************/
Static Function ProdutoGet(_cCodProd,_cIdCliente,_cRest)
Local _cAlias   := ""

Local _lRet     := .T.

Local _oJSon    := Nil 
Local _oProduto := Nil 

//------------------+
// Consulta produto |
//------------------+
If !PrdGetQry(@_cAlias,_cCodProd,_cIdCliente)
    aAdd(_aMsgErro,{"1",RTrim(_cCodProd), "Produto n�o localizado."})
    Return .F.
EndIf 

_oJSon              := Array(#)
_oJSon[#"produtos"] := {}

While (_cAlias)->( !Eof() )

    aAdd(_oJSon[#"produtos"],Array(#))
    _oProduto := aTail(_oJSon[#"produtos"])

    _oProduto[#"codigo"]                := (_cAlias)->B1_COD
	_oProduto[#"descricao"]             := (_cAlias)->B1_DESC
	_oProduto[#"tipo_produto"]          := (_cAlias)->B1_TIPO
	_oProduto[#"unidade"]               := (_cAlias)->B1_UM
	_oProduto[#"unidade_2"]             := (_cAlias)->B1_SEGUM
	_oProduto[#"fator_conv"]            := (_cAlias)->B1_CONV
	_oProduto[#"tipo_conv"]             := (_cAlias)->B1_TIPCONV
	_oProduto[#"codigo_barras"]         := (_cAlias)->B1_CODGTIN
	_oProduto[#"codigo_barras_caixa"]   := (_cAlias)->B1_XEANCX    
	_oProduto[#"lote"]                  := (_cAlias)->B1_RASTRO
	_oProduto[#"ncm"]                   := (_cAlias)->B1_POSIPI
	_oProduto[#"ativo"]                 := (_cAlias)->B1_MSBLQL
	_oProduto[#"origem"]                := (_cAlias)->B1_ORIGEM
	_oProduto[#"peso_liquido"]          := (_cAlias)->B1_PESO
	_oProduto[#"peso_bruto"]            := (_cAlias)->B1_PESBRU
	_oProduto[#"altura"]                := (_cAlias)->B5_ALTURA
	_oProduto[#"largura"]               := (_cAlias)->B5_LARG
	_oProduto[#"comprimento"]           := (_cAlias)->B5_COMPR
	_oProduto[#"peso_liquido_emb"]      := (_cAlias)->B1_PESO
	_oProduto[#"peso_bruto_emb"]        := (_cAlias)->B1_PESBRU
	_oProduto[#"altura_embalagem"]      := (_cAlias)->B5_ALTURLC
	_oProduto[#"largura_embalagem"]     := (_cAlias)->B5_LARGLC
	_oProduto[#"comprimento_embalagem"] := (_cAlias)->B5_COMPRLC
	_oProduto[#"tipo_embalagem"]        := (_cAlias)->B5_EMB1
	_oProduto[#"quantidade_embalagem"]  := (_cAlias)->B5_QE1
	_oProduto[#"empilhamento_maximo"]   := (_cAlias)->B5_EMPMAX0
	_oProduto[#"total_pallet"]          := (_cAlias)->B5_EMPMAX0 * (_cAlias)->B5_FATARMA

    (_cAlias)->( dbSkip() )
EndDo

//--------------+
// Cria retorno | 
//--------------+
_cRest  := EncodeUTF8(xToJson(_oJSon))

//---------------------+
// Encerra temposr�rio |
//---------------------+
(_cAlias)->( dbCloseArea() )

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} PrdGetQry
    @description Consulta produto 
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/11/2020
/*/
/*************************************************************************************/
Static Function PrdGetQry(_cAlias,_cCodProd,_cIdCliente)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	B1.B1_COD, " + CRLF
_cQuery += "	B1.B1_DESC, " + CRLF
_cQuery += "	B1.B1_TIPO, " + CRLF
_cQuery += "	B1.B1_UM, " + CRLF
_cQuery += "	B1.B1_SEGUM, " + CRLF
_cQuery += "	B1.B1_CONV, " + CRLF
_cQuery += "	B1.B1_TIPCONV, " + CRLF
_cQuery += "	B1.B1_CODGTIN, " + CRLF 
_cQuery += "	B1.B1_XEANCX, " + CRLF
_cQuery += "	B1.B1_LOCPAD, " + CRLF
_cQuery += "	B1.B1_RASTRO, " + CRLF
_cQuery += "	B1.B1_POSIPI, " + CRLF
_cQuery += "	B1.B1_PESO, " + CRLF
_cQuery += "	B1.B1_PESBRU, " + CRLF
_cQuery += "	B1.B1_MSBLQL, " + CRLF
_cQuery += "	B1.B1_ORIGEM, " + CRLF
_cQuery += "	B1.B1_XIDLOGI, " + CRLF
_cQuery += "    COALESCE(B5.B5_COMPR,0) B5_COMPR, " + CRLF
_cQuery += "	COALESCE(B5.B5_ALTURA,0) B5_ALTURA, " + CRLF
_cQuery += "	COALESCE(B5.B5_LARG,0) B5_LARG, " + CRLF
_cQuery += "	COALESCE(B5.B5_EMB1,'') B5_EMB1, " + CRLF
_cQuery += "	COALESCE(B5.B5_QE1,0) B5_QE1, " + CRLF
_cQuery += "	COALESCE(B5.B5_COMPRLC,0) B5_COMPRLC, " + CRLF
_cQuery += "	COALESCE(B5.B5_LARGLC,0) B5_LARGLC, " + CRLF
_cQuery += "	COALESCE(B5.B5_ALTURLC,0) B5_ALTURLC, " + CRLF
_cQuery += "	COALESCE(B5.B5_FATARMA,0) B5_FATARMA, " + CRLF
_cQuery += "	COALESCE(B5.B5_EMPMAX,0) B5_EMPMAX0 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SB1") + " B1 " + CRLF
_cQuery += "	LEFT JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = B1.B1_COD AND B5.B5_XIDLOGI = B1.B1_XIDLOGI AND B5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	B1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
_cQuery += "	B1.B1_COD = '" + _cCodProd + "' AND " + CRLF
_cQuery += "	B1.B1_XIDLOGI = '" + _cIdCliente + "' AND " + CRLF
_cQuery += "	B1.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ProdutoCompl
    @description Grava informa��es de complemento de produto 
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
// Erro grava��o de produto | 
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

	If (_lHelp .Or. _lTabela .Or. _lAjuda) .And. ( '< -- INVALIDO' $ _cLinha )
		_cMsgErro := _cLinha
	EndIf

    If _lHelpMvc
        _cMsgErro := SubStr(_cLinha,83)
    EndIf
	
Next _nX

Return Nil 