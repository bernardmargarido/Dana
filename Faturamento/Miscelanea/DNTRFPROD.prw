#INCLUDE "TOTVS.CH"

User Function DNTRFPROD()
Local _aArea        := GetArea()
Local _aParam	    := {}
Local _aRet		    := {}

Local _cFilTrf      := CriaVar("B1_FILIAL",.F.)

Private _cFilAux    := ""

aAdd(_aParam,{1, "Filial"           , _cFilTrf   , PesqPict("SB1","B1_FILIAL")      , ".T.", "SM0" , "", TamSx3("B1_FILIAL")[1]       , .T.})

If ParamBox(_aParam,"Conciliação Market Place",@_aRet,/*_bVldParam*/,,,,,,,.T.,.T.)
    _cFilAux    := mv_par01 

    FwMsgRun(,{|_oSay| DnTrfPrdA(@_oSay)},"Aguarde...","Processando dados.")

EndIf

RestArea(_aArea)
Return Nil 

Static Function DnTrfPrdA(_oSay)
Local _cAlias   := ""

Local _nX       := 0

Local _aStruct  := SB1->( DBStruct() )

//----------------------------------------+
// Consulta produtos a serem transferidos |
//----------------------------------------+
_oSay:cCaption := "Consultando produtos."
If !DnTrfQry(@_cAlias)
    MsgStop("Não foram encontrados novos produtos a serem  transferidos.","Dana - Avisos")
    Return Nil 
EndIf 

MakeDir("\produtos\")
MakeDir("\produtos\migracao\")

dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

While (_cAlias)->( !Eof() )

    If !SB1->( dbSeek(xFilial("SB1") + (_cAlias)->B1_COD) )

        RecLock("SB1",.T.)
            For _nX := 1 To Len(_aStruct)
                If RTrim(_aStruct[_nX][1]) # "B1_FILIAL"
                    If SB1->( FieldPos(Alltrim(_aStruct[_nX][1])) ) > 0
                        If _aStruct[_nX][2] == "D"
                            _cCampo02   := sTod(&("(_cAlias)->" + RTrim(_aStruct[_nX][1])))
                        ElseIf _aStruct[_nX][2] == "M"
                            _cCampo02   := "" //&("(_cAlias)->" + RTrim(_aStruct[_nX][1]))
                        Else 
                            _cCampo02   := &("(_cAlias)->" + RTrim(_aStruct[_nX][1]))
                        EndIf 
                        _cCampo01   := "SB1->" + RTrim(_aStruct[_nX][1])
                        Replace &(_cCampo01) With _cCampo02
                    EndIf
                EndIf
            Next _nX 
            SB1->B1_FILIAL := xFilial("SB1")
            SB1->B1_XCODPRD:= (_cAlias)->B1_COD
        SB1->( MsUnLock() )

        _oSay:cCaption := "Atualizando produto " + Rtrim((_cAlias)->B1_COD) + " ."

        _cArq := "FILIAL " + _cFilAux + " PRODUTO " + RTrim((_cAlias)->B1_COD) + " CRIADO COM SUCESSO. NOVA FILIAL " + xFilial("SB1") + "."
        MemoWrite("\produtos\migracao\produto" + RTrim((_cAlias)->B1_COD) + ".txt",_cArq)

    EndIf 
    (_cAlias)->( dbSkip() ) 
EndDo 

(_cAlias)->( dbCloseArea() )

Return Nil 

Static Function DnTrfQry(_cAlias)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	B1.* " + CRLF
_cQuery += " FROM " + CRLF 
_cQuery += "	" + RetSqlName("SB1") + " B1 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	B1.B1_FILIAL = '" + _cFilAux + "' AND " + CRLF
_cQuery += "	NOT EXISTS( " + CRLF
_cQuery += "			SELECT " + CRLF
_cQuery += "				SB1.B1_COD " + CRLF
_cQuery += "			FROM " + CRLF
_cQuery += "				" + RetSqlName("SB1") + " SB1 " + CRLF
_cQuery += "			WHERE " + CRLF
_cQuery += "				SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
_cQuery += "				SB1.B1_COD = B1.B1_COD AND " + CRLF
_cQuery += "				SB1.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	) " + CRLF
_cQuery += " ORDER BY B1.B1_COD "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf


Return .T.
