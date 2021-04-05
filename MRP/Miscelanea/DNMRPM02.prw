#INCLUDE "PROTHEUS.CH"

/**********************************************************************************************/
/*/{Protheus.doc} DNMRPM02
    @description Retorna empresa informada 
    @type  Function
    @author Bernard M. Margarido
    @since 01/04/2021
/*/
/**********************************************************************************************/
User Function DNMRPM02()
Local _aArea    := GetArea()

Local _cCodEmp  := ""

Local _lXT4     := IIF(Isincallstack("U_DNMRPA01"),.T.,.F.)

Local _oModel   := Nil 
Local _oMRP     := Nil 

If _lXT4
    _oModel     := FwModelActive()
    _oMRP       := _oModel:GetModel( 'XT4_01' ) 
    _cCodEmp    := _oMRP:GetValue("XT4_CODEMP")
Else 
   _oModel      := FwModelActive()
   _oMRP        := _oModel:GetModel( 'XT5_01' ) 
   _cCodEmp     := _oMRP:GetValue("XT5_CODEMP") 
EndIf

RestArea(_aArea)
Return _cCodEmp