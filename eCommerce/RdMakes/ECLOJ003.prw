#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} ECLOJ003
	@description Cadastro de Marcas
	@author Bernard M. Margarido
	@since 29/04/2019
	@version undefined
	@type function
/*/
/************************************************************************************/
User Function ECLOJ003()

Private oBrowse	:= Nil

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("AY2")

//-------------------+
// Adiciona Legendas |
//-------------------+
oBrowse:AddLegend("AY2_STATUS == '1' "	,"GREEN"				,"Ativo")
oBrowse:AddLegend("AY2_STATUS == '2' "	,"RED"					,"Inativo")

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Cadastro de Marcas')

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
oStruct := FWFormStruct(1,"AY2")

//----------------------------------+
// Cria o Objeto do Modelo de Dados |
//----------------------------------+
oModel	:= MPFormModel():New("AY2_00",,{|oModel| EcLoj03TOk(oModel) })

//-----------------------------------------------+
// Adiciona ao modelo o componente de formulário |
//-----------------------------------------------+
oModel:AddFields("AY2MASTER",/*cOwner*/,oStruct)

//---------------------+
// Cria Chave Primaria |
//---------------------+
oModel:SetPrimaryKey( {"AY2_FILIAL","AY2_CODIGO"} )

//-----------------------------------------+
// Adiciona a descrição do Modelo de Dados |
//-----------------------------------------+
oModel:SetDescription('Modelo de Dados Cadastro de Marcas')

//-------------------------------------------------------+
// Adiciona a descrição do componente do Modelo de Dados |
//-------------------------------------------------------+
oModel:GetModel('AY2MASTER'):SetDescription('Dados Cadastro de Marcas')

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
oDefModel := FWLoadModel("ECLOJ003") 

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
oDefStruct := FWFormStruct( 2,'AY2') 

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
oDefView:AddField( 'VIEW_AY2', oDefStruct, 'AY2MASTER' ) 

//---------------------------------------------------------------+
// Criar um "box" horizontal para receber algum elemento da view |
//---------------------------------------------------------------+
oDefView:CreateHorizontalBox( 'TELA' , 100 ) 

//------------------------------------------------------------------+
// Relaciona o identificador (ID) da View com o "box" para exibição |
//------------------------------------------------------------------+
oDefView:SetOwnerView( 'VIEW_AY2', 'TELA' ) 

Return( oDefView )

/************************************************************************************/
/*/{Protheus.doc} SyVa08TdOk

@description Valida deleção da marca 

@author Bernard M. Margarido
@since 22/01/2018
@version 1.0

@param oModel, object, descricao
@type function
/*/
/************************************************************************************/
Static Function EcLoj03TOk(oModel)
Local _lRet			:= .T.
Local _lExclui      := IIF(oModel:nOperation == 5,.T.,.F.)
Local _leCommerce   := GetNewPar("EC_USAECO",.T.)

Local _cMsg			:= ""

//---------------------------------------+
// Atualiza flags de envio ao e-Commerce |
//---------------------------------------+
If oModel:nOperation == 4
	RecLock("AY2",.F.)
		AY2->AY2_ENVECO	:= "1"
        AY2->AY2_XDTEXP := ""
        AY2->AY2_XHREXP := ""
	AY2->( MsUnLock() )
EndIf

//---------------+
// Excluir Marca |
//---------------+
If oModel:nOperation == 5

	//-----------------------------------------------+
	// Consulta se marca já foi enviada ao e-Commerce |
	//------------------------------------------------+
	If _leCommerce .And. _lExclui 
		FWMsgRun(, {|| _lExclui := U_AEcoI02C(AY2->AY2_XIDMAR) }, "Aguarde....", "Consultando marca e-Commerce. " )
		_cMsg := IIF(_lExclui,"Marca cadastrada no e-Commerce. Favor inativar marca.","")
	Endif

	//---------------------------------------+
	// Valida se marca amarrada a um produto |
	//---------------------------------------+
	If !_lExclui
        FWMsgRun(, {|| _lExclui := EcLoj03Vld(AY2->AY2_CODIGO) }, "Aguarde....", "Consultando Marca. " )
		_cMsg := IIF(_lExclui,"Marca amarrada a um produto.","")
    EndIf

    If _lExclui
        _lRet := .F.
        MsgAlert("Não é possivel excluir marca. " + _cMsg,"Avisos")
    EndIf
EndIf

Return _lRet

/************************************************************************************/
/*/{Protheus.doc} EcLoj03Vld
@description Valida se marca está amarrada a um produto
@type  Function
@author Bernard M. Margarido
@since 14/05/2019
/*/
/************************************************************************************/
Static Function EcLoj03Vld(_cCodMarca)
Local _aArea	:= GetArea()

Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()

Local _lRet		:= .T.

_cQuery := " SELECT " + CRLF
_cQuery	+= "	PRODUTO " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= " ( " + CRLF
_cQuery	+= "	SELECT " + CRLF
_cQuery	+= "		B5.B5_COD PRODUTO " + CRLF
_cQuery	+= "	FROM " + CRLF
_cQuery	+= "		" + RetSqlName("SB5") + " B5 " + CRLF 
_cQuery	+= "	WHERE " + CRLF
_cQuery	+= "		B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF
_cQuery	+= "		B5.B5_XCODMAR = '" + _cCodMarca + "' AND " + CRLF
_cQuery	+= "		B5.D_E_L_E_T_ = '' " + CRLF
_cQuery	+= "	UNION ALL " + CRLF
_cQuery	+= "	SELECT " + CRLF
_cQuery	+= "		B4.B4_COD PRODUTO " + CRLF
_cQuery	+= "	FROM " + CRLF
_cQuery	+= "		" + RetSqlName("SB4") + " B4 " + CRLF 
_cQuery	+= "	WHERE " + CRLF
_cQuery	+= "		B4.B4_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF
_cQuery	+= "		B4.B4_01CODMA = '" + _cCodMarca + "' AND " + CRLF
_cQuery	+= "		B4.D_E_L_E_T_ = '' " + CRLF
_cQuery	+= ") MARCAXPROD " + CRLF

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
Return FWMVCMenu( "ECLOJ003" )
