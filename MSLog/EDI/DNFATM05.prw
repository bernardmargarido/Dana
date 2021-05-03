#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/MsLog"
Static _cDirUpl     := "/upload"

/***************************************************************************************/
/*/{Protheus.doc} DNFATM05
    @description Realiza a criação do arquivo das notas de entrada Dana
    @type  Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
User Function DNFATM05(_cEmp,_cFil)
Local _aArea        := GetArea()

Private _cArqLog    := ""

Private _lJob       := IIF(Empty(_cEmp) ,.F.,.T.)

//------------------------+
// Envia notas para MSLog |
//------------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmp, _cFil,,,'FRT')
EndIf


//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)

_cArqLog := _cDirRaiz + "/" + "NOTA ENTRADA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA CRIACAO DOS ARQUIVOS MSLOG - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//------------------------------+
// Envia Notas de Entrada MSLOG |
//------------------------------+
If _lJob
    DnFatM05A()
Else
    FwMsgRun(,{|_oSay| DnFatM05A(_oSay) },"Aguarde...","Gerando arquivo MSLog - Notas de Entrada.")
EndIf

LogExec("FINALIZA CRIACAO DOS ARQUIVOS MSLOG - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
ConOut("")

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

RestArea(_aArea)
Return Nil 

/***************************************************************************************/
/*/{Protheus.doc} DnFatM05A
    @description Cria arquivo contendo as notas de entrada da Dana - MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
Static Function DnFatM05A(_oSay)
Local _aArea        := GetArea()

Local _cCnpjDep     := SM0->M0_CGC
Local _cAlias       := ""
Local _cLinCab      := ""
Local _cLinItem     := ""
Local _cLinArq      := ""
Local _cArqSF1      := ""
Local _cDirSF1      := ""
Local _cCnpj        := ""
Local _cInscr       := ""
Local _cDoc         := ""
Local _cSerie       := ""
Local _cChaveNfe    := ""
Local _cCodBar      := ""
Local _cItem        := ""
Local _cLote        := ""
            
Local _dDtLote      := ""
Local _dDtEmiss     := ""

Local _nQtdNota     := 0
Local _nVlrUnit     := 0
Local _nHdl         := 0

Default _oSay       := Nil 

//------------------------------------------------+
// Valida se existem novas notas a serem enviadas |
//------------------------------------------------+
If !DnFatM05Qry(@_cAlias)
    LogExec("<< DNFATM05 >> - NAO EXISTEM NOTAS DE ENTRADA PARA SEREM GERADOS.")
    RestArea(_aArea)
    Return .F.
EndIf

//-----------------------+
// Cria diretorio Upload |
//-----------------------+
MakeDir(_cDirRaiz + _cDirUpl)

//---------------------+
// SD1 - Itens da Nota | 
//---------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )

//----------------+
// SB1 - Produtos |
//----------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//---------------------------+
// Processa notas de entrada |
//---------------------------+
While (_cAlias)->( !Eof() )

    //-------------------+
    // Posiciona produto |
    //-------------------+
    SF1->( dbGoTo((_cAlias)->RECNOSF1) )

    //-----------------+
    // Dados cabeçalho |
    //-----------------+
    _cCnpj      := (_cAlias)->CNPJ_FOR
    _cInscr     := (_cAlias)->INSCR_FOR
    _cDoc       := (_cAlias)->DOCUMENTO
    _cSerie     := (_cAlias)->SERIE
    _dDtEmiss   := dToC(sTod((_cAlias)->DT_DIGITACAO))
    _cChaveNfe  := (_cAlias)->CHAVE_NFE
    
    //-----------------------+
    // Monta linha cabeçalho |
    //-----------------------+
    _cLinCab    :=  PadR(_cCnpj,14)     + ";"   // 01. CNPJ Fornecedor
    _cLinCab    +=  PadR(_cInscr,18)    + ";"   // 02. Inscrição Estadual Fornecedor
    _cLinCab    +=  PadR(_cDoc,9)       + ";"   // 03. Numero nota de entrada 
    _cLinCab    +=  PadR(_cSerie,3)     + ";"   // 04. Serie nota de entrada 
    _cLinCab    +=  PadR(_dDtEmiss,8)   + ";"   // 05. Data emissao da nota
    _cLinCab    +=  PadR(_cChaveNfe,44)         // 06. Chave Nota Fiscal 

    //-----------------+
    // Nome do arquivo |
    //-----------------+
    _cArqSF1    := "NFE_"  + _cCnpjDep + "_" + RTrim(_cDoc) + RTrim(_cSerie) + ".TXT"

    //----------------------+
    // Diretorio do arquivo |
    //----------------------+
    _cDirSF1    := _cDirRaiz + _cDirUpl + "/" + _cArqSF1
    
    //--------------------------+
    // Deleta arquivo existente |
    //--------------------------+
    If File(_cDirSF1)
        FErase(_cDirSF1)
    EndIf

    //-----------------------+
    // Cria arquivo de Notas |
    //-----------------------+
    _nHdl := MsFCreate( _cDirSF1,,,.F.)
    If _nHdl <= 0 
        LogExec("<< DNFATM05 >> - ERRO AO CRIAR ARQUIVO " + _cArqSF1 + " .")
        (_cAlias)->( dbSkip() )
        Loop
    EndIf

    //-------------------------+
    // Dados cabeçalho da nota |
    //-------------------------+
    If !_lJob
        _oSay:cCaption := "Nota " + RTrim(_cDoc) + " - " + RTrim(_cSerie)
        ProcessMessages()
    EndIf
    
    LogExec("<< DNFATM05 >> CRIANDO ARQUIVO NOTA DE ENTRADA " + RTrim(_cDoc) + " - " + RTrim(_cSerie) + " ." )

    //--------------------------+
    // Itens da Nota de Entrada |
    //--------------------------+
    _cLinItem := ""
    If SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
        While SD1->( !Eof() .And. xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA)

            //-------------------+
            // Posiciona Produto | 
            //-------------------+
            SB1->( dbSeek(xFilial("SB1") + SD1->D1_COD) )

            _cCodBar    := IIF(Empty(SB1->B1_CODBAR),SB1->B1_EAN,SB1->B1_CODBAR)
            _cItem      := SD1->D1_ITEM
            _nQtdNota   := cValToChar(SD1->D1_QUANT)
            _nVlrUnit   := cValToChar(SD1->D1_VUNIT)
            _cLote      := SD1->D1_LOTECTL
            _dDtLote    := dToc(SD1->D1_DTVALID)

            //-----------------------+
            // Cria linha do arquivo |
            //-----------------------+
            _cLinItem += PadR(_cCodBar,15)  + ";"      // 01. Codigo de Barras 
            _cLinItem += PadR(_cItem,4)     + ";"      // 02. Item da Nota
            _cLinItem += PadR(_nQtdNota,12) + ";"      // 03. Quantidade Entrada
            _cLinItem += PadR(_nVlrUnit,12) + ";"      // 04. Valor Unitario 
            _cLinItem += PadR(_cLote,18)    + ";"      // 05. Lote
            _cLinItem += PadR(_dDtLote,8)             // 06. Data Validade do Lote
            _cLinItem += CRLF

            SD1->( dbSkip() )
        EndDo
    EndIf
    
    //------------------------+
    // Grava linha do arquivo |
    //------------------------+
    _cLinArq    := _cLinCab + CRLF 
    _cLinArq    += _cLinItem

    FWrite(_nHdl, _cLinArq)

    //---------------+
    // Fecha Arquivo |
    //---------------+
    FClose(_nHdl)

    //-----------------------------------+
    // Retira nota da fila de integração | 
    //-----------------------------------+
    RecLock("SF1",.F.)
        SF1->F1_MSEXP := dTos(Date())
    SF1->( MsUnLock() )
    
    (_cAlias)->( dbSkip() )
EndDo

//---------------+
// Fecha Arquivo |
//---------------+
FClose(_nHdl)

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return Nil 

/***************************************************************************************/
/*/{Protheus.doc} DnFatM05Qry
    @description Consulta notas a serem enviados para MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
Static Function DnFatM05Qry(_cAlias)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	A2.A2_CGC CNPJ_FOR, " + CRLF
_cQuery += "	A2.A2_INSCR INSCR_FOR, " + CRLF
_cQuery += "	F1.F1_DOC DOCUMENTO, " + CRLF
_cQuery += "	F1.F1_SERIE SERIE, " + CRLF
_cQuery += "	F1.F1_DTDIGIT DT_DIGITACAO, " + CRLF
_cQuery += "	F1.F1_CHVNFE CHAVE_NFE, " + CRLF
_cQuery += "	F1.R_E_C_N_O_ RECNOSF1 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SF1") + " F1 " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SA2") + " A2 ON A2.A2_FILIAL = F1.F1_FILIAL AND A2.A2_COD = F1.F1_FORNECE AND A2.A2_LOJA = F1.F1_LOJA AND A2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	F1.F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
_cQuery += "	F1.F1_CHVNFE <> '' AND " + CRLF
_cQuery += "	F1.F1_TIPO IN('N','D') AND " + CRLF
_cQuery += "	F1.F1_MSEXP = '' AND " + CRLF
_cQuery += "	F1.D_E_L_E_T_ = '' " + CRLF

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.

/*******************************************************************************************/
/*/{Protheus.doc} LogExec
	@description Grava log 
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(_cArqLog,cMsg)
Return 
