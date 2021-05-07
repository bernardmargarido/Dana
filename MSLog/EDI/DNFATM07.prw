#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/MsLog"
Static _cDirUpl     := "/upload"

/***********************************************************************************************/
/*/{Protheus.doc} DNFATM07
    @description JOB - Envia dados para MSLOG
    @type  Function
    @author Bernard M. Margarido
    @since 07/05/2021
/*/
/***********************************************************************************************/
User Function DNFATM07(_cEmpInt,_cFilInt)
Local _aArea        := GetArea()

Private _lJob       := IIF(!Empty(_cEmpInt) .And. !Empty(_cFilInt), .T., .F.)

Default _cEmpInt   := "01"
Default _cFilInt   := "06"

//------------------+
// Mensagem console |
//------------------+
CoNout("<< DNFATM07 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmpInt, _cFilInt,,,'LOJ')
EndIf

//---------------------------+
// Integração arquivos MSLOG |
//---------------------------+
CoNout("<< DNFATM07 >> - INICIO UPLOAD DE ARQUIVOS MSLOG " + dTos( Date() ) + " - " + Time() )
    If _lJob
        DnFatM07A()
    Else 
        FWMsgRun(,{|_oSay| DnFatM07A(_oSay)},"Aguarde ....","Enviando arquivos para MSLOG.")
    EndIf 
CoNout("<< DNFATM07 >> - FIM UPLOAD DE ARQUIVOS MSLOG " + dTos( Date() ) + " - " + Time() )

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< ECLOJM03 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return Nil 

/*******************************************************************************************************/
/*/{Protheus.doc} DnFatM07A
    @description Envia arquivos para a MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 07/05/2021
/*/
/*******************************************************************************************************/
Static Function DnFatM07A(_oSay)
Local _aArea        := GetArea()
Local _aArquivo     := {}

Local _cArqUpd      := _cDirRaiz + _cDirUpl + "/"
Local cFTPServer    := GetNewPar("DN_MSLSERV","ftp.danalogistica.com.br")
Local cFTPUser      := GetNewPar("DN_MSLUSER","mslog")
Local cFTPPass      := GetNewPar("DN_MSLPASS","j0$5y5Qj")
Local nFTPPort      := GetNewPar("DN_MSLPORT",21)

Local _nX           := 0

Local _oFTP         := Nil 

Default _oSay       := Nil 

//------------------------------------+
// Busca arquivos na pasta para envio | 
//------------------------------------+
_aArquivo := Directory(_cArqUpd + "*.txt")

If Len(_aArquivo) == 0
    CoNout("<< DNFATM07 >> - NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
    If !_lJob
        MsgStop("Não existem arquivos para serem enviados.","Dana - Avisos")
    EndIf
    RestArea(_aArea)
    Return Nil 
EndIf 

//----------------------+
// Instancia classe FTP | 
//----------------------+
_oFTP               := FTPConnect():New()
_oFTP:cFTPServer    := cFTPServer
_oFTP:cFTPUser      := cFTPUser
_oFTP:cFTPPass      := cFTPPass
_oFTP:nFTPPort      := nFTPPort

//-------------------+
// Conecta FTP MSLog |
//-------------------+
If !_oFTP:Connect()
    CoNout("<< DNFATM07 >> - ERRO AO CONECTAR FTP " + Rtrim(_oFTP:cMsgErro))
    If !_lJob
        MsgStop("Erro ao conectar FTP. " + Rtrim(_oFTP:cMsgErro),"Dana - Avisos" )
    EndIf

    RestArea(_aArea)
    Return Nil 

EndIF

//---------------------+
// Posiciona diretorio |
//---------------------+
_oFTP:cRemoteFile := _cDirUpl
_oFTP:Directory()

//-------------------------------+
// Envia arquivos EDI para MSLOG |
//-------------------------------+
For _nX := 1 To Len(_aArquivo)
    
    //---------------------------+
    // Dados cabeçalho do pedido |
    //---------------------------+
    CoNout("<< DNFATM07 >> - ENVIANDO ARQUIVO " + RTrim(_aArquivo[_nX][1]))
    If !_lJob
        _oSay:cCaption := "Enviando arquivo " + RTrim(_aArquivo[_nX][1])
        ProcessMessages()
    EndIf

    _oFTP:cLocalFile    := _cDirRaiz + _cDirUpl + "/" + RTrim(_aArquivo[_nX][1])
    _oFTP:cRemoteFile   := _cDirUpl + "/" + RTrim(_aArquivo[_nX][1])
    If _oFTP:UpdLoad() 
        //------------------------------------+
        // Deleta arquivo enviado com sucesso | 
        //------------------------------------+
        FErase(_cDirRaiz + _cDirUpl + "/" + RTrim(_aArquivo[_nX][1]))
    Else 
        CoNout("<< DNFATM07 >> - ERRO AO ENVIAR ARQUIVO " + RTrim(_aArquivo[_nX][1]))
    EndIf

Next _nX 

//----------------+
// Disconecta FTP | 
//----------------+
_oFTP:Disconnect() 

RestArea(_aArea)
Return Nil 