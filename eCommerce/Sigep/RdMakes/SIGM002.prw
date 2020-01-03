#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/**********************************************************************/
/*/{Protheus.doc} SIGM002

@description Solicita a etiqueta de postagem  

@author Bernard M. Margarido
@since 08/02/2017
@version undefined

@type function
/*/
/**********************************************************************/
User Function SIGM002(cIdEtq)
Local _aArea		:= GetArea()

//-----------------------------------+
// Valida se existem dados na tabela |
//-----------------------------------+
If !SigM02Qry()
	//--------------------+
	// Solicita Etiquetas |
	//--------------------+
	FwMsgRun(,{|| SigM02A()},"Aguarde...","Consultando etiquetas")
Else
	//----------------------------+
	// Tela etiquetas solicitadas |
	//----------------------------+
	FwMsgRun(,{|| SigM02B()},"Aguarde...","Tela etiquetas solicitadas")	
EndIf	

RestArea(_aArea)
Return lRet

/************************************************************************************/
/*/{Protheus.doc} SigM02A
@description Gera novas etiquetas 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function SigM02A()
Local _cMsg			:= ""

Local _lRet 		:= .T.

Local  _oSigWeb		:= SigepWeb():New

//--------------------+
// Consulta Contratos |
//--------------------+
If _oSigWeb:GrvCodEtq()
	_cMsg 	:= "Etiquetas gravados com sucesso. Deseja abrir tela de consulta?"
	_lRet	:= .F.
Else
	_cMsg 	:= _oSigWeb:cError
	_lRet	:= .F.
EndIf

If _lRet
	If MsgYesNo(_cMsg,"Dana Cosmeticos - Avisos")
		FwMsgRun(,{|| SigM02B()},"Aguarde...","Tela etiquetas solicitadas")
	EndIf
Else
	MsgAlert(_cMsg,"Dana Cosmeticos - Avisos")
EndIf

Return _lRet

/************************************************************************************/
/*/{Protheus.doc} SigM02B
@description Tela consulta etiquetas disponiveis 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function SigM02B()
Local _aArea	:= GetArea()
Local _aCoors   	:= FWGetDialogSize( oMainWnd )
Local _aButtons		:= {}

Local _cTitulo  	:= "Etiquetas disponiveis."

Local _oSize    	:= FWDefSize():New( .T. )
Local _oLayer   	:= FWLayer():New()
Local _oDlg     	:= Nil
Local _oPCab		:= Nil
Local _oPnlBtn		:= Nil
Local _oButtonOk	:= Nil
Local _oButtonCa	:= Nil
Local _oButtonPq	:= Nil
Local _oButtonPr	:= Nil
Local _oPnlInf		:= Nil

Local _nLinIni 		:= 0
Local _nColIni 		:= 0
Local _nLinFin 		:= 0
Local _nColFin 		:= 0
Local _nOpcA		:= 1

Private aHeader		:= {}
Private aCols		:= {}
Private aAlter		:= {}

Private _oMsGetVnd	:= Nil	

//---------------------+
// Cria header e acols | 
//---------------------+
SigM02BHead()

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolução  |
//-------------------------------------------------------+
_oSize:AddObject( "DLG", 100, 100, .T., .T.)
_oSize:SetWindowSize(_aCoors)
_oSize:lProp         := .T.
_oSize:lLateral 	 := .T.
_oSize:Process()

//------------------------+
// Monta Dialog principal |
//------------------------+
_oDlg := MsDialog():New(_oSize:aWindSize[1], _oSize:aWindSize[2],_oSize:aWindSize[3] - 050, _oSize:aWindSize[4] - 300,_cTitulo,,,,DS_MODALFRAME,,,,,.T.)
	
	//----------------------+
	// Fecha janela com ESC |
	//----------------------+
	_oDlg:lEscClose := .F.
	
	_nLinIni := _oSize:GetDimension("DLG","LININI")
	_nColIni := _oSize:GetDimension("DLG","COLINI")
	_nLinFin := _oSize:GetDimension("DLG","LINEND")
	_nColFin := _oSize:GetDimension("DLG","COLEND")
	
	//-------------------------+
	// Painel para informações | 
	//-------------------------+
	_oPnlInf := TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,CLR_CINZA,000,030,.T.,.F.)
	_oPnlInf:Align := CONTROL_ALIGN_TOP
				
	//--------------------+
    // Layer da estrutura |
    //--------------------+
    _oLayer:Init( _oDlg, .F. )
    _oLayer:AddLine( "LINE01", 100 )
    
    _oLayer:AddCollumn( "COLLL01"  , 100,, "LINE01" )
    _oLayer:AddWindow( "COLLL01" , "WNDCABEC"  , "" ,093,.F. ,,,"LINE01" )
        
    _oPCab  := _oLayer:GetWinPanel( "COLLL01"   , "WNDCABEC"  , "LINE01" )
            
    //-------------------+
	// Lotes X Etiquetas |
	//-------------------+
	_oMsGetVnd 	:= MsNewGetDados():New(000,000,000,000,GD_UPDATE,/*_bLinOk*/,/*cTudoOk1*/,/*cIniCpos*/,aAlter,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,_oPCab,aHeader,aCols)
	_oMsGetVnd:oBrowse:lUseDefaultColors 	:= .T.
	_oMsGetVnd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
	    
    //-----------------------+
	// Painel para os Botoes | 
	//-----------------------+
	_oPnlBtn := TPanel():New(000,000,"",_oDlg,Nil,.T.,.F.,Nil,CLR_CINZA,000,022,.T.,.F.)
	_oPnlBtn:Align := CONTROL_ALIGN_BOTTOM
    
    _oButtonOk := TButton():New( _nLinIni - 28, _nColFin - 243, "Confirma"	, _oPnlBtn,{|| _oDlg:End() }	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oButtonCa := TButton():New( _nLinIni - 28, _nColFin - 198, "Sair"		, _oPnlBtn,{|| _oDlg:End() }	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    
_oDlg:Activate(,,,.T.,,,)

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} SigM02BHead
@description Cria dados para a GRID
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function SigM02BHead()
Local _cAlias	:= "ZZ1"

//------------------+
// Reseta variaveis |
//------------------+
aHeader		:= {}
aCols		:= {}
aAlter		:= {}

//---------------------------+
// Dicionario de dados - ZZ0 | 
//---------------------------+
dbSelectArea("SX3")
SX3->( dbSetOrder(1) )
If SX3->( dbSeek(_cAlias) )
	While SX3->( !Eof() .And. SX3->X3_ARQUIVO == _cAlias )
		If X3Uso(X3_USADO)
			AAdd(aHeader,{	AllTrim(	X3Titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT;
							})
			EndIf

		SX3->( dbSkip() )
	EndDo
EndIf

//------------------------+
// Preenche dados da GRID | 
//------------------------+
dbSelectArea("ZZ1")
ZZ1->( dbSetOrder(1) )
ZZ1->( dbGoTop() )
While ZZ1->( !Eof() )
	aAdd(aCols,Array(Len(aHeader)+1)) 
	For nX:= 1 To Len(aHeader)
		aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
	Next nX
	aCols[Len(aCols)][Len(aHeader)+1]:= .F.
	ZZ1->( dbSkip() )
EndDo

Return Nil

/************************************************************************************/
/*/{Protheus.doc} SigM02Qry
@description Valida se é primeiro acesso 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function SigM02Qry()
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""

Local _lRet		:= .T.

_cQuery	:= " SELECT " + CRLF 
_cQuery	+= "	COUNT(ZZ1.ZZ1_CODSER) SERVICOS " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= "	" + RetSqlName("ZZ1") + " ZZ1 " + CRLF
_cQuery	+= " WHERE " + CRLF
_cQuery	+= "	ZZ1.ZZ1_FILIAL = '" + xFilial("ZZ1") + "' AND " + CRLF 
_cQuery	+= "	ZZ1.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->SERVICOS == 0 
	_lRet	:= .F.
EndIf

(_cAlias)->( dbCloseArea() )

Return _lRet
