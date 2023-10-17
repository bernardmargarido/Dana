#Include "protheus.ch" 
//--------------------------------------------------------------------
/*/{Protheus.doc} XFISSA1BL
Permite apenas usuários cadastrados no parâmetro "MV_XFISSA1", 
manipular os campos que estão com a função.
@author TOTVS Protheus
@since  21/11/2017
/*/
//--------------------------------------------------------------------
User Function XFISSA1BL()

Local lRet		:= .T.
Local cUsuFis	:= GETMV("MV_XFISSA1")
Local cCodUsu	:= RetCodUsr()

Return .T.

If !cCodUsu $cUsuFis
	lRet	:= .F.
Endif

Return(lRet)
