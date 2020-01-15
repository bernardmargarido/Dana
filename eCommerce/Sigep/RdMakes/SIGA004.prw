#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} SIGA004

@description Cadastro de Etiquetas SIGEP

@author Bernard M. Margarido

@since 29/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
User Function SIGA004()

Private _oBrowse	:= Nil
Private _aRotina 	:= MenuDef()

If ZZ1->( Eof() )
    //+----------------------------------------+
    //| Verifica se existe a categoria inicial |
    //+----------------------------------------+
    U_SIGM003()
EndIf

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
_oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
_oBrowse:SetAlias("ZZ1")

//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend("Empty(ZZ1_NUMECO) .And. Empty(ZZ1_PLPID)"	    ,"GREEN"				,"Livre")
_oBrowse:AddLegend("!Empty(ZZ1_NUMECO) .And. Empty(ZZ1_PLPID)"	    ,"YELLOW"				,"Reservada")
_oBrowse:AddLegend("!Empty(ZZ1_NUMECO) .And. !Empty(ZZ1_PLPID)"	    ,"RED"					,"Usada")

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Etiquetas - SIGEP')

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
Local _oStructZZ1
Local _oModel

//-----------------------------------------------+
// Cria Estrutura a ser usada no Modelo de Dados |
//-----------------------------------------------+
_oStructZZ1 := FWFormStruct(1,"ZZ1")

//----------------------------------+
// Cria o Objeto do Modelo de Dados |
//----------------------------------+
_oModel	:= MPFormModel():New("ZZ1_00")

//-----------------------------------------------+
// Adiciona ao modelo o componente de formulário |
//-----------------------------------------------+
_oModel:AddFields("ZZ1MASTER",/*cOwner*/,_oStructZZ1)

//---------------------+
// Cria Chave Primaria |
//---------------------+
_oModel:SetPrimaryKey( {"ZZ1_FILIAL","ZZ1_CODETQ"} )

//-----------------------------------------+
// Adiciona a descrição do Modelo de Dados |
//-----------------------------------------+
_oModel:SetDescription('Modelo de Dados Etiquetas')

//-------------------------------------------------------+
// Adiciona a descrição do componente do Modelo de Dados |
//-------------------------------------------------------+
_oModel:GetModel('ZZ1MASTER'):SetDescription('Etiquetas - SIGEP')

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
Local _oStructZZ1
Local _oView  

//----------------------------------------------------------------------------+
//³Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado |
//----------------------------------------------------------------------------+
_oModel := FWLoadModel("SIGA004") 

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStructZZ1 := FWFormStruct( 2,'ZZ1') 

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
_oView:AddField( 'VIEW_ZZ1', _oStructZZ1, 'ZZ1MASTER' ) 

//---------------------------------------------------------------+
// Criar um "box" horizontal para receber algum elemento da view |
//---------------------------------------------------------------+
_oView:CreateHorizontalBox( 'TELA' , 100 ) 

//------------------------------------------------------------------+
// Relaciona o identificador (ID) da View com o "box" para exibição |
//------------------------------------------------------------------+
_oView:SetOwnerView( 'VIEW_ZZ1', 'TELA' ) 

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

    ADD OPTION aRotina TITLE "Pesquisa"  		    	ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"          	    ACTION "VIEWDEF.SIGA004" 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Solicita Etiquetas"       ACTION "U_SIGM002" 		        OPERATION 4 ACCESS 0 
    ADD OPTION aRotina TITLE "Gera Digito Etiquetas"    ACTION "U_SIGM003" 		        OPERATION 4 ACCESS 0 

Return aRotina