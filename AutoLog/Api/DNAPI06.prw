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

Private cArqLog		:= ""
Private _cFilWMS	:= FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

Private _lSF1Comp 	:= ( FWModeAccess("SF1",3) == "C" )
Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)

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

Local nNFE			:= 0

Local oJson			:= Nil

Private cJsonRet	:= ""

Private aMsgErro	:= {}
Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)

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

//------------+
// Grava JSON |
//------------+
If _lGrvJson
	MakeDir("\AutoLog\")
	MakeDir("\AutoLog\arquivos\")
	MakeDir("\AutoLog\arquivos\nfentrada")
	MemoWrite("\AutoLog\arquivos\nfentrada\json_post_nfentrada_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cBody)
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
Local nNFE			:= 0

Local oJson			:= Nil

Private cJsonRet	:= ""
	
Private aMsgErro	:= {}
Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)
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

//------------+
// Grava JSON |
//------------+
If _lGrvJson
	MakeDir("\AutoLog\")
	MakeDir("\AutoLog\arquivos\")
	MakeDir("\AutoLog\arquivos\nfentrada")
	MemoWrite("\AutoLog\arquivos\nfentrada\json_put_nfentrada_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cBody)
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
Local cSerieNf	:= ""
Local cCodForn	:= ""
Local cLoja		:= ""
Local cCnpj		:= ""
Local cCodTransp:= ""
Local cTpDoc	:= ""
Local dDtaEmiss	:= ""
Local cFilAux	:= ""

Local _nX		:= 0
Local _nPProd	:= 0

Local _aProdutos:= {}

Local oJson		:= Nil
Local oNFE		:= Nil
Local oItens	:= Nil

Private nTotPag	:= 0
Private nTotQry	:= 0

Default cTamPage:= "200" 
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

//-------------------------+
// Posiciona Itens da Nota |
//-------------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )

//-------------------------+
// SB1 - Posiciona Produto |
//-------------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

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
	cSerieNf	:= (cAlias)->SERIE
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
	oNFE[#"serie"]				:= cSerieNf
	oNFE[#"codigo_fornecedor"]	:= cCodForn
	oNFE[#"loja"]				:= cLoja
	oNFE[#"cnpj"]				:= cCnpj
	oNFE[#"transportadora"]		:= cCodTransp
	oNFE[#"data_emissao"]		:= dDtaEmiss
	oNFE[#"tipo_documento"]		:= cTpDoc
	
	//------------------------+
	// Posiciona filial atual |
	//------------------------+
	If cFilAnt <> cFilAtu
		cFilAux	:= cFilAnt
		cFilAnt := cFilAtu
	EndIf

	If SD1->( dbSeek(xFilial("SD1") + cDoc + cSerieNf + cCodForn + cLoja) )

		While SD1->( !Eof() .And. xFilial("SD1") + cDoc + cSerieNf + cCodForn + cLoja == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA )
			
			//-------------------+
			// Posiciona produto |
			//-------------------+
			If SB1->( dbSeek(xFilial("SB1") + SD1->D1_COD) )
				//-------------------------+
				// Somente produto acabado |
				//-------------------------+
				If RTrim(SB1->B1_TIPO) $ 'PA/MR'
					
					If ( _nPProd := aScan(_aProdutos,{|x| RTrim(x[2]) == RTrim(SD1->D1_COD)}) > 0 )
						_aProdutos[_nPProd][3] += SD1->D1_QUANT
					Else 
						aAdd(_aProdutos,{SD1->D1_ITEM,SD1->D1_COD,SD1->D1_QUANT,SD1->D1_UM,SD1->D1_LOTECTL,SD1->D1_DTVALID,SD1->D1_LOCAL})
					EndIf 

				EndIf 
			EndIf 
			SD1->( dbSkip() )
		EndDo

		If Len(_aProdutos) > 0 

			//----------------------------------+
			// Cria array para os itens da nota |
			//----------------------------------+
			oNFE[#"itens"]				:= {}

			For _nX := 1 To Len(_aProdutos)

				//---------------+
				// Itens da Nota |
				//---------------+
				aAdd(oNFE[#"itens"],Array(#))
				oItens := aTail(oNFE[#"itens"])
				oItens[#"item"]			:= _aProdutos[_nX][1]
				oItens[#"produto"]		:= _aProdutos[_nX][2]
				oItens[#"quantidade"]	:= _aProdutos[_nX][3]
				oItens[#"um"]			:= _aProdutos[_nX][4]
				oItens[#"lote"]			:= _aProdutos[_nX][5]
				oItens[#"data_validade"]:= _aProdutos[_nX][6]
				oItens[#"armazem"]		:= _aProdutos[_nX][7]

			Next _nX 

		EndIf 
		//-----------------------+
		// Restaura filial atual | 
		//-----------------------+
		If cFilAnt <> cFilAux
			cFilAnt := cFilAux
		EndIf

		(cAlias)->( dbSkip() )

	EndIf
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

//------------+
// Grava JSON |
//------------+
If _lGrvJson
	MakeDir("\AutoLog\")
	MakeDir("\AutoLog\arquivos\")
	MakeDir("\AutoLog\arquivos\nfentrada")
	MemoWrite("\AutoLog\arquivos\nfentrada\json_get_nfentrada_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cRest)
EndIf

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
Local _nPProd	:= 0

Local _aDiverg	:= {}
Local _aProdutos:= {}

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
		If ( _nPProd := aScan(_aProdutos,{|x| RTrim(x[2]) == RTrim(SD1->D1_COD)}) > 0 )
			_aProdutos[_nPProd][3] += SD1->D1_QUANT
		Else 
			aAdd(_aProdutos,{SD1->D1_ITEM,SD1->D1_COD,_nQtdConf,SD1->D1_UM,SD1->D1_LOTECTL,SD1->D1_DTVALID,SD1->D1_LOCAL})
		EndIf 
	EndIf			
		
Next _nNFE

If Len(_aProdutos) > 0 
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
		aAdd(aMsgErro,{cFilAnt,_cNota,_cSerie,.T.,"PRE NOTA COM DIVERGENCIA."})
		
	//------------------------------+	
	// Libera classificação da Nota |
	//------------------------------+	 
	Else
	
		RecLock("SF1",.F.)
			SF1->F1_XENVWMS := "3"
			SF1->F1_XDTALT	:= Date()
			SF1->F1_XHRALT	:= Time()
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
	SF1->F1_XDTALT	:= Date()
	SF1->F1_XHRALT	:= Time()
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
cQuery += "		RECNOSF1 " + CRLF
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
cQuery += "			RECNOSF1 " + CRLF
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
cQuery += "				F1.R_E_C_N_O_ RECNOSF1 " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SF1") + " F1 " + CRLF
cQuery += "				INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = F1.F1_FILIAL AND D1.D1_DOC = F1.F1_DOC AND D1.D1_SERIE = F1.F1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE AND D1.D1_LOJA = F1.F1_LOJA AND D1.D1_PEDIDO <> '' AND D1.D1_ITEMPC <> '' AND D1.D_E_L_E_T_ = '' " + CRLF
//cQuery += "				INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = F1.F1_FILIAL AND D1.D1_DOC = F1.F1_DOC AND D1.D1_SERIE = F1.F1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE AND D1.D1_LOJA = F1.F1_LOJA AND D1.D_E_L_E_T_ = '' " + CRLF
//cQuery += "				INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = SD1.D1_FILIAL AND F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF 
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
cQuery += "			GROUP BY F1.F1_FILIAL,F1.F1_DOC,F1.F1_SERIE,F1.F1_FORNECE,F1.F1_LOJA,A2.A2_CGC,F1.F1_TRANSP,F1.F1_DTDIGIT,F1.F1_TIPO,F1.R_E_C_N_O_ " + CRLF

cQuery += "		UNION ALL " + CRLF

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
cQuery += "				F1.R_E_C_N_O_ RECNOSF1 " + CRLF
cQuery += "			FROM " + CRLF
cQuery += "				" + RetSqlName("SF1") + " F1 " + CRLF
cQuery += "				INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = F1.F1_FILIAL AND D1.D1_DOC = F1.F1_DOC AND D1.D1_SERIE = F1.F1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE AND D1.D1_LOJA = F1.F1_LOJA AND D1.D_E_L_E_T_ = '' " + CRLF
//cQuery += "				INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = SD1.D1_FILIAL AND F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF 
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
cQuery += "			GROUP BY F1.F1_FILIAL, F1.F1_DOC, F1.F1_SERIE, F1.F1_FORNECE, F1.F1_LOJA, A1.A1_CGC, F1.F1_TRANSP, F1.F1_DTDIGIT, F1.F1_TIPO, F1.R_E_C_N_O_ " + CRLF
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
cQuery += "		COUNT(DOC) TOTREG " + CRLF
cQuery += "	FROM " + CRLF
cQuery += " ( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			F1.F1_FILIAL FILIAL, " + CRLF
cQuery += "			F1.F1_DOC DOC, " + CRLF
cQuery += "			F1.F1_SERIE SERIE, " + CRLF
cQuery += "			F1.F1_FORNECE FORNECE, " + CRLF
cQuery += "			F1.F1_LOJA LOJA " + CRLF
cQuery += "		FROM " + CRLF 
cQuery += "			" + RetSqlName("SF1") + " F1 " + CRLF

cQuery += "			INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = F1.F1_FILIAL AND D1.D1_DOC = F1.F1_DOC AND D1.D1_SERIE = F1.F1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE AND D1.D1_LOJA = F1.F1_LOJA AND D1.D1_PEDIDO <> '' AND D1.D1_ITEMPC <> '' AND D1.D_E_L_E_T_ = '' " + CRLF 
//cQuery += "			INNER JOIN " + RetSqlName("SF4") + " F4 ON F4.F4_FILIAL = D1.D1_FILIAL AND F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + CRLF 
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = F1.F1_FORNECE AND A1.A1_LOJA = F1.F1_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF    
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SA2") + " A2 ON A2.A2_FILIAL = D1.D1_FILIAL AND A2.A2_COD = F1.F1_FORNECE AND A2.A2_LOJA = F1.F1_LOJA AND A2.D_E_L_E_T_ = '' " + CRLF

cQuery += "		WHERE " + CRLF

If _lSF1Comp
	cQuery += "			F1.F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
Else
	cQuery += "			F1.F1_FILIAL IN" + _cFilWMS + " AND " + CRLF
EndIf

If Empty(cNota) .And. Empty(cSerie) 
	cQuery += "		CAST((F1.F1_XDTALT + ' ' + F1.F1_XHRALT) AS DATETIME) >= CAST(('" + cData + "' + ' ' + '" + cHora + ".000') AS DATETIME) AND " + CRLF
	cQuery += "		CAST((F1.F1_XDTALT + ' ' + F1.F1_XHRALT) AS DATETIME) <= CAST(('" + dTos(dDataBase) + "' + ' ' + '" + Time() + ".000') AS DATETIME) AND " + CRLF
Else	 
	cQuery += "		F1.F1_DOC = '" + cNota + "' AND " + CRLF
	cQuery += "		F1.F1_SERIE = '" + cSerie + "' AND " + CRLF
EndIf
 
cQuery += "		F1.F1_XENVWMS IN (' ','1') AND " + CRLF
cQuery += "		F1.F1_TIPO IN ('N','D','B') AND " + CRLF
cQuery += "		F1.F1_STATUS = '' AND " + CRLF
cQuery += "		F1.D_E_L_E_T_ = '' " + CRLF
cQuery += "	GROUP BY F1.F1_FILIAL,F1.F1_DOC,F1.F1_SERIE,F1.F1_FORNECE,F1.F1_LOJA " + CRLF
cQuery += ") NFENTRADA " + CRLF

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

Local lRet			:= .T.
Local _lEstorna		:= GetNewPar("DN_DELNFE",.T.)

//--------------+
// Envia e-Mail |
//--------------+
U_DnMailNf(_cNota,_cSerie,_cCodFor,_cLojafor,_aDiverg)

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

//------------------+
// Estorna pre nota |
//------------------+
If _lEstorna
	LogExec("ESTORNANDO PRE NOTA COM DIVERGENCIA.")
	lRet := u_DNEstM01(_cNota,_cSerie,_cCodFor,_cLojafor)
Else
	//---------------------------------+
	// Permiti dar entrada na pre nota |
	//---------------------------------+
	RecLock("SF1",.F.)
		SF1->F1_XENVWMS := "3"
		SF1->F1_XDTALT	:= Date()
		SF1->F1_XHRALT	:= Time()
	SF1->( MsUnLock() )
EndIf

RestArea(aArea)
Return lRet 

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
