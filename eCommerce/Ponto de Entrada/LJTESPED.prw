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
Local _cTesE    := GetNewPar("EC_TESECO","602")
Local _cTes     := ""

Local _aSL1     := ParamIxb[2]

ConOut("<< LJTESPED >> - INICIO VALIDACAO TES PEDIDOS E-COMMERCE ")

_nPosCli		:= aScan(_aSL1, {|x| AllTrim(x[1]) == "L1_CLIENTE"	})
_nPosLoj		:= aScan(_aSL1, {|x| AllTrim(x[1]) == "L1_LOJA"  	})

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
If SA1->( dbSeek(xFilial("SA1") + _aSL1[_nPosCli][2] + _aSL1[_nPosLoj][2]))
    ConOut("<< LJTESPED >> - CLIENTE LOCALIZADO - UF " + SA1->A1_EST)
    If SA1->A1_EST == "SP"
        _cTes := _cTesI
    Else
        _cTes := _cTesE
    EndIf
Else
    _cTes := _cTesI
EndIf

ConOut("<< LJTESPED >> - TES ENCONTRADA " + _cTes )

ConOut("<< LJTESPED >> - FIM VALIDACAO TES PEDIDOS E-COMMERCE")

Return _cTes