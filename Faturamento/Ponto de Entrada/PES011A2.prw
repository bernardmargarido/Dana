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
Local _cFilPed	:= ParamIxb[2]
Local _cNumPed	:= ParamIxb[3]


Local _lPoGrv	:= IIF(Rtrim(ParamIxb[1]) == "APOSPEDIDO",.T.,.F.)

//-----------------------+
// Somente após ExecAuto |
//-----------------------+
If !_lPoGrv
	RestArea(_aArea)
	Return .T.
EndIf

//-------------------------+
// Posiciona filial pedido |
//-------------------------+
cFilAnt := _cFilPed

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
			If SC6->C6_LOCAL <> SB1->B1_LOCPAD
				RecLock("SC6",.F.)
					SC6->C6_LOCAL := SB1->B1_LOCPAD
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

RestArea(_aArea)
Return Nil