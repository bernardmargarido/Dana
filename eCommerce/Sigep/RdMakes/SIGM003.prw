#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cDirImp	:= "/sigep/"

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
Local lRet		:= .T.

Private cArqLog	:= ""	

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirImp)
cArqLog := cDirImp + "DIGITOETIQUETA" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO SIGEP - DIGITOETIQUETA - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-----------------------------------------+
// Inicia processo de envio das categorias |
//-----------------------------------------+
Processa({|| lRet := SIGM03DV() },"Aguarde...","Solicitando novas etiquetas.")

LogExec("FINALIZA INTEGRACAO SIGEP - DIGITOETIQUETA - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
ConOut("")
	
Return lRet

/************************************************************************************/
/*/{Protheus.doc} SIGM03DV

@description Retorna digito verificador da etiqueta 

@author Bernard M. Margarido
@since 07/02/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function SIGM03DV()
Local aArea		:= GetArea()

Local lRet		:= .T.

Local cAlias	:= GetNextAlias()
Local cUsuario	:= GetNewPar("VI_USERSIG","sigep")
Local cSenha	:= GetNewPar("VI_PASSSIG","n5f9t8")
Local cUrlSigep	:= GetNewPar("VI_URLSIGE","https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

Local nDigito	:= 0

Local oWsSigep	:= Nil

Private oResp	:= Nil

If !SigM03Qry(cAlias)
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return .F.
EndIf

//--------------------------+
// Instancia a classe SIGEP |
//--------------------------+
oWsSigep := WSSigep():New

//------------------------------+
// Seleciona tabela de serviços |
//------------------------------+
While (cAlias)->( !Eof() )
	
	//--------------------+
	// Posiciona Registro |
	//--------------------+
	SZ1->( dbGoTo((cAlias)->RECNOSZ1) )
	
	//-------------------------+
	// Parametros BuscaCliente |
	//-------------------------+
	oWsSigep:_Url				:= cUrlSigep
	oWsSigep:cEtiquetas			:= (cAlias)->Z1_CODETQ + " " + (cAlias)->Z1_SIGLA
	oWsSigep:cUsuario 			:= cUsuario
	oWsSigep:cSenha 			:= cSenha
		
	WsdlDbgLevel(3)
	If oWsSigep:GeraDigitoVerificadorEtiquetas()
		lRet	:= .T.
		If ValType(oResp) == "O"
			If ValType(oResp:_Ns2_GeraDigitoVerificadorEtiquetasResponse:_Return:Text) == "C" .And. !Empty(oResp:_Ns2_GeraDigitoVerificadorEtiquetasResponse:_Return:Text)
				cDigito := oResp:_Ns2_GeraDigitoVerificadorEtiquetasResponse:_Return:Text
				RecLock("SZ1",.F.)
					SZ1->Z1_DVETQ := cDigito
				SZ1->( MsUnLock() )
			Else
				lRet	:= .F.
				LogExec("NAO FORAM RETORANDAS ETIQUETAS")
			EndIf				
		EndIf
	Else
		lRet	:= .F.
		LogExec("ERRO AO GERAR DIGITO VERIFICADOR ETIQUETAS " + GetWscError() )
	EndIf
	
	(cAlias)->( dbSkip() )
EndDo

RestArea(aArea)
Return lRet

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
Static Function SigM03Qry(cAlias)
Local cQuery := ""

cQuery := "	SELECT " + CRLF
cQuery += "		Z1.Z1_CODETQ, " + CRLF
cQuery += "		Z1.Z1_SIGLA, " + CRLF
cQuery += "		Z1.R_E_C_N_O_ RECNOSZ1 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SZ1") + " Z1 " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		Z1.Z1_FILIAL = '" + xFilial("SZ1") + "' AND " + CRLF 
cQuery += "		Z1.Z1_DVETQ = '' AND " + CRLF
cQuery += "		Z1.Z1_NOTA = '' AND " + CRLF
cQuery += "		Z1.Z1_SERIE = '' AND " + CRLF
cQuery += "		Z1.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
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