#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*********************************************************************************/
/*/{Protheus.doc} ECLOJ001
    @description Cadastro de Categorias
    @author Bernard M. Margarido    
    @since 23/04/2019
    @version 1.0
    @type function
/*/
/*********************************************************************************/
User Function ECLOJ001()
Local aArea		:= GetArea() 

Local _cFiltro	:= "AY0->AY0_CODIGO <> '000' "

Private oBrowse	:= Nil

//--------------------------------+
// Tecla de atalho para estrutura |
//--------------------------------+
SetKey( VK_F5, { || U_ECLOJ002() } )

//+----------------------------------------+
//| Verifica se existe a categoria inicial |
//+----------------------------------------+
U_ECLOJ01A()

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("AY0")

//-------------------+
// Adiciona Legendas |
//-------------------+
oBrowse:AddLegend("AY0_STATUS == '1' "	,"GREEN"				,"Ativo")
oBrowse:AddLegend("AY0_STATUS == '2' "	,"RED"					,"Inativo")

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Cadastro de Categorias')

//-------------------+
// Filtro da browser |
//-------------------+
oBrowse:SetFilterDefault( _cFiltro )

//--------------------+
// Ativação do Browse |
//--------------------+
oBrowse:Activate()

//------------------------+
// Reseta tecla de atalho |
//------------------------+
SetKey( VK_F5, { || } )

RestArea(aArea)
Return Nil 

/************************************************************************************/
/*/{Protheus.doc} ModelDef

@description  Modelo de dados, estrutura dos dados e modelo de negocio

@author Bernard M. Margarido

@since 22/04/2019
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
oStruct := FWFormStruct(1,"AY0")

//----------------------------------+
// Cria o Objeto do Modelo de Dados |
//----------------------------------+
oModel	:= MPFormModel():New("AY0_00",,{|oModel| EcLoj01TOk(oModel)})

//----------------------------+
// Tratamento para Campo Memo |
//----------------------------+
FWMemoVirtual( oStruct,{ { 'AY0_CODDES' , 'AY0_DESCEC' } } )

//-----------------------------------------------+
// Adiciona ao modelo o componente de formulário |
//-----------------------------------------------+
oModel:AddFields("AY0MASTER",/*cOwner*/,oStruct)

//---------------------+
// Cria Chave Primaria |
//---------------------+
oModel:SetPrimaryKey( {"AY0_FILIAL","AY0_CODIGO"} )

//-----------------------------------------+
// Adiciona a descrição do Modelo de Dados |
//-----------------------------------------+
oModel:SetDescription('Modelo de Dados Cadastro de Categorias')

//-------------------------------------------------------+
// Adiciona a descrição do componente do Modelo de Dados |
//-------------------------------------------------------+
oModel:GetModel('AY0MASTER'):SetDescription('Dados Cadastro de Categorias')

Return(oModel)

/************************************************************************************/
/*/{Protheus.doc} ViewDef

@description Cria interface com o usuario

@author Bernard M. Margarido

@since 22/04/2019
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
oDefModel := FWLoadModel("ECLOJ001") 

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
oDefStruct := FWFormStruct( 2,'AY0') 

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
oDefView:AddField( 'VIEW_AY0', oDefStruct, 'AY0MASTER' ) 

//---------------------------------------------------------------+
// Criar um "box" horizontal para receber algum elemento da view |
//---------------------------------------------------------------+
oDefView:CreateHorizontalBox( 'TELA' , 100 ) 

//------------------------------------------------------------------+
// Relaciona o identificador (ID) da View com o "box" para exibição |
//------------------------------------------------------------------+
oDefView:SetOwnerView( 'VIEW_AY0', 'TELA' ) 

Return( oDefView )

/************************************************************************************/
/*/{Protheus.doc} EcLoj01TOk

@description Valida dados cadastrados

@author Bernard M. Margarido

@since 22/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj01TOk(oModel)
Local _aArea        := GetArea()

Local _cMsg         := ""

Local _lExclui      := IIF(oModel:nOperation == 5,.T.,.F.)
Local _leCommerce   := GetNewPar("EC_USAECO",.T.)
Local _lRet         := .T.

//---------------------------------------+
// Atualiza flags de envio ao e-Commerce |
//---------------------------------------+
If oModel:nOperation == 4 
    RecLock("AY0",.F.)
        AY0->AY0_ENVECO := "1"
        AY0->AY0_XDTEXP := ""
        AY0->AY0_XHREXP := ""
    AY0->( MsUnLock() )
EndIf

//----------+
// Exclusão |
//----------+
If oModel:nOperation == 5
    //----------------------------------------------------+
    // Consulta se categoria já foi enviada ao e-Commerce |
    //----------------------------------------------------+
    If _leCommerce .And. _lExclui 
        FWMsgRun(, {|| _lExclui := U_AEcoI01C(AY0->AY0_XIDCAT) }, "Aguarde....", "Consultando categoria e-Commerce. " )
        _cMsg := IIF(_lExclui,"Categoria cadastrada no e-Commerce. Favor inativar categoria.","")
    Endif

    //----------------------------------------------+
    // Valida se categoria pertence a uma estrutura |
    //----------------------------------------------+
    If !_lExclui
        FWMsgRun(, {|| _lExclui := EcLoj01Vld(AY0->AY0_CODIGO,AY0->AY0_TIPO) }, "Aguarde....", "Consultando categoria. " )
        _cMsg := IIF(_lExclui,"Categoria pertence a uma estrutura. Favor excluir categoria da estrutura.","")
    EndIf

    If _lExclui
        _lRet := .F.
        MsgAlert("Não é possivel excluir categoria. " + _cMsg,"Avisos")
    EndIf

EndIf

RestArea(_aArea)
Return _lRet

/************************************************************************************/
/*/{Protheus.doc} EcLoj01Vld

@description Valida se categoria pertence a uma estrutura

@type  Function

@author Bernard M. Margarido
@since 14/05/2019
/*/
/************************************************************************************/
Static Function EcLoj01Vld(_cCodigo,_cTipo)
Local _aArea := GetArea()
Local _lRet  := .F.

//---------------------+
// Posiciona Estrutura |
//---------------------+
dbSelectArea("AY1")
If _cTipo == "1"
    AY1->( dbSetOrder(1) )
Else
    AY1->( dbSetOrder(2) )
EndIf

//----------------------------------------------+
// Valida se categoria pertence a uma estrutura |
//----------------------------------------------+
If AY1->( dbSeek(xFilial("AY1") + _cCodigo) )
    _lRet := .T.
EndIf

RestArea(_aArea)
Return _lRet 
/************************************************************************************/
/*/{Protheus.doc} MenuDef

@description Menu padrao para manutencao do cadastro

@author Bernard M. Margarido

@since 22/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
Static Function MenuDef()

Local aRotina   := {}

aRotina := FwMVCMenu('ECLOJ001')

aAdd(aRotina,{"Estrutura","U_ECLOJ002",0 , 4})

Return aRotina
