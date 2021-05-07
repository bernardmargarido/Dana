#INCLUDE "TOTVS.CH"


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

    Data nFTPPort       As Integer
    Data nFTPRet        As Integer

    Data oFTP           As Object 

    Method New() Constructor
    Method Connect() 
    Method Disconnect()
    Method UpdLoad()
    Method Download()
    Method Directory()

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

    ::nFTPPort      := 0
    ::nFTPRet       := 0

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
Local _lRet     := .T.

//---------------------------+
// Instancia a classe do FTP |
//---------------------------+
::oFTP      := TFTPClient():New()

//-------------+
// Conecta FTP | 
//-------------+
::nFTPRet   := ::oFTP:FTPConnect(::cFTPServer, ::nFTPPort, ::cFTPUser, ::cFTPPass)

//----------------+
// Valida conexão |
//----------------+
If ::nFTPRet <> 0
	::cMsgErro := ::oFTP:GetLastResponse()
     _lRet     := .F.
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

    ::oFTP:Close()

Return .T.

/********************************************************************************************************/
/*/{Protheus.doc} UpdLoad
    @description Metodo - UpdLoad arquivos FTP 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method UpdLoad() Class FTPConnect

::nFTPRet := ::oFTP:SendFile( ::cLocalFile, ::cRemoteFile )

Return IIF(::nFTPRet > 0, .F., .T.)

/********************************************************************************************************/
/*/{Protheus.doc} Download
    @description Metodo - Download dos arquivos FTP 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method Download() Class FTPConnect

::nFTPRet := ::oFTP:ReceiveFile( ::cRemoteFile, ::cLocalFile )

Return IIF(::nFTPRet > 0, .F., .T.) 

/********************************************************************************************************/
/*/{Protheus.doc} Directory
    @description Metodo - Posiciona diretorio 
    @type  Function
    @author Bernard M. Margarido
    @since 05/05/2021
 /*/
 /********************************************************************************************************/
Method Directory() Class FTPConnect

::nFTPRet := ::oFTP:ChDir( ::cRemoteFile )

Return IIF(::nFTPRet > 0, .F., .T.) 