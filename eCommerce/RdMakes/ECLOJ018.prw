#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/******************************************************************************/
/*/{Protheus.doc} ECLOJ018
    @description Amarração Transportadoras ERP X eCommerce
    @type  Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/******************************************************************************/
User Function ECLOJ018()
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()
//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("ZZ7")

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Transportadoras ERP x eCommerce')
_oBrowse:SetMenuDef("ECLOJ018")

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
Local _oModel		:= Nil
Local _oStruZZ7     := Nil

//-----------------+
// Monta Estrutura |
//-----------------+
_oStruZZ7   := FWFormStruct(1,"ZZ7")

//--------------------+
// Gatillho campo CGC |
//--------------------+
_oStruZZ7:AddTrigger( 	'ZZ7_TRANSP' 	/*cIdField*/ ,;
                        'ZZ7_NOME'	/*cTargetIdField*/ ,;  
                        { || .T. } /*bPre*/ ,;
                        { || PadR( Posicione("SA4", 1, xFilial("SA4") + FwFldGet('ZZ7_TRANSP'), "A4_NOME"), TamSx3("A4_NOME")[1]) } /*bSetValue*/ )

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('ECLOJ18_01', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('MASTER',,_oStruZZ7)

_oModel:SetDescription('Transportadoras ERP X eCommerce')
_oModel:GetModel( 'MASTER' ):SetDescription(  "Transportadoras ERP X eCommerce"  )

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({"ZZ7_FILIAL","ZZ7_TRANSP","ZZ7_IDECOM"})

_oModel:SetActivate()

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
Local _oStrViewZZ7	:= Nil

Local _nOldLen      := SetVarNameLen(255) 

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("ECLOJ018")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewZZ7	:= FWFormStruct( 2,'ZZ7') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('Transportadoras ERP X eCommerce')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('ZZ7_FORM' 	, _oStrViewZZ7 , 'MASTER' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 100 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:SetOwnerView('ZZ7_FORM'	    ,'SUP_01')

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
Return FwMVCMenu('ECLOJ018')
