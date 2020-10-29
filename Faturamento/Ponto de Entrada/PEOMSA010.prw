#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*****************************************************************************/
/*/{Protheus.doc} OMSA010
    @description Ponto de Entrada - MVC Tabela de Preco
    @type  Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/*****************************************************************************/
User Function OMSA010()
Local _aParam   := ParamIxb

Local _oObj     := Nil 
Local _oGrid    := Nil 

Local _cIdPonto := ""
Local _cIdModel := ""
Local _cClasse  := ""
Local _cValGrid := ""

Local _nPPrcAux := 0
Local _nPPrcVen := 0
Local _nPPerDesc:= 0
Local _nPValDesc:= 0
Local _nPPrcVenX:= 0 
Local _nPrcX    := 0

Local _lIsGrid  := .F.
Local _lRet     := .T.

If ValType(_aParam) <> "U" 
    _oObj       := _aParam[1] 
    _oGrid      := FWViewActive()
    _cIdPonto   := _aParam[2]
    _cIdModel   := _aParam[3]
    _cClasse    := IIf( ValType(_oObj) == "O", _oObj:ClassName(),"")
    _lIsGrid    := ( Len(_aParam) > 3)
    If _lIsGrid
        _cValGrid := IIF(Len(_aParam) > 4 , _aParam[5], "")
        If _cIdPonto == "FORMLINEPRE" //.And. _cValGrid == "SETVALUE"
            _cCpo       := _aParam[6]
            _nLinha     := _aParam[4]

            _nPProd     := aScan(_oObj:aHeader,{|x| RTrim(x[2]) == "DA1_CODPRO"})
            _nPPrcVen   := aScan(_oObj:aHeader,{|x| RTrim(x[2]) == "DA1_PRCVEN"})
            _nPPrcVenX  := aScan(_oObj:aHeader,{|x| RTrim(x[2]) == "DA1_XPRCVE"})
            _nPPerDesc  := aScan(_oObj:aHeader,{|x| RTrim(x[2]) == "DA1_PERDES"})
            _nPValDesc  := aScan(_oObj:aHeader,{|x| RTrim(x[2]) == "DA1_VLRDES"})  

            //---------------------------+    
            // Valida alteração de preço |
            //---------------------------+
            _xType  := ('M->'+_cCpo)
            If Type(_xType) <> "U"
                _nPPrcAux   := _oObj:aCols[_nLinha][_nPPrcVen]
                _oObj:aCols[_nLinha][_nPPrcVenX]    := 0
                If !u_DnFatM01(_oObj:aCols[_nLinha][_nPPrcVen], _oObj:aCols[_nLinha][_nPPerDesc], _oObj:aCols[_nLinha][_nPValDesc],_cCpo,@_nPrcX) 
                    Help(,,'OMSA010',, "Preço " + cValToChar(_nPrcX) + " do Produto " + RTrim(_oObj:aCols[_nLinha][_nPProd]) + " necessita de autorização do superior, será enviado um e-mail para autorização.", 1, 0)

                    DA1->( dbGoTo(_oObj:aCols[_nLinha][Len(_oObj:aHeader) + 1]))
                    RecLock("DA1",.F.)
                        DA1->DA1_XPRCVE := _nPrcX
                    DA1->( MsUnLock() )
                    
                    _oObj:aCols[_nLinha][_nPPrcVenX]    := _nPrcX
                    _oObj:aCols[_nLinha][_nPPrcVen]     := _nPPrcAux

                    _oGrid:Refresh()
                    _lRet := .F.
                Else
                    If _oObj:aCols[_nLinha][_nPPrcVenX] > 0 
                        DA1->( dbGoTo(_oObj:aCols[_nLinha][Len(_oObj:aHeader) + 1]))
                        RecLock("DA1",.F.)
                            DA1->DA1_XPRCVE := 0
                        DA1->( MsUnLock() )
                        _oObj:aCols[_nLinha][_nPPrcVenX]    := 0

                        _oGrid:Refresh()
                        
                    EndIF
                EndIf
            EndIf
        EndIf
    EndIf
EndIf

Return _lRet 