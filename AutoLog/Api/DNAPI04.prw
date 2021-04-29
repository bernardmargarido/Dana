#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "004"
Static cDescInt	:= "TRANSPORTADORAS"
Static cDirRaiz := "\wms\"

/************************************************************************************/
/*/{Protheus.doc} TRANSPORTADORAS
	@description API - Envia dados dos produtos 
	@author Bernard M. Margarido
	@since 26/10/2018
	@version 1.0
	@type class
/*/
/************************************************************************************/
WSRESTFUL TRANSPORTADORAS DESCRIPTION " Servico Perfumes Dana - Retorna dados das Transportadoras."
	
	WSDATA CODTRANSP 	AS STRING	
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET DESCRIPTION "Retorna dados dos Transportadoras. " WSSYNTAX "/API/TRANSPORTADORAS{CodTransp}/datahora{Data Hora da ultima Atualização}"

END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET
	@description Retorna string JSON com os dados das Transportadoras
	@author Bernard M. Margarido
	@since 26/10/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE CODTRANSP,DATAHORA,PERPAGE,PAGE WSSERVICE TRANSPORTADORAS
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cCodTransp	:= IIF(Empty(::CODTRANSP),"",::CODTRANSP)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE

Private cArqLog		:= ""
Private _lSA4Comp 	:= ( FWModeAccess("SA4",3) == "C" )
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")
Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "TRANSPORTADORAS" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DOS TRANSPORTADORAS WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//---------------------+
// Gera novo orçamento |
//---------------------+
aRet := DnaApi04A(cCodTransp,cDataHora,cTamPage,cPage) 

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

LogExec("FINALIZA ENVIO DOS TRANSPORTADORAS WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi04A
	@description Consulta transportadoras e monta arquivo e envio
	@author Bernard M. Margarido
	@since 26/10/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnaApi04A(cCodTransp,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}

Local cAlias	:= GetNextAlias()	
Local cRest		:= ""

Local oJson		:= Nil
Local oTransp	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "50" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cCodTransp,cDataHora,cTamPage,cPage)
	
	oJson			:= Array(#)
	oJson[#"error"]	:= {}
	
	aAdd(oJson[#"error"],Array(#))
	oTransp := aTail(oJson[#"error"])
	oTransp[#"msg"] := "Nao existem dados para serem retornados."
	
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
oJson						:= Array(#)
oJson[#"transportadoras"]	:= {}

While (cAlias)->( !Eof() )
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"transportadoras"],Array(#))
	oTransp := aTail(oJson[#"transportadoras"])
	
	//------------------+
	// Dados do Produto |
	//------------------+
	oTransp[#"filial"] 		:= (cAlias)->FILIAL
	oTransp[#"codigo"] 		:= (cAlias)->CODIGO
	oTransp[#"cnpj_cpf"] 	:= (cAlias)->CNPJ_CPF
	oTransp[#"razao"] 		:= RTrim((cAlias)->RAZAO)
	oTransp[#"fantasia"] 	:= RTrim((cAlias)->NREDUZ)
	oTransp[#"endereco"]	:= RTrim((cAlias)->ENDERECO)
	oTransp[#"bairro"]		:= RTrim((cAlias)->BAIRRO)
	oTransp[#"municipio"]	:= RTrim((cAlias)->MUNICIPIO)
	oTransp[#"uf"]			:= (cAlias)->ESTADO
	oTransp[#"cep"]			:= (cAlias)->CEP
	oTransp[#"telefone"]	:= IIF(Empty((cAlias)->DDD),"","(" + RTrim((cAlias)->DDD) + ")") + RTrim((cAlias)->TELEFONE)
	oTransp[#"email"]		:= RTrim((cAlias)->EMAIL)
	
	(cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
oJson[#"pagina"]										:= Array(#)
oJson[#"pagina"][#"total_transportadoras_pagina"]		:= Val(cTamPage)
oJson[#"pagina"][#"total_transportadoras"]				:= nTotQry
oJson[#"pagina"][#"total_paginas"]						:= nTotPag
oJson[#"pagina"][#"pagina_atual"]						:= Val(cPage)

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
	MakeDir("\AutoLog\arquivos\transportadora")
	MemoWrite("\AutoLog\arquivos\transportadora\jsontransportadora_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cRest)
EndIf

RestArea(aArea)
Return aRet 

/************************************************************************************/
/*/{Protheus.doc} DnaApiQry
	@description Consulta transportadoras para serem enviados 
	@author Bernard M. Margarido
	@since 26/10/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnaApiQry(cAlias,cCodTransp,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//---------------------------+
// Cosulta total de produtos | 
//---------------------------+
If !DnaQryTot(cCodTransp,cDataHora,cTamPage,cPage)
	Return .F.
EndIf

cQuery := "	SELECT " + CRLF
cQuery += "		TOP(" + cTamPage + ") RNUM, " + CRLF
cQuery += "		FILIAL, " + CRLF
cQuery += "		CODIGO, " + CRLF
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
cQuery += "			ROW_NUMBER() OVER(ORDER BY A4.A4_COD) RNUM, " + CRLF
cQuery += "			A4.A4_FILIAL FILIAL, " + CRLF 
cQuery += "			A4.A4_COD CODIGO, " + CRLF
cQuery += "			A4.A4_NOME RAZAO, " + CRLF
cQuery += "			A4.A4_NREDUZ NREDUZ, " + CRLF
cQuery += "			A4.A4_CGC CNPJ_CPF, " + CRLF
cQuery += "			A4.A4_END ENDERECO, " + CRLF
cQuery += "			A4.A4_BAIRRO BAIRRO, " + CRLF
cQuery += "			A4.A4_MUN MUNICIPIO, " + CRLF
cQuery += "			A4.A4_CEP CEP, " + CRLF
cQuery += "			A4.A4_EST ESTADO, " + CRLF
cQuery += "			A4.A4_TEL TELEFONE, " + CRLF
cQuery += "			A4.A4_DDD DDD, " + CRLF
cQuery += "			A4.A4_EMAIL EMAIL " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SA4") + " A4 " + CRLF  
cQuery += "		WHERE " + CRLF

If _lSA4Comp
	cQuery += "			A4.A4_FILIAL = '" + xFilial("SA4") + "' AND " + CRLF
Else
	cQuery += "			A4.A4_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf	

If Empty(cCodTransp)
	cQuery += "			CAST((A4.A4_XDTALT + ' ' + A4.A4_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((A4.A4_XDTALT + ' ' + A4.A4_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "			A4.A4_COD = '" + cCodTransp + "' AND " + CRLF
EndIf 
cQuery += "		A4.D_E_L_E_T_ = '' " + CRLF	
cQuery += "	) TRANSPORTADORA " + CRLF
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
	@description Retorna total de Transportadoras
	@author Bernard M. Margarido
	@since 26/10/2018
	@version 1.0
	@type function
/*/
/*************************************************************************************/
Static Function DnaQryTot(cCodTransp,cDataHora,cTamPage,cPage)
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
cQuery += "		COUNT(A4.A4_COD) TOTREG " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "			" + RetSqlName("SA4") + " A4 " + CRLF  
cQuery += "		WHERE " + CRLF

If _lSA4Comp
	cQuery += "			A4.A4_FILIAL = '" + xFilial("SA4") + "' AND " + CRLF
Else
	cQuery += "			A4.A4_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cCodTransp)
	cQuery += "			CAST((A4.A4_XDTALT + ' ' + A4.A4_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((A4.A4_XDTALT + ' ' + A4.A4_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "			A4.A4_COD = '" + cCodTransp + "' AND " + CRLF
EndIf 
cQuery += "		A4.D_E_L_E_T_ = '' " + CRLF

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