#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³S011A03   ³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 16/08/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WebService REST para integração com sistema Força de Vendas  ³±±
±±³          ³ Protheus x SIM3G (Wealthsystems).                            ³±±
±±³          ³ Acesso: http://localhost:80nn/rest/wssim3g/                  ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Específico integração SIM3G / MASTERSALES                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSRESTFUL WSSIM3G DESCRIPTION "Integracao SIM3G / MASTERSALES"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Propriedades para os parâmetros da QueryString (opcional)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WSDATA adapter    AS STRING
	WSDATA table      AS STRING
	WSDATA field      AS STRING
	WSDATA filter     AS STRING
	WSDATA order      AS STRING
	WSDATA limit      AS INTEGER
	WSDATA page       AS INTEGER
	WSDATA modo	      AS STRING	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Métodos HTTP que serão utilizados: POST, PUT, GET, DELETE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WSMETHOD POST     DESCRIPTION "Simulacao de impostos sobre venda de produtos. Informar 'GETIMPOSTO' no parametro 'adapter'" WSSYNTAX ""
	WSMETHOD GET      DESCRIPTION "Retorna dados de consulta genérica de uma tabela conforme parametros de chamada" WSSYNTAX ""
	WSMETHOD PUT      DESCRIPTION "Realiza atualização Flag _X_EXPO" WSSYNTAX ""
	
END WSRESTFUL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³POST      ºAutor  ³TOTVS CASCAVEL      º Data ³ 17/08/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Declaração do método POST do webservice.                    º±±
±±º          ³Pode receber parâmetros por querystring (URL), exemplo:     º±±
±±º          ³  localhost:8036/rest/WSSIM3G?adapter=getimpostos           º±±
±±º          ³Pode receber dados JSON/XML no corpo do documento (CONTENT) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ADAPTER: nome da função que será executada.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T. = Requisição realizada com sucesso.                     º±±
±±º          ³.F. = Inconsistência, deve executar função SetRestFault()   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD POST WSRECEIVE adapter WSSERVICE WSSIM3G

Local lRet  	:= .T.
Local cBody 	:= ""
Local cJSONRet	:= "{}"
Local cErro 	:= ""

Default self:adapter	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o parâmetro de entrada do 'adapter'                  ³
//³ Pode ser informado de duas maneiras:                        ³
//³    http://localhost:8036/rest/WSSIM3G/getimpostos           ³
//³    http://localhost:8036/rest/WSSIM3G?adapter=getimpostos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if len(self:aURLParms) > 0
	
	self:adapter := upper(alltrim( self:aURLParms[1] ))
	conout("WSSIM3G - "+ self:adapter +" - "+ dtoc(date()) +" "+ time())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GETIMPOSTOS - Cálculo dos impostos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if substr(self:adapter,1,10) == "GETIMPOSTO" .or. substr(self:adapter,1,11) == "CALCIMPOSTO"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recupera os dados no corpo da requisição (JSON) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cBody := self:GetContent()
		if ! empty(cBody)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa o cálculo dos impostos e retorna a resposta ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if fGetImposto(cBody, @cJSONRet, @cErro)
				self:SetResponse( cJSONRet )
			else
				SetRestFault(400, cErro)
				lRet := .F.
			endif
		else
			SetRestFault(400, "Requisicao nao possui conteudo (body)")
			lRet := .F.
		endif
	else
		SetRestFault(400, "Adapter nao encontrado: "+ self:adapter)
		lRet := .F.
	endif
else
	if empty(self:adapter)
		SetRestFault(400, "Adapter nao informado")
		lRet := .F.
	endif
endif

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetImpostºAutor  ³TOTVS CASCAVEL      º Data ³ 20/08/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para processar o cálculo dos impostos solicitados,   º±±
±±º          ³recebendo um objeto JSON de entrada, executando a função    º±±
±±º          ³planilha fiscal do ERP, gerando um objeto JSON de retorno.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function fGetImposto(cBody,cJSONRet,cErro)

local lRet  	:= .T.
Local oJSON 	:= nil
local oRetorno	:= nil
local oProduto	:= nil
local oCampos	:= nil
local oCabec	:= nil
local i, j

local cCliente		:= ""
local cLoja   		:= ""
local cTipoCli 		:= ""
local cTpFrete 		:= ""
local cProduto  	:= ""
local cTES  		:= ""
local cOper 		:= ""
local aProdutos 	:= {}
local aCpoRetCab 	:= {}
local aCpoRetIte 	:= {}
local nTotFrete 	:= 0
local nTotDespes	:= 0
local nTotSeguro	:= 0
local nTotFreAut	:= 0
local nQuant		:= 0
local nPrcVen		:= 0
local nValDesc		:= 0
local nPerDesc		:= 0
local nValMerc		:= 0
local nPrcList		:= 0
local aInfo  		:= GetApoInfo("S011A03.PRW")
local cInfo  		:= ""
local lS011TES 		:= ExistBlock("S011TES")
local cRetTES 		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtém informação de compilação do fonte PRW          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if ! empty(aInfo)
	cInfo := dtoc(aInfo[4])  // Data da última modificação do arquivo
	cInfo += " "+ aInfo[5]   // Hora, minutos e segundos da última modificação
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Decodifica string JSON de entrada e gera objeto JSON ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FWJsonDeserialize(cBody, @oJSON)
if oJSON == nil
	cErro := "Erro ao decodificar JSON de entrada, verifique a sintaxe"
	return(.F.)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Filial           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if AttIsMemberOf(oJSON, "C5_FILIAL")
	if ! empty(oJSON['C5_FILIAL'])
		cFilAnt := oJSON['C5_FILIAL']
		if ! FWFilExist()
			cErro := "Filial nao cadastrada: "+ cFilAnt
			conout(cErro)
			return(.F.)
		endif
	endif
endif
conout("-> Empresa/Filial: "+ cEmpAnt +"/"+ cFilAnt )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Cliente          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if AttIsMemberOf(oJSON, "C5_CLIENTE")
	cCliente := PADR( Alltrim(oJSON['C5_CLIENTE']), TamSX3("C5_CLIENTE")[1])
	if empty(cCliente)
		cErro := "Codigo do cliente nao informado"
		return(.F.)
	endif
else
	cErro := "Propriedade obrigatoria nao encontrada: 'C5_CLIENTE' "
	return(.F.)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Loja             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if AttIsMemberOf(oJSON, "C5_LOJACLI")
	cLoja := PADR( Alltrim(oJSON['C5_LOJACLI']), TamSX3("C5_LOJACLI")[1])
	if empty(cLoja)
		cErro := "Loja do cliente nao informada"
		return(.F.)
	endif
else
	cErro := "Propriedade obrigatoria nao encontrada: 'C5_LOJACLI' "
	return(.F.)
endif

dbSelectArea("SA1")
dbSetOrder(1)
if ! dbSeek( xFilial("SA1") + cCliente + cLoja )
	cErro := "Cliente nao cadastrado ["+ cCliente +"/"+ cLoja +"]"
	return(.F.)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Tipo de Cliente                               ³
//³ F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacao/Importacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipoCli := SA1->A1_TIPO
if AttIsMemberOf(oJSON, "C5_TIPOCLI") .and. ! empty(oJSON['C5_TIPOCLI'])
	cTipoCli := substr(alltrim(oJSON['C5_TIPOCLI']),1,1)
	if ! (cTipoCli $ "FLRSX")
		cErro := "Tipo de cliente invalido: "+ cTipoCli +". Utilize F, L, R, S ou X"
		return(.F.)
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Tipo de Frete    ³
//³ C=CIF;F=FOB;T=Por conta terceiros;S=Sem frete ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTpFrete := ""
if AttIsMemberOf(oJSON, "C5_TPFRETE")
	cTpFrete := substr(alltrim(oJSON['C5_TPFRETE']),1,1)
	if ! empty(cTpFrete) .and. ! (cTpFrete $ "CFTS")
		cErro := "Tipo de frete invalido: "+ cTpFrete +". Utilize C, F, T ou S"
		return(.F.)
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Frete Total      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if AttIsMemberOf(oJSON, "C5_FRETE")
	nTotFrete  := oJSON['C5_FRETE']
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Despesa Total    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if AttIsMemberOf(oJSON, "C5_DESPESA")
	nTotDespes := oJSON['C5_DESPESA']
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Seguro Total     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if AttIsMemberOf(oJSON, "C5_SEGURO")
	nTotSeguro := oJSON['C5_SEGURO']
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Frete Autonomo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if AttIsMemberOf(oJSON, "C5_FRETAUT")
	nTotFreAut := oJSON['C5_FRETAUT']
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Itens/Produtos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if ! AttIsMemberOf(oJSON, "itens")
	cErro := "Propriedade obrigatoria nao encontrada: 'itens' "
	return(.F.)
endif
if Valtype( oJSON['itens'] ) <> "A"
	cErro := "Propriedade 'itens' nao eh uma lista "
	return(.F.)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedade do JSON - Campos Retorno   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if AttIsMemberOf(oJSON, "campos_retorno_nivel_cabecalho") .and. Valtype( oJSON['campos_retorno_nivel_cabecalho'] ) == "A"
	aCpoRetCab := oJSON['campos_retorno_nivel_cabecalho']
endif
if AttIsMemberOf(oJSON, "campos_retorno_nivel_itens") .and. Valtype( oJSON['campos_retorno_nivel_itens'] ) == "A"
	aCpoRetIte := oJSON['campos_retorno_nivel_itens']
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida propriedades dos Itens                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
for i := 1 to len( oJSON['itens'] )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida propriedade do JSON - Produto          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if AttIsMemberOf(oJSON['itens'][i], "produto")
		oProduto := oJSON['itens'][i]['produto']
	else
		cErro := "Propriedade obrigatoria nao encontrada: 'itens[]:produto' "
		return(.F.)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida propriedade do JSON - Código do Produto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if AttIsMemberOf(oProduto, "C6_PRODUTO")
		cProduto  := oProduto['C6_PRODUTO']
		if ! empty(cProduto)
			dbSelectArea("SB1")
			dbSetOrder(1)
			if ! dbSeek( xFilial("SB1") + cProduto )
				cErro := "Produto nao cadastrado ["+ cProduto +"]. Linha: "+ alltrim(str(i))
				return(.F.)
			endif
		else
			cErro := "Codigo do produto nao informado"
			return(.F.)
		endif
	else
		cErro := "Propriedade obrigatoria nao encontrada: 'itens[]:produto:C6_PRODUTO' "
		return(.F.)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida propriedade do JSON - Quantidade       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if AttIsMemberOf(oProduto, "C6_QTDVEN")
		nQuant := oProduto['C6_QTDVEN']
		if empty(nQuant) .or. nQuant <= 0
			cErro := "Quantidade invalida ["+ alltrim(str(nQuant)) +"]"
			return(.F.)
		endif
	else
		cErro := "Propriedade obrigatoria nao encontrada: 'itens[]:produto:C6_QTDVEN' "
		return(.F.)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida propriedade do JSON - Preço Unitário   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if AttIsMemberOf(oProduto, "C6_PRCVEN")
		nPrcVen := oProduto['C6_PRCVEN']
		if empty(nPrcVen) .or. nPrcVen <= 0
			cErro := "Preco unitario invalido ["+ alltrim(str(nPrcVen)) +"]"
			return(.F.)
		endif
	else
		cErro := "Propriedade obrigatoria nao encontrada: 'itens[]:produto:C6_PRCVEN' "
		return(.F.)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida propriedade do JSON - TES              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if AttIsMemberOf(oProduto, "C6_TES")
		cTES := oProduto['C6_TES']
	else
		cTES := ""
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida propriedade do JSON - OPERACAO         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if AttIsMemberOf(oProduto, "C6_OPER")
		cOper := oProduto['C6_OPER']
	else
		cOper := ""
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida cadastro do TES ou OPERACAO            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if ! empty(cTES)
		cOper := ""
		dbSelectArea("SF4")
		dbSetOrder(1)
		if ! dbSeek( xFilial("SF4") + cTES )
			cErro := "TES nao cadastrado ["+ cTES +"]. Linha: "+ alltrim(str(i))
			return(.F.)
		endif
	else
		if ! empty(cOper)
			
			dbSelectArea("SFM")
			dbSetOrder(1)
			if ! dbSeek( xFilial("SFM") + cOper )
				cErro := "Operacao da TES Inteligente nao cadastrada ["+ cOper +"]. Linha: "+ alltrim(str(i))
				return(.F.)
			endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca TES via Operação TES Inteligente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTES := MaTesInt (2, cOper, cCliente, cLoja, "C", cProduto )
			if empty(cTES)
				cErro := "TES nao encontrada via Operacao TES Inteligente ["+ cOper +"]. Linha: "+ alltrim(str(i))
				return(.F.)
			endif
		else
			//cErro := "TES/Operacao nao informada no item. Linha: "+ alltrim(str(i))
			//return(.F.)
		endif
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida propriedade do JSON - Valor Desconto Item ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if AttIsMemberOf(oProduto, "C6_VALDESC")
		nValDesc := oProduto['C6_VALDESC']
	else
		nValDesc := 0
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida propriedade do JSON - Perc. Desconto Item ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if AttIsMemberOf(oProduto, "C6_DESCONT")
		nPerDesc := oProduto['C6_DESCONT']
		if nPerDesc > 0 .and. nValDesc == 0
			nPrcTab := (nPrcVen * 100) / (100 - nPerDesc)
			nValDesc := a410Arred( (nPrcTab - nPrcVen) * nQuant, "C6_VALDESC")
		endif
	else
		nPerDesc := 0
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona o item no vetor de produto da Planilha  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValMerc := (nQuant * nPrcVen) + nValDesc
	nPrcList := nPrcVen + (nValDesc / nQuant)
	aItem := { cProduto, cTES, nQuant, nPrcList, nValMerc, nValDesc, 0, 0, 0, 0 }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para obter o TES do Produto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lS011TES
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Declara variáveis para uso no ponto de entrada    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private _cTipoPed  := "N"
		Private _cCliente  := cCliente
		Private _cLoja     := cLoja
		Private _cTipoCli  := cTipoCli
		Private _cTpFrete  := cTpFrete
		Private _aItem     := aClone(aItem)
		
		cRetTES := ExecBlock("S011TES",.F.,.F.,{ cTES })
		If ValType(cRetTES) == "C"
			cTES := cRetTES
		endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida obrigatoriedade do TES ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if ! empty(cTES)
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek( xFilial("SF4") + cTES )
			aItem[2] := cTES
		else
			cErro := "TES nao cadastrado ["+ cTES +"]. Linha: "+ alltrim(str(i))
			return(.F.)
		endif
	else
		cErro := "TES/Operacao nao informada no item. Linha: "+ alltrim(str(i))
		return(.F.)
	endif

	aAdd( aProdutos, aItem )
	//conout( "Quant: "+ cvaltochar(nQuant) + " PrcLista: "+ cvaltochar(nPrcList) + " ValMerc: "+ cvaltochar(nValMerc) + " ValDesc: "+ cvaltochar(nValDesc) )
next i

FreeObj(oJSON)
oJSON := nil
oProduto := nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procedimentos para cálculo e retorno dos Impostos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if ! empty(aProdutos)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa a Planilha Fiscal maFisIni  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	conout("-> Iniciando planilha fiscal... ")
	if fMAFISINI(cCliente, cLoja, cTipoCli, cTpFrete, aProdutos, nTotFrete, nTotSeguro, nTotDespes, nTotFreAut)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria objeto JSON para retorno  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oRetorno := JsonObject():new()
		oRetorno['itens'] := {}
		oProduto := nil
		oCampos := nil
		for i := 1 to len(aProdutos)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define campos do Produto para retorno dos impostos ³
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oCampos := JsonObject():new()
			oCampos['IT_PRODUTO']      := MaFisRet(i,"IT_PRODUTO")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida campos adicionais para retornar no Itens ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			for j := 1 to len(aCpoRetIte)
				cCampo := upper(alltrim( aCpoRetIte[j] ))
				if substr(cCampo,1,3) == "IT_"
					xPosCpo := MaFisScan(cCampo,.F.)
					if ValType(xPosCpo) == "A" .or. ValType(xPosCpo) == "C"
						oCampos[cCampo] := MaFisRet(i,cCampo)
					else
						conout(cCampo + " - MATXFIS Referencia de imposto invalida")
					endif
				endif
			next j
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona objeto Produto na lista de Itens ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProduto := JsonObject():new()
			oProduto['produto'] := oCampos
			aAdd( oRetorno['itens'], oProduto )
		next i
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna campos totalizadores da venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oCabec := JsonObject():new()
		oCabec['VER_INFO']     := cInfo
		oCabec['NF_TOTAL']     := MaFisRet(,"NF_TOTAL")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida campos adicionais para retornar no cabeçalho ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		for j := 1 to len(aCpoRetCab)
			cCampo := upper(alltrim( aCpoRetCab[j] ))
			if substr(cCampo,1,3) == "NF_"
				xPosCpo := MaFisScan(cCampo,.F.)
				if ValType(xPosCpo) == "A" .or. ValType(xPosCpo) == "C"
					if cCampo == "NF_IMPOSTOS"
						oCabec[cCampo] := fRetNFIMP()
					else
						oCabec[cCampo] := MaFisRet(nil,cCampo)
					endif
				else
					conout(cCampo + " - MATXFIS Referencia de imposto invalida")
				endif
			endif
		next j
		oRetorno['cabecalho'] := oCabec
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Converte objeto JSON para STRING ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		conout("-> Gerando objeto JSON de retorno")
		cJSONRet := FWJsonSerialize(oRetorno,.T.,.T.)
		FreeObj(oRetorno)
		oRetorno := nil
		oProduto := nil
		oCampos  := nil
		oCabec   := nil
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a Planilha Fiscal maFisEnd  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisEnd()
		conout("-> Planilha fiscal finalizada - "+ time())
	else
		conout("-> Planilha fiscal nao iniciada")
	endif
else
	cErro := "Nenhum produto foi informado"
	lRet := .F.
endif
conout(" ")

return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRetNFIMP ºAutor  ³TOTVS CASCAVEL      º Data ³ 08/09/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para retornar objeto JSON formatado para NF_IMPOSTOS º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function fRetNFIMP()

local aRet	:= {}
local aImp	:= {}
local oAux	:= nil
local i
 
aImp := MaFisRet(nil,"NF_IMPOSTOS")
for i := 1 to len(aImp)
	oAux := JsonObject():new()
	oAux['CODIGO_IMPOSTO']   := aImp[i][1]
	oAux['NOME_IMPOSTO']     := aImp[i][2]
	oAux['BASE_IMPOSTO']     := aImp[i][3]
	oAux['ALIQUOTA_IMPOSTO'] := aImp[i][4]
	oAux['VALOR_IMPOSTO']    := aImp[i][5]
	aAdd( aRet, oAux )
next i

return(aRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fMAFISINI ºAutor  ³TOTVS CASCAVEL      º Data ³ 20/08/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para inicializar e carregar a Planilha Fiscal para   º±±
±±º          ³cálculo e simulação de Impostos sobre vendas.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function fMAFISINI(cCliente, cLoja, cTipoCli, cTpFrete, aProdutos, nTotFrete, nTotSeguro, nTotDespes, nTotFreAut)

local aAreas		:= { SA1->(GetArea()), SB1->(GetArea()) }
local aArea 		:= GetArea()
local lRet   		:= .F.
local lM410Ipi  	:= ExistBlock("M410IPI")
local lM410Icm  	:= ExistBlock("M410ICM")
local lM410Soli 	:= ExistBlock("M410SOLI")
local aSolid 		:= {}
local nItem 		:= 0
local _nI
local _nX

default cCliente 	:= ""
default cLoja    	:= ""
default cTipoCli   	:= ""
default cTpFrete 	:= ""
default aProdutos	:= {}
default nTotFrete	:= 0
default nTotSeguro	:= 0
default nTotDespes	:= 0
default nTotFreAut	:= 0

if ! empty(aProdutos)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no cadastro do Cliente             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	if dbSeek( xFilial("SA1") + cCliente + cLoja )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a Função Fiscal                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisEnd()
		MaFisClear()
		MaFisIni(SA1->A1_COD,;		// 1-Codigo Cliente/Fornecedor
			SA1->A1_LOJA,;			// 2-Loja do Cliente/Fornecedor
			"C",;					// 3-C:Cliente , F:Fornecedor
			"N",;					// 4-Tipo da NF
			cTipoCli,;				// 5-Tipo do Cliente/Fornecedor
			nil,;					// 6-Relacao de Impostos que suportados no arquivo
			nil,;					// 7-Tipo de complemento
			nil,;					// 8-Permite Incluir Impostos no Rodape .T./.F.
			nil,;					// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"MATA461",;				// 10-Nome da rotina que esta utilizando a funcao
			nil,;					// 11-Tipo de documento
			nil,;  					// 12-Especie do documento 
			nil,;					// 13-Codigo e Loja do Prospect 
			nil,;					// 14-Grupo Cliente
			nil,;					// 15-Recolhe ISS
			nil,;					// 16-Codigo do cliente de entrega na nota fiscal de saida
			nil,;					// 17-Loja do cliente de entrega na nota fiscal de saida
			nil,;					// 18-Informacoes do transportador [01]-UF,[02]-TPTRANS
			nil,;					// 19-Se esta emitindo nota fiscal ou cupom fiscal (Sigaloja)
			nil,;					// 20-Define se calcula IPI (SIGALOJA)
			nil,;					// 21-Pedido de Venda
			SA1->A1_COD,;			// 22-Cliente do faturamento ( cCodCliFor é passado como o cliente de entrega, pois é o considerado na maioria das funções fiscais, exceto ao gravar o clinte nas tabelas do livro)
			SA1->A1_LOJA,;			// 23-Loja do cliente do faturamento
			nil,;					// 24-Total do Pedido
			nil,;					// 25-Data de emissão do documento inicialmente só é diferente de dDataBase nas notas de entrada (MATA103 e MATA910)
			cTpFrete)				// 26-Tipo de Frete informado no pedido
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os itens do pedido para a Função Fiscal       ³
		//³ aProdutos[n][1]: código do produto (obrigatório)      ³
		//³ aProdutos[n][2]: TES da venda (obrigatório)           ³
		//³ aProdutos[n][3]: quantidade de venda (obrigatório)    ³
		//³ aProdutos[n][4]: preço de venda unitário (obrigatório)³
		//³ aProdutos[n][5]: valor da mercadoria (obrigatório)    ³
		//³ aProdutos[n][6]: valor do desconto (opcional)         ³
		//³ aProdutos[n][7]: valor do frete do item (opcional)    ³
		//³ aProdutos[n][8]: valor da despesa do item (opcional)  ³
		//³ aProdutos[n][9]: valor do seguro do item (opcional)   ³
		//³ aProdutos[n][10]: valor do frete autonomo (opcional)  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For _nI := 1 To Len(aProdutos)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Posiciona no cadastro do produto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			dbSelectArea("SB1")
			dbSetOrder(1)
			if dbSeek(xFilial("SB1") + aProdutos[_nI][1])
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Adiciona os dados do item ao processamento fiscal³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				MaFisAdd( ;
					aProdutos[_nI][1],;		// 1-Codigo do Produto ( Obrigatorio )
					aProdutos[_nI][2],;		// 2-Codigo do TES ( Opcional )
					aProdutos[_nI][3],;		// 3-Quantidade ( Obrigatorio )
					aProdutos[_nI][4],;		// 4-Preco Unitario ( Obrigatorio )
					aProdutos[_nI][6],; 	// 5-Valor do Desconto ( Opcional )
					nil,;	// 6 -Numero da NF Original ( Devolucao/Benef )
					nil,;	// 7 -Serie da NF Original ( Devolucao/Benef )
					nil,;	// 8 -RecNo da NF Original no arq SD1/SD2
					aProdutos[_nI][7],;		// 9 -Valor do Frete do Item ( Opcional )
					aProdutos[_nI][8],;		// 10-Valor da Despesa do item ( Opcional )
					aProdutos[_nI][9],;		// 11-Valor do Seguro do item ( Opcional )
					aProdutos[_nI][10],;	// 12-Valor do Frete Autonomo ( Opcional )
					aProdutos[_nI][5],;		// 13-Valor da Mercadoria ( Obrigatorio )
					0  ,;	// 14-Valor da Embalagem ( Opcional )
					nil,;	// 15-RecNo do SB1
					nil,;	// 16-RecNo do SF4
					nil,;	// 17-Item
					nil,;	// 18-Despesas nao tributadas - Portugal
					nil,;	// 19-Tara - Portugal
					nil,; 	// 20-CFO
					nil,;	// 21-Array para o calculo do IVA Ajustado (opcional)
					nil,;	// 22-Concepto
					nil,;	// 23-Base Veiculo
					nil,; 	// 24-Lote Produto
					nil,;	// 25-Sub-Lote Produto
					nil,;	// 26-Valor do Abatimento ISS
					nil,; 	// 27-Codigo ISS
					nil,;	// 28-Classificação Fiscal     
					nil,;	// 29-Cod. do Produto Fiscal 
					nil,;	// 30-Recno do Produto Fiscal 
					nil ;	// 31-NCM do produto Fiscal
				)
			endif
		next _nI
		
		MaFisAlt("NF_ESPECIE" , "SPED"      )
		MaFisAlt("NF_UFDEST"  , SA1->A1_EST )
		MaFisAlt("NF_FRETE"   , nTotFrete   )
		MaFisAlt("NF_SEGURO"  , nTotSeguro  )
		MaFisAlt("NF_DESPESA" , nTotDespes  )
		MaFisAlt("NF_AUTONOMO", nTotFreAut  )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida pontos de entrada de impostos  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lM410Ipi .Or. lM410Icm .Or. lM410Soli
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Declara variáveis para uso nos pontos de entrada  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Private _cTipoPed  := "N"
			Private _cCliente  := cCliente
			Private _cLoja     := cLoja
			Private _cTipoCli  := cTipoCli
			Private _cTpFrete  := cTpFrete
			Private _aProdutos := aClone(aProdutos)

			For _nX := 1 To Len(aProdutos)
				nItem++
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada M410IPI para alterar valores do IPI       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Ipi 
					VALORIPI    := MaFisRet(nItem,"IT_VALIPI")
					BASEIPI     := MaFisRet(nItem,"IT_BASEIPI")
					QUANTIDADE  := MaFisRet(nItem,"IT_QUANT")
					ALIQIPI     := MaFisRet(nItem,"IT_ALIQIPI")
					BASEIPIFRETE:= MaFisRet(nItem,"IT_FRETE")
					MaFisAlt("IT_VALIPI",ExecBlock("M410IPI",.F.,.F.,{ nItem }),nItem,.T.)
					MaFisLoad("IT_BASEIPI",BASEIPI ,nItem)
					MaFisLoad("IT_ALIQIPI",ALIQIPI ,nItem)
					MaFisLoad("IT_FRETE"  ,BASEIPIFRETE,nItem,"11")
					MaFisEndLoad(nItem,1)
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada M410ICM para alterar valores do ICMS      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Icm
					_BASEICM    := MaFisRet(nItem,"IT_BASEICM")
					_ALIQICM    := MaFisRet(nItem,"IT_ALIQICM")
					_QUANTIDADE := MaFisRet(nItem,"IT_QUANT")
					_VALICM     := MaFisRet(nItem,"IT_VALICM")
					_FRETE      := MaFisRet(nItem,"IT_FRETE")
					_VALICMFRETE:= MaFisRet(nItem,"IT_ICMFRETE")
					_DESCONTO   := MaFisRet(nItem,"IT_DESCONTO")
					ExecBlock("M410ICM",.F.,.F., { nItem } )
					MaFisLoad("IT_BASEICM" ,_BASEICM    ,nItem)
					MaFisLoad("IT_ALIQICM" ,_ALIQICM    ,nItem)
					MaFisLoad("IT_VALICM"  ,_VALICM     ,nItem)
					MaFisLoad("IT_FRETE"   ,_FRETE      ,nItem)
					MaFisLoad("IT_ICMFRETE",_VALICMFRETE,nItem)
					MaFisLoad("IT_DESCONTO",_DESCONTO   ,nItem)
					MaFisEndLoad(nItem,1)
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada M410SOLI para alterar valores do ICMS-ST  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Soli
					ICMSITEM    := MaFisRet(nItem,"IT_VALICM")		// variavel para ponto de entrada
					QUANTITEM   := MaFisRet(nItem,"IT_QUANT")		// variavel para ponto de entrada
					BASEICMRET  := MaFisRet(nItem,"IT_BASESOL")	    // criado apenas para o ponto de entrada
					MARGEMLUCR  := MaFisRet(nItem,"IT_MARGEM")		// criado apenas para o ponto de entrada
					aSolid := ExecBlock("M410SOLI",.f.,.f.,{nItem}) 
					aSolid := IIF(ValType(aSolid) == "A" .And. Len(aSolid) >= 2, aSolid,{})
					If ! Empty(aSolid)
						If Len(aSolid) == 2
							MaFisLoad("IT_BASESOL", NoRound(aSolid[1], 2), nItem)
							MaFisLoad("IT_VALSOL" , NoRound(aSolid[2], 2), nItem)
						ElseIf Len(aSolid) == 7
							MaFisLoad("IT_BASESOL", NoRound(aSolid[1], 2), nItem)
							MaFisLoad("IT_VALSOL" , NoRound(aSolid[2], 2), nItem)
							MaFisLoad("IT_MARGEM" , NoRound(aSolid[3], 2), nItem)
							MaFisLoad("IT_ALIQSOL", NoRound(aSolid[4], 2), nItem)
							MaFisLoad("IT_BSFCPST", NoRound(aSolid[5], 2), nItem)
							MaFisLoad("IT_ALFCST" , NoRound(aSolid[6], 2), nItem)
							MaFisLoad("IT_VFECPST", NoRound(aSolid[7], 2), nItem)
						EndIf
						MaFisEndLoad(nItem,1)
					Endif
				EndIf
			Next
		EndIf
		
		lRet := MaFisFound()
	endif
endif

aEval(aAreas, {|x| RestArea(x) })
RestArea(aArea)

return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GET       ºAutor  ³TOTVS CASCAVEL      º Data ³ 14/12/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Declaração do método GET do webservice.                     º±±
±±º          ³Pode receber parâmetros por querystring (URL), exemplo:     º±±
±±º          ³  localhost:8036/rest/WSSIM3G?adapter=getgenerico           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³TABLE: Alias da tabela para retornar                        º±±
±±º          ³FIELD: lista de campos da tabela (sintaxe SQL)              º±±
±±º          ³FILTER: expressão de filtro na tabela (sintaxe SQL)         º±±
±±º          ³ORDER: lista de campos para ordenar os registros (SQL)      º±±
±±º          ³LIMIT: quantidade de registros para retornar na paginação   º±±
±±º          ³PAGE: número da página para retornar na chamada             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T. = Requisição realizada com sucesso.                     º±±
±±º          ³.F. = Inconsistência, deve executar função SetRestFault()   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD GET WSRECEIVE table, field, filter, order, limit, page WSSERVICE WSSIM3G

Local lRet  	:= .T.
Local cMetodo 	:= ""
Local cJSONRet	:= "{}"
Local cErro 	:= ""

Default self:table  	:= ""
Default self:filter  	:= ""
Default self:field  	:= ""
Default self:order  	:= ""
Default self:limit  	:= 0
Default self:page   	:= 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o tipo do conteúdo de retorno: JSON ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
self:SetContentType("application/json")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o parâmetro de entrada do método GET                 ³
//³    http://localhost:8036/rest/WSSIM3G/getgenerico/          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(self:aURLParms) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtém nome do método a partir dos parâmetros da URL    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//varinfo("self:aURLParms",self:aURLParms)
	cMetodo := upper(alltrim( self:aURLParms[1] ))
	If Len(self:aURLParms) > 1
		cMetodo += "/"+ upper(alltrim( self:aURLParms[2] ))
	Endif
	
	//U_X011A01("CONSOLE", cMetodo +" - INICIO")
	If cMetodo == "GETGENERICO"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna os registros selecionados conforme parametros  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If fGetGenerico( @cJSONRet, @cErro, self:table, self:field, self:filter, self:order, self:limit, self:page )
			self:SetResponse( cJSONRet )
		Else
			SetRestFault(400, EncodeUTF8(cErro))
			lRet := .F.
		Endif

	ElseIf cMetodo == "GETGENERICO/COUNT"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna a quantidade total de registros       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If fGetCount( @cJSONRet, @cErro, self:table, self:filter )
			self:SetResponse( cJSONRet )
		Else
			SetRestFault(400, EncodeUTF8(cErro))
			lRet := .F.
		Endif

	Else
		SetRestFault(400, EncodeUTF8("metodo nao implementado: "+ cMetodo))
		lRet := .F.
	Endif
Else
	SetRestFault(400, EncodeUTF8("metodo nao informado"))
	lRet := .F.
Endif

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetGeneriºAutor  ³TOTVS CASCAVEL      º Data ³ 14/12/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para retonar os registros de uma tabela conforme     º±±
±±º          ³parametros de filtro.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet: indica se processou com sucesso (T) ou erro (F)       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetGenerico( cJSONRet, cErro, table, field, filter, order, limit, page )

Local aArea 		:= GetArea()
Local lRet   		:= .F.
Local cSql    		:= ""
Local cAliasQry 	:= GetNextAlias()
Local nCount 		:= 0
Local aStruct 		:= {}
Local cNomeCampo	:= ""
Local xConteudo 	:= nil
Local bError 		:= nil
Local cDescErro		:= ""
Local cLog      	:= ""
Local oRetorno
Local oCampos
Local i
Local lORA  		:= "ORACLE" $ TCGetDB()
Local lSQL  		:= "MSSQL" $ TCGetDB()
Local lDB2  		:= "DB2" $ TCGetDB()
Local nOffSet 		:= 0
Local nLimit  		:= 0
Local cSqlOra  		:= ""

If ! Empty(table)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se não informou os campos, retorna todos os campos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(field)
		field := "*"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se informou o ALIAS da tabela, pega o nome da tabela   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Alltrim(table)) == 3
		table := RetSqlName(table)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta informação para gerar LOG no console do WS       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLog := "FIELD: "+ field +" FILTER: "+ filter +" ORDER: "+ order
	If limit > 0
		cLog += " LIMIT: "+ cValToChar(limit) + " PAGE: "+ cValToChar(page)
	Endif
		
	U_X011A01("CONSOLE", "GETGENERICO - "+ table +" "+ cLog )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta consulta SQL com base nos parâmetros de entrada  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := "SELECT "+ field +" "
	cSql += "FROM "+ table +" "
	If ! Empty(filter)
		cSql += "WHERE "+ filter +" "
	Endif
	If ! Empty(order)
		cSql += "ORDER BY "+ order +" "
	Else
		cSql += "ORDER BY R_E_C_N_O_ "
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorno de registros com paginação nativa do SGBD      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If limit > 0
		If page <= 0
			page := 1
		Endif
		
		If lORA
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento para ORACLE versão anterior 12c que nao suporta OFFSET/FETCH ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nOffSet := (limit * page - limit)
			nLimit  := (nOffSet + limit)
			
			cSqlOra := "SELECT f.* "									+ CRLF
			cSqlOra += "FROM ("											+ CRLF
			cSqlOra += "   SELECT t.*, rownum r "						+ CRLF
			cSqlOra += "   FROM ("										+ CRLF
			cSqlOra += "      "+ cSql									+ CRLF
			cSqlOra += "   ) t "										+ CRLF
			cSqlOra += "   WHERE rownum <= "+ cValToChar(nLimit) +" "	+ CRLF
			cSqlOra += ") f "											+ CRLF
			cSqlOra += "WHERE r > "+ cValToChar(nOffSet) +" "			+ CRLF
			
			cSql := cSqlOra
			
		ElseIf lSQL
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento para SQL SERVER versão anterior 2012 que nao suporta OFFSET/FETCH ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSql := "SELECT * FROM ( "
			cSql += "SELECT "+ field +", ROW_NUMBER() OVER ( "
			If ! Empty(order)
				cSql += "ORDER BY "+ order +" ) "
			Else
				cSql += "ORDER BY R_E_C_N_O_ ) "
			Endif
			cSql += "AS RowNum "
			cSql += "FROM "+ table +" "
			If ! Empty(filter)
				cSql += " WHERE "+ filter +" "
			Endif
			cSql += ") AS RowConstrainedResult "
			cSql += "WHERE RowNum > "+ cValToChar(limit * page - limit)
			cSql += " AND RowNum <= "+ cValToChar(limit * page)
			cSql += " ORDER BY RowNum "

		ElseIf lDB2
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento específico para DB2 versão 9.7.0 que nao suporta OFFSET/FETCH  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If field == "*"
				field := table +".*"
			Endif
			cSql := "SELECT * FROM ( "
			cSql += "SELECT "+ field +", ROW_NUMBER() OVER ( "
			If ! Empty(order)
				cSql += "ORDER BY "+ order +" ) "
			Else
				cSql += "ORDER BY R_E_C_N_O_ ) "
			Endif
			cSql += "AS row_number "
			cSql += "FROM "+ table +" "
			If ! Empty(filter)
				cSql += " WHERE "+ filter +" "
			Endif
			cSql += ") PAG "
			cSql += "WHERE PAG.row_number > "+ cValToChar(limit * page - limit)
			cSql += " AND PAG.row_number <= "+ cValToChar(limit * page)
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o bloco de erro do sistema e atribui tratamento customizado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bError := ErrorBlock( { |oError| fCatchError( oError, @cDescErro ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sequencia de código protegido com captura de erro     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN SEQUENCE
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria objeto JSON para retorno  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oRetorno := JsonObject():new()
		oRetorno['result'] := {}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a consulta SQL e monta JSON de retorno         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		conout(cSql)
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
		dbSelectArea(cAliasQry)
		aStruct := DBStruct()
		
		While ! EOF()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria objeto JSON para cada registro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oCampos := JsonObject():new()
			
			For i := 1 to Len(aStruct)
				cNomeCampo := aStruct[i,1]
				xConteudo := &(cNomeCampo)
				
				If ("_USERLGI" $ cNomeCampo) .or. ("_USERLGA" $ cNomeCampo) .or. ("_USERGI" $ cNomeCampo) .or. ("_USERGA" $ cNomeCampo)
					// Implementação futura
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Converte e formata o conteúdo dos Campos para JSON     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SX3->(dbSetOrder(2))
					If SX3->(dbSeek( cNomeCampo ))
						Do Case
							Case SX3->X3_TIPO == "C"
								xConteudo := EncodeUTF8( Alltrim(xConteudo) )
							Case SX3->X3_TIPO == "M"
								xConteudo := EncodeUTF8( Alltrim(xConteudo) )
							Case SX3->X3_TIPO == "D"
								xConteudo := STOD(xConteudo)
						Endcase
					Else
						If ValType(xConteudo) == "C"
							xConteudo := EncodeUTF8( Alltrim(xConteudo) )
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona o campo no registro de retorno ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oCampos[cNomeCampo] := xConteudo
				Endif
			Next i
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona o registro no JSON de retorno  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( oRetorno['result'], oCampos )

			dbSelectArea(cAliasQry)
			dbSkip()
			nCount++
		Enddo
		dbSelectArea(cAliasQry)
		dbCloseArea()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Informações sobre a paginação                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oRetorno['count'] := nCount
		oRetorno['page']  := page

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Serializa o objeto JSON de retorno            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cJSONRet := FWJsonSerialize(oRetorno,.T.,.T.)
		FreeObj(oRetorno)
		oRetorno := nil
		oCampos  := nil

		U_X011A01("CONSOLE", cValToChar(nCount) +" registro(s)" )
		lRet := .T.

	RECOVER
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sequencia de código após a ocorrência de erro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_X011A01("CONSOLE", "GETGENERICO - ERRO")
		conout(cDescErro)
		cErro := cDescErro
		lRet := .F.
	END SEQUENCE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o bloco de erro padrao do sistema  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ErrorBlock(bError)
Else
	cErro := "Tabela nao informada (parametro 'table')"
	U_X011A01("CONSOLE", "GETGENERICO - "+ cErro)
	lRet := .F.
Endif

RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetCount ºAutor  ³TOTVS CASCAVEL      º Data ³ 17/12/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para retonar a quantidade total de registros de uma  º±±
±±º          ³tabela conforme parametros de filtro.                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet: indica se processou com sucesso (T) ou erro (F)       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetCount( cJSONRet, cErro, table, filter )

Local aArea 		:= GetArea()
Local lRet   		:= .F.
Local cSql    		:= ""
Local cAliasQry 	:= GetNextAlias()
Local bError 		:= nil
Local cDescErro		:= ""

Default filter := ""

If ! Empty(table)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se informou o ALIAS da tabela, pega o nome da tabela   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Alltrim(table)) == 3
		table := RetSqlName(table)
	Endif
	
	U_X011A01("CONSOLE", "GETGENERICO/COUNT - "+ table +" FILTER: "+ filter )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta consulta SQL com base nos parâmetros de entrada  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := "SELECT COUNT(*) QTD "
	cSql += "FROM "+ table +" "
	If ! Empty(filter)
		cSql += "WHERE "+ filter
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o bloco de erro do sistema e atribui tratamento customizado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bError := ErrorBlock( { |oError| fCatchError( oError, @cDescErro ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sequencia de código protegido com captura de erro     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN SEQUENCE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a consulta SQL e monta JSON de retorno         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
		dbSelectArea(cAliasQry)
		dbGoTop()
		cJSONRet := '{'
		cJSONRet += '"table": "' + table +'",'
		cJSONRet += '"count": '  + cValToChar((cAliasQry)->QTD) +','
		cJSONRet += '"filter": "'+ filter +'"'
		cJSONRet += '}'
		U_X011A01("CONSOLE", cValToChar((cAliasQry)->QTD) +" registro(s)" )
		dbCloseArea()
		lRet := .T.

	RECOVER
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sequencia de código após a ocorrência de erro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_X011A01("CONSOLE", "GETGENERICO/COUNT - ERRO")
		conout(cDescErro)
		cErro := cDescErro
		lRet := .F.
	END SEQUENCE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o bloco de erro padrao do sistema  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ErrorBlock(bError)
Else
	cErro := "Tabela nao informada (parametro 'table')"
	U_X011A01("CONSOLE", "GETGENERICO/COUNT - "+ cErro )
	lRet := .F.
Endif

RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCatchErroºAutor  ³TOTVS CASCAVEL      º Data ³ 18/12/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para tratamento customizado de erros do sistema,     º±±
±±º          ³redirecionado através da função ErrorBlock()                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oError: objeto ERRORCLASS contendo erro gerado pelo sistema º±±
±±º          ³cDescErro: retorno da mensagem do erro (por referência)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCatchError(oError, cDescErro)

cDescErro := oError:Description
BREAK

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PUT       ºAutor  ³TOTVS CASCAVEL      º Data ³ 21/01/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Declaração do método PUT do webservice.                     º±±
±±º          ³Pode receber parâmetros por querystring (URL), exemplo:     º±±
±±º          ³  localhost:8036/rest/WSSIM3G?adapter=putGenerico           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³TABLE: Alias da tabela para atualizar                       º±±
±±º          ³RECNO: Lista de Recnos a atualizar			              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T. = Requisição realizada com sucesso.                     º±±
±±º          ³.F. = Inconsistência, deve executar função SetRestFault()   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD PUT WSRECEIVE table, modo WSSERVICE WSSIM3G

Local lRet  	:= .T.
Local cMetodo 	:= ""
Local cJSONRet	:= "{}"
Local cErro 	:= ""

Default self:table  	:= ""
Default self:modo	  	:= ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o tipo do conteúdo de retorno: JSON ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
self:SetContentType("application/json")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o parâmetro de entrada do método PUT                 ³
//³    http://localhost:8036/rest/WSSIM3G/putgenerico/          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(self:aURLParms) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtém nome do método a partir dos parâmetros da URL    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMetodo := upper(alltrim( self:aURLParms[1] ))
	If Len(self:aURLParms) > 1
		cMetodo += "/"+ upper(alltrim( self:aURLParms[2] ))
	Endif
	
	If cMetodo == "PUTGENERICO"
		
		cBody := self:GetContent()
		
		CONOUT("cBody: "+cBody)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna os registros selecionados conforme parametros  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(cBody) > 0 
			If fPutGenerico( @cJSONRet, @cErro, self:table, cBody, self:modo )
				self:SetResponse( cJSONRet )
			Else
				SetRestFault(400, EncodeUTF8(cErro))
				lRet := .F.
			Endif
		endif
	Else
		SetRestFault(400, EncodeUTF8("metodo nao implementado: "+ cMetodo))
		lRet := .F.
	Endif
Else
	SetRestFault(400, EncodeUTF8("metodo nao informado"))
	lRet := .F.
Endif

Return(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fPutGenericoºAutor  ³TOTVS CASCAVEL    º Data ³ 21/01/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para atualizar os registros de uma tabela conform    º±±
±±º          ³lista de recno enviada.                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet: indica se processou com sucesso (T) ou erro (F)       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Específico integração SIM3G / MASTERSALES                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fPutGenerico( cJSONRet, cErro, table, crecno, modo )

Local aArea 		:= GetArea()
Local lRet   		:= .F.
Local xConteudo 	:= nil
Local bError 		:= nil
Local cDescErro		:= ""
Local cLog      	:= ""
Local oRetorno
Local oCampos
Local cCpoExpo
Local nRecCnt		:= 1
Local aRecno		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Converte String em Vetor							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if Len(crecno) > 0
	aRecno := strtokarr (crecno, ",")
endif

If ! Empty(table) .And. Len(aRecno) > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se informou o ALIAS da tabela, pega o nome da tabela   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Alltrim(table)) == 3
		table := RetSqlName(table)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta informação para gerar LOG no console do WS       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLog := "RECNO: "+ crecno 

	U_X011A01("CONSOLE", "PUTGENERICO - "+ table +" "+ cLog )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o bloco de erro do sistema e atribui tratamento customizado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bError := ErrorBlock( { |oError| fCatchError( oError, @cDescErro ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sequencia de código protegido com captura de erro     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN SEQUENCE
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria objeto JSON para retorno  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oRetorno := JsonObject():new()
		oRetorno['result'] := {}
		oRecno := nil

		For nRecCnt := 1 to Len(aRecno)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorno dos recnos atualizados		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oItem := JsonObject():new()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Recno					    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCpoExpo	:= U_X011A01("CMPEXP",table)

			if ! U_X011A01("UPDEXP",table, cCpoExpo, VAL(aRecno[nRecCnt]), .t., modo )
				oItem['IT_STATUS']    := ".f."
			else
				oItem['IT_STATUS']    := ".t."
			endif
			
			oItem['IT_RECNO']     := aRecno[nRecCnt]
			
			aAdd( oRetorno['result'], oItem )
		Next nRecCnt
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Serializa o objeto JSON de retorno            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cJSONRet := FWJsonSerialize(oRetorno,.T.,.T.)
		FreeObj(oRetorno)
		oRetorno := nil
		oItem	 := nil

		U_X011A01("CONSOLE", cValToChar(nRecCnt-1) +" registro(s)" )
		lRet := .T.

		RECOVER
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sequencia de código após a ocorrência de erro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_X011A01("CONSOLE", "PUTGENERICO - ERRO")
		CONOUT(cDescErro)
		cErro := cDescErro
		lRet := .F.
	
	END SEQUENCE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o bloco de erro padrao do sistema  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ErrorBlock(bError)
Else
	cErro := "Tabela nao informada (parametro 'table')"
	U_X011A01("CONSOLE", "PUTGENERICO - "+ cErro)
	lRet := .F.
Endif

RestArea(aArea)

Return(lRet)
