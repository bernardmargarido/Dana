#INCLUDE 'PROTHEUS.CH'

/******************************************************************************/
/*/{Protheus.doc} PES011A2
	@description Ponto de Entrada após a gravação do pedido via integração
	@author Bernard M. Margarido
	@since 07/05/2019
	@version 1.0
	@type function
/*/
/******************************************************************************/
User Function PES011A2()
Local _aArea	:= GetArea()

Local _nX		:= 0

Local _cFilAux	:= cFilAnt
//Local _cFilPed	:= ""
Local _cNumPed	:= ""
Local _aItem	:= ""
Local _xRet  	:= ""

//Local _lPoGrv	:= IIF(Rtrim(ParamIxb[1]) $ "AITEM/APOSPEDIDO/ANTESPEDIDO",.T.,.F.)
Local _lPoGrv	:= IIF(Rtrim(ParamIxb[1]) $ "AITEM/APOSPEDIDO",.T.,.F.)

//-----------------------+
// Somente após ExecAuto |
//-----------------------+
If !_lPoGrv //.Or. ( Rtrim(ParamIxb[1]) == "ANTESPEDIDO" .And. cFilAnt <> "07" )
	RestArea(_aArea)
	Return .T.
EndIf

//------------------------------------------------+
// Ponto de entrada após gravação Pedido de Venda |
//------------------------------------------------+
If Rtrim(ParamIxb[1]) == "APOSPEDIDO"

	//-----------------------+
	// Graba dados variaies  |
	//-----------------------+
	//_cFilPed	:= ParamIxb[2]
	_cNumPed	:= SC5->C5_NUM //ParamIxb[3]
	//cFilAnt 	:= _cFilPed

	CoNout('<< PES011A2 >> - APOSPEDIDO - INICIO FILIAL ' + cFilAnt + ' PEDIDO ' + _cNumPed + ' .')

	//-------------------+
	// Posiciona Produto |
	//-------------------+
	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )

	//------------------+
	// Posiciona Pedido |
	//------------------+
	dbSelectArea("SC6")
	SC6->( dbSetOrder(1) )

	//---------------------------+
	// posiciona itens do pedido | 
	//---------------------------+
	If SC6->( dbSeek(xFilial("SC6") + _cNumPed) )
		While SC6->( !Eof() .And. xFilial("SC6") + _cNumPed == SC6->C6_FILIAL + SC6->C6_NUM )
			If SB1->( dbSeek(xFilial("SB1") + SC6->C6_PRODUTO) )
				//------------------------------+
				// Atualiza para armazem padrão |
				//------------------------------+
				If SC6->C6_LOCAL <> IIF(cFilAnt == "06", SB1->B1_XLOCPAD, SB1->B1_LOCPAD)
					RecLock("SC6",.F.)
						SC6->C6_LOCAL := IIF(cFilAnt == "06", SB1->B1_XLOCPAD, SB1->B1_LOCPAD)
					SC6->( MsUnLock() )
				EndIf
			EndIf	 	
			SC6->( dbSkip() )
		EndDo
	EndIf

	//-----------------------+
	// Restaura filial atual | 
	//-----------------------+
	cFilAnt := _cFilAux
	_xRet 	:= Nil 

	CoNout('<< PES011A2 >> - APOSPEDIDO - FIM FILIAL ' + cFilAnt + ' PEDIDO ' + _cNumPed + ' .')

//----------------------------------------+
// Ponto de entrada Itens Pedido de Venda |
//----------------------------------------+
ElseIf Rtrim(ParamIxb[1]) == "AITEM"
	_aItem		:= ParamIxb[2]
	_nLinha		:= ParamIxb[3]

	_cProduto	:= _aItem[aScan(_aItem,{|x| RTrim(x[1]) == "C6_PRODUTO"})][2]
	_cLocal		:= _aItem[aScan(_aItem,{|x| RTrim(x[1]) == "C6_LOCAL"})][2]
	
	CoNout('<< PES011A2 >> - AITEM - INICIO PRODUTO ' + _cProduto + ' ARMAZEM ' + _cLocal + ' .')

	//------------------------------------------------+
	// Valida se produto contem armazem criado na SB2 |
	//------------------------------------------------+
	dbSelectArea("SB2")
	SB2->( dbSetOrder(1) )
	If !SB2->( dbSeek(xFilial("SB2") + _cProduto + _cLocal ))
		CriaSb2(_cProduto, _cLocal)
	EndIf

	_xRet	:= ParamIxb[2]

	CoNout('<< PES011A2 >> - AITEM - FIM PRODUTO ' + _cProduto + ' ARMAZEM ' + _cLocal + ' .')

ElseIf Rtrim(ParamIxb[1]) == "ANTESPEDIDO"

	_nX			:= 0
	_aCabec 	:= ParamIxb[2]
	_aItens 	:= ParamIxb[3]

	_cNatPv		:= IIF(aScan(_aCabec,{|x| RTrim(x[1]) == "C5_NATNOTA"}) > 0, _aCabec[aScan(_aCabec,{|x| RTrim(x[1]) == "C5_NATNOTA"})][2],"VE")
	_cCliente	:= _aCabec[aScan(_aCabec,{|x| RTrim(x[1]) == "C5_CLIENTE"})][2]
	_cLoja 		:= _aCabec[aScan(_aCabec,{|x| RTrim(x[1]) == "C5_LOJACLI"})][2]

	CoNout('<< PES011A2 >> - ANTESPEDIDO - INICIO CLIENTE ' + _cCliente + ' LOJA ' + _cLoja + ' NATUREZA VENDA ' + _cNatPv + ' .')

	For _nX := 1 To Len(_aItens)
		_cProduto	:= _aItens[_nX][aScan(_aItens[_nX],{|x| RTrim(x[1]) == "C6_PRODUTO"})][2]
		_cTes 		:= U_FAutoTes(xFILIAL("SZH"),_cNatPv,_cProduto,_cCliente,_cLoja)
		If aScan(_aItens[_nX],{|x| RTrim(x[1]) == "C6_TES"}) > 0
			_aItens[_nX][aScan(_aItens[_nX],{|x| RTrim(x[1]) == "C6_TES"})][2] := _cTes
		Else 
			aAdd(_aItens[_nX],{"C6_TES", _cTes, Nil} )
		EndIf
	Next _nX 
	
	aItensPE := _aItens
	_xRet 	 := .T.

	CoNout('<< PES011A2 >> - ANTESPEDIDO - FIM CLIENTE ' + _cCliente + ' LOJA ' + _cLoja + ' NATUREZA VENDA ' + _cNatPv + ' .')

EndIf

RestArea(_aArea)
Return _xRet
