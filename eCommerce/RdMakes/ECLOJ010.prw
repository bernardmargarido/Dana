#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} ECLOJ010

@description Gestão de Pedidos e-Commerce

@author Bernard M. Margarido

@since 29/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
User Function ECLOJ010()

Private oBrowse	:= Nil

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("WSA")

//-------------------+
// Adiciona Legendas |
//-------------------+
	dbSelectArea("WS1")
	WS1->( dbGoTop() )
	While WS1->( !Eof() ) 
		oBrowse:AddLegend( "WSA_CODSTA == '" + WS1->WS1_CODIGO + "'", WS1->WS1_CORSTA , WS1->WS1_DESCRI )
		WS1->( dbSkip() )
	EndDo	  

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Gestão Pedidos eCommerce')

//--------------------+
// Ativação do Browse |
//--------------------+
oBrowse:Activate()

Return Nil

/************************************************************************************/
/*/{Protheus.doc} ECLOJ10A

@description Visualiza dados do pedido e-Commerce

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
User Function ECLOJ10A(cAlias,nReg,nOpc)
Local _aArea		:= GetArea()
Local _aCoors       := FWGetDialogSize( oMainWnd )

Local _cTitulo      := "Pedidos - eCommerce"

Local _nOpcA        := 0

Local _oSize        := FWDefSize():New( .T. )
Local _oLayer       := FWLayer():New()
Local _oDlg         := Nil
Local _oPCab        := Nil
Local _oPItem       := Nil
Local _oMsMGet 		:= Nil
Local _oMsMGetEnd	:= Nil
Local _oMsGetDIt   	:= Nil

Private _oFolder    := Nil

Private _aHeadIt    := {}
Private _aColsIt    := {}
Private _aCab		:= {}
Private _aEnd		:= {}
Private aField 		:= {}

Private aTela[0][0]
Private aGets[0]

//----------------------------------+
// Campos tela de gestão de pedidos |
//----------------------------------+
EcLoj010Cpo()

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	:= .T.
_oSize:Process()

//------------------------+
// Cria campos na memória |
//------------------------+
RegToMemory( "WSA", IIF(nOpc == 3,.T.,.F.) )

//------------------------+
// Monta Dialog principal |
//------------------------+
_oDlg := MsDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3], _oSize:aWindSize[4],_cTitulo,,,,,,,,,.T.)
  

    //--------------------+
    // Layer da estrutura |
    //--------------------+
    _oLayer:Init( _oDlg, .F. )
    _oLayer:AddLine( "LINE01", 040 )
    _oLayer:AddLine( "LINE02", 055 )

    _oLayer:AddCollumn( "COLLL01"  , 100,, "LINE01" )
    _oLayer:AddCollumn( "COLLL02"  , 100,, "LINE02" )

    _oLayer:AddWindow( "COLLL01" , "WNDCABEC"  , ""     , 100 ,.F. ,,,"LINE01" )
    _oLayer:AddWindow( "COLLL02" , "WNDITEMS"  , ""     , 095 ,.F. ,,,"LINE02" )

    _oPCab  := _oLayer:GetWinPanel( "COLLL01"   , "WNDCABEC"  , "LINE01" )
    _oPItem := _oLayer:GetWinPanel( "COLLL02"   , "WNDITEMS"  , "LINE02" )

	//--------------------+
    // Enchoice Cabeçalho |
    //--------------------+
    _oMsMGet := MsMGet():New("WSA",,2,,,,_aCab,{000,000,000,000},/*aCposAlt*/,,,,,_oPCab,,.F.,.T.)
	_oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//----------------------------------+
	// Folder Itens/Destinatario/Status |
	//----------------------------------+
	_oFolder := TFolder():New(001,001,{ OemToAnsi("Itens eCommerce"), OemToAnsi("Destinatario"), OemToAnsi("Status Pedido")},{"HEADER"},_oPItem,,,, .T., .F.,000,000)
	_oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	//--------------+
	// Itens Pedido |
	//--------------+
	_oMsGetDIt 	:= MsNewGetDados():New(000,000,000,000,2,/*cLinOk*/,/*cTudoOk1*/,/*cIniCpos*/,/*aAlterGda*/,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,_oFolder:aDialogs[1],_aHeadIt,_aColsIt)
	_oMsGetDIt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//--------------+
	// Destinatario |
	//--------------+	 
	_oMsMGetEnd := MsMGet():New("WSA",WSA->( Recno() ),2,,,,,{000,000,000,000},,,,,,_oFolder:aDialogs[2],,,,,,.T.,aField)
	_oMsMGetEnd:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//-----------------+
    // Enchoice Botoes |
	//-----------------+
    _oDlg:bInit := {|| EnchoiceBar(_oDlg,{||Iif(Obrigatorio(aGets,aTela), (_nOpcA := 1 ,_oDlg:End()) ,_nOpcA := 0) },{|| _oDlg:End() },.F.)}

_oDlg:Activate(,,,.T.,,,)

RestArea(_aArea)
Return Nil

/***************************************************************************************/
/*/{Protheus.doc} EcLoj010Cpo
	@description Cria campos exibição tela de gestão de pedidos
	@type  Static Function
	@author user
	@since date
	@version version
/*/
/***************************************************************************************/
Static Function EcLoj010Cpo()
Local _aArea	:= GetArea()

Local _nX		:= 0

//------------------+
// Campos cabeçalho |
//------------------+
_aCab	:= {"NOUSER","WSA_NUM","WSA_CLIENT","WSA_LOJA","WSA_NOMCLI",;
			"WSA_EMISSA","WSA_VLRTOT","WSA_NUMECO","WSA_NUMECL",;
			"WSA_DOC","WSA_SERIE","WSA_OBSECO","WSA_MTCANC","WSA_CODSTA",;
			"WSA_DESTAT","WSA_VLBXPV"}


//---------------------------------+			
// Cria campos folder destinatario |
//---------------------------------+
_aEnd	:= {"WSA_NOMDES","WSA_ENDENT","WSA_ENDNUM","WSA_BAIRRE","WSA_MUNE",;
			"WSA_CEPE","WSA_ESTE","WSA_TPFRET","WSA_FRETE","WSA_SEGURO",;
			"WSA_DESPES","WSA_PLIQUI","WSA_PBRUTO","WSA_VOLUME","WSA_ESPECI",;
			"WSA_TRANSP"}

//---------------------------+
// Array campos destinatario |
//---------------------------+
dbSelectArea("SX3")
SX3->( dbSetOrder(2) )
For _nX := 1 To Len(_aEnd)
	If SX3->( dbSeek(PadR(_aEnd[_nX],10)) )
		aAdd(aField,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,,.F.,1,,,,.F.,.F.,Iif(__Language=="SPANISH",SX3->X3_CBOXSPA,Iif(__Language=="ENGLISH",SX3->X3_CBOXENG,SX3->X3_CBOX)),,.F.,,})
	Endif	
Next _nX	

//-----------------+
// Itens do Pedido |
//-----------------+
_aHeadIt    := {}
_aColsIt    := {}

dbSelectArea("SX3")
SX3->( dbSetOrder(1) )
If SX3->( dbSeek("WSB") )
	While SX3->( !Eof() .And. SX3->X3_ARQUIVO == "WSB" )
		If X3Uso(SX3->X3_USADO) //.And. aScan(aCpoGDa, {|x| Upper(AllTrim(x)) == Upper(Alltrim(SX3->X3_CAMPO))}) > 0
				aAdd(_aHeadIt,{	AllTrim(X3Titulo())	,;
								SX3->X3_CAMPO		,;
								SX3->X3_PICTURE		,;
								SX3->X3_TAMANHO		,;
								SX3->X3_DECIMAL		,;
								SX3->X3_VALID		,;
								SX3->X3_USADO		,;
								SX3->X3_TIPO		,;
								SX3->X3_F3			,;
								SX3->X3_CONTEXT		})
			EndIf
		SX3->( dbSkip() )
	EndDo
EndIf

dbSelectArea("WSB")
WSB->( dbSetOrder(1) )
If WSB->(dbSeek(xFilial("WSB") + WSA->WSA_NUM) )
	While WSB->( !Eof() .And. xFilial("WSB") + WSA->WSA_NUM == WSB->WSB_FILIAL + WSB->WSB_NUM )
		aAdd(_aColsIt,Array(Len(_aHeadIt)+1)) 
		For nX:= 1 To Len(_aHeadIt)
			_aColsIt[Len(_aColsIt)][nX] := FieldGet(FieldPos(_aHeadIt[nX][2]))
		Next nX
		_aColsIt[Len(_aColsIt)][Len(_aHeadIt)+1]:= .F.
		WSB->( dbSkip() )
	EndDo
EndIf

If Len(_aColsIt) <= 0
	aAdd(_aColsIt,Array(Len(_aHeadIt)+1)) 
	For nX:= 1 To Len(_aHeadIt)
		_aColsIt[1][nX]:= CriaVar(_aHeadIt[nX][2],.T.)
	Next nX
	_aColsIt[1][Len(_aHeadIt)+1]:= .F.
EndIf

RestArea(_aArea)
Return Nil

/************************************************************************************/
/*/{Protheus.doc} ECLOJ101

@description Realiza a liberação de pedido 

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
User Function ECLOJ101()
Local _aArea	:= GetArea()

	FWMsgRun(, {|| U_ECLOJ012() }, "Aguarde....", "Processando pedidos e-Commerce." )

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} MenuDef

@description Menu padrao para manutencao do cadastro

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function MenuDef()
Local aRotina := {}
Local aRotFat := {}
Local aRotTro := {}
Local aRotIbx := {}

//-----------------------+
// Rotina de Faturamento | 
//-----------------------+
aAdd(aRotFat, {"Libera Pedido"	,"U_ECLOJ101", 0, 4} )	// Libera Pedido
aAdd(aRotFat, {"Prep. Documento","U_ECLOJ102", 0, 4} )	// Prepara Documento
aAdd(aRotFat, {"Trans. Sefaz"	,"U_ECLOJ103", 0, 4} )	// Transmissão Sefaz

//----------------------+
// Troca / Cancelamento |
//----------------------+
aAdd(aRotTro, {"Cancela Pedido" ,"U_ECLOJ104", 0, 4 } )	// Cancela Pedido
aAdd(aRotTro, {"Troca/Devolucao","U_ECLOJ105", 0, 4 } )	// Troca / Devolução

//-------------------+
// Pedidos para IBEX |
//-------------------+
aAdd(aRotIbx, {"Envia PV. IBEX","U_IBFATM01", 0, 4 } )	// Envia Pedidos Ibex Logistica
aAdd(aRotIbx, {"Envia NF. IBEX","U_ECLOJM06", 0, 4 } )	// Envia Notas Ibex Logistica

aAdd(aRotina, {"Pesquisa"   	, "AxPesqui"    , 0, 1 })  // Pesquisa
aAdd(aRotina, {"Visualizar" 	, "U_ECLOJ10A"  , 0, 2 })  // Visualizar
aAdd(aRotina, {"Faturamento"	, aRotFat		, 0, 4 })  // Faturamento
aAdd(aRotina, {"Canc / Troca"   , aRotTro  		, 0, 4 })  // Cancelamento / Troca Devolução
aAdd(aRotina, {"Env. IBEX"   	, aRotIbx  		, 0, 4 })  // Envia Pedidos Ibex Logistica
Return aRotina