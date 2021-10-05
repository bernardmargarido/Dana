#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************/
/*/{Protheus.doc} DNFINA07
    @description Atualização de Banco 
    @type  Function
    @author Bernard M. Margarido
    @since 28/07/2021
/*/
/************************************************************************/
User Function DNFINA07()
Local _aParam	:= {}
Local _aRet		:= {}

Local _cCodBco	:= GetNewPar("DN_BCOPGME",CriaVar("A6_COD",.F.))
Local _cAgencia	:= GetNewPar("DN_AGEPGME",CriaVar("A6_AGENCIA",.F.))
Local _cConta   := GetNewPar("DN_CONPGME",CriaVar("A6_NUMCON",.F.))
Local _cCondPG  := GetNewPar("DN_PGTPGME",CriaVar("E4_CODIGO",.F.))
Local _cNaturez := GetNewPar("DN_NATPGME",CriaVar("ED_CODIGO",.F.))
Local _cTipo    := GetNewPar("DN_TIPPGME",CriaVar("E1_TIPO",.F.))

Local _bVldParam:= {|| DnFinA07A() }

aAdd(_aParam,{1, "Banco"        , _cCodBco  , PesqPict("SA6","A6_COD")      , ".T.", "SA6"  , "", TamSx3("A6_COD")[1]       , .T.})
aAdd(_aParam,{1, "Agencia"      , _cAgencia , PesqPict("SA6","A6_AGENCIA")  , ".T.",        , "", TamSx3("A6_AGENCIA")[1]   , .T.})
aAdd(_aParam,{1, "Conta"        , _cConta   , PesqPict("SA6","A6_NUMCON")   , ".T.",        , "", 050                       , .T.})
aAdd(_aParam,{1, "Cond. Pgto"   , _cCondPG  , PesqPict("SE4","E4_CODIGO")   , ".T.", "SE4"  , "", TamSx3("E4_CODIGO")[1]    , .T.})
aAdd(_aParam,{1, "Natureza"     , _cNaturez , PesqPict("SED","ED_CODIGO")   , ".T.", "SED"  , "", 050                       , .T.})
aAdd(_aParam,{1, "Tipo"         , _cTipo    , PesqPict("se1","E1_TIPO")     , ".T.", "05"   , "", TamSx3("E1_TIPO")[1]      , .T.})
   
If ParamBox(_aParam,"Parametros Transferencia PagarMe",@_aRet,_bVldParam,,,,,,,.T., .T.)
    //------------------+
	// Grava parametros |
    //------------------+
	FWMsgRun(, {|_oSay| DNFINA07B(_oSay) }, "Aguarde...", "Atualizando registros .... " )
EndIf

Return Nil 

/******************************************************************/
/*/{Protheus.doc} DnFinA07A
    @description Valida dados dos parametros 
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/07/2021
/*/
/******************************************************************/
Static Function DnFinA07A()
Local _lRet     := .T. 

Local _cMsg     := ""

//--------------------------+
// SA6 - Cadastro de Bancos |
//--------------------------+
dbSelectArea("SA6")
SA6->( dbSetOrder(1) )
If !SA6->( dbSeek(xFilial("SA6") + mv_par01 + mv_par02 + mv_par03) )
    _lRet := .F. 
    _cMsg += "Banco/Agencia/Conta não localizada. Favor verificar dados digitados." + CRLF
EndIf

//---------------------------+
// SED - Natureza financeira |
//---------------------------+
dbSelectArea("SED")
SED->( dbSetOrder(1) )
If !SED->( dbSeek(xFilial(xFilial("SED") + mv_par05)))
    _lRet := .F. 
    _cMsg += "Natureza financeira não localizada. Favor verificar dados digitados." + CRLF
EndIf

//-----------------------------+
// SE4 - Condição de Pagamento | 
//-----------------------------+
dbSelectArea("SE4")
SE4->( dbSetOrder(1) )
If !SE4->( dbSeek(xFilial("SE4") + mv_par04))
    _lRet := .F. 
    _cMsg += "Condição de Pagamento não localizada. Favor verificar dados digitados." + CRLF
EndIf

//----------------------+
// SX5 - Tipo de Titulo |
//----------------------+
dbSelectArea("SX5")
SX5->( dbSetOrder(1) )
If !SX5->( dbSeek(xFilial("SX5") + "05" + mv_par06))
    _lRet := .F. 
    _cMsg += "Tipo de Pagamento não localizada. Favor verificar dados digitados." + CRLF
EndIf

If !Empty(_cMsg)
    MsgInfo(_cMsg,"Dana - Avisos")
EndIf

Return _lRet 

/******************************************************************/
/*/{Protheus.doc} DNFINA07B
    @description Atualiza dados dos parametros
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/07/2021
/*/
/******************************************************************/
Static Function DNFINA07B(_oSay)

//---------------------------+
// Parametro codigo do banco |
//---------------------------+
If !PutMV("DN_BCOPGME",mv_par01)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_BCOPGME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Codigo do Banco"
        SX6->X6_CONTEUD	:= mv_par01
        SX6->X6_CONTSPA	:= mv_par01
        SX6->X6_CONTENG	:= mv_par01	
        SX6->X6_PROPRI	:= "U"
        SX6->X6_PYME	:= "S"
    SX6->( MsUnLock() )
EndIf

//--------------------------+
// Parametro codigo agencia |
//--------------------------+
If !PutMV("DN_AGEPGME",mv_par02)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_AGEPGME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Codigo da Agencia"
        SX6->X6_CONTEUD	:= mv_par02
        SX6->X6_CONTSPA	:= mv_par02
        SX6->X6_CONTENG	:= mv_par02	
        SX6->X6_PROPRI	:= "U"
        SX6->X6_PYME	:= "S"
    SX6->( MsUnLock() )
EndIf

//------------------------+
// Parametro codigo conta |
//------------------------+
If !PutMV("DN_CONPGME",mv_par03)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_CONPGME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Codigo da Conta"
        SX6->X6_CONTEUD	:= mv_par03
        SX6->X6_CONTSPA	:= mv_par03
        SX6->X6_CONTENG	:= mv_par03	
        SX6->X6_PROPRI	:= "U"
        SX6->X6_PYME	:= "S"
    SX6->( MsUnLock() )
EndIf

//------------------------------+
// Parametro condicao pagamento |
//------------------------------+
If !PutMV("DN_PGTPGME",mv_par04)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_PGTPGME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Codigo da condição de pagamento"
        SX6->X6_CONTEUD	:= mv_par04
        SX6->X6_CONTSPA	:= mv_par04
        SX6->X6_CONTENG	:= mv_par04	
        SX6->X6_PROPRI	:= "U"
        SX6->X6_PYME	:= "S"
    SX6->( MsUnLock() )
EndIf

//---------------------------+
// Parametro codigo natureza |
//---------------------------+
If !PutMV("DN_NATPGME",mv_par05)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_NATPGME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Codigo da natureza financeira"
        SX6->X6_CONTEUD	:= mv_par05
        SX6->X6_CONTSPA	:= mv_par05
        SX6->X6_CONTENG	:= mv_par05	
        SX6->X6_PROPRI	:= "U"
        SX6->X6_PYME	:= "S"
    SX6->( MsUnLock() )
EndIf

//--------------------------+
// Parametro tipo do titulo |
//--------------------------+
If !PutMV("DN_TIPPGME",mv_par06)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_TIPPGME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Tipo do titulo financeiro"
        SX6->X6_CONTEUD	:= mv_par06
        SX6->X6_CONTSPA	:= mv_par06
        SX6->X6_CONTENG	:= mv_par06	
        SX6->X6_PROPRI	:= "S"
        SX6->X6_PYME	:= "S"
    SX6->( MsUnLock() )
EndIf

Return Nil 