#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

/*************************************************************************************/
/*/{Protheus.doc} DNFINJ01
    @description Realiza a consulta de novos pagamento
    @type  Function
    @author Bernard M Margarido
    @since 03/05/2023
    @version version
/*/
/*************************************************************************************/
User Function DNFINJ01(_aParam)
Local _lJob         := ValType(_aParam) == "A" .And. Len(_aParam) > 0 

Local _cEmp         := IIF(_lJob,_aParam[1],'04')
Local _cFil         := IIF(_lJob,_aParam[2],'0404')

CoNout( "<< DNFINJ01 >> - INICIO " + DToS( Date() ) + " - " + Time() )

//----------------------------------------+
// Realiza a abertura da empresa e filial |
//----------------------------------------+
If _lJob
    RPCSetType(3)
    RPCSetEnv(_cEmp,_cFil)
EndIf 

If _lJob
    DNFINJ01A()
Else
    FWMsgRun(,{|| DNFINJ01A()},"Aguarde....","Integrando pagamentos PagarMe.")
EndIf 

//------------------------------------------+
// Realiza a encerramento da empresa/filial |
//------------------------------------------+
If _lJob 
    RPCClearEnv()
EndIf 

CoNout( "<< DNFINJ01 >> - FIM " + DToS( Date() ) + " - " + Time() )    
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} DNFINJ01A
    @description Realiza a integração dos pagamento da PagarMe
    @type  Static Function
    @author Bernard M Margarido
    @since 19/04/2023
    @version version
/*/
/*********************************************************************************/
Static Function DNFINJ01A()
Local _c1DUP        := SuperGetMv("MV_1DUP")
Local _cCodigo      := ""
Local _cStatus      := ""
Local _cID          := ""
Local _cTID         := ""
Local _cParcela     := ""
Local _cType        := ""
Local _cStaPay      := ""
Local _cRecID       := ""
Local _cJSonPay     := ""

Local _nValor       := 0
Local _nDesc        := 0
Local _nTaxa        := 0
Local _nX           := 0
Local _nPage        := 0
Local _nTID         := TamSx3("XTA_ID")[1]
Local _nTParc       := TamSx3("XTA_PARC")[1]

Local _dDtaIni      := DaySub(dDataBase,2)
Local _dDtaFim      := DaySub(dDataBase,1)
Local _dDtaEmiss    := ""
Local _dDtaPgto     := ""

Local _lGrava       := .F.
Local _lBaixado     := .F.
Local _lRecebivel   := .T.

Local _oPagarMe     := PagarMe():New()
Local _oJSon        := Nil 

//-----------------------------------+
// XTA- Itens pagamentos disponiveis |
//-----------------------------------+
dbSelectArea("XTA")
XTA->( dbSetOrder(1) )

//-----------------------------------------+
// Processa baixa dos pagamentos eCommerce |
//-----------------------------------------+
While _dDtaIni <= _dDtaFim

    _nPage          := 1
    _lGrava         := .F.
    _lRecebivel     := .T.
           
    //--------------------------+
    // Conecta com a adquirente |
    //--------------------------+
    While _lRecebivel

        _oPagarMe:dDTPayIni     := dToc(_dDtaIni)
        _oPagarMe:dDTPayFim     := dToc(_dDtaFim)    
        _oPagarMe:nPage         := _nPage
        If _oPagarMe:Recebivel()

            _oJSon := xFromJson(_oPagarMe:cRetJSon)

            If ValType(_oJSon) <> "U" .And. Len(_oJSon) > 0

                For _nX := 1 To Len(_oJSon)

                    _cStatus    := "1"
                    _cID        := cValToChar(_oJSon[_nX][#"id"])
                    _cTID       := cValToChar(_oJSon[_nX][#"transaction_id"])
                    _cParcela   := IIF(_oJSon[_nX][#"installment"] == Nil, _c1DUP, LJParcela(_oJSon[_nX][#"installment"], _c1DUP ))
                    _cType      := _oJSon[_nX][#"type"]
                    _cStaPay    := _oJSon[_nX][#"status"]
                    _cRecID     := _oJSon[_nX][#"recipient_id"]
                    _cJSonPay   := xToJson(_oJSon[_nX])
                    _nValor     := _oJSon[_nX][#"amount"] / 100   
                    _nDesc      := (_oJSon[_nX][#"amount"] / 100) - ( _oJSon[_nX][#"fee"] / 100 )
                    _nTaxa      := _oJSon[_nX][#"fee"] / 100
                    _dDtaEmiss  := sTod(SubStr(StrTran(_oJSon[_nX][#"date_created"],"-",""),1,10))
                    _dDtaPgto   := sTod(SubStr(StrTran(_oJSon[_nX][#"payment_date"],"-",""),1,10))
                    _lGrvPgto   := .T.
                    _lBaixado   := DNFINJ01B(_cTID,_cParcela)

                    If XTA->( dbSeek(xFilial("XTA") + PadR(_cTID,_nTID) + PadR(_cParcela,_nTParc)) )
                        _cCodigo := XTA->XTA_CODIGO
                        _lGrvPgto:= .F.
                    Else
                        _cCodigo := GetSxeNum("XTA","XTA_CODIGO")
                        _lGrvPgto:= .T.
                    EndIf 

                    //----------------------------------------+
                    // Gravação itens do pagamento e-Commerce |
                    //----------------------------------------+
                    RecLock("XTA",_lGrvPgto)
                        XTA->XTA_FILIAL     := xFilial("XTA")
                        XTA->XTA_CODIGO     := _cCodigo
                        XTA->XTA_ID         := _cID
                        XTA->XTA_IDPAY      := _cTID
                        XTA->XTA_DTEMIS     := _dDtaEmiss
                        XTA->XTA_DTPGTO     := _dDtaPgto
                        XTA->XTA_PARC       := _cParcela
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

                    //-------------------------------------------+
                    // Valida numeração no controle de numeração | 
                    //-------------------------------------------+
                    If _lGrvPgto
                        ConfirmSX8()
                    EndIf

                Next _nX
                //----------------+     
                // Proxima pagina |
                //----------------+ 
                _nPage++
            Else 
                _lRecebivel := .F.
            EndIf
        Else 
            _cMsgErro   := _oPagarMe:cError + " " + CRLF
            _lRecebivel := .F.
        EndIf

    EndDo 

    _dDtaIni := DaySum(_dDtaIni,1)

EndDo    

Return Nil

/****************************************************************************************************/
/*/{Protheus.doc} DNFINJ01B
    @description Valida se titulo ja está baixado 
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/07/2021
/*/
/****************************************************************************************************/
Static Function DNFINJ01B(_cTID,_cParcela)
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
_cQuery += "	E1.E1_DOCTEF = '" + _cTID + "' AND " + CRLF
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
