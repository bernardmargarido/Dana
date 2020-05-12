#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/************************************************************************/
/*/{Protheus.doc} SIGM004

@description Envio de PLP para SIGEP 

@author Bernard M. Margarido
@since 09/02/2017
@version undefined

@type function
/*/
/************************************************************************/
User Function SIGM004(cNumDoc,cSerie,cOrderId,aFaixaEtq,cXmlPlp)
Local _aArea		:= GetArea()

Local _lRet 		:= .T.

Private _lJob		:= IIF(Isincallstack("U_SIGM005"),.T.,.F.)

CoNout("<< SIGM004 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//----------------------------+
// Grava serviços contratados |
//----------------------------+
If _lJob
	_lRet := SigM04A()
Else
	FwMsgRun(,{|| _lRet := SigM04A()},"Aguarde...","Consultando contratos")
EndIf

CoNout("<< SIGM004 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return _lRet 

/************************************************************************************/
/*/{Protheus.doc} SigM04A

@description Realiza o envio de postagem SIGEP 

@author Bernard M. Margarido
@since 07/02/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function SigM04A()
Local _aArea	:= GetArea()

Local _cAlias	:= GetNextAlias()
Local _cCodPLP	:= ""
Local _cCodEmb	:= ""
Local _cIDPlp	:= ""

Local _nToReg	:= 0
Local _nRecnoZZ2:= 0

Local _aItPLP	:= {}
Local _aFaixaEtq:= {}

Local _lRet		:= .T.

Local  _oSigWeb	:= SigepWeb():New

//----------------+
// Consulta PLP's |
//----------------+
If !SigM04Qry(_cAlias,@_nToReg)

	If _lJob
		MsgStop("Não existem dados para serem enviados.","Aviso")
	EndIf
	
	ConOut(" << SIGM004 >> - NAO EXISTEM DADOS PARA SEREM ENVIADOS.")	

	RestArea(_aArea)
	Return .T.
EndIf

//--------------------------------+
// Tabela - Orçamentos e-Commerce |
//--------------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )

//--------------------+
// Tabela - Etiquetas |
//--------------------+
dbSelectArea("ZZ1")
ZZ1->( dbSetOrder(3) )

//--------------------+
// Tabela - Itens PLP |
//--------------------+
dbSelectArea("ZZ4")
ZZ4->( dbSetOrder(1) )

//---------------------+
// Tabela - Embalagens |
//---------------------+
dbSelectArea("ZZ3")
ZZ3->( dbSetOrder(1) )

//-----------------------------+
// Array contento as Etiquetas |
//-----------------------------+
While (_cAlias)->( !Eof() )

	_cCodPLP 	:= (_cAlias)->ZZ2_CODIGO
	_nRecnoZZ2	:= (_cAlias)->RECNOZZ2

	_aItPLP	 	:= {}
	_aFaixaEtq	:= {}

	CoNout("<< SIGM004 >> - ENVIANDO PLP " + _cCodPLP)

	While (_cAlias)->( !Eof() .And. _cCodPLP == (_cAlias)->ZZ2_CODIGO )

		//--------------------+
		// Posiciona Embalgem | 
		//--------------------+
		_cCodEmb := "001"
		ZZ3->( dbSeek(xFilial("ZZ3") + _cCodEmb) )

		CoNout("<< SIGM004 >> - ITENS PLP ETIQUETA " + RTrim((_cAlias)->ZZ4_CODETQ) + " NOTA " + RTrim((_cAlias)->WSA_DOC) + " SERIE " + RTrim((_cAlias)->WSA_SERIE) + " DESTINATARIO " + RTrim((_cAlias)->WSA_NOMDES) + " .")

		aAdd( _aFaixaEtq, { (_cAlias)->ZZ1_CODETQ + (_cAlias)->ZZ1_SIGLA } ) 

		aAdd( _aItPLP, {	(_cAlias)->ZZ4_CODETQ					,;	// 01. Codigo Serviço
							(_cAlias)->ZZ0_CODSER					,;	// 02. Codigo Etiqueta
							(_cAlias)->C5_PBRUTO					,;	// 03. Peso Bruto 
							(_cAlias)->WSA_NOMDES					,;	// 04. Destinatario
							(_cAlias)->U5_DDD						,;	// 05. DDD
							(_cAlias)->U5_FONE						,;	// 06. Telefone
							(_cAlias)->U5_CELULAR					,;	// 07. Celular
							(_cAlias)->WSA_ENDENT					,;	// 08. Endereço de Entrega
							(_cAlias)->WSA_COMPLE					,;	// 09. Complemento 
							(_cAlias)->U5_CPF						,;	// 10. CPF / CNPJ Destinatario
							(_cAlias)->WSA_BAIRRE					,;	// 11. Bairro de Entrega
							(_cAlias)->WSA_MUNE						,;	// 12. Municipio de Entrega
							(_cAlias)->WSA_ESTE						,;	// 13. Estado de Entrega
							(_cAlias)->WSA_CEPE						,;	// 14. CEP de Entrega
							(_cAlias)->WSA_DOC						,;	// 15. Numero da Nota
							(_cAlias)->WSA_SERIE					,;	// 16. Serie da Nota
							IIF(ZZ3->ZZ3_TIPO == "1","002","001")	,;	// 17. Tipo de Embalagem
							ZZ3->ZZ3_ALTURA							,;	// 18. Altura da Embalagem
							ZZ3->ZZ3_LARG							,;	// 19. Largura da Embalagem
							ZZ3->ZZ3_COMPRI							})	// 20. Comprimento Embalgem
		(_cAlias)->( dbSkip() )
	EndDo

	//-----------+
	// Envia PLP |
	//-----------+
	_oSigWeb:cIdPLPErp	:= _cCodPLP
	_oSigWeb:aFaixaEtq	:= aClone(_aFaixaEtq)
	_oSigWeb:aPlpDest	:= aClone(_aItPLP)

	If _oSigWeb:SetPLP()
		_cIDPlp	:= _oSigWeb:cIdPLP

		CoNout("<< SIGM004 >> - PLP ID " + _cIDPlp + " ENVIADA COM SUCESSO .")

		//---------------+
		// Posiciona PLP |
		//---------------+
		ZZ2->( dbGoTo(_nRecnoZZ2) )
		RecLock("ZZ2",.F.)
			ZZ2->ZZ2_PLPID	:= _cIDPlp
			ZZ2->ZZ2_STATUS	:= "04"
			ZZ2->ZZ2_DESC	:= "PLP Enviada"
		ZZ2->( MsUnLock() )

		//---------------------+
		// Posiciona Iten  PLP | 
		//---------------------+
		If ZZ4->( dbSeek(xFilial("ZZ4") + ZZ2->ZZ2_CODIGO) )
			While ZZ4->( !Eof() .And. xFilial("ZZ4") + ZZ2->ZZ2_CODIGO == ZZ4->ZZ4_FILIAL + ZZ4->ZZ4_CODIGO )
				//---------------------+
				// Atualiza Status PLP | 
				//---------------------+
				RecLock("ZZ4",.F.)
					ZZ4->ZZ4_PLPID	:= _cIDPlp 
					ZZ4->ZZ4_STATUS	:= "04"
					ZZ4->ZZ4_DESC	:= "PLP ENVIADA COM SUCESSO"
				ZZ4->( MsUnLock() )

				//---------------------------+	
				// Atualiza Status Orcamento |
				//---------------------------+
				If WSA->( dbSeek(xFilial("WSA") + ZZ4->ZZ4_NUMECO) )
					RecLock("WSA",.F.)
						WSA->WSA_ENVLOG := "4"
						WSA->WSA_CODSTA := "006"
						WSA->WSA_DESTAT := Posicione("WS1",1,xFilial("WS1") + "006","WS1_DESCRI")
						WSA->WSA_TRACKI	:= ZZ4->ZZ4_CODETQ
					WSA->( MsUnLock() )
				EndIf
				
				//------------------------+
				// Grava Status do Pedido |
				//------------------------+
				u_AEcoStaLog("006",WSA->WSA_NUMECO,WSA->WSA_NUM,Date(),Time())
				
				//----------------------------------------+
				// Envia invoice com o codigo de rastreio |
				//----------------------------------------+
				U_AECOI013(WSA->WSA_NUMECO)
													
				//--------------------------+
				// Atualiza status etiqueta |
				//--------------------------+
				If ZZ1->( dbSeek(xFilial("ZZ1") + ZZ4->ZZ4_NOTA + ZZ4->ZZ4_SERIE) )
					RecLock("ZZ1",.F.)
						ZZ1->ZZ1_PLPID := _cIDPlp
					ZZ1->( MsUnLock() )
				EndIf

				ZZ4->( dbSkip() )
			EndDo
		EndIf
	Else
		CoNout("<< SIGM004 >> - ERRO AO ENVIAR PLP " + _cCodPLP + " .")
		//---------------+
		// Posiciona PLP |
		//---------------+
		ZZ2->( dbGoTo(_nRecnoZZ2) )
		RecLock("ZZ2",.F.)
			ZZ2->ZZ2_STATUS	:= "03"
			ZZ2->ZZ2_DESC	:= "ERRO DE ENVIO"
		ZZ2->( MsUnLock() )

		//---------------------+
		// Posiciona Iten  PLP | 
		//---------------------+
		If ZZ4->( dbSeek(xFilial("ZZ4") + ZZ2->ZZ2_CODIGO) )
			While ZZ4->( !Eof() .And. xFilial("ZZ4") + ZZ2->ZZ2_CODIGO == ZZ4->ZZ4_FILIAL + ZZ4->ZZ4_CODIGO )
				//---------------------+
				// Atualiza Status PLP | 
				//---------------------+
				RecLock("ZZ4",.F.)
					ZZ4->ZZ4_STATUS	:= "03"
					ZZ4->ZZ4_DESC	:= "ERRO AO ENVIAR PLP"
				ZZ4->( MsUnLock() )

				ZZ4->( dbSkip() )
			EndDo
		EndIf
	EndIf
EndDo 

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return _lRet

/***************************************************************************/
/*/{Protheus.doc} nomeStaticFunction
	@description Consulta PLP a serem enviadas
	@type  Static Function
	@author Bernard M. Margarido
	@since 20/01/2030
/*/
/***************************************************************************/
Static Function SigM04Qry(_cAlias,_nToReg)
Local _cQuery 	:= ""

_cQuery := " SELECT " + CRLF
_cQuery += "	ZZ2.ZZ2_CODIGO, " + CRLF
_cQuery += "	ZZ4.ZZ4_CODETQ, " + CRLF
_cQuery += "	ZZ0.ZZ0_CODSER, " + CRLF
_cQuery += "	ZZ1.ZZ1_CODETQ, " + CRLF
_cQuery += "	ZZ1.ZZ1_SIGLA, " + CRLF
_cQuery += "	WSA.WSA_NOMDES, " + CRLF 
_cQuery += "	WSA.WSA_ENDENT, " + CRLF
_cQuery += "	WSA.WSA_BAIRRE, " + CRLF
_cQuery += "	WSA.WSA_MUNE, " + CRLF
_cQuery += "	WSA.WSA_CEPE, " + CRLF
_cQuery += "	WSA.WSA_ESTE, " + CRLF
_cQuery += "	WSA.WSA_COMPLE, " + CRLF
_cQuery += "	WSA.WSA_DOC, " + CRLF
_cQuery += "	WSA.WSA_SERIE, " + CRLF
_cQuery += "	WSA.WSA_VLRTOT,	" + CRLF
_cQuery += "	SU5.U5_DDD, " + CRLF
_cQuery += "	SU5.U5_FONE, " + CRLF
_cQuery += "	SU5.U5_CELULAR, " + CRLF
_cQuery += "	SU5.U5_CPF, " + CRLF
_cQuery += "	SC5.C5_VOLUME1, " + CRLF
_cQuery += "	SC5.C5_PBRUTO, " + CRLF
_cQuery += "	ZZ2.R_E_C_N_O_ RECNOZZ2 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("ZZ2") + " ZZ2 " + CRLF  
_cQuery += "	INNER JOIN " + RetSqlName("ZZ4") + " ZZ4 ON ZZ4.ZZ4_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ4.ZZ4_CODIGO = ZZ2.ZZ2_CODIGO AND ZZ4.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("WSA") + " WSA ON WSA.WSA_FILIAL = ZZ4.ZZ4_FILIAL AND WSA.WSA_NUMECO = ZZ4.ZZ4_NUMECO AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = WSA.WSA_FILIAL AND SC5.C5_NUM = WSA.WSA_NUMSC5 AND SC5.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("ZZ0") + " ZZ0 ON ZZ0.ZZ0_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ0.ZZ0_IDSER = ZZ4.ZZ4_CODSPO AND ZZ0.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("ZZ1") + " ZZ1 ON ZZ1.ZZ1_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ1.ZZ1_IDSER = ZZ0.ZZ0_IDSER AND ZZ1.ZZ1_NOTA = ZZ4.ZZ4_NOTA AND ZZ1.ZZ1_SERIE = ZZ4.ZZ4_SERIE AND ZZ1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SU5") + " SU5 ON SU5.U5_FILIAL = '  ' AND SU5.U5_XIDEND = WSA.WSA_IDENDE AND SU5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZ2.ZZ2_FILIAL = '" + xFilial("ZZ2") + "' AND " + CRLF
_cQuery += "	ZZ2.ZZ2_STATUS IN('01','03') AND " + CRLF
_cQuery += "	ZZ2.D_E_L_E_T_= '' " + CRLF
_cQuery += " GROUP BY ZZ2.ZZ2_CODIGO, ZZ4.ZZ4_CODETQ, ZZ0.ZZ0_CODSER, ZZ1.ZZ1_CODETQ, ZZ1.ZZ1_SIGLA, WSA.WSA_NOMDES, WSA.WSA_ENDENT, WSA.WSA_BAIRRE, WSA.WSA_MUNE, WSA.WSA_CEPE, WSA.WSA_ESTE, WSA.WSA_COMPLE, WSA.WSA_DOC, WSA.WSA_SERIE, WSA.WSA_VLRTOT, SU5.U5_DDD, SU5.U5_FONE, SU5.U5_CELULAR, SU5.U5_CPF, SC5.C5_VOLUME1, SC5.C5_PBRUTO, ZZ2.R_E_C_N_O_ " + CRLF
_cQuery += " ORDER BY ZZ2.ZZ2_CODIGO  "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg

dbSelectArea(_cAlias)
(_cAlias)->(dbGoTop() )

If (_cAlias)->( Eof() )
	(_cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.