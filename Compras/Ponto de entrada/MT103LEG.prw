#INCLUDE 'PROTHEUS.CH'

/****************************************************************************/
/*/{Protheus.doc} MT103LEG

@description Ponto de Entrada - Adiciona Legenda customizada

@author Bernard M. Margarido
@since 19/11/2018
@version 1.0

@type function
/*/
/****************************************************************************/
User Function MT103LEG()
Local _aLeg		:= aClone(ParamIxb[1])

//---------------------------------------+
// Novas cores integração Protheus X WSM |
//---------------------------------------+ 
If SF1->( FieldPos("F1_XENVWMS") ) > 0 

	aAdd(_aLeg,{"BR_AZUL_CLARO","Aguardando envio ao WMS."})
	aAdd(_aLeg,{"BR_PRETO","Aguardando conferencia."})

EndIf

Return _aLeg