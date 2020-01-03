#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

//---------------------------------------+
// Estrutura de Retorno Consulta Cliente |
//---------------------------------------+
WSSTRUCT STRCLIRET
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET  	AS STRING
	WSDATA WS_NPAGINI	AS INTEGER
	WSDATA WS_NPAGFIM	AS INTEGER
	WSDATA WS_ARRCLI 	AS ARRAY OF ARRAYCLI
ENDWSSTRUCT	

//-------------------------------+
// Estrutura Gravacao de Cliente |
//-------------------------------+
WSSTRUCT STRCLIGRV
	WSDATA WS_ARRCLI 	AS ARRAY OF ARRAYCLIGRV
ENDWSSTRUCT	

//-------------------------------------------+
// Estrutura de Retorno Tipos de Organizacao |
//-------------------------------------------+
WSSTRUCT STRTPORGGRV
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET  	AS STRING
	WSDATA WS_ARRORG 	AS ARRAY OF ARRAYTPORG
ENDWSSTRUCT	

//-----------------------------------------+
// Estrutura Gravacao Tipos de Organizacao |
//-----------------------------------------+
WSSTRUCT ARRAYTPORG
	WSDATA WS_DESCRICAO AS STRING
	WSDATA WS_ATIVO		AS STRING
	WSDATA WS_IDERP		AS INTEGER
ENDWSSTRUCT

//----------------------------------------+
// Estrutura retorno Tipos de Organizacao |
//----------------------------------------+
WSSTRUCT STRORGRET
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET  	AS STRING
	WSDATA WS_ARRORG 	AS ARRAY OF ARRAYORGRET
ENDWSSTRUCT	

WSSTRUCT ARRAYORGRET
	WSDATA WS_CODIGO 	AS STRING
	WSDATA WS_DESCRICAO AS STRING
	WSDATA WS_ATIVO		AS STRING
	WSDATA WS_IDERP		AS INTEGER
ENDWSSTRUCT

//-----------------------------+
// Estrutura retorno regionais |
//-----------------------------+
WSSTRUCT STRREGRET
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET  	AS STRING
	WSDATA WS_ARRREG 	AS ARRAY OF ARRAYREGRET
ENDWSSTRUCT	

WSSTRUCT ARRAYREGRET
	WSDATA WS_CODIGO 	AS STRING
	WSDATA WS_DESCRICAO AS STRING
	WSDATA WS_IDERP		AS INTEGER
ENDWSSTRUCT

//---------------------------------------+
// Estrutura de Retorno Gravacao Cliente |
//---------------------------------------+
WSSTRUCT STRGRVRET
	WSDATA WS_IDCLI		AS STRING
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET  	AS STRING
ENDWSSTRUCT

//--------------------------------------+
// Cria estrutura de clientes gravacao	|
//--------------------------------------+
WSSTRUCT ARRAYCLIGRV
	WSDATA WS_CGC 				AS STRING
	WSDATA WS_TIPO 				AS STRING
	WSDATA WS_PESSOA			AS STRING
	WSDATA WS_NOME 				AS STRING
	WSDATA WS_NREDUZ			AS STRING
	WSDATA WS_ENDERECO 			AS STRING
	WSDATA WS_NUMENDERECO		AS STRING
	WSDATA WS_COMPLEMENTO		AS STRING
	WSDATA WS_BAIRRO			AS STRING
	WSDATA WS_CIDADE			AS STRING
	WSDATA WS_UF				AS STRING
	WSDATA WS_INSCR				AS STRING
	WSDATA WS_INSCM				AS STRING
	WSDATA WS_PFISICA			AS STRING
	WSDATA WS_CEP				AS STRING
	WSDATA WS_DDD				AS STRING
	WSDATA WS_TELEFONE			AS STRING
	WSDATA WS_FAX				AS STRING
	WSDATA WS_EMAIL 			AS STRING
	WSDATA WS_HPAGE 			AS STRING
	WSDATA WS_ATIVO 			AS STRING
	WSDATA WS_CONTATO			AS STRING
	WSDATA WS_VENDEDOR			AS STRING
	WSDATA WS_REGIAO			AS STRING
	WSDATA WS_RAMO				AS STRING
	WSDATA WS_CANAL				AS STRING
	WSDATA WS_FREQUENCIA		AS STRING
	WSDATA WS_ORGANIZACAO		AS STRING
	WSDATA WS_DTENVI			AS STRING
ENDWSSTRUCT	

//--------------------------------------+
// Cria estrutura de clientes consulta	|
//--------------------------------------+
WSSTRUCT ARRAYCLI
	WSDATA WS_CODIGO 			AS STRING
	WSDATA WS_LOJA 				AS STRING
	WSDATA WS_CGC 				AS STRING
	WSDATA WS_TIPO 				AS STRING
	WSDATA WS_PESSOA			AS STRING
	WSDATA WS_NOME 				AS STRING
	WSDATA WS_NREDUZ			AS STRING
	WSDATA WS_ENDERECO 			AS STRING
	WSDATA WS_NUMENDERECO		AS STRING
	WSDATA WS_COMPLEMENTO		AS STRING
	WSDATA WS_BAIRRO			AS STRING
	WSDATA WS_CIDADE			AS STRING
	WSDATA WS_UF				AS STRING
	WSDATA WS_INSCR				AS STRING
	WSDATA WS_INSCM				AS STRING
	WSDATA WS_PFISICA			AS STRING
	WSDATA WS_CEP				AS STRING
	WSDATA WS_DDD				AS STRING
	WSDATA WS_TELEFONE			AS STRING
	WSDATA WS_FAX				AS STRING
	WSDATA WS_EMAIL 			AS STRING
	WSDATA WS_HPAGE 			AS STRING
	WSDATA WS_ATIVO 			AS STRING
	WSDATA WS_CONTATO			AS STRING
	WSDATA WS_VENDEDOR			AS STRING
	WSDATA WS_REGIAO			AS STRING
	WSDATA WS_REGIAO_ID			AS INTEGER
	WSDATA WS_RAMO				AS STRING
	WSDATA WS_RAMO_ID			AS INTEGER
	WSDATA WS_CANAL				AS STRING
	WSDATA WS_FREQUENCIA		AS STRING
	WSDATA WS_ORGANIZACAO		AS STRING
	WSDATA WS_ORGANIZACAO_ID	AS INTEGER
	WSDATA WS_DTENVI			AS STRING
	WSDATA WS_IDERP				AS INTEGER
ENDWSSTRUCT

//-----------------------------------------------+
// Estrutura de Retorno Consulta Transportadoras |
//-----------------------------------------------+
WSSTRUCT STRTRANRET
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET 	AS STRING
	WSDATA WS_ARRTRAN 	AS ARRAY OF STRUTRA
ENDWSSTRUCT	

//-----------------------------------------------+
// Cria estrutura de retorna das transportadoras |
//-----------------------------------------------+
WSSTRUCT STRUTRA
	WSDATA WS_CODIGO 		AS STRING
	WSDATA WS_NOME 			AS STRING
	WSDATA WS_IDERP			AS INTEGER
ENDWSSTRUCT

/**********************************************************************************/
/*/{Protheus.doc} DAWSI002

@description Webservice  - Clientes

@author Bernard M. Margarido

@since 07/08/2017
@version undefined

@type class
/*/
/**********************************************************************************/
WSSERVICE DAWSI002 DESCRIPTION "Servico renune metodos especificos Extranet - Dana."
	
	//------------+
	// Parametros | 
	//------------+
	WSDATA WS_CNPJCPF 	AS STRING
	WSDATA WS_CODIGO 	AS STRING
	WSDATA WS_LOJA 		AS STRING
	WSDATA WS_PAGINA	AS INTEGER
	WSDATA WS_CODTRANSP AS STRING
	WSDATA WS_DESCORG 	AS STRING
	WSDATA WS_DESCREG	AS STRING
		
	//---------------------+
	// Estruturas de envio |
	//---------------------+
	WSDATA WS_CLIENTE 	AS STRCLIGRV
	WSDATA WS_TPORG		AS STRTPORGGRV
		
	//-----------------------+
	// Estruturas de Retorno |
	//-----------------------+
	WSDATA WS_RETCLI 	AS STRCLIRET
	WSDATA WS_RETTRAN 	AS STRTRANRET
	WSDATA WS_RETORG	AS STRORGRET
	WSDATA WS_RETREG	AS STRREGRET
	WSDATA WS_RETGRVCLI	AS ARRAY OF STRGRVRET
	WSDATA WS_RETGRVORG	AS ARRAY OF STRGRVRET
		
	//------------------------+
	// Metodo Insere Clientes |
	//------------------------+	
	WSMETHOD WSGRVCLI	 	DESCRIPTION "Metodo realiza a inclusao/atualizacao para cadastro de clientes - Dana."
	
	//-----------------------------------+
	// Metodo Insere Tipo de Organizaçao |
	//-----------------------------------+	
	WSMETHOD WSGRVORG	 	DESCRIPTION "Metodo realiza a inclusao/atualizacao para cadastro de organização - Dana."
				
	//-----------------------+
	// Metodo envia Clientes |
	//-----------------------+
	WSMETHOD WSRETCLI	 	DESCRIPTION "Metodo retorna dados do clientes - Dana."
	
	//--------------------------------+
	// Metodo Retorna Transportadoras |
	//--------------------------------+	
	WSMETHOD WSRETTRAN	 	DESCRIPTION "Metodo retorna dados da transportadoras - Dana."
	
	//--------------------------+
	// Metodo envia organizacao |
	//--------------------------+
	WSMETHOD WSRETORG	 	DESCRIPTION "Metodo retorna dados do tipos de organizacoes - Dana."
	
	//------------------------+
	// Metodo envia regionais |
	//------------------------+
	WSMETHOD WSRETREG	 	DESCRIPTION "Metodo retorna dados daa regionais - Dana."
				
ENDWSSERVICE

/**********************************************************************************/
/*/{Protheus.doc} WSGRVCLI

@description Realiza a gravação dos dados do cliente enviados pela Extranet

@author Bernard M. Margarido
@since 14/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSGRVCLI WSRECEIVE WS_CLIENTE WSSEND WS_RETGRVCLI WSSERVICE DAWSI002
Local aArea		:= GetArea()
Local aCliente	:= {}
Local aMsgRet	:= {}

Local cCodCli	:= ""
Local cCodLoja	:= "01"
Local cCnpj		:= ""
Local cCodMun	:= ""

Local nOpcA		:= 0

Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSGRVCLI_" + cEmpAnt + "_" + cFilAnt + ".LOG"

Private lMsErroAuto	:= .F.

//----------------+
// Cria diretorio |
//----------------+
MakeDir(cDirImp)

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO CLIENTES - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------------------+
// Valida se foram enviado dados |
//-------------------------------+
If ValType(::WS_CLIENTE:ARRAYCLIGRV) == "A"
	
	//-------------------+
	// Posiciona Cliente |
	//-------------------+
	dbSelectArea("SA1")
	SA1->( dbSetOrder(3) )
	
	//---------------------------------------+
	// Inicia validaçao dos dados do cliente |
	//---------------------------------------+
	For nCli := 1 To Len(::WS_CLIENTE:WS_ARRCLI)
		//------------------------+
		// Formata campo CNPJ/CPF |
		//------------------------+
		cCnpj	:= u_SyFormat(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_CGC, "A1_CGC", .T.)
		
		//-----------------------------------------+
		// Valida se já existe cadastro de cliente |
		//-----------------------------------------+
		If SA1->( dbSeek(xFilial("SA1") + cCnpj) )
			LogExec("ALTERANDO CLIENTE " + Alltrim(SA1->A1_NOME) + " .")
			cCodCli := SA1->A1_COD
			cCodLoja:= SA1->A1_LOJA
			nOpcA	:= 4
		Else
			LogExec("INCLUINDO CLIENTE " + Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_NOME) + " .")
			VldCodCli(@cCodCli, @cCodLoja, cCnpj)
			nOpcA	:= 3
		EndIf
		
		//--------------------------+
		// Valida Incrição Estadual |
		//--------------------------+
		If !Empty(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_INSCR)) .And. ! Upper(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_INSCR)) $ "ISENTO/ISENTA" 
			If !IE(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_INSCR), Upper(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_UF))
				//-----------------------+
				// Grava mensagem no LOG |
				//-----------------------+
				LogExec("A INSCRICAO ESTADUAL INFORMADA E INVALIDA PARA O ESTADO INFORMADO.")
				//------------+
				// Grava Erro |
				//------------+
				aAdd(aMsgRet,{cCnpj,"1","A INSCRICAO ESTADUAL INFORMADA E INVALIDA PARA O ESTADO INFORMADO."})
				//------------------------------+
				// Pula para o proximo registro |
				//------------------------------+
				Loop
			EndIf
		Endif
		
		//-----------------+
		// Valida CNPJ/CPF |
		//-----------------+
		If !CGC(cCnpj)
			//-----------------------+
			// Grava mensagem no LOG |
			//-----------------------+
			LogExec("O CPF/CNPJ INFORMADO NAO E VALIDO.")
			//------------+
			// Grava Erro |
			//------------+
			aAdd(aMsgRet,{cCnpj,"1","O CPF/CNPJ INFORMADO NAO E VALIDO."})
			//------------------------------+
			// Pula para o proximo registro |
			//------------------------------+
			Loop
		EndIf
		
		//-----------------------+
		// Valida Cod. Municipio |
		//-----------------------+
		cEstado 	:= Upper(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_UF)
		cMunicipio	:= u_SyAcento(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_CIDADE,.T.)
		If !DaWsI02Mun(cEstado,cMunicipio,@cCodMun)
			//-----------------------+
			// Grava mensagem no LOG |
			//-----------------------+
			LogExec("NAO FOI ENCONTRADO CODIGO DE MUNICIPIO PARA " + cMunicipio + " .")
			//------------+
			// Grava Erro |
			//------------+
			aAdd(aMsgRet,{cCnpj,"1","NAO FOI ENCONTRADO CODIGO DE MUNICIPIO PARA " + cMunicipio + " ." })
			//------------------------------+
			// Pula para o proximo registro |
			//------------------------------+
			Loop
		EndIf
		
		//--------------------------------------+
		// Adiciona dados dos clientes no Array |
		//--------------------------------------+
		aCliente	:= {}
		aAdd(aCliente,{ "A1_FILIAL"		, xFilial("SA1")																								, Nil	} )
		aAdd(aCliente,{ "A1_COD"		, cCodCli																										, Nil	} )
		aAdd(aCliente,{ "A1_LOJA"		, cCodLoja																										, Nil	} )
		aAdd(aCliente,{ "A1_TIPO"		, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_TIPO																			, Nil	} )	 
		aAdd(aCliente,{ "A1_PESSOA"		, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_PESSOA																		, Nil	} )
		aAdd(aCliente,{ "A1_NOME"		, U_SyAcento(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_NOME,.T.) 															, Nil	} )	
		aAdd(aCliente,{ "A1_NREDUZ"		, U_SyAcento(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_NREDUZ,.T.)														, Nil	} )
		aAdd(aCliente,{ "A1_EMAIL"		, Lower(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_EMAIL)																	, Nil	} )
		aAdd(aCliente,{ "A1_HPAGE"		, Lower(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_HPAGE)																	, Nil	} )
		aAdd(aCliente,{ "A1_ATIVO"		, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_ATIVO																			, Nil	} )
		aAdd(aCliente,{ "A1_CGC"		, cCnpj																											, Nil	} )
		
		//----------------------------------------+
		// Pesso Juridica                         |
		// Adiciona Incrição Estadual e Municipal |
		//----------------------------------------+
		If ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_PESSOA == "J"
			aAdd(aCliente,{ "A1_INSCR"		, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_INSCR																			, Nil	} )
			aAdd(aCliente,{ "A1_INSCRM"		, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_INSCM																			, Nil	} )
		Else
			//----------------+
			// Pessoa Fisica  |
			// Adiciona RG    |
			//----------------+
			aAdd(aCliente,{ "A1_PFISICA" 	, U_SyFormat(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_PFISICA,"A1_PFISICA")												, Nil	} )
		EndIf
			
		aAdd(aCliente,{ "A1_END"		, U_SyAcento(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_ENDERECO,.T.) + ", " + ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_NUMENDERECO		, Nil	} )
		aAdd(aCliente,{ "A1_EST"		, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_UF																				, Nil	} )
		aAdd(aCliente,{ "A1_COD_MUN"	, cCodMun																											, Nil	} )
		aAdd(aCliente,{ "A1_MUN"		, U_SyAcento(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_CIDADE,.T.)															, Nil	} )
		aAdd(aCliente,{ "A1_BAIRRO"		, U_SyAcento(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_BAIRRO,.T.)															, Nil	} )
		aAdd(aCliente,{ "A1_CEP"		, U_SyFormat(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_CEP,"A1_CEP")															, Nil	} )
		aAdd(aCliente,{ "A1_DDD"		, U_SyFormat(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_DDD,"A1_DDD")															, Nil	} ) 
		aAdd(aCliente,{ "A1_TEL"		, U_SyFormat(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_TELEFONE,"A1_TEL")														, Nil	} )
		aAdd(aCliente,{ "A1_FAX"		, U_SyFormat(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_FAX,"A1_FAX")															, Nil	} )
		aAdd(aCliente,{ "A1_CLASSIF"	, "001"																												, Nil	} )
		aAdd(aCliente,{ "A1_CONTATO"	, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_CONTATO																			, Nil	} )
		aAdd(aCliente,{ "A1_VEND"		, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_VENDEDOR																			, Nil	} )
		aAdd(aCliente,{ "A1_COMPLEM"	, ::WS_CLIENTE:WS_ARRCLI[nCli]:WS_COMPLEMENTO																		, Nil	} )
		aAdd(aCliente,{ "A1_CODPALM"	, "00000000"																										, Nil	} )
		aAdd(aCliente,{ "A1_FATORPR"	, 1.00																												, Nil	} )
		aAdd(aCliente,{ "A1_CANAL"		, IIF(Upper(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_CANAL)) == "DIRETO","1","2")									, Nil	} )
				
		//-----------------+
		// Localiza Região |
		//-----------------+
		If !Empty(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_REGIAO)
			aAdd(aCliente,{ "A1_REGIAO"	, DaWsi02Re(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_REGIAO)																	, Nil	} )
		EndIf	  
		
		//----------------------------+
		// Localiza Ramo de Atividade |
		//----------------------------+
		If !Empty(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_RAMO)
			aAdd(aCliente,{ "A1_RAMO"	, DaWsi02At(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_RAMO)																	, Nil	} )
		EndIf
		
		If !Empty(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_ORGANIZACAO)
			aAdd(aCliente,{ "A1_TPORG"	, DaWsi02Or(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_ORGANIZACAO)															, Nil	} )
		EndIf	
		
		If Upper(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_FREQUENCIA)) == "BISEMANAL" .Or. Upper(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_FREQUENCIA)) == "QUINZENAL"
			aAdd(aCliente,{ "A1_TEMVIS"		, 15																											, Nil	} )
		ElseIf Upper(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_FREQUENCIA)) == "MENSAL"
			aAdd(aCliente,{ "A1_TEMVIS"		, 30																											, Nil	} )
		ElseIf Upper(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_FREQUENCIA)) == "SEMANAL" 	
			aAdd(aCliente,{ "A1_TEMVIS"		, 7																												, Nil	} )
		EndIf
			
		//-----------------------------------------------------+
		// Grava/Atualiza cliente utilizando rotina automatica |
		//-----------------------------------------------------+
		lMsErroAuto	:= .F.
		If Len(aCliente) > 0
			MsExecAuto({|x,y| MATA030(x,y)}, aCliente, nOpcA)
			If lMsErroAuto
				//-------------------------+
				// Confirma Codigo Cliente |
				//-------------------------+
				RollBackSx8()
				
				//------------+
				// Grava Erro |
				//------------+
				MakeDir(cDirImp + "\clientes\")
				cArqLog := "SA1" + cCodCli + " " + cCodLoja + " " + DToS(dDataBase)+Left(Time(),2)+SubStr(Time(),4,2)+Right(Time(),2)+".LOG"
				MostraErro(cDirImp + "\clientes\",cArqLog)
				DisarmTransaction()
				//------------------------------------------------+
				// Adiciona Arquivo de log no Retorno da resposta |
				//------------------------------------------------+
				cMsgErro := ""
				nHndImp  := FT_FUSE(cDirImp + "\clientes\" + cArqLog)

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
				
				
				//-----------------------+
				// Grava mensagem no LOG |
				//-----------------------+
				LogExec("ERRO AO GRAVAR CLIENTE " + Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_NOME) + " .")
				//------------+
				// Grava Erro |
				//------------+
				aAdd(aMsgRet,{cCnpj,"1","ERRO AO GRAVAR CLIENTE " + Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_NOME) + " ." + CRLF + cMsgErro })
			Else
				//-------------------------+
				// Confirma Codigo Cliente |
				//-------------------------+
				ConfirmSx8()
				//-----------------------+
				// Grava mensagem no LOG |
				//-----------------------+
				LogExec("CLIENTE " + Upper(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_NOME)) + " GRAVADO COM SUCESSO.")
				//------------+
				// Grava Erro |
				//------------+
				aAdd(aMsgRet,{cCnpj,"0","CLIENTE " + Upper(Alltrim(::WS_CLIENTE:WS_ARRCLI[nCli]:WS_NOME)) + " GRAVADO COM SUCESSO."})
			EndIf
		EndIf	 
			
	Next nCli
Else
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	aAdd(::WS_RETGRVCLI ,WSClassNew("STRGRVRET") )
	::WS_RETGRVCLI[1]:WS_IDCLI			:= ""
	::WS_RETGRVCLI[1]:WS_RETURN 		:= "1"
	::WS_RETGRVCLI[1]:WS_DESRET 		:= "NAO EXISTEM DADOS A SEREM GRAVADOS"
	
EndIf

If Len(aMsgRet) > 0
	For nMsg := 1 To Len(aMsgRet)
		aAdd(::WS_RETGRVCLI ,WSClassNew("STRGRVRET") )
		::WS_RETGRVCLI[Len(::WS_RETGRVCLI)]:WS_IDCLI 	:= aMsgRet[nMsg][1]
		::WS_RETGRVCLI[Len(::WS_RETGRVCLI)]:WS_RETURN 	:= aMsgRet[nMsg][2] 
		::WS_RETGRVCLI[Len(::WS_RETGRVCLI)]:WS_DESRET	:= aMsgRet[nMsg][3]
	Next nMsg	 
EndIf

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO CLIENTES - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} WSGRVORG

@description Realiza a gravação dos dados do tipo de organização enviados pela Extranet

@author Bernard M. Margarido
@since 14/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSGRVORG WSRECEIVE WS_TPORG WSSEND WS_RETGRVORG WSSERVICE DAWSI002
Local aArea		:= GetArea()
Local aMsgRet	:= {}

Local cCodOrg	:= ""

Local nOpcA		:= 0
Local nTpOrg	:= 0
Local nMsg		:= 0

Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSGRVTPORG_" + cEmpAnt + "_" + cFilAnt + ".LOG"

//----------------+
// Cria diretorio |
//----------------+
MakeDir(cDirImp)

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO TIPOS DE ORGANIZACAO - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())


If ValType(::WS_TPORG:WS_ARRTPORG) == "A"
	
	//------------------------------------------+
	// Seleciona Tabela de Tipos de Organização |
	//------------------------------------------+
	dbSelectArea("SZI")
	SZI->( dbSetOrder(1) )
	
	//---------------------------+
	// Processa registro enviado |
	//---------------------------+
	For nTpOrg := 1 To Len(::WS_TPORG:WS_ARRTPORG)
		
		//----------------------------------------------------+
		// Valida se ja existe tipo de organização cadastrado |
		//----------------------------------------------------+
		cCodOrg := DaWsi02Or(::WS_TPORG:WS_ARRTPORG[nTpOrg]:WS_DESCRICAO)
		If !Empty(cCodOrg)
			If SZI->( dbSeek(xFilial("SZI") + cCodOrg)  )
				//-----------------+
				// Atualiza Status |
				//-----------------+
				RecLock("SZI",.F.)
					SZI->ZI_MSBLQL := IIF(::WS_TPORG:WS_ARRTPORG[nTpOrg]:WS_ATIVO == "N","1","2")
				SZI->( MsUnLock() )
				
				//----------------------+
				// Grava LOG de Retorno |
				//----------------------+
				aAdd(aMsgRet,{"","0","TIPO DE ORGANIZAÇÃO " + Alltrim(::WS_TPORG:WS_ARRTPORG[nTpOrg]:WS_DESCRICAO) + " ATUALIZADO COM SUCESSO" })
				
				LogExec("TIPO DE ORGANIZAÇÃO " + Alltrim(::WS_TPORG:WS_ARRTPORG[nTpOrg]:WS_DESCRICAO) + " ATUALIZADO COM SUCESSO")
					
			EndIf	
		Else
			//---------------------+
			// Retorna novo codigo |
			//---------------------+ 
			cCodOrg	:= DaWsI02Prx("SZI")
			
			//-------------------------+
			// Salva ultimo sequencial | 
			//-------------------------+
			PutMv("DA_CODORG",cCodOrg)
			
			//--------------------+
			// Realiza a gravação | 
			//--------------------+
			RecLock("SZI",.T.)
				SZI->ZI_FILIAL	:= xFilial("SZI")
				SZI->ZI_CODIGO	:= cCodOrg
				SZI->ZI_DESC	:= u_SyAcento(::WS_TPORG:WS_ARRTPORG[nTpOrg]:WS_DESCRICAO,.T.)
				SZI->ZI_MSBLQL	:= IIF(::WS_TPORG:WS_ARRTPORG[nTpOrg]:WS_ATIVO == "N","1","2")
			SZI->(MsUnLock())
			
			//----------------------+
			// Grava LOG de Retorno |
			//----------------------+
			aAdd(aMsgRet,{"","0","TIPO DEORGANIZAÇÃO " + Alltrim(::WS_TPORG:WS_ARRTPORG[nTpOrg]:WS_DESCRICAO) + " ATUALIZADO COM SUCESSO" })
			
			LogExec("TIPO DE ORGANIZAÇÃO " + Alltrim(::WS_TPORG:WS_ARRTPORG[nTpOrg]:WS_DESCRICAO) + " ATUALIZADO COM SUCESSO")
			
		EndIf
	Next nTpOrg
	
EndIf

If Len(aMsgRet) > 0
	For nMsg := 1 To Len(aMsgRet)
		aAdd(::WS_RETGRVORG ,WSClassNew("STRGRVRET") )
		::WS_RETGRVORG[Len(::WS_RETGRVORG)]:WS_IDCLI 	:= aMsgRet[nMsg][1]
		::WS_RETGRVORG[Len(::WS_RETGRVORG)]:WS_RETURN 	:= aMsgRet[nMsg][2] 
		::WS_RETGRVORG[Len(::WS_RETGRVORG)]:WS_DESRET	:= aMsgRet[nMsg][3]
	Next nMsg	 
EndIf

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO TIPOS DE ORGANIZACAO - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} WSRETORG

@description Retorna cadastro dos tipos de Organização

@author Bernard M. Margarido

@since 25/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSRETORG WSRECEIVE WS_DESCORG WSSEND WS_RETORG WSSERVICE DAWSI002
Local aArea			:= GetArea()

Local cAlias		:= GetNextAlias()
Local cDescOrg		:= u_SyAcento(::WS_DESCORG,.T.)

Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSRETORG_" + cEmpAnt + "_" + cFilAnt + ".LOG"

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO TIPOS DE ORGANIZACAO - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------+
// Consulta usuarios |
//-------------------+
If !QRY02ORG(cAlias,cDescOrg)

	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	::WS_RETORG:WS_RETURN 		:= "1"
	::WS_RETORG:WS_DESRET 		:= "NAO EXISTEM DADOS A SEREM RETORNADOS"
	
	aAdd(::WS_RETORG:WS_ARRORG,WSClassNew("ARRAYORGRET"))
	::WS_RETORG:WS_ARRORG[1]:WS_CODIGO		:= ""
	::WS_RETORG:WS_ARRORG[1]:WS_DESCRICAO	:= ""
	::WS_RETORG:WS_ARRORG[1]:WS_ATIVO		:= ""
	::WS_RETORG:WS_ARRORG[1]:WS_IDERP		:= 0
	
	(cAlias)->( dbCloseArea() )
	LogExec("NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf 

//------------------+
// Processa retorno | 
//------------------+
::WS_RETORG:WS_RETURN 		:= "0"
::WS_RETORG:WS_DESRET 		:= "ARQUIVO RETORNADO COM SUCESSO"
	
While (cAlias)->( !Eof() )
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	aAdd(::WS_RETORG:WS_ARRORG,WSClassNew("ARRAYORGRET"))
		
	::WS_RETORG:WS_ARRORG[Len(::WS_RETORG:WS_ARRORG)]:WS_CODIGO			:= (cAlias)->ZI_CODIGO
	::WS_RETORG:WS_ARRORG[Len(::WS_RETORG:WS_ARRORG)]:WS_DESCRICAO		:= (cAlias)->ZI_DESC
	::WS_RETORG:WS_ARRORG[Len(::WS_RETORG:WS_ARRORG)]:WS_ATIVO			:= IIF((cAlias)->ZI_MSBLQL == "1","NAO","SIM")
	::WS_RETORG:WS_ARRORG[Len(::WS_RETORG:WS_ARRORG)]:WS_IDERP			:= (cAlias)->RECNOSZI
	
	//-----------+
	// Grava LOG |
	//-----------+
	LogExec("ENVIANDO TIPOS DE ORGANIZACAO " + Alltrim((cAlias)->ZI_DESC) )
	
	(cAlias)->( dbSkip() )
	
EndDo 

(cAlias)->( dbCloseArea() )

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO TIPOS DE ORGANIZACAO - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} WSRETREG

@description Retorna cadastro das regionais

@author Bernard M. Margarido

@since 25/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSRETREG WSRECEIVE WS_DESCREG WSSEND WS_RETREG WSSERVICE DAWSI002
Local aArea			:= GetArea()

Local cAlias		:= GetNextAlias()
Local cDescReg		:= u_SyAcento(::WS_DESCREG,.T.)

Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSRETREG_" + cEmpAnt + "_" + cFilAnt + ".LOG"

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO REGIONAIS - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------+
// Consulta usuarios |
//-------------------+
If !QRY02REG(cAlias,cDescReg)

	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	::WS_RETREG:WS_RETURN 		:= "1"
	::WS_RETREG:WS_DESRET 		:= "NAO EXISTEM DADOS A SEREM RETORNADOS"
	
	aAdd(::WS_RETREG:WS_ARRORG,WSClassNew("ARRAYREGRET"))
	::WS_RETREG:WS_ARRREG[1]:WS_CODIGO		:= ""
	::WS_RETREG:WS_ARRREG[1]:WS_DESCRICAO	:= ""
	::WS_RETREG:WS_ARRREG[1]:WS_IDERP		:= 0
	
	(cAlias)->( dbCloseArea() )
	LogExec("NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf 

//------------------+
// Processa retorno | 
//------------------+
::WS_RETREG:WS_RETURN 		:= "0"
::WS_RETREG:WS_DESRET 		:= "ARQUIVO RETORNADO COM SUCESSO"
	
While (cAlias)->( !Eof() )
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	aAdd(::WS_RETREG:WS_ARRREG,WSClassNew("ARRAYREGRET"))
		
	::WS_RETREG:WS_ARRREG[Len(::WS_RETREG:WS_ARRREG)]:WS_CODIGO			:= Alltrim((cAlias)->X5_CHAVE)
	::WS_RETREG:WS_ARRREG[Len(::WS_RETREG:WS_ARRREG)]:WS_DESCRICAO		:= Alltrim((cAlias)->X5_DESCRI)
	::WS_RETREG:WS_ARRREG[Len(::WS_RETREG:WS_ARRREG)]:WS_IDERP			:= (cAlias)->RECNOSX5
		
	//-----------+
	// Grava LOG |
	//-----------+
	LogExec("ENVIANDO TIPOS DE ORGANIZACAO " + Alltrim((cAlias)->X5_DESCRI) )
	
	(cAlias)->( dbSkip() )
	
EndDo 

(cAlias)->( dbCloseArea() )

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO REGIONAIS - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} WSRETCLI

@description Metodo consulta e retorna dados dos clientes

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSRETCLI WSRECEIVE WS_CNPJCPF,WS_CODIGO,WS_LOJA,WS_PAGINA WSSEND WS_RETCLI WSSERVICE DAWSI002
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cCnpj		:= ::WS_CNPJCPF
Local cCodCli	:= ::WS_CODIGO
Local cLoja		:= ::WS_LOJA
Local cDescFreq	:= ""

Local nCli		:= 0 	
Local nTotCli	:= 0
Local nPagIni	:= 0
Local nPagFim	:= 0
Local nTotPag	:= 0
Local nTotPags	:= 0
Local nPagLim	:= 500
Local nPagina	:= ::WS_PAGINA

Local lPagina	:= .F.

Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSRETCLI_" + cEmpAnt + "_" + cFilAnt + ".LOG"

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO CLIENTES - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//--------------------------+
// Valida se será paginacao |
//--------------------------+
If Empty(cCnpj) .And. Empty(cCodCli)

	//------------------------------+
	// Valida se será por paginação | 
	//------------------------------+
	If Empty(cCnpj) .And. Empty(cCodCli)
		Qry02TCli(@nTotCli)
	EndIf
	
	//-----------------+
	// Primeira Pagina |
	//-----------------+
	If Empty(nPagina)
		nPagina := 1
	EndIf	
	
	//------------------+
	// Total de Paginas |
	//------------------+
	If nTotCli <= nPagLim
		nTotPag := 1 
	Else
		nTotPag := VerNumPag(nPagLim,nTotCli) 
	EndIf	
	
	//----------------+
	// Calcula Pagina |
	//----------------+
	If nPagina == 1
		nPagIni	:= 1
		nPagFim	:= nPagLim
	ElseIf nPagina > 1 .And. nPagina <= nTotPag
		nPagIni := (( nPagina * nPagLim ) + 1 ) - nPagLim
		nPagFim := nPagina * nPagLim  		
	EndIf
	
	//-----------+
	// Paginacao |
	//-----------+
	lPagina	:= .T.
	
EndIf	

//-------------------+
// Consulta usuarios |
//-------------------+
If !QRY02CLI(cAlias,cCnpj,cCodCli,cLoja,nPagIni,nPagFim,lPagina)
	
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	::WS_RETCLI:WS_RETURN 		:= "1"
	::WS_RETCLI:WS_DESRET 		:= "NAO EXISTEM DADOS A SEREM RETORNADOS"
	::WS_RETCLI:WS_NPAGINI		:= 0
	::WS_RETCLI:WS_NPAGFIM		:= 0
	
	aAdd(::WS_RETCLI:WS_ARRCLI,WSClassNew("ARRAYCLI"))
	::WS_RETCLI:WS_ARRCLI[1]:WS_CODIGO			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_LOJA			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_CGC				:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_TIPO			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_PESSOA			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_NOME			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_NREDUZ			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_ENDERECO		:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_NUMENDERECO		:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_COMPLEMENTO		:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_BAIRRO			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_CIDADE			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_UF				:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_INSCR			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_INSCM			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_PFISICA			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_CEP				:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_DDD				:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_TELEFONE		:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_FAX				:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_EMAIL			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_HPAGE			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_ATIVO			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_CONTATO			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_VENDEDOR		:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_DTENVI			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_CANAL			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_FREQUENCIA		:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_ORGANIZACAO		:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_ORGANIZACAO_ID	:= 0
	::WS_RETCLI:WS_ARRCLI[1]:WS_RAMO			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_RAMO_ID			:= 0
	::WS_RETCLI:WS_ARRCLI[1]:WS_REGIAO 			:= ""
	::WS_RETCLI:WS_ARRCLI[1]:WS_REGIAO_ID		:= 0
	::WS_RETCLI:WS_ARRCLI[1]:WS_IDERP 			:= 0
		
	(cAlias)->( dbCloseArea() )
	
	LogExec("NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf


//------------------+
// Processa retorno | 
//------------------+
::WS_RETCLI:WS_RETURN 		:= "0"
::WS_RETCLI:WS_DESRET 		:= "ARQUIVO RETORNADO COM SUCESSO"
::WS_RETCLI:WS_NPAGINI		:= nPagina
::WS_RETCLI:WS_NPAGFIM		:= nTotPag
	
While (cAlias)->( !Eof() )
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	aAdd(::WS_RETCLI:WS_ARRCLI,WSClassNew("ARRAYCLI"))
	
	//--------------------+
	// Posiciona Vendedor |
	//--------------------+
	SA1->( dbGoTo((cAlias)->RECNOSA1) )
	RecLock("SA1",.F.)
		SA1->A1_MSEXP = dTos(Date())
	SA1->( MsUnLock() )
	
	nCli++
	
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_CODIGO			:= (cAlias)->A1_COD
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_LOJA			:= (cAlias)->A1_LOJA
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_CGC			:= (cAlias)->A1_CGC
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_TIPO			:= (cAlias)->A1_TIPO
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_PESSOA			:= (cAlias)->A1_PESSOA
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_NOME			:= (cAlias)->A1_NOME
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_NREDUZ			:= (cAlias)->A1_NREDUZ
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_ENDERECO		:= SubStr((cAlias)->A1_END,1,At(",",(cAlias)->A1_END) - 1)
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_NUMENDERECO	:= SubStr((cAlias)->A1_END,At(",",(cAlias)->A1_END) + 1)
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_COMPLEMENTO	:= (cAlias)->A1_COMPLEM
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_BAIRRO			:= (cAlias)->A1_BAIRRO
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_CIDADE			:= (cAlias)->A1_MUN
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_UF				:= (cAlias)->A1_EST
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_INSCR			:= (cAlias)->A1_INSCR
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_INSCM			:= (cAlias)->A1_INSCRM
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_PFISICA		:= (cAlias)->A1_PFISICA
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_CEP			:= (cAlias)->A1_CEP
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_DDD			:= (cAlias)->A1_DDD
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_TELEFONE		:= (cAlias)->A1_TEL
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_FAX			:= (cAlias)->A1_FAX
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_EMAIL			:= (cAlias)->A1_EMAIL
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_HPAGE			:= (cAlias)->A1_HPAGE
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_ATIVO			:= (cAlias)->A1_ATIVO
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_CONTATO		:= (cAlias)->A1_CONTATO
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_VENDEDOR		:= (cAlias)->A1_VEND
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_CANAL			:= IIF((cAlias)->A1_CANAL == "1","DIRETO","INDIRETO")
	//------------+	
	// Frequencia |
	//------------+
	If (cAlias)->A1_TEMVIS == 15
		cDescFreq	:= "QUINZENAL" 
	ElseIf (cAlias)->A1_TEMVIS == 30
		cDescFreq	:= "MENSAL"
	ElseIf (cAlias)->A1_TEMVIS == 7
		cDescFreq	:= "SEMANAL"
	EndIf
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_FREQUENCIA		:= cDescFreq
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_ORGANIZACAO	:= (cAlias)->DESCORG
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_ORGANIZACAO_ID	:= (cAlias)->RECNOORG
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_RAMO			:= (cAlias)->DESCRAMO
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_RAMO_ID		:= (cAlias)->RECNORAMO
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_REGIAO 		:= (cAlias)->DESCREGIAO
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_REGIAO_ID 		:= (cAlias)->RECNOREGIAO
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_DTENVI			:= dTos(Date())
	::WS_RETCLI:WS_ARRCLI[Len(::WS_RETCLI:WS_ARRCLI)]:WS_IDERP			:= (cAlias)->RECNOSA1
		
	LogExec("ENVIANDO DADOS CLIENTES " + Alltrim((cAlias)->A1_NOME) + " NPAGS " + Alltrim(Str(nCli)) )
	
	//-----------------------+
	// Cria Array de Retorno |
	//-----------------------+
	
	(cAlias)->( dbSkip() )
EndDo 

(cAlias)->( dbCloseArea() )

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO CLIENTES - DATA/HORA: " + dToc( Date() ) + " AS " + Time())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} WS_RETTRAN

@description Metodo consulta e retorna dados das transportadoras

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSRETTRAN WSRECEIVE WS_CODTRANSP WSSEND WS_RETTRAN WSSERVICE DAWSI002
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cCodTransp:= ::WS_CODTRANSP

Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSRETTRANSP_" + cEmpAnt + "_" + cFilAnt + ".LOG"

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO TRANSPORTADORAS - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------+
// Consulta usuarios |
//-------------------+
If !QRY02TRAN(cAlias,cCodTransp)

	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	::WS_RETTRAN:WS_RETURN 		:= "1"
	::WS_RETTRAN:WS_DESRET 		:= "NAO EXISTEM DADOS A SEREM RETORNADOS"
	
	aAdd(::WS_RETTRAN:WS_ARRTRAN,WSClassNew("STRUTRA"))
	
	::WS_RETTRAN:WS_ARRTRAN[1]:WS_CODIGO	:= ""
	::WS_RETTRAN:WS_ARRTRAN[1]:WS_NOME		:= ""
	::WS_RETTRAN:WS_ARRTRAN[1]:WS_IDERP		:= 0
	
	(cAlias)->( dbCloseArea() )
	LogExec("NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf 

//------------------+
// Processa retorno | 
//------------------+
::WS_RETTRAN:WS_RETURN 		:= "0"
::WS_RETTRAN:WS_DESRET 		:= "ARQUIVO RETORNADO COM SUCESSO"
	
While (cAlias)->( !Eof() )
		
	//--------------------+
	// Posiciona Vendedor |
	//--------------------+
	/*
	SA4->( dbGoTo((cAlias)->RECNOSA4) )
	RecLock("SA4",.F.)
		SA4->A4_MSEXP = dTos(Date())
	SA4->( MsUnLock() )
	*/
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	aAdd(::WS_RETTRAN:WS_ARRTRAN,WSClassNew("STRUTRA"))
	
	::WS_RETTRAN:WS_ARRTRAN[Len(::WS_RETTRAN:WS_ARRTRAN)]:WS_CODIGO		:= (cAlias)->A4_COD
	::WS_RETTRAN:WS_ARRTRAN[Len(::WS_RETTRAN:WS_ARRTRAN)]:WS_NOME		:= (cAlias)->A4_NOME
	::WS_RETTRAN:WS_ARRTRAN[Len(::WS_RETTRAN:WS_ARRTRAN)]:WS_IDERP		:= (cAlias)->RECNOSA4
	
	//-----------+
	// Grava LOG |
	//-----------+
	LogExec("ENVIANDO DADOS TRANSPORTADORA " + Alltrim((cAlias)->A4_NOME) )
		
	//-----------------------+
	// Cria Array de Retorno |
	//-----------------------+
	
	(cAlias)->( dbSkip() )
EndDo 
 
(cAlias)->( dbCloseArea() )

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI002 - CADASTRO TRANSPORTADORA - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} QRY02CLI

@description Consulta clientes a serem enviados

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@param cAlias	, characters, descricao

@type function
/*/
/**********************************************************************************/
Static Function QRY02CLI(cAlias,cCnpj,cCodCli,cLoja,nPagIni,nPagFim,lPagina)
Local aArea		:= GetArea()

Local cQuery	:= ""

Local nTotCli	:= 0

cQuery := "	SELECT * FROM ( " + CRLF
cQuery += "		SELECT " + CRLF
cQuery += "			ROW_NUMBER() OVER(ORDER BY A1.A1_COD) RNUM, " + CRLF
cQuery += "			A1.A1_COD A1_COD, " + CRLF
cQuery += "			A1.A1_LOJA A1_LOJA, " + CRLF
cQuery += "			A1.A1_CGC, " + CRLF
cQuery += "			A1.A1_NOME, " + CRLF
cQuery += "			A1.A1_NREDUZ, " + CRLF
cQuery += "			A1.A1_END, " + CRLF
cQuery += "			A1.A1_COMPLEM, " + CRLF
cQuery += "			A1.A1_BAIRRO, " + CRLF
cQuery += "			A1.A1_MUN, " + CRLF
cQuery += "			A1.A1_EST, " + CRLF
cQuery += "			A1.A1_CEP, " + CRLF
cQuery += "			A1.A1_TEL, " + CRLF
cQuery += "			A1.A1_DDD, " + CRLF
cQuery += "			A1.A1_FAX, " + CRLF
cQuery += "			A1.A1_EMAIL, " + CRLF
cQuery += "			A1.A1_CONTATO, " + CRLF
cQuery += "			A1.A1_VEND, " + CRLF
cQuery += "			A1.A1_PESSOA, " + CRLF
cQuery += "			A1.A1_HPAGE, " + CRLF
cQuery += "			A1.A1_ATIVO, " + CRLF
cQuery += "			A1.A1_TIPO, " + CRLF
cQuery += "			A1.A1_INSCR, " + CRLF
cQuery += "			A1.A1_INSCRM, " + CRLF
cQuery += "			A1.A1_PFISICA, " + CRLF
cQuery += "			A1.A1_CANAL, " + CRLF
cQuery += "			A1.A1_TEMVIS, " + CRLF
cQuery += "			ISNULL(ZI.ZI_DESC,'') DESCORG, " + CRLF 
cQuery += "			ISNULL(ZI.R_E_C_N_O_,0) RECNOORG, " + CRLF
cQuery += "			ISNULL(X5.X5_DESCRI,'') DESCREGIAO, " + CRLF
cQuery += "			ISNULL(X5.R_E_C_N_O_,0) RECNOREGIAO, " + CRLF
cQuery += "			ISNULL(ZJ.ZJ_DESC,'') DESCRAMO, " + CRLF
cQuery += "			ISNULL(ZJ.R_E_C_N_O_,'') RECNORAMO, " + CRLF
cQuery += "			A1.R_E_C_N_O_ RECNOSA1 " + CRLF
cQuery += "		FROM " + CRLF
cQuery += "			" + RetSqlName("SA1") + " A1 " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SZI") + " ZI ON ZI.ZI_FILIAL = '" + xFilial("SZI") + "' AND ZI.ZI_CODIGO = A1.A1_TPORG AND ZI.D_E_L_E_T_ = '' " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SZJ") + " ZJ ON ZJ.ZJ_FILIAL = '" + xFilial("SZJ") + "' AND ZJ.ZJ_CODIGO = A1.A1_RAMO AND ZJ.D_E_L_E_T_ = '' " + CRLF
cQuery += "			LEFT OUTER JOIN " + RetSqlName("SX5") + " X5 ON X5.X5_FILIAL = '" + xFilial("SX5") + "' AND X5.X5_TABELA = 'A2' AND X5.X5_CHAVE = A1.A1_REGIAO AND X5.D_E_L_E_T_ = '' " + CRLF 
cQuery += "		WHERE " + CRLF
cQuery += "			A1.A1_FILIAL = '" + xFilial("SA1") + "' AND " + CRLF

If !Empty(cCnpj) 
	cQuery += "			A1.A1_CGC = '" + cCnpj + "' AND " + CRLF
ElseIf !Empty(cCodCli)	 
	cQuery += "			A1.A1_COD = '" + cCodCli + "' AND " + CRLF
	cQuery += "			A1.A1_LOJA = '" + cLoja+ "' AND " + CRLF
Else
	cQuery += "			A1.A1_MSBLQL <> '1' AND " + CRLF
EndIf
cQuery += "			A1.D_E_L_E_T_ = '' " + CRLF
cQuery += "	) PAGCLI " + CRLF
cQuery += "	WHERE " + CRLF
If !lPagina
	cQuery += "	RNUM BETWEEN 1 AND 1 " + CRLF
Else
	cQuery += "	RNUM BETWEEN " + Alltrim(Str(nPagIni)) + " AND " + Alltrim(Str(nPagFim)) + " " + CRLF
EndIf	 
cQuery += "	ORDER BY A1_COD,A1_LOJA "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	RestArea(aArea)
	Return .F.
EndIf

RestArea(aArea)
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} Qry02TCli

@description Consulta totais de registros para clientes

@author Bernard M. Margarido

@since 19/10/2017
@version undefined

@param nTotCli	, numeric	, descricao
@type function
/*/
/*********************************************************************************/
Static Function Qry02TCli(nTotCli)
Local aArea		:= GetArea()

Local cAliasTot	:= GetNextAlias()
Local cQuery	:= ""

cQuery := "	SELECT " + CRLF 
cQuery += "		COUNT(A1.A1_CGC) NTOTAL " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SA1") + " A1 " + CRLF 
cQuery += "		LEFT OUTER JOIN " + RetSqlName("SZI") + " ZI ON ZI.ZI_FILIAL = '" + xFilial("SZI") + "' AND ZI.ZI_CODIGO = A1.A1_TPORG AND ZI.D_E_L_E_T_ = '' " + CRLF
cQuery += "		LEFT OUTER JOIN " + RetSqlName("SZJ") + " ZJ ON ZJ.ZJ_FILIAL = '" + xFilial("SZJ") + "' AND ZJ.ZJ_CODIGO = A1.A1_RAMO AND ZJ.D_E_L_E_T_ = '' " + CRLF
cQuery += "		LEFT OUTER JOIN " + RetSqlName("SX5") + " X5 ON X5.X5_FILIAL = '" + xFilial("SX5") + "' AND X5.X5_TABELA = 'A2' AND X5.X5_CHAVE = A1.A1_REGIAO AND X5.D_E_L_E_T_ = '' " + CRLF  
cQuery += "	WHERE " + CRLF
cQuery += "		A1.A1_FILIAL = '" + xFilial("SA1") + "' AND " + CRLF 
cQuery += "		A1.A1_MSBLQL <> '1' AND " + CRLF
cQuery += "		A1.D_E_L_E_T_ = '' 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTot,.T.,.T.)

nTotCli := (cAliasTot)->NTOTAL

(cAliasTot)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} DAWSI03QRY

@description Consulta transportadoras a serem enviados

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@param cAlias	, characters, descricao

@type function
/*/
/**********************************************************************************/
Static Function QRY02TRAN(cAlias,cCodTransp)
Local aArea	:= GetArea()

Local cQuery:= ""

cQuery := "	SELECT " + CRLF 
cQuery += "		A4.A4_COD, " + CRLF
cQuery += "		A4.A4_NOME, " + CRLF
cQuery += "		A4.R_E_C_N_O_ RECNOSA4 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SA4") + " A4 " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		A4.A4_FILIAL = '" + xFilial("SA4") + "' AND " + CRLF

//----------------+
// Busca por CNPJ |
//----------------+
If !Empty(cCodTransp) 
	cQuery += "		A4.A4_COD = '" + cCodTransp + "' AND " + CRLF
/*	
Else	 
	cQuery += "		A4.A4_MSEXP = '' AND " + CRLF
*/	
EndIf	 
cQuery += "		A4.D_E_L_E_T_ = '' " + CRLF
cQuery += "	ORDER BY A4.A4_COD "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	RestArea(aArea)
	Return .F.
EndIf

RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} QRY02ORG

@description Consulta cadastro de tipos de organização

@author Bernard M. Margarido

@since 25/08/2017
@version undefined

@param cAlias	, characters, descricao
@param cDescOrg	, characters, descricao

@type function
/*/
/**********************************************************************************/
Static Function QRY02ORG(cAlias,cDescOrg)
Local aArea	:= GetArea()

Local cQuery:= ""

cQuery := "	SELECT " + CRLF 
cQuery += "		ZI.ZI_CODIGO, " + CRLF
cQuery += "		ZI.ZI_DESC, " + CRLF
cQuery += "		ZI.ZI_MSBLQL, " + CRLF
cQuery += "		ZI.R_E_C_N_O_ RECNOSZI " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SZI") + " ZI " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		ZI.ZI_FILIAL = '" + xFilial("SZI") + "' AND " + CRLF

//----------------+
// Busca por CNPJ |
//----------------+
If !Empty(cDescOrg) 
	cQuery += "		ZI.ZI_DESC = '" + cDescOrg + "' AND " + CRLF
Else
	cQuery += "		ZI.ZI_MSBLQL <> '1' AND  " + CRLF
EndIf	 
cQuery += "		ZI.D_E_L_E_T_ = '' " + CRLF
cQuery += "	ORDER BY ZI.ZI_CODIGO "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	RestArea(aArea)
	Return .F.
EndIf

RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} QRY02REG

@description Realiza a consulta dos dados das regionais 

@author Bernard M. Margarido

@since 28/08/2017
@version undefined

@param cAlias	, characters, descricao
@param cDescReg	, characters, descricao

@type function
/*/
/**********************************************************************************/
Static Function QRY02REG(cAlias,cDescReg)
Local aArea	:= GetArea()

Local cQuery:= ""

cQuery := "	SELECT " + CRLF 
cQuery += "		X5.X5_CHAVE, " + CRLF
cQuery += "		X5.X5_DESCRI, " + CRLF
cQuery += "		X5.R_E_C_N_O_ RECNOSX5 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SX5") + " X5 " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		X5.X5_FILIAL = '" + xFilial("SX5") + "' AND " + CRLF
cQuery += "		X5.X5_TABELA = 'A2' AND " + CRLF
//---------------------+
// Busca por Descricao |
//---------------------+
If !Empty(cDescReg) 
	cQuery += "		X5.X5_DESCRI = '" + cDescReg + "' AND " + CRLF
EndIf	 
cQuery += "		X5.D_E_L_E_T_ = '' " + CRLF
cQuery += "	ORDER BY X5.X5_CHAVE "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	RestArea(aArea)
	Return .F.
EndIf

RestArea(aArea)
Return .T.

/**************************************************************************************/
/*/{Protheus.doc} DaWsI02Mun

@description Valida codigo de Municipio 

@author Bernard M. Margarido

@since 16/08/2017
@version undefined

@param cCodMun	, characters	, descricao

@type function
/*/
/**************************************************************************************/
Static Function DaWsI02Mun(cEstado,cMunicipio,cCodMun)
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cQuery 	:= ""

cQuery := "	SELECT " + CRLF 
cQuery += "		CC2_CODMUN, " + CRLF  
cQuery += "		CC2_MUN " + CRLF 
cQuery += "	FROM " + CRLF
cQuery += RetSqlName("CC2") + " " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		CC2_EST = '" + cEstado + "' AND " + CRLF
cQuery += "		CC2_MUN = '" + cMunicipio + "' AND " + CRLF
cQuery += 		"D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return .F.
EndIf

cCodMun := (cAlias)->CC2_CODMUN

(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return .T.

/******************************************************************************/
/*/{Protheus.doc} DaWsi02Re

@description Retorna regiao do cliente

@author Bernard M. Margarido

@since 21/08/2017
@version undefined

@param cRegiao	, characters, descricao

@type function
/*/
/******************************************************************************/
Static Function DaWsi02Re(cRegiao)
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cQuery	:= ""
Local cCodreg	:= ""

//-----------------------------+
// Formata Descrição da Regiao |
//-----------------------------+
cRegiao := u_SyAcento(cRegiao,.T.)

cQuery := "	SELECT " + CRLF 
cQuery += "		X5.X5_CHAVE " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SX5") + " X5 " + CRLF
cQuery += "	WHERE " + CRLF
cQuery += "		X5.X5_TABELA = 'A2' AND " + CRLF 
cQuery += "		X5.X5_DESCRI = '" + cRegiao + "' AND " + CRLF  
cQuery += "		X5.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return cCodReg
EndIf

cCodReg := (cAlias)->X5_CHAVE

(cAlias)->( dbCloseArea() )	
	
RestArea(aArea)
Return cCodReg

/******************************************************************************/
/*/{Protheus.doc} DaWsi02At

@description Retorna codigo de atividade

@author Bernard M. Margarido

@since 23/08/2017
@version undefined

@type function
/*/
/******************************************************************************/
Static Function DaWsi02At(cDescAtiv)
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cQuery	:= ""
Local cCodAtiv	:= ""

//-----------------------------+
// Formata Descrição da Regiao |
//-----------------------------+
cRegiao := u_SyAcento(cDescAtiv,.T.)

cQuery := "	SELECT " + CRLF
cQuery += "		ZJ_CODIGO " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "		" + RetSqlName("SZJ") + " " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		ZJ_DESC = '" + cDescAtiv + "' AND " + CRLF 
cQuery += "		D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return cCodAtiv
EndIf

cCodAtiv := (cAlias)->ZJ_CODIGO

(cAlias)->( dbCloseArea() )	
	
RestArea(aArea)
Return cCodAtiv

/******************************************************************************/
/*/{Protheus.doc} DaWsi02Or

@description Comsulta tipo de organização 

@author Bernard M. Margarido
@since 23/08/2017
@version undefined

@param cDescOrg, characters, descricao

@type function
/*/
/******************************************************************************/
Static Function DaWsi02Or(cDescOrg)
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cQuery	:= ""
Local cCodOrg	:= ""

//-----------------------------+
// Formata Descrição da Regiao |
//-----------------------------+
cRegiao := u_SyAcento(cDescOrg,.T.)

cQuery := "	SELECT " + CRLF
cQuery += "		ZI_CODIGO " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "		" + RetSqlName("SZI") + " " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		ZI_DESC = '" + cDescOrg + "' AND " + CRLF 
cQuery += "		D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return cCodOrg
EndIf

cCodOrg := (cAlias)->ZI_CODIGO

(cAlias)->( dbCloseArea() )	
	
RestArea(aArea)
Return cCodOrg 

/**************************************************************************************/
/*/{Protheus.doc} DaWsI02Prx

@description Retorno proximo numero do cliente

@author Bernard M. Margarido
@since 16/08/2017
@version undefined

@type function
/*/
/**************************************************************************************/
Static Function DaWsI02Prx(cTbl)
Local aArea		:= GetArea()

Local cPrxCod	:= ""
Local cQuery	:= ""
Local cAlias	:= GetNextAlias()

If cTbl == "SA1"

	cQuery := "	SELECT " + CRLF 
	cQuery += "		MAX(A1_COD) CODIGO " + CRLF 
	cQuery += "	FROM " + CRLF
	cQuery += "		" + RetSqlName("SA1") + " " + CRLF  
	cQuery += "	WHERE " + CRLF
	cQuery += "		D_E_L_E_T_ = '' "

ElseIf cTbl == "SZI"

	cQuery := "	SELECT " + CRLF
	cQuery += "		MAX(ZI_CODIGO) CODIGO " + CRLF
	cQuery += "	FROM " + CRLF 
	cQuery += "		" + RetSqlName("SZI") + " " + CRLF  
	cQuery += "	WHERE " + CRLF
	cQuery += "		D_E_L_E_T_ = '' "
	
EndIf	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.) 

cPrxCod := Soma1(Alltrim((cAlias)->CODIGO),5)	

(cAlias)->( dbCloseArea() )

RestArea(aArea)
Return cPrxCod

/**************************************************************************************/
/*/{Protheus.doc} SyVldCodCli

@description Gera codigo e loja do cliente

@author Symm Consultoria
@since 18/08/2016
@version undefined

@param xCodigo			, Codigo do Cliente - Passado como referencia
@param xLoja			, Loja do Cliente - Passado como referencia
@param xCnpj			, CPF/CNPJ do Cliente
@param xInc				, Valida se foi gerado novo codigo

@type function
/*/
/****************************************************************************************/
Static Function VldCodCli(xCodigo, xLoja, xCnpj, xInc)

	//-------------------+
	// Declara variaveis |
	//-------------------+
	Local aArea		:= GetArea()	
	Local cCodigo 	:= xCodigo
	Local cLoja	  	:= xLoja
	
	Default xInc	:= .F.
	
	//--------------------------------------------+
	// Verifica se a raiz do CNPJ esta cadastrada |
	//--------------------------------------------+
	dbSelectArea("SA1")
	SA1->( dbSetOrder(3) )
	If SA1->( dbSeek(xFilial("SA1") + xCnpj) )
	
		RollBackSx8()
		cCodigo := SA1->A1_COD
		cLoja   := SA1->A1_LOJA
		xInc    := .F.
		
	Else	
		xInc    := .T.
		cCodigo	:= DaWsI02Prx("SA1")
		PutMv("DA_CODCLI",cCodigo)
		
		//-------------------------------------------+
		// Separa clientes pessoa fisica de juridica |
		//-------------------------------------------+
		//---------------+
		// Pessoa Fisica |
		//---------------+ 
		If Len(Alltrim(xCnpj)) <= 11 
			//-----------------------------------------+
			// Cria novo codigo caso ja exista na base |
			//-----------------------------------------+
			While .T.
				dbSelectArea("SA1")                         
				SA1->( dbSetOrder(1) )
				If SA1->( dbSeek(xFilial("SA1") + cCodigo) ) 
					PutMv("DA_CODCLI",cCodigo)
					cCodigo	:= DaWsI02Prx()
				Else
					PutMv("DA_CODCLI",cCodigo)
					Exit
				EndIf
			End
		//-----------------+
		// Pessoa Juridica |
		//-----------------+
		Else
			dbSelectArea("SA1")
			SA1->( dbSetOrder(3) )
			If SA1->( dbSeek(xFilial("SA1")+Substr(xCnpj,1,8)) ) 
				cCodigo := SA1->A1_COD
				RollBackSX8()
				While .T.
					dbSelectArea("SA1")                         
					SA1->( dbSetOrder(1) )
					If SA1->( dbSeek(xFilial("SA1") + cCodigo + cLoja) ) 
						cLoja := Soma1(cLoja, 2)
					Else
						Exit
					EndIf
				End
			Else
				//-----------------------------------------+
				// Cria novo codigo caso ja exista na base |
				//-----------------------------------------+
				While .T.
					dbSelectArea("SA1")                         
					SA1->( dbSetOrder(1) )
					If SA1->( dbSeek(xFilial("SA1") + cCodigo) )
					 	PutMv("DA_CODCLI",cCodigo)
						cCodigo	:= DaWsI02Prx()
					Else
						PutMv("DA_CODCLI",cCodigo)
						Exit
					EndIf
				End
			EndIf
		EndIf
	EndIf

	xCodigo := cCodigo
	xLoja   := cLoja
	
	//----------------------------------------------+
	// Caso seja inclusao manual de um novo cliente |
	// valoriza as variaveis da enchoice            |
	//----------------------------------------------+
	If AtIsRotina("MATA030") .And. (!AtIsRotina("U_WSATXFUN") .And. !AtIsRotina("U_SAVISA03"))
		M->A1_COD  := cCodigo
		M->A1_LOJA := cLoja
	EndIf
	
	//SA1->( dbCloseArea() )
	
	RestArea(aArea)
Return .T.

/*******************************************************************************/
/*/{Protheus.doc} VerNumPag

@description Calcula total de paginas 

@author Bernard M. Margarido

@since 19/10/2017
@version undefined

@param nPagLim	, numeric, descricao
@param nToReg	, numeric, descricao

@type function
/*/
/*******************************************************************************/
Static Function VerNumPag(nPagLim,nToReg)
Local aArea		:= GetArea()
Local nPagina	:= 0

If Mod(nPagLim,nToReg) <> 0
	nPagina := Int( nToreg / nPagLim ) + 1
Else
	nPagina := ( nToreg / nPagLim ) 
EndIf
	
RestArea(aArea)
Return nPagina

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
