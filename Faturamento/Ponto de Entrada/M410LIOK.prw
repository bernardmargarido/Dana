#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M410LIOK ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 07/06/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validação na linha do pedido de venda.                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function M410LIOK()

Local cCliBred	:= ""
Local cGrpSB1	:= ""
Local cQuery	:= ""
Local bValid	:= ""
Local cCampo	:= ""
Local cProdif	:= ""
Local cNatNBo	:= ALLTRIM(GETMV("MV_XNATNBO")) // Nat. Nota com Bonificação filial 06
Local cTbDif06	:= ALLTRIM(GETMV("MV_XPRONST")) // Produtos que não incidem ST para filial 06
Local cNatQryB	:= StrTran(cNatNBo,"/","','")

Local lTbDif06	:= .F.
Local _lWeb		:= IIF(ValType(__cInternet) <> "U",.T.,.F.)
Local _aTbDif06	:= Separa(cTbDif06,"/")
Local lTESB1	:= .F.
Local cTipCli	:= Alltrim(M->C5_TIPOCLI)


SetPrvt("_nLinGetD,_nPosCan,_cCan,ACOLS,_cCpo,_flagdel,_DesPed,_DesMax,_SZ8des")
SetPrvt("_nPosDat,_cDat,_nPosPro,_cPro,_CTS,_nPosUse,_cVal,_nPosVal,_cUse")
SetPrvt("_nPosEmi,_cEmi,_nPosQtd,_cQtd,_nPosPru,_cPru,_cPrv,_nPosPrv,_cTES,_nPosTES,_nPosClasFis,_nPosCf,_cClasFis,_cSitTrib,_cOrigem,_cNatnfSt,_cCfST,_BaseRed")

lRet := .T.

If Alltrim(FUNNAME()) == "MATA311"
	Return lRet
Endif

If (Altera .or. Inclui) .And. M->C5_TIPO == "N" .And. xFilial("SC5") =="06"//Tratamento para pedidos Filial 06 WebService
	_nPosTES 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"})
	_nPosClasFis:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_CLASFIS"})
	_nPosPro 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
	_nPosNat	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_NATNOTA"})
	
	aCols[n, _nPosNat] := M->C5_NATNOTA

	_cPro    	:= aCols[n, _nPosPro]
	
	//------------------------------------+
	// Valida se produto não inside em ST |
	//------------------------------------+
	If aScan(_aTbDif06,{|x| RTrim(x) == RTrim(_cPro)}) > 0
		lTbDif06	:= .T.
	EndIf
	
	/*
	For nX1 := 1 To Len(cTbDif06)
	If !Substr(cTbDif06,nX1,1) == '/' .And. (nX1 <> Len(cTbDif06))
	cProdif += Substr(cTbDif06,nX1,1)
	Else
	If Alltrim(_cPro) == cProdif
	lTbDif06	:= .T.
	Endif
	cProdif	:= ""
	EndIf
	Next nX1
	*/
	
	_cTESB1  	:= Posicione('SB1',1,xFilial('SB1')+_cPro,'B1_TS')
	
	If _cTESB1 == "522"//Produtos Hair
		_cSitTrib 	:= Posicione('SF4',1,xFilial('SF4')+_cTESB1,'F4_SITTRIB')
		_cOrigem  	:= Posicione('SB1',1,xFilial('SB1')+_cPro,'B1_ORIGEM')
		aCols[n, _nPosTES] 		:= _cTESB1
		aCols[n, _nPosClasFis] 	:= Alltrim(_cOrigem)+Alltrim(_cSitTrib)		
		If !Altera 
			lTESB1	:= .T.
		Endif
	Endif
	
	If Alltrim(M->C5_XATUTES) == "S" .And. !lTESB1
		If Alltrim(M->C5_NATNOTA) $ cNatNBo
			If lTbDif06
				_cTES    	:= "504"//Bonificação sem incidencia de ST
				_cSitTrib 	:= Posicione('SF4',1,xFilial('SF4')+_cTES,'F4_SITTRIB')
				_cOrigem  	:= Posicione('SB1',1,xFilial('SB1')+_cPro,'B1_ORIGEM')
				aCols[n, _nPosTES] 		:= _cTES
				aCols[n, _nPosClasFis] 	:= Alltrim(_cOrigem)+Alltrim(_cSitTrib)
			Else
				_cTES    	:= "503"//Bonificação
				_cSitTrib 	:= Posicione('SF4',1,xFilial('SF4')+_cTES,'F4_SITTRIB')
				_cOrigem  	:= Posicione('SB1',1,xFilial('SB1')+_cPro,'B1_ORIGEM')
				aCols[n, _nPosTES] 		:= _cTES
				aCols[n, _nPosClasFis] 	:= Alltrim(_cOrigem)+Alltrim(_cSitTrib)
			Endif
		Else
			If lTbDif06
				_cTES    	:= "502"//Venda sem incidencia de ST
				_cSitTrib := Posicione('SF4',1,xFilial('SF4')+_cTES,'F4_SITTRIB')
				_cOrigem  := Posicione('SB1',1,xFilial('SB1')+_cPro,'B1_ORIGEM')
				aCols[n, _nPosTES] 		:= _cTES
				aCols[n, _nPosClasFis] 	:= Alltrim(_cOrigem)+Alltrim(_cSitTrib)
			Else
				_cTES    	:= "501"//Venda
				_cSitTrib := Posicione('SF4',1,xFilial('SF4')+_cTES,'F4_SITTRIB')
				_cOrigem  := Posicione('SB1',1,xFilial('SB1')+_cPro,'B1_ORIGEM')
				aCols[n, _nPosTES] 		:= _cTES
				aCols[n, _nPosClasFis] 	:= Alltrim(_cOrigem)+Alltrim(_cSitTrib)
			Endif
		Endif
	Endif
Else
	If ALTERA .OR. INCLUI
		If Alltrim(M->C5_TIPO) == "N"
			If Alltrim(M->C5_XATUTES) == "S"
				
				_cCli    	:= M->C5_CLIENTE
				_LojC		:= M->C5_LOJACLI
				
				_nPosPro 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
				_cPro    	:= aCols[n, _nPosPro]
				
				_nPosTES 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"})
				_cTES		:= aCols[n, _nPosTES]
				
				_nPosNat	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_NATNOTA"})
				_cNatNFSt	:= aCols[n, _nPosNat]
				
				cGrpSB1		:= Posicione("SB1",1,xFilial("SB1")+_cPro,"B1_GRTRIB")
				cCliUF  	:= Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJAENT),"A1_EST")
				cCliSuf 	:= Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJAENT),"A1_CALCSUF")
				cNumSuf 	:= Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJAENT),"A1_SUFRAMA")
				cCliBred 	:= Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJAENT),"A1_BASERED")
				cRegEsp 	:= Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJAENT),"A1_XREGESP")
				cTPNatNF	:= Posicione("SZH",1,xFilial("SZH")+M->C5_NATNOTA,"ZH_TIPOFAT")
				nMargSF7	:= 0
				lAchoSF7	:= .F.
				
				DbSelectArea("SF7")
				DbSetOrder(1)
				If DbSeek(xFilial("SF7")+cGrpSB1)
					While SF7->(!Eof()) .And. xFilial("SF7")+cGrpSB1 == SF7->(F7_FILIAL+F7_GRTRIB) .And. !lAchoSF7
						If cCliUF == Alltrim(SF7->F7_EST) .And. (cTipCli == Alltrim(SF7->F7_TIPOCLI) .Or. Alltrim(SF7->F7_TIPOCLI) == "*")
							nMargSF7	:= SF7->F7_MARGEM
							lAchoSF7	:= .T.
						Endif
						SF7->(DbSkip())
					Enddo
				Endif
				
				If Select("TRBSZH") > 0
					TRBSZH->(DbCloseArea())
				Endif
				
				If !Empty(cGrpSB1) 
					If Alltrim(M->C5_NATNOTA) $ cNatNBo
						cQuery	:= " SELECT * FROM "+RetSqlName("SZH")+" SZH (NOLOCK) "
						cQuery	+= " WHERE ZH_GRTRIB LIKE '%"+Alltrim(cGrpSB1)+"%' "
						cQuery	+= " AND ZH_FILIAL = '"+cFilAnt+"' "
						cQuery	+= " AND ZH_CODNAT IN('"+cNatQryB+"') "
						cQuery	+= " AND SZH.D_E_L_E_T_ = '' "
						PLSQUERY(cQuery,"TRBSZH")
					Else
						cQuery	:= " SELECT * FROM "+RetSqlName("SZH")+" SZH (NOLOCK) "
						cQuery	+= " WHERE ZH_GRTRIB LIKE '%"+Alltrim(cGrpSB1)+"%' "
						cQuery	+= " AND ZH_FILIAL = '"+cFilAnt+"' "
						cQuery	+= " AND ZH_CODNAT NOT IN('"+cNatQryB+"') "
						cQuery	+= " AND SZH.D_E_L_E_T_ = '' "
						PLSQUERY(cQuery,"TRBSZH")
					Endif
				Endif
				
				If Select("TRBSZH") > 0
					If !Empty(TRBSZH->ZH_CODNAT)
						If TRBSZH->ZH_FILIAL == "07"//Maceio
							If TRBSZH->ZH_TIPOFAT == "1"//Venda
								If cTipCli == "R"//Revendedor
									If cCliUF == "AL" .And. cRegEsp == "1" //AL e Regime Especial
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= TRBSZH->ZH_TES18
									ElseIf nMargSF7 <> 0 .And. cRegEsp <> "1" //Com ST
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= TRBSZH->ZH_TES//cValToChar(TRBSZH->ZH_FSPCST)//Com ST
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPSST)//cValToChar(TRBSZH->ZH_FSPSST)//Sem ST
									Endif
								Elseif cTipCli == "S"//Solidário
									If nMargSF7 <> 0 .And. cRegEsp <> "1" //Com ST
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= TRBSZH->ZH_TES//cValToChar(TRBSZH->ZH_FSPCST)//Com ST
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= TRBSZH->ZH_TES//cValToChar(TRBSZH->ZH_FSPSST)//Sem ST
									Endif
								Endif
							Elseif TRBSZH->ZH_TIPOFAT == "2"//Bonificação
								If cTipCli == "R"//Revendedor
									If nMargSF7 <> 0 .And. cRegEsp <> "1" //Com ST
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= TRBSZH->ZH_TES//cValToChar(TRBSZH->ZH_FSPCSTB)//Com ST Bonificação
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPSST)//cValToChar(TRBSZH->ZH_FSPSSTB)//Sem ST Bonificação
									Endif
								ElseIf cTipCli == "S"//Solidário
									If nMargSF7 <> 0 .And. cRegEsp <> "1" //Com ST
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= TRBSZH->ZH_TES//cValToChar(TRBSZH->ZH_FSPCSTB)//Com ST Bonificação
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= TRBSZH->ZH_TES//cValToChar(TRBSZH->ZH_FSPSSTB)//Sem ST Bonificação
									Endif
								Endif
							Endif
						Else
							If Alltrim(cTPNatNF) == "1"//Venda
								If cCliUF == "SP" .And. !Alltrim(cGrpSB1) $"100"
									If Alltrim(cCliBred)=="S" //Com Base Reduzida
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_BRSPSIM)//Base reduzida
									Else//Sem Base Reduzida
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_BRSPNAO)//Sem Base reduzida
									Endif
								Elseif cCliSuf == "S" .And. (!Alltrim(cGrpSB1) $"100" .Or. !cCliUF $"RO/AC")//Zona Franca
									If Alltrim(cCliBred)=="S" .Or. nMargSF7 <> 0 //Com Base Reduzida
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFCOMST)//Zona Base reduzida
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFSEMST)//Zona sem Base reduzida
									Endif
								Elseif Alltrim(cGrpSB1) $"100" .And. cCliUF $"RO/AC"//Talco RO e AC
									If Alltrim(cCliBred)=="S" .Or. nMargSF7 <> 0 //Com Base Reduzida
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFCOMST)//Zona Base reduzida
									Elseif cCliSuf <> "S" .And. Empty(cNumSuf)
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_TES18)//Fora de SP sem ST
									Elseif cCliSuf <> "S" .And. !Empty(cNumSuf)//Tem Num. Suframa, sem direito a desconto
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPSST)
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFSEMST)//Zona sem Base reduzida	
									Endif	
								Elseif !Alltrim(cGrpSB1) $"100"
									If nMargSF7 <> 0 .And. cRegEsp <> "1" //Com ST
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPCST)//Fora de SP com ST
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPSST)//Fora de SP sem ST
									Endif
								Endif
							Else//Bonificação
								If cCliUF == "SP" .And. !Alltrim(cGrpSB1) $"100"
									If Alltrim(cCliBred)=="S" //Com Base Reduzida
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_BRSPSIB)//Base reduzida Bonificação
									Else//Sem Base Reduzida
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_BRSPNAB)//Sem Base reduzida Bonificação
									Endif
								Elseif cCliSuf == "S" .And. !(Alltrim(cGrpSB1) $"100" .Or. cCliUF $"RO/AC")//Zona Franca
									If Alltrim(cCliBred)=="S" .Or. nMargSF7 <> 0 //Com Base Reduzida
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFCOSTB)//Zona Franca com Base Reduzida Bonificação.
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFSESTB)//Zona Franca sem Base Reduzida Bonificação.
									Endif
								Elseif Alltrim(cGrpSB1) $"100" .And. cCliUF $"RO/AC"//Talco RO e AC
									If Alltrim(cCliBred)=="S" .Or. nMargSF7 <> 0 //Com Base Reduzida
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFCOSTB)//Zona Franca com Base Reduzida Bonificação.
									Elseif cCliSuf <> "S" .And. Empty(cNumSuf)
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_TES18)//Fora de SP sem ST
									Elseif cCliSuf <> "S" .And. !Empty(cNumSuf)//Tem Num. Suframa, sem direito a desconto
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPSSTB)//Fora de SP sem ST Bonificação
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFSESTB)//Zona Franca sem Base Reduzida Bonificação.
									Endif	
								Elseif !Alltrim(cGrpSB1) $"100"
									If nMargSF7 <> 0 .And. cRegEsp <> "1" //Com ST
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPCSTB)//Fora de SP com ST Bonificação
									Else
										aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
										aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPSSTB)//Fora de SP sem ST Bonificação
									Endif
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
Endif

If Select("TRBSZH") > 0
	TRBSZH->(DbCloseArea())
Endif

/*-----------------------------\
| Executa validações no campo. |
\-----------------------------*/
If ALTERA .OR. INCLUI
	If Alltrim(M->C5_TIPO) == "N"
		If Alltrim(M->C5_XATUTES) == "S"
			M->C6_TES := aCols[n, _nPosTES]
			DNEnterCpo("C6_TES", aCols[n, _nPosTES], n)
			//DNEnterCpo("C6_TES", M->C6_TES, n)
		Endif
	Endif
Endif

/*----------------\
| Atualiza linha. |
\----------------*/
GETDREFRESH()

Return(lRet)


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DNEnterCpo ¦ Autor ¦ Clayton Martins  ¦ Data ¦ 05/11/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualiza validações do campo. Simula ENTER.                ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function DNEnterCpo(cCampo, ValorDoCampo, nLin)

Local cVarAtu  := ReadVar()
Local lRet     := .T.
Local cPrefixo := "M->"
Local bValid

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A variavel __ReadVar e padrao do sistema, ela identifica o campo atualmente posicionado. ³
//³ Mude o conteudo desta variavel para disparar as validacoes e gatilhos do novo campo.     ³
//³ Nao esquecer de voltar o conteudo original no final desta funcao.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
__ReadVar := cPrefixo+cCampo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valoriza o campo atual "Simulado".                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
&(cPrefixo+cCampo) := ValorDoCampo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega validacoes do campo.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->( dbSetOrder(2) )
SX3->( dbSeek(cCampo) )
bValid := "{|| "+IIF(!Empty(SX3->X3_VALID),Rtrim(SX3->X3_VALID)+IIF(!Empty(SX3->X3_VLDUSER),".And.",""),"")+Rtrim(SX3->X3_VLDUSER)+" }"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa validacoes do campo.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := Eval( &(bValid) )

IF lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa gatilhos do campo.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->(DbSetOrder(2))
	SX3->(DbSeek(cCampo))
	IF ExistTrigger(cCampo)
		RunTrigger(2,nLin)
	EndIF
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna __ReadVar com o valor original.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
__ReadVar := cVarAtu

n := nLin

Return lRet
