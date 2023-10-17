#INCLUDE "Protheus.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M030INC   ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 26/07/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ PE executado após inclusão SA1, grava dados adicionas GU3  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ DANA COSMÉTICOS 						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function M030INC

Local cQuery    := ""
Local cCanal    := ""
Local aArea     := GetArea()

/*
If !PARAMIXB == 3 .AND. ALLTRIM(FUNNAME()) == "MATA030"
    cCanal  := M->A1_XTIPCLI

    //-----------------------
    // Verifica se gerou GU3.| 
    //-----------------------
    If Select("TRBGU3") > 0
        TRBGU3->(DbCloseArea())
    Endif

	cQuery:= " SELECT GU3_FILIAL, GU3_CDEMIT FROM " + RetSqlName("GU3") +" GU3 (NOLOCK) "
	cQuery+= " WHERE GU3_CDERP = '"+M->A1_COD+"' "
    cQuery+= " AND GU3_CDCERP = '"+M->A1_LOJA+"' "
    cQuery+= " AND GU3_IDFED ='"+M->A1_CGC+"' "
    cQuery+= " AND GU3.D_E_L_E_T_ = '' "
	PLSQUERY(cQuery,"TRBGU3")

    If Select("TRBGU3") > 0
        If !Empty(TRBGU3->GU3_CDEMIT)
            DbSelectArea("GU3")
            DbSetOrder(1)//GU3_FILIAL+GU3_CDEMIT
            If Dbseek(TRBGU3->(GU3_FILIAL+GU3_CDEMIT))
                If !Empty(cCanal)
                    If cCanal == "1"//Atacado
                        cCanal:= "A"
                    else
                        cCanal := "V"
                    Endif
                    RecLock("GU3",.F.)
                    GU3->GU3_XTPCLI := cCanal
                    GU3->(MsUnlock())
                EndIf
            Endif
        Endif
    Endif
EndIf
*/
//------------------------------------------------+
// Chamada Ponto de Entrada Projetos Corporativos |
//------------------------------------------------+
If ExistBlock("XM030INC")
	ExecBlock("XM030INC",.F.,.F.,PARAMIXB)
EndIf

RestArea(aArea)

Return
