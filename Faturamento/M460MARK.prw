#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M460MARK ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 04/04/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de entrada para verificação se o pedido pode ser     ¦¦¦
¦¦¦          ¦ Faturado.        										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function M460MARK()

Local lRet 		:= .F.
Local cQuery
Local cAlias 	:= CriaTrab(Nil,.F.)
Local nTotPed	:= 0

cQuery := "SELECT C9_QTDLIB, C9_PRCVEN "
cQuery += "FROM " + RETSQLNAME("SC9")+ " "
cQuery += "WHERE "
cQuery += " C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += " AND D_E_L_E_T_ = '' "
cQuery += " AND C9_NFISCAL = '' "
cQuery += " AND C9_OK = '"+ThisMark()+"' "

TCQuery cQuery NEW ALIAS (cAlias)
(cAlias)->(dbGoTop())

While !(cAlias)->(Eof())
	nTotPed	+= (cAlias)->C9_QTDLIB * (cAlias)->C9_PRCVEN
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

If MsgYesNo("Valor total dos itens marcados R$ "+cValToChar(nTotPed) + ", Finaliza faturamento da nota?", "A T E N Ç Ã O")
	lRet	:= .T.
Endif

Return(lRet)
