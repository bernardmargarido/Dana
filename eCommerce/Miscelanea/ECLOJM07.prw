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

Private _lJob       := IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt    := "01"
Default _cFilInt    := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< ECLOJM07 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//--------------------------+
// Cria arquivo de semaforo |
//--------------------------+
If LockByName("ECLOJM07", .F., .F.)
   
    //-----------------------+
    // Abre empresa / filial | 
    //-----------------------+
    If _lJob
        RpcSetType(3)
        RpcSetEnv(_cEmpInt, _cFilInt,,,'LOJ')
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

    CoNout("<< ECLOJM07 >> - FIM  ENVIO INVOICE ECOMMERCE " + dTos( Date() ) + " - " + Time() )

    //------------------------+
    // Fecha empresa / filial |
    //------------------------+
    If _lJob
        RpcClearEnv()
    EndIf    

    //----------------------------+
    // Exclui arquivo de semaforo |
    //----------------------------+
    UnLockByName("ECLOJM07",.F.,.F.)

EndIf 

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
Local _aArea    := GetArea()

Local _cAlias   := ""

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
