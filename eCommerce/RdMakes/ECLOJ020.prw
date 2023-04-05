#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static _cCSSBtn :=  "QPushButton { background-color: #f44336; color: white; font-size:24px; font-style:bold  } " + ;
                    "QPushButton:focus { background-color: #f59794; border-style: solid; border-width: 8px  } "
                    
/******************************************************************************/
/*/{Protheus.doc} ECLOJ020
    @description Monitor impressao de notas fiscais eCommerce
    @type  Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/******************************************************************************/
User Function ECLOJ020()
Local _nTime        := GetMv("DN_TMEXPEC",,10)

Private _oBrowse    := Nil 

//--------------------------------------+
// Cria botão de atalho para parametros |
//--------------------------------------+
SetKey( VK_F12, { || Pergunte("ECLOJ12",.T.) } )
Pergunte("ECLOJ12",.F.)

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()

//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("XTE")

//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "XTE_STATUS == '1'", "GREEN" , "Aguardando Transmissao")
_oBrowse:AddLegend( "XTE_STATUS == '2'", "RED"   , "Transmitido com sucesso")
_oBrowse:AddLegend( "XTE_STATUS == '3'", "ORANGE", "PDF Impresso")
_oBrowse:AddLegend( "XTE_STATUS == '4'", "BLACK" , "Erro")

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Monitor - Expedição eCommerce')
_oBrowse:SetTimer({|| RefreshBrw(_oBrowse) }, IIF(_nTime<=0, 3600, ( _nTime * 60 ) ) * 1000)
_oBrowse:SetMenuDef("ECLOJ020")

//--------------------+
// Ativação do Browse |
//--------------------+
_oBrowse:Activate()

Return Nil 

/************************************************************************************/
/*/{Protheus.doc} ModelDef
@description  Modelo de dados, estrutura dos dados e modelo de negocio
@author Bernard M. Margarido
@since 10/08/2017
@version undefined
@type function
/*/
/************************************************************************************/
Static Function ModelDef()
Local _oModel		:= Nil
Local _oStruXTE     := Nil

//-----------------+
// Monta Estrutura |
//-----------------+
_oStruXTE   := FWFormStruct(1,"XTE")

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('ECLOJ20_01', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('MASTER',,_oStruXTE)

_oModel:SetDescription('Monitor - Expedição eCommerce')
_oModel:GetModel('MASTER'):SetDescription("Monitor - Expedição eCommerce")

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({"XTE_FILIAL","XTE_DOC","XTE_SERIE"})

_oModel:SetActivate()

Return _oModel

/************************************************************************************/
/*/{Protheus.doc} ViewDef
    @description Cria interface com o usuario
    @author Bernard M. Margarido
    @since 10/08/2017
    @version undefined
    @type function
/*/
/************************************************************************************/
Static Function ViewDef() 
Local _oView        
Local _oModel
Local _oStrViewXTE	:= Nil

Local _nOldLen      := SetVarNameLen(255) 

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("ECLOJ020")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewXTE	:= FWFormStruct( 2,'XTE') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('Monitor - Expedição eCommerce')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XTE_FORM' 	, _oStrViewXTE , 'MASTER' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 100 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:SetOwnerView('XTE_FORM'	    ,'SUP_01')

SetVarNameLen(_nOldLen)

Return _oView 

/************************************************************************************/
/*/{Protheus.doc} ECLOJ20A
    @description Impressão de Danfe e PLP via leitor 
    @type  Function
    @author Bernard M Margarido
    @since 22/03/2023
/*/
/************************************************************************************/
User Function ECLOJ20A()
Local _cCodEtq      := Space(6)
Local _cTitulo      := "Dana - Expedição e-Commerce"
Local _cTextSay     := '<h1 style="color:rgb(11, 155, 191); font-size: 36 "> Etiqueta: </h1>'
Local _nLinIni      := 0
Local _nColIni      := 0
Local _nLinFin      := 0
Local _nColFin      := 0

Local _aCoors   	:= FWGetDialogSize( oMainWnd )

Local _bValdGet     := {|| IIF(!Empty(_cCodEtq),(FwMsgRun(,{|_oSay| U_EcLojM10(_oSay,_cCodEtq)},"Aguarde...","Gerando Etiquetas."),_cCodEtq := Space(6),_oTGetEtq:SetFocus()),(.T.))}

Local _oSize    	:= FWDefSize():New(.T.)
Local _oFont32      := TFont():New('Arial',,-62,.T.)
Local _oSayEtq      := Nil 
Local _oTGroup      := Nil 
Local _oPanel       := Nil 
Local _oDlg         := Nil 

Private _oTGetEtq   := Nil 

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	 := .T.
_oSize:aWindSize     := {0,5,492,906}
_oSize:Process()

_oDlg := MsDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2], _oSize:aWindSize[3], _oSize:aWindSize[4], _cTitulo,,,,DS_MODALFRAME,,,,,.T.)

    _nLinIni := _oSize:GetDimension("DLG","LININI")
	_nColIni := _oSize:GetDimension("DLG","COLINI")
	_nLinFin := _oSize:GetDimension("DLG","LINEND")
	_nColFin := _oSize:GetDimension("DLG","COLEND")


    _oPanel := TPanel():New(001,001, , _oDlg,, .T.,,,, 200, 100, .F.)
    _oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    _oTGroup    := TGroup():New(_nColIni,_nColIni,_nLinFin - 230 ,_nColFin - 500,'Etiqueta',_oPanel,,,.T.)

    _oSayEtq    := TSay():New(_nLinIni + 15, _nColIni + 146 , {|| _cTextSay }, _oPanel,,,,,,.T.,,,100,060,,,,,,.T.)

    _oTGetEtq	:= TGet():New( _nLinIni + 30, _nColIni + 146	, {|u| IIF(PCount() > 0, _cCodEtq := u, _cCodEtq	)} 	, _oPanel, 160, 060,"@!",_bValdGet,,,_oFont32,,,.T.,,,,,,,.F.,,,"_cCodEtq",,,,.T.,,,"",2)
	_oTGetEtq:SetFocus()

    _oBtnSair  	:= TButton():New( _nLinFin - 228, _nColIni , "Sair", _oDlg,{|| _oDlg:End() } ,_nColFin - 504,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    _oBtnSair:SetCss(_cCSSBtn)

_oDlg:Activate(,,,.T.,,,)  

Return Nil 

/************************************************************************************/
/*/{Protheus.doc} RefreshBrw
    @description Realiza a atualização da tela de expedição eCommerce
    @type  Static Function
    @author Bernard M Margarido
    @since 22/03/2023
    @version version
/*/
/************************************************************************************/
Static Function RefreshBrw(_oBrowse)
    _oBrowse:Refresh(.T.)
    _oBrowse:GoBottom()
Return .T.

/************************************************************************************/
/*/{Protheus.doc} MenuDef
	@description Menu padrao para manutencao do cadastro
	@author Bernard M. Margarido
	@since 10/08/2017
	@version undefined
/*/
/************************************************************************************/
Static Function MenuDef()
Local _aRotina := {}
    ADD OPTION _aRotina TITLE "Pesquisar"            	ACTION "PesqBrw"            		OPERATION 1 ACCESS 0  
    ADD OPTION _aRotina TITLE "Visualizar"           	ACTION "VIEWDEF.ECLOJ020" 			OPERATION 2 ACCESS 0 
    ADD OPTION _aRotina TITLE "Impressao Nota"         	ACTION "U_ECLOJ20A"      			OPERATION 6 ACCESS 0 
Return _aRotina
