#INCLUDE "PROTHEUS.CH"

/********************************************************************************************/
/*/{Protheus.doc} ECADDCPO
    @description Ponto de Entrada - Inserir novos campos no cadastro de clientes e-Commerce
    @author Bernard M. Margarido
    @since 29/05/2018
    @version 1.0
    @type function
/*/
/********************************************************************************************/
User Function ECADDCPO()
Local aCliente 	:= ParamIxb[3]

Local _cAtivo   := "S"
Local _cTpCli   := "5"
Local _cTpFret  := "F"
Local _cSuframa := "N"
Local _cBaseRed := "N"
Local _cCond    := "001"
Local _cLeadFat := "2"
Local _cRegEsp  := "2"
Local _cClassif := "001"    
Local _cAceSaldo:= "2"
Local _cFimPPe  := "2"
Local _nLeadTi  := 1
Local _nFatorPr := 1

aAdd(aCliente , {"A1_ATIVO"     ,    _cAtivo    ,    Nil })
aAdd(aCliente , {"A1_XTIPCLI"   ,    _cTpCli    ,    Nil })
aAdd(aCliente , {"A1_TPFRET"    ,    _cTpFret   ,    Nil })
aAdd(aCliente , {"A1_CALCSUF"   ,    _cSuframa  ,    Nil })
aAdd(aCliente , {"A1_BASERED"   ,    _cBaseRed  ,    Nil })
aAdd(aCliente , {"A1_COND"      ,    _cCond     ,    Nil })
aAdd(aCliente , {"A1_XLEADFA"   ,    _cLeadFat  ,    Nil })
aAdd(aCliente , {"A1_XLEADTI"   ,    _nLeadTi   ,    Nil })
aAdd(aCliente , {"A1_XREGESP"   ,    _cRegEsp   ,    Nil })
aAdd(aCliente , {"A1_CLASSIF"   ,    _cClassif  ,    Nil })
aAdd(aCliente , {"A1_XACESAL"   ,    _cAceSaldo ,    Nil })
aAdd(aCliente , {"A1_FATORPR"   ,    _nFatorPr  ,    Nil })
aAdd(aCliente , {"A1_XFIMPPE"   ,    _cFimPPe   ,    Nil })

Return aCliente
