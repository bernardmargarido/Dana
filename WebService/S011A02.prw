#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³S011A02   ³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 29/01/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WebService para integração com sistema Força de Vendas       ³±±
±±³          ³ Protheus x SIM3G (Wealthsystems)                             ³±±
±±³          ³ - IMPORTACAO DE PEDIDOS: IncluirPedido                       ³±±
±±³          ³ - IMPORTACAO DE CONTRATO DE PARCERIA: IncluirCntParceria     ³±±
±±³          ³ - IMPORTACAO DE CLIENTE: IncluirCliente                      ³±±
±±³          ³ - IMPORTACAO DE CONTATO: IncluirContato                      ³±±
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
/*
WSSTRUCT EstrutRetCamposEspec
	WSDATA CAMPO AS STRING
	WSDATA VALOR AS STRING
ENDWSSTRUCT
*/
WSSTRUCT ItemPedido
	WSDATA C6_PRODUTO			As String	// Codigo Produto (SB1)
	WSDATA C6_QTDVEN 			As Float	// Quant. Venda
	WSDATA C6_PRUNIT 			As Float	// Preco de Venda Unitario
	WSDATA C6_PRCVEN 			As Float	// Preco de Venda
	WSDATA C6_UNSVEN 			As Float	// Quant. Venda 2a UM
	WSDATA C6_OPER    			As String	// Codigo TES Inteligente
	WSDATA C6_TES    			As String	// Codigo TES (opcional)
	WSDATA C6_DESCONT			As Float	// Perc. Desconto Item
	WSDATA C6_VALDESC			As Float	// Valor Desconto Item
	WSDATA C6_ENTREG 			As Date 	// Data Entrega do Item
	WSDATA C6_PEDCLI  			As String	// Nr. Pedido do Cliente
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT

WSSTRUCT INPedido
	WSDATA C5_FILIAL 			As String
	WSDATA C5_NUM    			As String	// Nr. Pedido Protheus
	WSDATA C5_X_PVSIM			As String	// Nr. Pedido SIM3G
	WSDATA C5_TIPO   			As String	// Tipos: N=Normal, D=Devolucao
	WSDATA C5_CLIENTE			As String
	WSDATA C5_LOJACLI			As String
	WSDATA C5_TRANSP 			As String
	WSDATA C5_REDESP 			As String
	WSDATA C5_TIPOCLI 			As String
	WSDATA C5_CONDPAG			As String
	WSDATA C5_TABELA 			As String
	WSDATA C5_VEND1  			As String
	WSDATA C5_MENNOTA			As String
	WSDATA C5_TPFRETE			As String	// Tipo de Frete: C/F/???
	WSDATA C5_EMISSAO			As Date 	// Data de Emissao
	WSDATA C5_FECENT 			As Date 	// Data de Entrega
	WSDATA C5_DESC1  			As Float	// Perc. Desconto Pedido
	WSDATA C5_DESCFI 			As Float	// Perc. Desconto Financeiro
	WSDATA C5_ACRSFIN			As Float
	WSDATA C5_FRETE  			As Float 
	WSDATA C5_SEGURO  			As Float 
	WSDATA C5_DESPESA			As Float 
	WSDATA C5_FRETAUT			As Float 
	WSDATA C5_PESOL   			As Float 
	WSDATA C5_PBRUTO 			As Float 
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
	WSDATA aItens      			As Array of ItemPedido  
	
ENDWSSTRUCT

WSSTRUCT MsgRetorno
	WSDATA c01TpMensagem    	As String	// Tipos: ERRO, VLD, INFO	?
	WSDATA c02Produto       	As String
	WSDATA n03Mensagem      	As String
ENDWSSTRUCT  

WSSTRUCT RetStatus
    WSDATA StatusPedido 		As String
	WSDATA aMensagem     		As Array of MsgRetorno
ENDWSSTRUCT


WSSERVICE WSSIM3G_PEDIDOVENDA   DESCRIPTION "Integracao Forca de Vendas SIM3G - Importacao de Pedidos de Venda"
	
	WSDATA INPedido				As INPedido 
	WSDATA INParceria			As INParceria 
	WSDATA INCliente			As INCliente 
	WSDATA INContato			As INContato
	WSDATA RetStatus		 	As RetStatus   
	
	WSMETHOD IncluirPedido 		DESCRIPTION "Inclui o Pedido de Venda gerado pelo SIM3G como Pedido de Venda no ERP"
//	WSMETHOD IncluirOrcamento	DESCRIPTION "Inclui o Pedido de Venda gerado pelo SIM3G como Orcamento de Venda no ERP"	// IMPLEMENTACAO FUTURA
//	WSMETHOD IncluirPrePedido	DESCRIPTION "Inclui o Pedido de Venda gerado pelo SIM3G como Pré-Pedido no ERP"			// IMPLEMENTACAO FUTURA
	WSMETHOD IncluirCntParceria	DESCRIPTION "Inclui um Contrato de Parceria no ERP"
	WSMETHOD IncluirCliente 	DESCRIPTION "Inclui um novo cadastro de Cliente no ERP"
	WSMETHOD IncluirContato 	DESCRIPTION "Inclui um novo cadastro de Contato vinculado a um Cliente"
	
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



WSMETHOD IncluirPedido WSRECEIVE INPedido WSSEND RetStatus WSSERVICE WSSIM3G_PEDIDOVENDA

Local aMsg  		:= {}
Local lLinux 		:= ("LINUX" $ Upper(GetSrvInfo()[2]))
Local cPath 		:= "\logsim3g"+ IF(lLinux,"/","\")	// Pasta abaixo da Protheus_Data para gravar os LOGS
Local cFile 		:= ""
Local cErro 		:= ""
Local _nI    		:= 0
Local lPedExist		:= .F.
Local cNumPedido	:= ""
Local cNumSIM3G		:= ""
Local cOldFil		:= cFilAnt
Local nOldMod		:= 0
Local aDadosPE		:= {}
Local cCampo 		:= ""
Local xValor		:= nil
Local i
Local bRet			:= .T.

Local nHandle		:= 0
Local _cArqLck		:= ""

Private aCabec	 	:= {}
Private aItensSC6	:= {}
Private aItem   	:= {}

GeraLog("INICIO","IncluirPedido")

If !ExistDir("\logsim3g")
	MakeDir("\logsim3g")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo obrigatório FILIAL ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(Self:INPedido:C5_FILIAL)
	aAdd(aMsg,{"P","C5_FILIAL","Codigo da Filial nao informado"})
Else
	cFilAnt := Self:INPedido:C5_FILIAL
	If ! FWFilExist()
		aAdd(aMsg,{"P","C5_FILIAL","Filial nao cadastrada: "+ cFilAnt })
	Else
		GeraLog("Empresa/Filial: "+ cEmpAnt +"/"+ cFilAnt,"IncluirCntParceria")
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida campos NUM.PEDIDO e PEDIDO SIM3G                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cNumPedido := PADR(AllTrim(::INPedido:C5_NUM    ), TamSX3("C5_NUM"    )[1])
cNumSIM3G  := PADR(AllTrim(::INPedido:C5_X_PVSIM), TamSX3("C5_X_PVSIM")[1])
If Empty(cNumSIM3G)
	aAdd(aMsg,{"P","C5_X_PVSIM","Campo obrigatorio nao informado"})
EndIf
GeraLog("Numero Pedido SIM3G: "+ cNumSIM3G,"IncluirPedido")

//-------------------------------------------+
// Trava registro para não haver duplicidade | 
//-------------------------------------------+
If !S011A02LCK(cNumSIM3G,1,@nHandle,@_cArqLck)
	aAdd(aMsg,{"P","C5_X_PVSIM","Pedido está em processo de gravação."})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o PEDIDO já foi importado - Campo de controle                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If !Empty(cNumPedido)
	dbSetOrder(1)	// FILIAL + PEDIDO
	If dbSeek( xFilial("SC5") + cNumPedido )
		aAdd(aMsg,{"P","C5_NUM","Pedido de Venda ja existe: "+ AllTrim(cNumPedido) })
		lPedExist := .T.
	Endif
Else
	dbOrderNickName("SC5PVSIM3G")	// FILIAL + PV.SIM3G
	If dbSeek( xFilial("SC5") + cNumSIM3G )
		aAdd(aMsg,{"P","C5_X_PVSIM","Pedido de Venda ja existe: "+ AllTrim(cNumSIM3G) })
		lPedExist := .T.
	Endif
Endif
*/
/*
If lPedExist
	//Return( GeraStatus("N",@aMsg,@::RetStatus) )
EndIf
*/

dbSelectArea("SC5")
SC5->( dbOrderNickName("SC5PVSIM3G") )	// FILIAL + PV.SIM3G
If SC5->( dbSeek( xFilial("SC5") + cNumSIM3G ) )
	aAdd(aMsg,{"P","C5_X_PVSIM","Pedido de Venda ja existe: "+ AllTrim(cNumSIM3G) })
	lPedExist := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida os ITENS do pedido                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(::INPedido:aItens) == 0
	aAdd(aMsg,{"P","aItens","Não há itens no pedido"})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para validação específica antes de continuar           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PES011A2")
	If ! ExecBlock("PES011A2",.F.,.F., { "VLDANTES", @::INPedido, @aMsg })
		//Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se há mensagens de erro retorna Status e aborta                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aMsg) > 0
	S011A02LCK(cNumSIM3G,2,@nHandle,@_cArqLck)
	Return( GeraStatus("N",@aMsg,@::RetStatus) )
Endif

//--------------------------------------+
// Retorna numeração do pedido de venda |
//--------------------------------------+
S011A02NPV(@cNumPedido)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara o CABEÇALHO do Pedido                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCabec := {}
If !Empty(cNumPedido)
	aAdd(aCabec, {"C5_NUM"     , cNumPedido 													, Nil})	// Numero ERP
Endif
If !Empty(cNumSIM3G)
	aAdd(aCabec, {"C5_X_PVSIM" , cNumSIM3G 														, Nil}) // Número do pedido no SIM3G
Endif
If !Empty(::INPedido:C5_TIPO)
	aAdd(aCabec, {"C5_TIPO"   , PADR(AllTrim(::INPedido:C5_TIPO), TamSX3("C5_TIPO")[1])   		, Nil}) // Tipo do pedido
Endif
If !Empty(::INPedido:C5_EMISSAO)
	aAdd(aCabec, {"C5_EMISSAO", ::INPedido:C5_EMISSAO							       			, Nil})	// Data de emissao
Endif
If !Empty(::INPedido:C5_CLIENTE)
	aAdd(aCabec, {"C5_CLIENTE", PADR(AllTrim(::INPedido:C5_CLIENTE), TamSX3("C5_CLIENTE")[1]) 	, Nil}) // Codigo do cliente
Endif
If !Empty(::INPedido:C5_LOJACLI)
	aAdd(aCabec, {"C5_LOJACLI", PADR(AllTrim(::INPedido:C5_LOJACLI), TamSX3("C5_LOJACLI")[1]) 	, Nil}) // Loja do cliente
Endif
If !Empty(::INPedido:C5_TRANSP)
	aAdd(aCabec, {"C5_TRANSP" , PADR(AllTrim(::INPedido:C5_TRANSP), TamSX3("C5_TRANSP")[1])		, Nil}) // Transportadora
Endif
If !Empty(::INPedido:C5_REDESP)
	aAdd(aCabec, {"C5_REDESP" , PADR(AllTrim(::INPedido:C5_REDESP), TamSX3("C5_REDESP")[1])		, Nil}) // Redespacho
Endif
If !Empty(::INPedido:C5_TIPOCLI)
	aAdd(aCabec, {"C5_TIPOCLI", PADR(AllTrim(::INPedido:C5_TIPOCLI), TamSX3("C5_TIPOCLI")[1])	, Nil}) // Tipo do Cliente
Endif
If !Empty(::INPedido:C5_CONDPAG)
	aAdd(aCabec, {"C5_CONDPAG", PADR(AllTrim(::INPedido:C5_CONDPAG), TamSX3("C5_CONDPAG")[1])	, Nil}) // Condicao de pagamento
Endif
If !Empty(::INPedido:C5_VEND1)
	aAdd(aCabec, {"C5_VEND1"  , PADR(AllTrim(::INPedido:C5_VEND1), TamSX3("C5_VEND1")[1])		, Nil}) // Codigo do vendedor
Endif
If !Empty(::INPedido:C5_TABELA)
	aAdd(aCabec, {"C5_TABELA" , PADR(AllTrim(::INPedido:C5_TABELA), TamSX3("C5_TABELA")[1])		, Nil}) // Tabela de Preço
Endif
If !Empty(::INPedido:C5_DESC1)
	aAdd(aCabec, {"C5_DESC1"  , ::INPedido:C5_DESC1									     		, Nil})	// Desconto
Endif
If !Empty(::INPedido:C5_FECENT)
	aAdd(aCabec, {"C5_FECENT" , ::INPedido:C5_FECENT									       	, Nil}) // Data de entrega Pedido
Endif
If !Empty(::INPedido:C5_MENNOTA)
	aAdd(aCabec, {"C5_MENNOTA" , PADR(AllTrim(::INPedido:C5_MENNOTA), TamSX3("C5_MENNOTA")[1])	, Nil}) // Mensagem p/ Nota
Endif
If !Empty(::INPedido:C5_TPFRETE)
	aAdd(aCabec, {"C5_TPFRETE" , PADR(AllTrim(::INPedido:C5_TPFRETE), TamSX3("C5_TPFRETE")[1])	, Nil}) // Tipo de Frete
Endif
If !Empty(::INPedido:C5_DESCFI)
	aAdd(aCabec, {"C5_DESCFI"  , ::INPedido:C5_DESCFI									     	, Nil})	// Desconto Financeiro
Endif
If !Empty(::INPedido:C5_ACRSFIN)
	aAdd(aCabec, {"C5_ACRSFIN" , ::INPedido:C5_ACRSFIN									     	, Nil})	// Acrescimo Financeiro
Endif
If !Empty(::INPedido:C5_FRETE)
	aAdd(aCabec, {"C5_FRETE"   , ::INPedido:C5_FRETE									     	, Nil})	// Frete
Endif
If !Empty(::INPedido:C5_SEGURO)
	aAdd(aCabec, {"C5_SEGURO"  , ::INPedido:C5_SEGURO									     	, Nil})	// Seguro
Endif
If !Empty(::INPedido:C5_DESPESA)
	aAdd(aCabec, {"C5_DESPESA" , ::INPedido:C5_DESPESA							     			, Nil})	// Despesas
Endif
If !Empty(::INPedido:C5_FRETAUT)
	aAdd(aCabec, {"C5_FRETAUT" , ::INPedido:C5_FRETAUT									     	, Nil})	// Frete autonomo
Endif
If !Empty(::INPedido:C5_PESOL)
	aAdd(aCabec, {"C5_PESOL"   , ::INPedido:C5_PESOL									     	, Nil})	// Peso Liquido
Endif
If !Empty(::INPedido:C5_PBRUTO)
	aAdd(aCabec, {"C5_PBRUTO"  , ::INPedido:C5_PBRUTO									     	, Nil})	// Peso Bruto
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona campos específicos na SC5 vindos do SIM3G                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to Len(::INPedido:CAMPOS_ESPEC)
	if ! empty(::INPedido:CAMPOS_ESPEC[i]:CAMPO)
		cCampo := Alltrim( Self:INPedido:CAMPOS_ESPEC[i]:CAMPO )
		xValor := AllTrim( Self:INPedido:CAMPOS_ESPEC[i]:VALOR )
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek(cCampo))
			Do Case
				Case SX3->X3_TIPO == "N"
					xValor := Val(xValor)
					
				Case SX3->X3_TIPO == "D" // 2018-12-01
					xValor := STOD( Substr(xValor,1,4) + Substr(xValor,6,2) + Substr(xValor,9,2) )
					
				Case SX3->X3_TIPO == "L"
					xValor := (Upper(xValor) $ "TRUE/T/SIM/S/V") 
					
			EndCase
			aAdd(aCabec, { cCampo, xValor, Nil})
		Else
			aAdd(aMsg,{"P","INPEDIDO","Campo especifico nao existe: "+ cCampo })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	endif
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para tratamento complementar sobre o vetor aCabec      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PES011A2")
	aDadosPE := ExecBlock("PES011A2",.F.,.F., { "ACABEC", @aCabec, @::INPedido })
	If Valtype(aDadosPE) == 'A'
		aCabec := aClone(aDadosPE)
		aDadosPE := nil
	EndIf
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena os campos conforme sequencia do SX3                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aCabec := FWVetByDic( aCabec, "SC5" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara os ITENS do Pedido                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aItensSC6 := {}
For _nI := 1 to len(::INPedido:aItens)
	aItem  := {}
	
	aAdd(aItem, {"C6_ITEM"    , StrZero( _nI, TamSX3("C6_ITEM")[1] )											,NIL} )
	
	If !Empty(::INPedido:aItens[_nI]:C6_PRODUTO)
		aAdd(aItem, {"C6_PRODUTO" , PADR(AllTrim(::INPedido:aItens[_nI]:C6_PRODUTO), TamSX3("C6_PRODUTO")[1])	,NIL} )
	Endif
	If ::INPedido:aItens[_nI]:C6_QTDVEN > 0
		aAdd(aItem, {"C6_QTDVEN"  , ::INPedido:aItens[_nI]:C6_QTDVEN     										,NIL} )
	Endif
	If ::INPedido:aItens[_nI]:C6_PRUNIT > 0
		aAdd(aItem, {"C6_PRUNIT"  , ::INPedido:aItens[_nI]:C6_PRUNIT 											,NIL} )
	Endif
	If ::INPedido:aItens[_nI]:C6_PRCVEN > 0
		aAdd(aItem, {"C6_PRCVEN"  , ::INPedido:aItens[_nI]:C6_PRCVEN 											,NIL} )
	Endif
	If ::INPedido:aItens[_nI]:C6_UNSVEN > 0
		aAdd(aItem, {"C6_UNSVEN"  , ::INPedido:aItens[_nI]:C6_UNSVEN 											,NIL} )
	Endif
	If !Empty(::INPedido:aItens[_nI]:C6_OPER)
		aAdd(aItem, {"C6_OPER"    , PADR(AllTrim(::INPedido:aItens[_nI]:C6_OPER), TamSX3("C6_OPER")[1])   		,NIL} )
	Endif
	If !Empty(::INPedido:aItens[_nI]:C6_TES)
		aAdd(aItem, {"C6_TES"     , PADR(AllTrim(::INPedido:aItens[_nI]:C6_TES), TamSX3("C6_TES")[1])   		,NIL} )
	Endif
	If ::INPedido:aItens[_nI]:C6_DESCONT > 0
		aAdd(aItem, {"C6_DESCONT" , ::INPedido:aItens[_nI]:C6_DESCONT											,NIL} )
	Endif
	If ::INPedido:aItens[_nI]:C6_VALDESC > 0
		aAdd(aItem, {"C6_VALDESC" , ::INPedido:aItens[_nI]:C6_VALDESC											,NIL} )
	Endif
	If !Empty(::INPedido:aItens[_nI]:C6_ENTREG)
		aAdd(aItem, {"C6_ENTREG"  , ::INPedido:aItens[_nI]:C6_ENTREG 											,NIL} )
	Endif
	If !Empty(::INPedido:aItens[_nI]:C6_PEDCLI)
		aAdd(aItem, {"C6_PEDCLI"  , ::INPedido:aItens[_nI]:C6_PEDCLI 											,NIL} )
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona campos específicos na SC6 vindos do SIM3G                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 to Len(::INPedido:aItens[_nI]:CAMPOS_ESPEC)
		if ! empty(::INPedido:aItens[_nI]:CAMPOS_ESPEC[i]:CAMPO)
			cCampo := Alltrim( Self:INPedido:aItens[_nI]:CAMPOS_ESPEC[i]:CAMPO )
			xValor := AllTrim( Self:INPedido:aItens[_nI]:CAMPOS_ESPEC[i]:VALOR )
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek(cCampo))
				Do Case
					Case SX3->X3_TIPO == "N"
						xValor := Val(xValor)
						
					Case SX3->X3_TIPO == "D" // 2018-12-01
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
	//³Ponto de Entrada para tratamento complementar sobre o vetor aItensSC6   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PES011A2")
		aDadosPE := ExecBlock("PES011A2",.F.,.F., { "AITEM", @aItem, @::INPedido:aItens[_nI] })
		If Valtype(aDadosPE) == 'A'
			aItem := aClone(aDadosPE)
			aDadosPE := nil
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordena os campos conforme sequencia do SX3                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aItem := FWVetByDic( aItem, "SC6" )
	
	aAdd(aItensSC6, aItem)
Next _nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada antes do MsExecAuto de inclusão do pedido              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PES011A2")
	Private cMsgVldPE := ""
	Private aCabecPE := aCabec
	Private aItensPE := aItensSC6
	If ExecBlock("PES011A2",.F.,.F., { "ANTESPEDIDO", @aCabec, @aItensSC6 })
		aCabec    := aCabecPE
		aItensSC6 := aItensPE
	Else
		If ValType(cMsgVldPE) == "C" .and. ! Empty(cMsgVldPE)
			aAdd(aMsg, { "P","ANTESPEDIDO", cMsgVldPE })
		Else
			aAdd(aMsg, { "P","ANTESPEDIDO", "Inclusao de pedido abortada via ponto de entrada PES011A2." })
		Endif
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a rotina de INCLUSAO do pedido de venda                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa rotina automatica de inclusao do pedido de venda MATA410        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMsErroAuto := .F.
	nModulo := 5
	MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItensSC6,3)	// INCLUSAO DE PEDIDO
	cErro := ""
	
	If ! lMsErroAuto
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna STATUS da importação - SUCESSO                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aMsg,{"S",SC5->C5_NUM,"Pedido incluido com sucesso! Numero ERP: "+ SC5->C5_NUM })
		GeraStatus("S",@aMsg,@::RetStatus)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada após a gravação do pedido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PES011A2")
			ExecBlock("PES011A2",.F.,.F., { "APOSPEDIDO", SC5->C5_FILIAL,SC5->C5_NUM })
		Endif
	Else
		//DisarmTransaction()
    	cFile := "IncluirPedido_"+ AllTrim(cNumSIM3G) +".log"
		MostraErro(cPath,cFile)
		cErro := MemoRead(cPath + cFile)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna STATUS da importação - ERRO                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aMsg,{"P","Pedido: "+ AllTrim(cNumSIM3G),"MSExecAuto MATA410: "+ cErro})
		GeraStatus("N",@aMsg,@::RetStatus)
		bRet := .T. // Deve retornar .T. mesmo em caso de erro
	EndIf

//End Transaction

//----------------+
// Deleta arquivo |
//----------------+
S011A02LCK(cNumSIM3G,2,nHandle,_cArqLck)

GeraLog("FIM","IncluirPedido")

Return bRet

/******************************************************************************/
/*/{Protheus.doc} S011A02NPV

@description Numero Pedido de Venda

@since 07/02/2019
@version 1.0
@type function
/*/
/******************************************************************************/
Static Function S011A02NPV(cNumPedido)
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cQuery	:= ""

cQuery := "	SELECT " + CRLF
cQuery += "		MAX(C5_NUM) PEDIDO " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SC5") + " " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		C5_FILIAL = '" + xFilial("SC5") + "' AND " + CRLF 
cQuery += "		LEN(C5_NUM) = 6 " + CRLF 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

cNumPedido := Soma1((cAlias)->PEDIDO)

(cAlias)->( dbCloseArea() )
	
/*
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
cNumPedido := GetSxeNum("SC5","C5_NUM")

While SC5->( dbSeek(xFilial("SC5") + cNumPedido) )
	ConfirmSx8()
	cNumPedido:= GetSxeNum("SC5","C5_NUM","",1)
EndDo 
*/

RestArea(aArea)
Return .T.

/******************************************************************************/
/*/{Protheus.doc} S011A02LCK

@description Cria semaforo pedido 

@since 07/02/2019
@version 1.0
@param nTipo, numeric, descricao
@type function
/*/
/******************************************************************************/
Static Function S011A02LCK(cNumSIM3G,nTipo,nHandle,_cArqLck)
Local _cDirSmf 	:= GetPathSemaforo()
Local lRet		:= .T.

MakeDir(_cDirSmf)
//---------------+
// Cria semaforo | 
//---------------+
If nTipo == 1
	_cArqLck := _cDirSmf + "S011A02" + cFilAnt + RTrim(cNumSIM3G) + ".LCK"
	If File(_cArqLck)
		lRet := .F.
		GeraLog("Arquivo " + _cArqLck + " em uso.","IncluirPedido")
	Else
		If ( nHandle := FCreate(_cArqLck)) < 0
			lRet := .F.
			GeraLog("Erro ao criar arquivo " + _cArqLck + " .","IncluirPedido")
		EndIf
	EndIf
//-----------------+	
// Exclui semaforo |
//-----------------+	
ElseIf nTipo == 2
	FClose(nHandle)
	FErase(_cArqLck)
	GeraLog("Arquivo deletado com sucesso. " + _cArqLck + " .","IncluirPedido")
EndIf
Return lRet

//******************************************************************************
// Retorna STATUS da importação - SUCESSO/ERRO
Static Function GeraStatus(cSucesso,aMsg,RetStatus)

Local _nI
Local cStatus := IF(cSucesso=="S","SUCESSO","ERRO")

RetStatus:StatusPedido := cSucesso

aSort(aMsg,,,{|x,y| x[1]+x[2] <= y[1]+y[2]})
For _nI := 1 to len(aMsg)
	aAdd(RetStatus:aMensagem,WSClassNew("MsgRetorno"))
	RetStatus:aMensagem[_nI]:c01TpMensagem := aMsg[_nI,1]
	RetStatus:aMensagem[_nI]:c02Produto    := aMsg[_nI,2]
	RetStatus:aMensagem[_nI]:n03Mensagem   := aMsg[_nI,3]
	
	GeraLog(cStatus + " "+ AllTrim(aMsg[_nI,2]) +" "+ AllTrim(aMsg[_nI,3]) )
Next

Return(.T.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IncluirCnt³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 12/09/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para incluir o cadastro do Contrato de Parceria       ³±±
±±³          ³ Rotina padrão: FATA400 tabelas ADA/ADB                       ³±±
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
WSSTRUCT ItemParceria
	WSDATA ADB_CODPRO   		As String	// Obrigatório
	WSDATA ADB_DESPRO   		As String	// Opcional, pode editar
	WSDATA ADB_QUANT    		As Float	// Obrigatório
	WSDATA ADB_PRCVEN   		As Float	// Obrigatório
	WSDATA ADB_PRUNIT    		As Float	// Opcional
	WSDATA ADB_TES       		As String	// Obrigatório
	WSDATA ADB_TESCOB   		As String	// Opcional
	WSDATA ADB_LOCAL    		As String	// Obrigatório, vem do produto
	WSDATA ADB_DESC     		As Float	// Opcional
	WSDATA ADB_VALDES   		As Float	// Opcional
	WSDATA ADB_CATEG    		As String
	WSDATA ADB_CTVAR    		As String
	WSDATA ADB_CULTRA   		As String
	WSDATA ADB_PENE     		As String
	
	//-- Campos opcionais desconsiderados -------
	//WSDATA ADB_UM       		As String	// Não deixa alterar
	//WSDATA ADB_TOTAL    		As Float	// Calculado
	//WSDATA ADB_SEGUM    		As String	// Não deixa alterar
	
	//-- Campos internos Ocultos ------------
	//WSDATA ADB_UNSVEN   		As Float
	//WSDATA ADB_FILENT   		As String
	//WSDATA ADB_QTDENT   		As Float
	//WSDATA ADB_QTDEMP   		As Float
	//WSDATA ADB_PEDCOB   		As String
	//WSDATA ADB_CODCLI   		As String
	//WSDATA ADB_LOJCLI   		As String
	//WSDATA ADB_CLACOM   		As String
	//WSDATA ADB_PREREF   		As Float
	
	WSDATA CAMPOS_ESPEC 		As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT

WSSTRUCT INParceria
	WSDATA ADA_FILIAL 			As String	// Obrigatório
	WSDATA ADA_NUMCTR  			As String	// Obrigatório, automático, mas pode informar
	WSDATA ADA_EMISSA  			As Date		// Obrigatório
	WSDATA ADA_CODCLI  			As String	// Obrigatório
	WSDATA ADA_LOJCLI  			As String	// Obrigatório
	WSDATA ADA_CONDPG  			As String	// Obrigatório
	WSDATA ADA_TABELA  			As String	// Opcional
	WSDATA ADA_DESC1  			As Float 	// Opcional
	WSDATA ADA_VEND1  			As String	// Opcional
	WSDATA ADA_VEND2  			As String
	WSDATA ADA_VEND3  			As String
	WSDATA ADA_VEND4  			As String
	WSDATA ADA_VEND5  			As String
	WSDATA ADA_FILENT 			As String	// Obrigatório, VIRTUAL
	WSDATA ADA_TPFRET  			As String
	WSDATA ADA_FRETE  			As Float
	WSDATA ADA_SEGURO  			As Float
	WSDATA ADA_MOEDA  			As Integer
	WSDATA ADA_CODSAF  			As String
	WSDATA ADA_SAFRA  			As String
	WSDATA ADA_X_NSIM  			As String	// Obrigatório, controle
	
	//-- Campos opcionais desconsiderados -------
	//WSDATA ADA_DESC2 			As Float
	//WSDATA ADA_DESC3  		As Float
	//WSDATA ADA_DESC4  		As Float
	//WSDATA ADA_COMIS1  		As Float
	//WSDATA ADA_COMIS2  		As Float
	//WSDATA ADA_COMIS3  		As Float
	//WSDATA ADA_COMIS4  		As Float
	//WSDATA ADA_COMIS5  		As Float
	//WSDATA ADA_TIPLIB  		As String
	
	//-- Campos internos ocultos ----------------
	//WSDATA ADA_STATUS  		As String
	//WSDATA ADA_TRCNUM  		As String
	//WSDATA ADA_CTRCOM  		As String
	//WSDATA ADA_MENNOT  		As String
	
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
	WSDATA aITENS		 		As Array of ItemParceria
ENDWSSTRUCT

WSMETHOD IncluirCntParceria WSRECEIVE INParceria WSSEND RetStatus WSSERVICE WSSIM3G_PEDIDOVENDA

Local aMsg  		:= {}
Local lLinux 		:= ("LINUX" $ Upper(GetSrvInfo()[2]))
Local cPath 		:= "\logsim3g"+ IF(lLinux,"/","\")	// Pasta abaixo da Protheus_Data para gravar os LOGS
Local cFile 		:= ""
Local cErro 		:= ""
Local aCabec	 	:= {}
Local aItens		:= {}
Local aItem   		:= {}
Local cNumContr 	:= ""
Local cNumSIM3G		:= ""
Local cOldFil		:= cFilAnt
Local nOldMod		:= 0
Local aDadosPE		:= {}
Local cCampo 		:= ""
Local xValor		:= nil
Local bRet			:= .T.
Local _nI
Local i

GeraLog("INICIO","IncluirCntParceria")

If ! ExistDir("\logsim3g")
	MakeDir("\logsim3g")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo obrigatório FILIAL ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(Self:INParceria:ADA_FILIAL)
	aAdd(aMsg,{"P","ADA_FILIAL","Codigo da Filial nao informado"})
Else
	cFilAnt := Self:INParceria:ADA_FILIAL
	If ! FWFilExist()
		aAdd(aMsg,{"P","ADA_FILIAL","Filial nao cadastrada: "+ cFilAnt })
	Else
		GeraLog("Empresa/Filial: "+ cEmpAnt +"/"+ cFilAnt,"IncluirCntParceria")
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo obrigatório NR.CONTRATO SIM3G ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumSIM3G := PADR(AllTrim(::INParceria:ADA_X_NSIM), TamSX3("ADA_X_NSIM")[1])
If ! Empty(cNumSIM3G)
	GeraLog("Numero Contrato SIM3G: "+ cNumSIM3G,"IncluirCntParceria")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida Número do Contrato SIM3G se já existe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("ADA")
	dbOrderNickName("ADANRSIM3G")	// FILIAL + NUM.SIM3G
	If dbSeek( xFilial("ADA") + cNumSIM3G )
		aAdd(aMsg,{"P","ADA_X_NSIM","Contrato de Parceria ja existente: "+ AllTrim(cNumSIM3G) })
	Endif
Else
	aAdd(aMsg,{"P","ADA_X_NSIM","Numero Contrato SIM3G nao informado"})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Número do Contrato ERP se já existe ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumContr := PADR(AllTrim(Self:INParceria:ADA_NUMCTR), TamSX3("ADA_NUMCTR")[1])
If ! Empty(cNumContr)
	dbSelectArea("ADA")
	dbSetOrder(1)	// FILIAL + NUMERO
	If dbSeek( xFilial("ADA") + cNumContr )
		aAdd(aMsg,{"P","ADA_NUMCTR","Contrato de Parceria ja existente: "+ AllTrim(cNumContr) })
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campos dos ITENS e posiciona tabelas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(::INParceria:aItens) == 0
	aAdd(aMsg,{"P","aItens","Nao ha itens no Contrato de Parceria"})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se há mensagens de erro retorna Status e aborta ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aMsg) > 0
	Return( GeraStatus("N",@aMsg,@::RetStatus) )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campos do cabeçalho           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCabec := {}
If ! empty(Self:INParceria:ADA_NUMCTR)
	aAdd(aCabec, {"ADA_NUMCTR", PADR(AllTrim(Self:INParceria:ADA_NUMCTR), TamSX3("ADA_NUMCTR")[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_EMISSA)
	aAdd(aCabec, {"ADA_EMISSA", Self:INParceria:ADA_EMISSA 											, Nil})
Endif
If ! empty(Self:INParceria:ADA_CODCLI)
	aAdd(aCabec, {"ADA_CODCLI", PADR(AllTrim(Self:INParceria:ADA_CODCLI), TamSX3("ADA_CODCLI")[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_LOJCLI)
	aAdd(aCabec, {"ADA_LOJCLI", PADR(AllTrim(Self:INParceria:ADA_LOJCLI), TamSX3("ADA_LOJCLI")[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_CONDPG)
	aAdd(aCabec, {"ADA_CONDPG", PADR(AllTrim(Self:INParceria:ADA_CONDPG), TamSX3("ADA_CONDPG")[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_TABELA)
	aAdd(aCabec, {"ADA_TABELA", PADR(AllTrim(Self:INParceria:ADA_TABELA), TamSX3("ADA_TABELA")[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_DESC1)
	aAdd(aCabec, {"ADA_DESC1" , Self:INParceria:ADA_DESC1  											, Nil})
Endif
If ! empty(Self:INParceria:ADA_VEND1)
	aAdd(aCabec, {"ADA_VEND1" , PADR(AllTrim(Self:INParceria:ADA_VEND1 ), TamSX3("ADA_VEND1" )[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_VEND2)
	aAdd(aCabec, {"ADA_VEND2" , PADR(AllTrim(Self:INParceria:ADA_VEND2 ), TamSX3("ADA_VEND2" )[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_VEND3)
	aAdd(aCabec, {"ADA_VEND3" , PADR(AllTrim(Self:INParceria:ADA_VEND3 ), TamSX3("ADA_VEND3" )[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_VEND4)
	aAdd(aCabec, {"ADA_VEND4" , PADR(AllTrim(Self:INParceria:ADA_VEND4 ), TamSX3("ADA_VEND4" )[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_VEND5)
	aAdd(aCabec, {"ADA_VEND5" , PADR(AllTrim(Self:INParceria:ADA_VEND5 ), TamSX3("ADA_VEND5" )[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_FILENT)
	aAdd(aCabec, {"ADA_FILENT", PADR(AllTrim(Self:INParceria:ADA_FILENT), TamSX3("ADA_FILENT" )[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_TPFRET)
	aAdd(aCabec, {"ADA_TPFRET", PADR(AllTrim(Self:INParceria:ADA_TPFRET), TamSX3("ADA_TPFRET" )[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_FRETE)
	aAdd(aCabec, {"ADA_FRETE" , Self:INParceria:ADA_FRETE  											, Nil})
Endif
If ! empty(Self:INParceria:ADA_SEGURO)
	aAdd(aCabec, {"ADA_SEGURO", Self:INParceria:ADA_SEGURO  										, Nil})
Endif
If ! empty(Self:INParceria:ADA_MOEDA)
	aAdd(aCabec, {"ADA_MOEDA" , Self:INParceria:ADA_MOEDA   										, Nil})
Endif
If ! empty(Self:INParceria:ADA_CODSAF)
	aAdd(aCabec, {"ADA_CODSAF", PADR(AllTrim(Self:INParceria:ADA_CODSAF), TamSX3("ADA_CODSAF")[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_SAFRA)
	aAdd(aCabec, {"ADA_SAFRA" , PADR(AllTrim(Self:INParceria:ADA_SAFRA ), TamSX3("ADA_SAFRA" )[1])	, Nil})
Endif
If ! empty(Self:INParceria:ADA_X_NSIM)
	aAdd(aCabec, {"ADA_X_NSIM", PADR(AllTrim(Self:INParceria:ADA_X_NSIM), TamSX3("ADA_X_NSIM" )[1])	, Nil})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campos específicos no Contrato     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to Len(Self:INParceria:CAMPOS_ESPEC)
	If ! empty(Self:INParceria:CAMPOS_ESPEC[i]:CAMPO)
		cCampo := Alltrim( Self:INParceria:CAMPOS_ESPEC[i]:CAMPO )
		xValor := AllTrim( Self:INParceria:CAMPOS_ESPEC[i]:VALOR )
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek(cCampo))
			Do Case
				Case SX3->X3_TIPO == "N"
					xValor := Val(xValor)
					
				Case SX3->X3_TIPO == "D" // 2018-12-01
					xValor := STOD( Substr(xValor,1,4) + Substr(xValor,6,2) + Substr(xValor,9,2) )
					
				Case SX3->X3_TIPO == "L"
					xValor := (Upper(xValor) $ "TRUE/T/SIM/S/V") 
					
			EndCase
			aAdd(aCabec, { cCampo, xValor, Nil})
		Else
			aAdd(aMsg,{"P","INPARCERIA","Campo especifico nao existe: "+ cCampo })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	Endif
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campos dos itens              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For _nI := 1 to Len(Self:INParceria:aItens)
	
	aAdd(aItem, {"ADB_ITEM"  , StrZero( _nI, TamSX3("ADB_ITEM")[1] )					, Nil})
	
	If ! empty(Self:INParceria:aItens[_nI]:ADB_CODPRO)
		aAdd(aItem, {"ADB_CODPRO", PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_CODPRO), TamSX3("ADB_CODPRO")[1]), Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_DESPRO)
		aAdd(aItem, {"ADB_DESPRO", PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_DESPRO), TamSX3("ADB_DESPRO")[1]), Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_LOCAL)
		aAdd(aItem, {"ADB_LOCAL" , PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_LOCAL) , TamSX3("ADB_LOCAL" )[1]), Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_QUANT)
		aAdd(aItem, {"ADB_QUANT" , Self:INParceria:aItens[_nI]:ADB_QUANT      			, Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_PRUNIT)
		aAdd(aItem, {"ADB_PRUNIT", Self:INParceria:aItens[_nI]:ADB_PRUNIT      			, Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_PRCVEN)
		aAdd(aItem, {"ADB_PRCVEN", Self:INParceria:aItens[_nI]:ADB_PRCVEN      			, Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_TES)
		aAdd(aItem, {"ADB_TES"   , PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_TES), TamSX3("ADB_TES")[1])      , Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_TESCOB)
		aAdd(aItem, {"ADB_TESCOB", PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_TESCOB), TamSX3("ADB_TESCOB")[1]), Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_DESC)
		aAdd(aItem, {"ADB_DESC"  , Self:INParceria:aItens[_nI]:ADB_DESC      			, Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_VALDES)
		aAdd(aItem, {"ADB_VALDES", Self:INParceria:aItens[_nI]:ADB_VALDES      			, Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_CATEG)
		aAdd(aItem, {"ADB_CATEG" , PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_CATEG) , TamSX3("ADB_CATEG" )[1]), Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_CTVAR)
		aAdd(aItem, {"ADB_CTVAR" , PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_CTVAR) , TamSX3("ADB_CTVAR" )[1]), Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_CULTRA)
		aAdd(aItem, {"ADB_CULTRA", PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_CULTRA), TamSX3("ADB_CULTRA")[1]), Nil})
	Endif
	If ! empty(Self:INParceria:aItens[_nI]:ADB_PENE)
		aAdd(aItem, {"ADB_PENE"  , PADR(AllTrim(Self:INParceria:aItens[_nI]:ADB_PENE  ), TamSX3("ADB_PENE"  )[1]), Nil})
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona campos específicos no Item do Contrato ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 to Len(Self:INParceria:aItens[_nI]:CAMPOS_ESPEC)
		If ! empty(Self:INParceria:aItens[_nI]:CAMPOS_ESPEC[i]:CAMPO)
			cCampo := Alltrim( Self:INParceria:aItens[_nI]:CAMPOS_ESPEC[i]:CAMPO )
			xValor := AllTrim( Self:INParceria:aItens[_nI]:CAMPOS_ESPEC[i]:VALOR )
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek(cCampo))
				Do Case
					Case SX3->X3_TIPO == "N"
						xValor := Val(xValor)
						
					Case SX3->X3_TIPO == "D" // 2018-12-01
						xValor := STOD( Substr(xValor,1,4) + Substr(xValor,6,2) + Substr(xValor,9,2) )
						
					Case SX3->X3_TIPO == "L"
						xValor := (Upper(xValor) $ "TRUE/T/SIM/S/V") 
						
				EndCase
				aAdd(aItem, { cCampo, xValor, Nil})
			Else
				aAdd(aMsg,{"P","aITENS","Campo especifico nao existe: "+ cCampo })
				Return( GeraStatus("N",@aMsg,@::RetStatus) )
			Endif
		Endif
	Next i
	
	aAdd(aItens, aItem)
Next _nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina automática de inclusão  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lMsErroAuto := .F.

//varinfo("aCabec",aCabec)
//varinfo("aItens",aItens)
nModulo := 67 // Gestao de Agronegocio
MSExecAuto({|x,y,z| U_C011A01(x,y,z)},aCabec,aItens,3)

If ! lMsErroAuto
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna STATUS da importação - SUCESSO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aMsg,{"S",ADA->ADA_NUMCTR,"Contrato de Parceria incluido - Numero ERP: "+ ADA->ADA_NUMCTR })
	GeraStatus("S",@aMsg,@::RetStatus)
Else
	cFile := "IncluirCntParceria_"+ AllTrim(cNumSIM3G) +".log"
	MostraErro(cPath,cFile)
	cErro := FwNoAccent(MemoRead(cPath + cFile))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna STATUS da importação - ERRO    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aMsg,{"P","Contrato de Parceria: "+ AllTrim(cNumSIM3G),cErro})
	GeraStatus("N",@aMsg,@::RetStatus)
	bRet := .T. // Deve retornar .T. mesmo em caso de erro
Endif

GeraLog("FIM","IncluirCntParceria")

Return(bRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IncluirCli³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 29/11/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para incluir o cadastro de Clientes                   ³±±
±±³          ³ Rotina padrão: MATA030 tabela SA1                            ³±±
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
WSSTRUCT INCliente
	WSDATA A1_FILIAL 			As String	// Obrigatório
	WSDATA A1_COD     			As String	// Obrigatório
	WSDATA A1_LOJA    			As String	// Obrigatório
	WSDATA A1_NOME    			As String	// Obrigatório
	WSDATA A1_NREDUZ 			As String	// Obrigatório
	WSDATA A1_PESSOA 			As String	// F=Fisica; J=Juridica
	WSDATA A1_END    			As String	// Obrigatório
	WSDATA A1_ENDCOB   			As String
	WSDATA A1_ENDENT   			As String
	WSDATA A1_BAIRRO 			As String
	WSDATA A1_BAIRROC 			As String
	WSDATA A1_BAIRROE 			As String
	WSDATA A1_COMPLEM 			As String
	WSDATA A1_COMPENT 			As String
	WSDATA A1_TIPO  			As String	// Obrigatório: F=Consumidor Final; R=Revendedor; S=Solidario; X=Exportacao; L=Produtor Rural;
	WSDATA A1_EST   			As String	// Obrigatório
	WSDATA A1_ESTC   			As String
	WSDATA A1_ESTE  			As String
	WSDATA A1_CEP   			As String
	WSDATA A1_CEPC   			As String
	WSDATA A1_CEPE   			As String
	WSDATA A1_COD_MUN  			As String
	WSDATA A1_CODMUNE  			As String
	WSDATA A1_MUN   			As String	// Obrigatório
	WSDATA A1_MUNC   			As String
	WSDATA A1_MUNE   			As String
	WSDATA A1_REGIAO 			As String
	WSDATA A1_DDD    			As String
	WSDATA A1_DDI   			As String
	WSDATA A1_TEL    			As String
	WSDATA A1_FAX   			As String
	WSDATA A1_TELEX   			As String
	WSDATA A1_CONTATO 			As String
	WSDATA A1_CGC   			As String
	WSDATA A1_RG     			As String
	WSDATA A1_PFISICA 			As String
	WSDATA A1_INSCR 			As String
	WSDATA A1_INSCRM 			As String
	WSDATA A1_INSCRUR 			As String
	WSDATA A1_PAIS  			As String
	WSDATA A1_DTNASC  			As Date
	WSDATA A1_EMAIL 			As String
	WSDATA A1_HPAGE 			As String
	WSDATA A1_CNAE   			As String
	//WSDATA A1_MSBLQL 			As String	// 1=Inativo; 2=Ativo
	WSDATA A1_VEND   			As String
	WSDATA A1_TPFRET   			As String	// C=CIF; F=FOB
	WSDATA A1_TRANSP			As String
	WSDATA A1_COND   			As String
	WSDATA A1_RISCO 			As String 	// A=Risco A; B=Risco B; C=Risco C; D=Risco D; E=Risco E
	WSDATA A1_LC       			As Float
	WSDATA A1_LCFIN    			As Float
	WSDATA A1_VENCLC   			As Date
	WSDATA A1_TABELA   			As String
	//WSDATA A1_OBSERV   			As String
	WSDATA A1_GRPVEN   			As String
	//WSDATA A1_DTCAD   			As Date  	// Automático, não permite editar
	//WSDATA A1_HRCAD   			As String	// Automático, não permite editar
	//WSDATA A1_CALCSUF  			As String	// Para impostos, não adianta colocar só esse (?)
	
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
	WSDATA OPERACAO		 		As String Optional
ENDWSSTRUCT

WSMETHOD IncluirCliente WSRECEIVE INCliente WSSEND RetStatus WSSERVICE WSSIM3G_PEDIDOVENDA

Local aMsg  		:= {}
Local lLinux 		:= ("LINUX" $ Upper(GetSrvInfo()[2]))
Local cPath 		:= "\logsim3g"+ IF(lLinux,"/","\")	// Pasta abaixo da Protheus_Data para gravar os LOGS
Local cFile 		:= ""
Local cErro 		:= ""
Local aDados 	 	:= {}
Local cNumSIM3G		:= ""
Local aDadosPE		:= {} //****************** VER  ******************/
Local cCampo 		:= ""
Local xValor		:= nil
Local bRet			:= .T.
Local cOperacao		:= "" // I=INCLUIR, A=ALTERAR
Local i

GeraLog("INICIO","IncluirCliente")

If ! ExistDir("\logsim3g")
	MakeDir("\logsim3g")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo OPERACAO utilizado para incluir ou alterar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(Self:INCliente:OPERACAO)
	cOperacao := "I"
Else
	cOperacao := Upper(Substr( AllTrim(Self:INCliente:OPERACAO), 1, 1 ))
	If cOperacao <> "I" .and. cOperacao <> "A"
		aAdd(aMsg,{"P","OPERACAO","Operacao invalida! Informe 'I' ou 'A'"})
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Endif
	If cOperacao == "A"
		GeraLog("OPERACAO: ALTERACAO")
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo FILIAL - Utilizado para LOGAR na filial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(Self:INCliente:A1_FILIAL)
	aAdd(aMsg,{"P","A1_FILIAL","Codigo da Filial nao informado"})
	Return( GeraStatus("N",@aMsg,@::RetStatus) )
Else
	cFilAnt := Self:INCliente:A1_FILIAL
	If ! FWFilExist()
		aAdd(aMsg,{"P","A1_FILIAL","Filial nao cadastrada: "+ cFilAnt })
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Else
		GeraLog("Empresa/Filial: "+ cEmpAnt +"/"+ cFilAnt)
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o Código do Cliente conforme a operacao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodigo := PADR(AllTrim(Self:INCliente:A1_COD ), TamSX3("A1_COD" )[1])
cLoja   := PADR(AllTrim(Self:INCliente:A1_LOJA), TamSX3("A1_LOJA")[1])
If cOperacao == "I"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se o Cliente já está cadastrado     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(cCodigo + cLoja)
		dbSelectArea("SA1")
		dbSetOrder(1)	// FILIAL + CODIGO + LOJA
		If dbSeek( xFilial("SA1") + cCodigo + cLoja )
			aAdd(aMsg,{"P","A1_COD/A1_LOJA","Cliente ja cadastrado com o Codigo/Loja: "+ cCodigo +"/"+ cLoja })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ALTERACAO - Valida se o Cliente está cadastrado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCodigo + cLoja)
		aAdd(aMsg,{"P","A1_COD/A1_LOJA","Informe o Codigo/Loja do Cliente para alterar"})
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)	// FILIAL + CODIGO + LOJA
		If ! dbSeek( xFilial("SA1") + cCodigo + cLoja )
			aAdd(aMsg,{"P","A1_COD/A1_LOJA","Cliente nao cadastrado! Verifique o Codigo/Loja: "+ cCodigo +"/"+ cLoja })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campos do cabeçalho           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDados := {}
//fAddCampo(aDados, Self:INCliente, "A1_COD")

aAdd(aDados, {"A1_FILIAL", xFilial("SA1"), Nil})
If ! empty(Self:INCliente:A1_COD)
	aAdd(aDados, {"A1_COD", PADR(AllTrim(Self:INCliente:A1_COD), TamSX3("A1_COD")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_LOJA)
	aAdd(aDados, {"A1_LOJA", PADR(AllTrim(Self:INCliente:A1_LOJA), TamSX3("A1_LOJA")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_NOME)
	aAdd(aDados, {"A1_NOME", PADR(AllTrim(Self:INCliente:A1_NOME), TamSX3("A1_NOME")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_NREDUZ)
	aAdd(aDados, {"A1_NREDUZ", PADR(AllTrim(Self:INCliente:A1_NREDUZ), TamSX3("A1_NREDUZ")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_PESSOA)
	aAdd(aDados, {"A1_PESSOA" , PADR(AllTrim(Self:INCliente:A1_PESSOA ), TamSX3("A1_PESSOA" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_END)
	aAdd(aDados, {"A1_END" , PADR(AllTrim(Self:INCliente:A1_END ), TamSX3("A1_END" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_ENDCOB)
	aAdd(aDados, {"A1_ENDCOB" , PADR(AllTrim(Self:INCliente:A1_ENDCOB ), TamSX3("A1_ENDCOB" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_ENDENT)
	aAdd(aDados, {"A1_ENDENT" , PADR(AllTrim(Self:INCliente:A1_ENDENT ), TamSX3("A1_ENDENT" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_BAIRRO)
	aAdd(aDados, {"A1_BAIRRO", PADR(AllTrim(Self:INCliente:A1_BAIRRO), TamSX3("A1_BAIRRO" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_BAIRROC)
	aAdd(aDados, {"A1_BAIRROC", PADR(AllTrim(Self:INCliente:A1_BAIRROC), TamSX3("A1_BAIRROC" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_BAIRROE)
	aAdd(aDados, {"A1_BAIRROE", PADR(AllTrim(Self:INCliente:A1_BAIRROE), TamSX3("A1_BAIRROE" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_COMPLEM)
	aAdd(aDados, {"A1_COMPLEM", PADR(AllTrim(Self:INCliente:A1_COMPLEM), TamSX3("A1_COMPLEM" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_COMPENT)
	aAdd(aDados, {"A1_COMPENT", PADR(AllTrim(Self:INCliente:A1_COMPENT), TamSX3("A1_COMPENT" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_TIPO)
	aAdd(aDados, {"A1_TIPO", PADR(AllTrim(Self:INCliente:A1_TIPO), TamSX3("A1_TIPO")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_EST)
	aAdd(aDados, {"A1_EST", PADR(AllTrim(Self:INCliente:A1_EST), TamSX3("A1_EST")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_ESTC)
	aAdd(aDados, {"A1_ESTC", PADR(AllTrim(Self:INCliente:A1_ESTC), TamSX3("A1_ESTC")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_ESTE)
	aAdd(aDados, {"A1_ESTE", PADR(AllTrim(Self:INCliente:A1_ESTE), TamSX3("A1_ESTE")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_CEP)
	aAdd(aDados, {"A1_CEP", PADR(AllTrim(Self:INCliente:A1_CEP), TamSX3("A1_CEP")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_CEPC)
	aAdd(aDados, {"A1_CEPC", PADR(AllTrim(Self:INCliente:A1_CEPC), TamSX3("A1_CEPC")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_CEPE)
	aAdd(aDados, {"A1_CEPE", PADR(AllTrim(Self:INCliente:A1_CEPE), TamSX3("A1_CEPE")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_COD_MUN)
	aAdd(aDados, {"A1_COD_MUN" , PADR(AllTrim(Self:INCliente:A1_COD_MUN ), TamSX3("A1_COD_MUN" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_CODMUNE)
	aAdd(aDados, {"A1_CODMUNE" , PADR(AllTrim(Self:INCliente:A1_CODMUNE ), TamSX3("A1_CODMUNE" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_MUN)
	aAdd(aDados, {"A1_MUN" , PADR(AllTrim(Self:INCliente:A1_MUN ), TamSX3("A1_MUN" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_MUNC)
	aAdd(aDados, {"A1_MUNC" , PADR(AllTrim(Self:INCliente:A1_MUNC ), TamSX3("A1_MUNC" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_MUNE)
	aAdd(aDados, {"A1_MUNE" , PADR(AllTrim(Self:INCliente:A1_MUNE ), TamSX3("A1_MUNE" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_REGIAO)
	aAdd(aDados, {"A1_REGIAO" , PADR(AllTrim(Self:INCliente:A1_REGIAO ), TamSX3("A1_REGIAO" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_DDD)
	aAdd(aDados, {"A1_DDD", PADR(AllTrim(Self:INCliente:A1_DDD), TamSX3("A1_DDD" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_DDI)
	aAdd(aDados, {"A1_DDI" , PADR(AllTrim(Self:INCliente:A1_DDI ), TamSX3("A1_DDI" )[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_TEL)
	aAdd(aDados, {"A1_TEL", PADR(AllTrim(Self:INCliente:A1_TEL), TamSX3("A1_TEL")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_FAX)
	aAdd(aDados, {"A1_FAX", PADR(AllTrim(Self:INCliente:A1_FAX), TamSX3("A1_FAX")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_TELEX)
	aAdd(aDados, {"A1_TELEX", PADR(AllTrim(Self:INCliente:A1_TELEX), TamSX3("A1_TELEX")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_CONTATO)
	aAdd(aDados, {"A1_CONTATO", PADR(AllTrim(Self:INCliente:A1_CONTATO), TamSX3("A1_CONTATO")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_CGC)
	aAdd(aDados, {"A1_CGC", PADR(AllTrim(Self:INCliente:A1_CGC), TamSX3("A1_CGC")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_RG)
	aAdd(aDados, {"A1_RG", PADR(AllTrim(Self:INCliente:A1_RG), TamSX3("A1_RG")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_PFISICA)
	aAdd(aDados, {"A1_PFISICA", PADR(AllTrim(Self:INCliente:A1_PFISICA), TamSX3("A1_PFISICA")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_INSCR)
	aAdd(aDados, {"A1_INSCR", PADR(AllTrim(Self:INCliente:A1_INSCR), TamSX3("A1_INSCR")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_INSCRM)
	aAdd(aDados, {"A1_INSCRM", PADR(AllTrim(Self:INCliente:A1_INSCRM), TamSX3("A1_INSCRM")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_INSCRUR)
	aAdd(aDados, {"A1_INSCRUR", PADR(AllTrim(Self:INCliente:A1_INSCRUR), TamSX3("A1_INSCRUR")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_PAIS)
	aAdd(aDados, {"A1_PAIS", PADR(AllTrim(Self:INCliente:A1_PAIS), TamSX3("A1_PAIS")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_DTNASC)
	aAdd(aDados, {"A1_DTNASC", Self:INCliente:A1_DTNASC 											, Nil})
Endif
If ! empty(Self:INCliente:A1_EMAIL)
	aAdd(aDados, {"A1_EMAIL", PADR(AllTrim(Self:INCliente:A1_EMAIL), TamSX3("A1_EMAIL")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_HPAGE)
	aAdd(aDados, {"A1_HPAGE", PADR(AllTrim(Self:INCliente:A1_HPAGE), TamSX3("A1_HPAGE")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_CNAE)
	aAdd(aDados, {"A1_CNAE", PADR(AllTrim(Self:INCliente:A1_CNAE), TamSX3("A1_CNAE")[1])	, Nil})
Endif
//If ! empty(Self:INCliente:A1_MSBLQL)
//	aAdd(aDados, {"A1_MSBLQL", PADR(AllTrim(Self:INCliente:A1_MSBLQL), TamSX3("A1_MSBLQL")[1])	, Nil})
//Endif
If ! empty(Self:INCliente:A1_VEND)
	aAdd(aDados, {"A1_VEND", PADR(AllTrim(Self:INCliente:A1_VEND), TamSX3("A1_VEND")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_TPFRET)
	aAdd(aDados, {"A1_TPFRET", PADR(AllTrim(Self:INCliente:A1_TPFRET), TamSX3("A1_TPFRET")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_TRANSP)
	aAdd(aDados, {"A1_TRANSP", PADR(AllTrim(Self:INCliente:A1_TRANSP), TamSX3("A1_TRANSP")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_COND)
	aAdd(aDados, {"A1_COND", PADR(AllTrim(Self:INCliente:A1_COND), TamSX3("A1_COND")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_RISCO)
	aAdd(aDados, {"A1_RISCO", PADR(AllTrim(Self:INCliente:A1_RISCO), TamSX3("A1_RISCO")[1])	, Nil})
Endif
If ! empty(Self:INCliente:A1_LC)
	aAdd(aDados, {"A1_LC" , Self:INCliente:A1_LC  											, Nil})
Endif
If ! empty(Self:INCliente:A1_LCFIN)
	aAdd(aDados, {"A1_LCFIN", Self:INCliente:A1_LCFIN  										, Nil})
Endif
If ! empty(Self:INCliente:A1_VENCLC)
	aAdd(aDados, {"A1_VENCLC" , Self:INCliente:A1_VENCLC   										, Nil})
Endif
If ! empty(Self:INCliente:A1_TABELA)
	aAdd(aDados, {"A1_TABELA", PADR(AllTrim(Self:INCliente:A1_TABELA), TamSX3("A1_TABELA")[1])	, Nil})
Endif
//If ! empty(Self:INCliente:A1_OBSERV)
//	aAdd(aDados, {"A1_OBSERV", PADR(AllTrim(Self:INCliente:A1_OBSERV), TamSX3("A1_OBSERV")[1])	, Nil})
//Endif
If ! empty(Self:INCliente:A1_GRPVEN)
	aAdd(aDados, {"A1_GRPVEN", PADR(AllTrim(Self:INCliente:A1_GRPVEN), TamSX3("A1_GRPVEN")[1])	, Nil})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campos específicos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to Len(Self:INCliente:CAMPOS_ESPEC)
	If ! empty(Self:INCliente:CAMPOS_ESPEC[i]:CAMPO)
		cCampo := Alltrim( Self:INCliente:CAMPOS_ESPEC[i]:CAMPO )
		xValor := AllTrim( Self:INCliente:CAMPOS_ESPEC[i]:VALOR )
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
			aAdd(aDados, { cCampo, xValor, Nil})
		Else
			aAdd(aMsg,{"P","INCliente","Campo especifico nao existe: "+ cCampo })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	Endif
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina automática de inclusão  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lMsErroAuto := .F.
nModulo := 5 // Faturamento
If cOperacao == "I"
	MSExecAuto({|x,y| MATA030(x,y)}, aDados, 3) // INCLUIR
Else
	conout("** Cliente posicionado: "+ SA1->A1_COD +" "+ SA1->A1_LOJA )
	MSExecAuto({|x,y| MATA030(x,y)}, aDados, 4) // ALTERAR
Endif
cErro := ""

If ! lMsErroAuto
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna STATUS da importação - SUCESSO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOperacao == "I"
		aAdd(aMsg,{"S",SA1->A1_COD +"/"+ SA1->A1_LOJA,"Cliente incluido com sucesso - Codigo/Loja ERP: "+ SA1->A1_COD +"/"+ SA1->A1_LOJA })
	Else
		aAdd(aMsg,{"S",SA1->A1_COD +"/"+ SA1->A1_LOJA,"Cliente alterado com sucesso" })
	Endif
	GeraStatus("S",@aMsg,@::RetStatus)
Else
	cFile := "IncluirCliente_"+ AllTrim(cNumSIM3G) +".log"
	MostraErro(cPath,cFile)
	cErro := FwNoAccent(MemoRead(cPath + cFile))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna STATUS da importação - ERRO    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aMsg,{"P","Cadastro de Cliente: "+ AllTrim(cNumSIM3G),cErro})
	GeraStatus("N",@aMsg,@::RetStatus)
	bRet := .T. // Deve retornar .T. mesmo em caso de erro
Endif

GeraLog("FIM","IncluirCliente")

Return(bRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IncluirCon³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 12/12/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para incluir o cadastro de Contatos x Clientes        ³±±
±±³          ³ Rotina padrão: TMKA070 tabela SU5, AGA, AGB                  ³±±
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
WSSTRUCT INContato
	WSDATA U5_FILIAL 			As String	// Obrigatório
	WSDATA U5_CODCONT  			As String	// Obrigatório
	WSDATA U5_CONTAT  			As String	// Obrigatório
	WSDATA U5_CPF    			As String	// Não pode ter repetido (validação padrão)
	WSDATA U5_END    			As String
	WSDATA U5_RG     			As String
	WSDATA U5_BAIRRO 			As String
	WSDATA U5_MUN    			As String
	WSDATA U5_EST     			As String
	WSDATA U5_CEP   			As String
	WSDATA U5_CODPAIS  			As String
	WSDATA U5_DDD    			As String
	WSDATA U5_FONE  			As String
	WSDATA U5_CELULAR			As String
	WSDATA U5_FAX   			As String
	WSDATA U5_FCOM1 			As String
	WSDATA U5_FCOM2 			As String
	WSDATA U5_EMAIL 			As String
	WSDATA U5_URL    			As String
	WSDATA U5_ATIVO  			As String	// 1=Sim; 2=Nao
	WSDATA U5_STATUS 			As String	// 1=Desatualizado; 2=Atualizado; 3=Em Desenvolvimento
	//WSDATA U5_MSBLQL   			As String
	WSDATA U5_SEXO   			As String	// 1=Masculino; 2=Feminino;
	WSDATA U5_NIVER  			As Date
	WSDATA U5_CIVIL  			As String	// 1=Solteiro; 2=Casado; 3=Divorciado; 4=Viuvo; 5=Companheiro(a);
	//WSDATA U5_OBS   			As String
	WSDATA U5_PAIS   			As String

	WSDATA A1_COD     			As String	// Obrigatório, vincular CLIENTE/LOJA
	WSDATA A1_LOJA    			As String	// Obrigatório, vincular CLIENTE/LOJA
	
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
	WSDATA OPERACAO		 		As String Optional
ENDWSSTRUCT

WSMETHOD IncluirContato WSRECEIVE INContato WSSEND RetStatus WSSERVICE WSSIM3G_PEDIDOVENDA

Local aMsg  		:= {}
Local lLinux 		:= ("LINUX" $ Upper(GetSrvInfo()[2]))
Local cPath 		:= "\logsim3g"+ IF(lLinux,"/","\")	// Pasta abaixo da Protheus_Data para gravar os LOGS
Local cFile 		:= ""
Local cErro 		:= ""
Local aDados 	 	:= {}
Local cNumSIM3G		:= ""
Local aDadosPE		:= {} //****************** VER  ******************/
Local cCampo 		:= ""
Local xValor		:= nil
Local bRet			:= .T.
Local cOperacao		:= "" // I=INCLUIR, A=ALTERAR
Local cCliente 		:= ""
Local cLoja   		:= ""
Local i

GeraLog("INICIO","IncluirContato")

If ! ExistDir("\logsim3g")
	MakeDir("\logsim3g")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo OPERACAO utilizado para incluir ou alterar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(Self:INContato:OPERACAO)
	cOperacao := "I"
Else
	cOperacao := Upper(Substr( AllTrim(Self:INContato:OPERACAO), 1, 1 ))
	If cOperacao <> "I" .and. cOperacao <> "A"
		aAdd(aMsg,{"P","OPERACAO","Operacao invalida! Informe 'I' ou 'A'"})
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Endif
	If cOperacao == "A"
		GeraLog("OPERACAO: ALTERACAO")
	Endif
Endif

conout("cOperacao: "+ cOperacao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo FILIAL - Utilizado para LOGAR na filial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(Self:INContato:U5_FILIAL)
	aAdd(aMsg,{"P","U5_FILIAL","Codigo da Filial nao informado"})
	Return( GeraStatus("N",@aMsg,@::RetStatus) )
Else
	cFilAnt := Self:INContato:U5_FILIAL
	If ! FWFilExist()
		aAdd(aMsg,{"P","U5_FILIAL","Filial nao cadastrada: "+ cFilAnt })
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Else
		GeraLog("Empresa/Filial: "+ cEmpAnt +"/"+ cFilAnt)
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o Código do Contato conforme a operacao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodigo := PADR(AllTrim(Self:INContato:U5_CODCONT ), TamSX3("U5_CODCONT" )[1])
If cOperacao == "I"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se o Contato já está cadastrado na tabela SU5           ³
	//³ Se não passar o código, será determinado pelo padrão da rotina ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(cCodigo)
		dbSelectArea("SU5")
		dbSetOrder(1)	// FILIAL + CODIGO
		If dbSeek( xFilial("SU5") + cCodigo )
			aAdd(aMsg,{"P","U5_CODCONT","Contato ja cadastrado com esse codigo: "+ cCodigo })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ALTERACAO - Valida se o Contato está cadastrado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCodigo)
		aAdd(aMsg,{"P","U5_CODCONT","Informe o Codigo do Contato para alterar"})
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Else
		dbSelectArea("SU5")
		dbSetOrder(1)	// FILIAL + CODIGO
		If ! dbSeek( xFilial("SU5") + cCodigo )
			aAdd(aMsg,{"P","U5_CODCONT","Contato nao cadastrado! Verifique o codigo: "+ cCodigo })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo CLIENTE/LOJA - Utilizado para vincular o contato ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOperacao == "I"
	cCliente := PADR(AllTrim(Self:INContato:A1_COD ), TamSX3("A1_COD" )[1])
	cLoja    := PADR(AllTrim(Self:INContato:A1_LOJA), TamSX3("A1_LOJA")[1])
	If Empty(cCliente + cLoja)
		aAdd(aMsg,{"P","A1_COD/A1_LOJA","Informe o Codigo/Loja do Cliente para vincular o contato" })
		Return( GeraStatus("N",@aMsg,@::RetStatus) )
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)	// FILIAL + CODIGO + LOJA
		If ! dbSeek( xFilial("SA1") + cCliente + cLoja )
			aAdd(aMsg,{"P","A1_COD/A1_LOJA","Cliente nao cadastrado: "+ cCliente +"/"+ cLoja })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	Endif
Endif
dbSelectArea("SU5")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campos do cabeçalho           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDados := {}
aAdd(aDados, {"U5_FILIAL", xFilial("SU5"), Nil})

If ! empty(Self:INContato:U5_CODCONT)
	aAdd(aDados, {"U5_CODCONT", PADR(AllTrim(Self:INContato:U5_CODCONT), TamSX3("U5_CODCONT")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_CONTAT)
	aAdd(aDados, {"U5_CONTAT", PADR(AllTrim(Self:INContato:U5_CONTAT), TamSX3("U5_CONTAT")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_CPF)
	aAdd(aDados, {"U5_CPF", PADR(AllTrim(Self:INContato:U5_CPF), TamSX3("U5_CPF")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_END)
	aAdd(aDados, {"U5_END", PADR(AllTrim(Self:INContato:U5_END), TamSX3("U5_END")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_RG)
	aAdd(aDados, {"U5_RG" , PADR(AllTrim(Self:INContato:U5_RG ), TamSX3("U5_RG" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_BAIRRO)
	aAdd(aDados, {"U5_BAIRRO" , PADR(AllTrim(Self:INContato:U5_BAIRRO ), TamSX3("U5_BAIRRO" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_MUN)
	aAdd(aDados, {"U5_MUN" , PADR(AllTrim(Self:INContato:U5_MUN ), TamSX3("U5_MUN" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_EST)
	aAdd(aDados, {"U5_EST" , PADR(AllTrim(Self:INContato:U5_EST ), TamSX3("U5_EST" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_CEP)
	aAdd(aDados, {"U5_CEP", PADR(AllTrim(Self:INContato:U5_CEP), TamSX3("U5_CEP" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_CODPAIS)
	aAdd(aDados, {"U5_CODPAIS", PADR(AllTrim(Self:INContato:U5_CODPAIS), TamSX3("U5_CODPAIS" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_DDD)
	aAdd(aDados, {"U5_DDD", PADR(AllTrim(Self:INContato:U5_DDD), TamSX3("U5_DDD" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_FONE)
	aAdd(aDados, {"U5_FONE", PADR(AllTrim(Self:INContato:U5_FONE), TamSX3("U5_FONE" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_CELULAR)
	aAdd(aDados, {"U5_CELULAR", PADR(AllTrim(Self:INContato:U5_CELULAR), TamSX3("U5_CELULAR")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_FAX)
	aAdd(aDados, {"U5_FAX", PADR(AllTrim(Self:INContato:U5_FAX), TamSX3("U5_FAX")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_FCOM1)
	aAdd(aDados, {"U5_FCOM1", PADR(AllTrim(Self:INContato:U5_FCOM1), TamSX3("U5_FCOM1")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_FCOM2)
	aAdd(aDados, {"U5_FCOM2", PADR(AllTrim(Self:INContato:U5_FCOM2), TamSX3("U5_FCOM2")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_EMAIL)
	aAdd(aDados, {"U5_EMAIL", PADR(AllTrim(Self:INContato:U5_EMAIL), TamSX3("U5_EMAIL")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_URL)
	aAdd(aDados, {"U5_URL", PADR(AllTrim(Self:INContato:U5_URL), TamSX3("U5_URL")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_ATIVO)
	aAdd(aDados, {"U5_ATIVO", PADR(AllTrim(Self:INContato:U5_ATIVO), TamSX3("U5_ATIVO")[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_STATUS)
	aAdd(aDados, {"U5_STATUS" , PADR(AllTrim(Self:INContato:U5_STATUS ), TamSX3("U5_STATUS" )[1])	, Nil})
Endif
//If ! empty(Self:INContato:U5_MSBLQL)
//	aAdd(aDados, {"U5_MSBLQL" , PADR(AllTrim(Self:INContato:U5_MSBLQL ), TamSX3("U5_MSBLQL" )[1])	, Nil})
//Endif
If ! empty(Self:INContato:U5_SEXO)
	aAdd(aDados, {"U5_SEXO" , PADR(AllTrim(Self:INContato:U5_SEXO ), TamSX3("U5_SEXO" )[1])	, Nil})
Endif
If ! empty(Self:INContato:U5_NIVER)
	aAdd(aDados, {"U5_NIVER", Self:INContato:U5_NIVER		, Nil})
Endif
If ! empty(Self:INContato:U5_CIVIL)
	aAdd(aDados, {"U5_CIVIL" , PADR(AllTrim(Self:INContato:U5_CIVIL ), TamSX3("U5_CIVIL" )[1])	, Nil})
Endif
//If ! empty(Self:INContato:U5_OBS)
//	aAdd(aDados, {"U5_OBS" , PADR(AllTrim(Self:INContato:U5_OBS ), TamSX3("U5_OBS" )[1])	, Nil})
//Endif
If ! empty(Self:INContato:U5_PAIS)
	aAdd(aDados, {"U5_PAIS" , PADR(AllTrim(Self:INContato:U5_PAIS ), TamSX3("U5_PAIS" )[1])	, Nil})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campos específicos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to Len(Self:INContato:CAMPOS_ESPEC)
	If ! empty(Self:INContato:CAMPOS_ESPEC[i]:CAMPO)
		cCampo := Alltrim( Self:INContato:CAMPOS_ESPEC[i]:CAMPO )
		xValor := AllTrim( Self:INContato:CAMPOS_ESPEC[i]:VALOR )
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
			aAdd(aDados, { cCampo, xValor, Nil})
		Else
			aAdd(aMsg,{"P","INContato","Campo especifico nao existe: "+ cCampo })
			Return( GeraStatus("N",@aMsg,@::RetStatus) )
		Endif
	Endif
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabelas Filhas: AGA=Endereço e AGB=Telefones  ³
//³ NÃO PRECISA PASSAR - O MSExecAuto já alimenta ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEndereco := nil
aTelefone := nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina automática de inclusão  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lMsErroAuto := .F.
nModulo := 5 // Faturamento
If cOperacao == "I"
	MSExecAuto({|x,y,z,a,b| TMKA070(x,y,z,a,b)}, aDados, 3, aEndereco, aTelefone, nil)
Else
	conout("** Contato posicionado: "+ SU5->U5_CODCONT )
	MSExecAuto({|x,y,z,a,b| TMKA070(x,y,z,a,b)}, aDados, 4, aEndereco, aTelefone, nil)
Endif
cErro := ""

If ! lMsErroAuto
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui o vínculo entre CONTATO X CLIENTE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOperacao == "I"
		cCodEnt := cCliente + cLoja
		If ! Empty(cCodEnt)
			dbSelectArea("AC8")
			dbSetOrder(1) // FILIAL + COD.CONTATO + ENTIDADE + FIL.ENT + COD.ENT
			If ! dbSeek( xFilial("AC8") + SU5->U5_CODCONT + "SA1" + xFilial("SA1") + cCodEnt )
				RecLock("AC8",.T.)
				AC8->AC8_FILIAL := xFilial("AC8")
				AC8->AC8_FILENT := xFilial("SA1")
				AC8->AC8_ENTIDA := "SA1"
				AC8->AC8_CODENT := cCodEnt
				AC8->AC8_CODCON := SU5->U5_CODCONT
				MsUnlock()
			Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna STATUS da importação - SUCESSO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOperacao == "I"
		aAdd(aMsg,{"S",SU5->U5_CODCONT,"Contato incluido com sucesso - Codigo ERP: "+ SU5->U5_CODCONT })
	Else
		aAdd(aMsg,{"S",SU5->U5_CODCONT,"Contato alterado com sucesso" })
	Endif
	GeraStatus("S",@aMsg,@::RetStatus)
Else
	cFile := "IncluirContato_"+ AllTrim(cNumSIM3G) +".log"
	MostraErro(cPath,cFile)
	cErro := FwNoAccent(MemoRead(cPath + cFile))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna STATUS da importação - ERRO    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aMsg,{"P","Cadastro de Contato: "+ AllTrim(cNumSIM3G),cErro})
	GeraStatus("N",@aMsg,@::RetStatus)
	bRet := .T. // Deve retornar .T. mesmo em caso de erro
Endif

GeraLog("FIM","IncluirContato")

Return(bRet)



/*
Static Function fAddCampo(aVet, oObj, cCampo)

If ! empty(oObj:&cCampo)
	aAdd(aVet, { cCampo, PADR(AllTrim(oObj:A1_&cCampoCOD), TamSX3(cCampo)[1])	, Nil })
Endif

Return
*/

