#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "012"
Static cDescInt	:= "ATIVACAO PRODUTO/SKU"
Static cDirImp	:= "/ecommerce/"

/*************************************************************************/

/*/{Protheus.doc} AECOI012

@description Realiza a ativação dos produtos / SKU.

@author Bernard M. Margarido
@since 30/01/2017
@version undefined

@type function
/*/
/*************************************************************************/
User Function AECOI012()
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
cArqLog := cDirImp + "ATIVASKU" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ATIVACAO DE PRODUTOS/SKU COM O ECOMMERCE - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())

//-----------------------------------------+
// Inicia processo de envio das categorias |
//-----------------------------------------+
Processa({|| AECOINT12() },"Aguarde...","Consultando Produtos.")

LogExec("FINALIZA ATIVACAO DE PRODUTOS/SKU COM A ECOMMERCE - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
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

/*/{Protheus.doc} AECOINT12

@description	Rotina consulta os produtos / sku para serem ativados

@author			Bernard M.Margarido
@version   		1.00
@since     		02/02/2016
/*/

/**************************************************************************************************/
Static Function AECOINT12()
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cCodProd	:= ""
Local cDescProd	:= ""
	
Local nIdProd	:= 0
Local nIdSku	:= 0
Local nToReg	:= 0
Local nRecnoWs6	:= 0
Local nRecnoWs5	:= 0
Local nRecnoSB5	:= 0

//-----------------------------------------------+
// Valida se existem categorias a serem enviadas |
//-----------------------------------------------+
If !AEcoQry(cAlias,@nToReg)
	aAdd(aMsgErro,{"008","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------------+
// Inicia o envio das categorias |
//-------------------------------+
ProcRegua(nToReg)
While (cAlias)->( !Eof() )
	
	nIdProd 	:= (cAlias)->IDPROD
	nRecnoSb5 	:= (cAlias)->RECNOSB5
	nRecnoWs5	:= (cAlias)->RECNOWS5
	nRecnoWs6	:= (cAlias)->RECNOWS6
	cCodProd	:= (cAlias)->CODPROD
	cDescProd	:= (cAlias)->DESCPROD
		
	While (cAlias)->( !Eof() .And. nIdProd == (cAlias)->IDPROD )
		
		//-----------------------------------+
		// Incrementa regua de processamento |
		//-----------------------------------+
		IncProc("Ativando produto " + (cAlias)->CODPROD + " " + Alltrim((cAlias)->DESCPROD) )
			
		aAtivSku(	(cAlias)->IDSKU,(cAlias)->RECNOSB5,(cAlias)->RECNOWS5,;
					(cAlias)->RECNOWS6,(cAlias)->CODPROD,(cAlias)->DESCPROD)		
				
		(cAlias)->( dbSkip() )
	EndDo
	
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	aAtivProd(	nIdProd,nRecnoSb5,nRecnoWs5 ,;
				nRecnoWs6,cCodProd,cDescProd )
		
EndDo
		
//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/*****************************************************************************************************/

/*/{Protheus.doc} aAtivProd

@description	Rotina ativa os produtos no e-Commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		02/02/2016

@param nIdProd		, numeric	, descricao
@param nRecnoSb5	, numeric	, descricao
@param nRecnoWs5	, numeric	, descricao
@param nRecnoWs6	, numeric	, descricao
@param cCodProd		, characters, descricao
@param cDescProd	, characters, descricao

/*/				
/******************************************************************************************************/
Static Function aAtivProd(	nIdProd,nRecnoSb5,nRecnoWs5 ,;
							nRecnoWs6,cCodProd,cDescProd)

Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")

Local oWsProd

//------------------+
// Instancia Classe |
//------------------+
oWsProd 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsProd:_URL 		:= cUrl
oWsProd:_HEADOUT 	:= {}	
oWsProd:nIdProduct	:= nIdProd

//--------------------------------------------+
// Adiciona Usuario e Senha para autenticação.|
//--------------------------------------------+
aAdd(oWsProd:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

LogExec("ATIVANDO PRODUTO " + cCodProd + " - " + Alltrim(cDescProd)  + " ." )

WsdlDbgLevel(3)
If oWsProd:ProductActive()  
	LogExec("PRODUTO " + cCodProd + " - " + Alltrim(cDescProd) + " ATIVADO COM SUCESSO." )
	If nRecnoSb5 > 0
		SB5->( dbGoTo(nRecnoSb5) )
		RecLock("SB5")
			SB5->B5_XATVPRD := "2"
		SB5->( MsUnLock() )	
	Else
		WS5->( dbGoTo(nRecnoWs5) )
		RecLock("WS5")
			WS5->WS5_ATVPRD := "2"
		WS5->( MsUnLock() )
	EndIf	
Else
	LogExec("ERRO AO ATIVAR PRODUTO " + cCodProd + " - " + Alltrim(cDescProd) + " . " + GetWSCError() )
	aAdd(aMsgErro,{cCodProd,"ERRO AO ATIVAR PRODUTO " + cCodProd + " - " + Alltrim(cDescProd) + " . " + GetWSCError() })
EndIf

Return .T.

/*****************************************************************************************************/

/*/{Protheus.doc} aAtivSku

@description	Rotina ativa os produtos no e-Commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		02/02/2016

@param			nIdSku		,	integer 	,Id do produto na VTEX


@return			aRet - Array aRet[1] - Logico	aRet[2] - Codigo Erro	aRet[3] - Descricao do Erro
/*/				
/******************************************************************************************************/
Static Function aAtivSku(	nIdSku,nRecnoSb5,nRecnoWs5,;
							nRecnoWs6,cCodProd,cDescProd)

Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")

Local oWsSku		

//------------------+
// Instancia Classe |
//------------------+
oWsSku 				:= WSVTex():New() 
 
//---------------------+
// Parametros de Envio |
//---------------------+
oWsSku:_URL 				:= cUrl
oWsSku:_HEADOUT 			:= {}	
oWsSku:nIdStockKeepingUnit	:= nIdSku

//--------------------------------------------+
// Adiciona Usuario e Senha para autenticação.|
//--------------------------------------------+
aAdd(oWsSku:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

LogExec("ATIVANDO PRODUTO " + cCodProd + " - " + Alltrim(cDescProd)  + " ." )

WsdlDbgLevel(3)
If oWsSku:StockKeepingUnitActive()  
	LogExec("PRODUTO SKU " + cCodProd + " - " + Alltrim(cDescProd) + " ATIVADO COM SUCESSO." )
	If nRecnoSb5 > 0
		SB5->( dbGoTo(nRecnoSb5) )
		RecLock("SB5")
			SB5->B5_XATVSKU := "2"
		SB5->( MsUnLock() )	
	Else
		WS6->( dbGoTo(nRecnoWs6) )
		RecLock("WS6")
			WS6->WS6_ATVSKU := "2"
		WS6->( MsUnLock() )
	EndIf		
Else
	LogExec("ERRO AO ATIVAR PRODUTO SKU " + cCodProd + " - " + Alltrim(cDescProd) + " . " + GetWSCError() )
	aAdd(aMsgErro,{cCodProd,"ERRO AO ATIVAR PRODUTO SKU " + cCodProd + " - " + Alltrim(cDescProd) + " . " + GetWSCError()})
EndIf

Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOQRY

@description 	Rotina consulta e envia categorias para a pataforma e-Commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		02/02/2016

@param			cAlias 		, Nome Arquivo Temporario
@param			nToReg		, Grava total de registros encontrados

@return			lRet - Variavel Logica
/*/
/**************************************************************************************************/
Static Function AEcoQry(cAlias,nToReg)
Local cQuery 		:= ""
Local cCodTab		:= GetNewPar("EC_TABECO")
Local cFilEst		:= GetNewPar("EC_FILEST")
Local cLocal		:= GetNewPar("EC_ARMAZEM")

//---------------------------+
// Query consulta categorias |
//---------------------------+
cQuery := "	SELECT " + CRLF
cQuery += "		CODPROD, " + CRLF
cQuery += "		DESCPROD," + CRLF
cQuery += "		IDPROD, " + CRLF 
cQuery += "		IDSKU, " + CRLF
cQuery += "		RECNOSB5, " + CRLF
cQuery += "		RECNOWS5, " + CRLF
cQuery += "		RECNOWS6 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			B5.B5_COD CODPROD, " + CRLF
cQuery += "			B5.B5_CEME DESCPROD, " + CRLF
cQuery += "			B5.B5_XIDPROD IDPROD, " + CRLF 
cQuery += "			B5.B5_XIDSKU IDSKU, " + CRLF 
cQuery += "			B5.R_E_C_N_O_ RECNOSB5, " + CRLF
cQuery += "			0 RECNOWS5, " + CRLF
cQuery += "			0 RECNOWS6 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SB5") + " B5 " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("DA1") + " DA1 ON DA1.DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1.DA1_CODPRO = B5.B5_COD AND DA1.DA1_CODTAB = '" + cCodTab + "' AND DA1.DA1_ENVECO = '2' AND DA1.D_E_L_E_T_ = '' " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("SB2") + " B2 ON B2.B2_FILIAL = '" + xFilial("SB2") + "' AND B2.B2_COD = B5.B5_COD AND B2.B2_LOCAL = '" + cLocal + "' AND B2.B2_MSEXP <> '' AND B2.D_E_L_E_T_ = '' " + CRLF 
cQuery += "		WHERE " + CRLF
cQuery += "			B5.B5_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF 
cQuery += "			B5.B5_XUSAECO = 'S' AND " + CRLF
cQuery += "			B5.B5_XENVECO = '2' AND " + CRLF
cQuery += "			B5.B5_XENVSKU = '2' AND " + CRLF
cQuery += "			B5.B5_XATVPRD = '1' AND " + CRLF
cQuery += "			B5.B5_STATUS = 'A' AND " + CRLF
cQuery += "			B5.D_E_L_E_T_ = '' " + CRLF
cQuery += "		UNION " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			WS6.WS6_CODSKU CODPROD, " + CRLF
cQuery += "			B1.B1_DESC DESCPROD, " + CRLF
cQuery += "			WS5.WS5_IDPROD IDPROD, " + CRLF 
cQuery += "			WS6.WS6_IDSKU IDSKU, " + CRLF
cQuery += "			0 RECNOSB5, " + CRLF
cQuery += "			WS5.R_E_C_N_O_ RECNOWS5, " + CRLF
cQuery += "			WS6.R_E_C_N_O_ RECNOWS6 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("WS5") + " WS5 " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("WS6") + " WS6 ON WS6.WS6_FILIAL = '" + xFilial("WS6") + "' AND WS6.WS6_CODPRD = WS5.WS5_CODPRD AND WS6.WS6_IDSKU > 0 AND WS6.WS6_ATVSKU IN('1','2') AND WS6.D_E_L_E_T_ = '' " + CRLF
cQuery += "			INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = WS6.WS6_CODSKU AND B1.D_E_L_E_T_ = '' " + CRLF
cQuery += "			INNER JOIN " + RetSqlName("DA1") + " DA1 ON DA1.DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1.DA1_CODPRO = WS6.WS6_CODSKU AND DA1.DA1_CODTAB = '" + cCodTab + "' AND DA1.DA1_ENVECO = '2' AND DA1.D_E_L_E_T_ = '' " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("SB2") + " B2 ON B2.B2_FILIAL = '" + xFilial("SB2") + "' AND B2.B2_COD = WS6.WS6_CODSKU AND B2.B2_LOCAL = '" + cLocal + "' AND B2.B2_MSEXP <> '' AND B2.D_E_L_E_T_ = '' " + CRLF 
cQuery += "		WHERE " + CRLF
cQuery += "			WS5.WS5_FILIAL = '" + xFilial("WS5") + "' AND " + CRLF 
cQuery += "			WS5.WS5_USAECO = 'S' AND " + CRLF 
cQuery += "			WS5.WS5_ENVECO = '2' AND " + CRLF
cQuery += "			WS5.WS5_ATVPRD = '1' AND " + CRLF
cQuery += "			WS5.WS5_STATUS = 'A' AND " + CRLF
cQuery += "			WS5.D_E_L_E_T_ = '' " + CRLF
cQuery += "	)ATVPRD " + CRLF
cQuery += "	ORDER BY IDPROD,IDSKU "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
count To nToReg  

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