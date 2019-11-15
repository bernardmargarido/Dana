#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE VAL_BSCII	19		// posicao do valor da BASE DE CALC I.I. (IMPOSTO IMPORTACAO)
#DEFINE VAL_II		20		// posicao do valor do I.I. (IMPOSTO IMPORTACAO)
#DEFINE VAL_DESPA	21		// posição do Valor do Despachante no Array
#DEFINE VAL_IOF		22		// posição do Valor do IOF no Array
#DEFINE GD_INSERT	1		// usado na MSNewGetDados
#DEFINE GD_UPDATE	2 		// usado na MSNewGetDados
#DEFINE GD_ALTERA	3 		// usado na MSNewGetDados
#DEFINE GD_DELETE	4		// usado na MSNewGetDados

User Function AlfSzf07()
	If SubStr(ZDH->ZDH_CHAVE,21,2) == "55"
	 Processa( {|| Principal()}, "Carregando a tela do XML - NFe.  Por favor, aguarde...")
	Else                                                      
	 Processa( {|| U_AlfVCTe()}, "Carregando a tela do XML - CTe.  Por favor, aguarde...")
	EndIf
Return



User Function AlfSZF0A()
Local _oDlgIni,_oPnlIni,_oSayIni,_oSayBrw,_oBtnPath,_oGetPath
Local _oFontMsg	:= TFont():New( 'Courier New',,15,,.t.)
Local _cMensIni := OemToAnsi("Este programa tem o objetivo de Pré-visualizar um Nota de Entrada através de arquivo no formato XML.")

Private _cGetpath	:= Space(30)	// Path + o arquivo escolhido atrave do cGetFile()

DEFINE MSDIALOG _oDlgIni FROM 010,000 TO 280,500 TITLE "Selecione o XML" PIXEL
@ 10,10 to 110,235 PIXEL
_oSayIni := tSay():New(15,15,{||_cMensIni},_oDlgIni,,_oFontMsg,,,,.T.,CLR_BLUE,,220,60)

_oSayBrw	:= tSay():New(65,30,{||"Localizar Arquivo em ..."},_oDlgIni,,_oFontMsg,,,,.T.,CLR_BLUE)
_oGetPath	:= TGet():New(75,30,{|u| if(PCount()>0,_cGetpath:=u,_cGetpath)}, _oDlgIni,150,10,'',,,,,,,.T.,,,,,,,.T.,,,'_cGetpath')
_oBtnPath	:= SButton():New(75,180,14,{||_cGetpath:=ALLTRIM(cGetFile(" *.XML ", 'Carga de Arquivo', 1,"", .F., GETF_LOCALHARD,.F.)),_oDlgIni:Refresh(),.T.},_oDlgIni,.T.,,)

DEFINE SBUTTON FROM 120, 150 TYPE 1 ACTION (Iif(Empty(_cGetpath),MsgAlert("Voce deve escolher um arquivo.","Arquivo"),Iif(PRINCIPAL(_cGetpath, "S" ),_cGetpath:="",.F.))) ENABLE OF _oDlgIni
DEFINE SBUTTON FROM 120, 200 TYPE 2 ACTION (_oDlgIni:End()) ENABLE OF _oDlgIni

ACTIVATE MSDIALOG _oDlgIni CENTERED

Return NIL


Static Function ChamaArq(cFile1)
	LjMsgRun("Carregando Informações..." ,,{|| PRINCIPAL(cFile1) })
Return

Static Function PRINCIPAL(cFile1, cAcao )
Local cError		:= ""
Local cWarning		:= ""
Local cCadastro		:= OemToAnsi("Pré-Visualização de NFe")
Local oVermelho		:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oVerde		:= LoadBitmap( GetResources(), "BR_VERDE" )
Local oOk			:= LoadBitMap(GetResources(),"LBOK")
Local oNo			:= LoadBitMap(GetResources(),"LBNO")
Local oFontCabec	:= TFont():New( 'Courier New',, 18,,.t.)
Local oFontItem		:= TFont():New( "Century",, 14,,.t.,,,,.t.)
//-- Controle de dimensoes de objetos
Local lEnchBar  	:= .T. // Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao   	:= .F. // Se a janela deve respeitar as medidas padrões do //Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY	    	:= 400 // Altura mínima da janela
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
Local aSize			:= {}
Local _cSchema 		:=  ""
// dados da enchoice
Local bBtnOk		:= {|| (Iif(Alf07OK(_cCHAVE,_cSchema,cAcao),oDlg:End(),.T.)) }
Local bBtnCancel	:= {|| oDlg:End() }
Local bEnchBarOn	:= {|| EnchoiceBar(oDlg,bBtnOk,bBtnCancel,,aButtons) }
Local aButtons		:= {}
Local lCte			:= .F.
Local lImpCte		:= .F.
Local _cImgAlt
Local _nValGet
Local lFile    := (!Empty(cFile1))
Default cAcao := "V" // Visualizar
// objetos da janela

// controles da MsMGetDb
Private aHeader		:= {}
Private aCols		:= {}
Private aStruct		:= {}
Private aHeaderAlt	:= {}
Private _lAlter		:= .F.

// controle de dimensionamento de tela
Private ODlg,oGetDados
Private aTela[0][0]
Private aGets[0]
Private oXml		:= NIL
Private _aEstrXML	:= {}		// dados do xml

Default cFile1 := ""

// copia o arquivo de um drive local para a pasta de processamento no servidor Protheus
FwMakeDir("\XML\")

If !Empty(cFile1)
	CpyT2S(cFile1, "\XML", .T. )
Endif

_cCHAVE  := ""
_cSCHEMA := ""

//Gera o Objeto XML
IF lFile
	//retira o path para deixar somente o nome do arquivo para localizacao a partir do server
	Do While "\" $ cFile1
		cFile1 := SubStr(cFile1,At("\",cFile1)+1,Len(cFile1))
	EndDo

	oXml := XmlParserFile( '\XML\'+cFile1, "_", @cError, @cWarning )    // "\XML\"+_cCHAVE+".XML"
	
	_cSCHEMA := MemoRead("\XML\"+cFile1)

Else 
	If !Empty(ZDH->ZDH_SCHEMA)
		_cCHAVE  := ZDH->ZDH_CHAVE
		_cSCHEMA := ZDH->ZDH_SCHEMA
		oXml     := XmlParser( _cSCHEMA , "_", @cError, @cWarning )
	Else
		MsgInfo("Erro na obtencao do XML, nao sera possivel visualiza-lo")
		Return()
	EndIf
	ProcRegua(4)
ENDIF

If Type("oXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") == "C"
	lCTe := .T.
	If Alltrim(oXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT) == Alltrim(SM0->M0_CGC)
		lImpCTe := .T.
	EndIf
EndIf
If Type("oXML:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT") == "C"
	lCTe := .T.
	If !lImpCTe
		If Alltrim(oXML:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT) == Alltrim(SM0->M0_CGC)
			lImpCTe := .T.
		EndIf
	EndIf
EndIf

If lCTe
	If lImpCTe
		U_AlfVCTe("I",oXML,_cSCHEMA)
	Else
		Alert("O destinatário e/ou remetente deste CTe não é da empresa/filial logada")
	EndIf
	Return(Nil)
EndIf

If Type("oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") == "C"
	If Alltrim(oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) <> Alltrim(SM0->M0_CGC)
		MsgInfo("Este XML não pode ser importado, pois é de outro destinatário."+Chr(10)+Chr(13)+"CNPJ do destinatário:   "+Alltrim(oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)+Chr(10)+Chr(13)+"CNPJ da filial logada: "+Alltrim(SM0->M0_CGC))
		Return()
    EndIf
EndIf

if Empty(cFile1)
   IncProc("Montando estrutura de matrizes a partir do XML")
endif
// monta estrutura de Matrizes a partir do XML
MontaStru( _cSCHEMA )

if Empty(cFile1)
   IncProc("Montando matriz com dados do produto")
endif
// monta matriz com dados do produto
MontaProd()

_lAlter		:= Iif(EmPty(RetTag("DANFE_CHAVENFE")),.T.,.F.)
_cImgAlt	:= Iif(_lAlter,"BR_VERDE","BR_VERMELHO")

if Empty(cFile1)
   IncProc("Montando tela de pré-visualização")
endif
// montagem da tela principal de pre-visualizacao.
//-- Dimensoes padroes

//-- Dimensoes padroes
//aSize   := MsAdvSize(lEnchBar,lPadrao,nMinY)	// usar no padrao
aSize := {0,12,636,422,1272,968,120}

AAdd( aObjects, { aSize[3]-6              , 030 , .F. , .F. } )	// painel DANFE
AAdd( aObjects, { aSize[3]-6              , 080 , .F. , .F. } )	// painel Transportadora
AAdd( aObjects, { aSize[3]-6              , 060 , .F. , .F. } )	// painel Imposto
AAdd( aObjects, { aSize[3]-6              , 150 , .F. , .F. } )	// painel MGet
AAdd( aObjects, { Int((aSize[3]*0.50-6)) , 060 , .F. , .F. } )	// painel Info Complementares, ocupa 1/2 do rodape da pagina
AAdd( aObjects, { Int((aSize[3]*0.25)-6) , 060 , .F. , .F. } )	// painel Impostos de DI, ocupa 1/4 do rodape da pagina
AAdd( aObjects, { Int((aSize[3]*0.25)-6) , 060 , .F. , .F. } )	// painel PIS e COFINS, ocupa 1/4 do rodape da pagina

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //000,000 TO 700,950 PIXEL
	// painel da DANFE
	oPnlDanfe  := TPanel():New(aPosObj[1,1],aPosObj[1,2],"Dados da DANFE",oDlg,,,,,CLR_WHITE,aObjects[1,1],aObjects[1,2],.T.,.T.)

	oSayDF1 := TSay():New(aPosObj[1,2]+0,002, {|| "Nome / Razão Social" },oPnlDanfe,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayDF2 := TSay():New(aPosObj[1,2]+0,175, {|| "Data de Emissão" },oPnlDanfe,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayDF3 := TSay():New(aPosObj[1,2]+0,250, {|| "DANFE / SERIE" },oPnlDanfe,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayDF4 := TSay():New(aPosObj[1,2]+0,355, {|| "Chave de acesso da NF-e" },oPnlDanfe,,oFontCabec,,,,.t.,CLR_RED,,200,21)

 	cGetDF1 := RetTag("DANFE_EMIT")
	oGetDF1 := TGet():New(aPosObj[1,2]+10,002,{|u| if(PCount()>0,cGetDF1:=u,cGetDF1)},oPnlDanfe,170,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,'cGetDF1')
	cGetDF2 := STOD(StrTran(RetTag("DANFE_DTEMIS"),"-",""))
	oGetDF2 := TGet():New(aPosObj[1,2]+10,175,{|u| if(PCount()>0,cGetDF2:=u,cGetDF2)},oPnlDanfe,070,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,'cGetDF2')
	cGetDF3 := AllTrim(RetTag("DANFE_NUM"))
	cGetDF3 := Replicate("0",TamSX3("F1_DOC")[1]-Len(cGetDF3))+cGetDF3+" / "+RetTag("DANFE_SERIE")
	oGetDF3 := TGet():New(aPosObj[1,2]+10,250,{|u| if(PCount()>0,cGetDF3:=u,cGetDF3)},oPnlDanfe,100,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,'cGetDF3')
	cGetDF4 := RetTag("DANFE_CHAVENFE")
	oGetDF4 := TGet():New(aPosObj[1,2]+10,355,{|u| if(PCount()>0,cGetDF4:=u,cGetDF4)},oPnlDanfe,170,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,'cGetDF4')

	oPnlDanfe := TPanel():New(aPosObj[1,1],540,"Situação do Arquivo",oPnlDanfe,,,,,CLR_WHITE,aObjects[1,1]-10,aObjects[1,2],.T.,.T.)
	TBitMap():New(14,20,10,10,_cImgAlt, , ,oPnlDanfe,,,,,,,,,.T.,,)
	oSayDF6 := TSay():New(14,35, {|| Iif(_lAlter,"Alterável","Bloqueado") },oPnlDanfe,,oFontCabec,,,,.t.,Iif(_lAlter,CLR_GREEN,CLR_RED),,200,21)

	// Painel da transportadora
	oPnlTrans  := TPanel():New(aPosObj[2,1],aPosObj[2,2],"Dados da Transportadora e Transporte",oDlg,,,,,CLR_WHITE,aObjects[2,1],aObjects[2,2],.T.,.T.)
	// segunda linha de dados de transportadora
	oSayTrA1 := TSay():New(aPosObj[2,2]+00,002, {|| "Razão Social" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayTrA2 := TSay():New(aPosObj[2,2]+00,200, {|| "Frete Por Conta"},oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayTrA3 := TSay():New(aPosObj[2,2]+00,290, {|| "Código ANTT" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayTrA4 := TSay():New(aPosObj[2,2]+00,360, {|| "Placa Veículo" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayTrA5 := TSay():New(aPosObj[2,2]+00,450, {|| "UF" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayTrA6 := TSay():New(aPosObj[2,2]+00,480, {|| "CNPJ/CPF" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)

	// segunda linha de dados de transportadora
	cGetTrA1 := RetTag("TRANS_NOME")
	oGetTrA1 := TGet():New(aPosObj[2,2]+10,002,{|u| if(PCount()>0,cGetTrA1:=u,cGetTrA1)},oPnlTrans,190,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrA1")
	cGetTrA2 := Iif(RetTag("TRANS_TPFRETE") == "1","F-FOB","C-CIF")
	oGetTrA2 := TGet():New(aPosObj[2,2]+10,200,{|u| if(PCount()>0,cGetTrA2:=u,cGetTrA2)},oPnlTrans,80,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrA2")
	cGetTrA3 := RetTag("TRANS_ANTT")
	oGetTrA3 := TGet():New(aPosObj[2,2]+10,290,{|u| if(PCount()>0,cGetTrA3:=u,cGetTrA3)},oPnlTrans,60,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrA3")
	cGetTrA4 := RetTag("TRANS_PLACA")
	oGetTrA4 := TGet():New(aPosObj[2,2]+10,360,{|u| if(PCount()>0,cGetTrA4:=u,cGetTrA4)},oPnlTrans,80,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrA4")
	cGetTrA5 := RetTag("TRANS_UFCARRO")
	oGetTrA5 := TGet():New(aPosObj[2,2]+10,450,{|u| if(PCount()>0,cGetTrA5:=u,cGetTrA5)},oPnlTrans,20,10,'@!',{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrA5")
	cGetTrA6 := RetTag("TRANS_CNPJ")
	oGetTrA6 := TGet():New(aPosObj[2,2]+10,480,{|u| if(PCount()>0,cGetTrA6:=u,cGetTrA6)},oPnlTrans,80,10,PesqPict("SA1","A1_CGC"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrA6")

	// segunda linha de dados de transportadora
	oSayTrB1 := TSay():New(aPosObj[2,2]+25,002, {|| "Endereço" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayTrB2 := TSay():New(aPosObj[2,2]+25,300, {|| "Municipio"},oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayTrB3 := TSay():New(aPosObj[2,2]+25,420, {|| "UF" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayTrB4 := TSay():New(aPosObj[2,2]+25,450, {|| "Inscrição Estadual" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	cGetTrB1 := RetTag("TRANS_END")
	oGetTrB1 := TGet():New(aPosObj[2,2]+35,002,{|u| if(PCount()>0,cGetTrB1:=u,cGetTrB1)},oPnlTrans,285,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrB1")
	cGetTrB2 := RetTag("TRANS_MUN")
	oGetTrB2 := TGet():New(aPosObj[2,2]+35,300,{|u| if(PCount()>0,cGetTrB2:=u,cGetTrB2)},oPnlTrans,100,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrB2")
	cGetTrB3 := RetTag("TRANS_UF")
	oGetTrB3 := TGet():New(aPosObj[2,2]+35,420,{|u| if(PCount()>0,cGetTrB3:=u,cGetTrB3)},oPnlTrans,20,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrB3")
	cGetTrB4 := RetTag("TRANS_IE")
	oGetTrB4 := TGet():New(aPosObj[2,2]+35,450,{|u| if(PCount()>0,cGetTrB4:=u,cGetTrB4)},oPnlTrans,80,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrB4")

	// terceira linha de dados de transportadora
	oSayTrC1 := TSay():New(aPosObj[2,2]+50,002, {|| "Quantidade" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,100,21)
	oSayTrC2 := TSay():New(aPosObj[2,2]+50,070, {|| "Especie"},oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,100,21)
	oSayTrC3 := TSay():New(aPosObj[2,2]+50,140, {|| "Marca" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,100,21)
	oSayTrC4 := TSay():New(aPosObj[2,2]+50,240, {|| "Numeração" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,100,21)
	oSayTrC5 := TSay():New(aPosObj[2,2]+50,340, {|| "Peso Bruto" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,100,21)
	oSayTrC6 := TSay():New(aPosObj[2,2]+50,440, {|| "Peso Liquido" },oPnlTrans,,oFontCabec,,,,.t.,CLR_RED,,100,21)
	cGetTrC1 := RetTag("VOLUME_QTDVOL")
	oGetTrC1 := TGet():New(aPosObj[2,2]+60,002,{|u| if(PCount()>0,cGetTrC1:=u,cGetTrC1)},oPnlTrans,050,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrC1")
	cGetTrC2 := RetTag("VOLUME_ESP")
	oGetTrC2 := TGet():New(aPosObj[2,2]+60,070,{|u| if(PCount()>0,cGetTrC2:=u,cGetTrC2)},oPnlTrans,050,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrC2")
	cGetTrC3 := RetTag("VOLUME_MARCA")
	oGetTrC3 := TGet():New(aPosObj[2,2]+60,140,{|u| if(PCount()>0,cGetTrC3:=u,cGetTrC3)},oPnlTrans,070,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrC3")
	cGetTrC4 := RetTag("VOLUME_NUM")
	oGetTrC4 := TGet():New(aPosObj[2,2]+60,240,{|u| if(PCount()>0,cGetTrC4:=u,cGetTrC4)},oPnlTrans,080,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrC4")
	cGetTrC5 := Val( RetTag("VOLUME_PESOB") )
	oGetTrC5 := TGet():New(aPosObj[2,2]+60,340,{|u| if(PCount()>0,cGetTrC5:=u,cGetTrC5)},oPnlTrans,090,10,PesqPict("SF1","F1_PESOL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrC5")
	cGetTrC6 := Val( RetTag("VOLUME_PESOL") )
	oGetTrC6 := TGet():New(aPosObj[2,2]+60,440,{|u| if(PCount()>0,cGetTrC6:=u,cGetTrC6)},oPnlTrans,100,10,PesqPict("SF1","F1_PESOL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetTrC6")

	// painel dos impostos
	oPnlImp  := TPanel():New(aPosObj[3,1],aPosObj[3,2],"Impostos e Tributos",oDlg,,,,,CLR_WHITE,aObjects[3,1],aObjects[3,2],.T.,.T.)
	// primeira linha de dados de impostos
	oSayImpA1 := TSay():New(aPosObj[3,2]+00,002, {|| "Base de Cálculo ICMS" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayImpA2 := TSay():New(aPosObj[3,2]+00,120, {|| "Valor ICMS"},oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayImpA3 := TSay():New(aPosObj[3,2]+00,200, {|| "Base Cálculo ICMS Substituição" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayImpA4 := TSay():New(aPosObj[3,2]+00,370, {|| "Valor ICMS Substituição" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayImpA5 := TSay():New(aPosObj[3,2]+00,500, {|| "Valor Total Produtos" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)

	// primeira linha de dados de impostos
	cGetImpA1 := Val( RetTag("IMP_BCICMS") )
	oGetImpA1 := TGet():New(aPosObj[3,2]+10,002,{|u| if(PCount()>0,cGetImpA1:=u,cGetImpA1)},oPnlImp,100,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpA1")
	cGetImpA2 := Val( RetTag("IMP_VALICMS") )
	oGetImpA2 := TGet():New(aPosObj[3,2]+10,120,{|u| if(PCount()>0,cGetImpA2:=u,cGetImpA2)},oPnlImp,070,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpA2")
	cGetImpA3 := Val( RetTag("IMP_BCST") )
	oGetImpA3 := TGet():New(aPosObj[3,2]+10,200,{|u| if(PCount()>0,cGetImpA3:=u,cGetImpA3)},oPnlImp,160,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpA3")
	cGetImpA4 := Val( RetTag("IMP_VALSUBTRIB") )
	oGetImpA4 := TGet():New(aPosObj[3,2]+10,370,{|u| if(PCount()>0,cGetImpA4:=u,cGetImpA4)},oPnlImp,110,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpA4")
	cGetImpA5 := Val( RetTag("IMP_VALTOTPROD") )
	oGetImpA5 := TGet():New(aPosObj[3,2]+10,500,{|u| if(PCount()>0,cGetImpA5:=u,cGetImpA5)},oPnlImp,100,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpA5")

	// segunda linha de dados de impostos
	oSayImpB1 := TSay():New(aPosObj[3,2]+25,002, {|| "Valor do Frete" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayImpB2 := TSay():New(aPosObj[3,2]+25,102, {|| "Valor do Seguro"},oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayImpB3 := TSay():New(aPosObj[3,2]+25,202, {|| "Desconto" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,200,21)
	oSayImpB4 := TSay():New(aPosObj[3,2]+25,302, {|| "Outras Despesas" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayImpB5 := TSay():New(aPosObj[3,2]+25,402, {|| "Valor IPI" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayImpB6 := TSay():New(aPosObj[3,2]+25,502, {|| "Valor Total Nota" },oPnlImp,,oFontCabec,,,,.t.,CLR_RED,,150,21)

	// segunda linha de dados de impostos
	cGetImpB1 := Val( RetTag("IMP_VALFRETE") )
	oGetImpB1 := TGet():New(aPosObj[3,2]+35,002,{|u| if(PCount()>0,cGetImpB1:=u,cGetImpB1)},oPnlImp,080,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpB1")
	cGetImpB2 := Val( RetTag("IMP_VALSEG") )
	oGetImpB2 := TGet():New(aPosObj[3,2]+35,102,{|u| if(PCount()>0,cGetImpB2:=u,cGetImpB2)},oPnlImp,080,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpB2")
	cGetImpB3 := Val( RetTag("IMP_VALDESC") )
	oGetImpB3 := TGet():New(aPosObj[3,2]+35,202,{|u| if(PCount()>0,cGetImpB3:=u,cGetImpB3)},oPnlImp,080,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpB3")
	cGetImpB4 := Val( RetTag("IMP_VALOUTROS") )
	oGetImpB4 := TGet():New(aPosObj[3,2]+35,302,{|u| if(PCount()>0,cGetImpB4:=u,cGetImpB4)},oPnlImp,080,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpB4")
	cGetImpB5 := Val( RetTag("IMP_VALIPI") )
	oGetImpB5 := TGet():New(aPosObj[3,2]+35,402,{|u| if(PCount()>0,cGetImpB5:=u,cGetImpB5)},oPnlImp,080,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpB5")
	cGetImpB6 := Val( RetTag("IMP_VALTOTNF") )
	oGetImpB6 := TGet():New(aPosObj[3,2]+35,502,{|u| if(PCount()>0,cGetImpB6:=u,cGetImpB6)},oPnlImp,080,10,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetImpB6")

	// painel da MsNewGetDados
	oPnlMGet  := TPanel():New(aPosObj[4,1],aPosObj[4,2],"",oDlg,,,,,CLR_WHITE,aObjects[4,1],aObjects[4,2],.T.,.T.)
	oGetDados := MsNewGetDados():New(00,00,00,00,GD_INSERT+GD_ALTERA+GD_DELETE,,,,Iif(_lAlter,aHeaderAlt,{}),,999,,,,oPnlMGet,aHeader,aCols)
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 	// faz com que o objeto ocupe todo o panel.
	oGetDados:Refresh()

	// painel Informacoes complementares
	oPnlInfA1 := TPanel():New(aPosObj[5,1],aPosObj[5,2],"Informações Complementares",oDlg,,,,,CLR_WHITE,aObjects[5,1],aObjects[5,2],.T.,.T.)
	cGetInfA1 := RetTag("INF_ADICIONAL")
	oGetInfA1 := TGet():New(aPosObj[5,2]+05,002,{|u| if(PCount()>0,cGetInfA1:=u,cGetInfA1)},oPnlInfA1,aObjects[5,1]-10,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetInfA1")
	cGetInfA2 := RetTag("INF_PROTOCOLO")
	oGetInfA2 := TGet():New(aPosObj[5,2]+20,002,{|u| if(PCount()>0,cGetInfA2:=u,cGetInfA2)},oPnlInfA1,aObjects[5,1]-10,10,"@!",{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetInfA2")

	// painel total dos impostos de DI, mesma linha das Info Complementares
	oPnlDI  := TPanel():New(aPosObj[5,1],aPosObj[5,2]+aObjects[5,1]+5,"Total dos Impostos de DI",oDlg,,,,,CLR_WHITE,aObjects[6,1],aObjects[6,2],.T.,.T.)
	oSayDIA1 := TSay():New(aPosObj[7,2]+05,002, {|| "Base Cálculo:" },oPnlDI,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayDIA2 := TSay():New(aPosObj[7,2]+15,002, {|| "Valor Despacho:" },oPnlDI,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayDIA3 := TSay():New(aPosObj[7,2]+25,002, {|| "Valor do II:" },oPnlDI,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayDIA4 := TSay():New(aPosObj[7,2]+35,002, {|| "Valor do IOF:" },oPnlDI,,oFontCabec,,,,.t.,CLR_RED,,150,21)

	// painel total dos impostos de DI, mesma linha das Info Complementares
	cGetDIA1 := SomaTag(VAL_BSCII)
	oGetDIA1 := TGet():New(aPosObj[7,2]+04,085,{|u| if(PCount()>0,cGetDIA1:=u,cGetDIA1)},oPnlDI,aObjects[7,1]-090,08,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetDIA1")
	cGetDIA2 := SomaTag(VAL_DESPA)
	oGetDIA2 := TGet():New(aPosObj[7,2]+14,085,{|u| if(PCount()>0,cGetDIA2:=u,cGetDIA2)},oPnlDI,aObjects[7,1]-090,08,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetDIA2")
	cGetDIA3 := SomaTag(VAL_II)
	oGetDIA3 := TGet():New(aPosObj[7,2]+24,085,{|u| if(PCount()>0,cGetDIA3:=u,cGetDIA3)},oPnlDI,aObjects[7,1]-090,08,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetDIA3")
	cGetDIA4 := SomaTag(VAL_IOF)
	oGetDIA4 := TGet():New(aPosObj[7,2]+34,085,{|u| if(PCount()>0,cGetDIA4:=u,cGetDIA4)},oPnlDI,aObjects[7,1]-090,08,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetDIA4")

	// painel total dos PIS e COFINS, mesma linha das Info Complementares
	oPnlPIS  := TPanel():New(aPosObj[5,1],aPosObj[5,2]+aObjects[5,1]+aObjects[6,1]+10,"Total de PIS, COFINS e Despesas de Transporte",oDlg,,,,,CLR_WHITE,aObjects[7,1],aObjects[7,2],.T.,.T.)
	oSayPISA1 := TSay():New(aPosObj[7,2]+05,002, {|| "Pis:" },oPnlPIS,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayPISA2 := TSay():New(aPosObj[7,2]+15,002, {|| "COFINS:"},oPnlPIS,,oFontCabec,,,,.t.,CLR_RED,,150,21)
	oSayPISA2 := TSay():New(aPosObj[7,2]+25,002, {|| "Frete/Descontos/Seguro:"},oPnlPIS,,oFontCabec,,,,.t.,CLR_RED,,150,21)

	// painel total dos PIS e COFINS, mesma linha das Info Complementares
	cGetPISA1 := Val( RetTag("IMP_VALPIS") )
	oGetPISA1 := TGet():New(aPosObj[7,2]+04,100,{|u| if(PCount()>0,cGetPISA1:=u,cGetPISA1)},oPnlPIS,aObjects[7,1]-100,08,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetPISA1")
	cGetPISA2 := Val( RetTag("IMP_VALCOFINS") )
	oGetPISA2 := TGet():New(aPosObj[7,2]+14,100,{|u| if(PCount()>0,cGetPISA2:=u,cGetPISA2)},oPnlPIS,aObjects[7,1]-100,08,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetPISA2")
	cGetPISA3 := cGetImpB1 + cGetImpB2 + cGetImpB3
	oGetPISA3 := TGet():New(aPosObj[7,2]+24,100,{|u| if(PCount()>0,cGetPISA3:=u,cGetPISA3)},oPnlPIS,aObjects[7,1]-100,08,PesqPict("SD1","D1_TOTAL"),{|o| .t. },,,oFontItem,,,.T.,,,,,,,!(_lAlter),,,"cGetPISA3")

//Linha abaixo exatamente igual ao comando ACTIVATE comum so que permite habilitar a oDlg e a enchoicebar ja na mesma chamada
oDlg:Activate(,,,.T.,,,bEnchBarOn)

Return(.T.)

Static Function RetTag(_cCont)
Local _xRet := Iif(Ascan(_aEstrXML,{|x|x[1]==_cCont})>0,_aEstrXML[Ascan(_aEstrXML,{|x|x[1]==_cCont})][2],"")
Return(_xRet)

Static Function SomaTag(_nPosTag)
Local _nCnt
Local _nValTag := 0

For _nCnt := 1 to Len(aCols)
	_nValTag := _nValTag + aCols[_nCnt][_nPosTag]
Next

Return(_nValTag)

Static Function ValidTAG(_cNode,_cTag,_cTipoTag)
Local _oChild
Private _xRet := ""

If Type(_cNode) == "O"
	_oChild := XmlChildEx(&(_cNode),_cTag)
	If _oChild <> Nil
		_xRet := _oChild:TEXT
	EndIf
EndIf

// usado somente na montagem do aCols
If !Empty(_cTipoTag)
	If _cTipoTag == "C"
		_xRet := _xRet
	ElseIf _cTipoTag == "N"
		_xRet := Val(_xRet)
	ElseIf _cTipoTag == "D"
		_xRet := STOD(StrTran(_xRet,"-",""))
	Else	// executa a regra especifica do campo
		_xRet := &(_cTipoTag)
	EndIf
EndIf

Return(_xRet)

Static Function MontaStru( _SCHEMA )
Local _cCNPJXML,_cCNPJSM0,_nCnt
Local _aAreaSM0 	:= SM0->( GetArea() )

Public _lDynatech	:= .F.	// esta variavel sera utilizada para o tratamento de inclusao de transportadora ou nao. Robinson em (31/05/2012)

// Valida o Emitente.
// Se emitente == Dynatech utiliza o destinatario como emitente da nota
// se emitente >< Dynatech utiliza o emitente como emitente da nota
_cCNPJXML := AllTrim(ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT","_CNPJ"))
SM0->( dbGoTop() )
While SM0->( !EOF() )
	_cCNPJSM0 := AllTrim(SM0->M0_CGC)
	_cCNPJSM0 := StrTran(_cCNPJSM0,".","")
	_cCNPJSM0 := StrTran(_cCNPJSM0,"-","")
	_cCNPJSM0 := StrTran(_cCNPJSM0,"/","")
	If _cCNPJSM0 == _cCNPJXML
		_lDynatech	:= .T.
		Exit
	EndIf
	SM0->( dbSkip() )
EndDo
RestArea(_aAreaSM0)

If _lDynatech
	AADD(_aEstrXML,{"DANFE_EMIT",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_DEST","_XNOME")})
Else
	AADD(_aEstrXML,{"DANFE_EMIT",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT","_XNOME")})
EndIf

// DADOS DA DANFE
AADD(_aEstrXML,{"DANFE_DTEMIS",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_IDE","_DHEMI")})
AADD(_aEstrXML,{"DANFE_NUM",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_IDE","_NNF")})
AADD(_aEstrXML,{"DANFE_SERIE",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_IDE","_SERIE")})
AADD(_aEstrXML,{"DANFE_CHAVENFE",ValidTag("oXml:_NFEPROC:_PROTNFE:_INFPROT","_CHNFE")})

 
//_SCHEMA := oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT

// DADOS DA TRANSPORTADORA
AADD(_aEstrXML,{"TRANS_NOME",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA","_XNOME")})
AADD(_aEstrXML,{"TRANS_TPFRETE",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP","_MODFRETE")})
AADD(_aEstrXML,{"TRANS_CNPJ",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA","_CNPJ")})
AADD(_aEstrXML,{"TRANS_IE",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA","_IE")})
AADD(_aEstrXML,{"TRANS_UF",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA","_UF")})
AADD(_aEstrXML,{"TRANS_END",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA","_XENDER")})
AADD(_aEstrXML,{"TRANS_MUN",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_TRANSPORTA","_XMUN")})

// DADOS DO VOLUME DE CARGA
AADD(_aEstrXML,{"VOLUME_ESP",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL","_ESP")})
AADD(_aEstrXML,{"VOLUME_MARCA",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL","_MARCA")})
AADD(_aEstrXML,{"VOLUME_NUM",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL","_NVOL")})
AADD(_aEstrXML,{"VOLUME_PESOB",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL","_PESOB")})
AADD(_aEstrXML,{"VOLUME_PESOL",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL","_PESOL")})
AADD(_aEstrXML,{"VOLUME_QTDVOL",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL","_QVOL")})

// DADOS IMPOSTOS
AADD(_aEstrXML,{"IMP_BCICMS",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VBC")})
AADD(_aEstrXML,{"IMP_VALICMS",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VICMS")})
AADD(_aEstrXML,{"IMP_BCST",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VBCST")})
AADD(_aEstrXML,{"IMP_VALCOFINS",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VCOFINS")})
AADD(_aEstrXML,{"IMP_VALDESC",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VDESC")})
AADD(_aEstrXML,{"IMP_VALFRETE",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VFRETE")})
AADD(_aEstrXML,{"IMP_VALICMS",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VICMS")})
AADD(_aEstrXML,{"IMP_VALII",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VII")})
AADD(_aEstrXML,{"IMP_VALIPI",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VIPI")})
AADD(_aEstrXML,{"IMP_VALTOTNF",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VNF")})
AADD(_aEstrXML,{"IMP_VALOUTROS",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VOUTRO")})
AADD(_aEstrXML,{"IMP_VALPIS",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VPIS")})
AADD(_aEstrXML,{"IMP_VALTOTPROD",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VPROD")})
AADD(_aEstrXML,{"IMP_VALSEG",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VSEG")})
AADD(_aEstrXML,{"IMP_VALSUBTRIB",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT","_VST")})

// DADOS DE INFORMACOES ADICIONAIS
AADD(_aEstrXML,{"INF_ADICIONAL",ValidTag("oXml:_NFEPROC:_NFE:_INFNFE:_INFADIC","_INFCPL")})
AADD(_aEstrXML,{"INF_PROTOCOLO",ValidTag("oXml:_NFEPROC:_PROTNFE:_INFPROT","_NPROT")})

Return Nil



Static Function MontaProd()
Local _nCnt,_nCntLin,_nCntCol,_nQtdDet
Local _aCamposXML	:= {}
Local _aHdrAlt		:= {}
Local nNx			:= 0

PRIVATE _aProd		:= {}
PRIVATE _cLocalTag
Private aSitTrib 	:= &(SuperGetMV("AF_XMLSTNO",,'{"00","10","20","30","40","41","50","51","60","70","90","PART"}'))


//CAMPOS QUE SERAO USADOS PARA A MONTAGEM DA MSMGETDB, SUA ORIGEM NO XML E QUAL O TIPO DE DADO QUE SERA RETORNADO
AADD(_aCamposXML,{"D1_ITEM","D1ITEM","Item","","_NITEM",'StrZero(Val(_xRet),4)'} )							// ITEM DO PRODUTO
AADD(_aCamposXML,{"D1_COD","D1COD","Produto",":_PROD","_CPROD","C"} ) 										// CODIGO DO PRODUTO
AADD(_aCamposXML,{"B1_DESC","B1DESC","Descricao",":_PROD","_XPROD","C"} ) 									// DESCRICAO PRODUTO
AADD(_aCamposXML,{"D1_PEDIDO","D1PEDIDO","Pedido",":_PROD","_XPED","C"} ) 									// PEDIDO
AADD(_aCamposXML,{"D1_ITEMPC","D1ITEMPED","Item.Ped.",":_PROD","_NITEMPED","C"} ) 							// ITEM DO PEDIDO
AADD(_aCamposXML,{"B1_POSIPI","B1POSIPI","NCM/SH",":_PROD","_NCM","C"} ) 									// NCM PRODUTO
AADD(_aCamposXML,{"D1_CF","D1CF","CFOP",":_PROD","_CFOP","C"} )											// CFOP OPERACAO
AADD(_aCamposXML,{"D1_UM","D1UM","UN",":_PROD","_UCOM","C"} ) 												// UNIDADE DE MEDIDA PRODUTO
AADD(_aCamposXML,{"D1_QUANT","D1QUANT","Quant",":_PROD","_QCOM","N"} ) 									// QTD COMPRADA
AADD(_aCamposXML,{"D1_VUNIT","D1VUNIT","Vlr Unit",":_PROD","_VUNCOM","N"} ) 								// VALOR UNITARIO
AADD(_aCamposXML,{"D1_TOTAL","D1TOTAL","Vlr Total",":_PROD","_VPROD","N"} ) 								// VALOR TOTAL DO PRODUTO
For nNx := 1 to Len(aSitTrib) // {"00","10","20","30","40","41","50","51","60","70","90","PART"}
	AADD(_aCamposXML,{"D1_BASEICM","D1BIC"+aSitTrib[nNx],"BC. ICMS "+aSitTrib[nNx],":_IMPOSTO:_ICMS:_ICMS"+aSitTrib[nNx],"_VBC","N"} ) 				// BASE CALC ICMS
	AADD(_aCamposXML,{"D1_VALICM", "D1VIC"+aSitTrib[nNx],"Vlr ICMS "+aSitTrib[nNx],":_IMPOSTO:_ICMS:_ICMS"+aSitTrib[nNx],"_VICMS","N"} )				// VALOR ICMS
	AADD(_aCamposXML,{"D1_ALQIMP1","D1AIC"+aSitTrib[nNx],"Aliq ICMS "+aSitTrib[nNx],":_IMPOSTO:_ICMS:_ICMS"+aSitTrib[nNx],"_PICMS","N"} ) 			// ALIQ ICMS
Next nNx
AADD(_aCamposXML,{"D1_BASECF3","D1BASECF3","BC COFINS",":_IMPOSTO:_COFINS:_COFINSOUTR","_VBC","N"} ) 		// BASE CALC COFINS
AADD(_aCamposXML,{"D1_VALCF3","D1VALCF3","Vlr COFINS",":_IMPOSTO:_COFINS:_COFINSOUTR","_VCOFINS","N"} ) 	// VALOR COFINS
AADD(_aCamposXML,{"D1_ALIQCF3","D1ALIQCF3","Aliq COFINS",":_IMPOSTO:_COFINS:_COFINSOUTR","_PCOFINS","N"} ) // ALIQ COFINS
AADD(_aCamposXML,{"D1_BASEPS3","D1BASEPS3","BC PIS",":_IMPOSTO:_PIS:_PISOUTR","_VBC","N"} ) 				// BASE CALC PIS
AADD(_aCamposXML,{"D1_VALPS3","D1VALPS3","Vlr PIS",":_IMPOSTO:_PIS:_PISOUTR","_VPIS","N"} ) 				// VALOR PIS
AADD(_aCamposXML,{"D1_ALIQPS3","D1ALIQPS3","Aliq PIS",":_IMPOSTO:_PIS:_PISOUTR","_PPIS","N"} ) 			// ALIQ PIS
AADD(_aCamposXML,{"D1_BASEICM","D1BASEII","BC II",":_IMPOSTO:_II","_VBC","N"} ) 							// BASE DE CALC I.I. (IMPOSTO IMPORTACAO)
AADD(_aCamposXML,{"D1_II","D1II","Vlr II",":_IMPOSTO:_II","_VII","N"} ) 									// VALOR DO I.I. (IMPOSTO IMPORTACAO)
AADD(_aCamposXML,{"D1_VALDEV","D1VALDEPC","Vlr Despachante",":_IMPOSTO:_II","_VDESPADU","N"} ) 			// VALOR DESPANCHANTE
AADD(_aCamposXML,{"D1_VALDEV","D1VALIOF","Vlr IOF",":_IMPOSTO:_II","_VIOF","N"} ) 							// VALOR DE IOF
AADD(_aCamposXML,{"CD5_NDI","CD5NDI","Numero DI",":_PROD:_DI","_NDI","C"} ) 								// Numero da DI
AADD(_aCamposXML,{"CD5_DTDI","CD5DTDI","Data DI",":_PROD:_DI","_DDI","D"} ) 								// data da DI
AADD(_aCamposXML,{"CD5_LOCDES","CD5LOCDES","Loc Desembaraço",":_PROD:_DI","_XLOCDESEMB","C"} ) 			// Local de Desembaraco
AADD(_aCamposXML,{"CD5_UFDES","CD5UFDES","UF Desembaraço",":_PROD:_DI","_UFDESEMB","C"} ) 					// UF do Desembaraco
AADD(_aCamposXML,{"CD5_DTDES","CD5DTDES","Data Desembaraço",":_PROD:_DI","_DDESEMB","D"} ) 				// Data do Desembaraco
AADD(_aCamposXML,{"CD5_CODEXP","CD5CODEXP","Exportador",":_PROD:_DI","_CEXPORTADOR","C"} ) 				// Exportador
AADD(_aCamposXML,{"CD5_NADIC","CD5NADIC","Adição",":_PROD:_DI:_ADI","_NADICAO","C"} ) 					// Adicao de complemento
AADD(_aCamposXML,{"CD5_SQADIC","CD5SQADIC","Sequecia Adição",":_PROD:_DI:_ADI","_NSEQADIC","C"} ) 			// Sequencia da adicao de complemento
AADD(_aCamposXML,{"CD5_CODFAB","CD5CODFAB","Fabricante",":_PROD:_DI:_ADI","_CFABRICANTE","C"} ) 			// Fabricante

_cCampos := ""
// montagem do aHeader
SX3->( dbSetOrder(2) )	// indexar por nome de campo
For _nCnt := 1 To Len(_aCamposXML)
	If SX3->( dbSeek(_aCamposXML[_nCnt][1]) )
		AADD(aHeader,{_aCamposXML[_nCnt][3],_aCamposXML[_nCnt][2],SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()","",SX3->X3_TIPO,"","" })
		If !_lAlter
			AADD(_aHdrAlt,_aCamposXML[_nCnt][2])
			_cCampos += '"'+_aCamposXML[_nCnt][2]+'",'
		EndIf
	else
		conout("Nao achou campo "+aLLtRIM(_aCamposXML[_nCnt][1]) )
	EndIf
Next

//AADD(aHeaderAlt,SubStr(_cCampos,1,Len(_cCampos)-1))
aHeaderAlt:= aClone(_aHdrAlt)

// validacao para a qtd de ITENS DE DETALHE do XML.
If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"	// qdo possui mais de um item o NODE vira um Array
	_nQtdDet	:= Len(oXml:_NFEPROC:_NFE:_INFNFE:_DET)
	_aProd		:= oXml:_NFEPROC:_NFE:_INFNFE:_DET
	_lDetObj	:= .F.
ElseIf Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "O"	// quando o XML so possui um item, ele eh um Objeto
	_nQtdDet	:= 1	//XMLChildCount(oXml:_NFEPROC:_NFE:_INFNFE:_DET)
	_lDetObj	:= .T.
EndIf

// populando o aCols com os dados coletados a partir do XML
For _nCntLin := 1 to _nQtdDet					// conta o "N" do aCols baseado na qtd de itens (DET) do XML
	If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "O"	// quando o XML so possui um item, ele eh um Objeto
		_cLocalTag := "oXml:_NFEPROC:_NFE:_INFNFE:_DET"
	EndIf
	AADD(aCols,Array(Len(_aCamposXML)+1))		// cria uma linha no array com a qtd de campos do aHeader
	For _nCntCol := 1 to Len(_aCamposXML)
		If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"	// qdo possui mais de um item o NODE vira um Array
			_cLocalTag := "_aProd["+AllTrim(Str(_nCntLin))+"]"+AllTrim(_aCamposXML[_nCntCol][4])+":"+AllTrim(_aCamposXML[_nCntCol][5])+":TEXT"
			// linha abaixo somente pra testes.
			//_cLocalTag := "_aProd["+AllTrim(Str(_nCntLin))+"]:_PROD:"+AllTrim(_aCamposXML[_nCntCol][5])+":TEXT"
		EndIf
		IF Type(_cLocalTag) <> "U"
			aCols[_nCntLin][_nCntCol] := Iif(_lDetObj,ValidTag(_cLocalTag+_aCamposXML[_nCntCol][4],_aCamposXML[_nCntCol][5],_aCamposXML[_nCntCol][6]),;
	   										ValidVal(_cLocalTag,_aCamposXML[_nCntCol][6]))
		else
		   if aHeader[_nCntCol][8] == "N"
			 aCols[_nCntLin][_nCntCol] := 0
		   else
		     aCols[_nCntLin][_nCntCol] := ""
		   endif
		Endif
	Next
	aCols[_nCntLin][Len(aCols[_nCntLin])] := .F.
Next

Return Nil

Static Function ValidVal(_cExp,_cTipoVal)
Local bBlock := ErrorBlock( { | o | MyErro( o ) } )

Private _xRet
Private _lErro := .F.
//
// Inicia Tratamento de erro
// A partir so begin tudo que der erro vai para o MyErro()
Begin Sequence
	_xRet := &(_cExp)
	If _lErro
		//Recover	// retorna ao estado antes do erro
     	Break		// desvia para o End Sequence
	EndIf
End Sequence

If _lErro
	If _cTipoVal == "C"
		_xRet := ""
	ElseIf _cTipoVal == "N"
		_xRet := 0
	Else	//_cTipoVal == "D"
		_xRet := CTOD(Space(8))
	EndIf
Else
	If _cTipoVal == "C"
		_xRet := _xRet
	ElseIf _cTipoVal == "N"
		_xRet := Val(_xRet)
	ElseIf _cTipoVal == "D"
		_xRet := STOD(StrTran(_xRet,"-",""))
	Else	// executa a regra especifica do campo
		_xRet := &(_cTipoVal)
	EndIf
EndIf

// Restaura  bloco de erro (se havia)
//ErrorBlock( bBlock )

Return _xRet

//--------------------------------------------
Static Function MyErro ( e )
// Você faz o tratamento de erro que você quiser aqui
// Mensagem de erro do error.log
If e:GenCode > 0
     Help( ' ', 1, 'ERR_FORM',, e:Description, 3, 1 )
     _lErro := .T.
EndIf

Return NIL


Static Function Alf07OK(cChvNFE, _cSchema , cAcao)
Local _lRet  := .T.
Local cPsqNFe := SuperGetMV("AF_PXMLNFE",,"N")

If cPsqNFe == "S"

	If cAcao == "S" // Selecionar o XML
		
		If Empty(cChvNFE)
			cChvNFE := ValidTag("oXml:_NFEPROC:_PROTNFE:_INFPROT","_CHNFE")
		EndIf
	
		If ( !Empty(cChvNFE) .And. !Empty(_cSchema) )
			If !XMLInMnt(cChvNFE)
				LjMsgRun("Gravando Informações..." ,,{|| U_AlfSfz06(_cSchema, oXML) , oDlg:End() })
			Else
			  _lRet := .F.
			  MsgInfo("XML já consta do Monitor, por favor verifique.","Atenção!")
			Endif
		Else
			lRet := .F.
			MsgInfo("Impossível prosseguir: erro no XML, ou na tabela do Monitor.","Atenção!")
		EndIf
	
	EndIf

EndIf

Return(_lRet)



Static Function XMLInMnt(cChvNFe)
Local cTQry := ""
Local lRet := .F.

cTQry := "SELECT ZDH.ZDH_NUMNF AS ZDHNUMNF "
cTQry += "FROM "
cTQry += RetSqlName("ZDH")+" ZDH "
cTQry += "WHERE ZDH.D_E_L_E_T_ <> '*' "
cTQry += "AND ZDH.ZDH_CHAVE = '"+Alltrim(cChvNFe)+"' "

Iif(Select("WKWZDH")>0,WKWZDH->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cTQry),"WKWZDH",.T.,.T.)
WKWZDH->(dbGoTop())

If WKWZDH->(!Eof())	
	If !Empty(WKWZDH->ZDHNUMNF)
		lRet := .T.
	EndIf
EndIf
WKWZDH->(dbCloseArea())

Return(lRet)



User Function AlfVCTe( cOpt, oCte, cXML )
Local aDCTe := {}
Local lRet := .T.
Local nLBx1 := 1
Local oFt1 := TFont():New("Arial",,022,,.T.,,,,,.F.,.T.)
Local oFt2 := TFont():New("Courier",,018,,.T.,,,,,.F.,.F.)
Local oLBx1 := Nil
Local oBConf := Nil
Local oBSair := Nil
Local oSD1 := Nil
Local oDgCt := Nil
Local cChvCTe := "" 
Local cError := ""
Local cWarning := ""
Local cCST := ""
Local nBICMS := 0
Local nVICMS := 0
Local nAICMS := 0

Default cOpt := "V"
Default oCTe := Nil
Default cXML := ""

Private oCTeVis := Nil
	

If oCTe <> Nil
	oCTeVis := oCTe
Else
	oCTeVis := XMLParser( ZDH->ZDH_SCHEMA, "_", @cError, @cWarning )
	If ValType(oCTeVis) <> "O"
		Alert("Erro na obtencao do XML deste CTe")
		Return(Nil)
	EndIf
EndIf

cChvCTe := oCTeVis:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT
cCST := Iif(Type("oCTeVis:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="C",oCTeVis:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT,"")
nBICMS := Iif(Type("oCTeVis:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT")=="C",Val(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT),0)
nVICMS := Iif(Type("oCTeVis:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT")=="C",Val(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT),0)
nAICMS := Iif(Type("oCTeVis:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT")=="C",Val(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT),0)

aAdd(aDCTe,"Chave CTe:")
aAdd(aDCTe,cChvCTe)
aAdd(aDCTe,"")
aAdd(aDCTe,"Dados do CTe--------------------------------------------------------------------------------")
aAdd(aDCTe,"Nr: "+Alltrim(StrZero(Val(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT),9))+"   Serie: "+StrZero(Val(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT),3)+"   Emissao: "+DtoC(StoD(SubStr(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,1,4)+SubStr(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,6,2)+SubStr(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,9,2))))
aAdd(aDCTe,"Nat. Oper: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT)+" - "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_IDE:_NATOP:TEXT))
aAdd(aDCTe,"")
aAdd(aDCTe,"Emitente / Transportador--------------------------------------------------------------------")
aAdd(aDCTe,"Nome: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT))
aAdd(aDCTe,"CNPJ: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT)+"   UF: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_UF:TEXT))
aAdd(aDCTe,"")
aAdd(aDCTe,"Remetente-----------------------------------------------------------------------------------")
aAdd(aDCTe,"Nome: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_REM:_XNOME:TEXT))
aAdd(aDCTe,"CNPJ: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT)+"   UF: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_REM:_ENDERREME:_UF:TEXT))
aAdd(aDCTe,"")
aAdd(aDCTe,"Destinatario--------------------------------------------------------------------------------")
aAdd(aDCTe,"Nome: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_DEST:_XNOME:TEXT))
aAdd(aDCTe,"CNPJ: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT)+"   UF: "+Alltrim(oCTeVis:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT))
aAdd(aDCTe,"")
aAdd(aDCTe,"Valores-------------------------------------------------------------------------------------")
aAdd(aDCTe,"Total da Prestacao de Servico: R$ " + Transform( Val(oCTeVis:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT), "@E 999,999,999.99" ) )
aAdd(aDCTe,"Base de Calculo do ICMS......: R$ " + Transform( nBICMS, "@E 999,999,999.99" ) )
aAdd(aDCTe,"Aliquota do ICMS.............: R$ " + Transform( nAICMS, "@E 999,999,999.99" ) )
aAdd(aDCTe,"Valor do ICMS................: R$ " + Transform( nVICMS, "@E 999,999,999.99" ) )

DEFINE MSDIALOG oDgCt TITLE "CT-e"+Iif(cOpt=="V"," (visualizacao)"," (importar XML)") FROM 000, 000  TO 520, 800 COLORS 0, 16777215 PIXEL

    @ 005, 007 SAY oSD1 PROMPT "Tela de Monitoramento XML - CTe" SIZE 278, 012 OF oDgCt FONT oFt1 COLORS 0, 16777215 PIXEL
	If cOpt == "I"
	@ 005, 290 BUTTON oBConf PROMPT "Confirma" Action(ImpCTe(oCTeVis,cXML,cChvCTe),oDgCt:End()) SIZE 048, 012 OF oDgCt PIXEL
	EndIf
    @ 005, 344 BUTTON oBSair PROMPT "Sair" Action(oDgCt:End()) SIZE 048, 012 OF oDgCt PIXEL
    @ 024, 008 LISTBOX oLBx1 VAR nLBx1 ITEMS aDCTe SIZE 384, 226 OF oDgCt COLORS 0, 16777215 FONT oFt2 PIXEL

ACTIVATE MSDIALOG oDgCt CENTERED

Return(Nil)


Static Function ImpCte(oCTe,cXML,cChvCTe)
Local cMsg := ""

If !XMLInMnt(cChvCTe)
	cMsg := U_GrvMnCte( SM0->M0_CGC, oCTe, cXML )
	If Empty(cMsg)
		U_Alf04GCT(cChvCTe)
	EndIf
Else
	cMsg := "Este XML já consta do monitor"
EndIf

If !Empty(cMsg)
	Alert(cMsg)
EndIf

Return(Nil)