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

@description	Rotina realiza manutenção de preços dos produtos no e-Commerce

@type   		Function 
@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016
/*/
/**************************************************************************************************/
User Function AECOI009()

Private cThread	:= Alltrim(Str(ThreadId()))
Private cStaLog	:= "0"
Private cArqLog	:= ""	

Private nQtdInt	:= 0

Private cHrIni	:= Time()
Private dDtaInt	:= Date()

Private aMsgErro:= {}

//----------------------------------+
// Grava Log inicio das Integrações | 
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

//---------------------------------+
// Inicia processo de envio Preços |
//---------------------------------+
Processa({|| AECOINT09() },"Aguarde...","Consultando Precos.")

LogExec("FINALIZA INTEGRACAO DA ALTERACAO DE PRECO COM O ECOMMERCE - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
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

/*/{Protheus.doc} AECOINT09

@description	Rotina consulta e envia manutenção de preços dos produtos no e-commerce

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
// Valida se existem preços a serem enviadas |
//-------------------------------------------+
If !AEcoQry(cAlias,@nToReg)
	aAdd(aMsgErro,{"009","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//-----------------------+
// Inicia o envio Preços |
//-----------------------+
ProcRegua(nToReg)
While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	IncProc("Produto" + Alltrim((cAlias)->CODSKU)  + " - " + Alltrim((cAlias)->DESCSKU) )
		
	//--------------------------------+
	// Dados Preços Produto Pai / Sku |
	//--------------------------------+
	nIdSku 		:= (cAlias)->IDSKU
	nIdPrc		:= (cAlias)->RECNODA1
	nPrcCheio	:= IIF((cAlias)->PRCDE > 0 .And. (cAlias)->PRCDE >= (cAlias)->PRCPOR, (cAlias)->PRCDE, (cAlias)->PRCPOR )
	nPrcPor		:= (cAlias)->PRCPOR	
	nIdLoja		:= (cAlias)->IDLOJA
	cCodSku		:= (cAlias)->CODSKU
	cDescPrd	:= (cAlias)->DESCSKU 
	cDtaDe		:= DateTime(1,(cAlias)->DATADE,(cAlias)->HORADE)
	cDtaAte		:= DateTime(2,(cAlias)->DATADE,(cAlias)->HORADE)
			
	//-----------------------+
	// Monta String API Rest |
	//-----------------------+
	oJson					:= {}        
	oJson					:= Array(#)
	oJson[#"listPrice"]		:= nPrcCheio
	oJson[#"costPrice"]		:= nPrcCheio
	oJson[#"markup"]		:= 0      
	
	oJson[#"fixedPrices"]	:= {}
	aAdd(oJson[#"fixedPrices"],Array(#))
	oPrice					:= aTail(oJson[#"fixedPrices"])    
	oPrice[#"tradePolicyId"]:= "1"
	oPrice[#"value"]		:= nPrcPor
	oPrice[#"listPrice"]	:= nPrcCheio
	oPrice[#"minQuantity"]	:= 1
		
	LogExec("ENVIANDO PRECO PRODUTO " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->DESCSKU) )
				 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(oJson,nIdSku,cCodSku,cDescPrd,(cAlias)->RECNODA1)
				
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

@description	Rotina envia manutanção de preços dos produtos para a plataforma e-commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		02/02/2016

@param oJson		, object		, descricao
@param nIdSku		, numeric		, descricao
@param cCodSku		, characters	, descricao
@param cDescPrd		, characters	, descricao
@param nRecnoDa1	, numeric		, descricao

/*/							
/**************************************************************************************************/
Static Function AEcoEnv(oJson,nIdSku,cCodSku,cDescPrd,nRecnoDa1)
Local aArea			:= GetArea()
Local aHeadOut  	:= {}

Local cUrl			:= GetNewPar("EC_URLRES2")
Local cAppKey		:= GetNewPar("EC_APPKEY")
Local cAppToken		:= GetNewPar("EC_APPTOKE")
Local cRest			:= ""

Local nTimeOut		:= 240

Local _oRest		:= Nil

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
_oRest:SetPath("/danacosmeticos/pricing/prices/"+ Alltrim(Str(nIdSku)))

 //--------------------+
 // Utiliza metodo PUT |
 //--------------------+
If _oRest:Put(aHeadOut,cRest)

	//--------------------+
	// Posiciona Registro |
	//--------------------+
	DA1->( dbGoTo( nRecnoDa1) )

	RecLock("DA1",.F.)
		DA1->DA1_ENVECO	:= "2" 
		DA1->DA1_XDTEXP	:= dTos( Date() )
		DA1->DA1_XHREXP	:= Time()	
	DA1->( MsUnLock() )
	LogExec("PRECO(S) ENVIADO COM SUCESSO. " )
	
Else
	//---------------------------------------+
	// Cria array com os erros de integracao |
	//---------------------------------------+
	aAdd(aMsgErro,{cCodSku,"ERRO AO ENVIAR A PRECO "  + _oRest:GetLastError()})
	LogExec("ERRO AO ENVIAR A PRECO " + _oRest:GetLastError() )	
EndIf 

RestArea(aArea)
Return .T.

/*******************************************************************************************/
/*/{Protheus.doc} DateTime

@description Converte Data e Hora utilizado no VTex

@author Bernard M. Margarido

@since 26/01/2017
@version undefined

@param nField	, numeric		, descricao
@param cDta		, characters	, descricao
@param cHora	, characters	, descricao

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

@description 	Rotina consulta preços dos produtos a serem enviados para a plataforma e-commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			cAlias 		, character ,Nome Arquivo Temporario
@param			nToReg		, integer	,Grava total de registros encontrados

@return			lRet - Variavel Logica
/*/			
/**************************************************************************************************/
Static Function AEcoQry(cAlias,nToReg)
Local cQuery 	:= ""
Local cCodTab	:= GetNewPar("EC_TABECO") 
	
//---------------------------+
// Query consulta preços sku |
//---------------------------+	
cQuery := "	SELECT " + CRLF
cQuery += "		CODSKU , " + CRLF 
cQuery += "		IDSKU , " + CRLF  
cQuery += "		DESCSKU, " + CRLF 
cQuery += "		PRCDE , " + CRLF 
cQuery += "		IDLOJA, " + CRLF 
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
cQuery += "			B5.B5_XIDSKU IDSKU , " + CRLF
cQuery += "			B1.B1_DESC DESCSKU, " + CRLF
cQuery += "			B1.B1_PRV1 PRCDE , " + CRLF 
cQuery += "			B5.B5_XIDLOJA IDLOJA, " + CRLF 
cQuery += "			DA0.DA0_DATDE DATADE, " + CRLF
cQuery += "			DA0.DA0_HORADE HORADE, " + CRLF
cQuery += "			DA1.DA1_PRCVEN PRCPOR, " + CRLF 
cQuery += "			DA1.DA1_CODTAB CODTABELA, " + CRLF 
cQuery += "			DA1.DA1_ITEM ITEM , " + CRLF 
cQuery += "			DA1.R_E_C_N_O_ RECNODA1 " + CRLF 
cQuery += "		FROM " + CRLF 
cQuery += "			" + RetSqlName("DA1") + " DA1 " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("DA0") + " DA0 ON DA0.DA0_FILIAL = '" + xFilial("DA0") + "' AND DA0.DA0_CODTAB = DA1.DA1_CODTAB AND DA0.D_E_L_E_T_ = '' " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = DA1.DA1_CODPRO AND B5.B5_XENVECO = '2' AND B5.B5_XENVSKU = '2' AND B5.B5_XUSAECO = 'S' AND B5.D_E_L_E_T_ = '' " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = DA1.DA1_CODPRO AND B1.B1_MSBLQL <> '1' AND B1.D_E_L_E_T_ = '' " + CRLF 
cQuery += "		WHERE " + CRLF 
cQuery += "			DA1.DA1_FILIAL = '" + xFilial("DA1") + "' AND " + CRLF 
cQuery += "			DA1.DA1_CODTAB = '" + cCodTab + "' AND " + CRLF
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

@param cMsg, characters, descricao

@type function
/*/

/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.
