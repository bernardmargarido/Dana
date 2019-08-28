#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � M410LIOK � Autor � Clayton Martins    � Data � 07/06/2018  ���
��+----------+------------------------------------------------------------���
���Descri��o � Valida��o na linha do pedido de venda.                     ���
��+----------+------------------------------------------------------------���
���Uso       � PERFUMES DANA    					                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function M410LIOK()

Local cCliBred	:= ""
Local cGrpSB1	:= ""
Local cQuery	:= ""
Local bValid	:= ""
Local cCampo	:= ""
Local cProdif	:= ""
Local cNatNBo	:= ALLTRIM(GETMV("MV_XNATNBO")) // Nat. Nota com Bonifica��o filial 06
Local cTbDif06	:= ALLTRIM(GETMV("MV_XPRONST")) // Produtos que n�o incidem ST para filial 06

Local lTbDif06	:= .F.
Local _lWeb		:= IIF(ValType(__cInternet) <> "U",.T.,.F.)
Local _aTbDif06	:= Separa(cTbDif06,"/")


SetPrvt("_nLinGetD,_nPosCan,_cCan,ACOLS,_cCpo,_flagdel,_DesPed,_DesMax,_SZ8des")
SetPrvt("_nPosDat,_cDat,_nPosPro,_cPro,_CTS,_nPosUse,_cVal,_nPosVal,_cUse")
SetPrvt("_nPosEmi,_cEmi,_nPosQtd,_cQtd,_nPosPru,_cPru,_cPrv,_nPosPrv,_cTES,_nPosTES,_nPosClasFis,_nPosCf,_cClasFis,_cSitTrib,_cOrigem,_cNatnfSt,_cCfST,_BaseRed")

lRet := .T.

If (Altera .or. Inclui) .And. M->C5_TIPO == "N" .And. xFilial("SC5") == "06"//Tratamento para pedidos Filial 06 WebService
	_nPosTES 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"})
	_nPosClasFis:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_CLASFIS"})
	_nPosPro 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
	_nPosNat	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_NATNOTA"})
	
	aCols[n, _nPosNat] := M->C5_NATNOTA

	_cPro    	:= aCols[n, _nPosPro]
	
	//------------------------------------+
	// Valida se produto n�o inside em ST |
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
	
	If Alltrim(M->C5_XATUTES) == "S"
		If Alltrim(M->C5_NATNOTA) $ cNatNBo
			If lTbDif06
				_cTES    	:= "504"//Bonifica��o sem incidencia de ST
				_cSitTrib 	:= Posicione('SF4',1,xFilial('SF4')+_cTES,'F4_SITTRIB')
				_cOrigem  	:= Posicione('SB1',1,xFilial('SB1')+_cPro,'B1_ORIGEM')
				aCols[n, _nPosTES] 		:= _cTES
				aCols[n, _nPosClasFis] 	:= Alltrim(_cOrigem)+Alltrim(_cSitTrib)
			Else
				_cTES    	:= "503"//Bonifica��o
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
				cCliBred 	:= Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJAENT),"A1_BASERED")
				cTPNatNF	:= Posicione("SZH",1,xFilial("SZH")+M->C5_NATNOTA,"ZH_TIPOFAT")
				nMargSF7	:= 0
				lAchoSF7	:= .F.
				
				DbSelectArea("SF7")
				DbSetOrder(1)
				If DbSeek(xFilial("SF7")+cGrpSB1)
					While SF7->(!Eof()) .And. xFilial("SF7")+cGrpSB1 == SF7->(F7_FILIAL+F7_GRTRIB) .And. !lAchoSF7
						If cCliUF == Alltrim(SF7->F7_EST)
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
					cQuery	:= " SELECT * FROM "+RetSqlName("SZH")+" SZH (NOLOCK) "
					cQuery	+= " WHERE ZH_GRTRIB LIKE '%"+Alltrim(cGrpSB1)+"%' "
					cQuery	+= " AND SZH.D_E_L_E_T_ = '' "
					PLSQUERY(cQuery,"TRBSZH")
				Endif
				
				If Select("TRBSZH") > 0
					If !Empty(TRBSZH->ZH_CODNAT)
						If Alltrim(cTPNatNF) == "1"//Venda
							If cCliUF == "SP"
								If Alltrim(cCliBred)=="S" //Com Base Reduzida
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_BRSPSIM)//Base reduzida
								Else//Sem Base Reduzida
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_BRSPNAO)//Sem Base reduzida
								Endif
							Elseif cCliSuf == "S"//Zona Franca
								If Alltrim(cCliBred)=="S" //Com Base Reduzida
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFCOMST)//Zona Base reduzida
								Else
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFSEMST)//Zona sem Base reduzida
								Endif
							Else
								If nMargSF7 <> 0 //Com ST
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPCST)//Fora de SP com ST
								Else
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPSST)//Fora de SP sem ST
								Endif
							Endif
						Else//Bonifica��o
							If cCliUF == "SP"
								If Alltrim(cCliBred)=="S" //Com Base Reduzida
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_BRSPSIB)//Base reduzida Bonifica��o
								Else//Sem Base Reduzida
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_BRSPNAB)//Sem Base reduzida Bonifica��o
								Endif
							Elseif cCliSuf == "S"//Zona Franca
								If Alltrim(cCliBred)=="S" //Com Base Reduzida
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFCOSTB)//Zona Franca com Base Reduzida Bonifica��o.
								Else
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_ZFSESTB)//Zona Franca sem Base Reduzida Bonifica��o.
								Endif
							Else
								If nMargSF7 <> 0 //Com ST
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPCSTB)//Fora de SP com ST Bonifica��o
								Else
									aCols[n, _nPosNat]	:= TRBSZH->ZH_CODNAT
									aCols[n, _nPosTES]	:= cValToChar(TRBSZH->ZH_FSPSSTB)//Fora de SP sem ST Bonifica��o
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
| Executa valida��es no campo. |
\-----------------------------*/
If ALTERA .OR. INCLUI
	If Alltrim(M->C5_TIPO) == "N"
		If Alltrim(M->C5_XATUTES) == "S"
			DNEnterCpo("C6_TES", aCols[n, _nPosTES], n)
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
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � DNEnterCpo � Autor � Clayton Martins  � Data � 05/11/2018  ���
��+----------+------------------------------------------------------------���
���Descri��o � Atualiza valida��es do campo. Simula ENTER.                ���
��+----------+------------------------------------------------------------���
���Uso       � PERFUMES DANA    					                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function DNEnterCpo(cCampo, ValorDoCampo, nLin)

Local cVarAtu  := ReadVar()
Local lRet     := .T.
Local cPrefixo := "M->"
Local bValid

//������������������������������������������������������������������������������������������Ŀ
//� A variavel __ReadVar e padrao do sistema, ela identifica o campo atualmente posicionado. �
//� Mude o conteudo desta variavel para disparar as validacoes e gatilhos do novo campo.     �
//� Nao esquecer de voltar o conteudo original no final desta funcao.                        �
//��������������������������������������������������������������������������������������������
__ReadVar := cPrefixo+cCampo

//�����������������������������������������������������Ŀ
//� Valoriza o campo atual "Simulado".                  �
//�������������������������������������������������������
&(cPrefixo+cCampo) := ValorDoCampo

//�����������������������������������������������������Ŀ
//� Carrega validacoes do campo.                        �
//�������������������������������������������������������
SX3->( dbSetOrder(2) )
SX3->( dbSeek(cCampo) )
bValid := "{|| "+IIF(!Empty(SX3->X3_VALID),Rtrim(SX3->X3_VALID)+IIF(!Empty(SX3->X3_VLDUSER),".And.",""),"")+Rtrim(SX3->X3_VLDUSER)+" }"

//�����������������������������������������������������Ŀ
//� Executa validacoes do campo.                        �
//�������������������������������������������������������
lRet := Eval( &(bValid) )

IF lRet
	//�����������������������������������������������������Ŀ
	//� Executa gatilhos do campo.                          �
	//�������������������������������������������������������
	SX3->(DbSetOrder(2))
	SX3->(DbSeek(cCampo))
	IF ExistTrigger(cCampo)
		RunTrigger(2,nLin)
	EndIF
EndIF

//�����������������������������������������������������Ŀ
//� Retorna __ReadVar com o valor original.             �
//�������������������������������������������������������
__ReadVar := cVarAtu

n := nLin

Return lRet
