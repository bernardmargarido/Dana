#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE TYPE_MODEL	                        1
#DEFINE TYPE_VIEW	                        2

#DEFINE CRLF CHR(13) + CHR(10)

Static _cAliasXTA   := "XTA"
Static _cAliasXTB   := "XTB"
Static _cAliasXTC   := "XTC"
Static _cAliasXTD   := "XTD"

/************************************************************************************/
/*/{Protheus.doc} ECLOJ016
	@description Monitor pedidos e-Commerce
	@author Bernard M. Margarido
	@since 15/01/2021
	@version undefined
	@type function
/*/
/************************************************************************************/
User Function ECLOJ016()
Local aStruct       := {}
Local aColumns      := {}
Local aFilter       := {}
Local aSeek         := {}

Local cAliasTMP     := ""

Private _oBrowse    := Nil 
Private _nOldLen    := SetVarNameLen(255) 

//-------------------------+
// Cria arquivo temporario |
//-------------------------+
EcLoj16G(@cAliasTMP,@aStruct,@aColumns,@aFilter,@aSeek)

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
_oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
_oBrowse:SetAlias(cAliasTMP)

//-------------------+
// Adiciona Legendas |
//-------------------+
dbSelectArea("WS1")
WS1->( dbGoTop() )
While WS1->( !Eof() ) 
	_oBrowse:AddLegend( "WSA_CODSTA == '" + WS1->WS1_CODIGO + "'", WS1->WS1_CORSTA , WS1->WS1_DESCRI )
	WS1->( dbSkip() )
EndDo	  

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Monitor Pedidos eCommerce')
_oBrowse:SetTemporary(.T.)
_oBrowse:SetUseFilter(.T.)
_oBrowse:OptionReport(.F.)
_oBrowse:SetColumns(aColumns)
_oBrowse:SetFieldFilter(aFilter)
_oBrowse:SetSeek(.T.,aSeek)
_oBrowse:SetAttach(.T.)
_oBrowse:SetOpenChart(.T.)

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
    @since 15/01/2021
    @version undefined
    @type function
/*/
/************************************************************************************/
Static Function ModelDef()
Local _oModel		:= Nil
Local _oStruXTA     := Nil
Local _oStruXTB		:= Nil
Local _oStruXTC		:= Nil
Local _oStruXTD		:= Nil

Local _bLoad        := {|_oLoad| EcLoj16Load(_oLoad)}

//-----------------+
// Monta Estrutura |
//-----------------+
_oStruXTA   := FWFormModelStruct():New()
_oStruXTA:AddTable(_cAliasXTA,{"XTA_NUM"},"Dados Pedido")
EcLoj16Stru(_oStruXTA,_cAliasXTA,TYPE_MODEL)

_oStruXTB     := FWFormModelStruct():New()
_oStruXTB:AddTable(_cAliasXTB,{"XTB_NUM"},"Itens Pedido")
EcLoj16Stru(_oStruXTB,_cAliasXTB,TYPE_MODEL)

_oStruXTC     := FWFormModelStruct():New()
_oStruXTC:AddTable(_cAliasXTC,{"XTC_NUMECO"},"Historico Status")
EcLoj16Stru(_oStruXTC,_cAliasXTC,TYPE_MODEL)

_oStruXTD     := FWFormModelStruct():New()
_oStruXTD:AddTable(_cAliasXTD,{"XTD_NUM"},"Pagamento")
EcLoj16Stru(_oStruXTD,_cAliasXTD,TYPE_MODEL)

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('ECOMM_01', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
_oModel:SetDescription('Historico Pedidos e-Commerce')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('XTA_01',,_oStruXTA,,,_bLoad)

//-----------------------+
// Chave primaria pedido | 
//-----------------------+
_oModel:SetPrimaryKey({"XTA_FILIAL","XTA_NUM"})

//----------------+
// Pedido X Itens |
//----------------+
_oModel:AddGrid("XTB_01", "XTA_01" /*cOwner*/, _oStruXTB , /*_bPreLiOk*/ , /*_bLinOk*/ , /*_bLinOk*/ , /*_bPost*/, _bLoad)

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel("XTB_01"):SetUniqueLine( {"XTB_ITEM","XTB_PRODUT"} )

//-------------------------------------------+
// Grid não necessita de itens para gravação |
//-------------------------------------------+
_oModel:GetModel("XTB_01"):SetOptional(.T.)

//--------------------+
// Pedido X Historico |
//--------------------+
_oModel:AddGrid("XTC_01", "XTA_01" /*cOwner*/, _oStruXTC , /*_bPreLiOk*/ , /*_bLinOk*/ , /*_bLinOk*/ , /*_bPost*/, _bLoad)

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel("XTC_01"):SetUniqueLine( {"XTC_CODSTA"} )

//-------------------------------------------+
// Grid não necessita de itens para gravação |
//-------------------------------------------+
_oModel:GetModel("XTC_01"):SetOptional(.T.)

//--------------------+
// Pedido X Pagamento |
//--------------------+
_oModel:AddGrid("XTD_01", "XTA_01" /*cOwner*/, _oStruXTD , /*_bPreLiOk*/ , /*_bLinOk*/ , /*_bLinOk*/ , /*_bPost*/, _bLoad)

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel("XTD_01"):SetUniqueLine( {"XTD_NUM","XTD_PREFIXO","XTD_PARCELA"} )

//-------------------------------------------+
// Grid não necessita de itens para gravação |
//-------------------------------------------+
_oModel:GetModel("XTD_01"):SetOptional(.T.)

//_oModel:SetActivate( _bActivate )

Return _oModel

/************************************************************************************/
/*/{Protheus.doc} ViewDef
    @description Cria interface com o usuario
    @author Bernard M. Margarido
    @since 15/01/2021
    @version undefined
    @type function
/*/
/************************************************************************************/
Static Function ViewDef() 
Local _oView        
Local _oModel
Local _oStrViewXTA	:= Nil
Local _oStrViewXTB	:= Nil
Local _oStrViewXTC	:= Nil
Local _oStrViewXTD	:= Nil

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("ECLOJ016")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewXTA	:= FWFormViewStruct():New()
EcLoj16Stru(_oStrViewXTA,_cAliasXTA,TYPE_VIEW)

_oStrViewXTB	:= FWFormViewStruct():New()
EcLoj16Stru(_oStrViewXTB,_cAliasXTB,TYPE_VIEW)

_oStrViewXTC	:= FWFormViewStruct():New()
EcLoj16Stru(_oStrViewXTC,_cAliasXTC,TYPE_VIEW)

_oStrViewXTD	:= FWFormViewStruct():New()
EcLoj16Stru(_oStrViewXTD,_cAliasXTD,TYPE_VIEW)

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('Historico Pedidos eCommerce')

_oStrViewXTA:AddGroup("GRP_DADOSPV" ,"Dados Pedido","",2)
_oStrViewXTA:AddGroup("GRP_DADOSDE" ,"Dados Entrega" ,"", 2 )
_oStrViewXTA:AddGroup("GRP_DADOSNF" ,"Dados Nota Fiscal" ,"", 2 )

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XTA_FORM' 	, _oStrViewXTA , 'XTA_01' )
_oView:AddGrid('XTB_GRID'	, _oStrViewXTB , 'XTB_01' )
_oView:AddGrid('XTC_GRID'	, _oStrViewXTC , 'XTC_01' )
_oView:AddGrid('XTD_GRID'	, _oStrViewXTD , 'XTD_01' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 060 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'MEI_01' , 005 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INF_01' , 035 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

//---------+
// Folders |
//---------+
_oView:CreateFolder( 'FOLDER','INF_01' )
_oView:AddSheet( 'FOLDER', 'FOLDER_01', 'Itens' )
_oView:AddSheet( 'FOLDER', 'FOLDER_02', 'Financeiro' )
_oView:AddSheet( 'FOLDER', 'FOLDER_03', 'Status' )

_oView:CreateHorizontalBox( 'FOL_01' , 100 ,,, 'FOLDER', 'FOLDER_01' )
_oView:CreateHorizontalBox( 'FOL_02' , 100 ,,, 'FOLDER', 'FOLDER_02' )
_oView:CreateHorizontalBox( 'FOL_03' , 100 ,,, 'FOLDER', 'FOLDER_03' )

//_oView:CreateVerticalBox( 'ESQ_S1'   ,047 , 'INF_01' )
//_oView:CreateVerticalBox( 'MEI_S1'   ,006 , 'INF_01' )
//_oView:CreateVerticalBox( 'DIR_S1'   ,047 , 'INF_01' )

_oView:SetOwnerView('XTA_01'	    ,'SUP_01')
_oView:SetOwnerView('XTB_01'	    ,'FOL_01')
_oView:SetOwnerView('XTD_01'	    ,'FOL_02')
_oView:SetOwnerView('XTC_01'	    ,'FOL_03')

//------------------------+
// Titulo componente GRID |
//------------------------+
//_oView:EnableTitleView('XTA_FORM','Dados Pedido eCommerce')
//_oView:EnableTitleView('XTB_GRID','Itens do Pedido')
//_oView:EnableTitleView('XTC_GRID','Historico Status')

//-------------------+
// Adicionando botão | 
//-------------------+
//_oView:AddUserButton( "Inclui Pedido", 'EDIT', {|_oView| BsEic01A() } )

Return _oView 

/************************************************************************************/
/*/{Protheus.doc} EcLoj16Stru
    @description Cria estrutura de campos
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16Load(_oLoad)
Local _aRet     := {}

//----------------------+
// Carrega dados pedido | 
//----------------------+
If _oLoad:GetId() == "XTA_01"
     EcLoj16A(_oLoad,@_aRet)
//-------------------------+
// Carrega itens do pedido | 
//-------------------------+     
ElseIf _oLoad:GetId() == "XTB_01"
    EcLoj16B(_oLoad,@_aRet)
//----------------------------+
// Carrega dados do pagamento | 
//----------------------------+
ElseIf _oLoad:GetId() == "XTC_01"
    EcLoj16C(_oLoad,@_aRet)
//------------------+
// Historico pedido | 
//------------------+
ElseIf _oLoad:GetId() == "XTD_01"
    EcLoj16D(_oLoad,@_aRet)
EndIf

Return _aRet

/************************************************************************************/
/*/{Protheus.doc} EcLoj16A
    @description Carrega dados cabeçalho
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16A(_oModel,_aRet)
Local _aArea    := GetArea()
Local _aXTA     := {}

//--------------------------+
// Posiciona dados clientes |
//--------------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1") + WSA->WSA_CLIENT + WSA->WSA_LOJA) )

//--------------------------+
// Posiciona dados clientes |
//--------------------------+
dbSelectArea("SA4")
SA4->( dbSetOrder(1) )
SA4->( dbSeek(xFilial("SA4") + WSA->WSA_TRANSP) )

//-----------------------+
// Posiciona nota fiscal | 
//-----------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
SF2->( dbSeek(xFilial("SF2") + WSA->WSA_DOC + WSA->WSA_SERIE) )

aAdd(_aXTA, WSA->WSA_NUM)
aAdd(_aXTA, WSA->WSA_NUMECO)
aAdd(_aXTA, WSA->WSA_NUMECL)
aAdd(_aXTA, WSA->WSA_CLIENT)
aAdd(_aXTA, WSA->WSA_LOJA)
aAdd(_aXTA, SA1->A1_NOME)
aAdd(_aXTA, WSA->WSA_VLRLIQ)
aAdd(_aXTA, WSA->WSA_VLRTOT)
aAdd(_aXTA, WSA->WSA_TRANSP)
aAdd(_aXTA, SA4->A4_NOME)
aAdd(_aXTA, WSA->WSA_FRETE)
aAdd(_aXTA, WSA->WSA_NOMDES)
aAdd(_aXTA, WSA->WSA_ENDENT)
aAdd(_aXTA, WSA->WSA_BAIRRE)
aAdd(_aXTA, WSA->WSA_MUNE)
aAdd(_aXTA, WSA->WSA_CEPE)
aAdd(_aXTA, WSA->WSA_ESTE)
aAdd(_aXTA, WSA->WSA_COMPLE)
aAdd(_aXTA, WSA->WSA_REFEN)
aAdd(_aXTA, SF2->F2_DOC)
aAdd(_aXTA, SF2->F2_SERIE)
aAdd(_aXTA, SF2->F2_EMISSAO)
aAdd(_aXTA, SF2->F2_HORA)
aAdd(_aXTA, SF2->F2_CHVNFE)
aAdd(_aXTA, SF2->F2_DAUTNFE)
aAdd(_aXTA, SF2->F2_HAUTNFE)

_aRet := { _aXTA, WSA->( Recno() )}

RestArea(_aArea)
Return Nil 

/************************************************************************************/
/*/{Protheus.doc} EcLoj16B
    @description Carrega dados itens do pedido 
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16B(_oModel,_aRet)
Local _aArea    := GetArea()

Local _cAlias   := ""

If !EcLoj16BQ(@_cAlias)
    aAdd(_aRet, { 0 , {"","","",0,0,0,"",0,0}})
    Return Nil
EndIf

//-----------------------------------+
// Posiciona dados pedido e-Commerce |
//-----------------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(1) )

//--------------------------+
// Posiciona dados clientes |
//--------------------------+
While (_cAlias)->( !Eof() )

    aAdd(_aRet, { (_cAlias)->( RECNOWSB  ), Array(9)})
    _aRet[Len(_aRet)][2][1]    := (_cAlias)->WSB_ITEM
    _aRet[Len(_aRet)][2][2]    := (_cAlias)->WSB_PRODUT
    _aRet[Len(_aRet)][2][3]    := (_cAlias)->WSB_DESCRI
    _aRet[Len(_aRet)][2][4]    := (_cAlias)->WSB_QUANT
    _aRet[Len(_aRet)][2][5]    := (_cAlias)->WSB_VRUNIT
    _aRet[Len(_aRet)][2][6]    := (_cAlias)->WSB_VLRITE
    _aRet[Len(_aRet)][2][7]    := (_cAlias)->WSB_LOCAL
    _aRet[Len(_aRet)][2][8]    := (_cAlias)->WSB_DESC
    _aRet[Len(_aRet)][2][9]    := (_cAlias)->WSB_VALDES
    
    (_cAlias)->( dbSkip() )

EndDo

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return Nil 

/************************************************************************************/
/*/{Protheus.doc} EcLoj16C
    @description Carrega dados historico do pedido 
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16C(_oModel,_aRet)
Local _cAlias   := ""
Local _cObsSta  := ""

Local _lProximo := .T.

If !EcLoj16CQ(@_cAlias)
    aAdd(_aRet, { 0 , {"","",Date(),"",""}})
    Return Nil
EndIf

//-------------------------------+
// Posiciona liberação de pedido |
//-------------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//-----------------------+
// Posiciona nota fiscal | 
//-----------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

While (_cAlias)->( !Eof() )
    If _lProximo
        EcLoj16CSta((_cAlias)->WS2_CODSTA,@_cObsSta,@_lProximo)

        aAdd(_aRet, { (_cAlias)->RECNOWS2 , Array(5) })
        
        _aRet[Len(_aRet)][2][1] := (_cAlias)->WS2_CODSTA
        _aRet[Len(_aRet)][2][2] := (_cAlias)->WS1_DESCRI
        _aRet[Len(_aRet)][2][3] := sTod((_cAlias)->WS2_DATA)
        _aRet[Len(_aRet)][2][4] := (_cAlias)->WS2_HORA
        _aRet[Len(_aRet)][2][5] := _cObsSta
    EndIf
    (_cAlias)->( dbSkip() )

EndDo

(_cAlias)->( dbCloseArea() )

Return Nil

/************************************************************************************/
/*/{Protheus.doc} EcLoj16D
    @description Carrega dados pagamento e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16D(_oModel,_aRet)
Local _cAlias   := ""

If !EcLoj16DQ(@_cAlias)
    aAdd(_aRet, { 0 , {"","","","",Date(),0,CtoD(""),"",""}})
    Return Nil
EndIf

While (_cAlias)->( !Eof() )
    aAdd(_aRet, { (_cAlias)->RECNOSE1 , Array(9) })
    _aRet[Len(_aRet)][2][1] := (_cAlias)->E1_NUM
    _aRet[Len(_aRet)][2][2] := (_cAlias)->E1_PREFIXO
    _aRet[Len(_aRet)][2][3] := (_cAlias)->E1_TIPO
    _aRet[Len(_aRet)][2][4] := (_cAlias)->E1_PARCELA
    _aRet[Len(_aRet)][2][5] := StoD((_cAlias)->E1_VENCREA)
    _aRet[Len(_aRet)][2][6] := (_cAlias)->E1_VALOR
    _aRet[Len(_aRet)][2][7] := StoD((_cAlias)->E1_BAIXA)
    _aRet[Len(_aRet)][2][8] := (_cAlias)->WSC_NUMCAR

    _aRet[Len(_aRet)][2][9] := (_cAlias)->WSC_TID

    (_cAlias)->( dbSkip() )

EndDo

(_cAlias)->( dbCloseArea() )
    
Return Nil

/************************************************************************************/
/*/{Protheus.doc} EcLoj16BQ
    @description Consulta itens do pedido e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16CSta(_cCodSta,_cObsSta,_lProximo)
Local _aArea        := GetArea() 

Default _lProximo   := .T.

_cObsSta        := ""

//-----------------------+
// Bloqueado por estoque |
//-----------------------+
If _cCodSta == "004"
    dbSelectArea("SC9")
    SC9->( dbSetOrder(1) )
    If SC9->( dbSeek(xFilial("SC9") + WSA->WSA_NUMSC5) )
        While SC9->( !Eof() .And. xFilial("SC9") + WSA->WSA_NUMSC5 == SC9->C9_FILIAL + SC9->C9_PEDIDO)
            If !Empty(SC9->C9_BLEST)  .And. SC9->C9_BLEST <> '10'
                _cObsSta += "Item " + SC9->C9_ITEM + " Produto " + SC9->C9_PRODUTO + " sem saldo disponivel para o pedido de venda " + WSA->WSA_NUMSC5 + " ."
            EndIf
            SC9->( dbSkip() )
        EndDo 
    EndIf

//---------------------+
// Faturado/Despachado |
//---------------------+
ElseIf _cCodSta $ "005"
    dbSelectArea("SF2")
    SF2->( dbSetOrder(1) )
    If SF2->( dbSeek(xFilial("SF2") + WSA->WSA_DOC + WSA->WSA_SERIE) )
        If SF2->F2_XENVWMS $ "1/2"
            _cObsSta += "Pedido encontra-se em separação."
            _lProximo := .F.
        ElseIf SF2->F2_XENVWMS == "3"
            _cObsSta += "Pedido já separado/despachado."
            _lProximo:= .T.
        EndIf
    EndIf
EndIf

RestArea(_aArea)
Return Nil 

/************************************************************************************/
/*/{Protheus.doc} EcLoj16BQ
    @description Consulta itens do pedido e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16BQ(_cAlias)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "    WSB.WSB_ITEM, " + CRLF
_cQuery += "    WSB.WSB_PRODUT, " + CRLF
_cQuery += "    WSB.WSB_DESCRI, " + CRLF
_cQuery += "    WSB.WSB_QUANT, " + CRLF 
_cQuery += "    WSB.WSB_VRUNIT, " + CRLF
_cQuery += "    WSB.WSB_VLRITE, " + CRLF
_cQuery += "    WSB.WSB_LOCAL, " + CRLF
_cQuery += "    WSB.WSB_DESC, " + CRLF
_cQuery += "    WSB.WSB_VALDES, " + CRLF
_cQuery += "    WSB.R_E_C_N_O_ RECNOWSB " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "   " + RetSqlName("WSB") + " WSB " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "    WSB.WSB_FILIAL = '" + xFilial("WSB") + "' AND " + CRLF
_cQuery += "    WSB.WSB_NUM = '" + WSA->WSA_NUM + "' AND " + CRLF
_cQuery += "    WSB.D_E_L_E_T_ = '' " + CRLF    
_cQuery += " ORDER BY WSB.WSB_NUM,WSB.WSB_ITEM " 

_cAlias := MPSysOpenQuery(_cQuery)

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf 

Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj16CQ
    @description Carrega dados pagamento e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16CQ(_cAlias)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	WS2.WS2_CODSTA, " + CRLF
_cQuery += "	WS1.WS1_DESCRI, " + CRLF
_cQuery += "	WS2.WS2_DATA, " + CRLF
_cQuery += "	WS2.WS2_HORA,  " + CRLF
_cQuery += "	WS2.R_E_C_N_O_ RECNOWS2  " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WS2") + " WS2 " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("WS1") + " WS1 ON WS1.WS1_FILIAL = ' ' AND WS1.WS1_CODIGO = WS2.WS2_CODSTA AND WS1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WS2.WS2_FILIAL = '" + xFilial("WS2") + "' AND " + CRLF
_cQuery += "	WS2.WS2_NUMSL1 = '" + WSA->WSA_NUM + "' AND " + CRLF
_cQuery += "	WS2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY WS2.WS2_DATA,WS2.WS2_HORA " 

_cAlias := MPSysOpenQuery(_cQuery)

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf 

Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj16DQ
    @descrition Consulta dados do pagamento e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16DQ(_cAlias)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	E1.E1_NUM, " + CRLF
_cQuery += "	E1.E1_PREFIXO, " + CRLF
_cQuery += "	E1.E1_TIPO, " + CRLF
_cQuery += "	E1.E1_PARCELA, " + CRLF
_cQuery += "	E1.E1_VENCREA, " + CRLF
_cQuery += "	E1.E1_VALOR, " + CRLF
_cQuery += "	E1.E1_BAIXA, " + CRLF
_cQuery += "	WSC.WSC_NUMCAR, " + CRLF
_cQuery += "	WSC.WSC_TID, " + CRLF
_cQuery += "	E1.R_E_C_N_O_ RECNOSE1 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WSA") + " WSA " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("WSC") + " WSC ON WSC.WSC_FILIAL = WSA.WSA_FILIAL AND WSC.WSC_NUM = WSA.WSA_NUM AND WSC.D_E_L_E_T_ = '' " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("SL1") + " L1 ON L1.L1_FILIAL = WSA.WSA_FILIAL AND L1.L1_NUM = WSA.WSA_NUMSL1 AND L1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SE1") + " E1 ON E1.E1_FILIAL = '" + xFilial("SE1") + "' AND E1.E1_NUM = L1.L1_DOCPED AND E1.E1_PREFIXO = L1.L1_SERPED AND E1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "	WSA.WSA_NUM = '" + WSA->WSA_NUM + "' AND " + CRLF
_cQuery += "	WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += " GROUP BY E1.E1_NUM,E1.E1_PREFIXO,E1.E1_TIPO,E1.E1_PARCELA,E1.E1_VENCREA,E1.E1_VALOR,E1.E1_BAIXA,WSC.WSC_NUMCAR,WSC.WSC_TID,E1.R_E_C_N_O_  " + CRLF
_cQuery += " ORDER BY E1.E1_NUM,E1.E1_PREFIXO,E1.E1_PARCELA "

_cAlias := MPSysOpenQuery(_cQuery)

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf 

Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj16Stru
    @description Cria estrutura de campos
    @type  Static Function
    @author Bernard M. Margarido
    @since 15/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16Stru(_oStruct,_cAlias,_nType)
Local _aDadCPO  := {}

//-------+
// Model |
//-------+
If _nType == TYPE_MODEL

    //--------------------+
    // XTA - Dados pedido |
    //--------------------+
    If _cAlias == _cAliasXTA

        //--------------+
        // Dados pedido |
        //--------------+
        _aDadCPO := TxSX3Campo("WSA_NUM")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_NUM",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])
        
        _aDadCPO := TxSX3Campo("WSA_NUMECO")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_NUMECO",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_NUMECL")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_NUMECL",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_CLIENT")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_CLIENT",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_LOJA")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_LOJA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("A1_NOME")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_NOMCLI",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_VLRLIQ")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_VLRLIQ",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_VLRTOT")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_VLRTOT",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        //------------------+
        // Dados de entrega |
        //------------------+
        _aDadCPO := TxSX3Campo("WSA_TRANSP")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_TRANSP",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("A4_NOME")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_NOMTRA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_FRETE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_FRETE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_NOMDES")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_NOMDES",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_ENDENT")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_ENDENT",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_BAIRRE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_BAIRRE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_MUNE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_MUNE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_CEPE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_CEPE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_ESTE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_ESTE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_COMPLE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_COMPLE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_REFEN")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_REFEN",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        //---------------+
        // Dados da nota | 
        //---------------+
        _aDadCPO := TxSX3Campo("F2_DOC")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_DOC",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("F2_SERIE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_SERIE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("F2_EMISSAO")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_DTEMIS",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("F2_HORA")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_HORA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("F2_CHVNFE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_CHVNFE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("F2_DAUTNFE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_DAUTNF",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("F2_HAUTNFE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTA_HAUTNF",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])



    //--------------------+
    // XTB - Itens Pedido |
    //--------------------+
    ElseIf _cAlias == _cAliasXTB

        _aDadCPO := TxSX3Campo("WSB_ITEM")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_ITEM",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSB_PRODUT")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_PRODUT",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSB_DESCRI")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_DESCRI",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSB_QUANT")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_QUANT",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSB_VRUNIT")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_VRUNIT",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSB_VLRITE")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_VLRITE",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSB_LOCAL")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_LOCAL",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSB_DESC")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_DESC",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSB_VALDES")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTB_VALDES",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

    //---------------------+
    // XTC - Status Pedido |
    //---------------------+
    ElseIf _cAlias == _cAliasXTC

        _aDadCPO := TxSX3Campo("WS2_CODSTA")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTC_CODSTA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WS1_DESCRI")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTC_DESCRI",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WS2_DATA")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTC_DATA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WS2_HORA")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTC_HORA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSA_OBSECO")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTC_OBSECO",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])
    
    //------------------+
    // XTD - Pagamentos |
    //------------------+
    ElseIf _cAlias == _cAliasXTD

        _aDadCPO := TxSX3Campo("E1_NUM")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_NUM",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("E1_PREFIXO")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_PREFIXO",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("E1_TIPO")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_TIPO",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("E1_PARCELA")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_PARCELA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("E1_VENCREA")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_VENCREA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("E1_VALOR")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_VALOR",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("E1_BAIXA")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_BAIXA",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSC_NUMCAR")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_NUMCAR",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

        _aDadCPO := TxSX3Campo("WSC_TID")
        _oStruct:AddField(RTrim(_aDadCPO[1]),AllTrim(_aDadCPO[1]),"XTD_TID",_aDadCPO[6],_aDadCPO[3],_aDadCPO[4])

    EndIf

//------+
// View | 
//------+
ElseIf _nType == TYPE_VIEW
    
    //--------------------+
    // XTA - Dados pedido |
    //--------------------+
    If _cAlias == _cAliasXTA

        _aDadCPO := TxSX3Campo("WSA_NUM")
        _oStruct:AddField("XTA_NUM","01",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , "GRP_DADOSPV")

        _aDadCPO := TxSX3Campo("WSA_NUMECO")
        _oStruct:AddField("XTA_NOMCLI","02",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , "GRP_DADOSPV")

        _aDadCPO := TxSX3Campo("WSA_NUMECL")
        _oStruct:AddField("XTA_NUMECL","03",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , "GRP_DADOSPV")

        _aDadCPO := TxSX3Campo("WSA_CLIENT")
        _oStruct:AddField("XTA_CLIENT","04",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , "GRP_DADOSPV")

        _aDadCPO := TxSX3Campo("WSA_LOJA")
        _oStruct:AddField("XTA_LOJA","05",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , "GRP_DADOSPV")

        _aDadCPO := TxSX3Campo("A1_NOME")
        _oStruct:AddField("XTA_NOMCLI","06",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , "GRP_DADOSPV")

        _aDadCPO := TxSX3Campo("WSA_VLRLIQ")
        _oStruct:AddField("XTA_VLRLIQ","07",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSPV")

        _aDadCPO := TxSX3Campo("WSA_VLRTOT")
        _oStruct:AddField("XTA_VLRTOT","08",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , "GRP_DADOSPV")

        _aDadCPO := TxSX3Campo("WSA_TRANSP")
        _oStruct:AddField("XTA_TRANSP","09",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("A4_NOME")
        _oStruct:AddField("XTA_NOMTRA","10",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_FRETE")
        _oStruct:AddField("XTA_FRETE","11",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_NOMDES")
        _oStruct:AddField("XTA_NOMDES","12",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_ENDENT")
        _oStruct:AddField("XTA_ENDENT","13",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_BAIRRE")
        _oStruct:AddField("XTA_BAIRRE","14",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_MUNE")
        _oStruct:AddField("XTA_MUNE","15",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_CEPE")
        _oStruct:AddField("XTA_CEPE","16",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_ESTE")
        _oStruct:AddField("XTA_ESTE","17",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_COMPLE")
        _oStruct:AddField("XTA_COMPLE","18",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")

        _aDadCPO := TxSX3Campo("WSA_REFEN")
        _oStruct:AddField("XTA_REFEN","19",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSDE")
        
        _aDadCPO := TxSX3Campo("F2_DOC")
        _oStruct:AddField("XTA_DOC","20",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSNF")

        _aDadCPO := TxSX3Campo("F2_SERIE")
        _oStruct:AddField("XTA_SERIE","21",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSNF")

        _aDadCPO := TxSX3Campo("F2_EMISSAO")
        _oStruct:AddField("XTA_DTEMIS","22",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSNF")

        _aDadCPO := TxSX3Campo("F2_HORA")
        _oStruct:AddField("XTA_HORA","23",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSNF")

        _aDadCPO := TxSX3Campo("F2_CHVNFE")
        _oStruct:AddField("XTA_CHVNFE","24",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSNF")

        _aDadCPO := TxSX3Campo("F2_DAUTNFE")
        _oStruct:AddField("XTA_DAUTNF","25",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSNF")

        _aDadCPO := TxSX3Campo("F2_HAUTNFE")
        _oStruct:AddField("XTA_HAUTNF","26",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , "GRP_DADOSNF")

    //--------------------+
    // XTB - Itens Pedido |
    //--------------------+
    ElseIf _cAlias == _cAliasXTB

        _aDadCPO := TxSX3Campo("WSB_ITEM")
        _oStruct:AddField("XTB_ITEM","01",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSB_PRODUT")
        _oStruct:AddField("XTB_PRODUT","02",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSB_DESCRI")
        _oStruct:AddField("XTB_DESCRI","03",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSB_QUANT")
        _oStruct:AddField("XTB_QUANT","04",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSB_VRUNIT")
        _oStruct:AddField("XTB_VRUNIT","05",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSB_VLRITE")
        _oStruct:AddField("XTB_VLRITE","06",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSB_LOCAL")
        _oStruct:AddField("XTB_LOCAL","07",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSB_DESC")
        _oStruct:AddField("XTB_DESC","08",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSB_VALDES")
        _oStruct:AddField("XTB_VALDES","09",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

    //---------------------+
    // XTC - Status Pedido |
    //---------------------+
    ElseIf _cAlias == _cAliasXTC

        _aDadCPO := TxSX3Campo("WS2_CODSTA")
        _oStruct:AddField("XTC_CODSTA","01",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WS1_DESCRI")
        _oStruct:AddField("XTC_DESCRI","02",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WS2_DATA")
        _oStruct:AddField("XTC_DATA","03",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WS2_HORA")
        _oStruct:AddField("XTC_HORA","04",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSA_OBSECO")
        _oStruct:AddField("XTC_OBSECO","05",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)
    
    //------------------+
    // XTD - Pagamentos |
    //------------------+
    ElseIf _cAlias == _cAliasXTD

        _aDadCPO := TxSX3Campo("E1_NUM")
        _oStruct:AddField("XTD_NUM","01",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("E1_PREFIXO")
        _oStruct:AddField("XTD_PREFIXO","02",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("E1_TIPO")
        _oStruct:AddField("XTD_TIPO","03",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("E1_PARCELA")
        _oStruct:AddField("XTD_PARCELA","04",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("E1_VENCREA")
        _oStruct:AddField("XTD_VENCREA","05",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("E1_VALOR")
        _oStruct:AddField("XTD_VALOR","06",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("E1_BAIXA")
        _oStruct:AddField("XTD_BAIXA","07",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.T.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSC_NUMCAR")
        _oStruct:AddField("XTD_NUMCAR","08",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

        _aDadCPO := TxSX3Campo("WSC_TID")
        _oStruct:AddField("XTD_TID","09",_aDadCPO[1],_aDadCPO[2],{_aDadCPO[2]},_aDadCPO[6],_aDadCPO[5],Nil,Nil,.F.,Nil , Nil)

    EndIf

EndIf

Return Nil

/************************************************************************************/
/*/{Protheus.doc} Historico pedido 
    @description Tela somente com o historico do pedido e-Commerce
    @type  Function
    @author Bernard M. Margarido
    @since 25/01/2021
/*/
/************************************************************************************/
User Function EcLoj16F()
Local _oDlg         := Nil
Local _oMsGetDSt	:= Nil 

Private _aHeadSta	:= {}
Private _aColsSta	:= {}

//------------------+
// Consulta cliente | 
//------------------+
If !EcLoj16FQ()
    RestArea(_aArea)
    Return .F.
EndIf

//----------------------------------------+
// Cria Browser com os clientes filtrados |
//----------------------------------------+
_oDlg := TDialog():New(000,000,466,1185,"Dana Cosméticos - Historico pedido " + RTrim(WSA->WSA_NUMECO),,,,,,,,,.T.,,,,,,.F.)
    //-----------------------------------------+
	// Nao permite fechar tela teclando no ESC |
	//-----------------------------------------+
	_oDlg:lEscClose := .F.

    //----------------+
    // Painel Browser |
    //----------------+
	_oFwLayer := FwLayer():New()
	_oFwLayer:Init(_oDlg,.F.)

    _oFwLayer:AddLine("BRWCLI",100, .T.)
    _oFWLayer:AddCollumn( "COLBRWCLI"	,090, .T. , "BRWCLI")
    _oFWLayer:AddCollumn( "COLBTNCLI"	,010, .T. , "BRWCLI")
    _oFWLayer:AddWindow( "COLBRWCLI", "WINENT", "", 100, .F., .F., , "BRWCLI")
    _oFWLayer:AddWindow( "COLBTNCLI", "WINENT", "", 100, .F., .F., , "BRWCLI")
	    
    _oPanel_01 := _oFWLayer:GetWinPanel("COLBRWCLI","WINENT","BRWCLI")
    _oPanel_02 := _oFWLayer:GetWinPanel("COLBTNCLI","WINENT","BRWCLI")    
    
	_oMsGetDSt 	:= MsNewGetDados():New(000,000,000,000,2,/*cLinOk*/,/*cTudoOk1*/,/*cIniCpos*/,/*aAlterGda*/,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,_oPanel_01,_aHeadSta,_aColsSta)
	_oMsGetDSt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    _oBtnOk	:= TButton():New( 003, 003 , "Atualizar"  , _oPanel_02, {|| FwMsgRun(,{||EcLoj16FR(_oMsGetDSt,_aHeadSta,_aColsSta) },"Aguarde...","Atualizando historido do pedido.")}	, 040,012,,,.F.,.T.,.F.,,.F.,,,.F. )
    _oBtnCa	:= TButton():New( 020, 003 , "Sair" 	  , _oPanel_02, {|| _oDlg:End() }    , 040,012,,,.F.,.T.,.F.,,.F.,,,.F. )

    _oDlg:lCentered := .T.

_oDlg:Activate()

Return Nil 

/************************************************************************************/
/*/{Protheus.doc} EcLoj16FR
    @description Atualiza historico pedido 
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16FR(_oMsGetDSt,_aHeadSta,_aColsSta)
Local _aArea    := GetArea()

EcLoj16FQ()
_oMsGetDSt:oBrowse:Refresh()

RestArea(_aArea)
Return Nil 

/************************************************************************************/
/*/{Protheus.doc} EcLoj16FQ
    @description Consulta historico do pedido 
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/01/2021
/*/
/************************************************************************************/
Static Function EcLoj16FQ()
Local _cQuery 	:= ""
Local _cAlias	:= ""
Local _cObsSta  := ""

Local _lProximo := .T.

_cQuery := " SELECT " + CRLF
_cQuery += "	WS2.WS2_CODSTA, " + CRLF
_cQuery += "	WS1.WS1_DESCRI, " + CRLF
_cQuery += "	WS1.WS1_CORSTA, " + CRLF
_cQuery += "	WS2.WS2_DATA, " + CRLF
_cQuery += "	WS2.WS2_HORA,  " + CRLF
_cQuery += "	WS2.R_E_C_N_O_ RECNOWS2  " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WS2") + " WS2 " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("WS1") + " WS1 ON WS1.WS1_FILIAL = ' ' AND WS1.WS1_CODIGO = WS2.WS2_CODSTA AND WS1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WS2.WS2_FILIAL = '" + xFilial("WS2") + "' AND " + CRLF
_cQuery += "	WS2.WS2_NUMSL1 = '" + WSA->WSA_NUM + "' AND " + CRLF
_cQuery += "	WS2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY WS2.WS2_DATA,WS2.WS2_HORA " 

_cAlias := MPSysOpenQuery(_cQuery)

//------------------+
// Status do Pedido | 
//------------------+
_aHeadSta	:= {}
_aColsSta	:= {}

aAdd(_aHeadSta,{" "				,"WS2LEGEND"	,"@BMP"					,10							,0,""   ,"" ,"C",""," ","" } )
aAdd(_aHeadSta,{"Status"		,"WS2STATUS"	,"@!"					,TamSx3("WS2_CODSTA")[1]	,0,".F.","û","C",""," ","" } )
aAdd(_aHeadSta,{"Descricao"		,"WS2DESCRI"	,"@!"					,TamSx3("WS1_DESCRI")[1]	,0,".F.","û","C",""," ","" } )
aAdd(_aHeadSta,{"Data"			,"WS2DATA"		,"@D"					,TamSx3("WS2_DATA")[1]		,0,".F.","û","D",""," ","" } )
aAdd(_aHeadSta,{"Hora "			,"WS2HORA"		,""						,TamSx3("WS2_HORA")[1]		,0,".F.","û","C",""," ","" } )
aAdd(_aHeadSta,{"Observacao"	,"WS2OBS"		,""						,TamSx3("WSA_OBSECO")[1]	,0,".F.","û","M",""," ","" } )

While (_cAlias)->( !Eof() )

    If _lProximo
        EcLoj16CSta((_cAlias)->WS2_CODSTA,@_cObsSta,@_lProximo)

        aAdd(_aColsSta, Array(Len(_aHeadSta) + 1))
        _aColsSta[Len(_aColsSta)][1] := RTrim((_cAlias)->WS1_CORSTA)
        _aColsSta[Len(_aColsSta)][2] := (_cAlias)->WS2_CODSTA
        _aColsSta[Len(_aColsSta)][3] := RTrim((_cAlias)->WS1_DESCRI)
        _aColsSta[Len(_aColsSta)][4] := DToC(SToD((_cAlias)->WS2_DATA))
        _aColsSta[Len(_aColsSta)][5] := (_cAlias)->WS2_HORA
        _aColsSta[Len(_aColsSta)][6] := _cObsSta
        _aColsSta[Len(_aColsSta)][Len(_aHeadSta) + 1]:= .F.

    EndIf

	(_cAlias)->( dbSkip() )
EndDo

(_cAlias)->( dbCloseArea() )

Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj16G
    @description Monta arquivo temporario
    @type  Static Function
    @author Bernard M Margarido
    @since 07/04/2022
/*/
/************************************************************************************/
Static Function EcLoj16G(cAliasTMP,aStruct,aColumns,aFilter,aSeek)
Local nX            := 0 
Local nOrder        := 0

Local cQuery        := ""
Local cAliasQry     := ""

Local oTempTable    := Nil 

aAdd(aStruct, {"NUMREG"     , "N", 12                           , 00})
aAdd(aStruct, {"WSA_CODSTA" , "C", TamSX3("WSA_CODSTA")[01]     , TamSX3("WSA_CODSTA")[02]})
aAdd(aStruct, {"WSA_FILIAL" , "C", TamSX3("WSA_FILIAL")[01]     , TamSX3("WSA_FILIAL")[02]})
aAdd(aStruct, {"WSA_NUM"    , "C", TamSX3("WSA_NUM")[01]        , TamSX3("WSA_NUM")[02]})
aAdd(aStruct, {"WSA_NUMSC5" , "C", TamSX3("WSA_NUMSC5")[01]     , TamSX3("WSA_NUMSC5")[02]})
aAdd(aStruct, {"WSA_CLIENT" , "C", TamSX3("WSA_CLIENT")[01]     , TamSX3("WSA_CLIENT")[02]})
aAdd(aStruct, {"WSA_LOJA"   , "C", TamSX3("WSA_LOJA")[01]       , TamSX3("WSA_LOJA")[02]})
aAdd(aStruct, {"WSA_VEND"   , "C", TamSX3("WSA_VEND")[01]       , TamSX3("WSA_VEND")[02]})
aAdd(aStruct, {"WSA_DOC"    , "C", TamSX3("WSA_DOC")[01]        , TamSX3("WSA_DOC")[02]})
aAdd(aStruct, {"WSA_SERIE"  , "C", TamSX3("WSA_SERIE")[01]      , TamSX3("WSA_SERIE")[02]})
aAdd(aStruct, {"WSA_EMISSA" , "D", TamSX3("WSA_EMISSA")[01]     , TamSX3("WSA_EMISSA")[02]})
aAdd(aStruct, {"WSA_NOMDES" , "C", TamSX3("WSA_NOMDES")[01]     , TamSX3("WSA_NOMDES")[02]})
aAdd(aStruct, {"WSA_NUMECO" , "C", TamSX3("WSA_NUMECO")[01]     , TamSX3("WSA_NUMECO")[02]})
aAdd(aStruct, {"WSA_NUMSL1" , "C", TamSX3("WSA_NUMSL1")[01]     , TamSX3("WSA_NUMSL1")[02]})
aAdd(aStruct, {"WSA_VALBRU" , "N", TamSX3("WSA_VALBRU")[01]     , TamSX3("WSA_VALBRU")[02]})
aAdd(aStruct, {"WSA_NUMECL", "C", TamSX3("WSA_NUMECL")[01]      , TamSX3("WSA_NUMECL")[02]})
aAdd(aStruct, {"WSA_VLRLIQ", "N", TamSX3("WSA_VLRLIQ")[01]      , TamSX3("WSA_VLRLIQ")[02]})
aAdd(aStruct, {"WSA_VLRTOT", "N", TamSX3("WSA_VLRTOT")[01]      , TamSX3("WSA_VLRTOT")[02]})
aAdd(aStruct, {"WSA_TRANSP", "C", TamSX3("WSA_TRANSP")[01]      , TamSX3("WSA_TRANSP")[02]})
aAdd(aStruct, {"WSA_FRETE ", "N", TamSX3("WSA_FRETE")[01]       , TamSX3("WSA_FRETE")[02]})
aAdd(aStruct, {"WSA_ENDENT", "C", TamSX3("WSA_ENDENT")[01]      , TamSX3("WSA_ENDENT")[02]})
aAdd(aStruct, {"WSA_BAIRRE", "C", TamSX3("WSA_BAIRRE")[01]      , TamSX3("WSA_BAIRRE")[02]})
aAdd(aStruct, {"WSA_MUNE"  , "C", TamSX3("WSA_MUNE")[01]        , TamSX3("WSA_MUNE")[02]})
aAdd(aStruct, {"WSA_CEPE"  , "C", TamSX3("WSA_CEPE")[01]        , TamSX3("WSA_CEPE")[02]})
aAdd(aStruct, {"WSA_ESTE"  , "C", TamSX3("WSA_ESTE")[01]        , TamSX3("WSA_ESTE")[02]})
aAdd(aStruct, {"WSA_COMPLE", "C", TamSX3("WSA_COMPLE")[01]      , TamSX3("WSA_COMPLE")[02]})
aAdd(aStruct, {"WSA_REFEN" , "C", TamSX3("WSA_REFEN")[01]       , TamSX3("WSA_REFEN")[02]})

// Set Columns
aColumns := {}
aFilter  := {}
For nX := 03 To Len(aStruct)
    //Columns
    aAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
    aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nX][1]))
    aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
    aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
    aColumns[Len(aColumns)]:SetPicture(PesqPict("WSA",aStruct[nX][1]))
    //Filters
    aAdd(aFilter, {aStruct[nX][1], RetTitle(aStruct[nX][1]), TamSX3(aStruct[nX][1])[3], TamSX3(aStruct[nX][1])[1], TamSX3(aStruct[nX][1])[2], PesqPict("WSA", aStruct[nX][1])} )
Next nX

//Instance of Temporary Table
oTempTable := FWTemporaryTable():New()
//Set Fields
oTempTable:SetFields(aStruct)
//Set Indexes
oTempTable:AddIndex("INDEX1", {"WSA_NUM"} )
oTempTable:AddIndex("INDEX2", {"WSA_NUMSC5"} )
//Create
oTempTable:Create()
cAliasTmp := oTemptable:GetAlias()

cQuery := " SELECT " + CRLF
cQuery += "	    WSA.* " + CRLF 
cQuery += " FROM " + CRLF
cQuery += "	    " + RetSqlName("WSA") + " WSA " + CRLF
cQuery += "	    INNER JOIN " + RetSqlName("SF3") + " SF3 ON SF3.F3_FILIAL = WSA.WSA_FILIAL AND SF3.F3_NFISCAL = WSA_DOC AND SF3.F3_SERIE = WSA_SERIE AND SF3.F3_CLIENT = WSA_CLIENT AND SF3.F3_LOJA = WSA_LOJA AND SF3.F3_DTCANC = '' AND SF3.D_E_L_E_T_= '' " + CRLF
cQuery += " WHERE " + CRLF
cQuery += "	    WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
cQuery += "	    WSA.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(cQuery)
nOrder  := 01

DBSelectArea(cAliasTMP)
(_cAlias)->(DbGoTop())
While !(_cAlias)->(Eof())
    //Add Temporary Table
    If (RecLock(cAliasTMP, .T.))
        (cAliasTMP)->NUMREG     := nOrder
        (cAliasTMP)->WSA_CODSTA := (_cAlias)->WSA_CODSTA
        (cAliasTMP)->WSA_FILIAL := (_cAlias)->WSA_FILIAL
        (cAliasTMP)->WSA_NUM    := (_cAlias)->WSA_NUM
        (cAliasTMP)->WSA_NUMSC5 := (_cAlias)->WSA_NUMSC5
        (cAliasTMP)->WSA_CLIENT := (_cAlias)->WSA_CLIENT
        (cAliasTMP)->WSA_LOJA   := (_cAlias)->WSA_LOJA
        (cAliasTMP)->WSA_VEND   := (_cAlias)->WSA_VEND
        (cAliasTMP)->WSA_DOC    := (_cAlias)->WSA_DOC
        (cAliasTMP)->WSA_SERIE  := (_cAlias)->WSA_SERIE
        (cAliasTMP)->WSA_EMISSA := sTod((_cAlias)->WSA_EMISSA)
        (cAliasTMP)->WSA_NOMDES := (_cAlias)->WSA_NOMDES
        (cAliasTMP)->WSA_NUMECO := (_cAlias)->WSA_NUMECO
        (cAliasTMP)->WSA_NUMSL1 := (_cAlias)->WSA_NUMSL1
        (cAliasTMP)->WSA_VALBRU := (_cAlias)->WSA_VALBRU
        (cAliasTMP)->WSA_NUMECL := (_cAlias)->WSA_NUMECL
        (cAliasTMP)->WSA_VLRLIQ := (_cAlias)->WSA_VLRLIQ
        (cAliasTMP)->WSA_VLRTOT := (_cAlias)->WSA_VLRTOT
        (cAliasTMP)->WSA_TRANSP := (_cAlias)->WSA_TRANSP
        (cAliasTMP)->WSA_FRETE  := (_cAlias)->WSA_FRETE
        (cAliasTMP)->WSA_ENDENT := (_cAlias)->WSA_ENDENT
        (cAliasTMP)->WSA_BAIRRE := (_cAlias)->WSA_BAIRRE
        (cAliasTMP)->WSA_MUNE   := (_cAlias)->WSA_MUNE
        (cAliasTMP)->WSA_CEPE   := (_cAlias)->WSA_CEPE
        (cAliasTMP)->WSA_ESTE   := (_cAlias)->WSA_ESTE
        (cAliasTMP)->WSA_COMPLE := (_cAlias)->WSA_COMPLE
        (cAliasTMP)->WSA_REFEN  := (_cAlias)->WSA_REFEN
        (cAliasTMP)->(MsUnlock())
    EndIf
    nOrder ++
    (_cAlias)->( DBSkip() )
EndDo

(cAliasTMP)->( DbGoTop() )
(_cAlias)->( dbCloseArea() )

// Array de pesquisa
aAdd( aSeek, {; // WSA_FILIAL + WSA_NUM
    		    AllTrim(RetTitle("WSA_FILIAL")) + ' + ' + AllTrim(RetTitle("WSA_NUM")) ,;
				{; //,;
					{'WSA',"C",TamSx3("WSA_FILIAL")[1],TamSx3("WSA_FILIAL")[2],RetTitle("WSA_FILIAL"),Nil},;
					{'WSA',"C",TamSx3("WSA_NUM")[1],TamSx3("WSA_NUM")[2],RetTitle("WSA_NUM"),Nil};
				}})
aAdd( aSeek, {; // WSA_FILIAL+WSA_NUMECO+WSA_NUMECL
				AllTrim(RetTitle("WSA_FILIAL")) + ' + ' + AllTrim(RetTitle("WSA_NUMECO")) + ' + ' + AllTrim(RetTitle("WSA_NUMECL")),;
				{; //,;
					{'WSA',"C",TamSx3("WSA_FILIAL")[1],TamSx3("WSA_FILIAL")[2],RetTitle("WSA_FILIAL"),Nil},;
                    {'WSA',"C",TamSx3("WSA_NUMECO")[1],TamSx3("WSA_NUMECO")[2],RetTitle("WSA_NUMECO"),Nil},;
                    {'WSA',"C",TamSx3("WSA_NUMECL")[1],TamSx3("WSA_NUMECL")[2],RetTitle("WSA_NUMECL"),Nil};
				}})

aAdd( aSeek, {; // WSA_FILIAL+WSA_NUMSC5
				AllTrim(RetTitle("WSA_FILIAL")) + ' + ' + AllTrim(RetTitle("WSA_NUMSC5")) ,;
				{; //,;
					{'WSA',"C",TamSx3("WSA_FILIAL")[1],TamSx3("WSA_FILIAL")[2],RetTitle("WSA_FILIAL"),Nil},;
                    {'WSA',"C",TamSx3("WSA_NUMSC5")[1],TamSx3("WSA_NUMSC5")[2],RetTitle("WSA_NUMSC5"),Nil};
				}})



Return Nil 

/************************************************************************************/
/*/{Protheus.doc} MenuDef
	@description Menu padrao para manutencao do cadastro
	@author Bernard M. Margarido
	@since 15/01/2021
	@version undefined
/*/
/************************************************************************************/
Static Function MenuDef()
Local _aRotina := {}

    ADD OPTION _aRotina TITLE "Pesquisar"            	ACTION "PesqBrw"            		OPERATION 1 ACCESS 0  
    ADD OPTION _aRotina TITLE "Visualizar"           	ACTION "VIEWDEF.ECLOJ016" 			OPERATION 2 ACCESS 0 
    ADD OPTION _aRotina TITLE "Monitor Status "        	ACTION "U_EcLoj017"      			OPERATION 4 ACCESS 0 
    ADD OPTION _aRotina TITLE "Historico "           	ACTION "U_EcLoj16F"      			OPERATION 4 ACCESS 0 

Return _aRotina  //FwMVCMenu('ECLOJ016')

