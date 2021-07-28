#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*************************************************************************************************************/
/*/{Protheus.doc} DNFINA05
    @description Transferencias PagarMe
    @type  Function
    @author Bernard M. Margarido
    @since 15/07/2021
/*/
/*************************************************************************************************************/
User Function DNFINA05()
Private _nOldLen := SetVarNameLen(255) 
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()
//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("XTB")
//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "XTB_STATUS == '1'", "GREEN"    , "Criada"      )
_oBrowse:AddLegend( "XTB_STATUS == '2'", "YELLOW"   , "Solicitado"  )
_oBrowse:AddLegend( "XTB_STATUS == '3'", "RED"      , "Recebido"    )

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Transferencias PagarMe')

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
Local _oStruXTB     := Nil

//-----------------+
// Monta Estrutura |
//-----------------+
_oStruXTB   := FWFormStruct(1,"XTB")

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('DFINA_05', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
_oModel:SetDescription('Transferencias PagarMe')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('XTB_01',,_oStruXTB)

//----------------+
// Chave primaria | 
//----------------+
_oModel:SetPrimaryKey({"XTB_FILIAL","XTB_CODIGO"})

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
Local _oStrViewXTB	:= Nil

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("DNFINA05")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewXTB	:= FWFormStruct( 2,'XTB') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('Transferencias PagarMe')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XTB_FORM' 	, _oStrViewXTB , 'XTB_01' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 100 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:SetOwnerView('XTB_FORM'	    ,'SUP_01')

//------------------------+
// Titulo componente GRID |
//------------------------+
_oView:EnableTitleView('XTB_FORM','Dados Transferencia')

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
ADD OPTION _aRotina TITLE "Visualizar"           	ACTION "VIEWDEF.DNFINA05" 			OPERATION 2 ACCESS 0 
ADD OPTION _aRotina TITLE "Excluir"              	ACTION "VIEWDEF.DNFINA05" 			OPERATION 5 ACCESS 0 
ADD OPTION _aRotina TITLE "Enviar Transf."         	ACTION "U_DNFINA06"		 			OPERATION 6 ACCESS 0 
ADD OPTION _aRotina TITLE "Banco Transf."         	ACTION "U_DNFINA07"		 			OPERATION 3 ACCESS 0 

Return _aRotina