#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "008"
Static cDescInt	:= "NFSAIDA"
Static cDirRaiz := "\wms\"

Static _nTNota	:= TamSx3("F2_DOC")[1]
Static _nTSerie	:= TamSx3("F2_SERIE")[1]
	
/************************************************************************************/
/*/{Protheus.doc} NFSAIDA

@description API - Envia dados das notas fiscais Dana

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type class
/*/
/************************************************************************************/
WSRESTFUL NFSAIDA DESCRIPTION " Servico Perfumes Dana - Nota Fiscal de Saida."
	
	WSDATA NOTA 		AS STRING
	WSDATA SERIE 		AS STRING
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET DESCRIPTION "Retorna dados da nota fiscal de saida Perfumes Dana " WSSYNTAX "/API/NFSAIDA/GET/nota/serie/datahora{Data Hora da ultima Atualização}"
	WSMETHOD PUT DESCRIPTION "Recebe dados da nota fiscal retirando da fila de integração Perfumes Dana " WSSYNTAX "/API/NFSAIDA/PUT"
	
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET

@description Retorna string JSON com os dados da nota de saida 

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE NOTA,SERIE,DATAHORA,PERPAGE,PAGE WSSERVICE NFSAIDA
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cNota			:= IIF(Empty(::NOTA),"",::NOTA)
Local cSerie		:= IIF(Empty(::SERIE),"",::SERIE)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE

Local nLen			:= Len(::aUrlParms)

Private cArqLog		:= ""
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

Private _lSF2Comp 	:= ( FWModeAccess("SF2",3) == "C" )

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "NOTA_SAIDA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DAS NOTA DE SAIDA AO WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//-----------------------------+
// JSON Envia Notas de Entrada |
//-----------------------------+
aRet := DnaApi08A(cNota,cSerie,cDataHora,cTamPage,cPage) 

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

LogExec("FINALIZA ENVIO DAS NOTA DE SAIDA AO WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} PUT

@description Realiza a baixa da nota fiscal da fila de integração
@author Bernard M. Margarido
@since 24/07/2019
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD PUT WSSERVICE NFSAIDA
Local aArea		:= GetArea()

Local nLen		:= Len(::aUrlParms)
Local _nX		:= 0

Local oJson		:= Nil
Local oNotas	:= Nil

Private cJsonRet:= ""
	
Private aMsgErro:= {}

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "NOTA_FISCAL_BAIXA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA BAIXA DAS NOTAS DE SAIDA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//---------------------+
// Corpo da Requisição |
//---------------------+
cBody := ::GetContent()

//-------------------+
// Valida requisição |
//-------------------+
If Empty(cBody)
	//----------------+
	// Retorno da API |
	//----------------+
	HTTPSetStatus(400,"Arquivo POST não enviado.")
	Return .T.
EndIf

//-----------------------------------+
// Realiza a deserializacao via HASH |
//-----------------------------------+
oJson 	:= xFromJson(cBody)

oNotas	:= oJson[#"notas"]

//---------------------------------------------+
// Inicia a Gravacao / Atualização dos Pedidos |
//---------------------------------------------+
For _nX := 1 To Len(oNotas)	
	LogExec("INICIA VALIDACAO DA BAIXA DA NOTA " + LTrim(oNotas[_nX][#"nota"]) )
	DnaApi08C(oNotas[_nX])
Next _nX	

//----------------------+
// Cria JSON de Retorno |
//----------------------+	
If Len(aMsgErro) > 0
	DnaApi08E(aMsgErro,@cJsonRet)
EndIf
	
//----------------+
// Retorno da API |
//----------------+
::SetResponse(cJsonRet)
HTTPSetStatus(200,"OK")

LogExec("FINALIZA DAS NOTAS DE SAIDA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi08A

@description Consulta notas de saida e monta arquivo de envio

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApi08A(cNota,cSerie,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}

Local cAlias	:= GetNextAlias()	
Local cRest		:= ""
Local _cNota 	:= ""
Local _cSerie 	:= ""
Local _cPedido	:= ""
Local _cFiliAtu	:= ""
Local _dDtaEmiss:= ""

Local oJson		:= Nil
Local oNFS		:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "200" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cNota,cSerie,cDataHora,cTamPage,cPage)
	
	oJson			:= Array(#)
	oJson[#"error"]	:= {}
	
	aAdd(oJson[#"error"],Array(#))
	oNFS := aTail(oJson[#"error"])
	oNFS[#"msg"] := "Nao existem dados para serem retornados."
	
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
oJson[#"nfs"]		:= {}

While (cAlias)->( !Eof() )
	
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"nfs"],Array(#))
	oNFS := aTail(oJson[#"nfs"])
	
	_cFiliAtu 	:= (cAlias)->FILIAL
	_cPedido 	:= (cAlias)->PEDIDO
	_cNota		:= (cAlias)->NOTA
	_cSerie		:= (cAlias)->SERIE
	_cChaveNfe	:= (cAlias)->CHAVENFE
	_dDtaEmiss	:= dToc(sTod((cAlias)->EMISSAO))
				 
	//-----------------------------+
	// Cria cabeçalho da nota JSON |
	//-----------------------------+
	oNFS[#"filial"]				:= _cFiliAtu
	oNFS[#"pedido"]				:= _cPedido
	oNFS[#"nota"]				:= _cNota
	oNFS[#"serie"]				:= _cSerie
	oNFS[#"chave_nfe"]			:= _cChaveNfe
	oNFS[#"data_emissao"]		:= _dDtaEmiss
	
	(cAlias)->( dbSkip() )
EndDo

//-----------+
// Paginação |
//-----------+
oJson[#"pagina"]								:= Array(#)
oJson[#"pagina"][#"total_notas_pagina"]			:= Val(cTamPage)
oJson[#"pagina"][#"total_notas"]				:= nTotQry
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
/*/{Protheus.doc} DnaApi08C

@description Realiza a baixa das notas de saida
@author Bernard M. Margarido
@since 24/07/2019
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApi08C(_oNota)
Local _aArea	:= GetArea()

Local _cFilAux	:= cFilAnt
Local _cFilNF	:= _oNota[#"filial"]
Local _cNota	:= PadR(_oNota[#"nota"],_nTNota)
Local _cSerie	:= PadR(_oNota[#"serie"],_nTSerie)

//------------------------+
// Posiciona filial atual | 
//------------------------+
cFilAnt := _cFilNF

//------------------+
// Posiciona Pedido | 
//------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cNota + _cSerie ) )
	aAdd(aMsgErro,{cFilAnt,RTrim(_cNota) + RTrim(_cSerie),.F.,"NOTA " + RTrim(_cNota) + " SERIE " + RTrim(_cSerie) + " NAO ENCONTRADO."})
	RestArea(_aArea)
	Return .F.
EndIf

//----------------------------------+
// Valida se Pedido já foi expedido | 
//----------------------------------+
If SF2->F2_XENVWMS == "4"
	aAdd(aMsgErro,{cFilAnt,RTrim(_cNota) + RTrim(_cSerie),.F.,"NOTA " + RTrim(_cNota) + " SERIE " + RTrim(_cSerie) + " JÁ VALIDADO."})
	RestArea(_aArea)
	Return .F.
EndIf

//---------------------------+
// Atualiza Status do Pedido |
//---------------------------+
RecLock("SF2",.F.)
	SF2->F2_XENVWMS := "4"
	SF2->F2_XDTALT	:= Date()
	SF2->F2_XHRALT	:= Time()
SF2->( MsUnLock() )

aAdd(aMsgErro,{cFilAnt,RTrim(_cNota) + RTrim(_cSerie),.T.,"NOTA " + RTrim(_cNota) + " SERIE " + RTrim(_cSerie) + " BAIXADO COM SUCESSO."})

//-------------------------+
// Restaura a filial atual |
//-------------------------+
cFilAnt := _cFilAux

RestArea(_aArea)
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} DnaApi07E

@description Processa retorno da conferencia separação pedido de venda

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnaApi08E(aMsgErro,cJsonRet)
Local oJsonRet	:= Nil
Local oPedidos	:= Nil

Local nMsg		:= 0

oJsonRet					:= Array(#)
oJsonRet[#"notas"]			:= {}
	
For nMsg := 1 To Len(aMsgErro)
	aAdd(oJsonRet[#"notas"],Array(#))
	oPedidos := aTail(oJsonRet[#"notas"])
	oPedidos[#"filial"]		:= aMsgErro[nMsg][1]
	oPedidos[#"nota"]		:= aMsgErro[nMsg][2]
	oPedidos[#"status"]		:= aMsgErro[nMsg][3]
	oPedidos[#"msg"]		:= aMsgErro[nMsg][4]
Next nMsg

//---------------------------+
// Transforma Objeto em JSON |
//---------------------------+
cJsonRet := EncodeUtf8(xToJson(oJsonRet))	

Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApiQry

@description Consulta notas de saida para serem enviados 

@author Bernard M. Margarido
@since 27/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApiQry(cAlias,cNota,cSerie,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//---------------------------+
// Cosulta total de produtos | 
//---------------------------+
If !DnaQryTot(cNota,cSerie,cDataHora,cTamPage,cPage)
	Return .F.
EndIf

cQuery := "	SELECT " + CRLF
cQuery += "		TOP(" + cTamPage + ") RNUM," + CRLF
cQuery += "		FILIAL," + CRLF
cQuery += "		NOTA," + CRLF
cQuery += "		SERIE," + CRLF
cQuery += "		PEDIDO," + CRLF
cQuery += "		EMISSAO," + CRLF
cQuery += "		CHAVENFE," + CRLF
cQuery += "		RECNOSF2" + CRLF
cQuery += "	FROM ( " + CRLF
cQuery += "			SELECT" + CRLF
cQuery += "				ROW_NUMBER() OVER(ORDER BY F2.F2_DOC) RNUM, " + CRLF
cQuery += "				F2.F2_FILIAL FILIAL," + CRLF
cQuery += "				F2.F2_DOC NOTA," + CRLF
cQuery += "				F2.F2_SERIE SERIE," + CRLF
cQuery += "				D2.D2_PEDIDO PEDIDO," + CRLF
cQuery += "				F2.F2_EMISSAO EMISSAO," + CRLF
cQuery += "				F2.F2_CHVNFE CHAVENFE," + CRLF
cQuery += "				F2.R_E_C_N_O_ RECNOSF2" + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SF2") + " F2 " + CRLF 

cQuery += "				INNER JOIN " + RetSqlName("SD2") + " D2 ON D2.D2_FILIAL = F2.F2_FILIAL AND D2.D2_DOC = F2.F2_DOC AND D2.D2_SERIE = F2.F2_SERIE AND D2.D_E_L_E_T_ = '' " + CRLF
cQuery += "				INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = D2.D2_FILIAL AND F4.F4_CODIGO = D2.D2_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF
//cQuery += "				INNER JOIN " + RetSqlName("SC5") + " C5 ON C5.C5_FILIAL = F2.F2_FILIAL AND C5.C5_NUM = D2.D2_PEDIDO AND C5.C5_XENVWMS = '3' AND C5.D_E_L_E_T_ = '' " + CRLF

cQuery += "			WHERE " + CRLF

If _lSF2Comp
	cQuery += "				F2.F2_FILIAL = '" + xFilial("SF2") + "' AND " + CRLF
Else
	cQuery += "				F2.F2_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf
	
cQuery += "				F2.F2_XENVWMS = '3' AND " + CRLF
cQuery += "				F2.F2_XNUMECO = '' AND " + CRLF
cQuery += "				F2.F2_FIMP = 'S' AND " + CRLF
If Empty(cNota) .And. Empty(cSerie)
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "				F2.F2_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "				F2.F2_SERIE = '" + cSerie + "' AND " + CRLF
EndIf
cQuery += "				F2.D_E_L_E_T_ = '' " + CRLF
cQuery += "		GROUP BY F2.F2_FILIAL,F2.F2_DOC,F2.F2_SERIE,D2.D2_PEDIDO,F2.F2_EMISSAO,F2.F2_CHVNFE,F2.R_E_C_N_O_ " + CRLF 
cQuery += "	) PEDIDO  " + CRLF
cQuery += "	WHERE RNUM > " + cTamPage + " * (" + cPage + " - 1) " + CRLF 
cQuery += "	ORDER BY FILIAL,NOTA,SERIE "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	LogExec("NAO EXISTEM DADOS PARA SEREM ENVIADOS.")
	(cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ApiQryTot

@description Retorna total de Notas

@author Bernard M. Margarido
@since 27/10/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnaQryTot(cNota,cSerie,cDataHora,cTamPage,cPage)
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
cQuery += "		COUNT(DOC) TOTREG " + CRLF
cQuery += "	FROM " + CRLF
cQuery += " ( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			F2.F2_FILIAL FILIAL, " + CRLF
cQuery += "			F2.F2_DOC DOC, " + CRLF
cQuery += "			F2.F2_SERIE SERIE " + CRLF
cQuery += "		FROM " + CRLF 
cQuery += "			" + RetSqlName("SF2") + " F2 " + CRLF 

cQuery += "			INNER JOIN " + RetSqlName("SD2") + " D2 ON D2.D2_FILIAL = F2.F2_FILIAL AND D2.D2_DOC = F2.F2_DOC AND D2.D2_SERIE = F2.F2_SERIE AND D2.D_E_L_E_T_ = '' " + CRLF
cQuery += "			INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = D2.D2_FILIAL AND F4.F4_CODIGO = D2.D2_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF
//cQuery += "				INNER JOIN " + RetSqlName("SC5") + " C5 ON C5.C5_FILIAL = F2.F2_FILIAL AND C5.C5_NUM = D2.D2_PEDIDO AND C5.C5_XENVWMS = '3' AND C5.D_E_L_E_T_ = '' " + CRLF

cQuery += "		WHERE " + CRLF

If _lSF2Comp
	cQuery += "			F2.F2_FILIAL = '" + xFilial("SF2") + "' AND " + CRLF
Else
	cQuery += "			F2.F2_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

cQuery += "				F2.F2_XENVWMS = '3' AND " + CRLF
cQuery += "				F2.F2_XNUMECO = '' AND " + CRLF
cQuery += "				F2.F2_FIMP = 'S' AND " + CRLF
If Empty(cNota) .And. Empty(cSerie)
	cQuery += "			CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "			F2.F2_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "			F2.F2_SERIE = '" + cSerie + "' AND " + CRLF
EndIf
cQuery += "			F2.D_E_L_E_T_ = '' " + CRLF
cQuery += "		GROUP BY F2.F2_FILIAL,F2.F2_DOC,F2.F2_SERIE " + CRLF
cQuery += ") NOTAS "

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