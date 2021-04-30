#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cCodInt	:= "009"
Static cDescInt	:= "MOVINT"
Static cDirRaiz := "\wms\"

Static nTProd	:= TamSx3("B1_COD")[1]
Static nTLote	:= TamSx3("B8_LOTECTL")[1]
Static nTLocal	:= TamSx3("B2_LOCAL")[1]
	
/************************************************************************************/
/*/{Protheus.doc} TRANSFERENCIA
	@description API - Movimentacao Interna
	@author Bernard M. Margarido
	@since 10/11/2018
	@version 1.0
	@type class
/*/
/************************************************************************************/
WSRESTFUL TRANSFERENCIA DESCRIPTION " Servico Perfumes Dana - Transferencia Interna."
			
	WSMETHOD POST  DESCRIPTION "Recebe dados para realização da Transferencia Interna Perfumes Dana " WSSYNTAX "/API/TRANSFERENCIA/POST/"
	
END WSRESTFUL

/************************************************************************************/
/*/{Protheus.doc} POST
	@description Metodo POST - Realiza movimentação interna
	@author Bernard M. Margarido
	@since 20/11/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
WSMETHOD POST WSSERVICE TRANSFERENCIA
Local aArea			:= GetArea()

Local _cFilAux		:= cFilAnt

Local oJson			:= Nil
Local oTransf		:= Nil

Private cJsonRet	:= ""
	
Private aMsgErro	:= {}
Private _lGrvJson	:= GetNewPar("DN_GRVJSON",.T.)

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirRaiz)
cArqLog := cDirRaiz + "TRANSFERENCIA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA TRANSFERENCIA DOS PRODUTOS - DATA/HORA: " + dToc( Date() )+ " AS " + Time())

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
	MakeDir("\AutoLog\arquivos\transferencia")
	MemoWrite("\AutoLog\arquivos\transferencia\json_transferencia_" + dTos(Date()) + "_" + StrTran(Time(),":","_")  + ".json",cBody)
EndIf

//-----------------------------------+
// Realiza a deserializacao via HASH |
//-----------------------------------+
oJson 	:= xFromJson(cBody)

//------------------------+
// Posiciona Filial atual |
//------------------------+
cFilAnt	:= RTrim(oJson[#"filial"])

//-------------------------------------+
// Array Produtos a serem transferidos |
//-------------------------------------+
oTransf	:= oJson[#"transferencia"]

//---------------------------------------------+
// Inicia a Gravacao / Atualização dos Pedidos |
//---------------------------------------------+
LogExec("INICIO TRANSFERNCIA INTERNA " + dToc( Date() ) + " " + Time() )
DnaApi09A(oTransf)
LogExec("FIM TRANSFERNCIA INTERNA " + dToc( Date() ) + " " + Time() )

//----------------------+
// Cria JSON de Retorno |
//----------------------+	
If Len(aMsgErro) > 0
	DnaApi09E(aMsgErro,@cJsonRet)
EndIf
	
//----------------+
// Retorno da API |
//----------------+
::SetResponse(cJsonRet)
HTTPSetStatus(200,"OK")

//-------------------------+
// Restaura a filial atual |
//-------------------------+
cFilAnt := _cFilAux

LogExec("FINALIZA TRANSFERENCIA DOS PRODUTOS  - DATA/HORA: " + dToc( Date() )+ " AS " + Time())
LogExec(Replicate("-",80))
ConOut("")

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} DnaApi09A
	@description Rotina realiza a movimentação interna
	@author Bernard M. Margarido
	@since 26/11/2018
	@version 1.0
	@param oTransf, object, descricao
	@type function
/*/
/************************************************************************************/
Static Function DnaApi09A(oTransf)
Local aArea			:= GetArea()
Local aAuto			:= {}
Local aItem			:= {}

Local cMsgErro 		:= ""
Local cLiArq	 	:= ""
Local cSD3Log		:= ""
Local cDocumento	:= GetSxeNum( "SD3","D3_DOC", 1 )

Local dDtaValid		:= ""

Local nI			:= 0
Local nHndImp	 	:= 0

Local lRet			:= .T.
Local _lLote		:= .F.
Local _lContinua	:= .F.

aAdd( aAuto, { cDocumento, dDataBase } )

//-------------------+
// Posiciona Armazem |
//-------------------+
dbSelectArea( "SB2" )
SB2->( dbSetOrder( 1 ) )

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//----------------+
// Posiciona Lote | 
//----------------+
dbSelectArea("SB8")
SB8->( dbSetOrder(3) )

For nI := 1 To Len( oTransf )
			
	//--------------------+
	// Ajusta campos JSON |
	//--------------------+
	_cCodProd 	:= PadR(oTransf[nI][#"produto"],nTProd)
	_cLote		:= PadR(oTransf[nI][#"lote"],nTLote)
	_cArmzOrig	:= PadR(oTransf[nI][#"armazem_origem"],nTLocal)
	_cArmzDest	:= PadR(oTransf[nI][#"armazem_destino"],nTLocal)
	_nQtdTransf	:= oTransf[nI][#"quantidade"]
	_lLote		:= .F.
	
	LogExec("TRANSFERINDO PRODUTO " + RTrim(_cCodProd) + " ORIGEM " + _cArmzOrig + " DESTINO " + _cArmzDest + " .")
	
	//---------------------------------------------------+
	// Valida se armazem de origem existe para o produto |
	//---------------------------------------------------+
	If !SB2->( dbSeek( xFilial( "SB2" ) + _cCodProd + _cArmzOrig ) )
		LogExec(" PRODUTO " + _cCodProd + " NÃO PERTENCE AO ARMAZEM " + _cArmzOrig + " DE ORIGEM. FAVOR VALIDAR O ARMAZEM CORRETO.")
		aAdd(aMsgErro,{cDocumento,.F.,"PRODUTO " + _cCodProd + " NAO LOCALIZADO." })
		Loop
	EndIf
	
	//-------------------------------------+
	// Valida se existe armazem de Destino |
	//-------------------------------------+
	If !SB2->( dbSeek( xFilial( "SB2" ) + _cCodProd + _cArmzDest ) )
		LogExec(" CRIADO ARMAZEM " + _cArmzDest + " PARA O PRODUTO " + _cCodProd + " .")
		CriaSB2( _cCodProd, _cArmzDest )
	EndIf
	
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	If !SB1->( dbSeek(xFilial("SB1") + _cCodProd ) )
		LogExec("PRODUTO " + _cCodProd + " NAO LOCALIZADO.")
		aAdd(aMsgErro,{cDocumento,.F.,"PRODUTO " + _cCodProd + " NAO LOCALIZADO." })
		Loop
	EndIf
	
	//----------------+
	// Posiciona Lote |
	//----------------+
	If SB1->B1_RASTRO == "L"
		_lLote := .T.
		If SB8->( dbSeek(xFilial("SB8") + _cCodProd + _cArmzOrig + _cLote) )
			dDtaValid := SB8->B8_DTVALID	
		Else
			dDtaValid := dDataBase
		EndIf
	Else
		dDtaValid := Date()
	EndIf	
	
	//-----------------------+
	// Limpa a cada iteração |
	//-----------------------+
	aItem := {} 

	aAdd( aItem, _cCodProd			) 	// 01. Codigo Produto 
	aAdd( aItem, SB1->B1_DESC		) 	// 02. Desrição Produto 
	aAdd( aItem, SB1->B1_UM			)	// 03. Unidade Medida 
	aAdd( aItem, _cArmzOrig			) 	// 04. Armazem de Origem
	aAdd( aItem, ""					)	// 05. Localização  
	aAdd( aItem, _cCodProd			) 	// 06. Codigo do Produto	
	aAdd( aItem, SB1->B1_DESC		)  	// 07. Descrição do Produto
	aAdd( aItem, SB1->B1_UM			) 	// 08. Unidade de Medida
	aAdd( aItem, _cArmzDest			)	// 09. Armazem de Destino
	aAdd( aItem, ""					) 	// 10. Endereco de Destino 
	aAdd( aItem, ""					)	// 11. Numero de Serie
	aAdd( aItem, _cLote				)	// 12. Lote
	aAdd( aItem, ""					)	// 13. SubLote
	aAdd( aItem, dDtaValid      	) 	// 14. Data de Validade Lote
	aAdd( aItem, 0					) 	// 15. Potencia do Lote
	aAdd( aItem, _nQtdTransf		) 	// 16. Quantidade Transferida
	aAdd( aItem, 0					) 	// 17. Quantidade Segunda Unidade de Medida
	aAdd( aItem, ""					) 	// 18. Estorno
	aAdd( aItem, ""					) 	// 19. Numero Sequencia Documento
	aAdd( aItem, ""					) 	// 20. Lote Destino 
	aAdd( aItem, dDtaValid			) 	// 21. Data de Validade do Lote Destino 
	aAdd( aItem, ""					) 	// 22. Item Grade
	aAdd( aItem, ""					) 	// 23. ID DCF
	aAdd( aItem, ""					) 	// 24. Observacao
	
	aAdd( aAuto, aItem )
	
	_lContinua 	:= .T.
	
Next nI

lMsErroAuto := .F.

If _lContinua

	MSExecAuto( { |x,y| MATA261( x,y ) }, aAuto, 3 )
	
	If lMsErroAuto
		RollBackSXE()
		
		MakeDir("\erros\")
		cSD3Log := "DNAPI09" + RTrim(cDocumento) + "_" + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".LOG"
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
		
		LogExec(" ERRO DE TRANSFERENCIA " + cDocumento + " .")
		aAdd(aMsgErro,{cDocumento,.F.,"ERRO DE TRANSFERENCIA " + CRLF + cMsgErro  })
		
	Else
		lRet := .T.
		ConfirmSX8()
		LogExec("TRANSFERENCIA REALIZADA COM SUCESSO.")
		aAdd(aMsgErro,{cDocumento,.T.,"TRANSFERENCIA REALIZADA COM SUCESSO."  })
	EndIf
	
EndIf
RestArea( aArea )
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} DnaApi09E
	@description Monta JSON de retorno 
	@author Bernard M. Margarido
	@since 26/11/2018
	@version 1.0
	@type function
/*/
/*************************************************************************************/
Static Function DnaApi09E(aMsgErro,cJsonRet)
Local oJsonRet	:= Nil
Local oTransf	:= Nil

Local nMsg		:= 0

oJsonRet							:= Array(#)
oJsonRet[#"transferencia"]			:= {}
	
For nMsg := 1 To Len(aMsgErro)
	aAdd(oJsonRet[#"transferencia"],Array(#))
	oTransf := aTail(oJsonRet[#"transferencia"])
	oTransf[#"documento"]	:= aMsgErro[nMsg][1]
	oTransf[#"status"]		:= aMsgErro[nMsg][2]
	oTransf[#"msg"]			:= aMsgErro[nMsg][3]
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
	@type function
/*/
/*************************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.