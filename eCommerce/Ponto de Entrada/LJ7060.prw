#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/***********************************************************************************/
/*/{Protheus.doc} LJ7060
    @description Ponto de Entrada - Filtro Browser inicial
    @type  Function
    @author Bernard M. Margarido
    @since 06/07/2019
    @version version
/*/
/***********************************************************************************/
User Function LJ7060()
Local _leCommerce := IIF(Isincallstack("U_ECLOJ012"),.T.,.F.)

CoNout("<< LJ7060 >> - INICIO " + dTos( Date() ) + " - " + Time() )

If _leCommerce
    CoNout("<< LJ7060 >> - " + IIF(lAutoExec,"TRUE","FALSE") + " ." )    
    lAutoExec := .T.
EndIf

CoNout("<< LJ7060 >> - FIM " + dTos( Date() ) + " - " + Time() )
Return Nil