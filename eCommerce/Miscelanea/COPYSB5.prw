#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*************************************************************************************/
/*/{Protheus.doc} COPYSB5
    @description Realiza a copia dos produtos e-Commerce
    @type  Function
    @author Bernard M Margarido
    @since 07/07/2023
    @version version
/*/
/*************************************************************************************/
User Function COPYSB5()
Local _aArea    := GetArea()
Local _aStruct  := SB5->( dbStruct() )
Local _aDadosB5 := {}

Local _nX       := 0 

Local _cQuery   := ""
Local _cAlias   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	B5.R_E_C_N_O_ RECNOSB5, " + CRLF
_cQuery += "	B1.R_E_C_N_O_ RECNOSB1 " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SB5") + " B5 " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = B5.B5_FILIAL AND B1.B1_COD = B5.B5_COD AND B1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	B5.B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF
_cQuery += "	B5.B5_XUSAECO = 'S' AND " + CRLF
_cQuery += "	B5.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

//-----------------------------------------+
// SB5 - Posiciona Complemento de Produtos |
//-----------------------------------------+
dbSelectArea("SB5")
SB5->( dbSetOrder(1) )

//--------------------------+
// SB1 - Posiciona Produtos |
//--------------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

While (_cAlias)->( !Eof() )

    //--------------------------+
    // SB5 - Posiciona registro |
    //--------------------------+
    SB5->( dbGoTo((_cAlias)->RECNOSB5) )

    //--------------------------+
    // SB1 - Posiciona registro |
    //--------------------------+
    SB1->( dbGoTo((_cAlias)->RECNOSB1) )

    _aDadosB5 := {}
    _cCodProd := SB5->B5_COD

    For _nX := 1 To Len(_aStruct)
        aAdd(_aDadosB5,{_aStruct[_nX][1], &('SB5->'+AllTrim(_aStruct[_nX][1]))})
    Next _nX 
        
    //--------------+
    // Atualiza SB5 |
    //--------------+
    CopySb5A(_cCodProd,_aDadosB5)

    (_cAlias)->( dbSkip() )
EndDo 

(_cAlias)->( dbCloseArea() ) 

RestArea(_aArea)
Return Nil 

/***********************************************************************************************/
/*/{Protheus.doc} CopySb5A
    @description Realiza a copia dos produtos 
    @type  Static Function
    @author Bernard M Margarido
    @since 07/07/2023
    @version version
/*/
/***********************************************************************************************/
Static Function CopySb5A(_cCodProd,_aDadosB5)
Local _aArea    := GetArea()

Local _nX       := 0 

Local _cFilAux  := cFilAnt 
Local _cFilSB5  := "05"

Local _lGrava   := .T.

If cFilAnt <> _cFilSB5
    cFilAnt := _cFilSB5
EndIf 

dbSelectArea("SB5")
SB5->( dbSetOrder(1) )
If SB5->( dbSeek(xFilial("SB5") + _cCodProd) )
    _lGrava := .F.
EndIf 

RecLock("SB5",_lGrava)
    For _nX := 1 To Len(_aDadosB5)
        If !_aDadosB5[_nX][1] $ "B5_FILIAL"
            Replace &('SB5->' + Alltrim(_aDadosB5[_nX][1])) With _aDadosB5[_nX][2]
        EndIf 
    Next _nX 
    SB5->B5_FILIAL := xFilial("SB5")
SB5->( MsUnLock() )


If cFilAnt <> _cFilAux
    cFilAnt := _cFilAux
EndIf 

RestArea(_aArea)
Return Nil 
