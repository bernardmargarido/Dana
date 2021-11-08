#include "rwmake.ch"
#include "topconn.ch"
#include "totvs.ch"
#Include "Protheus.Ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DCFAT230  ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 26/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Verifica raiz do CNPJ do cliente.        				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ DANA COSMÉTICOS    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function DCFAT230()

Local cQuery	:= ""
Local cMensCli  := ""
Local cPulaLin  := Chr(13) + Chr(10)
Local lRet      := .T.

If Select("TRBSA1") > 0
	TRBSA1->(DbCloseArea())
Endif

cQuery	:= " SELECT DISTINCT(A1_COD) AS 'A1_COD' " +CRLF
cQuery	+= " FROM "+ RetSqlname("SA1") +" SA1 (NOLOCK) " +CRLF
cQuery	+= " WHERE SUBSTRING(A1_CGC,1,8) = '"+SUBSTR(M->A1_CGC,1,8)+"' " +CRLF
cQuery	+= " AND A1_MSBLQL <> '1' " +CRLF
cQuery	+= " AND SA1.D_E_L_E_T_ = '' " +CRLF
TcQuery cQuery New Alias "TRBSA1"

If Select("TRBSA1") > 0
    While !TRBSA1->(EOF())
        If Select("TRBCL") > 0
            TRBCL->(DbCloseArea())
        Endif

        cQuery	:= " SELECT MAX(A1_LOJA) AS 'A1_LOJA' " +CRLF
        cQuery	+= " FROM "+ RetSqlname("SA1") +" SA1 (NOLOCK) " +CRLF
        cQuery	+= " WHERE A1_COD = '"+TRBSA1->A1_COD+"' " +CRLF
        cQuery	+= " AND A1_MSBLQL <> '1' " +CRLF
        cQuery	+= " AND SA1.D_E_L_E_T_ = '' " +CRLF
        TcQuery cQuery New Alias "TRBCL"    
        If Empty(cMensCli)
            cMensCli := "Código/Loja do cliente, já cadastrado com essa raiz de CNPJ:" + cPulaLin + TRBSA1->A1_COD +"/"+TRBCL->A1_LOJA
        Else
            cMensCli += cPulaLin + TRBSA1->A1_COD +"/"+TRBCL->A1_LOJA
        Endif
    TRBSA1->(DbSkip())
    EndDo
Endif

If !Empty(cMensCli)
    MsgInfo(cMensCli,"DCFAT230 - D A N A   C O S M É T I C O S")
Endif

If Select("TRBSA1") > 0
	TRBSA1->(DbCloseArea())
Endif

If Select("TRBCL") > 0
	TRBCL->(DbCloseArea())
Endif

Return(lRet)
