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

Private cArqLog		:= ""
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

Private _lSF2Comp 	:= ( FWModeAccess("SF2",3) == "C" )
Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)

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
Local aArea			:= GetArea()

Local nPed			:= 0

Local oJson			:= Nil
Local oPedido		:= Nil

Private cJsonRet	:= ""
	
Private aMsgErro	:= {}
Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)

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
	HTTPSetStatus(400,"Arquivo POST nço enviado.")
	Return .T.
EndIf

//------------+
// Grava JSON |
//------------+
If _lGrvJson
	MakeDir("\AutoLog\")
	MakeDir("\AutoLog\arquivos\")
	MakeDir("\AutoLog\arquivos\nfsaidaconf")
	MemoWrite("\AutoLog\arquivos\nfsaidaconf\json_post_nfsaidaconf_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cBody)
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
	LogExec("INICIA VALIDACAO DA SEPARACAO DA NOTA " + RTrim(oPedido[nPed][#"nota"]) )
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
Local aArea			:= GetArea()

Local nPed			:= 0

Local oJson			:= Nil
Local oPedido		:= Nil

Private cJsonRet	:= ""
	
Private aMsgErro	:= {}

Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)

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
	HTTPSetStatus(400,"Arquivo POST nço enviado.")
	Return .T.
EndIf

//------------+
// Grava JSON |
//------------+
If _lGrvJson
	MakeDir("\AutoLog\")
	MakeDir("\AutoLog\arquivos\")
	MakeDir("\AutoLog\arquivos\nfsaidaconf")
	MemoWrite("\AutoLog\arquivos\nfsaidaconf\json_put_nfsaidaconf_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cBody)
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
	LogExec("INICIA VALIDACAO DA BAIXA DA NOTA " + RTrim(oPedido[nPed][#"nota"]) )
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

Local cAlias	:= "" //GetNextAlias()	
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

If !DnaApiQry(@cAlias,cFilNF,cNota,cSerie,cDataHora,cTamPage,cPage)
	
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

//---------------------+
// Nota Fiscal - Itens |
//---------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )

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
	
	cFilAut			:= (cAlias)->FILIAL
	cNota			:= (cAlias)->NOTA
	cSerie			:= (cAlias)->SERIE
	
	//---------------------------------------------+
	// Ricardo Evangelista, Inserindo novos campos |
	//---------------------------------------------+
	cID_ecommerce	:= (cAlias)->ID_ECOMMERCEX

	cCodCli			:= (cAlias)->CLIENTE
	cLoja			:= (cAlias)->LOJA
	cCodTransp		:= (cAlias)->CODTRANSP
	cTipoPV			:= (cAlias)->TIPO
	cPedVen			:= (cAlias)->PEDIDO
	_nTotalPv		:= (cAlias)->TOTALNF
	
	dDtaEmiss		:= dToc(sTod((cAlias)->EMISSAO))
				 
	//-------------------------------+
	// Cria cabeçalho do pedido JSON |
	//-------------------------------+
	oPedido[#"filial"]				:= cFilAut
	oPedido[#"pedido"]				:= cPedVen
	oPedido[#"nota"]				:= cNota
	oPedido[#"serie"]				:= cSerie
	
	//---------------------------------------------+
	// Ricardo Evangelista, Inserindo novos campos |
	//---------------------------------------------+
	oPedido[#"id_ecommerce"]		:= cID_ecommerce

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
	
	If SD2->( dbSeek(cFilAut + cNota + cSerie + cCodCli + cLoja ) )

		While SD2->( !Eof() .And. cFilAut + cNota + cSerie + cCodCli + cLoja == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA )
		
			//-----------------+
			// Itens do pedido |
			//-----------------+
			aAdd(oPedido[#"itens"],Array(#))
			oItens := aTail(oPedido[#"itens"])
			oItens[#"item"]			:= SD2->D2_ITEM 
			oItens[#"produto"]		:= SD2->D2_COD
			oItens[#"quantidade"]	:= SD2->D2_QUANT
			oItens[#"valor_unit"]	:= SD2->D2_PRCVEN
			oItens[#"valor_total"]	:= SD2->D2_TOTAL
			oItens[#"um"]			:= SD2->D2_UM
			oItens[#"lote"]			:= SD2->D2_LOTECTL
			oItens[#"data_validade"]:= SD2->D2_DTVALID
			oItens[#"armazem"]		:= SD2->D2_LOCAL
					
			SD2->( dbSkip() )
		EndDo
	EndIf

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

//------------+
// Grava JSON |
//------------+
If _lGrvJson
	MakeDir("\AutoLog\")
	MakeDir("\AutoLog\arquivos\")
	MakeDir("\AutoLog\arquivos\nfsaidaconf")
	MemoWrite("\AutoLog\arquivos\nfsaidaconf\json_get_nfsaidaconf_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cRest)
EndIf

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
Local _cCodSta	:= "006"
Local _cFilAux	:= cFilAnt
	
Local _nQtdConf	:= 0
Local _nPed		:= 0

Local _aDiverg	:= {}

Local _lContinua:= .T.	

Local _oItPed	:= Nil

//------------------------+
// Posiciona Filial atual | 
//------------------------+
_cFilNF 	:= RTrim(_oPedido[#"filial"])

If cFilAnt <> _cFilNF
	cFilAnt := _cFilNF
EndIf 

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
// Valida se nota jç foi conferido | 
//---------------------------------+
If SF2->F2_XENVWMS == "3"
	LogExec("NOTA " + _cNota + " SERIE " + _cSerie + " Jç SEPARADO.")
	aAdd(aMsgErro,{cFilAnt,_cNota+_cSerie,.F.,"Jç SEPARADO."})
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
	
	//------------------------+
	// Grava numero do pedido | 
	//------------------------+
	_cPedido	:= SD2->D2_PEDIDO
		 
	//--------------------+
	// Valida conferencia |
	//--------------------+
	If _lContinua
		If _nQtdConf <> SD2->D2_QUANT
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
		LogExec(_cNota + _cSerie + "DIVERGENCIA SEPARAçãO.")
		aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.F.,"DIVERGENCIA SEPARAçãO."})
		
	//------------------------------+	
	// Libera faturamento do pedido |
	//------------------------------+	 
	Else
	
		RecLock("SF2",.F.)
			SF2->F2_XENVWMS := "3"
			SF2->F2_XDTALT	:= Date()
			SF2->F2_XHRALT	:= Time()
			SF2->F2_ESPECI1	:= IIF(Empty(SF2->F2_XNUMECO),"CAIXAS","EMBALAGEM")
			SF2->F2_VOLUME1	:= _nVolume
		SF2->( MsUnLock() )
		
		//------------------+
		// Atualiza pedidos |
		//------------------+
		dbSelectArea("SC5")
		SC5->( dbSetOrder(1) )
		If SC5->( dbSeek(xFilial("SC5") + _cPedido) )
			RecLock("SC5",.F.)
				SC5->C5_ESPECI1	:= IIF(Empty(SF2->F2_XNUMECO),"CAIXAS","EMBALAGEM")
				SC5->C5_VOLUME1	:= _nVolume
			SC5->( MsUnLock() )
		EndIf	

		//-------------------------------+	
		// Valida se é pedido e-Commerce |
		//-------------------------------+
		If !Empty(SF2->F2_XNUMECO)

			//------------------------------+
			// Posiciona status de Despacho |
			//------------------------------+
			dbSelectArea("WS1")
			WS1->( dbSetOrder(1) )
			WSA->( dbSeek(xFilial("WS1") + _cCodSta) )

			//----------------------------+
			// Atualiza dados de despacho | 
			//----------------------------+
			dbSelectArea("WSA")
			WSA->( dbSetOrder(2) )
			If WSA->( dbSeek(xFilial("WSA") + SF2->F2_XNUMECO) )
				RecLock("WSA",.F.)
					WSA->WSA_ESPECI	 := "EMBALAGEM" 
					WSA->WSA_VOLUME  := _nVolume
					WSA->WSA_CODSTA  := _cCodSta
                	WSA->WSA_DESTAT  := WS1->WS1_DESCRI
				WSA->( MsUnLock() )
			EndIf

		EndIf
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
If cFilAnt <> _cFilAux
	cFilAnt := _cFilAux
EndIf 

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
_cFilNF := RTrim(_oPedido[#"filial"])

If cFilAnt <> _cFilNF
	cFilAnt := _cFilNF
EndIf 

dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cNota + _cSerie + _cCodCli + _cLoja) )
	LogExec("NOTA " + _cNota + " SERIE " + _cSerie + " NAO LOCALIZADO")
	aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.F.,"NOTA NAO LOCALIZADO" })
	RestArea(_aArea)
	Return .F.
EndIf

//----------------------------------+
// Valida se Pedido ja foi expedido | 
//----------------------------------+
If SF2->F2_XENVWMS == "3"
	aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.F.,"NOTA JA SEPARADO."})
	RestArea(_aArea)
	Return .F.
EndIf

//---------------------------+
// Atualiza Status do Pedido |
//---------------------------+
RecLock("SF2",.F.)
	SF2->F2_XENVWMS := "2"
	SF2->F2_XDTALT	:= Date()
	SF2->F2_XHRALT	:= Time()
SF2->( MsUnLock() )

aAdd(aMsgErro,{cFilAnt,_cNota + _cSerie,.T.,"NOTA BAIXADO COM SUCESSO."})

//-------------------------+
// Restaura a filial atual |
//-------------------------+
If cFilAnt <> _cFilAux
	cFilAnt := _cFilAux
EndIf 

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
cQuery += "		ID_ECOMMERCEX, " + CRLF
cQuery += "		SERIE, " + CRLF
cQuery += "		CLIENTE, " + CRLF
cQuery += "		LOJA, " + CRLF
cQuery += "		CODTRANSP, " + CRLF
cQuery += "		EMISSAO, " + CRLF
cQuery += "		TIPO, " + CRLF
cQuery += "		TOTALNF, " + CRLF
cQuery += "		PEDIDO, " + CRLF
cQuery += "		RECNOSF2 " + CRLF
cQuery += "	FROM ( " + CRLF
cQuery += "			SELECT " + CRLF
cQuery += "				ROW_NUMBER() OVER(ORDER BY F2.F2_DOC) RNUM, " + CRLF
cQuery += "				F2.F2_FILIAL FILIAL, " + CRLF
cQuery += "				F2.F2_DOC NOTA, " + CRLF
cQuery += "				F2.F2_XNUMECO ID_ECOMMERCEX, " + CRLF
cQuery += "				F2.F2_SERIE SERIE, " + CRLF
cQuery += "				F2.F2_CLIENTE CLIENTE, " + CRLF
cQuery += "				F2.F2_LOJA LOJA, " + CRLF
cQuery += "				F2.F2_TRANSP CODTRANSP, " + CRLF
cQuery += "				F2.F2_EMISSAO EMISSAO, " + CRLF
cQuery += "				F2.F2_TIPO TIPO, " + CRLF
cQuery += "				F2.F2_VALFAT TOTALNF, " + CRLF
cQuery += "				PEDIDO_NOTA.PEDIDO PEDIDO, " + CRLF
cQuery += "				F2.R_E_C_N_O_ RECNOSF2 " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SF2") + " F2 " + CRLF
cQuery += "				CROSS APPLY( " + CRLF
cQuery += "							SELECT " + CRLF
cQuery += "								D2.D2_PEDIDO PEDIDO " + CRLF
cQuery += "							FROM " + CRLF
cQuery += "								" + RetSqlName("SD2") + " D2 " + CRLF
cQuery += "							WHERE " + CRLF
cQuery += "								D2.D2_FILIAL = F2.F2_FILIAL AND " + CRLF
cQuery += "								D2.D2_DOC = F2.F2_DOC AND " + CRLF
cQuery += "								D2.D2_SERIE = F2.F2_SERIE AND " + CRLF
cQuery += "								D2.D2_CLIENTE = F2.F2_CLIENTE AND " + CRLF
cQuery += "								D2.D2_LOJA = F2.F2_LOJA AND " + CRLF
cQuery += "								D2.D_E_L_E_T_ = '' " + CRLF
cQuery += "							GROUP BY D2.D2_PEDIDO " + CRLF
cQuery += "				) PEDIDO_NOTA " + CRLF
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
	cQuery += "				F2.F2_XENVWMS = '1' AND " + CRLF
	cQuery += "				F2.F2_TIPO IN('N','D','B') AND " + CRLF
	//cQuery += "				F2.F2_XNUMECO = '' AND " + CRLF
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "				F2.F2_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "				F2.F2_SERIE = '" + cSerie + "' AND " + CRLF
EndIf

cQuery += "			F2.D_E_L_E_T_ = ''  " + CRLF
cQuery += "	) PEDIDO  " + CRLF
cQuery += "	WHERE RNUM > " + cTamPage + " * (" + cPage + " - 1) " + CRLF 
cQuery += "	ORDER BY FILIAL,NOTA,SERIE"

//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
cAlias := MPSysOpenQuery(cQuery)

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
Local cAlias	:= "" //GetNextAlias()

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
	//cQuery += "				F2.F2_XNUMECO = '' AND " + CRLF
	cQuery += "				F2.F2_XENVWMS = '1' AND " + CRLF
	cQuery += "				F2.F2_TIPO IN('N','D','B') AND " + CRLF
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "				CAST((F2.F2_XDTALT + ' ' + F2.F2_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else
	cQuery += "				F2.F2_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "				F2.F2_SERIE = '" + cSerie + "' AND " + CRLF
EndIf

cQuery += "				F2.D_E_L_E_T_ = ''  " + CRLF

//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
cAlias := MPSysOpenQuery(cQuery)

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
u_DnMailNS(_cNota,_cSerie,_cCodCli,_cLoja,_aDiverg)

/*
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
// Itens da Prç Nota | 
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
*/

RestArea(aArea)
Return lRet 

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

oJsonRet					:= Array(#)
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
