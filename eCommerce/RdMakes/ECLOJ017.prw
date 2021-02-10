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
Local _cQuery   := ""
Local _cAlias   := ""
Local _cPedido  := ""
Local _cStatus  := ""
Local _cCliente := ""


_cQuery := " SELECT " + CRLF
_cQuery += "	PEDIDO, " + CRLF
_cQuery += "    STATUS, " + CRLF
_cQuery += "	CLIENTE, " + CRLF
_cQuery += "	CODSTA, " + CRLF
_cQuery += "	TOTSTA " + CRLF
/*
_cQuery += "	COALESCE([002],0) PAGAMENTO_APROVADO, " + CRLF
_cQuery += "	COALESCE([003],0) PEDIDO_LIBERADO, " + CRLF
_cQuery += "	COALESCE([004],0) BOQUEIO_ESTOQUE, " + CRLF
_cQuery += "	COALESCE([011],0) LIBERADO_FATURAMENTO, " + CRLF
_cQuery += "	COALESCE([010],0) PEDIDO_SEPARACAO, " + CRLF
_cQuery += "	COALESCE([005],0) FATURADO, " + CRLF
_cQuery += "	COALESCE([006],0) DESPACHADO " + CRLF
*/
_cQuery += " FROM " + CRLF
_cQuery += " ( " + CRLF
_cQuery += "	SELECT " + CRLF
_cQuery += "		WSA.WSA_NUMECO PEDIDO, " + CRLF
_cQuery += "		WSA.WSA_CODSTA STATUS, " + CRLF
_cQuery += "		A1.A1_NOME CLIENTE, " + CRLF
_cQuery += "		STATUS_ECOMM.WS2_CODSTA CODSTA, " + CRLF
_cQuery += "		COUNT(STATUS_ECOMM.WS2_CODSTA) TOTSTA " + CRLF
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("WSA") + " WSA " + CRLF
_cQuery += "		INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = WSA.WSA_CLIENT AND A1.A1_LOJA = WSA.WSA_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "		CROSS APPLY( " + CRLF
_cQuery += "					SELECT " + CRLF
_cQuery += "						WS2.WS2_CODSTA," + CRLF
_cQuery += "						WS2.WS2_DATA," + CRLF
_cQuery += "						WS2.WS2_HORA" + CRLF
_cQuery += "					FROM " + CRLF
_cQuery += "						" + RetSqlName("ws2") + " WS2 " + CRLF
_cQuery += "					WHERE " + CRLF
_cQuery += "						WS2.WS2_FILIAL = WSA.WSA_FILIAL AND " + CRLF
_cQuery += "						WS2.WS2_NUMSL1 = WSA.WSA_NUM AND " + CRLF
_cQuery += "						WS2.D_E_L_E_T_ = '' " + CRLF
_cQuery += "				) STATUS_ECOMM " + CRLF
_cQuery += "	WHERE " + CRLF
_cQuery += "		WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "		WSA.WSA_NUMECO BETWEEN '" + _cPedidoDe + "' AND '" + _cPedidoAte + "' AND " + CRLF
_cQuery += "		WSA.WSA_EMISSA BETWEEN '" + dTos(_cEmissaoDe) + "' AND '" + dTos(_cEmissaoAte) + "' AND " + CRLF
_cQuery += "		WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	GROUP BY WSA.WSA_NUMECO, WSA.WSA_CODSTA, A1.A1_NOME, STATUS_ECOMM.WS2_CODSTA " + CRLF
_cQuery += " )HISTORICO " + CRLF
/*
_cQuery += " PIVOT ( SUM(TOTSTA) FOR CODSTA IN([002],[003],[004],[011],[010],[005],[006]) ) AS STAPROD " + CRLF
_cQuery += " ORDER BY PEDIDO, CLIENTE "
*/
_cAlias := MPSysOpenQuery(_cQuery)

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

While (_cAlias)->(!Eof() )

    _oSay:cCaption  := "Salvando dados encontrados."
    _cPedido        := (_cAlias)->PEDIDO
    _cStatus        := (_cAlias)->STATUS
    _cCliente       := (_cAlias)->CLIENTE

    aAdd(_aCols,Array(Len(_aHeader) + 1)) 
    _aCols[Len(_aCols)][COL_STATUS] := EcLoj017d(_cStatus)
    _aCols[Len(_aCols)][COL_PEDIDO] := _cPedido
    _aCols[Len(_aCols)][COL_CLIENTE]:= RTrim(_cCliente)
    _aCols[Len(_aCols)][COL_STA01]  := EcLoj017e(0)
    _aCols[Len(_aCols)][COL_STA02]  := EcLoj017e(0)
    _aCols[Len(_aCols)][COL_STA03]  := EcLoj017e(0)
    _aCols[Len(_aCols)][COL_STA04]  := EcLoj017e(0)
    _aCols[Len(_aCols)][COL_STA05]  := EcLoj017e(0)
    _aCols[Len(_aCols)][COL_STA06]  := EcLoj017e(0)
    _aCols[Len(_aCols)][COL_STA07]  := EcLoj017e(0)
    _aCols[Len(_aCols)][COL_VAZIO]  := ""
    
    _aCols[Len(_aCols)][Len(_aHeader) + 1]:= .F.

    While (_cAlias)->(!Eof() .And. _cPedido == (_cAlias)->PEDIDO )
        If (_cAlias)->CODSTA == "002"
            _aCols[Len(_aCols)][COL_STA01]  := EcLoj017e(1)
        ElseIf (_cAlias)->CODSTA == "003"
            _aCols[Len(_aCols)][COL_STA02]  := EcLoj017e(1)
        ElseIf (_cAlias)->CODSTA == "004"
            _aCols[Len(_aCols)][COL_STA03]  := EcLoj017e(1)
        ElseIf (_cAlias)->CODSTA == "005"
            _aCols[Len(_aCols)][COL_STA06]  := EcLoj017e(1)
            _aCols[Len(_aCols)][COL_STA05]  := EcLoj017e(1)
        ElseIf (_cAlias)->CODSTA == "006"
            _aCols[Len(_aCols)][COL_STA07]  := EcLoj017e(1)
        ElseIf (_cAlias)->CODSTA == "010"
            _aCols[Len(_aCols)][COL_STA05]  := EcLoj017e(1)
        ElseIf (_cAlias)->CODSTA == "011"
            _aCols[Len(_aCols)][COL_STA04]  := EcLoj017e(1)
            _aCols[Len(_aCols)][COL_STA02]  := EcLoj017e(1)
        EndIf
        (_cAlias)->( dbSkip() )
    EndDo
EndDo

(_cAlias)->( dbCloseArea() )

Return Nil 

/********************************************************************************************************/
/*/{Protheus.doc} EcLoj017d
    @description Consulta status atual do pedido
    @type  Static Function
    @author Bernard M. Margarido
    @since 01/02/2021
/*/
/********************************************************************************************************/
Static Function EcLoj017d(_cCodSta)
Local _cCorSta  := ""

dbSelectArea("WS1")
WS1->( dbSetOrder(1) )
WS1->( dbSeek(xFilial("WS1") + _cCodSta) )
_cCorSta := WS1->WS1_CORSTA

Return _cCorSta

/********************************************************************************************************/
/*/{Protheus.doc} EcLoj017e
    @description Valida historico do pedido
    @type  Static Function
    @author Bernard M. Margarido
    @since 01/02/2021
/*/
/********************************************************************************************************/
Static Function EcLoj017e(_nStatus)
Return IIF(_nStatus > 0,"CHECKOK","")