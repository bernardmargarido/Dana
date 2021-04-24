#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*****************************************************************************************************/
/*/{Protheus.doc} DNMRPA03
    @description Monitor - Abastecimento Filiais 
    @type  Function
    @author Bernard M. Margarido
    @since 29/03/2021
/*/
/*****************************************************************************************************/
User Function DNMRPA03()
Private _nOldLen := SetVarNameLen(255) 
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()
//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("XT6")
//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "XT6_STATUS == '1'", "GREEN"    , "Aberto" )
_oBrowse:AddLegend( "XT6_STATUS == '2'", "YELLOW"   , "Em Transito" )
_oBrowse:AddLegend( "XT6_STATUS == '2'", "RED"      , "Encerrado" )

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('MRP - Monitor Abastecimento')
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
Local _oStruXT6     := FWFormStruct(1,"XT6")
Local _oStruXT7     := FWFormStruct(1,"XT7")
Local _oStruXT8     := FWFormStruct(1,"XT8")

/*Local _bCommit      := {|_oModel| DnMrp02A(_oModel)}*/

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('DNMRPA_03', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
_oModel:SetDescription('MRP - Monitor Abastecimento')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('XT6_01',,_oStruXT6)

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({"XT6_FILIAL","XT6_ID"})

//-----------------------------+
// Pedidos Matriz Abastecedora |
//-----------------------------+
_oModel:AddGrid("XT7_01", "XT6_01" /*cOwner*/, _oStruXT7 , /*_bLiOk */ , /*_bPosOk*/ , /*_bPre*/ , /*_bPost*/, /*_bColor*/)
_oModel:SetRelation( "XT7_01" , { { "XT7_FILIAL" , 'xFilial("XT7")' }, { "XT7_ID" , "XT6_ID" } } , XT7->( IndexKey( 1 ) ) )

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( "XT7_01" ):SetUniqueLine( {"XT7_FILIAL","XT7_ITEM","XT7_ID","XT7_CLIFOR","XT7_LOJA","XT7_PEDIDO"} )

//------------------------------+
// Pedidos Filial Abastecimento |
//------------------------------+
_oModel:AddGrid("XT8_01", "XT6_01" /*cOwner*/, _oStruXT8 , /*_bLiOk */ , /*_bPosOk*/ , /*_bPre*/ , /*_bPost*/, /*_bColor*/)
_oModel:SetRelation( "XT8_01" , { { "XT8_FILIAL" , 'xFilial("XT8")' }, { "XT8_ID" , "XT6_ID" } } , XT8->( IndexKey( 1 ) ) )

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( "XT8_01" ):SetUniqueLine( {"XT8_FILIAL","XT8_ITEM","XT8_ID","XT8_CLIFOR","XT8_LOJA","XT8_PEDIDO"} )

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
Local _oStrViewXT6	:= Nil
Local _oStrViewXT7	:= Nil
Local _oStrViewXT8	:= Nil

Local _nOldLen      := SetVarNameLen(255) 

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("DNMRPA03")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewXT6	:= FWFormStruct( 2,'XT6') 
_oStrViewXT7	:= FWFormStruct( 2,'XT7') 
_oStrViewXT8	:= FWFormStruct( 2,'XT8') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('MRP - Monitor Abastecimento')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XT6_FORM' 	, _oStrViewXT6 , 'XT6_01' )
_oView:AddGrid('XT7_GRID'	, _oStrViewXT7 , 'XT7_01' )
_oView:AddGrid('XT8_GRID'	, _oStrViewXT8 , 'XT8_01' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 030 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'MEI_01' , 005 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INF_01' , 065 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:CreateVerticalBox( 'ESQ_S1'   ,047 , 'INF_01' )
_oView:CreateVerticalBox( 'MEI_S1'   ,006 , 'INF_01' )
_oView:CreateVerticalBox( 'DIR_S1'   ,047 , 'INF_01' )

_oView:SetOwnerView('XT6_FORM'	    ,'SUP_01')
_oView:SetOwnerView('XT7_GRID'	    ,'ESQ_S1')
_oView:SetOwnerView('XT8_GRID'	    ,'DIR_S1')

//------------------------+
// Titulo componente GRID |
//------------------------+
_oView:EnableTitleView('XT6_FORM','ID Processo')
_oView:EnableTitleView('XT7_GRID','Pedidos Matriz Abastecedora')
_oView:EnableTitleView('XT8_GRID','Pedidos Filiais Abastecimento')

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
Local _aRotina := FwMVCMenu('DNMRPA03')

    ADD OPTION _aRotina Title 'Processar Abastecimento' 		Action 'U_DNMRPM03' 	OPERATION 7 ACCESS 0

Return _aRotina