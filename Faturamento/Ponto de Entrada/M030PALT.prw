#INCLUDE "PROTHEUS.CH"

/*************************************************************************************/
/*/{Protheus.doc} M030PALT
    @description Ponto de Entrada - Alteração de Clientes
    @type  Function
    @author Bernard M. Margarido
    @since 04/08/2021
/*/
/*************************************************************************************/
User Function M030PALT()
Local _aArea    := GetArea()

//------------------------------------------------+
// Chamada Ponto de Entrada Projetos Corporativos |
//------------------------------------------------+
If ExistBlock("XM030PALT")
	ExecBlock("XM030PALT",.F.,.F.,PARAMIXB)
EndIf

RestArea(_aARea)
Return .T.
