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
Private _cCnpjDep   := "99.999.999/9999-99"
Private _cCnpjEmi   := "99.999.999/9999-99"

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
Static Function IBFatM01Cab(_cCodTes,_nVlrProd)
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

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )

//--------------------------+
// Posiciona Transportadora |
//--------------------------+
dbSelectArea("SA4")
SA4->( dbSetOrder(1) )
SA4->( dbSeek(xFilial("SA4") + SC5->C5_TRANSP) )

//---------------+
// Posiciona TES |
//---------------+
dbSelectArea("SF4")
SF4->( dbSetOrder(1) )
SF4->( dbSeek(xFilial("SF4") + _cCodTes) )

//----------------------+
// Variaveis do arquivo |
//----------------------+
_cNumPv     := SC5->C5_NUM
_cDescOp    := SF4->F4_TEXTO
_cCfop      := SF4->F4_CF
_cPessoa    := SA1->A1_PESSOA
_cCodCli    := RTrim(SA1->A1_COD) + RTrim(SA1->A1_LOJA)
_cNome      := RTrim(SA1->A1_NOME)
_cFantasia  := RTrim(SA1->A1_NREDUZ)
_cCNPJDest  := RTrim(IIF(SA1->A1_PESSOA == "J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99")))
_cEndDest   := RTrim(SubStr(SA1->A1_END,1,At(",",SA1->A1_END) - 1))
_cNumDest   := RTrim(SubStr(SA1->A1_END,At(",",SA1->A1_END) + 1))
_cEndEnt    := RTrim(SA1->A1_END)
_cComplem   := RTrim(SA1->A1_COMPLEM)
_cBairDest  := RTrim(SA1->A1_BAIRRO)
_cCepDest   := RTrim(SA1->A1_CEP)
_cMunDest   := RTrim(SA1->A1_MUN)
_cTelDest   := RTrim(SA1->A1_DDD) + RTrim(SA1->A1_TEL)
_cEstDest   := RTrim(SA1->A1_EST)
_cInscR     := RTrim(SA1->A1_INSCR)
_cInscM     := RTrim(SA1->A1_INSCRM)
_cNomeTran  := RTrim(SA4->A4_NOME)
_cCNPJTran  := RTrim(SA4->A4_CGC)
_cEndTran   := RTrim(SubStr(SA4->A4_END,1,At(",",SA4->A4_END) - 1))
_cNumTran   := RTrim(SubStr(SA4->A4_END,At(",",SA4->A4_END) + 1))
_cBairTran  := RTrim(SA4->A4_BAIRRO)
_cMunTran   := RTrim(SA4->A4_MUN)
_cEstTran   := RTrim(SA4->A4_EST)
_cCEPTran   := RTrim(SA4->A4_CEP) 
_cInscRTran := RTrim(SA4->A4_INSEST) 
_cTPFrete   := IIF(SC5->C5_TPFRETE == "C","1","2")
_cPlaca     := ""
_cEstVeic   := ""
_cEspecie   := ""
_cMarca     := ""
_cNumero    := ""

_dDtaEmiss  := dToc(sTod(SC5->C5_EMISSAO))

_nBaseIcm   := Transform(StrZero(0,12,2),"@R 9999999999,99")
_nVlrIcm    := Transform(StrZero(0,12,2),"@R 9999999999,99")
_nBaseSub   := Transform(StrZero(0,12,2),"@R 9999999999,99")
_nVlrSub    := Transform(StrZero(0,12,2),"@R 9999999999,99")
_nFrete     := Transform(SC5->C5_FRETE,"@R 9999999999,99")
_nSeguro    := Transform(SC5->C5_SEGURO,"@R 9999999999,99")
_nDespesa   := Transform(SC5->C5_DESPESA,"@R 9999999999,99")
_nValorIPI  := Transform(StrZero(0,12,2),"@R 9999999999,99")
_nVlrProduto:= Transform(_nVlrProd,"@R 9999999999,99")
_nValorTotal:= _nVlrProd + SC5->C5_FRETE
_nQtdTran   := StrZero(0,12)

//--------------+
// Gera arquivo | 
//--------------+
_cLinArq := "3"                                         // 001. Tipo de Arquivo
_cLinArq += PadR(_cNumPv,20)                            // 002. codigo interno 
_cLinArq += PadR(_cNumPv,20)                            // 003. Numero Pedido
_cLinArq += PadR(_cCnpjDep,20)                          // 004. CNPJ Depositante
_cLinArq += PadR(_cCnpjEmi,20)                          // 005. CNPJ Emitente
_cLinArq += PadR("S",1)                                 // 006. Tipo de Pedido
_cLinArq += PadR(_cDescOp,100)                          // 007. Descrição da Operação
_cLinArq += PadR(_cCfop,4)                              // 008. CFOP
_cLinArq += _dDtaEmiss                                  // 009. Data de Emissao
_cLinArq += PadR(_cPessoa,1)                            // 010. Tipo de Pessoa
_cLinArq += PadR(_cCodCli,20)                           // 011. Codigo Destinatario
_cLinArq += PadR(_cNome,60)                             // 012. Nome Destinatario
_cLinArq += PadR(_cFantasia,60)                         // 013. Nome Fantasia
_cLinArq += PadR(_cCNPJDest,20)                         // 014. CNPJ Destinatario
_cLinArq += PadR(_cEndDest,80)                          // 015. Endereço Destinatario
_cLinArq += PadR(_cNumDest,10)                          // 016. Numero Endereço Destinatario
_cLinArq += PadR(_cComplem,50)                          // 017. Complemento Endereço Destinatario
_cLinArq += PadR(_cBairDest,50)                         // 018. Bairro Destinatario
_cLinArq += PadR(_cCepDest,8)                           // 019. CEP Destinatario
_cLinArq += PadR(_cMunDest,40)                          // 020. Municipio Destinatario
_cLinArq += PadR(_cTelDest,20)                          // 021. Telefone Destinatario
_cLinArq += PadR(_cEstDest,2)                           // 022. Estado Destinatario
_cLinArq += PadR(_cInscR,20)                            // 023. Inscrição Estadual Destinatario
_cLinArq += PadR(_cInscM,20)                            // 024. Inscrição Municipal Destinatario
_cLinArq += PadR(_cEndEnt,80)                           // 025. Endereço Entrega
_cLinArq += PadR(_cMunDest,40)                          // 026. Municipio Entrega
_cLinArq += PadR(_cBairDest,50)                         // 027. Bairro Entrega
_cLinArq += PadR(_cEstDest,2)                           // 028. Estado Entrega
_cLinArq += PadR(_cCepDest,8)                           // 029. CEP Entrega
_cLinArq += PadR(_cCNPJDest,20)                         // 030. CNPJ Entrega
_cLinArq += PadR(_cInscR,20)                            // 031. Inscrição Estadual Entrega
_cLinArq += PadR(_nBaseIcm,12)                          // 032. Base ICMS
_cLinArq += PadR(_nVlrIcm,12)                           // 033. Valor ICMS
_cLinArq += PadR(_nBaseSub,12)                          // 034. Base Substituição
_cLinArq += PadR(_nVlrSub,12)                           // 035. Valor Substituição
_cLinArq += PadR(_nFrete,12)                            // 036. Frete
_cLinArq += PadR(_nSeguro,12)                           // 037. Seguro
_cLinArq += PadR(_nDespesa,12)                          // 038. Despesas
_cLinArq += PadR(_nValorIPI,12)                         // 039. Valor IPI
_cLinArq += PadR(_nVlrProduto,12)                       // 040. Valor Produtos
_cLinArq += PadR(_nValorTotal,12)                       // 041. Valor Total
_cLinArq += PadR(_cNomeTran,60)                         // 042. Nome Transportadora
_cLinArq += PadR(_cCNPJTran,20)                         // 043. CNPJ Transportadora
_cLinArq += PadR(_cEndTran,80)                          // 044. Endereco Transportadora
_cLinArq += PadR(_cNumTran,10)                          // 045. Numero Transportadora
_cLinArq += PadR(_cBairTran,50)                         // 046. Bairro Transportadora
_cLinArq += PadR(_cMunTran,40)                          // 047. Municipio Transportadora
_cLinArq += PadR(_cEstTran,2)                           // 048. Estado Transportadora
_cLinArq += PadR(_cCEPTran,8)                           // 049. CEP Transportadora
_cLinArq += PadR(_cInscRTran,20)                        // 050. Inscrição Estadual Transportadora
_cLinArq += PadR(_cTPFrete,1)                           // 051. Tipo de Frete
_cLinArq += PadR(_cPlaca,20)                            // 052. Placa Veiculo
_cLinArq += PadR(_cEstVeic,2)                           // 053. Estado Veiculo
_cLinArq += PadR(_nQtdTran,12)                          // 054. Quantidade
_cLinArq += PadR(_cEspecie,20)                          // 055. Especie
_cLinArq += PadR(_cMarca,20)                            // 056. Marca
_cLinArq += PadR(_cNumero,20)                           // 057. Numero


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