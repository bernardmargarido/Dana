#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl
Gerado em        05/05/15 08:07:49
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OEZSMNE ; Return  // "dummy" function - Internal Use 


/* ====================== SERVICE WARNING MESSAGES ======================
Definition for destinatario as complexType NOT FOUND. This Object HAS NO RETURN.
====================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSSigep
------------------------------------------------------------------------------- */

WSCLIENT WSSigep

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD validaEtiquetaPLP
	WSMETHOD fechaPlp
	WSMETHOD verificaDisponibilidadeServico
	WSMETHOD registrarPedidosInformacao
	WSMETHOD bloquearObjeto
	WSMETHOD buscaCliente
	WSMETHOD solicitaEtiquetas
	WSMETHOD obterMensagemRetornoPI
	WSMETHOD consultarPedidosInformacao
	WSMETHOD geraDigitoVerificadorEtiquetas
	WSMETHOD validarPostagemReversa
	WSMETHOD fechaPlpVariosServicos
	WSMETHOD validaPlp
	WSMETHOD validarPostagemSimultanea
	WSMETHOD obterEmbalagemLRS
	WSMETHOD cancelarPedidoScol
	WSMETHOD buscaServicos
	WSMETHOD solicitarPostagemScol
	WSMETHOD solicitaPLP
	WSMETHOD getStatusCartaoPostagem
	WSMETHOD solicitaXmlPlp
	WSMETHOD obterMotivosPI
	WSMETHOD buscaContrato
	WSMETHOD consultaSRO
	WSMETHOD obterClienteAtualizacao
	WSMETHOD integrarUsuarioScol
	WSMETHOD atualizaPLP
	WSMETHOD obterAssuntosPI
	WSMETHOD consultaCEP

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cnumeroEtiqueta           AS string
	WSDATA   nidPlp                    AS long
	WSDATA   cusuario                  AS string
	WSDATA   csenha                    AS string
	WSDATA   lreturn                   AS boolean
	WSDATA   cxml                      AS string
	WSDATA   nidPlpCliente             AS long
	WSDATA   ccartaoPostagem           AS string
	WSDATA   cfaixaEtiquetas           AS string
	WSDATA   ncodAdministrativo        AS int
	WSDATA   cnumeroServico            AS string
	WSDATA   ccepOrigem                AS string
	WSDATA   ccepDestino               AS string
	WSDATA   oWSpedidosInformacao      AS AtendeClienteService_pedidoInformacaoRegistro
	WSDATA   oWSretorno                AS AtendeClienteService_retorno
	WSDATA   oWStipoBloqueio           AS AtendeClienteService_tipoBloqueio
	WSDATA   oWSacao                   AS AtendeClienteService_acao
	WSDATA   cidContrato               AS string
	WSDATA   cidCartaoPostagem         AS string
	WSDATA   oWSclienteERP             AS AtendeClienteService_clienteERP
	WSDATA   ctipoDestinatario         AS string
	WSDATA   cidentificador            AS string
	WSDATA   nidServico                AS long
	WSDATA   nqtdEtiquetas             AS int
	WSDATA   oWSmensagemRetornoPIMaster AS AtendeClienteService_mensagemRetornoPIMaster
	WSDATA   cetiquetas                AS string
	WSDATA   ncodigoServico            AS int
	WSDATA   ccepDestinatario          AS string
	WSDATA   oWScoleta                 AS AtendeClienteService_coletaReversaTO
	WSDATA   clistaEtiquetas           AS ListEtq_ArrayOfList
	WSDATA   ncliente                  AS long
	WSDATA   cnumero                   AS string
	WSDATA   ndiretoria                AS long
	WSDATA   ccartao                   AS string
	WSDATA   cunidadePostagem          AS string
	WSDATA   nservico                  AS long
	WSDATA   cservicosAdicionais       AS string
	WSDATA   oWSembalagemLRSMaster     AS AtendeClienteService_embalagemLRSMaster
	WSDATA   cidPostagem               AS string
	WSDATA   ctipo                     AS string
	WSDATA   oWSretornoCancelamentoTO  AS AtendeClienteService_retornoCancelamentoTO
	WSDATA   oWSservicoERP             AS AtendeClienteService_servicoERP
	WSDATA   nidPlpMaster              AS long
	WSDATA   cnumEtiqueta              AS string
	WSDATA   cnumeroCartaoPostagem     AS string
	WSDATA   oWSstatusCartao           AS AtendeClienteService_statusCartao
	WSDATA   oWSmotivoPIMaster         AS AtendeClienteService_motivoPIMaster
	WSDATA   oWScontratoERP            AS AtendeClienteService_contratoERP
	WSDATA   clistaObjetos             AS string
	WSDATA   ctipoConsulta             AS string
	WSDATA   ctipoResultado            AS string
	WSDATA   cusuarioSro               AS string
	WSDATA   csenhaSro                 AS string
	WSDATA   ccnpjCliente              AS string
	WSDATA   oWSassuntoPIMaster        AS AtendeClienteService_assuntoPIMaster
	WSDATA   ccep                      AS string
	WSDATA   oWSenderecoERP            AS AtendeClienteService_enderecoERP
	WSDATA 	 creturn				   AS String
	WSDATA   nreturn				   AS Int	
	
ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSigep
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20131106] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSigep
	::oWSpedidosInformacao := {} // Array Of  AtendeClienteService_PEDIDOINFORMACAOREGISTRO():New()
	::oWSretorno         := {} // Array Of  AtendeClienteService_RETORNO():New()
	::oWStipoBloqueio    := AtendeClienteService_TIPOBLOQUEIO():New()
	::oWSacao            := AtendeClienteService_ACAO():New()
	::oWSclienteERP      := AtendeClienteService_CLIENTEERP():New()
	::oWSmensagemRetornoPIMaster := {} // Array Of  AtendeClienteService_MENSAGEMRETORNOPIMASTER():New()
	::oWScoleta          := AtendeClienteService_COLETAREVERSATO():New()
	::oWSembalagemLRSMaster := {} // Array Of  AtendeClienteService_EMBALAGEMLRSMASTER():New()
	::oWSretornoCancelamentoTO := AtendeClienteService_RETORNOCANCELAMENTOTO():New()
	::oWSservicoERP      := {} // Array Of  AtendeClienteService_SERVICOERP():New()
	::oWSstatusCartao    := AtendeClienteService_STATUSCARTAO():New()
	::oWSmotivoPIMaster  := {} // Array Of  AtendeClienteService_MOTIVOPIMASTER():New()
	::oWScontratoERP     := AtendeClienteService_CONTRATOERP():New()
	::oWSassuntoPIMaster := {} // Array Of  AtendeClienteService_ASSUNTOPIMASTER():New()
	::oWSenderecoERP     := AtendeClienteService_ENDERECOERP():New()
Return

WSMETHOD RESET WSCLIENT WSSigep
	::cnumeroEtiqueta    := NIL 
	::nidPlp             := NIL 
	::cusuario           := NIL 
	::csenha             := NIL 
	::lreturn            := NIL 
	::cxml               := NIL 
	::nidPlpCliente      := NIL 
	::ccartaoPostagem    := NIL 
	::cfaixaEtiquetas    := NIL 
	::ncodAdministrativo := NIL 
	::cnumeroServico     := NIL 
	::ccepOrigem         := NIL 
	::ccepDestino        := NIL 
	::oWSpedidosInformacao := NIL 
	::oWSretorno         := NIL 
	::oWStipoBloqueio    := NIL 
	::oWSacao            := NIL 
	::cidContrato        := NIL 
	::cidCartaoPostagem  := NIL 
	::oWSclienteERP      := NIL 
	::ctipoDestinatario  := NIL 
	::cidentificador     := NIL 
	::nidServico         := NIL 
	::nqtdEtiquetas      := NIL 
	::oWSmensagemRetornoPIMaster := NIL 
	::cetiquetas         := NIL 
	::ncodigoServico     := NIL 
	::ccepDestinatario   := NIL 
	::oWScoleta          := NIL 
	::clistaEtiquetas    := NIL 
	::ncliente           := NIL 
	::cnumero            := NIL 
	::ndiretoria         := NIL 
	::ccartao            := NIL 
	::cunidadePostagem   := NIL 
	::nservico           := NIL 
	::cservicosAdicionais := NIL 
	::oWSembalagemLRSMaster := NIL 
	::cidPostagem        := NIL 
	::ctipo              := NIL 
	::oWSretornoCancelamentoTO := NIL 
	::oWSservicoERP      := NIL 
	::nidPlpMaster       := NIL 
	::cnumEtiqueta       := NIL 
	::cnumeroCartaoPostagem := NIL 
	::oWSstatusCartao    := NIL 
	::oWSmotivoPIMaster  := NIL 
	::oWScontratoERP     := NIL 
	::clistaObjetos      := NIL 
	::ctipoConsulta      := NIL 
	::ctipoResultado     := NIL 
	::cusuarioSro        := NIL 
	::csenhaSro          := NIL 
	::ccnpjCliente       := NIL 
	::oWSassuntoPIMaster := NIL 
	::ccep               := NIL 
	::oWSenderecoERP     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSigep
Local oClone := WSSigep():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:cnumeroEtiqueta := ::cnumeroEtiqueta
	oClone:nidPlp        := ::nidPlp
	oClone:cusuario      := ::cusuario
	oClone:csenha        := ::csenha
	oClone:lreturn       := ::lreturn
	oClone:cxml          := ::cxml
	oClone:nidPlpCliente := ::nidPlpCliente
	oClone:ccartaoPostagem := ::ccartaoPostagem
	oClone:cfaixaEtiquetas := ::cfaixaEtiquetas
	oClone:ncodAdministrativo := ::ncodAdministrativo
	oClone:cnumeroServico := ::cnumeroServico
	oClone:ccepOrigem    := ::ccepOrigem
	oClone:ccepDestino   := ::ccepDestino
	oClone:oWSpedidosInformacao :=  IIF(::oWSpedidosInformacao = NIL , NIL ,::oWSpedidosInformacao:Clone() )
	oClone:oWSretorno    :=  IIF(::oWSretorno = NIL , NIL ,::oWSretorno:Clone() )
	oClone:oWStipoBloqueio :=  IIF(::oWStipoBloqueio = NIL , NIL ,::oWStipoBloqueio:Clone() )
	oClone:oWSacao       :=  IIF(::oWSacao = NIL , NIL ,::oWSacao:Clone() )
	oClone:cidContrato   := ::cidContrato
	oClone:cidCartaoPostagem := ::cidCartaoPostagem
	oClone:oWSclienteERP :=  IIF(::oWSclienteERP = NIL , NIL ,::oWSclienteERP:Clone() )
	oClone:ctipoDestinatario := ::ctipoDestinatario
	oClone:cidentificador := ::cidentificador
	oClone:nidServico    := ::nidServico
	oClone:nqtdEtiquetas := ::nqtdEtiquetas
	oClone:oWSmensagemRetornoPIMaster :=  IIF(::oWSmensagemRetornoPIMaster = NIL , NIL ,::oWSmensagemRetornoPIMaster:Clone() )
	oClone:cetiquetas    := ::cetiquetas
	oClone:ncodigoServico := ::ncodigoServico
	oClone:ccepDestinatario := ::ccepDestinatario
	oClone:oWScoleta     :=  IIF(::oWScoleta = NIL , NIL ,::oWScoleta:Clone() )
	oClone:clistaEtiquetas := ::clistaEtiquetas
	oClone:ncliente      := ::ncliente
	oClone:cnumero       := ::cnumero
	oClone:ndiretoria    := ::ndiretoria
	oClone:ccartao       := ::ccartao
	oClone:cunidadePostagem := ::cunidadePostagem
	oClone:nservico      := ::nservico
	oClone:cservicosAdicionais := ::cservicosAdicionais
	oClone:oWSembalagemLRSMaster :=  IIF(::oWSembalagemLRSMaster = NIL , NIL ,::oWSembalagemLRSMaster:Clone() )
	oClone:cidPostagem   := ::cidPostagem
	oClone:ctipo         := ::ctipo
	oClone:oWSretornoCancelamentoTO :=  IIF(::oWSretornoCancelamentoTO = NIL , NIL ,::oWSretornoCancelamentoTO:Clone() )
	oClone:oWSservicoERP :=  IIF(::oWSservicoERP = NIL , NIL ,::oWSservicoERP:Clone() )
	oClone:nidPlpMaster  := ::nidPlpMaster
	oClone:cnumEtiqueta  := ::cnumEtiqueta
	oClone:cnumeroCartaoPostagem := ::cnumeroCartaoPostagem
	oClone:oWSstatusCartao :=  IIF(::oWSstatusCartao = NIL , NIL ,::oWSstatusCartao:Clone() )
	oClone:oWSmotivoPIMaster :=  IIF(::oWSmotivoPIMaster = NIL , NIL ,::oWSmotivoPIMaster:Clone() )
	oClone:oWScontratoERP :=  IIF(::oWScontratoERP = NIL , NIL ,::oWScontratoERP:Clone() )
	oClone:clistaObjetos := ::clistaObjetos
	oClone:ctipoConsulta := ::ctipoConsulta
	oClone:ctipoResultado := ::ctipoResultado
	oClone:cusuarioSro   := ::cusuarioSro
	oClone:csenhaSro     := ::csenhaSro
	oClone:ccnpjCliente  := ::ccnpjCliente
	oClone:oWSassuntoPIMaster :=  IIF(::oWSassuntoPIMaster = NIL , NIL ,::oWSassuntoPIMaster:Clone() )
	oClone:ccep          := ::ccep
	oClone:oWSenderecoERP :=  IIF(::oWSenderecoERP = NIL , NIL ,::oWSenderecoERP:Clone() )
Return oClone

// WSDL Method validaEtiquetaPLP of Service WSSigep

WSMETHOD validaEtiquetaPLP WSSEND cnumeroEtiqueta,nidPlp,cusuario,csenha WSRECEIVE lreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<validaEtiquetaPLP xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("numeroEtiqueta", ::cnumeroEtiqueta, cnumeroEtiqueta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idPlp", ::nidPlp, nidPlp , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</validaEtiquetaPLP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::lreturn            :=  WSAdvValue( oXmlRet,"_VALIDAETIQUETAPLPRESPONSE:_RETURN:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method fechaPlp of Service WSSigep

WSMETHOD fechaPlp WSSEND cxml,nidPlpCliente,ccartaoPostagem,cfaixaEtiquetas,cusuario,csenha WSRECEIVE nreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

//cSoap += '<fechaPlp xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += '<cli:fechaPlp>'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idPlpCliente", ::nidPlpCliente, nidPlpCliente , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cartaoPostagem", ::ccartaoPostagem, ccartaoPostagem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("faixaEtiquetas", ::cfaixaEtiquetas, cfaixaEtiquetas , "ArrayOfList", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</cli:fechaPlp>"

oXmlRet := u_XSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente","cli")

/*
oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPC","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")
*/

_oResp := oXmlRet

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_FECHAPLPRESPONSE:_RETURN:TEXT","long",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method verificaDisponibilidadeServico of Service WSSigep

WSMETHOD verificaDisponibilidadeServico WSSEND ncodAdministrativo,cnumeroServico,ccepOrigem,ccepDestino,cusuario,csenha WSRECEIVE lreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<verificaDisponibilidadeServico xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("codAdministrativo", ::ncodAdministrativo, ncodAdministrativo , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numeroServico", ::cnumeroServico, cnumeroServico , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cepOrigem", ::ccepOrigem, ccepOrigem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cepDestino", ::ccepDestino, ccepDestino , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</verificaDisponibilidadeServico>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::lreturn            :=  WSAdvValue( oXmlRet,"_VERIFICADISPONIBILIDADESERVICORESPONSE:_RETURN:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method registrarPedidosInformacao of Service WSSigep

WSMETHOD registrarPedidosInformacao WSSEND oWSpedidosInformacao,cusuario,csenha WSRECEIVE oWSretorno WSCLIENT WSSigep
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<registrarPedidosInformacao xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("pedidosInformacao", ::oWSpedidosInformacao, oWSpedidosInformacao , "pedidoInformacaoRegistro", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</registrarPedidosInformacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REGISTRARPEDIDOSINFORMACAORESPONSE:_RETURN","retorno",NIL,NIL,NIL,NIL,NIL,"xs") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSretorno,AtendeClienteService_retorno():New()) , ::oWSretorno[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method bloquearObjeto of Service WSSigep

WSMETHOD bloquearObjeto WSSEND cnumeroEtiqueta,nidPlp,oWStipoBloqueio,oWSacao,cusuario,csenha WSRECEIVE creturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<bloquearObjeto xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("numeroEtiqueta", ::cnumeroEtiqueta, cnumeroEtiqueta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idPlp", ::nidPlp, nidPlp , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoBloqueio", ::oWStipoBloqueio, oWStipoBloqueio , "tipoBloqueio", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("acao", ::oWSacao, oWSacao , "acao", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</bloquearObjeto>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_BLOQUEAROBJETORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method buscaCliente of Service WSSigep

WSMETHOD buscaCliente WSSEND cidContrato,cidCartaoPostagem,cusuario,csenha WSRECEIVE oWSclienteERP WSCLIENT WSSigep
Local cSoap 		:= ""
Local oXmlRet		:= Nil

BEGIN WSMETHOD

cSoap += '<cli:buscaCliente>'
cSoap += WSSoapValue("idContrato", ::cidContrato, cidContrato , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idCartaoPostagem", ::cidCartaoPostagem, cidCartaoPostagem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.)
cSoap += "</cli:buscaCliente>" 

oXmlRet := u_XSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente","cli")

/*
oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")
*/

_oResp := oXmlRet

::Init()
::oWSclienteERP:SoapRecv( WSAdvValue( oXmlRet,"_NS2:_BUSCACLIENTERESPONSE:_RETURN","clienteERP",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method solicitaEtiquetas of Service WSSigep

WSMETHOD solicitaEtiquetas WSSEND ctipoDestinatario,cidentificador,nidServico,nqtdEtiquetas,cusuario,csenha WSRECEIVE creturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

//cSoap += '<solicitaEtiquetas xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += '<cli:solicitaEtiquetas>'
cSoap += WSSoapValue("tipoDestinatario", ::ctipoDestinatario, ctipoDestinatario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("identificador", ::cidentificador, cidentificador , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idServico", ::nidServico, nidServico , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("qtdEtiquetas", ::nqtdEtiquetas, nqtdEtiquetas , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.)
//cSoap += "</solicitaEtiquetas>" 
cSoap += "</cli:solicitaEtiquetas>"


/*
oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")
*/

oXmlRet := u_XSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente","cli")

_oResp := oXmlRet

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_SOLICITAETIQUETASRESPONSE:_RETURN:TEXT","return",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterMensagemRetornoPI of Service WSSigep

WSMETHOD obterMensagemRetornoPI WSSEND NULLPARAM WSRECEIVE oWSmensagemRetornoPIMaster WSCLIENT WSSigep
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<obterMensagemRetornoPI xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += "</obterMensagemRetornoPI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_OBTERMENSAGEMRETORNOPIRESPONSE:_RETURN","mensagemRetornoPIMaster",NIL,NIL,NIL,NIL,NIL,"xs") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSmensagemRetornoPIMaster,AtendeClienteService_mensagemRetornoPIMaster():New()) , ::oWSmensagemRetornoPIMaster[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method consultarPedidosInformacao of Service WSSigep

WSMETHOD consultarPedidosInformacao WSSEND oWSpedidosInformacao,cusuario,csenha WSRECEIVE oWSretorno WSCLIENT WSSigep
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<consultarPedidosInformacao xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("pedidosInformacao", ::oWSpedidosInformacao, oWSpedidosInformacao , "pedidoInformacaoConsulta", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</consultarPedidosInformacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_CONSULTARPEDIDOSINFORMACAORESPONSE:_RETURN","retorno",NIL,NIL,NIL,NIL,NIL,"xs") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSretorno,AtendeClienteService_retorno():New()) , ::oWSretorno[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method geraDigitoVerificadorEtiquetas of Service WSSigep

WSMETHOD geraDigitoVerificadorEtiquetas WSSEND cetiquetas,cusuario,csenha WSRECEIVE nreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

//cSoap += '<geraDigitoVerificadorEtiquetas xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += '<cli:geraDigitoVerificadorEtiquetas>'
cSoap += WSSoapValue("etiquetas", ::cetiquetas, cetiquetas , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.)
cSoap += "</cli:geraDigitoVerificadorEtiquetas>" 
//cSoap += "</geraDigitoVerificadorEtiquetas>"

oXmlRet := u_XSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente","cli")

_oResp := oXmlRet

/*
oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")
*/

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_GERADIGITOVERIFICADORETIQUETASRESPONSE:_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method validarPostagemReversa of Service WSSigep

WSMETHOD validarPostagemReversa WSSEND ncodAdministrativo,ncodigoServico,ccepDestinatario,oWScoleta,cusuario,csenha WSRECEIVE lreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<validarPostagemReversa xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("codAdministrativo", ::ncodAdministrativo, ncodAdministrativo , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("codigoServico", ::ncodigoServico, ncodigoServico , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cepDestinatario", ::ccepDestinatario, ccepDestinatario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("coleta", ::oWScoleta, oWScoleta , "coletaReversaTO", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</validarPostagemReversa>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::lreturn            :=  WSAdvValue( oXmlRet,"_VALIDARPOSTAGEMREVERSARESPONSE:_RETURN:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method fechaPlpVariosServicos of Service WSSigep

WSMETHOD fechaPlpVariosServicos WSSEND cxml,nidPlpCliente,ccartaoPostagem,clistaEtiquetas,cusuario,csenha WSRECEIVE nreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

//cSoap += '<cli:fechaPlpVariosServicos xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += '<cli:fechaPlpVariosServicos>'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idPlpCliente", ::nidPlpCliente, nidPlpCliente , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cartaoPostagem", ::ccartaoPostagem, ccartaoPostagem , "string", .F. , .F., 0 , NIL, .F.) 
For _nX := 1 To Len(_aFaixa)
	clistaEtiquetas := _aFaixa[_nX][1] 
	cSoap += WSSoapValue("listaEtiquetas", ::clistaEtiquetas, clistaEtiquetas , "string", .F. , .F., 0 , NIL, .F.)
Next _nX	 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</cli:fechaPlpVariosServicos>"

/*
oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

*/

oXmlRet := u_XSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente","cli")

_oResp := oXmlRet

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_FECHAPLPVARIOSSERVICOSRESPONSE:_RETURN:TEXT","long",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method validaPlp of Service WSSigep

WSMETHOD validaPlp WSSEND ncliente,cnumero,ndiretoria,ccartao,cunidadePostagem,nservico,cservicosAdicionais,cusuario,csenha WSRECEIVE lreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<validaPlp xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("cliente", ::ncliente, ncliente , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numero", ::cnumero, cnumero , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("diretoria", ::ndiretoria, ndiretoria , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cartao", ::ccartao, ccartao , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("unidadePostagem", ::cunidadePostagem, cunidadePostagem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("servico", ::nservico, nservico , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("servicosAdicionais", ::cservicosAdicionais, cservicosAdicionais , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</validaPlp>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::lreturn            :=  WSAdvValue( oXmlRet,"_VALIDAPLPRESPONSE:_RETURN:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method validarPostagemSimultanea of Service WSSigep

WSMETHOD validarPostagemSimultanea WSSEND ncodAdministrativo,ncodigoServico,ccepDestinatario,oWScoleta,cusuario,csenha WSRECEIVE lreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<validarPostagemSimultanea xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("codAdministrativo", ::ncodAdministrativo, ncodAdministrativo , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("codigoServico", ::ncodigoServico, ncodigoServico , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cepDestinatario", ::ccepDestinatario, ccepDestinatario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("coleta", ::oWScoleta, oWScoleta , "coletaSimultaneaTO", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</validarPostagemSimultanea>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::lreturn            :=  WSAdvValue( oXmlRet,"_VALIDARPOSTAGEMSIMULTANEARESPONSE:_RETURN:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterEmbalagemLRS of Service WSSigep

WSMETHOD obterEmbalagemLRS WSSEND NULLPARAM WSRECEIVE oWSembalagemLRSMaster WSCLIENT WSSigep
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<obterEmbalagemLRS xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += "</obterEmbalagemLRS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_OBTEREMBALAGEMLRSRESPONSE:_RETURN","embalagemLRSMaster",NIL,NIL,NIL,NIL,NIL,"xs") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSembalagemLRSMaster,AtendeClienteService_embalagemLRSMaster():New()) , ::oWSembalagemLRSMaster[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method cancelarPedidoScol of Service WSSigep

WSMETHOD cancelarPedidoScol WSSEND ncodAdministrativo,cidPostagem,ctipo,cusuario,csenha WSRECEIVE oWSretornoCancelamentoTO WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<cancelarPedidoScol xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("codAdministrativo", ::ncodAdministrativo, ncodAdministrativo , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idPostagem", ::cidPostagem, cidPostagem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipo", ::ctipo, ctipo , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</cancelarPedidoScol>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::oWSretornoCancelamentoTO:SoapRecv( WSAdvValue( oXmlRet,"_CANCELARPEDIDOSCOLRESPONSE:_RETURN","retornoCancelamentoTO",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method buscaServicos of Service WSSigep

WSMETHOD buscaServicos WSSEND cidContrato,cidCartaoPostagem,cusuario,csenha WSRECEIVE oWSservicoERP WSCLIENT WSSigep
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<buscaServicos xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("idContrato", ::cidContrato, cidContrato , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idCartaoPostagem", ::cidCartaoPostagem, cidCartaoPostagem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</buscaServicos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_BUSCASERVICOSRESPONSE:_RETURN","servicoERP",NIL,NIL,NIL,NIL,NIL,"xs") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSservicoERP,AtendeClienteService_servicoERP():New()) , ::oWSservicoERP[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method solicitarPostagemScol of Service WSSigep

WSMETHOD solicitarPostagemScol WSSEND ncodAdministrativo,cxml,cusuario,csenha WSRECEIVE creturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<solicitarPostagemScol xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("codAdministrativo", ::ncodAdministrativo, ncodAdministrativo , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</solicitarPostagemScol>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_SOLICITARPOSTAGEMSCOLRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method solicitaPLP of Service WSSigep

WSMETHOD solicitaPLP WSSEND nidPlpMaster,cnumEtiqueta,cusuario,csenha WSRECEIVE creturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<solicitaPLP xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("idPlpMaster", ::nidPlpMaster, nidPlpMaster , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numEtiqueta", ::cnumEtiqueta, cnumEtiqueta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</solicitaPLP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_SOLICITAPLPRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getStatusCartaoPostagem of Service WSSigep

WSMETHOD getStatusCartaoPostagem WSSEND cnumeroCartaoPostagem,cusuario,csenha WSRECEIVE oWSstatusCartao WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getStatusCartaoPostagem xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("numeroCartaoPostagem", ::cnumeroCartaoPostagem, cnumeroCartaoPostagem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</getStatusCartaoPostagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::oWSstatusCartao:SoapRecv( WSAdvValue( oXmlRet,"_GETSTATUSCARTAOPOSTAGEMRESPONSE:_RETURN","statusCartao",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method solicitaXmlPlp of Service WSSigep

WSMETHOD solicitaXmlPlp WSSEND nidPlpMaster,cusuario,csenha WSRECEIVE creturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<solicitaXmlPlp xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("idPlpMaster", ::nidPlpMaster, nidPlpMaster , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</solicitaXmlPlp>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_SOLICITAXMLPLPRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterMotivosPI of Service WSSigep

WSMETHOD obterMotivosPI WSSEND NULLPARAM WSRECEIVE oWSmotivoPIMaster WSCLIENT WSSigep
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<obterMotivosPI xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += "</obterMotivosPI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_OBTERMOTIVOSPIRESPONSE:_RETURN","motivoPIMaster",NIL,NIL,NIL,NIL,NIL,"xs") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSmotivoPIMaster,AtendeClienteService_motivoPIMaster():New()) , ::oWSmotivoPIMaster[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method buscaContrato of Service WSSigep

WSMETHOD buscaContrato WSSEND cnumero,ndiretoria,cusuario,csenha WSRECEIVE oWScontratoERP WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<buscaContrato xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("numero", ::cnumero, cnumero , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("diretoria", ::ndiretoria, ndiretoria , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</buscaContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::oWScontratoERP:SoapRecv( WSAdvValue( oXmlRet,"_BUSCACONTRATORESPONSE:_RETURN","contratoERP",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method consultaSRO of Service WSSigep

WSMETHOD consultaSRO WSSEND clistaObjetos,ctipoConsulta,ctipoResultado,cusuarioSro,csenhaSro WSRECEIVE creturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<consultaSRO xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("listaObjetos", ::clistaObjetos, clistaObjetos , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoConsulta", ::ctipoConsulta, ctipoConsulta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoResultado", ::ctipoResultado, ctipoResultado , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuarioSro", ::cusuarioSro, cusuarioSro , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senhaSro", ::csenhaSro, csenhaSro , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</consultaSRO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_CONSULTASRORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterClienteAtualizacao of Service WSSigep

WSMETHOD obterClienteAtualizacao WSSEND ccnpjCliente,cusuario,csenha WSRECEIVE creturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obterClienteAtualizacao xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("cnpjCliente", ::ccnpjCliente, ccnpjCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obterClienteAtualizacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTERCLIENTEATUALIZACAORESPONSE:_RETURN:TEXT","dateTime",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method integrarUsuarioScol of Service WSSigep

WSMETHOD integrarUsuarioScol WSSEND ncodAdministrativo,cusuario,csenha WSRECEIVE lreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<integrarUsuarioScol xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("codAdministrativo", ::ncodAdministrativo, ncodAdministrativo , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</integrarUsuarioScol>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::lreturn            :=  WSAdvValue( oXmlRet,"_INTEGRARUSUARIOSCOLRESPONSE:_RETURN:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method atualizaPLP of Service WSSigep

WSMETHOD atualizaPLP WSSEND nidPlpMaster,cnumEtiqueta,cusuario,csenha,cxml WSRECEIVE lreturn WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<atualizaPLP xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("idPlpMaster", ::nidPlpMaster, nidPlpMaster , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numEtiqueta", ::cnumEtiqueta, cnumEtiqueta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</atualizaPLP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::lreturn            :=  WSAdvValue( oXmlRet,"_ATUALIZAPLPRESPONSE:_RETURN:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterAssuntosPI of Service WSSigep

WSMETHOD obterAssuntosPI WSSEND NULLPARAM WSRECEIVE oWSassuntoPIMaster WSCLIENT WSSigep
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<obterAssuntosPI xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += "</obterAssuntosPI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_OBTERASSUNTOSPIRESPONSE:_RETURN","assuntoPIMaster",NIL,NIL,NIL,NIL,NIL,"xs") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSassuntoPIMaster,AtendeClienteService_assuntoPIMaster():New()) , ::oWSassuntoPIMaster[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method consultaCEP of Service WSSigep

WSMETHOD consultaCEP WSSEND ccep WSRECEIVE oWSenderecoERP WSCLIENT WSSigep
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<consultaCEP xmlns="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
cSoap += WSSoapValue("cep", ::ccep, ccep , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</consultaCEP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://cliente.bean.master.sigep.bsb.correios.com.br/",,,; 
	"https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")

::Init()
::oWSenderecoERP:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTACEPRESPONSE:_RETURN","enderecoERP",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// Faixa de Etiquetas
WSSTRUCT ListEtq_ArrayOfList
	WSDATA   cListaEtiquetas   AS String
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ListEtq_ArrayOfList
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ListEtq_ArrayOfList
	::cListaEtiquetas                 := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT ListEtq_ArrayOfList
	Local oClone := ListEtq_ArrayOfList():NEW()
	oClone:cListaEtiquetas                 := IIf(::cListaEtiquetas <> NIL , aClone(::cListaEtiquetas) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT ListEtq_ArrayOfList
	Local cSoap := ""
	aEval( ::cListaEtiquetas , {|x| cSoap := cSoap  +  WSSoapValue("cListaEtiquetas", x , x , "String", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ListEtq_ArrayOfList
	Local oNodes1 :=  WSAdvValue( oResponse,"_INT","string",{},NIL,.T.,"N",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::cListaEtiquetas ,  val(x:TEXT)  ) } )
Return

// WSDL Data Structure pedidoInformacaoRegistro

WSSTRUCT AtendeClienteService_pedidoInformacaoRegistro
	WSDATA   oWScliente                AS AtendeClienteService_cliente OPTIONAL
	WSDATA   ccodigoRegistro           AS string OPTIONAL
	WSDATA   oWSconta                  AS AtendeClienteService_conta OPTIONAL
	WSDATA   cconteudoObjeto           AS string OPTIONAL
	WSDATA   ccpfCnpj                  AS string OPTIONAL
	WSDATA   oWSdestinatario           AS AtendeClienteService_destinatario OPTIONAL
	WSDATA   cembalagem                AS string OPTIONAL
	WSDATA   nmotivo                   AS int OPTIONAL
	WSDATA   cobservacao               AS string OPTIONAL
	WSDATA   oWSpostagem               AS AtendeClienteService_postagem OPTIONAL
	WSDATA   oWSremetente              AS AtendeClienteService_remetente OPTIONAL
	WSDATA   nservico                  AS int OPTIONAL
	WSDATA   ctipoDocumento            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_pedidoInformacaoRegistro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_pedidoInformacaoRegistro
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_pedidoInformacaoRegistro
	Local oClone := AtendeClienteService_pedidoInformacaoRegistro():NEW()
	oClone:oWScliente           := IIF(::oWScliente = NIL , NIL , ::oWScliente:Clone() )
	oClone:ccodigoRegistro      := ::ccodigoRegistro
	oClone:oWSconta             := IIF(::oWSconta = NIL , NIL , ::oWSconta:Clone() )
	oClone:cconteudoObjeto      := ::cconteudoObjeto
	oClone:ccpfCnpj             := ::ccpfCnpj
	oClone:oWSdestinatario      := IIF(::oWSdestinatario = NIL , NIL , ::oWSdestinatario:Clone() )
	oClone:cembalagem           := ::cembalagem
	oClone:nmotivo              := ::nmotivo
	oClone:cobservacao          := ::cobservacao
	oClone:oWSpostagem          := IIF(::oWSpostagem = NIL , NIL , ::oWSpostagem:Clone() )
	oClone:oWSremetente         := IIF(::oWSremetente = NIL , NIL , ::oWSremetente:Clone() )
	oClone:nservico             := ::nservico
	oClone:ctipoDocumento       := ::ctipoDocumento
Return oClone

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_pedidoInformacaoRegistro
	Local cSoap := ""
	cSoap += WSSoapValue("cliente", ::oWScliente, ::oWScliente , "cliente", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("codigoRegistro", ::ccodigoRegistro, ::ccodigoRegistro , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("conta", ::oWSconta, ::oWSconta , "conta", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("conteudoObjeto", ::cconteudoObjeto, ::cconteudoObjeto , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("cpfCnpj", ::ccpfCnpj, ::ccpfCnpj , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("destinatario", ::oWSdestinatario, ::oWSdestinatario , "destinatario", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("embalagem", ::cembalagem, ::cembalagem , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("motivo", ::nmotivo, ::nmotivo , "int", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("observacao", ::cobservacao, ::cobservacao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("postagem", ::oWSpostagem, ::oWSpostagem , "postagem", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("remetente", ::oWSremetente, ::oWSremetente , "remetente", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("servico", ::nservico, ::nservico , "int", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("tipoDocumento", ::ctipoDocumento, ::ctipoDocumento , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure retorno

WSSTRUCT AtendeClienteService_retorno
	WSDATA   ncodigoPI                 AS long OPTIONAL
	WSDATA   ccodigoRegistro           AS string OPTIONAL
	WSDATA   ccodigoRetorno            AS string OPTIONAL
	WSDATA   cdataPrazoResposta        AS string OPTIONAL
	WSDATA   cdataRegistro             AS string OPTIONAL
	WSDATA   cdataResposta             AS string OPTIONAL
	WSDATA   cdataUltimaRecorrencia    AS string OPTIONAL
	WSDATA   nid                       AS long OPTIONAL
	WSDATA   cmensagemRetorno          AS string OPTIONAL
	WSDATA   cresposta                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_retorno
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_retorno
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_retorno
	Local oClone := AtendeClienteService_retorno():NEW()
	oClone:ncodigoPI            := ::ncodigoPI
	oClone:ccodigoRegistro      := ::ccodigoRegistro
	oClone:ccodigoRetorno       := ::ccodigoRetorno
	oClone:cdataPrazoResposta   := ::cdataPrazoResposta
	oClone:cdataRegistro        := ::cdataRegistro
	oClone:cdataResposta        := ::cdataResposta
	oClone:cdataUltimaRecorrencia := ::cdataUltimaRecorrencia
	oClone:nid                  := ::nid
	oClone:cmensagemRetorno     := ::cmensagemRetorno
	oClone:cresposta            := ::cresposta
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_retorno
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigoPI          :=  WSAdvValue( oResponse,"_CODIGOPI","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccodigoRegistro    :=  WSAdvValue( oResponse,"_CODIGOREGISTRO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccodigoRetorno     :=  WSAdvValue( oResponse,"_CODIGORETORNO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataPrazoResposta :=  WSAdvValue( oResponse,"_DATAPRAZORESPOSTA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataRegistro      :=  WSAdvValue( oResponse,"_DATAREGISTRO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataResposta      :=  WSAdvValue( oResponse,"_DATARESPOSTA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataUltimaRecorrencia :=  WSAdvValue( oResponse,"_DATAULTIMARECORRENCIA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cmensagemRetorno   :=  WSAdvValue( oResponse,"_MENSAGEMRETORNO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cresposta          :=  WSAdvValue( oResponse,"_RESPOSTA","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Enumeration tipoBloqueio

WSSTRUCT AtendeClienteService_tipoBloqueio
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_tipoBloqueio
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "FRAUDE_BLOQUEIO" )
	aadd(::aValueList , "EXTRAVIO_VAREJO_PRE_INDENIZADO" )
	aadd(::aValueList , "EXTRAVIO_VAREJO_POS_INDENIZADO" )
	aadd(::aValueList , "EXTRAVIO_CORPORATIVO" )
	aadd(::aValueList , "INTERNACIONAL_LDI" )
Return Self

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_tipoBloqueio
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_tipoBloqueio
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT AtendeClienteService_tipoBloqueio
Local oClone := AtendeClienteService_tipoBloqueio():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration acao

WSSTRUCT AtendeClienteService_acao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_acao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "DEVOLVIDO_AO_REMETENTE" )
	aadd(::aValueList , "ENCAMINHADO_PARA_REFUGO" )
	aadd(::aValueList , "REINTEGRADO_E_DEVOLVIDO_AO_REMETENTE" )
	aadd(::aValueList , "DESBLOQUEADO" )
Return Self

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_acao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_acao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT AtendeClienteService_acao
Local oClone := AtendeClienteService_acao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure clienteERP

WSSTRUCT AtendeClienteService_clienteERP
	WSDATA   ccnpj                     AS string OPTIONAL
	WSDATA   oWScontratos              AS AtendeClienteService_contratoERP OPTIONAL
	WSDATA   cdataAtualizacao          AS dateTime OPTIONAL
	WSDATA   ndatajAtualizacao         AS int OPTIONAL
	WSDATA   cdescricaoStatusCliente   AS string OPTIONAL
	WSDATA   oWSgerenteConta           AS AtendeClienteService_gerenteConta OPTIONAL
	WSDATA   nhorajAtualizacao         AS long OPTIONAL
	WSDATA   nid                       AS long OPTIONAL
	WSDATA   cinscricaoEstadual        AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   cstatusCodigo             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_clienteERP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_clienteERP
	::oWScontratos         := {} // Array Of  AtendeClienteService_CONTRATOERP():New()
	::oWSgerenteConta      := {} // Array Of  AtendeClienteService_GERENTECONTA():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_clienteERP
	Local oClone := AtendeClienteService_clienteERP():NEW()
	oClone:ccnpj                := ::ccnpj
	oClone:oWScontratos := NIL
	If ::oWScontratos <> NIL 
		oClone:oWScontratos := {}
		aEval( ::oWScontratos , { |x| aadd( oClone:oWScontratos , x:Clone() ) } )
	Endif 
	oClone:cdataAtualizacao     := ::cdataAtualizacao
	oClone:ndatajAtualizacao    := ::ndatajAtualizacao
	oClone:cdescricaoStatusCliente := ::cdescricaoStatusCliente
	oClone:oWSgerenteConta := NIL
	If ::oWSgerenteConta <> NIL 
		oClone:oWSgerenteConta := {}
		aEval( ::oWSgerenteConta , { |x| aadd( oClone:oWSgerenteConta , x:Clone() ) } )
	Endif 
	oClone:nhorajAtualizacao    := ::nhorajAtualizacao
	oClone:nid                  := ::nid
	oClone:cinscricaoEstadual   := ::cinscricaoEstadual
	oClone:cnome                := ::cnome
	oClone:cstatusCodigo        := ::cstatusCodigo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_clienteERP
	Local nRElem2, oNodes2, nTElem2
	Local nRElem6, oNodes6, nTElem6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccnpj              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNodes2 :=  WSAdvValue( oResponse,"_CONTRATOS","contratoERP",{},NIL,.T.,"O",NIL,"xs") 
	nTElem2 := len(oNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( oNodes2[nRElem2] )
			aadd(::oWScontratos , AtendeClienteService_contratoERP():New() )
			::oWScontratos[len(::oWScontratos)]:SoapRecv(oNodes2[nRElem2])
		Endif
	Next
	::cdataAtualizacao   :=  WSAdvValue( oResponse,"_DATAATUALIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndatajAtualizacao  :=  WSAdvValue( oResponse,"_DATAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdescricaoStatusCliente :=  WSAdvValue( oResponse,"_DESCRICAOSTATUSCLIENTE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNodes6 :=  WSAdvValue( oResponse,"_GERENTECONTA","gerenteConta",{},NIL,.T.,"O",NIL,"xs") 
	nTElem6 := len(oNodes6)
	For nRElem6 := 1 to nTElem6 
		If !WSIsNilNode( oNodes6[nRElem6] )
			aadd(::oWSgerenteConta , AtendeClienteService_gerenteConta():New() )
			::oWSgerenteConta[len(::oWSgerenteConta)]:SoapRecv(oNodes6[nRElem6])
		Endif
	Next
	::nhorajAtualizacao  :=  WSAdvValue( oResponse,"_HORAJATUALIZACAO","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cinscricaoEstadual :=  WSAdvValue( oResponse,"_INSCRICAOESTADUAL","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cstatusCodigo      :=  WSAdvValue( oResponse,"_STATUSCODIGO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure mensagemRetornoPIMaster

WSSTRUCT AtendeClienteService_mensagemRetornoPIMaster
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cmensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_mensagemRetornoPIMaster
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_mensagemRetornoPIMaster
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_mensagemRetornoPIMaster
	Local oClone := AtendeClienteService_mensagemRetornoPIMaster():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cmensagem            := ::cmensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_mensagemRetornoPIMaster
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cmensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure coletaReversaTO

WSSTRUCT AtendeClienteService_coletaReversaTO
	WSDATA   cag                       AS string OPTIONAL
	WSDATA   nar                       AS int OPTIONAL
	WSDATA   ncartao                   AS long OPTIONAL
	WSDATA   nnumero                   AS int OPTIONAL
	WSDATA   oWSobj_col                AS AtendeClienteService_objetoTO OPTIONAL
	WSDATA   cservico_adicional        AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_coletaReversaTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_coletaReversaTO
	::oWSobj_col           := {} // Array Of  AtendeClienteService_OBJETOTO():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_coletaReversaTO
	Local oClone := AtendeClienteService_coletaReversaTO():NEW()
	oClone:cag                  := ::cag
	oClone:nar                  := ::nar
	oClone:ncartao              := ::ncartao
	oClone:nnumero              := ::nnumero
	oClone:oWSobj_col := NIL
	If ::oWSobj_col <> NIL 
		oClone:oWSobj_col := {}
		aEval( ::oWSobj_col , { |x| aadd( oClone:oWSobj_col , x:Clone() ) } )
	Endif 
	oClone:cservico_adicional   := ::cservico_adicional
Return oClone

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_coletaReversaTO
	Local cSoap := ""
	cSoap += WSSoapValue("ag", ::cag, ::cag , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ar", ::nar, ::nar , "int", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("cartao", ::ncartao, ::ncartao , "long", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("numero", ::nnumero, ::nnumero , "int", .F. , .F., 0 , NIL, .F.) 
	aEval( ::oWSobj_col , {|x| cSoap := cSoap  +  WSSoapValue("obj_col", x , x , "objetoTO", .F. , .F., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("servico_adicional", ::cservico_adicional, ::cservico_adicional , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure embalagemLRSMaster

WSSTRUCT AtendeClienteService_embalagemLRSMaster
	WSDATA   ccodigo                   AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   ctipo                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_embalagemLRSMaster
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_embalagemLRSMaster
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_embalagemLRSMaster
	Local oClone := AtendeClienteService_embalagemLRSMaster():NEW()
	oClone:ccodigo              := ::ccodigo
	oClone:cnome                := ::cnome
	oClone:ctipo                := ::ctipo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_embalagemLRSMaster
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ctipo              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure retornoCancelamentoTO

WSSTRUCT AtendeClienteService_retornoCancelamentoTO
	WSDATA   ccod_erro                 AS string OPTIONAL
	WSDATA   ccodigo_administrativo    AS string OPTIONAL
	WSDATA   cdata                     AS string OPTIONAL
	WSDATA   chora                     AS string OPTIONAL
	WSDATA   cmsg_erro                 AS string OPTIONAL
	WSDATA   oWSobjeto_postal          AS AtendeClienteService_objetoSimplificadoTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_retornoCancelamentoTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_retornoCancelamentoTO
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_retornoCancelamentoTO
	Local oClone := AtendeClienteService_retornoCancelamentoTO():NEW()
	oClone:ccod_erro            := ::ccod_erro
	oClone:ccodigo_administrativo := ::ccodigo_administrativo
	oClone:cdata                := ::cdata
	oClone:chora                := ::chora
	oClone:cmsg_erro            := ::cmsg_erro
	oClone:oWSobjeto_postal     := IIF(::oWSobjeto_postal = NIL , NIL , ::oWSobjeto_postal:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_retornoCancelamentoTO
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccod_erro          :=  WSAdvValue( oResponse,"_COD_ERRO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccodigo_administrativo :=  WSAdvValue( oResponse,"_CODIGO_ADMINISTRATIVO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdata              :=  WSAdvValue( oResponse,"_DATA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::chora              :=  WSAdvValue( oResponse,"_HORA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cmsg_erro          :=  WSAdvValue( oResponse,"_MSG_ERRO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode6 :=  WSAdvValue( oResponse,"_OBJETO_POSTAL","objetoSimplificadoTO",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode6 != NIL
		::oWSobjeto_postal := AtendeClienteService_objetoSimplificadoTO():New()
		::oWSobjeto_postal:SoapRecv(oNode6)
	EndIf
Return

// WSDL Data Structure servicoERP

WSSTRUCT AtendeClienteService_servicoERP
	WSDATA   ccodigo                   AS string OPTIONAL
	WSDATA   cdataAtualizacao          AS dateTime OPTIONAL
	WSDATA   ndatajAtualizacao         AS int OPTIONAL
	WSDATA   cdescricao                AS string OPTIONAL
	WSDATA   nhorajAtualizacao         AS int OPTIONAL
	WSDATA   nid                       AS long OPTIONAL
	WSDATA   oWSservicoSigep           AS AtendeClienteService_servicoSigep OPTIONAL
	WSDATA   oWSservicosAdicionais     AS AtendeClienteService_servicoAdicionalERP OPTIONAL
	WSDATA   ctipo1Codigo              AS string OPTIONAL
	WSDATA   ctipo1Descricao           AS string OPTIONAL
	WSDATA   ctipo2Codigo              AS string OPTIONAL
	WSDATA   ctipo2Descricao           AS string OPTIONAL
	WSDATA   oWSvigencia               AS AtendeClienteService_vigenciaERP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_servicoERP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_servicoERP
	::oWSservicosAdicionais := {} // Array Of  AtendeClienteService_SERVICOADICIONALERP():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_servicoERP
	Local oClone := AtendeClienteService_servicoERP():NEW()
	oClone:ccodigo              := ::ccodigo
	oClone:cdataAtualizacao     := ::cdataAtualizacao
	oClone:ndatajAtualizacao    := ::ndatajAtualizacao
	oClone:cdescricao           := ::cdescricao
	oClone:nhorajAtualizacao    := ::nhorajAtualizacao
	oClone:nid                  := ::nid
	oClone:oWSservicoSigep      := IIF(::oWSservicoSigep = NIL , NIL , ::oWSservicoSigep:Clone() )
	oClone:oWSservicosAdicionais := NIL
	If ::oWSservicosAdicionais <> NIL 
		oClone:oWSservicosAdicionais := {}
		aEval( ::oWSservicosAdicionais , { |x| aadd( oClone:oWSservicosAdicionais , x:Clone() ) } )
	Endif 
	oClone:ctipo1Codigo         := ::ctipo1Codigo
	oClone:ctipo1Descricao      := ::ctipo1Descricao
	oClone:ctipo2Codigo         := ::ctipo2Codigo
	oClone:ctipo2Descricao      := ::ctipo2Descricao
	oClone:oWSvigencia          := IIF(::oWSvigencia = NIL , NIL , ::oWSvigencia:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_servicoERP
	Local oNode7
	Local nRElem8, oNodes8, nTElem8
	Local oNode13
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataAtualizacao   :=  WSAdvValue( oResponse,"_DATAATUALIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndatajAtualizacao  :=  WSAdvValue( oResponse,"_DATAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nhorajAtualizacao  :=  WSAdvValue( oResponse,"_HORAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	oNode7 :=  WSAdvValue( oResponse,"_SERVICOSIGEP","servicoSigep",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode7 != NIL
		::oWSservicoSigep := AtendeClienteService_servicoSigep():New()
		::oWSservicoSigep:SoapRecv(oNode7)
	EndIf
	oNodes8 :=  WSAdvValue( oResponse,"_SERVICOSADICIONAIS","servicoAdicionalERP",{},NIL,.T.,"O",NIL,"xs") 
	nTElem8 := len(oNodes8)
	For nRElem8 := 1 to nTElem8 
		If !WSIsNilNode( oNodes8[nRElem8] )
			aadd(::oWSservicosAdicionais , AtendeClienteService_servicoAdicionalERP():New() )
			::oWSservicosAdicionais[len(::oWSservicosAdicionais)]:SoapRecv(oNodes8[nRElem8])
		Endif
	Next
	::ctipo1Codigo       :=  WSAdvValue( oResponse,"_TIPO1CODIGO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ctipo1Descricao    :=  WSAdvValue( oResponse,"_TIPO1DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ctipo2Codigo       :=  WSAdvValue( oResponse,"_TIPO2CODIGO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ctipo2Descricao    :=  WSAdvValue( oResponse,"_TIPO2DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode13 :=  WSAdvValue( oResponse,"_VIGENCIA","vigenciaERP",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode13 != NIL
		::oWSvigencia := AtendeClienteService_vigenciaERP():New()
		::oWSvigencia:SoapRecv(oNode13)
	EndIf
Return

// WSDL Data Enumeration statusCartao

WSSTRUCT AtendeClienteService_statusCartao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_statusCartao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Desconhecido" )
	aadd(::aValueList , "Normal" )
	aadd(::aValueList , "Suspenso" )
	aadd(::aValueList , "Cancelado" )
	aadd(::aValueList , "Irregular" )
Return Self

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_statusCartao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_statusCartao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT AtendeClienteService_statusCartao
Local oClone := AtendeClienteService_statusCartao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure motivoPIMaster

WSSTRUCT AtendeClienteService_motivoPIMaster
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cdescricao                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_motivoPIMaster
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_motivoPIMaster
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_motivoPIMaster
	Local oClone := AtendeClienteService_motivoPIMaster():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cdescricao           := ::cdescricao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_motivoPIMaster
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure contratoERP

WSSTRUCT AtendeClienteService_contratoERP
	WSDATA   oWScartoesPostagem        AS AtendeClienteService_cartaoPostagemERP OPTIONAL
	WSDATA   oWScliente                AS AtendeClienteService_clienteERP OPTIONAL
	WSDATA   ncodigoCliente            AS long OPTIONAL
	WSDATA   ccodigoDiretoria          AS string OPTIONAL
	WSDATA   oWScontratoPK             AS AtendeClienteService_contratoERPPK OPTIONAL
	WSDATA   cdataAtualizacao          AS dateTime OPTIONAL
	WSDATA   cdataAtualizacaoDDMMYYYY  AS string OPTIONAL
	WSDATA   cdataVigenciaFim          AS dateTime OPTIONAL
	WSDATA   cdataVigenciaFimDDMMYYYY  AS string OPTIONAL
	WSDATA   cdataVigenciaInicio       AS dateTime OPTIONAL
	WSDATA   cdataVigenciaInicioDDMMYYYY AS string OPTIONAL
	WSDATA   ndatajAtualizacao         AS int OPTIONAL
	WSDATA   ndatajVigenciaFim         AS int OPTIONAL
	WSDATA   ndatajVigenciaInicio      AS int OPTIONAL
	WSDATA   cdescricaoDiretoriaRegional AS string OPTIONAL
	WSDATA   cdescricaoStatus          AS string OPTIONAL
	WSDATA   oWSdiretoriaRegional      AS AtendeClienteService_unidadePostagemERP OPTIONAL
	WSDATA   nhorajAtualizacao         AS int OPTIONAL
	WSDATA   cstatusCodigo             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_contratoERP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_contratoERP
	::oWScartoesPostagem   := {} // Array Of  AtendeClienteService_CARTAOPOSTAGEMERP():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_contratoERP
	Local oClone := AtendeClienteService_contratoERP():NEW()
	oClone:oWScartoesPostagem := NIL
	If ::oWScartoesPostagem <> NIL 
		oClone:oWScartoesPostagem := {}
		aEval( ::oWScartoesPostagem , { |x| aadd( oClone:oWScartoesPostagem , x:Clone() ) } )
	Endif 
	oClone:oWScliente           := IIF(::oWScliente = NIL , NIL , ::oWScliente:Clone() )
	oClone:ncodigoCliente       := ::ncodigoCliente
	oClone:ccodigoDiretoria     := ::ccodigoDiretoria
	oClone:oWScontratoPK        := IIF(::oWScontratoPK = NIL , NIL , ::oWScontratoPK:Clone() )
	oClone:cdataAtualizacao     := ::cdataAtualizacao
	oClone:cdataAtualizacaoDDMMYYYY := ::cdataAtualizacaoDDMMYYYY
	oClone:cdataVigenciaFim     := ::cdataVigenciaFim
	oClone:cdataVigenciaFimDDMMYYYY := ::cdataVigenciaFimDDMMYYYY
	oClone:cdataVigenciaInicio  := ::cdataVigenciaInicio
	oClone:cdataVigenciaInicioDDMMYYYY := ::cdataVigenciaInicioDDMMYYYY
	oClone:ndatajAtualizacao    := ::ndatajAtualizacao
	oClone:ndatajVigenciaFim    := ::ndatajVigenciaFim
	oClone:ndatajVigenciaInicio := ::ndatajVigenciaInicio
	oClone:cdescricaoDiretoriaRegional := ::cdescricaoDiretoriaRegional
	oClone:cdescricaoStatus     := ::cdescricaoStatus
	oClone:oWSdiretoriaRegional := IIF(::oWSdiretoriaRegional = NIL , NIL , ::oWSdiretoriaRegional:Clone() )
	oClone:nhorajAtualizacao    := ::nhorajAtualizacao
	oClone:cstatusCodigo        := ::cstatusCodigo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_contratoERP
	Local nRElem1, oNodes1, nTElem1
	Local oNode2
	Local oNode5
	Local oNode17
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CARTOESPOSTAGEM","cartaoPostagemERP",{},NIL,.T.,"O",NIL,"xs") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWScartoesPostagem , AtendeClienteService_cartaoPostagemERP():New() )
			::oWScartoesPostagem[len(::oWScartoesPostagem)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
	oNode2 :=  WSAdvValue( oResponse,"_CLIENTE","clienteERP",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode2 != NIL
		::oWScliente := AtendeClienteService_clienteERP():New()
		::oWScliente:SoapRecv(oNode2)
	EndIf
	::ncodigoCliente     :=  WSAdvValue( oResponse,"_CODIGOCLIENTE","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccodigoDiretoria   :=  WSAdvValue( oResponse,"_CODIGODIRETORIA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode5 :=  WSAdvValue( oResponse,"_CONTRATOPK","contratoERPPK",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode5 != NIL
		::oWScontratoPK := AtendeClienteService_contratoERPPK():New()
		::oWScontratoPK:SoapRecv(oNode5)
	EndIf
	::cdataAtualizacao   :=  WSAdvValue( oResponse,"_DATAATUALIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataAtualizacaoDDMMYYYY :=  WSAdvValue( oResponse,"_DATAATUALIZACAODDMMYYYY","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataVigenciaFim   :=  WSAdvValue( oResponse,"_DATAVIGENCIAFIM","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataVigenciaFimDDMMYYYY :=  WSAdvValue( oResponse,"_DATAVIGENCIAFIMDDMMYYYY","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataVigenciaInicio :=  WSAdvValue( oResponse,"_DATAVIGENCIAINICIO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataVigenciaInicioDDMMYYYY :=  WSAdvValue( oResponse,"_DATAVIGENCIAINICIODDMMYYYY","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndatajAtualizacao  :=  WSAdvValue( oResponse,"_DATAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndatajVigenciaFim  :=  WSAdvValue( oResponse,"_DATAJVIGENCIAFIM","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndatajVigenciaInicio :=  WSAdvValue( oResponse,"_DATAJVIGENCIAINICIO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdescricaoDiretoriaRegional :=  WSAdvValue( oResponse,"_DESCRICAODIRETORIAREGIONAL","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdescricaoStatus   :=  WSAdvValue( oResponse,"_DESCRICAOSTATUS","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode17 :=  WSAdvValue( oResponse,"_DIRETORIAREGIONAL","unidadePostagemERP",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode17 != NIL
		::oWSdiretoriaRegional := AtendeClienteService_unidadePostagemERP():New()
		::oWSdiretoriaRegional:SoapRecv(oNode17)
	EndIf
	::nhorajAtualizacao  :=  WSAdvValue( oResponse,"_HORAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cstatusCodigo      :=  WSAdvValue( oResponse,"_STATUSCODIGO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure assuntoPIMaster

WSSTRUCT AtendeClienteService_assuntoPIMaster
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cdescricao                AS string OPTIONAL
	WSDATA   ctipo                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_assuntoPIMaster
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_assuntoPIMaster
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_assuntoPIMaster
	Local oClone := AtendeClienteService_assuntoPIMaster():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cdescricao           := ::cdescricao
	oClone:ctipo                := ::ctipo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_assuntoPIMaster
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ctipo              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure enderecoERP

WSSTRUCT AtendeClienteService_enderecoERP
	WSDATA   cbairro                   AS string OPTIONAL
	WSDATA   ccep                      AS string OPTIONAL
	WSDATA   ccidade                   AS string OPTIONAL
	WSDATA   ccomplemento              AS string OPTIONAL
	WSDATA   ccomplemento2             AS string OPTIONAL
	WSDATA   cend                      AS string OPTIONAL
	WSDATA   nid                       AS long OPTIONAL
	WSDATA   cuf                       AS string OPTIONAL
	WSDATA   oWSunidadesPostagem       AS AtendeClienteService_unidadePostagemERP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_enderecoERP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_enderecoERP
	::oWSunidadesPostagem  := {} // Array Of  AtendeClienteService_UNIDADEPOSTAGEMERP():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_enderecoERP
	Local oClone := AtendeClienteService_enderecoERP():NEW()
	oClone:cbairro              := ::cbairro
	oClone:ccep                 := ::ccep
	oClone:ccidade              := ::ccidade
	oClone:ccomplemento         := ::ccomplemento
	oClone:ccomplemento2        := ::ccomplemento2
	oClone:cend                 := ::cend
	oClone:nid                  := ::nid
	oClone:cuf                  := ::cuf
	oClone:oWSunidadesPostagem := NIL
	If ::oWSunidadesPostagem <> NIL 
		oClone:oWSunidadesPostagem := {}
		aEval( ::oWSunidadesPostagem , { |x| aadd( oClone:oWSunidadesPostagem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_enderecoERP
	Local nRElem9, oNodes9, nTElem9
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cbairro            :=  WSAdvValue( oResponse,"_BAIRRO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccep               :=  WSAdvValue( oResponse,"_CEP","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccomplemento       :=  WSAdvValue( oResponse,"_COMPLEMENTO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccomplemento2      :=  WSAdvValue( oResponse,"_COMPLEMENTO2","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cend               :=  WSAdvValue( oResponse,"_END","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cuf                :=  WSAdvValue( oResponse,"_UF","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNodes9 :=  WSAdvValue( oResponse,"_UNIDADESPOSTAGEM","unidadePostagemERP",{},NIL,.T.,"O",NIL,"xs") 
	nTElem9 := len(oNodes9)
	For nRElem9 := 1 to nTElem9 
		If !WSIsNilNode( oNodes9[nRElem9] )
			aadd(::oWSunidadesPostagem , AtendeClienteService_unidadePostagemERP():New() )
			::oWSunidadesPostagem[len(::oWSunidadesPostagem)]:SoapRecv(oNodes9[nRElem9])
		Endif
	Next
Return

// WSDL Data Structure cliente

WSSTRUCT AtendeClienteService_cliente
	WSDATA   cnumeroContrato           AS string OPTIONAL
	WSDATA   cpossuiContrato           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_cliente
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_cliente
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_cliente
	Local oClone := AtendeClienteService_cliente():NEW()
	oClone:cnumeroContrato      := ::cnumeroContrato
	oClone:cpossuiContrato      := ::cpossuiContrato
Return oClone

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_cliente
	Local cSoap := ""
	cSoap += WSSoapValue("numeroContrato", ::cnumeroContrato, ::cnumeroContrato , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("possuiContrato", ::cpossuiContrato, ::cpossuiContrato , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure conta

WSSTRUCT AtendeClienteService_conta
	WSDATA   ccodigoBanco              AS string OPTIONAL
	WSDATA   cnomeBanco                AS string OPTIONAL
	WSDATA   cnumeroAgencia            AS string OPTIONAL
	WSDATA   cnumeroConta              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_conta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_conta
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_conta
	Local oClone := AtendeClienteService_conta():NEW()
	oClone:ccodigoBanco         := ::ccodigoBanco
	oClone:cnomeBanco           := ::cnomeBanco
	oClone:cnumeroAgencia       := ::cnumeroAgencia
	oClone:cnumeroConta         := ::cnumeroConta
Return oClone

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_conta
	Local cSoap := ""
	cSoap += WSSoapValue("codigoBanco", ::ccodigoBanco, ::ccodigoBanco , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("nomeBanco", ::cnomeBanco, ::cnomeBanco , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("numeroAgencia", ::cnumeroAgencia, ::cnumeroAgencia , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("numeroConta", ::cnumeroConta, ::cnumeroConta , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure destinatario

WSSTRUCT AtendeClienteService_destinatario
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_destinatario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_destinatario
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_destinatario
	Local oClone := AtendeClienteService_destinatario():NEW()
Return oClone

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_destinatario
	Local cSoap := ""
Return cSoap

// WSDL Data Structure postagem

WSSTRUCT AtendeClienteService_postagem
	WSDATA   cagencia                  AS string OPTIONAL
	WSDATA   cavisoRecebimento         AS string OPTIONAL
	WSDATA   cdata                     AS string OPTIONAL
	WSDATA   clocal                    AS string OPTIONAL
	WSDATA   cvalorDeclarado           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_postagem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_postagem
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_postagem
	Local oClone := AtendeClienteService_postagem():NEW()
	oClone:cagencia             := ::cagencia
	oClone:cavisoRecebimento    := ::cavisoRecebimento
	oClone:cdata                := ::cdata
	oClone:clocal               := ::clocal
	oClone:cvalorDeclarado      := ::cvalorDeclarado
Return oClone

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_postagem
	Local cSoap := ""
	cSoap += WSSoapValue("agencia", ::cagencia, ::cagencia , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("avisoRecebimento", ::cavisoRecebimento, ::cavisoRecebimento , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("data", ::cdata, ::cdata , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("local", ::clocal, ::clocal , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("valorDeclarado", ::cvalorDeclarado, ::cvalorDeclarado , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure remetente

WSSTRUCT AtendeClienteService_remetente
	WSDATA   cemail                    AS string OPTIONAL
	WSDATA   cempresa                  AS string OPTIONAL
	WSDATA   cfax                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_remetente
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_remetente
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_remetente
	Local oClone := AtendeClienteService_remetente():NEW()
	oClone:cemail               := ::cemail
	oClone:cempresa             := ::cempresa
	oClone:cfax                 := ::cfax
Return oClone

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_remetente
	Local cSoap := ""
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("empresa", ::cempresa, ::cempresa , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fax", ::cfax, ::cfax , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure gerenteConta

WSSTRUCT AtendeClienteService_gerenteConta
	WSDATA   oWSclientesVisiveis       AS AtendeClienteService_clienteERP OPTIONAL
	WSDATA   cdataAtualizacao          AS dateTime OPTIONAL
	WSDATA   cdataInclusao             AS dateTime OPTIONAL
	WSDATA   cdataSenha                AS dateTime OPTIONAL
	WSDATA   clogin                    AS string OPTIONAL
	WSDATA   cmatricula                AS string OPTIONAL
	WSDATA   csenha                    AS string OPTIONAL
	WSDATA   oWSstatus                 AS AtendeClienteService_statusGerente OPTIONAL
	WSDATA   oWStipoGerente            AS AtendeClienteService_tipoGerente OPTIONAL
	WSDATA   oWSusuariosInstalacao     AS AtendeClienteService_usuarioInstalacao OPTIONAL
	WSDATA   cvalidade                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_gerenteConta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_gerenteConta
	::oWSclientesVisiveis  := {} // Array Of  AtendeClienteService_CLIENTEERP():New()
	::oWSusuariosInstalacao := {} // Array Of  AtendeClienteService_USUARIOINSTALACAO():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_gerenteConta
	Local oClone := AtendeClienteService_gerenteConta():NEW()
	oClone:oWSclientesVisiveis := NIL
	If ::oWSclientesVisiveis <> NIL 
		oClone:oWSclientesVisiveis := {}
		aEval( ::oWSclientesVisiveis , { |x| aadd( oClone:oWSclientesVisiveis , x:Clone() ) } )
	Endif 
	oClone:cdataAtualizacao     := ::cdataAtualizacao
	oClone:cdataInclusao        := ::cdataInclusao
	oClone:cdataSenha           := ::cdataSenha
	oClone:clogin               := ::clogin
	oClone:cmatricula           := ::cmatricula
	oClone:csenha               := ::csenha
	oClone:oWSstatus            := IIF(::oWSstatus = NIL , NIL , ::oWSstatus:Clone() )
	oClone:oWStipoGerente       := IIF(::oWStipoGerente = NIL , NIL , ::oWStipoGerente:Clone() )
	oClone:oWSusuariosInstalacao := NIL
	If ::oWSusuariosInstalacao <> NIL 
		oClone:oWSusuariosInstalacao := {}
		aEval( ::oWSusuariosInstalacao , { |x| aadd( oClone:oWSusuariosInstalacao , x:Clone() ) } )
	Endif 
	oClone:cvalidade            := ::cvalidade
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_gerenteConta
	Local nRElem1, oNodes1, nTElem1
	Local oNode8
	Local oNode9
	Local nRElem10, oNodes10, nTElem10
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLIENTESVISIVEIS","clienteERP",{},NIL,.T.,"O",NIL,"xs") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclientesVisiveis , AtendeClienteService_clienteERP():New() )
			::oWSclientesVisiveis[len(::oWSclientesVisiveis)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
	::cdataAtualizacao   :=  WSAdvValue( oResponse,"_DATAATUALIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataInclusao      :=  WSAdvValue( oResponse,"_DATAINCLUSAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataSenha         :=  WSAdvValue( oResponse,"_DATASENHA","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::clogin             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cmatricula         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::csenha             :=  WSAdvValue( oResponse,"_SENHA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode8 :=  WSAdvValue( oResponse,"_STATUS","statusGerente",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode8 != NIL
		::oWSstatus := AtendeClienteService_statusGerente():New()
		::oWSstatus:SoapRecv(oNode8)
	EndIf
	oNode9 :=  WSAdvValue( oResponse,"_TIPOGERENTE","tipoGerente",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode9 != NIL
		::oWStipoGerente := AtendeClienteService_tipoGerente():New()
		::oWStipoGerente:SoapRecv(oNode9)
	EndIf
	oNodes10 :=  WSAdvValue( oResponse,"_USUARIOSINSTALACAO","usuarioInstalacao",{},NIL,.T.,"O",NIL,"xs") 
	nTElem10 := len(oNodes10)
	For nRElem10 := 1 to nTElem10 
		If !WSIsNilNode( oNodes10[nRElem10] )
			aadd(::oWSusuariosInstalacao , AtendeClienteService_usuarioInstalacao():New() )
			::oWSusuariosInstalacao[len(::oWSusuariosInstalacao)]:SoapRecv(oNodes10[nRElem10])
		Endif
	Next
	::cvalidade          :=  WSAdvValue( oResponse,"_VALIDADE","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure objetoTO

WSSTRUCT AtendeClienteService_objetoTO
	WSDATA   cdesc                     AS string OPTIONAL
	WSDATA   centrega                  AS string OPTIONAL
	WSDATA   cid                       AS string OPTIONAL
	WSDATA   citem                     AS string OPTIONAL
	WSDATA   cnum                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_objetoTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_objetoTO
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_objetoTO
	Local oClone := AtendeClienteService_objetoTO():NEW()
	oClone:cdesc                := ::cdesc
	oClone:centrega             := ::centrega
	oClone:cid                  := ::cid
	oClone:citem                := ::citem
	oClone:cnum                 := ::cnum
Return oClone

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_objetoTO
	Local cSoap := ""
	cSoap += WSSoapValue("desc", ::cdesc, ::cdesc , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("entrega", ::centrega, ::centrega , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("id", ::cid, ::cid , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("item", ::citem, ::citem , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("num", ::cnum, ::cnum , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure objetoSimplificadoTO

WSSTRUCT AtendeClienteService_objetoSimplificadoTO
	WSDATA   cdatahora_cancelamento    AS string OPTIONAL
	WSDATA   nnumero_pedido            AS int OPTIONAL
	WSDATA   cstatus_pedido            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_objetoSimplificadoTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_objetoSimplificadoTO
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_objetoSimplificadoTO
	Local oClone := AtendeClienteService_objetoSimplificadoTO():NEW()
	oClone:cdatahora_cancelamento := ::cdatahora_cancelamento
	oClone:nnumero_pedido       := ::nnumero_pedido
	oClone:cstatus_pedido       := ::cstatus_pedido
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_objetoSimplificadoTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdatahora_cancelamento :=  WSAdvValue( oResponse,"_DATAHORA_CANCELAMENTO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nnumero_pedido     :=  WSAdvValue( oResponse,"_NUMERO_PEDIDO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cstatus_pedido     :=  WSAdvValue( oResponse,"_STATUS_PEDIDO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure servicoSigep

WSSTRUCT AtendeClienteService_servicoSigep
	WSDATA   oWScategoriaServico       AS AtendeClienteService_categoriaServico OPTIONAL
	WSDATA   oWSchancela               AS AtendeClienteService_chancelaMaster OPTIONAL
	WSDATA   lexigeDimensoes           AS boolean OPTIONAL
	WSDATA   lexigeValorCobrar         AS boolean OPTIONAL
	WSDATA   nimitm                    AS long OPTIONAL
	WSDATA   nservico                  AS long OPTIONAL
	WSDATA   oWSservicoERP             AS AtendeClienteService_servicoERP OPTIONAL
	WSDATA   cssiCoCodigoPostal        AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_servicoSigep
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_servicoSigep
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_servicoSigep
	Local oClone := AtendeClienteService_servicoSigep():NEW()
	oClone:oWScategoriaServico  := IIF(::oWScategoriaServico = NIL , NIL , ::oWScategoriaServico:Clone() )
	oClone:oWSchancela          := IIF(::oWSchancela = NIL , NIL , ::oWSchancela:Clone() )
	oClone:lexigeDimensoes      := ::lexigeDimensoes
	oClone:lexigeValorCobrar    := ::lexigeValorCobrar
	oClone:nimitm               := ::nimitm
	oClone:nservico             := ::nservico
	oClone:oWSservicoERP        := IIF(::oWSservicoERP = NIL , NIL , ::oWSservicoERP:Clone() )
	oClone:cssiCoCodigoPostal   := ::cssiCoCodigoPostal
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_servicoSigep
	Local oNode1
	Local oNode2
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CATEGORIASERVICO","categoriaServico",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode1 != NIL
		::oWScategoriaServico := AtendeClienteService_categoriaServico():New()
		::oWScategoriaServico:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_CHANCELA","chancelaMaster",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode2 != NIL
		::oWSchancela := AtendeClienteService_chancelaMaster():New()
		::oWSchancela:SoapRecv(oNode2)
	EndIf
	::lexigeDimensoes    :=  WSAdvValue( oResponse,"_EXIGEDIMENSOES","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lexigeValorCobrar  :=  WSAdvValue( oResponse,"_EXIGEVALORCOBRAR","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nimitm             :=  WSAdvValue( oResponse,"_IMITM","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::nservico           :=  WSAdvValue( oResponse,"_SERVICO","long",NIL,NIL,NIL,"N",NIL,"xs") 
	oNode7 :=  WSAdvValue( oResponse,"_SERVICOERP","servicoERP",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode7 != NIL
		::oWSservicoERP := AtendeClienteService_servicoERP():New()
		::oWSservicoERP:SoapRecv(oNode7)
	EndIf
	::cssiCoCodigoPostal :=  WSAdvValue( oResponse,"_SSICOCODIGOPOSTAL","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure servicoAdicionalERP

WSSTRUCT AtendeClienteService_servicoAdicionalERP
	WSDATA   ccodigo                   AS string OPTIONAL
	WSDATA   cdataAtualizacao          AS dateTime OPTIONAL
	WSDATA   ndatajAtualizacao         AS int OPTIONAL
	WSDATA   cdescricao                AS string OPTIONAL
	WSDATA   nhorajAtualizacao         AS int OPTIONAL
	WSDATA   nid                       AS int OPTIONAL
	WSDATA   csigla                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_servicoAdicionalERP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_servicoAdicionalERP
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_servicoAdicionalERP
	Local oClone := AtendeClienteService_servicoAdicionalERP():NEW()
	oClone:ccodigo              := ::ccodigo
	oClone:cdataAtualizacao     := ::cdataAtualizacao
	oClone:ndatajAtualizacao    := ::ndatajAtualizacao
	oClone:cdescricao           := ::cdescricao
	oClone:nhorajAtualizacao    := ::nhorajAtualizacao
	oClone:nid                  := ::nid
	oClone:csigla               := ::csigla
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_servicoAdicionalERP
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataAtualizacao   :=  WSAdvValue( oResponse,"_DATAATUALIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndatajAtualizacao  :=  WSAdvValue( oResponse,"_DATAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nhorajAtualizacao  :=  WSAdvValue( oResponse,"_HORAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::csigla             :=  WSAdvValue( oResponse,"_SIGLA","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure vigenciaERP

WSSTRUCT AtendeClienteService_vigenciaERP
	WSDATA   cdataFinal                AS dateTime OPTIONAL
	WSDATA   cdataInicial              AS dateTime OPTIONAL
	WSDATA   ndatajFim                 AS int OPTIONAL
	WSDATA   ndatajIni                 AS int OPTIONAL
	WSDATA   nid                       AS long OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_vigenciaERP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_vigenciaERP
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_vigenciaERP
	Local oClone := AtendeClienteService_vigenciaERP():NEW()
	oClone:cdataFinal           := ::cdataFinal
	oClone:cdataInicial         := ::cdataInicial
	oClone:ndatajFim            := ::ndatajFim
	oClone:ndatajIni            := ::ndatajIni
	oClone:nid                  := ::nid
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_vigenciaERP
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdataFinal         :=  WSAdvValue( oResponse,"_DATAFINAL","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataInicial       :=  WSAdvValue( oResponse,"_DATAINICIAL","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndatajFim          :=  WSAdvValue( oResponse,"_DATAJFIM","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndatajIni          :=  WSAdvValue( oResponse,"_DATAJINI","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","long",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure cartaoPostagemERP

WSSTRUCT AtendeClienteService_cartaoPostagemERP
	WSDATA   ccodigoAdministrativo     AS string OPTIONAL
	WSDATA   oWScontratos              AS AtendeClienteService_contratoERP OPTIONAL
	WSDATA   cdataAtualizacao          AS dateTime OPTIONAL
	WSDATA   cdataVigenciaFim          AS dateTime OPTIONAL
	WSDATA   cdataVigenciaInicio       AS dateTime OPTIONAL
	WSDATA   ndatajAtualizacao         AS int OPTIONAL
	WSDATA   ndatajVigenciaFim         AS int OPTIONAL
	WSDATA   ndatajVigenciaInicio      AS int OPTIONAL
	WSDATA   cdescricaoStatusCartao    AS string OPTIONAL
	WSDATA   cdescricaoUnidadePostagemGenerica AS string OPTIONAL
	WSDATA   nhorajAtualizacao         AS int OPTIONAL
	WSDATA   cnumero                   AS string OPTIONAL
	WSDATA   oWSservicos               AS AtendeClienteService_servicoERP OPTIONAL
	WSDATA   cstatusCartaoPostagem     AS string OPTIONAL
	WSDATA   cstatusCodigo             AS string OPTIONAL
	WSDATA   cunidadeGenerica          AS string OPTIONAL
	WSDATA   oWSunidadesPostagem       AS AtendeClienteService_unidadePostagemERP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_cartaoPostagemERP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_cartaoPostagemERP
	::oWScontratos         := {} // Array Of  AtendeClienteService_CONTRATOERP():New()
	::oWSservicos          := {} // Array Of  AtendeClienteService_SERVICOERP():New()
	::oWSunidadesPostagem  := {} // Array Of  AtendeClienteService_UNIDADEPOSTAGEMERP():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_cartaoPostagemERP
	Local oClone := AtendeClienteService_cartaoPostagemERP():NEW()
	oClone:ccodigoAdministrativo := ::ccodigoAdministrativo
	oClone:oWScontratos := NIL
	If ::oWScontratos <> NIL 
		oClone:oWScontratos := {}
		aEval( ::oWScontratos , { |x| aadd( oClone:oWScontratos , x:Clone() ) } )
	Endif 
	oClone:cdataAtualizacao     := ::cdataAtualizacao
	oClone:cdataVigenciaFim     := ::cdataVigenciaFim
	oClone:cdataVigenciaInicio  := ::cdataVigenciaInicio
	oClone:ndatajAtualizacao    := ::ndatajAtualizacao
	oClone:ndatajVigenciaFim    := ::ndatajVigenciaFim
	oClone:ndatajVigenciaInicio := ::ndatajVigenciaInicio
	oClone:cdescricaoStatusCartao := ::cdescricaoStatusCartao
	oClone:cdescricaoUnidadePostagemGenerica := ::cdescricaoUnidadePostagemGenerica
	oClone:nhorajAtualizacao    := ::nhorajAtualizacao
	oClone:cnumero              := ::cnumero
	oClone:oWSservicos := NIL
	If ::oWSservicos <> NIL 
		oClone:oWSservicos := {}
		aEval( ::oWSservicos , { |x| aadd( oClone:oWSservicos , x:Clone() ) } )
	Endif 
	oClone:cstatusCartaoPostagem := ::cstatusCartaoPostagem
	oClone:cstatusCodigo        := ::cstatusCodigo
	oClone:cunidadeGenerica     := ::cunidadeGenerica
	oClone:oWSunidadesPostagem := NIL
	If ::oWSunidadesPostagem <> NIL 
		oClone:oWSunidadesPostagem := {}
		aEval( ::oWSunidadesPostagem , { |x| aadd( oClone:oWSunidadesPostagem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_cartaoPostagemERP
	Local nRElem2, oNodes2, nTElem2
	Local nRElem13, oNodes13, nTElem13
	Local nRElem17, oNodes17, nTElem17
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodigoAdministrativo :=  WSAdvValue( oResponse,"_CODIGOADMINISTRATIVO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNodes2 :=  WSAdvValue( oResponse,"_CONTRATOS","contratoERP",{},NIL,.T.,"O",NIL,"xs") 
	nTElem2 := len(oNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( oNodes2[nRElem2] )
			aadd(::oWScontratos , AtendeClienteService_contratoERP():New() )
			::oWScontratos[len(::oWScontratos)]:SoapRecv(oNodes2[nRElem2])
		Endif
	Next
	::cdataAtualizacao   :=  WSAdvValue( oResponse,"_DATAATUALIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataVigenciaFim   :=  WSAdvValue( oResponse,"_DATAVIGENCIAFIM","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataVigenciaInicio :=  WSAdvValue( oResponse,"_DATAVIGENCIAINICIO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndatajAtualizacao  :=  WSAdvValue( oResponse,"_DATAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndatajVigenciaFim  :=  WSAdvValue( oResponse,"_DATAJVIGENCIAFIM","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndatajVigenciaInicio :=  WSAdvValue( oResponse,"_DATAJVIGENCIAINICIO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdescricaoStatusCartao :=  WSAdvValue( oResponse,"_DESCRICAOSTATUSCARTAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdescricaoUnidadePostagemGenerica :=  WSAdvValue( oResponse,"_DESCRICAOUNIDADEPOSTAGEMGENERICA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nhorajAtualizacao  :=  WSAdvValue( oResponse,"_HORAJATUALIZACAO","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cnumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNodes13 :=  WSAdvValue( oResponse,"_SERVICOS","servicoERP",{},NIL,.T.,"O",NIL,"xs") 
	nTElem13 := len(oNodes13)
	For nRElem13 := 1 to nTElem13 
		If !WSIsNilNode( oNodes13[nRElem13] )
			aadd(::oWSservicos , AtendeClienteService_servicoERP():New() )
			::oWSservicos[len(::oWSservicos)]:SoapRecv(oNodes13[nRElem13])
		Endif
	Next
	::cstatusCartaoPostagem :=  WSAdvValue( oResponse,"_STATUSCARTAOPOSTAGEM","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cstatusCodigo      :=  WSAdvValue( oResponse,"_STATUSCODIGO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cunidadeGenerica   :=  WSAdvValue( oResponse,"_UNIDADEGENERICA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNodes17 :=  WSAdvValue( oResponse,"_UNIDADESPOSTAGEM","unidadePostagemERP",{},NIL,.T.,"O",NIL,"xs") 
	nTElem17 := len(oNodes17)
	For nRElem17 := 1 to nTElem17 
		If !WSIsNilNode( oNodes17[nRElem17] )
			aadd(::oWSunidadesPostagem , AtendeClienteService_unidadePostagemERP():New() )
			::oWSunidadesPostagem[len(::oWSunidadesPostagem)]:SoapRecv(oNodes17[nRElem17])
		Endif
	Next
Return

// WSDL Data Structure contratoERPPK

WSSTRUCT AtendeClienteService_contratoERPPK
	WSDATA   ndiretoria                AS long OPTIONAL
	WSDATA   cnumero                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_contratoERPPK
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_contratoERPPK
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_contratoERPPK
	Local oClone := AtendeClienteService_contratoERPPK():NEW()
	oClone:ndiretoria           := ::ndiretoria
	oClone:cnumero              := ::cnumero
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_contratoERPPK
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ndiretoria         :=  WSAdvValue( oResponse,"_DIRETORIA","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cnumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure unidadePostagemERP

WSSTRUCT AtendeClienteService_unidadePostagemERP
	WSDATA   cdiretoriaRegional        AS string OPTIONAL
	WSDATA   oWSendereco               AS AtendeClienteService_enderecoERP OPTIONAL
	WSDATA   cid                       AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   cstatus                   AS string OPTIONAL
	WSDATA   ctipo                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_unidadePostagemERP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_unidadePostagemERP
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_unidadePostagemERP
	Local oClone := AtendeClienteService_unidadePostagemERP():NEW()
	oClone:cdiretoriaRegional   := ::cdiretoriaRegional
	oClone:oWSendereco          := IIF(::oWSendereco = NIL , NIL , ::oWSendereco:Clone() )
	oClone:cid                  := ::cid
	oClone:cnome                := ::cnome
	oClone:cstatus              := ::cstatus
	oClone:ctipo                := ::ctipo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_unidadePostagemERP
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdiretoriaRegional :=  WSAdvValue( oResponse,"_DIRETORIAREGIONAL","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode2 :=  WSAdvValue( oResponse,"_ENDERECO","enderecoERP",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode2 != NIL
		::oWSendereco := AtendeClienteService_enderecoERP():New()
		::oWSendereco:SoapRecv(oNode2)
	EndIf
	::cid                :=  WSAdvValue( oResponse,"_ID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cstatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ctipo              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Enumeration statusGerente

WSSTRUCT AtendeClienteService_statusGerente
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_statusGerente
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_statusGerente
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_statusGerente
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT AtendeClienteService_statusGerente
Local oClone := AtendeClienteService_statusGerente():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration tipoGerente

WSSTRUCT AtendeClienteService_tipoGerente
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_tipoGerente
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "GerenteConta" )
	aadd(::aValueList , "GerenteContaMaster" )
Return Self

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_tipoGerente
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_tipoGerente
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT AtendeClienteService_tipoGerente
Local oClone := AtendeClienteService_tipoGerente():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure usuarioInstalacao

WSSTRUCT AtendeClienteService_usuarioInstalacao
	WSDATA   cdataAtualizacao          AS dateTime OPTIONAL
	WSDATA   cdataInclusao             AS dateTime OPTIONAL
	WSDATA   cdataSenha                AS dateTime OPTIONAL
	WSDATA   oWSgerenteMaster          AS AtendeClienteService_gerenteConta OPTIONAL
	WSDATA   chashSenha                AS string OPTIONAL
	WSDATA   nid                       AS long OPTIONAL
	WSDATA   clogin                    AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   oWSparametros             AS AtendeClienteService_parametroMaster OPTIONAL
	WSDATA   csenha                    AS string OPTIONAL
	WSDATA   oWSstatus                 AS AtendeClienteService_statusUsuario OPTIONAL
	WSDATA   cvalidade                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_usuarioInstalacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_usuarioInstalacao
	::oWSparametros        := {} // Array Of  AtendeClienteService_PARAMETROMASTER():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_usuarioInstalacao
	Local oClone := AtendeClienteService_usuarioInstalacao():NEW()
	oClone:cdataAtualizacao     := ::cdataAtualizacao
	oClone:cdataInclusao        := ::cdataInclusao
	oClone:cdataSenha           := ::cdataSenha
	oClone:oWSgerenteMaster     := IIF(::oWSgerenteMaster = NIL , NIL , ::oWSgerenteMaster:Clone() )
	oClone:chashSenha           := ::chashSenha
	oClone:nid                  := ::nid
	oClone:clogin               := ::clogin
	oClone:cnome                := ::cnome
	oClone:oWSparametros := NIL
	If ::oWSparametros <> NIL 
		oClone:oWSparametros := {}
		aEval( ::oWSparametros , { |x| aadd( oClone:oWSparametros , x:Clone() ) } )
	Endif 
	oClone:csenha               := ::csenha
	oClone:oWSstatus            := IIF(::oWSstatus = NIL , NIL , ::oWSstatus:Clone() )
	oClone:cvalidade            := ::cvalidade
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_usuarioInstalacao
	Local oNode4
	Local nRElem9, oNodes9, nTElem9
	Local oNode11
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdataAtualizacao   :=  WSAdvValue( oResponse,"_DATAATUALIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataInclusao      :=  WSAdvValue( oResponse,"_DATAINCLUSAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdataSenha         :=  WSAdvValue( oResponse,"_DATASENHA","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode4 :=  WSAdvValue( oResponse,"_GERENTEMASTER","gerenteConta",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode4 != NIL
		::oWSgerenteMaster := AtendeClienteService_gerenteConta():New()
		::oWSgerenteMaster:SoapRecv(oNode4)
	EndIf
	::chashSenha         :=  WSAdvValue( oResponse,"_HASHSENHA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::clogin             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNodes9 :=  WSAdvValue( oResponse,"_PARAMETROS","parametroMaster",{},NIL,.T.,"O",NIL,"xs") 
	nTElem9 := len(oNodes9)
	For nRElem9 := 1 to nTElem9 
		If !WSIsNilNode( oNodes9[nRElem9] )
			aadd(::oWSparametros , AtendeClienteService_parametroMaster():New() )
			::oWSparametros[len(::oWSparametros)]:SoapRecv(oNodes9[nRElem9])
		Endif
	Next
	::csenha             :=  WSAdvValue( oResponse,"_SENHA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode11 :=  WSAdvValue( oResponse,"_STATUS","statusUsuario",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode11 != NIL
		::oWSstatus := AtendeClienteService_statusUsuario():New()
		::oWSstatus:SoapRecv(oNode11)
	EndIf
	::cvalidade          :=  WSAdvValue( oResponse,"_VALIDADE","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Enumeration categoriaServico

WSSTRUCT AtendeClienteService_categoriaServico
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_categoriaServico
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "SEM_CATEGORIA" )
	aadd(::aValueList , "PAC" )
	aadd(::aValueList , "SEDEX" )
	aadd(::aValueList , "CARTA_REGISTRADA" )
	aadd(::aValueList , "SERVICO_COM_RESTRICAO" )
	aadd(::aValueList , "REVERSO" )
Return Self

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_categoriaServico
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_categoriaServico
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT AtendeClienteService_categoriaServico
Local oClone := AtendeClienteService_categoriaServico():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure chancelaMaster

WSSTRUCT AtendeClienteService_chancelaMaster
	WSDATA   cchancela                 AS base64Binary OPTIONAL
	WSDATA   cdataAtualizacao          AS dateTime OPTIONAL
	WSDATA   cdescricao                AS string OPTIONAL
	WSDATA   nid                       AS long OPTIONAL
	WSDATA   oWSservicosSigep          AS AtendeClienteService_servicoSigep OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_chancelaMaster
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_chancelaMaster
	::oWSservicosSigep     := {} // Array Of  AtendeClienteService_SERVICOSIGEP():New()
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_chancelaMaster
	Local oClone := AtendeClienteService_chancelaMaster():NEW()
	oClone:cchancela            := ::cchancela
	oClone:cdataAtualizacao     := ::cdataAtualizacao
	oClone:cdescricao           := ::cdescricao
	oClone:nid                  := ::nid
	oClone:oWSservicosSigep := NIL
	If ::oWSservicosSigep <> NIL 
		oClone:oWSservicosSigep := {}
		aEval( ::oWSservicosSigep , { |x| aadd( oClone:oWSservicosSigep , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_chancelaMaster
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cchancela          :=  WSAdvValue( oResponse,"_CHANCELA","base64Binary",NIL,NIL,NIL,"SB",NIL,"xs") 
	::cdataAtualizacao   :=  WSAdvValue( oResponse,"_DATAATUALIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	oNodes5 :=  WSAdvValue( oResponse,"_SERVICOSSIGEP","servicoSigep",{},NIL,.T.,"O",NIL,"xs") 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSservicosSigep , AtendeClienteService_servicoSigep():New() )
			::oWSservicosSigep[len(::oWSservicosSigep)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
Return

// WSDL Data Structure parametroMaster

WSSTRUCT AtendeClienteService_parametroMaster
	WSDATA   nprmCoParametro           AS long OPTIONAL
	WSDATA   cprmTxParametro           AS string OPTIONAL
	WSDATA   cprmTxValor               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_parametroMaster
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AtendeClienteService_parametroMaster
Return

WSMETHOD CLONE WSCLIENT AtendeClienteService_parametroMaster
	Local oClone := AtendeClienteService_parametroMaster():NEW()
	oClone:nprmCoParametro      := ::nprmCoParametro
	oClone:cprmTxParametro      := ::cprmTxParametro
	oClone:cprmTxValor          := ::cprmTxValor
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_parametroMaster
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nprmCoParametro    :=  WSAdvValue( oResponse,"_PRMCOPARAMETRO","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cprmTxParametro    :=  WSAdvValue( oResponse,"_PRMTXPARAMETRO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cprmTxValor        :=  WSAdvValue( oResponse,"_PRMTXVALOR","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Enumeration statusUsuario

WSSTRUCT AtendeClienteService_statusUsuario
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AtendeClienteService_statusUsuario
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT AtendeClienteService_statusUsuario
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AtendeClienteService_statusUsuario
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT AtendeClienteService_statusUsuario
Local oClone := AtendeClienteService_statusUsuario():New()
	oClone:Value := ::Value
Return oClone

