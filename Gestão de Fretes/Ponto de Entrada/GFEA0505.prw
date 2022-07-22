#INCLUDE "TOTVS.CH"

/**********************************************************************************************/
/*/{Protheus.doc} GFEA0505
    @description Ponto de Entrada - Romaneio após a gravação da liberação do romaneio  
    @type  Function
    @author Bernard M Margarido
    @since 18/07/2022
    @version version
/*/
/**********************************************************************************************/
User Function GFEA0505()
Local _aArea        := GetArea()

Local _cRomaneio    := GWN->GWN_NRROM

Local _lJob         := IsBlind()

//------------------------------------------------------------+
// Rotina valida se envia e-mail para cliente com agendamento |
//------------------------------------------------------------+
If _lJob
    U_DNGFEA01(_cRomaneio)
Else 
    FwMsgRun(,{|| U_DNGFEA01(_cRomaneio)},"Aguarde....","Enviando e-mail para clientes com agendamento.")
EndIf 

RestArea(_aArea)
Return {} 
