#INCLUDE 'PROTHEUS.CH'

/*****************************************************************************/
/*/{Protheus.doc} SF2520E
	@description Ponto de Entrada - Exclusão da nota de saida 
	@author Bernard M. Margarido
	@since 23/07/2019
	@version 1.0
	@type function
/*/
/*****************************************************************************/
User Function SF2520E()
Local _aArea	:= GetArea()
Local _aPedidos	:= {}

Local _nX		:= 0

//----------------------------------------+
// Restaura pedido de venda como separado | 
//----------------------------------------+
If SC5->( FieldPos("C5_XENVWMS") ) > 0
	//-------------------------+
	// Posiciona itens da nota |
	//-------------------------+
	dbSelectArea("SD2")
	SD2->( dbSetOrder(1) )
	If SD2->( dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA) )
		While SD2->( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA)
			If aScan(_aPedidos,{|x| x == SD2->D2_PEDIDO} ) == 0
				aAdd(_aPedidos,SD2->D2_PEDIDO)
			EndIf
			SD2->( dbSkip() )
		EndDo 
	EndIf
	
	//-------------------+
	// Posiciona pedidos |
	//-------------------+
	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )
		
	If Len(_aPedidos) > 0
		For _nX := 1 To Len(_aPedidos)
			If SC5->( dbSeek(xFilial("SC5") + _aPedidos[_nX]))
				RecLock("SC5",.F.)
					SC5->C5_XENVWMS := SC5->C5_XENVWMS
					SC5->C5_XDTALT	:= Date()
					SC5->C5_XHRALT	:= Time()
				SC5->( MsUnLock() )	
			EndIf	
		Next _nX
	EndIf	
EndIf

RestArea(_aArea)
Return .T.
