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

Private _lJob       := IIF(Isincallstack("U_SIGM005"),.T.,.F.)

Private _aPLP       := {}

Private _oProcess   := Nil

CoNout("<< SIGM006 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//--------------+
// Processa PLP | 
//--------------+
If _lJob
    _lRet := SigM006A()
Else
    Processa({|| _lRet := SigM006A()},"Aguarde...","Gerando Pre Lista de Postagem." )
EndIf

//------------------------------------+
// Atualiza status pedidos e-Commerce | 
//------------------------------------+
If _lRet .And. Len(_aPLP) > 0
    If _lJob
        SigM006B()
    Else
        Processa({|| SigM006B()},"Aguarde...","Atualizando log dos dados." )
    EndIf
EndIf

CoNout("<< SIGM006 >> - FIM " + dTos( Date() ) + " - " + Time() )

Return .T.

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

Local _nToReg       := 0

Local _lRet         := .T.

Private _oSigepWeb  := Nil

CoNout("<< SIGM006A >> - INICIO GERACAO PRE LISTA DE POSTAGEM")

//----------------------------+
// Consulta notas disponiveis |
//----------------------------+
If !SigM06Qry(_cAlias,@_nToReg)
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
        IncProc("Aguarde, criando PLP " + RTrim((_cAlias)->WSA_NUMSC5) )
    EndIf 

    CoNout("<< SIGM006A >> - CRIANDO PLP PEDIDO " + RTrim((_cAlias)->WSA_NUMSC5) + " .")

    //------------------------+
    // Posiciona registro WSA |
    //------------------------+
    WSA->( dbGoTo( (_cAlias)->RECNOWSA) )

    //-----------------------------------------+
    // Solicita etiqueta de acordo com serviço |
    //-----------------------------------------+
    SigM006Etq((_cAlias)->WSA_SERPOS,@_cEtiqueta)

    //-----------------------------+
    // Retorna codigo da embalagem |
    //-----------------------------+
    SigM006Etq((_cAlias)->WSA_SERPOS,@_cCodEmb)

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

    (_cAlias)->( dbSkip() )
EndDo

//-----------------------------+
// Realiza a gravação do Sigep |
//-----------------------------+
If _oSigepWeb:GrvPlp()
    If !_lJob
        MsgAlert("PLP " + _oSigepWeb:cIdPLP + " Gravada com sucesso.")
    EndIf 
    CoNout("<< SIGM006A >> - PRE LISTA DE POSTAGEM " + _oSigepWeb:cIdPLP + " GRAVADA COM SUCESSO.")
Else
    If !_lJob
        MsgAlert("ERRO AO GERAR PLP " + _oSigepWeb:cIdPLP + ". ERROR " + _oSigepWeb:cError)
    EndIf 
    CoNout("<< SIGM006A >> - ERRO AO GERAR PRE LISTA DE POSTAGEM " + _oSigepWeb:cIdPLP + ". ERROR " + _oSigepWeb:cError)
    _lRet   := .F.
EndIf

(_cAlias)->( dbCloseArea() )

CoNout("<< SIGM006A >> - FIM GERACAO PRE LISTA DE POSTAGEM")

RestArea(_aArea)
Return _lRet 

/**********************************************************************************/
/*/{Protheus.doc} nomeStaticFunction
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


