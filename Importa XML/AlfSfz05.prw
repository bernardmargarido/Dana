#include "totvs.ch"


User Function XmlChkPFX( cFullPath, cPass)

Local   aRet     := {}
Local   cCliente := ""
Local   cEmissor := ""
Local   xDtINI
Local   xDtFIM
Private aPFX

	aPFX := PFXInfo( cFullPath, cPass )		// cFullPath -

	if valType(aPFX) == "A"
		nPos := AT( "/CN=", aPFX[1,2] )
		if nPos > 0
			cCliente := Substr(aPFX[1,2], nPos+4)
		endif

		nPos := AT( "/CN=", aPFX[1,3] )
		if nPos > 0
			cEmissor := Substr(aPFX[1,3], nPos+4)
		endif

		xDtINI   := StoD( "20"+ left( aPFX[1,4], 6 ) )
		xDtFIM   := StoD( "20"+ left( aPFX[1,5], 6 ) )

		if xDtFim < dDatabase
			aadd( aRet, .F. )	// deu zebra...
		else
			aadd( aRet, .T. )
		endif

		aadd( aRet, cCliente )
		aadd( aRet, cEmissor )
		aadd( aRet, xDtINI   )
		aadd( aRet, xDtFIM   )

	else
		aadd( aRet, .F. )	// deu zebra...
		aadd( aRet, "Falha na obtenção da informações do Certificado, verifique senha" )
	endif

return aClone( aRet )


//---------------------------
User Function GetCertPFX( cCmpArq, cArqPFX, _cSenha, lExibe ,cCNPJ,cServico)

Local   aRet
Local   cMsg
Local   nDias
Default lExibe 	:= .T.
Default cCNPJ	:= ""
Default cServico := ""

	aRet := U_XmlChkPFX( cCmpArq+cArqPFX, Alltrim(_cSenha),cCNPJ )

	if len( aRet ) > 2 .and. lExibe


		cMsg := "Certificado: " + aRet[2] + CRLF
		cMsg += "Emissor: " + aRet[3] + CRLF
		cMsg += "de " + DtoC( aRet[4] ) + " a " + DtoC( aRet[5] )  + CRLF
		cMsg += "CNPJ Corrente: "+cCNPJ+CRLF+CRLF
		cMsg += "Continua?"
		If cServico == "1"
			if Aviso("Validação Certificado Digital", cMsg, {"Ok","Cancela"}, 2) != 1
				cMsg := "Cert.Digital - Operacao cancelada pelo usuario!"
				conout( "XML Automático: " + cMsg + DtoC( Date() ) + " " + Time() )
				return { cMsg }
			endif
		EndIf
	endif

	if ! aRet[1]
		cMsg := "Problemas com o certificado. verifique!"
		conout( "XML Automático: " + cMsg + DtoC( Date() ) + " " + Time() )
		if lExibe
			Alert(cMsg)
		endif
		return { cMsg }
	endif

	nDias := aRet[5] - Date()
	if nDias < 0
		cMsg := "Certificado Digital EXPIRADO!"
		conout( "XML Automático: " + cMsg + DtoC( Date() ) + " " + Time() )
		if lExibe
			Alert(cMsg)
		endif
		return { cMsg }
	endif

	if nDias <= 15
		cMsg := "Certificado Digital vai expirar em "+DtoC( aRet[5] )
		conout( "XML Automático: " + cMsg + DtoC( Date() ) + " " + Time() )
		if lExibe
			Alert(cMsg)
		endif
	endif


	cPFX   := Lower(Alltrim(cCmpArq)+Alltrim(cArqPfx))
	cCert  := Strtran(cPFX,".pfx","_cert.pem")
	cKey   := Strtran(cPFX,".pfx","_key.pem")

	cError := ""
	lRet := PFXCert2PEM( cPFX, cCert, @cError, Alltrim(_cSenha) )
	If ! lRet
		cMsg := "Error: " + cError
		conout("XML Automático: " + cMsg + DtoC( Date() ) + " " + Time() )
		if lExibe
			Alert(cMsg)
		endif
	Endif

	cError := ""
	lRet := PFXKey2PEM( cPFX, cKey, @cError, Alltrim(_cSenha) )
	If( lRet == .F. )
		cMsg := "Error: " + cError
		conout( "XML Automático: " + cMsg + DtoC( Date() ) + " " + Time() )
		if lExibe
			Alert(cMsg)
		endif
	Endif

return { cCert, cKey }


//-----------------------------------------------
User Function XmlPFXChk()
Local cVarCurr := readVar()
Local cVarVal  := &( cVarCurr )
Local cCmpArq  := ""

	if File( cVarCurr )
		return .T.
	endif

	if Empty( cVarCurr )
		alert("Favor preencher o certificado digital!")
	endif

	cCmpArq := cGetFile('Arquivos (*.pfx)|*.pfx' , 'Selecione o Arquivo a ser convertido, extensão .PFX',1,"/",.T.,GETF_ONLYSERVER,.T.,.T.)

    if Empty(cCmpArq)
    	Return .F.
    endif

	&( cVarCurr ) := cCmpArq

return .T.



User Function tstXmlAut()
Local oDlg
Local aArea := GetArea()
Private cAlias1 := ""
Private cAlias2 := ""
Private cAlias3 := ""
Private cAlias4 := ""
Private cAlias5 := ""
Private cAlias6 := ""
Private cAlias7 := ""
Private cAlias8 := ""
Private cAlias9 := ""

	DEFINE MSDIALOG oDlg TITLE "Teste na rotina XML" FROM 0,0 TO 100,415 PIXEL

	@ 15,010 Button "test E-mail" Size 50,15 Pixel of oDlg  Action MsgRun("Testando E-mail", "Aguarde...", {|| chkEmail()} )
	@ 15,080 Button "test Sefaz"  Size 50,15 Pixel of oDlg  Action MsgRun("Testando Sefaz", "Aguarde...", {|| chkSefaz()} )
	@ 15,150 Button "Gerar .PEM"  Size 50,15 Pixel of oDlg  Action GerPEM()

	ACTIVATE MSDIALOG oDlg CENTER

	RestArea(aArea)

Return nil


//-------------------------------------------------------------------
Static Function chkEmail()
Local   oServer					// objeto Servidor de E-mail
Local   cServerPop				// Servidor POP
Local   cServerSMTP 			// Servidor SMTP
Local   cUserPop					// conta do usuário
Local   cSenhaPop				// senha do usuário
Local   nPortaPop				// Porta POP
Local   nPortaSmtp				// Porta SMTP
Local   lUseSSL					// usa SSL
Local   lUseTLS 					// usa TLS
Local   lAutentica				// Necessita de autenticação de e-mail
Local   nNumMsg    := 0		// Nº de mensagens na caixa de entrada
Local   nI
Local   nIniMsg    := 1		// Variável de início das mensagens, caso caia o Job, retoma da próxima mensagem.
Local   lRet       := .T.
Local   cMsg       := ""
Local   nRet

	//ProcessMessages()

	cMsg += "*** Checagem de e-mail ***"+CRLF+CRLF

	u_CR02M015( "SET", .F. /* Job */ )	// Criação de Parâmetros necessários para a rotina

	if ! SuperGetMV( "AF_XMLMAIL", , .F. )		// parâmetro desligado
		cMsg += "Parametro CR_XMLMAIL desligado - não vai funcionar"+CRLF
	endif

	cAlias1 := U_RETMV("ZZO")
	cAlias2 := U_RETMV("ZZP")
	cAlias3 := U_RETMV("ZZH")
	cAlias4 := U_RETMV("ZZL")
	cAlias5 := U_RETMV("ZD4")
	cAlias6 := U_RETMV("ZD9")
	cAlias7 := U_RETMV("ZZG")
	cAlias8 := U_RETMV("ZZI")
	cAlias9 := U_RETMV("ZZN")

	cServerPop  := SuperGetMV( "CR_XMLPOP" , , "" )		// Busca dados da conta POP para leitura da caixa de entrada
	cServerSMTP := SuperGetMV( "CR_XMLSMTP", , "" )		// Busca dados da conta SMTP
	cUserPop    := SuperGetMV( "CR_XMLUSR" , , "" )		// Usuário da conta
	cSenhaPop   := SuperGetMV( "CR_XMLPSW" , , "" )		// Senha do usuário
	nPortaPop   := SuperGetMV( "CR_XMLPPOP", ,  0 )		// Porta POP
	nPortaSmtp  := SuperGetMV( "CR_XMLPSMT", ,  0 )		// Porta SMTP
	lUseSSL     := SuperGetMV( "CR_XMLSSL" , , .F.)		// Usa SSL
	lUseTLS     := SuperGetMV( "CR_XMLTLS" , , .F.)		// Usa TLS
	lAutentica  := SuperGetMV( "CR_XMLAUTM", , .F.)		// Necessita Autenticação de e-mail

	cMsg += "Param: CR_XMLPOP:  "+cServerPop  +CRLF
	cMsg += "Param: CR_XMLSMTP: "+cServerSMTP +CRLF
	cMsg += "Param: CR_XMLUSR:  "+cUserPop    +CRLF
	cMsg += "Param: CR_XMLPSW:  "+cSenhaPop   +CRLF
	cMsg += "Param: CR_XMLPPOP: "+Alltrim(Str(nPortaPop )) +CRLF
	cMsg += "Param: CR_XMLPSMT: "+Alltrim(Str(nPortaSmtp)) +CRLF
	cMsg += "Param: CR_XMLSSL:  "+iif(lUseSSL   ,"Sim","Não") +CRLF
	cMsg += "Param: CR_XMLTLS:  "+iif(lUseTLS   ,"Sim","Não") +CRLF
	cMsg += "Param: CR_XMLAUTM: "+iif(lAutentica,"Sim","Não") +CRLF

	oServer := TMailManager():New()	// instância objeto e-mail do protheus

	oServer:SetUseSSL( lUseSSL )
	oServer:SetUseTLS( lUseTLS )

	oServer:Init( cServerPop, cServerSMTP, cUserPop, cSenhaPop, nPortaPop, nPortaSmtp)		// Logando no Servidor de E-mail

	nRet := oServer:POPConnect()
	if nRet != 0
		cMsg += "Problema: Não conectou Servidor POP"+ CRLF
		cMsg += oServer:GetErrorString( nRet ) + CRLF
		lRet := .F.
	else

		cMsg += "Conectado no servidor POP!!!"+ CRLF

		oServer:GetNumMsgs( @nNumMsg )			// obtém nº de e-mails não lidos
		cMsg += "Existem "+Alltrim(Str(nNumMsg))+" mensagens no servidor" + CRLF

		oServer:PopDisconnect()

		oServer  := nil
	endif

	if File("\System\CR02A011.txt")
		if FT_FUse("\System\CR02A011.txt") != -1
			while !FT_FEOF()
				nIniMsg := Val( FT_FREADLN() )
				FT_FSKIP()
		  	end
		  	FT_FUSE()
		endif
		cMsg += "arquivo \System\CR02A011.txt existe e seu conteúdo é: "+Alltrim(Str(nIniMsg))+ CRLF
	endif


	cFile   := getTempPath() + "\tstXmlAutEmail.txt"

	cMsg    := "O retorno foi "+iif(lRet,"Positivo","Negativo")+CRLF+CRLF+cMsg

	MemoWrite( cFile, cMsg )

	ShellExecute("open", cFile,"","",1)

Return Nil


//-------------------------------------------------------------------
Static Function chkSefaz()
Local   aEmpresa := {}
Local   aStru    := {}
Local   cArqTrab
Local   aParam
Local   nI, nJ
Local   oRet
Local   aAreaSM0 := SM0->( getArea() )
Local   _cEmpAnt := cEmpAnt
Local   _cFilAnt := cFilAnt
Local   cMsg     := ""

Private oTmp
Private _TstXml := ""

	//ProcessMessages()

	cMsg += "*** Checagem Sefaz ***"+CRLF+CRLF

	//u_CR02M015( "set", .F. /* job */ )	// Criação de Parâmetros necessários para a rotina

	if ! SuperGetMV( "CR_XMLSEFA", , .F. )		// parâmetro desligado
		cMsg += "Parametro CR_XMLSEFA desligado, rotina não vai funcionar" + CRLF
	endif

	cMsg += CRLF+"Empresas e pesquisa de certificados:"+CRLF

// Carga dos CNPJs - só raíz (primeiros 8 dígitos do CNPJ)
	SM0->( dbGotop() )
	while ! SM0->( EOF() )
		if ! Empty( SM0->M0_CGC ) //.and. aScan( aEmpresa, {|x| Left( x[1], 8) == Left( SM0->M0_CGC, 8 ) } ) == 0

			cMsg += "CNPJ: "+SM0->M0_CGC+" - Empresa: "+SM0->M0_CODIGO+" - Filial: "+SM0->M0_CODFIL+CRLF
			cEmpAnt := SM0->M0_CODIGO
			cFilAnt := SM0->M0_CODFIL


			PutGlbValue("cID_PAR", "")	// variavel para pegar o ID da empresa na configuracao SPED
			cIdEnt := ""

			_lRet  := StartJob("U_TSTXMLID",GetEnvServer(),.T., { cEmpAnt, cFilAnt, SM0->( Recno() ) })
			If _lRet
				cIdEnt := GetGlbValue("cID_PAR")
			endif

//			cIdEnt := GetIdEnt()
			If !Empty(cIdEnt)
				cMsg += "........ Identificação no SPED: "+cIdEnt + CRLF
			else
				cMsg += "........ não encontrou identificação no SPED!" + CRLF
			endif

			aadd( aEmpresa, {SM0->M0_CGC, SM0->M0_CODIGO, SM0->M0_CODFIL, CodUF( SM0->M0_ESTCOB ), SM0->( RECNO() ) } )	// [1]=CNPJ; [2]=Código da Empresa; [3]=Código da Filial; [4]=UF
		endif
		SM0->( dbSkip() )
	end

	if len(aEmpresa) > 0
		cMsg += CRLF+"Empresas e Certificados:"+CRLF
		for nI := 1 to len(aEmpresa)
			cMsg += StrZero(nI,3)+ " - CNPJ: "+aEmpresa[nI][1]+" - Empresa: "+aEmpresa[nI][2]+" - Filial: "+aEmpresa[nI][3]+CRLF

			dbSelectArea(cAlias4)
			if dbSeek( xFilial(cAlias4) + Left(aEmpresa[nI][1], 8) )
				cPathCert := Alltrim( &(cAlias4+"_PCERT") )
				cPathPKey := Alltrim( &(cAlias4+"_PKEY") )
				cPassword := Alltrim( &(cAlias4+"_PSS") )

				cMsg += "..... Certificado: "+cPathCert + CRLF
				cMsg += "..... Private Key: "+cPathPKey + CRLF
				cMsg += "..... Senha      : "+cPassword + CRLF

				if !File( cPathCert )
					cMsg += "..... Certificado não encontrado, deve ser um arquivo (.pem) dentro da Protheus_Data!" + CRLF
				endif
				if !File( cPathPKey )
					cMsg += "..... Private Key não encontrado, deve ser um arquivo (.pem) dentro da Protheus_Data!" + CRLF
				endif
			else
				cMsg += "..... Não encontrada Informações sobre o Certificado!"+CRLF
			endif

		next
		cMsg += CRLF
	else
		cMsg += "Não tem empresas cadastradas com Manifestação Ativa" + CRLF
	endif

// laço para pesquisa das chaves por raíz de CNPJ
	for nI := 1 to len(aEmpresa)

		oRet   := nil
		aParam := { aEmpresa[nI][1] ,;	// CNPJ
		            aEmpresa[nI][4] }		// Cod UF

		SM0->( dbGoto( aEmpresa[nI][5] ) )

		cMsg += "Pesquisando Chave para CNPJ: "+ aEmpresa[nI][1] +CRLF
		_TstXml := ""

		U_AlfSfz01( "3", aParam, @oRet)		// Pesquisa Chaves XML para o CNPJ
		If Empty(_TstXml)
			cMsg += "..............Falha na pesquisa"+CRLF
		Elseif Left(_TstXml, 6) != "RESP: "								// Retornou valores
			cMsg += "..............Existem chaves a serem baixadas"+CRLF
		Else
			cMsg += ".............." + Alltrim(_TstXml) +CRLF
		EndIf

	next

	SM0->( restArea( aAreaSM0 ) )
	cEmpAnt := _cEmpAnt
	cFilAnt := _cFilAnt


	cFile   := getTempPath() + "\tstXmlAutSefaz.txt"

	cMsg    := "O retorno foi: "+CRLF+CRLF+cMsg

	MemoWrite( cFile, cMsg )

	ShellExecute("open", cFile,"","",1)

Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetIdEnt  ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetIdEnt()
Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := ""		// UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf

	oWs := nil
	DelClassIntf()	// Exclui todas classes de interface da thread

	RestArea(aArea)
Return(cIdEnt)


//===========================================================================================
Static Function CodUF( cUF )
Local cRet := '91'
Local aUF  := { {'11','RO','RONDÔNIA'} ,;
                {'12','AC','ACRE'} ,;
                {'13','AM','AMAZONAS'} ,;
                {'14','RR','RORAIMA'} ,;
                {'15','PA','PARÁ'} ,;
                {'16','AP','AMAPÁ'} ,;
                {'17','TO','TOCANTINS'} ,;
                {'21','MA','MARANHÃO'} ,;
                {'22','PI','PIAUÍ'} ,;
                {'23','CE','CEARÁ'} ,;
                {'24','RN','RIO GRANDE DO NORTE'} ,;
                {'25','PB','PARAÍBA'} ,;
                {'26','PE','PERNAMBUCO'} ,;
                {'27','AL','ALAGOAS'} ,;
                {'28','SE','SERGIPE'} ,;
                {'29','BA','BAHIA'} ,;
                {'31','MG','MINAS GERAIS'} ,;
                {'32','ES','ESPIRITO SANTO'} ,;
                {'33','RJ','RIO DE JANEIRO'} ,;
                {'35','SP','SÃO PAULO'} ,;
                {'41','PR','PARANÁ'} ,;
                {'42','SC','SANTA CATARINA'} ,;
                {'43','RS','RIO GRANDE DO SUL'} ,;
                {'50','MS','MATO GROSSO DO SUL'} ,;
                {'51','MT','MATO GROSSO'} ,;
                {'52','GO','GOIÁS'} ,;
                {'53','DF','DISTRITO FEDERAL'} }

	if ( nPos := aScan( aUF, { |x| x[2] == cUF } ) ) > 0
		cRet := aUF[ nPos ][ 1 ]
	endif

Return cRet


//---------------------------------
User Function TSTXMLID( _aParam )
Local _cEmp   := _aParam[1]
Local _cFil   := _aParam[2]
Local nRecSM0 := _aPAram[3]

	RpcSetType(3)
	RpcSetEnv( _cEmp ,_cFil,,,"FAT", GetEnvServer())
	SetModulo( "SIGAFAT", "FAT" )

	SM0->( dbGoto( nRecSM0 ) )

	cIdEnt := GetIdEnt()

	PutGlbValue("cID_PAR", cIdEnt)	// Alimenta ID do Sped

Return .T.


//---------------------------------
Static function GerPEM()
Local   oDlg
Local   oFont    :=TFont():New("Arial",,24,,.T.,,,,.T.,.F.)

Local   cPFX     := "\certs\certificado a1 iv.pfx"
Local   cCert    := "\certs\certIV.pem"
Local   cKey     := "\certs\keyIV.pem"
Local   cPasta   := ""
Local   cSenha   := Space(30)
Local   cContent := ""
Local   cError   := ""
Local   lRet     := .F.

Private cNomArq := "", cCmpArq := "", oSayTrN		// Variáveis do arquivo a ser importado

	DEFINE MSDIALOG oDlg TITLE "Geração Certificado .PEM" FROM 0,0 TO 200,450 OF oMainWnd PIXEL

	@ 10, 10 Say "Senha do certificado:" of oDlg Pixel
	@ 09, 70 msGet cSenha Picture "@X" size 80,8 of oDlg Pixel

	@ 29,10 Say "Arquivo a ser convertido:" of oDlg Pixel
	oSayTrN := tSay():New(C(030),C(010),{|| iif(Empty(cNomArq),'não há arquivo vinculado',cNomArq)},oDlg,,oFont,,,,.T.,CLR_BLUE,,200,20)

	oBtn1:=tButton():New(C(050),C(010),'Selec.PFX',oDlg,{|| fVincArq()},50,20,,,,.T.)
	oBtn3:=tButton():New(C(050),C(060),'Gerar .PEM',oDlg,{||lRet := .T., oDlg:End()},50,20,,,,.T.)
	oBtn4:=tButton():New(C(050),C(120),'Fechar',oDlg,{||oDlg:End()},50,20,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

	if lRet
		if Empty(cCmpArq)
			Alert("O arquivo deve ser informado. verifique!")
			return nil
		endif

		if Empty(cSenha)
			Alert("A senha deve ser informada. verifique!")
			return nil
		endif

		if ! File(cCmpArq)
			Alert("O Arquivo "+cCmpArq+" não foi encontrado, verifique!")
			return nil
		else
			cPFX   := Lower(cCmpArq)
			cCert  := Strtran(cPFX,".pfx","_cert.pem")
			cKey   := Strtran(cPFX,".pfx","_key.pem")

			lRet := PFXCert2PEM( cPFX, cCert, @cError, Alltrim(cSenha) )

			If( lRet == .F. )
				conout( "Error: " + cError )
			Else
				cContent := MemoRead( cCert )
				varinfo( "Cert", cContent )
			Endif

			cError := ""
			lRet := PFXKey2PEM( cPFX, cKey, @cError, Alltrim(cSenha) )
			If( lRet == .F. )
				conout( "Error: " + cError )
			Else
				cContent := MemoRead( cKey )
				varinfo( "Key", cContent )
			Endif

			if lRet
				MsgInfo("Geração concluída com Êxito" , "Geração Certif .PEM")
			else
				MsgAlert("Geração concluída com Falha", "Geração Certif .PEM")
			endif

		endif
	endif

return nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fVincArq  ºAutor  ³Cristiam Rossi      º Data ³  08/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Vincula arquivo+localização completa do espelho da rota    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DANFAB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fVincArq()
	cCmpArq := cGetFile('Arquivos (*.pfx)|*.pfx' , 'Selecione o Arquivo a ser convertido, extensão .PFX',1,"/",.T.,GETF_ONLYSERVER,.T.,.T.)

    if Empty(cCmpArq)
    	Return .F.
    endif

	cNomArq := fNomArq(cCmpArq, "\")	// Retorna o nome do arquivo

	oSayTrN:SetText(cNomArq)
	oSayTrN:Refresh()
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fNomArq   ºAutor  ³Cristiam Rossi      º Data ³  08/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna parte do nome do arquivo digitalizado              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DANFAB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fNomArq(cPar, cToken)
Local nPos  := 0
Local cFile := ""

	if (nPos := RAT(cToken, StrTran(cPar,"/","\"))) != 0
		cFile := SubStr(cPar, nPos+1)
	endif
Return cFile
