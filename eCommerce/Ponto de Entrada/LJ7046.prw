#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/***********************************************************************************/
/*/{Protheus.doc} LJ7046
    @description Ponto de Entrada - Geração Pedido de Venda
    @type  Function
    @author Bernard M. Margarido
    @since 06/07/2019
    @version version
/*/
/***********************************************************************************/
User Function LJ7046()
Local _aArea    := GetArea()
Local _aRet     := {}
Local _aCab7046 := {}
Local _aCabec   := ParamIxb[2]

Local _nX       := 0

//---------------------------------+
// Somente para pedidos e-Commerce |
//---------------------------------+
If Empty(SL1->L1_XNUMECO)
    RestArea(_aArea)
    Return Nil
EndIf

//------------------+
// Mensagem console |
//------------------+
CoNout("<< LJ7046 >> - INICIO " + dTos( Date() ) + " - " + Time() )

aAdd(_aCab7046,{"C5_XNUMECO",   SL1->L1_XNUMECO         , Nil })
aAdd(_aCab7046,{"C5_XNUMECL",   SL1->L1_XNUMECL         , Nil })
aAdd(_aCab7046,{"C5_XENVWMS",   "1"                     , Nil })
aAdd(_aCab7046,{"C5_XDTALT" ,   Date()                  , Nil })
aAdd(_aCab7046,{"C5_XHRALT" ,   Time()                  , Nil })

//------------------------------+
// Array de Retorno             |
// Array[1] - Cabeçalho Pedido  | 
// Array[2] - Itens Pedido      |
//------------------------------+
aAdd(_aRet, _aCab7046)
aAdd(_aRet, {} )

Conout( "<< LJ7046 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return _aRet