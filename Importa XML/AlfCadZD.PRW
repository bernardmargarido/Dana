#Include "Totvs.Ch"
/*/
{Protheus.doc}	AlfCdZDG
Description 	Cadastro de Configuracao do Certificado Digital
@param			Nenhum
@return			Nil
@author			
@since			31/10/2017
/*/
User Function AlfCdZDG()

Local cFiltro			:= ""
Private cCadastro  		:= "Configuração XML"
Private aRotina    		:= MnuADef()

U_ALFVCXML()

dbSelectArea("ZDG")
ZDG->(dbSetOrder(1))
ZDG->(dbGotop())

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("ZDG")
oBrowse:SetDescription( cCadastro ) 
oBrowse:SetFilterDefault( cFiltro )  
oBrowse:Activate()

Return(Nil)


/*/
{Protheus.doc}	MnuADef
Description 	Opcoes do Menu do Browse
@param			Nenhum
@return			Array com os opcoes do menu
@author			
@since			31/10/2017
/*/
Static Function MnuADef()

Local aRot := {}

aAdd( aRot ,{"Pesquisar"		, "AxPesqui"		,0,1 })
aAdd( aRot ,{"Visualizar"	    , "U_AlfCdXML('V')"	,0,2 })
aAdd( aRot ,{"Incluir"  		, "U_AlfCdXML('I')"	,0,3 })
aAdd( aRot ,{"Alterar"  		, "U_AlfCdXML('A')"	,0,4 })
aAdd( aRot ,{"Excluir"   	    , "U_AlfCdXML('E')"	,0,5 })

Return(aRot)



/*/
{Protheus.doc}	AlfCdXML
Description 	Tela para manutencao do Cadastro de Configuracoes do XML (Certificado Digital)
@param			Nenhum
@return			Nil
@author			
@since			31/10/2017
/*/
User Function AlfCdXML(cOpt)

Local oBtOK, oBtSair, oGt1Psw, oGt2Psw, oGtCAM, oGtCERT, oGtCNPJ, oGtKEY, oGtPFX, oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7, oDgZDG := Nil
Local oFnt1 := TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
Local cGtCNPJ := Space(14)
Local cGtCERT := Space(50)
Local cGtKEY  := Space(50)
Local cGtCAM  := Space(200)
Local cGtPFX  := Space(50)
Local cGt2Psw := Space(50)
Local cGt1Psw := Space(50)
Local cTitTela:= ""
Local lEdit	  := .T.
Local lEdChv  := .T.
Default cOpt  := "V"

If cOpt == "V"
	cTitTela := "Visualizacao"
	lEdit := .F.
	lEdChv := .F.
ElseIf cOpt == "I"
	cTitTela := "Inclusao"
ElseIf cOpt == "A"
	cTitTela := "Alteracao"
	lEdChv := .F.
ElseIf cOpt == "E"
	cTitTela := "Exclusao"
	lEdit := .F.
	lEdChv := .F.
EndIf

If cOpt <> "I"
	dbSelectArea("ZDG")
	ZDG->(dbSetOrder(1))
	cGtCNPJ := PadR(ZDG->ZDG_CONTA,14)
	cGtCERT := PadR(ZDG->ZDG_PCERT,50)
	cGtKEY  := PadR(ZDG->ZDG_PKEY,50)
	cGtCAM  := PadR(ZDG->ZDG_CAMPEM,200)
	cGtPFX  := PadR(ZDG->ZDG_ARQCER,50)
	cGt1Psw := PadR( RC4Crypt(Alltrim( ZDG->ZDG_PSS) ,"731296548", .F.) ,50)
	cGt2Psw := cGt1Psw
	If cOpt $ "|A|E|"
		If ZDG->(!MsRLock(ZDG->(RecNo())))
			Alert("Este registro já está uso por outra estacao, não será possível "+Iif(cOpt=="A","altera-lo.","exclui-lo."))
		EndIf
	EndIf
EndIf

DEFINE MSDIALOG oDgZDG TITLE "Config. Import. XML - "+cTitTela FROM 000, 000  TO 400, 500 COLORS 0, 16777215 PIXEL

    @ 005, 007 SAY oSay1 PROMPT "CNPJ *" SIZE 043, 007 OF oDgZDG FONT oFnt1 COLORS 16711680, 16777215 PIXEL
    @ 012, 007 MSGET oGtCNPJ VAR cGtCNPJ When lEdChv SIZE 233, 010 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    @ 029, 007 SAY oSay2 PROMPT "Nome do Arquivo _CERT" SIZE 234, 007 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    @ 036, 007 MSGET oGtCERT VAR cGtCERT When lEdit SIZE 233, 010 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    @ 052, 007 SAY oSay3 PROMPT "Nome do Arquivo _KEY" SIZE 233, 007 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    @ 059, 007 MSGET oGtKEY VAR cGtKEY When lEdit SIZE 233, 010 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    @ 076, 007 SAY oSay4 PROMPT "Nome do Arquivo .PFX *" SIZE 233, 008 OF oDgZDG FONT oFnt1 COLORS 16711680, 16777215 PIXEL
    @ 083, 007 MSGET oGtPFX VAR cGtPFX When lEdit SIZE 233, 010 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    @ 103, 007 SAY oSay5 PROMPT "Pasta dos Arquivos do Certificado Digital no Servidor *" SIZE 237, 007 OF oDgZDG FONT oFnt1 COLORS 16711680, 16777215 PIXEL
    @ 111, 007 MSGET oGtCAM VAR cGtCAM When lEdit SIZE 233, 010 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    @ 132, 007 SAY oSay6 PROMPT "Senha do Certificado Digital *" SIZE 230, 007 OF oDgZDG FONT oFnt1 COLORS 16711680, 16777215 PIXEL
    @ 140, 007 MSGET oGt1Psw VAR cGt1Psw Password When lEdit SIZE 233, 010 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    @ 155, 007 SAY oSay7 PROMPT "Confirme a Senha do Certificado Digital *" SIZE 231, 007 OF oDgZDG FONT oFnt1 COLORS 16711680, 16777215 PIXEL
    @ 162, 007 MSGET oGt2Psw VAR cGt2Psw Password When lEdit SIZE 233, 010 OF oDgZDG FONT oFnt1 COLORS 0, 16777215 PIXEL
    If cOpt <> "V"
    	@ 182, 103 BUTTON oBtOK PROMPT "Confirma" SIZE 065, 012 FONT oFnt1 Action(Iif(GrvZDG(cOpt,cGtCNPJ,cGtCERT,cGtKEY,cGtPFX,@cGtCAM,cGt1Psw,cGt2Psw),oDgZDG:End(),oDgZDG:Refresh())) OF oDgZDG PIXEL
    EndIf
    @ 182, 176 BUTTON oBtSair PROMPT "Sair" SIZE 065, 012 FONT oFnt1 Action(oDgZDG:End()) OF oDgZDG PIXEL

ACTIVATE MSDIALOG oDgZDG CENTERED

If cOpt $ "|A|E|"
	ZDG->(MsUnLock())
EndIf

Return(Nil)



/*/
{Protheus.doc}	GrvZDG
Description 	Valida e grava os campos preenchidos na tela
@param			cOpt, cGtCNPJ, cGtCERT, cGtKEY, cGtPFX, cGtCAM, cGt1Psw, cGt2Psw
@return			.T. ou .F.
@author			
@since			31/10/2017
/*/
Static Function GrvZDG(cOpt,cGtCNPJ,cGtCERT,cGtKEY,cGtPFX,cGtCAM,cGt1Psw,cGt2Psw)

Local aSM0Area := {}
Local aChkPFX := {}
Local lRet := .T.
Local lAchouCNPJ := .F.
Local cMsgEr := ""
Local cMsgOk := ""
Local cMsgPFx := ""

If Empty(Alltrim(cGt1Psw)) .Or. Empty(Alltrim(cGt2Psw))
	lRet := .F.
	cMsgEr := "Os campos referentes a senha sao obrigatorios"
EndIf

If lRet
	If Alltrim(cGt1Psw) <> Alltrim(cGt2Psw)
		lRet := .F.
		cMsgEr := "As senhas não conferem"
	EndIf
EndIf	
	
If lRet

	If cOpt $ "|I|A|"
	
		If Empty(cGtCNPJ)
			lRet := .F.
			cMsgEr := "O CNPJ é obrigatorio."
		EndIf

		If lRet

			If Len(Alltrim(cGtCNPJ)) < 14

				lRet := .F.
				cMsgEr := "Informe o CNPJ completo"

			Else

				aSM0Area := SM0->(GetArea())
				dbSelectArea("SM0")
				SM0->(dbSetOrder(1))
				While SM0->(!EoF()) .And. SM0->M0_CODIGO == cEmpAnt
					If SM0->M0_CGC == cGtCNPJ
						lAchouCNPJ := .T.
					EndIf
					SM0->(dbSkip())
				EndDo
				RestArea(aSM0Area)
				
				If !lAchouCNPJ
					lRet := .F.
					cMsgEr := "O CNPJ informado nao foi encontrado no cadastro de empresas."
				Else
					If cOpt == "I"
						If ChkZDG(cGtCNPJ)
							lRet := .F.
							cMsgEr := "Já existe configuração para este CNPJ."
						EndIf
					EndIf
				EndIf

			EndIf
		EndIf	

		If lRet
			If Empty(cGtCAM)
				lRet := .F.
				cMsgEr := "Informe o caminho (pasta)dos arquivos do Certificado Digital, no servidor Protheus (ex. \data\certs\)."
			EndIf
		Else
			If SubStr(Alltrim(cGtCam),Len(Alltrim(cGtCam)),1) <> "\"
				cGtCam := PadR(Alltrim(cGtCam)+"\",50)
			EndIf
		EndIf
		
		If lRet
			If Empty(cGtPFX)
				lRet := .F.
				cMsgEr := "O nome do arquivo do Certificado Digital .PFX é obrigatório."
			EndIf
		EndIf
		
		If lRet
			If !File(Alltrim(cGtCAM)+Alltrim(cGtPFX))
				lRet := .F.
				cMsgEr := "Arquivo .PFX não encontrado na pasta, ou o nome do arquivo foi informado errado."
			EndIf
		EndIf
				
		If lRet
			If !Empty(cGtCERT)
				If !( "CERT" $ Upper(Alltrim(cGtCERT)) )
					lRet := .F.
					cMsgEr := "O nome do arquivo _CERT informado é invalido."
				EndIf
				If lRet
					If !File(Alltrim(cGtCAM)+(cGtCERT))
						lRet := .F.
						cMsgEr := "Arquivo _CERT não encontrado na pasta, ou o nome do arquivo foi informado errado."
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			If !Empty(cGtKEY)
				If !( "KEY" $ Upper(Alltrim(cGtKEY)) )
					lRet := .F.
					cMsgEr := "O nome do arquivo _KEY informado é invalido."
				EndIf
				If lRet
					If !File(Alltrim(cGtCAM)+Alltrim(cGtKEY))
						lRet := .F.
						cMsgEr := "Arquivo _KEY não encontrado na pasta, ou o nome do arquivo foi informado errado."
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			aChkPFX := U_XmlChkPFX( Alltrim(cGtCAM)+Alltrim(cGtPFX), Alltrim(cGt1Psw) )
			If aChkPFX[1]
				cMsgPFX := 	"Dados do Certificado Digital configurado:"+Chr(10)+;
							"Empresa  : "+Alltrim(aChkPFX[2])+Chr(10)+;
							"Emissor  : "+Alltrim(aChkPFX[3]) 
			Else
				lRet := .F.
				cMsgEr := "Falha ao obter dados do Certificado Digital. Verifique a senha."
			EndIf
		EndIf

		If lRet

			dbSelectArea("ZDG")
			If ZDG->(RecLock("ZDG",Iif(cOpt=="I",.T.,.F.)))
				ZDG->ZDG_FILIAL := xFilial("ZDG")
				ZDG->ZDG_CONTA := Alltrim(cGtCNPJ)
				ZDG->ZDG_PCERT := Alltrim(cGtCERT)
				ZDG->ZDG_PKEY := Alltrim(cGtKEY)
				ZDG->ZDG_ARQCER := Alltrim(cGtPFX)
				ZDG->ZDG_CAMPEM := Alltrim(cGtCAM)
				ZDG->ZDG_PSS := Alltrim( RC4Crypt( Alltrim(cGt1Psw) ,"731296548", .F. ) )
				ZDG->(MsUnLock())
				lRet := .T.
				cMsgOk := "Registro "+Iif(cOpt=="I","incluido","alterado")+" com sucesso."
				If !Empty(cMsgPFX)
					cMsgOk += Chr(10)+Chr(10)+cMsgPFX
				EndIf

			Else
				lRet := .F.
				cMsgEr := "Nao foi possível fazer a "+Iif(cOpt=="I","inclusao","alteracao")+" deste registro. Tente novamente. Caso este problema persista, contacte o administrador do sistema."
			EndIf

        EndIf

	ElseIf cOpt == "E"

		If MsgNoYes("Confirma a exclusão deste registro?")
			If ZDG->(RecLock("ZDG",.F.))
				ZDG->(DbDelete())
				ZDG->(MsUnLock())
				lRet  := .T.
				cMsgOk := "Registro excluido com sucesso."
			Else
				lRet := .F.
				cMsgEr := "Nao foi possível fazer a exclusao deste registro. Tente novamente. Caso este problema persista, contacte o administrador do sistema."
			EndIf
		EndIf

	Else

		lRet := .T.
		cMsgEr := ""
		cMsgOk := ""
	
	EndIf

EndIf

If !Empty(cMsgOk)
	MsgInfo(cMsgOk)
EndIf

If !Empty(cMsgEr)
	Alert(cMsgEr)
EndIf

Return(lRet)


/*/
{Protheus.doc}	ChkZDG
Description 	Verifica se o CNPJ informado ja' esta' gravado 
@param			cGtCNPJ
@return			.T. ou .F.
@author			
@since			31/10/2017
/*/
Static Function ChkZDG(cGtCNPJ)

Local lRet := .F.
Local cQry := ""

cQry := "SELECT ZDG_CONTA AS ZDGCNPJ "
cQry += "FROM "+RetSqlName("ZDG")+" ZDG "
cQry += "WHERE ZDG.D_E_L_E_T_ <> '*' "
cQry += "AND ZDG.ZDG_FILIAL = '"+xFilial("ZDG")+"' "
cQry += "AND ZDG.ZDG_CONTA = '"+cGtCNPJ+"' "

Iif(Select("WRKZDG")>0,WRKZDG->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKZDG",.T.,.T.)
WRKZDG->(dbGoTop())

If WRKZDG->(!EoF())
	If !Empty(WRKZDG->ZDGCNPJ)
		lRet := .T.
	EndIf
EndIf
WRKZDG->(dbCloseArea())

Return(lRet)


/*/
{Protheus.doc}	AlfCdZDA
Description 	Cadastro de Excecoes de CFOP
@param			Nenhum
@return			Nil
@author			
@since			31/10/2017
/*/
User Function AlfCdZDA()

U_ALFVCXML()
AxCadastro("ZDA","Excecoes CFOPs",".T.",".T.")

Return(Nil)


/*/
{Protheus.doc}	AlfCdZDB
Description 	Cadastro de Protocolo de ICMS-ST entre UFs
@param			Nenhum
@return			Nil
@author			
@since			31/10/2017
/*/
User Function AlfCdZDB()

U_ALFVCXML()
AxCadastro("ZDB","Protocolo ICMS-ST",".T.",".T.")

Return(Nil)


/*/
{Protheus.doc}	AlfCdZDC
Description 	De-Para para Origem de Produtos
@param			Nenhum
@return			Nil
@author			
@since			31/10/2017
/*/
User Function AlfCdZDC()

U_ALFVCXML()
AxCadastro("ZDC","De-Para Origem Produtos",".T.",".T.")

Return(Nil)


/*/
{Protheus.doc}	AlfCdZDE
Description 	De-Para para CST de Pis / Cofins
@param			Nenhum
@return			Nil
@author			
@since			31/10/2017
/*/
User Function AlfCdZDE()

U_ALFVCXML()
AxCadastro("ZDE","De-Para CST Pis Cofins",".T.",".T.")

Return(Nil)


/*/
{Protheus.doc}	AlfCdZD5
Description 	De-Para Unidade de Medida
@param			Nenhum
@return			Nil
@author			
@since			19/07/2018
/*/
User Function AlfCdZD5()

U_ALFVCXML()
AxCadastro("ZD5","De-Para Unidade de Medida",".T.",".T.")

Return(Nil)



User Function DNEnvEMail(cFrom, cTo, cSubject, cBody, aFiles, lSelfBCC, cCC, cBCC, lThread)

Local nRet       := 0
Local aEnvir     := {}
Local aParMail   := {}

Default lThread := .F.
If lThread
	aEnvir   := {cEmpAnt, cFilAnt, __cUserID, "FIS"}
	aParMail := {cFrom, cTo, cSubject, cBody, aFiles, lSelfBCC, cCC, cBCC }
	StartJob('U_xEnvMailJ', GetEnvServer(), .F., {aEnvir, aParMail})
Else
	nRet := EnvEMail(cFrom, cTo, cSubject, cBody, aFiles, lSelfBCC, cCC, cBCC, lThread)
Endif

Return nRet


User Function xEnvMailJ(aParam)

Local aEnvir     := aParam[1]
Local aParMail   := aParam[2]

// Variáveis de ambiente.
Local cRPCEmp    := aEnvir[1]
Local cRPCFil    := aEnvir[2]
Local cRPCUser   := aEnvir[3]
Local cRPCMod    := aEnvir[4]

// Prepara o ambiente.
RPCSetType(3)  // Não consome licença.
RPCSetEnv(cRPCEmp, cRPCFil, nil, nil, cRPCMod)

// Abre como se fosse o mesmo usuário.
__cUserId := cRPCUser
PswOrder(1)  // Por ID.
PswSeek(__cUserID)

// Envia o e-mail.
EnvEMail(aParMail[1], aParMail[2], aParMail[3], aParMail[4], aParMail[5], aParMail[6], aParMail[7], aParMail[8] )

// Finaliza o ambiente.
RpcClearEnv()

Return


Static Function EnvEMail(cFrom, cTo, cSubject, cBody, aFiles, lSelfBCC, cCC, cBCC )

Local nRet        := -1
Local aUsrMail    := {}
Local cUsrMail    := ""
Local nSendMail   := .F.
Local lMsProcTxt  := (Type("oText") == "O")
Local cBCCAux     := ""
Local aBCC        := {}
Local cToAlt      := ""
Local aFilesSrv   := {}
Local cFileName   := ""
Local cFileExt    := ""
Local oServer
Local cMailServer := ""
Local nMailPort   := 0
Local lSmtpAuth   := .F.
Local cMailConta  := ""
Local cMailSenha  := ""
Local nTimeOut    := 0
Local cMsgErro    := ""
Local cHeaderAlt  := ""
Local nX

Static oMessage
Static cTmpServ   := "\mailspool\"

// Configuração do servidor SMTP.
aUsrMail    := U_xUserMail()  // Busca o e-mail do usuário logado.
cUsrMail    := If(empty(aUsrMail[2, 2]), "", aUsrMail[1])
cMailServer := SuperGetMV("MV_RELSERV",, "")
nMailPort   := SuperGetMV("MV_GCPPORT",, 25)
lSmtpAuth   := SuperGetMV("MV_RELAUTH",, .T.)
If lSmtpAuth
	cMailConta  := SuperGetMV("MV_RELACNT",, "")
	cMailSenha  := SuperGetMV("MV_RELPSW" ,, "")
Endif

Default cFrom      := cUsrMail
Default aFiles     := {}
Default lSelfBCC   := .F.
Default cCC        := ""
Default cBCC       := ""
cFrom := AllTrim(cFrom)

If empty(cFrom)
	Help(,, 'Help',, "Usuário " + cUserName + " sem e-mail configurado. Falar com o administrador do sistema.", 1, 0)
	ConOut("Usuário " + cUserName + " sem e-mail configurado. Falar com o administrador do sistema.")
Else
	// Limpa variáveis antes de enviar o e-mail.
	cTo      := AllTrim(cTo)
	cSubject := AllTrim(cSubject)
	cBody    := AllTrim(cBody)
	cCC      := AllTrim(cCC)
	cBCC     := AllTrim(cBCC)

	ConOut("U_DNEnvEMail - Enviando e-mail para " + cTo)
	If !empty(cCC)
		ConOut("U_DNEnvEMail - Cc " + cTo)
	Endif
	If !empty(cBCC)
		ConOut("U_DNEnvEMail - Cco " + cBCC)
	Endif

	// Conecta ao servidor SMTP.
	If lMsProcTxt
		msProcTxt("Conectando ao servidor " + cMailServer + "..."); ProcessMessages()
	Endif
	oServer := TMailManager():New()
	oServer:Init("", cMailServer, cMailConta, cMailSenha, 110, nMailPort)
	oServer:SetSmtpTimeOut(nTimeOut)
	nRet := oServer:SmtpConnect()
	If nRet <> 0
		Help(,, 'Help',, "Erro " + ltrim(str(nRet)) + " - falha ao conectar ao servidor [" + rtrim(cMailServer) + "].", 1, 0)
	Else
		If lMsProcTxt
			msProcTxt("Enviando e-mail para " + AllTrim(cTo) + "..."); ProcessMessages()
		Endif

		// Cria objeto para envio de e-mails, e o mantém em memória para futuras chamadas.
		If ValType(oMessage) <> "O"
			oMessage   := TMailMessage():New()
		Endif

		// E-mails de cópia oculta.
		If lSelfBCC
			If !empty(cUsrMail)
				aAdd(aBCC, cUsrMail)
			Endif
			If !empty(cFrom) .and. aScan(aBCC, cFrom) == 0
				aAdd(aBCC, cFrom)
			Endif
		Endif
		If !empty(cBCC) .and. aScan(aBCC, cBCC) == 0
			aAdd(aBCC, cBCC)
		Endif

		// Monta e-mail.
		oMessage:Clear()
		oMessage:cFrom    := cFrom
		oMessage:cTo      := cTo
		If !empty(cCC)
			oMessage:cCC  := cCC
		Endif
		If !empty(aBCC)
			cBCCAux := ""
			For nX := 1 to len(aBCC)
				cBCCAux += AllTrim(aBCC[nX]) + "; "
			Next nX
			oMessage:cBCC := left(cBCCAux, len(cBCCAux) - 2)
		Endif
		oMessage:cSubject := cSubject
		oMessage:cBody    := cBody
		oMessage:MsgBodyType("text/html")

		// Anexa arquivos.
		For nX := 1 to len(aFiles)
			SplitPath(aFiles[nX], nil, nil, @cFileName, @cFileExt)
			cFileExt := rtrim(cFileExt)
			__CopyFile(aFiles[nX], cTmpServ + cFileName + cFileExt)
			If file(cTmpServ + cFileName + cFileExt)
				// Guarda o nome do arquivo a ser excluído posteriormente.
				aAdd(aFilesSrv, cTmpServ + cFileName + cFileExt)

				// Anexa arquivo ao e-mail.
				nRet := oMessage:AttachFilePath(cTmpServ + cFileName + cFileExt)
				If nRet < 0
					Help(,, 'Help',, "Erro " + ltrim(str(nRet)) + " - erro ao anexar arquivo " + cFileName + cFileExt + ".", 1, 0)
				Else
					nRet := 0

					// Adiciona uma tag informando a ID do arquivo.
					oMessage:AddAttHTag('Content-ID: <ID_' + cFileName + cFileExt + '>')
					oMessage:cBody := StrTran(oMessage:cBody, 'src="' + cFileName + cFileExt + '"', 'src="cid:ID_' + cFileName + cFileExt + '"')
				Endif
			Else
				Help(,, 'Help',, "Erro ao copiar arquivo " + cFileName + cFileExt + ".", 1, 0)
				nRet := -1
			Endif
		Next nX

		// Envia o e-mail.
		If nRet == 0
			nRet := oMessage:Send(oServer)
		Endif

		// Se deu falha, exibe mensagem na tela.
		If nRet <> 0
			cMsgErro := "Falha ao enviar e-mail." + CRLF
			cMsgErro += "De: " + RTrim(oMessage:cFrom) + CRLF
			cMsgErro += "Para: " + RTrim(oMessage:cTo) + CRLF
			If !empty(oMessage:cCC)
				cMsgErro += "Cópia: " + RTrim(oMessage:cCC) + CRLF
			Endif
			If !empty(oMessage:cBCC)
				cMsgErro += "Cópia oculta: " + RTrim(oMessage:cBCC) + CRLF
			Endif
			cMsgErro += "Erro: " + oServer:GetErrorString(nRet)
			Help(,, 'Help',, cMsgErro, 1, 0)
		Endif

		// Desconecta do servidor.
		If lMsProcTxt
			msProcTxt("Desconectando..."); ProcessMessages()
		Endif
		oServer:SmtpDisconnect()

		// Apaga arquivos depois de enviado o e-mail.
		aEval(aFilesSrv, {|x| fErase(x)})
	Endif
Endif

Return nRet



// ##############################################################################
// Projeto  : PROT-CAP
// Autor    : 
// Modulo   : Faturamento
// Função   : Txt2HTML
// Descrição: Converte um texto acentuado para o formato HTML.
// Retorno  : Nenhum.
// ---------+-------------------+------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+------------------------------------------------
// 04/09/13 | Felipe Raposo     | Desenvolvimento da rotina.
// ---------+-------------------+------------------------------------------------
User Function xTxt2HTML(cTexto, lConEspaco)

Local cRet       := ""
Local cChar      := ""
Local nX, nY

Default lConEspaco := .F.

Static aPort      := {}
If empty(aPort)
	aAdd(aPort, {char(034), '&quot;'})
	aAdd(aPort, {char(038), '&amp;'})
	aAdd(aPort, {char(060), '&lt;'})
	aAdd(aPort, {char(062), '&gt;'})
	aAdd(aPort, {char(145), '&#8217;'})
	aAdd(aPort, {char(146), '&#8217;'})
	aAdd(aPort, {char(147), '&quot;'})
	aAdd(aPort, {char(149), '&bull;'})
	aAdd(aPort, {char(148), '&quot;'})
	aAdd(aPort, {char(150), '&#9472;'})
	aAdd(aPort, {char(160), ' '})
	aAdd(aPort, {char(161), '&iexcl;'})
	aAdd(aPort, {char(162), '&cent;'})
	aAdd(aPort, {char(163), '&pound;'})
	aAdd(aPort, {char(164), '&curren;'})
	aAdd(aPort, {char(165), '&yen;'})
	aAdd(aPort, {char(166), '&brvbar;'})
	aAdd(aPort, {char(167), '&sect;'})
	aAdd(aPort, {char(168), '&uml;'})
	aAdd(aPort, {char(169), '&copy;'})
	aAdd(aPort, {char(170), '&ordf;'})
	aAdd(aPort, {char(171), '&laquo;'})
	aAdd(aPort, {char(172), '&not;'})
	aAdd(aPort, {char(173), '-'})
	aAdd(aPort, {char(174), '&reg;'})
	aAdd(aPort, {char(175), '&macr;'})
	aAdd(aPort, {char(176), '&deg;'})
	aAdd(aPort, {char(177), '&plusmn;'})
	aAdd(aPort, {char(178), '&sup2;'})
	aAdd(aPort, {char(179), '&sup3;'})
	aAdd(aPort, {char(180), '&acute;'})
	aAdd(aPort, {char(181), '&micro;'})
	aAdd(aPort, {char(182), '&para;'})
	aAdd(aPort, {char(183), '&middot;'})
	aAdd(aPort, {char(184), '&cedil;'})
	aAdd(aPort, {char(185), '&sup1;'})
	aAdd(aPort, {char(186), '&ordm;'})
	aAdd(aPort, {char(187), '&raquo;'})
	aAdd(aPort, {char(188), '&frac14;'})
	aAdd(aPort, {char(189), '&frac12;'})
	aAdd(aPort, {char(190), '&frac34;'})
	aAdd(aPort, {char(191), '&iquest;'})
	aAdd(aPort, {char(192), '&Agrave;'})
	aAdd(aPort, {char(193), '&Aacute;'})
	aAdd(aPort, {char(194), '&Acirc;'})
	aAdd(aPort, {char(195), '&Atilde;'})
	aAdd(aPort, {char(196), '&Auml;'})
	aAdd(aPort, {char(197), '&Aring;'})
	aAdd(aPort, {char(198), '&AElig;'})
	aAdd(aPort, {char(199), '&Ccedil;'})
	aAdd(aPort, {char(200), '&Egrave;'})
	aAdd(aPort, {char(201), '&Eacute;'})
	aAdd(aPort, {char(202), '&Ecirc;'})
	aAdd(aPort, {char(203), '&Euml;'})
	aAdd(aPort, {char(204), '&Igrave;'})
	aAdd(aPort, {char(205), '&Iacute;'})
	aAdd(aPort, {char(206), '&Icirc;'})
	aAdd(aPort, {char(207), '&Iuml;'})
	aAdd(aPort, {char(208), '&ETH;'})
	aAdd(aPort, {char(209), '&Ntilde;'})
	aAdd(aPort, {char(210), '&Ograve;'})
	aAdd(aPort, {char(211), '&Oacute;'})
	aAdd(aPort, {char(212), '&Ocirc;'})
	aAdd(aPort, {char(213), '&Otilde;'})
	aAdd(aPort, {char(214), '&Ouml;'})
	aAdd(aPort, {char(215), '&times;'})
	aAdd(aPort, {char(216), '&Oslash;'})
	aAdd(aPort, {char(217), '&Ugrave;'})
	aAdd(aPort, {char(218), '&Uacute;'})
	aAdd(aPort, {char(219), '&Ucirc;'})
	aAdd(aPort, {char(220), '&Uuml;'})
	aAdd(aPort, {char(221), '&Yacute;'})
	aAdd(aPort, {char(222), '&THORN;'})
	aAdd(aPort, {char(223), '&szlig;'})
	aAdd(aPort, {char(224), '&agrave;'})
	aAdd(aPort, {char(225), '&aacute;'})
	aAdd(aPort, {char(226), '&acirc;'})
	aAdd(aPort, {char(227), '&atilde;'})
	aAdd(aPort, {char(228), '&auml;'})
	aAdd(aPort, {char(229), '&aring;'})
	aAdd(aPort, {char(230), '&aelig;'})
	aAdd(aPort, {char(231), '&ccedil;'})
	aAdd(aPort, {char(232), '&egrave;'})
	aAdd(aPort, {char(233), '&eacute;'})
	aAdd(aPort, {char(234), '&ecirc;'})
	aAdd(aPort, {char(235), '&euml;'})
	aAdd(aPort, {char(236), '&igrave;'})
	aAdd(aPort, {char(237), '&iacute;'})
	aAdd(aPort, {char(238), '&icirc;'})
	aAdd(aPort, {char(239), '&iuml;'})
	aAdd(aPort, {char(240), '&eth;'})
	aAdd(aPort, {char(241), '&ntilde;'})
	aAdd(aPort, {char(242), '&ograve;'})
	aAdd(aPort, {char(243), '&oacute;'})
	aAdd(aPort, {char(244), '&ocirc;'})
	aAdd(aPort, {char(245), '&otilde;'})
	aAdd(aPort, {char(246), '&ouml;'})
	aAdd(aPort, {char(247), '&divide;'})
	aAdd(aPort, {char(248), '&oslash;'})
	aAdd(aPort, {char(249), '&ugrave;'})
	aAdd(aPort, {char(250), '&uacute;'})
	aAdd(aPort, {char(251), '&ucirc;'})
	aAdd(aPort, {char(252), '&uuml;'})
	aAdd(aPort, {char(253), '&yacute;'})
	aAdd(aPort, {char(254), '&thorn;'})
	aAdd(aPort, {char(255), '&yuml;'})
Endif

// Converte os acentos da língua portuguesa.
For nX := 1 to len(cTexto)
	cChar := SubStr(cTexto, nX, 1)
	If asc(cChar) > 0  // Retira caracter CHAR(0) do texto.
		nY := aScan(aPort, {|x| x[1] == cChar})
		If nY > 0
			cChar := aPort[nY, 2]
		ElseIf lConEspaco .and. cChar == " "
			// Converte espaços em branco.
			cChar := "&nbsp;"
		Endif
		cRet += cChar
	Endif
Next nX

// Converte as quebras de linha.
cRet := StrTran(cRet, CRLF,     '<BR/>')
cRet := StrTran(cRet, char(10), '<BR/>')
cRet := StrTran(cRet, char(13), '<BR/>')

Return cRet


User Function xUserMail(cUsrName)

// Declaracao de variaveis.
Local lRet   := .F.
Local aRet   := {"", {"", ""}}
Local cNome  := ""
Local cEmail := ""

// Pesquisa o usuário.
If ValType(cUsrName) == "C"
	PswOrder(2)  // Nome do usuário/grupo.
	lRet := PswSeek(rtrim(cUsrName))
Else
	PswOrder(1)  // ID do usuário/grupo.
	lRet := PswSeek(__CUSERID)
Endif

// Se encontrou o usuário, retornar seu nome e email.
If lRet
	aRetUser := PswRet(1)
	If !empty(aRetUser)
		cNome  := Capital(AllTrim(aRetUser[1, 4]))
		cEmail := lower(AllTrim(aRetUser[1, 14]))
		aRet[1] := cNome + " <" + cEmail + ">"
		aRet[2] := {cNome, cEmail}
	Endif
Endif

Return aRet