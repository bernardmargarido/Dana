#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "005"
Static cDescInt	:= "ARMAZENS"
Static cDirRaiz := "\wms\"

/************************************************************************************/
/*/{Protheus.doc} ARMAZENS

@description API - Envia dados dos Armazens utilizados na Perfumes Dana

@author Bernard M. Margarido
@since 27/10/2018
@version 1.0

@type class
/*/
/************************************************************************************/
WSRESTFUL ARMAZENS DESCRIPTION " Servico Perfumes Dana - Retorna dados dos armazens(depositos)."
	
	WSDATA CODARMAZEM 	AS STRING	
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET DESCRIPTION "Retorna dados dos armazens(depositos) utilizados na Perfumes Dana " WSSYNTAX "/API/TRANSPORTADORAS{CodArmazem}/datahora{Data Hora da ultima Atualização}"

END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET

@description Retorna string JSON com os dados dos armazens

@author Bernard M. Margarido
@since 27/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE CODARMAZEM,DATAHORA,PERPAGE,PAGE WSSERVICE ARMAZENS
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cCodArma		:= IIF(Empty(::CODARMAZEM),"",::CODARMAZEM)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE
Local cFilAux		:= cFilAnt
	
Local nLen			:= Len(::aUrlParms)

Private cArqLog		:= ""
Private _lNNRComp 	:= ( FWModeAccess("NNR",3) == "C" )
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "ARMAZENS" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DOS ARMAZENS WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//---------------------+
// Gera novo orçamento |
//---------------------+
aRet := DnaApi05A(cCodArma,cDataHora,cTamPage,cPage) 

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

LogExec("FINALIZA ENVIO DOS ARMAZENS WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi04A

@description Consulta armazens e monta arquivo e envio

@author Bernard M. Margarido
@since 27/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApi05A(cCodArma,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}
Local aCarac	:= {}

Local cAlias	:= GetNextAlias()	
Local cRest		:= ""

Local oJson		:= Nil
Local oLocal	:= Nil
Local oPagina	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "50" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cCodArma,cDataHora,cTamPage,cPage)
	
	oJson			:= Array(#)
	oJson[#"error"]	:= {}
	
	aAdd(oJson[#"error"],Array(#))
	oLocal := aTail(oJson[#"error"])
	oLocal[#"msg"] := "Nao existem dados para serem retornados."
	
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
oJson[#"armazens"]	:= {}

While (cAlias)->( !Eof() )
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"armazens"],Array(#))
	oLocal := aTail(oJson[#"armazens"])
	
	//------------------+
	// Dados do Produto |
	//------------------+
	oLocal[#"filial"] 		:= (cAlias)->FILIAL
	oLocal[#"codigo"] 		:= (cAlias)->CODIGO
	oLocal[#"descricao"] 	:= (cAlias)->DESCRICAO
	oLocal[#"departamento"]	:= RTrim((cAlias)->DEPARTAMENTO)
		
	(cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
oJson[#"pagina"]								:= Array(#)
oJson[#"pagina"][#"total_armazens_pagina"]		:= Val(cTamPage)
oJson[#"pagina"][#"total_armazens"]				:= nTotQry
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

@description Consulta armazens para serem enviados 

@author Bernard M. Margarido
@since 27/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApiQry(cAlias,cCodArma,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//---------------------------+
// Cosulta total de produtos | 
//---------------------------+
If !DnaQryTot(cCodArma,cDataHora,cTamPage,cPage)
	Return .F.
EndIf

cQuery := "	SELECT " + CRLF
cQuery += "		TOP(" + cTamPage + ") RNUM, " + CRLF
cQuery += "		FILIAL, " + CRLF
cQuery += "		CODIGO, " + CRLF
cQuery += "		DESCRICAO, " + CRLF
cQuery += "		DEPARTAMENTO " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF 
cQuery += "			ROW_NUMBER() OVER(ORDER BY NNR.NNR_CODIGO) RNUM, " + CRLF
cQuery += "			NNR.NNR_FILIAL FILIAL, " + CRLF 
cQuery += "			NNR.NNR_CODIGO CODIGO, " + CRLF
cQuery += "			NNR.NNR_DESCRI DESCRICAO, " + CRLF
cQuery += "			'' DEPARTAMENTO " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("NNR") + " NNR " + CRLF  
cQuery += "		WHERE " + CRLF

If _lNNRComp
	cQuery += "			NNR.NNR_FILIAL = '" + xFilial("NNR") + "' AND " + CRLF
Else
	cQuery += "			NNR.NNR_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf	

If Empty(cCodArma)
	cQuery += "			CAST((NNR.NNR_XDTALT + ' ' + NNR.NNR_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((NNR.NNR_XDTALT + ' ' + NNR.NNR_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "			NNR.NNR_CODIGO = '" + cCodArma + "' AND " + CRLF
EndIf 
cQuery += "		NNR.D_E_L_E_T_ = '' " + CRLF	
cQuery += "	) ARMAZEM " + CRLF
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
@since 27/10/2018
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
Static Function DnaQryTot(cCodArma,cDataHora,cTamPage,cPage)
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
cQuery += "		COUNT(NNR.NNR_CODIGO) TOTREG " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "			" + RetSqlName("NNR") + " NNR " + CRLF  
cQuery += "		WHERE " + CRLF

If _lNNRComp
	cQuery += "			NNR.NNR_FILIAL = '" + xFilial("NNR") + "' AND " + CRLF
Else
	cQuery += "			NNR.NNR_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cCodArma)
	cQuery += "			CAST((NNR.NNR_XDTALT + ' ' + NNR.NNR_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((NNR.NNR_XDTALT + ' ' + NNR.NNR_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "			NNR.NNR_CODIGO = '" + cCodArma + "' AND " + CRLF
EndIf 
cQuery += "		NNR.D_E_L_E_T_ = '' " + CRLF

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