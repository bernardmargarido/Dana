#Include "Protheus.ch"
#Include "rwmake.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PDCOM001  ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 30/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Grava histórico na rotina Documento de entrada.            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function PDCOM001()

Private lContinua	:= .T.
Private oDlgDI		:= NIL
Private aArea		:= GetArea()
Private cObs		:= SPACE(500)
Private lObs		:= .T.
Private cFilSF1		:= F1_FILIAL
Private cDocSF1		:= F1_DOC
Private cSerSF1		:= F1_SERIE
Private cForSF1		:= F1_FORNECE
Private cLojSF1		:= F1_LOJA
Private cTipSF1		:= F1_TIPO

Static oMultiGet1

DbSelectArea("SF1")
DbSetOrder(1)//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
If Dbseek(cFilSF1 + cDocSF1 + cSerSF1 + cForSF1 + cLojSF1 + cTipSF1)
	If Alltrim(SF1->F1_TIPO) == "N"
		If !Empty(SF1->F1_XHISTNF)
			lObs		:= .F.
			cObs		:= SF1->F1_XHISTNF
		Endif
		@ 000,000 TO 150,700 DIALOG oDlgDI TITLE "Histórico Documento de entrada"
		@ 015, 005 SAY "Histórico NFE:"
		@ 015, 060 GET oMultiGet1 VAR cObs WHEN lObs OF oDlgDI MULTILINE SIZE 150,30 COLORS 0, 16777215 HSCROLL PIXEL
		@ 015,230 BUTTON "Confirmar" SIZE 040,012 ACTION _Gravar(lObs)
		@ 015,280 BUTTON "Sair" SIZE 040,012 ACTION _Sair()
		ACTIVATE DIALOG oDlgDI CENTER
	Else
		Msginfo("Hitórico só pode ser adicionado para notas de entrada do tipo Normal!","PDCOM001 - P E R F U M E S  D A N A !!!")
	Endif
Endif

RestArea(aArea)

Return .T.


/*-----------------------------------------\
| Grava histórico na nota e no(s) titulo(s)|
\-----------------------------------------*/
Static Function _Gravar(lObs)

If lObs
	RecLock("SF1", .F.)
	SF1->F1_XHISTNF		:= cObs
	lContinua := .F.
	Close(oDlgDI)
	SF1->(MsUnLock())
	
	DbSelectArea("SE2")
	DbSetOrder(6)//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	If Dbseek(xFilial("SE2") + cForSF1 + cLojSF1 + cSerSF1 + cDocSF1)
		While !SE2->(Eof()) .And. SE2->(E2_FILORIG+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cFilSF1 + cForSF1 + cLojSF1 + cSerSF1 + cDocSF1
			RecLock("SE2", .F.)
			SE2->E2_XHISTNF	:= cObs
			SE2->(MsUnLock())
			SE2->(DbSkip())
		EndDo
	Endif
	
Else
	Close(oDlgDI)
	lContinua := .F.
Endif

Return


/*------------------------\
| Fecha tela de histórico |
\------------------------*/
Static Function _Sair()

Close(oDlgDI)
lContinua := .F.

Return
