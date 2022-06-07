#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE COL_COD     01
#DEFINE COL_DESC    02
#DEFINE COL_DATA    03
#DEFINE COL_HORA    04

/***********************************************************************************/
/*/{Protheus.doc} MDLOGA02
    @description Recupera status tracking
    @type  Function
    @author Bernard M. Margarido
    @since 07/06/2022
/*/
/***********************************************************************************/
User Function MDLOGA02()
Local   _lRet       := .T.

CoNout("<< MDLOGA02 >> - INICIO " + dTos( Date() ) + " - " + Time() )

Processa({|| _lRet := MDLOGM02A()},"Aguarde...","Recuperando status coleta." )

CoNout("<< MDLOGA02 >> - FIM " + dTos( Date() ) + " - " + Time() )
Return _lRet 

/***********************************************************************************/
/*/{Protheus.doc} MDLOGM02A
    @description Recupera status tracking
    @type  Static Function
    @author Bernard M. Margarido
    @since 07/06/2022
/*/
/***********************************************************************************/
Static Function MDLOGM02A()
Local _aArea	:= GetArea()
Local _aRastreio:= {}

Local _cCodDLog := GetNewPar("DN_CDMDLOG")
Local _cChaveNfe:= ""
Local _cError   := ""

Local _lRet		:= .T.

Local _oDLog	:= DLog():New()
Local _oJSon	:= Nil 
Local _oStatus	:= Nil 
Local _oPnlBtn  := Nil
Local _oPnlGrid := Nil
Local _oDlg     := Nil
Local _oBtnCa   := Nil

//------------------------------------------+
// Valida se transportadora pertence a Dlog |
//------------------------------------------+
If RTrim(WSA->WSA_TRANSP) # RTrim(_cCodDLog)
    MsgStop("Consulta disponivel somente para transportadoras DLOG.","Dana -Avisos!")
    RestArea(_aArea)
    Return .F.
EndIf

//------------------------+
// Posiciona Nota fiscal  |
//------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )
SF2->( dbSeek(xFilial("SF2") + WSA->WSA_DOC + WSA->WSA_SERIE) )
_cChaveNfe := SF2->F2_CHVNFE

//----------------------------+
// Consulta historico entrega |
//----------------------------+
If !MDLogM02B(_cChaveNfe,@_cError,@_aRastreio)
    //MsgStop("Não foi possivel localizar rastreio do pedido " + WSA->WSA_NUMECO + " ." + _cError,"Dana -Avisos!")
    RestArea(_aArea)
    Return .F.
EndIf

_oDlg := TDialog():New(000,000,466,1185,"Dana - Rastreio de Pedido",,,,,,,,,.T.,,,,,,.F.)
    //-----------------------------------------+
	// Nao permite fechar tela teclando no ESC |
	//-----------------------------------------+
	_oDlg:lEscClose := .F.

    //----------------+
    // Painel Browser |
    //----------------+
	_oFwLayer := FwLayer():New()
	_oFwLayer:Init(_oDlg,.F.)

    _oFwLayer:AddLine("BRWCLI",100, .T.)
    _oFWLayer:AddCollumn( "COLBRWCLI"	,090, .T. , "BRWCLI")
    _oFWLayer:AddCollumn( "COLBTNCLI"	,010, .T. , "BRWCLI")
    _oFWLayer:AddWindow( "COLBRWCLI", "WINENT", "Pedido eCommerce " + WSA->WSA_NUMECO, 100, .F., .F., , "BRWCLI")
    _oFWLayer:AddWindow( "COLBTNCLI", "WINENT", "", 100, .F., .F., , "BRWCLI")
    
    _oPanel_01 := _oFWLayer:GetWinPanel("COLBRWCLI","WINENT","BRWCLI")
    _oPanel_02 := _oFWLayer:GetWinPanel("COLBTNCLI","WINENT","BRWCLI")
 
    DEFINE FWBROWSE _oBrowse DATA ARRAY ARRAY _aRastreio NO SEEK NO CONFIG NO REPORT NO LOCATE Of _oPanel_01    
      
        ADD COLUMN _oColumn DATA {|| _aRastreio[_oBrowse:nAt][COL_COD]   	} TITLE "Codigo"        SIZE 06     PICTURE "@!"                            ALIGN 1 OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aRastreio[_oBrowse:nAt][COL_DESC]  	} TITLE "Descricao"	    SIZE 40     PICTURE "@!"                            ALIGN 1 OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aRastreio[_oBrowse:nAt][COL_DATA]     } TITLE "Data" 		    SIZE 08     PICTURE PesqPict("SF2","F2_EMISSAO")    ALIGN 1 OF _oBrowse
        ADD COLUMN _oColumn DATA {|| _aRastreio[_oBrowse:nAt][COL_HORA]  	} TITLE "Hora" 	        SIZE 08     PICTURE ""                              ALIGN 1 OF _oBrowse
        ADD COLUMN _oColumn DATA {|| " " 					   			    } TITLE " " 		    SIZE 01     PICTURE PesqPict("SA1","A1_NOME")       ALIGN 1 OF _oBrowse

        _oBrowse:SetLineHeight(20)
        _oBrowse:DisableConfig()

    ACTIVATE FWBROWSE _oBrowse

    //------+
    // Sair |
    //------+
    _oBtnCa	:= TButton():New( 003, 003 , "Sair", _oPanel_02, {|| _oDlg:End() }	, 040,012,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    _oDlg:lCentered := .T.

_oDlg:Activate()

RestArea(_aArea)
Return _lRet 

/***********************************************************************************/
/*/{Protheus.doc} MDLogM02B
    @description Consulta historico do rastreio 
    @type  Static Function
    @author Bernard M. Margarido
    @since 07/06/2022
/*/
/***********************************************************************************/
Static Function MDLogM02B(_cChaveNfe,_cError,_aRastreio)
Local _lRet     := .F.

Local _nX       := 0 
Local _nY       := 0

Local _oDLog	:= DLog():New()
Local _oJSon	:= Nil 
Local _oStatus	:= Nil 
Local _oRetSta  := Nil 
Local _oTrack   := Nil 

Private _cType  := ""

_oJSon						:= Nil 
_oJSon						:= Array(#)
_oJSon[#"recStatus"]	    := {}
aAdd(_oJSon[#"recStatus"],Array(#))
_oStatus := aTail(_oJSon[#"recStatus"])	
_oStatus[#"nfChave"]	     := _cChaveNfe   
_oStatus[#"allStatusTrack"]  := .T.

//--------------------------+
// Envia Postagem para DLog |
//--------------------------+
_cRest  := EncodeUTF8(xToJson(_oJSon))

_oDLog:cJSon 	:= _cRest 
If _oDLog:StatusLista()
    If ValType(_oDLog:oJSon) <> "U"
        _oRetSta:= _oDLog:oJSon[#"response"][#"responseStatus"]
        //--------------------------------------+    
        // Valida se obteve retorno com sucesso |
        //--------------------------------------+
        If ValType(_oRetSta) == "O"
            _cType  := _oRetSta[#"codSubStatus"] 
            If Type('_cType') <> "U" .And. _oRetSta[#"codSubStatus"] <> 1 
                MsgInfo(_oRetSta[#"descrSubStatus"],"Dana - Avisos")
            ElseIf Type('_cType') <> "U" .And. _oRetSta[#"codSubStatus"] == 1 
                _lRet   := .T.
                _oTrack := _oRetSta[#"status"]
                For _nX := 1 To Len(_oTrack)
                    
                    aAdd(_aRastreio,Array(4))

                    _aRastreio[Len(_aRastreio)][COL_COD]    := _oTrack[_nX][#"codStatusTrack"]
                    _aRastreio[Len(_aRastreio)][COL_DESC]   := _oTrack[_nX][#"descrStatusTrack"]
                    _aRastreio[Len(_aRastreio)][COL_DATA]   := dToc(StoD(StrTran(_oTrack[_nX][#"dataStatusTrack"],"-","")))
                    _aRastreio[Len(_aRastreio)][COL_HORA]   := SUbStr(_oTrack[_nX][#"dataStatusTrack"],At("T",_oTrack[_nX][#"dataStatusTrack"]) + 1)

                Next _nX 
            EndIf
        ElseIf ValType(_oRetSta) == "A"
            For _nX := 1 To Len(_oRetSta)
                _cType  := _oRetSta[_nX][#"codSubStatus"] 
                If Type('_cType') <> "U" .And. _oRetSta[_nX][#"codSubStatus"] <> 1 
                    MsgInfo(_oRetSta[_nX][#"descrSubStatus"],"Dana - Avisos")
                ElseIf Type('_cType') <> "U" .And. _oRetSta[_nX][#"codSubStatus"] == 1 
                    _lRet   := .T.
                    _oTrack := _oRetSta[_nX][#"status"]
                    For _nY := 1 To Len(_oTrack)
                        
                        aAdd(_aRastreio,Array(4))

                        _aRastreio[Len(_aRastreio)][COL_COD]    := _oTrack[_nY][#"codStatusTrack"]
                        _aRastreio[Len(_aRastreio)][COL_DESC]   := _oTrack[_nY][#"descrStatusTrack"]
                        _aRastreio[Len(_aRastreio)][COL_DATA]   := dToc(StoD(StrTran(_oTrack[_nY][#"dataStatusTrack"],"-","")))
                        _aRastreio[Len(_aRastreio)][COL_HORA]   := SUbStr(_oTrack[_nY][#"dataStatusTrack"],At("T",_oTrack[_nY][#"dataStatusTrack"]) + 1)

                    Next _nY 
                EndIf
            Next _nX
        EndIf
    EndIf
EndIf

Return _lRet 
