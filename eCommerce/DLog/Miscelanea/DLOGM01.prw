#INCLUDE "PROTHEUS.CH"

/********************************************************************/
/*/{Protheus.doc} DLOGM01
    @description GeraLista de Postagem 
    @type  Function
    @author Bernard M. Margarido
    @since 05/01/2021
/*/
/********************************************************************/
User Function DLOGM01(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _lJob       := IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt   := "01"
Default _cFilInt   := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< DLOGM01 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmpInt, _cFilInt,,,'LOJ')
EndIf

//----------------------------------+
// Criação de Pre Lista de Postagem |
//----------------------------------+
CoNout("<< DLOGM01 >> - INICIO CRIA PRE LISTA DE POSTAGEM " + dTos( Date() ) + " - " + Time() )
    U_DLOGM02()
CoNout("<< DLOGM01 >> - FIM CRIA CRIA PRE LISTA DE POSTAGEM " + dTos( Date() ) + " - " + Time() )

//-------------------------+
// Envia Lista de Postagem |
//-------------------------+
CoNout("<< DLOGM01 >> - INICIO ENVIA PRE LISTA DE POSTAGEM " + dTos( Date() ) + " - " + Time() )
    U_DLOGM03()
CoNout("<< DLOGM01 >> - FIM ENVIA PRE LISTA DE POSTAGEM " + dTos( Date() ) + " - " + Time() )

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< DLOGM01 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return Nil