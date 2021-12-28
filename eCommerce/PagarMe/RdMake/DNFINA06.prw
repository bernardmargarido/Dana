#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

/*****************************************************************************************/
/*/{Protheus.doc} DNFINA06
    @description Realiza o envio de uma transferencia
    @type  Function
    @author Bernard M. Margarido
    @since 29/07/2021
/*/
/*****************************************************************************************/
User Function DNFINA06()
Local _aArea    := GetArea()

    FwMsgRun(,{|| DNFINA06A()},"Aguarde...","Enviando transferencia " + XTB->XTB_CODIGO)

RestArea(_aArea)
Return Nil 

/*****************************************************************************************/
/*/{Protheus.doc} DNFINA06A
    @description Envia transferencia pagamentos e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 29/07/2021
/*/
/*****************************************************************************************/
Static Function DNFINA06A()
Local _cRecID   := GetNewPar("DN_RIDPGME","re_ckcl4czzt4ck7xa64pljs93u4") 
Local _cRest    := ""
Local _cMsg     := ""

Local _oJSon    := Nil 
Local _oJSonRet := Nil 
Local _oPagarMe := PagarMe():New() 

//--------------------------------------------+
// Cria interface para envio da Transferencia | 
//--------------------------------------------+
_oJSon := Array(#)
_oJSon[#"amount"]       := XTB->XTB_VALOR * 100
_oJSon[#"recipient_id"] := _cRecID
_oJSon[#"metadata"]     := ""

//-------------------+
// Cria arquivo JSon |
//-------------------+
_cRest := xToJson(_oJSon)

//--------------------------------------+
// Envia transferencia para o eCommerce |
//--------------------------------------+
_oPagarMe:cJson := _cRest
If _oPagarMe:Transferencia()

    If FWJsonDeserialize(_oPagarMe:cRetJSon,@_oJSonRet)
        _cID := _oJSonRet:id
        RecLock("XTB",.F.)
            XTB->XTB_IDTRAN := cValToChar(_cID)
            XTB->XTB_STATUS := "2"
        XTB->( MsUnlock() )

        _cMsg := "Transferencia " + XTB->XTB_CODIGO + " enviada com sucesso. ID " + _cID
    EndIf
Else
    _cMsg := "Erro ao enviar transferencia: " + _oPagarMe:cError
EndIf 

MsgAlert(_cMsg,"Dana - Avisos")

Return Nil 
