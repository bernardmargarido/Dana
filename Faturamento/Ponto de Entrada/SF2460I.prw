#include "rwmake.ch"

User Function SF2460I()

Local cGerente	:= ""
aAreacps	:= GetArea()
aAreaSE1	:= SE1->(GetArea())
_VEND		:= ""

Return .T.

DBSelectArea("SF2")
//  _VEND := GetAdvFval("SC5","C5_VEND1",xFilial("SC5")+SF2->(F2_DOC+F2_SERIE),5)
_XPEDIDO := POSICIONE("SD2",3,xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),"D2_PEDIDO")
_VEND    := POSICIONE("SC5",1,xFilial("SC5")+_XPEDIDO,"C5_VEND1")

//  dbSelectArea("SC5")
//  dbSetOrder(5)
//  dbSeek(xFilial("SC5")+SF2->F2_DOC+SF2->F2_SERIE)
//  _VEND   := SC5->C5_VEND1

IF EMPTY(_VEND)
	_VEND := GetAdvFval("SA1","A1_VEND",xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),1)
ENDIF

IF EMPTY(_VEND)
	_VEND := "070"  // VENDAS DIRETO
ENDIF

DbSelectArea("SF2")
Reclock("SF2",.F.)
SF2->F2_PLIQUI:= ROUND(SF2->F2_PLIQUI,0)
SF2->F2_PBRUTO:= ROUND(SF2->F2_PLIQUI*1.05,0)
SF2->F2_VEND1 := _VEND
MSUNLOCK()

//Grava gerente de vendas
If SF2->F2_TIPO <> 'D' .Or. SF2->F2_TIPO <> 'B'
	DbSelectArea("SE1")
	DbSetOrder(2)
	DbSeek(xFilial("SE1") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DOC)
	If Found()
		cGerente	:= Posicione("SA3",1,xFilial("SA3")+_VEND,"A3_GEREN")
		While SE1->(!Eof()) .And. xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DOC) == SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)
			RecLock("SE1", .F.)
			SE1->E1_XGERENT		:= cGerente
			SE1->(MsUnlock())
			SE1->(DbSkip())
		EndDo
	Endif
Endif

RestArea(aAreaCps)
RestArea(aAreaSE1)

RETURN
