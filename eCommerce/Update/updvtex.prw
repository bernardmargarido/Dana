#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDVTEX
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDVTEX( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else

		If !FWAuthAdmin()
			Final( "Atualização não Realizada." )
		EndIf

		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPDVTEX" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDVTEX" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Realizada." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não Realizada." )

		EndIf

	Else
		Final( "Atualização não Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXA
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de pastas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXA()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  09/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela WS0
//
aAdd( aSX2, { ;
	'WS0', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WS0'+cEmpr	, ; //X2_ARQUIVO
	'LOGS ECOMMERCE', ; //X2_NOME
	'LOGS ECOMMERCE', ; //X2_NOMESPA
	'LOGS ECOMMERCE', ; //X2_NOMEENG
	'C'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'E'	, ; //X2_MODOEMP
	'C'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WS1
//
aAdd( aSX2, { ;
	'WS1', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WS1'+cEmpr	, ; //X2_ARQUIVO
	'STATUS ECOMMERCE', ; //X2_NOME
	'STATUS ECOMMERCE', ; //X2_NOMESPA
	'STATUS ECOMMERCE', ; //X2_NOMEENG
	'C'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'E'	, ; //X2_MODOEMP
	'C'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WS2
//
aAdd( aSX2, { ;
	'WS2', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WS2'+cEmpr	, ; //X2_ARQUIVO
	'STATUS PEDIDOS ECOMMERCE', ; //X2_NOME
	'STATUS PEDIDOS ECOMMERCE', ; //X2_NOMESPA
	'STATUS PEDIDOS ECOMMERCE', ; //X2_NOMEENG
	'E'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'E'	, ; //X2_MODOEMP
	'E'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WS3
//
aAdd( aSX2, { ;
	'WS3', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WS3'+cEmpr	, ; //X2_ARQUIVO
	'FORMAS DE PAGAMENTO ECOMMERCE'		, ; //X2_NOME
	'FORMAS DE PAGAMENTO ECOMMERCE'		, ; //X2_NOMESPA
	'FORMAS DE PAGAMENTO ECOMMERCE'		, ; //X2_NOMEENG
	'C'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'E'	, ; //X2_MODOEMP
	'C'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WS4
//
aAdd( aSX2, { ;
	'WS4', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WS4'+cEmpr	, ; //X2_ARQUIVO
	'OPERADORAS PGTO ECOMMERCE', ; //X2_NOME
	'OPERADORAS PGTO ECOMMERCE', ; //X2_NOMESPA
	'OPERADORAS PGTO ECOMMERCE', ; //X2_NOMEENG
	'C'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'E'	, ; //X2_MODOEMP
	'C'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WS5
//
aAdd( aSX2, { ;
	'WS5', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WS5'+cEmpr	, ; //X2_ARQUIVO
	'Campos Especificos eCommerce'		, ; //X2_NOME
	'Campos Especificos eCommerce'		, ; //X2_NOMESPA
	'Campos Especificos eCommerce'		, ; //X2_NOMEENG
	'C'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'C'	, ; //X2_MODOEMP
	'C'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WS6
//
aAdd( aSX2, { ;
	'WS6', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WS6'+cEmpr	, ; //X2_ARQUIVO
	'Especificos X Produtos', ; //X2_NOME
	'Especificos X Produtos', ; //X2_NOMESPA
	'Especificos X Produtos', ; //X2_NOMEENG
	'C'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'C'	, ; //X2_MODOEMP
	'C'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WSA
//
aAdd( aSX2, { ;
	'WSA', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WSA'+cEmpr	, ; //X2_ARQUIVO
	'Pedidos eCommerce', ; //X2_NOME
	'Pedidos eCommerce', ; //X2_NOMESPA
	'Pedidos eCommerce', ; //X2_NOMEENG
	'E'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'E'	, ; //X2_MODOEMP
	'E'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WSB
//
aAdd( aSX2, { ;
	'WSB', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WSB'+cEmpr	, ; //X2_ARQUIVO
	'Itens Pedidos eCommerce', ; //X2_NOME
	'Itens Pedidos eCommerce', ; //X2_NOMESPA
	'Itens Pedidos eCommerce', ; //X2_NOMEENG
	'E'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'E'	, ; //X2_MODOEMP
	'E'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Tabela WSC
//
aAdd( aSX2, { ;
	'WSC', ; //X2_CHAVE
	cPath, ; //X2_PATH
	'WSC'+cEmpr	, ; //X2_ARQUIVO
	'Pagamentos eCommerce'	, ; //X2_NOME
	'Pagamentos eCommerce'	, ; //X2_NOMESPA
	'Pagamentos eCommerce'	, ; //X2_NOMEENG
	'E'	, ; //X2_MODO
	''	, ; //X2_TTS
	''	, ; //X2_ROTINA
	''	, ; //X2_PYME
	''	, ; //X2_UNICO
	''	, ; //X2_DISPLAY
	''	, ; //X2_SYSOBJ
	''	, ; //X2_USROBJ
	''	, ; //X2_POSLGT
	''	, ; //X2_CLOB
	''	, ; //X2_AUTREC
	'E'	, ; //X2_MODOEMP
	'E'	, ; //X2_MODOUN
	0	} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// Campos Tabela AGA
//
aAdd( aSX3, { ;
	'AGA', ; //X3_ARQUIVO
	'16', ; //X3_ORDEM
	'AGA_XIDEND', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id Endereco', ; //X3_TITULO
	'Id Endereco', ; //X3_TITSPA
	'Id Endereco', ; //X3_TITENG
	'Id Endereco', ; //X3_DESCRIC
	'Id Endereco', ; //X3_DESCSPA
	'Id Endereco', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192)		, ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SU5
//
aAdd( aSX3, { ;
	'SU5', ; //X3_ARQUIVO
	'76', ; //X3_ORDEM
	'U5_XIDEND'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id Endereco', ; //X3_TITULO
	'Id Endereco', ; //X3_TITSPA
	'Id Endereco', ; //X3_TITENG
	'Id Endereco', ; //X3_DESCRIC
	'Id Endereco', ; //X3_DESCSPA
	'Id Endereco', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192)		, ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela AY0
//
aAdd( aSX3, { ;
	'AY0', ; //X3_ARQUIVO
	'13', ; //X3_ORDEM
	'AY0_XIDCAT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id Categoria', ; //X3_TITULO
	'Id Categoria', ; //X3_TITSPA
	'Id Categoria', ; //X3_TITENG
	'Id Categoria', ; //X3_DESCRIC
	'Id Categoria', ; //X3_DESCSPA
	'Id Categoria', ; //X3_DESCENG
	'@E 9,999,999,999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'AY0', ; //X3_ARQUIVO
	'14', ; //X3_ORDEM
	'AY0_XDTEXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dta Exporta', ; //X3_TITULO
	'Dta Exporta', ; //X3_TITSPA
	'Dta Exporta', ; //X3_TITENG
	'Dta Exportacao eCommerce', ; //X3_DESCRIC
	'Dta Exportacao eCommerce', ; //X3_DESCSPA
	'Dta Exportacao eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'AY0', ; //X3_ARQUIVO
	'15', ; //X3_ORDEM
	'AY0_XHREXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hr. Exporta', ; //X3_TITULO
	'Hr. Exporta', ; //X3_TITSPA
	'Hr. Exporta', ; //X3_TITENG
	'Hora Exportacao eCommerce', ; //X3_DESCRIC
	'Hora Exportacao eCommerce', ; //X3_DESCSPA
	'Hora Exportacao eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela AY2
//
aAdd( aSX3, { ;
	'AY2', ; //X3_ARQUIVO
	'12', ; //X3_ORDEM
	'AY2_XDTEXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dta Exporta', ; //X3_TITULO
	'Dta Exporta', ; //X3_TITSPA
	'Dta Exporta', ; //X3_TITENG
	'Data Exporta eCommerce', ; //X3_DESCRIC
	'Data Exporta eCommerce', ; //X3_DESCSPA
	'Data Exporta eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'AY2', ; //X3_ARQUIVO
	'13', ; //X3_ORDEM
	'AY2_XHREXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hr. Exporta', ; //X3_TITULO
	'Hr. Exporta', ; //X3_TITSPA
	'Hr. Exporta', ; //X3_TITENG
	'Hora Exportacao eCommerce', ; //X3_DESCRIC
	'Hora Exportacao eCommerce', ; //X3_DESCSPA
	'Hora Exportacao eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'AY2', ; //X3_ARQUIVO
	'14', ; //X3_ORDEM
	'AY2_XIDMAR', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id Marca'	, ; //X3_TITULO
	'Id Marca'	, ; //X3_TITSPA
	'Id Marca'	, ; //X3_TITENG
	'Id Marca'	, ; //X3_DESCRIC
	'Id Marca'	, ; //X3_DESCSPA
	'Id Marca'	, ; //X3_DESCENG
	'@E 9,999,999,999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela AY3
//
aAdd( aSX3, { ;
	'AY3', ; //X3_ARQUIVO
	'22', ; //X3_ORDEM
	'AY3_OBRECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Obrig eComm', ; //X3_TITULO
	'Obrig eComm', ; //X3_TITSPA
	'Obrig eComm', ; //X3_TITENG
	'Obrigatorio eCommerce'	, ; //X3_DESCRIC
	'Obrigatorio eCommerce'	, ; //X3_DESCSPA
	'Obrigatorio eCommerce'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'AY3', ; //X3_ARQUIVO
	'23', ; //X3_ORDEM
	'AY3_XDTEXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dta Exporta', ; //X3_TITULO
	'Dta Exporta', ; //X3_TITSPA
	'Dta Exporta', ; //X3_TITENG
	'Dta Exportacao eCommerce', ; //X3_DESCRIC
	'Dta Exportacao eCommerce', ; //X3_DESCSPA
	'Dta Exportacao eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'AY3', ; //X3_ARQUIVO
	'24', ; //X3_ORDEM
	'AY3_XHREXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hr. Exporta', ; //X3_TITULO
	'Hr. Exporta', ; //X3_TITSPA
	'Hr. Exporta', ; //X3_TITENG
	'Hora Exportacao eCommerce', ; //X3_DESCRIC
	'Hora Exportacao eCommerce', ; //X3_DESCSPA
	'Hora Exportacao eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela AY4
//
aAdd( aSX3, { ;
	'AY4', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'AY4_ENVECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Envio eComm', ; //X3_TITULO
	'Envio eComm', ; //X3_TITSPA
	'Envio eComm', ; //X3_TITENG
	'Flag de envio eCommerce', ; //X3_DESCRIC
	'Flag de envio eCommerce', ; //X3_DESCSPA
	'Flag de envio eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Enviado;2=Enviado', ; //X3_CBOX
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXSPA
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'AY4', ; //X3_ARQUIVO
	'07', ; //X3_ORDEM
	'AY4_XDTEXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dta Exporta', ; //X3_TITULO
	'Dta Exporta', ; //X3_TITSPA
	'Dta Exporta', ; //X3_TITENG
	'Data Exporta eCommerce', ; //X3_DESCRIC
	'Data Exporta eCommerce', ; //X3_DESCSPA
	'Data Exporta eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'AY4', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'AY4_XHREXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hr. Exporta', ; //X3_TITULO
	'Hr. Exporta', ; //X3_TITSPA
	'Hr. Exporta', ; //X3_TITENG
	'Hora Exportacao eCommerce', ; //X3_DESCRIC
	'Hora Exportacao eCommerce', ; //X3_DESCSPA
	'Hora Exportacao eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SA1
//
aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'A1_NOME'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome', ; //X3_TITULO
	'Nombre'	, ; //X3_TITSPA
	'Name', ; //X3_TITENG
	'Nome do cliente', ; //X3_DESCRIC
	'Nombre del cliente'	, ; //X3_DESCSPA
	'Client Name', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	'FatVldStr()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(147) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'001', ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'09', ; //X3_ORDEM
	'A1_TIPO'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo', ; //X3_TITULO
	'Tipo', ; //X3_TITSPA
	'Type', ; //X3_TITENG
	'Tipo do Cliente', ; //X3_DESCRIC
	'Tipo de Cliente', ; //X3_DESCSPA
	'Type of Customer', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(135) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("FLRSX")', ; //X3_VLDUSER
	'F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao'		, ; //X3_CBOX
	'F=Cons.Final;L=Productor Rural;R=Revendedor;S=Solidario;X=Exportacion'		, ; //X3_CBOXSPA
	'F=Final Consumer;L=Rural Producer;R=Reseller;S=Solidary;X=Export'		, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'001', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'19', ; //X3_ORDEM
	'A1_ENDCOB'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End.Cobranca', ; //X3_TITULO
	'Dir.Cobranza', ; //X3_TITSPA
	'Collec.Addr.', ; //X3_TITENG
	'End.de cobr. do cliente', ; //X3_DESCRIC
	'Dir. de cobr. del cliente', ; //X3_DESCSPA
	'Custm.Collec.Address'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio().Or.texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'002', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'22', ; //X3_ORDEM
	'A1_ENDENT'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End.Entrega', ; //X3_TITULO
	'Direcc.Entre', ; //X3_TITSPA
	'Dil.Address', ; //X3_TITENG
	'End.de entr. do cliente', ; //X3_DESCRIC
	'Dir.de entr. del cliente', ; //X3_DESCSPA
	'Customer del.address'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(236) + Chr(128) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(144) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'002', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'23', ; //X3_ORDEM
	'A1_ENDREC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End.Recebto', ; //X3_TITULO
	'Dir.Cobro'	, ; //X3_TITSPA
	'Receiv.Addr.', ; //X3_TITENG
	'End.de Receb. do cliente', ; //X3_DESCRIC
	'Dir. de cobr. del cliente', ; //X3_DESCSPA
	'Custm.Receiv.Address'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(236) + Chr(128) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(144) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio().Or.texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'002', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'36', ; //X3_ORDEM
	'A1_COMIS'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'% Comissao', ; //X3_TITULO
	'% Comision', ; //X3_TITSPA
	'Commission %', ; //X3_TITENG
	'Aliquota de Comissao'	, ; //X3_DESCRIC
	'Alicuota de Comision'	, ; //X3_DESCSPA
	'Commission Rate', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'006', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'44', ; //X3_ORDEM
	'A1_TPFRET'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Frete', ; //X3_TITULO
	'Tipo Flete', ; //X3_TITSPA
	'Freight Type', ; //X3_TITENG
	'Tipo de Frete do cliente', ; //X3_DESCRIC
	'Tipo de Flete del cliente', ; //X3_DESCSPA
	'Freight Type', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(239) + Chr(253) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(147) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("CF")', ; //X3_VLDUSER
	'C=CIF;F=FOB', ; //X3_CBOX
	'C=CIF;F=FOB', ; //X3_CBOXSPA
	'C=CIF;F=FOB', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'008', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'46', ; //X3_ORDEM
	'A1_DESC'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desconto'	, ; //X3_TITULO
	'Descuento'	, ; //X3_TITSPA
	'Discount'	, ; //X3_TITENG
	'Desconto ao cliente'	, ; //X3_DESCRIC
	'Descuento al Cliente'	, ; //X3_DESCSPA
	'Discount to Customer'	, ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(239) + Chr(253) + Chr(143) + ;
	Chr(255) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(144) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'4'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'006', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'47', ; //X3_ORDEM
	'A1_PRIOR'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Prioridade', ; //X3_TITULO
	'Prioridad'	, ; //X3_TITSPA
	'Priority'	, ; //X3_TITENG
	'Prioridade do cliente'	, ; //X3_DESCRIC
	'Prioridad del Cliente'	, ; //X3_DESCSPA
	'Customer Priority', ; //X3_DESCENG
	'9'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(239) + Chr(253) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(144) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'entre("1","5")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'4'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'006', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'48', ; //X3_ORDEM
	'A1_RISCO'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Risco', ; //X3_TITULO
	'Riesgo'	, ; //X3_TITSPA
	'Risk', ; //X3_TITENG
	'Grau de Risco do cliente', ; //X3_DESCRIC
	'Grado de Riesgo do client', ; //X3_DESCSPA
	'Customer Risk Level'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("ABCDE ")'	, ; //X3_VLDUSER
	'A=Risco A;B=Risco B;C=Risco C;D=Risco D;E=Risco E'						, ; //X3_CBOX
	'A=Riesgo A;B=Riesgo B;C=Riesgo C;D=Riesgo D;E=Riesgo E'				, ; //X3_CBOXSPA
	'A=Risk A;B=Risk B;C=Risk C;D=Risk D;E=Risk E'							, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'4'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'006', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'49', ; //X3_ORDEM
	'A1_LC', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Lim. Credito', ; //X3_TITULO
	'Lim. Credito', ; //X3_TITSPA
	'Credit Limit', ; //X3_TITENG
	'Limite de Cred.do cliente', ; //X3_DESCRIC
	'Lim. de Cred. del Cliente', ; //X3_DESCSPA
	'Customer Credit Limit'	, ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'4'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'52', ; //X3_ORDEM
	'A1_LCFIN'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Lim Cred Sec', ; //X3_TITULO
	'Lim Cred Sec', ; //X3_TITSPA
	'Sec.Cred.Lim', ; //X3_TITENG
	'Lim Credito Secundario', ; //X3_DESCRIC
	'Lim Credito Secundario', ; //X3_DESCSPA
	'Secondary Credit Limit', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'4'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'73', ; //X3_ORDEM
	'A1_ATR'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Atrasados'	, ; //X3_TITULO
	'Retrasos'	, ; //X3_TITSPA
	'Delayed'	, ; //X3_TITENG
	'Valor dos Atrasos', ; //X3_DESCRIC
	'Valor de los Retrasos'	, ; //X3_DESCSPA
	'Value of Delays', ; //X3_DESCENG
	'@E 9,999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(239) + Chr(253) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(147) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'003', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'76', ; //X3_ORDEM
	'A1_TITPROT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tit.Protest.', ; //X3_TITULO
	'Tit.Protest.', ; //X3_TITSPA
	'Bill Protest', ; //X3_TITENG
	'Titulos Protestados'	, ; //X3_DESCRIC
	'Titulos Protestados'	, ; //X3_DESCSPA
	'Bills Protested', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(239) + Chr(253) + Chr(143) + ;
	Chr(255) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(147) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'003', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'78', ; //X3_ORDEM
	'A1_CHQDEVO', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cheques Dev.', ; //X3_TITULO
	'Cheques Dev.', ; //X3_TITSPA
	'Ret. Checks', ; //X3_TITENG
	'Numero de Cheques Devolv.', ; //X3_DESCRIC
	'Nº de cheques devueltos', ; //X3_DESCSPA
	'Number of Returned Checks', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(239) + Chr(253) + Chr(143) + ;
	Chr(255) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(147) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'003', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'83', ; //X3_ORDEM
	'A1_INCISS'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'ISS no Preco', ; //X3_TITULO
	'Imp.Servicio', ; //X3_TITSPA
	'ISS Included', ; //X3_TITENG
	'ISS incluso no preço'	, ; //X3_DESCRIC
	'Imp.Servicio en el Precio', ; //X3_DESCSPA
	'Price including ISS'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(239) + Chr(253) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(131) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("SN")', ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Si;N=No'	, ; //X3_CBOXSPA
	'S=Yes;N=No', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'005', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'91', ; //X3_ORDEM
	'A1_ALIQIR'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq. IRRF', ; //X3_TITULO
	'Alic. IRRF', ; //X3_TITSPA
	'IRRF TaxRate', ; //X3_TITENG
	'Aliquota IRRF', ; //X3_DESCRIC
	'Alicuota Imp. Ganancias', ; //X3_DESCSPA
	'IRRF Tax Rate', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'0'	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Entre(0,99.99)', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'005', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'96', ; //X3_ORDEM
	'A1_CALCSUF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc.p/Sufr.', ; //X3_TITULO
	'Desc.p/Sufr.', ; //X3_TITSPA
	'Disc Sufr.', ; //X3_TITENG
	'Calcula Desc. p/ Suframa', ; //X3_DESCRIC
	'Calcula Desc. p/ Suframa', ; //X3_DESCSPA
	'Calculate Disc. Suframa', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(255) + Chr(255) + Chr(239) + Chr(253) + Chr(143) + ;
	Chr(255) + Chr(240) + Chr(128) + Chr(132) + Chr(128) + ;
	Chr(131) + Chr(128) + Chr(160) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("SNI")', ; //X3_VLDUSER
	'S=Sim;N=Nao;I=ICMS'	, ; //X3_CBOX
	'S=Si;N=No;I=ICMS', ; //X3_CBOXSPA
	'S=Yes;N=No;I=ICMS', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'005', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'H9', ; //X3_ORDEM
	'A1_TIPOCLI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Cliente', ; //X3_TITULO
	'Tipo Cliente', ; //X3_TITSPA
	'CustomerType', ; //X3_TITENG
	'Tipo do Cliente', ; //X3_DESCRIC
	'Tipo de Cliente', ; //X3_DESCSPA
	'Customer Type', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	'FG_STRZERO("M->A1_TIPOCLI",2).and. naovazio() .and. EXISTCPO("SX5","TC"+M->A1_TIPOCLI)', ; //X3_VALID
	Chr(128) + Chr(137) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(130) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'TC', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'FG_STRZERO("M->A1_TIPOCLI",2) .AND. naovazio() .and. EXISTCPO("SX5","TC"+M->A1_TIPOCLI)', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'008', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'K3', ; //X3_ORDEM
	'A1_MSEXP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ident.Exp.', ; //X3_TITULO
	'Ident.Exp.', ; //X3_TITSPA
	'Ident.Exp.', ; //X3_TITENG
	'Ident.Exp.Dados', ; //X3_DESCRIC
	'Ident.Exp.Dados', ; //X3_DESCSPA
	'Ident.Exp.Dados', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	9	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'L'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	'008', ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'Q0', ; //X3_ORDEM
	'A1_XLOGIN'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	200	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Login Portal', ; //X3_TITULO
	'Login Portal', ; //X3_TITSPA
	'Login Portal', ; //X3_TITENG
	'Login Portal', ; //X3_DESCRIC
	'Login Portal', ; //X3_DESCSPA
	'Login Portal', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'Q1', ; //X3_ORDEM
	'A1_XSENHA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	200	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Senha Portal', ; //X3_TITULO
	'Senha Portal', ; //X3_TITSPA
	'Senha Portal', ; //X3_TITENG
	'Senha Portal', ; //X3_DESCRIC
	'Senha Portal', ; //X3_DESCSPA
	'Senha Portal', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1', ; //X3_ARQUIVO
	'Q2', ; //X3_ORDEM
	'A1_HREXP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora Exp'	, ; //X3_TITULO
	'Hora Exp'	, ; //X3_TITSPA
	'Hora Exp'	, ; //X3_TITENG
	'Hora da Exportacao'	, ; //X3_DESCRIC
	'Hora da Exportacao'	, ; //X3_DESCSPA
	'Hora da Exportacao'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SA4
//
aAdd( aSX3, { ;
	'SA4', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'A4_NOME'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome', ; //X3_TITULO
	'Nombre'	, ; //X3_TITSPA
	'Name', ; //X3_TITENG
	'Nome da transportadora', ; //X3_DESCRIC
	'Nombre de Transportadora', ; //X3_DESCSPA
	'Name of Carrier', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(147) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA4', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'A4_NREDUZ'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome Reduz.', ; //X3_TITULO
	'Nomb  Reduc.', ; //X3_TITSPA
	'Short Name', ; //X3_TITENG
	'Nome reduzido da transp.', ; //X3_DESCRIC
	'Nombre Reducido Trsnp.', ; //X3_DESCSPA
	'Carrier Short Name'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(146) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA4', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'A4_VIA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Via Transp.', ; //X3_TITULO
	'Medio Transp', ; //X3_TITSPA
	'Mean Transp.', ; //X3_TITENG
	'Via de Transporte', ; //X3_DESCRIC
	'Medio de Transporte'	, ; //X3_DESCSPA
	'Means of Transport'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(146) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA4', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'A4_END'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Endereco'	, ; //X3_TITULO
	'Direccion'	, ; //X3_TITSPA
	'Address'	, ; //X3_TITENG
	'Endereco da Transportad.', ; //X3_DESCRIC
	'Direccion da Transportad.', ; //X3_DESCSPA
	'Carrier Address', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(146) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA4', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'A4_MUN'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Municipio'	, ; //X3_TITULO
	'Municipio'	, ; //X3_TITSPA
	'City', ; //X3_TITENG
	'Municipio da Transportad.', ; //X3_DESCRIC
	'Municipio de la Transport', ; //X3_DESCSPA
	'Carrier City', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA4', ; //X3_ARQUIVO
	'11', ; //X3_ORDEM
	'A4_CEP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'CEP', ; //X3_TITULO
	'CP', ; //X3_TITSPA
	'Zip Code'	, ; //X3_TITENG
	'Cod Enderecamento Postal', ; //X3_DESCRIC
	'Cod Direccion Postal'	, ; //X3_DESCSPA
	'Zip Code'	, ; //X3_DESCENG
	'@R 99999-999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(146) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'naovazio()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SA4', ; //X3_ARQUIVO
	'20', ; //X3_ORDEM
	'A4_CONTATO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Contato'	, ; //X3_TITULO
	'Contacto'	, ; //X3_TITSPA
	'Contact'	, ; //X3_TITENG
	'Contato na transportadora', ; //X3_DESCRIC
	'Contacto en el Transport.', ; //X3_DESCSPA
	'Carrier Contact', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

//
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'B1_DESC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	80	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descripcion', ; //X3_TITSPA
	'Description', ; //X3_TITENG
	'Descricao do Produto'	, ; //X3_DESCRIC
	'Descripcion del Producto', ; //X3_DESCSPA
	'Description of Product', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(151) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'10', ; //X3_ORDEM
	'B1_IPI'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq. IPI'	, ; //X3_TITULO
	'Alic. IPI'	, ; //X3_TITSPA
	'IPI Tax Rate', ; //X3_TITENG
	'Alíquota de IPI', ; //X3_DESCRIC
	'Alicuota de IPI', ; //X3_DESCSPA
	'IPI Tax Rate', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(188) + Chr(255) + Chr(128) + Chr(129) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(144) + Chr(128) + Chr(128) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(142) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'16', ; //X3_ORDEM
	'B1_CODISS'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod.Serv.ISS', ; //X3_TITULO
	'Cod.Serv.ISS', ; //X3_TITSPA
	'ISS Sev.Cd.', ; //X3_TITENG
	'Código de Serviço do ISS', ; //X3_DESCRIC
	'Codigo de Servicio de ISS', ; //X3_DESCSPA
	'ISS Service Code', ; //X3_DESCENG
	'@9', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(188) + Chr(247) + Chr(128) + Chr(161) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'60', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(146) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'vazio() .or. existcpo("SX5","60"+M->B1_CODISS)'						, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'023', ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'19', ; //X3_ORDEM
	'B1_PICMRET', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Solid. Saida', ; //X3_TITULO
	'Solid.Salida', ; //X3_TITSPA
	'Solid. Outfl', ; //X3_TITENG
	'% Lucro Calc. Solid.Saida', ; //X3_DESCRIC
	'%Ganc.Calc. Solid.Salida', ; //X3_DESCSPA
	'Solid. Outf. Prof.Calc. %', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'20', ; //X3_ORDEM
	'B1_PICMENT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Solid. Entr.', ; //X3_TITULO
	'Solid.Entrad', ; //X3_TITSPA
	'Solid. Infl.', ; //X3_TITENG
	'% Lucro Calc. Solid.Entr.', ; //X3_DESCRIC
	'%Ganc.Calc. Solid.Entrada', ; //X3_DESCSPA
	'Solid. Infl. Prof. Cal. %', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'24', ; //X3_ORDEM
	'B1_CONV'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Fator Conv.', ; //X3_TITULO
	'Factor Conv.', ; //X3_TITSPA
	'Conv. Factor', ; //X3_TITENG
	'Fator de Conversao de UM', ; //X3_DESCRIC
	'Factor Conversion de UM', ; //X3_DESCSPA
	'Convers.Factor Un.Measure', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'27', ; //X3_ORDEM
	'B1_QE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Qtd.Embalag.', ; //X3_TITULO
	'Ctd.Embalaje', ; //X3_TITSPA
	'Qty.Package', ; //X3_TITENG
	'Qtde por Embalagem'	, ; //X3_DESCRIC
	'Cantidad por Embalaje'	, ; //X3_DESCSPA
	'Quantity per Package'	, ; //X3_DESCENG
	'@E 999,999,999', ; //X3_PICTURE
	'A010Mult()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'28', ; //X3_ORDEM
	'B1_PRV1'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Preco Venda', ; //X3_TITULO
	'Precio Venta', ; //X3_TITSPA
	'Sales Price', ; //X3_TITENG
	'Preco de Venda', ; //X3_DESCRIC
	'Precio de Venta', ; //X3_DESCSPA
	'Sales Price', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	'A010Preco()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'29', ; //X3_ORDEM
	'B1_EMIN'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Ponto Pedido', ; //X3_TITULO
	'Punto Pedido', ; //X3_TITSPA
	'Order Point', ; //X3_TITENG
	'Ponto de Pedido', ; //X3_DESCRIC
	'Punto de Pedido', ; //X3_DESCSPA
	'Order Point', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'36', ; //X3_ORDEM
	'B1_ESTSEG'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Seguranca'	, ; //X3_TITULO
	'Seguridad'	, ; //X3_TITSPA
	'Safety Inv.', ; //X3_TITENG
	'Estoque de Seguranca'	, ; //X3_DESCRIC
	'Stock de Seguridad'	, ; //X3_DESCSPA
	'Security Inventory'	, ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'39', ; //X3_ORDEM
	'B1_PE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Entrega'	, ; //X3_TITULO
	'Entrega'	, ; //X3_TITSPA
	'Deliv.Term', ; //X3_TITENG
	'Prazo de Entrega', ; //X3_DESCRIC
	'Plazo de Entrega', ; //X3_DESCSPA
	'Delivery Term', ; //X3_DESCENG
	'@E 99999'	, ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'40', ; //X3_ORDEM
	'B1_TIPE'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Prazo', ; //X3_TITULO
	'Tipo Plazo', ; //X3_TITSPA
	'Type of Term', ; //X3_TITENG
	'Tipo Prazo entrega(D/M/A)', ; //X3_DESCRIC
	'Tipo Plazo Entrega(D/M/A)', ; //X3_DESCSPA
	'Type of Deliv.Term(D/M/Y)', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("HDSMA")', ; //X3_VLDUSER
	'H=Horas;D=Dias;S=Semana;M=Mes;A=Ano', ; //X3_CBOX
	'H=Horas;D=Dias;S=Semana;M=Mes;A=A±o', ; //X3_CBOXSPA
	'H=Hours;D=Days;S=Week;M=Month;A=Year', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'41', ; //X3_ORDEM
	'B1_LE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Lote Econom.', ; //X3_TITULO
	'Lote Econom.', ; //X3_TITSPA
	'Economic Lot', ; //X3_TITENG
	'Lote Economico', ; //X3_DESCRIC
	'Lote Economico', ; //X3_DESCSPA
	'Economic Lot', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	'A010Mult()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'42', ; //X3_ORDEM
	'B1_LM', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Lote Minimo', ; //X3_TITULO
	'Lote Minimo', ; //X3_TITSPA
	'Minimum Lot', ; //X3_TITENG
	'Lote Minimo', ; //X3_DESCRIC
	'Lote Minimo', ; //X3_DESCSPA
	'Minimum Lot', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'51', ; //X3_ORDEM
	'B1_APROPRI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Apropriacao', ; //X3_TITULO
	'Asignación', ; //X3_TITSPA
	'Appropriat.', ; //X3_TITENG
	'Apropr.Direta ou Indireta', ; //X3_DESCRIC
	'Asig. Directa o Indirect', ; //X3_DESCSPA
	'Dir./Indir. Appropriation', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("DI ")', ; //X3_VLDUSER
	'D=Direto;I=Indireto'	, ; //X3_CBOX
	'D=Directa;I=Indirecta'	, ; //X3_CBOXSPA
	'D=Direct;I=Indirect'	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'55', ; //X3_ORDEM
	'B1_FANTASM', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Fantasma'	, ; //X3_TITULO
	'Fantasma'	, ; //X3_TITSPA
	'Phantom'	, ; //X3_TITENG
	"Informa 'S' se e' fantasm", ; //X3_DESCRIC
	"Informe 'S'si es Fantasma", ; //X3_DESCSPA
	"Type 'S' if it's Phantom", ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("SN ")', ; //X3_VLDUSER
	'S=Sim;&N=Nao', ; //X3_CBOX
	'S=Si;&N=No', ; //X3_CBOXSPA
	'S=Yes;&N=No', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'59', ; //X3_ORDEM
	'B1_FORAEST', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Fora estado', ; //X3_TITULO
	'Fuera E/P/R', ; //X3_TITSPA
	'Out state'	, ; //X3_TITENG
	'S-se comprado fora estado', ; //X3_DESCRIC
	'S-compra fuera del E/P/R', ; //X3_DESCSPA
	'S-if bought out state'	, ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(188) + Chr(255) + Chr(128) + Chr(129) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("SN")', ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sí;N=No'	, ; //X3_CBOXSPA
	'Y=Yes;N=No', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'65', ; //X3_ORDEM
	'B1_MRP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Entra MRP'	, ; //X3_TITULO
	'Entra MRP'	, ; //X3_TITSPA
	'Enter MRP'	, ; //X3_TITENG
	'Entra no Mrp?', ; //X3_DESCRIC
	'¿Entra en el Mrp?', ; //X3_DESCSPA
	'Enters in MRP?', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"S"', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Pertence(" SNE")', ; //X3_VLDUSER
	'S=Sim;N=Nao;E=Especial', ; //X3_CBOX
	'S=Sí;N=No;E=Especial'	, ; //X3_CBOXSPA
	'S=Yes;N=No;E=Special'	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'70', ; //X3_ORDEM
	'B1_CONTSOC', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cont.Seg.Soc', ; //X3_TITULO
	'Cont.Seg.Soc', ; //X3_TITSPA
	'Soc.Sec.Cont', ; //X3_TITENG
	'Incide Contr.Seg.Social', ; //X3_DESCRIC
	'Incide Contr.Seg.Social', ; //X3_DESCSPA
	'Incise Social Sec. Contr.', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Pertence("SN")', ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Si;N=No'	, ; //X3_CBOXSPA
	'S=Yes;N=No', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'71', ; //X3_ORDEM
	'B1_IRRF'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Impos.Renda', ; //X3_TITULO
	'Imp.Ganancia', ; //X3_TITSPA
	'Income Tax', ; //X3_TITENG
	'Incide imposto renda'	, ; //X3_DESCRIC
	'Incide Imp. a las Gananc.', ; //X3_DESCSPA
	'Income Tax Incidence'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(188) + Chr(255) + Chr(128) + Chr(129) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(131) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Pertence("SN")', ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Si;N=No'	, ; //X3_CBOXSPA
	'S=Yes;N=No', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'C3', ; //X3_ORDEM
	'B1_PCSLL'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Perc. CSLL', ; //X3_TITULO
	'Pord. CSLL', ; //X3_TITSPA
	'CSLL %'	, ; //X3_TITENG
	'Percentual CSLL', ; //X3_DESCRIC
	'Porcentaje CSLL', ; //X3_DESCSPA
	'CSLL Percentage', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'C4', ; //X3_ORDEM
	'B1_PCOFINS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Perc. COFINS', ; //X3_TITULO
	'Porc. COFINS', ; //X3_TITSPA
	'COFINS %'	, ; //X3_TITENG
	'Percentual COFINS', ; //X3_DESCRIC
	'Porcentaje COFINS', ; //X3_DESCSPA
	'COFFINS Percentage'	, ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'C5', ; //X3_ORDEM
	'B1_PPIS'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Perc. PIS'	, ; //X3_TITULO
	'Porc. PIS'	, ; //X3_TITSPA
	'PIS %', ; //X3_TITENG
	'Percentual PIS', ; //X3_DESCRIC
	'Porcentaje PIS', ; //X3_DESCSPA
	'PIS Percentage', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'E6', ; //X3_ORDEM
	'B1_PESBRU'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	11	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'Peso Bruto', ; //X3_TITULO
	'Peso Bruto', ; //X3_TITSPA
	'Gross Weight', ; //X3_TITENG
	'Peso Bruto', ; //X3_DESCRIC
	'Peso Bruto', ; //X3_DESCSPA
	'Gross Weight', ; //X3_DESCENG
	'@E 999,999.9999', ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'M8', ; //X3_ORDEM
	'B1_CRDEST'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Crd Estímulo', ; //X3_TITULO
	'Crd Estímulo', ; //X3_TITSPA
	'Crd Incentiv', ; //X3_TITENG
	'Crédito Estímulo', ; //X3_DESCRIC
	'Crédito Estímulo', ; //X3_DESCSPA
	'Credit Incentive', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	'Positivo()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(198) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'Q0', ; //X3_ORDEM
	'B1_MSEXP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ident.Exp.', ; //X3_TITULO
	'Ident.Exp.', ; //X3_TITSPA
	'Ident.Exp.', ; //X3_TITENG
	'Ident.Exp.Dados', ; //X3_DESCRIC
	'Ident.Exp.Dados', ; //X3_DESCSPA
	'Ident.Exp.Dados', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	9	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'L'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1', ; //X3_ARQUIVO
	'S9', ; //X3_ORDEM
	'B1_HREXP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora Exp'	, ; //X3_TITULO
	'Hora Exp'	, ; //X3_TITSPA
	'Hora Exp'	, ; //X3_TITENG
	'Hora da Exportacao'	, ; //X3_DESCRIC
	'Hora da Exportacao'	, ; //X3_DESCSPA
	'Hora da Exportacao'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SB2
//
aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'39', ; //X3_ORDEM
	'B2_CMFF1'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit.FIFO1', ; //X3_TITULO
	'C Unit.FIFO1', ; //X3_TITSPA
	'FIFO1 Unit C', ; //X3_TITENG
	'Custo Unit. do prod. FIFO', ; //X3_DESCRIC
	'Costo Unit. prod. FIFO', ; //X3_DESCSPA
	'Unit Cost of FIFO prod.', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(146) + Chr(129) + ;
	Chr(128) + Chr(192) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'40', ; //X3_ORDEM
	'B2_CMFF2'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit.FIFO2', ; //X3_TITULO
	'C Unit.FIFO2', ; //X3_TITSPA
	'FIFO2 Unit C', ; //X3_TITENG
	'Custo Unit. do prod. FIFO', ; //X3_DESCRIC
	'Costo Unit. prod. FIFO', ; //X3_DESCSPA
	'Unit Cost of FIFO prod.', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(146) + Chr(129) + ;
	Chr(128) + Chr(192) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'41', ; //X3_ORDEM
	'B2_CMFF3'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit.FIFO3', ; //X3_TITULO
	'C Unit.FIFO3', ; //X3_TITSPA
	'FIFO3 Unit C', ; //X3_TITENG
	'Custo Unit. do prod. FIFO', ; //X3_DESCRIC
	'Costo Unit. prod. FIFO', ; //X3_DESCSPA
	'Unit Cost of FIFO prod.', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(146) + Chr(129) + ;
	Chr(128) + Chr(192) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'42', ; //X3_ORDEM
	'B2_CMFF4'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit.FIFO4', ; //X3_TITULO
	'C Unit.FIFO4', ; //X3_TITSPA
	'FIFO4 Unit C', ; //X3_TITENG
	'Custo Unit. do prod. FIFO', ; //X3_DESCRIC
	'Costo Unit. prod. FIFO', ; //X3_DESCSPA
	'Unit Cost of FIFO prod.', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(146) + Chr(129) + ;
	Chr(128) + Chr(192) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'43', ; //X3_ORDEM
	'B2_CMFF5'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit.FIFO5', ; //X3_TITULO
	'C Unit.FIFO5', ; //X3_TITSPA
	'FIFO5 Unit C', ; //X3_TITENG
	'Custo Unit. do prod. FIFO', ; //X3_DESCRIC
	'Costo Unit. prod. FIFO', ; //X3_DESCSPA
	'Unit Cost of FIFO prod.', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(146) + Chr(129) + ;
	Chr(128) + Chr(192) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'64', ; //X3_ORDEM
	'B2_CMFIM1'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit 1a M', ; //X3_TITULO
	'C Unit 1a M', ; //X3_TITSPA
	'Unit C 1st M', ; //X3_TITENG
	'Custo unitario do produto', ; //X3_DESCRIC
	'Costo unitario producto', ; //X3_DESCSPA
	'Product Unit Cost', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(156) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'65', ; //X3_ORDEM
	'B2_CMFIM2'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit 2a M', ; //X3_TITULO
	'C Unit 2a M', ; //X3_TITSPA
	'Unit C 2nd M', ; //X3_TITENG
	'Custo unitario do produto', ; //X3_DESCRIC
	'Costo unitario producto', ; //X3_DESCSPA
	'Product Unit Cost', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(156) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'66', ; //X3_ORDEM
	'B2_CMFIM3'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit 3a M', ; //X3_TITULO
	'C Unit 3a M', ; //X3_TITSPA
	'Unit C 3rd M', ; //X3_TITENG
	'Custo unitario do produto', ; //X3_DESCRIC
	'Costo unitario producto', ; //X3_DESCSPA
	'Product Unit Cost', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(156) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'67', ; //X3_ORDEM
	'B2_CMFIM4'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit 4a M', ; //X3_TITULO
	'C Unit 4a M', ; //X3_TITSPA
	'Unit C 4th M', ; //X3_TITENG
	'Custo unitario do produto', ; //X3_DESCRIC
	'Costo unitario producto', ; //X3_DESCSPA
	'Product Unit Cost', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(156) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'68', ; //X3_ORDEM
	'B2_CMFIM5'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'C Unit 5a M', ; //X3_TITULO
	'C Unit 5a M', ; //X3_TITSPA
	'Unit C 5th M', ; //X3_TITENG
	'Custo unitario do produto', ; //X3_DESCRIC
	'Costo unitario producto', ; //X3_DESCSPA
	'Product Unit Cost', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(156) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'70', ; //X3_ORDEM
	'B2_CMRP1'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'Rep. Unit.', ; //X3_TITULO
	'Rep. Unit.', ; //X3_TITSPA
	'Unit Rep.'	, ; //X3_TITENG
	'Custo Unitario Reposicao', ; //X3_DESCRIC
	'Costo Unitario Reposicion', ; //X3_DESCSPA
	'Unit Replacement Cost'	, ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	"IIF(Subs(M->B2_COD,1,3)!='MOD',.F.,.T.)"								, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'72', ; //X3_ORDEM
	'B2_CMRP2'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'Rep.Uni.2a M', ; //X3_TITULO
	'Rep.Uni.2a M', ; //X3_TITSPA
	'U.Rep. 2nd C', ; //X3_TITENG
	'Rep. Unit. na 2a. Moeda', ; //X3_DESCRIC
	'Rep. Unit. en 2a. Moneda', ; //X3_DESCSPA
	'Unit Rep. 2nd Currency', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	"IIF(Subs(M->B2_COD,1,3)!='MOD',.F.,.T.)"								, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'74', ; //X3_ORDEM
	'B2_CMRP3'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'Rep.Uni.3a M', ; //X3_TITULO
	'Rep.Uni.3a M', ; //X3_TITSPA
	'U.Rep. 3rd C', ; //X3_TITENG
	'Rep. Unit. na 3a. Moeda', ; //X3_DESCRIC
	'Rep. Unit. en 3a. Moneda', ; //X3_DESCSPA
	'Unit Rep. 3rd Currency', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	"IIF(Subs(M->B2_COD,1,3)!='MOD',.F.,.T.)"								, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'76', ; //X3_ORDEM
	'B2_CMRP4'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'Rep.Uni.4a M', ; //X3_TITULO
	'Rep.Uni.4a M', ; //X3_TITSPA
	'U.Rep. 4th C', ; //X3_TITENG
	'Rep. Unit. na 4a. Moeda', ; //X3_DESCRIC
	'Rep. Unit. en 4a. Moneda', ; //X3_DESCSPA
	'Unit Rep. 4th Currency', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	"IIF(Subs(M->B2_COD,1,3)!='MOD',.F.,.T.)"								, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'78', ; //X3_ORDEM
	'B2_CMRP5'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'Rep.Uni.5a M', ; //X3_TITULO
	'Rep.Uni.5a M', ; //X3_TITSPA
	'U.Rep. 5th C', ; //X3_TITENG
	'Rep. Unit. na 5a. Moeda', ; //X3_DESCRIC
	'Rep. Unit. en 5a. Moneda', ; //X3_DESCSPA
	'Unit Rep. 5th Currency', ; //X3_DESCENG
	'@E 999,999,999.9999'	, ; //X3_PICTURE
	"IIF(Subs(M->B2_COD,1,3)!='MOD',.F.,.T.)"								, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'IIF(Subs(M->B2_COD,1,3)!="MOD",.F.,.T.)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'83', ; //X3_ORDEM
	'B2_MSEXP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ident.Exp.', ; //X3_TITULO
	'Ident.Exp.', ; //X3_TITSPA
	'Ident.Exp.', ; //X3_TITENG
	'Ident.Exp.Dados', ; //X3_DESCRIC
	'Ident.Exp.Dados', ; //X3_DESCSPA
	'Ident.Exp.Dados', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	9	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'L'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB2', ; //X3_ARQUIVO
	'87', ; //X3_ORDEM
	'B2_HREXP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora Exp'	, ; //X3_TITULO
	'Hora Exp'	, ; //X3_TITSPA
	'Hora Exp'	, ; //X3_TITENG
	'Hora da Exportacao'	, ; //X3_DESCRIC
	'Hora da Exportacao'	, ; //X3_DESCSPA
	'Hora da Exportacao'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SB4
//
aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'B4_DESC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descripcion', ; //X3_TITSPA
	'Description', ; //X3_TITENG
	'Descricao do Produto'	, ; //X3_DESCRIC
	'Descripcion del Producto', ; //X3_DESCSPA
	'Description of Product', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(147) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'21', ; //X3_ORDEM
	'B4_FORAEST', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Fora estado', ; //X3_TITULO
	'Fuera Estado', ; //X3_TITSPA
	'Out of State', ; //X3_TITENG
	'S-se comprado fora estado', ; //X3_DESCRIC
	'S:si Comprado Fuera Estad', ; //X3_DESCSPA
	'Y-if Purch. out of State', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("SN")', ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Si;N=No'	, ; //X3_CBOXSPA
	'S=Yes;N=No', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'24', ; //X3_ORDEM
	'B4_PICM'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq. ICMS', ; //X3_TITULO
	'Alic. ICMS', ; //X3_TITSPA
	'ICMS Tx.Rate', ; //X3_TITENG
	'Alíquota de ICMS', ; //X3_DESCRIC
	'Alicuota de ICMS', ; //X3_DESCSPA
	'ICMS Tax Rate', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("0,7,12,17,18,25")'		, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'32', ; //X3_ORDEM
	'B4_IRRF'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Impos.Renda', ; //X3_TITULO
	'Imp.Ganancia', ; //X3_TITSPA
	'Income Tax', ; //X3_TITENG
	'Incide imposto renda'	, ; //X3_DESCRIC
	'Incide Imp. a las Gananc.', ; //X3_DESCSPA
	'Income Tax Incidence'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Pertence("SN")', ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Si;N=No'	, ; //X3_CBOXSPA
	'S=Yes;N=No', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'36', ; //X3_ORDEM
	'B4_01CAT1'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Grupo Linha', ; //X3_TITULO
	'Grupo linea', ; //X3_TITSPA
	'Line Group', ; //X3_TITENG
	'Grupo Linha', ; //X3_DESCRIC
	'Grupo linea', ; //X3_DESCSPA
	'Line Group', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY0DEP'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B4_01CAT1,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	'INCLUI'	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'37', ; //X3_ORDEM
	'B4_01DCAT1', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Grupo', ; //X3_TITULO
	'Desc. Grupo', ; //X3_TITSPA
	'Desc. Group', ; //X3_TITENG
	'Descricao Linha', ; //X3_DESCRIC
	'Descripcion linea', ; //X3_DESCSPA
	'Line Description', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B4_01CAT1, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'38', ; //X3_ORDEM
	'B4_01CAT2'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Linha', ; //X3_TITULO
	'Linea', ; //X3_TITSPA
	'Row', ; //X3_TITENG
	'Linha', ; //X3_DESCRIC
	'Linea', ; //X3_DESCSPA
	'Row', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY1LIN'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B4_01CAT2,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	'INCLUI'	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'39', ; //X3_ORDEM
	'B4_01DCAT2', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Linha', ; //X3_TITULO
	'Desc. Linea', ; //X3_TITSPA
	'Desc. Line', ; //X3_TITENG
	'Desc. Linha', ; //X3_DESCRIC
	'Desc. Linea', ; //X3_DESCSPA
	'Desc. Line', ; //X3_DESCENG
	'@S25!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B4_01CAT2, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'40', ; //X3_ORDEM
	'B4_01CAT3'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Seção', ; //X3_TITULO
	'Seccion'	, ; //X3_TITSPA
	'Section'	, ; //X3_TITENG
	'Seção', ; //X3_DESCRIC
	'Seccion'	, ; //X3_DESCSPA
	'Section'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY1SEC'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B4_01CAT3,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	'INCLUI'	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'41', ; //X3_ORDEM
	'B4_01DCAT3', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Seção', ; //X3_TITULO
	'Desc. Seccio', ; //X3_TITSPA
	'Desc. Sectio', ; //X3_TITENG
	'Desc. Seção', ; //X3_DESCRIC
	'Desc. Seccion', ; //X3_DESCSPA
	'Desc. Section', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B4_01CAT3, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'42', ; //X3_ORDEM
	'B4_01CAT4'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Espécie'	, ; //X3_TITULO
	'Especie'	, ; //X3_TITSPA
	'Species'	, ; //X3_TITENG
	'Espécie'	, ; //X3_DESCRIC
	'Especie'	, ; //X3_DESCSPA
	'Species'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY1ESP'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B4_01CAT4,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	'INCLUI'	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'43', ; //X3_ORDEM
	'B4_01DCAT4', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Espéci', ; //X3_TITULO
	'Desc. Espec.', ; //X3_TITSPA
	'Desc. Specie', ; //X3_TITENG
	'Desc. Espécie', ; //X3_DESCRIC
	'Desc. Especie', ; //X3_DESCSPA
	'Desc. Species', ; //X3_DESCENG
	'@S25!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B4_01CAT4, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'44', ; //X3_ORDEM
	'B4_01CAT5'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sub-Espécie', ; //X3_TITULO
	'Subespecie', ; //X3_TITSPA
	'Sub-Species', ; //X3_TITENG
	'Sub-Espécie', ; //X3_DESCRIC
	'Subespecie', ; //X3_DESCSPA
	'Sub-Species', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY1SUB'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B4_01CAT5,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	'INCLUI'	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'45', ; //X3_ORDEM
	'B4_01DCAT5', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Sub-Es', ; //X3_TITULO
	'Desc. Subesp', ; //X3_TITSPA
	'Desc. Sub-Sp', ; //X3_TITENG
	'Desc. Sub-Espécie', ; //X3_DESCRIC
	'Desc. Subespecie', ; //X3_DESCSPA
	'Desc. Sub-Species', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B4_01CAT5, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'46', ; //X3_ORDEM
	'B4_01CODMA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Marca', ; //X3_TITULO
	'Marca', ; //X3_TITSPA
	'Brand', ; //X3_TITENG
	'Marca', ; //X3_DESCRIC
	'Marca', ; //X3_DESCSPA
	'Brand', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY2', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	'ExistCpo("AY2")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'47', ; //X3_ORDEM
	'B4_01DESMA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Marca', ; //X3_TITULO
	'Desc. Marca', ; //X3_TITSPA
	'Desc. Brand', ; //X3_TITENG
	'Desc. Marca', ; //X3_DESCRIC
	'Desc. Marca', ; //X3_DESCSPA
	'Desc. Brand', ; //X3_DESCENG
	'@S25!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"",POSICIONE("AY2",1,XFILIAL("AY2")+SB4->B4_01CODMA,"AY2_DESCR"))', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	'POSICIONE("AY2",1,XFILIAL("AY2")+SB4->B4_01CODMA,"AY2_DESCR")'			, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'48', ; //X3_ORDEM
	'B4_01COLEC', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Coleção'	, ; //X3_TITULO
	'Coleccion'	, ; //X3_TITSPA
	'Collection', ; //X3_TITENG
	'Coleção'	, ; //X3_DESCRIC
	'Coleccion'	, ; //X3_DESCSPA
	'Collection', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	'ExistCpo("AYH")', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AYH', ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'49', ; //X3_ORDEM
	'B4_PROC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Fornecedor', ; //X3_TITULO
	'Prove.Estand', ; //X3_TITSPA
	'Supplier'	, ; //X3_TITENG
	'Fornecedor Padrao', ; //X3_DESCRIC
	'Proveedor Estandar'	, ; //X3_DESCSPA
	'Standard Supplier', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA2_2', ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	'EXISTCPO("SA2")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'50', ; //X3_ORDEM
	'B4_LOJPROC', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Loja Forn.', ; //X3_TITULO
	'Loja Padrao', ; //X3_TITSPA
	'Loja Forn.', ; //X3_TITENG
	'Loja Fornecedor Padrao', ; //X3_DESCRIC
	'Loja Fornecedor Padrao', ; //X3_DESCSPA
	'Loja Fornecedor Padrao', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	'ExistCpo("SA2",M->B4_PROC+M->B4_LOJPROC)'								, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'51', ; //X3_ORDEM
	'B4_NOMFOR'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome Fornece', ; //X3_TITULO
	'Nome Fornece', ; //X3_TITSPA
	''	, ; //X3_TITENG
	'Nome Fornecedor', ; //X3_DESCRIC
	'Nome Fornecedor', ; //X3_DESCSPA
	'Nome Fornecedor', ; //X3_DESCENG
	'@S25!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"",POSICIONE("SA2",1,XFILIAL("SA2")+SB4->B4_PROC+SB4->B4_LOJPROC,"A2_NREDUZ"))', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	'POSICIONE("SA2",1,XFILIAL("SA2")+SB4->B4_PROC+SB4->B4_LOJPROC,"A2_NOME")'	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'52', ; //X3_ORDEM
	'B4_01UTGRD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Util. Grade?', ; //X3_TITULO
	'¿Util. Grill', ; //X3_TITSPA
	'Use Grid?'	, ; //X3_TITENG
	'Utiliza Grade', ; //X3_DESCRIC
	'Util. Grilla', ; //X3_DESCSPA
	'Use Grid'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	'Pertence("SN")', ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'53', ; //X3_ORDEM
	'B4_01DTCAD', ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Data Cadastr', ; //X3_TITULO
	'Fch Registro', ; //X3_TITSPA
	'Register Dat', ; //X3_TITENG
	'Data Cadastro', ; //X3_DESCRIC
	'Fecha de registro', ; //X3_DESCSPA
	'Register Date', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'DDATABASE'	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'54', ; //X3_ORDEM
	'B4_XNOMPRD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	128	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome Produto', ; //X3_TITULO
	'Nome Produto', ; //X3_TITSPA
	'Nome Produto', ; //X3_TITENG
	'Nome Produto eCommerce', ; //X3_DESCRIC
	'Nome Produto eCommerce', ; //X3_DESCSPA
	'Nome Produto eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'55', ; //X3_ORDEM
	'B4_XTITULO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	128	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Titulo eCom', ; //X3_TITULO
	'Titulo eCom', ; //X3_TITSPA
	'Titulo eCom', ; //X3_TITENG
	'Titulo eCommerce', ; //X3_DESCRIC
	'Titulo eCommerce', ; //X3_DESCSPA
	'Titulo eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'56', ; //X3_ORDEM
	'B4_XSUBTIT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	128	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sub Titulo', ; //X3_TITULO
	'Sub Titulo', ; //X3_TITSPA
	'Sub Titulo', ; //X3_TITENG
	'Sub Titulo eCommerce'	, ; //X3_DESCRIC
	'Sub Titulo eCommerce'	, ; //X3_DESCSPA
	'Sub Titulo eCommerce'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'57', ; //X3_ORDEM
	'B4_XDESCRI', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Prod'	, ; //X3_TITULO
	'Desc Prod'	, ; //X3_TITSPA
	'Desc Prod'	, ; //X3_TITENG
	'Desc Produto eCommerce', ; //X3_DESCRIC
	'Desc Produto eCommerce', ; //X3_DESCSPA
	'Desc Produto eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'58', ; //X3_ORDEM
	'B4_XCARACT', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Carac Produt', ; //X3_TITULO
	'Carac Produt', ; //X3_TITSPA
	'Carac Produt', ; //X3_TITENG
	'Carac. Produto eCommerce', ; //X3_DESCRIC
	'Carac. Produto eCommerce', ; //X3_DESCSPA
	'Carac. Produto eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'59', ; //X3_ORDEM
	'B4_XLONPAG', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Long Page'	, ; //X3_TITULO
	'Long Page'	, ; //X3_TITSPA
	'Long Page'	, ; //X3_TITENG
	'Long Page Produto eCommer', ; //X3_DESCRIC
	'Long Page Produto eCommer', ; //X3_DESCSPA
	'Long Page Produto eCommer', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'60', ; //X3_ORDEM
	'B4_XCODENQ', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Enq. Ga', ; //X3_TITULO
	'Cod. Enq. Ga', ; //X3_TITSPA
	'Cod. Enq. Ga', ; //X3_TITENG
	'Cod. Enquadr Garantia'	, ; //X3_DESCRIC
	'Cod. Enquadr Garantia'	, ; //X3_DESCSPA
	'Cod. Enquadr Garantia'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'61', ; //X3_ORDEM
	'B4_XDESENQ', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	80	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Enq Ga', ; //X3_TITULO
	'Desc. Enq Ga', ; //X3_TITSPA
	'Desc. Enq Ga', ; //X3_TITENG
	'Desc. Enquadramento Garan', ; //X3_DESCRIC
	'Desc. Enquadramento Garan', ; //X3_DESCSPA
	'Desc. Enquadramento Garan', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'62', ; //X3_ORDEM
	'B4_XALTPRD', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Altura'	, ; //X3_TITULO
	'Altura'	, ; //X3_TITSPA
	'Altura'	, ; //X3_TITENG
	'Altura do Produto', ; //X3_DESCRIC
	'Altura do Produto', ; //X3_DESCSPA
	'Altura do Produto', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'63', ; //X3_ORDEM
	'B4_XLARPRD', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Largura'	, ; //X3_TITULO
	'Largura'	, ; //X3_TITSPA
	'Largura'	, ; //X3_TITENG
	'Largura do Produto'	, ; //X3_DESCRIC
	'Largura do Produto'	, ; //X3_DESCSPA
	'Largura do Produto'	, ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'64', ; //X3_ORDEM
	'B4_XPROPRD', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Profundidade', ; //X3_TITULO
	'Profundidade', ; //X3_TITSPA
	'Profundidade', ; //X3_TITENG
	'Profundidade Produto'	, ; //X3_DESCRIC
	'Profundidade Produto'	, ; //X3_DESCSPA
	'Profundidade Produto'	, ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'65', ; //X3_ORDEM
	'B4_XALTEMB', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Alt. Embala', ; //X3_TITULO
	'Alt. Embala', ; //X3_TITSPA
	'Alt. Embala', ; //X3_TITENG
	'Altura Embalagem', ; //X3_DESCRIC
	'Altura Embalagem', ; //X3_DESCSPA
	'Altura Embalagem', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'66', ; //X3_ORDEM
	'B4_XLAREMB', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Larg Embala', ; //X3_TITULO
	'Larg Embala', ; //X3_TITSPA
	'Larg Embala', ; //X3_TITENG
	'Largura Embalagem', ; //X3_DESCRIC
	'Largura Embalagem', ; //X3_DESCSPA
	'Largura Embalagem', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'67', ; //X3_ORDEM
	'B4_XPROEMB', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Prof Embala', ; //X3_TITULO
	'Prof Embala', ; //X3_TITSPA
	'Prof Embala', ; //X3_TITENG
	'Profundidade Embalagem', ; //X3_DESCRIC
	'Profundidade Embalagem', ; //X3_DESCSPA
	'Profundidade Embalagem', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'68', ; //X3_ORDEM
	'B4_XPRZADI', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Prz. Adicio', ; //X3_TITULO
	'Prz. Adicio', ; //X3_TITSPA
	'Prz. Adicio', ; //X3_TITENG
	'Prazo Adicional entrega', ; //X3_DESCRIC
	'Prazo Adicional entrega', ; //X3_DESCSPA
	'Prazo Adicional entrega', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'69', ; //X3_ORDEM
	'B4_XQTDMAX', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	4	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Qtd. Max. Vn', ; //X3_TITULO
	'Qtd. Max. Vn', ; //X3_TITSPA
	'Qtd. Max. Vn', ; //X3_TITENG
	'Quantidade Maxima Venda', ; //X3_DESCRIC
	'Quantidade Maxima Venda', ; //X3_DESCSPA
	'Quantidade Maxima Venda', ; //X3_DESCENG
	'9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'70', ; //X3_ORDEM
	'B4_XTPPROD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tp. Produto', ; //X3_TITULO
	'Tp. Produto', ; //X3_TITSPA
	'Tp. Produto', ; //X3_TITENG
	'Tipo de Produto', ; //X3_DESCRIC
	'Tipo de Produto', ; //X3_DESCSPA
	'Tipo de Produto', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOX
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOXSPA
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'71', ; //X3_ORDEM
	'B4_XPRESEN', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Presente ?', ; //X3_TITULO
	'Presente ?', ; //X3_TITSPA
	'Presente ?', ; //X3_TITENG
	'Embalagem para Presente', ; //X3_DESCRIC
	'Embalagem para Presente', ; //X3_DESCSPA
	'Embalagem para Presente', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'72', ; //X3_ORDEM
	'B4_XPERSON', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Personaliza?', ; //X3_TITULO
	'Personaliza?', ; //X3_TITSPA
	'Personaliza?', ; //X3_TITENG
	'Personalizacao Extra'	, ; //X3_DESCRIC
	'Personalizacao Extra'	, ; //X3_DESCSPA
	'Personalizacao Extra'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'73', ; //X3_ORDEM
	'B4_XDESPER', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	50	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Persona', ; //X3_TITULO
	'Desc Persona', ; //X3_TITSPA
	'Desc Persona', ; //X3_TITENG
	'Descricao Personalizacao', ; //X3_DESCRIC
	'Descricao Personalizacao', ; //X3_DESCSPA
	'Descricao Personalizacao', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'74', ; //X3_ORDEM
	'B4_XISBN'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	13	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'ISBN', ; //X3_TITULO
	'ISBN', ; //X3_TITSPA
	'ISBN', ; //X3_TITENG
	'ISBN', ; //X3_DESCRIC
	'ISBN', ; //X3_DESCSPA
	'ISBN', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'75', ; //X3_ORDEM
	'B4_XEAN13'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ean 13'	, ; //X3_TITULO
	'Ean 13'	, ; //X3_TITSPA
	'Ean 13'	, ; //X3_TITENG
	'Ean 13'	, ; //X3_DESCRIC
	'Ean 13'	, ; //X3_DESCSPA
	'Ean 13'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'76', ; //X3_ORDEM
	'B4_XYOUTUB', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'YouTube'	, ; //X3_TITULO
	'YouTube'	, ; //X3_TITSPA
	'YouTube'	, ; //X3_TITENG
	'Codigo do Video no YouTub', ; //X3_DESCRIC
	'Codigo do Video no YouTub', ; //X3_DESCSPA
	'Codigo do Video no YouTub', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'77', ; //X3_ORDEM
	'B4_XESTMIN', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Est. Minimo', ; //X3_TITULO
	'Est. Minimo', ; //X3_TITSPA
	'Est. Minimo', ; //X3_TITENG
	'Estoque Minimo', ; //X3_DESCRIC
	'Estoque Minimo', ; //X3_DESCSPA
	'Estoque Minimo', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'78', ; //X3_ORDEM
	'B4_STATUS'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status'	, ; //X3_TITULO
	'Status'	, ; //X3_TITSPA
	'Status'	, ; //X3_TITENG
	'Status'	, ; //X3_DESCRIC
	'Status'	, ; //X3_DESCSPA
	'Status'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"A"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'A=Ativo;I=Inativo', ; //X3_CBOX
	'A=Ativo;I=Inativo', ; //X3_CBOXSPA
	'A=Ativo;I=Inativo', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'79', ; //X3_ORDEM
	'B4_XENVECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Envio eComme', ; //X3_TITULO
	'Envio eComme', ; //X3_TITSPA
	'Envio eComme', ; //X3_TITENG
	'Envio eCommemerce', ; //X3_DESCRIC
	'Envio eCommemerce', ; //X3_DESCSPA
	'Envio eCommemerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Enviado;2=Enviado', ; //X3_CBOX
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXSPA
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB4', ; //X3_ARQUIVO
	'80', ; //X3_ORDEM
	'B4_XUSAECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Usa Prd eCo', ; //X3_TITULO
	'Usa Prd eCo', ; //X3_TITSPA
	'Usa Prd eCo', ; //X3_TITENG
	'Usa Produto no eCommerce', ; //X3_DESCRIC
	'Usa Produto no eCommerce', ; //X3_DESCSPA
	'Usa Produto no eCommerce', ; //X3_DESCENG
	'@1', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'6'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SB5
//
aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'10', ; //X3_ORDEM
	'B5_CEME'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	200	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome Cientif', ; //X3_TITULO
	'Nomb Cientif', ; //X3_TITSPA
	'Scient.Name', ; //X3_TITENG
	'Descricao cientifica'	, ; //X3_DESCRIC
	'Descripcion Cientifica', ; //X3_DESCSPA
	'Scientific Description', ; //X3_DESCENG
	'@!S45', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(147) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'21', ; //X3_ORDEM
	'B5_ESTMAT'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Estado Fisic', ; //X3_TITULO
	'Estado Fisic', ; //X3_TITSPA
	'Physical Sit', ; //X3_TITENG
	'Estado fisico do material', ; //X3_DESCRIC
	'Estado Fisico de Material', ; //X3_DESCSPA
	'Physical Situat. of Good', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(146) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("SLG ")', ; //X3_VLDUSER
	'S=Solido;L=Liquido;G=Gasoso'		, ; //X3_CBOX
	'S=Solido;L=Liquido;G=Gaseoso'		, ; //X3_CBOXSPA
	'S=Solid;L=Liquid;G=Gaseous'		, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'71', ; //X3_ORDEM
	'B5_CONCENT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Concentracäo', ; //X3_TITULO
	'Concentrac.', ; //X3_TITSPA
	'Concentratio', ; //X3_TITENG
	'Concentracäo do Produto', ; //X3_DESCRIC
	'Concentración del product', ; //X3_DESCSPA
	'Concentration of Product', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'72', ; //X3_ORDEM
	'B5_DENSID'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Densidade'	, ; //X3_TITULO
	'Densidad'	, ; //X3_TITSPA
	'Density'	, ; //X3_TITENG
	'Densidade do Produto'	, ; //X3_DESCRIC
	'Densidad del producto'	, ; //X3_DESCSPA
	'Product Density', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'N4', ; //X3_ORDEM
	'B5_XCAT01'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Grupo Linha', ; //X3_TITULO
	'Grupo linea', ; //X3_TITSPA
	'Line Group', ; //X3_TITENG
	'Grupo Linha', ; //X3_DESCRIC
	'Grupo linea', ; //X3_DESCSPA
	'Line Group', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY0DEP'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B5_XCAT01,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'N5', ; //X3_ORDEM
	'B5_XDCAT01', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Grupo', ; //X3_TITULO
	'Desc. Grupo', ; //X3_TITSPA
	'Desc. Group', ; //X3_TITENG
	'Descricao Linha', ; //X3_DESCRIC
	'Descripcion linea', ; //X3_DESCSPA
	'Line Description', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B5_XCAT01, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'N6', ; //X3_ORDEM
	'B5_XCAT02'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Linha', ; //X3_TITULO
	'Linea', ; //X3_TITSPA
	'Row', ; //X3_TITENG
	'Linha', ; //X3_DESCRIC
	'Linea', ; //X3_DESCSPA
	'Row', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY1LIN'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B5_XCAT02,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'N7', ; //X3_ORDEM
	'B5_XDCAT02', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Linha', ; //X3_TITULO
	'Desc. Linea', ; //X3_TITSPA
	'Desc. Line', ; //X3_TITENG
	'Desc. Linha', ; //X3_DESCRIC
	'Desc. Linea', ; //X3_DESCSPA
	'Desc. Line', ; //X3_DESCENG
	'@S25!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B5_XCAT02, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'N8', ; //X3_ORDEM
	'B5_XCAT03'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Seção', ; //X3_TITULO
	'Seccion'	, ; //X3_TITSPA
	'Section'	, ; //X3_TITENG
	'Seção', ; //X3_DESCRIC
	'Seccion'	, ; //X3_DESCSPA
	'Section'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY1SEC'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B5_XCAT03,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'N9', ; //X3_ORDEM
	'B5_XDCAT03', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Seção', ; //X3_TITULO
	'Desc. Seccio', ; //X3_TITSPA
	'Desc. Sectio', ; //X3_TITENG
	'Desc. Seção', ; //X3_DESCRIC
	'Desc. Seccion', ; //X3_DESCSPA
	'Desc. Section', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B5_XCAT03, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O0', ; //X3_ORDEM
	'B5_XCAT04'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Espécie'	, ; //X3_TITULO
	'Especie'	, ; //X3_TITSPA
	'Species'	, ; //X3_TITENG
	'Espécie'	, ; //X3_DESCRIC
	'Especie'	, ; //X3_DESCSPA
	'Species'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY1ESP'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B5_XCAT04,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O1', ; //X3_ORDEM
	'B5_XDCAT04', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Espéci', ; //X3_TITULO
	'Desc. Espec.', ; //X3_TITSPA
	'Desc. Specie', ; //X3_TITENG
	'Desc. Espécie', ; //X3_DESCRIC
	'Desc. Especie', ; //X3_DESCSPA
	'Desc. Species', ; //X3_DESCENG
	'@S25!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B5_XCAT04, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O2', ; //X3_ORDEM
	'B5_XCAT05'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sub-Espécie', ; //X3_TITULO
	'Subespecie', ; //X3_TITSPA
	'Sub-Species', ; //X3_TITENG
	'Sub-Espécie', ; //X3_DESCRIC
	'Subespecie', ; //X3_DESCSPA
	'Sub-Species', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY1SUB'	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("AY0",M->B5_XCAT05,1)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O3', ; //X3_ORDEM
	'B5_XDCAT05', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Sub-Es', ; //X3_TITULO
	'Desc. Subesp', ; //X3_TITSPA
	'Desc. Sub-Sp', ; //X3_TITENG
	'Desc. Sub-Espécie', ; //X3_DESCRIC
	'Desc. Subespecie', ; //X3_DESCSPA
	'Desc. Sub-Species', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, "", POSICIONE("AY0", 1, XFILIAL("AY0")+M->B5_XCAT05, "AY0_DESC"))', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O4', ; //X3_ORDEM
	'B5_XCODMAR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Marca', ; //X3_TITULO
	'Marca', ; //X3_TITSPA
	'Brand', ; //X3_TITENG
	'Marca', ; //X3_DESCRIC
	'Marca', ; //X3_DESCSPA
	'Brand', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'AY2', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'ExistCpo("AY2")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O5', ; //X3_ORDEM
	'B5_XDESCMA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. Marca', ; //X3_TITULO
	'Desc. Marca', ; //X3_TITSPA
	'Desc. Brand', ; //X3_TITENG
	'Desc. Marca', ; //X3_DESCRIC
	'Desc. Marca', ; //X3_DESCSPA
	'Desc. Brand', ; //X3_DESCENG
	'@S25!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"",POSICIONE("AY2",1,XFILIAL("AY2")+SB5->B5_XCODMAR,"AY2_DESCR"))', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	'POSICIONE("AY2",1,XFILIAL("AY2")+SB5->B5_XCODMAR,"AY2_DESCR")'			, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O6', ; //X3_ORDEM
	'B5_XNOMPRD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	128	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome Produto', ; //X3_TITULO
	'Nome Produto', ; //X3_TITSPA
	'Nome Produto', ; //X3_TITENG
	'Nome Produto eCommerce', ; //X3_DESCRIC
	'Nome Produto eCommerce', ; //X3_DESCSPA
	'Nome Produto eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O7', ; //X3_ORDEM
	'B5_XTITULO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	128	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Titulo eCom', ; //X3_TITULO
	'Titulo eCom', ; //X3_TITSPA
	'Titulo eCom', ; //X3_TITENG
	'Titulo eCommerce', ; //X3_DESCRIC
	'Titulo eCommerce', ; //X3_DESCSPA
	'Titulo eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O8', ; //X3_ORDEM
	'B5_XSUBTIT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	128	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sub Titulo', ; //X3_TITULO
	'Sub Titulo', ; //X3_TITSPA
	'Sub Titulo', ; //X3_TITENG
	'Sub Titulo eCommerce'	, ; //X3_DESCRIC
	'Sub Titulo eCommerce'	, ; //X3_DESCSPA
	'Sub Titulo eCommerce'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'O9', ; //X3_ORDEM
	'B5_XDTEXP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dta. Expo.', ; //X3_TITULO
	'Dta. Expo.', ; //X3_TITSPA
	'Dta. Expo.', ; //X3_TITENG
	'Dta. Exportacao', ; //X3_DESCRIC
	'Dta. Exportacao', ; //X3_DESCSPA
	'Dta. Exportacao', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	9	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'L'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P0', ; //X3_ORDEM
	'B5_XDESCRI', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Prod'	, ; //X3_TITULO
	'Desc Prod'	, ; //X3_TITSPA
	'Desc Prod'	, ; //X3_TITENG
	'Desc Produto eCommerce', ; //X3_DESCRIC
	'Desc Produto eCommerce', ; //X3_DESCSPA
	'Desc Produto eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P1', ; //X3_ORDEM
	'B5_XCARACT', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Carac Produt', ; //X3_TITULO
	'Carac Produt', ; //X3_TITSPA
	'Carac Produt', ; //X3_TITENG
	'Carac. Produto eCommerce', ; //X3_DESCRIC
	'Carac. Produto eCommerce', ; //X3_DESCSPA
	'Carac. Produto eCommerce', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P2', ; //X3_ORDEM
	'B5_XKEYWOR', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Keywords'	, ; //X3_TITULO
	'Keywords'	, ; //X3_TITSPA
	'Keywords'	, ; //X3_TITENG
	'Keywords'	, ; //X3_DESCRIC
	'Keywords'	, ; //X3_DESCSPA
	'Keywords'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P3', ; //X3_ORDEM
	'B5_XALTPRD', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Altura'	, ; //X3_TITULO
	'Altura'	, ; //X3_TITSPA
	'Altura'	, ; //X3_TITENG
	'Altura do Produto', ; //X3_DESCRIC
	'Altura do Produto', ; //X3_DESCSPA
	'Altura do Produto', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P4', ; //X3_ORDEM
	'B5_XLONPAG', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Long Page'	, ; //X3_TITULO
	'Long Page'	, ; //X3_TITSPA
	'Long Page'	, ; //X3_TITENG
	'Long Page Produto eCommer', ; //X3_DESCRIC
	'Long Page Produto eCommer', ; //X3_DESCSPA
	'Long Page Produto eCommer', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'4'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'N'	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P5', ; //X3_ORDEM
	'B5_XLARPRD', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Largura'	, ; //X3_TITULO
	'Largura'	, ; //X3_TITSPA
	'Largura'	, ; //X3_TITENG
	'Largura do Produto'	, ; //X3_DESCRIC
	'Largura do Produto'	, ; //X3_DESCSPA
	'Largura do Produto'	, ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P6', ; //X3_ORDEM
	'B5_XPROPRD', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Profundidade', ; //X3_TITULO
	'Profundidade', ; //X3_TITSPA
	'Profundidade', ; //X3_TITENG
	'Profundidade Produto'	, ; //X3_DESCRIC
	'Profundidade Produto'	, ; //X3_DESCSPA
	'Profundidade Produto'	, ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P7', ; //X3_ORDEM
	'B5_XALTEMB', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Alt. Embala', ; //X3_TITULO
	'Alt. Embala', ; //X3_TITSPA
	'Alt. Embala', ; //X3_TITENG
	'Altura Embalagem', ; //X3_DESCRIC
	'Altura Embalagem', ; //X3_DESCSPA
	'Altura Embalagem', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P8', ; //X3_ORDEM
	'B5_XLAREMB', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Larg Embala', ; //X3_TITULO
	'Larg Embala', ; //X3_TITSPA
	'Larg Embala', ; //X3_TITENG
	'Largura Embalagem', ; //X3_DESCRIC
	'Largura Embalagem', ; //X3_DESCSPA
	'Largura Embalagem', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'P9', ; //X3_ORDEM
	'B5_XPROEMB', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Prof Embala', ; //X3_TITULO
	'Prof Embala', ; //X3_TITSPA
	'Prof Embala', ; //X3_TITENG
	'Profundidade Embalagem', ; //X3_DESCRIC
	'Profundidade Embalagem', ; //X3_DESCSPA
	'Profundidade Embalagem', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q0', ; //X3_ORDEM
	'B5_XPRZADI', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Prz. Adicio', ; //X3_TITULO
	'Prz. Adicio', ; //X3_TITSPA
	'Prz. Adicio', ; //X3_TITENG
	'Prazo Adicional entrega', ; //X3_DESCRIC
	'Prazo Adicional entrega', ; //X3_DESCSPA
	'Prazo Adicional entrega', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q1', ; //X3_ORDEM
	'B5_XTPPROD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tp. Produto', ; //X3_TITULO
	'Tp. Produto', ; //X3_TITSPA
	'Tp. Produto', ; //X3_TITENG
	'Tipo de Produto', ; //X3_DESCRIC
	'Tipo de Produto', ; //X3_DESCSPA
	'Tipo de Produto', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOX
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOXSPA
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q2', ; //X3_ORDEM
	'B5_XPRESEN', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Presente ?', ; //X3_TITULO
	'Presente ?', ; //X3_TITSPA
	'Presente ?', ; //X3_TITENG
	'Embalagem para Presente', ; //X3_DESCRIC
	'Embalagem para Presente', ; //X3_DESCSPA
	'Embalagem para Presente', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q3', ; //X3_ORDEM
	'B5_XSTAPRD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sta Prd eCom', ; //X3_TITULO
	'Sta Prd eCom', ; //X3_TITSPA
	'Sta Prd eCom', ; //X3_TITENG
	'Status Produto eCommerce', ; //X3_DESCRIC
	'Status Produto eCommerce', ; //X3_DESCSPA
	'Status Produto eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Ativo;2=Inativo', ; //X3_CBOX
	'1=Ativo;2=Inativo', ; //X3_CBOXSPA
	'1=Ativo;2=Inativo', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q4', ; //X3_ORDEM
	'B5_XPERSON', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Personaliza?', ; //X3_TITULO
	'Personaliza?', ; //X3_TITSPA
	'Personaliza?', ; //X3_TITENG
	'Personalizacao Extra'	, ; //X3_DESCRIC
	'Personalizacao Extra'	, ; //X3_DESCSPA
	'Personalizacao Extra'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q5', ; //X3_ORDEM
	'B5_XDESPER', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	50	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Persona', ; //X3_TITULO
	'Desc Persona', ; //X3_TITSPA
	'Desc Persona', ; //X3_TITENG
	'Descricao Personalizacao', ; //X3_DESCRIC
	'Descricao Personalizacao', ; //X3_DESCSPA
	'Descricao Personalizacao', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q6', ; //X3_ORDEM
	'B5_XQTDMAX', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	4	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Qtd. Max. Vn', ; //X3_TITULO
	'Qtd. Max. Vn', ; //X3_TITSPA
	'Qtd. Max. Vn', ; //X3_TITENG
	'Quantidade Maxima Venda', ; //X3_DESCRIC
	'Quantidade Maxima Venda', ; //X3_DESCSPA
	'Quantidade Maxima Venda', ; //X3_DESCENG
	'9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q7', ; //X3_ORDEM
	'B5_XESTMIN', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Est. Minimo', ; //X3_TITULO
	'Est. Minimo', ; //X3_TITSPA
	'Est. Minimo', ; //X3_TITENG
	'Estoque Minimo', ; //X3_DESCRIC
	'Estoque Minimo', ; //X3_DESCSPA
	'Estoque Minimo', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q8', ; //X3_ORDEM
	'B5_XEAN13'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ean 13'	, ; //X3_TITULO
	'Ean 13'	, ; //X3_TITSPA
	'Ean 13'	, ; //X3_TITENG
	'Ean 13'	, ; //X3_DESCRIC
	'Ean 13'	, ; //X3_DESCSPA
	'Ean 13'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'Q9', ; //X3_ORDEM
	'B5_XYOUTUB', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'YouTube'	, ; //X3_TITULO
	'YouTube'	, ; //X3_TITSPA
	'YouTube'	, ; //X3_TITENG
	'Codigo do Video no YouTub', ; //X3_DESCRIC
	'Codigo do Video no YouTub', ; //X3_DESCSPA
	'Codigo do Video no YouTub', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R0', ; //X3_ORDEM
	'B5_XUSAECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Usa Prd eCo', ; //X3_TITULO
	'Usa Prd eCo', ; //X3_TITSPA
	'Usa Prd eCo', ; //X3_TITENG
	'Usa Produto no eCommerce', ; //X3_DESCRIC
	'Usa Produto no eCommerce', ; //X3_DESCSPA
	'Usa Produto no eCommerce', ; //X3_DESCENG
	'@1', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R1', ; //X3_ORDEM
	'B5_XENVECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Envio eComme', ; //X3_TITULO
	'Envio eComme', ; //X3_TITSPA
	'Envio eComme', ; //X3_TITENG
	'Envio eCommemerce', ; //X3_DESCRIC
	'Envio eCommemerce', ; //X3_DESCSPA
	'Envio eCommemerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Enviado;2=Enviado', ; //X3_CBOX
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXSPA
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R2', ; //X3_ORDEM
	'B5_STATUS'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status'	, ; //X3_TITULO
	'Status'	, ; //X3_TITSPA
	'Status'	, ; //X3_TITENG
	'Status Produto', ; //X3_DESCRIC
	'Status Produto', ; //X3_DESCSPA
	'Status Produto', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"A"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'A=Ativo;I=Inativo', ; //X3_CBOX
	'A=Ativo;I=Inativo', ; //X3_CBOXSPA
	'A=Ativo;I=Inativo', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R3', ; //X3_ORDEM
	'B5_XIDLOJA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id Loja Vtex', ; //X3_TITULO
	'Id Loja Vtex', ; //X3_TITSPA
	'Id Loja Vtex', ; //X3_TITENG
	'Id Loja Vtex', ; //X3_DESCRIC
	'Id Loja Vtex', ; //X3_DESCSPA
	'Id Loja Vtex', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"01"', ; //X3_RELACAO
	'IDLOJA'	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R4', ; //X3_ORDEM
	'B5_XENVCAT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Env. Eco. Ca', ; //X3_TITULO
	'Env. Eco. Ca', ; //X3_TITSPA
	'Env. Eco. Ca', ; //X3_TITENG
	'Envio Categoria eCommerce', ; //X3_DESCRIC
	'Envio Categoria eCommerce', ; //X3_DESCSPA
	'Envio Categoria eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Enviado;2=Enviado', ; //X3_CBOX
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXSPA
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R5', ; //X3_ORDEM
	'B5_XENVSKU', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Envio Sku ?', ; //X3_TITULO
	'Envio Sku ?', ; //X3_TITSPA
	'Envio Sku ?', ; //X3_TITENG
	'Envio Sku ?', ; //X3_DESCRIC
	'Envio Sku ?', ; //X3_DESCSPA
	'Envio Sku ?', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Enviado; 2=Enviado', ; //X3_CBOX
	'1=Nao Enviado; 2=Enviado', ; //X3_CBOXSPA
	'1=Nao Enviado; 2=Enviado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R6', ; //X3_ORDEM
	'B5_XPRODP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Produto Pai', ; //X3_TITULO
	'Prod Princip', ; //X3_TITSPA
	'Parent Produ', ; //X3_TITENG
	'Produto Pai', ; //X3_DESCRIC
	'Prod. Principal', ; //X3_DESCSPA
	'Parent Product', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(65), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'G01', ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R7', ; //X3_ORDEM
	'B5_XIDPROD', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id Produto', ; //X3_TITULO
	'Id Produto', ; //X3_TITSPA
	'Id Produto', ; //X3_TITENG
	'Id Produto', ; //X3_DESCRIC
	'Id Produto', ; //X3_DESCSPA
	'Id Produto', ; //X3_DESCENG
	'999999999999999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R8', ; //X3_ORDEM
	'B5_XIDSKU'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id Sku'	, ; //X3_TITULO
	'Id Sku'	, ; //X3_TITSPA
	'Id Sku'	, ; //X3_TITENG
	'Id Sku'	, ; //X3_DESCRIC
	'Id Sku'	, ; //X3_DESCSPA
	'Id Sku'	, ; //X3_DESCENG
	'999999999999999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'R9', ; //X3_ORDEM
	'B5_XATVPRD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Prod Ativo', ; //X3_TITULO
	'Prod Ativo', ; //X3_TITSPA
	'Prod Ativo', ; //X3_TITENG
	'Produto Ativo', ; //X3_DESCRIC
	'Produto Ativo', ; //X3_DESCSPA
	'Produto Ativo', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao;2=Sim', ; //X3_CBOX
	'1=Nao;2=Sim', ; //X3_CBOXSPA
	'1=Nao;2=Sim', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'S0', ; //X3_ORDEM
	'B5_XATVSKU', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'SKU Ativo'	, ; //X3_TITULO
	'SKU Ativo'	, ; //X3_TITSPA
	'SKU Ativo'	, ; //X3_TITENG
	'SKU Ativo'	, ; //X3_DESCRIC
	'SKU Ativo'	, ; //X3_DESCSPA
	'SKU Ativo'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao;2=Sim', ; //X3_CBOX
	'1=Nao;2=Sim', ; //X3_CBOXSPA
	'1=Nao;2=Sim', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'A'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SB5', ; //X3_ARQUIVO
	'S1', ; //X3_ORDEM
	'B5_XHREXP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hr. Export', ; //X3_TITULO
	'Hr. Export', ; //X3_TITSPA
	'Hr. Export', ; //X3_TITENG
	'Hora Exportacao', ; //X3_DESCRIC
	'Hora Exportacao', ; //X3_DESCSPA
	'Hora Exportacao', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SC0
//
aAdd( aSX3, { ;
	'SC0', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'C0_TIPO'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Reserva', ; //X3_TITULO
	'Tipo Reserva', ; //X3_TITSPA
	'Type Reserv.', ; //X3_TITENG
	'Tipo da reserva (PV/CL...', ; //X3_DESCRIC
	'Tipo de Reserva (PV/CL...', ; //X3_DESCSPA
	'Type of Reserve', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("LB/VD/CL/PD/NF")'		, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

//
// Campos Tabela SC5
//
aAdd( aSX3, { ;
	'SC5', ; //X3_ARQUIVO
	'09', ; //X3_ORDEM
	'C5_TIPOCLI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Cliente', ; //X3_TITULO
	'Tipo Cliente', ; //X3_TITSPA
	'Customer Ty.', ; //X3_TITENG
	'Tipo do Cliente', ; //X3_DESCRIC
	'Tipo de Cliente', ; //X3_DESCSPA
	'Type of Customer', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(131) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("FLRSX")', ; //X3_VLDUSER
	'F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacao/Importacao', ; //X3_CBOX
	'F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacion/Importacion', ; //X3_CBOXSPA
	'F=Final Cons.;L=Rural Prod.;R=Reseller;S=Solidary;X=Export/Import'		, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5', ; //X3_ARQUIVO
	'38', ; //X3_ORDEM
	'C5_TPFRETE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Frete', ; //X3_TITULO
	'Tipo Flete', ; //X3_TITSPA
	'Tipo Freight', ; //X3_TITENG
	'Tipo do Frete Utilizado', ; //X3_DESCRIC
	'Tipo del flete utilizado', ; //X3_DESCSPA
	'Tp of Used Freight'	, ; //X3_DESCENG
	'X'	, ; //X3_PICTURE
	'pertence("CFTS")', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("CFTS")', ; //X3_VLDUSER
	'C=CIF;F=FOB;T=Por conta terceiros;S=Sem frete'							, ; //X3_CBOX
	'C=CIF;F=FOB;T=Por cta terceros;S=Sin flete'							, ; //X3_CBOXSPA
	'C=CIF;F=FOB;T=Due to Third Party;S=No freight'							, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5', ; //X3_ARQUIVO
	'60', ; //X3_ORDEM
	'C5_INCISS'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'ISS Incluso', ; //X3_TITULO
	'Incl. ISS'	, ; //X3_TITSPA
	'ISS Included', ; //X3_TITENG
	'ISS incluso no Preço'	, ; //X3_DESCRIC
	'ISS Incluido en Precio', ; //X3_DESCSPA
	'Price including ISS'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Pertence("SN")', ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Si;N=No'	, ; //X3_CBOXSPA
	'S=Yes;N=No', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5', ; //X3_ARQUIVO
	'61', ; //X3_ORDEM
	'C5_LIBEROK', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Liber. Total', ; //X3_TITULO
	'Liber. Total', ; //X3_TITSPA
	'Total Releas', ; //X3_TITENG
	'Pedido Liberado Total'	, ; //X3_DESCRIC
	'Pedido Liberado Total'	, ; //X3_DESCSPA
	'Total Released Order'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("S ")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5', ; //X3_ARQUIVO
	'91', ; //X3_ORDEM
	'C5_RECFAUT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Pag.Fret.Aut', ; //X3_TITULO
	'Pag.Flet.Aut', ; //X3_TITSPA
	'Free Freight', ; //X3_TITENG
	'Pagto do frete autonomo', ; //X3_DESCRIC
	'Pago del flete autónomo', ; //X3_DESCSPA
	'Pagto do Indep Freight', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	'Pertence("12") .And. MaFisGet("NF_RECFAUT")'							, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'MaFisGet("NF_RECFAUT")', ; //X3_VLDUSER
	'1=Emitente;2=Transportador'		, ; //X3_CBOX
	'1=Emisor;2=Transportador', ; //X3_CBOXSPA
	'1=Issuer;2=Carrier'	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5', ; //X3_ARQUIVO
	'E0', ; //X3_ORDEM
	'C5_XNUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Pv eCom', ; //X3_TITULO
	'Cod. Pv eCom', ; //X3_TITSPA
	'Cod. Pv eCom', ; //X3_TITENG
	'Cod. Pedido de Venda eCom', ; //X3_DESCRIC
	'Cod. Pedido de Venda eCom', ; //X3_DESCSPA
	'Cod. Pedido de Venda eCom', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5', ; //X3_ARQUIVO
	'E1', ; //X3_ORDEM
	'C5_XNUMECL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv Cli', ; //X3_TITULO
	'Num Pv Cli', ; //X3_TITSPA
	'Num Pv Cli', ; //X3_TITENG
	'Num Pv Cliente eCommerce', ; //X3_DESCRIC
	'Num Pv Cliente eCommerce', ; //X3_DESCSPA
	'Num Pv Cliente eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'2'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SC6
//
aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'C6_QTDVEN'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Quantidade', ; //X3_TITULO
	'Cantidad'	, ; //X3_TITSPA
	'Quantity'	, ; //X3_TITENG
	'Quantidade Vendida'	, ; //X3_DESCRIC
	'Cantidad vendida', ; //X3_DESCSPA
	'Sold Quantity', ; //X3_DESCENG
	'@E 999999.99', ; //X3_PICTURE
	'A410QTDGRA() .AND. A410SegUm().and.A410MultT().and.a410Refr("C6_QTDVEN")'	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(155) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'C6_PRCVEN'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	11	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Prc Unitario', ; //X3_TITULO
	'Prc Unitario', ; //X3_TITSPA
	'Unitary Pric', ; //X3_TITENG
	'Preco Unitario Liquido', ; //X3_DESCRIC
	'Precio unitario neto'	, ; //X3_DESCSPA
	'Net Unitary Price', ; //X3_DESCENG
	'@E 99,999,999.99', ; //X3_PICTURE
	'A410QtdGra() .And. A410MultT() .And. A410Zera() .And. MTA410TROP(n)'		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'07', ; //X3_ORDEM
	'C6_VALOR'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Total'	, ; //X3_TITULO
	'Vlr.Total'	, ; //X3_TITSPA
	'Total Vl'	, ; //X3_TITENG
	'Valor Total do Item'	, ; //X3_DESCRIC
	'Valor total del ítem'	, ; //X3_DESCSPA
	'Item Total Value', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	'A410MultT()', ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(155) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'C6_QTDLIB'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Qtd.Liberada', ; //X3_TITULO
	'Ctd Aprobada', ; //X3_TITSPA
	'Amt Approved', ; //X3_TITENG
	'Quantidade Liberada'	, ; //X3_DESCRIC
	'Cantidad Aprobada', ; //X3_DESCSPA
	'Amount Approved', ; //X3_DESCENG
	'@E 999999.99', ; //X3_PICTURE
	'A410QTDGRA() .AND. A440Qtdl() .and. a410MultT().and.a410Refr("C6_QTDLIB")'	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'09', ; //X3_ORDEM
	'C6_QTDLIB2', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Qtd.Lib 2aUM', ; //X3_TITULO
	'Ctd.Lib 2aUM', ; //X3_TITSPA
	'Qt.Rls.2UoM', ; //X3_TITENG
	'Quantidade Liberada 2a UM', ; //X3_DESCRIC
	'Cantidad Aprobada 2a UM', ; //X3_DESCSPA
	'Quantity Released 2nd UOM', ; //X3_DESCENG
	'@E 999999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'35', ; //X3_ORDEM
	'C6_DESCRI'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descripcion', ; //X3_TITSPA
	'Description', ; //X3_TITENG
	'Descricao Auxiliar'	, ; //X3_DESCRIC
	'Descripcion Auxiliar'	, ; //X3_DESCSPA
	'Support Description'	, ; //X3_DESCENG
	'@X', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(146) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'39', ; //X3_ORDEM
	'C6_OP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'OP Gerada'	, ; //X3_TITULO
	'OP Generada', ; //X3_TITSPA
	'Prod.Or.Gen.', ; //X3_TITENG
	'Flag de geracao de OP'	, ; //X3_DESCRIC
	'Flag de Generacion de OP', ; //X3_DESCSPA
	'Flag of Production Order', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Pertence("S ")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'A1', ; //X3_ORDEM
	'C6_CODROM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod Romaneio', ; //X3_TITULO
	'Cod List Emb', ; //X3_TITSPA
	'Pack List Cd', ; //X3_TITENG
	'Codigo do Romaneio'	, ; //X3_DESCRIC
	'Cod de Lista de Embarque', ; //X3_DESCSPA
	'Packing List Code', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	'Vazio() .Or. ExistCpo("NPR")'		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'NPR', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("NPR")'		, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6', ; //X3_ARQUIVO
	'C5', ; //X3_ORDEM
	'C6_CCUSTO'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'C. de Custo', ; //X3_TITULO
	'C. de Costo', ; //X3_TITSPA
	'Cost Center', ; //X3_TITENG
	'Centro de Custo', ; //X3_DESCRIC
	'Centro de Costo', ; //X3_DESCSPA
	'Cost Center', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'CTT', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("CTT")'		, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'004', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

//
// Campos Tabela SC9
//
aAdd( aSX3, { ;
	'SC9', ; //X3_ARQUIVO
	'67', ; //X3_ORDEM
	'C9_XNUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv Ecomm', ; //X3_TITULO
	'Num Pv Ecomm', ; //X3_TITSPA
	'Num Pv Ecomm', ; //X3_TITENG
	'Numero Pedido eCommerce', ; //X3_DESCRIC
	'Numero Pedido eCommerce', ; //X3_DESCSPA
	'Numero Pedido eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SD2
//
aAdd( aSX3, { ;
	'SD2', ; //X3_ARQUIVO
	'C2', ; //X3_ORDEM
	'D2_ICMFRET', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Icms Frete', ; //X3_TITULO
	'ICMs Flete', ; //X3_TITSPA
	'Freight ICMS', ; //X3_TITENG
	'Icms Frete', ; //X3_DESCRIC
	'ICMs Flete', ; //X3_DESCSPA
	'Freight ICMS', ; //X3_DESCENG
	'@E 99,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(250) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'MaFisRet("IT_ICMFRETE","MT100",M->D2_ICMFRET)'							, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2', ; //X3_ARQUIVO
	'M2', ; //X3_ORDEM
	'D2_CODROM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod Romaneio', ; //X3_TITULO
	'Cód List Emb', ; //X3_TITSPA
	'Pack list cd', ; //X3_TITENG
	'Codigo do Romaneio'	, ; //X3_DESCRIC
	'Código Lista de embarque', ; //X3_DESCSPA
	'Packing list code', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'NPR', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("NPR")'		, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

//
// Campos Tabela SE1
//
aAdd( aSX3, { ;
	'SE1', ; //X3_ARQUIVO
	'31', ; //X3_ORDEM
	'E1_SITUACA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Situacao'	, ; //X3_TITULO
	'Situacion'	, ; //X3_TITSPA
	'Situation'	, ; //X3_TITENG
	'Situacao do titulo'	, ; //X3_DESCRIC
	'Situacion del Titulo'	, ; //X3_DESCSPA
	'Situation of Bill', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'FRV', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'existcpo("FRV",M->E1_SITUACA)'		, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'3'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1', ; //X3_ARQUIVO
	'76', ; //X3_ORDEM
	'E1_VLCRUZ'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr R$'	, ; //X3_TITULO
	'Valor $'	, ; //X3_TITSPA
	'Value R$'	, ; //X3_TITENG
	'Valor na moeda nacional', ; //X3_DESCRIC
	'Valor en Moneda Corriente', ; //X3_DESCSPA
	'National Currency Value', ; //X3_DESCENG
	'@E 9,999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(155) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'NaoVazio()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	'1'	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1', ; //X3_ARQUIVO
	'Q8', ; //X3_ORDEM
	'E1_XNUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv eComm', ; //X3_TITULO
	'Num Pv eComm', ; //X3_TITSPA
	'Num Pv eComm', ; //X3_TITENG
	'Numero Pedido eCommerce', ; //X3_DESCRIC
	'Numero Pedido eCommerce', ; //X3_DESCSPA
	'Numero Pedido eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1', ; //X3_ARQUIVO
	'Q9', ; //X3_ORDEM
	'E1_XNUMECL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod Pv Clien', ; //X3_TITULO
	'Cod Pv Clien', ; //X3_TITSPA
	'Cod Pv Clien', ; //X3_TITENG
	'Codigo Pedido Cliente'	, ; //X3_DESCRIC
	'Codigo Pedido Cliente'	, ; //X3_DESCSPA
	'Codigo Pedido Cliente'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SF2
//
aAdd( aSX3, { ;
	'SF2', ; //X3_ARQUIVO
	'95', ; //X3_ORDEM
	'F2_RECFAUT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Pag.Fret.Aut', ; //X3_TITULO
	'Pag.Flet.Aut', ; //X3_TITSPA
	'AutnFrghtPay', ; //X3_TITENG
	'Pagto do frete autonomo', ; //X3_DESCRIC
	'Pago del flete autonomo', ; //X3_DESCSPA
	'Autonomous Freight Paymt.', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	'MaFisRef("NF_RECFAUT","MT100",M->F2_RECFAUT)'							, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'MaFisGet("NF_RECFAUT")', ; //X3_VLDUSER
	'1=Emitente;2=Transportador'		, ; //X3_CBOX
	'1=Emisor;2=Transportador', ; //X3_CBOXSPA
	'1=Issuer;2=Transporter', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2', ; //X3_ARQUIVO
	'K7', ; //X3_ORDEM
	'F2_XNUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv eComm', ; //X3_TITULO
	'Num Pv eComm', ; //X3_TITSPA
	'Num Pv eComm', ; //X3_TITENG
	'Numero Pedido eCommerce', ; //X3_DESCRIC
	'Numero Pedido eCommerce', ; //X3_DESCSPA
	'Numero Pedido eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2', ; //X3_ARQUIVO
	'K8', ; //X3_ORDEM
	'F2_XENVJOB', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'NF Enviada', ; //X3_TITULO
	'NF Enviada', ; //X3_TITSPA
	'NF Enviada', ; //X3_TITENG
	'NF Enviada para o Cliente', ; //X3_DESCRIC
	'NF Enviada para o Cliente', ; //X3_DESCSPA
	'NF Enviada para o Cliente', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SL1
//
aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'L1_COMIS'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Comissao'	, ; //X3_TITULO
	'Comision'	, ; //X3_TITSPA
	'Commission', ; //X3_TITENG
	'Comissao do Vendedor'	, ; //X3_DESCRIC
	'Comision del Vendedor'	, ; //X3_DESCSPA
	'Seller Commission', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo() .or. vazio()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	'#L1_COMIS  >=0', ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'L1_TIPOCLI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Cliente', ; //X3_TITULO
	'Tipo Cliente', ; //X3_TITSPA
	'Customer Ty.', ; //X3_TITENG
	'Tipo do Cliente', ; //X3_DESCRIC
	'Tipo del Cliente', ; //X3_DESCSPA
	'Type of Customer', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("F\L\R\S\X")'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	"#L1_TIPOCLI<>' '", ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'13', ; //X3_ORDEM
	'L1_DTLIM'	, ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dt.Validade', ; //X3_TITULO
	'Fch Validez', ; //X3_TITSPA
	'Validity Dt.', ; //X3_TITENG
	'Data Validade Orcamento', ; //X3_DESCRIC
	'Fecha Validez Presupuesto', ; //X3_DESCSPA
	'Budget Validity Date'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'dDataBase'	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'naovazio()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	"#L1_DTLIM  <>'        '", ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'73', ; //X3_ORDEM
	'L1_ENDCOB'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End. Cobranc', ; //X3_TITULO
	'Dir.Cobranza', ; //X3_TITSPA
	'Collect.Add.', ; //X3_TITENG
	'Enderaco de Cobranca'	, ; //X3_DESCRIC
	'Direccion de Cobranza'	, ; //X3_DESCSPA
	'Collection Address'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio.or.Texto()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'74', ; //X3_ORDEM
	'L1_ENDENT'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End. Entrega', ; //X3_TITULO
	'Dir.Entrega', ; //X3_TITSPA
	'Deliv.Locat.', ; //X3_TITENG
	'Endereco de Entrega'	, ; //X3_DESCRIC
	'Direccion de Entrega'	, ; //X3_DESCSPA
	'Delivery Location', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'A8', ; //X3_ORDEM
	'L1_FORCADA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vend.Forcada', ; //X3_TITULO
	'Vent. oblig.', ; //X3_TITSPA
	'Forced sale', ; //X3_TITENG
	'Venda Forcada', ; //X3_DESCRIC
	'Venda obligada', ; //X3_DESCSPA
	'Forced sale', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio().or.Pertence("12")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L1', ; //X3_ORDEM
	'L1_XCELULA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Celular'	, ; //X3_TITULO
	'Celular'	, ; //X3_TITSPA
	'Celular'	, ; //X3_TITENG
	'Celular Destinatario'	, ; //X3_DESCRIC
	'Celular Destinatario'	, ; //X3_DESCSPA
	'Celular Destinatario'	, ; //X3_DESCENG
	'@R 99999-9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L2', ; //X3_ORDEM
	'L1_XCODSTA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Status', ; //X3_TITULO
	'Cod. Status', ; //X3_TITSPA
	'Cod. Status', ; //X3_TITENG
	'Codigo Status', ; //X3_DESCRIC
	'Codigo Status', ; //X3_DESCSPA
	'Codigo Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L3', ; //X3_ORDEM
	'L1_XDDD01'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ddd Tel01'	, ; //X3_TITULO
	'Ddd Tel01'	, ; //X3_TITSPA
	'Ddd Tel01'	, ; //X3_TITENG
	'Ddd Telefone 01', ; //X3_DESCRIC
	'Ddd Telefone 01', ; //X3_DESCSPA
	'Ddd Telefone 01', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L4', ; //X3_ORDEM
	'L1_XDDDCEL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ddd Celular', ; //X3_TITULO
	'Ddd Celular', ; //X3_TITSPA
	'Ddd Celular', ; //X3_TITENG
	'Ddd Celular', ; //X3_DESCRIC
	'Ddd Celular', ; //X3_DESCSPA
	'Ddd Celular', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L5', ; //X3_ORDEM
	'L1_XDESTAT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Status', ; //X3_TITULO
	'Desc Status', ; //X3_TITSPA
	'Desc Status', ; //X3_TITENG
	'Descricao Status', ; //X3_DESCRIC
	'Descricao Status', ; //X3_DESCSPA
	'Descricao Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L6', ; //X3_ORDEM
	'L1_XDOCTRF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Doc Transf', ; //X3_TITULO
	'Doc Transf', ; //X3_TITSPA
	'Doc Transf', ; //X3_TITENG
	'Documento Transferencia', ; //X3_DESCRIC
	'Documento Transferencia', ; //X3_DESCSPA
	'Documento Transferencia', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L7', ; //X3_ORDEM
	'L1_XMOVINT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Doc Interno', ; //X3_TITULO
	'Doc Interno', ; //X3_TITSPA
	'Doc Interno', ; //X3_TITENG
	'Documento Interno', ; //X3_DESCRIC
	'Documento Interno', ; //X3_DESCSPA
	'Documento Interno', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L8', ; //X3_ORDEM
	'L1_XMTCANC', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Motv. Cancel', ; //X3_TITULO
	'Motv. Cancel', ; //X3_TITSPA
	'Motv. Cancel', ; //X3_TITENG
	'Motivo do Cancelamento', ; //X3_DESCRIC
	'Motivo do Cancelamento', ; //X3_DESCSPA
	'Motivo do Cancelamento', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'L9', ; //X3_ORDEM
	'L1_XNOMDES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	50	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome Destina', ; //X3_TITULO
	'Nome Destina', ; //X3_TITSPA
	'Nome Destina', ; //X3_TITENG
	'Nome Destinatario', ; //X3_DESCRIC
	'Nome Destinatario', ; //X3_DESCSPA
	'Nome Destinatario', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M0', ; //X3_ORDEM
	'L1_XNUMECL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv Cli', ; //X3_TITULO
	'Num Pv Cli', ; //X3_TITSPA
	'Num Pv Cli', ; //X3_TITENG
	'Num Pv Cliente eCommerce', ; //X3_DESCRIC
	'Num Pv Cliente eCommerce', ; //X3_DESCSPA
	'Num Pv Cliente eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M1', ; //X3_ORDEM
	'L1_XNUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Pv eCom', ; //X3_TITULO
	'Cod. Pv eCom', ; //X3_TITSPA
	'Cod. Pv eCom', ; //X3_TITENG
	'Cod. Pedido de Venda eCom', ; //X3_DESCRIC
	'Cod. Pedido de Venda eCom', ; //X3_DESCSPA
	'Cod. Pedido de Venda eCom', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M2', ; //X3_ORDEM
	'L1_XOBSECO', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Obs Pv eComm', ; //X3_TITULO
	'Obs Pv eComm', ; //X3_TITSPA
	'Obs Pv eComm', ; //X3_TITENG
	'Observacao Pedido eComm', ; //X3_DESCRIC
	'Observacao Pedido eComm', ; //X3_DESCSPA
	'Observacao Pedido eComm', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M3', ; //X3_ORDEM
	'L1_XSERTRF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Serie Transf', ; //X3_TITULO
	'Serie Transf', ; //X3_TITSPA
	'Serie Transf', ; //X3_TITENG
	'Serie Transferencia'	, ; //X3_DESCRIC
	'Serie Transferencia'	, ; //X3_DESCSPA
	'Serie Transferencia'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M4', ; //X3_ORDEM
	'L1_XTEL01'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Telefone'	, ; //X3_TITULO
	'Telefone'	, ; //X3_TITSPA
	'Telefone'	, ; //X3_TITENG
	'Telefone'	, ; //X3_DESCRIC
	'Telefone'	, ; //X3_DESCSPA
	'Telefone'	, ; //X3_DESCENG
	'@R 99999-9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M5', ; //X3_ORDEM
	'L1_XTRACKI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod Rastreio', ; //X3_TITULO
	'Cod Rastreio', ; //X3_TITSPA
	'Cod Rastreio', ; //X3_TITENG
	'Codigo de Rastreio'	, ; //X3_DESCRIC
	'Codigo de Rastreio'	, ; //X3_DESCSPA
	'Codigo de Rastreio'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M6', ; //X3_ORDEM
	'L1_XVLBXPV', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Bx Ped eComm', ; //X3_TITULO
	'Bx Ped eComm', ; //X3_TITSPA
	'Bx Ped eComm', ; //X3_TITENG
	'Baixa do Pedido eCommerce', ; //X3_DESCRIC
	'Baixa do Pedido eCommerce', ; //X3_DESCSPA
	'Baixa do Pedido eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Validado;2=Validado', ; //X3_CBOX
	'1=Nao Validado;2=Validado', ; //X3_CBOXSPA
	'1=Nao Validado;2=Validado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M7', ; //X3_ORDEM
	'L1_XDOCREM', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Doc. Dev. Re', ; //X3_TITULO
	'Doc. Dev. Re', ; //X3_TITSPA
	'Doc. Dev. Re', ; //X3_TITENG
	'Doc. Devolucao Remessa', ; //X3_DESCRIC
	'Doc. Devolucao Remessa', ; //X3_DESCSPA
	'Doc. Devolucao Remessa', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M8', ; //X3_ORDEM
	'L1_XSERIRE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ser. Dev Rem', ; //X3_TITULO
	'Ser. Dev Rem', ; //X3_TITSPA
	'Ser. Dev Rem', ; //X3_TITENG
	'Serie Devolucao Remessa', ; //X3_DESCRIC
	'Serie Devolucao Remessa', ; //X3_DESCSPA
	'Serie Devolucao Remessa', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'M9', ; //X3_ORDEM
	'L1_XCOMPLE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Compl. End', ; //X3_TITULO
	'Compl. End', ; //X3_TITSPA
	'Compl. End', ; //X3_TITENG
	'Complemento Endereco'	, ; //X3_DESCRIC
	'Complemento Endereco'	, ; //X3_DESCSPA
	'Complemento Endereco'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'N0', ; //X3_ORDEM
	'L1_XENDNUM', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num. End'	, ; //X3_TITULO
	'Num. End'	, ; //X3_TITSPA
	'Num. End'	, ; //X3_TITENG
	'Num. Endereco Entrega'	, ; //X3_DESCRIC
	'Num. Endereco Entrega'	, ; //X3_DESCSPA
	'Num. Endereco Entrega'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'N1', ; //X3_ORDEM
	'L1_XREFEN'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ref. End'	, ; //X3_TITULO
	'Ref. End'	, ; //X3_TITSPA
	'Ref. End'	, ; //X3_TITENG
	'Referencia Endereco'	, ; //X3_DESCRIC
	'Referencia Endereco'	, ; //X3_DESCSPA
	'Referencia Endereco'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL1', ; //X3_ARQUIVO
	'N2', ; //X3_ORDEM
	'L1_XIDENDE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id End. Entr', ; //X3_TITULO
	'Id End. Entr', ; //X3_TITSPA
	'Id End. Entr', ; //X3_TITENG
	'Id Endereço de Entrega', ; //X3_DESCRIC
	'Id Endereço de Entrega', ; //X3_DESCSPA
	'Id Endereço de Entrega', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SL2
//
aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'L2_DESCRI'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descripcion', ; //X3_TITSPA
	'Description', ; //X3_TITENG
	'Descricao do Produto'	, ; //X3_DESCRIC
	'Descripci¾n del Producto', ; //X3_DESCSPA
	'Description of Product', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'07', ; //X3_ORDEM
	'L2_VLRITEM', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Item'	, ; //X3_TITULO
	'Vlr. Item'	, ; //X3_TITSPA
	'Item Value', ; //X3_TITENG
	'Valor do Item', ; //X3_DESCRIC
	'Valor Item', ; //X3_DESCSPA
	'Item Value', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'13', ; //X3_ORDEM
	'L2_CF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Fiscal', ; //X3_TITULO
	'Cod. Fiscal', ; //X3_TITSPA
	'Fiscal Code', ; //X3_TITENG
	'Codigo Fiscal da Operacao', ; //X3_DESCRIC
	'Codigo Fiscal Operacion', ; //X3_DESCSPA
	'Operation Fiscal Code'	, ; //X3_DESCENG
	'@9', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'13', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'naovazio()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'22', ; //X3_ORDEM
	'L2_TABELA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tabela Preco', ; //X3_TITULO
	'Lista Precio', ; //X3_TITSPA
	'List Price', ; //X3_TITENG
	'Tabela de Preco', ; //X3_DESCRIC
	'Tabla de Precio', ; //X3_DESCSPA
	'List Price', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("1/2/3/4/5/6/7/8/9")'		, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'23', ; //X3_ORDEM
	'L2_STATUS'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status Troca', ; //X3_TITULO
	'Estatus Camb', ; //X3_TITSPA
	'Exchange Sta', ; //X3_TITENG
	'Status Troca Mercadoria', ; //X3_DESCRIC
	'Estatus de Cambio de Merc', ; //X3_DESCSPA
	'Product Exchange Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("D/R")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'G5', ; //X3_ORDEM
	'L2_XDESTAT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Status', ; //X3_TITULO
	'Desc Status', ; //X3_TITSPA
	'Desc Status', ; //X3_TITENG
	'Descricao Status Item'	, ; //X3_DESCRIC
	'Descricao Status Item'	, ; //X3_DESCSPA
	'Descricao Status Item'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'G6', ; //X3_ORDEM
	'L2_XPRODTP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Produto', ; //X3_TITULO
	'Tipo Produto', ; //X3_TITSPA
	'Tipo Produto', ; //X3_TITENG
	'Tipo de Produto', ; //X3_DESCRIC
	'Tipo de Produto', ; //X3_DESCSPA
	'Tipo de Produto', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOX
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOXSPA
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'G7', ; //X3_ORDEM
	'L2_XPRZENT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Prz Entrega', ; //X3_TITULO
	'Prz Entrega', ; //X3_TITSPA
	'Prz Entrega', ; //X3_TITENG
	'Prazo de Entrega', ; //X3_DESCRIC
	'Prazo de Entrega', ; //X3_DESCSPA
	'Prazo de Entrega', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL2', ; //X3_ARQUIVO
	'G8', ; //X3_ORDEM
	'L2_XSTATIT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status Item', ; //X3_TITULO
	'Status Item', ; //X3_TITSPA
	'Status Item', ; //X3_TITENG
	'Codigo Status Item'	, ; //X3_DESCRIC
	'Codigo Status Item'	, ; //X3_DESCSPA
	'Codigo Status Item'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SL4
//
aAdd( aSX3, { ;
	'SL4', ; //X3_ARQUIVO
	'59', ; //X3_ORDEM
	'L4_XNUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Pv eCom', ; //X3_TITULO
	'Cod. Pv eCom', ; //X3_TITSPA
	'Cod. Pv eCom', ; //X3_TITENG
	'Cod. Pedido de Venda eCom', ; //X3_DESCRIC
	'Cod. Pedido de Venda eCom', ; //X3_DESCSPA
	'Cod. Pedido de Venda eCom', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL4', ; //X3_ARQUIVO
	'60', ; //X3_ORDEM
	'L4_XNUMECL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv Cli', ; //X3_TITULO
	'Num Pv Cli', ; //X3_TITSPA
	'Num Pv Cli', ; //X3_TITENG
	'Num Pv Cliente eCommerce', ; //X3_DESCRIC
	'Num Pv Cliente eCommerce', ; //X3_DESCSPA
	'Num Pv Cliente eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SL4', ; //X3_ARQUIVO
	'61', ; //X3_ORDEM
	'L4_XTID'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. TID'	, ; //X3_TITULO
	'Cod. TID'	, ; //X3_TITSPA
	'Cod. TID'	, ; //X3_TITENG
	'Codigo Pagamento eCommerc', ; //X3_DESCRIC
	'Codigo Pagamento eCommerc', ; //X3_DESCSPA
	'Codigo Pagamento eCommerc', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SLQ
//
aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'LQ_COMIS'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Comissao'	, ; //X3_TITULO
	'Comision'	, ; //X3_TITSPA
	'Commission', ; //X3_TITENG
	'Comissao do Vendedor'	, ; //X3_DESCRIC
	'Comision del Vendedor'	, ; //X3_DESCSPA
	'Seller Commission', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo() .or. vazio()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'09', ; //X3_ORDEM
	'LQ_TIPOCLI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Cliente', ; //X3_TITULO
	'Tipo Cliente', ; //X3_TITSPA
	'Customer Ty.', ; //X3_TITENG
	'Tipo do Cliente', ; //X3_DESCRIC
	'Tipo del Cliente', ; //X3_DESCSPA
	'Type of Customer', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Pertence("F\L\R\S\X")'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'14', ; //X3_ORDEM
	'LQ_DTLIM'	, ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dt.Validade', ; //X3_TITULO
	'Fch Validez', ; //X3_TITSPA
	'Validity Dt.', ; //X3_TITENG
	'Data Validade Orcamento', ; //X3_DESCRIC
	'Fecha Validez Presupuesto', ; //X3_DESCSPA
	'Budget Validity Date'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'dDataBase'	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'naovazio()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'73', ; //X3_ORDEM
	'LQ_ENDCOB'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End. Cobranc', ; //X3_TITULO
	'Dir.Cobranza', ; //X3_TITSPA
	'Collect.Add.', ; //X3_TITENG
	'Enderaco de Cobranca'	, ; //X3_DESCRIC
	'Direccion de Cobranza'	, ; //X3_DESCSPA
	'Collection Address'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'Vazio.or.Texto()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'74', ; //X3_ORDEM
	'LQ_ENDENT'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End. Entrega', ; //X3_TITULO
	'Dir.Entrega', ; //X3_TITSPA
	'Deliv.Locat.', ; //X3_TITENG
	'Endereco de Entrega'	, ; //X3_DESCRIC
	'Direccion de Entrega'	, ; //X3_DESCSPA
	'Delivery Location', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(136) + Chr(176) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K0', ; //X3_ORDEM
	'LQ_XCELULA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Celular'	, ; //X3_TITULO
	'Celular'	, ; //X3_TITSPA
	'Celular'	, ; //X3_TITENG
	'Celular'	, ; //X3_DESCRIC
	'Celular'	, ; //X3_DESCSPA
	'Celular'	, ; //X3_DESCENG
	'@R 99999-9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K1', ; //X3_ORDEM
	'LQ_XCODSTA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Status', ; //X3_TITULO
	'Cod. Status', ; //X3_TITSPA
	'Cod. Status', ; //X3_TITENG
	'Codigo Status', ; //X3_DESCRIC
	'Codigo Status', ; //X3_DESCSPA
	'Codigo Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K2', ; //X3_ORDEM
	'LQ_XDDD01'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ddd Telefone', ; //X3_TITULO
	'Ddd Telefone', ; //X3_TITSPA
	'Ddd Telefone', ; //X3_TITENG
	'Ddd Telefone', ; //X3_DESCRIC
	'Ddd Telefone', ; //X3_DESCSPA
	'Ddd Telefone', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K3', ; //X3_ORDEM
	'LQ_XDDDCEL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ddd Celular', ; //X3_TITULO
	'Ddd Celular', ; //X3_TITSPA
	'Ddd Celular', ; //X3_TITENG
	'Ddd Celular', ; //X3_DESCRIC
	'Ddd Celular', ; //X3_DESCSPA
	'Ddd Celular', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K4', ; //X3_ORDEM
	'LQ_XDESTAT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Status', ; //X3_TITULO
	'Desc Status', ; //X3_TITSPA
	'Desc Status', ; //X3_TITENG
	'Descricao Status', ; //X3_DESCRIC
	'Descricao Status', ; //X3_DESCSPA
	'Descricao Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K5', ; //X3_ORDEM
	'LQ_XDOCTRF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Doc Transf', ; //X3_TITULO
	'Doc Transf', ; //X3_TITSPA
	'Doc Transf', ; //X3_TITENG
	'Documeto Transferencia', ; //X3_DESCRIC
	'Documeto Transferencia', ; //X3_DESCSPA
	'Documeto Transferencia', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K6', ; //X3_ORDEM
	'LQ_XMOVINT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Doc Intermo', ; //X3_TITULO
	'Doc Intermo', ; //X3_TITSPA
	'Doc Intermo', ; //X3_TITENG
	'Documento Interno', ; //X3_DESCRIC
	'Documento Interno', ; //X3_DESCSPA
	'Documento Interno', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K7', ; //X3_ORDEM
	'LQ_XMTCANC', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Motv. Cancel', ; //X3_TITULO
	'Motv. Cancel', ; //X3_TITSPA
	'Motv. Cancel', ; //X3_TITENG
	'Motivo do Cancelamento', ; //X3_DESCRIC
	'Motivo do Cancelamento', ; //X3_DESCSPA
	'Motivo do Cancelamento', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K8', ; //X3_ORDEM
	'LQ_XNOMDES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	50	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome Destina', ; //X3_TITULO
	'Nome Destina', ; //X3_TITSPA
	'Nome Destina', ; //X3_TITENG
	'Nome Destinatario', ; //X3_DESCRIC
	'Nome Destinatario', ; //X3_DESCSPA
	'Nome Destinatario', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'K9', ; //X3_ORDEM
	'LQ_XNUMECL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv Cli', ; //X3_TITULO
	'Num Pv Cli', ; //X3_TITSPA
	'Num Pv Cli', ; //X3_TITENG
	'Num Pv Cliente eCommerce', ; //X3_DESCRIC
	'Num Pv Cliente eCommerce', ; //X3_DESCSPA
	'Num Pv Cliente eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L0', ; //X3_ORDEM
	'LQ_XNUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Pv eCom', ; //X3_TITULO
	'Cod. Pv eCom', ; //X3_TITSPA
	'Cod. Pv eCom', ; //X3_TITENG
	'Cod. Pedido de Venda eCom', ; //X3_DESCRIC
	'Cod. Pedido de Venda eCom', ; //X3_DESCSPA
	'Cod. Pedido de Venda eCom', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L1', ; //X3_ORDEM
	'LQ_XOBSECO', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Obs Pv eComm', ; //X3_TITULO
	'Obs Pv eComm', ; //X3_TITSPA
	'Obs Pv eComm', ; //X3_TITENG
	'Observacao Pedido eComm', ; //X3_DESCRIC
	'Observacao Pedido eComm', ; //X3_DESCSPA
	'Observacao Pedido eComm', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L2', ; //X3_ORDEM
	'LQ_XSERTRF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Serie Transf', ; //X3_TITULO
	'Serie Transf', ; //X3_TITSPA
	'Serie Transf', ; //X3_TITENG
	'Serie Transferencia'	, ; //X3_DESCRIC
	'Serie Transferencia'	, ; //X3_DESCSPA
	'Serie Transferencia'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L3', ; //X3_ORDEM
	'LQ_XTEL01'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Telefone 01', ; //X3_TITULO
	'Telefone 01', ; //X3_TITSPA
	'Telefone 01', ; //X3_TITENG
	'Telefone 01', ; //X3_DESCRIC
	'Telefone 01', ; //X3_DESCSPA
	'Telefone 01', ; //X3_DESCENG
	'@R 99999-9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L4', ; //X3_ORDEM
	'LQ_XTRACKI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod Rastreio', ; //X3_TITULO
	'Cod Rastreio', ; //X3_TITSPA
	'Cod Rastreio', ; //X3_TITENG
	'Codigo de Rastreio'	, ; //X3_DESCRIC
	'Codigo de Rastreio'	, ; //X3_DESCSPA
	'Codigo de Rastreio'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L5', ; //X3_ORDEM
	'LQ_XVLBXPV', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Bx Ped eComm', ; //X3_TITULO
	'Bx Ped eComm', ; //X3_TITSPA
	'Bx Ped eComm', ; //X3_TITENG
	'Baixa do Pedido eCommerce', ; //X3_DESCRIC
	'Baixa do Pedido eCommerce', ; //X3_DESCSPA
	'Baixa do Pedido eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Validado;2=Validado', ; //X3_CBOX
	'1=Nao Validado;2=Validado', ; //X3_CBOXSPA
	'1=Nao Validado;2=Validado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L6', ; //X3_ORDEM
	'LQ_XDOCREM', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Doc. Dev Rem', ; //X3_TITULO
	'Doc. Dev Rem', ; //X3_TITSPA
	'Doc. Dev Rem', ; //X3_TITENG
	'Doc Devolucao Remessa'	, ; //X3_DESCRIC
	'Doc Devolucao Remessa'	, ; //X3_DESCSPA
	'Doc Devolucao Remessa'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L7', ; //X3_ORDEM
	'LQ_XSERIRE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ser. Dev Rem', ; //X3_TITULO
	'Ser. Dev Rem', ; //X3_TITSPA
	'Ser. Dev Rem', ; //X3_TITENG
	'Serie Devolucao Remessa', ; //X3_DESCRIC
	'Serie Devolucao Remessa', ; //X3_DESCSPA
	'Serie Devolucao Remessa', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L8', ; //X3_ORDEM
	'LQ_XCOMPLE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Compl. End', ; //X3_TITULO
	'Compl. End', ; //X3_TITSPA
	'Compl. End', ; //X3_TITENG
	'Complemento Endereco'	, ; //X3_DESCRIC
	'Complemento Endereco'	, ; //X3_DESCSPA
	'Complemento Endereco'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'L9', ; //X3_ORDEM
	'LQ_XREFEN'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ref. End'	, ; //X3_TITULO
	'Ref. End'	, ; //X3_TITSPA
	'Ref. End'	, ; //X3_TITENG
	'Referencia Endereco'	, ; //X3_DESCRIC
	'Referencia Endereco'	, ; //X3_DESCSPA
	'Referencia Endereco'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'M0', ; //X3_ORDEM
	'LQ_XENDNUM', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num. End'	, ; //X3_TITULO
	'Num. End'	, ; //X3_TITSPA
	'Num. End'	, ; //X3_TITENG
	'Num. Endereco Entrega'	, ; //X3_DESCRIC
	'Num. Endereco Entrega'	, ; //X3_DESCSPA
	'Num. Endereco Entrega'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLQ', ; //X3_ARQUIVO
	'M1', ; //X3_ORDEM
	'LQ_XIDENDE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id End. Entr', ; //X3_TITULO
	'Id End. Entr', ; //X3_TITSPA
	'Id End. Entr', ; //X3_TITENG
	'Id Endereco de Entrega', ; //X3_DESCRIC
	'Id Endereco de Entrega', ; //X3_DESCSPA
	'Id Endereco de Entrega', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela SLR
//
aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'LR_DESCRI'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descripcion', ; //X3_TITSPA
	'Description', ; //X3_TITENG
	'Descricao do Produto'	, ; //X3_DESCRIC
	'Descripci¾n del Producto', ; //X3_DESCSPA
	'Description of Product', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'texto()'	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'LR_VLRITEM', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Item'	, ; //X3_TITULO
	'Vlr.Item'	, ; //X3_TITSPA
	'Item Value', ; //X3_TITENG
	'Valor do Item', ; //X3_DESCRIC
	'Valor del Item', ; //X3_DESCSPA
	'Item Value', ; //X3_DESCENG
	'@E 99,999,999,999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(159) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'positivo()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'14', ; //X3_ORDEM
	'LR_CF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Fiscal', ; //X3_TITULO
	'Cod. Fiscal', ; //X3_TITSPA
	'Fiscal Code', ; //X3_TITENG
	'Codigo Fiscal da Operacao', ; //X3_DESCRIC
	'Codigo de la Operacion', ; //X3_DESCSPA
	'Operation Fiscal Code'	, ; //X3_DESCENG
	'@9', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'13', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'naovazio()', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'24', ; //X3_ORDEM
	'LR_TABELA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tabela Preco', ; //X3_TITULO
	'Lista Precio', ; //X3_TITSPA
	'List Price', ; //X3_TITENG
	'Tabela de Preco', ; //X3_DESCRIC
	'Tabla de Precio', ; //X3_DESCSPA
	'List Price', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("1/2/3/4/5/6/7/8/9")'		, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'25', ; //X3_ORDEM
	'LR_STATUS'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status Troca', ; //X3_TITULO
	'Estatus Camb', ; //X3_TITSPA
	'Exchange Sta', ; //X3_TITENG
	'Status Troca Mercadoria', ; //X3_DESCRIC
	'Estatus de Cambio de Merc', ; //X3_DESCSPA
	'Product Exchange Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	'pertence("D/R")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'G7', ; //X3_ORDEM
	'LR_XDESTAT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Status', ; //X3_TITULO
	'Desc Status', ; //X3_TITSPA
	'Desc Status', ; //X3_TITENG
	'Descricao Status Item'	, ; //X3_DESCRIC
	'Descricao Status Item'	, ; //X3_DESCSPA
	'Descricao Status Item'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'G8', ; //X3_ORDEM
	'LR_XPRODTP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Produto', ; //X3_TITULO
	'Tipo Produto', ; //X3_TITSPA
	'Tipo Produto', ; //X3_TITENG
	'Tipo Produto', ; //X3_DESCRIC
	'Tipo Produto', ; //X3_DESCSPA
	'Tipo Produto', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'G9', ; //X3_ORDEM
	'LR_XPRZENT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Prz Entrega', ; //X3_TITULO
	'Prz Entrega', ; //X3_TITSPA
	'Prz Entrega', ; //X3_TITENG
	'Prazo de Entrega', ; //X3_DESCRIC
	'Prazo de Entrega', ; //X3_DESCSPA
	'Prazo de Entrega', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'SLR', ; //X3_ARQUIVO
	'H0', ; //X3_ORDEM
	'LR_XSTATIT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status Item', ; //X3_TITULO
	'Status Item', ; //X3_TITSPA
	'Status Item', ; //X3_TITENG
	'Status Item', ; //X3_DESCRIC
	'Status Item', ; //X3_DESCSPA
	'Status Item', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WS0
//
aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WS0_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WS0_COD'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Interface'	, ; //X3_TITULO
	'Interface'	, ; //X3_TITSPA
	'Interface'	, ; //X3_TITENG
	'Interface'	, ; //X3_DESCRIC
	'Interface'	, ; //X3_DESCSPA
	'Interface'	, ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WS0_DESCIN', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	50	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Interf', ; //X3_TITULO
	'Desc Interf', ; //X3_TITSPA
	'Desc Interf', ; //X3_TITENG
	'Descricao Interface'	, ; //X3_DESCRIC
	'Descricao Interface'	, ; //X3_DESCSPA
	'Descricao Interface'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'WS0_DATA'	, ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Data', ; //X3_TITULO
	'Data', ; //X3_TITSPA
	'Data', ; //X3_TITENG
	'Data da Integracao'	, ; //X3_DESCRIC
	'Data da Integracao'	, ; //X3_DESCSPA
	'Data da Integracao'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WS0_HRINI'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora Inicial', ; //X3_TITULO
	'Hora Inicial', ; //X3_TITSPA
	'Hora Inicial', ; //X3_TITENG
	'Hora Inicial', ; //X3_DESCRIC
	'Hora Inicial', ; //X3_DESCSPA
	'Hora Inicial', ; //X3_DESCENG
	'@R 99:99:99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'WS0_HRFIM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora Fim'	, ; //X3_TITULO
	'Hora Fim'	, ; //X3_TITSPA
	'Hora Fim'	, ; //X3_TITENG
	'Hora Fim'	, ; //X3_DESCRIC
	'Hora Fim'	, ; //X3_DESCSPA
	'Hora Fim'	, ; //X3_DESCENG
	'@R 99:99:99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'07', ; //X3_ORDEM
	'WS0_HRTOT'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora Total', ; //X3_TITULO
	'Hora Total', ; //X3_TITSPA
	'Hora Total', ; //X3_TITENG
	'Hora Total', ; //X3_DESCRIC
	'Hora Total', ; //X3_DESCSPA
	'Hora Total', ; //X3_DESCENG
	'@r 99:99:99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'WS0_STATUS', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status Int', ; //X3_TITULO
	'Status Int', ; //X3_TITSPA
	'Status Int', ; //X3_TITENG
	'Status Integracao', ; //X3_DESCRIC
	'Status Integracao', ; //X3_DESCSPA
	'Status Integracao', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'0=Sucesso;1=Erro', ; //X3_CBOX
	'0=Sucesso;1=Erro', ; //X3_CBOXSPA
	'0=Sucesso;1=Erro', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'09', ; //X3_ORDEM
	'WS0_THREAD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Thread'	, ; //X3_TITULO
	'Thread'	, ; //X3_TITSPA
	'Thread'	, ; //X3_TITENG
	'Id da Thread', ; //X3_DESCRIC
	'Id da Thread', ; //X3_DESCSPA
	'Id da Thread', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'10', ; //X3_ORDEM
	'WS0_QTDINT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	4	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Qtd Integrad', ; //X3_TITULO
	'Qtd Integrad', ; //X3_TITSPA
	'Qtd Integrad', ; //X3_TITENG
	'Qtd Itens Integrados'	, ; //X3_DESCRIC
	'Qtd Itens Integrados'	, ; //X3_DESCSPA
	'Qtd Itens Integrados'	, ; //X3_DESCENG
	'@E 9,999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS0', ; //X3_ARQUIVO
	'11', ; //X3_ORDEM
	'WS0_ERROS'	, ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Msg Erros'	, ; //X3_TITULO
	'Msg Erros'	, ; //X3_TITSPA
	'Msg Erros'	, ; //X3_TITENG
	'Mensagem de Erros', ; //X3_DESCRIC
	'Mensagem de Erros', ; //X3_DESCSPA
	'Mensagem de Erros', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WS1
//
aAdd( aSX3, { ;
	'WS1', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WS1_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS1', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WS1_CODIGO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Codigo'	, ; //X3_TITULO
	'Codigo'	, ; //X3_TITSPA
	'Codigo'	, ; //X3_TITENG
	'Codigo'	, ; //X3_DESCRIC
	'Codigo'	, ; //X3_DESCSPA
	'Codigo'	, ; //X3_DESCENG
	'@9', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS1', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WS1_DESCRI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descricao'	, ; //X3_TITSPA
	'Descricao'	, ; //X3_TITENG
	'Descricao'	, ; //X3_DESCRIC
	'Descricao'	, ; //X3_DESCSPA
	'Descricao'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS1', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'WS1_CORSTA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cor Status', ; //X3_TITULO
	'Cor Status', ; //X3_TITSPA
	'Cor Status', ; //X3_TITENG
	'Cor Status', ; //X3_DESCRIC
	'Cor Status', ; //X3_DESCSPA
	'Cor Status', ; //X3_DESCENG
	'@BMP', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'BMPRET'	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS1', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WS1_ENVECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Envia Status', ; //X3_TITULO
	'Envia Status', ; //X3_TITSPA
	'Envia Status', ; //X3_TITENG
	'Envia Status p/ eCommerce', ; //X3_DESCRIC
	'Envia Status p/ eCommerce', ; //X3_DESCSPA
	'Envia Status p/ eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'S=Sim;N=Nao', ; //X3_CBOX
	'S=Sim;N=Nao', ; //X3_CBOXSPA
	'S=Sim;N=Nao', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS1', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'WS1_CODPRO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Processo Eco', ; //X3_TITULO
	'Processo Eco', ; //X3_TITSPA
	'Processo Eco', ; //X3_TITENG
	'Processo eCommerce'	, ; //X3_DESCRIC
	'Processo eCommerce'	, ; //X3_DESCSPA
	'Processo eCommerce'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS1', ; //X3_ARQUIVO
	'07', ; //X3_ORDEM
	'WS1_DESPRO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Process', ; //X3_TITULO
	'Desc Process', ; //X3_TITSPA
	'Desc Process', ; //X3_TITENG
	'Descricao do Processo'	, ; //X3_DESCRIC
	'Descricao do Processo'	, ; //X3_DESCSPA
	'Descricao do Processo'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS1', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'WS1_DESCVT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descr. VTex', ; //X3_TITULO
	'Descr. VTex', ; //X3_TITSPA
	'Descr. VTex', ; //X3_TITENG
	'Descricao VTEX', ; //X3_DESCRIC
	'Descricao VTEX', ; //X3_DESCSPA
	'Descricao VTEX', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WS2
//
aAdd( aSX3, { ;
	'WS2', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WS2_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS2', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WS2_NUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Ped Eco', ; //X3_TITULO
	'Num Ped Eco', ; //X3_TITSPA
	'Num Ped Eco', ; //X3_TITENG
	'Numero Pedido eCommerce', ; //X3_DESCRIC
	'Numero Pedido eCommerce', ; //X3_DESCSPA
	'Numero Pedido eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS2', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WS2_NUMSL1', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Codigo SL1', ; //X3_TITULO
	'Codigo SL1', ; //X3_TITSPA
	'Codigo SL1', ; //X3_TITENG
	'Codigo SL1', ; //X3_DESCRIC
	'Codigo SL1', ; //X3_DESCSPA
	'Codigo SL1', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS2', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'WS2_DATA'	, ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Data', ; //X3_TITULO
	'Data', ; //X3_TITSPA
	'Data', ; //X3_TITENG
	'Data', ; //X3_DESCRIC
	'Data', ; //X3_DESCSPA
	'Data', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS2', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WS2_HORA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora', ; //X3_TITULO
	'Hora', ; //X3_TITSPA
	'Hora', ; //X3_TITENG
	'Hora', ; //X3_DESCRIC
	'Hora', ; //X3_DESCSPA
	'Hora', ; //X3_DESCENG
	'99:99:99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS2', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'WS2_CODSTA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod Status', ; //X3_TITULO
	'Cod Status', ; //X3_TITSPA
	'Cod Status', ; //X3_TITENG
	'Codigo Status', ; //X3_DESCRIC
	'Codigo Status', ; //X3_DESCSPA
	'Codigo Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WS3
//
aAdd( aSX3, { ;
	'WS3', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WS3_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS3', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WS3_CODIGO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Codigo Forma', ; //X3_TITULO
	'Codigo Forma', ; //X3_TITSPA
	'Codigo Forma', ; //X3_TITENG
	'Codigo Forma eCommerce', ; //X3_DESCRIC
	'Codigo Forma eCommerce', ; //X3_DESCSPA
	'Codigo Forma eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS3', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WS3_DESCRI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descricao'	, ; //X3_TITSPA
	'Descricao'	, ; //X3_TITENG
	'Descricao forma ecommerce', ; //X3_DESCRIC
	'Descricao forma ecommerce', ; //X3_DESCSPA
	'Descricao forma ecommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WS4
//
aAdd( aSX3, { ;
	'WS4', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WS4_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS4', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WS4_TIPO'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo de Oper', ; //X3_TITULO
	'Tipo de Oper', ; //X3_TITSPA
	'Tipo de Oper', ; //X3_TITENG
	'Tipo de Operadora', ; //X3_DESCRIC
	'Tipo de Operadora', ; //X3_DESCSPA
	'Tipo de Operadora', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Cartao Credito;2=Boleto e  Debito;3=Pagamento em Casa'				, ; //X3_CBOX
	'1=Cartao Credito;2=Boleto e  Debito;3=Pagamento em Casa'				, ; //X3_CBOXSPA
	'1=Cartao Credito;2=Boleto e  Debito;3=Pagamento em Casa'				, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS4', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WS4_CODIGO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Codigo Oper', ; //X3_TITULO
	'Codigo Oper', ; //X3_TITSPA
	'Codigo Oper', ; //X3_TITENG
	'Codigo Operadora', ; //X3_DESCRIC
	'Codigo Operadora', ; //X3_DESCSPA
	'Codigo Operadora', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS4', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'WS4_DESCRI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descricao'	, ; //X3_TITSPA
	'Descricao'	, ; //X3_TITENG
	'Descricao'	, ; //X3_DESCRIC
	'Descricao'	, ; //X3_DESCSPA
	'Descricao'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS4', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WS4_CODADM', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Adm Fin', ; //X3_TITULO
	'Cod. Adm Fin', ; //X3_TITSPA
	'Cod. Adm Fin', ; //X3_TITENG
	'Cod. Adm Financeira', ; //X3_DESCRIC
	'Cod. Adm Financeira', ; //X3_DESCSPA
	'Cod. Adm Financeira', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SAE', ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192)	, ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WS5
//
aAdd( aSX3, { ;
	'WS5', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WS5_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS5', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WS5_CODIGO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Codigo Campo', ; //X3_TITULO
	'Codigo Campo', ; //X3_TITSPA
	'Codigo Campo', ; //X3_TITENG
	'Codigo Campo', ; //X3_DESCRIC
	'Codigo Campo', ; //X3_DESCSPA
	'Codigo Campo', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'GETSXENUM("WS5","WS5_CODIGO")'		, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	'ExistChav("WS5")', ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS5', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WS5_CAMPO'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Campo VTex', ; //X3_TITULO
	'Campo VTex', ; //X3_TITSPA
	'Campo VTex', ; //X3_TITENG
	'Campo VTex', ; //X3_DESCRIC
	'Campo VTex', ; //X3_DESCSPA
	'Campo VTex', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WS6
//
aAdd( aSX3, { ;
	'WS6', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WS6_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS6', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WS6_CODPRD', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Produto', ; //X3_TITULO
	'Cod. Produto', ; //X3_TITSPA
	'Cod. Produto', ; //X3_TITENG
	'Codigo do Produto', ; //X3_DESCRIC
	'Codigo do Produto', ; //X3_DESCSPA
	'Codigo do Produto', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS6', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WS6_CODIGO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Codigo Campo', ; //X3_TITULO
	'Codigo Campo', ; //X3_TITSPA
	'Codigo Campo', ; //X3_TITENG
	'Codigo Campo', ; //X3_DESCRIC
	'Codigo Campo', ; //X3_DESCSPA
	'Codigo Campo', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS6', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'WS6_CAMPO'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Campo VTEX', ; //X3_TITULO
	'Campo VTEX', ; //X3_TITSPA
	'Campo VTEX', ; //X3_TITENG
	'Campo VTEX', ; //X3_DESCRIC
	'Campo VTEX', ; //X3_DESCSPA
	'Campo VTEX', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WS6', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WS6_DESCEC', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc. VTEX', ; //X3_TITULO
	'Desc. VTEX', ; //X3_TITSPA
	'Desc. VTEX', ; //X3_TITENG
	'Desc. campo especifico', ; //X3_DESCRIC
	'Desc. campo especifico', ; //X3_DESCSPA
	'Desc. campo especifico', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	'€'	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME
	
aAdd( aSX3, { ;
	'WS6', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'WS6_ENVECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Envio eComm?', ; //X3_TITULO
	'Envio eComm?', ; //X3_TITSPA
	'Envio eComm?', ; //X3_TITENG
	'Envio eCommerce', ; //X3_DESCRIC
	'Envio eCommerce', ; //X3_DESCSPA
	'Envio eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Enviado;2=Enviado', ; //X3_CBOX
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXSPA
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WSA
//
aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WSA_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WSA_NUM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'No Orcamento', ; //X3_TITULO
	'Nro.Presup.', ; //X3_TITSPA
	'Budget No.', ; //X3_TITENG
	'Numero do Orcamento', ; //X3_DESCRIC
	'Numero del Presupuesto', ; //X3_DESCSPA
	'Budget Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176)					, ; //X3_USADO
	'GetSxENum("WSA","WSA_NUM")', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(129) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	'.F.', ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WSA_CLIENT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cliente'	, ; //X3_TITULO
	'Cliente'	, ; //X3_TITSPA
	'Customer'	, ; //X3_TITENG
	'Codigo do Cliente', ; //X3_DESCRIC
	'Codigo del Cliente', ; //X3_DESCSPA
	'Customer´s Code', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA1', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(135) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'001', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'WSA_LOJA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Loja Cliente', ; //X3_TITULO
	'Tda. Cliente', ; //X3_TITSPA
	'Custom. Unit', ; //X3_TITENG
	'Loja Cliente', ; //X3_DESCRIC
	'Tienda Cliente', ; //X3_DESCSPA
	'Customer Unit', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(135) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'002', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WSA_COMIS'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Comissao'	, ; //X3_TITULO
	'Comision'	, ; //X3_TITSPA
	'Commission', ; //X3_TITENG
	'Comissao do Vendedor', ; //X3_DESCRIC
	'Comision del Vendedor', ; //X3_DESCSPA
	'Seller Commission', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WSA_TIPOCL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Cliente', ; //X3_TITULO
	'Tipo Cliente', ; //X3_TITSPA
	'Customer Ty.', ; //X3_TITENG
	'Tipo do Cliente', ; //X3_DESCRIC
	'Tipo del Cliente', ; //X3_DESCSPA
	'Type of Customer', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'WSA_VLRTOT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Total'	, ; //X3_TITULO
	'Valor Total', ; //X3_TITSPA
	'Grand Total', ; //X3_TITENG
	'Valor Total do Orcamento', ; //X3_DESCRIC
	'Vlr. Total de Presupuesto', ; //X3_DESCSPA
	'Budget Grand Total', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'07', ; //X3_ORDEM
	'WSA_VEND'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vendedor'	, ; //X3_TITULO
	'Vendedor'	, ; //X3_TITSPA
	'Sales Repr.', ; //X3_TITENG
	'Codigo do Vendedor', ; //X3_DESCRIC
	'Codigo do Vendedor', ; //X3_DESCSPA
	'Seller Code', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA3', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'WSA_DESCON', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Desconto', ; //X3_TITULO
	'Vl.Descuento', ; //X3_TITSPA
	'Discount'	, ; //X3_TITENG
	'Valor Total do Desconto', ; //X3_DESCRIC
	'Valor Total de Descuento', ; //X3_DESCSPA
	'Discount Total Value', ; //X3_DESCENG
	'@E 9,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'09', ; //X3_ORDEM
	'WSA_VLRLIQ', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Liquido', ; //X3_TITULO
	'Valor Neto', ; //X3_TITSPA
	'Net Value'	, ; //X3_TITENG
	'Valor Liquido Orcamento', ; //X3_DESCRIC
	'Valor Neto Presupuesto', ; //X3_DESCSPA
	'Budget Net Value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'10', ; //X3_ORDEM
	'WSA_DTLIM'	, ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dt.Validade', ; //X3_TITULO
	'Fch Validez', ; //X3_TITSPA
	'Validity Dt.', ; //X3_TITENG
	'Data Validade Orcamento', ; //X3_DESCRIC
	'Fecha Validez Presupuesto', ; //X3_DESCSPA
	'Budget Validity Date', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'dDataBase'	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'11', ; //X3_ORDEM
	'WSA_DOC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nota Fiscal', ; //X3_TITULO
	'Factura'	, ; //X3_TITSPA
	'Invoice'	, ; //X3_TITENG
	'Numero da Nota Fiscal', ; //X3_DESCRIC
	'Numero de la Factura', ; //X3_DESCSPA
	'Invoice Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(134) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'018', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'12', ; //X3_ORDEM
	'WSA_SERIE'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Serie', ; //X3_TITULO
	'Serie', ; //X3_TITSPA
	'Series'	, ; //X3_TITENG
	'Serie da Nota Fiscal', ; //X3_DESCRIC
	'Serie de la Factura', ; //X3_DESCSPA
	'Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'094', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'13', ; //X3_ORDEM
	'WSA_EMISNF', ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Emissao NF', ; //X3_TITULO
	'Emision Fact', ; //X3_TITSPA
	'Invoice Iss.', ; //X3_TITENG
	'Data Emissao NF', ; //X3_DESCRIC
	'Fecha de Emision Factura', ; //X3_DESCSPA
	'Date of Invoice Issuing', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'14', ; //X3_ORDEM
	'WSA_VALBRU', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vl.Bruto NF', ; //X3_TITULO
	'Vlr.Bruto Fc', ; //X3_TITSPA
	'Gross Value', ; //X3_TITENG
	'Valor Bruto da NF', ; //X3_DESCRIC
	'Valor Bruto de la Factura', ; //X3_DESCSPA
	'Invoice Gross Value', ; //X3_DESCENG
	'@E 9,999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'15', ; //X3_ORDEM
	'WSA_VALMER', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vl.Mercador.', ; //X3_TITULO
	'Vlr. Mercad.', ; //X3_TITSPA
	'Goods Value', ; //X3_TITENG
	'Valor das Mercadorias', ; //X3_DESCRIC
	'Valor de las Mercaderias', ; //X3_DESCSPA
	'Goods Value', ; //X3_DESCENG
	'@E 9,999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'16', ; //X3_ORDEM
	'WSA_TIPO'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Venda', ; //X3_TITULO
	'Tipo Venta', ; //X3_TITSPA
	'Sale Type'	, ; //X3_TITENG
	'Tipo da Venda', ; //X3_DESCRIC
	'Tipo de Venta', ; //X3_DESCSPA
	'Type of Sale', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'17', ; //X3_ORDEM
	'WSA_DESCNF', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor Desc.', ; //X3_TITULO
	'Vl.Descuento', ; //X3_TITSPA
	'Discount Val', ; //X3_TITENG
	'Valor do Desconto', ; //X3_DESCRIC
	'Valor del Descuento', ; //X3_DESCSPA
	'Discount Value', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'18', ; //X3_ORDEM
	'WSA_DINHEI', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Dinheiro'	, ; //X3_TITULO
	'Dinero'	, ; //X3_TITSPA
	'Cash', ; //X3_TITENG
	'Total em Dinheiro', ; //X3_DESCRIC
	'Total en Dinero', ; //X3_DESCSPA
	'Total in Cash', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'19', ; //X3_ORDEM
	'WSA_CHEQUE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Cheques'	, ; //X3_TITULO
	'Cheques'	, ; //X3_TITSPA
	'Checks'	, ; //X3_TITENG
	'Total em Cheques', ; //X3_DESCRIC
	'Total en Cheques', ; //X3_DESCSPA
	'Total in Check', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'20', ; //X3_ORDEM
	'WSA_CARTAO', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Cartão'	, ; //X3_TITULO
	'Tarjeta'	, ; //X3_TITSPA
	'Card', ; //X3_TITENG
	'Total em Cartao', ; //X3_DESCRIC
	'Total en Tarjeta', ; //X3_DESCSPA
	'Total in Credit Cards', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'21', ; //X3_ORDEM
	'WSA_CONVEN', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Convenio'	, ; //X3_TITULO
	'Convenios'	, ; //X3_TITSPA
	'Health Plan', ; //X3_TITENG
	'Total em Convenio', ; //X3_DESCRIC
	'Total en Convenio/Plan', ; //X3_DESCSPA
	'Total in Convention', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'22', ; //X3_ORDEM
	'WSA_VALES'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vales', ; //X3_TITULO
	'Vales', ; //X3_TITSPA
	'Vouchers'	, ; //X3_TITENG
	'Total em Vales', ; //X3_DESCRIC
	'Total en Vales', ; //X3_DESCSPA
	'Total in Vouchers', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'23', ; //X3_ORDEM
	'WSA_FINANC', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Financiado', ; //X3_TITULO
	'Financiado', ; //X3_TITSPA
	'Financed'	, ; //X3_TITENG
	'Total Financiado', ; //X3_DESCRIC
	'Total Financiado', ; //X3_DESCSPA
	'Total Financed', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'24', ; //X3_ORDEM
	'WSA_OUTROS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Outros'	, ; //X3_TITULO
	'Otros', ; //X3_TITSPA
	'Other', ; //X3_TITENG
	'Total em Outros', ; //X3_DESCRIC
	'Total en Otros', ; //X3_DESCSPA
	'Total Others', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'25', ; //X3_ORDEM
	'WSA_ENTRAD', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Entrada'	, ; //X3_TITULO
	'Entrada'	, ; //X3_TITSPA
	'Down Payment', ; //X3_TITENG
	'Entrada Negociada', ; //X3_DESCRIC
	'Entrada Negociada', ; //X3_DESCSPA
	'Negociated Down Payment', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'26', ; //X3_ORDEM
	'WSA_PARCEL', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Parcelas'	, ; //X3_TITULO
	'Cuotas'	, ; //X3_TITSPA
	'Installments', ; //X3_TITENG
	'Num. de Parcelas Negoc.', ; //X3_DESCRIC
	'Num. de Cuotas Negociadas', ; //X3_DESCSPA
	'Nr.of Negotiated Installm', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'27', ; //X3_ORDEM
	'WSA_COND'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cond. Pagto.', ; //X3_TITULO
	'Cond. Pago', ; //X3_TITSPA
	'Payment Term', ; //X3_TITENG
	'Condicao de Pagamento', ; //X3_DESCRIC
	'Condici¾n de Pago', ; //X3_DESCSPA
	'Payment Term', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'28', ; //X3_ORDEM
	'WSA_FORMA'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Forma Pagto.', ; //X3_TITULO
	'Forma Pago', ; //X3_TITSPA
	'Payment Mode', ; //X3_TITENG
	'Forma de Pagamento', ; //X3_DESCRIC
	'Forma de Pago', ; //X3_DESCSPA
	'Payment Mode', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'29', ; //X3_ORDEM
	'WSA_VALICM', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor de ICM', ; //X3_TITULO
	'Valor de ICM', ; //X3_TITSPA
	'ICM Value'	, ; //X3_TITENG
	'Valor de ICM', ; //X3_DESCRIC
	'Valor de ICM', ; //X3_DESCSPA
	'Value of ICM Tax', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'30', ; //X3_ORDEM
	'WSA_VALIPI', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor de IPI', ; //X3_TITULO
	'Valor de IPI', ; //X3_TITSPA
	'IPI Value'	, ; //X3_TITENG
	'Valor de IPI', ; //X3_DESCRIC
	'Valor de IPI', ; //X3_DESCSPA
	'Value of IPI Tax', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'31', ; //X3_ORDEM
	'WSA_VALISS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor do ISS', ; //X3_TITULO
	'Valor ISS'	, ; //X3_TITSPA
	'ISS Value'	, ; //X3_TITENG
	'Valor do ISS', ; //X3_DESCRIC
	'Valor ISS'	, ; //X3_DESCSPA
	'Value of ISS Tax', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'32', ; //X3_ORDEM
	'WSA_CONDPG', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cond Pgto'	, ; //X3_TITULO
	'Cond. Pago', ; //X3_TITSPA
	'Payment Term', ; //X3_TITENG
	'Codigo Condicao Pagamento', ; //X3_DESCRIC
	'Codigo Condicion de Pago', ; //X3_DESCSPA
	'Payment Term Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'33', ; //X3_ORDEM
	'WSA_FORMPG', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Form Pgto'	, ; //X3_TITULO
	'Forma Pago', ; //X3_TITSPA
	'Payment Mode', ; //X3_TITENG
	'Forma de Pagamento', ; //X3_DESCRIC
	'Forma de Pago', ; //X3_DESCSPA
	'Payment Mode', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'34', ; //X3_ORDEM
	'WSA_CREDIT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Credito'	, ; //X3_TITULO
	'Credito'	, ; //X3_TITSPA
	'Credit'	, ; //X3_TITENG
	'Valor do Credito no Orcam', ; //X3_DESCRIC
	'Valor Cred en el Presupue', ; //X3_DESCSPA
	'Value of Credit in Budget', ; //X3_DESCENG
	'@E 9,999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'35', ; //X3_ORDEM
	'WSA_EMISSA', ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dt.Emissao', ; //X3_TITULO
	'Fch Emision', ; //X3_TITSPA
	'Issue Date', ; //X3_TITENG
	'Data de Emissao Orcamento', ; //X3_DESCRIC
	'Fecha de Emisi¾n Presup.', ; //X3_DESCSPA
	'Budget Issuing Date', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'ddatabase'	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'36', ; //X3_ORDEM
	'WSA_VEND2'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vendedor 2', ; //X3_TITULO
	'Vendedor 2', ; //X3_TITSPA
	'Seller 2'	, ; //X3_TITENG
	'Codigo do Vendedor 2', ; //X3_DESCRIC
	'Codigo del Vendedor 2', ; //X3_DESCSPA
	'Seller Code 2', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA3', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'37', ; //X3_ORDEM
	'WSA_VEND3'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vendedor 3', ; //X3_TITULO
	'Vendedor 3', ; //X3_TITSPA
	'Seller 3'	, ; //X3_TITENG
	'Codigo do Vendedor 3', ; //X3_DESCRIC
	'Codigo del Vendedor 3', ; //X3_DESCSPA
	'Seller Code 3', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA3', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'38', ; //X3_ORDEM
	'WSA_MULTNO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Iden Mul NFs', ; //X3_TITULO
	'Ind Mul Fact', ; //X3_TITSPA
	'Id.Mul.Inv.', ; //X3_TITENG
	'Iden Mul Notas', ; //X3_DESCRIC
	'Ind. Multiples Facturas', ; //X3_DESCSPA
	'Ident. Mult. Invoices', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(144) + Chr(136) + Chr(132) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'018', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'39', ; //X3_ORDEM
	'WSA_NUMCFI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Cup Fis.', ; //X3_TITULO
	'Nro. Factura', ; //X3_TITSPA
	'Voucher No.', ; //X3_TITENG
	'Numero do Cupom Fiscal', ; //X3_DESCRIC
	'Numero de la Factura', ; //X3_DESCSPA
	'Voucher Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'018', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'40', ; //X3_ORDEM
	'WSA_FATOR'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	8	, ; //X3_DECIMAL
	'Fator Multip', ; //X3_TITULO
	'Factor Multi', ; //X3_TITSPA
	'Multipl.Fact', ; //X3_TITENG
	'Fator Multiplicador', ; //X3_DESCRIC
	'Factor Multiplicador', ; //X3_DESCSPA
	'Multiplying Factor', ; //X3_DESCENG
	'@E 99,99999999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'41', ; //X3_ORDEM
	'WSA_VENDTE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Venda Tef'	, ; //X3_TITULO
	'Venta TEF'	, ; //X3_TITSPA
	'TEF Sale'	, ; //X3_TITENG
	'Indica se foi venda Tef', ; //X3_DESCRIC
	'Muestra si fue Venta TEF', ; //X3_DESCSPA
	'Inform if Sale was TEF', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'42', ; //X3_ORDEM
	'WSA_DATATE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Data Tef'	, ; //X3_TITULO
	'Fecha TEF'	, ; //X3_TITSPA
	'TEF Date'	, ; //X3_TITENG
	'Indica a data da tran.Tef', ; //X3_DESCRIC
	'Indica Fecha de Trans.TEF', ; //X3_DESCSPA
	'Inform TEF transfer Date', ; //X3_DESCENG
	'9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'43', ; //X3_ORDEM
	'WSA_HORATE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora Tef'	, ; //X3_TITULO
	'Hora TEF'	, ; //X3_TITSPA
	'TEF Time'	, ; //X3_TITENG
	'Indica a hora da tran.Tef', ; //X3_DESCRIC
	'Indica Hora Transf. TEF', ; //X3_DESCSPA
	'Inform TEF transfer Time', ; //X3_DESCENG
	'99:99:99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'44', ; //X3_ORDEM
	'WSA_DOCTEF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Doc Tef'	, ; //X3_TITULO
	'Doc TEF'	, ; //X3_TITSPA
	'TEF Document', ; //X3_TITENG
	'Numero do Documento Tef', ; //X3_DESCRIC
	'Nro. del Documento TEF', ; //X3_DESCSPA
	'TEF Document Number', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'45', ; //X3_ORDEM
	'WSA_AUTORI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Autorizacao', ; //X3_TITULO
	'Autorizacion', ; //X3_TITSPA
	'Authorizat.', ; //X3_TITENG
	'Codigo Autorizacao Venda', ; //X3_DESCRIC
	'Codigo Autorizacion Venta', ; //X3_DESCSPA
	'Sale Authorization Code', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'46', ; //X3_ORDEM
	'WSA_DOCCAN', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Cancel.', ; //X3_TITULO
	'Nro. Anulac.', ; //X3_TITSPA
	'Canc.No.'	, ; //X3_TITENG
	'Numero de Cancelamento', ; //X3_DESCRIC
	'Numero de la Anulacion', ; //X3_DESCSPA
	'Cancellation Number', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'47', ; //X3_ORDEM
	'WSA_DATCAN', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Data Cancel.', ; //X3_TITULO
	'Fch Anulac.', ; //X3_TITSPA
	'Cancell.Date', ; //X3_TITENG
	'Data de Cancelamento', ; //X3_DESCRIC
	'Fecha de Anulaci¾n', ; //X3_DESCSPA
	'Cancellation Date', ; //X3_DESCENG
	'9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'48', ; //X3_ORDEM
	'WSA_HORCAN', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora Cancel.', ; //X3_TITULO
	'Hora Cancela', ; //X3_TITSPA
	'Cancell.Time', ; //X3_TITENG
	'Hora de Cancelamento', ; //X3_DESCRIC
	'Hora de Anulaci¾n', ; //X3_DESCSPA
	'Cancellation Time', ; //X3_DESCENG
	'99:99:99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'49', ; //X3_ORDEM
	'WSA_INSTIT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Instituicao', ; //X3_TITULO
	'Institucion', ; //X3_TITSPA
	'Institution', ; //X3_TITENG
	'Codigo da Instituicao', ; //X3_DESCRIC
	'Codigo de la Institucion', ; //X3_DESCSPA
	'Institution Code', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'50', ; //X3_ORDEM
	'WSA_NSUTEF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sequencia'	, ; //X3_TITULO
	'Secuencia'	, ; //X3_TITSPA
	'Sequence'	, ; //X3_TITENG
	'Numero Sequencial Trans.', ; //X3_DESCRIC
	'Numero Secuencial Trans.', ; //X3_DESCSPA
	'Transfer Sequent. Number', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'51', ; //X3_ORDEM
	'WSA_TIPCAR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Modalidade', ; //X3_TITULO
	'Modalidad'	, ; //X3_TITSPA
	'Modality'	, ; //X3_TITENG
	'Modalidade do cartao', ; //X3_DESCRIC
	'Modalidad de la Tarjeta', ; //X3_DESCSPA
	'Card Modality', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'52', ; //X3_ORDEM
	'WSA_VLRDEB', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr. Crt Deb', ; //X3_TITULO
	'Vlr.Tarj.Deb', ; //X3_TITSPA
	'Val.Deb.Card', ; //X3_TITENG
	'Vlr no Cartao de Debito', ; //X3_DESCRIC
	'Vlr en Tarjeta de Debito', ; //X3_DESCSPA
	'Value in Debit Card', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'53', ; //X3_ORDEM
	'WSA_TEFSTA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status TEF', ; //X3_TITULO
	'Estatus TEF', ; //X3_TITSPA
	'TEF Status', ; //X3_TITENG
	'Status da Venda TEF', ; //X3_DESCRIC
	'Estatus de la Venta TEF', ; //X3_DESCSPA
	'TEF Status Sale', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'54', ; //X3_ORDEM
	'WSA_ADMFIN', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Admin Financ', ; //X3_TITULO
	'Admin.Financ', ; //X3_TITSPA
	'Finan.Manag.', ; //X3_TITENG
	'Admin. Financeira', ; //X3_DESCRIC
	'Administradora Financiera', ; //X3_DESCSPA
	'Financial Management', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'55', ; //X3_ORDEM
	'WSA_STATUS', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status TEF', ; //X3_TITULO
	'Estatus TEF', ; //X3_TITSPA
	'TEF Status', ; //X3_TITENG
	'Status TEF', ; //X3_DESCRIC
	'Estatus TEF', ; //X3_DESCSPA
	'TEF Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'56', ; //X3_ORDEM
	'WSA_HORA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora', ; //X3_TITULO
	'Hora', ; //X3_TITSPA
	'Time', ; //X3_TITENG
	'Hora', ; //X3_DESCRIC
	'Hora', ; //X3_DESCSPA
	'Time', ; //X3_DESCENG
	'99:99:99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(134) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'57', ; //X3_ORDEM
	'WSA_NUMORI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Orc.Original', ; //X3_TITULO
	'Presup.Orig.', ; //X3_TITSPA
	'Orig.Budget', ; //X3_TITENG
	'Numero Orcamento Original', ; //X3_DESCRIC
	'Nro. Presupuesto Original', ; //X3_DESCSPA
	'Original Budget Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(129) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'58', ; //X3_ORDEM
	'WSA_SUBSER', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sub Serie'	, ; //X3_TITULO
	'Sub Serie'	, ; //X3_TITSPA
	'Sub Series', ; //X3_TITENG
	'Sub Serie'	, ; //X3_DESCRIC
	'Sub Serie'	, ; //X3_DESCSPA
	'Sub Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'094', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'59', ; //X3_ORDEM
	'WSA_TXMOED', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	11	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'Taxa moeda', ; //X3_TITULO
	'Tasa moneda', ; //X3_TITSPA
	'Currency Rt.', ; //X3_TITENG
	'Taxa da moeda', ; //X3_DESCRIC
	'Tasa de la moneda', ; //X3_DESCSPA
	'Currency Rate', ; //X3_DESCENG
	'@E 999999.9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'60', ; //X3_ORDEM
	'WSA_MOEDA'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Moeda', ; //X3_TITULO
	'Moneda'	, ; //X3_TITSPA
	'Currency'	, ; //X3_TITENG
	'Moeda da fatura', ; //X3_DESCRIC
	'Moneda de la factura', ; //X3_DESCSPA
	'Invoice Currency', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'61', ; //X3_ORDEM
	'WSA_ENDCOB', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End. Cobranc', ; //X3_TITULO
	'Dir.Cobranza', ; //X3_TITSPA
	'Collect.Add.', ; //X3_TITENG
	'Enderaco de Cobranca', ; //X3_DESCRIC
	'Direccion de Cobranza', ; //X3_DESCSPA
	'Collection Address', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'62', ; //X3_ORDEM
	'WSA_ENDENT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'End. Entrega', ; //X3_TITULO
	'Dir.Entrega', ; //X3_TITSPA
	'Deliv.Locat.', ; //X3_TITENG
	'Endereco de Entrega', ; //X3_DESCRIC
	'Direccion de Entrega', ; //X3_DESCSPA
	'Delivery Location', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'63', ; //X3_ORDEM
	'WSA_TPFRET', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo frete', ; //X3_TITULO
	'Tipo flete', ; //X3_TITSPA
	'Freight Type', ; //X3_TITENG
	'Tipo do frete do cliente', ; //X3_DESCRIC
	'Tipo de flete del cliente', ; //X3_DESCSPA
	'Customer´s Freight Type', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'C=CIF;F=FOB;S=Sem Frete', ; //X3_CBOX
	'C=CIF;F=FOB;S=Sinflete', ; //X3_CBOXSPA
	'C=CIF;F=FOB;S=No shipment', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'64', ; //X3_ORDEM
	'WSA_BAIRRC', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Bairro Cob', ; //X3_TITULO
	'Barrio Cobr.', ; //X3_TITSPA
	'Collect.Dist', ; //X3_TITENG
	'Bairro de Cobranca', ; //X3_DESCRIC
	'Barrio de Cobranza', ; //X3_DESCSPA
	'Collection District', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'65', ; //X3_ORDEM
	'WSA_CEPC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cep de Cobr', ; //X3_TITULO
	'CP de Cobr.', ; //X3_TITSPA
	'Collect.ZIP', ; //X3_TITENG
	'Cep de Cobranca', ; //X3_DESCRIC
	'CP de Cobranza', ; //X3_DESCSPA
	'Collect. ZIP Code', ; //X3_DESCENG
	'@R 99999-999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'66', ; //X3_ORDEM
	'WSA_MUNC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Mun. Cobr.', ; //X3_TITULO
	'Partido Cobr', ; //X3_TITSPA
	'Collect. Dis', ; //X3_TITENG
	'Municipio de Cobranca', ; //X3_DESCRIC
	'Partido de Cobranza', ; //X3_DESCSPA
	'Collection District', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'67', ; //X3_ORDEM
	'WSA_ESTC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'UF de Cobr.', ; //X3_TITULO
	'Estado Cobr.', ; //X3_TITSPA
	'Collect.St.', ; //X3_TITENG
	'UF de Cobranca', ; //X3_DESCRIC
	'Estado de Cobranza', ; //X3_DESCSPA
	'Collection State', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(160) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'010', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'68', ; //X3_ORDEM
	'WSA_BAIRRE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Bairro Entr.', ; //X3_TITULO
	'Barrio Entr.', ; //X3_TITSPA
	'Entry Distri', ; //X3_TITENG
	'Bairro de entrada', ; //X3_DESCRIC
	'Barrio de entrada', ; //X3_DESCSPA
	'Entry District', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'69', ; //X3_ORDEM
	'WSA_CEPE'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cep de Entr.', ; //X3_TITULO
	'CP de Entr.', ; //X3_TITSPA
	'Deliv.ZIP'	, ; //X3_TITENG
	'Cep de Entrega', ; //X3_DESCRIC
	'CP de Entrega', ; //X3_DESCSPA
	'Delivery Zip Code', ; //X3_DESCENG
	'@R 99999-999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'70', ; //X3_ORDEM
	'WSA_MUNE'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Mun. Entrega', ; //X3_TITULO
	'Part.Entrega', ; //X3_TITSPA
	'Deliv.Dist.', ; //X3_TITENG
	'Municipio da Entrega', ; //X3_DESCRIC
	'Partido de Entrega', ; //X3_DESCSPA
	'District of Delivery', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(160) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'71', ; //X3_ORDEM
	'WSA_ESTE'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'UF da Entreg', ; //X3_TITULO
	'Estado Entr.', ; //X3_TITSPA
	'Deliv.State', ; //X3_TITENG
	'UF da Entrega', ; //X3_DESCRIC
	'Estado de Entrega', ; //X3_DESCSPA
	'State of Delivery', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'010', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'72', ; //X3_ORDEM
	'WSA_FRETE'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr. Frete', ; //X3_TITULO
	'Vlr. Flete', ; //X3_TITSPA
	'Freight Vl.', ; //X3_TITENG
	'Valor do Frete', ; //X3_DESCRIC
	'Valor del Flete', ; //X3_DESCSPA
	'Freight Value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'73', ; //X3_ORDEM
	'WSA_SEGURO', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr. Seguro', ; //X3_TITULO
	'Vlr. Seguro', ; //X3_TITSPA
	'Insur.Value', ; //X3_TITENG
	'Valor do Seguro', ; //X3_DESCRIC
	'Valor del Seguro', ; //X3_DESCSPA
	'Insurance Value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'74', ; //X3_ORDEM
	'WSA_DESPES', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr. Desp/Ac', ; //X3_TITULO
	'Vlr.Gast/Acc', ; //X3_TITSPA
	'Exp./Acc.Vl.', ; //X3_TITENG
	'Valor de Despesas/Acessor', ; //X3_DESCRIC
	'Valor de Gastos/Accesor.', ; //X3_DESCSPA
	'Exp./Acc.Vl.', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'75', ; //X3_ORDEM
	'WSA_PLIQUI', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	3	, ; //X3_DECIMAL
	'Peso Liquido', ; //X3_TITULO
	'Peso Neto'	, ; //X3_TITSPA
	'Net Weight', ; //X3_TITENG
	'Peso Liquido', ; //X3_DESCRIC
	'Peso Neto'	, ; //X3_DESCSPA
	'Net Weight', ; //X3_DESCENG
	'@E 99,999.999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'76', ; //X3_ORDEM
	'WSA_PBRUTO', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	3	, ; //X3_DECIMAL
	'Peso Bruto', ; //X3_TITULO
	'Peso Bruto', ; //X3_TITSPA
	'Gross Weight', ; //X3_TITENG
	'Peso Bruto', ; //X3_DESCRIC
	'Peso Bruto', ; //X3_DESCSPA
	'Gross Weight', ; //X3_DESCENG
	'@E 99,999.999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'77', ; //X3_ORDEM
	'WSA_VOLUME', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	3	, ; //X3_DECIMAL
	'Volume'	, ; //X3_TITULO
	'Volumen'	, ; //X3_TITSPA
	'Volume'	, ; //X3_TITENG
	'Volume'	, ; //X3_DESCRIC
	'Volumen'	, ; //X3_DESCSPA
	'Volume'	, ; //X3_DESCENG
	'@E 99,999.999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'78', ; //X3_ORDEM
	'WSA_TRANSP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Transp.'	, ; //X3_TITULO
	'Transp.'	, ; //X3_TITSPA
	'Carrier Code', ; //X3_TITENG
	'Codigo da Transportadora', ; //X3_DESCRIC
	'Codigo de Transportadora', ; //X3_DESCSPA
	'Carrier Code', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA4', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'79', ; //X3_ORDEM
	'WSA_ESPECI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Especie'	, ; //X3_TITULO
	'Tipo', ; //X3_TITSPA
	'Type', ; //X3_TITENG
	'Especie'	, ; //X3_DESCRIC
	'Tipo', ; //X3_DESCSPA
	'Type', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'80', ; //X3_ORDEM
	'WSA_MARCA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Marca', ; //X3_TITULO
	'Marca', ; //X3_TITSPA
	'Trademark'	, ; //X3_TITENG
	'Marca', ; //X3_DESCRIC
	'Marca', ; //X3_DESCSPA
	'Trademark'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'81', ; //X3_ORDEM
	'WSA_NUMERO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Numero'	, ; //X3_TITULO
	'Numero'	, ; //X3_TITSPA
	'Number'	, ; //X3_TITENG
	'Numero'	, ; //X3_DESCRIC
	'Numero'	, ; //X3_DESCSPA
	'Number'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'82', ; //X3_ORDEM
	'WSA_PLACA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Placa', ; //X3_TITULO
	'Matricula'	, ; //X3_TITSPA
	'Plate', ; //X3_TITENG
	'Placa do veiculo', ; //X3_DESCRIC
	'Matricula del vehiculo', ; //X3_DESCSPA
	'Numberplate', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'83', ; //X3_ORDEM
	'WSA_UFPLAC', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Uf da Placa', ; //X3_TITULO
	'Prov.Matric.', ; //X3_TITSPA
	'Nmbplt.State', ; //X3_TITENG
	'Uf da placa do veiculo', ; //X3_DESCRIC
	'Prov.matricula vehiculo', ; //X3_DESCSPA
	'Numberplate State', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(132) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'010', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'84', ; //X3_ORDEM
	'WSA_RESERV', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tem Reservas', ; //X3_TITULO
	'Tiene.Reserv', ; //X3_TITSPA
	'Reservations', ; //X3_TITENG
	'Orcamento com reservas', ; //X3_DESCRIC
	'Presupuesto con reservas', ; //X3_DESCSPA
	'Budget with reservations', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'85', ; //X3_ORDEM
	'WSA_NRDOC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nr.Documento', ; //X3_TITULO
	'Nr.Documento', ; //X3_TITSPA
	'Doc.Numb.'	, ; //X3_TITENG
	'Numero do Documento', ; //X3_DESCRIC
	'Numero del Documento', ; //X3_DESCSPA
	'Document Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(146) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'86', ; //X3_ORDEM
	'WSA_EMPRES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Emp.Reserva', ; //X3_TITULO
	'Emp.Reserva', ; //X3_TITSPA
	'Reserv.Cpny', ; //X3_TITENG
	'Cod.da Empresa da Reserva', ; //X3_DESCRIC
	'Cod. Empresa de reserva', ; //X3_DESCSPA
	'Reserved Company Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'87', ; //X3_ORDEM
	'WSA_FILRES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Fil.Reserva', ; //X3_TITULO
	'Suc. Reserva', ; //X3_TITSPA
	'Reserv.Brch.', ; //X3_TITENG
	'Cod.da Filial da Reserva', ; //X3_DESCRIC
	'Cod. Suc. de la reserva', ; //X3_DESCSPA
	'Reserved Branch Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'88', ; //X3_ORDEM
	'WSA_ORCRES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Orc.Reserva', ; //X3_TITULO
	'Presup.Reser', ; //X3_TITSPA
	'Res.Budget', ; //X3_TITENG
	'Cod.da Orcamento da Res.', ; //X3_DESCRIC
	'Cod.Presupuesto reserva', ; //X3_DESCSPA
	'Reserved Budget Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'89', ; //X3_ORDEM
	'WSA_DOCPED', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nota Fiscal', ; //X3_TITULO
	'Factura'	, ; //X3_TITSPA
	'Invoice'	, ; //X3_TITENG
	'Numero da Nota Fiscal', ; //X3_DESCRIC
	'Numero de la Factura', ; //X3_DESCSPA
	'Invoice Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'018', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'90', ; //X3_ORDEM
	'WSA_CGCCAR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'N. CGC/Cart.', ; //X3_TITULO
	'N. CGC/Tarj.', ; //X3_TITSPA
	'N. CGC/Card', ; //X3_TITENG
	'Numero do CGC ou Cartäo', ; //X3_DESCRIC
	'Numero del CGC o Tarjeta', ; //X3_DESCSPA
	'CGC or card number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'91', ; //X3_ORDEM
	'WSA_SERPED', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Serie', ; //X3_TITULO
	'Serie', ; //X3_TITSPA
	'Series'	, ; //X3_TITENG
	'Serie da Nota Fiscal', ; //X3_DESCRIC
	'Serie de la Factura', ; //X3_DESCSPA
	'Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'094', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'92', ; //X3_ORDEM
	'WSA_BRICMS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Base ICM Sol', ; //X3_TITULO
	'Base ICM Sol', ; //X3_TITSPA
	'Mut.ICM Base', ; //X3_TITENG
	'Base ICMS Solidario', ; //X3_DESCRIC
	'Base ICMS Solidario', ; //X3_DESCSPA
	'Mutual ICMS Base', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'93', ; //X3_ORDEM
	'WSA_CLIENE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cli. Entrega', ; //X3_TITULO
	'Cli. Entrega', ; //X3_TITSPA
	'CustDelivers', ; //X3_TITENG
	'Cliente Entrega', ; //X3_DESCRIC
	'Cliente Entrega', ; //X3_DESCSPA
	'Customer delivers', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA1', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'001', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'94', ; //X3_ORDEM
	'WSA_LOJENT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Loj. Entrega', ; //X3_TITULO
	'Tien Entrega', ; //X3_TITSPA
	'UnitDelivers', ; //X3_TITENG
	'Loja Entrega', ; //X3_DESCRIC
	'Tienda Entrega', ; //X3_DESCSPA
	'Unit delivers', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'002', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'95', ; //X3_ORDEM
	'WSA_ICMSRE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'ICMS Retido', ; //X3_TITULO
	'ICMS Reteni', ; //X3_TITSPA
	'Withh. ICMS', ; //X3_TITENG
	'ICMS retido na fonte', ; //X3_DESCRIC
	'ICMS reten. en la fuente', ; //X3_DESCSPA
	'Withheld ICMS', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'96', ; //X3_ORDEM
	'WSA_ABTOPC', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vl.Abat.'	, ; //X3_TITULO
	'Vl.Abat.'	, ; //X3_TITSPA
	'Deduc.Value', ; //X3_TITENG
	'Vl.Abat.PIS/COFINS/CSLL', ; //X3_DESCRIC
	'Vl.Abat.PIS/COFINS/CSLL', ; //X3_DESCSPA
	'PIS/COFINS/CSLL Ded.Value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'97', ; //X3_ORDEM
	'WSA_PARCTE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Parcelas TEF', ; //X3_TITULO
	'Cuotas TEF', ; //X3_TITSPA
	'EFT Installm', ; //X3_TITENG
	'Parcelamento TEF', ; //X3_DESCRIC
	'Pago en cuotas TEF', ; //X3_DESCSPA
	'EFT Installment', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'N'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'98', ; //X3_ORDEM
	'WSA_VALPIS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val.PIS'	, ; //X3_TITULO
	'Val.PIS'	, ; //X3_TITSPA
	'PIS Value'	, ; //X3_TITENG
	'Valor de retencäo do PIS', ; //X3_DESCRIC
	'Valor de retencion PIS', ; //X3_DESCSPA
	'PIS withholding value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'99', ; //X3_ORDEM
	'WSA_VALCOF', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val.COFINS', ; //X3_TITULO
	'Val.COFINS', ; //X3_TITSPA
	'COFINS Value', ; //X3_TITENG
	'Valor de retencäo COFINS', ; //X3_DESCRIC
	'Valor de retencion COFINS', ; //X3_DESCSPA
	'COFINS withholding value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A0', ; //X3_ORDEM
	'WSA_VALCSL', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val.CSLL'	, ; //X3_TITULO
	'Val.CSLL'	, ; //X3_TITSPA
	'CSLL value', ; //X3_TITENG
	'Valor de retencäo CSLL', ; //X3_DESCRIC
	'Valor de retencion CSLL', ; //X3_DESCSPA
	'CSLL withholding value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A1', ; //X3_ORDEM
	'WSA_PEDRES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num. Pedido', ; //X3_TITULO
	'Num. Pedido', ; //X3_TITSPA
	'Order Number', ; //X3_TITENG
	'Num. Pedido de venda', ; //X3_DESCRIC
	'Num. Pedido de venta', ; //X3_DESCSPA
	'Sales Order Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A2', ; //X3_ORDEM
	'WSA_NOMCLI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome cliente', ; //X3_TITULO
	'Nombre clien', ; //X3_TITSPA
	'Cust.Name'	, ; //X3_TITENG
	'Nome do cliente', ; //X3_DESCRIC
	'Nombre del cliente', ; //X3_DESCSPA
	"Customer's Name", ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'Posicione("SA1",1,xFilial("SA1")+WSA->WSA_CLIENT+WSA->WSA_LOJA,"A1_NOME")'	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	'Posicione("SA1",1,xFilial("SA1")+WSA->WSA_CLIENT+WSA->WSA_LOJA,"A1_NOME")'	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A3', ; //X3_ORDEM
	'WSA_TABELA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tabela'	, ; //X3_TITULO
	'Tabla', ; //X3_TITSPA
	'List', ; //X3_TITENG
	'Tabela de preco', ; //X3_DESCRIC
	'Tabela de precio', ; //X3_DESCSPA
	'Price list', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A4', ; //X3_ORDEM
	'WSA_CGCCLI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'CGC', ; //X3_TITULO
	'RFC', ; //X3_TITSPA
	'CGC', ; //X3_TITENG
	'CGC/ CPF do Cliente', ; //X3_DESCRIC
	'RFC del Cliente', ; //X3_DESCSPA
	'Customer CGC/ CPF', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A5', ; //X3_ORDEM
	'WSA_TEFBAN', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Band.cartao', ; //X3_TITULO
	'Band.tarjeta', ; //X3_TITSPA
	'Card Flag'	, ; //X3_TITENG
	'Nome da bandeira TEF', ; //X3_DESCRIC
	'Nombre bandera TEF', ; //X3_DESCSPA
	'EFT Brand Name', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A6', ; //X3_ORDEM
	'WSA_VALIRR', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor IRRF', ; //X3_TITULO
	'Valor IRRF', ; //X3_TITSPA
	'Inc.Tax Vl.', ; //X3_TITENG
	'Valor do IRRF', ; //X3_DESCRIC
	'Valor del IRRF', ; //X3_DESCSPA
	'Income Tax Value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A7', ; //X3_ORDEM
	'WSA_ARRED'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	4	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Arredondamen', ; //X3_TITULO
	'Redondeo'	, ; //X3_TITSPA
	'Rounding'	, ; //X3_TITENG
	'Decimal arredondamento', ; //X3_DESCRIC
	'Decimal redondeo', ; //X3_DESCSPA
	'Decimal Rounding', ; //X3_DESCENG
	'@E 9.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A8', ; //X3_ORDEM
	'WSA_VEND1'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vendedor 1', ; //X3_TITULO
	'Vendedor 1', ; //X3_TITSPA
	'SalesRep. 1', ; //X3_TITENG
	'Código Vendedor 1', ; //X3_DESCRIC
	'Codigo vendedor 1', ; //X3_DESCSPA
	'Sales Represent. Code 1', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA3', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'A9', ; //X3_ORDEM
	'WSA_VEND4'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vendedor 4', ; //X3_TITULO
	'Vendedor 4', ; //X3_TITSPA
	'SalesRep. 4', ; //X3_TITENG
	'Código Vendedor 4', ; //X3_DESCRIC
	'Codigo vendedor 4', ; //X3_DESCSPA
	'Sales Represent. Code 4', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA3', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B0', ; //X3_ORDEM
	'WSA_VEND5'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vendedor 5', ; //X3_TITULO
	'Vendedor 5', ; //X3_TITSPA
	'SalesRep. 5', ; //X3_TITENG
	'Código do Vendedor 5', ; //X3_DESCRIC
	'Codigo vendedor 5', ; //X3_DESCSPA
	'Sales Represent. Code 5', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA3', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B1', ; //X3_ORDEM
	'WSA_PEDPRS', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ped Presente', ; //X3_TITULO
	'Ped Regalo', ; //X3_TITSPA
	'CurrentOrder', ; //X3_TITENG
	'Pedido Presente', ; //X3_DESCRIC
	'Pedido regalo', ; //X3_DESCSPA
	'Current Order', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B2', ; //X3_ORDEM
	'WSA_VALINS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor INSS', ; //X3_TITULO
	'Valor INSS', ; //X3_TITSPA
	'INSS Value', ; //X3_TITENG
	'Valor de retenção de INSS', ; //X3_DESCRIC
	'Valor retencion de INSS', ; //X3_DESCSPA
	'INSS Withholding Value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B3', ; //X3_ORDEM
	'WSA_VLRARR', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val. Doacao', ; //X3_TITULO
	'Val.Donacion', ; //X3_TITSPA
	'Donation Val', ; //X3_TITENG
	'Valor de Doacao', ; //X3_DESCRIC
	'Valor de donacion', ; //X3_DESCSPA
	'Donation Value', ; //X3_DESCENG
	'@E 999.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B4', ; //X3_ORDEM
	'WSA_SDOCRP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sér. NF Serv', ; //X3_TITULO
	'Ser Fac Serv', ; //X3_TITSPA
	'Serv.Inv.Ser', ; //X3_TITENG
	'Série da N.F. de Servico', ; //X3_DESCRIC
	'Serie de Fact. Servicio', ; //X3_DESCSPA
	'Service Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'095', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B5', ; //X3_ORDEM
	'WSA_SDOC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Série Doc.', ; //X3_TITULO
	'Serie Doc.', ; //X3_TITSPA
	'Inv. Series', ; //X3_TITENG
	'Série do Documento Fiscal', ; //X3_DESCRIC
	'Serie de Documento Fiscal', ; //X3_DESCSPA
	'Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'095', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B6', ; //X3_ORDEM
	'WSA_SDOCPE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Série Nota', ; //X3_TITULO
	'Serie Fact', ; //X3_TITSPA
	'Inv.Series', ; //X3_TITENG
	'Série da Nota Fiscal', ; //X3_DESCRIC
	'Serie de Factura', ; //X3_DESCSPA
	'Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'095', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B7', ; //X3_ORDEM
	'WSA_VLRJUR', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vl. Juros'	, ; //X3_TITULO
	'Val. Interes', ; //X3_TITSPA
	'Interest Vl', ; //X3_TITENG
	'Valor de juros', ; //X3_DESCRIC
	'Valor de intereses', ; //X3_DESCSPA
	'Interest Value', ; //X3_DESCENG
	'@E 9,999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B8', ; //X3_ORDEM
	'WSA_CELULA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Celular'	, ; //X3_TITULO
	'Celular'	, ; //X3_TITSPA
	'Celular'	, ; //X3_TITENG
	'Celular Destinatario', ; //X3_DESCRIC
	'Celular Destinatario', ; //X3_DESCSPA
	'Celular Destinatario', ; //X3_DESCENG
	'@R 99999-9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'B9', ; //X3_ORDEM
	'WSA_CODSTA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Status', ; //X3_TITULO
	'Cod. Status', ; //X3_TITSPA
	'Cod. Status', ; //X3_TITENG
	'Codigo Status', ; //X3_DESCRIC
	'Codigo Status', ; //X3_DESCSPA
	'Codigo Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C0', ; //X3_ORDEM
	'WSA_DDD01'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ddd Tel01'	, ; //X3_TITULO
	'Ddd Tel01'	, ; //X3_TITSPA
	'Ddd Tel01'	, ; //X3_TITENG
	'Ddd Telefone 01', ; //X3_DESCRIC
	'Ddd Telefone 01', ; //X3_DESCSPA
	'Ddd Telefone 01', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C1', ; //X3_ORDEM
	'WSA_DDDCEL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ddd Celular', ; //X3_TITULO
	'Ddd Celular', ; //X3_TITSPA
	'Ddd Celular', ; //X3_TITENG
	'Ddd Celular', ; //X3_DESCRIC
	'Ddd Celular', ; //X3_DESCSPA
	'Ddd Celular', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C2', ; //X3_ORDEM
	'WSA_DESTAT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Status', ; //X3_TITULO
	'Desc Status', ; //X3_TITSPA
	'Desc Status', ; //X3_TITENG
	'Descricao Status', ; //X3_DESCRIC
	'Descricao Status', ; //X3_DESCSPA
	'Descricao Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C3', ; //X3_ORDEM
	'WSA_MOVINT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Doc Interno', ; //X3_TITULO
	'Doc Interno', ; //X3_TITSPA
	'Doc Interno', ; //X3_TITENG
	'Documento Interno', ; //X3_DESCRIC
	'Documento Interno', ; //X3_DESCSPA
	'Documento Interno', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C4', ; //X3_ORDEM
	'WSA_MTCANC', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Motv. Cancel', ; //X3_TITULO
	'Motv. Cancel', ; //X3_TITSPA
	'Motv. Cancel', ; //X3_TITENG
	'Motivo do Cancelamento', ; //X3_DESCRIC
	'Motivo do Cancelamento', ; //X3_DESCSPA
	'Motivo do Cancelamento', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C5', ; //X3_ORDEM
	'WSA_NOMDES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	50	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome Destina', ; //X3_TITULO
	'Nome Destina', ; //X3_TITSPA
	'Nome Destina', ; //X3_TITENG
	'Nome Destinatario', ; //X3_DESCRIC
	'Nome Destinatario', ; //X3_DESCSPA
	'Nome Destinatario', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C6', ; //X3_ORDEM
	'WSA_NUMECL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv Cli', ; //X3_TITULO
	'Num Pv Cli', ; //X3_TITSPA
	'Num Pv Cli', ; //X3_TITENG
	'Num Pv Cliente eCommerce', ; //X3_DESCRIC
	'Num Pv Cliente eCommerce', ; //X3_DESCSPA
	'Num Pv Cliente eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C7', ; //X3_ORDEM
	'WSA_NUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Pv eCom', ; //X3_TITULO
	'Cod. Pv eCom', ; //X3_TITSPA
	'Cod. Pv eCom', ; //X3_TITENG
	'Cod. Pedido de Venda eCom', ; //X3_DESCRIC
	'Cod. Pedido de Venda eCom', ; //X3_DESCSPA
	'Cod. Pedido de Venda eCom', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C8', ; //X3_ORDEM
	'WSA_OBSECO', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Obs Pv eComm', ; //X3_TITULO
	'Obs Pv eComm', ; //X3_TITSPA
	'Obs Pv eComm', ; //X3_TITENG
	'Observacao Pedido eComm', ; //X3_DESCRIC
	'Observacao Pedido eComm', ; //X3_DESCSPA
	'Observacao Pedido eComm', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'C9', ; //X3_ORDEM
	'WSA_TEL01'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Telefone'	, ; //X3_TITULO
	'Telefone'	, ; //X3_TITSPA
	'Telefone'	, ; //X3_TITENG
	'Telefone'	, ; //X3_DESCRIC
	'Telefone'	, ; //X3_DESCSPA
	'Telefone'	, ; //X3_DESCENG
	'@R 99999-9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D0', ; //X3_ORDEM
	'WSA_TRACKI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod Rastreio', ; //X3_TITULO
	'Cod Rastreio', ; //X3_TITSPA
	'Cod Rastreio', ; //X3_TITENG
	'Codigo de Rastreio', ; //X3_DESCRIC
	'Codigo de Rastreio', ; //X3_DESCSPA
	'Codigo de Rastreio', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D1', ; //X3_ORDEM
	'WSA_VLBXPV', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Bx Ped eComm', ; //X3_TITULO
	'Bx Ped eComm', ; //X3_TITSPA
	'Bx Ped eComm', ; //X3_TITENG
	'Baixa do Pedido eCommerce', ; //X3_DESCRIC
	'Baixa do Pedido eCommerce', ; //X3_DESCSPA
	'Baixa do Pedido eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Validado;2=Validado', ; //X3_CBOX
	'1=Nao Validado;2=Validado', ; //X3_CBOXSPA
	'1=Nao Validado;2=Validado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D2', ; //X3_ORDEM
	'WSA_COMPLE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Compl. End', ; //X3_TITULO
	'Compl. End', ; //X3_TITSPA
	'Compl. End', ; //X3_TITENG
	'Complemento Endereco', ; //X3_DESCRIC
	'Complemento Endereco', ; //X3_DESCSPA
	'Complemento Endereco', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D3', ; //X3_ORDEM
	'WSA_ENDNUM', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num. End'	, ; //X3_TITULO
	'Num. End'	, ; //X3_TITSPA
	'Num. End'	, ; //X3_TITENG
	'Num. Endereco Entrega', ; //X3_DESCRIC
	'Num. Endereco Entrega', ; //X3_DESCSPA
	'Num. Endereco Entrega', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D4', ; //X3_ORDEM
	'WSA_REFEN'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	100	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ref. End'	, ; //X3_TITULO
	'Ref. End'	, ; //X3_TITSPA
	'Ref. End'	, ; //X3_TITENG
	'Referencia Endereco', ; //X3_DESCRIC
	'Referencia Endereco', ; //X3_DESCSPA
	'Referencia Endereco', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D6', ; //X3_ORDEM
	'WSA_IDENDE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Id End. Entr', ; //X3_TITULO
	'Id End. Entr', ; //X3_TITSPA
	'Id End. Entr', ; //X3_TITENG
	'Id Endereco Entregra', ; //X3_DESCRIC
	'Id Endereco Entregra', ; //X3_DESCSPA
	'Id Endereco Entregra', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D7', ; //X3_ORDEM
	'WSA_NUMSL1', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num SL1'	, ; //X3_TITULO
	'Num SL1'	, ; //X3_TITSPA
	'Num SL1'	, ; //X3_TITENG
	'Num SL1'	, ; //X3_DESCRIC
	'Num SL1'	, ; //X3_DESCSPA
	'Num SL1'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D8', ; //X3_ORDEM
	'WSA_NUMSC5', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Ped Vend', ; //X3_TITULO
	'Num Ped Vend', ; //X3_TITSPA
	'Num Ped Vend', ; //X3_TITENG
	'Numero Pedido de Venda', ; //X3_DESCRIC
	'Numero Pedido de Venda', ; //X3_DESCSPA
	'Numero Pedido de Venda', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192)		, ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSA', ; //X3_ARQUIVO
	'D9', ; //X3_ORDEM
	'WSA_ENVLOG'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Logistica', ; //X3_TITULO
	'Logistica', ; //X3_TITSPA
	'Logistica', ; //X3_TITENG
	'Logistica', ; //X3_DESCRIC
	'Logistica', ; //X3_DESCSPA
	'Logistica', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Pedido em separação;2=Danfe Enviado', ; //X3_CBOX
	'1=Pedido em separação;2=Danfe Enviado', ; //X3_CBOXSPA
	'1=Pedido em separação;2=Danfe Enviado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WSB
//
aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WSB_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WSB_NUM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'No Orcamento', ; //X3_TITULO
	'Nro. Presup.', ; //X3_TITSPA
	'Budget No.', ; //X3_TITENG
	'Numero do Orcamento', ; //X3_DESCRIC
	'Numero del Presupuesto', ; //X3_DESCSPA
	'Budget Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WSB_ITEM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nº Item'	, ; //X3_TITULO
	'Nº Item'	, ; //X3_TITSPA
	'Item Nr'	, ; //X3_TITENG
	'Numero do Item', ; //X3_DESCRIC
	'Numero del Item', ; //X3_DESCSPA
	'Item Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WSB_PRODUT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Produto'	, ; //X3_TITULO
	'Producto'	, ; //X3_TITSPA
	'Product'	, ; //X3_TITENG
	'Codigo do Produto', ; //X3_DESCRIC
	'Codigo del Producto', ; //X3_DESCSPA
	'Code of Product', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SL2', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'030', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WSB_DESCRI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Descricao'	, ; //X3_TITULO
	'Descripcion', ; //X3_TITSPA
	'Description', ; //X3_TITENG
	'Descricao do Produto', ; //X3_DESCRIC
	'Descripci¾n del Producto', ; //X3_DESCSPA
	'Description of Product', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'WSB_QUANT'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	7	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Quantidade', ; //X3_TITULO
	'Cantidad'	, ; //X3_TITSPA
	'Quantity'	, ; //X3_TITENG
	'Quantidade Vendida', ; //X3_DESCRIC
	'Cantidad Vendida', ; //X3_DESCSPA
	'Quantity Sold', ; //X3_DESCENG
	'@E 9,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(152) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'07', ; //X3_ORDEM
	'WSB_VRUNIT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	4	, ; //X3_DECIMAL
	'Preco Unit.', ; //X3_TITULO
	'Prc Unitario', ; //X3_TITSPA
	'Unit Price', ; //X3_TITENG
	'Preco Unitario', ; //X3_DESCRIC
	'Precio Unitario', ; //X3_DESCSPA
	'Unit Price', ; //X3_DESCENG
	'@E 99,999,999,999.9999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(158) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'WSB_VLRITE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Item'	, ; //X3_TITULO
	'Vlr. Item'	, ; //X3_TITSPA
	'Item Value', ; //X3_TITENG
	'Valor do Item', ; //X3_DESCRIC
	'Valor Item', ; //X3_DESCSPA
	'Item Value', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'09', ; //X3_ORDEM
	'WSB_LOCAL'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Armazem'	, ; //X3_TITULO
	'Deposito'	, ; //X3_TITSPA
	'Warehouse'	, ; //X3_TITENG
	'Armazem do Produto', ; //X3_DESCRIC
	'Deposito del Producto', ; //X3_DESCSPA
	'Product Warehouse', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'NNR', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(250) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'024', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'10', ; //X3_ORDEM
	'WSB_UM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Unidade'	, ; //X3_TITULO
	'Unidad'	, ; //X3_TITSPA
	'Measure Unit', ; //X3_TITENG
	'Unidade de Medida', ; //X3_DESCRIC
	'Unidad de Medida', ; //X3_DESCSPA
	'Unit of Meausre', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SAH', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'122', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'11', ; //X3_ORDEM
	'WSB_DESC'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Desconto'	, ; //X3_TITULO
	'Descuento'	, ; //X3_TITSPA
	'Discount'	, ; //X3_TITENG
	'Desconto do Item', ; //X3_DESCRIC
	'Descuento del Item', ; //X3_DESCSPA
	'Item Discount', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(156) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'12', ; //X3_ORDEM
	'WSB_VALDES', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor Desc', ; //X3_TITULO
	'Valor Dsct.', ; //X3_TITSPA
	'Discount'	, ; //X3_TITENG
	'Valor do Desconto', ; //X3_DESCRIC
	'Valor del Descuento', ; //X3_DESCSPA
	'Discount Value', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(156) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'13', ; //X3_ORDEM
	'WSB_TES'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo E/S'	, ; //X3_TITULO
	'Tipo E/S'	, ; //X3_TITSPA
	'Inf./Out.Tp.', ; //X3_TITENG
	'Tipo Entrada e Saida', ; //X3_DESCRIC
	'Tipo de Entrada y Salida', ; //X3_DESCSPA
	'Type of Inflow/Outflow', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SF4', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	'S'	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'14', ; //X3_ORDEM
	'WSB_CF'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Fiscal', ; //X3_TITULO
	'Cod. Fiscal', ; //X3_TITSPA
	'Fiscal Code', ; //X3_TITENG
	'Codigo Fiscal da Operacao', ; //X3_DESCRIC
	'Codigo Fiscal Operacion', ; //X3_DESCSPA
	'Operation Fiscal Code', ; //X3_DESCENG
	'@9', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'13', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'15', ; //X3_ORDEM
	'WSB_DOC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nota NF'	, ; //X3_TITULO
	'Num. Factura', ; //X3_TITSPA
	'Invoice'	, ; //X3_TITENG
	'Numero da Nota Fiscal', ; //X3_DESCRIC
	'Numero de la Factura', ; //X3_DESCSPA
	'Invoice Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'018', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'16', ; //X3_ORDEM
	'WSB_SERIE'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Serie NF'	, ; //X3_TITULO
	'Serie Fact.', ; //X3_TITSPA
	'Inv.Series', ; //X3_TITENG
	'Serie da Nota Fiscal', ; //X3_DESCRIC
	'Serie de la Factura', ; //X3_DESCSPA
	'Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'094', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'17', ; //X3_ORDEM
	'WSB_VALIPI', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor do IPI', ; //X3_TITULO
	'Valor de IPI', ; //X3_TITSPA
	'IPI Value'	, ; //X3_TITENG
	'Valor de IPI', ; //X3_DESCRIC
	'Valor de IPI', ; //X3_DESCSPA
	'IPI Value'	, ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'18', ; //X3_ORDEM
	'WSB_VALICM', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor de ICM', ; //X3_TITULO
	'Valor de ICM', ; //X3_TITSPA
	'ICM Value'	, ; //X3_TITENG
	'Valor de ICM', ; //X3_DESCRIC
	'Valor de ICM', ; //X3_DESCSPA
	'ICMS Value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'19', ; //X3_ORDEM
	'WSB_VALISS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor do ISS', ; //X3_TITULO
	'Valor de ISS', ; //X3_TITSPA
	'ISS Value'	, ; //X3_TITENG
	'Valor do ISS', ; //X3_DESCRIC
	'Valor del ISS', ; //X3_DESCSPA
	'ISS Value'	, ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'20', ; //X3_ORDEM
	'WSB_BASEIC', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Base ICMS'	, ; //X3_TITULO
	'Base ICMS'	, ; //X3_TITSPA
	'ICMS Basis', ; //X3_TITENG
	'Base do ICMS', ; //X3_DESCRIC
	'Base del ICMS', ; //X3_DESCSPA
	'ICMS Basis', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'21', ; //X3_ORDEM
	'WSB_TABELA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tabela Preco', ; //X3_TITULO
	'Lista Precio', ; //X3_TITSPA
	'List Price', ; //X3_TITENG
	'Tabela de Preco', ; //X3_DESCRIC
	'Tabla de Precio', ; //X3_DESCSPA
	'List Price', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'22', ; //X3_ORDEM
	'WSB_STATUS', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status Troca', ; //X3_TITULO
	'Estatus Camb', ; //X3_TITSPA
	'Exchange Sta', ; //X3_TITENG
	'Status Troca Mercadoria', ; //X3_DESCRIC
	'Estatus de Cambio de Merc', ; //X3_DESCSPA
	'Product Exchange Status', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'23', ; //X3_ORDEM
	'WSB_EMISSA', ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dt Emissao', ; //X3_TITULO
	'Fch Emision', ; //X3_TITSPA
	'Issue Date', ; //X3_TITENG
	'Data Emissao da Venda', ; //X3_DESCRIC
	'Fecha Emisi¾n de Venta', ; //X3_DESCSPA
	'Sale Issue Date', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'24', ; //X3_ORDEM
	'WSB_PRCTAB', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Preco Tabela', ; //X3_TITULO
	'Precio Tabla', ; //X3_TITSPA
	'List Price', ; //X3_TITENG
	'Preco de Tabela do Produt', ; //X3_DESCRIC
	'Precio de Lista Producto', ; //X3_DESCSPA
	'Product List Price', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(156) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'25', ; //X3_ORDEM
	'WSB_GRADE'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Grade', ; //X3_TITULO
	'Cuadricula', ; //X3_TITSPA
	'Grid', ; //X3_TITENG
	'Grade de Produto', ; //X3_DESCRIC
	'Cuadricula de Producto', ; //X3_DESCSPA
	'Product Grids', ; //X3_DESCENG
	'!'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'N'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'26', ; //X3_ORDEM
	'WSB_VEND'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vendedor'	, ; //X3_TITULO
	'Vendedor'	, ; //X3_TITSPA
	'Sales Repr.', ; //X3_TITENG
	'Vendedor do Item', ; //X3_DESCRIC
	'Vendedor del Item', ; //X3_DESCSPA
	'Item Seller', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(130) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SA3', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(144) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'27', ; //X3_ORDEM
	'WSB_LOTECT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Lote', ; //X3_TITULO
	'Lote', ; //X3_TITSPA
	'Lot', ; //X3_TITENG
	'Lote do Produto', ; //X3_DESCRIC
	'Lote del Producto', ; //X3_DESCSPA
	'Product Lot', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SB8', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'068', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'28', ; //X3_ORDEM
	'WSB_NLOTE'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sub Lote'	, ; //X3_TITULO
	'Sublote'	, ; //X3_TITSPA
	'Sublot'	, ; //X3_TITENG
	'Sub Lote do Produto', ; //X3_DESCRIC
	'Sublote de Producto', ; //X3_DESCSPA
	'Product Sublot', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'29', ; //X3_ORDEM
	'WSB_LOCALI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Endereco'	, ; //X3_TITULO
	'Direccion'	, ; //X3_TITSPA
	'Address'	, ; //X3_TITENG
	'Endereco do Lote', ; //X3_DESCRIC
	'Direccion del Lote', ; //X3_DESCSPA
	'Lot Address', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SBE', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'30', ; //X3_ORDEM
	'WSB_NSERIE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Numero Serie', ; //X3_TITULO
	'Numero Serie', ; //X3_TITSPA
	'Serial No.', ; //X3_TITENG
	'Nº de serie do produto', ; //X3_DESCRIC
	'Nro. de serie de producto', ; //X3_DESCSPA
	'Product Serial Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'BF1', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'31', ; //X3_ORDEM
	'WSB_BCONTA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	44	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod.Barras', ; //X3_TITULO
	'Cod.Barras', ; //X3_TITSPA
	'Bar Code'	, ; //X3_TITENG
	'Codigo de Barras da Conta', ; //X3_DESCRIC
	'Cod. de Barras de Cuenta', ; //X3_DESCSPA
	'Account Bar Code', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'32', ; //X3_ORDEM
	'WSB_RESERV', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num.Reserva', ; //X3_TITULO
	'Nro. Reserva', ; //X3_TITSPA
	'Reserv.No.', ; //X3_TITENG
	'Numero da Reserva', ; //X3_DESCRIC
	'Numero de la Reserva', ; //X3_DESCSPA
	'Reserve Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(140) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SC0', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'33', ; //X3_ORDEM
	'WSB_LOJARE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Loja Reserv.', ; //X3_TITULO
	'Tienda Reser', ; //X3_TITSPA
	'Reserv.Unit', ; //X3_TITENG
	'Loja onde esta a reserva', ; //X3_DESCRIC
	'Tienda donde esta reserva', ; //X3_DESCSPA
	'Reserv.Unit', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(140) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'34', ; //X3_ORDEM
	'WSB_PEDFAT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num.Pedido', ; //X3_TITULO
	'Nro. Pedido', ; //X3_TITSPA
	'Order No.'	, ; //X3_TITENG
	'Num.do pedido da outra Lj', ; //X3_DESCRIC
	'Nro.pedido de otra Tienda', ; //X3_DESCSPA
	'Other Unit Order Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'35', ; //X3_ORDEM
	'WSB_VALFRE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor Frete', ; //X3_TITULO
	'Valor Flete', ; //X3_TITSPA
	'Freight Val.', ; //X3_TITENG
	'Valor do Frete', ; //X3_DESCRIC
	'Valor del Flete', ; //X3_DESCSPA
	'Freight value', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'36', ; //X3_ORDEM
	'WSB_SEGURO', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Seguro', ; //X3_TITULO
	'Vlr.Seguro', ; //X3_TITSPA
	'Ins. Value', ; //X3_TITENG
	'Valor do Seguro', ; //X3_DESCRIC
	'Valor del Seguro', ; //X3_DESCSPA
	'Insurance Value', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'37', ; //X3_ORDEM
	'WSB_DESPES', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Vlr.Desp.Ac.', ; //X3_TITULO
	'Vlr.Gsto.Com', ; //X3_TITSPA
	'Add.Exp.Vl.', ; //X3_TITENG
	'Valor Despesas Acessorias', ; //X3_DESCRIC
	'Valor Gastos Complement.', ; //X3_DESCSPA
	'Additional Expens. Value', ; //X3_DESCENG
	'@E 999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(164) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'38', ; //X3_ORDEM
	'WSB_EMPRES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Emp.Reserva', ; //X3_TITULO
	'Emp.Reserva', ; //X3_TITSPA
	'Reserv.Cpny.', ; //X3_TITENG
	'Cod.da Empresa da Reserva', ; //X3_DESCRIC
	'Cod. empresa de reserva', ; //X3_DESCSPA
	'Reserved Company Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'39', ; //X3_ORDEM
	'WSB_FILRES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Fil.Reserva', ; //X3_TITULO
	'Sucur.Reser.', ; //X3_TITSPA
	'Reserv.Brch.', ; //X3_TITENG
	'Cod.da Filial da Reserva', ; //X3_DESCRIC
	'Cod.Sucur. de la Reserva', ; //X3_DESCSPA
	'Reserved Branch Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'40', ; //X3_ORDEM
	'WSB_ORCRES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Orc.Reserva', ; //X3_TITULO
	'Presup.Reser', ; //X3_TITSPA
	'Res.Budget', ; //X3_TITENG
	'Cod.da Orcamento da Res.', ; //X3_DESCRIC
	'Cod. Presup. de Reserva', ; //X3_DESCSPA
	'Reserved Budget Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'41', ; //X3_ORDEM
	'WSB_ICMSRE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'ICMS Retido', ; //X3_TITULO
	'ICMS Retenid', ; //X3_TITSPA
	'Withh. ICMS', ; //X3_TITENG
	'ICMS retido na fonte', ; //X3_DESCRIC
	'ICMS retenido en fuente', ; //X3_DESCSPA
	'Withheld ICMS', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'42', ; //X3_ORDEM
	'WSB_BRICMS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Ret. ICMS'	, ; //X3_TITULO
	'Ret. ICMS'	, ; //X3_TITSPA
	'Withh. ICMS', ; //X3_TITENG
	'Base de Retenção ICMS', ; //X3_DESCRIC
	'Base de Retencion ICMS', ; //X3_DESCSPA
	'ICMS Withholding Basis', ; //X3_DESCENG
	'@E 999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'43', ; //X3_ORDEM
	'WSB_VALPIS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val.PIS'	, ; //X3_TITULO
	'Val.PIS'	, ; //X3_TITSPA
	'PIS Value'	, ; //X3_TITENG
	'Valor de retencäo do PIS', ; //X3_DESCRIC
	'Valor de retencion PIS', ; //X3_DESCSPA
	'PIS withholding value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'44', ; //X3_ORDEM
	'WSB_VALCOF', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val.COFINS', ; //X3_TITULO
	'Val.COFINS', ; //X3_TITSPA
	'COFINS value', ; //X3_TITENG
	'Valor de retencäo COFINS', ; //X3_DESCRIC
	'Valor de retencion COFINS', ; //X3_DESCSPA
	'COFINS withholding value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'45', ; //X3_ORDEM
	'WSB_VALCSL', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val.CSLL'	, ; //X3_TITULO
	'Val.CSLL'	, ; //X3_TITSPA
	'CSLL value', ; //X3_TITENG
	'Valor de retencäo do CSLL', ; //X3_DESCRIC
	'Valor de retencion CSLL', ; //X3_DESCSPA
	'CSLL withholding value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'46', ; //X3_ORDEM
	'WSB_VALPS2', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val.PIS'	, ; //X3_TITULO
	'Val.PIS'	, ; //X3_TITSPA
	'PIS Value'	, ; //X3_TITENG
	'Valor de apuracäo PIS', ; //X3_DESCRIC
	'Valor de determinac. PIS', ; //X3_DESCSPA
	'PIS calculation value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'47', ; //X3_ORDEM
	'WSB_VALCF2', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Val.COFINS', ; //X3_TITULO
	'Val.COFINS', ; //X3_TITSPA
	'COFINS value', ; //X3_TITENG
	'Valor de apuracäo COFINS', ; //X3_DESCRIC
	'Valor de determ. COFINS', ; //X3_DESCSPA
	'COFINS calculation value', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'48', ; //X3_ORDEM
	'WSB_BASEPS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Base do PIS', ; //X3_TITULO
	'Base del PIS', ; //X3_TITSPA
	'PIS Base'	, ; //X3_TITENG
	'Base de apuracäo do PIS', ; //X3_DESCRIC
	'Base de determinacion PIS', ; //X3_DESCSPA
	'PIS calculation base', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'49', ; //X3_ORDEM
	'WSB_BASECF', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Base COFINS', ; //X3_TITULO
	'Base COFINS', ; //X3_TITSPA
	'COFINS Base', ; //X3_TITENG
	'Base de apuracäo COFINS', ; //X3_DESCRIC
	'Base de determin. COFINS', ; //X3_DESCSPA
	'COFINS calculation base', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'50', ; //X3_ORDEM
	'WSB_ALIQPS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq.PIS'	, ; //X3_TITULO
	'Alic.PIS'	, ; //X3_TITSPA
	'PIS Rate'	, ; //X3_TITENG
	'Aliquota de apuracäo PIS', ; //X3_DESCRIC
	'Alicuota de determin. PIS', ; //X3_DESCSPA
	'PIS calculation rate', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'51', ; //X3_ORDEM
	'WSB_ALIQCF', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq.COFINS', ; //X3_TITULO
	'Alic.COFINS', ; //X3_TITSPA
	'COFINS Rate', ; //X3_TITENG
	'Aliquota apuracäo COFINS', ; //X3_DESCRIC
	'Alicuota determin. COFINS', ; //X3_DESCSPA
	'COFINS calculation rate', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'52', ; //X3_ORDEM
	'WSB_DTVALI', ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Valid. Lote', ; //X3_TITULO
	'Valid. Lote', ; //X3_TITSPA
	'Lot Validity', ; //X3_TITENG
	'Validade do Lote Inform.', ; //X3_DESCRIC
	'Validez del Lote Inform.', ; //X3_DESCSPA
	'Validity of lot entered', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'53', ; //X3_ORDEM
	'WSB_SEGUM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Segunda UM', ; //X3_TITULO
	'Segunda UM', ; //X3_TITSPA
	'Second UM'	, ; //X3_TITENG
	'Segunda unidade de medida', ; //X3_DESCRIC
	'Segunda unidad de medida', ; //X3_DESCSPA
	'2nd unit of measurement', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'SAH', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'122', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'54', ; //X3_ORDEM
	'WSB_PEDRES', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num. Pedido', ; //X3_TITULO
	'Num. Pedido', ; //X3_TITSPA
	'Order Number', ; //X3_TITENG
	'Num. Pedido de venda', ; //X3_DESCRIC
	'Num. Pedido de venta', ; //X3_DESCSPA
	'Sales Order Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'55', ; //X3_ORDEM
	'WSB_FDTENT', ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Data Entrega', ; //X3_TITULO
	'Fecha Entreg', ; //X3_TITSPA
	'Del. Date'	, ; //X3_TITENG
	'Data Entrega', ; //X3_DESCRIC
	'Fecha Entrega', ; //X3_DESCSPA
	'Delivery Date', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'56', ; //X3_ORDEM
	'WSB_CODCON', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Contato'	, ; //X3_TITULO
	'Contacto'	, ; //X3_TITSPA
	'Contact'	, ; //X3_TITENG
	'Contato do Cliente', ; //X3_DESCRIC
	'Contacto del Cliente', ; //X3_DESCSPA
	'Customer Contact', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'57', ; //X3_ORDEM
	'WSB_FDTMON', ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dt. Montagem', ; //X3_TITULO
	'Fc. Montagje', ; //X3_TITSPA
	'Assemb. Dt.', ; //X3_TITENG
	'Data de montagem', ; //X3_DESCRIC
	'Fecha de montaje', ; //X3_DESCSPA
	'Assembly Date', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'58', ; //X3_ORDEM
	'WSB_NUMORI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Orc.Original', ; //X3_TITULO
	'Pres.Orig.', ; //X3_TITSPA
	'Orig.Quotat.', ; //X3_TITENG
	'Numero Orcamento Original', ; //X3_DESCRIC
	'Numero Presupuesto Orig.', ; //X3_DESCSPA
	'Orig.Quotat.Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'59', ; //X3_ORDEM
	'WSB_VALEPR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vale Present', ; //X3_TITULO
	'Ticket Regal', ; //X3_TITSPA
	'Gift Cert.', ; //X3_TITENG
	'Código do Vale-Presente', ; //X3_DESCRIC
	'Codigo de Ticket Regalo', ; //X3_DESCSPA
	'Gift Certific.Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	'MDD', ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'60', ; //X3_ORDEM
	'WSB_PEDSC5', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nr. Ped.Vend', ; //X3_TITULO
	'Nr. Ped.Vent', ; //X3_TITSPA
	'Sales Ord Nr', ; //X3_TITENG
	'Ped.Venda (SC5)', ; //X3_DESCRIC
	'Ped.Venta (SC5)', ; //X3_DESCSPA
	'Sales Order (SC5)', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'N'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'61', ; //X3_ORDEM
	'WSB_ITESC6', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Item Pedido', ; //X3_TITULO
	'Item Pedido', ; //X3_TITSPA
	'Order Item', ; //X3_TITENG
	'Item Pedido Fat', ; //X3_DESCRIC
	'Item Pedido Fact', ; //X3_DESCSPA
	'Inv. Order Item', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'N'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'62', ; //X3_ORDEM
	'WSB_GARANT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Garantia'	, ; //X3_TITULO
	'Garantia'	, ; //X3_TITSPA
	'Warranty'	, ; //X3_TITENG
	'Garantia Estendida', ; //X3_DESCRIC
	'Garantia Extendida', ; //X3_DESCSPA
	'Extended Warranty', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'030', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'N'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'63', ; //X3_ORDEM
	'WSB_CODLPR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Lista Pres.', ; //X3_TITULO
	'Lista Reg.', ; //X3_TITSPA
	'Roll Call'	, ; //X3_TITENG
	'Lista de Presentes', ; //X3_DESCRIC
	'Lista de Regalos', ; //X3_DESCSPA
	'Roll Call'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'64', ; //X3_ORDEM
	'WSB_ITLPRE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Item L.Pres.', ; //X3_TITULO
	'Item L.Reg.', ; //X3_TITSPA
	'Gift List It', ; //X3_TITENG
	'Item da Lista de Presente', ; //X3_DESCRIC
	'Item Lista de Regalo', ; //X3_DESCSPA
	'Gift List Item', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'65', ; //X3_ORDEM
	'WSB_MSMLPR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Msg'	, ; //X3_TITULO
	'Cod. Msj'	, ; //X3_TITSPA
	'Msg.Code'	, ; //X3_TITENG
	'Mensagem presente', ; //X3_DESCRIC
	'Mensaje regalo', ; //X3_DESCSPA
	'Roll Call Message', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'66', ; //X3_ORDEM
	'WSB_MSGLPR', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	250	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Mensagem'	, ; //X3_TITULO
	'Mensaje'	, ; //X3_TITSPA
	'Message'	, ; //X3_TITENG
	'Mensagem presente(Memo)', ; //X3_DESCRIC
	'Mensaje regalo (Memo)', ; //X3_DESCSPA
	'Gift Message (Memo)', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIf(SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. !(FunName () $ "LOJA720|FATA720") .AND. !INCLUI,Lj843RtSYP(SL2->L2_MSMLPRE),"")', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'67', ; //X3_ORDEM
	'WSB_REMLPR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod.Remet.', ; //X3_TITULO
	'Cod.Remit.', ; //X3_TITSPA
	'Sender Code', ; //X3_TITENG
	'Cod.Remetente Mensagem', ; //X3_DESCRIC
	'Cod.Remitente Mensaje', ; //X3_DESCSPA
	'Message Sender Code', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'68', ; //X3_ORDEM
	'WSB_REVLPR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Remetente'	, ; //X3_TITULO
	'Remitente'	, ; //X3_TITSPA
	'Sender'	, ; //X3_TITENG
	'Remetente da Mensagem', ; //X3_DESCRIC
	'Remitente del Mensaje', ; //X3_DESCSPA
	'Message Sender', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIf(SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. !(FunName () $ "LOJA720|FATA720") .AND. !INCLUI,Lj843RtSYP(SL2->L2_REMLPRE),"")', ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	'V'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'69', ; //X3_ORDEM
	'WSB_CODBAR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod Barras', ; //X3_TITULO
	'Cod. Barras', ; //X3_TITSPA
	'Bar Code'	, ; //X3_TITENG
	'Código de Barras', ; //X3_DESCRIC
	'Codigo de barras', ; //X3_DESCSPA
	'Bar Code'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'030', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'70', ; //X3_ORDEM
	'WSB_POSIPI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Pos.IPI/NCM', ; //X3_TITULO
	'Pos.IPI/NCM', ; //X3_TITSPA
	'Pos.IPI/NCM', ; //X3_TITENG
	'Nomenclatura Ext.Mercosul', ; //X3_DESCRIC
	'Nomenclatura Ext.Mercosul', ; //X3_DESCSPA
	'Ext.Nomenclature Mercosul', ; //X3_DESCENG
	'@R 9999.99.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'71', ; //X3_ORDEM
	'WSB_ITEMNF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Item NF', ; //X3_TITULO
	'Num Item NF', ; //X3_TITSPA
	'Num Item Inv', ; //X3_TITENG
	'Numero Item da NF', ; //X3_DESCRIC
	'Numero Item de Factura', ; //X3_DESCSPA
	'Item Number Invoice', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'72', ; //X3_ORDEM
	'WSB_VLGAPR', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Vld Produto', ; //X3_TITULO
	'Vld.Producto', ; //X3_TITSPA
	'PrdShelfLife', ; //X3_TITENG
	'Validade Garantia Estendi', ; //X3_DESCRIC
	'Validez Garantia Extend.', ; //X3_DESCSPA
	'XtendedWarrantyExpiration', ; //X3_DESCENG
	'@E 99,999'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'73', ; //X3_ORDEM
	'WSB_CLASFI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Sit. Tribut.', ; //X3_TITULO
	'Sit. Tribut.', ; //X3_TITSPA
	'Tax Situatio', ; //X3_TITENG
	'Situacao Tributaria', ; //X3_DESCRIC
	'Situacion tributaria', ; //X3_DESCSPA
	'Tax situation', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'74', ; //X3_ORDEM
	'WSB_DOCPED', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nota Fiscal', ; //X3_TITULO
	'Factura'	, ; //X3_TITSPA
	'Invoice No.', ; //X3_TITENG
	'Numero da Nota Fiscal', ; //X3_DESCRIC
	'Numero de la factura', ; //X3_DESCSPA
	'Invoice Number', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(151) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'75', ; //X3_ORDEM
	'WSB_SERPED', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Serie', ; //X3_TITULO
	'Serie', ; //X3_TITSPA
	'Series'	, ; //X3_TITENG
	'Serie da Nota Fiscal', ; //X3_DESCRIC
	'Serie de la factura', ; //X3_DESCSPA
	'Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(159) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'094', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'76', ; //X3_ORDEM
	'WSB_PEDPRS', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Ped Presente', ; //X3_TITULO
	'Ped Regalo', ; //X3_TITSPA
	'CurrentOrder', ; //X3_TITENG
	'Pedido Presente', ; //X3_DESCRIC
	'Pedido regalo', ; //X3_DESCSPA
	'Current Order', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'77', ; //X3_ORDEM
	'WSB_ECMSGP', ; //X3_CAMPO
	'M'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Msg Presente', ; //X3_TITULO
	'Msj Regalo', ; //X3_TITSPA
	'Current Msg.', ; //X3_TITENG
	'Msg Presente eCommerce', ; //X3_DESCRIC
	'Msj Regalo eCommerce', ; //X3_DESCSPA
	'Current eCommerce Message', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'78', ; //X3_ORDEM
	'WSB_CLIENT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cli Entrega', ; //X3_TITULO
	'Cl.Entrega', ; //X3_TITSPA
	'Del. Cust.', ; //X3_TITENG
	'Cliente de Entrega', ; //X3_DESCRIC
	'Cliente de entrega', ; //X3_DESCSPA
	'Delivery Customer', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'001', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'79', ; //X3_ORDEM
	'WSB_CLILOJ', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Loja Entrega', ; //X3_TITULO
	'Tienda entr.', ; //X3_TITSPA
	'Del. Store', ; //X3_TITENG
	'Loja Cliente de Entrega', ; //X3_DESCRIC
	'Loja Cliente de Entrega', ; //X3_DESCSPA
	'Delivery Customer Store', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'002', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'80', ; //X3_ORDEM
	'WSB_BLEST'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Bloq Estoque', ; //X3_TITULO
	'Bloq stock', ; //X3_TITSPA
	'Invent. Lock', ; //X3_TITENG
	'Bloqueio Estoque', ; //X3_DESCRIC
	'Bloqueo de stock', ; //X3_DESCSPA
	'Inventory Lock', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'81', ; //X3_ORDEM
	'WSB_SDOC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Série Doc.', ; //X3_TITULO
	'Serie Doc.', ; //X3_TITSPA
	'Inv. Series', ; //X3_TITENG
	'Série do Documento Fiscal', ; //X3_DESCRIC
	'Serie de Documento Fiscal', ; //X3_DESCSPA
	'Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'095', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'82', ; //X3_ORDEM
	'WSB_SDOCPE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Série', ; //X3_TITULO
	'Serie', ; //X3_TITSPA
	'Series'	, ; //X3_TITENG
	'Série da Nota Fiscal', ; //X3_DESCRIC
	'Serie de Factura', ; //X3_DESCSPA
	'Invoice Series', ; //X3_DESCENG
	'!!!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'095', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'83', ; //X3_ORDEM
	'WSB_ITEMGA', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Item Gar Est', ; //X3_TITULO
	'Item Gar.Ext', ; //X3_TITSPA
	'Ext War Item', ; //X3_TITENG
	'Item Garantia Estendida', ; //X3_DESCRIC
	'Item garantia extendida', ; //X3_DESCSPA
	'Extended Warranty Item', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'84', ; //X3_ORDEM
	'WSB_QTDEDE', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	11	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Qtd. Devolv.', ; //X3_TITULO
	'Cant. Devuel', ; //X3_TITSPA
	'Amt Return', ; //X3_TITENG
	'Qtd. Devolvida', ; //X3_DESCRIC
	'Cant. Devuelta', ; //X3_DESCSPA
	'Amount Returned', ; //X3_DESCENG
	'@E 99,999,999,999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(168)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'85', ; //X3_ORDEM
	'WSB_BASCSL', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Base de CSLL', ; //X3_TITULO
	'Base de CSLL', ; //X3_TITSPA
	'CSLL Base'	, ; //X3_TITENG
	'Base de Calculo do CSLL', ; //X3_DESCRIC
	'Base de cálculo de CSLL', ; //X3_DESCSPA
	'CSLL Calculation Base', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'86', ; //X3_ORDEM
	'WSB_BASEPI', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Base Pis'	, ; //X3_TITULO
	'Base Pis'	, ; //X3_TITSPA
	'Pis Base'	, ; //X3_TITENG
	'Base de Retencao de Pis', ; //X3_DESCRIC
	'Base de retención de Pis', ; //X3_DESCSPA
	'Pis Withhold. Base', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'87', ; //X3_ORDEM
	'WSB_PREDIC', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'%Red.do ICMs', ; //X3_TITULO
	'%Red.ICMS'	, ; //X3_TITSPA
	'ICMs Red %', ; //X3_TITENG
	'% Reducao da Base de ICMS', ; //X3_DESCRIC
	'% Reducc. Base de ICMS', ; //X3_DESCSPA
	'ICMS Base Reduction %', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(128) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'88', ; //X3_ORDEM
	'WSB_ALIQIS', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq. ISS'	, ; //X3_TITULO
	'Alíc. ISS'	, ; //X3_TITSPA
	'ISS Rate'	, ; //X3_TITENG
	'Aliquota de ISS', ; //X3_DESCRIC
	'Alícuota de ISS', ; //X3_DESCSPA
	'ISS Rate'	, ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'89', ; //X3_ORDEM
	'WSB_ALIQPI', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq. Pis'	, ; //X3_TITULO
	'Alíc. Pis'	, ; //X3_TITSPA
	'Pis Rate'	, ; //X3_TITENG
	'Aliq. de Retencao de Pis', ; //X3_DESCRIC
	'Alíc. de Retención de Pis', ; //X3_DESCSPA
	'Pis Withhold. Rate', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'90', ; //X3_ORDEM
	'WSB_ALQCSL', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq. CSLL', ; //X3_TITULO
	'Alíc. CSLL', ; //X3_TITSPA
	'CSLL Rate'	, ; //X3_TITENG
	'Aliquota de CSLL', ; //X3_DESCRIC
	'Alícuota de CSLL', ; //X3_DESCSPA
	'CSLL Rate'	, ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'91', ; //X3_ORDEM
	'WSB_BASECO', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Base Confins', ; //X3_TITULO
	'Base Confins', ; //X3_TITSPA
	'Cofins Base', ; //X3_TITENG
	'Base de Retencao Cofins', ; //X3_DESCRIC
	'Base de retención Cofins', ; //X3_DESCSPA
	'Confis Withhold. Base', ; //X3_DESCENG
	'@E 99,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'92', ; //X3_ORDEM
	'WSB_PICM'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq. ICMS', ; //X3_TITULO
	'Alíc. ICMS', ; //X3_TITSPA
	'ICMS Rate'	, ; //X3_TITENG
	'Aliquota de ICMS', ; //X3_DESCRIC
	'Alícuota de ICMS', ; //X3_DESCSPA
	'ICMS Rate'	, ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'93', ; //X3_ORDEM
	'WSB_ALIQCO', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Aliq. Cofins', ; //X3_TITULO
	'Alíc. Cofins', ; //X3_TITSPA
	'Cofins Rate', ; //X3_TITENG
	'Aliq. de Retencao Cofins', ; //X3_DESCRIC
	'Alíc. de Retención Cofins', ; //X3_DESCSPA
	'Confis Withhold. Rate', ; //X3_DESCENG
	'@E 99.99'	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'94', ; //X3_ORDEM
	'WSB_KIT'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Kit Prod'	, ; //X3_TITULO
	'Kit Prod'	, ; //X3_TITSPA
	'Prod Kit'	, ; //X3_TITENG
	'Kit de Produtos', ; //X3_DESCRIC
	'Kit de Productos', ; //X3_DESCSPA
	'Product Kit', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(168)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'95', ; //X3_ORDEM
	'WSB_DESTAT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Desc Status', ; //X3_TITULO
	'Desc Status', ; //X3_TITSPA
	'Desc Status', ; //X3_TITENG
	'Descricao Status Item', ; //X3_DESCRIC
	'Descricao Status Item', ; //X3_DESCSPA
	'Descricao Status Item', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'96', ; //X3_ORDEM
	'WSB_PRODTP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Tipo Produto', ; //X3_TITULO
	'Tipo Produto', ; //X3_TITSPA
	'Tipo Produto', ; //X3_TITENG
	'Tipo de Produto', ; //X3_DESCRIC
	'Tipo de Produto', ; //X3_DESCSPA
	'Tipo de Produto', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOX
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOXSPA
	'1=Produto;2=Brinde;3=Produto Gratis;4=Vale Presente;5=Personalizado'		, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'97', ; //X3_ORDEM
	'WSB_PRZENT', ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Prz Entrega', ; //X3_TITULO
	'Prz Entrega', ; //X3_TITSPA
	'Prz Entrega', ; //X3_TITENG
	'Prazo de Entrega', ; //X3_DESCRIC
	'Prazo de Entrega', ; //X3_DESCSPA
	'Prazo de Entrega', ; //X3_DESCENG
	'999', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSB', ; //X3_ARQUIVO
	'98', ; //X3_ORDEM
	'WSB_STATIT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Status Item', ; //X3_TITULO
	'Status Item', ; //X3_TITSPA
	'Status Item', ; //X3_TITENG
	'Codigo Status Item', ; //X3_DESCRIC
	'Codigo Status Item', ; //X3_DESCSPA
	'Codigo Status Item', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

//
// Campos Tabela WSC
//
aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'01', ; //X3_ORDEM
	'WSC_FILIAL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Filial'	, ; //X3_TITULO
	'Sucursal'	, ; //X3_TITSPA
	'Branch'	, ; //X3_TITENG
	'Filial do Sistema', ; //X3_DESCRIC
	'Sucursal'	, ; //X3_DESCSPA
	'Branch of the System', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	'033', ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'02', ; //X3_ORDEM
	'WSC_NUM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Orcamto', ; //X3_TITULO
	'Nro. Presup.', ; //X3_TITSPA
	'Budget No.', ; //X3_TITENG
	'Numero do Orcamento', ; //X3_DESCRIC
	'Numero del Presupuesto', ; //X3_DESCSPA
	'Budget Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(132) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'03', ; //X3_ORDEM
	'WSC_DATA'	, ; //X3_CAMPO
	'D'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Data Orcamto', ; //X3_TITULO
	'Fch Presup.', ; //X3_TITSPA
	'Budget Date', ; //X3_TITENG
	'Data do Orcamento', ; //X3_DESCRIC
	'Fecha del Presupuesto', ; //X3_DESCSPA
	'Budget Date', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'04', ; //X3_ORDEM
	'WSC_VALOR'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	2	, ; //X3_DECIMAL
	'Valor Parc.', ; //X3_TITULO
	'Valor Cuota', ; //X3_TITSPA
	'Installment', ; //X3_TITENG
	'Valor da Parcela', ; //X3_DESCRIC
	'Valor de la Cuota', ; //X3_DESCSPA
	'Value of Installment', ; //X3_DESCENG
	'@E 9,999,999,999,999.99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(148) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'05', ; //X3_ORDEM
	'WSC_FORMA'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Forma Pgto', ; //X3_TITULO
	'Forma Pago', ; //X3_TITSPA
	'Payment Mode', ; //X3_TITENG
	'Forma Pagto da Parcela', ; //X3_DESCRIC
	'Forma de Pago de la Cuota', ; //X3_DESCSPA
	'Install. Payment Mode', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'S'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'06', ; //X3_ORDEM
	'WSC_ADMINI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Administrado', ; //X3_TITULO
	'Admin.Tarjet', ; //X3_TITSPA
	'Adminis.Card', ; //X3_TITENG
	'Administradora do Cartao', ; //X3_DESCRIC
	'Administradora de Tarjeta', ; //X3_DESCSPA
	'Credit Card Administrator', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'07', ; //X3_ORDEM
	'WSC_NUMCAR', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	30	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num. Cartao', ; //X3_TITULO
	'Num. Tarjeta', ; //X3_TITSPA
	'Card Number', ; //X3_TITENG
	'Numero do Cartao', ; //X3_DESCRIC
	'Numero de la Tarjeta', ; //X3_DESCSPA
	'Card Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'08', ; //X3_ORDEM
	'WSC_OBS'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	80	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Obs.', ; //X3_TITULO
	'Observacion', ; //X3_TITSPA
	'Note', ; //X3_TITENG
	'Observacao', ; //X3_DESCRIC
	'Observaci¾n', ; //X3_DESCSPA
	'Note', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'S'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'S'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'09', ; //X3_ORDEM
	'WSC_DATATE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Data TEF'	, ; //X3_TITULO
	'Fecha TEF'	, ; //X3_TITSPA
	'TEF Date'	, ; //X3_TITENG
	'Data da Transação TEF', ; //X3_DESCRIC
	'Fecha de Transaccion TEF', ; //X3_DESCSPA
	'TEF Transaction Date', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(134) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'10', ; //X3_ORDEM
	'WSC_HORATE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hora TEF'	, ; //X3_TITULO
	'Hora TEF'	, ; //X3_TITSPA
	'TEF Time'	, ; //X3_TITENG
	'Hora da Transação TEF', ; //X3_DESCRIC
	'Hora de Transaccion TEF', ; //X3_DESCSPA
	'TEF Transaction Time', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(134) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'11', ; //X3_ORDEM
	'WSC_DOCTEF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	9	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Document.TEF', ; //X3_TITULO
	'Document.TEF', ; //X3_TITSPA
	'TEF Document', ; //X3_TITENG
	'N·mero do Documento TEF', ; //X3_DESCRIC
	'Nro. Documento TEF', ; //X3_DESCSPA
	'TEF Document Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(134) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'12', ; //X3_ORDEM
	'WSC_AUTORI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	6	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Autoriz. TEF', ; //X3_TITULO
	'Autoriz. TEF', ; //X3_TITSPA
	'TEF Author.', ; //X3_TITENG
	'N·mero da Autorização TEF', ; //X3_DESCRIC
	'Nro. Autorizacion TEF', ; //X3_DESCSPA
	'ATM Authorization Number', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(134) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'13', ; //X3_ORDEM
	'WSC_INSTIT', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	16	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Instit. TEF', ; //X3_TITULO
	'Instit. TEF', ; //X3_TITSPA
	'TEF Instit.', ; //X3_TITENG
	'Nome da Instituição TEF', ; //X3_DESCRIC
	'Nombre de Institucion TEF', ; //X3_DESCSPA
	'TEF Institution Name', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(134) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(130) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'14', ; //X3_ORDEM
	'WSC_NSUTEF', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	12	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'NSU TEF'	, ; //X3_TITULO
	'NSU TEF'	, ; //X3_TITSPA
	'NSU TEF'	, ; //X3_TITENG
	'NSU do Sitef', ; //X3_DESCRIC
	'NSU de Sitef', ; //X3_DESCSPA
	'NSU do Sitef', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(134) + Chr(128) + Chr(160) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'15', ; //X3_ORDEM
	'WSC_MOEDA'	, ; //X3_CAMPO
	'N'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Moeda', ; //X3_TITULO
	'Moneda'	, ; //X3_TITSPA
	'Currency'	, ; //X3_TITENG
	'Moeda da fatura', ; //X3_DESCRIC
	'Moneda de la factura', ; //X3_DESCSPA
	'Invoice Currency', ; //X3_DESCENG
	'99', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(154) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'16', ; //X3_ORDEM
	'WSC_CGC'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	14	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'CNPJ', ; //X3_TITULO
	'CNPJ', ; //X3_TITSPA
	'CNPJ', ; //X3_TITENG
	'CNPJ do Emitente do Chequ', ; //X3_DESCRIC
	'CNPJ Emitente del Chequ', ; //X3_DESCSPA
	'Check Issuer`s CNPJ Num', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'17', ; //X3_ORDEM
	'WSC_NOMECL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	40	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Nome', ; //X3_TITULO
	'Nombre'	, ; //X3_TITSPA
	'Name', ; //X3_TITENG
	'Nome Emitente do Cheque', ; //X3_DESCRIC
	'Nombre Emitente de Cheque', ; //X3_DESCSPA
	'Check Issuer Name', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(150) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'18', ; //X3_ORDEM
	'WSC_FORMPG', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Form.Pagto', ; //X3_TITULO
	'Forma Pago', ; //X3_TITSPA
	'Paym.Mode'	, ; //X3_TITENG
	'Forma de pagamento', ; //X3_DESCRIC
	'Forma de pago', ; //X3_DESCSPA
	'Payment Mode', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'19', ; //X3_ORDEM
	'WSC_VENDTE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Venda TEF'	, ; //X3_TITULO
	'Venta TEF'	, ; //X3_TITSPA
	'TIO Sales'	, ; //X3_TITENG
	'Indica se foi venda TEF', ; //X3_DESCRIC
	'Indica si se vendio TEF', ; //X3_DESCSPA
	'Determine If a TIO sales', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(134) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'20', ; //X3_ORDEM
	'WSC_PARCTE', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	3	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Parcelas TEF', ; //X3_TITULO
	'Cuotas TEF', ; //X3_TITSPA
	'ETF Instal.', ; //X3_TITENG
	'Parcelamento TEF', ; //X3_DESCRIC
	'Division en Cuotas TEF', ; //X3_DESCSPA
	'ETF Installments', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	''	, ; //X3_BROWSE
	''	, ; //X3_VISUAL
	''	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'21', ; //X3_ORDEM
	'WSC_ITEM'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	2	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Item', ; //X3_TITULO
	'Item', ; //X3_TITSPA
	'Item', ; //X3_TITENG
	'Numero do Lancamento Nego', ; //X3_DESCRIC
	'Numero del Asto Nego', ; //X3_DESCSPA
	'Nego Entry Number', ; //X3_DESCENG
	'ciado', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'22', ; //X3_ORDEM
	'WSC_CODVP'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Codigo do VP', ; //X3_TITULO
	'Codigo de VP', ; //X3_TITSPA
	'VP Code'	, ; //X3_TITENG
	'Codigo do VP', ; //X3_DESCRIC
	'Codigo de VP', ; //X3_DESCSPA
	'VP Code'	, ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'A'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'23', ; //X3_ORDEM
	'WSC_BANDEI', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Bandeira'	, ; //X3_TITULO
	'Marca', ; //X3_TITSPA
	'Flag', ; //X3_TITENG
	'Codigo da Bandeira', ; //X3_DESCRIC
	'Código de la marca', ; //X3_DESCSPA
	'Flag Code'	, ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'24', ; //X3_ORDEM
	'WSC_REDEAU', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	5	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Rede Autoror', ; //X3_TITULO
	'Red Autoriz', ; //X3_TITSPA
	'Author Net', ; //X3_TITENG
	'Codigo Rede Autorizadora', ; //X3_DESCRIC
	'Código red autorizadora', ; //X3_DESCSPA
	'Authorized Net Code', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	1	, ; //X3_NIVEL
	Chr(132) + Chr(128), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	''	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	'N'	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	'1'	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	'N'	, ; //X3_MODAL
	'S'	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'25', ; //X3_ORDEM
	'WSC_NUMECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	15	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. Pv eCom', ; //X3_TITULO
	'Cod. Pv eCom', ; //X3_TITSPA
	'Cod. Pv eCom', ; //X3_TITENG
	'Cod. Pedido de Venda eCom', ; //X3_DESCRIC
	'Cod. Pedido de Venda eCom', ; //X3_DESCSPA
	'Cod. Pedido de Venda eCom', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'26', ; //X3_ORDEM
	'WSC_NUMECL', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	10	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Num Pv Cli', ; //X3_TITULO
	'Num Pv Cli', ; //X3_TITSPA
	'Num Pv Cli', ; //X3_TITENG
	'Num Pv Cliente eCommerce', ; //X3_DESCRIC
	'Num Pv Cliente eCommerce', ; //X3_DESCSPA
	'Num Pv Cliente eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'WSC', ; //X3_ARQUIVO
	'27', ; //X3_ORDEM
	'WSC_TID'	, ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	20	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Cod. TID'	, ; //X3_TITULO
	'Cod. TID'	, ; //X3_TITSPA
	'Cod. TID'	, ; //X3_TITENG
	'Cod. Transação Pagamento', ; //X3_DESCRIC
	'Cod. Transação Pagamento', ; //X3_DESCSPA
	'Cod. Transação Pagamento', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME
	
//
// Campos Tabela DA1
//
aAdd( aSX3, { ;
	'DA1', ; //X3_ARQUIVO
	'29', ; //X3_ORDEM
	'DA1_ENVECO', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	1	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Envia eComm', ; //X3_TITULO
	'Envia eComm', ; //X3_TITSPA
	'Envia eComm', ; //X3_TITENG
	'Envio eCommerce', ; //X3_DESCRIC
	'Envio eCommerce', ; //X3_DESCSPA
	'Envio eCommerce', ; //X3_DESCENG
	'@!', ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"', ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	'1=Nao Enviado;2=Enviado', ; //X3_CBOX
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXSPA
	'1=Nao Enviado;2=Enviado', ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	''	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	''	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'DA1', ; //X3_ARQUIVO
	'30', ; //X3_ORDEM
	'DA1_XDTEXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Dt Export'	, ; //X3_TITULO
	'Dt Export'	, ; //X3_TITSPA
	'Dt Export'	, ; //X3_TITENG
	'Data Exportacao', ; //X3_DESCRIC
	'Data Exportacao', ; //X3_DESCSPA
	'Data Exportacao', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME

aAdd( aSX3, { ;
	'DA1', ; //X3_ARQUIVO
	'31', ; //X3_ORDEM
	'DA1_XHREXP', ; //X3_CAMPO
	'C'	, ; //X3_TIPO
	8	, ; //X3_TAMANHO
	0	, ; //X3_DECIMAL
	'Hr Export'	, ; //X3_TITULO
	'Hr Export'	, ; //X3_TITSPA
	'Hr Export'	, ; //X3_TITENG
	'Hora Exportacao', ; //X3_DESCRIC
	'Hora Exportacao', ; //X3_DESCSPA
	'Hora Exportacao', ; //X3_DESCENG
	''	, ; //X3_PICTURE
	''	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''	, ; //X3_RELACAO
	''	, ; //X3_F3
	0	, ; //X3_NIVEL
	Chr(254) + Chr(192), ; //X3_RESERV
	''	, ; //X3_CHECK
	''	, ; //X3_TRIGGER
	'U'	, ; //X3_PROPRI
	'N'	, ; //X3_BROWSE
	'V'	, ; //X3_VISUAL
	'R'	, ; //X3_CONTEXT
	''	, ; //X3_OBRIGAT
	''	, ; //X3_VLDUSER
	''	, ; //X3_CBOX
	''	, ; //X3_CBOXSPA
	''	, ; //X3_CBOXENG
	''	, ; //X3_PICTVAR
	''	, ; //X3_WHEN
	''	, ; //X3_INIBRW
	''	, ; //X3_GRPSXG
	''	, ; //X3_FOLDER
	''	, ; //X3_CONDSQL
	''	, ; //X3_CHKSQL
	''	, ; //X3_IDXSRV
	'N'	, ; //X3_ORTOGRA
	''	, ; //X3_TELA
	''	, ; //X3_POSLGT
	'N'	, ; //X3_IDXFLD
	''	, ; //X3_AGRUP
	''	, ; //X3_MODAL
	''	} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SC0
//
aAdd( aSIX, { ;
	'SC0', ; //INDICE
	'3'	, ; //ORDEM
	'C0_FILIAL+C0_TIPO+C0_DOCRES'		, ; //CHAVE
	'Tipo Reserva+Doc. Reserva', ; //DESCRICAO
	'Tipo Reserva+Doc. Reserva', ; //DESCSPA
	'Tipo Reserva+Doc. Reserva', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	'RESERVECO'	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela SC5
//
aAdd( aSIX, { ;
	'SC5', ; //INDICE
	'5'	, ; //ORDEM
	'C5_FILIAL+C5_XNUMECO'	, ; //CHAVE
	'Cod. Pv eCom', ; //DESCRICAO
	'Cod. Pv eCom', ; //DESCSPA
	'Cod. Pv eCom', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	'PEDIDOECO'	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC5', ; //INDICE
	'6'	, ; //ORDEM
	'C5_FILIAL+C5_XNUMECL'	, ; //CHAVE
	'Num Pv Cli', ; //DESCRICAO
	'Num Pv Cli', ; //DESCSPA
	'Num Pv Cli', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela SE1
//
aAdd( aSIX, { ;
	'SE1', ; //INDICE
	'S'	, ; //ORDEM
	'E1_FILIAL+E1_XNUMECO'	, ; //CHAVE
	'Num Pv eComm', ; //DESCRICAO
	'Num Pv eComm', ; //DESCSPA
	'Num Pv eComm', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	'TITECO'	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela SL1
//
aAdd( aSIX, { ;
	'SL1', ; //INDICE
	'F'	, ; //ORDEM
	'L1_FILIAL+L1_XNUMECO'	, ; //CHAVE
	'Cod. Pv eCom', ; //DESCRICAO
	'Cod. Pv eCom', ; //DESCSPA
	'Cod. Pv eCom', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	'PEDIDOECO'	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SL1', ; //INDICE
	'G'	, ; //ORDEM
	'L1_FILIAL+L1_XNUMECL'	, ; //CHAVE
	'Num Pv Cli', ; //DESCRICAO
	'Num Pv Cli', ; //DESCSPA
	'Num Pv Cli', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	'PEDECOCLI'	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WS0
//
aAdd( aSIX, { ;
	'WS0', ; //INDICE
	'1'	, ; //ORDEM
	'WS0_FILIAL+WS0_COD+WS0_THREAD'		, ; //CHAVE
	'Interface+Trhead Id+Thread'		, ; //DESCRICAO
	'Interface+Trhead Id+Thread'		, ; //DESCSPA
	'Interface+Trhead Id+Thread'		, ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WS0', ; //INDICE
	'2'	, ; //ORDEM
	'WS0_FILIAL+WS0_DESCIN'	, ; //CHAVE
	'Desc Interf', ; //DESCRICAO
	'Desc Interf', ; //DESCSPA
	'Desc Interf', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WS0', ; //INDICE
	'3'	, ; //ORDEM
	'WS0_FILIAL+WS0_DATA'	, ; //CHAVE
	'Data', ; //DESCRICAO
	'Data', ; //DESCSPA
	'Data', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WS1
//
aAdd( aSIX, { ;
	'WS1', ; //INDICE
	'1'	, ; //ORDEM
	'WS1_FILIAL+WS1_CODIGO'	, ; //CHAVE
	'Codigo'	, ; //DESCRICAO
	'Codigo'	, ; //DESCSPA
	'Codigo'	, ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WS1', ; //INDICE
	'2'	, ; //ORDEM
	'WS1_FILIAL+WS1_DESCVT'	, ; //CHAVE
	'Filial+Descr. VTex'	, ; //DESCRICAO
	'Sucursal+Descr. VTex'	, ; //DESCSPA
	'Branch+Descr. VTex'	, ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'N'	} ) //SHOWPESQ

//
// Tabela WS2
//
aAdd( aSIX, { ;
	'WS2', ; //INDICE
	'1'	, ; //ORDEM
	'WS2_FILIAL+WS2_NUMECO+WS2_CODSTA'	, ; //CHAVE
	'Num Ped Eco+Cod Status', ; //DESCRICAO
	'Num Ped Eco+Cod Status', ; //DESCSPA
	'Num Ped Eco+Cod Status', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WS2', ; //INDICE
	'2'	, ; //ORDEM
	'WS2_FILIAL+WS2_NUMSL1+WS2_CODSTA'	, ; //CHAVE
	'Codigo SL1+Cod Status'	, ; //DESCRICAO
	'Codigo SL1+Cod Status'	, ; //DESCSPA
	'Codigo SL1+Cod Status'	, ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WS3
//
aAdd( aSIX, { ;
	'WS3', ; //INDICE
	'1'	, ; //ORDEM
	'WS3_FILIAL+WS3_CODIGO'	, ; //CHAVE
	'Codigo Forma', ; //DESCRICAO
	'Codigo Forma', ; //DESCSPA
	'Codigo Forma', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WS4
//
aAdd( aSIX, { ;
	'WS4', ; //INDICE
	'1'	, ; //ORDEM
	'WS4_FILIAL+WS4_CODIGO+WS4_TIPO'	, ; //CHAVE
	'Codigo Oper+Tipo de Oper', ; //DESCRICAO
	'Codigo Oper+Tipo de Oper', ; //DESCSPA
	'Codigo Oper+Tipo de Oper', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WS5
//
aAdd( aSIX, { ;
	'WS5', ; //INDICE
	'1'	, ; //ORDEM
	'WS5_FILIAL+WS5_CODIGO'	, ; //CHAVE
	'Codigo Campo', ; //DESCRICAO
	'Codigo Campo', ; //DESCSPA
	'Codigo Campo', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WS5', ; //INDICE
	'2'	, ; //ORDEM
	'WS5_FILIAL+WS5_CAMPO'	, ; //CHAVE
	'Campo VTex', ; //DESCRICAO
	'Campo VTex', ; //DESCSPA
	'Campo VTex', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WS6
//
aAdd( aSIX, { ;
	'WS6', ; //INDICE
	'1'	, ; //ORDEM
	'WS6_FILIAL+WS6_CODPRD+WS6_CODIGO'	, ; //CHAVE
	'Cod. Produto+Codigo Campo', ; //DESCRICAO
	'Cod. Produto+Codigo Campo', ; //DESCSPA
	'Cod. Produto+Codigo Campo', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WSA
//
aAdd( aSIX, { ;
	'WSA', ; //INDICE
	'1'	, ; //ORDEM
	'WSA_FILIAL+WSA_NUM'	, ; //CHAVE
	'No Orcamento', ; //DESCRICAO
	'Nro.Presup.', ; //DESCSPA
	'Budget No.', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WSA', ; //INDICE
	'2'	, ; //ORDEM
	'WSA_FILIAL+WSA_NUMECO+WSA_NUMECL'	, ; //CHAVE
	'Cod. Pv eCom+Num Pv Cli', ; //DESCRICAO
	'Cod. Pv eCom+Num Pv Cli', ; //DESCSPA
	'Cod. Pv eCom+Num Pv Cli', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	'PEDIDOECO'	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WSB
//
aAdd( aSIX, { ;
	'WSB', ; //INDICE
	'1'	, ; //ORDEM
	'WSB_FILIAL+WSB_NUM+WSB_PRODUT+WSB_ITEM'								, ; //CHAVE
	'No Orcamento+Produto+Nº Item'		, ; //DESCRICAO
	'Nro. Presup.+Producto+Nº Item'		, ; //DESCSPA
	'Budget No.+Producto+Nº Item'		, ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Tabela WSC
//
aAdd( aSIX, { ;
	'WSC', ; //INDICE
	'1'	, ; //ORDEM
	'WSC_FILIAL+WSC_NUM'	, ; //CHAVE
	'Num Orcamto', ; //DESCRICAO
	'Nro. Presup.', ; //DESCSPA
	'Budget No.', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WSC', ; //INDICE
	'2'	, ; //ORDEM
	'WSC_FILIAL+WSC_NUMECO+WSC_NUMECL'	, ; //CHAVE
	'Cod. Pv eCom+Num Pv Cli', ; //DESCRICAO
	'Cod. Pv eCom+Num Pv Cli', ; //DESCSPA
	'Cod. Pv eCom+Num Pv Cli', ; //DESCENG
	'U'	, ; //PROPRI
	''	, ; //F3
	''	, ; //NICKNAME
	'S'	} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_CODAGE'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define codigo da agencia default caso nao seja enc'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ontrada no titulo.'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	''	, ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_CODBACE', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Codigo de Pais Bacen, para cadastros de clientes v'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'indos do portal de cliente.'		, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'01058', ; //X6_CONTEUD
	'01058', ; //X6_CONTSPA
	'01058', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_CODBCO'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define codigo do banco default, caso nao seja enco'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ntrado no titulo.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	''	, ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_CODCTA'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define codigo da conta corrente caso nao seja enco'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ntrada no titulo.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	''	, ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_CODPAIS', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define codigo do pais default para clientes cadast'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'rados pelo Portal de Clientes.'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'105', ; //X6_CONTEUD
	'105', ; //X6_CONTSPA
	'105', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_DEL2VIA', ; //X6_VAR
	'L'	, ; //X6_TIPO
	'Define se deleta a 2Via do boleto após ser enviado'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'pela API.'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'.F.', ; //X6_CONTEUD
	'.F.', ; //X6_CONTSPA
	'.F.', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_DVENCTO', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Define quantidade de dias para nova data de vencim'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ento para 2 via de boleto.'		, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'7'	, ; //X6_CONTEUD
	'7'	, ; //X6_CONTSPA
	'7'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_MSBLQL'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define se novos clientes vindos do portal de clien'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'tes serão cadastrados como bloqueados.'								, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'1'	, ; //X6_CONTEUD
	'1'	, ; //X6_CONTSPA
	'1'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'AS_PDF2VIA', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define pasta onde será salvo a 2 via do boleto rep'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'rocessado.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'\boleto2via\', ; //X6_CONTEUD
	'\boleto2via\', ; //X6_CONTSPA
	'\boleto2via\', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'DA_A1PALM'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'codigo sequencial do codigo palm de clientes'							, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'9BRV', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'DA_AEROSOL', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Adiciona texto a descricao do produto na NF-e'							, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'650|656|657|658|913|915|916|7086|7090|7091|7092|7093|7094|7095|7096|7097|500|501|502|503|504|DP1001|DP1002', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'DA_PERFUMA', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Adiciona texto a descricao do produto na NF-e'							, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'695|696|697|701|704|716|717|718|742|744|745|746|7006|7007|7043|7044|7078|7079', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'DA_PERVEN'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Periodo em vigencia para geracao do objetivos de'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'vendas'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'0604', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'DN_TESBON'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'TES usada para calculo de bonificacao no faturamen'					, ; //X6_DESCRIC
	'TES usada para calculo de bonificacao no faturamen'					, ; //X6_DSCSPA
	'TES usada para calculo de bonificacao no faturamen'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'661/728/735/665/827/828/829/665/671/729/736/552/569/576/502/751/769/776/672/742/655', ; //X6_CONTEUD
	'661/728/735/665/827/828/829/665/671/729/736/552/569/576/502/751/769/776/672/742/655', ; //X6_CONTSPA
	'661/728/735/665/827/828/829/665/671/729/736/552/569/576/502/751/769/776/672/742/655', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'DN_TESDEV'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Tes de Devolucao que movimentam estoque e geram fi'					, ; //X6_DESCRIC
	'Tes de Devolucao que movimentam estoque e geram fi'					, ; //X6_DSCSPA
	'Tes de Devolucao que movimentam estoque e geram fi'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'031/032/033', ; //X6_CONTEUD
	'031/032/033', ; //X6_CONTSPA
	'031/032/033', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'DN_TESFAT'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'TES usadas para o calculo de Verba no faturamento'						, ; //X6_DESCRIC
	'TES usadas para o calculo de Verba no faturamento'						, ; //X6_DSCSPA
	'TES usadas para o calculo de Verba no faturamento'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'601/620/718/725/604/615/801/818/825/603/719/726/604/750/602/802/768/775/551/568/575/501/509/515/755/623/510', ; //X6_CONTEUD
	'601/620/718/725/604/615/801/818/825/603/719/726/604/750/602/802/768/775/551/568/575/501/509/515/755/623/510', ; //X6_CONTSPA
	'601/620/718/725/604/615/801/818/825/603/719/726/604/750/602/802/768/775/551/568/575/501/509/515/755/623/510', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_ADMFIN'	, ; //X6_VAR
	'L'	, ; //X6_TIPO
	'Define se utiliza Taxa Admnistrativa para titulos'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'pagos em Cartão. True = Utiliza ; False = Nao Util'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'iza', ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'.T.', ; //X6_CONTEUD
	'.T.', ; //X6_CONTSPA
	'.T.', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_AGEBCO'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Agencia bancaria para baixas automaticas pagamento'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	's eCommerce.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'0000', ; //X6_CONTEUD
	'0000', ; //X6_CONTSPA
	'0000', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_AMZDEVR', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa o armazem utilizado na devolução de remess'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'a. Caso tenha mais de uma filial, parametro devera'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'ser utilizado de forma exclusiva por filial.'							, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'51', ; //X6_CONTEUD
	'51', ; //X6_CONTSPA
	'51', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_APPKEY'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Chave de acesso para realizar a integracao dos dad'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'os atraves de API.'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'vtexappkey-danacosmeticos-UTFXVK'	, ; //X6_CONTEUD
	'vtexappkey-vizcaya-JPOHOC', ; //X6_CONTSPA
	'vtexappkey-vizcaya-JPOHOC', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_APPTOKE', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Token de acesso para relaizar as integracoes de da'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'dos utilizando API VTEX.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'JYIGPNWXMAIQAPLITNTYLPDNBJPXUPLGDMWGZNBRCYMXUUFIEOVVXWQUVUFGXYDWPBNNSEIGMCVMCGTGDGTFUQIGWCLFHUTDVPISHRPZFOIUBDRPBZDRFXCYTHRQTDYR', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_ARMAZEM', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa o armazem que espelha o estoque do ERP com'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'o e-Commerce.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'01', ; //X6_CONTEUD
	'01', ; //X6_CONTSPA
	'01', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_ARMVEND', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Armazem que sera realizada a movimentacao dos pedi'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'dos realizados no e-Commerce.'		, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'01', ; //X6_CONTEUD
	'01', ; //X6_CONTSPA
	'01', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_ARMZDEV', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define o Armazem que será dado entrada nas notas d'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'e devolução.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'01', ; //X6_CONTEUD
	'01', ; //X6_CONTSPA
	'01', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_BOLVENC', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informar o numero de dias para vencimento do bolet'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'o bancario para titulos e-Commerce.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'5'	, ; //X6_CONTEUD
	'5'	, ; //X6_CONTSPA
	'5'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_CHAVEA1', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa chave A1 de acesso ao ecommerce rakuten'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'08a7e0b8-6cb5-487c-857f-e00e60c92a7d', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_CHAVEA2', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa chave A2 de acesso ao ecommerce rakuten'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'0769e761-5193-4524-92b1-413961c21f1f', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_CODBCO'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Codigo do banco para baixa automatica dos titulos'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'eCommerce.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'000', ; //X6_CONTEUD
	'000', ; //X6_CONTSPA
	'000', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_CONBCO'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Numero da Conta + Digito para baixa automatica de'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'pagamentos e-Commerce.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'000000'	, ; //X6_CONTEUD
	'000000'	, ; //X6_CONTSPA
	'000000'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_CONDPAG', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informe a condicao de pagamento padrao para uso no'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	's pedios ecommerce'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001', ; //X6_CONTEUD
	'001', ; //X6_CONTSPA
	'001', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_ESPECIE', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa a especie para os volumes que serao impres'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'sos na nota fiscal de saida, para pedidos e-commer'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'ce', ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'CAIXA', ; //X6_CONTEUD
	'CAIXA', ; //X6_CONTSPA
	'CAIXA', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_FATAUTO', ; //X6_VAR
	'L'	, ; //X6_TIPO
	'Define de pedidos com pagameento aprovado sera fat'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'urado automaticamente.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'.F.', ; //X6_CONTEUD
	'.F.', ; //X6_CONTSPA
	'.F.', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_FIDEVRE', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define as filiais utilizadas na devolução de remes'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'sa. Caso tenha mais de uma filial utilizada separa'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'r as filiais por "/".'	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'0101/0102'	, ; //X6_CONTEUD
	'0101/0102'	, ; //X6_CONTSPA
	'0101/0102'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_FILEST'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa a filial que espelha o estoque do ERP com'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'o e-Commerce.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'01', ; //X6_CONTEUD
	'03', ; //X6_CONTSPA
	'03', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_FILNFJB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Determina as filiais que serão transmitidas as not'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'as automaticamente'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'0101/0102'	, ; //X6_CONTEUD
	'0101/0102'	, ; //X6_CONTSPA
	'0101/0102'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_FORCPMR', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define o fornecedor + loja do titulo a pagar dos p'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'edidos divididos. Preencher parametro codigo forne'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'cedor + loja', ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'00226703'	, ; //X6_CONTEUD
	'00226703'	, ; //X6_CONTSPA
	'00226703'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_GRPPRD'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define os Grupos de produtos quenão fazem parte da'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'explosao da estrutura no Pedido de Venda eCommerc'						, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'e'	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'01/05', ; //X6_CONTEUD
	'01/05', ; //X6_CONTSPA
	'01/05', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_LIBPVAU', ; //X6_VAR
	'L'	, ; //X6_TIPO
	'Libera pedido automatico quando pagamento confirma'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'do.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'.F.', ; //X6_CONTEUD
	'.F.', ; //X6_CONTSPA
	'.F.', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_LOGMAIL', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa o(s) email(s) que receberao os log(s) com'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'os erros de integracao ecommerce'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'bernard.modesto@alfaerp.com.br'	, ; //X6_CONTEUD
	'bernard.modesto@totvspartners.com.br', ; //X6_CONTSPA
	'bernard.modesto@totvspartners.com.br', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_NATCPMR', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define a naturaze para os titulas a pagar dos pedi'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'dos divididos.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'RECEBIMENT', ; //X6_CONTEUD
	'RECEBIMENT', ; //X6_CONTSPA
	'RECEBIMENT', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_NATNCC'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define natureza para os titulos de NCC gerados na'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'devolucao de venda.'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'CREDITO'	, ; //X6_CONTEUD
	'CREDITO'	, ; //X6_CONTSPA
	'CREDITO'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_PGTODEV', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define a Condicao de Pagamento a ser utilizada nas'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'notas de devolução gerando NCC para o cliente.'						, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001', ; //X6_CONTEUD
	'001', ; //X6_CONTSPA
	'001', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_PRDESTR', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define codigo inicial dos produtos que contem estr'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'utura amarrada.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'99', ; //X6_CONTEUD
	'99', ; //X6_CONTSPA
	'99', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_PREFIXO', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa qual vai ser o prefixo para os titulos do'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ecommerce.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'ECO', ; //X6_CONTEUD
	'ECO', ; //X6_CONTSPA
	'ECO', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_PSWVTEX', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define a senha de acesso aos webservices da VTEX.'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'JYIGPNWXMAIQAPLITNTYLPDNBJPXUPLGDMWGZNBRCYMXUUFIEOVVXWQUVUFGXYDWPBNNSEIGMCVMCGTGDGTFUQIGWCLFHUTDVPISHRPZFOIUBDRPBZDRFXCYTHRQTDYR', ; //X6_CONTEUD
	'integracao_123', ; //X6_CONTSPA
	'integracao_123', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_SERDEV'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define a serie da notas fiscal utilizada nas remes'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'sas de devolucao.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001', ; //X6_CONTEUD
	'001', ; //X6_CONTSPA
	'001', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_SERIEJB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Determina as series das notas que serão transmitid'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'as automaticamente.'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001', ; //X6_CONTEUD
	'001', ; //X6_CONTSPA
	'001', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_SERIENF', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informar a Serie da Nota Fiscal a ser utilizada pa'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ra pedidos e-Commerce'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001', ; //X6_CONTEUD
	'001', ; //X6_CONTSPA
	'001', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_SERPRE'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informar a serie a ser utilizada para as pre notas'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'de transferencia eCommerce'		, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'005', ; //X6_CONTEUD
	'005', ; //X6_CONTSPA
	'005', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_STATFAT', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa codigo dos status do pedido paranao permit'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ir nova liberacao. Codigo devera estar separados p'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'or "/"'	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'900', ; //X6_CONTEUD
	'900', ; //X6_CONTSPA
	'900', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_STATLIB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informar codigo dos Status do Pedido liberado e ag'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'uardando transferencia. Codigo serpado por /'							, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'900/901'	, ; //X6_CONTEUD
	'900/901'	, ; //X6_CONTSPA
	'900/901'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_STATPVE', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Infome o(s) codigos que poderam lberar o pedido de'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'venda e-commerce', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'007', ; //X6_CONTEUD
	'007', ; //X6_CONTSPA
	'007', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_STATVLD', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa codigo dos status do pedido paranao permit'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ir nova liberacao. Codigo devera estar separados p'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'or "/"'	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001/004/005/006/008/017/092/099/108', ; //X6_CONTEUD
	'001/004/005/006/008/017/092/099/108', ; //X6_CONTSPA
	'001/004/005/006/008/017/092/099/108', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TABECO'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa o codigo da tabela de preco a ser praticad'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'o no e-commerce', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001', ; //X6_CONTEUD
	'002', ; //X6_CONTSPA
	'002', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TESECO'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa a Tes utilziada no pedido e-commerce, some'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'nte utilizado caso nao use a tes inteligente.'							, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'501', ; //X6_CONTEUD
	'501', ; //X6_CONTSPA
	'501', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TESINT'	, ; //X6_VAR
	'L'	, ; //X6_TIPO
	'Informa se sera utilizado Tes Inteligente para os'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'pedidos e-commerce'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'.T.', ; //X6_CONTEUD
	'.T.', ; //X6_CONTSPA
	'.T.', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TESTROC', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define a TES utilizada para as Trocas de Pedidos e'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'-Commerce'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'008', ; //X6_CONTEUD
	'008', ; //X6_CONTSPA
	'008', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TPDESC'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define se o desconto será aplicado no total ou nos'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'itens do pedido e-Commerce. 1 - Total; 2 - Itens'						, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'2'	, ; //X6_CONTEUD
	'2'	, ; //X6_CONTSPA
	'2'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TPOPERD', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define o codido do tipo de operacao a ser utilizad'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'o na devoução quando se utiliza TES Inteligente.'						, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'02', ; //X6_CONTEUD
	'02', ; //X6_CONTSPA
	'02', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TPOPERE', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informa o codigo da tes inteligente para pedidos e'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'-Commerce'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'01', ; //X6_CONTEUD
	'EC', ; //X6_CONTSPA
	'EC', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TPTROCA', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define o tipo de nota que será realizada a devoluc'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ao. 1 - Pre-Nota, 2 - Documento de Entrada.'							, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'1'	, ; //X6_CONTEUD
	'1'	, ; //X6_CONTSPA
	'1'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TRANDEV', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define a Transportadora utilizada na Devolução das'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'mercadorias.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'000001'	, ; //X6_CONTEUD
	'000001'	, ; //X6_CONTSPA
	'000001'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_TRANSP'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define a transportadora padrao para pedidos e-comm'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'erce', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'246', ; //X6_CONTEUD
	'246', ; //X6_CONTSPA
	'246', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_URLECOM', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informar qual a URL que sera realizada as integrac'					, ; //X6_DESCRIC
	'Informar qual a URL que sera realizada as integrac'					, ; //X6_DSCSPA
	'Informar qual a URL que sera realizada as integrac'					, ; //X6_DSCENG
	'oes e-Commerce', ; //X6_DESC1
	'oes e-Commerce', ; //X6_DSCSPA1
	'oes e-Commerce', ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc', ; //X6_CONTEUD
	'http://maluli.ecservice.rakuten.com.br/ikcwebservice/'					, ; //X6_CONTSPA
	'http://maluli.ecservice.rakuten.com.br/ikcwebservice/'					, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_URLRES2', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'URL conexão com as API VTEX'		, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'https://api.vtex.com/danacosmeticos', ; //X6_CONTEUD
	'https://api.vtex.com/danacosmeticos', ; //X6_CONTSPA
	'https://api.vtex.com/danacosmeticos', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_URLREST', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informar qual a URL que sera realizada as integrac'					, ; //X6_DESCRIC
	'Informar qual a URL que sera realizada as integrac'					, ; //X6_DSCSPA
	'Informar qual a URL que sera realizada as integrac'					, ; //X6_DSCENG
	'oes API REST', ; //X6_DESC1
	'oes API REST', ; //X6_DSCSPA1
	'oes API REST', ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'http://danacosmeticos.vtexcommercestable.com.br'						, ; //X6_CONTEUD
	'http://vizcaya.vtexcommercestable.com.br'								, ; //X6_CONTSPA
	'http://vizcaya.vtexcommercestable.com.br'								, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_USAECO'	, ; //X6_VAR
	'L'	, ; //X6_TIPO
	'Está usando o template de e-Commerce.', ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'.T.', ; //X6_CONTEUD
	'.T.', ; //X6_CONTSPA
	'.T.', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_USAVEND', ; //X6_VAR
	'L'	, ; //X6_TIPO
	'Define se utilia vendedor para as vendas do e-Comm'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'erce. Se .T. informar o codigo do vendedor no para'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'metro EC_VENDECO', ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'.F.', ; //X6_CONTEUD
	'.F.', ; //X6_CONTSPA
	'.F.', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_USRVTEX', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define o usuario de acesso aos webservices da VTEX'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'vtexappkey-danacosmeticos-UTFXVK'	, ; //X6_CONTEUD
	'integracao', ; //X6_CONTSPA
	'integracao', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'EC_VENDECO', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Informar o vendedor padrao para vendas realizadas'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'no e-commerce', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'000001'	, ; //X6_CONTEUD
	'000001'	, ; //X6_CONTSPA
	'000001'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'FS_GCTCOT'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Tipo Contrato para cotacao'		, ; //X6_DESCRIC
	'Tipo Contrato para cotizacion'		, ; //X6_DSCSPA
	'Contract type for quotation'		, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001', ; //X6_CONTEUD
	'001', ; //X6_CONTSPA
	'001', ; //X6_CONTENG
	'S'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	'001', ; //X6_DEFPOR
	'001', ; //X6_DEFSPA
	'001', ; //X6_DEFENG
	'S'	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_ INSCRI', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Indica o numero da Inscricao'		, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'Municipal para contribuinte.'		, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'<conforme contribuinte>', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_BCOCNB'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Contem o numero dos bancos que receberao tratament'					, ; //X6_DESCRIC
	'Contem o numero dos bancos que receberao tratament'					, ; //X6_DSCSPA
	'Contem o numero dos bancos que receberao tratament'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'001/ 341/19/637/422'	, ; //X6_CONTEUD
	'001/', ; //X6_CONTSPA
	'001/', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_BLOQTES', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Bloqueia os pedidos que tiverem os TES que estao c'					, ; //X6_DESCRIC
	'Bloqueia os pedidos que tiverem os TES que estao c'					, ; //X6_DSCSPA
	'Bloqueia os pedidos que tiverem os TES que estao c'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'561/', ; //X6_CONTEUD
	'561/', ; //X6_CONTSPA
	'561/', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_BXBORDE', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Indica uso da tecla Alt+B para efetuar  baixa.'						, ; //X6_DESCRIC
	'Indica uso da tecla Alt+B para efetuar  baixa.'						, ; //X6_DSCSPA
	'Indica uso da tecla Alt+B para efetuar  baixa.'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'N'	, ; //X6_CONTEUD
	'N'	, ; //X6_CONTSPA
	'N'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_CLIELIB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Clientes que na emissao da nota fiscal aparece a q'					, ; //X6_DESCRIC
	'Clientes que na emissao da nota fiscal aparece a q'					, ; //X6_DSCSPA
	'Clientes que na emissao da nota fiscal aparece a q'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'03597/10905/', ; //X6_CONTEUD
	'03597/10905/', ; //X6_CONTSPA
	'03597/10905/', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_CODPSA1', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Ultimo codigo de cliente cadastrado pela extranet'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'07895', ; //X6_CONTEUD
	'07895', ; //X6_CONTSPA
	'07895', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_DANA01'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Nome do usuario liberado para alteracao do preco'						, ; //X6_DESCRIC
	'Nome do usuario liberado para alteracao do preco'						, ; //X6_DSCSPA
	'Nome do usuario liberado para alteracao do preco'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'CLOVIS\ADMINISTRADOR\CARLOS\ALEXSANDRA\MARISA'							, ; //X6_CONTEUD
	'CLOVIS\ADMINISTRADOR\CARLOS\ALEXSANDRA\MARISA'							, ; //X6_CONTSPA
	'CLOVIS\ADMINISTRADOR\CARLOS\ALEXSANDRA\MARISA'							, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_DANA02'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Nome do usuario liberado para alteracao de preco'						, ; //X6_DESCRIC
	'Nome do usuario liberado para alteracao de preco'						, ; //X6_DSCSPA
	'Nome do usuario liberado para alteracao de preco'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'RDUCATTI\MARCELO\CLOVIS\ADMINISTRADOR\MARCOS\MARISA\ALEXSANDRA'		, ; //X6_CONTEUD
	'RDUCATTI\MARCELO\CLOVIS\ADMINISTRADOR\MARCOS\MARISA\ALEXSANDRA'		, ; //X6_CONTSPA
	'RDUCATTI\MARCELO\CLOVIS\ADMINISTRADOR\MARCOS\MARISA\ALEXSANDRA'		, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_DANA03'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Codigos do TES que poderao ser alterado o valor de'					, ; //X6_DESCRIC
	'Codigos do TES que poderao ser alterado o valor de'					, ; //X6_DSCSPA
	'Codigos do TES que poderao ser alterado o valor de'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'566/581/578/694/700/710/715/725'	, ; //X6_CONTEUD
	'566/581/578/694/700/710/715/725'	, ; //X6_CONTSPA
	'566/581/578/694/700/710/715/725'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_DESCMAX', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Desconto maximo concedido no preco de venda'							, ; //X6_DESCRIC
	'Desconto maximo concedido no preco de venda'							, ; //X6_DSCSPA
	'Desconto maximo concedido no preco de venda'							, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'0'	, ; //X6_CONTEUD
	'5'	, ; //X6_CONTSPA
	'5'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_DETPROD', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Clientes em que na linha de detalhe do produto na'						, ; //X6_DESCRIC
	'Clientes em que na linha de detalhe do produto na'						, ; //X6_DSCSPA
	'Clientes em que na linha de detalhe do produto na'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'00770/10905/03597/'	, ; //X6_CONTEUD
	'00770/10905/03597/'	, ; //X6_CONTSPA
	'00770/10905/03597/'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_ESTBOL'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Estados para emissao do boleto'	, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'"RS|SC|PR|MG"', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_FRETEAL', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Valor de Frete dos Pedidos recebidos pela ALBRA,'						, ; //X6_DESCRIC
	'Valor de Frete dos Pedidos recebidos pela ALBRA,'						, ; //X6_DSCSPA
	'Valor de Frete dos Pedidos recebidos pela ALBRA,'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'29', ; //X6_CONTEUD
	'29', ; //X6_CONTSPA
	'29', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_GFEBRF'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'1 - Ativado / 2 - Desativado'		, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'Ativacao da performance na rotina de calculo de fr'					, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	'ete. Substituicao de tabela temporaria por variave'					, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'1'	, ; //X6_CONTEUD
	'1'	, ; //X6_CONTSPA
	'1'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_GORDSEP', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Parametro que informa se a ordem de separacao'							, ; //X6_DESCRIC
	'Parametro que informa se a ordem de separacao'							, ; //X6_DSCSPA
	'Parametro que informa se a ordem de separacao'							, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'0'	, ; //X6_CONTEUD
	'0'	, ; //X6_CONTSPA
	'0'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_GS1'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Descricao Grupo 1', ; //X6_DESCRIC
	'Descricao Grupo 1', ; //X6_DSCSPA
	'Descricao Grupo 1', ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'Grupo', ; //X6_CONTEUD
	'Grupo', ; //X6_CONTSPA
	'Grupo', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_GS2'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Descricao Grupo 2', ; //X6_DESCRIC
	'Descricao Grupo 2', ; //X6_DSCSPA
	'Descricao Grupo 2', ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'Sub-Grupo'	, ; //X6_CONTEUD
	'Sub-Grupo'	, ; //X6_CONTSPA
	'Sub-Grupo'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_GS3'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Descricao Grupo 3', ; //X6_DESCRIC
	'Descricao Grupo 3', ; //X6_DSCSPA
	'Descricao Grupo 3', ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'Item', ; //X6_CONTEUD
	'Item', ; //X6_CONTSPA
	'Item', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_HTTPEXT', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'HTTP utilizado pelos programas Extranet'								, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'http:\\endereco', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_LIBCLI'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Este parametro permite incluir os codigos dos clie'					, ; //X6_DESCRIC
	'Este parametro permite incluir os codigos dos clie'					, ; //X6_DSCSPA
	'Este parametro permite incluir os codigos dos clie'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'02634/09999/01405', ; //X6_CONTEUD
	'02634/09999/01405', ; //X6_CONTSPA
	'02634/09999/01405', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_LIMITE1', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Valor Limite para nao considerar na alcada de libe'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'racao de Credito no WF.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'99', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_LIMITE2', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Valor Limite para nao considerar na alcada de libe'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'racao do Credito no WF.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'99', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_LIMQTD'	, ; //X6_VAR
	'N'	, ; //X6_TIPO
	'PERCENTUAL MAXIMO NA QUANTIDADE NO PEDIDO COMPRASC'					, ; //X6_DESCRIC
	'PERCENTUAL MAXIMO NA QUANTIDADE NO PEDIDO COMPRAS'						, ; //X6_DSCSPA
	'PERCENTUAL MAXIMO NA QUANTIDADE NO PEDIDO COMPRAS'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'10', ; //X6_CONTEUD
	'10', ; //X6_CONTSPA
	'10', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_LIMVLR'	, ; //X6_VAR
	'N'	, ; //X6_TIPO
	'PERCENTUAL MAXIMO NO VALOR UNITARIO DO PED. COMPRA'					, ; //X6_DESCRIC
	'PERCENTUAL MAXIMO NO VALOR UNITARIO DO PED. COMPRA'					, ; //X6_DSCSPA
	'PERCENTUAL MAXIMO NO VALOR UNITARIO DO PED. COMPRA'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'1'	, ; //X6_CONTEUD
	'0.5', ; //X6_CONTSPA
	'0.5', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_NATST'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Determina a Tes a ser utilizada de acordo com o Es'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'tado do Cliente.', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'SP', ; //X6_CONTEUD
	'SP', ; //X6_CONTSPA
	'SP', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_NATSU'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Determina aTes a ser utilizada de acordo com o Est'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ado do cliente', ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'RS|MG|PE|SC|PR|AL|RJ|DF', ; //X6_CONTEUD
	'RS|MG|PE|SC|PR|AL|RJ|DF', ; //X6_CONTSPA
	'RS|MG|PE|SC|PR|AL|RJ|DF', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_NATV'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Tipos de NATNOTA usados no relat representantes'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'VE/ST/SU/VI/18/25/EX/CE/ZS/ZF/VS'	, ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_NATZF'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Determina a Tes Utilizada no Pedido de Venda de Ac'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'ordo com o Estado do Cliente'		, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'AM', ; //X6_CONTEUD
	'AM', ; //X6_CONTSPA
	'AM', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_NUMPED'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Numero sequencial de pedidos importados do Palm'						, ; //X6_DESCRIC
	'Numero sequencial de pedidos importados do Palm'						, ; //X6_DSCSPA
	'Numero sequencial de pedidos importados do Palm'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'AAFPFK'	, ; //X6_CONTEUD
	'AAF999'	, ; //X6_CONTSPA
	'AAD195'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_PAR1'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Contem a primeira parte do parametro para exportac'					, ; //X6_DESCRIC
	'Contem a primeira parte do parametro para exportac'					, ; //X6_DSCSPA
	'Contem a primeira parte do parametro para exportac'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'N000000000N0011030001000022000020405000000000000000000000000000000000000000000000000      1111111111111101', ; //X6_CONTEUD
	'N000000000N0011030001000022000020405000000000000000000000000000000000000000000000000      1111111111111101', ; //X6_CONTSPA
	'N000000000N0011030001000022000020405000000000000000000000000000000000000000000000000      1111111111111101', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_PAR2'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Contem a segunda parte dos parametros de Verbas'						, ; //X6_DESCRIC
	'Contem a segunda parte dos parametros de Verbas'						, ; //X6_DSCSPA
	'Contem a segunda parte dos parametros de Verbas'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'11803610000000001       .', ; //X6_CONTEUD
	'11803610000000001       .', ; //X6_CONTSPA
	'11803610000000001       .', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_PRDLIMP', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Grupo de produtos de material de limpeza.Cadastrar'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'da seguinte forma: Ex.:9999|99998|9997'								, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'9201|9901|9999', ; //X6_CONTEUD
	'9201|9901|9999', ; //X6_CONTSPA
	'9201|9901|9999', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_PROCSP'	, ; //X6_VAR
	'L'	, ; //X6_TIPO
	'Indica se a manutencao de stored procedures sera r'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'.T.', ; //X6_CONTEUD
	'.T.', ; //X6_CONTSPA
	'.T.', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_SIN0102', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Parametro que indica qual o Periodo Contabil que'						, ; //X6_DESCRIC
	'Parametro que indica qual o Periodo Contabil que'						, ; //X6_DSCSPA
	'Parametro que indica qual o Periodo Contabil que'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'SSSSSSSSSSSSSSSSS', ; //X6_CONTEUD
	'SSSSSSSSSSSSSSSSS', ; //X6_CONTSPA
	'SSSSSSSSSSSSSSSSS', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_SIN9901', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Parametro que indica qual o Periodo Contabil que'						, ; //X6_DESCRIC
	'Parametro que indica qual o Periodo Contabil que'						, ; //X6_DSCSPA
	'Parametro que indica qual o Periodo Contabil que'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'NNNNNNNNNNNNNNSNN', ; //X6_CONTEUD
	'NNNNNNNNNNNNNNSNN', ; //X6_CONTSPA
	'NNNNNNNNNNNNNNSNN', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_SIN9902', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'.'	, ; //X6_DESCRIC
	'.'	, ; //X6_DSCSPA
	'.'	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'NNNNNNNNNNNNNNNNN', ; //X6_CONTEUD
	'NNNNNNNNNNNNNNNNN', ; //X6_CONTSPA
	'NNNNNNNNNNNNNNNNN', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_TESDESA', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Estes TES estao desativados por solicitacao do Set'					, ; //X6_DESCRIC
	'Estes TES estao desativados por solicitacao do Set'					, ; //X6_DSCSPA
	'Estes TES estao desativados por solicitacao do Set'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'503/508/511/514/570/571/572/573/574/576/577/579/580/581/590/591/593/'		, ; //X6_CONTEUD
	'503/508/511/514/570/571/572/573/574/576/577/579/580/581/590/591/593/'		, ; //X6_CONTSPA
	'503/508/511/514/570/571/572/573/574/576/577/579/580/581/590/591/593/'		, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_TESLIB'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'TES LIBERADA PARA INCLUSAO DE PEDIDOS SEM PED.COMP'					, ; //X6_DESCRIC
	'TES LIBERADA PARA INCLUSAO DE PEDIDOS SEM PED.COMP'					, ; //X6_DSCSPA
	'TES LIBERADA PARA INCLUSAO DE PEDIDOS SEM PED.COMP'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	''	, ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_TESMOS'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Tes utilizado para identificar os TES referente a'						, ; //X6_DESCRIC
	'Tes utilizado para identificar os TES referente a'						, ; //X6_DSCSPA
	'Tes utilizado para identificar os TES referente a'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'663/692'	, ; //X6_CONTEUD
	'663/692'	, ; //X6_CONTSPA
	'663/692'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_TESQTD'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Verifica se existe a quantidade em estoque para os'					, ; //X6_DESCRIC
	'Verifica se existe a quantidade em estoque para os'					, ; //X6_DSCSPA
	'Verifica se existe a quantidade em estoque para os'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'553/554/555/556/557/'	, ; //X6_CONTEUD
	'553/554/555/556/557/'	, ; //X6_CONTSPA
	'553/554/555/556/557/'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_TESTRD'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Tes utilizado para identificar os TES referente a'						, ; //X6_DESCRIC
	'Tes utilizado para identificar os TES referente a'						, ; //X6_DSCSPA
	'Tes utilizado para identificar os TES referente a'						, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'675/', ; //X6_CONTEUD
	'675/', ; //X6_CONTSPA
	'675/', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_TIPOFAT', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Tipo de produtos liberados para pegar o'								, ; //X6_DESCRIC
	'Tipo de produtos liberados para pegar o'								, ; //X6_DSCSPA
	'Tipo de produtos liberados para pegar o'								, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'MH\DV\MA'	, ; //X6_CONTEUD
	'MH\DV\MA'	, ; //X6_CONTSPA
	'MH\DV\MA'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_TMKPRO'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Verifica a promocao em funcao de cliente'								, ; //X6_DESCRIC
	'Verifica a promocao em funcao de cliente'								, ; //X6_DSCSPA
	'Verifica a promocao em funcao de cliente'								, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'S'	, ; //X6_CONTEUD
	'S'	, ; //X6_CONTSPA
	'S'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_TMKRET'	, ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Define qual a quantidade de tentativas padrao para'					, ; //X6_DESCRIC
	'Define qual a quantidade de tentativas padrao para'					, ; //X6_DSCSPA
	'Define qual a quantidade de tentativas padrao para'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'05', ; //X6_CONTEUD
	'05', ; //X6_CONTSPA
	'05', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_URLMSHP', ; //X6_VAR
	'C'	, ; //X6_TIPO
	''	, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'http://mashups-proxy.cloudtotvs.com.br:8055/TOTVSSoa.Host/SOAManager.svc'	, ; //X6_CONTEUD
	'http://mashups-proxy.cloudtotvs.com.br:8055/TOTVSSoa.Host/SOAManager.svc'	, ; //X6_CONTSPA
	'http://mashups-proxy.cloudtotvs.com.br:8055/TOTVSSoa.Host/SOAManager.svc'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_XBLQSA1', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Envia alerta de bloqueio de cadastro de cliente'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'ricardo.brito@danacosmeticos.com.br;emanuela.guillen@danacosmeticos.com.br;carlos.andre@danacosmeticos.com.br', ; //X6_CONTEUD
	'renata.rigo@perfumesdana.com.br;danafin@perfumesdana.com.br'			, ; //X6_CONTSPA
	'renata.rigo@perfumesdana.com.br;danafin@perfumesdana.com.br'			, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_XFISSA1', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Usuarios que podem alterar campos fiscais.'							, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'000000;000004;000140;000158'		, ; //X6_CONTEUD
	'000000;000004;000140;000158'		, ; //X6_CONTSPA
	'000000;000004;000140;000158'		, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_XGRPDPS', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Grupos de tributacao Depilsam sem Retencao'							, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'105/115/116', ; //X6_CONTEUD
	''	, ; //X6_CONTSPA
	''	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_XMAINFE', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Recebe mensagem Alerta NFE com PA e MR'								, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	'Departamento Faturamento', ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'milena.santos@danacosmeticos.com.br;marcelo.lopes@danacosmeticos.com.br'	, ; //X6_CONTEUD
	'clayton.microsiga@gmail.com'		, ; //X6_CONTSPA
	'clayton.microsiga@gmail.com'		, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_XMAISA1', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Recebe mensagem para desbloquear cliente.'								, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	'Departamento Fiscal/Financeiro'	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'ricardo.brito@danacosmeticos.com.br;alessandra.nogueira@danacosmeticos.com.br;emanuela.guillen@danacosmeticos.com.br;', ; //X6_CONTEUD
	'renata.rigo@perfumesdana.com.br;danafin@perfumesdana.com.br'			, ; //X6_CONTSPA
	'renata.rigo@perfumesdana.com.br;danafin@perfumesdana.com.br'			, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'  ', ; //X6_FIL
	'MV_XUSRSA1', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Usuarios que podem lberar cadastro de cliente.'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	''	, ; //X6_DESC1
	'Departamento Financeiro', ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'000000;000004;000140;000026;000158;000126;000063'						, ; //X6_CONTEUD
	'000000;000004;000140;000026;000158;000126;000063'						, ; //X6_CONTSPA
	'000000;000004;000140;000026;000158;000126;000063'						, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'01', ; //X6_FIL
	'DN_PDIFPRC', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Porcentagem aceitavel considerando tabela de preco'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'Produto x Fornecedor'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'1.5', ; //X6_CONTEUD
	'1.5', ; //X6_CONTSPA
	'1.5', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'01', ; //X6_FIL
	'DN_PDIFQTD', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Percentual aceitavel na diferenca da quantidade'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'(Nota Fiscal x Pedido de Compra)'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'10', ; //X6_CONTEUD
	'10', ; //X6_CONTSPA
	'10', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'01', ; //X6_FIL
	'MV_FORNLIB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Fornecedores liberados para entrada de nf sem pedi'					, ; //X6_DESCRIC
	'Fornecedores liberados para entrada de nf sem pedi'					, ; //X6_DSCSPA
	'Fornecedores liberados para entrada de nf sem pedi'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'000052/001278/001306/001223/000770/000528/001029/000892'				, ; //X6_CONTEUD
	'000052/001278/001306/001223/000770/000528/001029/000892'				, ; //X6_CONTSPA
	'000052/001278/001306/001223/000770/000528/001029/000892'				, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'04', ; //X6_FIL
	'MV_FORNLIB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DESCRIC
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DSCSPA
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'800000/09999/000770/000052/000528'	, ; //X6_CONTEUD
	'800000/09999/000770/000052/000528'	, ; //X6_CONTSPA
	'800000/09999/000770/000052/000528'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'05', ; //X6_FIL
	'DN_PDIFPRC', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Porcentagem aceitavel considerando tabela de preco'					, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'Produto x Fornecedor'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'1.5', ; //X6_CONTEUD
	'1.5', ; //X6_CONTSPA
	'1.5', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'05', ; //X6_FIL
	'DN_PDIFQTD', ; //X6_VAR
	'N'	, ; //X6_TIPO
	'Percentual aceitavel na diferenca da quantidade'						, ; //X6_DESCRIC
	''	, ; //X6_DSCSPA
	''	, ; //X6_DSCENG
	'(Nota Fiscal x Pedido de Compra)'	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'10', ; //X6_CONTEUD
	'10', ; //X6_CONTSPA
	'10', ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'05', ; //X6_FIL
	'MV_FORNLIB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DESCRIC
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DSCSPA
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'800000/09999/000770/000052/000528'	, ; //X6_CONTEUD
	'800000/09999/000770/000052/000528'	, ; //X6_CONTSPA
	'800000/09999/000770/000052/000528'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'05', ; //X6_FIL
	'MV_SUBTRIB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Numero da Inscricao Estadual do contribuinte'							, ; //X6_DESCRIC
	'Numero de Inscripcion Provincial del contribuyente'					, ; //X6_DSCSPA
	'Taxpayer State Insc.number in another state when'						, ; //X6_DSCENG
	'em outro estado quando houver Substituicao'							, ; //X6_DESC1
	'en otro estado cuando hubiera Sustitucion'								, ; //X6_DSCSPA1
	'there is Tax Override.', ; //X6_DSCENG1
	'Tributaria', ; //X6_DESC2
	'Tributaria', ; //X6_DSCSPA2
	'.'	, ; //X6_DSCENG2
	'SP714081245114/PR0990702853/MG0030385980060/SC258453460/AP030576113/RJ92048470/RS9000035835/', ; //X6_CONTEUD
	'SP714081245114/PR0990702853/MG0030385980060/SC258453460/'				, ; //X6_CONTSPA
	'SP714081245114/PR0990702853/MG0030385980060/SC258453460/'				, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'06', ; //X6_FIL
	'MV_FORNLIB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DESCRIC
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DSCSPA
	'Fornecedores liberados para entrada de notas fisca'					, ; //X6_DSCENG
	''	, ; //X6_DESC1
	''	, ; //X6_DSCSPA1
	''	, ; //X6_DSCENG1
	''	, ; //X6_DESC2
	''	, ; //X6_DSCSPA2
	''	, ; //X6_DSCENG2
	'800000/09999/000770/000052/000528'	, ; //X6_CONTEUD
	'800000/09999/000770/000052/000528'	, ; //X6_CONTSPA
	'800000/09999/000770/000052/000528'	, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

aAdd( aSX6, { ;
	'06', ; //X6_FIL
	'MV_SUBTRIB', ; //X6_VAR
	'C'	, ; //X6_TIPO
	'Numero da Inscricao Estadual do contribuinte'							, ; //X6_DESCRIC
	'Numero de Inscripcion Provincial del contribuyente'					, ; //X6_DSCSPA
	'Taxpayer State Insc.number in another state when'						, ; //X6_DSCENG
	'em outro estado quando houver Substituicao'							, ; //X6_DESC1
	'en otro estado cuando hubiera Sustitucion'								, ; //X6_DSCSPA1
	'there is Tax Override.', ; //X6_DSCENG1
	'Tributaria', ; //X6_DESC2
	'Tributaria', ; //X6_DSCSPA2
	'.'	, ; //X6_DSCENG2
	'SP714081245114/PR0990702853/MG0030385980060/SC258453460/AP030576113/RJ92048470/RS9000035835/', ; //X6_CONTEUD
	'SP714081245114/PR0990702853/MG0030385980060/SC258453460/'				, ; //X6_CONTSPA
	'SP714081245114/PR0990702853/MG0030385980060/SC258453460/'				, ; //X6_CONTENG
	'U'	, ; //X6_PROPRI
	''	, ; //X6_VALID
	''	, ; //X6_INIT
	''	, ; //X6_DEFPOR
	''	, ; //X6_DEFSPA
	''	, ; //X6_DEFENG
	''	} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  09/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo WS6_CODIGO
//
aAdd( aSX7, { ;
	'WS6_CODIGO', ; //X7_CAMPO
	'001', ; //X7_SEQUENC
	'WS5->WS5_CAMPO', ; //X7_REGRA
	'WS6_CAMPO'	, ; //X7_CDOMIN
	'P'	, ; //X7_TIPO
	'S'	, ; //X7_SEEK
	'WS5', ; //X7_ALIAS
	1	, ; //X7_ORDEM
	'XFILIAL("WS6")+M->WS6_CODIGO'		, ; //X7_CHAVE
	'U'	, ; //X7_PROPRI
	''	} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXA
Função de processamento da gravação do SXA - Pastas

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXA()
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nPosAgr   := 0
Local lAlterou  := .F.

AutoGrLog( "Ínicio da Atualização" + " SXA" + CRLF )

aEstrut := { "XA_ALIAS"  , "XA_ORDEM"  , "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_AGRUP"  , "XA_TIPO"   , ;
             "XA_PROPRI" }


//
// Tabela SB4
//
aAdd( aSXA, { ;
	'SB4', ; //XA_ALIAS
	'1'	, ; //XA_ORDEM
	'Dados Produto', ; //XA_DESCRIC
	'Dados Produto', ; //XA_DESCSPA
	'Dados Produto', ; //XA_DESCENG
	''	, ; //XA_AGRUP
	''	, ; //XA_TIPO
	'U'	} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB4', ; //XA_ALIAS
	'2'	, ; //XA_ORDEM
	'Preços'	, ; //XA_DESCRIC
	'Preços'	, ; //XA_DESCSPA
	'Preços'	, ; //XA_DESCENG
	''	, ; //XA_AGRUP
	''	, ; //XA_TIPO
	'U'	} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB4', ; //XA_ALIAS
	'3'	, ; //XA_ORDEM
	'Impostos'	, ; //XA_DESCRIC
	'Impostos'	, ; //XA_DESCSPA
	'Impostos'	, ; //XA_DESCENG
	''	, ; //XA_AGRUP
	''	, ; //XA_TIPO
	'U'	} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB4', ; //XA_ALIAS
	'4'	, ; //XA_ORDEM
	'Dimensoes'	, ; //XA_DESCRIC
	'Dimensoes'	, ; //XA_DESCSPA
	'Dimensoes'	, ; //XA_DESCENG
	''	, ; //XA_AGRUP
	''	, ; //XA_TIPO
	'U'	} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB4', ; //XA_ALIAS
	'5'	, ; //XA_ORDEM
	'Fotos', ; //XA_DESCRIC
	'Fotos', ; //XA_DESCSPA
	'Fotos', ; //XA_DESCENG
	''	, ; //XA_AGRUP
	''	, ; //XA_TIPO
	'U'	} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB4', ; //XA_ALIAS
	'6'	, ; //XA_ORDEM
	'e-Commerce', ; //XA_DESCRIC
	'e-Commerce', ; //XA_DESCSPA
	'e-Commerce', ; //XA_DESCENG
	''	, ; //XA_AGRUP
	''	, ; //XA_TIPO
	'U'	} ) //XA_PROPRI

//
// Tabela SC5
//
aAdd( aSXA, { ;
	'SC5', ; //XA_ALIAS
	'1'	, ; //XA_ORDEM
	'Sigvaris'	, ; //XA_DESCRIC
	'Sigvaris'	, ; //XA_DESCSPA
	'Sigvaris'	, ; //XA_DESCENG
	''	, ; //XA_AGRUP
	''	, ; //XA_TIPO
	'U'	} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SC5', ; //XA_ALIAS
	'2'	, ; //XA_ORDEM
	'e-Commerce', ; //XA_DESCRIC
	'e-Commerce', ; //XA_DESCSPA
	'e-Commerce', ; //XA_DESCENG
	''	, ; //XA_AGRUP
	''	, ; //XA_TIPO
	'U'	} ) //XA_PROPRI

nPosAgr := aScan( aEstrut, { |x| AllTrim( x ) == "XA_AGRUP" } )

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		lAlterou := .F.

		While !SXA->( EOF() ).AND.  SXA->( XA_ALIAS + XA_ORDEM ) == aSXA[nI][1] + aSXA[nI][2]

			If SXA->XA_AGRUP == aSXA[nI][nPosAgr]
				RecLock( "SXA", .F. )
				For nJ := 1 To Len( aSXA[nI] )
					If FieldPos( aEstrut[nJ] ) > 0 .AND. Alltrim(AllToChar(SXA->( FieldGet( nJ ) ))) <> Alltrim(AllToChar(aSXA[nI][nJ]))
						FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
						lAlterou := .T.
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
			EndIf

			SXA->( dbSkip() )

		End

		If lAlterou
			AutoGrLog( "Foi alterada a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )
		EndIf

	Else

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )

	EndIf

oProcess:IncRegua2( "Atualizando Arquivos (SXA)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  09/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta AY0
//
aAdd( aSXB, { ;
	'AY0', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'CATEGORIA'	, ; //XB_DESCRI
	'CATEGORIA'	, ; //XB_DESCSPA
	'CATEGORIA'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0', ; //XB_ALIAS
	'3'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cadastra Novo', ; //XB_DESCRI
	'Incluye Nuevo', ; //XB_DESCSPA
	'Add New'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'01'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

//
// Consulta AY01
//
aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categoria 1', ; //XB_DESCRI
	'Categoria 1', ; //XB_DESCSPA
	'Categoria 1', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01', ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "1"'	} ) //XB_CONTEM

//
// Consulta AY02
//
aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categoria 1', ; //XB_DESCRI
	'Categoria 1', ; //XB_DESCSPA
	'Categoria 1', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02', ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "2"'	} ) //XB_CONTEM

//
// Consulta AY03
//
aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categoria 1', ; //XB_DESCRI
	'Categoria 1', ; //XB_DESCSPA
	'Categoria 1', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03', ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "3"'	} ) //XB_CONTEM

//
// Consulta AY04
//
aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categoria 1', ; //XB_DESCRI
	'Categoria 1', ; //XB_DESCSPA
	'Categoria 1', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04', ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "4"'	} ) //XB_CONTEM

//
// Consulta AY05
//
aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categoria 1', ; //XB_DESCRI
	'Categoria 1', ; //XB_DESCSPA
	'Categoria 1', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05', ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "5"'	} ) //XB_CONTEM

//
// Consulta AY0CA3
//
aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Secao', ; //XB_DESCRI
	'Secao', ; //XB_DESCSPA
	'Secao', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO=="3"'	} ) //XB_CONTEM

//
// Consulta AY0CA4
//
aAdd( aSXB, { ;
	'AY0CA4'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Especie'	, ; //XB_DESCRI
	'Especie'	, ; //XB_DESCSPA
	'Especie'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(MV_PAR03)'							} ) //XB_CONTEM

//
// Consulta AY0DEP
//
aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Depto', ; //XB_DESCRI
	'Consulta Depto', ; //XB_DESCSPA
	'Consulta Depto', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Tipo', ; //XB_DESCRI
	'Tipo', ; //XB_DESCSPA
	'Tipo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_TIPO'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Tipo', ; //XB_DESCRI
	'Tipo', ; //XB_DESCSPA
	'Tipo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_TIPO'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO=="1"'	} ) //XB_CONTEM

//
// Consulta AY0NV1
//
aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categorias Nivel 1'	, ; //XB_DESCRI
	'Categorias Nivel 1'	, ; //XB_DESCSPA
	'Categorias Nivel 1'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "1"'	} ) //XB_CONTEM

//
// Consulta AY0NV2
//
aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categorias Nivel 2'	, ; //XB_DESCRI
	'Categorias Nivel 2'	, ; //XB_DESCSPA
	'Categorias Nivel 2'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "2"'	} ) //XB_CONTEM

//
// Consulta AY0NV3
//
aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categorias Nivel 3'	, ; //XB_DESCRI
	'Categorias Nivel 3'	, ; //XB_DESCSPA
	'Categorias Nivel 3'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "3"'	} ) //XB_CONTEM

//
// Consulta AY0NV4
//
aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categorias Nivel 4'	, ; //XB_DESCRI
	'Categorias Nivel 4'	, ; //XB_DESCSPA
	'Categorias Nivel 4'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "4"'	} ) //XB_CONTEM

//
// Consulta AY0NV5
//
aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Categorias Nivel 5'	, ; //XB_DESCRI
	'Categorias Nivel 5'	, ; //XB_DESCSPA
	'Categorias Nivel 5'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "5"'	} ) //XB_CONTEM

//
// Consulta AY1
//
aAdd( aSXB, { ;
	'AY1', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'RE', ; //XB_COLUNA
	'Consulta Categorias'	, ; //XB_DESCRI
	'Consulta Categorias'	, ; //XB_DESCSPA
	'Consulta Categorias'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'T_SYVC008()'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'T_SYVC008A()'} ) //XB_CONTEM

//
// Consulta AY1ESP
//
aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Espécie', ; //XB_DESCRI
	'Consulta Espécie', ; //XB_DESCSPA
	'Consulta Espécie', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->B5_XCAT03)'						} ) //XB_CONTEM

//
// Consulta AY1GRP
//
aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Grupos', ; //XB_DESCRI
	'Consulta Grupos', ; //XB_DESCSPA
	'Consulta Grupos', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'04', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'04', ; //XB_SEQ
	'01', ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT1)'						} ) //XB_CONTEM

//
// Consulta AY1LIN
//
aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Linha', ; //XB_DESCRI
	'Consulta Linha', ; //XB_DESCSPA
	'Consulta Linha', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->B5_XCAT01)'						} ) //XB_CONTEM

//
// Consulta AY1SEC
//
aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Seção', ; //XB_DESCRI
	'Consulta Seção', ; //XB_DESCSPA
	'Consulta Seção', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->B5_XCAT02)'						} ) //XB_CONTEM

//
// Consulta AY1SUB
//
aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta SubTipo', ; //XB_DESCRI
	'Consulta SubTipo', ; //XB_DESCSPA
	'Consulta SubTipo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'04', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'04', ; //XB_SEQ
	'01', ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->B5_XCAT04)'						} ) //XB_CONTEM

//
// Consulta AY1TIP
//
aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Tipo', ; //XB_DESCRI
	'Consulta Tipo', ; //XB_DESCSPA
	'Consulta Tipo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'04', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'04', ; //XB_SEQ
	'01', ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT2)'						} ) //XB_CONTEM

//
// Consulta AY2
//
aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Cadastro de Marcas'	, ; //XB_DESCRI
	'Cadastro de Marcas'	, ; //XB_DESCSPA
	'Cadastro de Marcas'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY2'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Codigo'	, ; //XB_DESCRI
	'Codigo'	, ; //XB_DESCSPA
	'Codigo'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Codigo'	, ; //XB_DESCRI
	'Codigo'	, ; //XB_DESCSPA
	'Codigo'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Codigo'	, ; //XB_DESCRI
	'Codigo'	, ; //XB_DESCSPA
	'Codigo'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY2_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY2_DESCR'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY2_DESCR'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Codigo'	, ; //XB_DESCRI
	'Codigo'	, ; //XB_DESCSPA
	'Codigo'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY2_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY2->AY2_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY2->AY2_DESCR'} ) //XB_CONTEM

//
// Consulta AY3
//
aAdd( aSXB, { ;
	'AY3', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'CARACTERISTICAS', ; //XB_DESCRI
	'CARACTERISTICAS', ; //XB_DESCSPA
	'CARACTERISTICAS', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY3'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Caract.', ; //XB_DESCRI
	'Cod. Caract.', ; //XB_DESCSPA
	'Cod. Caract.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3', ; //XB_ALIAS
	'3'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cadastra Novo', ; //XB_DESCRI
	'Cadastra Novo', ; //XB_DESCSPA
	'Cadastra Novo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'01'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Caract.', ; //XB_DESCRI
	'Cod. Caract.', ; //XB_DESCSPA
	'Cod. Caract.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY3_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descric. Erp', ; //XB_DESCRI
	'Descric. Erp', ; //XB_DESCSPA
	'Descric. Erp', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY3_DESCRI'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY3->AY3_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY3->AY3_DESCRI'} ) //XB_CONTEM

//
// Consulta AY3DEP
//
aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Depto AY3'	, ; //XB_DESCRI
	'Consulta Depto AY3'	, ; //XB_DESCSPA
	'Consulta Depto AY3'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Tipo', ; //XB_DESCRI
	'Tipo', ; //XB_DESCSPA
	'Tipo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_TIPO'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Tipo', ; //XB_DESCRI
	'Tipo', ; //XB_DESCSPA
	'Tipo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_TIPO'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_TIPO=="4"'	} ) //XB_CONTEM

//
// Consulta AY3GRP
//
aAdd( aSXB, { ;
	'AY3GRP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Grupos AY3'	, ; //XB_DESCRI
	'Consulta Grupos AY3'	, ; //XB_DESCSPA
	'Consulta Grupos AY3'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AY3_CAT1)'						} ) //XB_CONTEM

//
// Consulta AY3SUB
//
aAdd( aSXB, { ;
	'AY3SUB'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta SubTipo AY3'	, ; //XB_DESCRI
	'Consulta SubTipo AY3'	, ; //XB_DESCSPA
	'Consulta SubTipo AY3'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AY3_01CAT3)'						} ) //XB_CONTEM

//
// Consulta AY3TIP
//
aAdd( aSXB, { ;
	'AY3TIP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Tipo AY3', ; //XB_DESCRI
	'Consulta Tipo AY3', ; //XB_DESCSPA
	'Consulta Tipo AY3', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AY3_CAT2)'						} ) //XB_CONTEM

//
// Consulta AY4
//
aAdd( aSXB, { ;
	'AY4', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'VALOR CARACTERISTICA'	, ; //XB_DESCRI
	'VALOR CARACTERISTICA'	, ; //XB_DESCSPA
	'VALOR CARACTERISTICA'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Caract.+sequenc'	, ; //XB_DESCRI
	'Cod. Caract.+sequenc'	, ; //XB_DESCSPA
	'Cod. Caract.+sequenc'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sequencia'	, ; //XB_DESCRI
	'Sequencia'	, ; //XB_DESCSPA
	'Sequencia'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4_SEQ'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Valor Caract', ; //XB_DESCRI
	'Valor Caract', ; //XB_DESCSPA
	'Valor Caract', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4_VALOR'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4->AY4_SEQ'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4', ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4->AY4_CODCAR==GdFieldGet("AY5_CODIGO")'								} ) //XB_CONTEM

//
// Consulta AY4_2
//
aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Valor Caracteristica'	, ; //XB_DESCRI
	'Valor Caracteristica'	, ; //XB_DESCSPA
	'Valor Caracteristica'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Valor Caract+sequenc'	, ; //XB_DESCRI
	'Valor Caract+sequenc'	, ; //XB_DESCSPA
	'Valor Caract+sequenc'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'04', ; //XB_COLUNA
	'Sequencia + Valor Ca'	, ; //XB_DESCRI
	'Sequencia + Valor Ca'	, ; //XB_DESCSPA
	'Sequencia + Valor Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'3'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cadastra Novo', ; //XB_DESCRI
	'Incluye Nuevo', ; //XB_DESCSPA
	'Add New'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	"01# T_SSVLRCAR('AY4',AY4->(Recno()),4)"								} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Valor Caract', ; //XB_DESCRI
	'Valor Caract', ; //XB_DESCSPA
	'Valor Caract', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4_VALOR'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sequencia'	, ; //XB_DESCRI
	'Sequencia'	, ; //XB_DESCSPA
	'Sequencia'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4_SEQ'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sequencia'	, ; //XB_DESCRI
	'Sequencia'	, ; //XB_DESCSPA
	'Sequencia'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4_SEQ'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Valor Caract', ; //XB_DESCRI
	'Valor Caract', ; //XB_DESCSPA
	'Valor Caract', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4_VALOR'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4->AY4_SEQ'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2', ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY4->AY4_CODCAR == T_RETCARAC()'	} ) //XB_CONTEM

//
// Consulta AYVDEP
//
aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Grupo', ; //XB_DESCRI
	'Consulta Grupo', ; //XB_DESCSPA
	'Consulta Grupo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Tipo', ; //XB_DESCRI
	'Tipo', ; //XB_DESCSPA
	'Tipo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_TIPO'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Descricao'	, ; //XB_DESCRI
	'Descricao'	, ; //XB_DESCSPA
	'Descricao'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_DESC'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Tipo', ; //XB_DESCRI
	'Tipo', ; //XB_DESCSPA
	'Tipo', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0_TIPO'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY0->AY0_DESC'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	"AY0->AY0_TIPO=='1'"	} ) //XB_CONTEM

//
// Consulta AYVGRP
//
aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Linha', ; //XB_DESCRI
	'Consulta Linha', ; //XB_DESCSPA
	'Consulta Linha', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT1)'						} ) //XB_CONTEM

//
// Consulta AYVSUB
//
aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Especie', ; //XB_DESCRI
	'Consulta Especie', ; //XB_DESCSPA
	'Consulta Especie', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT3)'						} ) //XB_CONTEM

//
// Consulta AYVTIP
//
aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'DB', ; //XB_COLUNA
	'Consulta Secao', ; //XB_DESCRI
	'Consulta Secao', ; //XB_DESCSPA
	'Consulta Secao', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Descricao+sub.catego'	, ; //XB_DESCRI
	'Descricao+sub.catego'	, ; //XB_DESCSPA
	'Descricao+sub.catego'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	''	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'	, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_002'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'	, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_001'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'01', ; //XB_COLUNA
	'Cod. Categ.', ; //XB_DESCRI
	'Cod. Categ.', ; //XB_DESCSPA
	'Cod. Categ.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_CODIGO'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'02', ; //XB_COLUNA
	'Sub.Categor.', ; //XB_DESCRI
	'Sub.Categor.', ; //XB_DESCSPA
	'Sub.Categor.', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'4'	, ; //XB_TIPO
	'03', ; //XB_SEQ
	'03', ; //XB_COLUNA
	'Desc.Sub.Cat', ; //XB_DESCRI
	'Desc.Sub.Cat', ; //XB_DESCSPA
	'Desc.Sub.Cat', ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'02', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'	, ; //XB_ALIAS
	'6'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT2)'						} ) //XB_CONTEM

//
// Consulta BMPRET
//
aAdd( aSXB, { ;
	'BMPRET'	, ; //XB_ALIAS
	'1'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'RE', ; //XB_COLUNA
	'Retorna Imagem Statu'	, ; //XB_DESCRI
	'Retorna Imagem Statu'	, ; //XB_DESCSPA
	'Retorna Imagem Statu'	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'WS1'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'BMPRET'	, ; //XB_ALIAS
	'2'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	'01', ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'U_ECLJM001()'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'BMPRET'	, ; //XB_ALIAS
	'5'	, ; //XB_TIPO
	'01', ; //XB_SEQ
	''	, ; //XB_COLUNA
	''	, ; //XB_DESCRI
	''	, ; //XB_DESCSPA
	''	, ; //XB_DESCENG
	''	, ; //XB_WCONTEM
	'U_ABitRet()'} ) //XB_CONTEM


//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

							If !( aSXB[nI][1] $ cAlias )
								cAlias += aSXB[nI][1] + "/"
								AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
							EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela AY0
//
//
// Helps Tabela AY2
//
aHlpPor := {}
aAdd( aHlpPor, 'Id Marca' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PAY2_XIDMAR", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "AY2_XIDMAR" )

//
// Helps Tabela AY3
//
aHlpPor := {}
aAdd( aHlpPor, 'Data Exportação eCommerce.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PAY3_XDTEXP", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "AY3_XDTEXP" )

aHlpPor := {}
aAdd( aHlpPor, 'Hora Exportacao eCommerce' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PAY3_XHREXP", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "AY3_XHREXP" )

//
// Helps Tabela AY4
//
aHlpPor := {}
aAdd( aHlpPor, 'Data Exporta eCommerce' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PAY4_XDTEXP", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "AY4_XDTEXP" )

aHlpPor := {}
aAdd( aHlpPor, 'Hora Exportacao eCommerce' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PAY4_XHREXP", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "AY4_XHREXP" )

//
// Helps Tabela SA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Nome ou razão social do cliente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_NOME   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_NOME" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Cliente :' )
aAdd( aHlpPor, 'Opções Brasil (L,F,R,S,X):' )
aAdd( aHlpPor, 'L - Produtor Rural; F - Cons.Final;' )
aAdd( aHlpPor, 'R - Revendedor; S - ICMS Solidário sem' )
aAdd( aHlpPor, 'IPI na base; X - Exportação.' )
aAdd( aHlpPor, 'Outros Países :' )
aAdd( aHlpPor, 'Verificar opções disponíveis' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_TIPO   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Deve ser preenchido apenas com L,F,R,S' )
aAdd( aHlpPor, 'ou X (Brasil) ou com opções diponiveis' )
aAdd( aHlpPor, 'para o pais em uso' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "SA1_TIPO   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado a solução do campo " + "A1_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço de cobrança do cliente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_ENDCOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDCOB" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço de entrega do cliente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_ENDENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDENT" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço da central de compras do' )
aAdd( aHlpPor, 'cliente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_ENDREC ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDREC" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual apresentado  como  default na' )
aAdd( aHlpPor, 'tela do pedido para cálculo de comissão.' )
aAdd( aHlpPor, 'Tem  prioridade  sobre  o % informado no' )
aAdd( aHlpPor, 'cadastro de  vendedor, porém não sobre o' )
aAdd( aHlpPor, '% informado no produto.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_COMIS  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_COMIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de frete do cliente.' )
aAdd( aHlpPor, 'C = CIF   F = FOB' )
aAdd( aHlpPor, 'Campo Informativo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_TPFRET ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TPFRET" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de desconto padrão  concedido' )
aAdd( aHlpPor, 'ao cliente como sugestão a cada' )
aAdd( aHlpPor, 'faturamento.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_DESC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Prioridade de atendimento do cliente' )
aAdd( aHlpPor, 'face sua contribuição com a empresa.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_PRIOR  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_PRIOR" )

aHlpPor := {}
aAdd( aHlpPor, 'Grau de Risco na aprovação do Crédito do' )
aAdd( aHlpPor, 'Cliente em Pedidos de Venda (A,B,C,D,E):' )
aAdd( aHlpPor, 'A: Crédito Ok;' )
aAdd( aHlpPor, 'B,C e D: Liberação definida através dos' )
aAdd( aHlpPor, 'parâmetros: MV_RISCO(B,C,D);' )
aAdd( aHlpPor, 'E: Liberação manual;' )
aAdd( aHlpPor, 'Z: Liberação através de integração com' )
aAdd( aHlpPor, 'software de terceiro.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_RISCO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_RISCO" )

aHlpPor := {}
aAdd( aHlpPor, 'Limite de crédito estabelecido para o' )
aAdd( aHlpPor, 'cliente. Valor armazenado na moeda forte' )
aAdd( aHlpPor, 'definida no campo A1_MOEDALC. Default' )
aAdd( aHlpPor, 'moeda 2.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_LC     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_LC" )

aHlpPor := {}
aAdd( aHlpPor, 'Limite de credito secundario.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_LCFIN  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_LCFIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Somatória dos valores em atraso  levando' )
aAdd( aHlpPor, 'em consideração o número de dias' )
aAdd( aHlpPor, 'definidos no risco do cliente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_ATR    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ATR" )

aHlpPor := {}
aAdd( aHlpPor, 'Número de títulos protestados  do' )
aAdd( aHlpPor, 'cliente. Campo informativo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_TITPROT", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TITPROT" )

aHlpPor := {}
aAdd( aHlpPor, 'Número de cheques devolvidos do cliente.' )
aAdd( aHlpPor, 'Deve ser informado pelo usuário. É' )
aAdd( aHlpPor, 'apresentado por ocasião da liberação de' )
aAdd( aHlpPor, 'crédito. Campo informativo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_CHQDEVO", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CHQDEVO" )

aHlpPor := {}
aAdd( aHlpPor, 'Se o ISS estiver embutido no preço,' )
aAdd( aHlpPor, 'informar "S", se desejar incluir o ISS' )
aAdd( aHlpPor, 'no total da NF, informar "N".' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_INCISS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_INCISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Alíquota de Imposto de Renda Retido  na' )
aAdd( aHlpPor, 'Fonte.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_ALIQIR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ALIQIR" )

aHlpPor := {}
aAdd( aHlpPor, 'Informar  se  deve  calcular  ou  não o' )
aAdd( aHlpPor, 'desconto de 7% para clientes com código' )
aAdd( aHlpPor, 'SUFRAMA.' )
aAdd( aHlpPor, 'VALIDAÇÄO:' )
aAdd( aHlpPor, '(N) - Não efetua o cálculo do desconto' )
aAdd( aHlpPor, 'SUFRAMA' )
aAdd( aHlpPor, '(Branco),(S) - Calcula o Desconto de' )
aAdd( aHlpPor, 'Pis, Cofins e ICMS, dependendo da' )
aAdd( aHlpPor, 'configuração no cadastro do produto.' )
aAdd( aHlpPor, '(I) - Calcula o desconto apenas' )
aAdd( aHlpPor, 'referente ao ICMS, não calculando o' )
aAdd( aHlpPor, 'desconto para Pis e Cofins, também' )
aAdd( aHlpPor, 'dependendo da configuração no cadastro' )
aAdd( aHlpPor, 'do produto para permitir o cálculo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_CALCSUF", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CALCSUF" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Cliente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_TIPOCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TIPOCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Informa a data de exportação do' )
aAdd( aHlpPor, 'registro.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_MSEXP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_MSEXP" )

aHlpPor := {}
aAdd( aHlpPor, 'Login Portal' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_XLOGIN ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XLOGIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Senha Portal' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_XSENHA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XSENHA" )

//
// Helps Tabela SA4
//
aHlpPor := {}
aAdd( aHlpPor, 'Razão Social ou nome da transportadora.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA4_NOME   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_NOME" )

aHlpPor := {}
aAdd( aHlpPor, 'É o nome  reduzido pelo qual a' )
aAdd( aHlpPor, 'transportadora é mais conhecida dentro' )
aAdd( aHlpPor, 'da empresa. Auxilia  nas  consultas e' )
aAdd( aHlpPor, 'relatórios do sistema.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA4_NREDUZ ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_NREDUZ" )

aHlpPor := {}
aAdd( aHlpPor, 'Via de Transporte' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA4_VIA    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_VIA" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço da transportadora.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA4_END    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_END" )

aHlpPor := {}
aAdd( aHlpPor, 'Município da transportadora.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA4_MUN    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_MUN" )

aHlpPor := {}
aAdd( aHlpPor, 'Código de endereçamento postal da' )
aAdd( aHlpPor, 'transportadora.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA4_CEP    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_CEP" )

aHlpPor := {}
aAdd( aHlpPor, 'Nome do contato da empresa na' )
aAdd( aHlpPor, 'transpor-tadora.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA4_CONTATO", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_CONTATO" )

//
// Helps Tabela SB1
//
aHlpPor := {}
aAdd( aHlpPor, 'Descrição do produto.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_DESC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de IPI a ser aplicado sobre o' )
aAdd( aHlpPor, 'produto, de acordo com a posição do IPI.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_IPI    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_IPI" )

aHlpPor := {}
aAdd( aHlpPor, 'Código de Serviço do ISS, utilizado para' )
aAdd( aHlpPor, 'discriminar a operação perante o' )
aAdd( aHlpPor, 'município tributador.' )
aAdd( aHlpPor, 'Tecla [F3] Disponível.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_CODISS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_CODISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Margem de Lucro para cálculo do ICMS' )
aAdd( aHlpPor, 'Solidário ou Retido.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_PICMRET", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PICMRET" )

aHlpPor := {}
aAdd( aHlpPor, 'Porcentual que define o lucro para' )
aAdd( aHlpPor, 'cálculo do ICMS Solidario na entrada.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_PICMENT", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PICMENT" )

aHlpPor := {}
aAdd( aHlpPor, 'Fator de Conversao da 1aUM para a 2aUM.' )
aAdd( aHlpPor, 'Todas as Rotinas de Entrada, Saida e' )
aAdd( aHlpPor, 'Movimentacao interna possuem campos para' )
aAdd( aHlpPor, 'a digitacao nas 2 unidades de Medida. Se' )
aAdd( aHlpPor, 'um Fator de Conversao for cadastrado,' )
aAdd( aHlpPor, 'somente um deles precisa ser digitado, o' )
aAdd( aHlpPor, 'sistema calcula a outra unidade de' )
aAdd( aHlpPor, 'medida com base neste Fator de Conversao' )
aAdd( aHlpPor, 'e preenche o outro campo' )
aAdd( aHlpPor, 'automaticamente.' )
aAdd( aHlpPor, 'Se nenhum Fator se Conversao for' )
aAdd( aHlpPor, 'atribuido os 2 campos deverao ser' )
aAdd( aHlpPor, 'preenchidos manualmente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_CONV   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_CONV" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade padrão inferior ao lote' )
aAdd( aHlpPor, 'econômico a ser considerada para COMPRA,' )
aAdd( aHlpPor, 'de modo que se incorra no custo minimo e' )
aAdd( aHlpPor, 'obtenha-se utilidades maximas. Qdo o' )
aAdd( aHlpPor, 'produto for fabricado utilize o lote' )
aAdd( aHlpPor, 'minimo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_QE     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_QE" )

aHlpPor := {}
aAdd( aHlpPor, 'Preço de venda do produto. Existe mais 6' )
aAdd( aHlpPor, 'tabelas no arquivo SB5 (Dados' )
aAdd( aHlpPor, 'Adicionaisdo Produto).' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_PRV1   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PRV1" )

aHlpPor := {}
aAdd( aHlpPor, 'Ponto de pedido. Quantidade mínima' )
aAdd( aHlpPor, 'pré-estabelecida que, uma vez atingida,' )
aAdd( aHlpPor, 'gera emissão automática de uma' )
aAdd( aHlpPor, 'solicitação de compras ou ordem de' )
aAdd( aHlpPor, 'produção.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_EMIN   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_EMIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Estoque de segurança. Quantidade' )
aAdd( aHlpPor, 'mínimade produto em estoque para evitar' )
aAdd( aHlpPor, 'a falta do mesmo entre a solicitação de' )
aAdd( aHlpPor, 'compra ou produção e o seu recebimento.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_ESTSEG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_ESTSEG" )

aHlpPor := {}
aAdd( aHlpPor, 'Prazo de entrega do produto. É o' )
aAdd( aHlpPor, 'númerode dias, meses ou anos que o' )
aAdd( aHlpPor, 'fornecedor ou a fábrica necessita para' )
aAdd( aHlpPor, 'entregar o  produto, a partir do' )
aAdd( aHlpPor, 'recebimento de seu pedido.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_PE     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PE" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do prazo de entrega. Informar se' )
aAdd( aHlpPor, 'oprazo será em horas (H), dias (D),' )
aAdd( aHlpPor, 'sema-nas (S), meses (M) ou ano (A). Este' )
aAdd( aHlpPor, 'cam-po deve estar em acordo com o campo' )
aAdd( aHlpPor, 'PRAZO DE ENTREGA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_TIPE   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_TIPE" )

aHlpPor := {}
aAdd( aHlpPor, 'Lote econômico do produto. Quantidade' )
aAdd( aHlpPor, 'padrão a ser comprada de uma só vez ou a' )
aAdd( aHlpPor, 'ser produzida em uma só operação, de' )
aAdd( aHlpPor, 'modo que se incorra no custo mínimo e' )
aAdd( aHlpPor, 'obtenha-se utilidades máximas.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_LE     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_LE" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade padrão inferior ao lote' )
aAdd( aHlpPor, 'econômico a ser considerada para' )
aAdd( aHlpPor, 'PRODUÇÃO, de modo que se incorra no' )
aAdd( aHlpPor, 'custo minimo e obtenha-se utilidades' )
aAdd( aHlpPor, 'máximas. Quando o produto for comprado' )
aAdd( aHlpPor, 'utilize quantidade por embalagem.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_LM     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_LM" )

aHlpPor := {}
aAdd( aHlpPor, 'Apropriacao Direta ou Indireta de' )
aAdd( aHlpPor, 'material.' )
aAdd( aHlpPor, 'Produtos de Pequeno Valor Agregado,' )
aAdd( aHlpPor, 'Grande Giro e/ou Dificil Quantificacao' )
aAdd( aHlpPor, 'podem utilizar a Apropriacao indireta.' )
aAdd( aHlpPor, 'Exemplo:' )
aAdd( aHlpPor, '========' )
aAdd( aHlpPor, 'Definimos que na montagem de 1 Cadeira' )
aAdd( aHlpPor, 'utilizam-se 8 Parafusos.' )
aAdd( aHlpPor, 'Parafusos com APROPRIACAO DIRETA:' )
aAdd( aHlpPor, 'Durante o dia cada Ordem de Producao de' )
aAdd( aHlpPor, '1 Cadeira ira Requisitar 8 parafusos do' )
aAdd( aHlpPor, 'Armazem Padrao; na pratica o funcionario' )
aAdd( aHlpPor, 'devera se dirigir ao Almoxarife com uma' )
aAdd( aHlpPor, 'requisicao de 8 parafusos cada vez que' )
aAdd( aHlpPor, 'for montar 1 cadeira.' )
aAdd( aHlpPor, 'Parafusos com APROPRIACAO INDIRETA: No' )
aAdd( aHlpPor, 'inicio do dia é feita uma Requisicao' )
aAdd( aHlpPor, 'Manual de 1 Caixa de Parafusos (1000' )
aAdd( aHlpPor, 'Parafusos). Esta Requisicao ira fazer' )
aAdd( aHlpPor, 'com que estes 1000 parafusos sejam' )
aAdd( aHlpPor, 'transferidos para o Armazem de Processo' )
aAdd( aHlpPor, '(definido no MV_LOCPROC). Cada OP de 1' )
aAdd( aHlpPor, 'Cadeira irá requisitar 8 parafusos do' )
aAdd( aHlpPor, 'Armazem de Processo; na pratica a caixa' )
aAdd( aHlpPor, 'de parafusos ja tera sido requisitada e' )
aAdd( aHlpPor, 'estara disponivel para que o funcionario' )
aAdd( aHlpPor, 'pegue os 8 parafusos.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_APROPRI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_APROPRI" )

aHlpPor := {}
aAdd( aHlpPor, "Informar 'S' se o produto é um" )
aAdd( aHlpPor, 'componente fantasma dentro da estrutura.' )
aAdd( aHlpPor, 'Nas rotinas de explosão serve apenas' )
aAdd( aHlpPor, 'como ponte para montagem das árvores,' )
aAdd( aHlpPor, 'não gerando ordens de produção.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_FANTASM", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_FANTASM" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para  informar se o' )
aAdd( aHlpPor, 'pro-duto  normalmente  é  comprado  fora' )
aAdd( aHlpPor, 'doestado  para  fins  de  cálculo do' )
aAdd( aHlpPor, 'custostandard (ICMS).' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_FORAEST", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_FORAEST" )

aHlpPor := {}
aAdd( aHlpPor, 'Indica se este produto entra para' )
aAdd( aHlpPor, 'cálculo do MRP.' )
aAdd( aHlpPor, '(S)im ou (N)ão.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_MRP    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_MRP" )

aHlpPor := {}
aAdd( aHlpPor, 'Indica se o Produto incide a' )
aAdd( aHlpPor, 'Contribuição Seguridade Social' )
aAdd( aHlpPor, '(Funrural)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_CONTSOC", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_CONTSOC" )

aHlpPor := {}
aAdd( aHlpPor, 'Define se deve ser calculado imposto de' )
aAdd( aHlpPor, 'renda para este produto na nota fiscal.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_IRRF   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_IRRF" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual CSLL.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_PCSLL  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PCSLL" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual a ser aplicado para cálculo' )
aAdd( aHlpPor, 'ddo COFINS quando a alíquota for' )
aAdd( aHlpPor, 'diferente da que estiver informada no' )
aAdd( aHlpPor, 'parâmetro MV_TXCOFIN.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_PCOFINS", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PCOFINS" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual a ser aplicado para cálculo' )
aAdd( aHlpPor, 'do PIS quando a alíquota for diferente' )
aAdd( aHlpPor, 'daque estiver informada no parâmetro' )
aAdd( aHlpPor, 'MV_TXPIS.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_PPIS   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PPIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Bruto do Produto ( Ex.:  Produto' )
aAdd( aHlpPor, '+Embalagem).' )
aAdd( aHlpPor, 'Atraves  do parâmetro MV_PESOCAR' )
aAdd( aHlpPor, 'pode-seutilizar este peso na Montagem de' )
aAdd( aHlpPor, 'Cargasno Módulo de OMS.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_PESBRU ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PESBRU" )

aHlpPor := {}
aAdd( aHlpPor, 'Porcentagem que deve ser aplicada para o' )
aAdd( aHlpPor, 'cálculo do Crédito Estímulo. Caso o' )
aAdd( aHlpPor, 'produto não proporcione o crédito, não' )
aAdd( aHlpPor, 'informar este campo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_CRDEST ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_CRDEST" )

aHlpPor := {}
aAdd( aHlpPor, 'Ident.Export.Dados' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_MSEXP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_MSEXP" )

//
// Helps Tabela SB2
//
aHlpPor := {}
aAdd( aHlpPor, 'Custo Unitario do Produto FIFO.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFF1  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFF1" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo Unitario do Produto FIFO da' )
aAdd( aHlpPor, '2a. moeda.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFF2  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFF2" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo Unitario do Produto FIFO da' )
aAdd( aHlpPor, '3a. moeda.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFF3  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFF3" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo Unitario do Produto FIFO da' )
aAdd( aHlpPor, '4a. moeda.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFF4  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFF4" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo Unitario do Produto FIFO da' )
aAdd( aHlpPor, '5a. moeda.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFF5  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFF5" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo unitário na moeda 1.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFIM1 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFIM1" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo unitário na moeda 2.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFIM2 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFIM2" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo unitário na moeda 3.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFIM3 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFIM3" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo unitário na moeda 4.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFIM4 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFIM4" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo unitário na moeda 5.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMFIM5 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMFIM5" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo de Reposicao Unitario na Moeda 1.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMRP1  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMRP1" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo de Reposicao Unitario na Moeda 2.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMRP2  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMRP2" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo de Reposicao Unitario na Moeda 3.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMRP3  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMRP3" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo de Reposicao Unitario na Moeda 4.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMRP4  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMRP4" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo de Reposicao Unitario na Moeda 5.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_CMRP5  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_CMRP5" )

aHlpPor := {}
aAdd( aHlpPor, 'Ident.Export.Dados' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB2_MSEXP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B2_MSEXP" )

//
// Helps Tabela SB4
//
aHlpPor := {}
aAdd( aHlpPor, 'Descrição da referência.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB4_DESC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B4_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para informar se o pro-' )
aAdd( aHlpPor, 'duto normalmente é comprado fora do es-' )
aAdd( aHlpPor, 'tado  para fins de cálculo do custo' )
aAdd( aHlpPor, 'standard.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB4_FORAEST", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B4_FORAEST" )

aHlpPor := {}
aAdd( aHlpPor, 'Alíquota do ICMS aplicada sobre o' )
aAdd( aHlpPor, 'produ-to conforme estado. As alíquotas' )
aAdd( aHlpPor, 'válidassão: 0%,7%,12%,18%,25%.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB4_PICM   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B4_PICM" )

aHlpPor := {}
aAdd( aHlpPor, 'Define se deve ser calculado imposto de' )
aAdd( aHlpPor, 'renda para este produto na nota fiscal.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB4_IRRF   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B4_IRRF" )

//
// Helps Tabela SB5
//
aHlpPor := {}
aAdd( aHlpPor, 'Descrição científica do produto, isto' )
aAdd( aHlpPor, 'é,uma  descrição  mais  longa, em' )
aAdd( aHlpPor, 'especialpara impressão na nota fiscal de' )
aAdd( aHlpPor, 'venda.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB5_CEME   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B5_CEME" )

aHlpPor := {}
aAdd( aHlpPor, 'Estado físico do material, quanto a' )
aAdd( aHlpPor, 'suaqualidade.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB5_ESTMAT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B5_ESTMAT" )

aHlpPor := {}
aAdd( aHlpPor, 'Concentração do Produto' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB5_CONCENT", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B5_CONCENT" )

aHlpPor := {}
aAdd( aHlpPor, 'Densidade do Produto' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB5_DENSID ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B5_DENSID" )

aHlpPor := {}
aAdd( aHlpPor, 'Hora Exportacao' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB5_XHREXP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B5_XHREXP" )

//
// Helps Tabela SC0
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo da reserva válida, sendo:' )
aAdd( aHlpPor, 'LB - Liberação      PD - Pedido' )
aAdd( aHlpPor, 'VD - Vendedor       NF - Nota Fiscal' )
aAdd( aHlpPor, 'CL - Cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC0_TIPO   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C0_TIPO" )

//
// Helps Tabela SC5
//
aHlpPor := {}
aAdd( aHlpPor, 'Código do tipo de cliente. (Ver help  do' )
aAdd( aHlpPor, 'programa).' )
aAdd( aHlpPor, 'R = Revendedor' )
aAdd( aHlpPor, 'S = Solidario' )
aAdd( aHlpPor, 'F = Consumidor Final' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_TIPOCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_TIPOCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do frete utilizado.' )
aAdd( aHlpPor, 'C = CIF' )
aAdd( aHlpPor, 'F = FOB' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_TPFRETE", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_TPFRETE" )

aHlpPor := {}
aAdd( aHlpPor, 'Este campo é sugerido através do cadas-' )
aAdd( aHlpPor, 'tro de clientes. Informa ao sistema se' )
aAdd( aHlpPor, 'o valor do ISS está incluso no preço.' )
aAdd( aHlpPor, 'Se o valor não estiver incluso e, ao' )
aAdd( aHlpPor, 'informar "N", o sistema inclui no Total' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_INCISS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_INCISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Utilizado pelo sistema.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_LIBEROK", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_LIBEROK" )

aHlpPor := {}
aAdd( aHlpPor, 'Este campo é utilizado para indicar, no' )
aAdd( aHlpPor, 'lançamento do pedido de venda, se o ICMS' )
aAdd( aHlpPor, 'sobre frete autonomo será pago pelo' )
aAdd( aHlpPor, 'emitente ou pelo transportador.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_RECFAUT", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_RECFAUT" )

//
// Helps Tabela SC6
//
aHlpPor := {}
aAdd( aHlpPor, 'Quantidade original do pedido.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_QTDVEN ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_QTDVEN" )

aHlpPor := {}
aAdd( aHlpPor, 'Preço unitário líquido. Preço de  tabela' )
aAdd( aHlpPor, 'com aplicação dos descontos e acréscimos' )
aAdd( aHlpPor, 'financeiros.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_PRCVEN ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_PRCVEN" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor total do ítem líquido, já' )
aAdd( aHlpPor, 'considerado todos os descontos e  com' )
aAdd( aHlpPor, 'base na quantidade.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_VALOR  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_VALOR" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para informar a' )
aAdd( aHlpPor, 'quantidade a ser liberada.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_QTDLIB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_QTDLIB" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para informar a' )
aAdd( aHlpPor, 'quantidade a ser liberada na segunda' )
aAdd( aHlpPor, 'unidade de medida.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_QTDLIB2", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_QTDLIB2" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição  do  produto  a ser emitido na' )
aAdd( aHlpPor, 'nota.É apresentado como default o  nome' )
aAdd( aHlpPor, 'que está no cadastro de produto.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_DESCRI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_DESCRI" )

aHlpPor := {}
aAdd( aHlpPor, 'Flag de geração da ordem de produção.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_OP     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_OP" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do romaneio.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_CODROM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_CODROM" )

aHlpPor := {}
aAdd( aHlpPor, 'Centro de Custo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_CCUSTO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_CCUSTO" )

//
// Helps Tabela SC9
//
//
// Helps Tabela SD2
//
aHlpPor := {}
aAdd( aHlpPor, 'Valor do ICMS sobre o Frete' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PD2_ICMFRET", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D2_ICMFRET" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do romaneio.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PD2_CODROM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D2_CODROM" )

//
// Helps Tabela SE1
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo de operação bancária na qual o' )
aAdd( aHlpPor, 'título  foi  negociado junto ao agente' )
aAdd( aHlpPor, 'cobrador. (Ver help do programa).' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_SITUACA", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "E1_SITUACA" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Tipo de Operação Bancaria.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "SE1_SITUACA", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado a solução do campo " + "E1_SITUACA" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do título expresso em moeda' )
aAdd( aHlpPor, 'corrente (Exemplo : Reais).' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_VLCRUZ ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "E1_VLCRUZ" )

//
// Helps Tabela SF2
//
aHlpPor := {}
aAdd( aHlpPor, 'Este campo é utilizado para indicar, no' )
aAdd( aHlpPor, 'lançamento do pedido de venda, se o ICMS' )
aAdd( aHlpPor, 'sobre frete autonomo será pago pelo' )
aAdd( aHlpPor, 'emitente ou pelo transportador.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PF2_RECFAUT", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "F2_RECFAUT" )

//
// Helps Tabela SL1
//
aHlpPor := {}
aAdd( aHlpPor, 'Comissao do vendedor' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL1_COMIS  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L1_COMIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL1_TIPOCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L1_TIPOCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Data de validade de orçamento.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL1_DTLIM  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L1_DTLIM" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço de cobrança do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL1_ENDCOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L1_ENDCOB" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço de entrega do orcamento' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL1_ENDENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L1_ENDENT" )

aHlpPor := {}
aAdd( aHlpPor, 'informar se a venda é forçada ou não' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL1_FORCADA", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L1_FORCADA" )

aHlpPor := {}
aAdd( aHlpPor, 'Id Endereço de Entrega' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL1_XIDENDE", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L1_XIDENDE" )

//
// Helps Tabela SL2
//
aHlpPor := {}
aAdd( aHlpPor, 'Descrição do produto' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL2_DESCRI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L2_DESCRI" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do item' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL2_VLRITEM", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L2_VLRITEM" )

aHlpPor := {}
aAdd( aHlpPor, 'Código fiscal deste ítem.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL2_CF     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L2_CF" )

aHlpPor := {}
aAdd( aHlpPor, 'Tabela de preco' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL2_TABELA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L2_TABELA" )

aHlpPor := {}
aAdd( aHlpPor, 'Status da troca de mercadoria' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL2_STATUS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L2_STATUS" )

//
// Helps Tabela SL4
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo Pagamento eCommerce' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PL4_XTID   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "L4_XTID" )

//
// Helps Tabela SLQ
//
aHlpPor := {}
aAdd( aHlpPor, 'Comissao do vendedor' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLQ_COMIS  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LQ_COMIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLQ_TIPOCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LQ_TIPOCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Data de validade de orçamento.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLQ_DTLIM  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LQ_DTLIM" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço de cobrança do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLQ_ENDCOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LQ_ENDCOB" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço de entrega do orcamento' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLQ_ENDENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LQ_ENDENT" )

aHlpPor := {}
aAdd( aHlpPor, 'Id Endereco de Entrega' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLQ_XIDENDE", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LQ_XIDENDE" )

//
// Helps Tabela SLR
//
aHlpPor := {}
aAdd( aHlpPor, 'Descrição do produto' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLR_DESCRI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LR_DESCRI" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do item' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLR_VLRITEM", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LR_VLRITEM" )

aHlpPor := {}
aAdd( aHlpPor, 'Código fiscal deste ítem.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLR_CF     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LR_CF" )

aHlpPor := {}
aAdd( aHlpPor, 'Tabela de preco' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLR_TABELA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LR_TABELA" )

aHlpPor := {}
aAdd( aHlpPor, 'Status da troca de mercadoria' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PLR_STATUS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "LR_STATUS" )

//
// Helps Tabela WS0
//
//
// Helps Tabela WS1
//
//
// Helps Tabela WS2
//
//
// Helps Tabela WS3
//
//
// Helps Tabela WS4
//
//
// Helps Tabela WS5
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo Campo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWS5_CODIGO", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WS5_CODIGO" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo VTex' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWS5_CAMPO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WS5_CAMPO" )

//
// Helps Tabela WS6
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Produto' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWS6_CODPRD", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WS6_CODPRD" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Campo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWS6_CODIGO", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WS6_CODIGO" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo VTEX' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWS6_CAMPO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WS6_CAMPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Conteúdo do campo especifico para o' )
aAdd( aHlpPor, 'produto eCommerce.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWS6_DESCEC", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WS6_DESCEC" )

//
// Helps Tabela WSA
//
aHlpPor := {}
aAdd( aHlpPor, 'Id Endereco Entregra' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWSA_IDENDE", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WSA_IDENDE" )

aHlpPor := {}
aAdd( aHlpPor, 'Num SL1' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWSA_NUMSL1", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WSA_NUMSL1" )

//
// Helps Tabela WSB
//
//
// Helps Tabela WSC
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo Transação de Pagamento' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PWSC_TID   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "WSC_TID" )

AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDVTEX" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  08/08/2019
@obs    Gerado por EXPORDIC - V.5.4.1.3 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet