#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/**********************************************************************/
/*/{Protheus.doc} SIGM002

@description Solicita a etiqueta de postagem  

@author Bernard M. Margarido
@since 08/02/2017
@version undefined

@type function
/*/
/**********************************************************************/
User Function SIGM002(cIdEtq)
Local _aArea		:= GetArea()

//--------------------+
// Solicita Etiquetas |
//--------------------+
FwMsgRun(,{|| SigM02A()},"Aguarde...","Consultando etiquetas")

RestArea(_aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} SigM02A
@description Gera novas etiquetas 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function SigM02A()
Local _cMsg			:= ""

Local _lRet 		:= .T.

Local  _oSigWeb		:= SigepWeb():New

//--------------------+
// Consulta Contratos |
//--------------------+
If _oSigWeb:GrvCodEtq()
	_cMsg 	:= "Etiquetas gravados com sucesso"
	_lRet	:= .T.
Else
	_cMsg 	:= _oSigWeb:cError
	_lRet	:= .F.
EndIf

MsgAlert(_cMsg,"Dana Cosmeticos - Avisos")

Return _lRet