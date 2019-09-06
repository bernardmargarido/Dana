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
Local aAreaSC6  := SC6->(GetArea())
Local nTotPed	:= 0
Local cFilSC5	:= SC5->C5_FILIAL
Local cPedSC5	:= SC5->C5_NUM
Local cUFCli	:= Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_EST")
Local cNumPed	:= SC5->C5_XNUMCLI
Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")

//---------------------------+
// Posiciona pedido de venda |
//---------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )
SC5->(dbSeek(cFilSC5 + cPedSC5))

    
dbSelectArea("SC9")
SC9->( dbGoTop() )
SC9->( dbSetOrder(1) )//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
If SC9->( dbseek(cFilSC5 + cPedSC5) )
	While SC9->( !Eof() .And.  cFilSC5 + cPedSC5 == SC9->C9_FILIAL + C9_PEDIDO )
		
		Reclock("SC9",.F.)
			SC9->C9_XFUCLI	:= cUFCli
			
			//-----------------------------------------+	
			// Reliberação de pedido ja separado no WMS|
			//-----------------------------------------+
			If cFilSC5 $ _cFilWMS
				If SC5->C5_XENVWMS == "3"
					SC9->C9_XENVWMS := "3"
					SC9->C9_XDTALT 	:= Date()
					SC9->C9_XHRALT 	:= Time()
				ElseIf SC5->C5_XENVWMS $ "1/2" .And. Empty(SC9->C9_XENVWMS) 
					SC9->C9_XENVWMS := SC5->C5_XENVWMS
					SC9->C9_XDTALT 	:= Date()
					SC9->C9_XHRALT 	:= Time()	
				EndIf
			EndIf
			
		SC9->( MsUnlock() )

		If !Empty(SC9->C9_BLCRED) .And. Alltrim(SC9->C9_BLCRED) <> "10"// 10 - Faturado
			nTotPed	+= SC9->C9_QTDLIB * SC9->C9_PRCVEN
		Endif
		
		SC9->( dbSkip())
	EndDo
Endif

//--------------------------+
// Atualiza total do pedido | 
//--------------------------+
RecLock("SC5",.F.)
	SC5->C5_XTOTLIB	:= nTotPed
	If cFilSC5 $ _cFilWMS
		SC5->C5_XENVWMS := SC5->C5_XENVWMS
		SC5->C5_XDTALT	:= Date()
		SC5->C5_XHRALT	:= Time()
	EndIf
SC5->( MsUnlock() )

If !Empty(cNumPed)
	DbselectArea("SC6")
	DbSetOrder(1)//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO	
	If SC6->(Dbseek(cFilSC5+cPedSC5))
		While SC6->(!Eof()) .And. cFilSC5+cPedSC5 == SC6->(C6_FILIAL+C6_NUM)
			If Empty(SC6->C6_NUMPCOM) .Or. Empty(SC6->C6_ITEMPC)
				Reclock("SC6",.F.)
				SC6->C6_NUMPCOM	:= cNumPed
				SC6->C6_ITEMPC	:= SC6->C6_ITEM
				SC6->(MsUnlock())
			Endif
			SC6->(Dbskip())
		EndDo
	Endif
Endif

//--------------------------------------------------+
// Valida se é reliberação de um pedido já separado | 
//--------------------------------------------------+

RestArea(aAreaSC9)
RestArea(aAreaSC5)
RestArea(aAreaSC6)

Return
