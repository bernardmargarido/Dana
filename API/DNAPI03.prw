#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "003"
Static cDescInt	:= "PRODUTOS"
Static cDirRaiz := "\wms\"

/************************************************************************************/
/*/{Protheus.doc} PRODUTOS

@description API - Envia dados dos produtos 

@author Bernard M. Margarido
@since 26/10/2018
@version 1.0

@type class
/*/
/************************************************************************************/
WSRESTFUL PRODUTOS DESCRIPTION " Servico Perfumes Dana - Retorna dados dos produtos."
	
	WSDATA CODPRODUTO 	AS STRING	
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET DESCRIPTION "Retorna dados dos Produtos. " WSSYNTAX "/API/PRODUTOS{cnpj_cpf}/datahora{Data Hora da ultima Atualização}"

END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET

@description Retorna string JSON com os dados dos Produtos

@author Bernard M. Margarido
@since 26/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE CODPRODUTO,DATAHORA,PERPAGE,PAGE WSSERVICE PRODUTOS
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cCodProd		:= IIF(Empty(::CODPRODUTO),"",::CODPRODUTO)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE
Local cFilAux		:= cFilAnt

Local nLen			:= Len(::aUrlParms)

Private cArqLog		:= ""
Private _lSB1Comp 	:= ( FWModeAccess("SB1",3) == "C" )
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "PRODUTOS" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DOS PRODUTOS WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//---------------------+
// Gera novo orçamento |
//---------------------+
aRet := DnaApi03A(cCodProd,cDataHora,cTamPage,cPage) 

//----------------+
// Retorno da API |
//----------------+
If aRet[1]
	::SetResponse(aRet[2])
	HTTPSetStatus(200,"OK")
Else
	::SetResponse(aRet[2])
	SetRestFault(400,aRet[2],.T.)
EndIf	

LogExec("FINALIZA ENVIO DOS PRODUTOS WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi03A

@description Consulta produtos e monta arquivo e envio

@author Bernard M. Margarido
@since 24/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApi03A(cCodProd,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}
Local aCarac	:= {}

Local cAlias	:= GetNextAlias()	
Local cRest		:= ""

Local oJson		:= Nil
Local oProduto	:= Nil
Local oPagina	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "50" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cCodProd,cDataHora,cTamPage,cPage)
	
	oJson			:= Array(#)
	oJson[#"error"]	:= {}
	
	aAdd(oJson[#"error"],Array(#))
	oProduto := aTail(oJson[#"error"])
	oProduto[#"msg"] := "Nao existem dados para serem retornados."
	
	//---------------------------+
	// Transforma Objeto em JSON |
	//---------------------------+
	cRest := xToJson(oJson)	
	
	aRet[1] := .F.
	aRet[2] := EncodeUtf8(cRest)
		
	RestArea(aArea)
	Return aRet
EndIf

//--------------------------+
// Inicaliza Matriz HashMap |
//--------------------------+
oJson				:= Array(#)
oJson[#"produtos"]	:= {}

While (cAlias)->( !Eof() )
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"produtos"],Array(#))
	oProduto := aTail(oJson[#"produtos"])
	
	//------------------+
	// Dados do Produto |
	//------------------+
	oProduto[#"filial"] 			:= (cAlias)->FILIAL
	oProduto[#"codido_produto"] 	:= (cAlias)->PRODUTO
	oProduto[#"codigo_barras"] 		:= (cAlias)->CODBARRAS
	oProduto[#"descricao"] 			:= (cAlias)->DESCRICAO
	oProduto[#"grupo"] 				:= (cAlias)->GRUPO
	oProduto[#"descri_grupo"]		:= (cAlias)->DESCGRUPO
	oProduto[#"tipo"] 				:= (cAlias)->TIPO
	oProduto[#"descri_tipo"]		:= (cAlias)->DESCTIPO
	oProduto[#"unidade01"]			:= (cAlias)->UNIDADE1
	oProduto[#"unidade02"]			:= (cAlias)->UNIDADE2
	oProduto[#"fator_conversao"]	:= (cAlias)->FATOR
	oProduto[#"tipo_fator"]			:= IIF((cAlias)->TPFATOR == "D","Divisor","Multiplicador")
	oProduto[#"qtd_caixa"]			:= (cAlias)->QTDCAIXA
	oProduto[#"utiliza_lote"]		:= IIF((cAlias)->LOTE == "L","Sim","Não")
	oProduto[#"peso_liquido"]		:= (cAlias)->PESO_LIQUIDO
	oProduto[#"peso_bruto"]			:= (cAlias)->PESO_BRUTO
	
	(cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
oJson[#"pagina"]								:= Array(#)
oJson[#"pagina"][#"total_produtos_pagina"]		:= Val(cTamPage)
oJson[#"pagina"][#"total_produtos"]				:= nTotQry
oJson[#"pagina"][#"total_paginas"]				:= nTotPag
oJson[#"pagina"][#"pagina_atual"]				:= Val(cPage)

//--------------------+
// Encerra temporario |
//--------------------+
(cAlias)->( dbCloseArea() )

//---------------------------+
// Transforma Objeto em JSON |
//---------------------------+
cRest := xToJson(oJson)	

aRet[1] := .T.
aRet[2] := EncodeUtf8(cRest)

RestArea(aArea)
Return aRet 

/************************************************************************************/
/*/{Protheus.doc} DnaApiQry

@description Consulta produtos para serem enviados 

@author Bernard M. Margarido
@since 24/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApiQry(cAlias,cCodProd,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//---------------------------+
// Cosulta total de produtos | 
//---------------------------+
If !DnaQryTot(cCodProd,cDataHora,cTamPage,cPage)
	Return .F.
Endif

cQuery := "	SELECT " + CRLF
cQuery += "		TOP(" + cTamPage + ") RNUM, " + CRLF
cQuery += "		FILIAL, " + CRLF
cQuery += "		PRODUTO, " + CRLF
cQuery += "		CODBARRAS, " + CRLF
cQuery += "		DESCRICAO, " + CRLF
cQuery += "		GRUPO, " + CRLF
cQuery += "		DESCGRUPO, " + CRLF
cQuery += "		TIPO, " + CRLF
cQuery += "		DESCTIPO, " + CRLF
cQuery += "		UNIDADE1, " + CRLF
cQuery += "		UNIDADE2, " + CRLF
cQuery += "		FATOR, " + CRLF
cQuery += "		TPFATOR, " + CRLF
cQuery += "		QTDCAIXA, " + CRLF
cQuery += "		LOTE, " + CRLF
cQuery += "		PESO_LIQUIDO, " + CRLF
cQuery += "		PESO_BRUTO " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF 
cQuery += "			ROW_NUMBER() OVER(ORDER BY B1.B1_COD) RNUM, " + CRLF 
cQuery += "			B1.B1_FILIAL FILIAL, " + CRLF
cQuery += "			B1.B1_COD PRODUTO, " + CRLF
cQuery += "			B1.B1_CODBAR CODBARRAS, " + CRLF
cQuery += "			B1.B1_DESC DESCRICAO, " + CRLF
cQuery += "			B1.B1_GRUPO GRUPO, " + CRLF
cQuery += "			ISNULL(BM.BM_DESC,'') DESCGRUPO, " + CRLF
cQuery += "			B1.B1_TIPO TIPO, " + CRLF
cQuery += "			ISNULL(X5.X5_DESCRI,'') DESCTIPO, " + CRLF
cQuery += "			B1.B1_UM UNIDADE1, " + CRLF
cQuery += "			B1.B1_SEGUM UNIDADE2, " + CRLF
cQuery += "			B1.B1_CONV FATOR, " + CRLF
cQuery += "			B1.B1_TIPCONV TPFATOR, " + CRLF
cQuery += "			B1.B1_QTDPCXA QTDCAIXA, " + CRLF
cQuery += "			B1.B1_RASTRO LOTE, " + CRLF
cQuery += "			B1_PESO PESO_LIQUIDO, " + CRLF
cQuery += "			B1_PESBRU PESO_BRUTO " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SB1") + " B1 " + CRLF  
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SBM") + " BM ON BM.BM_FILIAL = '" + xFilial("SBM") + "' AND BM.BM_GRUPO = B1.B1_GRUPO AND BM.D_E_L_E_T_ = '' " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SX5") + " X5 ON X5.X5_TABELA = '02' AND X5.X5_CHAVE = B1.B1_TIPO AND X5.D_E_L_E_T_ = '' " + CRLF
cQuery += "		WHERE " + CRLF

If _lSB1Comp
	cQuery += "			B1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
Else
	cQuery += "			B1.B1_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cCodProd)
	cQuery += "			CAST((B1.B1_XDTALT + ' ' + B1.B1_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((B1.B1_XDTALT + ' ' + B1.B1_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "			B1.B1_COD = '" + cCodProd + "' AND " + CRLF
EndIf 
cQuery += "		B1.B1_MSBLQL IN(' ','2') AND " + CRLF
cQuery += "		B1.D_E_L_E_T_ = '' " + CRLF	
cQuery += "	) PRODUTOS " + CRLF
cQuery += "	WHERE RNUM > " + cTamPage + " * (" + cPage + " - 1) " + CRLF
cQuery += "	ORDER BY FILIAL,PRODUTO "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	LogExec("NAO EXISTEM DADOS PARA SEREM ENVIADOS.")
	(cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ApiQryTot

@description Retorna total de clientes 

@author Bernard M. Margarido
@since 24/10/2018
@version 1.0

@param cCodProd		, characters, descricao
@param cDataHora	, characters, descricao
@param cTamPage		, characters, descricao
@param cPage		, characters, descricao
@param nTotPag		, numeric, descricao
@param nTotQry		, numeric, descricao
@type function
/*/
/*************************************************************************************/
Static Function DnaQryTot(cCodProd,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

Local nTotReg	:= 0

//------------------------------------+
// reseta variaveis totais por pagina |
//------------------------------------+
nTotPag := 0
nTotQry := 0

cQuery := "	SELECT " + CRLF
cQuery += "		COUNT(B1.B1_COD) TOTREG " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "			" + RetSqlName("SB1") + " B1 " + CRLF  
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SBM") + " BM ON BM.BM_FILIAL = '" + xFilial("SBM") + "' AND BM.BM_GRUPO = B1.B1_GRUPO AND BM.D_E_L_E_T_ = '' " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SX5") + " X5 ON X5.X5_TABELA = '02' AND X5.X5_CHAVE = B1.B1_TIPO AND X5.D_E_L_E_T_ = '' " + CRLF
cQuery += "		WHERE " + CRLF

If _lSB1Comp
	cQuery += "			B1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
Else
	cQuery += "			B1.B1_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cCodProd)
	cQuery += "			CAST((B1.B1_XDTALT + ' ' + B1.B1_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((B1.B1_XDTALT + ' ' + B1.B1_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "			B1.B1_COD = '" + cCodProd + "' AND " + CRLF
EndIf 
cQuery += "		B1.B1_MSBLQL IN(' ','2') AND " + CRLF
cQuery += "		B1.D_E_L_E_T_ = '' " + CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	LogExec("NAO EXISTEM DADOS PARA SEREM ENVIADOS.")
	(cAlias)->( dbCloseArea() )
	Return .F.
EndIf

nTotQry := (cAlias)->TOTREG

If nTotQry <= Val(cTamPage)
	nTotPag := 1 
Else
	If Mod(nTotQry,Val(cTamPage)) <> 0
		nTotPag := Int(nTotQry/Val(cTamPage)) + 1
	Else
		nTotPag := Int(nTotQry/Val(cTamPage))	
	EndIf
EndIf	

(cAlias)->( dbCloseArea() )

Return .T.

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