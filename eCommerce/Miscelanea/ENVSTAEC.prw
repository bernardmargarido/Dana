#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} ENVSTAEC
    @description Envia status eCommerce
    @type  Function
    @author user
    @since 22/11/2022
/*/
User Function ENVSTAEC()
Local _aParamBox    := {}
Local _aRet         := {}
Local _aTpProd      := {"Start","Invoice"}

Local _cOrcDe       := ""
Local _cOrcAte      := ""
Local _nTpEnvio     := 0 

aAdd(_aParamBox,{1, "Orcamento de"              , Space(TamSx3("WSA_NUM")[1])       , PesqPict("WSA","WSA_NUM")       , "", "WSA"     , "", 80     , .F.})
aAdd(_aParamBox,{1, "Orcamento ate"             , Space(TamSx3("WSA_NUM")[1])       , PesqPict("WSA","WSA_NUM")       , "", "WSA"     , "", 80     , .F.})
aAdd(_aParamBox,{2, "Tipo"                      ,"1", _aTpProd,080,,.T.})

If ParamBox(_aParamBox,"Envia Status Pedido",@_aRet,,,,,,,,.T.)
    _cOrcDe         := _aRet[1]
    _cOrcAte        := _aRet[2]
    _nTpEnvio       := IIF(ValType(_aRet[3]) == "N", _aRet[3], aScan(_aTpProd,{|x| RTrim(x) == RTrim(_aRet[3])})) 

    If _nTpEnvio == 1
        FwMsgRun(,{|_oSay| LoadOrc(@_oSay,_cOrcDe,_cOrcAte)},"Aguarde...","Enviando status...")
    Else 
        FwMsgRun(,{|_oSay| LoadInv(@_oSay,_cOrcDe,_cOrcAte)},"Aguarde...","Enviando invoice...")
    EndIf 

EndIf 

Return Nil 

/*/{Protheus.doc} LoadOrc
    @description envia status do orçamento
    @type  Static Function
    @author user
    @since 22/11/2022
/*/
Static Function LoadOrc(_oSay,_cOrcDe,_cOrcAte)
Local _aArea    := GetArea()
Local _cQuery   := ""
Local _cAlias   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	WSA_NUM " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WSA") + " WSA " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "	WSA_NUM BETWEEN '" + _cOrcDe + "' AND '" + _cOrcAte + "' AND " + CRLF
_cQuery += "	WSA_ENVLOG NOT IN('5') AND " + CRLF
_cQuery += "	D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

While (_cAlias)->( !Eof() )
    
    _oSay:cCaption := "Enviando status orcamento " + (_cAlias)->WSA_NUM
    ProcessMessages()

    U_AECOI11B((_cAlias)->WSA_NUM)

    (_cAlias)->( dbSkip() )

EndDo 

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return Nil 

/*/{Protheus.doc} LoadInv
    @description envia status do orçamento
    @type  Static Function
    @author user
    @since 22/11/2022
/*/
Static Function LoadInv(_oSay,_cOrcDe,_cOrcAte)
Local _aArea    := GetArea()
Local _cQuery   := ""
Local _cAlias   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	WSA_NUMECO " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WSA") + " WSA " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "	WSA_NUM BETWEEN '" + _cOrcDe + "' AND '" + _cOrcAte + "' AND " + CRLF
_cQuery += "	WSA_ENVLOG NOT IN('5') AND " + CRLF
_cQuery += "	D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

While (_cAlias)->( !Eof() )
    
    _oSay:cCaption := "Enviando invoice orcamento " + (_cAlias)->WSA_NUMECO
    ProcessMessages()

    U_AECOI013((_cAlias)->WSA_NUM)

    (_cAlias)->( dbSkip() )

EndDo 

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return Nil 
