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
/*/{Protheus.doc} DnaApi07A

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
Local cFilAut	:= ""
Local cRest		:= ""
Local cPedVen 	:= ""
Local cCodCli	:= ""
Local cLoja		:= ""
Local cCodTransp:= ""
Local cTipoPV	:= ""
Local cSeqLib	:= ""
Local dDtaEmiss	:= ""

Local _nTotalPv	:= 0
Local _nRecSC5	:= 0

Local oJson		:= Nil
Local oPedido	:= Nil
Local oItens	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "50" 
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
		cSeqLib := "01"
	Else
		cSeqLib := Soma1((cAlias)->SEQLIB)
	EndIf
	
	cFilAut		:= (cAlias)->FILIAL
	cPedVen 	:= (cAlias)->PEDIDO
	cCodCli		:= (cAlias)->CLIENTE
	cLoja		:= (cAlias)->LOJA
	cCodTransp	:= (cAlias)->CODTRANSP
	cTipoPV		:= (cAlias)->TIPO
	dDtaEmiss	:= dToc(sTod((cAlias)->EMISSAO))
	_nRecSC5	:= (cAlias)->RECNOSC5
	_nTotalPv	:= DnApi07TPv(cFilAut,cPedVen,1)
				 
	//-------------------------------+
	// Cria cabeçalho do pedido JSON |
	//-------------------------------+
	oPedido[#"filial"]				:= cFilAut
	oPedido[#"pedido"]				:= cPedVen
	oPedido[#"codigo_cliente"]		:= cCodCli
	oPedido[#"loja"]				:= cLoja
	oPedido[#"transportadora"]		:= cCodTransp
	oPedido[#"data_emissao"]		:= dDtaEmiss
	oPedido[#"tipo_pedido"]			:= cTipoPV
	oPedido[#"revisao"]				:= cSeqLib
	oPedido[#"total_pedido"]		:= _nTotalPv	
	//------------------------------------+
	// Cria array para os itens do pedido |
	//------------------------------------+
	oPedido[#"itens"]				:= {}
	
	While (cAlias)->( !Eof() .And. cFilAut == (cAlias)->FILIAL .And.  cPedVen == (cAlias)->PEDIDO )
		
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
		
		//-----------------------+
		// Atualiza item enviado |
		//-----------------------+
		DnApi07I(cFilAut,cPedVen,(cAlias)->ITEM,(cAlias)->PRODUTO)

		(cAlias)->( dbSkip() )
	EndDo

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
Local _nTotIt	:= 0

Local _aDiverg	:= {}
Local _aItensC	:= {}

Local _lContinua:= .T.	
Local _lLibParc	:= .F.

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

//----------------+
// Total de Itens |
//----------------+
_nTotIt := DnApi07TPv(xFilial("SC5"),_cPedido,2)

//-----------------------------------+
// Posiciona Itens Pedidos Liberados | 
//-----------------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//-----------------------------------------------------+
// Valida conferencia dos itens da Pre Nota de Entrada | 
//-----------------------------------------------------+
_oItPed 	:= _oPedido[#"itens"]

//--------------------------+
// Liberado com menos itens |
//--------------------------+
If _nTotIt <> Len(_oItPed)
	_lLibParc := .T.
EndIf

_lContinua	:= .T.
For _nPed := 1 To Len(_oItPed)
		
	//-----------------+
	// Dados dos Itens |
	//-----------------+
	_cCodProd	:= PadR(_oItPed[_nPed][#"produto"],nTProd)
	_cItem		:= PadL(_oItPed[_nPed][#"item"],nTItem,"0")
	_cLote		:= PadR(_oItPed[_nPed][#"lote"],nTLote)	
	_nQtdConf	:= _oItPed[_nPed][#"quantidade"]
	
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

If _lContinua
	//-------------------------------------+
	// Esorna liberação do pedido de venda | 
	//-------------------------------------+
	If Len(_aDiverg) > 0

		//----------------------------------+
		// Envia e-mail e estorna liberação |
		//----------------------------------+	
		DnaApi07P(_cPedido,_cCodCli,_cLoja,_aDiverg)

		//----------------------------------+
		// Libera pedido de venda novamente |
		//----------------------------------+
		DnaApi07L(_cPedido,_cCodCli,_cLoja)

		//----------------------+	
		// Log processo da nota |
		//----------------------+
		LogExec(_cPedido + "DIVERGENCIA SEPARAÇÃO.")
		aAdd(aMsgErro,{cFilAnt,_cPedido,.F.,"DIVERGENCIA SEPARAÇÃO."})
		
	//------------------------------+	
	// Libera faturamento do pedido |
	//------------------------------+	 
	Else

		//--------------------------+
		// Atualiza dados do pedido |
		//--------------------------+
		RecLock("SC5",.F.)
			SC5->C5_XENVWMS := IIF(_lLibParc,"2","3")
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
			/*
			If SC6->( dbSeeK(xFilial("SC9") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO) )
				If !Empty(SC6->C6_XENVWMS) .And. !Empty(SC6->C6_XDTALT) .And.  !Empty(SC6->C6_XHRALT)
					//------------------------+
					// Atualiza item liberado |
					//------------------------+
					RecLock("SC9",.F.)
						SC9->C9_XENVWMS := "3"
						SC9->C9_XDTALT	:= Date()
						SC9->C9_XHRALT	:= Time()
					SC9->( MsUnLock() )

					//----------------------+
					// Atualiza item pedido | 
					//----------------------+
					RecLock("SC6",.F.)
						SC6->C6_XENVWMS := "3"
						SC6->C6_XDTALT	:= Date()
						SC6->C6_XHRALT	:= Time()
					SC6->( MsUnLock() )
				Else
				*/
					//------------------------------+
					// Valida se items esta no JSON |
					//------------------------------+
					If aScan(_aItensC,{|x| RTrim(x[1]) + RTrim(x[2]) == RTrim(SC9->C9_ITEM) + RTrim(SC9->C9_PRODUTO) }) > 0
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
				//EndIf
			//EndIf	
			SC9->( dbSkip() )
		EndDo	
		
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
/*/{Protheus.doc} DnaApi07C

@description Realiza a baixa dos pedidos 

@author Bernard M. Margarido
@since 08/12/2018
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function DnaApi07C(_oPedido)
Local _aArea	:= GetArea()

Local _cFilAux	:= cFilAnt
Local _cPedido	:= PadR(_oPedido[#"pedido"],nTPed)
Local _cCodCli	:= PadR(_oPedido[#"codigo_cliente"],nTCodCli)
Local _cLoja	:= PadR(_oPedido[#"loja"],nTLoja)
Local _cSeqLib	:= RTrim(_oPedido[#"revisao"])

//------------------------+
// Posiciona filial atual | 
//------------------------+
cFilAnt := RTrim(_oPedido[#"filial"])

//------------------+
// Posiciona Pedido | 
//------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
If !SC5->( dbSeek(xFilial("SC5") + _cPedido + _cCodCli + _cLoja) )
	aAdd(aMsgErro,{cFilAnt,_cPedido,.F.,"PEDIDO NAO ENCONTRADO."})
	RestArea(_aArea)
	Return .F.
EndIf

//----------------------------------+
// Valida se Pedido já foi expedido | 
//----------------------------------+
If SC5->C5_XENVWMS == "3"
	aAdd(aMsgErro,{cFilAnt,_cPedido,.F.,"PEDIDO JÁ SEPARADO."})
	RestArea(_aArea)
	Return .F.
EndIf

//---------------------------+
// Atualiza Status do Pedido |
//---------------------------+
RecLock("SC5",.F.)
	SC5->C5_XENVWMS := "2"
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
cQuery += "		CLIENTE, " + CRLF
cQuery += "		LOJA, " + CRLF
cQuery += "		CODTRANSP, " + CRLF
cQuery += "		EMISSAO, " + CRLF
cQuery += "		TIPO, " + CRLF
cQuery += "		SEQLIB, " + CRLF
cQuery += "		RECNOSC5, " + CRLF
cQuery += "		ITEM, " + CRLF
cQuery += "		PRODUTO, " + CRLF
cQuery += "		QTDLIB, " + CRLF
cQuery += "		PRCVEN, " + CRLF
cQuery += "		PRCTOTAL, " + CRLF
cQuery += "		UM, " + CRLF
cQuery += "		LOTE, " + CRLF
cQuery += "		DTVALID, " + CRLF
cQuery += "		ARMAZEM " + CRLF
cQuery += "	FROM ( " + CRLF
cQuery += "			SELECT " + CRLF
cQuery += "				ROW_NUMBER() OVER(ORDER BY C5.C5_NUM) RNUM, " + CRLF
cQuery += "				C5.C5_FILIAL FILIAL, " + CRLF
cQuery += "				C5.C5_NUM PEDIDO, " + CRLF
cQuery += "				C5.C5_CLIENTE CLIENTE, " + CRLF
cQuery += "				C5.C5_LOJACLI LOJA, " + CRLF
cQuery += "				C5.C5_TRANSP CODTRANSP, " + CRLF
cQuery += "				C5.C5_EMISSAO EMISSAO, " + CRLF
cQuery += "				C5.C5_TIPO TIPO, " + CRLF
cQuery += "				C5.C5_XSEQLIB SEQLIB, " + CRLF
cQuery += "				C5.R_E_C_N_O_ RECNOSC5, " + CRLF

/*
cQuery += "				C6.C6_ITEM ITEM, " + CRLF
cQuery += "				C6.C6_PRODUTO PRODUTO, " + CRLF
cQuery += "				C6.C6_QTDVEN QTDLIB, " + CRLF
cQuery += "				C6.C6_PRCVEN PRCVEN, " + CRLF
cQuery += "				C6.C6_VALOR PRCTOTAL, " + CRLF
cQuery += "				C6.C6_UM UM, " + CRLF
cQuery += "				C6.C6_LOTECTL LOTE, " + CRLF
cQuery += "				C6.C6_DTVALID DTVALID, " + CRLF
cQuery += "				C6.C6_LOCAL ARMAZEM " + CRLF
*/

cQuery += "				C9.C9_ITEM ITEM, " + CRLF
cQuery += "				C9.C9_PRODUTO PRODUTO, " + CRLF
cQuery += "				C9.C9_QTDLIB QTDLIB, " + CRLF
cQuery += "				C6.C6_PRCVEN PRCVEN, " + CRLF
cQuery += "				C6.C6_VALOR PRCTOTAL, " + CRLF
cQuery += "				C6.C6_UM UM, " + CRLF
cQuery += "				C9.C9_LOTECTL LOTE, " + CRLF
cQuery += "				C9.C9_DTVALID DTVALID, " + CRLF
cQuery += "				C9.C9_LOCAL ARMAZEM " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SC5") + " C5 " + CRLF 

cQuery += "				INNER JOIN " + RetSqlName("SC6") + " C6 ON C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM AND C6.C6_NOTA = '' AND C6.C6_SERIE = '' AND C6.C6_BLQ <> 'R' AND C6.D_E_L_E_T_ = '' " + CRLF
cQuery += "				INNER JOIN " + RetSqlName("SC9") + " C9 ON C9.C9_FILIAL = C6.C6_FILIAL AND C9.C9_PEDIDO = C6.C6_NUM AND C9.C9_PRODUTO = C6.C6_PRODUTO AND C9.C9_ITEM = C6.C6_ITEM AND C9.C9_BLEST = '' AND C9.C9_BLCRED = '' AND C9.C9_NFISCAL = '' AND C9.D_E_L_E_T_ = '' " + CRLF

cQuery += "			WHERE " + CRLF

If _lSC5Comp
	cQuery += "				C5.C5_FILIAL = '" + xFilial("SC5") + "' AND " + CRLF
Else
	cQuery += "				C5.C5_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf
	
cQuery += "				C5.C5_XENVWMS IN('1') AND " + CRLF
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
cQuery += "	) PEDIDO  " + CRLF
cQuery += "	WHERE RNUM > " + cTamPage + " * (" + cPage + " - 1) " + CRLF 
cQuery += "	ORDER BY FILIAL,PEDIDO,ITEM"

//LogExec(cQuery)

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
cQuery += "		COUNT(*) TOTREG " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "				" + RetSqlName("SC5") + " C5 " + CRLF 

//cQuery += "				INNER JOIN " + RetSqlName("SC6") + " C6 ON C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM AND C6.D_E_L_E_T_ = '' " + CRLF
//cQuery += "				INNER JOIN " + RetSqlName("SC9") + " C9 ON C9.C9_FILIAL = C6.C6_FILIAL AND C9.C9_PEDIDO = C6.C6_NUM AND C9.C9_PRODUTO = C6.C6_PRODUTO AND C9.C9_ITEM = C6.C6_ITEM AND C9.C9_BLEST = '' AND C9.C9_BLCRED = '' AND C9.C9_NFISCAL = '' AND C9.D_E_L_E_T_ = '' " + CRLF

cQuery += "			WHERE " + CRLF

If _lSC5Comp
	cQuery += "				C5.C5_FILIAL = '" + xFilial("SC5") + "' AND " + CRLF
Else
	cQuery += "				C5.C5_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

cQuery += "				C5.C5_XENVWMS IN('1') AND " + CRLF
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
cQuery += "				C5.D_E_L_E_T_ = ''  " + CRLF
//cQuery += "		GROUP BY C5.C5_NUM " + CRLF
//cQuery += "		HAVING COUNT(C5.C5_NUM) > 0 "

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
DnApi07M(_cPedido,_cCodCli,_cLoja,_aDiverg)

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
	SC5->C5_XENVWMS := "2"
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

Local _lCredito 	:= .F.
Local _lEstoque		:= .F.
Local _lLiber		:= .T.
Local _lTransf   	:= .F.
Local _lRet			:= .T.

//-----------------+
// Pedido de venda | 
//-----------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
RecLock("SC5",.F.)
	SC5->C5_XENVWMS := "1"
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
		MaLibDoFat(SC6->(RecNo()),_nQtdLib,@_lCredito,@_lEstoque,.T.,.T.,_lLiber,_lTransf)
	EndIf

	//-------------------------+
	// Atualiza flag dos itens |
	//-------------------------+
	RecLock("SC6",.F.)
		SC6->C6_XENVWMS := ""
		SC6->C6_XDTALT	:= dToc('')
		SC6->C6_XHRALT	:= ""
	SC6->( MsUnLock() )

	SC6->( dbSkip() )
EndDo

//-----------------------------+
// Destrava todos os registros |
//-----------------------------+
MsUnLockAll()

//---------------------------+
// Grava liberação do Pedido |
//---------------------------+
SC6->( MaLiberOk({_cPedido},.F.) )

RestArea(_aArea)
Return _lRet

/*************************************************************************************/
/*/{Protheus.doc} DnApi07M

@description Envia e-mail com a divergencia separação dos pedidos 

@author Bernard M. Margarido
@since 21/11/2018
@version 1.0
@type function
/*/
/*************************************************************************************/
Static Function DnApi07M(_cPedido,_cCodCli,_cLoja,_aDiverg)
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
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//-----------------------------+
// Posiciona Itens da Pre Nota | 
//-----------------------------+
//dbSelectArea("SC9")
//SC9->( dbSetOrder(1) )

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//-----------------------------+
// Adiciona dados do cabeçalho |
//-----------------------------+
If !SC5->( dbSeek(xFilial("SC5") + _cPedido) )
	RestArea(aArea)
	Return .F.
EndIf

//---------------------+
// Valida Tipo de Nota | 
//---------------------+
If SC5->C5_TIPO == "N"

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

cHtml := '<html>'
cHtml += '	<head>'
cHtml += '		<title>Pedido de Venda</title>'
cHtml += '		<style>'
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
cHtml += '		</style>'
cHtml += '	</head>'
cHtml += '	<body>'
cHtml += '		<table style="color: rgb(0,0,0)" width="100%" border=1>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '					<td class=s_a width="100%"><p align=center><b>Pedido de Venda - Divergência Separação WMS</b></p></td>'
cHtml += '				</tr>'
cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<table style="color: rgb(0,0,0)" width="100%" cellspacing=0 border=0>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '					<td class=s_t width="100%"><p align=center><b>Dados Pedido de Venda</b></p></td>'
cHtml += '				</tr>'
cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<table style="width: 100%; height: 26px" cellspacing=0 border=1>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '					<td class=s_u colspan = "2"><b>Numero:</b> ' + ' ' + SC5->C5_NUM + '</td>'
cHtml += '					<td class=s_u colspan = "2"><b>Emissão:</b>' + ' ' + FsDateConv(SC5->C5_EMISSAO,"DDMMYYYY") + '</td>'
cHtml += '				</tr>'
cHtml += '				<tr>'
cHtml += '					<td class=s_u colspan = "7"><b>Cliente:</b>' + ' ' + _cCliFor + ' - ' + _cLoja + ' '   + _cNReduz + '</td>'
cHtml += '				</tr>'
cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<table style="color: rgb(0,0,0)" width="100%" cellspacing=0 border=0>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '					<td class=s_t width="100%"><p align=center><b>Itens Pedido</b></p></td>'
cHtml += '				</tr>'
cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<table style="width: 100%; height: 26px" cellspacing=0 border=1>'
cHtml += '			<tbody>'
cHtml += '				<tr>'  					
cHtml += '					<td class=s_u colspan = "1"><b>Item</b></td>'
cHtml += '					<td class=s_u colspan = "3"><b>Produto</b></td>'
cHtml += '					<td class=s_u colspan = "6"><b>Descricao</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Qtd. Nota</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Qtd. Conf.</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Armazem</b></td>'
cHtml += '				</tr>'

//-----------------+
// Itens liberados | 
//-----------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

For _nX := 1 To Len(_aDiverg)
	
	//------------------------+
	// Posiciona Item da Nota | 
	//------------------------+
	SC9->( dbSeek(xFilial("SC9") + _cPedido + _aDiverg[_nX][1] ) )
		
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB1->( dbSeek(xFilial("SB1") + _aDiverg[_nX][2]) )
	
	cHtml += '				<tr>' + CRLF
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SC9->C9_ITEM + '</td>'
	cHtml += '					<td class=s_u colspan = "3"><b></b>' + SC9->C9_PRODUTO + '</td>'
	cHtml += '					<td class=s_u colspan = "6"><b></b>' + SB1->B1_DESC + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(SC9->C9_QTDLIB)) + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(_aDiverg[_nX][3])) + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SC9->C9_LOCAL + '</td>'
	cHtml += '				</tr>'
	
Next _nX	

cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<p>Workflow enviado automaticamente pelo Protheus - Perfumes Dana</p>'
cHtml += '	</body>'
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