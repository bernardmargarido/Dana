#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

//------------------------------+
// Estrutura de Retorno Produto |
//------------------------------+
WSSTRUCT STRURETPROD
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET  	AS STRING
	WSDATA WS_NPAGINI	AS INTEGER
	WSDATA WS_NPAGFIM	AS INTEGER
	WSDATA WS_ARRPROD 	AS ARRAY OF ARRAYPROD 
ENDWSSTRUCT

WSSTRUCT ARRAYPROD
	WSDATA WS_CODIGO 			AS STRING
	WSDATA WS_DESCRICAO			AS STRING
	WSDATA WS_UM				AS STRING
	WSDATA WS_ARMAZEM			AS STRING
	WSDATA WS_MARCA				AS STRING
	WSDATA WS_DESCMARCA			AS STRING
	WSDATA WS_MARCA_ID			AS INTEGER
	WSDATA WS_CATEGORIA			AS STRING
	WSDATA WS_DESCCATEG			AS STRING
	WSDATA WS_CATEGORIA_ID		AS INTEGER
	WSDATA WS_SUBCATEGORIA		AS STRING
	WSDATA WS_DESCSUBCATEG		AS STRING
	WSDATA WS_SUBCATEGORIA_ID	AS INTEGER
	WSDATA WS_VERSAO			AS STRING
	WSDATA WS_DESCVERSAO		AS STRING
	WSDATA WS_QTDCAIXA			AS INTEGER
	WSDATA WS_PRCCUSTO			AS FLOAT
	WSDATA WS_IDERP				AS INTEGER
ENDWSSTRUCT

//------------------------------------+
// Estrutura retorno saldo em estoque |
//------------------------------------+
WSSTRUCT STRURETEST
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET  	AS STRING
	WSDATA WS_ARREST 	AS ARRAY OF ARRAYEST
ENDWSSTRUCT	

WSSTRUCT ARRAYEST
	WSDATA WS_CODIGO 		AS STRING
	WSDATA WS_DESCRICAO		AS STRING
	WSDATA WS_SALDO			AS FLOAT
	WSDATA WS_IDERP			AS INTEGER
ENDWSSTRUCT
 

/**********************************************************************************/
/*/{Protheus.doc} DAWSI003

@description Webservice  - Produtos

@author Bernard M. Margarido

@since 07/08/2017
@version undefined

@type class
/*/
/**********************************************************************************/
WSSERVICE DAWSI003 DESCRIPTION "Servico renune metodos especificos Extranet - Dana."
	
	WSDATA WS_CODPROD	AS STRING
	WSDATA WS_PAGINA	AS INTEGER
	
	WSDATA WS_PRODRET	AS STRURETPROD
	WSDATA WS_ESTRET	AS STRURETEST
					
	//-------------------------+
	// Metodo Retorna Produtos |
	//-------------------------+	
	WSMETHOD WSRETPROD	 	DESCRIPTION "Metodo retorna dados para cadastro de produtos - Dana."
	
	//---------------------------------+
	// Metodo retorna saldo em estoque |
	//---------------------------------+
	WSMETHOD WSRETEST	 	DESCRIPTION "Metodo retorna saldo em estoque - Dana."
	
ENDWSSERVICE

/**********************************************************************************/
/*/{Protheus.doc} WS_RETPROD

@description Metodo consulta e retorna dados dos produtos

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSRETPROD WSRECEIVE WS_CODPROD,WS_PAGINA WSSEND WS_PRODRET WSSERVICE DAWSI003
Local aArea			:= GetArea()

Local cAlias		:= GetNextAlias()
Local cCodProd		:= ::WS_CODPROD

Local nTotPrd		:= 0
Local nPagIni		:= 0
Local nPagFim		:= 0
Local nTotPag		:= 0
Local nTotPags		:= 0
Local nPagLim		:= 500
Local nPagina		:= ::WS_PAGINA

Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSRETPROD_" + cEmpAnt + "_" + cFilAnt + ".LOG"

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI003 - CADASTRO PRODUTOS - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-----------------------+
// Paginacao de Produtos |
//-----------------------+
If Empty(cCodProd)
	
	//---------------------------+
	// Valida Total de Registros |
	//---------------------------+
	Qry03TPrd(@nTotPrd)
		
	//-----------------+
	// Primeira Pagina |
	//-----------------+
	If Empty(nPagina)
		nPagina := 1
	EndIf	
	
	//------------------+
	// Total de Paginas |
	//------------------+
	If nTotPrd <= nPagLim
		nTotPag := 1 
	Else
		nTotPag := VerNumPag(nPagLim,nTotPrd) 
	EndIf	
	
	//----------------+
	// Calcula Pagina |
	//----------------+
	If nPagina == 1
		nPagIni	:= 1
		nPagFim	:= nPagLim
	ElseIf nPagina > 1 .And. nPagina <= nTotPag
		nPagIni := (( nPagina * nPagLim ) + 1 ) - nPagLim
		nPagFim := nPagina * nPagLim  		
	EndIf
	
	//-----------+
	// Paginacao |
	//-----------+
	lPagina	:= .T.
Endif

//-------------------+
// Consulta usuarios |
//-------------------+
If !QRY03PROD(cAlias,cCodProd,nPagIni,nPagFim,lPagina)

	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	::WS_PRODRET:WS_RETURN 		:= "1"
	::WS_PRODRET:WS_DESRET 		:= "NAO EXISTEM DADOS A SEREM RETORNADOS"
	::WS_PRODRET:WS_NPAGINI		:= 0
	::WS_PRODRET:WS_NPAGFIM		:= 0
	
	aAdd(::WS_PRODRET:WS_ARRPROD,WSClassNew("ARRAYPROD"))
	
	::WS_PRODRET:WS_ARRPROD[1]:WS_CODIGO			:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_DESCRICAO			:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_UM				:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_ARMAZEM			:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_MARCA				:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_DESCMARCA			:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_MARCA_ID			:= 0
	::WS_PRODRET:WS_ARRPROD[1]:WS_CATEGORIA			:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_DESCCATEG			:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_CATEGORIA_ID		:= 0
	::WS_PRODRET:WS_ARRPROD[1]:WS_SUBCATEGORIA		:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_DESCSUBCATEG		:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_SUBCATEGORIA_ID	:= 0
	::WS_PRODRET:WS_ARRPROD[1]:WS_VERSAO			:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_DESCVERSAO		:= ""
	::WS_PRODRET:WS_ARRPROD[1]:WS_QTDCAIXA			:= 0
	::WS_PRODRET:WS_ARRPROD[1]:WS_PRCCUSTO			:= 0
	::WS_PRODRET:WS_ARRPROD[1]:WS_IDERP				:= 0
	
	(cAlias)->( dbCloseArea() )
	LogExec("NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf 

//------------------+
// Processa retorno | 
//------------------+
::WS_PRODRET:WS_RETURN 		:= "0"
::WS_PRODRET:WS_DESRET 		:= "ARQUIVO RETORNADO COM SUCESSO"
::WS_PRODRET:WS_NPAGINI		:= nPagina
::WS_PRODRET:WS_NPAGFIM		:= nTotPag
	
While (cAlias)->( !Eof() )
	
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	aAdd(::WS_PRODRET:WS_ARRPROD,WSClassNew("ARRAYPROD"))
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_CODIGO				:= Alltrim((cAlias)->B1_COD)
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_DESCRICAO			:= Alltrim((cAlias)->B1_DESC)
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_UM					:= (cAlias)->B1_UM
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_ARMAZEM			:= (cAlias)->B1_LOCPAD
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_MARCA				:= (cAlias)->B1_MARCEXT
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_DESCMARCA			:= Alltrim((cAlias)->MARCA)
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_MARCA_ID			:= (cAlias)->RECNOMARCA
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_CATEGORIA			:= (cAlias)->B1_CATEGO
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_DESCCATEG			:= (cAlias)->CATEGORIA
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_CATEGORIA_ID		:= (cAlias)->RECNOCATEG
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_SUBCATEGORIA		:= (cAlias)->B1_SUBCAT
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_DESCSUBCATEG		:= (cAlias)->SUBCATEGORIA
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_SUBCATEGORIA_ID	:= (cAlias)->RECNOSUBCAT
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_VERSAO				:= (cAlias)->B1_VERSAO
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_DESCVERSAO			:= (cAlias)->VERSAO
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_QTDCAIXA			:= (cAlias)->B1_QTDPCXA
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_PRCCUSTO			:= (cAlias)->PRCCUSTO
	::WS_PRODRET:WS_ARRPROD[Len(::WS_PRODRET:WS_ARRPROD)]:WS_IDERP				:= (cAlias)->RECNOSB1
	
	//-----------+
	// Grava LOG |
	//-----------+
	LogExec("ENVIANDO DADOS PRODUTOS " + Alltrim((cAlias)->B1_DESC) )
			
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB1->( dbGoTo((cAlias)->RECNOSB1) )
	RecLock("SB1",.F.)
		SB1->B1_MSEXP = dTos(Date())
	SB1->( MsUnLock() )
	
	(cAlias)->( dbSkip() )
EndDo 
 
(cAlias)->( dbCloseArea() )

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI003 - CADASTRO TRANSPORTADORA - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} WS_RETEST

@description Metodo retorna saldo em estoque do produto

@author Bernard M. Margarido

@since 28/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSRETEST WSRECEIVE WS_CODPROD WSSEND WS_ESTRET WSSERVICE DAWSI003
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cCodProd	:= ::WS_CODPROD

Local nSaldoB2	:= 0

Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSRETEST_" + cEmpAnt + "_" + cFilAnt + ".LOG"

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI003 - SALDOS EM ESTOQUE - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------+
// Consulta usuarios |
//-------------------+
If !QRY03EST(cAlias,cCodProd)

	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	::WS_ESTRET:WS_RETURN 		:= "1"
	::WS_ESTRET:WS_DESRET 		:= "NAO EXISTEM DADOS A SEREM RETORNADOS"
	
	aAdd(::WS_ESTRET:WS_ARREST,WSClassNew("ARRAYEST"))
	
	::WS_ESTRET:WS_ARREST[1]:WS_CODIGO		:= ""
	::WS_ESTRET:WS_ARREST[1]:WS_DESCRICAO	:= ""
	::WS_ESTRET:WS_ARREST[1]:WS_SALDO		:= 0
	::WS_ESTRET:WS_ARREST[1]:WS_IDERP		:= 0
	
	(cAlias)->( dbCloseArea() )
	LogExec("NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf 

//------------------+
// Processa retorno | 
//------------------+
::WS_ESTRET:WS_RETURN 		:= "0"
::WS_ESTRET:WS_DESRET 		:= "ARQUIVO RETORNADO COM SUCESSO"
	
While (cAlias)->( !Eof() )
	
	//-----------------+
	// Posiciona Saldo |
	//-----------------+
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB2->( dbGoTo((cAlias)->RECNOSB2) )
	RecLock("SB2",.F.)
		SB2->B2_MSEXP = dTos(Date())
	SB2->( MsUnLock() )
	
	//--------------------------+
	// Retorna saldo disponivel |
	//--------------------------+ 
	nSaldoB2 := SaldoSb2()
	
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	aAdd(::WS_ESTRET:WS_ARREST,WSClassNew("ARRAYEST"))
	::WS_ESTRET:WS_ARREST[Len(::WS_ESTRET:WS_ARREST)]:WS_CODIGO			:= Alltrim((cAlias)->B2_COD)
	::WS_ESTRET:WS_ARREST[Len(::WS_ESTRET:WS_ARREST)]:WS_DESCRICAO		:= Alltrim((cAlias)->B1_DESC)
	::WS_ESTRET:WS_ARREST[Len(::WS_ESTRET:WS_ARREST)]:WS_SALDO			:= nSaldoB2
	::WS_ESTRET:WS_ARREST[Len(::WS_ESTRET:WS_ARREST)]:WS_IDERP			:= (cAlias)->RECNOSB2
	
	//-----------+
	// Grava LOG |
	//-----------+
	LogExec("ENVIANDO DADOS PRODUTOS " + Alltrim((cAlias)->B1_DESC) )
	
	(cAlias)->( dbSkip() )
EndDo 
 
(cAlias)->( dbCloseArea() )

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI003 - SALDOS EM ESTOQUE - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} QRY03PROD

@description Consulta produtos a serem enviados 

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@param cAlias	, characters, descricao

@type function
/*/
/**********************************************************************************/
Static Function QRY03PROD(cAlias,cCodProd,nPagIni,nPagFim,lPagina)
Local aArea		:= GetArea()

Local cFilProd	:= GetNewPar("DA_FILPRD","05")
Local cQuery	:= ""

cQuery := "	SELECT * FROM ( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			ROW_NUMBER() OVER(ORDER BY B1.B1_COD) RNUM, " + CRLF
cQuery += "			B1.B1_COD B1_COD, " + CRLF
cQuery += "			B1.B1_DESC, " + CRLF
cQuery += "			B1.B1_UM, " + CRLF
cQuery += "			B1.B1_LOCPAD, " + CRLF
cQuery += "			B1.B1_MARCEXT, " + CRLF
cQuery += "			ISNULL(ZK.ZK_DESC,'') MARCA, " + CRLF
cQuery += "			ISNULL(ZK.R_E_C_N_O_,0) RECNOMARCA, " + CRLF
cQuery += "			B1.B1_CATEGO, " + CRLF
cQuery += "			ISNULL(ZL.ZL_DESC,'')  CATEGORIA, " + CRLF
cQuery += "			ISNULL(ZL.R_E_C_N_O_,0)  RECNOCATEG, " + CRLF
cQuery += "			B1.B1_SUBCAT, " + CRLF
cQuery += "			ISNULL(ZM.ZM_DESC,'') SUBCATEGORIA, " + CRLF
cQuery += "			ISNULL(ZM.R_E_C_N_O_,0) RECNOSUBCAT, " + CRLF
cQuery += "			B1.B1_VERSAO, " + CRLF
cQuery += "			ISNULL(B2.B2_CM1,0) PRCCUSTO, " + CRLF
cQuery += "			ISNULL(ZR.ZR_DESC,'') VERSAO, " + CRLF
cQuery += "			B1.B1_QTDPCXA, " + CRLF
cQuery += "			B1.R_E_C_N_O_ RECNOSB1 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SB1") + " B1 " + CRLF 
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SZK") + " ZK ON ZK.ZK_FILIAL = '" + xFilial("SZK") + "' AND ZK.ZK_CODIGO = B1.B1_MARCEXT AND ZK.D_E_L_E_T_ = '' " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SZL") + " ZL ON ZL.ZL_FILIAL = '" + xFilial("SZK") + "' AND ZL.ZL_CODIGO = B1.B1_CATEGO AND ZL.D_E_L_E_T_ = '' " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SZM") + " ZM ON ZM.ZM_FILIAL = '" + xFilial("SZK") + "' AND ZM.ZM_CODIGO = B1.B1_SUBCAT AND ZM.D_E_L_E_T_ = '' " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SZR") + " ZR ON ZR.ZR_FILIAL = '" + xFilial("SZK") + "' AND ZR.ZR_CODIGO = B1.B1_VERSAO AND ZR.D_E_L_E_T_ = '' " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SB2") + " B2 ON B2.B2_FILIAL = '" + xFilial("SB2") + "' AND B2.B2_COD = B1.B1_COD AND B2.B2_LOCAL = B1.B1_LOCPAD AND B2.D_E_L_E_T_ = '' " + CRLF
cQuery += "		WHERE " + CRLF
cQuery += "			B1.B1_FILIAL = '" + cFilProd + "' AND " + CRLF
If !Empty(cCodProd)
	cQuery += "			B1.B1_COD = '" + cCodProd + "' AND " + CRLF
Else	
	cQuery += "			B1.B1_MSBLQL <> '1' AND " + CRLF
EndIf 
cQuery += "			B1.D_E_L_E_T_ = '' " + CRLF
cQuery += "	) PAGPRD " + CRLF
cQuery += "	WHERE " + CRLF
If !lPagina
	cQuery += "	RNUM BETWEEN 1 AND 1 " + CRLF
Else
	cQuery += "	RNUM BETWEEN " + Alltrim(Str(nPagIni)) + " AND " + Alltrim(Str(nPagFim)) + " " + CRLF
EndIf	 
cQuery += "	ORDER BY B1_COD "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return .F.
EndIf

RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} Qry03TPrd

@description Consulta total de produtos 

@author Bernard M. Margarido

@since 19/10/2017
@version undefined

@param nTotCli	, numeric, descricao
@type function
/*/
/**********************************************************************************/
Static Function Qry03TPrd(nTotCli)
Local aArea		:= GetArea()

Local cAliasTot	:= GetNextAlias()
Local cFilProd	:= GetNewPar("DA_FILPRD","05")
Local cQuery	:= ""

cQuery := "	SELECT " + CRLF
cQuery += "		COUNT(B1.B1_COD) NTOTAL " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SB1") + " B1 " + CRLF 
cQuery += "		LEFT OUTER JOIN " + RetSqlName("SZK") + " ZK ON ZK.ZK_FILIAL = '" + xFilial("SZK") + "' AND ZK.ZK_CODIGO = B1.B1_MARCEXT AND ZK.D_E_L_E_T_ = '' " + CRLF
cQuery += "		LEFT OUTER JOIN " + RetSqlName("SZL") + " ZL ON ZL.ZL_FILIAL = '" + xFilial("SZK") + "' AND ZL.ZL_CODIGO = B1.B1_CATEGO AND ZL.D_E_L_E_T_ = '' " + CRLF
cQuery += "		LEFT OUTER JOIN " + RetSqlName("SZM") + " ZM ON ZM.ZM_FILIAL = '" + xFilial("SZK") + "' AND ZM.ZM_CODIGO = B1.B1_SUBCAT AND ZM.D_E_L_E_T_ = '' " + CRLF
cQuery += "		LEFT OUTER JOIN " + RetSqlName("SZR") + " ZR ON ZR.ZR_FILIAL = '" + xFilial("SZK") + "' AND ZR.ZR_CODIGO = B1.B1_VERSAO AND ZR.D_E_L_E_T_ = '' " + CRLF
cQuery += "		LEFT OUTER JOIN " + RetSqlName("SB2") + " B2 ON B2.B2_FILIAL = '" + xFilial("SB2") + "' AND B2.B2_COD = B1.B1_COD AND B2.B2_LOCAL = B1.B1_LOCPAD AND B2.D_E_L_E_T_ = '' " + CRLF
cQuery += "	WHERE " + CRLF
cQuery += "		B1.B1_FILIAL = '" + cFilProd + "' AND " + CRLF
cQuery += "		B1.B1_MSBLQL <> '1' AND " + CRLF
cQuery += "		B1.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTot,.T.,.T.)

nTotCli := (cAliasTot)->NTOTAL

(cAliasTot)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} QRY03EST

@description Consulta saldos em estoque a serem enviados 

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@param cAlias	, characters, descricao

@type function
/*/
/**********************************************************************************/
Static Function QRY03EST(cAlias,cCodProd)
Local aArea		:= GetArea()

Local cFilEst	:= GetNewPar("DA_FILPRD","04")
Local cFilArmz	:= GetNewPar("DA_FILAMZ","15")
Local cQuery	:= ""

cQuery := "	SELECT " + CRLF
cQuery += "		B2.B2_COD, " + CRLF
cQuery += "		B1.B1_DESC, " + CRLF
cQuery += "		B2.R_E_C_N_O_ RECNOSB2 " + CRLF 
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SB2") + " B2 " + CRLF  
cQuery += "		INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = B2.B2_COD AND B2.D_E_L_E_T_ = '' " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		B2.B2_FILIAL = '" + cFilEst + "' AND " + CRLF 
If !Empty(cCodProd)
	cQuery += "		B2.B2_COD = '" + cCodProd + "' AND " + CRLF
Else
	cQuery += "		B2.B2_MSEXP = '' AND " + CRLF
EndIf	
cQuery += "		B2.B2_LOCAL = '" + cFilArmz + "' AND " + CRLF 
cQuery += "		B2.D_E_L_E_T_ = '' " + CRLF
cQuery += "	ORDER BY B2.B2_COD " 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	RestArea(aArea)
	Return .F.
EndIf

RestArea(aArea)
Return .T.

/*******************************************************************************/
/*/{Protheus.doc} VerNumPag

@description Calcula total de paginas 

@author Bernard M. Margarido

@since 19/10/2017
@version undefined

@param nPagLim	, numeric, descricao
@param nToReg	, numeric, descricao

@type function
/*/
/*******************************************************************************/
Static Function VerNumPag(nPagLim,nToReg)
Local aArea		:= GetArea()
Local nPagina	:= 0

If Mod(nPagLim,nToReg) <> 0
	nPagina := Int( nToreg / nPagLim ) + 1
Else
	nPagina := ( nToreg / nPagLim ) 
EndIf
	
RestArea(aArea)
Return nPagina

/*************************************************************************************/
/*/{Protheus.doc} LogExec

@description Grava log de integração

@author TOTVS
@since 05/06/2017
@version undefined

@param cMsg, characters, descricao

@type function
/*/
/*************************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.
