#INCLUDE "TOTVS.CH"

/***********************************************************************************************************/
/*/{Protheus.doc} ECLOJ019
    @description Realiza a atualização dos ID's dos produtos e-Commerce
    @type  Function
    @author Bernard M Margarido
    @since 22/08/2022
    @version version
/*/
/***********************************************************************************************************/
User Function ECLOJ019()
Local _aParamBox    := {}
Local _aRet         := {}
Local _aTpProd      := {"Produto","SKU"}

Local _nTpProd      := 0

Local _cIDLoja      := ""
Local _cFilAux      := cFilAnt 
Local _cFilEcom     := "06"

If cFilAnt <> _cFilEcom
    cFilAnt := _cFilEcom
EndIf 


aAdd(_aParamBox,{2, "Tipo de Produto"           ,"1", _aTpProd,080,,.T.})
aAdd(_aParamBox,{1, "Loja eCommerce"            , Space(TamSx3("XTC_CODIGO")[1])   , PesqPict("XTC","XTC_CODIGO")       , "", "IDLOJA"     , "", 80     , .F.})

If ParamBox(_aParamBox,"Atualiza ID eCommerce",@_aRet,,,,,,,,.T.)
    _nTpProd := IIF(ValType(_aRet[1]) == "N", _aRet[1], aScan(_aTpProd,{|x| RTrim(x) == RTrim(_aRet[1])})) 
    _cIDLoja := _aRet[2]

    FwMsgRun(,{|_oSay| ECLOJ019A(_oSay,_nTpProd,_cIDLoja)},"Aguarde...","Validando dados dos " + IIF(_nTpProd == 1,"Produtos","SKU's"))

EndIf 

If cFilAnt <> _cFilAux
    cFilAnt := _cFilAux
EndIf 

Return Nil 

/***********************************************************************************************************/
/*/{Protheus.doc} ECLOJ019A
    @description Realiza a atualização dos ID's dos produtos
    @type  Static Function
    @author Bernard M Margarido
    @since 22/08/2022
    @version version
/*/
/***********************************************************************************************************/
Static Function ECLOJ019A(_oSay,_nTpProd,_cIDLoja)
Local _aArea    := GetArea()

Local _cLojaID  := ""
Local _cUrl     := ""
Local _cAppKey  := ""
Local _cAppToken:= ""

Local _nTIDLoja := TamSx3("XTC_CODIGO")[1]

//----------------------------------------+
// XTC - Posiciona dados lojas e-Commerce |
//----------------------------------------+
dbSelectArea("XTC")
XTC->( dbSetOrder(1) )
If !XTC->( dbSeek(xFilial("XTC") + PadR(_cIDLoja,_nTIDLoja)))
    MsgStop("Loja eCommerce não localizada.", "Dana - Avisos")
    RestArea(_aArea)
    Return Nil 
EndIf 

//---------------------------+
// Valida se loja está ativa |
//---------------------------+
If XTC->XTC_STATUS == "2"
    MsgStop("Loja eCommerce inativa.", "Dana - Avisos")
    RestArea(_aArea)
    Return Nil 
EndIf 

//---------------------+
// Parametros de envio |
//---------------------+
_cLojaID  := RTrim(XTC->XTC_CODIGO)
_cUrl     := RTrim(XTC->XTC_URL2)
_cAppKey  := RTrim(XTC->XTC_APPKEY)
_cAppToken:= RTrim(XTC->XTC_APPTOK)

//---------+
// Produto |
//---------+
If _nTpProd == 1
    FwMsgRun(,{|_oSay| ECLOJ019B(_oSay,_cLojaID,_cUrl,_cAppKey,_cAppToken)},"Aguarde...","Atualizando ID dos produtos")
//-----+
// SKU |
//-----+
ElseIf _nTpProd == 2
    FwMsgRun(,{|_oSay| ECLOJ019C(_oSay,_cLojaID,_cUrl,_cAppKey,_cAppToken)},"Aguarde...","Atualizando ID dos sku's")
EndIf 

RestArea(_aArea)
Return Nil 

/***********************************************************************************************************/
/*/{Protheus.doc} ECLOJ019B
    @description Atualiza dados dos ID's dos produtos
    @type  Static Function
    @author Bernard M Margarido
    @since 22/08/2022
    @version version
/*/
/***********************************************************************************************************/
Static Function ECLOJ019B(_oSay,_cLojaID,_cUrl,_cAppKey,_cAppToken)
Local _cStatic   := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
Local _cRest     := ""

Local _nIDProd   := 0

Local _oDanaEcom := Nil  
Local _oJSon     := JSonObject():New() 

dbSelectArea("SB5")
SB5->( dbSetOrder(1) )
SB5->( dbSeek(xFilial("SB5")) )
While SB5->( !Eof() .And. xFilial("SB5") == SB5->B5_FILIAL)
    _cRefId := SB5->B5_COD 
    _oSay:cCaption := "Consultando ID do Produto " + RTrim(_cRefId) 
    ProcessMessages()

    _lRet := Eval( {|| &(_cStatic + "(" + "AECOI003,AEcoI03C,_cLojaID,_cUrl,_cAppKey,_cAppToken,_cRefId,'1',@_cRest" + ")") })

    If _lRet 

        _oJSon:fromJson(_cRest)
        _nIDProd := _oJSon["Id"]

        _oDanaEcom 			:= DanaEcom():New()
        _oDanaEcom:cLojaID	:= _cLojaID
        _oDanaEcom:cAlias	:= "SB5"
        _oDanaEcom:cCodErp	:= _cRefId
        _oDanaEcom:nID		:= _nIDProd
        _oDanaEcom:GravaID()

    EndIf  
    SB5->( dbSkip() )
EndDo 


Return Nil 

/***********************************************************************************************************/
/*/{Protheus.doc} ECLOJ019B
    @description Atualiza dados dos ID's dos produtos
    @type  Static Function
    @author Bernard M Margarido
    @since 22/08/2022
    @version version
/*/
/***********************************************************************************************************/
Static Function ECLOJ019C(_oSay,_cLojaID,_cUrl,_cAppKey,_cAppToken)
Local _cStatic   := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
Local _cRest     := ""

Local _nIDProd   := 0

Local _oDanaEcom := Nil  
Local _oJSon     := JSonObject():New() 

dbSelectArea("SB5")
SB5->( dbSetOrder(1) )
SB5->( dbSeek(xFilial("SB5")) )
While SB5->( !Eof() .And. xFilial("SB5") == SB5->B5_FILIAL)
    _cRefId := SB5->B5_COD 
    
    _oSay:cCaption := "Consultando ID do SKU " + RTrim(_cRefId) 
    ProcessMessages()

    _lRet := Eval( {|| &(_cStatic + "(" + "AECOI003,AEcoI03C,_cLojaID,_cUrl,_cAppKey,_cAppToken,_cRefId,'2',@_cRest" + ")") })
    
    If _lRet 
        _oJSon:fromJson(_cRest)
        _nIDProd := _oJSon["Id"]

        _oDanaEcom 			:= DanaEcom():New()
        _oDanaEcom:cLojaID	:= _cLojaID
        _oDanaEcom:cAlias	:= "SB1"
        _oDanaEcom:cCodErp	:= _cRefId
        _oDanaEcom:nID		:= _nIDProd
        _oDanaEcom:GravaID()

    EndIf  
    SB5->( dbSkip() )
EndDo 


Return Nil 
