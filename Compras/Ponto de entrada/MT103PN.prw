#include 'protheus.ch'

/*****************************************************************************/
/*/{Protheus.doc} MT103PN
	@description Ponto de Entrada - Valida se nota pode ser classificada 
	@author Bernard M. Margarido
	@since 19/11/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************/
User Function MT103PN()
Local _aArea	:= GetArea()

Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")
Local _cFilMSL  := GetNewPar("DN_FILMSL","07")

Local _lAtvWMS	:= GetNewPar("DN_ATVWSM",.T.)

If !_lAtvWMS .Or. cFilAnt $ _cFilMSL
	RestArea(_aArea)
	Return .T.
EndIf

If !INCLUI .And. SF1->F1_XENVWMS $ "1/2"
	MsgStop("Não é possivel classificar a nota " + SF1->F1_DOC + " Serie " + SF1->F1_SERIE + ". Aguardando conferencia WMS." )
	RestArea(_aArea)
	Return .F.
EndIF


RestArea(_aArea)	
Return .T.