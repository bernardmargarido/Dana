#INCLUDE "PROTHEUS.CH"

/*****************************************************************************************/
/*/{Protheus.doc} DnFatM10
    @description Altera forma de pagamento para PIX
    @type  Function
    @author Bernrd M. Margarido
    @since 14/09/2021
/*/
/*****************************************************************************************/
User Function DnFatM10(_cNumDoc,_cSerie,aDetPag)
Local _aArea    := GetArea()

Local _cNewForma:= ""

Local _lCondCN  := .F.

dbselectarea("SL1")
SL1->( dbsetorder(2) )
If SL1->( dbseek(xFilial('SL1') + _cSerie + _cNumDoc) )
    //---------------------------------+    
    // Somente para condição negociada |
    //---------------------------------+    
    _lCondCN := IIF(RTrim(SL1->L1_CONDPG) == "CN", .T., .F.)

    //--------------------------------+
    // SL4 - Formas de pagamento Loja |
    //--------------------------------+
    dbselectarea("SL4")			
    SL4->( dbsetorder(1) )
    If _lCondCN .And. SL4->( dbseek(SL1->L1_FILIAL + SL1->L1_NUM) )
        While SL4->( !Eof() .And. xFilial("SL4") + SL1->L1_NUM == SL4->L4_FILIAL + SL4->L4_NUM )
            If RTrim(SL4->L4_FORMA) == "PIX"
                _cNewForma := "01"
                Exit
            EndIf 
            SL4->( dbSkip() )
        EndDo		
    EndIf

    If !Empty(_cNewForma)
        aDetPag[1][1] := _cNewForma
    EndIf
EndIf

RestArea(_aArea)
Return Nil 