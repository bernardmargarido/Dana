#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "003"
Static cDescInt	:= "PRODUTOS"
Static cDirImp	:= "/ecommerce/"

/**************************************************************************************************/
/*/{Protheus.doc} AECOI003
	@description	Rotina realiza a integração dos produtos pai para o ecommerce
	@type   		Function 
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
User Function AECOI003()

Private cThread	:= Alltrim(Str(ThreadId()))
Private cStaLog	:= "0"
Private cArqLog	:= ""	

Private nQtdInt	:= 0

Private cHrIni	:= Time()
Private dDtaInt	:= Date()

Private aMsgErro	:= {}
Private aPrdEnv		:= {}

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
cArqLog := cDirImp + "PRODUTOS" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO DE PRODUTOS COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())

If _lMultLj
	_oProcess:= MsNewProcess():New( {|_lEnd| AECOMULT03(@_lEnd)},"Aguarde...","Consultando Produtos" )
	_oProcess:Activate()
Else 
	//---------------------------------------+
	// Inicia processo de envio dos produtos |
	//---------------------------------------+
	Processa({|| AECOINT03() },"Aguarde...","Consultando Produtos.")
EndIf 

LogExec("FINALIZA INTEGRACAO DE PRODUTOS COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
LogExec(Replicate("-",80))
ConOut("")

//-----------------------------------+
// Envia especificações dos produtos |
//-----------------------------------+
U_AECOI03A()

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
/*/{Protheus.doc} AECOMULT03
	@description Multi Lojas e-Commerce
	@author Bernard M. Margarido
	@since 17/05/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************************/
Static Function AECOMULT03(_lEnd)
Local _aArea		:= GetArea()

Local _cFilAux 		:= cFilAnt 

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

		//----------------------------+
		// Posiciona a filial correta | 
		//----------------------------+
		If XTC->XTC_FILIAL <> cFilAnt 
			cFilAnt := XTC->XTC_FILIAL
		EndIf  

		//------------------------------+
		// Envia os produtos multi loja |
		//------------------------------+
		AECOINT03M(XTC->XTC_CODIGO,XTC->XTC_URL,XTC->XTC_URL2,XTC->XTC_APPKEY,XTC->XTC_APPTOK)

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
/*/{Protheus.doc} AECOINT03M
	@description	Rotina consulta e envia Produtos para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT03M(_cLojaID,_cUrl,_cUrl_2,_cAppKey,_cAppToken)
Local aArea			:= GetArea()

Local cCodPai 		:= ""
Local cNomePrd		:= ""
Local cTitPrd		:= "" 
Local cSubTitPrd	:= "" 
Local cDescPrd		:= "" 
Local cCarcacPrd	:= "" 
Local cKeyword		:= "" 
Local cStatus		:= ""
Local cTpProd		:= ""
Local cIdLoja		:= ""

Local cAlias		:= GetNextAlias()

Local nCat01		:= 0  
Local nCat02		:= 0   
Local nCat03		:= 0  
Local nCat04		:= 0
Local nCat05		:= 0
Local nFabric		:= 0
Local nIdProd		:= 0
Local nToReg		:= 0

//---------------------------------------------+
// Valida se existem produtos a serem enviadas |
//---------------------------------------------+
If !AEcoQry(cAlias,@nToReg,_cLojaID)
	aAdd(aMsgErro,{"003","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//-----------------------------+
// Inicia o envio das produtos |
//-----------------------------+
_oProcess:SetRegua2( nToReg )
While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	_oProcess:IncRegua2("Produtos " + Alltrim((cAlias)->CODIGO) + " - " + Alltrim((cAlias)->NOME))
					
	//----------------------+
	// Dados da Produto Pai |
	//----------------------+
	cCodPai 	:= (cAlias)->CODIGO
	cNomePrd	:= (cAlias)->NOME
	cTitPrd		:= (cAlias)->TIUTLO 
	cSubTitPrd	:= (cAlias)->SUBTITULO 
	cDescPrd	:= (cAlias)->DESCECO 
	cCarcacPrd	:= (cAlias)->DESCCARA 
	cKeyword	:= (cAlias)->KEYWORDS 
	cStatus		:= (cAlias)->STATUSPRD
	cTpProd		:= (cAlias)->TPPROD
	cIdLoja		:= "01" //(cAlias)->IDLOJA
	
	nCat01		:= (cAlias)->CATEGO01  
	nCat02		:= (cAlias)->CATEGO02   
	nCat03		:= (cAlias)->CATEGO03  
	nCat04		:= (cAlias)->CATEGO04
	nCat05		:= (cAlias)->CATEGO05
	nFabric		:= (cAlias)->CODMARCA
	nIdProd		:= (cAlias)->IDPROD
						
	LogExec("ENVIANDO PRODUTO " + Alltrim((cAlias)->CODIGO) + " - " + Alltrim((cAlias)->NOME) )
		 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnvM(	_cLojaID,_cUrl,_cAppKey,_cAppToken,cCodPai,cNomePrd,cTitPrd,cSubTitPrd,;
			 	cDescPrd,cCarcacPrd,cKeyword,cStatus,cTpProd,cIdLoja,nCat01,nCat02,nCat03,;
				nCat04,nCat05,nFabric,nIdProd,(cAlias)->RECNOB5)
	
	(cAlias)->( dbSkip() )
				
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT03
	@description	Rotina consulta e envia Produtos para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT03()
Local aArea			:= GetArea()

Local cCodPai 		:= ""
Local cNomePrd		:= ""
Local cTitPrd		:= "" 
Local cSubTitPrd	:= "" 
Local cDescPrd		:= "" 
Local cCarcacPrd	:= "" 
Local cKeyword		:= "" 
Local cStatus		:= ""
Local cTpProd		:= ""
Local cIdLoja		:= ""

Local cAlias		:= GetNextAlias()

Local nCat01		:= 0  
Local nCat02		:= 0   
Local nCat03		:= 0  
Local nCat04		:= 0
Local nCat05		:= 0
Local nFabric		:= 0
Local nIdProd		:= 0
Local nToReg		:= 0

//---------------------------------------------+
// Valida se existem produtos a serem enviadas |
//---------------------------------------------+
If !AEcoQry(cAlias,@nToReg)
	aAdd(aMsgErro,{"002","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//-----------------------------+
// Inicia o envio das produtos |
//-----------------------------+
ProcRegua(nToReg)
While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	IncProc("Produtos " + Alltrim((cAlias)->CODIGO) + " - " + Alltrim((cAlias)->NOME) )

					
	//----------------------+
	// Dados da Produto Pai |
	//----------------------+
	cCodPai 	:= (cAlias)->CODIGO
	cNomePrd	:= (cAlias)->NOME
	cTitPrd		:= (cAlias)->TIUTLO 
	cSubTitPrd	:= (cAlias)->SUBTITULO 
	cDescPrd	:= (cAlias)->DESCECO 
	cCarcacPrd	:= (cAlias)->DESCCARA 
	cKeyword	:= (cAlias)->KEYWORDS 
	cStatus		:= (cAlias)->STATUSPRD
	cTpProd		:= (cAlias)->TPPROD
	cIdLoja		:= (cAlias)->IDLOJA
	
	nCat01		:= (cAlias)->CATEGO01  
	nCat02		:= (cAlias)->CATEGO02   
	nCat03		:= (cAlias)->CATEGO03  
	nCat04		:= (cAlias)->CATEGO04
	nCat05		:= (cAlias)->CATEGO05
	nFabric		:= (cAlias)->CODMARCA
	nIdProd		:= (cAlias)->IDPROD
						
	LogExec("ENVIANDO PRODUTO " + Alltrim((cAlias)->CODIGO) + " - " + Alltrim((cAlias)->NOME) )
		 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(cCodPai,cNomePrd,cTitPrd,cSubTitPrd,cDescPrd,cCarcacPrd,;
			cKeyword,cStatus,cTpProd,cIdLoja,nCat01,nCat02,nCat03,;
			nCat04,nCat05,nFabric,nIdProd,(cAlias)->RECNOB5)
	
	(cAlias)->( dbSkip() )
				
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AEcoEnvM
	@description	Rotina envia dados do produto para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
	@type function
/*/
/**************************************************************************************************/
Static Function AEcoEnvM(	_cLojaID,_cUrl,_cAppKey,_cAppToken,cCodPai,cNomePrd,cTitPrd,;
							cSubTitPrd,cDescPrd,cCarcacPrd,cKeyword,cStatus,cTpProd,cIdLoja,nCat01,nCat02,nCat03,;
							nCat04,nCat05,nFabric,nIdProd,nRecnoB5)
						
Local aArea			:= GetArea()
Local aIdLoja		:= {}

Local cUrl			:= RTrim(_cUrl)
Local cUsrVTex		:= Rtrim(_cAppKey)
Local cPswVTex		:= RTrim(_cAppToken)

Local nCatDepar		:= 0
Local nId			:= 0

Local lLjPri 		:= .F.

Local oWsProd		:= Nil
Local _oDanaEcom 	:= Nil 

Default cIdLoja		:= "01"

//------------------+
// Instancia Classe |
//------------------+
oWsProd 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsProd:_URL 		:= cUrl
oWsProd:_HEADOUT 	:= {}	

//--------------------------------------------+
// Adiciona Usuario e Senha para autenticação |
//--------------------------------------------+
aAdd(oWsProd:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

If !Empty(nCat01)
	nCatDepar := nCat01
EndIf	

If !Empty(nCat02)
	nCatDepar := nCat02
EndIf	

If !Empty(nCat03)
	nCatDepar := nCat03
EndIf	

If !Empty(nCat04)
	nCatDepar := nCat04
EndIf

If !Empty(nCat05)
	nCatDepar := nCat05
EndIf

//---------------------------+
// Adiciona dados do Produto |
//---------------------------+
oWsProd:oWSproductVO:cAdWordsRemarketingCode	:= ""
oWsProd:oWSproductVO:nBrandId					:= nFabric
oWsProd:oWSproductVO:nCategoryId 				:= nCatDepar
oWsProd:oWSproductVO:nDepartmentId				:= nCat01
oWsProd:oWSproductVO:cDescription  				:= cDescPrd
oWsProd:oWSproductVO:cDescriptionShort 			:= cSubTitPrd
oWsProd:oWSproductVO:nId						:= IIF(nIdProd > 0 ,nIdProd,Nil)
oWsProd:oWSproductVO:lIsActive					:= IIF(cStatus == "A",.T.,.F.)
oWsProd:oWSproductVO:lIsVisible					:= IIF(cStatus == "A",.T.,.F.)
oWsProd:oWSproductVO:cKeyWords					:= cKeyword 
oWsProd:oWSproductVO:cLinkId					:= Lower(Alltrim(cTitPrd))
oWsProd:oWSproductVO:cLomadeeCampaignCode		:= ""
oWsProd:oWSproductVO:cMetaTagDescription		:= cCarcacPrd
oWsProd:oWSproductVO:cName						:= cNomePrd
oWsProd:oWSproductVO:cRefId						:= cCodPai
oWsProd:oWSproductVO:cReleaseDate				:= Nil
oWsProd:oWSproductVO:lShowWithoutStock			:= .T.
oWsProd:oWSproductVO:nSupplierId				:= Nil
oWsProd:oWSproductVO:cTaxCode					:= Nil
oWsProd:oWSproductVO:cTitle						:= cTitPrd

//--------------------------+
// Adiciona Canal de Vendas |
//--------------------------+
oWsProd:oWsProductVo:oWsListStoreId := Service_ArrayOfint():New()

//------------------------------------+
// Cria Array para os Canais de Venda |
//------------------------------------+
oWsProd:oWsProductVo:oWsListStoreId:nInt := {}
                         
If AT(",",cIdLoja) > 0
	aIdLoja := Separa(cIdLoja,",")
ElseIf !Empty(cIdLoja)
    aAdd(aIdLoja,cIdLoja)
EndIf

//----------------+
// Canal de Venda |
//----------------+
lLjPri := .F.
If Len(aIdLoja) > 0
	For nId := 1 To Len(aIdLoja)
		If !lLjPri 
			lLjPri := (aScan(aIdLoja,{|x| Alltrim(x) == "01"})) > 0
		EndIf	
		aAdd(oWsProd:oWsProductVo:oWsListStoreId:nInt,Val(aIdLoja[nId])) 
	Next nId
EndIf

If !lLjPri 
	aAdd(oWsProd:oWsProductVo:oWsListStoreId:nInt,1) 
EndIf	

LogExec("ENVIANDO PRODUTO " + cCodPai + " - " + Alltrim(cNomePrd) + " ." )

WsdlDbgLevel(3)
If oWsProd:ProductInsertUpdate(oWsProd:oWsProductVo)  
	If ValType(oWsProd:oWSProductInsertUpdateResult) == "O"
		 
		//-------------------------------+
		// Retorna ID do Produto na Vtex |
		//-------------------------------+
		If oWsProd:oWsProductInsertUpdateResult:nId > 0
			LogExec("PRODUTO " + cCodPai + " - " + Alltrim(cNomePrd) + " . ENVIADA COM SUCESSO." )
			
			//--------------+
			// ID eCommerce | 
			//--------------+
			nIdProd := oWsProd:oWsProductInsertUpdateResult:nId

			//----------------+
			// Grava ID marca |
			//----------------+
			_oDanaEcom 			:= DanaEcom():New()
			_oDanaEcom:cLojaID	:= _cLojaID
			_oDanaEcom:cAlias	:= "SB5"
			_oDanaEcom:cCodErp	:= cCodPai
			_oDanaEcom:nID		:= nIdProd
			_oDanaEcom:GravaID()

			//------------------+
			// Atualiza produto |
			//------------------+
			SB5->( dbGoTo(nRecnoB5) )
			RecLock("SB5",.F.)
				SB5->B5_XENVECO := "2"
				SB5->B5_XENVSKU := "1"
				SB5->B5_XENVCAT := "2"
				SB5->B5_XDTEXP	:= dTos(Date())
				SB5->B5_XHREXP	:= Time()
			SB5->( MsunLock() )	

			//--------------------------------------------------+
			// Adiciona Array para envio dos campos especificos |
			//--------------------------------------------------+
			aAdd(aPrdEnv,{SB5->B5_FILIAL,SB5->B5_COD,SB5->B5_XIDPROD})

		EndIf	
	Else
		aAdd(aMsgErro,{cCodPai,"ERRO AO ENVIAR PRODUTO PAI " + Alltrim(cCodPai) + " - " + Upper(Alltrim(cNomePrd)) + " "})
		LogExec("ERRO AO ENVIAR PRODUTO PAI " + Alltrim(cCodPai) + " - " + Upper(Alltrim(cNomePrd)) + " "  )
	EndIf	
Else
	aAdd(aMsgErro,{cCodPai,"ERRO AO ENVIAR PRODUTO PAI " + Alltrim(cCodPai) + " - " + Upper(Alltrim(cNomePrd)) + " " + Alltrim(GetWscError()) + CRLF})
	LogExec("ERRO AO ENVIAR A PRODUTO " + cCodPai + " - " + cNomePrd + " . " + GetWSCError() )
EndIf

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AEcoEnv
	@description	Rotina envia dados do produto para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
	@type function
/*/
/**************************************************************************************************/
Static Function AEcoEnv(cCodPai,cNomePrd,cTitPrd,cSubTitPrd,cDescPrd,cCarcacPrd,;
						cKeyword,cStatus,cTpProd,cIdLoja,nCat01,nCat02,nCat03,;
						nCat04,nCat05,nFabric,nIdProd,nRecnoB5)
						
Local aArea			:= GetArea()
Local aIdLoja		:= {}

Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")

Local nCatDepar		:= 0
Local nId			:= 0

Local lLjPri 		:= .F.

Local oWsProd		:= Nil

Default cIdLoja		:= "01"

//------------------+
// Instancia Classe |
//------------------+
oWsProd 			:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsProd:_URL 		:= cUrl
oWsProd:_HEADOUT 	:= {}	

//--------------------------------------------+
// Adiciona Usuario e Senha para autenticação |
//--------------------------------------------+
aAdd(oWsProd:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )

If !Empty(nCat01)
	nCatDepar := nCat01
EndIf	

If !Empty(nCat02)
	nCatDepar := nCat02
EndIf	

If !Empty(nCat03)
	nCatDepar := nCat03
EndIf	

If !Empty(nCat04)
	nCatDepar := nCat04
EndIf

If !Empty(nCat05)
	nCatDepar := nCat05
EndIf

//---------------------------+
// Adiciona dados do Produto |
//---------------------------+
oWsProd:oWSproductVO:cAdWordsRemarketingCode	:= ""
oWsProd:oWSproductVO:nBrandId					:= nFabric
oWsProd:oWSproductVO:nCategoryId 				:= nCatDepar
oWsProd:oWSproductVO:nDepartmentId				:= nCat01
oWsProd:oWSproductVO:cDescription  				:= cDescPrd
oWsProd:oWSproductVO:cDescriptionShort 			:= cSubTitPrd
oWsProd:oWSproductVO:nId						:= IIF(nIdProd > 0 ,nIdProd,Nil)
oWsProd:oWSproductVO:lIsActive					:= IIF(cStatus == "A",.T.,.F.)
oWsProd:oWSproductVO:lIsVisible					:= IIF(cStatus == "A",.T.,.F.)
oWsProd:oWSproductVO:cKeyWords					:= cKeyword 
oWsProd:oWSproductVO:cLinkId					:= Lower(Alltrim(cTitPrd))
oWsProd:oWSproductVO:cLomadeeCampaignCode		:= ""
oWsProd:oWSproductVO:cMetaTagDescription		:= cCarcacPrd
oWsProd:oWSproductVO:cName						:= cNomePrd
oWsProd:oWSproductVO:cRefId						:= cCodPai
oWsProd:oWSproductVO:cReleaseDate				:= Nil
oWsProd:oWSproductVO:lShowWithoutStock			:= .T.
oWsProd:oWSproductVO:nSupplierId				:= Nil
oWsProd:oWSproductVO:cTaxCode					:= Nil
oWsProd:oWSproductVO:cTitle						:= cTitPrd

//--------------------------+
// Adiciona Canal de Vendas |
//--------------------------+
oWsProd:oWsProductVo:oWsListStoreId := Service_ArrayOfint():New()

//------------------------------------+
// Cria Array para os Canais de Venda |
//------------------------------------+
oWsProd:oWsProductVo:oWsListStoreId:nInt := {}
                         
If AT(",",cIdLoja) > 0
	aIdLoja := Separa(cIdLoja,",")
ElseIf !Empty(cIdLoja)
    aAdd(aIdLoja,cIdLoja)
EndIf

//----------------+
// Canal de Venda |
//----------------+
lLjPri := .F.
If Len(aIdLoja) > 0
	For nId := 1 To Len(aIdLoja)
		If !lLjPri 
			lLjPri := (aScan(aIdLoja,{|x| Alltrim(x) == "01"})) > 0
		EndIf	
		aAdd(oWsProd:oWsProductVo:oWsListStoreId:nInt,Val(aIdLoja[nId])) 
	Next nId
EndIf

If !lLjPri 
	aAdd(oWsProd:oWsProductVo:oWsListStoreId:nInt,1) 
EndIf	

LogExec("ENVIANDO PRODUTO " + cCodPai + " - " + Alltrim(cNomePrd) + " ." )

WsdlDbgLevel(3)
If oWsProd:ProductInsertUpdate(oWsProd:oWsProductVo)  
	If ValType(oWsProd:oWSProductInsertUpdateResult) == "O"
		 
		//-------------------------------+
		// Retorna ID do Produto na Vtex |
		//-------------------------------+
		If oWsProd:oWsProductInsertUpdateResult:nId > 0
			LogExec("PRODUTO " + cCodPai + " - " + Alltrim(cNomePrd) + " . ENVIADA COM SUCESSO." )
			
			//--------------+
			// ID eCommerce | 
			//--------------+
			nIdProd := oWsProd:oWsProductInsertUpdateResult:nId
									
			//------------------+
			// Atualiza produto |
			//------------------+
			SB5->( dbGoTo(nRecnoB5) )
			RecLock("SB5",.F.)
				SB5->B5_XIDPROD := nIdProd
				SB5->B5_XENVECO := "2"
				SB5->B5_XENVSKU := "1"
				SB5->B5_XENVCAT := "2"
				SB5->B5_XDTEXP	:= dTos(Date())
				SB5->B5_XHREXP	:= Time()
			SB5->( MsunLock() )	

			//--------------------------------------------------+
			// Adiciona Array para envio dos campos especificos |
			//--------------------------------------------------+
			aAdd(aPrdEnv,{SB5->B5_FILIAL,SB5->B5_COD,SB5->B5_XIDPROD})

		EndIf	
	Else
		aAdd(aMsgErro,{cCodPai,"ERRO AO ENVIAR PRODUTO PAI " + Alltrim(cCodPai) + " - " + Upper(Alltrim(cNomePrd)) + " "})
		LogExec("ERRO AO ENVIAR PRODUTO PAI " + Alltrim(cCodPai) + " - " + Upper(Alltrim(cNomePrd)) + " "  )
	EndIf	
Else
	aAdd(aMsgErro,{cCodPai,"ERRO AO ENVIAR PRODUTO PAI " + Alltrim(cCodPai) + " - " + Upper(Alltrim(cNomePrd)) + " " + Alltrim(GetWscError()) + CRLF})
	LogExec("ERRO AO ENVIAR A PRODUTO " + cCodPai + " - " + cNomePrd + " . " + GetWSCError() )
EndIf

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOQRY
	@description 	Rotina consulta os produtos a serem enviados para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/			
/**************************************************************************************************/
Static Function AEcoQry(cAlias,nToReg,_cLojaID)
Local cQuery 		:= ""

Default _cLojaID	:= ""

//-----------------------------+
// Query consulta produtos pai |
//-----------------------------+
cQuery := "	SELECT " + CRLF
cQuery += "		CODIGO, " + CRLF 
cQuery += "		CODMARCA, " + CRLF 
cQuery += "		NOME, " + CRLF
cQuery += "		TIUTLO, " + CRLF
cQuery += "		SUBTITULO, " + CRLF
cQuery += "		CATEGO01, " + CRLF
cQuery += "		CATEGO02, " + CRLF
cQuery += "		CATEGO03, " + CRLF  
cQuery += "		CATEGO04, " + CRLF  
cQuery += "		CATEGO05, " + CRLF  
cQuery += "		IDPROD, " + CRLF
cQuery += "		IDLOJA, " + CRLF
cQuery += "		DESCECO, " + CRLF 
cQuery += "		DESCCARA, " + CRLF 
cQuery += "		KEYWORDS, " + CRLF
cQuery += "		STATUSPRD, " + CRLF
cQuery += "		TPPROD, " + CRLF
cQuery += "		RECNOB5 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF 
cQuery += "			B5.B5_COD CODIGO, " + CRLF 

If Empty(_cLojaID)
	cQuery += "			ISNULL(AY2.AY2_XIDMAR,0) CODMARCA, " + CRLF 
Else 
	cQuery += "			ISNULL(XTD.XTD_IDECOM,0) CODMARCA, " + CRLF 
EndIf 

cQuery += "			B5.B5_XNOMPRD NOME, " + CRLF
cQuery += "			B5.B5_XTITULO TIUTLO, " + CRLF
cQuery += "			B5.B5_XSUBTIT SUBTITULO, " + CRLF

If Empty(_cLojaID)
	cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT01 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO01, " + CRLF   
	cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT02 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO02, " + CRLF  
	cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT03 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO03, " + CRLF 
	cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT04 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO04, " + CRLF 
	cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT05 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO05, " + CRLF 
Else 
	cQuery += "			ISNULL((SELECT XTD.XTD_IDECOM FROM " + RetSqlName("XTD") + " XTD WHERE XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'AY0' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = B5.B5_XCAT01 AND XTD.D_E_L_E_T_ = '' ),0) CATEGO01, " + CRLF   
	cQuery += "			ISNULL((SELECT XTD.XTD_IDECOM FROM " + RetSqlName("XTD") + " XTD WHERE XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'AY0' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = B5.B5_XCAT02 AND XTD.D_E_L_E_T_ = '' ),0) CATEGO02, " + CRLF  
	cQuery += "			ISNULL((SELECT XTD.XTD_IDECOM FROM " + RetSqlName("XTD") + " XTD WHERE XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'AY0' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = B5.B5_XCAT03 AND XTD.D_E_L_E_T_ = '' ),0) CATEGO03, " + CRLF 
	cQuery += "			ISNULL((SELECT XTD.XTD_IDECOM FROM " + RetSqlName("XTD") + " XTD WHERE XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'AY0' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = B5.B5_XCAT04 AND XTD.D_E_L_E_T_ = '' ),0) CATEGO04, " + CRLF 
	cQuery += "			ISNULL((SELECT XTD.XTD_IDECOM FROM " + RetSqlName("XTD") + " XTD WHERE XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'AY0' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = B5.B5_XCAT05 AND XTD.D_E_L_E_T_ = '' ),0) CATEGO05, " + CRLF 
EndIf 

If Empty(_cLojaID)
	cQuery += "			B5.B5_XIDPROD IDPROD, " + CRLF
Else 
	cQuery += "(		SELECT " + CRLF
	cQuery += "				XTD.XTD_IDECOM " + CRLF
	cQuery += "			FROM " + CRLF
	cQuery += "				" + RetSqlName("XTD") + " XTD " + CRLF 
	cQuery += "			WHERE " + CRLF
	cQuery += "				XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND " + CRLF
	cQuery += "				XTD.XTD_CODIGO = '" + _cLojaID + "' AND " + CRLF
	cQuery += "				XTD.XTD_ALIAS = 'SB5' AND " + CRLF
	cQuery += "				XTD.XTD_CODERP = B5.B5_COD AND " + CRLF
	cQuery += "				XTD.D_E_L_E_T_ = '' " + CRLF
	cQuery += "			) IDPROD,
EndIf 

cQuery += "			B5.B5_XIDLOJA IDLOJA, " + CRLF
cQuery += "			ISNULL(CAST(CAST(B5.B5_XDESCRI AS BINARY(2048)) AS VARCHAR(2048)),'') DESCECO, " + CRLF 
cQuery += "			ISNULL(CAST(CAST(B5.B5_XCARACT AS BINARY(2048)) AS VARCHAR(2048)),'') DESCCARA, " + CRLF
cQuery += "			ISNULL(CAST(CAST(B5.B5_XKEYWOR AS BINARY(2048)) AS VARCHAR(2048)),'') KEYWORDS, " + CRLF
cQuery += "			B5.B5_XSTAPRD STATUSPRD, " + CRLF
cQuery += "			B5.B5_XTPPROD TPPROD, " + CRLF
cQuery += "			B5.R_E_C_N_O_ RECNOB5 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SB5") + " B5 " + CRLF 

If Empty(_cLojaID)
	cQuery += "			LEFT OUTER JOIN " + RetSqlName("AY2") + " AY2 ON AY2.AY2_FILIAL = '" + xFilial("AY2") + "' AND AY2.AY2_CODIGO = B5.B5_XCODMAR AND AY2.D_E_L_E_T_ = '' " + CRLF
Else 
	cQuery += "			LEFT OUTER JOIN " + RetSqlName("XTD") + " XTD ON XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'AY2' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = B5.B5_XCODMAR AND XTD.D_E_L_E_T_ = '' " + CRLF
EndIf 

cQuery += "		WHERE " + CRLF
cQuery += "			B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF  
cQuery += "			B5.B5_XENVECO = '1' AND " + CRLF
cQuery += "			B5.B5_XENVSKU = '1' AND " + CRLF
cQuery += "			B5.B5_XUSAECO = 'S' AND " + CRLF

If !Empty(_cLojaID)
	cQuery += "			B5.B5_XIDLOJA LIKE '%" + _cLojaID + "%' AND " + CRLF
EndIf 

cQuery += "			B5.D_E_L_E_T_ = '' " + CRLF
cQuery += "	) PRDPAI " + CRLF
cQuery += "	ORDER BY CODIGO "

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
/*/{Protheus.doc} AEcoI03C
	@description Realiza a consulta dos ID dos produtos e-Commerce
	@type  Static Function
	@author Bernard M Margarido
	@since 22/08/2022
	@version version
/*/
/*********************************************************************************/
Static Function AEcoI03C(_cLojaID,_cUrl,_cAppKey,_cAppToken,_cRefId,_cTpProd,_cRest)
Local _oRest 	:= Nil 

Local _lRet		:= .F.

Local _aHeadOut	:= {}

aAdd(_aHeadOut,"Content-Type: application/json" )
aAdd(_aHeadOut,"X-VTEX-API-AppKey:" + _cAppKey )
aAdd(_aHeadOut,"X-VTEX-API-AppToken:" + _cAppToken ) 

_oRest := FWRest():New(RTrim(_cUrl))
_oRest:nTimeOut := 600
If _cTpProd == "1"
	_oRest:SetPath("/api/catalog_system/pvt/products/productgetbyrefid/" + RTrim(_cRefId))
	If _oRest:Get(_aHeadOut)
		//---------------------+
		// Desesserializa JSON |
		//---------------------+
		_cRest	:= _oRest:GetResult()
		_lRet   := .T.
	EndIf 
ElseIf _cTpProd == "2"
	_oRest:SetPath("/api/catalog/pvt/stockkeepingunit?refId=" + RTrim(_cRefId))
	If _oRest:Get(_aHeadOut)
		//---------------------+
		// Desesserializa JSON |
		//---------------------+
		_cRest	:= _oRest:GetResult()
		_lRet   := .T.
	EndIf 
EndIf 

Return _lRet 

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
