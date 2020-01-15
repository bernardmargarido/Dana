#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} SIGA003

@description Cadastro de Serviços SIGEP

@author Bernard M. Margarido

@since 29/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
User Function SIGA003()

Private _oBrowse	:= Nil
Private _aRotina 	:= MenuDef()

If ZZ0->( Eof() )
    //+----------------------------------------+
    //| Verifica se existe a categoria inicial |
    //+----------------------------------------+
    U_SIGM001()
EndIf

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
_oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
_oBrowse:SetAlias("ZZ0")

//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend("dTos(ZZ0_DTFIM) > Dtos(dDataBase) "	    ,"GREEN"				,"Ativo")
_oBrowse:AddLegend("dTos(ZZ0_DTFIM) <= Dtos(dDataBase) "	,"RED"					,"Vencido")

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Serviços Contratados - SIGEP')

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
Local _oStructZZ0
Local _oModel

//-----------------------------------------------+
// Cria Estrutura a ser usada no Modelo de Dados |
//-----------------------------------------------+
_oStructZZ0 := FWFormStruct(1,"ZZ0")

//------------------------------------------+
// Altera propriedades dos campos no Modelo |
//------------------------------------------+
_oStructZZ0:SetProperty("ZZ0_CODSER" , MODEL_FIELD_WHEN , {|| .T. } )
_oStructZZ0:SetProperty("ZZ0_IDSER"  , MODEL_FIELD_WHEN , {|| .T. } )
_oStructZZ0:SetProperty("ZZ0_DESCRI" , MODEL_FIELD_WHEN , {|| .T. } )
_oStructZZ0:SetProperty("ZZ0_DTINI"  , MODEL_FIELD_WHEN , {|| .T. } )
_oStructZZ0:SetProperty("ZZ0_DTFIM"  , MODEL_FIELD_WHEN , {|| .T. } )

//----------------------------------+
// Cria o Objeto do Modelo de Dados |
//----------------------------------+
_oModel	:= MPFormModel():New("ZZ0_00")

//-----------------------------------------------+
// Adiciona ao modelo o componente de formulário |
//-----------------------------------------------+
_oModel:AddFields("ZZ0MASTER",/*cOwner*/,_oStructZZ0)

//---------------------+
// Cria Chave Primaria |
//---------------------+
_oModel:SetPrimaryKey( {"ZZ0_FILIAL","ZZ0_CODSER"} )

//-----------------------------------------+
// Adiciona a descrição do Modelo de Dados |
//-----------------------------------------+
_oModel:SetDescription('Modelo de Dados Serviços contratados')

//-------------------------------------------------------+
// Adiciona a descrição do componente do Modelo de Dados |
//-------------------------------------------------------+
_oModel:GetModel('ZZ0MASTER'):SetDescription('Serviços Contratados - SIGEP')

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
Local _oModel
Local _oStructZZ0
Local _oView  

//----------------------------------------------------------------------------+
//³Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado |
//----------------------------------------------------------------------------+
_oModel := FWLoadModel("SIGA003") 

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStructZZ0 := FWFormStruct( 2,'ZZ0') 

//-----------------------+
// Cria o objeto de View |
//-----------------------+
_oView := FWFormView():New() 

//------------------------------------------------------+
// Define qual o Modelo de dados será utilizado na View |
//------------------------------------------------------+
_oView:SetModel(_oModel) 

//-------------------------------------------------------+
// Adiciona no nosso View um controle do tipo formulário |
// (antiga Enchoice)                                     |
//-------------------------------------------------------+
_oView:AddField( 'VIEW_ZZ0', _oStructZZ0, 'ZZ0MASTER' ) 

//---------------------------------------------------------------+
// Criar um "box" horizontal para receber algum elemento da view |
//---------------------------------------------------------------+
_oView:CreateHorizontalBox( 'TELA' , 100 ) 

//------------------------------------------------------------------+
// Relaciona o identificador (ID) da View com o "box" para exibição |
//------------------------------------------------------------------+
_oView:SetOwnerView( 'VIEW_ZZ0', 'TELA' ) 

Return( _oView )

/************************************************************************************/
/*/{Protheus.doc} MenuDef

@description Menu padrao para manutencao do cadastro

@author Bernard M. Margarido

@since 10/08/2017
@version undefined
/*/
/************************************************************************************/
Static Function MenuDef()
    Local aRotina	:= {}

    ADD OPTION aRotina TITLE "Pesquisa"  			ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"          	ACTION "VIEWDEF.SIGA003" 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.SIGA003" 		OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.SIGA003" 		OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Valida Contrato"      ACTION "U_SIGM001" 		        OPERATION 4 ACCESS 0 

Return aRotina