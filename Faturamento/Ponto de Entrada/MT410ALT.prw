#INCLUDE 'PROTHEUS.CH'

/*************************************************************************************/
/*/{Protheus.doc} MT410ALT

@description Ponto de Entrada - Alteração do pedido de venda

@author Bernard M. Margarido
@since 03/08/2019
@version 1.0

@type function
/*/
/*************************************************************************************/
User Function MT410ALT()
Local _aArea	:= GetArea()
Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")

//------------------------+
// Valida se pedido é WMS |
//------------------------+
If !xFilial("SC5") $ _cFilWMS
	RestArea(_aArea)
	Return .T.
EndIf

//----------------------------------------+
// Valida se pedido já foi enviado ao WMS |
//----------------------------------------+
If SC5->C5_XENVWMS == "2"
	RecLock("SC5",.F.)
		SC5->C5_XENVWMS := "1"
		SC5->C5_XDTALT	:= Date()
		SC5->C5_XHRALT	:= Time()
	SC5->( MsUnLock() )
EndIf

RestArea(_aArea)	
Return .T.