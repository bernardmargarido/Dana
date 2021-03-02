#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE COL_STATUS  01  
#DEFINE COL_PEDIDO  02  
#DEFINE COL_CLIENTE 03  
#DEFINE COL_DTEMISS 04
#DEFINE COL_STA01   05
#DEFINE COL_STA02   06
#DEFINE COL_STA03   07
#DEFINE COL_STA04   08
#DEFINE COL_STA05   09
#DEFINE COL_STA06   10
#DEFINE COL_STA07   11
#DEFINE COL_VAZIO   12

#DEFINE CRLF        CHR(13) + CHR(10)
#DEFINE CLR_CINZA   RGB(230,230,230)
#DEFINE CLR_BLACK   RGB(000,000,000)
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
aAdd(_aParamBox,{1, "Pedido De?"        , Space(TamSx3("WSA_NUMECO")[1])   , PesqPict("WSA","WSA_NUMECO")       , "", "WSA"   , "", 80     , .F.})
aAdd(_aParamBox,{1, "Pedido Ate?"       , Space(TamSx3("WSA_NUMECO")[1])   , PesqPict("WSA","WSA_NUMECO")       , "", "WSA"   , "", 80     , .T.})
aAdd(_aParamBox,{1, "Emissao De?"       , StoD("")                         , "@D"                               , "", ""      , "", 50     , .T.})
aAdd(_aParamBox,{1, "Emissao Ate?"      , StoD("")                         , "@D"                               , "", ""      , "", 50     , .T.})

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
aAdd(_aHeader,{"Emissao"		    ,"HIS_DTEMIS"	,PesqPict("WSA","WSA_EMISSA")   ,TamSx3("WSA_EMISSA")[1]    ,0,".F.","û","C",""," ","" } )
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
/*/{Protheus.doc} EcLoj017c
    @description Mostra status detalhado do pedido e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 23/02/2021
/*/
/********************************************************************************************************/
Static Function EcLoj017c(_oBrowse)
Local _cNumEc       := _aCols[_oBrowse:nAt][COL_PEDIDO]
Local _cCodCli      := ""
Local _cLojaCli     := ""
Local _cRazao       := ""
Local _dDtEmissao   := ""
Local _cFileHtml    := ""
Local _cCodImg      := "br_cinza_ocean.gif"
Local _cSerStat     := "\ecommerce\status_img\"
Local _cCliStat     := RTrim(GetTempPath())
Local _cTmpHtml     := RTrim(GetTempPath())

Local _oDlg         := Nil
Local _oScroll      := Nil
Local _oPanel_01    := Nil
Local _oPanel_02    := Nil
Local _oPanel_03    := Nil
Local _oSay01       := Nil 
Local _oSay02       := Nil 
Local _oSay03       := Nil 
Local _oSay04       := Nil 
Local _oBtn_Sair    := Nil

Local _oFont20N     := TFont():New("Arial Black",,-20,,.T.,,,,,.F. )

//--------------------------------------------------+
// Copia imagem status do servidor para pasta local |
//--------------------------------------------------+
CpyS2T(_cSerStat + _cCodImg, _cCliStat)

//----------------------------+
// Posiciona Pedido eCommerce |
//----------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )
If !WSA->( dbSeek(xFilial("WSA") + _cNumEc) )
    MsgAlert("Pedido" + RTrim(_cNumEc) + " não localizado.")
    Return .T.
EndIf

//---------------------------+
// Grava dados nas variaveis |
//---------------------------+
_cCodCli      := WSA->WSA_CLIENT
_cLojaCli     := WSA->WSA_LOJA
_cRazao       := Capital(RTrim(Posicione("SA1",1,xFilial("SA1") + _cCodCli + _cLojaCli,"A1_NOME")))
_dDtEmissao   := dToc(WSA->WSA_EMISSA)

//----------------------------------------+
// Cria Browser com os clientes filtrados |
//----------------------------------------+
_oDlg := TDialog():New(000,000,566,1185,"",,,,,,,,,.T.,,,,,,.F.)
    //----------------------------------------+
    // Scroll caso altere a resolucao da tela |
    //----------------------------------------+
    _oScroll := TScrollArea():New(_oDlg, 000, 000, 000, 000)
    _oScroll:Align := CONTROL_ALIGN_ALLCLIENT
    _oScroll:ReadClientCoors(.T.,.T.)

    //-----------------------------------------+
	// Nao permite fechar tela teclando no ESC |
	//-----------------------------------------+
	_oDlg:lEscClose := .F.

    //---------------------------+
	// Painel para as descrições | 
	//---------------------------+
	_oPanel_01 := TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,CLR_BLACK,000,040,.T.,.F.)
	_oPanel_01:Align := CONTROL_ALIGN_TOP

    //------------------+
    // Dados do cliente |
    //------------------+
    _oSay01 := TSay():New( 003, 002, {|| "Pedido: " + _cNumEc } , _oPanel_01, "", _oFont20N, /*uParam7*/, /*uParam8*/, /*uParam9*/, .T., CLR_WHITE, /*nClrBack*/  , 200, 020, /*uParam15*/, /*uParam16*/, /*uParam17*/, /*uParam18*/, /*uParam19*/, /*lHTML*/, /*nTxtAlgHor*/, /*nTxtAlgVer*/ )
    _oSay02 := TSay():New( 003, 300, {|| "Emissao: " + _dDtEmissao } , _oPanel_01, "", _oFont20N, /*uParam7*/, /*uParam8*/, /*uParam9*/, .T., CLR_WHITE, /*nClrBack*/  , 150, 020, /*uParam15*/, /*uParam16*/, /*uParam17*/, /*uParam18*/, /*uParam19*/, /*lHTML*/, /*nTxtAlgHor*/, /*nTxtAlgVer*/ )
    _oSay03 := TSay():New( 018, 002, {|| "Cliente\Loja: " + _cCodCli + " \ " + _cLojaCli } , _oPanel_01, "", _oFont20N, /*uParam7*/, /*uParam8*/, /*uParam9*/, .T., CLR_WHITE, /*nClrBack*/  , 150, 020, /*uParam15*/, /*uParam16*/, /*uParam17*/, /*uParam18*/, /*uParam19*/, /*lHTML*/, /*nTxtAlgHor*/, /*nTxtAlgVer*/ )
    _oSay04 := TSay():New( 018, 300, {|| "Nome: " + _cRazao } , _oPanel_01, "", _oFont20N, /*uParam7*/, /*uParam8*/, /*uParam9*/, .T., CLR_WHITE, /*nClrBack*/  , 500, 020, /*uParam15*/, /*uParam16*/, /*uParam17*/, /*uParam18*/, /*uParam19*/, /*lHTML*/, /*nTxtAlgHor*/, /*nTxtAlgVer*/ )

    //---------------+
	// Painel Imagem | 
	//---------------+
	_oPanel_02 := TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,CLR_WHITE,000,377,.T.,.F.)
	_oPanel_02:Align := CONTROL_ALIGN_TOP

    //----------------------------+
    // Rotina monta status pedido |
    //----------------------------+
    _cFileHtml  := _cTmpHtml + CriaTrab(Nil, .F.) + ".htm"
    EcLoj017f(_cNumEc,_dDtEmissao,_oPanel_02,_oBrowse,_oBrowse:nAt,@_cFileHtml)

    //---------------+
	// Painel Botoes | 
	//---------------+
	_oPanel_03 := TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,CLR_CINZA,000,020,.T.,.F.)
	_oPanel_03:Align := CONTROL_ALIGN_BOTTOM

    //---------+
    // Legenda | 
    //---------+
    _oBtn_Sair	:= TButton():New( 003, 540 , "Sair"     , _oPanel_03, {|| FErase(_cFileHtml), _oDlg:End() }	, 042,015,,,.F.,.T.,.F.,,.F.,,,.F. )

    _oDlg:lCentered := .T.
_oDlg:Activate()

Return Nil 

/****************************************************************************/
/*/{Protheus.doc} EcLoj017f
    @description Monta imagem e status do pedido 
    @type  Static Function
    @author Bernard M. Margarido
    @since 19/06/2020
/*/
/****************************************************************************/
Static Function EcLoj017f(_cNumEc,_dDtEmissao,_oPanel_02,_oBrowse,_nLin,_cFileHtml)
Local _aStatus  := {}

Local _cStatus  := ""
Local _cHtml    := ""

Local _nTNumEc  := TamSx3("WS2_NUMECO")[1]
Local _nTStatus := TamSx3("WS2_CODSTA")[1]
Local _nPSta_01 := aScan(_oBrowse:aHeader,{|x| RTrim(x[2]) == "HIS_STA01"})
Local _nPSta_02 := aScan(_oBrowse:aHeader,{|x| RTrim(x[2]) == "HIS_STA02"})
Local _nPSta_03 := aScan(_oBrowse:aHeader,{|x| RTrim(x[2]) == "HIS_STA03"})
Local _nPSta_04 := aScan(_oBrowse:aHeader,{|x| RTrim(x[2]) == "HIS_STA04"})
Local _nPSta_05 := aScan(_oBrowse:aHeader,{|x| RTrim(x[2]) == "HIS_STA05"})
Local _nPSta_06 := aScan(_oBrowse:aHeader,{|x| RTrim(x[2]) == "HIS_STA06"})
Local _nPSta_07 := aScan(_oBrowse:aHeader,{|x| RTrim(x[2]) == "HIS_STA07"})

Local _oTiBrowse:= Nil

//-----------------------------
// Posiciona historico pedido |
//-----------------------------
dbSelectArea("WS2")
WS2->( dbSetOrder(1) )

//--------------------+
// Pagamento Aprovado | 
//--------------------+
If _oBrowse:aCols[_nLin][_nPSta_01] == "CHECKOK"
    If WS2->( dbSeek(xFilial("WS2") + PadR(_cNumEc,_nTNumEc) + PadR("002",_nTStatus)))
        aAdd(_aStatus,{WS2->WS2_CODSTA, FwNoAccent(Posicione("WS1", 1, xFilial("WS1") + "002","WS1_DESCRI")),dToc(ws2->WS2_DATA),WS2->WS2_HORA})
    EndIf
EndIf

//-----------------+
// Pedido liberado |
//-----------------+
If _oBrowse:aCols[_nLin][_nPSta_02] == "CHECKOK"
    WS2->( dbSeek(xFilial("WS2") + PadR(_cNumEc,_nTNumEc) + PadR("002",_nTStatus)))
    aAdd(_aStatus,{WS2->WS2_CODSTA, FwNoAccent(Posicione("WS1", 1, xFilial("WS1") + "003","WS1_DESCRI")),dToc(ws2->WS2_DATA),WS2->WS2_HORA})
EndIf

//----------------------------+
// Pedido Bloqueio de Estoque |
//----------------------------+
If _oBrowse:aCols[_nLin][_nPSta_03] == "CHECKOK"
    If WS2->( dbSeek(xFilial("WS2") + PadR(_cNumEc,_nTNumEc) + PadR("004",_nTStatus)))
        aAdd(_aStatus,{WS2->WS2_CODSTA, FwNoAccent(Posicione("WS1", 1, xFilial("WS1") + "004","WS1_DESCRI")),dToc(ws2->WS2_DATA),WS2->WS2_HORA})
    EndIf
EndIf

//----------------------+
// Liberado Faturamento |
//----------------------+
If _oBrowse:aCols[_nLin][_nPSta_04] == "CHECKOK"
    If WS2->( dbSeek(xFilial("WS2") + PadR(_cNumEc,_nTNumEc) + PadR("011",_nTStatus)))
        aAdd(_aStatus,{WS2->WS2_CODSTA, FwNoAccent(Posicione("WS1", 1, xFilial("WS1") + "011","WS1_DESCRI")),dToc(ws2->WS2_DATA),WS2->WS2_HORA})
    EndIf
EndIf

//---------------------+
// Pedido em separação |
//---------------------+
If _oBrowse:aCols[_nLin][_nPSta_05] == "CHECKOK"
    WS2->( dbSeek(xFilial("WS2") + PadR(_cNumEc,_nTNumEc) + PadR("011",_nTStatus)))
    aAdd(_aStatus,{WS2->WS2_CODSTA, FwNoAccent(Posicione("WS1", 1, xFilial("WS1") + "010","WS1_DESCRI")),dToc(ws2->WS2_DATA),WS2->WS2_HORA})
EndIf

//----------+
// Faturado |
//----------+
If _oBrowse:aCols[_nLin][_nPSta_06] == "CHECKOK"
    If WS2->( dbSeek(xFilial("WS2") + PadR(_cNumEc,_nTNumEc) + PadR("005",_nTStatus)))
        aAdd(_aStatus,{WS2->WS2_CODSTA, FwNoAccent(Posicione("WS1", 1, xFilial("WS1") + "005","WS1_DESCRI")),dToc(ws2->WS2_DATA),WS2->WS2_HORA})
    EndIf
EndIf

//------------+
// Despachado |
//------------+
If _oBrowse:aCols[_nLin][_nPSta_07] == "CHECKOK"
    If WS2->( dbSeek(xFilial("WS2") + PadR(_cNumEc,_nTNumEc) + PadR("006",_nTStatus)))
        aAdd(_aStatus,{WS2->WS2_CODSTA, FwNoAccent(Posicione("WS1", 1, xFilial("WS1") + "006","WS1_DESCRI")),dToc(ws2->WS2_DATA),WS2->WS2_HORA})
    EndIf
EndIf

//--------------------------+
// Monta HTML status pedido |
//--------------------------+
EcLoj017g(_cStatus,_aStatus,@_cHtml,@_cFileHtml)

_oTiBrowse := TWebEngine():New(_oPanel_02, 000, 000, 000, 000)
_oTiBrowse:Align := CONTROL_ALIGN_ALLCLIENT
_oTiBrowse:Navigate(_cFileHtml)

_oPanel_02:Refresh()

Return .T.

/****************************************************************************/
/*/{Protheus.doc} EcLoj017g
    @description Monta HTML do status dos pedidos
    @type  Static Function
    @author Bernard M. Margarido
    @since 17/06/2020
/*/
/****************************************************************************/
Static Function EcLoj017g(_cStatus,_aStatus,_cHtml,_cFileHtml)
Local _nHdl := 0
Local _nX   := 0

_cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
_cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'
_cHtml += '<head>'
_cHtml += '    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>'
_cHtml += '</head>'
_cHtml += '<body>'
_cHtml += '    <table align="center" style="margin: 0 auto; text-align: center" bgcolor="#FFFFFF" height="50" width="600" cellspacing="0" cellpadding="0" border="0">'
_cHtml += '        <tr>'
_cHtml += '            <td height="1px" style="border-bottom:5px solid #000000;"></td>'
_cHtml += '        </tr>'
_cHtml += '        <tr>'
_cHtml += '            <td height="3px"></td>'
_cHtml += '        </tr>'
_cHtml += '        <tr>'
_cHtml += '            <td bgcolor="#000000" height="60px"><span style=" font-size:25px; color: #FFF; font-weight:bold; font-family:Arial, Helvetica, sans-serif;">Historico Pedido</span></td>'
_cHtml += '        </tr>'
_cHtml += '        <tr>'
_cHtml += '            <td>&nbsp;</td>'
_cHtml += '        </tr>'
_cHtml += '		   <tr>'
_cHtml += '			<td>'
_cHtml += ' 			  <table width="600" border="0" cellspacing="0" cellpadding="0" style="font-family:Ubuntu, Helvetica, Arial, sans-serif; text-align: center; font-size:10px;">'
_cHtml += '				<tr>'

//---------------+
// Imagem Status |
//---------------+
For _nX := 1 To Len(_aStatus)
    _cHtml += '   					<td height="60px" align = "center"><img src="' + RTrim(GetTempPath()) + 'br_cinza_ocean.gif" style=" border:0; display: block; text-align: center;" width="15" height="15" alt="#TEXTOSTATUS#"/></td>'
Next _nX 

_cHtml += '                 </tr>'
_cHtml += ' 				<tr>'

//------------------+
// Descrição Status |
//------------------+
For _nX := 1 To Len(_aStatus)
    _cHtml += '   					<td>' +  RTrim(_aStatus[_nX][2]) + '</td>'
Next _nX 

_cHtml += '                 </tr>'
_cHtml += '				 <tr>'
_cHtml += '					<td>&nbsp;</td>'
_cHtml += '				 </tr>'
_cHtml += '				 <tr>'

//-------------+
// Data Status |
//-------------+
For _nX := 1 To Len(_aStatus)
    _cHtml += '					<td>' +  _aStatus[_nX][3] + '</td>'
Next _nX 
_cHtml += '              </tr>'
_cHtml += '				 <tr>'

//-------------+
// Hora Status |
//-------------+
For _nX := 1 To Len(_aStatus)
    _cHtml += '             <td>' +  RTrim(_aStatus[_nX][4]) + '</td>'
Next _nX 					

_cHtml += '                 </tr>'
_cHtml += '			  </table>'
_cHtml += '		   </td>'
_cHtml += '		</tr>'
_cHtml += '    </table>'
_cHtml += '</body>'
_cHtml += '</html>'

_nHdl  := fCreate(_cFileHtml)
FWrite(_nHdl, _cHtml)
FClose(_nHdl)

Return .T.

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
_cQuery += "    DTEMISSAO, " + CRLF
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
_cQuery += "		WSA.WSA_EMISSA DTEMISSAO, " + CRLF
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
_cQuery += "	GROUP BY WSA.WSA_NUMECO, WSA.WSA_CODSTA, A1.A1_NOME, WSA.WSA_EMISSA, STATUS_ECOMM.WS2_CODSTA " + CRLF
_cQuery += " )HISTORICO " + CRLF
_cQuery += " ORDER BY  DTEMISSAO " + CRLF
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
    _dDtEmissao     := dToc(sTod((_cAlias)->DTEMISSAO))

    aAdd(_aCols,Array(Len(_aHeader) + 1)) 
    _aCols[Len(_aCols)][COL_STATUS] := EcLoj017d(_cStatus)
    _aCols[Len(_aCols)][COL_PEDIDO] := _cPedido
    _aCols[Len(_aCols)][COL_CLIENTE]:= RTrim(_cCliente)
    _aCols[Len(_aCols)][COL_DTEMISS]:= _dDtEmissao
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