#Include "protheus.ch" 
//--------------------------------------------------------------------
/*/{Protheus.doc} XFINSA1BL
Permite apenas usu�rios cadastrados no par�metro "MV_XUSRSA1", 
manipular os campos que est�o com a fun��o.
@author TOTVS Protheus
@since  21/11/2017
/*/
//--------------------------------------------------------------------
User Function XFINSA1BL()

Local lRet		:= .T.
Local cUsuFin	:= GETMV("MV_XUSRSA1")
Local cCodUsu	:= RetCodUsr()

If !cCodUsu $cUsuFin
	lRet	:= .F.
Endif

Return(lRet)