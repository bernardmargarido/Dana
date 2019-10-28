#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

Static _nTCodCat    := TamSx3("AY0_CODIGO")[1]
Static _nTOrderId	:= TamSx3("WSA_NUMECO")[1]

/*********************************************************************************/
/*/{Protheus.doc} ECLOJXFUN

@description Fun��es utilizadas template e-Commerce

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/

/*********************************************************************************/
/*/{Protheus.doc} ECLOJ01A

@description Cria categoria incial

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
User Function ECLOJ01A()

Local aArea    := GetArea()
Local aAreaAY0 := AY0->(GetArea())

dbSelectArea("AY0")
AY0->( dbSetOrder(1) ) 
If !AY0->( dbSeek(xFilial("AY0") + StrZero(0,_nTCodCat)) )
	RecLock("AY0", .T.)
		AY0->AY0_FILIAL := xFilial("AY0")
		AY0->AY0_CODIGO := StrZero(0, TAMSX3("AY0_CODIGO")[1])
		AY0->AY0_DESC   := "ESTRUTURA DE CATEGORIAS"
		MSMM(,TamSx3("AY0_DESCEC")[1],,"Estrutura de Categorias",1,,,"AY0","AY0_CODDES")
	AY0->( MsUnlock() )
EndIf

RestArea(aAreaAY0)
RestArea(aArea)

Return .T.

/**************************************************************************************************
Fun��o:
AEcoGrvLog

Autor:
Bernard M. Margarido

Data:
02/02/2016

Descri��o:
Rotina realiza a grava��o dos Logs de Integra��o Rakuten

Par�metros:
Param01 - Codigo da Interface
Param02 - Descri��o Interface
Param03 - Data de Integra��o
Param04 - Hora de Inicio da Integra��o
Param05 - Hora de Termino da Integra��o
Param06 - Status da Integra��o(0 - Sucesso, 1 - Erro)
Param07 - Quantidade de Itens Integrados
Param08 - Texto com os Erros (caso haja) 
Param09 - Tipo de Grava��o (1-Inicial,2-Final,3-Inicial/Final)

Retorno:
Nenhum
**************************************************************************************************/
User Function AEcoGrvLog(cCodigo,cDescricao,dDtaInt,cHrIni,cHrFim,cStatus,nQtdItem,aMsgErro,cThread,nField)
	Local aArea 	:= GetArea()

	Local cHrTotal	:= ""

	Default cHrFim	:= ""
	Default cStatus	:= ""
	Default aMsgErro:= {}
	Default nField	:= 3
	Default nQtdItem:= 0

	dbSelectArea("WS0")

	If nField == 1

		RecLock("WS0",.T.)
			WS0->WS0_FILIAL := xFilial("WS0")
			WS0->WS0_COD	:= cCodigo
			WS0->WS0_DESCIN	:= cDescricao
			WS0->WS0_DATA  	:= dDtaInt
			WS0->WS0_HRINI 	:= cHrIni
			WS0->WS0_THREAD	:= cThread	
		WS0->( MsUnLock() )

	ElseIf nField == 2 

		cHrTotal := ElapTime(cHrIni,cHrFim)
		cThread  := PadR(cThread,TamSx3("WS0_THREAD")[1])

		cMsgErro := AEcoMsgErr(aMsgErro)

		WS0->( dbSetOrder(1) )
		If WS0->( dbSeek(xFilial("WS0") + cCodigo + cThread ) )
			RecLock("WS0",.F.)	
				WS0->WS0_HRFIM 	:= cHrFim
				WS0->WS0_QTDINT	:= nQtdItem
				WS0->WS0_STATUS	:= cStatus
				WS0->WS0_HRTOT	:= cHrTotal	
				WS0->WS0_ERROS	:= cMsgErro
			WS0->( MsUnLock() )
		EndIf

	ElseIf nField == 3	

		cHrTotal := ElapTime(cHrIni,cHrFim)

		cMsgErro := AEcoMsgErr(aMsgErro)

		RecLock("WS0",.T.)
			WS0->WS0_FILIAL := xFilial("WS0")
			WS0->WS0_COD	:= cCodigo
			WS0->WS0_DESCIN	:= cDescricao
			WS0->WS0_DATA  	:= dDtaInt
			WS0->WS0_HRINI 	:= cHrIni
			WS0->WS0_TREAD	:= cThread
			WS0->WS0_HRFIM 	:= cHrFim
			WS0->WS0_QTDINT	:= nQtdItem
			WS0->WS0_STATUS	:= cStatus
			WS0->WS0_HRTOT	:= cHrTotal	
			WS0->WS0_ERROS	:= cMsgErro	
		WS0->( MsUnLock() )

	EndIf	 

	RestArea(aArea)
Return .T.

/**************************************************************************************************
Fun��o:
AEcoMsgErr

Autor:
Bernard M. Margarido

Data:
02/02/2016

Descri��o:
Retorna mensagens de erro em Texto

Par�metros:
Param01 - Array de Log com os Erros

Retorno:
cMsgErro - Texto com os erros

**************************************************************************************************/
Static Function AEcoMsgErr(aMsgErro)
	Local cMsgErro	:= ""
	Local nErro		:= 0

	For nErro := 1 To Len(aMsgErro)
		cMsgErro += aMsgErro[nErro][1] + " - " + aMsgErro[nErro][2] + CRLF 
	Next nErro 

Return cMsgErro

/**************************************************************************************************
Fun��o:
AEcoMail

Autor:
Bernard M. Margarido

Data:
02/02/2016

Descri��o:
Rotina realiza o envio de email com os logs

Par�metros:
Param01 - Codigo da Interface
Param02 - Descri��o Interface
Param03 - Array com os erros

Retorno:
Nenhum
**************************************************************************************************/
User Function AEcoMail(cCodInt,cDescInt,aMsgErro,_cPDF)
	Local aArea		:= GetArea()

	Local cServer	:= GetMv("MV_RELSERV")
	Local cUser		:= GetMv("MV_RELAUSR")
	Local cPassword := GetMv("MV_RELAPSW")
	Local cFrom		:= GetMv("MV_RELACNT")

	Local cMail		:= GetNewPar("EC_LOGMAIL")
	Local cMailIbex	:= GetNewPar("EC_MAILIBX","bernard.margarido@vitreoerp.com.br;agendamento@ibexlogistica.com.br")
	Local cBody		:= ""	
	Local cRgbCol	:= ""
	Local cTitulo	:= "Dana Cosmeticos - Integra��es e-Commerce"
	Local cEndLogo	:= "https://danacosmeticos.vteximg.com.br/arquivos/dana-logo-002.png" 

	Local nErro		:= 0

	Local lEnviado	:= .F.
	Local lOk		:= .F.
	Local lZebra	:= .T.
	Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)

	Default	_cPDF	:= ""

	//---------------------------------------------+
	// Montagem do Html que sera enciado com erros |
	//---------------------------------------------+
	cBody := '    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cBody += '    <html xmlns="http://www.w3.org/1999/xhtml">'
	cBody += '    <head>'
	cBody += '        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' 
	cBody += '        <title>' + cTitulo + '</title>'
	cBody += '    </head>'
	cBody += '    <body>'
	cBody += '        <table width="1000" height="10" border="0" bordercolor="#000000" bgcolor="#FFFFFF">'
	cBody += '            <tr align="center">'
	cBody += '                <td align="center" bgcolor="#0d0000">'
	cBody += '                    <img src="' + Alltrim(cEndLogo)  + '" height="070" width="180" />'
	cBody += '                </td>'    
	cBody += '            </tr>'
	//cBody += '         </table>' + CRLF
	//cBody += '         <table width="818" border="0" bordercolor="#333333" bgcolor="#FFFFFF">' + CRLF   
	cBody += '            <tr>'
	cBody += '                <td width="1000" align= "center">'
	cBody += '                    <font color="#999999" size="+2" face="Arial, Helvetica, sans-serif"><b>' + cCodInt + " - " + Capital(cDescInt) + '</b></font>'
	cBody += '                </td>'
	cBody += '            </tr>'
	cBody += '		   </table>'
	cBody += '         <table width="1000" border="0"  bordercolor="#000000" bgcolor="#FFFFFF">'   
	cBody += '            <tr bordercolor="#FFFFFF" bgcolor="#0d0000">'
	cBody += '                <td width="15%" height="30" align= "left">'
	cBody += '                    <font color="#FFFFFF" size="-1" face="Arial, Helvetica, sans-serif"><b>C�digo</b></font><br>'
	cBody += '                </td>'
	cBody += '                <td width="85%" height="30" align= "left">'
	cBody += '                    <font color="#FFFFFF" size="-1" face="Arial, Helvetica, sans-serif"><b>Descri��o</b></font><br>'
	cBody += '                </td>'
	cBody += '            </tr>'

	For nErro := 1 To Len(aMsgErro)

		If lZebra
			lZebra	:= .F.
			cRgbCol := "#FFFFFF"	
		Else
			lZebra	:= .T.
			cRgbCol := "#A9A9A9"
		EndIf	

		cBody += '            <tr bordercolor="#FFFFFF" bgcolor="' + cRgbCol + '">'
		cBody += '                <td width="15%" height="30" align= "left">'
		cBody += '                    <font color="#000000" size="-1" face="Arial, Helvetica, sans-serif">' + Alltrim(aMsgErro[nErro][1])  + '</font>'
		cBody += '                </td>'
		cBody += '                    <td width="85%" height="30" align= "left">'
		cBody += '                    <font color="#000000" size="-1" face="Arial, Helvetica, sans-serif">' + Alltrim(aMsgErro[nErro][2]) + '</font>'
		cBody += '                </td>'
		cBody += '            </tr>'

	Next nErro
	cBody += '        </table>'
	cBody += '        <br><br><br>'
	cBody += '        <font color="#000000" size="-1" face="Arial, Helvetica, sans-serif">VitreoERP - eCommerce <font face="Times New Roman">&copy;</font> - Enviado em ' + dToc(dDataBase) + ' - ' + Time() + '</font>'
	cBody += '    </body>'
	cBody += '    </html>'

	//-------------------------------------------------------------+
	// Verifica usuario e senha para conectar no servidor de saida |
	//-------------------------------------------------------------+
	CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPassword RESULT lOk

	//---------------------------+
	// Autentica usuario e senha |
	//---------------------------+
	If lRelauth
		lOk := MailAuth(cUser,cPassword)
	EndIf	

	//-------------------------------------------------------------+
	// Verifica se conseguiu conectar no servidor de saida e valida|
	// se conseguiu atenticar para enviar o e-mail                 |
	//-------------------------------------------------------------+
	If lOk
		If !Empty(_cPDF)
			If File(_cPDF)
				SEND MAIL FROM cFrom TO cMailIbex SUBJECT cTitulo BODY cBody ATTACHMENT _cPDF RESULT lEnviado  
			EndIf	
		Else
			SEND MAIL FROM cFrom TO cMail SUBJECT cTitulo BODY cBody RESULT lEnviado 
		EndIf	
	Else
		Conout("Erro ao Conectar ! ")
	Endif			

	If lEnviado
		Conout("E-Mail Enviado com sucesso ")
	Else                            
		GET MAIL ERROR cError
		Conout("Erro ao enviar e-mail --> " + cError)	
	EndIf	

	//--------------------+
	// Deleta arquivo PDF |
	//--------------------+
	/*
	If File(_cPDF)
		Ferase(_cPDF)
	EndIf
	*/

	//---------------------------------+
	// Disconecta do servidor de saida |
	//---------------------------------+
	DISCONNECT SMTP SERVER

	RestArea(aArea)

Return .T.

/*****************************************************************************/
/*/{Protheus.doc} SYACENTO

@description Rotina formata texto para o padrao Protheus

@author Symm Consultoria
@since 18/08/2016
@version undefined

@param cTexto		, Texto a ser formatado
@param lUpper		, Se verdadeiro retorna texto em Maiusculo

@type function
/*/
/****************************************************************************/
User Function ECACENTO(cTexto, lUpper,lMun)

	Local nCount 	:= 0 					
	Local z      	:= 0

	Local aAcentos 	:= {}

	Default lMun	:= .F.

	If ValType(cTexto) <> "C"
		Return(cTexto)
	EndIf

	If lUpper == Nil
		lUpper := .T.
	EndIf

	//----------------------------------------------------------+
	//  Carrega os acentos e respectivos caracteres substitutos |
	//----------------------------------------------------------+
	AADD(aAcentos, {"����"	, "a"})
	AADD(aAcentos, {"����"	, "A"})
	AADD(aAcentos, {"���"	, "e"})
	AADD(aAcentos, {"���"	, "E"})
	AADD(aAcentos, {"���"	, "i"})
	AADD(aAcentos, {"���"	, "I"})
	AADD(aAcentos, {"����"	, "o"})
	AADD(aAcentos, {"����"	, "O"})
	AADD(aAcentos, {"����"	, "u"})
	AADD(aAcentos, {"����"	, "U"})
	AADD(aAcentos, {"�"		, "c"})
	AADD(aAcentos, {"�"		, "C"})
	AADD(aAcentos, {"�"		, "N"})
	AADD(aAcentos, {"�"		, "n"})
	AAdd(aAcentos, {"?!:,./\|@#$%&"," "})
	If !lMun
		AAdd(aAcentos, {"'",""})
		AAdd(aAcentos, {"-",""})	
	EndIf	
	AAdd(aAcentos, {"  "," "})

	//-------------------------------------------+
	// Troca os caracteres caso encontre acentos |
	//-------------------------------------------+
	For nCount := 1 to Len(aAcentos)
		For z := 1 to Len(aAcentos[nCount][1])
			cTexto := StrTran(cTexto, SubStr(aAcentos[nCount][1], z, 1), aAcentos[nCount][2])
		Next z
	Next nCount

Return( If(lUpper, Upper(cTexto), cTexto) )

/**********************************************************************************************/
/*/{Protheus.doc} SYFORMAT

@description Rotina retira caracteres especiais dos campos 

@author Symm Consultoria
@since 18/08/2016
@version undefined

@param cTexto		, Texto a ser formatado
@param cCpo			, Campo Protheus
@param lFormata		, Se formata campo 
@param cTipo		, Tipo do campo 

@type function
/*/
/***********************************************************************************************/
User Function ECFORMAT(cTexto, cCpo, lFormata, cTipo)

	Local cAux     := ""
	Local nI       := 0     
	Local cAcentos := "��������������������������������������"
	Local cOutros  := "?!:,./\|@#$%& "

	Default lFormata := .F.     
	Default cTipo    := "N" 

	Do Case
		Case cTipo == "N"
		For nI := 1 To Len(cTexto)                   
			If (ASC( SubStr(cTexto, nI, 1) ) >= 48) .And. (ASC( SubStr(cTexto, nI, 1) ) <= 57)
				cAux += SubStr(cTexto, nI, 1)
			EndIf
		Next nI                                        

		Case cTipo == "C"
		For nI := 1 To Len(cTexto)                   
			If (ASC( SubStr(cTexto, nI, 1) ) >= 48)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 57)  .Or.; 
			(ASC( SubStr(cTexto, nI, 1) ) >= 65)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 90)  .Or.;
			(ASC( SubStr(cTexto, nI, 1) ) >= 97)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 122) 
				If (SubStr(cTexto, nI, 1) $ Alltrim(cOutros)) .Or. (SubStr(cTexto, nI, 1) $ Alltrim(cAcentos))
					If SubStr(cTexto, nI, 1) == "&"
						cAux += "e"
					Else
						cAux += SubStr(cTexto, nI, 1)
					EndIf
				Else
					cAux += SubStr(cTexto, nI, 1)
				EndIf
			EndIf
		Next nI                                        
	EndCase		

	If lFormata
		cAux := PadR(AllTrim(cAux), TamSx3(cCpo)[01])
	EndIf

Return cAux

/******************************************************************************/
/*/{Protheus.doc} AEcoStaLog
Rotina grava a status do pedido e-commerce

@author	Bernard M. Margarido
@since		18/02/2016
@version	1.00

@param			cCodSta		, Codigo do Status 
@param			cOrderId	, Numero do Pedido eCommerce
@param			cNumOrc		, Numero do Orcamento

/*/
/******************************************************************************/
User Function AEcoStaLog(cCodSta,cOrderId,cNumOrc,dDtaEmiss,cHora)
	Local aArea			:= GetArea()

	Default dDtaEmiss 	:= dDataBase
	Default cHora		:= Time() 

	dbSelectArea("WS2")
	WS2->( dbSetOrder(2) )
	If !WS2->( dbSeek(xFilial("WS2") + cNumOrc + cCodSta ) )
		RecLock("WS2",.T.)
			WS2->WS2_FILIAL := xFilial("WS2")
			WS2->WS2_NUMECO	:= cOrderId
			WS2->WS2_NUMSL1	:= cNumOrc
			WS2->WS2_DATA	:= dDtaEmiss
			WS2->WS2_HORA	:= cHora
			WS2->WS2_CODSTA	:= cCodSta
		WS2->( MsUnLock() )	   	
	EndIf	
	RestArea(aArea)
Return .T.

/**************************************************************************/
/*/{Protheus.doc} aEcoExPv

@description Estorna Pedido de Venda

@author Bernard M. Margarido
@since 25/08/2016
@version undefined

@param cNumPv		, Numero do Pedido de Venda

@type function
/*/
/**************************************************************************/
User Function aEcoExPv(cNumPv)
	Local aArea			:= GetArea()
	Local aRet			:= {.T.,"",""}
	Local cNumOrc		:= ""
	
	Local aCabec		:= {}
	Local aItem			:= {}
	Local aItems		:= {}
	
	Private lMsErroAuto	:= .F.

	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )
	If !SC5->( dbSeek(xFilial("SC5") + cNumPv) )
		aRet[1] := .T.
		aRet[2] := cNumPv
		aRet[3] := "PEDIDO " + cNumPv + " NAO LOCALIZADO. "
		RestArea(aArea)
		Return aRet
	EndIf
	
	//-------------------+
	// Estorna Liberacao |   
	//-------------------+
	aEcEstLibPv(SC5->C5_NUM)
	
	//---------------------------+
	// Grava Numero do Or�amento |
	//---------------------------+
	cNumOrc := SC5->C5_ORCRES
	
	//--------------------+
	// Dados do Cabe�alho |   
	//--------------------+
	aAdd(aCabec,{ "C5_FILIAL"	, xFilial("SC5")					,Nil,""})
	aAdd(aCabec,{ "C5_NUM"		, SC5->C5_NUM						,Nil,""})
	aAdd(aCabec,{ "C5_TIPO"		, SC5->C5_TIPO						,Nil,""})
	aAdd(aCabec,{ "C5_CLIENTE"	, SC5->C5_CLIENTE					,Nil,""})
	aAdd(aCabec,{ "C5_LOJACLI"	, SC5->C5_LOJACLI					,Nil,""})
	aAdd(aCabec,{ "C5_TIPOCLI"	, SC5->C5_TIPOCLI					,Nil,""})
	aAdd(aCabec,{ "C5_EMISSAO"	, SC5->C5_EMISSAO					,Nil,""})
	aAdd(aCabec,{ "C5_CONDPAG"	, SC5->C5_CONDPAG					,Nil,""})
	aAdd(aCabec,{ "C5_NUMECO"	, SC5->C5_NUMECO					,Nil,""})
	aAdd(aCabec,{ "C5_NUMECLI"	, SC5->C5_NUMECLI					,Nil,""})
	aAdd(aCabec,{ "C5_TPFRETE"	, SC5->C5_TPFRETE					,Nil,""})
	aAdd(aCabec,{ "C5_TRANSP"	, SC5->C5_TRANSP					,Nil,""})
	aAdd(aCabec,{ "C5_FRETE"	, SC5->C5_FRETE						,Nil,""})
	aAdd(aCabec,{ "C5_DESPESA"	, SC5->C5_DESPESA					,Nil,""})
	aAdd(aCabec,{ "C5_PESOL"	, SC5->C5_PESOL						,Nil,""})
	aAdd(aCabec,{ "C5_PBRUTO"	, SC5->C5_PBRUTO					,Nil,""})
	aAdd(aCabec,{ "C5_VOLUME1"	, SC5->C5_VOLUME1					,Nil,""})
	aAdd(aCabec,{ "C5_ESPECI1"	, SC5->C5_ESPECI1					,Nil,""})
	aAdd(aCabec,{ "C5_ORCRES"	, SC5->C5_ORCRES					,Nil,""})
		
	//--------------------------+
	// Itens do Pedido de Venda |   
	//--------------------------+
	dbSelectArea("SC6")
	SC6->( dbSetOrder(1) )
	SC6->( dbSeek(xFilial("SC6") + SC5->C5_NUM) )
	While SC6->( !Eof() .And. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM )

		aItem := {}	
		
		aAdd(aItem,{ "C6_FILIAL"	, xFilial("SC6")		,Nil,""})
		aAdd(aItem,{ "C6_ITEM"  	, SC6->C6_ITEM			,Nil,""})
		aAdd(aItem,{ "C6_PRODUTO"	, SC6->C6_PRODUTO		,Nil,""})
		aAdd(aItem,{ "C6_QTDVEN"	, SC6->C6_QTDVEN		,Nil,""})
		aAdd(aItem,{ "C6_PRCVEN"	, SC6->C6_PRCVEN		,Nil,""})
		aAdd(aItem,{ "C6_PRUNIT"	, SC6->C6_PRUNIT		,Nil,""})
		aAdd(aItem,{ "C6_LOCAL"		, SC6->C6_LOCAL			,Nil,""})
		aAdd(aItem,{ "C6_TES"		, SC6->C6_TES			,Nil,""})
		aAdd(aItem,{ "C6_ENTREG"	, SC6->C6_ENTREG		,Nil,""})
		aAdd(aItems,aItem)
		
		SC6->( dbSkip() )
		
	EndDo

	//----------------------+
	// Gera pedido de venda |
	//----------------------+
	If Len(aCabec) > 0 .And. Len(aItems) > 0

		lMsErroAuto := .F.

		MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItems,5)

		If lMsErroAuto

			RollBackSx8()
			MakeDir("/erros/")
			cArqLog := "SC5" + SC5->C5_NUM + " " + DToS(dDataBase)+Left(Time(),2)+SubStr(Time(),4,2)+Right(Time(),2)+".LOG"
			MostraErro("/erros/",cArqLog)
			DisarmTransaction()

			//------------------------------------------------+
			// Adiciona Arquivo de log no Retorno da resposta |
			//------------------------------------------------+
			cMsgErro := ""
			nHndImp  := FT_FUSE("/erros/" + cArqLog)

			If nHndImp >= 1
				Conout("Arquivo Texto de log " + cArqLog)
				
				//-----------------------------+
				// Posiciona Inicio do Arquivo |
				//-----------------------------+
				FT_FGOTOP()

				While !FT_FEOF()
					cLiArq := FT_FREADLN()
					If Empty(cLiArq)
						FT_FSKIP(1)
						Loop
					EndIf
					cMsgErro += cLiArq + CRLF
					FT_FSKIP(1)
				EndDo
				FT_FUSE()
			EndIf                                   
			
			aRet[1] := .F.
			aRet[2] := SC5->C5_NUM
			aRet[3] := "ERRO AO CANCELAR PEDIDO " + SC5->C5_NUM + ". " + CRLF + cMsgErro

		Else
	
			//----------------------------------------------------+
			// Atualiza or�amento com o numero do pedido de venda |
			//----------------------------------------------------+
			dbSelectArea("SL1")
			SL1->( dbSetOrder(1) )
			SL1->( dbSeek(xFilial("SL1") + cNumOrc) )
			RecLock("SL1",.F.)
				SL1->L1_PEDRES := ""
			SL1->( MsUnLock() )	
	
			aRet[1] := .T.
			aRet[2] := SC5->C5_NUM
			aRet[3] := ""
						
		EndIf

	EndIf

RestArea(aArea)
Return aRet

/********************************************************************************/
/*/{Protheus.doc} aEcoExCr

@description Valida se pedido pode ser excluido

@author Bernard
@since 25/08/2016
@version undefined

@param cOrderId			, Numero do Pedido e-Commerce
@param cOrdPvCli		, Numero do Pedido do cliente no e-Commerce
@param cNumOrc			, Numero do Or�amento
@param lPedido			, Numero do Or�amento

@type function
/*/
/********************************************************************************/
User Function aEcoExCr(cOrderId,cOrdPvCli,cNumOrc,lPedido)
	Local aArea		:= GetArea()
	Local aRet		:= {.T.,"",""}
	
	Local cPrefixo	:= GetNewPar("EC_PREFIXO","ECO")
	
	Local cFilAux	:= cFilAnt
		
	//-----------------------------------+
	// Valida se existem titulos baixado |
	//-----------------------------------+
	If AEcoVldTit(cOrderId,cOrdPvCli,cNumOrc) .And. !lPedido
	
		aRet[1] := .F.
		aRet[2] := cNumOrc
		aRet[3] := "NAO FOI POSSIVEL CANCELAR O PEDIDO " + cNumOrc + ", PEDIDO CONTEM TITULOS BAIXADOS."
		RestArea(aArea)
		Return aRet
		
	ElseIf lPedido
		//--------------------------------------------+
		// Gera NCC para o cliente no valor da compra |
		//--------------------------------------------+
		aRet := aEcoNcc(cOrderId,cOrdPvCli,cNumOrc)
	Else
		//-----------------------------------------+
		// Estorna titulos para o pedido cancelado |
		//-----------------------------------------+
		dbSelectArea("SE1")
		SE1->( dbSetOrder(1) )
		If SE1->( dbSeek(xFilial("SE1") + cPrefixo + PadR(cOrdPvCli,nTamTitu)) )
			While SE1->( !Eof() .And. xFilial("SE1") + cPrefixo + PadR(cOrdPvCli,nTamTitu) == SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM )
				RecLock("SE1",.F.)
					SE1->( dbDelete() )
				SE1->( MsUnLock() )	
				SE1->( dbSkip() )
			EndDo	
		EndIf
	EndIf
	
	//------------------------+
	// Posiciona Filial atual |
	//------------------------+
	cFilAnt := cFilAux
		
RestArea(aArea)
Return aRet

/***********************************************************************************/
/*/{Protheus.doc} VldLibPv
    @description Valida se pedido de venda esta liberado ou bloquedo
    @type  Function
    @author Bernard M. Margarido
    @since 06/07/2019
    @version version
/*/
/***********************************************************************************/
User Function VldLibPv(_cPedVen,_lLiber,_lBlqEst)
Local _aArea	:= GetArea()

//---------------------+
// Reseta as variaveis |
//---------------------+
_lLiber		:= .F.
_lBlqEst	:= .F.

//---------------------------+
// Posiciona itens liberados |
//---------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )
If SC9->( dbSeek(xFilial("SC9") + _cPedVen) )
	//-----------------+
	// Pedido liberado |
	//-----------------+
	_lLiber	:= .T.

	While SC9->( !Eof() .And. xFilial("SC9") + _cPedVen == SC9->C9_FILIAL + SC9->C9_PEDIDO )
		//---------------------+
		// Bloqueio de Estoque |
		//---------------------+
		If SC9->C9_BLEST == "02"
			_lBlqEst := .T.
		Endif	

		SC9->( dbSkip() )
	EndDo
EndIf

RestArea(_aArea)
Return Nil

/***********************************************************************************/
/*/{Protheus.doc} GrvStaEc
    @description Valida se pedido de venda esta liberado ou bloquedo
    @type  Function
    @author Bernard M. Margarido
    @since 06/07/2019
    @version version
/*/
/***********************************************************************************/
User Function GrvStaEc(_cOrderId,_cCodSta)
Local _aArea	:= GetArea()

//---------------+
// Valida Status |
//---------------+
dbSelectArea("WS1")
WS1->( dbSetOrder(1))
If !WS1->( dbSeek(xFilial("WS1") + _cCodSta))
	CoNout("STATUS " + _cCodSta + " NAO LOCALIZADO.")
	RestArea(_aArea)
	Return Nil
EndIf

//-----------------------------+
// Posiciona pedido e-Commerce | 
//-----------------------------+
dbSelectArea("WSA")
WSA->( dbOrderNickName("PEDIDOECO") )
If WSA->( dbSeek(xFilial("WSA") + PadR(_cOrderId,_nTOrderId)) )
	RecLock("WSA",.F.)
		WSA->WSA_CODSTA		:= WS1->WS1_CODIGO
		WSA->WSA_DESTAT		:= RTrim(WS1->WS1_DESCRI)
	WSA->( MsUnLock() )
EndIf

//------------------------+
// Grava Status do Pedido |
//------------------------+
u_AEcoStaLog(WS1->WS1_CODIGO,WSA->WSA_NUMECO,WSA->WSA_NUM,dDataBase,Time())

//--------------------------------+
// Envia Status para o e-Commerce |
//--------------------------------+
If WS1->WS1_ENVECO == "S"
	U_AECOI11B(WSA->WSA_NUM,.F.)
EndIf

RestArea(_aArea)
Return Nil

/**************************************************************************************************/
/*/{Protheus.doc} AEcoPerDes

@description	Calcula percentual de desconto

@author			Bernard M.Margarido
@version   		1.00
@since     		10/02/2016

@param			nVlr		, Valor Total
@param			nVlrDesc	, Valor do Desconto

@return			nPerDes		, Retorna percentual de desconto calculado 
/*/
/**************************************************************************************************/
User Function AEcoPerDes(nVlr,nVlrDesc)
	Local nPerDesc 	:= 0
	Local nVlrDif	:= 0
	
	nVlrDif		:= nVlr - nVlrDesc
	nPerDesc 	:= Round((nVlrDif / nVlr) * 100,2)
	nPerDesc	:= IIF(nPerDesc >= 100,99.99,nPerDesc)	
Return nPerDesc

/*********************************************************************************/
/*/{Protheus.doc} ECLOJXFUN

@description Fun��es utilizadas template e-Commerce

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
User Function EcVldNF(_cDoc,_cSerie,_cOrderId)
Local _aArea	:= GetArea()

Local _cCodSta	:= "005"

//-------------------------------+
// Atualiza dados da nota fiscal |
//-------------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cDoc + _cSerie ) )
	RestArea(_aArea)
	Return .F.	
EndIf

RecLock("SF2",.F.)
	SF2->F2_XNUMECO := _cOrderId
SF2->( MsUnLock() )	 

//-------------------------------+
// Atualiza status para faturado | 
//-------------------------------+
dbSelectArea("WS1")
WS1->( dbSetOrder(1) )
WS1->( dbSeek(xFilial("WS1") + _cCodSta) )

//-------------------------------------+
// Atualiza dados da nota no or�amento |
//-------------------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )
If WSA->( dbSeek(xFilial("WSA") +_cOrderId) )
	RecLock("WSA",.F.)
		WSA->WSA_DOC	:= _cDoc
		WSA->WSA_SERIE	:= _cSerie
		WSA->WSA_CODSTA	:= _cCodSta
		WSA->WSA_DESTAT	:= WS1->WS1_DESCRI
		WSA->WSA_ENVLOG	:= "3"
	WSA->( MsUnlock() )
EndIf

//------------------------+
// Grava Status do Pedido |
//------------------------+
u_AEcoStaLog(_cCodSta,_cOrderId,WSA->WSA_NUM,dDataBase,Time())
If WS1->WS1_ENVECO == "S"
	U_AECOI013(_cOrderId)
EndIf

RestArea(_aArea)
Return .T.

/*********************************************************************************/
/*/{Protheus.doc} EcLoj140

@description Ponto de Entrada - Exlcus�o or�amento/nota venda assistida

@author Bernard M. Margarido    
@since 23/04/2019
@version 1.0
@type function
/*/
/*********************************************************************************/
User Function EcLoj140()
Local _aArea    := GetArea()
Local _cCodSta	:= GetNewPar("EC_STACANC","008")

//-----------------------------+
// Posiciona pedido e-Commerce |
//-----------------------------+
dbSelectArea("WSA")
WSA->(dbSetOrder(2) )
If WSA->(dbSeek(xFilial("WSA") + SL1->L1_XNUMECO) )
    //---------------------------+
    // Valida se � or�amento PAI | 
    //---------------------------+
    If WSA->WSA_NUMSL1 == SL1->L1_NUM 
        
		//-----------------------------+
		// Posiciona tabela de status  |
		//-----------------------------+
		dbSelectArea("WS1")
		WS1->( dbSetOrder(1) )
		WS1->( dbSeek(xFilial("WS1") + _cCodSta) )

		//---------------------------------+
        // Atualiza dados do or�amento pai |
        //---------------------------------+
        RecLock("WSA",.F.)
            WSA->WSA_NUMSL1 := ""
            WSA->WSA_NUMSC5 := ""
            WSA->WSA_CODSTA := WS1->WS1_CODIGO
            WSA->WSA_DESTAT := WS1->WS1_DESCRI
        WSA->( MsUnLock() )

		//---------------------------+
		// Grava historico do pedido | 
		//---------------------------+
        u_AEcoStaLog(_cCodSta,WSA->WSA_NUMECO,WSA->WSA_NUM,dDataBase,Time())
		/*
		If WS1->WS1_ENVECO == "S"
			U_AECOI11B(WSA->WSA_NUM)
		EndIf
		*/
    EndIF
EndIf

RestArea(_aArea)
Return .T.