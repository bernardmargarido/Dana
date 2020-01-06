#INCLUDE "PROTHEUS.CH"

Static nTCodServ:= TamSx3("ZZ0_CODSER")[1]

/****************************************************************************************/
/*/{Protheus.doc} SIGEPWEB
@description Funcoes correios SIGEPWEB
@author    Bernard M. Margarido
@since     06/12/2019
/*/
/****************************************************************************************/
Class SIGEPWEB 
	
	CoNout("<< SIGEPWEB >> - INICIO SIGEPWEB DATA " + dToc( Date() ) + " HORA " + Time() + " .")
	
	Data cIdContrato	As String
	Data cIdCartao		As String
	Data cIdUser		As String
	Data cIdPass		As String
	Data cIdPLP			As String
	Data cCodAdm		As String
	Data cUrlSigep		As String
	Data cError			As String
	Data cCodServ 		As String
	Data cIdServ		As String
	Data cDescServ		As String
	Data cNumOrc		As String
	Data cNumEco		As String
	Data cNumCli		As String
	Data cCodCli		As String
	Data cLoja			As String
	Data cTipoEtq		As String
	Data cCNPJId		As String
	Data cDigEtq		As String
	Data cEtiqueta		As String
	Data cXmlPLP		As String
	Data cNumDoc		As String
	Data cSerie			As String
	Data cDestinatario	As String
	Data cEndereco		As String
	Data cNumEnd		As String
	Data cBairro		As String
	Data cMunicipio		As String
	Data cUF			As String
	Data cCep			As String
	Data cDDD			As String 
	Data cTel			As String
	Data cHrIni			As String
	Data cHrFim			As String
	
	Data nAltura		As Double
	Data nLargura 		As Double 
	Data nComprimento	As Double
	Data nPesoLiquido	As Double 
	
	Data nQtdEtq		As Integer
	
	Data dDtIni			As Date
	Data dDtFim			As Date
	
	Data aFaixaPlp		As Array
	
	Data oSigWeb		As Object
	
	Method New() constructor
	Method GrvServico()
	Method GrvPlp()
	Method GrvCodEtq()
	Method GetDigEtq()
	Method GetXMLPlp()
	Method GetIdPLP()
	Method GetItemPLP()
	Method SetPLP()
		
	CoNout("<< SIGEPWEB >> - FIM SIGEPWEB DATA " + dToc( Date() ) + " HORA " + Time() + " .")
	
EndClass

/****************************************************************************************/
/*/{Protheus.doc} new
@description Metodo construtor da classe 
@author    Bernard M. Margarido
@since     06/12/2019
/*/
/****************************************************************************************/
Method New() Class SIGEPWEB
	
	CoNout("<< SIGEPWEB - NEW >> - INICIO DATA " + dToc( Date() ) + " HORA " + Time() + " .")
	
	::cIdContrato	:= GetNewPar("EC_CODCONT")
	::cIdCartao		:= GetNewPar("EC_IDCARTA")
	::cCodAdm		:= GetNewPar("EC_CODADM")
	::cIdUser		:= GetNewPar("EC_USERSIG")
	::cIdPass		:= GetNewPar("EC_PASSSIG")
	::cUrlSigep		:= GetNewPar("EC_URLSIGE")
	::cCNPJId		:= GetNewPar("EC_CNPJSIG")
	::cError		:= ""
	::cCodServ 		:= ""
	::cIdServ		:= ""
	::cDescServ		:= ""
	::cNumOrc		:= ""
	::cNumEco		:= ""
	::cNumCli		:= ""
	::cCodCli		:= ""
	::cLoja			:= ""
	::cTipoEtq		:= "C"		
	::cDigEtq		:= ""
	::cEtiqueta		:= ""
	::cXmlPLP		:= ""
	::cNumDoc		:= ""
	::cSerie		:= ""
	::cTracking		:= ""
	::cDestinatario	:= ""
	::cEndereco		:= ""
	::cNumEnd		:= ""
	::cBairro		:= ""
	::cMunicipio	:= ""
	::cUF			:= ""
	::cCep			:= ""
	::cDDD			:= "" 
	::cTel			:= ""
	::cHrIni		:= ""
	::cHrFim		:= ""
	
	::nAltura		:= 0
	::nLargura 		:= 0 
	::nComprimento	:= 0
	::nPesoLiquido	:= 0 
	
	::nQtdEtq		:= GetNewPar("EC_QTDETQ")
	
	::dDtIni		:= Nil 
	::dDtFim		:= Nil
	
	::aFaixaPlp		:= {}
	
	::oSigWeb		:= Nil
	
	CoNout("<< SIGEPWEB - NEW >> - FIM DATA " + dToc( Date() ) + " HORA " + Time() + " .")
	
Return Nil

/****************************************************************************************/
/*/{Protheus.doc} GrvServico
@description Consulta servicos disponiveis para envio do Sigep
@author Bernard M. Margarido
@since 06/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Method GrvServico() Class SIGEPWEB
Local _aArea	:= GetArea()

Local _lRet		:= .T.

Private _oResp	:= Nil

CoNout("<< SIGEPWEB - GETSERVICO >> - INICIO DATA " + dToc( Date() ) + " HORA " + Time() + " .")

//--------------------------+
// Instancia a classe SIGEP |
//--------------------------+
::oSigWeb := WSSigep():New

//-------------------------+
// Parametros BuscaCliente |
//-------------------------+
::oSigWeb:_Url				:= ::cUrlSigep
::oSigWeb:cIdContrato 		:= ::cIdContrato
::oSigWeb:cIdCartaoPostagem := ::cIdCartao
::oSigWeb:cUsuario 			:= ::cIdUser
::oSigWeb:cSenha 			:= ::cIdPass

//------------------------------+
// Seleciona tabela de servicos |
//------------------------------+
dbSelectArea("ZZ0")
ZZ0->( dbSetOrder(1) )

WsdlDbgLevel(3)
If ::oSigWeb:BuscaCliente()
	
	CoNout("<< SIGEPWEB - GETSERVICO >> - BUSCA CODIGO DOS SERVICOS CONTRATADOS.")
	
	//--------------------------+	
	// Valida se obteve retorno |
	//--------------------------+
	If ValType(_oResp) == "O"
				
		//------------------------------+
		// Valida retornou os contratos |
		//------------------------------+
		If ValType(_oResp:_Ns2_BuscaClienteResponse:_Return:_Contratos) == "O"
			
			CoNout("<< SIGEPWEB - GETSERVICO >> - GRAVA SERVICOS CONTRATADOS.")
			
			//-------------------------------+
			// Grava os servicos contratados |
			//-------------------------------+
			If ValType(_oResp:_Ns2_BuscaClienteResponse:_Return:_Contratos:_CartoesPostagem:_Servicos) == "A"
				For _nX := 1 To Len(_oResp:_Ns2_BuscaClienteResponse:_Return:_Contratos:_CartoesPostagem:_Servicos)
					
					::cCodServ 	:= PadR(_oResp:_Ns2_BuscaClienteResponse:_Return:_Contratos:_CartoesPostagem:_Servicos[_nX]:_Codigo:Text,nTCodServ)
					::cIdServ	:= _oResp:_Ns2_BuscaClienteResponse:_Return:_Contratos:_CartoesPostagem:_Servicos[_nX]:_Id:Text
					::cDescServ	:= _oResp:_Ns2_BuscaClienteResponse:_Return:_Contratos:_CartoesPostagem:_Servicos[_nX]:_Descricao:Text
					::dDtIni	:= sTod(SubStr(StrTran(_oResp:_Ns2_BuscaClienteResponse:_Return:_Contratos:_CartoesPostagem:_dataVigenciaInicio:Text,"-",""),1,8)) 
					::dDtFim	:= sTod(SubStr(StrTran(_oResp:_Ns2_BuscaClienteResponse:_Return:_Contratos:_CartoesPostagem:_dataVigenciaFim:Text,"-",""),1,8))
					
					CoNout("<< SIGEPWEB - GETSERVICO >> - SERVICOS CODIGO " + ::cCodServ + " IDSERVICO " + ::cIdServ + " DESCRICAO " + ::cDescServ + " ." )
															
					//----------------------------------------+
					// Grava somente servicos nao encontrados |
					//----------------------------------------+
					If !ZZ0->( dbSeek(xFilial("ZZ0") + ::cCodServ) )
						RecLock("ZZ0",.T.)
							ZZ0->ZZ0_FILIAL := xFilial("ZZ0")
							ZZ0->ZZ0_CODSER := ::cCodServ
							ZZ0->ZZ0_IDSER 	:= ::cIdServ
							ZZ0->ZZ0_DESCRI := ::cDescServ
							ZZ0->ZZ0_DTINI 	:= ::dDtIni
							ZZ0->ZZ0_DTFIM 	:= ::dDtFim
						ZZ0->( MsUnLock() )
					EndIf
				Next _nX
			EndIf
		EndIf
	Else
		CoNout("<< SIGEPWEB - GETSERVICO >> - GRAVA SERVICOS CONTRATADOS.")
		::cError := "ERRO AO RETORNAR SERVICOS CONTRATADOS"
		_lRet	:= .F.
	EndIf
Else
	_lRet	:= .F.
	::cError := "ERRO AO RETORNAR SERVICOS CONTRATADOS " + GetWscError()
EndIf

CoNout("<< SIGEPWEB - GETSERVICO >> - FIM DATA " + dToc( Date() ) + " HORA " + Time() + " .")

RestArea(_aArea)
Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} GrvPlp
@descrption Grava nota para envio de pre lista de postagem 
@author Bernard M. Margarido
@since 06/12/2019
@version 1.0

@type function
/*/
/****************************************************************************************/
Method GrvPlp() Class SIGEPWEB
Local _aArea	:= GetArea()

Local _lRet		:= .T.

CoNout("<< SIGEPWEB - GRVPLP >> - INICIO DATA " + dToc( Date() ) + " HORA " + Time() + " .")

//-------------------+
// Retorna ID da PLP |
//-------------------+
::GetIdPLP()

//-------------+
// Grava SIGEP |
//-------------+
dbSelectArea("ZZ2")
ZZ2->( dbSetOrder(1) )
If ZZ2->( dbSeek(xFilial("ZZ2") + ::cIdPLP) )
	::cError	:= "NOTA JA PERTENCE A PRE LISTA DE POSTAGEM " + ::cIdPLP +  ". "
	RestArea(_aArea)
	Return .F.
EndIf

CoNout("<< SIGEPWEB - GRVPLP >> - GRAVANDO PRE LISTA DE POSTAGEM " + ::cIdPLP + " .")

RecLock("ZZ2",.T.)
	ZZ2->ZZ2_FILIAL	:= xFilial("ZZ2") 
	ZZ2->ZZ2_PLPID  := ::cIdPLP
	ZZ2->ZZ2_STATUS := "01"
	ZZ2->ZZ2_DESC   := "PRE LISTA GERADA"
	ZZ2->ZZ2_DTINC 	:= ::dDtIni
	ZZ2->ZZ2_HRINC	:= ::cHrIni
	ZZ2->ZZ2_DTALT  := ::dDtFim
	ZZ2->ZZ2_HRALT 	:= ::cHrFim
ZZ2->( MsunLock() )

//------------------------+
// Posiciona Itens da PLP | 
//------------------------+
dbSelectArea("ZZ4")
ZZ4->( dbSetOrder(1) )
For _nX := 1 To Len(::aNotas)
	If !ZZ4->( dbSeek(xFilial("ZZ4") + ::cIdPLP + ::aNotas[_nX][1] + ::aNotas[_nX][2]))
		CoNout("<< SIGEPWEB - GRVPLP >> - GRAVANDO PRE LISTA DE POSTAGEM " + ::cIdPLP + " NOTA " + ::aNotas[_nX][1] + " SERIE " + ::aNotas[_nX][2] + "  .")
		
		//-----------------------------+
		// Retorna proximo item da PLP |
		//-----------------------------+
		::GetItemPLP()
		
		RecLock("ZZ4",.T.)
			ZZ4->ZZ4_FILIAL	:= xFilial("")
			ZZ4->ZZ4_ITEM  	:= ::cItemPlp
			ZZ4->ZZ4_PLPID 	:= ::cIdPLP
			ZZ4->ZZ4_NOTA  	:= ::aNotas[_nX][1]
			ZZ4->ZZ4_SERIE  := ::aNotas[_nX][2] 
			ZZ4->ZZ4_CLIENT	:= ::aNotas[_nX][3]
			ZZ4->ZZ4_LOJA  	:= ::aNotas[_nX][4]
			ZZ4->ZZ4_CODETQ	:= ::aNotas[_nX][5]
			ZZ4->ZZ4_CODSPO	:= ::aNotas[_nX][6]
			ZZ4->ZZ4_CODEMB	:= ::aNotas[_nX][7]
			ZZ4->ZZ4_NUMECO	:= ::aNotas[_nX][8]
			ZZ4->ZZ4_NUMECL	:= ::aNotas[_nX][9]
			ZZ4->ZZ4_NUMSC5	:= ::aNotas[_nX][10]
			ZZ4->ZZ4_STATUS	:= "01"
			ZZ4->ZZ4_DESC   := "AGUARDANDO ENVIO"	
		ZZ4->( MsUnLock() )
	EndIf
Next _nX

CoNout("<< SIGEPWEB - GRVPLP >> - FIM DATA " + dToc( Date() ) + " HORA " + Time() + " .")

RestArea(_aArea)
Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} GrvCodEtq
@description Realiza a reserva de etiquetas de acordo com os serviï¿½os contratados 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Method GrvCodEtq() Class SIGEPWEB
Local _aArea	:= GetArea()
Local _aEtq		:= {}

Local _nX		:= 0

Local _lRet		:= .T.

Private _oResp	:= Nil

CoNout("<< SIGEPWEB - GRVCODETQ >> - INICIO DATA " + dToc( Date() ) + " HORA " + Time() + " .")

//--------------------------+
// Instancia a classe SIGEP |
//--------------------------+
::oSigWeb := WSSigep():New

//------------------------------+
// Seleciona tabela de servicos |
//------------------------------+
dbSelectArea("ZZ1")
ZZ1->( dbSetOrder(1) )

//------------------------------+
// Seleciona tabela de servicos |
//------------------------------+
dbSelectArea("ZZ0")
ZZ0->( dbSetOrder(1) )
ZZ0->( dbGoTop() )

While ZZ0->( !Eof() )
	
	If !Empty(ZZ0->ZZ0_CODECO)	
	
		CoNout("<< SIGEPWEB - GRVCODETQ >> - SOLICITA EIQUETA SERVIï¿½O  " + RTrim(ZZ0->ZZ0_DESCRI) + " .")
		
		//-------------------------+
		// Parametros BuscaCliente |
		//-------------------------+
		::cIdServ					:= ZZ0->ZZ0_IDSER
		::cCodServ					:= ZZ0->ZZ0_CODSER
		
		//-------------------------+
		// Parametros BuscaCliente |
		//-------------------------+
		::oSigWeb:_Url				:= ::cUrlSigep
		::oSigWeb:cTipoDestinatario	:= ::cTipoEtq
		::oSigWeb:cIdentificador	:= ::cCNPJId
		::oSigWeb:nIdServico		:= Val(::cIdServ)
		::oSigWeb:nQtdEtiquetas		:= ::nQtdEtq
		::oSigWeb:cUsuario 			:= ::cIdUser
		::oSigWeb:cSenha 			:= ::cIdPass
				
		WsdlDbgLevel(3)
		If ::oSigWeb:SolicitaEtiquetas()
			If ValType(_oResp) == "O"
				If ValType(_oResp:_Ns2_SolicitaEtiquetasResponse:_Return:Text) == "C" .And. !Empty(_oResp:_Ns2_SolicitaEtiquetasResponse:_Return:Text)
					
					CoNout("<< SIGEPWEB - GRVCODETQ >> - ETIQUETAS SOLICITADAS COM SUCESSO .")
					
					_aEtq := Separa(_oResp:_Ns2_SolicitaEtiquetasResponse:_Return:Text,",")
					For _nX := 1 To Len(_aEtq)
						CoNout("<< SIGEPWEB - GRVCODETQ >> - GRAVA NOVAS ETIQUETAS " + _aEtq[_nX] + " .")
						
						RecLock("ZZ1",.T.)
							ZZ1->ZZ1_FILIAL := xFilial("SZ1")
							ZZ1->ZZ1_CODSER	:= ::cCodServ
							ZZ1->ZZ1_IDSER  := ::cIdServ
							ZZ1->ZZ1_CODETQ := SubStr(_aEtq[_nX],1,10)
							ZZ1->ZZ1_SIGLA  := SubStr(_aEtq[_nX],12)
						ZZ1->( MsUnLock() )
					Next _nX 
				Else
					CoNout("<< SIGEPWEB - GRVCODETQ >> - ERRO NA SOLICITACAO DE NOVAS ETIQUETAS.")
					::cError:= "ERRO NA SOLICITACAO DE NOVAS ETIQUETAS."
					_lRet	:= .F.
					
				EndIf				
			EndIf
		Else
			_lRet	:= .F.
			::cError:= "ERRO NA SOLICITACAO DE NOVAS ETIQUETAS. " + CRLF + GetWscError()
			CoNout("<< SIGEPWEB - GRVCODETQ >> - ERRO NA SOLICITACAO DE NOVAS ETIQUETAS." + GetWscError() )
		EndIf
	EndIf
	ZZ0->( dbSkip() )
EndDo

CoNout("<< SIGEPWEB - GRVCODETQ >> - FIM DATA " + dToc( Date() ) + " HORA " + Time() + " .")
RestArea(_aArea)
Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} GetDigEtq
@description Solicita digito verificador etiquetas
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Method GetDigEtq() Class SIGEPWEB
Local _aArea	:= GetArea()

Local _lRet		:= .T.

Private _oResp	:= Nil

CoNout("<< SIGEPWEB - GETDIGETQ >> - INICIO DATA " + dToc( Date() ) + " HORA " + Time() + " .")

//--------------------------+
// Instancia a classe SIGEP |
//--------------------------+
::oSigWeb := WSSigep():New

//-------------------------+
// Parametros BuscaCliente |
//-------------------------+
::oSigWeb:_Url				:= ::cUrlSigep
::oSigWeb:cEtiquetas		:= ::cEtiqueta
::oSigWeb:cUsuario 			:= ::cIdUser
::oSigWeb:cSenha 			:= ::cIdPass
		
WsdlDbgLevel(3)
If ::oSigWeb:GeraDigitoVerificadorEtiquetas()
	_lRet	:= .T.
	If ValType(oResp) == "O"
		If ValType(_oResp:_Ns2_GeraDigitoVerificadorEtiquetasResponse:_Return:Text) == "C" .And. !Empty(_oResp:_Ns2_GeraDigitoVerificadorEtiquetasResponse:_Return:Text)
			::cDigEtq := _oResp:_Ns2_GeraDigitoVerificadorEtiquetasResponse:_Return:Text
		Else
			_lRet	:= .F.
			::cError:= "NAO FORAM RETORANDAS ETIQUETAS"
			CoNout("<< SIGEPWEB - GETDIGETQ >> - NAO FORAM RETORANDAS ETIQUETAS" )
		EndIf				
	EndIf
Else
	_lRet	:= .F.
	::cError:= "ERRO AO GERAR DIGITO VERIFICADOR ETIQUETAS " + GetWscError()
	CoNout("<< SIGEPWEB - GETDIGETQ >> - ERRO AO GERAR DIGITO VERIFICADOR ETIQUETAS ." + GetWscError() )
EndIf

CoNout("<< SIGEPWEB - GETDIGETQ >> - FIM DATA " + dToc( Date() ) + " HORA " + Time() + " .")

RestArea(_aArea)
Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} SetPLP
@description Envia PLP para os correios 
@author Bernard M. Maragrido
@since 10/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Method SetPLP() Class SIGEPWEB
Local _aArea	:= GetArea()

Local _lRet		:= .T.

Private _oResp	:= Nil
Private _aFaixa	:= {}

CoNout("<< SIGEPWEB - SETPLP >> - INICIO DATA " + dToc( Date() ) + " HORA " + Time() + " .")

//--------------------------+
// Instancia a classe SIGEP |
//--------------------------+
::oSigWeb := WSSigep():New

//-------------------------+
// Parametros BuscaCliente |
//-------------------------+
::oSigWeb:_Url				:= ::cUrlSigep
::oSigWeb:cXml				:= ::cXmlPLP
::oSigWeb:nIdPlpCliente		:= ::cIdPLP
::oSigWeb:cCartaoPostagem	:= ::cIdCartao
::oSigWeb:cUsuario 			:= ::cIdUser
::oSigWeb:cSenha 			:= ::cIdPass

//---------------------------------------+
// Faixa de etiquetas para envio SIGEWEB |
//---------------------------------------+
_aFaixa						:= aClone(::aFaixaPlp)

//----------------------------------------------+
// Posiciona tabela de faixa de etiquetas SIGEP |
//----------------------------------------------+ 
dbSelectArea("ZZ1")
ZZ1->( dbSetOrder(3))

//----------------------------+
// Posiciona tabela PLP SIGEP |
//----------------------------+
dbSelectArea("ZZ2")
ZZ2->( dbSetOrder(1))

//---------------------+
// Posiciona Orcamento |
//---------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(1) )

//------------------------------------+
// Envia registro de PLP para o SIGEP |
//------------------------------------+		
If ::oSigWeb:fechaPlpVariosServicos()
	
	//------------------------------------------+
	// Valida se PLP foi registrada com sucesso |
	//------------------------------------------+
	If ValType(_oResp) == "O"
		If ValType(_oResp:_NS2_FechaPlpVariosServicosResponse:_Return:Text) == "C" .And. !Empty(_oResp:_NS2_FechaPlpVariosServicosResponse:_Return:Text)
			CoNout("<< SIGEPWEB - SETPLP >> - PLP ENVIADA COM SUCESSO .")	
			//---------------------+
			// Atualiza Tabela PLP |
			//---------------------+
			If Len(::aFaixaPlp) > 0
				For _nX := 1 To Len(::aFaixaPlp)
					
					CoNout("<< SIGEPWEB - SETPLP >> - ATUALIZANDO STATUS PLP.")
					
					If ZZ2->( dbSeek(xFilial("ZZ2") + ::aFaixaPlp[_nX][2]) )
						RecLock("ZZ2",.F.)
							ZZ2->ZZ2_PLPID := _oResp:_NS2_FechaPlpVariosServicosResponse:_Return:Text
							ZZ2->ZZ2_STATUS:= "04"
						ZZ2->( MsUnLock() )	
					EndIf
					
					//---------------------+
					// Posiciona Orcamento |
					//---------------------+					
					WSA->( dbSeek(xFilial("WSA") + ZZ2->ZZ2_NUMECO) )
					
					//-----------------------------+
					// Atualiza faixa de etiquetas |
					//-----------------------------+
					If ZZ1->( dbSeek(xFilial("ZZ1") + WSA->WSA_DOC + WSA->WSA_SERIE) )
						RecLock("ZZ1",.F.)
							ZZ1->ZZ1_PLPID := oResp:_NS2_FechaPlpVariosServicosResponse:_Return:Text
						ZZ1->( MsUnLock() )	
					EndIf
					
				Next _nX
			EndIf
		Else
			CoNout("<< SIGEPWEB - SETPLP >> - ERRO AO GERAR PLP .")
			_lRet	:= .F.
		EndIf
	Else
		_lRet	:= .F.
		CoNout("<< SIGEPWEB - SETPLP >> - ERRO AO GERAR PLP " + GetWscError() + " .")
	EndIf
Else
	CoNout("<< SIGEPWEB - SETPLP >> - ERRO AO GERAR PLP " + GetWscError() + " .")
	_lRet := .F.
EndIf

//------------------------------+
// Caso de erro no envio da PLP |
//------------------------------+
If !lRet 
	//---------------------+
	// Atualiza Tabela PLP |
	//---------------------+
	If Len(::aFaixaPlp) > 0
		For _nX := 1 To Len(::aFaixaPlp)
			ZZ2->( dbSetOrder(1))
			If ZZ2->( dbSeek(xFilial("ZZ2") + ::aFaixaPlp[nFxEtq][2]) )
				RecLock("ZZ2",.F.)
					ZZ2->ZZ2_STATUS:= "03"
				ZZ2->( MsUnLock() )	
			EndIf
		Next _nX
	EndIf
EndIf

RestArea(aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} GetIdPLP
@description Retorna ID deidentificação da PLP 
@author Bernard M. Margarido
@since 10/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Method GetIdPLP() Class SIGEPWEB 
Local _cAlias 	:= GetNextAlias()
Local _cQuery	:= ""

If Empty(::cIdPLP)
	
	_cQuery	:= " SELECT " + CRLF
	_cQuery	+= " 	COALESCE(MAX(ZZ2_PLPID),'0000000000') PLPID " + CRLF
	_cQuery	+= " FROM " + CRLF
	_cQuery	+= "	" + RetSqlName("ZZ2") + " ZZ2 " + CRLF
	_cQuery	+= " WHERE " + CRLF
	_cQuery	+= "	ZZ2.ZZ2_FILIAL = '" + xFilial("ZZ2") + "' AND " + CRLF
	_cQuery	+= "	ZZ2.D_E_L_E_T = '' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
	
	::cIdPLP	:= Soma1((_cAlias)->PLPID)
	
	(_cAlias)->( dbCloseArea() )
	
EndIf

Return Nil

/****************************************************************************************/
/*/{Protheus.doc} GetItemPLP
@description Retorna item notas da PLP 
@author Bernard M. Margarido
@since 10/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Method GetItemPLP() Class SIGEPWEB
Local _cAlias	:= GetNextAlias()
Local _cQuery 	:= ""

Local _cAlias 	:= GetNextAlias()
Local _cQuery	:= ""

_cQuery	:= " SELECT " + CRLF
_cQuery	+= " 	COALESCE(MAX(ZZ4_ITEM),'000') ITEMPLP " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= "	" + RetSqlName("ZZ4") + " ZZ4 " + CRLF
_cQuery	+= " WHERE " + CRLF	
_cQuery	+= "	ZZ4.ZZ4_FILIAL = '" + xFilial("ZZ4") + "' AND " + CRLF
_cQuery	+= "	ZZ4.ZZ4_PLPID = '" + ::cIdPLP  + "' AND " + CRLF
_cQuery	+= "	ZZ4.D_E_L_E_T = '' " 
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
	
::cItemPlp	:= Soma1((_cAlias)->ITEMPLP)
	
(_cAlias)->( dbCloseArea() )

Return Nil

/****************************************************************************************/
/*/{Protheus.doc} GetXMLPlp
@description Gera XML para envio da PLP 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0

@type function
/*/
/****************************************************************************************/
Method GetXMLPlp() Class SIGEPWEB
Local _aArea	:= GetArea()

Local _cXml		:= ""

Local _lRet		:= .T.

//---------------------------------+
// Realiza a reserva das etiquetas |
//---------------------------------+
_cXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'
_cXml += '<correioslog>'

//--------------------+
// Dados do Remetente | 
//--------------------+
_cXml	+= XmlPlpRem()

//--------------------+
// Dados Destinatario |
//--------------------+
_cXml	+= XmlPlpDes()

_cXml += '</correioslog>'

//------------------------------+
// Grava XML variavel da classe |
//------------------------------+
::cXmlPLP	:= _cXml

Return .T.

/****************************************************************************************/
/*/{Protheus.doc} XmlPlpRem
@description XML PLP de Remessa 
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0

@type function
/*/
/****************************************************************************************/
Static Function XmlPlpRem()
Local _cXmlRem		:= ""

_cXmlRem += TagXml("tipo_arquivo","Postagem")
_cXmlRem += TagXml("versao_arquivo","2.3")

_cXmlRem += '<plp>'
_cXmlRem += TagXml("id_plp")
_cXmlRem += TagXml("valor_global")
_cXmlRem += TagXml("mcu_unidade_postagem")
_cXmlRem += TagXml("nome_unidade_postagem")
_cXmlRem += TagXml("cartao_postagem",::cIdCartao)
_cXmlRem += '</plp>'

_cXmlRem += '<remetente>'
_cXmlRem += TagXml("numero_contrato",RTrim(::cIdContrato))
_cXmlRem += TagXml("numero_diretoria","14")
_cXmlRem += TagXml("codigo_administrativo",::cCodAdm)
_cXmlRem += TagXml("nome_remetente",SubStr(RTrim(SM0->M0_NOMECOM),1,50),.T.)
If At(",",SM0->M0_ENDCOB) > 0 
	_cXmlRem += TagXml("logradouro_remetente",SubStr(RTrim(SM0->M0_ENDCOB),1,At(",",SM0->M0_ENDCOB) - 1),.T.)
	_cXmlRem += TagXml("numero_remetente",SubStr(RTrim(SM0->M0_ENDCOB),At(",",SM0->M0_ENDCOB) + 1))
Else
	_cXmlRem += TagXml("logradouro_remetente",RTrim(SM0->M0_ENDCOB),.T.)
	_cXmlRem += TagXml("numero_remetente","S/N")
EndIf	

_cXmlRem += TagXml("complemento_remetente",RTrim(SM0->M0_COMPCOB),.T.)
_cXmlRem += TagXml("bairro_remetente",RTrim(SM0->M0_BAIRCOB),.T.)
_cXmlRem += TagXml("cep_remetente",RTrim(SM0->M0_CEPCOB))
_cXmlRem += TagXml("cidade_remetente",RTrim(SM0->M0_CIDCOB),.T.)
_cXmlRem += TagXml("uf_remetente",SM0->M0_ESTCOB)
_cXmlRem += TagXml("telefone_remetente",RTrim(u_EcFormat(SM0->M0_TEL,"A1_TEL",.T.,"C")),.T.)
_cXmlRem += TagXml("fax_remetente")
_cXmlRem += TagXml("email_remetente")
_cXmlRem += '</remetente>'

_cXmlRem += TagXml("forma_pagamento")

Return _cXmlRem

/****************************************************************************************/
/*/{Protheus.doc} XmlPlpDes
@description Xml PLP de destinatario
@author Ana Carolina
@since 08/12/2019
@version 1.0

@type function
/*/
/****************************************************************************************/
Static Function XmlPlpDes()
Local _cXmlDest		:= ""

_cXmlDest += '<objeto_postal>'
_cXmlDest += TagXml("numero_etiqueta",RTrim(::cEtiqueta))
_cXmlDest += TagXml("codigo_objeto_cliente")
_cXmlDest += TagXml("codigo_servico_postagem",RTrim(::cIdServ))
_cXmlDest += TagXml("cubagem","0,00")
_cXmlDest += TagXml("peso",xConvCpo(::nPesoLiquido)
_cXmlDest += TagXml("rt1")
_cXmlDest += TagXml("rt2")

_cXmlDest += '<destinatario>'
_cXmlDest += TagXml("nome_destinatario",SubStr(::cDestinatario,1,50),.T.)
_cXmlDest += TagXml("telefone_destinatario",RTrim(WSA->WSA_DDD01) + RTrim(WSA->WSA_TEL01),.T.)
_cXmlDest += TagXml("celular_destinatario")
_cXmlDest += TagXml("email_destinatario")

_cXmlDest += TagXml("logradouro_destinatario",SubStr(::cEndereco,1,50),.T.)
_cXmlDest += TagXml("complemento_destinatario")
_cXmlDest += TagXml("numero_end_destinatario",IIF(Empty(::cNumEnd),"S/N",RTrim(::cNumEnd)),.T.)

_cXmlDest += '</destinatario>'

_cXmlDest += '<nacional>'
_cXmlDest += TagXml("bairro_destinatario",RTrim(::cBairro,.T.)
_cXmlDest += TagXml("cidade_destinatario",RTrim(::cMunicipio),.T.)
_cXmlDest += TagXml("uf_destinatario",::cUF)
_cXmlDest += TagXml("cep_destinatario",RTrim(::cCep),.T.)
_cXmlDest += TagXml("codigo_usuario_postal")
_cXmlDest += TagXml("centro_custo_cliente")
_cXmlDest += TagXml("numero_nota_fiscal",RTrim(Str(Val(::cNumDoc))))
_cXmlDest += TagXml("serie_nota_fiscal",::cSerie)
_cXmlDest += TagXml("valor_nota_fiscal")
_cXmlDest += TagXml("natureza_nota_fiscal")
_cXmlDest += TagXml("descricao_objeto","",.T.)
_cXmlDest += TagXml("valor_a_cobrar","0,00")
_cXmlDest += '</nacional>'
_cXmlDest += '<servico_adicional>'
_cXmlDest += TagXml("codigo_servico_adicional","025")
_cXmlDest += TagXml("valor_declarado")
_cXmlDest += "</servico_adicional>"
_cXmlDest += "<dimensao_objeto>"
_cXmlDest += TagXml("tipo_objeto","002")
_cXmlDest += TagXml("dimensao_altura",xConvCpo(::nAltura))
_cXmlDest += TagXml("dimensao_largura",xConvCpo(::nLargura))
_cXmlDest += TagXml("dimensao_comprimento",xConvCpo(::nComprimento))
_cXmlDest += TagXml("dimensao_diametro","0")
_cXmlDest += '</dimensao_objeto>'
_cXmlDest += TagXml("data_postagem_sara")
_cXmlDest += TagXml("status_processamento","0")
_cXmlDest += TagXml("numero_comprovante_postagem")
_cXmlDest += TagXml("valor_cobrado")
_cXmlDest += '</objeto_postal>'

Return _cXmlDest

/****************************************************************************************/
/*/{Protheus.doc} TagXml
@description Monta TAG XML PLP
@author Ana Carolina
@since 08/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Static Function TagXml(_cTagName,xConteud,_lCData)
Local 	_cTagXml	:= ""

Default _xConteud	:= ""
Default _lCData 	:= .F.

//-----------------------------------+
// Valida o tipo do conteudo passado |
//-----------------------------------+
If ValType(_xConteud) == "N"
	_xConteud := StrTran(Alltrim(Str(_xConteud)),".",",")
ElseIf ValType(_xConteud) == "D"
	_xConteud := dToC(_xConteud)
EndIf

If _lCData .And. !Empty(_xConteud)
	_cTagXml := "<" + _cTagName + "><![CDATA[" + _xConteud + "]]></" + _cTagName + ">"
ElseIf !_lCData .And. !Empty(_xConteud)
	_cTagXml := "<" + _cTagName + ">" + _xConteud + "</" + _cTagName + ">"
ElseIf Empty(_xConteud) 
	_cTagXml := "<" + _cTagName + "/>"
EndIf

Return _cTagXml 

/****************************************************************************************/
/*/{Protheus.doc} xConvCpo
@description Converte valor em caracter
@author Bernard M. Margarido
@since 08/12/2019
@version 1.0

@type function
/*/
/****************************************************************************************/
Static Function xConvCpo(xValor)
Return Alltrim(Str(xValor * 100)) 