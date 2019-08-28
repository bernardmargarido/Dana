#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GATCNTAUX ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 24/07/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gatilhos auxiliares Gestão de contratos(Medições).         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function GATCNTAUX(SeqGat)

Local cRet		:= ""
Local nNumCNF	:= ""
Local cQuery	:= ""
Local cQuery2	:= ""

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

If Select("TRBCNF2") > 0
	TRBCNF2->(DbCloseArea())
Endif

cQuery2	:= " SELECT CNF_FILIAL, CNF_CONTRA, CNF_PARCEL, CNF_COMPET, CNF_REVISA, CNF_NUMERO, CNF_PARCEL, CNF_DTVENC FROM " +RetSqlName("CNF") + " CNF (NOLOCK)"
cQuery2	+= " WHERE CNF_CONTRA = '"+M->CND_CONTRA+"' "
cQuery2	+= " AND CNF_FILIAL = '"+xFilial("CND")+"' "
cQuery2	+= " AND CNF_REVISA = '"+CND_REVISA+"' "
cQuery2	+= " AND CNF_NUMERO = '"+nNumCNF+"' "
cQuery2	+= " AND CNF_COMPET = '"+M->CND_COMPET+"' "
cQuery2	+= " AND CNF_VLREAL = '0' "
cQuery2	+= " AND CNF.D_E_L_E_T_ = '' "
cQuery2	+= " ORDER BY CNF_FILIAL, CNF_CONTRA, CNF_PARCEL "
PLSQUERY(cQuery2,"TRBCNF2")

If SeqGat == "001"//Atualiza Parcela
	If Select("TRBCNF") > 0
		cRet	:=	TRBCNF->CNF_PARCEL //Posicione("CNF",2,TRBCNF->CNF_FILIAL + TRBCNF->CNF_CONTRA + TRBCNF->CNF_REVISA + TRBCNF->CNF_NUMERO + TRBCNF->CNF_COMPET,"CNF_PARCEL")
		TRBCNF->(DbCloseArea())
	Else
		cRet:=	M->CND_PARCEL
	Endif
Endif

If SeqGat == "002"//Atualiza Data de Vencimento
	If Select("TRBCNF2") > 0
		cRet	:=	TRBCNF2->CNF_DTVENC //Posicione("CNF",2,TRBCNF->CNF_FILIAL + TRBCNF->CNF_CONTRA + TRBCNF->CNF_REVISA + TRBCNF->CNF_NUMERO + TRBCNF->CNF_COMPET,"CNF_DTVENC")
		TRBCNF2->(DbCloseArea())
	Else
		cRet:=	M->CND_DTVENC
	Endif
Endif

Return(cRet)
