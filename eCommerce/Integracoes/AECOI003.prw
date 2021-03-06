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
Local aArea		:= GetArea()

Private cThread	:= Alltrim(Str(ThreadId()))
Private cStaLog	:= "0"
Private cArqLog	:= ""	

Private nQtdInt	:= 0

Private cHrIni	:= Time()
Private dDtaInt	:= Date()

Private aMsgErro:= {}
Private aPrdEnv	:= {}

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

//---------------------------------------+
// Inicia processo de envio dos produtos |
//---------------------------------------+
Processa({|| AECOINT03() },"Aguarde...","Consultando Produtos.")
Processa({|| U_AECOI03A()},"Aguarde...","Enviando especificações")

LogExec("FINALIZA INTEGRACAO DE PRODUTOS COM A VTEX - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
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
Static Function AEcoQry(cAlias,nToReg)
Local cQuery := ""

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
cQuery += "			ISNULL(AY2.AY2_XIDMAR,0) CODMARCA, " + CRLF 
cQuery += "			B5.B5_XNOMPRD NOME, " + CRLF
cQuery += "			B5.B5_XTITULO TIUTLO, " + CRLF
cQuery += "			B5.B5_XSUBTIT SUBTITULO, " + CRLF
cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT01 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO01, " + CRLF   
cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT02 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO02, " + CRLF  
cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT03 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO03, " + CRLF 
cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT04 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO04, " + CRLF 
cQuery += "			ISNULL((SELECT AY0.AY0_XIDCAT FROM " + RetSqlName("AY0") + " AY0 WHERE AY0.AY0_FILIAL = '" + xFilial("AY0") + "' AND AY0.AY0_CODIGO = B5.B5_XCAT05 AND AY0.D_E_L_E_T_ = '' ),0) CATEGO05, " + CRLF 
cQuery += "			B5.B5_XIDPROD IDPROD, " + CRLF
cQuery += "			B5.B5_XIDLOJA IDLOJA, " + CRLF
cQuery += "			ISNULL(CAST(CAST(B5.B5_XDESCRI AS BINARY(2048)) AS VARCHAR(2048)),'') DESCECO, " + CRLF 
cQuery += "			ISNULL(CAST(CAST(B5.B5_XCARACT AS BINARY(2048)) AS VARCHAR(2048)),'') DESCCARA, " + CRLF
cQuery += "			ISNULL(CAST(CAST(B5.B5_XKEYWOR AS BINARY(2048)) AS VARCHAR(2048)),'') KEYWORDS, " + CRLF
cQuery += "			B5.B5_XSTAPRD STATUSPRD, " + CRLF
cQuery += "			B5.B5_XTPPROD TPPROD, " + CRLF
cQuery += "			B5.R_E_C_N_O_ RECNOB5 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SB5") + " B5 " + CRLF 
cQuery += "			LEFT OUTER JOIN " + RetSqlName("AY2") + " AY2 ON AY2.AY2_FILIAL = '" + xFilial("AY2") + "' AND AY2.AY2_CODIGO = B5.B5_XCODMAR AND AY2.D_E_L_E_T_ = '' " + CRLF
cQuery += "		WHERE " + CRLF
cQuery += "			B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF  
cQuery += "			B5.B5_XENVECO = '1' AND " + CRLF
cQuery += "			B5.B5_XENVSKU = '1' AND " + CRLF
cQuery += "			B5.B5_XUSAECO = 'S' AND " + CRLF
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