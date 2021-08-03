#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.CH"

#DEFINE TAM_A4 9 // A4 - 210mm x 297mm - 620 x 876

/***************************************************************************************/
/*/{Protheus.doc} BOLBRADN
	@description Impressao boleto bradesco
	@author Bernard M. Margarido
	@since 22/02/2017
	@version undefined
	@type function
/*/
/***************************************************************************************/
User function BOLBRADN(cDocx,cSeriex,cEnvBol)
Local cPerg			:= ''

Local aRegs			:= {}
Local aTemp			:= {}

Local cV12			:= GetRpoRelease()

Private lV12		:= SubStr(cV12,1,2) == "12"
Private cNumBoleto	:= ""
Private cComplemen	:= ""
Private cNumBol		:= ""
Private cNossoNum	:= ""
Private cDVNossoNum	:= ""
Private cDvCedente	:= ""
Private cJuros		:= ""
Private cMensBol1	:= "Após vencimento cobrar "
Private cMensBol2	:= ""
Private cMensBol3	:= "Protestar após 3 dias corridos do vencimento."
Private cMensBol4	:= ""
Private lAuto		:= .F.
Private lReimp		:= .F.
Private aInfMail	:= {}
Private lPreview	:= .F.

Default cDocx   	:= ""
Default cSerieX 	:= ""
Default cEnvBol		:= "1"

//+-------------------------------------------+
//|Funcao que cria as perguntas no arquivo SX1|
//+-------------------------------------------+
cPerg := U_BolSx1()

//+----------------------------------------------------------------------+
//|Verifica se o programa foi chamado atraves do menu ou por outra funcao|
//+----------------------------------------------------------------------+
If Empty(cDocx) .And. Empty(cSeriex)  //Trim(FunName()) == 'BOLBRADN' 
	If !(Pergunte(cPerg,.T.))
		Return
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

If MV_PAR04 <> '237'
	ALERT("Atenção !!! O código informado não pertence a este banco, o código correto é 237!")
	Return
EndIf

If lAuto
	aTemp := {{'G',MV_PAR03,MV_PAR01,SE1->E1_PARCELA}}
Else
	aTemp := U_MMSelNfBol(MV_PAR03,MV_PAR01,MV_PAR02,MV_PAR04)
EndIf

If Empty(aTemp)
	Return
EndIf

aRegs := SYCRIAQRY(aTemp)

Processa( {|lEnd| SYVALIDIMP(aRegs) }, "Aguarde...","Gerando Boletos...",.T.)

Return

/***************************************************************************************/
/*/{Protheus.doc} SYCRIAQRY
	Consulta as informacoes do titulo para preparar o boleto.
	@author Douglas Telles
	@since 30/05/2016
	@version 1.0
	@param aTemp, array, Array com os dados a serem consultados.
	@return aRet, Dados a serem utilizados na preparação do boleto.
/*/
/***************************************************************************************/
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
	cQry += "	AND E1_PORTADO = '237' " + CRLF
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

/***************************************************************************************/
/*/{Protheus.doc} SYVALIDIMP
	Efetua as regras e validações necessárias antes de imprimir o boleto.
	@author Douglas Telles
	@since 30/05/2016
	@version 1.0
	@param aCols, array, Array com as informações a serem impressas.
/*/
/***************************************************************************************/
Static Function SYVALIDIMP(aCols)
	Local nX					:= 0
	Local oPrint				:= Nil
	Local lAdjustToLegacy		:= .F.
	Local lDisableSetup			:= .T.
	Local cDirClient			:= GetTempPath()
	Local cFile					:= "Boleto"+Trim(SE1->E1_NUM)+Trim(SE1->E1_PARCELA)+DTOS(dDataBase)+Replace(Time(),':','')+".PD_"
	Local cDirExp				:= "\spool\"
	Local cConout				:= ""

	//+-------------------------------------------------+
	//|Instancia objeto a ser utilizado para impressao. |
	//+-------------------------------------------------+
	oPrint 			:=	FWMSPrinter():New(cFile, IMP_PDF, lAdjustToLegacy,cDirExp, lDisableSetup, , , , .T., , .F., )
	oPrint:cPathPdf := cDirClient
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
		SA1->( DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA) )

		SA6->( DbSetOrder(1) )
		SA6->( DbSeek(xFilial("SA6") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA) )
		If !( AllTrim(SA6->A6_COD) $ "237" )
			MsgAlert("A impressão de boletos não é valida para o banco " + AllTrim(SA6->A6_COD),"Atenção")
		Else
			SEE->( DbSetOrder(1) )
			IF !SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA))
				MsgAlert("Não existe os dados de configuração do banco (SEE).","Atenção")
			Else
				If !Empty(SEE->EE_DIASPRT)
					cMensBol3 := 'Protestar após ' + Trim(SEE->EE_DIASPRT) + ' dias corridos do vencimento.'
				EndIf
				//+-------------------------+
				//|Verifica se e reimpressao|
				//+-------------------------+
				If aCols[nX][1] == 'R' // Reimpressao
					lReimp 	:= .T.
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

/***************************************************************************************/
/*/{Protheus.doc} SYIMPBOL
	Gera o layout do boleto já com as informações.
	@author Douglas Telles
	@since 30/05/2016
	@version 1.0
	@param oPrint, objeto, Objeto de impressão a ser utilizado.
/*/
/***************************************************************************************/
Static Function SYIMPBOL(oPrint)
	Local cCarteira		:= AllTrim(SEE->EE_CODCART)
	Local cValorTit		:= ""
	Local cFatorVcto	:= ""
	Local cBitMapBanco	:= GetSrvProfString("Startpath","") +"logo"+"\logo_bradesco_02.bmp"
	Local cNumBanco		:= AllTrim(SA6->A6_COD)
	Local cAgencia		:= StrTran(Alltrim(SA6->A6_AGENCIA),'-','')
	Local cNumConta		:= StrTran(Alltrim(SA6->A6_NUMCON),'-','')
	Local cDigConta		:= Alltrim(SA6->A6_DVCTA)
	Local cDigAgenc		:= Alltrim(SA6->A6_DVAGE)
	Local cCodCed		:= AllTrim(SEE->EE_CODEMP) 
	Local cDtVencto		:= Ctod("")
	Local cNumTit		:= Iif(!Empty(SE1->E1_NFELETR), Alltrim(SE1->E1_NFELETR), StrZero(Val(SE1->E1_NUM),6))
	Local cParcela		:= IIF(Empty(SE1->E1_PARCELA),"0",SE1->E1_PARCELA)
	
	Local nValorTit		:= 0
	
	Private oFont6		:= TFont():New("Arial",,06,,.F.,,,,,.F. )
	Private oFont8		:= TFont():New("Arial",,08,,.F.,,,,,.F. )
	Private oFont10		:= TFont():New("Arial",,10,,.T.,,,,,.F. )
	Private oFont16		:= TFont():New("Arial",,16,,.T.,,,,.T.,.F. )
	Private oFont12		:= TFont():New("Arial",,12,,.T.,,,,,.F. )
	Private oFont18		:= TFont():New("Arial",,18,,.T.,,,,,.F. )
	Private oFont14		:= TFont():New("Arial",,14,,.T.,,,,,.F. )
	Private oFont20		:= TFont():New("Arial",,20,,.T.,,,,,.F. )
	Private oFont14		:= TFont():New("Arial",,14,,.T.,,,,.T.,.F. )
	
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
	SyGetNN(cCarteira)

	cDadosCta	:=	cAgencia + "-" + cDigAgenc + " / " + cNumConta + "-" + cDigConta
	//cDadosCta	:=	AllTrim(TransForm(cAgencia + cDigAgenc,"@R " + Replicate('9',Len(cAgencia + cDigAgenc) -1) + "-9")) + '/'
	//cDadosCta	+=	AllTrim(TransForm(cNumConta + cDigConta,"@R " + Replicate('9',Len(cNumConta + cDigConta)-1) + "-9" ))
		
	//----------------------------+
	// Prepara o codigo de barras |
	//----------------------------+
	cCampo01		:=  cNumBanco + "9" + cFatorVcto + PadL(cValorTit,10,"0")
	cCampoLivre		:=  PadL(cAgencia,4,"0") + cCarteira + cNumBoleto + PadL(cNumConta,7,"0" ) + "0" 
	cDigCodBar		:=	Modulo11(cCampo01 + cCampoLivre)
	
	If cDigCodBar == "0" .Or. cDigCodBar == "1" .Or. cDigCodBar > "9"
	 	cDigCodBar := "1"
	EndIf
	 	
	cCodBar			:= 	cNumBanco + "9" + cDigCodBar + cFatorVcto + PadL(cValorTit,10,"0") + PadL(cAgencia,4,"0") + cCarteira + cNumBoleto + PadL(cNumConta,7,"0" ) + "0" 
	
	//-------------------------+	 
	// Prepara Linha Digitavel |
	//-------------------------+
	cDigblc1		:=	Modulo10(cNumBanco + "9" + SubStr(cCampoLivre,1,5),2,1)
	cBloco1			:=	Transform(cNumBanco + "9" + SubStr(cCampoLivre,1,5) + cDigblc1,"@R 99999.99999")
	
	cDigblc2		:=	Modulo10(SubStr(cCampoLivre,6,10),2,1)
	cBloco2			:= 	Transform(SubStr(cCampoLivre,6,10) + cDigblc2,"@R 99999.999999")
	
	cDigblc3		:=	Modulo10(SubStr(cCampoLivre,16,10),2,1)
	cBloco3			:=	Transform(SubStr(cCampoLivre,16,10) + cDigblc3,"@R 99999.999999")
			
	cBloco4			:=	cFatorVcto + PadL(cValorTit,10,"0")
	
	cLinDigi		:=	cBloco1 + "  " + cBloco2 + "  " + cBloco3 + "  " + cDigCodBar + "  " + cBloco4

	//+---------------------+
	//| Inicia nova pagina. |
	//+---------------------+
	oPrint:StartPage()
	
	//+----------------------------+
	//|Layout - Informativo Boleto |
	//+----------------------------+
	oPrint:Line(040, 140, 060, 140) // Linha do codigo do banco
	oPrint:Line(040, 185, 060, 185) // Linha do codigo do banco

	oPrint:Box(060, 025, 080, 390) // Local Pagamento
	oPrint:Box(060, 390, 080, 550) // Vencimento
	
	oPrint:Box(080, 025, 120, 390) // Cedente
	oPrint:Box(080, 390, 100, 550) // Ag. / Cod. Cedente
	oPrint:Box(100, 390, 120, 550) // Uso do Banco
	
	oPrint:Box(120, 025, 140, 098) // Data Documento
	oPrint:Box(120, 098, 140, 171) // Numero documento
	oPrint:Box(120, 171, 140, 244) // Especie Documento
	oPrint:Box(120, 244, 140, 317) // Aceite
	oPrint:Box(120, 317, 140, 390) // Data Processamento
	oPrint:Box(120, 390, 140, 550) // Nosso Numero
		
	oPrint:Box(140, 025, 160, 068) // Uso do Banco
	oPrint:Box(140, 068, 160, 098) // CIP
	oPrint:Box(140, 098, 160, 141) // Carteira
	oPrint:Box(140, 141, 160, 171) // Moeda
	oPrint:Box(140, 171, 160, 244) // Especie
	oPrint:Box(140, 244, 160, 317) // Quantidade
	oPrint:Box(140, 317, 160, 390) // Valor Documento
	oPrint:Box(140, 390, 160, 550) // Valor Documento
	
	oPrint:Box(160, 025, 260, 390) // Instruções 
	oPrint:Box(160, 390, 180, 550) // Descontos / Abatimentos
	oPrint:Box(180, 390, 200, 550) // Outras Deduções
	oPrint:Box(200, 390, 220, 550) // Mora / Multa
	oPrint:Box(220, 390, 240, 550) // Outros Acrescimos
	oPrint:Box(240, 390, 260, 550) // Valor Cobrado
	
	oPrint:Box(260, 025, 300, 550) // Sacado
	
		
	oPrint:Say(350, 025, Replicate("-",187), oFont10, 100)
	
	
	//+-----------------------+
	//|Layout - Recibo Sacado |
	//+-----------------------+
	oPrint:Line(400, 140, 420, 140) // Linha do codigo do banco
	oPrint:Line(400, 185, 420, 185) // Linha do codigo do banco
	
	oPrint:Box(420, 025, 440, 390) // Local Pagamento
	oPrint:Box(420, 390, 440, 550) // Vencimento
	oPrint:Box(440, 025, 460, 390) // Cedente
	oPrint:Box(440, 390, 460, 550) // Agencia/Codigo Cedente
		
	oPrint:Box(460, 025, 480, 098) // Data Documento
	oPrint:Box(460, 098, 480, 171) // Numero documento
	oPrint:Box(460, 171, 480, 244) // Especie Documento
	oPrint:Box(460, 244, 480, 317) // Aceite
	oPrint:Box(460, 317, 480, 390) // Data Processamento
	oPrint:Box(460, 390, 480, 550) // Nosso Numero
	
	oPrint:Box(480, 025, 500, 068) // Uso do Banco
	oPrint:Box(480, 068, 500, 098) // CIP
	oPrint:Box(480, 098, 500, 141) // Carteira
	oPrint:Box(480, 141, 500, 171) // Moeda
	oPrint:Box(480, 171, 500, 244) // Especie
	oPrint:Box(480, 244, 500, 317) // Quantidade
	oPrint:Box(480, 317, 500, 390) // Valor Documento
	oPrint:Box(480, 390, 500, 550) // Valor Documento
	
	oPrint:Box(500, 025, 600, 390) // Instruções 
	oPrint:Box(500, 390, 520, 550) // Descontos / Abatimentos
	oPrint:Box(520, 390, 540, 550) // Outras Deduções
	oPrint:Box(540, 390, 560, 550) // Mora / Multa
	oPrint:Box(560, 390, 580, 550) // Outros Acrescimos
	oPrint:Box(580, 390, 600, 550) // Valor Cobrado
	
	oPrint:Box(600, 025, 640, 550) // Sacado
	
	oPrint:Line(630, 390, 640, 390) // Linha do codigo do banco
	
	
	//+----------------------------+
	//|Layout - Informativo Boleto |
	//+----------------------------+
	If File(cBitMapBanco)
		oPrint:SayBitmap(033, 025, cBitMapBanco, 100,025 )
	Else
		oPrint:Say(055, 025, AllTrim(SA6->A6_NOME), oFont16)
	EndIf
	
	//-----------------+
	// Codigo do Banco |
	//-----------------+
	oPrint:Say(056, 143, cNumBanco + "-2", oFont16)
	
	//-----------------+
	// Linha Digitavel |
	//-----------------+
	oPrint:Say(056, 390, "Recibo do Sacado"				, oFont14, 100 )
	
	oPrint:Say(066,027, "Local de Pagamento"			,oFont6,100)		// Local de Pagamento
	oPrint:Say(066,392, "Vencimento"					,oFont6,100)		// Vencimento
	oPrint:Say(086,027, "Nome Beneficiario"				,oFont6,100)		// Cedente 
	oPrint:Say(086,392, "Agencia/Código Beneficiario"	,oFont6,100)		// Agencia Codigo do Cedente
	oPrint:Say(106,392, "Para uso do Banco"				,oFont6,100)		// Para uso d banco
	
	oPrint:Say(126,027, "Data do Documento"				,oFont6,100)		// Data do Documento
	oPrint:Say(126,100, "Número Documento"				,oFont6,100)		// Numero do Documento
	oPrint:Say(126,173, "Espécie Documento"				,oFont6,100)		// Especie Documento
	oPrint:Say(126,246, "Aceite"						,oFont6,100)		// Aceite
	oPrint:Say(126,319, "Data Processamento"			,oFont6,100)		// Data Processamento
	oPrint:Say(126,393, "Carteira/Nosso Número"			,oFont6,100)		// Nosso Numero
	
	oPrint:Say(146,027, "Uso do Banco"					,oFont6,100)		// Uso do Banco
	oPrint:Say(146,070, "CIP"							,oFont6,100)		// CIP
	oPrint:Say(146,100, "Carteira"						,oFont6,100)		// Carteira
	oPrint:Say(146,143, "Moeda"							,oFont6,100)		// Moeda
	oPrint:Say(146,173, "Espécie"						,oFont6,100)		// Especie
	oPrint:Say(146,246, "Quantidade"					,oFont6,100)		// Quantidade
	oPrint:Say(146,319, "Valor Documento"				,oFont6,100)		// Valor Documento
	oPrint:Say(146,393, "(=) Valor Documento"			,oFont6,100)		// Valor Documento	
		
	oPrint:Say(166,027, "Instruções(Texto de responsabilidade do beneficiario)",oFont6,100)				// Instruções
	oPrint:Say(166,392, "(-) Descontos"					,oFont6,100)									// (-) Descontos/Abatimentos
	oPrint:Say(186,392, "(-) Outras Deduções"			,oFont6,100)									// (-) Outras Deduções
	oPrint:Say(206,392, "(+) Mora/Multa"				,oFont6,100)									// (+) Mora/Multa
	oPrint:Say(226,392, "(+) Outros Acréscimos"			,oFont6,100)									// (+) Outros Acrescimos
	oPrint:Say(246,392, "(=) Valor Cobrado"				,oFont6,100)									// (+) Valor Cobrado	
		
	oPrint:Say(266,027, "Sacado"						,oFont6,100)									// Sacado
	
	oPrint:Say(306,027, "Sacador/Avalista:"				,oFont6,100)									// Descritivo
	oPrint:Say(306,490, "Autenticação Mecânica"			,oFont6,100)									// Autenticação Mecanica
	
	oPrint:Say(346, 487, "Corte na linha pontilhada"	,oFont6,100)
	
	
	//+-----------------------+
	//|Layout - Recibo Sacado |
	//+-----------------------+
	If File(cBitMapBanco)
		oPrint:SayBitmap(394, 025, cBitMapBanco, 100,025 )
	Else
		oPrint:Say(395, 025, AllTrim(SA6->A6_NOME), oFont16)
	EndIf
	
	//-----------------+
	// Codigo do Banco |
	//-----------------+
	oPrint:Say(416, 143, cNumBanco + "-2", oFont16)
	
	//-----------------+
	// Linha Digitavel |
	//-----------------+
	oPrint:Say(416, 205, cLinDigi						,oFont14,100)
	
	oPrint:Say(426, 027, "Local de Pagamento"			,oFont6,100)			// Local de Pagamento
	oPrint:Say(426, 392, "Vencimento"					,oFont6,100)			// Vencimento
	
	oPrint:Say(446, 027, "Nome do Beneficiario"			,oFont6,100)			// Cedente
	oPrint:Say(446, 392, "Agencia/Código Beneficiario"	,oFont6,100)			// Vencimento
			
	oPrint:Say(466,027, "Data do Documento"				,oFont6,100)			// Data do Documento
	oPrint:Say(466,100, "Numero Documento"				,oFont6,100)			// Numero do Documento
	oPrint:Say(466,173, "Espécie Documento"				,oFont6,100)			// Especie Documento
	oPrint:Say(466,246, "Aceite"						,oFont6,100)			// Aceite
	oPrint:Say(466,319, "Data Processamento"			,oFont6,100)			// Data Processamento
	oPrint:Say(466,393, "Carteirra/Nosso Numero"		,oFont6,100)			// Nosso Numero
			
	oPrint:Say(486,027, "Uso do Banco"					,oFont6,100)			// Uso do Banco
	oPrint:Say(486,070, "CIP"							,oFont6,100)			// CIP
	oPrint:Say(486,100, "Carteira"						,oFont6,100)			// Carteira
	oPrint:Say(486,143, "Moeda"							,oFont6,100)			// Moeda
	oPrint:Say(486,173, "Espécie"						,oFont6,100)			// Especie
	oPrint:Say(486,246, "Quantidade"					,oFont6,100)			// Quantidade
	oPrint:Say(486,319, "Valor Documento"				,oFont6,100)			// Valor Documento
	oPrint:Say(486,392, "(=) Valor Documento"			,oFont6,100)			// Valor Documento
	
	oPrint:Say(506,027, "Instruções(Texto de responsabilidade do beneficiario)",oFont6,100)				// Instruções
	oPrint:Say(506,392, "(-) Descontos/Abatimentos"		,oFont6,100)									// (-) Descontos/Abatimentos
	oPrint:Say(526,392, "(-) Outras Deduções"			,oFont6,100)									// (-) Outras Deduções
	oPrint:Say(546,392, "(+) Mora/Multa"				,oFont6,100)									// (+) Mora/Multa
	oPrint:Say(566,392, "(+) Outros Acrescimos"			,oFont6,100)									// (+) Outros Acrescimos
	oPrint:Say(586,392, "(=) Valor Cobrado"				,oFont6,100)									// (+) Valor Cobrado
	
	oPrint:Say(606, 027, "Sacado"						,oFont6,100)									// Sacado
	oPrint:Say(636, 392, "Cód. Baixa"					,oFont6,100)									// Cód. Baixa
	
	oPrint:Say(647, 027, "Sacador/Avalista:"			,oFont6,100)									// Sacador Avalista
	oPrint:Say(647, 388, "Autenticação Mecânica"		,oFont6,100)									// Autenticação Mecânica
	oPrint:Say(647, 450, " - Ficha de Compensação"		,oFont6,100)									// Autenticação Mecânica
	
	//+----------------------------+
	//|Layout - Informativo Boleto |
	//+----------------------------+
		
	oPrint:Say(075,027, "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO", oFont8, 100 )						// Local de Pagamento
	oPrint:Say(075,392, dToc(cDtVencto)					,oFont8,100)									// Vencimento  
	oPrint:Say(095,392, cDadosCta						, oFont8, 100 )									// Agencia / Codigo Cedente
	oPrint:Say(095,027, Upper(Alltrim(SM0->M0_NOMECOM)) + " - " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oFont8,100)					// Cedente
	oPrint:Say(103,027, Upper(Alltrim(SM0->M0_ENDCOB)) + ", " + Upper(Alltrim(SM0->M0_BAIRCOB)) ,oFont8,100)									// Cedente
	oPrint:Say(111,027, Transform(SM0->M0_CEPCOB,"@R 99999-999") + " - " + Upper(Alltrim(SM0->M0_CIDCOB)) + " - " + SM0->M0_ESTCOB ,oFont8,100)	// Cedente
			
	oPrint:Say(135,027, dToc(SE1->E1_EMISSAO)										,oFont8,100)	// Data do Documento
	oPrint:Say(135,100, cNumTit + cParcela											,oFont8,100)	// Número Documento
	oPrint:Say(135,173, ""															,oFont8,100)	// Especie Documento
	oPrint:Say(135,246, "N"															,oFont8,100)	// Aceite
	oPrint:Say(135,319, dToc(SE1->E1_EMISSAO)										,oFont8,100)	// Data Processamento
	oPrint:Say(135,393, cCarteira + "/" + Transform(cNossoNum,"@R 99999999999-9")	,oFont8,100)	// Nosso Numero 
	
	cJuros := BRPCALMORA(nValorTit) + " por dia de atraso."
	
	oPrint:Say(155,027, ""															,oFont8,100)	// Uso do Banco
	oPrint:Say(155,100, cCarteira													,oFont8,100)	// Carteira
	oPrint:Say(155,143, "R$"														,oFont8,100)	// Moeda
	oPrint:Say(155,173, "REAL"														,oFont8,100)	// Especie
	oPrint:Say(155,246, ""															,oFont8,100)	// Quantidade
	oPrint:Say(155,319, ""															,oFont8,100)	// Valor Documento
	oPrint:Say(155,393, AllTrim(TransForm(nValorTit, "@E 999,999,999.99"))			,oFont8,100)	// Valor Documento	
	oPrint:Say(176, 027, cMensBol1 + cJuros											,oFont8,100)	// Instruções
	oPrint:Say(184, 027, cMensBol3													,oFont8,100)	// Instruções
	
	If SE1->E1_DECRESC > 0
		oPrint:Say(192,027, "Conceder desconto no valor de R$" + Transform(SE1->E1_DECRESC,"99,999.99"),oFont8,100)
	EndIf
	
	oPrint:Say(276, 027, Upper(AllTrim(SA1->A1_NOME)) + " - " + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")	,oFont8,100)						// Sacado
	oPrint:Say(284, 027, Upper(Alltrim(SA1->A1_ENDCOB)) + IIF(!EMPTY(SA1->A1_BAIRROC), " - " + Upper(AllTrim(SA1->A1_BAIRROC)),"")	,oFont8,100)	// Sacado
	oPrint:Say(292, 027, Capital(Alltrim(SA1->A1_MUNC)) + " - " + SA1->A1_ESTC	,oFont8,100)														// Sacado
				
	//+-----------------------+
	//|Layout - Recibo Sacado |
	//+-----------------------+
	oPrint:Say(435, 027, "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO"				,oFont8,100)		// Local de Pagamento
	oPrint:Say(435, 392, dToc(cDtVencto)											,oFont8,100)		// Vencimento
	
	oPrint:Say(455, 027, Upper(Alltrim(SM0->M0_NOMECOM))							,oFont8,100)		// Cedente
	oPrint:Say(455, 392, cDadosCta													,oFont8,100)		// Vencimento
		
	oPrint:Say(475, 027, dToc(SE1->E1_EMISSAO)										,oFont8,100)		// Data do Documento
	oPrint:Say(475, 100, cNumTit + cParcela											,oFont8,100)		// Numero do Documento
	oPrint:Say(475, 173, ""															,oFont8,100)		// Especie Documento
	oPrint:Say(475, 246, "N"														,oFont8,100)		// Aceite
	oPrint:Say(475, 319, dToc(SE1->E1_EMISSAO)										,oFont8,100)		// Data Processamento
	oPrint:Say(475, 393, cCarteira + "/" + Transform(cNossoNum,"@R 99999999999-9") 	,oFont8,100)		// Nosso Numero

	oPrint:Say(495, 027, ""															,oFont8,100)		// Uso do Banco
	oPrint:Say(495, 100, cCarteira													,oFont8,100)		// Carteira
	oPrint:Say(495, 143, "R$"														,oFont8,100)		// Moeda
	oPrint:Say(495, 173, "REAL"														,oFont8,100)		// Especie
	oPrint:Say(495, 246, ""															,oFont8,100)		// Quantidade
	oPrint:Say(495, 319, ""															,oFont8,100)		// Valor Documento
	oPrint:Say(495, 393, AllTrim(TransForm(nValorTit, "@E 999,999,999.99"))			,oFont8,100)		// Valor Documento
	
	cJuros := BRPCALMORA(nValorTit) + " por dia de atraso."
			
	oPrint:Say(515, 027, cMensBol1 + cJuros	,oFont8,100)				// Instruções
	oPrint:Say(523, 027, cMensBol3			,oFont8,100)				// Instruções
	
	If SE1->E1_DECRESC > 0
		oPrint:Say(531,027, "Conceder desconto no valor de R$" + Transform(SE1->E1_DECRESC,"99,999.99"),oFont8,100)
	EndIf
			
	oPrint:Say(615, 027, Upper(AllTrim(SA1->A1_NOME)) + " - " + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")	,oFont8,100)						// Sacado
	oPrint:Say(623, 027, Upper(Alltrim(SA1->A1_ENDCOB)) + IIF(!EMPTY(SA1->A1_BAIRROC), " - " + Upper(AllTrim(SA1->A1_BAIRROC)),"")	,oFont8,100)	// Sacado
	oPrint:Say(631, 027, Capital(Alltrim(SA1->A1_MUNC)) + " - " + SA1->A1_ESTC	,oFont8,100)														// Sacado
		
	//+-------------------------------+
	//|Impressão do  codigo de barras |
	//+-------------------------------+
	oPrint:FwMsBar("INT25" ,55, 2, cCodBar ,oPrint,.F.,,.T.,0.025,0.9,.F.,,,.F.,,,)
		
	oPrint:EndPage()

	aAdd(aInfMail,cNumTit) // Numero do titulo utilizado no boleto
	aAdd(aInfMail,SE1->E1_PREFIXO) // Serie do titulo
	aAdd(aInfMail,cParcela) // Parcela que foi impressa
	aAdd(aInfMail,SM0->M0_NOMECOM) // Nome da Beneficiario
Return

/***************************************************************************************/
/*/{Protheus.doc} SyGetNN
	Prepara o Nosso Numero verificando se o numero a ser utilizado ja existe.
	@author Douglas Telles
	@since 25/05/2016
	@version 1.0
/*/
/***************************************************************************************/
Static Function SyGetNN(cCarteira)
	
	cNumBoleto		:= SYRETSEQ() // Numero sequencial de acordo com a SEE
	cDVNossoNum		:= AllTrim(Modulo11(cCarteira + cNumBoleto,2,7)) // Digito de Verificacao do nosso numero
	
	If cDVNossoNum == "10" 
		cDVNossoNum := "P"
	EndIf
		
	If !lReimp
		While ValFaixa(cNumBoleto + cDVNossoNum,SE1->E1_AGEDEP,SE1->E1_CONTA)
			cNumBoleto := Soma1(cNumBoleto)
		EndDo

		DbSelectArea("SEE")
		RecLock("SEE",.F.)
			SEE->EE_FAXATU := StrZero(Val(cNumBoleto) + 1,11)
		MsUnlock()

		DbSelectArea("SE1")
		RecLock("SE1",.F.)
			SE1->E1_NUMBCO := cNumBoleto + cDVNossoNum //+ "5" + cDvCedente
		MsUnlock()
	EndIf

	cNossoNum	:= cNumBoleto + cDVNossoNum // Nosso numero. (Numero do boleto)
	
Return

/***************************************************************************************/
/*/{Protheus.doc} SyRetCed
	Calula Digito Verificador para Codigo do Cedente
	@author Bernard M. Margarido
	@since 15/06/2016
	@type function
/*/
/***************************************************************************************/
Static Function SyRetCed(cCodCed,cNumBoleto,cDVNossoNum)
Local cDvCed	:= ""
Local cNumBol	:= cNumBoleto + cDVNossoNum + "5"
Local cSomCed	:= SubStr(cNumBol,Len(cNumBol) - Len(cCodCed) + 1,Len(cNumBol))
Local cDigRest	:= SubStr(cNumBol,1,Len(cNumBol) - Len(cCodCed))
Local cCalcCed	:= ""

Local nSoma		:= 0

For nSoma := 1 To Len(cSomCed)
	nCalcCed := Val(SubStr(cSomCed,nSoma,1)) + Val(SubStr(cCodCed,nSoma,1))
	cCalcCed += Alltrim(Str(nCalcCed))
Next nSoma   

cDvCed := Alltrim(Modulo11(cDigRest + cCalcCed,9,2))

Return cDvCed

/***************************************************************************************/
/*/{Protheus.doc} SYRETSEQ
	Captura o numero do boleto.
	@author Douglas Telles
	@since 01/06/2016
	@version 1.0
	@return cNumero, Numero do boleto a ser utilizado.
/*/
/***************************************************************************************/
Static Function SYRETSEQ()
	Local cNumero

	If lReimp
		cNumero := StrZero(Val(cNumBol),11)
	Else
		cNumero := StrZero(Val(SEE->EE_FAXATU),11)
	EndIf
Return(cNumero)

/***************************************************************************************/
/*/{Protheus.doc} BRPCALMORA
	Calcula o valor do juros a ser cobrado.
	@author Douglas Telles
	@since 01/06/2016
	@version 1.0
	@param nValorTit, numérico, Valor do título.
	@return cRet, Valor do juros ja com a picture.
/*/
/***************************************************************************************/
Static Function BRPCALMORA(nValorTit)
	Local nPrcDia	:= SE1->E1_PORCJUR
	Local nResult	:= 0
	Local cRet		:= ''

	nResult	:= (nPrcDia * nValorTit) / 100
	cRet	:= Alltrim(Transform(nResult,"@E 999,999,999.99"))
Return(cRet)

/***************************************************************************************/
/*/{Protheus.doc} ValFaixa
	Valida a faixa da tabela de parametros de banco.
	@author Douglas Telles
	@since 25/05/2016
	@version 1.0
	@param cNum, caracter, Numero a ser validado
	@return lExist, Indica se o codigo ja existe
/*/
/***************************************************************************************/
Static Function ValFaixa(cNum,cAgencia,cConta)
	Local aBkpArea	:= GetArea()
	Local lExist		:= .F.
	Local cQry			:= ""

	cQry := "SELECT COUNT(E1_NUM) QTD" + CRLF
	cQry += "FROM " + RetSqlName("SE1") + " SE1" + CRLF
	cQry += "WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND" + CRLF
	cQry += "	E1_NUMBCO LIKE '" + AllTrim(cNum) + "'"+ CRLF
	cQry += "	AND E1_PORTADO = '237' " + CRLF
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

/***************************************************************************************/
/*/{Protheus.doc} SYORDINF
	Organiza registros consultados para utilizacao no boleto.
	@author Douglas Telles
	@since 30/05/2016
	@version 1.0
	@param aTemp, array, Array com as informações consultadas do título.
	@return aRegs, Array com os dados devidamente organizados.
/*/
/***************************************************************************************/
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