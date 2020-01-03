#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CLR_CINZA RGB(230,230,230)
#DEFINE CRLF CHR(13) + CHR(10)
 
/************************************************************************************/
/*/{Protheus.doc} SIGM001

@description Consulta servi�os disponiveis, comforme contrado

@author Bernard M. Margarido
@since 07/02/2017
@version undefined

@type function
/*/
/************************************************************************************/
User Function SIGM001()
Local _aArea		:= GetArea()

//-----------------------------------+
// Valida se existem dados na tabela |
//-----------------------------------+
If !SigM01Qry()
	//----------------------------+
	// Grava servi�os contratados |
	//----------------------------+
	FwMsgRun(,{|| SigM01A()},"Aguarde...","Consultando contratos")
Else
	//----------------------------+
	// Grava servi�os contratados |
	//----------------------------+
	FwMsgRun(,{|| SigM01B()},"Aguarde...","Tela Servi�os contratados")	
EndIf	

RestArea(_aArea)
Return .T. 

/************************************************************************************/
/*/{Protheus.doc} SigM01A
@description Consulta contratos
@author Bernard M. Margarido
@since 06/12/2019
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function SigM01A()
Local _cMsg			:= ""

Local _lRet 		:= .T.

Local  _oSigWeb		:= SigepWeb():New

//--------------------+
// Consulta Contratos |
//--------------------+
If _oSigWeb:GrvServico()
	_cMsg := "Contratos gravados com sucesso. Deseja abrir tela de consulta?"
Else
	_cMsg 	:= _oSigWeb:cError
	_lRet	:= .F.
EndIf

If _lRet
	If MsgYesNo(_cMsg,"Dana Cosmeticos - Avisos")
		FwMsgRun(,{|| SigM01B()},"Aguarde...","Tela Servi�os contratados")	
	EndIf
Else
	MsgAlert(_cMsg,"Dana Cosmeticos - Avisos")
EndIf

Return .T.

/************************************************************************************/
/*/{Protheus.doc} SigM01B
@description Tela servi�os contratados 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0

@type function
/*/
/************************************************************************************/
Static Function SigM01B()
Local _aArea	:= GetArea()
Local _aCoors   	:= FWGetDialogSize( oMainWnd )
Local _aButtons		:= {}

Local _cTitulo  	:= "Servi�os contratados Sigep."

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
SigM01BHead()

//-------------------------------------------------------+
// Inicializa as coordenadas de tela conforme resolu��o  |
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
	// Painel para informa��es | 
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
    
    _oButtonOk := TButton():New( _nLinIni - 28, _nColFin - 243, "Confirma"	, _oPnlBtn,{|| _nOpcA := 1, _oDlg:End()}	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oButtonCa := TButton():New( _nLinIni - 28, _nColFin - 198, "Sair"		, _oPnlBtn,{|| _oDlg:End() }	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    
_oDlg:Activate(,,,.T.,,,)

//--------------------------------------------------------+
// Realiza amarra��o transportadoras ERP x Servi�os SIGEP |
//--------------------------------------------------------+
If _nOpcA == 1
	FWMsgRun(, {|| SigM01Grv() }, "Processando", "Atualizando dados .... " )
EndIf

RestArea(_aArea)
Return Nil

/************************************************************************************/
/*/{Protheus.doc} SigM01Grv
@description Atualiza dados servi�os sigep 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function SigM01Grv()
Local _aArea	:= GetArea()

Local _nPCodSer	:= aScan(_oMsGetVnd:aHeader,{|x| Alltrim(x[2]) == "ZZ0_CODSER"})
Local _nPTransp	:= aScan(_oMsGetVnd:aHeader,{|x| Alltrim(x[2]) == "ZZ0_CODECO"})
Local _nX		:= 0

//--------------------------+
// Posiciona Servi�os Sigep |
//--------------------------+
dbSelectArea("ZZ0")
ZZ0->( dbSetOrder(1) )

For _nX := 1 To Len(_oMsGetVnd:aCols)
	If !Empty(_oMsGetVnd:aCols[_nX][_nPTransp])
		ZZ0->( dbSeek(xFilial("ZZ0") + _oMsGetVnd:aCols[_nX][_nPCodSer]))
		RecLock("ZZ0",.F.)
			ZZ0->ZZ0_CODECO := _oMsGetVnd:aCols[_nX][_nPTransp]
		ZZ0->( MsUnLock() )
	EndIf
Next _nX

RestArea(_aArea)
Return Nil

/************************************************************************************/
/*/{Protheus.doc} SigM01BHead
@description Grava dados para GRID 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function SigM01BHead()
Local _cAlias	:= "ZZ0"

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

aAdd(aAlter,"ZZ0_CODECO")

//------------------------+
// Preenche dados da GRID | 
//------------------------+
dbSelectArea("ZZ0")
ZZ0->( dbSetOrder(1) )
ZZ0->( dbGoTop() )
While ZZ0->( !Eof() )
	aAdd(aCols,Array(Len(aHeader)+1)) 
	For nX:= 1 To Len(aHeader)
		aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
	Next nX
	aCols[Len(aCols)][Len(aHeader)+1]:= .F.
	ZZ0->( dbSkip() )
EndDo

Return .T.

/************************************************************************************/
/*/{Protheus.doc} SigM01Qry
@description Consulta se servi�os contratados 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function SigM01Qry()
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""

Local _lRet		:= .T.

_cQuery	:= " SELECT " + CRLF 
_cQuery	+= "	COUNT(ZZ0.ZZ0_CODSER) SERVICOS " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= "	" + RetSqlName("ZZ0") + " ZZ0 " + CRLF
_cQuery	+= " WHERE " + CRLF
_cQuery	+= "	ZZ0.ZZ0_FILIAL = '" + xFilial("ZZ0") + "' AND " + CRLF 
_cQuery	+= "	ZZ0.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->SERVICOS == 0 
	_lRet	:= .F.
EndIf

(_cAlias)->( dbCloseArea() )

Return _lRet