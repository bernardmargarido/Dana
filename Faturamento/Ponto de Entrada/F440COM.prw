#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F440COM  ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 03/07/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualiza tabela (SE3 - Comissoes de Vendas).               ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function F440COM()

Local cFilSD2	:= SD2->D2_FILIAL
Local cFilSE1	:= SE1->E1_FILIAL
Local cNumSE1	:= SE1->E1_NUM
Local cPreSE1	:= SE1->E1_PREFIXO
Local cCliSE1	:= SE1->E1_CLIENTE
Local cLojSE1	:= SE1->E1_LOJA
Local cParcela	:= SE1->E1_PARCELA
//Local dEmissao	:= SE1->E1_EMISSAO
Local dVenc		:= CTOD("  /  /    ")//SE1->E1_VENCTO
Local cTipo		:= SE1->E1_TIPO
Local cSeqSE3	:= "01"
Local cTotPar	:= ""
Local nValBase	:= 0
Local aAreaSE1	:= SE1->(GetArea())
Local aAreaSE3	:= SE3->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaSC5	:= SC5->(GetArea())

RestArea(aAreaSE1)
RestArea(aAreaSE3)
RestArea(aAreaSD2)
RestArea(aAreaSC5)

Return .T.

/*---------------------------\
| Confere total de parcelas  |
\---------------------------*/
DbSelectArea("SE1")
DbSetOrder(1)//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
If Dbseek(cFilSE1 + cPreSE1 +cNumSE1 + cParcela + cTipo)
	While !SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) == cFilSE1 + cPreSE1 +cNumSE1 + cParcela + cTipo
		If Empty(cTotPar)
			cTotPar	:= "01"
		Else
			cTotPar	:= Soma1(cTotPar)
		Endif
		SE1->(DbSkip())
	EndDo
Endif

cTotPar		:= Val(cTotPar)

/*---------------------------\
| Gera comissão por item SE3 |
\---------------------------*/
DbSelectArea("SD2")
DbSetOrder(3)//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If Dbseek(cFilSD2 + cNumSE1 + cPreSE1 + cCliSE1 + cLojSE1)
	While !SD2->(Eof()) .And. cFilSD2 + cNumSE1 + cPreSE1 + cCliSE1 + cLojSE1 == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
		//Valor Base divido por parcela(s)
		nValBase	:= SD2->D2_VALBRUT / cTotPar
		dVenc		:= MonthSum(SD2->D2_EMISSAO,1)
		dVenc		:= DTOS(dVenc)
		dVenc		:= Substr(dVenc,1,6) + "20"
		dVenc		:= STOD(dVenc)
		
		RecLock("SE3",.T.)
		SE3->E3_BASE    := nValBase
		SE3->E3_COMIS   := (SD2->D2_COMIS1*nValBase/100)
		SE3->E3_FILIAL  := cFilSE1
		SE3->E3_VEND    := SD2->D2_VEND1
		SE3->E3_NUM     := SD2->D2_DOC
		SE3->E3_SERIE   := SD2->D2_SERIE
		SE3->E3_PORC    := SD2->D2_COMIS1
		SE3->E3_CODCLI  := SD2->D2_CLIENTE
		SE3->E3_LOJA    := SD2->D2_LOJA
		SE3->E3_EMISSAO := SD2->D2_EMISSAO//dEmissao
		SE3->E3_PREFIXO := SD2->D2_SERIE
		SE3->E3_PARCELA := cParcela
		SE3->E3_TIPO    := cTipo
		SE3->E3_ORIGEM  := "E"
		SE3->E3_VENCTO  := dVenc
		SE3->E3_BAIEMI  := "E"
		SE3->E3_MOEDA	:= "01"
		SE3->E3_PEDIDO	:= SD2->D2_PEDIDO
		SE3->E3_SEQ		:= cSeqSE3
		SE3->E3_XCODPRO	:= SD2->D2_COD
		SE3->E3_XCATEGO	:= Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_XCATEGO")
		SE3->E3_XITEMNF	:= SD2->D2_ITEM
		SE3->E3_XMOTCOM	:= "1"//Vendas
		SE3->(MsUnlock())
		cSeqSE3	:= Soma1(cSeqSE3)
		SD2->(DbSkip())
	EndDo
Endif

RestArea(aAreaSE1)
RestArea(aAreaSE3)
RestArea(aAreaSD2)
RestArea(aAreaSC5)

Return()
