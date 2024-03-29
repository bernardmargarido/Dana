#include "rwmake.ch"

User Function SF2460I()
Local _aArea		:= GetArea()

Local cGerente		:= ""
Local _cFilWMS		:= GetNewPar("DN_FILWMS","05,06")
Local _cFilMSL  	:= GetNewPar("DN_FILMSL","07")
Local dNovaData := ""
Local nMes		:= Month(Date()) + 1 
Local nAno		:= Year(Date())

Private oDlgDI2		:= NIL
Private lCat		:= .T.
Private cFilSF2		:= SF2->F2_FILIAL
Private cDocSF2		:= SF2->F2_DOC
Private cSerSF2		:= SF2->F2_SERIE
Private cForSF2		:= SF2->F2_CLIENTE
Private cLojSF2		:= SF2->F2_LOJA
Private cTipSF2		:= SF2->F2_TIPO
Private cPreSF2		:= SF2->F2_PREFIXO
Private nValBSF2	:= SF2->F2_VALBRUT
Private dEmiSF2		:= SF2->F2_EMISSAO
Private cICMSF2		:= SF2->F2_NFICMST
//Private cFECSF2		:= SF2->F2_NTFECP
Private cFECSF2		:= SF2->F2_GNRFECP
Private cDIFSF2		:= SF2->F2_GNRDIF
Private cCodCat		:= Space(03)
Private lContinua2 	:= .T.
Private cConvUN		:= ""
Private cCanalCli	:= ""
Private cTESTrade	:= ""
Private cTESBonif	:= ""
Private cCFOPVen	:= Alltrim(GetMv("MV_XCFOPVE"))
Private nPerCom		:= 0
Private dDtServ		:= Date()
Private dDtVGNRE	:= Date() + 1

aAreacps	:= GetArea()
aAreaSE1	:= SE1->(GetArea())
_VEND		:= ""

DBSelectArea("SF2")

_XPEDIDO := POSICIONE("SD2",3,xFilial("SD2") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),"D2_PEDIDO")
_VEND    := POSICIONE("SC5",1,xFilial("SC5") + _XPEDIDO,"C5_VEND1")
cConvUN	 := POSICIONE("SC5",1,xFilial("SC5") + _XPEDIDO,"C5_XCONVUN")
cCanalCli:= POSICIONE("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_XTIPCLI")

IF EMPTY(_VEND)
	_VEND := GetAdvFval("SA1","A1_VEND",xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,1)
ENDIF

IF EMPTY(_VEND)
	_VEND := "070"  // VENDAS DIRETO
ENDIF

DbSelectArea("SF2")
Reclock("SF2",.F.)
/*
	If SF2->F2_PLIQUI > 1
		SF2->F2_PLIQUI:= ROUND(SF2->F2_PLIQUI,0)
		SF2->F2_PBRUTO:= ROUND(SF2->F2_PLIQUI*1.05,0)
	Else
		SF2->F2_PBRUTO:= SF2->F2_PLIQUI*1.05
	Endif
*/
	SF2->F2_VEND1	:= _VEND
	SF2->F2_XXCONVU	:= cConvUN

	If cFilAnt $ RTrim(_cFilWMS) + "," + _cFilMSL
		SF2->F2_XDTALT := Date()
		SF2->F2_XHRALT := Time()
		SF2->F2_XENVWMS:= "1"
	EndIf
SF2->( MSUNLOCK() )

//--------------------------------------------------+
// Grava informa��es de volume para filial e Maceio |
//--------------------------------------------------+
/*
If cFilAnt $ _cFilMSL
    U_DNFATM09(SC5->C5_NUM,SF2->F2_DOC,SF2->F2_SERIE)
EndIf
*/

//Grava gerente de vendas
If SF2->F2_TIPO <> 'D' .Or. SF2->F2_TIPO <> 'B'
	DbSelectArea("SE1")
	DbSetOrder(2)
	DbSeek(xFilial("SE1") + cForSF2 + cLojSF2 + cPreSF2 + cDocSF2)
	If Found()
		cGerente	:= Posicione("SA3",1,xFilial("SA3")+_VEND,"A3_GEREN")
		While SE1->(!Eof() .And. xFilial("SE1")+ cForSF2 + cLojSF2 + cPreSF2 + cDocSF2 == SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) )
			RecLock("SE1", .F.)
				SE1->E1_XGERENT		:= cGerente
			SE1->( MsUnlock() )
			SE1->(DbSkip())
		EndDo
	Endif

	If nMes > 12
		nAno ++
		nMes := 1
	EndIf
	
	dNovaData := DataValida(  "01/" + Alltrim(Str(nMes)) + "/" + Alltrim(Str(nAno))  ,.T.)

	//Manuten��o t�tulo GNRE
	If !Empty(cICMSF2)
		DbSelectArea("SE2")
		SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If SE2->(dbSeek(xFilial("SE2") + Alltrim(cICMSF2)))
			RecLock("SE2",.F.)
			//SE2->E2_VENCORI	:= dNovaData	// DataValida(Date(),.T.)
			//SE2->E2_VENCTO 	:= dNovaData	// DataValida(Date(),.T.)
			//SE2->E2_VENCREA := dNovaData	// DataValida(Date(),.T.)
			SE2->E2_NATUREZ	:= "PROV"
			SE2->E2_HIST	:= "Nota:" + Alltrim(cDocSF2) + " - Serie:" + Alltrim(cSerSF2)
			SE2->E2_XCATNFE	:= "GNR"
			SE2->E2_XDTSERV	:= dDtServ
			SE2->E2_VENCREA	:= DataValida(dDtVGNRE,.T.)
			SE2->(MsUnLock())
		Endif
	Endif

	//Manuten��o t�tulo FECP
	If !Empty(cFECSF2)
		DbSelectArea("SE2")
		SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If SE2->(dbSeek(xFilial("SE2") + Alltrim(cFECSF2)))
			RecLock("SE2",.F.)
			//SE2->E2_VENCORI	:= dNovaData	// DataValida(Date(),.T.)
			//SE2->E2_VENCTO 	:= dNovaData	// DataValida(Date(),.T.)
			//SE2->E2_VENCREA := dNovaData	// DataValida(Date(),.T.)
			SE2->E2_NATUREZ	:= "PROV"
			SE2->E2_HIST	:= "Nota:" + Alltrim(cDocSF2) + " - Serie:" + Alltrim(cSerSF2)
			SE2->E2_XCATNFE	:= "GNR"
			SE2->E2_XDTSERV	:= dDtServ
			SE2->E2_VENCREA	:= DataValida(dDtVGNRE,.T.)
			SE2->(MsUnLock())
		Endif
	Endif

	//Manuten��o t�tulo DIFAL
	If !Empty(cDIFSF2)
		DbSelectArea("SE2")
		SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If SE2->(dbSeek(xFilial("SE2") + Alltrim(cDIFSF2)))
			RecLock("SE2",.F.)
			//SE2->E2_VENCORI	:= dNovaData	// DataValida(Date(),.T.)
			//SE2->E2_VENCTO 	:= dNovaData	// DataValida(Date(),.T.)
			//SE2->E2_VENCREA := dNovaData	// DataValida(Date(),.T.)
			SE2->E2_NATUREZ	:= "PROV"
			SE2->E2_HIST	:= "Nota:" + Alltrim(cDocSF2) + " - Serie:" + Alltrim(cSerSF2)
			SE2->E2_XCATNFE	:= "GNR"
			SE2->E2_XDTSERV	:= dDtServ
			SE2->E2_VENCREA	:= DataValida(dDtVGNRE,.T.)
			SE2->(MsUnLock())
		Endif
	Endif

	//Altera��o Vencimento GNRE SF6
	If !Empty(cICMSF2) .Or. !Empty(cFECSF2) .Or. !Empty(cDIFSF2)
		dbSelectArea("SF6")
		SF6->(dbSetOrder(1))//F6_FILIAL+F6_EST+F6_NUMERO
		If SF6->(dbSeek(SF2->F2_FILIAL + SF2->F2_EST + Alltrim(SF2->F2_NFICMST)))
			RecLock("SF6",.F.)
			SF6->F6_DTVENC := DataValida(dDtVGNRE,.T.)
			SF6->(MsUnLock())
		Endif
	Endif

Endif

If cTipSF2 == 'D' .Or. cTipSF2 == 'B'
	While lContinua2
		@ 000,000 TO 150,400 DIALOG oDlgDI2 TITLE "Categoria da Nota Fiscal - Devolu��o"
		@ 015, 005 SAY "Categoria NF"
		@ 015, 060 GET cCodCat F3("SZY") WHEN lCat PICTURE "@!"  SIZE 040,040
		@ 015,130 BUTTON "Confirmar" SIZE 040,012 ACTION _Gravar(cCodCat)
		ACTIVATE DIALOG oDlgDI2 CENTER
	EndDo
	If cTipSF2 == 'D'
		DCAVNFDEV()//Avisa departamento financeiro do lan�amento de Nota de devolu��o
	Endif
Endif

If cTipSF2 == 'N'
	DCEMAGEN()
Endif

//Atualiza Vendedor SD2
DbSelectArea("SD2")
DbSetOrder(3)//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If Dbseek(cFilSF2 + cDocSF2 + cSerSF2 + cForSF2 + cLojSF2)
	While !SD2->(Eof()) .And. cFilSF2 + cDocSF2 + cSerSF2 + cForSF2 + cLojSF2 == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)		
		If !Empty(_VEND)
			RecLock("SD2",.F.)
			SD2->D2_VEND1	:= _VEND 
			SD2->(Msunlock())
		Endif
		
		cCatCom		:= POSICIONE("SB1",1,xFilial("SB1") + SD2->D2_COD,"B1_XCATCOM")
		cTESTrade	:= POSICIONE("SF4",1,xFilial("SF4") + SD2->D2_TES,"F4_XTRADE")
		cTESBonif	:= POSICIONE("SF4",1,xFilial("SF4") + SD2->D2_TES,"F4_XDEVBON")
		nPerCom		:= 0

		If Alltrim(cTESBonif) <> "1" .And. Alltrim(cTESTrade) <> "1" .And. Alltrim(SD2->D2_TIPO) == "N"
			If Alltrim(cCanalCli) == "1"//Atacado
				nPerCom		:= POSICIONE("Z08",1,xFilial("Z08") + _VEND + cCatCom,"Z08_COMATA")	
			Elseif Alltrim(cCanalCli) $"2/3"//Varejo ou Farma
				nPerCom		:= POSICIONE("Z08",1,xFilial("Z08") + _VEND + cCatCom,"Z08_COMVAR")	
			Endif

			If nPerCom > 0
				RecLock("SD2",.F.)
				SD2->D2_XVLCOMI	:= (SD2->D2_TOTAL * nPerCom) / 100
				SD2->(Msunlock())
			Endif

			//Ajusta arredondamento B6_PRUNIT
			DbSelectArea("SB6")
			DbSetOrder(3)//B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3
			If Dbseek(SD2->(D2_FILIAL+D2_IDENTB6+D2_COD))
				Reclock("SB6",.F.)
				SB6->B6_PRUNIT	:= Round(SD2->D2_PRCVEN,2) + 0.01//Arredondamento para n�o dar problema no retorno da NFE
				SB6->(MsUnlock())
			Endif
		Endif		
	SD2->(DbSkip())
	EndDo
Endif

RestArea(aAreaCps)
RestArea(aAreaSE1)
RestArea(_aArea)
RETURN


/*-----------------------------------------\
| Grava hist�rico na nota e no(s) titulo(s)|
\-----------------------------------------*/
Static Function _Gravar(cCodCat)

Local aAreaGRV	:= GetArea()
Local aAreaSZY	:= SZY->(GetArea())

If lCat .And. !Empty(cCodCat)
	DbselectArea("SZY")
	DbSetOrder(1)
	If Dbseek(xFilial("SZY")+cCodCat)
		DbSelectArea("SE2")
		DbSetOrder(6)//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If Dbseek(xFilial("SE2") + cForSF2 + cLojSF2 + cSerSF2 + cDocSF2)
			While !SE2->(Eof()) .And. SE2->(E2_FILORIG+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cFilSF2 + cForSF2 + cLojSF2 + cSerSF2 + cDocSF2
				RecLock("SE2", .F.)
				SE2->E2_XCATNFE	:= cCodcat
				SE2->E2_XDTSERV	:= dDtServ
				SE2->(MsUnLock())
				SE2->(DbSkip())
			EndDo
		Endif
		lContinua2 := .F.
		Close(oDlgDI2)
	Else
		Msginfo("Categoria "+Alltrim(cCodCat)+", n�o cadastrada na tabela!","D A N A  C O S M � T I C O S - SF2460I")
	Endif
Endif

RestArea(aAreaGRV)
RestArea(aAreaSZY)

Return


/*+--------------------------------------------------------------------+
| DCAVNFDEV | Aviso de Retorno da nota de devolu��o(Contas a pagar).   |
+--------------------------------------------------------------------+*/
Static Function DCAVNFDEV

Local cMsgMail	:= ""
Local cTable	:= ""
Local cDtEmi	:= CTOD("  /  /    ")
Local nValNf	:= 0
Local cContae	:= GETMV("MV_XEQPCP")//e-mail equipe contas a pagar.
Local cNomFor	:= Posicione("SA2",1,cFilSF2+cForSF2+cLojSF2,"A2_NOME")
Local cDocOri	:= ""
Local aAreaSD2	:= SD2->(Getarea())

cDtEmi	:= DTOC(dEmiSF2)

DbSelectArea("SD2")
DbSetOrder(3)//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If Dbseek(cFilSF2 + cDocSF2 + cSerSF2 + cForSF2 + cLojSF2)
	While !SD2->(Eof()) .And. cFilSF2 + cDocSF2 + cSerSF2 + cForSF2 + cLojSF2 == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
		If Empty(cDocOri)
			cDocOri	:= Alltrim(SD2->D2_NFORI)
		Else
			If !Alltrim(SD2->D2_NFORI) $cDocOri
				cDocOri += " - " + Alltrim(SD2->D2_NFORI)
			Endif
		Endif
	SD2->(DbSkip())
	EndDo
Endif

cMsgMail := "Nota fiscal de devolu��o: " +cDocSF2+"/"+cSerSF2
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
cTable += "<td>Serie						</td>"
cTable += "<td>N�mero						</td>"
cTable += "<td>Fornecedor					</td>"
cTable += "<td>Loja							</td>"
cTable += "<td>Nome							</td>"
cTable += "<td>Data Emiss�o					</td>"
cTable += "<td>Valor						</td>"
cTable += "<td>NF(s) Original				</td>"
cTable += "<tr>"
cTable += "<td style='align:left'>" 	+cFilSF2			+"</td>"
cTable += "<td style='align:left'>" 	+cSerSF2			+"</td>"
cTable += "<td style='align:left'>" 	+cDocSF2			+"</td>"
cTable += "<td style='align:left'>" 	+cForSF2 			+"</td>"
cTable += "<td style='align:left'>" 	+cLojSF2 			+"</td>"
cTable += "<td style='align:left'>" 	+cNomFor 			+"</td>"
cTable += "<td style='align:left'>" 	+cDtEmi 			+"</td>"
cTable += "<td style='align:left'>" 	+'R$ '+ TransForm(nValBSF2,'@E 9999,999.99')		+"</td>"
cTable += "<td style='align:left'>" 	+cDocOri 			+"</td>"
cTable += "</tr>"
cTable += "</table>"
cTable += '<br/>'    
cTable += '</BODY>'
cTable += '<img border="0" src="http://181.41.175.59:1866/emp01/wfpc/Logo_Dana.jpg"></td>
cTable += '<br><br><br><p align="left"><span lang="pt-br"><font face="Arial" size="1">DANA COSM�TICOS</font></span></p>'
cTable += '</html>'
cTable += '</html>'

cSubject	:= cMsgMail

U_XEnvEmail(cSubject,cTable,cContae)

RestArea(aAreaSD2)

Return()





/*+---------------------------------------------+
| DCEMAGEN  | Aviso de cliente com Agendamento. |
+----------------------------------------------+*/
Static Function DCEMAGEN()

Local cMsgMail	:= ""
Local cTable	:= ""
Local cDtEmi	:= CTOD("  /  /    ")
Local nValNf	:= 0
Local cContae	:= GETMV("MV_XEQPLOG")//e-mail equipe Logistica
Local cAgenda	:= Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_XAGENDA")
Local cNomCli	:= Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME")

cDtEmi	:= DTOC(dEmiSF2)

If Alltrim(cTipSF2) == "N" .And. Alltrim(cAgenda) == "1"
	
	cMsgMail := "Nota fiscal de cliente com Agendamento: " +cDocSF2+"/"+cSerSF2
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
	cTable += "<td>Serie						</td>"
	cTable += "<td>N�mero						</td>"
	cTable += "<td>Cliente						</td>"
	cTable += "<td>Loja							</td>"
	cTable += "<td>Nome							</td>"
	cTable += "<td>Data Emiss�o					</td>"
	cTable += "<td>Valor						</td>"
	cTable += "<tr>"
	cTable += "<td style='align:left'>" 	+cFilSF2			+"</td>"
	cTable += "<td style='align:left'>" 	+cSerSF2			+"</td>"
	cTable += "<td style='align:left'>" 	+cDocSF2			+"</td>"
	cTable += "<td style='align:left'>" 	+cForSF2 			+"</td>"
	cTable += "<td style='align:left'>" 	+cLojSF2 			+"</td>"
	cTable += "<td style='align:left'>" 	+cNomCli 			+"</td>"
	cTable += "<td style='align:left'>" 	+cDtEmi 			+"</td>"
	cTable += "<td style='align:left'>" 	+'R$ '+ TransForm(nValBSF2,'@E 9999,999.99')		+"</td>"
	cTable += "</tr>"
	cTable += "</table>"
	cTable += '<br/>'
	cTable += '</BODY>'
	cTable += '<img border="0" src="http://181.41.175.59:1866/emp01/wfpc/Logo_Dana.jpg"></td>
	cTable += '<br><br><br><p align="left"><span lang="pt-br"><font face="Arial" size="1">DANA COSM�TICOS</font></span></p>'
	cTable += '</html>'
	cTable += '</html>'
	
	cSubject	:= cMsgMail
	
	U_XEnvEmail(cSubject,cTable,cContae)
Endif

Return()
