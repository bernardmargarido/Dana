#INCLUDE "PROTHEUS.CH"

/******************************************************************************/
/*/{Protheus.doc} IBSCHM01
    @descrption JOB - Integração Ibex
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
User Function IBSCHM01(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _lJob       := IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt   := "01"
Default _cFilInt   := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< IBSCHM01 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmpInt, _cFilInt,,,'LOJ')
EndIf

//-----------------------------------+
// Criação de Pedidos para separação |
//-----------------------------------+
CoNout("<< IBSCHM01 >> - INICIO CRIA ARQUIVOS DE PEDIDOS " + dTos( Date() ) + " - " + Time() )
    U_IBFATM01()
CoNout("<< IBSCHM01 >> - FIM CRIA ARQUIVOS DE PEDIDOS " + dTos( Date() ) + " - " + Time() )

//----------------------------------------------------------+
// Conecta FTP Ibex - realiza download e upload de arquivos |
//----------------------------------------------------------+
CoNout("<< IBSCHM01 >> - INICIO CONECTA FTP IBEX " + dTos( Date() ) + " - " + Time() )
    U_IBFATM02()
CoNout("<< IBSCHM01 >> - FIM CONECTA FTP IBEX " + dTos( Date() ) + " - " + Time() )

//--------------------+
// Processa separação |
//--------------------+
CoNout("<< IBSCHM01 >> - INICIO PEDIDOS SEPARADOS " + dTos( Date() ) + " - " + Time() )
    U_IBFATM03()
CoNout("<< IBSCHM01 >> - FIM PEDIDOS SEPARADOS " + dTos( Date() ) + " - " + Time() )

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< IBSCHM01 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return .T.