#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CLR_CINZA RGB(230,230,230)
#DEFINE CLR_RED RGB(200,047,053)
#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE COL_MARK    01
#DEFINE COL_STATUS  02
#DEFINE COL_IDPAY   03
#DEFINE COL_PARCELA 04
#DEFINE COL_DTEMIS  05
#DEFINE COL_DTPGTO  06
#DEFINE COL_VLRTOT  07
#DEFINE COL_VLRLIQ  08
#DEFINE COL_VLRTAX  09
#DEFINE COL_REFUND  10

#DEFINE COL_TMARK    01
#DEFINE COL_TSTATUS  02
#DEFINE COL_TITULO   03
#DEFINE COL_TPREFI   04
#DEFINE COL_TIDPAY   05
#DEFINE COL_TPARCELA 06
#DEFINE COL_TDTEMIS  07
#DEFINE COL_TDTPGTO  08
#DEFINE COL_TVLRTOT  09

/********************************************************************************************************************/
/*/{Protheus.doc} DNFINA03
    @description Tela de conciliação 
    @type  Function
    @author Bernard M. Margarido
    @since 20/07/2021
/*/
/********************************************************************************************************************/
User Function DNFINA03()
Local _aArea    := GetArea()

Private _aEcomm := {}
Private _aTitulo:= {}

//----------------------------+
// Grava dados de conciliação |
//----------------------------+
FwMsgRun(,{|| DnFinA03A()},"Aguarde...","Buscando concilações em aberto.")

//------------------+
// Tela conciliação | 
//------------------+
If Len(_aEcomm) > 0 .And. Len(_aTitulo) > 0 
    FwMsgRun(,{|| DnFinA03B()},"Aguarde...","Montando tela conciliação.")
EndIf

RestArea(_aArea)
Return Nil 

/********************************************************************************************************************/
/*/{Protheus.doc} DnFinA03A
    @description Consulta dados conciliação 
    @type  Static Function
    @author Bernard M. Margarido
    @since 20/07/2021
/*/
/********************************************************************************************************************/
Static Function DnFinA03A()
Local _cAlias   := ""
Local _cQuery   := ""

Local _nPosEc   := 0
Local _nPosTit  := 0

_cQuery := " SELECT " + CRLF
_cQuery += "	ID_PAY, " + CRLF
_cQuery += "	DT_EMISS, " + CRLF
_cQuery += "	DT_PGTO, " + CRLF
_cQuery += "	PARCELA, " + CRLF
_cQuery += "	VALOR_TOTAL, " + CRLF
_cQuery += "	VALOR_LIQUIDO, " + CRLF
_cQuery += "	VALOR_TAXA, " + CRLF
_cQuery += "	VALOR_REEMBOLSO, " + CRLF
_cQuery += "	TITULO, " + CRLF
_cQuery += "	PREFIXO, " + CRLF
_cQuery += "	ID_PAY_TITULO, " + CRLF
_cQuery += "	DT_EMISS_TITULO, " + CRLF
_cQuery += "	DT_PGTO_TITULO, " + CRLF
_cQuery += "	PARCELA_TITULO, " + CRLF
_cQuery += "	VALOR_TOTAL_TITULO, " + CRLF
_cQuery += "    CASE " + CRLF
_cQuery += "		WHEN ( ( VALOR_TOTAL - VALOR_TOTAL_TITULO ) < -0.05  AND ( VALOR_TOTAL - VALOR_TOTAL_TITULO ) < 0 )   THEN " + CRLF
_cQuery += "			'2' " + CRLF
_cQuery += "		WHEN ( ( VALOR_TOTAL - VALOR_TOTAL_TITULO ) > 0.05 ) THEN " + CRLF
_cQuery += "			'2' " + CRLF
_cQuery += "		ELSE " + CRLF
_cQuery += "			'1' " + CRLF
_cQuery += "	END STATUS " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += " ( " + CRLF
_cQuery += "	SELECT " + CRLF
_cQuery += "		XTA.XTA_IDPAY ID_PAY, " + CRLF
_cQuery += "		XTA.XTA_DTEMIS DT_EMISS, " + CRLF
_cQuery += "		XTA.XTA_DTPGTO DT_PGTO, " + CRLF
_cQuery += "		XTA.XTA_PARC PARCELA, " + CRLF
_cQuery += "		XTA.XTA_VALOR VALOR_TOTAL, " + CRLF
_cQuery += "		XTA.XTA_VLRLIQ VALOR_LIQUIDO, " + CRLF
_cQuery += "		XTA.XTA_TAXA VALOR_TAXA, " + CRLF
_cQuery += "		XTA.XTA_VLRREB VALOR_REEMBOLSO, " + CRLF
_cQuery += "		COALESCE(E1.E1_NUM,'') TITULO, " + CRLF
_cQuery += "		COALESCE(E1.E1_PREFIXO,'') PREFIXO, " + CRLF
_cQuery += "		COALESCE(E1.E1_XTID,'') ID_PAY_TITULO, " + CRLF
_cQuery += "		COALESCE(E1.E1_EMISSAO,'') DT_EMISS_TITULO, " + CRLF
_cQuery += "		COALESCE(E1.E1_VENCREA,'') DT_PGTO_TITULO, " + CRLF
_cQuery += "		COALESCE(E1.E1_PARCELA,'') PARCELA_TITULO, " + CRLF
_cQuery += "		COALESCE(E1.E1_VALOR,0) VALOR_TOTAL_TITULO " + CRLF
_cQuery += "	FROM " + CRLF
_cQuery += "		XTA010 XTA " + CRLF 
_cQuery += "		INNER JOIN SE1010 E1 ON E1.E1_FILORIG = XTA.XTA_FILIAL AND E1.E1_PARCELA = XTA.XTA_PARC AND E1.E1_XTID = XTA.XTA_IDPAY AND E1.E1_BAIXA = '' AND E1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	WHERE " + CRLF
_cQuery += "		XTA.XTA_FILIAL = '" + xFilial("XTA") + "' AND " + CRLF
_cQuery += "		XTA.XTA_STATUS = '1' AND " + CRLF
_cQuery += "		XTA.D_E_L_E_T_ = ''	" + CRLF
_cQuery += " )ID_PAGAMENTO " + CRLF
_cQuery += " GROUP BY ID_PAY,DT_EMISS,DT_PGTO,PARCELA,VALOR_TOTAL,VALOR_LIQUIDO,VALOR_TAXA,VALOR_REEMBOLSO,TITULO,PREFIXO,ID_PAY_TITULO,DT_EMISS_TITULO,DT_PGTO_TITULO,PARCELA_TITULO,VALOR_TOTAL_TITULO " + CRLF
_cQuery += " ORDER BY DT_EMISS, ID_PAY "

_cAlias := MPSysOpenQuery(_cQuery)

While (_cAlias)->( !Eof() )
    //------------------------+
    // Array titulo ecommerce |
    //------------------------+
    If (_nPosEc := aScan(_aEcomm,{|x| RTrim(x[COL_IDPAY]) + RTrim(x[COL_PARCELA]) == (_cAlias)->ID_PAY + (_cAlias)->PARCELA}) ) > 0
        If (_cAlias)->VALOR_TOTAL > 0 
            _aEcomm[_nPosEc][COL_VLRTOT] := (_cAlias)->VALOR_TOTAL
        ElseIf (_cAlias)->VALOR_REEMBOLSO > 0 
            _aEcomm[_nPosEc][COL_REFUND] := VALOR_REEMBOLSO
        EndIf
    Else
        aAdd(_aEcomm,Array(10))
        _aEcomm[Len(_aEcomm)][COL_MARK]     := "LBNO"
        _aEcomm[Len(_aEcomm)][COL_STATUS]   := (_cAlias)->STATUS
        _aEcomm[Len(_aEcomm)][COL_IDPAY]    := (_cAlias)->ID_PAY
        _aEcomm[Len(_aEcomm)][COL_PARCELA]  := (_cAlias)->PARCELA
        _aEcomm[Len(_aEcomm)][COL_DTEMIS]   := dToc(sTod((_cAlias)->DT_EMISS))
        _aEcomm[Len(_aEcomm)][COL_DTPGTO]   := dToc(sTod((_cAlias)->DT_PGTO))
        _aEcomm[Len(_aEcomm)][COL_VLRTOT]   := (_cAlias)->VALOR_TOTAL
        _aEcomm[Len(_aEcomm)][COL_VLRLIQ]   := (_cAlias)->VALOR_LIQUIDO
        _aEcomm[Len(_aEcomm)][COL_VLRTAX]   := (_cAlias)->VALOR_TAXA
        _aEcomm[Len(_aEcomm)][COL_REFUND]   := (_cAlias)->VALOR_REEMBOLSO
    EndIf

    //-----------------------+
    // Array Titulo Protheus |
    //-----------------------+
    If (_nPosTit := aScan(_aTitulo,{|x| RTrim(x[COL_TIDPAY]) + RTrim(x[COL_TPARCELA]) == (_cAlias)->ID_PAY_TITULO + (_cAlias)->PARCELA_TITULO}) ) == 0
        aAdd(_aTitulo,Array(9))
        _aTitulo[Len(_aTitulo)][COL_TMARK]      := "LBNO"
        _aTitulo[Len(_aTitulo)][COL_TSTATUS]    := (_cAlias)->STATUS
        _aTitulo[Len(_aTitulo)][COL_TITULO]     := (_cAlias)->TITULO
        _aTitulo[Len(_aTitulo)][COL_TPREFI]     := (_cAlias)->PREFIXO
        _aTitulo[Len(_aTitulo)][COL_TIDPAY]     := (_cAlias)->ID_PAY_TITULO
        _aTitulo[Len(_aTitulo)][COL_TPARCELA]   := (_cAlias)->PARCELA_TITULO    
        _aTitulo[Len(_aTitulo)][COL_TDTEMIS]    := dToc(sTod((_cAlias)->DT_EMISS))
        _aTitulo[Len(_aTitulo)][COL_TDTPGTO]    := dToc(sTod((_cAlias)->DT_EMISS))
        _aTitulo[Len(_aTitulo)][COL_TVLRTOT]    := (_cAlias)->VALOR_TOTAL_TITULO
    EndIf

    (_cAlias)->( dbSkip() ) 
EndDo

(_cAlias)->( dbCloseArea() ) 

Return Nil 

/********************************************************************************************************************/
/*/{Protheus.doc} DnFinA03B
    @description Monta Tela conciliação bancária 
    @type  Static Function
    @author Bernard M. Margarido
    @since 20/07/2021
/*/
/********************************************************************************************************************/
Static Function DnFinA03B()
Local _cTitulo      := "Conciliação pagamentos e-Commerce"
Local _cMsgChk      := "Marca ou desmarca todos os titulos de concliação."
Local _nLinIni      := 0
Local _nColIni      := 0
Local _nLinFin      := 0
Local _nColFin      := 0
Local _nTotal       := 0
Local _nCount       := 0

Local _lTodos       := .F.

Local _aCoors   	:= FWGetDialogSize( oMainWnd )

Local _bChkMark		:= {|| IIF(_lTodos,(DnFinA03F(.T.,@_nTotal,@_nCount,@_oSay_02,@_oSay_04),_oChkMark:Refresh()),(DnFinA03F(.F.,@_nTotal,@_nCount,@_oSay_02,@_oSay_04),_oChkMark:Refresh())) }

Local _oSize    	:= FWDefSize():New(.T.)
Local _oLayer       := FWLayer():New()
Local _oFont12      := TFont():New('Arial Black',,-12,.T.)
Local _oDlg     	:= Nil
Local _oChkMark     := Nil 
Local _oSay_01      := Nil 
Local _oSay_02      := Nil 
Local _oSay_03      := Nil 
Local _oSay_04      := Nil 
Local _oPanel_01    := Nil 
Local _oPanel_02    := Nil 
Local _oBtnOk       := Nil 
Local _oBtnSair     := Nil 

Private _oBrowseA  := Nil 
Private _oBrowseB  := Nil 

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	 := .T.
_oSize:Process()

//--------------------------------------------------------+
// 0 - Nenhum alinhamento (default) - CONTROL_ALIGN_NONE  |
// 1 - À esquerda - CONTROL_ALIGN_LEFT                    |
// 2 - À direita - CONTROL_ALIGN_RIGHT                    |
// 3 - No topo - CONTROL_ALIGN_TOP                        |
// 4 - No rodapé - CONTROL_ALIGN_BOTTOM                   |
// 5 - Em todo o parent - CONTROL_ALIGN_ALLCLIENT         |
//--------------------------------------------------------+

//------------------------+
// Monta Dialog principal |
//------------------------+
_oDlg := MsDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2], _oSize:aWindSize[3], _oSize:aWindSize[4], _cTitulo,,,,DS_MODALFRAME,,,,,.T.)

	_nLinIni := _oSize:GetDimension("DLG","LININI")
	_nColIni := _oSize:GetDimension("DLG","COLINI")
	_nLinFin := _oSize:GetDimension("DLG","LINEND")
	_nColFin := _oSize:GetDimension("DLG","COLEND")
	
	//-------------------------+
	// Painel para informações | 
	//-------------------------+
	_oPanel_01 := TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,CLR_CINZA,000,_nLinFin - 035,.T.,.F.)
	_oPanel_01:Align := 3

    _oLayer:Init( _oPanel_01, .F. )
    _oLayer:AddLine( "LINE01", 100 )

    _oLayer:AddCollumn( "COLLL01"  , 050,, "LINE01" )
    _oLayer:AddCollumn( "COLLL02"  , 050,, "LINE01" )

    _oLayer:AddWindow( "COLLL01" , "WNDECOM"  , "Titulos PagarMe"     , 100 ,.F. ,,,"LINE01" )
    _oLayer:AddWindow( "COLLL02" , "WNDTITU"  , "Titulos Protheus"     , 100 ,.F. ,,,"LINE01" )

    _oTEcom  := _oLayer:GetWinPanel( "COLLL01"   , "WNDECOM"  , "LINE01" )
    _oTTitul := _oLayer:GetWinPanel( "COLLL02"   , "WNDTITU"  , "LINE01" )

    //---------------------+
    // Cria Grid eCommerce |
    //---------------------+
    DnFinA03C(@_oBrowseA,@_nTotal,@_nCount,_oTEcom,@_oSay_02,@_oSay_04)

    //--------------------+
    // Cria Grid Protheus |
    //--------------------+
    DnFinA03D(@_oBrowseB,@_nTotal,@_nCount,_oTTitul,@_oSay_02,@_oSay_04)

    //-----------------------+
	// Painel para os Botoes | 
	//-----------------------+
    _oPanel_02 := TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,CLR_CINZA,000,030,.T.,.F.)
	_oPanel_02:Align := 4

    //------------------+    
    // Marcar/Desmarcar |
    //------------------+
    _oChkMark	:= TCheckBox():New(_nLinIni - 22,_nColIni ,"Marcar/Desmarcar"	,{|l| IIF( PCount() > 0, _lTodos := l, _lTodos) },_oPanel_02,080,040,,_bChkMark,_oFont12,,,,,.T.,_cMsgChk,,)

    //---------------+
    // Total marcado |
    //---------------+
    _oSay_01 := TSay():New(_nLinIni - 28, _nColIni + 480 , {|| "Total Marcado" }, _oPanel_02,, _oFont12,,,, .T. ,,CLR_CINZA, 080, 010,,,,,,.T.)
    _oSay_01:SetTextAlign(0,0)

    _oSay_02 := TSay():New(_nLinIni - 16, _nColIni + 480 , {|| cValToChar(_nCount) }, _oPanel_02,, _oFont12,,,, .T. ,CLR_RED,CLR_CINZA, 080, 010,,,,,,.T.)
    _oSay_02:SetTextAlign(0,0)

    _oSay_03 := TSay():New(_nLinIni - 28, _nColIni + 570 , {|| "Valor Total Marcado" }, _oPanel_02,, _oFont12,,,, .T. ,,CLR_CINZA, 080, 010,,,,,,.T.)
    _oSay_03:SetTextAlign(0,0)

    _oSay_04 := TSay():New(_nLinIni - 16, _nColIni + 570 , {|| Transform(_nTotal,PesqPict("SE1","E1_VALOR")) }, _oPanel_02,, _oFont12,,,, .T. ,CLR_RED,CLR_CINZA, 080, 010,,,,,,.T.)
    _oSay_04:SetTextAlign(0,0)

    //--------+
    // Botoes |
    //--------+
    _oBtnOk     := TButton():New( _nLinIni - 26, _nColFin - 100, "Confirmar", _oPanel_02,{|| FwMsgRun(,{|_oSay| DnFinA03G(_oSay) },"Aguarde...","Processando conciliação")}	, 045,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtnSair   := TButton():New( _nLinIni - 26, _nColFin - 050, "Sair", _oPanel_02,{|| _oDlg:End() }	, 045,015,,,.F.,.T.,.F.,,.F.,,,.F. )

    _oDlg:lEscClose := .F.    
    _oDlg:lCentered := .T.

_oDlg:Activate(,,,.T.,,,)
Return Nil 

/********************************************************************************************************************/
/*/{Protheus.doc} DnFinA03C
    @description Cria GRID com os dados dos titulos e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 21/07/2021
/*/
/********************************************************************************************************************/
Static Function DnFinA03C(_oBrowseA,_nTotal,_nCount,_oTEcom,_oSay_02,_oSay_04)
Local _aSeek 	:= {}

//------------------+
// Busca no browser |
//------------------+
aAdd( 	_aSeek, 	{ AllTrim("ID Pay")				,{{"","C",TamSx3("XTA_IDPAY")[1],0                      ,"ID Pay"		, PesqPict("XTA","XTA_IDPAY")}}})
aAdd( 	_aSeek, 	{ AllTrim("Dt. Emissao")		,{{"","D",TamSx3("XTA_DTEMIS")[1],0     	            ,"Dt. Emissao"	, PesqPict("XTA","XTA_DTEMIS")}}})
aAdd( 	_aSeek, 	{ AllTrim("Valor")		        ,{{"","N",TamSx3("XTA_VALOR")[1],TamSx3("XTA_VALOR")[2] ,"Valor"		, PesqPict("XTA","XTA_VALOR")}}})

//--------------+
// Cria browser |
//--------------+
_oBrowseA := FWBrowse():New(_oTEcom)
_oBrowseA:AddMarkColumns( {|| IIF( _aEcomm[_oBrowseA:At()][COL_MARK] == "LBOK" , "LBOK", "LBNO")}, {|| DnFinA03E(_oBrowseA,@_oSay_02,@_oSay_04,@_nTotal,@_nCount,_aEcomm,1,1) }, {|| DnFinA03E(_oBrowseA,@_oSay_02,@_oSay_04,@_nTotal,@_nCount,_aEcomm,2,1) })
_oBrowseA:AddLegend({|| _aEcomm[_oBrowseA:At()][COL_STATUS] == '1'}, "GREEN"	, "Título encontrado")
_oBrowseA:AddLegend({|| _aEcomm[_oBrowseA:At()][COL_STATUS] == '2'}, "YELLOW"	, "Título encontrado com divergencia")
_oBrowseA:AddLegend({|| _aEcomm[_oBrowseA:At()][COL_STATUS] == '3'}, "RED"	    , "Título não encontrado")
_oBrowseA:DisableConfig()
_oBrowseA:DisableReport()
_oBrowseA:SetDataArray()
_oBrowseA:SetSeek(,_aSeek)
_oBrowseA:SetArray(_aEcomm)
//_oBrowseA:SetUseFilter()
//_oBrowseA:SetDoubleClick({|| LiFatC01J(_oBrowseA) })

//--------------+
// Cria colunas |
//--------------+
_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aEcomm[_oBrowseA:At()][COL_IDPAY]})
_oColumns:SetTitle(RetTitle("XTA_IDPAY"))
_oColumns:SetSize(TamSx3("XTA_IDPAY")[1])
_oColumns:SetDecimal(TamSx3("XTA_IDPAY")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_IDPAY"))
_oBrowseA:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aEcomm[_oBrowseA:At()][COL_PARCELA]})
_oColumns:SetTitle(RetTitle("XTA_PARC"))
_oColumns:SetSize(TamSx3("XTA_PARC")[1])
_oColumns:SetDecimal(TamSx3("XTA_PARC")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_PARC"))
_oBrowseA:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aEcomm[_oBrowseA:At()][COL_DTEMIS]})
_oColumns:SetTitle(RetTitle("XTA_DTEMIS"))
_oColumns:SetSize(TamSx3("XTA_DTEMIS")[1])
_oColumns:SetDecimal(TamSx3("XTA_DTEMIS")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_DTEMIS"))
_oBrowseA:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aEcomm[_oBrowseA:At()][COL_DTPGTO]})
_oColumns:SetTitle(RetTitle("XTA_DTPGTO"))
_oColumns:SetSize(TamSx3("XTA_DTPGTO")[1])
_oColumns:SetDecimal(TamSx3("XTA_DTPGTO")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_DTPGTO"))
_oBrowseA:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aEcomm[_oBrowseA:At()][COL_VLRTOT]})
_oColumns:SetTitle(RetTitle("XTA_VALOR"))
_oColumns:SetSize(TamSx3("XTA_VALOR")[1])
_oColumns:SetDecimal(TamSx3("XTA_VALOR")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_VALOR"))
_oBrowseA:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aEcomm[_oBrowseA:At()][COL_VLRLIQ]})
_oColumns:SetTitle(RetTitle("XTA_VLRLIQ"))
_oColumns:SetSize(TamSx3("XTA_VLRLIQ")[1])
_oColumns:SetDecimal(TamSx3("XTA_VLRLIQ")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_VLRLIQ"))
_oBrowseA:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aEcomm[_oBrowseA:At()][COL_VLRTAX]})
_oColumns:SetTitle(RetTitle("XTA_TAXA"))
_oColumns:SetSize(TamSx3("XTA_TAXA")[1])
_oColumns:SetDecimal(TamSx3("XTA_TAXA")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_TAXA"))
_oBrowseA:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aEcomm[_oBrowseA:At()][COL_REFUND]})
_oColumns:SetTitle(RetTitle("XTA_VLRREB"))
_oColumns:SetSize(TamSx3("XTA_VLRREB")[1])
_oColumns:SetDecimal(TamSx3("XTA_VLRREB")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_VLRREB"))
_oBrowseA:SetColumns({_oColumns})

//_oBrowseA:SetEditCell(.T., {|| LiFatC01E(_oBrowseA,_oBrowseA:At()) })
_oBrowseA:SetLineHeight( 20 )
_oBrowseA:DeActivate()
_oBrowseA:Activate()
_oBrowseA:Refresh()

Return Nil 

/********************************************************************************************************************/
/*/{Protheus.doc} DnFinA03C
    @description Cria GRID com os dados dos titulos e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 21/07/2021
/*/
/********************************************************************************************************************/
Static Function DnFinA03D(_oBrowseB,_nTotal,_nCount,_oTTitul,_oSay_02,_oSay_04)
Local _aSeek 	:= {}

//------------------+
// Busca no browser |
//------------------+
aAdd( 	_aSeek, 	{ AllTrim("Titulo")				,{{"","C",TamSx3("E1_NUM")[1],0                         ,"Titulo"		, PesqPict("SE1","E1_NUM")}}})
aAdd( 	_aSeek, 	{ AllTrim("ID Pay")				,{{"","C",TamSx3("XTA_IDPAY")[1],0                      ,"ID Pay"		, PesqPict("XTA","XTA_IDPAY")}}})
aAdd( 	_aSeek, 	{ AllTrim("Dt. Emissao")		,{{"","D",TamSx3("XTA_DTEMIS")[1],0     	            ,"Dt. Emissao"	, PesqPict("XTA","XTA_DTEMIS")}}})
aAdd( 	_aSeek, 	{ AllTrim("Valor")		        ,{{"","N",TamSx3("XTA_VALOR")[1],TamSx3("XTA_VALOR")[2] ,"Valor"		, PesqPict("XTA","XTA_VALOR")}}})

//--------------+
// Cria browser |
//--------------+
_oBrowseB := FWBrowse():New(_oTTitul)                                                                              
_oBrowseB:AddMarkColumns( {|| IIF( _aTitulo[_oBrowseB:At()][COL_TMARK] == "LBOK" , "LBOK", "LBNO")}, {|| DnFinA03E(_oBrowseB,@_oSay_02,@_oSay_04,@_nTotal,@_nCount,_aTitulo,1,2) }, {|| DnFinA03E(_oBrowseB,@_oSay_02,@_oSay_04,@_nTotal,@_nCount,_aTitulo,2,2) })
_oBrowseB:AddLegend({|| _aTitulo[_oBrowseB:At()][COL_TSTATUS] == '1'}, "GREEN"	, "Título encontrado")
_oBrowseB:AddLegend({|| _aTitulo[_oBrowseB:At()][COL_TSTATUS] == '2'}, "YELLOW"	, "Título encontrado com divergencia")
_oBrowseB:AddLegend({|| _aTitulo[_oBrowseB:At()][COL_TSTATUS] == '3'}, "RED"	, "Título não encontrado")
_oBrowseB:DisableConfig()
_oBrowseB:DisableReport()
_oBrowseB:SetDataArray()
_oBrowseB:SetSeek(,_aSeek)
_oBrowseB:SetArray(_aTitulo)
//_oBrowseB:SetUseFilter()
//_oBrowseA:SetDoubleClick({|| LiFatC01J(_oBrowseA) })

//--------------+
// Cria colunas |
//--------------+
_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aTitulo[_oBrowseB:At()][COL_TITULO]})
_oColumns:SetTitle(RetTitle("E1_NUM"))
_oColumns:SetSize(TamSx3("E1_NUM")[1])
_oColumns:SetDecimal(TamSx3("E1_NUM")[2])
_oColumns:SetPicture(PesqPict("SE1","E1_NUM"))
_oBrowseB:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aTitulo[_oBrowseB:At()][COL_TPREFI]})
_oColumns:SetTitle(RetTitle("E1_PREFIXO"))
_oColumns:SetSize(TamSx3("E1_PREFIXO")[1])
_oColumns:SetDecimal(TamSx3("E1_PREFIXO")[2])
_oColumns:SetPicture(PesqPict("SE1","E1_PREFIXO"))
_oBrowseB:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aTitulo[_oBrowseB:At()][COL_TIDPAY]})
_oColumns:SetTitle(RetTitle("XTA_IDPAY"))
_oColumns:SetSize(TamSx3("XTA_IDPAY")[1])
_oColumns:SetDecimal(TamSx3("XTA_IDPAY")[2])
_oColumns:SetPicture(PesqPict("XTA","XTA_IDPAY"))
_oBrowseB:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aTitulo[_oBrowseB:At()][COL_TPARCELA]})
_oColumns:SetTitle(RetTitle("E1_PARCELA"))
_oColumns:SetSize(TamSx3("E1_PARCELA")[1])
_oColumns:SetDecimal(TamSx3("E1_PARCELA")[2])
_oColumns:SetPicture(PesqPict("SE1","E1_PARCELA"))
_oBrowseB:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aTitulo[_oBrowseB:At()][COL_TDTEMIS]})
_oColumns:SetTitle(RetTitle("E1_EMISSAO"))
_oColumns:SetSize(TamSx3("E1_EMISSAO")[1])
_oColumns:SetDecimal(TamSx3("E1_EMISSAO")[2])
_oColumns:SetPicture(PesqPict("SE1","E1_EMISSAO"))
_oBrowseB:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aTitulo[_oBrowseB:At()][COL_TDTPGTO]})
_oColumns:SetTitle(RetTitle("E1_VENCREA"))
_oColumns:SetSize(TamSx3("E1_VENCREA")[1])
_oColumns:SetDecimal(TamSx3("E1_VENCREA")[2])
_oColumns:SetPicture(PesqPict("SE1","E1_VENCREA"))
_oBrowseB:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aTitulo[_oBrowseB:At()][COL_TVLRTOT]})
_oColumns:SetTitle(RetTitle("E1_VALOR"))
_oColumns:SetSize(TamSx3("E1_VALOR")[1])
_oColumns:SetDecimal(TamSx3("E1_VALOR")[2])
_oColumns:SetPicture(PesqPict("SE1","E1_VALOR"))
_oBrowseB:SetColumns({_oColumns})

//_oBrowseA:SetEditCell(.T., {|| LiFatC01E(_oBrowseA,_oBrowseA:At()) })
_oBrowseB:SetLineHeight( 20 )
_oBrowseB:DeActivate()
_oBrowseB:Activate()
_oBrowseB:Refresh()

Return Nil 

/*********************************************************************************/
/*/{Protheus.doc} DnFinA03E
    @description Marca titulos aprovados
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/03/2021
/*/
/*********************************************************************************/
Static Function DnFinA03E(_oBrowse,_oSay_02,_oSay_04,_nTotal,_nCount,_aArray,_nMark,_nGrid)
Local _nPos     := 0
Local _nLin     := _oBrowse:nAt
Local _nIDPay   := IIF(_nGrid == 1,COL_TIDPAY,COL_IDPAY)
Local _nParcela := IIF(_nGrid == 1,COL_TPARCELA,COL_PARCELA)
Local _nValor   := IIF(_nGrid == 1,COL_VLRTOT,COL_TVLRTOT)
Local _nColMark := IIF(_nGrid == 1,COL_MARK,COL_TMARK)

If _nMark == 1
    //------------------------------------+
    // Valida se tem linha marcada        |
    // permite marcar somente um registro | 
    //------------------------------------+
    If _aArray[_nLin][_nColMark] == "LBNO"
        _aArray[_nLin][_nColMark] := "LBOK"
        _nTotal += _aArray[_nLin][_nValor]
        _nCount++
    ElseIf _aArray[_nLin][_nColMark] == "LBOK"
        _aArray[_nLin][_nColMark] := "LBNO"
        _nTotal -= _aArray[_nLin][_nValor]
        _nCount--  
    EndIf

    If _nGrid == 1
        //----------------------+
        // Marca o mesmo titulo |
        //----------------------+    
        If (_nPos := aScan(_aTitulo,{|x| RTrim(x[_nIDPay]) + RTrim(x[_nParcela]) == RTrim(_aArray[_nLin][COL_IDPAY]) + RTrim(_aArray[_nLin][COL_PARCELA]) }) ) > 0
            If _aTitulo[_nPos][_nColMark] == "LBNO"
                _aTitulo[_nPos][_nColMark] := "LBOK"
            ElseIf _aTitulo[_nLin][_nColMark] == "LBOK"
                _aTitulo[_nLin][_nColMark] := "LBNO"  
            EndIf
        EndIf

        //------------------+
        // Atualiza Browser |
        //------------------+
        _oBrowseB:Refresh()

    Else 

        //----------------------+
        // Marca o mesmo titulo |
        //----------------------+    
        If (_nPos := aScan(_aEcomm,{|x| RTrim(x[_nIDPay]) + RTrim(x[_nParcela]) == RTrim(_aArray[_nLin][COL_TIDPAY]) + RTrim(_aArray[_nLin][COL_TPARCELA]) }) ) > 0
            If _aEcomm[_nPos][_nColMark] == "LBNO"
                _aEcomm[_nPos][_nColMark] := "LBOK"
            ElseIf _aEcomm[_nLin][_nColMark] == "LBOK"
                _aEcomm[_nLin][_nColMark] := "LBNO"  
            EndIf
        EndIf

        //------------------+
        // Atualiza Browser |
        //------------------+
        _oBrowseA:Refresh()

    EndIf
EndIf

//------------------+
// Atualiza Browser |
//------------------+
_oBrowse:Refresh()

If ValType(_oSay_02) == "O" 
    _oSay_02:Refresh()
    _oSay_04:Refresh()
EndIf

Return .T.

/*********************************************************************************/
/*/{Protheus.doc} DnFinA03F
    @description Marca ou desmarca todos os titulos 
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/03/2021
/*/
/*********************************************************************************/
Static Function DnFinA03F(_lMark,_nTotal,_nCount,_oSay_02,_oSay_04)
Local _nX   := 1

_nTotal     := 0 
_nCount     := 0

For _nX := 1 To Len(_aEcomm)
    _aEcomm[_nX][COL_MARK]  := IIF(_lMark,"LBOK","LBNO")
    If _lMark
        _nTotal += _aEcomm[_nX][COL_VLRTOT]
        _nCount++
    EndIf
Next _nX 

For _nX := 1 To Len(_aTitulo)
    _aTitulo[_nX][COL_TMARK]  := IIF(_lMark,"LBOK","LBNO")
    If _lMark
        _nTotal += _aEcomm[_nX][COL_VLRTOT]
        _nCount++
    EndIf
Next _nX 

_oBrowseA:Refresh()
_oBrowseB:Refresh()

If ValType(_oSay_02) == "O" 
    _oSay_02:Refresh()
    _oSay_04:Refresh()
EndIf

Return Nil 

/*********************************************************************************/
/*/{Protheus.doc} DnFinA03G
    @description Realiza a baixa dos titulos eCommerce 
    @type  Static Function
    @author Bernard M. Margarido
    @since 22/07/2021
/*/
/*********************************************************************************/
Static Function DnFinA03G(_oSay)
Local _nX       := 0
Local _nValFat  := 0

Local _aArea    := GetArea()
Local _aBaixa   := {}

If !MsgYesNo("Confirma a conciliação dos pagametos marcados ?","Dana - Avisos!")
    RestArea(_aArea)
    Return .F.
EndIf 

//-------------------------------------+
// Orderna somente os titulos marcados |
//-------------------------------------+
_aTitulo := aSort(_aTitulo,,,{|x,y| x[1] > y[1]})
For _nX := 1 To Len(_aTitulo)
    If _aTitulo[_nX][COL_TMARK] == "LBOK"
        //-----------------------+
        // Cria Array para baixa | 
        //-----------------------+
        _nVlrTaxa := 0
        If ( _nPos := aScan(_aEcomm,{|x| RTrim(x[COL_IDPAY]) == RTrim(_aTitulo[_nX][COL_TIDPAY]) }) ) > 0
            _nVlrTaxa := _aEcomm[_nPos][COL_VLRTAX]
        EndIf
        aAdd(_aBaixa,{_aTitulo[_nX][COL_TITULO],_aTitulo[_nX][COL_TPREFI],_aTitulo[_nX][COL_TPARCELA],_aTitulo[_nX][COL_TVLRTOT],_nVlrTaxa})
    EndIf
Next _nX 

//-----------------------------+
// Realiza a baixa dos titulos |
//-----------------------------+
If Len(_aBaixa) > 0
    //------------------------------+
    // Cria fatura de transferencia |
    //------------------------------+
    DnFinA03H(_aBaixa,@_nValFat,@_oSay)
EndIf


RestArea(_aArea)
Return Nil

/*********************************************************************************/
/*/{Protheus.doc} DnFinA03H
    @description Realiza a baixa dos titulos eCommerce 
    @type  Static Function
    @author Bernard M. Margarido
    @since 22/07/2021
/*/
/*********************************************************************************/
Static Function DnFinA03H(_aBaixa,_nValFat,_oSay)
Local _aArea    := GetArea()

Private lAutoErrNoFile  := .T.
Private lMsErroAuto     := .F.





RestArea(_aArea)
Return Nil 