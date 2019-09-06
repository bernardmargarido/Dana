#INCLUDE 'PROTHEUS.CH'

/*************************************************************************************/
/*/{Protheus.doc} MT410ALT

@description Ponto de Entrada - Altera��o do pedido de venda

@author Bernard M. Margarido
@since 03/08/2019
@version 1.0

@type function
/*/
/*************************************************************************************/
User Function MT410ACE()
Local _aArea	:= GetArea()

Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")

Local _nOpcA    := ParamIxb[1]

Local _lRet     := .T.

//-------------------+
// Rotina automatica |
//-------------------+
If l410Auto
    RestArea(_aArea)
	Return .T.
EndIf

//------------------------+
// Valida se pedido � WMS |
//------------------------+
If !xFilial("SC5") $ _cFilWMS 
	RestArea(_aArea)
	Return .T.
EndIf

//---------------------+
// Visualiza / Incluir |
//---------------------+
If _nOpcA == 2 .Or. _nOpcA == 3  
	RestArea(_aArea)
	Return .T.
EndIf

//--------------------------------------------+
// Somente pedidos que n�o est�o em separa��o |
//--------------------------------------------+
If SC5->C5_XENVWMS $ "2/3"
	MsgAlert("Pedido aguardando separa��o AutoLog, n�o � permitido altera��o.")
	RestArea(_aArea)
	Return .F.
EndIf

RestArea(_aArea)
Return _lRet 