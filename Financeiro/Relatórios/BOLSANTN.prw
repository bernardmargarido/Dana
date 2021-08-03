#Include "Protheus.Ch"
#Include "TopConn.Ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "totvs.ch"

#DEFINE TAM_A4 9 // A4 - 210mm x 297mm - 620 x 876

/*/{Protheus.doc} BOLSANTN
Função para o processo de geração de boletos do Banco Santander.
@author Douglas Telles
@since 30/05/2016
@version 1.0
@param cDocx, caracter, Número do título para gerar o boleto junto com o DANFE.
@param cSeriex, caracter, Número da série para gerar o boleto junto com o DANFE.
@param cEnvBol, caracter, Indica se o boleto será enviado por e-mail. (1 = Sim, 2 = Não).
/*/
User Function BOLSANTN(cDocx,cSeriex,cEnvBol)
	Local cPerg	:= ''
	Local aRegs	:= {}
	Local aTemp	:= {}
	
	Default cDocx   := ' '
	Default cSerieX := ' '

	Private cNumBoleto		:= ""
	Private cComplemen		:= ""
	Private cNumBol			:= ""
	Private cNossoNum		:= ""
	Private cDVNossoNum		:= ""
	Private cJuros			:= ""
	Private cMensBol1		:= "Após vencimento cobrar "
	Private cMensBol2		:= ""
	Private cMensBol3		:= "Protestar após 3 dias corridos do vencimento."
	Private cMensBol4		:= ""
	Private lAuto			:= .F.
	Private lReimp			:= .F.
	Private aInfMail		:= {}
	Private lPreview		:= .F.

	Default cDocx   		:= ""
	Default cSerieX 		:= ""
	Default cEnvBol			:= "1"

	//+-------------------------------------------+
	//|Funcao que cria as perguntas no arquivo SX1|
	//+-------------------------------------------+
	cPerg := U_BolSx1()

	//+----------------------------------------------------------------------+
	//|Verifica se o programa foi chamado atraves do menu ou por outra funcao|
	//+----------------------------------------------------------------------+
	If Empty(cDocx) .And. Empty(cSeriex) //Trim(FunName()) == 'BOLSANTN'
		If !(Pergunte(cPerg,.T.))
			Return()
		EndIf
	Else
		MV_PAR01	:= SE1->E1_NUM
		MV_PAR02	:= SE1->E1_NUM
		MV_PAR03	:= SE1->E1_PREFIXO
		MV_PAR04	:= SE1->E1_PORTADO
		MV_PAR05	:= SE1->E1_AGEDEP 
		MV_PAR06	:= SE1->E1_CONTA
		lAuto		:= .T.
	EndIf

	If MV_PAR04 <> '033'
		ALERT("Atenção !!! O código informado não pertence a este banco, o código correto é 033!")
		Return()
	EndIf

	If lAuto
		aTemp := {{'G',MV_PAR043MV_PAR01,SE1->E1_PARCELA}}
	Else
		aTemp := U_MMSelNfBol(MV_PAR03,MV_PAR01,MV_PAR02,MV_PAR04)
	EndIf

	If Empty(aTemp)
		Return()
	EndIf
	aRegs := SYCRIAQRY(aTemp)
	Processa( {|lEnd| SYVALIDIMP(aRegs) }, "Aguarde...","Gerando Boletos...",.T.)
Return()

/*/{Protheus.doc} SYCRIAQRY
Consulta as informacoes do titulo para preparar o boleto.
@author Douglas Telles
@since 30/05/2016
@version 1.0
@param aTemp, array, Array com os dados a serem consultados.
@return aRet, Dados a serem utilizados na preparação do boleto.
/*/
Static Function SYCRIAQRY(aTemp)
	Local cQry	:= ""
	Local nX	:= 0
	Local aRet	:= {}
	Local aAux	:= {}

	//+-----------------------------------------------------+
	//|Efetua a consulta ao banco para cada item selecionado|
	//+-----------------------------------------------------+
	For nX:= 1 To Len(aTemp)
		cQry := "SELECT E1_NUM,E1_PREFIXO,E1_PARCELA,SE1.R_E_C_N_O_ AS E1_NUMREC" + CRLF
		cQry += "FROM " + RetSqlName("SE1") + " SE1" + CRLF
		cQry += "WHERE E1_FILIAL = '" + xFilial("SE1") + "'" + CRLF
		cQry += "	AND E1_PREFIXO = '" + aTemp[nX][2] + "' AND E1_NUM = '" + aTemp[nX][3] + "'" + CRLF
		If !(lAuto)
			cQry += "	AND E1_PARCELA = '" + aTemp[nX][4] + "' " + CRLF
		EndIf
		cQry += "	AND E1_PORTADO = '033' " + CRLF
		cQry += "	AND SE1.D_E_L_E_T_ = ' '" + CRLF
		cQry += "ORDER BY E1_NUM,E1_PREFIXO,E1_PARCELA"

		//+---------------------------------+
		//|Verifica se o arquivo esta em uso|
		//+---------------------------------+
		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf

		//+--------------------------+
		//|Cria instancia de trabalho|
		//+--------------------------+
		TcQuery cQry New Alias "TRB1"

		//+------------------------------------------------------------------------------------------+
		//| Prepara informacoes que serao utilizadas na impressao conforme itens selecionados na tela|
		//+------------------------------------------------------------------------------------------+
		If !(lAuto)
			aAux := SYORDINF(aTemp[nX])

			If !(Empty(aAux))
				aAdd(aRet,{})
				aRet[nX] := aAux
			EndIf
		EndIf
	Next nX

	//+-----------------------------------------------------------------------------------------------------+
	//| Prepara informacoes que serao utilizadas na impressao verificando cada parcela do titulo posicionado|
	//+-----------------------------------------------------------------------------------------------------+
	If lAuto
		TRB1->(DbGoTop())
		While (TRB1->(!(Eof())))
			aAux := SYORDINF(aTemp[1])

			If !(Empty(aAux))
				aAdd(aRet,aAux)
			EndIf
			TRB1->(DbSkip())
		EndDo
		TRB1->(DbCloseArea())
	EndIf
Return(aRet)

/*/{Protheus.doc} SYORDINF
Organiza registros consultados para utilizacao no boleto.
@author Douglas Telles
@since 30/05/2016
@version 1.0
@param aTemp, array, Array com as informações consultadas do título.
@return aRegs, Array com os dados devidamente organizados.
/*/
Static Function SYORDINF(aTemp)
	Local aRegs := {}

	If !(lAuto)
		TRB1->(DbGoTop())
	EndIf
	If !(TRB1->(Eof()))
		aRegs := {	aTemp[1]			,; // G = Gerar Novo, R = Reimprimir
					TRB1->E1_NUM		,; // Numero do titulo
					TRB1->E1_PREFIXO	,; // Prefixo do titulo
					TRB1->E1_PARCELA	,; // Parcela do titulo
					TRB1->E1_NUMREC	}  // R_E_C_N_O_ do titulo
	EndIf

	If !(lAuto)
		TRB1->(DbCloseArea())
	EndIf
Return(aRegs)

/*/{Protheus.doc} SYVALIDIMP
Efetua as regras e validações necessárias antes de imprimir o boleto.
@author Douglas Telles
@since 30/05/2016
@version 1.0
@param aCols, array, Array com as informações a serem impressas.
/*/
Static Function SYVALIDIMP(aCols)
	Local nX					:= 0
	Local oPrint				:= Nil
	Local lAdjustToLegacy	:= .F.
	Local lDisableSetup		:= .T.
	Local cDirClient			:= GetTempPath()
	Local cFile				:= "Boleto"+Trim(SE1->E1_NUM)+Trim(SE1->E1_PARCELA)+DTOS(dDataBase)+Replace(Time(),':','')+".PD_"
	Local cDirExp				:= "\spool\"
	Local cConout				:= ""

	//+-------------------------------------------------+
	//|Instancia objeto a ser utilizado para impressao. |
	//+-------------------------------------------------+
	oPrint :=	FWMSPrinter():New(cFile, IMP_PDF, lAdjustToLegacy,cDirExp, lDisableSetup, , , , .T., , .F., )
	oPrint:CPATHPDF := cDirClient
	oPrint:setResolution(78)
	oPrint:SetPortrait()
	oPrint:setPaperSize(TAM_A4)
	oPrint:SetMargin(60,60,60,60)

	ProcRegua(Len(aCols))

	For nX:= 1 To Len(aCols)
		IncProc("Titulo " + aCols[nX][2] + " Parcela " + aCols[nX][4])

		//+--------------------------------------------------------+
		//|Posiciona no registro atraves do recno filtrado na query|
		//+--------------------------------------------------------+
		SE1->(DbGoTo(aCols[nX][Len(aCols[nX])]))

		SA1->( DbSetOrder(1) )
		SA1->( DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA) )

		SA6->( DbSetOrder(1) )
		SA6->( DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA) )
		If !( AllTrim(SA6->A6_COD) $ "033" )
			MsgAlert("A impressão de boletos não é valida para o banco " + AllTrim(SA6->A6_COD),"Atenção")
		Else
			SEE->( DbSetOrder(1) )
			IF !SEE->(DbSeek(xFilial("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
				MsgAlert("Não existe os dados de configuração do banco (SEE).","Atenção")
			Else
				If !Empty(SEE->EE_DIASPRT)
					cMensBol3 := 'Protestar após ' + Trim(SEE->EE_DIASPRT) + ' dias corridos do vencimento.
				EndIf
				//+-------------------------+
				//|Verifica se e reimpressao|
				//+-------------------------+
				If aCols[nX][1] == 'R' // Reimpressao
					lReimp := .T.
					cNumBol := AllTrim(SE1->E1_NUMBCO)
					cNumBol := SubStr(cNumBol,1,Len(AllTrim(cNumBol))-1) // Ignora o digito verificador
				Else // Gerar novo numero
					lReimp := .F.
					/*
					If !Empty(SE1->E1_NUMBOR)
						MsgAlert("Título encontra-se no Bordero " + SE1->E1_NUMBOR, "Atencao")
						Loop
					Endif
					*/

					If lAuto
						cNumBol := AllTrim(SE1->E1_NUMBCO)
						cNumBol := SubStr(cNumBol,1,Len(AllTrim(cNumBol))-1) // Ignora o digito verificador

						If !(Empty(cNumBol))
							/*cConout := "Já Foi Emitido boleto para este Titulo" + CHR(13)
							cConout += "Numero Do Boleto: " + cNumBol + CHR(13)
							cConout += "Confirma a REEMISSAO DESTE BOLETO?"
							If !(MsgYesNo(cConout))
								Loop
							EndIf*/
							lReimp := .T.
						EndIf
					EndIf
				EndIf
				//+---------------------------+
				//|Chama funcao para impressao|
				//+---------------------------+
				SYIMPBOL(oPrint)
			EndIF
		EndIF
	Next nX

	If lPreview
		oPrint:Preview()
	EndIf

	/*
	If MV_PAR05 == 1 // Envia E-mail
		If lPreview
			If SA1->(FieldPos("A1_EMNFE")) > 0 .And. !Empty(Alltrim(SA1->A1_EMNFE))
				// +---------------------------------------------------+
				// | Copia arquivo para servidor para enviar por email |
				// +---------------------------------------------------+
				CpyT2S( cDirClient + Replace(cFile ,'PD_','PDF'), cDirExp)
				cFileMail := Replace(cDirExp + cFile ,'PD_','PDF')

				// +-------------------------------------------------------------------------+
				// | Executa a funcao que envia o email. Funcao esta no fonte FuncoesBol.prw |
				// +-------------------------------------------------------------------------+
				FwMsgRun(,{|| U_MMBolMail(Alltrim(SA1->A1_EMNFE),cFileMail,aInfMail)}, '','Enviando Boleto por E-Mail...')

				// +----------------------------+
				// | Apaga arquivo do servidor. |
				// +----------------------------+
				FErase(cFileMail)
			Else
				cConout := "E-mail não encontrado no cadastro do cliente!" + CRLF
				cConout += "Cod. " + SA1->A1_COD + " Loja " + SA1->A1_LOJA
				MsgAlert(cConout,"E-mail Não Enviado!")
			EndIf
		Else
			cConout := "Email não enviado ao cliente!" + CRLF
			cConout += "Não foi gerado boleto para envio."
			MsgAlert(cConout)
		EndIf
	EndIf
	*/
Return

/*/{Protheus.doc} SYIMPBOL
Gera o layout do boleto já com as informações.
@author Douglas Telles
@since 30/05/2016
@version 1.0
@param oPrint, objeto, Objeto de impressão a ser utilizado.
/*/
Static Function SYIMPBOL(oPrint)
	Local cCarteira		:= AllTrim(SEE->EE_CODCART)
	Local cValorTit		:= ""
	Local cFatorVcto	:= ""
	Local cNumBanco		:= AllTrim(SA6->A6_COD)
	Local cAgencia		:= StrTran(Alltrim(SA6->A6_AGENCIA),'-','')
	Local cNumConta		:= StrTran(Alltrim(SA6->A6_NUMCON),'-','')
	Local cDigConta		:= Alltrim(SA6->A6_DVCTA)
	Local cDigAgenc		:= Alltrim(SA6->A6_DVAGE)
	Local cCodCed		:= AllTrim(SEE->EE_CODEMP)
	Local cDtVencto		:= Ctod("")
	Local cBitMapBanco	:= GetSrvProfString("Startpath","")+"logo\logo_sant.bmp"
	Local cNumTit		:= Iif(!Empty(SE1->E1_NFELETR), Alltrim(SE1->E1_NFELETR), StrZero(Val(SE1->E1_NUM),6))
	Local cParcela		:= IIF(Empty(SE1->E1_PARCELA),"0",SE1->E1_PARCELA)
	Local oFont6  		:= TFont():New("Arial", 9, 06, .T., .F., 5, .T., 5, .T., .F.)
	Local oFont8  		:= TFont():New("Arial", 9, 08, .T., .F., 5, .T., 5, .T., .F.)
	Local oFont8B  		:= TFont():New("Arial", 9, 08, .T., .T., 5, .T., 5, .T., .F.)
	Local oFont10 		:= TFont():New("Arial", 9, 10, .T., .T., 5, .T., 5, .T., .F.)
	Local oFont12 		:= TFont():New("Arial", 9, 12, .T., .T., 5, .T., 5, .T., .F.)
	Local oFont11 		:= TFont():New("Arial", 9, 11, .T., .T., 5, .T., 5, .T., .F.)
	Local oFont16 		:= TFont():New("Arial", 9, 16, .T., .T., 5, .T., 5, .T., .F.)
	Local oFont14N		:= TFont():New("Arial", 9, 14, .T., .F., 5, .T., 5, .T., .F.)
	Local oFont22 		:= TFont():New("Arial", 9, 22, .T., .T., 5, .T., 5, .T., .F.)
	Local nValorTit		:= 0

	// +----------------------------------------------------------+
	// | Indica que foi gerado boleto para pelo menos uma parcela |
	// +----------------------------------------------------------+
	lPreview := .T.

	cDtVencto := SE1->E1_VENCTO
	nValorTit := SE1->E1_SALDO - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

	cFatorVcto := StrZero(cDtVencto - Ctod("07/10/1997"),4)

	cValorTit  := Right(StrZero(nValorTit * 100,17,0),10)

	IF nValorTit > 99999999.99
		cFatorVcto:= ""
		cValorTit := Substr(StrZero(nValorTit * 100,17,2),1,14)
	EndIF

	//+--------------------------------------------------+
	//| Prepara o nosso numero com as devidas validacoes |
	//+--------------------------------------------------+
	SyGetNN(cCodCed)

	cDadosCta	:=	cAgencia + "-" + cDigAgenc + " / " + cNumConta + "-" + cDigConta
	//cDadosCta	:=	AllTrim(TransForm(cAgencia + cDigAgenc,"@R " + Replicate('9',Len(cAgencia + cDigAgenc)))) + ' / '
	//cDadosCta	+=	AllTrim(TransForm(cNumConta + cDigConta,"@R " + Replicate('9',Len(cNumConta + cDigConta)-1) + "-9"))

	// Prepara o codigo de barras
	cDigCodBar		:=	Modulo11(cNumBanco + "9" + cFatorVcto + cValorTit + '9' + cCodCed + cNossoNum + '0' + cCarteira )
	cDigCodBar		:= IIF(cDigCodBar $ "0|1|10","1",cDigCodBar)
	cCodBar		:= cNumBanco + "9" + cDigCodBar + cFatorVcto + cValorTit + '9' + cCodCed + cNossoNum + '0' + cCarteira 
	// Prepara Linha Digitavel
	cDigblc1		:=	Modulo10(cNumBanco + "99" + SubStr(cCodCed,1,4))
	cBloco1		:=	Transform(cNumBanco + "99" + SubStr(cCodCed,1,4) + cDigblc1,"@R 99999.99999")
	cDigblc2		:=	Modulo10(SubStr(cCodCed,5,3) + SubStr(StrZero(val(cNossoNum),13),1,7))
	cBloco2		:= 	Transform(SubStr(cCodCed,5,3) + SubStr(StrZero(val(cNossoNum),13),1,7) + cDigblc2,"@R 99999.999999")
	cDigblc3		:=	Modulo10(SubStr(StrZero(val(cNossoNum),13),8,6) + '0' + cCarteira)
	cBloco3		:=	Transform(SubStr(StrZero(val(cNossoNum),13),8,6) + '0' + cCarteira + cDigblc3,"@R 99999.999999")
	cBloco4		:=	cFatorVcto + cValorTit
	cLinDigi		:=	cBloco1 + "   " + cBloco2 + "   " + cBloco3 + "  " + cDigCodBar + "   " + cBloco4

	//+---------------------+
	//| Inicia nova pagina. |
	//+---------------------+
	oPrint:StartPage()

	//+--------------------------+
	//|Layout - Recibo do Sacado |
	//+--------------------------+
	oPrint:Line(80, 240, 100, 240) // Linha do codigo do banco
	oPrint:Line(80, 285, 100, 285) // Linha do codigo do banco
	oPrint:Box(100, 025, 128, 390) // Local de pagamento
	oPrint:Box(100, 390, 128, 550) // Vencimento
	oPrint:Box(128, 025, 148, 390) // Cedente
	oPrint:Box(128, 390, 148, 550) // Ag. / Cod. Cedente
	oPrint:Box(148, 025, 168, 088) // Data Documento
	oPrint:Box(148, 088, 168, 190) // No. Documento
	oPrint:Box(148, 190, 168, 233) // Esp. Doc.
	oPrint:Box(148, 233, 168, 285) // Aceite
	oPrint:Box(148, 285, 168, 390) // Data Processamento
	oPrint:Box(148, 390, 168, 550) // Nosso Num
	oPrint:Box(168, 025, 188, 088) // Uso do Banco
	oPrint:Box(168, 088, 188, 152) // Carteira
	oPrint:Box(168, 152, 188, 190) // Especie
	oPrint:Box(168, 190, 188, 285) // Quantidade
	oPrint:Box(168, 285, 188, 390) // Valor
	oPrint:Box(168, 390, 188, 550) // (=) Valor documento
	oPrint:Box(188, 025, 288, 390) // Instrucoes
	oPrint:Box(188, 390, 208, 550) // (-) Desconto
	oPrint:Box(208, 390, 228, 550) // (-) Abatimento
	oPrint:Box(228, 390, 248, 550) // (+) Mora
	oPrint:Box(248, 390, 268, 550) // (+) Outros Acrescimos
	oPrint:Box(268, 390, 288, 550) // (=) Valor Cobrado
	oPrint:Box(288, 025, 330, 550) // Sacado

	//+-----------------------------+
	//|Layout - Ficha de Compensacao|
	//+-----------------------------+
	oPrint:Line(444, 145, 464, 145) // Linha do codigo do banco
	oPrint:Line(444, 190, 464, 190) // Linha do codigo do banco
	oPrint:Box(464, 025, 490, 390) // Local de Pagamento
	oPrint:Box(464, 390, 490, 550) // Vencimento
	oPrint:Box(490, 025, 510, 390) // Cedente
	oPrint:Box(490, 390, 510, 550) // Ag. / Cod. Cedente
	oPrint:Box(510, 025, 530, 088) // Data Documento
	oPrint:Box(510, 088, 530, 190) // No. Documento
	oPrint:Box(510, 190, 530, 233) // Esp. Doc.
	oPrint:Box(510, 233, 530, 285) // Aceite
	oPrint:Box(510, 285, 530, 390) // Data Processamento
	oPrint:Box(510, 390, 530, 550) // Nosso Num
	oPrint:Box(530, 025, 550, 088) // Uso do Banco
	oPrint:Box(530, 088, 550, 152) // Carteira
	oPrint:Box(530, 152, 550, 190) // Especie
	oPrint:Box(530, 190, 550, 285) // Quantidade
	oPrint:Box(530, 285, 550, 390) // Valor
	oPrint:Box(530, 390, 550, 550) // (=) Valor documento
	oPrint:Box(550, 025, 650, 390) // Instrucoes
	oPrint:Box(550, 390, 570, 550) // (-) Desconto
	oPrint:Box(570, 390, 590, 550) // (-) Abatimento
	oPrint:Box(590, 390, 610, 550) // (+) Mora
	oPrint:Box(610, 390, 630, 550) // (+) Outros Acrescimos
	oPrint:Box(630, 390, 650, 550) // (=) Valor Cobrado
	oPrint:Box(650, 025, 693, 550) // Sacado

	//+--------------------------+
	//|Layout - Recibo do Sacado |
	//+--------------------------+
	If File(cBitMapBanco)
		oPrint:SayBitmap(070, 020, cBitMapBanco, 120, 028 )
	Else
		oPrint:Say(096, 027, AllTrim(SA6->A6_NOME), oFont14N)
	EndIf

	oPrint:Say(096, 245, cNumBanco + "-7", oFont16)
	oPrint:Say(096, 450, "RECIBO DO SACADO", oFont8B ,100)
	oPrint:Say(107, 027, "Local de Pagamento",ofont8,100)
	oPrint:Say(116, 027, 'PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO.',oFont10,100)
	//oPrint:Say(123, 027, 'Após vencimento, somente no Banco do Brasil',oFont8b,100)
	oPrint:Say(107, 392, "Vencimento",ofont8,100)
	oPrint:Say(120, 400, DTOC(cDtVencto),ofont10,400,,,1) //Vencimento
	oPrint:Say(135, 027, "Cedente",ofont8,100)
	oPrint:Say(135, 392, "Agência/Código Cedente",ofont8,100)
	oPrint:Say(145, 030, Upper(Alltrim(SM0->M0_NOMECOM)) ,ofont10,100)
	oPrint:Say(145, 400, cDadosCta,ofont10,116,,,1)          //Agencia/Codigo do Cedente
	oPrint:Say(155, 027, "Data Documento",ofont8,100)
	oPrint:Say(155, 092, "No. do Documento",ofont8,100)
	oPrint:Say(155, 195, "Esp. Doc.",ofont8,100)
	oPrint:Say(155, 238, "Aceite",ofont8,100)
	oPrint:Say(155, 290, "Data Processamento",ofont8,100)
	oPrint:Say(155, 392, "Nosso Número",ofont8,100)
	oPrint:Say(164, 027, DTOC(SE1->E1_EMISSAO),ofont10,100)
	oPrint:Say(164, 094, cNumTit+"/"+cParcela,ofont10,100)    //Numero do Documento
	oPrint:Say(164, 195, "DM",ofont10,100)
	oPrint:Say(164, 238, "N",ofont10,100)
	oPrint:Say(164, 290, DTOC(SE1->E1_EMISSAO),ofont10,100)
	oPrint:Say(164, 400, TransForm(cNossoNum,"@R " + Replicate('9',Len(cNossoNum)-1)+"-9"),ofont10,100,,,1)
	oPrint:Say(175, 027, "Uso do Banco",ofont8,100)
	oPrint:Say(175, 093, "Carteira",ofont8,100)
	oPrint:Say(175, 157, "Espécie",ofont8,100)
	oPrint:Say(175, 195, "Quantidade",ofont8,100)
	oPrint:Say(175, 293, "Valor",ofont8,100)
	oPrint:Say(175, 392, "(=) Valor do Documento",ofont8,100)
	oPrint:Say(185, 093, cCarteira + "-ECR",ofont10,100) // carteira
	oPrint:Say(185, 157, "REAL",ofont10,100)
	oPrint:Say(185, 400, AllTrim(TransForm(nValorTit, "@E 999,999,999.99")),ofont10,100,,,1) //Valor
	oPrint:Say(195, 027, "Instruções de responsabilidade do Beneficiário. Qualquer dúvida sobre este boleto, contate o BENEFICIÁRIO.",ofont6,100)
	oPrint:Say(195,392,"(-) Desconto",ofont8,100)
	oPrint:Say(215,392,"(-) Abatimento",ofont8,100)
	oPrint:Say(235,392,"(+) Mora",ofont8,100)
	oPrint:Say(255,392,"(+) Outros Acréscimos",ofont8,100)
	oPrint:Say(275,392,"(=) Valor Cobrado",ofont8,100)

	cJuros := SYCALCJU(nValorTit) + " por dia de atraso."

	oPrint:Say  (205, 027, cMensBol1 + cJuros, oFont10)
	oPrint:Say  (215, 027, cMensBol2, oFont10)
	oPrint:Say  (225, 027, cMensBol3, oFont10)
	oPrint:Say  (235, 027, cMensBol4, oFont10)

	If SE1->E1_DECRESC > 0
		oPrint:Say(245,027,"Conceder desconto no valor de R$" + Transform(SE1->E1_DECRESC,"99,999.99"),ofont10,100)
	EndIf

	oPrint:Say(294, 027, "Sacado", ofont8, 100)
	oPrint:Say(294, 392, "Autenticação Mecânica", ofont8, 100)
	oPrint:Say(302, 027, AllTrim(SA1->A1_NOME)+'  -  ' + SA1->A1_COD, ofont8B, 100)
	oPrint:Say(302, 392, Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),ofont8B, 100)
	oPrint:Say(311, 027, AllTrim(SA1->A1_ENDCOB) + IIF(!EMPTY(SA1->A1_BAIRROC),'   -   ' + AllTrim(SA1->A1_BAIRROC),' '), ofont8B, 100)
	oPrint:Say(320, 027, Alltrim(Transform(SA1->A1_CEPC,"@R 99999-999"))+'   -   '+ AllTrim(SA1->A1_MUNC)+'   -   '+SA1->A1_ESTC, oFont8B, 100 )
	oPrint:Say(328, 027, 'Sacador/Avalista',ofont8,500)
	oPrint:Say(328, 392, 'Cód. Baixa', ofont8, 100)

	oPrint:Say(395, 000, Replicate("-",1800), ofont8, 100)

	//+-----------------------------+
	//|Layout - Ficha de Compensacao|
	//+-----------------------------+
	If File(cBitMapBanco)
		oPrint:SayBitmap(435, 020, cBitMapBanco, 120, 028 )
	Else
		oPrint:Say(461, 027, SubStr(AllTrim(SA6->A6_NOME),1,18), ofont11, 100)
	EndIf
	oPrint:Say(461, 150, cNumBanco + "-7", oFont16, 100)
	oPrint:Say(461, 193, cLinDigi, oFont14N, 100 )

	oPrint:Say(471, 027, "Local de Pagamento",ofont8,100)
	oPrint:Say(471, 392, "Vencimento",ofont8,100)
	oPrint:Say(480, 027, "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO.",ofont10,100)
	//oPrint:Say(488, 027, "Após vencimento, somente no Banco do Brasil",ofont8b,100)
	oPrint:Say(480, 400, Dtoc(SE1->E1_VENCTO), ofont10, 100,,,1)
	oPrint:Say(497, 027, "Cedente",ofont8,100)
	oPrint:Say(497, 392, "Agência/Código Cedente",ofont8,100)
	oPrint:Say(507, 030, Upper(Alltrim(SM0->M0_NOMECOM)) ,ofont10,100)
	oPrint:Say(507, 400, cDadosCta,ofont10,116,,,1) //Agencia/Codigo do Cedente
	oPrint:Say(518, 027, "Data Documento",ofont8,100)
	oPrint:Say(518, 092, "No. do Documento",ofont8,100)
	oPrint:Say(518, 195, "Esp. Doc.",ofont8,100)
	oPrint:Say(518, 238, "Aceite",ofont8,100)
	oPrint:Say(518, 290, "Data Processamento",ofont8,100)
	oPrint:Say(518, 392, "Nosso Número",ofont8,100)
	oPrint:Say(527, 027, dtoc(SE1->E1_EMISSAO),ofont10,100)
	oPrint:Say(527, 093, cNumTit+"/"+cParcela,ofont10,100)    //Numero do Documento
	oPrint:Say(527, 195, "DM",ofont10,100)
	oPrint:Say(527, 238, "N",ofont10,100)
	oPrint:Say(527, 290, dtoc(SE1->E1_EMISSAO),ofont10,100)
	oPrint:Say(527, 400, TransForm(cNossoNum,"@R " + Replicate('9',Len(cNossoNum)-1)+"-9"),ofont10,100,,,1)
	oPrint:Say(538, 027, "Uso do Banco",ofont8,100)
	oPrint:Say(538, 093, "Carteira",ofont8,100)
	oPrint:Say(538, 157, "Espécie",ofont8,100)
	oPrint:Say(538, 195, "Quantidade",ofont8,100)
	oPrint:Say(538, 290, "Valor",ofont8,100)
	oPrint:Say(538, 392, "(=) Valor do Documento",ofont8,100)
	oPrint:Say(548, 093, cCarteira + "-ECR",ofont10,100) // carteira
	oPrint:Say(548, 157, "REAL",ofont10,100)
	oPrint:Say(548, 400, AllTrim(TransForm(nValorTit, "@E 999,999,999.99")),ofont10,100,,,1)           //Valor
	oPrint:Say(558, 027, "Instruções de responsabilidade do Beneficiário. Qualquer dúvida sobre este boleto, contate o BENEFICIÁRIO.",ofont6,100)
	oPrint:Say(558, 392, "(-) Desconto",ofont8,100)
	oPrint:Say(578, 392, "(-) Abatimento",ofont8,100)
	oPrint:Say(598, 392, "(+) Mora",ofont8,100)
	oPrint:Say(618, 392, "(+) Outros Acréscimos",ofont8,100)
	oPrint:Say(638, 392, "(=) Valor Cobrado",ofont8,100)

	cJuros := SYCALCJU(nValorTit) + " por dia de atraso."

	oPrint:Say  (568, 027, cMensBol1 + cJuros, oFont10)
	oPrint:Say  (578, 027, cMensBol2, oFont10)
	oPrint:Say  (588, 027, cMensBol3, oFont10)
	oPrint:Say  (598, 027, cMensBol4, oFont10)

	If SE1->E1_DECRESC > 0
		oPrint:Say(608,027,"Conceder desconto no valor de R$" + Transform(SE1->E1_DECRESC,"99,999.99"),ofont10,100)
	EndIf

	oPrint:Say(657, 027, "Sacado", ofont8, 100)
	oPrint:Say(657, 392, "Autenticação Mecânica", ofont8, 100)
	oPrint:Say(665, 027, AllTrim(SA1->A1_NOME)+'  -  ' + SA1->A1_COD, ofont8B, 100)
	oPrint:Say(665, 392, Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),ofont8B, 100)
	oPrint:Say(674, 027, AllTrim(SA1->A1_ENDCOB) + IIF(!EMPTY(SA1->A1_BAIRROC),'   -   ' + AllTrim(SA1->A1_BAIRROC),' '), ofont8B, 100)
	oPrint:Say(683, 027, Alltrim(Transform(SA1->A1_CEPC,"@R 99999-999"))+'   -   '+ AllTrim(SA1->A1_MUNC)+'   -   '+ SA1->A1_ESTC, oFont8B, 100 )
	oPrint:Say(690, 027, 'Sacador/Avalista',ofont8,500)
	oPrint:Say(690, 392, 'Cód. Baixa', ofont8, 100)
	oPrint:Say(702, 375, 'Autenticação Mecânica - Ficha de Compensação', ofont8, 100)

	//+-------------------------------+
	//|Impressão do  codigo de barras |
	//+-------------------------------+
	oPrint:FWMSBAR("INT25" ,62 ,3 ,cCodBar ,oPrint,.F.,,.T.,0.025,1.4,,,,.F.,,,)

	oPrint:EndPage()

	aAdd(aInfMail,cNumTit) // Numero do titulo utilizado no boleto
	aAdd(aInfMail,SE1->E1_PREFIXO) // Serie do titulo
	aAdd(aInfMail,cParcela) // Parcela que foi impressa
	aAdd(aInfMail,SM0->M0_NOMECOM) // Nome da Beneficiario
Return()

/*/{Protheus.doc} SyGetNN
Prepara o Nosso Numero verificando se o numero a ser utilizado ja existe.
@author Douglas Telles
@since 25/05/2016
@version 1.0
/*/
Static Function SyGetNN()
	cNumBoleto		:= SYRETSEQ() // Numero sequencial de acordo com a SEE
	cDVNossoNum	:= AllTrim(Modulo11(cNumBoleto)) // Digito de Verificacao do nosso numero

	If !lReimp
		While ValFaixa(cNumBoleto + cDVNossoNum,SE1->E1_AGEDEP,SE1->E1_CONTA)
			cNumBoleto		:= Soma1(cNumBoleto)
			cDVNossoNum	:= AllTrim(Modulo11(cNumBoleto))
		EndDo

		DbSelectArea("SEE")
		RecLock("SEE",.F.)
			SEE->EE_FAXATU := StrZero(Val(cNumBoleto) + 1,7)
		MsUnlock()

		DbSelectArea("SE1")
		RecLock("SE1",.F.)
			SE1->E1_NUMBCO := cNumBoleto + cDVNossoNum
		MsUnlock()
	EndIf

	cNossoNum	:= cNumBoleto + cDVNossoNum // Nosso numero. (Numero do boleto)
Return

/*/{Protheus.doc} SYRETSEQ
Captura o numero do boleto.
@author Douglas Telles
@since 01/06/2016
@version 1.0
@return cNumero, Numero do boleto a ser utilizado.
/*/
Static Function SYRETSEQ()
	Local cNumero

	If lReimp
		cNumero := StrZero(Val(cNumBol),7)
	Else
		cNumero := StrZero(Val(SEE->EE_FAXATU),7)
	EndIf
Return(cNumero)

/*/{Protheus.doc} SYCALCJU
Calcula o valor do juros a ser cobrado.
@author Douglas Telles
@since 01/06/2016
@version 1.0
@param nValorTit, numérico, Valor do título.
@return cRet, Valor do juros ja com a picture.
/*/
Static Function SYCALCJU(nValorTit)
	Local nPrcDia	:= SE1->E1_PORCJUR
	Local nResult	:= 0
	Local cRet		:= ''

	nResult	:= (nPrcDia * nValorTit) / 100
	cRet		:= Alltrim(Transform(nResult,"@E 999,999,999.99"))
Return(cRet)

/*/{Protheus.doc} ValFaixa
Valida a faixa da tabela de parametros de banco.
@author Douglas Telles
@since 25/05/2016
@version 1.0
@param cNum, caracter, Numero a ser validado
@return lExist, Indica se o codigo ja existe
/*/
Static Function ValFaixa(cNum,cAgencia,cConta)
	Local aBkpArea	:= GetArea()
	Local lExist		:= .F.
	Local cQry			:= ""

	cQry := "SELECT COUNT(E1_NUM) QTD" + CRLF
	cQry += "FROM " + RetSqlName("SE1") + " SE1" + CRLF
	cQry += "WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND" + CRLF
	cQry += "	E1_NUMBCO LIKE '" + AllTrim(cNum) + "'"+ CRLF
	cQry += "	AND E1_PORTADO = '033' " + CRLF
	cQry += "	AND E1_AGEDEP = '" + cAgencia + "' " + CRLF
	cQry += "	AND E1_CONTA = '" + cConta + "' " + CRLF
	cQry += "	AND SE1.D_E_L_E_T_ = ' '" + CRLF

	//+---------------------------------+
	//|Verifica se o arquivo esta em uso|
	//+---------------------------------+
	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	EndIf

	//+--------------------------+
	//|Cria instancia de trabalho|
	//+--------------------------+
	TcQuery cQry New Alias "TRB2"

	If TRB2->QTD > 0
		lExist := .T.
	EndIf

	TRB2->(DbCloseArea())
Return (lExist)