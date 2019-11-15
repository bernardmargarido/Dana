#INCLUDE 'PROTHEUS.CH'
//#INCLUDE 'INKEY.CH'

#DEFINE NPOSDIRNOME    1
#DEFINE NPOSDIRTAMANHO 2
#DEFINE NPOSDIRDATA    3
#DEFINE NPOSDIRHORA    4
#DEFINE NPOSDIRATRIB   5

#DEFINE NPOSLBXBITMAP  1
#DEFINE NPOSLBXNOME    2
#DEFINE NPOSLBXANHO    3
#DEFINE NPOSLBXDATA    4
#DEFINE NPOSLBXHORA    5
#DEFINE NPOSLBXATRIB   6
#DEFINE NPOSLBXORDBY   7

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณApExplorerบAutor  ณ Iuspa /            บ Data ณ  11/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de copia de arquivos entre Server / Local           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ApExplorer()
Local nPosArq := 1
Local nPosLbx := 1
Local cPesq   := Space( 30 )
Local lOk     := .F.
Local nI      := 0
Local oMainWnd

Private CPAISLOC   := ''
Private cAcesso    := ''
Private cServStart := '\'
Private cLocaStart := 'C:\'
Private cServPath  := cServStart
Private cLocaPath  := cLocaStart
Private cObjFocus  := 'S'
Private cPathAtual := cServPath
Private oLbxAtual  := NIL
Private lPosFirst  := .T.

Private aServFiles := MyDirec( cServPath + '*.*', 'D' )
Private aLocaFiles := MyDirec( cLocaPath + '*.*', 'D' )
Private aClickServ := { .F., .F., .F., .F., .F., .F. }
Private aClickLoca := { .F., .F., .F., .F., .F., .F. }

SetKey( VK_F2, { || Renomear(.T.) } )
SetKey( VK_F4, { || Atualizar() } )
SetKey( VK_F7, { || CriaDir() } )
//SetKey( K_DEL, { || Apagar( aServFiles[oServer:nAt], aLocaFiles[oLocal:nAt] ) } )

Define MsDialog oDlg Title 'Copia Client/Server' From 0, 0 To 460, 990 Of oMainWnd Pixel
oDlg:lMaximized := .T.

@  20,  05 Say   'Server:'               Size  20, 6 Of oDlg Pixel
@  19,  28 MSGet oServGet Var cServPath  Size 140, 5 Of oDlg Pixel When .F.

@  38, 337 BtnBmp oBmpServ               Resource 'FOLDER5'   Size 22, 22 Action ( oServer:SetFocus(), LeDir() )
oBmpServ:cToolTip := "Seleciona Pasta no 'Server'"

@  39, 356 BtnBmp oBmpAcServ             Resource 'CGETFILE_10'  Size 22, 22 Action ( oServer:SetFocus(), SobeDir() )
oBmpAcServ:cToolTip := 'Recua um nivel'

@  34,  05 ListBox oServer Fields Header '', 'Nome', 'Tamanho', 'Data', 'Hora', 'Atributos' Size 234, 160  Of oDlg Pixel
oServer:SetArray( aServFiles )
oServer:bLine        := { || aServFiles[oServer:nAt] }
oServer:bGotFocus    := { || oLbxAtual := oServer, cPathAtual := cServPath, cObjFocus  := 'S' }
oServer:blDblClick   := { || AltCelula( aServFiles, oServer, cServPath ) }
oServer:bHeaderClick := { |oObj, nCol| SortDir( 1, nCol ) }
oServer:bRClicked    := { || MenuPop( 10, 100) }

@  20, 260 Say   'Local:'   /*Size  20, 6*/ Of oDlg Pixel
@  19, 285 MSGet oLocalGet Var cLocaPath  Size 140, 5 Of oDlg Pixel When .F.

@  38, 850 BtnBmp oBmpLoca                Resource 'FOLDER5'     Size 22, 22 Action ( oLocal:SetFocus(), LeDir() )
oBmpLoca:cToolTip := "Seleciona Pasta 'Local'"

@  39, 870 BtnBmp oBmpAcLoca              Resource 'CGETFILE_10' Size 22, 22 Action ( oLocal:SetFocus(), SobeDir() )
oBmpAcLoca:cToolTip := 'Recua um nivel'

@  34, 260 ListBox oLocal Fields Header '', 'Nome', 'Tamanho', 'Data', 'Hora', 'Atributos' Size 234, 160 Of oDlg Pixel
oLocal:SetArray( aLocaFiles )
oLocal:bLine         := { || aLocaFiles[oLocal:nAt] }
oLocal:bGotFocus     := { || oLbxAtual := oLocal, cPathAtual := cLocaPath, cObjFocus  := 'L' }
oLocal:blDblClick    := { || AltCelula( aLocaFiles, oLocal, cLocaPath ) }
oLocal:bHeaderClick  := { |oObj, nCol| SortDir( 2, nCol ) }
oLocal:bRClicked     := { || MenuPop( 10, 100) }

@  80, 490 BtnBmp oBmpLoca6  Resource 'PMSRRFSH'   Size 22, 22  Action ( Atualizar() )
oBmpLoca6:cToolTip := 'Atualizar ( F4 )'

@ 105, 490 BtnBmp oBmpLoca1  Resource 'LEFT'       Size 22, 22 Action MsgRun( 'Copiando para o Server ...', '', { || Copiar( aLocaFiles[oLocal:nAt] , 1 ) } )
oBmpLoca1:cToolTip := "Copiar para 'Server'"

@ 130, 490 BtnBmp oBmpLoca2  Resource 'RIGHT'      Size 22, 22 Action MsgRun( 'Copiando para o Local ...' , '', { || Copiar( aServFiles[oServer:nAt], 2 ) } )
oBmpLoca2:cToolTip := "Copiar para 'Local'"

@ 155, 490 BtnBmp oBmpLoca10  Resource 'LEFT2'      Size 22, 22 Action ;
MsgRun( 'Copiando para o Server ...' , '', { || CopiarTodos( aLocaFiles, 1 ) } )
oBmpLoca10:cToolTip := "Copiar TODOS para 'Server'"

@ 180, 490 BtnBmp oBmpLoca11  Resource 'RIGHT_2'     Size 22, 22 Action ;
MsgRun( 'Copiando para o Local ...' ,  '', { || CopiarTodos( aServFiles, 2 ) } )
oBmpLoca11:cToolTip := "Copiar TODOS para 'Local'"

@ 205, 490 BtnBmp oBmpLoca4  Resource 'CANCEL'     Size 22, 22 Action ( Apagar( aServFiles[oServer:nAt], aLocaFiles[oLocal:nAt]) )
oBmpLoca4:cToolTip := 'Excluir'

@ 230, 490 BtnBmp oBmpLoca5  Resource 'EDIT'       Size 22, 22 Action ( Renomear() )
oBmpLoca5:cToolTip := 'Renomear ( F2 )'

@ 255, 490 BtnBmp oBmpLoca7  Resource 'FOLDER10'    Size 22, 22 Action ( CriaDir() )
oBmpLoca7:cToolTip := 'Criar Pasta ( F7 )'

//@ 280, 380 BtnBmp oBmpLoca8  Resource 'FOLDER7'    Size 18, 18 Action ( RemoveDir( ) )
//oBmpLoca8:cToolTip := 'Remove Pasta'

//@ 280, 380 BtnBmp oBmpLoca9  Resource 'PCO_COEXC'  Size 18, 18 Action ( RemoveDir() )
//oBmpLoca9:cToolTip := 'Remove Arvore'

@ 330, 490 BtnBmp oBmpLoca3  Resource 'ENGRENAGEM' Size 22, 22 Action ( Dbf2Dtc( cServPath + aServFiles[oServer:nAt][NPOSLBXNOME] ) , LeDir( .F. ) )
oBmpLoca3:cToolTip := 'Converter'

@ 195,   5  Say 'Ambiente: ' + IIf( IsSrvUnix()         , 'Linux/Unix', 'Windows' ) Size 95, 7 Of oDlg Pixel
@ 195, 260  Say 'Ambiente: ' + IIf( GetRemoteType() == 2, 'Linux/Unix', 'Windows' ) Size 95, 7 Of oDlg Pixel

@ 207,   5  Say 'Pesquisar' Size 25, 7 Of oDlg Pixel

@ 205,  35 MSGet oPesq  Var cPesq  Size 120, 10 Message 'Pesquisa' Of oDlg Pixel Picture '@!'
//Valid ( nPosArq := IIf( !Empty( cPesq ) , aScan( IIf( cObjFocus == 'S', aServFiles, aLocaFiles ) , { | z | AllTrim( cPesq ) $ z[1] .OR. AllTrim( cPesq ) $ z[2] } ) ,  oLbx:nAt ) , IIf( nPosArq <> 0,  oLbx:nAt :=  nPosArq, ApMsgStop( 'Nใo encontrado' ) ) ,  oLbx:Refresh() , If( nPosArq <> 0,  nPosLbx :=  nPosArq, ) , ( nPosArq <> 0 ) )

@ 205, 155 Button  oButPrx Prompt ' > > ' Size 12, 12  ;
Action PesqPrx( IIf( cObjFocus == 'S', @oServer, @oLocal ) , IIf( cObjFocus == 'S', aServFiles, aLocaFiles ) , cPesq, nPosArq, nPosLbx ) ;
Message 'Pesquisa Pr๓ximo' Of oDlg Pixel

@ 210, 370  Say 'V1.5' Color CLR_RED Size 25, 7 Of oDlg Pixel

oServer:SetFocus()

Activate MsDialog oDlg //On Init EnchoiceBar( oDlg, { || lOk := .T., oDlg:End() } , { || lOk := .F., oDlg:End() } ) Centered

SetKey( VK_F4, NIL )
SetKey( VK_F2, NIL )
Return NIL
/*
Static Function Copiar2()
Local lRet := .T.
If cObjFocus == 'S'
Copiar( aServFiles[oServer:nAt], 2 )
Else
Copiar( aLocaFiles[oLocal:nAt] , 1 )
EndIf

Return lRet
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณCopiar    บAutor  ณ Ernani Forastieri  บ Data ณ  11/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Copia de arquivo / pasta                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Copiar( aFileCop, nOnde )
Local lRet       := .T.
Local aFileOrig  := aClone( aFileCop )

If 'D' $ aFileOrig[NPOSLBXATRIB]
	
	If Left( aFileOrig[NPOSLBXNOME], 1 ) <> '.'
		
		If      nOnde == 1
			MyMkDir( cServPath, aFileOrig[NPOSLBXNOME] )
			DesceDir( aFileOrig[NPOSLBXNOME], 1 )
			DesceDir( aFileOrig[NPOSLBXNOME], 2 )
			CopiarTodos( aLocaFiles, 1 )
			
		Else
			MyMkDir( cLocaPath, aFileOrig[NPOSLBXNOME] )
			DesceDir( aFileOrig[NPOSLBXNOME], 1 )
			DesceDir( aFileOrig[NPOSLBXNOME], 2 )
			CopiarTodos( aServFiles, 2 )
			
		EndIf
		
		SobeDir( 1 )
		SobeDir( 2 )
		
	EndIf
	
	//
	// ApMsgInfo( 'C๓pia de pasta ainda nใo disponํvel', 'ATENวรO' )
	//
	
Else
	If      nOnde == 1
		lRet := CpyCS( cLocaPath + aFileOrig[NPOSLBXNOME], cServPath )
		
	ElseIf nOnde == 2
		lRet := CpyCS( cServPath + aFileOrig[NPOSLBXNOME], cLocaPath )
		
	EndIf
	
EndIf

If !lRet
	ApMsgStop( 'Erro na c๓pia', 'ATENวรO' )
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณCopiarTodoบAutor  ณ Ernani Forastieri  บ Data ณ  11/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Copia todos os arquivo / pasta                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CopiarTodos( aFiles, nOnde )
Local lRet := .T.
Local nI   := 0

For nI := 1 To Len( aFiles )
	Copiar( aFiles[nI], nOnde )
Next

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณCpyCS     บAutor  ณ Ernani Forastieri  บ Data ณ  11/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua Copia de arquivos                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CpyCS( cFile, cDestino )
Local cFileAux  := ExtractFile( cFile )
Local lContinua := .T.
Local aDirOri   := {}
Local aDirDest  := {}
Local cMsg
Local lRet      := .T.

If File( cDestino + cFileAux )
	aDirOri   := Directory( cFile )
	aDirDest  := Directory( cDestino + cFileAux )
	cMsg := "Esta pasta jแ cont้m um arquivo chamado '" + cFileAux + "' "  + CRLF + CRLF
	cMsg += 'Deseja substituir o arquivo existente de ' + CRLF + CRLF
	cMsg += '    ' + Tamanho( aDirDest[1][NPOSDIRTAMANHO] ) + CRLF
	cMsg += '    modificado ' + IIf( aDirDest[1][NPOSDIRDATA] == Date() , 'hoje', Lower( DiaExtenso( aDirDest[1][NPOSDIRDATA] ) ) ) + ',  ' + DataExtenso( aDirDest[1][NPOSDIRDATA] ) + ',  ' + aDirDest[1][NPOSDIRHORA] + CRLF + CRLF // + ', Tamanho ' + AllTrim( Str( aDirDest[1][2] ) ) + ' b' + CRLF + CRLF
	cMsg += 'por este ? ' + CRLF + CRLF
	cMsg += '    ' + Tamanho( aDirOri[1][NPOSDIRTAMANHO] ) + CRLF
	cMsg += '    modificado ' + IIf( aDirOri[1][NPOSDIRDATA] == Date() , 'hoje', Lower( DiaExtenso( aDirOri[1][NPOSDIRDATA] ) ) ) + ',  ' + DataExtenso( aDirOri[1][NPOSDIRDATA] ) + ',  ' + aDirOri[1][NPOSDIRHORA] // + ', Tamanho ' + AllTrim( Str( aDirOri[1][2] ) ) + ' b' + CRLF
	lContinua := ApMsgYesNo( cMsg, 'Confirmar substitui็ใo de arquivo' )
EndIf

If lContinua
	If Left( cFile, 1 ) == '\'
		lRet := CpyS2T( cFile, cDestino, .T. )   // Copia arquivo do Server para o Remote
		//oLocal:SetFocus()
		LeDir( .F., 2 )
		//oServer:SetFocus()
	Else
		lRet := CpyT2S( cFile, cDestino, .T. )
		//oServer:SetFocus()
		LeDir( .F., 1 )
		//oLocal:SetFocus()
		
	EndIf
EndIf

SysRefresh()
ProcessMessage()

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณLeDir     บAutor  ณ Ernani Forastieri  บ Data ณ  11/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Le Diretorios                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeDir( lAsk, nTipo )
Local cFolder  := NIL
Default lAsk := .T.

If     nTipo == NIL
	If     cObjFocus  == 'S'
		nTipo := 1
	ElseIf cObjFocus  == 'L'
		nTipo := 2
	EndIf
Endif

If     nTipo == 1
	If lAsk
		cFolder := cGetFile( , 'Selecione a Pasta',, cServPath, .T., GETF_ONLYSERVER + GETF_RETDIRECTORY )
		cServPath := IIf( Empty( cFolder ) , cServPath, cFolder )
		oServGet:Refresh()
	EndIf
	
	If ( !Empty( cServPath ) ) .OR. ( !lAsk )
		aServFiles    := MyDirec( cServPath + '*.*', 'D' )
		oServer:SetArray( aServFiles )
		oServer:bLine := { || aServFiles[oServer:nAt] }
		oServer:SetFocus()
		If lPosFirst
			oServer:nAt := 1
		EndIf
		oServer:Refresh()
		oServGet:Refresh()
	EndIf
	
ElseIf nTipo == 2
	If lAsk
		cFolder := cGetFile( , 'Selecione a Pasta',, cLocaPath, .T., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY, .F.)
		cLocaPath := IIf( Empty( cFolder ) , cLocaPath, cFolder )
		oLocalGet:Refresh()
	EndIf
	
	If ( !Empty( cServPath ) ) .OR. ( !lAsk )
		aLocaFiles   := MyDirec( cLocaPath + '*.*', 'D' )
		oLocal:SetArray( aLocaFiles )
		oLocal:bLine := { || aLocaFiles[oLocal:nAt] }
		oLocal:SetFocus()
		If lPosFirst
			oLocal:nAt := 1
		EndIf
		oLocal:Refresh()
		oLocalGet:Refresh()
	EndIf
	
EndIf

Return .T.

// ???? Acho que tenta converter....
Static Function Dbf2Dtc( cFile )
Local cDestino := StrTran( Upper( cFile ) , '.DBF', '.DTC' )
Local cAlias   := CriaTrab( , .F. )
Local aStruct  := NIL

ApMsgInfo( 'Funcionalidade ainda nใo disponํvel.', 'ATENวรO' )
Return NIL


If Right( Upper( cFile ) , 4 ) # '.DBF'
	Return( .F. )
EndIf

dbUseArea( .T., 'DBFCDX', cFile, cAlias, .F., .F. )

aStruct := dbStruct()

( cAlias )->( dbCloseArea() )

dbCreate( cDestino, aStruct, 'CTREECDX' )

dbUseArea( .T., 'CTREECDX', cDestino, cAlias, .F., .F. )

__dbApp( cFile,,,,,,, 'DBFCDX' )

( cAlias )->( dbCloseArea() )

Return

/*
Static Function RemovePath( cFile )
Local nPos      := RAt( '\', cFile )
Local cFileName := SubStr( cFile, nPos + 1 )
Return( cFileName )
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ Apagar   บAutor  ณErnani Forastieri   บ Data ณ  15/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Delecao de arquivos                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Apagar( aServer, aLocal )
Local cMsg    := ''
Local aArq    := ''
Local cTitulo := 'Confirmar exclusใo'
Local cpath   := ''

If     cObjFocus == 'S'
	aArq  := aServer
	cPath := cServPath
	
ElseIf cObjFocus == 'L'
	aArq := aLocal
	cPath := cLocaPath
	
EndIf

If 'D' $ aArq[NPOSLBXATRIB]
	If Left( aArq[NPOSLBXNOME], 1 ) <> '.'
		cMsg := "Tem certeza que deseja a Pasta '"  + AllTrim( aArq[NPOSLBXNOME] ) + "' e TODOS os arquivos ?"
	EndIf
	
	If RemoveDir()
		lPosFirst := .F.
		LeDir( .F. )
		lPosFirst := .T.
		
	EndIf
	
Else
	cMsg := "Tem certeza que deseja apagar o arquivo '"  + AllTrim( aArq[NPOSLBXNOME] ) + "' ?"
	
	cArq := cPath + AllTrim( aArq[NPOSLBXNOME] )
	
	If ApMsgYesNo( cMsg, cTitulo )
		
		If FErase( cArq ) <> 0
			ApMsgStop( "Nใo foi possํvel excluir o arquivo '" + AllTrim( aArq[NPOSLBXNOME] ) + "' ", cTitulo )
		EndIf
		
		lPosFirst := .F.
		LeDir( .F. )
		lPosFirst := .T.
		
	EndIf
	
EndIf


Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ Renomear บAutor  ณErnani Forastieri   บ Data ณ  15/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de renomear arquivos                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Renomear(lSetar)

Default lSetar := .F.

If     cObjFocus == 'S'
	If lSetar
		oServer:ColPos := NPOSLBXNOME
	EndIf
	
	AltCelula( aServFiles, oServer, cServPath )
	
ElseIf cObjFocus == 'L'
	If lSetar
		oLocal:ColPos := NPOSLBXNOME
	EndIf
	
	AltCelula( aLocaFiles, oLocal, cLocaPath )
	
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ AltCelulaบAutor  ณErnani Forastieri   บ Data ณ  15/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de alteracao de celulas                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AltCelula( aLbx, oLbx, cPath )
Local cArqAnt := ''

If !Empty( aLbx[oLbx:nAt][NPOSLBXNOME] )
	If     oLbx:ColPos == NPOSLBXNOME
		
		If 'D' $ aLbx[oLbx:nAt][NPOSLBXATRIB] .and. !IsInCallStack('RENOMEAR')
			MoveDir( aLbx[oLbx:nAt][NPOSLBXNOME] )
			
		Else
			cArqAnt := aLbx[oLbx:nAt][NPOSLBXNOME]
			cPath   := AllTrim( cPath )
			aLbx[oLbx:nAt][NPOSLBXNOME] := PadR( aLbx[oLbx:nAt][NPOSLBXNOME], 30 )
			
			lEditCell( aLbx, oLbx, '@!', oLbx:ColPos )
			
			If AllTrim( cArqAnt ) <> AllTrim( aLbx[oLbx:nAt][NPOSLBXNOME] )
				If FRename( cPath + cArqAnt, cPath + aLbx[oLbx:nAt][NPOSLBXNOME] )  <> 0
					aLbx[oLbx:nAt][NPOSLBXNOME] := cArqAnt
					ApMsgStop( "Nใo foi possํvel renomear o arquivo '" + AllTrim( cArqAnt ) + "' ", 'ATENวรO' )
				EndIf
				aLbx[oLbx:nAt][NPOSLBXNOME] := AllTrim( aLbx[oLbx:nAt][NPOSLBXNOME] )
			EndIf
		EndIf
		
		//	ElseIf oLbx:ColPos == NPOSLBXBITMAP	.AND. 'D' $ aLbx[oLbx:nAt][NPOSLBXATRIB]
		//		MoveDir( aLbx[oLbx:nAt][NPOSLBXNOME] )
		
	Else
		
		If  'D' $ aLbx[oLbx:nAt][NPOSLBXATRIB]
			MoveDir( aLbx[oLbx:nAt][NPOSLBXNOME] )
		Else
			Abrir()
		EndIf
		
	EndIf
	
Else
	ApMsgStop( 'Sem arquivos na pasta', 'ATENวรO' )
	
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ MoveDir  บAutor  ณErnani Forastieri   บ Data ณ  15/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Sobe ou desce nivel da pasta                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MoveDir( cPath )

If !(Len( AllTrim( cPath ) ) == 1 .and. left( cPath, 1 ) = '.' )
	If '..' $ cPath
		SobeDir()
	Else
		DesceDir( cPath )
	EndIf
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณDataExtensบAutor  ณErnani Forastieri   บ Data ณ  15/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Data por extenso                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DataExtenso( dData )
Return AllTrim( Str( Day( dData ) ) ) + ' de ' + Nome_Mes( Month( dData ) ) + ' de ' + AllTrim( Str( Year( dData ) ) )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ AltCelulaบAutor  ณErnani Forastieri   บ Data ณ  15/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de renomear arquivos                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Atualizar()
LeDir( .F. )
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ Tamanho บAutor  ณErnani Forastieri    บ Data ณ  15/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o tamamho do arquivo                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso Geral                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tamanho( nTam )
cRet := ''

If     nTam > 1073741824
	cRet := AllTrim( Str( Round( nTam / 1073741824, 2 ) ) ) + ' GB'
	
ElseIf nTam > 1048576
	cRet := AllTrim( Str( Round( nTam / 1048576, 2 ) ) ) + ' MB'
	
ElseIf nTam > 1024
	cRet := AllTrim( Str( Round( nTam / 1024, 2 ) ) ) + ' KB'
	
Else
	cRet := AllTrim( Str( nTam  ) ) + ' bytes'
	
EndIf

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ SortDir  บAutor  ณ Ernani Forastieri  บ Data ณ  25/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classifica Lista                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SortDir( nLado, nColuna )
Local aPastas := {}
Local aPonto  := {}
Local aFiles  := {}

If     nLado == 1
	aEval( aServFiles, { |x| IIf( x[NPOSLBXORDBY] == '0', IIf( Left( x[NPOSLBXNOME],1 ) == '.', aAdd( aPonto, x ), aAdd( aPastas, x ) ), aAdd( aFiles, x ) ) } )
	
	If aClickServ[nColuna]
		//aSort( aServFiles,,, { | z, w | w[NPOSLBXORDBY] > z[NPOSLBXORDBY] .and. AllToChar(w[nColuna]) > AllToChar(z[nColuna]) } )
		aSort( aPastas,,, { | z, w | w[nColuna] > z[nColuna] } )
		aSort( aFiles ,,, { | z, w | w[nColuna] > z[nColuna] } )
	Else
		//aSort( aServFiles,,, { | z, w | w[NPOSLBXORDBY] < z[NPOSLBXORDBY] .and. AllToChar(w[nColuna]) < AllToChar(z[nColuna]) } )
		aSort( aPastas,,, { | z, w | w[nColuna] < z[nColuna] } )
		aSort( aFiles ,,, { | z, w | w[nColuna] < z[nColuna] } )
	EndIf
	
	aServFiles := {}
	aEval( aPonto , { |x| aAdd( aServFiles, x ) } )
	aEval( aPastas, { |x| aAdd( aServFiles, x ) } )
	aEval( aFiles , { |x| aAdd( aServFiles, x ) } )
	
	aClickServ[nColuna] := !aClickServ[nColuna]
	
	oServer:SetArray( aServFiles )
	oServer:bLine      := { || aServFiles[oServer:nAt] }
	oServer:Refresh()
	
Else
	
	aEval( aLocaFiles, { |x| IIf( x[NPOSLBXORDBY] == '0', IIf( Left( x[NPOSLBXNOME],1 ) == '.', aAdd( aPonto, x ), aAdd( aPastas, x ) ), aAdd( aFiles, x ) ) } )
	
	If aClickLoca[nColuna]
		//aSort( aLocaFiles,,, { | z, w | w[nColuna] > z[nColuna] } )
		aSort( aPastas,,, { | z, w | w[nColuna] > z[nColuna] } )
		aSort( aFiles ,,, { | z, w | w[nColuna] > z[nColuna] } )
		
	Else
		//aSort( aLocaFiles,,, { | z, w | w[nColuna] < z[nColuna] } )
		aSort( aPastas,,, { | z, w | w[nColuna] < z[nColuna] } )
		aSort( aFiles ,,, { | z, w | w[nColuna] < z[nColuna] } )
		
	EndIf
	
	aLocaFiles := {}
	aEval( aPonto , { |x| aAdd( aLocaFiles, x ) } )
	aEval( aPastas, { |x| aAdd( aLocaFiles, x ) } )
	aEval( aFiles , { |x| aAdd( aLocaFiles, x ) } )
	
	aClickLoca[nColuna] := !aClickLoca[nColuna]
	
	oLocal:SetArray( aLocaFiles )
	oLocal:bLine      := { || aLocaFiles[oLocal:nAt] }
	oLocal:Refresh()
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ PESQPRX  บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Pesquisa                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PesqPrx( oLbx, aLbx, cPesq, nPosArq, nPosLbx )
Local cAux := AllTrim( cPesq )
Local nTam := Len( cAux )

If !Empty( cPesq )
	nPosArq := aScan( aLbx, { | x | Upper( cAux ) == Upper( SubStr( x[NPOSLBXNOME], 1, nTam ) ) } , 1 )
EndIf

If  nPosArq <> 0
	oLbx:nAt :=  nPosArq
	oLbx:SetFocus()
Else
	//ApMsgStop( 'Arquivo nใo encontrado na pasta ' + IIf( cObjFocus == 'S', "'Server'", "'Local'" ) , 'PESQUISA' )
	ApMsgStop( 'Arquivo nใo encontrado na pasta ' + IIf( cObjFocus == 'S', cServPath, cLocaPath ) , 'PESQUISA' )
EndIf

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ CriaDir  บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cria nova pasta no Server ou Local                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaDir( nTipo )

If     nTipo == NIL
	If     cObjFocus  == 'S'
		nTipo := 1
	ElseIf cObjFocus  == 'L'
		nTipo := 2
	EndIf
Endif

If     nTipo == 1
	cServPath += MyMkDir( cServPath )
	LeDir( .F., 1 )
	
ElseIf nTipo == 2
	cLocaPath += MyMkDir( cLocaPath )
	LeDir( .F., 2 )
	
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณMYMAKEDIR บAutor  ณ Ernani Forastieri  บ Data ณ  02/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para criacao de diretorios                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyMkDir( cPath, cDirNovo )
Local oDlg
Local oDir
Local cDir       := Space( 40 )
Local lOk        := .F.
Local cDirTrb    := ''
Local cDirCriar  := '\'
Local nPosBarra  := 0
Local nAux       := 0
Local cTitJanela := ''
Local cRet       := ''

If cObjFocus == 'S'
	cTitJanela := 'Criar Pasta no Server'
	
Else
	cTitJanela := 'Criar Pasta Local'
	
EndIf

If cDirNovo == NIL
	Define MsDialog oDlg Title cTitJanela From 178, 181 To 264, 391 Pixel
	
	@ 005, 006 Say 'Nome da Pasta' Size 100, 008 Pixel Of oDlg
	@ 015, 005 MsGet oDir Var cDir Size 100, 009 Pixel Of oDlg
	
	Define SButton From 027, 042 Type 2 Enable Of oDlg Action ( lOk := .F., oDlg:End()  )
	Define SButton From 027, 075 Type 1 Enable Of oDlg Action ( lOk := .T., oDlg:End()  )
	
	Activate MsDialog oDlg Centered
	
	If !lOk
		Return ''
	EndIf
	
Else
	cDir := cDirNovo
	
EndIf

If !Empty( cDir )
	cPath     := BarraFinal( AllTrim( cPath ) )
	cDir      := BarraFinal( NoBarraInic( AllTrim( cDir  ) ) )
	cDirTrb   := BarraFinal( cPath + cDir )
	
	If ':' $ cDirTrb
		nAux      := At( '\', cDirTrb )
		cDirCriar := SubStr( cDirTrb, 1, nAux )
		cDirTrb   := SubStr( cDirTrb, nAux + 1 )
	Else
		cDirCriar :=  '\'
	EndIf
	
	nPosBarra := 0
	
	While Len( cDirTrb ) > 0
		nPosBarra := At( '\', cDirTrb )
		
		If nPosBarra > 2
			cDirCriar += SubStr( cDirTrb, 1, nPosBarra )
			If MakeDir( cDirCriar ) < 0
				ApMsgStop( 'Erro na cria็ใo da pasta ' + Alltrim( cDirCriar ), 'ATENวรO' )
				Return NIL
			EndIf
		EndIf
		
		cDirTrb   := SubStr( cDirTrb, nPosBarra + 1 )
	End
	
Else
	cDir := ''
	
EndIf

Return cDir


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณRemoveDir บAutor  ณ Ernani Forastieri  บ Data ณ  16/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Remove uma pasta no Server ou Local                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RemoveDir()
Local cMsg       := ''
Local cPath      := ''
//Local cAcima     := ''
Local nTipo      := 0
Local lCompleto  := .F.
Local lArquivos  := .F.

If     cObjFocus == 'S'
	cPath      := cServPath + AllTrim( aServFiles[oServer:nAt][NPOSLBXNOME] )
	nTipo      := 1
	
ElseIf cObjFocus == 'L'
	cPath      := cLocaPath + AllTrim( aLocaFiles[oLocal:nAt][NPOSLBXNOME] )
	nTipo      := 2
	
EndIf

lCompleto  := .T.
lArquivos  := .T.
cMsg       := 'MUITO CUIDADO !!! esta op็ใo remove TODA A ARVORE de pastas selecionada.'+ CRLF + 'Confirma a exclusใo ' + Alltrim( cPath )


If ApMsgNoYes( cMsg, 'ATENวรO' )
	
	//cAcima := DirAcima( cPath )
	
	If !MyDirRemove( cPath, 1, lCompleto, lArquivos )
		ApMsgStop( 'Problemas na exclusใo da pasta' , 'ATENวรO' )
	EndIf
	
	//If     cObjFocus == 'S'
	//	cServPath := cAcima
	//Else
	//	cLocaPath := cAcima
	//EndIf
	
	LeDir( .F. )
	
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณMyDirRemovบAutor  ณ Ernani Forastieri  บ Data ณ  16/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para remover diretorios a partir do Root            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyDirRemove( cDir, nTipo, lCompleto, lElimArq )
Local lRet      := .T.
Local cDirTrb   := cDir + IIf( SubStr( cDir, Len( cDir ), 1 ) <> '\', '\', '' )
Local cDirElim  := '\'
Local nPosBarra := 0
Local aLimpar   := {}
Local nI        := 0

lCompleto := IIf( lCompleto == NIL, .F., lCompleto )
lElimArq  := IIf( lElimArq  == NIL, .F., lElimArq  )
cDir      := BarraFinal( cDir )

If lCompleto
	
	//
	// Elimina toda a arvore do diretorio
	//
	//While Len( cDirTrb ) > 0
	nPosBarra := RAt( '\', cDirTrb )
	
	If nPosBarra > 2
		cDirElim := SubStr( cDirTrb, 1, nPosBarra )
		
		If lIsDir( cDirElim )
			//
			// Elimina arquivos do diretorio
			//
			If lElimArq
				aLimpar := Directory( cDirElim + '*.*', 'D' )
				aSort( aLimpar,,, { | z, w | w[NPOSDIRATRIB]+w[NPOSDIRNOME] < z[NPOSDIRATRIB]+z[NPOSDIRNOME] } )
				
				For nI := 1 To Len( aLimpar )
					If SubStr(aLimpar[nI][NPOSDIRNOME], 1, 1 ) <> '.'
						
						If aLimpar[nI][NPOSDIRATRIB] == 'D'
							MyDirRemove( AllTrim( cDirElim + aLimpar[nI][NPOSDIRNOME] ), nTipo, lCompleto, lElimArq )
						EndIf
						
						FErase( cDirElim + aLimpar[nI][NPOSDIRNOME] )
						
					EndIf
				Next
				
				
			EndIf
			
			If !( lRet := DirRemove( cDirElim ) )
				//Exit
			EndIf
			
		EndIf
		
	EndIf
	
	//	cDirTrb := SubStr( cDirTrb, 1, nPosBarra - 1 )
	//End
	
Else
	
	//
	// Elimina so o nivel mais baixo do diretorio
	//
	If lIsDir( cDir )
		
		//
		// Elimina arquivos do diretorio
		//
		If lElimArq
			aLimpar := Directory( cDir + '*.*' )
			aEval( aLimpar, { |y, x| FErase( cDir + aLimpar[x][NPOSDIRNOME] ) } )
		EndIf
		
		lRet := DirRemove( cDir )
	EndIf
	
EndIf


Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBarraFinalบAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para colocar a barra final numa string de diretorio บฑฑ
ฑฑบ          ณ local ou FTP                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BarraFinal( cDir, lNormal )
Local cRet := ''
Local cBarraFinal := ''

lNormal     := IIf( lNormal  == NIL, .F., lNormal )
cBarraFinal := IIf( lNormal, '/', '\' )

cRet := Alltrim( cDir )
cRet += IIf( SubStr( cRet, Len( cRet ), 1 ) <> cBarraFinal, cBarraFinal, '' )

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNoBarraFinบAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para retirar a barra final numa string de diretorio บฑฑ
ฑฑบ          ณ local ou FTP                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NoBarraFinal( cDir, lNormal )
Local cRet := ''
Local cBarraFinal := ''

lNormal     := IIf( lNormal  == NIL, .F., lNormal )
cBarraFinal := IIf( lNormal, '/', '\' )

cRet := Alltrim( cDir )
cRet := IIf( SubStr( cRet, Len( cRet ), 1 ) == cBarraFinal, SubStr( cRet, 1, Len( cRet ) - 1 ), cRet )

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNoBarraIniบAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para retirar a barra incial numa string de diretorioบฑฑ
ฑฑบ          ณ local ou FTP                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NoBarraInic( cDir, lNormal )
Local cRet := ''
Local cBarraFinal := ''

lNormal     := IIf( lNormal  == NIL, .F., lNormal )
cBarraFinal := IIf( lNormal, '/', '\' )

cRet := Alltrim( cDir )
cRet := IIf( SubStr( cRet, 1, 1 ) == cBarraFinal, SubStr( cRet, 2 ), cRet )

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SobeDir  บAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Recua um nivel de diretorio                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SobeDir( nTipo )
Local cRet := ''

If     nTipo == NIL
	If     cObjFocus  == 'S'
		nTipo := 1
	ElseIf cObjFocus  == 'L'
		nTipo := 2
	EndIf
Endif

If     nTipo == 1
	If cServStart <> cServPath
		cRet := DirAcima( cServPath )
		cServPath := cRet
		LeDir( .F., 1 )
	EndIf
	
ElseIf nTipo == 2
	If cLocaStart <> cLocaPath
		cRet := DirAcima( cLocaPath )
		If ':' $ cRet
			cLocaPath := cRet
			LeDir( .F., 2 )
		EndIf
	EndIf
	
EndIf

//oDlg:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNoBarraIniบAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para retirar a barra incial numa string de diretorioบฑฑ
ฑฑบ          ณ local ou FTP                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DirAcima( cDir )
Local cRet := ''
cRet := NoBarraFinal( cDir )
cRet := SubStr( cRet, 1, RAt( '\', cRet ) )
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMyDirec   บAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ faz a leitura dos arquivos de uma pasta ordenando          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyDirec( cPath, cAtrib )
Local aDir     := Directory( cPath + '*.*', cAtrib )
Local nI       := 0
Local aRet     := {}
Local aAuxArq  := {}
Local aAuxDir  := {}
Local oArq	   := LoadBitMap(GetResources(), 'ENABLE')
Local oDir	   := LoadBitMap(GetResources(), 'FOLDER5')
Local oRA 	   := LoadBitMap(GetResources(), 'DISABLE')
Local nMax     := 0


aEval( aDir, { |x| nMax := Max( Len( x[NPOSDIRNOME] ), nMax ) } )

For nI := 1 To Len( aDir )
	If      'D' $ aDir[nI][NPOSDIRATRIB]
		aAdd( aAuxDir, { oDir, PadR( aDir[nI][NPOSDIRNOME], nMax ), Round( aDir[nI][NPOSDIRTAMANHO]/1024,0 ), aDir[nI][NPOSDIRDATA], aDir[nI][NPOSDIRHORA], aDir[nI][NPOSDIRATRIB], '0' } )
	ElseIf  'R' $ aDir[nI][NPOSDIRATRIB]
		aAdd( aAuxArq, { oRA , PadR( aDir[nI][NPOSDIRNOME], nMax ), Round( aDir[nI][NPOSDIRTAMANHO]/1024,0 ), aDir[nI][NPOSDIRDATA], aDir[nI][NPOSDIRHORA], aDir[nI][NPOSDIRATRIB], '1' } )
	Else
		aAdd( aAuxArq, { oArq, PadR( aDir[nI][NPOSDIRNOME], nMax ), Round( aDir[nI][NPOSDIRTAMANHO]/1024,0 ), aDir[nI][NPOSDIRDATA], aDir[nI][NPOSDIRHORA], aDir[nI][NPOSDIRATRIB], '1' } )
	EndIf
Next

If Len( aDir ) == 0
	aLocaFiles := { { '', '', 0, CToD( '' ) , '' } }
EndIf

//aSort( aAuxDir,,, { | z, w | w[NPOSLBXNOME] > z[NPOSLBXNOME] } )
//aSort( aAuxArq,,, { | z, w | w[NPOSLBXNOME] > z[NPOSLBXNOME] } )
aEval( aAuxArq, { |x| aAdd( aAuxDir, x ) } )

aRet := aClone( aAuxDir )

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SobeDir  บAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Recua um nivel de diretorio                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DesceDir( cPath, nTipo )

If     nTipo == NIL
	If     cObjFocus  == 'S'
		nTipo := 1
	ElseIf cObjFocus  == 'L'
		nTipo := 2
	EndIf
Endif

If     nTipo == 1
	cServPath := BarraFinal( cServPath + AllTrim( cPath ) )
	
ElseIf nTipo == 2
	cLocaPath := BarraFinal( cLocaPath + AllTrim( cPath ) )
	
EndIf

LeDir( .F., nTipo )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuPop  บAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Menu de opcao do botao direito do ListBox                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuPop( nLeft, nTop )
//oMenu
Local oMenuItem	 := {}


MENU oMenu POPUP
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Opcoes do MENU.      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If cObjFocus == 'S'
	aAdd( oMenuItem, MenuAddItem( 'Copiar'  ,,, .T.,,,, oMenu, { || Copiar( aServFiles[oServer:nAt], 2 ) } ,,,,, { || .T. } ) )
Else
	aAdd( oMenuItem, MenuAddItem( 'Copiar'  ,,, .T.,,,, oMenu, { || Copiar( aLocaFiles[oLocal:nAt] , 1 )  } ,,,,, { || .T. } ) )
EndIf
aAdd( oMenuItem, MenuAddItem( 'Apagar'      ,,, .T.,,,, oMenu, { || Apagar( aServFiles[oServer:nAt], aLocaFiles[oLocal:nAt] ) } ,,,,, { || .T. } ) )
aAdd( oMenuItem, MenuAddItem( 'Renomear'    ,,, .T.,,,, oMenu, { || Renomear()                     } ,,,,, { || .T. } ) )
aAdd( oMenuItem, MenuAddItem( 'Abrir'       ,,, .T.,,,, oMenu, { || Abrir()                        } ,,,,, { || .T. } ) )
aAdd( oMenuItem, MenuAddItem( 'Nova Pasta'  ,,, .T.,,,, oMenu, { || CriaDir()                      } ,,,,, { || .T. } ) )

If cObjFocus == 'S'
	aAdd( oMenuItem, MenuAddItem( 'Copiar Todos'  ,,, .T.,,,, oMenu, { || CopiarTodos( aServFiles, 2 ) } ,,,,, { || .T. } ) )
Else
	aAdd( oMenuItem, MenuAddItem( 'Copiar Todos'  ,,, .T.,,,, oMenu, { || CopiarTodos( aLocaFiles, 1 )  } ,,,,, { || .T. } ) )
EndIf

ENDMENU

// As opcoes abaixo Desabilitam e Checam respectivamente o Item do Menu
//oMenu:aItems[1]:lActive := .F. // Desabilita a a Opcao
//oMenu:aItems[1]:lChecked := .T. // Opcao de Check True/False
//Activate POPUP oMenu AT MouseX() , MouseY()
oMenu:Activate( MouseX() , MouseY() , If ( cObjFocus == 'S', oServer, oLocal ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MouseX   บAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar do Menu POP                                บฑฑ
ฑฑบ          ณ Coordenada X                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MouseX()
//Return oDlg:oCtlFocus:nLeft + 2
If cObjFocus == 'S'
	//	nRet :=  oServer:nLeft + oServer:nHeight / 2
	nRet :=  oServer:nHeight / 2
Else
	//	nRet :=  oLocal:nLeft  + oLocal:nHeight  / 2
	nRet :=  oLocal:nHeight  / 2
EndIf
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MouseY   บAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar do Menu POP                                บฑฑ
ฑฑบ          ณ Coordenada Y                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MouseY()
//Return oDlg:nTop + oDlg:oCtlFocus:nTop + oDlg:oCtlFocus:nHeight + 100
Local nAlt := 17
If cObjFocus == 'S'
	//	nRet := oServer:nTop + nAlt + oServer:nAt*nAlt
	//	nRet := oServer:nWidth / 2 + oMenu:nWidth / 2
	nRet := 21 + ( oServer:nRowPos - 1 ) * nAlt
Else
	//	nRet := oLocal:nTop + nAlt + oLocal:nAt*nAlt
	//	nRet := oLocal:nWidth / 2 + oMenu:nWidth / 2
	nRet := 21 + ( oLocal:nRowPos - 1 ) * nAlt
EndIf

Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Abrir    บAutor  ณErnani Forastieri   บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abre arquivos usando o shell da maquina                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Abrir()
Local cTempPath := ''
Local lOk       := .F.
Local nRet      := 0

If cObjFocus == 'S'
	If !'D' $ aServFiles[oServer:nAt][NPOSLBXATRIB]
		cTempPath := GetTempPath()
		MsgRun( 'Aguarde ...', '', { || lOk := CpyS2T( BarraFinal( AllTrim( cServPath ) ) + AllTrim( aServFiles[oServer:nAt][NPOSLBXNOME] ) , cTempPath, .T. ) } )
		//ShellExecute( 'open', aServFiles[oServer:nAt][NPOSLBXNOME], '', '', 1 )
		If lOk
			nRet := ShellExecute( 'open', BarraFinal( cTempPath ) + AllTrim( aServFiles[oServer:nAt][NPOSLBXNOME] ) , '', cServPath, 1 )
		EndIf
	EndIf
Else
	If !'D' $ aLocaFiles[oLocal:nAt][NPOSLBXATRIB]
		//ShellExecute( 'open', aLocaFiles[oLocal:nAt][NPOSLBXNOME], '', '', 1 )
		//winexec( AllTrim( aLocaFiles[oLocal:nAt][NPOSLBXNOME] ) ,, cLocaPath )
		nRet := ShellExecute( 'open', AllTrim( aLocaFiles[oLocal:nAt][NPOSLBXNOME] ) , '', cLocaPath, 1 )
	EndIf
EndIf

If nRet <= 32
	ApMsgStop( 'Nใo existe aplicativo associado a este tipo de arquivo.', 'ATENวรO' )
EndIf

Return !(nRet <= 32)