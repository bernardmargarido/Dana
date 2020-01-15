#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} ECLOJ004

@description Filtros e-Commerce

@author Bernard M. Margarido

@since 29/04/2019
@version undefined

@type function
/*/
/************************************************************************************/
User Function ECLOJ004()
Private oBrowse		:= Nil

Private aRotina     := MenuDef()

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("AY3")

//-------------------+
// Adiciona Legendas |
//-------------------+
oBrowse:AddLegend("AY3_STATUS == '1' "	,"GREEN"				,"Ativo")
oBrowse:AddLegend("AY3_STATUS == '2' "	,"RED"					,"Inativo")

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Cadastro Filtros')

//--------------------+
// Ativação do Browse |
//--------------------+
oBrowse:Activate()
Return Nil

/************************************************************************************/
/*/{Protheus.doc} ECLOJ04A

@description Manutenção dos filtros e-Commerce

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
User Function ECLOJ04A(cAlias,nReg,nOpc)
Local _aArea        := GetArea()
Local _aCoors       := FWGetDialogSize( oMainWnd )

Local _cTitulo      := "Filtros"

Local _nOpcA        := 0

Local _oSize        := FWDefSize():New( .T. )
Local _oLayer       := FWLayer():New()
Local _oDlg         := Nil
Local _oPCab        := Nil
Local _oPItem       := Nil
Local _oEnchoice    := Nil
Local _oMsGetDad    := Nil

Private _aHeader    := {}
Private _aCols      := {}

Private aTela[0][0]
Private aGets[0]

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	:= .T.
_oSize:Process()

//-------------+
// Cria Header |
//-------------+
EcLoj04Head()

//---------------------------------+
// Carrega as variaveis em Memória |
//---------------------------------+
RegToMemory("AY3", IIF(nOpc == 3,.T.,.F.) )

//------------------------+
// Monta Dialog principal |
//------------------------+
_oDlg := MsDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3], _oSize:aWindSize[4],_cTitulo,,,,,,,,,.T.)

    //--------------------+
    // Layer da estrutura |
    //--------------------+
    _oLayer:Init( _oDlg, .F. )
    _oLayer:AddLine( "LINE01", 040 )
    _oLayer:AddLine( "LINE02", 055 )

    _oLayer:AddCollumn( "COLLL01"  , 100,, "LINE01" )
    _oLayer:AddCollumn( "COLLL02"  , 100,, "LINE02" )

    _oLayer:AddWindow( "COLLL01" , "WNDCABEC"  , "Filtro"    , 100 ,.F. ,,,"LINE01" )
    _oLayer:AddWindow( "COLLL02" , "WNDITEMS"  , "Valores"   , 095 ,.F. ,,,"LINE02" )

    _oPCab  := _oLayer:GetWinPanel( "COLLL01"   , "WNDCABEC"  , "LINE01" )
    _oPItem := _oLayer:GetWinPanel( "COLLL02"   , "WNDITEMS"  , "LINE02" )

    //---------------------------+
    // Adiciona campos cabeçalho |
    //---------------------------+
    _oEnchoice := MsMGet():New(cAlias, nReg, nOpc,,,,,{000,000,000,000},,,,,,_oPCab,,,,,,,,,,,,.T.)
    _oEnchoice:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

    //---------------------+
    // Adiciona grid itens |
    //---------------------+
    _oMsGetDad := MsNewGetDados():New(000,000,000,000,GD_INSERT+GD_UPDATE+GD_DELETE,/*cLinOk*/,/*cTudoOk1*/,"+AY4_SEQ",/*aAlterGda*/,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,_oPItem,_aHeader,_aCols)
    _oMsGetDad:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

    //---------------+
    // Enchoice Tela |
    //---------------+
    _oDlg:bInit := {|| EnchoiceBar(_oDlg,{||Iif( ( Obrigatorio(aGets,aTela) .And. EcLoj04TdOk(nOpc,_oMsGetDad)), (_nOpcA := 1 ,_oDlg:End()) ,_nOpcA := 0) },{|| _oDlg:End() },.F.)}

_oDlg:Activate(,,,.T.,,,)

//--------------------+
// Realiza a gravação |
//--------------------+
If _nOpcA == 1
    Begin Transaction
		FWMsgRun(, {|| EcLoj04Grv(nOpc,_oMsGetDad) }, "Aguarde...", "Gravando dados..." )
	End Transaction     
EndIf

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj04Grv

@description Realiza a gravação dos filtros

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj04Grv(nOpc,_oMsGetDad)
Local _aArea    := GetArea()

Local _cCpoAy3 := 'AY3_FILIAL/AY3_ENVECO/AY3_XDTEXP/AY3_XHREXP'
Local _cCpoAy4 := 'AY4_FILIAL/AY4_CODCAR/AY4_ENVECO/AY4_XDTEXP/AY4_XHREXP'
Local _nX       := 0
Local _nY       := 0
Local _nPCodFil := aScan(_oMsGetDad:aHeader,{|x| RTrim(x[2]) == "AY4_CODCAR"})
Local _nPSeqFil := aScan(_oMsGetDad:aHeader,{|x| RTrim(x[2]) == "AY4_SEQ"})

Local _lRet     := .T.
Local _lInclui	:= IIF(nOpc == 3,.T.,.F.)
Local _lAltera	:= IIF(nOpc == 4,.T.,.F.)
Local _lExclui	:= IIF(nOpc == 5,.T.,.F.)
Local _lVisual	:= IIF(nOpc == 2,.T.,.F.)
Local _lGrava	:= IIF(nOpc == 3,.T.,.F.)

//----------------------+
// Somente visualização |
//----------------------+
If _lVisual
	RestArea(_aArea)
	Return .T.
EndIf

//-----------------------+
// Inclusão ou Alteração |
//-----------------------+
If _lInclui .Or. _lAltera

    //----------------------------+
    // Grava / Atualiza cabeçalho |
    //----------------------------+
    dbSelectArea("AY3")
    RecLock("AY3",_lGrava)

        For _nX := 1 To fCount()
			IF FieldName(_nX) # _cCpoAy3
				FieldPut(_nX, &('M->' + FieldName(_nX)))
			EndIF
		Next _nX

        //------------------------------+
        // Grava informações adicionais | 
        //------------------------------+
        AY3->AY3_FILIAL     := xFilial("AY3")
        AY3->AY3_ENVECO     := "1"
        AY3->AY3_XDTEXP     := ""
        AY3->AY3_XHREXP     := ""

    AY3->( MsUnLock() )

    //---------------------------+
    // Posiciona itens do filtro |
    //---------------------------+
    dbSelectArea("AY4")
    AY4->( dbSetOrder(1) )

    //------------------------+
    // Grava / Atualiza itens |
    //------------------------+
    For _nX := 1 To Len(_oMsGetDad:aCols)
        //-------------------------------+
        // Valida se linha está deletada | 
        //-------------------------------+
        If _oMsGetDad:aCols[_nX][Len(_oMsGetDad:aHeader) + 1]
            If AY4->( dbSeek(xFilial("AY4") + M->AY3_CODIGO + _oMsGetDad:aCols[_nX][_nPSeqFil] ) )
                RecLock("AY4",.F.)
                    AY4->( dbDelete() )
                AY4->( MsUnLock() )
            Else
                Loop    
            EndIf
        Else

            _lGrava := .T.
            If AY4->( dbSeek(xFilial("AY4") + M->AY3_CODIGO + _oMsGetDad:aCols[_nX][_nPSeqFil] ) )
                _lGrava := .F.
            EndIf

            //-------------------------------+
			// Efetua a Gravação/Atualização |
			//-------------------------------+
			RecLock("AY4",_lGrava)
			
				For _nY:= 1 To Len(_oMsGetDad:aHeader)
					If !Alltrim(_oMsGetDad:aHeader[_nY][2]) $ _cCpoAy4
						AY4->( FieldPut(FieldPos(Alltrim(_oMsGetDad:aHeader[_nY][2])),_oMsGetDad:aCols[_nX][_nY]))
					EndIf	
				Next _nY
				
				AY4->AY4_FILIAL := xFilial("ZZE")
                AY4->AY4_CODCAR := M->AY3_CODIGO
				AY4->AY4_ENVECO := "1"
				AY4->AY4_XDTEXP := ""
                AY4->AY4_XHREXP := ""    

			AY4->( MsUnLock() )

        EndIf
    Next _nX
//---------+
// Excluir |
//---------+
ElseIf _lExclui
    //------------------+
    // Posiciona Filtro |
    //------------------+
    dbSelectArea("AY3")
    AY3->( dbSetOrder(1) )
    AY3->( dbSeek(xFilial("AY3") + M->AY3_CODIGO))

    //-----------------+
    // Exclui registro |
    //-----------------+
    RecLock("AY3",.F.)
        AY3->( dbDelete() )
    AY3->( MsUnLock() ) 

    //-----------------------------+
    // Posiciciona Itens do Filtro |
    //-----------------------------+
    dbSelectArea("AY4")
    AY4->( dbSetOrder(1) ) 

    //--------------+
    // Exclui itens | 
    //--------------+
    For _nX := 1 To Len(_oMsGetDad:aCols)
        //----------------+
        // Posiciona item | 
        //----------------+
        If AY4->( dbSeeK(xFilial("AY4") + M->AY3_CODIGO + _oMsGetDad:aCols[_nX][_nPSeqFil]))
            RecLock("AY4",.F.)
                AY4->( dbDelete() )
            AY4->( MsUnlock() )
        EndIf
    Next _nX    

EndIf
RestArea(_aArea)
Return _lRet

/************************************************************************************/
/*/{Protheus.doc} EcLoj04TdOk

@description Valida registro

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj04TdOk(nOpc,_oMsGetDad)
Local _aArea    := GetArea()

Local _cMsg     := ""

Local _lRet     := .T.
Local _lExclui  := .T.

If nOpc <> 5
    RestArea(_aArea)
    Return _lRet
EndIf

//-------------------------------------------------+
// Valida se filtros já está amarrado a um produto |
//-------------------------------------------------+
FWMsgRun(, {|| _lExclui := EcLoj04Vld(AY3->AY3_CODIGO) }, "Aguarde....", "Consultando Filtro. " )
_cMsg := IIF(_lExclui,"Filtro amarrado a um produto.","")

If _lExclui
    _lRet := .F.
    MsgAlert("Não é possivel excluir Filtro. " + _cMsg,"Avisos")
EndIf

RestArea(_aArea)
Return _lRet 

/************************************************************************************/
/*/{Protheus.doc} EcLoj04Vld

@description Valida se filtro está amarrado a um produto 

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj04Vld(_cCodFiltro)
Local _lRet     := .T.

Local _cQuery   := ""
Local _cAlias   := GetNextAlias()

_cQuery := " SELECT " + CRLF 
_cQuery += "	FILTRO " + CRLF 
_cQuery += " FROM " + CRLF 
_cQuery += " ( " + CRLF 
_cQuery += "	SELECT " + CRLF 
_cQuery += "		AY5.AY5_CODPRO FILTRO " + CRLF 
_cQuery += "	FROM " + CRLF 
_cQuery += "		" + RetSqlName("AY5") + " AY5 " + CRLF  
_cQuery += "	WHERE " + CRLF 
_cQuery += "		AY5.AY5_CODIGO = '" + _cCodFiltro + "' AND " + CRLF 
_cQuery += "		AY5.D_E_L_E_T_ = '' " + CRLF 
_cQuery += ") PRODXFILTRO "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If Empty((_cAlias)->FILTRO)
    _lRet := .F.
EndIf

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

Return _lRet

/************************************************************************************/
/*/{Protheus.doc} EcLoj04Head

@description Cria Header e aCols

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj04Head()
Local _cAlias   := "AY4"

Local _nX       := 0

//-------------------------------+
// Posiciona estrutura de Campos |
//-------------------------------+
dbSelectArea("SX3")
SX3->( dbSetOrder(1) )
SX3->( MsSeek(_cAlias) )

While SX3->( !Eof() .And. SX3->X3_ARQUIVO == _cAlias )
    If x3Uso(SX3->X3_USADO)
        AAdd(_aHeader,{	RTrim(X3Titulo())   ,;
				        SX3->X3_CAMPO       ,;
				        SX3->X3_PICTURE     ,;
				        SX3->X3_TAMANHO     ,;
				        SX3->X3_DECIMAL     ,;
				        SX3->X3_VALID       ,;
				        SX3->X3_USADO       ,;
				        SX3->X3_TIPO        ,;
				        SX3->X3_F3          ,;
				        SX3->X3_CONTEXT     })
    EndIf
    SX3->( dbSkip() )
EndDo

//----------------+
// Preenche aCols |
//----------------+
If !INCLUI
    dbSelectArea("AY4")
    AY4->( dbSetOrder(1) )
    If AY4->( dbSeeK(xFilial("AY4") + AY3->AY3_CODIGO) )
        While AY4->( !Eof() .And. xFilial("AY4") + AY3->AY3_CODIGO == AY4->AY4_FILIAL + AY4->AY4_CODCAR)

            aAdd(_aCols,Array(Len(_aHeader)+1)) 
            For _nX:= 1 To Len(_aHeader)
                _aCols[Len(_aCols)][_nX] := FieldGet(FieldPos(_aHeader[_nX][2]))
            Next _nX
            _aCols[Len(_aCols)][Len(_aHeader)+1]:= .F.

            AY4->( dbSkip() )
        EndDo
    EndIf       
Else
    aAdd(_aCols,Array(Len(_aHeader)+1)) 
    For _nX:= 1 To Len(_aHeader)
        If RTrim(_aHeader[_nX][2]) == "AY4_SEQ"
            _aCols[1][_nX]:= "000001"
        Else
            _aCols[1][_nX]:= CriaVar(_aHeader[_nX][2],.T.)
        EndIf    
    Next _nX
    _aCols[1][Len(_aHeader)+1]:= .F.
EndIf
Return .T.


/************************************************************************************/
/*/{Protheus.doc} MenuDef

@description Menu padrao para manutencao do cadastro

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function MenuDef()
Local aRotina := {}
    aAdd(aRotina, {"Pesquisa"   , "AxPesqui"    , 0, 1 })  // Pesquisa
    aAdd(aRotina, {"Visualizar" , "U_ECLOJ04A"  , 0, 2 })  // Visualizar
    aAdd(aRotina, {"Incluir"    , "U_ECLOJ04A"  , 0, 3 })  // Incluir
    aAdd(aRotina, {"Alterar"    , "U_ECLOJ04A"  , 0, 4 })  // Alterar
    aAdd(aRotina, {"Excluir"    , "U_ECLOJ04A"  , 0, 5 })  // Excluir
Return aRotina