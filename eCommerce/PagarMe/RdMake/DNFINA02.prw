#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

Static _nTID    := TamSx3("XTA_ID")[1]
Static _nTParc  := TamSx3("XTA_PARC")[1]

/************************************************************************************/
/*/{Protheus.doc} DNFINA02
    @description Importa dados da operadora de pagamento
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/************************************************************************************/
User Function DNFINA02()
Local _aArea    := GetArea()
Local _aParam	:= {}
Local _aRet		:= {}

Local _cMsgErro := ""

Local _dDtIni	:= CriaVar("F2_EMISSAO",.F.)
Local _dDtFim	:= CriaVar("F2_EMISSAO",.F.)

Local _bVldParam:= {|| DnFinA02A() }

aAdd(_aParam,{1, "Data De", _dDtIni, "@D", ".T.", , "", 60, .T.})
aAdd(_aParam,{1, "Data Ate", _dDtFim, "@D", ".T.", , "", 60, .T.})
   
If ParamBox(_aParam,"Importa Titulos PagarMe",@_aRet,_bVldParam,,,,,,,.T., .T.)
	//------------+
	// Monta Tela |
	//------------+
	FWMsgRun(, {|_oSay| DNFINA02B(_oSay,@_cMsgErro) }, "Aguarde...", "Consultando registros .... " )
    
    If !Empty(_cMsgErro)
        MsgInfo(_cMsgErro,"Dana - Avisos")
    EndIf

EndIf


RestArea(_aArea)
Return Nil 

/********************************************************************************************/
/*/{Protheus.doc} DNFINA02B
    @description Realiza a consulta dos titulos eCommerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 16/07/2021
/*/
/********************************************************************************************/
Static Function DNFINA02B(_oSay,_cMsgErro)
Local _c1DUP        := SuperGetMv("MV_1DUP")	
Local _cID          := ""
Local _cTID         := ""
Local _cParcela     := ""
Local _cType        := ""

//Local _nDias      := DateDiffDay(mv_par01,mv_par02)
Local _nValor       := 0
Local _nDesc        := 0
Local _nTaxa        := 0
Local _nX           := 0
Local _nTotal       := 0
Local _nTotLiq      := 0

Local _dDtaIni      := mv_par01 //DaySub(mv_par01,1)
Local _dDtaFim      := mv_par02
Local _dDtaEmiss    := ""
Local _dDtaPgto     := ""

Local _lGrava       := .F.
Local _lBaixado     := .F.

Local _oPagarMe     := PagarMe():New()
Local _oJSon        := Nil 

//------------------------------+
// XT9 - Pagamentos disponiveis |
//------------------------------+
dbSelectArea("XT9")
XT9->( dbSetOrder(2) )

//------------------------------------+
// XTA - Itens pagamentos disponiveis |
//------------------------------------+
dbSelectArea("XTA")
XTA->( dbSetOrder(1) )

//-----------------------------------------+
// Processa baixa dos pagamentos eCommerce |
//-----------------------------------------+
While _dDtaIni <= _dDtaFim

    _oSay:cCaption  := "Integrando pagamentos " + dToc(_dDtaIni)
    _nTotal         := 0
    _nTotLiq        := 0
    _lGrava         := .F.

    //--------------------------+
    // Conecta com a adquirente |
    //--------------------------+
    _oPagarMe:dDtaPayment := dToc(_dDtaIni)
    If _oPagarMe:Recebivel()

        _oJSon := xFromJson(_oPagarMe:cRetJSon)

        If ValType(_oJSon) <> "U" .And. Len(_oJSon) > 0

            //-----------------------------------+
            // Valida se contem pagamento do dia |
            //-----------------------------------+
            If !XT9->( dbSeek(xFilial("XT9") + DToS(_dDtaIni)) )
                _cCodigo := GetSxeNum("XT9","XT9_CODIGO")
                _lGrava  := .T.
            Else 
                _cCodigo := XT9->XT9_CODIGO
                _lGrava  := .F.
            EndIf

            For _nX := 1 To Len(_oJSon)

                _cStatus    := "1"
                _cID        := cValToChar(_oJSon[_nX][#"id"])
                _cTID       := cValToChar(_oJSon[_nX][#"transaction_id"])
                _cParcela   := IIF(_oJSon[_nX][#"installment"] == Nil,"A",LJParcela(_oJSon[_nX][#"installment"], _c1DUP ))
                _cType      := _oJSon[_nX][#"type"]
                _nValor     := _oJSon[_nX][#"amount"] / 100   
                _nDesc      := (_oJSon[_nX][#"amount"] / 100) - ( _oJSon[_nX][#"fee"] / 100 )
                _nTaxa      := _oJSon[_nX][#"fee"] / 100
                _dDtaEmiss  := sTod(SubStr(StrTran(_oJSon[_nX][#"date_created"],"-",""),1,10))
                _dDtaPgto   := sTod(SubStr(StrTran(_oJSon[_nX][#"payment_date"],"-",""),1,10))
                _lGrvPgto   := .T.
                _lBaixado   := DnFinA02C(_cTID,_cParcela)

                If !XTA->( dbSeek(xFilial("XTA") + PadR(_cID,_nTID) + PadR(_cParcela,_nTParc)) )
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
                        XTA->XTA_VALOR      := IIF(_nValor < 0,0, _nValor)
                        XTA->XTA_VLRLIQ     := IIF(_nDesc < 0,0, _nDesc )
                        XTA->XTA_TAXA       := IIF(_nTaxa < 0, _nTaxa * -1, _nTaxa)
                        XTA->XTA_VLRREB     := IIF(_nValor < 0, _nValor * -1, 0)
                        XTA->XTA_STATUS     := IIf(_lBaixado,"2","1")
                        XTA->XTA_TYPE       := _cType
                    XTA->( MsUnLock() )
                EndIf
                
                //----------------+
                // Calcula totais | 
                //----------------+
                _nTotal     += _nValor
                _nTotLiq    += _nDesc

            Next _nX 

            //--------------------------------+
            // Grava dados da baixa eCommerce |
            //--------------------------------+
            RecLock("XT9",_lGrava)
                XT9->XT9_FILIAL := xFilial("XT9")
                XT9->XT9_CODIGO := _cCodigo
                XT9->XT9_DATA   := _dDtaIni
                XT9->XT9_VLRTOT := _nTotal
                XT9->XT9_VLRLIQ := _nTotLiq
                XT9->XT9_STATUS := "1"
            XT9->( MsUnLock() )

            //-------------------------------------------+
            // Valida numeração no controle de numeração | 
            //-------------------------------------------+
            If _lGrava
                ConfirmSX8()
            EndIf

        EndIf
    Else 
        _cMsgErro := _oPagarMe:cError + " " + CRLF
    EndIf
    _dDtaIni := DaySum(_dDtaIni,1)
EndDo

Return Nil 

/****************************************************************************************************/
/*/{Protheus.doc} DnFinA02C
    @description Valida se titulo ja está baixado 
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/07/2021
/*/
/****************************************************************************************************/
Static Function DnFinA02C(_cTID,_cParcela)
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
_cQuery += "	E1.E1_PARCELA = '" + _cParcela + "' AND " + CRLF
_cQuery += "	E1.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If Empty((_cAlias)->STATUS) .Or. (_cAlias)->STATUS == "ABERTO"
    _lRet := .F.
ElseIf (_cAlias)->STATUS == "BAIXADO"
    _lRet := .T.
EndIf

(_cAlias)->( dbCloseArea() )

Return _lRet  

/****************************************************************************************************/
/*/{Protheus.doc} DnFinA02A
    @description Valida parametros digitados 
    @type  Static Function
    @author Bernard M. Margarido
    @since 16/07/2021
/*/
/****************************************************************************************************/
Static Function DnFinA02A()
Local _lRet := .T.
Return _lRet 