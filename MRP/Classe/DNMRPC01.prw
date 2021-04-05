#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*******************************************************************************/
/*/{Protheus.doc} DNMRPC01
    @description Classe criar codigo e loja 
    @author    Bernard M. Margarido
    @since     22/06/2020
/*/
/*******************************************************************************/
Class DNMRPC01

    Data _cCGC      AS String
    Data _cCodigo   AS String
    Data _cLoja     AS String
    Data _cAlias    AS String

    Method New() Constructor 
    Method SetCodLoja()
    Method GetCgc()

End Class

/*******************************************************************************/
/*/{Protheus.doc} New
    @description Método contrutor da classe 
    @author    Bernard M. Margarido
    @since     22/06/2020
/*/
/*******************************************************************************/
Method New() Class DNMRPC01

    ::_cCGC     := ""
    ::_cCodigo  := ""
    ::_cLoja    := ""
    ::_cAlias   := "SA1"
    
Return .T.

/*******************************************************************************/
/*/{Protheus.doc} SetCodigo
    @description Retorna codigo e loja
    @author    Bernard M. Margarido
    @since     22/06/2020
/*/
/*******************************************************************************/
Method SetCodLoja() Class DNMRPC01
Local _aArea    := GetArea()

//-----------------+
// Valida CPF/CNPJ |
//-----------------+
dbSelectArea(::_cAlias)
(::_cAlias)->( dbSetOrder(3) )
If (::_cAlias)->( dbSeek(xFilial(::_cAlias) + ::_cCGC ) )
    ::_cCodigo  := IIF(::_cAlias == "SA1", (::_cAlias)->A1_COD, (::_cAlias)->A2_COD)
    ::_cLoja    := IIF(::_cAlias == "SA1", (::_cAlias)->A1_LOJA, (::_cAlias)->A2_LOJA)
Else
    ::GetCgc()
EndIf

RestArea(_aArea)
Return .T.

/*******************************************************************************/
/*/{Protheus.doc} GetCgc
    @description Valida CPF/CNPJ  
    @author    Bernard M. Margarido
    @since     22/06/2020
/*/
/*******************************************************************************/
Method GetCgc() Class DNMRPC01
Local _cCodNew  := ""
Local _cLojaNew := IIF(::_cAlias == "SA1",PadL("1",TamSx3("A1_LOJA")[1],"0"),PadL("1",TamSx3("A2_LOJA")[1],"0"))

//---------------------------+
// Valida se é pessoa Fisica | 
//---------------------------+  
If Len(RTrim(::_cCGC)) <= 11
    dbSelectArea(::_cAlias)
    (::_cAlias)->( dbSetOrder(1) )

    _cCodNew := IIF(::_cAlias == "SA1",GetSxeNum("SA1","A1_COD"),GetSxeNum("SA2","A2_COD"))
    While (::_cAlias)->( dbSeek(xFilial(::_cAlias) + _cCodNew + _cLojaNew ) )
        ConfirmSx8()
        _cCodNew := IIF(::_cAlias == "SA1",GetSxeNum("SA1","A1_COD","",1),GetSxeNum("SA2","A2_COD","",1))
    EndDo
//-----------------+
// Pessoa Juridica | 
//-----------------+
Else
    //--------------------------+
    // Posiciona CNPJ pela raiz |
    //--------------------------+
    dbSelectArea(::_cAlias)
    (::_cAlias)->( dbSetOrder(3) )
    If (::_cAlias)->( dbSeek(xFilial(::_cAlias) + SubStr(::_cCGC,1,8) ) )
        
        _cCodNew    := IIF(::_cAlias == "SA1",(::_cAlias)->A1_COD,(::_cAlias)->A2_COD)
        
        dbSelectArea(::_cAlias)
        (::_cAlias)->( dbSetOrder(1) )
        While (::_cAlias)->( dbSeek(xFilial(::_cAlias) + _cCodNew + _cLojaNew ) )
            ConfirmSx8()
            _cLojaNew := Soma1(_cLojaNew)
        EndDo
    Else
        dbSelectArea(::_cAlias)
        (::_cAlias)->( dbSetOrder(1) )

        _cCodNew := IIF(::_cAlias == "SA1",GetSxeNum("SA1","A1_COD"),GetSxeNum("SA2","A2_COD"))
        While (::_cAlias)->( dbSeek(xFilial(::_cAlias) + _cCodNew + _cLojaNew ) )
            ConfirmSx8()
            _cCodNew := IIF(::_cAlias == "SA1",GetSxeNum("SA1","A1_COD","",1),GetSxeNum("SA2","A2_COD","",1))
        EndDo

    EndIf
EndIf

::_cCodigo  := _cCodNew
::_cLoja    := _cLojaNew

Return .T.