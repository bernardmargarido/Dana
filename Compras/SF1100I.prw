#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE "ap5mail.ch"

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ SF1100I   ¦ Autor ¦ Clayton Martins   ¦ Data ¦  18/06/2012 ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Inclui Motivo da Devolução.								  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ 							 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function SF1100I()

cNota	:= SF1->F1_DOC
M_LOJA	:= SF1->F1_LOJA
M_FOR	:= SF1->F1_FORNECE
SERIE	:= SF1->F1_SERIE

cDtLan	:= CTOD("  /  /    ")

Private lEnvMail	:= .F.
Private cNumNF		:= Alltrim(SF1->F1_DOC)
Private cSerNF		:= Alltrim(SF1->F1_SERIE)
Private cTable		:= ""
Private cQtdNF		:= ""
Private cMsgMail	:= ""
Private cContae		:= AllTrim(GetMv("MV_XMAINFE"))//E-mail da equipe financeira.
Private cSubject	:= ""

Private lContinua 	:= .F.
Private cMotDev		:= SF1->F1_MOTDEV
Private cCodVen		:= SF1->F1_XCODVEN
Private cCodCli		:= SF1->F1_XCODCLI
Private cLojCli		:= SF1->F1_XLOJCLI
Private cDescMot	:= ""
Private cDescSA3	:= ""
Private cDescSA1	:= ""
Private oDlgDI		:= NIL
Private oDlgDI2		:= NIL
Private AareaSF1	:= SF1->(GetArea())
Private aAreaSE2	:= SE2->(GetArea())
Private lTpNF		:= SF1->F1_TIPO
Private cMsgA1		:= SF1->F1_OBS1
Private	cEspecie	:= SF1->F1_ESPECIE
Private lContinua2 	:= .T.
Private cObs		:= SPACE(500)
Private lObs		:= .T.
Private lCat		:= .T.
Private cFilSF1		:= SF1->F1_FILIAL
Private cDocSF1		:= SF1->F1_DOC
Private cSerSF1		:= SF1->F1_SERIE
Private cForSF1		:= SF1->F1_FORNECE
Private cLojSF1		:= SF1->F1_LOJA
Private cTipSF1		:= SF1->F1_TIPO
Private cCodCat		:= Space(03)
Private dDtServ		:= Date()
Private lAltVenc	:= .F.
Private aTitSE2		:= {}
Private cMsgVen		:= ""

Static oMultiGet1

If Alltrim(lTpNF) == "N" 
	While lContinua2
		@ 000,000 TO 250,700 DIALOG oDlgDI2 TITLE "Histórico Documento de entrada"
		
		@ 015, 005 SAY "Categoria NF"
		@ 015, 060 GET cCodCat F3("SZY") WHEN lCat PICTURE "@!"  SIZE 040,040
		@ 030, 005 SAY "Histórico NFE:"
		@ 030, 060 GET oMultiGet1 VAR cObs WHEN lObs OF oDlgDI2 MULTILINE SIZE 150,30 COLORS 0, 16777215 HSCROLL PIXEL
		@ 015,230 BUTTON "Confirmar" SIZE 040,012 ACTION _Gravar(lObs,cCodCat)
		ACTIVATE DIALOG oDlgDI2 CENTER
	EndDo
Endif


IF lTpNF == "D"
	lContinua := .T.
	While lContinua
		@ 000,000 TO 200,700 DIALOG oDlgDI TITLE "Motivo da Devolução - Nota Fiscal "+AllTrim(SF1->F1_DOC)+" - Série "+AllTrim(SF1->F1_SERIE)
		@ 015, 005 SAY "Motivo Dev."
		@ 015, 060 GET cMotDev F3("SX5","Z6") PICTURE "@!" VALID _VldSX5() SIZE 040,040
		@ 025, 060 GET cDescMot WHEN .F. SIZE 200,040
		@ 055,100 BUTTON "Confirmar" SIZE 040,012 ACTION _GravMot()
		//@ 055,150 BUTTON "Abandonar" SIZE 040,012 ACTION _Sair()
		ACTIVATE DIALOG oDlgDI CENTER
	Enddo
	
	XDEVCOMIS(cNota,SERIE,M_FOR,M_LOJA)
	
ElseIf lTpNF $"N|B" .AND. ALLTRIM(SF1->F1_ESPECIE) == "SPED" .AND. SF1->F1_FORMUL == "S"
	
	lContinua := .T.
	While lContinua
		@ 000,000 TO 200,700 DIALOG oDlgDI TITLE "Observação da Nota Fiscal de Entrada "+AllTrim(SF1->F1_DOC)+" - Série "+AllTrim(SF1->F1_SERIE)
		
		@ 005, 005 SAY "Cod. Vendedor"
		@ 005, 060 GET cCodVen F3("A3DANA") PICTURE "@!" VALID _VldSA3() SIZE 040,040
		@ 015, 060 GET cDescSA3 WHEN .F. SIZE 200,040
		
		@ 030, 005 SAY "Cod. Cliente"
		@ 030, 060 GET cCodCli F3("SA1") PICTURE "@!"  SIZE 040,040
		@ 030, 120 GET cLojCli PICTURE "@!" VALID _VldSA1() SIZE 040,040
		@ 040, 060 GET cDescSA1 WHEN .F. SIZE 200,040
		
		@ 055, 060 SAY "OBSERVAÇÃO"
		@ 065, 060 GET cMsgA1 PICTURE "@!" SIZE 200,10
		@ 085,100 BUTTON "Confirmar" SIZE 040,012 ACTION _GravOBS()
		@ 085,150 BUTTON "Abandonar" SIZE 040,012 ACTION _Sair()
		ACTIVATE DIALOG oDlgDI CENTER
	Enddo
Else
	lContinua := .T.
	While lContinua
		@ 000, 000 TO 200,700 DIALOG oDlgDI TITLE "Observação da Nota Fiscal de Entrada "+AllTrim(SF1->F1_DOC)+" - Série "+AllTrim(SF1->F1_SERIE)
		
		@ 005, 005 SAY "Cod. Vendedor"
		@ 005, 060 GET cCodVen F3("A3DANA") PICTURE "@!" VALID _VldSA3() SIZE 040,040
		@ 015, 060 GET cDescSA3 WHEN .F. SIZE 200,040
		
		@ 030, 005 SAY "Cod. Cliente"
		@ 030, 060 GET cCodCli F3("SA1") PICTURE "@!"  SIZE 040,040
		@ 030, 120 GET cLojCli PICTURE "@!" VALID _VldSA1() SIZE 040,040
		@ 040, 060 GET cDescSA1 WHEN .F. SIZE 200,040
		
		@ 055, 060 SAY "OBSERVAÇÃO"
		@ 065, 060 GET cMsgA1 PICTURE "@!" SIZE 200,10
		@ 085, 100 BUTTON "Confirmar" SIZE 040,012 ACTION _GravOBS()
		@ 085, 150 BUTTON "Abandonar" SIZE 040,012 ACTION _Sair()
		ACTIVATE DIALOG oDlgDI CENTER
		
	Enddo
Endif


If lTpNF <> "D"
	DbSelectArea("SD1")
	DbSetOrder(1)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	If Dbseek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
		/*+---------------------------------+
		| Cabeçalho E-mail				    |
		+---------------------------------+*/
		cMsgMail	:= "Entrada de Nota Fiscal/Serie: " +cNumNF+"/"+cSerNF
		cTable := '<html>'   //Monta corpo do e-mail em HTML
		cTable += '<head>'
		cTable += '<title></title>'
		cTable += '</head>'
		cTable += '<BODY>'
		cTable += '<STYLE>'
		cTable += 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
		cTable += 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
		cTable += 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
		cTable += 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
		cTable += '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
		cTable += 'FORM {MARGIN: 0px}'
		cTable += '.S_A  {FONT-SIZE: 28px; VERTICAL-ALIGN: top; WIDTH: 100%; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: center}'
		cTable += '.S_B  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF99; TEXT-ALIGN: left}  '
		cTable += '.S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left}  '
		cTable += '.S_D  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left}  '
		cTable += '.S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
		cTable += '</STYLE>'
		cTable += '<TABLE style="COLOR: rgb(0,0,0)" width="100%" border=1>'
		cTable += '<TBODY>'
		cTable += '<TR><TD CLASS=S_A width="100%"><P align=center><B>'+cMsgMail+'</B></P></TD></TR>'
		cTable += '</TBODY>'
		cTable += '</TABLE>'
		cTable += "<table border='1' width='100%'>"
		cTable += "<tr>"
		cTable += "<td>Filial						</td>"
		cTable += "<td>Produto						</td>"
		cTable += "<td>Quantidade					</td>"
		cTable += "<td>Local						</td>"
		cTable += "<td>Fornecedor					</td>"
		cTable += "<td>Loja							</td>"
		cTable += "<tr>

		
		While SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
			If ALLTRIM(SD1->D1_TP) $"MR\PA"
				
				/*+---------------------------------+
				| Itens do E-mail.				    |
				+---------------------------------+*/
				cQtdNF	:= cValtoChar(SD1->D1_QUANT)
				cTable += "<tr>"
				cTable += "<td style='align:left'>" 	+SD1->D1_FILIAL				+"</td>"
				cTable += "<td style='align:left'>" 	+SD1->D1_COD				+"</td>"
				cTable += "<td style='align:left'>" 	+cQtdNF						+"</td>"
				cTable += "<td style='align:left'>" 	+SD1->D1_LOCAL	 			+"</td>"
				cTable += "<td style='align:left'>" 	+SD1->D1_FORNECE 			+"</td>"
				cTable += "<td style='align:left'>" 	+SD1->D1_LOJA	 			+"</td>"
				cTable += "</tr>"
				lEnvMail	:= .T.
			Endif
			SD1->(DbSkip())
		EndDo
	Endif
Endif

DbSelectArea("SE2")
DbSetOrder(6)//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
If Dbseek(xFilial("SE2") + M_FOR + M_LOJA + SERIE + cNota)
	While !SE2->(EOF()) .And. SE2->(E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM) == xFilial("SE2") + M_FOR + M_LOJA + SERIE + cNota
		If SE2->E2_VENCREA < dDtServ
			lAltVenc	:= .T.
			aAdd(aTitSE2,{SE2->E2_FILIAL,;
			SE2->E2_PREFIXO	,;
			SE2->E2_NUM		,;
			SE2->E2_PARCELA	,;
			SE2->E2_FORNECE	,;
			SE2->E2_LOJA	,;
			SE2->E2_NOMFOR	,;
			SE2->E2_EMISSAO	,;
			SE2->E2_VENCREA	,;
			dDtServ,;
			SE2->E2_SALDO})
			
			Reclock("SE2",.F.)
			SE2->E2_VENCREA	:= dDtServ
			SE2->E2_XESPECI	:= cEspecie
			SE2->(MsUnlock())
			SE2->(DbSkip())
		Else	
			Reclock("SE2",.F.)
			SE2->E2_XESPECI	:= cEspecie
			SE2->(MsUnlock())
			SE2->(DbSkip())
		Endif
	Enddo
Endif

If lEnvMail//Envia e-mal para equipe de faturamento informando a entrada dos produtos do tipo
	cSubject	:= "Entrada de Nota Fiscal/Série: "+cNumNF+"/"+cSerNF
	cTable		+= "</table>"
	cTable		+= '<br/>'    
	cTable		+= '</BODY>'
	cTable		+= '</html>'
	U_XEnvEmail(cSubject,cTable,cContae)
Endif

If Len(aTitSE2) > 0
	For Nx := 1 to Len(aTitSE2)
		cDtVen	:= aTitSE2[Nx][09]//STOD(aTitSE2[Nx][09])
		If Empty(cMsgVen)
			cMsgVen+= DTOC(cDtVen)
		Else
			cMsgVen+= " - "+DTOC(cDtVen)
		Endif
	Next
Endif

If lAltVenc
	DNALTVENC()
	cDtLan	:= DTOC(Date())
	Msginfo("Título(s) gerado(s) com data de vencimento: "+cMsgVen+", menor que data de lançamento: "+cDtLan+", a data de vencimento desse(s) título(s) foram altaredas para mesma data de lançamento e comunicado via e-mail o departamento financeiro!","P E R F U M E S  D A N A - SF1100I")
Endif

RestArea(aAreaSF1)	// Restaura area original
RestArea(aAreaSE2)

Return .T.

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _GravMot  ¦ Autor ¦ Clayton Martins   ¦ Data ¦  18/06/2012 ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Grava Motivo da Devolução.								  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ 							 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function _GravMot()

Local _AreaSD1 := SD1->(GETAREA())

RecLock("SF1", .F.)
F1_MOTDEV  := Alltrim(cMotDev) + " - " + Alltrim(cDescMot)
SF1->(MsUnLock())

lContinua := .F.
Close(oDlgDI)


If !Empty(cMotDev)
	DbSelectArea("SD1")
	DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	WHILE !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+cNOTA+SERIE+M_FOR+M_LOJA
		RecLock("SD1", .F.)
		D1_MOTDEV  := Alltrim(cMotDev) + " - " + Alltrim(cDescMot)
		SD1->(MsUnLock())
		SD1->(DBSkip())
	EndDo
Endif

RestArea(_AreaSD1)

Return

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _GravOBS  ¦ Autor ¦ Clayton Martins   ¦ Data ¦  18/06/2012 ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Grava Observação Nota Fiscal de Entrada.					  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ 							 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function _GravOBS()

RecLock("SF1", .F.)
SF1->F1_OBS1  	:= Alltrim(cMsgA1)
SF1->F1_XCODVEN	:= cCodVen
SF1->F1_XCODCLI	:= cCodCli
SF1->F1_XLOJCLI	:= cLojCli
SF1->(MsUnLock())

lContinua := .F.
Close(oDlgDI)

Return


/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _Sair     ¦ Autor ¦ Clayton Martins   ¦ Data ¦  18/06/2012 ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Cancela inclusão do Motivo da Devolução.					  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ 							 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function _Sair()

If !Empty(cMotDev)
	Close(oDlgDI)
	lContinua := .F.
Endif

Return

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _VldSx5   ¦ Autor ¦ Clayton Martins   ¦ Data ¦  18/06/2012 ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Valida codigo do Motivo da Devolução.					  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ 							 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function _VldSX5()

Local aArea    := GetArea()
Local lRetorno := .T.

If !Empty(cMotDev)
	dbSelectArea("SX5")
	dbSetOrder(1)
	If !dbSeek(xFilial("SX5")+"Z6")
		Alert("Motivo da Devolução inválido.")
		cDescMot  := Space(80)
		lRetorno := .F.
	Else
		cDescMot := POSICIONE("SX5",1,xFilial("SX5")+"Z6"+cMotDev,"X5_DESCRI")
	Endif
Else
	cDescMot := Space(80)
Endif
RestArea(aArea)

Return(lRetorno)


/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _VldSA3   ¦ Autor ¦ Clayton Martins   ¦ Data ¦  01/03/2018 ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Valida codigo do Vendedor.								  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ 							 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function _VldSA3()

Local aArea    := GetArea()
Local lRetorno := .T.

If !Empty(cCodVen)
	dbSelectArea("SA3")
	dbSetOrder(1)
	If DbSeek(xFilial("SA3")+cCodVen)
		If ALLTRIM(SA3->A3_XDESPE) == "1"
			cDescSA3 :=	Alltrim(SA3->A3_NOME)
		Else
			Msginfo("Código do Vendedor não cadastrado/inválido!","VLDSA3")
			cDescSA3	:= Space(80)
			cCodVen		:= SF1->F1_XCODVEN
			lRetorno := .F.
		EndIf
	Else
		Msginfo("Código do Vendedor não cadastrado/inválido!","VLDSA3")
		cDescSA3  := Space(80)
		cCodVen		:= SF1->F1_XCODVEN
		lRetorno := .F.
	Endif
Else
	cDescSA3 := Space(80)
Endif
RestArea(aArea)

Return(lRetorno)

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _VldSA1   ¦ Autor ¦ Clayton Martins   ¦ Data ¦  01/03/2018 ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Valida codigo do Cliente.								  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ 							 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function _VldSA1()

Local aArea    := GetArea()
Local lRetorno := .T.

If !Empty(cCodCli) .And. !Empty(cLojCli)
	dbSelectArea("SA1")
	dbSetOrder(1)
	If DbSeek(xFilial("SA1")+cCodCli+cLojCli)
		cDescSA1 :=	Alltrim(SA1->A1_NOME)
	Else
		Msginfo("Código do Cliente não cadastrado/inválido!","VLDSA1")
		cDescSA1	:= Space(80)
		cCodCli		:= SF1->F1_XCODCLI
		cLojCli		:= SF1->F1_XLOJCLI
		lRetorno := .F.
	Endif
Else
	cDescSA1 := Space(80)
Endif
RestArea(aArea)

Return(lRetorno)

RestArea(aArea)   // Restaura areas originais
RestArea(aAreaSF1) // Restaura area original

Return lRET



/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ XDEVCOMIS ¦ Autor ¦ Clayton Martins   ¦ Data ¦  10/07/2018 ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Gera Devolução de comissão de Vendas.					  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ 							 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function XDEVCOMIS(cDocSF1, cSerSF1, cCliSF1, cLojSF1)

Local cQuery	:= ""
Local cSeqSE3	:= ""
Local dEmiSE3	:= CTOD("  /  /    ")
Local cItemSD1	:= ""

DbSelectArea("SD1")
DbSetOrder(1)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
If Dbseek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
	If Select("TRBSE3")	> 0
		TRBSE3->(DbCloseArea())
	Endif
	
	cQuery	:= " SELECT MAX(E3_SEQ) AS 'MAXSEQ' FROM " +RetSqlname("SE3") + " AS SE3 (NOLOCK)"
	cQuery	+= " WHERE E3_NUM = '"+SD1->D1_NFORI+"'
	cQuery	+= " AND E3_PREFIXO = '"+SD1->D1_SERIORI+"'
	cQuery	+= " AND E3_CODCLI = '"+SD1->D1_FORNECE+"'
	cQuery	+= " AND E3_LOJA = '"+SD1->D1_LOJA+"'
	cQuery	+= " AND E3_FILIAL = '"+xFilial("SE3")+"'
	cQuery	+= " AND SE3.D_E_L_E_T_ = '' "
	//cQuery	+= " ORDER BY SE3.R_E_C_N_O_ DESC "
	PLSQUERY(cQuery,"TRBSE3")
	
	If Select("TRBSE3")	> 0
		cSeqSE3	:= Soma1(TRBSE3->MAXSEQ)
		TRBSE3->(DbCloseArea())
	Endif
	
	
	If Select("TRBE3")	> 0
		TRBE3->(DbCloseArea())
	Endif
	
	While !SD1->(Eof()) .And. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
		cQuery	:= " SELECT * FROM " +RetSqlname("SE3") + " AS SE3 (NOLOCK)"
		cQuery	+= " WHERE E3_NUM = '"+SD1->D1_NFORI+"'
		cQuery	+= " AND E3_PREFIXO = '"+SD1->D1_SERIORI+"'
		cQuery	+= " AND E3_XITEMNF = '"+SD1->D1_ITEMORI+"'
		cQuery	+= " AND E3_CODCLI = '"+cCliSF1+"'
		cQuery	+= " AND E3_LOJA = '"+cLojSF1+"'
		cQuery	+= " AND E3_COMIS > 0 "
		cQuery	+= " AND E3_FILIAL = '"+xFilial("SE3")+"'
		cQuery	+= " AND SE3.D_E_L_E_T_ = '' "
		PLSQUERY(cQuery,"TRBE3")
		
		If Select("TRBE3")	> 0
			While !TRBE3->(Eof())
				If dDataBase <= TRBE3->E3_EMISSAO
					dEmiSE3	:= dDataBase
				Else
					dEmiSE3	:= TRBE3->E3_EMISSAO
				Endif
				RecLock("SE3",.T.)
				SE3->E3_BASE    :=	TRBE3->E3_BASE
				SE3->E3_COMIS   :=	-TRBE3->E3_COMIS
				SE3->E3_FILIAL  :=	TRBE3->E3_FILIAL
				SE3->E3_VEND    :=	TRBE3->E3_VEND
				SE3->E3_NUM     :=	TRBE3->E3_NUM
				SE3->E3_SERIE   :=	TRBE3->E3_SERIE
				SE3->E3_PORC    :=	TRBE3->E3_PORC
				SE3->E3_CODCLI  :=	TRBE3->E3_CODCLI
				SE3->E3_LOJA    :=	TRBE3->E3_LOJA
				SE3->E3_EMISSAO :=	dDataBase
				SE3->E3_PREFIXO :=	TRBE3->E3_PREFIXO
				SE3->E3_PARCELA :=	TRBE3->E3_PARCELA
				SE3->E3_TIPO    :=	TRBE3->E3_TIPO
				SE3->E3_ORIGEM  :=	TRBE3->E3_ORIGEM
				SE3->E3_VENCTO  :=	TRBE3->E3_VENCTO
				SE3->E3_BAIEMI  :=	TRBE3->E3_BAIEMI
				SE3->E3_MOEDA	:=	TRBE3->E3_MOEDA
				SE3->E3_PEDIDO	:=	TRBE3->E3_PEDIDO
				SE3->E3_SEQ		:=	cSeqSE3
				SE3->E3_XCODPRO	:=	TRBE3->E3_XCODPRO
				SE3->E3_XCATEGO	:=	TRBE3->E3_XCATEGO
				SE3->(MsUnlock())
				cSeqSE3			:= Soma1(cSeqSE3)
				TRBE3->(DbSkip())
			EndDo
		Endif
		If Select("TRBE3") > 0
			TRBE3->(DbCloseArea())
		Endif
		
		
		If Empty(cItemSD1)
			cItemSD1	:= "01"
		Else
			cItemSD1	:= Soma1(cItemSD1)
		Endif
		SD1->(DbSkip())
	EndDo
	
	cQuery	:= " SELECT * FROM " +RetSqlname("SE3") + " AS SE3 (NOLOCK)"
	cQuery	+= " WHERE E3_NUM = '"+cDocSF1+"'
	cQuery	+= " AND E3_PREFIXO = '"+cSerSF1+"'
	cQuery	+= " AND E3_CODCLI = '"+cCliSF1+"'
	cQuery	+= " AND E3_LOJA = '"+cLojSF1+"'
	cQuery	+= " AND E3_FILIAL = '"+xFilial("SE3")+"'
	PLSQUERY(cQuery,"TRBE3")
	
	If Select("TRBE3")	> 0
		DbSelectArea("TRBE3")
		TRBE3->(DbGotop())
		If TRBE3->E3_COMIS	> 0
			While !TRBE3->(Eof()) .And. cItemSE3 <= cItemSD1
				RecLock("SE3",.T.)
				SE3->E3_BASE    :=	TRBE3->E3_BASE
				SE3->E3_COMIS   :=	-TRBE3->E3_COMIS
				SE3->E3_FILIAL  :=	TRBE3->E3_FILIAL
				SE3->E3_VEND    :=	TRBE3->E3_VEND
				SE3->E3_NUM     :=	TRBE3->E3_NUM
				SE3->E3_SERIE   :=	TRBE3->E3_SERIE
				SE3->E3_PORC    :=	TRBE3->E3_PORC
				SE3->E3_CODCLI  :=	TRBE3->E3_CODCLI
				SE3->E3_LOJA    :=	TRBE3->E3_LOJA
				SE3->E3_EMISSAO :=	dDataBase
				SE3->E3_PREFIXO :=	TRBE3->E3_PREFIXO
				SE3->E3_PARCELA :=	TRBE3->E3_PARCELA
				SE3->E3_TIPO    :=	TRBE3->E3_TIPO
				SE3->E3_ORIGEM  :=	TRBE3->E3_ORIGEM
				SE3->E3_VENCTO  :=	TRBE3->E3_VENCTO
				SE3->E3_BAIEMI  :=	TRBE3->E3_BAIEMI
				SE3->E3_MOEDA	:=	TRBE3->E3_MOEDA
				SE3->E3_PEDIDO	:=	TRBE3->E3_PEDIDO
				SE3->E3_SEQ		:=	cSeqSE3
				SE3->E3_XCODPRO	:=	TRBE3->E3_XCODPRO
				SE3->E3_XCATEGO	:=	TRBE3->E3_XCATEGO
				SE3->(MsUnlock())
				
				cItemSE3	:= Soma1(cItemSE3)
				cSeqSE3		:= Soma1(cSeqSE3)
				TRBE3->(DbSkip())
			EndDo
		Else
			TRBE3->(DbSkip())
		Endif
		TRBE3->(DbCloseArea())
	Endif
Endif

Return()


/*-----------------------------------------\
| Grava histórico na nota e no(s) titulo(s)|
\-----------------------------------------*/
Static Function _Gravar(lObs,cCodCat)

Local aAreaGRV	:= GetArea()
Local aAreaSZY	:= SZY->(GetArea())

If lObs .And. !Empty(cObs) .And. lCat .And. !Empty(cCodCat)
	DbselectArea("SZY")
	DbSetOrder(1)
	If Dbseek(xFilial("SZY")+cCodCat)
		
		RecLock("SF1", .F.)
		SF1->F1_XHISTNF		:= cObs
		SF1->F1_XCATNFE		:= cCodCat
		SF1->(MsUnLock())
		
		DbSelectArea("SE2")
		DbSetOrder(6)//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If Dbseek(xFilial("SE2") + cForSF1 + cLojSF1 + cSerSF1 + cDocSF1)
			While !SE2->(Eof()) .And. SE2->(E2_FILORIG+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cFilSF1 + cForSF1 + cLojSF1 + cSerSF1 + cDocSF1
				RecLock("SE2", .F.)
				SE2->E2_XHISTNF	:= cObs
				SE2->E2_XCATNFE	:= cCodcat
				SE2->(MsUnLock())
				SE2->(DbSkip())
			EndDo
		Endif
		lContinua2 := .F.
		Close(oDlgDI2)
	Else
		Msginfo("Categoria "+Alltrim(cCodCat)+", não cadastrada na tabela!","P E R F U M E S  D A N A - SF1100I")
	Endif
Endif

RestArea(aAreaGRV)
RestArea(aAreaSZY)

Return




/*+--------------------------------------------------------------------+
| DNALTVENC | Envia e-mail alertando manutenção na Data de vencimento. |
+--------------------------------------------------------------------+*/
Static Function DNALTVENC

Local cMsgMail	:= ""
Local cTable	:= ""
Local cDtEmi	:= CTOD("  /  /    ")
Local cDtVen	:= CTOD("  /  /    ")
Local cDtLan	:= CTOD("  /  /    ")
Local nValTit	:= 0
Local cContae	:= GETMV("MV_XEQPCP")//e-mail equipe contas a pagar.
Local lEnvMail	:= .F.

cMsgMail	:= "Manutenção vencimento título: " +cNumNF+"/"+cSerNF
cTable := '<html>'   //Monta corpo do e-mail em HTML
cTable += '<head>'
cTable += '<title></title>'
cTable += '</head>'
cTable += '<BODY>'
cTable += '<STYLE>'
cTable += 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cTable += 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cTable += 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cTable += 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cTable += '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
cTable += 'FORM {MARGIN: 0px}'
cTable += '.S_A  {FONT-SIZE: 28px; VERTICAL-ALIGN: top; WIDTH: 100%; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: center}'
cTable += '.S_B  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF99; TEXT-ALIGN: left}  '
cTable += '.S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left}  '
cTable += '.S_D  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left}  '
cTable += '.S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
cTable += '</STYLE>'
cTable += '<TABLE style="COLOR: rgb(0,0,0)" width="100%" border=1>'
cTable += '<TBODY>'
cTable += '<TR><TD CLASS=S_A width="100%"><P align=center><B>'+cMsgMail+'</B></P></TD></TR>'
cTable += '</TBODY>'
cTable += '</TABLE>'
cTable += "<table border='1' width='100%'>"
cTable += "<tr>"
cTable += "<td>Filial						</td>"
cTable += "<td>Prefixo						</td>"
cTable += "<td>Número						</td>"
cTable += "<td>Parcela						</td>"
cTable += "<td>Fornecedor					</td>"
cTable += "<td>Loja							</td>"
cTable += "<td>Nome							</td>"
cTable += "<td>Data Emissão					</td>"
cTable += "<td>Data Vencimento				</td>"
cTable += "<td>Data Lançamento				</td>"
cTable += "<td>Data Valor					</td>"
cTable += "<tr>

If Len(aTitSE2) > 0
	For Nx := 1 to Len(aTitSE2)
		nValTit	:= aTitSE2[Nx][11]
		cDtEmi	:= DTOC(aTitSE2[Nx][08])
		cDtVen	:= DTOC(aTitSE2[Nx][09])
		cDtLan	:= DTOC(aTitSE2[Nx][10])

		/*+---------------------------------+
		| Itens do E-mail.				    |
		+---------------------------------+*/
		cTable += "<tr>"
		cTable += "<td style='align:left'>" 	+aTitSE2[Nx][01]			+"</td>"
		cTable += "<td style='align:left'>" 	+aTitSE2[Nx][02]			+"</td>"
		cTable += "<td style='align:left'>" 	+aTitSE2[Nx][03]			+"</td>"
		cTable += "<td style='align:left'>" 	+aTitSE2[Nx][04] 			+"</td>"
		cTable += "<td style='align:left'>" 	+aTitSE2[Nx][05] 			+"</td>"
		cTable += "<td style='align:left'>" 	+aTitSE2[Nx][06] 			+"</td>"
		cTable += "<td style='align:left'>" 	+aTitSE2[Nx][07] 			+"</td>"
		cTable += "<td style='align:left'>" 	+cDtEmi			 			+"</td>"
		cTable += "<td style='align:left'>" 	+cDtVen			 			+"</td>"
		cTable += "<td style='align:left'>" 	+cDtLan			 			+"</td>"
		cTable += "<td style='align:left'>" 	+'R$ '+ TransForm(nValTit,'@E 9999,999.99')		+"</td>"
		cTable += "</tr>"
		lEnvMail	:= .T.
	Next
Endif


If lEnvMail//Envia e-mal para equipe financeira
	cSubject	:= "Manutenção Vencimento título: "+cNumNF+"/"+cSerNF
	cTable		+= "</table>"
	cTable		+= '<br/>'    
	cTable		+= '</BODY>'
	cTable		+= '</html>'
	U_XEnvEmail(cSubject,cTable,cContae)
Endif

Return()
