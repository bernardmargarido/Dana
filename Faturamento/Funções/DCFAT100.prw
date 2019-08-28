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
¦¦¦Programa  ¦ DCFAT100   ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 05/11/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Envia e-mail .CSV com total por produtos em pedidos em     ¦¦¦
¦¦¦          ¦ carteira e total disponível em estoque.                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ DANA COSMÉTICOS    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function DCFAT100()

Local cQuery	:= ""
Local cQrySB2	:= ""
Local dIniEmi	:= '20180201'
Local aAreaSC6	:= ""

Private aTitSC6		:= {}
Private lRetMail	:= .T.
Private cServer		:= ""
Private cAccount	:= ""
Private cPassword	:= ""
Private cFrom		:= ""
Private lMailAuth	:= ""
Private lUseTls		:= ""
Private lUseSsl		:= ""
Private nDiaSem		:= 0
Private cContDir	:= ""
Private nTotEst		:= 0

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" Modulo "FAT"

cServer		:= GetNewPar("MV_RELSERV","")
cAccount	:= GetNewPar("MV_RELACNT","")
cPassword	:= GetNewPar("MV_RELPSW","")
cFrom		:= GetNewPar("MV_RELFROM",.F.)
lMailAuth	:= GetNewPar("MV_RELAUTH",.F.)
lUseTls		:= GetNewPar("MV_RELTLS")
lUseSsl		:= GetNewPar("MV_RELSSL")
cContDir	:= GetNewPar("MV_XEMPCAR")//Contas de e-mail que devem receber a informação

nDiaSem	:= DOW(Date())

If "1/7" $cValToChar(nDiaSem)
	Return()
Endif

aAreaSC6	:= SC6->(GetArea())

If Select("TRBSC6") > 0
	TRBSC6->(DbCloseArea())
Endif

cQuery	:= " SELECT C6_FILIAL, C6_PRODUTO, C6_DESCRI, SUM(C6_QTDVEN) AS 'TOTPED' FROM "+RetSqlname("SC6")+" SC6 (NOLOCK) "+CRLF
cQuery	+= " WHERE C6_ENTREG  >= '"+dIniEmi+"' "+CRLF
cQuery	+= " AND C6_VEND <> '900' "+CRLF
cQuery	+= " AND C6_BLQ <> 'R' "+CRLF
cQuery	+= " AND C6_NOTA = '' "+CRLF
cQuery	+= " AND C6_FILIAL = '05' "+CRLF
cQuery	+= " AND C6_LOCAL IN('20','30') "+CRLF
cQuery	+= " AND SC6.D_E_L_E_T_ = '' "+CRLF
cQuery	+= " GROUP BY C6_FILIAL, C6_PRODUTO, C6_DESCRI "+CRLF
cQuery	+= " ORDER BY C6_FILIAL, C6_PRODUTO, C6_DESCRI "+CRLF
PLSQUERY(cQuery,"TRBSC6")

If Select("TRBSC6") > 0
	While !TRBSC6->(Eof())
		
		If Select("TRBSB2") > 0
			TRBSB2->(DbCloseArea())
		Endif
		cQrySB2	:= " SELECT B2_COD, SUM(B2_QATU) AS 'TOTEST' FROM "+RetSqlname("SB2")+" SB2 (NOLOCK) "+CRLF
		cQrySB2	+= " WHERE B2_COD = '"+TRBSC6->C6_PRODUTO+"' "+CRLF
		cQrySB2	+= " AND B2_FILIAL = '"+TRBSC6->C6_FILIAL+"' "+CRLF
		cQrySB2	+= " AND B2_LOCAL IN('20','30') "+CRLF
		cQrySB2	+= " AND SB2.D_E_L_E_T_ = '' "+CRLF
		cQrySB2	+= " GROUP BY B2_COD "+CRLF
		cQrySB2	+= " ORDER BY B2_COD "+CRLF
		PLSQUERY(cQrySB2,"TRBSB2")

		If Select("TRBSB2") > 0
			If !Empty(TRBSB2->TOTEST)
				nTotEst	:= TRBSB2->TOTEST
			Else
				nTotEst	:= 0
			Endif
			TRBSB2->(DbCloseArea())
		Endif

		aAdd(aTitSC6,{TRBSC6->C6_PRODUTO,;
		TRBSC6->C6_DESCRI	,;
		TRBSC6->TOTPED		,;
		nTotEst})

		nTotEst	:= 0
		TRBSC6->(DbSkip())
	EndDo
	DCFAT110()
Endif

If Select("TRBSC6")
	TRBSC6->(DbCloseArea())
Endif

RestArea(aAreaSC6)
RESET ENVIRONMENT

If IsBlind()
	RpcClearEnv() //LIMPA O AMBIENTE
EndIf

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
Static Function XSENDEMAI(cAssunto,cMensagem,cEmailDest,cEmailCc,cEmailBcc,cAnexo)

Local cMsgLog		:= ""
Local oServer		:= Nil
Local nPort			:= 25
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
				oMessage:AttachFile(cAnexo)//Anexo
				
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
¦¦¦Programa¦ DCFAT110¦ Envia relação Carteira Pedidos ¦ Data ¦ 05/11/2018 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function DCFAT110()

Local cTable	:= ""
Local cArquivo	:= CriaTrab(,.F.)
//Local cPath		:= AllTrim(GetTempPath())
//Local oExcelApp
Local nHandle
Local cDirDocs	:= MsDocPath()
Local cCrLf		:= Chr(13) + Chr(10)
Local cQuery
Local cAnexo	:= ""

Local cTotPed	:= ""
Local cTotEst	:= ""

//cMsgMail:= "Anexo - Lista de pedidos com produtos em carteira e saldo atual"
nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".CSV",0)
cAnexo	:= cDirDocs+"\"+cArquivo+".CSV"

If nHandle > 0

	fWrite(nHandle, "LISTA PRODUTOS EM CARTEIRA E SALDO ATUAL"+cCrLf)
	fWrite(nHandle, ""+cCrLf)
	fWrite(nHandle, ""+cCrLf)
	fWrite(nHandle, "Produto;Descrição;Total em carteira;Saldo atual"+cCrLf)

	If Len(aTitSC6) > 0
		For Nx := 1 to Len(aTitSC6)
			cTotPed	:= cValToChar(aTitSC6[Nx][03])
			cTotEst	:= cValToChar(aTitSC6[Nx][04])
			
			fWrite(nHandle, aTitSC6[Nx][01]+";"+;
			aTitSC6[Nx][02]+";"+;
			cTotPed+";"+;
			cTotEst+cCrLf)
		Next
	Endif

	cTotPed	:= ""
	cTotEst	:= ""

	fWrite(nHandle, ""+cCrLf)
	fClose(nHandle)
	
EndIf

cTable := '<html>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="3">Pezados(as), </font></span></p>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="4">Anexo, lista de produtos com pedidos em carteira e saldo atual!</font></span></p>'
cTable += '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
cTable += '</html>'

cSubject	:= " *** DANA COSMÉTICOS *** Lista Produtos em carteira"

If !Empty(cContDir)
	XSendEmai(cSubject,cTable,cContDir,"","",cAnexo)
Endif

Ferase(cDirDocs+"\"+cArquivo+".CSV" )

Return(.T.)
