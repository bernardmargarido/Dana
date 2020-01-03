#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CTBDESFIN ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 07/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Contabiliza desconto financeiro/Bonificação.               ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function CTBDESFIN

Local nRet		:= 0
Local cQuery	:= ""
Local aAreaSF2	:= SF2->(GetArea())

If Select("TRBSE1") > 0
	TRBSE1->(DbCloseArea())
Endif

cQuery	:= " SELECT E1_DESCFIN, E1_VALOR FROM " + RetSqlName("SE1") + " (NOLOCK) "
cQuery	+= " WHERE E1_NUM = '"+SF2->F2_DOC+"' "
cQuery	+= " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' "
cQuery	+= " AND E1_FILORIG = '"+SF2->F2_FILIAL+"' "
cQuery	+= " AND E1_CLIENTE = '"+SF2->F2_CLIENTE+"' "
cQuery	+= " AND E1_LOJA = '"+SF2->F2_LOJA+"' "
cQuery	+= " AND D_E_L_E_T_ = '' "
PLSQUERY(cQuery,"TRBSE1")

If Select("TRBSE1") > 0
	While !TRBSE1->(Eof())
		If nRet == 0
			nRet	:= (TRBSE1->E1_DESCFIN * TRBSE1->E1_VALOR)/100
		Else
			nRet	+= (TRBSE1->E1_DESCFIN * TRBSE1->E1_VALOR)/100
		Endif
		TRBSE1->(DbSkip())
	EndDo	
	TRBSE1->(DbCloseArea())	
Endif

RestArea(aAreaSF2)

Return(nRet)
