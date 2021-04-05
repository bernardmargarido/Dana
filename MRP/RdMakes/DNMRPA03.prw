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
/*/{Protheus.doc} MenuDef
	@description Menu padrao para manutencao do cadastro
	@author Bernard M. Margarido
	@since 10/08/2017
	@version undefined
/*/
/************************************************************************************/
Static Function MenuDef()
Local _aRotina := FwMVCMenu('DNMRPA03')

    ADD OPTION _aRotina Title 'Processar Abastecimento' 		Action 'U_DNMRP01M' 	OPERATION 7 ACCESS 0

Return _aRotina