#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*/{Protheus.doc} nomeFunction
    @description Atualiza codigo dos serviços dos correios SIGEP
    @type  Function
    @author user
    @since date
/*/
User Function UPDWSA()

    Processa({|| UPDWSAA() },"Aguarde...","Atualizando dados.")

Return .T.

/*/{Protheus.doc} nomeStaticFunction
    @description Rotina atualiza dados SIGEP
    @type  Static Function
    @author user
    @since date
/*/
Static Function UPDWSAA
    Local _cAlias   := GetNextAlias()

    Local _nToReg   := 0

    If !UpdWsaQry(_cAlias,@_nToReg)
        MsgStop("Nao existem dados para serem processados.","Aviso")
        Return .F.
    EndIf

    dbSelectArea("WSA")
    WSA->( dbSetOrder(1) )

    ProcRegua(_nToReg)
    While (_cAlias)->( !Eof() )

        WSA->( dbGoTo((_cAlias)->RECNOWSA) )

        IncProc("Atualizando dados orcamento: " + WSA->WSA_NUM )
        RecLock("WSA",.F.)
            WSA->WSA_SERPOS = (_cAlias)->ZZ0_IDSER
        WSA->( MsUnLock() ) 

        (_cAlias)->( dbSkip() )
    EndDo

    (_cAlias)->( dbCloseArea() )

Return .T.

/*/{Protheus.doc} UpdWsaQry
    @description Consulta dados a serem processados
    @type  Static Function
    @author user
    @since date
/*/
Static Function UpdWsaQry(_cAlias,_nToReg)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery	+= "    WSA.WSA_NUMECO, " + CRLF
_cQuery	+= "    ZZ0.ZZ0_IDSER, " + CRLF
_cQuery	+= "    WSA.R_E_C_N_O_ RECNOWSA " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= "    " + RetSqlName("WSA") + " WSA " + CRLF 
_cQuery	+= "    INNER JOIN " + RetSqlName("SA4") + " A4 ON A4.A4_FILIAL = '" + xFilial("SA4") + "' AND A4.A4_COD = WSA.WSA_TRANSP AND A4.D_E_L_E_T_ = '' " + CRLF 
_cQuery	+= "    INNER JOIN " + RetSqlName("ZZ0") + " ZZ0 ON ZZ0.ZZ0_FILIAL = '" + xFilial("ZZ0") + "' AND ZZ0.ZZ0_CODECO = A4.A4_ECSERVI AND ZZ0.D_E_L_E_T_ = '' " + CRLF
_cQuery	+= " WHERE " + CRLF
_cQuery	+= "    WSA.WSA_SERPOS = '' AND " + CRLF
_cQuery	+= "    WSA.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg  

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() )
    Return .F.
EndIf

Return .T.