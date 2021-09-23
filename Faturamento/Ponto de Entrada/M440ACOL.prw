#INCLUDE "PROTHEUS.CH"

/************************************************************************************/
/*/{Protheus.doc} M440ACOL
    @description Ponto de Entrada - Liberação do pedido, montagem acols 
    @type  Function
    @author Bernard M. Margarido
    @since 09/11/2019
/*/
/************************************************************************************/
User Function M440ACOL()
Local _aArea    := GetArea()

Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")

Local _nPItem   := aScan(aHeader,{|x| RTrim(x[2]) == "C6_ITEM"})
Local _nPProd   := aScan(aHeader,{|x| RTrim(x[2]) == "C6_PRODUTO"})
Local _nPQtdLib := aScan(aHeader,{|x| RTrim(x[2]) == "C6_QTDLIB"})
Local _nQtdVend := aScan(aHeader,{|x| RTrim(x[2]) == "C6_QTDVEN"})

Local _lAtvWMS	:= GetNewPar("DN_ATVWSMS",.T.)

If !_lAtvWMS
    RestArea(_aArea)
	Return .T.
EndIf

If !cFilAnt $ _cFilWMS
	RestArea(_aArea)
	Return .T.
EndIf

//--------------------------+
// Posiciona item do pedido |
//--------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1))
If SC6->( dbSeek(xFilial("SC6") + M->C5_NUM + aCols[Len(aCols)][_nPItem] + aCols[Len(aCols)][_nPProd]) )
    If SC6->C6_XQTDRES > 0
        aCols[Len(aCols)][_nPQtdLib] := aCols[Len(aCols)][_nQtdVend] - SC6->C6_XQTDRES
    EndIf
EndIf

RestArea(_aArea)
Return Nil