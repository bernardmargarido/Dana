#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³S011A01   ³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 21/01/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WebService para integração com sistema Força de Vendas       ³±±
±±³          ³ Protheus x SIM3G (Wealthsystems) - EXPORTACAO DE CADASTROS   ³±±
±±³          ³ Endereço	http://<URL_SERVIDOR>/ws/S011A01.apw?WSDL           ³±±
±±³          ³ Cada Grupo de Empresa deve ter um JOB específico             ³±±
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
WSSERVICE WSSIM3G_CADASTROS DESCRIPTION "Integracao Forca de Vendas SIM3G - Exportacao de Cadastros"
	
	// Estrutura de Dados dos parâmetros de ENTRADA dos métodos
	WSDATA INcampo      				as String	// Campos para filtro
	WSDATA INvalor      				as String	// Valores dos campos de filtro
	WSDATA INopcao      				as String	// Opção: DELTA, FULL
	WSDATA INCPOADIC     				as String Optional	// Campos adicionais para retornar
	WSDATA INLogin  					as String Optional	// Chave de acesso em Base64 (usuario:senha)
	
	// Estrutura de Dados dos parâmetros de SAÍDA dos métodos
	WSDATA RetCidade 					as RetCidade
	WSDATA RetCondicaoPagamento			as RetCondicaoPagamento
	WSDATA RetCliente 					as RetCliente
	WSDATA RetClienteContato			as RetClienteContato
	WSDATA RetEstoque					as RetEstoque
	WSDATA RetFilial					as RetFilial
	WSDATA RetGrupoProduto				as RetGrupoProduto
	WSDATA RetNotaFiscal 				as RetNotaFiscal
	WSDATA RetNotaFiscalProduto			as RetNotaFiscalProduto
	WSDATA RetPais						as RetPais
	WSDATA RetPedido    				as RetPedido
	WSDATA RetPedidoProduto				as RetPedidoProduto
	WSDATA RetProduto					as RetProduto
	WSDATA RetTabelaPreco				as RetTabelaPreco
	WSDATA RetTabelaPrecoProduto		as RetTabelaPrecoProduto
	WSDATA RetTituloReceber				as RetTituloReceber
	WSDATA RetUnidadeFederativa			as RetUnidadeFederativa
	WSDATA RetUnidadeMedida				as RetUnidadeMedida
	WSDATA RetVendedor 					as RetVendedor
	WSDATA RetVendedorCliente			as RetVendedorCliente
//	WSDATA RetTipoPedido				as RetTipoPedido
	WSDATA RetTipoCliente				as RetTipoCliente
	WSDATA RetTipoFretePedido			as RetTipoFretePedido
	WSDATA RetTipoNotaFiscal			as RetTipoNotaFiscal
	WSDATA RetTipoOperacaoItemPedido	as RetTipoOperacaoItemPedido
	WSDATA RetTipoTitulo 				as RetTipoTitulo
	WSDATA RetTES						as RetTES
	WSDATA RetMETASVENDAS				as RetMETASVENDAS
	WSDATA RetNotaFiscalDev 			as RetNotaFiscalDev
	WSDATA RetNotaFiscalDevProduto		as RetNotaFiscalDevProduto
	WSDATA RetCatProd 					as RetCatProd
	WSDATA RetCatProdRelac    			as RetCatProdRelac
	WSDATA RetVeiculoOficina			as RetVeiculoOficina
	WSDATA RetOrdemServicoOficina		as RetOrdemServicoOficina
	WSDATA RetContratoParceria			as RetContratoParceria
	WSDATA RetTransportadora			as RetTransportadora
	WSDATA RetRegraNegocio 				as RetRegraNegocio
	
	// Módulo GFE
	WSDATA RetGU3 						as RetGU3
	WSDATA RetGWM 						as RetGWM
	WSDATA RetGW1 						as RetGW1

	// Descritor dos Métodos
	WSMETHOD GetCidade                  DESCRIPTION "Retorna Cadastro de Cidades"
	WSMETHOD GetCondicaoPagamento       DESCRIPTION "Retorna Cadastro de Condições de Pagamento"
	WSMETHOD GetCliente                 DESCRIPTION "Retorna Cadastro de Clientes"
	WSMETHOD GetClienteContato          DESCRIPTION "Retorna Cadastro de Contatos x Cliente"
	WSMETHOD GetEstoque                 DESCRIPTION "Retorna Saldos de Estoque de Produtos"
	WSMETHOD GetFilial                  DESCRIPTION "Retorna Cadastro de Filiais"
	WSMETHOD GetGrupoProduto            DESCRIPTION "Retorna Cadastro de Grupos de Produtos"
	WSMETHOD GetNotaFiscal              DESCRIPTION "Retorna Notas Fiscais de Venda x Vendedor"
	WSMETHOD GetNotaFiscalProduto       DESCRIPTION "Retorna Produtos x Nota Fiscal Venda"
	WSMETHOD GetPais                    DESCRIPTION "Retorna Cadastro de Paises"
	WSMETHOD GetPedido                  DESCRIPTION "Retorna Pedido de Venda"
	WSMETHOD GetPedidoProduto           DESCRIPTION "Retorna Produtos x Pedido de Venda"
	WSMETHOD GetProduto                 DESCRIPTION "Retorna Cadastro de Produtos"
	WSMETHOD GetTabelaPreco             DESCRIPTION "Retorna Cadastro de Tabelas de Preços"
	WSMETHOD GetTabelaPrecoProduto      DESCRIPTION "Retorna Cadastro de Produtos x Tabela de Preço"
	WSMETHOD GetTituloReceber           DESCRIPTION "Retorna Títulos a Receber x Cliente"
	WSMETHOD GetUnidadeFederativa       DESCRIPTION "Retorna Cadastro de Estados da Federação"
	WSMETHOD GetUnidadeMedida           DESCRIPTION "Retorna Cadastro de Unidades de Medidas dos Produtos"
	WSMETHOD GetVendedor                DESCRIPTION "Retorna Cadastro de Vendedores"
	WSMETHOD GetVendedorCliente         DESCRIPTION "Retorna Cadastro de Clientes x Vendedor"
	WSMETHOD GetTipoCliente				DESCRIPTION "Retorna Cadastro de Tipos de Cliente"
	WSMETHOD GetTipoNotaFiscal			DESCRIPTION "Retorna Tipos de Notas Fiscais"
//	WSMETHOD GetTipoPedido				DESCRIPTION "Retorna Tipos de Pedidos"
	WSMETHOD GetTipoFretePedido			DESCRIPTION "Retorna Tipos de Frete dos Pedidos"
	WSMETHOD GetTipoOperacaoItemPedido	DESCRIPTION "Retorna Tipos de Operacao do Item do Pedido"
	WSMETHOD GetTipoTitulo				DESCRIPTION "Retorna Tipos de Títulos C.Receber"
	WSMETHOD GetTES						DESCRIPTION "Retorna Cadastro de Tipos de Entrada e saida"
	WSMETHOD GetMETASVENDAS				DESCRIPTION "Retorna Cadastro de Metas de Vendas"	
	WSMETHOD GetNotaFiscalDev           DESCRIPTION "Retorna Notas Fiscais de Devolução de Venda"
	WSMETHOD GetNotaFiscalDevProduto    DESCRIPTION "Retorna Produtos x Nota Fiscal de Devolução de Venda"
	WSMETHOD GetCatProd                 DESCRIPTION "Retorna Cadastro de Categorias de Produtos"
	WSMETHOD GetCatProdRelac            DESCRIPTION "Retorna Amarração entre Categorias x Produto/Grupo"
	WSMETHOD GetVeiculoOficina			DESCRIPTION "Retorna Cadastro de Veículos do módulo de Oficinas"
	WSMETHOD GetOrdemServicoOficina		DESCRIPTION "Retorna Ordens de Serviço do módulo de Oficinas"
	WSMETHOD GetContratoParceria		DESCRIPTION "Retorna Contratos de Parceria"
	WSMETHOD GetTransportadora			DESCRIPTION "Retorna Cadastro de Transportadoras"
	WSMETHOD GetRegraNegocio 			DESCRIPTION "Retorna Cadastro de Regras de Negocio - Descontos"
	
	// Módulo GFE
	WSMETHOD GetDocCargaGFE				DESCRIPTION "Retorna cabeçalho do Documento de Carga (GFE)"
	WSMETHOD GetEmitenteGFE   			DESCRIPTION "Retorna cadastro de Emitentes de Transporte (GFE)"
	WSMETHOD GetFreteGFE 				DESCRIPTION "Retorna dados de Rateio Contábil de Frete (GFE)"

ENDWSSERVICE  



/*/ ESTRUTURA GENERICA DE CODIGO E DESCRICAO /*/
WSSTRUCT EstrutRetCodDescri
	WSDATA CODIGO						As String
	WSDATA DESCRICAO 					As String
	WSDATA OPERACAO 					As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT



/*/ ESTRUTURA GENERICA PARA CAMPOS ESPECÍFICOS /*/
WSSTRUCT EstrutRetCamposEspec
	WSDATA CAMPO						As String
	WSDATA VALOR  					As String
ENDWSSTRUCT



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Método GetCidade - Cadastro de Cidades                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT EstrutRetCidade
	WSDATA CC2_FILIAL       	As String
	WSDATA CC2_CODMUN       	As String
	WSDATA CC2_MUN      		As String
	WSDATA CC2_EST  			As String
	WSDATA OPERACAO 			As String Optional
	WSDATA CAMPOS_ESPEC		As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetCidade
	WSDATA aCidade	    		As Array of EstrutRetCidade Optional
ENDWSSTRUCT

WSMETHOD GetCidade WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetCidade WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetCidade")
cFilDel		:= U_X011A01("FILDEL","CC2",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","CC2",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetCidade "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT CC2.*, CC2.D_E_L_E_T_ DELET, CC2.R_E_C_N_O_ "
cSql += "FROM "+ RetSqlName("CC2")+" CC2 "
cSql += "WHERE 1=1 "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql += " ORDER BY CC2_FILIAL, CC2_EST, CC2_MUN "
cSql := ChangeQuery(cSql)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasQry,.F.,.T.)

Begin Transaction

DbSelectArea(cAliasQry)
While ! (cAliasQry)->(Eof())
	dbSelectArea("CC2")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetCidade")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetCidade:aCidade,WSClassNew("EstrutRetCidade"))
	::RetCidade:aCidade[nIdx]:CC2_FILIAL	:= Alltrim(CC2_FILIAL)
	::RetCidade:aCidade[nIdx]:CC2_CODMUN	:= Alltrim(CC2_CODMUN)
	::RetCidade:aCidade[nIdx]:CC2_MUN   	:= U_X011A01("CP1252",CC2_MUN)
	::RetCidade:aCidade[nIdx]:CC2_EST   	:= Alltrim(CC2_EST)
	::RetCidade:aCidade[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*',"D","")
	::RetCidade:aCidade[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetCidade:aCidade[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetCidade:aCidade[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetCidade:aCidade[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetCidade", Self:RetCidade:aCidade[nIdx])
	nIdx++
	
	U_X011A01("UPDEXP","CC2", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Método GetCondicaoPagamento - Cadastro de Condições de Pagamento        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
// CONDICAOPAGAMENTO
WSSTRUCT EstrutRetCondicaoPagamento
	WSDATA E4_FILIAL       				As String
	WSDATA E4_CODIGO       				As String
	WSDATA E4_TIPO        				As String	// 1,2,3,4,5,6,8,9, A e B
	WSDATA E4_COND   					As String	// Parametros da condição de pagamento
	WSDATA E4_DESCRI 		    		 	 As String	// Descricao da condicao
	WSDATA E4_MSBLQL  		    		As String	// Bloqueado
	WSDATA E4_DESCFIN 			 		As Float Optional
	WSDATA E4_DIADESC 			 		As Float Optional
	WSDATA E4_ACRSFIN 					As Float Optional
	WSDATA OPERACAO 						As String Optional
	WSDATA CAMPOS_ESPEC					As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetCondicaoPagamento
	WSDATA aCondicaoPagamento	        As Array of EstrutRetCondicaoPagamento Optional
ENDWSSTRUCT

WSMETHOD GetCondicaoPagamento WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetCondicaoPagamento WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .T.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetCondicaoPagamento")
cFilDel		:= U_X011A01("FILDEL","SE4",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SE4",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetCondicaoPagamento "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SE4.*, SE4.D_E_L_E_T_ DELET, SE4.R_E_C_N_O_ "
cSql += "FROM "+ RetSqlName("SE4") +" SE4 "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND SE4.E4_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)

Begin Transaction

DbSelectArea(cAliasQry)
While ! (cAliasQry)->(Eof())
	dbSelectArea("SE4")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetCondicaoPagamento")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetCondicaoPagamento:aCondicaoPagamento,WSClassNew("EstrutRetCondicaoPagamento"))
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_FILIAL 	:= E4_FILIAL
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_CODIGO 	:= E4_CODIGO
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_TIPO		:= E4_TIPO
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_COND	  	:= Alltrim(E4_COND)
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_DESCRI  	:= U_X011A01("CP1252",E4_DESCRI)
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_MSBLQL	:= IF( FieldPos("E4_MSBLQL") > 0, E4_MSBLQL, "2" )
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_DESCFIN	:= E4_DESCFIN
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_DIADESC	:= E4_DIADESC
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:E4_ACRSFIN	:= E4_ACRSFIN
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:OPERACAO	:= IF((cAliasQry)->DELET == '*' .or. E4_X_SIM3G == "N","D","")
	::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetCondicaoPagamento:aCondicaoPagamento[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetCondicaoPagamento", Self:RetCondicaoPagamento:aCondicaoPagamento[nIdx]);
	
	U_X011A01("UPDEXP","SE4", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	nIdx++
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction

(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// CLIENTECONTATO
WSSTRUCT EstrutRetClienteContato
	WSDATA U5_FILIAL      			As String
	WSDATA U5_CODCONT       		As String	// CODIGO DO CONTATO
	WSDATA U5_CONTAT				As String	// CONTATO
	WSDATA U5_CPF					As String	// CPF DO CONTATO
	WSDATA U5_RG  					As String	// RG DO CONTATO
	WSDATA U5_EMAIL					As String	// EMAIL
	WSDATA U5_URL					As String	// SITE
	WSDATA U5_MSBLQL				As String	// CONTATO BLOQUEADO
	WSDATA U5_SEXO					As String	// SEXO
	WSDATA U5_NIVER					As Date  	// DATA DE NASCIMENTO
	WSDATA U5_CIVIL				 	As String	// ESTADO CIVIL
	WSDATA U5_CONJUGE				As String	// NOME DO CONJUGE
	WSDATA U5_FUNCAO				As String	// FUNCAO DO CONTATO
	WSDATA U5_DEPTO					As String	// DEPARTAMENTO DO CONTATO
	WSDATA U5_END  	  				As String	// ENDERECO DO CONTATO
	WSDATA U5_BAIRRO  				As String	// BAIRRO DO CONTATO
	WSDATA U5_MUN      				As String	// MUNICIPIO
	WSDATA U5_EST    				As String	// ESTADO
	WSDATA U5_CEP    				As String	// CEP
	WSDATA U5_PAIS 					As String	// PAÍS
	WSDATA U5_DDD    				As String	// CÓDIGO DE DDD
	WSDATA U5_FONE   				As String	// NUMERO DE TELEFONE
	WSDATA U5_CELULAR  				As String	// NUMERO DO CELULAR
	WSDATA U5_FCOM1  				As String	// TELEFONE COMERCIAL 1
	WSDATA U5_FCOM2  				As String	// TELEFONE COMERCIAL 2
	WSDATA UM_DESC      			As String	// DESCRICAO CARGO
	WSDATA QB_DESCRIC         		As String	// DESCRICAO DEPARTAMENTO
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT	
WSSTRUCT RetClienteContato
	WSDATA aClienteContato  		As Array of EstrutRetClienteContato Optional
ENDWSSTRUCT	

WSMETHOD GetClienteContato WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetClienteContato WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel1	:= ""
Local cFilDel2	:= ""
Local cFilDel3	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetClienteContato")
cFilDel1	:= U_X011A01("FILDEL","SU5",INOPCAO)
cFilDel2	:= U_X011A01("FILDEL","SA1",INOPCAO)
cFilDel3	:= U_X011A01("FILDEL","AC8",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SU5",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetClienteContato "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SU5.R_E_C_N_O_, SU5.D_E_L_E_T_ U5DELET, AC8.D_E_L_E_T_ AC8DELET, SA1.D_E_L_E_T_ A1DELET, UM_DESC, QB_DESCRIC, A1_X_SIM3G "
cSql += "FROM "+ RetSqlName("SA1") +" SA1 "
cSql += "INNER JOIN "+ RetSqlName("AC8") +" AC8 ON AC8_FILENT = A1_FILIAL AND AC8_CODENT = A1_COD || A1_LOJA AND AC8_ENTIDA = 'SA1' "
cSql += "INNER JOIN "+ RetSqlName("SU5") +" SU5 ON U5_CODCONT = AC8_CODCON "
cSql += "LEFT  JOIN "+ RetSqlName("SUM") +" SUM ON UM_CARGO   = U5_FUNCAO AND SUM.D_E_L_E_T_ = '' AND UM_FILIAL = A1_FILIAL "
cSql += "LEFT  JOIN "+ RetSqlName("SQB") +" SQB ON QB_DEPTO   = U5_DEPTO  AND SQB.D_E_L_E_T_ = '' AND QB_FILIAL = A1_FILIAL "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND SA1.A1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel1)
	cSql += " AND "+ cFilDel1 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFilDel2)
	cSql += " AND "+ cFilDel2 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFilDel3)
	cSql += " AND "+ cFilDel3 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)

Begin Transaction

DbSelectArea(cAliasQry)
While ! (cAliasQry)->(Eof())
	dbSelectArea("SU5")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetClienteContato")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetClienteContato:aClienteContato,WSClassNew("EstrutRetClienteContato"))
	::RetClienteContato:aClienteContato[nIdx]:U5_FILIAL  		:= U5_FILIAL
	::RetClienteContato:aClienteContato[nIdx]:U5_CODCONT 		:= U5_CODCONT
	::RetClienteContato:aClienteContato[nIdx]:U5_CONTAT 		:= U_X011A01("CP1252",U5_CONTAT)
	::RetClienteContato:aClienteContato[nIdx]:U5_CPF     		:= Alltrim(U5_CPF)
	::RetClienteContato:aClienteContato[nIdx]:U5_RG     		:= Alltrim(U5_RG)
	::RetClienteContato:aClienteContato[nIdx]:U5_EMAIL  		:= U_X011A01("CP1252",U5_EMAIL)
	::RetClienteContato:aClienteContato[nIdx]:U5_URL     		:= U_X011A01("CP1252",U5_URL)
	::RetClienteContato:aClienteContato[nIdx]:U5_MSBLQL 	   	:= U5_MSBLQL
	::RetClienteContato:aClienteContato[nIdx]:U5_SEXO    		:= U5_SEXO
	::RetClienteContato:aClienteContato[nIdx]:U5_NIVER   		:= U5_NIVER
	::RetClienteContato:aClienteContato[nIdx]:U5_CIVIL  		:= Alltrim(U5_CIVIL)
	::RetClienteContato:aClienteContato[nIdx]:U5_CONJUGE 		:= U_X011A01("CP1252",U5_CONJUGE)
	::RetClienteContato:aClienteContato[nIdx]:U5_FUNCAO  		:= U5_FUNCAO
	::RetClienteContato:aClienteContato[nIdx]:U5_DEPTO   		:= U5_DEPTO
	::RetClienteContato:aClienteContato[nIdx]:U5_END  	  		:= U_X011A01("CP1252",U5_END)
	::RetClienteContato:aClienteContato[nIdx]:U5_BAIRRO  		:= U_X011A01("CP1252",U5_BAIRRO)
	::RetClienteContato:aClienteContato[nIdx]:U5_MUN      		:= U_X011A01("CP1252",U5_MUN)
	::RetClienteContato:aClienteContato[nIdx]:U5_EST    		:= U5_EST
	::RetClienteContato:aClienteContato[nIdx]:U5_CEP    		:= U_X011A01("CP1252",U5_CEP)
	::RetClienteContato:aClienteContato[nIdx]:U5_PAIS 			:= U5_PAIS
	::RetClienteContato:aClienteContato[nIdx]:U5_DDD    		:= U_X011A01("CP1252",U5_DDD)
	::RetClienteContato:aClienteContato[nIdx]:U5_FONE   		:= U_X011A01("CP1252",U5_FONE)
	::RetClienteContato:aClienteContato[nIdx]:U5_CELULAR  		:= U_X011A01("CP1252",U5_CELULAR)
	::RetClienteContato:aClienteContato[nIdx]:U5_FCOM1  		:= U_X011A01("CP1252",U5_FCOM1)
	::RetClienteContato:aClienteContato[nIdx]:U5_FCOM2  		:= U_X011A01("CP1252",U5_FCOM2)
	::RetClienteContato:aClienteContato[nIdx]:UM_DESC    		:= U_X011A01("CP1252",(cAliasQry)->UM_DESC)
	::RetClienteContato:aClienteContato[nIdx]:QB_DESCRIC   		:= U_X011A01("CP1252",(cAliasQry)->QB_DESCRIC)
	::RetClienteContato:aClienteContato[nIdx]:OPERACAO			:= IF((cAliasQry)->U5DELET == '*' .or. (cAliasQry)->AC8DELET == '*' .or. (cAliasQry)->A1DELET == '*' .or. (cAliasQry)->A1_X_SIM3G == "N","D","")
	::RetClienteContato:aClienteContato[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetClienteContato:aClienteContato[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetClienteContato:aClienteContato[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetClienteContato:aClienteContato[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetClienteContato", Self:RetClienteContato:aClienteContato[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SU5", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction

(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// ESTOQUE
WSSTRUCT EstrutRetEstoque
	WSDATA B2_FILIAL 					As String
	WSDATA B2_COD     					As String
	WSDATA B2_LOCAL   					As String
	WSDATA B2_QATU    					As Float	// Saldo Atual em Quantidade
	WSDATA B2_VATU1   					As Float	// Saldo Atual em Valor
	WSDATA B2_CM1     					As Float 	// Custo Unitario do Produto
	WSDATA B2_QEMP   					As Float 	// Quantidade Empenhada
	WSDATA B2_QEMP2   					As Float 	// Quantidade Empenhada 2a UN
	WSDATA B2_QTSEGUM					As Float	// Quantidade 2a UN
	WSDATA B2_RESERVA     				As Float	// Quantidade Reservada
	WSDATA B2_QPEDVEN     				As Float	// Quantidade Pedidos de Venda
	WSDATA B2_QPEDVE2  					As Float 	// Quantidade Pedidos de Venda 2a UN
	WSDATA B2_RESERV2   				As Float 	// Quantidade Reservada 2a UN
	WSDATA B2_USAI   					As Date		// Data Ultima Saida Estoque
	WSDATA B2_DINVENT					As Date 	// Data Ultimo Inventario
	WSDATA B2_LOCALIZ     				As String	// Endereco
	WSDATA B2_STATUS   					As String 	// 1=Disponivel; 2=Indisponivel
	WSDATA B1_DESC    					As String
	WSDATA NNR_DESCRI  					As String	// Descricao do Local
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT
WSSTRUCT RetEstoque
	WSDATA aEstoque 					As Array of EstrutRetEstoque Optional
ENDWSSTRUCT

WSMETHOD GetEstoque WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetEstoque WSSERVICE WSSIM3G_CADASTROS
Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE := ""
Local cFilDel1	:= ""
Local cFilDel2	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE 	:= U_X011A01("FILSQL","GetEstoque")
cFilDel1	:= U_X011A01("FILDEL","SB1",INOPCAO)
cFilDel2	:= U_X011A01("FILDEL","SB2",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SB2",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetEstoque "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SB2.R_E_C_N_O_, B1_DESC, NNR_DESCRI, SB2.D_E_L_E_T_ B2DELET, SB1.D_E_L_E_T_ B1DELET, B1_X_SIM3G "
cSql += "FROM "+ RetSqlName("SB2")+" SB2 "
cSql += "INNER JOIN "+ RetSqlName("SB1")+ " SB1 ON B2_COD = B1_COD "
cSql += "LEFT  JOIN "+ RetSqlName("NNR")+ " NNR ON NNR_CODIGO = B1_COD AND NNR.D_E_L_E_T_ = '' "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND SB1.B1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel1)
	cSql += " AND "+ cFilDel1 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFilDel2)
	cSql += " AND "+ cFilDel2 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)

Begin Transaction

DbSelectArea(cAliasQry)

While ! (cAliasQry)->(Eof())
	dbSelectArea("SB2")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetEstoque")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetEstoque:aEstoque,WSClassNew("EstrutRetEstoque"))
	::RetEstoque:aEstoque[nIdx]:B2_FILIAL 			:= B2_FILIAL
	::RetEstoque:aEstoque[nIdx]:B2_COD   			:= B2_COD
	::RetEstoque:aEstoque[nIdx]:B2_LOCAL 			:= B2_LOCAL
	::RetEstoque:aEstoque[nIdx]:B2_QATU  			:= B2_QATU
	::RetEstoque:aEstoque[nIdx]:B2_VATU1 			:= B2_VATU1
	::RetEstoque:aEstoque[nIdx]:B2_CM1  			:= B2_CM1
	::RetEstoque:aEstoque[nIdx]:B2_QEMP  			:= B2_QEMP
	::RetEstoque:aEstoque[nIdx]:B2_QEMP2 			:= B2_QEMP2
	::RetEstoque:aEstoque[nIdx]:B2_QTSEGUM			:= B2_QTSEGUM
	::RetEstoque:aEstoque[nIdx]:B2_RESERVA			:= B2_RESERVA
	::RetEstoque:aEstoque[nIdx]:B2_QPEDVEN			:= B2_QPEDVEN
	::RetEstoque:aEstoque[nIdx]:B2_QPEDVE2			:= B2_QPEDVE2
	::RetEstoque:aEstoque[nIdx]:B2_RESERVA			:= B2_RESERVA
	::RetEstoque:aEstoque[nIdx]:B2_RESERV2			:= B2_RESERV2
	::RetEstoque:aEstoque[nIdx]:B2_USAI   			:= B2_USAI	//DATA
	::RetEstoque:aEstoque[nIdx]:B2_DINVENT			:= B2_DINVENT	//DATA
	::RetEstoque:aEstoque[nIdx]:B2_LOCALIZ			:= U_X011A01("CP1252",B2_LOCALIZ)
	::RetEstoque:aEstoque[nIdx]:B2_STATUS			:= B2_STATUS
	::RetEstoque:aEstoque[nIdx]:B1_DESC  			:= U_X011A01("CP1252",(cAliasQry)->B1_DESC)
	::RetEstoque:aEstoque[nIdx]:NNR_DESCRI			:= U_X011A01("CP1252",(cAliasQry)->NNR_DESCRI)
	::RetEstoque:aEstoque[nIdx]:OPERACAO			:= IF((cAliasQry)->B1DELET == '*' .or. (cAliasQry)->B2DELET == '*' .or. (cAliasQry)->B1_X_SIM3G == "N","D","")
	::RetEstoque:aEstoque[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetEstoque:aEstoque[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetEstoque:aEstoque[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetEstoque:aEstoque[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetEstoque", Self:RetEstoque:aEstoque[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SB2", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())

EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction

(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.





// TituloReceber
WSSTRUCT EstrutRetTituloReceber
	WSDATA E1_FILIAL 			As String
	WSDATA E1_PREFIXO 			As String
	WSDATA E1_NUM     			As String
	WSDATA E1_PARCELA 			As String
	WSDATA E1_TIPO   			As String
	WSDATA E1_CLIENTE 			As String
	WSDATA E1_LOJA   			As String
	WSDATA E1_NOMCLI  			As String
	WSDATA E1_EMISSAO  			As Date  	// Data emissão
	WSDATA E1_VENCTO 			As Date  	// Data vencimento
	WSDATA E1_VENCREA			As Date  	// Data vencimento real (dia util)
	WSDATA E1_VENCORI			As Date  	// Data vencimento original
	WSDATA E1_BAIXA  			As Date  	// Data baixa
	WSDATA E1_EMIS1  			As Date  	// Data digitação
	WSDATA E1_VALOR 			As Float
	WSDATA E1_SALDO    			As Float
	WSDATA E1_BASEIRF			As Float
	WSDATA E1_IRRF    			As Float
	WSDATA E1_ISS    			As Float
	WSDATA E1_INSS    			As Float
	WSDATA E1_CSLL    			As Float
	WSDATA E1_COFINS   			As Float
	WSDATA E1_PIS    			As Float
	WSDATA E1_HIST     			As String
	WSDATA E1_SITUACA  			As String	// Situação ???????????
	WSDATA E1_VEND1    			As String
	WSDATA E1_VEND2    			As String
	WSDATA E1_VEND3    			As String
	WSDATA E1_VEND4    			As String
	WSDATA E1_VEND5    			As String
	WSDATA E1_MULTA    			As Float 	// Valor Multa
	WSDATA E1_JUROS  			As Float 	// Valor Juros
	WSDATA E1_VALJUR   			As Float
	WSDATA E1_PORCJUR  			As Float
	WSDATA E1_ACRESC  			As Float
	WSDATA E1_DECRESC  			As Float
	WSDATA E1_DESCFIN 			As Float 	// Percentual desconto
	WSDATA E1_DIADESC 			As Float 	// Dias desconto
	WSDATA E1_MOEDA    			As Integer
	WSDATA E1_PORTADO  			As String
	WSDATA E1_AGEDEP			As String
	WSDATA E1_NUMBCO   			As String
	WSDATA E1_CODBAR			As String
	WSDATA E1_CODDIG 			As String
	WSDATA E1_PEDIDO			As String
	WSDATA E1_NUMNOTA 			As String
	WSDATA E1_SERIE  			As String
	WSDATA E1_STATUS  			As String	// Status ????????????
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT	
WSSTRUCT RetTituloReceber
	WSDATA aTituloReceber			As Array of EstrutRetTituloReceber Optional
ENDWSSTRUCT	
	
WSMETHOD GetTituloReceber WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTituloReceber WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetTituloReceber")
cFilDel		:= U_X011A01("FILDEL","SE1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SE1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetTituloReceber "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SE1.R_E_C_N_O_, SE1.D_E_L_E_T_ DELET, A1_X_SIM3G "
cSql += "FROM "+ RetSqlName("SE1")+" SE1 "
cSql += "INNER JOIN "+ RetSqlName("SA1")+" SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
cSql += "WHERE SA1.D_E_L_E_T_ = ' ' "
If ! lFullDel
	cSql += " AND SA1.A1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SE1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetTituloReceber")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetTituloReceber:aTituloReceber,WSClassNew("EstrutRetTituloReceber"))
	::RetTituloReceber:aTituloReceber[nIdx]:E1_FILIAL		:= E1_FILIAL
	::RetTituloReceber:aTituloReceber[nIdx]:E1_PREFIXO		:= E1_PREFIXO
	::RetTituloReceber:aTituloReceber[nIdx]:E1_NUM    		:= E1_NUM
	::RetTituloReceber:aTituloReceber[nIdx]:E1_PARCELA		:= E1_PARCELA
	::RetTituloReceber:aTituloReceber[nIdx]:E1_TIPO  		:= E1_TIPO
	::RetTituloReceber:aTituloReceber[nIdx]:E1_CLIENTE		:= E1_CLIENTE
	::RetTituloReceber:aTituloReceber[nIdx]:E1_LOJA 		:= E1_LOJA
	::RetTituloReceber:aTituloReceber[nIdx]:E1_NOMCLI  		:= U_X011A01("CP1252",E1_NOMCLI)
	::RetTituloReceber:aTituloReceber[nIdx]:E1_EMISSAO 		:= E1_EMISSAO
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VENCTO  		:= E1_VENCTO
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VENCREA 		:= E1_VENCREA
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VENCORI 		:= E1_VENCORI
	::RetTituloReceber:aTituloReceber[nIdx]:E1_BAIXA  		:= E1_BAIXA
	::RetTituloReceber:aTituloReceber[nIdx]:E1_EMIS1  		:= E1_EMIS1
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VALOR  		:= E1_VALOR
	::RetTituloReceber:aTituloReceber[nIdx]:E1_SALDO  		:= E1_SALDO
	::RetTituloReceber:aTituloReceber[nIdx]:E1_BASEIRF 		:= E1_BASEIRF
	::RetTituloReceber:aTituloReceber[nIdx]:E1_IRRF  		:= E1_IRRF
	::RetTituloReceber:aTituloReceber[nIdx]:E1_ISS  		:= E1_ISS
	::RetTituloReceber:aTituloReceber[nIdx]:E1_INSS  		:= E1_INSS
	::RetTituloReceber:aTituloReceber[nIdx]:E1_CSLL  		:= E1_CSLL
	::RetTituloReceber:aTituloReceber[nIdx]:E1_COFINS  		:= E1_COFINS
	::RetTituloReceber:aTituloReceber[nIdx]:E1_PIS 			:= E1_PIS
	::RetTituloReceber:aTituloReceber[nIdx]:E1_HIST 		:= U_X011A01("CP1252",E1_HIST)
	::RetTituloReceber:aTituloReceber[nIdx]:E1_SITUACA  	:= E1_SITUACA
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VEND1 		:= E1_VEND1
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VEND2 		:= E1_VEND2
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VEND3 		:= E1_VEND3
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VEND4 		:= E1_VEND4
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VEND5 		:= E1_VEND5
	::RetTituloReceber:aTituloReceber[nIdx]:E1_MULTA 		:= E1_MULTA
	::RetTituloReceber:aTituloReceber[nIdx]:E1_JUROS 		:= E1_JUROS
	::RetTituloReceber:aTituloReceber[nIdx]:E1_VALJUR 		:= E1_VALJUR
	::RetTituloReceber:aTituloReceber[nIdx]:E1_PORCJUR 		:= E1_PORCJUR
	::RetTituloReceber:aTituloReceber[nIdx]:E1_ACRESC 		:= E1_ACRESC
	::RetTituloReceber:aTituloReceber[nIdx]:E1_DECRESC 		:= E1_DECRESC
	::RetTituloReceber:aTituloReceber[nIdx]:E1_DESCFIN 		:= E1_DESCFIN
	::RetTituloReceber:aTituloReceber[nIdx]:E1_DIADESC 		:= E1_DIADESC
	::RetTituloReceber:aTituloReceber[nIdx]:E1_MOEDA 		:= E1_MOEDA
	::RetTituloReceber:aTituloReceber[nIdx]:E1_PORTADO 		:= E1_PORTADO
	::RetTituloReceber:aTituloReceber[nIdx]:E1_AGEDEP 		:= E1_AGEDEP
	::RetTituloReceber:aTituloReceber[nIdx]:E1_NUMBCO 		:= U_X011A01("CP1252",E1_NUMBCO)
	::RetTituloReceber:aTituloReceber[nIdx]:E1_CODBAR 		:= U_X011A01("CP1252",E1_CODBAR)
	::RetTituloReceber:aTituloReceber[nIdx]:E1_CODDIG 		:= U_X011A01("CP1252",E1_CODDIG)
	::RetTituloReceber:aTituloReceber[nIdx]:E1_PEDIDO 		:= E1_PEDIDO
	::RetTituloReceber:aTituloReceber[nIdx]:E1_NUMNOTA 		:= E1_NUMNOTA
	::RetTituloReceber:aTituloReceber[nIdx]:E1_SERIE 		:= E1_SERIE
	::RetTituloReceber:aTituloReceber[nIdx]:E1_STATUS 		:= E1_STATUS
	::RetTituloReceber:aTituloReceber[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*' .or. (cAliasQry)->A1_X_SIM3G == "N","D","")
	::RetTituloReceber:aTituloReceber[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetTituloReceber:aTituloReceber[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetTituloReceber:aTituloReceber[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetTituloReceber:aTituloReceber[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetTituloReceber", Self:RetTituloReceber:aTituloReceber[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SE1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// FILIAL
WSSTRUCT EstrutRetFilial
	WSDATA M0_CODIGO  				 	As String
	WSDATA M0_CODFIL  			 		As String
	WSDATA M0_FILIAL  			 		As String
	WSDATA M0_NOME   					As String
	WSDATA M0_NOMECOM	 				As String
	WSDATA M0_ENDCOB  					As String
	WSDATA M0_ENDENT  					As String
	WSDATA M0_CIDCOB	 				As String
	WSDATA M0_CIDENT	 				As String
	WSDATA M0_ESTCOB			 		As String
	WSDATA M0_ESTENT			 		As String
	WSDATA M0_CEPCOB  			 		As String
	WSDATA M0_CEPENT  			 		As String
	WSDATA M0_BAIRCOB			 		As String
	WSDATA M0_BAIRENT			 		As String
	WSDATA M0_COMPCOB  			 		As String
	WSDATA M0_COMPENT  			 		As String
	WSDATA M0_CGC    					As String
	WSDATA M0_INSC   					As String
	WSDATA M0_TEL     					As String
	WSDATA M0_FAX     					As String
	WSDATA M0_TPINSC  			 		As String
	WSDATA M0_INSCM  			 		As String
	WSDATA M0_CNAE    			 		As String
	WSDATA M0_CODMUN  			 		As String
	WSDATA CODEMP    					As String
	WSDATA CODUNI    					As String
	WSDATA OPERACAO 					As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  		
WSSTRUCT RetFilial
	WSDATA aFilial       				As Array of EstrutRetFilial Optional
ENDWSSTRUCT

WSMETHOD GetFilial WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetFilial WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltroPE := ""
Local cFiltro	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local cEmp 		:= ""
Local cUni 		:= ""
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltroPE 	:= U_X011A01("FILSQL","GetFilial")
cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
cEmp 		:= Alltrim( FWSM0Layout(nil, 1) ) // EE
cUni 		:= Alltrim( FWSM0Layout(nil, 2) ) // UU

U_X011A01("CONSOLE","Exportacao SIM3G: GetFilial "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

dbSelectArea("SM0")
dbSetOrder(1)
dbGoTop()
While !EOF()
	// Exporta somente as empresas/filiais do GRUPO logado no WebService
	If SM0->M0_CODIGO == cEmpAnt
		
		// Ponto de Entrada para campos específicos (array)
		aCpoEspec := U_X011A01("CMPESPEC","GetFilial")
		
		// Campos específicos via parâmetro de entrada
		aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
		
		AADD(::RetFilial:aFilial,WSClassNew("EstrutRetFilial")) 
		::RetFilial:aFilial[nIdx]:M0_CODIGO 	:= M0_CODIGO
		::RetFilial:aFilial[nIdx]:M0_CODFIL		:= M0_CODFIL
		::RetFilial:aFilial[nIdx]:M0_FILIAL		:= Alltrim(M0_FILIAL)
		::RetFilial:aFilial[nIdx]:M0_NOME		:= U_X011A01("CP1252",M0_NOME)
		::RetFilial:aFilial[nIdx]:M0_NOMECOM	:= U_X011A01("CP1252",M0_NOMECOM)
		::RetFilial:aFilial[nIdx]:M0_ENDCOB 	:= U_X011A01("CP1252",M0_ENDCOB)
		::RetFilial:aFilial[nIdx]:M0_ENDENT	 	:= U_X011A01("CP1252",M0_ENDENT)
		::RetFilial:aFilial[nIdx]:M0_CIDCOB		:= U_X011A01("CP1252",M0_CIDCOB)
		::RetFilial:aFilial[nIdx]:M0_CIDENT		:= U_X011A01("CP1252",M0_CIDENT)
		::RetFilial:aFilial[nIdx]:M0_ESTCOB		:= U_X011A01("CP1252",M0_ESTCOB)
		::RetFilial:aFilial[nIdx]:M0_ESTENT		:= U_X011A01("CP1252",M0_ESTENT)
		::RetFilial:aFilial[nIdx]:M0_CEPCOB		:= Alltrim(M0_CEPCOB)
		::RetFilial:aFilial[nIdx]:M0_CEPENT		:= Alltrim(M0_CEPENT)
		::RetFilial:aFilial[nIdx]:M0_BAIRCOB	:= U_X011A01("CP1252",M0_BAIRCOB)
		::RetFilial:aFilial[nIdx]:M0_BAIRENT	:= U_X011A01("CP1252",M0_BAIRENT)
		::RetFilial:aFilial[nIdx]:M0_COMPCOB	:= U_X011A01("CP1252",M0_COMPCOB)
		::RetFilial:aFilial[nIdx]:M0_COMPENT	:= U_X011A01("CP1252",M0_COMPENT)
		::RetFilial:aFilial[nIdx]:M0_CGC		:= Alltrim(M0_CGC)
		::RetFilial:aFilial[nIdx]:M0_INSC		:= Alltrim(M0_INSC)
		::RetFilial:aFilial[nIdx]:M0_TEL		:= U_X011A01("CP1252",M0_TEL)
		::RetFilial:aFilial[nIdx]:M0_FAX		:= U_X011A01("CP1252",M0_FAX)
		::RetFilial:aFilial[nIdx]:M0_TPINSC		:= Alltrim(M0_TPINSC)
		::RetFilial:aFilial[nIdx]:M0_INSCM		:= U_X011A01("CP1252",M0_INSCM)
		::RetFilial:aFilial[nIdx]:M0_CNAE		:= Alltrim(M0_CNAE)
		::RetFilial:aFilial[nIdx]:M0_CODMUN		:= M0_CODMUN
		::RetFilial:aFilial[nIdx]:OPERACAO		:= IF(SM0->(Deleted()),"D","")
		::RetFilial:aFilial[nIdx]:CAMPOS_ESPEC	:= {}
		::RetFilial:aFilial[nIdx]:CODEMP   		:= Substr(M0_CODFIL,1,Len(cEmp))
		::RetFilial:aFilial[nIdx]:CODUNI   		:= Substr(M0_CODFIL,1,Len(cEmp)+Len(cUni))

		// Tratativa para campos específicos (customizados)
		For i := 1 to Len(aCpoEspec)
			AADD(::RetFilial:aFilial[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
			::RetFilial:aFilial[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
			::RetFilial:aFilial[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
		Next i
		nIdx++
	Endif
	dbSkip()
Enddo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// GRUPOPRODUTO
WSSTRUCT EstrutRetGrupoProduto
	WSDATA BM_FILIAL       				As String
	WSDATA BM_GRUPO  	   				As String
	WSDATA BM_DESC      				As String 
	WSDATA BM_STATUS       				As String
	WSDATA BM_TIPGRU					As String
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  		
WSSTRUCT RetGrupoProduto
	WSDATA aGrupoProduto				As Array of EstrutRetGrupoProduto Optional
ENDWSSTRUCT

WSMETHOD GetGrupoProduto WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetGrupoProduto WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetGrupoProduto")
cFilDel		:= U_X011A01("FILDEL","SBM",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SBM",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetGrupoProduto "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SBM.R_E_C_N_O_, SBM.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SBM") + " SBM "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND SBM.BM_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SBM")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetGrupoProduto")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetGrupoProduto:aGrupoProduto,WSClassNew("EstrutRetGrupoProduto"))
	::RetGrupoProduto:aGrupoProduto[nIdx]:BM_FILIAL 			:= BM_FILIAL
	::RetGrupoProduto:aGrupoProduto[nIdx]:BM_GRUPO				:= BM_GRUPO
	::RetGrupoProduto:aGrupoProduto[nIdx]:BM_DESC				:= U_X011A01("CP1252",BM_DESC)
	::RetGrupoProduto:aGrupoProduto[nIdx]:BM_STATUS				:= Alltrim(BM_STATUS)
	::RetGrupoProduto:aGrupoProduto[nIdx]:BM_TIPGRU 	 		:= Alltrim(BM_TIPGRU)
	::RetGrupoProduto:aGrupoProduto[nIdx]:OPERACAO				:= IF((cAliasQry)->DELET == '*' .or. BM_X_SIM3G == "N","D","")
	::RetGrupoProduto:aGrupoProduto[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetGrupoProduto:aGrupoProduto[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetGrupoProduto:aGrupoProduto[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetGrupoProduto:aGrupoProduto[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetGrupoProduto", Self:RetGrupoProduto:aGrupoProduto[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SBM", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.





// NOTA FISCAL
WSSTRUCT EstrutRetNotaFiscal
	WSDATA F2_FILIAL    			As String
	WSDATA F2_DOC     				As String
	WSDATA F2_SERIE   				As String
	WSDATA F2_CLIENTE  				As String
	WSDATA F2_LOJA    				As String
	WSDATA F2_TIPO    				As String
	WSDATA F2_ESPECIE				As String
	WSDATA F2_VEND1    				As String
	WSDATA F2_VEND2    				As String
	WSDATA F2_VEND3    				As String
	WSDATA F2_VEND4    				As String
	WSDATA F2_VEND5    				As String
	WSDATA F2_COND     				As String
	WSDATA F2_DUPL    				As String
	WSDATA F2_EST    				As String
	WSDATA F2_TIPOCLI				As String
	WSDATA F2_NFORI					As String
	WSDATA F2_SERIORI				As String
	WSDATA F2_TRANSP				As String
	WSDATA F2_REDESP				As String
	WSDATA F2_TPFRETE				As String
	WSDATA F2_HORA    				As String
	WSDATA F2_MOEDA    				As Integer
	WSDATA F2_CHVNFE				As String
	WSDATA F2_HORNFE				As String
	WSDATA F2_MENNOTA				As String
	WSDATA F2_EMISSAO  				As Date
	WSDATA F2_FRETE    				As Float
	WSDATA F2_SEGURO   				As Float
	WSDATA F2_ICMFRET  				As Float
	WSDATA F2_VALBRUT  				As Float
	WSDATA F2_VALICM   				As Float
	WSDATA F2_BASEICM  				As Float
	WSDATA F2_VALIPI   				As Float
	WSDATA F2_BASEIPI				As Float
	WSDATA F2_VALMERC				As Float
	WSDATA F2_DESCONT				As Float
	WSDATA F2_ICMSRET  				As Float
	WSDATA F2_PLIQUI				As Float
	WSDATA F2_PBRUTO				As Float
	WSDATA F2_VALFAT				As Float
	WSDATA F2_BASEISS				As Float
	WSDATA F2_VALISS				As Float
	WSDATA F2_VALINSS				As Float
	WSDATA F2_CONTSOC				As Float
	WSDATA F2_BRICMS				As Float
	WSDATA F2_FRETAUT				As Float
	WSDATA F2_DESPESA				As Float
	WSDATA F2_VALCSLL				As Float
	WSDATA F2_VALCOFI				As Float
	WSDATA F2_VALPIS				As Float
	WSDATA F2_TXMOEDA				As Float
	WSDATA F2_VALIRRF				As Float
	WSDATA F2_BASEINS				As Float
	WSDATA F2_DESCCAB				As Float
	WSDATA F2_ICMSDIF				As Float
	WSDATA F2_VALACRS				As Float
	WSDATA F2_BASEIRR				As Float
	WSDATA F2_BASPIS 				As Float
	WSDATA F2_BASCOFI				As Float
	WSDATA F2_BASCSLL				As Float
	WSDATA F2_DESCZFR				As Float
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetNotaFiscal
	WSDATA aNotaFiscal 			As Array of EstrutRetNotaFiscal Optional
ENDWSSTRUCT


WSMETHOD GetNotaFiscal WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetNotaFiscal WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cTipoNF	:= " 'N','D' "	// *** SOMENTE OS TIPOS DE NOTAS CONFIGURADOS PARA INTEGRACAO
Local cCpoExpo	:= ""
Local cCpoExpo2 := ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetNotaFiscal")
cFilDel		:= U_X011A01("FILDEL","SF2",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SF2",INOPCAO)
cCpoExpo2 	:= U_X011A01("CMPEXP","SD2",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetNotaFiscal "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SF2.R_E_C_N_O_, SF2.D_E_L_E_T_ DELET, A1_X_SIM3G "
cSql += "FROM "+ RetSqlName("SF2") + " SF2 "
cSql += "INNER JOIN "+ RetSqlName("SA1")+" SA1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
cSql += "WHERE SA1.D_E_L_E_T_ = ' ' "
If ! lFullDel
	cSql += " AND SA1.A1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
cSql += " AND  SF2.F2_TIPO IN ("+ cTipoNF +") "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !Empty(cCpoExpo2) .and. !lOpcFull	// Controle de registros Exportados (S/N) via TRIGGER
	//cSql += " AND "+ cCpoExpo +" <> 'S' "
	cSql += "  AND ( SF2."+ cCpoExpo +" <> 'S' "
	cSql += "    OR EXISTS ("
	cSql += "      SELECT D2_FILIAL, D2_DOC "
	cSql += "      FROM "+ RetSqlName("SD2") + " SD2 "
	cSql += "      WHERE SD2.D2_FILIAL  = SF2.F2_FILIAL "
	cSql += "        AND SD2.D2_DOC     = SF2.F2_DOC "
	cSql += "        AND SD2.D2_SERIE   = SF2.F2_SERIE "
	cSql += "        AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cSql += "        AND SD2.D2_LOJA    = SF2.F2_LOJA "
	cSql += "        AND SD2."+ cCpoExpo2 +" <> 'S' "
	cSql += "    )"
	cSql += "  )"
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SF2")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetNotaFiscal")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetNotaFiscal:aNotaFiscal,WSClassNew("EstrutRetNotaFiscal"))
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_FILIAL		:= F2_FILIAL
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_DOC   		:= F2_DOC
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_SERIE 		:= F2_SERIE
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_CLIENTE	:= F2_CLIENTE
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_LOJA   	:= F2_LOJA
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_TIPO		:= F2_TIPO
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_ESPECIE	:= Alltrim(F2_ESPECIE)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VEND1		:= Alltrim(F2_VEND1)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VEND2		:= Alltrim(F2_VEND2)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VEND3		:= Alltrim(F2_VEND3)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VEND4		:= Alltrim(F2_VEND4)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VEND5		:= Alltrim(F2_VEND5)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_COND		:= F2_COND
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_DUPL		:= Alltrim(F2_DUPL)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_EST		:= F2_EST
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_TIPOCLI	:= F2_TIPOCLI
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_NFORI		:= Alltrim(F2_NFORI)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_SERIORI	:= Alltrim(F2_SERIORI)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_TRANSP		:= Alltrim(F2_TRANSP)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_REDESP		:= Alltrim(F2_REDESP)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_TPFRETE	:= F2_TPFRETE
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_HORA		:= F2_HORA
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_MOEDA		:= F2_MOEDA
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_CHVNFE		:= Alltrim(F2_CHVNFE)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_HORNFE		:= Alltrim(F2_HORNFE)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_MENNOTA	:= U_X011A01("CP1252",F2_MENNOTA)
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_EMISSAO	:= F2_EMISSAO
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_FRETE		:= F2_FRETE
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_SEGURO		:= F2_SEGURO
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_ICMFRET	:= F2_ICMFRET
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALBRUT	:= F2_VALBRUT
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALICM		:= F2_VALICM
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BASEICM	:= F2_BASEICM
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALIPI		:= F2_VALIPI
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BASEIPI	:= F2_BASEIPI
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALMERC	:= F2_VALMERC
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_DESCONT	:= F2_DESCONT
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_ICMSRET	:= F2_ICMSRET
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_PLIQUI		:= F2_PLIQUI
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_PBRUTO		:= F2_PBRUTO
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALFAT		:= F2_VALFAT
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BASEISS	:= F2_BASEISS
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALISS		:= F2_VALISS
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALINSS	:= F2_VALINSS
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_CONTSOC	:= F2_CONTSOC
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BRICMS		:= F2_BRICMS
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_FRETAUT	:= F2_FRETAUT
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_DESPESA	:= F2_DESPESA
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALCSLL	:= F2_VALCSLL
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALCOFI	:= F2_VALCOFI
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALPIS		:= F2_VALPIS
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_TXMOEDA	:= F2_TXMOEDA
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALIRRF	:= F2_VALIRRF
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BASEINS	:= F2_BASEINS
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_DESCCAB	:= F2_DESCCAB
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_ICMSDIF	:= F2_ICMSDIF
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_VALACRS	:= F2_VALACRS
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BASEIRR	:= F2_BASEIRR
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BASPIS		:= F2_BASPIS
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BASCOFI	:= F2_BASCOFI
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_BASCSLL	:= F2_BASCSLL
	::RetNotaFiscal:aNotaFiscal[nIdx]:F2_DESCZFR	:= F2_DESCZFR
	::RetNotaFiscal:aNotaFiscal[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*' .or. (cAliasQry)->A1_X_SIM3G == "N","D","")
	::RetNotaFiscal:aNotaFiscal[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetNotaFiscal:aNotaFiscal[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetNotaFiscal:aNotaFiscal[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetNotaFiscal:aNotaFiscal[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetNotaFiscal", Self:RetNotaFiscal:aNotaFiscal[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SF2", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.





// NOTA FISCAL X PRODUTO
WSSTRUCT EstrutRetNotaFiscalProduto
	WSDATA D2_FILIAL    			As String
	WSDATA D2_DOC     				As String
	WSDATA D2_SERIE   				As String
	WSDATA D2_CLIENTE				As String
	WSDATA D2_LOJA  				As String
	WSDATA D2_ITEM  				As String
	WSDATA D2_COD    				As String
	WSDATA D2_UM    				As String
	WSDATA D2_SEGUM 				As String
	WSDATA D2_GRUPO    				As String
	WSDATA D2_TIPO  				As String
	WSDATA D2_EST   				As String
	WSDATA D2_CF    				As String
	WSDATA D2_TP    				As String
	WSDATA D2_NUMSEQ				As String
	WSDATA D2_NFORI  				As String
	WSDATA D2_SERIORI				As String
	WSDATA D2_CLASFIS				As String
	WSDATA D2_PEDIDO				As String
	WSDATA D2_EMISSAO				As Date
	WSDATA D2_QUANT 				As Float
	WSDATA D2_QTSEGUM				As Float
	WSDATA D2_PRCVEN				As Float
	WSDATA D2_TOTAL 				As Float
	WSDATA D2_VALIPI				As Float
	WSDATA D2_VALICM				As Float
	WSDATA D2_DESC  				As Float
	WSDATA D2_IPI   				As Float
	WSDATA D2_PCIM  				As Float
	WSDATA D2_VALCSL				As Float
	WSDATA D2_PESO  				As Float
	WSDATA D2_CUSTO1				As Float
	WSDATA D2_PRUNIT				As Float
	WSDATA D2_DESCON				As Float
	WSDATA D2_BRICMS				As Float
	WSDATA D2_BASEICM				As Float
	WSDATA D2_VALACRS				As Float
	WSDATA D2_ICMSRET				As Float
	WSDATA D2_DESCZFR				As Float
	WSDATA D2_ALIQINS				As Float
	WSDATA D2_ALIQISS				As Float
	WSDATA D2_BASEIPI				As Float
	WSDATA D2_BASEISS				As Float
	WSDATA D2_VALISS				As Float
	WSDATA D2_SEGURO				As Float
	WSDATA D2_VALFRE				As Float
	WSDATA D2_DESPESA				As Float
	WSDATA D2_BASEINS				As Float
	WSDATA D2_ICMFRET				As Float
	WSDATA D2_VALINS 				As Float
	WSDATA D2_VALBRUT				As Float
	WSDATA D2_BASEIRR				As Float
	WSDATA D2_ALQIRRF				As Float
	WSDATA D2_BASECOF				As Float
	WSDATA D2_BASECSL				As Float
	WSDATA D2_BASEPIS				As Float
	WSDATA D2_VALCOF				As Float
	WSDATA D2_VALIRRF				As Float
	WSDATA D2_ALIQSOL				As Float
	WSDATA D2_BASEFUN				As Float
	WSDATA D2_ALIQFUN				As Float
	WSDATA D2_VALFUN 				As Float
	WSDATA D2_VALPIS				As Float
	WSDATA D2_ALQCOF				As Float
	WSDATA D2_ALQCSL				As Float
	WSDATA D2_ALQPIS				As Float
	WSDATA D2_MARGEM				As Float
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetNotaFiscalProduto
	WSDATA aNotaFiscalProduto 		As Array of EstrutRetNotaFiscalProduto Optional
ENDWSSTRUCT


WSMETHOD GetNotaFiscalProduto WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetNotaFiscalProduto WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cTipoNF	:= " 'N','D' "	// *** SOMENTE OS TIPOS DE NOTAS CONFIGURADOS PARA INTEGRACAO
Local cCpoExpo	:= ""
Local cCpoExpo2 := ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetNotaFiscalProduto")
cFilDel		:= U_X011A01("FILDEL","SD2",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SD2",INOPCAO)
cCpoExpo2 	:= U_X011A01("CMPEXP","SF2",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetNotaFiscalProduto "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SD2.R_E_C_N_O_, SD2.D_E_L_E_T_ DELET, A1_X_SIM3G "
cSql += "FROM "+ RetSqlName("SD2") + " SD2 "
cSql += "INNER JOIN "+ RetSqlName("SA1")+" SA1 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA "
cSql += "WHERE SA1.D_E_L_E_T_ = ' ' "
If ! lFullDel
	cSql += " AND SA1.A1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
cSql += " AND  SD2.D2_TIPO IN ("+ cTipoNF +") "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !Empty(cCpoExpo2) .and. !lOpcFull	// Controle de registros Exportados (S/N) via TRIGGER
	//cSql += " AND "+ cCpoExpo +" <> 'S' "
	cSql += "  AND ("
	cSql += "    EXISTS ("
	cSql += "      SELECT D2_FILIAL, D2_DOC "
	cSql += "      FROM "+ RetSqlName("SD2") + " SD2X "
	cSql += "      WHERE SD2X.D2_FILIAL  = SD2.D2_FILIAL "
	cSql += "        AND SD2X.D2_DOC     = SD2.D2_DOC "
	cSql += "        AND SD2X.D2_SERIE   = SD2.D2_SERIE "
	cSql += "        AND SD2X.D2_CLIENTE = SD2.D2_CLIENTE "
	cSql += "        AND SD2X.D2_LOJA    = SD2.D2_LOJA "
	cSql += "        AND SD2X."+ cCpoExpo +" <> 'S' "
	cSql += "    )"
	cSql += "    OR EXISTS ("
	cSql += "      SELECT F2_FILIAL, F2_DOC "
	cSql += "      FROM "+ RetSqlName("SF2") + " SF2 "
	cSql += "      WHERE SF2.F2_FILIAL  = SD2.D2_FILIAL "
	cSql += "        AND SF2.F2_DOC     = SD2.D2_DOC "
	cSql += "        AND SF2.F2_SERIE   = SD2.D2_SERIE "
	cSql += "        AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
	cSql += "        AND SF2.F2_LOJA    = SD2.D2_LOJA "
	cSql += "        AND SF2."+ cCpoExpo2 +" <> 'S' "
	cSql += "    )"
	cSql += "  )"
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SD2")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetNotaFiscalProduto")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetNotaFiscalProduto:aNotaFiscalProduto,WSClassNew("EstrutRetNotaFiscalProduto"))
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_FILIAL	:= D2_FILIAL
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_DOC   	:= D2_DOC
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_SERIE 	:= D2_SERIE
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_CLIENTE	:= D2_CLIENTE
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_LOJA		:= D2_LOJA
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ITEM		:= D2_ITEM
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_COD		:= D2_COD
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_UM		:= Alltrim(D2_UM)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_SEGUM	:= Alltrim(D2_SEGUM)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_GRUPO	:= D2_GRUPO
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_TIPO		:= Alltrim(D2_TIPO)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_EST		:= Alltrim(D2_EST)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_CF		:= Alltrim(D2_CF)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_TP		:= Alltrim(D2_TP)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_NUMSEQ	:= Alltrim(D2_NUMSEQ)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_NFORI	:= Alltrim(D2_NFORI)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_SERIORI	:= Alltrim(D2_SERIORI)
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_CLASFIS	:= D2_CLASFIS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_EMISSAO	:= D2_EMISSAO // dDataBase
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_QUANT	:= D2_QUANT
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_QTSEGUM	:= D2_QTSEGUM
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_PRCVEN	:= D2_PRCVEN
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_TOTAL	:= D2_TOTAL
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALIPI	:= D2_VALIPI
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALICM	:= D2_VALICM
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_DESC		:= D2_DESC
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_IPI		:= D2_IPI
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_PCIM		:= IF( FieldPos("D2_PCIM") > 0, D2_PCIM, 0 )
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALCSL	:= D2_VALCSL
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_PESO		:= D2_PESO
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_CUSTO1	:= D2_CUSTO1
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_PRUNIT	:= D2_PRUNIT
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_DESCON	:= D2_DESCON
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BRICMS	:= D2_BRICMS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASEICM	:= D2_BASEICM
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALACRS	:= D2_VALACRS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ICMSRET	:= D2_ICMSRET
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_DESCZFR	:= D2_DESCZFR
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ALIQINS	:= D2_ALIQINS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ALIQISS	:= D2_ALIQISS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASEIPI	:= D2_BASEIPI
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASEISS	:= D2_BASEISS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALISS	:= D2_VALISS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_SEGURO	:= D2_SEGURO
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALFRE	:= D2_VALFRE
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_DESPESA	:= D2_DESPESA
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASEINS	:= D2_BASEINS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ICMFRET	:= D2_ICMFRET
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALINS	:= D2_VALINS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALBRUT	:= D2_VALBRUT
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASEIRR	:= D2_BASEIRR
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ALQIRRF	:= D2_ALQIRRF
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASECOF	:= D2_BASECOF
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASECSL	:= D2_BASECSL
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASEPIS	:= D2_BASEPIS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALCOF	:= D2_VALCOF
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALIRRF	:= D2_VALIRRF
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ALIQSOL	:= D2_ALIQSOL
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_BASEFUN	:= D2_BASEFUN
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ALIQFUN	:= D2_ALIQFUN
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALFUN	:= D2_VALFUN
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_VALPIS	:= D2_VALPIS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ALQCOF	:= D2_ALQCOF
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ALQCSL	:= D2_ALQCSL
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_ALQPIS	:= D2_ALQPIS
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_MARGEM	:= D2_MARGEM
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:D2_PEDIDO	:= D2_PEDIDO
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:OPERACAO	:= IF((cAliasQry)->DELET == '*' .or. (cAliasQry)->A1_X_SIM3G == "N","D","")
	::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetNotaFiscalProduto", Self:RetNotaFiscalProduto:aNotaFiscalProduto[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SD2", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.




// PAIS
WSSTRUCT EstrutRetPais
	WSDATA YA_FILIAL 				As String 
	WSDATA YA_CODGI  				As String 
	WSDATA YA_DESCR  				As String 
	WSDATA YA_SIGLA 				As String Optional
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetPais
	WSDATA aPais 					As Array of EstrutRetPais Optional
ENDWSSTRUCT

WSMETHOD GetPais WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetPais WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetPais")
cFilDel		:= U_X011A01("FILDEL","SYA",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SYA",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetPais "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SYA.*, SYA.D_E_L_E_T_ DELET, SYA.R_E_C_N_O_ "
cSql += "FROM "+ RetSqlName("SYA") + " SYA "
cSql += "WHERE SYA.YA_SIGLA  <> ' ' "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql += "ORDER BY YA_CODGI "
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SYA")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetPais")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetPais:aPais,WSClassNew("EstrutRetPais"))
	::RetPais:aPais[nIdx]:YA_FILIAL  		:= YA_FILIAL
	::RetPais:aPais[nIdx]:YA_CODGI  		:= YA_CODGI
	::RetPais:aPais[nIdx]:YA_DESCR  		:= YA_DESCR
	::RetPais:aPais[nIdx]:YA_SIGLA			:= YA_SIGLA
	::RetPais:aPais[nIdx]:OPERACAO			:= IF((cAliasQry)->DELET == '*',"D","")
	::RetPais:aPais[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetPais:aPais[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetPais:aPais[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetPais:aPais[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetPais", Self:RetPais:aPais[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SYA", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.





// CLIENTE
WSSTRUCT EstrutRetCliente
	WSDATA A1_FILIAL 					As String
	WSDATA A1_COD    					As String
	WSDATA A1_LOJA    					As String
	WSDATA A1_NOME    					As String
	WSDATA A1_NREDUZ 					As String
	WSDATA A1_PESSOA 					As String
	WSDATA A1_END    					As String	// ENDERECO
	WSDATA A1_ENDCOB   					As String	// ENDERECO DE COBRANCA
	WSDATA A1_ENDENT   					As String	// ENDERECO DE ENTREGA
	WSDATA A1_BAIRRO 					As String	// BAIRRO
	WSDATA A1_BAIRROC 					As String	// BAIRRO COBRANCA
	WSDATA A1_BAIRROE 					As String	// BAIRRO ENTREGA
	WSDATA A1_COMPLEM 					As String
	WSDATA A1_TIPO  					As String
	WSDATA A1_EST   					As String
	WSDATA A1_ESTC   					As String
	WSDATA A1_ESTE  					As String
	WSDATA A1_CEP   					As String
	WSDATA A1_CEPC   					As String
	WSDATA A1_CEPE   					As String
	WSDATA A1_COD_MUN  					As String
	WSDATA A1_CODMUNE  					As String
	WSDATA A1_MUN   					As String	// DESCRICAO DA CIDADE
	WSDATA A1_MUNC   					As String	// DESCRICAO DA CIDADE
	WSDATA A1_REGIAO 					As String
	WSDATA A1_DDD    					As String
	WSDATA A1_DDI   					As String
	WSDATA A1_TEL    					As String
	WSDATA A1_FAX   					As String
	WSDATA A1_TELEX   					As String
	WSDATA A1_CONTATO 					As String
	WSDATA A1_CGC   					As String
	WSDATA A1_RG     					As String
	WSDATA A1_PFISICA 					As String
	WSDATA A1_INSCR 					As String
	WSDATA A1_INSCRM 					As String
	WSDATA A1_INSCRUR 					As String
	WSDATA A1_PAIS  					As String
	WSDATA A1_DTNASC  					As Date
	WSDATA A1_EMAIL 					As String
	WSDATA A1_HPAGE 					As String
	WSDATA A1_CNAE   					As String
	WSDATA A1_MSBLQL 					As String
	WSDATA A1_VEND   					As String
	WSDATA A1_TPFRET   					As String
	WSDATA A1_TRANSP					As String
	WSDATA A1_COND   					As String
	WSDATA A1_RISCO 					As String
	WSDATA A1_LC       					As Float
	WSDATA A1_LCFIN    					As Float
	WSDATA A1_VENCLC   					As Date
	WSDATA A1_TABELA   					As String
	WSDATA A1_OBSERV   					As String
	WSDATA A1_GRPVEN   					As String
	WSDATA A1_DTCAD    					As Date
	WSDATA A1_HRCAD  					As String
	WSDATA A1_CALCSUF					As String
	WSDATA OPERACAO 					As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetCliente
	WSDATA aCliente 					As Array of EstrutRetCliente Optional
ENDWSSTRUCT

WSMETHOD GetCliente WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetCliente WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetCliente")
cFilDel		:= U_X011A01("FILDEL","SA1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SA1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetCliente "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SA1.R_E_C_N_O_, SA1.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SA1") +" SA1 "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND SA1.A1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql += "ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)

Begin Transaction

DbSelectArea(cAliasQry)
While ! (cAliasQry)->(Eof())
	dbSelectArea("SA1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetCliente")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetCliente:aCliente,WSClassNew("EstrutRetCliente"))
	::RetCliente:aCliente[nIdx]:A1_FILIAL  := A1_FILIAL
	::RetCliente:aCliente[nIdx]:A1_COD     := A1_COD
	::RetCliente:aCliente[nIdx]:A1_LOJA    := A1_LOJA
	::RetCliente:aCliente[nIdx]:A1_NOME    := U_X011A01("CP1252",A1_NOME)
	::RetCliente:aCliente[nIdx]:A1_NREDUZ  := U_X011A01("CP1252",A1_NREDUZ)
	::RetCliente:aCliente[nIdx]:A1_PESSOA  := U_X011A01("CP1252",A1_PESSOA)
	::RetCliente:aCliente[nIdx]:A1_END     := U_X011A01("CP1252",A1_END)
	::RetCliente:aCliente[nIdx]:A1_ENDCOB  := U_X011A01("CP1252",A1_ENDCOB)
	::RetCliente:aCliente[nIdx]:A1_ENDENT  := U_X011A01("CP1252",A1_ENDENT)
	::RetCliente:aCliente[nIdx]:A1_BAIRRO  := U_X011A01("CP1252",A1_BAIRRO)
	::RetCliente:aCliente[nIdx]:A1_BAIRROC := U_X011A01("CP1252",A1_BAIRROC)
	::RetCliente:aCliente[nIdx]:A1_BAIRROE := U_X011A01("CP1252",A1_BAIRROE)
	::RetCliente:aCliente[nIdx]:A1_COMPLEM := U_X011A01("CP1252",A1_COMPLEM)
	::RetCliente:aCliente[nIdx]:A1_TIPO    := U_X011A01("CP1252",A1_TIPO)
	::RetCliente:aCliente[nIdx]:A1_EST     := U_X011A01("CP1252",A1_EST)
	::RetCliente:aCliente[nIdx]:A1_ESTC    := U_X011A01("CP1252",A1_ESTC)
	::RetCliente:aCliente[nIdx]:A1_ESTE    := U_X011A01("CP1252",A1_ESTE)
	::RetCliente:aCliente[nIdx]:A1_CEP     := U_X011A01("CP1252",A1_CEP)
	::RetCliente:aCliente[nIdx]:A1_CEPC    := U_X011A01("CP1252",A1_CEPC)
	::RetCliente:aCliente[nIdx]:A1_CEPE    := U_X011A01("CP1252",A1_CEPE)
	::RetCliente:aCliente[nIdx]:A1_COD_MUN := A1_COD_MUN
	::RetCliente:aCliente[nIdx]:A1_CODMUNE := A1_CODMUNE
	::RetCliente:aCliente[nIdx]:A1_MUN     := U_X011A01("CP1252",A1_MUN)
	::RetCliente:aCliente[nIdx]:A1_MUNC    := U_X011A01("CP1252",A1_MUNC)
	::RetCliente:aCliente[nIdx]:A1_REGIAO  := U_X011A01("CP1252",A1_REGIAO)
	::RetCliente:aCliente[nIdx]:A1_DDD     := U_X011A01("CP1252",A1_DDD)
	::RetCliente:aCliente[nIdx]:A1_DDI     := U_X011A01("CP1252",A1_DDI)
	::RetCliente:aCliente[nIdx]:A1_TEL     := U_X011A01("CP1252",A1_TEL)
	::RetCliente:aCliente[nIdx]:A1_FAX     := U_X011A01("CP1252",A1_FAX)
	::RetCliente:aCliente[nIdx]:A1_TELEX   := U_X011A01("CP1252",A1_TELEX)
	::RetCliente:aCliente[nIdx]:A1_CONTATO := U_X011A01("CP1252",A1_CONTATO)
	::RetCliente:aCliente[nIdx]:A1_CGC     := U_X011A01("CP1252",A1_CGC)
	::RetCliente:aCliente[nIdx]:A1_RG      := U_X011A01("CP1252",A1_RG)
	::RetCliente:aCliente[nIdx]:A1_PFISICA := U_X011A01("CP1252",A1_PFISICA)
	::RetCliente:aCliente[nIdx]:A1_INSCR   := U_X011A01("CP1252",A1_INSCR)
	::RetCliente:aCliente[nIdx]:A1_INSCRM  := U_X011A01("CP1252",A1_INSCRM)
	::RetCliente:aCliente[nIdx]:A1_INSCRUR := U_X011A01("CP1252",A1_INSCRUR)
	::RetCliente:aCliente[nIdx]:A1_PAIS    := U_X011A01("CP1252",A1_PAIS)
	::RetCliente:aCliente[nIdx]:A1_DTNASC  := A1_DTNASC
	::RetCliente:aCliente[nIdx]:A1_EMAIL   := U_X011A01("CP1252",A1_EMAIL)
	::RetCliente:aCliente[nIdx]:A1_HPAGE   := U_X011A01("CP1252",A1_HPAGE)
	::RetCliente:aCliente[nIdx]:A1_CNAE    := U_X011A01("CP1252",A1_CNAE)
	::RetCliente:aCliente[nIdx]:A1_MSBLQL  := A1_MSBLQL
	::RetCliente:aCliente[nIdx]:A1_VEND    := A1_VEND
	::RetCliente:aCliente[nIdx]:A1_TPFRET  := U_X011A01("CP1252",A1_TPFRET)
	::RetCliente:aCliente[nIdx]:A1_TRANSP  := U_X011A01("CP1252",A1_TRANSP)
	::RetCliente:aCliente[nIdx]:A1_COND    := A1_COND
	::RetCliente:aCliente[nIdx]:A1_RISCO   := A1_RISCO
	::RetCliente:aCliente[nIdx]:A1_LC      := A1_LC
	::RetCliente:aCliente[nIdx]:A1_LCFIN   := A1_LCFIN
	::RetCliente:aCliente[nIdx]:A1_VENCLC  := A1_VENCLC
	::RetCliente:aCliente[nIdx]:A1_TABELA  := U_X011A01("CP1252",A1_TABELA)
	::RetCliente:aCliente[nIdx]:A1_OBSERV  := U_X011A01("CP1252",A1_OBSERV)
	::RetCliente:aCliente[nIdx]:A1_GRPVEN  := U_X011A01("CP1252",A1_GRPVEN)
	::RetCliente:aCliente[nIdx]:A1_DTCAD   := IF( FieldPos("A1_DTCAD") > 0, A1_DTCAD, STOD("") )
	::RetCliente:aCliente[nIdx]:A1_HRCAD   := IF( FieldPos("A1_HRCAD") > 0, Alltrim(A1_HRCAD), " " )
	::RetCliente:aCliente[nIdx]:A1_CALCSUF := A1_CALCSUF
	::RetCliente:aCliente[nIdx]:OPERACAO	:= IF((cAliasQry)->DELET == '*' .or. A1_X_SIM3G == "N","D","")
	::RetCliente:aCliente[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetCliente:aCliente[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetCliente:aCliente[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetCliente:aCliente[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetCliente", Self:RetCliente:aCliente[nIdx]);

	nIdx++
	
	U_X011A01("UPDEXP","SA1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction

(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.





// PRODUTO
WSSTRUCT EstrutRetProduto
	WSDATA B1_FILIAL   	 			 	As String
	WSDATA B1_COD      	 			 	As String
	WSDATA B1_DESC     	 			 	As String
	WSDATA B1_TIPO    	 			 	As String
	WSDATA B1_UM      	 			 	As String
	WSDATA B1_LOCPAD   	 			 	As String
	WSDATA B1_GRUPO    	 			 	As String
	WSDATA B1_SEGUM    	 			 	As String
	WSDATA B1_CONV     	 			 	As Float
	WSDATA B1_TIPCONV  	 			 	As String
	WSDATA B1_ALTER    	 			 	As String
	WSDATA B1_PRV1     	 			 	As Float
	WSDATA B1_PESO     	 			 	As Float
	WSDATA B1_PESBRU   	 			 	As Float
	WSDATA B1_QE     					As Float	// Quant. por embalagem
	WSDATA B1_CODBAR   	 			 	As String
	WSDATA B1_CNAE     	 			 	As String
	WSDATA B1_FABRIC   	 			 	As String
	WSDATA B1_MSBLQL   	 			 	As String
	WSDATA B1_LOTVEN   	 			 	As Float	// Quant. minima venda
	WSDATA B1_CUSTD   	 			 	As Float	// Custo Standard
	WSDATA B1_EMIN   					As Float	// Estoque minimo
	WSDATA B1_EMAX        				As Float	// Estoque maximo
	WSDATA B1_UPRC   					As Float	// Ultimo preco de compra
	WSDATA B1_ESTSEG 					As Float	// Estoque de seguranca
	WSDATA B1_LE     					As Float	// Lote Economico
	WSDATA B1_LM						As Float	// Lote Minimo
	WSDATA B1_OBS    					As String
	WSDATA B1_MODELO 					As String
	WSDATA B5_CEME   					As String	// Descricao cientifica estendida
	WSDATA B5_COMPR  					As Float	// Comprimento
	WSDATA B5_ESPESS  					As Float	// Espessura
	WSDATA B5_LARG  					As Float	// Largura
	WSDATA B5_ALTURA  					As Float	// Altura
	WSDATA B5_MARCA  					As String
	WSDATA OPERACAO 					As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetProduto
	WSDATA aProduto					As Array of EstrutRetProduto Optional
ENDWSSTRUCT

WSMETHOD GetProduto WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetProduto WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetProduto")
cFilDel		:= U_X011A01("FILDEL","SB1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SB1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetProduto "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SB1.R_E_C_N_O_, B5_CEME, B5_COMPR, B5_ESPESS, B5_LARG, B5_ALTURA, B5_MARCA, SB1.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SB1") +" SB1 "
cSql += "LEFT JOIN "+ RetSqlName("SB5") +" SB5 ON B5_COD = B1_COD AND B5_FILIAL = B1_FILIAL AND SB5.D_E_L_E_T_ = ' ' "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND SB1.B1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql += "ORDER BY B1_FILIAL, B1_COD "
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SB1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetProduto")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	//cObs := POSICIONE("SB1", 1, B1_FILIAL+B1_COD, "B1_CODOBS")
	cObs := MSMM(B1_CODOBS)
	
	AADD(::RetProduto:aProduto,WSClassNew("EstrutRetProduto"))
	::RetProduto:aProduto[nIdx]:B1_FILIAL   := B1_FILIAL
	::RetProduto:aProduto[nIdx]:B1_COD      := B1_COD
	::RetProduto:aProduto[nIdx]:B1_DESC     := U_X011A01("CP1252",B1_DESC)
	::RetProduto:aProduto[nIdx]:B1_TIPO     := Alltrim(B1_TIPO)
	::RetProduto:aProduto[nIdx]:B1_UM       := U_X011A01("CP1252",B1_UM)
	::RetProduto:aProduto[nIdx]:B1_LOCPAD   := Alltrim(B1_LOCPAD)
	::RetProduto:aProduto[nIdx]:B1_GRUPO    := Alltrim(B1_GRUPO)
	::RetProduto:aProduto[nIdx]:B1_SEGUM    := U_X011A01("CP1252",B1_SEGUM)
	::RetProduto:aProduto[nIdx]:B1_CONV     := B1_CONV
	::RetProduto:aProduto[nIdx]:B1_TIPCONV  := B1_TIPCONV
	::RetProduto:aProduto[nIdx]:B1_ALTER    := B1_ALTER
	::RetProduto:aProduto[nIdx]:B1_PRV1     := B1_PRV1
	::RetProduto:aProduto[nIdx]:B1_PESO     := B1_PESO
	::RetProduto:aProduto[nIdx]:B1_PESBRU   := B1_PESBRU
	::RetProduto:aProduto[nIdx]:B1_QE       := B1_QE
	::RetProduto:aProduto[nIdx]:B1_CODBAR   := U_X011A01("CP1252",B1_CODBAR)
	::RetProduto:aProduto[nIdx]:B1_CNAE     := U_X011A01("CP1252",B1_CNAE)
	::RetProduto:aProduto[nIdx]:B1_FABRIC   := U_X011A01("CP1252",B1_FABRIC)
	::RetProduto:aProduto[nIdx]:B1_MSBLQL   := B1_MSBLQL
	::RetProduto:aProduto[nIdx]:B1_LOTVEN   := B1_LOTVEN
	::RetProduto:aProduto[nIdx]:B1_CUSTD    := B1_CUSTD
	::RetProduto:aProduto[nIdx]:B1_EMIN     := B1_EMIN
	::RetProduto:aProduto[nIdx]:B1_EMAX     := B1_EMAX
	::RetProduto:aProduto[nIdx]:B1_UPRC     := B1_UPRC
	::RetProduto:aProduto[nIdx]:B1_ESTSEG   := B1_ESTSEG
	::RetProduto:aProduto[nIdx]:B1_LE       := B1_LE
	::RetProduto:aProduto[nIdx]:B1_LM	    := B1_LM
	::RetProduto:aProduto[nIdx]:B1_OBS      := U_X011A01("CP1252",cObs) //Alltrim(B1_OBS) MSMM(B1_OBS  )
	::RetProduto:aProduto[nIdx]:B1_MODELO   := U_X011A01("CP1252",B1_MODELO)
	::RetProduto:aProduto[nIdx]:B5_CEME     := U_X011A01("CP1252",(cAliasQry)->B5_CEME)
	::RetProduto:aProduto[nIdx]:B5_COMPR    := (cAliasQry)->B5_COMPR
	::RetProduto:aProduto[nIdx]:B5_ESPESS   := (cAliasQry)->B5_ESPESS
	::RetProduto:aProduto[nIdx]:B5_LARG     := (cAliasQry)->B5_LARG
	::RetProduto:aProduto[nIdx]:B5_ALTURA   := (cAliasQry)->B5_ALTURA
	::RetProduto:aProduto[nIdx]:B5_MARCA    := U_X011A01("CP1252",(cAliasQry)->B5_MARCA)
	::RetProduto:aProduto[nIdx]:OPERACAO	:= IF((cAliasQry)->DELET == '*' .or. B1_X_SIM3G == "N","D","")
	::RetProduto:aProduto[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetProduto:aProduto[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetProduto:aProduto[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetProduto:aProduto[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetProduto", Self:RetProduto:aProduto[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SB1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// TABELAPRECO
WSSTRUCT EstrutRetTabelaPreco
	WSDATA DA0_FILIAL 			 	As String	
	WSDATA DA0_CODTAB 			 	As String	// Codigo da tabela	
	WSDATA DA0_DESCRI 				As String	// Descricao
	WSDATA DA0_DATDE  			 	As Date	    // Data inicial
	WSDATA DA0_DATATE 		 		As Date		// Data final
	WSDATA DA0_HORADE 			 	As String	// Hora inicial
	WSDATA DA0_HORATE 			 	As String	// Hora final
	WSDATA DA0_CONDPG 	 			As String	// Codigo condicao pagamento
	WSDATA DA0_TPHORA 			 	As String	// Tipo horario: 1=Unico;2=Recorrente
	WSDATA DA0_ATIVO   			 	As String	// 1=Sim;2=Nao
	WSDATA OPERACAO 					As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetTabelaPreco
	WSDATA aTabelaPreco  			As Array of EstrutRetTabelaPreco Optional
ENDWSSTRUCT

WSMETHOD GetTabelaPreco WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTabelaPreco WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetTabelaPreco")
cFilDel		:= U_X011A01("FILDEL","DA0",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","DA0",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetTabelaPreco "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql += "SELECT DA0.R_E_C_N_O_, DA0.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("DA0") +" DA0 "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND DA0.DA0_X_SIM3 <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("DA0")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetTabelaPreco")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetTabelaPreco:aTabelaPreco,WSClassNew("EstrutRetTabelaPreco"))
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_FILIAL		:= DA0_FILIAL
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_CODTAB		:= DA0_CODTAB
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_DESCRI		:= U_X011A01("CP1252",DA0_DESCRI)
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_DATDE		:= DA0_DATDE
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_DATATE		:= DA0_DATATE
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_HORADE		:= DA0_HORADE
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_HORATE		:= DA0_HORATE
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_CONDPG		:= Alltrim(DA0_CONDPG)
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_TPHORA		:= DA0_TPHORA
	::RetTabelaPreco:aTabelaPreco[nIdx]:DA0_ATIVO		:= DA0_ATIVO
	::RetTabelaPreco:aTabelaPreco[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*' .or. DA0_X_SIM3 == "N","D","")
	::RetTabelaPreco:aTabelaPreco[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetTabelaPreco:aTabelaPreco[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetTabelaPreco:aTabelaPreco[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetTabelaPreco:aTabelaPreco[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetTabelaPreco", Self:RetTabelaPreco:aTabelaPreco[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","DA0", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.




// TABELAPRECOPRODUTO
WSSTRUCT EstrutRetTabelaPrecoProduto
	WSDATA DA1_FILIAL 					As String
	WSDATA DA1_ITEM    					As String	// ID do Item
	WSDATA DA1_CODPRO 					As String	// Codigo do produto
	WSDATA DA1_CODTAB 					As String	// Codigo da tabela
	WSDATA DA1_DESTAB 					As String	// Descricao da tabela
	WSDATA DA1_GRUPO  					As String	// Codigo do grupo do produto
	WSDATA DA1_DESCRI 					As String	// Descricao do produto
	WSDATA DA1_ATIVO  					As String	// 1=Sim;2=Nao
	WSDATA DA1_ESTADO 					As String	// Estado UF
	WSDATA DA1_PRCBAS 					As Float	// Preco base
	WSDATA DA1_PRCVEN 					As Float	// Preco de venda
	WSDATA DA1_VLRDES 					As Float	// Valor do desconto
	WSDATA DA1_PERDES 					As Float	// Percentual desconto
	WSDATA DA1_FRETE 					As Float	// Valor do frete
	WSDATA DA1_PRCMAX 					As Float	// Perço máximo
	WSDATA DA1_DATVIG 					As Date 	// Data vigência do Item
	WSDATA OPERACAO 					As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetTabelaPrecoProduto
	WSDATA aTabelaPrecoProduto     		As Array of EstrutRetTabelaPrecoProduto Optional
ENDWSSTRUCT

WSMETHOD GetTabelaPrecoProduto WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTabelaPrecoProduto WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

Public INCLUI := .F.

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetTabelaPrecoProduto")
cFilDel		:= U_X011A01("FILDEL","DA1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","DA1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetTabelaPrecoProduto "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT DA1.R_E_C_N_O_, DA1.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("DA1") +" DA1 "
cSql += "INNER JOIN "+ RetSqlName("DA0") +" DA0 ON DA0_CODTAB = DA1_CODTAB AND DA0_FILIAL = DA1_FILIAL AND DA0.D_E_L_E_T_ = '' "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND DA0.DA0_X_SIM3 <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
	cSql += " AND DA1.DA1_X_SIM3 <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("DA1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetTabelaPrecoProduto")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetTabelaPrecoProduto:aTabelaPrecoProduto,WSClassNew("EstrutRetTabelaPrecoProduto"))
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_FILIAL  	:= DA1_FILIAL
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_ITEM    	:= DA1_ITEM
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_CODPRO  	:= DA1_CODPRO
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_CODTAB  	:= DA1_CODTAB
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_DESTAB  	:= U_X011A01("CP1252",POSICIONE("DA0",1,XFILIAL("DA0")+DA1_CODTAB,"DA0_DESCRI"))
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_DESCRI  	:= OMS010DESC() // OMS010DESC() //Alltrim(DA1_DESCRI) //
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_GRUPO   	:= Alltrim(DA1_GRUPO)
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_ATIVO  	:= DA1_ATIVO
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_ESTADO  	:= Alltrim(DA1_ESTADO)
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_PRCBAS  	:= POSICIONE("SB1",1,XFILIAL("SB1")+DA1_CODPRO,"B1_PRV1") //DA1_PRCBAS
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_PRCVEN  	:= DA1_PRCVEN
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_VLRDES  	:= DA1_VLRDES
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_PERDES  	:= DA1_PERDES
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_FRETE  	:= DA1_FRETE
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_PRCMAX  	:= DA1_PRCMAX
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:DA1_DATVIG  	:= DA1_DATVIG
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*' .or. DA1_X_SIM3 == "N","D","")
	::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetTabelaPrecoProduto", Self:RetTabelaPrecoProduto:aTabelaPrecoProduto[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","DA1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.




// UNIDADEFEDERATIVA
WSSTRUCT EstrutRetUnidadeFederativa
	WSDATA X5_FILIAL					As String
	WSDATA X5_CHAVE 					As String
	WSDATA X5_DESCRI 					As String
	WSDATA OPERACAO 					As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetUnidadeFederativa
	WSDATA aUnidadeFederativa       As Array of EstrutRetUnidadeFederativa Optional
ENDWSSTRUCT

WSMETHOD GetUnidadeFederativa WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetUnidadeFederativa WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetUnidadeFederativa")
cFilDel		:= U_X011A01("FILDEL","SX5",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SX5",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetUnidadeFederativa "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT DISTINCT SX5.*, SX5.D_E_L_E_T_ DELET, SX5.R_E_C_N_O_ "
cSql += "FROM "+ RetSqlName("SX5") + " SX5 "
cSql += "WHERE SX5.X5_TABELA  = '12'  "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SX5")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetUnidadeFederativa")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetUnidadeFederativa:aUnidadeFederativa, WSClassNew("EstrutRetUnidadeFederativa"))
	::RetUnidadeFederativa:aUnidadeFederativa[nIdx]:X5_FILIAL		:= X5_FILIAL
	::RetUnidadeFederativa:aUnidadeFederativa[nIdx]:X5_CHAVE 		:= U_X011A01("CP1252",X5_CHAVE)
	::RetUnidadeFederativa:aUnidadeFederativa[nIdx]:X5_DESCRI		:= U_X011A01("CP1252",X5_DESCRI)
	::RetUnidadeFederativa:aUnidadeFederativa[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*',"D","")
	::RetUnidadeFederativa:aUnidadeFederativa[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetUnidadeFederativa:aUnidadeFederativa[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetUnidadeFederativa:aUnidadeFederativa[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetUnidadeFederativa:aUnidadeFederativa[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetUnidadeFederativa", Self:RetUnidadeFederativa:aUnidadeFederativa[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SX5", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction 
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.




// UNIDADEMEDIDA
WSSTRUCT EstrutRetUnidadeMedida
	WSDATA AH_FILIAL 			As String
	WSDATA AH_UNIMED 			As String
	WSDATA AH_UMRES  			As String
	WSDATA AH_DESCPO			As String
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetUnidadeMedida
	WSDATA aUnidadeMedida		As Array of EstrutRetUnidadeMedida Optional
ENDWSSTRUCT

WSMETHOD GetUnidadeMedida WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetUnidadeMedida WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetUnidadeMedida")
cFilDel		:= U_X011A01("FILDEL","SAH",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SAH",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetUnidadeMedida "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SAH.*, SAH.D_E_L_E_T_ DELET, SAH.R_E_C_N_O_ "
cSql += "FROM "+ RetSqlName("SAH") +" SAH "
cSql += "WHERE 1=1 "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SAH")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetUnidadeMedida")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetUnidadeMedida:aUnidadeMedida,WSClassNew("EstrutRetUnidadeMedida"))
	::RetUnidadeMedida:aUnidadeMedida[nIdx]:AH_FILIAL		:= AH_FILIAL
	::RetUnidadeMedida:aUnidadeMedida[nIdx]:AH_UNIMED		:= U_X011A01("CP1252",AH_UNIMED)
	::RetUnidadeMedida:aUnidadeMedida[nIdx]:AH_UMRES		:= U_X011A01("CP1252",AH_UMRES)
	::RetUnidadeMedida:aUnidadeMedida[nIdx]:AH_DESCPO		:= U_X011A01("CP1252",AH_DESCPO)
	::RetUnidadeMedida:aUnidadeMedida[nIdx]:OPERACAO			:= IF((cAliasQry)->DELET == '*',"D","")
	::RetUnidadeMedida:aUnidadeMedida[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetUnidadeMedida:aUnidadeMedida[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetUnidadeMedida:aUnidadeMedida[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetUnidadeMedida:aUnidadeMedida[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetUnidadeMedida", Self:RetUnidadeMedida:aUnidadeMedida[nIdx]);

	nIdx++
	
	U_X011A01("UPDEXP","SAH", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// VENDEDOR
WSSTRUCT EstrutRetVendedor
	
	WSDATA A3_FILIAL 					As String
	WSDATA A3_COD    					As String
	WSDATA A3_NOME    					As String
	WSDATA A3_NREDUZ 					As String
	WSDATA A3_END    					As String
	WSDATA A3_BAIRRO 					As String
	WSDATA A3_MUN   					As String	// DESCRICAO DA CIDADE
	WSDATA A3_EST   					As String
	WSDATA A3_CEP   					As String
	WSDATA A3_DDDTEL 					As String
	WSDATA A3_MSBLQL 					As String
	WSDATA A3_TEL    					As String
	WSDATA A3_FAX   					As String
	WSDATA A3_TELEX 					As String
	WSDATA A3_CEL   					As String
	WSDATA A3_PAIS  					As String
	WSDATA A3_DDI   					As String
	WSDATA A3_TIPO  					As String
	WSDATA A3_CGC   					As String
	WSDATA A3_INSCR 					As String
	WSDATA A3_INSCRM 					As String
	WSDATA A3_EMAIL 					As String
	WSDATA A3_HPAGE 					As String
	WSDATA A3_SUPER 					As String
	WSDATA A3_GEREN 					As String
	WSDATA A3_REGIAO 					As String
	WSDATA A3_SENHA 					As String
	WSDATA A3_CARGO 					As String
	WSDATA A3_EMACORP 					As String
	WSDATA A3_ADMISS  					As Date
	WSDATA OPERACAO 					As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetVendedor
	WSDATA aVendedor 					As Array of EstrutRetVendedor Optional
ENDWSSTRUCT

WSMETHOD GetVendedor WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetVendedor WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetVendedor")
cFilDel		:= U_X011A01("FILDEL","SA3",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SA3",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetVendedor "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SA3.R_E_C_N_O_, SA3.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SA3") +" SA3 "
cSql += "WHERE 1=1 "
If ! lFullDel
	cSql += " AND SA3.A3_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SA3")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetVendedor")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetVendedor:aVendedor,WSClassNew("EstrutRetVendedor"))
	::RetVendedor:aVendedor[nIdx]:A3_FILIAL  := A3_FILIAL
	::RetVendedor:aVendedor[nIdx]:A3_COD     := A3_COD
	::RetVendedor:aVendedor[nIdx]:A3_NOME    := U_X011A01("CP1252",A3_NOME)
	::RetVendedor:aVendedor[nIdx]:A3_NREDUZ  := U_X011A01("CP1252",A3_NREDUZ)
	::RetVendedor:aVendedor[nIdx]:A3_END     := U_X011A01("CP1252",A3_END)
	::RetVendedor:aVendedor[nIdx]:A3_BAIRRO  := U_X011A01("CP1252",A3_BAIRRO)
	::RetVendedor:aVendedor[nIdx]:A3_MUN     := U_X011A01("CP1252",A3_MUN)
	::RetVendedor:aVendedor[nIdx]:A3_EST     := U_X011A01("CP1252",A3_EST)
	::RetVendedor:aVendedor[nIdx]:A3_CEP     := U_X011A01("CP1252",A3_CEP)
	::RetVendedor:aVendedor[nIdx]:A3_DDDTEL  := U_X011A01("CP1252",A3_DDDTEL)
	::RetVendedor:aVendedor[nIdx]:A3_MSBLQL  := IF( FieldPos("A3_MSBLQL") > 0, A3_MSBLQL, "2" )
	::RetVendedor:aVendedor[nIdx]:A3_TEL     := U_X011A01("CP1252",A3_TEL)
	::RetVendedor:aVendedor[nIdx]:A3_FAX     := U_X011A01("CP1252",A3_FAX)
	::RetVendedor:aVendedor[nIdx]:A3_TELEX   := U_X011A01("CP1252",A3_TELEX)
	::RetVendedor:aVendedor[nIdx]:A3_CEL     := U_X011A01("CP1252",A3_CEL)
	::RetVendedor:aVendedor[nIdx]:A3_PAIS    := Alltrim(A3_PAIS)
	::RetVendedor:aVendedor[nIdx]:A3_DDI     := Alltrim(A3_DDI)
	::RetVendedor:aVendedor[nIdx]:A3_TIPO    := Alltrim(A3_TIPO)
	::RetVendedor:aVendedor[nIdx]:A3_CGC     := U_X011A01("CP1252",A3_CGC)
	::RetVendedor:aVendedor[nIdx]:A3_INSCR   := U_X011A01("CP1252",A3_INSCR)
	::RetVendedor:aVendedor[nIdx]:A3_INSCRM  := U_X011A01("CP1252",A3_INSCRM)
	::RetVendedor:aVendedor[nIdx]:A3_EMAIL   := U_X011A01("CP1252",A3_EMAIL)
	::RetVendedor:aVendedor[nIdx]:A3_HPAGE   := U_X011A01("CP1252",A3_HPAGE)
	::RetVendedor:aVendedor[nIdx]:A3_SUPER   := Alltrim(A3_SUPER)
	::RetVendedor:aVendedor[nIdx]:A3_GEREN   := Alltrim(A3_GEREN)
	::RetVendedor:aVendedor[nIdx]:A3_REGIAO  := Alltrim(A3_REGIAO)
	::RetVendedor:aVendedor[nIdx]:A3_SENHA   := U_X011A01("CP1252",A3_SENHA)
	::RetVendedor:aVendedor[nIdx]:A3_CARGO   := U_X011A01("CP1252",A3_CARGO)
	::RetVendedor:aVendedor[nIdx]:A3_EMACORP := IF( FieldPos("A3_EMACORP") > 0, U_X011A01("CP1252",A3_EMACORP), " " )
	::RetVendedor:aVendedor[nIdx]:A3_ADMISS  := A3_ADMISS
	::RetVendedor:aVendedor[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*' .or. A3_X_SIM3G == "N","D","")
	::RetVendedor:aVendedor[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetVendedor:aVendedor[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetVendedor:aVendedor[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetVendedor:aVendedor[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetVendedor", Self:RetVendedor:aVendedor[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SA3", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.




// VENDEDORCLIENTE
WSSTRUCT EstrutRetVendedorCliente
	WSDATA A1_FILIAL 		As String
	WSDATA A1_COD    		As String	// CODIGO DO CLIENTE
	WSDATA A1_LOJA   		As String
	WSDATA A3_FILIAL 		As String
	WSDATA A3_COD    		As String	// CODIGO DO VENDEDOR
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetVendedorCliente
	WSDATA aVendedorCliente 			As Array of EstrutRetVendedorCliente Optional
ENDWSSTRUCT

WSMETHOD GetVendedorCliente WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetVendedorCliente WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel1	:= ""
Local cFilDel2	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetVendedorCliente")
cFilDel1	:= U_X011A01("FILDEL","SA3",INOPCAO)
cFilDel2	:= U_X011A01("FILDEL","SA1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SA1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetVendedorCliente "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT DISTINCT A1_FILIAL, A1_COD, A1_LOJA, A3_FILIAL, A3_COD, "
cSql += "SA1.D_E_L_E_T_ A1DELET, SA3.D_E_L_E_T_ A3DELET, "
cSql += "SA1.R_E_C_N_O_ A1RECNO, SA3.R_E_C_N_O_ A3RECNO "
cSql += "FROM "+ RetSqlName("SA1") +" SA1 "
cSql += "INNER JOIN "+ RetSqlName("SA3") +" SA3 ON A3_COD = A1_VEND "
cSql += "WHERE SA1.A1_VEND <> ' ' "
If ! lFullDel
	cSql += " AND SA1.A1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
	cSql += " AND SA3.A3_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel1)
	cSql += " AND "+ cFilDel1 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFilDel2)
	cSql += " AND "+ cFilDel2 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	SA1->(dbGoTo( (cAliasQry)->A1RECNO ))
	SA3->(dbGoTo( (cAliasQry)->A3RECNO ))
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetVendedorCliente")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetVendedorCliente:aVendedorCliente,WSClassNew("EstrutRetVendedorCliente"))
	::RetVendedorCliente:aVendedorCliente[nIdx]:A1_FILIAL 	:= A1_FILIAL
	::RetVendedorCliente:aVendedorCliente[nIdx]:A1_COD    	:= A1_COD
	::RetVendedorCliente:aVendedorCliente[nIdx]:A1_LOJA  	:= A1_LOJA
	::RetVendedorCliente:aVendedorCliente[nIdx]:A3_FILIAL	:= A3_FILIAL
	::RetVendedorCliente:aVendedorCliente[nIdx]:A3_COD   	:= A3_COD
	::RetVendedorCliente:aVendedorCliente[nIdx]:OPERACAO	:= IF((cAliasQry)->A1DELET == '*' .or. (cAliasQry)->A3DELET == '*' .or. SA1->A1_X_SIM3G == "N" .or. SA3->A3_X_SIM3G == "N","D","")
	::RetVendedorCliente:aVendedorCliente[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetVendedorCliente:aVendedorCliente[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetVendedorCliente:aVendedorCliente[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetVendedorCliente:aVendedorCliente[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetVendedorCliente", Self:RetVendedorCliente:aVendedorCliente[nIdx]);
	
	nIdx++
	
	//U_X011A01("UPDEXP","SA1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ ) -->> NAO PODE ATUALIZAR SA1/SA3
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// TIPOCLIENTE
WSSTRUCT RetTipoCliente
	WSDATA aTipoCliente       	As Array of EstrutRetCodDescri Optional
ENDWSSTRUCT

WSMETHOD GetTipoCliente WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTipoCliente WSSERVICE WSSIM3G_CADASTROS
Local aCodigo	:= {"L", 			  "F", 				 "R", 		  "S", 							   "X"}
Local aDescri	:= {"Produtor Rural", "Consumidor Final","Revendedor","ICMS Solidario sem IPI na base","Exportacao"}
Local nIdx		:= 1

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

U_X011A01("CONSOLE","Exportacao SIM3G: GetTipoCliente "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

For nIdx := 1 to Len(aCodigo)
	AADD(::RetTipoCliente:aTipoCliente, WSClassNew("EstrutRetCodDescri"))
	::RetTipoCliente:aTipoCliente[nIdx]:CODIGO		:= aCodigo[nIdx]
	::RetTipoCliente:aTipoCliente[nIdx]:DESCRICAO	:= aDescri[nIdx]
Next

U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// GETTIPOFRETEPEDIDO
WSSTRUCT RetTipoFretePedido
	WSDATA aTipoFretePedido			As Array of EstrutRetCodDescri Optional
ENDWSSTRUCT

WSMETHOD GetTipoFretePedido WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTipoFretePedido WSSERVICE WSSIM3G_CADASTROS
Local aCodigo	:= {"C",   "F",	 "T", 		  		   "S"}
Local aDescri	:= {"CIF", "FOB","Por conta terceiros","Sem frete"}
Local nIdx		:= 1

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

U_X011A01("CONSOLE","Exportacao SIM3G: GetTipoFretePedido "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

For nIdx := 1 to Len(aCodigo)
	AADD(::RetTipoFretePedido:aTipoFretePedido, WSClassNew("EstrutRetCodDescri"))
	::RetTipoFretePedido:aTipoFretePedido[nIdx]:CODIGO		:= aCodigo[nIdx]
	::RetTipoFretePedido:aTipoFretePedido[nIdx]:DESCRICAO	:= aDescri[nIdx]
Next

U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.


/*
// GETTIPOPEDIDO
WSSTRUCT RetTipoPedido
	WSDATA aTipoPedido				As Array of EstrutRetCodDescri Optional
ENDWSSTRUCT

WSMETHOD GetTipoPedido WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTipoPedido WSSERVICE WSSIM3G_CADASTROS

Local aDados 	:= {}
Local aDadosPE 	:= {}
Local nIdx		:= 1

U_X011A01("CONSOLE","Exportacao SIM3G: GetTipoPedido "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

aAdd( aDados, {"N","Pedidos Normais"} )
aAdd( aDados, {"D","Devolucao de Compras"} )
aAdd( aDados, {"C","Compl. Precos"} )
aAdd( aDados, {"P","Compl. de IPI"} )
aAdd( aDados, {"I","Compl. de ICMS"} )
aAdd( aDados, {"B","Beneficiamento p/ Fornecedor"} )

If ExistBlock("PES011A4")
	aDadosPE := ExecBlock("PES011A4",.F.,.F., { "GetTipoPedido", @aDados })
	If Valtype(aDadosPE) == 'A'
		aDados := aClone(aDadosPE)
		aDadosPE := nil
	EndIf
Endif

For nIdx := 1 to Len(aDados)
	AADD(::RetTipoPedido:aTipoPedido, WSClassNew("EstrutRetCodDescri"))
	::RetTipoPedido:aTipoPedido[nIdx]:CODIGO		:= aDados[nIdx][1]
	::RetTipoPedido:aTipoPedido[nIdx]:DESCRICAO	:= aDados[nIdx][2]
Next

U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

RETURN .T.
*/


// GETTIPONOTAFISCAL
WSSTRUCT RetTipoNotaFiscal
	WSDATA aTipoNotaFiscal			As Array of EstrutRetCodDescri Optional
ENDWSSTRUCT

WSMETHOD GetTipoNotaFiscal WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTipoNotaFiscal WSSERVICE WSSIM3G_CADASTROS
Local aCodigo	:= {"N", "D", "C", "P", "I" }
Local aDescri	:= {"Nota Fiscal Normal",;
	                "Devolucao",;
	                "Nota Complementar ou Conhecimento Transporte",;
	                "Nota Complementar de IPI",;
	                "Nota Complementar de ICMS"}
Local nIdx		:= 1

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

U_X011A01("CONSOLE","Exportacao SIM3G: GetTipoNotaFiscal "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

For nIdx := 1 to Len(aCodigo)
	AADD(::RetTipoNotaFiscal:aTipoNotaFiscal, WSClassNew("EstrutRetCodDescri"))
	::RetTipoNotaFiscal:aTipoNotaFiscal[nIdx]:CODIGO	:= aCodigo[nIdx]
	::RetTipoNotaFiscal:aTipoNotaFiscal[nIdx]:DESCRICAO	:= aDescri[nIdx]
Next

U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// GETTIPOOPERACAOITEMPEDIDO
WSSTRUCT RetTipoOperacaoItemPedido
	WSDATA aTipoOperacaoItemPedido			As Array of  EstrutRetCodDescri Optional
ENDWSSTRUCT

WSMETHOD GetTipoOperacaoItemPedido WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTipoOperacaoItemPedido WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetTipoOperacaoItemPedido")
cCpoExpo	:= U_X011A01("CMPEXP","SX5",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetTipoOperacaoItemPedido "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT DISTINCT X5_CHAVE, X5_DESCRI, SX5.D_E_L_E_T_ DELET, SX5.R_E_C_N_O_ "
cSql += "FROM "+ RetSqlName("SFM") +" SFM "
cSql += "INNER JOIN "+ RetSqlName("SX5") +" SX5 ON X5_CHAVE = FM_TIPO "
cSql += "WHERE SX5.D_E_L_E_T_ = ' ' AND SFM.D_E_L_E_T_ = ' ' "
cSql += "  AND SX5.X5_TABELA  = 'DJ' "
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SX5")
	SX5->(dbGoTo( (cAliasQry)->R_E_C_N_O_ ))
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetTipoOperacaoItemPedido")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetTipoOperacaoItemPedido:aTipoOperacaoItemPedido,WSClassNew("EstrutRetCodDescri"))
	::RetTipoOperacaoItemPedido:aTipoOperacaoItemPedido[nIdx]:CODIGO    	:= X5_CHAVE
	::RetTipoOperacaoItemPedido:aTipoOperacaoItemPedido[nIdx]:DESCRICAO  	:= U_X011A01("CP1252",X5_DESCRI)
	::RetTipoOperacaoItemPedido:aTipoOperacaoItemPedido[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*',"D","")
	::RetTipoOperacaoItemPedido:aTipoOperacaoItemPedido[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetTipoOperacaoItemPedido:aTipoOperacaoItemPedido[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetTipoOperacaoItemPedido:aTipoOperacaoItemPedido[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetTipoOperacaoItemPedido:aTipoOperacaoItemPedido[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	nIdx++
	(cAliasQry)->(DbSkip())
EndDo

End Transaction
(cAliasQry)->(DbCloseArea())
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// GETTIPOTITULO
WSSTRUCT RetTipoTitulo
	WSDATA aTipoTitulo				As Array of EstrutRetCodDescri Optional
ENDWSSTRUCT

WSMETHOD GetTipoTitulo WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTipoTitulo WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro 	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro 	:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetTipoTitulo")
cFilDel		:= U_X011A01("FILDEL","SX5",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SX5",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetTipoTitulo "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT DISTINCT X5_CHAVE, X5_DESCRI, SX5.D_E_L_E_T_ DELET, SX5.R_E_C_N_O_ "
cSql += "FROM "+ RetSqlName("SX5") +" SX5 "
cSql += "WHERE SX5.D_E_L_E_T_ = ' ' "
cSql += "  AND SX5.X5_TABELA  = '05' "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SX5")
	SX5->(dbGoTo( (cAliasQry)->R_E_C_N_O_ ))
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetTipoTitulo")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetTipoTitulo:aTipoTitulo,WSClassNew("EstrutRetCodDescri"))
	::RetTipoTitulo:aTipoTitulo[nIdx]:CODIGO    	:= X5_CHAVE
	::RetTipoTitulo:aTipoTitulo[nIdx]:DESCRICAO  	:= U_X011A01("CP1252",X5_DESCRI)
	::RetTipoTitulo:aTipoTitulo[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetTipoTitulo:aTipoTitulo[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetTipoTitulo:aTipoTitulo[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetTipoTitulo:aTipoTitulo[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	nIdx++
	(cAliasQry)->(DbSkip())
EndDo

End Transaction
(cAliasQry)->(DbCloseArea())
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

U_X011A01("CONSOLE","Exportacao SIM3G: GetTipoTitulo "+ INOPCAO)

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.




// GETTES
WSSTRUCT EstrutRetTES
	WSDATA F4_CODIGO 		As String
	WSDATA F4_FINALID  		As String	
	WSDATA F4_TEXTO   		As String
	WSDATA OPERACAO 			As String Optional
	WSDATA CAMPOS_ESPEC		As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetTES
	WSDATA aTES				As Array of  EstrutRetTES Optional
ENDWSSTRUCT

WSMETHOD GetTES WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTES WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetTES")
cFilDel		:= U_X011A01("FILDEL","SF4",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SF4",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetTES "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SF4.R_E_C_N_O_, SF4.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SF4") +" SF4 "
cSql += "WHERE SF4.F4_CODIGO >= '500' "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SF4")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetTES")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetTES:aTES,WSClassNew("EstrutRetTES"))
	::RetTES:aTES[nIdx]:F4_CODIGO   := F4_CODIGO
	::RetTES:aTES[nIdx]:F4_FINALID 	:= U_X011A01("CP1252",F4_FINALID)
	::RetTES:aTES[nIdx]:F4_TEXTO 	:= U_X011A01("CP1252",F4_TEXTO)
	::RetTES:aTES[nIdx]:OPERACAO	:= IF((cAliasQry)->DELET == '*',"D","")
	::RetTES:aTES[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetTES:aTES[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetTES:aTES[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetTES:aTES[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetTES", Self:RetTES:aTES[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SF4", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

End Transaction
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.





// PEDIDO DE VENDA
WSSTRUCT EstrutRetPedido
	WSDATA C5_FILIAL 			As String
	WSDATA C5_NUM    			As String	// Nr. Pedido Protheus
	WSDATA C5_X_PVSIM 			As String	// Nr. Pedido SIM3G
	WSDATA C5_TIPO  			As String	// Tipos: N=Normal, D=Devolucao
	WSDATA C5_CLIENTE 			As String
	WSDATA C5_LOJACLI 			As String
	WSDATA C5_TRANSP  			As String
	WSDATA C5_REDESP  			As String
	WSDATA C5_TIPOCLI  			As String	// Tipos: ?????
	WSDATA C5_CONDPAG 	 		As String
	WSDATA C5_MSBLQL 	 		As String
	WSDATA C5_TABELA			As String
	WSDATA C5_VEND1 			As String
	WSDATA C5_COMIS1		 	As Float 
	WSDATA C5_VEND2 			As String
	WSDATA C5_COMIS2		 	As Float 
	WSDATA C5_VEND3 			As String
	WSDATA C5_COMIS3		 	As Float 
	WSDATA C5_VEND4 			As String
	WSDATA C5_COMIS4		 	As Float 
	WSDATA C5_VEND5 			As String
	WSDATA C5_COMIS5		 	As Float 
	WSDATA C5_DESC1  	 		As Float	// Perc. Desconto Pedido
	WSDATA C5_DESC2  	 		As Float	// Perc. Desconto Pedido
	WSDATA C5_DESC3  	 		As Float	// Perc. Desconto Pedido
	WSDATA C5_DESC4  	 		As Float	// Perc. Desconto Pedido
	WSDATA C5_DESCFI 	 		As Float	// Perc. Desconto Financeiro
	WSDATA C5_BANCO 			As String
	WSDATA C5_EMISSAO 			As Date 	// Data de Emissao
	WSDATA C5_TPFRETE			As String	// Tipo de Frete: C/F/???
	WSDATA C5_FRETE 		 	As Float 	// 
	WSDATA C5_SEGURO		 	As Float 
	WSDATA C5_DESPESA		 	As Float 
	WSDATA C5_FRETAUT 		 	As Float 
	WSDATA C5_MOEDA  			As Integer
	WSDATA C5_PESOL 		 	As Float 
	WSDATA C5_PBRUTO  		 	As Float 
	WSDATA C5_ACRSFIN		 	As Float
	WSDATA C5_MENNOTA 			As String
	WSDATA C5_LIBEROK 			As String
	WSDATA C5_DESCONT		 	As Float
	WSDATA C5_TXMOEDA		 	As Float
	WSDATA C5_FECENT 			As Date 	// Data de Entrega
	WSDATA OPERACAO 				As String Optional
	WSDATA SITUACAOPEDIDO		As String
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
	
ENDWSSTRUCT  
WSSTRUCT RetPedido
	WSDATA aPedido  				As Array of EstrutRetPedido Optional
ENDWSSTRUCT


WSMETHOD GetPedido WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetPedido WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local cCpoExpo2 := ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i
Local cSituacao	:= ""

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetPedido")
cFilDel		:= U_X011A01("FILDEL","SC5",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SC5",INOPCAO)
cCpoExpo2 	:= U_X011A01("CMPEXP","SC6",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetPedido "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SC5.R_E_C_N_O_, SC5.D_E_L_E_T_ DELET, A1_X_SIM3G "
cSql += "FROM "+ RetSqlName("SC5") + " SC5 "
cSql += "INNER JOIN "+ RetSqlName("SA1")+" SA1 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "
cSql += "WHERE SA1.D_E_L_E_T_ = ' ' "
If ! lFullDel
	cSql += " AND SA1.A1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !Empty(cCpoExpo2) .and. !lOpcFull	// Controle de registros Exportados (S/N) via TRIGGER
	//cSql += " AND "+ cCpoExpo +" <> 'S' "
	cSql += "  AND ("+ cCpoExpo +" <> 'S' "
	cSql += "    OR EXISTS ("
	cSql += "      SELECT C6_FILIAL, C6_NUM "
	cSql += "      FROM "+ RetSqlName("SC6") + " SC6 "
	cSql += "      WHERE SC6.C6_FILIAL = SC5.C5_FILIAL "
	cSql += "        AND SC6.C6_NUM    = SC5.C5_NUM "
	cSql += "        AND "+ cCpoExpo2 +" <> 'S' "
	cSql += "    )"
	cSql += "  )"
Endif
cSql += " ORDER BY C5_FILIAL, C5_NUM "
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SC5")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetPedido")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	// Valida a situação do pedido de venda
	cSituacao := ""
	Do Case
		Case Alltrim(SC5->C5_NOTA) <> "" .and. ! SC5->(Deleted())
			cSituacao := "PF"		// FATURADO
			
		Case SC5->(Deleted())
			cSituacao := "PC"		// CANCELADO
			
		Case Alltrim(SC5->C5_NOTA) == "" .and. ! SC5->(Deleted())
			cSituacao := "PA"		// ABERTO
	EndCase
	
	// Ponto de Entrada que permite alterar a situacao do Pedido
	//cSituacao := U_X011A01("CSITUA", "GetPedido", cSituacao)
	
	AADD(::RetPedido:aPedido,WSClassNew("EstrutRetPedido"))
	::RetPedido:aPedido[nIdx]:C5_FILIAL		:= Alltrim(C5_FILIAL)
	::RetPedido:aPedido[nIdx]:C5_NUM    	:= C5_NUM
	::RetPedido:aPedido[nIdx]:C5_X_PVSIM 	:= Alltrim(C5_X_PVSIM)
	::RetPedido:aPedido[nIdx]:C5_TIPO  		:= Alltrim(C5_TIPO)
	::RetPedido:aPedido[nIdx]:C5_CLIENTE 	:= Alltrim(C5_CLIENTE)
	::RetPedido:aPedido[nIdx]:C5_LOJACLI 	:= Alltrim(C5_LOJACLI)
	::RetPedido:aPedido[nIdx]:C5_TRANSP  	:= Alltrim(C5_TRANSP)
	::RetPedido:aPedido[nIdx]:C5_REDESP  	:= Alltrim(C5_REDESP)
	::RetPedido:aPedido[nIdx]:C5_TIPOCLI  	:= Alltrim(C5_TIPOCLI)
	::RetPedido:aPedido[nIdx]:C5_CONDPAG 	:= Alltrim(C5_CONDPAG)
	::RetPedido:aPedido[nIdx]:C5_MSBLQL 	:= IF(FieldPos("C5_MSBLQL")>0,C5_MSBLQL,"")
	::RetPedido:aPedido[nIdx]:C5_TABELA		:= Alltrim(C5_TABELA)
	::RetPedido:aPedido[nIdx]:C5_VEND1 		:= Alltrim(C5_VEND1)
	::RetPedido:aPedido[nIdx]:C5_COMIS1		:= C5_COMIS1
	::RetPedido:aPedido[nIdx]:C5_VEND2 		:= Alltrim(C5_VEND2)
	::RetPedido:aPedido[nIdx]:C5_COMIS2		:= C5_COMIS2
	::RetPedido:aPedido[nIdx]:C5_VEND3 		:= Alltrim(C5_VEND3)
	::RetPedido:aPedido[nIdx]:C5_COMIS3		:= C5_COMIS3
	::RetPedido:aPedido[nIdx]:C5_VEND4 		:= Alltrim(C5_VEND4)
	::RetPedido:aPedido[nIdx]:C5_COMIS4		:= C5_COMIS4
	::RetPedido:aPedido[nIdx]:C5_VEND5 		:= Alltrim(C5_VEND5)
	::RetPedido:aPedido[nIdx]:C5_COMIS5		:= C5_COMIS5
	::RetPedido:aPedido[nIdx]:C5_DESC1  	:= C5_DESC1
	::RetPedido:aPedido[nIdx]:C5_DESC2  	:= C5_DESC2
	::RetPedido:aPedido[nIdx]:C5_DESC3  	:= C5_DESC3
	::RetPedido:aPedido[nIdx]:C5_DESC4  	:= C5_DESC4
	::RetPedido:aPedido[nIdx]:C5_DESCFI 	:= C5_DESCFI
	::RetPedido:aPedido[nIdx]:C5_BANCO 		:= Alltrim(C5_BANCO)
	::RetPedido:aPedido[nIdx]:C5_EMISSAO 	:= C5_EMISSAO
	::RetPedido:aPedido[nIdx]:C5_TPFRETE	:= Alltrim(C5_TPFRETE)
	::RetPedido:aPedido[nIdx]:C5_FRETE 		:= C5_FRETE
	::RetPedido:aPedido[nIdx]:C5_SEGURO		:= C5_SEGURO
	::RetPedido:aPedido[nIdx]:C5_DESPESA	:= C5_DESPESA
	::RetPedido:aPedido[nIdx]:C5_FRETAUT 	:= C5_FRETAUT
	::RetPedido:aPedido[nIdx]:C5_MOEDA  	:= C5_MOEDA
	::RetPedido:aPedido[nIdx]:C5_PESOL 		:= C5_PESOL
	::RetPedido:aPedido[nIdx]:C5_PBRUTO  	:= C5_PBRUTO
	::RetPedido:aPedido[nIdx]:C5_ACRSFIN	:= C5_ACRSFIN
	::RetPedido:aPedido[nIdx]:C5_MENNOTA 	:= U_X011A01("CP1252",C5_MENNOTA)
	::RetPedido:aPedido[nIdx]:C5_LIBEROK 	:= Alltrim(C5_LIBEROK)
	::RetPedido:aPedido[nIdx]:C5_DESCONT	:= C5_DESCONT
	::RetPedido:aPedido[nIdx]:C5_TXMOEDA	:= C5_TXMOEDA
	::RetPedido:aPedido[nIdx]:C5_FECENT 	:= C5_FECENT
	::RetPedido:aPedido[nIdx]:SITUACAOPEDIDO:= cSituacao
	::RetPedido:aPedido[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*' .or. (cAliasQry)->A1_X_SIM3G == "N","D","")
	::RetPedido:aPedido[nIdx]:CAMPOS_ESPEC 	:= {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetPedido:aPedido[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetPedido:aPedido[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetPedido:aPedido[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetPedido", Self:RetPedido:aPedido[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SC5", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.




// ITENS DO PEDIDO DE VENDA
WSSTRUCT EstrutRetPedidoProduto
	WSDATA C6_FILIAL 			As String	// Código Filial
	WSDATA C6_NUM        		As String	// Nr. Pedido
	WSDATA C6_ITEM       	   	As String	// Numero do item
	WSDATA C6_PRODUTO    	   	As String	// Codigo Produto (SB1)
	WSDATA C6_UM        	   	As String	// Unidade Medida
	WSDATA C6_QTDVEN 	 		As Float	// Quant. Venda
	WSDATA C6_PRCVEN 			As Float	// Preco de Venda
	WSDATA C6_VALOR 			As Float	// Total do item
	WSDATA C6_QTDLIB 	 		As Float	// Quant. Liberada
	WSDATA C6_QTDLIB2 	 		As Float	// Quant. Liberda 2a UM
	WSDATA C6_SEGUM        	   	As String	// 2a Unidade Medida
	WSDATA C6_TES       		As String	// Codigo TES (opcional)
	WSDATA C6_UNSVEN 	 		As Float	// Quant. Venda 2a UM
	WSDATA C6_LOCAL     		As String	// Local, armazém
	WSDATA C6_CF         		As String	// Codigo Fiscal
	WSDATA C6_QTDENT 	 		As Float	// Quant. Entregue
	WSDATA C6_QTDENT2 	 		As Float	// Quant. Entregue 2a UM
	WSDATA C6_DESCONT 			As Float	// Perc. Desconto Item
	WSDATA C6_VALDESC 			As Float	// Valor Desconto Item
	WSDATA C6_ENTREG 			As Date 	// Data Entrega do Item
	WSDATA C6_NOTA        		As String	// Nr. Nota Fiscal fatura
	WSDATA C6_SERIE       		As String	// Séria da NF fatura
	WSDATA C6_DATFAT 			As Date 	// Data último Faturamento
	WSDATA C6_COMIS1 	 		As Float	// Percentual Comissao Vendedor 1
	WSDATA C6_COMIS2 	 		As Float	// Percentual Comissao Vendedor 2
	WSDATA C6_COMIS3 	 		As Float	// Percentual Comissao Vendedor 3
	WSDATA C6_COMIS4 	 		As Float	// Percentual Comissao Vendedor 4
	WSDATA C6_COMIS5 	 		As Float	// Percentual Comissao Vendedor 5
	WSDATA C6_PEDCLI       		As String	// Nr. Pedido do Cliente
	WSDATA C6_DESCRI       		As String	// Descricao auxiliar do produto
	WSDATA C6_PRUNIT 			As Float	// Preço unitário de Lista
	WSDATA C6_LOTECTL      		As String	// Nr. Lote
	WSDATA C6_NUMLOTE      		As String	// Nr. Sub Lote
	WSDATA C6_DTVALID 			As Date 	// Data Validade Lote
	WSDATA C6_QTDEMP 	 		As Float	// Quant. Empenhada
	WSDATA C6_QTDEMP2 	 		As Float	// Quant. Empenhada 2a UM
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
	WSDATA OPERACAO 				As String Optional
	
ENDWSSTRUCT  
WSSTRUCT RetPedidoProduto
	WSDATA aPedidoItem 			As Array of EstrutRetPedidoProduto Optional
ENDWSSTRUCT


WSMETHOD GetPedidoProduto WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetPedidoProduto WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cFilDel2	:= ""
Local cCpoExpo	:= ""
Local cCpoExpo2 := ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetPedidoProduto")
cFilDel		:= U_X011A01("FILDEL","SC6",INOPCAO)
cFilDel2	:= U_X011A01("FILDEL","SC5",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SC6",INOPCAO)
cCpoExpo2 	:= U_X011A01("CMPEXP","SC5",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetPedidoProduto "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SC6.R_E_C_N_O_, SC6.D_E_L_E_T_ DELET, A1_X_SIM3G "
cSql += "FROM "+ RetSqlName("SC6") + " SC6 "
cSql += "INNER JOIN "+ RetSqlName("SA1")+" SA1 ON A1_COD = C6_CLI AND A1_LOJA = C6_LOJA "
cSql += "INNER JOIN "+ RetSqlName("SC5")+" SC5 ON C5_NUM = C6_NUM AND C5_FILIAL = C6_FILIAL "
cSql += "WHERE SA1.D_E_L_E_T_ = ' ' "
If ! lFullDel
	cSql += " AND SA1.A1_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFilDel2)
	cSql += " AND "+ cFilDel2 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !Empty(cCpoExpo2) .and. !lOpcFull	// Controle de registros Exportados (S/N) via TRIGGER
	//cSql += " AND "+ cCpoExpo +" <> 'S' "
	cSql += "  AND ("
	cSql += "	EXISTS ("
	cSql += "      SELECT C6_FILIAL, C6_NUM "
	cSql += "      FROM "+ RetSqlName("SC6") + " SC6X "
	cSql += "      WHERE SC6X.C6_FILIAL = SC6.C6_FILIAL "
	cSql += "        AND SC6X.C6_NUM    = SC6.C6_NUM "
	cSql += "        AND "+ cCpoExpo +" <> 'S' "
	cSql += "    )"
	cSql += "    OR EXISTS ("
	cSql += "      SELECT C5_FILIAL, C5_NUM "
	cSql += "      FROM "+ RetSqlName("SC5") + " SC5 "
	cSql += "      WHERE SC5.C5_FILIAL = SC6.C6_FILIAL "
	cSql += "        AND SC5.C5_NUM    = SC6.C6_NUM "
	cSql += "        AND "+ cCpoExpo2 +" <> 'S' "
	cSql += "    )"
	cSql += "  )"
Endif
cSql += " ORDER BY C6_FILIAL, C6_NUM, C6_ITEM "
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SC6")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetPedidoProduto")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetPedidoProduto:aPedidoItem,WSClassNew("EstrutRetPedidoProduto"))
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_FILIAL    	:= Alltrim(C6_FILIAL)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_NUM        	:= Alltrim(C6_NUM)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_ITEM       	:= Alltrim(C6_ITEM)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_PRODUTO    	:= Alltrim(C6_PRODUTO)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_UM        	:= Alltrim(C6_UM)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_QTDVEN 	 	:= C6_QTDVEN 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_PRCVEN 		:= C6_PRCVEN 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_VALOR 		:= C6_VALOR 	
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_QTDLIB 	 	:= C6_QTDLIB 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_QTDLIB2 	:= C6_QTDLIB2
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_SEGUM       := Alltrim(C6_SEGUM)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_TES       	:= Alltrim(C6_TES)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_UNSVEN 	 	:= C6_UNSVEN 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_LOCAL     	:= Alltrim(C6_LOCAL)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_CF         	:= Alltrim(C6_CF)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_QTDENT 	 	:= C6_QTDENT 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_QTDENT2 	:= C6_QTDENT2
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_DESCONT 	:= C6_DESCONT
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_VALDESC 	:= C6_VALDESC
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_ENTREG 		:= C6_ENTREG 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_NOTA        := Alltrim(C6_NOTA)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_SERIE       := Alltrim(C6_SERIE)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_DATFAT 		:= C6_DATFAT 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_COMIS1 	 	:= C6_COMIS1 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_COMIS2 	 	:= C6_COMIS2 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_COMIS3 	 	:= C6_COMIS3 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_COMIS4 	 	:= C6_COMIS4 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_COMIS5 	 	:= C6_COMIS5 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_PEDCLI      := U_X011A01("CP1252",C6_PEDCLI)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_DESCRI      := U_X011A01("CP1252",C6_DESCRI)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_PRUNIT 		:= C6_PRUNIT 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_LOTECTL     := Alltrim(C6_LOTECTL)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_NUMLOTE     := Alltrim(C6_NUMLOTE)
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_DTVALID 	:= C6_DTVALID
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_QTDEMP 	 	:= C6_QTDEMP 
	::RetPedidoProduto:aPedidoItem[nIdx]:C6_QTDEMP2 	:= C6_QTDEMP2
	::RetPedidoProduto:aPedidoItem[nIdx]:OPERACAO		:= IF((cAliasQry)->DELET == '*' .or. (cAliasQry)->A1_X_SIM3G == "N","D","")
	::RetPedidoProduto:aPedidoItem[nIdx]:CAMPOS_ESPEC 	:= {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetPedidoProduto:aPedidoItem[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetPedidoProduto:aPedidoItem[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetPedidoProduto:aPedidoItem[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetPedidoProduto", Self:RetPedidoProduto:aPedidoItem[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SC6", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.


// GETMETASVENDAS
WSSTRUCT EstrutRetMETASVENDAS
	WSDATA CT_FILIAL 		As String
	WSDATA CT_DOC	 		As String
	WSDATA CT_SEQUEN   		As String	
	WSDATA CT_DESCRI   		As String
	WSDATA CT_DATA			As Date
	WSDATA CT_VEND     		As String
	WSDATA CT_REGIAO   		As String
	WSDATA CT_CATEGO   		As String
	WSDATA CT_TIPO     		As String
	WSDATA CT_GRUPO    		As String
	WSDATA CT_PRODUTO  		As String
	WSDATA CT_QUANT    		As Float
	WSDATA CT_VALOR    		As Float
	WSDATA CT_MOEDA    		As Integer
	WSDATA CT_CCUSTO   		As String
	WSDATA CT_ITEMCC   		As String
	WSDATA CT_CLVL     		As String
	WSDATA CT_MSBLQL   		As String

	WSDATA OPERACAO 			As String Optional
	WSDATA CAMPOS_ESPEC		As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetMETASVENDAS
	WSDATA aMETASVENDAS				As Array of  EstrutRetMETASVENDAS Optional
ENDWSSTRUCT

WSMETHOD GetMetasVendas WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetMETASVENDAS WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetMetasVendas")
cFilDel		:= U_X011A01("FILDEL","SCT",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SCT",INOPCAO)
aCpoEspec	:= {}
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetMetasVendas "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SCT.R_E_C_N_O_, SCT.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SCT") +" SCT "
cSql += "WHERE  1=1 "
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SCT")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetMetasVendas")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetMETASVENDAS:aMetasVendas,WSClassNew("EstrutRetMETASVENDAS"))
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_FILIAL	:= Alltrim(CT_FILIAL)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_DOC		:= Alltrim(CT_DOC)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_SEQUEN 	:= Alltrim(CT_SEQUEN)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_DESCRI 	:= U_X011A01("CP1252",CT_DESCRI)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_DATA	 	:= CT_DATA
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_VEND	 	:= Alltrim(CT_VEND)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_REGIAO 	:= Alltrim(CT_REGIAO)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_CATEGO 	:= Alltrim(CT_CATEGO)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_TIPO	 	:= Alltrim(CT_TIPO)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_GRUPO	:= Alltrim(CT_GRUPO)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_PRODUTO 	:= Alltrim(CT_PRODUTO)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_QUANT	:= CT_QUANT
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_VALOR	:= CT_VALOR
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_MOEDA	:= CT_MOEDA
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_CCUSTO	:= ALLTRIM(CT_CCUSTO)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_ITEMCC	:= ALLTRIM(CT_ITEMCC)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_CLVL	 	:= ALLTRIM(CT_CLVL)
	::RetMETASVENDAS:aMetasVendas[nIdx]:CT_MSBLQL	:= ALLTRIM(CT_MSBLQL)
	::RetMETASVENDAS:aMetasVendas[nIdx]:OPERACAO	:= IF((cAliasQry)->DELET == '*',"D","")
	::RetMETASVENDAS:aMetasVendas[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetMETASVENDAS:aMetasVendas[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetMETASVENDAS:aMetasVendas[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetMETASVENDAS:aMetasVendas[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetMetasVendas", Self:RetMETASVENDAS:aMetasVendas[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SCT", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

End Transaction
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.




// NOTA FISCAL DEVOLUCAO DE VENDA (ENTRADA)
WSSTRUCT EstrutRetNotaFiscalDev
	WSDATA F1_BASCOFI    			As Float
	WSDATA F1_BASCSLL    			As Float
	WSDATA F1_BASEICM  				As Float
	WSDATA F1_BASEINS 				As Float
	WSDATA F1_BASEIPI				As Float
	WSDATA F1_BASPIS    			As Float
	WSDATA F1_BRICMS 				As Float
	WSDATA F1_CHVNFE   				As String
	WSDATA F1_CODNFE 				As String
	WSDATA F1_COND    				As String
	WSDATA F1_CONTSOC				As Float
	WSDATA F1_DESCONT				As Float
	WSDATA F1_DESPESA  				As Float
	WSDATA F1_DOC     				As String
	WSDATA F1_DUPL					As String
	WSDATA F1_EMISSAO  				As Date
	WSDATA F1_ESPECIE  				As String
	WSDATA F1_EST	   				As String
	WSDATA F1_FILIAL    			As String
	WSDATA F1_FORNECE  				As String
	WSDATA F1_FRETE    				As Float
	WSDATA F1_HORA   				As String
	WSDATA F1_HORNFE 				As String
	WSDATA F1_ICMS   				As Float
	WSDATA F1_ICMSRET				As Float
	WSDATA F1_INSS   				As Float
	WSDATA F1_IPI    				As Float
	WSDATA F1_IRRF     				As Float
	WSDATA F1_ISS    				As Float
	WSDATA F1_LOJA    				As String
	WSDATA F1_MENNOTA				As String
	WSDATA F1_MOEDA  				As Float
	WSDATA F1_NFELETR				As String
	WSDATA F1_NFORIG   				As String
	WSDATA F1_ORIGEM 				As String
	WSDATA F1_PBRUTO 				As Float
	WSDATA F1_PLACA  				As String
	WSDATA F1_PLIQUI 				As Float
	WSDATA F1_SEGURO 				As Float
	WSDATA F1_SERIE   				As String
	WSDATA F1_SERORIG  				As String
	WSDATA F1_TIPO   				As String
	WSDATA F1_TIPODOC				As String
	WSDATA F1_TPFRETE 				As String
	WSDATA F1_TRANSP   				As String
	WSDATA F1_TXMOEDA				As Float
	WSDATA F1_VALBRUT  				As Float
	WSDATA F1_VALCOFI    			As Float
	WSDATA F1_VALCSLL    			As Float
	WSDATA F1_VALICM   				As Float
	WSDATA F1_VALIPI   				As Float
	WSDATA F1_VALIRF    			As Float
	WSDATA F1_VALMERC  				As Float
	WSDATA F1_VALPIS    			As Float
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetNotaFiscalDev
	WSDATA aNotaFiscalDev 			As Array of EstrutRetNotaFiscalDev Optional
ENDWSSTRUCT


WSMETHOD GetNotaFiscalDev WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetNotaFiscalDev WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local cCpoExpo2 := ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetNotaFiscalDev")
cFilDel		:= U_X011A01("FILDEL","SF1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SF1",INOPCAO)
cCpoExpo2 	:= U_X011A01("CMPEXP","SD1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetNotaFiscalDev "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SF1.R_E_C_N_O_, SF1.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SF1") + " SF1 "
cSql += "WHERE SF1.F1_TIPO = 'D' "
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cCpoExpo) .and. !Empty(cCpoExpo2) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	//cSql += " AND "+ cCpoExpo +" <> 'S' "
	cSql += "  AND ( SF1."+ cCpoExpo +" <> 'S' "
	cSql += "    OR EXISTS ("
	cSql += "      SELECT D1_FILIAL, D1_DOC "
	cSql += "      FROM "+ RetSqlName("SD1") + " SD1 "
	cSql += "      WHERE SD1.D1_FILIAL  = SF1.F1_FILIAL "
	cSql += "        AND SD1.D1_DOC     = SF1.F1_DOC "
	cSql += "        AND SD1.D1_SERIE   = SF1.F1_SERIE "
	cSql += "        AND SD1.D1_FORNECE = SF1.F1_FORNECE "
	cSql += "        AND SD1.D1_LOJA    = SF1.F1_LOJA "
	cSql += "        AND SD1."+ cCpoExpo2 +" <> 'S' "
	cSql += "    )"
	cSql += "  )"
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SF1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetNotaFiscalDev")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetNotaFiscalDev:aNotaFiscalDev,WSClassNew("EstrutRetNotaFiscalDev"))
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_BASCOFI	:= F1_BASCOFI
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_BASCSLL	:= F1_BASCSLL
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_BASEICM	:= F1_BASEICM
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_BASEINS	:= F1_BASEINS
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_BASEIPI	:= F1_BASEIPI
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_BASPIS	:= F1_BASPIS
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_BRICMS	:= F1_BRICMS
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_CHVNFE	:= Alltrim(F1_CHVNFE)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_CODNFE	:= Alltrim(F1_CODNFE)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_COND		:= F1_COND
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_CONTSOC	:= F1_CONTSOC
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_DESCONT	:= F1_DESCONT
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_DESPESA	:= F1_DESPESA
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_DOC   	:= F1_DOC
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_DUPL		:= Alltrim(F1_DUPL)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_EMISSAO	:= F1_EMISSAO
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_ESPECIE	:= Alltrim(F1_ESPECIE)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_EST		:= F1_EST
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_FILIAL	:= F1_FILIAL
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_FORNECE	:= F1_FORNECE
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_FRETE	:= F1_FRETE
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_HORA		:= F1_HORA
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_HORNFE	:= Alltrim(F1_HORNFE)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_ICMS  	:= F1_ICMS
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_ICMSRET	:= F1_ICMSRET
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_INSS  	:= F1_INSS
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_IPI  	:= F1_IPI
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_IRRF 	:= F1_IRRF
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_ISS  	:= F1_ISS
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_LOJA   	:= F1_LOJA
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_MENNOTA	:= U_X011A01("CP1252",F1_MENNOTA)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_MOEDA	:= F1_MOEDA
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_NFELETR	:= Alltrim(F1_NFELETR)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_NFORIG	:= Alltrim(F1_NFORIG)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_ORIGEM	:= Alltrim(F1_ORIGEM)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_PBRUTO	:= F1_PBRUTO
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_PLACA	:= Alltrim(F1_PLACA)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_PLIQUI	:= F1_PLIQUI
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_SEGURO	:= F1_SEGURO
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_SERIE 	:= F1_SERIE
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_SERORIG	:= Alltrim(F1_SERORIG)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_TIPO   	:= F1_TIPO
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_TIPODOC	:= Alltrim(F1_TIPODOC)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_TPFRETE	:= F1_TPFRETE
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_TRANSP	:= Alltrim(F1_TRANSP)
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_TXMOEDA	:= F1_TXMOEDA
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_VALBRUT	:= F1_VALBRUT
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_VALCOFI	:= F1_VALCOFI
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_VALCSLL	:= F1_VALCSLL
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_VALICM	:= F1_VALICM
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_VALIPI	:= F1_VALIPI
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_VALIRF	:= F1_VALIRF
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_VALMERC	:= F1_VALMERC
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:F1_VALPIS	:= F1_VALPIS
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:OPERACAO	:= IF((cAliasQry)->DELET == '*',"D","")
	::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetNotaFiscalDev:aNotaFiscalDev[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetNotaFiscalDev", Self:RetNotaFiscalDev:aNotaFiscalDev[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SF1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// PRODUTO X NOTA FISCAL DEVOLUCAO DE VENDA (ENTRADA)
WSSTRUCT EstrutRetNotaFiscalDevProduto
	WSDATA D1_ALIQFUN				As Float
	WSDATA D1_ALIQINS				As Float
	WSDATA D1_ALIQIRR				As Float
	WSDATA D1_ALIQISS				As Float
	WSDATA D1_ALIQSOL				As Float
	WSDATA D1_ALQCOF				As Float
	WSDATA D1_ALQCSL				As Float
	WSDATA D1_ALQPIS				As Float
	WSDATA D1_BASECOF				As Float
	WSDATA D1_BASECSL				As Float
	WSDATA D1_BASEFUN				As Float
	WSDATA D1_BASEICM				As Float
	WSDATA D1_BASEINS				As Float
	WSDATA D1_BASEIPI				As Float
	WSDATA D1_BASEIRR				As Float
	WSDATA D1_BASEISS				As Float
	WSDATA D1_BASEPIS				As Float
	WSDATA D1_BRICMS				As Float
	WSDATA D1_CF    				As String
	WSDATA D1_CLASFIS				As String
	WSDATA D1_COD    				As String
	WSDATA D1_CUSTO 				As Float
	WSDATA D1_DESC  				As Float
	WSDATA D1_DESCICM				As Float
	WSDATA D1_DESCZFR				As Float
	WSDATA D1_DESPESA				As Float
	WSDATA D1_DOC     				As String
	WSDATA D1_DTDIGIT				As Date
	WSDATA D1_EMISSAO				As Date
	WSDATA D1_FILIAL    			As String
	WSDATA D1_FORNECE				As String
	WSDATA D1_GRUPO    				As String
	WSDATA D1_ICMSCOM				As Float
	WSDATA D1_ICMSDIF				As Float
	WSDATA D1_ICMSRET				As Float
	WSDATA D1_II    				As Float
	WSDATA D1_IPI   				As Float
	WSDATA D1_ITEM  				As String
	WSDATA D1_ITEMORI   			As String
	WSDATA D1_ITEMPC    			As String
	WSDATA D1_LOCAL  				As String
	WSDATA D1_LOJA  				As String
	WSDATA D1_LOTECTL 				As String
	WSDATA D1_MARGEM				As Float
	WSDATA D1_NFORI  				As String
	WSDATA D1_NUMLOTE				As String
	WSDATA D1_PEDIDO 				As String
	WSDATA D1_PESO  				As Float
	WSDATA D1_PICM 	  				As Float
	WSDATA D1_QTSEGUM				As Float
	WSDATA D1_QUANT 				As Float
	WSDATA D1_SEGUM 				As String
	WSDATA D1_SEGURO				As Float
	WSDATA D1_SERIE   				As String
	WSDATA D1_SERIORI				As String
	WSDATA D1_TES  					As String
	WSDATA D1_TIPO  				As String
	WSDATA D1_TOTAL 				As Float
	WSDATA D1_UM    				As String
	WSDATA D1_VALACRS				As Float
	WSDATA D1_VALCOF				As Float
	WSDATA D1_VALCSL				As Float
	WSDATA D1_VALDESC				As Float
	WSDATA D1_VALFRE				As Float
	WSDATA D1_VALFUN 				As Float
	WSDATA D1_VALICM				As Float
	WSDATA D1_VALINS 				As Float
	WSDATA D1_VALIPI				As Float
	WSDATA D1_VALIRR				As Float
	WSDATA D1_VALISS				As Float
	WSDATA D1_VALPIS				As Float
	WSDATA D1_VUNIT 				As Float
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT  
WSSTRUCT RetNotaFiscalDevProduto
	WSDATA aNotaFiscalDevProduto 	As Array of EstrutRetNotaFiscalDevProduto Optional
ENDWSSTRUCT


WSMETHOD GetNotaFiscalDevProduto WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetNotaFiscalDevProduto WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local cCpoExpo2	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetNotaFiscalDevProduto")
cFilDel		:= U_X011A01("FILDEL","SD1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SD1",INOPCAO)
cCpoExpo2	:= U_X011A01("CMPEXP","SF1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetNotaFiscalDevProduto "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SD1.R_E_C_N_O_, SD1.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SD1") + " SD1 "
cSql += "WHERE SD1.D1_TIPO = 'D' "
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cCpoExpo) .and. !Empty(cCpoExpo2) .and. !lOpcFull	// Controle de registros Exportados (S/N) via TRIGGER
	//cSql += " AND "+ cCpoExpo +" <> 'S' "
	cSql += "  AND ("
	cSql += "    EXISTS ("
	cSql += "      SELECT D1_FILIAL, D1_DOC "
	cSql += "      FROM "+ RetSqlName("SD1") + " SD1X "
	cSql += "      WHERE SD1X.D1_FILIAL  = SD1.D1_FILIAL "
	cSql += "        AND SD1X.D1_DOC     = SD1.D1_DOC "
	cSql += "        AND SD1X.D1_SERIE   = SD1.D1_SERIE "
	cSql += "        AND SD1X.D1_FORNECE = SD1.D1_FORNECE "
	cSql += "        AND SD1X.D1_LOJA    = SD1.D1_LOJA "
	cSql += "        AND SD1X."+ cCpoExpo +" <> 'S' "
	cSql += "    )"
	cSql += "    OR EXISTS ("
	cSql += "      SELECT F1_FILIAL, F1_DOC "
	cSql += "      FROM "+ RetSqlName("SF1") + " SF1 "
	cSql += "      WHERE SF1.F1_FILIAL  = SD1.D1_FILIAL "
	cSql += "        AND SF1.F1_DOC     = SD1.D1_DOC "
	cSql += "        AND SF1.F1_SERIE   = SD1.D1_SERIE "
	cSql += "        AND SF1.F1_FORNECE = SD1.D1_FORNECE "
	cSql += "        AND SF1.F1_LOJA    = SD1.D1_LOJA "
	cSql += "        AND SF1."+ cCpoExpo2 +" <> 'S' "
	cSql += "    )"
	cSql += "  )"
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("SD1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetNotaFiscalDevProduto")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetNotaFiscalDevProduto:aNotaFiscalDevProduto,WSClassNew("EstrutRetNotaFiscalDevProduto"))
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ALIQFUN	:= D1_ALIQFUN
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ALIQINS	:= D1_ALIQINS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ALIQIRR	:= D1_ALIQIRR
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ALIQISS	:= D1_ALIQISS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ALIQSOL	:= D1_ALIQSOL
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ALQCOF 	:= D1_ALQCOF
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ALQCSL 	:= D1_ALQCSL
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ALQPIS 	:= D1_ALQPIS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASECOF	:= D1_BASECOF
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASECSL	:= D1_BASECSL
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASEFUN	:= D1_BASEFUN
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASEICM	:= D1_BASEICM
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASEINS	:= D1_BASEINS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASEIPI	:= D1_BASEIPI
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASEIRR	:= D1_BASEIRR
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASEISS	:= D1_BASEISS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BASEPIS	:= D1_BASEPIS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_BRICMS 	:= D1_BRICMS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_CF	    	:= Alltrim(D1_CF)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_CLASFIS	:= D1_CLASFIS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_COD    	:= D1_COD
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_CUSTO  	:= D1_CUSTO
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_DESC		:= D1_DESC
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_DESCICM	:= D1_DESCICM
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_DESCZFR	:= D1_DESCZFR
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_DESPESA	:= D1_DESPESA
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_DOC    	:= D1_DOC
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_DTDIGIT	:= D1_DTDIGIT
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_EMISSAO	:= D1_EMISSAO
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_FILIAL  	:= D1_FILIAL
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_FORNECE 	:= D1_FORNECE
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_GRUPO		:= D1_GRUPO
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ICMSCOM	:= D1_ICMSCOM
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ICMSDIF	:= D1_ICMSDIF
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ICMSRET	:= D1_ICMSRET
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_II     	:= D1_II
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_IPI		:= D1_IPI
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ITEM    	:= D1_ITEM
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ITEMORI 	:= D1_ITEMORI
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_ITEMPC  	:= D1_ITEMPC
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_LOCAL   	:= D1_LOCAL
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_LOJA    	:= D1_LOJA
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_LOTECTL    := D1_LOTECTL
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_MARGEM		:= D1_MARGEM
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_NFORI		:= Alltrim(D1_NFORI)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_NUMLOTE	:= Alltrim(D1_NUMLOTE)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_PEDIDO		:= Alltrim(D1_PEDIDO)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_PESO		:= D1_PESO
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_PICM		:= D1_PICM
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_QTSEGUM	:= D1_QTSEGUM
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_QUANT		:= D1_QUANT
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_SEGUM		:= Alltrim(D1_SEGUM)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_SEGURO		:= D1_SEGURO
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_SERIE   	:= D1_SERIE
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_SERIORI	:= Alltrim(D1_SERIORI)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_TES		:= Alltrim(D1_TES)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_TIPO		:= Alltrim(D1_TIPO)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_TOTAL  	:= D1_TOTAL
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_UM	    	:= Alltrim(D1_UM)
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALACRS	:= D1_VALACRS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALCOF 	:= D1_VALCOF
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALCSL 	:= D1_VALCSL
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALDESC	:= D1_VALDESC
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALFRE 	:= D1_VALFRE
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALFUN 	:= D1_VALFUN
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALICM 	:= D1_VALICM
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALINS 	:= D1_VALINS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALIPI 	:= D1_VALIPI
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALIRR 	:= D1_VALIRR
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALISS 	:= D1_VALISS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VALPIS 	:= D1_VALPIS
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:D1_VUNIT  	:= D1_VUNIT
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:OPERACAO  	:= IF((cAliasQry)->DELET == '*',"D","")
	::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:CAMPOS_ESPEC	:= {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetNotaFiscalDevProduto", Self:RetNotaFiscalDevProduto:aNotaFiscalDevProduto[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","SD1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// CADASTRO DE CATEGORIAS DE PRODUTOS
WSSTRUCT EstrutRetCatProd
	WSDATA ACU_FILIAL 				As String
	WSDATA ACU_COD    				As String
	WSDATA ACU_DESC    				As String
	WSDATA ACU_CODPAI 				As String
	WSDATA OPERACAO    				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT
WSSTRUCT RetCatProd
	WSDATA aCatProd 				As Array of EstrutRetCatProd Optional
ENDWSSTRUCT


WSMETHOD GetCatProd WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetCatProd WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetCatProd")
cFilDel		:= U_X011A01("FILDEL","ACU",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","ACU",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetCatProd "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT ACU.R_E_C_N_O_, ACU.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("ACU") + " ACU "
cSql += "WHERE ACU.ACU_COD <> ' ' "
If !Empty(cFiltro)
	cSql += "  AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += "  AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += "  AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("ACU")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetCatProd")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetCatProd:aCatProd,WSClassNew("EstrutRetCatProd"))
	::RetCatProd:aCatProd[nIdx]:ACU_FILIAL	:= ACU_FILIAL
	::RetCatProd:aCatProd[nIdx]:ACU_COD   	:= ACU_COD
	::RetCatProd:aCatProd[nIdx]:ACU_DESC  	:= ACU_DESC
	::RetCatProd:aCatProd[nIdx]:ACU_CODPAI	:= ACU_CODPAI
	::RetCatProd:aCatProd[nIdx]:OPERACAO	:= IF((cAliasQry)->DELET == '*',"D","")
	::RetCatProd:aCatProd[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetCatProd:aCatProd[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetCatProd:aCatProd[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetCatProd:aCatProd[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetCatProd", Self:RetCatProd:aCatProd[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","ACU", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// CADASTRO AMARRAÇÃO DE CATEGORIAS X PRODUTO/GRUPO
WSSTRUCT EstrutRetCatProdRelac
	WSDATA ACV_FILIAL 				As String
	WSDATA ACV_CATEGO 				As String
	WSDATA ACV_CODPRO 				As String
	WSDATA ACV_GRUPO   				As String
	WSDATA ACV_REFGRD 				As String
	WSDATA ACV_SUVEND 				As String
	WSDATA ACV_SEQPRD  				As String
	WSDATA OPERACAO    				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT
WSSTRUCT RetCatProdRelac
	WSDATA aCatProdRelac		As Array of EstrutRetCatProdRelac Optional
ENDWSSTRUCT


WSMETHOD GetCatProdRelac WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetCatProdRelac WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

U_X011A01("CONSOLE","Exportacao SIM3G: GetCatProdRelac "+ INOPCAO)

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetCatProdRelac")
cFilDel		:= U_X011A01("FILDEL","ACV",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","ACV",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT ACV.R_E_C_N_O_, ACV.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("ACV") + " ACV "
cSql += "WHERE ACV.ACV_CATEGO <> ' ' "
If !Empty(cFiltro)
	cSql += "  AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += "  AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += "  AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("ACV")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetCatProdRelac")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetCatProdRelac:aCatProdRelac,WSClassNew("EstrutRetCatProdRelac"))
	::RetCatProdRelac:aCatProdRelac[nIdx]:ACV_FILIAL	:= ACV_FILIAL
	::RetCatProdRelac:aCatProdRelac[nIdx]:ACV_CATEGO	:= ACV_CATEGO
	::RetCatProdRelac:aCatProdRelac[nIdx]:ACV_CODPRO	:= ACV_CODPRO
	::RetCatProdRelac:aCatProdRelac[nIdx]:ACV_GRUPO 	:= ACV_GRUPO
	::RetCatProdRelac:aCatProdRelac[nIdx]:ACV_REFGRD	:= ACV_REFGRD
	::RetCatProdRelac:aCatProdRelac[nIdx]:ACV_SUVEND	:= ACV_SUVEND
	::RetCatProdRelac:aCatProdRelac[nIdx]:ACV_SEQPRD	:= ACV_SEQPRD
	::RetCatProdRelac:aCatProdRelac[nIdx]:OPERACAO  	:= IF((cAliasQry)->DELET == '*',"D","")
	::RetCatProdRelac:aCatProdRelac[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetCatProdRelac:aCatProdRelac[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetCatProdRelac:aCatProdRelac[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetCatProdRelac:aCatProdRelac[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetCatProdRelac", Self:RetCatProdRelac:aCatProdRelac[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","ACV", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// CADASTRO DE VEÍCULOS (MÓDULO DE OFICINAS)
WSSTRUCT EstrutRetVeiculoOficina
	WSDATA VV1_FILIAL				As String
	WSDATA VV1_CHAINT				As String
	WSDATA VV1_CHASSI	 			As String
	WSDATA VV1_CODMAR	 			As String
	WSDATA VV1_DESMAR	 			As String
	WSDATA VV1_MODVEI	 			As String
	WSDATA VV1_DESMOD	 			As String
	WSDATA VV1_FABMOD	 			As String
	WSDATA VV1_PLAVEI	 			As String
	WSDATA VV1_CORVEI	 			As String
	WSDATA VV1_DESCOR	 			As String
	WSDATA VV1_COMVEI	 			As String
	WSDATA VV1_ESTVEI	 			As String
	WSDATA VV1_KILVEI	 			As Integer
	WSDATA OPERACAO    				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT
WSSTRUCT RetVeiculoOficina
	WSDATA aVeiculoOficina			As Array of EstrutRetVeiculoOficina Optional
ENDWSSTRUCT

WSMETHOD GetVeiculoOficina WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetVeiculoOficina WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetVeiculoOficina")
cFilDel		:= U_X011A01("FILDEL","VV1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","VV1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetVeiculoOficina "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT VV1.R_E_C_N_O_, VV1.D_E_L_E_T_ DELET, VE1_DESMAR, VV2_DESMOD, VVC_DESCRI "
cSql += "FROM "+ RetSqlName("VV1") + " VV1 "
cSql += "LEFT JOIN "+ RetSqlName("VE1") + " VE1 "
cSql += " ON  VE1.D_E_L_E_T_ = ' ' "
cSql += " AND VE1_FILIAL = '"+ xFilial("VE1") +"' "
cSql += " AND VE1_CODMAR = VV1_CODMAR "
cSql += "LEFT JOIN "+ RetSqlName("VV2") + " VV2 "
cSql += " ON  VV2.D_E_L_E_T_ = ' ' "
cSql += " AND VV2_FILIAL = '"+ xFilial("VV2") +"' "
cSql += " AND VV2_CODMAR = VV1_CODMAR "
cSql += " AND VV2_MODVEI = VV1_MODVEI "
cSql += "LEFT JOIN "+ RetSqlName("VVC") + " VVC "
cSql += " ON  VVC.D_E_L_E_T_ = ' ' "
cSql += " AND VVC_FILIAL = '"+ xFilial("VVC") +"' "
cSql += " AND VV1_CODMAR = VVC_CODMAR "
cSql += " AND VV1_CORVEI = VVC_CORVEI "
cSql += "WHERE 1=1 "
If !Empty(cFiltro)
	cSql += "  AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += "  AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += "  AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("VV1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetVeiculoOficina")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetVeiculoOficina:aVeiculoOficina,WSClassNew("EstrutRetVeiculoOficina"))
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_FILIAL	:= VV1_FILIAL
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_CHAINT	:= VV1_CHAINT
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_CHASSI	:= VV1_CHASSI
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_CODMAR 	:= VV1_CODMAR
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_DESMAR	:= U_X011A01("CP1252", alltrim((cAliasQry)->VE1_DESMAR))
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_MODVEI	:= VV1_MODVEI
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_DESMOD	:= U_X011A01("CP1252", alltrim((cAliasQry)->VV2_DESMOD))
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_FABMOD	:= VV1_FABMOD
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_PLAVEI	:= VV1_PLAVEI
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_CORVEI	:= VV1_CORVEI
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_DESCOR	:= U_X011A01("CP1252", alltrim((cAliasQry)->VVC_DESCRI))
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_COMVEI	:= VV1_COMVEI
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_ESTVEI	:= VV1_ESTVEI
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:VV1_KILVEI	:= VV1_KILVEI
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:OPERACAO  	:= IF((cAliasQry)->DELET == '*',"D","")
	::RetVeiculoOficina:aVeiculoOficina[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetVeiculoOficina:aVeiculoOficina[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetVeiculoOficina:aVeiculoOficina[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetVeiculoOficina:aVeiculoOficina[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetVeiculoOficina", Self:RetVeiculoOficina:aVeiculoOficina[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","VV1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// ORDEM DE SERVIÇO (MÓDULO DE OFICINAS)
WSSTRUCT EstrutRetOrdemServicoOficina
	WSDATA VO1_FILIAL				As String
	WSDATA VO1_NUMOSV				As String
	WSDATA VO1_CHAINT				As String
	WSDATA VO1_CHASSI				As String
	WSDATA VO1_PLAVEI				As String
	WSDATA VO1_PROVEI				As String
	WSDATA VO1_LOJPRO				As String
	WSDATA VO1_NOMPRO				As String
	WSDATA VO1_STATUS				As String
	WSDATA VO1_KILOME				As Integer
	WSDATA VO1_NUMBOX				As String
	WSDATA VO1_DATSTA				As Date
	WSDATA VO1_HORSTA				As Integer
	WSDATA VO1_DATABE				As Date
	WSDATA VO1_HORABE				As Integer
	WSDATA VO1_DATENT				As Date
	WSDATA VO1_HORENT				As Integer
	WSDATA VO1_DATSAI				As Date
	WSDATA VO1_HORSAI				As Integer
	WSDATA OPERACAO    				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional	// Campos específicos do cliente
ENDWSSTRUCT
WSSTRUCT RetOrdemServicoOficina
	WSDATA aOrdemServicoOficina		As Array of EstrutRetOrdemServicoOficina Optional
ENDWSSTRUCT

WSMETHOD GetOrdemServicoOficina WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetOrdemServicoOficina WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetOrdemServicoOficina")
cFilDel		:= U_X011A01("FILDEL","VO1",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","VO1",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetOrdemServicoOficina "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT VO1.R_E_C_N_O_, VO1.D_E_L_E_T_ DELET, A1_NOME "
cSql += "FROM "+ RetSqlName("VO1") + " VO1 "
cSql += "LEFT JOIN "+ RetSqlName("SA1") + " SA1 "
cSql += " ON  SA1.D_E_L_E_T_ = ' ' "
cSql += " AND A1_FILIAL = '"+ xFilial("SA1") +"' "
cSql += " AND A1_COD    = VO1_PROVEI "
cSql += " AND A1_LOJA   = VO1_LOJPRO "
cSql += "WHERE 1=1 "
If !Empty(cFiltro)
	cSql += "  AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += "  AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += "  AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("VO1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetOrdemServicoOficina")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	AADD(::RetOrdemServicoOficina:aOrdemServicoOficina,WSClassNew("EstrutRetOrdemServicoOficina"))
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_FILIAL	:= VO1_FILIAL
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_NUMOSV	:= VO1_NUMOSV
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_CHAINT	:= VO1_CHAINT
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_CHASSI 	:= VO1_CHASSI
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_PLAVEI	:= VO1_PLAVEI
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_PROVEI	:= VO1_PROVEI
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_LOJPRO	:= VO1_LOJPRO
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_NOMPRO	:= U_X011A01("CP1252", alltrim((cAliasQry)->A1_NOME))
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_STATUS	:= VO1_STATUS
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_KILOME	:= VO1_KILOME
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_NUMBOX	:= VO1_NUMBOX
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_DATSTA	:= VO1_DATSTA
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_HORSTA	:= VO1_HORSTA
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_DATABE	:= VO1_DATABE
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_HORABE	:= VO1_HORABE
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_DATENT	:= VO1_DATENT
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_HORENT	:= VO1_HORENT
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_DATSAI	:= VO1_DATSAI
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:VO1_HORSAI	:= VO1_HORSAI
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:OPERACAO  	:= IF((cAliasQry)->DELET == '*',"D","")
	::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:CAMPOS_ESPEC := {}
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:CAMPOS_ESPEC[i]:CAMPO := aCpoEspec[i][1]
		::RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]:CAMPOS_ESPEC[i]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetOrdemServicoOficina", Self:RetOrdemServicoOficina:aOrdemServicoOficina[nIdx]);
	
	nIdx++
	
	U_X011A01("UPDEXP","VO1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// CONTRATOS DE PARCERIA - ITEM
WSSTRUCT EstrutRetContratoParceriaItem
	WSDATA ADB_ITEM     			As String
	WSDATA ADB_CODPRO   			As String
	WSDATA ADB_DESPRO   			As String
	WSDATA ADB_UM        			As String
	WSDATA ADB_QUANT    			As Float
	WSDATA ADB_PRCVEN   			As Float
	WSDATA ADB_TOTAL    			As Float
	WSDATA ADB_TES       			As String
	WSDATA ADB_TESCOB   			As String
	WSDATA ADB_LOCAL    			As String
	WSDATA ADB_PRUNIT   			As Float
	WSDATA ADB_SEGUM      			As String
	WSDATA ADB_UNSVEN   			As Float
	WSDATA ADB_DESC     			As Float
	WSDATA ADB_VALDES   			As Float
	WSDATA ADB_FILENT      			As String
	WSDATA ADB_QTDENT    			As Float
	WSDATA ADB_QTDEMP   			As Float
	WSDATA ADB_PEDCOB      			As String
	WSDATA ADB_CATEG    			As String
	WSDATA ADB_CTVAR    			As String
	WSDATA ADB_CULTRA   			As String
	WSDATA ADB_PENE     			As String
	WSDATA OPERACAO    				As String Optional
	WSDATA CAMPOS_ESPEC 			As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT

// CONTRATOS DE PARCERIA - CABEÇALHO + ITENS
WSSTRUCT EstrutRetContratoParceria
	WSDATA ADA_FILIAL 				As String
	WSDATA ADA_NUMCTR  				As String
	WSDATA ADA_EMISSA  				As Date	
	WSDATA ADA_CODCLI  				As String
	WSDATA ADA_LOJCLI  				As String
	WSDATA ADA_CONDPG  				As String
	WSDATA ADA_TABELA  				As String
	WSDATA ADA_DESC1  				As Float 
	WSDATA ADA_DESC2  				As Float 
	WSDATA ADA_DESC3  				As Float 
	WSDATA ADA_DESC4  				As Float 
	WSDATA ADA_VEND1  				As String
	WSDATA ADA_VEND2  				As String
	WSDATA ADA_VEND3  				As String
	WSDATA ADA_VEND4  				As String
	WSDATA ADA_VEND5  				As String
	WSDATA ADA_COMIS1  				As Float 
	WSDATA ADA_COMIS2  				As Float 
	WSDATA ADA_COMIS3  				As Float 
	WSDATA ADA_COMIS4  				As Float 
	WSDATA ADA_COMIS5  				As Float 
	WSDATA ADA_MOEDA   				As Integer
	WSDATA ADA_STATUS  				As String
	WSDATA ADA_SAFRA  				As String
	WSDATA ADA_CODSAF  				As String
	WSDATA ADA_SEGURO  				As Float 
	WSDATA ADA_FRETE   				As Float 
	WSDATA ADA_TPFRET  				As String
	WSDATA ADA_X_NSIM  				As String
	WSDATA AITENS     				As Array of EstrutRetContratoParceriaItem
	WSDATA OPERACAO    				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT
WSSTRUCT RetContratoParceria
	WSDATA aContratoParceria		As Array of EstrutRetContratoParceria Optional
ENDWSSTRUCT

WSMETHOD GetContratoParceria WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetContratoParceria WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cFilDel2	:= ""
Local cCpoExpo	:= ""
Local cCpoExpo2	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local i
Local oReg, oItem
Local nADA_Recno

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetContratoParceria")
cFilDel		:= U_X011A01("FILDEL","ADA",INOPCAO)
cFilDel2	:= U_X011A01("FILDEL","ADB",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","ADA",INOPCAO)
cCpoExpo2	:= U_X011A01("CMPEXP","ADB",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetContratoParceria "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT ADA.R_E_C_N_O_, ADA.D_E_L_E_T_ DELET, ADB.R_E_C_N_O_ ADBRECNO "
cSql += "FROM "+ RetSqlName("ADA") + " ADA "
cSql += "INNER JOIN "+ RetSqlName("ADB") + " ADB "
cSql += " ON  ADB_FILIAL = ADA_FILIAL "
cSql += " AND ADB_NUMCTR = ADA_NUMCTR "
cSql += "WHERE 1=1 "
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFilDel2)
	cSql += " AND "+ cFilDel2 +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cCpoExpo) .and. !Empty(cCpoExpo2) .and. !lOpcFull	// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND ("+ cCpoExpo +" <> 'S' OR "+ cCpoExpo2 +" <> 'S') "
Endif
cSql += "ORDER BY ADA.R_E_C_N_O_, ADB.R_E_C_N_O_ "
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("ADA")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	oReg := WSClassNew("EstrutRetContratoParceria")
	oReg:ADA_FILIAL	 	:= ADA->ADA_FILIAL
	oReg:ADA_NUMCTR  	:= ADA->ADA_NUMCTR
	oReg:ADA_EMISSA  	:= ADA->ADA_EMISSA
	oReg:ADA_CODCLI  	:= ADA->ADA_CODCLI
	oReg:ADA_LOJCLI  	:= ADA->ADA_LOJCLI
	oReg:ADA_CONDPG  	:= ADA->ADA_CONDPG
	oReg:ADA_TABELA  	:= ADA->ADA_TABELA
	oReg:ADA_DESC1  	:= ADA->ADA_DESC1
	oReg:ADA_DESC2  	:= ADA->ADA_DESC2
	oReg:ADA_DESC3  	:= ADA->ADA_DESC3
	oReg:ADA_DESC4  	:= ADA->ADA_DESC4
	oReg:ADA_VEND1  	:= ADA->ADA_VEND1
	oReg:ADA_VEND2  	:= ADA->ADA_VEND2
	oReg:ADA_VEND3  	:= ADA->ADA_VEND3
	oReg:ADA_VEND4  	:= ADA->ADA_VEND4
	oReg:ADA_VEND5  	:= ADA->ADA_VEND5
	oReg:ADA_COMIS1  	:= ADA->ADA_COMIS1
	oReg:ADA_COMIS2  	:= ADA->ADA_COMIS2
	oReg:ADA_COMIS3  	:= ADA->ADA_COMIS3
	oReg:ADA_COMIS4  	:= ADA->ADA_COMIS4
	oReg:ADA_COMIS5  	:= ADA->ADA_COMIS5
	oReg:ADA_MOEDA  	:= ADA->ADA_MOEDA
	oReg:ADA_STATUS  	:= ADA->ADA_STATUS
	oReg:ADA_SAFRA  	:= ADA->ADA_SAFRA
	oReg:ADA_CODSAF  	:= ADA->ADA_CODSAF
	oReg:ADA_SEGURO  	:= ADA->ADA_SEGURO
	oReg:ADA_FRETE  	:= ADA->ADA_FRETE
	oReg:ADA_TPFRET  	:= ADA->ADA_TPFRET
	oReg:ADA_X_NSIM  	:= IF( ADA->(FieldPos("ADA_X_NSIM")) > 0, ADA->ADA_X_NSIM, "" )
	oReg:OPERACAO  		:= IF((cAliasQry)->DELET == '*',"D","")
	oReg:CAMPOS_ESPEC	:= {}
	oReg:AITENS    		:= {}
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetContratoParceria")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		If Substr(Upper(Alltrim( aCpoEspec[i][1] )),1,3) == "ADA"
			AADD(oReg:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:CAMPO := aCpoEspec[i][1]
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:VALOR := aCpoEspec[i][2]
		Endif
	Next i
	
	// Adiciona os itens do contrato de parceria
	nADA_Recno := (cAliasQry)->R_E_C_N_O_
	While ! (cAliasQry)->(Eof()) .and. nADA_Recno == (cAliasQry)->R_E_C_N_O_
		dbSelectArea("ADB")
		dbGoTo( (cAliasQry)->ADBRECNO )
		oItem := WSClassNew("EstrutRetContratoParceriaItem")
		oItem:ADB_ITEM   	:= ADB->ADB_ITEM
		oItem:ADB_CODPRO 	:= ADB->ADB_CODPRO
		oItem:ADB_DESPRO 	:= ADB->ADB_DESPRO
		oItem:ADB_UM     	:= ADB->ADB_UM
		oItem:ADB_QUANT  	:= ADB->ADB_QUANT
		oItem:ADB_PRCVEN 	:= ADB->ADB_PRCVEN
		oItem:ADB_TOTAL  	:= ADB->ADB_TOTAL
		oItem:ADB_TES    	:= ADB->ADB_TES
		oItem:ADB_TESCOB 	:= ADB->ADB_TESCOB
		oItem:ADB_PRUNIT 	:= ADB->ADB_PRUNIT
		oItem:ADB_SEGUM  	:= ADB->ADB_SEGUM
		oItem:ADB_UNSVEN 	:= ADB->ADB_UNSVEN
		oItem:ADB_LOCAL  	:= ADB->ADB_LOCAL
		oItem:ADB_DESC   	:= ADB->ADB_DESC
		oItem:ADB_VALDES 	:= ADB->ADB_VALDES
		oItem:ADB_FILENT 	:= ADB->ADB_FILENT
		oItem:ADB_QTDENT 	:= ADB->ADB_QTDENT
		oItem:ADB_QTDEMP 	:= ADB->ADB_QTDEMP
		oItem:ADB_PEDCOB 	:= ADB->ADB_PEDCOB
		oItem:ADB_CATEG 	:= ADB->ADB_CATEG
		oItem:ADB_CTVAR 	:= ADB->ADB_CTVAR
		oItem:ADB_CULTRA 	:= ADB->ADB_CULTRA
		oItem:ADB_PENE   	:= ADB->ADB_PENE
		oItem:OPERACAO    	:= IF( ADB->(Deleted()),"D","")
		oItem:CAMPOS_ESPEC	:= {}
		
		// Ponto de Entrada para campos específicos (array)
		aCpoEspec := U_X011A01("CMPESPEC","GetContratoParceria")
		
		// Campos específicos via parâmetro de entrada
		aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
		
		// Tratativa para campos específicos (customizados)
		For i := 1 to Len(aCpoEspec)
			If Substr(Upper(Alltrim( aCpoEspec[i][1] )),1,3) == "ADB"
				AADD(oItem:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
				oItem:CAMPOS_ESPEC[ Len(oItem:CAMPOS_ESPEC) ]:CAMPO := aCpoEspec[i][1]
				oItem:CAMPOS_ESPEC[ Len(oItem:CAMPOS_ESPEC) ]:VALOR := aCpoEspec[i][2]
			Endif
		Next i
		
		AADD(oReg:AITENS, oItem)
		U_X011A01("UPDEXP","ADB", cCpoExpo2, (cAliasQry)->ADBRECNO )
		(cAliasQry)->(DbSkip())
	Enddo
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetContratoParceria", oReg);
	
	nIdx++
	AADD(::RetContratoParceria:aContratoParceria, oReg)
	U_X011A01("UPDEXP","ADA", cCpoExpo, nADA_Recno )
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// TRANSPORTADORA
WSSTRUCT EstrutRetTransportadora
	WSDATA A4_FILIAL 				As String
	WSDATA A4_COD    				As String
	WSDATA A4_NOME    				As String
	WSDATA A4_NREDUZ 				As String
	WSDATA A4_VIA     				As String
	WSDATA A4_END    				As String
	WSDATA A4_BAIRRO 				As String
	WSDATA A4_MUN   				As String
	WSDATA A4_COD_MUN  				As String
	WSDATA A4_EST   				As String
	WSDATA A4_CEP   				As String
	WSDATA A4_DDD    				As String
	WSDATA A4_TEL    				As String
	WSDATA A4_CGC   				As String
	WSDATA A4_INSEST				As String
	WSDATA A4_EMAIL 				As String
	WSDATA A4_HPAGE 				As String
	WSDATA A4_COMPLEM  				As String
	WSDATA A4_CODPAIS  				As String
	WSDATA A4_MSBLQL 				As String
	WSDATA OPERACAO 				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT  
WSSTRUCT RetTransportadora
	WSDATA aTransportadora 			As Array of EstrutRetTransportadora Optional
ENDWSSTRUCT

WSMETHOD GetTransportadora WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetTransportadora WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoEspec	:= {}
Local aCpoAdic	:= {}
Local lOpcFull	:= .F.
Local lFullDel	:= .F.
Local oReg
Local i

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)
cFiltroPE	:= U_X011A01("FILSQL","GetTransportadora")
cFilDel		:= U_X011A01("FILDEL","SA4",INOPCAO)
cCpoExpo	:= U_X011A01("CMPEXP","SA4",INOPCAO)
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))
lFullDel	:= ("FULL" $ Upper(Alltrim(INOPCAO)) .and. "DELET" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetTransportadora "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT SA4.R_E_C_N_O_, SA4.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("SA4") +" SA4 "
cSql += "WHERE 1=1 "
If ! lFullDel .and. SA4->(FieldPos("A4_X_SIM3G")) > 0
	cSql += " AND SA4.A4_X_SIM3G <> 'N' "	// Filtra registros marcados para integrar com o SIM3G
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "		// Filtra registros DELETADOS ou NAO DELETADOS
Endif
If !Empty(cFiltro)						// Adiciona os filtros informados na invocação do método
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)					// Adiciona os filtros informados no Ponto de Entrada
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND "+ cCpoExpo +" <> 'S' "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)

While ! (cAliasQry)->(Eof())
	dbSelectArea("SA4")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	oReg := WSClassNew("EstrutRetTransportadora")
	oReg:A4_FILIAL  := A4_FILIAL
	oReg:A4_COD     := A4_COD
	oReg:A4_NOME    := U_X011A01("CP1252",A4_NOME)
	oReg:A4_NREDUZ  := U_X011A01("CP1252",A4_NREDUZ)
	oReg:A4_VIA     := U_X011A01("CP1252",A4_VIA)
	oReg:A4_END     := U_X011A01("CP1252",A4_END)
	oReg:A4_BAIRRO  := U_X011A01("CP1252",A4_BAIRRO)
	oReg:A4_MUN     := U_X011A01("CP1252",A4_MUN)
	oReg:A4_COD_MUN := A4_COD_MUN
	oReg:A4_EST     := A4_EST
	oReg:A4_CEP     := A4_CEP
	oReg:A4_DDD     := A4_DDD
	oReg:A4_TEL     := U_X011A01("CP1252",A4_TEL)
	oReg:A4_CGC     := U_X011A01("CP1252",A4_CGC)
	oReg:A4_INSEST  := U_X011A01("CP1252",A4_INSEST)
	oReg:A4_EMAIL   := U_X011A01("CP1252",A4_EMAIL)
	oReg:A4_HPAGE   := U_X011A01("CP1252",A4_HPAGE)
	oReg:A4_COMPLEM := U_X011A01("CP1252",A4_COMPLEM)
	oReg:A4_CODPAIS := Alltrim(A4_CODPAIS)
	oReg:A4_MSBLQL  := IF( FieldPos("A4_MSBLQL") > 0, A4_MSBLQL, "2" )
	oReg:OPERACAO	:= IF((cAliasQry)->DELET == '*' .or. A4_X_SIM3G == "N","D","")
	oReg:CAMPOS_ESPEC := {}

	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetTransportadora")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		AADD(oReg:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
		oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:CAMPO := aCpoEspec[i][1]
		oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:VALOR := aCpoEspec[i][2]
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetTransportadora", oReg);

	nIdx++
	AADD(::RetTransportadora:aTransportadora, oReg)
	U_X011A01("UPDEXP","SA4", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



// REGRA DE NEGOCIO - DESCONTOS
WSSTRUCT EstrutRetRegraNegocioDesconto
	WSDATA ACN_ITEM     			As String
	WSDATA ACN_GRPPRO    			As String
	WSDATA ACN_CODPRO   			As String
	WSDATA ACN_DESCON    			As Float
	WSDATA ACN_ITEMGR   			As String
	WSDATA OPERACAO    				As String Optional
	WSDATA CAMPOS_ESPEC 			As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT

// REGRA DE NEGOCIO - CABECALHO
WSSTRUCT EstrutRetRegraNegocio
	WSDATA ACS_FILIAL 				As String
	WSDATA ACS_CODREG  				As String
	WSDATA ACS_DESCRI  				As String	
	WSDATA ACS_CODCLI  				As String
	WSDATA ACS_LOJA    				As String
	WSDATA ACS_GRPVEN  				As String
	WSDATA ACS_TPHORA 				As String 
	WSDATA ACS_HORDE 				As String 
	WSDATA ACS_HORATE 				As String 
	WSDATA ACS_DATDE 				As Date
	WSDATA ACS_DATATE  				As Date
	WSDATA ADESCONTOS     			As Array of EstrutRetRegraNegocioDesconto
	WSDATA OPERACAO    				As String Optional
	WSDATA CAMPOS_ESPEC				As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT
WSSTRUCT RetRegraNegocio
	WSDATA aRegraNegocio			As Array of EstrutRetRegraNegocio Optional
ENDWSSTRUCT

WSMETHOD GetRegraNegocio WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetRegraNegocio WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cFilDel2	:= ""
Local cCpoExpo	:= ""
Local cCpoExpo2	:= ""
Local aCpoAdic	:= {}
Local aCpoEspec	:= {}
Local lOpcFull	:= .F.
Local i
Local oReg, oItem
Local nACS_Recno

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)	// Filtro via parâmetro do GET
cFiltroPE	:= U_X011A01("FILSQL","GetRegraNegocio")	// Filtro via ponto de entrada
cFilDel		:= U_X011A01("FILDEL","ACS",INOPCAO)		// Filtra registros DELETADOS ou NAO DELETADOS
cFilDel2	:= U_X011A01("FILDEL","ACN",INOPCAO)		// Filtra registros DELETADOS ou NAO DELETADOS
cCpoExpo	:= U_X011A01("CMPEXP","ACS",INOPCAO)		// Campo de registro Exportado (S/N) via TRIGGER
cCpoExpo2	:= U_X011A01("CMPEXP","ACN",INOPCAO)		// Campo de registro Exportado (S/N) via TRIGGER
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)			// Campos adicionais via parâmetro do GET
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetRegraNegocio "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT ACS.R_E_C_N_O_, ACS.D_E_L_E_T_ DELET, ACN.R_E_C_N_O_ ACNRECNO "
cSql += "FROM "+ RetSqlName("ACS") + " ACS "
cSql += "INNER JOIN "+ RetSqlName("ACN") + " ACN "
cSql += " ON  ACN_FILIAL = ACS_FILIAL "
cSql += " AND ACN_CODREG = ACS_CODREG "
cSql += "WHERE 1=1 "
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "
Endif
If !Empty(cFilDel2)
	cSql += " AND "+ cFilDel2 +" "
Endif
If !Empty(cCpoExpo) .and. !Empty(cCpoExpo2) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND ("+ cCpoExpo +" <> 'S' OR "+ cCpoExpo2 +" <> 'S') "
Endif
cSql += "ORDER BY ACS.R_E_C_N_O_, ACN.R_E_C_N_O_ "
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("ACS")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	oReg := WSClassNew("EstrutRetRegraNegocio")
	oReg:ACS_FILIAL	 	:= ACS->ACS_FILIAL
	oReg:ACS_CODREG  	:= ACS->ACS_CODREG
	oReg:ACS_DESCRI  	:= ACS->ACS_DESCRI
	oReg:ACS_CODCLI  	:= ACS->ACS_CODCLI
	oReg:ACS_LOJA    	:= ACS->ACS_LOJA
	oReg:ACS_GRPVEN  	:= ACS->ACS_GRPVEN
	oReg:ACS_TPHORA  	:= ACS->ACS_TPHORA
	oReg:ACS_HORDE   	:= ACS->ACS_HORDE
	oReg:ACS_HORATE 	:= ACS->ACS_HORATE
	oReg:ACS_DATDE   	:= ACS->ACS_DATDE
	oReg:ACS_DATATE 	:= ACS->ACS_DATATE
	oReg:OPERACAO  		:= IF((cAliasQry)->DELET == '*',"D","")
	oReg:CAMPOS_ESPEC	:= {}
	oReg:ADESCONTOS    	:= {}
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetRegraNegocio")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		If Substr(Upper(Alltrim( aCpoEspec[i][1] )),1,3) == "ACS"
			AADD(oReg:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:CAMPO := aCpoEspec[i][1]
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:VALOR := aCpoEspec[i][2]
		Endif
	Next i
	
	// Adiciona os itens do contrato de parceria
	nACS_Recno := (cAliasQry)->R_E_C_N_O_
	While ! (cAliasQry)->(Eof()) .and. nACS_Recno == (cAliasQry)->R_E_C_N_O_
		dbSelectArea("ACN")
		dbGoTo( (cAliasQry)->ACNRECNO )
		oItem := WSClassNew("EstrutRetRegraNegocioDesconto")
		oItem:ACN_ITEM   	:= ACN->ACN_ITEM
		oItem:ACN_GRPPRO 	:= ACN->ACN_GRPPRO
		oItem:ACN_CODPRO 	:= ACN->ACN_CODPRO
		oItem:ACN_DESCON 	:= ACN->ACN_DESCON
		oItem:ACN_ITEMGR  	:= ACN->ACN_ITEMGR
		oItem:OPERACAO    	:= IF( ACN->(Deleted()),"D","")
		oItem:CAMPOS_ESPEC	:= {}
		
		// Ponto de Entrada para campos específicos (array)
		aCpoEspec := U_X011A01("CMPESPEC","GetRegraNegocio")
		
		// Campos específicos via parâmetro de entrada
		aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
		
		// Tratativa para campos específicos (customizados)
		For i := 1 to Len(aCpoEspec)
			If Substr(Upper(Alltrim( aCpoEspec[i][1] )),1,3) == "ACN"
				AADD(oItem:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
				oItem:CAMPOS_ESPEC[ Len(oItem:CAMPOS_ESPEC) ]:CAMPO := aCpoEspec[i][1]
				oItem:CAMPOS_ESPEC[ Len(oItem:CAMPOS_ESPEC) ]:VALOR := aCpoEspec[i][2]
			Endif
		Next i
		
		AADD(oReg:ADESCONTOS, oItem)
		U_X011A01("UPDEXP","ACN", cCpoExpo2, (cAliasQry)->ACNRECNO )
		(cAliasQry)->(DbSkip())
	Enddo
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetRegraNegocio", oReg);
	
	nIdx++
	AADD(::RetRegraNegocio:aRegraNegocio, oReg)
	U_X011A01("UPDEXP","ACS", cCpoExpo, nACS_Recno )
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Método GetDocCargaGFE - Documento de Carga (GFE)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT EstrutRetGW1
	WSDATA GW1_FILIAL 			As String
	WSDATA GW1_CDTPDC  			As String
	WSDATA GW1_EMISDC  			As String
	WSDATA GW1_NMEMIS 			As String //Virtual
	WSDATA GW1_DTEMIS  			As Date
	WSDATA GW1_SERDC   			As String
	WSDATA GW1_NRDC   			As String
	WSDATA GW1_ORIGEM   		As String //1=Usuario;2=ERP;3=SIGATMS;9=Outros
	WSDATA GW1_SIT   			As String //1=Digitado;2=Bloqueado;3=Liberado;4=Embarcado;5=Entregue;6=Retornado;7=Cancelado;8=Sinistrado
	WSDATA GW1_CDREM   			As String
	WSDATA GW1_NMREM  			As String //Virtual
	WSDATA GW1_CDDEST  			As String
	WSDATA GW1_NMDEST  			As String //Virtual
	WSDATA GW1_TPFRET			As String //1=CIF;2=CIF Redesp.;3=FOB;4=FOB Redesp.;5=Consignado;6=Consig. Redesp.
	WSDATA GW1_NRROM   			As String
	WSDATA GW1_DTIMPL   		As Date
	WSDATA GW1_HRIMPL  			As String
	WSDATA GW1_DSESP   			As String
	WSDATA GW1_QTVOL   			As Float
	WSDATA GW1_CARREG   		As String
	WSDATA GW1_REGCOM   		As String
	WSDATA GW1_REPRES   		As String
	WSDATA GW1_ICMSDC   		As String //1=Sim;2=Nao
	WSDATA GW1_ORINR   			As String
	WSDATA GW1_ORISER  			As String
	WSDATA GW1_ENTEND  			As String
	WSDATA GW1_ENTBAI  			As String
	WSDATA GW1_ENTCEP  			As String
	WSDATA GW1_ENTNRC  			As String
	WSDATA GW1_ENTCID  			As String //Virtual
	WSDATA GW1_ENTUF   			As String //Virtual
	WSDATA GW1_DTLIB    		As Date
	WSDATA GW1_HRLIB   			As String
	WSDATA GW1_DTPSAI    		As Date
	WSDATA GW1_HRPSAI   		As String
	WSDATA GW1_DTSAI     		As Date
	WSDATA GW1_HRSAI    		As String
	WSDATA GW1_DTPENT     		As Date
	WSDATA GW1_HRPENT    		As String
	WSDATA GW1_DTALT      		As Date
	WSDATA GW1_HRALT     		As String
	WSDATA GW1_DTCAN      		As Date
	WSDATA GW1_HRCAN     		As String
	WSDATA GW1_AUTSEF 			As String //0=Nao informado;1=Autorizado;2=Nao-autorizado;3=Nao se aplica
	WSDATA OPERACAO    			As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT
WSSTRUCT RetGW1
	WSDATA aRegistros			As Array of EstrutRetGW1 Optional
ENDWSSTRUCT

WSMETHOD GetDocCargaGFE WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetGW1 WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoAdic	:= {}
Local aCpoEspec	:= {}
Local lOpcFull	:= .f.
Local i
Local oReg

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)	// Filtro via parâmetro do GET
cFiltroPE	:= U_X011A01("FILSQL","GetDocCargaGFE")		// Filtro via ponto de entrada
cFilDel		:= U_X011A01("FILDEL","GW1",INOPCAO)		// Filtra registros DELETADOS ou NAO DELETADOS
cCpoExpo	:= U_X011A01("CMPEXP","GW1",INOPCAO)		// Campo de registro Exportado (S/N) via TRIGGER
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)			// Campos adicionais via parâmetro do GET
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetDocCargaGFE "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT GW1.R_E_C_N_O_, GW1.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("GW1") + " GW1 "
cSql += "WHERE 1=1 "
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND ("+ cCpoExpo +" <> 'S') "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("GW1")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	oReg := WSClassNew("EstrutRetGW1")
	oReg:GW1_FILIAL	 	:= GW1->GW1_FILIAL
	oReg:GW1_CDTPDC 	:= GW1->GW1_CDTPDC 
	oReg:GW1_EMISDC  	:= GW1->GW1_EMISDC 
	oReg:GW1_NMEMIS 	:= U_X011A01("CP1252", POSICIONE("GU3",1,XFILIAL("GU3")+GW1->GW1_EMISDC,"GU3_NMEMIT"))
	oReg:GW1_DTEMIS  	:= GW1->GW1_DTEMIS 
	oReg:GW1_SERDC  	:= GW1->GW1_SERDC  
	oReg:GW1_NRDC    	:= GW1->GW1_NRDC   
	oReg:GW1_ORIGEM  	:= GW1->GW1_ORIGEM 
	oReg:GW1_SIT    	:= GW1->GW1_SIT   
	oReg:GW1_CDREM   	:= GW1->GW1_CDREM  
	oReg:GW1_NMREM  	:= U_X011A01("CP1252", POSICIONE("GU3",1,XFILIAL("GU3")+GW1->GW1_CDREM,"GU3_NMEMIT"))
	oReg:GW1_CDDEST   	:= GW1->GW1_CDDEST  
	oReg:GW1_NMDEST  	:= U_X011A01("CP1252", POSICIONE("GU3",1,XFILIAL("GU3")+GW1->GW1_CDDEST,"GU3_NMEMIT"))
	oReg:GW1_TPFRET		:= GW1->GW1_TPFRET
	oReg:GW1_NRROM  	:= GW1->GW1_NRROM  
	oReg:GW1_DTIMPL  	:= GW1->GW1_DTIMPL 
	oReg:GW1_HRIMPL 	:= GW1->GW1_HRIMPL 
	oReg:GW1_DSESP  	:= U_X011A01("CP1252", GW1->GW1_DSESP)
	oReg:GW1_QTVOL  	:= GW1->GW1_QTVOL  
	oReg:GW1_CARREG 	:= GW1->GW1_CARREG 
	oReg:GW1_REGCOM 	:= GW1->GW1_REGCOM 
	oReg:GW1_REPRES 	:= U_X011A01("CP1252", GW1->GW1_REPRES)
	oReg:GW1_ICMSDC 	:= GW1->GW1_ICMSDC 
	oReg:GW1_ORINR  	:= GW1->GW1_ORINR  
	oReg:GW1_ORISER 	:= GW1->GW1_ORISER 
	oReg:GW1_ENTEND 	:= U_X011A01("CP1252", GW1->GW1_ENTEND)
	oReg:GW1_ENTBAI 	:= U_X011A01("CP1252", GW1->GW1_ENTBAI)
	oReg:GW1_ENTCEP 	:= GW1->GW1_ENTCEP 
	oReg:GW1_ENTNRC 	:= GW1->GW1_ENTNRC 
	oReg:GW1_ENTCID 	:= U_X011A01("CP1252", POSICIONE("GU7",1,XFILIAL("GU7")+GW1->GW1_ENTNRC,"GU7_NMCID"))
	oReg:GW1_ENTUF  	:= U_X011A01("CP1252", POSICIONE("GU7",1,XFILIAL("GU7")+GW1->GW1_ENTNRC,"GU7_CDUF"))  
	oReg:GW1_DTLIB  	:= GW1->GW1_DTLIB  
	oReg:GW1_HRLIB  	:= GW1->GW1_HRLIB  
	oReg:GW1_DTPSAI 	:= GW1->GW1_DTPSAI 
	oReg:GW1_HRPSAI 	:= GW1->GW1_HRPSAI 
	oReg:GW1_DTSAI  	:= GW1->GW1_DTSAI  
	oReg:GW1_HRSAI  	:= GW1->GW1_HRSAI  
	oReg:GW1_DTPENT 	:= GW1->GW1_DTPENT 
	oReg:GW1_HRPENT 	:= GW1->GW1_HRPENT 
	oReg:GW1_DTALT  	:= GW1->GW1_DTALT  
	oReg:GW1_HRALT  	:= GW1->GW1_HRALT  
	oReg:GW1_DTCAN  	:= GW1->GW1_DTCAN  
	oReg:GW1_HRCAN  	:= GW1->GW1_HRCAN  
	oReg:GW1_AUTSEF 	:= GW1->GW1_AUTSEF 
	oReg:OPERACAO  		:= IF((cAliasQry)->DELET == '*',"D","")
	oReg:CAMPOS_ESPEC	:= {}
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetDocCargaGFE")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		If Substr(Upper(Alltrim( aCpoEspec[i][1] )),1,3) == "GW1"
			AADD(oReg:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:CAMPO := aCpoEspec[i][1]
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:VALOR := aCpoEspec[i][2]
		Endif
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetDocCargaGFE", oReg);
	
	nIdx++
	AADD(Self:RetGW1:aRegistros, oReg)
	U_X011A01("UPDEXP","GW1", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Método GetEmitenteGFE - Emitentes de Transporte de Frete (GFE) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT EstrutRetGU3
	WSDATA GU3_FILIAL 			As String
	WSDATA GU3_CDEMIT 			As String
	WSDATA GU3_NMEMIT 			As String	
	WSDATA GU3_NMFAN   			As String
	WSDATA GU3_NMABRV  			As String
	WSDATA GU3_NATUR  			As String // J=Juridica;F=Fisica;X=Outros
	WSDATA GU3_DTNASC 			As Date 
	WSDATA GU3_DTIMPL 			As Date 
	WSDATA GU3_SIT   			As String // 1=Ativo;2=Inativo
	WSDATA GU3_EMFIL			As String // 1=Sim;2=Nao
	WSDATA GU3_TRANSP 			As String // 1=Sim;2=Nao
	WSDATA GU3_CLIEN 			As String // 1=Sim;2=Nao
	WSDATA GU3_FORN  			As String // 1=Sim;2=Nao
	WSDATA GU3_AUTON  			As String // 1=Sim;2=Nao
	WSDATA GU3_ENDER 			As String
	WSDATA GU3_COMPL 			As String
	WSDATA GU3_BAIRRO			As String
	WSDATA GU3_CEP   			As String
	WSDATA GU3_NRCID  			As String // Chave Tabela GU7
	WSDATA GU3_NMCID 			As String // Virtual
	WSDATA GU3_UF    			As String // Virtual
	WSDATA GU3_IDFED 			As String // Identificacao Federal CNPJ/CPF
	WSDATA GU3_IE    			As String
	WSDATA GU3_ORGEXP			As String
	WSDATA GU3_IM    			As String
	WSDATA GU3_CXPOS 			As String
	WSDATA GU3_EMAIL 			As String
	WSDATA GU3_FONE1 			As String
	WSDATA GU3_RAMAL1			As Integer
	WSDATA GU3_FONE2 			As String
	WSDATA GU3_RAMAL2			As Integer
	WSDATA GU3_WSITE 			As String
	WSDATA GU3_CATTRP			As String // 1=Empresa Comercial;2=Autonomo;3=Cooperativa;4=Operador Logistico;5=Distribuidor;6=Correios;7=Proprio Embarcador;8=Outros
	WSDATA GU3_MODAL 			As String // 1=Nao-informado;2=Rodoviario;3=Ferroviario;4=Aereo;5=Aquaviario;6=Dutoviario;7=Multimodal
	WSDATA GU3_OBS   			As String
	WSDATA OPERACAO    			As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT
WSSTRUCT RetGU3
	WSDATA aRegistros			As Array of EstrutRetGU3 Optional
ENDWSSTRUCT

WSMETHOD GetEmitenteGFE WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetGU3 WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoAdic	:= {}
Local aCpoEspec	:= {}
Local lOpcFull	:= .F.
Local i
Local oReg

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)	// Filtro via parâmetro do GET
cFiltroPE	:= U_X011A01("FILSQL","GetEmitenteGFE")		// Filtro via ponto de entrada
cFilDel		:= U_X011A01("FILDEL","GU3",INOPCAO)		// Filtra registros DELETADOS ou NAO DELETADOS
cCpoExpo	:= U_X011A01("CMPEXP","GU3",INOPCAO)		// Campo de registro Exportado (S/N) via TRIGGER
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)			// Campos adicionais via parâmetro do GET
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetEmitenteGFE"+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT GU3.R_E_C_N_O_, GU3.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("GU3") + " GU3 "
cSql += "WHERE 1=1 "
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND ("+ cCpoExpo +" <> 'S') "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("GU3")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	
	if FieldPos("R_E_C_N_O_") > 0
		conout("- RECNO: "+ cValtochar(GU3->(Recno())) )
	Else
		conout("- RECNO NAO EXISTE" )
	endif
	
	oReg := WSClassNew("EstrutRetGU3")
	oReg:GU3_FILIAL	 	:= GU3->GU3_FILIAL
	oReg:GU3_CDEMIT    	:= GU3->GU3_CDEMIT
	oReg:GU3_NMEMIT    	:= U_X011A01("CP1252",GU3->GU3_NMEMIT)
	oReg:GU3_NMFAN   	:= U_X011A01("CP1252",GU3->GU3_NMFAN )
	oReg:GU3_NMABRV  	:= U_X011A01("CP1252",GU3->GU3_NMABRV)
	oReg:GU3_NATUR  	:= GU3->GU3_NATUR
	oReg:GU3_DTNASC  	:= GU3->GU3_DTNASC
	oReg:GU3_DTIMPL  	:= GU3->GU3_DTIMPL
	oReg:GU3_SIT   		:= GU3->GU3_SIT
	oReg:GU3_EMFIL		:= GU3->GU3_EMFIL
	oReg:GU3_TRANSP 	:= GU3->GU3_TRANSP
	oReg:GU3_CLIEN 		:= GU3->GU3_CLIEN
	oReg:GU3_FORN  		:= GU3->GU3_FORN
	oReg:GU3_AUTON  	:= GU3->GU3_AUTON
	oReg:GU3_ENDER 		:= U_X011A01("CP1252",GU3->GU3_ENDER)
	oReg:GU3_COMPL 		:= U_X011A01("CP1252",GU3->GU3_COMPL)
	oReg:GU3_BAIRRO		:= U_X011A01("CP1252",GU3->GU3_BAIRRO)
	oReg:GU3_CEP   		:= GU3->GU3_CEP
	oReg:GU3_NRCID  	:= GU3->GU3_NRCID
	oReg:GU3_NMCID 		:= U_X011A01("CP1252", POSICIONE("GU7",1,XFILIAL("GU7")+GU3->GU3_NRCID,"GU7_NMCID") )
	oReg:GU3_UF    		:= POSICIONE("GU7",1,XFILIAL("GU7")+GU3->GU3_NRCID,"GU7_CDUF")
	oReg:GU3_IDFED 		:= GU3->GU3_IDFED
	oReg:GU3_IE    		:= GU3->GU3_IE
	oReg:GU3_ORGEXP		:= GU3->GU3_ORGEXP
	oReg:GU3_IM    		:= GU3->GU3_IM
	oReg:GU3_CXPOS 		:= GU3->GU3_CXPOS
	oReg:GU3_EMAIL 		:= Alltrim(GU3->GU3_EMAIL)
	oReg:GU3_FONE1 		:= Alltrim(GU3->GU3_FONE1)
	oReg:GU3_RAMAL1		:= GU3->GU3_RAMAL1
	oReg:GU3_FONE2 		:= Alltrim(GU3->GU3_FONE2)
	oReg:GU3_RAMAL2		:= GU3->GU3_RAMAL2
	oReg:GU3_WSITE 		:= Alltrim(GU3->GU3_WSITE)
	oReg:GU3_CATTRP		:= GU3->GU3_CATTRP
	oReg:GU3_MODAL 		:= GU3->GU3_MODAL
	oReg:GU3_OBS   		:= U_X011A01("CP1252",GU3->GU3_OBS)
	oReg:OPERACAO  		:= IF((cAliasQry)->DELET == '*',"D","")
	oReg:CAMPOS_ESPEC	:= {}
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetEmitenteGFE")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		If Substr(Upper(Alltrim( aCpoEspec[i][1] )),1,3) == "GU3"
			AADD(oReg:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:CAMPO := aCpoEspec[i][1]
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:VALOR := aCpoEspec[i][2]
		Endif
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetEmitenteGFE", oReg);
	
	nIdx++
	AADD(Self:RetGU3:aRegistros, oReg)
	U_X011A01("UPDEXP","GU3", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Método GetFreteGFE - Rateio Contábil de Frete (GFE)  ³
//³Tabela GWM - Rateio Contábil de Frete                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT EstrutRetGWM
	WSDATA GWM_FILIAL 			As String
	WSDATA GWM_TPDOC 			As String //1=Calculo Frete;2=CTRC/NFS;3=Contrato Autonomo;4=Estimativa
	WSDATA GWM_CDESP 			As String	
	WSDATA GWM_CDTRP   			As String
	WSDATA GWM_DSTRP  			As String //Virtual
	WSDATA GWM_SERDOC  			As String
	WSDATA GWM_NRDOC  			As String
	WSDATA GWM_DTEMIS  			As Date
	WSDATA GWM_CDTPDC  			As String
	WSDATA GWM_DSTPDC  			As String //Virtual
	WSDATA GWM_EMISDC  			As String
	WSDATA GWM_NMEMIT 			As String //Virtual
	WSDATA GWM_SERDC   			As String
	WSDATA GWM_NRDC   			As String
	WSDATA GWM_GRPCTB 			As String
	WSDATA GWM_SEQGW8 			As String
	WSDATA GWM_DTEMDC  			As Date
	WSDATA GWM_ITEM   			As String
	WSDATA GWM_DSITEM  			As String //Virtual não existe SX3
	WSDATA GWM_UNINEG 			As String
	WSDATA GWM_VLINAU 			As Float
	WSDATA GWM_VLINEM 			As Float
	WSDATA GWM_VLIRRF 			As Float
	WSDATA GWM_VLSEST 			As Float
	WSDATA GWM_VLISS  			As Float
	WSDATA GWM_VLICMS 			As Float
	WSDATA GWM_VLPIS  			As Float
	WSDATA GWM_VLCOFI 			As Float
	WSDATA GWM_VLFRET 			As Float
	WSDATA GWM_VLINA1 			As Float
	WSDATA GWM_VLINE1 			As Float
	WSDATA GWM_VLIRR1 			As Float
	WSDATA GWM_VLSES1 			As Float
	WSDATA GWM_VLISS1 			As Float
	WSDATA GWM_VLICM1 			As Float
	WSDATA GWM_VLPIS1 			As Float
	WSDATA GWM_VLCOF1 			As Float
	WSDATA GWM_VLFRE1 			As Float
	WSDATA GWM_VLINA2 			As Float
	WSDATA GWM_VLINE2 			As Float
	WSDATA GWM_VLIRR2 			As Float
	WSDATA GWM_VLSES2 			As Float
	WSDATA GWM_VLISS2 			As Float
	WSDATA GWM_VLICM2 			As Float
	WSDATA GWM_VLPIS2 			As Float
	WSDATA GWM_VLCOF2 			As Float
	WSDATA GWM_VLFRE2 			As Float
	WSDATA GWM_VLINA3 			As Float
	WSDATA GWM_VLINE3 			As Float
	WSDATA GWM_VLIRR3 			As Float
	WSDATA GWM_VLSES3 			As Float
	WSDATA GWM_VLISS3 			As Float
	WSDATA GWM_VLICM3 			As Float
	WSDATA GWM_VLPIS3 			As Float
	WSDATA GWM_VLCOF3 			As Float
	WSDATA GWM_VLFRE3 			As Float
	WSDATA GWM_PEDAG 			As Float
	WSDATA GWM_PEDAG1			As Float
	WSDATA GWM_PEDAG2			As Float
	WSDATA GWM_PEDAG3			As Float
	WSDATA GWM_PCRAT  			As Float
	WSDATA OPERACAO    			As String Optional
	WSDATA CAMPOS_ESPEC			As Array of EstrutRetCamposEspec Optional
ENDWSSTRUCT
WSSTRUCT RetGWM
	WSDATA aRegistros			As Array of EstrutRetGWM Optional
ENDWSSTRUCT

WSMETHOD GetFreteGFE WSRECEIVE INCAMPO, INVALOR, INOPCAO, INCPOADIC, INLogin WSSEND RetGWM WSSERVICE WSSIM3G_CADASTROS

Local cSql := ""
Local nIdx := 1
Local cAliasQry	:= GetNextAlias()
Local cFiltro	:= ""
Local cFiltroPE	:= ""
Local cFilDel	:= ""
Local cCpoExpo	:= ""
Local aCpoAdic	:= {}
Local aCpoEspec	:= {}
Local lOpcFull	:= .F.
Local i
Local oReg

//-----------------------+
// Abre empresa / filial |
//-----------------------+
RPCSetType(3)  // Não consome licença.
RPCSetEnv("01", "05", Nil, Nil, "FRT")

cFiltro		:= U_X011A01("PARSESQL",INCAMPO,INVALOR)	// Filtro via parâmetro do GET
cFiltroPE	:= U_X011A01("FILSQL","GetFreteGFE")		// Filtro via ponto de entrada
cFilDel		:= U_X011A01("FILDEL","GWM",INOPCAO)		// Filtra registros DELETADOS ou NAO DELETADOS
cCpoExpo	:= U_X011A01("CMPEXP","GWM",INOPCAO)		// Campo de registro Exportado (S/N) via TRIGGER
aCpoAdic	:= U_X011A01("PARSECPO",INCPOADIC)			// Campos adicionais via parâmetro do GET
lOpcFull	:= ("FULL" $ Upper(Alltrim(INOPCAO)))

U_X011A01("CONSOLE","Exportacao SIM3G: GetFreteGFE "+ INOPCAO)

If ! U_X011A01("LOGIN",INLogin)
	Return .F.
Endif

cSql := "SELECT GWM.R_E_C_N_O_, GWM.D_E_L_E_T_ DELET "
cSql += "FROM "+ RetSqlName("GWM") + " GWM "
cSql += "WHERE 1=1 "
If !Empty(cFiltro)
	cSql += " AND "+ cFiltro +" "
Endif
If !Empty(cFiltroPE)
	cSql += " AND "+ cFiltroPE +" "
Endif
If !Empty(cFilDel)
	cSql += " AND "+ cFilDel +" "
Endif
If !Empty(cCpoExpo) .and. !lOpcFull		// Controle de registros Exportados (S/N) via TRIGGER
	cSql += " AND ("+ cCpoExpo +" <> 'S') "
Endif
cSql := ChangeQuery(cSql)

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)
Begin Transaction

While ! (cAliasQry)->(Eof())
	dbSelectArea("GWM")
	dbGoTo( (cAliasQry)->R_E_C_N_O_ )
	oReg := WSClassNew("EstrutRetGWM")
	oReg:GWM_FILIAL	 	:= GWM->GWM_FILIAL
	oReg:GWM_TPDOC    	:= GWM->GWM_TPDOC
	oReg:GWM_CDESP 		:= GWM->GWM_CDESP
	oReg:GWM_CDTRP   	:= GWM->GWM_CDTRP
	oReg:GWM_DSTRP  	:= U_X011A01("CP1252", POSICIONE("GU3",1,XFILIAL("GU3")+GWM->GWM_CDTRP,"GU3_NMEMIT"))
	oReg:GWM_SERDOC  	:= GWM->GWM_SERDOC
	oReg:GWM_NRDOC  	:= GWM->GWM_NRDOC
	oReg:GWM_DTEMIS  	:= GWM->GWM_DTEMIS
	oReg:GWM_CDTPDC  	:= GWM->GWM_CDTPDC
	oReg:GWM_DSTPDC  	:= U_X011A01("CP1252", POSICIONE("GV5",1,XFILIAL("GV5")+GWM->GWM_CDTPDC,"GV5_DSTPDC"))
	oReg:GWM_EMISDC  	:= GWM->GWM_EMISDC
	oReg:GWM_NMEMIT 	:= U_X011A01("CP1252", POSICIONE("GU3",1,XFILIAL("GU3")+GWM->GWM_EMISDC,"GU3_NMEMIT"))
	oReg:GWM_SERDC   	:= GWM->GWM_SERDC
	oReg:GWM_NRDC   	:= GWM->GWM_NRDC
	oReg:GWM_GRPCTB 	:= GWM->GWM_GRPCTB
	oReg:GWM_SEQGW8 	:= GWM->GWM_SEQGW8
	oReg:GWM_DTEMDC  	:= GWM->GWM_DTEMDC
	oReg:GWM_ITEM   	:= GWM->GWM_ITEM
	oReg:GWM_DSITEM   	:= U_X011A01("CP1252", POSICIONE("GW8",1,GWM->GWM_FILIAL+GWM->GWM_CDTPDC+GWM->GWM_EMISDC+GWM->GWM_SERDC+GWM->GWM_NRDC+GWM->GWM_ITEM+GWM->GWM_UNINEG,"GW8_DSITEM"))
	oReg:GWM_UNINEG 	:= GWM->GWM_UNINEG
	oReg:GWM_VLINAU 	:= GWM->GWM_VLINAU
	oReg:GWM_VLINEM 	:= GWM->GWM_VLINEM
	oReg:GWM_VLIRRF 	:= GWM->GWM_VLIRRF
	oReg:GWM_VLSEST 	:= GWM->GWM_VLSEST
	oReg:GWM_VLISS  	:= GWM->GWM_VLISS 
	oReg:GWM_VLICMS 	:= GWM->GWM_VLICMS
	oReg:GWM_VLPIS  	:= GWM->GWM_VLPIS 
	oReg:GWM_VLCOFI 	:= GWM->GWM_VLCOFI
	oReg:GWM_VLFRET 	:= GWM->GWM_VLFRET
	oReg:GWM_VLINA1 	:= GWM->GWM_VLINA1
	oReg:GWM_VLINE1 	:= GWM->GWM_VLINE1
	oReg:GWM_VLIRR1 	:= GWM->GWM_VLIRR1
	oReg:GWM_VLSES1 	:= GWM->GWM_VLSES1
	oReg:GWM_VLISS1 	:= GWM->GWM_VLISS1
	oReg:GWM_VLICM1 	:= GWM->GWM_VLICM1
	oReg:GWM_VLPIS1 	:= GWM->GWM_VLPIS1
	oReg:GWM_VLCOF1 	:= GWM->GWM_VLCOF1
	oReg:GWM_VLFRE1 	:= GWM->GWM_VLFRE1
	oReg:GWM_VLINA2 	:= GWM->GWM_VLINA2
	oReg:GWM_VLINE2 	:= GWM->GWM_VLINE2
	oReg:GWM_VLIRR2 	:= GWM->GWM_VLIRR2
	oReg:GWM_VLSES2 	:= GWM->GWM_VLSES2
	oReg:GWM_VLISS2 	:= GWM->GWM_VLISS2
	oReg:GWM_VLICM2 	:= GWM->GWM_VLICM2
	oReg:GWM_VLPIS2 	:= GWM->GWM_VLPIS2
	oReg:GWM_VLCOF2 	:= GWM->GWM_VLCOF2
	oReg:GWM_VLFRE2 	:= GWM->GWM_VLFRE2
	oReg:GWM_VLINA3 	:= GWM->GWM_VLINA3
	oReg:GWM_VLINE3 	:= GWM->GWM_VLINE3
	oReg:GWM_VLIRR3 	:= GWM->GWM_VLIRR3
	oReg:GWM_VLSES3 	:= GWM->GWM_VLSES3
	oReg:GWM_VLISS3 	:= GWM->GWM_VLISS3
	oReg:GWM_VLICM3 	:= GWM->GWM_VLICM3
	oReg:GWM_VLPIS3 	:= GWM->GWM_VLPIS3
	oReg:GWM_VLCOF3 	:= GWM->GWM_VLCOF3
	oReg:GWM_VLFRE3 	:= GWM->GWM_VLFRE3
	oReg:GWM_PEDAG 		:= GWM->GWM_PEDAG
	oReg:GWM_PEDAG1		:= GWM->GWM_PEDAG1
	oReg:GWM_PEDAG2		:= GWM->GWM_PEDAG2
	oReg:GWM_PEDAG3		:= GWM->GWM_PEDAG3
	oReg:GWM_PCRAT  	:= GWM->GWM_PCRAT
	oReg:OPERACAO  		:= IF((cAliasQry)->DELET == '*',"D","")
	oReg:CAMPOS_ESPEC	:= {}
	
	// Ponto de Entrada para campos específicos (array)
	aCpoEspec := U_X011A01("CMPESPEC","GetFreteGFE")
	
	// Campos específicos via parâmetro de entrada
	aCpoEspec := U_X011A01("CPOADIC",aCpoEspec,aCpoAdic)
	
	// Tratativa para campos específicos (customizados)
	For i := 1 to Len(aCpoEspec)
		If Substr(Upper(Alltrim( aCpoEspec[i][1] )),1,3) == "GWM"
			AADD(oReg:CAMPOS_ESPEC,WSClassNew("EstrutRetCamposEspec"))
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:CAMPO := aCpoEspec[i][1]
			oReg:CAMPOS_ESPEC[ Len(oReg:CAMPOS_ESPEC) ]:VALOR := aCpoEspec[i][2]
		Endif
	Next i
	
	// Ponto de entrada que permite manipular o objeto XML do registro atual
	U_X011A01("PES011A6", "GetFreteGFE", oReg);
	
	nIdx++
	AADD(Self:RetGWM:aRegistros, oReg)
	U_X011A01("UPDEXP","GWM", cCpoExpo, (cAliasQry)->R_E_C_N_O_ )
	(cAliasQry)->(DbSkip())
EndDo
U_X011A01("CONSOLE",Alltrim(Str(nIdx-1)) +" Registro(s)")

End Transaction
(cAliasQry)->(DbCloseArea())

//-------------------+
// Finaliza Ambiente |
//-------------------+
RpcClearEnv()

RETURN .T.

