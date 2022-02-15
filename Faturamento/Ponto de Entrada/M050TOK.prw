#INCLUDE 'PROTHEUS.CH'

/****************************************************************************/
/*/{Protheus.doc} M050TOK
	@description Ponto de Entrada - Apos a gravaçcao das transportadoras
	@author Bernard M. Margarido
	@since 26/10/2018
	@version 1.0
	@type function
/*/
/****************************************************************************/
User Function M050TOK()
Local aArea	:= GetArea()

//------------------------------------------+
// Atualiza data e hora da ultima alteração |
//------------------------------------------+
If INCLUI .Or. ALTERA
	M->A4_XDTALT	:= dDataBase
	M->A4_XHRALT	:= Time()
EndIf	

RestArea(aArea)	
Return .T.
