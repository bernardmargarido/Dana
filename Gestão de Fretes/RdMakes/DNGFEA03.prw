#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE COL_MARK   01  
#DEFINE COL_NOTA   02  
#DEFINE COL_SERIE  03  
#DEFINE COL_DESTI  04
#DEFINE COL_NDEST  05
#DEFINE COL_DTEMIS 06

#DEFINE CRLF        CHR(13) + CHR(10)

/*******************************************************************************/
/*/{Protheus.doc} DNGFEA03
    @description Realiza o reenvio do workflow de agendamento
    @type  Function
    @author Bernard M Margarido
    @since 31/07/2022
    @version version
/*/
/*******************************************************************************/
User Function DNGFEA03()
Local _aParamBox    := {}
Local _aRet         := {}

Local _lAtvAgen     := GetNewPar("DN_ATVAGEN",.F.)

Local _oSay         := Nil 

Private _cRomaneio  := ""
Private _aRomaneio  := {}

If _lAtvAgen

    aAdd(_aParamBox,{1, "Romaneio?"        , Space(TamSx3("GW1_NRROM")[1])   , PesqPict("GW1","GW1_NRROM")       , "", "GWN"   , "", 80     , .F.})

    //-------------------+
    // Parametros rotina |
    //-------------------+
    If ParamBox(_aParamBox,"Reenvio de Agendamento",@_aRet,,,,,,,,.T.)

        _cRomaneio  := mv_par01

        
        FwMsgRun(,{|_oSay| DnGfeA03A(_oSay)},"Aguarde...","Consultando romaneio...")

        If Len(_aRomaneio) > 0 
            FwMsgRun(,{|_oSay| DnGfeA03B(_oSay)},"Aguarde...","Montando tela...")
        EndIf 

    EndIf
Else 
    MsgStop("Rotina de agendamento não está ativada, favor ativar rotina pelo parametro DN_ATVAGEN", "Dana - Avisos")
EndIf 
Return Nil 

/*******************************************************************************/
/*/{Protheus.doc} DnGfeA03A
    @description Consulta romaneio 
    @type  Static Function
    @author Bernard M Margarido
    @since 31/07/2022
    @version version
/*/
/*******************************************************************************/
Static Function DnGfeA03A(_oSay)
Local _cAlias := ""
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "    GW1.GW1_NRROM, " + CRLF
_cQuery += "	GW1.GW1_NRDC, " + CRLF
_cQuery += "    GW1.GW1_SERDC, " + CRLF
_cQuery += "    GW1.GW1_CDDEST, " + CRLF
_cQuery += "    GU3.GU3_NMEMIT, " + CRLF
_cQuery += "    GW1.GW1_DTEMIS " + CRLF
_cQuery += " FROM " + CRLF 
_cQuery += "	GW1010 (NOLOCK) GW1 " + CRLF
_cQuery += "    LEFT JOIN GU3010 GU3 (NOLOCK) ON GU3.GU3_FILIAL = '' AND GU3.GU3_CDEMIT = GW1.GW1_CDDEST AND GU3.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	GW1.GW1_FILIAL = '" + xFilial("GW1") + "' AND " + CRLF
_cQuery += "	GW1.GW1_NRROM = '" + _cRomaneio + "' AND " + CRLF
_cQuery += "	GW1.GW1_XDTAGE = '' AND " + CRLF
_cQuery += "	GW1.D_E_L_E_T_ = '' "

//----------------------+
// Efetiva consulta SQL | 
//----------------------+
_cAlias := MPSysOpenQuery(_cQuery) 

While (_cAlias)->( !Eof() )

    _oSay:cCaption  := "Adicionando documentos romaneio " + RTrim((_cAlias)->GW1_NRROM) + " " + RTrim((_cAlias)->GW1_NRDC) + " " + RTrim((_cAlias)->GW1_SERDC) + " ."

    aAdd(_aRomaneio,Array(6))
    _aRomaneio[Len(_aRomaneio)][COL_MARK]    := "LBNO"
    _aRomaneio[Len(_aRomaneio)][COL_NOTA]    := (_cAlias)->GW1_NRDC
    _aRomaneio[Len(_aRomaneio)][COL_SERIE]   := (_cAlias)->GW1_SERDC
    _aRomaneio[Len(_aRomaneio)][COL_DESTI]   := (_cAlias)->GW1_CDDEST
    _aRomaneio[Len(_aRomaneio)][COL_NDEST]   := (_cAlias)->GU3_NMEMIT
    _aRomaneio[Len(_aRomaneio)][COL_DTEMIS]  := dToC(sTod((_cAlias)->GW1_DTEMIS))
    
    (_cAlias)->( dbSkip() )        
EndDo

(_cAlias)->( dbCloseArea() )

Return Nil 

/*******************************************************************************/
/*/{Protheus.doc} DnGfeA03B
    @description Consulta romaneio para reenvio de agendamento
    @type  Static Function
    @author Bernard M Margarido
    @since 31/07/2022
    @version version
/*/
/*******************************************************************************/
Static Function DnGfeA03B(_oSay)
Local _aArea        := GetArea()
Local _cTitulo      := "Reenvio de Agendamento"
Local _cMsgChk      := "Marca ou desmarca todos os documentos."
Local _cMsg         := ""
Local _cMsgErro     := ""

Local _nLinIni      := 0
Local _nColIni      := 0
Local _nLinFin      := 0
Local _nColFin      := 0
Local _nOpcA        := 0
Local _nX           := 0

Local _aCoors   	:= FWGetDialogSize( oMainWnd )

Local _lTodos       := .F.

Local _oSize    	:= FWDefSize():New( .T. )
Local _oFont12      := TFont():New('Arial Black',,-12,.T.)
Local _oDlg     	:= Nil
Local _oPanel_01    := Nil 
Local _oPanel_02    := Nil 
Local _oBtnSair     := Nil 
Local _oBtnImp      := Nil 

Local _bChkMark		:= {|| IIF(_lTodos,(DnGfeA03F(.T.),_oChkMark:Refresh()),(DnGfeA03F(.F.),_oChkMark:Refresh())) }

Private _aNotas     := {}

Private _oBrowse    := Nil 

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	 := .T.
_oSize:aWindSize     := {0,5,492,906}
_oSize:Process()

_oSay:cCaption := "Romaneio."
ProcessMessages()

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
    _oPanel_01:= TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,,000,216,.T.,.F.)
    _oPanel_01:Align := CONTROL_ALIGN_TOP

    _oPanel_02:= TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,,000,030,.T.,.F.)
    _oPanel_02:Align := CONTROL_ALIGN_BOTTOM

    //----------------------------------------+
    // Cria Browser com os clientes filtrados |
    //----------------------------------------+
    _oSay:cCaption := "Montando dados na tela."
    ProcessMessages()

    //-----------+    
    // Cria GRID | 
    //-----------+
    DnGfeA03C(_oPanel_01,_oBrowse)
    
    //------------------+    
    // Marcar/Desmarcar |
    //------------------+
    _oChkMark	:= TCheckBox():New(_nColIni + 6, _nColIni - 001 ,"Marcar/Desmarcar"	,{|l| IIF( PCount() > 0, _lTodos := l, _lTodos) },_oPanel_02,080,040,,_bChkMark,_oFont12,,,,,.T.,_cMsgChk,,)

    _oBtnImp  := TButton():New( _nColIni + 4, _nColIni + 350 , "Confirmar", _oPanel_02,{|| IIF( DnGfeA03G() ,(_nOpcA := 1,_oDlg:End()),_nOpcA := 0)}	, 045,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtnSair := TButton():New( _nColIni + 4, _nColIni + 400 , "Sair"    , _oPanel_02,{|| _oDlg:End() }	, 045,015,,,.F.,.T.,.F.,,.F.,,,.F. )

    _oDlg:lEscClose := .T.
    _oDlg:lCentered := .T.

_oDlg:Activate(,,,.T.,,,)    

//----------------------+
// Reenvia agendamentos |
//----------------------+
If _nOpcA == 1
     aSort(_aRomaneio,,,{|x,y| x[1] > y[1]})
    For _nX := 1 To Len(_aRomaneio)
        If _aRomaneio[_nX][COL_MARK] == "LBOK"
            FwMsgRun(,{|| DnGfeA03H(_aRomaneio[_nX][COL_NOTA],_aRomaneio[_nX][COL_SERIE],_cRomaneio,@_cMsg)},"Aguarde...","Reenviando agendamento nota " + RTrim(_aRomaneio[_nX][COL_NOTA])  + " serie " + RTrim(_aRomaneio[_nX][COL_SERIE]) + " romaneio " + _cRomaneio + " ." )
            _cMsgErro += _cMsg
        EndIf
    Next _nX 
EndIf 

If !Empty(_cMsgErro)
    Aviso("Dana - Avisos",_cMsgErro,{"Ok"})
EndIf 

RestArea(_aArea)
Return Nil 

/*******************************************************************************/
/*/{Protheus.doc} DnGfeA03C
    @description Cria grid contendo os documentos
    @type  Static Function
    @author Bernard M Margarido
    @since 31/07/2022
    @version version
/*/
/*******************************************************************************/
Static Function DnGfeA03C(_oPanel_01,_oBrowse)
Local _aSeek 	:= {}

aAdd( 	_aSeek, 	{   AllTrim(RetTitle("GW1_NRDC")) + " + " + AllTrim(RetTitle("GW1_SERDC")),; 
                        {{"","C",TamSx3("GW1_NRDC")[1], 0, RetTitle("GW1_NRDC"), PesqPict("SE1","GW1_NRDC")},;
                         {"SE1","C",TamSx3("GW1_SERDC")[1], 0, RetTitle("GW1_SERDC"), PesqPict("GW1","GW1_SERDC")}}})                         

//--------------+
// Cria browser |
//--------------+
_oBrowse := FWBrowse():New(_oPanel_01)
_oBrowse:AddMarkColumns( {|| IIF( _aRomaneio[_oBrowse:At()][COL_MARK] == "LBOK" , "LBOK", "LBNO")}, {|| DnGfeA03D(_oBrowse,_aRomaneios,.F.) }, {|| DnGfeA03D(_oBrowse,_aRomaneios,.T.)})
_oBrowse:DisableConfig()
_oBrowse:DisableReport()
_oBrowse:SetDataArray()
_oBrowse:SetSeek({|| DnGfeA03E(_oBrowse) },_aSeek)
_oBrowse:SetArray(_aRomaneio)
    
//--------------+
// Cria colunas |
//--------------+
_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aRomaneio[_oBrowse:At()][COL_NOTA]})
_oColumns:SetTitle(RetTitle("GW1_NRDC"))
_oColumns:SetSize(TamSx3("GW1_NRDC")[1])
_oColumns:SetDecimal(TamSx3("GW1_NRDC")[2])
_oColumns:SetPicture(PesqPict("GW1","GW1_NRDC"))
_oBrowse:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aRomaneio[_oBrowse:At()][COL_SERIE]})
_oColumns:SetTitle(RetTitle("GW1_SERDC"))
_oColumns:SetSize(TamSx3("GW1_SERDC")[1])
_oColumns:SetDecimal(TamSx3("GW1_SERDC")[2])
_oColumns:SetPicture(PesqPict("GW1","GW1_SERDC"))
_oBrowse:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aRomaneio[_oBrowse:At()][COL_DESTI]})
_oColumns:SetTitle(RetTitle("GW1_CDDEST"))
_oColumns:SetSize(TamSx3("GW1_CDDEST")[1])
_oColumns:SetDecimal(TamSx3("GW1_CDDEST")[2])
_oColumns:SetPicture(PesqPict("GW1","GW1_CDDEST"))
_oBrowse:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aRomaneio[_oBrowse:At()][COL_NDEST]})
_oColumns:SetTitle(RetTitle("GU3_NMEMIT"))
_oColumns:SetSize(TamSx3("GU3_NMEMIT")[1])
_oColumns:SetDecimal(TamSx3("GU3_NMEMIT")[2])
_oColumns:SetPicture(PesqPict("GU3","GU3_NMEMIT"))
_oBrowse:SetColumns({_oColumns})

_oColumns := FWBrwColumn():New()
_oColumns:SetData({||_aRomaneio[_oBrowse:At()][COL_DTEMIS]})
_oColumns:SetTitle(RetTitle("GW1_DTEMIS"))
_oColumns:SetSize(TamSx3("GW1_DTEMIS")[1])
_oColumns:SetDecimal(TamSx3("GW1_DTEMIS")[2])
_oColumns:SetPicture(PesqPict("GW1","GW1_DTEMIS"))
_oBrowse:SetColumns({_oColumns})

_oBrowse:SetLineHeight( 20 )
_oBrowse:DeActivate()
_oBrowse:Activate()
_oBrowse:Refresh()   

Return Nil 

/***********************************************************************************************/
/*/{Protheus.doc} DnGfeA03D
    @description Marca ou Desmarca titulos cobrança
    @type  Static Function
    @author Bernard M. Margarido
    @since 17/08/2021
/*/
/***********************************************************************************************/
Static Function DnGfeA03D(_oBrowse,_aRomaneio,_lHeader)
Local _nLin := _oBrowse:At()
Local _nX   := 0

If _lHeader 

    
    For _nX := 1 To Len(_aRomaneio)
        _aRomaneio[_nX][COL_MARK]  := "LBOK"
    Next _nX 

Else 
    If _aRomaneio[_nLin][COL_MARK] == "LBOK"
        _aRomaneio[_nLin][COL_MARK]  := "LBNO"
    Else
        _aRomaneio[_nLin][COL_MARK]  := "LBOK"
    EndIf 
EndIf 

_oBrowse:Refresh()
_oBrowse:GoTo(_nLin,.T.)

Return .T.

/**************************************************************************************/
/*/{Protheus.doc} DnGfeA03E
    @description Rotina pesquisa dados da browser
    @type  Function
    @author Bernard M. Margarido
    @since 12/03/2020
/*/
/**************************************************************************************/
Static Function DnGfeA03E(_oBrowse)
Local _nOrderFil    := _oBrowse:oBrowseUI:oFWSeek:oOrder:nOption
Local _nPos         := 0
Local _nPosAtu      := _oBrowse:nAt

If _nOrderFil == 1 
    _nPos         := aScan( _oBrowse:oData:aArray, { |x| RTrim( _oBrowse:oBrowseUI:oFWSeek:cSeek ) $ RTrim(x[COL_NOTA]) + RTrim(x[COL_SERIE])  } )
EndIf 

If _nPos == 0
    _nPos := _nPosAtu
EndIf

Return _nPos

/***********************************************************************************************/
/*/{Protheus.doc} DnGfeA03F
    @description Marca ou Desmarca todos os titulos 
    @type  Static Function
    @author Bernard M. Margarido
    @since 04/04/2022
/*/
/***********************************************************************************************/
Static Function DnGfeA03F(_lMark)
Local _nX   := 0

For _nX := 1 To Len(_aRomaneio)
    _aRomaneio[_nX][COL_MARK]  := IIF(_lMark,"LBOK","LBNO")
Next _nX 

_oBrowse:Refresh()
    
Return .T.

/***********************************************************************************************/
/*/{Protheus.doc} DnGfeA03G
    @description Valida se existem itens marcados
    @type  Static Function
    @author Bernard M. Margarido
    @since 04/04/2022
/*/
/***********************************************************************************************/
Static Function DnGfeA03G()
Local _lRet     := .T.
Local _lMark    := .F.

If aScan(_aRomaneio,{|x| RTrim(x[1]) == "LBOK"}) == 0
    _lMark := .T.
EndIf

If _lMark 
    MsgAlert("Não existem documentos marcados.","Dana - Avisos")
    _lRet := .F. 
EndIf 

Return _lRet 

/***********************************************************************************************/
/*/{Protheus.doc} DnGfeA03H
    @description 
    @type  Static Function
    @author Bernard M Margarido
    @since 31/07/2022
    @version version
/*/
/***********************************************************************************************/
Static Function DnGfeA03H(_cNota,_cSerie,_cRomaneio,_cMsg)
Local _cAlias := ""
Local _cQuery := ""
Local _cStatic:= "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"

Local _aAgenda:= {}

_cQuery := " SELECT " + CRLF
_cQuery += "	F2.F2_DOC, " + CRLF
_cQuery += "	F2.F2_SERIE, " + CRLF
_cQuery += "	A1.A1_COD, " + CRLF
_cQuery += "	A1.A1_LOJA, " + CRLF
_cQuery += "	A1.A1_XMAILAG, " + CRLF
_cQuery += "	A1.A1_XAGENDA, " + CRLF
_cQuery += "    A1.A1_XLEADTI, " + CRLF
_cQuery += "	GW1.GW1_DTSAI, " + CRLF
_cQuery += "	GW1.GW1_HRSAI " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("GW1") + " (NOLOCK) GW1 " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SF2") + " F2 (NOLOCK) ON F2.F2_FILIAL = GW1.GW1_FILIAL AND F2.F2_DOC = GW1.GW1_NRDC AND F2.F2_SERIE = GW1.GW1_SERDC AND F2.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SA1") + " A1 (NOLOCK) ON A1.A1_FILIAL = '  ' AND A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	GW1.GW1_FILIAL = '" + xFilial("GW1") + "' AND " + CRLF
_cQuery += "	GW1.GW1_NRROM = '" + _cRomaneio + "' AND " + CRLF
_cQuery += "	GW1.GW1_NRDC = '" + _cNota + "' AND " + CRLF
_cQuery += "	GW1.GW1_SERDC = '" + _cSerie + "' AND " + CRLF
_cQuery += "	GW1.D_E_L_E_T_ = '' " + CRLF

//----------------------+
// Efetiva consulta SQL | 
//----------------------+
_cAlias := MPSysOpenQuery(_cQuery) 

If (_cAlias)->A1_XAGENDA == "1" .And. !Empty((_cAlias)->A1_XMAILAG)

    aAdd(_aAgenda, {    (_cAlias)->F2_DOC       ,;
                        (_cAlias)->F2_SERIE     ,;
                        (_cAlias)->A1_COD       ,;
                        (_cAlias)->A1_LOJA      ,;
                        (_cAlias)->A1_XMAILAG   ,;
                        IIF(Empty((_cAlias)->GW1_DTSAI),Date(),sTod((_cAlias)->GW1_DTSAI)),;
                        IIF(Empty((_cAlias)->GW1_HRSAI),Left(Time(),5),(_cAlias)->GW1_HRSAI),;
                        (_cAlias)->A1_XLEADTI   })
Else
    _cMsg += "Cliente " + RTrim((_cAlias)->A1_COD) + " loja " + RTrim((_cAlias)->A1_LOJA) + " sem e-mail de agendamento cadastrado." + CRLF
EndIf 

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->(dbCloseArea())

//-----------------------------+
// Valida se envia agendamento |
//-----------------------------+
If Len(_aAgenda) > 0 
    Eval( {|| &(_cStatic + "(" + "DNGFEA01,DNGFEA01A,_aAgenda" + ")") })
EndIf 

Return Nil 
