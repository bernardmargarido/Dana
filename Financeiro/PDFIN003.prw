#Include "Protheus.ch"
#Include "rwmake.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PDFIN003  ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 23/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Executa rotina para chamar AXCADASTRO Histórico de manut.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PDFIN003()

Private lContinua	:= .T.
Private oDlgDI		:= NIL
Private aArea		:= GetArea()
Private cFilZ03		:= ""
Private cPreZ03		:= ""
Private cNumZ03		:= ""
Private cCodZ03		:= ""
Private cLojZ03		:= ""
Private cNomZ03		:= ""
Private dEmiZ03		:= ""
Private dVenZ03		:= ""
Private nValZ03		:= 0
Private cTipZ03		:= ""
Private cObsZ03		:= SPACE(500)
Private lTipZ03		:= .T.
Private lObsZ03		:= .T.

Static oMultiGet1

DbSelectArea("Z03")
DbSetOrder(1)//Z03_FILIAL+Z03_PREFIX+Z03_NUM+Z03_TIPO+Z03_FORNEC+Z03_LOJA
If Dbseek(SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_TIPO+E2_FORNECE+E2_LOJA))
	Msginfo("Histórico de manutenção já adicionado ao título!","PDFIN003 - P E R F U M E S  D A N A")
	lTipZ03		:= .F.
	lObsZ03		:= .F.
	cFilZ03		:= Z03->Z03_FILIAL
	cPreZ03		:= Z03->Z03_PREFIX
	cNumZ03		:= Z03->Z03_NUM
	cTpoZ03		:= Z03->Z03_TIPO
	cCodZ03		:= Z03->Z03_FORNEC
	cLojZ03		:= Z03->Z03_LOJA
	cNomZ03		:= Z03->Z03_NOMFOR
	dEmiZ03		:= Z03->Z03_EMISSA
	dVenZ03		:= Z03->Z03_VENCRE
	nValZ03		:= Z03->Z03_VALOR
	cTipZ03		:= Z03->Z03_TIPMAN
	cObsZ03		:= Z03->Z03_OBSERV
Else
	cFilZ03		:= SE2->E2_FILIAL
	cPreZ03		:= SE2->E2_PREFIXO
	cNumZ03		:= SE2->E2_NUM
	cTpoZ03		:= SE2->E2_TIPO
	cCodZ03		:= SE2->E2_FORNECE
	cLojZ03		:= SE2->E2_LOJA
	cNomZ03		:= SE2->E2_NOMFOR
	dEmiZ03		:= SE2->E2_EMISSAO
	dVenZ03		:= SE2->E2_VENCREA
	nValZ03		:= SE2->E2_VALOR
Endif


If lContinua
	@ 000,000 TO 350,800 DIALOG oDlgDI TITLE "Histórico de manutenção contas a pagar"
	
	@ 015, 005 SAY "Filial:"
	@ 015, 060 GET cFilZ03 WHEN .F. PICTURE "@!" SIZE 020,010
	
	@ 015, 150 SAY "Prefixo:"
	@ 015, 180 GET cPreZ03 WHEN .F. PICTURE "@!" SIZE 30,10
	
	@ 015, 240 SAY "Número:"
	@ 015, 265 GET cNumZ03 WHEN .F. PICTURE "@!" SIZE 50,10
	
	@ 030, 005 SAY "Cod Fornecedor:"
	@ 030, 060 GET cCodZ03 WHEN .F. PICTURE "@!" SIZE 050,10
	
	@ 030, 150 SAY "Loja:"
	@ 030, 180 GET cLojZ03 WHEN .F. PICTURE "@!" SIZE 020,10
	
	@ 030, 240 SAY "Nome:"
	@ 030, 265 GET cNomZ03 WHEN .F. PICTURE "@!" SIZE 090,10
	
	@ 045, 005 SAY "Emissão:"
	@ 045, 060 GET dEmiZ03 WHEN .F. PICTURE "@!" SIZE 050,10
	
	@ 045, 150 SAY "Vencimento:"
	@ 045, 180 GET dVenZ03 WHEN .F. PICTURE "@!" SIZE 050,10
	
	@ 045, 240 SAY "Valor:"
	@ 045, 265 GET nValZ03 WHEN .F. PICTURE "@!" SIZE 050,10
	
	@ 060, 005 SAY "Tipo Manutenção:"
	@ 060, 060 COMBOBOX cTipZ03 WHEN lTipZ03 ITEMS {"1-Alteracao","2-Refazer"} SIZE 060,015 Pixel Of oDlgDI
	
	@ 100, 005 SAY "Observação:"
	@ 100, 060 GET oMultiGet1 VAR cObsZ03 WHEN lObsZ03 OF oDlgDI MULTILINE SIZE 150,30 COLORS 0, 16777215 HSCROLL PIXEL
	
	@ 100,230 BUTTON "Confirmar" SIZE 040,012 ACTION _Gravar(lObsZ03)
	@ 100,280 BUTTON "Abandonar" SIZE 040,012 ACTION _Sair()
	ACTIVATE DIALOG oDlgDI CENTER
Endif

RestArea(aArea)

Return .T.


Static Function _Gravar(lObsZ03)

If lObsZ03
	DbSelectArea("Z03")
	DbSetOrder(1)
	RecLock("Z03", .T.)
	
	Z03->Z03_FILIAL		:= cFilZ03
	Z03->Z03_PREFIX		:= cPreZ03
	Z03->Z03_NUM		:= cNumZ03
	Z03->Z03_TIPO		:= cTpoZ03
	Z03->Z03_FORNEC		:= cCodZ03
	Z03->Z03_LOJA		:= cLojZ03
	Z03->Z03_NOMFOR		:= cNomZ03
	Z03->Z03_EMISSA		:= dEmiZ03
	Z03->Z03_VENCRE		:= dVenZ03
	Z03->Z03_VALOR		:= nValZ03
	Z03->Z03_TIPMAN		:= cTipZ03
	Z03->Z03_OBSERV		:= cObsZ03
	Z03->Z03_SEQ		:= "001"
	Z03->Z03_DTBASE		:= dDataBase
	lContinua := .F.
	Close(oDlgDI)
	Z03->(MsUnLock())
Else
	Close(oDlgDI)
	lContinua := .F.
Endif

Return

Static Function _Sair()

Close(oDlgDI)
lContinua := .F.

Return
