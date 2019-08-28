#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*****************************************************************************************/
/*/{Protheus.doc} SaldoIni
    @description Cria saldo inicial para o aramzem de eCommerce
    @type  Function
    @author Bernard M. Margarido
    @since 27/08/2019
    @version version
/*/
/*****************************************************************************************/
User Function SaldoIni()
Private _oProcess   := Nil

    _oProcess:= MsNewProcess():New( {|lEnd| ProcSaldo(@lEnd)},"Aguarde...","Consultando Saldos" )
	_oProcess:Activate()


Return Nil

/*****************************************************************************************/
/*/{Protheus.doc} ProcSaldo
    @description Consulta produtos e-Commerce
    @type  Function
    @author Bernard M. Margarido
    @since 27/08/2019
    @version version
/*/
/*****************************************************************************************/
Static Function ProcSaldo(lEnd)
Local _cAlias   := GetNextAlias()

Private _cMsg   := ""

If !SaldoQry(_cAlias,@_nToReg)
    MsgStop("Não foram encontrados dados para serem processados.","Aviso")
    Return Nil
EndIf

_oProcess:SetRegua1( _nToReg )
While (_cAlias)->( !Eof () )

    _oProcess:IncRegua1("Produto " + RTrim((_cAlias)->B5_COD) )

    //--------------------+
    // Cria saldo inicial | 
    //--------------------+
    GrvSaldoIni((_cAlias)->B5_COD)

    (_cAlias)->( dbSkip() )
EndDo

(_cAlias)->( dbCloseArea() )

If !Empty(_cMsg)
    Aviso("Saldo inicial",_cMsg,{"OK"})
EndIf

Return Nil

/*****************************************************************************************/
/*/{Protheus.doc} GrvSaldoIni
    @description Cria saldo inicial 
    @type  Function
    @author Bernard M. Margarido
    @since 27/08/2019
    @version version
/*/
/*****************************************************************************************/
Static Function GrvSaldoIni(_cCodProd)
Local _aArea        := GetArea()

Local _cLocal       := "50"

Local _nQtdIni      := 100

Local _aSldIni      := {}

Private lMsErroAuto := .F.

_oProcess:SetRegua2( -1 )

//------------------------------+
// Cria armazem caso nao exista | 
//------------------------------+
dbSelectArea("SB2")
SB2->( dbSetorder(1) )
If !SB2->( dbSeek(xFilial("SB2") + _cCodProd + _cLocal) )
    CriaSb2(_cCodProd,_cLocal)
EndIf

aAdd(_aSldIni, {"B9_FILIAL" , xFilial("SB9")			, Nil })
aAdd(_aSldIni, {"B9_COD"	, _cCodProd	                , Nil })
aAdd(_aSldIni, {"B9_LOCAL"	, _cLocal	                , Nil })
aAdd(_aSldIni, {"B9_DATA"	, CTOD('')	                , Nil })
aAdd(_aSldIni, {"B9_QINI"	, _nQtdIni	                , Nil })

_oProcess:IncRegua2("Criando Saldo inicial produto " + RTrim(_cCodProd)  )

lMsErroAuto := .F.

MsExecAuto({|x,y| MATA220(x,y)}, _aSldIni, 3)

If lMsErroAuto
    
    _cArqErrAuto := NomeAutoLog()
	_cErrAuto    := Memoread(_cArqErrAuto)
    Ferase(_cArqErrAuto)

    _cMsg        += "[ ERRO SALDO INICIAL PRODUTO " +  _cCodProd + " ERRO: " + _cErrAuto + CRLF
EndIf

RestArea(_aArea)
Return Nil

/*****************************************************************************************/
/*/{Protheus.doc} SaldoQry
    @description Consulta produtos e-Commerce
    @type  Function
    @author Bernard M. Margarido
    @since 27/08/2019
    @version version
/*/
/*****************************************************************************************/
Static Function SaldoQry(_cAlias,_nToReg)
Local _cQuery := ""

_cQuery := "SELECT " + CRLF
_cQuery += " 	B5.B5_COD, " + CRLF
_cQuery += "	B5.R_E_C_N_O_ RECNOSB5 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	    " + RetSqlName("SB5") +  " B5 " + CRLF 
_cQuery += " WHERE " + CRLF
_cQuery += "	    B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF 
_cQuery += "	    B5.B5_XUSAECO = 'S' AND " + CRLF
_cQuery += "	    B5.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg  

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.