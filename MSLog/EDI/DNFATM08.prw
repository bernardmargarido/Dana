#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/MsLog"
Static _cDirDown    := "/download"

/***********************************************************************************************/
/*/{Protheus.doc} DNFATM08
    @description JOB - Realiza a leitura dos dados retornados da MSLOG
    @type  Function
    @author Bernard M. Margarido
    @since 07/05/2021
/*/
/***********************************************************************************************/
User Function DNFATM08(_cEmpInt,_cFilInt)
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
MakeDir(_cDirRaiz + _cDirDown)

_cArqLog := _cDirRaiz + "/" + "RETORNO_MSLOG" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA CRIACAO DOS ARQUIVOS MSLOG - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//---------------------------+
// Integração arquivos MSLOG |
//---------------------------+
LogExec("<< DNFATM08 >> - INICIO DOWNLOAD DE ARQUIVOS MSLOG " + dTos( Date() ) + " - " + Time() )
    If _lJob
        DnFatM08A()
        DnFatM08B()
    Else 
        FWMsgRun(,{|_oSay| DnFatM08A(_oSay)},"Aguarde ....","Lendo arquivos da MSLOG.")
        FWMsgRun(,{|_oSay| DnFatM08B(_oSay)},"Aguarde ....","Processando arquivos da MSLOG.")
    EndIf 
LogExec("<< DNFATM08 >> - FIM DOWNLOAD DE ARQUIVOS MSLOG " + dTos( Date() ) + " - " + Time() )

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
/*/{Protheus.doc} DnFatM08A
    @description Realiza download dos arquivos para a MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 07/05/2021
/*/
/*******************************************************************************************************/
Static Function DnFatM08A(_oSay)
Local _aArea        := GetArea()
Local _aArquivo     := {}

Local cFTPServer    := GetNewPar("DN_MSLSERV","ftp.danalogistica.com.br")
Local cFTPUser      := GetNewPar("DN_MSLUSER","mslog")
Local cFTPPass      := GetNewPar("DN_MSLPASS","j0$5y5Qj")
Local nFTPPort      := GetNewPar("DN_MSLPORT",21)

Local _nX           := 0

Local _oFTP         := Nil 

Default _oSay       := Nil 

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
    LogExec("<< DNFATM08 >> DnFatM08A - ERRO AO CONECTAR FTP " + Rtrim(_oFTP:cMsgErro))
    If !_lJob
        MsgStop("Erro ao conectar FTP. " + Rtrim(_oFTP:cMsgErro),"Dana - Avisos" )
    EndIf

    RestArea(_aArea)
    Return Nil 

EndIF

//---------------------+
// Posiciona diretorio |
//---------------------+
_oFTP:cRemoteDir    := _cDirDown
_oFTP:DirChange()
_oFTP:Directory("*.TXT")
_aArquivo := _oFTP:aArray

//-------------------------------------------+
// Realiza o download dos arquivos EDI MSLOG |
//-------------------------------------------+
For _nX := 1 To Len(_aArquivo)
    
    //---------------------------+
    // Dados cabeçalho do pedido |
    //---------------------------+
    LogExec("<< DNFATM08 >> DnFatM08A - REALIZANDO O DOWNLOAD DO ARQUIVO " + RTrim(_aArquivo[_nX][1]))

    If !_lJob
        _oSay:cCaption := "Download arquivo " + RTrim(_aArquivo[_nX][1])
        ProcessMessages()
    EndIf

    _oFTP:cLocalFile    := _cDirRaiz + _cDirDown + "/" + RTrim(_aArquivo[_nX][1])
    _oFTP:cRemoteFile   := RTrim(_aArquivo[_nX][1])
    If _oFTP:Download() 
        _oFTP:cDelFile := RTrim(_aArquivo[_nX][1])
        _oFTP:Delete() 
        LogExec("<< DNFATM08 >> DnFatM08A - DOWNLOAD ARQUIVO " + RTrim(_aArquivo[_nX][1]) + " REALIZADO COM SUCESSO.")
    Else 
        LogExec("<< DNFATM08 >> DnFatM08A - ERRO AO REALIZAR O DOWNLOAD ARQUIVO " + RTrim(_aArquivo[_nX][1]))
    EndIf

Next _nX 

//----------------+
// Disconecta FTP | 
//----------------+
_oFTP:Disconnect() 

RestArea(_aArea)
Return Nil 

/*******************************************************************************************/
/*/{Protheus.doc} DnFatM08B
    @description Processa arquivos de retorno MSLOG
    @type  Static Function
    @author Bernard M. Margarido
    @since 25/06/2021
/*/
/*******************************************************************************************/
Static Function DnFatM08B(_oSay)
Local _aArea    := GetArea()
Local _aArquivo := {}
Local _aCabec   := {}
Local _aItem    := {}
Local _aPedidos := {}
Local _aNotas   := {}

Local _cLinha   := ""
Local _cNumPV   := ""
Local _cDoc     := ""

Local _nLinha   := 0
Local _nX       := 0
Local _nY       := 0
Local _nHdl     := 0
Local _nBytes   := 0

Local _nTItem   := TamSx3("C6_ITEM")[1]
Local _nTProd   := TamSx3("C6_PRODUTO")[1]
Local _nTPedido := TamSx3("C6_NUM")[1]
Local _nTDoc    := TamSx3("F2_DOC")[1]

Local _lAtualiza:= .T.

Default _oSay   := Nil 

//--------------------------------------+
// Busca todos os arquivos do diretorio | 
//--------------------------------------+
_aArquivo := Directory(_cDirRaiz + _cDirDown + "/" + "*.txt")

//----------------------------------+
// SC5 - Pedidos de Venda Cabeçalho |
//----------------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//------------------------------+
// SC6 - Pedidos de Venda Itens |
//------------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

//------------------------------+
// SC9 - Pedido Itens Liberados | 
//------------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//-------------------------+
// SF2 - Nota fiscal saída |
//-------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

//-----------------------------------+
// SD2 - Posiciona itens nota fiscal |
//-----------------------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )

For _nX := 1 To Len(_aArquivo)

    If !_lJob
        _oSay:cCaption := "Processando arquivo " + RTrim(_aArquivo[_nX][1])
        ProcessMessages()
    EndIf
   
    LogExec("<< DNFATM08 >> DnFatM08B - PROCESSANDO ARQUIVO " + RTrim(_aArquivo[_nX][1]))

    //-------------------------------------+
    // Valida se arquivo esta no diretorio |
    //-------------------------------------+
    If File(_cDirRaiz + _cDirDown + "/" + _aArquivo[_nX,1])
        
        LogExec("<< DNFATM08 >> DnFatM08B - ARQUIVO " + RTrim(_aArquivo[_nX][1]) + " LOCALIZADO.")

        _nHdl := FT_FUse(_cDirRaiz + _cDirDown + "/" + _aArquivo[_nX,1])
        If _nHdl > 0 
            //--------------------------------+
            // Determina o tamanho do arquivo |
            //--------------------------------+
            _nBytes := FT_FLastRec()

            //--------------------------------+
            // Posiciona no início do arquivo |
            //--------------------------------+
            FT_FGoTop()

            If _nBytes > 0

                _nLinha := 0
                While !Ft_FEof()
                    //----------------------------+
                    // Leitura da linha do pedido | 
                    //----------------------------+
                    _cLinha := FT_FReadLn()
                    _nLinha++
                    If _nLinha == 1
                        If At(";",_cLinha) > 0 
                            _aCabec := Separa(_cLinha,";")
                        Else 
                            _aCabec := {_cLinha,"0"}
                        EndIf
                        aAdd(_aPedidos,{_aCabec[1],Val(_aCabec[2]),{}})
                    Else 
                        _aItem  := Separa(_cLinha,";")
                        aAdd(_aPedidos[Len(_aPedidos)][3],{_aItem[1],_aItem[2],Val(_aItem[3]),Val(_aItem[4]),Val(_aItem[5])})
                    EndIf

                    Ft_FSkip()

                EndDo
            EndIf
        EndIf

        //----------------------+
        // Fecha arquivo texto. |
        //----------------------+
        Ft_Fuse()

        //------------------+
        // Renomeia arquivo |
        //------------------+    
        _cArqBkp := StrTran(_aArquivo[_nX,1] , ".TXT", ".LIDO" )
		FRename(_cDirRaiz + _cDirDown + "/" + _aArquivo[_nX,1] , _cDirRaiz + _cDirDown + "/" + _cArqBkp)

    EndIf

Next _nX 

//------------------+
// Processa pedidos | 
//------------------+
If Len(_aPedidos) > 0
    For _nX := 1 To Len(_aPedidos)

        If !_lJob
            _oSay:cCaption := "Validando pedido : " + RTrim(_aPedidos[_nX][1])
            ProcessMessages()
        EndIf

        //------------------+
        // Posiciona Pedido |
        //------------------+
        _lAtualiza  := .T.
        _aNotas     := {}
        _cDoc       := IIF(Len(_aPedidos[_nX][1]) > 6, SubStr(_aPedidos[_nX][1],3,6), _aPedidos[_nX][1])
        If SF2->( dbSeek(xFilial("SF2") + PadR(_cDoc,_nTDoc)) )

            //---------------------------------+
            // Busca numero do pedido de venda |
            //---------------------------------+
            DnFatM08D(SF2->F2_DOC,SF2->F2_SERIE,@_cNumPV)

            For _nY := 1 To Len(_aPedidos[_nX][3])
                //---------------------------+
                // Retorna Codigo do Produto |
                //---------------------------+
                _cCodPrd := ""
                If DnFatM08C(_aPedidos[_nX][3][_nY][1],@_cCodPrd,@_lAtualiza)

                    //--------------------------+
                    // Posiciona Item do Pedido |
                    //--------------------------+
                    If SC6->( dbSeek(xFilial("SC6") + PadR(_cNumPV,_nTPedido) + Padr(_aPedidos[_nX][3][_nY][2],_nTItem) + PadR(_cCodPrd,_nTProd) ))
                        RecLock("SC6",.F.)
                            SC6->C6_XENVWMS := "3"
                            SC6->C6_XDTALT	:= Date()
                            SC6->C6_XHRALT	:= Time()
                        SC6->( MsUnLock() )
                    EndIf

                    //---------------------------+
                    // Posiciona itens liberados |
                    //---------------------------+
                    If SC9->( dbSeek(xFilial("SC9") +  PadR(_cNumPV,_nTPedido) + Padr(_aPedidos[_nX][3][_nY][2],_nTItem)))
                        RecLock("SC9",.F.)
                            SC9->C9_XENVWMS := "3"
                            SC9->C9_XDTALT	:= Date()
                            SC9->C9_XHRALT	:= Time()
                        SC9->( MsUnLock() )
                    EndIf

                EndIf 
            Next _nY

            //----------------------+
            // Atualiza LOG retorno | 
            //----------------------+
            If _lAtualiza

                RecLock("SF2",.F.)
                    SF2->F2_XENVWMS := "3"
                    SF2->F2_XDTALT	:= Date()
                    SF2->F2_XHRALT	:= Time()
                    SF2->F2_VOLUME1 := _aPedidos[_nX][2]
                SF2->( MsUnLock() )

                If SC5->( dbSeek(xFilial("SC5") + _cNumPV) )
                    RecLock("SC5",.F.)
                        SC5->C5_XENVWMS := "3"
                        SC5->C5_XDTALT	:= Date()
                        SC5->C5_XHRALT	:= Time()
                        SC5->C5_VOLUME1 := _aPedidos[_nX][2]
                    SC5->( MsUnLock() )
                EndIf 
            EndIf
        EndIf
    Next _nX 
EndIf

RestArea(_aArea)
Return Nil 

/*******************************************************************************************/
/*/{Protheus.doc} DnFatM08C
	@description Retorna codigo do produto pelo codigo de barras
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function DnFatM08C(_cCodBar,_cCodPrd,_lAtualiza)
Local _cAlias := ""
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "    B1_COD " + CRLF 
_cQuery += " FROM " + CRLF
_cQuery += "    " + RetSqlName("SB1") + " " + CRLF
_cQuery += " WHERE " + CRLF 
_cQuery += "    B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
_cQuery += "    ( B1_CODBAR = '" + _cCodBar + "' OR B1_EAN = '" + _cCodBar + "' ) AND " + CRLF
_cQuery += "    D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

_cCodPrd    := (_cAlias)->B1_COD
_lAtualiza  := IIF(_lAtualiza .And. Empty(_cCodPrd), .F., .T.)

(_cAlias)->( dbCloseArea() )

Return IIF(Empty(_cCodPrd),.F.,.T.) 

/*******************************************************************************************/
/*/{Protheus.doc} DnFatM08D
    @description Retorna numero do pedido de venda 
    @type  Static Function
    @author Bernard M Margarido
    @since 09/12/2021
/*/
/*******************************************************************************************/
Static Function DnFatM08D(_cDoc,_cSerie,_cNumPV)
Local _cQuery := ""
Local _cAlias := ""    

_cQuery := " SELECT " + CRLF
_cQuery += "	TOP 1 " + CRLF
_cQuery += "	D2_PEDIDO " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	SD2010 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	D2_FILIAL = '" + xFilial("SD2") + "' AND " + CRLF
_cQuery += "	D2_DOC = '" + _cDoc + "' AND " + CRLF
_cQuery += "	D2_SERIE = '" + _cSerie + "' AND " + CRLF
_cQuery += "	D_E_L_E_T_ = '' "

_cAlias     := MPSysOpenQuery(_cQuery)

_cNumPV    := (_cAlias)->D2_PEDIDO

(_cAlias)->( dbCloseArea() )
Return IIF(Empty(_cNumPV),.F.,.T.) 

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
