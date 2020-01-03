#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M440STTS ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 15/04/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Grava valor total liberado no pedido.                      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function M440STTS()

Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local nTotPed	:= 0
Local cFilSC5	:= SC5->C5_FILIAL
Local cPedSC5	:= SC5->C5_NUM
Local cUFCli	:= Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_EST")
    
DbSelectArea("SC9")
SC9->(dbGoTop())
DbSetOrder(1)//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
If Dbseek(cFilSC5+cPedSC5)
	While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == SC5->(C5_FILIAL+C5_NUM)
		Reclock("SC9",.F.)
			SC9->C9_XFUCLI	:= cUFCli
		SC9->(MsUnlock())
		
		If !Empty(SC9->C9_BLCRED) .And. Alltrim(SC9->C9_BLCRED) <> "10"// 10 - Faturado
			nTotPed	+= SC9->C9_QTDLIB * SC9->C9_PRCVEN
		Endif
		SC9->(DbSkip())
	EndDo
Endif

DbSelectArea("SC5")
DbSetOrder(1)
If DbSeek(cFilSC5+cPedSC5)
	RecLock("SC5",.F.)
	SC5->C5_XTOTLIB	:= nTotPed
	SC5->(MsUnlock())
Endif

RestArea(aAreaSC9)
RestArea(aAreaSC5)

Return
