#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#Include "ap5mail.ch"
#Include "TOTVS.CH"
#Include "apwebsrv.ch"
#Include "apwebex.ch"
#Include "Tbiconn.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GAT2CNTAU ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 24/07/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gatilhos auxiliares Gestão de contratos(Medições).         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function GAT2CNTAU()

Local cRet		:= ""
Local nNumCNF	:= ""
Local cQuery	:= ""

nNumCNF	:= 	Posicione("CNF",2,xFilial("CND") + M->CND_CONTRA + M->CND_REVISA,"CNF_NUMERO")

If Select("TRBCNF") > 0
	TRBCNF->(DbCloseArea())
Endif

cQuery	:= " SELECT CNF_FILIAL, CNF_CONTRA, CNF_PARCEL, CNF_COMPET, CNF_REVISA, CNF_NUMERO, CNF_PARCEL, CNF_DTVENC FROM " +RetSqlName("CNF") + " CNF (NOLOCK)"
cQuery	+= " WHERE CNF_CONTRA = '"+M->CND_CONTRA+"' "
cQuery	+= " AND CNF_FILIAL = '"+xFilial("CND")+"' "
cQuery	+= " AND CNF_REVISA = '"+CND_REVISA+"' "
cQuery	+= " AND CNF_NUMERO = '"+nNumCNF+"' "
cQuery	+= " AND CNF_COMPET = '"+M->CND_COMPET+"' "
cQuery	+= " AND CNF_VLREAL = '0' "
cQuery	+= " AND CNF.D_E_L_E_T_ = '' "
cQuery	+= " ORDER BY CNF_FILIAL, CNF_CONTRA, CNF_PARCEL "
PLSQUERY(cQuery,"TRBCNF")

If Select("TRBCNF") > 0
		cRet	:=	TRBCNF->CNF_DTVENC
		//TRBCNF->(DbCloseArea())
	Else
		cRet:=	M->CND_PARCEL
Endif

Return(cRet)
