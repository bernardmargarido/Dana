#INCLUDE "PROTHEUS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*******************************************************************************************************/
/*/{Protheus.doc} ECLOJM08
    @description Realiza o envio de e-mail contendo o rastreio
    @type  Function
    @author Bernard M. Margarido
    @since 20/08/2021
/*/
/*******************************************************************************************************/
User Function ECLOJM08(_cNumOrc)
Local _aArea        := GetArea()

Local _cTracking    := ""
Local _cBody        := ""
Local _cNome        := ""
Local _cNumEco      := ""
Local _cEnd         := ""
Local _cBairro      := ""
Local _cMunicipio   := ""
Local _cEstado      := ""
Local _cCep         := ""
Local _cComplemento := ""
Local _cReferencia  := ""

CoNout("<< ECLOJM08 >> - INICIA ENVIO DE E-MAIL DE RASTREAMENTO")
//-----------------------------+
// Posiciona pedido e-Commerce |
//-----------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(1) )
If !WSA->( dbSeek(xFilial("WSA") + _cNumOrc))
    CoNout("<< ECLOJM08 >> - ORCAMENTO " + _cNumOrc + " NAO LOCALIZADO")
    RestArea(_aArea)
    Return .T.
EndIf

//-------------------+
// Posiciona cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
If !SA1->( dbSeek(xFilial("SA1") + WSA->WSA_CLIENT + WSA->WSA_LOJA))
    CoNout("<< ECLOJM08 >> - CLIENTE NAO LOCALIZADO PARA O ORCAMENTO " + _cNumOrc + " .")
    RestArea(_aArea)
    Return .T.
EndIf

//---------------+
// Rastreio DLOG |
//---------------+
CoNout("<< ECLOJM08 >> - BUSCANDO LINK DE RASTREIO")
If Empty(WSA->WSA_SERPOS)
    EcLojM08A(WSA->WSA_NUMECO,@_cTracking)
//-------------------+
// Rastreio correios | 
//-------------------+
Else 
    _cTracking := "https://www.linkcorreios.com.br/?id=" + RTrim(WSA->WSA_TRACKI)
EndIf 

//--------------------+
// Cria HTML de envio | 
//--------------------+
CoNout("<< ECLOJM08 >> - CRIANDO ARQUIVO HTML")
_cNome          := RTrim(Capital(WSA->WSA_NOMDES))
_cNumEco        := RTrim(WSA->WSA_NUMECO)
_cEnd           := RTrim(Capital(WSA->WSA_ENDENT))
_cBairro        := RTrim(Capital(WSA->WSA_BAIRRE))
_cMunicipio     := RTrim(Capital(WSA->WSA_MUNE))
_cEstado        := WSA->WSA_ESTE
_cCep           := Transform(WSA->WSA_CEPE,PesqPict("SA1","A1_CEP"))
_cComplemento   := RTrim(Capital(WSA->WSA_COMPLE))
_cReferencia    := RTrim(Capital(WSA->WSA_REFEN))
_cEmail         := RTrim(Lower(SA1->A1_XMAILEC))
EcLojM08B(_cNumEco,_cNome,_cEnd,_cBairro,_cMunicipio,_cEstado,_cCep,_cComplemento,_cReferencia,_cTracking,@_cBody)

//---------------------------+
// Envia e-mail para cliente |
//---------------------------+
CoNout("<< ECLOJM08 >> - ENVIANDO HTML POR E-MAIL")
EcLojM08C(_cEmail,_cBody)

RestArea(_aArea)
Return Nil 

/*******************************************************************************************************/
/*/{Protheus.doc} EcLojM08A
    @description Consulta link de rastreio 
    @type  Static Function
    @author Bernard M. Margarido 
    @since 20/08/2021
/*/
/*******************************************************************************************************/
Static Function EcLojM08A(_cNumEco,_cTracking)
Local _cQuery   := ""
Local _cAlias   := ""

Local _oJSon    := Nil 

_cTracking      := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	ZZC_NUMECO, " + CRLF
_cQuery += "	CAST(CAST(ZZC_JSON AS BINARY(1024)) AS VARCHAR(1024)) JSON_ZZC " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("ZZC") + " " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZC_FILIAL = '" + xFilial("ZZC") + "' AND " + CRLF
_cQuery += "	ZZC_NUMECO = '" + _cNumEco + "' AND " + CRLF
_cQuery += "	D_E_L_E_T_ = '' " + CRLF

_cAlias := MPSysOpenQuery(_cQuery)

If !Empty((_cAlias)->JSON_ZZC)
    _oJSon      := xFromJson((_cAlias)->JSON_ZZC)
    _cTracking  := RTrim(_oJSon[#"linkRastreamento"])
    FreeObj(_oJSon)
EndIf 

Return Nil 

/*******************************************************************************************************/
/*/{Protheus.doc} EcLojM08B
    @description Monta HTML envio de mail 
    @type  Static Function
    @author Bernard M. Margarido
    @since 20/08/2021
/*/
/*******************************************************************************************************/
Static Function EcLojM08B(_cNumEco,_cNome,_cEnd,_cBairro,_cMunicipio,_cEstado,_cCep,_cComplemento,_cReferencia,_cTracking,_cBody)
Local _cHtml    := ""
Local _cLastName:= SubStr(_cNome,1,At(" ",_cNome))

_cHtml := '<!DOCTYPE html>'
_cHtml += '<html>'
_cHtml += ' <head>'
_cHtml += '	    <meta charset="utf-8">'
_cHtml += '	    <title>Invoice</title>'
_cHtml += ' </head>'
_cHtml += ' <body>'
_cHtml += ' 	<table align="center" width="600">'
_cHtml += ' 		<tbody>'
_cHtml += '			    <tr style="box-sizing: border-box !important;">'
_cHtml += ' 				<td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; border-bottom-style: solid; border-bottom-width: 1px; border-color: #eee; width: 100%; padding-bottom: 2rem; text-align: center !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="center">' 
_cHtml += ' 					<div style="box-sizing: border-box; width: 8rem; margin-bottom: 1rem; margin-top: 2rem; margin-right: auto; margin-left: auto !important;">' 
_cHtml += ' 						<a href="http://www.danacosmeticos.com.br" style="box-sizing: border-box !important;"> <img alt="" border="0" width="auto" src="http://licensemanager.vtex.com.br/api/site/pub/accounts/36ccb150-3191-4124-a08a-606cb3f3133f/logos/show" style="vertical-align: top; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; max-width: 100%; border: none; max-height: 80px !important;"> </a>' 
_cHtml += ' 					</div>'   
_cHtml += ' 					<h1 style="margin: 0; font-size: 50px; line-height: 58px; box-sizing: border-box !important;" align="center">Sua entrega foi iniciada.</h1>'  
_cHtml += ' 					<div style="box-sizing: border-box; color: #777; margin-top: .5rem !important;" align="center"> Referente ao Pedido <span style="font-weight: 700 !important;">#'+ _cNumEco +'</span></div>'  
_cHtml += '				    </td>' 
_cHtml += '			    </tr>' 
_cHtml += '			    <tr style="box-sizing: border-box !important;">' 
_cHtml += '				    <td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; text-align: left; width: 100% !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="left">'   
_cHtml += '				    	<p style="box-sizing: border-box; margin-top: 2rem !important;" align="center"> Olá, ' + _cLastName + '. Seu produto acabou de ser entregue à transportadora.</p>'    
_cHtml += '			    	</td>' 
_cHtml += '			    </tr>' 
_cHtml += '			    <tr style="box-sizing: border-box !important;" >' 
_cHtml += '			    	<td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; text-align: left; width: 100%; padding-top: 1rem; padding-bottom: 1rem !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="left">'   
_cHtml += '			    		<div style="box-sizing: border-box; clear: both; float: none !important;" align="center">' 
_cHtml += '			    			<h3 style="font-size: 20px; line-height: 36px; text-transform: capitalize; letter-spacing: 1.2pt; font-weight: 300; margin-top: 16px; box-sizing: border-box; margin: 0; margin-bottom: .5rem !important;"> Endereço</h3>'   
_cHtml += '			    			<div style="box-sizing: border-box; max-width: 24rem; background-color: #eee; padding: 1rem; margin-bottom: 1rem !important;" >'    
_cHtml += '				    			<strong >'+ _cNome +'</strong><br>'
_cHtml += '				    			' + _cEnd + IIF(Empty(_cComplemento),'', + ' - ' +_cComplemento) + '<br>'
_cHtml += '				    			' + _cBairro + ' - ' + _cMunicipio + ' - ' + _cEstado + '<br>'
_cHtml += '				    			CEP ' + _cCep + ' '   
_cHtml += '					    	</div>'    
_cHtml += '					    </div>'   
_cHtml += '				    </td>' 
_cHtml += '			    </tr>'  
_cHtml += '		    </tbody>'
_cHtml += '		    <tbody>'
_cHtml += '			    <tr style="box-sizing: border-box !important;" align="center">' 
_cHtml += '			    	<td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; text-align: center; border-top-style: solid; border-top-width: 1px; border-color: #eee; padding-top: 1rem; padding-bottom: 1rem !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="center">'   
_cHtml += '			    		<div style="box-sizing: border-box; clear: both; float: none !important;" align="center">' 
_cHtml += '			    			<h1 style="font-size: 13px; line-height: 36px; text-transform: none; letter-spacing: 1.2pt; font-weight: 300; margin-top: 10px; box-sizing: border-box; margin: 0; margin-bottom: .5rem !important;"> Clique no botão abaixo para rastrear sua encomenda.</h1>'
_cHtml += '			    		</div>'   
_cHtml += '			    	</td>'
_cHtml += '			    </tr>' 
_cHtml += '			    <tr style="box-sizing: border-box !important;">'
_cHtml += '			    	<td style="border-radius: 50px; max-width: 5rem; background-color: #000; padding: 1rem; margin-bottom:0rem !important;" align="center" height="10px" width="10px">' 
_cHtml += '			    			<a href="'+ _cTracking +'" style="text-decoration:none; font-family:Arial, Helvetica, sans-serif; font-size: 18px; color:#fff; font-weight:bold;">Rastrear</a>'
_cHtml += '			    	</td>'
_cHtml += '			    </tr>'
_cHtml += '			    <tr style="box-sizing: border-box !important;" align="center">'
_cHtml += '			       	<td style="box-sizing: border-box; clear: both; float: none !important;" align="center">'
_cHtml += '				    	<h1 style="font-size: 12px; line-height: 36px; text-transform: none; letter-spacing: 1.2pt; font-weight: 300; margin-top: 16px; box-sizing: border-box; margin: 0; margin-bottom: .5rem !important;">' + _cTracking + '</h1>'
_cHtml += '			    	</td>'
_cHtml += '			    </tr>'
_cHtml += ' 		</tbody>'
_cHtml += ' 		<tbody>'
_cHtml += ' 			<tr>'
_cHtml += '                 <td style=" font-size:11px; color:#636363; font-family:Arial, Helvetica, sans-serif; text-align:center">'
_cHtml += '                     <p><strong>Dana Cosméticos</strong> <br></p>'
_cHtml += '                     <p style="font-size:13px"><a href="https://danacosmeticos.com.br/" target="_blank">danacosmeticos.com.br</a></p>'
_cHtml += '                 </td>'
_cHtml += '             </tr>'
_cHtml += ' 		</tbody>'
_cHtml += '     </table>'
_cHtml += ' </body>'
_cHtml += '</html>'

_cBody := _cHtml

Return Nil 

/*****************************************************************************************************/
/*/{Protheus.doc} EcLojM08C
    @description Realiza a envio de e-mail para cliente
    @type  Static Function
    @author Bernard M. Margarido
    @since 20/08/2021
/*/
/*****************************************************************************************************/
Static Function EcLojM08C(_cEmail,_cBody)
Local _cServer	:= GetMv("MV_RELSERV")
Local _cUser	:= GetMv("MV_RELAUSR")
Local _cPassword:= GetMv("MV_RELAPSW")
Local _cFrom	:= GetMv("MV_RELACNT")
Local _cTitulo  := "Rastreio Dana Cosméticos"
Local _xRet     := ""

Local _nPort	:= 0
Local _nPosTmp	:= 0

Local _lEnviado	:= .F.
Local _lRelauth := SuperGetMv("MV_RELAUTH",, .F.)

Local _oServer	:= Nil
Local _oMessage	:= Nil

_oServer := TMailManager():New()
_oServer:SetUseTLS(.T.)

If ( _nPosTmp := At(":",_cServer) ) > 0
    _nPort := Val(SubStr(_cServer,_nPosTmp+1,Len(_cServer)))
    _cServer := SubStr(_cServer,1,_nPosTmp-1)
EndIf

If  ( _xRet := _oServer:Init( "", _cServer, _cUser, _cPassword,,_nPort) ) == 0
    If ( _xRet := _oServer:SMTPConnect()) == 0
        If _lRelauth
            If ( _xRet := _oServer:SMTPAuth( _cUser, _cPassword ))  <> 0
                _xRet := _oServer:SMTPAuth( SubStr(_cUser,1,At("@",_cUser)-1), _cPassword )
            EndIf
        Endif

        If _xRet == 0
            
            _oMessage := TMailMessage():New()
            _oMessage:Clear()
            
            _oMessage:cDate  	:= cValToChar( Date() )
            _oMessage:cFrom  	:= _cFrom
            _oMessage:cTo   	:= _cEmail
            _oMessage:cBCC   	:= "bernard.margarido@vitreoerp.com.br"
            _oMessage:cSubject 	:= _cTitulo
            _oMessage:cBody   	:= _cBody
            If (_xRet := _oMessage:Send( _oServer )) <> 0
                Conout("<< ECLOJM08 >> - Erro ao enviar e-mail --> " + _oServer:GetErrorString( _xRet ))	
                _lEnviado := .F.
            Endif
        Else
            Conout("<< ECLOJM08 >> - Erro ao enviar e-mail --> " + _oServer:GetErrorString( _xRet ))	
            _lEnviado := .F.
        EndIf
    EndIf
Else
    Conout("<< ECLOJM08 >> - Erro ao Conectar ! ")
EndIf

Return Nil