#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "PARMTYPE.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************************/
/*/{Protheus.doc} ECLOJM10
    @description Realiza a impressçao da Danfe reduzida 
    @type  Function
    @author Bernard M Margarido
    @since 22/03/2023
    @version version
/*/
/************************************************************************************/
User Function ECLOJM10(_oSay,_cCodEtq)
Local _aArea    := GetArea() 

Local _cDoc         := ""
Local _cSerie       := ""
Local _cCodImp      := ""

Local _nTpDanfe     := 0 
Local _nTpImp       := 0 

Private __prtSrv    := GetImpWindows( .T. )  
Private __prtCli    := GetImpWindows( .F. )  

//-------------------+
// Parametros padrão |
//-------------------+
Pergunte("ECLOJ12",.F.)
_nTpImp  := mv_par01 
_nTpDanfe:= mv_par02 
_cCodImp := mv_par03

//---------------------------------------+
// Valida se nota pertence ao e-Commerce |
//---------------------------------------+
_oSay:cCaption  := "Validando se nota pertence ao e-Commerce."
ProcessMessages()
If !EcLojM10A(_cCodEtq,@_cDoc,@_cSerie)
    MsgStop("Etiqueta não pertencente ao e-Commerce.","Dana Avisos!")
    RestArea(_aArea)
    Return .F.
EndIf 

//------------------------+
// Imprime Danfe reduzida | 
//------------------------+
_oSay:cCaption  := "Validando danfe nota " + _cDoc + " serie " + _cSerie + " ."
ProcessMessages()
EcLojM10B(_cDoc,_cSerie,_nTpDanfe,_nTpImp,_cCodImp,_oSay)


RestArea(_aArea)
Return Nil 

/************************************************************************************/
/*/{Protheus.doc} EcLojM10A
    @description Valida se nota pertence ao e-Commerce
    @type  Static Function
    @author Bernard M Margarido 
    @since 22/03/2023
    @version version
/*/
/************************************************************************************/
Static Function EcLojM10A(_cCodEtq,_cDoc,_cSerie)
Local _cAlias   := ""
Local _cQuery   := ""

Local _lRet     := .T. 

_cQuery := " SELECT " + CRLF
_cQuery += "	F2.F2_DOC, " + CRLF
_cQuery += "	F2.F2_SERIE, " + CRLF
_cQuery += "	WSA.WSA_NUMECO, " + CRLF
_cQuery += "	C5.C5_XNUMECO " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SF2") + " F2 (NOLOCK) " + CRLF
_cQuery += "	LEFT JOIN " + RetSqlName("WSA") + " WSA (NOLOCK) ON WSA.WSA_FILIAL = F2.F2_FILIAL AND WSA.WSA_DOC = F2.F2_DOC AND WSA.WSA_SERIE = F2.F2_SERIE AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	CROSS APPLY( " + CRLF
_cQuery += "		SELECT " + CRLF 
_cQuery += "            TOP 1 " + CRLF
_cQuery += "			D2.D2_FILIAL, " + CRLF
_cQuery += "			D2.D2_PEDIDO " + CRLF
_cQuery += "		FROM " + CRLF
_cQuery += "			" + RetSqlName("SD2") + " D2 (NOLOCK) " + CRLF 
_cQuery += "		WHERE " + CRLF
_cQuery += "			D2.D2_FILIAL = F2.F2_FILIAL AND " + CRLF
_cQuery += "			D2.D2_DOC = F2.F2_DOC AND " + CRLF
_cQuery += "			D2.D2_SERIE = F2.F2_SERIE AND " + CRLF
_cQuery += "			D2.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	) ITEM_PEDIDO " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " C5 (NOLOCK) ON C5.C5_FILIAL = ITEM_PEDIDO.D2_FILIAL AND C5.C5_NUM = ITEM_PEDIDO.D2_PEDIDO AND C5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	F2.F2_FILIAL = '" + xFilial("SF2") + "' AND " + CRLF
_cQuery += "	F2.F2_DOC = '" + _cCodEtq + "' AND " + CRLF
_cQuery += "	F2.F2_SERIE = '50' AND " + CRLF
_cQuery += "	F2.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If Empty((_cAlias)->WSA_NUMECO) .And. Emtpy((_cAlias)->C5_XNUMECO)
    _lRet := .F.
EndIf 

If _lRet 
    _cDoc   := (_cAlias)->F2_DOC
    _cSerie := (_cAlias)->F2_SERIE
    _lRet   := IIF(Empty((_cAlias)->F2_DOC), .F., .T.)
EndIf 

(_cAlias)->( dbCloseArea() )

Return _lRet

/************************************************************************************/
/*/{Protheus.doc} EcLojM10B
    @description Realiza a impressão da Danfe reduzida 
    @type  Static Function
    @author Bernard M Margarido
    @since 23/03/2023
    @version version
/*/
/************************************************************************************/
Static Function EcLojM10B(_cDoc,_cSerie,_nTpDanfe,_nTpImp,_cCodImp,_oSay)
Private _oSetup := Nil 

//-----+
// PDF |
//-----+
/*
If _nTpImp == 2 
    _oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN,"DANFE SIMPLIFICADA")
    _oSetup:SetPropert(PD_PRINTTYPE , 2) //Spool
    _oSetup:SetPropert(PD_ORIENTATION , 2)
    _oSetup:SetPropert(PD_DESTINATION , 1)
    _oSetup:SetPropert(PD_MARGIN , {0,0,0,0})
    _oSetup:SetPropert(PD_PAPERSIZE , 2)
    If !_oSetup:Activate() == PD_OK
        RestArea(_aArea)
        Return .F.
    Endif
EndIf 
*/

//----------------------+
// Imprime danfe padrao |
//----------------------+
If _nTpDanfe == 1

    EcLojM10C(_cDoc,_cSerie,_oSay)

//------------------------+
// Imprime danfe reduzida |
//------------------------+
ElseIf _nTpDanfe == 2
    
    EcLojM10D(_cDoc,_cSerie,_cCodImp,_nTpImp,_oSay)

EndIf 

//----------+
// Etiqueta |
//----------+
EcLojM10E(_cDoc,_cSerie,_cCodImp,_nTpImp,_oSay)

FreeObj(_oSetup)

Return Nil 

/***********************************************************************************/
/*/{Protheus.doc} EcLojM10C
    @description Realiza a impressão da Danfe 
    @type  Static Function
    @author Bernard M Margarido
    @since 24/03/2023
    @version version
/*/
/***********************************************************************************/
Static Function EcLojM10C(_cDoc,_cSerie,_oSay)
Local _aArea		:= GetArea()

Local _cArqDanfe	:= "DANFE_" + RTrim(_cDoc) + "_" + RTrim(_cSerie)
Local _cDirInPdf	:= "\expedicao\danfe"
Local _cDirlocal    := GetTempPath()
Local _cIdent   	:= ""

Local _lEnd     	:= .F.
Local _lExistNFe	:= .F.

Local _nTNota  		:= TamSX3('F2_DOC')[1]
Local _nTSerie 		:= TamSX3('F2_SERIE')[1]

Local oDanfe   		:= Nil
    
Private PixelX
Private PixelY

Private nConsNeg
Private nConsTex
Private nColAux

Private oRetNF

_oSay:cCaption  := "Imprimindo danfe padrao nota " + _cDoc + " serie " + _cSerie + " ."
ProcessMessages()

//--------------------------------+
// Cria diretorio caso nao exista |
//--------------------------------+
MakeDir("\expedicao\")
MakeDir("\expedicao\danfe")

//----------------------------+
// Retorna o IDENT da empresa |
//----------------------------+
_cIdent := GetIdEnt()   

//------------------------------------+
// Caso nao encontre IDENT da empresa |
//------------------------------------+
If Empty(_cIdent)
	RestArea(_aArea)
	Return .F.
EndIf        

//--------------------------------------------------------------------------+
// Se o último caracter da pasta não for barra, será barra para integridade |
//--------------------------------------------------------------------------+
If SubStr(_cDirInPdf, Len(_cDirInPdf), 1) != "\"
    _cDirInPdf += "\"
EndIf 

//------------------------------+ 
// Define as perguntas da DANFE |
//------------------------------+
Pergunte("NFSIGW",.F.)

_lEnd    := .F.
mv_par01 := PadR(_cDoc,  _nTNota)     	//Nota Inicial
mv_par02 := PadR(_cDoc,  _nTNota)     	//Nota Final
mv_par03 := PadR(_cSerie, _nTSerie)   	//Série da Nota
mv_par04 := 2       					//NF de Saida/Entrada
mv_par05 := 2                          	//Frente e Verso = Sim
mv_par06 := 2                          	//DANFE simplificado = Nao

//----------------------------+
// Deleta arquivo caso exista |
//----------------------------+
If File(_cDirInPdf + _cArqDanfe + ".pdf")
	FErase(_cDirInPdf + _cArqDanfe + ".pdf")
EndIf

//--------------+
// Cria a Danfe |
//--------------+
oDanfe := FWMSPrinter():New(_cArqDanfe, IMP_PDF, .F., _cDirInPdf, .T., , , , .T., , .F., )

//-----------------------+     
// Propriedades da DANFE |
//-----------------------+
oDanfe:SetResolution(78)
oDanfe:SetLandscape()
oDanfe:SetPaperSize(DMPAPER_A4)
oDanfe:SetMargin(60, 60, 60, 60)
oDanfe:nDevice      := IMP_PDF
oDanfe:cPathPDF     := _cDirlocal
oDanfe:lServer  	:= .T. 
oDanfe:lInJob  		:= .T.
oDanfe:lViewPDF 	:= .F.
/*
If _oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
    oDanfe:nDevice  := IMP_PDF
    oDanfe:cPathPDF := _cDirInPdf
    oDanfe:cPathPDF := IIF( Empty(_oSetup:aOptions[PD_VALUETYPE]), _cDirInPdf , _oSetup:aOptions[PD_VALUETYPE] )
ElseIf _oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
   oDanfe:nDevice := IMP_SPOOL
    fwWriteProfString(GetPrinterSession(),"DEFAULT", _oSetup:aOptions[PD_VALUETYPE], .T.)
    oDanfe:cPrinter := _oSetup:aOptions[PD_VALUETYPE]
EndIf 
*/
//--------------------------+     
// Força a impressão em PDF |
//--------------------------+
//_oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER 

//--------------------------------------------------------------+     
// Variáveis obrigatórias da DANFE (pode colocar outras abaixo) |
//--------------------------------------------------------------+
PixelX    := oDanfe:nLogPixelX()
PixelY    := oDanfe:nLogPixelY()
nConsNeg  := 0.4
nConsTex  := 0.5
oRetNF    := Nil
nColAux   := 0

//-----------------------------------------+     
// Chamando a impressão da danfe no RDMAKE |	  
//-----------------------------------------+  
_cStatic    := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
Eval( {|| &(_cStatic + "(" + "DANFEIII, DANFEProc, @oDanfe,@_lEnd,_cIdent,,,@_lExistNFe, .F." + ")") })  

If _lExistNFe

    oDanfe:Preview() 
    //oDanfe:Print() 
	//-------------------------------+
	// Emula uso do TotvsPrinter.exe |
	//-------------------------------+
    //.Or. File(oDanfe:cPathPDF + oDanfe:cFileName)
	If File(oDanfe:cFilePrint) 
        If Type("oDanfe:nHandle") <> "U"
            FClose(oDanfe:nHandle)
        EndIf
        File2Printer(oDanfe:cFilePrint, "PDF" )
        Sleep(20000)
        FErase(oDanfe:cFilePrint)
    EndIf

EndIf

FreeObj(oDanfe)
oDanfe := Nil

RestArea(_aArea)        
Return Nil 

/*************************************************************************************/
/*/{Protheus.doc} EcLojM10D
    @description Realiza a impressão da danfe reduzida via impressora termica 
    @type  Static Function
    @author Bernard M Margarido
    @since 24/03/2023
    @version version
/*/
/*************************************************************************************/
Static Function EcLojM10D(_cDoc,_cSerie,_cCodImp,_nTpImp,_oSay)
Local _aArea        := GetArea()
Local _aEmit        := {}
Local _aNotas       := {}
Local _aParam       := {}
Local _aNfe         := {}
Local _aDest        := {}

Local _cURL         := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local _cArqDanfe    := "DANFE_ETIQUETA_" + RTrim(_cDoc) + "_" + RTrim(_cSerie) + "_" + Dtos(MSDate()) + StrTran(Time(),":","")
Local _cDirInPdf	:= "\expedicao\danfe"
Local _cDirlocal    := GetTempPath()
Local _cIdent       := ""
Local _cAviso       := ""
Local _cErro        := ""
Local _cProtocolo   := ""
Local _cDpecProt    := ""
Local _cLogo        := ""
Local _cTotNota     := ""
Local _cXml         := ""
Local _cGrpCompany	:= ""
Local _cCodEmpGrp	:= ""
Local _cUnitGrp	    := ""
Local _cFilGrp		:= ""
Local _cDescLogo    := ""
Local _cLogoD       := ""

Local _nLinha       := 0
Local _nColuna      := 0
Local _nTCodImp     := TamSx3("CB5_CODIGO")[1]

Local _lMvLogo      := IIF(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )

Local _oRetNF       := Nil 
Local _oPrint       := Nil 
Local _oFontTit     := Nil
Local _oFontInf     := Nil 

_oSay:cCaption  := "Imprimindo danfe reduzida nota " + _cDoc + " serie " + _cSerie + " ."
ProcessMessages()

//----------------------------+
// Retorna o IDENT da empresa |
//----------------------------+
_cIdent := GetIdEnt()  
_aParam := {_cSerie,_cDoc,_cDoc}
_aNotas := procMonitorDoc(_cIdent, _cURL, _aParam, 1,,, @_cAviso)

_aEmit    := Array(4)
_aEmit[1] := AllTrim(SM0->M0_NOMECOM)
_aEmit[2] := AllTrim(SM0->M0_CGC)
_aEmit[3] := AllTrim(SM0->M0_INSC)
_aEmit[4] := if(!GetNewPar("MV_SPEDEND",.F.),alltrim(SM0->M0_ESTCOB),alltrim(SM0->M0_ESTENT))

//-------------------------+
// SA1 - Posiciona cliente |
//-------------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )

//-----------------------------+
// SF3 - Posiciona nota fiscal |
//-----------------------------+
dbSelectArea("SF3")
SF3->( dbSetOrder(5) )

//-----------------------------+
// SF2 - Posiciona Nota fiscal |
//-----------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

//-----------------------+
// Posiciona nota fiscal | 
//-----------------------+
If !SF2->(dbSeek(xFilial("SF2") + _cDoc + _cSerie) )
    MsgStop("Nota fiscal nao localizada.","Dana Avisos!")
    RestArea(_aArea)
    Return .F.
EndIf 

//-------------------+
// Posiciona cliente | 
//-------------------+
If !SA1->( dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA) )
    MsgStop("Nota fiscal nao localizada.","Dana Avisos!")
    RestArea(_aArea)
    Return .F.
EndIf 

If !SF3->(dbSeek(xFilial("SF3") + SF3->F3_SERIE + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA))
    MsgStop("Nota fiscal nao localizada.","Dana Avisos!")
    RestArea(_aArea)
    Return .F.
EndIf 

_cXml       := aTail(_aNotas[1])[2]
_cProtocolo := _aNotas[1][4]
_cDpecProt  := aTail(_aNotas[1])[3]
_cSerie     := _aNotas[1][2]
_cDoc       := _aNotas[1][3]

_oRetNF     := XmlParser(_cXml,"_",@_cAviso,@_cErro)
If ValAtrib("_oRetNF:_NFEPROC") <> "U"
    _oNfe := WSAdvValue( _oRetNF,"_NFEPROC","string",NIL,NIL,NIL,NIL,NIL)
Else
    _oNfe := _oRetNF
EndIf

If ValAtrib("_oNfe:_NFe:_InfNfe:_Total") == "U"
    MsgStop("Nota fiscal nao localizada.","Dana Avisos!")
Else
    _oTotal := _oNfe:_NFe:_InfNfe:_Total
EndIf

//-------------+
// Valida Logo | 
//-------------+
If _lMvLogo

    _cGrpCompany:= AllTrim(FWGrpCompany())
    _cCodEmpGrp	:= AllTrim(FWCodEmp())
    _cUnitGrp	:= AllTrim(FWUnitBusiness())
    _cFilGrp	:= AllTrim(FWFilial())

    If !Empty(_cUnitGrp)
        _cDescLogo := _cGrpCompany + _cCodEmpGrp + _cUnitGrp + _cFilGrp
    Else
        _cDescLogo := cEmpAnt + cFilAnt
    EndIf 

    _cLogoD := GetSrvProfString("Startpath","") + "DANFE" + _cDescLogo + ".BMP"
    If !File(_cLogoD)
        _cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
        If !File(_cLogoD)
            _lMvLogo := .F.
        EndIf
    EndIf
EndIf

If _lMvLogo
    _cLogo := _cLogoD
Else
    _cLogo := FisxLogo("1")
EndIf

_cTotNota   := AllTrim(Transform(Val(_oTotal:_ICMSTOT:_vNF:TEXT),"@e 9,999,999,999,999.99"))
_aNfe       := Array(9)
_aNfe[1]    := SF3->F3_CHVNFE
_aNfe[2]    := _cProtocolo
_aNfe[3]    := _cDpecProt
_aNfe[4]    := _cLogo
_aNfe[5]    := IIF( SubStr(SF3->F3_CFO,1,1) >= '5', "1", "0" ) // 0 - Entrada / 1 - Saída
_aNfe[6]    := SF3->F3_NFISCAL
_aNfe[7]    := SF3->F3_SERIE
_aNfe[8]    := SF3->F3_EMISSAO
_aNfe[9]    := _cTotNota

_aDest      := Array(4)  
_aDest[1]   := AllTrim(SA1->A1_NOME)
_aDest[2]   := AllTrim(SA1->A1_CGC)
_aDest[3]   := AllTrim(SA1->A1_INSCR)
_aDest[4]   := AllTrim(SA1->A1_EST)

//-------------------+
// Tipo de impressão |
//-------------------+

//---------+
// Termica |
//---------+
If _nTpImp == 1
    
    dbSelectArea("CB5")
    CB5->( dbSetOrder(1) )
    If !CB5->(DbSeek( xFilial("CB5") + PadR(_cCodImp, _nTCodImp) )) .Or. !CB5SetImp(_cCodImp)
        MsgStop("Local de impressão não encontrado, Informe um local de impressão cadastrado. Acesse a rotina 'Locais de Impressão'.","Dana Avisos!")
        RestArea(_aArea)
        Return .F.
    EndIf

    _cStatic    := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
    Eval( {|| &(_cStatic + "(" + "DanfeEtiqueta, impZebra, _aNfe, _aEmit, _aDest" + ")") })
    MSCBCLOSEPRINTER()

//-----+
// PDF |
//-----+
ElseIf _nTpImp == 2
    //--------------------------------+
    // Cria diretorio caso nao exista |
    //--------------------------------+
    MakeDir("\expedicao\")
    MakeDir("\expedicao\danfe")

    //--------------------------------------------------------------------------+
    // Se o último caracter da pasta não for barra, será barra para integridade |
    //--------------------------------------------------------------------------+
    If SubStr(_cDirInPdf, Len(_cDirInPdf), 1) != "\"
        _cDirInPdf += "\"
    EndIf     

    _oFontTit       := TFont():New( "Arial", , -8, .T.)
    _oFontTit:Bold  := .T.
    _oFontInf       := TFont():New( "Arial", , -8, .T.)
	_oFontInf:Bold  := .F.
    _nLinha         := 0
    _nColuna        := 0

    _oPrint := FWMSPrinter():New(_cArqDanfe, IMP_PDF, .F., _cDirInPdf, .T.,,,,.T.,,.F.)
    _oPrint:SetLandscape()
    _oPrint:SetPaperSize(DMPAPER_A4)
    //_oPrint:lInJob  	:= .T.
    //_oPrint:lServer  	:= .T.
    //_oPrint:lViewPDF 	:= .F.
    //_oPrint:nDevice     := IMP_PDF
    _oPrint:cPathPDF    := _cDirlocal
    //_oPrint:SetCopies(Val(_oSetup:cQtdCopia))
    /*
    If _oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
        _oPrint:nDevice   := IMP_PDF
        _oPrint:cPathPDF  := _cDirInPdf
        _oPrint:cPathPDF := IIF( Empty(_oSetup:aOptions[PD_VALUETYPE]), _cDirInPdf , _oSetup:aOptions[PD_VALUETYPE] )
    ElseIf _oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
        _oPrint:nDevice := IMP_SPOOL
        fwWriteProfString(GetPrinterSession(),"DEFAULT", _oSetup:aOptions[PD_VALUETYPE], .T.)
        _oPrint:cPrinter := _oSetup:aOptions[PD_VALUETYPE]
    EndIf 
    */

    _cStatic    := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
    Eval( {|| &(_cStatic + "(" + "DanfeEtiqueta, DanfeSimp, @_oPrint, _nLinha, _nColuna, _oFontTit, _oFontInf, _aEmit, _aNfe, _aDest" + ")") })
    
    _oPrint:EndPage()
    _oPrint:Preview()

    //-------------------------------+
	// Emula uso do TotvsPrinter.exe |
	//-------------------------------+
    //.Or. File(_oPrint:cPathPDF + StrTran(_oPrint:cFileName,".rel",".pdf") ) 
	If File(_oPrint:cFilePrint) 
        //_oPrint:Print()
        If Type("_oPrint:nHandle") <> "U"
            FClose(_oPrint:nHandle)
        EndIf
        File2Printer(_oPrint:cFilePrint, "PDF" )
        Sleep(20000)
        FErase(_oPrint:cFilePrint)
    EndIf    

    FreeObj(_oPrint)

EndIf 

RestArea(_aArea)
Return Nil 

/*************************************************************************************/
/*/{Protheus.doc} EcLojM10E
    @description Realiza a impressão da etiqueta 
    @type  Static Function
    @author Bernard M Margarido
    @since 24/03/2023
    @version version
/*/
/*************************************************************************************/
Static Function EcLojM10E(_cDoc,_cSerie,_cCodImp,_nTpImp,_oSay)
Local _cAlias       := ""
Local _cPlpID	    := ""
Local _cPedido	    := ""
Local _cCodEtq	    := ""
Local _cDest	    := ""
Local _cEndDest	    := ""
Local _cBairro	    := ""
Local _cMunicipio	:= ""
Local _cCep		    := ""
Local _cUF		    := ""
Local _cObs		    := ""
Local _cCodServ	    := ""
Local _cDescSer	    := ""
Local _cTelDest	    := ""
Local _cDTMatrix	:= ""
Local _nValor		:= ""

Local _nVolume	    := 0
Local _nPeso		:= 0

//-----------------------------------+
// Valida se nota pertence ao SIGEP  |
//-----------------------------------+
If !EcLojM10EA(_cDoc,_cSerie,@_cAlias)
    Return Nil 
EndIf 

//---------------------------+
// Valdia status da etiqueta |
//---------------------------+
If (_cAlias)->ZZ4_STATUS == "01"
    MsgStop("PLP " + RTrim((_cAlias)->ZZ4_PLPID) + " não integrada no SIGEP. Favor enviar a PLP e reimprimir a etiqueta!","Dana Avisos!")
    Return .F.
ElseIf (_cAlias)->ZZ4_STATUS == "03"
    MsgStop("PLP " + RTrim((_cAlias)->ZZ4_PLPID) + " com erro no SIGEP. Favor falar com o responsavel!","Dana Avisos!")
    Return .F.
EndIf 

_oSay:cCaption  := "Imprimindo etiqueta nota " + _cDoc + " serie " + _cSerie + " ."
ProcessMessages()

//------------------+	
// Imprime etiqueta |
//------------------+

_cPlpID		:= (_cAlias)->ZZ4_PLPID
_cPedido	:= (_cAlias)->ZZ4_NUMSC5
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
_nVolume	:= (_cAlias)->F2_VOLUME1
_nPeso		:= IIF((_cAlias)->C5_PBRUTO > 0, (_cAlias)->C5_PBRUTO * 1000, 100) 

//---------+
// Termica |
//---------+
If _nTpImp == 1
    EcLojM10EB( _cPlpID,_cDoc,_cSerie,_cPedido,_cCodEtq,_cDest,;
                _cEndDest,_cBairro,_cMunicipio,_cCep,_cUF,_cObs,;
                _cCodServ,_cDescSer,_cTelDest,_cDTMatrix,_nValor,;
                _nVolume,_nPeso,_cCodImp)
//-----+
// PDF |
//-----+
ElseIf _nTpImp == 2
    EcLojM10EC( _cPlpID,_cDoc,_cSerie,_cPedido,_cCodEtq,_cDest,;
                _cEndDest,_cBairro,_cMunicipio,_cCep,_cUF,_cObs,;
                _cCodServ,_cDescSer,_cTelDest,_cDTMatrix,_nValor,;
                _nVolume,_nPeso)
EndIf 

Return Nil 

/*************************************************************************************/
/*/{Protheus.doc} EcLojM10EA
    @description Realiza a consulta da nota na PLP
    @type  Static Function
    @author Bernard M Margarido
    @since 27/03/2023
    @version version
/*/
/*************************************************************************************/
Static Function EcLojM10EA(_cDoc,_cSerie,_cAlias)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	ZZ4.ZZ4_PLPID, " + CRLF
_cQuery += "	ZZ4.ZZ4_NOTA, " + CRLF
_cQuery += "	ZZ4.ZZ4_SERIE, " + CRLF 
_cQuery += "	ZZ4.ZZ4_NUMSC5, " + CRLF
_cQuery += "	ZZ4.ZZ4_CODETQ, " + CRLF
_cQuery += "	ZZ4.ZZ4_STATUS, " + CRLF
_cQuery += "	WSA_NOMDES, " + CRLF
_cQuery += "	WSA_ENDENT, " + CRLF
_cQuery += "	WSA_BAIRRE, " + CRLF
_cQuery += "	WSA_MUNE, " + CRLF
_cQuery += "	WSA_CEPE, " + CRLF 
_cQuery += "	WSA_ESTE, " + CRLF
_cQuery += "	WSA_COMPLE, " + CRLF
_cQuery += "	WSA_TEL01, " + CRLF
_cQuery += "	WSA_VLRTOT, " + CRLF
_cQuery += "	ZZ0_CODSER, " + CRLF
_cQuery += "	ZZ0_DESCRI, " + CRLF
_cQuery += "	C5_PBRUTO, " + CRLF
_cQuery += "	SF2.F2_VOLUME1 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("ZZ4") + " ZZ4 (NOLOCK) " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("ZZ0") + " ZZ0 (NOLOCK) ON ZZ0.ZZ0_FILIAL = ZZ4.ZZ4_FILIAL AND ZZ0.ZZ0_IDSER = ZZ4.ZZ4_CODSPO AND ZZ0.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("WSA") + " WSA (NOLOCK) ON WSA.WSA_FILIAL = ZZ4.ZZ4_FILIAL AND WSA.WSA_NUMECO = ZZ4.ZZ4_NUMECO AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " SC5 (NOLOCK) ON SC5.C5_FILIAL = ZZ4.ZZ4_FILIAL AND SC5.C5_NUM = ZZ4.ZZ4_NUMSC5 AND SC5.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SF2") + " SF2 (NOLOCK) ON SF2.F2_FILIAL = ZZ4.ZZ4_FILIAL AND SF2.F2_DOC = ZZ4.ZZ4_NOTA AND SF2.F2_SERIE = ZZ4.ZZ4_SERIE AND SF2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZ4.ZZ4_FILIAL = '" + xFilial("ZZ4") + "' AND " + CRLF
_cQuery += "	ZZ4.ZZ4_NOTA = '" + _cDoc + "' AND " + CRLF
_cQuery += "	ZZ4.ZZ4_SERIE = '" + _cSerie + "' AND " + CRLF
_cQuery += "	ZZ4.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() ) .Or. Empty((_cAlias)->ZZ4_PLPID)
    (_cAlias)->( dbCloseArea() )    
    Return .F. 
EndIf 

Return .T. 

/*************************************************************************************/
/*/{Protheus.doc} EcLojM10EB
    @description Realiza a impressão da etiqueta termica 
    @type  Static Function
    @author Bernard M Margarido
    @since 27/03/2023
    @version version
/*/
/*************************************************************************************/
Static Function EcLojM10EB( _cPlpID,_cDoc,_cSerie,_cPedido,_cCodEtq,_cDest,;
                            _cEndDest,_cBairro,_cMunicipio,_cCep,_cUF,_cObs,;
                            _cCodServ,_cDescSer,_cTelDest,_cDTMatrix,_nValor,;
                            _nVolume,_nPeso,_cCodImp)

Local _cEtq         := ""
Local _cTotEtq      := ""

Local _nX           := 0 
Local _nTCodImp     := TamSx3("CB5_CODIGO")[1]

For _nX := 1 To _nVolume

    _cEtq       := ""
    _cStatic    := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
    Eval( {|| &(_cStatic + "(" + "SIGR003, SigR03Etq, _cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,_cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,_cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,_nValor,_nX,_nPeso,@_cEtq" + ")") })

    If !Empty(_cEtq)
        _cTotEtq += _cEtq 
    EndIf

Next _nX 

//---------------------------------+
// Realiza a impressão de etiqueta |
//---------------------------------+
If !Empty(_cTotEtq)

    dbSelectArea("CB5")
    CB5->( dbSetOrder(1) )
    If !CB5->(DbSeek( xFilial("CB5") + PadR(_cCodImp, _nTCodImp) )) .Or. !CB5SetImp(_cCodImp)
        MsgStop("Local de impressão não encontrado, Informe um local de impressão cadastrado. Acesse a rotina 'Locais de Impressão'.","Dana Avisos!")
        RestArea(_aArea)
        Return .F.
    EndIf
    
    //------------------------+
    // Inicializa a impressão |
    //------------------------+
    MSCBBegin(1,6,150)

    //---------------------------+
    // Envia imagem de impressao |
    //---------------------------+
    MSCBWrite(_cTotEtq)
            
    //---------------------------------+
    // Finaliza a Imagem da Impressora |
    //---------------------------------+
    MscbEnd()

    //--------------------------------------+
    // Encerra comunicação com a impressora |
    //--------------------------------------+
    MSCBClosePrinter()

EndIf

/*
SigR03Etq(	_cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,;
            _cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,;
            _cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,;
            _nValor,_nVolume,_nPeso,@_cEtq)
*/



Return Nil 

/*************************************************************************************/
/*/{Protheus.doc} EcLojM10EC
    @description Imprime PDF etiqueta 
    @type  Static Function
    @author Bernard M Margarido
    @since 27/03/2023
    @version version
/*/
/*************************************************************************************/
Static Function  EcLojM10EC(_cPlpID,_cDoc,_cSerie,_cPedido,_cCodEtq,_cDest,;
                            _cEndDest,_cBairro,_cMunicipio,_cCep,_cUF,_cObs,;
                            _cCodServ,_cDescSer,_cTelDest,_cDTMatrix,_nValor,;
                            _nVolume,_nPeso)

Local _cFile            := "ETQ_" + RTrim(_cPlpID) + "_"  + RTrim(_cDoc) + "_" + RTrim(_cSerie)
Local _cStatic          := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
Local _cDirInPdf		:= "\expedicao\etiqueta"
Local _cDirlocal        := GetTempPath()

Local _nX               := 0 

Local _oPrint           := Nil 

Local _lAdjustToLegacy	:= .F.
Local _lDisableSetup	:= .T.

//--------------------------------+
// Cria diretorio caso nao exista |
//--------------------------------+
MakeDir("\expedicao\")
MakeDir("\expedicao\etiqueta")

//--------------------------------------------------------------------------+
// Se o último caracter da pasta não for barra, será barra para integridade |
//--------------------------------------------------------------------------+
If SubStr(_cDirInPdf, Len(_cDirInPdf), 1) != "\"
    _cDirInPdf += "\"
EndIf         

//------------------+
// Instancia classe | 
//------------------+
_oPrint	:=	FWMSPrinter():New(_cFile, IMP_PDF, _lAdjustToLegacy, _cDirInPdf, _lDisableSetup, , , , .T., , .F.)

//---------------------+
// Configura Relatorio |
//---------------------+
_oPrint:setResolution(78)
_oPrint:SetPortrait()
_oPrint:setPaperSize(DMPAPER_A4)
_oPrint:SetMargin(10,10,10,10)
//_oPrint:lInJob  	:= .T.
//_oPrint:lServer  	:= .T.
//_oPrint:lViewPDF 	:= .F.
//_oPrint:nDevice     := IMP_PDF
_oPrint:cPathPDF    := _cDirlocal

/*
If _oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
    _oPrint:nDevice := IMP_PDF
    _oPrint:cPathPDF:= _cDirInPdf
    _oPrint:cPathPDF := IIF( Empty(_oSetup:aOptions[PD_VALUETYPE]), _cDir , _oSetup:aOptions[PD_VALUETYPE] )
ElseIf _oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
    _oPrint:nDevice := IMP_SPOOL
    fwWriteProfString(GetPrinterSession(),"DEFAULT", _oSetup:aOptions[PD_VALUETYPE], .T.)
    _oPrint:cPrinter := _oSetup:aOptions[PD_VALUETYPE]
EndIf 
*/

For _nX := 1 To _nVolume
    
    Eval( {|| &(_cStatic + "(" + "SIGR001, SigR01Etq, @_oPrint,_cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,_cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,_cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,_nValor,_nX,_nPeso" + ")") })

Next _nX 

//-------------------------------+
// Emula uso do TotvsPrinter.exe |
//-------------------------------+
_oPrint:Preview()

// .Or. File(_oPrint:cPathPDF + StrTran(_oPrint:cFileName,".rel",".pdf") )
If File(_oPrint:cFilePrint) 
    If Type("_oPrint:nHandle") <> "U"
        FClose(_oPrint:nHandle)
    EndIf
    File2Printer(_oPrint:cFilePrint, "PDF" )
    Sleep(20000)
    FErase(_oPrint:cFilePrint)
EndIf    

FreeObj(_oPrint)

Return Nil 

/*************************************************************************************/
/*/{Protheus.doc} GetIdEnt
    @description Retorna IDENT da empresa
    @author TOTVS
    @since 22/05/2019
    @version 1.0
    @type function
/*/
/*************************************************************************************/
Static Function GetIdEnt(lUsaColab)
Local _cIdEnt := ""
Local _cError := ""

Default lUsaColab := .F.

If !lUsaColab
	_cIdEnt := getCfgEntidade(@_cError)
	If(Empty(_cIdEnt))
		CoNout("SPED - " + _cError)
	Endif
Else
	If !( ColCheckUpd() )
		CoNout("SPED - UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0")
	Else
		cIdEnt := "000000"
	Endif	 
EndIf	

Return _cIdEnt

Static Function ValAtrib(atributo)
Return ( type(atributo) )
