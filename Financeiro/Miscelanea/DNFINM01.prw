#INCLUDE "TOTVS.CH"

#DEFINE TITULO  01 
#DEFINE PREFIXO 02 
#DEFINE PARCELA 03 
#DEFINE VALOR   04 
#DEFINE EMISSAO 05 
#DEFINE BAIXA   07 

#DEFINE CRLF CHR(13) + CHR(10)

/**********************************************************************************************/
/*/{Protheus.doc} DNFINM01
    @description Realiza o cancelamento da baixa dos titulos financeiros 
    @type  Function
    @author Bernard M Margarido
    @since 26/12/2022
    @version version
/*/
/**********************************************************************************************/
User Function DNFINM01()
Local _cTpArq 	    := "(*.CSV)|*.CSV|"
Local _cArquivo	    := ""
Local _cDir		    := ""

Private _cDirImp 	:= "\IMPORT\"
Private _cImpPro 	:= "\IMPORT\PROCESSADOS\"
Private _cPathImp	:= ""

Private _aArqNome   := {}

Private _aError     := {}
//---------------------------------------+
// Abre a janela para selecao do arquivo |
//---------------------------------------+
_cTitulo	:= "Selecione o arquivo que será importado"
_nOpcF	    := GETF_LOCALHARD + GETF_NETWORKDRIVE
_cDir		:= cGetFile(_cTpArq,_cTitulo,0,,.T.,_nOpcF) //cGetFile(cTipoArq,cTitulo,0)
_cArquivo	:= SubStr(_cDir,RAT("\",_cDir) + 1,Len(_cDir))
_cPathImp	:= SubStr(_cDir,1,RAT("\",_cDir))
_aArqNome   := Separa(_cArquivo,"-")

If !Empty(_cArquivo)
	//---------------------------------+
	// Inicia a importacao do arquivo. |
	//---------------------------------+
	If MsgNoYes("Confirma Importacao do Arquivo "  + _cArquivo + "?")
		Processa({|_lEnd| DNFINM01A(_cPathImp,_cArquivo,@_lEnd) },"Lendo Arquivo Texto...",,.T.)
        If Len(_aError) > 0 
            DNFINM01D(_aError)
        EndIf 

	EndIf
EndIf	

Return Nil 

/**********************************************************************************************/
/*/{Protheus.doc} DNFINM01A
    @description Realiza a leitura do arquivo e cancelamento dos titulos
    @type  Static Function
    @author Bernard M Margarido
    @since 26/12/2022
    @version version
/*/
/**********************************************************************************************/
Static Function DNFINM01A(_cPathImp,_cArquivo,_lEnd) 
Local _nHdl 	    := FT_FUse(_cPathImp + _cArquivo)
Local _cLog      	:= ""
Local _cArqLog 		:= ""

Private _dDtaIni	:= dDataBase
Private _cHoraIni	:= Time()

Private _nErros		:= 0
Private _cAlias     := ""

//---------------------------------------+
// Efetua a leitura do arquivo de texto. |
//---------------------------------------+
DNFINM01B(_nHdl, _cArquivo, @_lEnd)

//----------------------+
// Fecha arquivo texto. |
//----------------------+
FT_FUSE()

//----------------------------------------------+
// Cria diretorio para arquivos ja processados. |
//----------------------------------------------+
If !EXISTDIR(_cImpPro)
    makeDir(_cImpPro)
EndIf

//------------------------------------------------+
// Remove arquivo de texto para pasta processados.|
//------------------------------------------------+
_cSource := AllTrim(_cDirImp + _cArquivo)
_cTarget := AllTrim(_cImpPro + SubStr(_cArquivo,1,Len(_cArquivo)-4) + "_" + DToS(Date()) + "_" + StrTran(Time(),":")+".CSV")
Copy File &_cSource to &_cTarget
Delete File &(_cSource)

//------------------------------------+
// Grava Log de Importacao dos Dados. |
//------------------------------------+
_cLog := "Arquivo........: " + _cArquivo + CRLF
_cLog += "Path...........: " + _cDirImp + CRLF
_cLog += "Data Inicial...: " + DToC(_dDtaIni) + CRLF
_cLog += "Hora Inicial...: " + _cHoraIni + CRLF
_cLog += "Data Final.....: " + DToC(Date()) + CRLF
_cLog += "Hora Final.....: " + Time() + CRLF
_cLog += "Inconformidades: " + cValToChar(_nErros)

_cArqLog := "LOGIMP_" + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2) + ".LOG"
MemoWrite(_cDirImp + _cArqLog, _cLog)
fRenameEX(_cDirImp + _cArqLog, strTran( UPPER(_cDirImp + _cArquivo) ,".CSV","_OK.CSV") )
Return Nil 

/***********************************************************************************************/
/*/{Protheus.doc} DNFINM01B
    @description Realiza a leitura do arquivo csv
    @type  Static Function
    @author Bernard M. Margarido
    @since 19/02/2021
/*/
/***********************************************************************************************/
Static Function DNFINM01B(_nHdl, _cArquivo, _lEnd)
Local _cLinha  	    := ""

Local _aDados       := {}
Local _aFatura      := {}

Local _nBytes  	    := 0
Local _nPos    	    := 1
Local _nLinhas 	    := 0
Local _nPorcAtu	    := 0
Local _nPorcNext	:= 0
Local _nX           := 0
Local _nTTitulo     := TamSx3("E1_NUM")[1]
Local _nTPrefix     := TamSx3("E1_PREFIXO")[1]
Local _nTParcela    := TamSx3("E1_PARCELA")[1]    

Default _lEnd   	:= .F.


//----------------------------------+
// SE1 - Posiciona Contas a Receber |
//----------------------------------+
dbSelectArea("SE1")
SE1->( dbSetOrder(1) )

//---------------------------------------+
// SE5 - Posiciona Movimentacao Bancaria |
//---------------------------------------+
dbSelectArea("SE5")
SE5->( dbSetOrder(7) )

//-------------------------------------+
// XTA - Posiciona conciliação Pagarme |
//-------------------------------------+
dbSelectArea("XTA")
XTA->( dbSetOrder(1) )

//--------------------------------+
// Determina o tamanho do arquivo |
//--------------------------------+
_nBytes := FT_FLastRec()

//--------------------------------+
// Posiciona no início do arquivo |
//--------------------------------+
FT_FGoTop()

//-------------------------------+
// Inicia regra de processamento | 
//-------------------------------+
ProcRegua(_nBytes)

//-------------------+
// Arquivo não vazio |
//-------------------+
If _nBytes > 0
    While !FT_FEOF()

        _nLinhas:= _nLinhas + 1
        _cLinha := FT_FReadLn()
        
        If _lEnd	
            Alert("Operação cancelada pelo usuário!")
            Exit
        EndIf                

        //--------------------------+
        // Primeira linha cabeçalho |
        //--------------------------+
        If _nLinhas > 1
            _aDados := Separa(_cLinha,";")

            If !Empty(_aDados[TITULO]) //.Or. At("/",_aDados[PAY]) == 0 
                _cTitulo        := PadR(_aDados[TITULO],_nTTitulo)
                _cPrefixo       := PadR(_aDados[PREFIXO],_nTPrefix)
                _cParcela       := PadR(_aDados[PARCELA],_nTParcela)
                _dDtEmiss       := _aDados[EMISSAO]
                _dDtBaixa       := _aDados[BAIXA]
                _nValor         := Val(_aDados[VALOR])

                //-----------------------+
                // Posiciona Nota Fiscal | 
                //-----------------------+
                If SE1->( dbSeek(xFilial("SE1") + _cPrefixo + _cTitulo + _cParcela)) 
                    If !Empty(SE1->E1_BAIXA) .And. SE1->E1_SALDO == 0

                        aAdd(_aFatura,{SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_PARCELA, SE1->( Recno() )})
                        RecLock("SE1",.F.)
                            SE1->E1_TIPOLIQ := ""
                        SE1->( MsUnLock() )

                        If SE5->( dbSeek(xFilial("SE5") + _cPrefixo + _cTitulo + _cParcela)) 
                            RecLock("SE5",.F.)
                                SE5->E5_MOTBX   := ""
                                SE5->E5_DOCUMEN := ""
                            SE5->( MsUnLock() )
                        EndIf 

                        If XTA->(dbSeek(xFilial("XTA") + SE1->E1_XTID + SE1->E1_PARCELA) )
                            RecLock("XTA",.F.)
                                XTA->XTA_STATUS := "1"
                            XTA->( MsUnLock() )
                        EndIf 
                    EndIf 
                EndIf
            EndIf
        EndIf        
    
        _nPorcNext := NoRound((_nPos/_nBytes)*100,2)
        If _nPorcNext > _nPorcAtu
            _nPorcAtu := _nPorcNext
            IncProc("Lendo Arquivo: " + _cArquivo + " - " + cValToChar(_nPorcAtu) + "%")
            Conout("Lendo Arquivo: " + _cArquivo + " - " + cValToChar(_nPorcAtu) + "%")
        EndIf
        FT_FSKIP()
        _nPos++
    EndDo
EndIf

If Len(_aFatura) > 0 
    ProcRegua(Len(_aFatura))
    For _nX := 1 To Len(_aFatura)
        IncProc("Estornando titulos " + _aFatura[_nX][1] )
        DNFINM01C(_aFatura[_nX][4])
    Next _nX 
EndIf

Return Nil

/***********************************************************************************************/
/*/{Protheus.doc} DNFINM01C
    @description Estorna contas a receber 
    @type  Static Function
    @author Bernard M Margarido
    @since 26/12/2022
    @version version
/*/
/***********************************************************************************************/
Static Function DNFINM01C(_nRecnoSE1)
Local _aArea            := GetArea()
Local _aTitulo          := {}

Local _cError           := ""

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

dbSelectArea("SE1")
SE1->( dbGoTo(_nRecnoSE1) )

aAdd(_aTitulo , {"E1_PREFIXO"	,SE1->E1_PREFIXO	,NIL})
aAdd(_aTitulo , {"E1_NUM"		,SE1->E1_NUM		,NIL})
aAdd(_aTitulo , {"E1_PARCELA"	,SE1->E1_PARCELA	,NIL})
aAdd(_aTitulo , {"E1_TIPO"  	,SE1->E1_TIPO		,NIL})
aAdd(_aTitulo , {"E1_CLIENTE"	,SE1->E1_CLIENTE	,NIL})
aAdd(_aTitulo , {"E1_LOJA"  	,SE1->E1_LOJA		,NIL})

lMsErroAuto := .F.
	
MSExecAuto({|x,y| FINA070(x,y)}, _aTitulo, 6)

If lMsErroAuto

    _cError := ""
    AEval(GetAutoGRLog(), {|x| _cError += x + CRLF})

    aAdd(_aError,{SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_PARCELA, _cError})

EndIf 

RestArea(_aArea)
Return Nil 

/***********************************************************************************************/
/*/{Protheus.doc} DNFINM01D
    @description Envia e-mail com os erros 
    @type  Static Function
    @author Bernard M Margarido
    @since 26/12/2022
    @version version
/*/
/***********************************************************************************************/
Static Function DNFINM01D(_aError)
Local cServer	:= "smtp.mailtrap.io:587"
Local cUser		:= "9809463a6165c4"
Local cPassword := "db75a00e67a596"
Local cFrom		:= "bernard.margarido@vitreoerp.com.br"

Local cMail		:= "bernard.margarido@vitreoerp.com.br"
Local cBody		:= ""	
Local cRgbCol	:= ""
Local cTitulo	:= "Dana Cosmeticos - Estorno de Baixas a Pagar"
Local cEndLogo	:= "https://danacosmeticos.vteximg.com.br/arquivos/dana-logo-002.png" 

Local nErro		:= 0
Local _nPort	:= 0
Local _nPosTmp	:= 0

Local _xRet		

Local lEnviado	:= .F.
Local lZebra	:= .T.
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)

Local _oServer	:= Nil
Local _oMessage	:= Nil

Default	_cPDF	:= ""
Default _cDirEtq:= ""
Default	_aETQ	:= {}
	
//---------------------------------------------+
// Montagem do Html que sera enciado com erros |
//---------------------------------------------+
cBody := '    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cBody += '    <html xmlns="http://www.w3.org/1999/xhtml">'
cBody += '    <head>'
cBody += '        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' 
cBody += '        <title>' + cTitulo + '</title>'
cBody += '    </head>'
cBody += '    <body>'
cBody += '        <table width="1000" height="10" border="0" bordercolor="#000000" bgcolor="#FFFFFF">'
cBody += '            <tr align="center">'
cBody += '                <td align="center" bgcolor="#0d0000">'
cBody += '                    <img src="' + Alltrim(cEndLogo)  + '" height="070" width="180" />'
cBody += '                </td>'    
cBody += '            </tr>'
cBody += '            <tr>'
cBody += '                <td width="1000" align= "center">'
cBody += '                    <font color="#999999" size="+2" face="Arial, Helvetica, sans-serif"><b>999 - Estorno Financeiro</b></font>'
cBody += '                </td>'
cBody += '            </tr>'
cBody += '		   </table>'
cBody += '         <table width="1000" border="0"  bordercolor="#000000" bgcolor="#FFFFFF">'   
cBody += '            <tr bordercolor="#FFFFFF" bgcolor="#0d0000">'
cBody += '                <td width="15%" height="30" align= "left">'
cBody += '                    <font color="#FFFFFF" size="-1" face="Arial, Helvetica, sans-serif"><b>Código</b></font><br>'
cBody += '                </td>'
cBody += '                <td width="85%" height="30" align= "left">'
cBody += '                    <font color="#FFFFFF" size="-1" face="Arial, Helvetica, sans-serif"><b>Descrição</b></font><br>'
cBody += '                </td>'
cBody += '            </tr>'

For nErro := 1 To Len(_aError)

    If lZebra
        lZebra	:= .F.
        cRgbCol := "#FFFFFF"	
    Else
        lZebra	:= .T.
        cRgbCol := "#A9A9A9"
    EndIf	

    cBody += '            <tr bordercolor="#FFFFFF" bgcolor="' + cRgbCol + '">'
    cBody += '                <td width="15%" height="30" align= "left">'
    cBody += '                    <font color="#000000" size="-1" face="Arial, Helvetica, sans-serif">' + Rtrim(_aError[nErro][1]) + '-' + Rtrim(_aError[nErro][2]) + '-' + Rtrim(_aError[nErro][3]) + '</font>'
    cBody += '                </td>'
    cBody += '                    <td width="85%" height="30" align= "left">'
    cBody += '                    <font color="#000000" size="-1" face="Arial, Helvetica, sans-serif">' + Rtrim(_aError[nErro][4]) + '</font>'
    cBody += '                </td>'
    cBody += '            </tr>'

Next nErro

cBody += '        </table>'
cBody += '        <br><br><br>'
cBody += '        <font color="#000000" size="-1" face="Arial, Helvetica, sans-serif">VitreoERP - eCommerce <font face="Times New Roman">&copy;</font> - Enviado em ' + dToc(dDataBase) + ' - ' + Time() + '</font>'
cBody += '    </body>'
cBody += '    </html>'

//-------------------------+	
// Realiza envio do e-mail | 
//-------------------------+
lEnviado := .T.	
_oServer := TMailManager():New()
_oServer:SetUseTLS(.T.)

If ( _nPosTmp := At(":",cServer) ) > 0
    _nPort := Val(SubStr(cServer,_nPosTmp+1,Len(cServer)))
    cServer := SubStr(cServer,1,_nPosTmp-1)
EndIf

If  ( _xRet := _oServer:Init( "", cServer, cUser, cPassword,,_nPort) ) == 0
    If ( _xRet := _oServer:SMTPConnect()) == 0
        If lRelauth
            If ( _xRet := _oServer:SMTPAuth( cUser, cPassword ))  <> 0
                _xRet := _oServer:SMTPAuth( SubStr(cUser,1,At("@",cUser)-1), cPassword )
            EndIf
        Endif

        If _xRet == 0
            
            _oMessage := TMailMessage():New()
            _oMessage:Clear()
            
            _oMessage:cDate  	:= cValToChar( Date() )
            _oMessage:cFrom  	:= cFrom
            _oMessage:cTo   	:= cMail
            _oMessage:cSubject 	:= cTitulo
            _oMessage:cBody   	:= cBody
            If (_xRet := _oMessage:Send( _oServer )) <> 0
                Conout("Erro ao enviar e-mail --> " + _oServer:GetErrorString( _xRet ))	
                lEnviado := .F.
            Endif
        Else
            Conout("Erro ao enviar e-mail --> " + _oServer:GetErrorString( _xRet ))	
            lEnviado := .F.
        EndIf
    EndIf
Else
    Conout("Erro ao Conectar ! ")
EndIf
Return Nil 

//fA070Can("SE1",Recno(),6,,nOpbaixa)
