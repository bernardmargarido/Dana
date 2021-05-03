#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/MsLog"
Static _cDirUpl     := "/upload"

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

//---------------------------+
// Envia produtos para MsLog |
//---------------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmp, _cFil,,,'FRT')
EndIf


//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)

_cArqLog := _cDirRaiz + "/" + "PRODUTO" + cEmpAnt + cFilAnt + ".LOG"
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
Local _cCodigo      := ""
Local _cCodBar      := ""
Local _cDescri      := ""
Local _cUM_1        := ""
Local _cUM_2        := ""
Local _cArqSb1      := ""
Local _cDirSB1      := ""
Local _cCnpjDep     := SM0->M0_CGC

Local _nFator       := 0
Local _nAltura      := 0
Local _nLargura     := 0
Local _nCompri      := 0
Local _nAltCaixa    := 0
Local _nLargCaixa   := 0
Local _nCompCaixa   := 0
Local _nLastro      := 0
Local _nCamada      := 0
Local _nHdl         := 0

Default _oSay       := Nil 
//-----------------------------------------------------+
// Valida se existem novos prodtos para serem enviados |
//-----------------------------------------------------+
If !DnFatM04Qry(@_cAlias)
    LogExec("<< DNFATM04 >> - NAO EXISTEM PRODUTOS PARA SEREM GERADOS.")
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
_cArqSb1    := "PROD_"  + _cCnpjDep + ".TXT"

//-----------------------+
// Cria diretorio Upload |
//-----------------------+
_cDirSB1    := _cDirRaiz + _cDirUpl + "/" + _cArqSb1
MakeDir(_cDirRaiz + _cDirUpl)

//--------------------------+
// Deleta arquivo existente |
//--------------------------+
If File(_cDirSB1)
   FErase(_cDirSB1)
EndIf

//--------------------------+
// Cria arquivo de Produtos |
//--------------------------+
_nHdl := MsFCreate( _cDirSB1,,,.F.)
If _nHdl <= 0 
    If !_lJob
        MsgStop("Erro ao criar arquivo do produto.")
    EndIf 
    LogExec("<< DNFATM04 >> - ERRO AO CRIAR ARQUIVO.")
    Return .F.
EndIf

//------------------+
// Processa produto |
//------------------+
While (_cAlias)->( !Eof() )

    //-------------------+
    // Posiciona produto |
    //-------------------+
    SB1->( dbGoTo((_cAlias)->RECNOSB1) )

    _cCodigo    := RTrim((_cAlias)->CODPROD)
    _cCodBar    := IIF(Empty((_cAlias)->CODBAR),RTrim((_cAlias)->CODEAN),RTrim((_cAlias)->CODBAR))
    _cDescri    := RTrim((_cAlias)->DESCPROD)
    _cUM_1      := RTrim((_cAlias)->UM_1)
    _cUM_2      := RTrim((_cAlias)->UM_2)
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

    LogExec("<< DNFATM04 >> - CRIANDO ARQUIVO PRODUTO " + RTrim(_cCodigo) + " - " + RTrim(_cDescri) + " ." )

    //-----------------------+
    // Cria linha do arquivo |
    //-----------------------+
    _cLinArq := PadR(_cCodigo,15)                   + ";"     // 01. Codigo do Produto 
    _cLinArq += PadR(_cCodBar,15)                   + ";"     // 02. Codigo de Barras 
    _cLinArq += PadR(_cDescri,40)                   + ";"     // 03. Descrição
    _cLinArq += PadR(_cUM_1,3)                      + ";"     // 04. 1ª Unidade
    _cLinArq += PadR(_cUM_2,3)                      + ";"     // 05. 2ª Unidade
    _cLinArq += PadR(cValToChar(_nFator),3)         + ";"     // 06. Fator Conversão 
    _cLinArq += PadR(cValToChar(_nAltura),11)       + ";"     // 07. Altura Embalagem 
    _cLinArq += PadR(cValToChar(_nLargura),11)      + ";"     // 08. Largura Embalagem 
    _cLinArq += PadR(cValToChar(_nCompri),11)       + ";"     // 09. Comprimento Embalagem 
    _cLinArq += PadR(cValToChar(_nAltCaixa),11)     + ";"     // 10. Altura Caixa
    _cLinArq += PadR(cValToChar(_nLargCaixa),11)    + ";"     // 11. Lagura Caixa
    _cLinArq += PadR(cValToChar(_nCompCaixa),11)    + ";"     // 12. Comprimento Caixa
    _cLinArq += PadR(cValToChar(_nLastro),3)        + ";"     // 13. Lastro
    _cLinArq += PadR(cValToChar(_nCamada),3)                  // 14. Camada
    _cLinArq += CRLF

    //--------------------------------------+
    // Retira produto da fila de integração |
    //--------------------------------------+
    RecLock("SB1",.F.)
        SB1->B1_MSEXP := dTos(Date())
    SB1->( MsUnLock() )
    
    //------------------------+
    // Grava linha do arquivo |
    //------------------------+
    FWrite(_nHdl, _cLinArq)

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
_cQuery += "	B1.B1_COD CODPROD, " + CRLF 
_cQuery += "	B1.B1_DESC DESCPROD, " + CRLF
_cQuery += "	B1.B1_CODBAR CODBAR, " + CRLF
_cQuery += "	B1.B1_EAN CODEAN, " + CRLF
_cQuery += "	B1.B1_UM UM_1, " + CRLF
_cQuery += "	B1.B1_SEGUM UM_2, " + CRLF
_cQuery += "	B1.B1_CONV FATOR, " + CRLF
_cQuery += "    B5.B5_COMPR COMPRIMENTO, " + CRLF
_cQuery += "	B5.B5_LARG LARGURA, " + CRLF
_cQuery += "	B5.B5_ALTURA ALTURA, " + CRLF
_cQuery += "	B5.B5_FATARMA LASTRO, " + CRLF
_cQuery += "	B5.B5_EMPMAX CAMADA, " + CRLF
_cQuery += "	B5.B5_COMPRLC COMPRIMENTO_CAIXA, " + CRLF
_cQuery += "	B5.B5_LARGLC LARGURA_CAIXA, " + CRLF
_cQuery += "	B5.B5_ALTURLC ALTURA_CAIXA, " + CRLF
_cQuery += "	B1.R_E_C_N_O_ RECNOSB1 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SB1") + " B1 " + CRLF
_cQuery += "	LEFT JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_FILIAL = B1.B1_FILIAL AND B5.B5_COD = B1.B1_COD AND B5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	B1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
_cQuery += "	B1.B1_TIPO IN " + _cTpProd + " AND " + CRLF
_cQuery += "	B1.B1_MSEXP = '' AND " + CRLF
_cQuery += "	B1.D_E_L_E_T_ = '' "

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
