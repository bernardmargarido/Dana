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
User Function IBFATM01(aParam)
Local _aArea        := GetArea()

Private _cArqLog    := ""

Private _lJob       := IIF(ValType(aParam) == "A",.T.,.F.)

//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)
MakeDir(_cDirRaiz + _cDirArq)

_cArqLog := _cDirRaiz + _cDirArq + "/" + "PEDIDOVENDA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA CRIACAO DOS ARQUIVOS PEDIDOS IBEX - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------------+
// Envia pedidos para IBEX |
//-------------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(aParam[1], aParam[2],,,'FAT')
    
    IBFatM01Proc()

Else
    Processa({|| IBFatM01Proc() },"Aguarde...","Gerando arquivo IBEX.")
EndIf

LogExec("FINALIZA CRIACAO DOS ARQUIVOS PEDIDOS IBEX - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
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

/**********************************************************************/
/*/{Protheus.doc} IBFATM01
    @description Cria arquivo pedido de venda
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
Static Function IBFatM01Proc()
Local _aArea        := GetArea()

Local _cAlias       := GetNextAlias()
Local _cTimeArq     := Time()
Local _cCfop        := ""

Local _nTotItens    := 0
Local _nVlrProd     := 0
Local _nToReg       := 0

Local _dDtaArq      := Date()

Local _lFlag        := .F.    

Private _cArqSc5    := ""
Private _cArqSc6    := ""
Private _cArqLog    := ""
Private _cCnpjDep   := SM0->M0_CGC
Private _cCnpjEmi   := SM0->M0_CGC
Private _cCnpjIbx   := GetNewPar("DN_IBXCNPJ","21840527000285")

Private _nHdlCab    := 0
Private _nHdlIt     := 0

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

//---------------------------------+
// Posiciona Orçamentos e-Commerce |
//---------------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )

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

_cCnpjDep   := IIF(Len(Rtrim(_cCnpjDep)) > 11,Transform(_cCnpjDep,"@R 99.999.999/9999-99"),Transform(_cCnpjDep,"@R 999.999.999-99"))
_cCnpjEmi   := IIF(Len(Rtrim(_cCnpjEmi)) > 11,Transform(_cCnpjEmi,"@R 99.999.999/9999-99"),Transform(_cCnpjEmi,"@R 999.999.999-99"))
_cCnpjIbx   := IIF(Len(Rtrim(_cCnpjIbx)) > 11,Transform(_cCnpjIbx,"@R 99.999.999/9999-99"),Transform(_cCnpjIbx,"@R 999.999.999-99"))

While (_cAlias)->( !Eof() )

    //------------------+
    // Posiciona pedido |
    //------------------+
    SC5->( dbGoTo((_cAlias)->RECNOSC5) )

    //----------------------+
    // Cria arquivo pedidos |
    //----------------------+
    _cArqSc5    := "PEDIDO_CAB_" + RTrim(SC5->C5_NUM) + "_"  + StrZero( Day( _dDtaArq ),2,0) + "_" + StrZero( Month( _dDtaArq),2,0) + "_" + StrZero( Year( _dDtaArq),4,0) + "_" + Left(_cTimeArq,2) + "_" + SubStr(_cTimeArq,4,2) + "_" + Right(_cTimeArq,2) + ".INF"
    _cArqSc6    := "PEDIDO_ITEM_" + RTrim(SC5->C5_NUM) + "_" + StrZero( Day( _dDtaArq ),2,0) + "_" + StrZero( Month( _dDtaArq),2,0) + "_" + StrZero( Year( _dDtaArq),4,0) + "_" + Left(_cTimeArq,2) + "_" + SubStr(_cTimeArq,4,2) + "_" + Right(_cTimeArq,2) + ".IDT"

    _cCfop      := (_cAlias)->CFOP
    _nTotItens  := (_cAlias)->ITENS
    _nVlrProd   := (_cAlias)->VALOR_ITENS

    If !_lJob
        IncProc("<===> CRIANDO ARQUIVO PEDIDO " + SC5->C5_NUM + " .") 
    EndIf

    LogExec("<===> CRIANDO ARQUIVO PEDIDO " + SC5->C5_NUM + " ." )

    //---------------------------+
    // Gera arquivo do cabeçalho | 
    //---------------------------+
    _lFlag  := .F.
    If IBFatM01Cab(_cCfop,_nTotItens,_nVlrProd)
        //------------------------+
        // Gera arquivo dos itens | 
        //------------------------+
        If IBFatM01It()
            _lFlag  := .T.
        EndIf
    EndIf    

    //---------------------------------------------+
    // Atualiza pedido como enviado para Logistica |
    //---------------------------------------------+
    If _lFlag
        If WSA->( dbSeek(xFilial("WSA") + (_cAlias)->WSA_NUMECO) )
            RecLock("WSA",.F.)
                WSA->WSA_ENVLOG := "1"
            WSA->( MsUnLock() )    
        EndIf
    EndIf

    (_cAlias)->( dbSkip() )
EndDo

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return .T.

/**********************************************************************/
/*/{Protheus.doc} IBFatM01Cab
    @description Gera arquivo com o cabeçalho dos itens
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
Static Function IBFatM01Cab(_cCfop,_nTotItens,_nVlrProd)
Local _cDirSC5      := _cDirRaiz + _cDirArq + _cDirUpl + "/" + _cArqSc5
Local _cLinArq      := ""
Local _cNumPv       := ""
Local _cDescOp      := ""
Local _cPessoa      := ""
Local _cCodCli      := ""
Local _cNome        := ""
Local _cFantasia    := ""
Local _cCNPJDest    := ""
Local _cEndDest     := ""
Local _cNumDest     := ""
Local _cEndEnt      := ""
Local _cComplem     := ""
Local _cBairDest    := ""
Local _cCepDest     := ""
Local _cMunDest     := ""
Local _cTelDest     := ""
Local _cEstDest     := ""
Local _cInscR       := ""
Local _cInscM       := ""
Local _cNomeTran    := ""
Local _cCNPJTran    := ""
Local _cEndTran     := ""
Local _cNumTran     := ""
Local _cBairTran    := ""
Local _cMunTran     := ""
Local _cEstTran     := ""
Local _cCEPTran     := ""
Local _cInscRTran   := ""
Local _cTPFrete     := ""
Local _cPlaca       := ""
Local _cEstVeic     := ""
Local _cEspecie     := ""
Local _cMarca       := ""
Local _cNumero      := ""
Local _cGeraFin     := ""
Local _cTpDoc       := ""
Local _cTpCarga     := ""
Local _cTpNF        := ""    
Local _cEstCarga    := ""
Local _dDtaColeta   := ""
Local _cHrColeta    := ""
Local _cTpPesEnt    := ""
Local _cCodEnt      := ""
Local _cNomeEnt     := ""
Local _cFantEnt     := ""
Local _cNumEnt      := ""
Local _cCompEnt     := ""
Local _cNomeVend    := ""
Local _cTelVend     := ""
Local _cFatura      := ""
Local _cObs         := ""
Local _cEstVeri     := ""
Local _cChaveVeri   := ""
Local _cPrioridade  := ""    
Local _cChaveNfe	:= ""    
Local _cSeqPedido	:= ""     
Local _cCNPJRed	    := ""
Local _cInscEmit	:= ""
Local _cF			:= ""
Local _cCodSerTr	:= ""    
Local _cClassPed	:= ""
Local _cCompleDest  := ""    

Local _dDtaEmiss    := ""

Local _nBaseIcm     := 0
Local _nVlrIcm      := 0
Local _nBaseSub     := 0
Local _nVlrSub      := 0
Local _nFrete       := 0
Local _nSeguro      := 0
Local _nDespesa     := 0
Local _nValorIPI    := 0
Local _nVlrProduto  := 0
Local _nValorTotal  := 0
Local _nQtdTran     := 0
Local _nPesoLiq     := 0
Local _nValPis      := 0
Local _nValCofi     := 0
Local _nValCont     := 0
Local _nValIR       := 0
Local _nValISS      := 0
Local _nValServ     := 0
Local _nIDNFiscal   := 0
Local _nLimiCorte   := 0
Local _nGeoMapa     := 0
Local _nClassCli    := 0
Local _nEmbarque    := 0
Local _nPerPrio	    := 0
Local _nIdMovIbex   := 0
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

//----------------------+
// Variaveis do arquivo |
//----------------------+
_cNumPv     := SC5->C5_NUM
_cSerie     := ""
_cDescOp    := SF4->F4_TEXTO
_cPessoa    := SA1->A1_PESSOA
_cCodCli    := RTrim(SA1->A1_COD) + RTrim(SA1->A1_LOJA)
_cNome      := RTrim(SA1->A1_NOME)
_cFantasia  := RTrim(SA1->A1_NREDUZ)
_cCNPJDest  := RTrim(IIF(SA1->A1_PESSOA == "J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99")))
_cEndDest   := RTrim(SubStr(SA1->A1_END,1,At(",",SA1->A1_END) - 1))
_cNumDest   := AllTrim(SubStr(SA1->A1_END,At(",",SA1->A1_END) + 1))
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
_cGeraFin   := "N"
_cTpDoc     := "T"
_cTpCarga   := "Produtos"
_cTpNF      := "P"    
_cEstCarga  := "N"
_dDtaColeta := ""
_cHrColeta  := ""
_cTpPesEnt  := ""
_cCodEnt    := ""
_cNomeEnt   := ""
_cFantEnt   := ""
_cNumEnt    := ""
_cCompEnt   := ""
_cNomeVend  := ""
_cTelVend   := ""
_cFatura    := ""
_cObs       := ""
_cEstVeri   := ""
_cChaveVeri := ""
_cPrioridade:= "P"    
_cChaveNfe	:= ""    
_cSeqPedido	:= ""     
_cCNPJRed	:= ""
_cInscEmit	:= ""
_cF			:= "*"
_cCodSerTr	:= ""    
_cClassPed	:= ""
_cCompleDest:= ""    

_dDtaEmiss  := dToc(SC5->C5_EMISSAO)

_nBaseIcm   := Transform(StrZero(0,12,2),"@r 999999999,99")
_nVlrIcm    := Transform(StrZero(0,12,2),"@e 999999999,99")
_nBaseSub   := Transform(StrZero(0,12,2),"@e 999999999,99")
_nVlrSub    := Transform(StrZero(0,12,2),"@e 999999999,99")
_nFrete     := Transform(StrZero(SC5->C5_FRETE,12,2),"@e 999999999,99")
_nSeguro    := Transform(StrZero(SC5->C5_SEGURO,12,2),"@e 999999999,99")
_nDespesa   := Transform(StrZero(SC5->C5_DESPESA,12,2),"@e 999999999,99")
_nValorIPI  := Transform(StrZero(0,12,2),"@e 999999999,99")
_nVlrProduto:= Transform(StrZero(_nVlrProd,12,2),"@e 999999999,99")
_nValorTotal:= Transform(StrZero(_nVlrProd + SC5->C5_FRETE,12,2),"@e 999999999,99")
_nQtdTran   := StrZero(0,12)
_nPesoLiq   := Transform(StrZero((SC5->C5_PESOL * 1000),12),"@e 999999999999")
_nValPis    := Transform(StrZero(0,12,2),"@e 999999999,99")
_nValCofi   := Transform(StrZero(0,12,2),"@e 999999999,99")
_nValCont   := Transform(StrZero(0,12,2),"@e 999999999,99")
_nValIR     := Transform(StrZero(0,12,2),"@e 999999999,99")
_nValISS    := Transform(StrZero(0,12,2),"@e 999999999,99")
_nValServ   := Transform(StrZero(0,12,2),"@e 999999999,99")
_nIDNFiscal := StrZero(0,12)
_nLimiCorte := Transform(StrZero(0,12,2),"@e 999999999,99")
_nGeoMapa   := StrZero(0,12)
_nClassCli  := StrZero(0,12)
_nEmbarque	:= 0    
_nPerPrio	:= Transform(StrZero(0,12,2),"@e 999999999,99")  
_nIdMovIbex := StrZero(0,12)

//--------------+
// Gera arquivo | 
//--------------+
_cLinArq := "0"                                         // 001. Tipo de Arquivo
_cLinArq += PadR(_cNumPv,20)                            // 002. codigo interno 
_cLinArq += PadR(_cNumPv,20)                            // 003. Numero Pedido
_cLinArq += PadR(_cCnpjDep,20)                          // 004. CNPJ Depositante
_cLinArq += PadR(_cCnpjEmi,20)                          // 005. CNPJ Emitente
_cLinArq += PadR(_cSerie,20)                            // 006. Serie Nota Fiscal
_cLinArq += PadR("S",1)                                 // 007. Tipo de Pedido
_cLinArq += PadR(_cDescOp,100)                          // 008. Descrição da Operação
_cLinArq += PadR(_cCfop,4)                              // 009. CFOP
_cLinArq += _dDtaEmiss                                  // 010. Data de Emissao
_cLinArq += PadR(_cPessoa,1)                            // 011. Tipo de Pessoa
_cLinArq += PadR(_cCNPJDest,20)                         // 012. Codigo Destinatario
_cLinArq += PadR(_cNome,60)                             // 013. Nome Destinatario
_cLinArq += PadR(_cFantasia,60)                         // 014. Nome Fantasia
_cLinArq += PadR(_cCNPJDest,20)                         // 015. CNPJ Destinatario
_cLinArq += PadR(_cEndDest,80)                          // 016. Endereço Destinatario
_cLinArq += PadR(_cNumDest,10)                          // 017. Numero Endereço Destinatario
_cLinArq += PadR(_cComplem,50)                          // 018. Complemento Endereço Destinatario
_cLinArq += PadR(_cBairDest,50)                         // 019. Bairro Destinatario
_cLinArq += PadR(_cCepDest,8)                           // 020. CEP Destinatario
_cLinArq += PadR(_cMunDest,40)                          // 021. Municipio Destinatario
_cLinArq += PadR(_cTelDest,20)                          // 022. Telefone Destinatario
_cLinArq += PadR(_cEstDest,2)                           // 023. Estado Destinatario
_cLinArq += PadR(_cInscR,20)                            // 024. Inscrição Estadual Destinatario
_cLinArq += PadR(_cInscM,20)                            // 025. Inscrição Municipal Destinatario
_cLinArq += PadR(_cEndEnt,80)                           // 026. Endereço Entrega
_cLinArq += PadR(_cMunDest,40)                          // 027. Municipio Entrega
_cLinArq += PadR(_cBairDest,50)                         // 028. Bairro Entrega
_cLinArq += PadR(_cEstDest,2)                           // 029. Estado Entrega
_cLinArq += PadR(_cCepDest,8)                           // 030. CEP Entrega
_cLinArq += PadR(_cCNPJDest,20)                         // 031. CNPJ Entrega
_cLinArq += PadR(_cInscR,20)                            // 032. Inscrição Estadual Entrega
_cLinArq += PadR(_nBaseIcm,12)                          // 033. Base ICMS
_cLinArq += PadR(_nVlrIcm,12)                           // 034. Valor ICMS
_cLinArq += PadR(_nBaseSub,12)                          // 035. Base Substituição
_cLinArq += PadR(_nVlrSub,12)                           // 036. Valor Substituição
_cLinArq += PadR(_nFrete,12)                            // 037. Frete
_cLinArq += PadR(_nSeguro,12)                           // 038. Seguro
_cLinArq += PadR(_nDespesa,12)                          // 039. Despesas
_cLinArq += PadR(_nValorIPI,12)                         // 040. Valor IPI
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
_cLinArq += PadR(_nPesoLiq,12)                          // 058. Peso Liquido 
_cLinArq += PadR(_nValPis,12)                           // 059. Valor PIS
_cLinArq += PadR(_nValCofi,12)                          // 060. Valor COFINS
_cLinArq += PadR(_nValCont,12)                          // 061. Valor Contribuição Socia
_cLinArq += PadR(_nValIR,12)                            // 062. Valor IR
_cLinArq += PadR(_nValISS,12)                           // 063. Valor ISS
_cLinArq += PadR(_nValServ,12)                          // 064. Valor Serviço
_cLinArq += PadR(_nIdMovIbex,12)                        // 065. ID Movimento IBEX
_cLinArq += PadR(_nIDNFiscal,12)                        // 066. ID Nota Fiscal
_cLinArq += PadR(_cGeraFin,1)                           // 067. Gera Financeiro
_cLinArq += PadR(_cTpDoc,5)                             // 068. Tipo de Documento
_cLinArq += PadR(_cTpCarga,10)                          // 069. Tipo de Carga
_cLinArq += PadR(_nLimiCorte,12)                        // 070. Limite de Corte
_cLinArq += PadR(_nGeoMapa,12)                          // 071. GeoMapa
_cLinArq += PadR(_nTotItens,12)                         // 072. Total de Itens
_cLinArq += PadR(_cTpNF,1)                              // 073. Tipo de Documento
_cLinArq += PadR(_cEstCarga,1)                          // 074. Estado que se econtra a Carga
_cLinArq += PadR(_dDtaColeta,10)                        // 075. Data da Coleta
_cLinArq += PadR(_cHrColeta,8)                          // 076. Hora da Coleta
_cLinArq += PadR(_cTpPesEnt,1)                          // 077. Entidade de Entrega
_cLinArq += PadR(_cCodEnt,20)                           // 078. Codigo da Entidade de Entrega
_cLinArq += PadR(_cNomeEnt,60)                          // 079. Nome da Entidade de Entrega
_cLinArq += PadR(_cFantEnt,60)                          // 080. Fantasia Entidade de Entrega
_cLinArq += PadR(_cNumEnt,10)                           // 081. Numero Endereço Entidade de Entrega
_cLinArq += PadR(_cCompEnt,50)                          // 082. Complemento Endereço Entidade de Entrega
_cLinArq += PadR(_cNomeVend,60)                         // 083. Nome Vendedor
_cLinArq += PadR(_cTelVend,20)                          // 084. Telefone Vendedor
_cLinArq += PadR(_cCnpjIbx,20)                          // 085. CNPJ undade de Armazenagem
_cLinArq += PadR(_cFatura,50)                           // 086. Fatura
_cLinArq += PadR(_cObs,200)                             // 087. Observações
_cLinArq += PadR(_cEstVeri,1)                           // 088. Estoque verificado
_cLinArq += PadR(_cChaveVeri,20)                        // 089. Chave de verificação
_cLinArq += PadR(_nClassCli,12)                         // 090. Classificação Cliente
_cLinArq += PadR(_cPrioridade,1)                        // 091. Prioridade Separação
_cLinArq += PadR(_nPerPrio,12)                          // 092. Porcentagem de caixa fechada para prioridade
_cLinArq += PadR(_cChaveNfe,44)                         // 093. Chave de Acesso NF-e
_cLinArq += PadR(_cSeqPedido,20)                        // 094. Sequencia pedido
_cLinArq += PadR(_cCNPJRed,20)                          // 095. CNPJ Transportadora Redespacho
_cLinArq += PadR(_cInscEmit,20)                         // 096. Inscrição Estatual Emitente
_cLinArq += PadR(_cF,1)                                 // 097. Não Utilizar
_cLinArq += PadR(_cCodSerTr,60)                         // 098. Codigo de Serviço Transportadora
_cLinArq += PadR(_cClassPed,100)                        // 099. Codigo de Classificação do Pedido
_cLinArq += PadR(_nEmbarque,1)                          // 100. Indica se a Nota Fiscal tem embarque 
_cLinArq += PadR(_cCompleDest,60)                       // 101. Complemento Destinatario

_cLinArq += CRLF    

FWrite(_nHdlCab, _cLinArq)

//---------------+
// Fecha Arquivo |
//---------------+
FClose(_nHdlCab)

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
Local _cNumPv     := ""
Local _cSerie     := ""
Local _cProduto   := ""
Local _cDesProd   := ""
Local _cCodBar    := ""
Local _cClassFis  := ""
Local _cST        := ""
Local _cST2       := ""
Local _cTpProd    := ""
Local _cNumSerie  := ""
Local _cChaveIden := ""
Local _cSeqPedido := ""
Local _cInscEmit  := ""
Local _cF         := ""
Local _cUM        := ""

Local _nItem      := 0
Local _nQtdVen    := 0
Local _nVlrUni    := 0
Local _nVlrTotal  := 0
Local _nAliqIcm   := 0
Local _nAliqIPI   := 0
Local _nValorIPI  := 0
Local _nVlrDesc   := 0
Local _nPerDesc   := 0
Local _nTotalDesc := 0
Local _nTotalLiq  := 0
Local _nQtdAtend  := 0
Local _nIDNFiscal := 0
Local _nTpMaterial:= 0

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

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//---------------------------------+
// Posiciona Complmento do Produto |
//---------------------------------+
dbSelectArea("SB5")
SB5->( dbSetOrder(1) )

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

    //-------------------+
    // Posiciona Produto |
    //-------------------+
    SB1->( dbSeek(xFilial("SB1") + SC6->C6_PRODUTO))

    //-------------------------------+
    // Posiciona Complemento Produto |
    //-------------------------------+
    SB5->( dbSeek(xFilial("SB5") + SC6->C6_PRODUTO))

    _cNumPv     := SC5->C5_NUM
    _cSerie     := ""
    _cProduto   := RTrim(SC6->C6_PRODUTO)
    _cDesProd   := RTrim(SB5->B5_XNOMPRD)
    _cCodBar    := RTrim(SB1->B1_EAN)
    _cClassFis  := SC6->C6_CLASFIS
    _cST        := ""
    _cST2       := ""
    _cTpProd    := "P"
    _cNumSerie  := ""
    _cChaveIden := ""
    _cSeqPedido := ""
    _cInscEmit  := ""
    _cF         := "00"
    _cUM        := ""

    _nItem      := Alltrim(StrZero(Val(SC6->C6_ITEM),12))
    _nQtdVen    := Alltrim(StrZero(Int(SC6->C6_QTDVEN),12))
    _nVlrUni    := Transform(StrZero(RetPrcUni(SC6->C6_QTDVEN),12),"@e 999999999999")
    _nVlrTotal  := Transform(StrZero(RetPrcUni(SC6->C6_VALOR),12),"@e 999999999999")
    _nAliqIcm   := Transform(StrZero(0,6,2),"@e 999,99")
    _nAliqIPI   := Transform(StrZero(0,6,2),"@e 999,99")
    _nValorIPI  := Transform(StrZero(0,12,2),"@e 999999999,99")
    _nVlrDesc   := Transform(StrZero(0,12,2),"@e 999999999,99")
    _nPerDesc   := Transform(StrZero(0,6,2),"@e 999,99")
    _nTotalDesc := Transform(StrZero(0,12,2),"@e 999999999,99")
    _nTotalLiq  := Transform(StrZero(RetPrcUni(SC6->C6_VALOR),12),"@e 999999999999")
    _nQtdAtend  := StrZero(0,12)
    _nIDNFiscal := StrZero(0,12)
    _nTpMaterial:= StrZero(0,12)

    //--------------+
    // Gera arquivo | 
    //--------------+
    _cLinArq := "0"                                         // 001. Tipo de Arquivo
    _cLinArq += PadR(_cNumPv,20)                            // 002. codigo interno 
    _cLinArq += PadR(_cNumPv,20)                            // 003. Numero Pedido
    _cLinArq += PadR(_cCnpjDep,20)                          // 004. CNPJ Depositante
    _cLinArq += PadR(_cCnpjEmi,20)                          // 005. CNPJ Emitente
    _cLinArq += PadR(_cSerie,20)                            // 006. Serie Nota Fiscal
    _cLinArq += PadR("S",1)                                 // 007. Tipo de Pedido
    _cLinArq += PadR(_nItem,12)                             // 008. Item do Pedido
    _cLinArq += PadR(_cProduto,20)                          // 009. Codigo do Produto
    _cLinArq += PadR(_cDesProd,80)                          // 010. Codigo do Produto
    _cLinArq += PadR(_cCodBar,20)                           // 011. Codigo de Barras
    _cLinArq += PadR(_cClassFis,5)                          // 012. Classificação Fiscal
    _cLinArq += PadR(_cST,2)                                // 013. Situação Tributária
    _cLinArq += PadR(_nQtdVen,12)                           // 014. Quantidade
    _cLinArq += PadR(_nVlrUni,12)                           // 015. Valor Unitario
    _cLinArq += PadR(_nVlrTotal,12)                         // 016. Valor Total
    _cLinArq += PadR(_nAliqIcm,6)                           // 017. Aliquota ICMS
    _cLinArq += PadR(_nAliqIPI,6)                           // 018. Aliquota IPI
    _cLinArq += PadR(_nValorIPI,12)                         // 019. Valor IPI
    _cLinArq += PadR(_nVlrDesc,12)                          // 020. Valor de Desconto
    _cLinArq += PadR(_nPerDesc,6)                           // 021. Percentual de Desconto
    _cLinArq += PadR(_nTotalDesc,12)                        // 022. Valor Total de Desconto 
    _cLinArq += PadR(_nTotalLiq,12)                         // 023. Valor Total Liquido
    _cLinArq += PadR(_cTpProd,1)                            // 024. Tipo de Produto
    _cLinArq += PadR(_nQtdAtend,12)                         // 025. Quantidade Atendida
    _cLinArq += PadR(_nIDNFiscal,12)                        // 026. Id Nota Fiscal
    _cLinArq += PadR(_cNumSerie,20)                         // 027. Numero Serie  
    _cLinArq += PadR(_nTpMaterial,20)                       // 028. Tipo de Material
    _cLinArq += PadR(_cST2,10)                              // 029. Situação Triburária tres digitos
    _cLinArq += PadR(_cChaveIden,20)                        // 030. Chave de Identificação
    _cLinArq += PadR(_cSeqPedido,20)                        // 031. Sequencia Pedido
    _cLinArq += PadR(_cProduto,60)                          // 032. Codigo Industria
    _cLinArq += PadR(_cDesProd,120)                         // 033. Descrição Produto
    _cLinArq += PadR(_cInscEmit,20)                         // 034. Incrição Estadual Emitente
    _cLinArq += PadR(_cF,2)                                 // 035. F
    _cLinArq += PadR(_cUM,6)                                // 036. Descrição Reduzida
    _cLinArq += CRLF

    FWrite(_nHdlIt, _cLinArq)

    SC6->( dbSkip() )

EndDo    

//FWrite(_nHdlIt, _cLinArq)

//---------------+
// Fecha Arquivo |
//---------------+
FClose(_nHdlIt)

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
_cQuery += "    WSA.WSA_NUMECO," + CRLF
_cQuery += "	ITENS_PEDIDO.CFOP," + CRLF
_cQuery += "	ITENS_PEDIDO.ITENS," + CRLF
_cQuery += "	ITENS_PEDIDO.VALOR_ITENS," + CRLF
_cQuery += "	C5.R_E_C_N_O_ RECNOSC5 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WSA") + " WSA " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("SL1") + " L1 ON L1.L1_FILIAL = WSA.WSA_FILIAL AND L1.L1_FILRES = WSA.WSA_FILIAL AND L1.L1_ORCRES = WSA.WSA_NUMSL1 AND L1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " C5 ON C5.C5_FILIAL = WSA.WSA_FILIAL AND C5.C5_NUM = L1.L1_PEDRES AND C5.D_E_L_E_T_ = '' " + CRLF
_cQuery += "    CROSS APPLY( " + CRLF 
_cQuery += "		        SELECT " + CRLF 
_cQuery += "		        	C6.C6_CF CFOP, " + CRLF 
_cQuery += "        			COUNT(C6.C6_ITEM) ITENS, " + CRLF 
_cQuery += "        			SUM(C6.C6_VALOR) VALOR_ITENS " + CRLF 
_cQuery += "        		FROM " + CRLF 
_cQuery += "    			    " + RetSqlName("SC6") + " C6 " + CRLF 
_cQuery += "		        WHERE " + CRLF 
_cQuery += "                    C6.C6_FILIAL = C5.C5_FILIAL AND " + CRLF  
_cQuery += "	        		C6.C6_NUM = C5.C5_NUM AND " + CRLF 
_cQuery += "        			C6.D_E_L_E_T_ = '' " + CRLF 
_cQuery += "            	GROUP BY C6.C6_CF " + CRLF 
_cQuery += "	) ITENS_PEDIDO " + CRLF 
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF 
_cQuery += "	WSA.WSA_DOC = '' AND " + CRLF 
_cQuery += "	WSA.WSA_SERIE = '' AND " + CRLF 
_cQuery += "	WSA.WSA_ENVLOG = '' AND " + CRLF 
_cQuery += "	WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY C5.C5_FILIAL,C5.C5_NUM "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->( Eof() )
   Return .F.
EndIf

Return .T.

/*******************************************************************/
/*/{Protheus.doc} RetPrcUni

@description Formata valor para envio ao eCommerce

@author Bernard M. Margarido
@since 13/02/2017
@version undefined

@param nVlrUnit, numeric, descricao

@type function
/*/
/*******************************************************************/
Static Function RetPrcUni(nVlrUnit) 
Local nValor	:= 0
	nValor		:= NoRound(nVlrUnit,2) * 100
Return nValor

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