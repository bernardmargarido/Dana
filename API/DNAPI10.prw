#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "010"
Static cDescInt	:= "NOTA"
Static cDirRaiz := "\wms\"

Static nTNota	:= TamSx3("F2_DOC")[1]
Static nTSerie	:= TamSx3("F2_SERIE")[1]
Static nTCodCli	:= TamSx3("A1_COD")[1]
Static nTLoja	:= TamSx3("A1_LOJA")[1]
Static nTProd	:= TamSx3("B1_COD")[1]
Static nTItem	:= TamSx3("C6_ITEM")[1]
Static nTLote	:= TamSx3("C6_LOTECTL")[1]
	
/************************************************************************************/
/*/{Protheus.doc} NOTA

@description API - Envia dados das notas para separação

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type class
/*/
/************************************************************************************/
WSRESTFUL NOTA_SEPARACAO DESCRIPTION " Servico Perfumes Dana - Processo Separação."
	
	WSDATA FILIAL		AS STRING
	WSDATA NOTA 		AS STRING
	WSDATA SERIE 		AS STRING
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET  	DESCRIPTION "Retorna dados da nota fiscal para separação - Perfumes Dana " WSSYNTAX "/API/PEDIDO/GET/pedido/datahora{Data Hora da ultima Atualização}"
	WSMETHOD POST 	DESCRIPTION "Recebe dados da separação da nota fiscal - Perfumes Dana " WSSYNTAX "/API/PEDIDO/POST"
	WSMETHOD PUT 	DESCRIPTION "Recebe dados da separação da nota fiscal - Perfumes Dana " WSSYNTAX "/API/PEDIDO/PUT"
	
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} GET

@description Retorna string JSON com os pedidos para separação

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD GET WSRECEIVE FILIAL,NOTA,SERIE,DATAHORA,PERPAGE,PAGE WSSERVICE NOTA_SEPARACAO
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cFilNF		:= IIF(Empty(::FILIAL),"",::FILIAL)
Local cNota			:= IIF(Empty(::NOTA),"",::NOTA)
Local cSerie		:= IIF(Empty(::SERIE),"",::SERIE)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE
Local cFilAux		:= cFilAnt

Local nLen			:= Len(::aUrlParms)

Private cArqLog		:= ""
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

Private _lSF2Comp 	:= ( FWModeAccess("SF2",3) == "C" )

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "NOTA_FISCAL_SEPARACAO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DAS NOTAS FISCAIS DE VENDA PARA SEPARACAO AO WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//-----------------------------------+
// JSON Envia Pedidos para separação |
//-----------------------------------+
aRet := DnaApi10A(cFilNF,cNota,cSerie,cDataHora,cTamPage,cPage) 

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

LogExec("FINALIZA ENVIO DAS NOTAS FISCAIS DE VENDA PARA SEPARACAO AO WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} POST

@description Metodo POST - Retorna dados conferidos da separação.

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE NOTA_SEPARACAO
Local aArea		:= GetArea()

Local nLen		:= Len(::aUrlParms)
Local nPed		:= 0

Local oJson		:= Nil
Local oPedido	:= Nil

Private cJsonRet:= ""
	
Private aMsgErro:= {}

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "NOTA_RETORNO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA RETORNO SEPARACAO DAS NOTAS DE SAIDA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

oPedido	:= oJson[#"notas"]

//---------------------------------------------+
// Inicia a Gravacao / Atualização dos Pedidos |
//---------------------------------------------+
For nPed := 1 To Len(oPedido)	
	LogExec("INICIA VALIDACAO DA SEPARACAO DA NOTA " + LTrim(oPedido[nPed][#"notas"]) )
	DnaApi10B(oPedido[nPed])
Next nPed	

//----------------------+
// Cria JSON de Retorno |
//----------------------+	
If Len(aMsgErro) > 0
	DnaApi10E(aMsgErro,@cJsonRet)
EndIf
	
//----------------+
// Retorno da API |
//----------------+
::SetResponse(cJsonRet)
HTTPSetStatus(200,"OK")

LogExec("FINALIZA RETORNO SEPARACAO DAS NOTAS DE SAIDA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} PUT

@description Metodo PUT - Retorna dados conferidos da separação.

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
WSMETHOD PUT WSSERVICE NOTA_SEPARACAO
Local aArea		:= GetArea()

Local nLen		:= Len(::aUrlParms)
Local nPed		:= 0

Local oJson		:= Nil
Local oPedido	:= Nil

Private cJsonRet:= ""
	
Private aMsgErro:= {}

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "NOTA_BAIXA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA BAIXA DA NOTA DE SAIDA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

oPedido	:= oJson[#"notas"]

//---------------------------------------------+
// Inicia a Gravacao / Atualização dos Pedidos |
//---------------------------------------------+
For nPed := 1 To Len(oPedido)	
	LogExec("INICIA VALIDACAO DA BAIXA DA NOTA " + LTrim(oPedido[nPed][#"notas"]) )
	DnaApi10C(oPedido[nPed])
Next nPed	

//----------------------+
// Cria JSON de Retorno |
//----------------------+	
If Len(aMsgErro) > 0
	DnaApi10E(aMsgErro,@cJsonRet)
EndIf
	
//----------------+
// Retorno da API |
//----------------+
::SetResponse(cJsonRet)
HTTPSetStatus(200,"OK")

LogExec("FINALIZA BAIXA DA NOTA DE SAIDA - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

//------------------------+
// Restaura a Filila REST |
//------------------------+
If cFilAux <> cFilAnt
	cFilAnt := cFilAux
EndIf

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi10A

@description Consulta pedidos de separacao e monta arquivo de envio

@author Bernard M. Margarido
@since 10/11/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApi10A(cFilNF,cNota,cSerie,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}

Local cAlias	:= GetNextAlias()	
Local cRest		:= ""
Local cPedVen 	:= ""
Local cCodCli	:= ""
Local cLoja		:= ""
Local cCodTransp:= ""
Local dDtaEmiss	:= ""

Local oJson		:= Nil
Local oPedido	:= Nil
Local oItens	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "50" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cFilNF,cNota,cSerie,cDataHora,cTamPage,cPage)
	
	oJson			:= Array(#)
	oJson[#"error"]	:= {}
	
	aAdd(oJson[#"error"],Array(#))
	oPedido := aTail(oJson[#"error"])
	oPedido[#"msg"] := "Nao existem dados para serem retornados."
	
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
oJson[#"notas"]		:= {}

While (cAlias)->( !Eof() )
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"notas"],Array(#))
	oPedido := aTail(oJson[#"notas"])
	
	cFilAut		:= (cAlias)->FILIAL
	cNota		:= (cAlias)->NOTA
	cSerie		:= (cAlias)->SERIE
	cCodCli		:= (cAlias)->CLIENTE
	cLoja		:= (cAlias)->LOJA
	cCodTransp	:= (cAlias)->CODTRANSP
	cTipoPV		:= (cAlias)->TIPO
	
	_nTotalPv	:= (cAlias)->TOTALNF
	
	dDtaEmiss	:= dToc(sTod((cAlias)->EMISSAO))
				 
	//-------------------------------+
	// Cria cabeçalho do pedido JSON |
	//-------------------------------+
	oPedido[#"filial"]				:= cFilAut
	oPedido[#"nota"]				:= cNota
	oPedido[#"serie"]				:= cSerie
	oPedido[#"codigo_cliente"]		:= cCodCli
	oPedido[#"loja"]				:= cLoja
	oPedido[#"transportadora"]		:= cCodTransp
	oPedido[#"data_emissao"]		:= dDtaEmiss
	oPedido[#"tipo_nota"]			:= cTipoPV
	oPedido[#"total_nota"]			:= _nTotalPv	
	
	//------------------------------------+
	// Cria array para os itens do pedido |
	//------------------------------------+
	oPedido[#"itens"]				:= {}
	
	While (cAlias)->( !Eof() .And. cFilAut + cNota + cSerie == (cAlias)->FILIAL + (cAlias)->NOTA + (cAlias)->SERIE )
		
		//-----------------+
		// Itens do pedido |
		//-----------------+
		aAdd(oPedido[#"itens"],Array(#))
		oItens := aTail(oPedido[#"itens"])
		oItens[#"item"]			:= (cAlias)->ITEM 
		oItens[#"produto"]		:= (cAlias)->PRODUTO 
		oItens[#"quantidade"]	:= (cAlias)->QTDLIB
		oItens[#"valor_unit"]	:= (cAlias)->PRCVEN
		oItens[#"valor_total"]	:= (cAlias)->PRCTOTAL
		oItens[#"um"]			:= (cAlias)->UM
		oItens[#"lote"]			:= (cAlias)->LOTE
		oItens[#"data_validade"]:= (cAlias)->DTVALID
		oItens[#"armazem"]		:= (cAlias)->ARMAZEM
		oItens[#"pedido"]		:= (cAlias)->PEDIDO
		
		(cAlias)->( dbSkip() )
	EndDo
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
/*/{Protheus.doc} DnaApi10B

@description Realiza conferencia das notas separados pelo WMS

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function DnaApi10B(_oPedido)
Local aArea		:= GetArea()

Local _cPedido	:= ""
Local _cCodCli	:= ""
Local _cLoja	:= ""
Local _cCodProd	:= ""
Local _cItem	:= ""
Local _cLote	:= ""
Local _cFilAux	:= cFilAnt
	
Local _nQtdConf	:= 0
Local _nPed		:= 0

Local _aDiverg	:= {}

Local _lContinua:= .T.	

Local _oItPed	:= Nil

//------------------------+
// Posiciona Filial atual | 
//------------------------+
cFilAnt := RTrim(_oPedido[#"filial"])

//---------------+
// Dados da Nota |
//---------------+
_cNota		:= PadR(_oPedido[#"nota"],nTNota)
_cSerie		:= PadR(_oPedido[#"serie"],nTSerie)
_cCodCli	:= PadR(_oPedido[#"codigo_cliente"],nTCodCli)
_cLoja		:= PadR(_oPedido[#"loja"],nTLoja)
_nVolume	:= _oPedido[#"volume"]
_nPeso		:= _oPedido[#"peso"]

//-----------------------------+
// Posiciona cabecalho da Nota |
//-----------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cNota + _cSerie + _cCodCli + _cLoja) )
	LogExec("NOTA " + _cNota + " SERIE " + _cSerie + " NAO LOCALIZADO")
	aAdd(aMsgErro,{cFilAnt,_cNota+_cSerie,.F.,"NOTA NAO LOCALIZADO" })
	RestArea(aArea)
	Return .F.
EndIf

//---------------------------------+
// Valida se nota já foi conferido | 
//---------------------------------+
If SF2->F2_XENVWMS == "3"
	LogExec("NOTA " + _cNota + " SERIE " + _cSerie + " JÁ SEPARADO.")
	aAdd(aMsgErro,{cFilAnt,_cNota+_cSerie,.F.,"JÁ SEPARADO."})
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------+
// Posiciona Itens da Nota | 
//-------------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )

//-----------------------------------------------------+
// Valida conferencia dos itens da Pre Nota de Entrada | 
//-----------------------------------------------------+
_oItPed 	:= _oPedido[#"itens"]
_lContinua	:= .T.
For _nPed := 1 To Len(_oItPed)
		
	//-----------------+
	// Dados dos Itens |
	//-----------------+
	_cCodProd	:= PadR(_oItPed[_nPed][#"produto"],nTProd)
	_cItem		:= PadL(_oItPed[_nPed][#"item"],nTItem,"0")
	_cLote		:= PadR(_oItPed[_nPed][#"lote"],nTLote)	
	_nQtdConf	:= _oItPed[_nPed][#"quantidade"]
	
	//------------------------+
	// Posiciona Item da Nota |
	//------------------------+
	If !SD2->( dbSeek(xFilial("SD2") + _cNota + _cSerie + _cCodCli  + _cLoja + _cCodProd + _cItem) )
		LogExec(" ITEM/PRODUTO " + _cItem + "/" + _cCodProd + " NAO LOCALIZADO.")
		aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.F.," ITEM/PRODUTO " + _cItem + "/" + _cCodProd + " NAO LOCALIZADO." })
		_lContinua := .F.
		Loop
	EndIf
		
	//--------------------+
	// Valida conferencia |
	//--------------------+
	If _lContinua
		If _nQtdConf <> SC9->C9_QTDLIB
			//-------------------+
			// Array Divergencia |
			//-------------------+
		 	aAdd(_aDiverg,{ SD2->D2_ITEM		,;	// 1 - Item Pre Nota
		 					SD2->D2_COD			,;	// 2 - Codigo do Produto
							_nQtdConf			,;	// 3 - Quantidade Transferida
							SD2->D2_LOTECTL		,;	// 4 - Lote Produto
							SD2->D2_LOCAL		})	// 5 - Armazem 	
		EndIf 
	EndIf			
		
Next _nPed

If _lContinua
	//-------------------------------------+
	// Esorna liberação do pedido de venda | 
	//-------------------------------------+
	If Len(_aDiverg) > 0
	
		DnaApi10P(_cNota, _cSerie,_cCodCli,_cLoja,_aDiverg)
		//----------------------+	
		// Log processo da nota |
		//----------------------+
		LogExec(_cNota + _cSerie + "DIVERGENCIA SEPARAÇÃO.")
		aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.F.,"DIVERGENCIA SEPARAÇÃO."})
		
	//------------------------------+	
	// Libera faturamento do pedido |
	//------------------------------+	 
	Else
	
		RecLock("SF2",.F.)
			SF2->F2_XENVWMS := "3"
			//SF2->F2_ESPECI1	:= "CAIXAS"
			//SF2->F2_PESOL	:= _nPeso
			//SF2->F2_PBRUTO	:= _nPeso
			//SF2->F2_VOLUME1	:= _nVolume
		SF2->( MsUnLock() )
			
		//----------------------+	
		// Log processo da nota |
		//----------------------+
		LogExec(_cPedido + "CONFERENCIA REALIZADA COM SUCESSO.")
		aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.T.,"CONFERENCIA REALIZADA COM SUCESSO."})

	EndIf
EndIf

//-------------------------+
// Restaura a filial atual |
//-------------------------+ 
cFilAnt := _cFilAux

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi10C

@description Realiza a baixa dos pedidos 

@author Bernard M. Margarido
@since 08/12/2018
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function DnaApi10C(_oPedido)
Local _aArea	:= GetArea()

Local _cFilAux	:= cFilAnt
Local _cNota	:= PadR(_oPedido[#"nota"],nTNota)
Local _cSerie	:= PadR(_oPedido[#"serie"],nTSerie)
Local _cCodCli	:= PadR(_oPedido[#"codigo_cliente"],nTCodCli)
Local _cLoja	:= PadR(_oPedido[#"loja"],nTLoja)

//------------------------+
// Posiciona filial atual | 
//------------------------+
cFilAnt := RTrim(_oPedido[#"filial"])

dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cNota + _cSerie + _cCodCli + _cLoja) )
	LogExec("NOTA " + _cNota + " SERIE " + _cSerie + " NAO LOCALIZADO")
	aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.F.,"NOTA NAO LOCALIZADO" })
	RestArea(aArea)
	Return .F.
EndIf

//----------------------------------+
// Valida se Pedido já foi expedido | 
//----------------------------------+
If SF2->F2_XENVWMS == "3"
	aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.F.,"NOTA JÁ SEPARADO."})
	RestArea(_aArea)
	Return .F.
EndIf

//---------------------------+
// Atualiza Status do Pedido |
//---------------------------+
RecLock("SF2",.F.)
	SF2->F2_XENVWMS := "2"
SF2->( MsUnLock() )

aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.T.,"NOTA BAIXADO COM SUCESSO."})

//-------------------------+
// Restaura a filial atual |
//-------------------------+
cFilAnt := _cFilAux

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApiQry

@description Consulta pedidos de venda para serem enviados para separação 

@author Bernard M. Margarido
@since 27/10/2018
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function DnaApiQry(cAlias,cFilNF,cNota,cSerie,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//--------------------------+
// Cosulta total de pedidos | 
//--------------------------+
If !DnaQryTot(cFilNF,cNota,cSerie,cDataHora,cTamPage,cPage)
	Return .F.
EndIf

cQuery := "	SELECT " + CRLF
cQuery += "		TOP(" + cTamPage + ") RNUM, " + CRLF
cQuery += "		FILIAL, " + CRLF
cQuery += "		NOTA, " + CRLF
cQuery += "		SERIE, " + CRLF
cQuery += "		CLIENTE, " + CRLF
cQuery += "		LOJA, " + CRLF
cQuery += "		CODTRANSP, " + CRLF
cQuery += "		EMISSAO, " + CRLF
cQuery += "		TIPO, " + CRLF
cQuery += "		TOTALNF, " + CRLF
cQuery += "		RECNOSF2, " + CRLF
cQuery += "		ITEM, " + CRLF
cQuery += "		PRODUTO, " + CRLF
cQuery += "		QTDLIB, " + CRLF
cQuery += "		PRCVEN, " + CRLF
cQuery += "		PRCTOTAL, " + CRLF
cQuery += "		UM, " + CRLF
cQuery += "		LOTE, " + CRLF
cQuery += "		DTVALID, " + CRLF
cQuery += "		PEDIDO, " + CRLF
cQuery += "		ARMAZEM " + CRLF
cQuery += "	FROM ( " + CRLF
cQuery += "			SELECT " + CRLF
cQuery += "				ROW_NUMBER() OVER(ORDER BY F2.F2_DOC) RNUM, " + CRLF
cQuery += "				F2.F2_FILIAL FILIAL, " + CRLF
cQuery += "				F2.F2_DOC NOTA, " + CRLF
cQuery += "				F2.F2_SERIE SERIE, " + CRLF
cQuery += "				F2.F2_CLIENTE CLIENTE, " + CRLF
cQuery += "				F2.F2_LOJA LOJA, " + CRLF
cQuery += "				F2.F2_TRANSP CODTRANSP, " + CRLF
cQuery += "				F2.F2_EMISSAO EMISSAO, " + CRLF
cQuery += "				F2.F2_TIPO TIPO, " + CRLF
cQuery += "				F2.F2_VALFAT TOTALNF, " + CRLF
cQuery += "				F2.R_E_C_N_O_ RECNOSF2, " + CRLF
cQuery += "				D2.D2_ITEM ITEM, " + CRLF
cQuery += "				D2.D2_COD PRODUTO, " + CRLF
cQuery += "				D2.D2_QUANT QTDLIB, " + CRLF
cQuery += "				D2.D2_PRCVEN PRCVEN, " + CRLF
cQuery += "				D2.D2_TOTAL PRCTOTAL, " + CRLF
cQuery += "				D2.D2_UM UM, " + CRLF
cQuery += "				D2.D2_LOTECTL LOTE, " + CRLF
cQuery += "				D2.D2_DTVALID DTVALID, " + CRLF
cQuery += "				D2.D2_PEDIDO PEDIDO, " + CRLF
cQuery += "				D2.D2_LOCAL ARMAZEM " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SF2") + " F2 " + CRLF
cQuery += "				INNER JOIN " + RetSqlName("SD2") + " D2 ON D2.D2_FILIAL = F2.F2_FILIAL AND D2.D2_DOC = F2.F2_DOC AND D2.D2_SERIE = F2.F2_SERIE AND D2.D2_CLIENTE = F2.F2_CLIENTE AND D2.D2_LOJA = F2.F2_LOJA AND D2.D_E_L_E_T_ = '' " + CRLF
cQuery += "			WHERE " + CRLF

If Empty(cFilNF)
	If _lSF2Comp
		cQuery += "				F2.F2_FILIAL = '" + xFilial("SF2") + "' AND " + CRLF
	Else
		cQuery += "				F2.F2_FILIAL IN" + _cFilWMS + " AND " + CRLF
	EndIf
Else
	cQuery += "				F2.F2_FILIAL = '" + cFilNF + "' AND " + CRLF
Endif

If Empty(cNota) .And. Empty(cSerie)
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "				F2.F2_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "				F2.F2_SERIE = '" + cSerie + "' AND " + CRLF
EndIf

cQuery += "			F2.F2_XENVWMS IN('1') AND " + CRLF
cQuery += "			F2.F2_TIPO IN('N','D','B') AND " + CRLF
cQuery += "			F2.D_E_L_E_T_ = ''  " + CRLF
cQuery += "	) PEDIDO  " + CRLF
cQuery += "	WHERE RNUM > " + cTamPage + " * (" + cPage + " - 1) " + CRLF 
cQuery += "	ORDER BY FILIAL,PEDIDO"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	LogExec("NAO EXISTEM DADOS PARA SEREM ENVIADOS.")
	(cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.

/*************************************************************************************/
/*/{Protheus.doc} ApiQryTot

@description Retorna total de Pedidos

@author Bernard M. Margarido
@since 27/10/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnaQryTot(cFilNF,cNota,cSerie,cDataHora,cTamPage,cPage)
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
cQuery += "		COUNT(*) TOTREG " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "		" + RetSqlName("SF2") + " F2 " + CRLF 
cQuery += "	WHERE " + CRLF

If Empty(cFilNF)
	If _lSF2Comp
		cQuery += "				F2.F2_FILIAL = '" + xFilial("SF2") + "' AND " + CRLF
	Else
		cQuery += "				F2.F2_FILIAL IN" + _cFilWMS + " AND " + CRLF
	EndIf
Else
	cQuery += "				F2.F2_FILIAL = '" + cFilNF + "' AND " + CRLF
Endif

If Empty(cNota) .And. Empty(cSerie)
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "				F2.F2_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "				F2.F2_SERIE = '" + cSerie + "' AND " + CRLF
EndIf

cQuery += "				F2.F2_XENVWMS IN('1') AND " + CRLF
cQuery += "				F2.F2_TIPO IN('N','D','B') AND " + CRLF
cQuery += "				F2.D_E_L_E_T_ = ''  " + CRLF

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
/*/{Protheus.doc} DnaApi10P

@description Estorna liberação do pedido 

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function

/*/
/*************************************************************************************/
Static Function DnaApi10P(_cNota, _cSerie,_cCodCli,_cLoja,_aDiverg)
Local aArea			:= GetArea()

Local lRet			:= .T.

//--------------+
// Envia e-Mail |
//--------------+
DnApi10M(_cNota, _cSerie,_cCodCli,_cLoja,_aDiverg)

//---------------------------------+
// Posiciona Cabeçalho da Pre Nota |
//---------------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

//-----------------------------+
// Posiciona cabecalho da Nota |
//-----------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cNota + _cSerie + _cCodCli + _cLoja) )
	RestArea(aArea)
	Return .F.
EndIf


//SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,lMostraCtb,lAglCtb,lContab,lCarteira))

//-------------------+
// Itens da Pré Nota | 
//-------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )
SC9->( dbSeek(xFilial("SC9") + _cPedido))
While SC9->( !Eof() .And. xFilial("SC9") + _cPedido == SC9->C9_FILIAL + SC9->C9_PEDIDO )  	
	If Empty(SC9->C9_NFISCAL) .And. Empty(SC9->C9_SERIENF)
		//--------------------------+
		// Estorna Liberação Pedido |
		//--------------------------+
		a460Estorna(.T.,.F.)
	EndIf	
	SC9->( dbSkip() )	
EndDo

RestArea(aArea)
Return lRet 

/*************************************************************************************/
/*/{Protheus.doc} DnApi07M

@description Envia e-mail com a divergencia separação dos pedidos 

@author Bernard M. Margarido
@since 21/11/2018
@version 1.0
@type function
/*/
/*************************************************************************************/
Static Function DnApi10M(_cNota, _cSerie,_cCodCli,_cLoja,_aDiverg)
Local aArea		:= GetArea()

Local cServer	:= GetMv("MV_RELSERV")
Local cUser		:= GetMv("MV_RELAUSR")
Local cPassword := GetMv("MV_RELAPSW")
Local cFrom		:= GetMv("MV_RELACNT")

Local cMail		:= GetNewPar("DN_MAILWMS","bernard.modesto@alfaerp.com.br;bernard.margarido@gmail.com")
Local cTitulo	:= "Dana - Divergencia separação."
Local cHtml		:= ""

Local _nX		:= 0

Local lEnviado	:= .F.
Local lOk		:= .F.
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)

//---------------------------------+
// Posiciona Cabeçalho da Pre Nota |
//---------------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

//-----------------------------+
// Posiciona Itens da Pre Nota | 
//-----------------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//-----------------------------+
// Posiciona cabecalho da Nota |
//-----------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cNota + _cSerie + _cCodCli + _cLoja) )
	RestArea(aArea)
	Return .F.
EndIf

//---------------------+
// Valida Tipo de Nota | 
//---------------------+
If SF2->F2_TIPO == "N"
	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	SA1->( dbSeek(xFilial("SA1") + _cCodCli + _cLoja) )
	_cCliFor	:= SA1->A1_COD
	_cLoja		:= SA1->A1_LOJA
	_cNReduz	:= SA1->A1_NREDUZ
Else
	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2") + _cCodCli + _cLoja) )
	_cCliFor	:= SA2->A2_COD
	_cLoja		:= SA2->A2_LOJA
	_cNReduz	:= SA2->A2_NREDUZ 
EndIf

cHtml := '<html>' + CRLF
cHtml += '	<head>' + CRLF
cHtml += '		<title>Pedido de Venda</title>' + CRLF
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
cHtml += '					<td class=s_a width="100%"><p align=center><b>Pedido de Venda - Divergência Separação WMS</b></p></td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '			</tbody>' + CRLF
cHtml += '		</table>' + CRLF
cHtml += '		<table style="color: rgb(0,0,0)" width="100%" cellspacing=0 border=0>' + CRLF
cHtml += '			<tbody>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_t width="100%"><p align=center><b>Dados Pedido de Venda</b></p></td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '			</tbody>' + CRLF
cHtml += '		</table>' + CRLF
cHtml += '		<table style="width: 100%; height: 26px" cellspacing=0 border=1>' + CRLF
cHtml += '			<tbody>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_u colspan = "2"><b>Numero:</b> ' + ' ' + SC5->C5_NUM + '</td>' + CRLF
cHtml += '					<td class=s_u colspan = "2"><b>Emissão:</b>' + ' ' + FsDateConv(SC5->C5_EMISSAO,"DDMMYYYY") + '</td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_u colspan = "7"><b>Cliente:</b>' + ' ' + _cCliFor + ' - ' + _cLoja + ' '   + _cNReduz + '</td>' + CRLF
cHtml += '				</tr>' + CRLF
cHtml += '			</tbody>' + CRLF
cHtml += '		</table>' + CRLF
cHtml += '		<table style="color: rgb(0,0,0)" width="100%" cellspacing=0 border=0>' + CRLF
cHtml += '			<tbody>' + CRLF
cHtml += '				<tr>' + CRLF
cHtml += '					<td class=s_t width="100%"><p align=center><b>Itens Pedido</b></p></td>' + CRLF
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

For _nX := 1 To Len(_aDiverg)
	
	//------------------------+
	// Posiciona Item da Nota | 
	//------------------------+
	SD2->( dbSeek(xFilial("SD2") + _cNota + _cSerie + _cCodCli  + _cLoja + _aDiverg[_nX][2] + _aDiverg[_nX][1]) )
	
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB1->( dbSeek(xFilial("SB1") + _aDiverg[_nX][2]) )
	
	cHtml += '				<tr>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SD2->D2_ITEM + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "3"><b></b>' + SD2->D2_COD + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "6"><b></b>' + SB1->B1_DESC + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(SD2->D2_QUANT)) + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(_aDiverg[_nX][3])) + '</td>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SD2->D2_LOCAL + '</td>' + CRLF
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
/*/{Protheus.doc} DnaApi10E

@description Processa retorno da conferencia separação pedido de venda

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnaApi10E(aMsgErro,cJsonRet)
Local oJsonRet	:= Nil
Local oPedidos	:= Nil

Local nMsg		:= 0

oJsonRet						:= Array(#)
oJsonRet[#"notas"]			:= {}
	
For nMsg := 1 To Len(aMsgErro)
	aAdd(oJsonRet[#"notas"],Array(#))
	oPedidos := aTail(oJsonRet[#"notas"])
	oPedidos[#"filial"]		:= aMsgErro[nMsg][1]
	oPedidos[#"notas"]		:= aMsgErro[nMsg][2]
	oPedidos[#"status"]		:= aMsgErro[nMsg][3]
	oPedidos[#"msg"]		:= aMsgErro[nMsg][4]
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