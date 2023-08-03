#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

//----------------+
// Dummy function |
//----------------+
User Function DnApi11()
Return Nil 

/**********************************************************************************************************/
/*/{Protheus.doc} DANA - Custumers B2B
    @description API - Informa se existem novos clientes a serem integrados pelo B2B VTEX
    @type  Function
    @author Bernard M. Margarido
    @since 30/06/2023
/*/
/**********************************************************************************************************/
WSRESTFUL CustomerB2B DESCRIPTION "Informa se existem clientes B2B VTEX."

    WSDATA documentId AS STRING OPTIONAL  
    
    WSMETHOD POST CustomerB2B ;
    DESCRIPTION "Informa se exisyem novos clientes B2B VTEX." ;
    WSSYNTAX "/CustomerB2B/{documentId}" ;
    PATH "/CustomerB2B/{documentId}";
    PRODUCES APPLICATION_JSON
    
    
ENDWSRESTFUL

/**********************************************************************************************************/
/*/{Protheus.doc} DANA - Custumers B2B
    @description API - Informa se existem novos clientes a serem integrados pelo B2B VTEX
    @type  Function
    @author Bernard M. Margarido
    @since 30/06/2023
/*/
/**********************************************************************************************************/
WSMETHOD POST CustomerB2B PATHPARAM documentId  WSSERVICE CustomerB2B
Local _aArea        := GetArea()

Local _cDocumentID  := Self:documentId

Local _lRet         := .T.
Local _lGrava       := .T.

Self:SetContentType("application/json")

If !Empty(_cDocumentID)

    If Len(_cDocumentID) <= 14
        _cDocumentID := StrTran(_cDocumentID,".","")
        _cDocumentID := StrTran(_cDocumentID,"-","")
        _cDocumentID := StrTran(_cDocumentID,"/","")
    EndIf 
    
    //--------------------------------------+
    // XTF - Posiciona fila de clientes B2B |
    //--------------------------------------+
    dbSelectArea("XTF")
    XTF->( dbSetOrder(2) )
    If XTF->( dbSeek(xFilial("XTF") + _cDocumentID) )
        _lGrava := .F.
        _cCodigo:= XTF->XTF_COD
    Else 
        _cCodigo:= GetSxeNum("XTF","XTF_COD")
    EndIf 

    RecLock("XTF",_lGrava)
        XTF->XTF_FILIAL := xFilial("XTF")
        XTF->XTF_COD    := _cCodigo 
        XTF->XTF_DOCID  := _cDocumentID
        XTF->XTF_DATA   := ""
    XTF->( MsUnlock() )

Else 
    _lRet := .F.
EndIf 

Self:SetResponse( IIF(_lRet, "true", "false") )

RestArea(_aArea)
Return .T.
