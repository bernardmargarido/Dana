#Include 'RwMake.ch'
#Include 'Protheus.ch'
#Include 'TopConn.ch'
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

Local lRet 		:= .T.
Local cQuery
Local cAlias 	:= CriaTrab(Nil,.F.)
Local nTotPed	:= 0
Local cFilCST	:= Alltrim(GetNewPar("MV_XFILCST"))
Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")
Local _cFilMSL  := GetNewPar("DN_FILMSL","07")
Local cUFCli	:= ""
Local cNomCli	:= ""
Local cMarca	:= ParamIXB[1]
Local lInverte	:= ParamIXB[2]
Local clQrb 	:= CHR(13) + CHR(10)
Local cPedEco	:= ""

Pergunte("MT461A", .F.)

//-----------------------------------------------+
// Valida se o pedido foi confirmada a separação |
//-----------------------------------------------+
If cFilAnt $ _cFilWMS + "," + _cFilMSL
	If !U_DnFatM01(cMarca,lInverte)
		Return .F.
	EndIf
EndIf

Pergunte("MT461A", .F.)

cQuery := " SELECT C9_QTDLIB, C9_PRCVEN, C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO "
cQuery += " FROM " + RETSQLNAME("SC9")+ " SC9 (NOLOCK) "
cQuery += " WHERE C9_OK"+Iif(lInverte, "<>", "=")+ "'"+cMarca+"' "
cQuery += " AND C9_CLIENTE >= '" + MV_PAR07 + "' AND C9_CLIENTE <= '" + MV_PAR08 + "' "
cQuery += " AND C9_LOJA >= '" + MV_PAR09 + "' AND C9_LOJA <= '" + MV_PAR10 + "' "
cQuery += " AND C9_DATALIB >= '" + DTOS(MV_PAR11) + "' AND C9_DATALIB <= '" + DTOS(MV_PAR12) + "' " 
cQuery += " AND C9_PEDIDO >= '" + MV_PAR05 + "' AND C9_PEDIDO <= '" + MV_PAR06 + "' " 
cQuery += " AND C9_NFISCAL = '' "
cQuery += " AND C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += " AND SC9.D_E_L_E_T_ = '' "

TCQuery cQuery NEW ALIAS (cAlias)
(cAlias)->(dbGoTop())

While !(cAlias)->(Eof())
	nTotPed	+= (cAlias)->C9_QTDLIB * (cAlias)->C9_PRCVEN
	cPedEco	:= Posicione("SC5",1,(cAlias)->C9_FILIAL+(cAlias)->C9_PEDIDO,"C5_XNUMECO")
	
	If cFilCST == (cAlias)->C9_FILIAL
		cUFCli	:= Posicione("SA1",1,xFilial("SA1")+(cAlias)->C9_CLIENTE + (cAlias)->C9_LOJA,"A1_EST")
		cNomCli	:= Posicione("SA1",1,xFilial("SA1")+(cAlias)->C9_CLIENTE + (cAlias)->C9_LOJA,"A1_NOME")
		If !Empty(cUFCli) .And. Alltrim(cUFCli) <> "SP" .And. Empty(cPedEco)
			Msginfo("Não é permitido faturar pedidos, para clientes com UF: "+Alltrim(cUFCli)+", na Filial: "+cFilCST+"! Apenas clientes de SP podem faturar nessa filial. " + clQrb + "Pedido: "+ (cAlias)->C9_PEDIDO + clQrb + "Cliente: "+Alltrim((cAlias)->C9_CLIENTE) + clQrb + "Loja: " +  Alltrim((cAlias)->C9_LOJA) + clQrb + "Nome: " + Alltrim(cNomCli),"M460MARK - D A N A  C O S M É T I C O S")
			lRet	:= .F.
		Endif
	Endif
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

If nTotPed > 0 .And. lRet
	If MsgYesNo("Valor total dos itens marcados R$ "+ TransForm(nTotPed, "@E 99,999,999.99" ) + clQrb + "Finaliza faturamento da nota?","M460MARK - D A N A  C O S M É T I C O S")
		lRet	:= .T.
	Else
		lRet	:= .F.
	Endif
Endif

//Restaurando a pergunta do botão Prep.Doc.
Pergunte("MT460A", .F.)

Return(lRet)
