#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "008"
Static cDescInt	:= "ESTOQUE"
Static cDirImp	:= "/ecommerce/"

/**************************************************************************************************/
/*/{Protheus.doc} AECOI008
	@description	Rotina realiza a integração dos estoques e-commerce
	@type   		Function 
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
User Function AECOI008()
Local _nX 			:= 0 

Private cThread		:= Alltrim(Str(ThreadId()))
Private cStaLog		:= "0"
Private cArqLog		:= ""	

Private nQtdInt		:= 0

Private cHrIni		:= Time()
Private dDtaInt		:= Date()

Private _aRecno 	:= {}
Private aMsgErro	:= {}

Private _lJob		:= IIF(Isincallstack("U_ECLOJM03"),.T.,.F.)
Private _lMultLj	:= GetNewPar("EC_MULTLOJ",.T.)

Private _oProcess 	:= Nil

//----------------------------------+
// Grava Log inicio das Integrações | 
//----------------------------------+
u_AEcoGrvLog(cCodInt,cDescInt,dDtaInt,cHrIni,,,,,cThread,1)

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirImp)
cArqLog := cDirImp + "ESTOQUE" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO DE ESTOQUE COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())

//----------------------------------+
// Inicia processo de envio Estoque |
//----------------------------------+
If _lMultLj
	If _lJob
		AECOMULT08()
	Else 
		_oProcess:= MsNewProcess():New( {|| AECOMULT08()},"Aguarde...","Consultando Estoque." )
		_oProcess:Activate()
	EndIf 
Else 
	If _lJob
		AECOINT08()
	Else
		Processa({|| AECOINT08() },"Aguarde...","Consultando Estoque.")
	EndIf
EndIf 

LogExec("FINALIZA INTEGRACAO DE ESTOQUE COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
LogExec(Replicate("-",80))
ConOut("")

If Len(_aRecno) > 0 
	dbSelectArea("SB2")
	SB2->( dbSetOrder(1) )
	For _nX := 1 To Len(_aRecno)
		SB2->( dbGoTo(_aRecno[_nX]))
		RecLock("SB2",.F.)
			SB2->B2_MSEXP := dTos(Date())
		SB2->( MsUnLock() )	
	Next _nX 
EndIf 

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

/*****************************************************************************************/
/*/{Protheus.doc} AECOMULT08
	@description Multi Lojas e-Commerce
	@author Bernard M. Margarido
	@since 17/05/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************************/
Static Function AECOMULT08()
Local _aArea		:= GetArea()

Local _cFilAux 		:= cFilAnt 

//-----------------+
// Lojas eCommerce |
//-----------------+
dbSelectArea("XTC")
XTC->( dbSetOrder(1) ) 
XTC->( dbGoTop() )

If !_lJob
	_oProcess:SetRegua1( XTC->( RecCount()))
	LogExec(" TOTAL REGISTRO " + cValToChar( XTC->( RecCount()) ))
EndIf 

While XTC->( !Eof() )

	If !_lJob	
		_oProcess:IncRegua1("Loja eCommerce " + RTrim(XTC->XTC_DESC) )
	EndIf 

	LogExec("Loja eCommerce " + RTrim(XTC->XTC_DESC))

	//----------------------+
	// Somente lojas ativas |
	//----------------------+
	If XTC->XTC_STATUS == "1"

		//----------------------------+
		// Posiciona a filial correta | 
		//----------------------------+
		If XTC->XTC_FILIAL <> cFilAnt 
			cFilAnt := XTC->XTC_FILIAL
		EndIf  

		//--------------------------------+
		// Envia as categorias multi loja |
		//--------------------------------+
		AECOINT08M(XTC->XTC_CODIGO,XTC->XTC_URL,XTC->XTC_URL2,XTC->XTC_APPKEY,XTC->XTC_APPTOK)

		//----------------------------+
		// Restaura a filial corrente |
		//----------------------------+
		If _cFilAux <> cFilAnt
			cFilAnt := _cFilAux
		EndIf 

	EndIf
	
	XTC->( dbSkip() )
	
EndDo

RestArea(_aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT08M
	@description	Rotina consulta e envia estoque dos produtos para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT08M(_cLojaID,_cUrl,_cUrl_2,_cAppKey,_cAppToken)
Local aArea		:= GetArea()

Local cCodSku	:= ""
Local cDescSku	:= ""
Local cAlias	:= GetNextAlias()

Local nToReg	:= 0
Local nIdSku	:= 0

Local oJson		:= Nil
Local oEstoque	:= Nil

//---------------------------------------------+
// Valida se existem Estoques a serem enviadas |
//---------------------------------------------+
If !AEcoQry(cAlias,@nToReg,_cLojaID)
	//aAdd(aMsgErro,{"008","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	LogExec("NAO EXISTEM REGISTROS PARA SEREM ENVIADOS.")  
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------+
// Inicia o envio Estoques |
//-------------------------+
If !_lJob
	_oProcess:SetRegua2( nToReg )
EndIf

While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	If !_lJob
		_oProcess:IncRegua2("Sku " + RTrim((cAlias)->CODSKU) + " - " + RTrim((cAlias)->DESCSKU) )
	Endif	

	LogExec("ESTOQUE " + RTrim((cAlias)->CODSKU)  + " - " + RTrim((cAlias)->DESCSKU) )

	//--------------------+
	// Posiciona registro |
	//--------------------+
	SB2->( dbGoTo((cAlias)->RECNOSB2) )
		
	//--------------------------+
	// Dados Filtros X Produtos |
	//--------------------------+
	cCodSku	:= (cAlias)->CODSKU
	cDescSku:= (cAlias)->DESCSKU
	nIdSku	:= (cAlias)->IDSKU
		
	//------------------+
	// Saldo em Estoque |
	//------------------+
	nSaldoB2 := SaldoSb2()
	
	//-----------------+
	// Cria Array JSON |
	//-----------------+
	oJson								:= {}
	aAdd(oJson,Array(#))
	oEstoque							:= aTail(oJson)
	oEstoque[#"wareHouseId"]			:= "1_1"
	oEstoque[#"itemId"]					:= Alltrim(Str(nIdSku))
	oEstoque[#"unlimitedQuantity"]		:= .F.
	oEstoque[#"quantity"]				:= nSaldoB2
	oEstoque[#"dateUtcOnBalanceSystem"]	:= Nil
		
	LogExec("ENVIANDO ESTOQUE " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->DESCSKU) + " IDSKU " + Alltrim(Str(nIdSku)) + " SALDO " + Alltrim(Str(nSaldoB2)) )
					 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(oJson,nIdSku,(cAlias)->RECNOSB2,_cLojaID,_cUrl_2,_cAppKey,_cAppToken)
					
	(cAlias)->( dbSkip() )
	
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT08
	@description	Rotina consulta e envia estoque dos produtos para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT08()
Local aArea		:= GetArea()

Local cCodSku	:= ""
Local cDescSku	:= ""
Local cAlias	:= GetNextAlias()

Local nToReg	:= 0
Local nIdSku	:= 0

Local oJson		:= Nil
Local oEstoque	:= Nil

//---------------------------------------------+
// Valida se existem Estoques a serem enviadas |
//---------------------------------------------+
If !AEcoQry(cAlias,@nToReg)
	//aAdd(aMsgErro,{"008","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	LogExec("NAO EXISTEM REGISTROS PARA SEREM ENVIADOS.")  
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------+
// Inicia o envio Estoques |
//-------------------------+
If !_lJob
	ProcRegua(nToReg)
EndIf

While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	If !_lJob
		IncProc("Estoque " + Alltrim((cAlias)->CODSKU)  + " - " + Alltrim((cAlias)->DESCSKU) )
	Endif	

	LogExec("ESTOQUE " + Alltrim((cAlias)->CODSKU)  + " - " + Alltrim((cAlias)->DESCSKU) )

	//--------------------+
	// Posiciona registro |
	//--------------------+
	SB2->( dbGoTo((cAlias)->RECNOSB2) )
		
	//--------------------------+
	// Dados Filtros X Produtos |
	//--------------------------+
	cCodSku	:= (cAlias)->CODSKU
	cDescSku:= (cAlias)->DESCSKU
	nIdSku	:= (cAlias)->IDSKU
		
	//------------------+
	// Saldo em Estoque |
	//------------------+
	nSaldoB2 := SaldoSb2()
	
	//-----------------+
	// Cria Array JSON |
	//-----------------+
	oJson								:= {}
	aAdd(oJson,Array(#))
	oEstoque							:= aTail(oJson)
	oEstoque[#"wareHouseId"]			:= "1_1"
	oEstoque[#"itemId"]					:= Alltrim(Str(nIdSku))
	oEstoque[#"unlimitedQuantity"]		:= .F.
	oEstoque[#"quantity"]				:= nSaldoB2
	oEstoque[#"dateUtcOnBalanceSystem"]	:= Nil
		
	LogExec("ENVIANDO ESTOQUE " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->DESCSKU) + " IDSKU " + Alltrim(Str(nIdSku)) + " SALDO " + Alltrim(Str(nSaldoB2)) )
					 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(oJson,nIdSku,(cAlias)->RECNOSB2)
					
	(cAlias)->( dbSkip() )
	
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOENV
	@description	Rotina envia o estoque dos produtos para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
/*/							
/**************************************************************************************************/

Static Function AEcoEnv(oJson,nIdSku,nRecnoSb2,_cLojaID,_cUrl,_cAppKey,_cAppToken)
Local aArea			:= GetArea()
Local aHeadOut  	:= {}

Local cUrl			:= ""
Local cAppKey		:= ""
Local cAppToken		:= ""

Local cRest			:= ""

Local oRestClient	:= Nil

Default _cLojaID	:= ""
Default _cUrl		:= ""
Default _cAppKey	:= ""
Default _cAppToken	:= ""

cUrl				:= RTrim(IIF(Empty(_cUrl), GetNewPar("EC_URLREST"), _cUrl))
cAppKey				:= RTrim(IIF(Empty(_cAppKey), GetNewPar("EC_APPKEY"), _cAppKey))
cAppToken			:= RTrim(IIF(Empty(_cAppToken), GetNewPar("EC_APPTOKE"), _cAppToken))

aAdd(aHeadOut,"Content-Type: application/json" )
aAdd(aHeadOut,"X-VTEX-API-AppKey:" + cAppKey )
aAdd(aHeadOut,"X-VTEX-API-AppToken:" + cAppToken ) 

//--------------------+
// Posiciona registro |
//--------------------+
//SB2->( dbGoTo(nRecnoSb2) )

//---------------------------+
// Transforma Objeto em JSON |
//---------------------------+
cRest := xToJson(oJson)

//-----------------------+
// Instancia Classe Rest |
//-----------------------+
oRestClient := FWRest():New(cUrl)

//---------------------+
// TimeOut do processo |
//---------------------+
oRestClient:nTimeOut := 600

//----------------------+
// Metodo a ser enviado | 
//----------------------+
oRestClient:SetPath("/api/logistics/pvt/inventory/balance")

//---------------------+
// Parametros de Envio |
//---------------------+
oRestClient:SetPostParams(cRest)
 
 //--------------------+
 // Utiliza metodo PUT |
 //--------------------+
If oRestClient:Post(aHeadOut)
	aAdd(_aRecno,nRecnoSb2)
	LogExec("ESTOQUE ENVIADO COM SUCESSO. ")
Else
	aAdd(aMsgErro,{SB2->B2_COD,"ERRO AO ENVIAR PRODUTO " + oRestClient:GetLastError()})
	LogExec("ERRO AO ENVIAR PRODUTO " + Alltrim(SB2->B2_COD))
Endif

RestArea(aArea)
Return .T.

/**********************************************************************************************/
/*/{Protheus.doc} AECOQRY
	@description 	Rotina consulta os estoques a serem enviados para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/			
/************************************************************************************************/
Static Function AEcoQry(cAlias,nToReg,_cLojaID)

Local cQuery 	:= ""
Local cFilEst	:= GetNewPar("EC_FILEST")
Local cLocal	:= FormatIn(GetNewPar("EC_ARMAZEM"),"/")

Default _cLojaID:= ""

//------------------------+
// Query consulta Estoques|
//------------------------+
cQuery := "	SELECT " + CRLF  
cQuery += "		CODSKU, " + CRLF
cQuery += "		DESCSKU, " + CRLF
cQuery += "		IDSKU, " + CRLF
cQuery += "		SALDOB2, " + CRLF
cQuery += "		RECNOSB2 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			B2.B2_COD CODSKU, " + CRLF
cQuery += "			B1.B1_DESC DESCSKU, " + CRLF

If Empty(_cLojaID)
	cQuery += "			B5.B5_XIDSKU IDSKU, " + CRLF
Else
	cQuery += "			XTD.XTD_IDECOM IDSKU, " + CRLF
EndIf 

cQuery += "			B2.B2_QATU SALDOB2, " + CRLF
cQuery += "			B2.R_E_C_N_O_ RECNOSB2 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SB2") + " B2 " + CRLF
cQuery += "			INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = B2.B2_COD AND B1.B1_MSBLQL <> '1' AND B1.D_E_L_E_T_ = '' " + CRLF 

If Empty(_cLojaID)
	cQuery += "			INNER JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = B2.B2_COD AND B5.B5_XENVECO = '2' AND B5.B5_XENVSKU = '2' AND B5.B5_XUSAECO = 'S' AND B5.D_E_L_E_T_ = '' " + CRLF
ElseIf !Empty(_cLojaID)
	cQuery += "			INNER JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = B2.B2_COD AND B5.B5_XENVECO = '2' AND B5.B5_XENVSKU = '2' AND B5.B5_XUSAECO = 'S' AND B5.B5_XIDLOJA LIKE '%" + _cLojaID + "%' AND B5.D_E_L_E_T_ = '' " + CRLF
	cQuery += "			INNER JOIN " + RetSqlName("XTD") + " XTD ON XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'SB1' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = B2.B2_COD AND XTD.D_E_L_E_T_ = '' " + CRLF
EndIf 

cQuery += "		WHERE " + CRLF
cQuery += "			B2.B2_FILIAL = '" + cFilEst  + "' AND " + CRLF 
cQuery += "			B2.B2_LOCAL IN " + cLocal + " AND " + CRLF
cQuery += "			B2.B2_MSEXP = '' AND " + CRLF
cQuery += "			B2.D_E_L_E_T_ = '' " + CRLF
cQuery += "	) ESTOQUE " + CRLF
cQuery += "	ORDER BY CODSKU " 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
Count To nToReg  

//------------------------------+
// Quantidade de Itens enviados |
//------------------------------+
nQtdInt := nToReg

dbSelectArea(cAlias)
(cAlias)->( dbGoTop() )

If (cAlias)->( Eof() )
	(cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.

/*********************************************************************************/
/*/{Protheus.doc} LogExec
	@description Grava Log do processo 
	@author SYMM Consultoria
	@since 26/01/2017
	@type function
/*/
/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.
