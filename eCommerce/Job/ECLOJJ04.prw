#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE DESTIN 1
#DEFINE ENDERE 2
#DEFINE NUMERO 3
#DEFINE IBGE   4
#DEFINE ESTADO 5
#DEFINE MUNICI 6
#DEFINE BAIRRO 7
#DEFINE CEP    8
#DEFINE TELEF1 9
#DEFINE TELEF2 10
#DEFINE CELULA 11
#DEFINE REFERE 12
#DEFINE COMPLE 13
#DEFINE IDENDE 14
#DEFINE CONTAT 15

/**************************************************************************************************/
/*/{Protheus.doc} ECLOJJ04
    @description JOB - Integra novos clientes B2B 
    @type  Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
User Function ECLOJJ04(aParam)
Local _cEmpJob := IIF(ValType(aParam) == "U", "01", aParam[1])  
Local _cFilJob := IIF(ValType(aParam) == "U", "06", aParam[2])

Private _lJob  := IsBlind()

FWLogMsg( "INFO",,"ECLOJJ04","","","","INICIO PEDIDOS ECOMMERCE NAO FATURADOS " + DTOC( DATE() ) + " AS " + TIME(),,,)

If _lJob
    RPCSetType(3)
    RPCSetEnv(_cEmpJob,_cFilJob)
        ECLOJJ04A()
    RpcClearEnv()    
Else 
    FwMsgRun(,{|_oSay| ECLOJJ04A(@_oSay)}, "Aguarde...","Validando pedidos eCommerce.")
EndIf 

FWLogMsg( "INFO",,"ECLOJJ04","","","","FIM PEDIDOS ECOMMERCE NAO FATURADOS " + DTOC( DATE() ) + " AS " + TIME(),,,)

Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} ECLOJJ04A
    @description JOB - Valida se existem novos clientes na fila de integração 
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function ECLOJJ04A(_oSay)
Local _aArea        := GetArea()

Local _cAlias       := ""
Local _cNumSC5      := ""

Local _lLiber       := .F.
Local _lBlqEst      := .F.

Default _oSay       := Nil 

//--------------------------+
// Consulta novos registros |
//--------------------------+
If !ECLOJJ04B(@_cAlias)
    FWLogMsg( "INFO",,"ECLOJJ04","","","","NAO EXISTEM DADOS PARA SEREM PROCESSADOS.",,,)
    RestArea(_aArea)
    Return .F.
EndIf 

dbSelectArea("WSA")
WSA->( dbSetOrder(1) )

//-------------------------------+
// Processa fila de clientes B2B |
//-------------------------------+
While (_cAlias)->( !Eof() )

    //-------------------------------------+
    // XTF - Posiciona registro pelo Recno |
    //-------------------------------------+
    WSA->( dbGoTo((_cAlias)->RECNOWSA) )   
    
    //---------------------+
    // Parametros processo | 
    //---------------------+
    _cNumSC5        := WSA->WSA_NUMSC5

    If !_lJob 
        _oSay:cCaption := "Validando pedido eCommerce " + RTrim(WSA->WSA_NUMECO)
        Processmessages() 
    EndIf 

    FWLogMsg( "INFO",,"ECLOJJ04","","","","VALIDANDO PEDIDO ECOMMERCE " + RTrim(WSA->WSA_NUMECO),,,)

    //---------------------------+
    // Posiciona pedido de venda |
    //---------------------------+
    SC5->( dbSeek(xFilial("SC5") + _cNumSC5))

    //------------------------------------+
    // Somente se pedido não foi faturado |
    //------------------------------------+
    If Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_SERIE) 

        //-----------------------------------------------+
        // Valida se pedido está com bloqueio de estoque |
        //-----------------------------------------------+
        ECLOJJ04C(_cNumSC5,@_lLiber,@_lBlqEst)

        //-------------------------+
        // Libera pedido novamente |
        //-------------------------+
        If _lBlqEst
            ECLOJJ04D(_cNumSC5,@_lBlqEst)
        EndIf 

        If _lLiber .And. !_lBlqEst
            U_GrvStaEc(WSA->WSA_NUMECO,'011')
        EndIf  

    ElseIf !Empty(SC5->C5_NOTA) .And. SC5->C5_NOTA <> "XXXXXXXXX"

        RecLock("WSA",.F.)
            WSA->WSA_DOC    := SC5->C5_NOTA
            WSA->WSA_SERIE  := SC5->C5_SERIE
            WSA->WSA_ENVLOG := '4'
        WSA->( MsUnlock() )

        U_GrvStaEc(WSA->WSA_NUMECO,'011')
        U_GrvStaEc(WSA->WSA_NUMECO,'006')

    EndIf 
    (_cAlias)->( dbSkip() )
EndDo 

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} ECLOJJ04B
    @description Consulta clientes na fila de integração
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
/*/
/**************************************************************************************************/
Static Function ECLOJJ04B(_cAlias)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "    WSA.R_E_C_N_O_ RECNOWSA " + CRLF
_cQuery += " FROM " + CRLF 
_cQuery += "    " + RetSqlName("WSA") + " WSA " + CRLF
_cQuery += "    INNER JOIN " + RetSqlName("SC5") + " C5 (NOLOCK) ON C5.C5_FILIAL = WSA.WSA_FILIAL AND C5.C5_NUM = WSA.WSA_NUMSC5 AND C5.C5_XNUMECO = WSA.WSA_NUMECO AND C5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "    WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "    WSA.WSA_CODSTA = '002' AND " + CRLF
_cQuery += "    WSA.WSA_NUMSC5 <> '' AND " + CRLF
_cQuery += "    WSA.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() ) 
    Return .F.
EndIf 

Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} ECLOJJ04C
    @description Realzia a consulta do cliente no Master Data
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function ECLOJJ04C(_cNumSC5,_lLiber,_lBlqEst)
Local _aArea    := GetArea()

//---------------------+
// Reseta as variaveis |
//---------------------+
_lLiber		:= .F.
_lBlqEst	:= .F.

//---------------------------+
// Posiciona itens liberados |
//---------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )
If SC9->( dbSeek(xFilial("SC9") + _cNumSC5) )

	//-----------------+
	// Pedido liberado |
	//-----------------+
	_lLiber	:= .T.

	While SC9->( !Eof() .And. xFilial("SC9") + _cNumSC5 == SC9->C9_FILIAL + SC9->C9_PEDIDO )
		//---------------------+
		// Bloqueio de Estoque |
		//---------------------+
		If SC9->C9_BLEST == "02"
			_lBlqEst := .T.
		Endif	

		SC9->( dbSkip() )
	EndDo
EndIf

RestArea(_aArea)
Return Nil 

/**************************************************************************************************/
/*/{Protheus.doc} ECLOJJ04D
    @description Realiza a consulta dos endereços dos clientes
    @type  Static Function
    @author Bernard M Margarido 
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function ECLOJJ04D(_cNumSC5,_lBlqEst)
Local _aArea		:= GetArea()

Local _nQtdLib		:= 0

Local _lCredito 	:= .T.
Local _lEstoque		:= .T.
Local _lLiber		:= .T.
Local _lTransf   	:= .F.

_lBlqEst := .F.

//-----------------+
// Pedido de venda | 
//-----------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//-----------------------+
// Itens pedido de venda |
//-----------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
SC6->( dbSeeK(xFilial("SC6") + _cNumSC5) )
While SC6->( !Eof() .And. xFilial("SC6") + _cNumSC5 == SC6->C6_FILIAL + SC6->C6_NUM )

	_nQtdLib := SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT + SC6->C6_QTDLIB + SC6->C6_XQTDRES )  
	If _nQtdLib > 0
		MaLibDoFat(SC6->(RecNo()),_nQtdLib,@_lCredito,@_lEstoque,.F.,.F.,_lLiber,_lTransf)
	EndIf

	SC6->( dbSkip() )
EndDo

//-----------------------------+
// Destrava todos os registros |
//-----------------------------+
MsUnLockAll()

//---------------------------+
// Grava liberação do Pedido |
//---------------------------+
MaLiberOk({_cNumSC5},.T.) 

RestArea(_aArea)
Return Nil 
