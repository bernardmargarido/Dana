#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*************************************************************************************************************/
/*/{Protheus.doc} DNFINA01
    @description Browser Inicial com os pagamentos por data 
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/*************************************************************************************************************/
User Function DNFINA01()
Private _nOldLen := SetVarNameLen(255) 
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()
//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("XT9")
//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "XT9_STATUS == '1'", "GREEN"    , "Em Aberto" )
_oBrowse:AddLegend( "XT9_STATUS == '2'", "YELLOW"   , "Parcialmente Conciliado" )
_oBrowse:AddLegend( "XT9_STATUS == '3'", "RED"      , "Conciliado" )

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Conciliação e-Commerce')

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
Local _oStruXT9     := Nil
Local _oStruXTA		:= Nil

//Local _bCommit      := {|_oModel| DFinaA01A(_oModel)}
//-----------------+
// Monta Estrutura |
//-----------------+
_oStruXT9   := FWFormStruct(1,"XT9")
_oStruXTA	:= FWFormStruct(1,"XTA")

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('DFINA_01', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
_oModel:SetDescription('Conciliação e-Commerce')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('XT9_01',,_oStruXT9)
_oModel:AddGrid("XTA_01", "XT9_01" /*cOwner*/, _oStruXTA , /*_bLiOk */ , /*_bPosOk*/ , /*_bPre*/ , /*_bPost*/, /*_bColor*/)
_oModel:SetRelation( 'XTA_01', { { 'XTA_FILIAL', 'xFilial( "XTA" )' }, { 'XTA_CODIGO', 'XT9_CODIGO' } }, XTA->( IndexKey( 1 ) ) )

//----------------+
// Chave primaria | 
//----------------+
_oModel:SetPrimaryKey({"XT9_FILIAL","XT9_CODIGO"})

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( "XTA_01" ):SetUniqueLine( {"XTA_FILIAL","XTA_CODIGO","XTA_IDPAY"} )

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
Local _oStrViewXT9	:= Nil
Local _oStrViewXTA	:= Nil

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("DNFINA01")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewXT9	:= FWFormStruct( 2,'XT9') 
_oStrViewXTA	:= FWFormStruct( 2,'XTA') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('Conciliação e-Commerce')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XT9_FORM' 	, _oStrViewXT9 , 'XT9_01' )
_oView:AddGrid('XTA_GRID' 	, _oStrViewXTA , 'XTA_01' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 030 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INF_01' , 070 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:SetOwnerView('XT9_FORM'	    ,'SUP_01')
_oView:SetOwnerView('XTA_GRID'	    ,'INF_01')

//------------------------+
// Titulo componente GRID |
//------------------------+
_oView:EnableTitleView('XT9_FORM','Dados Recebiveis')
_oView:EnableTitleView('XTA_GRID','Titulos Recebiveis')

//-------------------+
// Adicionando botão | 
//-------------------+
//_oView:AddUserButton( 'Visualiza NF-e', 'CLIPS', {|_oView| U_BSFATA07() } )

Return _oView 

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
ADD OPTION _aRotina TITLE "Visualizar"           	ACTION "VIEWDEF.DNFINA01" 			OPERATION 2 ACCESS 0 
ADD OPTION _aRotina TITLE "Incluir"              	ACTION "U_DNFINA02" 			    OPERATION 3 ACCESS 0 
ADD OPTION _aRotina TITLE "Excluir"              	ACTION "VIEWDEF.DNFINA01" 			OPERATION 5 ACCESS 0 
ADD OPTION _aRotina TITLE "Conciliar"           	ACTION "U_DNFINA03"		 			OPERATION 6 ACCESS 0 
ADD OPTION _aRotina TITLE "Saldo "           	    ACTION "U_DNFINA04"		 			OPERATION 6 ACCESS 0 
ADD OPTION _aRotina TITLE "Configuracoes "     	    ACTION "U_DNFINA08"		 			OPERATION 6 ACCESS 0 

Return _aRotina
