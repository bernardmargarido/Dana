#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "002"
Static cDescInt	:= "MARCAS"
Static cDirImp	:= "/ecommerce/"

/**************************************************************************************************/
/*/{Protheus.doc} AECOI002
	@description	Rotina realiza a integração das Marcas/Fabricantes para o ecommerce
	@type   		Function 
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/
/**************************************************************************************************/
User Function AECOI002()
		
Private cThread	:= Alltrim(Str(ThreadId()))
Private cStaLog	:= "0"
Private cArqLog	:= ""	

Private nQtdInt	:= 0

Private cHrIni	:= Time()
Private dDtaInt	:= Date()

Private aMsgErro:= {}

Private _lMultLj		:= GetNewPar("EC_MULTLOJ",.T.)

Private _oProcess 		:= Nil

//----------------------------------+
// Grava Log inicio das Integrações | 
//----------------------------------+
u_AEcoGrvLog(cCodInt,cDescInt,dDtaInt,cHrIni,,,,,cThread,1)

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirImp)
cArqLog := cDirImp + "MARCAS" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO DE MARCAS COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())

If _lMultLj
	_oProcess:= MsNewProcess():New( {|_lEnd| AECOMULT02(@_lEnd)},"Aguarde...","Consultando Marcas" )
	_oProcess:Activate()
Else 
	//-----------------------------------------+
	// Inicia processo de envio das categorias |
	//-----------------------------------------+
	Processa({|| AECOINT02() },"Aguarde...","Consultando as Categorias.")
EndIf 
LogExec("FINALIZA INTEGRACAO DE MARCAS COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
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

/*****************************************************************************************/
/*/{Protheus.doc} AECOMULT02
	@description Multi Lojas e-Commerce
	@author Bernard M. Margarido
	@since 17/05/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************************/
Static Function AECOMULT02(_lEnd)
Local _aArea		:= GetArea()

//-----------------+
// Lojas eCommerce |
//-----------------+
dbSelectArea("XTC")
XTC->( dbSetOrder(1) ) 
XTC->( dbGoTop() )
_oProcess:SetRegua1( XTC->( RecCount()))
While XTC->( !Eof() )
	
	_oProcess:IncRegua1("Loja eCommerce " + RTrim(XTC->XTC_DESC) )
	
	//----------------------+
	// Somente lojas ativas |
	//----------------------+
	If XTC->XTC_STATUS == "1"
		//--------------------------------+
		// Envia as categorias multi loja |
		//--------------------------------+
		AECOINT02M(XTC->XTC_CODIGO,XTC->XTC_URL,XTC->XTC_URL2,XTC->XTC_APPKEY,XTC->XTC_APPTOK)

	EndIf
	
	XTC->( dbSkip() )
	
EndDo

RestArea(_aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT02M
	@description	Rotina consulta e envia Marcas para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT02M(_cLojaID,_cUrl,_cUrl_2,_cAppKey,_cAppToken)
Local aArea		:= GetArea()

Local cCodMarca	:= ""
Local cDescMarca:= ""
Local cStatus 	:= ""

Local cAlias	:= GetNextAlias()

Local nToReg	:= 0
Local nIdMarca	:= 0

//-------------------------------------------+
// Valida se existem marcas a serem enviadas |
//-------------------------------------------+
If !AEcoQry(cAlias,@nToReg,_cLojaID)
	aAdd(aMsgErro,{"002","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//---------------------------------------+
// Inicia o envio das Marcas/Fabricantes |
//---------------------------------------+
_oProcess:SetRegua2( nToReg )
While (cAlias)->( !Eof() )

	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	_oProcess:IncRegua2("Marcas / Fabricantes " + RTrim((cAlias)->AY2_CODIGO) + " " + RTrim((cAlias)->DESCMARCA))
	
	//-----------------------------+
	// Dados da Marcas/Fabricantes |
	//-----------------------------+
	cCodMarca 	:= Alltrim((cAlias)->AY2_CODIGO)
	cDescMarca	:= Alltrim((cAlias)->DESCMARCA)
	nIdMarca	:= (cAlias)->AY2_XIDMAR
	cStatus 	:= (cAlias)->AY2_STATUS

	LogExec("ENVIANDO MARCA " + (cAlias)->AY2_CODIGO + " - " + Upper((cAlias)->DESCMARCA) )

	//-----------------------------------------+
	// Rotina realiza o envio para o eCommerce |
	//-----------------------------------------+
	AEcoEnvM(_cLojaID,_cUrl,_cAppKey,_cAppToken,cStatus,cDescMarca,cCodMarca,nIdMarca,(cAlias)->RECNOAY2)

	(cAlias)->( dbSkip() )

EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} AEcoEnvM
	@description	Rotina envia dados da caegoria para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/				
/************************************************************************************/
Static Function AEcoEnvM(_cLojaID,_cUrl,_cAppKey,_cAppToken,cStatus,cDescMarca,cCodMarca,nIDMarca,nRecnoAy2)
Local aArea			:= GetArea()

Local cUrl			:= RTrim(_cUrl)
Local cUsrVTex		:= Rtrim(_cAppKey)
Local cPswVTex		:= RTrim(_cAppToken)
Local oWsMarca		:= Nil 
Local _oDanaEcom 	:= Nil 

//--------------------+
// Posiciona Registro |
//--------------------+
AY2->( dbGoTo(nRecnoAy2) )

//------------------+
// Instancia Classe |
//------------------+
oWsMarca 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsMarca:_URL 		:= cUrl
oWsMarca:_HEADOUT 	:= {}	

//---------------------------------------------+
// Adiciona Usuario e Senha para autenticação. |
//---------------------------------------------+
aAdd(oWsMarca:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

oWsMarca:oWSbrand:cAdWordsRemarketingCode 	:= ""
oWsMarca:oWSbrand:cDescription				:= cDescMarca
oWsMarca:oWSbrand:cKeywords					:= Lower(cDescMarca)
oWsMarca:oWSbrand:cLomadeECampaignCode		:= ""	
oWsMarca:oWSbrand:cName						:= cDescMarca
oWsMarca:oWSbrand:cTitle					:= cDescMarca
oWsMarca:oWSbrand:lIsActive					:= IIF(cStatus == "1",.T.,.F.)
oWsMarca:oWSbrand:nId			   			:= IIF(nIDMarca > 0, nIDMarca, Nil)

LogExec("ENVIANDO MARCA " + cCodMarca + " - " + cDescMarca + " ." )

WsdlDbgLevel(3)
If oWsMarca:BrandInsertUpdate(oWsMarca:oWSbrand)  
	If ValType(oWsMarca:oWSbrandInsertUpdateResult) == "O"
		LogExec("MARCA " + cCodMarca + " - " + cDescMarca + " . ENVIADA COM SUCESSO." )

		//----------------+
		// Grava ID marca |
		//----------------+
		_oDanaEcom 			:= DanaEcom():New()
		_oDanaEcom:cLojaID	:= _cLojaID
		_oDanaEcom:cAlias	:= "AY2"
		_oDanaEcom:cCodErp	:= cCodMarca
		_oDanaEcom:nID		:= oWsMarca:oWSbrandInsertUpdateResult:nId
		_oDanaEcom:GravaID()

		RecLock("AY2",.F.)
			AY2->AY2_ENVECO  	:= "2"
			AY2->AY2_XDTEXP	  	:= dTos( Date() )
			AY2->AY2_XHREXP		:= Time()
		AY2->( MsUnLock() )	

	Else
		LogExec("ERRO AO ENVIAR A MARCA " + cCodMarca + " - " + cDescMarca + " . " )
		aAdd(aMsgErro,{cCodMarca,"ERRO AO ENVIAR A MARCA " + cCodMarca + " - " + cDescMarca + " . "})
	EndIf	
Else
	LogExec("ERRO AO ENVIAR A MARCA " + cCodMarca + " - " + cDescMarca + " . " )
	aAdd(aMsgErro,{cCodMarca,"ERRO AO ENVIAR A MARCA " + cCodMarca + " - " + cDescMarca + " . "})
EndIf

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT02
	@description	Rotina consulta e envia Marcas para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT02()
Local aArea		:= GetArea()

Local cCodMarca	:= ""
Local cDescMarca:= ""
Local cStatus 	:= ""

Local cAlias	:= GetNextAlias()

Local nToReg	:= 0
Local nIdMarca	:= 0

//-------------------------------------------+
// Valida se existem marcas a serem enviadas |
//-------------------------------------------+
If !AEcoQry(cAlias,@nToReg)
	aAdd(aMsgErro,{"002","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//---------------------------------------+
// Inicia o envio das Marcas/Fabricantes |
//---------------------------------------+
ProcRegua(nToReg)
While (cAlias)->( !Eof() )

	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	IncProc("Marcas / Fabricantes " + (cAlias)->AY2_CODIGO + " " + (cAlias)->DESCMARCA )

	//-----------------------------+
	// Dados da Marcas/Fabricantes |
	//-----------------------------+
	cCodMarca 	:= Alltrim((cAlias)->AY2_CODIGO)
	cDescMarca	:= Alltrim((cAlias)->DESCMARCA)
	nIdMarca	:= (cAlias)->AY2_XIDMAR
	cStatus 	:= (cAlias)->AY2_STATUS

	LogExec("ENVIANDO MARCA " + (cAlias)->AY2_CODIGO + " - " + Upper((cAlias)->DESCMARCA) )

	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(cStatus,cDescMarca,cCodMarca,nIdMarca,(cAlias)->RECNOAY2)

	(cAlias)->( dbSkip() )

EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} AECOENV
	@description	Rotina envia dados da caegoria para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/				
/************************************************************************************/
Static Function AEcoEnv(cStatus,cDescMarca,cCodMarca,nIDMarca,nRecnoAy2)
Local aArea			:= GetArea()

Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")
Local oWsMarca

//--------------------+
// Posiciona Registro |
//--------------------+
AY2->( dbGoTo(nRecnoAy2) )

//------------------+
// Instancia Classe |
//------------------+
oWsMarca 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsMarca:_URL 		:= cUrl
oWsMarca:_HEADOUT 	:= {}	

//---------------------------------------------+
// Adiciona Usuario e Senha para autenticação. |
//---------------------------------------------+
aAdd(oWsMarca:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

oWsMarca:oWSbrand:cAdWordsRemarketingCode 	:= ""
oWsMarca:oWSbrand:cDescription				:= cDescMarca
oWsMarca:oWSbrand:cKeywords					:= Lower(cDescMarca)
oWsMarca:oWSbrand:cLomadeECampaignCode		:= ""	
oWsMarca:oWSbrand:cName						:= cDescMarca
oWsMarca:oWSbrand:cTitle					:= cDescMarca
oWsMarca:oWSbrand:lIsActive					:= IIF(cStatus == "1",.T.,.F.)
oWsMarca:oWSbrand:nId			   			:= IIF(nIDMarca > 0, nIDMarca, Nil)

LogExec("ENVIANDO MARCA " + cCodMarca + " - " + cDescMarca + " ." )

WsdlDbgLevel(3)
If oWsMarca:BrandInsertUpdate(oWsMarca:oWSbrand)  
	If ValType(oWsMarca:oWSbrandInsertUpdateResult) == "O"
		LogExec("MARCA " + cCodMarca + " - " + cDescMarca + " . ENVIADA COM SUCESSO." )
		RecLock("AY2",.F.)
			AY2->AY2_ENVECO  	:= "2"
			AY2->AY2_XIDMAR		:= oWsMarca:oWSbrandInsertUpdateResult:nId
			AY2->AY2_XDTEXP	  	:= dTos( Date() )
			AY2->AY2_XHREXP		:= Time()
		AY2->( MsUnLock() )	
	Else
		LogExec("ERRO AO ENVIAR A MARCA " + cCodMarca + " - " + cDescMarca + " . " )
		aAdd(aMsgErro,{cCodMarca,"ERRO AO ENVIAR A MARCA " + cCodMarca + " - " + cDescMarca + " . "})
	EndIf	
Else
	LogExec("ERRO AO ENVIAR A MARCA " + cCodMarca + " - " + cDescMarca + " . " )
	aAdd(aMsgErro,{cCodMarca,"ERRO AO ENVIAR A MARCA " + cCodMarca + " - " + cDescMarca + " . "})
EndIf

RestArea(aArea)
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} AEcoI01C
	@description Consulta categoria no e-Commerce
	@author Bernard M. Margarido
	@since 13/05/2019
	@version undefined
	@type function
/*/
/*********************************************************************************/
User Function AEcoI02C(_nIdMarca)
Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")

Local _lRet			:= .F.

Local oWsMarca		:= Nil

//------------------+
// Instancia Classe |
//------------------+
oWsMarca 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsMarca:_URL 		:= cUrl
oWsMarca:_HEADOUT 	:= {}	

//---------------------------------------------+
// Adiciona Usuario e Senha para autenticação. |
//---------------------------------------------+
aAdd(oWsMarca:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

oWsMarca:nidBrand	:= _nIdMarca

//--------------------+
// Consulta Categoria |
//--------------------+
WsdlDbgLevel(3)
If oWsMarca:BrandGet()  
	If ValType(oWsMarca:oWsBrandGetResult:nId) <> "U"
		_lRet := .T.
	EndIf
Else
	_lRet := .F.
EndIf

Return _lRet

/*************************************************************************************/
/*/{Protheus.doc} AECOQRY
	@description 	Rotina consulta as marcas/fabricantes para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/			
/*************************************************************************************/
Static Function AEcoQry(cAlias,nToReg,_cLojaID)
Local cQuery 		:= ""

Default _cLojaID	:= ""

//---------------------------------+
// Query consulta Marcas/Fabricane |
//---------------------------------+
cQuery := "	SELECT " + CRLF 
cQuery += "		AY2.AY2_CODIGO, " + CRLF
cQuery += "		CAST(CAST(AY2_DESECO AS BINARY) AS VARCHAR) DESCMARCA," + CRLF
cQuery += "		AY2.AY2_STATUS," + CRLF

If Empty(_cLojaID)
	cQuery += "		AY2.AY2_XIDMAR," + CRLF
Else 
	cQuery += "(	SELECT " + CRLF
	cQuery += "			XTD.XTD_IDECOM " + CRLF
	cQuery += "		FROM " + CRLF
	cQuery += "			" + RetSqlName("XTD") + " XTD " + CRLF 
	cQuery += "		WHERE " + CRLF
	cQuery += "			XTD.XTD_CODIGO = '" + _cLojaID + "' AND " + CRLF
	cQuery += "			XTD.XTD_ALIAS = 'AY2' AND " + CRLF
	cQuery += "			XTD.XTD_CODERP = AY2.AY2_CODIGO AND " + CRLF
	cQuery += "			XTD.D_E_L_E_T_ = '' " + CRLF
	cQuery += "		) AY2_XIDMAR, "
EndIf 

cQuery += "		AY2.R_E_C_N_O_ RECNOAY2" + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("AY2") + " AY2 " + CRLF

cQuery += "	WHERE " + CRLF
cQuery += "		AY2.AY2_FILIAL = '" + xFilial("AY2") + "' AND " + CRLF
cQuery += "		AY2.AY2_ENVECO = '1' AND " + CRLF 

If !Empty(_cLojaID)
	cQuery += "		AY2.AY2_IDLOJA LIKE '%" + _cLojaID + "%' AND " + CRLF 
EndIf 

cQuery += "		AY2.D_E_L_E_T_ = '' " + CRLF
cQuery += "	ORDER BY AY2.AY2_CODIGO "

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
