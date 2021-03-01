#INCLUDE "PROTHEUS.CH"

/********************************************************************/
/*/{Protheus.doc} SIGM005
    @description Gera Pre Lista de Postagem 
    @type  Function
    @author Bernard M. Margarido
    @since 14/12/2019
/*/
/********************************************************************/
User Function SIGM005(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _lJob       := IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt   := "01"
Default _cFilInt   := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< SIGM005 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmpInt, _cFilInt,,,'LOJ')
EndIf

//--------------------------+
// Cria arquivo de semaforo |
//--------------------------+
If !LockByName("SIGM005", .T., .T.)
    CoNout("<< SIGM005 >> - ROTINA JA ESTA SENDO EXECUTADA.")
    If _lJob
        RpcClearEnv()
    EndIf
	Return Nil 
EndIf

//----------------------------------+
// Cria��o de Pre Lista de Postagem |
//----------------------------------+
CoNout("<< SIGM005 >> - INICIO CRIA PRE LISTA DE POSTAGEM " + dTos( Date() ) + " - " + Time() )
    U_SIGM006()
CoNout("<< SIGM005 >> - FIM CRIA CRIA PRE LISTA DE POSTAGEM " + dTos( Date() ) + " - " + Time() )

//-------------------------+
// Envia Lista de Postagem |
//-------------------------+
CoNout("<< SIGM005 >> - INICIO ENVIA PRE LISTA DE POSTAGEM " + dTos( Date() ) + " - " + Time() )
    U_SIGM004()
CoNout("<< SIGM005 >> - FIM ENVIA PRE LISTA DE POSTAGEM " + dTos( Date() ) + " - " + Time() )

//----------------------------+
// Exclui arquivo de semaforo |
//----------------------------+
UnLockByName("SIGM005",.T.,.T.)

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< SIGM005 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return Nil