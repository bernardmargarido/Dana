#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CLR_CINZA RGB(230,230,230)
#DEFINE CRLF CHR(13) + CHR(10)
 
/************************************************************************************/
/*/{Protheus.doc} SIGM001

@description Consulta serviços disponiveis, comforme contrado

@author Bernard M. Margarido
@since 07/02/2017
@version undefined

@type function
/*/
/************************************************************************************/
User Function SIGM001()
Local _aArea		:= GetArea()

//----------------------------+
// Grava serviços contratados |
//----------------------------+
FwMsgRun(,{|| SigM01A()},"Aguarde...","Consultando contratos")

RestArea(_aArea)
Return .T. 

/************************************************************************************/
/*/{Protheus.doc} SigM01A
@description Consulta contratos
@author Bernard M. Margarido
@since 06/12/2019
@version 1.0
@type function
/*/
/************************************************************************************/
Static Function SigM01A()
Local _cMsg			:= ""

Local _lRet 		:= .T.

Local  _oSigWeb		:= SigepWeb():New

//--------------------+
// Consulta Contratos |
//--------------------+
If _oSigWeb:GrvServico()
	_cMsg := "Contratos gravados com sucesso. Deseja abrir tela de consulta?"
Else
	_cMsg 	:= _oSigWeb:cError
	_lRet	:= .F.
EndIf

MsgAlert(_cMsg,"Dana Cosmeticos - Avisos")

Return .T.