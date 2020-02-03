#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³S011A04   ³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 28/11/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WebService para integração com sistema Força de Vendas       ³±±
±±³          ³ Protheus x SIM3G (Wealthsystems)                             ³±±
±±³          ³ - IMPORTACAO DE ORÇAMENTO - VENDA ASSISTIDA: IncluirOrcamento³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TOTVS CASCAVEL                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

WSSTRUCT MsgRetOrc
	WSDATA c01TpMensagem    	As String	// Tipos: ERRO, VLD, INFO	?
	WSDATA c02Produto       	As String
	WSDATA n03Mensagem      	As String
ENDWSSTRUCT  

WSSTRUCT RetStatOrc
    WSDATA StatusVendaAssistida	As String
	WSDATA aMensagem     		As Array of MsgRetOrc
ENDWSSTRUCT

WSSERVICE WSSIM3G_VENDA_ASSISTIDA   DESCRIPTION "Integracao Forca de Vendas SIM3G - Importacao de Orçamentos do Venda Assistida"
	
	WSDATA INVendaAssistida		As INVendaAssistida
	WSDATA INLogin  			As String Optional	// Chave de acesso em Base64 (usuario:senha)
	WSDATA RetStatus		 	As RetStatus   
	
	WSMETHOD IncluirVendaAssistida	DESCRIPTION "Inclui um novo Orçamento do Venda Assistida no ERP"
	
ENDWSSERVICE



//******************************************************************************
// Função para gerar uma mensagem no Console do Server
Static Function GeraLog(cTxt,cTit)

Default cTxt	:= ""
Default cTit 	:= ""

If ! Empty(cTxt)
	If ! Empty(cTit)
		cTxt := Upper(Alltrim(cTit)) +" "+ Alltrim(cTxt)
	Endif
	CONOUT( "[WSSIM3G "+ DTOC(Date()) +" "+ Time() +"] "+ FwNoAccent(cTxt) )
Endif

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IncluirPed³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 28/11/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para incluir um Orçamento Venda Assistida             ³±±
±±³          ³ Rotina padrão: LOJA701 tabelas SL1/SL2                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TOTVS CASCAVEL                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSSTRUCT INVendaAssistida
	WSDATA LQ_FILIAL 			As String
	WSDATA LQ_NUM				As String   // Nr. da Venda Protheus
	WSDATA LQ_X_PVSIM 			As String   // Nr. da Venda SIM3G
	WSDATA LQ_VEND     			As String	// Vendedor
	WSDATA LQ_COMIS 			As Float	// Comissao
	WSDATA LQ_CLIENTE    		As String	// Cliente
	WSDATA LQ_LOJA 				As String   // Loja Cliente
	WSDATA LQ_TIPOCLI 			As String   // Tipo do Cliente
	WSDATA LQ_DESCONT  			As Float    // Desconto Cabeçalho
	WSDATA LQ_DTLIM  			As Date     // Data Limite Orçamento
	WSDATA LQ_EMISSAO  			As Date     // Data emissao
	WSDATA LQ_CONDPG 			As String   // Condição Pagamento
	WSDATA LQ_NUMMOV 			As String   // Movimento do dia
	WSDATA LOCAL_ENTREGA		As String   // Local de Entrega
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
	WSDATA aItens      			As Array of ItemVendaAssistida  
	WSDATA aForma				As Array of FormaPagamentoVenda
	
ENDWSSTRUCT

WSSTRUCT ItemVendaAssistida
	WSDATA LR_PRODUTO			As String	// Codigo Produto (SB1)
	WSDATA LR_QUANT  			As Float	// Quant. Venda
	WSDATA LR_VRUNIT 			As Float	// Valor do Item
	WSDATA LR_VLRITEM 			As Float	// Valor do Item	
	WSDATA LR_UM 	 			As String	// Unidade Medida
	WSDATA LR_DESC  			As Float	// Percentual de Desconto
	WSDATA LR_VALDESC  			As Float	// Valor Desconto
	WSDATA LR_TABELA     		As String	// Tabela de Preço
	WSDATA LR_DESCPRO     		As Float	// Desconto proporcional
	WSDATA LR_VEND 				As Float	// Vendedor
	WSDATA LR_LOTECTL 			As String	// LOTECTL
	WSDATA LR_LOCALIZ 			As String	// LOCALIZ
	WSDATA LR_NLOTE				As String	// Sub-Lote
	WSDATA LR_LOCAL				As String	// Local
	WSDATA LR_LOJARES 			As String	// Loja reserva
	WSDATA LR_FILRES 			As String	// Filial reserva
	WSDATA LR_ENTREGA 			As String	// Entrega
	WSDATA LR_CLIENT			As String   // Cliente de Entrega
	WSDATA LR_CLILOJA			As String   // Loja Cliente de Entrega
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT

WSSTRUCT FormaPagamentoVenda
	WSDATA L4_DATA  			As Date	    // Data
	WSDATA L4_VALOR 			As Float    // Valor
	WSDATA L4_FORMA  			As String   // Forma Pagamento
	WSDATA L4_ADMINIS      		As String	// Administradoras 
	WSDATA L4_NUMCART  			As String	// Numero cartao credito/debito
	//WSDATA L4_FORMAID    		As String	// ID Cartao
	WSDATA L4_MOEDA 			As Integer    // Moeda
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT

WSMETHOD IncluirVendaAssistida WSRECEIVE INVendaAssistida, INLogin WSSEND RetStatus WSSERVICE WSSIM3G_VENDA_ASSISTIDA

Local aMsg  		:= {}
Local lLinux 		:= ("LINUX" $ Upper(GetSrvInfo()[2]))
Local cPath 		:= "\logsim3g"+ IF(lLinux,"/","\")	// Pasta abaixo da Protheus_Data para gravar os LOGS
Local cFile 		:= ""
Local cErro 		:= ""
Local _nI    		:= 0
Local lPedExist		:= .F.
Local cNumOrc 		:= ""
Local cNumSIM3G		:= ""
Local cOldFil		:= cFilAnt
Local nOldMod		:= 0
Local aDadosPE		:= {}
Local cCampo 		:= ""
Local xValor		:= nil
Local i
Local bRet			:= .T.
Local bEntrg 		:= .F.

Private aCabec	 	:= {}
Private aItensSLR	:= {}
Private aItensSL4	:= {}
Private aItem   	:= {}
Private aParc		:= {}
Private nTotOrc		:= 0

Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private INCLUI := .T. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
Private ALTERA := .F. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão

GeraLog("INICIO","IncluirVendaAssistida")

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

If ! ExistDir("\logsim3g")
	MakeDir("\logsim3g")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo obrigatório FILIAL ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(Self:INVendaAssistida:LQ_FILIAL)
	aAdd(aMsg,{"P","LQ_FILIAL","Codigo da Filial nao informado"})
Else
	cFilAnt := Self:INVendaAssistida:LQ_FILIAL
	If ! FWFilExist()
		aAdd(aMsg,{"P","LQ_FILIAL","Filial nao cadastrada: "+ cFilAnt })
	Else
		GeraLog("Empresa/Filial: "+ cEmpAnt +"/"+ cFilAnt,"IncluirVendaAssistida")
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida campos NUM.VENDA e VENDA SIM3G                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumOrc    := PADR(AllTrim(::INVendaAssistida:LQ_NUM    ), TamSX3("LQ_NUM"    )[1])
cNumSIM3G  := PADR(AllTrim(::INVendaAssistida:LQ_X_PVSIM), TamSX3("LQ_X_PVSIM")[1])
If Empty(cNumSIM3G)
	aAdd(aMsg,{"P","LQ_X_PVSIM","Campo obrigatorio nao informado"})
EndIf
GeraLog("Numero Venda SIM3G: "+ cNumSIM3G,"IncluirVendaAssistida")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o Orçamento já foi importado - Campo de controle                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SL1")
If !Empty(cNumOrc)
	dbSetOrder(1)	// FILIAL + VENDA
	If dbSeek( xFilial("Sl1") + cNumOrc )
		aAdd(aMsg,{"P","LQ_NUM","Orçamento de Venda ja existe: "+ AllTrim(cNumOrc) })
		lPedExist := .T.
	Endif
Else
	dbOrderNickName("SL1PVSIM3G")	// FILIAL + PV.SIM3G
	If dbSeek( xFilial("SL1") + cNumSIM3G )
		aAdd(aMsg,{"P","LQ_X_PVSIM","Venda ja existe: "+ AllTrim(cNumSIM3G) })
		lPedExist := .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida os ITENS do Venda                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(::INVendaAssistida:aItens) == 0
	aAdd(aMsg,{"P","aItens","Não há itens no orçamento"})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para validação específica antes de continuar           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PES011A4")
	If ! ExecBlock("PES011A4",.F.,.F., { "VLDANTES", @::INVendaAssistida, @aMsg })
		//Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se há mensagens de erro retorna Status e aborta                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aMsg) > 0
	Return( GeraStatus("N",@aMsg,@::RetStatus) )
Endif

If !Empty(::INVendaAssistida:LQ_CLIENTE)
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(MsSeek(xFilial("SA1")+PADR(AllTrim(::INVendaAssistida:LQ_CLIENTE), TamSX3("LQ_CLIENTE")[1])+PADR(AllTrim(::INVendaAssistida:LQ_LOJA), TamSX3("LQ_LOJA")[1])))
Endif


If !Empty(::INVendaAssistida:LQ_VEND)
	SA3->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SA3->(MsSeek(xFilial("SA3")+PADR(AllTrim(::INVendaAssistida:LQ_VEND), TamSX3("A3_COD")[1])))
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara o CABEÇALHO do Orçamento                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCabec := {}
aAdd(aCabec, {"LQ_FILIAL"     , XFILIAL("SLQ")	 													, Nil})	// Filial ERP
	
If !Empty(cNumOrc)
	aAdd(aCabec, {"LQ_NUM"     , cNumOrc	 													, Nil})	// Numero ERP
Endif
If !Empty(cNumSIM3G)
	aAdd(aCabec, {"LQ_X_PVSIM" , cNumSIM3G 														, Nil}) // Número do Venda no SIM3G
Endif
If !Empty(::INVendaAssistida:LQ_VEND)
	aAdd(aCabec, {"LQ_VEND"   , PADR(AllTrim(::INVendaAssistida:LQ_VEND), TamSX3("A3_COD")[1])   		, Nil}) // Vendedor
Endif
If !Empty(::INVendaAssistida:LQ_CLIENTE)
	aAdd(aCabec, {"LQ_CLIENTE", PADR(AllTrim(::INVendaAssistida:LQ_CLIENTE), TamSX3("LQ_CLIENTE")[1])							       			, Nil})	// Cliente
Endif
If !Empty(::INVendaAssistida:LQ_LOJA)
	aAdd(aCabec, {"LQ_LOJA", PADR(AllTrim(::INVendaAssistida:LQ_LOJA), TamSX3("LQ_LOJA")[1]) 	, Nil}) // Loja do cliente
Endif
If !Empty(::INVendaAssistida:LQ_TIPOCLI)
	aAdd(aCabec, {"LQ_TIPOCLI", PADR(AllTrim(::INVendaAssistida:LQ_TIPOCLI), TamSX3("LQ_TIPOCLI")[1]) 	, Nil}) // Tipo do cliente
Endif
If !Empty(::INVendaAssistida:LQ_DESCONT)
	aAdd(aCabec, {"LQ_DESCONT" ,  ::INVendaAssistida:LQ_DESCONT 		, Nil}) // Desconto
Endif
If !Empty(::INVendaAssistida:LQ_DTLIM)
	aAdd(aCabec, {"LQ_DTLIM" , ::INVendaAssistida:LQ_DTLIM		, Nil}) // Data Limite Orcamento
Endif
If !Empty(::INVendaAssistida:LQ_EMISSAO)
	aAdd(aCabec, {"LQ_EMISSAO", ::INVendaAssistida:LQ_EMISSAO	, Nil}) // Data Emissao
Endif
If !Empty(::INVendaAssistida:LQ_CONDPG)
	aAdd(aCabec, {"LQ_CONDPG", PADR(AllTrim(::INVendaAssistida:LQ_CONDPG), TamSX3("LQ_CONDPG")[1])	, Nil}) // Condicao de pagamento
Endif
If !Empty(::INVendaAssistida:LQ_NUMMOV)
	aAdd(aCabec, {"LQ_NUMMOV", PADR(AllTrim(::INVendaAssistida:LQ_NUMMOV), TamSX3("LQ_NUMMOV")[1])	, Nil}) // Movimento do dia
Endif

//aAdd(aCabec, {"LQ_TIPO", PADR(AllTrim("V"), TamSX3("LQ_TIPO")[1])	, Nil}) // Movimento do dia
aAdd(aCabec, {"LQ_NUMMOV", PADR(AllTrim("01"), TamSX3("LQ_NUMMOV")[1])	, Nil}) // Movimento do dia
aAdd(aCabec, {"LQ_ORIGEM", PADR(AllTrim("V"), TamSX3("LQ_ORIGEM")[1])	, Nil}) // Movimento do dia


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona campos específicos na SC5 vindos do SIM3G                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to Len(::INVendaAssistida:CAMPOS_ESPEC)
	if ! empty(::INVendaAssistida:CAMPOS_ESPEC[i]:CAMPO)
		cCampo := Alltrim( Self:INVendaAssistida:CAMPOS_ESPEC[i]:CAMPO )
		xValor := AllTrim( Self:INVendaAssistida:CAMPOS_ESPEC[i]:VALOR )
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek(cCampo))
			Do Case
				Case SX3->X3_TIPO == "N"
					xValor := Val(xValor)
					
				Case SX3->X3_TIPO == "D"  
					xValor := STOD( Substr(xValor,1,4) + Substr(xValor,6,2) + Substr(xValor,9,2) )
					
				Case SX3->X3_TIPO == "L"
					xValor := (Upper(xValor) $ "TRUE/T/SIM/S/V") 
					
			EndCase
			aAdd(aCabec, { cCampo, xValor, Nil})
		Else
			aAdd(aMsg,{"P","INVENDAASSISTIDA","Campo especifico nao existe: "+ cCampo })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	endif
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para tratamento complementar sobre o vetor aCabec      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PES011A4")
	aDadosPE := ExecBlock("PES011A4",.F.,.F., { "ACABEC", @aCabec, @::INVendaAssistida })
	If Valtype(aDadosPE) == 'A'
		aCabec := aClone(aDadosPE)
		aDadosPE := nil
	EndIf
Endif

aCabec := FWVetByDic( aCabec, "SLQ" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara os ITENS do Orçamento                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aItensSLR := {}
nTotOrc   := 0

For _nI := 1 to len(::INVendaAssistida:aItens)
	If !Empty(::INVendaAssistida:aItens[_nI]:LR_PRODUTO)
		aItem  := {}
		
		aAdd(aItem, {"LR_ITEM"    , StrZero( _nI, TamSX3("LR_ITEM")[1] )											,NIL} )
		If !Empty(::INVendaAssistida:aItens[_nI]:LR_PRODUTO)
			aAdd(aItem, {"LR_PRODUTO" , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_PRODUTO), TamSX3("LR_PRODUTO")[1])	,NIL} )
		Endif
	
		If !Empty(::INVendaAssistida:aItens[_nI]:LR_UM)
			aAdd(aItem, {"LR_UM"  , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_UM), TamSX3("LR_UM")[1])	,NIL} )
		Endif
	
		If ::INVendaAssistida:aItens[_nI]:LR_QUANT >= 0
			aAdd(aItem, {"LR_QUANT"  , ::INVendaAssistida:aItens[_nI]:LR_QUANT     										,NIL} )
		Endif

		If ::INVendaAssistida:aItens[_nI]:LR_VRUNIT >= 0
			aAdd(aItem, {"LR_VRUNIT"  , ::INVendaAssistida:aItens[_nI]:LR_VRUNIT     										,NIL} )
		Endif
		
		If ::INVendaAssistida:aItens[_nI]:LR_VLRITEM >= 0
			aAdd(aItem, {"LR_VLRITEM"  , ::INVendaAssistida:aItens[_nI]:LR_VLRITEM     										,NIL} )
		Endif

		If ::INVendaAssistida:aItens[_nI]:LR_DESC >= 0
			aAdd(aItem, {"LR_DESC"  , ::INVendaAssistida:aItens[_nI]:LR_DESC 											,NIL} )
		Endif
	
		If ::INVendaAssistida:aItens[_nI]:LR_VALDESC >= 0
			aAdd(aItem, {"LR_VALDESC"  , ::INVendaAssistida:aItens[_nI]:LR_VALDESC 											,NIL} )
		Endif
	
		If !Empty(::INVendaAssistida:aItens[_nI]:LR_TABELA)
			aAdd(aItem, {"LR_TABELA"    , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_TABELA), TamSX3("LR_TABELA")[1])   		,NIL} )
		Endif
	
		If ::INVendaAssistida:aItens[_nI]:LR_DESCPRO >= 0
			aAdd(aItem, {"LR_DESCPRO"     , ::INVendaAssistida:aItens[_nI]:LR_DESCPRO   		,NIL} )
		Endif
		
		If !Empty(::INVendaAssistida:aItens[_nI]:LR_VEND)
			aAdd(aItem, {"LR_VEND"    , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_VEND), TamSX3("LR_VEND")[1])   		,NIL} )
		Endif

		aAdd(aItem, {"LR_LOCAL"    , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_LOCAL), TamSX3("LR_LOCAL")[1])   		,NIL} )
		
		If !Empty(::INVendaAssistida:aItens[_nI]:LR_LOTECTL)
			aAdd(aItem, {"LR_LOTECTL"    , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_LOTECTL), TamSX3("LR_LOTECTL")[1])   		,NIL} )
			aAdd(aItem, {"LR_NLOTE"      , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_NLOTE), TamSX3("LR_NLOTE")[1])   		,NIL} )
			aAdd(aItem, {"LR_LOCALIZ"    , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_LOCALIZ), TamSX3("LR_LOCALIZ")[1])   		,NIL} )
		Endif


/*		If !Empty(::INVendaAssistida:aItens[_nI]:LR_LOJARES)
			aAdd(aItem, {"LR_LOJARES"    , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_LOJARES), TamSX3("LR_LOJARES")[1])   		,NIL} )
			CONOUT("::INVendaAssistida:aItens[_nI]:LR_LOJARES: "+::INVendaAssistida:aItens[_nI]:LR_LOJARES)
		Endif
		
		If !Empty(::INVendaAssistida:aItens[_nI]:LR_FILRES)
			aAdd(aItem, {"LR_FILRES"    , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_FILRES), TamSX3("LR_FILRES")[1])   		,NIL} )
			CONOUT("::INVendaAssistida:aItens[_nI]:LR_FILRES: "+::INVendaAssistida:aItens[_nI]:LR_FILRES)
		Endif */
				
		If !Empty(::INVendaAssistida:aItens[_nI]:LR_ENTREGA)
			aAdd(aItem, {"LR_ENTREGA"    , PADR(AllTrim(::INVendaAssistida:aItens[_nI]:LR_ENTREGA), TamSX3("LR_ENTREGA")[1])   		,NIL} )
			If AllTrim(::INVendaAssistida:aItens[_nI]:LR_ENTREGA) $ "1/3" //RETIRA
				bEntrg := .T. //Caso entrega = 1, precisa ativar opção no execauto
			EndiF
		Endif
		
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona campos específicos na SLR vindos do SIM3G                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i := 1 to Len(::INVendaAssistida:aItens[_nI]:CAMPOS_ESPEC)
			if ! empty(::INVendaAssistida:aItens[_nI]:CAMPOS_ESPEC[i]:CAMPO)
				cCampo := Alltrim( Self:INVendaAssistida:aItens[_nI]:CAMPOS_ESPEC[i]:CAMPO )
				xValor := AllTrim( Self:INVendaAssistida:aItens[_nI]:CAMPOS_ESPEC[i]:VALOR )
				SX3->(dbSetOrder(2))
				If SX3->(dbSeek(cCampo))
					Do Case
						Case SX3->X3_TIPO == "N"
							xValor := Val(xValor)
							
						Case SX3->X3_TIPO == "D" 
							xValor := STOD( Substr(xValor,1,4) + Substr(xValor,6,2) + Substr(xValor,9,2) )
							
						Case SX3->X3_TIPO == "L"
							xValor := (Upper(xValor) $ "TRUE/T/SIM/S/V") 
							
					EndCase
					aAdd(aItem, { cCampo, xValor, Nil})
				Else
					aAdd(aMsg,{"P","aITENS","Campo especifico nao existe: "+ cCampo })
					Return( GeraStatus("N",@aMsg,@::RetStatus) )
				Endif
			endif
		Next i
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para tratamento complementar sobre o vetor aItensSLR   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PES011A4")
			aDadosPE := ExecBlock("PES011A4",.F.,.F., { "AITEM", @aItem, @::INVendaAssistida:aItens[_nI] })
			If Valtype(aDadosPE) == 'A'
				aItem := aClone(aDadosPE)
				aDadosPE := nil
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ordena os campos conforme sequencia do SX3                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//aItem := FWVetByDic( aItem, "SLR" )
		
		aAdd(aItensSLR, aItem)
	EndIf
Next _nI

//Atualiza cabeçalho apos identificar entrega nos itens
If bEntrg
	CONOUT("######## AUTORESERVA #######")
	If !Empty(::INVendaAssistida:LOCAL_ENTREGA)
		aAdd( aCabec, {"LQ_RESERVA", "S"	, Nil}) // Ativa Reserva
		aAdd( aCabec, {"AUTRESERVA" , PADR(AllTrim(::INVendaAssistida:LOCAL_ENTREGA), TamSX3("LR_LOJARES")[1]) , NIL} ) 
		CONOUT("::INVendaAssistida:LOCAL_ENTREGA: "+::INVendaAssistida:LOCAL_ENTREGA )
	EndIf
	//Codigo da Loja (Campo SLJ->LJ_CODIGO) que deseja efetuar a reserva quando existir item(s) que for do tipo entrega (LR_ENTREGA = 3)
EndIf

//************************************************
// Monta o Pagamento do orçamento (aPagtos) (SL4)
//************************************************
For _nI := 1 to len(::INVendaAssistida:aForma)

	aParc  := {}

	If ::INVendaAssistida:aForma[_nI]:L4_VALOR > 0

		If !Empty(::INVendaAssistida:aForma[_nI]:L4_DATA)
			aAdd(aParc, {"L4_DATA" , ::INVendaAssistida:aForma[_nI]:L4_DATA	,NIL} )
		Endif
	
		If ::INVendaAssistida:aForma[_nI]:L4_VALOR > 0 
			aAdd(aParc, {"L4_VALOR"  , ::INVendaAssistida:aForma[_nI]:L4_VALOR 	,NIL} )
		Endif
	
		If !Empty(::INVendaAssistida:aForma[_nI]:L4_FORMA)
			aAdd(aParc, {"L4_FORMA" , AllTrim(::INVendaAssistida:aForma[_nI]:L4_FORMA)	,NIL} )
		Endif

		If !Empty(::INVendaAssistida:aForma[_nI]:L4_NUMCART)
			aAdd(aParc, {"L4_NUMCART" , PADR(AllTrim(::INVendaAssistida:aForma[_nI]:L4_NUMCART), TamSX3("L4_NUMCART")[1])	,NIL} )
		Else
			aAdd(aParc, {"L4_NUMCART" , " "	,NIL} )
		Endif	
			
		If !Empty(::INVendaAssistida:aForma[_nI]:L4_ADMINIS)
			aAdd(aParc, {"L4_ADMINIS" , PADR(AllTrim(::INVendaAssistida:aForma[_nI]:L4_ADMINIS), TamSX3("L4_ADMINIS")[1])	,NIL} )
		Else
			aAdd(aParc, {"L4_ADMINIS" , " "	,NIL} )
		Endif	
		
		If ::INVendaAssistida:aForma[_nI]:L4_MOEDA > 0
			aAdd(aParc, {"L4_MOEDA" , ::INVendaAssistida:aForma[_nI]:L4_MOEDA	,NIL} )
		Else
			aAdd(aParc, {"L4_MOEDA" , 0	,NIL} ) //Real
		Endif
		
		aAdd(aParc, {"L4_FORMAID" , " "	,NIL} )
	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona campos específicos na SL4 vindos do SIM3G                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i := 1 to Len(::INVendaAssistida:aForma[_nI]:CAMPOS_ESPEC)
			if ! empty(::INVendaAssistida:aForma[_nI]:CAMPOS_ESPEC[i]:CAMPO)
				cCampo := Alltrim( Self:INVendaAssistida:aForma[_nI]:CAMPOS_ESPEC[i]:CAMPO )
				xValor := AllTrim( Self:INVendaAssistida:aForma[_nI]:CAMPOS_ESPEC[i]:VALOR )
				SX3->(dbSetOrder(2))
				If SX3->(dbSeek(cCampo))
					Do Case
						Case SX3->X3_TIPO == "N"
							xValor := Val(xValor)
							
						Case SX3->X3_TIPO == "D" 
							xValor := STOD( Substr(xValor,1,4) + Substr(xValor,6,2) + Substr(xValor,9,2) )
							
						Case SX3->X3_TIPO == "L"
							xValor := (Upper(xValor) $ "TRUE/T/SIM/S/V") 
							
					EndCase
					aAdd(aItem, { cCampo, xValor, Nil})
				Else
					aAdd(aMsg,{"P","aITENS","Campo especifico nao existe: "+ cCampo })
					Return( GeraStatus("N",@aMsg,@::RetStatus) )
				Endif
			endif
		Next i
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para tratamento complementar sobre o vetor aItensSLR   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PES011A4")
			aDadosPE := ExecBlock("PES011A4",.F.,.F., { "AFORMA", @aForma, @::INVendaAssistida:aForma[_nI] })
			If Valtype(aDadosPE) == 'A'
				aItem := aClone(aDadosPE)
				aDadosPE := nil
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ordena os campos conforme sequencia do SX3                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParc := FWVetByDic( aParc, "SL4" )
		
		aAdd(aItensSL4, aParc)
	EndIf
Next _nI


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada antes do MsExecAuto de inclusão da Venda              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PES011A4")
	Private cMsgVldPE := ""
	Private aCabecPE := aCabec
	Private aItensPE := aItensSLR
	Private aFormaPE := aItensSL4
	
	If ExecBlock("PES011A4",.F.,.F., { "ANTESVENDA", @aCabec, @aItensSLR, @aItensSL4 })
		aCabec    := aCabecPE
		aItensSLR := aItensPE
		aItensSL4 := aFormaPE
	Else
		If ValType(cMsgVldPE) == "C" .and. ! Empty(cMsgVldPE)
			aAdd(aMsg, { "P","ANTESVENDA", cMsgVldPE })
		Else
			aAdd(aMsg, { "P","ANTESVENDA", "Inclusao da Venda abortada via ponto de entrada PES011A4." })
		Endif
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a rotina de INCLUSAO do orçamento pelo venda assistida          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa rotina automatica de inclusao da venda de venda LOJA710         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMsErroAuto := .F.
	cUserName := "CAIXA"
	nModulo := 05
	SetFunName("LOJA701")
	
	MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aCabec,aItensSLR ,aItensSL4 )
		
	cErro := ""
	
	If ! lMsErroAuto
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna STATUS da importação - SUCESSO                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aMsg,{"S",SL1->L1_NUM,"Venda incluida com sucesso! Numero ERP: "+ SL1->L1_NUM })
		GeraStatus("S",@aMsg,@::RetStatus)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada após a gravação da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PES011A4")
			ExecBlock("PES011A4",.F.,.F., { "APOSVENDA", SL1->L1_NUM })
		Endif
	Else
		DisarmTransaction()
    	cFile := "IncluirVendaAssistida_"+ AllTrim(cNumSIM3G) +".log"
		MostraErro(cPath,cFile)
		cErro := MemoRead(cPath + cFile)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna STATUS da importação - ERRO                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aMsg,{"P","Venda: "+ AllTrim(cNumSIM3G),"MSExecAuto Loja701: "+ cErro})
		GeraStatus("N",@aMsg,@::RetStatus)
		bRet := .T. // Deve retornar .T. mesmo em caso de erro
	EndIf

End Transaction

GeraLog("FIM","IncluirVendaAssistida")

Return bRet



//******************************************************************************
// Retorna STATUS da importação - SUCESSO/ERRO
Static Function GeraStatus(cSucesso,aMsg,RetStatus)

Local _nI
Local cStatus := IF(cSucesso=="S","SUCESSO","ERRO")

RetStatus:StatusPedido := cSucesso

aSort(aMsg,,,{|x,y| x[1]+x[2] <= y[1]+y[2]})
For _nI := 1 to len(aMsg)
	aAdd(RetStatus:aMensagem,WSClassNew("MsgRetOrc"))
	RetStatus:aMensagem[_nI]:c01TpMensagem := aMsg[_nI,1]
	RetStatus:aMensagem[_nI]:c02Produto    := aMsg[_nI,2]
	RetStatus:aMensagem[_nI]:n03Mensagem   := aMsg[_nI,3]
	
	GeraLog(cStatus + " "+ AllTrim(aMsg[_nI,2]) +" "+ AllTrim(aMsg[_nI,3]) )
Next

Return(.T.)





