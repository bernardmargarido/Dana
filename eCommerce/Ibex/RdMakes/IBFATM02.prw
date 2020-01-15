#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/ibex"
Static _cDirArq     := "/pedido"
Static _cDirUpl     := "/upload"
Static _cDirDow     := "/download"

/**********************************************************************/
/*/{Protheus.doc} IBFATM02
    @description Conecta FTP IBEX
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
User Function IBFATM02(aParam)
Local _aArea        := GetArea()

Private _cArqLog    := ""

Private _lJob       := IIF(Isincallstack("U_IBSCHM01"),.T.,.F.)

//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)
MakeDir(_cDirRaiz + _cDirArq)

_cArqLog := _cDirRaiz + _cDirArq + "/" + "FTP_CONNECT" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA CONEXAO FTP IBEX - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------------+
// Envia pedidos para IBEX |
//-------------------------+
If _lJob
    //RpcSetType(3)
	//RpcSetEnv(aParam[1], aParam[2],,,'FAT')
    
    IBFatM02Con()

Else
    FWMsgRun(, {|| IBFatM02Con() },"Aguarde...","Conectando FTP IBEX.")
EndIf

LogExec("FINALIZA CONEXAO FTP IBEX - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
ConOut("")

//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    //RpcClearEnv()
EndIf    

RestArea(_aArea)
Return .T.

/********************************************************************/
/*/{Protheus.doc} IBFatM02Con
    (long_description)
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/09?2019
/*/
/********************************************************************/
Static Function IBFatM02Con()
Local _aArea    := GetArea()

//-------------+
// Conecta FTP |
//-------------+
If !EcFtpConect(1)
    RestArea(_aArea)
    Return .F.
EndIf

//-------------------------------+
// Realiza Updaload dos arquivos |
//-------------------------------+
LogExec("<< IBFATM02 >> - INICIO UPLOAD FTP.")
    If _lJob
        IbFatM02Upd()
    Else
        Processa({|| IbFatM02Upd() },"Aguarde...","Enviando pedidos para separação.")
    Endif
LogExec("<< IBFATM02 >> - FIM UPLOAD FTP.")

//-------------------------------+
// Realiza Updaload dos arquivos |
//-------------------------------+
LogExec("<< IBFATM02 >> - INICIO DOWNLOAD FTP.")
    If _lJob
        IbFatM02Dow()
     Else
        Processa({|| IbFatM02Dow() },"Aguarde...","Baixando pedidos separados.")
    Endif
LogExec("<< IBFATM02 >> - INICIO DOWNLOAD FTP.")

//----------------+ 
// Desconecta FTP |
//----------------+ 
EcFtpConect(2)

RestArea(_aArea)
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} IbFatM02Upd
    @description Realiza o envio dos pedidos para IBEX 
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/09/2019
/*/
/**********************************************************************************/
Static Function IbFatM02Upd()
Local _aArea        := GetArea()

Local _cArqUpd      := _cDirRaiz + _cDirArq + _cDirUpl + "/"
Local _cArqIbxUpd   := "/prd/importacao/"
Local _cArqBkp      := ""

Local _lRet         := .T.
Local _lOk          := .T.

Local _nVezes       := 0
Local _nX           := 0

Local _aDirCab      := {}
Local _aDirItem     := {}

//-----------------------------+
// Envia cabeçalho dos pedidos |
//-----------------------------+
_aDirCab    := Directory(_cArqUpd + "*.inf")

If !_lJob
    ProcRegua(Len(_aDirCab))
EndIf

For _nX := 1 To Len(_aDirCab)

    If !_lJob
        IncProc("Enviando arquivo cabeçalho " + RTrim(_aDirCab[_nX,1]) )
    EndIf

    //-------------------------------------+
    // Valida se arquivo esta no diretorio |
    //-------------------------------------+
    If File(_cArqUpd + _aDirCab[_nX,1])

        //-------------------------------+
        // Numero de tentativas de envio | 
        //-------------------------------+
        _nVezes := 1
		
		While _nVezes <= 3
			
			LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Realizando UPLOAD do arquivo " + _aDirCab[_nX,1] + " - Tentativa No." + AllTrim(Str(_nVezes)))
			
			_lOk := FTPUpLoad(_cArqUpd + _aDirCab[_nX,1], _cArqIbxUpd + _aDirCab[_nX,1] )
			
			If _lOk
				//----------------------------------------------------------------------------+
				// Se conseguiu enviar, renomeia o arquivo do diretorio de envio do Protheus. |
				//----------------------------------------------------------------------------+
                _cArqBkp := StrTran(_aDirCab[_nX,1] , ".INF", ".IMP" )
				FRename(_cArqUpd + _aDirCab[_nX,1], _cArqUpd + _cArqBkp)
				LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Arquivo " + _aDirCab[_nX,1] + " enviado com sucesso.")
				Exit
			Else
				LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Erro ao enviar o arquivo " + _aDirCab[_nX,1] + " - Tentativa No." + AllTrim(Str(_nVezes)))
				_nVezes++
				Inkey(5)
			EndIf
			
		EndDo
    EndIf

Next _nX

//--------------------+
// Envia itens pedido |
//--------------------+
_aDirItem   := Directory(_cArqUpd + "*.idt")

If !_lJob
    ProcRegua(Len(_aDirItem))
EndIf

For _nX := 1 To Len(_aDirItem)

     If !_lJob
        IncProc("Enviando arquivo itens " + RTrim(_aDirCab[_nX,1]) )
    EndIf

    //-------------------------------------+
    // Valida se arquivo esta no diretorio |
    //-------------------------------------+
    If File(_cArqUpd + _aDirItem[_nX,1])

        //-------------------------------+
        // Numero de tentativas de envio | 
        //-------------------------------+
        _nVezes := 1
		
		While _nVezes <= 3
			
			LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Realizando UPLOAD do arquivo " + _aDirItem[_nX,1] + " - Tentativa No." + AllTrim(Str(_nVezes)))
			
			_lOk := FTPUpLoad(_cArqUpd + _aDirItem[_nX,1], _cArqIbxUpd + _aDirItem[_nX,1] )
			
			If _lOk
				//----------------------------------------------------------------------------+
				// Se conseguiu enviar, renomeia o arquivo do diretorio de envio do Protheus. |
				//----------------------------------------------------------------------------+
                _cArqBkp := StrTran(_aDirItem[_nX,1] , ".IDT", ".IMP" )
				FRename(_cArqUpd + _aDirItem[_nX,1], _cArqUpd + _cArqBkp)
				LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Arquivo " + _aDirItem[_nX,1] + " enviado com sucesso.")
				Exit
			Else
				LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Erro ao enviar o arquivo " + _aDirItem[_nX,1] + " - Tentativa No." + AllTrim(Str(_nVezes)))
				_nVezes++
				Inkey(5)
			EndIf
			
		EndDo
    EndIf

Next _nX

RestArea(_aArea)
Return _lRet 

/**********************************************************************************/
/*/{Protheus.doc} IbFatM02Dow
    @description Realiza o download dos arquivos IBEX
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/09/2019
/*/
/**********************************************************************************/
Static Function IbFatM02Dow()
Local _aArea        := GetArea()

Local _cArqDow      := _cDirRaiz + _cDirArq + _cDirDow + "/"
Local _cArqIbxDow   := "/prd/exportacao/"
Local _cArqBkp      := ""

Local _lRet         := .T.
Local _lOk          := .T.

Local _nVezes       := 0
Local _nX           := 0

Local _aDirCab      := {}
Local _aDirItem     := {}

//----------------------+
// Valida diretorio FTP |
//----------------------+
FTPDirChange(_cArqIbxDow)

//-----------------------------+
// Envia cabeçalho dos pedidos |
//-----------------------------+
_aDirCab    := FTPDirectory("*.rnc")

If !_lJob
    ProcRegua(Len(_aDirCab))
EndIf

For _nX := 1 To Len(_aDirCab)

    If !_lJob
        IncProc("Download arquivo cabeçalho " + RTrim(_aDirCab[_nX,1]) )
    EndIf

    //-------------------------------+
    // Numero de tentativas de envio | 
    //-------------------------------+
    _nVezes := 1
    
    While _nVezes <= 3
        
        LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Realizando DOWNLOAD do arquivo " + _aDirCab[_nX,1] + " - Tentativa No." + AllTrim(Str(_nVezes)))
        
        _lOk := FTPDownLoad(_cArqDow + _aDirCab[_nX,1], _aDirCab[_nX,1] )
        
        If _lOk
            //----------------------------------------------------------------------------+
            // Se conseguiu enviar, renomeia o arquivo do diretorio de envio do Protheus. |
            //----------------------------------------------------------------------------+
            _cArqBkp := StrTran(_aDirCab[_nX,1] , ".rnc", ".imp" )
            FTPRenameFile(_aDirCab[_nX,1], _cArqBkp)
            LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Arquivo " + _aDirCab[_nX,1] + " copiado com sucesso.")
            Exit
        Else
            LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Erro ao copiar o arquivo " + _aDirCab[_nX,1] + " - Tentativa No." + AllTrim(Str(_nVezes)))
            _nVezes++
            Inkey(5)
        EndIf
        
    EndDo

Next _nX

//--------------------+
// Envia itens pedido |
//--------------------+
_aDirItem   := FTPDirectory("*.rdc")

If !_lJob
    ProcRegua(Len(_aDirItem))
EndIf

For _nX := 1 To Len(_aDirItem)

    If !_lJob
        IncProc("Download arquivo itens " + RTrim(_aDirItem[_nX,1]) )
    EndIf

    //-------------------------------+
    // Numero de tentativas de envio | 
    //-------------------------------+
    _nVezes := 1
    
    While _nVezes <= 3
        
        LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Realizando DOWNLOAD do arquivo " + _aDirItem[_nX,1] + " - Tentativa No." + AllTrim(Str(_nVezes)))
        
        _lOk := FTPDownLoad(_cArqDow + _aDirItem[_nX,1], _aDirItem[_nX,1] )
        
        If _lOk
            //----------------------------------------------------------------------------+
            // Se conseguiu enviar, renomeia o arquivo do diretorio de envio do Protheus. |
            //----------------------------------------------------------------------------+
            _cArqBkp := StrTran(_aDirItem[_nX,1] , ".rdc", ".imp" )
            FTPRenameFile(_aDirItem[_nX,1], _cArqBkp)
            LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Arquivo " + _aDirItem[_nX,1] + " copiado com sucesso.")
            Exit
        Else
            LogExec( "<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Erro ao copiar o arquivo " + _aDirItem[_nX,1] + " - Tentativa No." + AllTrim(Str(_nVezes)))
            _nVezes++
            Inkey(5)
        EndIf
        
    EndDo

Next _nX

Return _lRet

/**********************************************************************************/
/*/{Protheus.doc} EcFtpConect
    @description Conecta FTP IBEX Logistica
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/09/2019
/*/
/**********************************************************************************/
Static Function EcFtpConect(_nTpConect)
Local _cURLFtp  := GetNewPar("EC_FTPIBX","201.55.81.110")
Local _cUsrFTP  := GetNewPar("EC_FTPUSR","dana")
Local _cPassFTP := GetNewPar("EC_FTPPAS","DUx!@19PxkAh!")

Local _nPorta   := 21
Local _nVezes   := 0

Local _lBinario := .T.
Local _lRet     := .T.

LogExec("<< IBFATM02 >> - INICIA CONEXAO FTP.")

While _nVezes <= 3

    IF _nTpConect == 1
        FTPDisconnect()
        _lRet := FTPConnect(_cURLFtp,_nPorta,_cUsrFTP,_cPassFTP)
    Else
        _lRet := FTPDisconnect()
    EndIF

    IF !_lRet
		Inkey(5)
		_nVezes++
		IF _nTpConect == 1
			LogExec("<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Erro de conexao ao FTP. Servidor: " + _cURLFtp + " Usuario: " + _cUsrFTP + " Senha: " + _cPassFTP + " - Tentativas: " + Alltrim(Str(_nVezes)))
		Else
			LogExec("<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Erro ao desconectar do FTP. Servidor: " + _cURLFtp + " Usuario: " + _cUsrFTP + " Senha: " + _cPassFTP + " - Tentativas: " + Alltrim(Str(_nVezes)))
		EndIF
	Else
		IF _nTpConect == 1
			LogExec("<< IBFATM02 >> - " + Dtoc(Date()) + " " + Time() + " Conexao ao FTP efetuada com sucesso.")
			
			// Determina que sera trasferido um arquivo binario
			IF _lBinario
				FtpSetType(1)
			EndIF
		Else
			LogExec("<< IBFATM02 >> - "  + Dtoc(Date()) + " " + Time() + " Desconexao do FTP efetuada com sucesso.")
		EndIF
		Exit
	EndIF

    _nVezes++

EndDo

LogExec("<< IBFATM02 >> - FINALIZA CONEXAO FTP.")

Return _lRet

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