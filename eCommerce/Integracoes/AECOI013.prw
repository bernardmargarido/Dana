#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "013"
Static cDescInt	:= "Invoice"
Static cDirImp	:= "/ecommerce/"

/************************************************************************************/
/*/{Protheus.doc} AECOI013
	@description Realiza o envio do numero da nota para o e-Commerce
	@author Bernard M. Margarido
	@since 13/02/2017
	@version undefined
	@param cOrderId		, characters, OrderID eCommerce
	@type function
/*/
/************************************************************************************/
User function AECOI013(cOrderId)
Local aArea		:= GetArea()
Local aRet		:= {.T.,"",""}

Local _lBloqueio:= GetNewPar("EC_BLSMSG",.F.)
Local _lRet 	:= .T.

Private cThread	:= Alltrim(Str(ThreadId()))
Private cStaLog	:= "0"
Private cArqLog	:= ""	

Private nQtdInt	:= 0

Private cHrIni	:= Time()
Private dDtaInt	:= Date()

Private aMsgErro:= {}

Private lJob 	:= IIF(Isincallstack("U_ECLOJM07"),.F.,.T.) 

If _lBloqueio
	RestArea(aArea)
	Return aRet
EndIf

//----------------------------------+
// Grava Log inicio das Integrações | 
//----------------------------------+
u_AEcoGrvLog(cCodInt,cDescInt,dDtaInt,cHrIni,,,,,cThread,1)

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirImp)
cArqLog := cDirImp + "INVOICE" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DE INVOICE COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())

//-----------------------------------------+
// Inicia processo de envio das categorias |
//-----------------------------------------+
If lJob
	_lRet := AECOINT13(cOrderId)
Else
	Processa({|| _lRet := AECOINT13(cOrderId) },"Aguarde...","Enviando invoice.")
EndIf

LogExec("FINALIZA ENVIO DE INVOICE COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
LogExec(Replicate("-",80))
ConOut("")

//----------------------------------+
// Envia e-Mail com o Logs de Erros |
//----------------------------------+
If Len(aMsgErro) > 0
	cStaLog := "1"
	u_AEcoMail(cCodInt,cDescInt,aMsgErro)
EndIf

//----------------------------------+
// Grava Log inicio das Integrações |
//----------------------------------+
u_AEcoGrvLog(cCodInt,cDescInt,dDtaInt,cHrIni,Time(),cStaLog,nQtdInt,aMsgErro,cThread,2)

Return _lRet

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT13
	@description	Realiza o envio da Invoice para o e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT13(cOrderId)
Local aArea		:= GetArea()
Local aRet		:= {.F.,"",""}

Local _cCodDLog := GetNewPar("DN_CODDLOG")
Local cChaveNfe := ""
Local cTracking := ""
Local cUrlTrack := ""
Local cNumTransp:= ""	
Local cRest		:= ""  
Local cQuant 	:= ""
Local cPrcVen	:= ""
Local cDtaFat	:= ""
Local cVlrFat	:= ""
Local cUrl		:= ""
Local cAppKey	:= ""
Local cAppToken	:= ""
Local dDtaEmiss	:= ""

Local nIdSku	:= 0
Local _nVlrTotal:= 0
Local _nTOrderId:= TamSx3("WSA_NUMECO")[1]

Local _oJson	:= Nil
Local _oItens	:= Nil

//---------------------+
// Posiciona Orçamento |
//---------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )
WSA->( dbSeek(xFilial("WSA") + PadR(cOrderId,_nTOrderId)) )

//----------------------------------+
// Consulta Data de Emissao da Nota |
//----------------------------------+
aEcoI13DtaE(WSA->WSA_DOC,WSA->WSA_SERIE,WSA->WSA_CLIENT,WSA->WSA_LOJA,@cChaveNfe,@dDtaEmiss,@_nVlrTotal)

cTracking 	:= Alltrim(WSA->WSA_TRACKI)
cNumTransp	:= WSA->WSA_TRANSP

//------------------+
// Valida se é DLog |
//------------------+
If Rtrim(cNumTransp) $ RTrim(_cCodDLog)
	aEcoI13Url(WSA->WSA_NUMECO,@cUrlTrack,@cTracking)
EndIf
//-----------------------+
// Monta String API Rest |
//-----------------------+
_oJson					:= {}        
_oJson					:= Array(#)	
_oJson[#"type"]			:= "Output"
_oJson[#"invoiceNumber"]:= RTrim(WSA->WSA_DOC) + "-" + RTrim(WSA->WSA_SERIE)

//------------+
// Chave NF-e |
//------------+
If !Empty(cChaveNfe)
	_oJson[#"invoiceKey"]	:= cChaveNfe
EndIf
_oJson[#"courier"]			:= cNumTransp
_oJson[#"trackingNumber"]	:= cTracking
_oJson[#"trackingUrl"]		:= cUrlTrack

//-------------------------+
// Posiciona Itens da Nota |
//-------------------------+
_oJson[#"items"]	:= {}

WSB->( dbSetOrder(1) )
WSB->( dbSeek(xFilial("WSB") + WSA->WSA_NUM ) )
While WSB->( !Eof() .And. xFilial("WSB") + WSA->WSA_NUM == WSB->WSB_FILIAL + WSB->WSB_NUM )

	aAdd(_oJson[#"items"],Array(#))
	_oItens				:= aTail(_oJson[#"items"])   
	
	//------------------------------------------+
	// Posiciona Porduto para pegar codigo Vtex |
	//------------------------------------------+
	aEcoI013Sku(WSB->WSB_PRODUT,@nIdSku)
	
	cQuant := Alltrim(Str(Int(WSB->WSB_QUANT)))
	cPrcVen:= cValToChar(RetPrcUni(WSB->WSB_VRUNIT))

	_oItens[#"id"]			:= 	IIF(Empty(WSB->WSB_KIT),Alltrim(Str(nIdSku)),RTrim(WSB->WSB_KIT))
	_oItens[#"quantity"]	:= 	cQuant
	_oItens[#"price"]		:= 	cPrcVen
		
	WSB->( dbSkip() )   
	
EndDo

//-----------------------------+
// Data e Valor de Faturamento |
//-----------------------------+
cDtaFat := IIF(Empty(dDtaEmiss),dTos(dDataBase),dTos(dDtaEmiss))
cDtaFat := SubStr(cDtaFat,1,4) + "-" + SubStr(cDtaFat,5,2) + "-" + SubStr(cDtaFat,7,2) //+ "T" + SubStr(Time(),1,8)
cVlrFat	:= cValToChar(RetPrcUni(_nVlrTotal))    

//------------------------+
// Data e Valor da Fatura |
//------------------------+
_oJson[#"issuanceDate"]	:= cDtaFat
_oJson[#"invoiceValue"]	:= cVlrFat

//---------------------------+
// Transforma Objeto em JSON |
//---------------------------+
cRest := xToJson(_oJson)

//----------------+
// Valida ID loja |
//----------------+
If Empty(WSA->WSA_IDLOJA)
	cUrl			:= GetNewPar("EC_URLREST")
	cAppKey			:= GetNewPar("EC_APPKEY")
	cAppToken		:= GetNewPar("EC_APPTOKE")
Else 
	dbSelectArea("XTC")
	XTC->( dbSetOrder(1) )
	XTC->( dbSeek(xFilial("XTC") + WSA->WSA_IDLOJA))

	cUrl			:= RTrim(XTC->XTC_URL2)
	cAppKey			:= RTrim(XTC->XTC_APPKEY)
	cAppToken		:= RTrim(XTC->XTC_APPTOK)

EndIf 
//---------------+
// Envia Invoice |
//---------------+ 
aRet := AEcoI13Inv(WSA->WSA_DOC,WSA->WSA_SERIE,cOrderId,cRest,cUrl,cAppKey,cAppToken)

RestArea(aArea)
Return aRet[1]

/************************************************************************************/
/*/{Protheus.doc} aEcoI13DtaE
	@description Retorna dados da nota fiscal de saida 
	@author Bernard M. Margarido
	@since 18/04/2017
	@type function
/*/
/************************************************************************************/
Static Function aEcoI13DtaE(cDoc,cSerie,cCliente,cLoja,cChaveNfe,dDtaEmiss,_nVlrTotal)
Local aArea		:= GetArea()

dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If SF2->( dbSeek(xFilial("SF2") + Padr(cDoc,TamSx3("F2_DOC")[1]) + Padr(cSerie,TamSx3("F2_SERIE")[1]) + PadR(cCliente,TamSx3("F2_CLIENTE")[1]) + PadR(cLoja,TamSx3("F2_LOJA")[1])) )
	cChaveNfe := SF2->F2_CHVNFE
	dDtaEmiss := SF2->F2_EMISSAO
	_nVlrTotal:= SF2->F2_VALBRUT	
EndIf	 

RestArea(aArea)
Return .T.

/********************************************************************/
/*/{Protheus.doc} aEcoI13Url
	@description Retorna URL de rastreio 
	@author Bernard M. Margarido
	@since 14/02/2017
	@version undefined
	@type function
/*/
/********************************************************************/
Static Function aEcoI13Url(_cNumEco,cUrlTrack,cTracking)
Local _cAlias	:= ""
Local _cQuery   := ""

Local _oJSonUrl	:= Nil 

_cQuery := " SELECT " + CRLF
_cQuery	+= "	ZZC.R_E_C_N_O_ RECNOZZC, " + CRLF
_cQuery	+= "	ZZC.ZZC_STATUS STATUS, " + CRLF
_cQuery	+= "	CAST(CAST( ZZC.ZZC_JSON AS BINARY(1024)) AS VARCHAR(1024)) JSON_DLOG " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= "	" + RetSqlName("ZZC") + " ZZC " + CRLF 
_cQuery	+= " WHERE " + CRLF
_cQuery	+= "	ZZC.ZZC_FILIAL = '" + xFilial("ZZC") + "' AND " + CRLF
_cQuery	+= "	ZZC.ZZC_NUMECO = '" + _cNumEco + "' AND " + CRLF
_cQuery	+= "	ZZC.D_E_L_E_T_ = '' " + CRLF

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->STATUS == "2"
	_oJSonUrl 	:= xFromJson(RTrim((_cAlias)->JSON_DLOG))
	cUrlTrack	:= _oJSonUrl[#"linkRastreamento"]
EndIf

(_cAlias)->( dbCloseArea() )

Return Nil 

/********************************************************************/
/*/{Protheus.doc} AEcoI13Inv
	@description Rotina realiza o envio da Invoice para o e-Commerce
	@author Bernard M. Margarido
	@since 14/02/2017
	@version undefined
	@type function
/*/
/********************************************************************/
Static Function AEcoI13Inv(cDocNum,cSerie,cOrderId,cRest,cUrl,cAppKey,cAppToken)
Local aRet			:= {.T.,"",""}

//Local cUrl		:= GetNewPar("EC_URLREST")
//Local cAppKey		:= GetNewPar("EC_APPKEY")
//Local cAppToken	:= GetNewPar("EC_APPTOKE")

Local nTimeOut		:= 240

Local aHeadOut  	:= {}
Local cXmlHead 	 	:= ""     
Local cRetPost  	:= ""
Local oXmlRet   	:= Nil 

aAdd(aHeadOut,"Content-Type: application/json" )
aAdd(aHeadOut,"X-VTEX-API-AppKey:" + cAppKey )
aAdd(aHeadOut,"X-VTEX-API-AppToken:" + cAppToken ) 
                     
cRetPost := HttpPost(cUrl + "/api/oms/pvt/orders/" + Alltrim(cOrderId) + "/invoice","",cRest,nTimeOut,aHeadOut,@cXmlHead) 

If HTTPGetStatus() == 200 
	If FWJsonDeserialize(cRetPost,@oXmlRet)
		If ValType(oXmlRet) == "O"	
			aRet[1] := .T.
			aRet[2] := cDocNum + cSerie
			aRet[3] := "INVOICE" + cDocNum + cSerie + "ENVIADA COM SUCESSO "
			
			LogExec("INVOICE" + cDocNum + cSerie + "ENVIADA COM SUCESSO " )
		EndIf
	Else
		aRet[1] := .T.
		aRet[2] := cDocNum + cSerie
		aRet[3] := "INVOICE" + cDocNum + cSerie + "ENVIADA COM SUCESSO "
		
		LogExec("INVOICE" + cDocNum + cSerie + "ENVIADA COM SUCESSO " + CRLF + cRetPost )
	EndIf		
	
Else 
	If FWJsonDeserialize(cRetPost,@oXmlRet)
		If ValType(oXmlRet) == "O"	
			aRet[1] := .F.
			aRet[2] := cDocNum + cSerie 	
			aRet[3] := "ERRO AO ENVIAR INVOICE " + cDocNum + " / " + cSerie 
			
			aAdd(aMsgErro,{aRet[2],aRet[3]})
			
			LogExec("ERRO AO ENVIAR INVOICE " + cDocNum + " / " + cSerie) 
		EndIf	
	EndIf	
EndIf

Return aRet

/*******************************************************************************/
/*/{Protheus.doc} aEcoI013Sku
	@description Consulta SKU
	@author Bernard M. Margarido
	@since 23/01/2018
	@version 1.0
	@type function
/*/
/*******************************************************************************/
Static Function aEcoI013Sku(cCodProd,nIdSku)
Local aArea		:= GetArea()
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()

cQuery := "	SELECT " + CRLF
cQuery += "		IDSKU " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			B5.B5_XIDSKU IDSKU " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "		" + RetSqlName("SB5") + " B5 " + CRLF
cQuery += "		WHERE " + CRLF
cQuery += "			B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF 
cQuery += "			B5.B5_COD = '" + cCodProd + "' AND  " + CRLF
cQuery += "			B5.D_E_L_E_T_ = '' " + CRLF 
cQuery += "	)SKU "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

nIdSku := (cAlias)->IDSKU

(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/*******************************************************************/
/*/{Protheus.doc} RetPrcUni
	@description Formata valor para envio ao eCommerce
	@author Bernard M. Margarido
	@since 13/02/2017
	@version undefined
	@type function
/*/
/*******************************************************************/
Static Function RetPrcUni(nVlrUnit) 
Local nValor	:= 0
	nValor		:= NoRound(nVlrUnit,2) * 100
Return nValor

/*********************************************************************************/
/*/{Protheus.doc} LogExec
	@description Grava Log do processo 
	@author SYMM Consultoria
	@since 26/01/2017
	@version undefined
	@type function
/*/
/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.
