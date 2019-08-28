#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "002"
Static cDescInt	:= "FORNECEDORES"
Static cDirRaiz := "\wms\"

/************************************************************************************/
/*/{Protheus.doc} FORNECEDORES

@description API - Envia dados dos fornecedores 

@author Bernard M. Margarido
@since 25/10/2018
@version 1.0

@type class
/*/
/************************************************************************************/
WSRESTFUL FORNECEDORES DESCRIPTION " Servico Perfumes Dana - Retorna dados dos fornecedores."
	
	WSDATA CNPJ_CPF 	AS STRING	
	WSDATA CODIGO		AS STRING
	WSDATA LOJA			AS STRING	
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET DESCRIPTION "Retorna dados dos Fornecedores. " WSSYNTAX "/API/FORNECEDORES{cnpj_cpf}/datahora{Data Hora da ultima Atualização}"

END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET

@description Retorna string JSON com os dados do Fornecedores

@author Bernard M. Margarido
@since 25/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE CNPJ_CPF,CODIGO,LOJA,DATAHORA,PERPAGE,PAGE WSSERVICE FORNECEDORES
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cCNPJ			:= IIF(Empty(::CNPJ_CPF),"",::CNPJ_CPF)
Local cCodigo		:= IIF(Empty(::CODIGO),"",::CODIGO)
Local cLoja			:= IIF(Empty(::LOJA),"",::LOJA)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE
Local cFilAux		:= cFilAnt

Private cArqLog		:= ""
Private _lSA2Comp 	:= ( FWModeAccess("SA2",3) == "C" )
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "FORNECEDORES" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DOS FORNECEDORES WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//---------------------+
// Gera novo orçamento |
//---------------------+
aRet := DnaApi02A(cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage) 

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

LogExec("FINALIZA ENVIO DOS FORNECEDORES WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi02A

@description Consulta fornecedores e monta arquivo e envio

@author Bernard M. Margarido
@since 25/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApi02A(cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}

Local cAlias	:= GetNextAlias()	
Local cRest		:= ""

Local oJson		:= Nil
Local oFornece	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "50" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage)
	
	oJson			:= Array(#)
	oJson[#"error"]	:= {}
	
	aAdd(oJson[#"error"],Array(#))
	oFornece := aTail(oJson[#"error"])
	oFornece[#"msg"] := "Nao existem dados para serem retornados."
	
	//---------------------------+
	// Transforma Objeto em JSON |
	//---------------------------+
	cRest := xToJson(oJson)	
	
	aRet[1] := .F.
	aRet[2] := EncodeUtf8(cRest)
	
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return aRet
EndIf

//--------------------------+
// Inicaliza Matriz HashMap |
//--------------------------+
oJson					:= Array(#)
oJson[#"fornecedores"]	:= {}

While (cAlias)->( !Eof() )
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"fornecedores"],Array(#))
	oFornece := aTail(oJson[#"fornecedores"])
	
	//------------------+
	// Dados do Produto |
	//------------------+
	oFornece[#"filial"] 	:= (cAlias)->FILIAL
	oFornece[#"codigo"] 	:= (cAlias)->CODIGO
	oFornece[#"loja"] 		:= (cAlias)->LOJA
	oFornece[#"cnpj_cpf"] 	:= (cAlias)->CNPJ_CPF
	oFornece[#"razao"] 		:= RTrim((cAlias)->RAZAO)
	oFornece[#"fantasia"] 	:= RTrim((cAlias)->NREDUZ)
	oFornece[#"endereco"]	:= RTrim((cAlias)->ENDERECO)
	oFornece[#"bairro"]		:= RTrim((cAlias)->BAIRRO)
	oFornece[#"municipio"]	:= RTrim((cAlias)->MUNICIPIO)
	oFornece[#"uf"]			:= (cAlias)->ESTADO
	oFornece[#"cep"]		:= (cAlias)->CEP
	oFornece[#"telefone"]	:= IIF(Empty((cAlias)->DDD),"","(" + RTrim((cAlias)->DDD) + ")") + RTrim((cAlias)->TELEFONE)
	oFornece[#"email"]		:= RTrim(Lower((cAlias)->EMAIL))
	
	(cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
oJson[#"pagina"]									:= Array(#)
oJson[#"pagina"][#"total_fornecedores_pagina"]		:= Val(cTamPage)
oJson[#"pagina"][#"total_fornecedores"]				:= nTotQry
oJson[#"pagina"][#"total_paginas"]					:= nTotPag
oJson[#"pagina"][#"pagina_atual"]					:= Val(cPage)

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
@since 25/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApiQry(cAlias,cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//---------------------------+
// Cosulta total de produtos | 
//---------------------------+
If !DnaQryTot(cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage)
	Return .F.
EndIf

cQuery := "	SELECT " + CRLF
cQuery += "		TOP(" + cTamPage + ") RNUM, " + CRLF
cQuery += "		FILIAL, " + CRLF
cQuery += "		CODIGO, " + CRLF
cQuery += "		LOJA, " + CRLF
cQuery += "		RAZAO, " + CRLF
cQuery += "		NREDUZ, " + CRLF
cQuery += "		CNPJ_CPF, " + CRLF
cQuery += "		ENDERECO, " + CRLF
cQuery += "		BAIRRO, " + CRLF
cQuery += "		MUNICIPIO, " + CRLF
cQuery += "		CEP, " + CRLF
cQuery += "		ESTADO, " + CRLF
cQuery += "		TELEFONE, " + CRLF
cQuery += "		DDD, " + CRLF
cQuery += "		EMAIL " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF 
cQuery += "			ROW_NUMBER() OVER(ORDER BY A2.A2_COD) RNUM, " + CRLF 
cQuery += "			A2.A2_FILIAL FILIAL, " + CRLF
cQuery += "			A2.A2_COD CODIGO, " + CRLF
cQuery += "			A2.A2_LOJA LOJA, " + CRLF
cQuery += "			A2.A2_NOME RAZAO, " + CRLF
cQuery += "			A2.A2_NREDUZ NREDUZ, " + CRLF
cQuery += "			A2.A2_CGC CNPJ_CPF, " + CRLF
cQuery += "			A2.A2_END ENDERECO, " + CRLF
cQuery += "			A2.A2_BAIRRO BAIRRO, " + CRLF
cQuery += "			A2.A2_MUN MUNICIPIO, " + CRLF
cQuery += "			A2.A2_CEP CEP, " + CRLF
cQuery += "			A2.A2_EST ESTADO, " + CRLF
cQuery += "			A2.A2_TEL TELEFONE, " + CRLF
cQuery += "			A2.A2_DDD DDD, " + CRLF
cQuery += "			A2.A2_EMAIL EMAIL " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SA2") + " A2 " + CRLF  
cQuery += "		WHERE " + CRLF

If _lSA2Comp
	cQuery += "			A2.A2_FILIAL = '" + xFilial("SA2") + "' AND " + CRLF
Else
	cQuery += "			A2.A2_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf	

If Empty(cCNPJ) .And. Empty(cCodigo) .And. Empty(cLoja)
	cQuery += "			CAST((A2.A2_XDTALT + ' ' + A2.A2_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((A2.A2_XDTALT + ' ' + A2.A2_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
ElseIf !Empty(cCNPJ)	 
	cQuery += "			A2.A2_CGC = '" + cCNPJ + "' AND " + CRLF
ElseIf !Empty(cCodigo) .And. !Empty(cLoja)	
	cQuery += "			A2.A2_COD = '" + cCodigo + "' AND " + CRLF
	cQuery += "			A2.A2_LOJA = '" + cLoja + "' AND " + CRLF
EndIf 

cQuery += "		A2.A2_MSBLQL IN(' ','2') AND " + CRLF
cQuery += "		A2.D_E_L_E_T_ = '' " + CRLF	
cQuery += "	) FORNECE " + CRLF
cQuery += "	WHERE RNUM > " + cTamPage + " * (" + cPage + " - 1) " 
cQuery += "	ORDER BY FILIAL,CODIGO "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	LogExec("NAO EXISTEM DADOS PARA SEREM ENVIADOS.")
	Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ApiQryTot

@description Retorna total de clientes 

@author Bernard M. Margarido
@since 25/10/2018
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
Static Function DnaQryTot(cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//------------------------------------+
// reseta variaveis totais por pagina |
//------------------------------------+
nTotPag := 0
nTotQry := 0

cQuery := "	SELECT " + CRLF
cQuery += "		COUNT(A2.A2_COD) TOTREG " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "			" + RetSqlName("SA2") + " A2 " + CRLF  
cQuery += "		WHERE " + CRLF

If _lSA2Comp
	cQuery += "			A2.A2_FILIAL = '" + xFilial("SA2") + "' AND " + CRLF
Else
	cQuery += "			A2.A2_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cCNPJ) .And. Empty(cCodigo) .And. Empty(cLoja)
	cQuery += "			CAST((A2.A2_XDTALT + ' ' + A2.A2_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((A2.A2_XDTALT + ' ' + A2.A2_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
ElseIf !Empty(cCNPJ)	 
	cQuery += "			A2.A2_CGC = '" + cCNPJ + "' AND " + CRLF
ElseIf !Empty(cCodigo) .And. !Empty(cLoja)	
	cQuery += "			A2.A2_COD = '" + cCodigo + "' AND " + CRLF
	cQuery += "			A2.A2_LOJA = '" + cLoja + "' AND " + CRLF
EndIf 
 
cQuery += "		A2.A2_MSBLQL IN(' ','2') AND " + CRLF
cQuery += "		A2.D_E_L_E_T_ = '' " + CRLF

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