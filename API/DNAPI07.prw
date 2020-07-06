#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "007"
Static cDescInt	:= "PEDIDO"
Static cDirRaiz := "\wms\"

Static nTPed	:= TamSx3("C5_NUM")[1]
Static nTCodCli	:= TamSx3("A1_COD")[1]
Static nTLoja	:= TamSx3("A1_LOJA")[1]
Static nTProd	:= TamSx3("B1_COD")[1]
Static nTItem	:= TamSx3("C6_ITEM")[1]
Static nTLote	:= TamSx3("C6_LOTECTL")[1]
	
/************************************************************************************/
/*/{Protheus.doc} PEDIDO
	@description API - Envia dados dos pedidos para separação
	@author Bernard M. Margarido
	@since 10/11/2018
	@version 1.0
	@type class
/*/
/************************************************************************************/
WSRESTFUL PEDIDO DESCRIPTION " Servico Perfumes Dana - Processo Separação."
	
	WSDATA PEDIDO 		AS STRING	
	WSDATA DATAHORA		AS STRING
	WSDATA PERPAGE 		AS STRING	
	WSDATA PAGE			AS STRING
			
	WSMETHOD GET  	DESCRIPTION "Retorna dados dos pedidos para separação Perfumes Dana " WSSYNTAX "/API/PEDIDO/GET/pedido/datahora{Data Hora da ultima Atualização}"
	WSMETHOD POST 	DESCRIPTION "Recebe dados da separação dos pedidos Perfumes Dana " WSSYNTAX "/API/PEDIDO/POST"
	WSMETHOD PUT 	DESCRIPTION "Recebe dados da separação dos pedidos Perfumes Dana " WSSYNTAX "/API/PEDIDO/PUT"
	
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
WSMETHOD GET WSRECEIVE PEDIDO,DATAHORA,PERPAGE,PAGE WSSERVICE PEDIDO
Local aArea			:= GetArea()
Local aRet			:= {.F.,""}

Local cPedido		:= IIF(Empty(::PEDIDO),"",::PEDIDO)
Local cDataHora		:= IIF(Empty(::DATAHORA),"1900-01-01T00:00",::DATAHORA)
Local cTamPage		:= ::PERPAGE
Local cPage			:= ::PAGE

Local nLen			:= Len(::aUrlParms)

Private cArqLog		:= ""
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

Private _lSC5Comp 	:= ( FWModeAccess("SC5",3) == "C" )

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "PEDIDO_SEPARACAO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA ENVIO DOS PEDIDOS DE VENDA PARA SEPARACAO AO WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

//--------------------+
// Seta o contenttype |
//--------------------+
::SetContentType("application/json") 

//-----------------------------------+
// JSON Envia Pedidos para separação |
//-----------------------------------+
aRet := DnaApi07A(cPedido,cDataHora,cTamPage,cPage) 

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

LogExec("FINALIZA ENVIO DOS PEDIDOS DE VENDA PARA SEPARACAO AO WMS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
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
WSMETHOD PUT WSSERVICE PEDIDO
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
cArqLog := cDirRaiz + "PEDIDO_BAIXA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA BAIXA DOS PEDIDOS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

oPedido	:= oJson[#"pedidos"]

//---------------------------------------------+
// Inicia a Gravacao / Atualização dos Pedidos |
//---------------------------------------------+
For nPed := 1 To Len(oPedido)	
	LogExec("INICIA VALIDACAO DA BAIXA DO PEDIDO " + LTrim(oPedido[nPed][#"pedido"]) )
	DnaApi07C(oPedido[nPed])
Next nPed	

//----------------------+
// Cria JSON de Retorno |
//----------------------+	
If Len(aMsgErro) > 0
	DnaApi07E(aMsgErro,@cJsonRet)
EndIf
	
//----------------+
// Retorno da API |
//----------------+
::SetResponse(cJsonRet)
HTTPSetStatus(200,"OK")

LogExec("FINALIZA BAIXA DOS PEDIDOS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
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
WSMETHOD POST WSSERVICE PEDIDO
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
cArqLog := cDirRaiz + "PEDIDO_RETORNO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA RETORNO SEPARACAO DOS PEDIDOS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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

oPedido	:= oJson[#"pedidos"]

//---------------------------------------------+
// Inicia a Gravacao / Atualização dos Pedidos |
//---------------------------------------------+
For nPed := 1 To Len(oPedido)	
	LogExec("INICIA VALIDACAO DA SEPARACAO DO PEDIDO " + LTrim(oPedido[nPed][#"pedido"]) )
	DnaApi07B(oPedido[nPed])
Next nPed	

//----------------------+
// Cria JSON de Retorno |
//----------------------+	
If Len(aMsgErro) > 0
	DnaApi07E(aMsgErro,@cJsonRet)
EndIf
	
//----------------+
// Retorno da API |
//----------------+
::SetResponse(cJsonRet)
HTTPSetStatus(200,"OK")

LogExec("FINALIZA RETORNO SEPARACAO DOS PEDIDOS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DNAAPI07A	
	@description Consulta pedidos de separacao e monta arquivo de envio
	@author Bernard M. Margarido
	@since 10/11/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnaApi07A(cPedido,cDataHora,cTamPage,cPage)
Local aArea		:= GetArea()
Local aRet		:= {.F.,""}

Local cAlias	:= GetNextAlias()
Local cFilAux	:= ""	
Local cFilAut	:= ""
Local cRest		:= ""
Local cPedVen 	:= ""
Local cCodCli	:= ""
Local cLoja		:= ""
Local cCodTransp:= ""
Local cTipoPV	:= ""
Local cSeqLib	:= ""
Local cCancelado:= ""	
Local dDtaEmiss	:= ""

Local _nTotalPv	:= 0
Local _nRecSC5	:= 0

Local oJson		:= Nil
Local oPedido	:= Nil
Local oItens	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "200" 
Default cPage	:= "1" 

If !DnaApiQry(cAlias,cPedido,cDataHora,cTamPage,cPage)
	
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

//---------------------------+
// Posiciona itens do pedido |
//---------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

//---------------------------+
// Posiciona itens liberados |
//---------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//--------------------------+
// Inicaliza Matriz HashMap |
//--------------------------+
oJson				:= Array(#)
oJson[#"pedidos"]	:= {}

While (cAlias)->( !Eof() )
	//--------------------+
	// Cria Array HashMap |
	//--------------------+
	aAdd(oJson[#"pedidos"],Array(#))
	oPedido := aTail(oJson[#"pedidos"])
	
	//---------------------------+
	// Sequencia de envio ao WMS |
	//---------------------------+
	If Empty((cAlias)->SEQLIB)
		cSeqLib := IIF( Empty((cAlias)->SEQLIB),"01", (cAlias)->SEQLIB)
	EndIf
	
	cFilAut			:= (cAlias)->FILIAL
	cPedVen 		:= (cAlias)->PEDIDO
	//-------------------------+
	// Ricardo Evangelista     |
	// Inserindo novos campos  |
	//-------------------------+
	cPed_ecom 		:= (cAlias)->PEDIDO_ECOMMERCE
	cPed_ID_ecom	:= (cAlias)->ID_ECOMMERCE

	cCodCli			:= (cAlias)->CLIENTE
	cLoja			:= (cAlias)->LOJA
	cCodTransp		:= (cAlias)->CODTRANSP
	cTipoPV			:= (cAlias)->TIPO
	cPedPai			:= (cAlias)->PEDPAI
	cCancelado		:= (cAlias)->CANCELADO
	dDtaEmiss		:= dToc(sTod((cAlias)->EMISSAO))
	_nRecSC5		:= (cAlias)->RECNOSC5
	_nTotalPv		:= DnApi07TPv(cFilAut,cPedVen,1)
				 
	//-------------------------------+
	// Cria cabeçalho do pedido JSON |
	//-------------------------------+
	oPedido[#"filial"]				:= cFilAut
	oPedido[#"pedido"]				:= cPedVen
	
	//---------------------------------------------+
	// Ricardo Evangelista, Inserindo novos campos |
	//---------------------------------------------+
	oPedido[#"pedido_ecommerce"]	:= cPed_ecom
	oPedido[#"id_ecommerce"]		:= cPed_ID_ecom

	oPedido[#"codigo_cliente"]		:= cCodCli
	oPedido[#"loja"]				:= cLoja
	oPedido[#"transportadora"]		:= cCodTransp
	oPedido[#"data_emissao"]		:= dDtaEmiss
	oPedido[#"tipo_pedido"]			:= cTipoPV
	oPedido[#"revisao"]				:= cSeqLib
	oPedido[#"total_pedido"]		:= _nTotalPv	
	oPedido[#"pedido_pai"]			:= cPedPai
	oPedido[#"cancelado"]			:= cCancelado
	
	//------------------------------------+
	// Cria array para os itens do pedido |
	//------------------------------------+
	oPedido[#"itens"]				:= {}
	
	//------------------------+
	// Posiciona filial atual |
	//------------------------+
	If cFilAnt <> cFilAut
		cFilAux	:= cFilAnt
		cFilAnt := cFilAut
	EndIf

	//------------------+
	// Pedido cancelado | 
	//------------------+
	If cCancelado == "S"
		SC6->( dbSeek(xFilial("SC6") + cPedVen) )
		SET DELETED OFF
		While SC6->( !Eof() .And. xFilial("SC6") + cPedVen == SC6->C6_FILIAL + SC6->C6_NUM )
		
			//-----------------+
			// Itens do pedido |
			//-----------------+
			aAdd(oPedido[#"itens"],Array(#))
			oItens := aTail(oPedido[#"itens"])
			oItens[#"item"]			:= SC6->C6_ITEM
			oItens[#"produto"]		:= SC6->C6_PRODUTO 
			oItens[#"quantidade"]	:= SC6->C6_QTDVEN
			oItens[#"valor_unit"]	:= SC6->C6_PRCVEN
			oItens[#"valor_total"]	:= (SC6->C6_QTDVEN * SC6->C6_PRCVEN)
			oItens[#"um"]			:= Posicione("SB1",1,xFilial("SB1") + SC6->C6_PRODUTO,"B1_UM")
			oItens[#"lote"]			:= SC6->C6_LOTECTL
			oItens[#"data_validade"]:= SC6->C6_DTVALID
			oItens[#"armazem"]		:= SC6->C6_LOCAL
			SC6->( dbSkip() )
		EndDo
		SET DELETED ON
	//------------------+	
	// Pedido separação |
	//------------------+	
	Else
		//---------------------------+
		// Posiciona itens do pedido | 	
		//---------------------------+
		SC9->( dbSeek(xFilial("SC9") + cPedVen) )
		While SC9->( !Eof() .And. xFilial("SC9") + cPedVen == SC9->C9_FILIAL + SC9->C9_PEDIDO )

			If Empty(SC9->C9_NFISCAL) .And. Empty(SC9->C9_SERIENF)

				//-----------------+
				// Itens do pedido |
				//-----------------+
				aAdd(oPedido[#"itens"],Array(#))
				oItens := aTail(oPedido[#"itens"])
				oItens[#"item"]			:= SC9->C9_ITEM
				oItens[#"produto"]		:= SC9->C9_PRODUTO 
				oItens[#"quantidade"]	:= SC9->C9_QTDLIB
				oItens[#"valor_unit"]	:= SC9->C9_PRCVEN
				oItens[#"valor_total"]	:= (SC9->C9_QTDLIB * SC9->C9_PRCVEN)
				oItens[#"um"]			:= Posicione("SB1",1,xFilial("SB1") + SC9->C9_PRODUTO,"B1_UM")
				oItens[#"lote"]			:= SC9->C9_LOTECTL
				oItens[#"data_validade"]:= SC9->C9_DTVALID
				oItens[#"armazem"]		:= SC9->C9_LOCAL
			
				//-----------------------+
				// Atualiza item enviado |
				//-----------------------+
				DnApi07I(cFilAut,cPedVen,SC9->C9_ITEM,SC9->C9_PRODUTO )

			EndIf

			SC9->( dbSkip() )
		EndDo
	EndIf

	//-----------------------+
	// Restaura filial atual | 
	//-----------------------+
	If cFilAnt <> cFilAux
		cFilAnt := cFilAux
	EndIf
	
	(cAlias)->( dbSkip() )

EndDo

//-----------+
// Paginação |
//-----------+
oJson[#"pagina"]								:= Array(#)
oJson[#"pagina"][#"total_pedidos_pagina"]		:= Val(cTamPage)
oJson[#"pagina"][#"total_pedidos"]				:= nTotQry
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
/*/{Protheus.doc} DnApi07I
	@description Atualiza item do pedido de venda
	@author Bernard M. Margarido
	@since 29/04/2019
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnApi07I(cFilAut,_cPedVen,_cItem,_cProduto)
Local _aArea	:= GetArea()
Local _cFilAux	:= cFilAnt

//------------------+
// Posiciona filial |
//------------------+
cFilAnt := cFilAut

//--------------------------+
// Posiciona item do pedido |
//--------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If SC6->( dbSeeK(xFilial("SC6") + _cPedVen + _cItem + _cProduto) )
	RecLock("SC6",.F.)
		SC6->C6_XENVWMS := "1"
		SC6->C6_XDTALT 	:= Date()
		SC6->C6_XHRALT	:= Time()
	SC6->( MsUnLock() )	
EndIf

//-----------------+
// Restaura Filial | 
//-----------------+
cFilAnt	:= _cFilAux

RestArea(_aArea)
Return Nil

/************************************************************************************/
/*/{Protheus.doc} DnApi07TPv
	@description Retorna total do pedido 
	@author Bernard M. Margarido
	@since 29/04/2019
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnApi07TPv(cFilAut,cPedVen,_nField)
Local _aArea	:= GetArea()
Local _cFilAux	:= cFilAnt

Local _nTotal	:= 0

//------------------------+
// Posiciona filial atual |
//------------------------+
cFilAnt	:= cFilAut

dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If SC6->( dbSeek(xFilial("SC6") + cPedVen ) )
	While SC6->( !Eof() .And. xFilial("SC6") + cPedVen == SC6->C6_FILIAL + SC6->C6_NUM )
		//-----------------+
		// Total do Pedido |
		//-----------------+
		If _nField == 1
			_nTotal += SC6->C6_VALOR
		//----------------+
		// Total de Itens |
		//----------------+		
		ElseIf _nField == 2
			_nTotal++
		EndIf
		SC6->( dbSkip() )
	EndDo
EndIf

//-----------------------+
// Restaura filial atual | 
//-----------------------+
cFilAnt := _cFilAux

RestArea(_aArea)
Return _nTotal

/************************************************************************************/
/*/{Protheus.doc} DnaApi07B
	@description Realiza conferencia dos pedidos separados pelo WMS
	@author Bernard M. Margarido
	@since 20/11/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnaApi07B(_oPedido)
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
Local _aItensC	:= {}
Local _aProdu	:= {}
Local _lContinua:= .T.	

Local _oItPed	:= Nil

//------------------------+
// Posiciona Filial atual | 
//------------------------+
cFilAnt := RTrim(_oPedido[#"filial"])

//---------------+
// Dados da Nota |
//---------------+
_cPedido	:= PadR(_oPedido[#"pedido"],nTPed)
_cCodCli	:= PadR(_oPedido[#"codigo_cliente"],nTCodCli)
_cLoja		:= PadR(_oPedido[#"loja"],nTLoja)
_nVolume	:= _oPedido[#"volume"]
_nPeso		:= _oPedido[#"peso"]

//-----------------------------+
// Posiciona cabeçalho da Nota |
//-----------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
If !SC5->( dbSeek(xFilial("SC5") + _cPedido) )
	LogExec(_cPedido + "PEDIDO NAO LOCALIZADO")
	aAdd(aMsgErro,{cFilAnt,_cPedido,.F.,"PEDIDO NAO LOCALIZADO" })
	RestArea(aArea)
	Return .F.
EndIf

//-----------------------------------+
// Valida se pedido já foi conferido | 
//-----------------------------------+
If SC5->C5_XENVWMS == "3"
	LogExec(_cPedido  + "PEDIDO JÁ SEPARADO.")
	aAdd(aMsgErro,{cFilAnt,_cPedido,.F.,"PEDIDO JÁ SEPARADO."})
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------+
// Posiciona Itens Pedidos | 
//-------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

//-----------------------------------+
// Posiciona Itens Pedidos Liberados | 
//-----------------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//-----------------------------------------------------+
// Valida conferencia dos itens da Pre Nota de Entrada | 
//-----------------------------------------------------+
_oItPed 	:= _oPedido[#"itens"]

//-----------------------------+
// Valida produtos divergentes | 
//-----------------------------+
DnApi07Div(_oItPed,@_aProdu)

_lContinua	:= .T.

If Len(_aProdu) > 0
	For _nPed := 1 To Len(_aProdu)
			
		//-----------------+
		// Dados dos Itens |
		//-----------------+
		_cItem		:= PadL(_aProdu[_nPed][1],nTItem,"0")
		_cCodProd	:= PadR(_aProdu[_nPed][2],nTProd)
		_cLote		:= PadR(_aProdu[_nPed][4],nTLote)	
		_nQtdConf	:= _aProdu[_nPed][3]
		
		//--------------------------+
		// Posiciona Item da Pedido |
		//--------------------------+
		If !SC6->( dbSeek(xFilial("SC6") + _cPedido + _cItem + _cCodProd) )
			LogExec(_cPedido + " ITEM/PRODUTO " + _cItem + "/" + _cCodProd + " NAO LOCALIZADO.")
			aAdd(aMsgErro,{cFilAnt,_cPedido,.F.," ITEM/PRODUTO " + _cItem + "/" + _cCodProd + " NAO LOCALIZADO." })
			_lContinua := .F.
			Loop
		EndIf
		
		//------------------------+
		// Posiciona Item da Nota |
		//------------------------+
		If SC6->C6_QTDEMP > 0 .Or. SC6->C6_QTDLIB > 0  
			If !SC9->( dbSeek(xFilial("SC9") + _cPedido + _cItem ) )
				LogExec(_cPedido + " ITEM/PRODUTO " + _cItem + "/" + _cCodProd + " NAO LIBERADO.")
				aAdd(aMsgErro,{cFilAnt,_cPedido,.F.," ITEM/PRODUTO " + _cItem + "/" + _cCodProd + " NAO LIBERADO." })
				_lContinua := .F.
				Loop
			EndIf
		EndIf	
			
		//--------------------+
		// Valida conferencia |
		//--------------------+
		If _lContinua
			
			//------------------------------+
			// Valida divergencia separação |
			//------------------------------+
			While SC9->( !Eof() .And. xFilial("SC9") + _cPedido + _cItem == SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM )

				If Empty(SC9->C9_NFISCAL) .And. Empty(SC9->C9_NFISCAL)
					//------------------------------+
					// Valida divergencia separação |
					//------------------------------+
					If _nQtdConf < SC9->C9_QTDLIB .Or. _nQtdConf > SC9->C9_QTDLIB
						//-------------------+
						// Array Divergencia |
						//-------------------+
						aAdd(_aDiverg,{ SC6->C6_ITEM		,;	// 1 - Item Pre Nota
										SC6->C6_PRODUTO		,;	// 2 - Codigo do Produto
										_nQtdConf			,;	// 3 - Quantidade Transferida
										SC9->C9_QTDLIB		,;	// 4 - Quantidade Liberada
										SC6->C6_LOTECTL		,;	// 4 - Lote Produto
										SC6->C6_LOCAL		})	// 5 - Armazem 	
					//------------------+					
					// Itens conferidos |
					//------------------+					
					Else
						aAdd(_aItensC,{ SC6->C6_ITEM		,;	// 1 - Item Pre Nota
										SC6->C6_PRODUTO		,;	// 2 - Codigo do Produto
										_nQtdConf			,;	// 3 - Quantidade Transferida
										SC9->C9_QTDLIB		,;	// 4 - Quantidade Liberada
										SC6->C6_LOTECTL		,;	// 4 - Lote Produto
										SC6->C6_LOCAL		})	// 5 - Armazem 	
					EndIf

				EndIf 
				SC9->( dbSkip() )
			EndDo
			
		EndIf			
			
	Next _nPed
EndIf

If _lContinua

	//--------------------------------------+
	// Estorna liberação do pedido de venda | 
	//--------------------------------------+
	If Len(_aDiverg) > 0

		//----------------------------------+
		// Envia e-mail e estorna liberação |
		//----------------------------------+	
		DnaApi07P(_cPedido,_cCodCli,_cLoja,_aDiverg)

		//----------------------------------+
		// Libera pedido de venda novamente |
		//----------------------------------+
		DnaApi07L(_cPedido,_cCodCli,_cLoja)

		//-----------------------+
		// Elimina Residuo sobra |
		//-----------------------+
		//DnaApi07N(_cPedido,_cCodCli,_cLoja)

		//--------------------------+
		// Atualiza dados do pedido |
		//--------------------------+
		DnApi07O(_cPedido,_nPeso,_nVolume,_aItensC,_aDiverg)

		//----------------------+	
		// Log processo da nota |
		//----------------------+
		LogExec(_cPedido + "DIVERGENCIA SEPARAÇÃO.")
		aAdd(aMsgErro,{cFilAnt,_cPedido,.T.,"DIVERGENCIA SEPARAÇÃO."})
		
	//------------------------------+	
	// Libera faturamento do pedido |
	//------------------------------+	 
	Else

		//--------------------------+
		// Atualiza dados do pedido |
		//--------------------------+
		DnApi07O(_cPedido,_nPeso,_nVolume,_aItensC)
	
		//----------------------+	
		// Log processo da nota |
		//----------------------+
		LogExec(_cPedido + " CONFERENCIA REALIZADA COM SUCESSO.")
		aAdd(aMsgErro,{cFilAnt,_cPedido,.T.,"CONFERENCIA REALIZADA COM SUCESSO."})

	EndIf
EndIf

//-------------------------+
// Restaura a filial atual |
//-------------------------+ 
cFilAnt := _cFilAux

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnApi07Div
	@description Realiza a baixa dos pedidos 
	@author Bernard M. Margarido
	@since 08/12/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnApi07Div(_oItPed,_aProdu)

Local _cCodProd	:= ""
Local _cItem	:= ""
Local _cLote	:= ""

Local _nQtdConf	:= 0
Local _nPosPrd	:= 0
Local _nX		:= 0

LogExec("    INICIO VALIDA ITENS DIVERGENTES")

_aProdu := {}
For _nX := 1 To Len(_oItPed)
			
	//-----------------+
	// Dados dos Itens |
	//-----------------+
	_cCodProd	:= PadR(_oItPed[_nX][#"produto"],nTProd)
	_cItem		:= PadL(_oItPed[_nX][#"item"],nTItem,"0")
	_cLote		:= PadR(_oItPed[_nX][#"lote"],nTLote)	
	_nQtdConf	:= _oItPed[_nX][#"quantidade"]

	_nPosPrd	:= aScan(_aProdu,{|x| RTrim(x[1]) + RTrim(x[2]) == RTrim(_cItem) + RTrim(_cCodProd)})

	//-----------------------+
	// Algutina itens iguais |
	//-----------------------+
	If _nPosPrd == 0
		aAdd(_aProdu, {	_cItem		,;
						_cCodProd	,;
						_nQtdConf	,;
						_cLote		})
		LogExec("    ITEM " + _aProdu[Len(_aProdu)][1] + "PRODUTO " + _aProdu[Len(_aProdu)][2] + " QUANTIDADE " + Alltrim(Str(_aProdu[Len(_aProdu)][3])) + " .")						
	Else
		_aProdu[_nPosPrd][3] += _nQtdConf
		LogExec("    ITEM " + _aProdu[_nPosPrd][1] + "PRODUTO " + _aProdu[_nPosPrd][2] + " QUANTIDADE " + Alltrim(Str(_aProdu[_nPosPrd][3])) + " .")						
	EndIf		
	
Next _nPed

Return Nil

/************************************************************************************/
/*/{Protheus.doc} DnaApi07C
	@description Realiza a baixa dos pedidos 
	@author Bernard M. Margarido
	@since 08/12/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
Static Function DnaApi07C(_oPedido)
Local _aArea		:= GetArea()

Local _cFilAux		:= cFilAnt
Local _cPedido		:= PadR(_oPedido[#"pedido"],nTPed)
Local _cCodCli		:= PadR(_oPedido[#"codigo_cliente"],nTCodCli)
Local _cLoja		:= PadR(_oPedido[#"loja"],nTLoja)
Local _cSeqLib		:= RTrim(_oPedido[#"revisao"])

//------------------------+
// Posiciona filial atual | 
//------------------------+
cFilAnt := RTrim(_oPedido[#"filial"])

//------------------+
// Posiciona Pedido | 
//------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
SET DELETED OFF
If !SC5->( dbSeek(xFilial("SC5") + _cPedido + _cCodCli + _cLoja) )
	aAdd(aMsgErro,{cFilAnt,_cPedido,.F.,"PEDIDO NAO ENCONTRADO."})
	RestArea(_aArea)
	Return .F.
EndIf

//------------------------------+
// Valida se pedido e cancelado |
//------------------------------+
If SC5->C5_XENVWMS == "9"

	//---------------------------+
	// Atualiza Status do Pedido |
	//---------------------------+
	RecLock("SC5",.F.)
		SC5->C5_XENVWMS := "X"
		SC5->C5_XSEQLIB	:= SC5->C5_XSEQLIB
		SC5->C5_XDTALT	:= Date()
		SC5->C5_XHRALT	:= Time()
	SC5->( MsUnLock() )

	//-------------------------+
	// Restaura a filial atual |
	//-------------------------+
	cFilAnt := _cFilAux

	aAdd(aMsgErro,{cFilAnt,_cPedido,.T.,"PEDIDO BAIXADO COM SUCESSO."})

	RestArea(_aArea)
	Return .T.

EndIf

SET DELETED ON

//----------------------------------+
// Valida se Pedido já foi expedido | 
//----------------------------------+
If SC5->C5_XENVWMS == "3"

	//-------------------------+
	// Restaura a filial atual |
	//-------------------------+
	cFilAnt := _cFilAux

	aAdd(aMsgErro,{cFilAnt,_cPedido,.F.,"PEDIDO JÁ SEPARADO."})
	RestArea(_aArea)
	Return .F.
EndIf

//---------------------------+
// Atualiza Status do Pedido |
//---------------------------+
RecLock("SC5",.F.)
	SC5->C5_XENVWMS := IIF(SC5->C5_XENVWMS == "9","X","2")
	SC5->C5_XSEQLIB	:= _cSeqLib
	SC5->C5_XDTALT	:= Date()
	SC5->C5_XHRALT	:= Time()
SC5->( MsUnLock() )

//------------------------+
// Tabela itens do pedido |
//------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

//---------------------------+
// Posiciona Itens Liberados |
//---------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )
SC9->( dbSeek(xFilial("SC9") + SC5->C5_NUM) )
While SC9->( !Eof() .And. xFilial("SC9") + SC5->C5_NUM == SC9->C9_FILIAL + SC9->C9_PEDIDO)
	If SC6->( dbSeeK(xFilial("SC9") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO) )

		If !Empty(SC6->C6_XENVWMS) .And. !Empty(SC6->C6_XDTALT) .And.  !Empty(SC6->C6_XHRALT)
			//------------------------+
			// Atualiza item liberado |
			//------------------------+
			RecLock("SC9",.F.)
				SC9->C9_XENVWMS := "2"
				SC9->C9_XDTALT	:= Date()
				SC9->C9_XHRALT	:= Time()
			SC9->( MsUnLock() )

			//----------------------+
			// Atualiza item pedido | 
			//----------------------+
			RecLock("SC6",.F.)
				SC6->C6_XENVWMS := "2"
				SC6->C6_XDTALT	:= Date()
				SC6->C6_XHRALT	:= Time()
			SC6->( MsUnLock() )

		EndIf	
	EndIF
	SC9->( dbSkip() )	
EndDo


aAdd(aMsgErro,{cFilAnt,_cPedido,.T.,"PEDIDO BAIXADO COM SUCESSO."})

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
Static Function DnaApiQry(cAlias,cPedido,cDataHora,cTamPage,cPage)
Local cQuery 	:= ""

Local cData		:= StrTran(SubStr(cDataHora,1,10),"-","")
Local cHora		:= SubStr(cDataHora,At("T",cDataHora) + 1)

//--------------------------+
// Cosulta total de pedidos | 
//--------------------------+
If !DnaQryTot(cPedido,cDataHora,cTamPage,cPage)
	Return .F.
EndIf

cQuery := "	SELECT " + CRLF
cQuery += "		TOP(" + cTamPage + ") RNUM, " + CRLF
cQuery += "		FILIAL, " + CRLF
cQuery += "		PEDIDO, " + CRLF
cQuery += "		PEDIDO_ECOMMERCE, " + CRLF //C5_XNUMECO
cQuery += "		ID_ECOMMERCE, " + CRLF //C5_XNUMECL
cQuery += "		CLIENTE, " + CRLF
cQuery += "		LOJA, " + CRLF
cQuery += "		CODTRANSP, " + CRLF
cQuery += "		EMISSAO, " + CRLF
cQuery += "		TIPO, " + CRLF
cQuery += "		SEQLIB, " + CRLF
cQuery += "		PEDPAI, " + CRLF
cQuery += "		TOTAL_PV, " + CRLF
cQuery += "		TOTAL_LIB, " + CRLF
cQuery += "		CANCELADO, " + CRLF
cQuery += "		RECNOSC5 " + CRLF
cQuery += "	FROM ( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			ROW_NUMBER() OVER(ORDER BY PEDIDO) RNUM, 
cQuery += "			FILIAL, " + CRLF
cQuery += "			PEDIDO, " + CRLF
cQuery += "			PEDIDO_ECOMMERCE, " + CRLF //C5_XNUMECO
cQuery += "			ID_ECOMMERCE, " + CRLF //C5_XNUMECL
cQuery += "			CLIENTE, " + CRLF
cQuery += "			LOJA, " + CRLF
cQuery += "			CODTRANSP, " + CRLF
cQuery += "			EMISSAO, " + CRLF
cQuery += "			TIPO, " + CRLF
cQuery += "			SEQLIB, " + CRLF
cQuery += "			PEDPAI, " + CRLF
cQuery += "			TOTAL_PV, " + CRLF
cQuery += "			TOTAL_LIB, " + CRLF
cQuery += "			CANCELADO, " + CRLF
cQuery += "			RECNOSC5 " + CRLF
cQuery += "		FROM ( " + CRLF
cQuery += "			SELECT " + CRLF
cQuery += "				C5.C5_FILIAL FILIAL, " + CRLF
cQuery += "				C5.C5_NUM PEDIDO, " + CRLF
cQuery += "				C5.C5_XNUMECO PEDIDO_ECOMMERCE, " + CRLF //PEDIDO_ECOMMERCE
cQuery += "				C5.C5_XNUMECL ID_ECOMMERCE, " + CRLF //ID_ECOMMERCE
cQuery += "				C5.C5_CLIENTE CLIENTE, " + CRLF
cQuery += "				C5.C5_LOJACLI LOJA, " + CRLF
cQuery += "				C5.C5_TRANSP CODTRANSP, " + CRLF
cQuery += "				C5.C5_EMISSAO EMISSAO, " + CRLF
cQuery += "				C5.C5_TIPO TIPO, " + CRLF
cQuery += "				C5.C5_XSEQLIB SEQLIB, " + CRLF
cQuery += "				C5.C5_XPEDPAI PEDPAI, " + CRLF
cQuery += "				PV.TOTAL TOTAL_PV, " + CRLF
cQuery += "				LIB.TOTAL TOTAL_LIB, " + CRLF
cQuery += "				'N' CANCELADO, " + CRLF
cQuery += "				C5.R_E_C_N_O_ RECNOSC5 " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SC5") + " C5 " + CRLF 
cQuery += "				CROSS APPLY ( " + CRLF
cQuery += "								SELECT " + CRLF 
cQuery += "									COUNT(C6.C6_ITEM) TOTAL " + CRLF
cQuery += "								FROM " + CRLF
cQuery += "									" + RetSqlName("SC6") + " C6 " + CRLF
cQuery += "									INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = C6.C6_FILIAL AND F4.F4_CODIGO = C6.C6_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF
cQuery += "								WHERE " + CRLF
cQuery += "									C6.C6_FILIAL = C5.C5_FILIAL AND " + CRLF
cQuery += "									C6.C6_NUM = C5.C5_NUM AND " + CRLF
cQuery += "									C6.C6_NOTA = '' AND " + CRLF
cQuery += "									C6.C6_SERIE = '' AND " + CRLF
cQuery += "									C6.C6_BLQ <> 'R' AND " + CRLF
cQuery += "									C6.D_E_L_E_T_ = '' " + CRLF
cQuery += "								GROUP BY C6.C6_FILIAL,C6.C6_NUM " + CRLF
cQuery += "							) PV " + CRLF
cQuery += "				CROSS APPLY ( " + CRLF
cQuery += "								SELECT " + CRLF
cQuery += "									COUNT(C9.C9_ITEM) TOTAL " + CRLF
cQuery += "								FROM " + CRLF
cQuery += "									" + RetSqlName("SC9") + " C9 " + CRLF 
cQuery += "								WHERE " + CRLF
cQuery += "									C9.C9_FILIAL = C5.C5_FILIAL AND " + CRLF
cQuery += "									C9.C9_PEDIDO = C5.C5_NUM AND " + CRLF
cQuery += "									C9.C9_BLCRED = '  ' AND " + CRLF
cQuery += "									C9.C9_NFISCAL = '' AND " + CRLF
cQuery += "									C9.D_E_L_E_T_ = '' " + CRLF
cQuery += "								GROUP BY C9.C9_FILIAL,C9.C9_PEDIDO " + CRLF
cQuery += "							) LIB " + CRLF
cQuery += "			WHERE " + CRLF

If _lSC5Comp
	cQuery += "				C5.C5_FILIAL = '" + xFilial("SC5") + "' AND " + CRLF
Else
	cQuery += "				C5.C5_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf
	
cQuery += "				C5.C5_XENVWMS = '1' AND " + CRLF
cQuery += "				C5.C5_NOTA = '' AND " + CRLF
cQuery += "				C5.C5_LIBEROK <> 'E' AND " + CRLF
cQuery += "				C5.C5_BLQ = '' AND " + CRLF
cQuery += "				C5.C5_TIPO IN('N','D','B') AND " + CRLF

If Empty(cPedido)
	cQuery += "				CAST((C5.C5_XDTALT + ' ' + C5.C5_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((C5.C5_XDTALT + ' ' + C5.C5_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "				C5.C5_NUM = '" + cPedido + "' AND " + CRLF
EndIf

cQuery += "				C5.D_E_L_E_T_ = '' " + CRLF
//Bernard cQuery += "			GROUP BY C5.C5_FILIAL,C5.C5_NUM,C5.C5_CLIENTE,C5.C5_LOJACLI,C5.C5_TRANSP,C5.C5_EMISSAO,C5.C5_TIPO,C5.C5_XSEQLIB,C5.C5_XPEDPAI,PV.TOTAL,LIB.TOTAL,C5.R_E_C_N_O_  " + CRLF
//Ricardo Evangelista, Inserindo novos campos
cQuery += "			GROUP BY C5.C5_XNUMECO,C5.C5_XNUMECL,C5.C5_FILIAL,C5.C5_NUM,C5.C5_CLIENTE,C5.C5_LOJACLI,C5.C5_TRANSP,C5.C5_EMISSAO,C5.C5_TIPO,C5.C5_XSEQLIB,C5.C5_XPEDPAI,PV.TOTAL,LIB.TOTAL,C5.R_E_C_N_O_  " + CRLF
cQuery += "			UNION ALL  " + CRLF
cQuery += "			SELECT " + CRLF
cQuery += "				C5.C5_FILIAL FILIAL, " + CRLF
cQuery += "				C5.C5_NUM PEDIDO, " + CRLF
cQuery += "				C5_XNUMECO PEDIDO_ECOMMERCE, " + CRLF //C5_XNUMECO
cQuery += "				C5.C5_CLIENTE CLIENTE, " + CRLF
cQuery += "				C5.C5_LOJACLI LOJA, " + CRLF
cQuery += "				C5.C5_TRANSP CODTRANSP, " + CRLF
cQuery += "				C5.C5_EMISSAO EMISSAO, " + CRLF
cQuery += "				C5.C5_TIPO TIPO, " + CRLF
cQuery += "				C5.C5_XSEQLIB SEQLIB, " + CRLF
cQuery += "				C5.C5_XPEDPAI PEDPAI, " + CRLF
cQuery += "				PV.TOTAL TOTAL_PV, " + CRLF
cQuery += "				LIB.TOTAL TOTAL_LIB, " + CRLF
cQuery += "				'S' CANCELADO, " + CRLF
cQuery += "				C5.R_E_C_N_O_ RECNOSC5 " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SC5") + " C5 " + CRLF 
cQuery += "				CROSS APPLY ( " + CRLF
cQuery += "								SELECT " + CRLF 
cQuery += "									COUNT(C6.C6_ITEM) TOTAL " + CRLF
cQuery += "								FROM " + CRLF
cQuery += "									" + RetSqlName("SC6") + " C6 " + CRLF
cQuery += "									INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = C6.C6_FILIAL AND F4.F4_CODIGO = C6.C6_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF
cQuery += "								WHERE " + CRLF
cQuery += "									C6.C6_FILIAL = C5.C5_FILIAL AND " + CRLF
cQuery += "									C6.C6_NUM = C5.C5_NUM AND " + CRLF
cQuery += "									C6.C6_NOTA = '' AND " + CRLF
cQuery += "									C6.C6_SERIE = '' AND " + CRLF
cQuery += "									C6.C6_BLQ <> 'R' AND " + CRLF
cQuery += "									( C6.D_E_L_E_T_ = '' OR C6.D_E_L_E_T_ = '*' ) " + CRLF
cQuery += "								GROUP BY C6.C6_FILIAL,C6.C6_NUM " + CRLF
cQuery += "							) PV " + CRLF
cQuery += "				CROSS APPLY ( " + CRLF
cQuery += "								SELECT " + CRLF
cQuery += "									COUNT(C9.C9_ITEM) TOTAL " + CRLF
cQuery += "								FROM " + CRLF
cQuery += "									" + RetSqlName("SC9") + " C9 " + CRLF 
cQuery += "								WHERE " + CRLF
cQuery += "									C9.C9_FILIAL = C5.C5_FILIAL AND " + CRLF
cQuery += "									C9.C9_PEDIDO = C5.C5_NUM AND " + CRLF
cQuery += "									C9.C9_BLCRED = '  ' AND " + CRLF
cQuery += "									C9.C9_NFISCAL = '' AND " + CRLF
cQuery += "									( C9.D_E_L_E_T_ = '' OR  C9.D_E_L_E_T_ = '*' ) " + CRLF
cQuery += "								GROUP BY C9.C9_FILIAL,C9.C9_PEDIDO " + CRLF
cQuery += "							) LIB " + CRLF
cQuery += "			WHERE " + CRLF

If _lSC5Comp
	cQuery += "				C5.C5_FILIAL = '" + xFilial("SC5") + "' AND " + CRLF
Else
	cQuery += "				C5.C5_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf
	
cQuery += "				C5.C5_XENVWMS = '9' AND " + CRLF
cQuery += "				( C5.C5_NOTA = '' OR C5.C5_NOTA = 'XXXXXX' ) AND " + CRLF
cQuery += "				C5.C5_TIPO IN('N','D','B') AND " + CRLF

If Empty(cPedido)
	cQuery += "				CAST((C5.C5_XDTALT + ' ' + C5.C5_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((C5.C5_XDTALT + ' ' + C5.C5_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "				C5.C5_NUM = '" + cPedido + "' AND " + CRLF
EndIf

cQuery += "				( C5.D_E_L_E_T_ = '*' OR C5.D_E_L_E_T_ = '' ) " + CRLF
//Bernard cQuery += "			GROUP BY C5.C5_FILIAL,C5.C5_NUM,C5.C5_CLIENTE,C5.C5_LOJACLI,C5.C5_TRANSP,C5.C5_EMISSAO,C5.C5_TIPO,C5.C5_XSEQLIB,C5.C5_XPEDPAI,PV.TOTAL,LIB.TOTAL,C5.R_E_C_N_O_  " + CRLF
//Ricardo Evangelista, Inserindo novos campos
cQuery += "			GROUP BY C5.C5_XNUMECO,C5.C5_XNUMECL,C5.C5_FILIAL,C5.C5_NUM,C5.C5_CLIENTE,C5.C5_LOJACLI,C5.C5_TRANSP,C5.C5_EMISSAO,C5.C5_TIPO,C5.C5_XSEQLIB,C5.C5_XPEDPAI,PV.TOTAL,LIB.TOTAL,C5.R_E_C_N_O_  " + CRLF

cQuery += "		) PEDIDOS  " + CRLF
cQuery += "	) TOTAL_PEDIDO  " + CRLF
cQuery += "	WHERE " + CRLF
cQuery += "		RNUM > " + cTamPage + " * (" + cPage + " - 1)  AND " + CRLF 
cQuery += "		( CANCELADO = 'N' AND TOTAL_PV = TOTAL_LIB OR " + CRLF
cQuery += "		  CANCELADO = 'S' AND TOTAL_PV = TOTAL_LIB OR TOTAL_PV <> TOTAL_LIB	) " + CRLF
cQuery += "	ORDER BY FILIAL,PEDIDO "

MemoWrite("/views/DNAPI007.txt",cQuery)

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
Static Function DnaQryTot(cPedido,cDataHora,cTamPage,cPage)
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
cQuery += "		COUNT(PEDIDO) TOTREG " + CRLF
cQuery += "	FROM " + CRLF
cQuery += " ( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			PEDIDO, " + CRLF
cQuery += "			TOTAL_PV, " + CRLF
cQuery += "			TOTAL_LIB " + CRLF
cQuery += "		FROM " + CRLF
cQuery += " 	( " + CRLF
cQuery += "			SELECT " + CRLF 		
cQuery += "				C5.C5_FILIAL, " + CRLF
cQuery += "				C5.C5_NUM PEDIDO, " + CRLF
cQuery += "				PV.TOTAL TOTAL_PV, " + CRLF
cQuery += "				LIB.TOTAL TOTAL_LIB " + CRLF
cQuery += "			FROM " + CRLF 
cQuery += "				" + RetSqlName("SC5") + " C5 " + CRLF 
cQuery += "					CROSS APPLY ( " + CRLF
cQuery += "									SELECT " + CRLF 
cQuery += "										COUNT(C6.C6_ITEM) TOTAL " + CRLF
cQuery += "									FROM " + CRLF
cQuery += "										" + RetSqlName("SC6") + " C6 " + CRLF
cQuery += "										INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = C6.C6_FILIAL AND F4.F4_CODIGO = C6.C6_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF
cQuery += "									WHERE " + CRLF
cQuery += "										C6.C6_FILIAL = C5.C5_FILIAL AND " + CRLF
cQuery += "										C6.C6_NUM = C5.C5_NUM AND " + CRLF
cQuery += "										C6.C6_NOTA = '' AND " + CRLF
cQuery += "										C6.C6_SERIE = '' AND " + CRLF
cQuery += "										C6.C6_BLQ <> 'R' AND " + CRLF
cQuery += "										C6.D_E_L_E_T_ = '' " + CRLF
cQuery += "									GROUP BY C6.C6_FILIAL,C6.C6_NUM " + CRLF
cQuery += "								) PV " + CRLF
cQuery += "					CROSS APPLY ( " + CRLF
cQuery += "									SELECT " + CRLF
cQuery += "										COUNT(C9.C9_ITEM) TOTAL " + CRLF
cQuery += "									FROM " + CRLF
cQuery += "										" + RetSqlName("SC9") + " C9 " + CRLF 
cQuery += "									WHERE " + CRLF
cQuery += "										C9.C9_FILIAL = C5.C5_FILIAL AND " + CRLF
cQuery += "										C9.C9_PEDIDO = C5.C5_NUM AND " + CRLF
cQuery += "										C9.C9_BLCRED = '  ' AND " + CRLF
cQuery += "										C9.C9_NFISCAL = '' AND " + CRLF
cQuery += "										C9.D_E_L_E_T_ = '' " + CRLF
cQuery += "									GROUP BY C9.C9_FILIAL,C9.C9_PEDIDO " + CRLF
cQuery += "								) LIB " + CRLF
cQuery += "				WHERE " + CRLF

If _lSC5Comp
	cQuery += "					C5.C5_FILIAL = '" + xFilial("SC5") + "' AND " + CRLF
Else
	cQuery += "					C5.C5_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

cQuery += "					C5.C5_XENVWMS = '1' AND " + CRLF
cQuery += "					C5.C5_NOTA = '' AND " + CRLF
cQuery += "					C5.C5_LIBEROK <> 'E' AND " + CRLF
cQuery += "					C5.C5_BLQ = '' AND " + CRLF
cQuery += "					C5.C5_TIPO IN('N','D','B') AND " + CRLF
If Empty(cPedido)
	cQuery += "					CAST((C5.C5_XDTALT + ' ' + C5.C5_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "					CAST((C5.C5_XDTALT + ' ' + C5.C5_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "					C5.C5_NUM = '" + cPedido + "' AND " + CRLF
EndIf
cQuery += "					C5.D_E_L_E_T_ = ''  " + CRLF
cQuery += "		) PEDIDOS " + CRLF
cQuery += " 	WHERE " + CRLF
cQuery += "			TOTAL_PV = TOTAL_LIB " + CRLF
cQuery += " 	GROUP BY PEDIDO,TOTAL_PV,TOTAL_LIB " + CRLF
cQuery += "	) TOTAL_PEDIDOS "

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
/*/{Protheus.doc} DnaApi07P

@description Estorna liberação do pedido 

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function

/*/
/*************************************************************************************/
Static Function DnaApi07P(_cPedido,_cCodCli,_cLoja,_aDiverg)
Local aArea			:= GetArea()

Local _cSaldo		:= ""

Local lRet			:= .T.

//--------------+
// Envia e-Mail |
//--------------+
U_DnMailPV(_cPedido,_cCodCli,_cLoja,_aDiverg)

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )

//----------------------------+
// Seleciona cabeçalho pedido |
//----------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//--------------------------+
// Selecioa itens do pedido |
//--------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

//---------------------------+
// Seleciona itens liberados |
//---------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//---------------------------+
// Posiciona pedido de venda |
//---------------------------+
If !SC5->( dbSeek(xFilial("SC5") + _cPedido) )
	RestArea(aArea)
	Return .F.
EndIf

//-------------------+
// Posiciona cliente |
//-------------------+
SA1->( dbSeeK(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )
_cSaldo := SA1->A1_XACESAL

//-------------------------------------------+
// Atualiza pedido para se enviado novamente |
//-------------------------------------------+
RecLock("SC5",.F.)
	SC5->C5_XRESIDU := IIF(_cSaldo == "1","2","1")
	SC5->C5_XENVWMS := "3"
	SC5->C5_XDTALT	:= Date()
	SC5->C5_XHRALT	:= Time()
SC5->( MsUnLock() )

//--------------------------+
// Atualiza itens do pedido | 
//--------------------------+
SC6->( dbSeeK(xFilial("SC6") + _cPedido) )
While SC6->( !Eof() .And. xFilial("SC6") + _cPedido == SC6->C6_FILIAL + SC6->C6_NUM )
	_nPosIt	:= aScan(_aDiverg,{|x| RTrim(x[1]) + RTrim(x[2]) == Rtrim(SC6->C6_ITEM) + Rtrim(SC6->C6_PRODUTO)})
	If _nPosIt > 0
		//-------------------------------------------------+
		// Somente quantidade conferida menor que liberada |
		//-------------------------------------------------+
		If _aDiverg[_nPosIt][3] < _aDiverg[_nPosIt][4]
			RecLock("SC6",.F.)
				SC6->C6_XENVWMS	:= "X"
				SC6->C6_XDTALT	:= Date()
				SC6->C6_XHRALT	:= Time()
				SC6->C6_XQTDRES := _aDiverg[_nPosIt][4] - _aDiverg[_nPosIt][3]
			SC6->( MsUnLock() )
		EndIf
	EndIf
	SC6->( dbSkip() )
EndDo

//--------------------+
// Itens da Liberados | 
//--------------------+
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
/*/{Protheus.doc} DnaApi07L

@description Libera pedido com a quantidade certa

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function

/*/
/*************************************************************************************/
Static Function DnaApi07L(_cPedido,_cCodCli,_cLoja)
Local _aArea		:= GetArea()

Local _nQtdLib		:= 0

Local _lCredito 	:= .T.
Local _lEstoque		:= .T.
Local _lLiber		:= .T.
Local _lTransf   	:= .F.
Local _lRet			:= .T.

//-----------------+
// Pedido de venda | 
//-----------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
RecLock("SC5",.F.)
	SC5->C5_XENVWMS := "3"
	SC5->C5_XDTALT	:= Date()
	SC5->C5_XHRALT	:= Time()
SC5->( MsUnLock() )

//-----------------------+
// Itens pedido de venda |
//-----------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
SC6->( dbSeeK(xFilial("SC6") + _cPedido) )
While SC6->( !Eof() .And. xFilial("SC6") + _cPedido == SC6->C6_FILIAL + SC6->C6_NUM )

	_nQtdLib := SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT + SC6->C6_QTDLIB + SC6->C6_XQTDRES )  
	If _nQtdLib > 0
		MaLibDoFat(SC6->(RecNo()),_nQtdLib,@_lCredito,@_lEstoque,.F.,.F.,_lLiber,_lTransf)

		//-------------------------+
		// Atualiza flag dos itens |
		//-------------------------+
		RecLock("SC6",.F.)
			SC6->C6_XENVWMS := "3"
			SC6->C6_XDTALT	:= Date()
			SC6->C6_XHRALT	:= Time()
		SC6->( MsUnLock() )

	EndIf

	SC6->( dbSkip() )
EndDo

//-----------------------------+
// Destrava todos os registros |
//-----------------------------+
MsUnLockAll()

//---------------------------+
// Grava liberação do Pedido |
//---------------------------+
MaLiberOk({_cPedido},.T.) 

RestArea(_aArea)
Return _lRet

/*************************************************************************************/
/*/{Protheus.doc} DnApi07N

@description Elimina residuo da sobra / cria novo pedido para cliente saldo

@author Bernard M. Margarido
@since 15/10/2019
@version 1.0
@type function
/*/
/*************************************************************************************/
Static Function DnaApi07N(_cPedido,_cCodCli,_cLoja)
Local _aArea		:= GetArea()

//---------------------------+
// Posiciona Pedido de venda |
//---------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
SC5->( dbSeek(xFilial("SC5") + _cPedido ) )

//--------------+
// Aceita Saldo |
//--------------+ 
If SC5->C5_XRESIDU == "2"
	RestArea(_aArea)
	Return .T.
EndIf

//-----------------+
// Elimina residuo | 
//-----------------+
If DnApi07R(_cPedido)
	RecLock("SC5",.F.)
		SC5->C5_XRESIDU := "3"
	SC5->(MsUnLock())
EndIf

RestArea(_aArea)
Return _lRet

/*************************************************************************************/
/*/{Protheus.doc} DnaApi07O

@description Atualiza dados do pedido separado 

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnApi07O(_cPedido,_nPeso,_nVolume,_aItensC,_aDiverg)
Local _aArea	:= GetArea()

Local _lRet		:= .T.

Default _aDiverg:= {}

//--------------------------+
// Atualiza dados do pedido |
//--------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
SC5->( dbSeek(xFilial("SC5") + _cPedido) )

RecLock("SC5",.F.)
	SC5->C5_XENVWMS := "3"
	SC5->C5_XDTALT	:= Date()
	SC5->C5_XHRALT	:= Time()
	SC5->C5_ESPECI1	:= "CAIXAS"
	SC5->C5_PESOL	:= _nPeso
	SC5->C5_PBRUTO	:= _nPeso
	SC5->C5_VOLUME1	:= _nVolume
SC5->( MsUnLock() )

//------------------------+
// Tabela itens do pedido |
//------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

//---------------------------+
// Posiciona Itens Liberados |
//---------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )
SC9->( dbSeek(xFilial("SC9") + SC5->C5_NUM) )
While SC9->( !Eof() .And. xFilial("SC9") + SC5->C5_NUM == SC9->C9_FILIAL + SC9->C9_PEDIDO)
	//------------------------------+
	// Valida se items esta no JSON |
	//------------------------------+
	If  aScan(_aItensC,{|x| RTrim(x[1]) + RTrim(x[2]) == RTrim(SC9->C9_ITEM) + RTrim(SC9->C9_PRODUTO) }) > 0 .Or. ;
		aScan(_aItensC,{|x| RTrim(x[1]) + RTrim(x[2]) == RTrim(SC9->C9_ITEM) + RTrim(SC9->C9_PRODUTO) }) > 0
		//------------------------+
		// Atualiza item liberado |
		//------------------------+
		RecLock("SC9",.F.)
			SC9->C9_XENVWMS := "3"
			SC9->C9_XDTALT	:= Date()
			SC9->C9_XHRALT	:= Time()
		SC9->( MsUnLock() )
		
		If SC6->( dbSeeK(xFilial("SC9") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO) )
			//----------------------+
			// Atualiza item pedido | 
			//----------------------+
			RecLock("SC6",.F.)
				SC6->C6_XENVWMS := "3"
				SC6->C6_XDTALT	:= Date()
				SC6->C6_XHRALT	:= Time()
			SC6->( MsUnLock() )
		EndIf
	EndIf
	SC9->( dbSkip() )
EndDo	

RestArea(_aArea)
Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} DnApi07R

@description Elimina residuo dos pedidos 

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnApi07R(_cPedido)
Local _aArea	:= GetArea()
Local _lRet		:= .T.

//----------------------+
// Cria Itens do Pedido | 
//----------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If SC6->( dbSeek(xFilial("SC6") + SC5->C5_NUM) )
	While SC6->( !Eof() .And. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM )
		If (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0 .And. _lRet
			Pergunte("MTA500",.F.)
		    	_lRet := MaResDoFat(,.T.,.F.,,MV_PAR12 == 1,MV_PAR13 == 1)
		    Pergunte("MTA410",.F.)
		EndIf
		SC6->( dbSkip() )
	EndDo
EndIf

RestArea(_aArea)
Return _lRet

/*************************************************************************************/
/*/{Protheus.doc} DnaApi07E

@description Processa retorno da conferencia separação pedido de venda

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnaApi07E(aMsgErro,cJsonRet)
Local oJsonRet	:= Nil
Local oPedidos	:= Nil

Local nMsg		:= 0

oJsonRet						:= Array(#)
oJsonRet[#"pedidos"]			:= {}
	
For nMsg := 1 To Len(aMsgErro)
	aAdd(oJsonRet[#"pedidos"],Array(#))
	oPedidos := aTail(oJsonRet[#"pedidos"])
	oPedidos[#"filial"]		:= aMsgErro[nMsg][1]
	oPedidos[#"pedido"]		:= aMsgErro[nMsg][2]
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