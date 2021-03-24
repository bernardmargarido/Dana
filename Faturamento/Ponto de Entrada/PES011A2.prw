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

Local _cFilAux	:= cFilAnt
Local _cFilPed	:= ""
Local _cNumPed	:= ""
Local _aItem	:= ""

Local _lPoGrv	:= IIF(Rtrim(ParamIxb[1]) $ "AITEM/APOSPEDIDO",.T.,.F.)

//-----------------------+
// Somente após ExecAuto |
//-----------------------+
If !_lPoGrv
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
	_cFilPed	:= ParamIxb[2]
	_cNumPed	:= ParamIxb[3]
	cFilAnt 	:= _cFilPed

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
//----------------------------------------+
// Ponto de entrada Itens Pedido de Venda |
//----------------------------------------+
ElseIf Rtrim(ParamIxb[1]) == "AITEM"
	_aItem		:= ParamIxb[2]
	_cProduto	:= _aItem[aScan(_aItem,{|x| RTrim(x[1]) == "C6_PRODUTO"})][2]
	_cLocal		:= _aItem[aScan(_aItem,{|x| RTrim(x[1]) == "C6_LOCAL"})][2]

	//------------------------------------------------+
	// Valida se produto contem armazem criado na SB2 |
	//------------------------------------------------+
	dbSelectArea("SB2")
	SB2->( dbSetOrder(1) )
	If !SB2->( dbSeek(xFilial("SB2") + _cProduto + _cLocal ))
		CriaSb2(_cProduto, _cLocal)
	EndIf

EndIf

RestArea(_aArea)
Return Nil