#Include "protheus.ch" 
//--------------------------------------------------------------------
/*/{Protheus.doc} XA1XBLQFIN
Permite apenas usu�rios cadastrados no par�metro "MV_XFINSA1", 
manipular os campos que est�o com a fun��o.
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
