#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpBolet  ºAutor  ³Felipe Moreira      º Data ³ 21/11/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o boleto baseado no banco do pedido                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Maurano & Maurano                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ImpBolet(nEnvBol)
	Local aAreaSE1		:= SE1->(GetArea())
	Local cExecBol		:= ""
	Local cAgencia		:= ""
	Local cConta		:= ""
	Local cBcoExc		:= GetMv("MM_PORTEXC")
	local cBcoSec		:= ""
	local cPortador		:= ""

	Default nEnvBol := 2 // Nao envia email

	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	SA1->( dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA) )

	//  IF SA1->A1_USADDA == "1"            // criado por Marcelo em 23/11/2015 para avisar que não é para imprimir boleto com DDA
	//		MsgAlert("CLIENTE COM DDA, NAO IMPRIMIR BOLETO, GERAR SOMENTE PDF")
	//  ENDIF          // RETIRADO EM 18/02/2016 POR SOLICITAÇÃO DO BENJAMIN

	dbSelectArea("SE1")
	SE1->( dbSetOrder(2) )
	SE1->( dbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC) )

	//->> Marcelo Celi - Symm - 15/05/2015
	If SF2->(FieldPos("F2_XMSGBOL")) > 0 .And. !Empty(Alltrim(SF2->F2_XMSGBOL))
		MsgAlert(Alltrim(SF2->F2_XMSGBOL))	
	EndIf
	//->> Fim

	While SE1->( !Eof() ) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SF2")+SF2->( F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC )
		If AllTrim(SE1->E1_TIPO) == "NF" .And. !(SE1->E1_PORTADO $ cBcoExc)
			dbSelectArea("SZN")
			SZN->( dbGoTop() )

			While !( SZN->( EOF() ) )
				dbSetOrder(1) //FILIAL+BANCO+AGENCIA+CONTA
				If DbSeek(xFilial("SZN") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA)
					If SZN->ZN_EMUSO == "S" // .And. SZN->ZN_BCOSEM == "S" Alterado por Lucas para teste em 04.09.14
						cExecBol	:= Alltrim(SZN->ZN_PROGRAM)
						cAgencia 	:= SZN->ZN_AGENCIA
						cConta 		:= SZN->ZN_CONTA

						//If SZN->ZN_BANCO == '604'
						//	cExecBol += '("'+cAgencia+'", "'+cConta+'", "'+SF2->F2_DOC+'", "'+SF2->F2_SERIE+'",.T.)'
						//If SZN->ZN_BANCO $ '341|033|399|745|604|041|246|104' // Douglas Telles - 18.05.2016 - Tratativa temporaria para novos boletos
							cExecBol += '("'+SF2->F2_DOC+'", "'+SF2->F2_SERIE+'", "'+cValToChar(nEnvBol)+'")'
						//Else
						//	cExecBol += '("'+cAgencia+'", "'+cConta+'", "'+SF2->F2_DOC+'", "'+SF2->F2_SERIE+'")'
						//EndIf

						//Wheber -> 10/08/2015 -- Inibe geração de Boleto para DDA
						//If !U_MMBolDDA(SE1->E1_CLIENTE,SE1->E1_LOJA) SYNN - 30/09/2015 - Marcelo solicitou desabilitar esta linha pois não vai usar no momento.
							//Executa a Impressao do Boleto
							&(cExecBol)
						//EndIf

						Exit
					EndIf
				EndIf
				SZN->( dBSKIP() )
			EndDo
		EndIf

		SE1->(DbSkip())
	EndDo

	SE1->(RestArea(aAreaSE1))
Return()