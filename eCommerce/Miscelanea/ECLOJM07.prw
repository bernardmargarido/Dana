#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*********************************************************************************/
/*/{Protheus.doc} ECLOJM07
    @description JOB - Envia dados da nota para o e-Commerce
    @type  Function
    @author Bernard M. Margarido
    @since 10/08/2020
/*/
/*********************************************************************************/
User Function ECLOJM07(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _lJob       := .T. //IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt    := "01"
Default _cFilInt    := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< ECLOJM07 >> - INICIO " + dTos( Date() ) + " - " + Time() )

/*   
//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
    RpcSetEnv(_cEmpInt, _cFilInt,,,'FAT')
EndIf

//--------------------------+
// Cria arquivo de semaforo |
//--------------------------+
If !LockByName("ECLOJM07", .T., .T.)
    CoNout("<< ECLOJM07 >> - ROTINA EM USO AGUARDE A FINALIZACAO DO PROCESSO - DATA " + dToc(Date()) + " HORA " + Time() )
    CoNout("<< ECLOJM07 >> - FIM ENVIO INVOICE ECOMMERCE - DATA " + dToc(Date()) + " HORA " + Time() )
    CoNout(Replicate("-",80))
    CoNout("")
    If _lJob
        RpcClearEnv()
    Endif 
    Return Nil 
EndIf 
    
//-----------------------+
// Integração de Pedidos |
//-----------------------+
CoNout("<< ECLOJM07 >> - INICIO ENVIO INVOICE ECOMMERCE " + dTos( Date() ) + " - " + Time() )

If _lJob
    EcLojM07A()
Else
    FwMsgRun(,{|_oSay| EcLojM07A(_oSay)},"Aguarde...","Enviando Invoices")
EndIf

CoNout("<< ECLOJM07 >> - FIM ENVIO INVOICE ECOMMERCE " + dTos( Date() ) + " - " + Time() )

//----------------------------+
// Exclui arquivo de semaforo |
//----------------------------+
UnLockByName("ECLOJM07", .T., .T.)

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    
*/

EcLojM07A()

CoNout("<< ECLOJM07 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} EcLojM07A
    @description ECLOJM07
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2020
/*/
/*********************************************************************************/
Static Function EcLojM07A(_oSay)
Local _aArea        := GetArea()

Local _cAlias       := ""

Local _lCancelado   := .F.

Default _oSay   := Nil 

CoNout("<< ECLOJM07 >> - CONSULTA REGISTROS A SEREM ENVIADOS.")
If !EcLojM07B(@_cAlias)
    CoNout("<< ECLOJM07 >> - NAO EXISTEM NOVOS REGISTROS A SEREM ENVIADOS.")
    If !_lJob
        MsgStop("Não existem novos registros para serem enviados","Dana - eCommerce")
    EndIf
    RestArea(_aArea)
    Return .T.
EndIf

//-------------------------------+
// Atualiza status para faturado | 
//-------------------------------+
dbSelectArea("WS1")
WS1->( dbSetOrder(1) )

//--------------------------------+
// WSA - Tabela pedidos eCommerce |
//--------------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(1) )

While (_cAlias)->( !Eof() )

    //-----------------------------+
    // Posiciona pedido e-Commerce |
    //-----------------------------+
    WSA->( dbGoTo((_cAlias)->RECNOWSA) )
    
    If !_lJob
        _oSay:cCaption := "Enviando pedido " + WSA->WSA_NUMECO
        ProcessMessages()
    EndIf

    CoNout("<< ECLOJM07 >> - ENVIANDO PEDIDO ECOMMERCE " + RTrim(WSA->WSA_NUMECO) )
    
    If U_AECOI013(WSA->WSA_NUM)
        WS1->( dbSeek(xFilial("WS1") + "006") )
        
        RecLock("WSA",.F.)
            WSA->WSA_CODSTA	:= WS1->WS1_CODIGO
            WSA->WSA_DESTAT	:= WS1->WS1_DESCRI
            WSA->WSA_ENVLOG := "5"
        WSA->( MsUnLock() )

        //--------------------------+
        // Envia e-mail de rastreio |
        //--------------------------+
        CoNout("<< ECLOJM07 >> - ENVIANDO E-MAIL COM RASTREIO." )
        U_EcLojM08(WSA->WSA_NUM)

        //------------------------+
        // Grava Status do Pedido |
        //------------------------+
        u_AEcoStaLog("006",WSA->WSA_NUMECO,WSA->WSA_NUM,dDataBase,Time())

        CoNout("<< ECLOJM07 >> - PEDIDO ECOMMERCE " + RTrim(WSA->WSA_NUMECO) + "ENVIADO COM SUCESSO." )
    Else 

        CoNout("<< ECLOJM07 >> - VALIDA SE PEDIDO ECOMMERCE " + RTrim(WSA->WSA_NUMECO) + "ESTA CANCELADO." )

        EcLojM07C(WSA->WSA_IDLOJA,WSA->WSA_NUMECO,@_lCancelado)

        If _lCancelado
            WS1->( dbSeek(xFilial("WS1") + "008") )
                
            RecLock("WSA",.F.)
                WSA->WSA_CODSTA	:= WS1->WS1_CODIGO
                WSA->WSA_DESTAT	:= WS1->WS1_DESCRI
                WSA->WSA_ENVLOG := "C"
            WSA->( MsUnLock() )
        EndIf 
    EndIf
    
    (_cAlias)->( dbSkip() )
EndDo

//----------------------------+
// Encerra arquivo temporário | 
//----------------------------+
(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} nomeStaticFunction
    @description Consulta envio de invoice
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2020
/*/
/*********************************************************************************/
Static Function EcLojM07B(_cAlias)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	WSA.WSA_NUM, " + CRLF
_cQuery += "	WSA.WSA_NUMECO, " + CRLF
_cQuery += "	WSA.R_E_C_N_O_ RECNOWSA " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WSA") + " WSA " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("SF2") + " F2 ON F2.F2_DOC = WSA.WSA_DOC AND F2.F2_SERIE = WSA.WSA_SERIE AND F2.F2_FIMP = 'S' AND F2.F2_CHVNFE <> '' AND F2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "	WSA.WSA_ENVLOG = '4' AND " + CRLF
_cQuery += "	WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY WSA.WSA_NUM " + CRLF

_cAlias := MPSysOpenQuery(_cQuery)

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/****************************************************************************************/
/*/{Protheus.doc} EcLojM07C
    @description Consulta status do pedido 
    @type  Static Function
    @author Bernard M Margarido
    @since 24/03/2023
    @version version
    @param param_name, param_type, param_descr
/*/
/****************************************************************************************/
Static Function EcLojM07C(_cIdLoja,_cOrderID,_lCancelado)
Local _aHeadOut     := {}

Local _cUrl         := ""
Local _cAppKey      := ""
Local _cAppToken    := ""
Local _cJSon        := ""

Local _nTimeOut     := 600 

Local _oJSon        := Nil 
Local _oFwRest      := Nil 

//----------------+
// Posiciona loja |
//----------------+
dbSelectArea("XTC")
XTC->( dbSetOrder(1) )
If XTC->( dbSeek(xFilial("XTC") + _cIdLoja) )
    _cUrl       := RTrim(XTC->XTC_URL2)
    _cAppKey    := RTrim(XTC->XTC_APPKEY)
    _cAppToken  := RTrim(XTC->XTC_APPTOK)
EndIf 

_lCancelado := .F.
_cUrl		:= RTrim(IIF(Empty(_cUrl), GetNewPar("EC_URLREST"), _cUrl))
_cAppKey	:= RTrim(IIF(Empty(_cAppKey), GetNewPar("EC_APPKEY"), _cAppKey))
_cAppToken	:= RTrim(IIF(Empty(_cAppToken), GetNewPar("EC_APPTOKE"), _cAppToken))

aAdd(_aHeadOut,"Content-Type: application/json" )
aAdd(_aHeadOut,"X-VTEX-API-AppKey:" + _cAppKey )
aAdd(_aHeadOut,"X-VTEX-API-AppToken:" + _cAppToken ) 

_oFwRest := FWRest():New(_cUrl)
_oFwRest:nTimeOut := _nTimeOut
_oFwRest:SetPath("/api/oms/pvt/orders/" + RTrim(_cOrderID))
If _oFwRest:Get(_aHeadOut)
    _cJSon := DecodeUtf8(_oFwRest:GetResult())
    _oJSon := JSonObject():New()
    _oJSon:fromJson(_cJSon)
    _lCancelado := IIF(_oJSon['status'] == 'canceled', .T., .F.)
EndIf 

FreeObj(_oFwRest)
Return Nil 
