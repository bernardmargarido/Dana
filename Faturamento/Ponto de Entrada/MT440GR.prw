#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#Include 'APWEBSRV.CH'
#Include 'XMLXFUN.CH'
#Include 'TBICONN.CH'
#INCLUDE "TopConn.Ch"
#INCLUDE "Fileio.ch"
#INCLUDE "ap5mail.ch"

User Function MT440GR()

Local cRegEsp	:= ""
Local nTotPed	:= 0
Local cSubject	:= ""
Local cTable	:= ""
Local cMsg		:= ""

Private cCondCli	:= ""
Private cNumPed		:= ""
Private cCondPed	:= ""
Private cContae		:= AllTrim(GetMv("MV_XMAISE4"))//E-mail da equipe financeira.

cRegEsp	:= Posicione("SA1",1,"  " + M->C5_CLIENTE + M->C5_LOJACLI,"A1_REGESP")
cCondCli:= Posicione("SA1",1,"  " + M->C5_CLIENTE + M->C5_LOJACLI,"A1_COND")

M->C5_BLQPREC := "L"
M->C5_LOGLIBE := SUBSTR(cUsuario,7,15)
M->C5_XCONDC  := cCondCli

If !Empty(M->C5_MENNOTA)
	If !M->C5_MENNOTA $Alltrim(cRegEsp)
		M->C5_MENNOTA	:= Alltrim(M->C5_MENNOTA) +" - "+ Alltrim(cRegEsp)
	Endif
Else
	M->C5_MENNOTA	:= Alltrim(cRegEsp)
Endif

M->C5_MENNOTA	:= StrTran(M->C5_MENNOTA,chr(13)," ")
M->C5_MENNOTA	:= StrTran(M->C5_MENNOTA,chr(10)," ")

If Alltrim(cCondCli) <> Alltrim(M->C5_CONDPAG)
	cNumPed		:= M->C5_NUM
	cCondPed	:= M->C5_CONDPAG
	
	/*+---------------------------------+
	| Cabeçalho E-mail				    |
	+---------------------------------+*/
	cTable := '<STYLE>'
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
	cTable += '<TR><TD CLASS=S_A width="100%"><P align=center><B>Condição de Pagamento Diferente do cadastro</B></P></TD></TR>'
	cTable += '</TBODY>'
	cTable += '</TABLE>'
	cTable += "<table border='1' width='100%'>"
	cTable += "<tr>"
	cTable += "<td>Filial						</td>"
	cTable += "<td>Pedido						</td>"
	cTable += "<td>Condição do Pedido			</td>"
	cTable += "<td>Condição do Cadastro			</td>"
	cTable += "</tr>"
	/*+---------------------------------+
	| Itens do E-mail.				    |
	+---------------------------------+*/
	cTable += "<tr>"
	cTable += "<td style='align:left'>" 	+cFilAnt					+"</td>"
	cTable += "<td style='align:left'>" 	+cNumPed					+"</td>"
	cTable += "<td style='align:left'>" 	+cCondPed					+"</td>"
	cTable += "<td style='align:left'>" 	+cCondCli		 			+"</td>"
	cTable += "</tr>"
	cTable += "</table>"

	cMsg := '<html>'   //Monta corpo do e-mail em HTML
	cMsg += '<head>'
	cMsg += '<title></title>'
	cMsg += '</head>'
	cMsg += '<BODY>'
	cMsg +=	cTable
	cMsg +=	'<br/>'
	cMsg += '</BODY>'
	cMsg += '</html>'

	cSubject	:= "Condição Pgto Diferente do cadastro"
	U_XEnvEmail(cSubject,cMsg,cContae)
Endif

Return(.T.)