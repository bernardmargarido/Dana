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
Local aArea		:= GetArea()

Private cThread	:= Alltrim(Str(ThreadId()))
Private cStaLog	:= "0"
Private cArqLog	:= ""	

Private nQtdInt	:= 0

Private cHrIni	:= Time()
Private dDtaInt	:= Date()

Private aMsgErro:= {}

Private _lJob	:= IIF(Isincallstack("U_ECLOJM03"),.T.,.F.)

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
If _lJob
	AECOINT08()
Else
	Processa({|| AECOINT08() },"Aguarde...","Consultando Estoque.")
EndIf

LogExec("FINALIZA INTEGRACAO DE ESTOQUE COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
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
Local cLocal	:= GetNewPar("EC_ARMAZEM")
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
@since     		02/02/2016

@param			oJson		, object	, Objeto contendo arquivo JSON
@param			nRecnoSb2	, inteiro	, ID Estoque Protheus
/*/							
/**************************************************************************************************/

Static Function AEcoEnv(oJson,nIdSku,nRecnoSb2)
Local aArea			:= GetArea()
Local aHeadOut  	:= {}

Local cUrl			:= GetNewPar("EC_URLREST")
Local cAppKey		:= GetNewPar("EC_APPKEY")
Local cAppToken		:= GetNewPar("EC_APPTOKE")

Local cRest			:= ""

Local oRestClient	:= Nil

aAdd(aHeadOut,"Content-Type: application/json" )
aAdd(aHeadOut,"X-VTEX-API-AppKey:" + cAppKey )
aAdd(aHeadOut,"X-VTEX-API-AppToken:" + cAppToken ) 

//--------------------+
// Posiciona registro |
//--------------------+
SB2->( dbGoTo(nRecnoSb2) )

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
	RecLock("SB2",.F.)
		SB2->B2_MSEXP := dTos(Date())
	SB2->( MsUnLock() )	
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

@param			cAlias 		, Nome Arquivo Temporario
@param			nToReg		, Grava total de registros encontrados

@return			lRet - Variavel Logica
/*/			
/************************************************************************************************/
Static Function AEcoQry(cAlias,nToReg)

Local cQuery 	:= ""
Local cFilEst	:= GetNewPar("EC_FILEST")
Local cLocal	:= GetNewPar("EC_ARMAZEM")

//------------------------+
// Query consulta Estoques|
//------------------------+
cQuery := "	SELECT " + CRLF  
cQuery += "		CODSKU, " + CRLF
cQuery += "		DESCSKU, " + CRLF
cQuery += "		IDSKU, " + CRLF
cQuery += "		SALDO, " + CRLF
cQuery += "		RECNOSB2 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			B2.B2_COD CODSKU, " + CRLF
cQuery += "			B1.B1_DESC DESCSKU, " + CRLF
cQuery += "			B5.B5_XIDSKU IDSKU, " + CRLF
cQuery += "			B2.B2_QATU SALDO, " + CRLF
cQuery += "			B2.R_E_C_N_O_ RECNOSB2 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SB2") + " B2 " + CRLF
cQuery += "			INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = B2.B2_COD AND B1.B1_MSBLQL <> '1' AND B1.D_E_L_E_T_ = '' " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = B2.B2_COD AND B5.B5_XENVECO = '2' AND B5.B5_XENVSKU = '2' AND B5.B5_XUSAECO = 'S' AND B5.D_E_L_E_T_ = '' " + CRLF
cQuery += "		WHERE " + CRLF
cQuery += "			B2.B2_FILIAL = '" + cFilEst  + "' AND " + CRLF 
cQuery += "			B2.B2_LOCAL = '" + cLocal + "' AND " + CRLF
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
@version undefined

@param cMsg, characters, descricao

@type function
/*/

/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.