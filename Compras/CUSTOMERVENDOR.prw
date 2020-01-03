#INCLUDE 'PROTHEUS.CH'

/****************************************************************************/
/*/{Protheus.doc} CUSTOMERVENDOR

@description Ponto de Entrada - MVC Fornecedores

@author Bernard M. Margarido
@since 25/10/2018
@version 1.0

@type function
/*/
/****************************************************************************/
User Function CUSTOMERVENDOR()
Local aArea		:= GetArea()
Local aParam 	:= ParamIxb

Local cIdPonto	:= ""
Local cIdModel	:= ""

Local oModel	:= Nil
Local oModelSA2	:= Nil
 
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
		oModelSA2	:= oModel:GetModel( 'SA2MASTER' )
		
		//-------------------------+
		// Alteração do Fornecedor |
		//-------------------------+
		If oModel:nOperation == 4
			dbSelectArea("SA2")
			SA2->( dbSetOrder(1) )
			If SA2->( dbSeek(xFilial("SA2") + oModelSA2:GetValue('A2_COD') + oModelSA2:GetValue('A2_LOJA')))
				RecLock("SA2",.F.)
					SA2->A2_XDTALT := dDataBase 
					SA2->A2_XHRALT := Time()
				SA2->( MsUnLock() )	
			EndIf	
		EndIf
	EndIf
	
EndIf
		
RestArea(aArea)		
Return .T.