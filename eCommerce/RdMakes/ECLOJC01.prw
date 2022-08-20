#INCLUDE "TOTVS.CH"

Static _cIDLoja := ""

/*********************************************************************************************/
/*/{Protheus.doc} ECLOJC01
    @description Tela consulta MultiLojas
    @type  Function
    @author Bernard M Margarido
    @since 16/08/2022
    @version version
/*/
/*********************************************************************************************/
User Function ECLOJC01()
Local _aArea    := GetArea() 

Local _cTitulo  := "Dana - MultiLojas eCommerce"

Local _oOk 		:= LoadBitmap(GetResources(), "LBOK")
Local _oNo 		:= LoadBitmap(GetResources(), "LBNO")
Local _oDlg		:= Nil
Local _oTwBrowse:= Nil
Local _oPanel   := Nil 

Local _aTitTwBr := {"","Codigo","Descricao"}
Local _aTamBrw	:= {05,20,40}
Local _aListBrw	:= {}  

Local _nOpcA	:= 0
Local _nX		:= 0

Local _cMarcados:= &(ReadVar())

//-------------------------+
// Cria lista com as lojas |
//-------------------------+
ECLOJC01A(_aListBrw,_cMarcados)

_oDlg := MsDialog():New(0, 0, 250, 400, _cTitulo,,,,DS_MODALFRAME,,,,,.T.)
	_oPanel := TPanel():New(001,001, , _oDlg,, .T.,,,, 200, 100, .T.,)
	
	_oTwBrowse := TWBrowse():New(00,00,00,00,,_aTitTwBr,_aTamBrw,_oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	_oTwBrowse:SetArray(_aListBrw)
	_oTwBrowse:bLine := {|| {Iif(_aListBrw[_oTwBrowse:nAt,1],_oOk,_oNo),;
							_aListBrw[_oTwBrowse:nAt,2],;
							_aListBrw[_oTwBrowse:nAt,3]}}
							
	_oTwBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	_oTwBrowse:bLDblClick 	 := {|| ECLOJC01B(_oTwBrowse,_aListBrw,2) }
	_oTwBrowse:bHeaderClick  := {|| ECLOJC01C(_oTwBrowse,_aListBrw)}
	
	//@ 110,002 Button "Incluir" 	Size 040,010 ACTION AEcoNewMP() PIXEL OF oDlg
	@ 110,110 Button "Ok" 		Size 040,010 ACTION (_nOpcA := 1, _oDlg:End() )  PIXEL OF _oDlg
	@ 110,160 Button "Fechar" 	Size 040,010 ACTION _oDlg:End()  PIXEL OF _oDlg
	
_oDlg:Activate(,,,.T.,,,)    

If _nOpcA == 1
	_cIDLoja := "" 
	For _nX := 1 To Len(_aListBrw)
		If _aListBrw[_nX][1]
			_cIDLoja += RTrim(_aListBrw[_nX][2]) + ","
		EndIf	
	Next _nX
	
	_cIDLoja := SubStr(_cIDLoja,1,Rat(",",_cIDLoja) - 1)

EndIf

RestArea(_aArea)
Return .T. 

/*****************************************************************************************/
/*/{Protheus.doc} MtnListBrw
	@description Monta ListBrowser
	@author Bernard M. Margarido
	@since 02/11/2017
	@version undefined
	@type function
/*/
/*****************************************************************************************/
Static Function ECLOJC01A(_aListBrw,_cMarcados)

Local _aArea	:= GetArea()
Local _aMarc	:= Separa(_cMarcados,",")
Local _nPMarc   := 0	

If At(",",_cMarcados) > 0
	_aMarc	:= Separa(_cMarcados,",")
Else
	aAdd(_aMarc,Alltrim(_cMarcados))
EndIf

dbSelectArea("XTC")
XTC->( dbSetOrder(1) )
XTC->( dbGoTop() )
While XTC->( !Eof()  )
    
    _nPMarc := aScan(_aMarc,{|x| RTrim(x) == RTrim(XTC->XTC_CODIGO) })
	
	aAdd(_aListBrw,{IIF(_nPMarc > 0,.T.,.F.),;
					XTC->XTC_CODIGO,;
					XTC->XTC_DESC})
	
	XTC->( dbSkip() )
EndDo

RestArea(_aArea)
Return .T.

/*****************************************************************************************/
/*/{Protheus.doc} ECLOJC01B
	@description Valida o Duplo click
	@author Bernard M. Margarido
	@type function
/*/
/*****************************************************************************************/
Static Function ECLOJC01B(_oList,_aLista,_nField)
Local _lRet		    := .T.

Default _nField 	:= 0

_aLista[_oList:nAt,1]:= !_aLista[_oList:nAt,1]
If !_aLista[_oList:nAt,1]
	_aLista[_oList:nAt,1] := .F.
EndIf

_oList:Refresh()

Return _lRet

/*****************************************************************************************/
/*/{Protheus.doc} ECLOJC01C
	@description Marca e desmarca os itens da lista 
	@author Bernard M. Margarido
	@since 02/11/2017
	@version undefined
	@type function
/*/
/*****************************************************************************************/
Static Function ECLOJC01C(_oTwBrowse,_aListBrw)
Local _nX

For _nX := 1 To Len(_oTwBrowse)
	_aListBrw[_nX,1]    := .F.		
Next _nX

_oTwBrowse:Refresh()

Return .T.

User Function ECLOJC1D()
Return _cIDLoja
