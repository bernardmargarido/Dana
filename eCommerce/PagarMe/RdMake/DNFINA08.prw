#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************/
/*/{Protheus.doc} DNFINA08
    @description Confogurações Pagar.Me
    @type  Function
    @author Bernard M. Margarido
    @since 28/07/2021
/*/
/************************************************************************/
User Function DNFINA08()
Local _aParam	:= {}
Local _aRet		:= {}

Local _cUrl	    := GetNewPar("DN_URLPAME",Space(100))
Local _cToken	:= GetNewPar("DN_USRPAME",Space(100))
Local _cPassword:= GetNewPar("DN_PASPAME",Space(100))

aAdd(_aParam,{1, "URL"        , _cUrl       , ""   , ".T.", , "", 080   , .T.})
aAdd(_aParam,{1, "Token"      , _cToken     , ""   , ".T.", , "", 080   , .T.})
aAdd(_aParam,{1, "Password"   , _cPassword  , ""   , ".T.", , "", 080   , .T.})
   
If ParamBox(_aParam,"Configuracoes PagarMe",@_aRet,,,,,,,,.T., .T.)
    //------------------+
	// Grava parametros |
    //------------------+
	FWMsgRun(, {|_oSay| DNFINA08B(_oSay) }, "Aguarde...", "Atualizando registros .... " )
EndIf

Return Nil 

/******************************************************************/
/*/{Protheus.doc} DNFINA08B
    @description Atualiza dados dos parametros
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/07/2021
/*/
/******************************************************************/
Static Function DNFINA08B(_oSay)

//---------------------------+
// Parametro codigo do banco |
//---------------------------+
If !PutMV("DN_URLPAME",mv_par01)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_URLPAME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Url de acesso as API's"
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
If !PutMV("DN_USRPAME",mv_par02)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_USRPAME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Token de acesso as API's"
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
If !PutMV("DN_PASPAME",mv_par03)
    SX6->( RecLock("SX6",.T.) )
        SX6->X6_FIL		:= xFilial("SX6")
        SX6->X6_VAR		:= "DN_PASPAME"
        SX6->X6_TIPO	:= "C"
        SX6->X6_DESCRIC	:= "Senha de acesso as API's"
        SX6->X6_CONTEUD	:= mv_par03
        SX6->X6_CONTSPA	:= mv_par03
        SX6->X6_CONTENG	:= mv_par03	
        SX6->X6_PROPRI	:= "U"
        SX6->X6_PYME	:= "S"
    SX6->( MsUnLock() )
EndIf

Return Nil 