#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICODE.CH"
//#INCLUDE "AUTODEF.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "APWIZARD.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/ibex"
Static _cDirArq     := "/danfe"

/******************************************************************************/
/*/{Protheus.doc} ECLOJM06
    @descrption JOB - Envio Danfe IBEX
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
User Function ECLOJM06(aParam)
Local _aArea        := GetArea()

Private _lJob       := IIF( ValType(aParam) == "A", .T., .F.)

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
	RpcSetEnv(aParam[1], aParam[2],,,'FAT')
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

    //------------------+
    // Gera PDF da nota |
    //------------------+
    If EcLojM06B(WSA->WSA_DOC,WSA->WSA_SERIE,@_cPDFDanfe)
        //-------------------+
        // Envia e-Mail IBEX |
        //-------------------+
        If EcLojM06C(WSA->WSA_NUMECO,_cPDFDanfe)
            RecLock("WSA",.F.)
                WSA->WSA_ENVLOG := "4"
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

Local _cIdent   := GetIdEnt()
Local _cPasta   := _cDirRaiz + _cDirArq
Local _cArqPDF  := ""

Local _lRet     := .T.
Local lEnd      := .F.
Local lExistNFe := .F.

Local oDanfe    := Nil

//--------------------------------+
// Valida se nota foi posicionada |
//--------------------------------+
If !_lJob
    _oProcess:SetRegua2(-1)
EndIf

If !Empty(_cIdent) .And. !Empty(_cDoc) .And. !Empty(_cSerie)
    CoNout("<< EcLojM06A >> - ID ENT " + RTrim(_cIdent) )

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
    _cPDFDanfe  := "DANFE_" + RTrim(_cDoc) + "_" + _cSerie 

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
    StaticCall(DANFEII, DanfeProc, @oDanfe, @lEnd, _cIdent, , , @lExistNFe)
    oDanfe:Print()

    If lExistNFe
        //--------------------------+
        // Renomeia nome do arquivo |
        //--------------------------+
        _cArqPDF  := _cPasta + _cPDFDanfe + ".PD_" 

        //-------------------------------+
        // Emula uso do TotvsPrinter.exe |
        //-------------------------------+
        File2Printer( _cPasta + _cArqPDF, "PDF" )
            
        If File(_cPasta + _cPDFDanfe + ".pdf")
            _lRet := .T.
            _cPDFDanfe := _cPDFDanfe + ".pdf"
            Conout("<< EcLojM06A >> - ARQUIVO PDF " + _cPasta + _cPDFDanfe + " GERADO COM SUCESSO.")
        Else
            
            If File(_cPasta + _cArqPDF) 
                File2Printer( _cPasta + _cArqPDF, "PDF" )
            ElseIf File(_cPasta + _cArqPDF + ".rel")
                File2Printer( _cPasta + _cArqPDF, "PDF" )
            ElseIf File(_cPasta + _cArqPDF + ".pd_")
                File2Printer( _cPasta + _cArqPDF, "PDF" )
            EndIf
            
            If File(_cPasta + _cPDFDanfe + ".pdf")
                _lRet := .T.
                _cPDFDanfe := _cPDFDanfe + ".pdf"
                Conout("<< EcLojM06A >> - ARQUIVO PDF " + _cPasta + _cPDFDanfe + " GERADO COM SUCESSO.")
            Else
                _lRet 		:= .F.
                _cPDFDanfe 	:= ""
                Conout("<< EcLojM06A >> - NAO GEROU ARQUIVO DE NOTA FISCAL EM PDF  [" + _cPasta + _cPDFDanfe + "].")
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

RestArea(_aArea)
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
Static Function EcLojM06C(_cOrderID,_cPDFDanfe)
Local _aArea    := GetArea()

Local _cCodInt  := "DNF"
Local _cDescInt := "INTEGRACAO DANFE IBEX"
Local _cPasta   := _cDirRaiz + _cDirArq

Local _lRet     := .T.

Local _aMsgErro := {}

aAdd(_aMsgErro,{_cOrderID,"PDF DANFE " + _cPDFDanfe + " ENVIADO COM SUCESSO."})

_lRet := U_AEcoMail(_cCodInt,_cDescInt,_aMsgErro,_cPasta + _cPDFDanfe)    

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
Local _cCodFat  := "005"

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
_cQuery += "	WSA.WSA_ENVLOG = '3' AND " + CRLF
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