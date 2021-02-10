#INCLUDE 'PROTHEUS.CH'

/******************************************************************************/
/*/{Protheus.doc} LOGXWMS
@description Classe realiza a gravação dos LOGS 
@author    Bernard M. Margarido
@since     22/10/2019
/*/
/******************************************************************************/
Class LOGXWMS 
    
    Data _cId       As String
    Data _cPedido   As String
    Data _cTipo     As String
    Data _cNota     As String
    Data _cSerie    As String
    Data _cCodSta   As String
    Data _cDescSta  As String
    Data _cCodStaF  As String
    Data _cDescStaF As String
    Data _dDtaIni   As Date
    Data _cHrIni    As String
    Data _dDtaAlt   As Date
    Data _cHrAlt    As String
    Data _cLog      As String
    Data _nMaster   As Integer
    Data _nSlave    As Integer

	Method new()    Constructor
    Method GetID()
    Method GetCodMaster()
    Method GetCodSlave()
    Method GetLog() 
    Method GrvLog()

EndClass

/******************************************************************************/
/*/{Protheus.doc} new
@description Metodo construtor
@author    Bernard M. Margarido
@since     22/10/2019
/*/
/******************************************************************************/
Method new() Class LOGXWMS
    ::_cId      := ""
    ::_cPedido  := ""
    ::_cTipo    := ""
    ::_cNota    := ""
    ::_cSerie   := ""
    ::_cCodSta  := ""
    ::_cDescSta := ""
    ::_dDtaIni  := Date()
    ::_cHrIni   := Time()
    ::_dDtaAlt  := Date()
    ::_cHrAlt   := Time()
    ::_cLog     := ""
Return Nil

/******************************************************************************/
/*/{Protheus.doc} new
@description Metodo GetId - ID LOG
@author    Bernard M. Margarido
@since     22/10/2019
/*/
/******************************************************************************/
Method GrvLog() Class LOGXWMS
Local _aArea    := GetArea()
Local _lGrava   := .T.
Local _lRet     := .T.

//-----------+
// Valida ID |
//-----------+
::GetID()

//----------------------+
// Valida Codigo Master |
//----------------------+
::GetCodMaster()

//---------------------+
// Valida Codigo Filho |
//---------------------+
::GetCodSlave()

//--------------+
// Posiciona ID | 
//--------------+
dbSelectArea("ZZA")
ZZA->( dbSetOrder(1) )

If ZZA->( dbSeek(FwFilial("ZZA") + ::_cTipo + ::_cId))
    _lGrava := .F.
EndIf

//-----------+
// Grava ZZA |
//-----------+
RecLock("ZZA",_lGrava)
    ZZA->ZZA_FILIAL := FwFilial("ZZA")
    ZZA->ZZA_IDINTR := IIF(_lGrava,::_cId,ZZA->ZZA_IDINTR)
    ZZA->ZZA_TIPO   := IIF(_lGrava,::_cTipo,ZZA->ZZA_TIPO)
    ZZA->ZZA_PEDIDO := IIF(_lGrava,::_cPedido,ZZA->ZZA_PEDIDO)
    ZZA->ZZA_NOTA   := ::_cNota
    ZZA->ZZA_SERIE  := ::_cSerie
    ZZA->ZZA_CODSTA := ::_cCodSta
    ZZA->ZZA_DESCST := ::_cDescSta
    ZZA->ZZA_DTINI  := IIF(_lGrava,::_dDtaIni,ZZA->ZZA_DTINI)
    ZZA->ZZA_HRINI  := IIF(_lGrava,::_cHrIni,ZZA->ZZA_HRINI)
    ZZA->ZZA_DTALT  := ::_dDtaAlt
    ZZA->ZZA_HRALT  := ::_cHrAlt
ZZA->( MsUnLock() )

//-----------+
// Grava ZZB |
//-----------+
RecLock("ZZB",.T.)
    ZZB->ZZB_FILIAL := FwFilial("ZZB")
    ZZB->ZZB_IDINTE := ::_cId
    ZZB->ZZB_CODSTA := ::_cCodStaF
    ZZB->ZZB_DESCST := ::_cDescStaF
    ZZB->ZZB_LOG    := ::_cLog
ZZB->( MsUnLock() )

RestArea(_aArea)
Return _lRet

/******************************************************************************/
/*/{Protheus.doc} new
@description Metodo GetId - ID LOG
@author    Bernard M. Margarido
@since     22/10/2019
/*/
/******************************************************************************/
Method GetID() Class LOGXWMS

//-----------+    
// Valida ID | 
//-----------+
::GetLog()

//--------------+
// Posiciona ID | 
//--------------+
dbSelectArea("ZZA")
ZZA->( dbSetOrder(1) )

If Empty(::_cId)
    ::_cId := GetSxeNum("ZZA","ZZA_IDINTR")
    While ZZA->( dbSeek(FwFilial("ZZA") + ::_cId) )
        ConfirmSx8()
        ::_cId := GetSxeNum("ZZA","ZZA_IDINTR","",1)
    EndDo
EndIf

Return Nil

/******************************************************************************/
/*/{Protheus.doc} GetLog
@description Metodo GetLog - Valida se já existe LOG
@author    Bernard M. Margarido
@since     22/10/2019
/*/
/******************************************************************************/
Method GetLog() Class LOGXWMS
Local _cAlias   := GetNextAlias()
Local _cQuery   := ""

_cQuery   := " SELECT " + CRLF
_cQuery   += "      ZZA.ZZA_IDINTR " + CRLF
_cQuery   += " FROM " + CRLF
_cQuery   += "      " + RetSqlName("ZZA") + " ZZA " + CRLF 
_cQuery   += " WHERE " + CRLF
_cQuery   += "      ZZA.ZZA_FILIAL = '" + FwFilial("ZZA") + "' AND " + CRLF

If !Empty(::_cPedido)
    _cQuery   += "      ZZA.ZZA_PEDIDO = '" + ::_cPedido + "' AND " + CRLF
EndIf

If !Empty(::_cNota) .And. !Empty(::_cSerie)    
    _cQuery   += "      ZZA.ZZA_NOTA = '" + ::_cNota + "' AND " + CRLF
    _cQuery   += "      ZZA.ZZA_SERIE = '" + ::_cSerie + "' AND " + CRLF
EndIf    

_cQuery   += "      ZZA.ZZA_TIPO = '" + ::_cTipo + "' AND " + CRLF
_cQuery   += "      ZZA.D_E_L_E_T_ = '' " + CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.) 

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .T. 
EndIf

::_cId := (_cAlias)->ZZA_IDINTR

Return .T.

/******************************************************************************/
/*/{Protheus.doc} GetCodMaster
@description Metodo GetCodMaster - Retorna Status Master Atual
@author    Bernard M. Margarido
@since     22/10/2019
/*/
/******************************************************************************/
Method GetCodMaster() Class LOGXWMS

::_cCodSta := ""
::_cDescSta:= ""

//------------------------------+
// Tabela de Codigo Master      |
// 01 - Aguardando separação    |
// 02 - Embalado                |
// 03 - Faturado                |
//------------------------------+
If ::_nMaster == 1
    ::_cCodSta := "01"
    ::_cDescSta:= "Aguardando Separacao"
ElseIf ::_nMaster == 2
    ::_cCodSta := "02"
    ::_cDescSta:= "Embalado"
ElseIf ::_nMaster == 3
    ::_cCodSta := "03"
    ::_cDescSta:= "Faturado"
EndIf

Return .T.

/******************************************************************************/
/*/{Protheus.doc} GetCodSlave
@description Metodo GetCodSlave - Retorna Status Filho
@author    Bernard M. Margarido
@since     22/10/2019
/*/
/******************************************************************************/
Method GetCodSlave() Class LOGXWMS

::_cCodStaF     := ""
::_cDescStaF    := ""

//------------------------------------------------------+
// Tabela de Codigo Filho                               |
// 01 - Enviado para o WMS                              |
// 02 - Recebido pelo WMS                               |
// 03 - Separado/Recebido pelo WMS                      |
// 04 - Separado/Recebido pelo WMS com divergencia      |
// 05 - Nota de Entrada Recebida                        |
// 06 - Saldo - Eliminado residuo                       |
// 07 - Saldo - Eliminado residuo com Pedido            |
// 08 - Faturado                                        |
//------------------------------------------------------+
If ::_nSlave == 1
    ::_cCodStaF := "01"
    ::_cDescStaF:= "Enviado para o WMS"
ElseIf ::_nSlave == 2
    ::_cCodStaF := "02"
    ::_cDescStaF:= "Recebido pelo WMS"
ElseIf ::_nSlave == 3
    ::_cCodStaF := "03"
    ::_cDescStaF:= "Separado/Recebido pelo WMS"
ElseIf ::_nSlave == 4
    ::_cCodStaF := "04"
    ::_cDescStaF:= "Separado/Recebido pelo WMS com divergencia"
ElseIf ::_nSlave == 5 
    ::_cCodStaF := "05"
    ::_cDescStaF:= "Nota de Entrada Classificada"
ElseIf ::_nSlave == 6
    ::_cCodStaF := "06"
    ::_cDescStaF:= "Saldo - Eliminado residuo"
ElseIf ::_nSlave == 7
    ::_cCodStaF := "07"
    ::_cDescStaF:= "Saldo - Eliminado residuo com Pedido "
ElseIf ::_nSlave == 8
    ::_cCodStaF := "08"
    ::_cDescStaF:= "Faturado "
EndIf

Return .T.

User Function LogXWms()
Local _oLogWms  := LogXWms():New

Local _cPedido  := "000001"
Local _cTipo    := "S"
Local _cLog     := "Teste Classe WMS 02"

Local _nMaster  := 1
Local _nSlave   := 2

_oLogWms:_cPedido   := _cPedido
_oLogWms:_cTipo     := _cTipo
_oLogWms:_cLog      := _cLog
_oLogWms:_nMaster   := _nMaster
_oLogWms:_nSlave    := _nSlave

_oLogWms:GrvLog()

Return .T.