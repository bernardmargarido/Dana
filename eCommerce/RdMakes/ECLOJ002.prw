#INCLUDE "PROTHEUS.CH"

#DEFINE MAX_ITENS 5
#DEFINE CRLF CHR(13) + CHR(10)

Static _nTCodCat    := TamSx3("AY0_CODIGO")[1]

/*********************************************************************************/
/*/{Protheus.doc} ECLOJ002

@description Estrutura das Categorias

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
User Function ECLOJ002()
Local _aArea    := GetArea()
Local _aCoors   := FWGetDialogSize( oMainWnd )

Local _cTitulo  := "Estrutura das Categorias"

Local _oSize    := FWDefSize():New( .T. )
Local _oLayer   := FWLayer():New()
Local _oDlg     := Nil
Local _oPBtn    := Nil
Local _oPTree   := Nil
Local _oBntInc  := Nil
Local _oBntAlt  := Nil
Local _oBntDel  := Nil
Local _oBntExit := Nil

Private _oTree  := Nil
Private _nRecNo := AY1->( RecNo() )

//--------------------------------+
// Tecla de atalho para estrutura |
//--------------------------------+
SetKey( VK_F6, { || ECLOJ02A(1) } )
SetKey( VK_F7, { || ECLOJ02A(2) } )
SetKey( VK_F8, { || _oDlg:End() } )

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	:= .T.
_oSize:Process()

//------------------------+
// Monta Dialog principal |
//------------------------+
_oDlg := MsDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3], _oSize:aWindSize[4],_cTitulo,,,,,,,,,.T.)
    //--------------------+
    // Layer da estrutura |
    //--------------------+
    _oLayer:Init( _oDlg, .F. )
    _oLayer:AddLine( "LINE01", 090 )

    _oLayer:AddCollumn( "BUTTONS", 015,, "LINE01" )
    _oLayer:AddCollumn( "TREE"   , 085,, "LINE01" )

    _oLayer:AddWindow( "BUTTONS" , "WNDBUTTONS"  , "Ações"       , 100 ,.F. ,,,"LINE01" )
    _oLayer:AddWindow( "TREE"   , "WNDTREE"      , "Estrutura"   , 100 ,.F. ,,,"LINE01" )

    _oPBtn  := _oLayer:GetWinPanel( "BUTTONS"   , "WNDBUTTONS"  , "LINE01" )
    _oPTree := _oLayer:GetWinPanel( "TREE"      , "WNDTREE"     , "LINE01" )

    _oTree := DbTree():New(0,0,0,0,_oPTree,,,.T.)
	_oTree:ALIGN := CONTROL_ALIGN_ALLCLIENT  
	
	//+------------------------------------------------------------------------+
	//| Monta o Tree View da Estrutura                                         |
	//+------------------------------------------------------------------------+
	_oTree:BeginUpdate()
	    EcLoj02Tree()
	_oTree:EndUpdate()

    //-----------------+
    // Botoes de Ações |
    //-----------------+
    _oBntInc    := TButton():New( 005, 020, "Incluir - F6", _oPBtn, {|| ECLOJ02A(1) }       , 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    _oBntDel    := TButton():New( 020, 020, "Exclui - F7" , _oPBtn, {|| ECLOJ02A(2) }       , 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    _oBntExit   := TButton():New( 035, 020, "Sair - F8"   , _oPBtn, {|| _oDlg:End() }        , 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    //---------------+
    // Enchoice Tela |
    //---------------+
    _oDlg:bInit := {|| EnchoiceBar(_oDlg,{|| _oDlg:End() },{|| _oDlg:End() },.F.)}

_oDlg:Activate(,,,.T.,,,)

SetKey( VK_F6, Nil )
SetKey( VK_F7, Nil )
SetKey( VK_F8, Nil )
SetKey( VK_F9, Nil )

RestArea(_aArea)
Return Nil

/*********************************************************************************/
/*/{Protheus.doc} EcLoj02Tree

@description Monta árvore

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
Static Function EcLoj02Tree(_cCategoria, _cCatPai, _nCargo, _nCargoPai)
Local _aArea        := GetArea()

Local _cTexto       := ""
Local _cCargo       := ""
Local _cCargoPai    := ""

Default _cCategoria := StrZero(0, _nTCodCat)
Default _cCatPai    := StrZero(0, _nTCodCat)
Default _nCargo     := 0
Default _nCargoPai  := 0

//----------------------+
// Posiciona categorias |
//----------------------+
dbSelectArea("AY0")
AY0->( dbSetOrder(1) )
AY0->( dbSeek(xFilial("AY0") + PadR(_cCategoria,_nTCodCat) ))

//--------------------+
// Grava as variaveis |
//--------------------+
_nCargo++
If _nCargo == 1
    _cTexto    := RTrim(_cCategoria) + " - ESTRUTURA DE CATEGORIAS"
Else
    _cTexto    := RTrim(_cCategoria) + " - " + AY0->AY0_DESC
EndIf 
_cCargo    := StrZero(_nCargo, _nTCodCat)
_cCargoPai := StrZero(_nCargoPai, _nTCodCat)

//----------------------+
// Posiciona Estruturas |
//----------------------+
dbSelectArea("AY1")
AY1->( dbSetOrder(1) )
If AY1->( dbSeek(xFilial("AY1") + _cCategoria) )
    _oTree:AddTree(_cTexto,.T.,,, "BPMSEDT3", "BPMSEDT3", _cCargo + _cCargoPai + _cCategoria + _cCatPai)
	_nCargoPai := _nCargo
	
	While AY1->( !Eof() .And. xFilial("AY1") + _cCategoria == AY1->AY1_FILIAL + AY1->AY1_CODIGO )
	    		
		EcLoj02Tree( RTrim(AY1->AY1_SUBCAT), RTrim(AY1->AY1_CODIGO), @_nCargo, _nCargoPai, .F.)
				
		AY1->( dbSkip() )	
	EndDo
	
	_oTree:EndTree()
Else
	_oTree:AddTreeItem(_cTexto, "BPMSEDT3",,  _cCargo + _cCargoPai + _cCategoria + _cCatPai)    
EndIf

RestArea(_aArea)
Return  .T.

/*********************************************************************************/
/*/{Protheus.doc} ECLOJ02A

@description Realiza as atualizações da Arvore de Categorias

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
Static Function EcLoj02A(_nOpcA)
Local _aArea        := GetArea()
Local _aXbNivel		:= {}

Local _cTitulo      := ""
Local _cCodCategP   := PadR("",_nTCodCat)
Local _cCodSubC     := PadR("",_nTCodCat)
Local _cF3Cat       := ""
Local _cSubCatDesc 	:= ""

Local _cCatePaiDesc := ""
Local _cSubCat 	    := PadR("",_nTCodCat)
Local _cCargo       := _oTree:GetCargo()  
Local _cCodPai		:= _oTree:GetPrompt()

Local _nPosCat      := 0

Local _lRet         := .T.
Local _lOutraEst    := .F. 
Local _lConfirma    := .F.  
Local _lOutras 	    := .F.

Local _oFont01      := TFont():New('Arial',,-10,.T.,.F.)
Local _oFont02      := TFont():New('Arial',,-12,.T.,.T.)
Local _oDlgEstr     := Nil
Local _oSayCat      := Nil
Local _oTGetCat     := Nil
Local _oSayCodC     := Nil
Local _oSaySubC     := Nil
Local _oTGetSCat    := Nil
Local _oSaySubCD    := Nil

Local _bVldCatP     := {|| EcLoj02G01(_cCodCategP,_cCatePaiDesc,_oSayCodC) }
Local _bVldSCat     := {|| EcLoj02G01(_cSubCat,_cSubCatDesc,_oSaySubCD) }

Private _cCategoria := PosChave(_cCargo,3)
Private _cCatPai    := PosChave(_cCargo,4)  
Private _cCatZero   := StrZero(0, _nTCodCat)
Private _cValIniCat := ""
Private _cValIniSub := ""

//--------+
// Inclui | 
//--------+
If _nOpcA == 1
    _cTitulo := "Estrutura - Incluir"     
//--------+
// Excluir |
//--------+
ElseIf _nOpcA == 2
    _cTitulo := "Estrutura - Excluir"     
Endif

//--------------------------------+
// Consulta Categorias pelo Nivel |
//--------------------------------+
aAdd(_aXbNivel,{"1","AY0NV1"})
aAdd(_aXbNivel,{"2","AY0NV2"})
aAdd(_aXbNivel,{"3","AY0NV3"})
aAdd(_aXbNivel,{"4","AY0NV4"})
aAdd(_aXbNivel,{"5","AY0NV5"})

//------------------------------+
// Localiza consulta pelo Nivel | 
//------------------------------+
dbSelectArea("AY0")
AY0->( dbSetOrder(1) )
//---------------------+    
// Inclusao / Exclusao |
//---------------------+    
If AY0->( dbSeek(xFilial("AY0") + PadR(_cCategoria,_nTCodCat)) )
    _nPosCat := aScan(_aXbNivel,{|x| RTrim(x[1]) == RTrim(Iif(!Empty(AY0->AY0_TIPO),Soma1(AY0->AY0_TIPO),"1"))})	
    If _nPosCat > 0
        _cF3Cat := _aXbNivel[_nPosCat][2]
    ElseIf PadR(_cCategoria,_nTCodCat) == "000"
        _cF3Cat := _aXbNivel[1][2]
    Else
        _cF3Cat := "AY0"	
    EndIf	
ElseIf PadR(_cCategoria,_nTCodCat) == "000"     
    _cF3Cat := _aXbNivel[1][2]
EndIf	

//------------------------+
// Monta Dialog principal |
//------------------------+
_oDlgEstr := TDialog():New(001,001,180,450,_cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.,,,,,,.F.)

    //-------------------------------------------+
    // Não permite fechar a tela com a tecla ESC |
    //-------------------------------------------+
    _oDlgEstr:lEscClose := .T.
	
    //-----------------------------------------------------+
    // Panel tela de manutenção da Estrutura de Categorias |
    //-----------------------------------------------------+
	_oPanel:= TPanel():New(0, 0, "", _oDlgEstr, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
	_oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    //-----------+
    // Alteração |
    //-----------+
    If _nOpcA == 2
        _cCodCategP     := _cCatPai
        _cCatePaiDesc   := Posicione("AY0",1,xFilial("AY0") + _cCatPai,"AY0_DESC")
        _cSubCat        := _cCategoria
        _cSubCatDesc    := Posicione("AY0",1,xFilial("AY0") + _cSubCat,"AY0_DESC")
    Else
        _cCodCategP     := SubStr(_oTree:GetPrompt(),1,_nTCodCat)
        _cCatePaiDesc   := Posicione("AY0",1,xFilial("AY0") + _cCodCategP,"AY0_DESC")
    EndIf    

    _oSayCat        := TSay():New(011, 010, {|| "Categoria: " }, _oPanel,,_oFont02,,,,.T.,CLR_BLACK,CLR_WHITE,070,15)
    _oTGetCat       := TGet():New(010, 065, {|u| IIF(PCount() > 0, _cCodCategP := u, _cCodCategP) }  , _oPanel, 040, 009, PesqPict("AY0","AY0_CODIGO"),_bVldCatP,,,_oFont01,,,.T.,,,,,,,.T.,,, "_cCodCategP",,,,.T.)
    _oSayCodC       := TSay():New(011, 115, {|| _cCatePaiDesc }, _oPanel,,_oFont02,,,,.T.,CLR_BLACK,CLR_WHITE,100,10)

    _oSaySubC       := TSay():New(025, 010, {|| "Sub-Categoria: " },_oPanel,,_oFont02,,,,.T.,CLR_BLACK,CLR_WHITE,070,15)                                             
    _oTGetSCat      := TGet():New(024, 065, {|u| IIF(PCount() > 0, _cSubCat := u, _cSubCat) }, _oPanel, 040, 009, PesqPict("AY0","AY0_CODIGO"),_bVldSCat,,,_oFont01,,,.T.,,,,,,,IIF(_nOpcA == 1,.F.,.T.),,,"_cSubCat",,,,.T.)
    _oTGetSCat:cF3  := IIF(_nOpcA == 1,_cF3Cat,Nil)
    _oSaySubCD      := TSay():New(025, 115, {|| _cSubCatDesc },_oPanel,,_oFont01,,,,.T.,CLR_BLACK,CLR_WHITE,100,10)                                             
	
	_oPanelBot:= TPanel():New(000, 000, "", _oPanel, NIL, .T., .F., NIL, NIL, 0,015, .T., .F. )
	_oPanelBot:Align:= CONTROL_ALIGN_BOTTOM
	
    //--------+
    // Fechar | 
    //--------+
    _oBntExit   := TButton():New( 002, 125, "&Confirmar", _oPanelBot, {|| IIF(EcLo02Grv(_cCodCategP,_cSubCat,_nOpcA), _oDlgEstr:End(), ) }      , 40,11,,,.F.,.T.,.F.,,.F.,,,.F. )
    _oBntExit   := TButton():New( 002, 170, "&Fechar"   , _oPanelBot, {|| _oDlgEstr:End() }                                                     , 40,11,,,.F.,.T.,.F.,,.F.,,,.F. )

_oDlgEstr:Activate(,,,.T.,,,)

RestArea(_aArea)
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} EcLo02Grv

@description Valida posição da estrutura

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
Static Function EcLo02Grv(_cCodPai,_cSubCat,_nOpcA)

    Local _nCargo1 		:= 0
	Local _nCargo2 		:= 0

	Local _cCargo    	:= ""
	Local _cDescSubCat	:= ""
	Local _cCargo1		:= ""
	Local _cCargo2 		:= ""
	Local _cTitulo 		:= ""

	Local _lRet         := .T.     
    Local _lOutraEst    := .F.
    Local _lOutras      := .F.

    Local _bConfirma    := Nil

    Private _aSubExcl   := {}

    Default _cCodPai    := ""
    Default _cSubCat    := ""
    Default _nOpcA      := 1

    //-------------------+
    // Default variaveis |
    //-------------------+
    _cCargo    		    := _oTree:GetCargo()  
    _cDescSubCat		:= AY0->AY0_DESC

    _nCargo1 			:= Val( PosChave(_cCargo,2) ) + 1
	_nCargo2 			:= Val( PosChave(_cCargo,2) ) 

	_cCargo1			:= StrZero(_nCargo1,_nTCodCat)
	_cCargo2 			:= StrZero(_nCargo2,_nTCodCat)   
	_cTitulo 			:= RTrim(AY0->AY0_CODIGO) + " - " + AY0->AY0_DESC

    If _nOpcA == 1

        If !Vazio(_cSubCat) .And. ExistCpo('AY0',_cSubCat,1)  

             //---------------------+
            // Posiciona Estrutura |
            //---------------------+
            dbSelectArea("AY1")
            AY1->( dbSetOrder(1) )

            //--------------------------------------------------------------+
            // Verifica se já não existe esta subcategoria para a categoria |
            //--------------------------------------------------------------+
            If !AY1->( dbSeek(xFilial("AY1") + _cCategoria + _cSubCat) )
                
                //--------------------------------------------------------------------------------------------------------+
                // Valida referência circular, subcategoria igual categoria e se já não existe aquela subcategoria no pai |
                //--------------------------------------------------------------------------------------------------------+
                If !EcLoj02Ref(_cCategoria, _cSubCat) .And. _cCategoria <> _cSubCat  
                
                    While _oTree:TreeSeek(_cCargo1 + _cCargo2 + _cSubCat + _cCategoria)
                        _nCargo1 += 1
                        _cCargo1 := StrZero(_nCargo1,_nTCodCat)
                        _cCargo2 := StrZero(_nCargo2,_nTCodCat)
                    EndDo

                    //--------------------------+
                    // Atualiza dados Estrutura |
                    //--------------------------+ 
                    RecLock("AY1",.T.) 
                        AY1->AY1_FILIAL := xFilial("AY1")	
                        AY1->AY1_CODIGO := _cCategoria
                        AY1->AY1_SUBCAT := _cSubCat
                        AY1->AY1_DESCSU := _cDescSubCat
                        AY1->AY1_CATPAI := _cCatPai + _cCategoria
                        AY1->AY1_CATFIL := _cCategoria + _cSubCat
                    AY1->( MsUnLock() )
                    
                    _oTree:AddItem(_cTitulo,_cCargo1 + _cCargo2 + _cSubCat + _cCategoria,"BPMSEDT3",,,,2)	
                    _oTree:TreeSeek(_cCargo1 + _cCargo2 + _cSubCat + _cCategoria)   
                    _oTree:TreeSeek(_cCargo)  
                    _lRet := .T.
                Else           
                    MsgAlert("Não é possível incluir esta categoria pois irá criar uma referência circular!","Atenção!")
                    _lRet := .F.    	
                EndIf   
            Else           
                MsgAlert("Esta sub-categoria já esta cadastradada para a categoria!","Atenção!")
                _lRet := .F.    	
            EndIf
        Else
            MsgAlert("Informe uma categoria válida!","Atenção!")
            _lRet := .F.    
        EndIf
    //--------+    
    // Exclui |
    //--------+    
	Else
        //---------------------------------------+
        // Valida se estrutura pode ser excluida |
        //---------------------------------------+
        If EcLoj02Vld(_cSubCat)
            //---------------------+
            // Posiciona Estrutura |
            //---------------------+
            dbSelectArea("AY1")
            AY1->( dbSetOrder(1) )

            If AY1->( dbSeek(xFilial("AY1") + _cSubCat) )
                //+------------------------------------------------------------------------+
                //| Verifica se esta sub-categoria não está em outra estrutura.            |
                //+------------------------------------------------------------------------+ 
                dbSelectArea("AY1")
                AY1->( dbSetOrder(2) )
                If AY1->( dbSeek(xFilial("AY1") + _cSubCat))
                    While AY1->( !Eof() .And. xFilial("AY1") + _cSubCat == AY1->AY1_FILIAL + AY1->AY1_SUBCAT )
                        If AY1->AY1_CODIGO <> _cCodPai
                            _lOutraEst := .T.
                            Exit
                        EndIf
                        AY1->(dbSkip())
                    EndDo
                EndIf
                            
                If (!_lOutraEst .And. _cSubCat <> _cCatZero)  
                    _lOutras := .T.
                    _bConfirma := MsgYesNo( 'Esta categoria possui sub-categorias relacionadas e ao exclui-la suas sub-categorias também serão excluidas!' + CHR(13) + CHR(10) + CHR(13) + CHR(10) + 'Confirma a exclusão?' , 'Aviso!' )					
                EndIf
            EndIf
        

            //--------------------+
            // Posicona Estrutura |
            //--------------------+
            dbSelectArea("AY1")	
            If !_lOutras
                If _cSubCat <> _cCatZero       
                    _bConfirma := MsgYesNo( 'Confirma a exclusão da categoria?' , 'Aviso!' )					
                    If _bConfirma
                        AY1->( dbSetOrder(1) )
                        If AY1->( dbSeek(xFilial("AY1") + _cCodPai + _cSubCat)) 
                            RecLock("AY1",.F.)
                                AY1->( DbDelete() )
                            AY1->( MsUnLock() )
                            _oTree:DelItem()
                        EndIf  
                    EndIf    
                EndIf
            Else
                If _bConfirma
                    AY1->( dbSetOrder(2) )
                    If AY1->( dbSeek(xFilial("AY1") + _cSubCat) )
                        While AY1->( !Eof() .And. xFilial("AY1") + _cSubCat == AY1->AY1_FILIAL + AY1->AY1_SUBCAT )
                            aAdd(_aSubExcl,{AY1->AY1_SUBCAT})  
                            LjMsgRun('Aguarde excluindo categoria e sub-categorias...' , , { || EcLoj02Del(AY1->AY1_SUBCAT)  } )						 
                            RecLock("AY1",.F.)
                                AY1->( DbDelete() )
                            AY1->( MsUnLock() )
                            
                            AY1->( dbSkip() )
                        EndDo	
                    EndIf 
                    _oTree:DelItem()
                EndIf		
            EndIf
        Else
            _lRet := .F.
        EndIf
    EndIf

    //-----------------+
    // Atualiza arvore |
    //-----------------+
    EcLoj02Rel(_cCargo)

Return _lRet

/*********************************************************************************/
/*/{Protheus.doc} EcLoj02Del

@description Realiza a deleção de uma determinada estrutura

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
Static Function EcLoj02Del(_cCodigo)     
   
Local _aArea    	:= GetArea()

dbSelectArea("AY1")
AY1->( dbSetOrder(1) )

If AY1->( dbSeek(xFilial("AY1") + _cCodigo))
	While AY1->( !Eof() .And. xFilial("AY1") + _cCodigo	== AY1->AY1_FILIAL + AY1->AY1_CODIGO )

		aAdd(_aSubExcl,{AY1->AY1_SUBCAT})

		EcLoj02Del(AY1->AY1_SUBCAT)  
		
		RecLock("AY1",.F.)
		    AY1->( dbDelete() )
		AY1->( MsUnLock() )
			
		AY1->(dbSkip())
	EndDo	
EndIf 	
	
RestArea(_aArea)
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} EcLoj02Ref

@description Verifica se determinada estrutura não é caracterizada por uma referência circular.

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
Static Function EcLoj02Ref(_cCateg, _cSubCat)

Local _aArea    := GetArea()
Local _lRet     := .F.

//---------------------+
// Posiciona estrutura |
//---------------------+
dbSelectArea("AY1")
AY1->( dbSetOrder(1) ) 

If AY1->( dbSeek(xFilial("AY1") + _cSubCat) )
	While AY1->( !Eof() .And. xFilial("AY1") + _cSubCat == AY1->AY1_FILIAL + AY1->AY1_CODIGO )
	    If AY1->AY1_SUBCAT == _cCateg .Or. EcLoj02Ref(_cCateg, AY1->AY1_SUBCAT)
	    	lRet := .T.
	    	Exit
	    EndIf
		AY1->( dbSkip() )
	EndDo
EndIf

RestArea(_aArea)
Return lRet

/*********************************************************************************/
/*/{Protheus.doc} EcLoj02G01

@description Valida posição da estrutura

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
Static Function EcLoj02Rel(_cCargo)

Default _cCargo := ""

    AY1->( dbGoTo(_nRecNo) )

    _oTree:Reset()
    _oTree:BeginUpdate()
        EcLoj02Tree()
    _oTree:EndUpdate()
    _oTree:EndTree()

    If !Empty(_cCargo)
        _oTree:TreeSeek(_cCargo)
    EndIf

Return .T.

/*********************************************************************************/
/*/{Protheus.doc} EcLoj02G01

@description Valida posição da estrutura

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
Static Function EcLoj02G01(_cCodPai,_cDescCat,_oObject)
Local _aArea    := GetArea()

//----------------------+
// Posiciona Categorias |
//----------------------+
dbSelectArea("AY0")
AY0->( dbSetOrder(1) )
AY0->( dbSeek(xFilial("AY0") + PadR(_cCodPai,_nTCodCat)) )
_cDescCat := AY0->AY0_DESC

_oObject:SetText(_cDescCat)
_oObject:Refresh()

RestArea(_aArea)
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} PosChave

@description Valida posição da estrutura

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
Static Function PosChave(_cChave,_nPos)
    Local _cRet := ""
    Local _nIni := (_nTCodCat * _nPos) - (_nTCodCat - 1)

    _cRet := SubStr(_cChave,_nIni,_nTCodCat)
Return _cRet 

/*********************************************************************************/
/*/{Protheus.doc} EcLoj02Vld(_cSubCat)

@description Valida se estrutura pode ser deletada

@type  Function
@author Bernard M. Margarido

@since 14/05/2019
/*/
/*********************************************************************************/
Static Function EcLoj02Vld(_cSubCat)
Local _aArea        := GetArea()

Local _cTipo        := ""
Local _cMsg         := ""

Local _leCommerce   := GetNewPar("EC_USAECO",.T.)
Local _lRet         := .T.
Local _lExclui      := .T.

//---------------------+
// Posiciona categoria |
//---------------------+
dbSelectArea("AY0")
AY0->( dbSetOrder(1) )
AY0->( dbSeek(xFilial("AY0") + _cSubCat) )
_cTipo := AY0->AY0_TIPO

//----------------------------------------------------+
// Consulta se categoria já foi enviada ao e-Commerce |
//----------------------------------------------------+
If _leCommerce .And. _lExclui
    FWMsgRun(, {|| _lExclui := U_AEcoI01C(AY0->AY0_XIDCAT) }, "Aguarde....", "Consultando categoria e-Commerce. " )
    _cMsg := IIF(_lExclui,"Categoria cadastrada no e-Commerce. Favor inativar categoria.","")
Endif

//------------------------------------------------+
// Valida se categoria está amarrada a um produto | 
//------------------------------------------------+
If !_lExclui
    FWMsgRun(, {|| _lExclui := EcLoj02VPrd(_cSubCat,_cTipo) }, "Aguarde....", "Consultando categoria e-Commerce. " )
    _cMsg := IIF(_lExclui,"Categoria amarrada a produtos. Alterar categoria do produto.","")
EndIf

If _lExclui
    MsgAlert("Não é possivel excluir estrutura " + _cMsg,"Aviso")
    _lRet := .F.
EndIf

RestArea(_aArea)
Return _lRet

/*********************************************************************************/
/*/{Protheus.doc} EcLoj02VPrd

@descripion Valida se categoria está amarrada no produto

@type  Function
@author Bernard M. Margarido

@since 14/05/2019
/*/
/*********************************************************************************/
Static Function EcLoj02VPrd(_cSubCat,_cTipo)
Local _aArea    := GetArea()

Local _cQuery   := ""
Local _cAlias   := GetNextAlias()

Local _lRet     := .T.

_cQuery := " SELECT " + CRLF
_cQuery += "	PRODUTO " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += " ( " + CRLF
_cQuery += "	SELECT " + CRLF
_cQuery += "		B5.B5_COD PRODUTO " + CRLF
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("SB5") + " B5 " + CRLF 
_cQuery += "	WHERE " + CRLF
_cQuery += "		B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF

If _cTipo == "1"
    _cQuery += "		B5.B5_XCAT01 = '" + _cSubCat + "' AND " + CRLF
ElseIf _cTipo == "2"
    _cQuery += "		B5.B5_XCAT02 = '" + _cSubCat + "' AND " + CRLF
ElseIf _cTipo == "3"
    _cQuery += "		B5.B5_XCAT03 = '" + _cSubCat + "' AND " + CRLF
ElseIf _cTipo == "4"
    _cQuery += "		B5.B5_XCAT04 = '" + _cSubCat + "' AND " + CRLF
ElseIf _cTipo == "5"
    _cQuery += "		B5.B5_XCAT05 = '" + _cSubCat + "' AND " + CRLF
EndIf

_cQuery += "		B5.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	UNION ALL " + CRLF
_cQuery += "	SELECT " + CRLF
_cQuery += "		B4.B4_COD PRODUTO " + CRLF 
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("SB4") + " B4 " + CRLF 
_cQuery += "	WHERE " + CRLF
_cQuery += "		B4.B4_FILIAL = '" + xFilial("SB4") + "' AND " + CRLF

If _cTipo == "1"
    _cQuery += "		B4.B4_01CAT1 = '" + _cSubCat + "' AND " + CRLF
ElseIf _cTipo == "2"
    _cQuery += "		B4.B4_01CAT2 = '" + _cSubCat + "' AND " + CRLF
ElseIf _cTipo == "3"
    _cQuery += "		B4.B4_01CAT3 = '" + _cSubCat + "' AND " + CRLF
ElseIf _cTipo == "4"
    _cQuery += "		B4.B4_01CAT4 = '" + _cSubCat + "' AND " + CRLF
ElseIf _cTipo == "5"
    _cQuery += "		B4.B4_01CAT5 = '" + _cSubCat + "' AND " + CRLF
EndIf

_cQuery += "		B4.D_E_L_E_T_ = '' " + CRLF
_cQuery += ") CATXPROD "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If Empty((_cAlias)->PRODUTO)
    _lRet := .F.
EndIf

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return _lRet