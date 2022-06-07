#INCLUDE "PROTHEUS.CH"

/********************************************************************/
/*/{Protheus.doc} MDLOGM01
    @description GeraLista de Coleta 
    @type  Function
    @author Bernard M. Margarido
    @since 07/06/2022
/*/
/********************************************************************/
User Function MDLOGM01(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _lJob       := IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt   := "01"
Default _cFilInt   := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< MDLOGM01 >> - INICIO " + dTos( Date() ) + " - " + Time() )

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
CoNout("<< MDLOGM01 >> - INICIO CRIA LISTA DE COLETA " + dTos( Date() ) + " - " + Time() )
    U_MDLOGM02()
CoNout("<< MDLOGM01 >> - FIM CRIA LISTA DE COLETA " + dTos( Date() ) + " - " + Time() )

//-------------------------+
// Envia Lista de Postagem |
//-------------------------+
CoNout("<< MDLOGM01 >> - INICIO ENVIA LISTA DE COLETA " + dTos( Date() ) + " - " + Time() )
    U_MDLOGM03()
CoNout("<< MDLOGM01 >> - FIM ENVIA LISTA DE COLETA " + dTos( Date() ) + " - " + Time() )

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< MDLOGM01 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return Nil
