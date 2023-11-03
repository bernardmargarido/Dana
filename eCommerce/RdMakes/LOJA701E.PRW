#INCLUDE "LOJA701E.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

#DEFINE IT_MARCADO		1    // Selecionado .T. ou .F.
#DEFINE IT_NITEM		2    // Numero do Item
#DEFINE IT_DESCR		3    // Descricao do Item
#DEFINE IT_DTENTR		4    // Data da Entrada
#DEFINE IT_TURNO 		5    // Turno de Entrega
#DEFINE IT_CONTATO		6    // Contato da Entrega
#DEFINE CRLF					CHR(10)+CHR(13)

Static lAmbOff		:= .F.	//Verifica se o ambiente esta em off-line
Static lLjVfe		:= SuperGetMV("MV_LJVFE",,.F.)//#VFE Verifica se a rotina de Venda fora do estado esta ativa
Static cLojRes		:= '' 	//#VFE Guarda a loja mais proxima do cliente para solicitar a reserva
Static lVfe			:= .F.	//#VFE Verifica se o produto e VFE ou nao
Static aLockReserv	:= {}	// Array com o codigo de Lock de arquivo de reserva
Static nTamX3Prod	:= TamSx3("LR_PRODUTO")[1]

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJ7BtnRes ºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua o processamento da reserva ou de consulta das reser- º±±
±±º          ³vas                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void LJ7BtnRes( ExpN1 )                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Tipo da Operacao                                    º±±
±±º          ³        1 - Reserva                                         º±±
±±º          ³        2 - Consulta de reserva                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7BtnRes( nOpcx )
Local aLojas		:= {}						// Contem a relacao de lojas que permitem reserva
Local aProdutos 	:= {}						// Contem a relacao de produtos para a rotina de reservas
Local aReserva		:= {}						// Contem as reservas efetuadas
Local aItens 		:= {}						// Array para pegar o resultado do P.E.LJ7008
Local nX			:= 0						// Variavel auxiliar
Local nPos			:= 0 						// Variavel auxiliar
Local nPosItem		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]		// Posicao do numero do item
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do codigo do produto
Local nPosDescri	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_DESCRI"})][2]	// Posicao da Descricao do produto
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]	// Posicao da Quantidade
Local nPosDtReserva	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_RESERVA"})  	  		// Posicao do codigo da reserva
Local nPosDtLojaRes	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOJARES"})	  		// Posicao do codigo da reserva
Local nPosDtFilRes 	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_FILRES"})				// Posicao do codigo da filial da empresa da reserva
Local nPosDtLocal  	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOCAL"})				// Posicao do local (armazem)
Local nPosDtTes		:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_TES"})				// Posicao do Codigo do TES
Local nPosMesRec	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_MESREC"})				// Posicao do numero do recno da tabela MES
Local nPosEntr		:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ENTREGA"})				// Posicao do Tipo de Entrega
Local cCliPad		:= Padr(GetMv("MV_CLIPAD"),TamSx3("A1_COD")[1])
Local cLojaPad		:= GetMv("MV_LOJAPAD")
Local cMsg 			:= ""
Local lContinua 	:= .F.
Local lProdRes		:= .F.
Local lLj7008 		:= ExistBlock("LJ7008")
Local lLj7025		:= ExistBlock("LJ7025") 
Local lLj7025T  	:= ExistTemplate("LJ7025")
Local aLj7025		:= {}  	// Retorno do P.E. LJ7025
Local nPosDel		:= Len(aHeader) + 1															//Posicao que determina se o item foi deletado
Local lPedVen		:= .T.																		//Verifica se pode utilizar emissao de Pedidos de Venda
Local lVassConc 	:=	SuperGetMV("MV_LJVACC",,.F.)  											//Indica se a venda e concomitante.
Local nPosLote		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOTECTL" })				// Posicao do Campo de Lote
Local nPosSubL		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NLOTE" })				// Posicao do Sub Lote
Local nPosEndL		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOCALIZ" })				// Posicao do Endereco
Local nPosNSer		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NSERIE" })				// Posicao do Numero de Serie
Local nPosOrcam		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_ORCRES" })				// Posicao do Orcamento da Reserva
Local nPosPedido	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_PEDRES" })				// Posicao do Pedido de Venda da Reserva
Local nPosDtEntr	:= aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_FDTENTR"})				// Posicao do Campo Data Entrega
Local nPosCodCon	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_CODCONT"})				// Posicao do Campo Codigo Contato
Local lFdtEntr		:= (nPosDtEntr > 0)															// Verifica se o Campo Existe
Local lCodCont		:= (nPosCodCon > 0)															// Verifica se o Campo Existe
Local cTpQuebra		:= SuperGetMV("MV_LJTPPED", NIL, "1")										// Define o Tipo de Quebra para os Pedidos de Venda:
Local cQuebra		:= ""																		// Chave para Quebra na geracao dos Orcamentos Filho / Pedidos de Venda
Local cProduto		:= ""																		// Codigo do Produto
Local aInfCli		:= {}																		// Array com as Informacoes do Cliente
Local lReserva		:= .T.																		// Determina se deve efetuar a Reserva
Local oEstoque		:= NIL																		// Objeto de Controle de Estoque e Reservas
Local lRet			:= .T.   																	// Indica se Produto configurado com Enderecamento foi enderecado
Local aProdSemEnd	:= {}
Local lCentPDV		:= LjGetCPDV()[1]			 												// Central de PDV 

Local lFTVD7008 	:= ExistBlock("FTVD7008")
Local lFTVD7025		:= ExistBlock("FTVD7025") 
Local lFTVD7025T  	:= ExistTemplate("FTVD7025")
Local aFTVD7025		:= {}  																		// Retorno do P.E. FTVD7025
Local nPosCliEnt	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_CLIENT"})				// Posicao do Campo Codigo do Cliente de entrega
Local nPosFilCliEnt	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_CLILOJA"})				// Posicao do Campo Codigo da Filial do Cliente de entrega
Local nPosaProdut	:= 0																		// Linha do array aProdutos que se refere ao item do aCols
local cMsg2			:= " "																		// Mensagem de validação de estoque na reserva de produtos
Local cMvLjGerSC	:= cValToChar( SuperGetMV("MV_LJGERSC",,1) )								//valor do parametro MV_LJGERSC
Local lReturn 		:= .T. 																		//Retorno da funcao
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= ExistFunc("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local aItemNRes  	:= {} // Itens não reservados por utilizar TES que não controla estoque
Local lTESAtuEst 	:= .T.
Local lIntegDef	 	:= Lj701GtInD() //Venda Origem Integração
Local cMsgPdSRes	:= ""																		//Guarda  a mensagem dos pedidos que serão9 gerados
Local nPosFilRes	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_FILRES"})				//Posição da Filial selecionada para reserva
Local cLJRESER 		:= SuperGetMV("MV_LJRESER ",,"1") 											//Controla como será realizada a reserva de produtos da venda. 1=Ao pressionar o botão F11; 2=Na gravação do orçamento; 3=Na gravação da venda.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao executa rotina de reserva quando for Protheus Start   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __lPyme
	Aviso(STR0008, STR0057, {STR0009}) // "Atenção", "Rotina não disponível para o Protheus Start." , "Ok"
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao executa reserva, se houver selecao de 'Entrega'   ³
//³e alguma condicao impeca a utilizacao desta opcao.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 1
	If Ascan(aCols, {|x| !x[nPosDel] .AND. x[nPosEntr] == "3" }) > 0 .AND. !LjPedVen()
    	lPedVen := .F.
		lReturn := .F.
 	EndIf
EndIf

If lPedVen .AND. Ascan(aCols, {|x| !x[nPosDel] .AND. x[nPosEntr] $ "1|3|4" }) > 0 .AND. ( !ExistBlock("SCRPED") .AND. !ExistFunc("LJSCRPED") )
	MsgInfo(STR0095,STR0008) //"O rdmake SCRPED.PRW não está compilado e não será possível continuar a reserva e finalizar a venda. Somente Venda 'Retira' será possível fazer!"#Atenção
	lPedVen := .F.
	lReturn := .F.	
EndIf

If lPedVen .AND. !lAmbOff
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para tratamento do código e descricao do produto             ³
	//³ Retorno a posicao da aCols que contem o codigo e a descricao do produto       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLJ7025T .AND. !lFtvdVer12
		aLJ7025 := ExecTemplate("LJ7025",.F.,.F.,{nPosProd,nPosDescri} )
		If ValType(aLJ7025) == "A" .And. Len(aLJ7025) >= 2
			nPosProd	:= aLJ7025[1]
			nPosDescri	:= aLJ7025[2]
		Endif
	Endif
	
	If lFTVD7025T .AND. lFtvdVer12
		aFTVD7025 := ExecTemplate("FTVD7025",.F.,.F.,{nPosProd,nPosDescri} )
		If ValType(aFTVD7025) == "A" .And. Len(aFTVD7025) >= 2
			nPosProd	:= aFTVD7025[1]
			nPosDescri	:= aFTVD7025[2]
		Endif
	Endif
	
	If lLJ7025 .AND. !lFtvdVer12
		aLJ7025 := ExecBlock("LJ7025",.F.,.F.,{nPosProd,nPosDescri} )
		If ValType(aLJ7025) == "A" .And. Len(aLJ7025) >= 2
			nPosProd	:= aLJ7025[1]
			nPosDescri	:= aLJ7025[2]
		Endif
	EndIf
	
	If lFTVD7025 .AND. lFtvdVer12
		aFTVD7025 := ExecBlock("FTVD7025",.F.,.F.,{nPosProd,nPosDescri} )
		If ValType(aFTVD7025) == "A" .And. Len(aFTVD7025) >= 2
			nPosProd	:= aFTVD7025[1]
			nPosDescri	:= aFTVD7025[2]
		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do array aLojas                                                ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³[1] - .T. ou .F.                                                          ³
	//³[2] - Codigo da loja (LJ_CODIGO)                                          ³
	//³[3] - Nome da loja (LJ_NOME)                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do array aProdutos                                             ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³[1] - .T. ou .F.                                                          ³
	//³[2] - Item do produto na aCols                                            ³
	//³[3] - Codigo do Produto                                                   ³
	//³[4] - Descricao                                                           ³
	//³[5] - Quantidade                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do array aReserva                                              ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³[1] - Item do produto na aCols                                            ³
	//³[2] - Codigo do produto                                                   ³
	//³[3] - Quantidade reservada                                                ³
	//³[4] - Codigo da Loja                                                      ³
	//³[5] - Codigo da reserva                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desabilita as teclas de atalho                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite efetuar reservas para o cliente padrão                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If Alltrim(M->LQ_CLIENTE) + Alltrim(M->LQ_LOJA) == Alltrim(cCliPad) + Alltrim(cLojaPad)
	
		cMsg := STR0006 //"Não é permitido efetuar reservas para o cliente padrão."
		IF nOpcx == 2
			cMsg := cMsg + STR0007 //" Escolha outro cliente para consulta."
		Endif
	
		Aviso( STR0008, cMsg, {STR0009} )  //"Atenção"###"Ok"
		
	ElseIf Len(aColsDet) < n .AND. !aTail(aCols[n])
		MsgStop(STR0080) // Para realizar reserva e necessario o lancamento do Produto!		
	Else 
	
		//#VFE
		//Se o estiver utilizando VFE e o produto for do tipo 3
		//entao não utiliza a SLJ mas sim, a DB5 (matriz de abastecimento)
		lLjVfe := lLjVfe .AND. aCols[n][nPosEntr] == "3"   
		If !lLjVfe
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Varre o cadastro de lojas (SLJ) e monta um array de pesquisa             ³
			//³ So ira checar as lojas que permitirem reservas (LJ_RESERVA = 1)          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SLJ")
			dbSetOrder(2)	// filial + nome + codigo
			dbSeek(xFilial("SLJ"))
			While !Eof() .And. SLJ->LJ_FILIAL == xFilial("SLJ")
				If SLJ->LJ_RESERVA == "1"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Verifica se a empresa eh a mesma que a empresa local |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SM0->M0_CODIGO == SLJ->LJ_RPCEMP
						aAdd( aLojas, { .F., SLJ->LJ_CODIGO, SLJ->LJ_NOME } )
					EndIf
				Endif
				dbSkip()
			End
		Else
			
			//#VFE
			aLojas := Lj7LoadShop()
									
		EndIf
		
		If !Empty( aLojas )
			
			If nOpcx == 1	// Reserva
				If lVassConc
					Aviso( STR0008, STR0056, {STR0009} )  //"Atenção"## "Nao e permitido efetuar reserva quando a venda e concomitante" #"Ok"
     			Else
					aItens := {}
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Chama o ponto de entrada LJ7008 para checar quais os produtos da acols   ³
					//³ deverao aparecer para fazer a reserva.                                   ³
					//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
					//³ Ponto de entrada: LJ7008                                                 ³
					//³ Parametros: Nenhum                                                       ³
					//³ Retorno: Array com o numero do item na aCols que devera aparecer para o  ³
					//³          usuario escolher se faz a reserva.                              ³
					//³          Exemplo: { "01","03","04" }                                     ³
					//³          Ira incluir na consulta os itens 01, 03 e 04.                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLj7008 .AND. !lFtvdVer12
						aItens := ExecBlock("LJ7008",.F.,.F.)
						If ValType(aItens) <> "A"
							aItens := {}
						Endif
					Endif
				
					If lFTVD7008 .AND. lFtvdVer12
						aItens := ExecBlock("FTVD7008",.F.,.F.)
						If ValType(aItens) <> "A"
							aItens := {}
						Endif
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Varre o aCols e monta array com os produtos do acols, mas verifica se    ³
					//³ ainda nao foram reservados                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ((lLJ7025T .or. lLJ7025) .AND. !lFtvdVer12) .OR. ((lFTVD7025T .or. lFTVD7025) .AND. lFtvdVer12) // Se utilizar o TPL - Optica
						For nX := 1 to Len(aCols)
							If !aCols[nX][Len(aCols[nX])]
								If !Empty(aColsDet[nX][nPosProd]) .And. Empty(aColsDet[nX][nPosDtReserva])
									If !lLj7008 .AND. !lFtvdVer12
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//| Se nao existe o ponto de entrada LJ7008 somente checa se o produto movimenta estoque    |
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										lProdRes := .T.
									ElseIf !lFtvdVer12
										lProdRes := (aScan( aItens, aCols[nX][nPosItem] ) > 0)
									Endif

									If !lFTVD7008 .AND. lFtvdVer12
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//| Se nao existe o ponto de entrada FTVD7008 somente checa se o produto movimenta estoque    |
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										lProdRes := .T.
									ElseIf lFtvdVer12
										lProdRes := (aScan( aItens, aCols[nX][nPosItem] ) > 0)
									Endif
									
									If lProdRes
										aAdd( aProdutos, { .F., aCols[nX][nPosItem], aColsDet[nX][nPosProd], aCols[nX][nPosDescri], aCols[nX][nPosQuant],aCols[nX][nPosEntr] } )
									Endif
								Endif
							Endif
						Next nX
			
						If !Empty( aProdutos )
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Faz a reserva dos produtos 												 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aReserva := Lj7Reserva( aLojas, aProdutos )
							lContinua := !Empty(aReserva)
							lReturn	  := lContinua
						Else
							If ( Len(aCols) <= 1 ) .And. ( aTail( aCols[1] ) .Or. Empty(aColsDet[1][nPosProd]) )
								Aviso( STR0008, STR0010, {STR0009} ) //"Atenção"###"Não há produtos para reservar."###"Ok"
							Else
								Aviso( STR0008, STR0011, {STR0009} ) //"Atenção"###"Os produtos atuais estão reservados."###"Ok"
							EndIf
						Endif
					Else // Padrao
						For nX := 1 to Len(aCols)
							//#VFE
	  						If lLjVfe
	  							nX := Val(aCols[n][nPosItem])
	  						EndIf 
							If !aCols[nX][Len(aCols[nX])]
								If !Empty(aCols[nX][nPosProd]) .And. ((Empty(aColsDet[nX][nPosDtReserva]) .AND. aCols[nX][nPosEntr] <> "5") .OR.;
									(Empty(aColsDet[nX][aPosCpoDet[nPosFilRes][2]]) .AND. aCols[nX][nPosEntr] == "5") .OR.;
									(!Empty(aColsDet[nX][aPosCpoDet[nPosFilRes][2]]) .AND. aCols[nX][nPosEntr] == "5") .AND. cLJRESER == "3")
																																			  
									If !lLj7008 .AND. !lFtvdVer12
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//|Se nao existe o ponto de entrada LJ7008 somente checa se o produto movimenta estoque |
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										lProdRes := (Posicione("SF4",1,xFilial("SF4")+aColsDet[nX][nPosDtTes],"SF4->F4_ESTOQUE") == "S") .OR.;
													(Posicione("SF4",1,xFilial("SF4")+aColsDet[nX][nPosDtTes],"SF4->F4_ESTOQUE") == "N") .AND. aCols[nX][nPosEntr] == "5"

										lTESAtuEst := lProdRes
									ElseIf !lFtvdVer12
										lProdRes := (aScan( aItens, aCols[nX][nPosItem] ) > 0)
									Endif
									
									If !lTESAtuEst
									   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//|Se o TES não atualiza estoque  |
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									   Aadd( aItemNRes, { aCols[nX][nPosItem], aCols[nX][nPosProd], aCols[nX][nPosDescri] })
									EndIf									
									
									If !lFTVD7008 .AND. lFtvdVer12
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//| Se nao existe o ponto de entrada FTVD7008 somente checa se o produto movimenta estoque    |
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										lProdRes := (Posicione("SF4",1,xFilial("SF4")+aColsDet[nX][nPosDtTes],"SF4->F4_ESTOQUE") == "S")
									ElseIf lFtvdVer12
										lProdRes := (aScan( aItens, aCols[nX][nPosItem] ) > 0)
									Endif

									If lProdRes
										//#VFE
										//Se for VFE ja incluio o produto como selecionado
										aAdd( aProdutos, { IIF(lLjVfe,.T.,.F.), aCols[nX][nPosItem], PadR(aCols[nX][nPosProd], nTamX3Prod), aCols[nX][nPosDescri], aCols[nX][nPosQuant],aCols[nX][nPosEntr] } )
                                                                                  
										// Procura no array aProdutos pelo item do aCols
										nPosaProdut := aScan( aProdutos, { |x| x[2] == aCols[nX][nPosItem] } )										
										
										// Verifica se Produto foi enderecado antes de fazer a reserva
										If !Lj7Serial(.F.,nX)
											Aadd(aProdSemEnd,aProdutos[nPosaProdut])
										EndIf																																
									Endif
									//#VFE
									//Se for VFE sai do FOR apos selecionar o produto
									If lLjVfe  
										Exit
									EndIf
								Else
									//#VFE
									//Se for VFE sai do FOR apos selecionar o produto
									If lLjVfe  
										Exit
									EndIf								
								Endif
							Else
								//#VFE
								//Se for VFE sai do FOR apos selecionar o produto
								If lLjVfe  
									Exit
								EndIf
							Endif
						Next nX
						
						If Len(aProdSemEnd) > 0
											   
							cMsg := STR0079 //"Para que o Produto seja Reservado corretamente, sera necessario preencher o campo Endereco na Tela de Detalhes dos Itens, tecla <F8> para os seguinte(s) Produto(s):"
						   	For nX = 1 to Len(aProdSemEnd)
								cMsg := cMsg + aProdSemEnd[nX][2] + " - " + Alltrim(aProdSemEnd[nX][3]) + " - " + aProdSemEnd[nX][4]
							Next nX
							
							MsgInfo( cMsg )
							cMsg := ''
							lRet := .F.
							lContinua := .F.
						Endif
						
						If Len(aItemNRes) > 0
													   
						   	cMsg := Chr(13)+Chr(10) + STR0091 + Chr(13)+Chr(10) +; // "Para que o Produto seja reservado é necessário utilizar um TES ( Tipo de Saída ) que atualize estoque."
						   	                          STR0092 //  "O(s) seguinte(s) itens estão utilizando um TES que não atualiza estoque:" 						   	
						   	For nX = 1 to Len(aItemNRes)
								cMsg += Chr(13)+Chr(10) + aItemNRes[nX][01] + " - " + aItemNRes[nX][02] + " - " + aItemNRes[nX][03]
							Next nX
							
							MsgInfo( cMsg )
						   cMsg := ''

						Endif	

						If !Empty( aProdutos )

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Faz a reserva dos produtos 												 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lRet
								aReserva := Lj7Reserva( aLojas, aProdutos )
								lContinua := !Empty(aReserva)
								
								If lIntegDef
									lReturn	  := .T. //Integracao Mensagem Unica retorna .T. pois nao faz reserva
								Else
									lReturn	  := lContinua
								EndIf
							Endif	
							
						Else
							If ( Len(aCols) <= 1 ) .And. ( aTail( aCols[1] ) .Or. Empty(aCols[1][nPosProd]) )
								Aviso( STR0008, STR0010, {STR0009} ) //"Atenção"###"Não há produtos para reservar."###"Ok"
							ElseIf Len(aProdutos) > 0
								cMSG := STR0093 + CHR(13)+CHR(10) // "Os seguintes produtos estão reservados: "
								For nX := 1 To Len(aProdutos)
								    cMSG += aProdutos[nX][nPosItem] + " - " + aProdutos[nX][nPosProd] + " - " + aProdutos[nX][nPosDescri] + CHR(13)+CHR(10)
								Next nX 
								MsgInfo( cMSG )
								cMSG := '' 
							EndIf
						Endif
					Endif
				EndIf
			Else
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a consulta das reservas												 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Lj7ConsRes( aLojas, M->LQ_CLIENTE, M->LQ_LOJA )
					
			Endif
						
	  	Else
	  		//#VFE
	  		If !lLjVfe
				Aviso( STR0008, STR0012,{STR0009} ) //"Atenção"###"Não foi encontrada nenhuma loja cadastrada que permita reserva. Verifique o cadastro de lojas (SLJ)."###"Ok"
			Else
				Aviso( STR0008,'Não existe estoque disponivel para o produto lançado!',{STR0009} )			
			EndIf
		Endif
			
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o tratamento dos dados da reserva                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg := ""
	cMsg2 := ""
	If lContinua .and. nOpcx == 1	// Reserva
		For nX := 1 to Len( aReserva )		
		    If (lLJ7025T .or. lLJ7025) .AND. !lFtvdVer12
			    nPos := aScan( aColsDet, { |x| x[1]+x[nPosProd] == aReserva[nX][1]+aReserva[nX][2] } )
			ElseIf (lFTVD7025T .or. lFTVD7025) .AND. lFtvdVer12
			    nPos := aScan( aColsDet, { |x| x[1]+x[nPosProd] == aReserva[nX][1]+aReserva[nX][2] } )
			Else
				nPos := aScan( aColsDet, { |x| x[1]+x[2] == aReserva[nX][1]+PadR(aReserva[nX][2], nTamX3Prod) } )
			Endif
			
			//Verifica se foi efetuado reserva do produto na SC0, quando entrega diferente de 5=Entrega c/ Pedido s/ Reserva
            If cMvLjGerSC == "1" .And. aCols[nPos][nPosEntr] <> "5"
				If !SC0->(DbSeek(Posicione("SLJ",1,xFilial("SLJ")+aReserva[nX][4],"LJ_RPCFIL")+aReserva[nX][5]+aReserva[nX][2]))
					cMsg2 := cMsg2 + Chr(10) + aReserva[nX][1] + "-" + aReserva[nX][2] + " " + Posicione("SB1",1,xFilial("SB1")+aReserva[nX][2],"SB1->B1_DESC")
					nPos := 0
				Endif
			EndIf

			If nPos > 0
				aColsDet[nPos][nPosDtLojaRes]	:= aReserva[nX][4]
				aColsDet[nPos][nPosDtReserva]	:= aReserva[nX][5]
				aColsDet[nPos][nPosDtFilRes]	:= Posicione("SLJ",1,xFilial("SLJ")+aReserva[nX][4],"LJ_RPCFIL")
				aColsDet[nPos][nPosDtLocal]	:= aReserva[nX][6]
				
				If lCentPDV .AND. nPosMesRec > 0 				
					aColsDet[nPos][nPOSMesRec]	:= aReserva[nX][7]				
				EndIf

				If aCols[nPos][nPosEntr] <> "5" 
					cMsg := cMsg + Chr(10) + aReserva[nX][1] + "-" + aReserva[nX][2] + " " + Posicione("SB1",1,xFilial("SB1")+aReserva[nX][2],"SB1->B1_DESC")
				Else	
					cMsgPdSRes := cMsgPdSRes + Chr(10) + aReserva[nX][1] + "-" + aReserva[nX][2] + " " + Posicione("SB1",1,xFilial("SB1")+aReserva[nX][2],"SB1->B1_DESC")
				EndIf
			Else
				Conout("01. LOJA701E - LJ7BTNRES: O array aColsDet nao foi atualizado com os dados da reserva.")
			Endif			
		Next nX
		
		If !Empty(cMsg2)
			If !IsBlind()
				If !ExistBlock("LJRESERV") //Ponto de Entrada utilizado para fazer a reserva sem a apresentacao da tela ao usuario para selecao. Caso o PE estaja sendo utilizado, nao pode exibir mensagem na tela.
					MsgStop( STR0034+cMsg2 ) //"Saldo insuficiente:"
				EndIf
			Else
				LjGrvLog("", STR0034+cMsg2 ) //"Saldo insuficiente:"

			EndIf
		EndIf
		
		If !Empty(cMsg) .OR. !Empty(cMsgPdSRes) 

			If !IsBlind()
				If !ExistBlock("LJRESERV")  //Ponto de Entrada utilizado para fazer a reserva sem a apresentacao da tela ao usuario para selecao. Caso o PE estaja sendo utilizado, nao pode exibir mensagem na tela.				
					If !Empty(cMsg)			
						MsgInfo( STR0016+cMsg ) //"Foram realizadas as reservas dos produtos:"
					EndIf	
					If !Empty(cMsgPdSRes)
						MsgInfo( STR0099 +cMsgPdSRes ) //"Serão gerados PEDIDOS SEM RESERVAS dos produtos: "
					EndIf
				EndIf	
			Else
				LjGrvLog("", STR0016+cMsg ) //"Foram realizadas as reservas dos produtos:"
				If !Empty(cMsgPdSRes)
					LjGrvLog("", "Serão gerados PEDIDOS SEM RESERVAS dos produtos: "+cMsgPdSRes ) 
				EndIf				
			EndIf
		EndIf
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso for pdvpaf faz por ws³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf lPedVen .AND. lAmbOff

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para tratamento do código e descricao do produto             ³
	//³ Retorno a posicao da aCols que contem o codigo e a descricao do produto       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLJ7025T
		aLJ7025 := ExecTemplate("LJ7025",.F.,.F.,{nPosProd,nPosDescri} )
		If ValType(aLJ7025) == "A" .And. Len(aLJ7025) >= 2
			nPosProd	:= aLJ7025[1]
			nPosDescri	:= aLJ7025[2]
		Endif
	Endif

	If lLJ7025
		aLJ7025 := ExecBlock("LJ7025",.F.,.F.,{nPosProd,nPosDescri} )
		If ValType(aLJ7025) == "A" .And. Len(aLJ7025) >= 2
			nPosProd	:= aLJ7025[1]
			nPosDescri	:= aLJ7025[2]
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do array aLojas                                                ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³[1] - .T. ou .F.                                                          ³
	//³[2] - Codigo da loja (LJ_CODIGO)                                          ³
	//³[3] - Nome da loja (LJ_NOME)                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do array aProdutos                                             ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³[1] - .T. ou .F.                                                          ³
	//³[2] - Item do produto na aCols                                            ³
	//³[3] - Codigo do Produto                                                   ³
	//³[4] - Descricao                                                           ³
	//³[5] - Quantidade                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do array aReserva                                              ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³[1] - Item do produto na aCols                                            ³
	//³[2] - Codigo do produto                                                   ³
	//³[3] - Quantidade reservada                                                ³
	//³[4] - Codigo da Loja                                                      ³
	//³[5] - Codigo da reserva                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desabilita as teclas de atalho                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite efetuar reservas para o cliente padrão                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(M->LQ_CLIENTE) + Alltrim(M->LQ_LOJA) == Alltrim(cCliPad) + Alltrim(cLojaPad)	
	
		cMsg := STR0006 //"Não é permitido efetuar reservas para o cliente padrão."
		IF nOpcx == 2
			cMsg := cMsg + STR0007 //" Escolha outro cliente para consulta."
		Endif
	
		Aviso( STR0008, cMsg, {STR0009} )  //"Atenção"###"Ok"
		
	Else 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Varre o cadastro de lojas (SLJ) e monta um array de pesquisa             ³
		//³ So ira checar as lojas que permitirem reservas (LJ_RESERVA = 1)          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SLJ")
		dbSetOrder(2)	// filial + nome + codigo
		dbSeek(xFilial("SLJ"))
		While !Eof() .And. SLJ->LJ_FILIAL == xFilial("SLJ")
			If SLJ->LJ_RESERVA == "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Verifica se a empresa eh a mesma que a empresa local |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SM0->M0_CODIGO == SLJ->LJ_RPCEMP
					aAdd( aLojas, { .F., SLJ->LJ_CODIGO, SLJ->LJ_NOME } )
				Endif
			Endif
			dbSkip()
		End
		If !Empty( aLojas )
			If nOpcx == 1	// Reserva
				If lVassConc
					Aviso( STR0008, STR0056, {STR0009} )  //"Atenção"## "Nao e permitido efetuar reserva quando a venda e concomitante" #"Ok"
     			Else
					aItens := {}
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Chama o ponto de entrada LJ7008 para checar quais os produtos da acols   ³
					//³ deverao aparecer para fazer a reserva.                                   ³
					//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
					//³ Ponto de entrada: LJ7008                                                 ³
					//³ Parametros: Nenhum                                                       ³
					//³ Retorno: Array com o numero do item na aCols que devera aparecer para o  ³
					//³          usuario escolher se faz a reserva.                              ³
					//³          Exemplo: { "01","03","04" }                                     ³
					//³          Ira incluir na consulta os itens 01, 03 e 04.                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLj7008
						aItens := ExecBlock("LJ7008",.F.,.F.)
						If ValType(aItens) <> "A"
							aItens := {}
						Endif
					Endif
		            
					For nX := 1 to Len(aCols)
						cProduto := ""
						If !aCols[nX][Len(aCols[nX])]
							If lLJ7025T .or. lLJ7025 // Se utilizar o TPL - Optica
								cProduto := aColsDet[nX][nPosProd]
							Else
								cProduto := aCols[nX][nPosProd]
							EndIf
							
							If !Empty(cProduto) .AND. Empty(aColsDet[nX][nPosDtReserva])
							
								If lLj7008
									lProdRes := (aScan(aItens, aCols[nX][nPosItem]) > 0)
								Else
									If lLJ7025T .OR. lLJ7025
										lProdRes := .T.
									Else
										lProdRes := (Posicione("SF4", 1, xFilial("SF4") + aColsDet[nX][nPosDtTes],"SF4->F4_ESTOQUE") == "S")
									EndIf
								EndIf
								//xxxxx
								If lProdRes
									//Tipo de Entrega
									cQuebra := ""
		
									If cTpQuebra == "2" .AND. lCodCont
										//Inclui o Codigo do Contato
										If (nPosCliEnt > 0) .AND. Empty(aColsDet[nX][nPosCliEnt])
											cQuebra	+= aColsDet[nX][nPosCodCon]
										Else
											If (nPosCliEnt > 0) //verifica se o campo existe
												cQuebra	+= aColsDet[nX][nPosCliEnt]
										    Endif
										 Endif   
									ElseIf cTpQuebra == "3" .AND. lFdtEntr
										//Inclui a Data de Entrega
										cQuebra	+= DtoS(aColsDet[nX][nPosDtEntr])
										
									ElseIf cTpQuebra == "4" .AND. lCodCont .AND. lFdtEntr
										//Inclui o Codigo do Contato + Data de Entrega
										cQuebra	+= aColsDet[nX][nPosCodCon] + DtoS(aColsDet[nX][nPosDtEntr])
										
									EndIf
															
									If (nPosFilCliEnt > 0)// verifica se o campo existe
										Aadd(aProdutos, {	cProduto				,;		//01 - Codigo do Produto
														aColsDet[nX][nPosDtLocal]	,;		//02 - Armazem
														aCols[nX][nPosQuant]		,;		//03 - Quantidade
														aCols[nX][nPosItem]			,;		//04 - Item da Venda
														aCols[nX][nPosDescri]		,;		//05 - Descricao
														aColsDet[nX][nPosLote]		,;		//06 - Lote
														aColsDet[nX][nPosSubL]		,;		//07 - Sub Lote
														aColsDet[nX][nPosEndL]		,;		//08 - Endereco
														aColsDet[nX][nPosNSer]		,;		//09 - Numero Serie
														aCols[nX][nPosEntr]			,;	  	//10 - Tipo de Entrega
														cQuebra						,;		//11 - Chave para Quebra na Geracao dos Orcamentos Filho / Pedidos de Venda
													    aColsDet[nX][nPosFilCliEnt] })      //12 - Filial do cliente de entrega
									Else

										Aadd(aProdutos, {	cProduto				,;		//01 - Codigo do Produto
														aColsDet[nX][nPosDtLocal]	,;		//02 - Armazem
														aCols[nX][nPosQuant]		,;		//03 - Quantidade
														aCols[nX][nPosItem]			,;		//04 - Item da Venda
														aCols[nX][nPosDescri]		,;		//05 - Descricao
														aColsDet[nX][nPosLote]		,;		//06 - Lote
														aColsDet[nX][nPosSubL]		,;		//07 - Sub Lote
														aColsDet[nX][nPosEndL]		,;		//08 - Endereco
														aColsDet[nX][nPosNSer]		,;		//09 - Numero Serie
														aCols[nX][nPosEntr]			,;		//10 - Tipo de Entrega
														cQuebra						})		//11 - Chave para Quebra na Geracao dos Orcamentos Filho / Pedidos de Venda
									EndIf   
								Endif	
							EndIf
						EndIf
					Next nX
		            
					If Empty(aProdutos)
						If (Len(aCols) <= 1) .AND. (aTail(aCols[1]))
							Aviso(STR0008, STR0010, {STR0009}) //"Atenção"###"Não há produtos para reservar."###"Ok"
						Else
							Aviso(STR0008, STR0011, {STR0009}) //"Atenção"###"Os produtos atuais estão reservados."###"Ok"
						EndIf
					Else
						lReserva := .T.
					Endif
					// xxx
					If lReserva
		    			aInfCli		:= {M->LQ_CLIENTE, M->LQ_LOJA, SA1->A1_CGC}
						
						//Instancia o Objeto
						oEstoque	:= LJCEstoque():New(.T., .T.)
						
						//Passa os Dados do Cliente
						If oEstoque:SetCliente(aInfCli)
			
							//Passa os Produtos para Reserva
							oEstoque:SetProd(aProdutos)
	
							//Recupera as Lojas no Cadastro de Lojas
							If oEstoque:SetLoja()
					
								//Seleciona as Lojas para Consulta
								If oEstoque:SelProdLoj()
					
									//Relaciona os Produtos x Lojas Selecionados
									oEstoque:SetConsult()
						
									//Consulta o Estoque
									oEstoque:ConsEst()
						
									//Mostra o Resultado da Consulta de Estoque
									If oEstoque:ShowEst()
										If oEstoque:ResProd()
											aRetRes := oEstoque:RetReserva()
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Faz o tratamento dos dados da reserva                                    ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											For nX := 1 to Len( aRetRes )
											    If lLJ7025T .or. lLJ7025
												    nPos := aScan(aColsDet,{|x| x[1] + x[nPosProd] == aRetRes[nX][1] + aRetRes[nX][2]})
												Else
													nPos := aScan(aColsDet, {|x| x[1] + x[2] == aRetRes[nX][1] + aRetRes[nX][2]})
												Endif
												If nPos > 0
													aColsDet[nPos][nPosDtLojaRes]	:= aRetRes[nX][08]
													aColsDet[nPos][nPosDtReserva]	:= aRetRes[nX][05]
													aColsDet[nPos][nPosDtFilRes]	:= aRetRes[nX][07]
													aColsDet[nPos][nPosDtLocal]		:= aRetRes[nX][04]
													aColsDet[nPos][nPosOrcam]		:= aRetRes[nX][09]
													If nPosPedido > 0
														aColsDet[nPos][nPosPedido]	:= aRetRes[nX][10]
													EndIf
												Endif
												cMsg := cMsg + CRLF + aRetRes[nX][08] + " - " + aRetRes[nX][2] + " " + aRetRes[nX][03]
											Next nX
											MsgInfo( STR0016+cMsg ) //"Foram realizadas as reservas dos produtos:"
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf 
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a consulta das reservas												 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   			aInfCli		:= {M->LQ_CLIENTE, M->LQ_LOJA, SA1->A1_CGC}
				
				//Instancia o Objeto
				oEstoque	:= LJCEstoque():New(.T., .F.)
				
				//Passa os Dados do Cliente
				If oEstoque:SetCliente(aInfCli)
					If oEstoque:SetLoja()
						If oEstoque:ConsRes()
							oEstoque:ShowRes()
						EndIf
					EndIf
				EndIf
			Endif			
		Endif
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita as teclas de atalho                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Lj7SetKeys(.T.)

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7ReservaºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a consulta e a reserva dos produtos e tambem cria os    º±±
±±º          ³orcamentos para a emissao da venda na outra loja            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1 := Lj7Reserva( aExpA2, aExpA3 )                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA2 - Array contendo:                                     º±±
±±º          ³        [1] - .F.                                           º±±
±±º          ³        [2] - Codigo da loja                                º±±
±±º          ³        [3] - Nome da loja                                  º±±
±±º          ³                                                            º±±
±±º          ³ExpA3 - Array contendo:                                     º±±
±±º          ³        [1] - .F.                                           º±±
±±º          ³        [2] - Item do produto na aCols                      º±±
±±º          ³        [3] - Codigo do produto                             º±±
±±º          ³        [4] - Descricao do produto                          º±±
±±º          ³        [5] - Quantidade                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array contendo:                                     º±±
±±º          ³        [1] - Item do produto na aCols                      º±±
±±º          ³        [2] - Codigo do produto                             º±±
±±º          ³        [3] - Quantidade reservada                          º±±
±±º          ³        [4] - Codigo da loja                                º±±
±±º          ³        [5] - Codigo da reserva                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Lj7BtnRes  (Loja701)                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7Reserva( aLojas, aProdutos, lECCia, dDtLimite, cFilRes )
Local aArea			:= Lj7GetArea({"SA1","SA2","SL1","SL2","SL4"})
Local aRet 			:= {}
Local aEstoque 		:= {}
Local aLocais 		:= {}
Local aSldEst		:= {}
Local aReserva 		:= {}
Local aCliente		:= {}
Local aLote			:= {}				// Array de Lotes de produtos  
Local nPosaCols		:= 0				// Posicao do Item no acols
Local nPosSublote	:= 0				// Posicao do subLote
Local nPosLote		:= 0				// Posicao do Lote
Local nPosEndereco	:= 0				// Posicao do Endereco
Local nPosNumSerie	:= 0				// Posicao do num de serie
Local lCentPDV		:= LjGetCPDV()[1]	// Central de PDV 
Local cReserva		:= ""				// Guarda numero da reserva
Local nRecnoMES		:= 0				// Numero recno da tabela de contingencia "MES"
Local cMsg 			:= ""
Local cArmazem 		:= ""
Local nX 			:= 0
Local nY 			:= 0
Local nZ 			:= 0
Local nCont 		:= 0
Local nQuant 		:= 0
Local nPos 			:= 0
Local lTodasLojas	:= .F.
Local lTodosProds	:= .F.
Local lContinua 	:= .F.
Local lReserva 		:= .F.
Local oOk 			:= LoadBitmap(GetResources(), "LBOK")
Local oNo 			:= LoadBitmap(GetResources(), "LBNO")
Local oWhite		:= LoadBitmap(GetResources(), "BR_BRANCO")
Local oDlgConsulta
Local oLojas
Local oTodasLojas
Local oProdutos
Local oTodosProds
Local oDlgEstoque
Local oEstoque
Local aLjSemArmazem := {}				// Array que contem as lojas sem armazem cadastrado
Local cLjSemArmazem := ""				// Variavel que contem as lojas sem armazem cadastrado ( Eh o label mostrado ao usuario )
Local nLjSemArmazem := 0				// Contador do for next para alimentacao e leitura da array
Local cLoteSubLote  := ""				// Lote e sublote, para verificar se a reserva com lote e sublote ja esta no array de reserva	 
Local lAutoExC 		:= IsBlind() .OR. !Empty(GetPvProfString( "TESTE", "PROD", "", GetADV97()))	// Robo
Local aLJRESERV		:= {}
Local lECommerce := SuperGetMV("MV_LJECOMM",,.F.) .And. LJ862ECAuto()
Local nPosItem		:= 0				// Posicao do numero do item
Local nPosEntr		:= 0				// Posicao do Tipo de Entrega
Local nPosLocal		:= 0				// Posição do Local(Armazém)
Local nPosEstoqu 	:= 0				//Guarda Item do array aEstoque
Local nPosSldEst	:= 0				//Compara o array aSldEst e guarda a posição do aColsDet

Local cProduto   	:= " " 				//Variavel que ira controlar se o produto ja teve o estoque selecionado.
Local aSB1			:= {}				//WorkArea da SB1
Local cItem			:= ""				//item Pedido
Local aNumRes		:=  {}				//itens das Reservas
Local cResTmp		:= ""				//Numero da Reserva
Local nPosRes		:= 0				//Posicao da REserva
Local aItAuto		:= {}				//quando execauto, possui itens do orçamento
Local aItReserv		:= {}				//guarda apenas itens que devem ser reservados
Local nPosLoj,nItPrdRes,nItPrdItem 
Local lIntegDef		:= Lj701GtInD()		//Venda Origem Integração
Local nPosLojaRes   := 0
Local lLojaNaoSel 	:= .T.				//Verifica se existe alguma loja selecionada na tela de Consulta Estoque/Identificação Loja 
Local lPedSemRes	:= .F.				//Guarda se o pedido é sem Reserva	
Local lAutomato 	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)  // Execução via Robô
Local cLojaEstq		:= ""				//Guarda a Loja corrente para utilizar no aScan do array aEstoque

Default lECCia := .F. 
Default dDtLimite := Date()
Default cFilRes := ""

If lECCia
	lECommerce := .F. //e-commerce ciashop não existe range de ceps nem loja nem acols, acolsdet
EndIf

If Type("aHeaderDet") == "A" //Proteção para execução via ExecAuto

	nPosSublote		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NLOTE"})					// Posicao do subLote
	nPosLote		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOTECTL"})				// Posicao do Lote
	nPosEndereco	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOCALIZ"})				// Posicao do Endereco
	nPosNumSerie	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NSERIE"})				// Posicao do num de serie
	nPosLojaRes	    := aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOJARES"})				// Posicao do num de serie

EndIf

If Type("aHeader") == "A" //Proteção para execução via ExecAuto
	nPosItem	:= Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_ITEM"})		// Posicao do numero do item no aCols
	nPosEntr	:= Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_ENTREGA"})	// Posicao do Tipo de Entrega	
	nPosLocal	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOCAL"})		// Posicao do Armazém	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela para o usuario selecionar os produtos/lojas para reserva      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aProdutos) .And.  !Empty(aLojas)
	If lAutoExc .AND. !lECCia .And. (Type("M->AUTRESERVA") == "C" .Or. lIntegDef)
		If !lIntegDef
			For nX := 1 To Len(aLojas)			
				If aLojas[nX][2] == M->AUTRESERVA
					aLojas[nX][1] := .T.                
					lContinua     := .T.
				EndIf			
			Next
			If !lContinua
				Final(STR0077) //"A Loja Informada para reserva não foi encontrada."
			EndIf

		EndIf         
		//Escolhe todos os produtos de acols
		For nX := 1 To Len(aProdutos)
			If !lECommerce .And. FunName() == "LOJA701" .And. nPosItem > 0 .And. !lIntegDef 
				nPosaCols := aScan( aCols, { |x| x[nPosItem] == aProdutos[nX][2] })
				If aCols[nPosaCols][nPosEntr] $ "3|4" //Somente seleciona para efetuar a reserva automatica se for (3=ENTREGA ou 4=Retira Posterior c/ Pedido)
					aProdutos[nX][1] := .T.
				EndIf
			Else
				aProdutos[nX][1] := .T.
				
				If lIntegDef
					nPosaCols := aScan( aCols, { |x| x[nPosItem] == aProdutos[nX][2] })					
					nPosLoja  := aScan( aLojas, { |x| x[2] == aColsDet[nPosaCols][nPosLojaRes] })
					
					If nPosLoja > 0
						aLojas[nPosLoja][1] := .T.                
						lContinua := .T.
					EndIf	
				EndIf
			EndIf
		Next	
	ElseIf lECCia
		lContinua := .T.
	ElseIf ExistBlock("LJRESERV") //Ponto de Entrada utilizado para fazer a reserva sem a apresentacao da tela ao usuario para selecao.
		aLJRESERV := ExecBlock("LJRESERV",.F.,.F., {"1", aLojas, aProdutos, aEstoque} )
		
		If aLJRESERV[1]
			lContinua := .T.
			
			//Atualiza o array aLojas, conforme opcoes selecionadas no Ponto de Entrada (Customizado)
			For nX:=1 To Len(aLojas)
				aLojas[nX][1] := aLJRESERV[2][nX][1]
			Next nX
			
			//Atualiza o array aProdutos, conforme opcoes selecionadas no Ponto de Entrada (Customizado)
			For nX:=1 To Len(aProdutos)
				aProdutos[nX][1] := aLJRESERV[3][nX][1]
			Next nX
		Else
			lContinua := .F.
		EndIf
	ElseIf IsBlind() .AND. ExistFunc("LjGetItens") //phsm tratamento ExecAuto(nao utilizei a variavel lAutoExC pois ela poderá retornar .T. se ambiente possuir configuração de robo de testes), nesse ponto irá auto selecionar os itens que serão reservados
		aItAuto := LjGetItens()	//retorna itens que foram enviados na ExecAuto
		 
		For nX:=1 To Len(aItAuto) //Percorre todos os itens e marca/check para os itens que possuem definição de reserva			
			If (nPosLoj :=  AScan( aItAuto[nX], { |x| x[1] == "LR_LOJARES"} )) > 0 .AND. ValType(aItAuto[nX][nPosLoj][2]) == "C" //Marca loja para reserva e consulta de estoque								
				If (nPosLoj :=  AScan( aLojas, { |x| x[2] == aItAuto[nX][nPosLoj][2]} )) > 0
					lContinua 			:= .T.  //Se existir ao menos 1 item, sinaliza que deve continuar com o processo da reserva
					aProdutos[nX][1] 	:= .T.						
					aLojas[nPosLoj][1] 	:= .T.					
					aAdd(aItReserv, aItAuto[nX])  //guarda itens que devem ser reservados
				Else
					nPosLoj :=  AScan( aItAuto[nX], { |x| x[1] == "LR_LOJARES"} )
					Conout("ExecAuto LOJA701 - Reserva de Produto não foi realizada. Motivo: Loja(LR_LOJARES):["+aItAuto[nX][nPosLoj][2]+"] não localizada no Protheus.")
					lContinua	:= .F.
					Exit						
				EndIf 						
			EndIf 							
		Next nX
	Else
		//#VFE
		//Quando for VFE nao abre a tela para reservar o produto
		If !lLjVfe
			DEFINE MSDIALOG oDlgConsulta TITLE STR0017 FROM 0,0 TO 300,490 PIXEL OF oDlgVA //"Consulta de Estoques / Identificação de lojas"
			
			@ 08,08 LISTBOX oLojas FIELDS HEADER "",STR0018 FIELDSIZES 14,130 SIZE 230,55 PIXEL FONT aFontes[3] OF oDlgConsulta //"Loja"
			oLojas:SetArray(aLojas)
			oLojas:bLDblClick := {|| (aLojas[oLojas:nAt,1] := !aLojas[oLojas:nAt,1]) }
			oLojas:bLine := {|| {If(aLojas[oLojas:nAt,1],oOk,oNo),aLojas[oLojas:nAt,3] }}
			
			@ 65,12 CHECKBOX oTodasLojas VAR lTodasLojas PROMPT STR0019 SIZE 53,8 PIXEL OF oDlgConsulta; //"Selecionar Todas"
			ON CHANGE {|| aEval(aLojas,{|x| x[1]:= lTodasLojas }),oLojas:Refresh() }
			
			@ 75,08 LISTBOX oProdutos FIELDS HEADER "",STR0020,STR0021,STR0022 FIELDSIZES 14,40,123,40 SIZE 230,55 PIXEL FONT aFontes[3] OF oDlgConsulta  //"Codigo"###"Descrição"###"Quant."
			oProdutos:SetArray(aProdutos)
			oProdutos:bLDblClick := {|| (aProdutos[oProdutos:nAt,1] := !aProdutos[oProdutos:nAt,1])}
			oProdutos:bLine := {|| {If(aProdutos[oProdutos:nAt,1],oOk,oNo),;
			aProdutos[oProdutos:nAt,3],aProdutos[oProdutos:nAt,4],;
			Transform(aProdutos[oProdutos:nAt,5],PesqPict("SL2","L2_QUANT")) }}
			
			@ 133,12 CHECKBOX oTodosProds VAR lTodosProds PROMPT STR0023 SIZE 53,8 PIXEL OF oDlgConsulta; //"Selecionar Todos"
			ON CHANGE {|| aEval(aProdutos,{|x| x[1]:= lTodosProds }),oProdutos:Refresh() }
			
			DEFINE SBUTTON FROM 133, 180 TYPE 1 ACTION (lContinua := .T. ,oDlgConsulta:End()) ENABLE PIXEL OF oDlgConsulta
			DEFINE SBUTTON FROM 133, 210 TYPE 2 ACTION oDlgConsulta:End() ENABLE PIXEL OF oDlgConsulta
			
			ACTIVATE MSDIALOG oDlgConsulta CENTERED
		Else 
			//#VFE
			//Se for VFE nao abre a tela para escolher a loja e o produto e incluir .T. para o lContinua
			lContinua := .T.
		EndIf
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa os arrays aLojas e aProdutos. Deixa so os que foram selecionados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCont := 0
//Proteção para execução via ExecAuto
If lAutoExC .And. Type("aHeader") == "A" .And. !ExistBlock("LJRESERV")
	For nX := Len(aLojas) to 1 Step -1
		If !aLojas[nX][1]
			aDel( aLojas, nX )
			nCont ++
		Endif
	Next nX
	aSize( aLojas, Len(aLojas)-nCont )
	
	nCont := 0
	For nX := Len(aProdutos) to 1 Step -1
		If !aProdutos[nX][1]
			aDel( aProdutos, nX )
			nCont ++
		Endif
	Next nX
	aSize( aProdutos, Len(aProdutos)-nCont )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi selecionada alguma loja ou produto para a pesquisa       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .And. aScan(aLojas,{ |x| x[1] }) == 0 .And. !ExistBlock("LJRESERV") 
		Aviso( STR0008, STR0024, {STR0009} ) //"Atenção"###"Não foi selecionada nenhuma loja para consulta"###"Ok"
		lContinua := .F.
	Endif
	If lContinua .And. aScan(aProdutos,{ |x| x[1] }) == 0 .And. !ExistBlock("LJRESERV") 
		Aviso( STR0008, STR0025, {STR0009} ) //"Atenção"###"Não foi selecionado nenhum produto para consulta"###"Ok"
		lContinua := .F.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aEstoque                                               ³
//³(Utilizada para mostrar os saldos dos estoques das outras lojas)          ³
//³                                                                          ³
//³aEstoque[1] - True ou False (para o ListBox)                              ³
//³aEstoque[2] - Codigo da Loja                                              ³
//³aEstoque[3] - Nome da Loja                                                ³
//³aEstoque[4] - Codigo do Produto                                           ³
//³aEstoque[5] - Array com a qtd em Estoque                                  ³
//³              [1]-Local                                                   ³
//³              [2]-Qtde Estoque                                            ³
//³aEstoque[6] - Quantidade a Reservar                                       ³
//³aEstoque[7] - Texto para ser mostrado no ListBox                          ³
//³aEstoque[8] - Numero do item na aCols                                     ³
//³aEstoque[9] - Armazem                                                     ³
//³aEstoque[10] - Filial                                             		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aSldEst                                                ³
//³                                                                          ³
//³aSldEst[1] - Numero do item                                               ³
//³aSldEst[2] - Codigo do produto                                            ³
//³aSldEst[3] - Descricao do produto                                         ³
//³aSldEst[4] - Quantidade solicitada para reserva                           ³
//³aSldEst[5] - Array contendo:                                              ³
//³             [1] - Local                                                  ³
//³             [2] - Qtde Estoque                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a consulta dos estoques das lojas da rede via RPC                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEstoque 	:= {}
aSldEst 	:= {}
cMsg 		:= ""

lLojaNaoSel := aScan(aLojas,{ |x| x[1] }) == 0

If lContinua
	For nX := 1 to Len(aLojas)
		If aLojas[nX][1] .OR. lLojaNaoSel  // Se tiver lojas selecionadas, carrega somente as selecionadas, caso contrario carrega todas como anteriormente.
			SLJ->(dbSetOrder(1))
			If  (  SLJ->(dbSeek(xFilial("SLJ")+aLojas[nX][2])) .or. lECCia) //e-commerce CiaShop não tem local de estoque
				If !lECCia
					aLocais := Lj080Local( Alltrim(SLJ->LJ_LOCAL), 2 )
					If empty( aLocais )
						aadd( aLjSemArmazem , SLJ->LJ_RPCFIL )
					endif
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|Para e-commerce sera utilizado o range de CEP (MF6) para definir armazem e filial.   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  lECommerce
						aSldEst := Lj7SldEst( aProdutos, {MF6->MF6_LOCAL}, PadR(MF6->MF6_XFILIA,Len(SB2->B2_FILIAL)) )
				ElseIf lCentPDV				
					//Consulta Estoque e add no Array 			
					// Central de PDV - Realizado via componente de comunicacao STBRemoteExecute  
					lContinua := STBRemoteExecute("Lj7SldEst", { aProdutos , aLocais , SLJ->LJ_RPCFIL } , NIL, .F. , @aSldEst )
					
					If !lContinua
						Aviso( "Atenção.", "Não foi possivel estabelecer comunicação com o Back-Office. " 		+ ;
								"Não será possivel consultar o estoque online. Deseja fazer a reserva mesmo " 	+ ;
								"sem saber se havera estoque disponivel? se não existir estoque suficiente "		+ ;
								"sera gerada uma solicitacao de compras com a quantidade necessaria para efetuar a reserva. ", {"OK"} )  
						
						// Monta Array com produtos zerados apenas para confirmacao
						aSldEst := LJ7EstZero( aProdutos, aLocais )
					EndIf
					
				ElseIf lECCia
					aSldEst := Lj7SldEst( aProdutos, {}, cFilRes, lECCia )
				Else
					aSldEst := Lj7SldEst( aProdutos, aLocais, SLJ->LJ_RPCFIL )
				EndIf	
					
					
				If ValType( aSldEst ) == "A" .AND. Len(aSldEst) > 0  
					If !lECCia
						aAdd( aEstoque, { .F., SLJ->LJ_CODIGO, Trim(SLJ->LJ_NOME), "", 0, 0, Trim(SLJ->LJ_NOME), "" } )
					Else
						aAdd( aEstoque, { .F., aLojas[01,02],  aLojas[01,03], "", 0, 0, aLojas[01,03], "" } )
					EndIf

					cLojaEstq := If(!lECCia, Alltrim(SLJ->LJ_CODIGO), aLojas[01,02])

					For nY := 1 to Len( aSldEst )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|soma as quantidades de todos os locais (almoxarifados)                               |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						For nZ := 1 to Len( aSldEst[nY][5] )
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//|Para e-commerce sera utilizado o range de CEP (MF6) para definir armazem e filial.   |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If  lECommerce
								If  (aSldEst[nY][5][nZ][1] != MF6->MF6_LOCAL)
									Loop
								EndIf
							EndIf

							// Aqui executa somente pela Rotina Automática(MSExecAuto)
							If isBlind() .AND. !lAutomato
								// Procura no aColsDet o número do item
								nPosSldEst := aScan( aColsDet, {|x| Alltrim(x[1])==aSldEst[nY][1]})
								If nPosSldEst == 0
									Loop
								EndIf	

								//Verifica se o item do array já foi adicionado no array aEstoque
								nPosEstoqu := aScan( aEstoque, { |x| ( Alltrim(x[2])+x[8]+x[4] == cLojaEstq+aSldEst[nY][1]+aSldEst[nY][2] ) } )

								//Aqui se já está no array aEstoque, não adiciona novamente
								If nPosEstoqu > 0
									Loop
								EndIf	
								aSldEst[nY][5][nZ][1] := aColsDet[nPosSldEst][nPosLocal]
							EndIf	
							
							// Se as posições referentes ao lote e endereçamento do produto estiverem vazias,
							// é gravado o tamanho dos campos da tabela SBF.
							// Este tratamento é feito na função Lj7SldEst. 
							cArmazem 	:= aSldEst[nY][5][nZ][1]
							nQuant 		:= aSldEst[nY][5][nZ][2]
							cLoteCtl := Iif(Empty(aSldEst[nY][5][nZ][3]), Space(Len(aSldEst[nY][5][nZ][3])), aSldEst[nY][5][nZ][3] + Space(TamSx3("BF_LOTECTL")[1] - Len(aSldEst[nY][5][nZ][3])))
							cSubLote := Iif(Empty(aSldEst[nY][5][nZ][4]), Space(Len(aSldEst[nY][5][nZ][4])), aSldEst[nY][5][nZ][4] + Space(TamSx3("BF_NUMLOTE")[1] - Len(aSldEst[nY][5][nZ][4])))
							cLocaliz := Iif(Empty(aSldEst[nY][5][nZ][5]), Space(Len(aSldEst[nY][5][nZ][5])), aSldEst[nY][5][nZ][5] + Space(TamSx3("BF_LOCALIZ")[1] - Len(aSldEst[nY][5][nZ][5])))
							cNumSer	 := Iif(Empty(aSldEst[nY][5][nZ][6]), Space(Len(aSldEst[nY][5][nZ][6])), aSldEst[nY][5][nZ][6] + Space(TamSx3("BF_NUMSERI")[1] - Len(aSldEst[nY][5][nZ][6])))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//| Alimenta a array aEstoque para montar a tela com os resultados                      |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							
							//#VFE
							//Se for VFE entao ja seleciona o produto automaticamente
							aAdd( aEstoque, { Iif(!lECCia,IIF(lLjVfe,.T.,.F.),.F.),;			// 1- True ou False (para o ListBox)	
										Iif(!lECCia,SLJ->LJ_CODIGO,aLojas[01,02]),;				// 2 - Codigo da Loja
										Iif(!lECCia,Trim(SLJ->LJ_NOME),Trim(aLojas[01,03])),;	// 3 - Nome da Loja 
										aSldEst[nY][2],;										// 4 - Codigo do Produto
										aSldEst[nY][5],; 										// 5 - Array com a qtd em Estoque | [1]-Local | [2]-Qtde Estoque | [3]-Lote | [4]-Sub-Lote | [5]-Endereço| [6]-Nro Serie
										aSldEst[nY][4],;										// 6 - Quantidade a Reservar
										Subst(aSldEst[nY][2],1,20)+" "+Subst(aSldEst[nY][3],1,25)+" "+cArmazem+"  " + Transform(nQuant,PesqPict("SB2","B2_QATU"));
										+ " " + cLoteCtl + " " + cSubLote + "  " + cLocaliz + " " + cNumSer,;		// 7 - Texto para ser mostrado no ListBox
										aSldEst[nY][1],;										// 8 - Numero do item na aCols
										aSldEst[nY][5][nZ][1],;									// 9 - Armazem
										Iif(!lECCia,SLJ->LJ_RPCFIL,cFilAnt),;					// 10 - Filial
										cLoteCtl,;												// 11 - Lote
										cSubLote,;												// 12 - Sub-Lote
										cLocaliz,;												// 13 - Endereço
										cNumSer,;												// 14 - Nro Serie
										})														
						Next nZ
					Next nY
				Endif
			Endif
		EndIf 
	Next nX
	
	If !Empty( cMsg )
		Aviso( STR0008, STR0026 + Substr(cMsg,1,Len(cMsg)-2),{STR0009} ) //"Atenção"###"Não foi possível estabelecer comunição com as lojas: "###"Ok"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se existir alguma loja sem o armazem cadastrado eh mostrada a mensagem abaixo como aviso ao usuario.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !empty(aLjSemArmazem)
		For nLjSemArmazem := 1 to len( aLjSemArmazem )
			cLjSemArmazem += aLjSemArmazem[nLjSemArmazem]  + " , "
		Next
		if len(cLjSemArmazem) > 5  // Tem mais de um elemento 
		
			cLjSemArmazem := Substr(cLjSemArmazem,1,Len(cLjSemArmazem)-8) + " e " + Substr(cLjSemArmazem,Len(cLjSemArmazem)-4 , 2 )
			// Substituo o penultimo " , " por  " e "  alem de Retirar o ultimo " , "
		else
			cLjSemArmazem := Substr(cLjSemArmazem,1,Len(cLjSemArmazem)-3)  // Retiro o ultimo " , "
		Endif
		Aviso( STR0008, STR0051 + space(1) + cLjSemArmazem + space(1) + STR0052 ,{STR0009} ) //"Atenção"###"Os produtos da(s) loja(s)" + xx, yy, zz + "Nao serão visualizados porque os seus armazens não foram informados." ###"Ok"		
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tela com o resultado da consulta do estoque para o usuario       ³
	//³ escolher onde fazer a reserva                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lReserva := .F.
	If !Empty(aEstoque)
		If lAutoExc .OR. lECCia
			//Reserva do primeiro local de estoque encontrado para a loja escolhida que possua saldo
			lContinua:=.F.

			If ExistBlock("LJRESERV") //Ponto de Entrada utilizado para fazer a reserva sem a apresentacao da tela ao usuario para selecao.
				aLJRESERV := ExecBlock("LJRESERV",.F.,.F., {"2", aLojas, aProdutos, aEstoque} )
				lContinua := .F.
				
				If aLJRESERV[1]
					lReserva  := .T.
					LjGrvLog( "LJRESERV", "Reserva via Ponto de Entrada LJRESERV.", NIL)
					
					//Atualiza o array aEstoque, conforme opcoes selecionadas no Ponto de Entrada (Customizado)
					For nX:=1 To Len(aEstoque)
						aEstoque[nX][1] := aLJRESERV[4][nX][1]
					Next nX
				EndIf
			Else

				For nX := 1 To Len(aEstoque)
					//Para cProduto (ou item e-commerce), cujo estoque ja foi selecionado passa para os estoques do proximo produto do Orcamento.
					If lECommerce .And. (aEstoque[nX][4] == cProduto) .AND. (!lECCia .OR. aEstoque[nX][8] == cItem )
						Loop
					EndIf    

					aEstoque[nX][1] := If(Empty(aEstoque[nX][4]),.F.,Lj7VldRes( aEstoque, nX, aLojas, aProdutos, lECCia))
					If aEstoque[nX][1]                                
						lReserva :=.T.
						lContinua:=.T.					
						cProduto := aEstoque[nX][4]	 //Estoque ja selecionado, nao processar mais estoques deste produto.
						cItem 	 := aEstoque[nX][8] //item do produto
					EndIf
				Next
				If !lContinua
					If !lECCia
						Final(STR0078) //"A Loja Informada para reserva não possui local/estoque suficiente."
					Else
						lReserva := .F.
						LjGrvLog( "", STR0078, NIL) //"A Loja Informada para reserva não possui local/estoque suficiente."
					EndIf
				EndIf

			EndIf

		ElseIf IsBlind() .AND. Len(aItReserv) > 0 //tratamento ExecAuto, nesse ponto irá auto selecionar os itens que serão reservados
			For nX:=1 To Len(aItReserv)	//Localiza item que foi marcado para reserva dentro do Array de Estoque(valida produto+numero do item)			
				If 	(nItPrdRes 	:= AScan( aItAuto[nX], 	{ |x| x[1] == "LR_PRODUTO"} )) > 0 	.AND. ;
					(nItPrdItem := AScan( aItAuto[nX], 	{ |x| x[1] == "LR_ITEM"} )) > 0 	.AND. ;
					(nPosRes 	:= AScan( aEstoque, 	{ |x| x[4]+x[8] == aItReserv[nX][nItPrdRes][2]+aItReserv[nX][nItPrdItem][2]} )) > 0 
					 
					 If aEstoque[nPosRes][5][1][2] >= aEstoque[nPosRes][6] //Verifica se possui saldo
						lReserva  				:= .T.
						aEstoque[nPosRes][1]	:= .T.
					 Else
					 	lReserva  				:= .F.
					 	Conout("ExecAuto LOJA701 - Reserva do Produto:["+AllTrim(aItReserv[nX][nItPrdRes][2])+"] Item:["+aItReserv[nX][nItPrdItem][2]+"] não foi realizada. Motivo: Saldo Insuficiente ")
					 EndIf 					
				EndIf
			Next nX
		Else
			lContinua := .T.
			While lContinua
				
				If ExistBlock("LJRESERV") //Ponto de Entrada utilizado para fazer a reserva sem a apresentacao da tela ao usuario para selecao.
					aLJRESERV := ExecBlock("LJRESERV",.F.,.F., {"2", aLojas, aProdutos, aEstoque} )
					lContinua := .F.
					
					If aLJRESERV[1]
						lReserva  := .T.
						
						//Atualiza o array aEstoque, conforme opcoes selecionadas no Ponto de Entrada (Customizado)
						For nX:=1 To Len(aEstoque)
							aEstoque[nX][1] := aLJRESERV[4][nX][1]
						Next nX
					EndIf
					
				//#VFE
				//Caso esta com VFE nao abre a tela para consultar o estoque
				ElseIf !lLjVfe
					DEFINE MSDIALOG oDlgEstoque TITLE STR0027 FROM 0,0 TO 300,940 PIXEL OF oDlgVA //"Consulta de Estoques"
			
					@ 08,08 LISTBOX oEstoque FIELDS HEADER "", STR0018 + CHR(13)+CHR(10)+STR0094 FIELDSIZES 14,100 SIZE 458,118 PIXEL FONT aFontes[3] OF oDlgEstoque  //"Loja Codigo          Descrição                Local      Saldo      Endereço"				
					oEstoque:SetArray(aEstoque)
					oEstoque:bLine := {|| { If(Empty(aEstoque[oEstoque:nAt][4]),oWhite,If(aEstoque[oEstoque:nAt,1],oOk,oNo)),;
											aEstoque[oEstoque:nAt,7] }}
					oEstoque:bLDblClick := {|| aEstoque[oEstoque:nAt,1] := If(Empty(aEstoque[oEstoque:nAt][4]),.F.,Lj7VldRes( @aEstoque, oEstoque:nAt, @aLojas, @aProdutos )) }
										
					@ 133,400 BUTTON STR0029 PIXEL SIZE 32,14 ACTION (lReserva:=.T.,oDlgEstoque:End()) OF oDlgEstoque //"Reservar"
					@ 133,435 BUTTON STR0030 PIXEL SIZE 32,14 ACTION (lContinua:=.F.,oDlgEstoque:End()) OF oDlgEstoque //"Cancelar"
					
					ACTIVATE MSDIALOG oDlgEstoque CENTERED
				Else
					lReserva := .T.
				EndIf
		
				If lReserva .And. !ExistBlock("LJRESERV")
					aEval( aEstoque, { |x| If(x[1].And.!Empty(x[4]),lContinua:=.F.,Nil) } )
				Endif		
			End
		EndIf		
	Else
		If lCentPDV
			Aviso( "Atenção.", "Não foi possivel estabelecer comunicação com o Back-Office.", {"OK"} )  
		Else
			Aviso( STR0008, STR0031, {STR0009} ) //"Atenção"###"Não há informações para serem consultadas."###"Ok"
		EndIf
	Endif                                         

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do array aReserva                                               ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³aReserva[1]-Codigo da Loja                                                ³
	//³aReserva[2]-Array contendo:                                               ³
	//³            [1] - Item do produto na aCols                                ³
	//³            [2] - Codigo do produto                                       ³
	//³            [3] - Quantidade                                              ³
	//³            [4] - Array contendo                                          ³
	//³                  [1] - Local                                             ³
	//³                  [2] - Quantidade em estoque                             ³
	//³            [5] - Armazem                                                 ³
	//³            [6] - Lote: Array contendo                                    ³		
	//³                  [1] - Sublote                                           ³
	//³                  [2] - Lote                                              ³
	//³                  [3] - Endereco                                          ³
	//³                  [4] - Numero Serie                                      ³
	//³            [7] - Numero do Recno da Tabela de Contingencia "MES"         ³		
	//³aReserva[3]-Codigo da reserva (SC0)                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aReserva := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o usuario pressionou o botao "Reservar" verifica se hah alguma reserva³
	//³ selecionada                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReserva
		For nX := 1 to Len(aEstoque)
			If aEstoque[nX][1] .And. !Empty(aEstoque[nX][4])
			
				// Numero da linha/posicao do produto gravado no array aReserva
				If !lECCia
					nPosaCols   := aScan( aColsDet, { |x| x[nPosItem] == aEstoque[nX][8] })

					If nPosaCols > 0

						//Atualizo o aColsDet, pra manter o padrão do F8
						aColsDet[nPosaCols][nPosLote]		:= aEstoque[nX][11]
						aColsDet[nPosaCols][nPosSublote]	:= aEstoque[nX][12]
						aColsDet[nPosaCols][nPosEndereco]	:= aEstoque[nX][13]
						aColsDet[nPosaCols][nPosNumSerie]	:= aEstoque[nX][14]
						
						aLote := {aColsDet[nPosaCols][nPosSublote] 	,; 	// Sublote
								  	aColsDet[nPosaCols][nPosLote]    	,;	// Lote				  				  				  
								  	aColsDet[nPosaCols][nPosEndereco]	,;	// Endereco
								  	aColsDet[nPosaCols][nPosNumSerie]	}	// Numero de serie
						
						cLoteSubLote := Alltrim(aColsDet[nPosaCols][nPosSublote]) + ; 	// Sublote
										  Alltrim(aColsDet[nPosaCols][nPosLote])		// Lote  
					EndIf

					nPos := aScan( aReserva, { |x| x[1] == aEstoque[nX][2] .AND. cLoteSubLote == Alltrim(x[2][1][6][1])+ Alltrim(x[2][1][6][2]) } )

					If nPos == 0		
						aAdd( aReserva, { aEstoque[nX][2], {{aEstoque[nX][8], aEstoque[nX][4], aEstoque[nX][6], aEstoque[nX][5], aEstoque[nX][9]}}, ""  } )
						aAdd( aReserva[Len(aReserva)][2][1], aLote  )
					Else
						aAdd( aReserva[nPos][2], {aEstoque[nX][8], aEstoque[nX][4], aEstoque[nX][6], aEstoque[nX][5], aEstoque[nX][9]} )
						aAdd( aReserva[nPos][2][Len(aReserva[nPos][2])], aLote  )
					Endif
				Else
					aLote := {"" 	,; 	// Sublote
								  	""    	,;	// Lote				  				  				  
								  	""	,;	// Endereco
								  	""	}	// Numero de serie 
				
					aAdd( aReserva, { aEstoque[nX][2], {{aEstoque[nX][8], ;
																	aEstoque[nX][4], ;
																	aEstoque[nX][6],;
																	 aEstoque[nX][5], ;
																	 aEstoque[nX][9],;
																	 aLote }}, ""  } )				
				EndIf			

			
			Endif
		Next nX
	Endif
	
	cMsg := ""
	If !Empty(aReserva)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazenas os dados do cliente em um array para enviar via RPC para cadas-³
		//³ tra-lo na outra loja se necessario                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		For nX:=1 to FCount()
			aAdd(aCliente,{Field(nX),FieldGet(nX)})
		Next nX

		// Array dos itens da Reserva              
		For nX := 1 to Len(aReserva[1][2])       		                                                                                                                        
 			If Len(aReserva[1][2]) < nX
				Exit
			Endif	
			
			If !lECCia						
			// Verifica se existe lancado com o mesmo codigo de produto
				nPos := aScan( aColsDet, { |x| x[2] == PadR(aReserva[1][2][nX][2], nTamX3Prod)}, nX+1 )
				If nPos > 1              
					// Posiciona no cadastro de Produtos
					If SB1->( DbSeek(xFilial("SB1") + aReserva[1][2][nX][2]) )
						// Verifica se o produto e controlado por Lote
						If SB1->B1_RASTRO == "L"
							Aadd( aReserva,{aReserva[1][1],{aReserva[1][2][nX]},""} )
							Adel(aReserva[1][2], nX)
							Asize( aReserva[1][2], Len(aReserva[1][2])-1 )
							// Como e retirado do Array de Itens volta para primeira posicao do array
							nX := 0
						EndIf
					EndIf
				EndIf

			EndIf
		Next

		For nX := 1 to Len(aReserva) 
			If  lECommerce        
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //|Para e-commerce sera utilizado o range de CEP (MF6) para definir armazem e filial.   |
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cReserva := Lj7GeraSC0( aReserva[nX][2], dDatabase+MF6->MF6_DIASRE, aCliente, MF6->MF6_XFILIA,,,@aNumRes )
				
				If  (ValType(cReserva) == "C") .And. !( Empty(cReserva) )
					aReserva[nX][3] := cReserva
				Else
					cMsg += "E-Commerce"
				EndIf	
			
			ElseIf lECCia 
				cReserva := Lj7GeraSC0( aReserva[nX][2], dDtLimite, aCliente, cFilRes,;
														   , lECCia, @aNumRes)
				
				If  (ValType(cReserva) == "C") .And. !( Empty(cReserva) )
					aReserva[nX][3] := cReserva
				Else
					cMsg += "E-Commerce"
				EndIf			
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Posiciona o arquivo de lojas (SLJ)                                                  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SLJ->(dbSetOrder(1))
				SLJ->(dbSeek(xFilial("SLJ")+aReserva[nX][1]))
	
				If lCentPDV
					// Central de PDV - Realizado via componente de comunicacao 
					lContinua := STBRemoteExecute("Lj7GeraSC0", { aReserva[nX][2], dDatabase+SLJ->LJ_DIASRES, aCliente, SLJ->LJ_RPCFIL, lCentPDV } , NIL, .F. , @cReserva )
					
					If !lContinua
					
						//Pergunta se deseja gerar reserva cegas 
						If MsgYesNo("Não foi possível estabelecer comunicação com o Back-Office. Deseja gerar reserva mesmo sem comuncação com BackOffice? a reserva sera gerada via contingência.")
						
							//Chama gravacao por contingencia
							aRet := STBRecordLocalContingency("Lj7GeraSC0", { aReserva[nX][2], dDatabase+SLJ->LJ_DIASRES, aCliente, SLJ->LJ_RPCFIL, lCentPDV,,@aNumRes } , Nil ,"01", SL2->L2_FILIAL+SL2->L2_NUM+SL2->L2_ITEM+SL2->L2_PRODUTO )
	
							If Empty(cReserva) .AND. aRet[1]
			
								// Se conseguiu gravar contingencia grava cReserva como "MES"
								cReserva := "MES"
								nRecnoMES := aRet[2] // Guarda o Numero do recno da tabela de contingencia "MES"
							Else
														
								cMsg += Trim("Nao conseguiu gravar Reserva") // Nao conseguiu gravar contingencia...						
							
							EndIf	
	
						EndIf
					
									
					EndIf
						
				Else
					cReserva := Lj7GeraSC0( aReserva[nX][2], dDatabase+SLJ->LJ_DIASRES, aCliente, SLJ->LJ_RPCFIL,,, @aNumRes,,,, aProdutos )
				EndIf			

				// Verifica se foi adicionado dados ao array
				If Len(aReserva[nX][2]) > 0
					//Verifica se o Tipo Entrega é igual a "5"
					nPosaCols := aScan( aCols, { |x| x[nPosItem] == aReserva[nX][2][1][1] })
					If aCols[nPosaCols][nPosEntr] == "5" 
						//Existe Pedido com Entrega sem Reserva
						lPedSemRes	:= .T.
					EndIf				
				EndIf

				If !lIntegDef //Integracao Mensagem Unica nao faz reserva				
					If ValType(cReserva) == "C" .and. !Empty(cReserva)
						aReserva[nX][3] := cReserva
						cMsg := ""
					Else 
						cMsg += Trim(SLJ->LJ_NOME)
					Endif
				EndIf	
			EndIf

		Next nX
	
		//Se existe Pedido com Entrega sem Reserva, não apresenta mensagem
		If !Empty(cMsg) .AND. !lPedSemRes 
			If lCentPDV
				Aviso( STR0008, "Não foi possível estabelecer comunicação com o Back-Office. " + cMsg, {STR0009} ) 
			Else	
				Aviso( STR0008, STR0032 + Substr(cMsg,1,Len(cMsg)-2), {STR0009} ) //"Atenção"###"Não foi possível estabelecer comunicação com a(s) loja(s): "###"Ok"
			EndIf
		Endif
	
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o array de retorno com as informacoes da reserva                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet := {}
	lPedSemRes	:= .F.   
	For nX := 1 to Len( aReserva )
		SLJ->(dbSetOrder(1))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Verifica se retornou um numero de reserva                                           |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Verfica tamanho do array e se foi adionado os dados necessário
		If Len(aReserva[nX][2]) > 0
			nPosaCols := aScan( aCols, { |x| x[nPosItem] == aReserva[nx][2][1][1] })
			If aCols[nPosaCols][nPosEntr] == "5" 
				//Existe Pedido com Entrega sem Reserva
				lPedSemRes	:= .T.
			EndIf
		EndIf	
		If (( SLJ->(dbSeek(xFilial("SLJ")+aReserva[nX][1])) .OR. lECCia ) .And. !Empty(aReserva[nX][3])) .OR. (SLJ->(dbSeek(xFilial("SLJ")+aReserva[nX][1])) .AND. lPedSemRes)  
			For nY := 1 to Len( aReserva[nX][2] )
				cResTmp := aReserva[nX][3] 
				
				If Len(aNumRes) > 1
					If (nPosRes := aScan( aNumRes, { |r| r[1] == aReserva[nX][2][nY][1]}) ) > 0
						cResTmp := aNumRes[nPosRes][02]
					EndIf 
				EndIf
			
				aAdd( aRet, { aReserva[nX][2][nY][1],;		// Item do produto na aCols
							aReserva[nX][2][nY][2],;			// Codigo do produto
							aReserva[nX][2][nY][3],;			// Quantidade reservada
							aReserva[nX][1],;					// Codigo da loja
							cResTmp,;					// Codigo da reserva
							aReserva[nX][2][nY][5] ,;		// Armazem da reserva
							nRecnoMES				 } )		// Recno da tabela de contingencia "MES"
			Next nY
		ElseIf Empty(aReserva[nX][3])
			aSB1 := SB1->(GetArea())				
			SB1->(DbSetOrder(1)) //B1_Filial + B1_COD
				For nY := 1 to Len( aReserva[nX][2] )
					If !(IntWms(aReserva[nX][2][nY][2]))
						SB1->(DbSeek(xFilial("SB1") + aReserva[nX][2][nY][2]))
						If SB1->(Found() .AND. B1_LOCALIZ == "S")//produto controlado por endereçamento
							Aviso(STR0008, STR0089 + AllTrim(SB1->B1_COD) + "-" + AllTrim(SB1->B1_DESC) + STR0090 + Chr(13)+Chr(10) + STR0088 , {STR0009}) // "Não foi encontrado Saldo por Endereço na tabela SBF para o produto <Produto>. Favor verificar a rotina 'Cria Endereço' para a Criação de Saldos por Endereço. Reserva não Efetuada."
						EndIf
					EndIf
				Next nY
			RestArea(aSB1)	
		Endif
		lPedSemRes := .F.
	Next nX

Endif

Lj7RestArea(aArea)
Return aRet 

/*/{Protheus.doc} LJ7VldRes
Faz a validacao no dblclick no ListBox da escolha dos
produtos/lojas. Valida se o produto tem saldo em estoque e
nao permite escolher o mesmo item em duas lojas diferentes
@type  Static Function
@author Vendas Clientes
@since 11/11/02
@version AP7
@param	ExpA2 - Array com as informacoes do Listbox
			ExpA2[1] - True ou False (para o ListBox)
			ExpA2[2] - Codigo da Loja
			ExpA2[3] - Nome da Loja
			ExpA2[4] - Codigo do Produto
			ExpA2[5] - Array com a qtd em Estoque
					[1]-Local
					[2]-Qtde Estoque
			ExpA2[6] - Quantidade a Reservar
			ExpA2[7] - Texto para ser mostrado no ListBox
			ExpA2[8] - Numero do item na aCols
			ExpA2[9] - Armazem
			ExpA2[10] - Filial
			ExpA2[11] - Lote
			ExpA2[12] - Sub-Lote
			ExpA2[13] - Endereço
			ExpA2[14] - Nro Serie

		ExpN3 - Numero da linha do listbox em que o usuario esta posicionado.
@return lRet, Logico,	Se .T. - Faz a selecao da linha
						Se .F. - Nao faz a selecao da linha
@example
ExpL1 := LJ7VLDRES( ExpA2, ExpN3 ) 
/*/
Static Function LJ7VldRes( aEstoque, nLinha, aLojas,aProdutos, lECCia )

Local lRet 		:= !aEstoque[nLinha][1]
Local nPos		:= 0
Local lTemSaldo	:= .F.
Local lLJ7062	:= ExistBlock("LJ7062")						// Ponto de entrada no duplo clique da selecao dos produtos
Local nValResUti:= 0
Local nX		:= 0
Local nPosi		:= 0
Local lCentPDV	:= LjGetCPDV()[1]						 	// Central de PDV
Local nPosEntr	:= 0										// Posicao do Tipo de Entrega
Local nPosItem	:= 0										// Posicao do Item
Local nItaCols	:= 0										// Posicao do Item no aCols
Local lEstNeg 	:= (SuperGetMV("MV_ESTNEG",,"S") == "S")	// Indica se permite vender com estoque negativo
Local nItemaCols:= 1										// Indica o numero do item no aCols
Local lEntSResrv:= .F.										// Indica se o produto é com tipo de entrega 5 - Pentrega c/ Pedido sem reserva, pois esta modalidade não controla endereço e localização
Local lPrdLotEnd:= .F.										// Se produto configurado com Lote ou Endereço
Local lRastro 	:= .F. 										// Guarda se o Produto é Configurado com Controle de Lote
Local lLocaliza	:= .F.										// Guarda se o Produto é Configurado com Controle de Endereçamento

//³Tratamento para e-Commerce
Local lECommerce := SuperGetMV("MV_LJECOMM",,.F.) .And. LJ862ECAuto()
Default lECCia := .f.

lRastro 	:= Rastro(aEstoque[nLinha][4])
lLocaliza	:= Localiza(aEstoque[nLinha][4])

If !lECommerce .And. !lECCia .And. !IsBlind()
	nPosEntr	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ENTREGA"})	// Posicao do Tipo de Entrega
	nPosItem	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ITEM"})		// Posicao do Item

	If nPosItem > 0
		// Procura a linha(Item) do aCols	
		nItaCols := aScan( aCols , { |x| x[nPosItem] == aEstoque[nLinha][8] } )	
	EndIf
EndIf

If lLj7062
	U_LJ7062(@aEstoque, nLinha, @aLojas, @aProdutos)
EndIf	

//³ Soh faz a validacao se o usuario estiver selecionando o produto          ³
If !aEstoque[nLinha][1]
	//³ Verifica se o produto esta sendo selecionado em duplicidade              ³
	nPos := aScan( aEstoque, { |x| ( x[1] .And. x[8]+x[4] == aEstoque[nLinha][8]+aEstoque[nLinha][4] ) } )
	If nPos > 0
		If !lECCia
			Aviso( STR0008, STR0033, {STR0009} ) //"Atenção"###"Não poderá ser selecionado o mesmo item em 2 lojas."###"Ok"
		EndIf
		lRet := .F.
	Endif
	
	If !lECCia
		//Valida se o Produto de Retira é da mesma filial da reserva
		lRet := lRet .And. LjVlFilRes(aLojas,aProdutos,aEstoque[nLinha][8])
	EndIf	

	//³ Verifica o saldo em estoque                                              ³
	If lRet
		If Len(aEstoque[nLinha][5]) > 1 .OR. lRastro .OR. lLocaliza
			//Entra no IF quando esta trabalhando com Lote e Enderecamento
			nPos := aScan( aEstoque[nLinha][5], { |x| AllTrim(x[1])+AllTrim(x[3])+AllTrim(x[4])+AllTrim(x[5]) == AllTrim(aEstoque[nLinha][9])+AllTrim(aEstoque[nLinha][11])+AllTrim(aEstoque[nLinha][12])+AllTrim(aEstoque[nLinha][13]) } )
	
			If nPosItem > 0 .AND. nPosEntr > 0 .AND. (lRastro .OR. lLocaliza) .AND. aCols[nItaCols][nPosEntr] <> "5"
				lPrdLotEnd := .T.
			EndIf	
		Else
			nPos := aScan( aEstoque[nLinha][5], { |x| x[1] == aEstoque[nLinha][9] } )
		EndIf
		If nPos > 0 
			If aEstoque[nLinha][5][nPos][2] >= aEstoque[nLinha][6]
				lTemSaldo := .T.
			Endif	
		Endif
		
		If lTemSaldo .OR. (!lTemSaldo .AND. aEstoque[nLinha][5][nPos][2] < aEstoque[nLinha][6])  
			For nX:=1 to Len(aEstoque)
				// Verifica se ja tem reserva para o mesmo Produto e mesmo Local
				nItemaCols := aScan(aProdutos, {|x| x[2] == aEstoque[nLinha][8] })
				lEntSResrv := ( Len(aProdutos[nItemaCols]) >= 6 .AND. aProdutos[nItemaCols][6] == "5" .AND. Localiza(aEstoque[nLinha][4]) )

				If	!Empty(aEstoque[nX][4]) .AND. aEstoque[nX][1] .AND.; 	// Item selecionado?
					aEstoque[nLinha][4] == aEstoque[nX][4] .AND.;			// Produto igual?
					aEstoque[nLinha][9] == aEstoque[nX][9] .AND.;			// Armazem igual?
					( aEstoque[nLinha][13] == aEstoque[nX][13] .OR.	lEntSResrv ) // // Enrereço igual?  Ou Produto entrega Tipo 5 com controle de localização? // Produto com Entrega Tipo 5 não controla endereçamento
				
					nPosi := aScan( aEstoque[nX][5], { |x| x[3] == aEstoque[nX][11] } )
					If (nPosi > 0 .AND.  aEstoque[nLinha][11] == aEstoque[nX][5][nPosi][3]) .OR. lEntSResrv // -- Comparo se o Lote é o mesmo para fins de acumulo de saldo.
						nValResUti += aEstoque[nX][6] //Saldo ja reservado
					EndIf

				EndIf
			Next nX
	
			If aEstoque[nLinha][5][nPos][2] < (aEstoque[nLinha][6] + nValResUti)
				lTemSaldo := .F.
			EndIf
		EndIf

		If !lTemSaldo 
			//³ Verifica se usa reserva sem estoque. Se usar chama funcao para validar   ³
   			If ((AllTrim(Str(SuperGetMv("MV_LJGERSC",,1))) $ "2|3|4") .OR. lECommerce .OR. lECCia) .AND. !lPrdLotEnd

   				//Para reservas na central  ou e-commerce CiaShop  faz direto sem confirmacao
   				If lCentPDV
   					lRet := .T.

				ElseIf FindFunction("LA590VlEtq")
					If nPosEntr > 0
						// Se !lTemSaldo, MV_ESTNEG = "N" e Tipo Reserva = "2 - Retira", não será permitido realizar reserva
						If !lEstNeg .AND. aCols[nItaCols][nPosEntr]=="2"
							Aviso( STR0008, STR0098, {STR0009} ) //"Produto sem saldo em estoque!!! Não é permitido realizar reserva do tipo Retira com produto sem saldo em estoque."
							lRet := .F.
						EndIf
					EndIf
					
					If lRet
						lRet := LA590VlEtq(aEstoque, nLinha)
						If lRet													
							aEstoque[nLinha][5][nPos][2] := aEstoque[nLinha][5][nPos][2] - nValResUti
						Endif
					EndIf
			    	LjGrvLog( "", "Retorno da Reserva automatica de estoque ", lRet)
			    Endif											 
			Else
				// Central de PDV 
				If lCentPDV
					//Add mensagem para usario da central de pdv habilitar os processos de SC p etq negativo
					Aviso( STR0008, STR0034 + " Habilite o processo de Solicatacao de compras para Reservar Itens sem estoque: MV_LJGERSC", {STR0009} ) //"Atenção"###"Saldo insuficiente."###"Ok"
				Else
					If !lPrdLotEnd
						Aviso( STR0008, STR0034, {STR0009} ) //"Atenção"###"Saldo insuficiente."###"Ok"
						LjGrvLog( "", STR0008 + " " + STR0034, lRet)
					Else

						If !isBlind()
							Help(NIL, NIL, STR0101, NIL, CRLF + STR0102 + AllTrim(aEstoque[nLinha][4]) +;	//"SALDO INSUFICIENTE!",, "Produto: " + AllTrim(aEstoque[nLinha][4])
									STR0103 + " " +;														//"Produto configurado com CONTROLE DE LOTE e/ou ENDEREÇAMENTO, está com SALDO em Estoque INSUFICIENTE!!!"
									STR0104 + CRLF  +;														//"Não será possível  realizar a reserva do Produto."	
									STR0105 + AllTrim(Str(aEstoque[nLinha][6] + nValResUti)) + CHR(10) +;	//"Qtde à Reservar:" + AllTrim(Str((aEstoque[nLinha][6] + nValResUti)))
									STR0106 + AllTrim(Str(aEstoque[nLinha][5][nPos][2]))  + CRLF +;			//"Saldo Disponível: " + AllTrim(Str(aEstoque[nLinha][5][nPos][2])) , 1 )
									STR0107 , +;															//"Para Entrega do tipo 3-Entrega, somente é permitida a Reserva da quantidade disponível no Lote e/ou Endereço." 
									1, 0, NIL, NIL, NIL, NIL, NIL, {STR0109})			   					//"Para a quantidade que está indisponível, é possível utilizar a opção 5-Entrega c/ Pedido s/ Reserva."

						Else
							ConOut(	STR0101 + CRLF +;
									STR0102 + AllTrim(aEstoque[nLinha][4]) + CRLF +;    					//"SALDO INSUFICIENTE!",, "Produto: " + AllTrim(aEstoque[nLinha][4])
									STR0103 + CRLF +;                                                		//"Produto configurado com CONTROLE DE LOTE e/ou ENDEREÇAMENTO, está com SALDO em Estoque INSUFICIENTE!!!"
									STR0104 )												    			//"Não será possível  realizar a reserva do Produto."
						EndIf														  																		
						LjGrvLog( "", STR0101 + " " + STR0103, lRet)
					EndIf							
				EndIf
				lRet := .F.					
		    Endif 			
		Endif
	Endif
Endif

Return lRet
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LJ7EstZero ºAutor  ³Vendas Clientes     º Data ³  26/09/02 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta array de Estoque zerado                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1 := LJ7EstZero( ExpA2, ExpA3 )                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA2 - Array contendo:                                     º±±
±±º          ³        [1] - .F.                                           º±±
±±º          ³        [2] - Item do produto na aCols                      º±±
±±º          ³        [3] - Codigo do produto                             º±±
±±º          ³        [4] - Descricao do produto                          º±±
±±º          ³        [5] - Quantidade                                    º±±
±±º          ³ExpA3 - Array com os locais (almoxarifados)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array contendo:                                     º±±
±±º          ³        [1] - Numero do item                                º±±
±±º          ³        [2] - Codigo do produto                             º±±
±±º          ³        [3] - Descricao do produto                          º±±
±±º          ³        [4] - Quantidade solicitada para reservar           º±±
±±º          ³        [5] - Array contendo:                               º±±
±±º          ³              [1] - Local                                   º±±
±±º          ³              [2] - Qtde Estoque Zerado                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ7EstZero( aProdutos, aLocais )   

Local aRet 		:= {}
Local nX 		:= 0
Local nY 		:= 0
Local nSaldo	:= 0

For nX := 1 to Len(aProdutos)
	aAdd( aRet, { aProdutos[nX][2], aProdutos[nX][3], aProdutos[nX][4],aProdutos[nX][5], {} } )
	For nY := 1 to Len(aLocais)
		aAdd( aRet[Len(aRet)][5], { aLocais[nY], nSaldo } )
	Next nY	
Next nX

Return aRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7SldEst ºAutor  ³Vendas Clientes     º Data ³  26/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a consulta de saldo em estoque dos produtos             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1 := Lj7SldEst( ExpA2, ExpA3, ExpC1 )                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA2 - Array contendo:                                     º±±
±±º          ³        [1] - .F.                                           º±±
±±º          ³        [2] - Item do produto na aCols                      º±±
±±º          ³        [3] - Codigo do produto                             º±±
±±º          ³        [4] - Descricao do produto                          º±±
±±º          ³        [5] - Quantidade                                    º±±
±±º          ³ExpA3 - Array com os locais (almoxarifados)                 º±±
±±º          ³ExpC1 - Codigo da filial para pesquisa do estoque           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array contendo:                                     º±±
±±º          ³        [1] - Numero do item                                º±±
±±º          ³        [2] - Codigo do produto                             º±±
±±º          ³        [3] - Descricao do produto                          º±±
±±º          ³        [4] - Quantidade solicitada para reservar           º±±
±±º          ³        [5] - Array contendo:                               º±±
±±º          ³              [1] - Local                                   º±±
±±º          ³              [2] - Qtde Estoque                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7SldEst( aProdutos, aLocais, cFilEst, lECCia )
Local aRet 			:= {}
Local nX 			:= 0
Local nY 			:= 0
Local nSaldo		:= 0
Local nPosaCols		:= 0
Local nPosItem		:= 0										// Posicao do Campo de nro do item
Local nPosLote		:= 0										// Posicao do Campo de Lote
Local nPosSubL		:= 0										// Posicao do Sub Lote
Local nPosEndL		:= 0										// Posicao do Endereco
Local nPosNSer		:= 0										// Posicao do Numero de Serie
Local lMV_LOTVENC	:= (SuperGetMV("MV_LOTVENC",,"S") == "S")	// Indica se devem ser utilizados Lotes/Sub-Lotes com a data de validade vencida. (S)im ou (N)ao        
Local nPosEntr		:= 0										// Posicao do Tipo de Entrega
Local lPedSemRes	:= .F.										// guarda se o Pedido é Entrega sem Reserva

Default cFilEst	:= xFilial("SB2")
Default lECCia := .F.

If !lECCia
    nPosItem	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_ITEM" })					// Posicao do Campo de nro do item
    nPosLote	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOTECTL" })				// Posicao do Campo de Lote
    nPosSubL	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NLOTE" })				// Posicao do Sub Lote
    nPosEndL	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOCALIZ" })				// Posicao do Endereco
    nPosNSer	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NSERIE" })				// Posicao do Numero de Serie
	nPosEntr    := aScan(aHeader,   {|x| AllTrim(Upper(x[2]))=="LR_ENTREGA"})				// Posicao do Tipo de Entrega	
EndIf

If Empty(xFilial("SB2"))
	cFilEst := xFilial("SB2")
EndIf

dbSelectArea("SB2")
SB2->(dbSetOrder(1))	// filial + cod + local 

For nX := 1 to Len(aProdutos)

	// Apresenta somente os itens selecionados na tela anterior
	If aProdutos[nX][1]

		//Variáveis inicializadas com o tamanho dos campos da tabela SBF
		cLote    :=	Space(TamSx3("BF_LOTECTL")[1])
		cSubLote :=	Space(TamSx3("BF_NUMLOTE")[1])
		cLocaliz :=	Space(TamSx3("BF_LOCALIZ")[1])
		cNroSerie:= Space(TamSx3("BF_NUMSERI")[1])	

		If !lECCia
			nPosaCols := aScan( aColsDet, { |x| x[nPosItem] == aProdutos[nX][2] })
			cLote    	:= aColsDet[nPosaCols][nPosLote]		
			cSubLote 	:= aColsDet[nPosaCols][nPosSubL]	
			cLocaliz 	:= aColsDet[nPosaCols][nPosEndL]	
			cNroSerie	:= aColsDet[nPosaCols][nPosNSer]
			lPedSemRes 	:= aCols[nPosaCols][nPosEntr] == "5" 			
		EndIf

		aAdd( aRet, { aProdutos[nX][2], aProdutos[nX][3], aProdutos[nX][4], aProdutos[nX][5], {} } )
		If lECCia .AND. Len(aProdutos[nX]) >= 6 //e-commerce ciashop o local vem no item, por conta de P.E
			aLocais := aClone(aProdutos[nX, 06])
		EndIf
		
		For nY := 1 to Len(aLocais) 
			// Produto configurado COM Controle de Lote e COM controle de Endereçamento			
			// Se for Tipo Entrega igual a "5", não faz o Select com Lote e Endereçamento	
			If !lECCia .And. Rastro(aProdutos[nX][3]) .And. Localiza(aProdutos[nX][3]) .AND. !lPedSemRes

				cAliasSBF := GetNextAlias()
				cQuery := " SELECT BF_LOTECTL, BF_NUMLOTE, BF_LOCALIZ, BF_NUMSERI, (BF_QUANT - BF_EMPENHO) AS BF_QUANT "
				cQuery += " FROM " + RetSqlName("SBF") + " SBF "
				cQuery += " WHERE SBF.BF_FILIAL  = '" + cFilEst + "' "
				cQuery += " AND SBF.BF_PRODUTO = '" + aProdutos[nX][3] + "' "
				cQuery += " AND SBF.BF_LOCAL = '" + aLocais[nY] + "' "

				If !Empty(cLote)
					cQuery += " AND SBF.BF_LOTECTL = '" + cLote + "' "
				EndIf

				If !Empty(cSubLote)
					cQuery += " AND SBF.BF_NUMLOTE = '" + cSubLote + "' "
				EndIf
				
				If !Empty(cLocaliz)
					cQuery += " AND SBF.BF_LOCALIZ = '" + cLocaliz + "' "
				EndIf
			
				If !Empty(cNroSerie)
					cQuery += " AND SBF.BF_NUMSERI = '" + cNroSerie + "' "
				EndIf

				cQuery += " AND SBF.D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBF,.T.,.T.)
				If (cAliasSBF)->(!Eof())
					While (cAliasSBF)->(!Eof())						
						aAdd( aRet[Len(aRet)][5], { aLocais[nY], (cAliasSBF)->BF_QUANT, (cAliasSBF)->BF_LOTECTL, (cAliasSBF)->BF_NUMLOTE, (cAliasSBF)->BF_LOCALIZ, (cAliasSBF)->BF_NUMSERI } )	// armazém, saldo, lote  e endereço												
						(cAliasSBF)->(dbSkip())	
					End
				Else
					// Adiciona no aRet as variaveis já com o tamanho dos campos da tabela SBF
					aAdd( aRet[Len(aRet)][5], { aLocais[nY], 0, cLote, cSubLote, cLocaliz, cNroSerie } )	// armazém, saldo e endereço					
				Endif

			ElseIf Rastro(aProdutos[nX][3])	.And. !Localiza(aProdutos[nX][3]) .AND. !lPedSemRes
				// Produto configurado COM Controle de Lote e SEM controle de Endereçamento	
				// Se for Tipo Entrega igual a "5", não faz o Select com Controle de Lotes

				cAliasSB8 := GetNextAlias()
				cQuery := " SELECT B8_LOTECTL, B8_NUMLOTE, (B8_SALDO - B8_EMPENHO) AS B8_QUANT "
				cQuery += " FROM " + RetSqlName("SB8") + " SB8 "
				cQuery += " WHERE SB8.B8_FILIAL  = '" + cFilEst + "' "
				cQuery += " AND SB8.B8_PRODUTO = '" + aProdutos[nX][3] + "' "
				cQuery += " AND SB8.B8_LOCAL = '" + aLocais[nY] + "' "

				// Se MV_LOTVENC = "N", serão exibidos somente os lotes dentro da validade
				If !lMV_LOTVENC
                    cQuery +="  AND SB8.B8_DTVALID >= '" + DtoS(dDataBase) + "' "
                EndIf   

				If !Empty(cLote)
					cQuery += " AND SB8.B8_LOTECTL = '" + cLote + "' "
				EndIf

				If !Empty(cSubLote)
					cQuery += " AND SB8.B8_NUMLOTE = '" + cSubLote + "' "
				EndIf

				cQuery += " AND SB8.D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB8,.T.,.T.)
				If (cAliasSB8)->(!Eof())
					While (cAliasSB8)->(!Eof())
						If  (cAliasSB8)->B8_QUANT > 0
							aAdd( aRet[Len(aRet)][5], { aLocais[nY], (cAliasSB8)->B8_QUANT, (cAliasSB8)->B8_LOTECTL, (cAliasSB8)->B8_NUMLOTE, "", "" } )	// armazém, saldo e endereço							
						EndIf
						(cAliasSB8)->(dbSkip())	
					End
					If Len(aRet[Len(aRet)][5]) == 0
						aAdd( aRet[Len(aRet)][5], { aLocais[nY], 0, Space(TamSx3("B8_LOTECTL")[1]), Space(TamSx3("B8_NUMLOTE")[1]), "", "" } )	// armazém, saldo e lote
					EndIf
				Else
					aAdd( aRet[Len(aRet)][5], { aLocais[nY], 0, Space(TamSx3("B8_LOTECTL")[1]), Space(TamSx3("B8_NUMLOTE")[1]), "", "" } )	// armazém, saldo e lote
				EndIf

			ElseIf !lECCia .And. !Rastro(aProdutos[nX][3]) .And. Localiza(aProdutos[nX][3]) .AND. !lPedSemRes
				// Produto configurado SEM Controle de Lote e COM controle de Endereçamento	
				//Se for Tipo Entrega igual a "5", não faz o Select com Controle de Endereço

				cAliasSBF := GetNextAlias()
				cQuery := " SELECT BF_LOTECTL, BF_NUMLOTE, BF_LOCALIZ, BF_NUMSERI, (BF_QUANT - BF_EMPENHO) AS BF_QUANT "
				cQuery += " FROM " + RetSqlName("SBF") + " SBF "
				cQuery += " WHERE SBF.BF_FILIAL  = '" + cFilEst + "' "
				cQuery += " AND SBF.BF_PRODUTO = '" + aProdutos[nX][3] + "' "
				cQuery += " AND SBF.BF_LOCAL = '" + aLocais[nY] + "' "
				
				If !Empty(cLocaliz)
					cQuery += " AND SBF.BF_LOCALIZ = '" + cLocaliz + "' "
				EndIf

				If !Empty(cNroSerie)
					cQuery += " AND SBF.BF_NUMSERI = '" + cNroSerie + "' "
				EndIf

				cQuery += " AND SBF.D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBF,.T.,.T.)
				If (cAliasSBF)->(!Eof())
					While (cAliasSBF)->(!Eof())
						
						aAdd( aRet[Len(aRet)][5], { aLocais[nY], (cAliasSBF)->BF_QUANT, (cAliasSBF)->BF_LOTECTL, (cAliasSBF)->BF_NUMLOTE, (cAliasSBF)->BF_LOCALIZ, (cAliasSBF)->BF_NUMSERI } )	// armazém, saldo e endereço
						
						(cAliasSBF)->(dbSkip())	
					End
				Else
					// Adiciona no aRet as variaveis já com o tamanho dos campos da tabela SBF
					aAdd( aRet[Len(aRet)][5], { aLocais[nY], 0, cLote, cSubLote, cLocaliz, cNroSerie } )	// armazém, saldo e endereço				
				Endif
			Else			
				If SB2->(dbSeek(cFilEst+aProdutos[nX][3]+aLocais[nY]))
					nSaldo := SaldoSb2()
					aAdd( aRet[Len(aRet)][5], { aLocais[nY], nSaldo, "", "", "", "" } )
				Endif
			EndIf
		Next nY

	EndIf
	
Next nX

Return aRet 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7GeraSC0  ºAutor³Vendas Clientes     º Data ³  29/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a reserva no SC0                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpC1:= Lj7GeraSC0( ExpA1, ExpD1, ExpA2, ExpC2 , ExpL1,ExpL2)±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Array contendo                                      º±±
±±º          ³        [1] - Item do produto na aCols                      º±±
±±º          ³        [2] - Codigo do produto                             º±±
±±º          ³        [3] - Quantidade                                    º±±
±±º          ³        [4] - Array contendo                                º±±
±±º          ³              [1] - Local                                   º±±
±±º          ³              [2] - Quantidade em estoque                   º±±
±±º          ³        [5] - Armazem onde sera feita a reserva             º±±
±±º          ³        [6] - Lote: Array contendo                          º±±
±±º          ³              [1] - Sublote                                 º±±
±±º          ³              [2] - Lote                                    º±±
±±º          ³              [1] - Endereco                                º±±
±±º          ³              [2] - Numero Serie                            º±±
±±º          ³ExpD1 - Data de validade da reserva                         º±±
±±º          ³ExpA2 - Array com os dados do cliente (SA1)                 º±±
±±º          ³        [1] - Campo                                         º±±
±±º          ³        [2] - Conteudo do campo                             º±±
±±º          ³ExpC2 - Codigo da filial para ser efetuada a reserva        º±±
±±º          ³ExpL1 - Determina se foi chamado da central do POS          º±±
±±º          ³ExpL2 - Array com o número das Reservas Gearadas            º±±
±±º          ³ExpL3 - Msg de Retorno para Integracao EAI                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC1 - Numero da reserva gerada (SC0->C0_NUM)              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7GeraSC0(aReserva, dValidade, aCliente, cFilRes   , lCentPDV ,;
                    lECCia  , aNumRes  , cXMLRet , aHeaderAux, aColsAux ,;
					aProdutos )
Local aOperacao := {}							// Variavel para utilizacao da funcao de reservas
Local aLote 	:= {"","","",""}				// Variavel para utilizacao da funcao de reservas
Local nPosCGC	:= aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="A1_CGC" })
Local nPosCod	:= aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="A1_COD" })
Local nPosLoja	:= aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="A1_LOJA" })
Local nPosFil	:= aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="A1_FILIAL" })
Local nX 		:= 0
Local cFilSc0	:= cFilAnt
Local cFilAux	:= ""
Local cCGC		:= ""
Local cNumero 	:= ""
Local lRet 		:= .F.
Local nSaveSx8 	:= 0
Local nPosSublote	:= 0 //³Inicializado variavel como zero, porque pode ser Ws. ³
Local nPosLote		:= 0 //³Vai ser Inicializada com valor logo a baixo          ³
Local nPosEndereco	:= 0
Local nPosNumSerie	:= 0
Local lAutomato		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) 
Local lWebServ		:= lAmbOff .OR. lAutomato//Determina se esta sendo executado via Web Service
Local nPosaCols		:= 0
Local lLA590PSC		:= ExistFunc("LA590ProSC")	//Verifica se existe a funcao LA590ProSC (LOJA590.PRW)
Local cMvLjGerSC	:= cValToChar( SuperGetMV("MV_LJGERSC",,1) )	//valor do parametro MV_LJGERSC
Local lNotEstq      := .T.			// Verifica se tem estoque para reservar o produto
Local cDadReserv    := ""           // Variavel para bucar o estoque na SB2
Local lECommerce := SuperGetMV("MV_LJECOMM",,.F.) .And. LJ862ECAuto()
Local nQtdResBkp := 0 //Bakup da quantidade de reserva
Local cNewRes		:= "" //Numero da reserva corrente
//Posicao 1 , numero da reserva
//Posicao 2, numero de produtos		
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local nPosReserva   := 0
Local lIntegDef 	:= (IsInCallStack("LOJA704") .OR. IsInCallStack("LOJI704") .OR. IsInCallStack("M410ESTRE") .OR. IsInCallStack("delete_id_internal") .OR. IsInCallStack("put_id_internal")) .AND. IsBlind()  //Integracao via Mensagem Unica
Local cCliente  	:= ""
Local cResp			:= ""
Local cQnum			:= ""
Local aAreaSC0		:= {}
Local nTamB2COD	 	:= TamSX3("B2_COD")[1]
Local lMV_LJCTRES	:= SuperGetMV("MV_LJCTRES",,.F.)	//Controla quantidade reservada. Não apaga a informação B2_RESERVA mesmo com o parâmetro MV_LJPVLIB=1 
Local nPosEntr		:= 0								// Posicao do Tipo de Entrega
Local lPedSemRes	:= .F.								// Guarda se o pedido é sem Reserva	
Local cTpEntrega	:= ""								// Tipo de entrega
Local nPosicProd	:= 0								// Posição do produto no array aProdutos
Local aAreaSM0		:= SM0->(GetArea())

Default cFilRes	 	:= xFilial("SC0")
Default lCentPDV 	:= .F.			//Determina se foi chamdo da central do POS
Default lECCia   	:= .F.			//Reserva pelo e-commerce CiaShop
Default aNumRes	 	:= {}
Default cXMLRet  	:= ""
Default aHeaderAux  := {}           //Demais campos da SC0 a serem gravados
Default aColsAux    := {}           //Conteúdo dos campos acima da SC0 a serem gravados
Default aProdutos	:= {}			//Contem a relacao de produtos para a rotina de reservas

LjGrvLog( Nil, " Inicio da função Lj7GeraSC0")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aLote:              ³
//³---------------------------------------³
//³[1] - Sublote                          ³
//³[2] - Lote                             ³
//³[3] - Endereco                         ³
//³[4] - Numero Serie                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lWebServ .AND. !lCentPDV .AND. !lECCia .AND. !lIntegDef
	nPosSublote		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NLOTE"})
	nPosLote		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOTECTL"})
	nPosEndereco	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOCALIZ"})
	nPosNumSerie	:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NSERIE"})
	nPosReserva		:= aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_RESERVA"})
	nPosEntr		:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ENTREGA"})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera o valor de cFilAnt para gerar a reserva na filial correta        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAux := cFilAnt
cFilAnt := cFilRes
LjGrvLog(Nil, "Filial onde sera efetuada a reserva (variavel cFilRes): " + cFilRes)

//Atualiza array com aHeader e aCols com os dados necessarios para a rotina de reserva
SX3->( DbSetOrder(2) )
If SX3->( DbSeek("C0_VALIDA ") )

    Aadd(aHeaderAux, {  TRIM( X3Titulo() )  ,;
                        SX3->X3_CAMPO       ,;
                        SX3->X3_PICTURE     ,;
                        SX3->X3_TAMANHO     ,;
                        SX3->X3_DECIMAL     ,;
                        SX3->X3_VALID       ,;
                        SX3->X3_USADO       ,;
                        SX3->X3_TIPO        ,;
                        SX3->X3_ARQUIVO     ,;
                        SX3->X3_CONTEXT     }	)

    //Carrega o acols
    Aadd(aColsAux, dValidade)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o cliente já existe na base de dados. Caso contrario cria un novo registro.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ADEQUAÇÕES DE REGRA PARA USO DO EAI DE RESERVA - LOJI704
if !lIntegDef 
	cCGC := aCliente[nPosCGC][2]
	cFil := aCliente[nPosFil][2]
	dbSelectArea("SA1")
	SA1->(dbSetOrder(3))
	If !(SA1->(dbSeek(cFil+cCGC)))
		nSaveSx8 := GetSx8Len()
		dbSetOrder(1)
		aCliente[nPosCod][2] := GetSx8Num("SA1","A1_COD")
		aCliente[nPosLoja][2] := "01"
		While (GetSX8Len() > nSaveSx8)
			ConfirmSx8()
		End
		Begin Transaction 
		
		RecLock("SA1",.T.)
		For nX := 1 To Len(aCliente)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Os dicionarios das empresas deverao estar identicos, mas foi colocado esse fieldPos |
			//| para garantir que o sistema nao vai 'abendar' caso essa premissa seja falsa.        |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FieldPos(aCliente[nX][1]) > 0
				FieldPut(FieldPos(aCliente[nX][1]),aCliente[nX][2])
			Endif
		Next nX
		SA1->(MsUnlock())
		
		End Transaction 
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reposiciono no SA1 como seguranca para a possibilidade de haver registros com A1_CGC duplicado na base.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+aCliente[nPosCod][2] +aCliente[nPosLoja][2] ))
	
	cCliente  := SA1->A1_COD
	cResp  	  := cUserName
	cQnum	  := M->LQ_NUM
Else
	cCliente  := aCliente[aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="C0_DOCRES" })][2]
	cResp  	  := aCliente[aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="C0_SOLICIT"})][2]
	cQnum     := aCliente[aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="C0_DOCRES" })][2]
	cFilRes   := aCliente[aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="C0_FILRES" })][2]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta a variavel para o controle da a430Reserv()                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lWebServ .OR. lCentPDV .OR. lECCia .OR. lIntegDef
	If !lECCia .AND. !lIntegDef
		cObserv := "Reserva via Web Service - " + STR0036 + cFilAux		//" Filial:"
	ElseIF lIntegDef
		cObserv := "Reserva via EAI - "+ STR0036 + cFilAux	+" - "+ cQnum	//" Filial:"
		aOperacao := {nOpcx,"LJ",cCliente,cResp,cFilRes, cObserv} //"Filial:"
		LjGrvLog(Nil, "Operacao realizada (Legenda: 1=Inclusao; 2=Alteracao; 3=Exclusao)", nOpcx)
		LjGrvLog(Nil, "Conteudo do array aOperacao", aOperacao)
	Else
		cObserv := "Reserva via Rotina automatica LOJA901A - " + STR0036 + cFilAux		//" Filial:"
	EndIf
	if !lIntegDef
		aOperacao := {1,"LJ",cCliente,cResp,cFilSc0, STR0036 + cFilAux} //"Filial:"
	Endif
Else
	aOperacao := {1,"LJ",cCliente,cResp,cFilSc0,STR0035 + cQnum + STR0036 + cFilAux} //"Pedido:"###" Filial:"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Reserva  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX := 1 to Len(aReserva)
	//Verifica se o saldo do produto + a reserva é positivo, caso contrario bloqueia a reserva do produto.
	lNotEstq := .T.
	nQtdResBkp := 0
	SB2->(DbSetOrder(1))

	If Len(aProdutos) > 1
		nPosicProd := aScan( aProdutos, {|x| x[02]+x[03] == aReserva[nX][01]+aReserva[nX][02]} )

		If Len(aProdutos[nPosicProd]) >= 6
			cTpEntrega := aProdutos[nPosicProd][6]
		EndIf
	EndIf
	
	If Len(aReserva[nX]) > 3 .And. Len(aReserva[nX][4]) > 0
		If lIntegDef
			cDadReserv := cFilAnt + PadR(alltrim(aReserva[nX][2]),nTamB2COD) + Alltrim(aReserva[nX][5])
		Else
			cDadReserv := cFilRes + PadR(alltrim(aReserva[nX][2]),nTamB2COD) + Alltrim(aReserva[nX][5])
		Endif
		LjGrvLog(Nil,"Pesquisa na SB2 -> Chave da Pesquisa (Filial + Código do produto + Local/Armazem) :", cDadReserv)
	Else
		If lIntegDef
			cDadReserv := cFilAnt + Alltrim(aReserva[nX][2])
		Else
			cDadReserv := cFilRes + Alltrim(aReserva[nX][2])
		Endif
		LjGrvLog(Nil,"Pesquisa na SB2 -> Chave da Pesquisa (Filial + Código da produto) :" + cDadReserv)
	EndIf

	If SB2->(DbSeek( cDadReserv ))
		LjGrvLog(Nil,"Produto " + SB2->B2_COD + " encontrado na tabela Saldos em Estoque (SB2)")
		If SaldoMov() < aReserva[nX][3]
			If cMvLjGerSC <> "1" //Não valida saldo
				LjGrvLog(Nil, "Não existe estoque suficiente para o produto [" + SB2->B2_COD + "]. Parâmetro de solicitação de compras (MV_LJGERSC) para reserva sem estoque habilitado. Qtde Solicitada" + cValToChar(aReserva[nX][3]))
			Else
				lNotEstq := .F.
				LjGrvLog(Nil, "Não existe estoque suficiente para o produto [" + SB2->B2_COD + "] (Verifique os seguintes campos da tabela SB2: B2_QATU, B2_QACLASS, B2_RESERVA).")
				If lIntegDef
					cXMLRet	:= "Não existe estoque suficiente para o produto [" + SB2->B2_COD + "] (Verifique os seguintes campos da tabela SB2: B2_QATU, B2_QACLASS, B2_RESERVA)."
					cNumero := ""
					Return cNumero
				Endif
			EndIf
		Endif
	Else
		If cMvLjGerSC = "1" //Sem solicitação de compras e/ou compra sem estoque implementado
			lNotEstq := .F.
			LjGrvLog(Nil, "Armazém não localizado para o produto.")
			cXMLRet := "Armazém não localizado para o produto."
			If lIntegDef
				cXMLRet	:= "Armazém não localizado para o produto."
				cNumero := ""
				Return cNumero
			Endif
		EndIf		
	Endif
	
	cNewRes := ""
	
	//Na integracao de Mensagem Unica, caso seja 2=ALTERAÇÃO ou 3=EXCLUSÃO, busca o numero da reserva
	If lIntegDef .AND. (nOpcx == 2 .OR. nOpcx== 3) 
		If aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="C0_NUM" }) >0 
			cNewRes := aCliente[aScan(aCliente,{|x| Alltrim(Upper(x[1]))=="C0_NUM" })][2]
			LjGrvLog(Nil, "Achou o C0_NUM no array aCliente. Vai considerar o numero da reserva" + cNewRes, aCliente)
		Endif
	Else
		//Verifica se ja existe reserva criada para este produto. Caso existir, sera gerado um proximo numero (C0_NUM) para não dar erro de chave duplicada.
		If aScan( aNumRes, { |r| r[3] == aReserva[nX][2]}) > 0
			LjGrvLog(Nil, "Achou uma reserva criada para o produto "+ aReserva[nX][2] + ", entao vai pegar uma nova numeração (C0_NUM) de reserva.")
		Else
			//Retorna a primeira reserva criada
			cNewRes := cNumero
		EndIf
	Endif                     
	
	nSaveSx8 := GetSx8Len()
	
	If Empty(cNewRes) .AND. cTpEntrega <> "5" // Tipo 5 não efetua a reserva, não precisa pegar numeração
		aAreaSC0 := SC0->(GetArea())
		SC0->(DbSetOrder(1)) //C0_FILIAL+C0_NUM+C0_PRODUTO
		While Empty(cNewRes) .Or. SC0->(DbSeek(xFilial("SC0")+cNewRes))
			cNewRes := GetSx8Num("SC0","C0_NUM")
			LjGrvLog(Nil, "Pegou o proximo C0_NUM: " + cNewRes + " da Filial: " + cFilAnt)
		End
		cNumero := cNewRes
		RestArea(aAreaSC0)
	EndIf
	
	LjGrvLog(Nil, "Numero da Reserva que sera gerada: " + cNewRes)
	
	//Esse processo é ncessário para que seja possível
	//efeutar a alteração ou exclusão com segurança.
	If lIntegDef   .AND. (nOpcx == 2 .OR. nOpcx== 3)
		SC0->(DbSetOrder(1))	// C0_FILIAL+C0_NUM+C0_PRODUTO+C0_LOCAL
		If SC0->(MsSeek( xFilial("SC0")+cNewRes+aReserva[nX][2]+aReserva[nX][5] ))
			LjGrvLog(Nil, "Achou o Registro ja existente na SC0 - ponto 1 (dados: SC0->C0_FILIAL,SC0->C0_NUM,SC0->C0_PRODUTO,SC0->C0_LOCAL)", {SC0->C0_FILIAL,SC0->C0_NUM,SC0->C0_PRODUTO,SC0->C0_LOCAL})
		    SC0->( RecLock("SC0",.F.)  )    //Se o Alias atual for o SC0, quando tiver mais de dois produtos ira alterar os valores sempre do segundo produto pois o a430Reserv() utiliza o RestArea().
			    	SC0->C0_QUANT   := SC0->C0_QTDORIG
					SC0->C0_QTDPED  := 0					
			SC0->(MsUnlock())
		Endif
	Endif
	
	If !lECCia  .AND. !lIntegDef               	
		// Pociona pelo numero do item gravado no array aReserva
		nPosaCols := aScan( aColsDet, {|x| Alltrim(x[1])==aReserva[nX][1]})
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Atualizando o array aLote                                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lWebServ .AND. !lIntegDef .And. !lECCia	
		If lFtvdVer12 .Or. (!lFtvdVer12 .And. !lCentPDV .And. !IsBlind())
			aLote := {aColsDet[nPosaCols][nPosSublote] ,;
					  aColsDet[nPosaCols][nPosLote]    ,;				  				  				  
					  aColsDet[nPosaCols][nPosEndereco],;
					  aColsDet[nPosaCols][nPosNumSerie]}

			lPedSemRes := aCols[nPosaCols][nPosEntr] == "5"

		ElseIf IsBlind()		
			aLote := {aColsDet[nPosaCols][nPosSublote] ,;
					  aColsDet[nPosaCols][nPosLote]    ,;
					  aColsDet[nPosaCols][nPosEndereco],;			
					  aColsDet[nPosaCols][nPosNumSerie]}
		EndIf
	EndIf
	
	// Se for central do POS OU CIASHOP e pega o Lote do aReservas  
	If ( lCentPDV  .OR. lECCia ) .AND. Len( aReserva[nX][6] ) > 0 .OR. lIntegDef
		aLote := aClone(aReserva[nX][6])
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a reserva no SC0                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Se o item for Tipo Entrega == "5", não gera Reserva
	If lNotEstq	.AND. !lPedSemRes
		If lIntegDef
			If nPosaCols > 0 .And. nPosReserva > 0 .And. Empty(aColsDet[nPosaCols][nPosReserva])
				aColsDet[nPosaCols][nPosReserva] := cNewRes
			EndIf			
		EndIf
		
		LjGrvLog(Nil, "Conteudo da variavel aOperacao que sera enviada para a funcao de reserva A430Reserv()", aOperacao)
		LjGrvLog(Nil, "Conteudo da variavel aReserva que sera enviada para a funcao de reserva A430Reserv()", aReserva)
		LjGrvLog(Nil, "Conteudo da variavel aLote que sera enviada para a funcao de reserva A430Reserv()", aLote)
		LjGrvLog(Nil, "Conteudo da variavel aHeaderAux que sera enviada para a funcao de reserva A430Reserv()", aHeaderAux)
		LjGrvLog(Nil, "Conteudo da variavel aColsAux que sera enviada para a funcao de reserva A430Reserv()", aColsAux)
		
		lRet := a430Reserv(aOperacao,;
							cNewRes,;				// Numero da reserva 
							aReserva[nX][2],;		// Produto da reserva
							aReserva[nX][5],; 		// Armazem da reserva 
							aReserva[nX][3],;		// Quantidade a ser reservada
							aLote,;
							aHeaderAux,;
							aColsAux,;
							NIL,;
							.T.)
		
		LjGrvLog( cNewRes, " Retorno da Execução de a430Reserv", lRet)
		
		If nQtdResBkp > 0
			aReserva[nX][3] := nQtdResBkp //Restaura quantidade a ser reservada original
		EndIf															
	Else
		lRet := .F.
	Endif
	
	If lRet
		//Gera a numeração de reserva gerada para o produto
		aAdd(aNumRes, { aReserva[nX][1], cNewRes, aReserva[nX][2]})
	EndIf
	
	/* 
		***********************************************************
		Vincula a reserva ao orçamento para que nao seja manipulada
		pelo programa Controle de Reservas (MATA340).               
		Procedimento tambem utilizado para amarracoes entre pedidos  
		(SC6) e reservas (SC0) no modulo de faturamento            
		**********************************************************
	*/
	If lRet .And. !lECCia
		SC0->(DbSetOrder(1))	// C0_FILIAL+C0_NUM+C0_PRODUTO+C0_LOCAL
		If SC0->(MsSeek( xFilial("SC0")+cNewRes+aReserva[nX][2]+aReserva[nX][5] ))
			/*Se o Alias atual for o SC0, quando tiver mais de dois produtos ira alterar
			 os valores sempre do segundo produto pois o a430Reserv() utiliza o RestArea().*/
		    SC0->( RecLock("SC0",.F.)  )    
			
			/*
				Altero o C0_QUANT somente se parâmetro com "1", pois quando com "2" existe
				uma reserva associada (C6_RESERVA) e ao faturar (no Modulo do Faturamento)
				é capturado	o valor desse campo é capturado para zerar a SB2 (B2_QPEDVEN)			
			*/
			If SuperGetMv("MV_LJPVLIB",,"1") == "1"
				If !lMV_LJCTRES
					SC0->C0_QUANT  -= aReserva[nX][3]
					LjGrvLog( cNewRes , "Parâmetro MV_LJPVLIB com 1, portanto pedido será gerado liberado")

				// Caso o parâmetro MV_LJPVLIB esteja como 2 o campo C0_QTDPED só será atualizado pela função MaAvalSC6 quando o pedido tiver sido gerado
					If lIntegDef .AND. (nOpcx == 2 .OR. nOpcx== 3)
						SC0->C0_QTDPED := aReserva[nX][3]				
					Else	    		
						SC0->C0_QTDPED += aReserva[nX][3]
					Endif
				EndIf
			EndIf
	
			If lLjVfe
				//#VFE
				//Altera o campo C0_FILRES para a filial mais proxima do cliente.
				//Essa filial mais proxima do cliente e a responsavel por estar solicitando a reserva.			
				SC0->C0_FILRES := cLojRes
				cLojRes := ''		
			EndIf
			
	    	SC0->(MsUnLock())
	    Else
	    	LjGrvLog( cNewRes , " Controle de Reserva não Encontrado - Indice Pesquisado [" + xFilial("SC0")+cNewRes+aReserva[nX][2]+aReserva[nX][5] + "]")
	  	EndIf
  	ElseIf !lRet
  		LjGrvLog(cNewRes, " Reserva Número [" + cNewRes + "] não foi gerada na tabela SC0 - Controle de Reservas")
		If Len(aReserva) = 1
			cNumero := "" //Apaga o numero da reserva pois não criou
			cNewRes := ""
		EndIf
  	Endif

  	//Comita o uso do Numero Sequencial da SC0
	If lRet 
		While (GetSX8Len() > nSaveSx8)
			ConfirmSx8()
			LjGrvLog(Nil, "Executando o ConfirmSx8 para comitar a numeracao automatica do campo C0_NUM")
		End

		// Efetua o LockByName referente a esta reserva
		If GetApoInfo("LOJA701.PRW")[4] >= CtoD("25/04/2019") 
			LjLockRes( cFilRes, cQnum, cNumero )
		EndIf
	EndIf

	//³ Verifica se usa reserva sem estoque                    ³
	//³ Para eCommerce devera gerar a solicitacao de compras.  ³	
	If lLA590PSC .AND. ((cMvLjGerSC $ "2|3") .OR. lECommerce) .And. !lECCia
		//Chama funcao para incluir o produto na SC 
		LjGrvLog( cNewRes , " Antes da Execução da Função LA590ProSC ") 
    	LA590ProSC(aReserva, nX, cFilRes)
    	LjGrvLog( cNewRes , " Depois da Execução da Função LA590ProSC ")
    Endif

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Volta o valor original de cFilAnt                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilAux

RestArea(aAreaSM0)

Return cNumero

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7ConsResºAutor  ³Vendas Clientes     º Data ³  01/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a consulta das reservas nas lojas da rede            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void Lj7ConsRes( ExpA1, ExpC1, ExpC2 )                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA2 - Array contendo:                                     º±±
±±º          ³        [1] - .F.                                           º±±
±±º          ³        [2] - Codigo da loja                                º±±
±±º          ³        [3] - Nome da loja                                  º±±
±±º          ³ExpC1 - Codigo do cliente                                   º±±
±±º          ³ExpC2 - Codigo da loja do cliente                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7ConsRes( aLojas, cCliente, cLoja )
Local nX			:= 0
Local lCancelar		:= .F.
Local cGetCliente	:= ""
Local cMsg 			:= ""
Local cObs			:= ""
Local aConsulta		:= {}
Local aReservas 	:= {}
Local aRet 			:= {}

Local oOk 			:= LoadBitmap(GetResources(), "LBOK")
Local oNo 			:= LoadBitmap(GetResources(), "LBNO")
Local oDlgConsulta
Local oConsulta
Local lCentPDV		:= LjGetCPDV()[1]	// Central de PDV 
Local lContinua		:= .F. 				// Controle Execucao
Local nTamObs		:= 150				// Tamanho do campo Observação

Default cCliente 	:= SA1->A1_COD
Default cLoja		:= SA1->A1_LOJA

If lCentPDV

	// Central de PDV - Realizado via componente de comunicacao  
	lContinua := STBRemoteExecute("Lj7CsResDB", { aLojas , cCliente , cLoja } , NIL, .F. , @aConsulta )

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consulta as reservas                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SC0->(dbSetOrder(1))
	SLJ->(dbSetOrder(1))
	For nX := 1 to Len( aLojas )
		If SLJ->(DbSeek(xFilial("SLJ")+aLojas[nX][2]))
			DbSelectArea("SC0")
			DbSeek(SLJ->LJ_RPCFIL)
			While !Eof() .And. SC0->C0_FILIAL == SLJ->LJ_RPCFIL
				If SC0->C0_TIPO == "LJ" .And. AllTrim( SC0->C0_DOCRES ) == AllTrim( cCliente )
					cObs := SC0->C0_OBS

					If Len(AllTrim(cObs)) > 40
						nTamObs := 300
					EndIf

					aAdd( aConsulta, { .F.,; 						// Controle do listbox
										SLJ->LJ_CODIGO,;			// Codigo da loja
										Trim(SLJ->LJ_NOME),;		// Nome da loja
										SC0->C0_PRODUTO,;			// Codigo do produto
										Posicione("SB1",1,xFilial("SB1")+SC0->C0_PRODUTO,"B1_DESC"),;	// Descricao do produto
										SC0->C0_QTDORIG,;			// Quantidade da reserva
										SC0->C0_NUM,;				// Codigo da reserva
										SC0->C0_EMISSAO,;			// Data de emissao da reserva
										SC0->C0_VALIDA,;			// Data da validade do orcamento
										SC0->C0_LOCAL,; 			// Local (armazem) onde esta reservado o produto
										cObs } )					// Observacao 
				Endif
				SC0->(dbSkip())
			End
		Endif
	Next nX

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela para informar ao usuario as reservas para o cliente           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aConsulta)
	cGetCliente := SA1->A1_COD + " - " + SA1->A1_NOME
	DEFINE MSDIALOG oDlgConsulta TITLE STR0037 FROM 0,0 TO 300,490 PIXEL OF oDlgVA  //"Consulta Reservas"
	@ 10,8 SAY OemToAnsi(STR0038) PIXEL OF oDlgConsulta //"Cliente:"
	@ 10,30 MSGET oCliente VAR cGetCliente WHEN .F. SIZE 130,08 PIXEL OF oDlgConsulta

	@ 25,8 LISTBOX oConsulta FIELDS HEADER "",STR0018,STR0039,STR0040,STR0041,STR0042,STR0043,STR0044; //"Loja"###"Produto"###"Qtd"###"Reserva"###"Emissão"###"Validade"###"Observação"
	FIELDSIZES 14,60,90,30,40,35,40,nTamObs,120 SIZE 230,100 PIXEL FONT aFontes[3] OF oDlgConsulta
	
	oConsulta:SetArray(aConsulta)      
	oConsulta:bLDblClick := {|| (aConsulta[oConsulta:nAt,1] := !aConsulta[oConsulta:nAt,1]) }
	oConsulta:bLine := {|| { Iif(aConsulta[oConsulta:nAt,1],oOk,oNo),aConsulta[oConsulta:nAt,3],;
	Alltrim(aConsulta[oConsulta:nAt,4])+"-"+Alltrim(aConsulta[oConsulta:nAt,5]),;
	aConsulta[oConsulta:nAt,6],aConsulta[oConsulta:nAt,7],;
	aConsulta[oConsulta:nAt,8],aConsulta[oConsulta:nAt,9],;
	aConsulta[oConsulta:nAt,11] }}

	@ 133,210 BUTTON STR0045     PIXEL SIZE 32,14 ACTION oDlgConsulta:End() OF oDlgConsulta //"Sair"

	ACTIVATE MSDIALOG oDlgConsulta CENTERED
Else
	Aviso( STR0008, STR0046, {STR0009} ) //"Atenção"###"Não há reservas para este cliente."###"Ok"
Endif	

If lCancelar
	aReservas := {}
	For nX := 1 To Len(aConsulta)
		If aConsulta[nX][1]
			aAdd(aReservas, {	aConsulta[nX][7],;		// Codigo da reserva 
								aConsulta[nX][2],;		// Codigo da loja
								aConsulta[nX][4],;		// Codigo do produto
								aConsulta[nX][10] })	// Local (armazem) da reserva
		Endif
	Next nX
	
	If !Empty(aReservas)
		aRet := Lj7CancRes( aReservas )
		cMsg := ""
		For nX := 1 to Len(aRet)
			If !aRet[nX][2]
				cMsg := cMsg + aRet[nX][1] + ", "
			Endif		
		Next nX
		
		If !Empty(cMsg)
			Aviso( STR0008, STR0047 + Substr(cMsg,1,Len(cMsg)-2) + STR0048, {STR0009} ) //"Atenção"###"A reserva "###" não puderam ser canceladas."###"Ok"
		Else
			Aviso( STR0008, STR0049, {STR0009} ) //"Atenção"###"A reserva foi cancelada."###"Ok"
		Endif
	Else
		Aviso( STR0008, STR0050, {STR0009} )  //"Atenção"###"Não foi escolhida nenhuma reserva para cancelamento."###"Ok"
	Endif
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7CancResºAutor  ³Vendas Clientes     º Data ³  17/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz o cancelamento das reservas.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1 := Lj7CancRes( ExpA2 )                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA2 - Array contendo:                                     º±±
±±º          ³        [1]-Numero da Reserva                               º±±
±±º          ³        [2]-Codigo da Loja                                  º±±
±±º          ³        [3]-Codigo do Produto                               º±±
±±º          ³        [4]-Local (Armazem)                                 º±±
±±º          ³        [5]-Filial da reserva (Obrigatório se nao informar  º±±
±±º          ³            o codigo da loja                                º±±
±±º          ³        [6]-Array com o Lote                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array contendo:                                     º±±
±±º          ³        [1]-Numero da reserva                               º±±
±±º          ³        [2]-.T./.F. Se consegiu ou nao fazer o cancelamento º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7CancRes( aReserva ,lJob, lCentPDV, lECCia, lDelReserv, cCodOrcam )
Local aArea 		:= GetArea()
Local aAreaSl2		:= SL2->(GetArea())
Local aAreaSM0		:= SM0->(GetArea())
Local aRet 			:= {}
Local aOperacao 	:= {3,"LJ","",cUserName,cFilAnt}	// Variavel para utilizacao da funcao de reservas
Local aLote 		:= {"","","",""}					// Variavel para utilizacao da funcao de reservas
Local nX 			:= 0
Local lCancela 		:= .F.
Local cFilAux 		:= cFilAnt
Local cFilTrab		:= ""
Local lRecLote		:= lAmbOff							// Verifica se recebeu as informacoes de Lote
Local nPosSublote	:= 0								// Posicao Sub Lote
Local nPosLote		:= 0								// Posicao Lote
Local nPosEndereco	:= 0								// Posicao Endereco
Local nPosNumSerie	:= 0								// Posicao Numero Serie
Local lCancReser	:= .T.

Default lJob		:= .F.
Default lCentPDV	:= .F.								// Esta Habilitado o Modo central do POS
Default lECCia 		:= .f.
Default lDelReserv	:= .F. 								// Indica de deve Deletar a reserva e tirar LockByName
Default cCodOrcam	:= ""								// Codigo do orçamento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aLote:              ³
//³---------------------------------------³
//³[1] - Sublote                          ³
//³[2] - Lote                             ³
//³[3] - Endereco                         ³
//³[4] - Numero Serie                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob .AND. !lCentPDV .and. !lECCia
	nPosSublote	 := aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NLOTE" })
	nPosLote	 := aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOTECTL" })
	nPosEndereco := aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_LOCALIZ" })
	nPosNumSerie := aScan(aHeaderDet,{|x| Alltrim(Upper(x[2]))=="LR_NSERIE" })	
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloca o array em ordem de lojas                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aReserva,,,{|a,b| a[2] < b[2]})

LjGrvLog(cCodOrcam, "Executando o cancelamento de reserva(s)", aReserva)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Varre o array de reservas e faz o cancelamento                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SLJ->(DbSetOrder(1))
For nX :=1  to Len( aReserva )
	cFilTrab := ""
	If Len(aReserva[nX]) >= 5 .And. !Empty(aReserva[nX][5])
		cFilTrab := aReserva[nX][5]
	Else
		If SLJ->(dbSeek(xFilial("SLJ")+aReserva[nX][2]))
			cFilTrab := SLJ->LJ_RPCFIL
		Endif
	Endif
	
	If !Empty(cFilTrab)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Altera o valor de cFilAnt para o cancelamento da reserva na filial correta          |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilAnt := cFilTrab

		//---------------------------------------------------------------------------------------------------------------------------
		// Verifica se pode cancelar a Reserva, conforme o controle de Semáforo.
		// Evitando assim que sejam excluidas indevidamente Reservas que ainda estão sendo feitas no momento com o orçamento em tela
		//---------------------------------------------------------------------------------------------------------------------------
		If !Empty(cCodOrcam)
			lCancReser := LjLockRes( aReserva[nX][5], cCodOrcam, aReserva[nX][1] )
		Else
			lCancReser := .T.
		EndIf

		LjGrvLog(cCodOrcam, "Permite prosseguir com o cancelamento da reserva?", lCancReser)

		If lCancReser
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Vincula a reserva ao orçamento para que nao seja manipulada   ³
			//³ pelo programa Controle de Reservas (MATA340).                 ³
			//³ Procedimento tambem utilizado para amarracoes entre pedidos   ³
			//³ (SC6) e reservas (SC0) no modulo de faturamento               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SC0->(DbSetOrder(1))	// C0_FILIAL+C0_NUM+C0_PRODUTO+C0_LOCAL
			If SC0->(DbSeek( xFilial("SC0")+aReserva[nX][1]+aReserva[nX][3]+aReserva[nX][4] ))
				SC0->(RecLock("SC0",.F.))
				SC0->C0_QUANT  += SC0->C0_QTDPED
				SC0->C0_QTDPED -= SC0->C0_QUANT
				SC0->(MsUnlock())

				LjGrvLog(cCodOrcam, "Atualiza tabela SC0")

				// Exclui Solicitacao de Compra caso exista
				If ExistFunc("Lj7DelSC1")
					LjGrvLog(cCodOrcam, "Exclui Solicitacao de Compra caso exista")
					Lj7DelSC1(cCodOrcam,  aReserva[nX][2], aReserva[nX][3], SC0->C0_QUANT) // Orçamento, Filial, Produto, Quantidade
				EndIf
			Endif

			If lCentPDV
				aLote := aClone(aReserva[nX][7])
			ElseIf lJob 
				SL2->(DbSetOrder(5))
				If SL2->(DbSeek(xFilial("SL2")+ aReserva[nX][1]+aReserva[nX][2]+aReserva[nX][3]+aReserva[nX][6])) //FILIAL+RESERVA+LOJA RESERVA+PRODUTO+ITEM
					aLote := {SL2->L2_NLOTE,;
							SL2->L2_LOTECTL,;
							SL2->L2_LOCALIZ,;
							SL2->L2_NSERIE}
				Endif		
			Else
				If !lRecLote
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|Atualizando o array aLote                                                            |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aLote := {aColsDet[nX][nPosSublote]		,;
						aColsDet[nX][nPosLote]    	,;
						aColsDet[nX][nPosEndereco]	,;
						aColsDet[nX][nPosNumSerie]	}
				EndIf
			EndIf

			//---------------------------------------
			// Chama a funcao para cancelar a Reserva
			//---------------------------------------
			lCancela 	:= a430Reserv(aOperacao,aReserva[nX][1],aReserva[nX][3],aReserva[nX][4],0,aLote,{},{})
			LjGrvLog(cCodOrcam, "Retorno da função (a430Reserv) de cancelamento de Reserva", lCancela)
			aAdd( aRet, { aReserva[nX][1], lCancela , aReserva[nX][2] , aReserva[nX][3] , aReserva[nX][6] } )
			SC0->(MsUnLock())

			LjULockRes( aReserva[nX][5], cCodOrcam, aReserva[nX][1] )
		EndIf

	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloca o array em ordem de lojas                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilAux

RestArea(aArea)
RestArea(aAreaSl2)
RestArea(aAreaSM0)

LjGrvLog(cCodOrcam, "Retorno da função de cancelamento de reserva (Lj7CancRes)", aRet)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA701E  ºAutor  ³Vendas Clientes     º Data ³  08/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ira limpar os dados do orcamento quando não tiver mais  re-º±±
±±º          ³ serva                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1 := Lj7AtuResOrc( ExpN1 )                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Numero do orcamento a ser verificado                º±±
±±º          ³ExpL1 - Define se deleta todos as reservas                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7AtuResOrc (cOrcamento, lApaga)

Local nConta		:= 0
Local aArea			:= Lj7GetArea({"SL1","SL2","SL4"})
Local nPosItem		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]				// Posicao do numero do item
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]			// Posicao do codigo do produto
Local nPosDtReserva	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_RESERVA"})	// Posicao do codigo da reserva
Local lReserva	:= .F. 

Default cOrcamento 	:= M->LQ_NUM
Default lApaga			:= .F.

DBSelectArea("SL1")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0¿
//³Verifica se o orcamento ja foi Salvo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0Ù
If !DbSeek(xFilial("SL1")+cOrcamento)
	Lj7RestArea(aArea)
	Return .T.
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe reserva no orcamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(SL1->L1_RESERVA)
	Lj7RestArea(aArea)
	Return .T.
EndIf


For nConta := 1 to Len(aCols)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o produto foi informado e se possui reserva³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aColsDet[nConta][nPosProd]) .And. (Empty(aColsDet[nConta][nPosDtReserva]) .OR. lApaga)

		DbSelectArea("SL2")
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura o item ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DbSeek(xFilial("SL2") + cOrcamento + AllTrim(aColsDet[nConta][nPosItem]))
			If !Empty(SL2->L2_RESERVA)

				RecLock("SL2", .F.)
					Replace SL2->L2_RESERVA With ""
					Replace SL2->L2_LOJARES With ""			
				SL2->(MsUnlock())

			EndIf
		EndIf
	Else
		lReserva := .T.
	EndIf
	
	
Next nConta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄL¿
//³Caso tenha sido identificado que nao existem reservas nos itens ³
//³devera limpar a reserva do pai                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄLÙ
If !lReserva           
	If DbSeek(xFilial("SL1")+cOrcamento)	
		RecLock("SL1", .F.)
			Replace SL1->L1_RESERVA With ""
		SL1->(MsUnLock())
	EndIf	
EndIf

Lj7RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjPedVen  ºAutor  ³Vendas Clientes     º Data ³  18/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se esta preparado para gerar Pedidos de Venda.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 - Valida a utilizacao dos Pedidos de Venda.          º±±
±±º		 	 ³ 														      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjPedVen(lScreen)
Local lLjPedVe		:= SuperGetMV("MV_LJPEDVE", NIL, .F.)			//Verifica se utiliza geracao de PV
Local lCondPed		:= !Empty(SuperGetMV("MV_LJCONDP", NIL, ""))	//Condicao de Pagamento para geracao do Pedido de Venda
Local lTESPed		:= !Empty(SuperGetMV("MV_LJTESPE", NIL, ""))	//TES padrao para geracao do Pedido de Venda
Local lRet			:= .F.											//Retorno da Funcao

Default lScreen		:= .T.											//Determina se deve exibir a tela de Erro

If lLjPedVe .AND. lCondPed .AND. (lTESPed .or. Lj701GtInD() ) // Se for integração não realiza a validação do parametro MV_LJTESPE
	lRet	:= .T.
EndIf

If !lRet .AND. lScreen
	
	If Type("lAutoExec") <> "L" .OR. !lAutoExec 
		MsgAlert(STR0054) //"Para utilizar a Opção 'Entrega' do campo LR_ENTREGA, configure os parâmetros conforme documentação no TDN."
	Else
		Conout(STR0054) //"Para utilizar a Opção 'Entrega' do campo LR_ENTREGA, configure os parâmetros conforme documentação no TDN."
        LjGrvLog("LjPedVen",STR0110 + "https://tdn.totvs.com/pages/releaseview.action?pageId=552590004", {lLjPedVe,lCondPed})
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVldEnt  ºAutor  ³Vendas Clientes     º Data ³  21/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o tipo de Entrega pode ser alterado.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 - Valida se pode alterar o tipo de Entrega           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVldEnt()
Local nPosReser	:= Ascan(aPosCpoDet, {|x| Alltrim(Upper(x[1])) == "LR_RESERVA"})	// Posicao do Codigo da Reserva
Local nPosProd	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_PRODUTO" })		// Posicao do Produto
Local nPosCont	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_CODCONT" })		// Posicao do Contato
Local lRet		:= .T.																// Retorno da Funcao
Local lLjAltEn	:= SuperGetMV("MV_LJALTEN", NIL, .F.)								// Verifica se deve permitir a alteracao do Tipo de Entrega apos a Reserva dos Produtos

If LjPedVen()
	If !Empty(aCols[n][nPosProd])
		If !lLjAltEn .AND. !Empty(aColsDet[n][nPosReser])
			//Este campo não pode ser alterado após a confirmação da Reserva. Para excluir a reserva efetue a exclusão do item.
			MsgAlert(STR0055)
			lRet := .F.
		EndIf
		If lRet .AND. nPosCont > 0 .AND. !Empty(aCols[n][nPosCont])
			aCols[n][nPosCont] := Space(TamSX3("LR_CODCONT")[1])
		EndIf
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7Turno  ºAutor  ³Vendas Clientes     º Data ³  21/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe a tela para a escolha do dia e turno de entrega.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ -														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7Turno()

Local nPosTurn	 := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_TURNO"})			// Posicao do codigo da reserva
Local nPosCont	 := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_CODCONT" })][2]	// Posicao do Contato
Local nPosDtEntr := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_FDTENTR"	})][2] 	// Posicao do Contato
Local nPosDescri := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESCRI"	})][2]	// Posicao da codigo do produto
Local nPosItem 	 := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ITEM"	})][2]	// Posicao do Item
Local nPosProd	 := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do codigo do produto
Local nPosEntr 	 := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ENTREGA"	})][2]	// Posicao do Item
Local aProds	 := {}
Local nX		 := 0
Local nY		 := 0
Local lRet		 := .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando for Protheus Start nao executa Reserva(F11), logo nao executa Periodo de Entrega (CTRL+H)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __lPyme
	Aviso(STR0008, STR0057, {STR0009}) // "Atencao", "Rotina não disponivel para o Protheus Start." , "Ok"
	Return
EndIf                                                                                                   

If ( Len(aCols) == 1 ) .And. ( aTail( aCols[1] ) .Or. Empty(aCols[1][nPosProd]) )
	Aviso( STR0008, STR0058, {STR0009} ) //"Atenção"###"Não há produtos lançados."###"Ok"
	lRet		 := .F.
Else									
	For nX := 1 to Len(aCols)
		If !aCols[nX][Len(aCols[nX])] .AND. aCols[nX][nPosEntr] == "3"
		    aAdd( aProds, { .F.						,;
	   	    	aCols[nX][nPosItem]	 				,;		// ITEM
		    	aCols[nX][nPosDescri]				,;      // DESCRICAO
		    	aCols[nX][nPosDtEntr]				,;      // ENTREGA
	   	    	Lj7GetTurn(aColsDet[nX][nPosTurn])	,; 	    // TURNO
	    		aCols[nX][nPosCont]	   				})      // CONTATO
		EndIf
	Next nX
EndIf	

If Len(aProds) > 0
	Lj7SelTurn(@aProds)
ElseIf lRet	
	Aviso( STR0008, STR0059, {STR0009} ) //"Atenção"###"Não há produtos lançados."###"Ok"	
EndIf

For nX := 1 to Len(aCols)
	For nY := 1 to Len(aProds)
	    If aCols[nX][nPosItem] == aProds[nY][IT_NITEM]
	   		If !Empty(aProds[nY][IT_DTENTR])		  	
			  	aCols[nX][nPosDtEntr]	:= aProds[nY][IT_DTENTR] 			// ENTREGA
			EndIf  	
	   		If !Empty(aProds[nY][IT_TURNO])		  	
		   		aColsDet[nX][nPosTurn]	:= SubStr(aProds[nY][IT_TURNO],1,1)	// TURNO
		   	EndIf	
	   		If !Empty(aProds[nY][IT_CONTATO])
	   			aCols[nX][nPosCont]	   	:= aProds[nY][IT_CONTATO] 			// CONTATO
	   		EndIf	
   		EndIf	
   	Next nY
Next nX

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7SelTurnºAutor  ³Vendas Clientes     º Data ³  21/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe a tela para a escolha do dia e turno de entrega.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ -														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7SelTurn(aProds)

Local oDlgPeriodo
Local oListPro
Local oOk 			:= LoadBitmap(GetResources(), "LBOK")
Local oNo 			:= LoadBitmap(GetResources(), "LBNO")
Local lTodosProd	:= .F.
Local nVarQ			:= 0
Local dNewData 		:= dDatabase	
Local cTurno		:= Space(10)
Local aTurnos		:= {STR0060,STR0061,STR0062} //"Manha"#"Tarde"#"Noite"
Local oTodosProd 			// Objeto CheckBox
Local oComboList			// Objeto ComboBox dos Turnos
Local oFnt1					// Fonte do texto
Local cContato		:= Space(10)// Contato para a entrega
Local oBtRef				// Botao atualizar na tela
Local oddata
Local oCont

		DEFINE FONT oFnt1 NAME "Arial" SIZE 8.5,14 BOLD // Largura x Altura

		DEFINE MSDIALOG oDlgPeriodo TITLE STR0063 FROM 0,0 TO 330,500 PIXEL OF oDlgVA 

		@ 5,07 TO 35, 247 LABEL "" OF oDlgPeriodo PIXEL	
		@08,19 SAY STR0064 PIXEL COLOR CLR_BLUE FONT oFnt1 OF oDlgPeriodo // "Selecione os Produtos abaixo para depois altera-los"

		SET DATE FORMAT "dd/mm/yy"
		@21,11 SAY STR0065 PIXEL // "DATA :"
		@20,28 MSGET oddata VAR dNewData PIXEL SIZE 40,09 CENTER

		@21,72 SAY STR0066 PIXEL // "PERIODO:"
		@20,97 COMBOBOX oComboList VAR cTurno ITEMS aTurnos SIZE 35,27	OF oDlgPeriodo PIXEL 
		
		@21,134 SAY STR0067 PIXEL // "Contato :" 		
		@20,157 MSGET oCont VAR cContato F3 "CNTLJ" SIZE 36,09 PICTURE PesqPict("SLR","LR_CODCONT") OF oDlgPeriodo PIXEL
		
	    oBtRef := TButton():New( 19, 199, STR0076,oDlgPeriodo,{||Lj7AtualDt(dNewData,@aProds,cTurno,cContato),oListPro:Refresh()},;
                   40,11.5,,,.F.,.T.,.F.,,.F.,,,.F. )

		@ 34,07 TO 145, 247 LABEL "" OF oDlgPeriodo PIXEL	// "% Desconto"
		
		@ 39,12 LISTBOX oListPro VAR nVarQ FIELDS HEADER "",STR0069,STR0070,STR0071,STR0072,STR0073 FIELDSIZES 14,15,100,30,24 SIZE 230,100 PIXEL OF oDlgPeriodo //"Loja" //
		
		oListPro:SetArray(aProds)
		oListPro:bLDblClick := {|| (aProds[oListPro:nAt,1] := !aProds[oListPro:nAt,1] , dNewData := aProds[oListPro:nAt,4] ,oddata:Refresh() )}
		oListPro:bLine := {|| {If(aProds[oListPro:nAt,1],oOk,oNo),aProds[oListPro:nAt,2],aProds[oListPro:nAt,3],;
								  aProds[oListPro:nAt,4]	, aProds[oListPro:nAt,5]	,aProds[oListPro:nAt,6] }}
				                                                                  
		@ 149,12 CHECKBOX oTodosProd VAR lTodosProd PROMPT STR0074 SIZE 53,8 PIXEL OF oDlgPeriodo; //"Selecionar Todas"
		ON CHANGE {|| aEval(aProds,{|x| x[1]:= lTodosProd }),oListPro:Refresh() }
		

		DEFINE SBUTTON FROM 150, 175 TYPE 1 ACTION ( Lj7AtualDt(dNewData,@aProds,cTurno,cContato),oDlgPeriodo:End()) ENABLE PIXEL OF oDlgPeriodo
		DEFINE SBUTTON FROM 150, 205 TYPE 2 ACTION oDlgPeriodo:End() ENABLE PIXEL OF oDlgPeriodo
		
		ACTIVATE MSDIALOG oDlgPeriodo CENTERED
		
Return(aProds)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7AtualDtºAutor  ³Vendas Clientes     º Data ³  21/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe a tela para a escolha do dia e turno de entrega.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ -														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj7AtualDt(dDataEnt,aProds,cTurno,cContato)
  
Local lRet 	:= .T.
Local nX	:= 0

If !Empty(dDataEnt) .AND. !Empty(cTurno)
	If dDataEnt < dDatabase		// Verifica a integridade da data
		MsgStop(STR0075)	// "Data para Entrega Invalida"
		lRet 	:= .F.
   	EndIf                           
   
   	If lRet
		For nX := 1 to Len(aProds)
			If aProds[nX][IT_MARCADO]
				aProds[nX][IT_MARCADO] 	:= .F.	            
				aProds[nX][IT_DTENTR] 	:= dDataEnt	// ENTREGA
				aProds[nX][IT_TURNO] 	:= cTurno   // TURNO
				If !Empty(cContato)
					aProds[nX][IT_CONTATO] 	:= cContato	// CONTATO
				EndIf	
	 		EndIf
		Next nX
		aProds := aSort(aProds,,,{|x,y| x[4]<y[4]})
	Endif
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7GetTurnºAutor  ³Vendas Clientes     º Data ³  21/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pega a descricao do turno escolhido para a entrega   .     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj7GetTurn(cTurno)

Local cDescTurn	:= ""

Default cTurno		:= "M"

Do Case
	Case AllTrim(cTurno) == "M"
		cDescTurn	:= STR0060 //"Manhã"
	Case AllTrim(cTurno) == "T"
		cDescTurn	:= STR0061 //Tarde
	Case AllTrim(cTurno) == "N"
    	cDescTurn	:= STR0062 //"Noite"
Endcase

Return(cDescTurn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7LoadShopºAutor  ³Vendas Clientes    º Data ³  02/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega qual sera o CD da loja mais proxima do cliente     º±±
             ³ para reservar o produto                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj7LoadShop()

Local aRet 		:= {} 	//Variavel de retorno
Local cCep 		:= '' 	//Cep para a pesquisa da loja proxima ao endereco de entrega do cliente
Local aSaldo		:= {} 	//Array que carrega do saldo em estoque do produto
Local cQuery		:= ''	//Variavel para execucao de query
Local lEofMf6		:= .F.	//Variavel que verifica se tem ou nao registro na MF6
Local cLoja		:= ''	//Recebe o codigo da loja mais proxima do endereco do cliente
Local cLocalEst	:= ''	//Local de estoque
Local cAliasMF6	:= 'RESERMF6'	//Alias da tabela MF6
Local nPosProd	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do codigo do produto
Local nPosClient	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CLIENT"})][2]	// Posicao do codigo do cliente
Local nPosCliLoja	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CLILOJA"})][2]	// Posicao do codigo da loja
Local nPosFilPed	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_FILPED"})][2]	// Posicao do LR_FILPED
Local nPosPrzEntr	:= aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_FDTENTR"})				// Posicao do Campo Data Entrega
Local cUfCliente	:= ''	//Estado de entrega do cliente
Local nPrazo		:= SuperGetMV("MV_LJPRAZ",,0)

//#VFE			
//Se o campo LR_CLIENT e LR_CLILOJA estiver preenchido no momento da reserva,
//considera essas informacao para pegar o CEP de entrega, caso contrario
//pesquisa pelo campo LQ_CLIENTE
If !Empty(aCols[n][nPosClient]) .AND. !Empty(aCols[n][nPosCliLoja]) 


	dbSelectArea('SA1')
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	//Pesquisa na SA1 o contato do cliente para pegar o CEP
	If SA1->(dbSeek(xFilial('SA1')+aCols[n][nPosClient]+aCols[n][nPosCliLoja]))
		If !Empty(SA1->A1_CEPE)
			cCep 		:= SA1->A1_CEPE
			cUfCliente	:= SA1->A1_ESTE
		Else
			cCep 		:= SA1->A1_CEP
			cUfCliente	:= SA1->A1_EST
		EndIf
	EndIf	
		 
Else

	dbSelectArea('SA1')
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	
	//Pesquisa na SA1 o contato do cliente para pegar o CEP
	If SA1->(dbSeek(xFilial('SA1')+M->LQ_CLIENTE+M->LQ_LOJA))
		If !Empty(SA1->A1_CEPE)
			cCep 		:= SA1->A1_CEPE
			cUfCliente	:= SA1->A1_ESTE
		Else
			cCep 		:= SA1->A1_CEP
			cUfCliente	:= SA1->A1_EST
		EndIf
	EndIf
	
EndIf

//Faz a consulta da loja com base no CEP de entrega do cliente
cQuery := "SELECT MF6_CEPDE  " +;
          "     , MF6_CEPATE " +;
          "     , MF6_XFILIA " +;
          "     , MF6_LOCAL  " +;
          "     , MF6_DIASRE " +;
          "  FROM " + RetSQLName("MF6") +;
          " WHERE MF6_FILIAL = '" + xFilial("MF6") + "'" +;
          "   AND MF6_CEPDE <= '" + cCep + "'"  +;
          "   AND MF6_CEPATE >= '" + cCep + "'" +;
          "   AND D_E_L_E_T_ = '' "
           
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasMF6,.F.,.F.)
lEofMf6 := (cAliasMF6)->( !EoF() )

//Se a consulta retornou algum resultado, entao 
//pesquisa a matriz de abastecimento daquela filial
If lEofMf6
	
	cLoja		:= Padr((cAliasMF6)->MF6_XFILIA,Len(CriaVar("DB5_FILABA",.F.)),'') 
	cLocalEst	:= (cAliasMF6)->MF6_LOCAL
	cLojRes	:= cLoja 

	dbSelectArea('DB5')
	DB5->(dbSetOrder(2)) //DB5_FILIAL+DB5_FILABA
	DB5->(dbSeek(xFilial('DB5')+cLoja))
			
	//Varre a matriz de abastecimento em busca da filial abastecedora que esta emitindo a venda.
	While DB5->(!Eof()) .AND. DB5->DB5_FILIAL == xFilial('DB5') .AND. DB5->DB5_FILABA == cLoja
		dbSelectArea("SLJ")
		SLJ->(dbSetOrder(4))	//LJ_FILIAL+LJ_RPCFIL
		If SLJ->(dbSeek(xFilial("SLJ")+DB5->DB5_FILDIS))
			//#VFE Consultando o estoque
			aSaldo := LJXEstVfe(SLJ->LJ_RPCFIL, aCols[n][nPosProd], SLJ->LJ_LOCAL)
			
			If Len(aSaldo) > 0 
				If !(ValType(aSaldo[1][1]) == 'L' .AND. aSaldo[1][1] == .F.)
					If aSaldo[1][8] > 0
						aAdd( aRet, { .T., SLJ->LJ_CODIGO, SLJ->LJ_NOME } )
						lVfe := Lj7IsVfe(SLJ->LJ_RPCEMP,SLJ->LJ_RPCFIL,cUfCliente)	
						
						aCols[n][nPosFilPed] := cLojRes
						
						If !Empty( nPrazo )
							aCols[n][nPosPrzEntr]:= dDataBase + nPrazo
						Else
							aCols[n][nPosPrzEntr]:= dDataBase + DB5->DB5_PRAZO
						EndIf
											
						Exit
					EndIf		
				EndIf
			EndIf
			
		EndIf
		DB5->(dbSkip())
	End

EndIf

(cAliasMF6)->( dbCloseArea() )

Return aRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7IsVfeºAutor  ³Vendas Clientes    º Data ³     08/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se determinado item sera uma FVE                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj7IsVfe(cEmpReserva, cFilReserva, cUfCliente)

//#VFE
Local aArea 	:= GetArea() 	//Salva area
Local lRet		:= .F.			//Retorno da funcao

Default cEmpReserva	:= ''
Default cFilReserva 	:= ''
Default cUfCliente	:= ''

If !Empty(cEmpReserva) .AND. !Empty(cFilReserva) 
	
	SM0->(dbSetOrder(1))
	If SM0->(dbSeek(cEmpReserva+cFilReserva))
		If Upper(AllTrim(SM0->M0_ESTCOB)) == Upper(AllTrim(cUfCliente))
			lRet := .F.		
		Else
			lRet := .T.
		EndIf		
	EndIf
	
EndIf

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjRetVFEºAutor  ³Vendas Clientes    º Data ³     08/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna valor de lVFE e tambem reseta seu valor            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjRetVFE(lReset)

DEFAULT lReset := .F.

If lReset
	lVfe := .F.
EndIf

Return lVFE

//-------------------------------------------------------------------
/*/{Protheus.doc} LjVlFilRes
Valida se venda Retira e o estoque aonde será efetuado a reserva,
caso seja diferente da filial da SB2, não permite pois
a reserva RETIRA deve ser efetuada na mesma filial da baixa 
de estoque

@type function
@param aLojas, array,  contem as lojas de reserva
@param aProdutos, array , contem os produtos de reserva
@param cItaCols, caracter , 
@author  Varejo
@version P12
@since   10/08/2016
@return  lRet , lógico , permite ou não fazer a reserva
/*/
//----------------------------------------------------------------------
Function LjVlFilRes(aLojas,aProdutos,cItaCols)
Local cFilRes	:= ""
Local lRet		:= .T.
Local aLocLj	:= {}
Local aLocProd	:= {}
Local aAreaSLJ	:= {}
Local nLinACols := 0
Local nX		:= 0
Local nY		:= 0
Local nPosEntr	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ENTREGA"})				// Posicao do Tipo de Entrega

Default aLojas	:= {}
Default aProdutos:={}
Default cItaCols:= ""

If Len(aLojas) > 0 .And. Len(aProdutos) > 0 .And. !Empty(AllTrim(cItaCols))
	aLocLj		:= aLojas
	aLocProd	:= aProdutos
	nLinACols	:= Ascan(aCols,{|x| Alltrim(x[1]) == AllTrim(cItaCols)})
	nX			:= Ascan(aLocProd,{|x| Alltrim(x[2]) == AllTrim(cItaCols)})
	
	If nLinACols > 0 .And. AllTrim(aCols[nLinACols][nPosEntr]) == "2"
		aAreaSLJ := SLJ->(GetArea())
		SLJ->(dbSetOrder(1))

		For nY := 1 to Len(aLocLj)
			If aLocLj[nY][1] .AND. SLJ->(dbSeek(xFilial("SLJ") + aLocLj[nY][2])) 
				cFilRes := SLJ->LJ_RPCFIL

				If cFilRes <> xFilial("SB2")
					MsgAlert(STR0081 + AllTrim(aLocProd[nX][3]) + " - " + AllTrim(aLocProd[nX][4])  + STR0082 +; //#" O produto "," esta com reserva do Tipo 'Retira' "
							STR0083 +; //" e não pode ser selecionada pois a baixa de estoque ocorre na filial corrente "
							STR0084 + cFilRes + STR0085 +; //" e a reserva foi lançada para a filial "," portanto a reserva não "
							STR0086 +; //" será finalizada! Caso necessário efetue reserva dos tipos "
							STR0087,STR0088) //" 'Retira Posterior' ou 'Entrega' ","Reserva Nao Efetuada"
					lRet := .F.
					Loop
				EndIf  
			EndIf
		Next nY
		
		RestArea(aAreaSLJ)
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} LJRefazSC0
Refaz as reservas na SC0.
@Obs Essa função é uma copia da antiga função MaRefazSC0 existente no fonte mata521

@return Nulo

@author Varejo
@since 06/10/2015
@version 1.0

/*/
Function LJRefazSC0()
Local aArea 	 := {}
Local aAreaSC0 	 := {}
Local cReservOld := ""
Local cProduto 	 := ""
Local cLocal	 := ""
Local nQtde 	 := 0
Local cFilSC0  	 := ""
Local aOperacao  := {}
Local cNumLote	 := ""
Local cLoteCtl	 := ""
Local cLocaliz	 := ""
Local cNumSer	 := ""
Local cDocRes 	 := ""
Local cFilOri 	 := ""
Local cObserv 	 := ""
Local nUso		 := 0
Local aHeaderAux := {}
Local aColsAux   := {}
Local dDtValid 	 := CTOD("  /  /  ")
Local lContinua  := .F.
Local lReservOK	 := .F.
Local cFilFilho  := ""
Local cOrcFilho  := ""
Local cFilPai  	 := ""
Local cOrcPai  	 := ""
Local cNumeroSC0 := ""
Local cQuery 	 := ""
Local cAliasQRY  := ""
Local cAliasQRY2 := ""
Local cL2FilRes	 := ""
Local cL2OrcRes  := ""
Local lMV_LJCTRES:= SuperGetMV("MV_LJCTRES",,.F.)	 //Controla quantidade reservada. Não apaga a informação B2_RESERVA mesmo com o parâmetro MV_LJPVLIB=1 

//Somente se aplica este processo, para pedido gerados de origem do SIGALOJA
If !Empty(SC5->C5_ORCRES) //Verifica se o pedido foi gerado pelo modulo SIGALOJA
	//Parametro que controla se gera Pedido de Venda com a Qtde. Liberada para faturar. (MV_LJPVLIB: 1=Sim; 2=Nao)
	If SuperGetMv("MV_LJPVLIB", Nil, "1") == "2" //2=Nao.  Neste caso, refaz a Reserva da SC0, pois o pedido nao foi gerado liberado, entao deve-se manter a reserva na SC0.
		lContinua := .T.
	Else
		If !lMV_LJCTRES
			lContinua := .F.		
		Else
			//Se controla quantidade reservada, refaz a reserva 		
			lContinua := .T.
		EndIf	
	EndIf
EndIf

If lContinua
	aArea 	 	:= GetArea()
	aAreaSC0 	:= SC0->(GetArea())
	
	cReservOld 	:= SC9->C9_RESERVA
	cProduto	:= SC6->C6_PRODUTO
	cLocal	 	:= SC6->C6_LOCAL
	nQtde 		:= SC9->C9_QTDLIB
	
	DbSelectArea("SC0")
	SC0->(DbSetOrder(1))
	If SC0->(DbSeek(xFilial("SC0")+cReservOld+cProduto+cLocal))
		
		nRecnoSC0 := SC0->(Recno())
		
		//Considera informacoes da reserva original para incluir uma nova reserva
		cFilSC0 := SC0->C0_FILIAL
		cDocRes	:= SC0->C0_DOCRES
		cFilOri	:= SC0->C0_FILRES
		cObserv	:= SC0->C0_OBS
		
		cNumLote	:= SC0->C0_NUMLOTE
		cLoteCtl	:= SC0->C0_LOTECTL
		cLocaliz	:= SC0->C0_LOCALIZ
		cNumSer		:= SC0->C0_NUMSERI
		dDtValid 	:= SC0->C0_VALIDA //Data de Validade da Reserva
		
		aOperacao 	:= { 1, "LJ", cDocRes, cUserName, cFilOri, cObserv }
		aLote 		:= { cNumLote, cLoteCtl, cLocaliz, cNumSer }
		
		
		//Monta array com aHeader e aCols somente com os dados necessarios para a
		//rotina de reserva.
		aHeaderAux := {}
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek("C0_VALIDA ")
				nUso++
				AADD(aHeaderAux,{ TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT }	)
		Endif
		
		//Inicializa as variaveis da acols.
		aColsAux := Array(nUso+1)
		aColsAux[1] := dDtValid
		aColsAux[nUso+1] := .F.
		
		cNumeroSC0 := GetSx8Num("SC0","C0_NUM")
		ConfirmSx8()
		
		//Cria a reserva no SC0.
		lReservOK := a430Reserv(aOperacao,;
								cNumeroSC0,;	// Numero da reserva
								cProduto,;		// Produto da reserva
								cLocal,; 		// Armazem da reserva 
								nQtde,;			// Quantidade a ser reservada
								aLote,;
								aHeaderAux,;
								aColsAux,;
								NIL,;
								.T.)
		
		If lReservOK
			//--------------------------------------------
			//Atualiza o SC6 com o codigo da nova reserva
			//--------------------------------------------
			RecLock("SC6", .F.)
			SC6->C6_RESERVA := cNumeroSC0
			SC6->C6_QTDRESE := nQtde
			SC6->(MsUnLock())
			
			
			//Procura pelo SL2 do Orcamento (Pai)
			cL2FilRes := SC5->C5_FILIAL
			cL2OrcRes := SC5->C5_ORCRES
			
			//Procura pelo SL1 do Orcamento (Filho)
			cAliasQRY  := GetNextAlias()
			cQuery := "SELECT L1_FILIAL FILFILHO, L1_NUM ORCFILHO"
			cQuery += "  FROM " + RetSQLName("SL1") + " SL1, "
			cQuery += "       " + RetSQLName("SL2") + " SL2  "
			cQuery += " WHERE L1_FILRES  = L2_FILIAL"
			cQuery += "   AND L1_ORCRES  = L2_NUM"
			cQuery += "   AND L2_FILRES  = '"+cL2FilRes+"'"
			cQuery += "   AND L2_ORCRES  = '"+cL2OrcRes+"'"
			cQuery += "   AND L2_RESERVA = '"+cReservOld+"'"
			cQuery += "   AND SL1.D_E_L_E_T_ = ' '"
			cQuery += "   AND SL2.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)			
			
			If (cAliasQRY)->(!EoF())
				
				cFilFilho	:= (cAliasQRY)->FILFILHO
				cOrcFilho	:= (cAliasQRY)->ORCFILHO
				
				DbSelectArea("SL1")
				SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
				SL1->(DbSeek(cFilFilho+cOrcFilho))
				
				cFilPai		:= SL1->L1_FILRES
				cOrcPai		:= SL1->L1_ORCRES
				
				//----------------------------------------------------
				//Atualiza o SL2 (Filho) com o codigo da nova reserva
				//----------------------------------------------------
				DbSelectArea("SL2")
				SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
				If SL2->(DbSeek(cFilFilho+cOrcFilho+SC6->C6_ITEM+cProduto))
					RecLock("SL2", .F.)
					SL2->L2_RESERVA := cNumeroSC0
					SL2->(MsUnLock())
				EndIf
				
				//----------------------------------------------------
				//Atualiza o SL2 (Pai) com o codigo da nova reserva
				//----------------------------------------------------
				cAliasQRY2 := GetNextAlias()
				cQuery := " SELECT L2_FILIAL, L2_RESERVA, L2_LOJARES , L2_PRODUTO , L2_ITEM "
				cQuery += " FROM " + RetSQLName("SL2") + " SL2 "
				cQuery += " WHERE L2_FILIAL = '"  + cFilPai      + "' "
				cQuery += " AND L2_RESERVA =  '"  + cReservOld   + "' "
				cQuery += " AND L2_PRODUTO =  '"  + cProduto     + "' "
				cQuery += " AND L2_ITEM =     '"  + SC6->C6_ITEM + "' "
				cQuery += " AND SL2.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY2,.T.,.T.)		
				
				If (cAliasQRY2)->(!EoF())
					SL2->(DbSetOrder(5)) //L2_FILIAL+L2_RESERVA+L2_LOJARES+L2_PRODUTO+L2_ITEM
					If SL2->(DbSeek((cAliasQRY2)->L2_FILIAL+(cAliasQRY2)->L2_RESERVA+(cAliasQRY2)->L2_LOJARES+(cAliasQRY2)->L2_PRODUTO+(cAliasQRY2)->L2_ITEM))
						RecLock("SL2", .F.)
						SL2->L2_RESERVA := cNumeroSC0
						SL2->(MsUnLock())	
					EndIf		
				Endif

				(cAliasQRY2)->(DbCloseArea())
				
				//--------------------------------------------
				//Exclui a antiga Reserva na SC0
				//--------------------------------------------
				SC0->(DbGoTo(nRecnoSC0))
				RecLock("SC0", .F.)
				SC0->(DbDelete())
				SC0->(MsUnLock())
			EndIf
			
			(cAliasQRY)->(DbCloseArea())
			
		EndIf
		
	EndIf
	
	RestArea(aAreaSC0)
	RestArea(aArea)
EndIf
Return

/*/{Protheus.doc} LjLockRes
Efetua o LockByName referente a Reserva

@type 	 function
@author  João Marcos Martins
@since   25/04/2019
@version 12.1.23

@param 	 cFilRes, Caractere, Código da Filial onde foi feita a Reserva
@param 	 cNumOrc, Caractere, Número do orçamento que solicitou a reserva (Orçamento PAI)
@param 	 cNumReserv, Caractere, Número da Reserva na tabela SC0

@return lRet, Lógico, Se efetuou ou nao o Lock
/*/
Function LjLockRes( cFilRes, cNumOrc, cNumReserv )
Local cLockReser	:= ""
Local lRet			:= .T.

Default cFilRes 	:= ""
Default cNumOrc		:= ""
Default cNumReserv 	:= ""

cLockReser := LjKeyLcRes( cFilRes, cNumOrc, cNumReserv )

If !Empty(cLockReser)
	lRet := LockByName(cLockReser, .T., .F.)

	If lRet
		LjGrvLog( cNumOrc,"LockByName (semaforo) de arquivo de Reserva efetuado - Chave:" + cLockReser )
		If aScan( aLockReserv, cLockReser ) == 0
			Aadd(aLockReserv, cLockReser)
		EndIf
	Else 
		LjGrvLog( cNumOrc,"Nao foi possivel efetuar o LockByName (semaforo) de Reserva - Chave:" + cLockReser )	
	EndIf
EndIf

Return( lRet )

/*/{Protheus.doc} LjULockRes
Efetua o UnlockByName referente a Reserva dos nomes contidos no array aLockReserv

@type 	 function
@author  João Marcos Martins
@since 	 25/04/2019
@version 12.1.23

@param 	 cFilRes, Caractere, Código da Filial onde foi feita a Reserva
@param 	 cNumOrc, Caractere, Número do orçamento que solicitou a reserva (Orçamento PAI)
@param 	 cNumReserv, Caractere, Número da Reserva na tabela SC0

@return Nil, Nulo
/*/
Function LjULockRes( cFilRes, cNumOrc, cNumReserv )
Local nX			:= 0
Local nForIni 		:= 0
Local nForFim 		:= 0
Local cLockReser	:= ""
Local nQtdDel		:= 0

Default cFilRes 	:= ""
Default cNumOrc		:= ""
Default cNumReserv 	:= ""

cLockReser := LjKeyLcRes( cFilRes, cNumOrc, cNumReserv )

//Faz UnLock de uma chave especifica apenas
If !Empty(cLockReser)
	If ( nForIni := aScan( aLockReserv, cLockReser ) ) > 0
		nForFim := nForIni
	EndIf
Else
	nForIni	:= 1
	nForFim	:= Len(aLockReserv)
EndIf

For nX := nForIni To nForFim
	UnLockByName( aLockReserv[nX], .T., .F., .F. )
	LjGrvLog( Nil,"UnLockByName (semaforo) de Reserva efetuado - Chave:" + aLockReserv[nX] )
	aLockReserv[nX] := "*" //Marca para deletar essa posição do array
	nQtdDel++
Next nX

While ( nX := aScan( aLockReserv, "*" ) ) > 0
	aDel( aLockReserv, nX )
End

aSize( aLockReserv, Len(aLockReserv)-nQtdDel )

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} LjKeyLcRes
Monta a chave para controle de semáforo de reservas.

@type 	 function
@author  Alberto Deviciente
@since   17/09/2021
@version 12.1.27

@param 	 cFilRes, Caractere, Código da Filial onde foi feita a Reserva
@param 	 cNumOrc, Caractere, Número do orçamento que solicitou a reserva (Orçamento PAI)
@param 	 cNumReserv, Caractere, Número da Reserva na tabela SC0

@return  cRet, Caractere, Chave para controle de semáforo de reservas.
/*/
//----------------------------------------------------------------------
Static Function LjKeyLcRes( cFilRes, cNumOrc, cNumReserv )
Local cRet	:= "" 

If !Empty(cFilRes) .And. !Empty(cNumOrc) .And. !Empty(cNumReserv)
	// Filial onde foi feita a Reserva + Cod. do Orcamento + Cod. da Reserva
	cRet := cFilRes + Padr(AllTrim(cNumOrc), TamSX3("LQ_NUM")[1]) + Padr(AllTrim(cNumReserv), TamSX3("C0_NUM")[1])
EndIf

Return cRet
