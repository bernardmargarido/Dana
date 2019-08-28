#include "TOTVS.CH"
#include "protheus.ch"
#include "apwebsrv.ch"
#include "apwebex.ch"
#include "ap5mail.ch"

User Function XEnvEmail(cAssunto,cMensagem,cEmailDest,cEmailCc,cEmailBcc,aAnexos)

Local lRetorno		:= .T.
Local cServer		:= Nil
Local cAccount		:= Nil
Local cPassword		:= Nil
Local cFrom			:= Nil
Local lMailAuth		:= Nil
Local lUseTls		:= Nil
Local lUseSsl		:= Nil
Local cMsgLog		:= ""
Local oServer		:= Nil
Local nPort			:= 25
Local xRet			:= 0
Local nPosTmp		:= 0
//Local nCont1		:= 1
Local cErro			:= ""
Local lPrintError	:= .F.

Default cEmailDest	:= ""
Default cEmailCc	:= ""
Default aAnexos		:= {}
Default cMensagem	:= ""
Default cAssunto	:= ""
Default cErro		:= ""
Default lPrintError	:= .F.

If IsBlind()
	RpcClearEnv() //LIMPA O AMBIENTE
	RpcSetType(3)
	RpcSetEnv("01","01")
EndIf

cServer		:= GetNewPar("MV_RELSERV","")
cAccount	:= GetNewPar("MV_RELACNT","")
cPassword	:= GetNewPar("MV_RELPSW","")
cFrom		:= GetNewPar("MV_RELFROM",.F.)
lMailAuth	:= GetNewPar("MV_RELAUTH",.F.)
lUseTls		:= GetNewPar("MV_RELTLS")
lUseSsl		:= GetNewPar("MV_RELSSL")
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
				
				/*
				If oMessage:AttachFile( "system\LGMID.png") 
				     Conout( "Erro ao atachar o arquivo" )
				     Return .F.
				Else                     
				     //adiciona uma tag informando que é um attach e o nome do arq
				     oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=\system\LGMID.png')
				EndIf
				*/
				/*
				For nCont1 := 1 To Len(aAnexos)
					oMessage:AttachFile(aAnexos[nCont1])
				Next nCont1
				*/
				
				If (xRet := oMessage:Send( oServer )) <> 0
					cErro := "Erro na tentativa de e-mail para " + Alltrim(cEmailDest) + "/" + Alltrim(cEmailCc) + ". " + oServer:GetErrorString( xRet )
					lRetorno := .F.
				Endif
			Else
				cErro := "Erro na tentativa de autenticação da conta " + cAccount + ". " + oServer:GetErrorString( xRet )
				lRetorno := .F.
			EndIf
			
			If ( xRet := oServer:SMTPDisconnect() ) <> 0
				cErro := "Erro na tentativa de desconexão com o servidor SMTP: " + cServer + " com a conta " + cAccount + ". " + oServer:GetErrorString( xRet )
				lRetorno := .F.
			EndIf
		Else
			cErro := "Erro na tentativa de conexão com o servidor SMTP: " + cServer + " com a conta " + cAccount + ". " + oServer:GetErrorString( xRet )
			lRetorno := .F.
		EndIf
	Else
		cErro := "Erro na tentativa de inicializar o servidor SMTP: " + cServer + " com a conta " + cAccount + ". " + oServer:GetErrorString( xRet )
		lRetorno := .F.
	EndIf
	
Else
	
	If Empty(cEmailDest)
		cErro := "É neessário fornecer o destinátario para o e-mail. "
		lRetorno := .F.		
	EndIf
	
	If Empty(cAssunto)
		cErro := "É neessário fornecer o assunto para o e-mail. "
		lRetorno := .F.
	EndIf
	
	If Empty(cMensagem)
		cErro := "É neessário fornecer o corpo do e-mail. "
		lRetorno := .F.
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

If IsBlind()
	RpcClearEnv() //LIMPA O AMBIENTE
EndIf

Return(lRetorno)
