#Include "protheus.ch" 
//--------------------------------------------------------------------
/*/{Protheus.doc} XA1XBLQFIN
Permite apenas usuários cadastrados no parâmetro "MV_XFINSA1", 
manipular os campos que estão com a função.
@author TOTVS Protheus
@since  21/11/2017
/*/
//--------------------------------------------------------------------
User Function XA1XBLQFIN()

Local lRet		:= .T.
Local cUsuFin	:= GETMV("MV_XBLQFIN")
Local cCodUsu	:= RetCodUsr()

If !cCodUsu $cUsuFin
	lRet	:= .F.
Endif

Return(lRet)
