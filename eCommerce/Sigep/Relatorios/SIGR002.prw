#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE TAM_A4 9

/**********************************************************************************/
/*/{Protheus.doc} SIGR002

@description Relatorio de PLP

@author Bernard M. Margarido
@since 07/04/2017
@version undefined

@type function
/*/
/**********************************************************************************/
User Function SIGR002()
Local cPerg := "SIGR02"

//------------------------------+
// Cria Parametros do relatorio |
//------------------------------+
AjustaSx1(cPerg)

If Pergunte(cPerg,.T.)
	Processa({|| SigR02Prt() },"Aguarde ... Processando relatorio","Vizcaya - eCommerce")
EndIf
	
Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigR02Prt

@description Realiza a impressao do relatorio

@author Bernard M. Margarido
@since 07/04/2017
@version undefined

@type function
/*/
/**********************************************************************************/
Static Function SigR02Prt()

Local aArea				:= GetARea()

Local cAlias			:= GetNextAlias()
Local cDirRaiz			:= GetTempPath()
Local cFile				:= "PLP_" + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".PD_"
Local cDirExp			:= "\spool\"
Local cCodPlp			:= ""

Local nToReg			:= 0
Local nTotPlp			:= 0
Local nLinI 			:= 0
Local nLinF 			:= 0

Local lAdjustToLegacy	:= .F.
Local lDisableSetup		:= .T.

Local oPlp				:= Nil

Private oFont06			:= TFont():New("Arial",,06,,.F.,,,,,.F. )
Private oFont06N		:= TFont():New("Arial",,06,,.T.,,,,,.F. )
Private oFont08			:= TFont():New("Arial",,08,,.F.,,,,,.F. )
Private oFont08N		:= TFont():New("Arial",,08,,.T.,,,,,.F. )
Private oFont14			:= TFont():New("Arial",,14,,.T.,,,,,.F. )

//-----------------------------+
// Consulta PLP a ser impressa |
//-----------------------------+
If !Sigr02Qry(cAlias,@nToReg)
	MsgStop("Não foram encontrados dados para serem processados. Favor Verificar os parametros.","Vizcaya - eCommerce")
	RestArea(aArea)
	Return Nil
EndIf

//------------------+
// Instancia classe | 
//------------------+
oPlp	:=	FWMSPrinter():New(cFile, IMP_PDF, lAdjustToLegacy,cDirExp, lDisableSetup, , , , .T., , .F., )

//---------------------+
// Configura Relatorio |
//---------------------+
oPlp:cPathPdf 			:= cDirRaiz
oPlp:setResolution(78)
oPlp:SetPortrait()
oPlp:setPaperSize(TAM_A4)
oPlp:SetMargin(10,10,10,10)

//---------------------+
// Posiciona orçamento |
//---------------------+
dbSelectArea("SL1")
SL1->( dbOrderNickName("PEDIDOECO") )

//------------------------------+
// Posiciona Tabela de serviços |
//------------------------------+
dbSelectArea("SZ0")
SZ0->( dbSetOrder(2) )

//---------------------------------------+
// Coordendas para linha inicial e final |
//---------------------------------------+
While (cAlias)->( !Eof() )
	
	cCodPlp := (cAlias)->Z8_PLPID
	nTotPlp := 0
	//---------------------+
	// Inicio da Impressao |
	//---------------------+
	SigR02Cabec(oPlp,cCodPlp)
	nLinI := 120
	nLinF := 145
	While (cAlias)->( !Eof() .And. cCodPlp == (cAlias)->Z8_PLPID)
		
		//--------------------+
		// Posiciona registro |
		//--------------------+
		SZ8->( dbGoTo((cAlias)->RECNOSZ8) )
		
		//---------------------+
		// Posiciona orçamento |
		//---------------------+
		SL1->( dbSeek(xFilial("SL1") + SZ8->Z8_NUMECO) )
		
		//-------------------------------+
		// Posiciona Serviço de Postagem |
		//-------------------------------+
		SZ0->( dbSeek(xFilial("SZ0") + SL1->L1_XSERPOS) )
				
		If nLinI >= 850
			//------------------------+
			// Encerra a pagina atual |
			//------------------------+
			oPlp:EndPage()
			
			//-------------------+
			// Imprime cabeçalho |
			//-------------------+
			SigR02Cabec(oPlp,cCodPlp)
			//---------------------------------------+
			// Coordendas para linha inicial e final |
			//---------------------------------------+
			nLinI := 120
			nLinF := 145
		EndIf 
		
		oPlp:Box(nLinI, 025, nLinF, 600)
		
		oPlp:Say(nLinI + 7, 030, SZ8->Z8_TRACKIN											, oFont06, 100 )
		oPlp:Say(nLinI + 7, 087, SL1->L1_CEPE												, oFont06, 100 )
		oPlp:Say(nLinI + 7, 119, Alltrim(Str(SL1->L1_PBRUTO))								, oFont06, 100 )
		oPlp:Say(nLinI + 7, 150, "N"														, oFont06, 100 )
		oPlp:Say(nLinI + 7, 165, "N"														, oFont06, 100 )
		oPlp:Say(nLinI + 7, 180, "S"														, oFont06, 100 )
		oPlp:Say(nLinI + 7, 200, Alltrim(Str(SL1->L1_VLRTOT))								, oFont06, 100 )
		oPlp:Say(nLinI + 7, 260, Alltrim(SL1->L1_DOC)										, oFont06, 100 )
		oPlp:Say(nLinI + 7, 310, Alltrim(Str(SL1->L1_VOLUME))								, oFont06, 100 )
		oPlp:Say(nLinI + 7, 360, "A/C - " + Alltrim(SL1->L1_XNOMDES)						, oFont06, 100 )
		oPlp:Say(nLinF - 5, 030, "Serviço:"													, oFont06N, 100 )
		oPlp:Say(nLinF - 5, 060, Alltrim(SZ0->Z0_CODSERV) + " - " + Alltrim(SZ0->Z0_DESCRI)	, oFont06, 100 )
		oPlp:Say(nLinF - 5, 200, "Obserçoes:"												, oFont06N, 100 )
		oPlp:Say(nLinF - 5, 230, Alltrim(SL1->L1_XCOMPLE)									, oFont06, 100 )
		
		nLinI 	:= nLinF
		nLinF 	:= nLinF + 25
		nTotPlp++ 
	
		(cAlias)->( dbSkip() )
	EndDo
	
	//----------------+
	// Imprime Rodape |
	//----------------+
	SigR02Rod(oPlp,nLinF,nTotPlp)
		
EndDo

//-----------------+
// Exibe relatorio |
//-----------------+
oPlp:Preview()

RestArea(aArea) 
Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigR02Cabec

@description Imprime cabeçalho do relatorio

@author Bernard M. Margarido

@since 07/04/2017
@version undefined

@param oPlp		, object	, objeto contendo dados para impressao do relatorio

@type function
/*/
/**********************************************************************************/
Static Function SigR02Cabec(oPlp,cCodPlp)
Local cSubTit	:= "LISTA DE POSTAGEM"
Local cCodCont	:= GetNewPar("VI_CODCONT","9912208555")
Local cCodAdm	:= GetNewPar("VI_CODADM","08082650")
Local cIdCartao	:= GetNewPar("VI_IDCARTA","0057018901")
Local cBitMap	:= GetSrvProfString("Startpath","")+"\correios.bmp"
Local cEndereco := ""

//---------------------+
// Inicio da Impressao |
//---------------------+
oPlp:StartPage()

//--------------+
// Logo Coreios |
//--------------+
oPlp:SayBitmap(001, 025, cBitMap, 100,025 )

//-------------------+
// Imprime Cabeçalho |
//-------------------+
oPlp:Box(030, 025, 110, 600)
oPlp:Box(110, 025, 120, 600)

//-----------------+
// Dados Cabecalho |
//-----------------+
oPlp:Say(043, 222, cSubTit 							, oFont14 , 100 )
oPlp:Say(060, 030, "N° da Lista:"					, oFont06N, 100 )
oPlp:Say(060, 070, cCodPlp	 						, oFont06 , 100 )
oPlp:Say(060, 160, "Remetente:" 					, oFont06N, 100 )
oPlp:Say(060, 200, Alltrim(SM0->M0_NOMECOM)			, oFont06 , 100 )

oPlp:Say(075, 030, "Contrato:"	 					, oFont06N, 100 )
oPlp:Say(075, 070, cCodCont		 					, oFont06, 100  )
oPlp:Say(075, 160, "Cliente:"	 					, oFont06N, 100 )
oPlp:Say(075, 200, Alltrim(SM0->M0_NOMECOM)	 		, oFont06, 100  )
oPlp:Say(090, 030, "Cod. Adm:"	 					, oFont06N, 100 )
oPlp:Say(090, 070, cCodAdm	 						, oFont06, 100  )
oPlp:Say(090, 160, "Endereço:"	 					, oFont06N, 100 )

cEndereco := Alltrim(SM0->M0_ENDCOB) + " - " + Alltrim(SM0->M0_BAIRCOB) + " - " + Alltrim(SM0->M0_CIDCOB) + "/" + SM0->M0_ESTCOB + " - CEP:" + Alltrim(SM0->M0_CEPCOB)   
oPlp:Say(090, 200, cEndereco	 					, oFont06, 100  )
oPlp:Say(105, 030, "Cartão:"	 					, oFont06N, 100 )
oPlp:Say(105, 070, cIdCartao	 					, oFont06, 100  )
oPlp:Say(105, 520, "Telefone:"	 					, oFont06N, 100 )
oPlp:Say(105, 560, Alltrim(SM0->M0_TEL)				, oFont06, 100  )

//------------------+
// Titulo dos Itens |
//------------------+
oPlp:Say(117, 030, "N° do Objeto"					, oFont06N, 100 )
oPlp:Say(117, 090, "CEP"							, oFont06N, 100 )
oPlp:Say(117, 120, "Peso"							, oFont06N, 100 )
oPlp:Say(117, 150, "AR"								, oFont06N, 100 )
oPlp:Say(117, 165, "MP"								, oFont06N, 100 )
oPlp:Say(117, 180, "VD"								, oFont06N, 100 )
oPlp:Say(117, 200, "Valor Declarado"				, oFont06N, 100 )
oPlp:Say(117, 260, "Nota Fiscal"					, oFont06N, 100 )
oPlp:Say(117, 310, "Volume"							, oFont06N, 100 )
oPlp:Say(117, 360, "Destinatario"					, oFont06N, 100 )

Return oPlp

/**********************************************************************************/
/*/{Protheus.doc} SigR02Rod

@description Imprime Rodape PLP

@author Bernard M. Margarido

@since 07/04/2017
@version undefined

@param oPlp		, object	, objeto contendo dados para impressao do relatorio

@type function
/*/
/**********************************************************************************/
Static Function SigR02Rod(oPlp,nLinF,nTotPlp)
Local nLinR	:= 720

If nLinF >= nLinR
	oPlp:EndPage()
	oPlp:StartPage()
EndIf

//------------+
// Box Rodape |
//------------+
oPlp:Box(nLinR, 025, 840, 600)

nLinR := nLinR + 7
oPlp:Say(nLinR , 030, "Totalizador: " + StrZero(nTotPlp,6)						, oFont06N, 100 )
oPlp:Say(nLinR , 430, "Carimbo e Assinatura / Matrícula dos Correios"			, oFont06N, 100 )

nLinR := nLinR + 25
oPlp:Say(nLinR , 152, "APRESENTAR ESTA LISTA EM CASO DE PEDIDO DE INFORMAÇÕES"	, oFont08N, 100 )

nLinR := nLinR + 15
oPlp:Say(nLinR , 152, "Estou ciente do disposto na cláusula terceira do contrato de prestação de Serviços."	, oFont06N, 100 )

nLinR := nLinR + 40
oPlp:Say(nLinR , 210, Replicate("_",45)											, oFont06N, 100 )

nLinR := nLinR + 07
oPlp:Say(nLinR , 235, "ASSINATURA DO REMETENTE"									, oFont06N, 100 )

nLinR := nLinR + 10
oPlp:Say(nLinR 	, 215, "Obs: 1ª via Unidade de Postagem e 2ª via Cliente"		, oFont06N, 100 )
oPlp:Say(850 	, 030, "Data de Emissao: " + dToc(Date())						, oFont06, 100 )

//---------------------+
// Encerra a Impressao |
//---------------------+
oPlp:EndPage()

Return oPlp

/**********************************************************************************/
/*/{Protheus.doc} Sigr02Qry

@description Consulta PLP a ser impressa

@author Bernard M. Margarido

@since 07/04/2017
@version undefined

@param cAlias, characters, descricao
@param nToReg, numeric, descricao

@type function
/*/
/**********************************************************************************/
Static Function Sigr02Qry(cAlias,nToReg)
Local cQuery := ""

cQuery := "	SELECT " + CRLF
cQuery += "		Z8.Z8_PLPID, " + CRLF
cQuery += "		Z8.R_E_C_N_O_ RECNOSZ8 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SZ8") + " Z8 " + CRLF
cQuery += "	WHERE " + CRLF
cQuery += "		Z8.Z8_FILIAL = '" + xFilial("SZ8") + "' AND " + CRLF
cQuery += "		Z8.Z8_PLPID BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' AND " + CRLF
cQuery += "		Z8.Z8_STATUS = '04' AND " + CRLF
cQuery += "		Z8.D_E_L_E_T_= '' " + CRLF
cQuery += "	ORDER BY Z8.Z8_PLPID "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
Count To nToReg

dbSelectArea(cAlias)
(cAlias)->(dbGoTop() )

If (cAlias)->( Eof() )
	(cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.

/***************************************************************************************/
/*/{Protheus.doc} AjustaSx1

@description Cria parametros para processamento da PLP

@author Bernard M. Maragrido
@since 05/04/2017
@version undefined
@param cPerg		, characters	, Codigo para criação dos parametros
@type function
/*/
/***************************************************************************************/
Static Function AjustaSx1(cPerg)
	PutSx1(cPerg, "01", "Id Plp de ? "	, "Id Plp de ? ", "Id Plp de ? ", "mv_ch1", "C", TamSx3("Z8_PLPID")[1],0,0,"G","","SZ8PLP","","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(cPerg, "02", "Id Plp Ate ? "	, "Id Plp Ate ?", "Id Plp Ate ?", "mv_ch2", "C", TamSx3("Z8_PLPID")[1],0,0,"G","","SZ8PLP","","","mv_par02","","","","","","","","","","","","","","","","",{},{},{})
Return Nil