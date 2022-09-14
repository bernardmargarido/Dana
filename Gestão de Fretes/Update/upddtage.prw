#INCLUDE "protheus.ch"

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
/*/{Protheus.doc} UPDDTAGE
Fun��o de update de dicion�rios para compatibiliza��o

@author TOTVS Protheus
@since  28/07/2022
@obs    Gerado por EXPORDIC - V.7.2.0.1 EFS / Upd. V.5.2.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDDTAGE( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZA��O DE DICION�RIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como fun��o fazer  a atualiza��o  dos dicion�rios do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja n�o podem haver outros"
Local   cDesc3    := "usu�rios  ou  jobs utilizando  o sistema.  � EXTREMAMENTE recomendav�l  que  se  fa�a"
Local   cDesc4    := "um BACKUP  dos DICION�RIOS  e da  BASE DE DADOS antes desta atualiza��o, para"
Local   cDesc5    := "que caso ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cMsg      := ""
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

	If FindFunction( "MPDicInDB" ) .AND. MPDicInDB()
		cMsg := "Este update N�O PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicion�rios se encontram no Banco de Dados e este update est� preparado " + ;
				"para atualizar apenas ambientes com dicion�rios no formato ISAM (.dbf ou .dtc)."

		If lAuto
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZA��O DOS DICION�RIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( cMsg )
			ConOut( DToC(Date()) + "|" + Time() + cMsg )
		Else
			MsgInfo( cMsg )
		EndIf

		Return NIL
	EndIf

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else

		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualiza��o dos dicion�rios ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualiza��o Realizada.", "UPDDTAGE" )
				Else
					MsgStop( "Atualiza��o n�o Realizada.", "UPDDTAGE" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualiza��o Realizada." )
				Else
					Final( "Atualiza��o n�o Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualiza��o n�o Realizada." )

		EndIf

	Else
		Final( "Atualiza��o n�o Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Fun��o de processamento da grava��o dos arquivos

@author TOTVS Protheus
@since  28/07/2022
@obs    Gerado por EXPORDIC - V.7.2.0.1 EFS / Upd. V.5.2.1 EFS
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
		// S� adiciona no aRecnoSM0 se a empresa for diferente
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
				MsgStop( "Atualiza��o da empresa " + aRecnoSM0[nI][2] + " n�o efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZA��O DOS DICION�RIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora �nicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Vers�o.............: " + GetVersao(.T.) )
			AutoGrLog( " Usu�rio TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usu�rio da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Esta��o............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conex�o............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicion�rio SX3
			//------------------------------------
			FSAtuSX3()

			oProcess:IncRegua1( "Dicion�rio de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/�ndices" )

			// Altera��o f�sica dos arquivos
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
					MsgStop( "Ocorreu um erro desconhecido durante a atualiza��o da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicion�rio e da tabela.", "ATEN��O" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualiza��o da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

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

			Define MsDialog oDlg Title "Atualiza��o concluida." From 3, 0 to 340, 417 Pixel

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
/*/{Protheus.doc} FSAtuSX3
Fun��o de processamento da grava��o do SX3 - Campos

@author TOTVS Protheus
@since  28/07/2022
@obs    Gerado por EXPORDIC - V.7.2.0.1 EFS / Upd. V.5.2.1 EFS
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

AutoGrLog( "�nicio da Atualiza��o" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// --- ATEN��O ---
// Coloque .F. na 2a. posi��o de cada elemento do array, para os dados do SX3
// que n�o ser�o atualizados quando o campo j� existir.
//

//
// Campos Tabela GW1
//
aAdd( aSX3, { ;
	{ 'GW1'																	, .T. }, ; //X3_ARQUIVO
	{ '66'																	, .T. }, ; //X3_ORDEM
	{ 'GW1_XDTAGE'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'DT Agenda'															, .T. }, ; //X3_TITULO
	{ 'DT Agenda'															, .T. }, ; //X3_TITSPA
	{ 'DT Agenda'															, .T. }, ; //X3_TITENG
	{ 'Data Agendamento'													, .T. }, ; //X3_DESCRIC
	{ 'Data Agendamento'													, .T. }, ; //X3_DESCSPA
	{ 'Data Agendamento'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'GW1'																	, .T. }, ; //X3_ARQUIVO
	{ '67'																	, .T. }, ; //X3_ORDEM
	{ 'GW1_XOBSAG'															, .T. }, ; //X3_CAMPO
	{ 'M'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Obs. Agenda'															, .T. }, ; //X3_TITULO
	{ 'Obs. Agenda'															, .T. }, ; //X3_TITSPA
	{ 'Obs. Agenda'															, .T. }, ; //X3_TITENG
	{ 'Observacoes Agendamento'												, .T. }, ; //X3_DESCRIC
	{ 'Observacoes Agendamento'												, .T. }, ; //X3_DESCSPA
	{ 'Observacoes Agendamento'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'GW1'																	, .T. }, ; //X3_ARQUIVO
	{ '68'																	, .T. }, ; //X3_ORDEM
	{ 'GW1_XSTAT'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sta. Agend'															, .T. }, ; //X3_TITULO
	{ 'Sta. Agend'															, .T. }, ; //X3_TITSPA
	{ 'Sta. Agend'															, .T. }, ; //X3_TITENG
	{ 'Status Agendamento'													, .T. }, ; //X3_DESCRIC
	{ 'Status Agendamento'													, .T. }, ; //X3_DESCSPA
	{ 'Status Agendamento'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Pendente de Envio;2=Aguardando Agendamento;3=Agendado'				, .T. }, ; //X3_CBOX
	{ '1=Pendente de Envio;2=Aguardando Agendamento;3=Agendado'				, .T. }, ; //X3_CBOXSPA
	{ '1=Pendente de Envio;2=Aguardando Agendamento;3=Agendado'				, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela SA1
//
aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ 'FS'																	, .T. }, ; //X3_ORDEM
	{ 'A1_XMAILAG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 120																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mail Agenda'															, .T. }, ; //X3_TITULO
	{ 'Mail Agenda'															, .T. }, ; //X3_TITSPA
	{ 'Mail Agenda'															, .T. }, ; //X3_TITENG
	{ 'e-Mail Agendamento'													, .T. }, ; //X3_DESCRIC
	{ 'e-Mail Agendamento'													, .T. }, ; //X3_DESCSPA
	{ 'e-Mail Agendamento'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela SA4
//
aAdd( aSX3, { ;
	{ 'SA4'																	, .T. }, ; //X3_ARQUIVO
	{ '41'																	, .T. }, ; //X3_ORDEM
	{ 'A4_XMAILAG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 120																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mail Agenda'															, .T. }, ; //X3_TITULO
	{ 'Mail Agenda'															, .T. }, ; //X3_TITSPA
	{ 'Mail Agenda'															, .T. }, ; //X3_TITENG
	{ 'e-Mail de Agendamento'												, .T. }, ; //X3_DESCRIC
	{ 'e-Mail de Agendamento'												, .T. }, ; //X3_DESCSPA
	{ 'e-Mail de Agendamento'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME


//
// Atualizando dicion�rio
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq][1]+x[nPosOrd][1]+x[nPosCpo][1] < y[nPosArq][1]+y[nPosOrd][1]+y[nPosCpo][1] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG][1] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG][1] ) )
			If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
				aSX3[nI][nPosTam][1] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " N�O atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq][1] $ cAlias )
		cAlias += aSX3[nI][nPosArq][1] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq][1] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo][1], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq][1] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq][1]

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
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo][1] )

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG][1]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
					aSX3[nI][nPosTam][1] := SXG->XG_SIZE
					AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " N�O atualizado e foi mantido em [" + ;
					AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF + ;
					"   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF )
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aSX3[nI][nJ][2]
				cX3Campo := AllTrim( aEstrut[nJ][1] )
				cX3Dado  := SX3->( FieldGet( aEstrut[nJ][2] ) )

				If  aEstrut[nJ][2] > 0 .AND. ;
					PadR( StrTran( AllToChar( cX3Dado ), " ", "" ), 250 ) <> ;
					PadR( StrTran( AllToChar( aSX3[nI][nJ][1] ), " ", "" ), 250 ) .AND. ;
					!cX3Campo == "X3_ORDEM"

					cMsg := "O campo " + aSX3[nI][nPosCpo][1] + " est� com o " + cX3Campo + ;
					" com o conte�do" + CRLF + ;
					"[" + RTrim( AllToChar( cX3Dado ) ) + "]" + CRLF + ;
					"que ser� substitu�do pelo NOVO conte�do" + CRLF + ;
					"[" + RTrim( AllToChar( aSX3[nI][nJ][1] ) ) + "]" + CRLF + ;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZA��O DE DICION�RIOS E TABELAS", cMsg, { "Sim", "N�o", "Sim p/Todos", "N�o p/Todos" }, 3, "Diferen�a de conte�do - SX3" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a op��o de REALIZAR TODAS altera��es no SX3 e N�O MOSTRAR mais a tela de aviso." + CRLF + "Confirma a a��o [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a op��o de N�O REALIZAR nenhuma altera��o no SX3 que esteja diferente da base e N�O MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta a��o [N�o p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						AutoGrLog( "Alterado campo " + aSX3[nI][nPosCpo][1] + CRLF + ;
						"   " + PadR( cX3Campo, 10 ) + " de [" + AllToChar( cX3Dado ) + "]" + CRLF + ;
						"            para [" + AllToChar( aSX3[nI][nJ][1] )           + "]" + CRLF )

						RecLock( "SX3", .F. )
						FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] )
						MsUnLock()
					EndIf

				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualiza��o" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Fun��o de processamento da grava��o dos Helps de Campos

@author TOTVS Protheus
@since  28/07/2022
@obs    Gerado por EXPORDIC - V.7.2.0.1 EFS / Upd. V.5.2.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "�nicio da Atualiza��o" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela GW1
//
aHlpPor := {}
aAdd( aHlpPor, 'Data Agendamento' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PGW1_XDTAGE", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "GW1_XDTAGE" )

aHlpPor := {}
aAdd( aHlpPor, 'Observacoes Agendamento' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PGW1_XOBSAG", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "GW1_XOBSAG" )

//
// Helps Tabela SA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Nome ou raz�o social do cliente.' )

aHlpEng := {}
aAdd( aHlpEng, 'Name or corporate name of customer.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nombre o raz�n social del cliente.' )

PutSX1Help( "PA1_NOME   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_NOME" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Cliente :' )
aAdd( aHlpPor, 'Op��es Brasil (L,F,R,S,X):' )
aAdd( aHlpPor, 'L - Produtor Rural; F - Cons.Final;' )
aAdd( aHlpPor, 'R - Revendedor; S - ICMS Solid�rio sem' )
aAdd( aHlpPor, 'IPI na base; X - Exporta��o.' )
aAdd( aHlpPor, 'Outros Pa�ses :' )
aAdd( aHlpPor, 'Verificar op��es dispon�veis' )

aHlpEng := {}
aAdd( aHlpEng, 'Type of Customer' )
aAdd( aHlpEng, 'Brazil Options (L,F,R,S,X):' )
aAdd( aHlpEng, 'L-Rural producer;F-End Consumer;;' )
aAdd( aHlpEng, 'R-Reseller; S-VAT without Excise tax in' )
aAdd( aHlpEng, 'base ; X-Export.' )
aAdd( aHlpEng, 'Other Countries :' )
aAdd( aHlpEng, 'Check the available choices' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Cliente' )
aAdd( aHlpSpa, 'Opciones Brasil (I, N, F, Z, A):' )
aAdd( aHlpSpa, 'I: Inscripto         ; N: No Exento' )
aAdd( aHlpSpa, 'F: Consumidor Final  ; Z: Exento' )
aAdd( aHlpSpa, 'A: Agente' )
aAdd( aHlpSpa, 'Otros Paises :' )
aAdd( aHlpSpa, 'Verificar opciones disponibles' )

PutSX1Help( "PA1_TIPO   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Deve ser preenchido apenas com L,F,R,S' )
aAdd( aHlpPor, 'ou X (Brasil) ou com op��es diponiveis' )
aAdd( aHlpPor, 'para o pais em uso' )


aHlpEng := {}
aAdd( aHlpEng, 'Must be filled in only with L,F,R,S or' )
aAdd( aHlpEng, 'X (Brazil) or with the available options' )
aAdd( aHlpEng, 'for the country being used' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Debe llenarse apenas con I, N, F, Z o A.' )
aAdd( aHlpSpa, '(Brasil) o con las opciones disponibles' )
aAdd( aHlpSpa, 'para el pais en uso' )

PutSX1Help( "SA1_TIPO   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado a solu��o do campo " + "A1_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para informar a natureza' )
aAdd( aHlpPor, 'do t�tulo, quando gerado, para o m�dulo' )
aAdd( aHlpPor, 'financeiro.' )

aHlpEng := {}
aAdd( aHlpEng, 'Field used to inform the nature of the' )
aAdd( aHlpEng, 'bill, when generated, for the financial' )
aAdd( aHlpEng, 'module.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Campo usado para informar al m�dulo fi-' )
aAdd( aHlpSpa, 'nanciero, la modalidad del t�tulo que' )
aAdd( aHlpSpa, 'es generado.' )

PutSX1Help( "PA1_NATUREZ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_NATUREZ" )

aHlpPor := {}
aAdd( aHlpPor, 'Endere�o de cobran�a do cliente.' )

aHlpEng := {}
aAdd( aHlpEng, "Customer's Invoicing Address." )

aHlpSpa := {}
aAdd( aHlpSpa, 'Direcci�n de cobros del cliente.' )

PutSX1Help( "PA1_ENDCOB ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDCOB" )

aHlpPor := {}
aAdd( aHlpPor, 'Endere�o de entrega do cliente.' )

aHlpEng := {}
aAdd( aHlpEng, "Customer's Delivery Address." )

aHlpSpa := {}
aAdd( aHlpSpa, 'Direcci�n de entrega del cliente.' )

PutSX1Help( "PA1_ENDENT ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDENT" )

aHlpPor := {}
aAdd( aHlpPor, 'Endere�o da central de compras do' )
aAdd( aHlpPor, 'cliente.' )

aHlpEng := {}
aAdd( aHlpEng, 'Customer purchase unit address.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Direcci�n de la central de compras del' )
aAdd( aHlpSpa, 'cliente.' )

PutSX1Help( "PA1_ENDREC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDREC" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual apresentado  como  default na' )
aAdd( aHlpPor, 'tela do pedido para c�lculo de comiss�o.' )
aAdd( aHlpPor, 'Tem  prioridade  sobre  o % informado no' )
aAdd( aHlpPor, 'cadastro de  vendedor, por�m n�o sobre o' )
aAdd( aHlpPor, '% informado no produto.' )

aHlpEng := {}
aAdd( aHlpEng, 'Percentage presented as default in the' )
aAdd( aHlpEng, 'order screen for calculation of' )
aAdd( aHlpEng, 'commission.Has priority over 0%' )
aAdd( aHlpEng, "informedin seller's  register however" )
aAdd( aHlpEng, 'not over  the % informed in product.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Porcentual presentado como est�ndar en' )
aAdd( aHlpSpa, 'la pantalla del pedido para c�lculo de' )
aAdd( aHlpSpa, 'comisi�n.  Es prioritario sobre el %' )
aAdd( aHlpSpa, 'in-formado en el archivo de vendedor,' )
aAdd( aHlpSpa, 'pero no sobre el % informado en el' )
aAdd( aHlpSpa, 'producto.' )

PutSX1Help( "PA1_COMIS  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_COMIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Cliente com regime especial?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XREGESP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XREGESP" )

aHlpPor := {}
aAdd( aHlpPor, 'Mensagem regime especial Dana.' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_REGESP ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_REGESP" )

aHlpPor := {}
aAdd( aHlpPor, 'Descri��o da regra de base de c�lculo.' )

aHlpEng := {}
aAdd( aHlpEng, 'Description of calculation base rule.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descripci�n de la regla de base de' )
aAdd( aHlpSpa, 'c�lculo.' )

PutSX1Help( "PA1_TPFRET ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TPFRET" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de desconto padr�o  concedido' )
aAdd( aHlpPor, 'ao cliente como sugest�o a cada' )
aAdd( aHlpPor, 'faturamento.' )

aHlpEng := {}
aAdd( aHlpEng, 'Percentage of standard discount granted' )
aAdd( aHlpEng, 'to customer, as suggested at each' )
aAdd( aHlpEng, 'invoicing.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Porcentual de descuento est�ndar otor-' )
aAdd( aHlpSpa, 'gado al cliente como sugerencia en cada' )
aAdd( aHlpSpa, 'facturaci�n.' )

PutSX1Help( "PA1_DESC   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Prioridade de atendimento do cliente' )
aAdd( aHlpPor, 'face sua contribui��o com a empresa.' )

aHlpEng := {}
aAdd( aHlpEng, 'Service priority to customer' )
aAdd( aHlpEng, 'consideringhis contribution to the' )
aAdd( aHlpEng, 'company.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Prioridad  de atenci�n al cliente en' )
aAdd( aHlpSpa, 'funci�n de su contribuci�n a la empre-' )
aAdd( aHlpSpa, 'sa.' )

PutSX1Help( "PA1_PRIOR  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_PRIOR" )

aHlpPor := {}
aAdd( aHlpPor, 'Grau de Risco na aprova��o do Cr�dito do' )
aAdd( aHlpPor, 'Cliente em Pedidos de Venda (A,B,C,D,E):' )
aAdd( aHlpPor, 'A: Cr�dito Ok;' )
aAdd( aHlpPor, 'B,C e D: Libera��o definida atrav�s dos' )
aAdd( aHlpPor, 'par�metros: MV_RISCO(B,C,D);' )
aAdd( aHlpPor, 'E: Libera��o manual;' )
aAdd( aHlpPor, 'Z: Libera��o atrav�s de integra��o com' )
aAdd( aHlpPor, 'software de terceiro.' )

aHlpEng := {}
aAdd( aHlpEng, 'Risk level referring to the customer' )
aAdd( aHlpEng, 'credit approval in sales orders' )
aAdd( aHlpEng, '(A,B,C,D,E):' )
aAdd( aHlpEng, 'A:Credit is Ok;' )
aAdd( aHlpEng, 'B,C and D: Release defined through the' )
aAdd( aHlpEng, 'parameters: MV_RISCO(B,C,D);' )
aAdd( aHlpEng, 'E: Manual release' )
aAdd( aHlpEng, 'Z: Release through the integration with' )
aAdd( aHlpEng, 'third party software.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Grado de riesgo en la aprovaci�n del' )
aAdd( aHlpSpa, 'credito del cliente en Pedidos de venta' )
aAdd( aHlpSpa, '(A,B,C,D,E):' )
aAdd( aHlpSpa, 'A: Credito OK.' )
aAdd( aHlpSpa, 'B,C,D:Liberacion definida a traves de' )
aAdd( aHlpSpa, 'los parametros: MV_RISCO(B,C,D).' )
aAdd( aHlpSpa, 'E:Aprobaci�n manual.' )
aAdd( aHlpSpa, 'Z:Aprobaci�n a traves de la integracion' )
aAdd( aHlpSpa, 'con software de terceros.' )

PutSX1Help( "PA1_RISCO  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_RISCO" )

aHlpPor := {}
aAdd( aHlpPor, 'Limite de cr�dito estabelecido para o' )
aAdd( aHlpPor, 'cliente. Valor armazenado na moeda forte' )
aAdd( aHlpPor, 'definida no campo A1_MOEDALC. Default' )
aAdd( aHlpPor, 'moeda 2.' )

aHlpEng := {}
aAdd( aHlpEng, 'Credit Limit established for the' )
aAdd( aHlpEng, 'customer. Value stored in the strong' )
aAdd( aHlpEng, 'currency defined in field A1_MOEDALC.' )
aAdd( aHlpEng, 'Default currency 2.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'L�mite de cr�dito establecido para el' )
aAdd( aHlpSpa, 'cliente. Valor almacenado en la moneda' )
aAdd( aHlpSpa, 'fuerte definida en el campo A1_MOEDALC.' )
aAdd( aHlpSpa, 'Est�ndar: moneda 2.' )

PutSX1Help( "PA1_LC     ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_LC" )

aHlpPor := {}
aAdd( aHlpPor, 'Data de vencimento do limite de cr�dito.' )
aAdd( aHlpPor, 'O sistema bloqueia os pedidos  quando a' )
aAdd( aHlpPor, 'data do limite de cr�dito estiver' )
aAdd( aHlpPor, 'expirada.' )

aHlpEng := {}
aAdd( aHlpEng, 'Maturity date of the credit limit. The' )
aAdd( aHlpEng, 'system blocks the orders when the date' )
aAdd( aHlpEng, 'ofthe credit limit is expired.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Fecha de vencimiento del l�mite de cr�-' )
aAdd( aHlpSpa, 'dito.  El sistema  bloquea los pedidos' )
aAdd( aHlpSpa, 'cuando  la fecha del l�mite de cr�dito' )
aAdd( aHlpSpa, 'est� expirada.' )

PutSX1Help( "PA1_VENCLC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_VENCLC" )

aHlpPor := {}
aAdd( aHlpPor, 'Limite de credito secundario.' )

aHlpEng := {}
aAdd( aHlpEng, 'Secondary credit limit.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Limite de credito secundario.' )

PutSX1Help( "PA1_LCFIN  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_LCFIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Somat�ria dos valores em atraso  levando' )
aAdd( aHlpPor, 'em considera��o o n�mero de dias' )
aAdd( aHlpPor, 'definidos no risco do cliente.' )

aHlpEng := {}
aAdd( aHlpEng, 'Sum of amounts in arrears considering' )
aAdd( aHlpEng, 'the number of days defined in risk of' )
aAdd( aHlpEng, 'customer.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Suma de los valores en atraso conside-' )
aAdd( aHlpSpa, 'rando  el n�mero de d�as definidos en' )
aAdd( aHlpSpa, 'el Grado de Riesgo del cliente.' )

PutSX1Help( "PA1_ATR    ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ATR" )

aHlpPor := {}
aAdd( aHlpPor, 'N�mero de t�tulos protestados  do' )
aAdd( aHlpPor, 'cliente. Campo informativo.' )

aHlpEng := {}
aAdd( aHlpEng, "Number of customer's protested bills." )
aAdd( aHlpEng, 'Informative field.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'N�mero de t�tulos protestados del' )
aAdd( aHlpSpa, 'clien-te. Campo informativo.' )

PutSX1Help( "PA1_TITPROT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TITPROT" )

aHlpPor := {}
aAdd( aHlpPor, 'N�mero de cheques devolvidos do cliente.' )
aAdd( aHlpPor, 'Deve ser informado pelo usu�rio. �' )
aAdd( aHlpPor, 'apresentado por ocasi�o da libera��o de' )
aAdd( aHlpPor, 'cr�dito. Campo informativo.' )

aHlpEng := {}
aAdd( aHlpEng, 'Number of returned checks of customer.' )
aAdd( aHlpEng, 'Must be informed by user.It is' )
aAdd( aHlpEng, 'presentedduring credit release.' )
aAdd( aHlpEng, 'Informative      field.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'N�mero de cheques devueltos del' )
aAdd( aHlpSpa, 'cliente.Debe  ser  informado por el' )
aAdd( aHlpSpa, 'usuario. Se presenta  en  la liberaci�n' )
aAdd( aHlpSpa, 'de cr�dito. Campo informativo.' )

PutSX1Help( "PA1_CHQDEVO", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CHQDEVO" )

aHlpPor := {}
aAdd( aHlpPor, 'Se o ISS estiver embutido no pre�o,' )
aAdd( aHlpPor, 'informar "S", se desejar incluir o ISS' )
aAdd( aHlpPor, 'no total da NF, informar "N".' )

aHlpEng := {}
aAdd( aHlpEng, 'In the event the Service Tax included' )
aAdd( aHlpEng, 'inthe price reads " S" , and you wish to' )
aAdd( aHlpEng, 'include the Service Tax to the Invoice' )
aAdd( aHlpEng, 'total, then inform " N" .' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Si el Impuesto Sobre Servicios (ISS)' )
aAdd( aHlpSpa, 'es-t� incluido en el precio -> informe' )
aAdd( aHlpSpa, '<S>.Si desea que el ISS est� incluido en' )
aAdd( aHlpSpa, 'el total de la factura -> informe <N>.' )

PutSX1Help( "PA1_INCISS ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_INCISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Al�quota de Imposto de Renda Retido  na' )
aAdd( aHlpPor, 'Fonte.' )

aHlpEng := {}
aAdd( aHlpEng, 'Income Tax withheld at Source Rate.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Al�cuota del Impuesto a las Ganancias' )
aAdd( aHlpSpa, 'Retenido en la Fuente.' )

PutSX1Help( "PA1_ALIQIR ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ALIQIR" )

aHlpPor := {}
aAdd( aHlpPor, 'Informar  se  deve  calcular  ou  n�o o' )
aAdd( aHlpPor, 'desconto de 7% para clientes com c�digo' )
aAdd( aHlpPor, 'SUFRAMA.' )
aAdd( aHlpPor, 'VALIDA��O:' )
aAdd( aHlpPor, '(N) - N�o efetua o c�lculo do desconto' )
aAdd( aHlpPor, 'SUFRAMA' )
aAdd( aHlpPor, '(Branco),(S) - Calcula o Desconto de' )
aAdd( aHlpPor, 'Pis, Cofins e ICMS, dependendo da' )
aAdd( aHlpPor, 'configura��o no cadastro do produto.' )
aAdd( aHlpPor, '(I) - Calcula o desconto apenas' )
aAdd( aHlpPor, 'referente ao ICMS, n�o calculando o' )
aAdd( aHlpPor, 'desconto para Pis e Cofins, tamb�m' )
aAdd( aHlpPor, 'dependendo da configura��o no cadastro' )
aAdd( aHlpPor, 'do produto para permitir o c�lculo.' )

aHlpEng := {}
aAdd( aHlpEng, 'Enter if calculates or not 7% discount' )
aAdd( aHlpEng, 'for clients under SUFRAMA code.' )
aAdd( aHlpEng, 'VALIDATION: (N) -' )
aAdd( aHlpEng, 'It does not perform calculation of' )
aAdd( aHlpEng, 'SUFRAMA discount(White),(S) -' )
aAdd( aHlpEng, 'Calculates Pis, Cofins and ICMS,' )
aAdd( aHlpEng, 'discounts, depending on the' )
aAdd( aHlpEng, 'configuration of product file.(I) -' )
aAdd( aHlpEng, 'Calculates discount only related to' )
aAdd( aHlpEng, 'ICMS, excluding Pis and Cofins discount,' )
aAdd( aHlpEng, 'also depending on the configuration in' )
aAdd( aHlpEng, 'product file to enable calculation.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Informar  si  debe  calcular  o  no el' )
aAdd( aHlpSpa, 'descuento de 7% para clientes con codigo' )
aAdd( aHlpSpa, 'SUFRAMA.' )
aAdd( aHlpSpa, 'VALIDACION: (N) - No efectua el calculo' )
aAdd( aHlpSpa, 'del descuento SUFRAMA(Blanco), (S) -' )
aAdd( aHlpSpa, 'Calcula el Descuento de Pis, Cofins e' )
aAdd( aHlpSpa, 'ICMS, dependiendo de la configuracion en' )
aAdd( aHlpSpa, 'el registro del producto.(I) - Calcula' )
aAdd( aHlpSpa, 'el descuento solamente referente al' )
aAdd( aHlpSpa, 'ICMS, no calculando el descuento para' )
aAdd( aHlpSpa, 'Pis y Cofins, dependiendo tambien de la' )
aAdd( aHlpSpa, 'configuracion en el registro del' )
aAdd( aHlpSpa, 'producto para permitir el calculo.' )

PutSX1Help( "PA1_CALCSUF", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CALCSUF" )

aHlpPor := {}
aAdd( aHlpPor, 'Indica se o cliente � Ativo ou n�o' )

aHlpEng := {}
aAdd( aHlpEng, 'Indicates if the client is Actie or not.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Indica si el Cliente es Activo o no.' )

PutSX1Help( "PA1_ATIVO  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ATIVO" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe S ou N.' )


aHlpEng := {}
aAdd( aHlpEng, 'Inform S or N' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Informe S o N.' )

PutSX1Help( "SA1_ATIVO  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado a solu��o do campo " + "A1_ATIVO" )

aHlpPor := {}
aAdd( aHlpPor, 'Cliente Especial (S/N)' )

aHlpEng := {}
aAdd( aHlpEng, 'Personalized costumer (Y/N)' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cliente Especial (S/N)' )

PutSX1Help( "PA1_CLIESP ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CLIESP" )

aHlpPor := {}
aAdd( aHlpPor, 'Saldo tempor�rio de Cr�dito.' )

aHlpEng := {}
aAdd( aHlpEng, 'Temporary Credit Balance.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Saldo temporal de Cr�dito.' )

PutSX1Help( "PA1_SALTEMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_SALTEMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Cliente.' )

aHlpEng := {}
aAdd( aHlpEng, 'Type of Customer.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de cliente' )

PutSX1Help( "PA1_TIPOCLI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TIPOCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Canal de Distribui��o' )

aHlpEng := {}
aAdd( aHlpEng, 'Distribution way' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Canal de Distrubucion' )

PutSX1Help( "PA1_CANAL  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CANAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Condicao de Pagamento Praticada.' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_CONDPRA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CONDPRA" )

aHlpPor := {}
aAdd( aHlpPor, 'Bloqueio Financeiro.' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XBLQFIN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XBLQFIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Bloqueado pelo Depto Fiscal.' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XBLQFIS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XBLQFIS" )

aHlpPor := {}
aAdd( aHlpPor, 'E-commerce' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XECOMER", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XECOMER" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Rede' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XREDE  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XREDE" )

aHlpPor := {}
aAdd( aHlpPor, 'Descricao da Rede' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XDESRED", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XDESRED" )

aHlpPor := {}
aAdd( aHlpPor, 'Contato Financeiro' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XCONFIN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XCONFIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Tel Financeiro' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XTELFIN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XTELFIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Email Financeiro' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XEMAILF", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XEMAILF" )

aHlpPor := {}
aAdd( aHlpPor, 'Contato Logistica' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XCONLOG", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XCONLOG" )

aHlpPor := {}
aAdd( aHlpPor, 'Email Logistica' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XEMAILL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XEMAILL" )

aHlpPor := {}
aAdd( aHlpPor, 'Agendamento?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XAGENDA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XAGENDA" )

aHlpPor := {}
aAdd( aHlpPor, 'Paletizacao?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XPALETI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XPALETI" )

aHlpPor := {}
aAdd( aHlpPor, 'Hora do recebimento' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XHORECE", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XHORECE" )

aHlpPor := {}
aAdd( aHlpPor, 'Mensagem Data recebimento' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XMSGDTR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XMSGDTR" )

aHlpPor := {}
aAdd( aHlpPor, 'Atacado/Varejo ?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XTIPCLI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XTIPCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Vendedor 2' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XVEND2 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XVEND2" )

aHlpPor := {}
aAdd( aHlpPor, 'Carro Dedicado ?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XCARROD", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XCARROD" )

aHlpPor := {}
aAdd( aHlpPor, 'Lead Time - Entrega' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XLEADTI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XLEADTI" )

aHlpPor := {}
aAdd( aHlpPor, 'Data da ultima ativacao.' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XDTATIV", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XDTATIV" )

aHlpPor := {}
aAdd( aHlpPor, 'Importa pedido para Filial 6?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XFIMPPE", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XFIMPPE" )

aHlpPor := {}
aAdd( aHlpPor, 'EAN CX Master no XML' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XEANCXM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XEANCXM" )

aHlpPor := {}
aAdd( aHlpPor, 'Considera Lead Time no Famento, Lead' )
aAdd( aHlpPor, 'Time + Condi��o de pagamento?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XLEADFA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XLEADFA" )

aHlpPor := {}
aAdd( aHlpPor, 'Aceita Saldo de pedido' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XACESAL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XACESAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Dias de validade do saldo do pedido?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XDIASSL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XDIASSL" )

aHlpPor := {}
aAdd( aHlpPor, 'Recebimento por transferencia(TED)?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XTRANSF", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XTRANSF" )

aHlpPor := {}
aAdd( aHlpPor, 'Atendimento Marketing?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XATEMKT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XATEMKT" )

aHlpPor := {}
aAdd( aHlpPor, 'Filial de Faturamento' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XFILFAT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XFILFAT" )

aHlpPor := {}
aAdd( aHlpPor, 'eMail eCommerce' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XMAILEC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XMAILEC" )

aHlpPor := {}
aAdd( aHlpPor, 'Raiz do CNPJ' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XRAIZ  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XRAIZ" )

aHlpPor := {}
aAdd( aHlpPor, 'Gera Boleto?' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XBOLETO", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XBOLETO" )

aHlpPor := {}
aAdd( aHlpPor, 'e-Mail Agendamento' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA1_XMAILAG", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XMAILAG" )

//
// Helps Tabela SA4
//
aHlpPor := {}
aAdd( aHlpPor, 'Raz�o Social ou nome da transportadora.' )

aHlpEng := {}
aAdd( aHlpEng, "Carrier's Corporate Name or name." )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nombre o raz�n social de la transporta-' )
aAdd( aHlpSpa, 'dora.' )

PutSX1Help( "PA4_NOME   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_NOME" )

aHlpPor := {}
aAdd( aHlpPor, '� o nome  reduzido pelo qual a' )
aAdd( aHlpPor, 'transportadora � mais conhecida dentro' )
aAdd( aHlpPor, 'da empresa. Auxilia  nas  consultas e' )
aAdd( aHlpPor, 'relat�rios do sistema.' )

aHlpEng := {}
aAdd( aHlpEng, "It's the short name by which the" )
aAdd( aHlpEng, 'carrieris best known inside the' )
aAdd( aHlpEng, "company.It     helps in the system's" )
aAdd( aHlpEng, 'consultations and reports.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nombre reducido por el cual la' )
aAdd( aHlpSpa, 'transportadora  es m�s conocida dentro' )
aAdd( aHlpSpa, 'de la empresa. Ayuda en las consultas e' )
aAdd( aHlpSpa, 'informesdel sistema.' )

PutSX1Help( "PA4_NREDUZ ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_NREDUZ" )

aHlpPor := {}
aAdd( aHlpPor, 'Via de Transporte' )

aHlpEng := {}
aAdd( aHlpEng, 'Transportation Method.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Medio de Transporte.' )

PutSX1Help( "PA4_VIA    ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_VIA" )

aHlpPor := {}
aAdd( aHlpPor, 'Endere�o da transportadora.' )

aHlpEng := {}
aAdd( aHlpEng, "Carrier's Address." )

aHlpSpa := {}
aAdd( aHlpSpa, 'Direcci�n de la transportadora.' )

PutSX1Help( "PA4_END    ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_END" )

aHlpPor := {}
aAdd( aHlpPor, 'Munic�pio da transportadora.' )

aHlpEng := {}
aAdd( aHlpEng, "Carrier's City." )

aHlpSpa := {}
aAdd( aHlpSpa, 'Municipio/ Ciudad de la transportadora.' )

PutSX1Help( "PA4_MUN    ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_MUN" )

aHlpPor := {}
aAdd( aHlpPor, 'C�digo de endere�amento postal da' )
aAdd( aHlpPor, 'transportadora.' )

aHlpEng := {}
aAdd( aHlpEng, "Carrier's Zip Code." )

aHlpSpa := {}
aAdd( aHlpSpa, 'C�digo Postal (CP) de la transportadora.' )

PutSX1Help( "PA4_CEP    ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_CEP" )

aHlpPor := {}
aAdd( aHlpPor, 'Nome do contato da empresa na' )
aAdd( aHlpPor, 'transpor-tadora.' )

aHlpEng := {}
aAdd( aHlpEng, "Company's Contact Name at the carrier's." )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nombre del contacto de la empresa en la' )
aAdd( aHlpSpa, 'transportadora.' )

PutSX1Help( "PA4_CONTATO", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_CONTATO" )

aHlpPor := {}
aAdd( aHlpPor, 'e-Mail de Agendamento' )

aHlpEng := {}

aHlpSpa := {}

PutSX1Help( "PA4_XMAILAG", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A4_XMAILAG" )

AutoGrLog( CRLF + "Final da Atualiza��o" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Fun��o gen�rica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as sele��es feitas.
             Se n�o for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Par�metro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta s� com Empresas
// 3 - Monta s� com Filiais de uma Empresa
//
// Par�metro  aMarcadas
// Vetor com Empresas/Filiais pr� marcadas
//
// Par�metro  cEmpSel
// Empresa que ser� usada para montar sele��o
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

oDlg:cToolTip := "Tela para M�ltiplas Sele��es de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualiza��o"

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
Message "M�scara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Sele��o" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "m�scara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "m�scara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDDTAGE" ) ) ) ;
Message "Confirma a sele��o e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplica��o" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Fun��o auxiliar para marcar/desmarcar todos os �tens do ListBox ativo

@param lMarca  Cont�udo para marca .T./.F.
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
Fun��o auxiliar para inverter a sele��o do ListBox ativo

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
Fun��o auxiliar que monta o retorno com as sele��es

@param aRet    Array que ter� o retorno das sele��es (� alterado internamente)
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
Fun��o para marcar/desmarcar usando m�scaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a m�scara (???)
@param lMarDes  Marca a ser atribu�da .T./.F.

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
Fun��o auxiliar para verificar se est�o todos marcados ou n�o

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
Fun��o de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  28/07/2022
@obs    Gerado por EXPORDIC - V.7.2.0.1 EFS / Upd. V.5.2.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "N�o foi poss�vel a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATEN��O" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Fun��o de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  28/07/2022
@obs    Gerado por EXPORDIC - V.7.2.0.1 EFS / Upd. V.5.2.1 EFS
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
		cRet += "Tamanho de exibi��o maxima do LOG alcan�ado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
