#INCLUDE "PROTHEUS.CH"

/**********************************************************************************/
/*/{Protheus.doc} DnFatM02
    @description Valida alteração do preço aplicada
    @type  Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/**********************************************************************************/
User Function DnFatM02(_nPrcVen, _nPerDesc, _nValDesc,_cCpo,_nPrcX)
Local _lRet     := .T.

Local _cUserAut := GetNewPar("DN_USRPRC","000000")

//-------------------------------+
// Valida campo que foi alterado | 
//-------------------------------+
If _cCpo == "DA1_PRCVEN" .And. Type('M->DA1_PRCVEN') <> "U"
    If ( _nPrcVen > M->DA1_PRCVEN .And. !__cUserId $ _cUserAut )
        _nPrcX  := M->DA1_PRCVEN
        _lRet   := .F.
    EndIf
ElseIf _cCpo == "DA1_PERDES" .And. Type('M->DA1_PERDES') <> "U"
    If ( _nPrcVen > ( _nPrcVen * M->DA1_PERDES ) .And. !__cUserId $ _cUserAut )
        _nPrcX  := Round(_nPrcVen * M->DA1_PERDES,2)
        _lRet   := .F.
    EndIf
ElseIf _cCpo == "DA1_VLRDES" .And. Type('M->DA1_VLRDES') <> "U"
    If ( _nPrcVen > ( _nPrcVen - M->DA1_VLRDES ) .And. !__cUserId $ _cUserAut )
        _nPrcX  := _nPrcVen - M->DA1_PERDES
        _lRet   := .F.
    EndIf
EndIf

Return _lRet 
