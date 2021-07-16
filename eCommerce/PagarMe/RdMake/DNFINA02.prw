#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

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

Local _dDtIni	:= CriaVar("F2_EMISSAO",.F.)
Local _dDtFim	:= CriaVar("F2_EMISSAO",.F.)

Local _bVldParam:= {|| DnFinA02A() }

aAdd(_aParam,{1, "Data De", _dDtIni, "@D", ".T.", , "", 60, .T.})
aAdd(_aParam,{1, "Data Ate", _dDtFim, "@D", ".T.", , "", 60, .T.})
   
If ParamBox(_aParam,"Importa Titulos PagarMe",@_aRet,_bVldParam,,,,,,,.T., .T.)
	//------------+
	// Monta Tela |
	//------------+
	FWMsgRun(, {|_oSay| DNFINA02B(_oSay) }, "Aguarde...", "Consultando registros .... " )
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
Static Function DNFINA02B(_oSay)
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

Local _lGrava   := .F.

Local _oPagarMe := PagarMe():New()
Local _oJSon    := Nil 

//------------------------------+
// XT9 - Pagamentos disponiveis |
//------------------------------+
dbSelectArea("XT9")
XT9->( dbSetOrder(1) )

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

        //-----------------------------------+
        // Valida se contem pagamento do dia |
        //-----------------------------------+
        //If !XT9->( dbSeek(xFilial("XT9") + dToc(_dDtaIni)) )
        //    _cCodigo := GeSxeNum("XT9","XT9_CODIGO")
        //    _lGrava  := .T.
        //EndIf


        If ValType(_oJSon) <> "U"
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
                //----------------+
                // Calcula totais | 
                //----------------+
                _nTotal     += _nValor
                _nTotLiq    += _nDesc
                
            Next _nX 
        EndIf
    Else 
        _cMsgErro := _oPagarMe:cError + " " + CRLF
    EndIf
    _dDtaIni := DaySum(_dDtaIni,1)
EndDo

Return Nil 

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