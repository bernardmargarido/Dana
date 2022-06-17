#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/***********************************************************************************/
/*/{Protheus.doc} LJTESPED
    @description Ponto de Entrada - retorna tes para pedidos de vendas ecommerce
    @type  Function
    @author Bernard M. Margarido
    @since 06/07/2019
    @version version
/*/
/***********************************************************************************/
User Function LJTESPED()
Local _cTesI    := GetNewPar("EC_TESECO","601")
Local _cTesE    := GetNewPar("EC_TESECOE","602")
Local _cTesB    := GetNewPar("EC_TESECOB","550")
Local _cTes     := ""

Local _lBrinde  := GetNewPar("EC_TESBRIN",.T.)

Local _aSL1     := ParamIxb[2]
Local _aSL2     := ParamIxb[3]
Local _nLinha   := ParamIxb[4]

ConOut("<< LJTESPED >> - INICIO VALIDACAO TES PEDIDOS E-COMMERCE ")

_nPosCli		:= aScan(_aSL1      , {|x| AllTrim(x[1]) == "L1_CLIENTE"})
_nPosLoj		:= aScan(_aSL1      , {|x| AllTrim(x[1]) == "L1_LOJA"  	})
_nPosProd       := aScan(_aSL2[1]   , {|x| AllTrim(x[1]) == "L2_PRODUTO"})

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
If SA1->( dbSeek(xFilial("SA1") + _aSL1[_nPosCli][2] + _aSL1[_nPosLoj][2]))
    ConOut("<< LJTESPED >> - CLIENTE LOCALIZADO - UF " + SA1->A1_EST)
    //--------------------------------+
    // Valida UF do cliente eCommerce |
    //--------------------------------+
    If SA1->A1_EST == "SP"
        _cTes := _cTesI
    Else
        _cTes := _cTesE
    EndIf
Else
    _cTes := _cTesI
EndIf

//----------------------------+
// Valida se é produto brinde | 
//----------------------------+
dbSelectArea("SB5")
SB5->( dbSetOrder(1) )
If SB5->( dbSeek(xFilial("SB5") + _aSL2[_nLinha][_nPosProd][2]) ) .And. _lBrinde
    If SB5->B5_XTPPROD == "2"
        _cTes := _cTesB
    EndIf 
EndIf 

ConOut("<< LJTESPED >> - TES ENCONTRADA " + _cTes )

ConOut("<< LJTESPED >> - FIM VALIDACAO TES PEDIDOS E-COMMERCE")

Return _cTes
