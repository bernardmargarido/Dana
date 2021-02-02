#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE COL_STATUS  01  
#DEFINE COL_PEDIDO  02  
#DEFINE COL_CLIENTE 03  
#DEFINE COL_STA01   04
#DEFINE COL_STA02   05
#DEFINE COL_STA03   06
#DEFINE COL_STA04   07
#DEFINE COL_STA05   08
#DEFINE COL_STA06   09
#DEFINE COL_STA07   10
#DEFINE COL_VAZIO   11

#DEFINE CRLF        CHR(13) + CHR(10)
#DEFINE CLR_CINZA   RGB(230,230,230)
#DEFINE CLR_GREENL  RGB(122,193,65)
#DEFINE CLR_WHITE   RGB(255,255,255)


/********************************************************************************************************/
/*/{Protheus.doc} ECLOJ017
    @description Monitos Status pedidos e-Commerce
    @type  Function
    @author Bernard M. Margarido
    @since 01/02/2021
/*/
/********************************************************************************************************/
User Function ECLOJ017()
Local _aParamBox    := {}
Local _aRet         := {}

Private _cPedidoDe  := ""
Private _cPedidoAte := ""
Private _cEmissaoDe := ""
Private _cEmissaoAte:= ""

Private _aTpCli     := CtbcBox("A1_TIPO")

//---------------------------+
// Cria parametros relatorio |
//---------------------------+
aAdd(_aParamBox,{1, "Pedido De?"        , Space(TamSx3("WSA_NUMECO")[1])   , PesqPict("WSA","WSA_NUMECO")       , "", "WSA"   , "", TamSx3("WSA_NUMECO")[1]     , .F.})
aAdd(_aParamBox,{1, "Pedido Ate?"       , Space(TamSx3("WSA_NUMECO")[1])   , PesqPict("WSA","WSA_NUMECO")       , "", "WSA"   , "", TamSx3("WSA_NUMECO")[1]     , .T.})
aAdd(_aParamBox,{1, "Emissao De?"       , StoD("")                         , "@D"                               , "", ""      , "", 50                          , .T.})
aAdd(_aParamBox,{1, "Emissao Ate?"      , StoD("")                         , "@D"                               , "", ""      , "", 50                          , .T.})

//-------------------+
// Parametros rotina |
//-------------------+
If ParamBox(_aParamBox,"Status Pedidos e-Commerce",@_aRet,,,,,,,,.T.)

    _cPedidoDe  := mv_par01
    _cPedidoAte := mv_par02
    _cEmissaoDe := mv_par03
    _cEmissaoAte:= mv_par04

    FwMsgRun(,{|_oSay| EcLoj017A(_oSay)},"Aguarde...","Consultando pedidos..")

EndIf

Return Nil 

/********************************************************************************************************/
/*/{Protheus.doc} EcLoj017A
    @description Consulta pedidos e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 01/02/2021
/*/
/********************************************************************************************************/
Static Function EcLoj017A(_oSay)
Local _aArea        := GetArea()
Local _aCoors       := FWGetDialogSize( oMainWnd )

Local _oDlg         := Nil
Local _oBrowse      := Nil
Local _oScroll      := Nil
Local _oFwLayer     := Nil
Local _oBtnCa	    := Nil
Local _oSize        := FWDefSize():New( .T. )

Private _aPedidos   := {}
Private _aHeader    := {}
Private _aCols      := {}

_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	:= .T.
_oSize:Process()

_oSay:cCaption := "Consultando pedidos."
ProcessMessages()

//--------------+
// Cria Header  |
//--------------+
EcLoj017b(_oSay)

//------------------------+
// Query consulta pedidos | 
//------------------------+
EcLoj017Qry(_oSay)

//----------------------------------------+
// Cria Browser com os clientes filtrados |
//----------------------------------------+
_oSay:cCaption := "Montando dados na tela."
ProcessMessages()

_oDlg := TDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3], _oSize:aWindSize[4],"Historico Pedidos",,,,,,,,,.T.,,,,,,.F.)
    //-----------------------------------------+
	// Nao permite fechar tela teclando no ESC |
	//-----------------------------------------+
	_oDlg:lEscClose := .F.
    
    //----------------------------------------+
    // Scroll caso altere a resolucao da tela |
    //----------------------------------------+
    _oScroll := TScrollArea():New(_oDlg, 000, 000, 000, 000)
    _oScroll:Align := CONTROL_ALIGN_ALLCLIENT
    _oScroll:ReadClientCoors(.T.,.T.)
    _oScroll:SetFrame( _oFwLayer )

    //----------------+
    // Painel Browser |
    //----------------+
	_oFwLayer := FwLayer():New()
	_oFwLayer:Init(_oScroll,.F.)

    _oFwLayer:AddLine("LINE_GRID",085, .T.)
    _oFWLayer:AddCollumn("COL_GRID"	,100, .T. , "LINE_GRID")
    _oFWLayer:AddWindow( "COL_GRID", "WIN_GRID", "", 100, .F., .F., , "LINE_GRID")
    _oFwLayer_01 := _oFWLayer:GetWinPanel("COL_GRID","WIN_GRID","LINE_GRID")
    
    _oBrowse 	:= MsNewGetDados():New(000,000,000,000,GD_UPDATE,/*_bLinOk*/,/*cTudoOk1*/,/*cIniCpos*/,/*aAlter*/,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,_oFwLayer_01,_aHeader,_aCols)
	_oBrowse:oBrowse:bLDblClick		  	:= {|| EcLoj017c(_oBrowse) }
	_oBrowse:oBrowse:lUseDefaultColors 	:= .T.
	_oBrowse:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
    
    _oFwLayer:AddLine("LINE_DESC",012, .T.)
    _oFWLayer:AddCollumn("COL_DESC"	,100, .T. , "LINE_DESC")
    _oFWLayer:AddWindow( "COL_DESC", "WIN_DESC", "", 100, .F., .F., , "LINE_DESC")
    _oFwLayer_02 := _oFWLayer:GetWinPanel("COL_DESC","WIN_DESC","LINE_DESC")
        
    _oBtnCa	:= TButton():New( 001, 860 , "Sair"     , _oFwLayer_02, {|| _oDlg:End() }	, 042,015,,,.F.,.T.,.F.,,.F.,,,.F. )
    _oBtnCa:Align   := CONTROL_ALIGN_RIGHT
    _oBtnCa:nHeight := 005
	_oBtnCa:nWidth  := 100
    
    _oDlg:lCentered := .T.

_oDlg:Activate()

RestArea(_aArea)
Return Nil 

/********************************************************************************************************/
/*/{Protheus.doc} EcLoj017b
    @description Cria GRID consulta de pedidos
    @type  Static Function
    @author Bernard M. Margarido
    @since 01/02/2021
/*/
/********************************************************************************************************/
Static Function EcLoj017b(_oSay)

_oSay:cCaption  := "Criando tabela temporaria"

_aHeader    := {}
aAdd(_aHeader,{" "					,"HIS_STATUS"	,"@BMP"					        ,10						    ,0,""   ,"" ,"C",""," ","" } )
aAdd(_aHeader,{"Pedido"		        ,"HIS_PEDVEN"	,PesqPict("WSA","WSA_NUMECO")   ,TamSx3("WSA_NUMECO")[1]	,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{"Cliente"		    ,"HIS_CLIENT"	,PesqPict("SA1","A1_NOME") 	    ,TamSx3("A1_NREDUZ")[1]     ,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{"Pgto. Aprovado"		,"HIS_STA01"	,"@BMP"					        ,10	                        ,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{"Pedido Liberado"	,"HIS_STA02"	,"@BMP"					        ,10                         ,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{"Ped. com Bloqueio"	,"HIS_STA03"	,"@BMP"             	        ,10	                        ,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{"Lib. Faturamento"	,"HIS_STA04"	,"@BMP"					        ,10	                        ,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{"Ped. em Separação"  ,"HIS_STA05"	,"@BMP"					        ,10	                        ,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{"Faturado"			,"HIS_STA06"	,"@BMP"					        ,10	                        ,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{"Despachado"	    	,"HIS_STA07"	,"@BMP"					        ,10	                        ,0,".F.","û","C",""," ","" } )
aAdd(_aHeader,{""			        ,"HIS_VAZIO"	,"@!"					        ,10	                        ,0,".F.","û","C",""," ","" } )

Return Nil 

/********************************************************************************************************/
/*/{Protheus.doc} EcLoj017Qry
    @description Consulta pedidos e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 01/02/2021
/*/
/********************************************************************************************************/
Static Function EcLoj017Qry(_oSay)
_oSay:cCaption := "Salvando dados encontrados."

    aAdd(_aCols,Array(Len(_aHeader) + 1)) 
    _aCols[Len(_aCols)][COL_STATUS] := EcLoj017d("008")
    _aCols[Len(_aCols)][COL_PEDIDO] := "123456789-0"
    _aCols[Len(_aCols)][COL_CLIENTE]:= RTrim("Teste")
    _aCols[Len(_aCols)][COL_STA01]  := EcLoj017e(1)
    _aCols[Len(_aCols)][COL_STA02]  := EcLoj017e(1)
    _aCols[Len(_aCols)][COL_STA03]  := EcLoj017e(1)
    _aCols[Len(_aCols)][COL_STA04]  := EcLoj017e(1)
    _aCols[Len(_aCols)][COL_STA05]  := EcLoj017e(1)
    _aCols[Len(_aCols)][COL_STA06]  := EcLoj017e(1)
    _aCols[Len(_aCols)][COL_STA07]  := EcLoj017e(1)
    _aCols[Len(_aCols)][COL_VAZIO]  := ""
    
    _aCols[Len(_aCols)][Len(_aHeader) + 1]:= .F.

Return Nil 

Static Function EcLoj017d(_cCodSta)
Local _cCorSta  := ""

dbSelectArea("WS1")
WS1->( dbSetOrder(1) )
WS1->( dbSeek(xFilial("WS1") + _cCodSta) )
_cCorSta := WS1->WS1_CORSTA

Return _cCorSta

Static Function EcLoj017e(_nStatus)
Return IIF(_nStatus > 0,"CHECKOK","")