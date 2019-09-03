#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/ibex"
Static _cDirArq     := "/pedido"
Static _cDirUpl     := "/upload"
Static _cDirDow     := "/download"

/**********************************************************************/
/*/{Protheus.doc} IBFATM01
    @description Cria arquivo pedido de venda
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
User Function IBFATM01(_cEmpEco,_cFilEco)
Local _aArea        := GetArea()

Local _cAlias       := GetNextAlias()
Local _cTimeArq     := Time()

Local _nToReg       := 0

Local _dDtaArq      := Date()

Private _cArqSc5    := ""
Private _cArqSc6    := ""
Private _cArqLog    := ""

Private _nHdlCab    := 0
Private _nHdlIt     := 0

Private _lJob       := IIF(Empty(_cEmpEco),.F.,.T.)

Default _cEmpEco    := ""
Default _cFilEco    := ""

//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)
MakeDir(_cDirRaiz + _cDirArq)

_cArqLog := _cDirRaiz + _cDirArq + "/" + "PEDIDOVENDA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA CRIACAO DOS ARQUIVOS PEDIDOS IBEX - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-----------------------------------------------------+
// Valida se existem novos pedidos para serem enviados |
//-----------------------------------------------------+
If !IBFatMQry(_cAlias,@_nToReg)
    (_cAlias)->( dbCloseArea() )
    LogExec("NAO EXISTEM PEDIDOS PARA SEREM GERADOS.")
    RestArea(_aArea)
    Return .F.
EndIf

//-------------------------------------+
// Posiciona tabela de pedido de venda |
//-------------------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//----------------------+
// Cria arquivo pedidos |
//----------------------+
_cArqSc5    := "PEDIDO_CAB_"  + StrZero( Day( _dDtaArq ),2,0) + "_" + StrZero( Month( _dDtaArq),2,0) + "_" + StrZero( Year( _dDtaArq),4,0) + "_" + Left(_cTimeArq,2) + "_" + SubStr(_cTimeArq,4,2) + "_" + Right(_cTimeArq,2) + ".TXT"
_cArqSc6    := "PEDIDO_ITEM_" + StrZero( Day( _dDtaArq ),2,0) + "_" + StrZero( Month( _dDtaArq),2,0) + "_" + StrZero( Year( _dDtaArq),4,0) + "_" + Left(_cTimeArq,2) + "_" + SubStr(_cTimeArq,4,2) + "_" + Right(_cTimeArq,2) + ".TXT"

//-----------------------+
// Cria diretorio Upload |
//-----------------------+
MakeDir(_cDirRaiz + _cDirArq + _cDirUpl)

//------------------+
// Processa pedidos |
//------------------+
While (_cAlias)->( !Eof() )
    //------------------+
    // Posiciona pedido |
    //------------------+
    SC5->( dbGoTo((_cAlias)->RECNOSC5) )

    LogExec("<===> CRIANDO ARQUIVO PEDIDO " + SC5->C5_NUM + " ." )

    //---------------------------+
    // Gera arquivo do cabeçalho | 
    //---------------------------+
    If IBFatM01Cab()
        //------------------------+
        // Gera arquivo dos itens | 
        //------------------------+
        IBFatM01It()
    EndIf    
    (_cAlias)->( dbSkip() )
EndDo

//---------------+
// Fecha Arquivo |
//---------------+
FClose(_nHdlCab)
FClose(_nHdlIt)

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

LogExec("FINALIZA CRIACAO DOS ARQUIVOS PEDIDOS IBEX - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
ConOut("")

RestArea(_aArea)
Return Nil

/**********************************************************************/
/*/{Protheus.doc} IBFatM01Cab
    @description Gera arquivo com o cabeçalho dos itens
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
Static Function IBFatM01Cab()
Local _cDirSC5  := _cDirRaiz + _cDirArq + _cDirUpl + "/" + _cArqSc5
Local _cLinArq  := ""

//--------------------------+
// Valida se existe arquivo |
//--------------------------+
If !File(_cDirSC5)
    _nHdlCab := MsFCreate( _cDirSC5,,,.F.)
    If _nHdlCab <= 0 
        LogExec("ERRO AO CRIAR ARQUIVO.")
        Return .F.
    EndIf
EndIf

//--------------+
// Gera arquivo | 
//--------------+
_cLinArq := "3"                         // 001. Tipo de Arquivo
_cLinArq += PadR(SC5->C5_NUM,20)        // 002. codigo interno 
_cLinArq += PadR(SC5->C5_NUM,20)        // 003. Numero Pedido
_cLinArq += CRLF    

FWrite(_nHdlCab, _cLinArq)

Return .T.

/**********************************************************************/
/*/{Protheus.doc} IBFatM01It
    @description Gera arquivo dos itens do pedido
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
Static Function IBFatM01It()
Local _cDirSC6  := _cDirRaiz + _cDirArq + _cDirUpl + "/" + _cArqSc6
Local _cLinArq  := ""

//--------------------------+
// Valida se existe arquivo |
//--------------------------+
If !File(_cDirSC6)
    _nHdlIt := MsFCreate( _cDirSC6,,,.F.)
    If _nHdlIt <= 0 
        LogExec("ERRO AO CRIAR ARQUIVO.")
        Return .F.
    EndIf
EndIf

//---------------------------+
// Posiciona Itens do Pedido |
//---------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If !SC6->( dbSeek(xFilial("SC6") + SC5->C5_NUM) )
    LogExec("ITENS DO PEDIDO " + SC5->C5_NUM + " NAO LOCALIZADO.")
    Return .F.
EndIf

While SC6->( !Eof() .And. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM )
    //--------------+
    // Gera arquivo | 
    //--------------+
    _cLinArq := "4"                         // 001. Tipo de Arquivo
    _cLinArq += PadR(SC5->C5_NUM,20)        // 002. codigo interno 
    _cLinArq += PadR(SC5->C5_NUM,20)        // 003. Numero Pedido
    _cLinArq += CRLF

    SC6->( dbSkip() )

EndDo    

FWrite(_nHdlIt, _cLinArq)

Return .T.

/**********************************************************************/
/*/{Protheus.doc} IBFatMQry
    @description Consulta pedidos para serem ennviados
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
Static Function IBFatMQry(_cAlias,_nToReg)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	C5.C5_FILIAL, " + CRLF
_cQuery += "	C5.C5_NUM, " + CRLF
_cQuery += "	C5.R_E_C_N_O_ RECNOSC5 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WSA") + " WSA " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("SL1") + " L1 ON L1.L1_FILIAL = WSA.WSA_FILIAL AND L1.L1_FILRES = WSA.WSA_FILIAL AND L1.L1_ORCRES = WSA.WSA_NUMSL1 AND L1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " C5 ON C5.C5_FILIAL = WSA.WSA_FILIAL AND C5.C5_NUM = L1.L1_PEDRES AND C5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF 
_cQuery += "	WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY C5.C5_FILIAL,C5.C5_NUM "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->( Eof() )
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