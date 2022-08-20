#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/****************************************************************************************/
/*/{Protheus.doc} Danaecom
    @description Classe responsavel pelo processo de MultiLojas
    @author    Bernard M. Margarido
    @since     16/08/2022
/*/
/****************************************************************************************/
Class DanaEcom 

    Data nID        As Integer

    Data cLojaID    As String 
    Data cDTEnv     As String 
    Data cCodErp    As String 
    Data cAlias     As String 

    Method New() Constructor 
    Method GravaID()
    Method GetID()
    Method Item() 

End Class 

/***************************************************************************************/
/*/{Protheus.doc} New
    @description New - Método construtor da classe
    @author Bernard M Margarido 
    @since 16/08/2022
    @version version
/*/
/***************************************************************************************/
Method New() Class DanaEcom 
    
    Self:nID        := 0

    Self:cLojaID    := ""
    Self:cCodErp    := ""
    Self:cAlias     := ""
    Self:cDTEnv     := FwTimeStamp(3,Date())

Return Nil 

/*************************************************************************************************/
/*/{Protheus.doc} GravaID
    @description GravaID - Método responsavel por gravar ID do eCommerce no ERP 
    @author user
    @since 16/08/2022
    @version version
/*/
/*************************************************************************************************/
Method GravaID() Class DanaEcom 
Local _aArea := GetArea()

Local _cItem := ""

Local _nRecno:= 0

Local _lGrava:= .T.
Local _lRet  := .T.

//-------------------------------------+
// XTD - Posiciona tabela ID eCommerce |
//-------------------------------------+
dbSelectArea("XTD")
XTD->( dbSetOrder(1) )

//-------------------+
// Consulta registro | 
//-------------------+
QryXTD(Self:cLojaID,Self:cAlias,Self:cCodErp,Self:nID,@_nRecno) 

If _nRecno > 0 
    XTD->( dbGoTo(_nRecno) )
   
    _lGrava := .F.
    _cItem  := XTD->XTD_ITEM 

Else 
    _lGrava := .T.
    _cItem  := QryItem(Self:cLojaID,Self:cAlias)
EndIf 

RecLock("XTD", _lGrava)
    XTD->XTD_FILIAL := xFilial("XTD")
    XTD->XTD_ITEM   := _cItem 
    XTD->XTD_CODIGO := Self:cLojaID
    XTD->XTD_ALIAS  := Self:cAlias
    XTD->XTD_CODERP := Self:cCodErp
    XTD->XTD_IDECOM := Self:nID
    XTD->XTD_DTENV  := Self:cDTEnv 
XTD->( MsUnLock() )

RestArea(_aArea)
Return _lRet 

/***********************************************************************************************/
/*/{Protheus.doc} QryXTD
    @description Consulta registro ID 
    @type  Static Function
    @author Bernard M Margarido
    @since 16/08/2022
/*/
/***********************************************************************************************/
Static Function QryXTD(_cIDLoja,_cAlias,_cCodErp,_nID,_nRecno) 
Local _cQuery       := ""
Local _cAliasTMP    := ""

Local _lRet         := .T.

_cQuery := " SELECT " + CRLF
_cQuery += "	XTD.R_E_C_N_O_ RECNOXTD " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("XTD") + " XTD " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND " + CRLF
_cQuery += "	XTD.XTD_ALIAS = '" + _cAlias + "' AND " + CRLF
_cQuery += "	XTD.XTD_CODIGO = '" + _cIDLoja + "' AND " + CRLF
_cQuery += "	XTD.XTD_CODERP = '" + _cCodErp + "' AND " + CRLF
_cQuery += "	XTD.D_E_L_E_T_ = '' "

_cAliasTMP := MPSysOpenQuery(_cQuery)

If Empty((_cAliasTMP)->RECNOXTD)
    _nRecno := 0    
    _lRet   := .F.
Else 
    _nRecno := (_cAliasTMP)->RECNOXTD    
    _lRet   := .T.
EndIf 

(_cAliasTMP)->( dbCloseArea() )    

Return .T.

/***********************************************************************************************/
/*/{Protheus.doc} QryItem
    @description Retorna o proximo item 
    @type  Static Function
    @author Bernard M Margarido
    @since 16/08/2022
    @version version
/*/
/***********************************************************************************************/
Static Function QryItem(_cLojaID,_cAlias)
Local _cItem    := ""
	
_cQuery := " SELECT " + CRLF
_cQuery += "	ISNULL(MAX(XTD.XTD_ITEM),'000') ITEM " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("XTD") + " XTD " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	XTD.XTD_FILIAL = '" + xFilial("XTD") + "' AND " + CRLF
_cQuery += "	XTD.XTD_ALIAS = '" + _cAlias + "' AND " + CRLF
_cQuery += "	XTD.XTD_CODIGO = '" + _cLojaID + "' AND " + CRLF
_cQuery += "	XTD.D_E_L_E_T_ = '' "

_cAliasTMP := MPSysOpenQuery(_cQuery)

_cItem     := Soma1((_cAliasTMP)->ITEM)

(_cAliasTMP)->( dbCloseArea() )    

Return _cItem 
