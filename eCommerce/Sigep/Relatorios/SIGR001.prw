#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "REPORT.CH" 

#DEFINE CRLF CHR(13) + CHR(10)
#DEFINE CLR_BLACK RGB(0,0,0)
#DEFINE CLR_WITHE RGB(255,255,255)

#DEFINE TAM_A4 9

/********************************************************************************/
/*/{Protheus.doc} SIGR001

@description Realiza a impressao das etiquetas SIGEP

@author Bernard M. Margarido
@since 08/03/2017
@version undefined

@type function
/*/
/********************************************************************************/
User Function SIGR001()
Local _cPerg 		:= "SIGR02"

Private _lJob		:= IIF(Isincallstack("U_ECLOJM06"),.T.,.F.)

Private _oProcess   := Nil

//------------------------------+
// Cria Parametros do relatorio |
//------------------------------+
AjustaSx1(_cPerg)

If Pergunte(_cPerg,.T.)
	_oProcess:= MsNewProcess():New( {|| SigR01Prt()},"Dana Cosmeticos - eCommerce","Aguarde ... Imprimindo Etiquetas." )
    _oProcess:Activate()
EndIf
	
Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigR01Prt

@description Realiza a impressao de etiquetas

@author Bernard M. Margarido
@since 07/04/2017
@version undefined

@type function
/*/
/**********************************************************************************/
Static Function SigR01Prt()
Local _cAlias			:= GetNextAlias()
Local _cDirRaiz			:= GetTempPath()
Local _cFile			:= ""
Local _cDirExp			:= "\spool\"
Local _cCodPlp			:= ""
Local _cDoc				:= ""
Local _cSerie			:= ""
Local _cPedido			:= ""
Local _cCodEtq			:= ""
Local _cDest			:= ""
Local _cEndDest			:= ""
Local _cBairro			:= ""
Local _cMunicipio		:= ""
Local _cCep				:= ""
Local _cUF				:= ""
Local _cObs				:= ""
Local _cDTMatrix		:= ""
Local _cPlpID			:= ""
Local _cCodServ			:= ""
Local _cTelDest			:= ""

Local _nVolume			:= 0
Local _nPeso			:= 0 
Local _nToReg			:= 0
Local _nValor			:= 0
Local _nX				:= 0

Local _lAdjustToLegacy	:= .F.
Local _lDisableSetup	:= .T.

Local _oPrint			:= Nil

//-----------------------------+
// Consulta PLP a ser impressa |
//-----------------------------+
If !Sigr01Qry(_cAlias,@_nToReg)
	MsgStop("Não foram encontrados dados para serem processados. Favor Verificar os parametros.","Dana Cosmeticos - eCommerce")
	(_cAlias)->( dbCloseArea() )
	Return Nil
EndIf

//---------------------------------------+
// Coordendas para linha inicial e final |
//---------------------------------------+
 _oProcess:SetRegua1( _nToReg )
While (_cAlias)->( !Eof() )
	
	_cCodPlp 	:= (_cAlias)->ZZ2_CODIGO
	
	_cFile		:= "ETQ_" + _cCodPlp + "_"  + DToS(Date()) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".PD_"

	_oProcess:IncRegua1("Etiquetas PLP " + _cCodPlp +  " .")

	//------------------+
	// Instancia classe | 
	//------------------+
	_oPrint	:=	FWMSPrinter():New(_cFile, IMP_PDF, _lAdjustToLegacy, _cDirExp, _lDisableSetup, , , , .T., , .F., )

	//---------------------+
	// Configura Relatorio |
	//---------------------+
	_oPrint:cPathPdf 			:= _cDirRaiz
	_oPrint:setResolution(78)
	_oPrint:SetPortrait()
	_oPrint:setPaperSize(TAM_A4)
	_oPrint:SetMargin(10,10,10,10)
	
	_oProcess:SetRegua2( -1 )
	While (_cAlias)->( !Eof() .And. _cCodPlp == (_cAlias)->ZZ2_CODIGO )

		For _nX := 1 To Int((_cAlias)->C5_VOLUME1)

			//------------------+	
			// Imprime etiqueta |
			//------------------+
			_cPlpID		:= (_cAlias)->ZZ2_PLPID
			_cDoc		:= (_cAlias)->WSA_DOC
			_cSerie		:= (_cAlias)->WSA_SERIE
			_cPedido	:= (_cAlias)->C5_NUM
			_cCodEtq	:= (_cAlias)->ZZ4_CODETQ	
			_cDest		:= (_cAlias)->WSA_NOMDES
			_cEndDest	:= (_cAlias)->WSA_ENDENT
			_cBairro	:= (_cAlias)->WSA_BAIRRE
			_cMunicipio	:= (_cAlias)->WSA_MUNE
			_cCep		:= (_cAlias)->WSA_CEPE
			_cUF		:= (_cAlias)->WSA_ESTE
			_cObs		:= (_cAlias)->WSA_COMPLE
			_cCodServ	:= (_cAlias)->ZZ0_CODSER
			_cDescSer	:= (_cAlias)->ZZ0_DESCRI
			_cTelDest	:= (_cAlias)->WSA_TEL01
			_cDTMatrix	:= ""
			_nValor		:= (_cAlias)->WSA_VLRTOT
			_nVolume	:= _nX
			_nPeso		:= (_cAlias)->C5_PBRUTO * 100
			
			_oProcess:IncRegua2(" Imprimindo Etiqueta pedido " + _cPedido + " .")

			SigR01Etq(	_oPrint,_cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,;
						_cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,;
						_cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,;
						_nValor,_nVolume,_nPeso)
		Next _nX

		(_cAlias)->( dbSkip() )
	EndDo
			
EndDo

//-----------------+
// Exibe relatorio |
//-----------------+
_oPrint:Preview()

Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigR01Etq

@description Imprime etiqueta 

@author Bernard M. Margarido

@since 07/04/2017
@version undefined

@param _oPrint		, object	, objeto contendo dados para impressao do relatorio

@type function
/*/
/**********************************************************************************/
Static Function SigR01Etq(	_oPrint,_cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,;
							_cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,;
							_cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,;
							_nValor,_nVolume,_nPeso)

Local _cBtmDana		:= GetSrvProfString("Startpath","")+"sigep_dana.bmp"
Local _cDirSigep	:= GetSrvProfString("Startpath","")
Local _cBTMapSedex	:= "sigep_sedex.bmp"
Local _cBTMapPac	:= "sigep_pac.bmp"
Local _cCodCont		:= GetNewPar("EC_CODCONT")
Local _cCodCartao	:= GetNewPar("EC_IDCARTA")
Local _cNomeRem		:= ""
Local _cEndCob		:= ""
Local _cMunCob		:= ""
Local _cBairCob		:= ""
Local _cEstCob		:= ""
Local _cCepCob		:= ""
Local _cCompCob		:= ""
Local _cImgSigep	:= ""

Local _oFont09N		:= TFont():New("Arial",,09,,.T.,,,,,.F. )
Local _oFont09		:= TFont():New("Arial",,09,,.F.,,,,,.F. )
Local _oFont10N		:= TFont():New("Arial",,10,,.T.,,,,,.F. )
Local _oFont10		:= TFont():New("Arial",,10,,.F.,,,,,.F. )
Local _oFont11N		:= TFont():New("Arial",,11,,.T.,,,,,.F. )
Local _oFont11		:= TFont():New("Arial",,11,,.F.,,,,,.F. )

//--------------------+
// Dados do Remetente |
//--------------------+
_cNomeRem		:= "Dana Cosméticos" 	//Capital(RTrim(SM0->M0_NOMECOM))
_cEndCob		:= "Av. Piracema, 1.411"//Capital(RTrim(SM0->M0_ENDCOB))
_cMunCob		:= "Barueri "			//Capital(RTrim(SM0->M0_CIDCOB))
_cBairCob		:= "Tamboré"			//Capital(RTrim(SM0->M0_BAIRCOB))
_cCompCob		:= "Módulo 5"			//Capital(RTrim(SM0->M0_COMPCOB))
_cEstCob		:= "SP"					//SM0->M0_ESTCOB
_cCepCob		:= "06460030"			//SM0->M0_CEPCOB

//---------------------+
// Inicio da Impressao |
//---------------------+
_oPrint:StartPage()

//-----------------------+
// Imprime Box Principal |
//-----------------------+
_oPrint:Box(010, 005, 365, 293,"-9")

//-----------+
// Logo Dana |
//-----------+
_oPrint:SayBitmap(015, 015, _cBtmDana, 080,030 )

//---------------------------+
// Logo serviço PAC ou Sedex |
//---------------------------+
If At("SEDEX",_cDescSer) > 0
	_cImgSigep 	:= _cDirSigep + _cBTMapSedex
	_nPixelX	:= 070
	_nPixelY	:= 060
ElseIf At("PAC",_cDescSer) > 0
	_cImgSigep 	:= _cDirSigep + _cBTMapPac
	_nPixelX	:= 060
	_nPixelY	:= 060
EndIf

_oPrint:SayBitmap(015, 210, _cImgSigep , _nPixelX, _nPixelY )

//----------------------------+
// Codigo do Tipo Data Matrix |
//----------------------------+
_cCodDtMatrix := SigR01DtMat(_cCep,_cCepCob,_cCodEtq,_cEndDest,_cEndCob,_cCodCartao,_cCodServ,_cObs,_nValor)
//_oPrint:DataMatrix( 118, 085, _cCodDtMatrix, 075)

//---------------+
// Dados Etiqueta|
//---------------+
_oPrint:Say(092, 015, "NF: "						, _oFont09,  100 )
_oPrint:Say(092, 112, "Contrato: "					, _oFont09,  100 )
_oPrint:Say(092, 210, "Volume: "					, _oFont09,  100 )

_oPrint:Say(100, 015, "Pedido: "					, _oFont09,  100 )
_oPrint:Say(100, 210, "Peso(g): "					, _oFont09,  100 )

_oPrint:Say(108, 015, "PLP: "						, _oFont09,  100 )

_oPrint:Say(092, 028, RTrim(_cDoc) + "-" + _cSerie	, _oFont09,  100 )
_oPrint:Say(092, 144, _cCodCont						, _oFont09N, 100 )
_oPrint:Say(092, 240, cValToChar(_nVolume)			, _oFont09,  100 )

_oPrint:Say(100, 042, _cPedido						, _oFont09,  100 )
_oPrint:Say(100, 240, cValToChar(_nPeso)			, _oFont09N, 100 )

_oPrint:Say(108, 032, _cPlpID						, _oFont09,  100 )


_oPrint:Say(124, 090, _cCodEtq						, _oFont11N, 100 )
_oPrint:Code128(126, 015, _cCodEtq, 02, 36, .F., /*oFont*/ , 200)

_oPrint:Say(172, 015, "Recebedor:"					, _oFont09,  100 )
_oPrint:Say(182, 015, "Assinatura:"					, _oFont09,  100 )
_oPrint:Say(182, 146, "Documento:"					, _oFont09,  100 )

_oPrint:Say(172, 060, Replicate("_",53)				, _oFont09,  100 )
_oPrint:Say(182, 060, Replicate("_",20)				, _oFont09,  100 )
_oPrint:Say(182, 190, Replicate("_",22)				, _oFont09,  100 )

_oPrint:Line(190, 005, 190, 293, 0, "-9")

_oPrint:FillRect ( {190, 005, 200, 100}, TBrush():New2( , CLR_BLACK ) )
_oPrint:Say(198, 015, "DESTINATARIO"							, _oFont11N, 100, CLR_WITHE )

_oPrint:Say(212, 015, Capital(_cDest)							, _oFont11,  100 )
_oPrint:Say(223, 015, Capital(_cEndDest)						, _oFont11,  100 )
_oPrint:Say(234, 015, Capital(_cBairro)							, _oFont11,  100 )
_oPrint:Say(245, 015, Capital(_cCep)							, _oFont11N, 100 )
_oPrint:Say(245, 080, Capital(RTrim(_cMunicipio)) + "/" + _cUF	, _oFont11,  100 )

//_oPrint:Code128(250, 015, _cCep, 02, 36, .F., /*oFont*/ , 080)
_oPrint:Code128c(283, 015, _cCep, 035)

If !Empty(_cObs)
	_oPrint:Say(256, 098, "OBS: " + Capital(RTrim(_cObs))		, _oFont10,  100 )
EndIf	

_oPrint:Line(290, 005, 290, 293, 0, "-9")

_oPrint:Say(300, 015, "Remetente: "					, _oFont10N,  100 )
_oPrint:Say(300, 065, _cNomeRem						, _oFont10,   100 )
_oPrint:Say(311, 015, _cEndCob						, _oFont10,   100 )
_oPrint:Say(322, 015, _cBairCob						, _oFont10,   100 )
_oPrint:Say(333, 015, _cCompCob						, _oFont10,   100 )
_oPrint:Say(344, 015, _cCepCob						, _oFont10N,  100 )
_oPrint:Say(344, 065, _cMunCob + "/" + _cEstCob		, _oFont10,   100 )

//------------------------+
// Encerra a pagina atual |
//------------------------+
_oPrint:EndPage()

Return _oPrint

/**********************************************************************************/
/*/{Protheus.doc} SigR01DtMat
	@description Monta codigo Data Matrix
	@type  Static Function
	@author Bernard M. Margarido
	@since 20/01/2020
/*/
/**********************************************************************************/
Static Function SigR01DtMat(_cCep,_cCepCob,_cCodEtq,_cEndDest,_cEndCob,_cCodCartao,_cCodServ,_cObs,_nValor)
Local _cNumDest	:= ""
Local _cNumCob	:= ""
Local _cDigCep	:= ""
Local _cIDV		:= "51"
Local _cServAdd	:= "250000000000"
Local _cAgrup	:= "00"
Local _cTel		:= "000000000000"
Local _cLatid	:= "-00.000000"

//-------------------------+
// Numero endereço destino | 
//-------------------------+
_cNumDest	:= SigR01DtA(_cEndDest)
_cNumCob	:= SigR01DtA(_cEndCob)	
_cDigCep	:= SigR01DtB(_cCepCob)	

//--------------------------+
// Formata codigo DT Matrix |
//--------------------------+
_cCodDtMatrix	:= _cCep
_cCodDtMatrix	+= _cNumDest
_cCodDtMatrix	+= _cCepCob
_cCodDtMatrix	+= _cNumCob
_cCodDtMatrix	+= _cNumCob
_cCodDtMatrix	+= _cDigCep
_cCodDtMatrix	+= _cIDV
_cCodDtMatrix	+= RTrim(_cCodEtq)
_cCodDtMatrix	+= _cServAdd
_cCodDtMatrix	+= _cCodCartao
_cCodDtMatrix	+= _cCodServ
_cCodDtMatrix	+= _cAgrup
_cCodDtMatrix	+= _cNumDest
_cCodDtMatrix	+= SubStr(_cObs,1,20)
_cCodDtMatrix	+= cValToChar(_nValor * 100)
_cCodDtMatrix	+= _cTel
_cCodDtMatrix	+= _cLatid
_cCodDtMatrix	+= _cLatid
_cCodDtMatrix	+= "|"
_cCodDtMatrix	+= Space(30)


Return _cCodDtMatrix

/*****************************************************************************************/
/*/{Protheus.doc} nomeStaticFunction
	@description Valida numero do endereço de destino e remetente
	@type  Static Function
	@author Bernard M. Margarido
	@since 20/01/2020
/*/
/*****************************************************************************************/
Static Function SigR01DtA(_cEnd)
Local _cNum		:= ""
Local _cAlfaMa	:= "A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/X/W/Y/Z"
Local _cAlfaMi	:= "a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/w/x/y/z"

If At(",",_cEnd) > 0
	_cNum	:= Padl(Alltrim(SubStr(_cEnd, At(",",_cEnd) + 1)),5,"0")
	If _cNum $ _cAlfaMa .Or. _cNum $ _cAlfaMi
		_cNum	:= "00000"
	EndIf
Else
	_cNum	:= "00000"
EndIf

Return _cNum

/**********************************************************************************/
/*/{Protheus.doc} nomeStaticFunction
	@description Calcula digito verificador para CEP do remetente
	@type  Static Function
	@author Bernard M. Margarido
	@since 20/01/2020
/*/
/**********************************************************************************/
Static Function SigR01DtB(_cCepCob)	

Local _nX		:= 0
Local _nSCep	:= 0
Local _nResult	:= 0

For _nX := 1 To Len(_cCepCob)
	_nSCep += Val(SubStr(_cCepCob,_nX,1))
Next _nX

If Mod(_nSCep,10) <> 0
	_nResult := 20 - _nSCep
Else
	_nResult := 10 - _nSCep
EndIF

Return cValToChar(_nResult)

/**********************************************************************************/
/*/{Protheus.doc} Sigr01Qry

@description Consulta etiquetas ser impressa

@author Bernard M. Margarido

@since 07/04/2017
@version undefined

@param _cAlias, characters, descricao
@param nToReg, numeric, descricao

@type function
/*/
/**********************************************************************************/
Static Function Sigr01Qry(_cAlias,_nToReg)
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
_cQuery += "	SC5.C5_NUM, " + CRLF
_cQuery += "	SC5.C5_VOLUME1, " + CRLF
_cQuery += "	SC5.C5_PBRUTO, " + CRLF
_cQuery += "	WSA.WSA_VLRTOT, " + CRLF
_cQuery += "	WSA.WSA_TEL01, " + CRLF
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
	(_cAlias)->( dbCloseArea() )
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

