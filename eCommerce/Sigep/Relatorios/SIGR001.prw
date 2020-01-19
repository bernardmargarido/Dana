#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)
#DEFINE CLR_GRAY RGB(238,238,238)

#DEFINE TAM_A4 9

/********************************************************************************/
/*/{Protheus.doc} SIGR001

@description Realiza a impressao das etiquetas Vizcaya

@author Bernard M. Margarido
@since 08/03/2017
@version undefined

@type function
/*/
/********************************************************************************/
User Function SIGR001()
Local _cPerg := "SIGR02"

//------------------------------+
// Cria Parametros do relatorio |
//------------------------------+
AjustaSx1(_cPerg)

If Pergunte(_cPerg,.T.)
	Processa({|| SigR01Prt() },"Aguarde ... Imprimindo Etiquetas.","Dana Cosmeticos - eCommerce")
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

Local _nVolume			:= 0
Local _nPeso			:= 0 
Local _nToReg			:= 0

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
While (_cAlias)->( !Eof() )
	
	_cCodPlp 	:= (_cAlias)->ZZ2_CODIGO
	
	_cFile		:= "ETQ_" + RTrim((_cAlias)->WSA_DOC) + "_" + RTrim((_cAlias)->WSA_SERIE) + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".PD_"

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
	
	While (_cAlias)->( !Eof() .And. _cCodPlp == (_cAlias)->ZZ2_CODIGO )

		//------------------+	
		// Imprime etiqueta |
		//------------------+
		_cDoc		:= ""
		_cSerie		:= ""
		_cPedido	:= ""
		_cCodEtq	:= (_cAlias)->ZZ4_CODETQ	
		_cDest		:= ""
		_cEndDest	:= ""
		_cBairro	:= ""
		_cMunicipio	:= ""
		_cCep		:= ""
		_cUF		:= ""
		_cObs		:= ""
		_cDTMatrix	:= ""
		_nVolume	:= 0
		_nPeso		:= 0 
		
		SigR01Etq(	_oPrint,_cDoc,_cSerie,_cPedido,_cCodEtq,;
					_cDest,_cEndDest,_cBairro,_cMunicipio,;
					_cCep,_cUF,_cObs,_cDTMatrix,_nVolume,_nPeso)

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
Static Function SigR01Etq(	_oPrint,_cDoc,_cSerie,_cPedido,_cCodEtq,;
							_cDest,_cEndDest,_cBairro,_cMunicipio,;
							_cCep,_cUF,_cObs,_cDTMatrix,_nVolume,_nPeso)

Local _cBtmDana		:= GetSrvProfString("Startpath","")+"\sigep_dana.bmp"
Local _cBtmSigep	:= GetSrvProfString("Startpath","")+"\sigep_sedex.bmp"

Local _nHorzSize	:= _oPrint:nHorzSize()
Local _nVertSize 	:= _oPrint:nVertSize()
Local _nLogPixelX	:= _oPrint:nLogPixelX()
Local _nLogPixelY	:= _oPrint:nLogPixelY()
Local _nPaperSize	:= _oPrint:PaperSize()

Local _oFont08		:= TFont():New("Arial",,08,,.F.,,,,,.F. )
Local _oFont08N		:= TFont():New("Arial",,08,,.T.,,,,,.F. )
Local _oFont09N		:= TFont():New("Arial",,09,,.T.,,,,,.F. )
Local _oFont09		:= TFont():New("Arial",,09,,.F.,,,,,.F. )
Local _oFont10N		:= TFont():New("Arial",,10,,.T.,,,,,.F. )
Local _oFont10		:= TFont():New("Arial",,10,,.F.,,,,,.F. )
Local _oFont11N		:= TFont():New("Arial",,11,,.T.,,,,,.F. )
Local _oFont11		:= TFont():New("Arial",,11,,.F.,,,,,.F. )

//---------------------+
// Inicio da Impressao |
//---------------------+
_oPrint:StartPage()

//-------------------+
// Imprime Cabeçalho |
//-------------------+
_oPrint:Box(010, 005, 435, 293,"-9")

//-----------+
// Logo Dana |
//-----------+
_oPrint:SayBitmap(015, 015, _cBtmDana, 080,030 )

//---------------------------+
// Logo serviço PAC ou Sedex |
//---------------------------+
_oPrint:SayBitmap(015, 210, _cBtmSigep, 070,060 )

//----------------------------+
// Codigo do Tipo Data Matrix |
//----------------------------+
_cCodDtMatrix	:= "01234567890123456789|01234567890123456789|01234567890123456789|01234567890123456789"
_oPrint:DataMatrix( 118, 085, _cCodDtMatrix, 075)

//---------------+
// Dados Etiqueta|
//---------------+
_oPrint:Say(092, 015, "NF: "						, _oFont09, 100 )
_oPrint:Say(092, 116, "Contrato: "					, _oFont09, 100 )
_oPrint:Say(092, 210, "Volume: "					, _oFont09, 100 )

_oPrint:Say(100, 015, "Pedido: "					, _oFont09, 100 )
_oPrint:Say(100, 210, "Peso(g): "					, _oFont09, 100 )

_oPrint:Say(108, 015, "PLP: "						, _oFont09, 100 )

_oPrint:Say(124, 090, _cCodEtq						, _oFont11N, 100 )

//_oPrint:Code128C(160, 015, _cCodEtq, 50 )
_oPrint:Code128(126, 015, _cCodEtq, 02, 36, .F., /*oFont*/ , 200)
//_oPrint:Line(112, 025, 112, 600, 0, "-9")

//------------------------+
// Encerra a pagina atual |
//------------------------+
_oPrint:EndPage()

Return _oPrint

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
_cQuery += "	WSA.WSA_CEPE, " + CRLF
_cQuery += "	WSA.WSA_COMPLE, " + CRLF
_cQuery += "	WSA.WSA_DOC, " + CRLF
_cQuery += "	WSA.WSA_SERIE, " + CRLF
_cQuery += "	WSA.WSA_VOLUME, " + CRLF
_cQuery += "	WSA.WSA_PBRUTO, " + CRLF
_cQuery += "	WSA.WSA_VLRTOT, " + CRLF	 
_cQuery += "	ZZ0.ZZ0_CODSER, " + CRLF	 
_cQuery += "	ZZ0.ZZ0_DESCRI " + CRLF	 
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

