#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#include "rwmake.ch"
#include "ap5mail.ch"
#include "TOTVS.CH"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Recebendo email automaticamente �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
User Function DCGFE100()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Dados da conta POP �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local cData		:= DtoC(Date())
Local cHora		:= Time()
Local cPathTmp	:= "\xmlnfe\emp15\tmp\"
Local cPath		:= "\xmlnfe\emp15\confirmadas"
Local nTotMsg	:= 0
Local cServer	:= "mail.minhaempresa.com.br"
Local cAccount	:= "email@minhaempresa.com.br"
Local cPassword	:= "senhadoemail"
Local lConectou	:= .f.
Local cBody		:=""
Local cTO		:=""
Local cFrom		:=""
Local cCc		:=""
Local cBcc		:=""
Local cSubject	:=""
Local cCmdEnv	:=""
Local nX		:= 0
Local i			:= 0
Local w			:= 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Conectado ao servidor POP �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
CONNECT POP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou
POP MESSAGE COUNT nTotMsg


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Total de mensagens �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
/*If nTotMsg>0
//Msgbox("Existem "+alltrim(str(nTotMsg,5,0))+" novas mensagens...","Aten豫o...","INFO")
Else
//Msgbox("N�o existem novas mensagens...","Aten豫o...","INFO")
Endif
*/

If lConectou
	//Msgbox("N�o foi poss�vel abrir a conta de E-mail!")
	//Else
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Recebendo emails �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	For w:=1 to nTotMsg
		aFiles:={}
		
		RECEIVE MAIL MESSAGE w FROM cFrom TO cTo CC cCc BCC cBcc SUBJECT cSubject BODY cBody ATTACHMENT aFiles SAVE IN (cPathTmp) DELETE

		For i:=1 to len(aFiles)
			If Right(aFiles[1],4) $ "#.xml#.XML#"
				Private nHdl := FOpen("\xmlnfe\emp15\tmp\log_salva_anexos_hist.txt",0,,.F.)
				cLog := StrTran(aFiles[1],'� �','몣',1)+" "+cData+" "+cHora
				Acalog("\xmlnfe\emp15\tmp\log_salva_anexos_hist.txt",cLog)

				xFile := STRTRAN(lower(StrTran(aFiles[1],'� �','몣',1)),cPathTmp,cPath)
				
				COPY FILE &aFiles[1] TO &xFile
				nX++
				FErase(aFiles[1])
			Else
				Private nHdl := FOpen("\xmlnfe\emp15\tmp\log_exc_anexos_hist.txt",0,,.F.)
				cLog := aFiles[1]+" "+cData+" "+cHora
				Acalog("\xmlnfe\emp15\tmp\log_exc_anexos_hist.txt",cLog)
				FErase(aFiles[1])
			EndIf
		Next
	Next
	//Msgbox("Acabei! Baixei "+Str(nX)+" anexos! :D","Aten豫o...","INFO")
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Desconectando �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If lConectou
	DISCONNECT POP SERVER Result lDisConectou
	//If !lDisConectou
	//     Alert ("Erro ao desconectar do Servidor de e-mail - " + cServer)
	//Endif
EndIf

Return
