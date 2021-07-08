#INCLUDE "TOTVS.CH"

/*******************************************************************************************************/
/*/{Protheus.doc} DNFATM09
    @description Realiza a gravação dos dados de volume e peso 
    @type  Function
    @author Bernard M. Margarido
    @since 07/07/2021
/*/
/*******************************************************************************************************/
User Function DNFATM09(_cNumPV,_cDoc,_cSerie)
Local _aArea    := GetArea()

//---------------------------------+
// SC5 - Cabeçalho pedido de venda |
//---------------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
SC5->( dbSeek(xFilial("SC5") + _cNumPV) )

//-----------------------------+
// SF2 - Cabeçalho nota fiscal |
//-----------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
SF2->( dbSeek(xFilial("SF2") + _cDoc + _cSerie) )
RecLock("SF2",.F.)
    SF2->F2_VOLUME1 := SC5->C5_VOLUME1
SF2->( MsUnLock() )

RestArea(_aArea)
Return Nil 