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
SetPrvt("_CNAT,ACOLS,_LRETURN,_CCC,CCOLORANT,CSAVESCR,_NPOSITORI,_CITORI,_NPOSSERORI,_CSERORI,_NPOSNFORI,_CNFORI")
SetPrvt("CSAVEMENUH,")

Private cString 	:= .T.
Private dEmiNF		:= M->DDEMISSAO
Private dDtBase		:= dDataBase 

Private cTpNF		:= M->C103TIPO
Private cCliOri		:= M->CA100FOR
Private cLojOri		:= M->CLOJA

Private _lDanaLog	:= (cEmpAnt == "02" .And. cFilAnt == "01")
/*
dEmiNF	:= DTOS(dEmiNF)
dEmiNF	:= Substr(dEmiNF,7,2) + "/" + Substr(dEmiNF,5,2) + "/" + Substr(dEmiNF,1,4)

dDtBase	:= DTOS(dDtBase)
dDtBase	:= Substr(dDtBase,7,2) + "/" + Substr(dDtBase,5,2) + "/" + Substr(dDtBase,1,4)
*/

If ( altera .or. inclui ) .And. !_lDanaLog
/*	
	If M->DDEMISSAO < dDataBase
		Msginfo("A data de emissão da nota: "+dEmiNF+" não pode ser menor que a data de login do sistema: "+dDtBase,"P E R F U M E S  D A N A - MT100LOK")
		cString := .F.
	Endif
*/
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
		If Alltrim(SB1->B1_TIPO) $"PA/MR" .AND. M->CTIPO == "N"
			nPOS := aSCAN(aHEADER, {|X| UPPER(ALLTRIM(x[2])) == "D1_PEDIDO"})
			cCOD := aCOLS[n,nPOS]
			If Empty(cCOD)
				Msginfo("Para produtos do tipo(PA/MR), é obrigatório o vínculo à um pedido de compras!!!","P E R F U M E S  D A N A - MT100LOK")
				cString := .F.
			Endif
		Endif
	Endif
	
	If cTpNF =="D"//Devolução
		nPosIte	:= aSCAN(aHEADER, {|X| UPPER(ALLTRIM(x[2])) == "D1_ITEMORI"})
		cItNF	:= aCOLS[n,nPosIte]
		
		nPosSer := aSCAN(aHEADER, {|X| UPPER(ALLTRIM(x[2])) == "D1_SERIORI"})
		cSerNf	:= aCOLS[n,nPosSer]
		
		nPosNFo := aSCAN(aHEADER, {|X| UPPER(ALLTRIM(x[2])) == "D1_NFORI"})
		cNFOri	:= aCOLS[n,nPosNFo]
		
		nPosCod := aSCAN(aHEADER, {|X| UPPER(ALLTRIM(x[2])) == "D1_COD"})
		cCodOri	:= aCOLS[n,nPosCod]

		If !Empty(cItNF) .And. !Empty(cSerNf) .And. !Empty(cNFOri)
			DCNFDEV(cNFOri,cSerNf,cCliOri,cLojOri,cCodOri,cItNF)//Valida NF origem
		Else
			Msginfo("Os campos NF Original, Item NF Original e Serie NF Original, devem ser preenchidos para prosseguir com a devolução! Dica, aperte ENTER e a tecla F7 para localizar o documento de origem!","P E R F U M E S  D A N A - MT100LOK")
		Endif
		
	Endif	
		
	
Endif

Return(cString)


Static Function Verif()

_cAlias := Alias()
_nIndex := IndexOrd()
_nReg   := Recno()
//cSTRING := .F.

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


/*-------------------\
| Busca nota origem. |
\-------------------*/
Static Function DCNFDEV(cNFOri,cSerNf,cCliOri,cLojOri,cCodOri,cItNF)

Local aAreaSD2 := SD2->(GetArea())

DbSelectArea("SD2")
DbSetOrder(3)//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If !Dbseek(xFilial("SD2")+cNFOri+cSerNf+cCliOri+cLojOri+cCodOri+cItNF)
	If !MsgYesNo("Os dados informados, Nota, Serie e Item, não foram localizados para esse cliente. Deseja continuar?", "A T E N Ç Ã O - MT100LOK")
		cString	:= .F.
	Endif
Endif

RestArea(aAreaSD2)

Return()