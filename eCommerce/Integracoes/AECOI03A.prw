#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "03A"
Static cDescInt	:= "PRODUTOS"
Static cDirImp	:= "/ecommerce/"

/*******************************************************************************************/
/*/{Protheus.doc} AECOI03A
	@description Envia as Especificações 
	@author Bernard M. Margarido
	@since 22/01/2018
	@version 1.0
	@type function
/*/
/*******************************************************************************************/
User Function AECOI03A()

Private cThread		:= Alltrim(Str(ThreadId()))
Private cStaLog		:= "0"
Private cArqLog		:= ""	

Private nQtdInt		:= 0

Private cHrIni		:= Time()
Private dDtaInt		:= Date()

Private aMsgErro	:= {}

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
cArqLog := cDirImp + "ESPECIFICACAO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO ESPECIFICACAO DE PRODUTOS COM A VTEX - DATA/HORA: "+DTOC( DATE() )+" AS "+TIME())

If _lMultLj
	_oProcess:= MsNewProcess():New( {|_lEnd| AECMULT03A(@_lEnd)},"Aguarde...","Consultando Produtos" )
	_oProcess:Activate()
Else 
	//---------------------------------------+
	// Inicia processo de envio dos produtos |
	//---------------------------------------+
	Processa({|| AECOINT3A() },"Aguarde...","Consultando Produtos.")
EndIf 

LogExec("FINALIZA INTEGRACAO ESPECIFICACAO DE PRODUTOS COM A VTEX - DATA/HORA: "+DTOC( DATE() )+" AS "+TIME())
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
/*/{Protheus.doc} AECMULT03A
	@description Multi Lojas e-Commerce
	@author Bernard M. Margarido
	@since 17/05/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************************/
Static Function AECMULT03A(_lEnd)
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

		//--------------------------------+
		// Envia as categorias multi loja |
		//--------------------------------+
		AECOINT3AM(XTC->XTC_CODIGO,XTC->XTC_URL,XTC->XTC_URL2,XTC->XTC_APPKEY,XTC->XTC_APPTOK)

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
/*/{Protheus.doc} AECOINT3A
	@description	Rotina consulta e envia Produtos para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT3AM(_cLojaID,_cUrl,_cUrl_2,_cAppKey,_cAppToken)
Local aArea			:= GetArea()

Local cCodPai 		:= ""
Local cNomePrd		:= ""
Local cCampo		:= ""

Local cAlias		:= GetNextAlias()

Local nIdProd		:= 0
Local nToReg		:= 0

//---------------------------------------------+
// Valida se existem produtos a serem enviadas |
//---------------------------------------------+
If !AEcoQry(cAlias,@nToReg,_cLojaID)
	aAdd(aMsgErro,{"03A","NAO EXISTEM REGISTROS PARA SEREM ENVIADOS."})  
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
	nIdProd		:= (cAlias)->IDPROD
	cCampo		:= RTrim((cAlias)->NOME_CAMPO)
	cDesCampo	:= (cAlias)->DESC_ESPE
	
	LogExec("ENVIANDO ESPECIFICACAO PRODUTO " + Alltrim((cAlias)->CODIGO) + " - " + Alltrim((cAlias)->NOME) )
		 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(cCodPai,cNomePrd,nIdProd,cCampo,cDesCampo,_cLojaID,_cUrl,_cAppKey,_cAppToken)
	
	(cAlias)->( dbSkip() )
				
EndDo

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT3A
	@description	Rotina consulta e envia Produtos para a pataforma e-Commerce
	@author			Bernard M.Margarido
	@version   		1.00
	@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT3A()
Local aArea			:= GetArea()

Local cCodPai 		:= ""
Local cNomePrd		:= ""
Local cCampo		:= ""

Local cAlias		:= GetNextAlias()

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
	nIdProd		:= (cAlias)->IDPROD
	cCampo		:= RTrim((cAlias)->NOME_CAMPO)
	cDesCampo	:= (cAlias)->DESC_ESPE
	
	LogExec("ENVIANDO ESPECIFICACAO PRODUTO " + Alltrim((cAlias)->CODIGO) + " - " + Alltrim((cAlias)->NOME) )
		 
	//---------------------------------------+
	// Rotina realiza o envio para a Rakuten |
	//---------------------------------------+
	AEcoEnv(cCodPai,cNomePrd,nIdProd,cCampo,cDesCampo)
	
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
Static Function AEcoEnv(cCodPai,cNomePrd,nIdProd,cCampo,cDesCampo,_cLojaID,_cUrl,_cAppKey,_cAppToken)
						
Local aArea			:= GetArea()

Local cUrl			:= GetNewPar("EC_URLECOM")
Local cUsrVTex		:= GetNewPar("EC_USRVTEX")
Local cPswVTex		:= GetNewPar("EC_PSWVTEX")

Local oWsProd		:= Nil

Default _cLojaID	:= ""
Default _cUrl		:= ""
Default _cAppKey	:= ""
Default _cAppToken	:= ""

cUrl				:= RTrim(IIF(Empty(_cUrl), GetNewPar("EC_URLECOM"), _cUrl))
cUsrVTex			:= RTrim(IIF(Empty(_cAppKey), GetNewPar("EC_USRVTEX"), _cAppKey))
cPswVTex			:= RTrim(IIF(Empty(_cAppToken), GetNewPar("EC_PSWVTEX"), _cAppToken))

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

//---------------------------+
// Adiciona dados do Produto |
//---------------------------+
oWsProd:nIdProduct	:= nIdProd
oWsProd:cFieldName	:= cCampo

//--------------------------+
// Adiciona Canal de Vendas |
//--------------------------+
oWsProd:oWSfieldValues := Service_ArrayOfstring():New()

//------------------------------------+
// Cria Array para os Canais de Venda |
//------------------------------------+
oWsProd:oWSfieldValues:cString := {}
               

aAdd(oWsProd:oWSfieldValues:cString,cDesCampo) 
	

LogExec("ENVIANDO ESPECIFICACAO PRODUTO " + cCodPai + " - " + Alltrim(cNomePrd) + " ." )

WsdlDbgLevel(3)
If oWsProd:ProductEspecificationInsert()  
	LogExec("ESPECIFICACAO PRODUTO " + cCodPai + " - " + Alltrim(cNomePrd) + " . ENVIADA COM SUCESSO." )
Else
	aAdd(aMsgErro,{cCodPai,"ERRO AO ENVIAR ESPECIFICACAO PRODUTO " + Alltrim(cCodPai) + " - " + Upper(Alltrim(cNomePrd)) + " " + Alltrim(GetWscError()) + CRLF})
	LogExec("ERRO AO ENVIAR ESPECIFICACAO PRODUTO " + cCodPai + " - " + cNomePrd + " . " + GetWSCError() )
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
cQuery += "    	NOME, " + CRLF
cQuery += "    	IDPROD, " + CRLF     
cQuery += "    	COD_CAMPO, " + CRLF
cQuery += "		NOME_CAMPO, " + CRLF
cQuery += "		DESC_ESPE, " + CRLF
cQuery += "    	RECNOB5 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF 
cQuery += "			B5.B5_COD CODIGO, " + CRLF 
cQuery += "			B5.B5_XNOMPRD NOME, " + CRLF

If Empty(_cLojaID)
	cQuery += "			B5.B5_XIDPROD IDPROD, " + CRLF
Else 
	cQuery += "			XTD.XTD_IDECOM IDPROD, " + CRLF
EndIf 

cQuery += "			WS6.WS6_CODIGO COD_CAMPO, " + CRLF     
cQuery += "			WS6.WS6_CAMPO NOME_CAMPO, " + CRLF     
cQuery += "			COALESCE(CAST(CAST(WS6.WS6_DESCEC AS BINARY(8000)) AS VARCHAR(8000)),'') DESC_ESPE, " + CRLF 
cQuery += "			B5.R_E_C_N_O_ RECNOB5 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SB5") + " B5 " + CRLF 
cQuery += "			INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = B5.B5_COD AND B1.D_E_L_E_T_ = '' " + CRLF
cQuery += "			INNER JOIN " + RetSqlName("WS6") + " WS6 ON WS6.WS6_FILIAL = '" + xFilial("WS6") + "' AND WS6.WS6_CODPRD = B5.B5_COD AND WS6.WS6_ENVECO = '1' AND WS6.D_E_L_E_T_ = ''  " + CRLF    

If !Empty(_cLojaID)
	cQuery += "			INNER JOIN " + RetSqlName("XTD") + " XTD ON XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND XTD.XTD_ALIAS = 'SB5' AND XTD.XTD_CODIGO = '" + _cLojaID + "' AND XTD.XTD_CODERP = B5.B5_COD AND XTD.D_E_L_E_T_ = '' " + CRLF
EndIf 

cQuery += "		WHERE " + CRLF
cQuery += "			B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF  
cQuery += "			B5.B5_XENVECO = '2' AND " + CRLF
cQuery += "			B5.B5_XUSAECO = 'S' AND " + CRLF

If !Empty(_cLojaID)
	cQuery += "			B5.B5_XIDLOJA LIKE '%" + _cLojaID + "%' AND " + CRLF
EndIf 

cQuery += "			B5.D_E_L_E_T_ = '' " + CRLF
cQuery += "	) CAMPOS_ESPECIFICOS " + CRLF
cQuery += "	ORDER BY CODIGO "

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
	@type function
/*/
/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.
