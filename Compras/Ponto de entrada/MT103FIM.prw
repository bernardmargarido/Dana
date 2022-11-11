#INCLUDE "TOTVS.CH"

/********************************************************************************************************/
/*/{Protheus.doc} MT103FIM
    @description Ponto de Entrada - Após a gravação da nota ou pré nota de entrada
    @type  Function
    @author Bernard M Margarido
    @since 13/10/2022
    @version version
/*/
/********************************************************************************************************/
User Function MT103FIM()
Local _aArea    := GetArea()

Local _nRotina  := ParamIxb[1]
Local _nOpcA    := ParamIxb[2]

Local _lEstClas := Isincallstack("A140EstCla")
//---------------------------------+
// Valida estorno da classificação | 
//---------------------------------+
If _nRotina == 5 .And. _nOpcA = 1 .And. _lEstClas
    RecLock("SF1",.F.)
        SF1->F1_XESTCLA := .T.
    SF1->( MsUnLock() )
EndIf 

RestArea(_aArea)
Return Nil 
