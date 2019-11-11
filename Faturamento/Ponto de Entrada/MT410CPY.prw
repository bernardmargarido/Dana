#INCLUDE 'PROTHEUS.CH'

/*************************************************************************************/
/*/{Protheus.doc} MT410CPY

@description Ponto de Entrada - Copia do Pedido

@author Bernard M. Margarido
@since 03/08/2019
@version 1.0

@type function
/*/
/*************************************************************************************/
User Function MT410CPY()
Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")

//------------------------+
// Valida se pedido � WMS |
//------------------------+
If !xFilial("SC5") $ _cFilWMS
	Return .T.
EndIf

//----------------------------------------+
// Valida se pedido j� foi enviado ao WMS |
//----------------------------------------+
M->C5_XENVWMS := CriaVar("C5_XENVWMS",.T.)
M->C5_XDTALT  := CriaVar("C5_XDTALT",.T.)
M->C5_XHRALT  := CriaVar("C5_XHRALT",.T.)

Return .T.
