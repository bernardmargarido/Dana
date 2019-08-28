#Include "RwMake.Ch"
#Include "Protheus.Ch"
#Include "TopConn.Ch"
/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � PDCOM003  � Autor � Clayton Martins   � Data � 08/10/2018  ���
��+----------+------------------------------------------------------------���
���Descri��o � Cadastro de Ocorr�ncias de N�o conformidade.               ���
��+----------+------------------------------------------------------------���
���Uso       � PERFUMES DANA     					                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function PDCOM003()

Local bOK	:= {||U_XOKSZ0(), .T.}
Local bDel	:= {||, .T.}

AxCadastro("SZ0", "Ocorr�ncia de n�o conformidade",bDel,'.T.', , ,bOK, , , , , , , )  

Return


/*----------------------------------------\
| Fun��o executada ao clicar no bot�o OK. |
\----------------------------------------*/
User Function XOKSZ0()

Local cQuery	:= ""
Local dBase90	:= dDataBase - 90
Local dBase180	:= dDataBase - 180
Local cPulaLin	:= Chr(13) + Chr(10)
Local lAvi90	:= .T.

Private xEmFabri	:= GETMV("MV_XEMFABR")//Conta de e-mail dos Fabricantes
//NC �ltimos 6 meses
If Select("TRB180") > 0
	TRB180->(DbCloseArea())
Endif

cQuery	:= " SELECT COUNT(*) AS 'TOTREG' FROM " + RetSqlName("SZ0") + " SZ0 (NOLOCK) "
cQuery	+= " WHERE Z0_FORNECE = '"+M->Z0_FORNECE+"' "
cQuery	+= " AND Z0_LOJA = '"+M->Z0_LOJA+"' "
cQuery	+= " AND Z0_DTOCORR >= '"+DTOS(dBase180)+"' "
cQuery	+= " AND SZ0.D_E_L_E_T_ = '' "
PLSQUERY(cQuery,"TRB180")


//NC �ltimos 3 meses
If Select("TRBSZ0") > 0
	TRBSZ0->(DbCloseArea())
Endif

cQuery	:= " SELECT COUNT(*) AS 'TOTREG' FROM " + RetSqlName("SZ0") + " SZ0 (NOLOCK) "
cQuery	+= " WHERE Z0_FORNECE = '"+M->Z0_FORNECE+"' "
cQuery	+= " AND Z0_LOJA = '"+M->Z0_LOJA+"' "
cQuery	+= " AND Z0_DTOCORR >= '"+DTOS(dBase90)+"' "
cQuery	+= " AND SZ0.D_E_L_E_T_ = '' "
PLSQUERY(cQuery,"TRBSZ0")

If Select("TRB180") > 0
	If TRB180->TOTREG >= 3
		If MsgYesNo("Fornecedor: "+ALLTRIM(M->Z0_NOME)+", com tr�s ou mais n�o conformidades nos �ltimos 6 meses!" + cPulaLin + "Deseja desqualificar o fornecedor?" + cPulaLin + "Caso confirme, o fornecedor ser� bloqueado no Protheus, receber� um aviso sobre o bloqueio e ser� enviado e-mail avisando as fabricantes!" ,"P E R F U M E S  D A N A - PDCOM003")
			PDBLQFOR(M->Z0_FORNECE,M->Z0_LOJA, M->Z0_NOME)//Enviar e-mail e bloqueia fornecedor
			lAvi90	:= .F.
		Endif
		TRB180->(DbCloseArea())	
	Endif
Endif

If Select("TRBSZ0") > 0 .And. lAvi90
	If TRBSZ0->TOTREG > 1
		If MsgYesNo("Fornecedor: "+ALLTRIM(M->Z0_NOME)+", com mais de uma n�o conformidade nos �ltimos 3 meses!" + cPulaLin + "Deseja enviar um alerta sobre poss�vel desqualifica��o de fornecimento?" ,"P E R F U M E S  D A N A - PDCOM003")
			PDALEFOR(M->Z0_FORNECE,M->Z0_LOJA, M->Z0_NOME)//Enviar e-mail de alerta
		Endif
		TRBSZ0->(DbCloseArea())
	Endif
Endif

If Select("TRB180") > 0
	TRBSZ0->(DbCloseArea())
Endif

If Select("TRBSZ0") > 0
	TRBSZ0->(DbCloseArea())
Endif

Return(.T.)


/*/
_______________________________________________________________________________________________
�����������������������������������������������������������������������������������������������
��+-----------------------------------------------------------------------------------------+��
���Programa� PDBLQFOR � Envia e-mail com alertas e bloqueia fornecedor. � Data � 15/10/2018 ���
��+-----------------------------------------------------------------------------------------+��
�����������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������������
/*/
Static Function PDBLQFOR(cCodSA2,cLojFor, cNomFor)

Local cTable	:= ""
Local cEmailSA2	:= Posicione("SA2",1,xFilial("SA2")+cCodSA2+cLojFor,"A2_EMAIL")
Local cCGCSA2	:= Posicione("SA2",1,xFilial("SA2")+cCodSA2+cLojFor,"A2_CGC")

cTable := '<html>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="3">Ol�, ' + Alltrim(cNomFor) + '</font></span></p>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="4">Estamos descredenciando seu fornecimento, devido a um n�mero consider�vel de N�O CONFORMIDADES nos �ltimos seis meses! Qualquer d�vida, entre em contato com (11)2842-3262 Ramal(170) - Departamento de Qualidade. </font></span></p>'
cTable += '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
cTable += '</html>'

cSubject	:= " *** PERFUMES DANA *** Fornecimento n�o Homologado"

If !Empty(cEmailSA2)
	U_XEnvEmail(cSubject,cTable,cEmailSA2)
Endif

cMsgFabri	:= "O fornecedor: "+Alltrim(cNomFor)+", CNPJ: "+cCGCSA2+" ,N�O EST� HOMOLOGADO devido a um n�mero consider�vel de N�O CONFORMIDADES nos �ltimos seis meses! Qualquer d�vida, entre em contato com (11)2842-3262 Ramal(170) - Departamento de Qualidade.

cTable := '<html>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="3">Prezados(as), </font></span></p>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="4">'+cMsgFabri+' </font></span></p>'
cTable += '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
cTable += '</html>'

cSubject	:= " *** PERFUMES DANA *** Fornecedor n�o Homologado"

If !Empty(xEmFabri)
	U_XEnvEmail(cSubject,cTable,xEmFabri)
Endif


/*---------------------\
| Bloqueia Fornecedor. |
\---------------------*/
DbSelectArea("SA2")
DbSetOrder(1)
If Dbseek(xFilial("SA2")+cCodSA2+cLojFor)
	RecLock("SA2",.F.)
	SA2->A2_MSBLQL	:= "1"
	SA2->A2_XHOMOLO	:= "2"
	SA2->(MsUnlock())
Endif

Return(.T.)


/*/
_______________________________________________________________________________________________
�����������������������������������������������������������������������������������������������
��+-----------------------------------------------------------------------------------------+��
���Programa� PDALEFOR � Envia e-mail com alerta para fornecedor.        � Data � 15/10/2018 ���
��+-----------------------------------------------------------------------------------------+��
�����������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������������
/*/
Static Function PDALEFOR(cCodSA2,cLojFor, cNomFor)

Local cTable	:= ""
Local cEmailSA2	:= Posicione("SA2",1,xFilial("SA2")+cCodSA2+cLojFor,"A2_EMAIL")
Local cCGCSA2	:= Posicione("SA2",1,xFilial("SA2")+cCodSA2+cLojFor,"A2_CGC")

cTable := '<html>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="3">Ol�, ' + Alltrim(cNomFor) + '</font></span></p>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="4">Nosso departamento de qualidade, identificou a segunda N�O CONFORMIDADE nos �ltimos tr�s meses. A possibilidade de descredenciamento do fornecimento est� sendo estudada. Qualquer d�vida, entre em contato com (11)2842-3262 Ramal(170) - Departamento de Qualidade. </font></span></p>'
cTable += '<br><p align="left"><span lang="pt-br"><font face="Arial" size="4">*** Esta � uma mensagem autom�tica. Por favor, n�o responda! ***</font></span></p>'
cTable += '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
cTable += '</html>'

cSubject	:= " *** PERFUMES DANA *** Alerta de n�o conformidade"

If !Empty(cEmailSA2)
	U_XEnvEmail(cSubject,cTable,cEmailSA2)
Endif

Return(.T.)