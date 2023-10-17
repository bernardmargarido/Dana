#INCLUDE 'PROTHEUS.CH'

/*************************************************************************************/
/*/{Protheus.doc} MT410ACE
	@description Ponto de Entrada - Alteração do pedido de venda
	@author Bernard M. Margarido
	@since 03/08/2019
	@version 1.0
	@type function
/*/
/*************************************************************************************/
User Function MT410ACE()
Local _aArea	:= GetArea()

Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")
Local _cFilMSL  := GetNewPar("DN_FILMSL","07")

Local _nOpcA    := ParamIxb[1]

Local _lAtvWMS	:= GetNewPar("DN_ATVWSMS",.T.)
Local _lRet     := .T.

If !_lAtvWMS .Or. cFilAnt <> _cFilMSL
	RestArea(_aArea)
	Return .T.
EndIf

//-------------------+
// Rotina automatica |
//-------------------+
If Type("l410Auto") == "L" .And. l410Auto 
    RestArea(_aArea)
	Return .T.
EndIf

//------------------------+
// Valida se pedido é WMS |
//------------------------+
If !xFilial("SC5") $ _cFilWMS + "," + _cFilMSL
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
// Somente pedidos que não estão em separação |
//--------------------------------------------+
If SC5->C5_XENVWMS $ "1/2/3"
	//MsgAlert("Pedido aguardando separação logistica, não é permitido alteração.")
	RestArea(_aArea)
	Return .T.
EndIf

RestArea(_aArea)
Return _lRet 
