#Include "protheus.ch" 
//--------------------------------------------------------------------
/*/{Protheus.doc} XFINSA1BL
Permite apenas usuários cadastrados no parâmetro "MV_XUSRSA1", 
manipular os campos que estão com a função.
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