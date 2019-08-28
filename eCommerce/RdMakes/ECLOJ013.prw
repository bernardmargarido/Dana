#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} ECLOJ013

@description Campos especificos eCommerce

@author Bernard M. Margarido

@since 29/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
User Function ECLOJ013()

Private oBrowse	:= Nil

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("WS5")

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Campos Especificos e-Commerce.')

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
oStruct := FWFormStruct(1,"WS5")

//----------------------------------+
// Cria o Objeto do Modelo de Dados |
//----------------------------------+
oModel	:= MPFormModel():New("WS5_00",,{|oModel| EcLoj13TOk(oModel) })

//-----------------------------------------------+
// Adiciona ao modelo o componente de formulário |
//-----------------------------------------------+
oModel:AddFields("WS5MASTER",/*cOwner*/,oStruct)

//---------------------+
// Cria Chave Primaria |
//---------------------+
oModel:SetPrimaryKey( {"WS5_FILIAL","WS5_CODIGO"} )

//-----------------------------------------+
// Adiciona a descrição do Modelo de Dados |
//-----------------------------------------+
oModel:SetDescription('Modelo de Dados Campos Especificos eCommerce')

//-------------------------------------------------------+
// Adiciona a descrição do componente do Modelo de Dados |
//-------------------------------------------------------+
oModel:GetModel('WS5MASTER'):SetDescription('Campos Especificos eCommerce')

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
oDefModel := FWLoadModel("ECLOJ013") 

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
oDefStruct := FWFormStruct( 2,'WS5') 

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
oDefView:AddField( 'VIEW_WS5', oDefStruct, 'WS5MASTER' ) 

//---------------------------------------------------------------+
// Criar um "box" horizontal para receber algum elemento da view |
//---------------------------------------------------------------+
oDefView:CreateHorizontalBox( 'TELA' , 100 ) 

//------------------------------------------------------------------+
// Relaciona o identificador (ID) da View com o "box" para exibição |
//------------------------------------------------------------------+
oDefView:SetOwnerView( 'VIEW_WS5', 'TELA' ) 

Return( oDefView )

/************************************************************************************/
/*/{Protheus.doc} EcLoj13TOk

@description Valida deleção da marca 

@author Bernard M. Margarido
@since 22/01/2018
@version 1.0

@param oModel, object, descricao
@type function
/*/
/************************************************************************************/
Static Function EcLoj13TOk(oModel)
Local _lRet			:= .T.
Local _lExclui      := .F.

Local _cMsg			:= ""

//---------------+
// Excluir Marca |
//---------------+
If oModel:nOperation == 4 .Or. oModel:nOperation == 5

	//---------------------------------------+
	// Valida se marca amarrada a um produto |
	//---------------------------------------+
    FWMsgRun(, {|| _lExclui := EcLoj13Vld(WS5->WS5_CODIGO) }, "Aguarde....", "Validando se registro pode ser excluido." )
	_cMsg := IIF(_lExclui,"Campo especifico já amarrado a produtos e-Commerce.","")

    If _lExclui
        Help( ,, 'HELP',, "Não é possivel " + IIF(oModel:nOperation == 4,"alterar","excluir") + " registro. " + _cMsg, 1, 0)
        _lRet := .F.
    EndIf
    
EndIf

Return _lRet

/************************************************************************************/
/*/{Protheus.doc} EcLoj13Vld
@description Valida se campo especifico pode ser excluido
@type  Function
@author Bernard M. Margarido
@since 14/05/2019
/*/
/************************************************************************************/
Static Function EcLoj13Vld(_cCampo)
Local _aArea	:= GetArea()

Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()

Local _lRet		:= .T.

_cQuery	:= " SELECT " + CRLF
_cQuery	+= "	WS6.WS6_CODIGO PRODUTO " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= "	" + RetSqlName("WS6") + " WS6 " + CRLF 
_cQuery	+= " WHERE " + CRLF
_cQuery	+= "	WS6.WS6_FILIAL = '" + xFilial("WS6") + "' AND " + CRLF
_cQuery	+= "	WS6.WS6_CODIGO = '" + _cCampo + "' AND " + CRLF
_cQuery	+= "	WS6.D_E_L_E_T_ = '' " + CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If Empty((_cAlias)->PRODUTO)
    _lRet := .F.
EndIf

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return _lRet

/************************************************************************************/
/*/{Protheus.doc} MenuDef

@description Menu padrao para manutencao do cadastro

@author Bernard M. Margarido

@since 10/08/2017
@version undefined
/*/
/************************************************************************************/
Static Function MenuDef()
Return FWMVCMenu( "ECLOJ013" )