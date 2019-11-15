#Include "Protheus.Ch"
/*/
{Protheus.doc}	ALFVCXML
Description 	Valida se o cliente está habilitado para uso do template
@param			Nenhum
@return			Nil
@author			
@since			07/01/2019
/*/
User Function ALFVCXML(lJob)
Local lRet := .T.
Local cCNPJ := SubStr(Alltrim(SM0->M0_CGC),1,8)
Local cMsg := "Empresa logada nao esta habilitada para uso do Template XML"
Default lJob := .F.

// CNPJs Habilitados

/*
If !( cCNPJ $ "|43854777|10702092|61088936|" )
	lRet := .F.
EndIf
*/

If !lRet
	If lJob
		ConOut(cMsg)
	Else
		Alert(cMsg)
	EndIf
	Final(cMsg)
EndIf

Return(Nil)