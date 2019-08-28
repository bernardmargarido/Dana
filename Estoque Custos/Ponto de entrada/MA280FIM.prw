#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#Include "TOTVS.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA280FIM  ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 05/10/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Executado no final da rotina virada de saldo.              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA     					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function MA280FIM()

Local lRet		:= .T.
Local dData 	:=  CTOD("  /  /    ")  // ParamIxb
Local cQuery	:= ""
Local cQryDtB9	:= ""
Local cLocSB9	:= Alltrim(GetMV("MV_XLOCSB9"))
Local aAreaZ02	:= Z02->(GetArea())
Local nValCus	:= 0
Local cDescSB1	:= ""
Local cCompet	:= ""
                   

/*--------------------------------\
| Busca data do Fechamento Atual. |
\--------------------------------*/
If Select("TRDTB9") > 0
	TRDTB9->(DbCloseArea())   
Endif

cQryDtB9	:= " SELECT B9_DATA FROM " +RetSqlName("SB9") + " SB9 (NOLOCK)"
cQryDtB9	+= " WHERE R_E_C_N_O_=( "
cQryDtB9	+= " SELECT MAX(R_E_C_N_O_) AS 'MAX_RECNO' FROM " +RetSqlName("SB9") + " (NOLOCK)"
cQryDtB9	+= " WHERE B9_DATA <> '' AND D_E_L_E_T_='' "
cQryDtB9	+= " ) "
PLSQUERY(cQryDtB9,"TRDTB9")

If Select("TRDTB9") > 0
	dData	:= TRDTB9->B9_DATA
	TRDTB9->(DbCloseArea())   
Endif


/*--------------------------------\
| Busca data do Fechamento Atual. |
\--------------------------------*/
If Select("TRBSB9") > 0
	TRBSB9->(DbCloseArea())   
Endif

cQuery	:= " SELECT B9_FILIAL, B9_COD, B9_DATA, B9_CM1 FROM " +RetSqlName("SB9") + " SB9 (NOLOCK)"
cQuery	+= " WHERE B9_DATA = '"+DTOS(dData)+"' "
cQuery	+= " AND B9_LOCAL = '"+cLocSB9+"' "
cQuery	+= " AND B9_FILIAL = '"+xFilial("Z02")+"' "
cQuery	+= " AND SB9.D_E_L_E_T_ = '' "
cQuery	+= " ORDER BY B9_COD "
PLSQUERY(cQuery,"TRBSB9")

If Select("TRBSB9") > 0
	While TRBSB9->(!Eof())
		nValCus		:=	TRBSB9->B9_CM1
		cDescSB1	:=	Posicione("SB1",1,xFilial("SB1")+TRBSB9->B9_COD,"B1_DESC")
		cCompet		:=	SUBSTR(DTOS(TRBSB9->B9_DATA),5,2) + SUBSTR(DTOS(TRBSB9->B9_DATA),1,4)

		DbSelectArea("Z02")
		DbSetOrder(1)//Z02_FILIAL+ZO2_COD
		If !Dbseek(TRBSB9->B9_FILIAL + TRBSB9->B9_COD + cCompet)
			RecLock("Z02",.T.)
			Z02->Z02_FILIAL	:= TRBSB9->B9_FILIAL
			Z02->Z02_COD	:= TRBSB9->B9_COD
			Z02->Z02_DESC	:= Alltrim(cDescSB1)
			Z02->Z02_COMPET	:= cCompet
			Z02->Z02_CONTAB	:= nValCus
			Z02->Z02_CUSTNF	:= 0
			Z02->Z02_MSBLQL	:= "2"//Não Bloqueado
			Z02->(MsunLock())
		Else
			RecLock("Z02",.F.)
			Z02->Z02_CONTAB	:= nValCus
			Z02->(MsunLock())
		EndIf
		TRBSB9->(DbSkip())
	EndDo
Endif

If Select("TRBSB9") > 0
	TRBSB9->(DbCloseArea())   
Endif

RestArea(aAreaZ02)

Return(lRet)