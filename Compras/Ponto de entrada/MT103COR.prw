#INCLUDE 'PROTHEUS.CH'

/************************************************************************************/
/*/{Protheus.doc} MT103COR
	@description Ponto de Entrada - Adiciona novas cores legenda 
	@author Bernard M. Margarido
	@since 19/11/2018
	@version 1.0
	@type function
/*/
/************************************************************************************/
User Function MT103COR()
Local _aCores 	:= aClone(ParamIxb[1])
Local _aColors	:= {}		

//---------------------------------------+
// Novas cores integração Protheus X WSM |
//---------------------------------------+ 
If SF1->( FieldPos("F1_XENVWMS") ) > 0
	
	aAdd(_aColors,{'F1_XENVWMS=="3".And.Empty(F1_STATUS)'	,'ENABLE'			})	
	aAdd(_aColors,{'F1_XENVWMS=="1".And.Empty(F1_STATUS)'	,'BR_AZUL_CLARO'	})
	aAdd(_aColors,{'F1_XENVWMS=="2".And.Empty(F1_STATUS)'	,'BR_PRETO'			})
	aAdd(_aColors,{'F1_STATUS=="B"'							,'BR_LARANJA'		})
	aAdd(_aColors,{'F1_STATUS=="C"'							,'BR_VIOLETA'		})
	aAdd(_aColors,{'F1_STATUS=="D"'							,'BR_BRANCO'		})
	aAdd(_aColors,{'F1_STATUS=="E"'							,'BR_AZUL_CLARO'	})
	aAdd(_aColors,{'F1_STATUS=="F"'							,'BR_VERDE_ESCURO'	})
	aAdd(_aColors,{'F1_TIPO=="N"'							,'DISABLE'			})
	aAdd(_aColors,{'F1_TIPO=="P"'							,'BR_AZUL'			})
	aAdd(_aColors,{'F1_TIPO=="I"'							,'BR_MARROM'		})
	aAdd(_aColors,{'F1_TIPO=="C"'							,'BR_PINK'			})
	aAdd(_aColors,{'F1_TIPO=="B"'							,'BR_CINZA'			})
	aAdd(_aColors,{'F1_TIPO=="D"'							,'BR_AMARELO'		})
	
	//aEval( _aCores , { |aElem,nIndex| aAdd( _aColors , _aCores[ nIndex ] ) } )
			
EndIf
	
Return _aColors
