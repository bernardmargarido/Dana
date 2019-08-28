#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/***********************************************************************************/
/*/{Protheus.doc} LJ7066
    @description Ponto de Entrada - Após a gravação do Pedido de Venda
    @type  Function
    @author Bernard M. Margarido
    @since 06/07/2019
    @version version
/*/
/***********************************************************************************/
User Function LJ7066()
Local _aArea    := GetArea()

Local _lLiber   := .T.
Local _lBlqEst  := .T.

//---------------------------------+
// Somente para pedidos e-Commerce |
//---------------------------------+
If Empty(SC5->C5_XNUMECO)
    RestArea(_aArea)
    Return Nil
EndIf

//------------------+
// Mensagem console |
//------------------+
CoNout("<< LJ7066 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//----------------------------------------------+ 
// Atualização de Status dos Pedidos e-Commerce |
//----------------------------------------------+ 
U_VldLibPv(SC5->C5_NUM,@_lLiber,@_lBlqEst)

//---------------------------+
// Atualiza status do Pedido |
//---------------------------+
If _lLiber .And. _lBlqEst
    U_GrvStaEc(SC5->C5_XNUMECO,'004')
ElseIf _lLiber .And. !_lBlqEst
    U_GrvStaEc(SC5->C5_XNUMECO,'003')
ElseIf !_lLiber .And. !_lBlqEst    
    U_GrvStaEc(SC5->C5_XNUMECO,'002')
EndIf

//-------------------------------------+
// Grava numero do pedido de venda WSA |
//-------------------------------------+
If WSA->( FieldPos("WSA_NUMSC5") ) > 0
    //--------------------------------------+
	// Valida se pedido ja esta no Protheus |
	//--------------------------------------+
	dbSelectArea("WSA")
	WSA->( dbOrderNickName("PEDIDOECO") )
	If WSA->( dbSeek(xFilial("WSA") + SC5->C5_XNUMECO) )
        RecLock("WSA",.F.)
            WSA->WSA_NUMSC5 := SC5->C5_NUM
        WSA->( MsUnLock() )
    EndIf
EndIf

Conout( "<< LJ7066 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return .T.