#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XDBCOFOR ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 26/04/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Dados bancários Fornecedor pagamento CNAB/SISPAG.          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function XDBCOFOR

Local cDadosFor	:= ""

If Alltrim(SE2->E2_FORBCO)== "341"//Crédito em Conta
	cDadosFor	:= "0" + STRZERO(VAL(SE2->E2_FORAGE),4) + SPACE(1) + "000000" + STRZERO(VAL(SE2->E2_FORCTA),6) + SPACE(1) + ALLTRIM(SE2->E2_FCTADV)
Else
	cDadosFor	:= STRZERO(VAL(SE2->E2_FORAGE),5) + SPACE(1) + STRZERO(VAL(SE2->E2_FORCTA),12) + SPACE(1) + ALLTRIM(SE2->E2_FCTADV)
Endif

Return(cDadosFor)
