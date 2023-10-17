#INCLUDE "TOTVS.CH"

/***************************************************************************************/
/*/{Protheus.doc} LOJA140B
    @description Ponto de Entrada - Ap�s a exclus�o do or�amento
    @type  Function
    @author Bernard M. Margarido
    @since 26/09/2019
/*/
/***************************************************************************************/
User Function LOJA140B()

    If Empty(SL1->L1_XNUMECO)
        Return .T.
    EndIF

    //------------------------------------+
    // Atualiza dados do or�amento origem |
    //------------------------------------+
    U_EcLoj140()

Return .T.
