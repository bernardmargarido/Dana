#INCLUDE "TOTVS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE FF_LAYOUT_VERT_DESCR_TOP 			001 // Vertical com descrição acima do get
#DEFINE FF_LAYOUT_VERT_DESCR_LEFT			002 // Vertical com descrição a esquerda
#DEFINE FF_LAYOUT_HORZ_DESCR_TOP 			003 // Horizontal com descrição acima do get
#DEFINE FF_LAYOUT_HORZ_DESCR_LEFT			004 // Horizontal com descrição a esquerda

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************************/
/*/{Protheus.doc} ECLOJ015
    @description Cadastro de Lojas e-Commerce
    @type  Function
    @author Bernard M Margarido
    @since 11/08/2022Admin  
    @version version
/*/
/************************************************************************************************/
User Function ECLOJ015()
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()

//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("XTC")

//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "XTC_STATUS == '1'", "GREEN" , "Ativo")
_oBrowse:AddLegend( "XTC_STATUS == '2'", "RED"   , "Inativo")

//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('Cadastro de Lojas - eCommerce')
_oBrowse:SetMenuDef("ECLOJ015")

//--------------------+
// Ativação do Browse |
//--------------------+
_oBrowse:Activate()
Return Nil 

/************************************************************************************************/
/*/{Protheus.doc} ModelDef
    @description Modelo de dados, estrutura dos dados e modelo de negocio
    @type  Function
    @author Bernard M Margarido
    @since 11/08/2022
    @version version
/*/
/************************************************************************************************/
Static Function ModelDef()

Local _oModel		:= Nil
Local _oStruXTC   	:= FWFormStruct(1 ,"XTC" )
Local _oStruAY0     := EcLoj15A("AY0") 
Local _oStruAY2     := EcLoj15A("AY2") 
Local _oStruSB5     := EcLoj15A("SB5") 
Local _oStruSB1     := EcLoj15A("SB1") 

//Local _bPosValid	:= {|_oModel| EcLoj14TOk(_oModel)	}  
//Local _bCommit	:= {|_oModel| EcLoj14Grv(_oModel)	}  

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('XTC_00', /*bPreValid*/ , /*_bPosValid*/ , /*_bCommit*/ , /*_bCancel*/ )
_oModel:SetDescription('Lojas e-Commerce.')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('XTCMASTER',,_oStruXTC)

//------------------------------+
// GRID contendo as amarrações  |
//------------------------------+
_oModel:AddGrid("AY0DETAIL","XTCMASTER",_oStruAY0,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|_oModel| EcLoj15C(_oModel,"AY0") }/* bLoad */)
_oModel:GetModel("AY0DETAIL"):SetOptional(.T.)
_oModel:GetModel("AY0DETAIL"):SetNoInsertLine(.T.)
_oModel:GetModel("AY0DETAIL"):SetNoUpdateLine(.T.)
_oModel:GetModel("AY0DETAIL"):SetNoDeleteLine(.T.)

_oModel:AddGrid("AY2DETAIL","XTCMASTER",_oStruAY2,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|_oModel| EcLoj15C(_oModel,"AY2") }/* bLoad */)
_oModel:GetModel("AY2DETAIL"):SetOptional(.T.)
_oModel:GetModel("AY2DETAIL"):SetNoInsertLine(.T.)
_oModel:GetModel("AY2DETAIL"):SetNoUpdateLine(.T.)
_oModel:GetModel("AY2DETAIL"):SetNoDeleteLine(.T.)

_oModel:AddGrid("SB5DETAIL","XTCMASTER",_oStruSB5,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|_oModel| EcLoj15C(_oModel,"SB5") }/* bLoad */)
_oModel:GetModel("SB5DETAIL"):SetOptional(.T.)
_oModel:GetModel("SB5DETAIL"):SetNoInsertLine(.T.)
_oModel:GetModel("SB5DETAIL"):SetNoUpdateLine(.T.)
_oModel:GetModel("SB5DETAIL"):SetNoDeleteLine(.T.)

_oModel:AddGrid("SB1DETAIL","XTCMASTER",_oStruSB1,/* bLinePre */ , /* bLinePost */, /* bPre */,/* bLinePost */, {|_oModel| EcLoj15C(_oModel,"SB1") }/* bLoad */)
_oModel:GetModel("SB1DETAIL"):SetOptional(.T.)
_oModel:GetModel("SB1DETAIL"):SetNoInsertLine(.T.)
_oModel:GetModel("SB1DETAIL"):SetNoUpdateLine(.T.)
_oModel:GetModel("SB1DETAIL"):SetNoDeleteLine(.T.)

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({ "XTC_FILIAL" , "XTC_CODIGO" })

_oModel:GetModel('AY0DETAIL'):SetDescription( "Categoria X ID" )
_oModel:GetModel('AY2DETAIL'):SetDescription( "Marca X ID" )
_oModel:GetModel('SB5DETAIL'):SetDescription( "Produto X ID" )
_oModel:GetModel('SB1DETAIL'):SetDescription( "SKU X ID" )

Return _oModel

/************************************************************************************************/
/*/{Protheus.doc} ViewDef
    @description Cria interface com o usuario
    @type  Function
    @author Bernard M Margarido
    @since 11/08/2022
    @version version
/*/
/************************************************************************************************/
Static Function ViewDef()

Local _oView
Local _oModel
Local _oStrViewXTC	:= FWFormStruct(2 ,"XTC" )
Local _oStrViewAY0	:= EcLoj15B("AY0")
Local _oStrViewAY2	:= EcLoj15B("AY2")
Local _oStrViewSB5	:= EcLoj15B("SB5")
Local _oStrViewSB1	:= EcLoj15B("SB1")

_oModel := FWLoadModel("ECLOJ015")
_oView	:= FWFormView():New()

_oView:SetModel(_oModel)
_oView:SetDescription('Cadastro de Lojas e-Commerce.')

_oView:showUpdateMsg(.F.)
_oView:showInsertMsg(.T.)

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XTCFORM' 	, _oStrViewXTC , 'XTCMASTER' )
_oView:AddGrid('AY0FORM'	, _oStrViewAY0 , 'AY0DETAIL' )
_oView:AddGrid('AY2FORM'	, _oStrViewAY2 , 'AY2DETAIL' )
_oView:AddGrid('SB5FORM'	, _oStrViewSB5 , 'SB5DETAIL' )
_oView:AddGrid('SB1FORM'	, _oStrViewSB1 , 'SB1DETAIL' )

_oView:CreateHorizontalBox( 'SUPERIOR_A1'    		, 050 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INFERIOR_A1'    		, 050 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:CreateVerticalBox( 'ESQ_S1'      ,100 , 'SUPERIOR_A1' )
_oView:CreateVerticalBox( 'MEI_S1'      ,001 , 'SUPERIOR_A1' )

_oView:CreateVerticalBox( 'ESQ_A1'      ,100 , 'INFERIOR_A1' )
_oView:CreateVerticalBox( 'MEI_A1'      ,001 , 'INFERIOR_A1' )

//-------------+
// Cria pastas | 
//-------------+ 
_oView:CreateFolder('FOLDER','INFERIOR_A1')
_oView:AddSheet( 'FOLDER', 'FOLDER_01', "Categorias" )
_oView:AddSheet( 'FOLDER', 'FOLDER_02', "Marcas" )
_oView:AddSheet( 'FOLDER', 'FOLDER_03', "Produtos" )
_oView:AddSheet( 'FOLDER', 'FOLDER_04', "Sku's" )

_oView:CreateVerticalBox( 'INF_01', 100,,, 'FOLDER', 'FOLDER_01')
_oView:CreateVerticalBox( 'INF_02', 100,,, 'FOLDER', 'FOLDER_02')
_oView:CreateVerticalBox( 'INF_03', 100,,, 'FOLDER', 'FOLDER_03')
_oView:CreateVerticalBox( 'INF_04', 100,,, 'FOLDER', 'FOLDER_04')

_oView:SetOwnerView('XTCFORM'	,'ESQ_S1')
_oView:SetOwnerView('AY0FORM'	,'INF_01')
_oView:SetOwnerView('AY2FORM'	,'INF_02')
_oView:SetOwnerView('SB5FORM'	,'INF_03')
_oView:SetOwnerView('SB1FORM'	,'INF_04')

//_oView:bAfterViewActivate := { |_oView| EcLoj014Fld(_oView)}

Return _oView

/*************************************************************************************************/
/*/{Protheus.doc} EcLoj15A
    @description Cria arquivos temporarios
    @type  Static Function
    @author Bernard M Margarido
    @since 12/08/2022
/*/
/*************************************************************************************************/
Static Function EcLoj15A(_cAlias) 
Local _oStruct  := Nil 

If _cAlias == "AY0"
    _oStruct  := FWFormModelStruct():New()
    _oStruct:AddField(	;
                        "Codigo"				,;	// [01] Titulo do campo
                        "Codigo"				,;	// [02] ToolTip do campo
                        "CODIGO"			    ,;	// [03] Id do Field
                        "C"					    ,;	// [04] Tipo do campo
                        TamSx3("AY0_CODIGO")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
    
    _oStruct:AddField(	;
                        "ID eComm"				,;	// [01] Titulo do campo
                        "ID eComm"				,;	// [02] ToolTip do campo
                        "IDECOMM"			    ,;	// [03] Id do Field
                        "N"					    ,;	// [04] Tipo do campo
                        TamSx3("AY0_XIDCAT")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
    _oStruct:AddField(	;
                        "DT Envio"      		,;	// [01] Titulo do campo
                        "DT Envio"				,;	// [02] ToolTip do campo
                        "DTENVIO"			    ,;	// [03] Id do Field
                        "C"					    ,;	// [04] Tipo do campo
                        TamSx3("XTD_DTENV")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório

ElseIf _cAlias == "AY2"
    _oStruct  := FWFormModelStruct():New()
    _oStruct:AddField(	;
                        "Codigo"				,;	// [01] Titulo do campo
                        "Codigo"				,;	// [02] ToolTip do campo
                        "CODIGO"			    ,;	// [03] Id do Field
                        "C"					    ,;	// [04] Tipo do campo
                        TamSx3("AY2_CODIGO")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
    
    _oStruct:AddField(	;
                        "ID eComm"				,;	// [01] Titulo do campo
                        "ID eComm"				,;	// [02] ToolTip do campo
                        "IDECOMM"			    ,;	// [03] Id do Field
                        "N"					    ,;	// [04] Tipo do campo
                        TamSx3("AY2_XIDMAR")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
    _oStruct:AddField(	;
                        "DT Envio"      		,;	// [01] Titulo do campo
                        "DT Envio"				,;	// [02] ToolTip do campo
                        "DTENVIO"			    ,;	// [03] Id do Field
                        "C"					    ,;	// [04] Tipo do campo
                        TamSx3("XTD_DTENV")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
ElseIf _cAlias == "SB5"
    _oStruct  := FWFormModelStruct():New()
    _oStruct:AddField(	;
                        "Codigo"				,;	// [01] Titulo do campo
                        "Codigo"				,;	// [02] ToolTip do campo
                        "CODIGO"			    ,;	// [03] Id do Field
                        "C"					    ,;	// [04] Tipo do campo
                        TamSx3("B5_COD")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
    
    _oStruct:AddField(	;
                        "ID eComm"				,;	// [01] Titulo do campo
                        "ID eComm"				,;	// [02] ToolTip do campo
                        "IDECOMM"			    ,;	// [03] Id do Field
                        "N"					    ,;	// [04] Tipo do campo
                        TamSx3("B5_XIDPROD")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
    _oStruct:AddField(	;
                        "DT Envio"      		,;	// [01] Titulo do campo
                        "DT Envio"				,;	// [02] ToolTip do campo
                        "DTENVIO"			    ,;	// [03] Id do Field
                        "C"					    ,;	// [04] Tipo do campo
                        TamSx3("XTD_DTENV")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
ElseIf _cAlias == "SB1"
    _oStruct  := FWFormModelStruct():New()
    _oStruct:AddField(	;
                        "Codigo"				,;	// [01] Titulo do campo
                        "Codigo"				,;	// [02] ToolTip do campo
                        "CODIGO"			    ,;	// [03] Id do Field
                        "C"					    ,;	// [04] Tipo do campo
                        TamSx3("BI_COD")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
    
    _oStruct:AddField(	;
                        "ID eComm"				,;	// [01] Titulo do campo
                        "ID eComm"				,;	// [02] ToolTip do campo
                        "IDECOMM"			    ,;	// [03] Id do Field
                        "N"					    ,;	// [04] Tipo do campo
                        TamSx3("B5_XIDSKU")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
    _oStruct:AddField(	;
                        "DT Envio"      		,;	// [01] Titulo do campo
                        "DT Envio"				,;	// [02] ToolTip do campo
                        "DTENVIO"			    ,;	// [03] Id do Field
                        "C"					    ,;	// [04] Tipo do campo
                        TamSx3("XTD_DTENV")[1]	,;	// [05] Tamanho do campo
                        0					    ,;	// [06] Decimal do campo
                        { || .T. }			    ,;	// [07] Code-block de validação do campo
                                                ,;	// [08] Code-block de validação When do campo
                                                ,;	// [09] Lista de valores permitido do campo
                        .F.                     )   // [10] Indica se o campo tem preenchimento obrigatório
EndIf 

Return _oStruct 

/*************************************************************************************************/
/*/{Protheus.doc} EcLoj15B
    @description Cria arquivos temporarios
    @type  Static Function
    @author Bernard M Margarido
    @since 12/08/2022
/*/
/*************************************************************************************************/
Static Function EcLoj15B(_cAlias) 
Local _oStruct  := Nil 

If _cAlias == "AY0"
    _oStruct  := FWFormViewStruct():New()
    _oStruct:AddField(		                ;
                        "CODIGO"			,;	// [01] Id do Field
                        "01"				,;	// [02] Ordem
                        "Codigo"	        ,;	// [03] Titulo do campo		//"Lote"
                        "Codigo Categoria"	,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                        "@!"				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
    _oStruct:AddField(		                ;
                        "IDECOMM"			,;	// [01] Id do Field
                        "02"				,;	// [02] Ordem
                        "ID eComm"	        ,;	// [03] Titulo do campo		//"Lote"
                        "ID eComm"	        ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                             				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
    _oStruct:AddField(		                ;
                        "DTENVIO"			,;	// [01] Id do Field
                        "03"				,;	// [02] Ordem
                        "DT Envio"	        ,;	// [03] Titulo do campo		//"Lote"
                        "DT Envio"	        ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                            				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3

ElseIf _cAlias == "AY2"
    _oStruct  := FWFormViewStruct():New()
    _oStruct:AddField(		                ;
                        "CODIGO"			,;	// [01] Id do Field
                        "01"				,;	// [02] Ordem
                        "Codigo"	        ,;	// [03] Titulo do campo		//"Lote"
                        "Codigo Marca"  	,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                        "@!"				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
    _oStruct:AddField(		                ;
                        "IDECOMM"			,;	// [01] Id do Field
                        "02"				,;	// [02] Ordem
                        "ID eComm"	        ,;	// [03] Titulo do campo		//"Lote"
                        "ID eComm"	        ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                             				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
    _oStruct:AddField(		                ;
                        "DTENVIO"			,;	// [01] Id do Field
                        "03"				,;	// [02] Ordem
                        "DT Envio"	        ,;	// [03] Titulo do campo		//"Lote"
                        "DT Envio"	        ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                            				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
ElseIf _cAlias == "SB5"
    _oStruct  := FWFormViewStruct():New()
    _oStruct:AddField(		                ;
                        "CODIGO"			,;	// [01] Id do Field
                        "01"				,;	// [02] Ordem
                        "Codigo"	        ,;	// [03] Titulo do campo		//"Lote"
                        "Codigo Produto"  	,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                        "@!"				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
    _oStruct:AddField(		                ;
                        "IDECOMM"			,;	// [01] Id do Field
                        "02"				,;	// [02] Ordem
                        "ID eComm"	        ,;	// [03] Titulo do campo		//"Lote"
                        "ID eComm"	        ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                             				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
    _oStruct:AddField(		                ;
                        "DTENVIO"			,;	// [01] Id do Field
                        "03"				,;	// [02] Ordem
                        "DT Envio"	        ,;	// [03] Titulo do campo		//"Lote"
                        "DT Envio"	        ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                            				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
ElseIf _cAlias == "SB1"
    _oStruct  := FWFormViewStruct():New()
    _oStruct:AddField(		                ;
                        "CODIGO"			,;	// [01] Id do Field
                        "01"				,;	// [02] Ordem
                        "Codigo"	        ,;	// [03] Titulo do campo		//"Lote"
                        "Codigo SKU"  	    ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                        "@!"				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
    _oStruct:AddField(		                ;
                        "IDECOMM"			,;	// [01] Id do Field
                        "02"				,;	// [02] Ordem
                        "ID eComm"	        ,;	// [03] Titulo do campo		//"Lote"
                        "ID eComm"	        ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                             				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
    _oStruct:AddField(		                ;
                        "DTENVIO"			,;	// [01] Id do Field
                        "03"				,;	// [02] Ordem
                        "DT Envio"	        ,;	// [03] Titulo do campo		//"Lote"
                        "DT Envio"	        ,;	// [04] ToolTip do campo	//"Lote"
                                            ,;	// [05] Help
                        "G"					,;	// [06] Tipo do campo
                            				,;	// [07] Picture
                                            ,;	// [08] PictVar
                        ''					)	// [09] F3
EndIf 

Return _oStruct 

/************************************************************************************/
/*/{Protheus.doc} EcLoj15C
    @description Carrega dados das tabelas 
    @type  Static Function
    @author Bernard M Margarido
    @since 12/08/2022
/*/
/************************************************************************************/
Static Function EcLoj15C(_oModel,_cAlias)
Local _aLoad    := {}
Local _aRegs    := {}
Local _aFields  := _oModel:oFormModelStruct:GetFields()

Local _cIdLoja  := XTC->XTC_CODIGO

dbSelectArea("XTD")
XTD->( dbSetOrder(2) )
If XTD->( dbSeek(xFilial("XTD") + _cIdLoja + _cAlias) )
    While XTD->( !Eof() .And. xFilial("XTD") + _cIdLoja + _cAlias == XTD->XTD_FILIAL + XTD->XTD_CODIGO + XTD->XTD_ALIAS )

        _aRegs := Array( Len( _aFields ) )
        _aRegs[1] := XTD->XTD_CODERP
        _aRegs[2] := XTD->XTD_IDECOM
        _aRegs[3] := XTD->XTD_DTENV 

        aAdd(_aLoad ,{ XTD->(Recno()),_aRegs} )

        XTD->( dbSkip() )
    EndDo 
   
Else 
    aAdd(_aLoad,{0 ,{"",0,""} })
EndIf 

Return _aLoad

/************************************************************************************/
/*/{Protheus.doc} MenuDef
    @description Menu 
    @author Bernard M. Margarido
    @since 10/08/2022
    @version undefined
    @type function
/*/
/************************************************************************************/
Static Function MenuDef()
Local _aRotina := {}
    ADD OPTION _aRotina TITLE "Pesquisar"            	ACTION "PesqBrw"            		OPERATION 1 ACCESS 0  
    ADD OPTION _aRotina TITLE "Visualizar"           	ACTION "VIEWDEF.ECLOJ015" 			OPERATION 2 ACCESS 0 
    ADD OPTION _aRotina TITLE "Incluir"              	ACTION "VIEWDEF.ECLOJ015" 			OPERATION 3 ACCESS 0 
    ADD OPTION _aRotina TITLE "Alterar"              	ACTION "VIEWDEF.ECLOJ015" 			OPERATION 4 ACCESS 0 
    ADD OPTION _aRotina TITLE "Excluir"              	ACTION "VIEWDEF.ECLOJ015" 			OPERATION 5 ACCESS 0 
Return _aRotina 
