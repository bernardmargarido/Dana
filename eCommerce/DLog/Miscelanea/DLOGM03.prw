#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/***********************************************************************************/
/*/{Protheus.doc} DLOGM03
    @description Envia lista de postagem DLog
    @type  Function
    @author Bernard M. Margarido
    @since 05/01/2021
/*/
/***********************************************************************************/
User Function DLOGM03()
Local   _lRet       := .T.

Private _lJob       := IIF(Isincallstack("U_DLOGM01"),.T.,.F.)

Private _aPLP       := {}

Private _oProcess   := Nil

CoNout("<< DLOGM03 >> - INICIO " + dTos( Date() ) + " - " + Time() )

If _lJob
    _lRet := DLOGM03A()
Else
    Processa({|| _lRet := DLOGM03A()},"Aguarde...","Enviando Lista de Postagem." )
EndIf

CoNout("<< DLOGM03 >> - FIM " + dTos( Date() ) + " - " + Time() )
Return _lRet 

/***********************************************************************************/
/*/{Protheus.doc} DLOGM03A
    @description Realiza o envio das postagens 
    @type  Static Function
    @author Bernard M. Margarido
    @since 05/01/2021
/*/
/***********************************************************************************/
Static Function DLOGM03A()
Local _aArea	:= GetArea()

Local _cAlias	:= GetNextAlias()
Local _cCodPLP	:= ""

Local _nToReg	:= 0
Local _nRecnoZZB:= 0

Local _aItPLP	:= {}

Local _lRet		:= .T.

Local _oDLog	:= DLog():New()

//-------------------+
// Consulta Postagem |
//-------------------+
If !DlogM03Qry(_cAlias,@_nToReg)
	If _lJob
		MsgStop("Não existem dados para serem enviados.","Aviso")
	EndIf
	ConOut(" << DLOGM03 >> - NAO EXISTEM DADOS PARA SEREM ENVIADOS.")	
	RestArea(_aArea)
	Return .F.
EndIf

//--------------------------------+
// Tabela - Orçamentos e-Commerce |
//--------------------------------+
dbSelectArea("WSA")
WSA->( dbSetOrder(2) )

//--------------------+
// Tabela - Postagens |
//--------------------+
dbSelectArea("ZZB")
ZZB->( dbSetOrder(1) )

//-------------------------+
// Tabela - Itens Postagem |
//-------------------------+
dbSelectArea("ZZC")
ZZC->( dbSetOrder(1) )

//-----------------------------+
// Array contento as Etiquetas |
//-----------------------------+
While (_cAlias)->( !Eof() )

	_cCodPLP 	:= (_cAlias)->ZZB_CODIGO
	_nRecnoZZB	:= (_cAlias)->RECNOZZB

	CoNout("<< DLOGM03 >> - ENVIANDO PLP " + _cCodPLP)

	While (_cAlias)->( !Eof() .And. _cCodPLP == (_cAlias)->ZZ2_CODIGO )

		
		(_cAlias)->( dbSkip() )
	EndDo
	
EndDo 

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return _lRet 