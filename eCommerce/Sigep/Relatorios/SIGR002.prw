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
Local _cPerg := "SIGR02"

//------------------------------+
// Cria Parametros do relatorio |
//------------------------------+
AjustaSx1(_cPerg)

If Pergunte(_cPerg,.T.)
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
Local _cAlias			:= GetNextAlias()
Local _cDirRaiz			:= GetTempPath()
Local _cFile			:= "PLP_" + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".PD_"
Local _cDirExp			:= "\spool\"
Local _cCodPlp			:= ""

Local _nToReg			:= 0
Local _nTotPlp			:= 0
Local _nLinI 			:= 0
Local _nLinF 			:= 0

Local _lAdjustToLegacy	:= .F.
Local _lDisableSetup	:= .T.

Local _oPrint			:= Nil

Private _oFont06		:= TFont():New("Arial",,06,,.F.,,,,,.F. )
Private _oFont06N		:= TFont():New("Arial",,06,,.T.,,,,,.F. )
Private _oFont08		:= TFont():New("Arial",,08,,.F.,,,,,.F. )
Private _oFont08N		:= TFont():New("Arial",,08,,.T.,,,,,.F. )
Private _oFont14		:= TFont():New("Arial",,14,,.T.,,,,,.F. )

//-----------------------------+
// Consulta PLP a ser impressa |
//-----------------------------+
If !Sigr02Qry(_cAlias,@_nToReg)
	MsgStop("Não foram encontrados dados para serem processados. Favor Verificar os parametros.","Vizcaya - eCommerce")
	(_cAlias)->( dbCloseArea() )
	Return Nil
EndIf

//------------------+
// Instancia classe | 
//------------------+
_oPrint	:=	FWMSPrinter():New(_cFile, IMP_PDF, _lAdjustToLegacy,_cDirExp, _lDisableSetup, , , , .T., , .F., )

//---------------------+
// Configura Relatorio |
//---------------------+
_oPrint:cPathPdf 			:= _cDirRaiz
_oPrint:setResolution(78)
_oPrint:SetPortrait()
_oPrint:setPaperSize(TAM_A4)
_oPrint:SetMargin(10,10,10,10)

//---------------------------------------+
// Coordendas para linha inicial e final |
//---------------------------------------+
While (_cAlias)->( !Eof() )
	
	_cCodPlp := (_cAlias)->ZZ2_CODIGO
	_nTotPlp := 0

	//---------------------+
	// Inicio da Impressao |
	//---------------------+
	SigR02Cabec(_oPrint,_cCodPlp)
	_nLinI := 120
	_nLinF := 145
	While (_cAlias)->( !Eof() .And. _cCodPlp == (_cAlias)->ZZ2_CODIGO )
							
		If _nLinI >= 850
			//------------------------+
			// Encerra a pagina atual |
			//------------------------+
			_oPrint:EndPage()
			
			//-------------------+
			// Imprime cabeçalho |
			//-------------------+
			SigR02Cabec(_oPrint,_cCodPlp)

			//---------------------------------------+
			// Coordendas para linha inicial e final |
			//---------------------------------------+
			_nLinI := 120
			_nLinF := 145

		EndIf 
		
		_oPrint:Box(_nLinI, 025, _nLinF, 600)
		
		_oPrint:Say(_nLinI + 7, 030, SZ8->Z8_TRACKIN											, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 087, SL1->L1_CEPE												, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 119, Alltrim(Str(SL1->L1_PBRUTO))								, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 150, "N"														, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 165, "N"														, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 180, "S"														, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 200, Alltrim(Str(SL1->L1_VLRTOT))								, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 260, Alltrim(SL1->L1_DOC)										, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 310, Alltrim(Str(SL1->L1_VOLUME))								, _oFont06, 100 )
		_oPrint:Say(_nLinI + 7, 360, "A/C - " + Alltrim(SL1->L1_XNOMDES)						, _oFont06, 100 )
		_oPrint:Say(_nLinI - 5, 030, "Serviço:"													, _oFont06N, 100 )
		_oPrint:Say(_nLinI - 5, 060, Alltrim(SZ0->Z0_CODSERV) + " - " + Alltrim(SZ0->Z0_DESCRI)	, _oFont06, 100 )
		_oPrint:Say(_nLinI - 5, 200, "Obserçoes:"												, _oFont06N, 100 )
		_oPrint:Say(_nLinI - 5, 230, Alltrim(SL1->L1_XCOMPLE)									, _oFont06, 100 )
		
		_nLinI 	:= _nLinF
		_nLinF 	:= _nLinF + 25
		_nTotPlp++ 
	
		(_cAlias)->( dbSkip() )
	EndDo
	
	//----------------+
	// Imprime Rodape |
	//----------------+
	SigR02Rod(_oPrint,_nLinF,_nTotPlp)
		
EndDo

//-----------------+
// Exibe relatorio |
//-----------------+
_oPrint:Preview()

RestArea(aArea) 
Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigR02Cabec

@description Imprime cabeçalho do relatorio

@author Bernard M. Margarido

@since 07/04/2017
@version undefined

@param _oPrint		, object	, objeto contendo dados para impressao do relatorio

@type function
/*/
/**********************************************************************************/
Static Function SigR02Cabec(_oPrint,_cCodPlp)
Local _cSubTit		:= "LISTA DE POSTAGEM"
Local _cCodCont		:= GetNewPar("EC_CODCONT","9912208555")
Local _cCodAdm		:= GetNewPar("EC_CODADM","08082650")
Local _cIdCartao	:= GetNewPar("EC_IDCARTA","0057018901")
Local _cBitMap		:= GetSrvProfString("Startpath","")+"\correios.bmp"
Local _cEndereco 	:= ""

//---------------------+
// Inicio da Impressao |
//---------------------+
_oPrint:StartPage()

//--------------+
// Logo Coreios |
//--------------+
_oPrint:SayBitmap(001, 025, _cBitMap, 100,025 )

//-------------------+
// Imprime Cabeçalho |
//-------------------+
_oPrint:Box(030, 025, 110, 600)
_oPrint:Box(110, 025, 120, 600)

//-----------------+
// Dados Cabecalho |
//-----------------+
_oPrint:Say(043, 222, _cSubTit 							, _oFont14 , 100 )
_oPrint:Say(060, 030, "N° da Lista:"					, _oFont06N, 100 )
_oPrint:Say(060, 070, _cCodPlp	 						, _oFont06 , 100 )
_oPrint:Say(060, 160, "Remetente:" 						, _oFont06N, 100 )
_oPrint:Say(060, 200, Alltrim(SM0->M0_NOMECOM)			, _oFont06 , 100 )

_oPrint:Say(075, 030, "Contrato:"	 					, _oFont06N, 100 )
_oPrint:Say(075, 070, _cCodCont		 					, _oFont06, 100  )
_oPrint:Say(075, 160, "Cliente:"	 					, _oFont06N, 100 )
_oPrint:Say(075, 200, Alltrim(SM0->M0_NOMECOM)	 		, _oFont06, 100  )
_oPrint:Say(090, 030, "Cod. Adm:"	 					, _oFont06N, 100 )
_oPrint:Say(090, 070, _cCodAdm	 						, _oFont06, 100  )
_oPrint:Say(090, 160, "Endereço:"	 					, _oFont06N, 100 )

cEndereco := Alltrim(SM0->M0_ENDCOB) + " - " + Alltrim(SM0->M0_BAIRCOB) + " - " + Alltrim(SM0->M0_CIDCOB) + "/" + SM0->M0_ESTCOB + " - CEP:" + Alltrim(SM0->M0_CEPCOB)   
_oPrint:Say(090, 200, _cEndereco	 					, _oFont06, 100  )
_oPrint:Say(105, 030, "Cartão:"	 						, _oFont06N, 100 )
_oPrint:Say(105, 070, _cIdCartao	 					, _oFont06, 100  )
_oPrint:Say(105, 520, "Telefone:"	 					, _oFont06N, 100 )
_oPrint:Say(105, 560, Alltrim(SM0->M0_TEL)				, _oFont06, 100  )

//------------------+
// Titulo dos Itens |
//------------------+
_oPrint:Say(117, 030, "N° do Objeto"					, _oFont06N, 100 )
_oPrint:Say(117, 090, "CEP"								, _oFont06N, 100 )
_oPrint:Say(117, 120, "Peso"							, _oFont06N, 100 )
_oPrint:Say(117, 150, "AR"								, _oFont06N, 100 )
_oPrint:Say(117, 165, "MP"								, _oFont06N, 100 )
_oPrint:Say(117, 180, "VD"								, _oFont06N, 100 )
_oPrint:Say(117, 200, "Valor Declarado"					, _oFont06N, 100 )
_oPrint:Say(117, 260, "Nota Fiscal"						, _oFont06N, 100 )
_oPrint:Say(117, 310, "Volume"							, _oFont06N, 100 )
_oPrint:Say(117, 360, "Destinatario"					, _oFont06N, 100 )

Return _oPrint

/**********************************************************************************/
/*/{Protheus.doc} SigR02Rod

@description Imprime Rodape PLP

@author Bernard M. Margarido

@since 07/04/2017
@version undefined

@param _oPrint		, object	, objeto contendo dados para impressao do relatorio

@type function
/*/
/**********************************************************************************/
Static Function SigR02Rod(_oPrint,_nLinF,_nTotPlp)
Local _nLinR	:= 720

If _nLinF >= _nLinR
	_oPrint:EndPage()
	_oPrint:StartPage()
EndIf

//------------+
// Box Rodape |
//------------+
_oPrint:Box(_nLinR, 025, 840, 600)

_nLinR := nLinR + 7
_oPrint:Say(_nLinR , 030, "Totalizador: " + StrZero(nTotPlp,6)						, _oFont06N, 100 )
_oPrint:Say(_nLinR , 430, "Carimbo e Assinatura / Matrícula dos Correios"			, _oFont06N, 100 )

_nLinR := _nLinR + 25
_oPrint:Say(_nLinR , 152, "APRESENTAR ESTA LISTA EM CASO DE PEDIDO DE INFORMAÇÕES"	, _oFont08N, 100 )

_nLinR := _nLinR + 15
_oPrint:Say(_nLinR , 152, "Estou ciente do disposto na cláusula terceira do contrato de prestação de Serviços."	, _oFont06N, 100 )

_nLinR := _nLinR + 40
_oPrint:Say(_nLinR , 210, Replicate("_",45)											, _oFont06N, 100 )

_nLinR := _nLinR + 07
_oPrint:Say(_nLinR , 235, "ASSINATURA DO REMETENTE"									, _oFont06N, 100 )

_nLinR := _nLinR + 10
_oPrint:Say(_nLinR 	, 215, "Obs: 1ª via Unidade de Postagem e 2ª via Cliente"		, _oFont06N, 100 )
_oPrint:Say(850 	, 030, "Data de Emissao: " + dToc(Date())						, _oFont06, 100 )

//---------------------+
// Encerra a Impressao |
//---------------------+
_oPrint:EndPage()

Return _oPrint

/**********************************************************************************/
/*/{Protheus.doc} Sigr02Qry

@description Consulta PLP a ser impressa

@author Bernard M. Margarido

@since 07/04/2017
@version undefined

@param _cAlias, characters, descricao
@param nToReg, numeric, descricao

@type function
/*/
/**********************************************************************************/
Static Function Sigr02Qry(_cAlias,_nToReg)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	ZZ2.ZZ2_CODIGO, " + CRLF
_cQuery += "	ZZ2.ZZ2_PLPID, " + CRLF
_cQuery += "	ZZ4.ZZ4_CODETQ, " + CRLF
_cQuery += "	WSA.WSA_NOMDES, " + CRLF
_cQuery += "	WSA.WSA_CEPE, " + CRLF
_cQuery += "	WSA.WSA_COMPLE, " + CRLF
_cQuery += "	WSA.WSA_DOC, " + CRLF
_cQuery += "	WSA.WSA_SERIE, " + CRLF
_cQuery += "	WSA.WSA_VOLUME, " + CRLF
_cQuery += "	WSA.WSA_PBRUTO, " + CRLF
_cQuery += "	WSA.WSA_VLRTOT " + CRLF	 
_cQuery += " FROM " + CRLF
_cQuery += "	ZZ2010 ZZ2 " + CRLF 
_cQuery += "	INNER JOIN ZZ4010 ZZ4 ON ZZ4.ZZ4_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ4.ZZ4_CODIGO = ZZ2.ZZ2_CODIGO AND ZZ4.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN WSA010 WSA ON WSA.WSA_FILIAL = ZZ4.ZZ4_FILIAL AND WSA.WSA_NUMECO = ZZ4.ZZ4_NUMECO AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN ZZ0010 ZZ0 ON ZZ0.ZZ0_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ0.ZZ0_IDSER = ZZ4.ZZ4_CODSPO AND ZZ0.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZ2.ZZ2_FILIAL = '06' AND " + CRLF
_cQuery += "	ZZ2.ZZ2_CODIGO BETWEEN '' AND 'ZZZZZZ' AND " + CRLF
_cQuery += "	ZZ2.D_E_L_E_T_= '' " + CRLF
_cQuery += " ORDER BY ZZ2.ZZ2_CODIGO "
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg

dbSelectArea(_cAlias)
(_cAlias)->(dbGoTop() )

If (_cAlias)->( Eof() )
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
Static Function AjustaSx1(_cPerg)
	PutSx1(_cPerg, "01", "Pre Lista De ? "	, "Pre Lista De ? ", "Pre Lista De ? ", "mv_ch1", "C", TamSx3("ZZ2_CODIGO")[1],0,0,"G","","ZZ2","","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(_cPerg, "02", "Pre Lista Ate? "	, "Pre Lista Ate?" , "Pre Lista Ate?" , "mv_ch2", "C", TamSx3("ZZ2_CODIGO")[1],0,0,"G","","ZZ2","","","mv_par02","","","","","","","","","","","","","","","","",{},{},{})
Return Nil