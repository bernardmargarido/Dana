#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"

User Function XATUGEREN

Local cGerente	:= ""
Local cQuery	:= ""
Local aAreaSE1	:= SE1->(GetArea())

If Select("TRBSE1") > 0
	TRBSE1->(DbCloseArea())
Endif

cQuery	:= "SELECT E1_VEND1, R_E_C_N_O_ AS 'RECSE1' FROM " + RetSqlName("SE1") + "(NOLOCK) "
cQuery	+= "WHERE E1_EMISSAO >= '20140101' "
cQuery	+= "AND E1_VEND1 <> '' "
cQuery	+= "AND E1_XGERENT = '' "
cQuery	+= "AND D_E_L_E_T_ = '' "
cQuery	+= "ORDER BY E1_FILIAL "
PLSQUERY(cQuery,"TRBSE1")
          
While !TRBSE1->(Eof())
	
	cGerente	:= Posicione("SA3",1,xFilial("SA3")+TRBSE1->E1_VEND1,"A3_GEREN")
	
	DbSelectArea("SE1")
	SE1->(DbGoto(TRBSE1->RECSE1))
	If !Empty(cGerente)
		RecLock("SE1",.F.)
		SE1->E1_XGERENT	:= cGerente
		SE1->(Msunlock())
	Endif
	TRBSE1->(DbSkip())
EndDo

If Select("TRBSE1") > 0
	TRBSE1->(DbCloseArea())
Endif

RestArea(aAreaSE1)

Msginfo("Atualização de gerente finalizada com sucesso!!!","P E R F U M E S  D A N A")

Return()
