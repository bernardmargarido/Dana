#INCLUDE "PROTHEUS.CH"

/******************************************************************************************/
/*/{Protheus.doc} XM030PALT
    @description Ponto de Entrada - Alteração de Clientes
    @type  Function
    @author Bernard M. Margarido
    @since 04/08/2021
/*/
/******************************************************************************************/
User Function XM030PALT()
Local _aArea        := GetArea()
Local _aFilFat      := {}

Local _cFilFat      := ""

Local _nX           := 0            

Local _lConfirma    := .F.

If _lConfirma
    
    _aFilFat := StaticCall(DNFATA01, DnFatA01D, .F., .F.)

    If Len(_aFilFat) == 0

        Help(" ", 1, "Help", "", "Nao localizado regra de filial de faturamento para este cliente.", 3, 0)

        _cFilFat := CriaVar("A1_XFILFAT",.F.)

    ElseIf Len(_aFilFat) == 1
        
        _cFilFat := _aFilFat[1][1]

    Else
        For _nX := 1 To Len(_aFilFat)
            _cFilFat += IIF(_nX > 1,";","") + _aFilFat[_nX][1]
        Next _nX

        Help(" ", 1, "Help", "", "Cliente com regras de filial de faturamento conflitantes: " + _cFilFat, 3, 0)

        _cFilFat := CriaVar("A1_XFILFAT",.F.)
    EndIf

        
    dbSelectArea("SA1")
    RecLock("SA1",.F.)
        SA1->A1_XFILFAT :=  _cFilFat
    SA1->( MsUnlock() )
    
EndIf

RestArea(_aArea)
Return .T.