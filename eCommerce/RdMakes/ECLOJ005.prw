#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} ECLOJ005
    @description Produtos com Grade
    @author Bernard M. Margarido
    @since 29/04/2019
    @version undefined
    @type function
/*/
/************************************************************************************/
User Function ECLOJ005()
Private oBrowse		:= Nil

Private aRotina     := MenuDef()

//---------------------------------+
// Instanciamento da Classe Browse |
//---------------------------------+
oBrowse := FWMBrowse():New()

//------------------+
// Tabela utilizado |
//------------------+
oBrowse:SetAlias("SB4")

//-------------------+
// Adiciona Legendas |
//-------------------+
oBrowse:AddLegend("SB4_STATUS == '1' "	,"GREEN"				,"Ativo")
oBrowse:AddLegend("SB4_STATUS == '2' "	,"RED"					,"Inativo")

//------------------+
// Titulo do Browse |
//------------------+
oBrowse:SetDescription('Produtos - Grade')

//--------------------+
// Ativação do Browse |
//--------------------+
oBrowse:Activate()

Return Nil

/************************************************************************************/
/*/{Protheus.doc} ECLOJ05A

@description Produtos com Grade

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
User Function ECLOJ05A(cAlias,nReg,nOpc)
Local _aArea        := GetArea()
Local _aCoors       := FWGetDialogSize( oMainWnd )
Local _aMascara	    := Separa(GetMv('MV_MASCGRD'),',')

Local _cTitulo      := "Produtos - Grade"

Local _nOpcA        := 0

Local _oSize        := FWDefSize():New( .T. )
Local _oLayer       := FWLayer():New()
Local _oDlg         := Nil
Local _oPCab        := Nil
Local _oPItem       := Nil
Local _oMsMGet      := Nil  
Local _oFolder      := Nil

Private _nTamPai 	:= Val(_aMascara[1])
Private _nTamLin 	:= Val(_aMascara[2])
Private _nTamCol 	:= Val(_aMascara[3])
Private _nTamRef 	:= IIF(Len(_aMascara) == 4, Val(_aMascara[4]),0)
Private _aCposVis   := {}
Private _aCposAlt   := {}
Private _aHeaderGrd := {}
Private _aColsGrd   := {}
Private _aRef       := {}

Private aTela[0][0]
Private aGets[0]

Private _oMsGetGrd    := Nil

//-----------------+
// Campos Enchoice | 
//-----------------+
EcLoj05Cab(cAlias,nReg,nOpc)

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp            := .T.
_oSize:lLateral 	    := .T.
_oSize:Process()

//-----------------------------+
// Utiliza variavel em memoria |
//-----------------------------+
RegToMemory(cAlias, IIF(nOpc == 3,.T.,.F.) )

//-------------------+
// Monta Array Grade |
//-------------------+
EcLoj05Grd(M->B4_LINHA,M->B4_COLUNA,M->B4_COD)

//------------------------+
// Monta Dialog principal |
//------------------------+
_oDlg := MsDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3], _oSize:aWindSize[4],_cTitulo,,,,,,,,,.T.)

    //--------------------+
    // Layer da estrutura |
    //--------------------+
    _oLayer:Init( _oDlg, .F. )
    _oLayer:AddLine( "LINE01", 055 )
    _oLayer:AddLine( "LINE02", 045 )

    _oLayer:AddCollumn( "COLLL01"  , 100,, "LINE01" )
    _oLayer:AddCollumn( "COLLL02"  , 100,, "LINE02" )

    _oLayer:AddWindow( "COLLL01" , "WNDCABEC"  , ""     , 100 ,.F. ,,,"LINE01" )
    _oLayer:AddWindow( "COLLL02" , "WNDITEMS"  , ""     , 095 ,.F. ,,,"LINE02" )

    _oPCab  := _oLayer:GetWinPanel( "COLLL01"   , "WNDCABEC"  , "LINE01" )
    _oPItem := _oLayer:GetWinPanel( "COLLL02"   , "WNDITEMS"  , "LINE02" )

    _oMsMGet := MsMGet():New(cAlias, nReg, nOpc,,,,_aCposVis,_oSize:aPosObj[1],_aCposAlt,,,,,_oPCab,,.F.,.T.)
	_oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

    //------------+
    // Folder SKU |
    //------------+
    _oFolder:=TFolder():New(0,0,{"Grade","SKU","Características"},,_oPItem,,,,.T.,.F.,0,0)
	_oFolder:Align := CONTROL_ALIGN_ALLCLIENT

    //-------------------+
    // Grade de Produtos |
    //-------------------+
    _oMsGetGrd := MsNewGetDados():New(_oSize:aPosObj[2,1],_oSize:aPosObj[2,2],_oSize:aPosObj[2,3],_oSize:aPosObj[2,4],GD_INSERT+GD_UPDATE+GD_DELETE,"U_MA06LinOk()","U_MA06TudOk","MAREF",_aAlter,,,,,,_oFolder:aDialogs[1],_aHeaderGrd,_aColsGrd)
	_oMsGetGrd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	_oMsGetGrd:lDelete := .F.
	_oMsGetGrd:lActive := IIF( M->B4_01UTGRD == 'S' , .T. , .F. )
	_oMsGetGrd:GoTop()

    //---------------+
    // Enchoice Tela |
    //---------------+
    _oDlg:bInit := {|| EnchoiceBar(_oDlg,{|| IIf(Obrigatorio(aGets,aTela), (_nOpcA := 1 ,_oDlg:End()) ,_nOpcA := 0) },{|| _oDlg:End() },.F.)}

_oDlg:Activate(,,,.T.,,,)

//--------------------+
// Realiza a gravação |
//--------------------+
If _nOpcA == 1
    Begin Transaction
		FWMsgRun(, {|| EcLoj05Grv(nOpc) }, "Aguarde...", "Gravando dados..." )
	End Transaction     
EndIf

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj05Grv

@description Realiza a gravação do produto com grade

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj05Grv(nOpc)
Local _aArea    := GetArea()
Local _lRet     := .T.

RestArea(_aArea)
Return _lRet

/************************************************************************************/
/*/{Protheus.doc} EcLoj05Cab

@description Cria campos de alteração e visualização

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj05Cab(cAlias,nReg,nOpc)

//-----------------------------------+
// Tratamento dos Campos Alteraveis  |
//-----------------------------------+
aAdd(_aCposVis,"NOUSER")

SX3->( dbSetOrder(1) )
SX3->( dbSeek("SB4") )

While SX3->( !Eof() .And. SX3->X3_ARQUIVO == "SB4" )
    If ( X3Uso( SX3->X3_USADO ) .And. cNivel >= SX3->X3_NIVEL )
        aAdd(_aCposAlt,SX3->X3_CAMPO)
        aAdd(_aCposVis,SX3->X3_CAMPO)
    EndIF
    SX3->( dbSkip() )
EndDo

Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj05Arr

@description Cria array da grade de produtos

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj05Grd(_cLinha,_cColuna,_cProdPai)
Local _aArea    := GetArea()

    //-------------+
    // Monta Grade |
    //-------------+
	EcLoj05Mtn(_cLinha,_cColuna,_cProdPai) 
	
    //MontaCarac(cProdPai,"AY5") 
	//MontaBarra(cLinha,cColuna,cProdPai)
	
RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} EcLoj05Mtn

@description Cria array da grade de produtos

@author Bernard M. Margarido

@since 10/08/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function EcLoj05Mtn(_cLinha,_cColuna,_cProdPai) 
Local _aArea	    := GetArea()
Local _nY 		    := 0

_cProdPai := Padr(Substr(_cProdPai,1,_nTamPai),_nTamPai)

//----------------+
// Monta o Header |
//----------------+
_aHeaderGrd	:= {}
_aColsGrd 	:= {}
__aAlter	:= {}

aAdd(_aHeaderGrd,{'Referência'  		    ,'MAREF'	,'@S10'	,TamSx3("B1_01DREF")[1]		,0,'U_MAVDREF()'	,'û','C',''			,'' } )
aAdd(_aHeaderGrd,{'Cor'		   			    ,'MACOR'	,'@!'	,_nTamLin  	   	  			,0,'U_MAVDCOR1()'	,'û','C','SBVCOR'	,'' } )
aAdd(_aHeaderGrd,{'Descrição'   		    ,'MADES'	,'@!'	,15		   					,0,'.F.'			,'û','C',''			,'' } )
If GetMv('MV_01UTGRC',,.F.)
    aAdd(_aHeaderGrd,{'Grp. Cores'		    ,'MAGRPCOR'	,'@!'	,TamSx3("BV_01DESGR")[1]	,0,'.F.'			,'û','C',''			,'' } )
EndIf
aAdd(_aHeaderGrd,{RetTitle('B1_01CODFO')	,'MACODFOR'	,'@!'	,TamSx3("B1_01CODFO")[1]	,0,'.T.'			,'û','C',''			,'' } )
aAdd(_aHeaderGrd,{'Packs'                   ,'MAPACK'	,'@!'   ,TamSx3("B1_01PACKS")[1]	,0,'ExistCpo("AY7")','û','C','AY7PAK'	,'' } )

aAdd(_aAlter,_aHeaderGrd[Len(_aHeaderGrd),2])
IF _nTamRef > 0
    aAdd(__aAlter,_aHeaderGrd[Len(_aHeaderGrd),2])
EndIF
aAdd(_aAlter,_aHeaderGrd[Len(_aHeaderGrd),2])
aAdd(_aAlter,_aHeaderGrd[Len(_aHeaderGrd),2])

nCol_Tam := Len(_aHeaderGrd)

SBV->(DbOrderNickName('SYMMSBV03'))
SBV->(DbSeek(xFilial('SBV') + _cColuna))
While SBV->( !Eof()  .And. SBV->BV_TABELA == _cColuna )
    aAdd(_aHeaderGrd,{'-'+Alltrim(SBV->BV_DESCRI)+'-','_'+Substr(SBV->BV_CHAVE,1,_nTamCol),'@!',1,0,'U_SyA550Valid()','û','C','',''})
    aAdd(_aAlter,'_'+Substr(SBV->BV_CHAVE,1,_nTamCol))
    SBV->( dbSkip() )
EndDo

If !Empty(_cProdPai)

    SB1->( dbSetOrder(1) )
    SB1->( dbSeek(xFilial('SB1') + _cProdPai) )

    While SB1->( !Eof() .And. xFilial("SB1") + _cProdPai == SB1->B1_FILIAL + Padr(Substr(SB1->B1_COD,1,_nTamPai),_nTamPai ) )

        _nPos := aScan(_aColsGrd,{|x| x[1] + x[2] == SB1->B1_01DREF + SB1->B1_01LNGRD } )
        
        If _nPos == 0
            aAdd(_aColsGrd,Array(Len(_aHeaderGrd)+1))
            _nPos := Len(_aColsGrd)

            For _nY := 1 To Len(_aHeaderGrd)
                _aColsGrd[_nPos,_nY] := Space(_aHeaderGrd[_nY,4] + _aHeaderGrd[_nY,5])
            Next _nY

            _aColsGrd[Len(_aColsGrd)][Len(_aHeaderGrd) + 1] := .F.

        EndIF

        If _nTamRef > 0	
            nCodRef := aScan(_aRef, {|x| x[1] == AllTrim(SB1->B1_01DREF)})
            If  nCodRef == 0	
                aAdd(_aRef, {AllTrim(SB1->B1_01DREF), AllTrim(SB1->B1_01RFGRD)})
            EndIf		
        EndIf

        For _nY := 1 To Len(_aHeaderGrd)

            IF _aHeaderGrd[_nY,2] == 'MAREF'
                _aColsGrd[nPos,_nY] := SB1->B1_01DREF
            ElseIF _aHeaderGrd[_nY,2] == 'MACOR'
                _aColsGrd[nPos,_nY] := SB1->B1_01LNGRD
            ElseIF _aHeaderGrd[_nY,2] == 'MADES'
                _aColsGrd[nPos,_nY] := Posicione('SBV',1,xFilial('SBV') + cLinha + SB1->B1_01LNGRD,'BV_DESCRI')
            ElseIF _aHeaderGrd[_nY,2] == 'MAGRPCOR'
                _aColsGrd[nPos,_nY] := Posicione('SBV',1,xFilial('SBV') + cLinha + SB1->B1_01LNGRD,'BV_01DESGR')
            ElseIF _aHeaderGrd[_nY,2]== 'MACODFOR'
                _aColsGrd[nPos,_nY] := SB1->B1_01CODFO
            ElseIF _aHeaderGrd[_nY,2]== 'MAPACK'
                _aColsGrd[nPos,_nY] := SB1->B1_01PACKS
            ElseIF Substr(_aHeaderGrd[_nY,2],1,2) == "C_"
                _aColsGrd[nPos,_nY] := Posicione("AY5",3,xFilial("AY5") + Substr(_aHeaderGrd[_nY,2],3,TamSx3("AY3_CODIGO")[1])+;
                PadR(_cProdPai,TamSx3("AY5_CODPRO")[1]) + SB1->B1_01RFGRD + SB1->B1_01LNGRD,"AY5_SEQ")
            ElseIF Alltrim(SB1->B1_01CLGRD) == Alltrim(Substr(_aHeaderGrd[_nY,2],2,_nTamCol)) .And. Substr(_aHeaderGrd[_nY,2],1,2) <> "C_" 
                _aColsGrd[nPos,_nY] := 'X'
            EndIF
        Next _nY

        _aColsGrd[Len(_aColsGrd)][Len(_aHeaderGrd)+1] := .F.

        SB1->(DbSkip())

    EndDo
EndIf

IF Len(_aColsGrd) == 0
    aAdd(_aColsGrd,Array(Len(_aHeaderGrd)+1))
    For _nY := 1 To Len(_aHeaderGrd)
        IF _aHeaderGrd[_nY,8] == 'C'
            _aColsGrd[Len(_aColsGrd)][_nY]:= Space(_aHeaderGrd[_nY,4])
        ElseIF _aHeaderGrd[_nY,8] == 'N'
            _aColsGrd[Len(_aColsGrd)][_nY]:= 0
        EndIF
    Next
    _aColsGrd[Len(_aColsGrd)][Len(_aHeaderGrd)+1] := .F.
EndIF

//-----------------------------+
// Ordena coluna da descricao  |
//-----------------------------+
aSort(_aColsGrd,,,{ |x,y| y[1]+y[2] > x[1]+x[2] } )

//--------------------------------------------------------------+
// Ordena array de referencias. Necessario para garantir que a  |
// ultima referencia do array e a maior, para geracao das novas |
//--------------------------------------------------------------+
aSort(_aRef,,,{ |x,y| y[2] > x[2] } )

IF ValType(_oMsGetGrd) == "O"
    _oMsGetGrd:oBrowse:Refresh()
EndIf

RestArea(_aArea)
Return Nil

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
    aAdd(aRotina, {"Visualizar" , "U_ECLOJ05A"  , 0, 2 })  // Visualizar
    aAdd(aRotina, {"Incluir"    , "U_ECLOJ05A"  , 0, 3 })  // Incluir
    aAdd(aRotina, {"Alterar"    , "U_ECLOJ05A"  , 0, 4 })  // Alterar
    aAdd(aRotina, {"Excluir"    , "U_ECLOJ05A"  , 0, 5 })  // Excluir
Return aRotina
