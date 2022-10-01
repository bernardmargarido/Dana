#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF            CHR(13) + CHR(10)

Static _nTSerie     := TamSx3("F2_SERIE")[1]
Static _nTDoc       := TamSx3("F2_DOC")[1]

/****************************************************************************************/
/*/{Protheus.doc} MDLog
    @description Classe utilizada para integração MDTransLog
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Class MDLog 

    Data cUser          As String 
    Data cPassDlog      As String 
    Data cToken         As String 
    Data cUrl           As String 
    Data cJSon          As String 
    Data cJSonRet       As String 
    Data cCodigo        As String
    Data cPassword	    As String
	Data cCertPath	    As String
	Data cKeyPath		As String
	Data cCACertPath	As String
    Data cError         As String 

    Data nSSL2		    As Integer
	Data nSSL3		    As Integer
	Data nTLS1		    As Integer
	Data nHSM		    As Integer
	Data nVerbose	    As Integer
	Data nBugs		    As Integer
	Data nState	        As Integer

    Data aNotas         As Array 
    Data aHeadOut       As Array

    Data oJSon          As Object 
    Data oFwRest        As Object

    Method New() Constructor
    Method GetSSLCache()
    Method GravaLista()
    Method GeraLista() 
    Method StatusLista()
    Method ClearObj() 

End Class

/****************************************************************************************/
/*/{Protheus.doc} New
    @description Método construtor da classe 
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Method New() Class MDLog

    ::cUser         := GetNewPar("DN_MDLGUSE","")
    ::cPassDlog     := GetNewPar("DN_MDLGPAS","kksmdtras01ksa")
    ::cToken        := GetNewPar("DN_MDLGTOK","")
    ::cUrl          := GetNewPar("DN_MDLGURL","http://mdtranslog.sinclog.com.br")
    ::cJSon         := ""
    ::cJSonRet      := ""
    ::cCodigo       := ""
    ::cPassword	    := ""
	::cCertPath	    := "" 
	::cKeyPath		:= "" 
	::cCACertPath	:= ""
    ::cError        := ""

    ::nSSL2		    := 1
	::nSSL3		    := 1
	::nTLS1		    := 1
	::nHSM		    := 1
	::nVerbose	    := 1
	::nBugs		    := 1
	::nState	    := 1

    ::aNotas        := {}
    ::aHeadOut      := {}

    ::oJSon         := Nil 
    ::oFwRest       := Nil 

Return Nil 

/****************************************************************************************/
/*/{Protheus.doc} GetSSLCache
@description Define o uso em memoria da configuração SSL para integrações SIGEP
@author Bernard M. Margarido
@since 06/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Method GetSSLCache() Class MDLog
Local _lRet 	:= .F.

//-------------------------------------+
// Utiliza configurações SSL via Cache |
//-------------------------------------+
If HTTPSSLClient( ::nSSL2, ::nSSL3, ::nTLS1, ::cPassword, ::cCertPath, ::cKeyPath, ::nHSM, .F. , ::nVerbose, ::nBugs, ::nState)
	_lRet := .T.
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} GravaLista
    @description Método - Grava lista de postagem
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Method GravaLista() Class MDLog
Local _aArea    := GetArea() 

Local _cNumID   := ""

Local _nX       := 0

Local _lRet     := .T.

//----------------------+
// ZZB - Postagens DLog |
//----------------------+
dbSelectArea("ZZB")
ZZB->( dbSetOrder(1) )

//------------------+
// ZZC - Itens DLog |
//------------------+
dbSelectArea("ZZC")
ZZC->( dbSetOrder(1) )

//-------------------------------------------+
// Inicia gravação da lista de postagem DLog | 
//-------------------------------------------+
_cNumID := GetSxeNum("ZZB","ZZB_CODIGO")
While ZZB->( dbSeek(xFilial("ZZB") + _cNumID) )
    _cNumID := GetSxeNum("ZZB","ZZB_CODIGO",,"1")
EndDo

//-----------------+
// Grava cabeçalho |
//-----------------+
RecLock("ZZB",.T.)
    ZZB->ZZB_FILIAL := xFilial("ZZB")
    ZZB->ZZB_CODIGO := _cNumID
    ZZB->ZZB_DATA   := dDataBase
    ZZB->ZZB_HORA   := Time()
    ZZB->ZZB_JSON   := ""
    ZZB->ZZB_STATUS := "1"
ZZB->( MsUnLock() )

//----------------------+
// Grava itens postagem |
//----------------------+
For _nX := 1 To Len(::aNotas)
    RecLock("ZZC",.T.)
        ZZC->ZZC_FILIAL := xFilial("ZZB")
        ZZC->ZZC_CODIGO := _cNumID
        ZZC->ZZC_ITEM   := StrZero(_nX,2)
        ZZC->ZZC_NOTA   := ::aNotas[_nX][1]
        ZZC->ZZC_SERIE  := ::aNotas[_nX][2]
        ZZC->ZZC_NUMECO := ::aNotas[_nX][3]
        ZZC->ZZC_NUMECL := ::aNotas[_nX][4]
        ZZC->ZZC_NUMSC5 := ::aNotas[_nX][5]
        ZZC->ZZC_JSON   := ""
        ZZC->ZZC_STATUS := "1"
    ZZC->( MsUnLock() )
Next _nX 

RestArea(_aArea)
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} GeraLista
    @description Método - Gera lista de postagem 
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Method GeraLista() Class MDLog
Local _lRet         := .T.
Local _lStatus      := .T.

Local _cMemoRest    := ""
Local _cIdInterno   := ""
Local _cIdGerada    := ""
Local _cNumEco      := ""

Local _nX           := 0

Local _oNotas       := Nil 

//---------------+
// Posiciona ZZB |
//---------------+
dbSelectArea("ZZB")
ZZB->( dbSetOrder(1) )
ZZB->( dbSeek(xFilial("ZZB") + ::cCodigo ) )

//---------------+
// Posiciona ZZC |
//---------------+
dbSelectArea("ZZC")
ZZC->( dbSetOrder(2) )

//---------------+
// Posiciona WSA |
//---------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )

//-----------------+
// Roda URL em SSL | 
//-----------------+
::GetSSLCache()

::aHeadOut  := {}
aAdd(::aHeadOut,"Content-Type: application/json")
aAdd(::aHeadOut,"Authorization:Bearer " + RTrim(::cPassDlog))

//-------------------------+
// Instancia classe FwRest |
//-------------------------+
::oFwRest   := FWRest():New(::cUrl)

//---------------------+
// TimeOut do processo |
//---------------------+
::oFwRest:nTimeOut := 600

::oFwRest:SetPath("/Api/Solicitacoes/RegistrarNovaSolicitacao")
::oFwRest:SetPostParams(EncodeUtf8(::cJSon))

//-----------------+
// Envia categoria |
//-----------------+
If ::oFwRest:Post(::aHeadOut)
    ::cJSonRet	:= DecodeUtf8(::oFwRest:GetResult())
    ::oJSon	    := xFromJson(::cJSonRet)

    If ValType(::oJSon) <> "U" 
        If !::oJSon[#"erro"] 
            //-----------------------+
            // Grava JSON de retorno | 
            //-----------------------+
            _oNotas    := ::oJSon[#"resultados"]
            For _nX := 1 To Len(_oNotas)
                _cIdInterno := _oNotas[_nX][#"idSolicitacaoInterno"]
                _cIdGerada  := _oNotas[_nX][#"idSolicitacaoGerada"]
                _oVolumes   := _oNotas[_nX][#"listaVolumes"]

                //-----------------------------------------+
                // Grava informações nos itens da postagem | 
                //-----------------------------------------+
                If ZZC->( dbSeek(xFilial("ZZC") + ::cCodigo + Padr(SubStr(_cIdInterno,1,6),_nTDoc) + PadR(SubStr(_cIdInterno,7,2),_nTSerie)))
                    _cNumEco    := ZZC->ZZC_NUMECO

                    _oResp                          := Nil 
                    _oResp                          := Array(#)
                    _oResp[#"idSolicitacaoInterno"] := _cIdInterno
                    _oResp[#"idSolicitacaoGerada"]  := _cIdGerada
                    _oResp[#"listaVolumes"]         := _oVolumes
                    _oResp[#"linkRastreamento"]     := "https://mdtranslog.uxsolutions.com.br/TrackingFilter/MQA5ADQAMwA4ADYANQA=/P/" + Rtrim(ZZC->ZZC_NUMSC5)
                    _cMemoRest  := EncodeUTF8(xToJson(_oResp))
                    _lStatus    := .T.

                    RecLock("ZZC",.F.)
                        ZZC->ZZC_JSON   := _cMemoRest
                        ZZC->ZZC_STATUS := IIF(_lStatus,"2","3")
                    ZZC->( MsUnLock() )

                    //-----------------------------------+    
                    // Atualiza status pedido e-Commerce |
                    //-----------------------------------+
                    If WSA->( dbSeek(xFilial("WSA") + _cNumEco) )
                        RecLock("WSA",.F.)
                            WSA->WSA_ENVLOG := "4"
                            WSA->WSA_CODSTA := "005"
                            WSA->WSA_DESTAT := Posicione("WS1",1,xFilial("WS1") + "005","WS1_DESCRI")
                        WSA->( MsUnLock() )
                    EndIf
                EndIf
            Next _nX 
            
            //-----------------------+
            // Atualiza JSON enviado |
            //-----------------------+
            RecLock("ZZB",.F.)
                ZZB->ZZB_JSON   := ::cJSon
                ZZB->ZZB_STATUS := IIF(_lStatus,"2","3")
            ZZB->( MsUnLock() )
        Else 
            _lRet       := .F.
            ::cError    := ::oJSon[#"mensagem"] + CRLF

            If ValType(::oJSon[#"errosDetalhes"]) <> "U" .And. Len(::oJSon[#"errosDetalhes"]) > 0 
                For _nX := 1 To Len(::oJSon[#"errosDetalhes"])
                    ::cError += cValToChar(::oJSon[#"errosDetalhes"][_nX][#"code"]) + " "
                    ::cError += AllTrim(::oJSon[#"errosDetalhes"][_nX][#"descricao"]) + " "
                    ::cError += AllTrim(::oJSon[#"errosDetalhes"][_nX][#"info"][#"idSolicitacaoInterno"]) + "||"
                    _cIdInterno := ::oJSon[#"errosDetalhes"][_nX][#"info"][#"idSolicitacaoInterno"] 
                Next _nX 
            EndIf 
            //-----------------------------------------+
            // Grava informações nos itens da postagem | 
            //-----------------------------------------+
            If ZZC->( dbSeek(xFilial("ZZC") + ::cCodigo + Padr(SubStr(_cIdInterno,1,6),_nTDoc) + PadR(SubStr(_cIdInterno,7,2),_nTSerie)))
                _cNumEco    := ZZC->ZZC_NUMECO
                RecLock("ZZC",.F.)
                    ZZC->ZZC_JSON   := ::cError
                    ZZC->ZZC_STATUS := "3"
                ZZC->( MsUnLock() )
                
            EndIf
            
            //-----------------------+
            // Atualiza JSON enviado |
            //-----------------------+
            RecLock("ZZB",.F.)
                ZZB->ZZB_JSON   := ::cJSon
                ZZB->ZZB_STATUS := "3"
            ZZB->( MsUnLock() )

        EndIf 
    EndIf
Else
    //---------------------------+
    // Erro no envio da gravação |
    //---------------------------+
    If ValType(::oFwRest:GetResult()) <> "U"
        ::cJSonRet	:= DecodeUtf8(::oFwRest:GetResult())
        ::oJSon	    := xFromJson(::cJSonRet)

        If ValType(::oJSon) <> "U" 
            If ::oJSon[#"erro"]
                _lRet       := .F.
                ::cError    := ::oJSon[#"mensagem"] + CRLF

                If ValType(::oJSon[#"errosDetalhes"]) <> "U" .And. Len(::oJSon[#"errosDetalhes"]) > 0 
                    For _nX := 1 To Len(::oJSon[#"errosDetalhes"])
                        ::cError += cValToChar(::oJSon[#"errosDetalhes"][_nX][#"code"]) + " "
                        ::cError += AllTrim(::oJSon[#"errosDetalhes"][_nX][#"descricao"]) + " "
                        ::cError += AllTrim(::oJSon[#"errosDetalhes"][_nX][#"info"][#"idSolicitacaoInterno"]) + "||"
                        _cIdInterno := ::oJSon[#"errosDetalhes"][_nX][#"info"][#"idSolicitacaoInterno"] 
                    Next _nX 
                EndIf 
                //-----------------------------------------+
                // Grava informações nos itens da postagem | 
                //-----------------------------------------+
                If ZZC->( dbSeek(xFilial("ZZC") + ::cCodigo + Padr(SubStr(_cIdInterno,1,6),_nTDoc) + PadR(SubStr(_cIdInterno,7,2),_nTSerie)))
                    _cNumEco    := ZZC->ZZC_NUMECO
                    RecLock("ZZC",.F.)
                        ZZC->ZZC_JSON   := ::cError
                        ZZC->ZZC_STATUS := "3"
                    ZZC->( MsUnLock() )
                EndIf
            
                //-----------------------+
                // Atualiza JSON enviado |
                //-----------------------+
                RecLock("ZZB",.F.)
                    ZZB->ZZB_JSON   := ::cJSon
                    ZZB->ZZB_STATUS := "3"
                ZZB->( MsUnLock() )

            Else
                _lRet       := .F.
                ::cError    := "Erro ao enviar coleta MDTransLog."
            EndIf 
        Else
            _lRet       := .F.
            ::cError    := "Erro ao enviar coleta MDTransLog."
        EndIf
    Else
        _lRet       := .F.
        ::cError    := "Erro ao enviar coleta MDTransLog."
    EndIf
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} StatusLista
    @description Método - Consulta status da lista de postagem  
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Method StatusLista() Class MDLog
Local _lRet         := .T.

//-----------------+
// Roda URL em SSL | 
//-----------------+
::GetSSLCache()

::aHeadOut  := {}
aAdd(::aHeadOut,"Content-Type: application/json")
aAdd(::aHeadOut,"Clie-Cod: " + RTrim(::cUser))
aAdd(::aHeadOut,"Login: " + RTrim(::cPassDlog))
aAdd(::aHeadOut,"Token: " + RTrim(::cToken))

//-------------------------+
// Instancia classe FwRest |
//-------------------------+
::oFwRest   := FWRest():New(::cUrl)

//---------------------+
// TimeOut do processo |
//---------------------+
::oFwRest:nTimeOut := 600

::oFwRest:SetPath("/RecuperarStatus/")
::oFwRest:SetPostParams(EncodeUtf8(::cJSon))

//-----------------+
// Envia categoria |
//-----------------+
If ::oFwRest:Post(::aHeadOut)
    ::cJSonRet	:= DecodeUtf8(::oFwRest:GetResult())
    ::oJSon	    := xFromJson(::cJSonRet)
    _lRet       := .T.
Else
    //---------------------------+
    // Erro no envio da gravação |
    //---------------------------+
    If ValType(::oFwRest:GetResult()) <> "U"
        ::cJSonRet	:= DecodeUtf8(::oFwRest:GetResult())
        ::oJSon	    := xFromJson(::cJSonRet)

        If ValType(::oJSon) <> "U"
            _lRet       := .F.
            ::cError    := "Erro ao enviar postagem DLog."
        Else
            _lRet       := .F.
            ::cError    := "Erro ao enviar postagem DLog."
        EndIf
    Else
        _lRet       := .F.
        ::cError    := "Erro ao enviar postagem DLog."
    EndIf
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} ClearObj
    @description Método - Limpa objeto da classe  
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Method ClearObj(oObj) Class MDLog
Return FreeObj(oObj)
