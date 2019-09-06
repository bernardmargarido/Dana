#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "006"
Static cDescInt	:= "NFENTRADA"
Static cDirRaiz := "\wms\"

Static nTDoc	:= TamSx3("F1_DOC")[1]
Static nTSerie	:= TamSx3("F1_SERIE")[1]
Static nTItem	:= TamSx3("D1_ITEM")[1]
Static nTLote	:= TamSx3("D1_LOTECTL")[1]
Static nTCodFor	:= TamSx3("A2_COD")[1]
Static nTLoja	:= TamSx3("A2_LOJA")[1]
Static nTProd	:= TamSx3("B1_COD")[1]

/************************************************************************************/
/*/{Protheus.doc} NFENTRADA

@description API - Envia dados das notas de entrada

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type class
/*/
/************************************************************************************/
WSRESTFUL NFENTRADA DESCRIPTION " Servico Perfumes Dana - Processo Notas e Entrada."
	
	WSDATA NOTA 		AS STRING	
	WSDATA SERIE 		AS STRING
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET  DESCRIPTION "Retorna dados das pré notas de entrada Perfumes Dana " WSSYNTAX "/API/NFENTRADA/GET/nota/serie/datahora{Data Hora da ultima Atualização}"
	WSMETHOD POST DESCRIPTION "Recebe conferencia da pré nota de entrada Perfumes Dana " WSSYNTAX "/API/NFENTRADA/POST"
	WSMETHOD PUT  DESCRIPTION "Conforma recebimento da pre nota de entrada Perfumes Dana " WSSYNTAX "/API/NFENTRADA/PUT/{json}"

END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET

@description Retorna string JSON com os dados das notas de entrada

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE NOTA,SERIE,DATAHORA,PERPAGE,PAGE WSSERVICE NFENTRADA
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cNota			:= IIF(Empty(::NOTA),"",::NOTA)
Local cSerie		:= IIF(Empty(::SERIE),"",::SERIE)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE
Local cFilAux		:= cFilAnt
	
Local nLen			:= Len(::aUrlParms)

Private cArqLog		:= ""
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

Private _lSF1Comp 	:= ( FWModeAccess("SF1",3) == "C" )

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "NFENTRADA_ENVIO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DA PRE NOTA DE ENTRADA AO WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//-----------------------------+
// JSON Envia Notas de Entrada |
//-----------------------------+
aRet := DnaApi06A(cNota,cSerie,cDataHora,cTamPage,cPage) 

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

LogExec("FINALIZA ENVIO DA PRE NOTA DE ENTRADA AO WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} POST

@description Metodo POST - Retorna dados conferidos da pre nota de entrada.

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE NFENTRADA
Local aArea			:= GetArea()

Local nLen			:= Len(::aUrlParms)
Local nNFE			:= 0

Local oJson			:= Nil

Private cJsonRet	:= ""

Private aMsgErro	:= {}

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "NFENTRADA_RETORNO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA RETORNO CONFERENCIA WMS DA PRE NOTA DE ENTRADA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

oPreNFE	:= oJson[#"nfe"]

//-------------------------------------------+
// Inicia a Gravacao / Atualização dos Notas |
//-------------------------------------------+
For nNFE := 1 To Len(oPreNFE)	
	LogExec("INICIA VALIDACAO DA CONFERENCIA DA NOTA/SERIE " + LTrim(oPreNFE[nNFE][#"nota"]) + "/" + LTrim(oPreNFE[nNFE][#"serie"]) )
	DnaApi06B(oPreNFE[nNFE])
Next nNFE	

//----------------------+
// Cria JSON de Retorno |
//----------------------+	
If Len(aMsgErro) > 0
	DnaApi06E(aMsgErro,@cJsonRet)
EndIf
	
//----------------+
// Retorno da API |
//----------------+
::SetResponse(cJsonRet)
HTTPSetStatus(200,"OK")

LogExec("FINALIZA RETORNO CONFERENCIA WMS DA PRE NOTA DE ENTRADA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} PUT

@description Realiza a baixa das pré notas de entrada. 

@author Bernard M. Margarido
@since 08/12/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD PUT WSSERVICE NFENTRADA
Local aArea		:= GetArea()

Local nLen		:= Len(::aUrlParms)
Local nNFE		:= 0

Local oJson		:= Nil

Private cJsonRet:= ""
	
Private aMsgErro:= {}

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "NFENTRADA_BAIXA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA BAIXA DA PRE NOTA DE ENTRADA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

oPreNFE	:= oJson[#"nfe"]

//-------------------------------------------+
// Inicia a Gravacao / Atualização dos Notas |
//-------------------------------------------+
For nNFE := 1 To Len(oPreNFE)	
	LogExec("INICIA BAIXA DA PRE NOTA DE ENTRADA " + LTrim(oPreNFE[nNFE][#"nota"]) + "/" + LTrim(oPreNFE[nNFE][#"serie"]) )
	DnaApi06C(oPreNFE[nNFE])
Next nNFE	

//----------------------+
// Cria JSON de Retorno |
//----------------------+	
If Len(aMsgErro) > 0
	DnaApi06E(aMsgErro,@cJsonRet)
EndIf
	
//----------------+
// Retorno da API |
//----------------+
::SetResponse(cJsonRet)
HTTPSetStatus(200,"OK")

LogExec("FINALIZA BAIXA DA PRE NOTA DE ENTRADA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi06A

@description Consulta notas e monta arquivo e envio

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApi06A(cNota,cSerie,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}

Local cAlias	:= GetNextAlias()	
Local cRest		:= ""
Local cDoc 		:= ""
Local cSerie	:= ""
Local cCodForn	:= ""
Local cLoja		:= ""
Local cCnpj		:= ""
Local cCodTransp:= ""
Local cTpDoc	:= ""
Local dDtaEmiss	:= ""
	
Local oJson		:= Nil
Local oNFE		:= Nil
Local oItens	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "50" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cNota,cSerie,cDataHora,cTamPage,cPage)
	
	oJson			:= Array(#)
	oJson[#"error"]	:= {}
	
	aAdd(oJson[#"error"],Array(#))
	oNFE := aTail(oJson[#"error"])
	oNFE[#"msg"] := "Nao existem dados para serem retornados."
	
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
oJson[#"nfe"]		:= {}

While (cAlias)->( !Eof() )
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"nfe"],Array(#))
	oNFE := aTail(oJson[#"nfe"])
	
	cFilAtu		:= (cAlias)->FILIAL
	cDoc 		:= (cAlias)->NOTA
	cSerie		:= (cAlias)->SERIE
	cCodForn	:= (cAlias)->FORNECE
	cLoja		:= (cAlias)->LOJA
	cCnpj		:= (cAlias)->CNPJ
	cCodTransp	:= (cAlias)->CODTRANSP
	dDtaEmiss	:= dToc(sTod((cAlias)->EMISSAO))
	cTpDoc		:= (cAlias)->TIPODOC
		 
	//-----------------------------+
	// Cria cabeçalho da nota JSON |
	//-----------------------------+
	oNFE[#"filial"]				:= cFilAtu
	oNFE[#"nota"]				:= cDoc
	oNFE[#"serie"]				:= cSerie
	oNFE[#"codigo_fornecedor"]	:= cCodForn
	oNFE[#"loja"]				:= cLoja
	oNFE[#"cnpj"]				:= cCnpj
	oNFE[#"transportadora"]		:= cCodTransp
	oNFE[#"data_emissao"]		:= dDtaEmiss
	oNFE[#"tipo_documento"]		:= cTpDoc
	
	//----------------------------------+
	// Cria array para os itens da nota |
	//----------------------------------+
	oNFE[#"itens"]				:= {}
	
	While (cAlias)->( !Eof() .And. cFilAtu == (cAlias)->FILIAL .And. cDoc + cSerie == (cAlias)->NOTA + (cAlias)->SERIE )
		
		//---------------+
		// Itens da Nota |
		//---------------+
		aAdd(oNFE[#"itens"],Array(#))
		oItens := aTail(oNFE[#"itens"])
		oItens[#"item"]			:= (cAlias)->ITEM 
		oItens[#"produto"]		:= (cAlias)->PRODUTO 
		oItens[#"quantidade"]	:= (cAlias)->QUANTIDADE
		oItens[#"um"]			:= (cAlias)->UM
		oItens[#"lote"]			:= (cAlias)->LOTECTL
		oItens[#"data_validade"]:= (cAlias)->DTA_VALIDADE
		oItens[#"armazem"]		:= (cAlias)->ARMAZEM
		
		(cAlias)->( dbSkip() )
	EndDo
EndDo

//-----------+
// Paginação |
//-----------+
oJson[#"pagina"]								:= Array(#)
oJson[#"pagina"][#"total_nfe_pagina"]			:= Val(cTamPage)
oJson[#"pagina"][#"total_nfe"]					:= nTotQry
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
/*/{Protheus.doc} DnaApi06B

@description Realiza conferencia das Pre Notas de Entrada Perfumes Dana

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function DnaApi06B(_oPreNFE)
Local aArea		:= GetArea()

Local _cFilAux	:= cFilAnt
Local _cFilAtu	:= ""
Local _cNota	:= ""
Local _cSerie	:= ""
Local _cCodFor	:= ""
Local _cLojafor	:= ""
Local _cCodProd	:= ""
Local _cItemNfe	:= ""
Local _cLote	:= ""
	
Local _nQtdConf	:= 0
Local _nNFE		:= 0

Local _aDiverg	:= {}

Local _lContinua:= .T.	

Local _oItNFE	:= Nil

//------------------------+
// Posiciona filial atual |
//------------------------+
_cFilAtu	:= RTrim(_oPreNFE[#"filial"])
cFilAnt		:= _cFilAtu
 
//---------------+
// Dados da Nota |
//---------------+
_cNota		:= PadR(_oPreNFE[#"nota"],nTDoc)
_cSerie		:= PadR(_oPreNFE[#"serie"],nTSerie)
_cCodFor	:= PadR(_oPreNFE[#"codigo_fornecedor"],nTCodFor)
_cLojafor	:= PadR(_oPreNFE[#"loja"],nTLoja)

//-----------------------------+
// Posiciona cabeçalho da Nota |
//-----------------------------+
dbSelectArea("SF1")
SF1->( dbSetOrder(1) )
If !SF1->( dbSeek(xFilial("SF1") + _cNota + _cSerie + _cCodFor + _cLojafor) )
	LogExec(_cNota + " " + _cSerie + "NOTA NAO LOCALIZADO")
	aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.F.,"NOTA NAO LOCALIZADO" })
	RestArea(aArea)
	Return .F.
EndIf

//--------------------------------+
// Valida se ainda é uma pré nota |
// somente para notas do tipo N   |
//--------------------------------+
If ( !Empty(SF1->F1_STATUS) .Or. SF1->F1_XENVWMS == "3" ) .And. SF1->F1_TIPO == "N" 
	LogExec(_cNota + " " + _cSerie + "NOTA CONFERIDA, JÁ CLASSIFICADA.")
	aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.F.,"NOTA CONFERIDA, JÁ CLASSIFICADA." })
	RestArea(aArea)
	Return .T.
EndIf
 	
//------------------------------+
// Valida se nota está conferia |
// somente para notas do tipo D | 
//------------------------------+	
If SF1->F1_XENVWMS == "3" .And. SF1->F1_TIPO == "D" 
	LogExec(_cNota + " " + _cSerie + "NOTA CONFERIDA, JÁ CLASSIFICADA.")
	aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.F.,"NOTA CONFERIDA, JÁ CLASSIFICADA." })
	RestArea(aArea)
	Return .T.
EndIf
//-------------------------------------+
// Posiciona Itens Pre Nota de Entrada | 
//-------------------------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )

//-----------------------------------------------------+
// Valida conferencia dos itens da Pre Nota de Entrada | 
//-----------------------------------------------------+
_oItNFE 	:= _oPreNFE[#"itens"]
_lContinua	:= .T.
For _nNFE := 1 To Len(_oItNFE)
	
	//-----------------+
	// Dados dos Itens |
	//-----------------+
	_cCodProd	:= PadR(_oItNFE[_nNFE][#"produto"],nTProd)
	_cItemNfe	:= PadL(_oItNFE[_nNFE][#"item"],nTItem,"0")
	_cLote		:= PadR(_oItNFE[_nNFE][#"lote"],nTLote)	
	_nQtdConf	:= _oItNFE[_nNFE][#"quantidade"]
	
	//------------------------+
	// Posiciona Item da Nota |
	//------------------------+
	If !SD1->( dbSeek(xFilial("SD1") + _cNota + _cSerie + _cCodFor + _cLojafor + _cCodProd + _cItemNfe ) )
		LogExec(_cNota + " " + _cSerie + " ITEM/PRODUTO " + _cItemNfe + "/" + _cCodProd + " NAO LOCALIZADO.")
		aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.F.," ITEM/PRODUTO " + _cItemNfe + "/" + _cCodProd + " NAO LOCALIZADO." })
		_lContinua := .F.
		Loop
	EndIf
	
	//--------------------+
	// Valida conferencia |
	//--------------------+
	If _lContinua
		
		//---------------------+
		// Quantidade a Maior  |
		//---------------------+
		If _nQtdConf <> SD1->D1_QUANT
			//-------------------+
			// Array Divergencia |
			//-------------------+
		 	aAdd(_aDiverg,{ SD1->D1_ITEM		,;	// 1 - Item Pre Nota
		 					SD1->D1_COD			,;	// 2 - Codigo do Produto
							_nQtdConf			,;	// 3 - Quantidade Transferida
							SD1->D1_LOTECTL		,;	// 4 - Lote Produto
							SD1->D1_LOCAL		})	// 5 - Armazem 	
		EndIf
	
	EndIf			
		
Next _nNFE


If _lContinua
	//---------------------------------------------------+
	// Estorna pre nota envia e-mail com as divergencias | 
	//---------------------------------------------------+
	If Len(_aDiverg) > 0
		DnaApi06P(_cNota,_cSerie,_cCodFor,_cLojafor,_aDiverg)
		//----------------------+	
		// Log processo da nota |
		//----------------------+
		LogExec(_cNota + " " + _cSerie + "DIVERGENCIA PRE NOTA.")
		aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.F.,"PRE NOTA COM DIVERGENCIA."})
		
	//------------------------------+	
	// Libera classificação da Nota |
	//------------------------------+	 
	Else
	
		RecLock("SF1",.F.)
			SF1->F1_XENVWMS := "3"
		SF1->( MsUnLock() )
		
		//----------------------+	
		// Log processo da nota |
		//----------------------+
		LogExec(_cNota + " " + _cSerie + "CONFERENCIA REALIZADA COM SUCESSO.")
		aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.T.,"CONFERENCIA REALIZADA COM SUCESSO."})

	EndIf
EndIf

//-------------------------+
// Restaura a filial atual | 
//-------------------------+
cFilAnt := _cFilAux

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi06C

@description atualiza status da pre nota de entrada.

@author Bernard M. Margarido
@since 08/12/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApi06C(_oPreNFE)
Local _aArea	:= GetArea()

Local _cFilAux	:= cFilAnt
Local _cFilAtu	:= _oPreNFE[#"filial"]
Local _cNota	:= PadR(_oPreNFE[#"nota"],nTDoc)
Local _cSerie	:= PadR(_oPreNFE[#"serie"],nTSerie)
Local _cCodFor	:= PadR(_oPreNFE[#"codigo_fornecedor"],nTCodFor)
Local _cLojafor	:= PadR(_oPreNFE[#"loja"],nTLoja)

//------------------------+
// Posiciona filial atual | 
//------------------------+
cFilAnt := _cFilAtu

//-------------------------------+
// Posiciona Pre Nota de Entrada |
//-------------------------------+
dbSelectArea("SF1")
SF1->( dbSetOrder(1) )
If !SF1->( dbSeek(xFilial("SF1") + _cNota + _cSerie + _cCodFor + _cLojafor) )
	aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.F.,"NAO ENCONTRADA."})
	RestArea(_aArea)
	Return .T.	
EndIf  

//------------------------------------------+
// Valida se nota faz parte do envio ao WMS |
//------------------------------------------+
If Empty(SF1->F1_XENVWMS) 
	aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.F.,"NAO ENCONTRADA."})
	RestArea(_aArea)
	Return .T.	
EndIf

//---------------------------------+
// Valida se nota ja foi conferida |
//---------------------------------+
If SF1->F1_XENVWMS == "3" 
	aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.F.,"NOTA JA CONFERIDA."})
	RestArea(_aArea)
	Return .T.	
EndIf

//-----------------------------+
// Atualiza Status da Pré Nota |
//-----------------------------+
RecLock("SF1",.F.)
	SF1->F1_XENVWMS := "2"
SF1->( MsUnLock() )

aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.T.,"BAIXADA COM SUCESSO."})

//-------------------------+
// Restaura a filial atual |
//-------------------------+
cFilAnt := _cFilAux

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApiQry

@description Consulta pre notas de entrada para serem enviados 

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

//------------------------+
// Cosulta total de Notas | 
//------------------------+
If !DnaQryTot(cNota,cSerie,cDataHora,cTamPage,cPage)
	Return .F.
EndIf

cQuery := "	SELECT " + CRLF
cQuery += "		TOP(" + cTamPage + ") RNUM, " + CRLF
cQuery += "		FILIAL, " + CRLF
cQuery += "		NOTA, " + CRLF
cQuery += "		SERIE, " + CRLF
cQuery += "		FORNECE, " + CRLF
cQuery += "		LOJA, " + CRLF
cQuery += "		CNPJ, " + CRLF
cQuery += "		CODTRANSP, " + CRLF
cQuery += "		EMISSAO, " + CRLF
cQuery += "		TIPODOC, " + CRLF
cQuery += "		RECNOSF1, " + CRLF
cQuery += "		ITEM, " + CRLF 
cQuery += "		PRODUTO, " + CRLF 
cQuery += "		QUANTIDADE, " + CRLF
cQuery += "		UM, " + CRLF
cQuery += "		LOTECTL, " + CRLF
cQuery += "		DTA_VALIDADE, " + CRLF
cQuery += "		ARMAZEM " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	( " + CRLF
cQuery += "		SELECT " + CRLF 
cQuery += "			ROW_NUMBER() OVER(ORDER BY NOTA) RNUM, " + CRLF
cQuery += "			FILIAL, " + CRLF
cQuery += "			NOTA, " + CRLF
cQuery += "			SERIE, " + CRLF
cQuery += "			FORNECE, " + CRLF
cQuery += "			LOJA, " + CRLF
cQuery += "			CNPJ, " + CRLF
cQuery += "			CODTRANSP, " + CRLF
cQuery += "			EMISSAO, " + CRLF
cQuery += "			TIPODOC, " + CRLF
cQuery += "			RECNOSF1, " + CRLF
cQuery += "			ITEM, " + CRLF
cQuery += "			PRODUTO, " + CRLF
cQuery += "			QUANTIDADE, " + CRLF
cQuery += "			UM, " + CRLF
cQuery += "			LOTECTL, " + CRLF
cQuery += "			DTA_VALIDADE, " + CRLF
cQuery += "			ARMAZEM " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "		( " + CRLF
cQuery += "			SELECT " + CRLF 
cQuery += "				F1.F1_FILIAL FILIAL, " + CRLF
cQuery += "				F1.F1_DOC NOTA, " + CRLF
cQuery += "				F1.F1_SERIE SERIE, " + CRLF
cQuery += "				F1.F1_FORNECE FORNECE, " + CRLF
cQuery += "				F1.F1_LOJA LOJA, " + CRLF
cQuery += "				A2.A2_CGC CNPJ, " + CRLF
cQuery += "				F1.F1_TRANSP CODTRANSP, " + CRLF
cQuery += "				F1.F1_DTDIGIT EMISSAO, " + CRLF
cQuery += "				F1.F1_TIPO TIPODOC, " + CRLF
cQuery += "				F1.R_E_C_N_O_ RECNOSF1, " + CRLF
cQuery += "				D1.D1_ITEM ITEM, " + CRLF 
cQuery += "				D1.D1_COD PRODUTO, " + CRLF 
cQuery += "				D1.D1_QUANT QUANTIDADE, " + CRLF
cQuery += "				D1.D1_UM UM, " + CRLF
cQuery += "				D1.D1_LOTECTL LOTECTL, " + CRLF
cQuery += "				D1.D1_DTVALID DTA_VALIDADE, " + CRLF
cQuery += "				D1.D1_LOCAL ARMAZEM " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SF1") + " F1 " + CRLF

cQuery += "				INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = F1.F1_FILIAL AND D1.D1_DOC = F1.F1_DOC AND D1.D1_SERIE = F1.F1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE AND D1.D1_LOJA = F1.F1_LOJA AND D1.D1_PEDIDO <> '' AND D1.D1_ITEMPC <> '' AND D1.D_E_L_E_T_ = '' " + CRLF
//cQuery += "				INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF 
cQuery += "				INNER JOIN " + RetSqlName("SA2") + " A2 ON A2.A2_FILIAL = F1.F1_FILIAL AND A2.A2_COD = F1.F1_FORNECE AND A2.A2_LOJA = F1.F1_LOJA AND A2.D_E_L_E_T_ = '' " + CRLF
 

cQuery += "			WHERE " + CRLF

If _lSF1Comp
	cQuery += "				F1.F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
Else
	cQuery += "				F1.F1_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf
	
If Empty(cNota) .And. Empty(cSerie)
	cQuery += "				CAST((F1.F1_XDTALT + ' ' + F1.F1_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((F1.F1_XDTALT + ' ' + F1.F1_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "				F1.F1_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "				F1.F1_SERIE = '" + cSerie + "' AND " + CRLF
EndIf 
cQuery += "			F1.F1_XENVWMS IN (' ','1') AND " + CRLF
cQuery += "			F1.F1_TIPO = 'N' AND " + CRLF
cQuery += "			F1.F1_STATUS = '' AND " + CRLF
cQuery += "			F1.D_E_L_E_T_ = '' " + CRLF

cQuery += "			UNION ALL " + CRLF

cQuery += "			SELECT " + CRLF 
cQuery += "				F1.F1_FILIAL FILIAL, " + CRLF
cQuery += "				F1.F1_DOC NOTA, " + CRLF
cQuery += "				F1.F1_SERIE SERIE, " + CRLF
cQuery += "				F1.F1_FORNECE FORNECE, " + CRLF
cQuery += "				F1.F1_LOJA LOJA, " + CRLF
cQuery += "				A1.A1_CGC CNPJ, " + CRLF
cQuery += "				F1.F1_TRANSP CODTRANSP, " + CRLF
cQuery += "				F1.F1_DTDIGIT EMISSAO, " + CRLF
cQuery += "				F1.F1_TIPO TIPODOC, " + CRLF
cQuery += "				F1.R_E_C_N_O_ RECNOSF1, " + CRLF
cQuery += "				D1.D1_ITEM ITEM, " + CRLF 
cQuery += "				D1.D1_COD PRODUTO, " + CRLF 
cQuery += "				D1.D1_QUANT QUANTIDADE, " + CRLF
cQuery += "				D1.D1_UM UM, " + CRLF
cQuery += "				D1.D1_LOTECTL LOTECTL, " + CRLF
cQuery += "				D1.D1_DTVALID DTA_VALIDADE, " + CRLF
cQuery += "				D1.D1_LOCAL ARMAZEM " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SF1") + " F1 " + CRLF

cQuery += "				INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = F1.F1_FILIAL AND D1.D1_DOC = F1.F1_DOC AND D1.D1_SERIE = F1.F1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE AND D1.D1_LOJA = F1.F1_LOJA AND D1.D_E_L_E_T_ = '' " + CRLF
//cQuery += "				INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF 
cQuery += "				INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = F1.F1_FORNECE AND A1.A1_LOJA = F1.F1_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF

cQuery += "			WHERE " + CRLF

If _lSF1Comp
	cQuery += "				F1.F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
Else
	cQuery += "				F1.F1_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cNota) .And. Empty(cSerie)
	cQuery += "				CAST((F1.F1_XDTALT + ' ' + F1.F1_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((F1.F1_XDTALT + ' ' + F1.F1_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "				F1.F1_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "				F1.F1_SERIE = '" + cSerie + "' AND " + CRLF
EndIf 

cQuery += "			F1.F1_XENVWMS IN (' ','1') AND " + CRLF
cQuery += "			F1.F1_TIPO IN ('D','B') AND " + CRLF
cQuery += "			F1.D_E_L_E_T_ = '' " + CRLF
cQuery += "		) NF_NORMAL_DEVOLUCAO " + CRLF
cQuery += "	) NFENTRADA " + CRLF
cQuery += "	WHERE RNUM > " + cTamPage + " * (" + cPage + " - 1) " 

MemoWrite("/views/DNAPI006.txt",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	LogExec("NAO EXISTEM DADOS PARA SEREM ENVIADOS.")
	(cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ApiQryTot

@description Retorna total de pre notas

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
cQuery += "		COUNT(DISTINCT F1.F1_DOC) TOTREG " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "			" + RetSqlName("SF1") + " F1 " + CRLF

cQuery += "			INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = F1.F1_FILIAL AND D1.D1_DOC = F1.F1_DOC AND D1.D1_SERIE = F1.F1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE AND D1.D1_LOJA = F1.F1_LOJA AND D1.D1_PEDIDO <> '' AND D1.D1_ITEMPC <> '' AND D1.D_E_L_E_T_ = '' " + CRLF 
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = F1.F1_FORNECE AND A1.A1_LOJA = F1.F1_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF    
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SA2") + " A2 ON A2.A2_FILIAL = D1.D1_FILIAL AND A2.A2_COD = F1.F1_FORNECE AND A2.A2_LOJA = F1.F1_LOJA AND A2.D_E_L_E_T_ = '' " + CRLF

cQuery += "		WHERE " + CRLF

If _lSF1Comp
	cQuery += "				F1.F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
Else
	cQuery += "				F1.F1_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cNota) .And. Empty(cSerie) 
	cQuery += "			CAST((F1.F1_XDTALT + ' ' + F1.F1_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "			CAST((F1.F1_XDTALT + ' ' + F1.F1_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "			F1.F1_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "			F1.F1_SERIE = '" + cSerie + "' AND " + CRLF
EndIf
 
cQuery += "		F1.F1_XENVWMS IN (' ','1') AND " + CRLF
cQuery += "		F1.F1_TIPO IN ('N','D','B') AND " + CRLF
cQuery += "		F1.F1_STATUS = '' AND " + CRLF
cQuery += "		F1.D_E_L_E_T_ = '' " + CRLF

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
/*/{Protheus.doc} DnaApi06P

@description Estorna pré nota de entrada envia e-mail com as divergencias. 

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function

/*/
/*************************************************************************************/
Static Function DnaApi06P(_cNota,_cSerie,_cCodFor,_cLojafor,_aDiverg)
Local aArea			:= GetArea()

Local cMsgErro 		:= ""
Local cLiArq		:= ""
Local cSD3Log		:= ""

Local aCabec		:= {}
Local aItem			:= {}
Local aItems		:= {}

Local nHndImp		:= 0

Local lRet			:= .T.

//--------------+
// Envia e-Mail |
//--------------+
DnApi06M(_cNota,_cSerie,_cCodFor,_cLojafor,_aDiverg)

//---------------------------------+
// Posiciona Cabeçalho da Pre Nota |
//---------------------------------+
dbSelectArea("SF1")
SF1->( dbSetOrder(1) )

//-----------------------------+
// Posiciona Itens da Pre Nota | 
//-----------------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//-----------------------------+
// Adiciona dados do cabeçalho |
//-----------------------------+
If !SF1->( dbSeek(xFilial("SF1") + _cNota + _cSerie + _cCodFor + _cLojafor) )
	RestArea(aArea)
	Return .F.
EndIf

aAdd(aCabec,{"F1_DOC"       ,_cNota        		,NIL})
aAdd(aCabec,{"F1_SERIE"     ,_cSerie      		,NIL})
aAdd(aCabec,{"F1_FORNECE"   ,SA2->A2_COD   		,NIL})
aAdd(aCabec,{"F1_LOJA"      ,SA2->A2_LOJA  		,NIL})

//-------------------+
// Itens da Pré Nota | 
//-------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )
SD1->( dbSeek(xFilial("SD1") + _cNota + _cSerie + _cCodFor + _cLojafor))
While SD1->( !Eof() .And. xFilial("SD1") + _cNota + _cSerie + _cCodFor + _cLojafor == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA )  	
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB1->( dbSeek(xFilial("SB1") + SD1->D1_COD) )
	
	aAdd(aItem, {"D1_FILIAL"	,	xFilial("SD1")			, Nil })
	aAdd(aItem, {"D1_COD"   	, 	SD1->D1_COD				, Nil })
	aAdd(aItem, {"D1_QUANT" 	, 	SD1->D1_QUANT			, Nil })
	aAdd(aItem, {"D1_VUNIT" 	, 	SD1->D1_VUNIT 			, Nil })
	aAdd(aItem, {"D1_TOTAL" 	,   SD1->D1_TOTAL 			, Nil })
	aAdd(aItem, {"D1_UM"    	, 	SD1->D1_UM				, Nil })
	aAdd(aItem, {"D1_LOCAL" 	, 	SD1->D1_LOCAL			, Nil })
	aAdd(aItem, {"D1_DOC" 		, 	SD1->D1_DOC				, Nil })
	aAdd(aItem, {"D1_SERIE"		, 	SD1->D1_SERIE			, Nil })
	
	aAdd(aItems,aItem)
	
	SD1->( dbSkip() )	
	
EndDo

If Len(aCabec) > 0 .And. Len(aItems) > 0
	
	lMsErroAuto := .F.
	
	MSExecAuto({|x,y,z| Mata140(x,y,z) }, aCabec, aItems, 5)
	
	If lMsErroAuto
		MakeDir("\erros\")
		cSD3Log := "DNAPI06" + RTrim(_cNota) + "_" + RTrim(_cSerie) + "_" + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".LOG"
		MostraErro("\erros\",cSD3Log)
		
		DisarmTransaction()
		lRet := .F. 
		
		cMsgErro := ""
		cLiArq	 := ""
		nHndImp	 := 0	
		nHndImp  := FT_FUSE("\erros\" + cSD3Log)
		If nHndImp >= 1
			//-----------------------------+
			// Posiciona Inicio do Arquivo |
			//-----------------------------+
			FT_FGOTOP()
			
			While !FT_FEOF()
				cLiArq := FT_FREADLN()
				If Empty(cLiArq)
					FT_FSKIP(1)
					Loop
				EndIf
				cMsgErro += cLiArq + CRLF
				FT_FSKIP(1)
			EndDo
			FT_FUSE()
		EndIf  
		
		//---------------------+
		// Variavel de retorno |
		//---------------------+
		LogExec(_cNota + " " + _cSerie + "ERRO AO ESTORNAR PRE NOTA : " +  cMsgErro)
		aAdd(aMsgErro,{_cNota,_cSerie,.F.,"ERRO AO ESTORNAR PRE NOTA : " +  cMsgErro })
	Else
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)
Return lRet 

/*************************************************************************************/
/*/{Protheus.doc} DnApi06M

@description Envia e-mail com a divergencia da pré nota 

@author Bernard M. Margarido
@since 21/11/2018
@version 1.0
@type function
/*/
/*************************************************************************************/
Static Function DnApi06M(_cNota,_cSerie,_cCodFor,_cLojafor,_aDiverg)
Local aArea		:= GetArea()

Local cServer	:= GetMv("MV_RELSERV")
Local cUser		:= GetMv("MV_RELAUSR")
Local cPassword := GetMv("MV_RELAPSW")
Local cFrom		:= GetMv("MV_RELACNT")

Local cMail		:= GetNewPar("DN_MAILWMS","bernard.modesto@alfaerp.com.br;bernard.margarido@gmail.com")
Local cTitulo	:= "Dana - Divergencia recebimento."
Local cHtml		:= ""

Local lEnviado	:= .F.
Local lOk		:= .F.
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)

//---------------------------------+
// Posiciona Cabeçalho da Pre Nota |
//---------------------------------+
dbSelectArea("SF1")
SF1->( dbSetOrder(1) )

//-----------------------------+
// Posiciona Itens da Pre Nota | 
//-----------------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//-----------------------------+
// Adiciona dados do cabeçalho |
//-----------------------------+
If !SF1->( dbSeek(xFilial("SF1") + _cNota + _cSerie + _cCodFor + _cLojafor) )
	RestArea(aArea)
	Return .F.
EndIf

//---------------------+
// Valida Tipo de Nota | 
//---------------------+
If SF1->F1_TIPO == "N"
	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA) )
	_cCliFor	:= SA2->A2_COD
	_cLoja		:= SA2->A2_LOJA
	_cNReduz	:= SA2->A2_NREDUZ
Else
	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	SA1->( dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA) )
	_cCliFor	:= SA1->A1_COD
	_cLoja		:= SA1->A1_LOJA
	_cNReduz	:= SA1->A1_NREDUZ 
EndIf

cHtml := '<html>' + CRLF
cHtml += '	<head>' + CRLF
cHtml += '		<title>Pre Nota</title>' + CRLF
cHtml += '		<style>' + CRLF
cHtml += '			body {font-family: arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '			div {font-family: arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '			table {font-family: arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '			td {font-family:arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '			.mini {font-family:arial, helvetica, sans-serif; font-size: 10px}'
cHtml += '			form {margin: 0px}'
cHtml += '			.s_a  {font-size: 28px; vertical-align: top; width: 100%; color: #ffffff; font-family: arial, helvetica, sans-serif; background-color: #6baccf; text-align: center}'
cHtml += '			.s_b  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #ffff99; text-align: left}'
cHtml += '			.s_c  {font-size: 12px; vertical-align: top; width: 05% ; color: #ffffff; font-family: arial, helvetica, sans-serif; background-color: #6baccf; text-align: left}'
cHtml += '			.s_d  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #e8e8e8; text-align: left}'
cHtml += '			.s_o  {font-size: 12px; vertical-align: top; width: 05% ; font-family: arial, helvetica, sans-serif; text-align: left}'
cHtml += '			.s_t  {font-size: 16px; vertical-align: top; width: 100%; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #e8e8e8; text-align: center}'
cHtml += '			.s_u  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; text-align: left}'
cHtml += '		</style>' + CRLF
cHtml += '	</head>' + CRLF
cHtml += '	<body>' + CRLF
cHtml += '		<table style="color: rgb(0,0,0)" width="100%" border=1>' + CRLF
cHtml += '			<tbody>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_a width="100%"><p align=center><b>Pré Nota de Entrada - Divergência WMS</b></p></td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '			</tbody>' + CRLF
cHtml += '		</table>' + CRLF
cHtml += '		<table style="color: rgb(0,0,0)" width="100%" cellspacing=0 border=0>' + CRLF
cHtml += '			<tbody>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_t width="100%"><p align=center><b>Dados da Pré Nota</b></p></td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '			</tbody>' + CRLF
cHtml += '		</table>' + CRLF
cHtml += '		<table style="width: 100%; height: 26px" cellspacing=0 border=1>' + CRLF
cHtml += '			<tbody>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_u colspan = "1"><b>Documento:</b> ' + ' ' + SF1->F1_DOC + '</td>' + CRLF
cHtml += '					<td class=s_u colspan = "4"><b>Serie:</b> ' + ' ' + SF1->F1_SERIE +  '</td> ' + CRLF
cHtml += '					<td class=s_u colspan = "2"><b>Emissão:</b>' + ' ' + FsDateConv(SF1->F1_EMISSAO,"DDMMYYYY") + '</td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_u colspan = "7"><b>Fornecedor:</b>' + ' ' + _cCliFor + ' - ' + _cLoja + ' '   + _cNReduz + '</td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '			</tbody>' + CRLF
cHtml += '		</table>' + CRLF
cHtml += '		<table style="color: rgb(0,0,0)" width="100%" cellspacing=0 border=0>' + CRLF
cHtml += '			<tbody>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_t width="100%"><p align=center><b>Itens Pré Nota</b></p></td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '			</tbody>' + CRLF
cHtml += '		</table>' + CRLF
cHtml += '		<table style="width: 100%; height: 26px" cellspacing=0 border=1>' + CRLF
cHtml += '			<tbody>' + CRLF
cHtml += '				<tr>' + CRLF  					
cHtml += '					<td class=s_u colspan = "1"><b>Item</b></td>' + CRLF
cHtml += '					<td class=s_u colspan = "3"><b>Produto</b></td>' + CRLF
cHtml += '					<td class=s_u colspan = "6"><b>Descricao</b></td>' + CRLF
cHtml += '					<td class=s_u colspan = "1"><b>Qtd. Nota</b></td>' + CRLF
cHtml += '					<td class=s_u colspan = "1"><b>Qtd. Conf.</b></td>' + CRLF
cHtml += '					<td class=s_u colspan = "1"><b>Armazem</b></td>' + CRLF
cHtml += '				</tr>' + CRLF
//-------------------+
// Itens da Pré Nota | 
//-------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )

For _nX := 1 To Len(_aDiverg)
	
	//------------------------+
	// Posiciona Item da Nota | 
	//------------------------+
	SD1->( dbSeek(xFilial("SD1") + _cNota + _cSerie + _cCodFor + _cLojafor +  _aDiverg[_nX][2] + _aDiverg[_nX][1] ))
	
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB1->( dbSeek(xFilial("SB1") + _aDiverg[_nX][2]) )
	
	cHtml += '				<tr>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SD1->D1_ITEM + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "3"><b></b>' + SD1->D1_COD + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "6"><b></b>' + SB1->B1_DESC + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(SD1->D1_QUANT)) + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(_aDiverg[_nX][3])) + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SD1->D1_LOCAL + '</td>' + CRLF
	cHtml += '				</tr>' + CRLF
	
Next _nX	

cHtml += '			</tbody>' + CRLF
cHtml += '		</table>' + CRLF
cHtml += '		<p>Workflow enviado automaticamente pelo Protheus - Perfumes Dana</p>' + CRLF
cHtml += '	</body>' + CRLF
cHtml += '</html>'

//-------------------------------------------------------------+
// Verifica usuario e senha para conectar no servidor de saida |
//-------------------------------------------------------------+
CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPassword RESULT lOk

//---------------------------+
// Autentica usuario e senha |
//---------------------------+
If lRelauth
	lOk := MailAuth(cUser,cPassword)
EndIf	

//--------------------------------------------------------------+
// Verifica se conseguiu conectar no servidor de saida e valida |
// se conseguiu atenticar para enviar o e-mail                  |
//--------------------------------------------------------------+
If lOk
	SEND MAIL FROM cFrom TO cMail SUBJECT cTitulo BODY cHtml RESULT lEnviado 
Else
	Conout("Erro ao Conectar ! ")
Endif			

If lEnviado
	Conout("E-Mail Enviado com sucesso ")
Else                            
	GET MAIL ERROR cError
	Conout("Erro ao enviar e-mail --> " + cError)	
EndIf	

//---------------------------------+
// Disconecta do servidor de saida |
//---------------------------------+
DISCONNECT SMTP SERVER

RestArea(aArea)
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} DnaApi06E

@description Processa retorno da conferencia pre nota de entrada 

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnaApi06E(aMsgErro,cJsonRet)
Local oJsonRet	:= Nil
Local oNFE		:= Nil

Local nMsg		:= 0

oJsonRet					:= Array(#)
oJsonRet[#"nfe"]			:= {}
	
For nMsg := 1 To Len(aMsgErro)
	aAdd(oJsonRet[#"nfe"],Array(#))
	oNFE := aTail(oJsonRet[#"nfe"])
	oNFE[#"filial"]		:= aMsgErro[nMsg][1]
	oNFE[#"nota"]		:= aMsgErro[nMsg][2]
	oNFE[#"serie"]		:= aMsgErro[nMsg][3]
	oNFE[#"status"]		:= aMsgErro[nMsg][4]
	oNFE[#"msg"]		:= aMsgErro[nMsg][5]
Next nMsg

//---------------------------+
// Transforma Objeto em JSON |
//---------------------------+
cJsonRet := EncodeUtf8(xToJson(oJsonRet))	

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