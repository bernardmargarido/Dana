#INCLUDE "PROTHEUS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CODCLI  1 
#DEFINE LOJACLI 2
#DEFINE FILCLI  3 

#DEFINE CRLF CHR(13) + CHR(10)
#DEFINE _OPC_cGETFILE (GETF_ONLYSERVER )  

Static _nTCodCli  := TamSx3("A1_COD")[1]
Static _nTLojaCli := TamSx3("A1_LOJA")[1]

/************************************************************************************************************/
/*/{Protheus.doc} DNIMPCLI
    @description realiza a atualização da filial de faturamento dos clientes
    @type  Function
    @author user
    @since date
/*/
/************************************************************************************************************/
User Function DNIMPCLI()
Local _cExt     := "Arquivo CSV | *.CSV"

Private _cArq   := ""
Private _aErros := {}

If Empty(_cArq:= cGetFile( _cExt , _cExt , Nil , "C:\temp" , .F. , nOR(GETF_LOCALHARD,_OPC_cGETFILE),.T., .T. ) )
	MsgStop("Arquivo não informado. Verifique!")
	Return Nil
EndIf

If !File(_cArq)
    MsgStop("Arquivo não localizado.")
	Return Nil
EndIf

If !MsgYesNo("Confirma processamento ?")
	MsgStop("Processo abortado!")
	Return Nil
EndIf

FwMsgRun(,{|_oSay| DnImpCliA(_oSay,_cArq)},"Dana - Avisos","Aguarde... Importando dados.")

RestArea(_aArea)
Return Nil 

/************************************************************************************************************/
/*/{Protheus.doc} DnImpCliA
    @description Realiza a atualização da filial dos clientes
    @type  Static Function
    @author user
    @since date
/*/
/************************************************************************************************************/
Static Function DnImpCliA(_oSay,_cArq)
Local _aArea        := GetArea()

Local _cLinha       := ""
Local cDirImp       := "/csv/"
Local _cError       := ""

Local _nHdl         := 0
Local _nCount       := 1

Local _aLin         := {}

Private cArqLog     := ""

Private lMsErroAuto := .F.

MakeDir(cDirImp)
cArqLog := cDirImp + "IMPORTACSV" + cEmpAnt + cFilAnt + ".LOG"

LogExec(Replicate("-",80))
LogExec("INICIO - DELETA ORCAMENTOS - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------------------+
// Realiza a abertura do arquivo | 
//-------------------------------+
_oSay:cCaption := "Realiza a abertura do arquivo "
ProcessMessages()

FT_FUSE(_cArq)

//---------------------+
// Numero de registros | 
//---------------------+
_nHdl := FT_FLASTREC()   

//--------------------------------+
// Posiciona no primeiro registro |
//--------------------------------+
FT_FGOTOP()

//----------------+
// SA1 - Clientes |
//----------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )

While !FT_FEOF()

    _oSay:cCaption := "Linha  " + cValToChar(_nCount) + " de " + cValToChar(_nHdl) + " ."
    ProcessMessages()

    If _nCount > 1

        _cLinha := FT_FREADLN()
        _aLin   := Separa(_cLinha,";") 
        _cError := ""
        _lRet   := .F.

        LogExec("   CLIENTE " + _aLin[CODCLI] + " LOJA " + _aLin[LOJACLI] + " .")

        _oSay:cCaption := " Cliente " + _aLin[CODCLI] + " loja " + _aLin[LOJACLI] + " ."
        ProcessMessages()
        
        If SA1->( dbSeek(xFilial("SA1") +  Padr(_aLin[CODCLI],_nTCodCli) + PadR(_aLin[LOJACLI],_nTLojaCli) ) ) 
            If SA1->A1_PESSOA == "J" .And. SA1->A1_MSBLQL <> "1"
                RecLock("SA1",.F.)
                    SA1->A1_XFILFAT   := IIF(Empty(_aLin[FILCLI]),"05",_aLin[FILCLI])
                SA1->( MsUnLock() )
            EndIf 
        EndIf
    EndIf
    _nCount++
    FT_FSKIP() 

EndDo

LogExec("FIM - IMPORTA CSV CLIENTE - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
LogExec(Replicate("-",80))

RestArea(_aArea)
Return Nil 

Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.