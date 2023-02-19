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
Default _cFilInt   := "07"

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmpInt, _cFilInt,,,'LOJ')
EndIf

//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)
MakeDir(_cDirRaiz + _cDirUpl)

_cArqLog := _cDirRaiz + "/" + "ENVIA_MSLOG" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA O ENVIO DOS ARQUIVOS MSLOG - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//---------------------------+
// Integração arquivos MSLOG |
//---------------------------+
LogExec("<< DNFATM07 >> - INICIO UPLOAD DE ARQUIVOS MSLOG " + dTos( Date() ) + " - " + Time() )
    If _lJob
        DnFatM07A()
    Else 
        FWMsgRun(,{|_oSay| DnFatM07A(_oSay)},"Aguarde ....","Enviando arquivos para MSLOG.")
    EndIf 
LogExec("<< DNFATM07 >> - FIM UPLOAD DE ARQUIVOS MSLOG " + dTos( Date() ) + " - " + Time() )

LogExec("FINALIZA ENVIO DOS ARQUIVOS MSLOG - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
ConOut("")

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

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
    LogExec("<< DNFATM07 >> - NAO EXISTEM ARQUIVOS PARA SEREM ENVIADOS.")
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
    LogExec("<< DNFATM07 >> - ERRO AO CONECTAR FTP " + Rtrim(_oFTP:cMsgErro))
    If !_lJob
        MsgStop("Erro ao conectar FTP. " + Rtrim(_oFTP:cMsgErro),"Dana - Avisos" )
    EndIf

    RestArea(_aArea)
    Return Nil 

EndIF

//---------------------+
// Posiciona diretorio |
//---------------------+
_oFTP:cRemoteDir := _cDirUpl
_oFTP:DirChange()

//-------------------------------+
// Envia arquivos EDI para MSLOG |
//-------------------------------+
For _nX := 1 To Len(_aArquivo)
    
    //---------------------------+
    // Dados cabeçalho do pedido |
    //---------------------------+
    LogExec("<< DNFATM07 >> - ENVIANDO ARQUIVO " + RTrim(_aArquivo[_nX][1]))
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
        //FErase(_cDirRaiz + _cDirUpl + "/" + RTrim(_aArquivo[_nX][1]))
        _cArqBkp := StrTran(_aArquivo[_nX,1] , ".TXT", ".ENVIADO" )

        //----------------------------+
        // Deleta arquivo caso exista |
        //----------------------------+
        If File(_cDirRaiz + _cDirUpl + "/" + _cArqBkp)
            FErase(_cDirRaiz + _cDirUpl + "/" + _cArqBkp)
        EndIf 

		FRename(_cDirRaiz + _cDirUpl + "/" + _aArquivo[_nX,1] , _cDirRaiz + _cDirUpl + "/" + _cArqBkp)
    Else 
        LogExec("<< DNFATM07 >> - ERRO AO ENVIAR ARQUIVO " + RTrim(_aArquivo[_nX][1]))
    EndIf

Next _nX 

//----------------+
// Disconecta FTP | 
//----------------+
_oFTP:Disconnect() 

RestArea(_aArea)
Return Nil 

/*******************************************************************************************/
/*/{Protheus.doc} LogExec
	@description Grava log 
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(_cArqLog,cMsg)
Return 
