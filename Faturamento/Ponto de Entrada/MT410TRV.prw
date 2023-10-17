#INCLUDE 'PROTHEUS.CH'

/***************************************************************************/
/*/{Protheus.doc} MT410TRV
    @description Ponto de Entrada - Liberação da trava de registros
    @author Bernard M. Margarido
    @since 23/01/2019
    @version 1.0
    @type function
/*/
/***************************************************************************/
User Function MT410TRV()
Local cCliForn 	:= ParamIXB[1] // Codigo do Cliente/Fornecedor 
Local cLoja 	:= ParamIXB[2] // Loja 
Local cTipo 	:= ParamIXB[3] // C=Cliente(SA1) - F=Fornecedor(SA2) 
 
Local lTravaSA1 := .F. // Desliga trava da tabela SA1 
Local lTravaSA2 := .F. // Desliga trava da tabela SA2 
Local lTravaSB2 := .F. // Desliga trava da tabela SB2 

Local aRet 		:= Array(4)

Local aRet[1] 	:= lTravaSA1 
Local aRet[2] 	:= lTravaSA2 
Local aRet[3] 	:= lTravaSB2 

CoNout('MT410TRV - Pedido de Venda - Lock Desligado.')
 	
Return aRet
