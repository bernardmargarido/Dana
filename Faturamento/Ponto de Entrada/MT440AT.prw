#INCLUDE "PROTHEUS.CH"

/****************************************************************************************/
/*/{Protheus.doc} MT440AT
    @description Ponto de Entrada - Valida se pedido pode ser liberado 
    @type  Function
    @author Bernard M. Margarido
    @since 21/11/2019
/*/
/****************************************************************************************/
User Function MT440AT()
Local _aArea    := GetArea()

Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")
Local _cPedido  := SC5->C5_NUM
Local _cCodCli  := SC5->C5_CLIENTE
Local _cLojaCli := SC5->C5_LOJACLI
Local _cFilial  := SC5->C5_FILIAL

Local _lRet     := .T.
Local _lPedido  := .F.
Local _lAtvWMS	:= GetNewPar("DN_ATVWSM",.T.)

Private _cMsg   := ""

Private _lPedSld:= .F.

//---------------------------+
// Retirado processo AutoLog |
//---------------------------+
If !_lAtvWMS
	RestArea(aArea)
	Return .T.
EndIf

//----------------------------------------------+
// Caso nao seja filial WMS não valida processo | 
//----------------------------------------------+
If !cFilAnt $ _cFilWMS
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------------+
// Valida se e pedido e-Commerce |
//-------------------------------+
If SC5->( FieldPos("C5_XNUMECO") ) > 0 .And. !Empty(SC5->C5_XNUMECO)
	RestArea(aArea)
	Return .T.
EndIf

//-----------------------------------+
// Valida se pedido tem item cortado | 
//-----------------------------------+
If SC5->C5_XENVWMS == "3"
    //------------------------------------+
    // Valida se exite quantidade Cortada |
    //------------------------------------+
    If M410QTD()
        //----------------------------------+
        // Valida se já existe pedido saldo |
        //----------------------------------+
        _lRet := M410SLD()
    EndIf
EndIf

//------------------------+
// Gera novo pedido saldo |
//------------------------+
If _lPedSld
    If MsgYesNo(_cMsg,"Dana - Avisos")
        //-------------------+
        // Gera Pedido saldo |
        //-------------------+
        FwMsgRun(,{|| _lPedido := U_DnWmsM02(_cFilial,_cPedido, _cCodCli, _cLojaCli,.T.)},"Aguarde...","Gerando pedido saldo.")

        If _lPedido
            //-----------------------+    
            // Elimina Residuo saldo |
            //-----------------------+
            U_DnWmsM03(_cPedido)
        EndIf
    EndIf
ElseIf !Empty(_cMsg)
    MsgAlert(_cMsg,"Dana - Avisos!")
    _lRet   := .F.
EndIf

RestArea(_aArea)
Return _lRet

/*******************************************************************/
/*/{Protheus.doc} M410SLD
    @description Valida se existe pedido saldo 
    @type  Static Function
    @author Bernard M. Margarido
    @since 23/11/2019
/*/
/*******************************************************************/
Static Function M410SLD()
Local _cAlias   := GetNextAlias()
Local _cQuery   := ""

Local _lRet     := .F.

_cQuery := " SELECT " + CRLF
_cQuery += "    COALESCE(C5.C5_NUM,'') C5_NUM, " + CRLF
_cQuery += "    COALESCE(SC5.C5_NUM,'') PED_SLD " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SC5") + " C5 " + CRLF 
_cQuery += "    INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL  = C5.C5_FILIAL AND SC5.C5_XPVSLD = C5.C5_NUM AND SC5.D_E_L_E_T_ = '' " + CRLF 
_cQuery += " WHERE " + CRLF
_cQuery += "	C5.C5_FILIAL = '" + xFilial("SC5") + "' AND " + CRLF
_cQuery += "	C5.C5_NUM = '" + SC5->C5_NUM + "' AND " + CRLF
_cQuery += "	C5.D_E_L_E_T_ = '' " + CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If Empty((_cAlias)->C5_NUM)
    _cMsg   := "Não é permitido liberar pedido com saldo, somente gerando um novo pedido. Deseja gerar um novo pedido saldo ?."
    _lPedSld:= .T.
Else
    _cMsg   := "Não é permitido liberar pedido. Já foi gerado um novo pedido saldo Numero " + (_cAlias)->PED_SLD + " ."
EndIF 

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

Return _lRet

/*******************************************************************/
/*/{Protheus.doc} M410QTD
    @description Valida itens cortados pelo WMS
    @type  Static Function
    @author Bernard M. Margarido
    @since 24/11/2019
/*/
/*******************************************************************/
Static Function M410QTD()
Local _aArea        := GetArea()

Local _lRet         := .T.
Local _lResiduo     := .F.
Local _lFaturado    := .F.
Local _lPedente     := .F.

//---------------------------+
// Posiciona Itens do Pedido | 
//---------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If !SC6->( dbSeek(xFilial("SC6") + SC5->C5_NUM) )
    RestArea(_aArea)
    Return .F.
EndIf

While SC6->( !Eof() .And. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM)
    //-----------------------------------+
    // Contem residuo e não foi faturado |
    //-----------------------------------+
    If SC6->C6_XQTDRES > 0 .And. Empty(SC6->C6_NOTA)
        _lResiduo := .T.
    //----------------------------------------+
    // Nao contem residuo e item foi faturado |
    //----------------------------------------+
    ElseIf ( SC6->C6_XQTDRES == 0 .Or. SC6->C6_XQTDRES > 0 )  .And. !Empty(SC6->C6_NOTA)
        _lFaturado := .T.
    //----------------------------------------+
    // Nao contem residuo e item foi faturado |
    //----------------------------------------+
    ElseIf SC6->C6_XQTDRES == 0 .And. Empty(SC6->C6_NOTA)
        _lPedente := .T.
    EndIf

    SC6->( dbSkip())
EndDo

//------------------------------------+
// Valida se pedido pode ser liberado | 
//------------------------------------+
If _lPedente 
    _lRet := .F.
ElseIf _lResiduo .And. _lFaturado
    _lRet := .T.
EndIf

RestArea(_aArea)
Return _lRet