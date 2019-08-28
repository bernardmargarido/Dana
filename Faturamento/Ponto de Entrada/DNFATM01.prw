#INCLUDE 'PROTHEUS.CH'

/**************************************************************************/
/*/{Protheus.doc} DNFATM01

@description Confirma se pedido foi realizada a separação

@author Bernard M. Margarido
@since 22/11/2018
@version 1.0

@type function
/*/
/**************************************************************************/
User Function DNFATM01()
Local aArea		:= GetArea()

Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")

Local lRet		:= .T.

If !cFilAnt $ _cFilWMS
	RestArea(aArea)
	Return .T.
EndIf

//------------------+
// Posiciona Pedido |
//------------------+
SC5->( dbSetOrder(1) )
SC5->( dbSeek(xFilial("SC5") + SC9->C9_PEDIDO) )

//------------------------------------+
// Valida se nota é de beneficiamento |
//------------------------------------+
If !SC5->C5_TIPO $ "N/D/B"
	RestArea(aArea)
	Return .T.
EndIf

//----------------------------------------------+
// Valida se item está com separação confirmada | 
//----------------------------------------------+
If SC9->C9_XENVWMS <> "3"
	MsgAlert("Pedido " + SC9->C9_PEDIDO + " aguardando separação WMS","Dana Cosméticos - Avisos")
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet