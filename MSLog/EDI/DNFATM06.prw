#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/MsLog"
Static _cDirUpl     := "/upload"

/***************************************************************************************/
/*/{Protheus.doc} DNFATM06
    @description Realiza a criação do arquivo dos pedidos de venda Dana
    @type  Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
User Function DNFATM06(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _cArqLog    := ""

Private _lJob       := IIF(Empty(_cEmpInt) ,.F.,.T.)

Default _cEmpInt    := "01"
Default _cFilInt    := "07"
//------------------------+
// Envia notas para MSLog |
//------------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmpInt, _cFilInt,,,'FRT')
EndIf

//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)

_cArqLog := _cDirRaiz + "/" + "PEDIDO VENDA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA CRIACAO DOS ARQUIVOS MSLOG - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//------------------------------+
// Envia Pedidos de Venda MSLOG |
//------------------------------+
If _lJob
    DnFatM06A()
Else
    FwMsgRun(,{|_oSay| DnFatM06A(_oSay) },"Aguarde...","Gerando arquivo MSLog - Pedidos de Venda.")
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
/*/{Protheus.doc} DnFatM06A
    @description Cria arquivo contendo os pedidos de venda da Dana - MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
Static Function DnFatM06A(_oSay)
Local _aArea        := GetArea()

Local _cCnpjDep     := SM0->M0_CGC
Local _cAlias       := ""
Local _cLinCab      := ""
Local _cLinItem     := ""
Local _cLinArq      := ""
Local _cArqSC5      := ""
Local _cDirSC5      := ""
Local _cCnpj        := ""
Local _cInscr       := ""
Local _cNumero      := ""
Local _cCodBar      := ""
Local _cItem        := ""
Local _cLote        := ""
Local _cUF          := ""
            
Local _dDtLote      := ""

Local _nQtdNota     := 0
Local _nVlrUnit     := 0
Local _nHdl         := 0

Default _oSay       := Nil 

//--------------------------------------------------+
// Valida se existem novos pedidos a serem enviadas |
//--------------------------------------------------+
If !DnFatM06Qry(@_cAlias)
    LogExec("<< DNFATM06 >> - NAO EXISTEM PEDIDOS PARA SEREM GERADOS.")
    RestArea(_aArea)
    Return .F.
EndIf

//-----------------------+
// Cria diretorio Upload |
//-----------------------+
MakeDir(_cDirRaiz + _cDirUpl)

//----------------------+
// SF2 - Cabeçalho Nota | 
//----------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

//---------------------+
// SD2 - Itens da Nota | 
//---------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )

//----------------+
// SB1 - Produtos |
//----------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//---------------------------+
// Processa pedidos de venda |
//---------------------------+
While (_cAlias)->( !Eof() )

    //------------------+
    // Posiciona pedido |
    //------------------+
    SF2->( dbGoTo((_cAlias)->RECNOSF2) )

    //-----------------+
    // Dados cabeçalho |
    //-----------------+
    _cCnpj      := (_cAlias)->CNPJ_CLI
    _cInscr     := (_cAlias)->INSCR_CLI
    _cNota      := (_cAlias)->NOTA
    _cSerie     := (_cAlias)->SERIE
    _cRazao     := (_cAlias)->RAZAO
    _cMunicipio := (_cAlias)->MUNICIPIO
    _cUF        := (_cAlias)->ESTADO
    _cNumero    := (_cAlias)->PEDIDO
    

    //-----------------------+
    // Monta linha cabeçalho |
    //-----------------------+
    _cLinCab    :=  PadR(_cCnpj,14)     + ";"   // 01. CNPJ Cliente
    _cLinCab    +=  PadR(_cInscr,18)    + ";"   // 02. Inscrição Estadual Cliente
    _cLinCab    +=  PadR(_cNumero,9)    + ";"   // 03. Numero pedido
    _cLinCab    +=  PadR(_cNota  ,9)    + ";"   // 04. Numero da Nota
    _cLinCab    +=  PadR(_cRazao,40)    + ";"   // 05. Nome do Cliente
    _cLinCab    +=  PadR(_cMunicipio,35)+ ";"   // 06. Municipio
    _cLinCab    +=  PadR(_cUF,2)

    //-----------------+
    // Nome do arquivo |
    //-----------------+
    _cArqSC5    := "NFS_"  + _cCnpjDep + "_" + RTrim(_cNota) + ".TXT"

    //----------------------+
    // Diretorio do arquivo |
    //----------------------+
    _cDirSC5    := _cDirRaiz + _cDirUpl + "/" + _cArqSC5
    
    //--------------------------+
    // Deleta arquivo existente |
    //--------------------------+
    If File(_cDirSC5)
        FErase(_cDirSC5)
    EndIf

    //-----------------------+
    // Cria arquivo de Notas |
    //-----------------------+
    _nHdl := MsFCreate( _cDirSC5,,,.F.)
    If _nHdl <= 0 
        LogExec("<< DNFATM06 >> - ERRO AO CRIAR ARQUIVO " + _cDirSC5 + " .")
        (_cAlias)->( dbSkip() )
        Loop
    EndIf

    //---------------------------+
    // Dados cabeçalho do pedido |
    //---------------------------+
    If !_lJob
        _oSay:cCaption := "Pedido " + RTrim(_cNumero)
        ProcessMessages()
    EndIf
    
    LogExec("<< DNFATM06 >> CRIANDO ARQUIVO PEDIDO DE VENDA " + RTrim(_cNumero) + " ." )

    //-----------------+
    // Itens do Pedido |
    //-----------------+
    _cLinItem := ""
    If SD2->( dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE ) )
        While SD2->( !Eof() .And. xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE )

            //-------------------+
            // Posiciona Produto | 
            //-------------------+
            SB1->( dbSeek(xFilial("SB1") + SD2->D2_COD) )

            _cCodBar    := IIF(Empty(SB1->B1_CODBAR),SB1->B1_EAN,SB1->B1_CODBAR)
            _cItem      := SD2->D2_ITEM
            _nQtdNota   := cValToChar(SD2->D2_QUANT)
            _nVlrUnit   := cValToChar(SD2->D2_PRCVEN)
            _cLote      := SD2->D2_LOTECTL
            _dDtLote    := dToc(SD2->D2_DTVALID)

            //-----------------------+
            // Cria linha do arquivo |
            //-----------------------+
            _cLinItem += PadR(_cCodBar,15)  + ";"      // 01. Codigo de Barras 
            _cLinItem += PadR(_cItem,4)     + ";"      // 02. Item da Nota
            _cLinItem += PadR(_nQtdNota,12) + ";"      // 03. Quantidade Entrada
            _cLinItem += PadR(_nVlrUnit,12) + ";"      // 04. Valor Unitario 
            _cLinItem += PadR(_cLote,18)    + ";"      // 05. Lote
            _cLinItem += PadR(_dDtLote,8)              // 06. Data Validade do Lote
            _cLinItem += CRLF

            SD2->( dbSkip() )
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
    RecLock("SF2",.F.)
        SF2->F2_XENVWMS := "2"
        SF2->F2_XDTALT	:= Date()
        SF2->F2_XHRALT	:= Time()
    SF2->( MsUnLock() )
    
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
/*/{Protheus.doc} DnFatM06Qry
    @description Consulta notas a serem enviados para MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
Static Function DnFatM06Qry(_cAlias)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	A1.A1_CGC CNPJ_CLI, " + CRLF
_cQuery += "	A1.A1_INSCR INSCR_CLI, " + CRLF
_cQuery += "    A1.A1_NOME RAZAO, " + CRLF
_cQuery += "	A1.A1_MUN MUNICIPIO, " + CRLF
_cQuery += "	A1.A1_EST ESTADO, " + CRLF
_cQuery += "	F2.F2_DOC NOTA,  " + CRLF
_cQuery += "	F2.F2_SERIE SERIE, " + CRLF
_cQuery += "    ITENS_NOTA.D2_PEDIDO PEDIDO, " + CRLF
_cQuery += "	F2.R_E_C_N_O_ RECNOSF2 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SF2") + " F2 (NOLOCK) " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SA1") + " A1 (NOLOCK) ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "    CROSS APPLY( " + CRLF
_cQuery += "				SELECT " + CRLF
_cQuery += "					TOP 1 " + CRLF
_cQuery += "					D2.D2_PEDIDO " + CRLF
_cQuery += "				FROM " + CRLF
_cQuery += "					" + RetSqlName("SD2") + " D2 (NOLOCK) " + CRLF
_cQuery += "				WHERE " + CRLF
_cQuery += "					D2.D2_FILIAL = F2.F2_FILIAL AND " + CRLF
_cQuery += "					D2.D2_DOC = F2.F2_DOC AND " + CRLF
_cQuery += "					D2.D2_SERIE = F2.F2_SERIE AND " + CRLF
_cQuery += "					D2.D_E_L_E_T_ = '' " + CRLF
_cQuery += "    ) ITENS_NOTA " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	F2.F2_FILIAL = '" + xFilial("SF2") + "' AND " + CRLF
_cQuery += "	F2.F2_XENVWMS = '1' AND " + CRLF
_cQuery += "	F2.F2_TIPO IN('N','B') AND " + CRLF
_cQuery += "	F2.D_E_L_E_T_ = '' " + CRLF

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
