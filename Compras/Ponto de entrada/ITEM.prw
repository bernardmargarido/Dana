#INCLUDE 'PROTHEUS.CH'

/******************************************************************************/
/*/{Protheus.doc} ITEM

@description Ponto de Entrada - MVC Produtos 

@author Bernard M. Margarido
@since 25/10/2018
@version 1.0

@type function
/*/
/******************************************************************************/
User Function ITEM()
Local aArea		:= GetArea()
Local aParam 	:= ParamIxb

Local cIdPonto	:= ""
Local cIdModel	:= ""

Local oModel	:= Nil
Local oModelSB1	:= Nil
 
If ValType(aParam) == "A"
	//---------------------------------+
	// Variaveis de validação do model |
	//---------------------------------+
	cIdPonto	:= aParam[2]
	cIdModel	:= aParam[3]
	
	//-----------------------------+
	// Apos a gravação do registro |
	//-----------------------------+ 
	If cIdPonto == "MODELCOMMITTTS"
		//-----------------------+
		// Carrega Objetos Model |
		//-----------------------+
		oModel		:= FwModelActive()
		oModelSB1	:= oModel:GetModel( 'SB1MASTER' )
		
		//-------------------------+
		// Alteração do Fornecedor |
		//-------------------------+
		If oModel:nOperation == 4
			dbSelectArea("SB1")
			SB1->( dbSetOrder(1) )
			If SB1->( dbSeek(xFilial("SB1") + oModelSB1:GetValue('B1_COD')) )
				RecLock("SB1",.F.)
					SB1->B1_XDTALT := dDataBase 
					SB1->B1_XHRALT := Time()
				SB1->( MsUnLock() )	
			EndIf	
		EndIf
	EndIf
	
EndIf
		
RestArea(aArea)		
Return .T.