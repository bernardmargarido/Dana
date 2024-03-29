#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

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
//Local _cFilWMS	:= GetNewPar("DN_FILWMS","05,06")
Local _cFilMSL  := GetNewPar("DN_FILMSL","07")
Local cEstGNRE	:= GetNewPar("MV_XUFGNRE")
Local cEstSF2	:= GetNewPar("MV_XUFGNRE")

Local cParSub 	:= GetMV("MV_SUBTRIB",,"")
Local cMensAx 	:= ""

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
Local aDetPag	:= aParam[16]
Local aRetSefaz	:= {}
//Local dDtVGNRE	:= DATE() + 2

//Local dNovaData := ""
//Local nMes		:= Month(Date()) + 1 
//Local nAno		:= Year(Date())

//--------------------------+
// Tipo de Nota Transmitida |
//--------------------------+
cNotaES			:= aNota[04]
cTpNota			:= aNota[05]

//dNovaData := DataValida(  "01/" + Alltrim(Str(nMes)) + "/" + Alltrim(Str(nAno))  ,.T.)

If cNotaES == '1' 
	If SF2->F2_FILIAL == "06" .And. SF2->F2_EST $ cParSub .And. Alltrim(SF2->F2_TIPOCLI) == "F" .And. Alltrim(SF2->F2_SERIE) == "50"
		cMensAx := "ICMS EC87/15 recolhimento mensal."
		If !AllTrim(cMensAx) $ cMensCli
			If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
				cMensCli += " "
			EndIf
			cMensCli += AllTrim(cMensAx)
		EndIf
	Endif
EndIf

//---------------+
// Nota de Saida |
//---------------+
If cNotaES == '1' 

	If cFilAnt $ _cFilMSL
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

	//------------------------+
	// Faturamento e-Commerce |
	//------------------------+
	If ValType(cMensCli) == "U"
		cMensCli := ""
	EndIf
	U_DnFatM10(aNota[02],aNota[01],@aDetPag,@cMensCli)

EndIf

/*---------------------------\
| Manutenção Vencimento GNRE.|
\---------------------------*/
cEstSF2	:= ""
dbSelectArea("SF2")
SF2->(dbSetOrder(1))
If SF2->(dbSeek(xFilial("SF2") + aNota[02] + aNota[01]))
	If !Empty(SF2->F2_NFICMST)
		cEstSF2	:= Alltrim(SF2->F2_EST)
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If SE2->(dbSeek(xFilial("SE2") + Alltrim(SF2->F2_NFICMST)))
			If cEstGNRE	$cEstSF2
				RecLock("SE2",.F.)
				//SE2->E2_VENCREA := DataValida(dDtVGNRE,.T.)
				SE2->E2_NATUREZ	:= "ICMS"
				SE2->(MsUnLock())
			Else
				RecLock("SE2",.F.)
				//SE2->E2_VENCREA := Date()	//dNovaData	//DataValida(Date(),.T.)
				SE2->E2_NATUREZ	:= "ICMS"
				SE2->(MsUnLock())						
			Endif
		Endif
	Endif
Endif
/*
dbSelectArea("SF2")
SF2->(dbSetOrder(1))
If SF2->(dbSeek(xFilial("SF2") + aNota[02] + aNota[01]))
	If !Empty(SF2->F2_NFICMST)
		If cEstGNRE	$SF2->F2_EST
			dbSelectArea("SF6")
			SF6->(dbSetOrder(1))//F6_FILIAL+F6_EST+F6_NUMERO
			If SF6->(dbSeek(SF2->F2_FILIAL + SF2->F2_EST + Alltrim(SF2->F2_NFICMST)))
				RecLock("SF6",.F.)
				SF6->F6_DTVENC := DataValida(dDtVGNRE,.T.)
				SF6->(MsUnLock())
			Endif
		Endif
	Endif
Endif
*/

/*---------------------------\
| Manutenção Vencimento FECP.|
\---------------------------*/
dbSelectArea("SF2")
SF2->(dbSetOrder(1))
If SF2->(dbSeek(xFilial("SF2") + aNota[02] + aNota[01]))
	//If !Empty(SF2->F2_NTFECP)
	If !Empty(SF2->F2_GNRFECP)
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If SE2->(dbSeek(xFilial("SE2") + Alltrim(SF2->F2_GNRFECP)))
			//If Altrim(SE2->E2_PREFIXO) 
			RecLock("SE2",.F.)
			//SE2->E2_VENCTO 	:= DataValida(Date()+1,.T.)
			//SE2->E2_VENCREA := Date() //dNovaData	//DataValida(Date(),.T.)
			SE2->E2_NATUREZ	:= "ICMS"
			SE2->(MsUnLock())
		Endif
	Endif
Endif

/*----------------------------\
| Manutenção Vencimento DIFAL.|
\----------------------------*/
dbSelectArea("SF2")
SF2->(dbSetOrder(1))
If SF2->(dbSeek(xFilial("SF2") + aNota[02] + aNota[01]))
	If !Empty(SF2->F2_GNRDIF)
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1))	//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If SE2->(dbSeek(xFilial("SE2") + Alltrim(SF2->F2_GNRDIF)))
			//If Altrim(SE2->E2_PREFIXO) 
			RecLock("SE2",.F.)
			//SE2->E2_VENCTO 	:= DataValida(Date()+1,.T.)
			//SE2->E2_VENCREA := Date()  //dNovaData	//DataValida(Date(),.T.)
			SE2->E2_NATUREZ	:= "ICMS"
			SE2->(MsUnLock())
		Endif
	Endif
Endif

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
aAdd(aRetSefaz, aDetPag)

RestArea(aArea)	
Return aRetSefaz
