#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} ECLOJ006
    @description Produtos E-Commerce
    @author Bernard M. Margarido
    @since 29/04/2019
    @version undefined
    @type function
/*/
/************************************************************************************/
User Function ECLOJ006()
Private oBrowse		:= Nil

Private aRotina     := MenuDef()

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("SB4")

//-------------------+
// Adiciona Legendas |
//-------------------+
oBrowse:AddLegend("B4_STATUS == '1' "	,"GREEN"				,"Ativo")
oBrowse:AddLegend("B4_STATUS == '2' "	,"RED"					,"Inativo")

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Produtos - eCommerce')

//--------------------+
// Ativação do Browse |
//--------------------+
oBrowse:Activate()

Return Nil

/************************************************************************************/
/*/{Protheus.doc} ECLOJ006

@description Produtos E-Commerce

@author Bernard M. Margarido

@since 29/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
User Function ECLOJ06A(cAlias,nReg,nOpc)
Local _aArea        := GetArea()
Local _aCoors       := FWGetDialogSize( oMainWnd )

Local _cTitulo      := "Produtos - eCommerce"

Local _nOpcA        := 0

Local _oSize        := FWDefSize():New( .T. )
Local _oLayer       := FWLayer():New()
Local _oDlg         := Nil
Local _oPCab        := Nil
Local _oPItem       := Nil
Local _oEnchoice    := Nil
Local _oMsGetDad    := Nil

Private _oFolder    := Nil

Private _aHeader    := {}
Private _aCols      := {}

Private aTela[0][0]
Private aGets[0]

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	:= .T.
_oSize:Process()

//------------------------+
// Monta Dialog principal |
//------------------------+
_oDlg := MsDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3], _oSize:aWindSize[4],_cTitulo,,,,,,,,,.T.)

    _oFolder := TFolder():New(001,001,{ OemToAnsi("Dados eCommerce"), OemToAnsi("Produto X Categorias"), OemToAnsi("Produto X Filtros")},{"HEADER"},_oDlg,,,, .T., .F.,000,000)
	_oFolder:Align := CONTROL_ALIGN_ALLCLIENT

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

    _oMsMGet := MsMGet():New("SB4",,nOpc,,,,,{000,000,000,000},/*aCposAlt*/,,,,,_oPCab,,.F.,.T.)
	_oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

    //---------------+
    // Enchoice Tela |
    //---------------+
    _oDlg:bInit := {|| EnchoiceBar(_oDlg,{||Iif(Obrigatorio(aGets,aTela), (_nOpcA := 1 ,_oDlg:End()) ,_nOpcA := 0) },{|| _oDlg:End() },.F.)}

_oDlg:Activate(,,,.T.,,,)

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
    aAdd(aRotina, {"Pesquisa"   , "AxPesqui"    , 0, 1 })  // Pesquisa
    aAdd(aRotina, {"Visualizar" , "U_ECLOJ06A"  , 0, 2 })  // Visualizar
    aAdd(aRotina, {"Incluir"    , "U_ECLOJ06A"  , 0, 3 })  // Incluir
    aAdd(aRotina, {"Alterar"    , "U_ECLOJ06A"  , 0, 4 })  // Alterar
    aAdd(aRotina, {"Excluir"    , "U_ECLOJ06A"  , 0, 5 })  // Excluir
Return aRotina
