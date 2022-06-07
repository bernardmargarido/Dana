#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

/******************************************************************************/
/*/{Protheus.doc} MDLOGA01
    @description DLog - Postagem MDLog
    @type  Function
    @author Bernard M. Margarido
    @since 07/06/2022
/*/
/******************************************************************************/
User Function MDLOGA01()
Local _cFilter   := ""

Private _nOldLen := SetVarNameLen(255) 
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()
//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("ZZB")
//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "ZZB_STATUS == '1'", "RED"      , "Lista Gerada" )
_oBrowse:AddLegend( "ZZB_STATUS == '2'", "GREEN"    , "Lista Enviada" )
_oBrowse:AddLegend( "ZZB_STATUS == '3'", "BLACK"    , "Erro ao Enviar Lista" )

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('MDLOG - Monitor')

_cFilter := "ZZB_DATA > 20220215"
_oBrowse:setFilterDefault(_cFilter)

//--------------------+
// Ativação do Browse |
//--------------------+
_oBrowse:Activate()
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
Local _oStruZZB     := Nil
Local _oStruZZC		:= Nil

//Local _bCommit      := {|_oModel| DLogA01Com(_oModel)}

//-----------------+
// Monta Estrutura |
//-----------------+
_oStruZZB   := FWFormStruct(1,"ZZB")
_oStruZZC	:= FWFormStruct(1,"ZZC")

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('DLOGA_01', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
_oModel:SetDescription('MDLOG - Monitor')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('ZZB_01',,_oStruZZB)

//--------------------------+
// Chave primaria cabeçalho | 
//--------------------------+
_oModel:SetPrimaryKey({"ZZB_FILIAL","ZZB_CODIGO"})

//----------------------------+
// Cabeçalho X Notas Postagem |
//----------------------------+
_oModel:AddGrid("ZZC_01", "ZZB_01" /*cOwner*/, _oStruZZC , /*_bLiOk */ , /*_bPosOk*/ , /*_bPre*/ , /*_bPost*/, /*_bColor*/)
_oModel:SetRelation( "ZZC_01" , { { "ZZC_FILIAL" , 'xFilial("ZZC")' }, { "ZZC_CODIGO" , "ZZB_CODIGO" } } , ZZC->( IndexKey( 1 ) ) )

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( "ZZC_01" ):SetUniqueLine( {"ZZC_FILIAL","ZZC_CODIGO","ZZC_NOTA","ZZC_SERIE"} )

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
Local _oStrViewZZB	:= Nil
Local _oStrViewZZC  := Nil

Local _nOldLen      := SetVarNameLen(255) 

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("MDLOGA01")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewZZB	:= FWFormStruct( 2,'ZZB') 
_oStrViewZZC    := FWFormStruct( 2,'ZZC') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('MDLOG - Monitor')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('ZZB_FORM' 	, _oStrViewZZB , 'ZZB_01' )
_oView:AddGrid('ZZC_GRID'	, _oStrViewZZC , 'ZZC_01' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 050 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'MEI_01' , 005 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INF_01' , 045 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

//_oView:CreateVerticalBox( 'ESQ_S1'   ,047 , 'INF_01' )
//_oView:CreateVerticalBox( 'MEI_S1'   ,006 , 'INF_01' )
//_oView:CreateVerticalBox( 'DIR_S1'   ,047 , 'INF_01' )
_oView:CreateVerticalBox( 'ESQ_S1'   ,100 , 'INF_01' )

//--------------+
// Panel Botoes | 
//--------------+
_oView:AddUserButton( 'Atualiza Coleta', 'CLIPS', {|_oView| FwMsgRun(,{|_oView| MDLogA01A(_oView),"Aguarde...","Validando coleta..."})} )

//--------------------------------+
// Ajusta paineis nas coordenadas |
//--------------------------------+
_oView:SetOwnerView('ZZB_FORM'	    ,'SUP_01')
_oView:SetOwnerView('ZZC_GRID'	    ,'ESQ_S1')
//_oView:SetOwnerView('XT3_GRID'	    ,'DIR_S1')
//_oView:SetOwnerView('VIEW_BTN'	    ,'MEI_S1')

//------------------------+
// Titulo componente GRID |
//------------------------+
_oView:EnableTitleView('ZZB_FORM','Dados Coleta')
_oView:EnableTitleView('ZZC_GRID','Notas Coleta')

//-------------------+
// Adicionando botão | 
//-------------------+
//_oView:AddUserButton( 'Visualiza NF-e', 'CLIPS', {|_oView| U_BSFATA07() } )

Return _oView 

/***************************************************************************************/
/*/{Protheus.doc} MDLogA01A
	@description Atualiza dados do romaneio 
	@type  Static Function
	@author Bernard M. Margarido
	@since 07/06/2022
/*/
/***************************************************************************************/
Static Function MDLogA01A(_oView)
Local _aArea		:= GetArea()
Local _aSaveRows	:= FWSaveRows()

Local _nX			:= 0

Local _cNumEco		:= ""
Local _cMemo		:= ""
Local _cDoc			:= ""
Local _cSerie		:= ""

Local _lStaOk		:= .F.

Local _oModel 		:= FwModelActive()
Local _oModel_ZZB	:= _oModel:GetModel( 'ZZB_01' )
Local _oModel_ZZC   := _oModel:GetModel( 'ZZC_01' )

//-----------------------+
// Posiciona Nota Fiscal |
//-----------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

For _nX := 1 To _oModel_ZZC:Length()

	//----------------------+
	// Posiciona linha Grid |
	//----------------------+
	_oModel_ZZC:GoLine(_nX)

	//-------------------------+
	// Somente itens com erros |
	//-------------------------+
	If FwFldGet("ZZC_STATUS") == "3"
		_cNumEco	:= FwFldGet("ZZC_NUMECO")
		_cMemo		:= FwFldGet("ZZC_JSON")
		_cDoc		:= FwFldGet("ZZC_NOTA")
		_cSerie		:= FwFldGet("ZZC_SERIE")

		//-----------------------+
		// Posiciona Nota Fiscal |
		//-----------------------+
		If SF2->( dbSeek(xFilial("SF2") + _cDoc + _cSerie) )
			If !Empty(SF2->F2_CHVNFE)
				If MDLogA01B(_cNumEco,SF2->F2_CHVNFE,@_cMemo)
					_lStaOk	:= .T.
					FwFldPut("ZZC_JSON", _cMemo)		
					FwFldPut("ZZC_STATUS", "2")		
				EndIf
			EndIf
		EndIf
	EndIf

Next _nX 

//---------------------------+
// Atualiza status cabeçalho |
//---------------------------+
If _lStaOk
	FwFldPut("ZZB_STATUS", "2")
EndIf

_oView:Refresh()

FwRestRows(_aSaveRows)
RestArea(_aArea)
Return _oView

/***************************************************************************************/
/*/{Protheus.doc} MDLogA01B
	@description Consulta Chave NF-E na DLOG
	@type  Static Function
	@author Bernard M. Margarido
	@since 07/06/2022
/*/
/***************************************************************************************/
Static Function MDLogA01B(_cNumEco,_cChaveNfe,_cMemo)
Local _cJSon	:= ""
Local _cLink	:= ""
Local _cCodSta	:= ""
Local _cDescSta	:= ""

Local _nY		:= 0

Local _lRet 	:= .F.

Local _oJSon	:= Nil 
Local _oStatus	:= Nil 
Local _oRetSta	:= Nil 
Local _oMemo	:= Nil 
Local _oDLog	:= DLog():New()

//----------------------------+
// Posiciona Pedido eCommerce |
//----------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )

_oJSon						:= Nil 
_oJSon						:= Array(#)
_oJSon[#"recStatus"]	    := {}
aAdd(_oJSon[#"recStatus"],Array(#))
_oStatus := aTail(_oJSon[#"recStatus"])	
_oStatus[#"nfChave"]	     := _cChaveNfe   
_oStatus[#"allStatusTrack"]  := .T.

//--------------------------+
// Envia Postagem para DLog |
//--------------------------+
_cJSon  := EncodeUTF8(xToJson(_oJSon))

_oDLog:cJSon 	:= _cJSon 
If _oDLog:StatusLista()
	If ValType(_oDLog:oJSon) <> "U"
		_oRetSta := _oDLog:oJSon[#"response"][#"responseStatus"]

		If ValType(_oRetSta) == "A"
			For _nY := 1 To Len(_oRetSta)
				If _oRetSta[_nY][#"codSubStatus"] == 1
					//------------------------+	
					// Salva dados retornados |
					//------------------------+	
					_cLink 		:= _oRetSta[_nY][#"linkRastreamento"]
					_cCodSta	:= _oRetSta[_nY][#"codSubStatus"] 
					_cDescSta	:= _oRetSta[_nY][#"descrSubStatus"] 
					
					//--------------------+
					// Atualiza JSON DLOG |
					//--------------------+
					_oMemo 		:= xFromJson(_cMemo)
					_oMemo[#"codSubStatus"]		:= _cCodSta
					_oMemo[#"descrSubStatus"]	:= _cDescSta
					_oMemo[#"linkRastreamento"] := _cLink
					_cMemo 		:= xToJson(_oMemo)
					_lRet		:= .T.
				EndIf
			Next _nY 
		ElseIf ValType(_oRetSta) == "O"
			If _oRetSta[#"codSubStatus"] == 1
				//------------------------+	
				// Salva dados retornados |
				//------------------------+	
				_cLink 		:= _oRetSta[#"linkRastreamento"]
				_cCodSta	:= _oRetSta[#"codSubStatus"] 
				_cDescSta	:= _oRetSta[#"descrSubStatus"] 
				
				//--------------------+
				// Atualiza JSON DLOG |
				//--------------------+
				_oMemo 						:= xFromJson(_cMemo)
				_oMemo[#"codSubStatus"]		:= _cCodSta
				_oMemo[#"descrSubStatus"]	:= _cDescSta
				_oMemo[#"linkRastreamento"] := _cLink
				_cMemo 		:= xToJson(_oMemo)
				_lRet		:= .T.
			EndIf
		EndIf
	EndIf
EndIf

//-----------------------------------------+
// Atualiza informações para envio do Link |
//-----------------------------------------+
If _lRet
	If WSA->( dbSeek(xFilial("WSA") + _cNumEco) )
		RecLock("WSA",.F.)
			WSA->WSA_ENVLOG := "4"
		WSA->( MsUnLock() )	
	EndIf
EndIf

FreeObj(_oJSon)
FreeObj(_oStatus)
FreeObj(_oRetSta)
FreeObj(_oMemo)
FreeObj(_oDLog)

Return _lRet 

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
	ADD OPTION aRotina TITLE "Visualizar"          	ACTION "VIEWDEF.DLOGA01" 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Incluir" 	            ACTION "U_DLOGM02" 				OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.DLOGA01" 		OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.DLOGA01" 		OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE "Envia Coleta"			ACTION 'U_DLOGM03'		  		OPERATION 4 ACCESS 0
		
Return aRotina
