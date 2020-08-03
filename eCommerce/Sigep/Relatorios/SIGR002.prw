#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)
#DEFINE CLR_GRAY RGB(238,238,238)

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
Local _cPerg 	:= "SIGR02"

Private _lJob	:= .F.
//------------------------------+
// Cria Parametros do relatorio |
//------------------------------+
AjustaSx1(_cPerg)

If Pergunte(_cPerg,.T.)
	Processa({|| SigR02Prt() },"Aguarde ... Processando relatorio","Dana Cosmeticos - eCommerce")
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
Local _cIDPlp			:= ""

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
Private _oFont10N		:= TFont():New("Arial",,10,,.T.,,,,,.F. )
Private _oFont10		:= TFont():New("Arial",,10,,.F.,,,,,.F. )
Private _oFont12		:= TFont():New("Arial",,12,,.F.,,,,,.F. )
Private _oFont12N		:= TFont():New("Arial",,12,,.T.,,,,,.F. )
Private _oFont18N		:= TFont():New("Arial",,18,,.T.,,,,,.F. )

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
//_oPrint:SetMargin(10,10,10,10)

//---------------------------------------+
// Coordendas para linha inicial e final |
//---------------------------------------+
ProcRegua(_nToReg)
While (_cAlias)->( !Eof() )
	
	_cCodPlp := (_cAlias)->ZZ2_CODIGO
	_cIDPlp	 := (_cAlias)->ZZ2_PLPID
	_nTotPlp := 0

	//---------------------+
	// Inicio da Impressao |
	//---------------------+
	SigR02Cabec(_oPrint,_cIDPlp)
	_nLinI := 115
	_nLinF := 142
	While (_cAlias)->( !Eof() .And. _cCodPlp == (_cAlias)->ZZ2_CODIGO )

		IncProc("PLP " + (_cAlias)->ZZ2_CODIGO)

		If _nLinI >= 850
			//------------------------+
			// Encerra a pagina atual |
			//------------------------+
			_oPrint:EndPage()
			
			//-------------------+
			// Imprime cabeçalho |
			//-------------------+
			SigR02Cabec(_oPrint,_cIDPlp)

			//---------------------------------------+
			// Coordendas para linha inicial e final |
			//---------------------------------------+
			_nLinI := 115
			_nLinF := 142

		EndIf 
		
		//_oPrint:Box(_nLinI, 025, _nLinF, 600)
		_oPrint:FillRect ( {_nLinI, 025, _nLinF - 2, 600}, TBrush():New2( , CLR_GRAY ) )

		_oPrint:Say(_nLinI + 7, 030, RTrim((_cAlias)->ZZ4_CODETQ)											, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 100, (_cAlias)->WSA_CEPE													, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 160, cValToChar((_cAlias)->C5_PBRUTO)										, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 192, "N"																	, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 212, "N"																	, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 232, "N"																	, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 252, "N"																	, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 272, "N"																	, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 290, cValToChar((_cAlias)->WSA_VLRTOT)										, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 370, RTrim((_cAlias)->WSA_DOC) + RTrim((_cAlias)->WSA_SERIE)				, _oFont08, 100 )
		_oPrint:Say(_nLinI + 7, 430, RTrim((_cAlias)->ZZ0_CODSER) + " - " + RTrim((_cAlias)->ZZ0_DESCRI)	, _oFont08, 100 )

		If !Empty((_cAlias)->WSA_NOMDES)
			_nLinD	:= _nLinI + 16 
			_oPrint:Say(_nLinD, 030, "Destinatário: "														, _oFont10N, 100 )
			_oPrint:Say(_nLinD, 083, RTrim(Capital((_cAlias)->WSA_NOMDES))									, _oFont08 , 100 )
		EndIf

		If !Empty((_cAlias)->WSA_COMPLE)
			_nLinD	:= _nLinI + 25 
			_oPrint:Say(_nLinD, 030, "Obs.:"																, _oFont10N, 100 )
			_oPrint:Say(_nLinD, 083, RTrim(Capital((_cAlias)->WSA_COMPLE))									, _oFont08 , 100 )		
		EndIf

		_nLinI 	:= _nLinF
		_nLinF 	:= _nLinF + 31
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

Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigR02Cabec
	@description Imprime cabeçalho do relatorio
	@author Bernard M. Margarido
	@since 07/04/2017
	@version undefined
	@type function
/*/
/**********************************************************************************/
Static Function SigR02Cabec(_oPrint,_cIDPlp)
Local _cTitCabec	:= "EMPRESA BRASILEIRA DE CORREIOS E TELÉGRAFOS"
Local _cSubTit		:= "LISTA DE POSTAGEM"
Local _cCodCont		:= GetNewPar("EC_CODCONT")
Local _cCodAdm		:= GetNewPar("EC_CODADM")
Local _cIdCartao	:= GetNewPar("EC_IDCARTA")
Local _cBitMap		:= GetSrvProfString("Startpath","")+"\correios.bmp"
Local _cEnd_01 		:= ""
Local _cEnd_02 		:= ""
Local _cNomeRem		:= ""
Local _cEndCob		:= ""
Local _cMunCob		:= ""
Local _cBairCob		:= ""
Local _cCompCob		:= ""
Local _cEstCob		:= ""
Local _cCepCob		:= ""

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
_oPrint:Box(030, 025, 100, 600,"-9")
_oPrint:Line(112, 025, 112, 600, 0, "-9")

//--------------------+
// Dados do Remetente |
//--------------------+
_cNomeRem		:= Capital(RTrim(SM0->M0_NOMECOM))
_cEndCob		:= Capital(RTrim(SM0->M0_ENDCOB))
_cMunCob		:= Capital(RTrim(SM0->M0_CIDCOB))
_cBairCob		:= Capital(RTrim(SM0->M0_BAIRCOB))
_cCompCob		:= Capital(RTrim(SM0->M0_COMPCOB))
_cEstCob		:= SM0->M0_ESTCOB
_cCepCob		:= SM0->M0_CEPCOB

//-----------------+
// Dados Cabecalho |
//-----------------+
_oPrint:Say(024, 165, _cTitCabec						, _oFont18N, 100 )
_oPrint:Say(042, 260, _cSubTit 							, _oFont12N, 100 ) 
_oPrint:Say(053, 030, "N° da Lista:"					, _oFont12N, 100 ) 
_oPrint:Say(053, 090, _cIDPlp	 						, _oFont12 , 100 )
_oPrint:Say(053, 190, "Remetente:" 						, _oFont12N, 100 )
_oPrint:Say(053, 260, RTrim(Capital(_cNomeRem))			, _oFont12 , 100 )

_oPrint:Say(068, 030, "Contrato:"	 					, _oFont12N, 100 ) 
_oPrint:Say(068, 090, _cCodCont		 					, _oFont12 , 100 )
_oPrint:Say(068, 190, "Cliente:"	 					, _oFont12N, 100 )
_oPrint:Say(068, 260, RTrim(Capital(_cNomeRem))			, _oFont12 , 100 )
_oPrint:Say(083, 030, "Cod. Adm:"	 					, _oFont12N, 100 ) 
_oPrint:Say(083, 090, _cCodAdm	 						, _oFont12 , 100 )
_oPrint:Say(083, 190, "Endereço:"	 					, _oFont12N, 100 )

_cEnd_01 := RTrim(Capital(_cEndCob))
_cEnd_02 := RTrim(Capital(_cBairCob)) + " - " + RTrim(Capital(_cMunCob)) + "/" + _cEstCob + " - CEP:" + RTrim(_cCepCob)    	

_oPrint:Say(083, 260, _cEnd_01		 					, _oFont12 , 100 )
_oPrint:Say(098, 260, _cEnd_02		 					, _oFont12 , 100 ) 
_oPrint:Say(098, 030, "Cartão:"	 						, _oFont12N, 100 )
_oPrint:Say(098, 090, _cIdCartao	 					, _oFont12 , 100 )
_oPrint:Say(053, 480, "Telefone:"	 					, _oFont12N, 100 ) 
_oPrint:Say(053, 530, Alltrim(SM0->M0_TEL)				, _oFont12 , 100 )

//------------------+
// Titulo dos Itens |
//------------------+
_oPrint:Say(110, 030, "N° do Objeto"					, _oFont10N, 100 ) 
_oPrint:Say(110, 100, "CEP"								, _oFont10N, 100 )
_oPrint:Say(110, 160, "Peso"							, _oFont10N, 100 )
_oPrint:Say(110, 190, "AR"								, _oFont10N, 100 )
_oPrint:Say(110, 210, "MP"								, _oFont10N, 100 )
_oPrint:Say(110, 230, "VD"								, _oFont10N, 100 )
_oPrint:Say(110, 250, "EV"								, _oFont10N, 100 )
_oPrint:Say(110, 270, "EL"								, _oFont10N, 100 )
_oPrint:Say(110, 290, "V. Declarado"					, _oFont10N, 100 )
_oPrint:Say(110, 370, "N. Fiscal"						, _oFont10N, 100 )
_oPrint:Say(110, 430, "Serviço"							, _oFont10N, 100 )

Return _oPrint

/**********************************************************************************/
/*/{Protheus.doc} SigR02Rod
	@description Imprime Rodape PLP
	@author Bernard M. Margarido
	@since 07/04/2017
	@version undefined
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
_oPrint:Box(_nLinR, 025, 820, 600,"-9")

_nLinR := _nLinR + 10
_oPrint:Say(_nLinR , 030, "Quantidade de Objetos: " + cValToChar(_nTotPlp)			, _oFont10N, 100 )
_oPrint:Say(_nLinR , 400, "Carimbo e Assinatura / Matrícula dos Correios"			, _oFont10N, 100 )

_nLinR := _nLinR + 20
_oPrint:Say(_nLinR , 030, "APRESENTAR ESTA LISTA EM CASO DE PEDIDO DE INFORMAÇÕES"	, _oFont10N, 100 )

_nLinR := _nLinR + 10
_oPrint:Say(_nLinR , 030, "Estou ciente do disposto na cláusula terceira do contrato de prestação de Serviços."	, _oFont10N, 100 )

_nLinR := _nLinR + 25
_oPrint:Say(_nLinR , 040, Replicate("_",45)											, _oFont10N, 100 )

_nLinR := _nLinR + 10
_oPrint:Say(_nLinR , 085, "ASSINATURA DO REMETENTE"									, _oFont10N, 100 )

_nLinR := _nLinR + 10
_oPrint:Say(_nLinR 	, 048, "Obs: 1ª via Unidade de Postagem e 2ª via Cliente"		, _oFont10N, 100 )
_oPrint:Say(830 	, 028, "Data de Emissao: " + dToc(Date())						, _oFont10N , 100 )

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
_cQuery += "	WSA.WSA_ENDENT, " + CRLF
_cQuery += "	WSA.WSA_BAIRRE, " + CRLF
_cQuery += "	WSA.WSA_MUNE, " + CRLF
_cQuery += "	WSA.WSA_CEPE, " + CRLF
_cQuery += "	WSA.WSA_ESTE, " + CRLF
_cQuery += "	WSA.WSA_COMPLE, " + CRLF
_cQuery += "	WSA.WSA_DOC, " + CRLF
_cQuery += "	WSA.WSA_SERIE, " + CRLF
_cQuery += "	SC5.C5_VOLUME1, " + CRLF
_cQuery += "	SC5.C5_PBRUTO, " + CRLF
_cQuery += "	WSA.WSA_VLRTOT, " + CRLF	 
_cQuery += "	ZZ0.ZZ0_CODSER, " + CRLF	 
_cQuery += "	ZZ0.ZZ0_DESCRI " + CRLF	 
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("ZZ2") + " ZZ2 " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("ZZ4") + " ZZ4 ON ZZ4.ZZ4_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ4.ZZ4_CODIGO = ZZ2.ZZ2_CODIGO AND ZZ4.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("WSA") + " WSA ON WSA.WSA_FILIAL = ZZ4.ZZ4_FILIAL AND WSA.WSA_NUMECO = ZZ4.ZZ4_NUMECO AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("ZZ0") + " ZZ0 ON ZZ0.ZZ0_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ0.ZZ0_IDSER = ZZ4.ZZ4_CODSPO AND ZZ0.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = WSA.WSA_FILIAL AND SC5.C5_NUM = WSA.WSA_NUMSC5 AND SC5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZ2.ZZ2_FILIAL = '" + xFilial("ZZ2") + "' AND " + CRLF
_cQuery += "	ZZ2.ZZ2_CODIGO BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' AND " + CRLF
_cQuery += "	ZZ2.ZZ2_STATUS = '04' AND " + CRLF
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
	@type function
/*/
/***************************************************************************************/
Static Function AjustaSx1(_cPerg)
Local aArea 	:= GetArea()
Local aPerg 	:= {}

Local _nX		:= 0
Local nTPerg    := Len( SX1->X1_GRUPO )
Local nTSeq     := Len( SX1->X1_ORDEM )

SX1->( dbSetOrder(1) )

aAdd(aPerg, {_cPerg, "01", "Pre Lista De ?"     , "MV_CH1" , "C", TamSX3("ZZ2_CODIGO")[1]	, 0, "G", "MV_PAR01", "ZZ2" ,"",""	,"",""})
aAdd(aPerg, {_cPerg, "02", "Pre Lista Ate?"     , "MV_CH2" , "C", TamSX3("ZZ2_CODIGO")[1]	, 0, "G", "MV_PAR02", "ZZ2" ,"",""	,"",""})

For _nX := 1 To Len(aPerg)
	
	If  !SX1->( dbSeek(  PadR(aPerg[_nX][1], nTPerg) + PadR(aPerg[_nX][2],nTSeq) ) )		
		RecLock("SX1",.T.)
			Replace X1_GRUPO   with aPerg[_nX][01]
			Replace X1_ORDEM   with aPerg[_nX][02]
			Replace X1_PERGUNT with aPerg[_nX][03]
			Replace X1_VARIAVL with aPerg[_nX][04]
			Replace X1_TIPO	   with aPerg[_nX][05]
			Replace X1_TAMANHO with aPerg[_nX][06]
			Replace X1_PRESEL  with aPerg[_nX][07]
			Replace X1_GSC	   with aPerg[_nX][08]
			Replace X1_VAR01   with aPerg[_nX][09]
			Replace X1_F3	   with aPerg[_nX][10]
			Replace X1_DEF01   with aPerg[_nX][11]
			Replace X1_DEF02   with aPerg[_nX][12]
			Replace X1_DEF03   with aPerg[_nX][13]
			Replace X1_DEF04   with aPerg[_nX][14]
	
		SX1->( MsUnlock() )
	EndIf
Next _nX

RestArea( aArea )
	
Return Nil