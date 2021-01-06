#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/******************************************************************************/
/*/{Protheus.doc} DLOGA01
    @description DLog - Postagem DLog
    @type  Function
    @author Bernard M. Margarido
    @since 06/01/2021
/*/
/******************************************************************************/
User Function DLOGA01()
Private _nOldLen := SetVarNameLen(255) 
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()
//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("ZZB")
//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "ZZB_STATUS == '1'", "RED"      , "Lista Gerada" )
_oBrowse:AddLegend( "ZZB_STATUS == '2'", "GREEN"    , "Lista Enviada" )
_oBrowse:AddLegend( "ZZB_STATUS == '3'", "BLACK"    , "Erro ao Enviar Lista" )

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('DLOG - Monitor')
//--------------------+
// Ativação do Browse |
//--------------------+
_oBrowse:Activate()
SetVarNameLen(_nOldLen)

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
Local _oStruZZB     := Nil
Local _oStruZZC		:= Nil

Local _bCommit      := {|_oModel| DLogA01Com(_oModel)}

//-----------------+
// Monta Estrutura |
//-----------------+
_oStruZZB   := FWFormStruct(1,"ZZB")
_oStruZZC	:= FWFormStruct(1,"ZZC")

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('DLOGA_01', /*bPreValid*/ , /*_bPosValid*/ , _bCommit , /*_bCancel*/ )
_oModel:SetDescription('DLOG - Monitor')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('ZZB_01',,_oStruZZB)

//--------------------------+
// Chave primaria cabeçalho | 
//--------------------------+
_oModel:SetPrimaryKey({"ZZB_FILIAL","ZZB_CODIGO"})

//----------------------------+
// Cabeçalho X Notas Postagem |
//----------------------------+
_oModel:AddGrid("ZZC_01", "ZZB_01" /*cOwner*/, _oStruZZC , /*_bLiOk */ , /*_bPosOk*/ , /*_bPre*/ , /*_bPost*/, /*_bColor*/)
_oModel:SetRelation( "ZZC_01" , { { "ZZC_FILIAL" , 'xFilial("ZZC")' }, { "ZZC_CODIGO" , "ZZB_CODIGO" } } , ZZC->( IndexKey( 1 ) ) )

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( "ZZC_01" ):SetUniqueLine( {"ZZC_FILIAL","ZZC_CODIGO","ZZC_NOTA","ZZC_SERIE"} )

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
Local _oStrViewZZB	:= Nil
Local _oStrViewZZC  := Nil

Local _nOldLen      := SetVarNameLen(255) 

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("DLOGA01")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewZZB	:= FWFormStruct( 2,'ZZB') 
_oStrViewZZC    := FWFormStruct( 2,'ZZC') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('DLOG - Monitor')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('ZZB_FORM' 	, _oStrViewZZB , 'ZZB_01' )
_oView:AddGrid('ZZC_GRID'	, _oStrViewZZC , 'ZZC_01' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 050 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'MEI_01' , 005 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INF_01' , 045 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

//_oView:CreateVerticalBox( 'ESQ_S1'   ,047 , 'INF_01' )
//_oView:CreateVerticalBox( 'MEI_S1'   ,006 , 'INF_01' )
//_oView:CreateVerticalBox( 'DIR_S1'   ,047 , 'INF_01' )
_oView:CreateVerticalBox( 'ESQ_S1'   ,100 , 'INF_01' )

//--------------+
// Panel Botoes | 
//--------------+
//_oView:AddOtherObject("VIEW_BTN", {|_oPanel| DlogA01Btn(_oPanel)})   

_oView:SetOwnerView('ZZB_FORM'	    ,'SUP_01')
_oView:SetOwnerView('ZZC_GRID'	    ,'ESQ_S1')
//_oView:SetOwnerView('XT3_GRID'	    ,'DIR_S1')
//_oView:SetOwnerView('VIEW_BTN'	    ,'MEI_S1')

//------------------------+
// Titulo componente GRID |
//------------------------+
_oView:EnableTitleView('ZZB_FORM','Dados Postagem')
_oView:EnableTitleView('ZZC_GRID','Notas Postagem')

//-------------------+
// Adicionando botão | 
//-------------------+
//_oView:AddUserButton( 'Visualiza NF-e', 'CLIPS', {|_oView| U_BSFATA07() } )

Return _oView 

/***************************************************************************************/
/*/{Protheus.doc} MENUDEF
	@description Função de definição do Menu da Rotina
	@author	Bernard M. Margarido
	@since		18/02/2016
	@version	1.00
/*/
/***************************************************************************************/
Static Function MenuDef()     
	Local aRotina	:= {}
										
	ADD OPTION aRotina TITLE "Pesquisa"  			ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"          	ACTION "VIEWDEF.DLOGA01" 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Incluir" 	            ACTION "U_DLOGM02" 				OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.DLOGA01" 		OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.DLOGA01" 		OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE "Envia PLP"			ACTION 'U_DLOGM03'		  		OPERATION 4 ACCESS 0
		
Return aRotina