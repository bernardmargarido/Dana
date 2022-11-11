#INCLUDE 'PROTHEUS.CH'

/**************************************************************************/
/*/{Protheus.doc} MT140SAI
	@description Ponto de Entrada - Após a gravação da pré nota de entrada 
	@author Bernard M. Margarido
	@since 19/11/2018
	@version 1.0
	@type function
/*/
/**************************************************************************/
User Function MT140SAI()
Local aArea		:= GetArea()

Local nOpcA		:= ParamIxb[7]
Local nOpcX		:= ParamIxb[1]

Local cDoc		:= ParamIxb[2]
Local cSerie	:= ParamIxb[3]
Local cCodFor	:= ParamIxb[4]
Local cLoja		:= ParamIxb[5]
//Local cTpNota	:= ParamIxb[6]

Local _lEstClas := SF1->F1_XESTCLA

If nOpcX == 2 .Or. nOpcA <> 1 
	RestArea(aArea)
	Return .T.
EndIf

//--------------------+
// Posiciona Pre Nota |
//--------------------+
dbSelectArea("SF1")
SF1->( dbSetOrder(1) )
If !SF1->( dbSeek(xFilial("SF1") + cDoc + cSerie + cCodFor + cLoja) )
	RestArea(aArea)
	Return .T.
EndIf

If SF1->F1_TIPO $ "N/D/B"
	//----------------------------------+
	// Atualiza dados para envio ao WMS |
	//----------------------------------+
	RecLock("SF1",.F.)
		SF1->F1_XDTALT	:= dDataBase 
		SF1->F1_XHRALT 	:= Time()
		SF1->F1_XENVWMS	:= IIF(_lEstClas,SF1->F1_XENVWMS,"1")
	SF1->( MsUnLock() )	
EndIf

RestArea(aArea)	
Return .T.
