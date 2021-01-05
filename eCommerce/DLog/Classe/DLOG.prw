#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

#DEFINE CRLF            CHR(13) + CHR(10)

/****************************************************************************************/
/*/{Protheus.doc} DLog
    @description Classe utilizada para integração DLog
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Class DLog 

    Data cUser     As String 
    Data cPassword As String 
    Data cToken    As String 
    Data cUrl      As String 
    Data cRest     As String 
    Data cResponse As String 

    Data aNotas    As Array 

    Data oJSon     As Object 

    Method New() Constructor
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
Method New() Class DLog

    ::cUser     := GetNewPar("DN_DLOGUSE")
    ::cPassword := GetNewPar("DN_DLOGPAS")
    ::cToken    := GetNewPar("DN_DLOGTOK")
    ::cUrl      := GetNewPar("DN_DLOGURL")
    ::cRest     := ""
    ::cResponse := ""

    ::aNotas    := {}

    ::oJSon     := Nil 

Return Nil 

/****************************************************************************************/
/*/{Protheus.doc} GravaLista
    @description Método - Grava lista de postagem
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Method GravaLista() Class DLog
Local _aArea    := GetArea() 

Local _cNumID   := ""

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
Method GeraLista() Class DLog
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} StatusLista
    @description Método - Consulta status da lista de postagem  
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Method StatusLista() Class DLog
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} ClearObj
    @description Método - Limpa objeto da classe  
    @author    Bernard M. Margarido
    @since     05/01/2020
/*/
/****************************************************************************************/
Method ClearObj(oObj) Class DLog
Return FreeObj(oObj)