/*************************************************************************************/
/*/{Protheus.doc} DNMRPM01
    @description Valida se existe cliente ou fornecedor abastecimento 
    @type  Function
    @author Bernard M. Margarido
    @since 01/04/2021
/*/
/*************************************************************************************/
User Function DNMRPM01(_nField)
Local _aArea    := GetArea()

Local _lRet     := .T.
Local _lXT4     := IIF(Isincallstack("U_DNMRPA01"),.T.,.F.)

Local _oModel   := FwModelActive()
Local _oMRP     := _oModel:GetModel( 'XT4_01' )

//--------------------------+
// Valida se existe cliente |
//--------------------------+
If _lXT4
    _oModel   := FwModelActive()
    _oMRP     := _oModel:GetModel( 'XT4_01' )
    If _nField == 1
        dbSelectArea("SA1")
        SA1->( dbSetOrder(3) )
        If SA1->( dbSeek(xFilial("SA1") + FwFldGet("XT4_CGC")))
            _oMRP:SetValue("XT4_CODCLI",SA1->A1_COD)
            _oMRP:SetValue("XT4_LOJCLI",SA1->A1_LOJA)
        EndIf
    ElseIf _nField == 2
        dbSelectArea("SA2")
        SA2->( dbSetOrder(3) )
        If SA2->( dbSeek(xFilial("SA2") + FwFldGet("XT4_CGC")))
            _oMRP:SetValue("XT4_CODFOR",SA2->A2_COD)
            _oMRP:SetValue("XT4_LOJFOR",SA2->A2_LOJA)
        EndIf
    EndIf
Else
    _oModel   := FwModelActive()
    _oMRP     := _oModel:GetModel( 'XT5_01' )
    If _nField == 1
        dbSelectArea("SA1")
        SA1->( dbSetOrder(3) )
        If SA1->( dbSeek(xFilial("SA1") + FwFldGet("XT5_CGC")))
            _oMRP:SetValue("XT5_CODCLI",SA1->A1_COD)
            _oMRP:SetValue("XT5_LOJCLI",SA1->A1_LOJA)
        EndIf
    ElseIf _nField == 2
        dbSelectArea("SA2")
        SA2->( dbSetOrder(3) )
        If SA2->( dbSeek(xFilial("SA2") + FwFldGet("XT5_CGC")))
            _oMRP:SetValue("XT5_CODFOR",SA2->A2_COD)
            _oMRP:SetValue("XT5_LOJFOR",SA2->A2_LOJA)
        EndIf
    EndIf
EndIf
RestArea(_aArea)
Return _lRet 
