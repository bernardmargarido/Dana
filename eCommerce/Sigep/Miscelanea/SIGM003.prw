#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/**************************************************************************/
/*/{Protheus.doc} SIGM003

@description Retornar Digito verificador etiquetas

@author Bernard M. Margarido
@since 08/02/2017
@version undefined

@type function
/*/
/**************************************************************************/
User Function SIGM003()
Local _lRet		:= .T.

//----------------------------+
// Grava serviços contratados |
//----------------------------+
FwMsgRun(,{|| SigM03A()},"Aguarde...","Gera digito etiquetas")

	
Return _lRet

/************************************************************************************/
/*/{Protheus.doc} SigM03A

@description Gera digito verificador etoquetas

@author Bernard M. Margarido
@since 07/02/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function SigM03A()
Local _cAlias	:= GetNextAlias()
Local _cMsg		:= ""

Local _lRet 	:= .T.

Local  _oSigWeb	:= SigepWeb():New

If !SigM03Qry(_cAlias)
	Return .F.
EndIf

//------------------------------+
// Seleciona tabela de serviços |
//------------------------------+
While (_cAlias)->( !Eof() )
	
	//--------------------+
	// Posiciona Registro |
	//--------------------+
	ZZ1->( dbGoTo((_cAlias)->RECNOZZ1) )

	//---------------------------------------+
	// Parametros para gerar digito etiqueta |
	//---------------------------------------+
	_oSigWeb:cEtqParc 	:= Rtrim(ZZ1->ZZ1_CODETQ)
	_oSigWeb:cSigla		:= Rtrim(ZZ1->ZZ1_SIGLA)

	//-----------------------------------+
	// Classe gera digito etiqueta SIGEP |
	//-----------------------------------+
	If _oSigWeb:GetDigEtq()
		_cMsg += "DIGITO ETIQUETA " + Rtrim(ZZ1->ZZ1_CODETQ) + " GERADO COM SUCESSO. " + CRLF
		//--------------------------+
		// Grava digito verificador |
		//--------------------------+
		RecLock("ZZ1",.F.)
			ZZ1->ZZ1_DVETQ := _oSigWeb:cDigEtq
		ZZ1->( MsUnLock() )
	Else
		_cMsg += "ERRO AO GERAR DIGITO ETIQUETA " + Rtrim(ZZ1->ZZ1_CODETQ) + " ." + _oSigWeb:cError + " ." + CRLF
	EndIf

	(_cAlias)->( dbSkip() )
EndDo

//--------------------+
// Encerra temporario |
//--------------------+
(_cAlias)->( dbCloseArea() )

//---------------------+
// Alerta para usuário |
//---------------------+
MsgAlert(_cMsg,"Dana Cosmeticos - Avisos")

Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} SigM03Qry

@description Consulta etiquetas que estão sem digito verificador

@author Bernard M. Margarido
@since 08/02/2017
@version undefined
@param cAlias, characters, descricao
@type function
/*/
/****************************************************************************************/
Static Function SigM03Qry(_cAlias)
Local _cQuery := ""

_cQuery := "	SELECT " + CRLF
_cQuery += "		ZZ1.ZZ1_CODETQ, " + CRLF
_cQuery += "		ZZ1.ZZ1_SIGLA, " + CRLF
_cQuery += "		ZZ1.R_E_C_N_O_ RECNOZZ1 " + CRLF
_cQuery += "	FROM " + CRLF
_cQuery += "		" + RetSqlName("ZZ1") + " ZZ1 " + CRLF 
_cQuery += "	WHERE " + CRLF
_cQuery += "		ZZ1.ZZ1_FILIAL = '" + xFilial("ZZ1") + "' AND " + CRLF 
_cQuery += "		ZZ1.ZZ1_DVETQ = '' AND " + CRLF
_cQuery += "		ZZ1.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->( Eof() )
	(_cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.

/*********************************************************************************/
/*/{Protheus.doc} LogExec

@description Grava Log do processo 

@author SYMM Consultoria
@since 26/01/2017
@version undefined

@param cMsg, characters, descricao

@type function
/*/

/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.