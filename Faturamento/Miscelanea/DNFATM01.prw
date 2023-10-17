#INCLUDE 'PROTHEUS.CH'

#DEFINE CRLF CHR(13) + CHR(10)

/**************************************************************************/
/*/{Protheus.doc} DNFATM01
	@description Confirma se pedido foi realizada a separação
	@author Bernard M. Margarido
	@since 22/11/2018
	@version 1.0
	@type function
/*/
/**************************************************************************/
User Function DNFATM01(cMarca,lInverte)
Local aArea		:= GetArea()

Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")
Local _cFilMSL  := GetNewPar("DN_FILMSL","07")
Local _cAlias	:= GetNextAlias()
Local _cMsg		:= ""
Local _cQuery	:= ""

Local lRet		:= .T.

Local _lAtvWMS	:= GetNewPar("DN_ATVWSMS",.T.)

If !_lAtvWMS .Or. cFilAnt <> _cFilMSL
	RestArea(aArea)
	Return .T.
EndIf

If !cFilAnt $ _cFilWMS + "," + _cFilMSL
	RestArea(aArea)
	Return .T.
EndIf

//------------------+
// Posiciona Pedido |
//------------------+
SC5->( dbSetOrder(1) )
SC5->( dbSeek(xFilial("SC5") + SC9->C9_PEDIDO) )

//------------------------------------+
// Valida se nota é de beneficiamento |
//------------------------------------+
If !SC5->C5_TIPO $ "N/D"
	RestArea(aArea)
	Return .T.
EndIf

_cQuery := " SELECT " + CRLF
_cQuery += "	C9.C9_ITEM," + CRLF
_cQuery += "	C9.C9_PRODUTO," + CRLF
_cQuery += "	C9.C9_PEDIDO, " + CRLF 
_cQuery += "	C9.R_E_C_N_O_ RECNOSC9 " + CRLF 
_cQuery	+= " FROM " + CRLF
_cQuery	+= " 	" + RetSqlName("SC9") + " C9  " + CRLF
_cQuery	+= " WHERE " + CRLF
_cQuery	+= "	C9.C9_FILIAL = '" + xFilial("SC9") + "' AND " + CRLF
_cQuery += "   	C9.C9_PEDIDO  BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' AND " + CRLF
_cQuery += "   	C9.C9_CLIENTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' AND " + CRLF
_cQuery += "   	C9.C9_LOJA    BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' AND " + CRLF
_cQuery += "   	C9.C9_DATALIB BETWEEN '" + Dtos(MV_PAR11) + "' AND '" + Dtos(MV_PAR12) + "' AND " + CRLF
_cQuery += "	C9.C9_XENVWMS <> '3' AND " + CRLF
_cQuery += "   	C9.C9_NFISCAL  = '' AND " + CRLF
_cQuery += "   	C9.C9_BLCRED  = '' AND " + CRLF
_cQuery += "   	C9.C9_BLEST   = '' AND " + CRLF

If lInverte
	_cQuery += " C9.C9_OK <> '" + cMarca + "' AND " + CRLF
Else
	_cQuery += " C9.C9_OK = '" + cMarca + "' AND " + CRLF
EndIf

_cQuery += "   	C9.D_E_L_E_T_  = '' "  + CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

While (_cAlias)->( !Eof() )
	
	_cMsg += " Item " + RTrim((_cAlias)->C9_ITEM) + " Produto " + RTrim((_cAlias)->C9_PRODUTO) + " do pedido " + RTrim((_cAlias)->C9_PEDIDO) + " não poderá ser faturado. Aguardando separação do operador logistico." + CRLF 	
	
	SC9->( dbGoto((_cAlias)->RECNOSC9) )
	RecLock("SC9",.F.)
		SC9->C9_OK := " "
	SC9->( MsUnLock() )

	(_cAlias)->( dbSkip() )
EndDo

(_cAlias)->( dbCloseArea() )

//----------------+
// Exibe mensagem | 
//----------------+
If !Empty(_cMsg)
	Aviso("Dana Cosmeticos - Avisos",_cMsg,{"Ok"})
	lRet := .F.
EndIf	

Pergunte("MT460A", .F.)

RestArea(aArea)
Return lRet
