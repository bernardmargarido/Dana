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
/*/{Protheus.doc} ECLOJ014
	@description Complemento de Produtos e-Commerce
	@author Bernard M. Margarido
	@since 08/08/2019
	@version undefined
	@type function
/*/
/************************************************************************************/
User Function ECLOJ014()
Local _nOldLen	 	:= SetVarNameLen(255)

Private oBrowse		:= Nil

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("SB5")

//-------------------+
// Adiciona Legendas |
//-------------------+
oBrowse:AddLegend( "B5_STATUS == 'A'", "GREEN" , "Ativo" )
oBrowse:AddLegend( "B5_STATUS == 'I'", "RED" , "Inativo" )

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Complemento de Produtos - eCommerce')

oBrowse:SetAttach(.T.)
oBrowse:SetCacheView( .F. )
oBrowse:SetAmbiente(.F.)       
oBrowse:SetWalkThru(.F.)       
oBrowse:DisableDetails()
oBrowse:SetMenuDef("ECLOJ014")

//--------------------+
// Ativação do Browse |
//--------------------+
oBrowse:Activate()

SetVarNameLen(_nOldLen)

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
Local _oStruSB5   	:= FWFormStruct(1 ,"SB5" )
Local _oStruWS6		:= FWFormStruct(1 ,"WS6" )
Local _oStruAY5		:= FWFormStruct(1 ,"AY5" )

Local _bPosValid	:= {|_oModel| EcLoj14TOk(_oModel)	}  
Local _bCommit		:= {|_oModel| EcLoj14Grv(_oModel)	}  

//-----------------+
// Gatilho Produto | 
//-----------------+
_oStruSB5:AddTrigger( 	'B5_COD' 	/*cIdField*/ ,;
					 	'B5_CEME'	/*cTargetIdField*/ ,;  
					 	{ || .T. } /*bPre*/ ,;
					 	{ || Padr( Posicione("SB1",1,xFilial("SB1") + FwFldGet('B5_COD'),'B1_DESC'), TamSx3("B1_DESC")[1] ) } /*bSetValue*/ )

_oStruWS6:AddTrigger( 	'WS6_CODIGO' /*cIdField*/ ,;
					 	'WS6_CAMPO'	/*cTargetIdField*/ ,;  
					 	{ || .T. } /*bPre*/ ,;
					 	{ || Padr( Posicione("WS5",1,xFilial("WS5") + FwFldGet('WS6_CODIGO'),'WS5_CAMPO'), TamSx3("WS6_CAMPO")[1] ) } /*bSetValue*/ )

_oStruAY5:AddTrigger( 	'AY5_CODIGO' /*cIdField*/ ,;
					 	'AY5_DESCRI'/*cTargetIdField*/ ,;  
					 	{ || .T. } /*bPre*/ ,;
					 	{ || Padr( Posicione("AY3",1,xFilial("AY3") + FwFldGet('AY5_CODIGO'),'AY3_DESCRI'), TamSx3("AY5_DESCRI")[1] ) } /*bSetValue*/ )

_oStruAY5:AddTrigger( 	'AY5_SEQ' /*cIdField*/ ,;
					 	'AY5_VALOR'	/*cTargetIdField*/ ,;  
					 	{ || .T. } /*bPre*/ ,;
					 	{ || Padr( Posicione("AY4",1,xFilial("AY4") + FwFldGet('AY5_CODIGO') + FwFldGet('AY5_SEQ'),'AY4_VALOR'), TamSx3("AY5_VALOR")[1] ) } /*bSetValue*/ )

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('SB5_00', /*bPreValid*/ , _bPosValid , _bCommit , /*_bCancel*/ )
_oModel:SetDescription('Complemento de Produtos e-Commerce.')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('SB5MASTER',,_oStruSB5)

//------------------------------+
// Produto X Campos Especificos |
//------------------------------+
_oModel:AddGrid("WS6DETAIL", "SB5MASTER" /*cOwner*/, _oStruWS6 , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/, /*{ |oGrid| LoadCores(oGrid) } bLoad*/)
_oModel:SetRelation( "WS6DETAIL" , { { "WS6_FILIAL" , 'xFilial("WS6")' }, { "WS6_CODPRD" , "B5_COD" } } , WS6->( IndexKey( 1 ) ) )
_oModel:GetModel("WS6DETAIL"):SetOptional(.T.)

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( 'WS6DETAIL' ):SetUniqueLine( { 'WS6_CODIGO' } )

//------------------+
// Prduto X Filtros |
//------------------+
_oModel:AddGrid("AY5DETAIL", "SB5MASTER" /*cOwner*/, _oStruAY5 , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/, /*{ |oGrid| LoadCores(oGrid) } bLoad*/)
_oModel:SetRelation( "AY5DETAIL" , { { "AY5_FILIAL" , 'xFilial("AY5")' }, { "AY5_CODPRO" , "B5_COD" } } , AY5->( IndexKey( 1 ) ) )
_oModel:GetModel("AY5DETAIL"):SetOptional(.T.)

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( 'AY5DETAIL' ):SetUniqueLine( { 'AY5_CODIGO','AY5_SEQ','AY5_CODPRO' } )

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({ "B5_FILIAL" , "B5_COD" })

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
Local _oStrViewSB5	:= FWFormStruct(2 ,"SB5" )
Local _oStrViewWS6	:= FWFormStruct(2 ,"WS6" )
Local _oStrViewAY5	:= FWFormStruct(2 ,"AY5" )

Local _cCSS       	:= "QHeaderView::section { font-family: Arial, Helvetica, sans-serif; font-size: 09px; color: black ; background-image: url(rpo:fw_brw_hdr.png); border: 1px solid #99CCFF; } "+ ;
                       	"QTableView{ rowHeight: 5; font-family: Arial, Helvetica, sans-serif; font-size: 10px; alternate-background-color: LightGray ; color: black }" 

_oModel := FWLoadModel("ECLOJ014")
_oView	:= FWFormView():New()

_oView:SetModel(_oModel)
_oView:SetDescription('Complemento de Produtos e-Commerce.')

_oView:showUpdateMsg(.F.)
_oView:showInsertMsg(.T.)

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('SB5FORM' 	, _oStrViewSB5 , 'SB5MASTER' )
_oView:AddGrid('WS6FORM'	, _oStrViewWS6 , 'WS6DETAIL' )
_oView:AddGrid('AY5FORM'	, _oStrViewAY5 , 'AY5DETAIL' )

_oView:CreateHorizontalBox( 'SUPERIOR_A1'    		, 060 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INFERIOR_A1'    		, 040 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:CreateVerticalBox( 'ESQ_S1'      ,100 , 'SUPERIOR_A1' )
_oView:CreateVerticalBox( 'MEI_S1'      ,001 , 'SUPERIOR_A1' )

_oView:CreateVerticalBox( 'ESQ_A1'      ,100 , 'INFERIOR_A1' )
_oView:CreateVerticalBox( 'MEI_A1'      ,001 , 'INFERIOR_A1' )

//_oView:EnableTitleView( 'SB5FORM' , 'Cadastrais Produto' )
//_oView:EnableTitleView( 'WS6FORM' , 'Campos Especificos VTEX' )

//-------------+
// Cria pastas | 
//-------------+ 
_oView:CreateFolder('FOLDER','INFERIOR_A1')
_oView:AddSheet( 'FOLDER', 'FOLDER_01', 'Campos Especificos VTEX' )
_oView:AddSheet( 'FOLDER', 'FOLDER_02', 'Filtros VTEX' )

_oView:CreateVerticalBox( 'INF_ESQ', 100,,, 'FOLDER', 'FOLDER_01')
_oView:CreateVerticalBox( 'INF_DIR', 100,,, 'FOLDER', 'FOLDER_02')

_oView:SetOwnerView('SB5FORM'	,'ESQ_S1')
_oView:SetOwnerView('WS6FORM'	,'INF_ESQ')
_oView:SetOwnerView('AY5FORM'	,'INF_DIR')

//----------------------+
// Propriedades Visuais |
//----------------------+
_oView:SetViewProperty( "SB5FORM", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 5 } )

_oView:SetViewProperty('WS6FORM'    		, 'ENABLENEWGRID' )
_oView:SetViewProperty('WS6FORM'    		, "GRIDVSCROLL", {.T.})
_oView:SetViewProperty('WS6FORM'    		, "GRIDROWHEIGHT", {20})

_oView:SetViewProperty('AY5FORM'    		, 'ENABLENEWGRID' )
_oView:SetViewProperty('AY5FORM'    		, "GRIDVSCROLL", {.T.})
_oView:SetViewProperty('AY5FORM'    		, "GRIDROWHEIGHT", {20})

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
Static Function EcLoj14TOk(_oModel)
Local _aArea 		:= GetArea()

Local _cMsg			:= ""

Local _nX			:= 0

Local _lRet			:= .T.

Local _oModelWs6	:= _oModel:GetModel("WS6DETAIL")
Local _oModelAy5	:= _oModel:GetModel("AY5DETAIL")

//--------+
// Inclui |
//--------+
If _oModel:nOperation == 3  .Or. _oModel:nOperation == 4
	//------------------------------------------------------------+
	// Valida se campos obrigatorios e-Commerce foram preenchidos |
	//------------------------------------------------------------+
	If Empty(M->B5_XNOMPRD)
		_cMsg := " Campo " + RetTitle("B5_XNOMPRD")+ " obrigatorio e-Commerce nao preenchido."
	ElseIf Empty(M->B5_XTITULO)
		_cMsg := " Campo " + RetTitle("B5_XTITULO")+ " obrigatorio e-Commerce nao preenchido."
	ElseIf Empty(M->B5_XCODMAR)
		_cMsg := " Campo " + RetTitle("B5_XCODMAR")+ " obrigatorio e-Commerce nao preenchido."
	ElseIf Empty(M->B5_XCAT01) 
		_cMsg := " Campo " + RetTitle("B5_XCAT01")+ " obrigatorio e-Commerce nao preenchido."
	EndIf

//---------+
// Excluir | 
//---------+
ElseIf _oModel:nOperation == 5
	If SB5->B5_XENVECO == "2" .Or. !Empty(SB5->B5_XDTEXP) .Or. !Empty(SB5->B5_XHREXP)  
		_cMsg := " Não é possivel excluir complemento de produto para produtos já enviados ao e-Commerce."
	EndIf
Endif

If !Empty(_cMsg)
	_lRet	:= .F.
	 Help( ,, 'HELP',, _cMsg, 1, 0)
EndIf

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
Static Function EcLoj14Grv(_oModel)

Local _cCodProd		:= ""
Local _cCodCampo	:= ""
Local _cCodCarac	:= ""

Local _nX			:= 0

Local _oModelSB5	:= _oModel:GetModel("SB5MASTER")
Local _oModelWs6	:= _oModel:GetModel("WS6DETAIL")
Local _oModelAy5	:= _oModel:GetModel("AY5DETAIL")

Local _aSaveLines	:= FWSaveRows()

//----------------------------------------+
// Realiza a gravação dos dados do Objeto |
//----------------------------------------+
FwFormCommit(_oModel)

//-------------------------------------+
// Atualiza Flag para envio e-Commerce |
//-------------------------------------+
RecLock("SB5",.F.)
	SB5->B5_XENVECO := "1"
	SB5->B5_XENVCAT	:= "1"
	SB5->B5_XENVSKU	:= "1"
SB5->( MsUnLock() )

//----------------------+
// Campos para gravação |
//----------------------+
_cCodProd := _oModelSB5:GetValue("B5_COD")

//--------------------------+
// Atualiza flag para envio |
//--------------------------+
dbSelectArea("WS6")
WS6->( dbSetOrder(1) )
If WS6->( dbSeek(xFilial("WS6") + _cCodProd) )
	While WS6->( !Eof() .And. xFilial("WS6") + RTrim(_cCodProd) == WS6->WS6_FILIAL + RTrim(WS6->WS6_CODPRD) )
		RecLock("WS6",.F.)
			WS6->WS6_ENVECO := "1"
		WS6->( MsUnLock() )
		WS6->( dbSkip() )
	EndDo
EndIf	


//---------------+
// Valida Filtro |
//---------------+
dbSelectArea("AY5")
AY5->( dbSetOrder(2) )
If AY5->( dbSeek(xFilial("AY5") + _cCodProd) )
	While AY5->( !Eof() .And. xFilial("AY5") + _cCodProd == AY5->AY5_FILIAL + AY5->AY5_CODPRO)
		RecLock("AY5",.F.)
			AY5->AY5_ENVECO := "1"
		AY5->( MsUnLock() )
		AY5->( dbSkip() )
	EndDo
EndIf

FWRestRows(_aSaveLines) 

Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj014Fld
	@description Rotina desativa pastas SXA
	@author Bernard M. Margarido
	@since 10/08/2017
	@version undefined
	@type function
/*/
/************************************************************************************/
Static Function EcLoj014Fld(_oView)

	//-------------------+
	// Remove os folders |
	//-------------------+
	//_oView:HideFolder("SB5FORM", 1 , 1)
	//_oView:HideFolder("SB5FORM", 2 , 1)
	//_oView:HideFolder("SB5FORM", 3 , 1)
	//_oView:HideFolder("SB5FORM", 4 , 1)
	//_oView:HideFolder("SB5FORM", 5 , 1)
	//_oView:HideFolder("SB5FORM", 6 , 1)
	//_oView:HideFolder("SB5FORM", 7 , 1)
	//_oView:HideFolder("SB5FORM", 8 , 1)
	//_oView:HideFolder("SB5FORM", 9 , 1)
	//_oView:HideFolder("SB5FORM", 10, 1)
	//_oView:HideFolder("SB5FORM", 11, 1)

Return 

/************************************************************************************/
/*/{Protheus.doc} MenuDef
	@description Menu 
	@author Bernard M. Margarido
	@since 10/08/2017
	@version undefined
	@type function
/*/
/************************************************************************************/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"            	ACTION "PesqBrw"            		OPERATION 1 ACCESS 0  
ADD OPTION aRotina TITLE "Visualizar"           	ACTION "VIEWDEF.ECLOJ014" 			OPERATION 2 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"              	ACTION "VIEWDEF.ECLOJ014" 			OPERATION 3 ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"              	ACTION "VIEWDEF.ECLOJ014" 			OPERATION 4 ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"              	ACTION "VIEWDEF.ECLOJ014" 			OPERATION 5 ACCESS 0 
ADD OPTION aRotina TITLE "Imp. Planilha"           	ACTION "U_ECLJM002"		 			OPERATION 3 ACCESS 0 
ADD OPTION aRotina TITLE "Ajusta ID eComm"         	ACTION "U_ECLOJ019"		 			OPERATION 6 ACCESS 0 

Return ( aRotina )
