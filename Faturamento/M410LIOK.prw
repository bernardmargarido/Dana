#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M410LIOK ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 07/06/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualiza o campo de % de comissão conforme cadastro do     ¦¦¦
¦¦¦          ¦ Vendedor.        										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function M410LIOK()

Local lRet			:= .T.
Local nPosProSC6	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nPosComSC6	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_COMIS1"})
Local cProSC6		:= Alltrim(aCols[n,nPosProSC6])
Local cComSC6		:= aCols[n,nPosComSC6]
Local aArea			:= GetArea()
Local cVend			:= M->C5_VEND1
Local cTipCli		:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XTIPCLI")

If M->C5_TIPO <> "N"
	Return(lRet)
EndIf

If Empty(cTipCli)
	Msginfo("Para preencher corretamente o percentual de comissão, deve atualizar no cadastro do cliente se é Atacado ou Varejo","M410LIOK - P E R F U M E S  D A N A")
	Return(lRet)
Endif

If Empty(cVend)
	MsgInfo("Informe o vendedor, para preencher o percentual de comissão!","MT410LIOK - P E R F U M E S  D A N A")
	Return(lRet)
Else
	cCodCateg	:= Posicione("SB1",1,xFilial("SB1")+cProSC6,"B1_XCATEGO")

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	cQuery:= " SELECT A3_XCATE01, A3_XPATA01, A3_XPVAR01, A3_XCATE02, A3_XPATA02, A3_XPVAR02, A3_XCATE03, A3_XPATA03, A3_XPVAR03, A3_XCATE04, A3_XPATA04, A3_XPVAR04, A3_XCATE05, A3_XPATA05, A3_XPVAR05, A3_XCATE06, A3_XPATA06, A3_XPVAR06, A3_XCATE07, A3_XPATA07, A3_XPVAR07, A3_XCATE08, A3_XPATA08, A3_XPVAR08 FROM " + RetSqlname("SA3") + " (NOLOCK) "
	cQuery+= " WHERE A3_COD = '"+cVend+"' "
	cQuery+= " AND A3_FILIAL = '"+xFilial("SA3")+"' "
	cQuery+= " AND D_E_L_E_T_ = '' "
	PLSQUERY(cQuery,"TRB")
	
	If Select("TRB") > 0
		
		If TRB->A3_XCATE01 == cCodCateg
			If cTipCli == "1"//Atacado
				aCols[n,nPosComSC6]	:= TRB->A3_XPATA01
			Else//Varejo
				aCols[n,nPosComSC6]	:= TRB->A3_XPVAR01
			Endif
		Endif
		
		If TRB->A3_XCATE02 == cCodCateg
			If cTipCli == "1"//Atacado
				aCols[n,nPosComSC6]	:= TRB->A3_XPATA02
			Else//Varejo
				aCols[n,nPosComSC6]	:= TRB->A3_XPVAR02
			Endif
		Endif
		
		If TRB->A3_XCATE03 == cCodCateg
			If cTipCli == "1"//Atacado
				aCols[n,nPosComSC6]	:= TRB->A3_XPATA03
			Else//Varejo
				aCols[n,nPosComSC6]	:= TRB->A3_XPVAR03
			Endif
		Endif
		
		If TRB->A3_XCATE04 == cCodCateg
			If cTipCli == "1"//Atacado
				aCols[n,nPosComSC6]	:= TRB->A3_XPATA04
			Else//Varejo
				aCols[n,nPosComSC6]	:= TRB->A3_XPVAR04
			Endif
		Endif
		
		If TRB->A3_XCATE05 == cCodCateg
			If cTipCli == "1"//Atacado
				aCols[n,nPosComSC6]	:= TRB->A3_XPATA05
			Else//Varejo
				aCols[n,nPosComSC6]	:= TRB->A3_XPVAR05
			Endif
		Endif
		
		If TRB->A3_XCATE06 == cCodCateg
			If cTipCli == "1"//Atacado
				aCols[n,nPosComSC6]	:= TRB->A3_XPATA06
			Else//Varejo
				aCols[n,nPosComSC6]	:= TRB->A3_XPVAR06
			Endif
		Endif
		
		If TRB->A3_XCATE07 == cCodCateg
			If cTipCli == "1"//Atacado
				aCols[n,nPosComSC6]	:= TRB->A3_XPATA07
			Else//Varejo
				aCols[n,nPosComSC6]	:= TRB->A3_XPVAR07
			Endif
		Endif
		
		If TRB->A3_XCATE08 == cCodCateg
			If cTipCli == "1"//Atacado
				aCols[n,nPosComSC6]	:= TRB->A3_XPATA08
			Else//Varejo
				aCols[n,nPosComSC6]	:= TRB->A3_XPVAR08
			Endif
		Endif
		
		If Select("TRB") > 0
			TRB->(DbCloseArea())
		Endif
	Endif
Endif

RestArea(aArea)
GETDREFRESH()

Return(lRet)
