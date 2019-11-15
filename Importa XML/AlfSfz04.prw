Static lDBug    := SuperGetMV("AF_MDBGXML",,"N") == "S" //Obs.: necessario para debug 
Static lEspFunc := SuperGetMV("AF_MXMLEFN",,"N") == "S" //Habilita funcoes corretivas no monitor
Static lClassNF := SuperGetMV("AF_MXMLCFN",,"N") == "S" //Habilita Classificacao Automatica

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE DIRXML  "\XML\"

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

/*/{Protheus.doc} AlfSfz04()
    Rotina que irá controlar o status dos arquivos
    (Tela de Monitoramento)
    (long_description)
    @type  Function
    @author user:
    @since date:    23/10/2017
    @version version
    @param param, param_type, param_descr
    @return lStatus
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AlfSfz04()
	Local cFilterDefault := ""
	Local cPsqNFe := SuperGetMV("AF_PXMLNFE",,"N")

	Private oXMLBrw
	Private cCadastro 	:= "Tela de Monitoramento XML Entrada"
	
	U_ALFVCXML()
    
	dbSelectArea("ZDH")
	
	SetKey( VK_F2, {|| U_Alf04FIL() } ) // Filtros Pre-Definidos
	
	AjustaSX1()

	cFilterDefault := U_Alf04FIL()

	if Empty(cFilterDefault)
		Return
	Endif

	DEFINE FWMBROWSE oXMLBrw ALIAS "ZDH" FILTERDEFAULT cFilterDefault DESCRIPTION cCadastro NO DETAILS

		//--------------------------------------------------------
		// Adiciona legenda no Browse
		//--------------------------------------------------------
		If cPsqNFe == "S"		
		
			ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'G' } COLOR "GREEN" 		TITLE "NFe: Pré-Nota" 						OF oXMLBrw
			ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'C' } COLOR "RED" 		TITLE "NFe: Classificada" 					OF oXMLBrw
			ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'O' } COLOR "WHITE"		TITLE "NFe: Confirmação da Operação"		OF oXMLBrw
			ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'N' } COLOR "PINK"		TITLE "NFe: Operação não Realizada"			OF oXMLBrw
			ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'D' } COLOR "ORANGE"		TITLE "NFe: Desconhecimento da Operação"	OF oXMLBrw
			ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'E' } COLOR "BLUE"		TITLE "NFe: Erro - Compras"					OF oXMLBrw
			ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'F' } COLOR "BLACK"		TITLE "NFe: Erro - Fiscal"					OF oXMLBrw

		EndIf

		ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'T' } COLOR "GRAY"		TITLE "CTe: Incluído no Monitor"			OF oXMLBrw
		ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'Y' } COLOR "YELLOW"		TITLE "CTe: Nota Gerada"					OF oXMLBrw
		ADD LEGEND DATA {|| ZDH->ZDH_STATUS == 'W' } COLOR "BROWN"		TITLE "CTe: Erro ao Gerar Nota"				OF oXMLBrw

		oXMLBrw:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente

	ACTIVATE FWMBROWSE oXMLBrw

Return



/*****************************************************************************
* Autor         
* Descricao     Chama Rotina para Selecionar Arquvio e Gerar Pré-Nota
* Data          23/10/2017
*****************************************************************************/
Static Function MenuDef()

	Local aRotina := {}
	Local aManif  := {}
	Local cPsqNFe := SuperGetMV("AF_PXMLNFE",,"N")

	ADD OPTION aRotina TITLE "Seleciona XML"		ACTION "U_AlfSZF0A()" 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Pesquisar" 			ACTION "PesqBrw"		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Detalhes"				ACTION "U_Alf04Vis()" 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Visual.XML"			ACTION "U_AlfSzf07()" 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Gera Nota CTE"		ACTION "U_Alf04GER()" 	OPERATION 2 ACCESS 0
	

	If cPsqNFe == "S"

		If lClassNF
			ADD OPTION aRotina TITLE "Classificar Pre-Nota" ACTION "U_ALFVCLAS()" 	OPERATION 2 ACCESS 0
		EndIf

		ADD OPTION aManif TITLE "Confirmação da Operação" 		ACTION "U_Alf04Man('4')" 	OPERATION 2 ACCESS 0
		ADD OPTION aManif TITLE "Desconhecimento da Operação" 	ACTION "U_Alf04Man('5')" 	OPERATION 2 ACCESS 0
		ADD OPTION aManif TITLE "Operação não Realizada" 		ACTION "U_Alf04Man('6')" 	OPERATION 2 ACCESS 0
		ADD OPTION aRotina TITLE "Manifesto" 					ACTION aManif 				OPERATION 8 ACCESS 0

	EndIf
	
	ADD OPTION aRotina TITLE "Filtros (F2)" 		ACTION "U_Alf04FIL"		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Legenda" 		    	ACTION "U_Alf04LEG"	    OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Pesquisar Sefaz"    	ACTION "U_AlfPqSfz()"   OPERATION 2 ACCESS 0
	
	If lEspFunc
		ADD OPTION aRotina TITLE "Ajusta Legenda"   	ACTION "U_AlfACLG"	    OPERATION 2 ACCESS 0
	EndIf
	
Return aRotina


/*****************************************************************************
* Autor         
* Descricao     Rotina de Legenda do monitoramento
* Data          23/10/2017
*****************************************************************************/
User Function Alf04LEG()

	Local aLegenda := {}
	Local cPsqNFe := SuperGetMV("AF_PXMLNFE",,"N")

	If cPsqNFe == "S"
		AADD( aLegenda, {"BR_VERDE"		, "NFe: Pré-Nota" } )
		AADD( aLegenda, {"BR_VERMELHO"	, "NFe: Classificada" } )
		AADD( aLegenda, {"BR_BRANCO"	, "NFe: Confirmação da Operação" } )
		AADD( aLegenda, {"BR_PINK"		, "NFe: Operação não Realizada" } )
		AADD( aLegenda, {"BR_LARANJA"	, "NFe: Desconhecimento da Operação" } )
		AADD( aLegenda, {"BR_AZUL"		, "NFe: Erro - Compras" } )
		AADD( aLegenda, {"BR_PRETO"		, "NFe: Erro - Fiscal" } )
	EndIf
	AADD( aLegenda, {"BR_CINZA"		, "CTe: Incluído no Monitor" } )
	AADD( aLegenda, {"BR_AMARELO"	, "CTe: Nota incluída" } )
	AADD( aLegenda, {"BR_MARROM"	, "CTe: Erro ao Gerar Nota" } )
	BrwLegenda(cCadastro,"Legenda",aLegenda)

Return .T. 


/*****************************************************************************
* Autor         
* Descricao     Rotina de Filtrar Registros
* Data          23/10/2017
*****************************************************************************/
User Function Alf04FIL()
Local cFiltDef := ""
Local cFornec := ""
Local cTipos := ""

AjustaSX1()
Pergunte("ALFSFZXMLA",.F.)

If lDBug

	MV_PAR01 := 1
	MV_PAR02 := 1
    MV_PAR03 := Space(9)
    MV_PAR04 := Space(44)
    Return(" ZDH_FILIAL = '"+xFilial("ZDH")+"' ")

Else

	cFiltDef := " ZDH_FILIAL = '"+xFilial("ZDH")+"' "
	
	If Pergunte("ALFSFZXMLA",.T.)	
	
		// STATUS
		If MV_PAR01 == 1 // Todas
			cFiltDef += ""
		ELSEIf MV_PAR01 == 2
			cFiltDef += " .AND. ZDH_STATUS == 'T' "
		ELSEIf MV_PAR01 == 3
			cFiltDef += " .AND. ZDH_STATUS == 'W' "
		ELSEIf MV_PAR01 == 4
			cFiltDef += " .AND. ZDH_STATUS == 'Y' "
		Else
			cFiltDef += ""
		EndIf
		
		// Nota DE ATE
		If !Empty(MV_PAR02) .Or. !Empty(MV_PAR03)
			cFiltDef += " .AND. ZDH_NUMNF >= '"+MV_PAR02+"' "
			cFiltDef += " .AND. ZDH_NUMNF <= '"+MV_PAR03+"' "
		EndIf
		
		// Chave NF-e
		If !Empty(MV_PAR04)
			cFiltDef += " .AND. ZDH_CHAVE == '"+MV_PAR04+"' "
		EndIf
		
	EndIf

EndIf

If TYPE("oXMLBrw") <> "U"

	oXMLBrw:SetFilterDefault(cFiltDef)
	TcRefresh(RetSqlName("ZDH"))	
	ZDH->(dbGoTop())
	oXMLBrw:Refresh(.T.)

EndIf

Return(cFiltDef)


/*****************************************************************************
* Autor         
* Descricao     Rotina que irá chamar a validação
* Data          23/10/2017
*****************************************************************************/
User Function Alf04GER()

	If SubStr(ZDH->ZDH_CHAVE,21,2) == "55"
		Processa({ || Alf04GE1() },"Processando NFe...")
	ElseIf SubStr(ZDH->ZDH_CHAVE,21,2) == "57"
		Processa({ || U_Alf04GCT() },"Processando CTe...")
	Else
		Alert("Erro ao visualizar este documento")
	EndIf

Return

/*****************************************************************************
* Autor         
* Descricao     Rotina que irá buscar o arquivo XML para novo processamento
* Data          23/10/2017
*****************************************************************************/
Static Function Alf04GE1()
    Local cChvNFE    := ZDH->ZDH_CHAVE
	Local cNumNF     := ZDH->ZDH_NUMNF
	Local cStatus    := ZDH->ZDH_STATUS
	Local cSChema    := ZDH->ZDH_SCHEMA
	Local cSerie	 := ""
	Local cError	 := ""
	Local cWarning	 := ""
	Local cXMLFile	 := "\XML\"+Alltrim(ZDH->ZDH_CHAVE)+".xml"
	Local oXMLFile	 := Nil
	

	IF cStatus $ "E|F"

		If File(cXMLFile)
			oXmlFile := XmlParserFile( cXMLFile, "_", @cError, @cWarning )    // "\XML\"+_cCHAVE+".XML"
		EndIf

		IncProc("Iniciando o Processo de Geração de Pré-Nota")
		U_AlfSfz06( cSChema, oXMLFile)
	ELSE
		MsgInfo("Este XML já foi importado. Documento Entrada: "+ZDH->ZDH_NUMNF,"Atenção!!!")
	Endif

Return



/*****************************************************************************
* Autor         
* Descricao     Rotina Chamada de Parâmetros
* Data          23/10/2017
*****************************************************************************/
Static Function AjustaSX1()
	Local aSX1Area := SX1->(GetArea())
	Local aHelp01 := {}
	Local aHelp02 := {}
	Local aHelp03 := {}
	Local aHelp04 := {}

	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If SX1->(!dbSeek("ALFSFZXMLA"))

		aHelp01 := {"Seleciona os Status:","Todos","CTe Incluido no Monitor","CTe com Erro","CTe Com Nota Gerada",""}
		aHelp02 := {"Numero da Nota Fiscal Inicial.","","","",""}
		aHelp03 := {"Numero da Nota Fiscal Final."  ,"","","",""}
		aHelp04 := {"Chave Nota Fiscal Eletronica." ,"","","",""}

		AlfPtSx1("ALFSFZXMLA","01","Status"		,"Status"		,"Status"		,"MV_CH1","N",1	,0,5,"C","","","","","MV_PAR01","Todos"	,"","",""					,"CTe Incluido"		,"","","CTe Erro"			,"","","CTe Nota Gerada",	"","",	"",					"","",aHelp01)
		AlfPtSx1("ALFSFZXMLA","02","Nota De"	,"Nota De"		,"Nota De"		,"MV_CH2","C",9	,0,0,"G","","","","","MV_PAR02",""			,"","",""					,""					,"","",""					,"","","",					"","",	"",					"","",aHelp02)
		AlfPtSx1("ALFSFZXMLA","03","Nota Ate"	,"Nota Ate"		,"Nota Ate"		,"MV_CH3","C",9 ,0,0,"G","","","","","MV_PAR03",""			,"","",Replicate("Z",44)	,""					,"","",""					,"","","",					"","",	"",					"","",aHelp03)
		AlfPtSx1("ALFSFZXMLA","04","Chave NF-e"	,"Chave NF-e"	,"Chave NF-e"	,"MV_CH4","C",44,0,0,"G","","","","","MV_PAR04",""			,"","",""					,""					,"","",""					,"","","",					"","",	"",					"","",aHelp04)

    EndIf

    RestArea(aSX1Area)

Return(Nil)



/*****************************************************************************
* Autor         
* Descricao     Rotina de Visualização de inconsistência
* Data          23/10/2017
*****************************************************************************/
User Function Alf04Vis()
Local oBTOK
Local oFont1     := TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
Local oFont2     := TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
Local oMsgError 
Local cMsgError  := ZDH->ZDH_MSGERR
Local oPnInferior
Local oPnSuperior
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Detalhes" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

    @ 003, 002 MSPANEL oPnSuperior PROMPT "Mensagem" SIZE 245, 016 OF oDlg COLORS 255, 16777215 FONT oFont1 CENTERED LOWERED
    @ 020, 002 GET oMsgError VAR cMsgError OF oDlg MULTILINE SIZE 246, 205 COLORS 0, 16777215 READONLY HSCROLL FONT oFont2 PIXEL
    @ 228, 002 MSPANEL oPnInferior SIZE 244, 020 OF oDlg COLORS 0, 16777215 LOWERED
    @ 003, 098 BUTTON oBTOK PROMPT "Sair" SIZE 039, 016 ACTION oDlg:End() OF oPnInferior PIXEL
    oBTOK:cToolTip := "Retorna para tela anterior"
    oBTOK:SetCss( CSSBOTAO )

  ACTIVATE MSDIALOG oDlg CENTERED

Return



Static Function AlfPtSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

LOCAL aArea := GetArea()
Local cKey
Local lPort := .f.
Local lSpa  := .f.
Local lIngl := .f. 

cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

cPyme 	:= Iif( cPyme 		== Nil, " ", cPyme		)
cF3 	:= Iif( cF3 		== NIl, " ", cF3		)
cGrpSxg	:= Iif( cGrpSxg		== Nil, " ", cGrpSxg	)
cCnt01 	:= Iif( cCnt01		== Nil, "" , cCnt01 	)
cHelp 	:= Iif( cHelp		== Nil, "" , cHelp		)

dbSelectArea( "SX1" )
dbSetOrder( 1 )

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
// RFC - 15/03/2007
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

If !( DbSeek( cGrupo + cOrdem ))

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
	cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
	cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

	Reclock( "SX1" , .T. )

	Replace X1_GRUPO   With cGrupo
	Replace X1_ORDEM   With cOrdem
	Replace X1_PERGUNT With cPergunt
	Replace X1_PERSPA  With cPerSpa
	Replace X1_PERENG  With cPerEng
	Replace X1_VARIAVL With cVar
	Replace X1_TIPO    With cTipo
	Replace X1_TAMANHO With nTamanho
	Replace X1_DECIMAL With nDecimal
	Replace X1_PRESEL  With nPresel
	Replace X1_GSC     With cGSC
	Replace X1_VALID   With cValid

	Replace X1_VAR01   With cVar01

	Replace X1_F3      With cF3
	Replace X1_GRPSXG  With cGrpSxg

	If Fieldpos("X1_PYME") > 0
		If cPyme != Nil
			Replace X1_PYME With cPyme
		Endif
	Endif

	Replace X1_CNT01   With cCnt01
	If cGSC == "C"			// Mult Escolha
		Replace X1_DEF01   With cDef01
		Replace X1_DEFSPA1 With cDefSpa1
		Replace X1_DEFENG1 With cDefEng1

		Replace X1_DEF02   With cDef02
		Replace X1_DEFSPA2 With cDefSpa2
		Replace X1_DEFENG2 With cDefEng2

		Replace X1_DEF03   With cDef03
		Replace X1_DEFSPA3 With cDefSpa3
		Replace X1_DEFENG3 With cDefEng3

		Replace X1_DEF04   With cDef04
		Replace X1_DEFSPA4 With cDefSpa4
		Replace X1_DEFENG4 With cDefEng4

		Replace X1_DEF05   With cDef05
		Replace X1_DEFSPA5 With cDefSpa5
		Replace X1_DEFENG5 With cDefEng5
	Endif

	Replace X1_HELP  With cHelp

	AlfHlpSX1(cKey,aHelpPor,aHelpEng,aHelpSpa)

	MsUnlock()
Else

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
   lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
   lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

   If lPort .Or. lSpa .Or. lIngl
		RecLock("SX1",.F.)
		If lPort 
         SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
		EndIf
		If lSpa 
			SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
		EndIf
		If lIngl
			SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
		EndIf
		SX1->(MsUnLock())
	EndIf
Endif

RestArea( aArea )

Return


Static Function AlfHlpSX1(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdate,cStatus)

Local cFilePor := "SIGAHLP.HLP"
Local cFileEng := "SIGAHLE.HLE"
Local cFileSpa := "SIGAHLS.HLS"
Local nRet
Local nT
Local nI
Local cLast
Local cNewMemo
Local cAlterPath := ''
Local nPos	

If ( ExistBlock('HLPALTERPATH') )
	cAlterPath := Upper(AllTrim(ExecBlock('HLPALTERPATH', .F., .F.)))
	If ( ValType(cAlterPath) != 'C' )
        cAlterPath := ''
	ElseIf ( (nPos:=Rat('\', cAlterPath)) == 1 )
		cAlterPath += '\'
	ElseIf ( nPos == 0	)
		cAlterPath := '\' + cAlterPath + '\'
	EndIf
	
	cFilePor := cAlterPath + cFilePor
	cFileEng := cAlterPath + cFileEng
	cFileSpa := cAlterPath + cFileSpa
	
EndIf

Default aHelpPor := {}
Default aHelpEng := {}
Default aHelpSpa := {}
Default lUpdate  := .T.
Default cStatus  := ""

If Empty(cKey)
	Return
EndIf

If !(cStatus $ "USER|MODIFIED|TEMPLATE")
	cStatus := NIL
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpPor)

For nI:= 1 to nT
   cLast := Padr(aHelpPor[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFilePor, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFilePor, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFilePor, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpEng)

For nI:= 1 to nT
   cLast := Padr(aHelpEng[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFileEng, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFileEng, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFileEng, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpSpa)

For nI:= 1 to nT
   cLast := Padr(aHelpSpa[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFileSpa, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFileSpa, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFileSpa, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf

Return


User Function AlfPqSfz()
LjMsgRun("Aguarde... Pesquisando NFs na Sefaz - Empresa "+cEmpAnt+" Filial "+cFilAnt ,,{||U_AlfXmlJB(cEmpAnt,cFilAnt,.F.)})
Return(Nil)

/*****************************************************************************
* Autor         
* Descricao     Rotina para manifesto manual do XML.
* Data          25/01/2018
*****************************************************************************/
User Function Alf04Man(cOper)

Local aAreaAtu 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aAreaZDI 	:= ZDI->(GetArea())
Local cDescOper	:= ""
Local aParam 	:= Array(6)
Local oRet 		:= Nil
Local lOK 		:= .F.
Local cJustific := ""

If SubStr(ZDH->ZDH_CHAVE,21,2) == "57"
	Alert("Opcao disponivel somente para NF-e")
	Return(Nil)
EndIf

DO CASE 
	CASE cOper == "4" // Confirmação da Operação
		cStatus 	:= "O"
		cMsgOper 	:= "Confirmação da Operação"
		cDescOper 	:= "Realizando Confirmação da Operação"
		cJustific	:= ""
	CASE cOper == "5" // Desconhecimento da Operação
		cStatus 	:= "D"
		cMsgOper 	:= "Desconhecimento da Operação"
		cDescOper 	:= "Realizando Desconhecimento da Operação"
		cJustific	:= ""
	CASE cOper == "6" // Operação não Realizada
		cStatus 	:= "N"
		cMsgOper 	:= "Operação não Realizada"
		cDescOper 	:= "Envio de Operação não Realizada"
		
		While Empty(cJustific)
			cJustific := StrTran(TelaMsg("Justificativa"),CRLF," ")
			If Empty(cJustific)
				Help(Nil,Nil,"Justificativa",,"Por favor, informe a justificativa.", 1, 5) 
			EndIf
		EndDo
ENDCASE

DbSelectArea("SM0")
DbSetOrder(1) // M0_CODIGO+M0_CODFIL
DbSeek(cEmpAnt+cFilAnt)

DbSelectArea("ZDI")
DbSetOrder(2) // ZDI_FILIAL+ZDI_CONTA+ZDI_CHVNFE
If DbSeek(xFilial("ZDI")+SM0->M0_CGC+ZDH->ZDH_CHAVE)
	aParam[1] := ZDI->ZDI_CONTA
	aParam[2] := ZDI->ZDI_UFDEST 
	aParam[3] := ZDI->ZDI_CHVNFE 
	aParam[4] := ZDI->ZDI_DTPROC
	aParam[5] := ZDI->ZDI_HRPROC
	aParam[6] := cJustific
Else
	aParam[1] := SM0->M0_CGC
	aParam[2] := StaticCall( AlfJbXml, CodUF, SM0->M0_ESTCOB) 
	aParam[3] := ZDH->ZDH_CHAVE 
	aParam[4] := ZDH->ZDH_DTIMPO
	aParam[5] := ZDH->ZDH_HRIMPO + "-03:00"
	aParam[6] := cJustific
EndIf
	
FwMsgRun( ,{|| lOK := U_AlfSfz01(cOper,aParam,@oRet) }, , "Por favor, aguarde. "+cDescOper+"..." )

If lOK
	FwMsgRun( ,{|| U_AlfAtStNF(ZDH->ZDH_CHAVE, cStatus, cMsgOper) }, , "Por favor, aguarde. Atualizando Status do XML..." )
EndIf

RestArea(aAreaZDI)
RestArea(aAreaSM0)
RestArea(aAreaAtu)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TelaMsg   º Autor ³				     º Data ³ 25/01/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina para informar mensagem de justificativa.		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TelaMsg(cTitulo)

Local aButtons 	:= {}
Local oDlg		:= Nil
Local oObsMemo 	:= Nil
Local cObsMemo 	:= ""

DEFINE MSDIALOG oDlg FROM 0, 0 TO 400,500 TITLE cTitulo Of oMainWnd PIXEL

	@ 000,000 GET oObsMemo VAR cObsMemo WHEN .T. OF oDlg MEMO SIZE 300,055 PIXEL
	oObsMemo:Align := CONTROL_ALIGN_ALLCLIENT
		
ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End() }, {|| oDlg:End() },,aButtons) )

Return cObsMemo


User Function Alf04GCT(cChvCTe)
Local cMsg := ""
Local aMsg := {}
Local cStMon := ""
Default cChvCTe := ""

If Empty(cChvCTe)
	cChvCTe := ZDH->ZDH_CHAVE
EndIf

aMsg := U_ChkCTeBD(cChvCTe)

If Len(aMsg[2]) == 0
	cMsg := U_GrvPNCte( SM0->M0_CGC, cChvCTe )
	If Empty(cMsg)
		cStMon := "Y"
		cMsg := "Nota Gerada para este CTe"
	Else
		cStMon := "W"
	EndIf
Else
	cStMon := "Y"
	cMsg = aMsg[2]
EndIf

U_AtStCTe( cChvCTe, cMsg, cStMon )

If Empty(cMsg)
	MsgInfo("Pre-Nota gerada com suceso")
Else
	Alert("Pre-Nota não gerada: "+cMsg)
EndIf

Return(Nil)


User Function ALFVCLAS()
If SubStr(ZDH->ZDH_CHAVE,21,2)=="55"
	U_Alf04CPN()
Else
	Alert("CTe não pode ser classificado pelo monitor")
EndIf
Return(Nil)