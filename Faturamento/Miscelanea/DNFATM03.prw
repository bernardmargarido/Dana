#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/**********************************************************************************/
/*/{Protheus.doc} DnFatM02
    @description Valida alteração do preço aplicada
    @type  Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/**********************************************************************************/
User Function DnFatM03(_cCodtab,_cFilial,_cMsg,_aMsg)
Local _cQuery 	:= ""
Local _cAlias	:= ""
Local _cAviso	:= ""

Local _lRet     := .T.

_cQuery := " SELECT " + CRLF
_cQuery += "	DA1.DA1_ITEM, " + CRLF
_cQuery += "	DA1.DA1_CODPRO, " + CRLF
_cQuery += "	DA1.DA1_PRCVEN, " + CRLF
_cQuery += "	DA1.DA1_XPRCVE, " + CRLF
_cQuery += "	DA1.R_E_C_N_O_ RECNODA1 " + CRLF 
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("DA1") + " DA1 " + CRLF 
_cQuery += " WHERE " + CRLF 
_cQuery += "	DA1.DA1_FILIAL = '" + _cFilial + "' AND " + CRLF
_cQuery += "	DA1.DA1_CODTAB = '" +_cCodtab + "' AND " + CRLF 
_cQuery += "	DA1.DA1_XPRCVE > 0 AND " + CRLF
_cQuery += "	DA1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY DA1.DA1_ITEM "

_cAlias := MPSysOpenQuery(_cQuery)

dbSelectArea("DA1")
DA1->( dbSetOrder(1) )

While (_cAlias)->( !Eof() )
	
	_cAviso	+= " Item " + (_cAlias)->DA1_ITEM + " Produto " + RTrim((_cAlias)->DA1_CODPRO) + " Preço Atual " + cValToChar((_cAlias)->DA1_XPRCVE) + " Preço Alterado " + cValToChar((_cAlias)->DA1_PRCVEN) + " ." + CRLF 
	
	aAdd(_aMsg,{RTrim((_cAlias)->DA1_CODPRO)," Item " + (_cAlias)->DA1_ITEM + " Produto " + RTrim((_cAlias)->DA1_CODPRO) + " Preço Atual " + cValToChar((_cAlias)->DA1_XPRCVE) + " Preço Alterado " + cValToChar((_cAlias)->DA1_PRCVEN) + " ."})
	
	DA1->( dbGoTo((_cAlias)->RECNODA1) )
	RecLock("DA1",.F.)
		DA1->DA1_PRCVEN := (_cAlias)->DA1_XPRCVE
		DA1->DA1_XPRCVE := (_cAlias)->DA1_PRCVEN
	DA1->( MsUnLock() )
	(_cAlias)->( dbSkip() ) 
EndDo

If !Empty(_cAviso)
	_cMsg := "Os produtos abaixo somente surtiram efeito mediante aprovação do superior." + CRLF
	_cMsg += _cAviso
EndIf

Return _lRet 
