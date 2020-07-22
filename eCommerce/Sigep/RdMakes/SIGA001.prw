#INCLUDE "TOTVS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE FF_LAYOUT_VERT_DESCR_TOP 			001 // Vertical com descrição acima do get
#DEFINE FF_LAYOUT_VERT_DESCR_LEFT			002 // Vertical com descrição a esquerda
#DEFINE FF_LAYOUT_HORZ_DESCR_TOP 			003 // Horizontal com descrição acima do get
#DEFINE FF_LAYOUT_HORZ_DESCR_LEFT			004 // Horizontal com descrição a esquerda

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} SIGA001
	@description Monitor SIGEP
	@author Bernard M. Margarido
	@since 03/04/2017
	@version undefined
	@type function
/*/ 
/************************************************************************************/
User Function SIGA001()
	Local _aArea		:= GetArea()
	Local _cFiltro		:= ""
		
	Private _cCadastro 	:= "Monitor SIGEP"
	Private _cAlias		:= "ZZ2"
	Private aRotina 	:= MenuDef()
		
	dbSelectArea(_cAlias)
	(_cAlias)->( dbSetOrder(1) )

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( _cAlias )
	oBrowse:SetDescription( _cCadastro )
		
	oBrowse:AddLegend( "ZZ2_STATUS == '01'", "BR_VERMELHO" 	, "PLP - Gerada" )
	oBrowse:AddLegend( "ZZ2_STATUS == '02'", "BR_AMARELO" 	, "PLP - Etiqueta Reservada" )
	oBrowse:AddLegend( "ZZ2_STATUS == '04'", "BR_VERDE" 	, "PLP - Enviada" )
	oBrowse:AddLegend( "ZZ2_STATUS == '03'", "BR_PRETO" 	, "PLP - Erro de Envio" )
	
	oBrowse:Activate()
	
	RestArea(_aArea)
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
Local _oStruZZ2   	:= FWFormStruct(1 ,"ZZ2" )
Local _oStruZZ4		:= FWFormStruct(1 ,"ZZ4" )

Local _bPosValid	:= {|_oModel| SigaA01TOk(_oModel)	}  
Local _bCommit		:= {|_oModel| SigaA01Grv(_oModel)	}  

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('ZZ2_00', /*bPreValid*/ , _bPosValid , _bCommit , /*_bCancel*/ )
_oModel:SetDescription('Monitor SIGEP.')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('ZZ2MASTER',,_oStruZZ2)

//------------------------------+
// Produto X Campos Especificos |
//------------------------------+
_oModel:AddGrid("ZZ4DETAIL", "ZZ2MASTER" /*cOwner*/, _oStruZZ4 , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/, /*{ |oGrid| LoadCores(oGrid) } bLoad*/)
_oModel:SetRelation( "ZZ4DETAIL" , { { "ZZ4_FILIAL" , 'xFilial("ZZ4")' }, { "ZZ4_CODIGO" , "ZZ2_CODIGO" } } , ZZ4->( IndexKey( 1 ) ) )
_oModel:GetModel("ZZ4DETAIL"):SetOptional(.T.)

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( 'ZZ4DETAIL' ):SetUniqueLine( { "ZZ4_ITEM","ZZ4_CODIGO","ZZ4_NOTA","ZZ4_SERIE" } )

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({ "ZZ2_FILIAL" , "ZZ2_CODIGO" })

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
Local _nOldLen	 	:= SetVarNameLen(255) 
Local _oStrViewZZ2	:= FWFormStruct(2 ,"ZZ2" )
Local _oStrViewZZ4	:= FWFormStruct(2 ,"ZZ4" )

Local _cCSS       	:= "QHeaderView::section { font-family: Arial, Helvetica, sans-serif; font-size: 09px; color: black ; background-image: url(rpo:fw_brw_hdr.png); border: 1px solid #99CCFF; } "+ ;
                       	"QTableView{ rowHeight: 5; font-family: Arial, Helvetica, sans-serif; font-size: 10px; alternate-background-color: LightGray ; color: black }" 

_oModel := FWLoadModel("SIGA001")
_oView	:= FWFormView():New()

_oView:SetModel(_oModel)
_oView:SetDescription('Monitor SIGEP.')

_oView:showUpdateMsg(.F.)
_oView:showInsertMsg(.T.)

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('ZZ2FORM' 	, _oStrViewZZ2 , 'ZZ2MASTER' )
_oView:AddGrid('ZZ4FORM'	, _oStrViewZZ4 , 'ZZ4DETAIL' )

_oView:CreateHorizontalBox( 'SUPERIOR_A1'    		, 030 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INFERIOR_A1'    		, 070 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:CreateVerticalBox( 'ESQ_S1'      ,100 , 'SUPERIOR_A1' )
_oView:CreateVerticalBox( 'MEI_S1'      ,001 , 'SUPERIOR_A1' )

_oView:CreateVerticalBox( 'ESQ_A1'      ,100 , 'INFERIOR_A1' )
_oView:CreateVerticalBox( 'MEI_A1'      ,001 , 'INFERIOR_A1' )

//_oView:EnableTitleView( 'SB5FORM' , 'Cadastrais Produto' )
//_oView:EnableTitleView( 'WS6FORM' , 'Campos Especificos VTEX' )

_oView:SetOwnerView('ZZ2FORM'	,'ESQ_S1')
_oView:SetOwnerView('ZZ4FORM'	,'ESQ_A1')

//----------------------+
// Propriedades Visuais |
//----------------------+
_oView:SetViewProperty( "ZZ2FORM", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 5 } )

_oView:SetViewProperty('ZZ4FORM'    		, 'ENABLENEWGRID' )
_oView:SetViewProperty('ZZ4FORM'    		, "GRIDVSCROLL", {.T.})
_oView:SetViewProperty('ZZ4FORM'    		, "GRIDROWHEIGHT", {20})

//_oView:bAfterViewActivate := { |_oView| EcLoj014Fld(_oView)}

Return _oView

/************************************************************************************/
/*/{Protheus.doc} EcLoj14TOk
	@description Valida dados do complemento de produtos e-Commerce.
	@type  Static Function
	@author Bernard M. Nargarido
	@since 09/08/2019
	@version 1.0
/*/
/************************************************************************************/
Static Function SigaA01TOk(_oModel)
Local _aArea 		:= GetArea()

Local _cMsg			:= ""

Local _nX			:= 0

Local _lRet			:= .T.

RestArea(_aArea)
Return _lRet

/************************************************************************************/
/*/{Protheus.doc} EcLoj14Grv
	@description Realiza a atualização dos campos de flag
	@type  Static Function
	@author Bernard M. Nargarido
	@since 09/08/2019
	@version 1.0
/*/
/************************************************************************************/
Static Function SigaA01Grv(_oModel)

Local _cCodProd		:= ""
Local _cCodCampo	:= ""
Local _cCodCarac	:= ""

Local _nX			:= 0

Return .T.

/***************************************************************************************/
/*/{Protheus.doc} SIGA01A
	@description Função de definição do Menu da Rotina
	@author	Bernard M. Margarido
	@since		18/02/2016
	@version	1.00
/*/
/***************************************************************************************/
User Function SIGA01A()
Local _aArea	:= GetArea()

Local _cPLPAte	:= CriaVar("ZZ2_CODIGO",.F.)
Local _cPLPDe	:= CriaVar("ZZ2_CODIGO",.F.)
Local _nStatus	:= 0

Local _aParam	:= {}
Local _aRetP	:= {}

aAdd( _aParam, {1,"Pre Lista De ?"	, _cPLPDe	, "@!", "", "ZZ2", "", 60, .F.	})
aAdd( _aParam, {1,"Pre Lista Ate?"	, _cPLPAte	, "@!", "", "ZZ2", "", 60, .F.	})
aAdd( _aParam, {3,"Imprimir em ..."	, _nStatus  , {"PDF","Térmica - Zebra"}, 100, , .T.	})

If ParamBox(_aParam,"Informe mode de impressão.",@_aRetP)

	_cPLPDe	 := _aRetP[1]
	_cPLPAte := _aRetP[2]	
	_nStatus := _aRetP[3]
	
	//-----+	
	// PDF |
	//-----+	
	If _nStatus == 1
		U_SIGR001(_cPLPDe,_cPLPAte)
	//-------+
	// Zebra |
	//-------+
	Else
		U_SIGR003(_cPLPDe,_cPLPAte)
	EndIf
EndIf

RestArea(_aArea)
Return .T.

/***************************************************************************************/
/*/{Protheus.doc} MENUDEF
	@description Função de definição do Menu da Rotina
	@author	Bernard M. Margarido
	@since		18/02/2016
	@version	1.00
/*/
/***************************************************************************************/
Static Function MenuDef()     
	Local aRotina	:= {}
										
	ADD OPTION aRotina TITLE "Pesquisa"  			ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"          	ACTION "VIEWDEF.SIGA001" 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Incluir" 	            ACTION "U_SIGM006" 				OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.SIGA001" 		OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.SIGA001" 		OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE "Envia PLP"			ACTION 'U_SIGM004'		  		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Imprime PLP"			ACTION 'U_SIGR002'		  		OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Imprime ETQ"			ACTION 'U_SIGA01A'		  		OPERATION 6 ACCESS 0
		
Return aRotina