#INCLUDE 'PROTHEUS.CH'

/******************************************************************************/
/*/{Protheus.doc} M030ALT
	@author Bernard M. Margarido
	@since 07/07/2019
	@version 1.0
	@type function
/*/
/******************************************************************************/
User Function M030ALT()
Local _aArea := GetArea()

//-----------------------------+
// Atualiza dados da alteração |
//-----------------------------+
RecLock("SA1",.F.)
	SA1->A1_XDTALT	:= dDatabase
	SA1->A1_XHRALT	:= Time()
SA1->( MsUnLock() )

RestArea(_aArea)
Return .T.