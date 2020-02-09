#INCLUDE "PROTHEUS.CH"

/******************************************************************************/
/*/{Protheus.doc} ECLOJM04
    @descrption JOB - ExecAuto Loja
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
User Function ECLOJM04(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _lJob       := IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt   := "01"
Default _cFilInt   := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< ECLOJM04 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmpInt, _cFilInt,,,'LOJ')
EndIf

//-----------------------+
// Integração de Pedidos |
//-----------------------+
CoNout("<< ECLOJM04 >> - INICIO EXECAUTO LOJA PARA PEDIDOS ECOMMERCE " + dTos( Date() ) + " - " + Time() )
    U_ECLOJ012()
CoNout("<< ECLOJM04 >> - INICIO EXECAUTO LOJA PARA PEDIDOS ECOMMERCE " + dTos( Date() ) + " - " + Time() )

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< ECLOJM04 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return .T.