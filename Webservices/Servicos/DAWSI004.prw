#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

//--------------------+
// Variaveis staticas |
//--------------------+
Static nTCnpj	:= TamSx3("A1_CGC")[1]
Static nTVend	:= TamSx3("A3_COD")[1]
Static nTProd	:= TamSx3("B1_COD")[1]
Static nTItem	:= TamSx3("C6_ITEM")[1]
Static nTPedido	:= TamSx3("C5_NUM")[1]

WSSTRUCT STRGRVPED

	WSDATA WS_CPFCNPJ 	AS STRING
	WSDATA WS_IDPED	  	AS STRING
	WSDATA WS_VENDEDOR	AS STRING
	WSDATA WS_OBSPED  	AS STRING
	WSDATA WS_DESCDUPLI	AS FLOAT
	WSDATA WS_NUMCLI	AS STRING
	WSDATA WS_NUMRCL	AS STRING
	WSDATA WS_DTENTREG	AS DATE
	WSDATA WS_DTBALANCO	AS DATE
	WSDATA WS_CLASSPV	AS STRING
	WSDATA WS_DIASHRS	AS STRING
	WSDATA WS_MOTBONIF	AS STRING
	WSDATA WS_ITEMS		AS ARRAY OF STRITEMS
	
ENDWSSTRUCT

WSSTRUCT STRITEMS
	WSDATA WS_CODPROD 		AS STRING
	WSDATA WS_QUANTIDADE	AS INTEGER
	WSDATA WS_PRECOUNIT		AS FLOAT
ENDWSSTRUCT

WSSTRUCT STRGRVPVRET
	
	WSDATA WS_RETURN AS STRING
	WSDATA WS_DESRET AS STRING
	WSDATA WS_NUMPED AS STRING
	
ENDWSSTRUCT

WSSTRUCT STRCONPVRET
	WSDATA WS_STATUS 	AS STRING
	WSDATA WS_NUMERO 	AS STRING
	WSDATA WS_CLIENTE	AS STRING
	WSDATA WS_RAZAO		AS STRING
	WSDATA WS_CONDPGTO	AS STRING
	WSDATA WS_TPFRETE	AS STRING
	WSDATA WS_VLRFRETE	AS FLOAT
	WSDATA WS_VENDEDOR	AS STRING
	WSDATA WS_NOMEVEND	AS STRING
	WSDATA WS_ITEMS		AS ARRAY OF STRCONITEMS
	WSDATA WS_VALORLIQ	AS FLOAT
	WSDATA WS_VALORBRUT AS FLOAT
ENDWSSTRUCT

WSSTRUCT STRCONITEMS
	WSDATA WS_ITEM 			AS STRING
	WSDATA WS_PRODUTO		AS STRING
	WSDATA WS_DESCPROD		AS STRING
	WSDATA WS_QUANTIDADE	AS INTEGER
	WSDATA WS_PRCVENDA		AS FLOAT
	WSDATA WS_PRCTOTAL		AS FLOAT
	WSDATA WS_ALIQICM		AS FLOAT
	WSDATA WS_VALICM		AS FLOAT
	WSDATA WS_ALIQIPI		AS FLOAT
	WSDATA WS_VALIPI		AS FLOAT
ENDWSSTRUCT

/***********************************************************************************/
/*/{Protheus.doc} DAWSI004

@description Webservices - Pedidos 

@author Bernard M. Margarido

@since 30/08/2017
@version undefined

@type class
/*/
/***********************************************************************************/
WSSERVICE DAWSI004 DESCRIPTION "Servico renune metodos especificos Extranet - Dana."
	
	//---------------------+
	// Estruturas de Envio |
	//---------------------+
	WSDATA WS_PEDIDO AS STRGRVPED
	
	//-----------------------+
	// Estruturas de Retorno |
	//-----------------------+
	WSDATA WS_RETPED 	AS STRGRVPVRET
	WSDATA WS_RETCONPED AS STRCONPVRET
	
	//---------------------+
	// Parametros de Envio |
	//---------------------+
	WSDATA WS_NUMPED AS STRING 
	 					
	//------------------------+
	// Metodo Insere Usuarios |
	//------------------------+	
	WSMETHOD WSGRVPEDIDO 	DESCRIPTION "Metodo realiza a gravação/atualização de pedidos de venda - Dana."
	WSMETHOD WSRETPEDIDO 	DESCRIPTION "Metodo retorna dados do pedido de venda - Dana."
	//WSMETHOD WSRETPOSFIN	DESCRIPTION "Metodo retorna posicao financeira do cliente - Dana."
	
ENDWSSERVICE

/***********************************************************************************/
/*/{Protheus.doc} WSGRVPEDIDO

@description Metodo - Realiza a gravação/atualização de pedido de venda

@author Bernard M. Margarido
@since 30/08/2017
@version undefined

@type function
/*/
/***********************************************************************************/
WSMETHOD WSGRVPEDIDO WSRECEIVE WS_PEDIDO WSSEND WS_RETPED WSSERVICE DAWSI004
Local aArea			:= GetArea()

Local cNumPed		:= ""
Local cNatPv		:= ""
Local cMensPv		:= ""

Local nItem			:= 0
Local nQtdCaixa		:= 0
Local nPosTag		:= 0

Local lContinua		:= .T.
Local lRet			:= .T.

Local aCabec		:= {}
Local aItem			:= {}
Local aItems		:= {}

Private lMsErroAuto := {}

//----------------+
// Valida Cliente |
//----------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(3) )
If !SA1->( dbSeek(xFilial("SA1") + PadR(::WS_PEDIDO:WS_CPFCNPJ,nTCnpj) ) )
	::WS_RETPED:WS_RETURN := "1"
	::WS_RETPED:WS_DESRET := "CLIENTE " + ::WS_PEDIDO:WS_CPFCNPJ  + " NAO LOCALIZADO."
	::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
	RestArea(aArea)
	Return .T.
EndIf

//----------------------------------+
// Valida se cliente esta bloqueado |
//----------------------------------+
If SA1->A1_MSBLQL == "1"
	::WS_RETPED:WS_RETURN := "1"
	::WS_RETPED:WS_DESRET := "CLIENTE " + Alltrim(SA1->A1_NOME)  + " BLOQUEADO."
	::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
	RestArea(aArea)
	Return .T.
EndIf

//--------------------------------+
// Valida se cliente esta inativo |
//--------------------------------+
If SA1->A1_ATIVO == "N"
	::WS_RETPED:WS_RETURN := "1"
	::WS_RETPED:WS_DESRET := "CLIENTE " + Alltrim(SA1->A1_NOME)  + " INATIVO."
	::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
	RestArea(aArea)
	Return .T.
EndIf

//--------------------------------+
// Valida se cliente esta inativo |
//--------------------------------+
If Empty(SA1->A1_COND)
	::WS_RETPED:WS_RETURN := "1"
	::WS_RETPED:WS_DESRET := "CLIENTE " + Alltrim(SA1->A1_NOME)  + " SEM CONDICAO DE PAGAMENTO."
	::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
	RestArea(aArea)
	Return .T.
EndIf

//-----------------+
// Valida vendedor |
//-----------------+
dbSelectArea("SA3")
SA3->( dbSetOrder(1) )
If !SA3->( dbSeek(xFilial("SA3") + Padr(::WS_PEDIDO:WS_VENDEDOR,nTVend)) )
	::WS_RETPED:WS_RETURN := "1"
	::WS_RETPED:WS_DESRET := "VENDEDOR " + ::WS_PEDIDO:WS_VENDEDOR + " NAO LOCALIZADO."
	::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
	RestArea(aArea)
	Return .T.
EndIf

//------------------------------------+
// Valida se pedido já foi cadastrado |
//------------------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
If SC5->( dbSeek(xFilial("SC5") + ::WS_PEDIDO:WS_IDPED) )
	::WS_RETPED:WS_RETURN := "1"
	::WS_RETPED:WS_DESRET := "PEDIDO JA CADASTRADO."
	::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
	RestArea(aArea)
	Return .T.
EndIf

//-----------------------------+
// Proxima numeração do Pedido |
//-----------------------------+
cNumPed	:= GetSxeNum("SC5","C5_NUM")
While SC5->( dbSeek(xFilial("SC5") + cNumPed)  )
	ConfirmSx8()
	cNumPed	:= GetSxeNum("SC5","C5_NUM")
EndDo

//-----------------------------+
// Prepara cabeçalho do Pedido |
//-----------------------------+
aAdd(aCabec,{"C5_FILIAL"	, xFilial("SC5")										, Nil	})
aAdd(aCabec,{"C5_NUM"		, cNumPed												, Nil	})
aAdd(aCabec,{"C5_TIPO"		, "N"													, Nil	})
aAdd(aCabec,{"C5_CLIENTE"	, SA1->A1_COD				   							, Nil	})
aAdd(aCabec,{"C5_LOJACLI"	, SA1->A1_LOJA											, Nil	})
aAdd(aCabec,{"C5_EMISSAO"	, Date()						   						, Nil	})
aAdd(aCabec,{"C5_DESCFI"	, Round(::WS_PEDIDO:WS_DESCDUPLI,2)						, Nil	})
aAdd(aCabec,{"C5_DESADFI"	, Round(::WS_PEDIDO:WS_DESCDUPLI,2)						, Nil	})
aAdd(aCabec,{"C5_DATA"		, Date()												, Nil	})	
aAdd(aCabec,{"C5_HORA"		, Left(Time(),5)										, Nil	}) 
aAdd(aCabec,{"C5_UFCLI"		, SA1->A1_EST											, Nil	}) 
aAdd(aCabec,{"C5_TABELA" 	, ""	 	   											, Nil 	})

//--------------------------------+
// Retorna a Natureza de Operação |
//--------------------------------+
cNatPv := DaWsI04Nat(::WS_PEDIDO:WS_CLASSPV)

//-------------------------------------+
// Para grupo de tributação especifico |
//-------------------------------------+
If AllTrim(SA1->A1_GRPVEN) == "002" 
	cNatPv	:= "CE" 
	cCodNat	:= "CE"
Endif   	 	

If !Empty(cNatPv) 
	aAdd(aCabec,{"C5_NATNOTA"	, cNatPv											, Nil	}) 
EndIf

//--------------------+
// Mensagem para nota |
//--------------------+
cMensPv := ::WS_PEDIDO:WS_IDPED + " " + Alltrim(::WS_PEDIDO:WS_OBSPED)
	
aAdd(aCabec,{"C5_MENNOTA"	, cMensPv									    	, Nil	})
aAdd(aCabec,{"C5_VEND1"		, Padr(::WS_PEDIDO:WS_VENDEDOR,nTVend)				, Nil	})	
aAdd(aCabec,{"C5_CONDPAG"	, SA1->A1_COND             	   						, Nil	}) 
aAdd(aCabec,{"C5_TIPLIB"  	, "1"  												, Nil 	})	
aAdd(aCabec,{"C5_XNUMCLI"	, ::WS_PEDIDO:WS_NUMCLI								, Nil	})
aAdd(aCabec,{"C5_XNUMRLC"	, ::WS_PEDIDO:WS_NUMRCL								, Nil	})
aAdd(aCabec,{"C5_ENTREG" 	, ::WS_PEDIDO:WS_DTENTREG							, Nil	})
aAdd(aCabec,{"C5_DTABAL"	, ::WS_PEDIDO:WS_DTBALANCO							, Nil	})
aAdd(aCabec,{"C5_XTIPO"  	, ::WS_PEDIDO:WS_CLASSPV							, Nil	})
aAdd(aCabec,{"C5_XDHRENT"	, ::WS_PEDIDO:WS_DIASHRS							, Nil	})	
aAdd(aCabec,{"C5_REGIONA"	, SA3->A3_REGIONA									, Nil	})	
aAdd(aCabec,{"C5_AREA"		, SA3->A3_AREA										, Nil	})	
aAdd(aCabec,{"C5_TERRITO"	, SA3->A3_TERRITO									, Nil	})	
aAdd(aCabec,{"C5_XMOTBON"	, ::WS_PEDIDO:WS_MOTBONIF							, Nil	})	

//--------------------+
// Posiciona Produtos |
//--------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//---------------+
// Posiciona TES |
//---------------+
dbSelectArea("SZH")
SZH->( dbSetOrder(1) )

//--------------+
// Valida Itens |
//--------------+
If ValType(::WS_PEDIDO:WS_ITEMS) == "A"

	For nItem := 1 To Len(::WS_PEDIDO:WS_ITEMS)
		
		//-----------------------+
		// Reseta Array de Itens |
		//-----------------------+
		aItem	:= {}
			
		If !SB1->( dbSeek(xFilial("SB1") + PadR(::WS_PEDIDO:WS_ITEMS[nItem]:WS_CODPROD,nTProd) ) )
			::WS_RETPED:WS_RETURN := "1"
			::WS_RETPED:WS_DESRET := "PRODUTO " + ::WS_PEDIDO:WS_ITEMS[nItem]:WS_CODPROD + " NAO LOCALIZADO."
			::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
			lContinua			  := .F.	
			Exit
		EndIf
		
		//------------------+
		// Quantidade Caixa |
		//------------------+
		nQtdCaixa := ::WS_PEDIDO:WS_ITEMS[nItem]:WS_QUANTIDADE * SB1->B1_QTDPCXA
		If nQtdCaixa - Int(nQtdCaixa) <> 0 
			::WS_RETPED:WS_RETURN := "1"
			::WS_RETPED:WS_DESRET := "QUANTIDADE " + Alltrim(Str(::WS_PEDIDO:WS_ITEMS[nItem]:WS_QUANTIDADE)) + " INFORMADA NAO E VALIDA PARA ESSE PRODUTO ."
			::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
			lContinua			  := .F.	
			Exit
		EndIf	  
		
		//--------------------+
		// Calcula Valor Item |
		//--------------------+
		nVlrItem := nQtdCaixa * ::WS_PEDIDO:WS_ITEMS[nItem]:WS_PRECOUNIT
		
		::WS_PEDIDO:WS_ITEMS[nItem]:WS_CODPROD
		::WS_PEDIDO:WS_ITEMS[nItem]:WS_QUANTIDADE
		::WS_PEDIDO:WS_ITEMS[nItem]:WS_PRECOUNIT
		
		aAdd(aItem,{"C6_FILIAL"		, xFilial("SC6")		   										, Nil	})
		aAdd(aItem,{"C6_ITEM"		, StrZero(nItem,nTItem)											, Nil	})
		aAdd(aItem,{"C6_PRODUTO"	, PadR(::WS_PEDIDO:WS_ITEMS[nItem]:WS_CODPROD,nTProd)			, Nil	}) 
		aAdd(aItem,{"C6_PRUNIT"		, ::WS_PEDIDO:WS_ITEMS[nItem]:WS_PRECOUNIT 						, Nil	})
		aAdd(aItem,{"C6_PRCVEN"		, ::WS_PEDIDO:WS_ITEMS[nItem]:WS_PRECOUNIT						, Nil	})
		aAdd(aItem,{"C6_QTDVEN"		, nQtdCaixa		   												, Nil	}) 
 		aAdd(aItem,{"C6_LOCAL"   	, SB1->B1_LOCPAD												, Nil	})  
 		
 		//-------------------------------+
 		// Busca Natureza da Nota Fiscal |
 		//-------------------------------+
		cNatNota := U_SchNatNota(xFilial("SC6"),cNatPv,PadR(::WS_PEDIDO:WS_ITEMS[nItem]:WS_CODPROD,nTProd),SA1->A1_COD,SA1->A1_LOJA,'S')
		cCodNat := SubStr(cNatNota,1,2)
		cAlqEsp := SubStr(cNatNota,3,2)
		
		//---------------+
		// Posiciona TES | 
		//---------------+		
		SZH->( dbSeek(xFilial("SZH") + cCodNat) )	
		If cAlqEsp == '25'	     	 	 	
  			cTes := SZH->ZH_TES25
  		ElseIf cAlqEsp == '18'
  	   		cTes := SZH->ZH_TES18
  		Else
   	 		cTes := SZH->ZH_TES
   	 	EndIf
   	 	
   	 	//----------------------------+
   	 	// Valida grupo de tributação |
   	 	//----------------------------+
   	 	If AllTrim(SA1->A1_GRPVEN) == "002" 
   	 		If Alltrim(SB1->B1_GRTRIB) == "100"
   	 			cTes := "515"
			Else
				cTes := "615"
			Endif
		Endif                   
		
		//-----------------------------+
		// Valida Estados e Municipios |
		//-----------------------------+
	 	If SA1->A1_COD_MUN $ '02603' .And. Alltrim(SB1->B1_GRTRIB) == "100"
	 		cTes := "509"
 		Else
 			If SA1->A1_COD_MUN $ '00106/00203/00252/00104/00600' .And. Alltrim(SB1->B1_GRTRIB) == "100"
 				cTes := "509"
 			Else
 				If SA1->A1_COD_MUN $ '00303/00600' .And. Alltrim(SB1->B1_GRTRIB) == "100"
 					cTes := "510"			
 				Else
					If SA1->A1_EST $ 'AC/AP/AM/RO/RR' .And. Alltrim(SB1->B1_GRTRIB) == "100"
						cTes := "513"			
 				    Endif	
 				EndIf
			EndIf
		EndIf		
 	    
 	    //-----------------------------------------+
 	    // Valida se foi econtrada TES inteligente |
 	    //-----------------------------------------+
 	    If Empty(cTes)
 	    	::WS_RETPED:WS_RETURN := "1"
			::WS_RETPED:WS_DESRET := "TES VAZIA, VERIFICAR CADASTRO ( TABELA SZH )"
			::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
			lContinua			  := .F.	
			Exit
		EndIf
 	    
 	    //------------+
 	    // Valida TES |
 	    //------------+
 	    If !SF4->( dbSeek(xFilial("SF4") + cTes) )
 	    	::WS_RETPED:WS_RETURN := "1"
			::WS_RETPED:WS_DESRET := "TES " + cTes + " NAO LOCALIZADA."
			::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
			lContinua			  := .F.	
			Exit
 	    EndIf
 	    
 	    //------------------------------+ 	    
 	    // Valida se TES esta bloqueada |
 	    //------------------------------+
 	    If SF4->F4_MSBLQL
 	    	::WS_RETPED:WS_RETURN := "1"
			::WS_RETPED:WS_DESRET := "TES " + cTes + " BLOQUEADA."
			::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
			lContinua			  := .F.	
			Exit
 	    EndIf
 	    	
		If Empty(cCodNat)
			::WS_RETPED:WS_RETURN := "1"
			::WS_RETPED:WS_DESRET := "NAO FOI POSSIVEL IDENTIFICAR A NATUREZA DO PEDIDO " + Alltrim(::WS_PEDIDO:WS_IDPED) + " ."
			::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
			lContinua			  := .F.	
			Exit
		EndIf
		  
		aAdd(aItem,{"C6_NATNOTA"	, cCodNat									, Nil	})
		
		cSitTrib	:= SF4->F4_SITTRIB
		cOrigem		:= SB1->B1_ORIGEM
		
		If !Empty(cSitTrib)
			aAdd(aItem,{"C6_CLASFIS"	, Alltrim(cOrigem) + Alltrim(cSitTrib)	, Nil	})
		EndIf   
	
		aAdd(aItem,{"C6_TES"	, cTes 											, Nil	})
		
		//------------------------------------+
		// Cria array formatado para ExecAuto |
		//------------------------------------+
		aAdd(aItems,aItem)
		
	Next nItem
	
//--------------------------+
// Apenas um item no pedido | 
//--------------------------+	
Else

	If !SB1->( dbSeek(xFilial("SB1") + PadR(::WS_PEDIDO:WS_ITEMS:WS_CODPROD,nTProd) ) )
		::WS_RETPED:WS_RETURN := "1"
		::WS_RETPED:WS_DESRET := "PRODUTO " + ::WS_PEDIDO:WS_ITEMS:WS_CODPROD + " NAO LOCALIZADO."
		::WS_RETPED:WS_NUMPED := ""
		lContinua			  := .F.	
	EndIf
		
	//------------------+
	// Quantidade Caixa |
	//------------------+
	nQtdCaixa := ::WS_PEDIDO:WS_ITEMS:WS_QUANTIDADE * SB1->B1_QTDPCXA
	If nQtdCaixa - Int(nQtdCaixa) <> 0 
		::WS_RETPED:WS_RETURN := "1"
		::WS_RETPED:WS_DESRET := "QUANTIDADE " +Alltrim(Str(::WS_PEDIDO:WS_ITEMS:WS_QUANTIDADE))+ " INFORMADA NAO E VALIDA PARA ESSE PRODUTO ."
		::WS_RETPED:WS_NUMPED := ""
		lContinua			  := .F.	
	EndIf	  
		
	//--------------------+
	// Calcula Valor Item |
	//--------------------+
	nVlrItem := nQtdCaixa * ::WS_PEDIDO:WS_ITEMS:WS_PRECOUNIT
	
	::WS_PEDIDO:WS_ITEMS:WS_CODPROD
	::WS_PEDIDO:WS_ITEMS:WS_QUANTIDADE
	::WS_PEDIDO:WS_ITEMS:WS_PRECOUNIT
		
	aAdd(aItem,{"C6_FILIAL"		, xFilial("SC6")		   								, Nil	})
	aAdd(aItem,{"C6_ITEM"		, StrZero(nItem,nTItem)									, Nil	})
	aAdd(aItem,{"C6_PRODUTO"	, PadR(::WS_PEDIDO:WS_ITEMS:WS_CODPROD,nTProd)			, Nil	}) 
	aAdd(aItem,{"C6_PRUNIT"		, ::WS_PEDIDO:WS_ITEMS:WS_PRECOUNIT 					, Nil	})
	aAdd(aItem,{"C6_PRCVEN"		, ::WS_PEDIDO:WS_ITEMS:WS_PRECOUNIT						, Nil	})
	aAdd(aItem,{"C6_QTDVEN"		, nQtdCaixa		   										, Nil	})
	aAdd(aItem,{"C6_LOCAL"   	, SB1->B1_LOCPAD										, Nil	})  
 		
	//-------------------------------+
	// Busca Natureza da Nota Fiscal |
	//-------------------------------+
	cNatNota := U_SchNatNota(xFilial("SC6"),cNatPv,PadR(::WS_PEDIDO:WS_ITEMS:WS_CODPROD,nTProd),SA1->A1_COD,SA1->A1_LOJA,'S')
	cCodNat := SubStr(cNatNota,1,2)
	cAlqEsp := SubStr(cNatNota,3,2)
	
	//---------------+
	// Posiciona TES | 
	//---------------+		
	SZH->( dbSeek(xFilial("SZH") + cCodNat) )	
	If cAlqEsp == '25'	     	 	 	
		cTes := SZH->ZH_TES25
	ElseIf cAlqEsp == '18'
   		cTes := SZH->ZH_TES18
	Else
 		cTes := SZH->ZH_TES
 	EndIf
 	
 	//----------------------------+
 	// Valida grupo de tributação |
 	//----------------------------+
 	If AllTrim(SA1->A1_GRPVEN) == "002" 
 		If Alltrim(SB1->B1_GRTRIB) == "100"
 			cTes := "515"
		Else
			cTes := "615"
		Endif
	Endif                   
	
	//-----------------------------+
	// Valida Estados e Municipios |
	//-----------------------------+
 	If SA1->A1_COD_MUN $ '02603' .And. Alltrim(SB1->B1_GRTRIB) == "100"
 		cTes := "509"
	Else
		If SA1->A1_COD_MUN $ '00106/00203/00252/00104/00600' .And. Alltrim(SB1->B1_GRTRIB) == "100"
			cTes := "509"
		Else
			If SA1->A1_COD_MUN $ '00303/00600' .And. Alltrim(SB1->B1_GRTRIB) == "100"
				cTes := "510"			
			Else
				If SA1->A1_EST $ 'AC/AP/AM/RO/RR' .And. Alltrim(SB1->B1_GRTRIB) == "100"
					cTes := "513"			
			    Endif	
			EndIf
		EndIf
	EndIf		
    
    //-----------------------------------------+
    // Valida se foi econtrada TES inteligente |
    //-----------------------------------------+
    If Empty(cTes)
    	::WS_RETPED:WS_RETURN := "1"
		::WS_RETPED:WS_DESRET := "TES VAZIA, VERIFICAR CADASTRO ( TABELA SZH )"
		::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
		lContinua			  := .F.	
	EndIf
    
    //------------+
    // Valida TES |
    //------------+
    If !SF4->( dbSeek(xFilial("SF4") + cTes) )
    	::WS_RETPED:WS_RETURN := "1"
		::WS_RETPED:WS_DESRET := "TES " + cTes + " NAO LOCALIZADA."
		::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
		lContinua			  := .F.	
    EndIf
    
    //------------------------------+ 	    
    // Valida se TES esta bloqueada |
    //------------------------------+
    If SF4->F4_MSBLQL
    	::WS_RETPED:WS_RETURN := "1"
		::WS_RETPED:WS_DESRET := "TES " + cTes + " BLOQUEADA."
		::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
		lContinua			  := .F.	
    EndIf
    	
	If Empty(cCodNat)
		::WS_RETPED:WS_RETURN := "1"
		::WS_RETPED:WS_DESRET := "NAO FOI POSSIVEL IDENTIFICAR A NATUREZA DO PEDIDO " + Alltrim(::WS_PEDIDO:WS_IDPED) + " ."
		::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)
		lContinua			  := .F.	
	EndIf
	  
	aAdd(aItem,{"C6_NATNOTA"	, cCodNat									, Nil	})
	
	cSitTrib	:= SF4->F4_SITTRIB
	cOrigem		:= SB1->B1_ORIGEM
	
	If !Empty(cSitTrib)
		aAdd(aItem,{"C6_CLASFIS"	, Alltrim(cOrigem) + Alltrim(cSitTrib)	, Nil	})
	EndIf   

	aAdd(aItem,{"C6_TES"	, cTes 											, Nil	})
	
	//------------------------------------+
	// Cria array formatado para ExecAuto |
	//------------------------------------+
	aAdd(aItems,aItem)
		
EndIf

//------------------------------+
// Realiza a gravação do pedido |
//------------------------------+
If Len(aItems) > 0 .And. lContinua
	lMsErroAuto	:= .F.
	
	Begin Transaction 
	
		MSExecAuto({|x,y,z| Mata410(x,y,z)}, aCabec, aItems, 3)
		
		If lMsErroAuto
			RollBackSx8()
			MakeDir("/extranet/")
			MakeDir("/extranet/pedidos")
			MakeDir("/extranet/pedidos/erros")
			cArqLog := "SC5" + cNumPed + " " + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2)+".LOG"
			MostraErro("/extranet/pedidos/erros/",cArqLog)
			DisarmTransaction()

			//------------------------------------------------+
			// Adiciona Arquivo de log no Retorno da resposta |
			//------------------------------------------------+
			cMsgErro := ""
			nHndImp  := FT_FUSE("/extranet/pedidos/erros/" + cArqLog)

			If nHndImp >= 1
				Conout("Arquivo Texto de log " + cArqLog)
				
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
					
					cMsgErro += StrTran(cLiArq,"<","+") + CRLF
					FT_FSKIP(1)
				EndDo
				FT_FUSE()
			EndIf                                   
			
			::WS_RETPED:WS_RETURN := "1"
			::WS_RETPED:WS_DESRET := "ERRO AO INCLUIR PEDIDO " + CRLF + cMsgErro + " XXX " + Alltrim(Str(nPosTag))
			::WS_RETPED:WS_NUMPED := Alltrim(::WS_PEDIDO:WS_IDPED)	
			lRet := .F.	
		Else

			ConfirmSx8()
			
			::WS_RETPED:WS_RETURN := "0"
			::WS_RETPED:WS_DESRET := "PEDIDO INCLUIDO COM SUCESSO. "
			::WS_RETPED:WS_NUMPED := cNumPed					
			lRet := .T.
		EndIf
		
	End Transaction 	
	
EndIf

RestArea(aArea)
Return .T.

/***********************************************************************************/
/*/{Protheus.doc} WSRETPEDIDO

@description Retorna consulta do pedido de venda

@author Bernard M. Margarido
@since 11/10/2017
@version undefined

@type function
/*/
/***********************************************************************************/
WSMETHOD WSRETPEDIDO WSRECEIVE WS_NUMPED WSSEND WS_RETCONPED WSSERVICE DAWSI004
Local aArea	:= GetArea()

Local nItem	:= 0

//--------------------------------+
// Valida se foi enontrado pedido |
//--------------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
If !SC5->( dbSeek(xFilial("SC5") + PadR(::WS_NUMPED,nTPedido) ) )
	
	::WS_RETCONPED:WS_STATUS 	:= "0"
	::WS_RETCONPED:WS_NUMERO 	:= ""
	::WS_RETCONPED:WS_CLIENTE	:= ""
	::WS_RETCONPED:WS_RAZAO		:= ""
	::WS_RETCONPED:WS_CONDPGTO	:= ""
	::WS_RETCONPED:WS_TPFRETE	:= ""
	::WS_RETCONPED:WS_VLRFRETE	:= 0
	::WS_RETCONPED:WS_VENDEDOR	:= ""
	::WS_RETCONPED:WS_NOMEVEND	:= ""
	::WS_RETCONPED:WS_VALORLIQ	:= 0
	::WS_RETCONPED:WS_VALORBRUT := 0
	
	aAdd(::WS_RETCONPED:WS_ITEMS,WSClassNew("STRCONITEMS"))
	::WS_RETCONPED:WS_ITEMS[1]:WS_ITEM 			:= ""
	::WS_RETCONPED:WS_ITEMS[1]:WS_PRODUTO		:= ""
	::WS_RETCONPED:WS_ITEMS[1]:WS_DESCPROD		:= ""
	::WS_RETCONPED:WS_ITEMS[1]:WS_QUANTIDADE	:= 0
	::WS_RETCONPED:WS_ITEMS[1]:WS_PRCVENDA		:= 0
	::WS_RETCONPED:WS_ITEMS[1]:WS_PRCTOTAL		:= 0
	::WS_RETCONPED:WS_ITEMS[1]:WS_ALIQICM		:= 0
	::WS_RETCONPED:WS_ITEMS[1]:WS_VALICM		:= 0
	::WS_RETCONPED:WS_ITEMS[1]:WS_ALIQIPI		:= 0
	::WS_RETCONPED:WS_ITEMS[1]:WS_VALIPI		:= 0
		
	RestArea(aArea)
	Return .T.
EndIf

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )

//--------------------+
// Posiciona Vendedor |
//--------------------+
dbSelectArea("SA3")
SA3->( dbSetOrder(1) )
SA3->( dbSeek(xFilial("SA3") + SC5->C5_VEND1) )

//--------------------+
// Posiciona Vendedor |
//--------------------+
dbSelectArea("SE4")
SE4->( dbSetOrder(1) )
SE4->( dbSeek(xFilial("SE4") + SC5->C5_CONDPAG) )

//------------------------------+
// Posiciona Tabela de Produtos |
//------------------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//--------------------------------------------------+
// Caso pedido encontrado inicia as funções fiscais | 
//--------------------------------------------------+
MaFisSave()
MaFisEnd()
MaFisIni(	SC5->C5_CLIENTE	,; 
			SC5->C5_LOJACLI ,; 
			"C"  			,;
			"S"  			,;
			NIL           	,; 
			NIL         	,; 
			NIL  			,; 
			.F. 			,;
			"SB1"         	,; 
			"MATA410"		)


//------------------+
// Status do Pedido | 
//------------------+
If Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)
	::WS_RETCONPED:WS_STATUS 	:= "1"
ElseIf !Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK == "E" .And. Empty(SC5->C5_BLQ)
	::WS_RETCONPED:WS_STATUS 	:= "2"
ElseIf !Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA).And. Empty(SC5->C5_BLQ)
	::WS_RETCONPED:WS_STATUS 	:= "3"
ElseIf SC5->C5_BLQ == "1"
	::WS_RETCONPED:WS_STATUS 	:= "4"                            
ElseIf SC5->C5_BLQ == "2"
	::WS_RETCONPED:WS_STATUS 	:= "5"
EndIf

::WS_RETCONPED:WS_NUMERO 	:= SC5->C5_NUM
::WS_RETCONPED:WS_CLIENTE	:= SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI
::WS_RETCONPED:WS_RAZAO		:= Alltrim(SA1->A1_NOME)
::WS_RETCONPED:WS_CONDPGTO	:= SC5->C5_CONDPAG + " " + Alltrim(SE4->E4_DESCRI)
::WS_RETCONPED:WS_TPFRETE	:= IIF(SC5->C5_TPFRETE == "C","CIF","FOB")
::WS_RETCONPED:WS_VLRFRETE	:= SC5->C5_FRETE
::WS_RETCONPED:WS_VENDEDOR	:= SC5->C5_VEND1 
::WS_RETCONPED:WS_NOMEVEND	:= Alltrim(SA3->A3_NOME)

//---------------------------+
// Posiciona Itens do Pedido |
//---------------------------+ 
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
SC6->( dbSeek(xFilial("SC6") + PadR(::WS_NUMPED,nTPedido)))
While SC6->( !Eof() .And. xFilial("SC6") + PadR(::WS_NUMPED,nTPedido) == SC6->C6_FILIAL + SC6->C6_NUM )
	
	//---------------------------+
	// Incrementa numero do item | 
	//---------------------------+
	nItem++
	
	//-------------------+	
	// Posiciona produto |
	//-------------------+
	SB1->( dbSeek(xFilial("SB1") + SC6->C6_PRODUTO) )
	
	//--------------------------------------------------+
	// Adiciona Itens para realização de calculo fiscal |
	//--------------------------------------------------+
	MaFisAdd( 	SC6->C6_PRODUTO	     				,;                		// Produto
				SC6->C6_TES							,;                		// TES
				SC6->C6_QTDVEN						,;                		// Quantidade
				SC6->C6_PRCVEN						,;                		// Preco unitario
				SC6->C6_VALDESC		  				,;                		// Valor do desconto
				""                     				,;                		// Numero da NF original
				""                     				,;                		// Serie da NF original
				0                      				,;                		// Recno da NF original
				0                      				,;                		// Valor do frete do item
				0                      				,;                		// Valor da despesa do item
				0                      				,;                		// Valor do seguro do item
				0                     				,;                		// Valor do frete autonomo
				( SC6->C6_PRCVEN * SC6->C6_QTDVEN )	,;			  			// Valor da mercadoria
				0)	                                     					// Valor da embalagem
	
	
	aAdd(::WS_RETCONPED:WS_ITEMS,WSClassNew("STRCONITEMS"))
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_ITEM 		:= StrZero(nItem,nTItem)
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_PRODUTO	:= Alltrim(SC6->C6_PRODUTO)
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_DESCPROD	:= Alltrim(SB1->B1_DESC)
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_QUANTIDADE	:= SC6->C6_QTDVEN
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_PRCVENDA	:= SC6->C6_PRCVEN
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_PRCTOTAL	:= SC6->C6_VALOR
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_ALIQICM	:= MafisRet(nItem,"IT_ALIQICM")
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_VALICM		:= MafisRet(nItem,"IT_VALICM")
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_ALIQIPI	:= MafisRet(nItem,"IT_ALIQIPI")
	::WS_RETCONPED:WS_ITEMS[Len(::WS_RETCONPED:WS_ITEMS)]:WS_VALIPI		:= MafisRet(nItem,"IT_VALIPI")
	
	SC6->( dbSkip() )
EndDo

//------------------+
// Totais do Pedido |
//------------------+
::WS_RETCONPED:WS_VALORLIQ	:= MafisRet(,"NF_VALMERC")
::WS_RETCONPED:WS_VALORBRUT := MafisRet(,"NF_TOTAL")
	
RestArea(aArea)
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} DaWsI04Nat

@description Retorna codigo da natureza de operação do pedido de venda

@author Bernard M. Margarido
@since 04/09/2017
@version undefined

@param cClassPv		, characters, descricao

@type function
/*/
/*************************************************************************************/
Static Function DaWsI04Nat(cClassPv)
Local aArea			:= GetArea()

Local cNatSt		:= GetMv("MV_NATST",,"SP")
Local cNatSu		:= GetMv("MV_NATSU",,"RS|MG|PE|SC|PR")
Local cNatZf		:= GetMv("MV_NATZF",,"AM")   
Local cNatNf		:= ""

//-----------------------------+
// Valida Natureza da Operação |
//-----------------------------+
If cClassPv == "PV" 
	If SA1->A1_EST $ cNatSt .Or. ( SA1->A1_EST $ cNatSu .And. SA1->A1_TIPO == 'S' )
		cNatNf	:= "SU"  
	ElseIf ( SA1->A1_EST $ cNatZf .Or. !Empty(SA1->A1_CODMUN) ) .And. SA1->A1_CALCSUF $ "S/I"
		cNatNf := IIf (SA1->A1_EST == 'AP',"ZT","ZF")
	Else              
		cNatNf	:= "VE"
	EndIf
ElseIf cClassPv == "BV" 
	If SA1->A1_EST $ cNatSt .Or. ( SA1->A1_EST $ cNatSu .And. SA1->A1_TIPO == 'S' )
		cNatNf	:= "SV"
	ElseIf ( SA1->A1_EST $ cNatZf .Or. !Empty(SA1->A1_CODMUN) ) .And. SA1->A1_CALCSUF $ "S/I" 
		cNatNf := IIf( SA1->A1_EST == 'AP',"ZB","BZ")
	Else 
		cNatNf	:= "BO"
	EndIf
ElseIf cClassPv == 	"BT" 
	If SA1->A1_EST $ cNatSt .Or. ( SA1->A1_EST $ cNatSu .And. SA1->A1_TIPO == 'S' ) 
		cNatNf	:= "SY" 
	ElseIf ( SA1->A1_EST $ cNatZf .Or. !Empty(SA1->A1_CODMUN)) .And. SA1->A1_CALCSUF $ "S/I"  
		cNatNf := IIf( SA1->A1_EST == 'AP',"ZB","TZ")
	Else
		cNatNf := "BT"
	EndIf
EndIf

RestArea(aArea)
Return cNatNf