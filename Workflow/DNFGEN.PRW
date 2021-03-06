#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � WF_SCDN   �Autor � Clayton Martins    � Data � 28/06/2018  ���
��+----------+------------------------------------------------------------���
���Descri��o � Funcoes Genericas para Workflow.                           ���
��+----------+------------------------------------------------------------���
���Uso       � Perfumes Dana						                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function Console(cTexto)

Local cEOL		:= Chr(13)+Chr(10)
Local nHdl2
Local aLogBody  := {}
Local nW		:= 0

Set Date To British

If cTexto == NIL
	cTexto := "["+DtoC(Date()) + ' ' + Time()+"] ** Texto n�o recebido **"
Else
	cTexto := "["+DtoC(Date()) + ' ' + Time()+"] " + cTexto
Endif

ConOut(cTexto)

aLogBody := QuebrLin(cTexto,160)

nHdl2 := FOpen("\workflow\emp"+cEmpAnt+"\wfconsole.log",2)
Iif(nHdl2 > 0,,nHdl2:= MSFCreate("\workflow\emp"+cEmpAnt+"\wfconsole.log",0))
FSeek(nHdl2,0,2)

For nW := 1 to Len(aLogBody)
	If nW = 1
		FWrite(nHdl2,aLogBody[nW]+cEOL,Len(aLogBody[nW]+cEOL))
	Else
		FWrite(nHdl2,Space(20)+aLogBody[nW]+cEOL,Len(Space(20)+aLogBody[nW]+cEOL))
	EndIf
Next nW
FClose(nHdl2)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QuebrLin � Autor �                    � Data �  07/07/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Quebra um string em uma ou varias linhas de acordo com o   ���
���          � tamanho da linha especificado, e retorna um array com as   ���
���          � linhas.                                                    ���
���          � Parametros recebidos:                                      ���
���          �   cTexto  ==> String contendo o texto ou mensagem          ���
���          �   nTamLin ==> Tamanho maximo de cada linha                 ���
���          � Parametros devolvidos:                                     ���
���          �   aLinha  ==> Array com as linhas contendo o texto.        ���
�������������������������������������������������������������������������͹��
���Uso       � TOTVS Business Inteligence Library                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function QuebrLin(cTexto,nTamLin)

Local aLinha	:= {}
Local nPosIni	:= 1
Local nCaracLin	:= 0
Local aCaracQbra:= {" ",".",",","-",")",":","/"}
Local nCaracQbra:= 0
Local nN		:= 0

cTexto	:= AllTrim(cTexto)

Do While Len(cTexto) - nPosIni >= 0

	If Len(cTexto) - (nPosIni - 1) <= nTamLin	// Processa ultima linha
		nCaracLin	:= nTamLin
	Else
		nCaracLin := 0
		For nN := 1 to Len(aCaracQbra)
			nCaracQbra	:= RAt(aCaracQbra[nN],Substr(cTexto,nPosIni,nTamLin))	// Encontra o ultimo caracter de quebra
			If nCaracLin < nCaracQbra
				nCaracLin := nCaracQbra
			EndIf		
		Next nN
	EndIf
	
	aAdd(aLinha, Substr(cTexto,nPosIni,nCaracLin))			// Adiciona o trecho ao Array
	
	nPosIni += nCaracLin

EndDo

Return(aLinha)
                           
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NotifyAdm �Autor  �Microsiga           � Data �  08/15/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Utilizado para enviar qualquer notificacao ao administrador ���
���          �do Siga.     															  ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION NotifyAdm(cTitle, aMsg, aFiles )
RETURN U_MailNotify( , cTitle, aMsg, aFiles )

USER FUNCTION MailNotify(cTo, cTitle, aMsg, aFiles )
Local cBody := '', nInd

cTitle		:= ALLTRIM(cTitle) + " Emp/Fil : " + cEmpAnt + "/" + cFilAnt

cBody := ''
cBody += '<DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>'
cBody += '<DIV><SPAN class=610203920-12022004><FONT face=Verdana color=#ff0000 '
cBody += 'size=3><STRONG>Workflow - Servi�o de Envio de Mensagens</STRONG></FONT></SPAN></DIV><hr>'
For nInd := 1 TO Len(aMsg)
 cBody += '<DIV><FONT face=Verdana color=#000080 size=2><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
Next

IF EMPTY(cTo)
	cTo	:= Nil                            
ENDIF

RETURN WFNotifyAdmin( cTo , cTitle, cBody, aFiles )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetTimeOut                                                  ���
�������������������������������������������������������������������������͹��
*/
User function GetTimeOut(nTimeOut,dData, cHora)
Local cQuery := ""
                  
IF dData == Nil
	dData	:= MSDATE()
ENDIF
IF cHora == Nil
	cHora	:= TIME()
ENDIF
IF nTimeOut == Nil
	nTimeOut:= 24
ENDIF

cHoraI 	:= GetNewPar("MV_WFHORAI","00:00")
cHoraF  := GetNewPar("MV_WFHORAF","24:00")

nHora	:= Val(Left(cHora,2))  + Val(Substr(cHora,4,2))/60
nHoraI  := Val(Left(cHoraI,2)) + Val(Substr(cHoraI,4,2))/60
nHoraF  := Val(Left(cHoraF,2)) + Val(Substr(cHoraF,4,2))/60

IF nHora<=nHoraI  
	nHora	:= nHoraI 
ENDIF                
  
dDtVld := dData
While .T.
	IF (nHora + nTimeOut) <= nHoraF
		nHora	:= nHora + nTimeOut
		EXIT
	ENDIF
	nTimeOut	:= nTimeOut - (nHoraF - nHora)
	nHora		:= nHoraI

	dDtVld		:= dDtVld + 1     
	dDtVld		:= DataValida(dDtVld,.T.)
END

Return {dData,cHora,dDtVld, ALLTRIM(STRZERO(int(nHora),2)) + ":" + ALLTRIM(STRZERO((nHora - Int(nHora)) * 60,2))}

USER FUNCTION SEMAFORO(Params)

Local nHdl 	:= 0                  
Local cFile := ""

    IF Params == Nil .OR. ! ValType(Params) $ "N|C" 
    	U_CONSOLE("SEMAFORO - Parametro invalido")
    	RETURN
    ENDIF            

	IF VALTYPE(Params) == "C"	// Quando for caracter - fecha o semaforo
		cFile := TRIM(Params) + ".LCK"
		       
		IF !FILE(cFile)
			nHdl:=MSFCREATE(cFile,0)
			fClose(nHdl)
		ENDIF
			
		While .T.
			nHdl := FOPEN(cFile , 16)
			IF nHdl > 0
			   	EXIT
			ENDIF			    
		    
			SLEEP(5000)
		END
	ENDIF
	
	IF VALTYPE(Params) == "N"	// Quando for numerico - abre o semaforo
		fClose(Params)
	ENDIF
	
RETURN IIF(nHdl <> 0, nHdl, Nil)

//------------------------------------------------------------------------
// ENVIO DE EMAIL
//------------------------------------------------------------------------

User Function Send
	U_XSENDMAIL({'01'})
Return

User Function XSENDMAIL(aParam)
	If aParam == Nil .OR. VALTYPE(aParam) == "U"
		U_CONSOLE("Parametros nao recebidos => XSENDMAIL(cEmp)" )
		RETURN
	EndIf
	
	U_CONSOLE('XSENDMAIL() /' + aParam[1] )
	
	WFSENDMAIL({aParam[1],"0101"})
Return