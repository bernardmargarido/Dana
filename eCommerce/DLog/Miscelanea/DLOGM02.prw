#INCLUDE "PROTHEUS.CH"

/***************************************************************/
/*/{Protheus.doc} DLOGM02
    @description Gera Lista de Postagem Dlog
    @type  Function
    @author Bernard M. Margarido
    @since 05/01/2021
    @version version
/*/
/***************************************************************/
User Function DLOGM02()
Local   _lRet       := .T.

Private _lJob       := IIF(Isincallstack("U_DLOGM01"),.T.,.F.)

Private _aPLP       := {}

Private _oProcess   := Nil

CoNout("<< DLOGM02 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//--------------+
// Processa PLP | 
//--------------+
Begin Transaction 
    If _lJob
        _lRet := DLOGM02A()
    Else
        Processa({|| _lRet := DLOGM02A()},"Aguarde...","Gerando Pre Lista de Postagem." )
    EndIf
End Transaction

CoNout("<< DLOGM02 >> - FIM " + dTos( Date() ) + " - " + Time() )

Return _lRet

/**********************************************************************************/
/*/{Protheus.doc} DLOGM02A
    @description Consulta notas e gera pre lista de postagem 
    @type  Static Function
    @author Bernard M. Margarido
    @since 12/12/2019
    @version version
/*/
/**********************************************************************************/
Static Function DLOGM02A()
Local _aArea        := GetArea()

Local _cAlias       := GetNextAlias()

Local _nToReg       := 0

Local _lRet         := .T.

Private _oDLog      := Nil

CoNout("<< DLOGM02A >> - INICIO GERACAO LISTA DE POSTAGEM")

//----------------------------+
// Consulta notas disponiveis |
//----------------------------+
If !DLOGM02Qry(_cAlias,@_nToReg)
    If !_lJob
        MsgInfo("Não existem dados para serem importados.","Dana - Avisos")
    EndIf
    CoNout("<< DLOGM02A >> - NAO EXISTEM DADOS PARA SEREM CRIADOS")
    RestArea(_aArea)
    Return .F.
EndIf

//---------------------+
// Tabela - Orçamentos |
//---------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(1) )

If !_lJob
    ProcRegua(_nToReg)
EndIf

//-----------------------+
// Instancia classe DLOG |
//-----------------------+
_oDLog  := DLog():New() 

While (_cAlias)->( !Eof() )

    If !_lJob
        IncProc("Aguarde, CRIANDO PLP PEDIDO " + RTrim((_cAlias)->WSA_NUMSC5) )
    EndIf 

    CoNout("<< DLOGM02A >> - CRIANDO PLP PEDIDO " + RTrim((_cAlias)->WSA_NUMSC5) + " .")

    //------------------------+
    // Posiciona registro WSA |
    //------------------------+
    WSA->( dbGoTo( (_cAlias)->RECNOWSA) )

    //--------------------------------+
    // Array contendo os dados da PLP |
    //--------------------------------+
    aAdd(_oDLog:aNotas,{    (_cAlias)->WSA_DOC      ,;  // 01. Nota
                            (_cAlias)->WSA_SERIE    ,;  // 02. Serie
                            (_cAlias)->WSA_NUMECO   ,;  // 03. Codigo do pedido e-Commerce
                            (_cAlias)->WSA_NUMECL   ,;  // 04. Codigo do pedido e-Commerce (Chave)
                            (_cAlias)->WSA_NUMSC5   })  // 05. Numero do Pedido Faturamento 

    (_cAlias)->( dbSkip() )
EndDo

//-----------------------------+
// Realiza a gravação do Sigep |
//-----------------------------+
If _oDLog:GravaLista()
    If !_lJob
        MsgAlert("Postagem gravada com sucesso.")
    EndIf 
Else
    If !_lJob
        MsgAlert("Erro ao gravar postagem")
    EndIf 
    _lRet   := .F.
EndIf

(_cAlias)->( dbCloseArea() )

CoNout("<< SIGM006A >> - FIM GERACAO LISTA DE POSTAGEM")

RestArea(_aArea)
Return _lRet 

/**********************************************************************************/
/*/{Protheus.doc} DLOGM02Qry
    @description Consulta novas notas para postagem 
    @type  Static Function
    @author Bernard M. Margarido
    @since date
    @version version
/*/
/**********************************************************************************/
Static Function DLOGM02Qry(_cAlias,_nToReg)
Local _cQuery   := ""
Local _cCodDLog := GetNewPar("DN_CODDLOG")

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
_cQuery += "    INNER JOIN " + RetSqlName("SF2") + " F2 ON F2.F2_FILIAL = WSA.WSA_FILIAL AND F2.F2_DOC = WSA.WSA_DOC AND F2.F2_SERIE = WSA.WSA_SERIE AND F2.F2_CLIENTE = WSA.WSA_CLIENT AND F2.F2_LOJA = WSA.WSA_LOJA AND F2.F2_CHVNFE <> '' AND F2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "	WSA.WSA_DOC <> '' AND " + CRLF 
_cQuery += "	WSA.WSA_SERIE <> '' AND " + CRLF
_cQuery += "	WSA.WSA_ENVLOG = '3' AND " + CRLF
_cQuery += "	WSA.WSA_SERPOS = '' AND " + CRLF
_cQuery += "	WSA.WSA_TRANSP = '" + _cCodDLog + "' AND " + CRLF
_cQuery += "	NOT EXISTS( " + CRLF
_cQuery += "				SELECT " + CRLF
_cQuery += "					ZZC.ZZC_NOTA, " + CRLF
_cQuery += "					ZZC.ZZC_SERIE " + CRLF
_cQuery += "				FROM  " + CRLF
_cQuery += "					" + RetSqlName("ZZC") + " ZZC " + CRLF
_cQuery += "				WHERE " + CRLF
_cQuery += "					ZZC.ZZC_FILIAL = WSA.WSA_FILIAL AND " + CRLF
_cQuery += "					ZZC.ZZC_NOTA = WSA.WSA_DOC AND " + CRLF 
_cQuery += "					ZZC.ZZC_SERIE = WSA.WSA_SERIE AND " + CRLF
_cQuery += "					ZZC.ZZC_NUMECO = WSA.WSA_NUMECO AND " + CRLF
_cQuery += "					ZZC.D_E_L_E_T_ = '' " + CRLF
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