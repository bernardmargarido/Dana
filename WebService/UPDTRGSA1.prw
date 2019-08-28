#INCLUDE 'PROTHEUS.CH'

#DEFINE CRLF CHR(13) + CHR(10)

User Function UPDTRGSA1(cEmp,cFil)

Local aArea		:= GetArea()
Local cQuery	:= ""
Local cTMP1		:= "TRIGGER"

Default cEmp	:= "04"
Default	cFil	:= "05"

//-------------------------------+
// Valida se ja existe a Trigger |
//-------------------------------+
/*
cQuery := " SELECT COUNT(1) NUMREG FROM sys.sysobjects WHERE name = 'TG_SA1010' AND xtype = 'TR' "

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTMP1,.T.,.T.)

If (cTMP1)->( !EOF()) .Or. (cTMP1)->NUMREG <> 0
	MsgAlert(" - Trigger TG_SA1010 ja existente " + CRLF )
	(cTMP1)->(DbCloseArea())
	RestArea(aArea)
	Return .T.
EndIf
*/

cQuery := " ALTER "
cQuery += " TRIGGER TG_SA1010 "+ CRLF
cQuery += " ON " + RetSqlName("SA1") + " "+ CRLF
cQuery += " FOR UPDATE AS "+ CRLF
cQuery += " BEGIN "+ CRLF
cQuery += " IF @@ROWCOUNT = 0 RETURN "+ CRLF
cQuery += "		IF 	NOT UPDATE(A1_FILIAL) AND " + CRLF
cQuery += "			NOT UPDATE(A1_COD) AND " + CRLF
cQuery += "			NOT UPDATE(A1_LOJA) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_NOME) AND " + CRLF
cQuery += "			NOT UPDATE(A1_NREDUZ) AND " + CRLF
cQuery += "			NOT UPDATE(A1_PESSOA) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_END) AND " + CRLF
cQuery += "			NOT UPDATE(A1_ENDCOB) AND " + CRLF
cQuery += "			NOT UPDATE(A1_ENDENT) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_BAIRRO) AND " + CRLF
cQuery += "			NOT UPDATE(A1_BAIRROC) AND " + CRLF
cQuery += "			NOT UPDATE(A1_BAIRROE) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_COMPLEM) AND " + CRLF
cQuery += "			NOT UPDATE(A1_TIPO) AND " + CRLF
cQuery += "			NOT UPDATE(A1_EST) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_ESTC) AND " + CRLF
cQuery += "			NOT UPDATE(A1_ESTE) AND " + CRLF
cQuery += "			NOT UPDATE(A1_CEP) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_CEPC) AND " + CRLF
cQuery += "			NOT UPDATE(A1_CEPE) AND " + CRLF
cQuery += "			NOT UPDATE(A1_COD_MUN) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_CODMUNE) AND " + CRLF
cQuery += "			NOT UPDATE(A1_MUN) AND " + CRLF
cQuery += "			NOT UPDATE(A1_REGIAO) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_DDD) AND " + CRLF
cQuery += "			NOT UPDATE(A1_DDI) AND " + CRLF
cQuery += "			NOT UPDATE(A1_TEL) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_FAX) AND " + CRLF
cQuery += "			NOT UPDATE(A1_TELEX) AND " + CRLF
cQuery += "			NOT UPDATE(A1_CONTATO) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_CGC) AND " + CRLF
cQuery += "			NOT UPDATE(A1_RG) AND " + CRLF
cQuery += "			NOT UPDATE(A1_PFISICA) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_INSCR) AND " + CRLF
cQuery += "			NOT UPDATE(A1_INSCRM) AND " + CRLF
cQuery += "			NOT UPDATE(A1_INSCRUR) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_PAIS) AND " + CRLF
cQuery += "			NOT UPDATE(A1_DTNASC) AND " + CRLF
cQuery += "			NOT UPDATE(A1_EMAIL) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_HPAGE) AND " + CRLF
cQuery += "			NOT UPDATE(A1_CNAE) AND " + CRLF
cQuery += "			NOT UPDATE(A1_MSBLQL) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_VEND) AND " + CRLF
cQuery += "			NOT UPDATE(A1_TPFRET) AND " + CRLF
cQuery += "			NOT UPDATE(A1_TRANSP) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_COND) AND " + CRLF
cQuery += "			NOT UPDATE(A1_RISCO) AND " + CRLF
cQuery += "			NOT UPDATE(A1_LC) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_LCFIN) AND " + CRLF
cQuery += "			NOT UPDATE(A1_VENCLC) AND " + CRLF
cQuery += "			NOT UPDATE(A1_TABELA) AND " + CRLF
cQuery += "	 		NOT UPDATE(A1_OBSERV) AND " + CRLF
cQuery += "			NOT UPDATE(A1_GRPVEN) AND " + CRLF
cQuery += "			NOT UPDATE(A1_DTCAD) AND  " + CRLF
cQuery += "	 		NOT UPDATE(A1_HRCAD) AND " + CRLF
cQuery += "			NOT UPDATE(A1_CALCSUF) AND " + CRLF
cQuery += "			NOT UPDATE(A1_BASERED) AND " + CRLF
cQuery += "			NOT UPDATE(A1_XVEND2) AND " + CRLF
cQuery += "			NOT UPDATE(A1_XFIMPPE) AND " + CRLF
cQuery += "			NOT UPDATE(A1_DESCABT) AND " + CRLF
cQuery += "			NOT UPDATE(A1_RAMO) AND " + CRLF
cQuery += "			NOT UPDATE(A1_XTIPCLI) AND " + CRLF
cQuery += "			NOT UPDATE(A1_TPORG) AND " + CRLF
cQuery += "			NOT UPDATE(A1_XFIMPPE)  RETURN " + CRLF 
cQuery += " 	DECLARE @OLD VARCHAR(1) "+ CRLF
cQuery += "		SELECT  @OLD = [A1_X_EXPO] FROM DELETED " 	+ CRLF
cQuery += " 	DECLARE @ID INT "+ CRLF
cQuery += " 	SELECT @ID = R_E_C_N_O_ FROM INSERTED "+ CRLF
cQuery += " 	UPDATE " + RetSqlName("SA1") + " SET A1_X_EXPO = '' WHERE R_E_C_N_O_ = @ID AND @OLD = 'S' "+ CRLF
cQuery += "	END "+ CRLF

If TcSqlExec(cQuery) >= 0
	MsgAlert(" - Criado Trigger TG_SA1010 " + CRLF )
Else
	MsgAlert(" - Erro ao Criar Trigger TG_SA1010  " + CRLF)
EndIf 

RestArea(aArea)	
Return .T.