#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE COD_PROD   1
#DEFINE DESC_PROD  2
#DEFINE NOME_PROD  3
#DEFINE LONG_PROD  4
#DEFINE MODOUSAR   5
#DEFINE PRECAUCOES 6
#DEFINE COMPOSICAO 7
#DEFINE PROD_CAT1  8
#DEFINE PROD_CAT2  9
#DEFINE PROD_GENE  10
#DEFINE PROD_CODM  11
#DEFINE PROD_LARG  12
#DEFINE PROD_PROF  13
#DEFINE PROD_ALTU  14
#DEFINE PROD_PESO  15

Static _nTCodPrd 	:= TamSx3("B1_COD")[1]
Static _nTDescFil	:= TamSx3("AY4_VALOR")[1]

/************************************************************/
/*/{Protheus.doc} ECLJM002
    @description Importa planlilha CSV 
    @type  Function
    @author Bernard M. Margarido
    @since 09/08/2019
    @version 1.0
/*/
/************************************************************/
User Function ECLJM002()
Local _cTpArq       := "(*.csv)|*.csv|"
Local _cTitulo      := "Importa Complemento de Produtos VTEX"
Local _cArquivo     := ""
Local _cDir         := ""

Local _nOpcFile     := 0

Private _cDirLog    := "\imp\"
Private _cDirArqImp := "\imp\processados\"
Private _cPathImp   := ""

//-------------------------------------+
// Cria janela para seleção do arquivo |
//-------------------------------------+
_nOpcFile   := GETF_LOCALHARD + GETF_NETWORKDRIVE
_cDir		:= cGetFile(_cTpArq,_cTitulo,0) //cGetFile(cTipoArq,cTitulo,0,,.T.,nOpcFile)
_cArquivo   := SubStr(_cDir,Rat("\",_cDir) + 1,Len(_cDir))
_cPathImp	:= SubStr(_cDir,1,Rat("\",_cDir))

If !Empty(_cArquivo)
    //---------------------------------+
    // Inicia a importacao do arquivo. |
    //---------------------------------+
    If MsgNoYes("Confirma Importacao do Arquivo "  + _cArquivo + "?")
        Processa({|_lEnd| ProcArq(_cPathImp,_cArquivo,@_lEnd) },"Lendo Arquivo Texto...",,.T.)
    EndIf
EndIf

Return Nil

/**********************************************************/
/*/{Protheus.doc} ProcArq
    @description Processa arquivo CSV
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/**********************************************************/
Static Function ProcArq(_cPathImp,_cArquivo,_lEnd)
Local _nHdl 	        := 0
Local _cMsg             := ""
Local _cLog      	    := ""
Local _cArqLog  	    := ""
Local _cSource          := ""
Local _cTarget          := ""
Local _cFilAux			:= cFilAnt

Private _dDtaIni	    := dDataBase
Private _cHoraIni	    := Time()

Private _nErros		    := 0

Private _cPathErr	    := _cDirArqImp + "erros"

//-----------+
// Filial 06 | 
//-----------+
cFilAnt := "06"

_nHdl 	:= FT_FUse(_cPathImp + _cArquivo)

//---------------------------------------+
// Efetua a leitura do arquivo de texto. |
//---------------------------------------+
LeArqTexto(_nHdl, _cArquivo,@_lEnd)

//----------------------+
// Fecha arquivo texto. |
//----------------------+
FT_FUSE()

//----------------------------------------------+
// Cria diretorio para arquivos ja processados. |
//----------------------------------------------+
If !EXISTDIR(_cDirLog)
    MakeDir(_cDirLog)
EndIf

If !EXISTDIR(_cDirArqImp)
    MakeDir(_cDirArqImp)
EndIf

//------------------------------------------------+
// Remove arquivo de texto para pasta processados.|
//------------------------------------------------+
_cSource := AllTrim(_cPathImp + _cArquivo)
_cTarget := AllTrim(_cDirArqImp + SubStr(_cArquivo,1,Len(_cArquivo)-4) + "_" + DToS( Date() ) + "_" + StrTran( Time(), ":") + ".CSV")
Copy File &_cSource to &_cTarget
//Delete File &(_cSource)

//------------------------------------+
// Grava Log de Importacao dos Dados. |
//------------------------------------+
_cLog := "Arquivo........: " + _cArquivo + CRLF
_cLog += "Path...........: " + _cDirArqImp + CRLF
_cLog += "Data Inicial...: " + DToC(_dDtaIni) + CRLF
_cLog += "Hora Inicial...: " + _cHoraIni + CRLF
_cLog += "Data Final.....: " + DToC( Date() ) + CRLF
_cLog += "Hora Final.....: " + Time() + CRLF
_cLog += "Inconformidades: " + Alltrim(Str(_nErros))

_cArqLog := "LOGIMP_" + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2)+".LOG"
MemoWrite(_cDirArqImp +_cArqLog, _cLog)
fRenameEX(_cPathImp + _cArquivo, StrTran( Upper(_cPathImp + _cArquivo) ,".CSV","_OK.CSV") )

cFilAnt := _cFilAux

Return Nil

/**********************************************************/
/*/{Protheus.doc} LeArqTexto
    @description Processa arquivo CSV
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/**********************************************************/
Static Function LeArqTexto(_nHdl, _cArquivo,_lEnd)
	Local _cLinha   	:= ""
		
	Local _nBytes  	    := 0
	Local _nPos    	    := 1
	Local _nLinhas 	    := 0
	Local _nPorcAtu	    := 0
	Local _nPorcNext	:= 0
	
	Local _lQuebra		:= .F.
	Local _nCount		:= 0

	Default _lEnd   	:= .F.

    //--------------------------------+
	// Determina o tamanho do arquivo |
    //--------------------------------+
	_nBytes := FT_FLastRec()

    //--------------------------------+
	// Posiciona no início do arquivo |
    //--------------------------------+
	FT_FGoTop()

	ProcRegua(_nBytes)
	
    //-------------------+
	// Arquivo não vazio |
    //-------------------+
	If _nBytes > 0
		While !FT_FEOF()

			EcLjM02Lin(FT_FReadLn(),@_cLinha,@_nCount,@_lQuebra)

			If _lQuebra
				_nLinhas++
				If !GravaLinha(_cLinha, _nLinhas)
					Return .F.
				EndIf
				_cLinha	:= ""	
				_nCount := 0
				_lQuebra:= .T.
			EndIf

			If _lEnd	
				Alert("Operação cancelada pelo usuário!")
				Exit
			EndIf
		
			_nPorcNext := NoRound((_nPos/_nBytes)*100,2)
			If _nPorcNext > _nPorcAtu
				_nPorcAtu := _nPorcNext
				IncProc("Lendo Arquivo: " + _cArquivo + " - " + Str(_nPorcAtu, 6, 2) + "%")
				Conout("Lendo Arquivo: " + _cArquivo + " - " + Str(_nPorcAtu, 6, 2) + "%")
			EndIf
			FT_FSKIP()
			_nPos++
		EndDo
	EndIf
Return

/**********************************************************/
/*/{Protheus.doc} EcLjM02Lin
    @description Valida se houve quebra de linha
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/**********************************************************/
Static Function EcLjM02Lin(_cLinArq,_cLinha,_nCount,_lQuebra)
Local _nX 		:= 0 

For _nX := 1 To Len(_cLinArq)
	If SubStr(_cLinArq,_nX,1) == ";"
		_nCount++
	EndIf	
Next _nX

If _nCount < 14
	_lQuebra 	:= .F.
	_cLinha		+= _cLinArq 
Else
	_lQuebra 	:= .T.
	_cLinha		+= _cLinArq 
EndIf

Return Nil

/**********************************************************/
/*/{Protheus.doc} GravaLinha
    @description Grava linga do arquivo
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/**********************************************************/
Static Function GravaLinha(_cDados, _nLin)

Local  _aDados		:= {}	// Array contendo todos os dados a serem importados	

If Empty(_cDados)
	If _nLin == 1
		_nErros++
		MsgAlert("O cabecalho do arquivo está vazio.")
		Return .F.
	Else
		Return .T.
	EndIf
EndIf
	
If _nLin == 1 
	Return .T.
EndIf

//------------------------------------------------------+
// Monta as dados conforme a leitura das demais linhas. |
//------------------------------------------------------+
aAdd( _aDados , Separa(_cDados,';',.T.) )

//-----------------------------------------------+
// Processa os dados que estao sendo importados. |
//-----------------------------------------------+
ProcGen(_aDados[1])			
		
Return .T.

/**********************************************************/
/*/{Protheus.doc} ProcGen
    @description Processa arquivo CSV
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/**********************************************************/
Static Function ProcGen(_aDados)
Local _aArea		:= GetArea()

Local _cCodProd   	:= ""
Local _cDescProd  	:= ""
LOcal _cNomeProd  	:= ""
Local _cLongDesc  	:= ""
Local _cBenefi    	:= ""
Local _cModoUsar  	:= ""
Local _cPrecau    	:= ""
Local _cComposicao	:= ""
Local _cCat01     	:= ""
Local _cCat02     	:= ""
Local _cCodCat1		:= ""
Local _cCodCat2		:= ""
Local _cGenero    	:= ""
Local _cDescMarca 	:= ""
Local _cCodMarca	:= ""
Local _cDescSB1		:= ""

Local _nLarguga   	:= 0
Local _nProfund   	:= 0
Local _nAltura    	:= 0
Local _nPeso      	:= 0
Local _nOpcX		:= 3

Local _aCabec		:= {}

Local _lGrava		:= .F.

Private lMsErroAuto	:= .F.

//---------------+
// Prepara Dados |
//---------------+
_cCodProd   := PadR(RTrim(_aDados[COD_PROD]),_nTCodPrd)
_cDescProd  := RTrim(_aDados[DESC_PROD])
_cNomeProd  := RTrim(_aDados[NOME_PROD])
_cLongDesc  := RTrim(_aDados[LONG_PROD])
//_cBenefi    := RTrim(_aDados[BENEFECIO])
_cModoUsar  := RTrim(_aDados[MODOUSAR])
_cPrecau    := RTrim(_aDados[PRECAUCOES])
_cComposicao:= RTrim(_aDados[COMPOSICAO])
_cCat01     := RTrim(_aDados[PROD_CAT1])
_cCat02     := RTrim(_aDados[PROD_CAT2])
_cGenero    := RTrim(_aDados[PROD_GENE])
_cDescMarca := RTrim(_aDados[PROD_CODM])
_nLarguga   := Val(StrTran(_aDados[PROD_LARG],",","."))
_nProfund   := Val(StrTran(_aDados[PROD_PROF],",","."))
_nAltura    := Val(StrTran(_aDados[PROD_ALTU],",","."))
_nPeso      := Val(StrTran(_aDados[PROD_PESO],",","."))

//----------------+
// Valida produto | 
//----------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )
If !SB1->( dbSeek(xFilial("SB1") + _cCodProd) )  
	CoNout("Produto " + _cCodProd + " não localizado.")
	_nErros++
	Return .F.
EndIf


//----------------------------------+
// Posiciona complemento de produto | 
//----------------------------------+
dbSelectArea("SB5")
SB5->( dbSetOrder(1) )
If SB5->( dbSeek(xFilial("SB5") + _cCodProd) )
	CoNout("Produto " + Rtrim(_cCodProd) + " já cadastrado.")
	_nOpcX := 4
	//_nErros++
	//Return .T.
EndIf

//--------------------------+
// Localiza codigo da marca |
//--------------------------+
If !EcLojM02Mar(_cDescMarca,@_cCodMarca)
	_nErros++
	Return .F.
Endif

//--------------------------------+
// Localiza codigo das categorias |
//--------------------------------+
If !EcLojM02Cat(_cCat01,_cCat02,@_cCodCat1,@_cCodCat2)
	_nErros++
	Return .F.
Endif


//------------------------------+
// Grava complemento de produto | 
//------------------------------+
_cDescSB1	:= Posicione("SB1",1,xFilial("SB1") + _cCodProd,"B1_DESC")
aAdd(_aCabec,{ "B5_FILIAL"	,		xFilial("SB5")		, Nil	})
aAdd(_aCabec,{ "B5_COD"		,		_cCodProd			, Nil	})
aAdd(_aCabec,{ "B5_CEME"	,		_cDescSB1			, Nil	})
aAdd(_aCabec,{ "B5_XCAT01"	,		_cCodCat1			, Nil	}) 	
aAdd(_aCabec,{ "B5_XCAT02"	,		_cCodCat2			, Nil	}) 
aAdd(_aCabec,{ "B5_XCODMAR"	,		_cCodMarca			, Nil	})
aAdd(_aCabec,{ "B5_XNOMPRD"	,		_cNomeProd			, Nil	})
aAdd(_aCabec,{ "B5_XTITULO"	,		_cNomeProd			, Nil	})
aAdd(_aCabec,{ "B5_XSUBTIT"	,		_cNomeProd			, Nil	})
aAdd(_aCabec,{ "B5_XALTPRD"	,		_nAltura			, Nil	})
aAdd(_aCabec,{ "B5_ALTURA"	,		_nAltura			, Nil	}) 
aAdd(_aCabec,{ "B5_XLARPRD"	,		_nLarguga			, Nil	})
aAdd(_aCabec,{ "B5_LARG"	,		_nLarguga			, Nil	})
aAdd(_aCabec,{ "B5_XPROPRD"	,		_nProfund			, Nil	})
aAdd(_aCabec,{ "B5_COMPR"	,		_nProfund			, Nil	})  
aAdd(_aCabec,{ "B5_PESO"	,		_nPeso				, Nil	})   
aAdd(_aCabec,{ "B5_XPRESEN"	,		"N"					, Nil	})
aAdd(_aCabec,{ "B5_XSTAPRD"	,		"1"					, Nil	})
aAdd(_aCabec,{ "B5_XPERSON"	,		"N"					, Nil	})
aAdd(_aCabec,{ "B5_XUSAECO"	,		"S"					, Nil	})
aAdd(_aCabec,{ "B5_STATUS"	,		"A"					, Nil	})

//----------------------------------------+
// Ordena campos pela ordem do dicionario |
//----------------------------------------+
_aCabec := FWVetByDic(_aCabec, "SB5")

If Len(_aCabec) > 0 .And. _nOpcX == 3
	lMsErroAuto := .F.

	MSExecAuto({|x| Mata180(x)},_aCabec,,_nOpcX)

	If lMsErroAuto
		_cLogSB5 := "SB5" + RTrim(_cCodProd) + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".LOG"
		
		//----------------+
		// Cria diretorio |
		//----------------+ 
		MakeDir("/erros/")
		MostraErro("/erros/",_cLogSB5)
		_nErros++

	Else
		

		dbSelectArea("SB5")
		SB5->( dbSetOrder(1) )
		SB5->( dbSeek(xFilial("SB5") + _cCodProd) )
		RecLock("SB5",.F.)
			SB5->B5_XDESCRI	:= _cLongDesc
			SB5->B5_XCARACT	:= ""
			SB5->B5_XKEYWOR	:= ""
			SB5->B5_XLONPAG	:= ""
		SB5->( MsUnLock() )

		//--------------------------+
		// Grava Campos especificos |
		//--------------------------+
		If !EcLojM02CpoE(_cCodProd,_cLongDesc,_cModoUsar,_cPrecau,_cComposicao)
			_nErros++
			Return .F.
		Endif

		//------------------+
		// Filtros Produtos |
		//------------------+
		If !EcLojM02Fil(_cCodProd,_cGenero)
			_nErros++
			Return .F.
		Endif

		//-----------------+
		// Tabela de Preço |
		//-----------------+
		If !EcLojM02Tab(_cCodProd)
			_nErros++
			Return .F.
		Endif

	EndIf

ElseIf _nOpcX == 4 
	/*
	_aAreaB5 := GetArea()
		If SB5->( dbSeek("05" + _cCodProd) )
			_nIdProd	:= SB5->B5_XIDPROD 
			_nIdSku		:= SB5->B5_XIDSKU
		EndIf
	RestArea(_aAreaB5)

	RecLock("SB5",.F.)
		SB5->B5_XIDPROD 	:= _nIdProd
		SB5->B5_XIDSKU		:= _nIdSku
	SB5->( MsUnLock() )
	*/

	//--------------------------+
	// Grava Campos especificos |
	//--------------------------+
	If !EcLojM02CpoE(_cCodProd,_cLongDesc,_cModoUsar,_cPrecau,_cComposicao)
		_nErros++
		Return .F.
	Endif

	//------------------+
	// Filtros Produtos |
	//------------------+
	If !EcLojM02Fil(_cCodProd,_cGenero)
		_nErros++
		Return .F.
	Endif

	//-----------------+
	// Tabela de Preço |
	//-----------------+
	If !EcLojM02Tab(_cCodProd)
		_nErros++
		Return .F.
	Endif

EndIf	

RestArea(_aArea)	
Return .T.

/**********************************************************/
/*/{Protheus.doc} EcLojM02Mar
    @description Localiza codigo da Marca
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/**********************************************************/
Static Function EcLojM02Mar(_cDescMarca,_cCodMarca)
Local _aArea	:= GetArea()

Local _cMsg		:= ""

Local _lRet		:= .T.

//----------------------------+
// Formata descrição da Marca |
//----------------------------+
_cDescMarca := U_EcAcento(_cDescMarca, .T.)

//-----------------+
// Posiciona Marca |
//-----------------+
dbSelectArea("AY2")
AY2->( dbSetOrder(2) )
If AY2->( dbSeek(xFilial("AY2") + _cDescMarca) )
	_cCodMarca := AY2->AY2_CODIGO
Else	
	_lRet	:= .F.
	CoNout( "Marca " + _cDescMarca + " nao localizada." )
EndIf

RestArea(_aArea)
Return _lRet

/**********************************************************/
/*/{Protheus.doc} EcLojM02Mar
    @description Localiza codigo da Marca
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/**********************************************************/
Static Function EcLojM02Cat(_cCat01,_cCat02,_cCodCat1,_cCodCat2)
Local _aArea	:= GetArea()

Local _cMsg		:= ""
Local _cCpoAux	:= ""
Local _xRet		:= "_cCodCat"
Local _nX 		:= 0

Local _lRet		:= .T.

//----------------------------+
// Formata descrição da Marca |
//----------------------------+
_cCat01 := U_EcAcento(_cCat01, .T.)
_cCat02 := U_EcAcento(_cCat02, .T.,.T.)

dbSelectArea("AY0")
AY0->( dbSetOrder(2) )
For _nX := 1 To 2
	_cCpoAux := &("_cCat0" + Alltrim(Str(_nX)))

	If AY0->( dbSeek(xFilial("AY0") + _cCpoAux) )
		_xRet := AY0->AY0_CODIGO
	Else
		_lRet := .F. 
		ConOut("Não foi localizada a categoria " + _cCpoAux + " .")
		Exit
	EndIf

	If _nX == 1 
		_cCodCat1 := _xRet
	ElseIf _nX == 2 
		_cCodCat2 := _xRet
	EndIf

Next _nX

RestArea(_aArea)
Return _lRet

/*********************************************************************/
/*/{Protheus.doc} EcLojM02CpoE
    @description Grava campos especificos do complemento de produtos
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/*********************************************************************/
Static Function EcLojM02CpoE(_cCodProd,_cLongDesc,_cModoUsar,_cPrecau,_cComposicao)
Local _aArea 	:= GetArea()

Local _lGrava 	:= .T.
//------------------------------+
// Posiciona campos especificos |
//------------------------------+
dbSelectArea("WS6")
WS6->( dbSetOrder(1) )

//-----------------+
// Campo O Produto | 
//-----------------+
_lGrava := .T.
If WS6->( dbSeek(xFilial("WS6") + _cCodProd + "001") )
	_lGrava := .F.
EndIf
RecLock("WS6",_lGrava)
	WS6->WS6_FILIAL := xFilial("WS6")
	WS6->WS6_CODPRD	:= _cCodProd 
	WS6->WS6_CODIGO	:= "001"
	WS6->WS6_CAMPO	:= Posicione("WS5",1,xFilial("WS5") + "001","WS5_CAMPO")
	WS6->WS6_DESCEC	:= _cLongDesc
	WS6->WS6_ENVECO	:= "1"
WS6->( MsUnLock() )	

//--------------------+
// Campo Mode de Usar |
//--------------------+
_lGrava := .T.
If WS6->( dbSeek(xFilial("WS6") + _cCodProd + "002") )
	_lGrava := .F.
EndIf
RecLock("WS6",_lGrava)
	WS6->WS6_FILIAL := xFilial("WS6")
	WS6->WS6_CODPRD	:= _cCodProd 
	WS6->WS6_CODIGO	:= "002"
	WS6->WS6_CAMPO	:= Posicione("WS5",1,xFilial("WS5") + "002","WS5_CAMPO")
	WS6->WS6_DESCEC	:= _cModoUsar
	WS6->WS6_ENVECO	:= "1"
WS6->( MsUnLock() )	

//------------------+
// Campo Precauções |
//------------------+
_lGrava := .T.
If WS6->( dbSeek(xFilial("WS6") + _cCodProd + "003") )
	_lGrava := .F.
EndIf
RecLock("WS6",_lGrava)
	WS6->WS6_FILIAL := xFilial("WS6")
	WS6->WS6_CODPRD	:= _cCodProd 
	WS6->WS6_CODIGO	:= "003"
	WS6->WS6_CAMPO	:= Posicione("WS5",1,xFilial("WS5") + "003","WS5_CAMPO")
	WS6->WS6_DESCEC	:= _cPrecau
	WS6->WS6_ENVECO	:= "1"
WS6->( MsUnLock() )	

//------------------+
// Campo Composição |
//------------------+
_lGrava := .T.
If WS6->( dbSeek(xFilial("WS6") + _cCodProd + "004") )
	_lGrava := .F.
EndIf
RecLock("WS6",_lGrava)
	WS6->WS6_FILIAL := xFilial("WS6")
	WS6->WS6_CODPRD	:= _cCodProd 
	WS6->WS6_CODIGO	:= "004"
	WS6->WS6_CAMPO	:= Posicione("WS5",1,xFilial("WS5") + "004","WS5_CAMPO")
	WS6->WS6_DESCEC	:= _cComposicao
	WS6->WS6_ENVECO	:= "1"
WS6->( MsUnLock() )	

RestArea(_aArea)
Return .T.

/*********************************************************************/
/*/{Protheus.doc} EcLojM02Fil
    @description Grava filtros dos produtos e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/*********************************************************************/
Static Function EcLojM02Fil(_cCodProd,_cGenero)
Local _aArea 		:= GetArea()

Local _lRet			:= .T.
Local _lGrava		:= .T.

//----------------+
// Formata campo  |
//----------------+
_cGenero := U_EcAcento(_cGenero, .T.)

//---------------------------+
// Posiciona valores filtros |
//---------------------------+
dbSelectArea("AY4")
AY4->( dbSetOrder(3) )
If !AY4->( dbSeek(xFilial("AY4") + PadR(_cGenero,_nTDescFil)) )
	_lRet	:= .F.
	CoNout("Nao foi localizado filtro " + _cGenero + " .")
EndIf

dbSelectArea("AY5")
AY5->( dbSetOrder(1) )
If AY5->( dbSeek(xFilial("AY5") + AY4->AY4_CODCAR + AY4->AY4_SEQ + _cCodProd))
	_lGrava := .F.
EndIf

RecLock("AY5",_lGrava)
	AY5->AY5_FILIAL := xFilial("AY5")
	AY5->AY5_CODIGO := AY4->AY4_CODCAR
	AY5->AY5_SEQ	:= AY4->AY4_SEQ
	AY5->AY5_CODPRO	:= _cCodProd
	AY5->AY5_STATUS	:= "1"
	AY5->AY5_ENVECO	:= "1"
AY5->( MsUnLock() )

RestArea(_aArea)
Return _lRet

/*********************************************************************/
/*/{Protheus.doc} EcLojM02Tab
    @description Grava filtros dos produtos e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/*********************************************************************/
Static Function EcLojM02Tab(_cCodProd)
Local _aArea 	:= GetArea()
Local _aStrDA1	:= DA1->( dbStruct() )

Local _cQuery 	:= ""
Local _cItem	:= ""
Local _cCodTab	:= GetNewPar("EC_TABECO")
Local _cAlias	:= GetNextAlias()

Local _nX		:= 0

_cQuery 	:= " SELECT " + CRLF
_cQuery 	+= "	B1.B1_COD, " + CRLF
_cQuery 	+= "	MAX(DA1.DA1_PRCVEN) DA1_PRCVEN " + CRLF
_cQuery 	+= " FROM " + CRLF
_cQuery 	+= "	" + RetSqlName("SB1") + " B1 " + CRLF
_cQuery 	+= "	INNER JOIN " + RetSqlName("DA1") + " DA1 ON DA1.DA1_FILIAL = '05' AND DA1.DA1_CODTAB = 'E03' AND DA1.DA1_GRUPO = B1.B1_GRUPO AND DA1.D_E_L_E_T_ = '' " + CRLF
_cQuery 	+= "	INNER JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = B1.B1_COD AND B5.D_E_L_E_T_ = '' " + CRLF
_cQuery 	+= " WHERE " + CRLF
_cQuery 	+= "	B1.B1_COD = '" + _cCodProd + "' AND " + CRLF
_cQuery 	+= "	B1.D_E_L_E_T_ = '' " + CRLF
_cQuery 	+= " GROUP BY B1.B1_COD " + CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->( Eof() )
	(_cAlias)->( dbCloseArea() )
	Return .F.
EndIf

//------------------------------------+
// Valida se existe tabela e-Commerce |
//------------------------------------+
dbSelectArea("DA0")
DA0->( dbSetOrder(1) )
If !DA0->( dbSeek(xFilial("DA0") + _cCodTab) )
	RecLock("DA0",.T.)
		DA0->DA0_FILIAL := xFilial("DA0")
		DA0->DA0_CODTAB	:= _cCodTab
		DA0->DA0_DESCRI	:= "ECOMMERCE"
		DA0->DA0_DATDE	:= Date()
		DA0->DA0_HORADE	:= "00:00"
		DA0->DA0_HORATE	:= "23:59"
		DA0->DA0_TPHORA	:= "1"
		DA0->DA0_ATIVO	:= "1"
	DA0->( MsUnLock() )
EndIf

dbSelectArea("DA1")
DA1->( dbSetOrder(1) )
If DA1->( dbSeek(xFilial("DA1") + _cCodTab + _cCodProd) )
	RecLock("DA1",.F.)
		DA1->DA1_PRCVEN := (_cAlias)->DA1_PRCVEN
	DA1->( MsUnLock() )
Else
	
	_cItem := EcLjM02Max()

	RecLock("DA1",.T.)
		
		DA1->DA1_FILIAL := xFilial("DA1")

		For _nX := 1 To Len(_aStrDA1)
			If RTrim(_aStrDA1[_nX][1]) == "DA1_ITEM"
				_cCpoDA1 	:= "DA1->" + Alltrim(_aStrDA1[_nX][1])
				&(_cCpoDA1) := _cItem
			ElseIf RTrim(_aStrDA1[_nX][1]) == "DA1_CODTAB"
				_cCpoDA1 	:= "DA1->" + Alltrim(_aStrDA1[_nX][1])
				&(_cCpoDA1) := _cCodTab
			ElseIf RTrim(_aStrDA1[_nX][1]) == "DA1_CODPRO"
				_cCpoDA1 	:= "DA1->" + Alltrim(_aStrDA1[_nX][1])
				&(_cCpoDA1) := _cCodProd
			ElseIf RTrim(_aStrDA1[_nX][1]) == "DA1_PRCVEN"
				_cCpoDA1 	:= "DA1->" + Alltrim(_aStrDA1[_nX][1])
				&(_cCpoDA1) := (_cAlias)->DA1_PRCVEN
			ElseIf !RTrim(_aStrDA1[_nX][1]) $ "DA1_FILIAL"	
				_cCpoDA1 	:= "DA1->" + Alltrim(_aStrDA1[_nX][1])
				&(_cCpoDA1) := CriaVar(Alltrim(_aStrDA1[_nX][1]),.T.)	
			EndIf
		Next _nX
	DA1->( MsUnLock() )
EndIf

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return .T.

/*********************************************************************/
/*/{Protheus.doc} EcLjM02Max
    @description Retorna proximo item da tabela de preços
    @type  Static Function
    @author Bernard M. Margarido
    @since 10/08/2019
    @version 1.0
/*/
/*********************************************************************/
Static Function EcLjM02Max()
Local _cQuery 	:= ""
Local _cItem	:= ""
Local _cCodTab	:= GetNewPar("EC_TABECO")
Local _cAlias	:= GetNextAlias()

_cQuery 	:= " SELECT " + CRLF
_cQuery 	+= "	MAX(DA1.DA1_ITEM) DA1_ITEM " + CRLF
_cQuery 	+= " FROM " + CRLF
_cQuery 	+= "	" + RetSqlName("DA1") + " DA1 " + CRLF
_cQuery 	+= " WHERE " + CRLF
_cQuery 	+= "	DA1.DA1_FILIAL = '" + xFilial("DA1") + "' AND " + CRLF
_cQuery 	+= "	DA1.DA1_CODTAB = '" + _cCodTab + "' AND " + CRLF
_cQuery 	+= "	DA1.D_E_L_E_T_ = '' " + CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

_cItem	:= Soma1(Rtrim((_cAlias)->DA1_ITEM))

(_cAlias)->( dbCloseArea() )

Return _cItem