#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "001"
Static cDescInt	:= "CLIENTES"
Static cDirRaiz := "\wms\"

/************************************************************************************/
/*/{Protheus.doc} CLIENTES
	@description API - Envia dados dos Clienres 
	@author Bernard M. Margarido
	@since 23/10/2018
	@version 1.0
	@type class
/*/
/************************************************************************************/
WSRESTFUL CLIENTES DESCRIPTION " Servico Perfumes Dana - Retorna dados dos clientes."
	
	WSDATA CNPJ_CPF 	AS STRING
	WSDATA CODIGO		AS STRING
	WSDATA LOJA			AS STRING	
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET DESCRIPTION "Retorna dados dos Clientes. " WSSYNTAX "/API/CLIENTES/?cnpj_cpf,codigo,loja,datahora{Data Hora da ultima Atualização}"

END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET
	@description Retorna string JSON com os dados do cliente
	@author Bernard M. Margarido
	@since 23/03/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE CNPJ_CPF,CODIGO,LOJA,DATAHORA,PERPAGE,PAGE WSSERVICE CLIENTES
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cCNPJ			:= IIF(Empty(::CNPJ_CPF),"",::CNPJ_CPF)
Local cCodigo		:= IIF(Empty(::CODIGO),"",::CODIGO)
Local cLoja			:= IIF(Empty(::LOJA),"",::LOJA)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE

//Local _nX			:= 0

//Local _aGrpCom		:= FWAllGrpCompany()

Private cArqLog		:= ""

Private _lSA1Comp 	:= ( FWModeAccess("SA1",3) == "C" )
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")
Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)

//For _nX := 1 To Len(_aGrpCom)

//	RPCSetType(3)  
//	RPCSetEnv(_aGrpCom[_nX], IIF(_aGrpCom[_nX] == "01","05","01"), Nil, Nil, "FRT")

	//------------------------------+
	// Inicializa Log de Integracao |
	//------------------------------+
	MakeDir(cDirRaiz)
	cArqLog := cDirRaiz + "CLIENTES" + cEmpAnt + cFilAnt + ".LOG"
	ConOut("")	
	LogExec(Replicate("-",80))
	LogExec("INICIA ENVIO DOS CLIENTES WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

	//--------------------+
	// Seta o contenttype |
	//--------------------+
	::SetContentType("application/json") 

	//---------------------+
	// Gera novo orçamento |
	//---------------------+
	aRet := DnaApi01A(cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage) 

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

	LogExec("FINALIZA ENVIO DOS CLIENTES WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
	LogExec(Replicate("-",80))
	ConOut("")

	//-------------------+
	// Finaliza Ambiente |
	//-------------------+
	RpcClearEnv()

//Next _nX 
RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi01A
	@description Consulta clientes e monta arquivo e envio
	@author Bernard M. Margarido
	@since 24/10/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnaApi01A(cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}

Local cAlias	:= GetNextAlias()	
Local cRest		:= ""

Local oJson		:= Nil
Local oCliente	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "50" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage)
	
	oJson			:= Array(#)
	oJson[#"error"]	:= {}
	
	aAdd(oJson[#"error"],Array(#))
	oCliente := aTail(oJson[#"error"])
	oCliente[#"msg"] := "Nao existem dados para serem retornados."
	
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
oJson[#"clientes"]	:= {}

While (cAlias)->( !Eof() )
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"clientes"],Array(#))
	oCliente := aTail(oJson[#"clientes"])
	
	//------------------+
	// Dados do Produto |
	//------------------+
	oCliente[#"filial"] 	:= (cAlias)->FILIAL
	oCliente[#"codigo"] 	:= (cAlias)->CODIGO
	oCliente[#"loja"] 		:= (cAlias)->LOJA
	oCliente[#"cnpj_cpf"] 	:= (cAlias)->CNPJ_CPF
	oCliente[#"razao"] 		:= RTrim((cAlias)->RAZAO)
	oCliente[#"fantasia"] 	:= RTrim((cAlias)->NREDUZ)
	oCliente[#"endereco"]	:= RTrim((cAlias)->ENDERECO)
	oCliente[#"bairro"]		:= RTrim((cAlias)->BAIRRO)
	oCliente[#"municipio"]	:= RTrim((cAlias)->MUNICIPIO)
	oCliente[#"uf"]			:= (cAlias)->ESTADO
	oCliente[#"cep"]		:= (cAlias)->CEP
	oCliente[#"telefone"]	:= IIF(Empty((cAlias)->DDD),"","(" + RTrim((cAlias)->DDD) + ")") + RTrim((cAlias)->TELEFONE)
	oCliente[#"email"]		:= RTrim(Lower((cAlias)->EMAIL))
	
	(cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
oJson[#"pagina"]								:= Array(#)
oJson[#"pagina"][#"total_clientes_pagina"]		:= Val(cTamPage)
oJson[#"pagina"][#"total_clientes"]				:= nTotQry
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

//------------+
// Grava JSON |
//------------+
If _lGrvJson
	MakeDir("\AutoLog\")
	MakeDir("\AutoLog\arquivos\")
	MakeDir("\AutoLog\arquivos\clientes")
	MemoWrite("\AutoLog\arquivos\clientes\jsonclientes_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cRest)
EndIf

RestArea(aArea)
Return aRet 

/************************************************************************************/
/*/{Protheus.doc} DnaApiQry
	@description Consulta clientes para serem enviados 
	@author Bernard M. Margarido
	@since 24/10/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnaApiQry(cAlias,cCNPJ,cCodigo,cLoja,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//---------------------------+
// Cosulta total de clientes | 
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
cQuery += "			ROW_NUMBER() OVER(ORDER BY A1.A1_COD) RNUM, " + CRLF 
cQuery += "			A1.A1_FILIAL FILIAL, " + CRLF
cQuery += "			A1.A1_COD CODIGO, " + CRLF
cQuery += "			A1.A1_LOJA LOJA, " + CRLF
cQuery += "			A1.A1_NOME RAZAO, " + CRLF
cQuery += "			A1.A1_NREDUZ NREDUZ, " + CRLF
cQuery += "			A1.A1_CGC CNPJ_CPF, " + CRLF
cQuery += "			A1.A1_END ENDERECO, " + CRLF
cQuery += "			A1.A1_BAIRRO BAIRRO, " + CRLF
cQuery += "			A1.A1_MUN MUNICIPIO, " + CRLF
cQuery += "			A1.A1_CEP CEP, " + CRLF
cQuery += "			A1.A1_EST ESTADO, " + CRLF
cQuery += "			A1.A1_TEL TELEFONE, " + CRLF
cQuery += "			A1.A1_DDD DDD, " + CRLF
cQuery += "			A1.A1_EMAIL EMAIL " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SA1") + " A1 " + CRLF  
cQuery += "		WHERE " + CRLF

//----------------------+
// Tabela compartilhada | 
//----------------------+
If  _lSA1Comp
	cQuery += "			A1.A1_FILIAL = '" + xFilial("SA1") + "' AND " + CRLF
//-----------+	
// Exclusiva |
//-----------+	
Else
	cQuery += "			A1.A1_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cCNPJ) .And. Empty(cCodigo) .And. Empty(cLoja)
	cQuery += "			CAST((A1.A1_XDTALT + ' ' + A1.A1_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((A1.A1_XDTALT + ' ' + A1.A1_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
ElseIf !Empty(cCNPJ)	 
	cQuery += "			A1.A1_CGC = '" + cCNPJ + "' AND " + CRLF
ElseIf !Empty(cCodigo) .And. !Empty(cLoja)
	cQuery += "			A1.A1_COD = '" + cCodigo + "' AND " + CRLF
	cQuery += "			A1.A1_LOJA = '" + cLoja + "' AND " + CRLF
EndIf 

cQuery += "		A1.A1_MSBLQL IN(' ','2') AND " + CRLF
cQuery += "		A1.D_E_L_E_T_ = '' " + CRLF	
cQuery += "	) CLIENTES " + CRLF
cQuery += "	WHERE RNUM > " + cTamPage + " * (" + cPage + " - 1) " 
cQuery += "	ORDER BY FILIAL,CODIGO "

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
cQuery += "		COUNT(A1.A1_COD) TOTREG " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "			" + RetSqlName("SA1") + " A1 " + CRLF  
cQuery += "		WHERE " + CRLF

//----------------------+
// Tabela compartilhada | 
//----------------------+
If  _lSA1Comp
	cQuery += "			A1.A1_FILIAL = '" + xFilial("SA1") + "' AND " + CRLF
//-----------+	
// Exclusiva |
//-----------+	
Else
	cQuery += "			A1.A1_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf	

If Empty(cCNPJ) .And. Empty(cCodigo) .And. Empty(cLoja)
	cQuery += "			CAST((A1.A1_XDTALT + ' ' + A1.A1_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((A1.A1_XDTALT + ' ' + A1.A1_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
ElseIf !Empty(cCNPJ)	 
	cQuery += "			A1.A1_CGC = '" + cCNPJ + "' AND " + CRLF
ElseIf !Empty(cCodigo) .And. !Empty(cLoja)
	cQuery += "			A1.A1_COD = '" + cCodigo + "' AND " + CRLF
	cQuery += "			A1.A1_LOJA = '" + cLoja + "' AND " + CRLF
EndIf 

cQuery += "		A1.A1_MSBLQL IN(' ','2') AND " + CRLF
cQuery += "		A1.D_E_L_E_T_ = '' " + CRLF

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
	@type function
/*/
/*************************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.
