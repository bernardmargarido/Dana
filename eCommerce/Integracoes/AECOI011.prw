#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE DESTIN 1
#DEFINE ENDERE 2
#DEFINE NUMERO 3
#DEFINE IBGE   4
#DEFINE ESTADO 5
#DEFINE MUNICI 6
#DEFINE BAIRRO 7
#DEFINE CEP    8
#DEFINE TELEF1 9
#DEFINE TELEF2 10
#DEFINE CELULA 11
#DEFINE REFERE 12
#DEFINE COMPLE 13
#DEFINE IDENDE 14
#DEFINE CONTAT 15

Static cCodInt	:= "011"
Static cDescInt	:= "PEDIDOVENDA"
Static cDirImp	:= "/ecommerce/"

Static nTamCnpj	:= TamSx3("A1_CGC")[1]
Static nTCodCli	:= TamSx3("A1_COD")[1]
Static nTamTel	:= TamSx3("A1_TEL")[1] 
Static nTamInsc	:= TamSx3("A1_INSCR")[1]
Static nTamBco	:= TamSx3("A6_COD")[1]
Static nTamAge	:= TamSx3("A6_AGENCIA")[1]
Static nTamCon	:= TamSx3("A6_NUMCON")[1]
Static nTamProd	:= TamSx3("B1_COD")[1]
Static nTamItem	:= TamSx3("C6_ITEM")[1]
Static nTamNuSe1:= TamSx3("E1_NUM")[1]	
Static nTamNatur:= TamSx3("E1_NATUREZ")[1]
Static nTamTipo	:= TamSx3("E1_TIPO")[1]
Static nTamParc	:= TamSx3("E1_PARCELA")[1]
Static nTamTitu	:= TamSx3("E1_NUM")[1]
Static nTamOrder:= TamSx3("WSA_NUMECO")[1]
Static nTPedCli	:= TamSx3("WSA_NUMECL")[1]
Static nTItemL2	:= TamSx3("WSB_ITEM")[1]
Static nDecIt	:= TamSx3("WSB_VLRITE")[2]
Static nTamStat	:= TamSx3("WS1_DESCVT")[1]
Static nTamOper	:= TamSx3("WS4_CODIGO")[1]


/**************************************************************************************************/

/*/{Protheus.doc} AECOI011

@description	Rotina realiza a integra��o dos pedidos de vendas do e-Commerce

@type   		Function 
@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016
/*/
/**************************************************************************************************/
User Function AECOI011()
	Local aArea		:= GetArea()

	Private cThread	:= Alltrim(Str(ThreadId()))
	Private cStaLog	:= "0"
	Private cArqLog	:= ""	

	Private nQtdInt	:= 0

	Private cHrIni	:= Time()
	Private dDtaInt	:= Date()

	Private aMsgErro:= {}
	Private aOrderId:= {}	

	Private _lJob	:= IIF(Isincallstack("U_ECLOJM03"),.T.,.F.)
			
	//----------------------------------+
	// Grava Log inicio das Integra��es | 
	//----------------------------------+
	u_AEcoGrvLog(cCodInt,cDescInt,dDtaInt,cHrIni,,,,,cThread,1)

	//------------------------------+
	// Inicializa Log de Integracao |
	//------------------------------+
	MakeDir(cDirImp)
	cArqLog := cDirImp + "PEDIDOVENDA" + cEmpAnt + cFilAnt + ".LOG"
	ConOut("")	
	LogExec(Replicate("-",80))
	LogExec("INICIA INTEGRACAO CLIENTES / PEDIDOS ECOMMERCE - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

	//----------------------------+
	// Inicia processo de Pedidos |
	//----------------------------+
	If _lJob
		AECOINT11()
	Else
		Processa({|| AECOINT11() },"Aguarde...","Consultando Pedidos.")
	EndIf	
	
	//-------------------------------+
	// Inicia grava��o / atualiza��o |
	//-------------------------------+
	If Len(aOrderId) > 0 
		If _lJob
			AEcoI11PvC()
		Else
			Processa({|| AEcoI11PvC() },"Aguarde...","Gravando/Atualizando Novos Pedidos.")
		EndIf	
	EndIf
		
	LogExec("FINALIZA INTEGRACAO CLIENTES / PEDIDOS ECOMMERCE - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
	LogExec(Replicate("-",80))
	ConOut("")

	//----------------------------------+
	// Envia e-Mail com o Logs de Erros |
	//----------------------------------+
	If Len(aMsgErro) > 0
		cStaLog := "1"
		u_AEcoMail(cCodInt,cDescInt,aMsgErro)
	EndIf

	//----------------------------------+
	// Grava Log inicio das Integra��es |
	//----------------------------------+
	u_AEcoGrvLog(cCodInt,cDescInt,dDtaInt,cHrIni,Time(),cStaLog,nQtdInt,aMsgErro,cThread,2)
		
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} AECOINT11

@description	Rotina realiza a integra��o dos Pedidos de Venda.

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016
/*/
/**************************************************************************************************/
Static Function AECOINT11()
Local aArea			:= GetArea()
Local aHeadOut  	:= {}

Local cUrl			:= GetNewPar("EC_URLREST")
Local cAppKey		:= GetNewPar("EC_APPKEY")
Local cAppToken		:= GetNewPar("EC_APPTOKE")
Local cXmlHead 	 	:= ""
Local cUrlParms		:= ""     
Local cError    	:= ""
Local cWarning  	:= ""
Local cRetPost  	:= ""

Local nTimeOut		:= 240

Local oRestRet   	:= Nil 

aAdd(aHeadOut,"Content-Type: application/json" )
aAdd(aHeadOut,"X-VTEX-API-AppKey:" + cAppKey )
aAdd(aHeadOut,"X-VTEX-API-AppToken:" + cAppToken ) 

cUrlParms := "ready-for-handling"
//cUrlParms := "canceled,invoiced" //handling,payment-pending,

cHtmlPage := HttpGet(cUrl + "/api/oms/pvt/orders?f_status=" + cUrlParms , /*cUrlParms*/, nTimeOut, aHeadOut, @cXmlHead)

If !_lJob
	ProcRegua(-1)
EndIf	
//--------------------------+
// Valida Status de retorno |
//--------------------------+
If HTTPGetStatus() == 200

	//------------------------------------+
	// Realiza o Parse para a String Rest |
	//------------------------------------+
	If FWJsonDeserialize(cHtmlPage,@oRestRet)
	
		//---------------------------+
		// Valida se retornou Objeto |
		//---------------------------+
		If ValType(oRestRet) == "O" 
		
			//---------------------------------------------+
			// Valida se existe pedidos a serem integrados |
			//---------------------------------------------+
			If ValType(oRestRet:List) == "A" .And. Len(oRestRet:List) > 0
			
				For nList := 1 To Len(oRestRet:List)

					If !_lJob
						IncProc('Validando novos pedidos VTEX')
					EndIf	
					
					LogExec('VALIDANDO NOVOS PEDIDOS VTEX ')

					aAdd(aOrderId,oRestRet:List[nList]:OrderId)
				Next nList
			Else
				If !_lJob
					Aviso('e-Commerce','Nao existem novos pedidos a serem integrados',{"Ok"})	
				EndIf	
				LogExec('NAO EXISTEM NOVOS PEDIDOS A SEREM INTEGRADOS')
			EndIf
		EndIf
	Else
		If !_lJob
			Aviso('e-Commerce','Nao existem novos pedidos a serem integrados',{"Ok"})	
		EndIf	
		LogExec('NAO EXISTEM NOVOS PEDIDOS A SEREM INTEGRADOS')
	EndIf
Else
	If !_lJob
		Aviso('e-Commerce','Nao existem novos pedidos a serem integrados',{"Ok"})	
	EndIf	
	LogExec('NAO EXISTEM NOVOS PEDIDOS A SEREM INTEGRADOS')
EndIf

RestArea(aArea)
Return Nil

/********************************************************************************************/
/*/{Protheus.doc} AEcoI11PvC

@description Atualiza clientes e pedidos

@author Bernard M. Margarido
@since 30/01/2017
@version undefined

@type function
/*/
/********************************************************************************************/
Static Function AEcoI11PvC()
Local aArea			:= GetArea()
Local cUrl			:= GetNewPar("EC_URLREST")
Local cAppKey		:= GetNewPar("EC_APPKEY")
Local cAppToken		:= GetNewPar("EC_APPTOKE")

Local nTimeOut		:= 240

Local aHeadPv	  	:= {}
Local aRet			:= {.T.,"",""}
Local aEndRes		:= {}
Local aEndCob		:= {}
Local aEndEnt		:= {}

Local cXmlRest 	 	:= ""
Local cUrlParms		:= ""     
Local cError    	:= ""
Local cWarning  	:= ""
Local cRetPost  	:= ""

Local oRestPv   	:= Nil 

aAdd(aHeadPv,"Content-Type: application/json" )
aAdd(aHeadPv,"X-VTEX-API-AppKey:" + cAppKey )
aAdd(aHeadPv,"X-VTEX-API-AppToken:" + cAppToken ) 

If !_lJob
	ProcRegua(Len(aOrderId))
EndIf	

For nPed := 1 To Len(aOrderId)
                     
	cHtmlPv := HttpGet(cUrl + "/api/oms/pvt/orders/" + aOrderId[nPed] , /*cUrlParms*/, nTimeOut, aHeadPv, @cXmlRest)

	If !_lJob	
		IncProc(' Processando OrderId ' + aOrderId[nPed] )
	EndIf	

	LogExec(' PROCESSANDO ORDERID ' + aOrderId[nPed] )

	//--------------------------------------------------+
	// Valida se obteve sucesso no retorno da consulta. |
	//--------------------------------------------------+
	If HTTPGetStatus() == 200
	
		//------------------------------------+
		// Realiza o Parse para a String Rest |
		//------------------------------------+
		FWJsonDeserialize(cHtmlPv,@oRestPv)
		
		If ValType(oRestPv) == "O"
			
			//---------------------------------+
			// Grava/Atualiza dados do Cliente |
			//---------------------------------+
			aRet 	:= EcGrvCli(oRestPv:ClientProfileData,oRestPv:ShippingData,@aEndRes,@aEndCob,@aEndEnt)
			
			//-----------------------+
			// Grava Pedido de Venda |
			//-----------------------+ 
			If aRet[1]
				aRet := EcGrvPed(oRestPv,aEndRes,aEndCob,aEndEnt,aOrderId[nPed])
			EndIf        
			
	     	//---------------------------------+
			// Envia a Confirmacao da Reserva  |
			//---------------------------------+	
		    //	If aRet[1]
		    //		u_EcConfRes(aOrderId[nPed])
		    //	EndIf
						            
            If !aRet[1]
				aAdd(aMsgErro,{aRet[2],aRet[3]})            
            EndIf
            
			//-------------+
			// Mata Objeto |
			//-------------+
			If ValType(oRestPv) == "O"
				FreeObj(oRestPv)
			EndIf
													
		Else
			If !_lJob	
				Aviso('e-Commerce','N�o existem novos pedidos a serem integrados',{"Ok"})	
			EndIf
			LogExec('NAO EXISTEM NOVOS PEDIDOS A SEREM INTEGRADOS')	
		EndIf
	Else
		If !_lJob	
			Aviso('e-Commerce','Erro na requisi��o de pedidos ' + Alltrim(HTTPGetStatus()),{"Ok"})	
		EndIf	
		LogExec('ERRO NA REQUISI��O DE PEDIDOS ' + Alltrim(HTTPGetStatus()))	
	EndIf
		
Next nPed

RestArea(aArea)
Return aRet

/************************************************************************************/
/*/{Protheus.doc} EcGrvCli

@description Realiza a grava��o / atualiza��o do cliente

@author Bernard M. Margarido
@since 30/01/2017
@version undefined

@param oDadosCli	, object	, Objeto contendo dados dos cliente
@param oDadosEnd	, object	, Objeto contendo endere�os do cliente
@param aEndRes		, array		, Armazena endere�o residencial
@param aEndCob		, array		, Armazena endere�o de Cobran�a
@param aEndEnt		, array		, Armazena endere�o de Entrega

@type function
/*/
/************************************************************************************/
Static Function EcGrvCli(oDadosCli,oDadosEnd,aEndRes,aEndCob,aEndEnt)
Local aArea		:= GetArea()
Local aRet		:= {.T.,"",""}

Local cCodCli	:= ""
Local cLoja		:= ""
Local cTpPess	:= ""   
Local cTipoCli	:= ""
Local cContrib	:= ""
Local cContato	:= "" 
Local cInscE	:= ""
Local cEnd		:= ""
Local cNumEnd	:= ""
Local cBairro	:= ""
Local cMun		:= ""
Local cCep		:= ""
Local cEst		:= ""
Local cCodMun	:= ""
Local cEndC		:= ""
Local cNumEndC	:= ""
Local cBairroC	:= ""
Local cMunC		:= ""
Local cCepC		:= ""
Local cEstC		:= ""
Local cEndE		:= ""
Local cNumEndE	:= ""
Local cBairroE	:= ""
Local cMunE		:= ""
Local cCepE		:= ""
Local cEstE		:= "" 


Local aCliente  := {} 

Local nOpcA		:= 0

Local lEcCliCpo	:= ExistBlock("ECADDCPO")

Private lMsErroAuto := .F.

//---------------------+
// Cnpj/Cpf do cliente |
//---------------------+    
If oDadosCli:IsCorporate   
	cCnpj 	:= PadR(oDadosCli:CorporateDocument,nTamCnpj)
	cTpPess := "J"
	cTipoCli:= "F"
Else
	cCnpj 	:= PadR(oDadosCli:Document,nTamCnpj) 
	cTpPess := "F"
	cTipoCli:= "F"	  
EndIf	

//----------------------------------------------------------+
// Valida se cliente ja existe na base de dados do Protheus |
//----------------------------------------------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(3) )
If SA1->( dbSeek(xFilial("SA1") + cCnpj ) )
	cCodCli := SA1->A1_COD
	cLoja	:= SA1->A1_LOJA
	nOpcA 	:= 4
	LogExec("INICIA ATUALIZACAO DO CLIENTE " + cCodCli + "-" + cLoja + "-" + Alltrim(SA1->A1_NREDUZ)  )
Else
	cCodCli := GetSxeNum("SA1","A1_COD")
	cLoja	:= "01"
	SA1->( dbSetOrder(1) )
	While SA1->( dbSeek(xFilial("SA1") + PadR(cCodCli,nTCodCli) + cLoja ) )
		ConfirmSx8()
		cCodCli	:= GetSxeNum("SA1","A1_COD","",1)
	EndDo	
	nOpcA := 3
	LogExec("INICIA INCLUSAO DO CLIENTE " + cCodCli + "-" + cLoja  )
EndIf

//--------------------------+
// Dados passados pela Vtex |
//--------------------------+ 
If oDadosCli:IsCorporate
	cNomeCli	:= IIF(nOpcA == 3,	u_SyAcento(DecodeUtf8(oDadosCli:CorporateName),.T.)				, SA1->A1_NOME 		) 
	cNReduz		:= IIF(nOpcA == 3,	u_SyAcento(DecodeUtf8(oDadosCli:TradeName),.T.)					, SA1->A1_NREDUZ	)
	cContato	:= IIF(nOpcA == 3,	u_SyAcento(DecodeUtf8(oDadosCli:FirstName),.T.) + " " + u_SyAcento(DecodeUtf8(oDadosCli:LastName),.T.)	, SA1->A1_CONTATO	)	
	cDdd01		:= IIF(nOpcA == 3,	SubStr(oDadosCli:CorporatePhone,5,2)							, SA1->A1_DDD		)
	cTel01		:= IIF(nOpcA == 3,	StrTran(SubStr(oDadosCli:CorporatePhone,8,nTamTel)," ","")		, SA1->A1_TEL		)
	cInscE		:= IIF(nOpcA == 3,	Upper(oDadosCli:StateInscription)								, SA1->A1_INSCR		)
	cContrib	:= IIF(nOpcA == 3,	IIF(Alltrim(cInscE) == "ISENTO","2","1")						, SA1->A1_CONTRIB	)
Else	
	
	cNomeCli	:= IIF(nOpcA == 3,	u_SyAcento(DecodeUtf8(oDadosCli:FirstName),.T.) + " " + u_SyAcento(DecodeUtf8(oDadosCli:LastName),.T.)	, SA1->A1_NOME 		)
	cNReduz		:= IIF(nOpcA == 3,	u_SyAcento(DecodeUtf8(oDadosCli:FirstName),.T.) + " " + u_SyAcento(DecodeUtf8(oDadosCli:LastName),.T.)	, SA1->A1_NREDUZ	)
	cDdd01		:= IIF(nOpcA == 3,	SubStr(oDadosCli:Phone,4,2)										, SA1->A1_DDD		)
	cTel01		:= IIF(nOpcA == 3,	SubStr(oDadosCli:Phone,6,nTamTel) 								, SA1->A1_TEL		)
	cContrib	:= IIF(nOpcA == 3,	"2"																, SA1->A1_CONTRIB	)
EndIf

cEmail			:= IIF(nOpcA == 3,	Alltrim(oDadosCli:eMail)										, SA1->A1_EMAIL		)

//----------------+
// Dados Endere�o |
//----------------+
aEndRes	:= {}
aEndCob	:= {}
aEndEnt	:= {}
EcRetEnd(oDadosEnd:Address,@aEndRes,@aEndCob,@aEndEnt)

//-----------+
// Enderecos |
//-----------+
If Len(aEndRes) > 0 
	cEnd		:= aEndRes[ENDERE]
	cNumEnd		:= aEndRes[NUMERO]
	cBairro		:= aEndRes[BAIRRO]
	cMun		:= aEndRes[MUNICI]	
	cCep		:= aEndRes[CEP]
	cEst		:= aEndRes[ESTADO]
	cCodMun		:= aEndRes[IBGE]
ElseIf Len(aEndEnt) > 0		
	cEnd		:= aEndEnt[ENDERE]
	cNumEnd		:= aEndEnt[NUMERO]
	cBairro		:= aEndEnt[BAIRRO]
	cMun		:= aEndEnt[MUNICI]	
	cCep		:= aEndEnt[CEP]
	cEst		:= aEndEnt[ESTADO]
	cCodMun		:= aEndEnt[IBGE]
EndIf

//----------------------+
// Endereco de Cobranca | 
//----------------------+
If Len(aEndCob) > 0	
	cEndC		:= aEndCob[ENDERE]
	cNumEndC	:= aEndCob[NUMERO]
	cBairroC	:= aEndCob[BAIRRO]
	cMunC		:= aEndCob[MUNICI]
	cCepC		:= aEndCob[CEP]
	cEstC		:= aEndCob[ESTADO]
ElseIf Len(aEndRes) > 0
	cEndC		:= aEndRes[ENDERE]
	cNumEndC	:= aEndRes[NUMERO]
	cBairroC	:= aEndRes[BAIRRO]
	cMunC		:= aEndRes[MUNICI]
	cCepC		:= aEndRes[CEP]
	cEstC		:= aEndRes[ESTADO]	
EndIf

//---------------------+
// Endereco de Entrega |
//---------------------+
If Len(aEndEnt) > 0		
	cEndE		:= aEndEnt[ENDERE]
	cNumEndE	:= aEndEnt[NUMERO]
	cBairroE	:= aEndEnt[BAIRRO]
	cMunE		:= aEndEnt[MUNICI]
	cCepE		:= aEndEnt[CEP]
	cEstE		:= aEndEnt[ESTADO]
ElseIf Len(aEndRes) > 0
	cEndE		:= aEndRes[ENDERE]
	cNumEndE	:= aEndRes[NUMERO]
	cBairroE	:= aEndRes[BAIRRO]
	cMunE		:= aEndRes[MUNICI]
	cCepE		:= aEndRes[CEP]
	cEstE		:= aEndRes[ESTADO]
EndIf

//--------------------------------------+
// Cria Array para cadastro de clientes |
//--------------------------------------+
aAdd(aCliente ,	{"A1_FILIAL"	,	xFilial("SA1")							,	Nil, Posicione("SX3",2,"A1_FILIAL","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_COD"		,	cCodCli									,	Nil, Posicione("SX3",2,"A1_COD","X3_ORDEM")		})
aAdd(aCliente ,	{"A1_LOJA"		,	cLoja									,	Nil, Posicione("SX3",2,"A1_LOJA","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_PESSOA"	,	cTpPess									,	Nil, Posicione("SX3",2,"A1_PESSOA","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_NOME"		,	cNomeCli								,	Nil, Posicione("SX3",2,"A1_NOME","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_NREDUZ"	,	cNReduz									,	Nil, Posicione("SX3",2,"A1_NREDUZ","X3_ORDEM")	})

If nOpcA == 3
	aAdd(aCliente ,	{"A1_END"		,	cEnd + ", " + cNumEnd					,	Nil, Posicione("SX3",2,"A1_END","X3_ORDEM")		})
	aAdd(aCliente ,	{"A1_EST"		,	cEst									,	Nil, Posicione("SX3",2,"A1_EST","X3_ORDEM")		})
	aAdd(aCliente ,	{"A1_COD_MUN"	,	cCodMun									,	Nil, Posicione("SX3",2,"A1_COD_MUN","X3_ORDEM")	})
	aAdd(aCliente ,	{"A1_MUN"		,	cMun									,	Nil, Posicione("SX3",2,"A1_MUN","X3_ORDEM")		})
	aAdd(aCliente ,	{"A1_BAIRRO"	,	cBairro									,	Nil, Posicione("SX3",2,"A1_BAIRRO","X3_ORDEM")	})
	aAdd(aCliente ,	{"A1_CEP"		,	cCep									,	Nil, Posicione("SX3",2,"A1_CEP","X3_ORDEM")		})
EndIf	

aAdd(aCliente ,	{"A1_ENDCOB"	,	cEndC + ", " + cNumEndC					,	Nil, Posicione("SX3",2,"A1_ENDCOB","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_ESTCOB"	,	cEstC									,	Nil, Posicione("SX3",2,"A1_ESTCOB","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_MUNCOB"	,	cMunC									,	Nil, Posicione("SX3",2,"A1_MUNCOB","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_BAIRROC"	,	cBairroC								,	Nil, Posicione("SX3",2,"A1_BAIRROC","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_CEPCOB"	,	cCepC									,	Nil, Posicione("SX3",2,"A1_CEPCOB","X3_ORDEM")	})  
aAdd(aCliente ,	{"A1_ENDENT"	,	cEndE + ", " + cNumEndE					,	Nil, Posicione("SX3",2,"A1_ENDENT","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_ESTE"		,	cEstE									,	Nil, Posicione("SX3",2,"A1_ESTE","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_MUNE"		,	cMunE									,	Nil, Posicione("SX3",2,"A1_MUNE","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_BAIRROE"	,	cBairroE								,	Nil, Posicione("SX3",2,"A1_BAIRROE","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_CEPE"		,	cCepE									,	Nil, Posicione("SX3",2,"A1_CEPE","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_TIPO"		,	cTipoCli								,	Nil, Posicione("SX3",2,"A1_TIPO","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_DDD"		,	cDdd01									,	Nil, Posicione("SX3",2,"A1_DDD","X3_ORDEM")		})
aAdd(aCliente ,	{"A1_TEL"		,	cTel01									,	Nil, Posicione("SX3",2,"A1_TEL","X3_ORDEM")		})
aAdd(aCliente ,	{"A1_PAIS"		,	"105"									,	Nil, Posicione("SX3",2,"A1_PAIS","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_CGC"		,	cCnpj									,	Nil, Posicione("SX3",2,"A1_CGC","X3_ORDEM")		})
aAdd(aCliente ,	{"A1_EMAIL"		,	cEmail									,	Nil, Posicione("SX3",2,"A1_EMAIL","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_DTNASC"	,	dDataBase								,	Nil, Posicione("SX3",2,"A1_DTNASC","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_CLIENTE"	,	"S"										,	Nil, Posicione("SX3",2,"A1_CLIENTE","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_CONTRIB"	,	cContrib								,	Nil, Posicione("SX3",2,"A1_CONTRIB","X3_ORDEM")	})  
aAdd(aCliente ,	{"A1_CONTATO"	,	cContato								,	Nil, Posicione("SX3",2,"A1_CONTATO","X3_ORDEM")	})  

//---------------------------+
// Valida Inscricao estadual |
//---------------------------+
If oDadosCli:IsCorporate
  	If !IE(cInscE,aEndRes[ESTADO],.F.)
		//---------------------+
		// Variavel de retorno |
		//---------------------+
	 	aRet[1] := .F.
	   	aRet[2] := cCnpj
		aRet[3] := "INSCRICAO ESTADUAL " + cInscE + " INV�LIDA PARA O ESTADO DE " + aEndRes[ESTADO]
		RestArea(aArea)
		Return aRet
	EndIf
EndIf	
	
//-----------------------------------------------+
// Grava Incsri��o estadual para pessoa Juridica |
//-----------------------------------------------+
If oDadosCli:IsCorporate
	aAdd(aCliente ,	{"A1_INSCR"	,	Alltrim(cInscE)										,	"AllWaysTrue()", Posicione("SX3",2,"A1_INSCR","X3_ORDEM")	})
Else
	aAdd(aCliente ,	{"A1_INSCR"	,	Alltrim("ISENTO")									,	"AllWaysTrue()", Posicione("SX3",2,"A1_INSCR","X3_ORDEM")	})
EndIf

//----------------------------------------------+
// Caso pedido de venda seja outros             |
// o cliente ser� criado com risco de credito E |
//----------------------------------------------+
aAdd(aCliente ,	{"A1_RISCO"		,"A"													,	Nil, Posicione("SX3",2,"A1_RISCO","X3_ORDEM")	})
aAdd(aCliente ,	{"A1_CODPAIS"	,"01058"												,	Nil, Posicione("SX3",2,"A1_CODPAIS","X3_ORDEM")	})

//----------------------------------------------------------+
// Ponto de Entrada utilizado para acrescentar novos campos |
//----------------------------------------------------------+
If lEcCliCpo 
	aCliente := ExecBlock("ECADDCPO",.F.,.F.,{oDadosCli,oDadosEnd,aCliente,nOpcA})
EndIf

//--------------------------+
// Ordena pela ordem do SX3 |
//--------------------------+
aCliente := FWVetByDic(aCliente, "SA1")

If Len(aCliente) > 0 
 
	lMsErroAuto := .F.
	
	//-------------------+
	// ExecAuto Cliente. |
	//-------------------+
	MsExecAuto({|x,y| Mata030(x,y)}, aCliente, nOpcA)
	
	LogExec("PROCESSANDO MANUTENCAO DO CLIENTE " + cCodCli + "-" + cLoja  )
	
	//---------------------+
	// Erro na Atualiza��o |
	//---------------------+
	If lMsErroAuto
	
		RollBackSx8()
		MakeDir("\erros\")
		cSA1Log := "SA1" + cCodCli + cLoja + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".LOG"
		MostraErro("\erros\",cSA1Log)
				
		LogExec("ERRO AO " + Iif(nOpcA == 3,"INCLUIR","ALTERAR") + " O CLIENTE " + cCodCli + "-" + cLoja  )					
		LogExec("FAVOR VERIFICAR O ARQUIVO DE LOG " + cSA1Log + " NA PASTA \erros\" )					
		
		//------------------------------------------------+
		// Adiciona Arquivo de log no Retorno da resposta |
		//------------------------------------------------+
		cMsgErro := ""
		cLiArq	 := ""
		nHndImp	 := 0	
		nHndImp  := FT_FUSE("\erros\" + cSA1Log)
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
		aRet[1] := .F.
		aRet[2] := cCnpj 
		aRet[3] := cMsgErro
																						
	Else
		
		//-----------------------------+
		// Reseta variavel da ExecAuto |
		//-----------------------------+
		ConfirmSx8()

		//----------------------------------------+
		// Grava endere�o de entrega nos contatos |
		//----------------------------------------+
		If Len(aEndEnt) > 0 .Or. Len(aEndRes) > 0
			AEc011Cont(cCodCli,cLoja,cNomeCli,IIF(Len(aEndEnt) > 0,aEndEnt,aEndRes))
		Endif

		//--------------------+
		// Desloqueia Cliente |
		//--------------------+
		RecLock("SA1",.F.)
			SA1->A1_MSBLQL := "2"
		SA1->( MsUnLock() )
		
		//---------------------+
		// Variavel de retorno |
		//---------------------+
		aRet[1] := .T.
		aRet[2] := ""
		aRet[3] := ""

		//------------+
		// Msg CoNout |
		//------------+
		LogExec("CLIENTE " + Iif(nOpcA == 3,"INCLUIDO","ALTERADO") + " COM SUCESSO " + cCodCli + "-" + cLoja  )					
		
	EndIf
					
EndIf

LogExec("FIM MANUTENCAO DE CLIENTES" )

Restarea(aArea)
Return aRet

/***************************************************************************************/
/*/{Protheus.doc} EcRetEnd

@description Valida os endere�os cadastrados pelo o cliente

@author Bernard M. Margarido
@since 30/01/2017
@version undefined

@param oDadosEnd		, object	, Objeto contendo endere�o(s) do cliente
@param aEndRes			, array		, Armazena endere�o residencial
@param aEndCob			, array		, Aramzena endere�o de Cobranc�a
@param aEndEnt			, array		, Armazena endere�o de Entrega

@type function
/*/
/***************************************************************************************/
Static Function EcRetEnd(oDadosEnd,aEndRes,aEndCob,aEndEnt)

Local nEnd		:= 0

//-------------------+
// Tipos de Endereco |
// 1 - Residencial   |
// 2 - Entrega       |
// 3 - Cobranca      |
//-------------------+
	
//------------------------+
// Valida tipo  de Objeto |
//------------------------+
If ValType(oDadosEnd) == "O" 
	If SubStr(Upper(oDadosEnd:AddressType),1,3) == "RES"
		aEndRes := EcLoadEnd(oDadosEnd)
	ElseIf SubStr(Upper(oDadosEnd:AddressType),1,3) == "COB"
		aEndEnt := EcLoadEnd(oDadosEnd)
	ElseIf SubStr(Upper(oDadosEnd:AddressType),1,3) == "COM"
		aEndCob := EcLoadEnd(oDadosEnd)
	EndIf	
ElseIf ValType(oDadosEnd) == "A"
	For nEnd := 1 To Len(oDadosEnd)
		If SubStr(Upper(oDadosEnd[nEnd]:AddressType),1,3) == "RES"
			aEndRes := EcLoadEnd(oDadosEnd[nEnd])
		ElseIf SubStr(Upper(oDadosEnd[nEnd]:AddressType),1,3) == "COB"
			aEndEnt := EcLoadEnd(oDadosEnd[nEnd])
		ElseIf SubStr(Upper(oDadosEnd[nEnd]:AddressType),1,3) == "COM"
			aEndCob := EcLoadEnd(oDadosEnd[nEnd])
		EndIf
	Next nEnd
EndIf

Return .T.

/****************************************************************************/
/*/{Protheus.doc} EcLoadEnd

@description Carrega os enderecos cadastrados

@author Bernard M. Margarido
@since 30/01/2017
@version undefined

@param oEndereco	, object	, Objeto contendo endere�os do cliente

@type function
/*/
/****************************************************************************/
Static Function EcLoadEnd(oEndereco)
Local aRet			:= {}
Local cMunicipio	:= ""
Local cEstado		:= ""
Local cComplem		:= ""
Local cPais			:= ""
Local cBairro		:= ""
Local cNumero		:= ""
Local cCep			:= ""
Local cDesti		:= ""
Local cReferen		:= ""
Local cEnd			:= ""
Local cIdEnd		:= ""

//------------------------------------+
// Acerta endere�o no padrao protheus |
//------------------------------------+
cMunicipio	:= IIF(ValType(oEndereco:City) <> "U", u_SyAcento(DecodeUtf8(oEndereco:City),.T.), "")
cEstado		:= IIF(ValType(oEndereco:State) <> "U", Upper(oEndereco:State), "")
cComplem	:= IIF(ValType(oEndereco:Complement) <> "U", u_SyAcento(DecodeUtf8(oEndereco:Complement),.T.), "")
cPais		:= IIF(ValType(oEndereco:Country) <> "U", oEndereco:Country, "")
cBairro		:= IIF(ValType(oEndereco:NeighBorhood) <> "U", u_SyAcento(DecodeUtf8(oEndereco:NeighBorhood),.T.), "")
cNumero		:= IIF(ValType(oEndereco:Number) <> "U", oEndereco:Number, "")
cCep		:= IIF(ValType(oEndereco:PostalCode) <> "U", u_SyFormat(oEndereco:PostalCode,"A1_CEP",.T.), "")
cDesti		:= IIF(ValType(oEndereco:ReceiverName) <> "U", u_SyAcento(DecodeUtf8(oEndereco:ReceiverName),.T.), "")
cReferen	:= IIF(ValType(oEndereco:Reference) <> "U", u_SyAcento(DecodeUtf8(oEndereco:Reference),.T.), "")
cEnd		:= IIF(ValType(oEndereco:Street) <> "U", u_SyAcento(DecodeUtf8(oEndereco:Street),.T.), "")
cIdEnd		:= IIF(ValType(oEndereco:addressId) <> "U", oEndereco:addressId, "")
cContato	:= IIF(ValType(oEndereco:receiverName) <> "U", u_SyAcento(DecodeUtf8(oEndereco:receiverName),.T.), "")

aRet 		:= Array(15) 

cIbge		:= EcCodMun(cEstado,cMunicipio) 
		
aRet[DESTIN]	:= cDesti
aRet[ENDERE]	:= cEnd 
aRet[NUMERO]	:= cNumero
aRet[IBGE]		:= cIbge
aRet[ESTADO]	:= cEstado
aRet[MUNICI]	:= cMunicipio
aRet[BAIRRO]	:= cBairro
aRet[CEP]		:= cCep
aRet[TELEF1]	:= ""
aRet[TELEF2]	:= ""
aRet[CELULA]	:= ""
aRet[REFERE]	:= cReferen
aRet[COMPLE]	:= cComplem
aRet[IDENDE]	:= cIdEnd
aRet[CONTAT]	:= cContato

Return aRet

/***********************************************************************************/
/*/{Protheus.doc} EcCodMun

@description Retorna codigo do municipio

@author Bernard M. Margarido
@since 30/01/2017
@version undefined

@param cEstado		, characters, Estado 
@param cMunicipio	, characters, Municipio

@type function
/*/
/***********************************************************************************/
Static Function EcCodMun(cEstado,cMunicipio)
Local aArea	:= GetARea()
Local cAlias:= GetNextAlias()
Local cQuery:= ""
Local cIbge	:= ""

If At("'",cMunicipio) > 0
	cMunicipio := StrTran(cMunicipio,"'","''")
EndIf

//-----------------------------+
// Cosulta codigo de municipio |
//-----------------------------+
cQuery := "	SELECT " + CRLF 
cQuery += "		CC2_CODMUN " + CRLF 
cQuery += "	FROM " + CRLF 
cQuery += "		" + RetSqlName("CC2") + CRLF   
cQuery += "	WHERE " + CRLF 
cQuery += "		CC2_FILIAL = '" + xFilial("CC2") + "' AND " + CRLF 
cQuery += "		CC2_EST = '" + cEstado + "' AND " + CRLF 
cQuery += "		CC2_MUN = '" + cMunicipio + "' AND " + CRLF 
cQuery += "		D_E_L_E_T_ <> '*' " 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.) 

If Empty( (cAlias)->CC2_CODMUN )
	(cAlias)->( dbCloseArea() )	
	RestArea(aArea)
	Return cIbge
EndIf

cIbge := (cAlias)->CC2_CODMUN
(cAlias)->( dbCloseArea() )	

RestArea(aArea)
Return cIbge 

/**************************************************************************************************/
/*/{Protheus.doc} EcGrvPed

@description	Rotina valida se pedido ecommerce ja existe na base de dados do protheus

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			oPedido		, Objeto contendo o pedido a ser gravado

@return			aRet - Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro
/*/			
/**************************************************************************************************/
Static Function EcGrvPed(oRestPv,aEndRes,aEndCob,aEndEnt,cOrderId)
	Local aArea		:= GetArea()
	Local aRet		:= {.T.,"",""}

	Local cNumOrc	:= ""
	Local cNumPv	:= ""
	
	Local lLiberPv	:= GetNewPar("EC_LIBPVAU",.F.)
		
	LogExec("VERIFICANDO ORDERID " + cOrderId)

	//--------------------------------------+
	// Valida se pedido ja esta no Protheus |
	//--------------------------------------+
	dbSelectArea("WSA")
	WSA->( dbSetOrder(2) )
	If WSA->( dbSeek(xFilial("WSA") + PadR(cOrderId,nTamOrder)) )
		//------------------------------------+
		// Atualiza Status do Pedido eCommerce|
		//------------------------------------+
		cNumOrc		:= WSA->WSA_NUM
		cOrdPvCli	:= WSA->WSA_NUMECL
		cNumDoc		:= WSA->WSA_DOC
		cNumSer		:= WSA->WSA_SERIE
		cNumPv		:= WSA->WSA_PEDRES
		
		aRet 		:= AEcoUpdPv(cOrderId,cOrdPvCli,cNumOrc,cNumDoc,cNumSer,cNumPv,oRestPv)

	Else
		//---------------------------------+
		// Realiza a grava��o do pedido    |
		// dentro do controle de transa��o |
		//---------------------------------+
		Begin Transaction 
			aRet := AEcoGrvPv(cOrderId,oRestPv,aEndRes,aEndCob,aEndEnt)
			If !aRet[1]
				DisarmTransaction()
			Endif
		End Transaction
		
		//-----------------------+
		// Grava pedido de venda |
		//-----------------------+
		If aRet[1] .And. lLiberPv
			dbSelectArea("WSA")
			WSA->( dbSetOrder(2) )
			If WSA->( dbSeek(xFilial("WSA") + cOrderId) )
				//------------------------------------+
				// Atualiza Status do Pedido eCommerce|
				//------------------------------------+
				cNumOrc		:= WSA->WSA_NUM
				cOrdPvCli	:= WSA->WSA_NUMECL
				cNumDoc		:= WSA->WSA_DOC
				cNumSer		:= WSA->WSA_SERIE
				cNumPv		:= WSA->WSA_PEDRES
				aRet 		:= AEcoUpdPv(cOrderId,cOrdPvCli,cNumOrc,cNumDoc,cNumSer,cNumPv,oRestPv)
			EndIf	
		EndIf
		
	EndIf

	RestArea(aArea)
Return aRet

/**************************************************************************************************/
/*/{Protheus.doc} AEcoGrvPv

@description	Realiza a grava��o do pedido de venda e-commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			cOrderId	, 	string	,	Numero do Pedido e-Commerce
@param			oRestPv		, 	string	,	Objeto contendo o pedido a ser gravado
@param 			lLiberPv	, 	logico	,	Passado como referencia para validar se pagamento esta confirmado.

@return			aRet - Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro
/*/			
/**************************************************************************************************/
Static Function AEcoGrvPv(cOrderId,oRestPv,aEndRes,aEndCob,aEndEnt)
	Local aArea			:= GetArea()
	Local aRet			:= {.T.,"",""}

	Local cVendedor 	:= GetNewPar("EC_VENDECO")
	Local cCnpj			:= ""
	Local cNomeCli		:= ""
	Local cTipoCli		:= ""
	Local cNumOrc		:= ""
	Local cCodCli		:= ""
	Local cLojaCli		:= ""
	Local cEndDest		:= ""
	Local cNumDest 		:= ""
	Local cMunDest 		:= ""
	Local cBaiDest 		:= "" 
	Local cCepDest 		:= ""
	Local cEstDest 		:= ""
	Local cNomDest 		:= ""
	Local cDddCel  		:= ""
	Local cDdd1	 		:= "" 
	Local cTel01 		:= ""
	Local cCelular 		:= ""
	Local cPedCodCli	:= ""
	Local cPedCodInt	:= ""
	Local cCodAfili		:= ""
	Local cIdPost		:= ""
	Local cEndComp		:= "" 
	Local cEndRef		:= ""
	Local cCodTransp	:= ""
	Local cCondPag		:= ""
	
	Local nDesconto		:= 0
	Local nQtdParc		:= 0
	Local nVlrFrete		:= 0
	Local nVrSubTot		:= 0
	Local nVlrTotal		:= 0
	Local nQtdItem		:= 0
		
	Local lUsaVend		:= GetNewPar("EC_USAVEND",.F.)
		
	Local dDtaEmiss		:= Nil
	
	Private nPesoBruto	:= 0

	//------------------+
	// Ajusta variaveis |
	//------------------+
	If Empty(oRestPv:ClientProfileData:CorporateDocument)
		cCnpj := PadR(oRestPv:ClientProfileData:Document,nTamCnpj)
	Else     
		cCnpj := PadR(oRestPv:ClientProfileData:CorporateDocument,nTamCnpj)
	EndIf	
	
	cNomeCli:= Alltrim(oRestPv:ClientProfileData:FirstName + " " +  oRestPv:ClientProfileData:LastName )	

	//-----------------------------------------------+
	// Valida se cliente esta cadastrado no Protheus |
	//-----------------------------------------------+
	dbSelectArea("SA1")
	SA1->( dbSetOrder(3) )
	If !SA1->( dbSeek(xFilial("SA1") + cCnpj) )
		LogExec("CLIENTE " + cNomeCli + " CNPJ/CPF " + cCnpj + " NAO ENCONTRADO. FAVOR REALIZAR A BAIXA DE CLIENTES DO ECOMMERCE.")
		aRet[1] := .F.
		aRet[2] := cCnpj
		aRet[3] := "CLIENTE " + cNomeCli + " CNPJ/CPF " + cCnpj + " NAO ENCONTRADO. FAVOR REALIZAR A BAIXA DE CLIENTES DO ECOMMERCE."
		RestArea(aArea)
		Return aRet
	EndIf

	//---------------+
	// Dados Cliente |
	//---------------+
	cCodCli := SA1->A1_COD
	cLojaCli:= SA1->A1_LOJA
	cTipoCli:= SA1->A1_TIPO

	//-----------------+
	// Valida vendedor |
	//-----------------+
	If lUsaVend
		dbSelectArea("SA3")
		SA3->( dbSetOrder(1) )
		If !SA3->( dbSeek(xFilial("SA3") + cVendedor) )
			LogExec("VENDEDOR " + cVendedor + " PARA O ECOMMERCE NAO CADASTRADO. FAVOR CADASTRAR O VENDEDOR E INFORMAR O CODIGO DO VENDEDOR NO PARAMETRO EC_VENDECO.")
			aRet[1] := .F.
			aRet[2] := cVendedor
			aRet[3] := "VENDEDOR " + cVendedor + " PARA O ECOMMERCE NAO CADASTRADO. FAVOR CADASTRAR O VENDEDOR E INFORMAR O CODIGO DO VENDEDOR NO PARAMETRO EC_VENDECO."
			RestArea(aArea)
			Return aRet
		EndIf
	EndIf
		
	//--------------+
	// Dados Pedido |
	//--------------+
	cIdEnd		:= IIF(Len(aEndEnt) > 0 ,aEndEnt[IDENDE],aEndRes[IDENDE])
	cEndDest 	:= IIF(Len(aEndEnt) > 0 ,aEndEnt[ENDERE],aEndRes[ENDERE])
	cNumDest 	:= IIF(Len(aEndEnt) > 0 ,aEndEnt[NUMERO],aEndRes[NUMERO])
	cMunDest 	:= IIF(Len(aEndEnt) > 0 ,aEndEnt[MUNICI],aEndRes[MUNICI])
	cBaiDest 	:= IIF(Len(aEndEnt) > 0 ,aEndEnt[BAIRRO],aEndRes[BAIRRO]) 
	cCepDest 	:= IIF(Len(aEndEnt) > 0 ,aEndEnt[CEP],aEndRes[CEP])
	cEstDest 	:= IIF(Len(aEndEnt) > 0 ,aEndEnt[ESTADO],aEndRes[ESTADO])
	cNomDest 	:= IIF(Len(aEndEnt) > 0 ,aEndEnt[DESTIN],aEndRes[DESTIN])
	cEndComp	:= IIF(Len(aEndEnt) > 0 ,aEndEnt[COMPLE],aEndRes[COMPLE])
	cEndRef		:= IIF(Len(aEndEnt) > 0 ,aEndEnt[REFERE],aEndRes[REFERE])
	cDddCel  	:= ""
	cDdd1	 	:= IIF(Empty(oRestPv:ClientProfileData:Phone),"",SubStr(oRestPv:ClientProfileData:Phone,4,2)) 
	cTel01 	 	:= IIF(Empty(oRestPv:ClientProfileData:Phone),"",SubStr(oRestPv:ClientProfileData:Phone,6))
	cCelular 	:= ""
	cMotCancel	:= ""
	cObsPedido	:= ""
	cPedCodCli	:= oRestPv:Sequence
	cPedCodInt	:= oRestPv:OrderGroup
	cHoraEmis	:= SubStr(oRestPv:creationDate,At("T",oRestPv:creationDate) + 1,8)
	cPedStatus	:= Lower(oRestPv:Status)
	cCodAfili	:= oRestPv:Affiliateid
	dDtaEmiss	:= dToc(sTod(StrTran(SubStr(oRestPv:creationDate,1,10),"-","")))
	
	//-------------------------+
	// Valida o Id de Postagem |
	//-------------------------+
	If cCodAfili == "MRC"
		cCodTransp 	:= ""
		cIdPost		:= ""
	Else
		AEcoI11IP(oRestPv:ShippingData:LogisticsInfo[1]:DeliveryIds[1]:CourierId,cCodAfili,@cCodTransp,@cIdPost)
	EndIf	 
		
	nDesconto	:= 0 
	If Len(oRestPv:PayMentData:Transactions) > 1
		aEval(oRestPv:PayMentData:Transactions,{|x| nQtdParc += x:Payments[1]:InstallMents})
	Else
		nQtdParc	:= oRestPv:PayMentData:Transactions[1]:Payments[1]:InstallMents
	EndIf	

	nVlrFrete	:= RetPrcUni(oRestPv:Totals[3]:Value)
	nVrSubTot	:= RetPrcUni(oRestPv:Totals[1]:Value)
	nVlrTotal	:= RetPrcUni(oRestPv:Totals[1]:Value) //RetPrcUni(oRestPv:Value)
	nQtdItem	:= Len(oRestPv:Items)
		
	//---------------------+
	// Numero do Orcamento |
	//---------------------+
	cNumOrc := GetSxeNum("WSA","WSA_NUM")

	dbSelectArea("WSA")
	WSA->( dbSetOrder(1) )

	While WSA->( dbSeek(xFilial("WSA") + cNumOrc) )
		ConfirmSx8()
		cNumOrc := GetSxeNum("WSA","WSA_NUM","",1)
	EndDo	 

	LogExec("INCLUINDO PEDIDO PROTHEUS " + cNumOrc + " CLIENTE " + cNomeCli )

	//-----------------------+
	// Grava Itens do Pedido |
	//-----------------------+
	aRet := AEcoGrvIt(cOrderId,cNumOrc,cCodCli,cLojaCli,cVendedor,@nDesconto,@nPesoBruto,dDtaEmiss,oRestPv:Items,oRestPv:ShippingData,oRestPv)
	If!aRet[1]
		RestArea(aArea)
		Return aRet
	EndIf

	//-----------------+
	// Grava Cabe�alho |
	//-----------------+
	aRet := AEcoGrvCab(	cNumOrc,cOrderId,cCodCli,cLojaCli,cTipoCli,cVendedor,cEndDest,cNumDest,;
						cMunDest,cBaiDest,cCepDest,cEstDest,cNomDest,cDddCel,cDdd1,cTel01,cCelular,;
						cIdEnd,cMotCancel,cPedCodCli,cPedCodInt,cHoraEmis,dDtaEmiss,cPedStatus,nVlrFrete,;
						nVrSubTot,nVlrTotal,nQtdParc,nDesconto,nPesoBruto,cIdPost,cEndComp,cEndRef,cCodTransp)
	//------------------------------+					
	// Efetua a grava��o da Reserva |
	//------------------------------+
	If aRet[1]
		aRet := AEcoGrvRes(cOrderId,cPedCodCli,cNumOrc,cCodCli,cLojaCli,cVendedor,nDesconto,dDtaEmiss,oRestPv:Items,oRestPv:ShippingData,oRestPv)
	EndIf

	If!aRet[1]
		RestArea(aArea)
		Return aRet
	EndIf	

	//------------------+
	// Grava Financeiro |
	//------------------+
	aRet := AEcoGrvFin(oRestPv:PaymentData,oRestPv,cNumOrc,cOrderId,cPedCodCli,cHoraEmis,cCodAfili,dDtaEmiss)
		
	If!aRet[1]
		RestArea(aArea)
		Return aRet
	EndIf

	//------------------+
	// Atualiza Status  |
	//------------------+
	aRet := AEcoGrvWs2(cNumOrc,cOrderId,cPedStatus,dDtaEmiss,cHoraEmis)

	If !aRet[1]
		RestArea(aArea)
		Return aRet
	EndIf

	//--------------------------------------+
	// Envia Baixa do Pedido para a Rakuten |
	//--------------------------------------+
	/*
	aRet := u_aEcoI11a(cOrderId,cNumOrc)
	If !aRet[1]
		RestArea(aArea)
		Return aRet
	EndIf
	*/
	//-----------------------------------+
	// Confirma a numera��o do or�amento |
	//-----------------------------------+
	ConfirmSx8()
	
	RestArea(aArea)
Return aRet

/**************************************************************************************************/
/*/{Protheus.doc} AEcoGrvIt

@description	Grava os Itens do Pedido e-Commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

/*/			
/**************************************************************************************************/
Static Function AEcoGrvIt(cOrderId,cNumOrc,cCliente,cLoja,cVendedor,nDesconto,nPesoBruto,dDtaEmiss,oItems,oTransp,oRestPv)
	Local aArea 	:= GetArea()
	Local aRet		:= {.T.,"",""}

	Local aRefImpos	:= {} 

	Local lTesInt	:= GetNewPar("EC_TESINT")
	Local lGrava	:= .T.
	Local lDescPer	:= .F.
	Local lGift		:= .F.
	Local lBrinde	:= .F.
	Local lGratis	:= .F.

	Local cTpOper	:= GetNewPar("EC_TPOPEREC")
	Local cTesEco	:= GetNewPar("EC_TESECO")
	Local cLocal	:= GetNewPar("EC_ARMVEND")
	Local cProduto	:= ""
	Local cItem		:= "01"
	Local cCodKit	:= "kit"
		
	Local nPrd		:= 0
	Local nPesoPrd	:= 0
	Local nPesoCobr	:= 0
	Local nPesoCuba	:= 0
	Local nPesoCubC	:= 0
	Local nPrzEntr	:= 0
	Local nPerDItem	:= 0
	Local nQtdItem	:= 0
	Local nValor	:= 0
	Local nVlrFinal	:= 0
	Local nVlrBrinde:= 0	
	Local nVlrDesc	:= 0
	Local nVlrTotIt	:= 0
		
	Local dDtaEntr	:= Nil
			
	LogExec("GRAVANDO ITENS DO PEDIDO ORDERID " + cOrderId )

	//--------------+
	// Abre Tabelas |
	//--------------+
	dbSelectArea("SB1")
	dbSelectArea("SF4")
	dbSelectArea("WSB")

	//------------------------+
	// Inicia Fun��es Fiscais |
	//------------------------+
	MaFisEnd()
	MaFisIni(cCliente,cLoja,"C","N",Nil,aRefImpos,,.T.,,,,,,,)

	For nPrd := 1 To Len(oItems)

		If ValType(oItems[nPrd]:RefId) == "U"
			cProduto	:= "000001"
		Else
			cProduto	:= oItems[nPrd]:RefId
		EndIf

		LogExec("ITEM " + cItem + " PRODUTO " + cProduto )
				
		//---------------+
		// Dados do Item |
		//---------------+
		cProduto	:= PadR(cProduto,nTamProd)
				
		//--------------------+
		// Converte em quilos |
		//--------------------+
		nPesoPrd	:= oItems[nPrd]:AdditionalInfo:Dimension:Weight / 1000
		
		//--------------------+
		// Converte em quilos |
		//--------------------+ 
		nPesoCobr	:= oItems[nPrd]:AdditionalInfo:Dimension:Weight / 1000
		nPesoCuba	:= oItems[nPrd]:AdditionalInfo:Dimension:CubicWeight
		nPesoCubC	:= oItems[nPrd]:AdditionalInfo:Dimension:CubicWeight
		
		//-------------------------+
		// Valida se � produto KIT |
		//-------------------------+
		If AT(cCodKit,cProduto) > 0
			//----------------------------+
			// Grava itens do produto KIT |
			//----------------------------+
			aRet 	:= AEcoI11Kit(cOrderId,cNumOrc,cCliente,cLoja,cVendedor,nDesconto,nPesoBruto,dDtaEmiss,oItems[nPrd]:Quantity,oItems[nPrd]:Components,oTransp,oRestPv,cProduto,nPrd,@cItem)
			If !aRet[1]
				RestArea(aArea)
				Return aRet
			EndIf
		Else
			//----------------+
			// Valida Produto |
			//----------------+
			SB1->( dbSetOrder(1) )
			If !SB1->( dbSeek(xFilial("SB1") + cProduto) )
				LogExec("PRODUTO " + Alltrim(cProduto) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId )
				aRet[1] := .F.
				aRet[2] := cProduto
				aRet[3] := "PRODUTO " + Alltrim(cProduto) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId 
				RestArea(aArea)
				Return aRet
			EndIf
			
			lGift		:= oItems[nPrd]:IsGift
			lBrinde		:= IIF(!lBrinde,lGift,lBrinde)
			lGratis		:= IIF(oItems[nPrd]:SellingPrice <= 0,.T.,.F.)
			nQtdItem	:= oItems[nPrd]:Quantity
			nValor		:= IIF(lGift .Or. lGratis , 0.01, RetPrcUni(oItems[nPrd]:Price))
			nVlrFinal	:= IIF(lGift .Or. lGratis , 0.01, RetPrcUni(oItems[nPrd]:SellingPrice))
			nVlrBrinde	+= IIF(lBrinde .Or. lGratis , ( 0.01 * nQtdItem) ,0)		

			If Empty(oTransp:LogisticsInfo[nPrd]:ShippingEstimateDate)
				dDtaEntr	:= cTod(dDtaEmiss) + Val(oTransp:LogisticsInfo[nPrd]:ShippingEstimate)
				nPrzEntr	:= Val(oTransp:LogisticsInfo[nPrd]:ShippingEstimate)
			Else
				dDtaEntr	:= StoD(StrTran(SubStr(oTransp:LogisticsInfo[nPrd]:ShippingEstimateDate,1,10),"-",""))
				nPrzEntr	:= StoD(StrTran(SubStr(oTransp:LogisticsInfo[nPrd]:ShippingEstimateDate,1,10),"-","")) - cTod(dDtaEmiss)
			EndIf	 
			
			//--------------------------------------------------------+
			// Valida se desconto foi aplicado em percentual ou valor |
			//--------------------------------------------------------+
			cNameDesc	:=  IIF(Len(oItems[nPrd]:PriceTags) > 0 ,oItems[nPrd]:PriceTags[1]:name,"") 
			lDescPer	:= IIF(Len(oItems[nPrd]:PriceTags) > 0 ,oItems[nPrd]:PriceTags[1]:IsPercentual,.F.)
			nVlrDesc	:= IIF(Len(oItems[nPrd]:PriceTags) > 0 ,IIF(oItems[nPrd]:PriceTags[1]:value < 0,oItems[nPrd]:PriceTags[1]:value,0),0)
				
			//------------------------------+
			// Acha percentual de desconto  |
			//------------------------------+ 
			If !lGift .And. nVlrBrinde == 0 .And. At("discount@shipping",cNameDesc) <= 0  
				If lDescPer
					nPerDItem := RetPrcUni(oItems[nPrd]:PriceTags[1]:Value * -1)
				ElseIf nVlrDesc < 0
					nVlrDesc := RetPrcUni(oItems[nPrd]:PriceTags[1]:Value * -1)
					nVlrTotIt:= nQtdItem * nValor		
					nPerDItem:= Round(( nVlrDesc / nVlrTotIt ) * 100,2)
				EndIf	


			EndIf
			
			//-----------------+
			// Soma peso Bruto |
			//-----------------+
			nPesoBruto	+= nPesoPrd
			
			//------------------------+
			// Utiliza Tes do Produto |
			//------------------------+
			If !Empty(SB1->B1_TS)
				cTesEco := SB1->B1_TS 
			EndIf
			
			//-----------------+
			// Tes Inteligente |
			//-----------------+
			If lTesInt
				cTesEco :=  MaTesInt(2,cTpOper,cCliente,cLoja,"C",cProduto)
			EndIf
	
			//------------+
			// Valida Tes |
			//------------+
			SF4->( dbSetOrder(1) )
			If !SF4->( dbSeek(xFilial("SF4") + cTesEco) )
				LogExec("CODIGO TES " + Alltrim(cTesEco) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId)
				aRet[1] := .F.
				aRet[2] := cTesEco
				aRet[3] := "CODIGO TES  " + Alltrim(cTesEco) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId
				RestArea(aArea)
				Return aRet
			EndIf
					
			//----------------------------------------+
			// Retira o valor de IPI do produto       |
			// quando pedido for faturado calcula IPI |
			// no padrao do sistema                   |
			//----------------------------------------+
			If SB1->B1_IPI > 0 .And. SF4->F4_IPI == "S" //.And. nVlrBrinde <= 0
				nVlrFinal := NoRound( nVlrFinal / ( 1 + ( SB1->B1_IPI / 100 ) ), 4 )
			EndIf
	
			//-------------------------------+
			// Valida se valor foi informado |
			//-------------------------------+
			If Empty(nVlrFinal) 
				LogExec("VALOR DO PRODUTO " + Alltrim(cProduto) + " NAO INFORMADO. VERIFIQUE VALOR NO ADMINISTRATIVO VTEX PARA PEDIDO ORDERID " + cOrderId)
				aRet[1] := .F.
				aRet[2] := cOrderId
				aRet[3] := "VALOR DO PRODUTO " + Alltrim(cProduto) + " NAO INFORMADO. VERIFIQUE VALOR NO ADMINISTRATIVO VTEX PARA PEDIDO ORDERID " + cOrderId
				RestArea(aArea)
				Return aRet
			EndIf
	
			//----------------------------------------+
			// Adiciona Produto para calculos fiscais |
			//----------------------------------------+
			MaFisAdd(cProduto,cTesEco,nQtdItem,nVlrFinal,nDesconto,"","",,0,0,0,0,Round(nQtdItem * nVlrFinal,nDecIt))
	
			//-----------------+
			// Grava Itens SL2 |
			//-----------------+
			lGrava := .T.
	
			WSB->( dbSetOrder(1) )
			If WSB->( dbSeek(xFilial("WSB") + cNumOrc + cItem + cProduto) )
				lGrava := .F.
			EndIf	
	
			RecLock("WSB",lGrava)
				WSB->WSB_FILIAL 	:= xFilial("WSB")
				WSB->WSB_NUM		:= cNumOrc 
				WSB->WSB_PRODUT		:= cProduto
				WSB->WSB_ITEM		:= cItem
				WSB->WSB_DESCRI		:= SB1->B1_DESC
				WSB->WSB_QUANT		:= nQtdItem
				WSB->WSB_VRUNIT		:= nVlrFinal
				WSB->WSB_VLRITE		:= Round(nQtdItem * nVlrFinal,nDecIt)
				WSB->WSB_LOCAL		:= cLocal
				WSB->WSB_UM			:= SB1->B1_UM
				WSB->WSB_DESC		:= nPerDItem
				WSB->WSB_VALDES		:= IIF(nVlrDesc > 0,nVlrDesc,Round( nValor * (nPerDItem /100 ),2))
				WSB->WSB_TES		:= cTesEco
				WSB->WSB_CF			:= SF4->F4_CF
				WSB->WSB_VALIPI		:= MaFisRet(nPrd,"IT_VALIPI") 
				WSB->WSB_VALICM		:= MaFisRet(nPrd,"IT_VALICM")
				WSB->WSB_VALISS		:= MaFisRet(nPrd,"IT_VALISS")
				WSB->WSB_BASEIC		:= MaFisRet(nPrd,"IT_BASEICM")
				WSB->WSB_STATUS		:= ""
				WSB->WSB_EMISSA		:= cTod(dDtaEmiss)
				WSB->WSB_PRCTAB		:= nValor
				WSB->WSB_GRADE		:= "N"
				WSB->WSB_VEND		:= cVendedor
				WSB->WSB_VALFRE		:= 0
				WSB->WSB_SEGURO		:= 0
				WSB->WSB_DESPES		:= 0
				WSB->WSB_ICMSRE		:= MaFisRet(nPrd,"IT_VALSOL")
				WSB->WSB_BRICMS		:= MaFisRet(nPrd,"IT_BASESOL")
				WSB->WSB_VALPIS		:= MaFisRet(nPrd,"IT_VALPIS")
				WSB->WSB_VALCOF		:= MaFisRet(nPrd,"IT_VALCOF")
				WSB->WSB_VALCSL		:= MaFisRet(nPrd,"IT_VALCSL")
				WSB->WSB_VALPS2		:= MaFisRet(nPrd,"IT_VALPS2")
				WSB->WSB_VALCF2		:= MaFisRet(nPrd,"IT_VALCF2")
				WSB->WSB_BASEPS		:= MaFisRet(nPrd,"IT_BASEPS2")
				WSB->WSB_BASECF		:= MaFisRet(nPrd,"IT_BASECF2")
				WSB->WSB_ALIQPS		:= MaFisRet(nPrd,"IT_ALIQPS2")
				WSB->WSB_ALIQCF		:= MaFisRet(nPrd,"IT_ALIQCF2")
				WSB->WSB_SEGUM		:= SB1->B1_SEGUM
				WSB->WSB_PEDRES		:= ""
				WSB->WSB_FDTENT		:= dDtaEntr
				WSB->WSB_PRODTP		:= ""
				WSB->WSB_PRZENT		:= nPrzEntr
				WSB->WSB_STATIT		:= "" 
				WSB->WSB_DESTAT		:= ""
			WSB->( MsUnLock() )
			
			//------------------------+
			// Codigo do Proximo Item |
			//------------------------+
			cItem := Soma1(cItem) //StrZero(nPrd,nTItemL2)
		EndIf	

	Next nPrd
	
	//-----------------------------------------+
	// Valida se teve brinde                   |
	// aplica desconto de 0.1 no primeiro item | 
	//-----------------------------------------+
	If lBrinde .Or. lGratis
		nDesconto := nVlrBrinde
		//AEcoI11Brinde(cNumOrc,nVlrBrinde)
	EndIf
	
	RestArea(aArea)
Return aRet 

/**************************************************************************************/
/*/{Protheus.doc} AEcoI11Kit

@description Realiza a grava��o dos produtos KIT

@author Bernard M. Margarido
@since 02/03/2017
@version undefined

@type function
/*/
/**************************************************************************************/
Static Function AEcoI11Kit(cOrderId,cNumOrc,cCliente,cLoja,cVendedor,nDesconto,nPesoBruto,dDtaEmiss,nQtdKit,oItKit,oTransp,oRestPv,cCodKit,nItAtu,cItem)
Local aArea	:= GetArea()

Local aRet		:= {.T.,"",""}

Local aRefImpos	:= {} 

Local lTesInt	:= GetNewPar("EC_TESINT")
Local lGrava	:= .T.
Local lDescPer	:= .F.

Local cTpOper	:= GetNewPar("EC_TPOPEREC")
Local cTesEco	:= GetNewPar("EC_TESECO")
Local cLocal	:= GetNewPar("EC_ARMVEND")
Local cProduto	:= ""

Local nPrd		:= 0
Local nPesoPrd	:= 0
Local nPesoCobr	:= 0
Local nPesoCuba	:= 0
Local nPesoCubC	:= 0
Local nPrzEntr	:= 0
Local nPerDItem	:= 0
Local nQtdItem	:= 0
Local nValor	:= 0
Local nVlrFinal	:= 0

Local dDtaEntr	:= Nil
		
LogExec("GRAVANDO ITENS DO PRODUTO KIT " + cCodKit )

//--------------+
// Abre Tabelas |
//--------------+
dbSelectArea("SB1")
dbSelectArea("SF4")
dbSelectArea("WSB")

For nPrd := 1 To Len(oItKit)
	
	//---------------------------+
	// Formata codigo do Produto |
	//---------------------------+
	cProduto	:= PadR(oItKit[nPrd]:RefId,nTamProd) 
	
	LogExec("ITEM " + cItem + " PRODUTO KIT " + cProduto )
	
	//----------------+
	// Valida Produto |
	//----------------+
	SB1->( dbSetOrder(1) )
	If !SB1->( dbSeek(xFilial("SB1") + cProduto) )
		LogExec("PRODUTO " + Alltrim(cProduto) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId )
		aRet[1] := .F.
		aRet[2] := cProduto
		aRet[3] := "PRODUTO " + Alltrim(cProduto) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId 
		RestArea(aArea)
		Return aRet
	EndIf
						
	nQtdItem	:= nQtdKit * oItKit[nPrd]:Quantity
	nValor		:= RetPrcUni(oItKit[nPrd]:Price)
	nVlrFinal	:= RetPrcUni(oItKit[nPrd]:SellingPrice)
	If Empty(oTransp:LogisticsInfo[nItAtu]:ShippingEstimateDate)
		dDtaEntr	:= cTod(dDtaEmiss) + Val(oTransp:LogisticsInfo[nItAtu]:ShippingEstimate)
		nPrzEntr	:= Val(oTransp:LogisticsInfo[nItAtu]:ShippingEstimate)
	Else
		dDtaEntr	:= StoD(StrTran(SubStr(oTransp:LogisticsInfo[nItAtu]:ShippingEstimateDate,1,10),"-",""))
		nPrzEntr	:= StoD(StrTran(SubStr(oTransp:LogisticsInfo[nItAtu]:ShippingEstimateDate,1,10),"-","")) - cTod(dDtaEmiss)
	EndIf	 
		
	//--------------------------------------------------------+
	// Valida se desconto foi aplicado em percentual ou valor |
	//--------------------------------------------------------+
	lDescPer	:= IIF(Len(oItKit[nPrd]:PriceTags) > 0 ,oItKit[nPrd]:PriceTags[1]:IsPercentual,.F.)
	nVlrDesc	:= IIF(Len(oItKit[nPrd]:PriceTags) > 0 ,IIF(oItKit[nPrd]:PriceTags[1]:value < 0,oItKit[nPrd]:PriceTags[1]:value,0),0)
		
	//------------------------------+
	// Acha percentual de desconto  |
	//------------------------------+ 
	If lDescPer
		nPerDItem := RetPrcUni(oItKit[nPrd]:PriceTags[1]:Value * -1)
	ElseIf nVlrDesc < 0
		nVlrDesc := RetPrcUni(oItKit[nPrd]:PriceTags[1]:Value * -1)
		nVlrTotIt:= nQtdItem * nValor		
		nPerDItem:= Round(( nVlrDesc / nVlrTotIt ) * 100,2)
	EndIf		
		
	//-----------------+
	// Soma peso Bruto |
	//-----------------+
	nPesoBruto	+= nPesoPrd
	
	//------------------------+
	// Utiliza Tes do Produto |
	//------------------------+
	If !Empty(SB1->B1_TS)
		cTesEco := SB1->B1_TS 
	EndIf
	
	//-----------------+
	// Tes Inteligente |
	//-----------------+
	If lTesInt
		cTesEco :=  MaTesInt(2,cTpOper,cCliente,cLoja,"C",cProduto)
	EndIf
	
	//------------+
	// Valida Tes |
	//------------+
	SF4->( dbSetOrder(1) )
	If !SF4->( dbSeek(xFilial("SF4") + cTesEco) )
		LogExec("CODIGO TES " + Alltrim(cTesEco) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId)
		aRet[1] := .F.
		aRet[2] := cTesEco
		aRet[3] := "CODIGO TES  " + Alltrim(cTesEco) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId
		RestArea(aArea)
		Return aRet
	EndIf
			
	//----------------------------------------+
	// Retira o valor de IPI do produto       |
	// quando pedido for faturado calcula IPI |
	// no padrao do sistema                   |
	//----------------------------------------+
	If SB1->B1_IPI > 0 .And. SF4->F4_IPI == "S" 
		nVlrFinal := NoRound( nVlrFinal / ( 1 + ( SB1->B1_IPI / 100 ) ), 4 )
	EndIf
	
	//-------------------------------+
	// Valida se valor foi informado |
	//-------------------------------+
	If Empty(nVlrFinal)
		LogExec("VALOR DO PRODUTO " + Alltrim(cProduto) + " NAO INFORMADO. VERIFIQUE VALOR NO ADMINISTRATIVO RAKUTEN PARA PEDIDO ORDERID " + cOrderId)
		aRet[1] := .F.
		aRet[2] := cOrderId
		aRet[3] := "VALOR DO PRODUTO " + Alltrim(cProduto) + " NAO INFORMADO. VERIFIQUE VALOR NO ADMINISTRATIVO RAKUTEN PARA PEDIDO ORDERID " + cOrderId
		RestArea(aArea)
		Return aRet
	EndIf
	
	//----------------------------------------+
	// Adiciona Produto para calculos fiscais |
	//----------------------------------------+
	MaFisAdd(cProduto,cTesEco,nQtdItem,nVlrFinal,nDesconto,"","",,0,0,0,0,Round(nQtdItem * nVlrFinal,nDecIt))
	
	//-----------------+
	// Grava Itens SL2 |
	//-----------------+
	lGrava := .T.
	
	WSB->( dbSetOrder(1) )
	If WSB->( dbSeek(xFilial("WSB") + cNumOrc + cItem + cProduto) )
		lGrava := .F.
	EndIf	
	
	RecLock("WSB",lGrava)
		WSB->WSB_FILIAL 	:= xFilial("WSB")
		WSB->WSB_NUM		:= cNumOrc 
		WSB->WSB_PRODUT		:= cProduto
		WSB->WSB_ITEM		:= cItem
		WSB->WSB_DESCRI		:= SB1->B1_DESC
		WSB->WSB_QUANT		:= nQtdItem
		WSB->WSB_VRUNIT		:= nVlrFinal
		WSB->WSB_VLRITE		:= Round(nQtdItem * nVlrFinal,nDecIt)
		WSB->WSB_LOCAL		:= cLocal
		WSB->WSB_UM			:= SB1->B1_UM
		WSB->WSB_DESC		:= nPerDItem
		WSB->WSB_VALDES		:= Round( nValor * (nPerDItem /100 ),2)
		WSB->WSB_TES		:= cTesEco
		WSB->WSB_CF			:= SF4->F4_CF
		WSB->WSB_VALIPI		:= MaFisRet(nPrd,"IT_VALIPI") 
		WSB->WSB_VALICM		:= MaFisRet(nPrd,"IT_VALICM")
		WSB->WSB_VALISS		:= MaFisRet(nPrd,"IT_VALISS")
		WSB->WSB_BASEIC		:= MaFisRet(nPrd,"IT_BASEICM")
		WSB->WSB_STATUS		:= ""
		WSB->WSB_EMISSA		:= cTod(dDtaEmiss)
		WSB->WSB_PRCTAB		:= nValor
		WSB->WSB_GRADE		:= "N"
		WSB->WSB_VEND		:= cVendedor
		WSB->WSB_VALFRE		:= 0
		WSB->WSB_SEGURO		:= 0
		WSB->WSB_DESPES		:= 0
		WSB->WSB_ICMSRE		:= MaFisRet(nPrd,"IT_VALSOL")
		WSB->WSB_BRICMS		:= MaFisRet(nPrd,"IT_BASESOL")
		WSB->WSB_VALPIS		:= MaFisRet(nPrd,"IT_VALPIS")
		WSB->WSB_VALCOF		:= MaFisRet(nPrd,"IT_VALCOF")
		WSB->WSB_VALCSL		:= MaFisRet(nPrd,"IT_VALCSL")
		WSB->WSB_VALPS2		:= MaFisRet(nPrd,"IT_VALPS2")
		WSB->WSB_VALCF2		:= MaFisRet(nPrd,"IT_VALCF2")
		WSB->WSB_BASEPS		:= MaFisRet(nPrd,"IT_BASEPS2")
		WSB->WSB_BASECF		:= MaFisRet(nPrd,"IT_BASECF2")
		WSB->WSB_ALIQPS		:= MaFisRet(nPrd,"IT_ALIQPS2")
		WSB->WSB_ALIQCF		:= MaFisRet(nPrd,"IT_ALIQCF2")
		WSB->WSB_SEGUM		:= SB1->B1_SEGUM
		WSB->WSB_PEDRES		:= ""
		WSB->WSB_FDTENT		:= dDtaEntr
		WSB->WSB_PRODTP		:= ""
		WSB->WSB_PRZENT		:= nPrzEntr
		WSB->WSB_STATIT		:= "" 
		WSB->WSB_DESTAT		:= ""
	WSB->( MsUnLock() )
	
	//------------------------+
	// Codigo do Proximo Item |
	//------------------------+
	cItem := Soma1(cItem) //StrZero(nPrd,nTItemL2)

Next nPrd

RestArea(aArea)
Return aRet

/******************************************************************************/
/*/{Protheus.doc} AEcoI11Brinde

@description Aplica desconto do brinde no primeiro item do pedido

@author Bernard M. Margarido

@since 01/06/2017
@version undefined

@param cNumOrc, characters, descricao

@type function
/*/
/******************************************************************************/
Static Function AEcoI11Brinde(cNumOrc,nVlrBrinde)
Local aArea		:= GetArea()

Local cItem		:= PadL("01",nTItemL2,"0") 

Local nPrcVen	:= 0
Local nPrcTab	:= 0
Local nVlrTot	:= 0
Local nVlrSDesc	:= 0
Local nQtdVen	:= 0
Local nValDesc	:= 0
Local nPDesc	:= 0	


dbSelectArea("WSB")
WSB->( dbSetOrder(2) )
WSB->( dbSeek(xFilial("WSB") + cNumOrc + cItem) )

//----------------------+
// Grava valores atuais |
//----------------------+
nPrcVen := WSB->WSB_VRUNIT
nPrcTab	:= WSB->WSB_PRCTAB
nQtdVen := WSB->WSB_QUANT
nVlrTot	:= WSB->WSB_VLRITE
nValDesc:= WSB->WSB_VALDES
nPDesc	:= WSB->WSB_DESC

//-------------------------+
// Calula os novos valores |
//-------------------------+
nVlrSDesc	:= Round( nQtdVen * nPrcTab ,2)
nValDesc	:= nValDesc + nVlrBrinde 
nVlrTot		:= nVlrTot - nVlrBrinde  
nPDesc		:= 0
nPrcVen		:= Round(nVlrTot / nQtdVen ,2)

//------------------------------------+
// Atualiza informa��es no or�amentos |
//------------------------------------+
RecLock("WSB",.F.)
	WSB->WSB_VRUNIT		:= nPrcVen
	WSB->WSB_VLRITE		:= nVlrTot
	WSB->WSB_VALDES		:= nValDesc
	WSB->WSB_DESC		:= nPDesc
WSB->( MsUnLock() )

RestArea(aArea)
Return .T.

/**************************************************************************************/
/*/{Protheus.doc} AEcoGrvRes
	@description Efetua a reserva do item 
	@author Bernard M. Margarido
	@since 13/06/2019
	@version undefined
	@type function
/*/
/**************************************************************************************/
Static Function AEcoGrvRes(cOrderId,cPedCodCli,cNumOrc,cCodCli,cLojaCli,cVendedor,nDesconto,dDtaEmiss,oItems,oTransp,oRestPv)
Local _aArea 		:= GetArea()
Local aRet			:= {.T.,"",""}
Local aOperacao		:= {}
Local aLote			:= {}

Local _cCodRes		:= ""
Local cProduto		:= ""
Local cTipo			:= "LJ"
Local _cClient		:= "ECOMM"
Local cCodKit		:= "kit"
Local cLocal		:= GetNewPar("EC_ARMVEND")

Local nQtdItem		:= 0
Local _nSaldoSb2	:= 0

Local dDtVldRserv	:= GetNewPar("EC_DTVLDRE","01/01/2049")

Local _lGerou		:= .F.
Local lGift			:= .F.
Local lBrinde		:= .F.

LogExec("EFETUANDO A RESERVA DO PEDIDO " + cOrderId )

//--------------+
// Abre Tabelas |
//--------------+
dbSelectArea("SB1")
dbSelectArea("WSB")

For nPrd := 1 To Len(oItems)

	If ValType(oItems[nPrd]:RefId) == "U"
		cProduto := "000001"
	Else
		cProduto := oItems[nPrd]:RefId
	EndIf

	LogExec(" GERANDO A RESERVA DO PRODUTO " + cProduto )
				
	//---------------+
	// Dados do Item |
	//---------------+
	cProduto	:= PadR(cProduto,nTamProd)
	nQtdItem	:= oItems[nPrd]:Quantity

	//-------------------------+
	// Valida se � produto KIT |
	//-------------------------+
	If AT(cCodKit,cProduto) > 0
		//-----------------------------------+
		// Efetua a reserva dos peodutos KIT |
		//-----------------------------------+
		aRet 	:= AEcoGrvRKit(cOrderId,cPedCodCli,cNumOrc,cCodCli,cLojaCli,cVendedor,nDesconto,dDtaEmiss,oItems[nPrd]:Quantity,oItems[nPrd]:Components,oTransp,oRestPv,cProduto,dDtVldRserv)
		If !aRet[1]
			RestArea(aArea)
			Return aRet
		EndIf
	Else

		//----------------+
		// Valida Produto |
		//----------------+
		SB1->( dbSetOrder(1) )
		If !SB1->( dbSeek(xFilial("SB1") + cProduto) )
			LogExec("PRODUTO " + Alltrim(cProduto) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId )
			aRet[1] := .F.
			aRet[2] := cProduto
			aRet[3] := "PRODUTO " + Alltrim(cProduto) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId 
			RestArea(aArea)
			Return aRet
		EndIf
		
		//-----------------------------------------+
		// Valida se produto tem desconto / brinde |
		//-----------------------------------------+ 
		lGift		:= oItems[nPrd]:IsGift
		lBrinde		:= IIF(!lBrinde,lGift,lBrinde)

		If lBrinde .Or. lGift
			Loop
		Endif

		//--------------------------+
		// Valida se existe reserva |
		//--------------------------+
		dbSelectArea("SC0")
		SC0->( dbSetOrder(3) )
		If !SC0->( dbSeek(xFilial("SC0") + cTipo + PadR(cPedCodCli,nTPedCli) + cProduto) )

			//----------------------------------------+	
			// Valida se produto tem armzem de venda  |
			//----------------------------------------+
			_aAreaSB2 := SB2->( GetArea() )
				dbSelectArea("SB2")
				SB2->( dbSetOrder(1) )
				If !SB2->( dbSeek(xFilial("SB2") + cProduto + cLocal) )
					CriaSb2(cProduto,cLocal)
				EndIf
				//-------------------------+
				// Valida saldo do produto | 
				//-------------------------+
				_nSaldoSb2	:= 0
				_nSaldoSb2 	:= SaldoSB2()
				If _nSaldoSb2 <= 0
					aRet[1]	:= .F.
					aRet[2]	:= cOrderId
					aRet[3]	:= "PRODUTO " + cProduto  + " SEM SALDO EM ESTOQUE NO ARMAZEM " + cLocal + " ."
					RestArea(_aArea)
					Return aRet
				EndIf	
			RestArea(_aAreaSB2)

			

			//------------------------------+
			// Inicia a grava��o da reserva |
			//------------------------------+
			aOperacao 	:= {1, cTipo, cPedCodCli, _cClient, xFilial("SC0"), "Reserva eCommerce:" + cPedCodCli}
			aLote   	:= {"" , "" , "", ""}
			_cCodRes	:= GetSxeNum("SC0","C0_NUM")

			_lGerou		:= a430Reserv(	aOperacao						,;			// Array contendo dados da reserva
										_cCodRes						,;			// Numero da Reserva
										PadR(cProduto, nTamProd)		,;			// Produto 
										cLocal							,;			// Armazem  
										nQtdItem						,;			// Saldo
										aLote,,							)			// Lote 
			If _lGerou
				//--------------------+
				// Confirma numera��o |
				//--------------------+
				ConfirmSx8()
				
				//-----------------------+
				// Posiciona Pre Empenho |
				//-----------------------+
				SC0->( dbSetOrder(3) )
				SC0->( dbSeek(xFilial("SC0") + cTipo + PadR(cPedCodCli,nTPedCli) + cProduto))
					
				//---------------------------------------------+
				// Validas e Reserva foi realizada com sucesso |
				//---------------------------------------------+
				If ( SC0->C0_PRODUTO == Padr(RTrim(cProduto),nTamProd) ) .And. ( cPedCodCli $ SC0->C0_OBS ) .And. ( SC0->C0_NUM == _cCodRes )
					RecLock("SC0",.F.)
						SC0->C0_QUANT  -= nQtdItem
						SC0->C0_QTDPED += nQtdItem
						SC0->C0_VALIDA := IIF(ValType(dDtVldRserv) == "C",cTod(dDtVldRserv),dDtVldRserv)
					SC0->(MsUnLock())

					LogExec("RESERVA " + _cCodRes + " EFETUADA COM SUCESSO.")

				Else
					
					//-----------------------------------+
					// Desarma Transacao em caso de erro |
					//-----------------------------------+
					RollBackSx8()
					LogExec("ERRO AO GERAR PRE EMPENHO " + _cCodRes + " .")	

					aRet[1]	:= .F.
					aRet[2]	:= cOrderId
					aRet[3]	:= "ERRO AO GERAR PRE EMPENHO " + _cCodRes + " ."
				EndIf
			Else
				//-----------------------------------+
				// Desarma Transacao em caso de erro |
				//-----------------------------------+
				RollBackSx8()
				LogExec("ERRO AO GERAR PRE EMPENHO " + _cCodRes + " .")	

				aRet[1]	:= .F.
				aRet[2]	:= cOrderId
				aRet[3]	:= "ERRO AO GERAR PRE EMPENHO " + _cCodRes + " ."
				
			EndIf
		EndIf
	EndIf	
Next nPrd			

RestArea(_aArea)
Return aRet

/**************************************************************************************/
/*/{Protheus.doc} AEcoGrvRKit
	@description Realiza a reserva dos produtos KIT
	@author Bernard M. Margarido
	@since 13/06/2019
	@version undefined
	@type function
/*/
/**************************************************************************************/
Static Function AEcoGrvRKit(cOrderId,cPedCodCli,cNumOrc,cCodCli,cLojaCli,cVendedor,nDesconto,dDtaEmiss,nQtdKit,oItKit,oTransp,oRestPv,cCodKit,dDtVldRserv)
Local _aArea	:= GetArea()

Local aRet		:= {.T.,"",""}
Local aOperacao	:= {}
Local aLote		:= {}

Local _cCodRes	:= ""
Local cProduto	:= ""
Local cTipo		:= "LJ"
Local _cClient	:= "ECOMM"
Local cLocal	:= GetNewPar("EC_ARMVEND")

Local nQtdItem	:= 0
Local nX		:= 0

		
LogExec("EFETUANDO A RESERVA DOS PRODUTOS KIT PEDIDO " + cOrderId)

//--------------+
// Abre Tabelas |
//--------------+
dbSelectArea("SB1")
dbSelectArea("WSB")

For nX := 1 To Len(oItKit)
	
	//---------------------------+
	// Formata codigo do Produto |
	//---------------------------+
	cProduto	:= PadR(oItKit[nX]:RefId,nTamProd) 
	nQtdItem	:= nQtdKit * oItKit[nX]:Quantity

	LogExec(" EFETUAND A RESERVA DO PRODUTO KIT " + cProduto )
	
	//----------------+
	// Valida Produto |
	//----------------+
	SB1->( dbSetOrder(1) )
	If !SB1->( dbSeek(xFilial("SB1") + cProduto) )
		LogExec("PRODUTO " + Alltrim(cProduto) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId )
		aRet[1] := .F.
		aRet[2] := cProduto
		aRet[3] := "PRODUTO " + Alltrim(cProduto) + " NAO ENCONTRADO. PEDIDO ORDERID " + cOrderId 
		RestArea(aArea)
		Return aRet
	EndIf

	//--------------------------+
	// Valida se existe reserva |
	//--------------------------+
	dbSelectArea("SC0")
	SC0->( dbSetOrder(3) )
	If !SC0->( dbSeek(xFilial("SC0") + cTipo + PadR(cPedCodCli,nTPedCli) + cProduto) )

		//----------------------------------------+	
		// Valida se produto tem armzem de venda  |
		//----------------------------------------+
		_aAreaSB2 := SB2->( GetArea() )
			dbSelectArea("SB2")
			SB2->( dbSetOrder(1) )
			If !SB2->( dbSeek(xFilial("SB2") + cProduto + cLocal) )
				CriaSb2(cProduto,cLocal)
			EndIf

			//-------------------------+
			// Valida saldo do produto | 
			//-------------------------+
			_nSaldoSb2 := 0
			_nSaldoSb2 := SaldoSB2()
			If _nSaldoSb2 <= 0
				aRet[1]	:= .F.
				aRet[2]	:= cOrderId
				aRet[3]	:= "PRODUTO " + cProduto  + " SEM SALDO EM ESTOQUE NO ARMAZEM " + cLocal + " ."
				RestArea(_aArea)
				Return aRet
			EndIf

		RestArea(_aAreaSB2)

		//------------------------------+
		// Inicia a grava��o da reserva |
		//------------------------------+
		aOperacao 	:= {1, cTipo, cPedCodCli, _cClient, xFilial("SC0"), "Reserva eCommerce:" + cPedCodCli}
		aLote   	:= {"" , "" , "", ""}
		_cCodRes	:= GetSxeNum("SC0","C0_NUM")

		_lGerou		:= a430Reserv(	aOperacao						,;			// Array contendo dados da reserva
									_cCodRes						,;			// Numero da Reserva
									PadR(cProduto, nTamProd)		,;			// Produto 
									cLocal							,;			// Armazem  
									nQtdItem						,;			// Saldo
									aLote,,							)			// Lote 
		If _lGerou
			//--------------------+
			// Confirma numera��o |
			//--------------------+
			ConfirmSx8()
			
			//-----------------------+
			// Posiciona Pre Empenho |
			//-----------------------+
			SC0->( dbSetOrder(3) )
			SC0->( dbSeek(xFilial("SC0") + cTipo + PadR(cPedCodCli,nTPedCli) + cProduto))
				
			//---------------------------------------------+
			// Validas e Reserva foi realizada com sucesso |
			//---------------------------------------------+
			If ( SC0->C0_PRODUTO == Padr(RTrim(cProduto),nTamProd) ) .And. ( cPedCodCli $ SC0->C0_OBS ) .And. ( SC0->C0_NUM == _cCodRes )
				RecLock("SC0",.F.)
					SC0->C0_QUANT  -= nQtdItem
					SC0->C0_QTDPED += nQtdItem
					SC0->C0_VALIDA := IIF(ValType(dDtVldRserv) == "C",cTod(dDtVldRserv),dDtVldRserv) 
				SC0->(MsUnLock())

				LogExec("RESERVA " + _cCodRes + " EFETUADA COM SUCESSO.")

			Else
				LogExec("ERRO AO GERAR RESERVA " + _cCodRes )
			EndIf
		Else
			//-----------------------------------+
			// Desarma Transacao em caso de erro |
			//-----------------------------------+
			RollBackSx8()
			LogExec("ERRO AO GERAR PRE EMPENHO " + _cCodRes + " .")	

			aRet[1]	:= .F.
			aRet[2]	:= cOrderId
			aRet[3]	:= "ERRO AO GERAR PRE EMPENHO " + _cCodRes + " ."

		EndIf

	EndIf
Next nX
	
RestArea(_aArea)
Return aRet

/***********************************************************************************************************/
/*/{Protheus.doc} AEcoGrvCab

@description Grava Cabe�alho do Pedido e-Commerce

@author Bernard M. Margarido

@since 01/02/2017
@version undefined

@type function
/*/
/***********************************************************************************************************/
Static Function AEcoGrvCab(	cNumOrc,cOrderId,cCodCli,cLojaCli,cTipoCli,cVendedor,cEndDest,cNumDest,;
							cMunDest,cBaiDest,cCepDest,cEstDest,cNomDest,cDddCel,cDdd1,cTel01,cCelular,;
							cIdEnd,cMotCancel,cPedCodCli,cPedCodInt,cHoraEmis,dDtaEmiss,cPedStatus,nVlrFrete,;
							nVrSubTot,nVlrTotal,nQtdParc,nDesconto,nPesoBruto,cIdPost,cEndComp,cEndRef,cCodTransp)

	Local aArea			:= GetArea()
	Local aRet			:= {.T.,"",""}
	
	Local lGrava		:= .T.	

	Local cEspecie		:= GetNewPar("EC_ESPECIE","EMBALAGEM")
	Local cTransViz		:= GetNewPar("EC_TRANVIZ","067/077/087")
	Local cTpFrete		:= ""
	Local cCondPag		:= GetNewPar("EC_CONDPAG","001")
	Local nDiasOrc		:= GetNewPar("EC_DIASORC",15)
		
	//------------------------------+
	// Grava Cabe�alho do Or�amento |
	//------------------------------+
	dbSelectArea("WSA")
	WSA->( dbSetOrder(1) )
	If WSA->( dbSeek(xFilial("WSA") + cNumOrc ) )
		lGrava := .F.
	EndIf							

	//---------------------------+
	// Posiciona Status do Pedido|
	//---------------------------+
	dbSelectArea("WS1")
	WS1->( dbSetOrder(2) )
	If !WS1->( dbSeek(xFilial("WS1") + Padr(Alltrim(cPedStatus),nTamStat)) )
		LogExec("STATUS " + Capital(cPedStatus) + " NAO LOCALIZADO PARA O PEDIDO ORDERID " + cOrderId + " FAVOR CADASTRAR O STATUS E IMPORTAR O PEDIDO NOVAMENTE.")
		aRet[1] := .F.
		aRet[2] := cOrderId
		aRet[3] := "STATUS " + Capital(cPedStatus) + " NAO LOCALIZADO PARA O PEDIDO ORDERID " + cOrderId + " FAVOR CADASTRAR O STATUS E IMPORTAR O PEDIDO NOVAMENTE."
		RestArea(aArea)
		Return aRet
	EndIf
	
	//----------------------+
	// Valida Tipo de Frete |
	//----------------------+
	If SubStr(Alltrim(cOrderId),1,3) == "MRC"
		cTpFrete := "0"
	ElseIf Empty(cIdPost) .And. Alltrim(cCodTransp) $ cTransViz 
		cTpFrete := "0"
	ElseIf !Empty(cIdPost)
		If nVlrFrete > 0
			cTpFrete := "F"
		Else
			cTpFrete := "C"
		EndIf
	ElseIf Empty(cIdPost) .And. !Empty(cCodTransp)
		If nVlrFrete > 0
			cTpFrete := "F"
		Else
			cTpFrete := "C"
		EndIf
	ElseIf Empty(cIdPost) .And. Empty(cCodTransp)
		If nVlrFrete > 0
			cTpFrete := "F"
		Else
			cTpFrete := "C"
		EndIf	
	EndIf
	
	//------------------------------+
	// Atualiza endere�o de entrega |
	//------------------------------+
	/*
	aEcoI011Entr(	cCodCli,cLojaCli,cNomDest,;
					cEndDest,cNumDest,cBaiDest,;
					cCepDest,cMunDest,cEstDest,cEndComp )
	*/

	RecLock("WSA",lGrava)
		WSA->WSA_FILIAL		:= xFilial("WSA")
		WSA->WSA_NUM		:= cNumOrc
		WSA->WSA_VEND		:= cVendedor
		WSA->WSA_COMIS		:= 0
		WSA->WSA_CLIENT		:= cCodCli
		WSA->WSA_LOJA		:= cLojaCli
		WSA->WSA_TIPOCL		:= cTipoCli	
		WSA->WSA_VLRTOT		:= MaFisRet(,"NF_VALMERC")
		WSA->WSA_DESCON		:= nDesconto
		WSA->WSA_VLRLIQ		:= MaFisRet(,"NF_VALMERC")
		WSA->WSA_DTLIM		:= DaySum(cTod(dDtaEmiss),nDiasOrc)
		WSA->WSA_VALBRU		:= MaFisRet(,"NF_VALMERC") //MaFisRet(,"NF_TOTAL") 
		WSA->WSA_VALMER		:= MaFisRet(,"NF_VALMERC") //MaFisRet(,"NF_VALMERC")
		WSA->WSA_DESCNF		:= 0
		WSA->WSA_DINHEI		:= 0
		WSA->WSA_CHEQUE		:= 0
		WSA->WSA_CARTAO		:= 0
		WSA->WSA_CONVEN		:= 0
		WSA->WSA_VALES		:= 0
		WSA->WSA_FINANC		:= 0
		WSA->WSA_OUTROS		:= 0
		WSA->WSA_PARCEL		:= nQtdParc 	
		WSA->WSA_VALICM		:= MaFisRet(,"NF_VALICM")
		WSA->WSA_VALIPI		:= MaFisRet(,"NF_VALIPI")
		WSA->WSA_VALISS		:= MaFisRet(,"NF_VALISS")
		WSA->WSA_CONDPG		:= cCondPag
		WSA->WSA_FORMPG		:= ""
		WSA->WSA_CREDIT		:= 0
		WSA->WSA_EMISSA		:= cTod(dDtaEmiss)
		WSA->WSA_FATOR		:= 0
		WSA->WSA_AUTORI		:= ""
		WSA->WSA_NSUTEF		:= ""
		WSA->WSA_VLRDEB		:= 0
		WSA->WSA_HORA		:= SubStr(StrTran(cHoraEmis,":",""),1,4)
		WSA->WSA_TXMOED		:= 0
		WSA->WSA_ENDENT		:= Upper(Alltrim(cEndDest)) + " ," + cNumDest
		WSA->WSA_ENDNUM		:= cNumDest
		WSA->WSA_TPFRET		:= cTpFrete
		WSA->WSA_BAIRRE		:= Upper(Alltrim(cBaiDest))
		WSA->WSA_CEPE		:= cCepDest
		WSA->WSA_MUNE		:= Upper(Alltrim(cMunDest))	
		WSA->WSA_ESTE		:= Upper(cEstDest)	
		WSA->WSA_FRETE		:= nVlrFrete
		WSA->WSA_SEGURO		:= 0
		WSA->WSA_DESPES		:= 0
		WSA->WSA_PLIQUI		:= nPesoBruto
		WSA->WSA_PBRUTO		:= nPesoBruto
		WSA->WSA_VOLUME		:= 1 
		WSA->WSA_TRANSP		:= cCodTransp
		WSA->WSA_ESPECI		:= cEspecie
		WSA->WSA_MOEDA		:= 0
		WSA->WSA_BRICMS		:= MaFisRet(,"NF_BASESOL" ) 
		WSA->WSA_ICMSRE		:= MaFisRet(,"NF_VALSOL" )
		WSA->WSA_ABTOPC		:= 0
		WSA->WSA_VALPIS		:= MaFisRet(,'NF_VALPIS')
		WSA->WSA_VALCOF		:= MaFisRet(,'NF_VALCOF')
		WSA->WSA_VALCSL		:= MaFisRet(,'NF_VALCSL')
		WSA->WSA_CGCCLI		:= ""
		WSA->WSA_VALIRR		:= 0
		WSA->WSA_NUMECO		:= cOrderId
		WSA->WSA_NUMECL		:= cPedCodCli
		WSA->WSA_OBSECO		:= cObsPedido
		WSA->WSA_MTCANC		:= cMotCancel
		WSA->WSA_CODSTA		:= WS1->WS1_CODIGO
		WSA->WSA_DESTAT		:= Alltrim(WS1->WS1_DESCRI)
		WSA->WSA_TRACKI		:= ""
		WSA->WSA_VLBXPV		:= "1" 
		WSA->WSA_NOMDES		:= cNomDest
		WSA->WSA_DDDCEL		:= cDddCel
		WSA->WSA_DDD01 		:= cDdd1
		WSA->WSA_CELULA		:= cCelular
		WSA->WSA_TEL01 		:= cTel01
		WSA->WSA_COMPLE		:= cEndComp
		WSA->WSA_REFEN		:= cEndRef 
		WSA->WSA_IDENDE		:= cIdEnd

	WSA->( MsUnLock() )	
			
	RestArea(aArea)
Return aRet

/**************************************************************************************************/
/*/{Protheus.doc} AEcoGrvFin

@description	Grava os titulos financeiro

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			oPayment	, object	, Objeto contendo os dados do pagamento
@param			oRestPv		, object	, Objeto contendo os dados do pedido ecommerce
@param			cNumOrc		, character	, Numero do Or�amento
@param			cOrderId	, character	, Numero do pedido e-Commerce
@param			cPedCodCli  , character	, Numero do pedido Cliente
@param			cHoraEmis	, character	, Hora emissao do pedido
@param			dDtaEmiss	, date		, Data de Emissao do Pedido

@return			aRet - Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro
/*/			
/**************************************************************************************************/
Static Function AEcoGrvFin(oPayment,oRestPv,cNumOrc,cOrderId,cPedCodCli,cHoraEmis,cCodAfili,dDtaEmiss)
	Local aArea		:= GetArea()
	Local aRet		:= {.T.,"",""}
	Local aVencTo	:= {}
	
	Local cTipo		:= ""
	Local cAdmCart	:= ""
	Local cParcela 	:= ""
	Local cCondPg	:= ""
	Local c1DUP     := SuperGetMv("MV_1DUP")	
	Local cOpera	:= ""	
	Local cCodAuto	:= ""
	Local cNsuId	:= ""
	Local cNumCart	:= ""
	Local cRetMsg	:= ""
	Local cSemNsu	:= ""
	Local cTID		:= ""
	Local cCodAdm	:= ""
	Local cPrefixo	:= GetNewPar("EC_PREFIXO","ECO")
		
	Local nVlrParc	:= 0
	Local nTxParc	:= 0
	Local nTran		:= 0
	Local nPay		:= 0
	Local nParc		:= 0
	Local nQtdParc	:= 0
	Local nVlrTotal	:= 0
		
	Local dDtaVencto:= cTod('  /  /    ')	
	
	Local lTaxaCC	:= GetNewPar("EC_ADMFIN",.F.)
	Local lUsaSAE	:= GetNewPar("EC_SAEFIN",.F.)
	Local lGrava 	:= .T.
	
	Local oDadCart	:= Nil
	
	//-----------------------+
	// Operadoras e-Commerce |
	//-----------------------+
	dbSelectArea("WS4")
	WS4->( dbSetOrder(1) )

	For nTran := 1 To Len(oPayMent:Transactions)
		
		If oPayMent:Transactions[nTran]:IsActive
			
			For nPay := 1 To Len(oPayMent:Transactions[nTran]:Payments)
				
				If Len(oPayMent:Transactions[nTran]:Payments) > 1
					cPrefixo := "EC" + Alltrim(Str(nPay))
				EndIf	
				
				//---------------------+
				// Codigo da Operadora |
				//---------------------+
				cOpera 		:= PadL(oPayMent:Transactions[nTran]:Payments[nPay]:PayMentSystem,nTamOper,"0")
				nQtdParc	:= oPayMent:Transactions[nTran]:Payments[nPay]:InstallMents	
				nVlrTotal	:= RetPrcUni(oPayMent:Transactions[nTran]:Payments[nPay]:Value)
				
				//-------------------------------------------+
				// Posiciona Operadora de Pagamento eCommerce|
				//-------------------------------------------+
				If !WS4->( dbSeek(xFilial("WS4") + cOpera ) )
					aRet[1] := .F.
					aRet[2] := cOpera
					aRet[3] := "NAO FOI ENCONTRADA A OPERADORA CADASTRADA NO PROTHEUS. FAVOR CADASTRAR A OPERADORA."
					LogExec("NAO FOI ENCONTRADA A OPERADORA CADASTRADA NO PROTHEUS. FAVOR CADASTRAR A OPERADORA.")
					RestArea(aArea)
					Return aRet
				EndIf
				
				//------------+
				// C. Credito |
				//------------+
				If WS4->WS4_TIPO == "1"
					cTipo 		:= "CC"
					oDadCart	:= oPayMent:Transactions[nTran]:Payments[nPay]
					cSemNsu 	:= FWJsonSerialize(oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses)
					cCodAuto	:= IIF(AT("AUTHID",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Authid,"")
					cNsuId		:= IIF(AT("NSU",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Nsu,"")
					cTID		:= IIF(AT("TID",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Tid,"")
					cNumCart	:= Alltrim(oPayMent:Transactions[nTran]:Payments[nPay]:FirstDigits) + "XXXXXX" + Alltrim(oPayMent:Transactions[nTran]:Payments[nPay]:LastDigits) 
				//--------+	
				// Boleto |
				//--------+
				ElseIf WS4->WS4_TIPO == "2"
					cTipo 		:= "BOL"
					cSemNsu 	:= FWJsonSerialize(oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses)
					cCodAuto	:= IIF(AT("AUTHID",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Authid,"")
					cNsuId		:= IIF(AT("NSU",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Nsu,"")
					cTID		:= IIF(AT("TID",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Tid,"")
				//--------+	
				// Debito | 	
				//--------+
				ElseIf WS4->WS4_TIPO == "3"
					cTipo 		:= "CD"
					oDadCart	:= oPayMent:Transactions[nTran]:Payments[nPay]
					cSemNsu 	:= FWJsonSerialize(oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses)
					cCodAuto	:= IIF(AT("AUTHID",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Authid,"")
					cNsuId		:= IIF(AT("NSU",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Nsu,"")
					cTID		:= IIF(AT("TID",cSemNsu) > 0,oPayMent:Transactions[nTran]:Payments[nPay]:ConnectorResponses:Tid,"")
					cNumCart	:= Alltrim(oPayMent:Transactions[nTran]:Payments[nPay]:FirstDigits) + "XXXXXX" + Alltrim(oPayMent:Transactions[nTran]:Payments[nPay]:LastDigits)
				//--------------+	
				// Market Place |
				//--------------+ 
				ElseIf WS4->WS4_TIPO == "4"
					cTipo 	:= "MKT"
				EndIf
			
				//----------+
				// Grava SE4|
				//----------+
				aRet := AEcoSe4(cOrderId,cTipo,nQtdParc)
			
				If !aRet[1]
					RestArea(aArea)
					Return aRet
				EndIf
				
				//---------------------------------+
				// Codigo da Condi��o de Pagamento |
				//---------------------------------+
				cCondPg := aRet[2]
								
				//-----------------------------+
				// Descri��o da Bandeira usada |
				//-----------------------------+
				cAdmCart := Capital(WS4->WS4_DESCRI)
					
				//----------+
				// Grava SL4|
				//----------+
				aVencTo	:= Condicao(nVlrTotal,cCondPg,,cTod(dDtaEmiss))
				
				//----------------------------------------------+
				// Valida se utiliza Administradora ficnanceira |
				//----------------------------------------------+
				If lTaxaCC .And. WS4->WS4_TIPO == "1"
					aRet := aEcoTxAdm(WS4->WS4_CODADM,Len(aVencTo))
					If aRet[1]
						nTxParc := aRet[2]
						cCodAdm	:= aRet[4]
					Else
						aRet[1] := .F.
						aRet[2] := cOpera
						aRet[3] := "NAO FOI ENCONTRADA TAXA ADMINISTRATIVA PARA A OPERADORA " + cOpera + " - " + cAdmCart + " ."
						LogExec("NAO FOI ENCONTRADA TAXA ADMINISTRATIVA PARA A OPERADORA " + cOpera + " - " + cAdmCart + " .")
						RestArea(aArea)
						Return aRet
					EndIf
				EndIf
				
				dbSelectArea("WSC")
				WSC->( dbSetOrder(1) )
			
				For nParc := 1 To Len(aVencTo)
											
					If WS4->WS4_TIPO == "1"
						cParcela := LJParcela( nParc, c1DUP )
					EndIf
					
					//----------------------------------------------+
					// Valida se utiliza Administradora ficnanceira |
					//----------------------------------------------+
					If lTaxaCC .And. WS4->WS4_TIPO == "1"
						nVlrParc 	:= Round( aVencTo[nParc][2] - ( aVencTo[nParc][2] *  nTxParc / 100 ) , 2 ) 
						dDtaVencto	:= aVencTo[nParc][1]
					Else
						nVlrParc 	:= aVencTo[nParc][2]
						dDtaVencto	:= aVencTo[nParc][1]
					EndIf
					
					RecLock("WSC",.T.)				
						WSC->WSC_FILIAL	:= xFilial("WSC")
						WSC->WSC_NUM    	:= cNumOrc
						WSC->WSC_NUMECO		:= cOrderId
						WSC->WSC_NUMECL		:= cPedCodCli
						WSC->WSC_DATA   	:= dDtaVencto
						WSC->WSC_VALOR  	:= nVlrParc		
						WSC->WSC_FORMA  	:= cTipo
						WSC->WSC_FORMPG		:= cTipo
						WSC->WSC_ADMINI		:= IIF(Empty(cCodAdm),cOpera,cCodAdm)
						WSC->WSC_NUMCAR		:= cNumCart
						WSC->WSC_OBS    	:= cRetMsg
						WSC->WSC_DATATE		:= dTos(cTod(dDtaEmiss))
						WSC->WSC_HORATE		:= StrTran(cHoraEmis,":","")
						WSC->WSC_DOCTEF 	:= cCodAuto
						WSC->WSC_AUTORI		:= cCodAuto
						WSC->WSC_NSUTEF 	:= cNsuId
						WSC->WSC_MOEDA  	:= 1
						WSC->WSC_PARCTE		:= cPrefixo  
						WSC->WSC_ITEM   	:= cParcela    
						WSC->WSC_TID		:= cTID
					WSC->( MsunLock() )
															
				Next nParc
			Next nPay
		EndIf	
	Next nTran
	
	//----------+
	// Grava SE1|
	//----------+
	//aRet := AEcoGrvSe1(cNumOrc,cOrderId,cPedCodCli,cOpera,cPrefixo,cNsuId,dDtaEmiss,Len(aVencTo))
	
	
	RestArea(aArea)
Return aRet

/**************************************************************************************************/
/*/{Protheus.doc} AEcoSe4

@description	Gera condi��o de pagamento

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			cTipo		, Tipo de Pagameto (Cartao,Boleto eEtc)
@param			nQtdParc	, Quantidade de Parcelas

@return			aRet - Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro
/*/			
/**************************************************************************************************/
Static Function AEcoSe4(cOrderId,cTipo,nQtdParc)
	Local aArea		:= GetArea()
	Local aRet		:= {.T.,"",""}
	Local aCond		:= {}

	Local cCodigo	:= ""
	Local cDescri	:= ""
	Local cCondPg	:= ""
	Local cTpCond 	:= "1"

	Private lMsErroAuto := .F.

	//--------------------------+
	// Valida tipo de pagamento |
	//--------------------------+
	If cTipo == "CC"

		cCodigo := "C" + PadL(Alltrim(Str(nQtdParc)),2,"0")	
		cDescri	:= PadL(Alltrim(Str(nQtdParc)),2,"0") + "X. C.CREDITO"
		If nQtdParc > 1
			cCondPg	:= "30," + Alltrim(Str(nQtdParc)) + ",30"
			cTpCond := "5"
		Else
			cCondPg	:= "30"
			cTpCond := "1"
		EndIf

	ElseIf cTipo == "BOL"

		cCodigo := "BOL"	
		cDescri	:= "BOLETO"
		cCondPg	:= GetNewPar("EC_BOLVENC")
		cTpCond := "1"
	
	ElseIf cTipo == "CD"

		cCodigo := "CD1"	
		cDescri	:= "CARTAO DEBITO"
		cCondPg	:= "00"
		cTpCond := "1"
	
	ElseIf cTipo == "MKT"

		cCodigo := "MKT"	
		cDescri	:= "MARKET PLACE"
		cCondPg	:= GetNewPar("EC_MKTVENC","15")
		cTpCond := "1"
		
	EndIf	

	//-----------------------------------------------------+
	// Se j� existe condi��o de pagamento retorna o codigo |
	//-----------------------------------------------------+
	dbSelectArea("SE4")
	SE4->( dbSetOrder(1) )
	If SE4->( dbSeek(xFilial("SE4") + PadR(cCodigo,TamSx3("E4_CODIGO")[1]) ) )
		aRet[1] := .T.
		aRet[2] := SE4->E4_CODIGO
		aRet[3] := ""
		RestArea(aArea)
		Return aRet
	EndIf

	aAdd(aCond,{"E4_FILIAL"	,	xFilial("SE4")							,	Nil })
	aAdd(aCond,{"E4_CODIGO"	,	cCodigo									,	Nil })
	aAdd(aCond,{"E4_DESCRI"	,	cDescri									,	Nil })
	aAdd(aCond,{"E4_TIPO"  	,	cTpCond									,	Nil })
	aAdd(aCond,{"E4_COND"	,	cCondPg									,	Nil })

	//-------------------------------------------------------+
	// Insere condi��o de pagamento especifica do e-Commerce.|
	//-------------------------------------------------------+
	lMsErroAuto := .F.
	MsExecAuto({|x,y,z| Mata360(x,y,z)},aCond,{},3)

	If lMsErroAuto

		cSE4Log	:= "SE4" + cCodigo + DToS(dDataBase)+Left(Time(),2)+SubStr(Time(),4,2)+Right(Time(),2)+".LOG"
		//----------------+
		// Cria diretorio |
		//----------------+ 
		MakeDir("/erros/")
		MostraErro("/erros/",cSE4Log)

		//-------------------------------------------------+
		//�Adiciona Arquivo de log no Retorno da resposta. |
		//-------------------------------------------------+
		cMsgErro := ""
		cLiArq	 := ""
		nHndImp	 := 0	
		nHndImp  := FT_FUSE("/ecommerce/" + cSE4Log)
		If nHndImp >= 1
			//----------------------------+
			// Posiciona Inicio do Arquivo|
			//----------------------------+
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

		//--------------------+
		// Variavel de retorno|
		//--------------------+
		aRet[1] := .F.
		aRet[2]	:= cOrderId
		aRet[3] := cMsgErro 

	Else
		LogExec("PAGAMENTO " + cCodigo + "-" + cDescri + " INSERIDO COM SUCESSO" )
		aRet[1] := .T.
		aRet[2] := cCodigo
		aRet[3]	:= ""
	Endif	

	RestArea(aArea)
Return aRet

/*************************************************************************************
{Protheus.doc} aEcoTxAdm

@description  Retorna taxa administrativa 

@author Bernard M. Margarido
@since 23/08/2016
@version undefined

@param cOpera		, Codigo da Operadora e-Comemrce
@param nParcela		, Numero de parcelas

@type function
*************************************************************************************/
Static Function aEcoTxAdm(cOpera,nParcela,nTipo)
Local aArea		:= GetArea()
Local aRet		:= {.T.,"","",""}

Local nTaxa		:= 0

Local cCodCli	:= ""
Local cCodSAE	:= ""
Local cAlias	:= GetNextAlias()

Local cQuery 	:= ""

Default nTipo	:= 1

cQuery := "	SELECT " + CRLF
cQuery += "		AE.AE_COD, " + CRLF
cQuery += "		AE.AE_TAXA, " + CRLF
cQuery += "		AE.AE_PARCDE, " + CRLF
cQuery += "		AE.AE_PARCATE, " + CRLF
cQuery += "		AE.AE_CODCLI " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "		" + RetSqlName("SAE") + " AE " + CRLF
cQuery += "	WHERE " + CRLF
cQuery += "		AE.AE_FILIAL = '" + xFilial("SAE")  + "' AND " + CRLF 
cQuery += "		AE.AE_COD = '" + cOpera + "' AND " + CRLF 
cQuery += "		AE.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	aRet[1] := .F.
	aRet[2] := ""
	aRet[3] := ""
	aRet[4] := ""
	(cAlias)->( dbCloseArea() ) 
	RestArea(aArea)
	Return aRet
EndIf

While (cAlias)->( !Eof() )
	If nTipo == 1
		If nParcela >= (cAlias)->AE_PARCDE .And. nParcela <= (cAlias)->AE_PARCATE  
			nTaxa 	:= (cAlias)->AE_TAXA
			cCodSAE	:= (cAlias)->AE_COD
			Exit
		EndIf
	Else
		If nParcela >= (cAlias)->AE_PARCDE .And. nParcela <= (cAlias)->AE_PARCATE  
			cCodCli := (cAlias)->AE_CODCLI
			cCodSAE	:= (cAlias)->AE_COD
			Exit
		EndIf
	EndIf	
	(cAlias)->( dbSkip() )
EndDo
	

aRet[1] := .T.
aRet[2] := IIF(nTipo == 1,nTaxa,cCodCli)
aRet[3] := IIF(nTipo == 1,"","01")
aRet[4]	:= cCodSAE
(cAlias)->( dbCloseArea() ) 

RestArea(aArea)
Return aRet

/**************************************************************************************************/

/*/{Protheus.doc} AEcoGrvSe1

@description	Gera contas a receber

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			cNumOrc		, Numero do Or�amento
@param			cOrderId	, Numero do OrderId e-Commerce
@param			cPedCodCli	, Numero do OrderId e-Commerce Cliente
@param			cOpera		, Codigo da Operadora
@param			dDtaEmiss	, Data de Emissao do Pedido e-Commerce
@param			nParcTx		, Numero de parcelas para calcula da Taxa

@return			aRet - Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro
/*/			
/**************************************************************************************************/
Static Function AEcoGrvSe1(cNumOrc,cOrderId,cPedCodCli,cOpera,cPrefixo,cNsuId,dDtaEmiss,nParcTx)
	Local aArea 	:= GetArea()
	Local aRet		:= {.T.,"",""}
	Local aSe1 		:= {}

	Local cMsgErro 	:= ""
	Local cLiArq	:= ""
	Local cCliOper	:= ""
	Local cLojaOper	:= ""
			
	Local nHndImp  	:= 0
	Local nOpcA		:= 0
	
	Local lTaxaCC	:= GetNewPar("EC_ADMFIN",.F.)
	
	Private lMsErroAuto	:= .F.

	//----------------------+
	// Posiciona Or�amento  |
	//----------------------+
	dbSelectArea("WSA")
	WSA->( dbSetOrder(1) )
	WSA->( dbSeek(xFilial("WSA") + cNumOrc) )

	//-------------------------------+
	// Posiciona Condi��o Negociada  |
	//-------------------------------+
	dbSelectArea("WSC")
	WSC->( dbSetOrder(1) )
	If !WSC->( dbSeek(xFilial("WSC") + cNumOrc) )
		aRet[1] := .F.
		aRet[2] := cOrderId
		aRet[3] := "PAGAMENTO NAO ENCONTRADO PARA O PEDIDO ORDERID " + Alltrim(cOrderId) + ". FAVOR INFORMAR O ADMINISTRADOR DO SISTEMA."	
		RestArea(aArea)
		Return aRet
	EndIf
	

	//------------------------+
	// Cria Contas a Receber  |
	//------------------------+
	While WSC->( !Eof() .And. xFilial("WSC") + cNumOrc == WSC->( WSC_FILIAL + WSC_NUM) )

		aSe1 := {}
		
		//----------------------------------------+
		// Caso pagamento tenha mais de um cart�o | 
		//----------------------------------------+
		If Alltrim(WSC->WSC_FORMA) == "CC" .And. Alltrim(cNsuId) <> Alltrim(WSC->WSC_NSUTEF)
		 	WSC->( dbSkip() )
			Loop 
		EndIf
		
		cNumE1	:= PadR(WSC->WSC_NUMECL,nTamTitu)
		cParce	:= PadR(WSC->WSC_ITEM,nTamParc)
		cPrefixo:= WSC->WSC_PARCTEF
		nOpcA 	:= 3
		
		//----------------------------+
		// Valida se j� existe Titulo |
		//----------------------------+		
		If SE1->( dbSeek(xFilial("SE1") + cPrefixo + cNumE1 + cParce ) )
			nOpcA := 4
			WSC->( dbSkip() )
			Loop 
		EndIf
			
		If Alltrim(WSC->WSC_FORMA) == "CC"
			cNatureza := &(SuperGetMV("MV_NATCART"))
			If lTaxaCC
				aRet := aEcoTxAdm(cOpera,nParcTx,2)
				If aRet[1]
					cCliOper	:= aRet[2]
					cLojaOper	:= aRet[3]
				EndIf	
			EndIf
			cCliente  := WSA->WSA_CLIENTE
			cLoja	  := WSA->WSA_LOJA		
		ElseIf Alltrim(WSC->WSC_FORMA) == "CD"
			cNatureza := &(SuperGetMV("MV_NATTEF"))
			cCliente  := WSA->WSA_CLIENTE
			cLoja	  := WSA->WSA_LOJA
		ElseIf Alltrim(WSC->WSC_FORMA) == "BOL"
			cCliente  := WSA->WSA_CLIENTE
			cLoja	  := WSA->WSA_LOJA	
			cNatureza := &(SuperGetMV("MV_NATOUTR"))
			
		ElseIf Alltrim(WSC->WSC_FORMA) == "MKT"
			cCliente  := WSA->WSA_CLIENTE
			cLoja	  := WSA->WSA_LOJA	
			cNatureza := &(SuperGetMV("MV_NATOUTR"))
		EndIf

		If Alltrim(WSC->WSC_FORMA) $ "BOL/FI"
			cHist := "PED: " + cOrderId + " BOLETO"	
		ElseIf Alltrim(WSC->WSC_FORMA) $ "MKT"	
			cHist := "PED: " + cOrderId + " MARKET PLACE"
		Else
			cHist := "PED: " + cOrderId + " CARTAO:" + Upper(WSC->WSC_ADMINIS)
		EndIf
		
		cNatureza := IIF(ValType(cNatureza) == "N", Alltrim(Str(cNatureza)),cNatureza)
		
		aAdd(aSe1,{"E1_FILIAL"			, xFilial("SE1")						  	    					, Nil })				
		aAdd(aSe1,{"E1_PREFIXO"			, cPrefixo								  	    					, Nil })
		aAdd(aSe1,{"E1_TIPO"			, Alltrim(WSC->WSC_FORMA)					    					, Nil })
		aAdd(aSe1,{"E1_NUM"				, Alltrim(WSC->WSC_NUMECL)											, Nil })
		aAdd(aSe1,{"E1_PARCELA"			, Alltrim(WSC->WSC_ITEM)						   						, Nil })
		aAdd(aSe1,{"E1_NATUREZ"			, cNatureza															, Nil })
		aAdd(aSe1,{"E1_CLIENTE"			, IIF(Empty(cCliOper),cCliente,cCliOper)							, Nil })
		aAdd(aSe1,{"E1_LOJA"			, IIF(Empty(cLojaOper),cLoja,cLojaOper)								, Nil })
		aAdd(aSe1,{"E1_VALOR"			, WSC->WSC_VALOR														, Nil })
		aAdd(aSe1,{"E1_EMISSAO"			, cTod(dDtaEmiss)													, Nil })
		aAdd(aSe1,{"E1_VENCTO"			, WSC->WSC_DATA														, Nil })
		aAdd(aSe1,{"E1_VLCRUZ"			, WSC->WSC_VALOR														, Nil })		
		aAdd(aSe1,{"E1_VENCREA"			, DataValida(WSC->WSC_DATA,.T.)        								, Nil })
		aAdd(aSe1,{"E1_XNUMECO"			, cOrderId															, Nil })  
		aAdd(aSe1,{"E1_XNUMECL"			, cPedCodCli														, Nil })  
		aAdd(aSe1,{"E1_ORIGEM"			, "FINA040"															, Nil })  
		aAdd(aSe1,{"E1_STATUS"			, "A"																, Nil })  
		aAdd(aSe1,{"E1_FLUXO"			, "S"																, Nil })  
		aAdd(aSe1,{"E1_VLRREAL"			, WSC->WSC_VALOR														, Nil })  
		aAdd(aSe1,{"E1_DOCTEF" 			, WSC->WSC_DOCTEF													, Nil })
		aAdd(aSe1,{"E1_NSUTEF"			, WSC->WSC_NSUTEF													, Nil })
		aAdd(aSe1,{"E1_HIST"			, cHist																, Nil })
		
		MsExecAuto({|x,y| FINA040(x,y)},aSe1,nOpcA)

		If lMsErroAuto   

			cSE1Log := "SE1" + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".LOG"

			//----------------+
			// Cria diretorio |
			//----------------+ 
			MakeDir("\erros\")
			MostraErro("\erros\",cSE1Log)

			//------------------------------------------------+
			// Adiciona Arquivo de log no Retorno da resposta |
			//------------------------------------------------+
			cMsgErro := ""
			nHndImp  := FT_FUSE("\erros\" + cSE1Log)

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
				FClose(nHndImp)
			EndIf

			aRet[1] := .F.
			aRet[2] := Alltrim(WSC->WSC_XNUMECL)
			aRet[3] := "ERRO AO GERAR CONTAS A RECEBER " + cMsgErro

		Else
			LogExec("TITULO A RECEBER GERADO COM SUCESSO." )
			aRet[1] := .T.
			aRet[2] := ""
			aRet[3] := ""
		EndIf

		WSC->( dbSkip() )

	EndDo

	RestArea(aArea)
Return aRet

/**************************************************************************************************/

/*/{Protheus.doc} AEcoUpdPv

@description	Realiza a atualiza��o dos pedidos e-commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

/*/
/**************************************************************************************************/
Static Function AEcoUpdPv(cOrderId,cOrdPvCli,cNumOrc,cNumDoc,cNumSer,cNumPv,oRestPv)
	Local aArea			:= GetArea()
	Local aRet			:= {.T.,"",""}
	
	Local cVendedor 	:= GetNewPar("EC_VENDECO")
	Local cPedCodCli	:= ""	
	Local cCnpj			:= ""
	Local cDocEco		:= ""
	Local cHoraEmis		:= ""
	Local cNotaDev		:= ""
	Local cPedStatus	:= ""
	Local cTipo			:= "LJ"
	
	Local nQtdParc		:= 0			
	Local nVlrTotal		:= 0
	
	Local lBaixaEco		:= .F.
	Local lEnvStatus	:= .F.
	Local lFatAut		:= GetNewPar("EC_FATAUTO",.F.)
	Local lLiberPv		:= GetNewPar("EC_LIBPVAU",.F.)
			
	Local dDtaEmiss		:= Nil
		
	//------------------+
	// Ajusta variaveis |
	//------------------+
	cCnpj	:= oRestPv:ClientProfileData:Document
	cCnpj 	:= PadR(cCnpj,nTamCnpj)
	cNomeCli:= Alltrim(oRestPv:ClientProfileData:FirstName + " " + oRestPv:ClientProfileData:LastName)	
	
	//-----------------------------------------------+
	// Valida se cliente esta cadastrado no Protheus |
	//-----------------------------------------------+
	dbSelectArea("SA1")
	SA1->( dbSetOrder(3) )
	If !SA1->( dbSeek(xFilial("SA1") + cCnpj) )
		LogExec("CLIENTE " + cNomeCli + " CNPJ/CPF " + cCnpj + " NAO ENCONTRADO. FAVOR REALIZAR A BAIXA DE CLIENTES DO ECOMMERCE.")
		aRet[1] := .F.
		aRet[2] := cCnpj
		aRet[3] := "CLIENTE " + cNomeCli + " CNPJ/CPF " + cCnpj + " NAO ENCONTRADO. FAVOR REALIZAR A BAIXA DE CLIENTES DO ECOMMERCE."
		RestArea(aArea)
		Return aRet
	EndIf
		
	//---------------------------+
	// Valida reserva do produto | 
	//---------------------------+
	dDtaEmiss	:= dToc(sTod(StrTran(SubStr(oRestPv:creationDate,1,10),"-","")))
	cCodCli		:= SA1->A1_COD
	cLojaCli	:= sA1->A1_LOJA
	cVendedor	:= ""
	nDesconto	:= 0
	aRet := AEcoGrvRes(cOrderId,cOrdPvCli,cNumOrc,cCodCli,cLojaCli,cVendedor,nDesconto,dDtaEmiss,oRestPv:Items,oRestPv:ShippingData,oRestPv)
	If !aRet[1]
		RestArea(aArea)
		Return aRet
	EndIf
	//---------------------+
	// Posiciona Or�amento |
	//---------------------+
	dbSelectArea("WSA")	
	WSA->( dbSetOrder(1) )
	WSA->( dbSeek(xFilial("WSA") + cNumOrc) )
	
	//--------------+
	// Dados Pedido |
	//--------------+	
	cPedStatus	:= oRestPv:Status

	//---------------------------+
	// Posiciona Status do Pedido|
	//---------------------------+
	dbSelectArea("WS1")
	WS1->( dbSetOrder(2) )
	If !WS1->( dbSeek(xFilial("WS1") + Padr(cPedStatus,nTamStat)) )
		LogExec("STATUS CODIGO " + Alltrim(cPedStatus) + " NAO LOCALIZADO PARA O PEDIDO ORDERID " + cOrderId + " FAVOR CADASTRAR O STATUS E IMPORTAR O PEDIDO NOVAMENTE.")
		aRet[1] := .F.
		aRet[2] := cOrderId
		aRet[3] := "STATUS CODIGO " + Alltrim(cPedStatus) + " NAO LOCALIZADO PARA O PEDIDO ORDERID " + cOrderId + " FAVOR CADASTRAR O STATUS E IMPORTAR O PEDIDO NOVAMENTE."
		RestArea(aArea)
		Return aRet
	EndIf

	//------------------+
	// Status Cancelado |
	//------------------+
	If WS1->WS1_CODIGO == "008" 
				
		//--------------------------------+
		// Envia status para o e-Commerce |
		//--------------------------------+
		lEnvStatus	:= IIF(WS1->WS1_ENVECO == "S",.T.,.F.)
		lBaixaEco	:= .T.
				
		RecLock("WSA",.F.)
			WSA->WSA_CODSTA	:= WS1->WS1_CODIGO
			WSA->WSA_DESTAT	:= Alltrim(WS1->WS1_DESCRI)
		WSA->( MsUnLock() )	
	
		//----------------------+
		// Pagamento Confirmado |
		//----------------------+
	ElseIf WS1->WS1_CODIGO == "002"
			
		//--------------------------------+
		// Envia status para o e-Commerce |
		//--------------------------------+
		lEnvStatus	:= IIF(WS1->WS1_ENVECO == "S",.T.,.F.)
		lBaixaEco	:= .T.
			
		RecLock("WSA",.F.)
			WSA->WSA_CODSTA	:= WS1->WS1_CODIGO
			WSA->WSA_DESTAT	:= Alltrim(WS1->WS1_DESCRI)
		WSA->( MsUnLock() )
	
	//---------------+
	// Demais Status |
	//---------------+
	Else
		RecLock("WSA",.F.)
			WSA->WSA_CODSTA	:= WS1->WS1_CODIGO
			WSA->WSA_DESTAT	:= Alltrim(WS1->WS1_DESCRI)
		WSA->( MsUnLock() )	
	EndIf

	//------------------------+
	// Grava Status do Pedido |
	//------------------------+
	u_AEcoStaLog(WS1->WS1_CODIGO,cOrderId,cNumOrc,dDataBase,Time())

	//---------------------------+
	// Atualiza status ecommerce |
	//---------------------------+
	If lEnvStatus
		aRet := u_AEcoStat(WSA->WSA_NUM)
	EndIf	

RestArea(aArea)
Return aRet

/*********************************************************************************************************/
/*/{Protheus.doc} AEcoCancPv

@description	Cancela Pedido e-commerce

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			cNumOrc		, Numero do Or�amento 
@param			cOrderId	, Numero OrderId e-Commerce
@param			cOrdPvCli	, Numero do pedido e-commerce cliente	
@param			cNumPv		, Numero do Pedido de Venda

@return			aRet		- Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro  
/*/
/***********************************************************************************************************/
User Function AEcoCancPv(cOrderId,cOrdPvCli,cNumOrc,cNumPv)
	Local aArea		:= GetArea()
	Local aRet		:= {.T.,"",""}
	
	Local cAlias	:= GetNextAlias()
		
	Local lPedido	:= .F.
	Local lTitulo	:= .F.
	/*
	//----------------------------+
	// Valida se j� existe pedido |
	//----------------------------+
	If !aVldCanPv(cAlias,cOrderId)
		lTitulo := .T.
	EndIf
	
	While (cAlias)->( !Eof() )
	
		//---------------------------+
		// Posiciona na filial atual |
		//---------------------------+
		cFilAnt := (cAlias)->C5_FILIAL
		
		//------------------+
		// Posiciona Pedido |
		//------------------+
		SC5->( dbGoTo((cAlias)->RECNOSC5) )
		
		//----------------------------------+
		// Valida se nao existe nota fiscal |
		//----------------------------------+
		If Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_SERIE)
			//-------------------------+
			// Cancela Pedido de Venda |
			//-------------------------+
			aRet := u_aEcoExPv(SC5->C5_NUM)
			
			If aRet[1]	
				//-----------------------------------------+
				// Estorna titulos para o pedido cancelado |
				//-----------------------------------------+
				aRet := u_aEcoExCr(cOrderId,cOrdPvCli,cNumOrc,.F.)
				If !aRet[1]
					RestArea(aArea)
					Return aRet
				EndIf
			EndIf
			
		//-------------------------+	
		// Caso exista nota fiscal |
		//-------------------------+	
		Else
			aRet := u_AEcoTro(SC5->C5_NOTA,SC5->C5_SERIE,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ORCRES)
		EndIf
		
		(cAlias)->( dbSkip() )
		
	EndDo	
			
	//------------------------------------------+
	// Or�amento somente com o titulo a receber |
	//------------------------------------------+
	If lTitulo
		//-----------------------------------------+
		// Estorna titulos para o pedido cancelado |
		//-----------------------------------------+
		aRet := u_aEcoExCr(cOrderId,cOrdPvCli,cNumOrc,lPedido)
		If !aRet[1]
			RestArea(aArea)
			Return aRet
		EndIf
	EndIf
	
	//--------------------+
	// Encerra temporario |
	//--------------------+
	(cAlias)->( dbCloseArea())
	*/		
	RestArea(aArea)
Return aRet

/***********************************************************************************/
/*/{Protheus.doc} aVldCanPv

@description Consulta pedidos ecommerce

@author Bernard M. Margarido
@since 20/03/2017
@version undefined
@param cAlias	, characters, descricao
@type function
/*/
/***********************************************************************************/
Static Function aVldCanPv(cAlias,cOrderId)
Local cQuery := ""

cQuery := "	SELECT 
cQuery += "		C5.C5_FILIAL,
cQuery += "		C5.R_E_C_N_O_ RECNOSC5
cQuery += "	FROM	
cQuery += "		" + RetSqlName("SC5") + " C5 "
cQuery += "	WHERE 
cQuery += "		C5.C5_XNUMECO = '" + cOrderId + "' AND "
cQuery += "		C5.D_E_L_E_T_ = '' "
cQuery += "	ORDER BY C5.C5_FILIAL " 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	Return .F.
EndIf

Return .T.

/*********************************************************************************************************/
/*/{Protheus.doc} AEcoBxTit

@description	Realiza a baixa dos titulos do cart�o 

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@return			aRet		- Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro  
/*/
/********************************************************************************************************/
Static Function AEcoBxTit(cNumTit)
	Local aArea	 		:= GetARea()
	Local aRet			:= {.T.,"",""}
	Local aBaixa		:= {}

	Local cPrefixo		:= GetNewPar("EC_PREFIXO")
	Local cBcoBx		:= GetNewPar("EC_CODBCO")
	Local cAgBx			:= GetNewPar("EC_AGEBCO")
	Local cContaBx		:= GetNewPar("EC_CONBCO")
	
	Local nTitulo		:= 1

	Private lMsErroAuto	:= .F.

	dbSelectArea("SA6")
	SA6->( dbSetOrder(1) )

	dbSelectArea("SE1")
	SE1->( dbSetOrder(1) )
	If SE1->( dbSeek(xFilial("SE1") + cPrefixo + Padr(cNumTit,nTamTitu)) )
		While SE1->( !Eof() .And. xFilial("SE1") + cPrefixo + Padr(cNumTit,nTamTitu) == SE1->( E1_FILIAL + E1_PREFIXO + E1_NUM) )

			If Empty(SE1->E1_BAIXA) .And. SE1->E1_SALDO > 0

				If SA6->( dbSeek(xFilial("SA6") + PadR(cBcoBx,nTamBco) + PadR(cAgBx,nTamAge) + PadR(cContaBx,nTamCon) ) )

					aBaixa := {}

					aAdd( aBaixa, {"E1_FILIAL"		, xFilial("SE1")									, Nil})
					aAdd( aBaixa, {"E1_PREFIXO"		, SE1->E1_PREFIXO									, Nil})
					aAdd( aBaixa, {"E1_NUM"			, SE1->E1_NUM										, Nil})
					aAdd( aBaixa, {"E1_PARCELA" 	, SE1->E1_PARCELA									, Nil})
					aAdd( aBaixa, {"E1_TIPO"		, SE1->E1_TIPO										, Nil})
					aAdd( aBaixa, {"E1_CLIENTE"		, SE1->E1_CLIENTE									, Nil})
					aAdd( aBaixa, {"E1_LOJA"		, SE1->E1_LOJA										, Nil})
					aAdd( aBaixa, {"AUTMOTBX"  		, "NOR"												, Nil})
					aAdd( aBaixa, {"AUTBANCO"  		, SA6->A6_COD										, Nil})
					aAdd( aBaixa, {"AUTAGENCIA"  	, SA6->A6_AGENCIA									, Nil})
					aAdd( aBaixa, {"AUTCONTA"  		, SA6->A6_NUMCON									, Nil})
					aAdd( aBaixa, {"AUTDTBAIXA"		, dDataBase											, Nil})
					aAdd( aBaixa, {"AUTHIST"   		, "BX. ECOMMERCE ORDERID " + Alltrim(SE1->E1_XNUMECO), Nil})
					aAdd( aBaixa, {"AUTDESCONT" 	, 0													, Nil})
					aAdd( aBaixa, {"AUTMULTA"	 	, 0													, Nil})
					aAdd( aBaixa, {"AUTJUROS"		, 0													, Nil})
					aAdd( aBaixa, {"AUTOUTGAS" 		, 0													, Nil})
					aAdd( aBaixa, {"AUTVLRPG"  		, 0    												, Nil})
					aAdd( aBaixa, {"AUTVLRME"  		, 0													, Nil})
					aAdd( aBaixa, {"AUTCHEQUE"  	, ""												, Nil})

					//���������������������������������������������������������Ŀ
					//� Baixa do titulo.                                        �
					//�����������������������������������������������������������
					lMsErroAuto := .F.

					MsExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3)

					If lMsErroAuto

						cSE5Log := "SE5" + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".LOG"

						//��������������Ŀ
						//�Cria diretorio�
						//���������������� 
						MakeDir("/erros/")
						MostraErro("/erros/",cSE5Log)

						//�����������������������������������������������Ŀ
						//�Adiciona Arquivo de log no Retorno da resposta.�
						//�������������������������������������������������
						cMsgErro := ""
						nHndImp  := FT_FUSE("/erros/" + cSE5Log)

						If nHndImp >= 1
							//���������������������������Ŀ
							//�Posiciona Inicio do Arquivo�
							//�����������������������������
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
							FClose(nHndImp)
						EndIf

						aRet[1] := .F.
						aRet[2] := cNumTit
						aRet[3] := cMsgErro

						If nTitulo <= 1
							Exit
						Endif	

					Else

						aRet[1] := .T.
						aRet[2] := ""
						aRet[3] := ""	

					EndIf

					nTitulo++

				EndIf

			EndIf

			SE1->( dbSkip() )

		EndDo
	EndIf

	RestArea(aArea)
Return aRet 

/**************************************************************************************************/
/*/{Protheus.doc} AEcoGrvWs2

@description	Grava Status do Pedido eCommerce

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			cNumOrc		, Numero do Or�amento 
@param			cOrderId	, Numero OrderId e-Commerce	
@param			nPedStatus	, Codigo do Status do Pedido
@param			dDtaEmiss	, Data de Emissao
@param			cHoraEmis	, Hora da Emissao

@return			aRet		- Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro  
/*/
/**************************************************************************************************/
Static Function AEcoGrvWs2(cNumOrc,cOrderId,cPedStatus,dDtaEmiss,cHoraEmis)
	Local aArea		:= GetArea()
	Local aRet		:= {.T.,"",""}

	Local cAlias	:= GetNextAlias()
	Local cStatus	:= ""
	Local cQuery	:= ""

	Local lGrava	:= .T.
	
	//---------------------------+
	// Posiciona Status do Pedido|
	//---------------------------+
	dbSelectArea("WS1")
	WS1->( dbSetOrder(2) )
	If !WS1->( dbSeek(xFilial("WS1") + Padr(Alltrim(cPedStatus),nTamStat)) )
		LogExec("STATUS " + Capital(cPedStatus) + " NAO LOCALIZADO PARA O PEDIDO ORDERID " + cOrderId + " FAVOR CADASTRAR O STATUS E IMPORTAR O PEDIDO NOVAMENTE.")
		aRet[1] := .F.
		aRet[2] := cOrderId
		aRet[3] := "STATUS " + Capital(cPedStatus) + " NAO LOCALIZADO PARA O PEDIDO ORDERID " + cOrderId + " FAVOR CADASTRAR O STATUS E IMPORTAR O PEDIDO NOVAMENTE."
		RestArea(aArea)
		Return aRet
	EndIf
	
	//------------------+
	// Codigo do Status |
	//------------------+
	cStatus := WS1->WS1_CODIGO
	
	cQuery := "	SELECT " + CRLF
	cQuery += "		WS2_CODSTA " + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		" + RetSqlName("WS2") + " " + CRLF 
	cQuery += "	WHERE " + CRLF
	cQuery += "		WS2_FILIAL = '" + xFilial("WS2") + "' AND " + CRLF
	cQuery += "		WS2_NUMSL1 = '" + cNumOrc + "' AND " + CRLF
	cQuery += "		D_E_L_E_T_ = '' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If (cAlias)->( Eof() )
		U_AEcoStaLog(cStatus,cOrderId,cNumOrc,cTod(dDtaEmiss),cHoraEmis)
		(cAlias)->( dbCloseArea() )
	Else
		 (cAlias)->( dbCloseArea() )
	EndIf
	
	RestArea(aArea)
Return aRet

/**************************************************************************************************/
/*/{Protheus.doc} RetPrcUni

@description	Converte para decimal

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			cNumOrc		, Numero do Or�amento 
@param			cOrderId	, Numero OrderId e-Commerce	
@param			nPedStatus	, Codigo do Status do Pedido
@param			dDtaEmiss	, Data de Emissao
@param			cHoraEmis	, Hora da Emissao

@return			aRet		- Array aRet[1] - Logico aRet[2] - Codigo Erro aRet[3] - Descricao do Erro  
/*/
/**************************************************************************************************/
Static Function RetPrcUni(nVlrUnit)
Local nValor	:= 0
/*
If Len(cVlrUnit) == 1
	nDecimal		:= 3
	nValor 			:= Val(Left(Alltrim(Str(nVlrUnit)),Len(cVlrUnit) - nDecimal) + "." + Right(Alltrim(Str(nVlrUnit)),nDecimal))
Else 
	nValor 			:= Val(Left(Alltrim(Str(nVlrUnit)),Len(cVlrUnit) - nDecimal) + "." + Right(Alltrim(Str(nVlrUnit)),nDecimal))
EndIf
*/

nValor := nVlrUnit / 100

Return nValor

/*******************************************************************************/
/*/{Protheus.doc} AEcoI11IP

@description Retorna ID do servi�o de Postagem

@author Bernard M. Margarido
@since 09/02/2017
@version undefined

@param cIdTran	, characters	, ID da Transportadora

@type function
/*/
/*******************************************************************************/
Static Function AEcoI11IP(cIdTran,cCodAfili,cCodTransp,cIdPost)
Local aArea 	:= GetArea() 

If Empty(cIdPost)
	cCodTransp	:= AEcoI11TR(SubStr(cIdTran,1,6))
Else
	cCodTransp	:= GetNewPar("EC_TRANSP","EC0001")
EndIf	

Return .T. 

/***************************************************************/
/*/{Protheus.doc} AEcoI11TR

@description Valida se Transportadora Propria

@author Bernard M. Margarido
@since 08/03/2017
@version undefined

@type function
/*/
/***************************************************************/
Static Function AEcoI11TR(cIdTran)
Local aArea 	:= GetArea() 
Local cAlias	:= GetNextAlias()
Local cQuery 	:= ""
Local cIdPost	:= ""

cQuery := "	SELECT " + CRLF  
cQuery += "		A4.A4_COD " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SA4") + " A4 " + CRLF  
cQuery += "	WHERE " + CRLF 
cQuery += "		A4.A4_FILIAL = '" + xFilial("SA4") + "' AND " + CRLF 
cQuery += "		UPPER(A4.A4_ECSERVI) = '" + Upper(cIdTran) + "' AND " + CRLF
cQuery += "		A4.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	cIdPost	:= ""
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return cIdPost
EndIf

cIdPost := (cAlias)->A4_COD

(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return cIdPost 

/*******************************************************************************************/
/*/{Protheus.doc} aEcoI011Entr

@description Atualiza dados de entrega no cadastro do cliente

@author Bernard M. Margarido
@since 22/06/2018
@version 1.0

@param cCodCli	, characters, descricao
@param cLojaCli	, characters, descricao
@param cNomDest	, characters, descricao
@param cEndDest	, characters, descricao
@param cNumDest	, characters, descricao
@param cBaiDest	, characters, descricao
@param cCepDest	, characters, descricao
@param cMunDest	, characters, descricao
@param cEstDest	, characters, descricao
@type function
/*/
/*******************************************************************************************/
Static Function aEcoI011Entr(	cCodCli,cLojaCli,cNomDest,;
								cEndDest,cNumDest,cBaiDest,;
								cCepDest,cMunDest,cEstDest,cEndComp )
Local aArea		:= GetArea()
Local cCodMune	:= ""
Local cEndVld	:= cEndDest + ", " + cNumDest

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
If !SA1->( dbSeek(xFilial("SA1") + cCodCli + cLojaCli) )
	LogExec("CLIENTE NAO LOCALIZADO PARA ATUALIZA��O DE ENDERE�O DE ENTREGA.")
	RestArea(aArea)
	Return .T.
EndIf

//-------------------------------------------------------------------+
// Mesmo endere�o de entrega e cobran�a atualiza somente complemento |
//-------------------------------------------------------------------+
If Alltrim(SA1->A1_END) == Alltrim(cEndVld)
	//---------------------------+
	// Atualiza dados de entrega |
	//---------------------------+
	RecLock("SA1",.F.)
		SA1->A1_COMPLEM	:= cEndComp
	SA1->( MsUnLock() )	
Else
	//----------------------+
	// Municipio de Entrega | 
	//----------------------+
	cCodMune := EcCodMun(cMunDest,cEstDest)
	
	//---------------------------+
	// Atualiza dados de entrega |
	//---------------------------+
	RecLock("SA1",.F.)
		//------------------+
		// Endere�o Cliente |
		//------------------+
		SA1->A1_CEP		:= cCepDest
		SA1->A1_END		:= cEndDest + ", " + cNumDest
		SA1->A1_BAIRRO	:= cBaiDest
		SA1->A1_MUN		:= cMunDest
		SA1->A1_EST		:= cEstDest
		SA1->A1_COD_MUN	:= cCodMune
		SA1->A1_COMPLEM	:= cEndComp
		
		//------------------+
		// Endere�o Entrega |
		//------------------+
		SA1->A1_CEPE	:= "" //cCepDest
		SA1->A1_ENDENT	:= "" //cEndDest + ", " + cNumDest
		SA1->A1_BAIRROE	:= "" //cBaiDest
		SA1->A1_MUNE	:= "" //cMunDest
		SA1->A1_ESTE	:= "" //cEstDest
		SA1->A1_CODMUNE	:= "" //cCodMune
		
	SA1->( MsUnLock() )
	
EndIf

RestArea(aArea)
Return Nil

/*******************************************************************************************/
/*/{Protheus.doc} AEc011Cont
	@description Grava endere�o de entrega nos contatos
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function AEc011Cont(cCodCli,cLoja,cNomeCli,aEndEnt)
Local _aArea	:= GetArea()

Local _lGrava	:= .T.

Local _cEnd		:= ""
Local _cNumEnd	:= ""
Local _cBairro	:= ""
Local _cMun		:= ""
Local _cCep		:= ""
Local _cEst		:= ""
Local _cCodMun	:= ""
Local _cNumSU5	:= ""
Local _cIdEnd	:= ""
Local _cContato	:= ""

Local _nRecnoSU5:= 0

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1") + cCodCli + cLoja) )

_cEnd		:= aEndEnt[ENDERE]
_cNumEnd	:= aEndEnt[NUMERO]
_cBairro	:= aEndEnt[BAIRRO]
_cMun		:= aEndEnt[MUNICI]	
_cCep		:= aEndEnt[CEP]
_cEst		:= aEndEnt[ESTADO]
_cCodMun	:= aEndEnt[IBGE]
_cIdEnd		:= aEndEnt[IDENDE]
_cContato	:= aEndEnt[CONTAT]

_nRecnoSU5 	:= QryContato(_cCep)
			
//----------------------------+
// Posiciona dados do contato |
//----------------------------+
If _nRecnoSU5 > 0

	SU5->( dbGoTo(_nRecnoSU5) )
	_cNumSU5:= SU5->U5_CODCONT
	_lGrava	:= .F.

Else

	dbSelectArea("SU5")
	SU5->( dbSetOrder(1) )
	_cNumSU5 := GetSxeNum("SU5","U5_CODCONT")
	While SU5->( dbSeek(xFilial("SU5") + _cNumSU5 ) )
		ConfirmSx8()
		_cNumSU5 := GetSxeNum("SU5","U5_CODCONT")
	EndDo
	_lGrava := .T.

EndIf

//------------------+
// Atualiza Contato |
//------------------+	
RecLock("SU5",_lGrava)
	SU5->U5_FILIAL	:= xFilial("SU5")
	SU5->U5_CODCONT := _cNumSU5
	SU5->U5_CONTAT  := RTrim(_cContato)
	SU5->U5_EMAIL   := RTrim(SA1->A1_EMAIL)
	SU5->U5_CPF		:= RTrim(SA1->A1_CGC)
	SU5->U5_END		:= _cEnd + ", " + _cNumEnd
	SU5->U5_BAIRRO	:= _cBairro
	SU5->U5_MUN		:= _cMun
	SU5->U5_EST		:= _cEst
	SU5->U5_CEP		:= _cCep
	SU5->U5_DDD		:= RTrim(SA1->A1_DDD)
	SU5->U5_FONE	:= RTrim(SA1->A1_TEL)
	SU5->U5_CELULAR := RTrim(SA1->A1_TEL)
	SU5->U5_ATIVO	:= "1"
	SU5->U5_STATUS	:= "2"
	SU5->U5_XIDEND	:= _cIdEnd
	SU5->U5_MSBLQL	:= "2"
SU5->(MsUnLock())

//-----------------------------+
// Amarra��o Contato X Cliente |
//-----------------------------+
dbSelectArea("AC8")
AC8->( dbSetOrder(1) )
If !AC8->( dbSeek(xFilial("AC8") + _cNumSU5 + "SA1" + xFilial("SA1") + cCodCli + cLoja ) )
	RecLock("AC8",.T.)
		AC8->AC8_FILIAL := xFilial("AC8")
		AC8->AC8_FILENT	:= xFilial("SA1")
		AC8->AC8_ENTIDA := "SA1"
		AC8->AC8_CODENT	:= cCodCli + cLoja
		AC8->AC8_CODCON	:= _cNumSU5
	AC8->( MsUnLock() )	
EndIf 
		
//-------------------+
// Atualiza Endere�o |
// Entrega			 |
//-------------------+	
aEcI10AGA(_cNumSU5,aEndEnt)


RestArea(_aArea)
Return Nil

/*******************************************************************************************/
/*/{Protheus.doc} QryContato
	@description Valida se j� existe contato salvo
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function QryContato(_cCep)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local nRecno := 0		

cQuery := "	SELECT " + CRLF
cQuery += "		U5.R_E_C_N_O_ RECNOSU5 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SU5") + " U5 " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		U5.U5_FILIAL = '" + xFilial("SU5") + "' AND " + CRLF
cQuery += "		U5.U5_CEP = '" + _cCep + "' AND " + CRLF
cQuery += "		U5.D_E_L_E_T_ = '' " + CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

nRecno := (cAlias)->RECNOSU5 

(cAlias)->( dbCloseArea() )

Return nRecno

/*******************************************************************************************/
/*/{Protheus.doc} aEcI10AGA
	@description Grava dados de entrega AGA
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function aEcI10AGA(_cNumSU5,aEndEnt)
Local _aArea	:= GetARea()

Local _cCodEnd	:= ""
Local _cEnd		:= ""
Local _cNumEnd	:= ""
Local _cBairro	:= ""
Local _cMun		:= ""
Local _cCep		:= ""
Local _cEst		:= ""
Local _cCodMun	:= ""
Local _cIdEnd	:= ""

Local _lGrava	:= .F.

_cEnd		:= aEndEnt[ENDERE]
_cNumEnd	:= aEndEnt[NUMERO]
_cBairro	:= aEndEnt[BAIRRO]
_cMun		:= aEndEnt[MUNICI]	
_cCep		:= aEndEnt[CEP]
_cEst		:= aEndEnt[ESTADO]
_cCodMun	:= aEndEnt[IBGE]
_cIdEnd		:= aEndEnt[IDENDE]

//---------------------------+
// Valida se existe endere�o |
//---------------------------+
_lGrava := AEcoVldAga(_cIdEnd)

If _lGrava
	_cCodEnd := GetSxeNum("AGA","AGA_CODIGO")
	While AGA->( dbSeek(xFilial("AGA") + _cCodEnd ) )
		ConfirmSx8()
		_cCodEnd := GetSxeNum("AGA","AGA_CODIGO")
	EndDo
	RecLock("AGA", _lGrava)
		AGA->AGA_FILIAL := xFilial("AGA")
		AGA->AGA_CODIGO	:= _cCodEnd
		AGA->AGA_ENTIDA	:= "SU5"					
		AGA->AGA_CODENT	:= _cNumSU5
		AGA->AGA_XIDEND	:= _cIdEnd
		AGA->AGA_TIPO 	:= "2"
		AGA->AGA_PADRAO	:= "1"
		AGA->AGA_END	:= _cEnd + ", " + _cNumEnd
		AGA->AGA_BAIRRO	:= _cBairro
		AGA->AGA_MUNDES	:= _cMun
		AGA->AGA_MUN    := _cCodMun
		AGA->AGA_EST	:= _cEst
		AGA->AGA_CEP	:= _cCep
		AGA->AGA_PAIS	:= "105"  
	AGA->(MsUnLock())
EndIf	
	
Return Nil

/*******************************************************************************************/
/*/{Protheus.doc} AEcoVldAga
	@description Valida se endere�o j� est� cadastrado 
	@type  Static Function
	@author Bernard M. Margarido
	@since 27/05/2019
/*/
/*******************************************************************************************/
Static Function AEcoVldAga(_cIdEnd)
Local _aArea 	:= GetArea()

Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""

Local _lRet		:= .T.

_cQuery	:= " SELECT " + CRLF 
_cQuery	+= "	AGA.AGA_CODIGO " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= "	" + RetSqlName("AGA") + " AGA " + CRLF 
_cQuery	+= " WHERE " + CRLF
_cQuery	+= "	AGA.AGA_FILIAL = '" + xFilial("AGA") + "' AND " + CRLF 
_cQuery	+= "	AGA.AGA_XIDEND = '" + _cIdEnd + "' AND " + CRLF
_cQuery	+= "	AGA.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If !Empty((_cAlias)->AGA_CODIGO)
	_lRet := .F.
EndIf

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return _lRet 

/*******************************************************************************************/
/*/{Protheus.doc} LogExec
	@description Grava log 
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return 