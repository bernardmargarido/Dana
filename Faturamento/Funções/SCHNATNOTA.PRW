#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±
±³SISTEMA   ³ SIGA Advanced ³ MODULO ³ Faturamento ³ PROGRAMA ³ SCHNATNOTA   ³±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³FINALIDADE³ PROCURAR NATNOTA CORRETO PARA O ITEM DA NOTA FISCAL DE SAIDA   ³±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³AUTOR     ³  RENATO PAIVA - SYMM CONSULTORIA				      ±
±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³               R E G I S T R O S   D E   A L T E R A € å E S               ³±
±ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³  DATA  ³   AUTOR  ³               A  L  T  E  R  A  €  Ç  O               ³±
±³24.08.12³Evandro   ³ Criado consulta para localização da NATNOTA           ³±
±³        ³          ³                                                       ³±
±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SCHNATNOTA(xFil,cNatCab,cProd,cCliente,cLoja,cOrigem)

Local clQry	    := ""
Local clQry2    := ""
Local clTpFat   := ""
Local clIpi		:= ""
Local clAl18	:= ""
Local clAl25	:= ""
Local clIcmRet  := ""
Local clCodZfm  := ""
Local clGrpCli  := ""
Local clGrpPrd  := ""
Local clEstCli  := ""
Local clEstSZH  := ""
Local clRet		:= ""
Local clTalco	:= ""
Local clArmz	:= ""
Local clBaseR   := ""
Local clTpCli   := ""
Local clRetAlq	:= Space(2)
Local ll25Qry   := .F.
Local clEspuma	:= ""
Local clRegEsp := '2'

Local cAlias	:= GetNextAlias()
Local cAlias2   := GetNextAlias()
Local clNatSt	:= GetMv("MV_NATST",,"SP")
Local clNatSu	:= GetMv("MV_NATSU",,"RS|MG|PE|SC|PR")
//Local cNatTra	:= Alltrim(GetMv("MV_XNATNTR"))
//Local clNatTra	:= Strtran(cNatTra,"','","/")
//Local clNatZf	:= GetMv("MV_NATZF",,"AM")

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1")+cCliente+cLoja,.F.)
	clCodZfm := IIf(Alltrim(SA1->A1_SUFRAMA)=="","2","1")
	clGrpCli := SA1->A1_GRPTRIB
	clEstCli := SA1->A1_EST
	clBaseR  := SA1->A1_BASERED
	clTpCli  := SA1->A1_TIPO
EndIf

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1")+cProd)
	clIpi 	 := IIf(SB1->B1_IPI==0 .Or. (SB1->B1_IPI <>0 .And. Alltrim(SB1->B1_GRTRIB)<>'100'),"2","1")
	clAl18	 := IIf(SB1->B1_PICM==18,"1","")
	clAl25	 := IIf(SB1->B1_PICM==25,"1","")
	clTalco  := IIf(Alltrim(SB1->B1_GRTRIB) == '100',"1","2")
	clEspuma := IIf(Alltrim(SB1->B1_GRTRIB) == '107',"1","2")
	clGrpPrd := (Alltrim(SB1->B1_GRTRIB))
	clArmz   := SB1->B1_LOCPAD
EndIf

DbSelectArea('SZH')
DbSetOrder(1)
If DbSeek(xFilial('SZH')+AllTrim(cNatCab))
	clTpFat  := SZH->ZH_TIPOFAT
	clIcmRet := SZH->ZH_CICMRET //Normal
EndIf

If (clTpFat == '4') .And. (clAl25 == '1') .And. (AllTrim(clEstCli) == clNatSt) .And. (clArmz == '30') // Tratamento para SB Aliq 25% SP
	clTpFat  := '2'
	clIcmRet := '2'
	ll25Qry  := .T.
ElseIf (clAl25 == '1') .And. (AllTrim(clEstCli) == clNatSt) .And. (clArmz == '30') // Aliq 25%  ST
	clIcmRet := '2'
	ll25Qry  := .T.
ElseIf (clEspuma == '1') .And. AllTrim(clEstCli) == 'PR'
	clEstSZH := clEstCli
EndIf

If ((clAl25 == '1') .Or. AllTrim(clEstCli) == 'AP') .And. !(clGrpPrd $'108/115')   //If ((clAl25 == '1') .Or. AllTrim(clEstCli) == 'AP') .And. clGrpPrd <> '108'
	clEstSZH := Posicione('SZH',5,xFilial('SZH')+AllTrim(clEstCli),'ZH_EST')
EndIf

clEstSZH := If ((clTpFat == '3') .And. (clTalco == '1') .And. (clEstCli $ clNatSt),clEstCli,clEstSZH) // Ajuste para SP

If (clCodZfm == '1') .And. (clTpFat == '5') // Ajuste TZ Trade
	clTpFat := '5'
ElseIf !(clEstCli $ clNatSt + "|" + clNatSu) .And. (clCodZfm == '2') .And. 	(clTalco == '1') .And. (clTpFat == '5') //Ajuste para BV
	clTpFat := '2'
EndIf

If !Empty(clGrpCli)  .And. clTpCli <> 'R' .And. AllTrim(cNatCab) <> 'VE' //Tratamento para regime esp
	IIf(Posicione('SF7',1,xFilial("SF7")+PADR(SB1->B1_GRTRIB,6," ")+clGrpCli,"F7_MARGEM") > 0,clIcmRet := '1', clIcmRet := '2')
EndIf

clIpi    := IIf (clCodZfm == '1' .And. SA1->A1_CALCSUF == 'S' .And. !Empty(SA1->A1_CODMUN),'2',clIpi) // Zona Franca Não tem IPI
clCodZfm := IIf (clCodZfm == '1' .And. SA1->A1_CALCSUF == 'N' .And. Empty(SA1->A1_CODMUN),'2',clCodZfm) // Zona Franca Não tem IPI

If (clTpFat == '6') .And. (clTalco == '1') .And. (clEstCli $ clNatSt+"|"+clNatSu) //Trade BP
	clTpFat := '4'
	clEstSZH := ' '
ElseIf (clTpFat == '6') .And. (clEstCli $ clNatSt)  .And. clIcmRet == '2' //Trade SM
	clTpFat := '5'
ElseIf (clTpFat == '6') .And. (clCodZfm == '1') // Trade ZB (somente estado configurado na NatNota)
	clEstSZH  := clEstCli
ElseIf (clTpFat == '6') .And. (clAl25 == '1') .And. clEstCli == 'PR'   //Trade SZ Melhorar condicao
	clTpFat := '4'
	ll25Qry := .T.
EndIf

If  clCodZfm == '2' .And. clEstCli == 'PR' .And. clAl25 == '1'   //Ajuste CodNat do paraná
	ll25Qry	 := .T.
	clEstSZH := 'PR'
EndIf
clEstSZH := IIf (clTpFat == '3' .And. clTalco == '2' .And. clIcmRet == '1' .And. clCodZfm == '1','AP',clEstSZH) //Ajuste ZT
clEstSZH := IIf ((clTpFat == '2') .And. (clCodZfm == '1') .And. (clArmz == '30'),'',clEstSZH )  //Ajuste para BZ com aliq especial
clEstSZH := IIf ((clTpFat == '1') .And. (clCodZfm == '1') .And. (clTalco == '2'),'',clEstSZH )  //Ajuste para Itens com aliq especial PV ZFM
clEstSZH := IIf (clEspuma == '1' .And. (!clEstSZH $ 'PR|AP'),'',clEstSZH) // Ajuste para Espuma quando o Estado não for Paraná e Amapá
clEstSZH := IIf ((clTpFat == '3') .And. (clTalco == '2') .And. clEstCli <> 'PR' .And. clEstCli <> 'AP' .And. clEspuma == '1','',clEstSZH) // Ajuste Espuma diferente de Paraná
clIcmRet := IIf (clEstCli == 'AP','1',clIcmRet) //Clientes AP são com ST (regra da Dana)
clTalco  := IIf (clTalco == '1' .And. clTpFat == '5' .And. clTpCli == 'R' .And. cNatCab <> 'BT','2',clTalco) //Gambi para ajustar o talco do TZ
clIcmRet := IIf (clEstCli == 'PR' .And. clTpFat == '6' .And. clEspuma == '1','1',clIcmRet)  // Ajute Aliq 25 PR Trade
clTpFat  := IIf (clEstCli == 'PR' .And. clTpFat == '6' .And. clEspuma == '1','4',clTpFat)   // Força ajuste no Trade Aliq 25 PR
clTpFat  := IIf (clEstCli $ clNatSu .And. clTpFat == '5' .And. clTalco == '1' .And. clCodZfm == '2' .And. cNatCab == 'BT' ,'2',clTpFat) //Tratamento BV com IPI


clQry2 := " SELECT F7_GRTRIB GRP_TRIB "
clQry2 += " ,F7_EST UF "
clQry2 += " ,F7_TIPOCLI TIPO_CLI"
clQry2 += " ,F7_ALIQDST ALIQT"
clQry2 += " ,F7_GRPCLI  GRP_CLI"
clQry2 += " FROM SF7010  "
clQry2 += " WHERE F7_GRTRIB = '" + clGrpPrd + "'"
clQry2 += " AND D_E_L_E_T_ <> '*' "
clQry2 += " AND F7_EST = '" + clEstCli + "'"

DbUseArea(.T., "TOPCONN", TCGenQry(,,clQry2),cAlias2,.T.,.T.)

If (Empty(AllTrim((cAlias2)->GRP_CLI)) .Or. (cAlias2)->GRP_CLI == clGrpCli) .And. Empty(AllTrim(clRetAlq)) .And. clEspuma <> '1' .And. clTalco <> '1' .And. clCodZfm == '2'
	If (cAlias2)->ALIQT == 18
		clRetAlq := '18'
	ElseIf (cAlias2)->ALIQT == 25
		clRetAlq := '25'
	ElseIf (cAlias2)->ALIQT == 12 .And. clEstCli $ clNatSt
		clRegEsp := '1'
	EndIf
EndIf

If  (AllTrim(clEstCli) == clNatSt) .And. (clRetAlq == '25' .Or. clAl25 == '1') .And. !(clGrpPrd $'108/115')  // Aliq 25%  ST   //If  (AllTrim(clEstCli) == clNatSt) .And. (clRetAlq == '25' .Or. clAl25 == '1') .And. clGrpPrd <> '108'  // Aliq 25%  ST
	clIcmRet := '2'
	ll25Qry  := .T.
EndIf

clQry := "SELECT ZH_TIPOFAT"
clQry += " ,ZH_CIPI"
clQry += " ,ZH_CICMRET"
clQry += " ,ZH_ZFM"
clQry += " ,ZH_CODNAT"
clQry += " ,ZH_TALCO"
clQry += " ,ZH_ALQES"
clQry += " FROM " + RETSQLNAME('SZH')
clQry += " WHERE ZH_TIPOFAT = '" + clTpFat + "'"
clQry += " AND ZH_CIPI = '" + clIpi + "'"
clQry += " AND ZH_CICMRET = '" + clIcmRet + "'"
clQry += " AND ZH_ZFM = '" + clCodZfm + "'"
If (clTalco == '1' .And. clTpFat <> '5') .Or. ((clCodZfm == '1') .And. (clTpFat <> '2' .And. clTpFat <> '6'))   // (clTpFat <> '5') Tratamento para Trade BZ/ZB
	clQry += " AND ZH_TALCO = '" + clTalco + "'"
EndIf
If ll25Qry .And. (clCodZfm == '2') /*.And. (clTpFat != '5')*/ .And. Empty(AllTrim(clRetAlq))  //Não usar Alq Esp na ZFM
	clQry += " AND ZH_ALQES = '" + clAl25 + "'"
	clRetAlq := '25'
EndIf
clQry += " AND ZH_EST = '" + clEstSZH  + "'"
clQry += " AND D_E_L_E_T_ <> '*'"
clQry += " AND ZH_FILIAL = " + xFilial('SZH')
/*
If cNatCab $clNatTra
	clQry += " AND ZH_CODNAT IN( " + cNatTra +" ) "
Endif
*/
DbUseArea(.T., "TOPCONN", TCGenQry(,,clQry),cAlias,.T.,.T.)
MemoWrite("D:\Dana\SchNatNota.Sql",clQry)

If clBaseR == 'S' .And. clEstCli $ clNatSt  .And. Empty(AllTrim((cAlias)->ZH_ALQES)) .And. !(clGrpPrd $'108/115')  //Tratamento para base reduzida
	clRetAlq := '18'
ElseIf (clBaseR == 'N' .Or. Empty(Alltrim(clBaseR))) .And. (clEstCli $ clNatSt .Or.  clEstCli $ clNatSu)  .And. (cAlias)->ZH_CODNAT $ 'SU|SV|SY|VE|BO|BT|ZB'
	clRetAlq := ' '
Endif

clRet := (cAlias)->ZH_CODNAT + clRetAlq

If Alltrim(xFilial("SZH")) == "06"
	clRet	:= cNatCab
Endif

Return (clRet)
