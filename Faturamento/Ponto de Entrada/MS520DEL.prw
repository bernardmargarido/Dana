#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MS520DEL ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 05/07/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exclui Comissoes de Vendas, caso não tenha sido paga.      ¦¦¦
¦¦¦          ¦ No caso da comissão pagar, comissão negativa.              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function MS520DEL

Local cQuery	:= ""
Local cSeqSE3	:= ""
Local aDadosSE3	:= {}
Local aAreaSF2	:= SF2->(GetArea())
Local aAreaSE3	:= SE3->(GetArea())

Local Nx		:= 0

DbSelectArea("SE3")
DbSetOrder(3)//E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ
If Dbseek(xFilial("SE3")+SF2->(F2_VEND1 + F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC))
	
	If Select("TRBSE3")	> 0
		TRBSE3->(DbCloseArea())
	Endif
	
	cQuery	:= " SELECT MAX(E3_SEQ) AS 'MAXSEQ' FROM " +RetSqlname("SE3") + " (NOLOCK)"
	cQuery	+= " WHERE E3_NUM = '"+SF2->F2_DOC+"'
	cQuery	+= " AND E3_PREFIXO = '"+SF2->F2_SERIE+"'
	cQuery	+= " AND E3_CODCLI = '"+SF2->F2_CLIENTE+"'
	cQuery	+= " AND E3_LOJA = '"+SF2->F2_LOJA+"'
	cQuery	+= " AND E3_VEND = '"+SF2->F2_VEND1+"'
	cQuery	+= " AND E3_FILIAL = '"+xFilial("SE3")+"'
	PLSQUERY(cQuery,"TRBSE3")
	
	If Select("TRBSE3")	> 0
		cSeqSE3	:= Soma1(TRBSE3->MAXSEQ)
		TRBSE3->(DbCloseArea())
	Endif
	
	While !SE3->(Eof()) .And. xFilial("SE3")+SF2->(F2_VEND1 + F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC) == SE3->(E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM)
		If Empty(SE3->E3_DATA)
			Reclock("SE3",.F.)
			SE3->(DbDelete())
			SE3->(MsUnlock())
		Else
			aAdd(aDadosSE3,{SE3->E3_BASE,;
			-SE3->E3_COMIS,;
			SE3->E3_FILIAL,;
			SE3->E3_VEND,;
			SE3->E3_NUM,;
			SE3->E3_SERIE,;
			SE3->E3_PORC,;
			SE3->E3_CODCLI,;
			SE3->E3_LOJA,;
			dDatabase,;
			SE3->E3_PREFIXO,;
			SE3->E3_PARCELA,;
			SE3->E3_TIPO,;
			SE3->E3_ORIGEM,;
			SE3->E3_VENCTO,;
			SE3->E3_BAIEMI,;
			SE3->E3_MOEDA,;
			SE3->E3_PEDIDO,;
			cSeqSE3,;
			SE3->E3_XCODPRO,;
			SE3->E3_XCATEGO,;
			SE3->E3_XITEMNF})
		Endif
		cSeqSE3	:= Soma1(cSeqSE3)
		SE3->(DbSkip())
	EndDo
Endif

DbSelectArea("SE3")
DbSetOrder(1)
If Len(aDadosSE3) > 0	
	For Nx := 1 to Len(aDadosSE3)
		RecLock("SE3",.T.)
		SE3->E3_BASE    := aDadosSE3[Nx][1]
		SE3->E3_COMIS   := aDadosSE3[Nx][2]
		SE3->E3_FILIAL  := aDadosSE3[Nx][3]
		SE3->E3_VEND    := aDadosSE3[Nx][4]
		SE3->E3_NUM     := aDadosSE3[Nx][5]
		SE3->E3_SERIE   := aDadosSE3[Nx][6]
		SE3->E3_PORC    := aDadosSE3[Nx][7]
		SE3->E3_CODCLI  := aDadosSE3[Nx][8]
		SE3->E3_LOJA    := aDadosSE3[Nx][9]
		SE3->E3_EMISSAO := aDadosSE3[Nx][10]
		SE3->E3_PREFIXO := aDadosSE3[Nx][11]
		SE3->E3_PARCELA := aDadosSE3[Nx][12]
		SE3->E3_TIPO    := aDadosSE3[Nx][13]
		SE3->E3_ORIGEM  := aDadosSE3[Nx][14]
		SE3->E3_VENCTO  := aDadosSE3[Nx][15]
		SE3->E3_BAIEMI  := aDadosSE3[Nx][16]
		SE3->E3_MOEDA	:= aDadosSE3[Nx][17]
		SE3->E3_PEDIDO	:= aDadosSE3[Nx][18]
		SE3->E3_SEQ		:= aDadosSE3[Nx][19]
		SE3->E3_XCODPRO	:= aDadosSE3[Nx][20]
		SE3->E3_XCATEGO	:= aDadosSE3[Nx][21]
		SE3->E3_XITEMNF	:= aDadosSE3[Nx][22]
		SE3->E3_XMOTCOM	:= "4"//Nota deletada, de uma comissão que gerou título a pagar para o vendedor
		SE3->(MsUnlock())
	Next
Endif

RestArea(aAreaSE3)
RestArea(aAreaSF2)

Return()
