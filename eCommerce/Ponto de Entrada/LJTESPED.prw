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
Local _cTesI    := GetNewPar("EC_TESECO","604")
Local _cTesE    := GetNewPar("EC_TESECOE","602")
Local _cTesIB   := GetNewPar("EC_TESECOB","6B4")
Local _cTesEB   := GetNewPar("EC_TESECEB","6B2")

Local _cTesB    := GetNewPar("EC_TESECOB","550")

Local _cPosIni  := GetNewPar("Ec_POSIPII","33030010")
Local _cPosFim  := GetNewPar("Ec_POSIPIF","33079000")
Local _cTes     := ""
Local _cPosIpi  := ""
Local _cExNcm   := ""

Local _nPosCli	:= 0
Local _nPosLoj	:= 0
Local _nPosProd := 0
Local _nPosEstE := 0

Local _lBrinde  := GetNewPar("EC_TESBRIN",.T.)

Local _aSL1     := ParamIxb[2]
Local _aSL2     := ParamIxb[3]
Local _nLinha   := ParamIxb[4]

ConOut("<< LJTESPED >> - INICIO VALIDACAO TES PEDIDOS E-COMMERCE ")

_nPosCli		:= aScan(_aSL1      , {|x| AllTrim(x[1]) == "L1_CLIENTE"})
_nPosLoj		:= aScan(_aSL1      , {|x| AllTrim(x[1]) == "L1_LOJA"  	})
_nPosProd       := aScan(_aSL2[1]   , {|x| AllTrim(x[1]) == "L2_PRODUTO"})
_nPosEstE       := aScan(_aSL1      , {|x| AllTrim(x[1]) == "L1_ESTE"  	})

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
If SA1->( dbSeek(xFilial("SA1") + _aSL1[_nPosCli][2] + _aSL1[_nPosLoj][2]))
    ConOut("<< LJTESPED >> - CLIENTE LOCALIZADO - UF " + SA1->A1_EST)

    //--------------------------+
    // SB1 - Posiciona produto  |
    //--------------------------+
    dbSelectArea("SB1")
    SB1->( dbSetOrder(1) )
    SB1->( dbSeek(xFilial("SB1") + _aSL2[_nLinha][_nPosProd][2]) )    
    _cPosIpi  := SB1->B1_POSIPI 
    _cExNcm   := SB1->B1_EX_NCM

    //--------------------------------+
    // Valida UF do cliente eCommerce |
    //--------------------------------+
    If SA1->A1_EST == "SP"
        If ( RTrim(_cPosIni) >= RTrim(_cPosIpi) .And. RTrim(_cPosIpi) <= RTrim(_cPosFim)  ) .And. Empty(_cExNcm)
            _cTes := _cTesI
        ElseIf ( RTrim(_cPosIpi) == "34011190" .Or. RTrim(_cPosIpi) == "34012010" ) .And. Empty(_cExNcm)
            _cTes := _cTesI
        ElseIf RTrim(_cPosIpi) == "34011190" .And. RTrim(_cExNcm) == "01"
            _cTes := _cTesIB
        Else 
            _cTes := _cTesI
        EndIf   
    Else
        If ( RTrim(_cPosIni) >= RTrim(_cPosIpi) .And. RTrim(_cPosIpi) <= RTrim(_cPosFim)  ) .And. Empty(_cExNcm)
            _cTes := _cTesE
        ElseIf ( RTrim(_cPosIpi) == "34011190" .Or. RTrim(_cPosIpi) == "34012010" )  .And. Empty(_cExNcm)
            _cTes := _cTesE
        ElseIf RTrim(_cPosIpi) == "34011190" .And. RTrim(_cExNcm) == "01"
            _cTes := _cTesEB
        Else 
            _cTes := _cTesE
        EndIf   
    EndIf
Else
    //--------------------------+
    // SB1 - Posiciona produto  |
    //--------------------------+
    dbSelectArea("SB1")
    SB1->( dbSetOrder(1) )
    SB1->( dbSeek(xFilial("SB1") + _aSL2[_nLinha][_nPosProd][2]) )    
    _cPosIpi  := SB1->B1_POSIPI 
    _cExNcm   := SB1->B1_EX_NCM

    ConOut("<< LJTESPED >> - CLIENTE SL1 - UF " + _aSL1[_nPosEstE][2])

    //--------------------------------+
    // Valida UF do cliente eCommerce |
    //--------------------------------+
    If _aSL1[_nPosEstE][2] == "SP"
        If ( RTrim(_cPosIni) >= RTrim(_cPosIpi) .And. RTrim(_cPosIpi) <= RTrim(_cPosFim)  ) .And. Empty(_cExNcm)
            _cTes := _cTesI
        ElseIf ( RTrim(_cPosIpi) == "34011190" .Or. RTrim(_cPosIpi) == "34012010" ) .And. Empty(_cExNcm)
            _cTes := _cTesI
        ElseIf RTrim(_cPosIpi) == "34011190" .And. RTrim(_cExNcm) == "01"
            _cTes := _cTesIB
        Else 
            _cTes := _cTesI
        EndIf   
    Else
        If ( RTrim(_cPosIni) >= RTrim(_cPosIpi) .And. RTrim(_cPosIpi) <= RTrim(_cPosFim)  ) .And. Empty(_cExNcm)
            _cTes := _cTesE
        ElseIf ( RTrim(_cPosIpi) == "34011190" .Or. RTrim(_cPosIpi) == "34012010" )  .And. Empty(_cExNcm)
            _cTes := _cTesE
        ElseIf RTrim(_cPosIpi) == "34011190" .And. RTrim(_cExNcm) == "01"
            _cTes := _cTesEB
        Else 
            _cTes := _cTesE
        EndIf   
    EndIf

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
