#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/**************************************************************************************************/
/*/{Protheus.doc} ECLOJJ03
    @description JOB - Integra novos clientes B2B 
    @type  Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
User Function ECLOJJ03(aParam)
Local _cEmpJob := IIF(aParam[1] == NIL,"01",aParam[1])  
Local _cFilJob := IIF(aParam[2] == NIL,"05",aParam[2])

Private _lJob  := IsBlind()


If _lJob

    RPCSetType(3)
    RPCSetEnv(_cEmpJob,_cFilJob)

        EcLojJ03A()

    RpcClearEnv()    
Else 
    
    FwMsgRun(,{|_oSay| EcLojJ03A(@_oSay)}, "Aguarde...","Validando novos clientes B2B.")

EndIf 

Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03A
    @description JOB - Valida se existem novos clientes na fila de integração 
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function EcLojJ03A(_oSay)
Local _aArea        := GetArea()

Local _cAlias       := ""
Local _cDocumentID  := ""
Local _cUserId      := ""

Local _oDadosCL     := Nil 
Local _oDadosAD     := Nil 

Local _lCliente     := .F.
Local _lEnderecos   := .F.
Local _lOk          := .F.

Default _oSay       := Nil 

//--------------------------+
// Consulta novos registros |
//--------------------------+
If !EcLojJ03B(@_cAlias)
    RestArea(_aArea)
    Return .F.
EndIf 

//-------------------------------+
// Processa fila de clientes B2B |
//-------------------------------+
While (_cAlias)->( !Eof() )

    //-------------------------------------+
    // XTF - Posiciona registro pelo Recno |
    //-------------------------------------+
    XTF->( dbGoTo((_cAlias)->RECNOXTF) )   
    
    //---------------------+
    // Parametros processo | 
    //---------------------+
    _cDocumentID    := RTrim(XTF->XTF_DOCID)
    _cUserId        := ""
    _lCliente       := .F.
    _lEnderecos     := .F.
    _lOk            := .F.
    _oDadosCL       := Nil 
    _oDadosAD       := Nil 

    If !_lJob 
        _oSay:cCaption := "Integrando dados documentID " + RTrim(XTF->XTF_DOCID)
        Processmessages() 
    EndIf 

    //-------------------------------+
    // Localizar cliente master data |
    //-------------------------------+
    EcLojJ03C(_cDocumentID,@_cUserId,@_oDadosCL,@_lCliente)

    //--------------------------------+
    // Localizar endereço master data |
    //--------------------------------+
    If _lCliente
        EcLojJ03D(_cUserId,@_oDadosAD,@_lEnderecos)
    EndIf 

    //-------------------------------+
    // Realiza a inclusao do cliente |
    //-------------------------------+
    If _lCliente .And. _lEnderecos
        EcLojJ03E(_oDadosCL,_oDadosAD,@_lOk)
    EndIf 

    //--------------------------+
    // Atualiza fila de cliente | 
    //--------------------------+
    If _lOk
        RecLock("XTF",.F.)
            XTF->XTF_DATA := FwTimeStamp(3,Date())
        XTF->( MsUnLock() )
    EndIf 

    (_cAlias)->( dbSkip() )
EndDo 

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03B
    @description Consulta clientes na fila de integração
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
/*/
/**************************************************************************************************/
Static Function EcLojJ03B(_cAlias)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "    R_E_C_N_O_ RECNOXTF " + CRLF
_cQuery += " FROM " + CRLF 
_cQuery += "    " + RetSqlName("XTF") + " " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "    XTF_FILIAL = '" + xFilial("XTF") + "' AND " + CRLF
_cQuery += "    XTF_DATA = '' AND " + CRLF
_cQuery += "    D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() ) 
    Return .F.
EndIf 

Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03C
    @description Realzia a consulta do cliente no Master Data
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function EcLojJ03C(_cDocumentID,_cUserId,_oDadosCL,_lCliente)
    
Return Nil 

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03D
    @description Realiza a consulta dos endereços dos clientes
    @type  Static Function
    @author Bernard M Margarido 
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function EcLojJ03D(_cUserId,_oDadosAD,_lEnderecos)
    
Return Nil 

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 30/06/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function EcLojJ03E(_oDadosCL,_oDadosAD,_lOk)
    
Return Nil 
