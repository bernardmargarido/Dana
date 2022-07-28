#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/***************************************************************************************************/
/*/{Protheus.doc} DNGFEA02
    @description Processa retorno do processo de agendamento
    @type  Function
    @author Bernard M Margarido
    @since 19/07/2022
    @version version
/*/
/***************************************************************************************************/
User Function DNGFEA02(_oProcess)
Local _aArea    := GetArea()

Local _cFilAux  := cFilAnt
Local _cFilAgen := ""
Local _cDoc     := ""
Local _cSerie   := ""
Local _cObs     := ""
Local _dDtaAgend:= ""

Local _nTDoc    := TamSx3("F2_DOC")[1]
Local _nTSer    := TamSx3("F2_SERIE")[1]
Local _nRecno   := 0

CoNout("<< DNGFEA02 >> - INICIO PROCESSO DE RETORNO WORKFLOW DATA_HORA " + FWTimeStamp(3,Date()) )

//---------------------------+
// Localiza nota no romaneio |
//---------------------------+
_cDoc       := PadR(_oProcess:oHtml:RetByName("NOTA"),_nTDoc)
_cSerie     := PadR(_oProcess:oHtml:RetByName("SERIE"),_nTSer)
_cFilAgen   := _oProcess:oHtml:RetByName("WFFILIAL")
_cObs       := _oProcess:oHtml:RetByName("OBSERVACOES")
_dDtaAgend  := _oProcess:oHtml:RetByName("dt_agenda")

CoNout("<< DNGFEA02 >> - DOCUMENTO " + _cDoc )
CoNout("<< DNGFEA02 >> - SERIE " + _cSerie )
CoNout("<< DNGFEA02 >> - FILIAL " +  _cFilAgen)
CoNout("<< DNGFEA02 >> - OBSERVACOES " + _cObs )
CoNout("<< DNGFEA02 >> - DATA " +  _dDtaAgend )

If ValType(_cFilAgen) <> 'U' .And. cFilAnt <> _cFilAgen
    cFilAnt := _cFilAgen
EndIf 

//-----------------------------+
// Localiza documento romaneio | 
//-----------------------------+
DnGfeA02A(_cDoc,_cSerie,@_nRecno)

CoNout("<< DNGFEA02 >> - RECNO " +  cValToChar(_nRecno))

//----------------------------------------+
// GW1 - Posiciona documentos do romaneio |
//----------------------------------------+
dbSelectArea("GW1")
GW1->( dbSetOrder(1) )
GW1->( dbGoTo(_nRecno))
RecLock("GW1",.F.)
    GW1->GW1_XDTAGE := sToD(StrTran(_dDtaAgend,"-",""))
    GW1->GW1_XOBSAG := _cObs
GW1->( MsUnlock() )

//-------------------------------------+
// Envia workflow para o transportador | 
//-------------------------------------+
DnGfeA02B(_cDoc,_cSerie,_cObs,_dDtaAgend)

//-----------------+
// Restaura filial |
//-----------------+
If _cFilAux <> cFilAnt
    cFilAnt := _cFilAux
EndIf 

CoNout("<< DNGFEA02 >> - FIM PROCESSO DE RETORNO WORKFLOW DATA_HORA " + FWTimeStamp(3,Date()) )

RestArea(_aArea)
Return .T. 

/***************************************************************************************************/
/*/{Protheus.doc} DnGfeA02A
    @description Busca documento de romaneio 
    @type  Static Function
    @author Bernard M Margarido
    @since 22/07/2022
    @version version
/*/
/***************************************************************************************************/
Static Function DnGfeA02A(_cDoc,_cSerie,_nRecno)
Local _cQuery   := ""
Local _cAlias   := ""

Local _lRet     := .T.

_cQuery := " SELECT " + CRLF
_cQuery += "	R_E_C_N_O_ RECNOGW1 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("GW1") + " " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	GW1_FILIAL = '" + xFilial("GW1") + "' AND " + CRLF
_cQuery += "	GW1_NRDC = '" + _cDoc + "' AND " + CRLF
_cQuery += "	GW1_SERDC = '" + _cSerie + "' AND " + CRLF
_cQuery += "	D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    _nRecno := 0 
    _lRet   := .F.
Else 
    _nRecno := (_cAlias)->RECNOGW1
    _lRet   := .T.
EndIf 

(_cAlias)->( dbCloseArea() )

Return _lRet

/***************************************************************************************************/
/*/{Protheus.doc} DnGfeA02B
    @description Realiza o envio de e-mail para o transportador
    @type  Static Function
    @author Bernard M Margarido 
    @since 27/07/2022
    @version version
/*/
/***************************************************************************************************/
Static Function DnGfeA02B(_cDoc,_cSerie,_cObs,_dDtaAgend)
Local _aArea    := GetArea()

Local _cBody    := ""
Local _cEmail   := ""
Local _cNomeTran:= ""
Local _cNomeCli := ""
Local _cChave   := ""
Local _dDtEmiss := ""

//-----------------------------+
// SF2 - Posiciona nota fiscal |
//-----------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
If !SF2->( dbSeek(xFilial("SF2") + _cDoc + _cSerie) )
    CoNout("<< DNGFEA02 >> - NOTA " + _cDoc + " SERIE " + _cSerie + " NAO LOCALIZADA.")
    RestArea(_aArea)
    Return .F.
EndIf

//-------------------------+
// SA1 - Posiciona cliente |
//-------------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
If !SA1->( dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA) )
    CoNout("<< DNGFEA02 >> - CLIENTE " +  SF2->F2_CLIENTE + " LOJA " + SF2->F2_LOJA + " NAO LOCALIZADA.")
    RestArea(_aArea)
    Return .F.
EndIf 

//--------------------------------+
// SA4 - Posiciona transportadora |
//--------------------------------+
dbSelectArea("SA4")
SA4->( dbSetOrder(1) )
If !SA4->( dbSeek(xFilial("SA4") + SF2->F2_TRANSP) )
    CoNout("<< DNGFEA02 >> - TRANSPORTADORA " + SF2->F2_TRANSP + " NAO LOCALIZADA.")
    RestArea(_aArea)
    Return .F.
EndIf 

//------------------------------------------+
// Valida se contem e-mail para agendamento |
//------------------------------------------+
/*
If Empty(SA4->A4_XMAILAG)
    CoNout("<< DNGFEA02 >> - TRANSPORTADORA SEM E-MAIL DE AGENDAMENTO CADASTRADO.")
    RestArea(_aArea)
    Return .F.
EndIf 
*/
//----------------------------+
// Cria HTML do transportador |
//----------------------------+
_cEmail     := "bernard.margarido@gmail.com"//SA4->A4_XMAILAG
_cNomeTran  := RTrim(SA4->A4_NOME)
_cNomeCli   := RTrim(SA1->A1_NOME)
_cChave     := SF2->F2_CHVNFE
_dDtEmiss   := dToc(SF2->F2_EMISSAO)

DnGfeA02C(_cDoc,_cSerie,_cObs,_cNomeTran,_cNomeCli,_cChave,_dDtEmiss,_dDtaAgend,@_cBody)

//--------------+
// Envia e-Mail |
//--------------+
DnGfeA02D(_cEmail,_cBody)

RestArea(_aArea)
Return Nil 

/***************************************************************************************************/
/*/{Protheus.doc} DnGfeA02C
    @description Cria HTML transportador
    @type  Static Function
    @author Bernard M Margarido
    @since 27/07/2022
    @version version
/*/
/***************************************************************************************************/
Static Function DnGfeA02C(_cDoc,_cSerie,_cObs,_cNomeTran,_cNomeCli,_cChave,_dDtEmiss,_dDtaAgend,_cBody)
Local _cHtml := ''

//---------------------------+
// SD2 - Itens Nota de Saida |
//---------------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )
If !SD2->( dbSeek(xFilial("SD2") + _cDoc + _cSerie) )
    CoNout("<< DNGFEA02 >> - NAO FORAM ENCONTRADOS OS ITENS DA NOTA.")
    Return .F. 
EndIf 

//----------------+
// SB1 - Produtos |
//----------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

_cHtml := '<!DOCTYPE html>'
_cHtml += '<html>'
_cHtml += '<head>'
_cHtml += ' <meta charset="utf-8">'
_cHtml += ' <title>Dana Cosméticos - Agendamento</title>'
_cHtml += ' <!-- Bootstrap CSS -->'
_cHtml += ' <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">'
_cHtml += '</head>'
_cHtml += '<body>'
_cHtml += ' <table align="center" width="900">'
_cHtml += '     <tbody>'
_cHtml += '         <tr style="box-sizing: border-box !important;">'
_cHtml += '             <td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; border-bottom-style: solid; border-bottom-width: 1px; border-color: #eee; width: 100%; padding-bottom: 2rem; text-align: center !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="center">'
_cHtml += '                 <div style="box-sizing: border-box; width: 8rem; margin-bottom: 1rem; margin-top: 2rem; margin-right: auto; margin-left: auto !important;">'
_cHtml += '                    <a href="http://www.danacosmeticos.com.br" style="box-sizing: border-box !important;"> <img alt="" border="0" width="auto" src="http://licensemanager.vtex.com.br/api/site/pub/accounts/36ccb150-3191-4124-a08a-606cb3f3133f/logos/show" style="vertical-align: top; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; max-width: 100%; border: none; max-height: 80px !important;"> </a>' 
_cHtml += '                 </div>'
_cHtml += '                 <div class="row">'
_cHtml += '                     <div class="col">'
_cHtml += '                        <p style="box-sizing: border-box; margin-top: 2rem !important;" align="center"> Olá,  ' + Capital(_cNomeTran) + '. O cliente ' + Capital(_cNomeCli) + ' realizou o agendamento do recebimento da nota ' + _cDoc + ' - ' + _cSerie + '.</p>'
_cHtml += '                     </div>'
_cHtml += '                 </div>'  
_cHtml += '             </td>'
_cHtml += '         </tr>'
_cHtml += '         <tr style="box-sizing: border-box !important;">'
_cHtml += '             <td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; border-bottom-style: solid; border-bottom-width: 1px; border-color: #eee; width: 100%; padding-bottom: 2rem; text-align: center !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="center">'
_cHtml += '                 <div class="row">'
_cHtml += '                     <div class="col" align="left">'
_cHtml += '                         <label class="form-label">Data Agendada:</label>'
_cHtml += '                         <input type="date" class="form-control" style="min-width:10px;" aria-label="data de recebimento" aria-describedby="basic-addon1" name="dt_agenda" value="' + _dDtaAgend + '" disabled>'
_cHtml += '                     </div>'
_cHtml += '                 </div>'
_cHtml += '             </td>'
_cHtml += '         </tr>'
_cHtml += '         <tr style="box-sizing: border-box !important;">'
_cHtml += '             <td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; border-bottom-style: solid; border-bottom-width: 1px; border-color: #eee; width: 100%; padding-bottom: 2rem; text-align: center !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="center">'
_cHtml += '                 <div class="row">'
_cHtml += '                     <div class="col order-1" align="left">'
_cHtml += '                         <label class="col-form-label">Observações:</label>'
_cHtml += '                         <textarea class="form-control" aria-label="With textarea" placeholder="Escreva sua observação aqui..." name="obs_agenda" rows="6" readonly>' + _cObs + '</textarea>'
_cHtml += '                     </div>'
_cHtml += '                 </div>'
_cHtml += '             </td>'
_cHtml += '         </tr>'
_cHtml += '     </tbody>'
_cHtml += '     <tbody>'
_cHtml += '         <tr style="box-sizing: border-box !important;">'
_cHtml += '             <td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; text-align: left; width: 100% !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="left">'
_cHtml += '                 <div class="py-5 text-center">'
_cHtml += '                     <strong>Dados da Nota</strong>'
_cHtml += '                     <hr class="my-4">'
_cHtml += '                     <table class="table table-borderless">'
_cHtml += '                         <thead>'
_cHtml += '                             <tr>'
_cHtml += '                                 <th scope="col">Nota: ' + _cDoc + '</th>'
_cHtml += '                                 <th scope="col">Serie: ' + _cSerie + '</th>'
_cHtml += '                                 <th scope="col">Emissão: ' + _dDtEmiss + '</th>'
_cHtml += '                                 <th scope="col">Chave NF-e: ' + _cChave + '</th>'
_cHtml += '                             </tr>'
_cHtml += '                         </thead>'
_cHtml += '                     </table>'
_cHtml += '                     <table class="table table-hover">'
_cHtml += '                         <thead>'
_cHtml += '                             <tr>'
_cHtml += '                                 <th scope="col">Item</th>'
_cHtml += '                                 <th scope="col">Produto</th>'
_cHtml += '                                 <th scope="col">Descrição</th>'
_cHtml += '                                 <th scope="col">UM</th>'
_cHtml += '                                 <th scope="col">Qtd.</th>'
_cHtml += '                                 <th scope="col">Vlr. Unit</th>'
_cHtml += '                                 <th scope="col">Total</th>'
_cHtml += '                             </tr>'
_cHtml += '                         </thead>'
_cHtml += '                     <tbody>'

While SD2->( !Eof() .And. xFilial("SD2") + _cDoc + _cSerie == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE)

    SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD) )

    _cHtml += '                     <tr>'
    _cHtml += '                         <th scope="row">' + SD2->D2_ITEM + '</th>'
    _cHtml += '                         <td>' + RTrim(SD2->D2_COD) + '</td>'
    _cHtml += '                         <td>' + RTrim(SB1->B1_DESC) + '</td>'
    _cHtml += '                         <td>' + RTrim(SD2->D2_UM) + '</td>'
    _cHtml += '                         <td>' + Transform(SD2->D2_QUANT,PesqPict("SD2","D2_QUANT")) + '</td>'
    _cHtml += '                         <td>' + Transform(SD2->D2_PRCVEN,PesqPict("SD2","D2_PRCVEN")) + '</td>'
    _cHtml += '                         <td>' + Transform(SD2->D2_TOTAL,PesqPict("SD2","D2_TOTAL")) + '</td>'
    _cHtml += '                     </tr>'

    SD2->( dbSkip() )

EndDo 

_cHtml += '                     </div>
_cHtml += '                 </td>
_cHtml += '             </tr>
_cHtml += '         </tbody>
_cHtml += '         <tbody>
_cHtml += '         <tr style="box-sizing: border-box !important;"> 
_cHtml += '             <td style="font-size: 14px; line-height: 20px; box-sizing: border-box; border-collapse: collapse; text-align: left; width: 100% !important; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif;" align="left">
_cHtml += '                 <hr class="my-4">
_cHtml += '                 <div>
_cHtml += '                     <p style=" font-size:11px; color:#636363; font-family:Arial, Helvetica, sans-serif; text-align:center"><strong>Dana Cosméticos</strong></p>
_cHtml += '                     <p style="font-size:13px; text-align:center"><a href="https://danacosmeticos.com.br/" target="_blank">danacosmeticos.com.br</a></p>
_cHtml += '                 </div>
_cHtml += '             </td>
_cHtml += '         </tr>
_cHtml += '     </tbody>  
_cHtml += ' </table>
_cHtml += '</body>'
_cHtml += ' <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>'
_cHtml += ' <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>'
_cHtml += ' <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>'
_cHtml += '</html>'
_cBody := _cHtml

Return Nil 

/***************************************************************************************************/
/*/{Protheus.doc} DnGfeA02D
    @description Realiza o envio do e-mail ao transportador 
    @type  Static Function
    @author Bernard M Margarido
    @since 27/07/2022
    @version version
/*/
/***************************************************************************************************/
Static Function DnGfeA02D(_cEmail,_cBody)
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
            _oMessage:cBCC   	:= "bernard_tcn1@hotmail.com"
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
