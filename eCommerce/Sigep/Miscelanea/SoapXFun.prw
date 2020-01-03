#INCLUDE "PROTHEUS.CH"
//#INCLUDE "XMLCSVCS.CH"

// Versão atual deste fonte-conversor
// ## APENAS ALTERAR NUMEROS : NAO MEXER NO TAMANHO E POSICOES ##
// ## FORMATO DE VERSAO : 1.AAMMDD                             ##
#DEFINE WSDLCLIENT_VERSION 		'ADVPL WSDL Client 1.090116'

// Defines com Builds Protheus por compatibilidade com novas implementações
#DEFINE  ACTUAL_BUILD		left(GetBuild(),11)
#DEFINE  LONGNAMES_BUILD	'7.00.030715'

// Fontes gerados com esta versão exigem lib de infra-estrutura
// igual ou superior `a definida abaixo ...
// ## NAO MEXA NO TAMANHO DA STRING, NAO PONHA LETRA E NAO MEXA NO PONTO ##
#DEFINE  WSDL_CLIENT_COMPATIBLE '1.040504'

// Defines com Versões de Lib Server do PRotheus para breaks de compatibilidade
#DEFINE  NEWWSDL_VERSION	'1.031217'

STATIC __nTimeOut       := 120
STATIC __WSDLError	:= ''			// Armazenar ocorrências de Erro
STATIC __DbgLevel		:= 0			// Armazena Nivel de Debug para a Thread Atual
STATIC __DbgInfo		:= ''			// Informações de Debug
STATIC __AdvType  	:= {} 		// Nomes de Variaveis ADVPL para Types...
STATIC __DbgProfile	:= .F.		// Flag para habilitar PROFILE de execução Client
STATIC __DbgSaveXML	:= .F.		// Flag para salvar xmls no disco

STATIC __UseLongNames
STATIC __UseHttps

STATIC __SvcPrefix	:= NIL

STATIC __ExternalRef := .F.
STATIC __FatalError	:= .F.
STATIC __NameSpaces := {}

// Variaveis de controle de tratamento de erro em Client
STATIC __MethodBlock := NIL
STATIC __ClientStack := ''

// Informacoes adicionais de Controle de SOAP_FAULT

STATIC __SFaultCode
STATIC __SFaultStr
STATIC __SFaultObj

// Controle de namespaces dentro de uma requisicao client
STATIC __NSSoapCall 	:= {}

STATIC aPendIO			:= {}			// Array com estruturas e urilização em Input , Output ou ambos.

STATIC aType	:= {}	// Types
STATIC aMsg		:= {}	// Messages
STATIC aPort	:= {} // Port
STATIC aBind	:= {} // aBinding
STATIC aServ	:= {} // aServices
STATIC aName	:= {} // aNameSpaces
STATIC aImport := {} // Imports

STATIC aImportDone := {} // Imports já processados

STATIC __ExistUtf8		       // Se a função de Encode Utf-8, já está disponível --> ANDRÉ
STATIC __CtTypeUsed	   		 // ContentType utilizado --> utf-8 ou iso-8859-1

STATIC __XMLURLPost  := ''
STATIC __XMLHeadRet	:= ''
STATIC __XMLPostRet	:= ''
STATIC __XMLSaveInfo	:= .F.

STATIC __XMLCTimer 	:= 0
STATIC __XMLCPLog		:= ''

STATIC __lXmlChildEx	:= .F.
STATIC __lXmlFnChild := 'XMLCHILDEX'

STATIC __aMPar := {}	// Static de Controle de Parâmetros do Método

STATIC __UseSpecial	:= .F.

// STATIC para controle : Se o client a ser regerado deve usar alias
// por compatibilidade com estruturas de parâmetro para servers protheus
// atualizados com a correção no WSDL ...
// Esta informação é verificada no momento da interpretação do retorno
// da httpget , através da presença do header http

STATIC __UseAlias		:= .F.

// Static de controle de msg de Warning por client gerado a partir de WSDL
// fornecido por server Protheus NOVO e executado em server protheus VELHO
// Caso preenchido, informa a versão sob a qual o fonte client necessita
// para rodar ok.
STATIC __WarnBuild	:= ''

// Static para msgs diversas de advertencia
STATIC __WarnMsg := {}

// Static de Controle para SoapAction alternativo na chamada do client.

STATIC __SoapAct

// SUPORTE PARA PADRAO .NET
STATIC __UseEmptyNS := .F.

// Definições para TYPES

#DEFINE WSDLTYPE_NAME			1	// Nome do Parâmetro
#DEFINE WSDLTYPE_DEFINITION	2	// Definição : complexType , element ...
#DEFINE WSDLTYPE_TYPE	 		3  // Tipo do Parâmetro
#DEFINE WSDLTYPE_MINOCCCURS	4  // Numero minimo de ocorrências
#DEFINE WSDLTYPE_MAXOCCCURS	5  // Numero máximo de ocorrências
#DEFINE WSDLTYPE_UNKNOW1		6  // ???
#DEFINE WSDLTYPE_REF				7  // Element Ref=
#DEFINE WSDLTYPE_STRUCTIN		8	// Elemento Interno
#DEFINE WSDLTYPE_EXT_BASE		9	// Extension Base do Elemento Interno

#DEFINE WSDLTYPE_NAMESPACE		10  // NAMESPACE EXPLICITO DO ELEMENTO 


/* 				--- WSDLTYPE_DEFINITION ---
attribute		Apenas nome e tipo basico para validacao
element			Atributo com mais propriedades
simpletype		Usado para Enumerations ...
complextype		Tipo complexto , estrutura e afins.
any				Contido em uma estrutura , identifica o pai como se fosse um "SCHEMA"
*/

// Definições de Serviços

#DEFINE WSDLSERVICE_NAME		1
#DEFINE WSDLSERVICE_APORT		2

#DEFINE WSDLSERVICE_PORT_NAME			1
#DEFINE WSDLSERVICE_PORT_TYPE			2	// soap , http ,...
#DEFINE WSDLSERVICE_PORT_BINDING		3
#DEFINE WSDLSERVICE_PORT_LOCATION	4

// Definições para Bindings

#DEFINE WSDLBIND_NAME				1
#DEFINE WSDLBIND_TYPE				2
#DEFINE WSDLBIND_PORTTYPE			3	// Soap ou HTTP
#DEFINE WSDLBIND_SOAPTRANSPORT	4
#DEFINE WSDLBIND_SOAPSTYLE			5  // Document or RPC
#DEFINE WSDLBIND_AOPER				6

#DEFINE WSDLBIND_OPER_NAME									1
#DEFINE WSDLBIND_OPER_SOAPACTION							2
#DEFINE WSDLBIND_OPER_STYLE								3
#DEFINE WSDLBIND_OPER_INPUT_BODY_USE					4
#DEFINE WSDLBIND_OPER_INPUT_BODY_NAMESPACE         5 	// Usado em RPC (?)
#DEFINE WSDLBIND_OPER_INPUT_BODY_ENCODINGSTYLE     6
#DEFINE WSDLBIND_OPER_INPUT_HEADER_REQUIRED        7
#DEFINE WSDLBIND_OPER_INPUT_HEADER_MESSAGE         8
#DEFINE WSDLBIND_OPER_INPUT_HEADER_PART            9
#DEFINE WSDLBIND_OPER_INPUT_HEADER_USE             10
#DEFINE WSDLBIND_OPER_OUTPUT_BODY_USE              11
#DEFINE WSDLBIND_OPER_OUTPUT_BODY_NAMESPACE        12 	// Usado em RPC (?)
#DEFINE WSDLBIND_OPER_OUTPUT_BODY_ENCODINGSTYLE    13
#DEFINE WSDLBIND_OPER_OUTPUT_HEADER_REQUIRED       14
#DEFINE WSDLBIND_OPER_OUTPUT_HEADER_MESSAGE        15
#DEFINE WSDLBIND_OPER_OUTPUT_HEADER_PART           16
#DEFINE WSDLBIND_OPER_OUTPUT_HEADER_USE            17

// Definicões para PortTypes

#DEFINE WSDLPORT_NAME			1
#DEFINE WSDLPORT_AOPER			2

#DEFINE WSDLPORT_OPERNAME			1
#DEFINE WSDLPORT_OPERINPUT			2
#DEFINE WSDLPORT_OPEROUTPUT		3

// Definições para Messages & Parts

#DEFINE WSDLMESSAGE_NAME		1
#DEFINE WSDLMESSAGE_UNKNOW		2
#DEFINE WSDLMESSAGE_APART		3

#DEFINE WSDLMESSAGE_PARTNAME		1
#DEFINE WSDLMESSAGE_PARTELEM		2

// Definicoes para aName
#DEFINE WSDLNS_SOURCE				1
#DEFINE WSDLNS_ID						2

// Defincioes de aImport

#DEFINE WSDLIMPORT_NAMESPACE 			1
#DEFINE WSDLIMPORT_SCHEMALOCATION	2
#DEFINE WSDLIMPORT_LOCATION			3

/* ----------------------------------------------------------------------------------
Funcao		SvcSoapCall(oSvcObj,cSoap,cSoapAction,cSoapStyle,cNameSpace,cSoapHead,cXBuild)
Autor			Julio Wittwer
Data			14/10/2002
Descrição 	Realiza a chamada do Servico, já alimentando o objeto de retorno

RELEASE 		18/12/2003 Parametro cXBuild, caso passado, indica que este
fonte client foi gerado a partir de um WSDL fornecido por um
PRotheus com a lib NEWWSDL_VERSION ou superior.
15/01/2004 Parametro cPostUrl colocado diretamente no fonte
---------------------------------------------------------------------------------- */
User Function XSoapCall(oSvcObj,cSoap,cSoapAction,cSoapStyle,cNameSpace,cSoapHead,cXBuild, cPostUrl,cApl )
Local cError 		:= '' 
Local cWarning		:= ''
Local oXmlRet		:= Nil
Local aHeadOut 		:= {}
Local cSoapSend 	:= ''
Local aTmpTypes 	:= {}
Local nPosTypes 	:= 0
Local cSoapPrefix 	:= ''
Local cUrl 			:= ''
Local aTmp1 		:= {}
Local aTmp2			:= {}
Local cHeaderRet 	:= ''
Local cXMLFile
Local lURLChanged 	:= .F. 
Local lChanged 		:= .F. 
Local cOldSoap 		:= ''
Local nRetry      	:= 0
Local nStart      	:= 0

// Re-inicializa STATICs de Controle de POST do Client
__XMLURLPost 		:= ''
__XMLPostRet 		:= ''
__XMLHeadRet 		:= ''
__XMLSaveInfo		:= .F.

// Inicializa controle de namespace de retorno desta requisicao
asize(__NSSoapCall,0)

// Reinicializa STATIC de controle de PROFILE
__XMLCPLog		:= ''

// Identifica se a função XMLCHILDEX está compilada ...
__lXmlChildEx	:= FindFunction(__lXmlFnChild)

DEFAULT cSoapHead := ''
Default	cApl	  := '' 	

// Verifica se o build atual têm a função XmlPArser
If !FindFunction('XMLPARSER') ; UserException('WSCERRINT / Build '+GETBUILD()+' does not support Web Services.') ; Endif

// Zera variaveis STATIC de controle de Erros SOAP_FAULT
__SFaultCode   	:= NIL
__SFaultStr 	:= NIL
__SFaultObj		:= NIL

// Identifica a URL a submeter

If cPostUrl <> NIL
	// Fonte client gerado com lib de webservices nova !
	// Passa a URL a submeter na linha de chamada da svcsoapcall
	If oSvcObj:_URL <> NIL
		// Caso a _URL seja passada na propriedade , esta prevalece sobre
		// a default, e liga flag informando que o SoapAction deve ser re-montado.
		cUrl 			:= oSvcObj:_URL
		lURLChanged	:= .T.
	Else
		// Caso o _URL não seja alimentado, utiliza a url original do serviço.
		cUrl 			:= cPostUrl
	Endif
Else
	// Fonte gerado com lib anterior à x.040115
	// Pega a URL a partir da propriedade _URL
	cUrl := oSvcObj:_URL
Endif

If empty(cUrl)
	UserException("WSCERR042 / "+"URL LOCATION não especificada.") // "URL LOCATION não especificada."
ElseIf IsHttpsURL(cUrl) .and. !IsHTTPSBuild()
	UserException("WSCERR070 / "+"Requisição HTTPS não suportada neste BUILD" +" ["+GetBuild()+"]") // "Requisição HTTPS não suportada neste BUILD"
Endif

If !empty(__SoapAct)
	
	// Caso tenha sido especificado um Soap Action alternativo para esta chamada,
	// Ele é utilizado apenas para esta chamada e a STATIC de controle é limpa !
	
	cOldSoap 	:= cSoapAction
	cSoapAction	:= __SoapAct
	__SoapAct 	:= NIL
	
	// Seta que soapaction foi alterado
	lChanged := .t.
	
Endif

If __DbgLevel > 1
	conout(replicate('-',79))
	conout("SvcSoapCall to "+cUrl+" / "+cSoapStyle)
	conout("NameSpace "+cNameSpace)
	conout("SoapAction "+cSoapAction)
	If lURLChanged
		conout("ORIGINAL URL : "+cPostURL)
	Endif
	If lChanged
		conout("ORIGINAL SOAPACTION : "+cOldSoap)
	Endif
	conout(GetStack())
Endif

// Acrescenta Informações adicionais no Header da requisição
aadd(aHeadOut,'SOAPAction: '+cSoapAction)
aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8' )

// Acrescenta o UserAgent na requisição ...
aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+'; '+WSDLCLIENT_VERSION+')')

//cSoapSend += '<?xml version="1.0" encoding="'+__CtTypeUsed+'"?>'

IF cSoapStyle == "DOCUMENT"
	cSoapSend += '<soap:Envelope '
	cSoapSend += 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += 'xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
	cSoapSend += 'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" '
	cSoapSend += 'xmlns:'+ cApl +'="' + cNameSpace+'">'
ElseIF cSoapStyle == "DOCUMENTSOAP12"
	cSoapSend += '<soap:Envelope '
	cSoapSend += 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += 'xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
	cSoapSend += 'xmlns:soap="http://www.w3.org/2003/05/soap-envelope">'
ElseIF cSoapStyle == "RPC" .or. cSoapStyle == "RPCX"
	cSoapSend += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += 	'xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
	cSoapSend += 	'xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" '
	cSoapSend += 	'xmlns:tns="'+cNameSpace+'" '
	cSoapSend += 	'xmlns:types="'+cNameSpace+'encodedTypes" '
	cSoapSend += 	'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	
Else
	
	UserException("WSCERR043 / ["+cSoapStyle+"] "+"SOAPSTYLE Desconhecido.") // "SOAPSTYLE Desconhecido."
	
Endif

If !empty(cSoapHead)
	cSoapSend += '<soap:Header>'
	cSoapSend += cSoapHead
	cSoapSend += '</soap:Header>'
Endif

If cSoapStyle == "DOCUMENT" .OR. cSoapStyle == "DOCUMENTSOAP12"
	cSoapSend += '<soap:Body>'
ElseIF cSoapStyle == "RPC" .or. cSoapStyle == "RPCX"
	cSoapSend += '<soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
Endif

cSoapSend += cSoap

cSoapSend += '</soap:Body>'
cSoapSend += '</soap:Envelope>'

If left(csoap,1)=="_"
	// RECURSO DE DEBUG :
	// Caso o Soap enviado inicie com _ , manda ele direto pro destino
	// sem acrescentar os header's e definições....
	cSoapSend := substr(cSoap,2)
Endif

If __DbgLevel > 1
	conout(padc(" SOAPSEND ",79,"-"))
	conout(strtran(cSoapSend,"><",">"+CRLF+"<"))
	conout(replicate("-",79))
Endif

If __DbgSaveXML
	// Cria nome de arquivo temporario
	cXMLFile := str(seconds()*1000,8)
	// salva o XML a ser enviado no disco
	memowrit(cXMLFile+'_snd.xml',cSoapSend)
Endif

If __DbgProfile	 ; 	MarkTimer() ; Endif
               
//-----------------------------
// Tenta por 2 minutos ou 3 vezes antes de abortar
//    - Adicionado para proteger erros de código de WSClient Protheus
//-----------------------------
nStart := Seconds()
nRetry := 0
While nRetry <3 
	__XMLPostRet := Httppost(cUrl,"",cSoapSend,__nTimeOut,aHeadOut,@__XMLHeadRet)
	
	If __XMLPostRet <> Nil
		nRetry := 4
		Exit
	Else
		nRetry++
		If (Seconds() - nStart) >= __nTimeOut	
			nRetry := 4
			Exit
		EndIf
	EndIf	
EndDo

If __XMLPostRet = NIL
	UserException("WSCERR044 / Não foi possível POST : URL "+cURL) // Não foi possível POST
ElseIf Empty(__XMLPostRet)
	If !empty(__XMLHeadRet)
		UserException("WSCERR045 / Não foi possível POST : URL "+cURL+' ['+__XMLHeadRet+']')
	Else
		UserException("WSCERR045 / Não foi possível POST : URL "+cURL)
	Endif
Endif

If __DbgProfile
	ShowTimer(	"HTTPPost ( Send "+str(len(cSoapSend),8)+" bytes. / "+;
	"Receive "+str(len(__XMLPostRet),8)+" bytes.)")
Endif

If __DbgSaveXML
	// Salva XML Recebido no disco
	memowrit(cXMLFile+'_rcv.xml',__XMLPostRet)
Endif

// Alimenta static de controle de ultimo POST
__XMLURLPost := cUrl

If __DbgLevel > 0
	conout(padc(" POST RETURN ",79,'='))
	If !empty(__XMLHeadRet)
		conout(__XMLHeadRet)
		conout(replicate('-',79))
	Endif
	conout(__XMLPostRet)
	conout(replicate('=',79))
Endif

// --------------------------------------------------------
// Antes de Mandar o XML para o PArser ,
// Verifica se o Content-Type é XML !
// Se não for , nem perde tempo em parsear nada !
// Content-Type: text/xml; charset=utf-8
// ========================================================
// ATENCAO : Não é feita a consistência do content-type
// caso o __XMLHeadRet esteja vazio, pois o retorno do header
// por referência na função httppost foi realizado a partir de
// uma versão de Binário .
// --------------------------------------------------------

If !empty(__XMLHeadRet)
	cHeaderRet := __XMLHeadRet
	nPosCType := at("CONTENT-TYPE:",Upper(cHeaderRet))
	If nPosCType > 0
		cHeaderRet := substr(cHeaderRet,nPosCType)
		nPosCTEnd := at(CRLF , cHeaderRet)
		cHeaderRet := substr(cHeaderRet,1,IIF(nPosCTEnd > 0 ,nPosCTEnd-1, NIL ) )
		If !"XML"$upper(cHeaderRet)
			__XMLSaveInfo := .T.
			UserException("WSCERR064 / Invalid Content-Type return ("+cHeaderRet+") from "+cURL+CRLF+" HEADER:["+__XMLHeadRet+"] POST-RETURN:["+__XMLPostRet+"]")
		Endif
	Else
		__XMLSaveInfo := .T.
		UserException("WSCERR065 / EMPTY Content-Type return ("+cHeaderRet+") from "+cURL+CRLF+" HEADER:["+__XMLHeadRet+"] POST-RETURN:["+__XMLPostRet+"]")
	Endif
Endif


If __DbgProfile	 ; 	MarkTimer() ; Endif

// Passa pela XML Parser...
oXmlRet := XmlParser(__XMLPostRet,'_',@cError,@cWarning)

If __DbgProfile
	ShowTimer(	"Convert XML String to Advpl XML Object. (XMLPArser)")
Endif

If !empty(cWarning)
	__XMLSaveInfo := .T.
	UserException('WSCERR046 / XML Warning '+cWarning+' ( POST em '+cURL+' )'+CRLF+" HEADER:["+__XMLHeadRet+"] POST-RETURN:["+__XMLPostRet+"]")
ElseIf !empty(cError)
	__XMLSaveInfo := .T.
	UserException('WSCERR047 / XML Error '+cError+' ( POST em '+cURL+' )'+CRLF+" HEADER:["+__XMLHeadRet+"] POST-RETURN:["+__XMLPostRet+"]")
ElseIF oXmlRet = NIL
	__XMLSaveInfo := .T.
	UserException('WSCERR073 / Build '+GETBUILD()+' XML Internal Error.'+CRLF+" HEADER:["+__XMLHeadRet+"] POST-RETURN:["+__XMLPostRet+"]")
Endif

// Identifica os nodes inicias envelope e body
// Eles devem ser os primeiros niveis do XML

If Empty(aTmp1 := ClassDataArr(oXmlRet))
	__XMLSaveInfo := .T.
	aTmp1 := NIL
	UserException('WSCERR056 / Invalid XML-Soap Server Response : soap-envelope not found.')
Endif

If empty(cEnvSoap := aTmp1[1][1])
	aTmp1 := NIL
	__XMLSaveInfo := .T.
	UserException('WSCERR057 / Invalid XML-Soap Server Response : soap-envelope empty.')
Endif

// Limpa a variável temporária
aTmp1 := NIL

// Elimina este node, re-atribuindo o Objeto
oXmlRet := xGetInfo( oXmlRet, cEnvSoap  )

If valtype(oXmlRet) <> 'O'
	__XMLSaveInfo := .T.
	UserException('WSCERR058 / Invalid XML-Soap Server Response : Invalid soap-envelope ['+cEnvSoap+'] object as valtype ['+valtype(oXmlRet)+']')
Endif

If Empty(aTmp2 := ClassDataArr(oXmlRet))
	aTmp2 := NIL 
	__XMLSaveInfo := .T.
	UserException('WSCERR059 / Invalid XML-Soap Server Response : soap-body not found.')
Endif

If empty(cEnvBody := aTmp2[1][1])
	aTmp2 := NIL 
	__XMLSaveInfo := .T.
	UserException('WSCERR060 / Invalid XML-Soap Server Response : soap-body envelope empty.')
Endif

// Limpa a variável temporária
aTmp2 := NIL 

// Elimina este node, re-atribuindo o Objeto
oXmlRet := xGetInfo( oXmlRet, cEnvBody )

If valtype(oXmlRet) <> 'O'
	__XMLSaveInfo := .T.
	UserException('WSCERR061 / Invalid XML-Soap Server Response : Invalid soap-body ['+cEnvBody+'] object as valtype ['+valtype(oXmlRet)+']')
Endif

cSoapPrefix := substr(cEnvSoap,1,rat("_",cEnvSoap)-1)

If Empty(cSoapPrefix)
	__XMLSaveInfo := .T.
	UserException('WSCERR062 / Invalid XML-Soap Server Response : Unable to determine Soap Prefix of Envelope ['+cEnvSoap+']')
Endif

/*
ESTRUTURA DE SOAP FAULT 1.2

<soap:Fault>
	<faultcode></faultcode>
	<faultstring></faultstring>
	<faultactor></faultactor>
	<detail></detail>
</soap:Fault>
*/

If xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:TEXT" ) != NIL
	// Se achou um soap_fault....
	
	cFaultString := xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
	
	If !empty(cFaultString)		
		// OPA, protocolo soap 1.0 ou 1.1	
		cFaultCode := xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
		cFaultString := xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTSTRING:TEXT" )
	Else 
		// caso contrario, trato como soap 1.2		  
		cFaultCode := xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )	
		If Empty(cFaultCode)
			cFaultCode := xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_CODE:TEXT" )
		Else
			cFaultCode += " [FACTOR] " + xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTACTOR:TEXT" )
		EndIf		
		DEFAULT cFaultCode := ""
		cFaultString := xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_DETAIL:TEXT" )
		If !Empty(cFaultString)
			cFaultString := xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTSTRING:TEXT" ) + " [DETAIL] " + cFaultString
		Else
			cFaultString :=  xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_REASON:"+cSoapPrefix+"_TEXT:TEXT" )
			DEFAULT cFaultString := ""
			cFaultString += " [DETAIL] " + xGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_DETAIL:TEXT" )
			DEFAULT cFaultString := ""
		Endif
	Endif
	
	// Seta Statics de controle de Soap Fault adicionais
	__SFaultCode   := cFaultCode
	__SFaultStr 	:= cFaultString
	__SFaultObj		:= oXmlRet
	
	// Inicializa static de Warning de Build de WebServices SERVER PRotheus
	// Caso o build tenha sido passado como parâmetro
	If !empty(cXBuild)
		__WarnBuild := cXBuild
	Endif
	
	// Aborta processamento atual com EXCEPTION
	UserException('WSCERR048 / SOAP FAULT '+cFaultCode+' ( POST em '+cURL+' ) : ['+cFaultString+']')
	
Endif

If cSoapStyle == "RPC" .or. cSoapStyle == "RPCX"
	
	// RPCTUNGA  : Identifica o node de response
	aTmpTypes := ClassDataArr(oXmlRet)
	
	// Localiza o Node de Response
	nPosTypes := ascan(aTmpTypes,{|x| isNode(x[2]) .and. "RESPONSE"$x[1] })
	
	If nPosTypes = 0
		// Se não achou o Response ... pega o primeiro Node (?)
		nPosTypes := ascan(aTmpTypes,{|x| isNode(x[2]) })
	Endif
	
	If nPosTypes = 0
		__XMLSaveInfo := .T.
		UserException('WSCERR049 / SOAP RESPONSE (RPC) NOT FOUND.')
	Endif
	
	If cSoapStyle == "RPC"
		
		// TRATAMENTO MANTIDO POR COMPATIBILIDADE PARA CLIENTS ANTIGOS
		// Que chamam esta função passando soapstyle = RPC ....
		// Quando não é referência , tem que arrancar
		// também Nível de RETORNO !!! OS novos clients gerados a partir da
		// versão x.xxxxxxxxxx buscam o dado no luigar certo do node
		
		// Verifica se o node de response faz referência a outro node
		// Primeiro pega o nome do node de resposta
		cRNodeName := ClassDataArr(aTmpTypes[nPosTypes][2])[1][1]
		
		cRef := xGetInfo( aTmpTypes[nPosTypes][2],cRNodeName+":_HREF:TEXT" )
		DEFAULT cRef := ''
		cRef := IIF(left(cRef,1)=="#", Substr(cRef,2),cRef)
		
		IF !empty(cRef)
			
			// Se está fazendo referência a alguem ...
			// PRocura o node no Raiz com ID especificado
			
			nPosTypes := ascan(aTmpTypes,{|x| isNode(x[2]) .and. xGetInfo(x[2],'_ID:TEXT') == cRef })
			
			If nPosTypes = 0
				__XMLSaveInfo := .T.
				UserException('WSCERR050 / SOAP RESPONSE REF '+cRef+' (RPC) NOT FOUND.')
			Endif
			
			// Retorna o Conteudo da Referência ...
			// Quando é referência , o nivel de retorno já foi arrancado
			oXmlRet := xGetInfo( oXmlRet, aTmpTypes[nPosTypes][1] )
			
		Else
			
			// Retorna o Conteudo do Node
			oXmlRet := xGetInfo( oXmlRet, aTmpTypes[nPosTypes][1] )
			
			// E arranca proximo nivel tb ...
			aTmpTypes := ClassDataArr(oXmlRet)
			
			nPosTypes := ascan(aTmpTypes,{|x| isNode(x[2]) })
			
			If nPosTypes = 0
				__XMLSaveInfo := .T.
				UserException('WSCERR051 / SOAP RESPONSE RETURN (RPC) NOT FOUND.')
			Endif
			
			// Agora sim , Retorna o Conteudo do Node
			oXmlRet := xGetInfo( oXmlRet, aTmpTypes[nPosTypes][1] )
			
		Endif
		
	ElseIf cSoapStyle == "RPCX"
		
		// Tratamento corrigido : Retorna apenas o primeiro nivel de resposta
		// do node. O tratamento de referências deve ser estudado !!!
		// Pois a especificação de referências é MUITO ABERTA
		
		// Retorna o Conteudo do Node...
		oXmlRet := xGetInfo( oXmlRet, aTmpTypes[nPosTypes][1] )
		
	Else
		
		UserException("*** UNEXPECTED SOAPSTYLE "+cSoapStyle+" ***")
		
	Endif
	
Endif

If __DbgProfile
	conout(	replicate('-',79),;
	'POST on '+__XMLURLPost,;
	'SoapAction '+cSoapAction,;
	__XMLCPLog,;
	replicate('-',79))
	__XMLCPLog := ''
Endif

Return oXmlRet

/* -------------------------------------------------------------------------------
Funcao		IsHttpsURL(cUrl)
Autor			Julio Wittwer
Data			09/12/2003
Descrição	Determina se a URl é HTTPS
------------------------------------------------------------------------------- */
STATIC Function IsHttpsURL(cUrl)
Return ( upper(left(cUrl,6)) == "HTTPS:" )

/* -------------------------------------------------------------------------------
Funcao		IsHTTPSBuild()
Autor			Julio Wittwer
Data			09/12/2003
Descrição	Determina se o build atual suporta https
------------------------------------------------------------------------------- */
STATIC Function IsHTTPSBuild()
If __UseHttps = NIL
	__UseHttps := FindFunction('IsSecure')
Endif
Return __UseHttps