#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/********************************************************************************************************/
/*/{Protheus.doc} FTpConnect
    @description Classe para conexão e envio de dados via FTP
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
 Class FTPConnect

    Data cFTPServer     As String
    Data cFTPUser       As String 
    Data cFTPPass       As String
    Data cMsgErro       As String
    Data cLocalFile     As String
    Data cRemoteFile    As String 
    Data cRemoteDir     As String
    Data cDelFile       As String 

    Data nFTPPort       As Integer
    Data nFTPRet        As Integer

    Data aArray         As Array 

    Data oFTP           As Object 

    Method New() Constructor
    Method Connect() 
    Method Disconnect()
    Method UpdLoad()
    Method Download()
    Method DirChange()
    Method Directory()
    Method Delete()
    Method FtpSetPasv()

End Class 

/********************************************************************************************************/
/*/{Protheus.doc} New
    @description Metodo construtor da classe
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method New() Class FTPConnect

    ::cFTPServer    := ""
    ::cFTPUser      := ""
    ::cFTPPass      := ""
    ::cMsgErro      := ""
    ::cDelFile      := ""
    ::cLocalFile    := ""
    ::cRemoteFile   := ""
    ::cRemoteDir    := ""

    ::nFTPPort      := 0
    ::nFTPRet       := 0

    ::aArray        := {}

    ::oFTP          := Nil 

Return Nil 

/********************************************************************************************************/
/*/{Protheus.doc} Connect
    @description Metodo - Conecta FTP 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method Connect() Class FTPConnect
    Local _nVezes   := 0

    Local _lBinario := .T.
    Local _lRet     := .T.

    While _nVezes <= 3

        _lRet := FTPConnect(::cFTPServer,::nFTPPort,::cFTPUser,::cFTPPass)

        IF !_lRet
            Inkey(5)
            _nVezes++
        Else
            //--------------------------------------------------+
            // Determina que sera trasferido um arquivo binario |
            //--------------------------------------------------+
            IF _lBinario
                FtpSetType(1)
            EndIF
            Exit
        EndIF

        _nVezes++

    EndDo

    //----------------+
    // Valida conexão |
    //----------------+
    If !_lRet 
        ::cMsgErro := "Erro ao conectar ao FTP"
    EndIf

Return _lRet 

/********************************************************************************************************/
/*/{Protheus.doc} Disconnect
    @description Metodo - Desconecta FTP 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method Disconnect() CLass FTPConnect
Return FTPDisconnect()

/********************************************************************************************************/
/*/{Protheus.doc} UpdLoad
    @description Metodo - UpdLoad arquivos FTP 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method UpdLoad() Class FTPConnect
Return FTPUpLoad(::cLocalFile, ::cRemoteFile )

/********************************************************************************************************/
/*/{Protheus.doc} Download
    @description Metodo - Download dos arquivos FTP 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method Download() Class FTPConnect
Return FTPDownLoad(::cLocalFile, ::cRemoteFile )

/********************************************************************************************************/
/*/{Protheus.doc} DirChange
    @description Metodo - Posiciona diretorio 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method DirChange() Class FTPConnect
Return FTPDirChange(::cRemoteDir)

/********************************************************************************************************/
/*/{Protheus.doc} Delete
    @description Metodo - Deleta arquivo FTP
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method Delete() Class FTpConnect
Return FTPErase(::cDelFile)

/********************************************************************************************************/
/*/{Protheus.doc} Directory
    @description Metodo - Busca arquivos no diretorio FTP 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method Directory(_cMask,_lCase) Class FTpConnect
    Local _aArquivos    := {}

    Default _cMask      := ""
    Default _lCase      := .T.

    //----------------------------+    
    // Retorna arquivos diretorio |
    //----------------------------+    
    _aArquivos := FTPDirectory(_cMask)
    ::aArray := _aArquivos

Return IIF(Len(::aArray) > 0,.T.,.F.)

