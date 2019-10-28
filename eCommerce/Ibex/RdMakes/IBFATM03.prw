#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/ibex"
Static _cDirArq     := "/pedido"
Static _cDirUpl     := "/upload"
Static _cDirDow     := "/download"

/**********************************************************************/
/*/{Protheus.doc} IBFATM03
    @description Realiza a leitura dos pedidos separados IBEX
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
User Function IBFATM03(aParam)
Local _aArea        := GetArea()

Private _cArqLog    := ""

Private _lJob       := IIF(ValType(aParam) == "A",.T.,.F.)

Private _aDiverg    := {}

Private _oProcess   := Nil

//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)
MakeDir(_cDirRaiz + _cDirArq)

_cArqLog := _cDirRaiz + _cDirArq + "/" + "PEDIDOVENDA_SEPARACAO" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA LEITURA DOS PEDIDOS IBEX - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-------------------------+
// Envia pedidos para IBEX |
//-------------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(aParam[1], aParam[2],,,'FAT')
    
    IBFatM03Proc()

Else
    _oProcess:= MsNewProcess():New( {|| IBFatM03Proc()},"Aguarde...","Validando separação de pedidos eCommerce." )
	_oProcess:Activate()
EndIf

//----------------------------------+
// Envia e-mail com as divergencias | 
//----------------------------------+
If Len(_aDiverg) > 0

EndIf

LogExec("FINALIZA LEITURA DOS PEDIDOS IBEX - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
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

/**********************************************************************/
/*/{Protheus.doc} IBFatM03Proc
    @description Realiza a leitura dos pedidos separados 
    @type  Function
    @author Bernard M. Margarido
    @since 02/09/2019
    @version 1.0
/*/
/**********************************************************************/
Static Function IBFatM03Proc()
Local _aArea        := GetArea()

Local _cArqPV       :=  _cDirRaiz + _cDirArq + _cDirDow + "/"

Local _nX           := 0

Private _aPedItem   := {}
Private _aPedCab    := {}

LogExec( "<< IBFATM03 >> - BUSCA NOVOS ARQUIVOS NO DIRETORIO " +  _cArqPV +  " .")

//-------------------------------+
// Busca novos pedidos separados | 
//-------------------------------+
_aPedItem   := Directory(_cArqPV + "*.rdc")
_aPedCab    := Directory(_cArqPV + "*.rnc")

//------------------+
// Processa pedidos |
//------------------+
If !_lJob
    _oProcess:SetRegua1( Len(_aPedItem) )
EndIf

//-------------------------------+
// Processa arquivo de separação | 
//-------------------------------+
For _nX := 1 To Len(_aPedItem)

    If !_lJob
       _oProcess:IncRegua1("INICIA A LEITURA DO ARQUIVO " +  _aPedItem[_nX][1] +  " .")
    EndIf

    LogExec( "<< IBFATM03 >> - INICIA A LEITURA DO ARQUIVO " +  _aPedItem[_nX][1] +  " .")

    //---------------------------------+
    // Valida itens do pedido separado | 
    //---------------------------------+
    If IbFatM03It( _aPedItem[_nX][1])
        //----------------------------+
        // Valida cabeçalho do pedido |
        //----------------------------+
        IbFatM03Cab(_aPedItem[_nX][1])
    EndIf

    LogExec( "<< IBFATM03 >> - FINALIZA A LEITURA DO ARQUIVO " +  _aPedItem[_nX][1] +  " .")

Next _nX 

RestArea(_aArea)
Return .T.

/*******************************************************************/
/*/{Protheus.doc} IbFatM03It
    @description Realiza a leitura dos itens do pedido
    @author Bernard M. Margarido
    @since 13/02/2017
    @version undefined
    @type function
/*/
/*******************************************************************/
Static Function IbFatM03It(_cArqItem)
Local _aArea    := GetArea()

Local _cArqPV   :=  _cDirRaiz + _cDirArq + _cDirDow + "/"
Local _cLinha   := ""
Local _cNumPV   := ""
Local _cCodPrd  := ""

Local _nQtdPV   := 0
Local _nQtdSep  := 0
Local _nHdl     := 0
Local _nBytes   := 0
Local _nTPedido := TamSx3("C5_NUM")[1]
Local _nTProd   := TamSx3("B1_COD")[1]

Local _lRet     := .T.

//--------------------------+
// Valida se existe arquivo | 
//--------------------------+
If !File(_cArqPV + _cArqItem)
    LogExec( "<< IBFATM03 >> - ARQUIVO " +  _cArqItem +  " NAO ENCONTRADO.")
    RestArea(_aArea)
    Return .F.
EndIf

//--------------+
// Abre arquivo | 
//--------------+
_nHdl := FT_FUse(_cArqPV + _cArqItem)

//-----------------------------------------------+
// Valida se ocorreu erro na abertuda do arquivo | 
//-----------------------------------------------+
If _nHdl <= 0 
    LogExec( "<< IBFATM03 >> - ERRO AO ABRIR ARQUIVO " +  _cArqItem +  " .")
    RestArea(_aArea)
    Return .F.
EndIf

//--------------------------------+
// Determina o tamanho do arquivo |
//--------------------------------+
_nBytes := FT_FLastRec()

//--------------------------------+
// Posiciona no início do arquivo |
//--------------------------------+
FT_FGoTop()

If _nBytes > 0
    If !_lJob
        _oProcess:SetRegua2( _nBytes )
    EndIf

    While !Ft_FEof()
        
        //----------------------------+
        // Leitura da linha do pedido | 
        //----------------------------+
        _cLinha := FT_FReadLn()

        //----------------------+    
        // Grava dados da linha |
        //----------------------+
        _cNumPV := PadR(SubStr(_cLinha,022,20),_nTPedido)
        _cCodPrd:= PadR(SubStr(_cLinha,171,20),_nTProd)
        _nQtdPV := Val(SubStr(_cLinha,135,12))
        _nQtdSep:= Val(SubStr(_cLinha,147,12))

        If !_lJob
            _oProcess:IncRegua2(" Validando separacao produto " + RTrim(_cCodPrd) + " pedido " + _cNumPV + " .")
        EndIf

        LogExec( "<< IBFATM03 >> - VALIDANDO SEPARACAO PRODUTO " + RTrim(_cCodPrd) +  " PEDIDO " +  _cNumPV +  " .")
        
        //----------------------------+
        // Valida quantidade atendida |
        //----------------------------+
        If _nQtdPV <> _nQtdSep
            LogExec( "<< IBFATM03 >> - PRODUTO " + RTrim(_cCodPrd) +  " PEDIDO " +  _cNumPV +  " COM DIVERGENCIA.")
            _lRet   := .F.
            aAdd(_aDiverg,{_cNumPV,"001",_nQtdPV,_nQtdSep})
        EndIf

		Ft_FSkip()

	EndDo

EndIf

//----------------------+
// Fecha arquivo texto. |
//----------------------+
Ft_Fuse()

RestArea(_aArea)
Return _lRet

/*******************************************************************/
/*/{Protheus.doc} IbFatM03Cab
    @description Formata valor para envio ao eCommerce
    @author Bernard M. Margarido
    @since 13/02/2017
    @version undefined
    @type function
/*/
/*******************************************************************/
Static Function IbFatM03Cab(_cArqItem)
Local _aArea    := GetArea()

Local _cArqPV   :=  _cDirRaiz + _cDirArq + _cDirDow + "/"
Local _cLinha   := ""
Local _cArqCab  := ""
Local _cCodSta  := GetNewPar("EC_STAFAT","011")
Local _cEspecie := GetNewPar("EC_ESPECIE","EMBALAGEM")

Local _nPosArq  := 0
Local _nHdl     := 0
Local _nBytes   := 0
Local _nTPedido := TamSx3("C5_NUM")[1]
Local _nTProd   := TamSx3("B1_COD")[1]

Local _lRet     := .T.

//-------------------------------+
// Localiza arquivo de cabeçalho |
//-------------------------------+
_nPosArq := aScan(_aPedCab,{|x| SubStr(x[1],1,6) == SubStr(_cArqItem,1,6)})

If _nPosArq <= 0
    LogExec( "<< IBFATM03 >> - ARQUIVO NAO ENCONTRADO.")
    RestArea(_aArea)
    Return .F.
EndIf

//--------------------------+
// Valida se existe arquivo | 
//--------------------------+
_cArqCab    := _aPedCab[_nPosArq][1]
If !File(_cArqPV + _cArqCab)
    LogExec( "<< IBFATM03 >> - ARQUIVO " +  _cArqCab +  " NAO ENCONTRADO.")
    RestArea(_aArea)
    Return .F.
EndIf

//--------------+
// Abre arquivo | 
//--------------+
_nHdl := FT_FUse(_cArqPV + _cArqCab)

//-----------------------------------------------+
// Valida se ocorreu erro na abertuda do arquivo | 
//-----------------------------------------------+
If _nHdl <= 0 
    LogExec( "<< IBFATM03 >> - ERRO AO ABRIR ARQUIVO " +  _cArqCab +  " .")
    RestArea(_aArea)
    Return .F.
EndIf

//--------------------------------+
// Determina o tamanho do arquivo |
//--------------------------------+
_nBytes := FT_FLastRec()

//--------------------------------+
// Posiciona no início do arquivo |
//--------------------------------+
FT_FGoTop()

If _nBytes > 0
    If !_lJob
        _oProcess:SetRegua2( _nBytes )
    EndIf

    While !Ft_FEof()
        
        //----------------------------+
        // Leitura da linha do pedido | 
        //----------------------------+
        _cLinha := FT_FReadLn()

        //----------------------+    
        // Grava dados da linha |
        //----------------------+
        _cNumPV     := PadR(SubStr(_cLinha,022,20),_nTPedido)
        _nVolume    := Val(SubStr(_cLinha,500,12))
        _nPesoLiq   := RetPrcUni(Val(SubStr(_cLinha,512,12)),1)
        _nPesoBrut  := RetPrcUni(Val(SubStr(_cLinha,512,12)),1)

        If !_lJob
            _oProcess:IncRegua2(" Validando separacao  pedido " + _cNumPV + " .")
        EndIf

        LogExec( "<< IBFATM03 >> - VALIDANDO SEPARACAO PEDIDO " +  _cNumPV +  " .")

        //---------------------------+        
        // Posiciona Pedido de Venda |
        //---------------------------+        
        dbSelectArea("SC5")
        SC5->( dbSetOrder(1) )
        If !SC5->( dbSeek(xFilial("SC5") + _cNumPV) )
            LogExec( "<< IBFATM03 >> - PEDIDO NAO LOCALIZADO " +  _cNumPV +  " .")
            RestArea(_aArea)
            Return .F.
        EndIf
                       
        //-----------------------------------+
        // Atualiza informações de separação |
        //-----------------------------------+
        RecLock("SC5",.F.)
            SC5->C5_ESPECI1 := _cEspecie 
            SC5->C5_VOLUME1 := _nVolume
            SC5->C5_PESOL   := _nPesoLiq
            SC5->C5_PBRUTO  := _nPesoBrut
        SC5->( MsUnLock() )

         //----------------------------+
        // Posiciona status do pedido | 
        //----------------------------+
        WS1->( dbSeek(xFilial("WS1") + _cCodSta) )

        //-------------------------------+
        // Posiciona Orçamento eCommerce |
        //-------------------------------+
        dbSelectArea("WSA")
        WSA->( dbSetOrder(2) )
        If !WSA->( dbSeek(xFilial("WSA") + SC5->C5_XNUMECO) )
            LogExec( "<< IBFATM03 >> - PEDIDO ECOMMERCE NAO LOCALIZADO " +  SC5->C5_XNUMECO +  " .")
            RestArea(_aArea)
            Return .F.
        EndIf

        //--------------------+
        // Atualiza flag IBEX |
        //--------------------+
        If WSA->WSA_ENVLOG == "1"
            RecLock("WSA",.F.)
                WSA->WSA_ENVLOG := "2"
                WSA->WSA_CODSTA := _cCodSta
                WSA->WSA_DESTAT := WS1->WS1_DESCRI
            WSA->( MsUnLock() ) 
        EndIf
        //---------------------------+
        // Grava historico do pedido | 
        //---------------------------+
        u_AEcoStaLog(_cCodSta,WSA->WSA_NUMECO,WSA->WSA_NUM,Date(),Time())

        Ft_FSkip()

	EndDo

EndIf

//----------------------+
// Fecha arquivo texto. |
//----------------------+
Ft_Fuse()

RestArea(_aArea)
Return _lRet 

/*******************************************************************/
/*/{Protheus.doc} RetPrcUni

@description Formata valor para envio ao eCommerce

@author Bernard M. Margarido
@since 13/02/2017
@version undefined

@param nVlrUnit, numeric, descricao

@type function
/*/
/*******************************************************************/
Static Function RetPrcUni(_nValor,_nFator) 
    If _nFator == 1
	    _nValor		:= NoRound(_nValor,2) / 1000
    Else
        _nValor		:= NoRound(_nValor,2) / 100
    Endif
Return _nValor

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