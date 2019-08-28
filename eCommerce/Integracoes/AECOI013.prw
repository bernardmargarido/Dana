#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

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

Private cThread	:= Alltrim(Str(ThreadId()))
Private cStaLog	:= "0"
Private cArqLog	:= ""	

Private nQtdInt	:= 0

Private cHrIni	:= Time()
Private dDtaInt	:= Date()

Private aMsgErro:= {}

Private lJob 	:= .F.

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
Processa({|| AECOINT13(cOrderId) },"Aguarde...","Enviando invoice.")

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

Return Nil

/**************************************************************************************************/

/*/{Protheus.doc} AECOINT13

@description	Realiza o envio da Invoice para o e-Commerce

@param cOrderId		, characters, OrderID eCommerce

@author			Bernard M.Margarido
@version   		1.00
@since     		02/02/2016
/*/

/**************************************************************************************************/
Static Function AECOINT13(cOrderId)
Local aArea		:= GetArea()
Local aRet		:= {.F.,"",""}

Local cChaveNfe := ""
Local cTracking := ""
Local cUrlTrack := ""
Local cNumTransp:= ""	
Local cRest		:= ""  
Local cQuant 	:= ""
Local cPrcVen	:= ""
Local cDtaFat	:= ""
Local cVlrFat	:= ""
Local cFilNf	:= ""
Local dDtaEmiss	:= ""
Local cFilAux	:= cFilAnt

Local nDecimal 	:= 2
Local nIdSku	:= 0

//---------------------+
// Posiciona Orçamento |
//---------------------+
dbSelectArea("SL1")
SL1->( dbOrderNickName("PEDIDOECO") )
SL1->( dbSeek(xFilial("SL1") + cOrderId) )

//----------------------------------+
// Consulta Data de Emissao da Nota |
//----------------------------------+
aEcoI13DtaE(xFilial("SF2"),SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_CLIENTE,SL1->L1_LOJA,@cChaveNfe,@dDtaEmiss)

cTracking 	:= Alltrim(SL1->L1_XTRACKI)
cNumTransp	:= SL1->L1_TRANSP
	
cRest += '	{ ' + CRLF
cRest += '  	"type": "Output", ' + CRLF
cRest += '  	"invoiceNumber": "' +  Alltrim(SL1->L1_DOC) + '", ' + CRLF
If !Empty(cChaveNfe)
	cRest += '  	"invoiceKey": "' + cChaveNfe + '", ' + CRLF
EndIf	
cRest += '		"courier": "' +  cNumTransp + '", ' + CRLF
cRest += '		"trackingNumber": "' + cTracking + '", ' + CRLF
cRest += '		"trackingUrl": "' +  cUrlTrack + '", ' + CRLF

cRest += '  	"items": [' + CRLF

//-------------------------+
// Posiciona Itens da Nota |
//-------------------------+
SL2->( dbSetOrder(1) )
SL2->( dbSeek(xFilial("SL2") + SL1->L1_NUM ) )
While SL2->( !Eof() .And. xFilial("SL2") + SL1->L1_NUM == SL2->( L2_FILIAL + L2_NUM ) )

	//------------------------------------------+
	// Posiciona Porduto para pegar codigo Vtex |
	//------------------------------------------+
	aEcoI013Sku(SL2->L2_PRODUTO,@nIdSku)
	
	cQuant := Alltrim(StrTran(Alltrim(Str(SL2->L2_QUANT)),".",""))
	cPrcVen:= RetPrcUni(SL2->L2_VLRITEM)
			
	cRest += '			{ ' + CRLF
	cRest += '  			"id": "' + Alltrim(Str(nIdSku)) + '", ' + CRLF
    cRest += '				"quantity ":' + cQuant + ' , ' + CRLF
    cRest += '				"price": ' + cPrcVen + '  ' + CRLF
	cRest += '			}, ' + CRLF
	
	SL2->( dbSkip() )   
	
EndDo

//-----------------------------+
// Data e Valor de Faturamento |
//-----------------------------+
cDtaFat := IIF(Empty(dDtaEmiss),dTos(dDataBase),dTos(dDtaEmiss))
cDtaFat := SubStr(cDtaFat,1,4) + "-" + SubStr(cDtaFat,5,2) + "-" + SubStr(cDtaFat,7,2) //+ "T" + SubStr(Time(),1,8)
cVlrFat	:= RetPrcUni(SL1->L1_VLRTOT)    

//------------------------+
// Data e Valor da Fatura |
//------------------------+
cRest += '  	], ' + CRLF
cRest += '  "issuanceDate": "' + cDtaFat +  '", ' + CRLF
cRest += '	"invoiceValue": ' + cVlrFat + ' ' + CRLF 
cRest += '	} ' + CRLF

//---------------+
// Envia Invoice |
//---------------+ 
aRet := AEcoI13Inv(SL1->L1_DOC,SL1->L1_SERIE,cOrderId,cRest)

RestArea(aArea)
Return .T.

/*/{Protheus.doc} aEcoI13DtaE
//TODO Descrição auto-gerada.
@author berna
@since 18/04/2017
@version undefined
@param cFilNf, characters, descricao
@param cDoc, characters, descricao
@param cSerie, characters, descricao
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@param cChaveNfe, characters, descricao
@param dDtaEmiss, date, descricao
@type function
/*/
Static Function aEcoI13DtaE(cFilNf,cDoc,cSerie,cCliente,cLoja,cChaveNfe,dDtaEmiss)
Local aArea		:= GetArea()
Local cFilaux	:= cFilAnt

If cFilNf == "10"
	cFilAnt := cFilNf
EndIf

dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If SF2->( dbSeek(xFilial("SF2") + Padr(SL1->L1_DOC,TamSx3("F2_DOC")[1]) + Padr(SL1->L1_SERIE,TamSx3("F2_SERIE")[1]) + PadR(SL1->L1_CLIENTE,TamSx3("F2_CLIENTE")[1]) + PadR(SL1->L1_LOJA,TamSx3("F2_LOJA")[1])) )
	cChaveNfe := SF2->F2_CHVNFE
	dDtaEmiss := SF2->F2_EMISSAO
EndIf	 
If cFilNf == "10"
	cFilAnt := cFilAux
EndIf	
RestArea(aArea)
Return .T.

/********************************************************************/
/*/{Protheus.doc} AEcoI13Inv

@description Rotina realiza o envio da Invoice para o e-Commerce

@author Bernard M. Margarido
@since 14/02/2017
@version undefined

@param cDocNum	, characters, Numero do Documento
@param cSerie	, characters, Serie Documento
@param cOrderId	, characters, Numero pedido e-Commerce 
@param cRest	, characters, String API REST

@type function
/*/
/********************************************************************/
Static Function AEcoI13Inv(cDocNum,cSerie,cOrderId,cRest)
Local aRet			:= {.T.,"",""}
Local cUrl			:= GetNewPar("EC_URLREST")
Local cAppKey		:= GetNewPar("EC_APPKEY")
Local cAppToken		:= GetNewPar("EC_APPTOKE")

Local nTimeOut		:= 240

Local aHeadOut  	:= {}
Local cXmlHead 	 	:= ""     
Local cError    	:= ""
Local cWarning  	:= ""
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

/*/{Protheus.doc} aEcoI013Sku

@description Consulta SKU

@author berna
@since 23/01/2018
@version 1.0

@param nIdSku, numeric, descricao
@type function
/*/
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
cQuery += "	UNION ALL " + CRLF
cQuery += "		SELECT " + CRLF 
cQuery += "			WS6.WS6_IDSKU IDSKU " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "		" + RetSqlName("WS6") + " WS6 " + CRLF
cQuery += "		WHERE " + CRLF
cQuery += "			WS6.WS6_FILIAL = '" + xFilial("WS6") + "' AND " + CRLF 
cQuery += "			WS6.WS6_CODSKU = '" + cCodProd + "' AND " + CRLF 
cQuery += "			WS6.D_E_L_E_T_ = '' " + CRLF 
cQuery += "		)SKU "

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

@param nVlrUnit, numeric, descricao

@type function
/*/
/*******************************************************************/
Static Function RetPrcUni(nVlrUnit) 
Local nDecimal	:= 2
Local cValor	:= ""
Local cVlrUnit	:= Alltrim(Str(nVlrUnit))
Local aValor	:= {}

If At(".",cVlrUnit) > 0
	aValor := Separa(cVlrUnit,".")
	cValor := aValor[1] + PadR(aValor[2],nDecimal,"0")
Else
	cValor := cVlrUnit + "00"
EndIf

Return cValor

/*********************************************************************************/
/*/{Protheus.doc} LogExec

@description Grava Log do processo 

@author SYMM Consultoria
@since 26/01/2017
@version undefined

@param cMsg, characters, descricao

@type function
/*/

/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.