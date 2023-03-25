#INCLUDE "PROTHEUS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*******************************************************************************************************/
/*/{Protheus.doc} ECLOJM09
    @description Transmissão automatica de notas e-Commerce
    @type  Function
    @author Bernard M. Margarido
    @since 20/08/2021
/*/
/*******************************************************************************************************/
User Function ECLOJM09()
Local _aArea        := GetArea()

CoNout("<< ECLOJM09 >> - INICIA TRANSMISSAO/MONITORAMENTO DAS NOTAS ECOMMERCE DATA " + dToC(Date()) + " Hora " + Left(Time(),5) )

//-----------------------------------------+
// Realiza a transmissao das notas fiscais |
//-----------------------------------------+
CoNout("<< ECLOJM09 >> - INICIA TRANSMISSAO DAS NOTAS ECOMMERCE DATA " + dToC(Date()) + " Hora " + Left(Time(),5) )
EcLojM09A()
CoNout("<< ECLOJM09 >> - FINALIZA TRANSMISSAO DAS NOTAS ECOMMERCE DATA " + dToC(Date()) + " Hora " + Left(Time(),5) )

//------------------------+
// Aguardando transmissao |
//------------------------+
Sleep(25000)

//---------------------------------+
// Monitoramento das notas fiscais |
//---------------------------------+
CoNout("<< ECLOJM09 >> - INICIA MONITORAMENTO DAS NOTAS ECOMMERCE DATA " + dToC(Date()) + " Hora " + Left(Time(),5) )
EcLojM09B()
CoNout("<< ECLOJM09 >> - FINALIZA MONITORAMENTO DAS NOTAS ECOMMERCE DATA " + dToC(Date()) + " Hora " + Left(Time(),5) )


CoNout("<< ECLOJM09 >> - FIM TRANSMISSAO/MONITORAMENTO DAS NOTAS ECOMMERCE DATA " + dToC(Date()) + " Hora " + Left(Time(),5) )

RestArea(_aArea)
Return Nil 

/*******************************************************************************************************/
/*/{Protheus.doc} EcLojM09A
    @description Realiza a transmissao das notas eCommerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 20/08/2021
/*/
/*******************************************************************************************************/
Static Function EcLojM09A()
Local _cAlias       := ""

//---------------------------------------+
// Consulta notas na fila de transmissão |
//---------------------------------------+
If !EcLojM09C(@_cAlias)
    CoNout("<< ECLOJM09 >> - NAO EXISTEM NOTAS A SEREM TRANSMITIDAS.")
    Return .F.
EndIf 

While (_cAlias)->( !Eof() ) 
    CoNout("<< ECLOJM09 >> - TRANSMITINDO NOTA " + RTrim((_cAlias)->XTE_DOC) + " SERIE " + RTrim((_cAlias)->XTE_SERIE) + " DATA " + dToC(Date()) + " HORA " + Left(Time(),5) + " .")
    EcLojM09D((_cAlias)->XTE_SERIE,(_cAlias)->XTE_DOC)
    (_cAlias)->( dbSkip() ) 
EndDo 

Return Nil 

/*******************************************************************************************************/
/*/{Protheus.doc} EcLojM09B
    @description Realiza o monitoramento das notas transmitidas
    @type  Static Function
    @author Bernard M Margarido
    @since 21/03/2023
    @version version
/*/
/*******************************************************************************************************/
Static Function EcLojM09B()
Local _cAlias   := ""
Local _cAviso   := ""
Local _cUrl	    := Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local _cIdEnt   := RetIdEnti()	

Local _aRetorno := {}

If !EcLojM09C(@_cAlias)
    Return .F.
EndIf 

dbSelectArea("XTE")
XTE->( dbSetOrder(1) )

_cUrl   := Padr( GetNewPar("MV_SPEDURL",""), 250 )
_cIdEnt := RetIdEnti()	

While (_cAlias)->( !Eof() )
    
    //-------------------------------------+
    // Posiciona registro de monitoramento |
    //-------------------------------------+
    XTE->( dbGoTo((_cAlias)->RECNOXTE) )
    
    CoNout("<< ECLOJM09 >> - VALIDANDO TRANSMICAO NOTA " + RTrim(XTE->XTE_DOC) + " SERIE " + RTrim(XTE->XTE_SERIE) + " DATA " + dToC(Date()) + " HORA " + Left(Time(),5) + " .")

    dbSelectArea("SX6")
    _aRetorno := {}
    _aRetorno := procMonitorDoc(_cIdEnt, _cUrl, {XTE->XTE_SERIE,XTE->XTE_DOC,XTE->XTE_DOC}, 1, Nil, .F., @_cAviso)
    
    If Len(_aRetorno) > 0 
        RecLock("XTE",.F.)
            XTE->XTE_DATA   := FWTimeStamp(3,Date())
            XTE->XTE_STATUS := "2"
        XTE->( MsUnLock() )
    Else 
        CoNout("<< ECLOJM09 >> - ERRO MONITORAMENTO " + RTrim(_cAviso) + ".")
    EndIf 

    (_cAlias)->( dbSkip() )

EndDo 

(_cAlias)->( dbCloseArea() )

Return Nil 

/*******************************************************************************************************/
/*/{Protheus.doc} EcLojM09C
    @description Consulta link de rastreio 
    @type  Static Function
    @author Bernard M. Margarido 
    @since 20/08/2021
/*/
/*******************************************************************************************************/
Static Function EcLojM09C(_cAlias)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	XTE.XTE_DOC, " + CRLF
_cQuery += "	XTE.XTE_SERIE, " + CRLF
_cQuery += "	XTE.R_E_C_N_O_ RECNOXTE " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("XTE") + " XTE (NOLOCK) " + CRLF
_cQuery += "    LEFT JOIN " + RetSqlName("SF3") + " F3 (NOLOCK) ON F3.F3_FILIAL = XTE.XTE_FILIAL AND F3.F3_NFISCAL = XTE.XTE_DOC AND F3.F3_SERIE = XTE.XTE_SERIE AND F3_ESPECIE = 'SPED' AND F3_CHVNFE = '' AND F3_OBSERV <> 'NF INUTILIZADA' AND F3.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	XTE.XTE_FILIAL = '" + xFilial("XTE") + "' AND " + CRLF
_cQuery += "	XTE.XTE_STATUS = '1' AND " + CRLF
_cQuery += "	XTE.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/*******************************************************************************************************/
/*/{Protheus.doc} EcLojM09D
    @description Realiza a transmissão automatica das notas eCommerce
    @type  Static Function
    @author Bernard M Margarido
    @since 22/03/2023
    @version version
/*/
/*******************************************************************************************************/
Static Function EcLojM09D(_cSerie,_cDoc)
Local _cOpc	        := '1'		// 1 - Transmissao, 2 - Monitoramento, 3 - Cancelamento
Local cIdEnt        := ""
Local cNotaIni      := ""
Local cNotaFim      := ""
Local cAmbiente     := ""
Local cError        := ""
Local cModelo       := ""
Local cModalidade   := ""
Local cVersao       := ""
Local cSerie        := ""

Local lOk           := .F.
Local lEnd          := .F.
Local lCte          := .F.

cIdEnt := RetIdEnti()	

If !Empty( cIdEnt )

    cNotaIni := _cDoc
    cNotaFim := _cDoc
    cSerie   := _cSerie

    cAmbiente := getCfgAmbiente(@cError, cIdEnt, cModelo)

    If( !Empty(cAmbiente))

        cModalidade := getCfgModalidade(@cError, cIdEnt, cModelo)

        If( !Empty(cModalidade) )
            cVersao	:= getCfgVersao(@cError, cIdEnt, cModelo) 

            lOk := !Empty(cVersao)

        EndIf 
    EndIf 

    If( lOk )
        cRetorno := SpedNFeTrf("SF2",cSerie,cNotaIni,cNotaFim,cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd,lCte,.T.,nil,nil)
        CoNout("<< ECLOJM09 >> - RETORNO: " + cRetorno)
    Else

        If !Empty( cError )
            CoNout("<< ECLOJM09 >> - ERRO NO PROCESSO DE " + getProcName(_cOpc ) + " - " + cError)
        EndIf

    EndIf

EndIf

Return Nil
