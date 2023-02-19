#INCLUDE "TOTVS.CH"

/***************************************************************************************************************************/
/*/{Protheus.doc} F040TRVSA1
    @description Ponto de entrada - Valida se atualiza ou não as informações dos cliente contedo ultima compra ou não 
    @type  Function
    @author user
    @since 05/02/2023
    @version version
/*/
/***************************************************************************************************************************/
User Function F040TRVSA1()
Local _lTrvAtuSa1 := .F.

If SA1->A1_PESSOA == "F" .And. SA1->A1_TIPO == "F"
    _lTrvAtuSa1 := GetMv("DN_UPDSA1",,.T.)    
EndIf 

Return _lTrvAtuSa1
