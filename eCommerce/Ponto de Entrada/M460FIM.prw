#INCLUDE "PROTHEUS.CH"

/********************************************************************************/
/*/{Protheus.doc} nomeFunction
    @description Ponto de Entrada - Após a gravação da nota fiscal
    @type  Function
    @author Bernard M. Margarido
    @since 07/09/2019
/*/
/********************************************************************************/
User Function M460FIM()
Local _aArea    := GetArea()

//-----------------------------+
// Valida se é nota e-Commerce |
//-----------------------------+
If SF2->( FieldPos("F2_XNUMECO") ) > 0 
    If !Empty(SC5->C5_XNUMECO)
        U_EcVldNF(SF2->F2_DOC,SF2->F2_SERIE,SC5->C5_XNUMECO)
    EndIf
EndIf

RestArea(_aArea)
Return .T.