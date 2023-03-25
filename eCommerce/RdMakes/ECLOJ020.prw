#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/******************************************************************************/
/*/{Protheus.doc} ECLOJ020
    @description Monitor impressao de notas fiscais eCommerce
    @type  Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/******************************************************************************/
User Function ECLOJ020()
Local _nTime        := GetMv("DN_TMEXPEC",,10)

Private _oBrowse    := Nil 

//--------------------------------------+
// Cria botão de atalho para parametros |
//--------------------------------------+
SetKey( VK_F12, { || Pergunte("ECLOJ12",.T.) } )
Pergunte("ECLOJ12",.F.)

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()

//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("XTE")

//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "XTE_STATUS == '1'", "GREEN" , "Aguardando Transmissao")
_oBrowse:AddLegend( "XTE_STATUS == '2'", "RED"   , "Transmitido com sucesso")
_oBrowse:AddLegend( "XTE_STATUS == '3'", "ORANGE", "PDF Impresso")
_oBrowse:AddLegend( "XTE_STATUS == '4'", "BLACK" , "Erro")

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Monitor - Expedição eCommerce')
_oBrowse:SetTimer({|| RefreshBrw(_oBrowse) }, IIF(_nTime<=0, 3600, ( _nTime * 60 ) ) * 1000)
_oBrowse:SetMenuDef("ECLOJ020")

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
Local _oStruXTE     := Nil

//-----------------+
// Monta Estrutura |
//-----------------+
_oStruXTE   := FWFormStruct(1,"XTE")

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('ECLOJ20_01', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('MASTER',,_oStruXTE)

_oModel:SetDescription('Monitor - Expedição eCommerce')
_oModel:GetModel('MASTER'):SetDescription("Monitor - Expedição eCommerce")

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({"XTE_FILIAL","XTE_DOC","XTE_SERIE"})

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
Local _oStrViewXTE	:= Nil

Local _nOldLen      := SetVarNameLen(255) 

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("ECLOJ020")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewXTE	:= FWFormStruct( 2,'XTE') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('Monitor - Expedição eCommerce')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XTE_FORM' 	, _oStrViewXTE , 'MASTER' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 100 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:SetOwnerView('XTE_FORM'	    ,'SUP_01')

SetVarNameLen(_nOldLen)

Return _oView 

/************************************************************************************/
/*/{Protheus.doc} ECLOJ20A
    @description Impressão de Danfe e PLP via leitor 
    @type  Function
    @author Bernard M Margarido
    @since 22/03/2023
/*/
/************************************************************************************/
User Function ECLOJ20A()
Local _cCodEtq  := Space(6)

Local _oSay     := Nil 

While !Empty( _cCodEtq := FwInputBox("Informa o codigo da etiqueta ?", _cCodEtq) )

    If !Empty(_cCodEtq)
        FwMsgRun(,{|_oSay| U_EcLojM10(_oSay,_cCodEtq)},"Aguarde...","Gerando Etiquetas.")
    EndIf 

EndDo 
Return Nil 

/************************************************************************************/
/*/{Protheus.doc} RefreshBrw
    @description Realiza a atualização da tela de expedição eCommerce
    @type  Static Function
    @author Bernard M Margarido
    @since 22/03/2023
    @version version
/*/
/************************************************************************************/
Static Function RefreshBrw(_oBrowse)
    _oBrowse:Refresh(.T.)
    _oBrowse:GoBottom()
Return .T.

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
    ADD OPTION _aRotina TITLE "Visualizar"           	ACTION "VIEWDEF.ECLOJ020" 			OPERATION 2 ACCESS 0 
    ADD OPTION _aRotina TITLE "Impressao Nota"         	ACTION "U_ECLOJ20A"      			OPERATION 6 ACCESS 0 
Return _aRotina
