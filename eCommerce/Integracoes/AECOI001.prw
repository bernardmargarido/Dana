#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "001"
Static cDescInt	:= "CATEGORIAS"
Static cDirImp	:= "/ecommerce/"
Static nTamCat	:= TamSx3("AY1_CODIGO")[1]


/**************************************************************************************************/
/*/{Protheus.doc} AECOI001
	@description	Rotina realiza a integração das categorias para o ecommerce
	@type   		Function 
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/
/**************************************************************************************************/
User Function AECOI001()

Private cThread			:= Alltrim(Str(ThreadId()))
Private cStaLog			:= "0"
Private cArqLog			:= ""	

Private nQtdInt			:= 0

Private cHrIni			:= Time()
Private dDtaInt			:= Date()

Private aMsgErro		:= {}

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
cArqLog := cDirImp + "CATEGORIAS" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO DE CATEGORIAS COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())

If _lMultLj
	_oProcess:= MsNewProcess():New( {|_lEnd| AECOMULT01(@_lEnd)},"Aguarde...","Consultando Categorias" )
	_oProcess:Activate()
Else 

	//-----------------------------------------+
	// Inicia processo de envio das categorias |
	//-----------------------------------------+
	Processa({|| AECOINT01() },"Aguarde...","Consultando as Categorias.")

EndIf 
LogExec("FINALIZA INTEGRACAO DE CATEGORIAS COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
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
/*/{Protheus.doc} AECOMULT01
	@description Multi Lojas e-Commerce
	@author Bernard M. Margarido
	@since 17/05/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************************/
Static Function AECOMULT01(_lEnd)
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
		AECOINT01M(XTC->XTC_CODIGO,XTC->XTC_URL,XTC->XTC_URL2,XTC->XTC_APPKEY,XTC->XTC_APPTOK)

	EndIf
	
	XTC->( dbSkip() )
	
EndDo

RestArea(_aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT01M
	@description	Rotina consulta e envia categorias para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT01M(_cLojaID,_cUrl,_cUrl_2,_cAppKey,_cAppToken)
Local aArea		:= GetArea()
	
Local cCatIni	:= ""
Local cCodCat 	:= ""
Local cCodPai	:= ""
Local cStatus 	:= ""
Local cDescCat	:= ""
		
Local cAlias	:= GetNextAlias()

Local nToReg	:= 0
Local nIdCat	:= 0
Local nIdCatPai	:= 0

//-----------------------------------------------+
// Valida se existem categorias a serem enviadas |
//-----------------------------------------------+
If !AEcoQry(cAlias,@nToReg,_cLojaID)
	LogExec("NAO EXISTEM REGISTROS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------------+
// Inicia o envio das categorias |
//-------------------------------+
_oProcess:SetRegua2( nToReg )
While (cAlias)->( !Eof() )
	
	cCatIni := (cAlias)->AY1_CODIGO
	
	While (cAlias)->( !Eof() .And. cCatIni == (cAlias)->AY1_CODIGO )
	
		//-----------------------------------+
		// Incrementa regua de processamento |
		//-----------------------------------+
		_oProcess:IncRegua2("Categoria " + RTrim((cAlias)->AY1_SUBCAT) + " " + RTrim((cAlias)->AY0_DESC) )
				
		//--------------------+
		// Dados da Categoria |
		//--------------------+
		cCodCat 	:= Alltrim((cAlias)->AY1_SUBCAT)
		cCodPai		:= Iif(Alltrim((cAlias)->AY1_CODIGO) == StrZero(0,nTamCat),"",Alltrim((cAlias)->AY1_CODIGO))
		nIdCat		:= (cAlias)->IDCATEG
		nIdCatPai	:= IIF(Empty(cCodPai),0,AEcoI01K(_cLojaID,cCodPai))
		cStatus 	:= (cAlias)->AY0_STATUS
		cDescCat	:= MsMm((cAlias)->AY0_CODDES)
		
		LogExec("ENVIANDO CATEGORIA " + cCodCat + " - " + Upper(cDescCat) )
		 
		//-----------------------------------------+
		// Rotina realiza o envio para o eCommerce |
		//-----------------------------------------+
		AEcoEnvM(_cLojaID,_cUrl,_cAppKey,_cAppToken,cStatus,cDescCat,cCodCat,cCodPai,nIdCat,nIdCatPai,(cAlias)->RECNOAY0)
				
		(cAlias)->( dbSkip() )
		
	EndDo
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT01
	@description	Rotina consulta e envia categorias para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT01()
Local aArea		:= GetArea()
	
Local cCatIni	:= ""
Local cCodCat 	:= ""
Local cCodPai	:= ""
Local cStatus 	:= ""
Local cDescCat	:= ""
		
Local cAlias	:= GetNextAlias()

Local nToReg	:= 0
Local nIdCat	:= 0
Local nIdCatPai	:= 0

//-----------------------------------------------+
// Valida se existem categorias a serem enviadas |
//-----------------------------------------------+
If !AEcoQry(cAlias,@nToReg)
	LogExec("NAO EXISTEM REGISTROS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------------+
// Inicia o envio das categorias |
//-------------------------------+
ProcRegua(nToReg)
While (cAlias)->( !Eof() )
	
	cCatIni := (cAlias)->AY1_CODIGO
	
	While (cAlias)->( !Eof() .And. cCatIni == (cAlias)->AY1_CODIGO )
	
		//-----------------------------------+
		// Incrementa regua de processamento |
		//-----------------------------------+
		IncProc("Categoria " + (cAlias)->AY1_SUBCAT + " " + (cAlias)->AY0_DESC )

		//--------------------+
		// Dados da Categoria |
		//--------------------+
		cCodCat 	:= Alltrim((cAlias)->AY1_SUBCAT)
		cCodPai		:= Iif(Alltrim((cAlias)->AY1_CODIGO) == StrZero(0,nTamCat),"",Alltrim((cAlias)->AY1_CODIGO))
		nIdCat		:= (cAlias)->IDCATEG
		nIdCatPai	:= IIF(Empty(cCodPai),0,Posicione("AY0",1,xFilial("AY0") + cCodPai,"AY0_XIDCAT"))
		cStatus 	:= (cAlias)->AY0_STATUS
		cDescCat	:= MsMm((cAlias)->AY0_CODDES)
		
		LogExec("ENVIANDO CATEGORIA " + cCodCat + " - " + Upper(cDescCat) )
		 
		//---------------------------------------+
		// Rotina realiza o envio para a Rakuten |
		//---------------------------------------+
		AEcoEnv(cStatus,cDescCat,cCodCat,cCodPai,nIdCat,nIdCatPai,(cAlias)->RECNOAY0)
				
		(cAlias)->( dbSkip() )
		
	EndDo
		
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} AEcoEnvM
	@description	Rotina envia dados da categoria processo multi loja
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/								
/*************************************************************************************/
Static Function AEcoEnvM(_cLojaID,_cUrl,_cAppKey,_cAppToken,cStatus,cDescCat,cCodCat,cCodPai,nIdCat,nIdCatPai,nRecnoAy0)

Local cUrl			:= RTrim(_cUrl)
Local cUsrVTex		:= Rtrim(_cAppKey)
Local cPswVTex		:= RTrim(_cAppToken)

Local oWsCateg		:= Nil 
Local _oDanaEcom 	:= Nil 

//------------------+
// Instancia Classe |
//------------------+
oWsCateg 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsCateg:_URL 		:= cUrl
oWsCateg:_HEADOUT 	:= {}	

//---------------------------------------------+
// Adiciona Usuario e Senha para autenticação. |
//---------------------------------------------+
aAdd(oWsCateg:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

oWsCateg:oWsCategory:cAdWordsRemarketingCode	:= ""
oWsCateg:oWsCategory:cDescription				:= cDescCat
oWsCateg:oWsCategory:nFatherCategoryId			:= IIf(nIdCatPai > 0,nIdCatPai, Nil)
oWsCateg:oWsCategory:nId						:= IIF(nIdCat > 0 , nIdCat,Nil)
oWsCateg:oWsCategory:lIsActive					:= IIF(cStatus == "1",.T.,.F.)
oWsCateg:oWsCategory:cKeywords					:= Lower(cDescCat)
oWsCateg:oWsCategory:cLomadeeCampaignCode  		:= ""
oWsCateg:oWsCategory:cName						:= cDescCat
oWsCateg:oWsCategory:cTitle						:= cDescCat

LogExec("ENVIANDO CATEGORIA " + cCodCat + " - " + cDescCat + " ." )

//--------------------+
// Posiciona Registro |
//--------------------+
AY0->( dbGoTo(nRecnoAy0) )

WsdlDbgLevel(3)
If oWsCateg:CategoryInsertUpdate(oWsCateg:oWsCategory)  
	If ValType(oWsCateg:oWsCategoryInsertUpdateResult) == "O"

		_oDanaEcom 			:= DanaEcom():New()
		_oDanaEcom:cLojaID	:= _cLojaID
		_oDanaEcom:cAlias	:= "AY0"
		_oDanaEcom:cCodErp	:= cCodCat
		_oDanaEcom:nID		:= oWsCateg:oWsCategoryInsertUpdateResult:nId
		_oDanaEcom:GravaID()

		RecLock("AY0",.F.)
			AY0->AY0_ENVECO := "2"
			AY0->AY0_XDTEXP	:= dTos( Date() )
			AY0->AY0_XHREXP	:= Time()
		AY0->( MsUnLock() )

		LogExec("CATEGORIA " + cCodCat + " - " + cDescCat + " . ENVIADA COM SUCESSO." )	
	Else
		LogExec("ERRO AO ENVIAR A CATEGORIA " + cCodCat + " - " + cDescCat + " . " )
		aAdd(aMsgErro,{cCodCat,"ERRO AO ENVIAR CATEGORIA " + cCodCat + " - " + cDescCat + " ."}) 
	EndIf	
Else
	LogExec("ERRO AO ENVIAR A CATEGORIA " + cCodCat + " - " + cDescCat + " . ERRO: " + RTrim(GetWscError()) )
	aAdd(aMsgErro,{cCodCat,"ERRO AO ENVIAR CATEGORIA " + cCodCat + " - " + cDescCat + " . ERRO: " + RTrim(GetWscError())}) 
EndIf

Return .T.

/************************************************************************************/
/*/{Protheus.doc} AECOENV
	@description	Rotina envia dados da caegoria para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/								
/*************************************************************************************/
Static Function AEcoEnv(cStatus,cDescCat,cCodCat,cCodPai,nIdCat,nIdCatPai,nRecnoAy0)

Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")

Local oWsCateg

//------------------+
// Instancia Classe |
//------------------+
oWsCateg 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsCateg:_URL 		:= cUrl
oWsCateg:_HEADOUT 	:= {}	

//---------------------------------------------+
// Adiciona Usuario e Senha para autenticação. |
//---------------------------------------------+
aAdd(oWsCateg:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

oWsCateg:oWsCategory:cAdWordsRemarketingCode	:= ""
oWsCateg:oWsCategory:cDescription				:= cDescCat
oWsCateg:oWsCategory:nFatherCategoryId			:= IIf(nIdCatPai > 0,nIdCatPai, Nil)
oWsCateg:oWsCategory:nId						:= IIF(nIdCat > 0 , nIdCat,Nil)
oWsCateg:oWsCategory:lIsActive					:= IIF(cStatus == "1",.T.,.F.)
oWsCateg:oWsCategory:cKeywords					:= Lower(cDescCat)
oWsCateg:oWsCategory:cLomadeeCampaignCode  		:= ""
oWsCateg:oWsCategory:cName						:= cDescCat
oWsCateg:oWsCategory:cTitle						:= cDescCat

LogExec("ENVIANDO CATEGORIA " + cCodCat + " - " + cDescCat + " ." )

//--------------------+
// Posiciona Registro |
//--------------------+
AY0->( dbGoTo(nRecnoAy0) )

WsdlDbgLevel(3)
If oWsCateg:CategoryInsertUpdate(oWsCateg:oWsCategory)  
	If ValType(oWsCateg:oWsCategoryInsertUpdateResult) == "O"
		RecLock("AY0",.F.)
			AY0->AY0_ENVECO := "2"
			AY0->AY0_XIDCAT	:= oWsCateg:oWsCategoryInsertUpdateResult:nId
			AY0->AY0_XDTEXP	:= dTos( Date() )
			AY0->AY0_XHREXP	:= Time()
		AY0->( MsUnLock() )
		LogExec("CATEGORIA " + cCodCat + " - " + cDescCat + " . ENVIADA COM SUCESSO." )	
	Else
		LogExec("ERRO AO ENVIAR A CATEGORIA " + cCodCat + " - " + cDescCat + " . " )
		aAdd(aMsgErro,{cCodCat,"ERRO AO ENVIAR CATEGORIA " + cCodCat + " - " + cDescCat + " ."}) 
	EndIf	
Else
	LogExec("ERRO AO ENVIAR A CATEGORIA " + cCodCat + " - " + cDescCat + " . ERRO: " + RTrim(GetWscError()) )
	aAdd(aMsgErro,{cCodCat,"ERRO AO ENVIAR CATEGORIA " + cCodCat + " - " + cDescCat + " . ERRO: " + RTrim(GetWscError())}) 
EndIf

Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOQRY
	@description 	Rotina consulta e envia categorias para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
/*/
/**************************************************************************************************/
Static Function AEcoQry(cAlias,nToReg,_cLojaID)
Local cQuery 		:= ""

Default _cLojaID	:= ""

//---------------------------+
// Query consulta categorias |
//---------------------------+
cQuery := "	SELECT " + CRLF
cQuery += "		AY1.AY1_CODIGO, " + CRLF
cQuery += "		AY1.AY1_SUBCAT, " + CRLF
cQuery += "		AY0.AY0_DESC, " + CRLF
cQuery += "		AY0.AY0_STATUS, " + CRLF
cQuery += "		AY1.AY1_CATPAI, " + CRLF
cQuery += "		AY1.AY1_CATFIL, " + CRLF
cQuery += "		AY0.AY0_CODDES, " + CRLF

If Empty(_cLojaID)
	cQuery += "	(	SELECT " + CRLF
	cQuery += "			AY0.AY0_XIDCAT " + CRLF
	cQuery += "		FROM " + CRLF
	cQuery += "			" + RetSqlName("AY0") + " AYB " + CRLF 
	cQuery += "		WHERE " + CRLF
	cQuery += "			AYB.AY0_CODIGO = AY1.AY1_SUBCAT AND " + CRLF
	cQuery += "			AYB.D_E_L_E_T_ = '' " + CRLF
	cQuery += "		) IDCATEG, " + CRLF
Else 	
	cQuery += "(	SELECT " + CRLF
	cQuery += "			XTD.XTD_IDECOM " + CRLF
	cQuery += "		FROM " + CRLF
	cQuery += "			" + RetSqlName("XTD") + " XTD " + CRLF 
	cQuery += "		WHERE " + CRLF
	cQuery += "			XTD.XTD_CODIGO = '" + _cLojaID + "' AND " + CRLF
	cQuery += "			XTD.XTD_ALIAS = 'AY0' AND " + CRLF
	cQuery += "			XTD.XTD_CODERP = AY1.AY1_SUBCAT AND " + CRLF
	cQuery += "			XTD.D_E_L_E_T_ = '' " + CRLF
	cQuery += "		) IDCATEG, "
EndIf 

cQuery += "		AY0.R_E_C_N_O_ RECNOAY0 " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "		 " + RetSqlName("AY1") + " AY1 " + CRLF

If Empty(_cLojaID)
	cQuery += "		INNER JOIN " + RetSqlName("AY0") + " AY0 ON AY0.AY0_CODIGO = AY1.AY1_SUBCAT AND AY0.AY0_ENVECO = '1' AND AY0.D_E_L_E_T_ = '' " + CRLF
Else 
	cQuery += "		INNER JOIN " + RetSqlName("AY0") + " AY0 ON AY0.AY0_CODIGO = AY1.AY1_SUBCAT AND AY0.AY0_ENVECO = '1' AND AY0.AY0_IDLOJA LIKE '%" + _cLojaID + "%' AND AY0.D_E_L_E_T_ = '' " + CRLF
EndIf 

cQuery += "	WHERE " + CRLF
cQuery += "		AY1.D_E_L_E_T_ = ' ' " + CRLF 
cQuery += "	ORDER BY AY0_TIPO "

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
/*/{Protheus.doc} AEcoI01C
	@description Consulta categoria no e-Commerce
	@author Bernard M. Margarido
	@since 13/05/2019
	@version undefined
	@type function
/*/
/*********************************************************************************/
User Function AEcoI01C(_nIdCat)
Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")

Local _lRet			:= .F.

Local oWsCateg		:= Nil

//------------------+
// Instancia Classe |
//------------------+
oWsCateg 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsCateg:_URL 		:= cUrl
oWsCateg:_HEADOUT 	:= {}	

//---------------------------------------------+
// Adiciona Usuario e Senha para autenticação. |
//---------------------------------------------+
aAdd(oWsCateg:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

oWsCateg:nidCategory	:= _nIdCat

//--------------------+
// Consulta Categoria |
//--------------------+
WsdlDbgLevel(3)
If oWsCateg:CategoryGet()  
	If ValType(oWsCateg:oWsCategoryGetResult:nId) <> "U"
		_lRet := .T.
	EndIf
Else
	_lRet := .F.
EndIf

Return _lRet

/*********************************************************************************/
/*/{Protheus.doc} AEcoI01D
	@description Consulta categoria no e-Commerce
	@author Bernard M. Margarido
	@since 13/05/2019
	@version undefined
	@type function
/*/
/*********************************************************************************/
Static Function AEcoI01D(_cLojaID,_cUrl,_cAppKey,_cAppToken,_cDedscCat,_cRest)
Local cUrl			:= _cUrl
Local cUsrVTex		:= _cAppKey
Local cPswVTex		:= _cAppToken

Local _lRet			:= .F.

Local oWsCateg		:= Nil

//------------------+
// Instancia Classe |
//------------------+
oWsCateg 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsCateg:_URL 		:= cUrl
oWsCateg:_HEADOUT 	:= {}	

//---------------------------------------------+
// Adiciona Usuario e Senha para autenticação. |
//---------------------------------------------+
aAdd(oWsCateg:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

oWsCateg:cnameCategory	:= RTrim(_cDedscCat)

//--------------------+
// Consulta Categoria |
//--------------------+
WsdlDbgLevel(3)
If oWsCateg:CategoryGetByName()  
	If ValType(oWsCateg:oWSCategoryGetByNameResult:nId) <> "U"
		_lRet := .T.
	EndIf
Else
	_lRet := .F.
EndIf

Return _lRet

/*********************************************************************************/
/*/{Protheus.doc} AEcoI01K
	@description Consulta ID produto pai 
	@type  Static Function
	@author Bernard M Margarido
	@since 16/08/2022
/*/
/*********************************************************************************/
Static Function AEcoI01K(_cLojaID,cCodPai)
Local _cQuery       := ""
Local _cAlias    	:= ""

Local _nIDPai		:= 0

_cQuery := " SELECT " + CRLF
_cQuery += "	XTD.XTD_IDECOM " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("XTD") + " XTD " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND " + CRLF
_cQuery += "	XTD.XTD_ALIAS = 'AY0' AND " + CRLF
_cQuery += "	XTD.XTD_CODIGO = '" + _cLojaID + "' AND " + CRLF
_cQuery += "	XTD.XTD_CODERP = '" + cCodPai + "' AND " + CRLF
_cQuery += "	XTD.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

_nIDPai	:= IIF( Empty((_cAlias)->XTD_IDECOM), 0, (_cAlias)->XTD_IDECOM)

(_cAlias)->( dbCloseArea() )

Return _nIDPai

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
