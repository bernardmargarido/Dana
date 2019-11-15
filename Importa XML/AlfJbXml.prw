#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"


//Executar pelo SmartClient ( U_JBALFXML )
User Function JbAlfXml(cGtEmp,cGtFil)

Default cGtEmp := "                           "
Default cGtFil := "                           "
U_ALFRUNXML(cGtEmp,cGtFil)

Return(Nil)


//Executar do Menu 
User Function AlfJbXml()

LjMsgRun("Aguarde... Pesquisando NFs na Sefaz - Empresa "+cEmpAnt+" Filial "+cFilAnt ,,{||U_AlfXmlJB(cEmpAnt,cFilAnt,.F.)})

Return(Nil)


//Chamar do Schedule
User Function AlfScXml(xParm)

Local cEmpJb := ""
Local cFilJb := ""

cEmpJb := xParm[1]
cFilJb := xParm[2]
ConOut(">>> Monitor XML <<< Inicio: Emp "+cEmpJb+ " Fil "+cFilJb+ " " +Dtoc(Date())+ " " +Time())
U_AlfXmlJB(cEmpJb,cFilJb,.T.)
ConOut(">>> Monitor XML <<< Fim: Emp "+cEmpJb+ " Fil "+cFilJb+ " " +Dtoc(Date())+ " " +Time() )
	
Return(Nil)



/*/{Protheus.doc} AlfJbXml()
Job para realizar a busca dos arquivos XML do documento de entrada
e dar entrada no pre-nota
@type  Function
@athor user:    
@since date:    02/10/2017
@version version
@param param, param_type, param_descr
@return .T.
#    @example
(examples)
@see (links_or_references)
/*/
User Function AlfXmlJB(cEmpJb,cFilJb,lIsJb)

Local aEmpresa := {}
Local aParam := {}
Local aRetCOp := {}
Local nI := 0
Local nJ := 0
Local oRet := Nil
Local nBaixadas := 0
Local cError := ""
Local cWarning := ""
Local cMsgError := ""
Local cTxtQry := ""
Local lSM0Find := .F.
Local lGo := .T.
Local cLockNm := ""
Default lIsJb := .T.
Private lInJob := lIsJb
Private oTmp := Nil

If lGo
	If lInJob .And. !Empty(cEmpJb) .And. !Empty(cFilJb)
		cLockNm := "ALFJBXML"+Alltrim(cEmpJb)+Alltrim(cFilJb)
		PREPARE ENVIRONMENT EMPRESA cEmpJb FILIAL cFilJb TABLES  "SX2", "SX5", "SX6"
		U_ALFVCXML(.T.)
		lGo := LockByName(cLockNm, .F., .F.)
	EndIf
EndIf

//Verifica as empresas e filiais configuradas na tabela ZDG
//e pega demais dados no cadastro da empresa
If lGo	

	cTxtQry := "SELECT "
	cTxtQry += "ZDG.ZDG_CONTA AS ZDGCONTA "
	cTxtQry += "FROM "+RetSqlName("ZDG")+" ZDG WHERE ZDG.D_E_L_E_T_ <> '*' "
	cTxtQry += "AND ZDG.ZDG_FILIAL = '"+xFilial("ZDG")+"' "
	cTxtQry += "AND ZDG.ZDG_CONTA <> '' "
	cTxtQry += "ORDER BY ZDG.ZDG_CONTA"
	
	Iif(Select("WRKWZDG")>0,WRKWZDG->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cTxtQry),"WRKWZDG",.T.,.T.)
	WRKWZDG->(dbGoTop())
	
	While WRKWZDG->(!EoF())

		lSM0Find := .F.
		dbSelectArea("SM0")
		SM0->(dbGoTop())
		While SM0->(!EoF()) .And. !lSM0Find
			
			If Upper(Alltrim(SM0->M0_CGC)) == Upper(Alltrim(WRKWZDG->ZDGCONTA))

                lSM0Find := .T.
				aAdd( aEmpresa, {	SM0->M0_CGC,;
									SM0->M0_CODIGO,;
									SM0->M0_CODFIL,;
									CodUF( SM0->M0_ESTCOB ),;
									SM0->( RECNO() ) } )
			EndIf
			If SM0->(EoF())
   				lSM0Find := .T.
			EndIf
			SM0->( dbSkip() )
		EndDo
		WRKWZDG->(dbSkip())

	EndDo
	WRKWZDG->(dbCloseArea())
	
	If Len(aEmpresa) = 0
		lGo := .F.
		cMsgError := "Nao existe configuracao ZDG - Emp " +cEmpJb+ " Fil " +cFilJb
	EndIf

EndIf
 

If lGo
	// laço para pesquisa das chaves por raíz de CNPJ
	For nI := 1 to len(aEmpresa)
		oRet   := nil
		aParam := { aEmpresa[nI][1] ,;
		aEmpresa[nI][4],"" }
		SM0->( dbGoto( aEmpresa[nI][5] ) )

		//Pesquisa Chaves XML para o CNPJ, gravando na tabela ZDI
		U_AlfSfz01( "1", aParam, @oRet)	
	Next nI

	
	//Ciencia da Operacao e Download do XML
	cTxtQry := "SELECT * " 
	cTxtQry += "FROM "+RetSqlName("ZDI")+" WHERE D_E_L_E_T_ <> '*' "
	cTxtQry += "AND ZDI_FILIAL = '"+xFilial("ZDI")+"' "
	cTxtQry += "AND LTRIM(RTRIM(ZDI_STATUS)) IN ('','E') "
	cTxtQry += "AND ZDI_TPXML = 'RESNFE' "
	cTxtQry += "ORDER BY R_E_C_N_O_ DESC"
	
	Iif(Select("WRKZDI")>0,WRKZDI->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cTxtQry),"WRKZDI",.T.,.T.)
	WRKZDI->(dbGoTop())
	

	While WRKZDI->(!EoF())

		If Alltrim(WRKZDI->ZDI_STATUS) == "" .Or. Alltrim(WRKZDI->ZDI_STATUS) == "E"

        	aRetCOp := {}
			aParam := {}

			aadd( aParam, WRKZDI->ZDI_CONTA )	// CNPJ
			aadd( aParam, WRKZDI->ZDI_UFDEST )	// Chave do XML
			aadd( aParam, WRKZDI->ZDI_CHVNFE )	// Chave do XML
			oRet := nil

			//Faz a Ciencia da Operacao
			aRetCOp :=  AlfCOper( aParam )

			If aRetCOp[1]

				aParam := aRetCOp[2]

				If Alltrim(WRKZDI->ZDI_STATUS) <> "E"
					U_AlfSfz01( "2", aParam, @oRet)	
				EndIf

				if U_AlfSfz01( "3", aParam, @oRet)	// Pesquisa Chaves XML para o CNPJ
	
					If Left(oRet, 6) != "RESP: "								// Retornou valores
	
						cError   := ""
						cWarning := ""
						oTmp     := XMLParser( oRet, "", @cError,@cWarning)	// efetua parse pra retornar o objeto
	
						If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
							aItens := oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
						elseif Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT") == "C"
							aItens := {oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT}
						else
							aItens := {}
						endif
	
						for nJ := 1 to len( aItens )
							oRet := U_xDescptDocZip(aItens[nJ], WRKZDI->ZDI_CHVNFE )
							if U_AlfSfz06( oRet )	// Tratamento do XML
								nBaixadas++
								//Parei aqui: atualizar status da ZDI/ZDH com "Baixadas"
							endif
						next nJ
					EndIf
	
				endif
			
			EndIf
		endif

		WRKZDI->(dbSkip())

	EndDo

	WRKZDI->(dbCloseArea())

EndIf

If !Empty(cMsgError)
	If lInJob
		Conout("------------------------------------------------------------")
		Conout(DtoC(Date()) + " - " + Time() + " - ERRO Job ALFJBXML")
		Conout(cMsgError)
		Conout("------------------------------------------------------------")
	Else
		Alert(cMsgError)
	EndIf
EndIf

If lGo
	If lInJob
		If !Empty(cLockNm)
			UnLockByName(cLockNm, .F., .F.)
			RESET ENVIRONMENT
		EndIf
	EndIf
EndIf

Return(Nil)



Static Function CodUF( cUF )
Local cRet := '91'
Local aUF  := { {'11','RO','RONDONIA'} ,;
				{'12','AC','ACRE'} ,;
				{'13','AM','AMAZONAS'} ,;
				{'14','RR','RORAIMA'} ,;
				{'15','PA','PARA'} ,;
				{'16','AP','AMAPA'} ,;
				{'17','TO','TOCANTINS'} ,;
				{'21','MA','MARANHAO'} ,;
				{'22','PI','PIAUI'} ,;
				{'23','CE','CEARA'} ,;
				{'24','RN','RIO GRANDE DO NORTE'} ,;
				{'25','PB','PARAIBA'} ,;
				{'26','PE','PERNAMBUCO'} ,;
				{'27','AL','ALAGOAS'} ,;
				{'28','SE','SERGIPE'} ,;
				{'29','BA','BAHIA'} ,;
				{'31','MG','MINAS GERAIS'} ,;
				{'32','ES','ESPIRITO SANTO'} ,;
				{'33','RJ','RIO DE JANEIRO'} ,;
				{'35','SP','SAO PAULO'} ,;
				{'41','PR','PARANA'} ,;
				{'42','SC','SANTA CATARINA'} ,;
				{'43','RS','RIO GRANDE DO SUL'} ,;
				{'50','MS','MATO GROSSO DO SUL'} ,;
				{'51','MT','MATO GROSSO'} ,;
				{'52','GO','GOIAS'} ,;
				{'53','DF','DISTRITO FEDERAL'} }
			
If ( nPos := aScan( aUF, { |x| x[2] == cUF } ) ) > 0
	cRet := aUF[ nPos ][ 1 ]
EndIf

Return(cRet)



Static Function AlfCOper( aParam ) // { CNPJ, UF, ChvNFe }
Local cXQry := ""
Local lRet := .F.
Local oRet := Nil
Local aParms := { aParam[1] , aParam[2] , aParam[3] , , }

cXQry := "SELECT " 
cXQry += "ZDI_TPXML AS ZDITPXML, " 
cXQry += "ZDI_STATUS AS ZDISTATUS, " 
cXQry += "ZDI_DTPROC AS ZDIDTPROC, " 
cXQry += "ZDI_HRPROC AS ZDIHRPROC, " 
cXQry += "R_E_C_N_O_ AS ZDIRECNO " 
cXQry += "FROM "+RetSqlName("ZDI")+" WHERE D_E_L_E_T_ <> '*' "
cXQry += "AND ZDI_FILIAL = '"+xFilial("ZDI")+"' "
cXQry += "AND ZDI_CONTA = '"+aParms[1]+"' "
cXQry += "AND ZDI_CHVNFE = '"+aParms[3]+"' "

Iif(Select("WRKXZDI")>0,WRKXZDI->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cXQry),"WRKXZDI",.T.,.T.)
WRKXZDI->(dbGoTop())

If WRKXZDI->(!EoF())
	If Alltrim(WRKXZDI->ZDITPXML) == "RESNFE"
		lRet := .T.
		aParms[4] := StoD(WRKXZDI->ZDIDTPROC)
		aParms[5] := WRKXZDI->ZDIHRPROC
	EndIf
EndIf
WRKXZDI->(dbCloseArea())

Return({ lRet , aParms })



User Function ALFRUNXML(cGtEmp,cGtFil)
Local oBt1, oBt2, oGtEmp, oGtFil, oSay1, oSay2, oDg1 := Nil
Local lGo := .F.
Default cGtEmp := "                           "
Default cGtFil := "                           "

DEFINE MSDIALOG oDg1 TITLE "ALFJBXML - Execução sob Demanda" FROM 000, 000  TO 085, 450 COLORS 0, 16777215 PIXEL
    @ 007, 005 SAY oSay1 PROMPT "Empresa" SIZE 025, 007 OF oDg1 COLORS 0, 16777215 PIXEL
    @ 005, 032 MSGET oGtEmp VAR cGtEmp Valid(!Empty(cGtEmp)) SIZE 060, 010 OF oDg1 COLORS 0, 16777215 PIXEL
    @ 006, 134 SAY oSay2 PROMPT "Filial" SIZE 017, 007 OF oDg1 COLORS 0, 16777215 PIXEL
    @ 004, 156 MSGET oGtFil VAR cGtFil Valid(!Empty(cGtEmp)) SIZE 060, 010 OF oDg1 COLORS 0, 16777215 PIXEL
    @ 023, 004 BUTTON oBt1 PROMPT "Executa" SIZE 098, 012 OF oDg1 ACTION (lGo:=.T.,oDg1:End()) PIXEL
    @ 023, 119 BUTTON oBt2 PROMPT "Sair" SIZE 098, 012 OF oDg1 ACTION (lGo:=.F.,oDg1:End()) PIXEL
ACTIVATE MSDIALOG oDg1 CENTERED
If lGo
	If ( Empty(Alltrim(cGtEmp)) .And. Empty(Alltrim(cGtFil)) )
		Alert("Empresa / Filial invalidos")
	Else
		dbUseArea(,,"SIGAMAT.EMP","SM0",.T.,.F.)
		dbSetIndex( "SIGAMAT.IND" )
		dbSelectArea("SM0")
		If SM0->(dbSeek(Alltrim(cGtEmp)+Alltrim(cGtFil)))
			MsgRun ("Aguarde... Pesquisando NFs na Sefaz - Emp "+Alltrim(cGtEmp)+" Fil "+Alltrim(cGtFil), "Aguarde", {||U_AlfXmlJB(Alltrim(cGtEmp),Alltrim(cGtFil),.T.)} )
			MsgInfo("Fim do processamento - Empresa "+Alltrim(cGtEmp)+" Filial "+Alltrim(cGtFil))
		Else
			Alert("Empresa / Filial nao consta do cadastro de empresas")
		EndIf
	EndIf
EndIf
Return(Nil)
