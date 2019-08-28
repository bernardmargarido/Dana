#INCLUDE "PROTHEUS.CH"

/******************************************************************************/
/*/{Protheus.doc} ECLOJM03
    @descrption JOB - Integra��o e-Commerce
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
User Function ECLOJM03(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _lJob       := IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt   := "01"
Default _cFilInt   := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< ECLOJM03 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmpInt, _cFilInt,,,'LOJ')
EndIf

//-----------------------+
// Integra��o de Pedidos |
//-----------------------+
CoNout("<< ECLOJM03 >> - INICIO INTEGRACAO DE PEDIDOS " + dTos( Date() ) + " - " + Time() )
    U_AECOI011()
CoNout("<< ECLOJM03 >> - FIM INTEGRACAO DE PEDIDOS " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Integra��o de Estoque |
//-----------------------+
CoNout("<< ECLOJM03 >> - INICIO INTEGRACAO DE ESTOQUES " + dTos( Date() ) + " - " + Time() )
    U_AECOI008()
CoNout("<< ECLOJM03 >> - FIM INTEGRACAO DE ESTOQUES " + dTos( Date() ) + " - " + Time() )

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< ECLOJM03 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return .T.