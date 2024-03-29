#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "009"
Static cDescInt	:= "ALTERAPRECO"
Static cDirImp	:= "/ecommerce/"

/**************************************************************************************************/
/*/{Protheus.doc} AECOI009
	@description	Rotina realiza manuten��o de pre�os dos produtos no e-Commerce
	@type   		Function 
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
User Function AECOI009()
Local _nX			:= 0 
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
// Grava Log inicio das Integra��es | 
//----------------------------------+
u_AEcoGrvLog(cCodInt,cDescInt,dDtaInt,cHrIni,,,,,cThread,1)

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirImp)
cArqLog := cDirImp + "ALTERAPRECO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO DA ALTERACAO DE PRECO COM O ECOMMERCE - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())

//----------------------------------+
// Inicia processo de envio Estoque |
//----------------------------------+
If _lMultLj
	If _lJob
		AECOMULT09()
	Else 
		_oProcess:= MsNewProcess():New( {|| AECOMULT09()},"Aguarde...","Consultando Precos" )
		_oProcess:Activate()
	EndIf 
Else 
	//---------------------------------+
	// Inicia processo de envio Pre�os |
	//---------------------------------+
	If _lJob
		AECOINT09()
	Else 
		Processa({|| AECOINT09() },"Aguarde...","Consultando Precos.")
	EndIf 
EndIf 

LogExec("FINALIZA INTEGRACAO DA ALTERACAO DE PRECO COM O ECOMMERCE - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
LogExec(Replicate("-",80))
ConOut("")

If Len(_aRecno) > 0 
	dbSelectArea("DA1")
	DA1->( dbSetOrder(1) )
	For _nX := 1 to Len(_aRecno)
		DA1->( dbGoTo(_aRecno[_nX]))
		RecLock("DA1",.F.)
			DA1->DA1_ENVECO	:= "2" 
			DA1->DA1_XDTEXP	:= dTos( Date() )
			DA1->DA1_XHREXP	:= Time()	
		DA1->( MsUnLock() )
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
// Grava Log inicio das Integra��es |
//----------------------------------+
u_AEcoGrvLog(cCodInt,cDescInt,dDtaInt,cHrIni,Time(),cStaLog,nQtdInt,aMsgErro,cThread,2)

Return Nil

/*****************************************************************************************/
/*/{Protheus.doc} AECOMULT09
	@description Multi Lojas e-Commerce
	@author Bernard M. Margarido
	@since 17/05/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************************/
Static Function AECOMULT09()
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
		AECOINT09M(XTC->XTC_CODIGO,XTC->XTC_URL,XTC->XTC_URL3,XTC->XTC_APPKEY,XTC->XTC_APPTOK)

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
/*/{Protheus.doc} AECOINT09
	@description	Rotina consulta e envia manuten��o de pre�os dos produtos no e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT09M(_cLojaID,_cUrl,_cUrl_3,_cAppKey,_cAppToken)
Local aArea		:= GetArea()

Local cCodSku	:= ""
Local cDescPrd	:= "" 
Local cDtaDe	:= ""
Local cDtaAte	:= ""
Local cAlias	:= GetNextAlias()

Local nIdSku 	:= 0
Local nIdPrc	:= 0
Local nPrcCheio	:= 0
Local nPrcPor	:= 0	
Local nIdLoja	:= 0
Local nToReg	:= 0

Local oJson		:= Nil
Local oPrice	:= Nil

//-------------------------------------------+
// Valida se existem pre�os a serem enviadas |
//-------------------------------------------+
If !AEcoQry(cAlias,@nToReg,_cLojaID)
	LogExec("009 - NAO EXISTEM REGISTROS PARA SEREM ENVIADOS.")  
	RestArea(aArea)
	Return .T.
EndIf

//-----------------------+
// Inicia o envio Pre�os |
//-----------------------+
If !_lJob
	_oProcess:SetRegua2( nToReg )
EndIf

While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	If !_lJob
		_oProcess:IncRegua2("Produto " + RTrim((cAlias)->CODSKU) + " - " + RTrim((cAlias)->DESCSKU) )	
	EndIf 

	//--------------------------------+
	// Dados Pre�os Produto Pai / Sku |
	//--------------------------------+
	nIdSku 		:= (cAlias)->IDSKU
	nIdPrc		:= (cAlias)->RECNODA1
	nPrcCheio	:= IIF((cAlias)->PRCDE > 0 .And. (cAlias)->PRCDE >= (cAlias)->PRCPOR, (cAlias)->PRCDE, (cAlias)->PRCPOR )
	nPrcPor		:= (cAlias)->PRCPOR	
	nIdLoja		:= (cAlias)->IDLOJA
	cCodSku		:= (cAlias)->CODSKU
	cDescPrd	:= (cAlias)->DESCSKU 
	cIdTabela	:= '1' //(cAlias)->IDTABELA 
	cDtaDe		:= FWTimeStamp(3,Date())
	cDtaAte		:= FWTimeStamp(3,YearSum(Date(),10))
			
	//-----------------------+
	// Monta String API Rest |
	//-----------------------+
	oJson					:= {}        
	//oJson					:= Array(#)
	aAdd(oJson,Array(#))
	oPrice					:= aTail(oJson)  
	oPrice[#"listPrice"]	:= nPrcCheio
	oPrice[#"value"]		:= nPrcPor
	oPrice[#"minQuantity"]	:= 1
	
	/*
	oJson[#"listPrice"]		:= nPrcCheio
	oJson[#"costPrice"]		:= nPrcCheio
	oJson[#"markup"]		:= 0      
	
	oJson[#"fixedPrices"]	:= {}
	aAdd(oJson[#"fixedPrices"],Array(#))
	oPrice					:= aTail(oJson[#"fixedPrices"])    
	oPrice[#"tradePolicyId"]:= IIF(Empty(cIdTabela),"1",RTrim(cIdTabela))
	oPrice[#"value"]		:= nPrcPor
	oPrice[#"listPrice"]	:= nPrcCheio
	oPrice[#"minQuantity"]	:= 1
	*/

	LogExec("ENVIANDO PRECO PRODUTO " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->DESCSKU) )
				 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(oJson,nIdSku,cCodSku,cDescPrd,(cAlias)->RECNODA1,_cLojaID,_cUrl_3,_cAppKey,_cAppToken,cIdTabela)
				
	(cAlias)->( dbSkip() )
				
EndDo
	
//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT09
	@description	Rotina consulta e envia manuten��o de pre�os dos produtos no e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT09()
Local aArea		:= GetArea()

Local cCodSku	:= ""
Local cDescPrd	:= "" 
Local cDtaDe	:= ""
Local cDtaAte	:= ""
Local cIdTabela	:= ""
Local cAlias	:= GetNextAlias()

Local nIdSku 	:= 0
Local nIdPrc	:= 0
Local nPrcCheio	:= 0
Local nPrcPor	:= 0	
Local nIdLoja	:= 0
Local nToReg	:= 0

Local oJson		:= Nil
Local oPrice	:= Nil

//-------------------------------------------+
// Valida se existem pre�os a serem enviadas |
//-------------------------------------------+
If !AEcoQry(cAlias,@nToReg)
	aAdd(aMsgErro,{"009","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//-----------------------+
// Inicia o envio Pre�os |
//-----------------------+
If !_lJob
	ProcRegua(nToReg)
EndIf 

While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	If !_lJob
		IncProc("Produto" + Alltrim((cAlias)->CODSKU)  + " - " + Alltrim((cAlias)->DESCSKU) )
	EndIf 
		
	//--------------------------------+
	// Dados Pre�os Produto Pai / Sku |
	//--------------------------------+
	nIdSku 		:= (cAlias)->IDSKU
	nIdPrc		:= (cAlias)->RECNODA1
	nPrcCheio	:= IIF((cAlias)->PRCDE > 0 .And. (cAlias)->PRCDE >= (cAlias)->PRCPOR, (cAlias)->PRCDE, (cAlias)->PRCPOR )
	nPrcPor		:= (cAlias)->PRCPOR	
	nIdLoja		:= (cAlias)->IDLOJA
	cCodSku		:= (cAlias)->CODSKU
	cDescPrd	:= (cAlias)->DESCSKU 
	cIdTabela	:= (cAlias)->IDTABELA 
	cDtaDe		:= FWTimeStamp(3,Date())
	cDtaAte		:= FWTimeStamp(3,YearSum(Date(),10))
			
	//-----------------------+
	// Monta String API Rest |
	//-----------------------+
	oJson					:= {}        
	//oJson					:= Array(#)
	aAdd(oJson,Array(#))
	oPrice					:= aTail(oJson)  
	oPrice[#"listPrice"]	:= nPrcCheio
	oPrice[#"value"]		:= nPrcPor
	oPrice[#"minQuantity"]	:= 1

	/*
	oJson					:= {}        
	oJson					:= Array(#)
	oJson[#"listPrice"]		:= nPrcCheio
	oJson[#"costPrice"]		:= nPrcCheio
	oJson[#"markup"]		:= 0      
	
	oJson[#"fixedPrices"]	:= {}
	aAdd(oJson[#"fixedPrices"],Array(#))
	oPrice					:= aTail(oJson[#"fixedPrices"])    
	oPrice[#"tradePolicyId"]:= IIF(Empty(cIdTabela),"1",cIdTabela)
	oPrice[#"value"]		:= nPrcPor
	oPrice[#"listPrice"]	:= nPrcCheio
	oPrice[#"minQuantity"]	:= 1
	*/
	LogExec("ENVIANDO PRECO PRODUTO " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->DESCSKU) )
				 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(oJson,nIdSku,cCodSku,cDescPrd,(cAlias)->RECNODA1,Nil,Nil,Nil,Nil,_cIdTabela)
				
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
	@description	Rotina envia manutan��o de pre�os dos produtos para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/							
/**************************************************************************************************/
Static Function AEcoEnv(oJson,nIdSku,cCodSku,cDescPrd,nRecnoDa1,_cLojaID,_cUrl,_cAppKey,_cAppToken,_cIdTabela)
Local aArea			:= GetArea()
Local aHeadOut  	:= {}

Local cUrl			:= ""
Local cAppKey		:= ""
Local cAppToken		:= ""
Local cRest			:= ""

Local nTimeOut		:= 240

Local _oRest		:= Nil

Default _cLojaID	:= ""
Default _cUrl		:= ""
Default _cAppKey	:= ""
Default _cAppToken	:= ""
Default _cIdTabela	:= ""

cUrl				:= RTrim(IIF(Empty(_cUrl), GetNewPar("EC_URLRES2"), _cUrl) )
cAppKey				:= RTrim(IIF(Empty(_cAppKey), GetNewPar("EC_APPKEY"), _cAppKey))
cAppToken			:= RTrim(IIF(Empty(_cAppToken), GetNewPar("EC_APPTOKE"), _cAppToken) )

//---------------------------+
// Transforma Objeto em JSON |
//---------------------------+
cRest := xToJson(oJson)

aAdd(aHeadOut,"Content-Type: application/json" )
aAdd(aHeadOut,"X-VTEX-API-AppKey:" + cAppKey )
aAdd(aHeadOut,"X-VTEX-API-AppToken:" + cAppToken ) 

//-----------------------+
// Instancia Classe Rest |
//-----------------------+
_oRest := FWRest():New(cUrl)

//---------------------+
// TimeOut do processo |
//---------------------+
_oRest:nTimeOut := nTimeOut

//----------------------+
// Metodo a ser enviado | 
//----------------------+
If Empty(_cIdTabela)
	_oRest:SetPath("/pricing/prices/"+ RTrim(CValToChar(nIdSku)))
	//--------------------+
	// Utiliza metodo PUT |
	//--------------------+
	If _oRest:Put(aHeadOut,cRest)
		aAdd(_aRecno,nRecnoDa1)		
		LogExec("PRECO(S) ENVIADO COM SUCESSO. " )
	Else
		//---------------------------------------+
		// Cria array com os erros de integracao |
		//---------------------------------------+
		aAdd(aMsgErro,{cCodSku,"ERRO AO ENVIAR A PRECO "  + _oRest:GetLastError()})
		LogExec("ERRO AO ENVIAR A PRECO " + _oRest:GetLastError() )	
	EndIf 
Else 
	_oRest:SetPath("/pricing/prices/" + RTrim(CValToChar(nIdSku)) + "/fixed/" + RTrim(_cIdTabela) )

	_oRest:SetPostParams(cRest)

	//--------------------+
	// Utiliza metodo PUT |
	//--------------------+
	If _oRest:Post(aHeadOut)

		//--------------------+
		// Posiciona Registro |
		//--------------------+
		aAdd(_aRecno,nRecnoDa1)
		LogExec("PRECO(S) ENVIADO COM SUCESSO. " )
		
	Else
		
		//---------------------------------------+
		// Cria array com os erros de integracao |
		//---------------------------------------+
		aAdd(aMsgErro,{cCodSku,"ERRO AO ENVIAR A PRECO "  + _oRest:GetLastError()})
		LogExec("ERRO AO ENVIAR A PRECO " + _oRest:GetLastError() )	
		
	EndIf 
EndIf  

RestArea(aArea)
Return .T.

/*******************************************************************************************/
/*/{Protheus.doc} DateTime
	@description Converte Data e Hora utilizado no VTex
	@author Bernard M. Margarido
	@since 26/01/2017
	@version undefined
	@type function
/*/
/*******************************************************************************************/
Static Function DateTime(nField,cDta,cHora)
Local cDtaTime	:= ""
Local nAno		:= 0
Default cDta 	:= dDataBase
Default cHora	:= Time()
Default nField	:= 1

If nField == 1
	cDtaTime := SubSTr(cDta,7,2) + "-" + SubSTr(cDta,5,2) +"-" + SubSTr(cDta,1,4) + "T" + cHora
Else
	nAno	 := Year(StoD(cDta)) + 20 
	cDtaTime := SubSTr(cDta,7,2) + "-" + SubSTr(cDta,5,2) +"-" + Alltrim(Str(nAno)) + "T" + cHora
EndIf	

Return cDtaTime

/**************************************************************************************************/
/*/{Protheus.doc} AECOQRY
	@description 	Rotina consulta pre�os dos produtos a serem enviados para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/			
/**************************************************************************************************/
Static Function AEcoQry(cAlias,nToReg,_cLojaID)
Local cQuery 	:= ""
Local cCodTab	:= GetNewPar("EC_TABECO") 

Default _cLojaID:= ""

//---------------------------+
// Query consulta pre�os sku |
//---------------------------+	
cQuery := "	SELECT " + CRLF
cQuery += "		CODSKU , " + CRLF 
cQuery += "		IDSKU , " + CRLF  
cQuery += "		DESCSKU, " + CRLF 
cQuery += "		PRCDE , " + CRLF 
cQuery += "		IDLOJA, " + CRLF 
//cQuery += "		IDTABELA, " + CRLF 
cQuery += "		DATADE, " + CRLF
cQuery += "		HORADE, " + CRLF
cQuery += "		PRCPOR, " + CRLF 
cQuery += "		CODTABELA, " + CRLF 
cQuery += "		ITEM, " + CRLF 
cQuery += "		RECNODA1 " + CRLF 
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			B5.B5_COD CODSKU , " + CRLF 

If Empty(_cLojaID)
	cQuery += "			B5.B5_XIDSKU IDSKU, " + CRLF
Else
	cQuery += "			XTD.XTD_IDECOM IDSKU, " + CRLF
EndIf 

cQuery += "			B1.B1_DESC DESCSKU, " + CRLF
cQuery += "			B1.B1_PRV1 PRCDE , " + CRLF 
cQuery += "			B5.B5_XIDLOJA IDLOJA, " + CRLF 
//cQuery += "			DA0.DA0_XIDVET IDTABELA, " + CRLF
cQuery += "			DA0.DA0_DATDE DATADE, " + CRLF
cQuery += "			DA0.DA0_HORADE HORADE, " + CRLF
cQuery += "			DA1.DA1_PRCVEN PRCPOR, " + CRLF 
cQuery += "			DA1.DA1_CODTAB CODTABELA, " + CRLF 
cQuery += "			DA1.DA1_ITEM ITEM , " + CRLF 
cQuery += "			DA1.R_E_C_N_O_ RECNODA1 " + CRLF 
cQuery += "		FROM " + CRLF 
cQuery += "			" + RetSqlName("DA1") + " DA1 " + CRLF 
//cQuery += "			INNER JOIN " + RetSqlName("DA0") + " DA0 ON DA0.DA0_FILIAL = '" + xFilial("DA0") + "' AND DA0.DA0_CODTAB = DA1.DA1_CODTAB AND DA0.DA0_XSTATU = '1' AND DA0.D_E_L_E_T_ = '' " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("DA0") + " DA0 ON DA0.DA0_FILIAL = '" + xFilial("DA0") + "' AND DA0.DA0_CODTAB = DA1.DA1_CODTAB AND DA0.D_E_L_E_T_ = '' " + CRLF 

If Empty(_cLojaID)
	cQuery += "			INNER JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = DA1.DA1_CODPRO AND B5.B5_XENVECO = '2' AND B5.B5_XENVSKU = '2' AND B5.B5_XUSAECO = 'S' AND B5.D_E_L_E_T_ = '' " + CRLF 
Else 
	cQuery += "			INNER JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = DA1.DA1_CODPRO AND B5.B5_XENVECO = '2' AND B5.B5_XENVSKU = '2' AND B5.B5_XUSAECO = 'S' AND B5.B5_XIDLOJA LIKE '%" + _cLojaID + "%' AND B5.D_E_L_E_T_ = '' " + CRLF
	cQuery += "			INNER JOIN " + RetSqlName("XTD") + " XTD ON XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'SB1' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = DA1.DA1_CODPRO AND XTD.D_E_L_E_T_ = '' " + CRLF
EndIf 

cQuery += "			INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = DA1.DA1_CODPRO AND B1.B1_MSBLQL <> '1' AND B1.D_E_L_E_T_ = '' " + CRLF 
cQuery += "		WHERE " + CRLF 
cQuery += "			DA1.DA1_FILIAL = '" + xFilial("DA1") + "' AND " + CRLF 
If Empty(_cLojaID)
	cQuery += "			DA1.DA1_CODTAB = '" + cCodTab + "' AND " + CRLF
EndIf 
cQuery += "			DA1.DA1_ENVECO = '1' AND " + CRLF  
cQuery += "			DA1.D_E_L_E_T_ = '' " + CRLF 
cQuery += "	) PRECO " + CRLF
cQuery += "	ORDER BY CODSKU "
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
count To nToReg  

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
	@version undefined
	@type function
/*/
/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.
