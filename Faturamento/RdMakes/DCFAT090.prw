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
¦¦¦Programa  ¦ DCFAT090 ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 02/08/2022  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Alerta, nota de entrada e saída que não foram transmitidas.¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ DANA COSMÉTICOS 					                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function DCFAT090()

Local aArea		 := GetArea()
Local dDtServ	:= CTOD("  /  /    ")
Local cQuery	:= ""
Local cMsg		:= ""
Local cAnexo2	:= ""

Private cContae    := ""
Private cTable   := ""
Private lEnvMail := .F.

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" Modulo "FAT"

cContae    := ALLTRIM(GETMV("MV_XEMANFE"))

//+-------------------------------------+
//| Seta job para nao consumir licenças |
//+-------------------------------------+
RpcSetType(3)

//+-----------------------------------------------------------------+
//| Seta job para empresa filial desejada:                          |
//| 1 - Empresa                                                     |
//| 2 - Filial                                                      |
//| 3 - Usuario                                                     |
//| 4 - Senha                                                       |
//| 5 - Módulo (FIN, FAT, EST)                                      |
//| 6 - Ambiente                                                    |
//| 7 - Array com as tabelas que serão abertas {"SA1","SA2","SA3"}  |
//+-----------------------------------------------------------------+
RpcSetEnv("01","01",,,"COM",GetEnvServer(),{"SF1","SF2","SA2","SA1"})

cTable += '<STYLE>'
cTable += 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cTable += 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cTable += 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cTable += 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cTable += '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
cTable += 'FORM {MARGIN: 0px}'
cTable += '.S_A  {FONT-SIZE: 28px; VERTICAL-ALIGN: top; WIDTH: 100%; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #696969; TEXT-ALIGN: center}'
cTable += '.S_B  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF99; TEXT-ALIGN: left}  '
cTable += '.S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #235908; TEXT-ALIGN: left}  '
cTable += '.S_D  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left}  '
cTable += '.S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
cTable += '</STYLE>'
cTable += '<TABLE style="COLOR: rgb(0,0,0)" width="100%" border=1>'
cTable += '<TBODY>'
cTable += '<TR><TD CLASS=S_A width="100%"><P align=center><B>Nota(s) emitida(s) pendente transmissão SEFAZ</B></P></TD></TR>'
cTable += '</TBODY>'
cTable += '</TABLE>'
cTable += "<table border='1' width='100%'>
cTable += "<tr>
cTable += "<td>Nota			 	</td>"
cTable += "<td>Serie		 	</td>"
cTable += "<td>Emissão		 	</td>"
cTable += "<td>Status		 	</td>"
cTable += "<td>Valor		 	</td>"
cTable += "<td>Tipo NF		 	</td>"
cTable += "</tr>"

dDtServ	:= DATE() -2

//Notas de entrada
DbSelectArea("SF1")
DbSetOrder(1)
SF1->(DbGoTop())

If Select("TRBSF1") > 0
	TRBSF1->(DbCloseArea())
Endif

cQuery	:= " SELECT F1_FIMP, F1_FILIAL, F1_DOC, F1_SERIE, F1_EMISSAO, F1_TIPO, F1_VALBRUT, F1_FORNECE, F1_LOJA, F3_NFELETR,F3_CODNFE, F3_CHVNFE, F3_DESCRET, F3_CODRSEF FROM " + RetSqlName("SF1") + " SF1, " + RetSqlName("SF3") + " SF3 (NOLOCK) "
cQuery	+= " WHERE F1_EMISSAO BETWEEN '20220101' AND '"+DTOS(dDtServ)+"' AND SF1.D_E_L_E_T_ = '' AND F1_FORMUL = 'S' AND F1_CHVNFE = '' "
cQuery	+= " AND F1_FILIAL = F3_FILIAL AND F1_DOC = F3_NFISCAL AND F1_SERIE = F3_SERIE AND F1_FORNECE = F3_CLIEFOR AND F1_LOJA = F3_LOJA AND SF3.D_E_L_E_T_='' "
cQuery	+= " GROUP BY F1_FIMP, F1_FILIAL, F1_DOC, F1_SERIE, F1_EMISSAO, F1_TIPO, F1_VALBRUT, F1_FORNECE, F1_LOJA, F3_NFELETR,F3_CODNFE, F3_CHVNFE, F3_DESCRET, F3_CODRSEF "
cQuery	+= " ORDER BY F1_DOC, F1_SERIE "
PLSQUERY(cQuery,"TRBSF1")

If Select("TRBSF1") > 0
	If !Empty(TRBSF1->F1_DOC)
		While !TRBSF1->(Eof())
			lEnvMail:= .T.
			If Alltrim(TRBSF1->F1_TIPO) == "D"
				cNomFor	:= Posicione("SA1",1,xFilial("SA1")+TRBSF1->(F1_FORNECE + F1_LOJA),"A1_NOME")
			Else
				cNomFor	:= Posicione("SA2",1,xFilial("SA2")+TRBSF1->(F1_FORNECE + F1_LOJA),"A2_NOME")
			Endif

			If !Empty(TRBSF1->F3_DESCRET)
				cStatus	:= Alltrim(TRBSF1->F3_DESCRET)
			Elseif Alltrim(TRBSF1->F1_FIMP) == "N"
				cStatus	:= "NF nao autorizada"
			Elseif Empty(TRBSF1->F3_CHVNFE)
				cStatus	:= "Transmissão pendente"
			Else
				cStatus	:= ""
			Endif

			cTable += "<tr>"
			cTable += "<td style='align:left'>" 	+TRBSF1->F1_DOC					+"</td>"
			cTable += "<td style='align:left'>" 	+TRBSF1->F1_SERIE				+"</td>"
			cTable += "<td style='align:left'>" 	+DTOC(TRBSF1->F1_EMISSAO)		+"</td>"
			cTable += "<td style='align:left'>" 	+cStatus						+"</td>"
			cTable += "<td style='align:left'>" 	+Alltrim(TransForm(TRBSF1->F1_VALBRUT,'@E 9999,999,999.99'))+"</td>"
			cTable += "<td style='align:left'>ENTRADA</td>"
			cTable += "</tr>"
		TRBSF1->(DbSkip())	
		EndDo	
	Endif
Endif

If Select("TRBSF1") > 0 
	TRBSF1->(DbCloseArea())
Endif		


//Notas de Saída
DbSelectArea("SF2")
DbSetOrder(1)
SF2->(DbGoTop())

If Select("TRBSF2") > 0
	TRBSF2->(DbCloseArea())
Endif

cQuery	:= " SELECT F2_FIMP, F2_DOC, F2_SERIE, F2_EMISSAO, A1_NOME, F2_TIPO, F2_VALBRUT, F3_NFELETR,F3_CODNFE, F3_CHVNFE, F3_DESCRET, F3_CODRSEF FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SF3") + " SF3," + RetSqlName("SA1") + " SA1 (NOLOCK) "
cQuery	+= " WHERE F2_EMISSAO BETWEEN '20220101' AND '"+DTOS(dDtServ)+"' AND SF2.D_E_L_E_T_ = '' AND F2_CHVNFE = '' AND F2_TIPO = 'N' "
cQuery	+= " AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ = '' "
cQuery	+= " AND F2_FILIAL = F3_FILIAL AND F2_DOC = F3_NFISCAL AND F2_SERIE = F3_SERIE AND F2_CLIENTE = F3_CLIEFOR AND F2_LOJA = F3_LOJA AND SF3.D_E_L_E_T_='' "
cQuery	+= " GROUP BY F2_FIMP, F2_DOC, F2_SERIE, F2_EMISSAO, A1_NOME, F2_TIPO, F2_VALBRUT, F3_NFELETR,F3_CODNFE, F3_CHVNFE, F3_DESCRET, F3_CODRSEF "
cQuery	+= " ORDER BY F2_DOC, F2_SERIE "
PLSQUERY(cQuery,"TRBSF2")

If !Empty(TRBSF2->F3_DESCRET)
	cStatus	:= Alltrim(TRBSF2->F3_DESCRET)
Elseif Alltrim(TRBSF2->F2_FIMP) == "N"
	cStatus	:= "NF nao autorizada"
Elseif Empty(TRBSF2->F3_CHVNFE)
	cStatus	:= "Transmissão pendente"
Else
	cStatus	:= ""
Endif

If Select("TRBSF2") > 0
	If !Empty(TRBSF2->F2_DOC)
		While !TRBSF2->(Eof())
			lEnvMail:= .T.
			cTable += "<tr>"
			cTable += "<td style='align:left'>" 	+TRBSF2->F2_DOC					+"</td>"
			cTable += "<td style='align:left'>" 	+TRBSF2->F2_SERIE				+"</td>"
			cTable += "<td style='align:left'>" 	+DTOC(TRBSF2->F2_EMISSAO)		+"</td>"
			cTable += "<td style='align:left'>" 	+cStatus						+"</td>"
			cTable += "<td style='align:left'>" 	+Alltrim(TransForm(TRBSF2->F2_VALBRUT,'@E 9999,999,999.99'))	+"</td>"
			cTable += "<td style='align:left'>SAÍDA</td>"
			cTable += "</tr>"
		TRBSF2->(DbSkip())	
		EndDo	
	Endif
Endif

//Notas pendente Inutilização
cTable += "</table>"

If Select("TRBSF2") > 0 
	TRBSF2->(DbCloseArea())
Endif		

If !Empty(cTable) .And. lEnvMail
	cSubj	:="Notas emitidas com tranmissão SEFAZ pendente"
	HENVMAIL(cSubj,cMsg,cContae,"","",cAnexo2)
EndIf

RestArea(aArea)
Return .T.

Static Function HENVMAIL(cAssunto,cMensagem,cEmailDest,cEmailCc,cEmailBcc,cAnexo)

Local cMsgLog		:= ""
Local oServer		:= Nil
Local nPort			:= 587
Local xRet			:= 0
Local nPosTmp		:= 0
Local cErro			:= ""
Local lPrintError	:= .F.

Default cEmailDest	:= ""
Default cEmailCc	:= ""
Default cAnexo		:= ""
Default cMensagem	:= ""
Default cAssunto	:= ""
Default cErro		:= ""
Default lPrintError	:= .F.

cMensagem += '<html>'   //Monta corpo do e-mail em HTML
cMensagem += '<head>'
cMensagem += '<title></title>'
cMensagem += '</head>'
cMensagem += '<BODY>'
cMensagem += cTable 
cMensagem += '<br/>'    
cMensagem += '</BODY>'
cMensagem += '</html>'

cServer		:= GetNewPar("MV_RELSERV","")
cAccount	:= GetNewPar("MV_RELACNT","")
cPassword	:= GetNewPar("MV_RELAPSW","")
cFrom  		:= GetNewPar("MV_RELACNT","")
lMailAuth	:= GetNewPar("MV_RELAUTH",.F.)
lUseTls		:= GetNewPar("MV_RELTLS")
lUseSsl		:= GetNewPar("MV_RELSSL")
cAut	    := GetNewPar("MV_RELAUSR")
cEmailDest	:= cContae

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
			nPort := 587
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
				If ( xRet := oServer:SMTPAuth( cAut, cPassword ))  <> 0
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
				oMessage:AttachFile(cAnexo)//Anexo
				
				If (xRet := oMessage:Send( oServer )) <> 0
					cErro := "Erro na tentativa de e-mail para " + Alltrim(cEmailDest) + "/" + Alltrim(cEmailCc) + ". " + oServer:GetErrorString( xRet )
					lRetMail := .F.
				else
					lRetMail := .T.
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

EndIf

Return(.T.)
