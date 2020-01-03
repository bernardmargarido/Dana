#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100LOK   º Autor ³                     Data ³  04/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP5 IDE.                                º±±
±±º          ³ OBRIGA COLOCAR O PEDIDO DE COMPRA                          º±±
±³           ³ Verifica a quantidade e valor se estao dentro do            ³±
±³           ³ pedido realizado                                            ³±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Notas Fiscais de Entrada                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT100LOK

SetPrvt("_CALIAS,_NINDEX,_NREG,_NLINGETD,_NPOSCCUSTO,_NPOSCONTA")
SetPrvt("_NPOSNATUREZ,_NPOSTES,_NPOSVUNIT,_NPOSTOTAL,_NPOSQUANT,_CTES")
SetPrvt("_CNAT,ACOLS,_LRETURN,_CCC,CCOLORANT,CSAVESCR")
SetPrvt("CSAVEMENUH,")

Private cString := .T.

If altera .or. inclui
	If aCols[n,Len(aHeader)+1] == .F. // verifica se o item está deletado
		If SB1->B1_TIPO <> "PA"
			If SB1->B1_TIPO $ "MA/ME/MP" .AND. M->CTIPO == "N" .AND. !ALLTRIM(M->CA100FOR) $ GETMV("MV_FORNLIB")
				nPOS := aSCAN(aHEADER, {|X| UPPER(ALLTRIM(x[2])) == "D1_PEDIDO"})
				cCOD := aCOLS[n,nPOS]
				If Empty(cCOD)
					Msginfo("Obrigatório informar um pedido de compras!!!","P E R F U M E S  D A N A - MT100LOK")
					cString := .F.
				Endif
				VERIF()
			Endif
		Endif
		If Alltrim(SB1->B1_TIPO) $"PA/MR"
			nPOS := aSCAN(aHEADER, {|X| UPPER(ALLTRIM(x[2])) == "D1_PEDIDO"})
			cCOD := aCOLS[n,nPOS]
			If Empty(cCOD)
				Msginfo("Para produtos do tipo(PA/MR), é obrigatório o vínculo à um pedido de compras!!!","P E R F U M E S  D A N A - MT100LOK")
				cString := .F.
			Endif
		Endif
	Endif
Endif

Return(cString)


Static Function Verif()

_cAlias := Alias()
_nIndex := IndexOrd()
_nReg   := Recno()
cSTRING := .F.

_nLinGetD  := n

_nPosVUnit   := aScan(aHeader, { |x| Alltrim(x[2]) == "D1_VUNIT" })
_nPosQuant   := aScan(aHeader, { |x| Alltrim(x[2]) == "D1_QUANT" })
_nPosPedido  := aScan(aHeader, { |x| Alltrim(x[2]) == "D1_PEDIDO" })
_nPosItem    := aScan(aHeader, { |x| Alltrim(x[2]) == "D1_ITEMPC" })
_nPosTES     := aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES" })
_cPED        := aCols[_nLinGetD, _nPosPedido]
_nITEM       := aCols[_nLinGetD, _nPosItem]
_nVLR        := aCols[_nLinGetD, _nPosVUnit]
_cTES        := aCols[_nLinGetD, _nPosTES]
_nQTD        := aCols[_nLinGetD, _nPosQuant]

_mvqtd := getmv("MV_LIMQTD")
_mvvlr := getmv("MV_LIMVLR")
_mvtes := getmv("MV_TESLIB")

_cDuplic := GetAdvFVal("SF4","F4_DUPLIC",xFilial("SF4")+_cTes,1)

If _cTES $ _mvtes .or. _cDuplic == "N"
	cSring := .T.
Else
	_nC7vlr := GetAdvFVal("SC7","C7_PRECO",xFilial("SC7")+_cPed+_nItem,1)
	_nC7qtd := GetAdvFVal("SC7","C7_QUANT",xFilial("SC7")+_cPed+_nItem,1)
	
	_ndifvlr  := _nC7vlr - ((_nC7Vlr * _mvvlr)/100)
	_ndifvlrm := _nC7vlr + ((_nC7Vlr * _mvvlr)/100)
	_ndifqtdm := _nC7qtd + ((_nC7qtd * _mvqtd)/100)
	
	If _nVLR > _ndifvlrm
		MsgBox("! Valor unitario "+Transform(_nvlr,"@E 999,999.999")+", esta acima do permitido = "+Transform(_ndifvlrm,"@E 999,999.999"),"Alterar o Pedido!!!","STOP")
		aCols[_nLinGetD, _nPosVUnit] := 0
		cString := .F.
	Else
		cString := .T.
	Endif
	
	if _nQTD > _ndifqtdm
		MsgBox("! Quantidade esta "+Transform(_nQTD,"@E 999,999.999")+", acima do permitido = "+Transform(_ndifqtdm,"@E 999,999.999"),"Alterar o Pedido!!!","STOP")
		aCols[_nLinGetD, _nPosQuant] := 0
		cString := .F.
	Else
		cString := .T.
	Endif
	
Endif

Return()
