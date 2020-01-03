#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

WSSTRUCT DAWSI01STR
	WSDATA WS_RETURN	AS STRING
	WSDATA WS_DESRET  	AS STRING
	WSDATA WS_ARRUSER 	AS ARRAY OF STRUSER
ENDWSSTRUCT	

//-------------------------------------+
// Cria estrutura cadastro de usuarios |
//-------------------------------------+
WSSTRUCT STRUSER
	WSDATA WS_CODIGO 	AS STRING
	WSDATA WS_NOME 		AS STRING
	WSDATA WS_MAIL 		AS STRING
	WSDATA WS_STATUS	AS STRING
	WSDATA WS_SEXO		AS STRING
	WSDATA WS_CPFCNPJ	AS STRING
	WSDATA WS_DTNASC	AS STRING
	WSDATA WS_DTENVI	AS STRING
	WSDATA WS_IDERP		AS INTEGER
ENDWSSTRUCT

/**********************************************************************************/
/*/{Protheus.doc} DAWSI001

@description Webservice  - Vendedores

@author Bernard M. Margarido

@since 07/08/2017
@version undefined

@type class
/*/
/**********************************************************************************/
WSSERVICE DAWSI001 DESCRIPTION "Servico renune metodos especificos Extranet - Dana."
	
	WSDATA WS_CNPJCPF 	AS STRING
	WSDATA WS_CODIGO	AS STRING
	WSDATA WS_ARRRET 	AS DAWSI01STR
				
	//------------------------+
	// Metodo Insere Usuarios |
	//------------------------+	
	WSMETHOD WSUSER 	DESCRIPTION "Metodo retorna dados para cadastro de usuários - Dana."
	//WSMETHOD WS_CARGOS 	DESCRIPTION "Metodo retorna dados para cadastro de cargos - Dana."
	
ENDWSSERVICE

/**********************************************************************************/
/*/{Protheus.doc} WS_USER 

@description Metodo consulta e retorna dados para cadastro de usuarios

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@type function
/*/
/**********************************************************************************/
WSMETHOD WSUSER WSRECEIVE WS_CNPJCPF,WS_CODIGO WSSEND WS_ARRRET WSSERVICE DAWSI001
Local aArea		:= GetArea()

Local cAlias	:= GetNextAlias()
Local cCnpj		:= ::WS_CNPJCPF
Local cCodVend	:= ::WS_CODIGO
	
Private cDirImp		:= "\WSDANA\"
Private cARQLOG		:= cDirImp + "WSUSER_" + cEmpAnt + "_" + cFilAnt + ".LOG"

//----------------+
// Cria diretorio |
//----------------+
MakeDir(cDirImp)

CONOUT("")	
LogExec(Replicate("-",80))
LogExec("INICIADO ROTINA DE INTEGRACAO COM EXTRANET: DAWSI001 - CADASTRO USUARIOS - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------+
// Consulta usuarios |
//-------------------+
If !DAWSI01QRY(cAlias,cCnpj,cCodVend)

	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	::WS_ARRRET:WS_RETURN 		:= "1"
	::WS_ARRRET:WS_DESRET 		:= "NAO EXISTEM DADOS A SEREM RETORNADOS"
	
	aAdd(::WS_ARRRET:WS_ARRUSER,WSClassNew("STRUSER"))
	::WS_ARRRET:WS_ARRUSER[1]:WS_CODIGO		:= ""
	::WS_ARRRET:WS_ARRUSER[1]:WS_NOME		:= ""
	::WS_ARRRET:WS_ARRUSER[1]:WS_MAIL		:= ""
	::WS_ARRRET:WS_ARRUSER[1]:WS_STATUS		:= ""
	::WS_ARRRET:WS_ARRUSER[1]:WS_SEXO		:= ""
	::WS_ARRRET:WS_ARRUSER[1]:WS_CPFCNPJ	:= ""
	::WS_ARRRET:WS_ARRUSER[1]:WS_DTNASC		:= ""
	::WS_ARRRET:WS_ARRUSER[1]:WS_DTENVI		:= ""
	::WS_ARRRET:WS_ARRUSER[1]:WS_IDERP		:= 0
		
	(cAlias)->( dbCloseArea() )
	LogExec("NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
	RestArea(aArea)
	Return .T.
EndIf 


//------------------+
// Processa retorno | 
//------------------+
::WS_ARRRET:WS_RETURN 		:= "0"
::WS_ARRRET:WS_DESRET 		:= "ARQUIVO RETORNADO COM SUCESSO"
	
While (cAlias)->( !Eof() )
	//-------------------------+
	// Inicia Array de Retorno |
	//-------------------------+
	aAdd(::WS_ARRRET:WS_ARRUSER,WSClassNew("STRUSER"))
	
	//--------------------+
	// Posiciona Vendedor |
	//--------------------+
	SA3->( dbGoTo((cAlias)->RECNOSA3) )
	RecLock("SA3",.F.)
		SA3->A3_MSEXP = dTos(Date())
	SA3->( MsUnLock() )

	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_CODIGO	:= (cAlias)->A3_COD
	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_NOME		:= (cAlias)->A3_NOME
	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_MAIL		:= (cAlias)->A3_EMAIL
	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_STATUS	:= IIF((cAlias)->A3_MSBLQL == "1","1","0")
	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_SEXO		:= ""
	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_CPFCNPJ	:= (cAlias)->A3_CGC
	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_DTNASC	:= ""
	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_DTENVI	:= dTos(Date())
	::WS_ARRRET:WS_ARRUSER[Len(::WS_ARRRET:WS_ARRUSER)]:WS_IDERP	:= (cAlias)->RECNOSA3
	 
	//-----------------------+
	// Cria Array de Retorno |
	//-----------------------+
	
	(cAlias)->( dbSkip() )
EndDo 

(cAlias)->( dbCloseArea() )

CONOUT("")	
LogExec("FIM ROTINA DE INTEGRACAO COM EXTRANET: DAWSI001 - CADASTRO USUARIOS - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
RestArea(aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} DAWSI01QRY

@description Consulta usuarios a serem enviados

@author Bernard M. Margarido

@since 11/08/2017
@version undefined

@param cAlias	, characters, descricao
 
@type function
/*/
/**********************************************************************************/
Static Function DAWSI01QRY(cAlias,cCnpj,cCodVend)
Local aArea	:= GetArea()

Local cQuery:= ""

cQuery := "	SELECT " + CRLF 
cQuery += "		A3.A3_COD, " + CRLF
cQuery += "		A3.A3_NOME, " + CRLF
cQuery += "		A3.A3_EMAIL, " + CRLF
cQuery += "		A3.A3_MSBLQL, " + CRLF
cQuery += "		A3.A3_CGC, " + CRLF
cQuery += "		A3.R_E_C_N_O_ RECNOSA3 " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "		" + RetSqlName("SA3") + " A3 " + CRLF
cQuery += "	WHERE " + CRLF

//------------------+
// Retorna por CNPJ | 
//------------------+
If !Empty(cCnpj) .And. Len(Alltrim(cCnpj)) > 0
	cQuery += "		A3.A3_CGC = '" + cCnpj + "' AND " + CRLF
ElseIf !Empty(cCodVend) .And. Len(Alltrim(cCodVend)) > 0
 	cQuery += "		A3.A3_COD = '" + cCodVend + "' AND " + CRLF
 	EndIf

cQuery += "		A3.D_E_L_E_T_ = '' " + CRLF
cQuery += "	ORDER BY A3.A3_COD "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	RestArea(aArea)
	Return .F.
EndIf

RestArea(aArea)
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} LogExec

@description Grava log de integração

@author TOTVS
@since 05/06/2017
@version undefined

@param cMsg, characters, descricao

@type function
/*/
/*************************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.