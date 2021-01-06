#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/***********************************************************************************/
/*/{Protheus.doc} DLOGM03
    @description Envia lista de postagem DLog
    @type  Function
    @author Bernard M. Margarido
    @since 05/01/2021
/*/
/***********************************************************************************/
User Function DLOGM03()
Local   _lRet       := .T.

Private _lJob       := IIF(Isincallstack("U_DLOGM01"),.T.,.F.)

Private _aPLP       := {}

Private _oProcess   := Nil

CoNout("<< DLOGM03 >> - INICIO " + dTos( Date() ) + " - " + Time() )

If _lJob
    _lRet := DLOGM03A()
Else
    Processa({|| _lRet := DLOGM03A()},"Aguarde...","Enviando Lista de Postagem." )
EndIf

CoNout("<< DLOGM03 >> - FIM " + dTos( Date() ) + " - " + Time() )
Return _lRet 

/***********************************************************************************/
/*/{Protheus.doc} DLOGM03A
    @description Realiza o envio das postagens 
    @type  Static Function
    @author Bernard M. Margarido
    @since 05/01/2021
/*/
/***********************************************************************************/
Static Function DLOGM03A()
Local _aArea	:= GetArea()

Local _cAlias	:= GetNextAlias()
Local _cCodPLP	:= ""

Local _nToReg	:= 0
Local _nRecnoZZB:= 0

Local _aItPLP	:= {}

Local _lRet		:= .T.

Local _oDLog	:= DLog():New()
Local _oJSon	:= Nil 
Local _oNotas	:= Nil 

//-------------------+
// Consulta Postagem |
//-------------------+
If !DlogM03Qry(_cAlias,@_nToReg)
	If _lJob
		MsgStop("Não existem dados para serem enviados.","Aviso")
	EndIf
	ConOut(" << DLOGM03 >> - NAO EXISTEM DADOS PARA SEREM ENVIADOS.")	
	RestArea(_aArea)
	Return .F.
EndIf

//--------------------------------+
// Tabela - Orçamentos e-Commerce |
//--------------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )

//--------------------+
// Tabela - Postagens |
//--------------------+
dbSelectArea("ZZB")
ZZB->( dbSetOrder(1) )

//-------------------------+
// Tabela - Itens Postagem |
//-------------------------+
dbSelectArea("ZZC")
ZZC->( dbSetOrder(1) )

//-----------------------------+
// Array contento as Etiquetas |
//-----------------------------+
While (_cAlias)->( !Eof() )

	_cRest		:= ""
	_cCodPLP 	:= (_cAlias)->ZZB_CODIGO
	_nRecnoZZB	:= (_cAlias)->RECNOZZB

	CoNout("<< DLOGM03 >> - ENVIANDO PLP " + _cCodPLP)

	_oJSon						:= Nil 
	_oJSon						:= Array(#)
	_oJSon[#"listaPostagem"]	:= {}

	While (_cAlias)->( !Eof() .And. _cCodPLP == (_cAlias)->ZZ2_CODIGO )
		
		aAdd(_oJSon[#"listaPostagem"],Array(#))
    	_oNotas := aTail(_oJSon[#"listaPostagem"])	

		_oNotas[#"notaFiscal"]											:= Array(#)
        _oNotas[#"notaFiscal"][#"idTabFrete"]							:= ""
		_oNotas[#"notaFiscal"][#"nfChave"]								:= RTrim((_cAlias)->F2_CHVNFE)
		_oNotas[#"notaFiscal"][#"nfNumero"]								:= RTrim((_cAlias)->ZZC_NOTA)
		_oNotas[#"notaFiscal"][#"nfSerie"]								:= RTrim((_cAlias)->ZZC_SERIE)
		_oNotas[#"notaFiscal"][#"nfDataHora"]							:= RTrim((_cAlias)->F2_DTDANFE) + "T" + RTrim((_cAlias)->F2_HORNFE)
		_oNotas[#"notaFiscal"][#"nfTpServico"]							:= "0"
		_oNotas[#"notaFiscal"][#"nfPedidoVenda"]						:= RTrim((_cAlias)->ZZC_NUMSC5)
		_oNotas[#"notaFiscal"][#"enderecoEntrega"] 						:= Array(#)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"pessoaJuridica"] 	:= IIF( (_cAlias)->A1_PESSOA == "F", .F., .T.)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"cpfCnpjDest"]		:= PadL(RTrim((_cAlias)->A1_CGC),_nTCNPJ,"0")
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"ieDest"]			:= RTrim((_cAlias)->A1_INSCR)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"nomeDest"]			:= RTrim((_cAlias)->WSA_NOMDES)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"logradouroDest"]	:= SubStr((_cAlias)->WSA_ENDENT, 1, At(",",(_cAlias)->WSA_ENDENT) - 1)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"numeroDest"]		:= RTrim((_cAlias)->WSA_ENDNUM)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"complDest"]		:= RTrim((_cAlias)->WSA_COMPLE)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"bairroDest"]		:= RTrim((_cAlias)->WSA_BAIRRE)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"cidadeDest"]		:= RTrim((_cAlias)->WSA_MUNE)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"ufDest"]			:= (_cAlias)->WSA_ESTE
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"cepDest"]			:= (_cAlias)->WSA_CEPE
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"ptoRefDest"]		:= RTrim((_cAlias)->WSA_REFEN)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"foneDest"]			:= RTrim((_cAlias)->WSA_TEL01)
        _oNotas[#"notaFiscal"][#"enderecoEntrega"][#"emailDest"]		:= RTrim((_cAlias)->A1_EMAIL)
		_oNotas[#"notaFiscal"][#"valorProd"]							:= (_cAlias)->F2_VALMERC
		_oNotas[#"notaFiscal"][#"valorNf"]								:= (_cAlias)->F2_VALBRUT

		(_cAlias)->( dbSkip() )

	EndDo
	
	//--------------------------+
	// Envia Postagem para DLog |
	//--------------------------+
	_cRest  := EncodeUTF8(xToJson(_oJSon))

	_oDLog:cJSon 	:= _cRest 
	_oDLog:cCodigo	:= _cCodPLP
	_oDLog:GeraLista()

EndDo 

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return _lRet 

/***********************************************************************************/
/*/{Protheus.doc} DlogM03Qry
	@description Consulta postagens da Dlog
	@type  Static Function
	@author Bernard M. Margarido
	@since 06/01/2021
/*/
/***********************************************************************************/
Static Function DlogM03Qry(_cAlias,_nToReg)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	ZZB.ZZB_CODIGO, " + CRLF
_cQuery += "	ZZC.ZZC_ITEM, " + CRLF
_cQuery += "	ZZC.ZZC_NOTA, " + CRLF
_cQuery += "	ZZC.ZZC_SERIE, " + CRLF
_cQuery += "	ZZC.ZZC_NUMECO, " + CRLF
_cQuery += "	ZZC.ZZC_NUMSC5, " + CRLF
_cQuery += "	F2.F2_CHVNFE, " + CRLF
_cQuery += "	F2.F2_DTDANFE, " + CRLF 
_cQuery += "	F2.F2_HORNFE, " + CRLF
_cQuery += "	F2.F2_VALMERC, " + CRLF
_cQuery += "	F2.F2_VALBRUT, " + CRLF
_cQuery += "	A1.A1_PESSOA, " + CRLF
_cQuery += "	A1.A1_CGC, " + CRLF
_cQuery += "	A1.A1_INSCR, " + CRLF
_cQuery += "	A1.A1_EMAIL, " + CRLF
_cQuery += "	WSA.WSA_NOMDES, " + CRLF
_cQuery += "	WSA.WSA_ENDENT, " + CRLF
_cQuery += "	WSA.WSA_ENDNUM, " + CRLF
_cQuery += "	WSA.WSA_COMPLE, " + CRLF
_cQuery += "	WSA.WSA_REFEN, " + CRLF
_cQuery += "	WSA.WSA_BAIRRE, " + CRLF
_cQuery += "	WSA.WSA_MUNE, " + CRLF
_cQuery += "	WSA.WSA_ESTE, " + CRLF
_cQuery += "	WSA.WSA_CEPE, " + CRLF
_cQuery += "	WSA.WSA_TEL01, " + CRLF
_cQuery += "	ZZB.R_E_C_N_O_ RECNOZZB, " + CRLF
_cQuery += "	ZZC.R_E_C_N_O_ RECNOZZC " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("ZZB") + " ZZB " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("ZZC") + " ZZC ON ZZC.ZZC_FILIAL = ZZB.ZZB_FILIAL AND ZZC.ZZC_CODIGO = ZZB.ZZB_CODIGO AND ZZC.ZZC_STATUS IN('1','3') AND ZZC.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("WSA") + " WSA ON WSA.WSA_FILIAL = ZZC.ZZC_FILIAL AND WSA.WSA_NUMECO = ZZC.ZZC_NUMECO AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = WSA.WSA_CLIENT AND A1.A1_LOJA = WSA.WSA_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SF2") + " F2 ON F2.F2_FILIAL = ZZC.ZZC_FILIAL AND F2.F2_DOC = ZZC.ZZC_NOTA AND F2.F2_SERIE = ZZC.ZZC_SERIE AND F2.F2_CLIENTE = A1.A1_COD AND F2.F2_LOJA = A1.A1_LOJA AND F2.F2_CHVNFE <> '' AND F2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZB.ZZB_FILIAL = '" + xFilial("ZZB") + "' AND " + CRLF
_cQuery += "	ZZB.ZZB_STATUS IN('1','3') AND " + CRLF
_cQuery += "	ZZB.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY ZZB.ZZB_CODIGO,ZZC.ZZC_ITEM,ZZC.ZZC_NOTA,ZZC.ZZC_SERIE "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )
If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.