#INCLUDE 'PROTHEUS.CH'

/*****************************************************************************/
/*/{Protheus.doc} PE01NFESEFAZ
	@description Ponto de Entrada - NFESefaz
	@author Bernard M. Margarido
	@since 26/11/2018
	@version 1.0
	@type function
/*/
/*****************************************************************************/
User Function PE01NFESEFAZ()
Local aArea		:= GetArea()
Local aProd		:= aParam[1]

Local cMensCli	:= aParam[2]
Local cMensFis	:= aParam[3]
Local cNotaES	:= ""
Local cTpNota	:= ""
Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")
Local _cFilMSL  := GetNewPar("DN_FILMSL","07")

Local aDest 	:= aParam[4]
Local aNota 	:= aParam[5]
Local aInfoItem	:= aParam[6]  
Local aDupl		:= aParam[7]
Local aTransp	:= aParam[8]
Local aEntrega	:= aParam[9]
Local aRetirada	:= aParam[10]
Local aVeiculo	:= aParam[11]
Local aReboque	:= aParam[12]
Local aNfVincRur:= aParam[13]
Local aEspVol   := aParam[14]
Local aNfVinc	:= aParam[15]
Local aRetSefaz	:= {}

//--------------------------+
// Tipo de Nota Transmitida |
//--------------------------+
cNotaES			:= aNota[04]
cTpNota			:= aNota[05]

//---------------+
// Nota de Saida |
//---------------+
If cNotaES == '1' .And. cFilAnt $ _cFilMSL
	
	//----------------+
	// Posiciona Nota |
	//----------------+
	If cTpNota $ 'N|B|D'
		//----------------------+
		// Posciona Nota Fiscal |
		//----------------------+
		dbSelectArea("SF2")
		SF2->( dbSetOrder(1) )
		SF2->( dbSeek(xFilial("SF2") + aNota[02] + aNota[01]) )
		RecLock("SF2",.F.)
			SF2->F2_XDTALT := Date()
			SF2->F2_XHRALT := Time()
			SF2->F2_XENVWMS:= "1"
		SF2->( MsUnLock() )
	EndIf
	
EndIf

aAdd(aRetSefaz, aProd )
aAdd(aRetSefaz, cMensCli)
aAdd(aRetSefaz, cMensFis)
aAdd(aRetSefaz, aDest)
aAdd(aRetSefaz, aNota)
aAdd(aRetSefaz, aInfoItem)  
aAdd(aRetSefaz, aDupl)
aAdd(aRetSefaz, aTransp)
aAdd(aRetSefaz, aEntrega)
aAdd(aRetSefaz, aRetirada)
aAdd(aRetSefaz, aVeiculo)
aAdd(aRetSefaz, aReboque)
aAdd(aRetSefaz, aNfVincRur)
aAdd(aRetSefaz, aEspVol)
aAdd(aRetSefaz, aNfVinc)

RestArea(aArea)	
Return aRetSefaz