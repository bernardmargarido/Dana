#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/MsLog"
Static _cDirArq     := "/produto"
Static _cDirUpl     := "/upload"
Static _cDirDow     := "/download"

/***************************************************************************************/
/*/{Protheus.doc} DNFATM04
    @description Realiza a criação do arquivo dos produtos Dana
    @type  Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
User Function DNFATM04(_cEmp,_cFil)
Local _aArea        := GetArea()

Private _cArqLog    := ""

Private _lJob       := IIF(Empty(_cEmp) ,.F.,.T.)

//-------------------------+
// Envia pedidos para IBEX |
//-------------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmp, _cFil,,,'FRT')
EndIf


//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)
MakeDir(_cDirRaiz + _cDirArq)

_cArqLog := _cDirRaiz + _cDirArq + "/" + "PRODUTO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA CRIACAO DOS ARQUIVOS MSLOG - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//----------------------+
// Envia produtos MSLOG |
//----------------------+
If _lJob
    DnFatM04A()
Else
    FwMsgRun(,{|_oSay| DnFatM04A(_oSay) },"Aguarde...","Gerando arquivo MSLog - Produtos.")
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
/*/{Protheus.doc} DnFatM04A
    @description Cria arquivo contendo os produtos da Dana - MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
Static Function DnFatM04A(_oSay)
Local _aArea        := GetArea()

Local _cAlias       := ""
Local _cLinArq      := ""

Local _nTotItens    := 0

Local _dDtaArq      := Date()

Private _cArqSb1    := ""
Private _cArqLog    := ""
Private _cCnpjDep   := SM0->M0_CGC

Private _nHdlCab    := 0
Private _nHdlIt     := 0

//-----------------------------------------------------+
// Valida se existem novos pedidos para serem enviados |
//-----------------------------------------------------+
If !DnFatM04Qry(_cAlias)
    LogExec("<< DNFATM04 >> - NAO EXISTEM PEDIDOS PARA SEREM GERADOS.")
    RestArea(_aArea)
    Return .F.
EndIf

//-------------------------------------+
// Posiciona tabela de pedido de venda |
//-------------------------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//----------------------+
// Cria arquivo pedidos |
//----------------------+
_cArqSb1    := "PROD_"  + _cCnpjDep + ".INF"

//-----------------------+
// Cria diretorio Upload |
//-----------------------+
MakeDir(_cDirRaiz + _cDirArq + _cDirUpl)

//------------------+
// Processa pedidos |
//------------------+
If !_lJob
    ProcRegua(_nToReg)
EndIf

While (_cAlias)->( !Eof() )

    //------------------+
    // Posiciona pedido |
    //------------------+
    SB1->( dbGoTo((_cAlias)->RECNOSB1) )

    _cCodigo    := (_cAlias)->CODPROD
    _cCodBar    := (_cAlias)->CODBAR
    _cDescri    := (_cAlias)->DESCPROD
    _cUM_1      := (_cAlias)->UM_1
    _cUM_2      := (_cAlias)->UM_2
    _nFator     := (_cAlias)->FATOR
    _nAltura    := (_cAlias)->ALTURA
    _nLargura   := (_cAlias)->LARGURA
    _nCompri    := (_cAlias)->COMPRIMENTO
    _nAltCaixa  := (_cAlias)->ALTURA_CAIXA
    _nLargCaixa := (_cAlias)->LARGURA_CAIXA
    _nCompCaixa := (_cAlias)->COMPRIMENTO_CAIXA
    _nLastro    := (_cAlias)->LASTRO
    _nCamada    := (_cAlias)->CAMADA

    If !_lJob
        _oSay:cCaption := "Produto " + RTrim(_cCodigo) + " - " + RTrim(_cDescri)
        ProcessMessages()
    EndIf

    LogExec("<< DNFATM04 >> CRIANDO ARQUIVO PRODUTO " + RTrim(_cCodigo) + " - " + RTrim(_cDescri) + " ." )
    

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

RestArea(_aArea)
Return Nil 

/***************************************************************************************/
/*/{Protheus.doc} DnFatM04Qry
    @description Consulta produtos a serem enviados para MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 30/04/2021
/*/
/***************************************************************************************/
Static Function DnFatM04Qry(_cAlias)
Local _cQuery   := ""
Local _cTpProd  := FormatIn(GetNewPar("DN_TPPRDMS","MR"),"/")

_cQuery := " SELECT " + CRLF
_cQuery += "	B1.B1_COD, " + CRLF 
_cQuery += "	B1.B1_DESC, " + CRLF
_cQuery += "	B1.B1_CODBAR, " + CRLF
_cQuery += "	B1.B1_EAN, " + CRLF
_cQuery += "	B1.B1_UM, " + CRLF
_cQuery += "	B1.B1_SEGUM, " + CRLF
_cQuery += "	B1.B1_CONV " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SB1") + " B1 " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SB1") + " B5 ON B5.B5_FILIAL = B1.B1_FILIAL AND B5.B5_COD = B1.B1_COD AND B5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	B1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
_cQuery += "	B1.B1_TIPO IN '" + + "' AND " + CRLF
_cQuery += "	B1.B1_MSEXP = '' AND " + CRLF
_cQuery += "	B1.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.