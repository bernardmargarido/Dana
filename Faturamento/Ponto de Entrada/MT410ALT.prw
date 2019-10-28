#INCLUDE 'PROTHEUS.CH'

/*************************************************************************************/
/*/{Protheus.doc} MT410ALT

@description Ponto de Entrada - Alteração do pedido de venda

@author Bernard M. Margarido
@since 03/08/2019
@version 1.0

@type function
/*/
/*************************************************************************************/
User Function MT410ALT()
Local _aArea	:= GetArea()
Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")

//------------------------+
// Valida se pedido é WMS |
//------------------------+
If !xFilial("SC5") $ _cFilWMS
	RestArea(_aArea)
	Return .T.
EndIf

//----------------------------------------+
// Valida se pedido já foi enviado ao WMS |
//----------------------------------------+
RecLock("SC5",.F.)
	//SC5->C5_XENVWMS := "1"
	SC5->C5_XDTALT	:= Date()
	SC5->C5_XHRALT	:= Time()
SC5->( MsUnLock() )

//--------------+
// Altera Itens |
//--------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If SC6->( dbSeeK(xFilial("SC6") + SC5->C5_NUM ) )
	While SC6->( !Eof() .And. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM) 
		//----------------------+
		// Atualiza item pedido | 
		//----------------------+
		If !Empty( SC6->C6_XENVWMS)
			RecLock("SC6",.F.)
				//SC6->C6_XENVWMS := SC6->C6_XENVWMS
				SC6->C6_XDTALT	:= Date()
				SC6->C6_XHRALT	:= Time()
			SC6->( MsUnLock() )
		EndIf
		
		SC6->( dbSkip() )		
	EndDo
EndIf

RestArea(_aArea)	
Return .T.