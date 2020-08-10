#INCLUDE "PROTHEUS.CH"

/***************************************************************/
/*/{Protheus.doc} SIGM006
    @description Gera Pre Lista de Postagem 
    @type  Function
    @author Bernard M. Margarido
    @since 14/12/2019
    @version version
/*/
/***************************************************************/
User Function SIGM006()
Local   _lRet       := .T.

Private _lJob       := IIF(Isincallstack("U_SIGM005"),.T.,.F.)

Private _aPLP       := {}

Private _oProcess   := Nil

CoNout("<< SIGM006 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//--------------+
// Processa PLP | 
//--------------+
Begin Transaction 
    If _lJob
        _lRet := SigM006A()
    Else
        Processa({|| _lRet := SigM006A()},"Aguarde...","Gerando Pre Lista de Postagem." )
    EndIf
End Transaction

CoNout("<< SIGM006 >> - FIM " + dTos( Date() ) + " - " + Time() )

Return _lRet

/**********************************************************************************/
/*/{Protheus.doc} SigM006A
    @description Consulta notas e gera pre lista de postagem 
    @type  Static Function
    @author Bernard M. Margarido
    @since 12/12/2019
    @version version
/*/
/**********************************************************************************/
Static Function SigM006A()
Local _aArea        := GetArea()

Local _cAlias       := GetNextAlias()
Local _cEtiqueta    := ""
Local _cCodEmb      := ""

Local _nToReg       := 0
Local _nX           := 0

Local _lRet         := .T.

Private _oSigepWeb  := Nil

CoNout("<< SIGM006A >> - INICIO GERACAO PRE LISTA DE POSTAGEM")

//----------------------------+
// Consulta notas disponiveis |
//----------------------------+
If !SigM06Qry(_cAlias,@_nToReg)
    If !_lJob
        MsgInfo("Não existem dados para serem importados.","Dana - Avisos")
    EndIf
    CoNout("<< SIGM006A >> - NAO EXISTEM DADOS PARA SEREM CRIADOS")
    RestArea(_aArea)
    Return .F.
EndIf

//---------------------+
// Tabela - Orçamentos |
//---------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(1) )

//---------------------------+
// Instancia Classe SigepWeb |
//---------------------------+
_oSigepWeb := SigepWeb():New()

//-------------------------------+
// Campos para gravação SigepWeb |
//-------------------------------+
_oSigepWeb:dDtIni   := Date()
_oSigepWeb:cHrIni   := Time()
_oSigepWeb:dDtFim   := Date()
_oSigepWeb:cHrFim   := Time()

If !_lJob
    ProcRegua(_nToReg)
EndIf

While (_cAlias)->( !Eof() )

    If !_lJob
        IncProc("Aguarde, CRIANDO PLP PEDIDO " + RTrim((_cAlias)->WSA_NUMSC5) )
    EndIf 

    CoNout("<< SIGM006A >> - CRIANDO PLP PEDIDO " + RTrim((_cAlias)->WSA_NUMSC5) + " .")

    //------------------------+
    // Posiciona registro WSA |
    //------------------------+
    WSA->( dbGoTo( (_cAlias)->RECNOWSA) )

    //-------------------------------------------+
    // Solicita etiquetas de acordo com o volume | 
    //-------------------------------------------+
    For _nX := 1 To Int(WSA->WSA_VOLUME)
        //-----------------------------------------+
        // Solicita etiqueta de acordo com serviço |
        //-----------------------------------------+
        _cEtiqueta := ""
        SigM006C((_cAlias)->WSA_SERPOS,(_cAlias)->WSA_DOC,(_cAlias)->WSA_SERIE,(_cAlias)->WSA_NUMECO,@_cEtiqueta)

        //-----------------------------+
        // Retorna codigo da embalagem |
        //-----------------------------+
        _cCodEmb := ""
        SigM006D(@_cCodEmb)

        //--------------------------------+
        // Array contendo os dados da PLP |
        //--------------------------------+
        aAdd(_oSigepWeb:aNotas,{    (_cAlias)->WSA_DOC      ,;  // 01. Nota
                                    (_cAlias)->WSA_SERIE    ,;  // 02. Serie
                                    (_cAlias)->WSA_CLIENT   ,;  // 03. Cliente
                                    (_cAlias)->WSA_LOJA     ,;  // 04. Loja
                                    _cEtiqueta              ,;  // 05. Codigo Etiqueta
                                    (_cAlias)->WSA_SERPOS   ,;  // 06. Codigo serviço de postagem
                                    _cCodEmb                ,;  // 07. Codigo Embalagem 
                                    (_cAlias)->WSA_NUMECO   ,;  // 08. Codigo do pedido e-Commerce
                                    (_cAlias)->WSA_NUMECL   ,;  // 09. Codigo do pedido e-Commerce (Chave)
                                    (_cAlias)->WSA_NUMSC5   })  // 10. Numero do Pedido Faturamento 

    Next _nX

    (_cAlias)->( dbSkip() )
EndDo

//-----------------------------+
// Realiza a gravação do Sigep |
//-----------------------------+
If _oSigepWeb:GrvPlp()
    If !_lJob
        MsgAlert("PLP " + _oSigepWeb:cIdPLPErp + " Gravada com sucesso.")
    EndIf 
    CoNout("<< SIGM006A >> - PRE LISTA DE POSTAGEM " + _oSigepWeb:cIdPLPErp + " GRAVADA COM SUCESSO.")
Else
    If !_lJob
        MsgAlert("ERRO AO GERAR PLP " + _oSigepWeb:cIdPLPErp + ". ERROR " + _oSigepWeb:cError)
    EndIf 
    CoNout("<< SIGM006A >> - ERRO AO GERAR PRE LISTA DE POSTAGEM " + _oSigepWeb:cIdPLPErp + ". ERROR " + _oSigepWeb:cError)
    _lRet   := .F.
EndIf

(_cAlias)->( dbCloseArea() )

CoNout("<< SIGM006A >> - FIM GERACAO PRE LISTA DE POSTAGEM")

RestArea(_aArea)
Return _lRet 

/**********************************************************************************/
/*/{Protheus.doc} SigM006C
    @description Consulta etiquetas disponiveis
    @type  Static Function
    @author Bernard M. Margarido
    @since date
    @version version
/*/
/**********************************************************************************/
Static Function SigM006C(_cIdPos,_cDoc,_cSerie,_cNumEco,_cEtiqueta)
Local _aArea    := GetArea()

Local _oSigepWeb:= Nil

CoNout("<< SIGM006A >> - CONSULTANDO ETIQUETA DISPONIVEL PARA O CODIGO DE SERVIÇO " + _cIdPos + " .")

//---------------------------------------+
// Valida se existe etiquetas dispniveis | 
//---------------------------------------+
SigM006E(_cIdPos)

//-----------------------+
// Instacia Classe SIGEP |
//-----------------------+
_oSigepWeb:= SigepWeb():New()

//-------------------+
// Parametros Método | 
//-------------------+
_oSigepWeb:cIdPostagem := _cIdPos

//------------------------------------------------------------------+
// Caso ocorra erro ao retornar a etiqueta solicita novas etiquetas |
//------------------------------------------------------------------+
If _oSigepWeb:GetEtiqueta()

    CoNout("<< SIGM006A >> - ETIQUETA RETORNADA COM SUCESSO.")

    _cEtiqueta := RTrim(_oSigepWeb:cEtqParc) + RTrim(_oSigepWeb:cDigEtq) + RTrim(_oSigepWeb:cSigla)
    //---------------------------------------+
    // Atualiza as informações na tabela ZZ1 |
    //---------------------------------------+
    dbSelectArea("ZZ1")
    ZZ1->( dbSetOrder(1) )
    ZZ1->( dbGoTo(_oSigepWeb:nRecno) )
    RecLock("ZZ1",.F.)
        ZZ1->ZZ1_DVETQ  := _oSigepWeb:cDigEtq
        ZZ1->ZZ1_NOTA   := _cDoc
        ZZ1->ZZ1_SERIE  := _cSerie
        ZZ1->ZZ1_NUMECO := _cNumEco
    ZZ1->( MsUnLock() )

EndIf

FreeObj(_oSigepWeb)

RestArea(_aArea)
Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigM006D
    @description Consulta codigo da embalagem
    @type  Static Function
    @author Bernard M. Margarido
    @since date
    @version version
/*/
/**********************************************************************************/
Static Function SigM006D(_cCodEmb)
_cCodEmb := "001"
Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigM006E
    @description Consulta etiquetas disponiveis
    @type  Static Function
    @author Bernard M. Margarido
    @since date
    @version version
/*/
/**********************************************************************************/
Static Function SigM006E(_cIdPos)
Local _lRet     := .T.

Local _oSigepWeb:= Nil

CoNout("<< SIGM006E >> - CONSULTANDO ETIQUETA DISPONIVEL PARA O CODIGO DE SERVIÇO " + _cIdPos + " .")

If !SigM06EQry(_cIdPos)

    CoNout("<< SIGM006E >> - SOLICITANDO NOVAS ETIQUETAS PARA O CODIGO DE SERVIÇO " + _cIdPos + " .")

    _oSigepWeb:= SigepWeb():New()

    _oSigepWeb:cIdServ := _cIdPos
    If _oSigepWeb:GrvCodEtq()
        CoNout("<< SIGM006E >> - NOVAS ETIQUETAS PARA O CODIGO DE SERVIÇO " + _cIdPos + " GERADAS COM SUCESSO.")
        _lRet := .T. 
    Else
        CoNout("<< SIGM006E >> - ERRO AO GERAR NOVAS ETIQUETAS PARA O CODIGO DE SERVIÇO " + _cIdPos + " .")
        _lRet := .F. 
    EndIf

    FreeObj(_oSigepWeb)

EndIf

Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} GetEtqQry
@description Retorna Etiqueta pelo id de postagem 
@author Bernard M. Margarido
@since 10/12/2019
@version 1.0
@type function
/*/
/****************************************************************************************/
Static Function SigM06EQry(_cIdPos)
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""

_cQuery := " SELECT " + CRLF
_cQuery += "	TOP 1 " + CRLF
_cQuery += "	ZZ1.ZZ1_CODETQ, " + CRLF
_cQuery += "	ZZ1.ZZ1_SIGLA, " + CRLF
_cQuery += "	ZZ1.ZZ1_DVETQ, " + CRLF
_cQuery += "	ZZ1.R_E_C_N_O_ RECNOZZ1" + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("ZZ1") + " ZZ1 " + CRLF 
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZ1.ZZ1_FILIAL = '" + xFilial("ZZ1") + "' AND " + CRLF 
_cQuery += "	ZZ1.ZZ1_IDSER = '" + _cIdPos + "' AND " + CRLF 
_cQuery += "	ZZ1.ZZ1_NOTA = '' AND " + CRLF 
_cQuery += "	ZZ1.ZZ1_SERIE = '' AND " + CRLF 
_cQuery += "	ZZ1.ZZ1_PLPID = '' AND " + CRLF 
_cQuery += "	ZZ1.ZZ1_NUMECO = '' AND " + CRLF 
_cQuery += "	ZZ1.D_E_L_E_T_ = '' " + CRLF 
_cQuery += " ORDER BY ZZ1.R_E_C_N_O_ ASC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->( Eof() )
	(_cAlias)->( dbCloseArea() )
	Return .F.
EndIf

(_cAlias)->( dbCloseArea() )
Return .T.

/**********************************************************************************/
/*/{Protheus.doc} SigM06Qry
    @description Consulta novas notas para PLP 
    @type  Static Function
    @author Bernard M. Margarido
    @since date
    @version version
/*/
/**********************************************************************************/
Static Function SigM06Qry(_cAlias,_nToReg)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	WSA.WSA_NUM, " + CRLF
_cQuery += "	WSA.WSA_NUMECO, " + CRLF
_cQuery += "	WSA.WSA_NUMECL, " + CRLF
_cQuery += "	WSA.WSA_NUMSC5, " + CRLF
_cQuery += "	WSA.WSA_DOC, " + CRLF
_cQuery += "	WSA.WSA_SERIE, " + CRLF
_cQuery += "	WSA.WSA_CLIENT, " + CRLF
_cQuery += "	WSA.WSA_LOJA, " + CRLF
_cQuery += "	WSA.WSA_SERPOS, " + CRLF
_cQuery += "	WSA.R_E_C_N_O_ RECNOWSA " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("WSA") + " WSA  " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "	WSA.WSA_DOC <> '' AND " + CRLF 
_cQuery += "	WSA.WSA_SERIE <> '' AND " + CRLF
_cQuery += "	WSA.WSA_ENVLOG = '3' AND " + CRLF
_cQuery += "	WSA.WSA_SERPOS <> '' AND " + CRLF
_cQuery += "	NOT EXISTS( " + CRLF
_cQuery += "				SELECT " + CRLF
_cQuery += "					ZZ4.ZZ4_NOTA, " + CRLF
_cQuery += "					ZZ4.ZZ4_SERIE " + CRLF
_cQuery += "				FROM  " + CRLF
_cQuery += "					" + RetSqlName("ZZ4") + " ZZ4 " + CRLF
_cQuery += "				WHERE " + CRLF
_cQuery += "					ZZ4.ZZ4_FILIAL = WSA.WSA_FILIAL AND " + CRLF
_cQuery += "					ZZ4.ZZ4_NOTA = WSA.WSA_DOC AND " + CRLF 
_cQuery += "					ZZ4.ZZ4_SERIE = WSA.WSA_SERIE AND " + CRLF
_cQuery += "					ZZ4.ZZ4_NUMECO = WSA.WSA_NUMECO AND " + CRLF
_cQuery += "					ZZ4.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	) AND " + CRLF
_cQuery += "	WSA.D_E_L_E_T_ = '' " + CRLF 
_cQuery += " ORDER BY WSA.WSA_NUM "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )
If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.