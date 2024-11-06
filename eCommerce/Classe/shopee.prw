#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*************************************************************************************************************/
/*/{Protheus.doc} Shopee
    @description Classe - Responsavel pelos metodos de envio e recebimento de dados com a Shopee
    @author Bernard M Margarido
    @since 22/10/2024
    @version version
/*/
/*************************************************************************************************************/
Class Shopee 
    
    Data _cUrl      as String 
    Data _cPartID   as String 
    Data _cLojaID   as String 
    Data _cSign     as String 
    Data _cTimeSt   as String 
    Data _cPath     as String 

    Method New() Constructor 
    Method GetToken() 
    Method GetPLP() 

EndClass

/*************************************************************************************************************/
/*/{Protheus.doc} New
    @description Metodo construtor da classe
    @author Bernard M Margarido
    @since 22/10/2024
    @version version
/*/
/*************************************************************************************************************/
Method New() Class Shopee
    
    Self:_cUrl      := "https://partner.test-stable.shopeemobile.com"
    Self:_cPartID   := "1207523"
    Self:_cLojaID   := "113056"
    Self:_cSign     := ""
    Self:_cTimeSt   := ""
    Self:_cPath     := ""

Return Nil 

/*************************************************************************************************************/
/*/{Protheus.doc} GetToken
    @description Metodo realiza a busca do token de autorização 
    @author Bernard M Margarido
    @since 22/10/2024
    @version version
/*/
/*************************************************************************************************************/
Method GetToken()
Local _lRet     := .T. 

Local _oFwRest  := FWRest():New(Self:_cUrl)
Local _oJSon    := JSonObject():new()

Self:_cTimeSt   := FwTimeStamp(4,Date(),Time())
Self:_cPath     := '/api/v2/auth/token/get'
Self:_cSign     := SHA256(Self:_cPartID + Self:_cPath + Self:_cTimeSt)

_oJSon['code']              := "cbdb2a0e81da3af6"
_oJSon['partner_id']        := Self:_cPartID
_oJSon['shop_id']           := Self:_cLojaID
_oJSon['main_account_id']   := "4811a317aed30b6c6bd7"

Return _lRet 
