#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XVLDMOD  ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 18/04/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualiza dados bancários no título.                        ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function XVLDMOD()

Local cTipoPag	:= ""
Local cBanPag	:= ""
Local cAgePag	:= ""
Local cDgAPag	:= ""
Local cConPag	:= ""
Local cDgCPag	:= ""
Local cNomPag	:= "" 
Local cBanFor	:= ""
Local cAgeFor	:= ""
Local cDgAFor	:= ""
Local cConFor	:= ""
Local cDgCFor	:= ""
Local cNomFor	:= ""

If Alltrim(FUNNAME())== "FINA050" .or. Alltrim(FUNNAME())== "FINA750"
	If M->E2_FORMPAG $"01/03/41/43"//Crédito em Conta, DOC e TED
	
		cBanFor		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_BANCO") 
		cAgeFor		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_AGENCIA")
		cDgAFor		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_DVAGE")
		cConFor 	:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_NUMCON")
		cDgCFor		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_DVCTA")
		cNomFor		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_NOME")
		cTipoPag	:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XTIPO")

		If !Empty(cTipoPag)
			cBanPag		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XBANCO")
			cAgePag		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XAGENCI")
			cDgAPag		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XDGAGEN")
			cConPag 	:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XCONTA")
			cDgCPag		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XDGCON")
			cNomPag		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XNOMPAG")
			cTipPag		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XTIPO")
			cCGCCPF		:= Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_XCGCCPF")
			
			If MsgYesNo("Conta de pagamento cadastrada no Fornecedor! Deseja carregar conta de pagamento = SIM, Conta convencional = NAO"+ Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Nome Favorecido: "+ cNompag + Chr(13) + Chr(10) + "Banco: "+ cBanpag + Chr(13) + Chr(10) + "Agência: " + cAgePag + Chr(13) + Chr(10) + "Conta/Digito: " + cConPag +"/"+ cDgCPag  + Chr(13) + Chr(10), "A T E N Ç Ã O")
				M->E2_FORBCO	:= cBanPag
				M->E2_FORAGE	:= cAgePag
				M->E2_FAGEDV	:= cDgAPag
				M->E2_FORCTA	:= cConPag
				M->E2_FCTADV	:= cDgCPag
				M->E2_XNOMPAG	:= cNomPag
				M->E2_XTIPFAV	:= cTipPag
				M->E2_XCGCCPF	:= cCGCCPF
			Else
				M->E2_FORBCO	:= cBanFor
				M->E2_FORAGE	:= cAgeFor
				M->E2_FAGEDV	:= cDgAFor
				M->E2_FORCTA	:= cConFor
				M->E2_FCTADV	:= cDgCFor
				M->E2_FORCTA	:= cConFor
				M->E2_XNOMPAG	:= ""
				M->E2_XTIPFAV	:= ""
				M->E2_XCGCCPF	:= ""
			Endif
		Else
			M->E2_FORBCO	:= cBanFor
			M->E2_FORAGE	:= cAgeFor
			M->E2_FAGEDV	:= cDgAFor
			M->E2_FORCTA	:= cConFor
			M->E2_FCTADV	:= cDgCFor
			M->E2_FORCTA	:= cConFor
			M->E2_XNOMPAG	:= ""
			M->E2_XTIPFAV	:= ""
			M->E2_XCGCCPF	:= ""
		Endif
	Endif
Endif

Return(.T.)
