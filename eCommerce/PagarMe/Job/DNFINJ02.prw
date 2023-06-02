#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

/*************************************************************************************/
/*/{Protheus.doc} DNFINJ02
    @description Realiza a consulta de novos pagamento
    @type  Function
    @author Bernard M Margarido
    @since 03/05/2023
    @version version
/*/
/*************************************************************************************/
User Function DNFINJ02(_aParam)
Local _lJob         := ValType(_aParam) == "A" .And. Len(_aParam) > 0 

Local _cEmp         := IIF(_lJob,_aParam[1],'01')
Local _cFil         := IIF(_lJob,_aParam[2],'06')

CoNout( "<< DNFINJ02 >> - INICIO " + DToS( Date() ) + " - " + Time() )

//----------------------------------------+
// Realiza a abertura da empresa e filial |
//----------------------------------------+
If _lJob
    RPCSetType(3)
    RPCSetEnv(_cEmp,_cFil)
EndIf 

If _lJob
    DNFINJ02A(_lJob)
Else
    FWMsgRun(,{|| DNFINJ02A(_lJob)},"Aguarde....","Integrando pagamentos PagarMe.")
EndIf 

//------------------------------------------+
// Realiza a encerramento da empresa/filial |
//------------------------------------------+
If _lJob 
    RPCClearEnv()
EndIf 

CoNout( "<< DNFINJ02 >> - FIM " + DToS( Date() ) + " - " + Time() )    
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} DNFINJ02A
    @description Realiza a integração dos pagamento da PagarMe
    @type  Static Function
    @author Bernard M Margarido
    @since 19/04/2023
    @version version
/*/
/*********************************************************************************/
Static Function DNFINJ02A(_lJob)
Local _c1DUP        := SuperGetMv("MV_1DUP")
Local _cStatus      := ""
Local _cID          := ""
Local _cTID         := ""
Local _cParcela     := ""
Local _cType        := ""
Local _cStaPay      := ""
Local _cRecID       := ""
Local _cJSonPay     := ""
Local _cAlias       := ""

Local _nValor       := 0
Local _nDesc        := 0
Local _nTaxa        := 0
Local _nPage        := 0

Local _dDtaEmiss    := ""
Local _dDtaPgto     := ""

Local _lGrava       := .F.
Local _lBaixado     := .F.
Local _lRecebivel   := .T.

Local _oPagarMe     := PagarMe():New()
Local _oJSon        := Nil 

//-----------------------------------------+
// Consulta pagamentos a serem consultados |
//-----------------------------------------+
If !DNFINJ02B(@_cAlias,_lJob)
    Return .F.
EndIf 

//-----------------------------------+
// XTA- Itens pagamentos disponiveis |
//-----------------------------------+
dbSelectArea("XTA")
XTA->( dbSetOrder(1) )

//-----------------------------------------+
// Processa baixa dos pagamentos eCommerce |
//-----------------------------------------+
While (_cAlias)->( !Eof() )

    _nPage          := 1
    _lGrava         := .F.
    _lRecebivel     := .T.

    //--------------------+
    // Posiciona registro |
    //--------------------+
    XTA->( dbGoTo((_cAlias)->RECNOXTA))

    _oPagarMe:cId   := XTA->XTA_ID

    If _oPagarMe:Recebivel()

        _oJSon := xFromJson(_oPagarMe:cRetJSon)

        If ValType(_oJSon) <> "U" 
            _cStatus    := "1"
            _cID        := cValToChar(_oJSon[#"id"])
            _cTID       := cValToChar(_oJSon[#"transaction_id"])
            _cParcela   := IIF(_oJSon[#"installment"] == Nil, _c1DUP, LJParcela(_oJSon[#"installment"], _c1DUP ))
            _cType      := _oJSon[#"type"]
            _cStaPay    := _oJSon[#"status"]
            _cRecID     := _oJSon[#"recipient_id"]
            _cJSonPay   := xToJson(_oJSon)
            _nValor     := _oJSon[#"amount"] / 100   
            _nDesc      := (_oJSon[#"amount"] / 100) - ( _oJSon[#"fee"] / 100 )
            _nTaxa      := _oJSon[#"fee"] / 100
            _dDtaEmiss  := sTod(SubStr(StrTran(_oJSon[#"date_created"],"-",""),1,10))
            _dDtaPgto   := sTod(SubStr(StrTran(_oJSon[#"payment_date"],"-",""),1,10))
            _lGrvPgto   := .F.
            _lBaixado   := DNFINJ02C(_cTID,_cParcela)

            //----------------------------------------+
            // Gravação itens do pagamento e-Commerce |
            //----------------------------------------+
            RecLock("XTA",_lGrvPgto)
                XTA->XTA_VALOR      := IIF(_nValor < 0, 0, _nValor)
                XTA->XTA_VLRLIQ     := IIF(_nDesc < 0, 0, _nDesc )
                XTA->XTA_TAXA       := IIF(_nTaxa < 0, _nTaxa * -1, _nTaxa)
                XTA->XTA_VLRREB     := IIF(_nValor < 0, _nValor * -1, 0)
                XTA->XTA_STATUS     := IIf(_lBaixado, "2", "1")
                XTA->XTA_TYPE       := _cType
                XTA->XTA_STAPAY     := _cStaPay
                XTA->XTA_RECID      := _cRecID 
                XTA->XTA_JSON       := _cJSonPay  
            XTA->( MsUnLock() )
        EndIf
    Else 
        _cMsgErro   := _oPagarMe:cError + " " + CRLF
    EndIf

    (_cAlias)->( dbSkip() )

EndDo    

(_cAlias)->( dbCloseArea() )

Return Nil

/****************************************************************************************************/
/*/{Protheus.doc} DNFINJ02B
    @description Consulta pagamentos 
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/07/2021
/*/
/****************************************************************************************************/
Static Function DNFINJ02B(_cAlias,_lJob)
Local _cQuery   := ""

Local _dDtaPgi := dToS(DaySub(Date(),1))
Local _dDtaPgf := dToS(Date())

_cQuery := " SELECT " + CRLF
_cQuery += "    XTA.R_E_C_N_O_ RECNOXTA " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "    " + RetSqlName("XTA") + " XTA " + CRLF 
_cQuery += " WHERE " + CRLF
_cQuery += "	XTA.XTA_FILIAL = '" + xFilial("XTA") + "' AND " + CRLF
_cQuery += "	XTA.XTA_STATUS = '1' AND " + CRLF
_cQuery += "	XTA.XTA_VALOR > 0 AND " + CRLF
_cQuery += "    XTA.XTA_STAPAY <> 'paid' AND " + CRLF
If _lJob
    _cQuery += "    XTA.XTA_DTPGTO BETWEEN '" + _dDtaPgi + "' AND '" + _dDtaPgf + "' AND " + CRLF
Endif 
_cQuery += "    XTA.D_E_L_E_T_ = ''	" + CRLF

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
Endif 
    

Return .T.  

/****************************************************************************************************/
/*/{Protheus.doc} DNFINJ02B
    @description Valida se titulo ja está baixado 
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/07/2021
/*/
/****************************************************************************************************/
Static Function DNFINJ02C(_cTID,_cParcela)
Local _cQuery   := ""
Local _cAlias   := ""

Local _lRet     := .T.

_cQuery := " SELECT " + CRLF
_cQuery += "	CASE " + CRLF
_cQuery += "		WHEN E1.E1_SALDO > 0 THEN " + CRLF
_cQuery += "			'ABERTO' " + CRLF
_cQuery += "		ELSE " + CRLF
_cQuery += "			'BAIXADO' " + CRLF
_cQuery += "	END STATUS " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SE1") + " E1 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	E1.E1_FILIAL = '" + xFilial("SE1") + "' AND " + CRLF
_cQuery += "	E1.E1_XTID = '" + _cTID + "' AND " + CRLF
_cQuery += "	( E1.E1_PARCELA = '" + _cParcela + "' OR E1.E1_PARCELA = '' ) AND " + CRLF
_cQuery += "	E1.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If Empty((_cAlias)->STATUS) .Or. RTrim((_cAlias)->STATUS) == "ABERTO"
    _lRet := .F.
ElseIf RTrim((_cAlias)->STATUS) == "BAIXADO"
    _lRet := .T.
EndIf

(_cAlias)->( dbCloseArea() )

Return _lRet  
