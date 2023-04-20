#INCLUDE "TOTVS.CH"

/***********************************************************************************************************/
/*/{Protheus.doc} ECLOJJ02
    @description Realiza o envio da nota ao eCommerce
    @type  Function
    @author Bernard M Margarido
    @since 21/03/2023
    @version version
/*/
/***********************************************************************************************************/
User Function ECLOJJ02(aParam)
Local _cEmpJob := IIF(aParam[1] == NIL,"01",aParam[1])  
Local _cFilJob := IIF(aParam[2] == NIL,"06",aParam[2])

RPCSetType(3)
RPCSetEnv(_cEmpJob,_cFilJob)

    U_ECLOJM07()

RpcClearEnv()

Return Nil 
