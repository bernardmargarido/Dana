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
¦¦¦Programa  ¦ PDFIN001  ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 09/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Envia e-mail de cobrança p/ clientes com boletos atrasados.¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function PDFIN001()

Local cQuery	:= ""
Local dIniEmi	:= '20180601'
Local dVencRea	:= ""
Local aAreaSE1	:= ""
Local lPendMail	:= .F.
Local lEnvMail	:= .F.
Local lAtuSE1	:= .F.

Private aTitPen		:= {}
Private aTitEnv		:= {}
Private lRetMail	:= .T.
Private cServer		:= ""
Private cAccount	:= ""
Private cPassword	:= ""
Private cFrom		:= ""
Private lMailAuth	:= ""
Private lUseTls		:= ""
Private lUseSsl		:= ""
Private cContFin	:= ""
Private cContCom	:= ""
Private nDiaSem		:= 0

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" Modulo "FIN"

cServer		:= GetNewPar("MV_RELSERV","")
cAccount	:= GetNewPar("MV_RELACNT","")
cPassword	:= GetNewPar("MV_RELPSW","")
cFrom		:= GetNewPar("MV_RELFROM",.F.)
lMailAuth	:= GetNewPar("MV_RELAUTH",.F.)
lUseTls		:= GetNewPar("MV_RELTLS")
lUseSsl		:= GetNewPar("MV_RELSSL")
cContFin	:= AllTrim(GetMv("MV_XMAISE4"))//E-mail da equipe financeira.
cContCom	:= AllTrim(GetMv("MV_XMAICOM"))//E-mail da equipe Comercial
dVencRea	:= Date() - 2
dVencRea	:= DTOS(dVencRea)
aAreaSE1	:= SE1->(GetArea())

If Select("TEBSE1") > 0
	TRBSE1->(DbCloseArea())
Endif

cQuery	:= " SELECT E1_FILORIG, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_VALOR, A1_XEMAILF, A1_COD, A1_LOJA, SE1.R_E_C_N_O_ AS RECSE1 FROM " + RetSqlname("SE1") +" SE1, "+ RetSqlName("SA1") +" SA1 (NOLOCK) " +CRLF
cQuery	+= " WHERE E1_EMISSAO >= '"+dIniEmi+"' "+CRLF
cQuery	+= " AND E1_VENCREA <= '"+dVencRea+"' "+CRLF
cQuery	+= " AND A1_COD = E1_CLIENTE "+CRLF
cQuery	+= " AND A1_LOJA = E1_LOJA "+CRLF
cQuery	+= " AND E1_BAIXA = '' "+CRLF
cQuery	+= " AND E1_PORTADO <> '' "+CRLF
cQuery	+= " AND E1_NUMBCO <> '' "+CRLF
cQuery	+= " AND E1_XDEVPRE = '' "+CRLF
cQuery	+= " AND E1_XFLAGEM = '' "+CRLF
cQuery	+= " AND SE1.D_E_L_E_T_ = '' "+CRLF
cQuery	+= " AND SA1.D_E_L_E_T_ = '' "+CRLF
PLSQUERY(cQuery,"TRBSE1")

If Select("TRBSE1") > 0
	While !TRBSE1->(Eof())
		If Empty(TRBSE1->A1_XEMAILF)//Clientes sem e-mail financeiro
			aAdd(aTitPen,{TRBSE1->E1_FILORIG,;
			TRBSE1->A1_COD		,;
			TRBSE1->A1_LOJA		,;
			TRBSE1->E1_NOMCLI	,;
			TRBSE1->A1_XEMAILF	})
			lPendMail	:= .T.
			lAtuSE1		:= .T.
		Else
			nDiaSem:=	DOW(TRBSE1->E1_VENCREA)
			If !("1/7" $cValToChar(nDiaSem))//Domingo-1, Segunda-feira-2, Terça-feira-3, Quarta-feira-4, Quinta-feira-5, Sexta-feira-6, Sábado-7
				PDMAILCLI(TRBSE1->A1_XEMAILF, TRBSE1->E1_NUM, TRBSE1->E1_PREFIXO, TRBSE1->E1_PARCELA, TRBSE1->E1_NOMCLI, TRBSE1->E1_EMISSAO, TRBSE1->E1_VENCREA, TRBSE1->E1_VALOR, TRBSE1->E1_FILORIG, TRBSE1->A1_COD, TRBSE1->A1_LOJA, TRBSE1->RECSE1)//Envia E-mail para cleinte
				lEnvMail	:= .T.
			Endif
		Endif
		TRBSE1->(DbSkip())
	EndDo
	TRBSE1->(DbCloseArea())
Else
	TRBSE1->(DbCloseArea())
Endif

If lPendMail
	PDENVEMOK()//Envia relação de clientes que receberam o e-mail(Financeiro).
Endif

If lEnvMail
	PDPENEMOK()//Envia relação de clientes que não receberam o e-mail(Comercial).
Endif

RestArea(aAreaSE1)
RESET ENVIRONMENT

If IsBlind()
	RpcClearEnv() //LIMPA O AMBIENTE
EndIf

Return(.T.)



/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa¦ PDMAILCLI ¦ Monta e-mail para envio.    ¦ Data ¦ 14/08/2018  ¦¦¦

¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function PDMAILCLI(cEmaSA1, cNumSE1, cPreSE1, cParSE1, cNomSE1, dEmiSE1, dVenSE1, nValSE1, cFilSE1, cCodSA1, cLojSA1, cRecSE1)

Local cHtml:= ""

cSubject:= "Pagamento Pendente! ***P E R F U M E S  D A N A***"

cHtml:= '<html>'
cHtml+= '<br><p align="left"><span lang="pt-br"><font face="Arial" size="3">Olá, ' + Alltrim(cNomSE1) + '</font></span></p>'
cHtml+= '<br><p align="left"><span lang="pt-br"><font face="Arial" size="4">Não identificamos o pagamento de seu boleto!</font></span></p>'
cHtml += '<STYLE>'
cHtml += 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
cHtml += 'FORM {MARGIN: 0px}'
cHtml += '.S_A  {FONT-SIZE: 28px; VERTICAL-ALIGN: top; WIDTH: 100%; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: center}'
cHtml += '.S_B  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF99; TEXT-ALIGN: left}  '
cHtml += '.S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left}  '
cHtml += '.S_D  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left}  '
cHtml += '.S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
cHtml += '</STYLE>'
cHtml += '<TABLE style="COLOR: rgb(0,0,0)" width="100%" border=1>'
cHtml += '<TBODY>'
cHtml += '<TR><TD CLASS=S_A width="100%"><P align=center><B>' + Alltrim(cNomSE1) + '</B></P></TD></TR>'
cHtml += '</TBODY>'
cHtml += '</TABLE>'
cHtml += "<table border='1' width='100%'>"
cHtml += "<tr>"
cHtml += "<td>Nota						</td>"
cHtml += "<td>Série						</td>"
cHtml += "<td>Parcela					</td>"
cHtml += "<td>Emissão					</td>"
cHtml += "<td>Vencimento				</td>"
cHtml += "<td>Valor						</td>"
cHtml += "</tr>"
cHtml += "<tr>"
cHtml += "<td style='align:left'>" 	+cNumSE1					+"</td>"
cHtml += "<td style='align:left'>" 	+cPreSE1					+"</td>"
cHtml += "<td style='align:left'>" 	+cParSE1					+"</td>"
cHtml += "<td style='align:left'>" 	+DTOC(dEmiSE1)	 			+"</td>"
cHtml += "<td style='align:left'>" 	+DTOC(dVenSE1)	 			+"</td>"
cHtml += "<td style='align:left'>"  +'R$ '+ TransForm(nValSE1,'@E 9999,999.99')	+"</td>"
cHtml += "</tr>"
cHtml += "</table>"
cHtml+= '<br><p align="left"><span lang="pt-br"><font face="Arial" size="4">Caso já tenha pago, desconsidere essa mensagem.</font></span></p>'
cHtml+= '<td style="text-align: center; width: 15%;" height="53">
cHtml+= '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
cHtml+= '<br><br><br><p align="left"><span lang="pt-br"><font face="Arial" size="1">PERFUMES DANA DO BRASIL</font></span></p>'
cHtml+= '</html>'

XSendEmai(cSubject,cHtml,cEmaSA1)

If lRetMail
	aAdd(aTitEnv,{cFilSE1,;
	cNumSE1	,;
	cPreSE1	,;
	cParSE1	,;
	cCodSA1	,;
	cLojSA1	,;
	cNomSE1	,;
	dEmiSE1	,;
	dVenSE1	,;
	nValSE1	,;
	cRecSE1	})
Else//Erro envio e-mail
	aAdd(aTitPen,{cFilSE1,;
	cCodSA1	,;
	cLojSA1	,;
	cNomSE1	,;
	cEmaSA1	})
Endif

Return(.T.)



/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa¦ XSENDEMAI ¦ Função para envio do e-mail ¦ Data ¦ 14/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function XSENDEMAI(cAssunto,cMensagem,cEmailDest,cEmailCc,cEmailBcc,aAnexos)

Local cMsgLog		:= ""
Local oServer		:= Nil
Local nPort			:= 25
Local xRet			:= 0
Local nPosTmp		:= 0
Local cErro			:= ""
Local lPrintError	:= .F.

Default cEmailDest	:= ""
Default cEmailCc	:= ""
Default aAnexos		:= {}
Default cMensagem	:= ""
Default cAssunto	:= ""
Default cErro		:= ""
Default lPrintError	:= .F.

cEmailDest	:= Alltrim(cEmailDest)
cEmailCc	:= Alltrim(cEmailCc)

If !Empty(cEmailDest) .And. !Empty(cAssunto) .And. !Empty(cMensagem)
	
	cServer := Alltrim(cServer)
	
	If ( nPosTmp := At(":",cServer) ) > 0
		nPort := Val(SubStr(cServer,nPosTmp+1,Len(cServer)))
		cServer := SubStr(cServer,1,nPosTmp-1)
	EndIf
	
	oServer := TMailManager():New()
	
	If lUseSsl
		oServer:SetUseSSL(.T.)
		If nPort == 0
			nPort := 465
		EndIf
	Else
		oServer:SetUseSSL(.F.)
	EndIf
	
	If lUseTls
		oServer:SetUseTLS(.T.)
		If nPort == 0
			nPort := 587
		EndIf
	Else
		oServer:SetUseTLS(.F.)
	EndIf
	
	If  ( xRet := oServer:Init( "", cServer, cAccount, cPassword,,nPort) ) == 0
		If ( xRet := oServer:SMTPConnect()) == 0
			If lMailAuth
				If ( xRet := oServer:SMTPAuth( cAccount, cPassword ))  <> 0
					xRet := oServer:SMTPAuth( SubStr(cAccount,1,At("@",cAccount)-1), cPassword )
				EndIf
			Endif
			
			If xRet == 0
				
				oMessage := TMailMessage():New()
				oMessage:Clear()
				
				oMessage:cDate  := cValToChar( Date() )
				oMessage:cFrom  := cFrom
				oMessage:cTo   := cEmailDest
				oMessage:cCc   := cEmailCc
				oMessage:cSubject := cAssunto
				oMessage:cBody   := cMensagem
				
				If (xRet := oMessage:Send( oServer )) <> 0
					cErro := "Erro na tentativa de e-mail para " + Alltrim(cEmailDest) + "/" + Alltrim(cEmailCc) + ". " + oServer:GetErrorString( xRet )
					lRetMail := .F.
				Endif
			Else
				cErro := "Erro na tentativa de autenticação da conta " + cAccount + ". " + oServer:GetErrorString( xRet )
				lRetMail := .F.
			EndIf
			
			If ( xRet := oServer:SMTPDisconnect() ) <> 0
				cErro := "Erro na tentativa de desconexão com o servidor SMTP: " + cServer + " com a conta " + cAccount + ". " + oServer:GetErrorString( xRet )
				lRetMail := .F.
			EndIf
		Else
			cErro := "Erro na tentativa de conexão com o servidor SMTP: " + cServer + " com a conta " + cAccount + ". " + oServer:GetErrorString( xRet )
			lRetMail := .F.
		EndIf
	Else
		cErro := "Erro na tentativa de inicializar o servidor SMTP: " + cServer + " com a conta " + cAccount + ". " + oServer:GetErrorString( xRet )
		lRetMail := .F.
	EndIf
	
Else
	
	If Empty(cEmailDest)
		cErro := "É neessário fornecer o destinátario para o e-mail. "
		lRetMail := .F.
	EndIf
	
	If Empty(cAssunto)
		cErro := "É neessário fornecer o assunto para o e-mail. "
		lRetMail := .F.
	EndIf
	
	If Empty(cMensagem)
		cErro := "É neessário fornecer o corpo do e-mail. "
		lRetMail := .F.
	EndIf
	
Endif

If !Empty(cErro)
	
	cMsgLog := "Erro na tentativa de enviar e-mail com os seguintes dados: " + Chr(13) + Chr(10) + ;
	"Servidor: " + Alltrim(cServer) + Chr(13) + Chr(10) + ;
	"Porta: " + cValToChar(nPort) + Chr(13) + Chr(10) + ;
	"Conta: " + Alltrim(cAccount) + Chr(13) + Chr(10) + ;
	"Utiliza autenticação: " + Iif(lMailAuth,"Sim","Não") + Chr(13) + Chr(10) + ;
	"Destinatário: " + Alltrim(cEmailDest) + Chr(13) + Chr(10) + ;
	"Cópia: " + Alltrim(cEmailDest) + Chr(13) + Chr(10) + ;
	cErro
	
	If  lPrintError .And. !IsBlind()
		Aviso("MYSNDMAIL.01";
		,cMsgLog;
		,{"Ok"};
		,3)
	EndIf
	
EndIf

Return(lRetMail)



/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa¦ PDENVEMOK ¦ Envia relação para Financeiro¦ Data ¦ 14/08/2018 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function PDENVEMOK()

Local cTable	:= ""
Local nValTit	:= 0

/*+---------------------------------+
| Cabeçalho E-mail				    |
+---------------------------------+*/
cMsgMail	:= "Cliente(s) com boleto(s) pendente pagamento "
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
cTable += "<td>Título						</td>"
cTable += "<td>Prefixo						</td>"
cTable += "<td>Parcela						</td>"
cTable += "<td>Codigo / Loja / Cliente			</td>"
cTable += "<td>Emissão						</td>"
cTable += "<td>Vencimento					</td>"
cTable += "<td>Valor						</td>"
cTable += "</tr>"

If Len(aTitEnv) > 0
	For Nx := 1 to Len(aTitEnv)
		/*+---------------------------------+
		| Itens do E-mail.				    |
		+---------------------------------+*/
		nValTit	:= aTitEnv[Nx][10]
		cTable += "<tr>"
		cTable += "<td style='align:left'>" 	+aTitEnv[Nx][1]				+"</td>"//Filial
		cTable += "<td style='align:left'>" 	+aTitEnv[Nx][2]				+"</td>"//Título
		cTable += "<td style='align:left'>" 	+aTitEnv[Nx][3]				+"</td>"//Prefixo
		cTable += "<td style='align:left'>" 	+aTitEnv[Nx][4]	 			+"</td>"//Parcela
		cTable += "<td style='align:left'>" 	+Alltrim(aTitEnv[Nx][5])+" / "+Alltrim(aTitEnv[Nx][6])+" / "+aTitEnv[Nx][7]						+"</td>"//Cliente
		cTable += "<td style='align:left'>" 	+DTOC(aTitEnv[Nx][8])	+"</td>"//Emissão
		cTable += "<td style='align:left'>" 	+DTOC(aTitEnv[Nx][9])	+"</td>"//Vencimento
		cTable += "<td style='align:left'>" 	+'R$ '+ TransForm(nValTit,'@E 9999,999.99')	+"</td>"//Valor
		cTable += "</tr>"
		
		DbSelectArea("SE1")
		SE1->(DbGoto(aTitEnv[Nx][11]))
		RecLock("SE1",.F.)
		SE1->E1_XFLAGEM	:= "1"//Grava Flag de e-mail enviado.
		SE1->(Msunlock())
		
	Next
Endif

cSubject	:= "Recebimentos Pendentes"
cTable		+= "</table>"
cTable		+= '<br/>'
cTable		+= '</BODY>'
cTable		+= '<td style="text-align: center; width: 15%;" height="53">
cTable		+= '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
cTable		+= '</html>'

XSendEmai(cSubject,cTable,cContFin)

Return(.T.)



/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa¦ PDPENEMOK ¦ Envia relação para Comercial ¦ Data ¦ 14/08/2018 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function PDPENEMOK()

Local cTable	:= ""

/*+---------------------------------+
| Cabeçalho E-mail				    |
+---------------------------------+*/
cMsgMail	:= "Cliente(s) com e-mail financeiro vazio ou incorreto "
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
cTable += "<td>Codigo						</td>"
cTable += "<td>Loja							</td>"
cTable += "<td>Nome							</td>"
cTable += "<td>E-mail Financeiro			</td>"
cTable += "</tr>"

If Len(aTitPen) > 0
	For Nx := 1 to Len(aTitPen)
		/*+---------------------------------+
		| Itens do E-mail.				    |
		+---------------------------------+*/
		cTable += "<tr>"
		cTable += "<td style='align:left'>" 	+aTitPen[Nx][2]				+"</td>"//Código
		cTable += "<td style='align:left'>" 	+aTitPen[Nx][3]				+"</td>"//Loja
		cTable += "<td style='align:left'>" 	+aTitPen[Nx][4]				+"</td>"//Nome
		cTable += "<td style='align:left'>" 	+aTitPen[Nx][5]	 			+"</td>"//E-mail Financeiro
		cTable += "</tr>"
	Next
Endif

cSubject	:= "Cliente(s) com E-mail financeiro não cadastrado ou incorreto"
cTable		+= "</table>"
cTable		+= '<br/>'
cTable		+= '</BODY>'
cTable		+= '<td style="text-align: center; width: 15%;" height="53">
cTable		+= '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
cTable		+= '</html>'

XSendEmai(cSubject,cTable,cContCom)

Return(.T.)
