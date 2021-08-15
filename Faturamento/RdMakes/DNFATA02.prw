#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF        CHR(13) + CHR(10)
#DEFINE CLR_CINZA   RGB(230,230,230)

#DEFINE COL_MARK    1
#DEFINE COL_ITEM    2
#DEFINE COL_PROD    3
#DEFINE COL_DPROD   4
#DEFINE COL_PRCVEN  5
#DEFINE COL_PRCALT  6
#DEFINE COL_PERDES  7
#DEFINE COL_VLRDES  8
#DEFINE COL_RECNO   9

/***************************************************************************/
/*/{Protheus.doc} DNFATA02
    @description Aprovação de preços Dana
    @type  Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/***************************************************************************/
User Function DNFATA02()
Local _cQuery       := ""
Local _cAliasTMP    := "DA1TEMP"
Local _cUserApr     := GetNewPar("DN_USRPRC")

Local _aColumns     := []

Private _oBrowse	:= Nil

If !__cUserId $ _cUserApr
    MsgStop("Usuário sem acesso a rotina. Favor solicitar autorização ao superior.","Dana - Avisos")
    Return Nil 
EndIf

//------------------+
// Colunas exibição |
//------------------+
_aColumns := fColumns()

//-------------------------------+
// Filtro para tela de alteração |
//-------------------------------+
_cQuery := fQuery(_aColumns[2])

_oBrowse := FWMBrowse():New()
_oBrowse:SetDataQuery(.T.)
_oBrowse:SetAlias(_cAliasTMP)
_oBrowse:SetDescription('DANA - Aprovação alteração de preços')
_oBrowse:SetColumns( _aColumns[1] )
_oBrowse:SetQuery( _cQuery )
_oBrowse:SetUseFilter(.F.)
_oBrowse:SetTemporary(.T.)
//_oBrowse:SetProfileID('1')
_oBrowse:DisableDetails() 
_oBrowse:Activate()

Return .T.

/***************************************************************************/
/*/{Protheus.doc} DNFATA02A
    @description Realiza a aprovação dos preços alterados
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/11/2020
/*/
/***************************************************************************/
Static Function DNFATA02A(_nRecnoDA0)
Local _aArea        := GetArea()
Local _aItems       := {}
Local _aSeek        := {}
Local _aSections    := {}
Local _aInfo        := {}
Local _aPosObj      := {}
Local _aCoors       := FWGetDialogSize( oMainWnd )

Local _cTool        := "Marca ou Desmarca todos os preços para serem aprovados."

Local _nOpcA        := 0

Local _lTodos       := .F.

Local _bEditCell    := {|| DnFatA02E(_oBrowse,_aItems)}

Local _oDlg         := Nil 
Local _oFwLayer     := Nil 
Local _oPanel_01    := Nil 
Local _oBrowse      := Nil
Local _oPnlBtn      := Nil 
Local _oBtnMk       := Nil 
Local _oBtnOk       := Nil 
Local _oBtnCa       := Nil 
Local _oSize        := FWDefSize():New( .T. )

_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	 := .T.
_oSize:Process()

//----------------------------------+
// Consulta Itens a serem alterados | 
//----------------------------------+
If !DnFatA02Qry(_nRecnoDA0,@_aItems)
    Help("",1,"DNFATA02",,"Não existem dados para serem alterados.",1)
    RestArea(_aArea)
    Return .F. 
EndIf

//--------------------------------------------------------+
// Adiciona Coordenadas da Tela de acordo com a resolução |
//--------------------------------------------------------+
aAdd(_aSections, {100, 95, .T., .T.}) // Painel 1 - 05%
aAdd(_aSections, {100, 5, .T., .T. }) //Painel 2 - 85%
_aInfo  := { _oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3], _oSize:aWindSize[4], 3, 3, 3, 3}
_aPosObj:=  MsObjSize( _aInfo, _aSections, .T., .F.)

//----------------------------------------+
// Cria Browser com os clientes filtrados |
//----------------------------------------+
_oDlg := TDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3], _oSize:aWindSize[4],"Dana - Aprovação de Preços",,,,,,,,,.T.,,,,,,.F.)
    //-----------------------------------------+
	// Nao permite fechar tela teclando no ESC |
	//-----------------------------------------+
	_oDlg:lEscClose := .F.

    //----------------+
    // Painel Browser |
    //----------------+
	_oFwLayer := FwLayer():New()
	_oFwLayer:Init(_oDlg,.F.)

    _oFwLayer:AddLine("BRWCLI",095, .T.)
    _oFWLayer:AddCollumn( "COLBRWCLI"	,100, .T. , "BRWCLI")
    _oFWLayer:AddWindow( "COLBRWCLI", "WINENT", "Preços a serem aprovados", 100, .F., .F., , "BRWCLI")
    _oPanel_01 := _oFWLayer:GetWinPanel("COLBRWCLI","WINENT","BRWCLI")
    
    //-------------------+
	// Array de pesquisa | 
	//-------------------+
	aAdd( 	_aSeek, 	{ AllTrim("Produto")				,{{"","C",TamSx3("DA1_CODPRO")[1],0 ,"Produto"		, PesqPict("DA1","DA1_CODPRO")}}})

    DEFINE FWBROWSE _oBrowse DATA ARRAY ARRAY _aItems EDITCELL _bEditCell Of _oPanel_01
        _oBrowse:SetSeek(,_aSeek)

        ADD MARKCOLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_MARK] } DOUBLECLICK {|| MarkBrw(_aItems, _oBrowse)} OF _oBrowse
    
        ADD COLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_ITEM]   	} TITLE "Item"	        SIZE TamSx3("DA1_ITEM")[1]      PICTURE PesqPict("DA1","DA1_ITEM")      TYPE "C"    ALIGN 1 DOUBLECLICK {|| MarkBrw(_aItems, _oBrowse)} OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_PROD]   	} TITLE "Produto"	    SIZE TamSx3("DA1_CODPRO")[1]    PICTURE PesqPict("DA1","DA1_CODPRO")    TYPE "C"    ALIGN 1 DOUBLECLICK {|| MarkBrw(_aItems, _oBrowse)} OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_DPROD] 	} TITLE "Descrição" 	SIZE TamSx3("B1_DESC")[1]       PICTURE PesqPict("DA1","B1_DESC")       TYPE "C"    ALIGN 1 DOUBLECLICK {|| MarkBrw(_aItems, _oBrowse)} OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_PRCVEN] 	} TITLE "Prc. Venda" 	SIZE TamSx3("DA1_PRCVEN")[1]    PICTURE PesqPict("DA1","DA1_PRCVEN")    TYPE "N"    ALIGN 1 DOUBLECLICK {|| MarkBrw(_aItems, _oBrowse)} OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_PRCALT] 	} TITLE "Prc. Alterado" SIZE TamSx3("DA1_XPRCVE")[1]    PICTURE PesqPict("DA1","DA1_XPRCVE")    TYPE "N"    EDIT READVAR "_nPrcAlt"                             OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_PERDES] 	} TITLE "% Desconto" 	SIZE TamSx3("C6_DESCONT")[1]    PICTURE PesqPict("SC6","C6_DESCONT")    TYPE "N"    EDIT READVAR "_nPerDesc"                            OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_VLRDES] 	} TITLE "Vlr. Desconto" SIZE TamSx3("DA1_VLRDES")[1]    PICTURE PesqPict("DA1","DA1_VLRDES")    TYPE "N"    EDIT READVAR "_nValDesc"                            OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aItems[_oBrowse:nAt][COL_RECNO]	} TITLE " " 		    SIZE 10                         PICTURE "9999999999"                    TYPE "N"    ALIGN 1 DOUBLECLICK {|| MarkBrw(_aItems, _oBrowse)} OF _oBrowse

        _oBrowse:DisableConfig()

    ACTIVATE FWBROWSE _oBrowse
 

    _oDlg:lCentered := .T.

    //-----------------------+
    // Painel para os Botoes | 
    //-----------------------+
    _oPnlBtn := TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,CLR_CINZA,022,022,.T.,.F.)
    _oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

    _oBtnMk := TCheckBox():New( _aPosObj[2][2] + 4, _aPosObj[2][2], 'Marcar/Desmarcar todos?',{|u| IIF( PCount() > 0, _lTodos := u, _lTodos)}, _oPnlBtn, 100, 210,,,,,,,,.T.,_cTool,,)
    _oBtnMk:bLClicked   := {|| MarkBrw(_aItems,_oBrowse,_lTodos,2)}

    _oBtnOk	:= TButton():New( _aPosObj[2][2], _aPosObj[2][4] - 61 , "Aprovar"      , _oPnlBtn, {|| IIF(DnFatA02T(_oBrowse,_aItems),(_nOpcA := 1,_oDlg:End()), .F.) }	, 060,018,,,.F.,.T.,.F.,,.F.,,,.F. )
    _oBtnCa	:= TButton():New( _aPosObj[2][2], _aPosObj[2][4] + 01 , "Sair"         , _oPnlBtn, {|| _oDlg:End() }	, 060,018,,,.F.,.T.,.F.,,.F.,,,.F. )

_oDlg:Activate()

//-----------------+
// Atualiza preços | 
//-----------------+
If _nOpcA == 1
    //Begin Transaction 
        FwMsgRun(,{|| DnFatA02G(_oBrowse,_aItems)}, "Aguarde...","Atualizando preços...")
    //End Transaction
EndIf

RestArea(_aArea)
Return Nil 

/***************************************************************************/
/*/{Protheus.doc} DnFatA02T
    @description Valida itens da GRID
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/11/2020
/*/
/***************************************************************************/
Static Function DnFatA02T(_oBrowse,_aItems)
Local _lRet     := .T. 
Local _nPMark   := 0

If ( _nPMark := aScan(_aItems,{|x| x[COL_MARK] == "LBOK"} ) ) == 0
    Help("",1,"DNFATA02",,"Não existem itens marcados para gravar a aprovação.",1)
    Return .F.
EndIf

Return _lRet 

/***************************************************************************/
/*/{Protheus.doc} DnFatA02G
    @description Realiza a atualização dos preços após a aprovação 
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/11/2020
/*/
/***************************************************************************/
Static Function DnFatA02G(_oBrowse,_aItems)
Local _nX   := 0

dbSelectArea("DA1")
DA1->( dbSetOrder(1) )

For _nX := 1 To Len(_aItems)
    If _aItems[_nX][COL_MARK] == "LBOK" 
        DA1->(dbGoTo(_aItems[_nX][COL_RECNO]))
        RecLock("DA1",.F.)
            DA1->DA1_ENVECO := "1"
            DA1->DA1_PRCVEN := _aItems[_nX][COL_PRCALT]
            DA1->DA1_XPRCVE := 0
        DA1->( MsUnLock() )
    EndIf
Next _nX

Return Nil 

/***************************************************************************/
/*/{Protheus.doc} DnFatA02E
    @description Valida edição de celulas no Browser
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/11/2020
/*/
/***************************************************************************/
Static Function DnFatA02E(_oBrowse,_aItems)
Local _lRet     := .T.

Local _nLin     := _oBrowse:nAt
Local _nPDesc   := 0
Local _nVDesc   := 0 
Local _nPrcVnd  := 0
Local _nPrcNew  := 0

If ReadVar() == "_NPRCALT"
    If _nPrcAlt < 0
        Help("",1,"DNFATA02",,"Não é permitido valor negativo.",1)
        Return .F.
    EndIf

    //-----------------------+
    // Calcula novos valores |
    //-----------------------+
    _nPrcVnd                    := _aItems[_nLin][COL_PRCVEN]
    _nVDesc                     := _nPrcVnd - _nPrcAlt
    _nPDesc                     := Round( (_nVDesc / _nPrcVnd) * 100,2 )
    
    _aItems[_nLin][COL_MARK]    := "LBOK"
    _aItems[_nLin][COL_PRCALT]  := _nPrcAlt
    _aItems[_nLin][COL_PERDES]  := _nPDesc
    _aItems[_nLin][COL_VLRDES]  := _nVDesc

ElseIf ReadVar() == "_NPERDESC"
    If _nPerDesc < 0
        Help("",1,"DNFATA02",,"Não é permitido valor negativo.",1)
        Return .F.
    EndIf
    
    //-----------------------+
    // Calcula novos valores |
    //-----------------------+
    _nPrcVnd                    := _aItems[_nLin][COL_PRCVEN]
    _nVDesc                     := Round( _nPrcVnd * ( _nPerDesc / 100 ) , 2 )
    _nPDesc                     := _nPerDesc
    _nPrcNew                    := _nPrcVnd - _nVDesc

    _aItems[_nLin][COL_MARK]    := "LBOK"
    _aItems[_nLin][COL_PRCALT]  := _nPrcNew
    _aItems[_nLin][COL_PERDES]  := _nPDesc
    _aItems[_nLin][COL_VLRDES]  := _nVDesc

ElseIf ReadVar() == "_NVALDESC"
    If _nValDesc < 0
        Help("",1,"DNFATA02",,"Não é permitido valor negativo.",1)
        Return .F.
    EndIf

     //-----------------------+
    // Calcula novos valores |
    //-----------------------+
    _nPrcVnd                    := _aItems[_nLin][COL_PRCVEN]
    _nVDesc                     := _nValDesc
    _nPrcNew                    := _nPrcVnd - _nValDesc
    _nPDesc                     := Round( (_nVDesc / _nPrcVnd) * 100,2 )
    
    _aItems[_nLin][COL_MARK]    := "LBOK"
    _aItems[_nLin][COL_PRCALT] := _nPrcNew
    _aItems[_nLin][COL_PERDES] := _nPDesc
    _aItems[_nLin][COL_VLRDES] := _nVDesc

Endif

If _lRet .And. Type("_oBrowse") == "O"
	_oBrowse:SetArray(_aItems)
	_oBrowse:Refresh()
EndIf

Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} MarkBrw
    @description Marca Browser para TGV
    @type  Static Function
    @author Bernard M. Margarido
    @since 05/03/2020
/*/
/*************************************************************************************/
Static Function MarkBrw(_aArray, _oBrowse, _lTodos, _nField)
Local _nLin     := _oBrowse:nAt
Local _nLMark   := 0

Default _nField := 1
Default _lTodos := .F.

If _nField == 1
    //------------------------------------+
    // Valida se tem linha marcada        |
    // permite marcar somente um registro | 
    //------------------------------------+
    _nLMark := aScan(_aArray,{|x| x[1] == "LBOK" })

    If _nLMark > 0
        _aArray[_nLMark][COL_MARK] := "LBNO"
    EndIf

    If _aArray[_nLin][COL_MARK] == "LBNO"
        _aArray[_nLin][COL_MARK] := "LBOK"
    EndIf

Else
    For _nLin   := 1 To Len(_aArray)
        _aArray[_nLin][COL_MARK] := IIF(_lTodos,"LBOK","LBNO")
    Next _nLin
EndIf

//------------------+
// Atualiza Browser |
//------------------+
_oBrowse:Refresh()

Return .T.

/***************************************************************************/
/*/{Protheus.doc} DnFatA02Qry
    @description Consulta Itens da tabela de preço a serem alterados
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/11/2020
/*/
/***************************************************************************/
Static Function DnFatA02Qry(_nRecnoDA0,_aItems)
Local _cAlias   := ""
Local _cQuery   := ""

Local _nVlrDesc := 0
Local _nPerDesc := 0

//---------------------------+
// Posiciona tabela de preço | 
//---------------------------+
dbSelectArea("DA0")
DA0->( dbGoTo(_nRecnoDA0) )

_cQuery := " SELECT " + CRLF
_cQuery += "	DA1.DA1_ITEM ITEM, " + CRLF
_cQuery += "	DA1.DA1_CODPRO PRODUTO, " + CRLF
_cQuery += "    B1.B1_DESC DESC_PROD, " + CRLF
_cQuery += "	DA1.DA1_PRCVEN PRCVEN, " + CRLF
_cQuery += "	DA1.DA1_XPRCVE PRCALT, " + CRLF
_cQuery += "	DA1.DA1_PERDES PERDES, " + CRLF
_cQuery += "	DA1.DA1_VLRDES VLRDES," + CRLF
_cQuery += "	DA1.R_E_C_N_O_ RECNODA1" + CRLF
_cQuery += " FROM " + CRLF 
_cQuery += "	" + RetSqlName("DA1") + " DA1 " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + DA0->DA0_FILIAL + "' AND B1.B1_COD = DA1.DA1_CODPRO AND B1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	DA1.DA1_FILIAL = '" + DA0->DA0_FILIAL + "' AND " + CRLF
_cQuery += "	DA1.DA1_CODTAB = '" + DA0->DA0_CODTAB + "' AND " + CRLF
_cQuery += "	DA1.DA1_XPRCVE > 0 AND " + CRLF
_cQuery += "	DA1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY DA1.DA1_ITEM "

_cAlias := MPSysOpenQuery(_cQuery)

While (_cAlias)->( !Eof() )
    aAdd(_aItems,Array(9))

    _nVlrDesc                           :=  (_cAlias)->PRCVEN - (_cAlias)->PRCALT 
    _nPerDesc                           :=  Round((_nVlrDesc / (_cAlias)->PRCVEN) * 100,2)
    _aItems[Len(_aItems)][COL_MARK]     := "LBNO" 
    _aItems[Len(_aItems)][COL_ITEM]     := (_cAlias)->ITEM
    _aItems[Len(_aItems)][COL_PROD]     := (_cAlias)->PRODUTO
    _aItems[Len(_aItems)][COL_DPROD]    := (_cAlias)->DESC_PROD
    _aItems[Len(_aItems)][COL_PRCVEN]   := (_cAlias)->PRCVEN
    _aItems[Len(_aItems)][COL_PRCALT]   := (_cAlias)->PRCALT
    _aItems[Len(_aItems)][COL_PERDES]   := _nPerDesc
    _aItems[Len(_aItems)][COL_VLRDES]   := _nVlrDesc
    _aItems[Len(_aItems)][COL_RECNO]    := (_cAlias)->RECNODA1
    (_cAlias)->( dbSkip() )

EndDo

(_cAlias)->( dbCloseArea() )

Return .T.

/***************************************************************************/
/*/{Protheus.doc} fQuery
    @description Filtra regitros tabela de preço 
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/11/2020
/*/
/***************************************************************************/
Static Function fQuery(_cColumns)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "    DA0.R_E_C_N_O_ RECNODA0, " + CRLF
_cQuery += "    " + _cColumns + " " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("DA0") + " DA0 " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("DA1") + " DA1 ON DA1.DA1_FILIAL = DA0.DA0_FILIAL AND DA1.DA1_CODTAB = DA0.DA0_CODTAB AND DA1.DA1_XPRCVE > 0 AND DA1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	DA0.D_E_L_E_T_ = '' " + CRLF
_cQuery += " GROUP BY DA0.R_E_C_N_O_, " + _cColumns + " " + CRLF
_cQuery += " ORDER BY DA0.DA0_CODTAB "

_cQuery := ChangeQuery(_cQuery)

Return _cQuery 


/***************************************************************************/
/*/{Protheus.doc} fColumns
    @description Colunas da Browser
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/11/2020
/*/
/***************************************************************************/
Static Function fColumns()

Local _cColumns	    := ""

Local _aRet 		:= {}
Local _aColumns	    := {}
Local _aArea		:= GetArea()
Local _aAreaSX3	    := SX3->( GetArea() )

dbSelectArea('SX3')
SX3->( dbSetOrder(1) )	
SX3->( dbSeek("DA0") )

While SX3->( !EoF() .And. SX3->X3_ARQUIVO == "DA0" )

	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE == "S"

        //-----------------------------------------+
		// Cria uma instancia da classe FWBrwColum |
        //-----------------------------------------+
		aAdd( _aColumns, FWBrwColumn():New() )

        //------------------------------------------------------------------+
		// Se for do tipo [D]ata, faz a conversao para o formato DD/MM/AAAA |
        //------------------------------------------------------------------+
		_cX3Campo  := AllTrim(SX3->X3_CAMPO)
		_cColumns += (_cX3Campo + ",")

		If SX3->X3_TIPO == "D"
			Atail(_aColumns):SetData( &("{||StoD(" + _cX3Campo + ")}") )
		Else
			Atail(_aColumns):SetData( &("{||" + _cX3Campo + "}") )
		EndIf

		Atail(_aColumns):SetSize( SX3->X3_TAMANHO )
		Atail(_aColumns):SetDecimal( SX3->X3_DECIMAL )
		Atail(_aColumns):SetTitle( X3Titulo() )
		Atail(_aColumns):SetPicture( SX3->X3_PICTURE )

		If SX3->X3_TIPO == "N"
			Atail(_aColumns):SetAlign( CONTROL_ALIGN_RIGHT )
		Else
			Atail(_aColumns):SetAlign( CONTROL_ALIGN_LEFT )
		EndIf
	EndIf
	
	SX3->( DbSkip() )
End	

RestArea(_aAreaSX3)
RestArea(_aArea)

//---------------------------------------------+
// Retira a ultima virgula dos campos da query |
//---------------------------------------------+
_cColumns := Substr(_cColumns, 1, Len(_cColumns)-1)

Aadd(_aRet, Aclone(_aColumns) )	// Campos presentes na mBrowse (cada campo é um objeto da classe FWBrwColumn)
Aadd(_aRet, _cColumns )			// Campos que serao retornados na query

//--------------------+
// Destroi o aColumns |
//--------------------+
aSize( _aColumns,0 )
_aColumns := Nil

Return _aRet

/***************************************************************************/
/*/{Protheus.doc} MenuDef
    @description Menu especifico regras tabelas de preço
    @type  Static Function
    @author Bernard M. Margarido
    @since 11/09/2020
/*/
/***************************************************************************/
Static Function MenuDef()
Local _aRotina := {}  // Recebe o Array de Rotinas
	
    ADD OPTION _aRotina TITLE 'Aprovar'             ACTION 'StaticCall(DNFATA02,DNFATA02A,RECNODA0)'     OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 3
   
Return _aRotina