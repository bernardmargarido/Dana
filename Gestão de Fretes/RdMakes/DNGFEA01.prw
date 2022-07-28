#INCLUDE "TOTVS.CH"

/***************************************************************************************************/
/*/{Protheus.doc} DNGFEA01
    @description Valida se cliente contem a opção de envio de e-mail para agendamento
    @type  Function
    @author Bernard M Margarido
    @since 18/07/2022
    @version version
/*/
/***************************************************************************************************/
User Function DNGFEA01(_cRomaneio)
Local _aAgenda  := {}

Local _nTDoc    := TamSx3("F2_DOC")[1]
Local _nTSer    := TamSx3("F2_SERIE")[1]

//---------------------------+
// GW1 - Documentos de Carga |
//---------------------------+
dbSelectArea("GW1")
GW1->( dbSetOrder(9))
If !GW1->( dbSeek(xFilial("GW1") + _cRomaneio) )
    Return .F.
EndIf 

//----------------------+
// SF2 - Notas de Saida |
//----------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

//----------------+
// SA1 - Clientes |
//----------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )

While GW1->( !Eof() .And. xFilial("GW1") + _cRomaneio == GW1->GW1_FILIAL + GW1->GW1_NRROM )
    //-----------------------------+
    // SF2 - Posiciona Nota fiscal |
    //-----------------------------+
    If SF2->( dbSeek(xFilial("SF2") + PadR(GW1->GW1_NRDC,_nTDoc) + PadR(GW1->GW1_SERDC,_nTSer)))
        SA1->( dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA) )
        //If SA1->A1_XAGENDA == "1"
            aAdd(_aAgenda, {    SF2->F2_DOC     ,;
                                SF2->F2_SERIE   ,;
                                SF2->F2_CLIENTE ,;
                                SF2->F2_LOJA    ,;
                                /*SA1->A1_XMAILAG*/"bernard.margarido@vitreoerp.com.br" ,;
                                IIF(Empty(GW1->GW1_DTSAI),Date(),GW1->GW1_DTSAI)        ,;
                                IIF(Empty(GW1->GW1_HRSAI),Left(Time(),5),GW1->GW1_HRSAI)})
        //EndIf 
    EndIf 
    GW1->( dbSkip() )
EndDo

//-----------------------------+
// Valida se envia agendamento |
//-----------------------------+
If Len(_aAgenda) > 0 
    DNGFEA01A(_aAgenda)
EndIf 

Return Nil 

/***************************************************************************************************/
/*/{Protheus.doc} DNGFEA01A
    @description Cria e envia pagina de link de agendamento
    @type  Static Function
    @author Bernard M Margarido
    @since 18/07/2022
    @version version
/*/
/***************************************************************************************************/
Static Function DnGfeA01A(_aAgenda)
Local _nX           := 0 

Local _cBody        := ""
Local _cIdProcess   := ""
Local _cFileWF      := "\workflow\emp" + cEmpAnt + "\wfagenda\"

For _nX := 1 To Len(_aAgenda)

    //-----------------------------------------------+
    // Cria e salva na pasta WorkFlow de Agendamento |
    //-----------------------------------------------+
    DNGFEA01B(_aAgenda[_nX][1],_aAgenda[_nX][2],_aAgenda[_nX][3],_aAgenda[_nX][4],_aAgenda[_nX][6],_cFileWF,@_cIdProcess)

    //----------------------------------+
    // Cria e envia link de agendamento |
    //----------------------------------+
    DNGFEA01C(_aAgenda[_nX][1],_aAgenda[_nX][2],_aAgenda[_nX][3],_aAgenda[_nX][4],_cFileWF,_cIdProcess,@_cBody)

    //----------------------------------+
    // Cria e envia link de agendamento |
    //----------------------------------+
    DNGFEA01D(_aAgenda[_nX][5],_cBody)

Next _nX 

Return Nil 

/***************************************************************************************************/
/*/{Protheus.doc} DNGFEA01B
    @description Cria workflow de agendamento
    @type  Static Function
    @author Bernard M Margarido
    @since 18/07/2022
    @version version
/*/
/***************************************************************************************************/
Static Function DNGFEA01B(_cDoc,_cSerie,_cCliente,_cLoja,_dDTSaida,_cFileWF,_cIdProcess)
Local _oProcess     := Nil 
Local _oHtml        := Nil 

Local _cAssunto     := "Dana - Agendamento Recebimento"
Local _cArqHTM	    := "\workflow\danaagenda.htm"

//----------------------+
// SF2 - Notas de Saida |
//----------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cDoc + _cSerie) )
    Return .F. 
EndIf 

//---------------------------+
// SD2 - Itens Nota de Saida |
//---------------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )
If !SD2->( dbSeek(xFilial("SD2") + _cDoc + _cSerie) )
    Return .F. 
EndIf 

//----------------+
// SA1 - Clientes |
//----------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
SA1->(dbSeek(xFilial("SA1") + _cCliente + _cLoja) )

//----------------+
// SB1 - Produtos |
//----------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )


_oProcess := TWFProcess():New( "MAILMKT", _cAssunto )
_oProcess:NewTask( "Mail Markteing", _cArqHTM )
_oProcess:cSubject := _cAssunto

_oHtml := _oProcess:oHtml

_oHtml:ValbyName("nota"    	, RTrim(SF2->F2_DOC) )
_oHtml:ValbyName("serie"    , RTrim(SF2->F2_SERIE) )
_oHtml:ValbyName("emissao"  , dToC(SF2->F2_EMISSAO) )
_oHtml:ValbyName("chave"    , RTrim(SF2->F2_CHVNFE) )

While SD2->( !Eof() .And. xFilial("SD2") + _cDoc + _cSerie == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE )

    SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD) )

    aAdd( _oHtml:ValByName( "it.item" )	        , RTrim(SD2->D2_ITEM) )
    aAdd( _oHtml:ValByName( "it.produto" )	    , RTrim(SD2->D2_COD) )
    aAdd( _oHtml:ValByName( "it.descricao" )	, RTrim(SB1->B1_DESC) )
    aAdd( _oHtml:ValByName( "it.unidade" )	    , RTrim(SD2->D2_UM) )
    aAdd( _oHtml:ValByName( "it.quantidade" )	, Transform(SD2->D2_QUANT,PesqPict("SD2","D2_QUANT")) )
    aAdd( _oHtml:ValByName( "it.vlrunit" )	    , Transform(SD2->D2_PRCVEN,PesqPict("SD2","D2_PRCVEN")) )
    aAdd( _oHtml:ValByName( "it.total" )	    , Transform(SD2->D2_TOTAL,PesqPict("SD2","D2_TOTAL")) )

    SD2->( dbSkip() )
EndDo 

_oHtml:ValbyName("dt_min", SubStr(FwTimeStamp(3,DaySum(_dDTSaida,1)),1,10)  )
_oHtml:ValbyName("dt_max", SubStr(FwTimeStamp(3,DaySum(_dDTSaida,11)),1,10) )

_oProcess:cTo 			:= Nil
_oProcess:bReturn		:= "U_DNGFEA02()"
_oProcess:bTimeOut 		:= {{"U_DNGFEA03()", 0, 24, 0}}
_oProcess:nEncodeMime 	:= 0
_cIdProcess 			:= _oProcess:Start(_cFileWF)

Return Nil 

/***************************************************************************************************/
/*/{Protheus.doc} DNGFEA01C
    @description Realiza o envio do link de pagamento 
    @type  Static Function
    @author Bernard M Margarido
    @since 19/07/2022
    @version version
/*/
/***************************************************************************************************/
Static Function DNGFEA01C(_cDoc,_cSerie,_cCliente,_cLoja,_cFileWF,_cIdProcess,_cBody)
Local _cUrlWF   := "http://perfumesdana134461.protheus.cloudtotvs.com.br:1322/emp" + cEmpAnt + "/wfagenda/" + RTrim(_cIdProcess) + ".htm"
Local _cHtml    := ''
Local _cPedido  := ""
Local _cRazao   := ""
//----------------------+
// SF2 - Notas de Saida |
//----------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cDoc + _cSerie) )
    Return .F. 
EndIf 

//---------------------------+
// SD2 - Itens Nota de Saida |
//---------------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )
If !SD2->( dbSeek(xFilial("SD2") + _cDoc + _cSerie) )
    Return .F. 
EndIf 
_cPedido := SD2->D2_PEDIDO 

//----------------+
// SA1 - Clientes |
//----------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
SA1->(dbSeek(xFilial("SA1") + _cCliente + _cLoja) )
_cRazao := SA1->A1_NOME

_cHtml := '<!DOCTYPE html>'
_cHtml += '<html>'
_cHtml += '<head>'
_cHtml += '	<meta charset="utf-8">'
_cHtml += '	<title>Dana Cosméticos - Link de Agendamento</title>'
_cHtml += '	<!-- Bootstrap CSS -->'
_cHtml += '	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">'
_cHtml += '</head>'
_cHtml += '<body>'
_cHtml += '	<table align="center" width="600">'
_cHtml += '		<tbody>'
_cHtml += '			<tr style="box-sizing: border-box !important;">'
_cHtml += '				<td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; border-bottom-style: solid; border-bottom-width: 1px; border-color: #eee; width: 100%; padding-bottom: 2rem; text-align: center !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="center">'
_cHtml += '					<div style="box-sizing: border-box; width: 8rem; margin-bottom: 1rem; margin-top: 2rem; margin-right: auto; margin-left: auto !important;">'
_cHtml += '						<a href="http://www.danacosmeticos.com.br" style="box-sizing: border-box !important;"> <img alt="" border="0" width="auto" src="http://licensemanager.vtex.com.br/api/site/pub/accounts/36ccb150-3191-4124-a08a-606cb3f3133f/logos/show" style="vertical-align: top; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; max-width: 100%; border: none; max-height: 80px !important;"> </a>'
_cHtml += '					</div>'
_cHtml += '					<h1 style="margin: 0; font-size: 50px; line-height: 58px; box-sizing: border-box !important;" align="center">Agendamento de recebimento.</h1>'
_cHtml += '				</td>' 
_cHtml += '			</tr>'
_cHtml += '			<tr style="box-sizing: border-box !important;">'
_cHtml += '				<td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; text-align: left; width: 100% !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="left">'
_cHtml += '					<p style="box-sizing: border-box; margin-top: 2rem !important;" align="center"> Olá,  ' + RTrim(_cRazao) + '. Seu pedido ' + RTrim(_cPedido) + ', faturado sobre a nota ' + _cDoc + ' - ' + _cSerie + ' está em processo de separação em nosso Centro de Distribuição. Caso deseja agendar o recebebimento da sua mercadoria clique no botão "Agendar".</p>'
_cHtml += '				</td>'
_cHtml += '			</tr>' 
_cHtml += '		</tbody>'
_cHtml += '		<tbody>'
_cHtml += '			<tr style="box-sizing: border-box !important;">'
_cHtml += '				<td style="border-radius: 50px; max-width: 5rem; background-color: #000; padding: 1rem; margin-bottom:0rem !important;" align="center" height="10px" width="10px" colspan="2">'
_cHtml += '					<a href="'+ _cUrlWF +'" style="text-decoration:none; font-family:Arial, Helvetica, sans-serif; font-size: 18px; color:#fff; font-weight:bold;">Agendar</a>'
_cHtml += '				</td>'
_cHtml += '			</tr>'
_cHtml += '		</tr>'
_cHtml += '	</tbody>'
_cHtml += '	<tbody>'
_cHtml += '		<tr>'
_cHtml += '			<td style=" font-size:11px; color:#636363; font-family:Arial, Helvetica, sans-serif; text-align:center">'
_cHtml += '				<p><strong>Dana Cosméticos</strong> <br></p>'
_cHtml += '				<p style="font-size:13px"><a href="https://danacosmeticos.com.br/" target="_blank">danacosmeticos.com.br</a></p>'
_cHtml += '			</td>'
_cHtml += '		</tr>'
_cHtml += '	</tbody>'
_cHtml += '</table>'
_cHtml += '</body>'
_cHtml += '<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>'
_cHtml += '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>'
_cHtml += '<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>'
_cHtml += '</html>'
_cBody := _cHtml

Return Nil 

/***************************************************************************************************/
/*/{Protheus.doc} DNGFEA01D
    @description Realiza envio de e-mail 
    @type  Static Function
    @author Bernard M Margarido
    @since 19/07/2022
    @version version
/*/
/***************************************************************************************************/
Static Function DNGFEA01D(_cEMail,_cBody)
Local _cServer	:= GetMv("MV_RELSERV")
Local _cUser	:= GetMv("MV_RELAUSR")
Local _cPassword:= GetMv("MV_RELAPSW")
Local _cFrom	:= GetMv("MV_RELACNT")
Local _cTitulo  := "Dana - Agendamento"
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
                Conout("<< DNGFEA01 >> - Erro ao enviar e-mail --> " + _oServer:GetErrorString( _xRet ))	
                _lEnviado := .F.
            Endif
        Else
            Conout("<< DNGFEA01 >> - Erro ao enviar e-mail --> " + _oServer:GetErrorString( _xRet ))	
            _lEnviado := .F.
        EndIf
    EndIf
Else
    Conout("<< DNGFEA01 >> - Erro ao Conectar ! ")
EndIf

Return Nil 
