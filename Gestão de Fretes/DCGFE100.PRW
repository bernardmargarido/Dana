#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#include "rwmake.ch"
#include "ap5mail.ch"
#include "TOTVS.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebendo email automaticamente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function DCGFE100()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da conta POP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conectado ao servidor POP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CONNECT POP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou
POP MESSAGE COUNT nTotMsg


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Total de mensagens ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*If nTotMsg>0
//Msgbox("Existem "+alltrim(str(nTotMsg,5,0))+" novas mensagens...","Atenção...","INFO")
Else
//Msgbox("Não existem novas mensagens...","Atenção...","INFO")
Endif
*/

If lConectou
	//Msgbox("Não foi possível abrir a conta de E-mail!")
	//Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebendo emails ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For w:=1 to nTotMsg
		aFiles:={}
		
		RECEIVE MAIL MESSAGE w FROM cFrom TO cTo CC cCc BCC cBcc SUBJECT cSubject BODY cBody ATTACHMENT aFiles SAVE IN (cPathTmp) DELETE

		For i:=1 to len(aFiles)
			If Right(aFiles[1],4) $ "#.xml#.XML#"
				Private nHdl := FOpen("\xmlnfe\emp15\tmp\log_salva_anexos_hist.txt",0,,.F.)
				cLog := StrTran(aFiles[1],‘ ‘,‘‘,1)+" "+cData+" "+cHora
				Acalog("\xmlnfe\emp15\tmp\log_salva_anexos_hist.txt",cLog)

				xFile := STRTRAN(lower(StrTran(aFiles[1],‘ ‘,‘‘,1)),cPathTmp,cPath)
				
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
	//Msgbox("Acabei! Baixei "+Str(nX)+" anexos! :D","Atenção...","INFO")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desconectando ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lConectou
	DISCONNECT POP SERVER Result lDisConectou
	//If !lDisConectou
	//     Alert ("Erro ao desconectar do Servidor de e-mail - " + cServer)
	//Endif
EndIf

Return
