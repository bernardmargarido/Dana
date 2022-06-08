#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _nTCnpj := TamSx3("A1_CGC")[1]

/***********************************************************************************/
/*/{Protheus.doc} MDLOGM03
    @description Envia lista de postagem DLog
    @type  Function
    @author Bernard M. Margarido
    @since 05/01/2021
/*/
/***********************************************************************************/
User Function MDLOGM03()
Local   _lRet       := .T.

Private _lJob       := IIF(Isincallstack("U_DLOGM01"),.T.,.F.)

Private _aPLP       := {}

Private _oProcess   := Nil

CoNout("<< MDLOGM03 >> - INICIO " + dTos( Date() ) + " - " + Time() )

If _lJob
    _lRet := MDLOGM03A()
Else
    Processa({|| _lRet := MDLOGM03A()},"Aguarde...","Enviando coleta para MDTransLog." )
EndIf

CoNout("<< MDLOGM03 >> - FIM " + dTos( Date() ) + " - " + Time() )
Return _lRet 

/***********************************************************************************/
/*/{Protheus.doc} MDLOGM03A
    @description Realiza o envio das postagens 
    @type  Static Function
    @author Bernard M. Margarido
    @since 05/01/2021
/*/
/***********************************************************************************/
Static Function MDLOGM03A()
Local _aArea	:= GetArea()

Local _cAlias	:= GetNextAlias()
Local _cCodPLP	:= ""
Local _cExpress	:= GetNewPar("DN_TRANEXP","1056")
Local _cCnpjEmb := GetNewPar("DN_CGCEMBA","61105722000103")

Local _nToReg	:= 0
Local _nRecnoZZB:= 0

Local _lRet		:= .T.

Local _oDLog	:= MDLog():New()
Local _oJSon	:= Nil 
Local _oNota	:= Nil 
Local _oLista	:= Nil 
Local _oItensNF	:= Nil 
Local _oVolumeNF:= Nil 

//-------------------+
// Consulta Postagem |
//-------------------+
If !MDLOGM03Qry(_cAlias,@_nToReg)
	If _lJob
		MsgStop("Não existem dados para serem enviados.","Aviso")
	EndIf
	ConOut(" << MDLOGM03 >> - NAO EXISTEM DADOS PARA SEREM ENVIADOS.")	
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

//---------------------+
// SD2 - Itens da Nota |
//---------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )

//---------------+
// SB1 - Produto |
//---------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//------------------------------+
// SB5 - Complemento de Produto |
//------------------------------+
dbSelectArea("SB5")
SB5->( dbSetOrder(1) )

//-----------------------------+
// Array contento as Etiquetas |
//-----------------------------+
While (_cAlias)->( !Eof() )

	_cRest		:= ""
	_cCodPLP 	:= (_cAlias)->ZZB_CODIGO
	_nRecnoZZB	:= (_cAlias)->RECNOZZB

	CoNout("<< MDLOGM03 >> - ENVIANDO COLETA " + _cCodPLP)

	_oJSon							:= Nil 
	_oJSon							:= Array(#)
	_oJSon[#"cnpjEmbarcadorOrigem"]	:= RTrim(_cCnpjEmb)
	_oJSon[#"listaSolicitacoes"]	:= {}

	While (_cAlias)->( !Eof() .And. _cCodPLP == (_cAlias)->ZZB_CODIGO )

		//------------------------------------------------------+
		// Cria JSON somente de itens não enviados ou com erros |
		//------------------------------------------------------+
		If 	(_cAlias)->ZZB_STATUS $ "1/3"
		
			aAdd(_oJSon[#"listaSolicitacoes"],Array(#))
			_oLista := aTail(_oJSon[#"listaSolicitacoes"])	
			_oLista[#"idSolicitacaoInterno"] 	:= RTrim((_cAlias)->ZZC_NOTA) + RTrim((_cAlias)->ZZC_SERIE)
			_oLista[#"idServico"] 				:= IIF(RTrim((_cAlias)->F2_TRANSP) == _cExpress, 8, 4)
			_oLista[#"flagLiberacaoEmbarcador"] := Nil 
			_oLista[#"dtPrazoInicio"]			:= Nil 		
			_oLista[#"dtPrazoFim"]				:= Nil 

			_oLista[#"Remetente"]												:= Array(#) 
			_oLista[#"Remetente"][#"cpf"]										:= Nil
            _oLista[#"Remetente"][#"cnpj"]										:= RTrim(SM0->M0_CGC)
            _oLista[#"Remetente"][#"inscricaoEstadual"]							:= RTrim(SM0->M0_INSC)
            _oLista[#"Remetente"][#"nome"]										:= RTrim(SM0->M0_NOME)
            _oLista[#"Remetente"][#"razaoSocial"]								:= RTrim(SM0->M0_NOMECOM)
            _oLista[#"Remetente"][#"telefone"]									:= RTrim(SM0->M0_TEL)
            _oLista[#"Remetente"][#"email"]										:= Nil
            _oLista[#"Remetente"][#"Endereco"]									:= Array(#)	
            _oLista[#"Remetente"][#"Endereco"][#"cep"]							:= SM0->M0_CEPCOB
            _oLista[#"Remetente"][#"Endereco"][#"logradouro"]					:= SubStr(SM0->M0_ENDCOB, 1, At(",",SM0->M0_ENDCOB) - 1)
            _oLista[#"Remetente"][#"Endereco"][#"numero"]						:= Alltrim(SubStr(SM0->M0_ENDCOB,At(",",SM0->M0_ENDCOB) + 1))
            _oLista[#"Remetente"][#"Endereco"][#"complemento"]					:= RTrim(SM0->M0_COMPCOB)
            _oLista[#"Remetente"][#"Endereco"][#"pontoReferencia"]				:= Nil
            _oLista[#"Remetente"][#"Endereco"][#"bairro"]						:= RTrim(SM0->M0_BAIRCOB)
            _oLista[#"Remetente"][#"Endereco"][#"nomeCidade"]					:= RTrim(SM0->M0_CIDCOB)
            _oLista[#"Remetente"][#"Endereco"][#"siglaEstado"]					:= SM0->M0_ESTCOB
            _oLista[#"Remetente"][#"Endereco"][#"idCidadeIBGE"]					:= SM0->M0_CODMUN
			_oLista[#"Destinatario"]											:= Array(#)		
			_oLista[#"Destinatario"][#"cpf"]									:= IIF( (_cAlias)->A1_PESSOA == "F",,Nil)
            _oLista[#"Destinatario"][#"cnpj"]									:= IIF( (_cAlias)->A1_PESSOA == "F",Nil,(_cAlias)->A1_CGC)
            _oLista[#"Destinatario"][#"inscricaoEstadual"]						:= IIF( (_cAlias)->A1_PESSOA == "F", Nil, RTrim((_cAlias)->A1_INSCR))
            _oLista[#"Destinatario"][#"nome"]									:= RTrim((_cAlias)->WSA_NOMDES)
            _oLista[#"Destinatario"][#"razaoSocial"]							:= IIF( (_cAlias)->A1_PESSOA == "F", Nil, (_cAlias)->A1_NOME)
            _oLista[#"Destinatario"][#"telefone"]								:= RTrim((_cAlias)->WSA_TEL01)
            _oLista[#"Destinatario"][#"email"]									:= RTrim((_cAlias)->A1_EMAIL)
            _oLista[#"Destinatario"][#"Endereco"]								:= Array(#)	
            _oLista[#"Destinatario"][#"Endereco"][#"cep"]						:= (_cAlias)->WSA_CEPE
            _oLista[#"Destinatario"][#"Endereco"][#"logradouro"]				:= SubStr((_cAlias)->WSA_ENDENT, 1, At(",",(_cAlias)->WSA_ENDENT) - 1)
            _oLista[#"Destinatario"][#"Endereco"][#"numero"]					:= RTrim((_cAlias)->WSA_ENDNUM)
            _oLista[#"Destinatario"][#"Endereco"][#"complemento"]				:= RTrim((_cAlias)->WSA_COMPLE)
            _oLista[#"Destinatario"][#"Endereco"][#"pontoReferencia"]			:= RTrim((_cAlias)->WSA_REFEN)
            _oLista[#"Destinatario"][#"Endereco"][#"bairro"]					:= RTrim((_cAlias)->WSA_BAIRRE)
            _oLista[#"Destinatario"][#"Endereco"][#"nomeCidade"]				:= RTrim((_cAlias)->WSA_MUNE)
            _oLista[#"Destinatario"][#"Endereco"][#"siglaEstado"]				:= (_cAlias)->WSA_ESTE
            _oLista[#"Destinatario"][#"Endereco"][#"idCidadeIBGE"]				:= Nil 
			_oLista[#"Expedidor"]												:= Nil 
			_oLista[#"LogisticaReversa"]										:= Nil 
         	_oLista[#"DadosAgendamento"]										:= Nil 

			_oLista[#"listaOperacoes"]											:= {}
			aAdd(_oLista[#"listaOperacoes"],Array(#))
			_oNota := aTail(_oLista[#"listaOperacoes"])
			_oNota[#"nroNotaFiscal"]											:= Val((_cAlias)->ZZC_NOTA)
            _oNota[#"serieNotaFiscal"]											:= Val((_cAlias)->ZZC_SERIE)
            _oNota[#"dtEmissaoNotaFiscal"]										:= FWTimeStamp(3,sTod((_cAlias)->F2_DAUTNFE),Time())
			_oNota[#"chaveNotaFiscal"]											:= RTrim((_cAlias)->F2_CHVNFE)
			_oNota[#"nroCarga"]													:= Nil 
			_oNota[#"nroPedido"]												:= RTrim((_cAlias)->ZZC_NUMSC5)
			_oNota[#"nroEntrega"]												:= Nil 
			_oNota[#"qtdeVolumes"]												:= (_cAlias)->F2_VOLUME1
			_oNota[#"qtdeItens"]												:= (_cAlias)->TOTAL_ITENS
			_oNota[#"pesoTotal"]												:= (_cAlias)->F2_PBRUTO
			_oNota[#"cubagemTotal"]												:= Nil
			_oNota[#"valorMercadoria"]											:= (_cAlias)->F2_VALMERC
			_oNota[#"valorICMS"]												:= (_cAlias)->F2_VALICM
			_oNota[#"valorPendenteCompra"]										:= Nil
			
			_oNota[#"listaVolumes"]												:= {}
			_oNota[#"listaItens"]												:= {}

			If SD2->( dbSeek(xFilial("SD2") + (_cAlias)->ZZC_NOTA + (_cAlias)->ZZC_SERIE))
				While SD2->( !Eof() .And. xFilial("SD2") + (_cAlias)->ZZC_NOTA + (_cAlias)->ZZC_SERIE == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE )
					aAdd(_oNota[#"listaItens"],Array(#))
					_oItensNF := aTail(_oNota[#"listaItens"])

					aAdd(_oNota[#"listaVolumes"],Array(#))
					_oVolumeNF := aTail(_oNota[#"listaVolumes"])

					//-------------------+	
					// Posiciona produto |
					//-------------------+		
					SB1->( dbSeek(xFilial("SB1") + SD2->D2_COD) )

					//----------------------------------+	
					// Posiciona complemento de produto |
					//----------------------------------+		
					SB5->( dbSeek(xFilial("SB5") + SD2->D2_COD) )

					//--------------+
					// Lista Volume |
					//--------------+
					_oVolumeNF[#"idVolume"]			:= Nil 
                    _oVolumeNF[#"nroEtiqueta"]		:= RTrim((_cAlias)->ZZC_NUMSC5)
                    _oVolumeNF[#"codigoBarras"]		:= SB1->B1_EAN
                    _oVolumeNF[#"pesoVolume"]		:= SB1->B1_PESBRU
                    _oVolumeNF[#"cubagemVolume"]	:= Nil
                    _oVolumeNF[#"altura"]			:= Nil 
                    _oVolumeNF[#"largura"]			:= Nil 
                    _oVolumeNF[#"comprimento"]		:= Nil 
                    _oVolumeNF[#"descricaoVolumes"] := Nil 

					//-------------+
					// Lista Itens |
					//-------------+
					_oItensNF[#"idItem"]			:= Nil 
					_oItensNF[#"nroEtiqueta"]		:= RTrim((_cAlias)->ZZC_NUMSC5)
					_oItensNF[#"codigoItem"]		:= SD2->D2_COD
					_oItensNF[#"descricaoItem"]		:= RTrim(SB5->B5_XNOMPRD)
					_oItensNF[#"tipoItem"]			:= "UN"
					_oItensNF[#"qtde"]				:= SD2->D2_QUANT

					SD2->( dbSkip() )
				EndDo 
			EndIf 

			_oLista[#"linkCTe"]						:= Nil 
         	_oLista[#"base64CTe"]					:= Nil 
         	_oLista[#"xmlCTeAnterior"]				:= Nil 
         	_oLista[#"chaveCTeAnterior"]			:= Nil 

		EndIf	 

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
/*/{Protheus.doc} MDLOGM03Qry
	@description Consulta postagens da Dlog
	@type  Static Function
	@author Bernard M. Margarido
	@since 06/01/2021
/*/
/***********************************************************************************/
Static Function MDLOGM03Qry(_cAlias,_nToReg)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	ZZB.ZZB_CODIGO, " + CRLF
_cQuery += "	ZZC.ZZC_ITEM, " + CRLF
_cQuery += "	ZZC.ZZC_NOTA, " + CRLF
_cQuery += "	ZZC.ZZC_SERIE, " + CRLF
_cQuery += "	ZZC.ZZC_NUMECO, " + CRLF
_cQuery += "	ZZC.ZZC_NUMSC5, " + CRLF
_cQuery += "	F2.F2_CHVNFE, " + CRLF
_cQuery += "	F2.F2_DAUTNFE, " + CRLF 
_cQuery += "	F2.F2_HAUTNFE, " + CRLF
_cQuery += "	F2.F2_VALMERC, " + CRLF
_cQuery += "	F2.F2_VALBRUT, " + CRLF
_cQuery += "	F2.F2_VOLUME1, " + CRLF
_cQuery += "	F2.F2_PLIQUI, " + CRLF
_cQuery += "	F2.F2_PBRUTO, " + CRLF
_cQuery += "	F2.F2_VALICM, " + CRLF
_cQuery += "	F2.F2_TRANSP, " + CRLF
_cQuery += "	ITENS.TOTAL_ITENS, " + CRLF
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
_cQuery += "	ZZB.ZZB_STATUS, " + CRLF
_cQuery += "	ZZB.R_E_C_N_O_ RECNOZZB, " + CRLF
_cQuery += "	ZZC.R_E_C_N_O_ RECNOZZC " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("ZZB") + " ZZB " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("ZZC") + " ZZC ON ZZC.ZZC_FILIAL = ZZB.ZZB_FILIAL AND ZZC.ZZC_CODIGO = ZZB.ZZB_CODIGO AND ZZC.ZZC_STATUS IN('1','3') AND ZZC.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("WSA") + " WSA ON WSA.WSA_FILIAL = ZZC.ZZC_FILIAL AND WSA.WSA_NUMECO = ZZC.ZZC_NUMECO AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = WSA.WSA_CLIENT AND A1.A1_LOJA = WSA.WSA_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SF2") + " F2 ON F2.F2_FILIAL = ZZC.ZZC_FILIAL AND F2.F2_DOC = ZZC.ZZC_NOTA AND F2.F2_SERIE = ZZC.ZZC_SERIE AND F2.F2_CLIENTE = A1.A1_COD AND F2.F2_LOJA = A1.A1_LOJA AND F2.F2_CHVNFE <> '' AND F2.F2_FIMP = 'S' AND F2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " 	CROSS APPLY( " + CRLF
_cQuery += "				SELECT " + CRLF
_cQuery += "					COUNT(D2_ITEM) TOTAL_ITENS " + CRLF
_cQuery += "				FROM " + CRLF
_cQuery += "					" + RetSqlName("SD2") + " D2 " + CRLF 
_cQuery += "				WHERE " + CRLF
_cQuery += "					D2.D2_FILIAL = F2.F2_FILIAL AND " + CRLF
_cQuery += "					D2.D2_DOC = F2.F2_DOC AND " + CRLF
_cQuery += "					D2.D2_SERIE = F2.F2_SERIE AND " + CRLF
_cQuery += "					D2.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	)ITENS " + CRLF
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
