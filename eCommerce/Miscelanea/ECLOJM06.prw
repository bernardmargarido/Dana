#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "APWIZARD.CH"

#DEFINE IMP_SPOOL 2
#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/ibex/"
Static _cDirArq     := "/danfe/"

/******************************************************************************/
/*/{Protheus.doc} ECLOJM06
    @descrption JOB - Envio Danfe IBEX
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
User Function ECLOJM06(_cEmp,_cFil)
Local _aArea        := GetArea()

Private _lJob       := IIF(Isincallstack("U_ECLOJ010"),.F.,.T.) 

Private _oProcess   := Nil

//------------------+
// Mensagem console |
//------------------+
CoNout("<< ECLOJM06 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)
MakeDir(_cDirRaiz + _cDirArq)

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmp, _cFil,,,'FAT')
EndIf

//----------------------------+
// Integração Danfe eCommerce |
//----------------------------+
CoNout("<< EcLojM06A >> - INICIO INTEGRACAO DANFE IBEX " + dTos( Date() ) + " - " + Time() )
    If _lJob
        EcLojM06A()
    Else
        _oProcess:= MsNewProcess():New( {|| EcLojM06A()},"Aguarde...","Validando Danfe IBEX" )
		_oProcess:Activate()
    EndIf
CoNout("<< EcLojM06A >> - FIM INTEGRACAO DANFE IBEX " + dTos( Date() ) + " - " + Time() )


//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< ECLOJM06 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return .T.

/******************************************************************************/
/*/{Protheus.doc} EcLojM06A
    @descrption Consulta Danfe e envia por e-mail
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
Static Function EcLojM06A()
Local _aArea        := GetArea()

Local _cAlias       := GetNextAlias()
Local _cPDFDanfe    := ""

Local _nToReg       := 0

Local _aPDFEtq		:= {}

Private _nTNota     := TamSX3("F2_DOC")[1]
Private _nTSerie    := TamSX3("F2_SERIE")[1]

//--------------------------------------+
// Consulta pedidos ecommerce faturados |
//--------------------------------------+
If !EcLojM06Qry(_cAlias,@_nToReg)
    CoNout("<< EcLojM06A >> - NAO EXISTEM ARQUIVOS PARA SEREM PROCESSADOS.")
    RestArea(_aArea)
    Return .F.
EndIf

//----------------------+
// Posiciona Orçamentos |
//----------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(1) )

//-----------------------+
// Posiciona nota fiscal | 
//-----------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

//---------------------------+
// Processa Danfe e-Commerce |
//---------------------------+
CoNout("<< EcLojM06A >> - INICIO GERA PDF DAS NOTAS.")
If !_lJob
    _oProcess:SetRegua1(_nToReg)
EndIf

While (_cAlias)->( !Eof() ) 

    //---------------------+
    // Posiciona Orçamento | 
    //---------------------+
    WSA->( dbgoTo((_cAlias)->RECNOWSA) )

    If !_lJob
        _oProcess:IncRegua1("DANFE " + RTrim(WSA->WSA_NUMECO) )
    EndIf    

    CoNout("<< EcLojM06A >> - GERANDO DANFE PEDIDO E-COMMERCE" + RTrim(WSA->WSA_NUMECO) )
    
    //---------------+
    // Envia Invoice |
    //---------------+
    U_AECOI013(WSA->WSA_NUMECO)
    
    //------------------+
    // Gera PDF da nota |
    //------------------+
    _cPDFDanfe	:= ""
    _aPDFEtq 	:= {}
    If EcLojM06B(WSA->WSA_DOC,WSA->WSA_SERIE,@_cPDFDanfe)
        //------------------+
        // Imprime etiqueta |
        //------------------+
        If !Empty(WSA->WSA_SERPOS)
            EcLojM06E(WSA->WSA_DOC,WSA->WSA_SERIE,@_aPDFEtq)
        EndIf
        //-------------------+
        // Envia e-Mail IBEX |
        //-------------------+
        If EcLojM06C(WSA->WSA_NUMECO,_cPDFDanfe,_aPDFEtq)
            RecLock("WSA",.F.)
                WSA->WSA_ENVLOG := "5"
            WSA->(MsUnLocK() )

            CoNout("<< EcLojM06A >> - EMAIL ENVIADO COM SUCESSO.")
        EndIf
    EndIf   
    (_cAlias)->( dbSkip() )
EndDo
CoNout("<< EcLojM06A >> - FIM GERA PDF DAS NOTAS.")

RestArea(_aArea)
Return Nil

/******************************************************************************/
/*/{Protheus.doc} EcLojM06B
    @descrption Gera PDF da nota
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
Static Function EcLojM06B(_cDoc,_cSerie,_cPDFDanfe)
Local _aArea    := GetArea()

//--------------------------------+
// Valida se nota foi posicionada |
//--------------------------------+
If !_lJob
    _oProcess:SetRegua2(-1)
EndIf

//---------------+
// Imprime DANFE | 
//---------------+
EcLojM06D(_cDoc,_cSerie,@_cPDFDanfe)

RestArea(_aArea)
Return .T. 

/******************************************************************************/
/*/{Protheus.doc} EcLojM06D
@description Realiza a impressão PDF da NF-e
@author Bernard M. Margarido
@since 22/01/2020
@version 1.0
@type function
/*/
/******************************************************************************/
Static Function EcLojM06D(_cDoc,_cSerie,_cPDFDanfe)
Local _cIdent       := GetIdEnt()
Local _cPasta       := _cDirRaiz
Local _cArqPDF      := ""
Local _cStatiCall   := ""

Local _lRet         := .T.
Local lEnd          := .F.
Local lExistNFe     := .F.

Local oDanfe    := Nil

If !Empty(_cIdent) .And. !Empty(_cDoc) .And. !Empty(_cSerie)
    CoNout("<< ECLOJM06D >> - ID ENT " + RTrim(_cIdent) )
    
    If !_lJob
        _oProcess:IncRegua2("PDF NF " + RTrim(_cDoc) + " / " + RTrim(_cSerie) )
    EndIf
    
    //------------------------------+
    // Define as perguntas da DANFE |
    //------------------------------+
    Pergunte("NFSIGW",.F.)
    MV_PAR01 := PadR(_cDoc,  _nTNota)       // 1. Nota Inicial
    MV_PAR02 := PadR(_cDoc,  _nTNota)       // 2. Nota Final
    MV_PAR03 := PadR(_cSerie,_nTSerie)      // 3. Série da Nota
    MV_PAR04 := 2                           // 4. NF de Saida/Entrada
    MV_PAR05 := 2                           // 5. Frente e Verso = Sim
    MV_PAR06 := 2                 

    //-----------------------+
    // Gera nome arquivo PDF |
    //-----------------------+
    _cPDFDanfe  := "DANFE_" + RTrim(_cDoc) + "_" + RTrim(_cSerie)

    //--------------------------+
    // Deleta arquivo existente |
    //--------------------------+
    If File(_cPasta + _cPDFDanfe + ".pdf")
		FErase(_cPasta + _cPDFDanfe + ".pdf")
	EndIf

    //------------------------------+
    // Chama rotina impressão Danfe |
    //------------------------------+
    oDanfe := FWMSPrinter():New(_cPDFDanfe, IMP_PDF, .F.,_cPasta, .T., , , , .T., , .F., ) 

    //-----------------------+         
    // Propriedades da DANFE |
    //-----------------------+
    oDanfe:SetResolution(78)
    oDanfe:SetPortrait()
    oDanfe:SetPaperSize(DMPAPER_A4)
    oDanfe:SetMargin(60, 60, 60, 60)

    //--------------------------+         
    // Força a impressão em PDF |
    //--------------------------+
    oDanfe:nDevice  := IMP_PDF
    oDanfe:cPathPDF := _cPasta
    oDanfe:lInJob  	:= .T.
    oDanfe:lServer  := .T.
    oDanfe:lViewPDF := .F.

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
    _cStatiCall := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
    Eval( {|| &(_cStatiCall + "("+"DANFEII,DanfeProc,@oDanfe, @lEnd, _cIdent, , , @lExistNFe)"+")") })

    //StaticCall(DANFEII, DanfeProc, @oDanfe, @lEnd, _cIdent, , , @lExistNFe)
    oDanfe:Print()

    If lExistNFe
        //--------------------------+
        // Renomeia nome do arquivo |
        //--------------------------+
        _cArqPDF  := _cPasta + _cPDFDanfe

        //-------------------------------+
        // Emula uso do TotvsPrinter.exe |
        //-------------------------------+
        File2Printer(_cArqPDF, "PDF" )
            
        If File(_cPasta + _cPDFDanfe + ".pdf")
            _lRet := .T.
            _cPDFDanfe := _cPDFDanfe + ".pdf"
            Conout("<< ECLOJM06D >> - ARQUIVO PDF " + _cPasta + _cPDFDanfe + " GERADO COM SUCESSO.")
        Else
            
            If File(_cArqPDF) 
                File2Printer(_cArqPDF, "PDF" )
            ElseIf File(_cArqPDF + ".rel")
                File2Printer(_cArqPDF, "PDF" )
            ElseIf File(_cArqPDF + ".pd_")
                File2Printer(_cArqPDF, "PDF" )
            EndIf
            
            If File(_cPasta + _cPDFDanfe + ".pdf")
                _lRet := .T.
                _cPDFDanfe := _cPDFDanfe + ".pdf"
                Conout("<< ECLOJM06D >> - ARQUIVO PDF " + _cPasta + _cPDFDanfe + " GERADO COM SUCESSO.")
            Else
                _lRet 		:= .F.
                _cPDFDanfe 	:= ""
                Conout("<< ECLOJM06D >> - NAO GEROU ARQUIVO DE NOTA FISCAL EM PDF  [" + _cPasta + _cPDFDanfe + "].")
            EndIf	
        EndIf
    //-------------------+    
    // Estorna PDF vazio |
    //-------------------+    
    Else
        _lRet   := .F.
        If File(_cPasta + _cPDFDanfe)
            FErase(_cPasta + _cPDFDanfe)
        ElseIf File(_cPasta + _cPDFDanfe + ".pdf")
            FErase(_cPasta + _cPDFDanfe + ".pdf")
        EndIf    
    EndIf    
EndIf

If ValType(oDanfe) == "O"
    FreeObj(oDanfe)
EndIf

Return _lRet 

/******************************************************************************/
/*/{Protheus.doc} EcLojM06E
@description Realiza a impressão PDF da Etiqueta
@author Bernard M. Margarido
@since 22/01/2020
@version 1.0
@type function
/*/
/******************************************************************************/
Static Function EcLojM06E(_cDoc,_cSerie,_aPDFEtq)
Local _cAlias			:= GetNextAlias()
Local _cPasta   		:= _cDirRaiz
Local _cCodEtq          := ""
Local _cPedido			:= ""
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
Local _cArqPDF          := ""
Local _cPDFEtq          := ""
Local _cStatiCall       := ""

Local _nVolume			:= 0
Local _nPeso			:= 0 
Local _nValor			:= 0

Local _lRet				:= .T.
Local _lAdjustToLegacy	:= .F.
Local _lDisableSetup	:= .T.

Local _oPrint			:= Nil

CoNout("<< ECLOJM06E >> - INICIA IMPRESSAO ETIQUETA " )

//-------------------+
// Consulta Etiqueta |
//-------------------+
EcLojM06EQry(_cAlias,_cDoc,_cSerie)


While (_cAlias)->( !Eof() .And. _lRet ) 

    //-----------------+
    // Volume etiqueta |
    //-----------------+
    _nVolume++

    //----------------------+
    // Cria nome do arquivo |
    //----------------------+
    _cPDFEtq	:= "ETQ_" + RTrim(_cDoc) + "_" + RTrim(_cSerie) + cValToChar(_nVolume)

    If !_lJob
        _oProcess:IncRegua2("PDF ETQ " + RTrim(_cDoc) + " / " + RTrim(_cSerie) + " " + (_cAlias)->ZZ4_CODETQ + " " + cValToChar(_nVolume) )
    EndIf

    //--------------------------+
    // Deleta arquivo existente |
    //--------------------------+
    If File(_cPasta + "/" + _cPDFEtq + ".pdf")
        FErase(_cPasta + "/" + _cPDFEtq + ".pdf")
    EndIf

    //------------------+
    // Instancia classe | 
    //------------------+
    _oPrint	:= FWMSPrinter():New(_cPDFEtq, IMP_PDF , _lAdjustToLegacy, _cPasta, _lDisableSetup, , , , .T., , .F., )

    //---------------------+
    // Configura Relatorio |
    //---------------------+
    _oPrint:setResolution(78)
    _oPrint:SetPortrait()
    _oPrint:setPaperSize(DMPAPER_A4)
    _oPrint:SetMargin(10,10,10,10)

    _oPrint:nDevice             := IMP_PDF
    _oPrint:cPathPdf 			:= _cPasta
    _oPrint:lInJob  	        := .T.
    _oPrint:lServer             := .T.
    _oPrint:lViewPDF            := .F.

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
    //_nVolume	:= (_cAlias)->C5_VOLUME1
    _nPeso		:= (_cAlias)->C5_PBRUTO * 100

    //-----------------------------------------+         
    // Chamando a impressão da danfe no RDMAKE |	        
    //-----------------------------------------+

    _cStatiCall := "S"+"t"+"a"+"t"+"i"+"c"+"C"+"a"+"l"+"l"
    Eval( {|| &(_cStatiCall + "("+"SIGR001,SigR01Etq,@_oPrint,_cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,_cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,_cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,_nValor,_nVolume,_nPeso)"+")") })
    /*
    StaticCall(SIGR001, SigR01Etq, 	@_oPrint, _cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,;
                                    _cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,;
                                    _cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,;
                                    _nValor,_nVolume,_nPeso)
    */
    _oPrint:Print()

    //--------------------------+
    // Renomeia nome do arquivo |
    //--------------------------+
    _cArqPDF  := _cPasta + "/" + _cPDFEtq 

    //-------------------------------+
    // Emula uso do TotvsPrinter.exe |
    //-------------------------------+
    File2Printer( _cArqPDF, "PDF" )
        
    If File(_cPasta + "/" + _cPDFEtq + ".pdf")
        _lRet := .T.
        _cPDFEtq := _cPDFEtq + ".pdf"
        Conout("<< ECLOJM06E >> - ARQUIVO PDF " + _cPasta + _cPDFEtq + " GERADO COM SUCESSO.")
    Else
        
        If File(_cArqPDF) 
            File2Printer(_cArqPDF, "PDF" )
        ElseIf File(_cArqPDF + ".rel")
            File2Printer(_cArqPDF, "PDF" )
        ElseIf File(_cArqPDF + ".pd_")
            File2Printer(_cArqPDF, "PDF" )
        EndIf
        
        If File(_cPasta + "/" + _cPDFEtq + ".pdf")
            _lRet := .T.
            _cPDFEtq := _cPDFEtq + ".pdf"
            Conout("<< ECLOJM06E >> - ARQUIVO PDF " + _cPasta + _cPDFEtq + " GERADO COM SUCESSO.")
        Else
            _lRet 		:= .F.
            _cPDFEtq 	:= ""
            Conout("<< ECLOJM06E >> - NAO GEROU ARQUIVO DE NOTA FISCAL EM PDF  [" + _cPasta + _cPDFEtq + "].")
        EndIf	
    EndIf

    If _lRet
        aAdd(_aPDFEtq,_cPDFEtq)
    EndIf

    (_cAlias)->( dbSkip() )
EndDo
//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

If ValType(_oPrint) == "O"
    FreeObj(_oPrint)
EndIf

CoNout("<< ECLOJM06E >> - FIM IMPRESSAO ETIQUETA " )
	
Return _lRet 

/******************************************************************************/
/*/{Protheus.doc} EcLojM06C
    @descrption Envia PDF da Danfe para IBEX
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
Static Function EcLojM06C(_cOrderID,_cPDFDanfe,_aPDFEtq)
Local _aArea    := GetArea()

Local _cCodInt  := "DNF"
Local _cDescInt := "INTEGRACAO DANFE IBEX"
Local _cPasta   := _cDirRaiz

Local _lRet     := .T.

Local _aMsgErro := {}

aAdd(_aMsgErro,{_cOrderID,"PDF DANFE " + _cPDFDanfe + " ENVIADO COM SUCESSO."})

_lRet := U_AEcoMail(_cCodInt,_cDescInt,_aMsgErro,_cPasta + _cPDFDanfe,_cPasta,_aPDFEtq)    

RestArea(_aArea)
Return _lRet

/******************************************************************************/
/*/{Protheus.doc} GetIdEnt
    @descrption Retorna IDENT empresa
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
Static Function GetIdEnt(_lUsaColab)
Local _cIdEnt := ""
Local _cError := ""

Default _lUsaColab := .F.

If !_lUsaColab
	_cIdEnt := getCfgEntidade(@_cError)
	If(empty(_cIdEnt))
		Conout("SPED - " + _cError)
	Endif
Else
	If !( ColCheckUpd() )
		Conout("SPED - UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0")
	Else
		_cIdEnt := "000000"
	Endif	 
EndIf	

Return _cIdEnt

/******************************************************************************/
/*/{Protheus.doc} EcLojM06Qry
    @descrption Consulta notas e-Commerce
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
Static Function EcLojM06Qry(_cAlias,_nToReg)
Local _cQuery   := ""
Local _cCodFat  := "006"

_cQuery := " SELECT " + CRLF
_cQuery += "	F2.F2_DOC, " + CRLF
_cQuery += "	F2.F2_SERIE, " + CRLF
_cQuery += "	F2.F2_CLIENTE, " + CRLF
_cQuery += "	F2.F2_LOJA, " + CRLF
_cQuery += "	WSA.R_E_C_N_O_ RECNOWSA " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WSA") + " WSA " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SF2") + " F2 ON F2.F2_FILIAL = WSA.WSA_FILIAL AND F2.F2_DOC = WSA.WSA_DOC AND F2.F2_SERIE = WSA.WSA_SERIE AND (F2.F2_CHVNFE <> '' OR F2.F2_FIMP = 'S') AND F2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "	WSA.WSA_DOC <> '' AND " + CRLF
_cQuery += "	WSA.WSA_SERIE <> '' AND " + CRLF
_cQuery += "	WSA.WSA_ENVLOG = '4' AND " + CRLF
_cQuery += "	WSA.WSA_CODSTA = '" + _cCodFat + "' AND " + CRLF 
_cQuery += "	WSA.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() ) 
   Return .F.
EndIf

Return .T.

/******************************************************************************/
/*/{Protheus.doc} EcLojM06EQry
@description Consulta Etiqueta a ser Impressa
@author Bernard M. Margarido
@since 22/01/2020
@version 1.0
@type function
/*/
/******************************************************************************/
Static Function EcLojM06EQry(_cAlias,_cDoc,_cSerie)
Local _cQuery	:= ""

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
_cQuery += "	INNER JOIN " + RetSqlName("ZZ4") + " ZZ4 ON ZZ4.ZZ4_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ4.ZZ4_CODIGO = ZZ2.ZZ2_CODIGO AND ZZ4.ZZ4_NOTA = '" + _cDoc + "' AND ZZ4.ZZ4_SERIE = '" + _cSerie + "' AND ZZ4.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("WSA") + " WSA ON WSA.WSA_FILIAL = ZZ4.ZZ4_FILIAL AND WSA.WSA_NUMECO = ZZ4.ZZ4_NUMECO AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("ZZ0") + " ZZ0 ON ZZ0.ZZ0_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ0.ZZ0_IDSER = ZZ4.ZZ4_CODSPO AND ZZ0.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = WSA.WSA_FILIAL AND SC5.C5_NUM = WSA.WSA_NUMSC5 AND SC5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZ2.ZZ2_FILIAL = '" + xFilial("ZZ2") + "' AND " + CRLF
_cQuery += "	ZZ2.ZZ2_STATUS = '04' AND " + CRLF
_cQuery += "	ZZ2.D_E_L_E_T_= '' " + CRLF
_cQuery += " ORDER BY ZZ2.ZZ2_CODIGO "
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->( Eof() )
	(_cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T. 
