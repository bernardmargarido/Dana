#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/***********************************************************************************/
/*/{Protheus.doc} LJTESPED
    @description Ponto de Entrada - retorna tes para pedidos de vendas ecommerce
    @type  Function
    @author Bernard M. Margarido
    @since 06/07/2019
    @version version
/*/
/***********************************************************************************/
User Function LJTESPED()
Local _cTes := GetNewPar("EC_TESECO")

Return _cTes