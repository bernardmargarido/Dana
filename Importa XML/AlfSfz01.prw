#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} AlfSfz01()
Rotina que irá realizar as requisições ao WebService da SEFAZ responsável por capturar a chave da NFe.
@type  Function
@author user: Valdemir José Rabelo
@since date:  02/10/2017
@version version
@param param, param_type, param_descr
cServico: 
1-Pesquisa Chaves Destinatário
2-Ciência XML
3-Download XML
4-Aceite XML
5-Desconhecimento XML
6-Operação não realizada XML

aParam:   array com os parâmetros necessários
@return oRet: Retorno XML
@example
(examples)
@see (links_or_references)
/*/
User Function AlfSfz01(cServico, aParam, oRet, _cEmp, _cFil)
	Local   cResposta := ""
	Local   lRet      := .F.
	Local 	lGo		  := .F.
	Local   _cCertif  := ""
	Local   _cPrivKey := ""
	Local   _cPass	  := ""
	Local   _cUf      := ""
	Local   _cCNPJ    := ""
	Local   _cChave   := ""
	Local   _cTpOper  := ""//  210200=Confirmação da Operação / 210210=Ciência da Operação / 210220=Desconhecimento da Operação / 210240=Operação não Realizada
	Local   cUltNSU   := ""
	Local   _cJusti   := ""
	Local   cSubj     := ""
	Local   cBody     := ""
	Local   cToClNFe  := SuperGetMV("AF_MAILXML",,"")
	Local   cPsqCTe   := SuperGetMV("AF_PXMLCTE",,"S")
	Local   cPsqNFe   := SuperGetMV("AF_PXMLNFE",,"N")
	Local   cDbgCte	  := SuperGetMV("AF_MDBGCTE",,"N")
	
	Default cServico  := ""
	Default _cEmp     := ""
	Default _cFil     := ""
	
	Private lProducao := SuperGetMV("CR_XMLPROD",,.T.)

	oRet := nil

	_cCNPJ 	:= aParam[1]
	_cUf 	:= aParam[2]

	//Modo Debug para CTE - gravar monitor e incluir pre-nota
	//a tabela ZDI deve possuir dados do tipo CTEPROC
	If cDbgCTe == "S"
		U_AtMnCte(_cCNPJ)
		Return(.T.)
    EndIf
	
	lGo := U_AlfSfz02( _cCNPJ, @_cCertif, @_cPrivKey, @_cPass ) // Recupera dados do Certificado digital

	If lGo 

		Do case

			Case cServico == '1'	// Pesquisa Chaves Destinatário

				//Pesquisa NFe
				If cPsqNFe == "S"

					If !PesqFaixa( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, @cUltNSU, @cResposta )		// chama pesquisa de XML por CNPJ
						cSubj := "Monitor XML - Erro ao Pesquisar NFe na Sefaz "
						cBody += '</p><font face="Arial">Prezado(a):</font></p>'
						cBody += '</p><font face="Arial"></font></p>'
						cBody += '</p><font face="Arial">Nao foi possível conectar a Sefaz, para pesquisar novas NFs, em '+Dtoc(Date())+' as '+Time()+'.</font></p>'
						cBody += '</p><font face="Arial"></font></p>'
						cBody += '</p><font face="Arial">A causa poder ser indisponibilidade da Sefaz, ou falta de acesso a Internet.</font></p>'
						cBody += '</p><font face="Arial">Caso este problema persiste, contacte seu suporte de TI.</font></p>'
						cBody += '</p><font face="Arial"></font></p>'
						cBody += '</p><font face="Arial">Obs.: está é uma mensagem automática gerada pelo sistema Protheus, não responda este e-mail.</font></p>'
					
						U_DNEnvEMail( Nil, cToClNFe, cSubj, cBody)
	
					Else

						lRet := .T.

					EndIf

				EndIf

				//Pesquisa CTe
				If cPsqCTe == "S"	

					PsqFxCte( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, @cUltNSU, @cResposta )

					lRet := .T.

				EndIf

			Case cServico == '2'	// Ciência do XML

				_cChave  := aParam[3]
				_dEmiss  := aParam[4]
				_cHEmis  := aParam[5]
				_cTpOper := "210210=Ciencia da Operacao"		// Ciência da Operação
	
				If ManifXML( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _cChave, _cTpOper, _dEmiss, _cHEmis, @cResposta )
					If Left(cResposta, 6) != "RESP: "									// Retornou valores
						cError   := ""
						cWarning := ""
						oRet     := cResposta
						lRet     := .T.														   // atualiza flag com sucesso
					Else
						If SubStr(cResposta,7,3) == "573" //Rejeicao: Duplicidade de evento, quer dizer que foi dado ciencia anteriormente
							cError   := ""
							cWarning := ""
							oRet     := cResposta
							lRet     := .F.														// atualiza flag com sucesso
						EndIf
					EndIf
				EndIf
				
				//Atualiza Status nas tabelas de Controle NSU e Monitor
				If !lRet
					If ! ( "Não foi possível consultar o SEFAZ" $ cResposta )
						U_AlfAtStNF( _cChave, "E", cResposta ) //Atualiza tabela de controle de NSU
					EndIf
				EndIf

			Case cServico == '3'	// Download XML

				_cChave := ''
				_cChave := aParam[3]
	
				if BxXml( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _cChave, @cResposta )	// download XML
	
					If Left(cResposta, 6) != "RESP: "									// Retornou valores
						oRet := cResposta
						lRet := .T.														// atualiza flag com sucesso
					Endif

				Else

					//Atualiza Status nas tabelas de Controle NSU e Monitor
					If !( "Não foi possível consultar o SEFAZ" $ cResposta )
						U_AlfAtStNF( _cChave, "F", cResposta ) //Atualiza tabela de controle de NSU
					EndIf

				EndIf


			Case cServico == '4'	// Aceite XML

				_cChave  := aParam[3]
				_dEmiss  := aParam[4]
				_cHEmis  := aParam[5]
				_cUf     := '91'
				_cTpOper := "210200=Confirmacao da Operacao"		// Confirmação da Operação
	
				If ManifXML( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _cChave, _cTpOper, _dEmiss, _cHEmis, @cResposta )
					If Left(cResposta, 6) != "RESP: "									// Retornou valores
						cError   := ""
						cWarning := ""
						oRet     := cResposta
						lRet     := .T.														// atualiza flag com sucesso
					EndIf
				Else
					If Type("cUsuario") == "U" .or. Empty(cUsuario)	// é JOB
						ConOut( cResposta + " - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					Else
						Alert( cResposta )
					EndIf
				EndIf

			Case cServico == '5'	// Rejeição XML - Desconhecimento da Operação

				_cChave  := aParam[3]
				_dEmiss  := aParam[4]
				_cHEmis  := aParam[5]
				_cUf     := '91'
				_cTpOper := "210220=Desconhecimento da Operacao"		// Desconhecimento da Operação
	
				If ManifXML( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _cChave, _cTpOper, _dEmiss, _cHEmis, @cResposta )
					If Left(cResposta, 6) != "RESP: "									// Retornou valores
						cError   := ""
						cWarning := ""
						oRet     := cResposta
						lRet     := .T.														// atualiza flag com sucesso
					EndIf
				Else
					If Type("cUsuario") == "U" .or. Empty(cUsuario)	// é JOB
					    cMsgError := cResposta + " - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time()
						ConOut( cMsgError )
					Else
						Alert( cResposta )
					Endif
				EndIf

			Case cServico == '6'	// Rejeição XML - Operacao nao Realizada

				_cChave  := aParam[3]
				_dEmiss  := aParam[4]
				_cHEmis  := aParam[5]
				_cJusti  := aParam[6]
				_cUf     := '91'
				_cTpOper := "210240=Operacao nao Realizada"		// Operacao nao Realizada
	
				If ManifXML( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _cChave, _cTpOper, _dEmiss, _cHEmis, @cResposta, _cJusti )
					If Left(cResposta, 6) != "RESP: "									// Retornou valores
						cError   := ""
						cWarning := ""
						oRet     := cResposta
						lRet     := .T.														// atualiza flag com sucesso
					Else
						oRet     := cResposta
					Endif
				Else
					If Type("cUsuario") == "U" .or. Empty(cUsuario)	// é JOB
					    cMsgError := cResposta + " - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time()
						ConOut( cMsgError )
					Else
						Alert( cResposta )
					EndIf
				EndIf
	

		EndCase

	Else

		_xResp := "Favor cadastrar dados do certificado digital!"

		If Type("cUsuario") == "U" .or. Empty(cUsuario)	// é JOB
		    cMsgError := "Favor cadastrar dados do certificado digital - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time()
			ConOut( cMsgError )
		Else 
		   Alert( "Favor cadastrar dados do certificado digital!" )
		EndIf
	EndIf

Return(lRet)




/*****************************************************************************************
* Rotina chama o WebService da SEFAZ para pegar as Chaves emitidas contra o cliente
*****************************************************************************************/
Static Function PesqFaixa( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _ultNSU, cResposta )

	Local   lRet    := .T.
	Local   cError
	Local   cWarning
	Local   nChaves := 0
	Local   nPesqs  := 0
	Local   aItens
	Local   nJ
	Local   _LogRet
	Local  cUltNSU := ""
	
	Private oRet
	Private oTmp


	//Pesquisa NFe
	lRet := Pesq2Faixa( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, @_ultNSU, @cResposta )		// chama pesquisa de XML por CNPJ

	nPesqs++

	if Left(cResposta, 6) != "RESP: "								// Retornou valores

		cError   := ""
		cWarning := ""
		oTmp     := XMLParser( cResposta, "", @cError,@cWarning)	// efetua parse pra retornar o objeto

		If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
			aItens := oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
		elseif Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT") == "C"
			aItens := {oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT}
		else
			aItens := {}
		endif

			For nJ := 1 to len( aItens )

				cResposta := U_xDescptDocZip(aItens[nJ],_cCNPJ)

				If Left(cResposta, 6) == "RESP: "								// Retornou valores

					Exit

				Else

					cError   := ""
					cWarning := ""
					oXml     := XMLParser( cResposta, "", @cError,@cWarning)	// efetua parse pra retornar o objeto

 					If Type("oXml:_RESNFE:_CHNFE:TEXT" ) == "C"

						nChaves++

						_LogRet := "NF-e: " + oXml:_RESNFE:_CHNFE:TEXT + " - "
						_LogRet += "CNPJ: " + oXml:_RESNFE:_CNPJ:TEXT + " - "
						
						ZDIIns( 	_cCNPJ,; 
									aItens[nJ]:_NSU:TEXT,; 
									oXml:_RESNFE:_CHNFE:TEXT,; 
									"RESNFE",; 
									Alltrim(cResposta),; 
									"",; 
									_cUf,; 
									"",; 
									DtoS(dDataBase),; 
									StrTran( oXml:_RESNFE:_DHEMI:TEXT, "-", "" ),; 
									Substr( oXml:_RESNFE:_DHRECBTO:TEXT, 12) )
						
						
					Elseif type("oXml:_RESEVENTO:_CHNFE:TEXT" ) == "C"

						nChaves++

						_LogRet := "NF-e: " + oXml:_RESEVENTO:_CHNFE:TEXT + " - "
						_LogRet += "CNPJ: " + oXml:_RESEVENTO:_CNPJ:TEXT + " - "

						ZDIIns( 	_cCNPJ,; 
									aItens[nJ]:_NSU:TEXT,; 
									oXml:_RESEVENTO:_CHNFE:TEXT,; 
									"RESEVENTO",; 
									Alltrim(cResposta),; 
									"",; 
									_cUf,; 
									"",; 
									DtoS(dDataBase),; 
									StrTran( Substr(oXml:_RESEVENTO:_DHEVENTO:TEXT,1,10), "-", "" ),; 
									Iif(Type("oXml:_RESEVENTO:_DHEVENTO:TEXT")<>"U",Substr(oXml:_RESEVENTO:_DHEVENTO:TEXT,12),"") )

					EndIf					

				If cUltNSU < aItens[nJ]:_NSU:TEXT
					cUltNSU := aItens[nJ]:_NSU:TEXT
				EndIf
			EndIf
		Next nJ
		
		// Grava ultimo NSU na tabela de configuração ZDG
		GrvNSU(_cCNPJ, cUltNSU)

		oXml   := nil
		oRet   := nil
		aItens := nil

	Endif

	_xResp := cResposta		// retorna var Private do TstXmlAut - test SEFAZ

Return(.T.)



Static Function Pesq2Faixa( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _ultNSU, cResposta )
	Local   cURL      := "'
	Local   cAmbiente := ""
	Local   cVersao   := ""
	Local   aHeadOut  := {}
	Local   cAviso    := ""
	Local   nTries    := 0
	Local   cSoap     := ""
	Local   xRetWs    := Nil
	Private oTmp      := Nil
    
    If Empty(_ultNSU)
		_ultNSU := GetUNSU(_cCNPJ)
	EndIF

	If lProducao
		cURL := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?wsdl"
		cAmbiente := "1"		// 1-Produção 2-Homologação
		cVersao   := "1.01"
	Else
		cURL := "https://hom.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?wsdl"
		cAmbiente := "2"		// 1-Produção 2-Homologação
		cVersao   := "1.01"
	Endif


	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nfed="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'
	cSoap += 	'<soapenv:Header/>'
	cSoap += 		'<soapenv:Body>'
	cSoap += 			'<nfed:nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe" versao="'+cVersao+'">'
	cSoap += 				'<nfed:nfeDadosMsg>'
	cSoap += 					'<distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="'+cVersao+'">'
	cSoap += 						'<tpAmb>'+cAmbiente+'</tpAmb>'
	cSoap += 						'<cUFAutor>'+_cUf+'</cUFAutor>'
	cSoap += 						'<CNPJ>'+_cCNPJ+'</CNPJ>'
	cSoap += 						'<distNSU>'
	cSoap += 							'<ultNSU>'+PadL(_ultNSU,15,"0")+'</ultNSU>'
	cSoap += 						'</distNSU>'
	cSoap += 					'</distDFeInt>'
	cSoap += 				'</nfed:nfeDadosMsg>'
	cSoap += 		'</nfed:nfeDistDFeInteresse>'
	cSoap += 	'</soapenv:Body>'
	cSoap += '</soapenv:Envelope>'

	aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8 ')
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')') // Acrescenta o UserAgent na requisição ... '; '+WSDLCLIENT_VERSION+
    
	While ( ( xRetWs == Nil ) .And. nTries < 10 )
		nTries++
		xRetWs := HttpSPost(cURL, _cCertif, _cPrivKey, _cPass, "", cSoap, 120, aHeadOut, @cAviso, .F. )
		Sleep(2000)
	EndDo

	if xRetWs != Nil
		cError 		:= ""
		cWarning    := ""
		oTmp := XMLParser( xRetWs, "", @cError, @cWarning )

		If Type("oTmp") == "O"
			If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") == "C"
				//Se encontrou Documento
				If Alltrim(oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT) == "138"
					If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT") == "C"
						_ultNSU := oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT
						If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
							cResposta := xRetWs
						ElseIf Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT") == "C"
							cResposta := xRetWs
						Else
							cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _LOTEDISTDFEINT com _DOCZIP"
							ConOut(cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
						EndIf
					Else
						cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _ULTNSU"
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					EndIf
				Else
					If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT") == "C"
						cResposta := "RESP: "+oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					Else
						cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _XMOTIVO"
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					EndIf
				EndIf
			Else
				cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _CSTAT"
				ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
			EndIf
		Else
			cResposta := "RESP: Problema no retorno do SEFAZ"
			ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
		EndIf

	else
		cResposta := "RESP: Não foi possível consultar o SEFAZ"
		ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
	endif

Return ( xRetWs != Nil )


/*****************************************************************************************
* Rotina chama o WebService da SEFAZ para baixar um XML
*****************************************************************************************/
Static Function BxXml( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, cChave, cResposta )
	Local   cURL
	Local   cAmbiente
	Local   cVersao
	Local   aHeadOut  := {}
	Local   cAviso    := ""
	Local   cSoap
	Local   xRetWs

	// Conforme Nota no portal da sefaz, os webserives NFeConsultaDest e NfeDownloadNF sairam do ar, link da nota: http://portalnfe.fazenda.mg.gov.br/
	if lProducao
		cURL := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?wsdl"
		cAmbiente := "1"		// 1-Produção 2-Homologação
		cVersao   := "1.01"
	else
		cURL := "https://hom.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?wsdl"
		cAmbiente := "2"		// 1-Produção 2-Homologação
		cVersao   := "1.01"
	endif

	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nfed="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'+CRLF
	cSoap += '   <soapenv:Header/>'+CRLF
	cSoap += '   <soapenv:Body>'+CRLF
	cSoap += '      <nfed:nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe" versao="'+cVersao+'">'+CRLF
	cSoap += '         <nfed:nfeDadosMsg>'+CRLF
	cSoap += '     		<distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="'+cVersao+'">'+CRLF
	cSoap += '                    <tpAmb>'+cAmbiente+'</tpAmb>'+CRLF
	cSoap += '                    <cUFAutor>'+_cUf+'</cUFAutor>'+CRLF
	cSoap += '                    <CNPJ>'+_cCNPJ+'</CNPJ>'+CRLF
	//Faz consulta pela chave da NFe
	cSoap += '                    <consChNFe>'+CRLF
	cSoap += '                        <chNFe>'+cChave+'</chNFe>'+CRLF
	cSoap += '                    </consChNFe>'+CRLF
	cSoap += '                </distDFeInt>'+CRLF
	cSoap += '         </nfed:nfeDadosMsg>'+CRLF
	cSoap += '      </nfed:nfeDistDFeInteresse>'+CRLF
	cSoap += '   </soapenv:Body>'+CRLF
	cSoap += '</soapenv:Envelope>'


	aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8 ')
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+'; '+')') // Acrescenta o UserAgent na requisição ... WSDLCLIENT_VERSION+

	xRetWs := HttpSPost(cURL, _cCertif, _cPrivKey, _cPass, "", cSoap, 120, aHeadOut, @cAviso)
	if xRetWs != Nil
		cError 		:= ""
		cWarning    := ""
		oTmp := XMLParser( xRetWs, "", @cError, @cWarning )

		If Type("oTmp") == "O"
			If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") == "C"
				//Se encontrou Documento
				If Alltrim(oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT) == "138"
			   		If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
						cResposta := xRetWs
					ElseIf Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT") == "C"
						cResposta := xRetWs
	                Else
		        		cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _LOTEDISTDFEINT com _DOCZIP"
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
	                EndIf
				Else
					If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT") == "C"
						cResposta := "RESP: "+oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					Else
		        		cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _XMOTIVO"
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					EndIf
				EndIf
			Else
				cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _CSTAT"
				ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
			EndIf
		Else
			cResposta := "RESP: Problema no retorno do SEFAZ"
			ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
		EndIf
	else
		cResposta := "RESP: Não foi possível consultar o SEFAZ"
	endif

Return ( xRetWs != Nil )


Static Function ManifXML( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _cChave, _cTpOper, _dEmiss, _cHEmis, cResposta, cJustifica )
	Local   cURL
	Local   cAmbiente
	Local   _cVersao
	Local   _cSeqEven  := "1"
	Local   _cIdLote   := "000000000000001"
	Local   cDataHora  := StrZero(Year(_dEmiss),4)+"-"+StrZero(Month(_dEmiss),2)+"-"+StrZero(Day(_dEmiss),2)	//+"T23:59:59-03:00"
	Local   cIdEvent   := 'ID' + Substr(_cTpOper,1,6) + _cChave + StrZero(Val(_cSeqEven),2)
	Local   aHeadOut   := {}
	Local   cAviso     := ""
	Default cJustifica := ""
	Default _cHEmis    := Time() + "-03:00" // "23:59:59-03:00"

	if Empty( _cHEmis )
		_cHEmis    := Time() + "-03:00"
	endif

	cDataHora  += "T" + Alltrim(_cHEmis)

//	if Right( cDataHora, 6 ) != "-03:00"
//		cDataHora += "-03:00"
//	endif

	//_cTpOper :=  210200=Confirmação da Operação / 210210=Ciência da Operação / 210220=Desconhecimento da Operação / 210240=Operação não Realizada
	// deve ser passado o texto sem acentos no XML

	if lProducao
		cURL      := "https://www.nfe.fazenda.gov.br/RecepcaoEvento/RecepcaoEvento.asmx"
		cAmbiente := "1"		// 1-Produção 2-Homologação
		_cVersao   := "1.00"
	else
		cURL      := "https://hom.nfe.fazenda.gov.br/RecepcaoEvento/RecepcaoEvento.asmx"
		cAmbiente := "2"		// 1-Produção 2-Homologação
		_cVersao   := "1.00"
	endif

	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:rec="http://www.portalfiscal.inf.br/nfe/wsdl/RecepcaoEvento">'
	cSoap += '<soapenv:Header>'
	cSoap += '<rec:nfeCabecMsg>'
	cSoap += '<rec:versaoDados>'+_cVersao+'</rec:versaoDados>'
	cSoap += '<rec:cUF>'+_cUf+'</rec:cUF>'
	cSoap += '</rec:nfeCabecMsg>'
	cSoap += '</soapenv:Header>'
	cSoap += '<soapenv:Body>'
	cSoap += '<rec:nfeDadosMsg>'

	cXML := '<envEvento xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + _cVersao + '">'
	cXML += '<idLote>' + _cIdLote + '</idLote>'
	cXML += '<evento xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + _cVersao + '">'
	cXML += '<infEvento Id="' + cIdEvent + '">'
	cXML += '<cOrgao>91</cOrgao>' //'<cOrgao>' + _cUf + '</cOrgao>'
	cXML += '<tpAmb>' + cAmbiente + '</tpAmb>'
	cXML += '<CNPJ>' + _cCNPJ + '</CNPJ>'
	cXML += '<chNFe>' + _cChave + '</chNFe>'
	cXML += '<dhEvento>' + cDataHora + '</dhEvento>'
	cXML += '<tpEvento>' + Substr(_cTpOper,1,6) + '</tpEvento>'
	cXML += '<nSeqEvento>1</nSeqEvento>'
	cXML += '<verEvento>' + _cVersao + '</verEvento>'
	cXML += '<detEvento versao="' + _cVersao + '">'
	cXML += '<descEvento>' + Substr(_cTpOper,8) + '</descEvento>'
	If Substr(_cTpOper,1,6) == "210240" // Operação não Realizada
		cXML += '<xJust>'+Alltrim(cJustifica)+'</xJust>'
	EndIf
	cXML += '</detEvento>'
	cXML += '</infEvento>'
	cXML += '</evento>'
	cXML += '</envEvento>'

	//cSoap += fAssinaXML( cXML, _cCNPJ, _cChave, cIdEvent, "infEvento", _cCertif, _cPrivKey, _cPass)

	cSoap += SignXML( cIdEvent, cXML, "infEvento", "", "", _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _cChave, _cTpOper, _dEmiss, _cHEmis, cResposta, cJustifica )

	cSoap += '</rec:nfeDadosMsg>'
	cSoap += '</soapenv:Body>'
	cSoap += '</soapenv:Envelope>'
	aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8 ')
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild() )

	xRetWs := HttpSPost(cURL, _cCertif, _cPrivKey, _cPass, "", cSoap, 120, aHeadOut, @cAviso)
	If xRetWs != Nil
		cError   := ""
		cWarning := ""
		oXmlRet  := XMLParser( xRetWs ,"", @cError,@cWarning)

		If Type("oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_CSTAT") <> "U"
			If Type("oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT") <> "U"
				cResposta :=  Alltrim(oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT)
			EndIf

			cResposta := Alltrim(oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_CSTAT:TEXT)
			cResposta += " - "+Alltrim(oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_XMOTIVO:TEXT)+Chr(13)+Chr(10)+Chr(13)+Chr(10)

			if "<xMotivo>Rejeicao:" $ xRetWs	// Ocorreu Rejeição
				If Type("oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT") == "C" .AND. Type("oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT") == "C"
					cResposta := "RESP: " + Alltrim(oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT) + " - " +Alltrim(oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT)
				Else
					nIni := at( "<xMotivo>Rejeicao:", xRetWs ) + 9
					nFim := rat( "</xMotivo>", xRetWs )
					cResposta := "RESP: " + substr(xRetWs, nIni, nFim-nIni)

				EndIf

			else
				If Type("oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT") == "C"
					cResposta := Alltrim(oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT)
					cResposta += " - "+Alltrim(oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT)
				EndIf
			endif


		ElseIf Type("oXmlRet:_ENV_ENVELOPE:_ENV_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_CSTAT") <> "U"
			If Type("oXmlRet:_ENV_ENVELOPE:_ENV_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT") <> "U"
				cResposta := Alltrim(oXmlRet:_ENV_ENVELOPE:_ENV_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT)
			EndIf

			_cStat := Alltrim(oXmlRet:_ENV_ENVELOPE:_ENV_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_CSTAT:TEXT)

			If _cStat == "100" 		// 100-Autorizado o Uso

			ElseIf _cStat == "101" 	// 101-Cancelamento de NF-e Homologado

			Else 				   	// 110-Uso Denegado

			EndIf

			cResposta := "RESP: " + _cStat +" - "+ Alltrim(oXmlRet:_ENV_ENVELOPE:_ENV_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_XMOTIVO:TEXT)

			If Type("oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT") <> "U"
				cResposta := oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT
				cResposta += " - "+oXmlRet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT
			EndIf

		Else
			cResposta := "RESP: Erro no arquivo XML de Retorno"
		Endif

		if Left(_cTpOper,6) == "210210" .and. Left(cResposta, 6) != "RESP: "
			cTag   := "retEnvEvento"
			nAtIni := At("<"+cTag,xRetWs)
			If nAtIni > 0

				cXmlDown  := Substr(xRetWs,nAtIni)
				nAtFim    := At("</"+cTag,cXmlDown) + Len(cTag) + 2
				cXmlDown  := '<?xml version="1.0" encoding="UTF-8"?>' + Substr(cXmlDown,1,nAtFim)

				cResposta := cXmlDown

			else
				cResposta := "RESP: Xml não disponível"

			endif
		endif

	else
		cResposta := "RESP: Não foi possível consultar o SEFAZ"
	endif

Return ( xRetWs != Nil )



/**********************************************************************
* GetCertificate - Rotina para buscar o certificado do cliente
**********************************************************************/
User Function AlfGtCrt(cFile)
	Local cTxtCert     := ""
	Local nAT          := 0
	Local nRAT         := 0
	Local nHandle      := 0
	Local nBuffer      := 0
	Local cNewFunc     := ""
	Local lExistCert   := .T.

	nHandle      := FOpen( cFile, 0 )
	nBuffer      := FSEEK(nHandle,0,2)

	FSeek( nHandle, 0 )
	If nHandle > 0
		FRead( nHandle , cTxtCert , nBuffer )
		FClose( nHandle )
	Else
		cMsgError := "Certificado nao encontrado no diretorio Certs - Realizar a configuracao do certificado para entidade !"
		Conout(cMsgError)
		lExistCert := .F.
	EndIf
	If lExistCert
		nAt := AT("BEGIN CERTIFICATE", cTxtCert)
		If (nAt > 0)
			nAt := nAt + 22
			cTxtCert := substr(cTxtCert, nAt)
		EndIf
		nRat := AT("END CERTIFICATE", cTxtCert)
		If (nRAt > 0)
			nRat := nRat - 6
			cTxtCert := substr(cTxtCert, 1, nRat)
		EndIf
		cTxtCert := StrTran(cTxtCert, Chr(13),"")
		cTxtCert := StrTran(cTxtCert, Chr(10),"")
		cTxtCert := StrTran(cTxtCert, Chr(13)+Chr(10),"")
	EndIf

Return cTxtCert



User Function xDescptDocZip(cTexto,_cCNPJ)
	Local cResposta := ""
	If ValType(cTexto)== "O"
		cTexto := cTexto:TEXT
	EndIf
	//Conforme Layout Técnico:
	//Informação resumida ou documento fiscal eletrônico de
	//interesse da ou empresa. O conteúdo desta tag estará
	//compactado no padrão gZip. O tipo do campo é base64Binary
	cContGZip 	:= Decode64(cTexto)

	nLenComp := Len( cContGZip )

	cResposta := ""

	//Descompacta o conteúdo do gzip
	If GzStrDecomp( cContGZip, nLenComp, @cResposta )
		cResposta  := '<?xml version="1.0" encoding="UTF-8"?>' + cResposta
	Else
		cResposta := "RESP: Problema ao Descompactar gzip"
		// Adicionar Log u_addLOG( "AlfSfz01 (busca SEFAZ) - " + cResposta + ": " + _cCNPJ )
		ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
	EndIf
Return (cResposta)


Static Function GrvNSU(cCNPJ, cNSU, cTpXML )
Local cUpd := ""
Default cTpXML := "NFE"

If cTpXML == "NFE"

	If !Empty(cNSU)
		DbSelectArea("ZDG")
		DbSetOrder(1) // ZDG_FILIAL+ZDG_CONTA
		If DbSeek(xFilial("ZDG")+cCNPJ) .And. cNSU > ZDG->ZDG_ULTNSU
			RecLock("ZDG",.F.)
				REPLACE ZDG_ULTNSU WITH cNSU
			MsUnlock()
		EndIf
	EndIf

ElseIf cTpXML == "CTE"

	cUpd := "UPDATE "+RetSqlName("ZDG")+" SET ZDG_NSUCTE = '"+cNSU+"' WHERE D_E_L_E_T_ = ' ' AND ZDG_FILIAL = '"+xFilial("ZDG")+"' AND ZDG_CONTA = '"+cCNPJ+"' "
	TcSqlExec(cUpd)
	
EndIf

Return .T.


Static Function GetUNSU(cCNPJ)

Local aArea 	:= GetArea()
Local cTMP1 	:= CriaTrab(,.F.)
Local cQuery	:= ""
Local cRet 		:= "000000000000000"

cQuery := " SELECT "+ CRLF
cQuery += " 	MAX(ZDG.ZDG_ULTNSU) ZDG_ULTNSU "+ CRLF
cQuery += " FROM "+RetSqlName("ZDG")+" ZDG (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " 	ZDG.ZDG_FILIAL = '"+xFilial("ZDG")+"' "+ CRLF
cQuery += " 	AND ZDG.ZDG_CONTA = '"+AllTrim(cCNPJ)+"' "+ CRLF
cQuery += " 	AND ZDG.D_E_L_E_T_ = ' ' "+ CRLF

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTMP1,.F.,.T.)

If (cTMP1)->(!EOF())
	cRet := (cTMP1)->ZDG_ULTNSU
EndIf

(cTMP1)->(DbCloseArea())

If Empty(cRet)
	cQuery := " SELECT "+ CRLF
	cQuery += " 	MAX(ZDI.ZDI_NSU) ZDI_NSU "+ CRLF
	cQuery += " FROM "+RetSqlName("ZDI")+" ZDI (NOLOCK) "+ CRLF
	cQuery += " WHERE "+ CRLF
	cQuery += " 	ZDI.ZDI_FILIAL = '"+xFilial("ZDI")+"' "+ CRLF
	cQuery += " 	AND ZDI.ZDI_CONTA = '"+AllTrim(cCNPJ)+"' "+ CRLF
	cQuery += " 	AND ZDI.D_E_L_E_T_ = ' ' "+ CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTMP1,.F.,.T.)
	
	If (cTMP1)->(!EOF())
		cRet := (cTMP1)->ZDI_NSU
	EndIf
	
	(cTMP1)->(DbCloseArea())
EndIf

RestArea(aArea)

Return cRet



Static Function ZDIIns( cCNPJ, cNSU, cChvNFe, cTpXML, cXML, cStatus, cUFDest, cUFEmit, cDtBxml, cDtProc, cHrProc )
Local cQry := ""
Local cCmd := ""
Local cBDErr := ""
Local cSubj := ""
Local cBody := ""
Local cObs := DtoC(dDataBase)+ " - " +Time()+ ": registro incluido."
Local cToClNFe := SuperGetMV("AF_MAILXML",,"")
Local cMdGrv := SuperGetMv("AF_MDGZDI",,"I") // Modo de Gravacao: R=RecLock, I=Insert
Local nRet := 0
Local nRecNo := 0

ChkFile("ZDI")

If cMdGrv == "R" // RecLock()

	dbSelectArea("ZDI")
	RecLock("ZDI",.T.)
	
	ZDI->ZDI_FILIAL	:= xFilial("ZDI")
	ZDI->ZDI_CONTA	:= cCNPJ
	ZDI->ZDI_NSU	:= cNSU
	ZDI->ZDI_CHVNFE	:= cChvNFe
	ZDI->ZDI_TPXML	:= cTpXML
	ZDI->ZDI_XML	:= cXML
	ZDI->ZDI_STATUS	:= cStatus
	ZDI->ZDI_UFDEST	:= cUFDest
	ZDI->ZDI_UFEMIT	:= cUFEmit
	ZDI->ZDI_DTBXML	:= StoD(SubStr(cDtBXml,1,8))
	ZDI->ZDI_DTPROC	:= StoD(SubStr(cDtProc,1,8))
	ZDI->ZDI_HRPROC	:= cHrProc
	ZDI->ZDI_OBS	:= cObs

	ZDI->(MsUnLock())
	
Else		

	cQry := "SELECT MAX(R_E_C_N_O_) AS MAXRECNO FROM "+RetSqlName("ZDI")+" (NOLOCK)"  //Considerar deletados
	
	Iif(Select("WRCNZDI")>0,WRCNZDI->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRCNZDI",.T.,.T.)
	TcSetField("WRCNZDI","MAXRECNO","N",14,0)
	WRCNZDI->(dbGoTop())
	
	If WRCNZDI->(!EoF())
		nRecNo := WRCNZDI->MAXRECNO
	EndIf
	WRCNZDI->(dbCloseArea())
	
	nRecNo := nRecNo++

	cCmd := "INSERT INTO "+RetSqlName("ZDI")+" "
	cCmd += "( ZDI_FILIAL, "
	cCmd += "ZDI_CONTA, "
	cCmd += "ZDI_NSU, "
	cCmd += "ZDI_CHVNFE, "
	cCmd += "ZDI_TPXML, "
	cCmd += "ZDI_XML, "
	cCmd += "ZDI_STATUS, "
	cCmd += "ZDI_UFDEST, "
	cCmd += "ZDI_UFEMIT, "
	cCmd += "ZDI_DTBXML, "
	cCmd += "ZDI_DTPROC, "
	cCmd += "ZDI_HRPROC, "
	cCmd += "ZDI_OBS, "
	cCmd += "D_E_L_E_T_, "
	cCmd += "R_E_C_N_O_, "
	cCmd += "R_E_C_D_E_L_ ) "
	cCmd += "VALUES " 
	cCmd += "("
	cCmd += "'"+xFilial("ZDI")+"', "		//ZDI_FILIAL
	cCmd += "'"+cCNPJ+"', "					//ZDI_CONTA
	cCmd += "'"+cNSU+"', "					//ZDI_NSU
	cCmd += "'"+cChvNFe+"', "				//ZDI_CHVNFE
	cCmd += "'"+cTpXML+"', "				//ZDI_TPXML
	cCmd += "CONVERT( VARBINARY(MAX), '"+Alltrim(cXML)+"', 0), " //ZDI_XML
	cCmd += "'"+cStatus+"', "				//ZDI_STATUS
	cCmd += "'"+cUFDest+"', "				//ZDI_UFDEST
	cCmd += "'"+cUFEmit+"', "				//ZDI_UFEMIT
	cCmd += "'"+SubStr(cDtBxml,1,8)+"', "	//ZDI_DTBXML
	cCmd += "'"+SubStr(cDtProc,1,8)+"', "	//ZDI_DTPROC
	cCmd += "'"+Alltrim(cHrProc)+"', "		//ZDI_HRPROC
	cCmd += "'"+cObs+"', "					//ZDI_OBS
	cCmd += "' ', "							//DELET
	cCmd += Alltrim(Str(nRecno++))+", "		//RECNO
	cCmd += "0 )"							//RECDEL
	            
	nRet := TcSqlExec(cCmd)

	If nRet <> 0
	
		cBdErr := TcSqlError()

		cSubj := "Monitor XML - Erro ao Gravar XML no Banco de Dados"
		cBody += '</p><font face="Arial">Prezado(a):</font></p>'
		cBody += '</p><font face="Arial"></font></p>'
		cBody += '</p><font face="Arial">Nao foi possivel gravar XML pesquisado na Sefaz, em '+Dtoc(Date())+' as '+Time()+'.</font></p>'
		cBody += '</p><font face="Arial"></font></p>'
		cBody += '</p><font face="Arial">Contacte seu suporte Protheus, informando o erro:</font></p>'
		cBody += '</p><font face="Arial"></font></p>'
		cBody += '</p><font face="Arial">'+cBdErr+'</font></p>'
		cBody += '</p><font face="Arial"></font></p>'
		cBody += '</p><font face="Arial">Dados da NFe/Evento com erro na gravacao:</font></p>'
		cBody += '</p><font face="Arial">Chave: '+cChvNFe+'</font></p>'
		cBody += '</p><font face="Arial">Tipo de XML: '+cTpXML+'</font></p>'
		cBody += '</p><font face="Arial">Data de Processamento na Sefaz AN: '+SubStr(cDtProc,1,8)+ ' - ' +Alltrim(cHrProc)+ '</font></p>'
		cBody += '</p><font face="Arial"></font></p>'
		cBody += '</p><font face="Arial">Conteudo do XML:</font></p>'
		cBody += '</p><font face="Arial">'+cXML+ '</font></p>'
		cBody += '</p><font face="Arial"></font></p>'
		cBody += '</p><font face="Arial">Obs.: está é uma mensagem automática gerada pelo sistema Protheus, não responda este e-mail.</font></p>'
	
		U_DNEnvEMail( Nil, cToClNFe, cSubj, cBody)

	EndIf

EndIf

Return(.T.)




Static Function SignXML( cIdEvent, cXML, cTag, cAttID, cIdEnt, _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _cChave, _cTpOper, _dEmiss, _cHEmis, cResposta, cJustifica )
Local cXmlToSign  := ""
Local cCert       := ""
Local cURI        := ""
Local cMacro      := ""
Local cError      := ""
Local cWarning    := ""
Local cDigest     := ""
Local cSignature  := ""
Local cSignInfo   := ""
Local cIniXml     := ""
Local cFimXml     := ""
Local cNameSpace  := ""
Local cNewTag     := ""
Local nAt         := 0
Local nAtVer  	  := 0
Default cAttId    := ""
Default cIdent    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtenho a URI                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cUri := cIdEvent

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Canoniza o XML                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXmlToSign := XmlC14N(cXml, "", @cError, @cWarning) 		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para troca de caracter referente ao xml da ANFAVEA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXmlToSign := (StrTran(cXmlToSign,"&lt;/","</"))
cXmlToSign = (StrTran(cXmlToSign,"/&gt;","/>"))  
cXmlToSign = (StrTran(cXmlToSign,"&lt;","<"))  
cXmlToSign = (StrTran(cXmlToSign,"&gt;",">"))  
cXmlToSign = (StrTran(cXmlToSign,"<![CDATA[[ ","<![CDATA["))  

If Empty(cError) .And. Empty(cWarning)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retira a Tag anterior a tag de assinatura                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAt := At("<"+cTag,cXmlToSign)
	cIniXML    := SubStr(cXmlToSign,1,nAt-1)
	cXmlToSign := SubStr(cXmlToSign,nAt)
	nAt := At("</"+cTag+">",cXmltoSign)
	cFimXML    := SubStr(cXmltoSign,nAt+Len(cTag)+3)
	cXmlToSign := SubStr(cXmlToSign,1,nAt+Len(cTag)+2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descobre o namespace complementar da tag de assinatura                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNewTag := AllTrim(cIniXml)
	cNewTag := SubStr(cIniXml,2,At(" ",cIniXml)-2)
	cNameSpace := StrTran(cIniXml,"<"+cNewTag,"")
	cNameSpace := AllTrim(StrTran(cNameSpace,">",""))
	nAtver := At("versao",cNameSpace) // Pode ter um atributo versao Ex. ( xmlns="http://" versao="1.01")
	If nAtver > 0
		cNameSpace := SubStr(cNameSpace, 1, nAtver-1) // -2 por causa do espaco
		cNameSpace := RTrim(cNameSpace)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o DigestValue da assinatura                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 cDigest := StrTran(cXmlToSign,"<"+cTag+" ","<"+cTag +" "+cNameSpace+" ")
     cDigest := XmlC14N(cDigest, "", @cError, @cWarning) 
     cMacro  := "EVPDigest"
     cDigest := Encode64(&cMacro.( cDigest , 3 ))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o SignedInfo  da assinatura                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSignInfo := '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
	cSignInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></CanonicalizationMethod>'
	cSignInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod>'
	cSignInfo += '<Reference URI="#'+ cUri +'">'
	cSignInfo += '<Transforms>'
	cSignInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform>'
	cSignInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></Transform>'
	cSignInfo += '</Transforms>'
	cSignInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod>'
	cSignInfo += '<DigestValue>' + cDigest + '</DigestValue></Reference></SignedInfo>' 
	cSignInfo := XmlC14N(cSignInfo, "", @cError, @cWarning) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Assina o XML                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMacro     := "EVPPrivSign"
	cSignature := &cMacro.( _cPrivKey , cSignInfo , 3 , _cPass , @cError)
	cSignature := Encode64(cSignature)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envelopa a assinatura                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCert := U_AlfGtCrt( _cCertif )

	If !Empty(cCert)
		cXmlToSign += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
		cXmltoSign += cSignInfo
		cXmlToSign += '<SignatureValue>'+cSignature+'</SignatureValue>'
		cXmltoSign += '<KeyInfo>'
		cXmltoSign += '<X509Data>'			
		cXmltoSign += '<X509Certificate>'+cCert+'</X509Certificate>'
		cXmltoSign += '</X509Data>'
		cXmltoSign += '</KeyInfo>'
		cXmltoSign += '</Signature>'
		cXmlToSign := cIniXML+cXmlToSign+cFimXML

	Else

		cXmlToSign:= ""				

	EndIf

Else

	cXmlToSign := cXml
	ConOut("Sign Error "+cError+"/"+cWarning)

EndIf

Return(cXmlToSign)


//Atualiza tabela de controle de NSU
User Function AlfAtStNF( cChvNFe, cStatus, cMsgObs, cOrigem )
Local cAQry := ""
Local cUpdt := "" 
Local cMdGrv := SuperGetMv("AF_MDGSTE",,"U") // Modo de Gravacao: R=RecLock, I=Insert
Local cObs := DtoC(dDataBase) +" - "+ Time()+ ": "
Local aAtuArea := {}
Local aZDIArea := {}
Local nRcnZDI := 0
Local nRcnZDH := 0
Local nRetU := 0
Default cOrigem := ""


If !Empty(cOrigem)
	cObs += "("+Alltrim(cOrigem)+") "
EndIf
If cStatus == "E" //Erro
	cObs += "ERRO - "+Alltrim(cMsgObs)
Else
	cObs += Alltrim(cMsgObs)
EndIf
cObs := Alltrim(SubStr(cObs,1,254))


cAQry := "SELECT ZDI.R_E_C_N_O_ AS ZDIRECNO "
cAQry += "FROM "+RetSqlName("ZDI")+" ZDI "
cAQry += "WHERE ZDI.D_E_L_E_T_ <> '*' "
cAQry += "AND ZDI.ZDI_FILIAL = '"+xFilial("ZDI")+"' "
cAQry += "AND ZDI.ZDI_CHVNFE = '"+cChvNFe+"' "

Iif(Select("WRKAZDI")>0,WRKAZDI->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cAQry),"WRKAZDI",.T.,.T.)
TcSetField("WRKAZDI","ZDIRECNO","N",14,0)
WRKAZDI->(dbGoTop())

If WRKAZDI->(!EoF())
	If WRKAZDI->ZDIRECNO > 0
		nRcnZDI := WRKAZDI->ZDIRECNO
	EndIf
EndIf

WRKAZDI->(dbCloseArea())

cAQry := "SELECT ZDH.R_E_C_N_O_ AS ZDHRECNO "
cAQry += "FROM "+RetSqlName("ZDH")+" ZDH "
cAQry += "WHERE ZDH.D_E_L_E_T_ <> '*' "
cAQry += "AND ZDH.ZDH_FILIAL = '"+xFilial("ZDH")+"' "
cAQry += "AND ZDH.ZDH_CHAVE = '"+cChvNFe+"' "

Iif(Select("WRKBZDH")>0,WRKBZDH->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cAQry),"WRKBZDH",.T.,.T.)
TcSetField("WRKBZDH","ZDHRECNO","N",14,0)
WRKBZDH->(dbGoTop())

If WRKBZDH->(!EoF())
	If WRKBZDH->ZDHRECNO > 0
		nRcnZDH := WRKBZDH->ZDHRECNO
	EndIf
EndIf

WRKBZDH->(dbCloseArea())

If nRcnZDI > 0

	If cMdGrv == "U"

		cUpdt := "UPDATE "+RetSqlName("ZDI")+" SET ZDI_STATUS = '"+cStatus+"', ZDI_OBS = '"+cObs+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(nRcnZDI))
		nRetU := TcSqlExec(cUpdt)

	Else

		aAtuArea := GetArea()
		aZDIArea := ZDI->(GetArea())
		
		dbSelectArea("ZDI")
		ZDI->(dbSetOrder(1))
		ZDI->(dbGoTo(nRcnZDI))
		
		If ZDI->(RecNo()) == nRcnZDI
			
			If RecLock("ZDI",.F.)
				ZDI->ZDI_STATUS := cStatus
				ZDI->(MsUnLock())
			EndIf
	
		EndIf
		
		RestArea(aZDIArea)
		RestArea(aAtuArea)

	EndIf

EndIf

If nRcnZDH > 0

	If cMdGrv == "I"

		cUpdt := "UPDATE "+RetSqlName("ZDH")+" SET ZDH_STATUS = '"+cStatus+"', ZDH_MSGERR = '"+cObs+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(nRcnZDH))
		nRetU := TcSqlExec(cUpdt)

	Else

		aAtuArea := GetArea()
		aZDHArea := ZDH->(GetArea())
		
		dbSelectArea("ZDH")
		ZDH->(dbSetOrder(1))
		ZDH->(dbGoTo(nRcnZDH))
		
		If ZDH->(RecNo()) == nRcnZDH
			
			If RecLock("ZDH",.F.)
				ZDH->ZDH_STATUS := cStatus
				ZDH->ZDH_MSGERR := cMsgObs
				ZDH->(MsUnLock())
			EndIf
	
		EndIf
		
		RestArea(aZDHArea)
		RestArea(aAtuArea)

	EndIf

EndIf

Return(Nil)



Static Function PsqFxCte( _cUf, _cCertif, _cPrivKey, _cPass, _cCNPJ, _ultNSU, cResposta )
	Local   cURL      := "https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx?wsdl"
	Local   cAviso    := ""
	Local   cSoap     := ""
	Local   cError	  := ""
	Local   cWarning  := ""
	Local   cRespXML  := ""
	Local   cUltNSU   := ""
	Local   nTries    := 0
	Local	lBxCte    := .F.
	Local   lImpCTe   := .F.
	Local   aHeadOut  := {}
	Local   aItens    := {}
	Local   xRetWs    := Nil
	Private nNNj	  := 0
	Private oTmp      := Nil
	Private oXML	  := Nil
	Default cResposta := ""

	If Empty(_ultNSU)
		_ultNSU := RUNSUCte(_cCNPJ)
	EndIf

/*
	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cted="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'
	cSoap += 	'<soapenv:Header/>'
	cSoap +=    	'<soapenv:Body>'
	cSoap +=       		'<cted:cteDistDFeInteresse>'
	cSoap +=          		'<cted:cteDadosMsg>'
	cSoap += 					'<distDFeInt xmlns="http://www.portalfiscal.inf.br/cte" versao="1.00">'
	cSoap += 						'<tpAmb>1</tpAmb>'
	cSoap += 						'<cUFAutor>'+_cUf+'</cUFAutor>'
	cSoap += 						'<CNPJ>'+_cCNPJ+'</CNPJ>'
	cSoap += 						'<distNSU>'
	cSoap += 							'<ultNSU>'+PadL(_ultNSU,15,"0")+'</ultNSU>'
	cSoap += 						'</distNSU>'
	cSoap += 					'</distDFeInt>'
	cSoap +=          '</cted:cteDadosMsg>'
	cSoap +=       '</cted:cteDistDFeInteresse>'
	cSoap +=    '</soapenv:Body>'
	cSoap += '/soapenv:Envelope>'

*/

	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cted="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'
	cSoap += 	'<soapenv:Header/>'
	cSoap += 		'<soapenv:Body>'
	cSoap += 			'<cted:cteDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/cte" versao="1.00">'
	cSoap += 				'<cted:cteDadosMsg>'
	cSoap += 					'<distDFeInt xmlns="http://www.portalfiscal.inf.br/cte" versao="1.00">'
	cSoap += 						'<tpAmb>1</tpAmb>'
	cSoap += 						'<cUFAutor>'+_cUf+'</cUFAutor>'
	cSoap += 						'<CNPJ>'+_cCNPJ+'</CNPJ>'
	cSoap += 						'<distNSU>'
	cSoap += 							'<ultNSU>'+PadL(_ultNSU,15,"0")+'</ultNSU>'
	cSoap += 						'</distNSU>'
	cSoap += 					'</distDFeInt>'
	cSoap += 				'</cted:cteDadosMsg>'
	cSoap += 		'</cted:cteDistDFeInteresse>'
	cSoap += 	'</soapenv:Body>'
	cSoap += '</soapenv:Envelope>'

	aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8 ')
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')') // Acrescenta o UserAgent na requisição ... '; '+WSDLCLIENT_VERSION+

	While ( ( xRetWs == Nil ) .And. nTries < 10 )
		nTries++
		xRetWs := HttpSPost(cURL, _cCertif, _cPrivKey, _cPass, "", cSoap, 120, aHeadOut, @cAviso, .F. )
		Sleep(2000)
	EndDo

	If xRetWs != Nil

		cError 		:= ""
		cWarning    := ""
		oTmp := XMLParser( xRetWs, "", @cError, @cWarning )

		If Type("oTmp") == "O"
			If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") == "C"
				//Se encontrou Documento
				If Alltrim(oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT) == "138"
					If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT") == "C"
						_ultNSU := oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT
						If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
							cResposta := xRetWs
						ElseIf Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT") == "C"
							cResposta := xRetWs
						Else
							cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _LOTEDISTDFEINT com _DOCZIP"
							ConOut(cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
						EndIf
					Else
						cResposta := "RESP: Problema no retorno do SEFAZ, não achou a tag _ULTNSU"
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					EndIf
				Else
					If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT") == "C"
						cResposta := "RESP: CTE - "+oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					Else
						cResposta := "RESP: CTE - Problema no retorno do SEFAZ, não achou a tag _XMOTIVO"
						ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
					EndIf
				EndIf
			Else
				cResposta := "RESP: CTE - Problema no retorno do SEFAZ, não achou a tag _CSTAT"
				ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
			EndIf
		Else
			cResposta := "RESP: CTE - Problema no retorno do SEFAZ"
			ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )
		EndIf

	Else

		cResposta := "RESP: CTE - Não foi possível consultar o SEFAZ"
		ConOut( cResposta + ": "+_cCNPJ+" - AlfSfz01.PRW em "+DtoC( Date() )+" "+Time() )

	Endif

	If Left(cResposta, 6) != "RESP: "								// Retornou valores

		cError   := ""
		cWarning := ""
		oTmp     := XMLParser( cResposta, "", @cError,@cWarning)	// efetua parse pra retornar o objeto

		If Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
			aItens := oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
		ElseIf Type("oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT") == "C"
			aItens := {oTmp:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT}
		Else
			aItens := {}
		EndIf

		For nNNj := 1 to len( aItens )

			cRespXML := U_xDescptDocZip(aItens[nNNj],_cCNPJ)

			If Left(cRespXML, 6) == "RESP: "								// Retornou valores

				Exit

			Else

				cError   := ""
				cWarning := ""
				oXml     := XMLParser( cRespXML, "", @cError,@cWarning)	// efetua parse pra retornar o objeto

				If Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT") == "C"

					If Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_CSTAT:TEXT") == "C"
					
						If oXml:_CTEPROC:_PROTCTE:_INFPROT:_CSTAT:TEXT == "100" //Autorizado

							lBxCte := .T.
						    lImpCTe := .F.
						    
							If Type("oXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") == "C"
								If Alltrim(oXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT) == Alltrim(SM0->M0_CGC)
									lImpCTe := .T.
								EndIf
							EndIf

							If Type("oXML:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT") == "C"
								If !lImpCTe
									If Alltrim(oXML:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT) == Alltrim(SM0->M0_CGC)
										lImpCTe := .T.
									EndIf
								EndIf
							EndIf
                    
							If lImpCTe
								ZDIIns( 	_cCNPJ,; 
											aItens[nNNj]:_NSU:TEXT,; 
											oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT,; 
											"CTEPROC",; 
											Alltrim(cRespXML),; 
											"",; 
											_cUf,; 
											"",; 
											DtoS(dDataBase),; 
											StrTran( oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT, "-", "" ),; 
											Substr( oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT,12) )
                            EndIf
                            
						EndIf

					EndIf

				EndIf
				
				If cUltNSU < aItens[nNNj]:_NSU:TEXT
					cUltNSU := aItens[nNNj]:_NSU:TEXT
				EndIf

			EndIf

		Next nNNj
		
		// Grava ultimo NSU na tabela de configuração ZDG
		If !Empty(cUltNSU)
			GrvNSU(_cCNPJ, cUltNSU, "CTE")
		EndIf

		oXml   := nil
		aItens := nil

	Endif
	
	U_AtMnCte(_cCNPJ)

Return(lBxCTe)



User Function AtMnCte(_cCNPJ)
Local cQry := ""
Local cError := ""
Local cWarning := ""
Local cStMon := ""
Local cMsg := ""
Local cGrPNCTe := SuperGetMV("AF_GPNFCTE",,"S")
Local nNx := 0
Local aRtVCte := {}
Local aAtuArea := GetArea()
Local aZDIArea := ZDI->(GetArea())
Local aRecZDI := {}
Private oCte := Nil

cQry := "SELECT ZDI.R_E_C_N_O_ AS ZDIRECNO "
cQry += "FROM "+RetSqlName("ZDI")+ " ZDI WHERE ZDI.D_E_L_E_T_ = ' ' "
cQry += "AND ZDI.ZDI_FILIAL = '"+xFilial("ZDI")+"' "
cQry += "AND ZDI.ZDI_CONTA = '"+_cCNPJ+"' "
cQry += "AND ZDI.ZDI_TPXML = 'CTEPROC                       ' "
cQry += "AND ZDI.ZDI_STATUS = '                    ' "
cQry += "ORDER BY ZDI.R_E_C_N_O_"

Iif(Select("WKXZDI")>0,WKXZDI->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKXZDI",.T.,.T.)
TcSetField("WKXZDI","ZDIRECNO","N",14,0)
WKXZDI->(dbGoTop())

While WKXZDI->(!EoF())
	aAdd( aRecZDI, WKXZDI->ZDIRECNO )
	WKXZDI->(dbSkip())
EndDo
WKXZDI->(dbCloseArea())

If Len(aRecZDI) > 0

	dbSelectArea("ZDI")
	ZDI->(dbSetOrder(1))

	For nNx := 1 to Len(aRecZDI)

		ZDI->(dbGoTo(aRecZDI[nNx]))

		If ZDI->(RecNo()) == aRecZDI[nNx]

			cStMon := ""
			cMsg := ""
			oCTe := XMLParser( ZDI->ZDI_XML, "", @cError, @cWarning )
			
			If Type("oCTe") == "O"
			
				aRtVCte := U_ChkCTeBD( oCTe:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT )
				
				If Empty( aRtVCte[1] )
					cMsg := U_GrvMnCte( _cCNPJ, oCTe )
					If Empty(cMsg)
						cStMon := "T"
						cMsg := "CTe - incluido no monitor"
					Else
						cStMon := "T"
					EndIf
				Else
					cStMon := "T"
					cMsg := aRtVCte[1]
			    EndIf
				U_AtStCTe( oCTe:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT, cMsg, cStMon )

				If cGrPNCTe == "S"

					cStMon := ""
					cMsg := ""
					If Empty( aRtVCte[2] )
					    cMsg := U_GrvPNCte( _cCNPJ, oCTe:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT )
					    If Empty(cMsg)
							cStMon := "Y"
							cMsg := "Nota gerada para este CTe"
						Else
							cStMon := "W"
					    EndIf
					Else
	                    cStMon := "Y"
	                    cMsg := aRtVCte[2]
				    EndIf
				    U_AtStCTe( oCTe:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT, cMsg, cStMon )

				EndIf

			EndIf
			
		EndIf

	Next nNx

EndIf

Return(Nil)



Static Function RUNSUCte(cCNPJ)
Local cQry := ""
Local xRet := 0

cQry := "SELECT ZDG_NSUCTE AS NSU FROM "+RetSqlName("ZDG")+" "
cQry += "WHERE D_E_L_E_T_ = ' ' "
cQry += "AND ZDG_FILIAL = '"+xFilial("ZDG")+"' "
cQry += "AND ZDG_CONTA = '"+cCNPJ+"' "

Iif(Select("WKXZDG")>0,WKXZDG->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKXZDG",.T.,.T.)
WKXZDG->(dbGoTop())

If WKXZDG->(!EoF())
	If !Empty(WKXZDG->NSU)
		xRet := Val(WKXZDG->NSU)
	EndIf
EndIf

xRet := StrZero((xRet+1),15)

Return(xRet)



User Function ChkCTeBD(cChvCTe)
Local cQry := ""
Local cMsgA := ""
Local cMsgB := ""

cQry := "SELECT ZDH_NUMNF AS ZDHNUMNF FROM "+RetSqlName("ZDH")+" "
cQry += "WHERE D_E_L_E_T_ = ' ' "
cQry += "AND ZDH_FILIAL = '"+xFilial("ZDH")+"' "
cQry += "AND ZDH_CHAVE = '"+cChvCTe+"' "

Iif(Select("WKXZDH")>0,WKXZDH->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKXZDH",.T.,.T.)
WKXZDH->(dbGoTop())

If WKXZDH->(!EoF())
	If !Empty(WKXZDH->ZDHNUMNF)
		cMsgA := "CTe ja consta do monitor"
	EndIf            
EndIf
WKXZDH->(dbCloseArea())

cQry := "SELECT TOP 1 F1.F1_DOC AS F1DOC, " 
cQry += "D1TES = ISNULL(( "
cQry += "SELECT TOP 1 D1.D1_TES AS D1TES FROM "+RetSqlName("SD1")+" D1 WHERE D1.D_E_L_E_T_ = ' ' "
cQry += "AND D1.D1_FILIAL = F1.F1_FILIAL "
cQry += "AND D1.D1_DOC = F1.F1_DOC "
cQry += "AND D1.D1_SERIE = F1.F1_SERIE "
cQry += "AND D1.D1_TIPO = F1.F1_TIPO "
cQry += "AND D1.D1_FORMUL = F1.F1_FORMUL "
cQry += "AND D1.D1_FORNECE = F1.F1_FORNECE "
cQry += "AND D1.D1_LOJA = F1.F1_LOJA "
cQry += "AND D1.D1_TES <> '   ' ),'') "
cQry += "FROM "+RetSqlName("SF1")+" F1 "
cQry += "WHERE F1.D_E_L_E_T_ = ' ' "
cQry += "AND F1.F1_FILIAL = '"+xFilial("SF1")+"' "
cQry += "AND F1.F1_CHVNFE = '"+cChvCTe+"' "
cQry += "AND F1.F1_DOC <> '         '"
Iif(Select("WKXSF1")>0,WKXSF1->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKXSF1",.T.,.T.)
WKXSF1->(dbGoTop())

If WKXSF1->(!EoF())
	If !Empty(WKXSF1->F1DOC)
		cMsgB := "Pre-Nota ja incluida para este CTe"
	EndIf
	If !Empty(WKXSF1->D1TES)
		cMsgB := "Nota gerada para este CTe"
	EndIf
EndIf
WKXSF1->(dbCloseArea())

Return( { cMsgA, cMsgB } )



User Function GrvMnCte( cCNPJ, oCTe, cXMLCte )
Local lRet := .T.
Local cMsg := ""
Local aAtuArea := GetArea()
Local aZDIArea := ZDI->(GetArea())
Local nId := GetIdZDH()
Local cUpd := ""
Local cObs := DtoC(dDataBase)+ " - " + Time() + ": CTe incluido no monitor."
Local cCNPJDest := ""
Default cXMLCTe := ""

If Empty(cXMLCTe)
	dbSelectArea("ZDI")
	ZDI->(dbSetOrder(3))
	If ZDI->(dbSeek(Alltrim(oCTe:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT)))
		cXMLCTe := ZDI->ZDI_XML
	EndIf
EndIf

If Type("oCTe:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ") <> "U"
	cCNPJDest := oCTe:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
EndIf
If Empty(cCNPJDest)
	If Type("oCTe:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF") <> "U"
		cCNPJDest := oCTe:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT
	EndIf
EndIf

BeginTran()

dbSelectArea("ZDH")
If ZDH->(RecLock("ZDH",.T.))
	ZDH->ZDH_FILIAL := xFilial("ZDH")
	ZDH->ZDH_ID := nId
	ZDH->ZDH_CHAVE := oCTe:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT
	ZDH->ZDH_NUMNF := StrZero(Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT),9)
	ZDH->ZDH_STATUS := "T" //Cte Incluido no monitor
	ZDH->ZDH_DTIMPO := dDataBase
	ZDH->ZDH_HRIMPO := Time()
	ZDH->ZDH_FORNEC := oCTe:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT
	ZDH->ZDH_SCHEMA := cXMLCTe
	ZDH->ZDH_MSGERR := "CTe incluido no Monitor"
	ZDH->(MsunLock())
Else
	lRet := .F.
EndIf

dbSelectArea("ZD2")
If ZD2->(RecLock("ZD2",.T.))
	ZD2->ZD2_FILIAL := xFilial("ZD2")
	ZD2->ZD2_NUMNF  := StrZero(Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT),9)
	ZD2->ZD2_SERIE  := StrZero(Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT),3)
	ZD2->ZD2_EMISSA := StoD(SubStr(oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,1,4)+SubStr(oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,6,2)+SubStr(oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,9,2))
	ZD2->ZD2_CHVNFE := oCTe:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT
	ZD2->ZD2_CNPJFO := oCTe:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
	ZD2->ZD2_CODFOR := ""
	ZD2->ZD2_LOJFOR := ""
	ZD2->ZD2_UFFORN := oCTe:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_UF:TEXT
	ZD2->ZD2_CNPJDE := cCNPJDest
	ZD2->ZD2_DTLOG  := dDataBase
	ZD2->ZD2_HRLOG  := Time()
	ZD2->ZD2_STATUS := "A"
	ZD2->ZD2_NATOPE := oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_NATOP:TEXT
	ZD2->ZD2_VBC    := Iif(Type("oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT")=="C",Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT),0)
	ZD2->ZD2_VICMS  := Iif(Type("oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT")=="C",Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT),0)
	ZD2->ZD2_VPROD  := Val(oCTe:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)
	ZD2->ZD2_VNF    := Val(oCTe:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)
	ZD2->(MsUnLock())
Else
	lRet := .F.
EndIf

dbSelectArea("ZD3")
If ZD3->(RecLock("ZD3",.T.))
	ZD3->ZD3_FILIAL := xFilial("ZD3")
	ZD3->ZD3_NUMNF  := StrZero(Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT),9)
	ZD3->ZD3_SERIE  := StrZero(Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT),3)
	ZD3->ZD3_CHVNFE := oCTe:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT
	ZD3->ZD3_CNPJFO := oCTe:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
	ZD3->ZD3_ITEMNF := "0001"
	ZD3->ZD3_CODFOR := ""
	ZD3->ZD3_LOJFOR := ""
	ZD3->ZD3_PRODP  := ""
	ZD3->ZD3_PRDFOR := "SERV TRANSP - CTE"
	ZD3->ZD3_DESFOR := "SERVICO DE TRANSPORTE - CTE"
	ZD3->ZD3_CFOP   := oCTe:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT
	ZD3->ZD3_UM     := "SV"
	ZD3->ZD3_QUANT  := 1
	ZD3->ZD3_VLRUNI := Val(oCTe:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)
	ZD3->ZD3_VLRTOT := Val(oCTe:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)
	ZD3->ZD3_CST    := Iif(Type("oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="C",oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT,"")
	ZD3->ZD3_BASICM := Iif(Type("oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT")=="C",Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT),0)
	ZD3->ZD3_VALICM := Iif(Type("oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT")=="C",Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT),0)
	ZD3->ZD3_PICM   := Iif(Type("oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT")=="C",Val(oCTe:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT),0)
	ZD3->(MsUnLock())
Else
	lRet := .F.
EndIf

If !lRet
	DisarmTransaction()
EndIf

EndTran()

If !lRet
	cMsg := "CTE - erro ao incluir no monitor"
EndIf

RestArea(aZDIArea)
RestArea(aAtuArea)

Return(cMsg)



User Function AtStCTe( cChvCTe, cMsg, cStatus )
Local cUpd := ""
Local lRet := .T.

cUpd := "UPDATE "+RetSqlName("ZDH")+" SET "
cUpd += "ZDH_MSGERR = '"+cMsg+"', "
cUpd += "ZDH_STATUS = '"+cStatus+"' "
cUpd += "WHERE D_E_L_E_T_ = ' ' "
cUpd += "AND ZDH_FILIAL = '"+xFilial("ZDH")+"' "
cUpd += "AND ZDH_CHAVE = '"+cChvCTe+"'"

lRet := ( TcSqlExec(cUpd) == 0 )

If lRet

	cUpd := "UPDATE "+RetSqlName("ZDI")+" SET "
	cUpd += "ZDI_STATUS = '"+cStatus+"' "
	cUpd += "WHERE D_E_L_E_T_ = ' ' "
	cUpd += "AND ZDI_FILIAL = '"+xFilial("ZDI")+"' "
	cUpd += "AND ZDI_CHVNFE = '"+cChvCTe+"'"

	lRet := ( TcSqlExec(cUpd) == 0 )

EndIf
	
Return(lRet)



Static Function GetIdZDH()
Local nRet := 0
Local cQry := ""

cQry := "SELECT ISNULL(MAX(ZDH_ID),0) AS MAXID "
cQry += "FROM "+RetSqlName("ZDH")+" "
cQry += "WHERE D_E_L_E_T_ = ' ' "
cQry += "AND ZDH_FILIAL = '"+xFilial("ZDH")+"' "

Iif(Select("WRMXID")>0,WRMXID->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRMXID",.T.,.T.)
TcSetField("WRMXID","MAXID","N",14,0)
WRMXID->(dbGoTop())

If WRMXID->(!EoF())
	If WRMXID->MAXID > 0
		nRet := WRMXID->MAXID + 1
	EndIf
EndIf
Iif(Select("WRMXID")>0,WRMXID->(dbCloseArea()),Nil)

If nRet == 0
	nRet := 1
EndIf

Return(nRet++)


//Deve estar posicionado na tabela ZDH
//Nao desposicionar ZDH
User Function GrvPNCte( cCNPJ, cChvCTe )
Local lRet := .T.
Local cQry := ""
Local cMsg := ""
Local cUM := ""
Local cTipo := ""
Local cLocal := ""
Local cCodFor := ""
Local cCodNat := ""
Local cTES := ""
Local cError := ""
Local cWarning := ""
Local cCodPro := ""
Local nZD2Rcn := 0
Local nZD3Rcn := 0
Local aCbNFe := {}
Local aItNFe := {}
Local aLiNFe := {}
Local nBICMS := 0
Local nVICMS := 0
Local nAICMS := 0
Local cModal := ""
Local cTpCTe := ""
Local cUFOritR := ""
Local cMuOritR := ""
Local cUFDestR := ""
Local cMuDestR := ""
Local cCFCTe := ""
Local cCFEnt := ""
Local aAtuArea := GetArea()
Local aZD2Area := ZD2->(GetArea())
Local aZD3Area := ZD3->(GetArea())
Private oCTePrc := Nil

cQry := "SELECT R_E_C_N_O_ AS ZD2RECNO "
cQry += "FROM "+RetSqlName("ZD2")+" WHERE D_E_L_E_T_ = ' ' "
cQry += "AND ZD2_FILIAL = '"+xFilial("ZD2")+"' "
cQry += "AND ZD2_CHVNFE = '"+cChvCTe+"' "

Iif(Select("WKBXZD2")>0,WKBXZD2->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKBXZD2",.T.,.T.)
TcSetField("WKBXZD2","ZD2RECNO","N",14,0)
WKBXZD2->(dbGoTop())

If WKBXZD2->(!EoF())
	If WKBXZD2->ZD2RECNO > 0
		nZD2Rcn := WKBXZD2->ZD2RECNO
	EndIf
EndIf
WKBXZD2->(dbCloseArea())

cQry := "SELECT R_E_C_N_O_ AS ZD3RECNO "
cQry += "FROM "+RetSqlName("ZD3")+" WHERE D_E_L_E_T_ = ' ' "
cQry += "AND ZD3_FILIAL = '"+xFilial("ZD3")+"' "
cQry += "AND ZD3_CHVNFE = '"+cChvCTe+"' "

Iif(Select("WKBXZD3")>0,WKBXZD3->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKBXZD3",.T.,.T.)
TcSetField("WKBXZD3","ZD3RECNO","N",14,0)
WKBXZD3->(dbGoTop())

If WKBXZD3->(!EoF())
	If WKBXZD3->ZD3RECNO > 0
		nZD3Rcn := WKBXZD3->ZD3RECNO
	EndIf
EndIf
WKBXZD3->(dbCloseArea())

If ( nZD2Rcn > 0 .And. nZD3Rcn > 0 )

	dbSelectArea("ZD2")
	ZD2->(dbGoTo(nZD2Rcn))
	If !( ZD2->(RecNo()) == nZD2Rcn )
	  	lRet := .F.
	  	cMsg := "Erro na tabela do monitor - ZD2"
	EndIf
	
	If lRet
		dbSelectArea("ZD3")
		ZD3->(dbGoTo(nZD3Rcn))
		If !( ZD3->(RecNo()) == nZD3Rcn )
		  	lRet := .F.
		  	cMsg := "Erro na tabela do monitor - ZD2"
		EndIf
	EndIf

EndIf

If lRet
	
	cQry := "SELECT F1_DOC AS F1DOC "
	cQry += "FROM "+RetSqlName("SF1")+" WHERE D_E_L_E_T_ = ' ' "
	cQry += "AND F1_CHVNFE = '"+cChvCTe+"' "
	
	Iif(Select("WKBXSF1")>0,WKBXSF1->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKBXSF1",.T.,.T.)
	WKBXSF1->(dbGoTop())
	
	If WKBXSF1->(!EoF())
		If !Empty(WKBXSF1->F1DOC)
			lRet := .F.
		  	cMsg := "Nota ja gerada para este CTe"
		EndIf
	EndIf
	WKBXSF1->(dbCloseArea())

EndIf

If lRet

	cQry := "SELECT "
	cQry += "A2_COD AS A2COD, "
	cQry += "A2_LOJA AS A2LOJA, "
	cQry += "A2_MSBLQL AS A2MSBLQL "
	cQry += "FROM "+RetSqlName("SA2")+" WHERE D_E_L_E_T_ = ' ' "
	cQry += "AND A2_FILIAL = '"+xFilial("SA2")+"' "
	cQry += "AND A2_CGC = '"+ZD2->ZD2_CNPJFO+"' "
	
	Iif(Select("WKBXSA2")>0,WKBXSA2->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKBXSA2",.T.,.T.)
	WKBXSA2->(dbGoTop())
	
	If WKBXSA2->(!EoF())
		If !Empty(WKBXSA2->A2COD)
			cCodFor := WKBXSA2->A2COD
			cLojFor := WKBXSA2->A2LOJA
			If WKBXSA2->A2MSBLQL == "1"
				lRet := .F.
				cMsg := "Fornecedor/Transportador bloqueado"
			EndIf
		EndIf
	EndIf
	WKBXSA2->(dbCloseArea())
	                       
	If Empty(cCodFor)
		lRet := .F.
		cMsg := "Fornecedor/Transportador nao cadastrado"
	EndIf

EndIf

If lRet

	cQry := "SELECT F1_DOC AS F1DOC "
	cQry += "FROM "+RetSqlName("SF1")+" WHERE D_E_L_E_T_ = ' ' "
	cQry += "AND F1_FILIAL = '"+xFilial("SF1")+"' "
	cQry += "AND F1_FORNECE = '"+cCodFor+"' "
	cQry += "AND F1_LOJA = '"+cLojFor+"' "
	cQry += "AND CONVERT( INT, F1_DOC ) = "+Alltrim(Str(Val(ZD2->ZD2_NUMNF)))+" "
	cQry += "AND CONVERT( INT, F1_SERIE ) = "+Alltrim(Str(Val(ZD2->ZD2_SERIE)))+" "
//	cQry += "AND F1_TIPO = 'N' "
//	cQry += "AND F1_ESPECIE = 'CTE' "
	
	Iif(Select("WKCXSF1")>0,WKCXSF1->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKCXSF1",.T.,.T.)
	WKCXSF1->(dbGoTop())
	
	If WKCXSF1->(!EoF())
		If !Empty(WKCXSF1->F1DOC)
			lRet := .F.
			cMsg := "Nota ja gerada para este CTe"
		EndIf
	EndIf
	WKCXSF1->(dbCloseArea())

EndIf


If lRet

	oCTePrc := XMLParser( ZDH->ZDH_SCHEMA, "", @cError, @cWarning )
	
	If Type("oCTePrc") == "O"

		nBICMS := Iif(Type("oCTePrc:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT")=="C",Val(oCTePrc:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT),0)
		nVICMS := Iif(Type("oCTePrc:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT")=="C",Val(oCTePrc:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT),0)
		nAICMS := Iif(Type("oCTePrc:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT")=="C",Val(oCTePrc:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT),0)
		cCFCTe := oCTePrc:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT
		cModal := oCTePrc:_CTEPROC:_CTE:_INFCTE:_IDE:_MODAL:TEXT
		cTpCTe := oCTePrc:_CTEPROC:_CTE:_INFCTE:_IDE:_TPCTE:TEXT
		cUFOritR := oCTePrc:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT
		cMuOritR := SubStr(oCTePrc:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNINI:TEXT,3,5)
		cUFDestR := oCTePrc:_CTEPROC:_CTE:_INFCTE:_IDE:_UFFIM:TEXT
		cMuDestR := SubStr(oCTePrc:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNFIM:TEXT,3,5)

	Else

		lRet := .F.
		cMsg := "Nao foi possivel obter o XML deste CTe"

	EndIf

EndIf

If lRet

	GTEPCTE( nAICMS, cUFOritR, @cTES, @cCodPro )

	If Empty(cTES)

		lRet := .F.
		cMsg := "Nao foi possível obter o TES para gerar a nota para este CTe. Verique a tabela generica "+SuperGetMV("DT_CTEX5TB",,"#2") + " (SX5)"

	EndIf

	If Empty(cCodPro)

		lRet := .F.
		cMsg := "Nao foi possível obter o codigo de produto para gerar a nota para este CTe. Verique a tabela generica "+SuperGetMV("DT_CTEX5TB",,"#2") + " (SX5)"

	EndIf
	
	cCFEnt := Alltrim( Str( Val(cCFCTe) - 4000 ) )

EndIf


If lRet

	cQry := "SELECT "
	cQry += "B1_COD AS B1COD, "
	cQry += "B1_UM AS B1UM, "
	cQry += "B1_TIPO AS B1TIPO, "
	cQry += "B1_LOCPAD AS B1LOCPAD, "
	cQry += "B1_TE AS B1TE, "
	cQry += "B1_MSBLQL AS B1MSBLQL "
	cQry += "FROM "+RetSqlName("SB1")+" WHERE D_E_L_E_T_ = ' ' "
	cQry += "AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQry += "AND B1_COD = '"+cCodPro+"' "
	
	Iif(Select("WKBXSB1")>0,WKBXSB1->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKBXSB1",.T.,.T.)
	WKBXSB1->(dbGoTop())
	
	If WKBXSB1->(!EoF())
		If !Empty(WKBXSB1->B1COD)
			cUM := WKBXSB1->B1UM
			cLocal := WKBXSB1->B1LOCPAD
			cTipo := WKBXSB1->B1TIPO
			If Empty(cTES)
				cTES := WKBXSB1->B1TE
			EndIf
			If WKBXSB1->B1MSBLQL == "1"
				lRet := .F.
				cMsg := "Produto bloqueado: "+Alltrim(cCodPro)
			EndIf
		Else
			lRet := .F.
			cMsg := "Produto "+Alltrim(cCodPro)+" nao cadastrado"
		EndIf
	Else
		lRet := .F.
		cMsg := "Produto "+Alltrim(cCodPro)+" nao cadastrado"
	EndIf
	WKBXSB1->(dbCloseArea())
	
EndIf


//Gera Documento Fiscal
If lRet

	If cTpCTe == "0"
		cTpCTe := "N"
	ElseIf cTpCTe == "1"
		cTpCTe := "C"
	ElseIf cTpCTe == "2"
		cTpCTe := "A"
	ElseIf cTpCTe == "3"
		cTpCTe := "S"
	Else
		cTpCTe := ""
	EndIf

	aAdd( aCbNFe, { "F1_FILIAL" 	, ZD2->ZD2_FILIAL						, Nil	, POSICIONE("SX3",2,"F1_FILIAL"		, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_TIPO" 		, "N" 									, Nil	, POSICIONE("SX3",2,"F1_TIPO" 		, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_FORMUL" 	, "N" 									, Nil	, POSICIONE("SX3",2,"F1_FORMUL" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_DOC" 		, ZD2->ZD2_NUMNF						, Nil	, POSICIONE("SX3",2,"F1_DOC" 		, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_SERIE" 		, Alltrim(Str(Val(ZD2->ZD2_SERIE)))	, Nil	, POSICIONE("SX3",2,"F1_SERIE" 		, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_EMISSAO" 	, ZD2->ZD2_EMISSA 						, Nil	, POSICIONE("SX3",2,"F1_EMISSAO" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_FORNECE" 	, cCodFor		 						, Nil	, POSICIONE("SX3",2,"F1_FORNECE" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_LOJA" 		, cLojFor 								, Nil	, POSICIONE("SX3",2,"F1_LOJA" 		, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_ESPECIE" 	, "CTE" 								, Nil	, POSICIONE("SX3",2,"F1_ESPECIE" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_VALMERC" 	, ZD2->ZD2_VPROD 						, Nil	, POSICIONE("SX3",2,"F1_VALMERC" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_VALBRUT" 	, ZD2->ZD2_VNF 							, Nil	, POSICIONE("SX3",2,"F1_VALBRUT" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_CHVNFE" 	, ZD2->ZD2_CHVNFE 						, Nil	, POSICIONE("SX3",2,"F1_CHVNFE" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_MODAL" 		, cModal 								, Nil	, POSICIONE("SX3",2,"F1_MODAL" 		, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_TPCTE" 		, cTpCTe 								, Nil	, POSICIONE("SX3",2,"F1_TPCTE" 		, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_UFORITR" 	, cUFOritR 								, Nil	, POSICIONE("SX3",2,"F1_UFORITR" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_MUORITR" 	, cMuOritR 								, Nil	, POSICIONE("SX3",2,"F1_MUORITR"	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_UFDESTR" 	, cUFDestR 								, Nil	, POSICIONE("SX3",2,"F1_UFDESTR" 	, "X3_ORDEM") } )
	aAdd( aCbNFe, { "F1_MUDESTR" 	, cMuDestR 								, Nil	, POSICIONE("SX3",2,"F1_MUDESTR" 	, "X3_ORDEM") } )
	If !Empty(cCodNat)
		aAdd( aCbNFe, { "E2_NATUREZ", cCodNat								, Nil	, "999999" } )
	EndIf
		
	aSort(aCbNFe,,,{|x,y| x[4] < y[4] })

	aAdd( aLiNFe, { "D1_FILIAL"	, ZD3->ZD3_FILIAL		, Nil	, POSICIONE("SX3",2,"D1_FILIAL" 	, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_ITEM"	, "01"					, Nil	, POSICIONE("SX3",2,"D1_ITEM" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_COD"	, cCodPro				, Nil	, POSICIONE("SX3",2,"D1_COD" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_UM"		, cUM					, Nil	, POSICIONE("SX3",2,"D1_UM" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_QUANT"	, 1						, Nil	, POSICIONE("SX3",2,"D1_QUANT" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_VUNIT"	, ZD3->ZD3_VLRTOT		, Nil	, POSICIONE("SX3",2,"D1_VUNIT" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_TOTAL"	, ZD3->ZD3_VLRTOT		, Nil	, POSICIONE("SX3",2,"D1_TOTAL" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_PICM"	, nAICMS				, Nil	, POSICIONE("SX3",2,"D1_PICM" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_BASEICM", ZD3->ZD3_BASICM		, Nil	, POSICIONE("SX3",2,"D1_BASEICM" 	, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_VALICM"	, ZD3->ZD3_VALICM		, Nil	, POSICIONE("SX3",2,"D1_VALICM" 	, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_TES"	, cTES					, Nil	, POSICIONE("SX3",2,"D1_TES" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "D1_CF"		, cCFEnt				, Nil	, POSICIONE("SX3",2,"D1_CF" 		, "X3_ORDEM") } )
	aAdd( aLiNFe, { "AUTDELETA" , "N" 					, Nil 	, "999999" } )

	aSort( aLiNFe,,,{|x,y| x[4] < y[4] })
	aAdd( aItNFe, aLiNFe )

	BeginTran()
	
		lMsErroAuto := .F.
		lMsHelpAuto	:= .T.

		MsExecAuto( {|x,y,z| MATA103(x,y,z) }, aCbNFe, aItNFe, 3, .F.)

		If lMsErroAuto

	        lRet := .F.
	        FwMakeDir("\ErrorLog\")
	   		cMsg := Mostraerro("\ErrorLog\")
	        
		EndIf
		
		If lRet
			lRet := TcSqlExec("UPDATE "+RetSqlName("ZD2")+" SET ZD2_CODFOR = '"+cCodFor+"', ZD2_LOJFOR = '"+cLojFor+"' WHERE D_E_L_E_T_ = ' ' AND ZD2_CHVNFE = '"+cChvCTe+"'") == 0
		EndIf
	
		If lRet
			lRet := TcSqlExec("UPDATE "+RetSqlName("ZD3")+" SET ZD3_CODFOR = '"+cCodFor+"', ZD3_LOJFOR = '"+cLojFor+"' WHERE D_E_L_E_T_ = ' ' AND ZD3_CHVNFE = '"+cChvCTe+"'") == 0
		EndIf
	
		If !lRet
			DisarmTransaction()
		EndIf
	
	EndTran()

EndIf
	
If !lRet
	/*
	cSubj := "Monitor XML - Erro ao Gerar Pré-Nota "+Alltrim(ZD2->ZD2_NUMNF)+" - "+Alltrim(ZDH->ZDH_FORNEC)
	cBody += '</p><font face="Arial">Prezado(a):</font></p>'
	cBody += '</p><font face="Arial"></font></p>'
	cBody += '</p><font face="Arial">O XML da NFe '+Alltrim(ZD2->ZD2_NUMNF)+' - '+Alltrim(ZDH->ZDH_FORNEC)+' foi importado para o Monitor XML, porem nao foi possivel gerar a Pre-Nota, pelo motivo abaixo:</font></p>'
	cBody += '</p><font face="Arial"> </font></p>'
	cBody += '</p><font face="Arial">'+Alltrim(aNFe[4])+'</font></p>'
	cBody += '</p><font face="Arial"></font></p>'
	cBody += '</p><font face="Arial">Obs.: está é uma mensagem automática gerada pelo sistema Protheus, não responda este e-mail.</font></p>'
	U_DNEnvEMail( Nil, cToGrvPNF, cSubj, cBody)
    */
EndIf

RestArea(aZD3Area)
RestArea(aZD2Area)
RestArea(aAtuArea)

dbSelectArea("ZDH")

Return(cMsg)



Static Function GTEPCTE( nAliqICMS, cUFIni, cTES, cCodPro )
Local cQry := ""
Local cRet := ""
Local cTabSX5 := SuperGetMV("DT_CTEX5TB",,"#2") // Tabela do SX5 com as regras de TES e produto
Local cChvSX5 := ""

cChvSX5 := StrZero( nAliqICMS * 100 , 4 )

If cUFIni <> "SP"
	cChvSX5 += "**"
Else
	cChvSX5 += "SP"
EndIf

cQry := "SELECT X5_DESCRI AS X5DESCRI "
cQry += "FROM "+RetSqlName("SX5")+" WHERE D_E_L_E_T_ = ' ' "
cQry += "AND X5_FILIAL = '"+xFilial("SX5")+"' "
cQry += "AND X5_TABELA = '"+cTabSX5+"' "
cQry += "AND X5_CHAVE = '"+cChvSX5+"' " // Ex.: '1200SP'

Iif(Select("WKBWX5")>0,WKBWX5->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKBWX5",.T.,.T.)
WKBWX5->(dbGoTop())

If WKBWX5->(!EoF())
	If !Empty(WKBWX5->X5DESCRI)
		cRet := Alltrim(WKBWX5->X5DESCRI)
	EndIf
EndIf
WKBWX5->(dbCloseArea())

If !Empty(cRet)

	cTES := SubStr(cRet,1,3)
	cCodPro := PadR(Alltrim(SubStr(cRet,5,16)),16)

EndIf

Return(Nil)