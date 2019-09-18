#INCLUDE "PROTHEUS.CH"

/******************************************************************************************/
/*/{Protheus.doc} nomeFunction
    @description JOB - Faturamento automatico nota fiscal e-commerce
    @type  Function
    @author Bernard M. Margarido
    @since 16/09/2019
/*/
/******************************************************************************************/
User Function EcLojM05(aParam)
Local _aArea        := GetArea()

Private _lJob       := IIF( ValType(aParam) == "A", .T., .F.)

Private _oProcess   := Nil

//------------------+
// Mensagem console |
//------------------+
CoNout("<< ECLOJM05 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(aParam[1], aParam[2],,,'FAT')
EndIf

//----------------------------------+
// Faturamento automatico eCommerce |
//----------------------------------+
CoNout("<< EcLojM05A >> - INICIO FATURAMENTO AUTOMATICO " + dTos( Date() ) + " - " + Time() )
    If _lJob
        EcLojM05A()
    Else
        _oProcess:= MsNewProcess():New( {|| EcLojM05A()},"Aguarde...","Faturando pedidos e-Commerce" )
		_oProcess:Activate()
    EndIf
CoNout("<< EcLojM05A >> - FIM FATURAMENTO AUTOMATICO " + dTos( Date() ) + " - " + Time() )


//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< ECLOJM05 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return Nil

/******************************************************************************************/
/*/{Protheus.doc} nomeStaticFunction
    @description Valida pedidos e-Commerce a serem faturados 
    @type  Static Function
    @author Bernard M. Margarido
    @since 16/09/2019
/*/
/******************************************************************************************/
Static Function EcLojM05A()
Return Nil