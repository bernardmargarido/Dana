#Include 'Protheus.ch'
#include 'TOPCONN.ch'
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DNCTB001  ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 17/09/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Função para apoio na contabilização.                       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function DNCTB001(cLP,cTp,cConta,cHist)

Local xRet
Local cQuery1	:= ""
Local aArea		:= GetArea()

If cLP == "650" .And. cTp == "C"//Conta Crédito LP 650/020 e Débio LP 655/020
	cQuery1	:=	" SELECT E2_NATUREZ "
	cQuery1	+=	" FROM "+RetSqlName("SE2") "
	cQuery1	+=	"  (NOLOCK) WHERE E2_FILIAL = '"+xFilial("SF1")+"'
	cQuery1	+=	" AND E2_PREFIXO = '"+SF1->F1_SERIE+"'
	cQuery1	+=	" AND E2_NUM = '"+SF1->F1_DOC+"'
	cQuery1	+=	" AND E2_FORNECE = '"+SF1->F1_FORNECE+"'
	cQuery1	+=	" AND E2_LOJA = '"+SF1->F1_LOJA+"'
	cQuery1	+=	" AND E2_ORIGEM IN ('MATA100','MATA103')
	cQuery1	+=	" AND "+RetSqlName("SE2")+".D_E_L_E_T_= ' '
	
	cAlias1 := GetNextAlias()
	If !Empty(Select(cAlias1))
		DbSelectArea(cAlias1)
		(cAlias1)->(dbCloseArea())
	Endif
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery1),cAlias1, .T., .T.)
	
	dbSelectArea(cAlias1)
	(cAlias1)->(DbGoTop())
	If (cAlias1)->(Eof())
		xRet := 0
	Else
		xRet :=	Posicione("SDE",1,xFilial("SDE") + (cAlias1)->E2_NATUREZ,"ED_CONTA")
	EndIf
	
	//+------------------------------+
	// Fecha Alias se estiver em Uso |
	//+------------------------------+
	If !Empty(Select(cAlias1))
		DbSelectArea(cAlias1)
		(cAlias1)->(dbCloseArea())
	Endif
	
Endif

RestArea(aArea)

Return(xRet)
