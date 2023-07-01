#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "004"
Static cDescInt	:= "SKU"
Static cDirImp	:= "/ecommerce/"

/**************************************************************************************************/
/*/{Protheus.doc} AECOI004
	@description	Rotina realiza a integração dos produtos filhos (sku) para o ecommerce
	@type   		Function 
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
User Function AECOI004()

Private cThread		:= Alltrim(Str(ThreadId()))
Private cStaLog		:= "0"
Private cArqLog		:= ""	

Private nQtdInt		:= 0

Private cHrIni		:= Time()
Private dDtaInt		:= Date()

Private aMsgErro	:= {}

Private lJob 		:= .F.

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
cArqLog := cDirImp + "SKU" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO DE SKU COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())

If _lMultLj
	_oProcess:= MsNewProcess():New( {|_lEnd| AECOMULT04(@_lEnd)},"Aguarde...","Consultando SKU's" )
	_oProcess:Activate()
Else 
	//----------------------------------+
	// Inicia processo de envio dos SKU |
	//----------------------------------+
	Processa({|| AECOINT04() },"Aguarde...","Consultando Sku.")
EndIf 

LogExec("FINALIZA INTEGRACAO DE SKU COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
LogExec(Replicate("-",80))
ConOut("")

//Processa({|| U_AECOI04A()},"Aguarde...","Enviando Especificacoes Sku.")

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
/*/{Protheus.doc} AECOMULT04
	@description Multi Lojas e-Commerce
	@author Bernard M. Margarido
	@since 17/05/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************************/
Static Function AECOMULT04(_lEnd)
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

		//---------------------------+
		// Envia os SKU's multi loja |
		//---------------------------+
		AECOINT04M(XTC->XTC_CODIGO,XTC->XTC_URL,XTC->XTC_URL2,XTC->XTC_APPKEY,XTC->XTC_APPTOK)

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
/*/{Protheus.doc} AECOINT04
	@description	Rotina consulta e envia Produtos Filhos (SKU) para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT04M(_cLojaID,_cUrl,_cUrl_2,_cAppKey,_cAppToken)
Local aArea		:= GetArea()

Local cCodPai 	:= ""
Local cNomePrd	:= "" 
Local cCodSku	:= ""
Local cNomeSku	:= ""
Local cCodBar	:= ""  
Local cLocal	:= ""
Local cUnidade	:= ""
Local cStatPrd	:= ""
Local cAlias	:= GetNextAlias()

Local nCodMarca	:= 0
Local nPeso		:= 0
Local nPrcVen	:= 0   
Local nAltPrd	:= 0   
Local nAltEmb	:= 0   
Local nProfPrd	:= 0   
Local nProfEmb	:= 0   
Local nLargPrd	:= 0 
Local nLargEmb	:= 0 
Local nIdProd	:= 0   
Local nIdSku	:= 0 
Local nToReg	:= 0

//----------------------------------------+
// Valida se existem SKU a serem enviadas |
//----------------------------------------+
If !AEcoQry(cAlias,@nToReg,_cLojaID)
	aAdd(aMsgErro,{"004","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//------------------------+
// Inicia o envio dos SKU |
//------------------------+
_oProcess:SetRegua2( nToReg )
While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	_oProcess:IncRegua2("Sku " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->NOMESKU) )		

	//-----------+
	// Dados SKU |
	//-----------+
	cCodPai 	:= (cAlias)->CODIGO
	cNomePrd	:= (cAlias)->NOMEPAI 
	cCodSku		:= (cAlias)->CODSKU
	cNomeSku	:= Alltrim((cAlias)->NOMEPAI) 
	cCodBar		:= (cAlias)->CODBARRA  
	cLocal		:= (cAlias)->ARMAZEM
	cUnidade	:= (cAlias)->UNIDADE
	cStatPrd	:= (cAlias)->STATUSPRD
		
	//-----------------------------+   
	// Peso convertido para Gramas |
	//-----------------------------+
	nCodMarca	:= (cAlias)->CODMARCA
	nPeso		:= IIF((cAlias)->PESOLIQ > 0, (cAlias)->PESOLIQ ,(cAlias)->PESOLIQP ) 
	nPrcVen		:= (cAlias)->PRCVEN
	nAltPrd		:= (cAlias)->ALTPRD   
	nAltEmb		:= (cAlias)->ALTEMB   
	nProfPrd	:= (cAlias)->PROPRD   
	nProfEmb	:= (cAlias)->PROEMB   
	nLargPrd	:= (cAlias)->LARGPRD 
	nLargEmb	:= (cAlias)->LARGEMB
	
	//-----------------------
	// ID Produto eCommerce |
	//-----------------------
	nIdProd		:= (cAlias)->IDPROD   
	nIdSku		:= (cAlias)->IDSKU
					
	LogExec("ENVIANDO SKU " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->NOMESKU) )
		 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnvM(	_cLojaID,_cUrl,_cAppKey,_cAppToken,cCodPai,cNomePrd,cCodSku,;
				cNomeSku,cCodBar,cLocal,cUnidade,cStatPrd,nCodMarca,nPeso,;
				nPrcVen,nAltPrd,nAltEmb,nProfPrd,nProfEmb,nLargPrd,nLargEmb,;
				nIdProd,nIdSku,(cAlias)->RECNOSB5)
	
	(cAlias)->( dbSkip() )
				
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT04
	@description	Rotina consulta e envia Produtos Filhos (SKU) para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT04()
Local aArea		:= GetArea()

Local cCodPai 	:= ""
Local cNomePrd	:= "" 
Local cCodSku	:= ""
Local cNomeSku	:= ""
Local cCodBar	:= ""  
Local cLocal	:= ""
Local cUnidade	:= ""
Local cStatPrd	:= ""
Local cAlias	:= GetNextAlias()

Local nCodMarca	:= 0
Local nPeso		:= 0
Local nPrcVen	:= 0   
Local nAltPrd	:= 0   
Local nAltEmb	:= 0   
Local nProfPrd	:= 0   
Local nProfEmb	:= 0   
Local nLargPrd	:= 0 
Local nLargEmb	:= 0 
Local nIdProd	:= 0   
Local nIdSku	:= 0 
Local nToReg	:= 0

//----------------------------------------+
// Valida se existem SKU a serem enviadas |
//----------------------------------------+
If !AEcoQry(cAlias,@nToReg)
	aAdd(aMsgErro,{"004","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
	RestArea(aArea)
	Return .T.
EndIf

//------------------------+
// Inicia o envio dos SKU |
//------------------------+
ProcRegua(nToReg)
While (cAlias)->( !Eof() )
	
	//-----------------------------------+
	// Incrementa regua de processamento |
	//-----------------------------------+
	IncProc("Sku " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->NOMESKU) )
			
	//-----------+
	// Dados SKU |
	//-----------+
	cCodPai 	:= (cAlias)->CODIGO
	cNomePrd	:= (cAlias)->NOMEPAI 
	cCodSku		:= (cAlias)->CODSKU
	cNomeSku	:= Alltrim((cAlias)->NOMEPAI) 
	cCodBar		:= (cAlias)->CODBARRA  
	cLocal		:= (cAlias)->ARMAZEM
	cUnidade	:= (cAlias)->UNIDADE
	cStatPrd	:= (cAlias)->STATUSPRD
		
	//-----------------------------+   
	// Peso convertido para Gramas |
	//-----------------------------+
	nCodMarca	:= (cAlias)->CODMARCA
	nPeso		:= IIF((cAlias)->PESOLIQ > 0, (cAlias)->PESOLIQ ,(cAlias)->PESOLIQP ) 
	nPrcVen		:= (cAlias)->PRCVEN
	nAltPrd		:= (cAlias)->ALTPRD   
	nAltEmb		:= (cAlias)->ALTEMB   
	nProfPrd	:= (cAlias)->PROPRD   
	nProfEmb	:= (cAlias)->PROEMB   
	nLargPrd	:= (cAlias)->LARGPRD 
	nLargEmb	:= (cAlias)->LARGEMB
	
	//-----------------------
	// ID Produto eCommerce |
	//-----------------------
	nIdProd		:= (cAlias)->IDPROD   
	nIdSku		:= (cAlias)->IDSKU
					
	LogExec("ENVIANDO SKU " + Alltrim((cAlias)->CODSKU) + " - " + Alltrim((cAlias)->NOMESKU) )
		 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(cCodPai,cNomePrd,cCodSku,cNomeSku,cCodBar,cLocal,cUnidade,;
			cStatPrd,nCodMarca,nPeso,nPrcVen,nAltPrd,nAltEmb,nProfPrd,nProfEmb,;
			nLargPrd,nLargEmb,nIdProd,nIdSku,(cAlias)->RECNOSB5)
	
	(cAlias)->( dbSkip() )
				
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AEcoEnv
	@description	Rotina envia dados do SKU para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
	@type function
/*/
/**************************************************************************************************/
Static Function AEcoEnvM(	_cLojaID,_cUrl,_cAppKey,_cAppToken,cCodPai,cNomePrd,;
							cCodSku,cNomeSku,cCodBar,cLocal,cUnidade,cStatPrd,;
							nCodMarca,nPeso,nPrcVen,nAltPrd,nAltEmb,nProfPrd,nProfEmb,;
							nLargPrd,nLargEmb,nIdProd,nIdSku,nRecnoSb5)
						
Local aArea			:= GetArea()

Local cUrl			:= RTrim(_cUrl)
Local cUsrVTex		:= RTrim(_cAppKey)
Local cPswVTex		:= RTrim(_cAppToken)

Local nCubic		:= 0

Local oWsSku		:= Nil
Local _oDanaEcom 	:= Nil 

//------------------+
// Instancia Classe |
//------------------+
oWsSku 				:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsSku:_URL 		:= cUrl
oWsSku:_HEADOUT 	:= {}	

//--------------------------------------------+
// Adiciona Usuario e Senha para autenticação |
//--------------------------------------------+
aAdd(oWsSku:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )


//------------------------------+
// Calcula a Cubagem do Produto |
//------------------------------+
If nAltEmb > 0 .And. nProfEmb > 0 .And. nLargEmb > 0 
	nCubic := Round(nAltEmb * nProfEmb * nLargEmb,2) 
Else
	nCubic := Round(nAltPrd * nProfPrd * nLargPrd,2)
EndIf

//---------------------------+
// Adiciona dados do Produto |
//---------------------------+
oWsSku:oWSstockKeepingUnitVO:nCommercialConditionId	:= Nil
oWsSku:oWSstockKeepingUnitVO:nCostPrice				:= nPrcVen
oWsSku:oWSstockKeepingUnitVO:nCubicWeight          	:= nCubic
oWsSku:oWSstockKeepingUnitVO:cDateUpdated			:= Nil
oWsSku:oWSstockKeepingUnitVO:cEstimatedDateArrival	:= Nil
oWsSku:oWSstockKeepingUnitVO:nHeight				:= Iif( nAltEmb > 0, nAltEmb, nAltPrd )
oWsSku:oWSstockKeepingUnitVO:nId					:= Iif( nIdSku > 0, nIdSku, Nil)
oWsSku:oWSstockKeepingUnitVO:cInternalNote			:= Nil
oWsSku:oWSstockKeepingUnitVO:lIsActive				:= Iif(cStatPrd == "A",.T.,.F.)
oWsSku:oWSstockKeepingUnitVO:lIsAvaiable			:= .T.
oWsSku:oWSstockKeepingUnitVO:lIsKit					:= .F.
oWsSku:oWSstockKeepingUnitVO:nLength				:= Iif( nProfEmb > 0, nProfEmb, nProfPrd) 
oWsSku:oWSstockKeepingUnitVO:nListPrice				:= nPrcVen
oWsSku:oWSstockKeepingUnitVO:cManufacturerCode		:= Alltrim(Str(nCodMarca))
oWsSku:oWSstockKeepingUnitVO:cMeasurementUnit		:= cUnidade
oWsSku:oWSstockKeepingUnitVO:nModalId				:= 1
oWsSku:oWSstockKeepingUnitVO:cModalType				:= Nil
oWsSku:oWSstockKeepingUnitVO:cName					:= cNomeSku
oWsSku:oWSstockKeepingUnitVO:nPrice					:= nPrcVen
oWsSku:oWSstockKeepingUnitVO:nProductId				:= nIdProd
oWsSku:oWSstockKeepingUnitVO:cProductName			:= cNomePrd	
oWsSku:oWSstockKeepingUnitVO:nRealHeight			:= Nil
oWsSku:oWSstockKeepingUnitVO:nRealLength			:= Nil
oWsSku:oWSstockKeepingUnitVO:nRealWeightKg			:= nPeso
oWsSku:oWSstockKeepingUnitVO:nRealWidth				:= Nil
oWsSku:oWSstockKeepingUnitVO:cRefId					:= cCodSku
oWsSku:oWSstockKeepingUnitVO:nRewardValue			:= Nil
oWsSku:oWSstockKeepingUnitVO:nUnitMultiplier		:= 1
oWsSku:oWSstockKeepingUnitVO:nWeightKg				:= nPeso
oWsSku:oWSstockKeepingUnitVO:nWidth					:= Iif( nLargEmb > 0 , nLargEmb, nLargPrd)

If !Empty(cCodBar)
	//---------------------------+
	// Adiciona Codigo de Barras |
	//---------------------------+
	oWsSku:oWSstockKeepingUnitVO:oWSStockKeepingUnitEans := Service_ArrayOfStockKeepingUnitEanDTO():New()
	
	//-------------------------------------+
	// Cria Array para os Codigo de Barras |
	//-------------------------------------+
	aAdd(oWsSku:oWSstockKeepingUnitVO:oWSStockKeepingUnitEans:oWSStockKeepingUnitEanDTO, Service_StockKeepingUnitEanDTO():New())
	oWsSku:oWSstockKeepingUnitVO:oWSStockKeepingUnitEans:oWSStockKeepingUnitEanDTO[1]:cEan := cCodBar
EndIf

//------------------------+
// Realiza o envio do SKU |
//------------------------+
WsdlDbgLevel(3)
If oWsSku:StockKeepingUnitInsertUpdate(oWsSku:oWSstockKeepingUnitVO)
  
	If ValType(oWsSku:oWSStockKeepingUnitInsertUpdateResult) == "O"
	
		If oWsSku:oWSStockKeepingUnitInsertUpdateResult:nId > 0
			nIdSku 	:= oWsSku:oWSStockKeepingUnitInsertUpdateResult:nId
						
			//----------------+
			// Grava ID marca |
			//----------------+
			_oDanaEcom 			:= DanaEcom():New()
			_oDanaEcom:cLojaID	:= _cLojaID
			_oDanaEcom:cAlias	:= "SB1"
			_oDanaEcom:cCodErp	:= cCodSku
			_oDanaEcom:nID		:= nIdSku
			_oDanaEcom:GravaID()

			//---------------+
			// Posiciona SKU |
			//---------------+
			If nRecnoSb5 > 0
				SB5->( dbGoTo(nRecnoSb5) )
				RecLock("SB5",.F.)
					SB5->B5_XENVSKU := "2"
					SB5->B5_XENVECO := "2"
				SB5->( MsUnLock() )	
			EndIf

			LogExec("PRODUTO SKU " + cCodSku + " - " + Alltrim(cNomeSku) + " . ENVIADA COM SUCESSO.")
		EndIf	
	Else
		aAdd(aMsgErro,{cCodSku,"ERRO AO ENVIAR PRODUTO " + Alltrim(cCodSku) + " - " + Upper(Alltrim(cNomeSku)) + " "})
		LogExec("ERRO AO ENVIAR PRODUTO " + Alltrim(cCodSku) + " - " + Upper(Alltrim(cNomeSku)) + " " )
	EndIf	
Else
	aAdd(aMsgErro,{cCodSku,"ERRO AO ENVIAR PRODUTO " + Alltrim(cCodSku) + " - " + Upper(Alltrim(cNomeSku)) + " " + GetWSCError()})
	LogExec("ERRO AO ENVIAR PRODUTO " + Alltrim(cCodSku) + " - " + Upper(Alltrim(cNomeSku)) + " " + GetWSCError())
EndIf 

RestArea(aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AEcoEnv
	@description	Rotina envia dados do SKU para a plataforma e-commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		02/02/2016
	@type function
/*/
/**************************************************************************************************/
Static Function AEcoEnv(cCodPai,cNomePrd,cCodSku,cNomeSku,cCodBar,cLocal,cUnidade,;
						cStatPrd,nCodMarca,nPeso,nPrcVen,nAltPrd,nAltEmb,nProfPrd,nProfEmb,;
						nLargPrd,nLargEmb,nIdProd,nIdSku,nRecnoSb5)
						
Local aArea			:= GetArea()

Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")

Local nCubic		:= 0

Local oWsSku		:= Nil

//------------------+
// Instancia Classe |
//------------------+
oWsSku 				:= WSVTex():New() 

//---------------------+
// Parametros de Envio |
//---------------------+
oWsSku:_URL 		:= cUrl
oWsSku:_HEADOUT 	:= {}	

//--------------------------------------------+
// Adiciona Usuario e Senha para autenticação |
//--------------------------------------------+
aAdd(oWsSku:_HEADOUT, "Authorization: Basic " + Encode64(cUsrVTex + ":" + cPswVTex) )


//------------------------------+
// Calcula a Cubagem do Produto |
//------------------------------+
If nAltEmb > 0 .And. nProfEmb > 0 .And. nLargEmb > 0 
	nCubic := Round(nAltEmb * nProfEmb * nLargEmb,2) 
Else
	nCubic := Round(nAltPrd * nProfPrd * nLargPrd,2)
EndIf

//---------------------------+
// Adiciona dados do Produto |
//---------------------------+
oWsSku:oWSstockKeepingUnitVO:nCommercialConditionId	:= Nil
oWsSku:oWSstockKeepingUnitVO:nCostPrice				:= nPrcVen
oWsSku:oWSstockKeepingUnitVO:nCubicWeight          	:= nCubic
oWsSku:oWSstockKeepingUnitVO:cDateUpdated			:= Nil
oWsSku:oWSstockKeepingUnitVO:cEstimatedDateArrival	:= Nil
oWsSku:oWSstockKeepingUnitVO:nHeight				:= Iif( nAltEmb > 0, nAltEmb, nAltPrd )
oWsSku:oWSstockKeepingUnitVO:nId					:= Iif( nIdSku > 0, nIdSku, Nil)
oWsSku:oWSstockKeepingUnitVO:cInternalNote			:= Nil
oWsSku:oWSstockKeepingUnitVO:lIsActive				:= Iif(cStatPrd == "A",.T.,.F.)
oWsSku:oWSstockKeepingUnitVO:lIsAvaiable			:= .T.
oWsSku:oWSstockKeepingUnitVO:lIsKit					:= .F.
oWsSku:oWSstockKeepingUnitVO:nLength				:= Iif( nProfEmb > 0, nProfEmb, nProfPrd) 
oWsSku:oWSstockKeepingUnitVO:nListPrice				:= nPrcVen
oWsSku:oWSstockKeepingUnitVO:cManufacturerCode		:= Alltrim(Str(nCodMarca))
oWsSku:oWSstockKeepingUnitVO:cMeasurementUnit		:= cUnidade
oWsSku:oWSstockKeepingUnitVO:nModalId				:= 1
oWsSku:oWSstockKeepingUnitVO:cModalType				:= Nil
oWsSku:oWSstockKeepingUnitVO:cName					:= cNomeSku
oWsSku:oWSstockKeepingUnitVO:nPrice					:= nPrcVen
oWsSku:oWSstockKeepingUnitVO:nProductId				:= nIdProd
oWsSku:oWSstockKeepingUnitVO:cProductName			:= cNomePrd	
oWsSku:oWSstockKeepingUnitVO:nRealHeight			:= Nil
oWsSku:oWSstockKeepingUnitVO:nRealLength			:= Nil
oWsSku:oWSstockKeepingUnitVO:nRealWeightKg			:= nPeso
oWsSku:oWSstockKeepingUnitVO:nRealWidth				:= Nil
oWsSku:oWSstockKeepingUnitVO:cRefId					:= cCodSku
oWsSku:oWSstockKeepingUnitVO:nRewardValue			:= Nil
oWsSku:oWSstockKeepingUnitVO:nUnitMultiplier		:= 1
oWsSku:oWSstockKeepingUnitVO:nWeightKg				:= nPeso
oWsSku:oWSstockKeepingUnitVO:nWidth					:= Iif( nLargEmb > 0 , nLargEmb, nLargPrd)

If !Empty(cCodBar)
	//---------------------------+
	// Adiciona Codigo de Barras |
	//---------------------------+
	oWsSku:oWSstockKeepingUnitVO:oWSStockKeepingUnitEans := Service_ArrayOfStockKeepingUnitEanDTO():New()
	
	//-------------------------------------+
	// Cria Array para os Codigo de Barras |
	//-------------------------------------+
	aAdd(oWsSku:oWSstockKeepingUnitVO:oWSStockKeepingUnitEans:oWSStockKeepingUnitEanDTO, Service_StockKeepingUnitEanDTO():New())
	oWsSku:oWSstockKeepingUnitVO:oWSStockKeepingUnitEans:oWSStockKeepingUnitEanDTO[1]:cEan := cCodBar
EndIf

//------------------------+
// Realiza o envio do SKU |
//------------------------+
WsdlDbgLevel(3)
If oWsSku:StockKeepingUnitInsertUpdate(oWsSku:oWSstockKeepingUnitVO)
  
	If ValType(oWsSku:oWSStockKeepingUnitInsertUpdateResult) == "O"
	
		If oWsSku:oWSStockKeepingUnitInsertUpdateResult:nId > 0
			nIdSku 	:= oWsSku:oWSStockKeepingUnitInsertUpdateResult:nId
			//---------------+
			// Posiciona SKU |
			//---------------+
			If nRecnoSb5 > 0
				SB5->( dbGoTo(nRecnoSb5) )
				RecLock("SB5",.F.)
					SB5->B5_XENVSKU := "2"
					SB5->B5_XENVECO := "2"
					SB5->B5_XIDSKU	:= nIdSku
				SB5->( MsUnLock() )	
			EndIf
			LogExec("PRODUTO SKU " + cCodSku + " - " + Alltrim(cNomeSku) + " . ENVIADA COM SUCESSO.")
		EndIf	
	Else
		aAdd(aMsgErro,{cCodSku,"ERRO AO ENVIAR PRODUTO " + Alltrim(cCodSku) + " - " + Upper(Alltrim(cNomeSku)) + " "})
		LogExec("ERRO AO ENVIAR PRODUTO " + Alltrim(cCodSku) + " - " + Upper(Alltrim(cNomeSku)) + " " )
	EndIf	
Else
	aAdd(aMsgErro,{cCodSku,"ERRO AO ENVIAR PRODUTO " + Alltrim(cCodSku) + " - " + Upper(Alltrim(cNomeSku)) + " " + GetWSCError()})
	LogExec("ERRO AO ENVIAR PRODUTO " + Alltrim(cCodSku) + " - " + Upper(Alltrim(cNomeSku)) + " " + GetWSCError())
EndIf 

RestArea(aArea)
Return .T.

/*****************************************************************************************************/
/*/{Protheus.doc} AECOQRY
	@description 	Rotina consulta os produtos filhos (SKU) a serem enviados para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
	@return			lRet - Variavel Logica			
/*/
/******************************************************************************************************/
Static Function AEcoQry(cAlias,nToReg,_cLojaID)
Local cQuery 		:= ""

Local cCodTab		:= GetNewPar("EC_TABECO")

Default _cLojaID	:= ""

//-----------------------------+
// Query consulta produtos pai |
//-----------------------------+
cQuery := "	SELECT " + CRLF
cQuery += "		CODIGO, " + CRLF
cQuery += "		NOMEPAI, " + CRLF
cQuery += "		CODSKU, " + CRLF
cQuery += "		NOMESKU, " + CRLF
cQuery += "		CODBARRA, " + CRLF
cQuery += "		ARMAZEM, " + CRLF
cQuery += "		UNIDADE, " + CRLF
cQuery += "		PESOLIQ, " + CRLF
cQuery += "		PESOLIQP, " + CRLF
cQuery += "		PESOBRUP, " + CRLF
cQuery += "		ALTPRD, " + CRLF
cQuery += "		ALTEMB, " + CRLF
cQuery += "		PROPRD, " + CRLF
cQuery += "		PROEMB, " + CRLF
cQuery += "		LARGPRD, " + CRLF
cQuery += "		LARGEMB, " + CRLF  
cQuery += "		CODMARCA, " + CRLF
cQuery += "		IDPROD, " + CRLF
cQuery += "		IDSKU, " + CRLF
cQuery += "		STATUSPRD, " + CRLF
cQuery += "		PRCVEN,  " + CRLF
cQuery += "		RECNOSB5 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			B5.B5_COD CODIGO, " + CRLF
cQuery += "			B5.B5_XNOMPRD NOMEPAI, " + CRLF
cQuery += "			B5.B5_COD CODSKU, " + CRLF
cQuery += "			B1.B1_DESC NOMESKU, " + CRLF
cQuery += "			B1.B1_EAN CODBARRA, " + CRLF
cQuery += "			B1.B1_LOCPAD ARMAZEM, " + CRLF
cQuery += "			B1.B1_UM UNIDADE, " + CRLF
cQuery += "			B5.B5_PESO PESOLIQ, " + CRLF
cQuery += "			B1.B1_PESO PESOLIQP, " + CRLF
cQuery += "			B1.B1_PESBRU PESOBRUP, " + CRLF
cQuery += "			B5.B5_XALTPRD ALTPRD, " + CRLF
cQuery += "			B5.B5_XALTEMB ALTEMB, " + CRLF
cQuery += "			B5.B5_XPROPRD PROPRD, " + CRLF
cQuery += "			B5.B5_XPROEMB PROEMB, " + CRLF
cQuery += "			B5.B5_XLARPRD LARGPRD, " + CRLF
cQuery += "			B5.B5_XLAREMB LARGEMB, " + CRLF

If Empty(_cLojaID)
	cQuery += "			AY2.AY2_XIDMAR CODMARCA, " + CRLF
	cQuery += "			B5.B5_XIDPROD IDPROD, " + CRLF
	cQuery += "			B5.B5_XIDSKU IDSKU, " + CRLF
Else 
	cQuery += "			XTD_AY2.XTD_IDECOM CODMARCA, " + CRLF
	cQuery += "			XTD_SB5.XTD_IDECOM IDPROD, " + CRLF
	cQuery += "			ISNULL(XTD_SB1.XTD_IDECOM,0) IDSKU, " + CRLF
EndIf 

cQuery += "			B5.B5_STATUS STATUSPRD, " + CRLF
cQuery += "			ISNULL(DA1.DA1_PRCVEN,0) PRCVEN, " + CRLF  
cQuery += "			B5.R_E_C_N_O_ RECNOSB5 " + CRLF
cQuery += "		FROM " + CRLF 
cQuery += "			" + RetSqlName("SB5") + " B5 " + CRLF   
cQuery += "			INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = B5.B5_COD AND B1.B1_MSBLQL <> '1' AND B1.D_E_L_E_T_ = '' " + CRLF

If Empty(_cLojaID)
	cQuery += "			INNER JOIN " + RetSqlName("AY2") + " AY2 ON AY2.AY2_FILIAL = '" + xFilial("AY2") + "' AND AY2.AY2_CODIGO = B5.B5_XCODMAR AND AY2.D_E_L_E_T_ = '' " + CRLF
Else 
	cQuery += "			INNER JOIN " + RetSqlName("XTD") + " XTD_AY2 ON XTD_AY2.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD_AY2.XTD_ALIAS = 'AY2' AND XTD_AY2.XTD_CODIGO = '" + _cLojaID + "' AND XTD_AY2.XTD_CODERP = B5.B5_XCODMAR AND XTD_AY2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "			INNER JOIN " + RetSqlName("XTD") + " XTD_SB5 ON XTD_SB5.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD_SB5.XTD_ALIAS = 'SB5' AND XTD_SB5.XTD_CODIGO = '" + _cLojaID + "' AND XTD_SB5.XTD_CODERP = B5.B5_COD AND XTD_SB5.D_E_L_E_T_ = '' " + CRLF
	cQuery += "			LEFT JOIN " + RetSqlName("XTD") + " XTD_SB1 ON XTD_SB1.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD_SB1.XTD_ALIAS = 'SB1' AND XTD_SB1.XTD_CODIGO = '" + _cLojaID + "' AND XTD_SB1.XTD_CODERP = B5.B5_COD AND XTD_SB1.D_E_L_E_T_ = '' " + CRLF
EndIf 

cQuery += "			LEFT OUTER JOIN " + RetSqlName("DA1") + " DA1 ON DA1.DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1.DA1_CODTAB = '" + cCodTab + "' AND DA1.DA1_CODPRO = B1.B1_COD AND DA1.D_E_L_E_T_ = '' " + CRLF

cQuery += "		WHERE " + CRLF
cQuery += "			B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF  
cQuery += "			B5.B5_XUSAECO = 'S' AND " + CRLF
cQuery += "			B5.B5_XENVECO = '2' AND " + CRLF
cQuery += "			B5.B5_XENVSKU = '1' AND " + CRLF

If !Empty(_cLojaID)
	cQuery += "			B5.B5_XIDLOJA LIKE '%" + _cLojaID + "%' AND " + CRLF
EndIf 

cQuery += "			B5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "	) SKU " + CRLF
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
