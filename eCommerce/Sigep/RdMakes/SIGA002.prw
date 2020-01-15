#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} SIGA002

@description Cadastro de Embalagens

@author Bernard M. Margarido

@since 29/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
User Function SIGA002()

Private oBrowse	:= Nil

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("ZZ3")

//-------------------+
// Adiciona Legendas |
//-------------------+
//oBrowse:AddLegend("AY2_STATUS == '1' "	,"GREEN"				,"Ativo")
//oBrowse:AddLegend("AY2_STATUS == '2' "	,"RED"					,"Inativo")

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Cadastro de Embalagens - SIGEP')

//--------------------+
// Ativação do Browse |
//--------------------+
oBrowse:Activate()

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
Local oStruct 
Local oModel

//-----------------------------------------------+
// Cria Estrutura a ser usada no Modelo de Dados |
//-----------------------------------------------+
oStruct := FWFormStruct(1,"ZZ3")

//----------------------------------+
// Cria o Objeto do Modelo de Dados |
//----------------------------------+
oModel	:= MPFormModel():New("ZZ3_00")

//-----------------------------------------------+
// Adiciona ao modelo o componente de formulário |
//-----------------------------------------------+
oModel:AddFields("ZZ3MASTER",/*cOwner*/,oStruct)

//---------------------+
// Cria Chave Primaria |
//---------------------+
oModel:SetPrimaryKey( {"ZZ3_FILIAL","ZZ3_CODIGO"} )

//-----------------------------------------+
// Adiciona a descrição do Modelo de Dados |
//-----------------------------------------+
oModel:SetDescription('Modelo de Dados Cadastro de Embalagens')

//-------------------------------------------------------+
// Adiciona a descrição do componente do Modelo de Dados |
//-------------------------------------------------------+
oModel:GetModel('ZZ3MASTER'):SetDescription('Cadastro de Embalagens - SIGEP')

Return(oModel)

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
Local oDefModel
Local oDefStruct
Local oDefView  

//----------------------------------------------------------------------------+
//³Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado |
//----------------------------------------------------------------------------+
oDefModel := FWLoadModel("SIGA002") 

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
oDefStruct := FWFormStruct( 2,'ZZ3') 

//-----------------------+
// Cria o objeto de View |
//-----------------------+
oDefView := FWFormView():New() 

//------------------------------------------------------+
// Define qual o Modelo de dados será utilizado na View |
//------------------------------------------------------+
oDefView:SetModel(oDefModel) 

//-------------------------------------------------------+
// Adiciona no nosso View um controle do tipo formulário |
// (antiga Enchoice)                                     |
//-------------------------------------------------------+
oDefView:AddField( 'VIEW_ZZ3', oDefStruct, 'ZZ3MASTER' ) 

//---------------------------------------------------------------+
// Criar um "box" horizontal para receber algum elemento da view |
//---------------------------------------------------------------+
oDefView:CreateHorizontalBox( 'TELA' , 100 ) 

//------------------------------------------------------------------+
// Relaciona o identificador (ID) da View com o "box" para exibição |
//------------------------------------------------------------------+
oDefView:SetOwnerView( 'VIEW_ZZ3', 'TELA' ) 

Return( oDefView )

/************************************************************************************/
/*/{Protheus.doc} MenuDef

@description Menu padrao para manutencao do cadastro

@author Bernard M. Margarido

@since 10/08/2017
@version undefined
/*/
/************************************************************************************/
Static Function MenuDef()
Return FWMVCMenu( "SIGA002" )