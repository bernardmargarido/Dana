#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT100TOK  ¦Autor ¦ Clayton Martins    ¦ Data ¦ 20/09/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Valida inclusão NFE, analisa possível duplicidade.         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function MT100TOK()

Local lRet		:= .T.
Local dEmiSF1	:= dDEmissao
Local cForSF1	:= cA100For
Local cLojSF1	:= cLoja
Local nTotSF1	:= MaFisRet(n,"IT_TOTAL")
Local cQuery	:= ""
Local cPulaLin	:= Chr(13) + Chr(10)
Local cNomSA2	:= ""

If Select("TRBSF1") > 0
	TRBSF1->(DbCloseArea())
Endif

cQuery	:= " SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_EMISSAO, F1_FORNECE, F1_LOJA, F1_VALBRUT FROM " + RetSqlName("SF1") + " SF1 (NOLOCK) "
cQuery	+= " WHERE F1_EMISSAO = '"+DTOS(dEmiSF1)+"' "
cQuery	+= " AND F1_FORNECE = '"+cForSF1+"' "
cQuery	+= " AND F1_LOJA = '"+cLojSF1+"' "
cQuery	+= " AND F1_VALBRUT = '"+cValToChar(nTotSF1)+"' "
cQuery	+= " AND F1_FILIAL = '"+xFilial("SF1")+"' "
cQuery	+= " AND SF1.D_E_L_E_T_ = '' "
PLSQUERY(cQuery,"TRBSF1")

If Select("TRBSF1") > 0
	cNomSA2	:= Posicione("SA2",1,xFilial("SA2") + TRBSF1->F1_FORNECE + TRBSF1->F1_LOJA,"A2_NOME")
    If !Empty(cNomSA2)
		If !MsgYesNo("*** NOTA FISCAL JÁ LANÇADA COM OS DADOS ABAIXO, DESEJA CONTINUAR O LANÇAMENTO? ***" + cPulaLin + "Número: "+TRBSF1->F1_DOC + cPulaLin + "Serie: "+TRBSF1->F1_SERIE + cPulaLin + "Fornecedor: "+Alltrim(cNomSA2),"P E R F U M E S  D A N A - MT100TOK")
			lRet	:= .F.
		Endif
	Endif
	TRBSF1->(DbCloseArea())	
Endif

Return(lRet)
