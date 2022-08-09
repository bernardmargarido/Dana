#INCLUDE "PROTHEUS.CH"

/*****************************************************************************************/
/*/{Protheus.doc} DnFatM10
    @description Altera forma de pagamento para PIX
    @type  Function
    @author Bernrd M. Margarido
    @since 14/09/2021
/*/
/*****************************************************************************************/
User Function DnFatM10(_cNumDoc,_cSerie,aDetPag,cMensCli)
Local _aArea        := GetArea()

Local _cNewForma    := ""
Local _cCodBrinde   := "BD0001/BD0002/BD0003"
Local _lCondCN      := .F.


//-------------------------+
// SL1 - Pedido e-Commerce |
//-------------------------+
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

    //---------------------------------+
    // SL2 - Posiciona itens do pedido | 
    //---------------------------------+
    dbSelectArea("SL2")
    SL2->( dbSetOrder(1) )
    If SL2->( dbSeek(xFilial("SL2") + SL1->L1_NUM) )
        While SL2->( !Eof() .And. xFilial("SL2") + SL1->L1_NUM  == SL2->L2_FILIAL + SL2->L2_NUM)
            If RTrim(SL2->L2_PRODUTO) $ _cCodBrinde
                If RTrim(SL2->L2_PRODUTO) == "BD0001"
                    cMensCli += "Nota Fiscal emitida nos termos do § 2º do art. 456 do RICMS - Nota Fiscal emitida na entrada nº009152 e 009154, de22/06/2022"
                ElseIf RTrim(SL2->L2_PRODUTO) == "BD0002"
                    cMensCli += "Nota Fiscal emitida nos termos do § 2º do art. 456 do RICMS - Nota Fiscal emitida na entrada nº 009153 de 22/06/2022"
                ElseIf RTrim(SL2->L2_PRODUTO) == "BD0003"
                    cMensCli += "Nota Fiscal emitida nos termos do § 2º do art. 456 do RICMS - Nota Fiscal emitida na entrada nº 009154 de 22/06/2022"
                EndIf 
            EndIf 
            SL2->( dbSkip() )
        EndDo 
    EndIf 
EndIf



RestArea(_aArea)
Return Nil 
