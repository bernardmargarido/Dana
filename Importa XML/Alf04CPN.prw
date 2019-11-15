#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*/
{Protheus.doc}	Alf04CPN
Description 	Valida o registro do monitor, e faz a classificacao automatica da pre-nota.  Deve estar posicionado na tabela ZDH.
@param			Nenhum
@return			Nil
@author			
@since			31/10/2017
/*/
User Function Alf04CPN( lIsJob )

Local aRetProc := {.T.,""}
Local aRetNF := {}
Local cToClNFe := SuperGetMV("DN_MAILXML",,"")
Local cVldAg := SuperGetMV("AF_VCLNFAG",,"N")
Local cSubj := ""
Local cBody := ""
Local cTpErr := ""
Local lRet := .T.

Default lIsJob := .F.

Private lInJob := lIsJob

U_ALFVCXML()

If ExistBlock("ALFCLPE1")
	ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: entrou PE ALFCLPE1")
	lRet := ExecBlock("ALFCLPE1",.F.,.F.,ZDH->ZDH_CHAVE)
	If !lRet
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: cancelou classificacao pelo PE ALFCLPE1")
		aRetProc := {.F.,"Erro de Validacao ao Classificar (ALFCLPE1)","E"}
	Else
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: saiu do PE ALFCLPE1")
	EndIf
EndIf

If aRetProc[1]
	If lInJob
		aRetNF:=U_AlfChkChv(ZDH->ZDH_CHAVE)
	Else
		LjMsgRun("Verificando Classificacao da NFe..." ,,{||aRetNF:=U_AlfChkChv(ZDH->ZDH_CHAVE)})
	EndIf
EndIf

If aRetProc[1]
	If aRetNF[2]
		aRetProc := {.F.,"NFe Classificada","C"}
		cTpErr := "C"
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: NFe ja classificada")
	EndIf
EndIf

If aRetProc[1]
	If !aRetNF[1]
		aRetProc := {.F.,"Pre-Nota nao Gerada","E"}
		cTpErr := "E"
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: pre-nota nao gerada")
	EndIf
EndIf

If aRetProc[1]
	If ExistBlock("ALFCLPE2")
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: entrou PE ALFCLPE2")
		lRet := ExecBlock("ALFCLPE2",.F.,.F.,ZDH->ZDH_CHAVE)
		If !lRet
			ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: classificacao cancelada pelo PE ALFCLPE2")
			aRetProc := {.F.,"Erro de Validacao ao Classificar (ALFCLPE2)","E"}
		EndIf
	EndIf
EndIf

If aRetProc[1]
	If cVldAg == "S"
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: inicio da validacao do agendamento de entrega")
		If lInJob
			aRetProc:=ChkAgd(ZDH->ZDH_CHAVE)
		Else
			LjMsgRun("Verificando Entrega dos Produtos..." ,,{||aRetProc:=ChkAgd(ZDH->ZDH_CHAVE)})
		EndIf
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: fim da validacao do agendamento de entrega")
	EndIf
EndIf

If aRetProc[1]
	If ExistBlock("ALFCLPE3")
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: entrou PE ALFCLPE3")
		lRet := ExecBlock("ALFCLPE3",.F.,.F.,ZDH->ZDH_CHAVE)
		If !lRet
			ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: classificacao cancelada pelo PE ALFCLPE3")
			aRetProc := {.F.,"Erro de Validacao ao Classificar (ALFCLPE3)","E"}
		EndIf
	EndIf
EndIf

If aRetProc[1]
	ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: inicio da classificacao")
	If lInJob
		aRetProc := U_ALFCLNFE( ZDH->ZDH_CHAVE, "C", lInJob )
	Else
		LjMsgRun("Processando a Classificacao..." ,,{||aRetProc:=U_ALFCLNFE(ZDH->ZDH_CHAVE,"C") })
	EndIf
	ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: fim da classificacao")
EndIf

If aRetProc[1]

	U_AlfAtStNF( ZDH->ZDH_CHAVE, "C", "NFe Classificada" )
	ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - OK: pre-nota classificada com sucesso")

	If !lInJob
		MsgInfo("Pre-Nota Classificada com Sucesso")
	EndIf

Else
	
	cTpErr :=  aRetProc[Len(aRetProc)]

	U_AlfAtStNF( ZDH->ZDH_CHAVE, cTpErr, Alltrim(aRetProc[2]) , "Classificacao" )

	cSubj := "Monitor XML - Erro ao Classificar a Pré-Nota "+Alltrim(ZDH->ZDH_NUMNF)+" - "+Alltrim(ZDH->ZDH_FORNEC)
	cBody += '</p><font face="Arial">Prezado(a):</font></p>'
	cBody += '</p><font face="Arial"></font></p>'
	cBody += '</p><font face="Arial"></font></p>'
	cBody += '</p><font face="Arial">O XML da NFe '+Alltrim(ZDH->ZDH_NUMNF)+' - '+Alltrim(ZDH->ZDH_FORNEC)+' foi importado para o Monitor XML e gerou a Pre-Nota, porem nao foi possivel fazer a Classificacao Automatica, pelo motivo abaixo:</font></p>'
	cBody += '</p><font face="Arial"> </font></p>'
	cBody += '</p><font face="Arial">'+Alltrim(aRetProc[2])+'</font></p>'
	cBody += '</p><font face="Arial"></font></p>'
	cBody += '</p><font face="Arial"></font></p>'
	cBody += '</p><font face="Arial">Obs.: está é uma mensagem automática gerada pelo sistema Protheus, não responda este e-mail.</font></p>'

	U_DNEnvEMail( Nil, cToClNFe, cSubj, cBody)

	If !lInJob
		Alert(aRetProc[2])
	EndIf

	ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: fim da classificao (pre-nota nao foi classificada)")
	
EndIf

Return(Nil)



/*/
{Protheus.doc}	AlfChkChv
Description 	Verifica, nas tabelas do agendamento (ZC5 e ZC6), se a NF foi entregue.
@param			Chave da NFe
@return			.T. (NFe Classificada) / .F. (NFe Nao Classificada)
@author			
@since			31/10/2017
/*/
User Function AlfChkChv( cChvNFe )

Local cPQry := ""
Local lPreN := .F.
Local lClas := .F.

cPQry := "SELECT "
cPQry += "F1.F1_DOC AS F1DOC, "
cPQry += "F1.F1_STATUS AS F1STATUS "
cPQry += "FROM "
cPQry += RetSqlName("SF1")+ " F1 "
cPQry += "WHERE F1.D_E_L_E_T_ = ' ' "
cPQry += "AND F1.F1_FILIAL = '"+xFilial("SF1")+"' "
cPQry += "AND F1.F1_CHVNFE = '"+cChvNFe+"' "

If(Select("WKXSF1")>0,WKXSF1->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cPQry),"WKXSF1",.T.,.T.)
WKXSF1->(dbGoTop())

If WKXSF1->(!EoF())
	If  !Empty(WKXSF1->F1DOC)
		lPreN := .T.
	EndIf
	If !Empty(WKXSF1->F1STATUS)
		lClas := .T.
	EndIf
EndIf
WKXSF1->(dbCloseArea())		

Return({lPreN,lClas})



/*/
{Protheus.doc}	ChqAgd
Description 	Verifica, nas tabelas do agendamento (ZC5 e ZC6), se a NF foi entregue.
@param			Chave da NFe
@return			Nil
@author			
@since			31/10/2017
/*/
Static Function ChkAgd(cChvNFe)

Local cQry := ""
Local aRet := {.T.,"","G"}
Local cStatus := SuperGetMV("AF_STAGENT",,"|01|03|")
Local cStTrf  := SuperGetMV("AF_STAGTRF",,"|01|04|")

//NFs de Compras
cQry := "SELECT DISTINCT "
cQry += "ZC6.ZC6_STATUS AS ZC6STATUS, "
cQry += "ZC6.ZC6_PRODUT AS ZC6PRODUT, "
cQry += "ZD3.ZD3_PRDFOR AS ZD3PRDFOR, "
cQry += "ZD3.ZD3_ITEMNF AS ZD3ITEMNF, "
cQry += "CODPRO = "
cQry +=  	 " ( SELECT TOP 1 ISNULL(A5.A5_PRODUTO,'') FROM "+RetSqlName("SA5")+" A5 WHERE A5.D_E_L_E_T_ = ' ' "
cQry += 	    "AND A5.A5_FILIAL = '"+xFilial("SA5")+"' "
cQry +=         "AND A5.A5_FORNECE = ZD3.ZD3_CODFOR "
cQry +=         "AND A5.A5_LOJA = ZD3.ZD3_LOJFOR "
cQry +=         "AND A5.A5_CODPRF = ZD3.ZD3_PRDFOR ) "
cQry += "FROM "
cQry += RetSqlName("ZD3")+ " ZD3, "
cQry += RetSqlName("ZC6")+ " ZC6 "
cQry += "WHERE ZD3.D_E_L_E_T_ = ' ' "
cQry += "AND ZD3.ZD3_CHVNFE = '"+cChvNFe+"' "
cQry += "AND ZC6.D_E_L_E_T_ = ' ' "
cQry += "AND ZC6.ZC6_FILIAL = '"+xFilial("ZC6")+"' "
cQry += "AND ZC6.ZC6_NUMPED = ZD3.ZD3_NUMPED "
cQry += "AND ZC6.ZC6_DOC = ZD3.ZD3_NUMNF "

Iif(Select("WCHKAG")>0,WCHKAG->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WCHKAG",.T.,.T.)
WCHKAG->(dbGoTop())

If WCHKAG->(!EoF())
	While WCHKAG->(!EoF())
		If !Empty(WCHKAG->ZC6STATUS)
		    If (Upper(Alltrim(WCHKAG->ZC6PRODUT)) == Upper(Alltrim(WCHKAG->CODPRO))) .Or. (Upper(Alltrim(WCHKAG->ZD3PRDFOR)) == Upper(Alltrim(WCHKAG->CODPRO)))
				If !( WCHKAG->ZC6STATUS $ cStatus )
					aRet := {.F.,"Status da entrega do item "+WCHKAG->ZD3ITEMNF+" nao permite classificacao - status "+WCHKAG->ZC6STATUS,"G" }
					ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: status da entrega do item "+WCHKAG->ZD3ITEMNF+" nao permite classificacao - status "+WCHKAG->ZC6STATUS)
				EndIf
			Else
				aRet := {.F.,"Item "+WCHKAG->ZD3ITEMNF+" nao possui registro de entrega","G" }
				ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: item "+WCHKAG->ZD3ITEMNF+" nao possui registro de entrega")
			EndIf
		Else
			aRet := {.F.,"Nao ha registro de entrega para o item "+WCHKAG->ZD3ITEMNF+" desta NF","G" }
			ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: nao ha registro de entrega para o item "+WCHKAG->ZD3ITEMNF+" desta NF")
		EndIf
		WCHKAG->(dbSkip())

	EndDo
Else
	aRet := {.F.,"Nao ha registro de entrega (agendamento) para esta NF","G"}
	ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - nao ha registro de entrega (agendamento) para esta NF")
EndIf
WCHKAG->(dbCloseArea())


If !aRet[1]

	//NFs de Transferencias entre Filiais
	aRet := {.T.,"","G"}
	cQry := "SELECT DISTINCT "
	cQry += "ZC6.ZC6_STATUS AS ZC6STATUS, "
	cQry += "ZC6.ZC6_PRODUT AS ZC6PRODUT, "
	cQry += "ZD3.ZD3_ITEMNF AS ZD3ITEMNF "
	cQry += "FROM "
	cQry += RetSqlName("ZD3")+ " ZD3, "
	cQry += RetSqlName("ZC6")+ " ZC6 "
	cQry += "WHERE ZD3.D_E_L_E_T_ = ' ' "
	cQry += "AND ZD3.ZD3_CHVNFE = '"+cChvNFe+"' "
	cQry += "AND ZC6.D_E_L_E_T_ = ' ' "
	cQry += "AND ZC6.ZC6_FILIAL = '"+xFilial("ZC6")+"' "
	cQry += "AND ZC6.ZC6_NUMPED = ZD3.ZD3_NUMPED "
	cQry += "AND ZC6.ZC6_ITEM = ZD3.ZD3_ITPCPR "
	cQry += "AND ZC6.ZC6_DOC = ZD3.ZD3_NUMNF "
	
	Iif(Select("WCHKAG")>0,WCHKAG->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WCHKAG",.T.,.T.)
	WCHKAG->(dbGoTop())
	
	If WCHKAG->(!EoF())
		While WCHKAG->(!EoF())
			
			If !( WCHKAG->ZC6STATUS $ cStTrf )
				aRet := {.F.,"Nao ha registro de entrega para o item "+WCHKAG->ZD3ITEMNF+" desta NF","G" }
				ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: nao ha registro de entrega para o item "+WCHKAG->ZD3ITEMNF+" desta NF")
			EndIf
			WCHKAG->(dbSkip())
	
		EndDo
	Else
		aRet := {.F.,"Nao ha registro de entrega (agendamento) para esta NF","G"}
		ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: nao ha registro de entrega (agendamento) para esta NFe")
	EndIf
	WCHKAG->(dbCloseArea())

EndIf

Return(aRet)



/*/
{Protheus.doc}	ALFCLNFE
Description 	Efetua a classificacao automatica da pre-nota
@param			Chave da NFe
@return			Nil
@author			
@since			27/11/2017
/*/
User Function ALFCLNFE( cChvNFe , cAcao , lIsJob)

Local aRtCNFe := {.T.,""}
Local aPgNF := {}
Local aPgPC := {}
Local nPgNF := 0
Local nNx := 0
Local cQry := ""
Local cCodProd := ""
Local cUMProd := ""
Local lPriUM := .F.
Local lSegUM := .F.
Local cCFOP := ""
Local cOriPrd := ""
Local cCstICM := ""
Local cCstPIS := ""
Local cCstCOF := ""
Local cCodTES := ""
Local cCondPG := ""
Local nAliqIPI:= 0
Local nAliqICM:= 0
Local cItemNF := ""
Local cProtocolo := ""
Local cTpErro := "" //Tipo do Erro: E=Compras, F=Fiscal
Local dEmisNF := CtoD("//")
Local aAtuArea := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSC7 := SC7->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSA5 := SA5->(GetArea())
Local aAreaZD2 := ZD2->(GetArea())
Local aAreaZD3 := ZD3->(GetArea())
Local aAreaZDA := ZDA->(GetArea())
Local aAreaZDB := ZDB->(GetArea())
Local aAreaZDC := ZDC->(GetArea())
Local aAreaZDE := ZDE->(GetArea())
Local cFilSF1 := xFilial("SF1")
Local cTblSF1 := RetSqlName("SF1")
Local cFilSD1 := xFilial("SD1")
Local cTblSD1 := RetSqlName("SD1")
Local cFilSB1 := xFilial("SB1")
Local cTblSB1 := RetSqlName("SB1")
Local cFilSA2 := xFilial("SA2")
Local cTblSA2 := RetSqlName("SA2")
Local cFilSA5 := xFilial("SA5")
Local cTblSA5 := RetSqlName("SA5")
Local cFilSF4 := xFilial("SF4")
Local cTblSF4 := RetSqlName("SF4")
Local cFilSC7 := xFilial("SC7")
Local cTblSC7 := RetSqlName("SC7")
Local cFilZD2 := xFilial("ZD2")
Local cTblZD2 := RetSqlName("ZD2")
Local cFilZD3 := xFilial("ZD3")
Local cTblZD3 := RetSqlName("ZD3")
Local cFilZD4 := xFilial("ZD4")
Local cTblZD4 := RetSqlName("ZD4")
Local cFilZD5 := xFilial("ZD5")
Local cTblZD5 := RetSqlName("ZD5")
Local cFilZDA := xFilial("ZDA")
Local cTblZDA := RetSqlName("ZDA")
Local cFilZDB := xFilial("ZDB")
Local cTblZDB := RetSqlName("ZDB")
Local cFilZDC := xFilial("ZDC")
Local cTblZDC := RetSqlName("ZDC")
Local cFilZDE := xFilial("ZDE")
Local cTblZDE := RetSqlName("ZDE")
Local nTolVlPC := SuperGetMV("AF_TPCCLNF",,0)   // Tolerancia para divergencia de preco entre NF e Pedido de Compras
Local cVld01 := SuperGetMV("AF_V01CLNF",,"N")   // De-Para CFOP
Local cVld02 := SuperGetMV("AF_V02CLNF",,"N")   // Protocolo ICMS-ST
Local cVld03 := SuperGetMV("AF_V03CLNF",,"N")   // Origem do Produto
Local cVld04 := SuperGetMV("AF_V04CLNF",,"N")   // De-Para CST Pis Cofins
Local cVld05 := SuperGetMV("AF_V05CLNF",,"S")   // Pedido de Compras (Preco, Qtd, Valor, UM e Amarracao Prod X Fornecedor)
Local cVld06 := SuperGetMV("AF_V06CLNF",,"N")   // CST da TES
Local cVld07 := SuperGetMV("AF_V07CLNF",,"N")   // Natureza no Cadastro do Fornecedor
Local cVld08 := SuperGetMV("AF_V08CLNF",,"N")   // Condicao de Pagto no PC
Local cVld09 := SuperGetMV("AF_V09CLNF",,"S")   // Parcelas a pagar
Local cVld10 := SuperGetMV("AF_V10CLNF",,"S")   // Valida CST ICMS para Simples Nacional 
Local cMdCPG := SuperGetMV("AF_MPGCLNF",,"1")   // Modo de validacao da forma de pagamento
Local cTESSN := SuperGetMV("AF_TESSNCL",,"")    // TES para Simples Nacional
Local cMdClass := SuperGetMV("DN_MCLCLNF",,"")  // Modo de Classificacao da NFe: 1=Reduzida; 2=Completa
Local cUFFCP := SuperGetMV("AF_CLUFFCP",,"|RJ|")// 
Local cCodNat := ""
Local cSiglaUF := ""
Local aCbNFe := {}
Local aLiNFe := {}
Local aItNFe := {}
Local nQtdNF 		:= 0
Local nVlrUnit		:= 0
Local nSF1Rcn 		:= 0
Local nPD1ITEM 		:= 0
Local nPD1COD 		:= 0
Local nPD1UM 		:= 0
Local nPD1TES 		:= 0
Local nPD1PEDIDO	:= 0
Local nPD1ITEMPC	:= 0
Local nPD1QUANT 	:= 0
Local nPD1VUNIT 	:= 0
Local nPD1TOTAL 	:= 0
Local nPD1XCLF		:= 0
Local nPD1VALIPI	:= 0
Local nPD1PICM		:= 0
Local nPD1VALICM	:= 0
Local nPD1BASEICM	:= 0
Local nPD1CF		:= 0
Local nPD1CLASFIS	:= 0
Local nPD1FCICOD	:= 0
Local nPD1ALFCPST	:= 0
Local nPD1ALIQSOL	:= 0
Local nSC7Rcn		:= 0
Local nTCodPrf		:= 0
Local nTA2CGC 		:= 0
Local lvCSTxTES		:= .F.
Local lVldPC		:= .F.
Local lTransf		:= .F.
Local cPCItem		:= ""

Local nDecD1QUA 	:= TAMSX3("D1_QUANT")[2] // Numero de Casas Decimais para a Quantidade
Local nDecD1VUN 	:= TAMSX3("D1_VUNIT")[2] // Numero de Casas Decimais para o Valor Unitario
Local nDecD1TOT 	:= TAMSX3("D1_TOTAL")[2] // Numero de Casas Decimais para o Valor Total

Default cAcao		:= "C" // C=Classificar, V=Validar
Default lIsJob 		:= .F.

Private lInJb 		:= lIsJob
Private lMsErroAuto	:= .F.

//Valida se a NFe ja' consta do banco de dados
cQry := "SELECT TOP 1 "
cQry += "F1.F1_STATUS AS F1STATUS, "
cQry += "F1.R_E_C_N_O_ AS F1RECNO "
cQry += "FROM "
cQry += cTblSF1+ " F1 "
cQry += "WHERE F1.D_E_L_E_T_ = ' ' "
cQry += "AND F1.F1_FILIAL = '"+cFilSF1+"' "
cQry += "AND F1.F1_CHVNFE = '"+cChvNFe+"' "

Iif(Select("WKF1XD1")>0,WKF1XD1->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKF1XD1",.T.,.T.)
TcSetField("WKF1XD1","F1RECNO","N",14,0)

WKF1XD1->(dbGoTop())

If WKF1XD1->(!EoF())
	If WKF1XD1->F1RECNO > 0
		nSF1Rcn := WKF1XD1->F1RECNO
		If cAcao == "V"
			If Empty(WKF1XD1->F1STATUS)
				aRtCNFe := {.F.,"Ja existe Pre-Nota com esta chave no banco de dados"}
				cTpErro := "F"
			Else
				aRtCNFe := {.F.,"NFe Classificada"}
				cTpErro := "F"
			EndIf
		EndIf
	Else
		If cAcao == "C"
			aRtCNFe := {.F.,"Nao existe pre-nota gerada"}
			cTpErro := "F"
		EndIf
	EndIf
EndIf			
WKF1XD1->(dbCloseArea())


//Valida cabecalho do XML no monitor
If aRtCNFe[1]

	cQry := "SELECT ZD2.R_E_C_N_O_ AS ZD2RECNO "
	cQry += "FROM " +cTblZD2+ " ZD2 "
	cQry += "WHERE ZD2.D_E_L_E_T_ = ' ' "
	cQry += "AND ZD2.ZD2_FILIAL = '"+cFilZD2+"' "
	cQry += "AND ZD2.ZD2_CHVNFE = '"+cChvNFe+"' "
	                                                 
	Iif(Select("WRKZD2")>0,WRKZD2->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKZD2",.T.,.T.)
	TcSetField("WRKZD2","ZD2RECNO","N",14,0)
	WRKZD2->(dbGoTop())
	
	If WRKZD2->(!EoF())
		If WRKZD2->ZD2RECNO > 0
			dbSelectArea("ZD2")
			ZD2->(dbSetOrder(1))
			ZD2->(dbGoTo(WRKZD2->ZD2RECNO))
			If ZD2->(RecNo()) <> WRKZD2->ZD2RECNO
				aRtCNFe := {.F.,"Cabecalho XML nao localizado - ZD2"}
				cTpErro := "F"
			Else
				dEmisNF := ZD2->ZD2_EMISSA
			EndIf	
		Else
			aRtCNFe := {.F.,"Cabecalho XML nao localizado - ZD2"}
			cTpErro := "F"
		EndIf
	Else
		aRtCNFe := {.F.,"Cabecalho XML nao localizado - ZD2"}
		cTpErro := "F"
	EndIf
	WRKZD2->(dbCloseArea())

EndIf	

//Valida Fornecedor
If aRtCNFe[1]

	nTA2CGC := TamSX3("A2_CGC")[1]

	cQry := "SELECT "
	cQry += "SA2.R_E_C_N_O_ AS SA2RECNO "
	cQry += "FROM " +cTblSA2+ " SA2 "
	cQry += "WHERE SA2.D_E_L_E_T_ = ' ' "
//	cQry += "AND SA2.A2_FILIAL = '"+cFilSA2+"' "
	cQry += "AND SA2.A2_COD = '"+ZD2->ZD2_CODFOR+"' "
	cQry += "AND SA2.A2_LOJA = '"+ZD2->ZD2_LOJFOR+"' "
	cQry += "AND SA2.A2_CGC = '"+SubStr(Alltrim(ZD2->ZD2_CNPJFO),1,nTA2CGC)+"' "
                                                 
	Iif(Select("WRKSA2")>0,WRKSA2->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKSA2",.T.,.T.)
	TcSetField("WRKSA2","SA2RECNO","N",14,0)
	WRKSA2->(dbGoTop())
	
	If WRKSA2->(!EoF())
		If WRKSA2->SA2RECNO > 0
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbGoTo(WRKSA2->SA2RECNO))
			If SA2->(RecNo()) == WRKSA2->SA2RECNO
				If SA2->A2_MSBLQL == "1"
					aRtCNFe := {.F.,"Fornecedor bloqueado - SA2"}
					cTpErro := "E"
				Else
					cCodNat := SA2->A2_NATUREZ
					cSiglaUF := SA2->A2_EST
				EndIf
			Else
				aRtCNFe := {.F.,"Fornecedor nao cadastrado - SA2"}
				cTpErro := "E"
			EndIf	
		Else
			aRtCNFe := {.F.,"Fornecedor nao cadastrado - SA2"}
			cTpErro := "E"
		EndIf
	Else
		aRtCNFe := {.F.,"Fornecedor nao cadastrado - SA2"}
		cTpErro := "E"
	EndIf
	WRKSA2->(dbCloseArea())

EndIf

//Verifica se eh uma transferencia entre filiais
If aRtCNFe[1]
	If SubStr(Alltrim(SA2->A2_CGC),1,8) == SubStr(Alltrim(SM0->M0_CGC),1,8)
		lTransf := .T.
	EndIf
EndIf

//Prepara variaveis para ordenar array de itens do execauto, antes de entrar no While de produtos,
//que esta' no trecho de validacao de itens por motivos de performance
If aRtCNFe[1]

	If cAcao == "C"
	
		nPD1ITEM 	:= POSICIONE("SX3",2,"D1_ITEM" 		, "X3_ORDEM")
		nPD1COD 	:= POSICIONE("SX3",2,"D1_COD" 		, "X3_ORDEM")
		nPD1UM 		:= POSICIONE("SX3",2,"D1_UM" 		, "X3_ORDEM")
		nPD1TES 	:= POSICIONE("SX3",2,"D1_TES" 		, "X3_ORDEM")
		nPD1PEDIDO	:= POSICIONE("SX3",2,"D1_PEDIDO" 	, "X3_ORDEM")
		nPD1ITEMPC	:= POSICIONE("SX3",2,"D1_ITEMPC" 	, "X3_ORDEM")
		nPD1QUANT 	:= POSICIONE("SX3",2,"D1_QUANT" 	, "X3_ORDEM")
		nPD1VUNIT 	:= POSICIONE("SX3",2,"D1_VUNIT" 	, "X3_ORDEM")
		nPD1TOTAL 	:= POSICIONE("SX3",2,"D1_TOTAL" 	, "X3_ORDEM")
		nPD1XCLF	:= POSICIONE("SX3",2,"D1_X_CLF" 	, "X3_ORDEM")
		nPD1VALIPI	:= POSICIONE("SX3",2,"D1_VALIPI" 	, "X3_ORDEM")
		nPD1PICM	:= POSICIONE("SX3",2,"D1_PICM" 		, "X3_ORDEM")
		nPD1BASEICM	:= POSICIONE("SX3",2,"D1_BASEICM" 	, "X3_ORDEM")
		nPD1VALICM	:= POSICIONE("SX3",2,"D1_VALICM" 	, "X3_ORDEM")
		nPD1CF		:= POSICIONE("SX3",2,"D1_CF" 		, "X3_ORDEM")
		nPD1CLASFIS	:= POSICIONE("SX3",2,"D1_CLASFIS"	, "X3_ORDEM")
		nPD1FCICOD	:= POSICIONE("SX3",2,"D1_FCICOD"	, "X3_ORDEM")
		nPD1ALFCPST	:= POSICIONE("SX3",2,"D1_ALFCPST"	, "X3_ORDEM")
		nPD1ALIQSOL	:= POSICIONE("SX3",2,"D1_ALIQSOL"	, "X3_ORDEM")
	
	EndIf

EndIf


//Valida Itens, inclusive antes da classificacao
If aRtCNFe[1]

	nTCodPrf := TamSX3("A5_CODPRF")[1]

	cQry := "SELECT ZD3.R_E_C_N_O_ AS ZD3RECNO "
	cQry += "FROM " +cTblZD3+ " ZD3 "
	cQry += "WHERE ZD3.D_E_L_E_T_ = ' ' "
	cQry += "AND ZD3.ZD3_FILIAL = '"+cFilZD3+"' "
	cQry += "AND ZD3.ZD3_CHVNFE = '"+cChvNFe+"' "
	cQry += "ORDER BY ZD3.ZD3_ITEMNF"

	Iif(Select("WKXZD3")>0,WKXZD3->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKXZD3",.T.,.T.)
	TcSetField("WKXZD3","ZD3RECNO","N",14,0)
	WKXZD3->(dbGoTop())

	While WKXZD3->(!EoF()) .And. aRtCNFe[1]

		nQtdNF 	:= 0
		nVlrUnit:= 0
		nSC7Rcn := 0
		cCFOP := ""
		cCodProd := ""
		cUMProd := ""
		lPriUM := .F.
		lSegUM := .F.
		cOriPrd := ""
		cCstICM := ""
		cCstPIS := ""
		cCstCOF := ""
		cCodTES := ""
		nAliqIPI:= 0
		nAliqICM:= 0
		cProtocolo := ""
		cItemNF := ""
		cPcItem := ""
		lvCSTxTES := .F.
		lVldPC := .F.
			
		dbSelectArea("ZD3")
		ZD3->(dbSetOrder(1))
		ZD3->(dbGoTo(WKXZD3->ZD3RECNO))
		If ZD3->(RecNo()) <> WKXZD3->ZD3RECNO
			aRtCNFe := {.F.,"Item da NFe nao localizado no monitor - ZD3"}
			cTpErro := "F"
		EndIf
                
		//Valida Amarracao Produto X Fornecedor, e posiciona no SB1
		If aRtCNFe[1]

			If !lTransf		
                
				cQry := "SELECT SA5.A5_PRODUTO AS A5PRODUTO "                       
				cQry += "FROM " +cTblSA5+ " SA5 "
				cQry += "WHERE SA5.D_E_L_E_T_ = ' ' "
				cQry += "AND SA5.A5_FILIAL = '"+cFilSA5+"' "
				cQry += "AND SA5.A5_FORNECE = '"+SA2->A2_COD+"' "
				cQry += "AND SA5.A5_LOJA = '"+SA2->A2_LOJA+"' "
				cQry += "AND SA5.A5_CODPRF = '"+SubStr(ZD3->ZD3_PRDFOR,1,nTCodPrf)+"' "
		
				Iif(Select("WRKSA5")>0,WRKSA5->(dbCloseArea()),Nil)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKSA5",.T.,.T.)
				WRKSA5->(dbGoTop())
				
				If WRKSA5->(!EoF())
	
					If !Empty(WRKSA5->A5PRODUTO)
	                    
						cCodProd := WRKSA5->A5PRODUTO
	
						cQry := "SELECT B1.R_E_C_N_O_ AS B1RECNO "
						cQry += "FROM " +cTblSB1+ " B1 "
						cQry += "WHERE B1.D_E_L_E_T_ = ' ' "
						cQry += "AND B1.B1_FILIAL = '"+cFilSB1+"' "
						cQry += "AND B1.B1_COD = '"+WRKSA5->A5PRODUTO+"' "
		                                                 
						Iif(Select("WRKSB1")>0,WRKSB1->(dbCloseArea()),Nil)
						dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKSB1",.T.,.T.)
						TcSetField("WRKSB1","B1RECNO","N",14,0)
						WRKSB1->(dbGoTop())
						
						If WRKSB1->(!EoF())
							If WRKSB1->B1RECNO > 0
								dbSelectArea("SB1")
								SB1->(dbSetOrder(1))
								SB1->(dbGoTo(WRKSB1->B1RECNO))
								If SB1->(RecNo()) == WRKSB1->B1RECNO
									If SB1->B1_MSBLQL == "1"
										aRtCNFe := {.F.,"Produto bloqueado - SB1"}
										cTpErro := "E"
									Else
										If Upper(Alltrim(SB1->B1_POSIPI)) <> Upper(Alltrim(ZD3->ZD3_NCMFOR)) 
											aRtCNFe := {.F.,"NCM do produto divergente do cadastro"}
											cTpErro := "E"
										Else
											cOriPrd := SB1->B1_ORIGEM
										EndIf
									EndIf
								Else
									aRtCNFe := {.F.,"Produto nao cadastrado - SB1"}
									cTpErro := "E"
								EndIf
							Else
								aRtCNFe := {.F.,"Produto nao cadastrado - SB1"}
								cTpErro := "E"
							EndIf
						Else
							aRtCNFe := {.F.,"Produto nao cadastrado - SB1"}
							cTpErro := "E"
						EndIf
						WRKSB1->(dbCloseArea())
	
					Else
						aRtCNFe := {.F.,"Nao existe amarracao Produto X Fornecedor - Produto: " +Alltrim(ZD3->ZD3_PRDFOR)}
						cTpErro := "E"
	                EndIf
	
				Else
					aRtCNFe := {.F.,"Nao existe amarracao Produto X Fornecedor - Produto: "+Alltrim(ZD3->ZD3_PRDFOR)}
					cTpErro := "E"
				EndIf

            Else

				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(cFilSB1+Upper(Alltrim(ZD3->ZD3_PRDFOR))))
					If SB1->B1_MSBLQL == "1"
						aRtCNFe := {.F.,"Produto bloqueado - SB1"}
						cTpErro := "E"
					Else
						cCodProd := SB1->B1_COD
						cOriPrd := SB1->B1_ORIGEM
					EndIf
				Else
					aRtCNFe := {.F.,"Produto nao cadastrado - SB1"}
					cTpErro := "E"
				EndIf
            	
			EndIf

		EndIf


		//Valida De-Para CFOP
		If aRtCNFe[1]
			If cVld01 == "S" // .And. !lTransf

				cQry := "SELECT "
				cQry += "ZDA.ZDA_CFXML AS ZDACFXML, "
				cQry += "ZDA.ZDA_CFPED AS ZDACFPED, "
				cQry += "ZDA.ZDA_CSTPED AS ZDACSTPED "
				cQry += "FROM " +cTblZDA+ " ZDA "
				cQry += "WHERE ZDA.D_E_L_E_T_ = ' ' "
				cQry += "AND ZDA.ZDA_FILIAL = '"+cFilZDA+"' "
				cQry += "AND ZDA.ZDA_TPPROD = '"+SB1->B1_TIPO+"' "
				cQry += "AND ZDA.ZDA_CFXML = '"+ZD3->ZD3_CFOP+"' "
				cQry += "AND ZDA.ZDA_CSTXML = '"+SubStr(ZD3->ZD3_CST,2,2)+"' "
				Iif(Select("WRKZDA")>0,WRKZDA->(dbCloseArea()),Nil)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKZDA",.T.,.T.)
				WRKZDA->(dbGoTop())

				If WRKZDA->(!EoF())

					If !Empty(WRKZDA->ZDACFPED)
						cCFOP := WRKZDA->ZDACFPED
						cCstICM := WRKZDA->ZDACSTPED
					EndIf

				EndIf
				WRKZDA->(dbCloseArea())

				If Empty(cCFOP)
					If SubStr(ZD3->ZD3_CFOP,1,1) == "5"
						cCFOP := "1" + SubStr(ZD3->ZD3_CFOP,2,3)
					ElseIf SubStr(ZD3->ZD3_CFOP,1,1) == "6"
						cCFOP := "2" + SubStr(ZD3->ZD3_CFOP,2,3)
					ElseIf SubStr(ZD3->ZD3_CFOP,1,1) == "7"
						cCFOP := "3" + SubStr(ZD3->ZD3_CFOP,2,3)
					EndIf
					lvCSTxTES := .T.
					cCstICM := SubStr(ZD3->ZD3_CST,2,2)
				EndIf 							
				
				If Empty(cCFOP)
					aRtCNFe := {.F.,"Item da NF sem CFOP - SD1"}
					cTpErro := "F"
				EndIf	

	       	EndIf

		EndIf

		//Valida Protocolo ICMS - ST (ZDB)
		If ( aRtCNFe[1] .And. !lTransf )
			If cVld02 == "S" 
                
				cProtocolo := ""

				If cCFOP $ "|1403|2403|1409|2409|"

					cQry := "SELECT "
					cQry += "ZDB.ZDB_TRANSF, "
					cQry += "ZDB.ZDB_UF "
					cQry += "FROM " +cTblZDB+ " ZDB "
					cQry += "WHERE ZDB.D_E_L_E_T_ = ' ' "
					cQry += "AND ZDB.ZDB_FILIAL = '"+cFilZDB+"' "
					cQry += "AND ZDB.ZDB_CNPJ = '"+ZD2->ZD2_CNPJDE+"' "
					cQry += "AND ZDB.ZDB_UF LIKE '%"+ZD2->ZD2_UFFORN+"%' "
					cQry += "AND ZDB.ZDB_GRTRIB = '"+Alltrim(SB1->B1_GRTRIB)+"' "

					Iif(Select("WRKZDB")>0,WRKZDB->(dbCloseArea()),Nil)
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKZDB",.T.,.T.)
					WRKZDB->(dbGoTop())

					If WRKZDB->(!EoF())
						If !Empty(WRKZDB->ZDB_UF)
							If lTransf
								If WRKZDB->ZDB_TRANSF == "S"
									cProtocolo := "S"
								Else
									cProtocolo := ""
								EndIf
							Else
								cProtocolo := "S"
							EndIf
						EndIf
					EndIf
					WRKZDB->(dbCloseArea())

				EndIf

				If cProtocolo == "S"
                	If ZD2->ZD2_VST <= 0
						aRtCNFe := { .F. , "Esta operacao requer ICMS-ST, pois ha protocolo com o estado emitente - "+ZD2->ZD2_UFFORN }
						cTpErro := "F"
             		EndIf
				EndIf                 
			EndIf
		EndIf


		//Valida Origem do Produto (ZDC)
		If aRtCNFe[1]
			If cVld03 == "S" .And. !lTransf
            	If !Empty(ZD3->ZD3_ORIPRD)

					cQry := "SELECT "
					cQry += "ZDC.ZDC_ORIXML AS ZDCORIXML, "
					cQry += "ZDC.ZDC_ORIPED AS ZDCORIPED "
					cQry += "FROM " +cTblZDC+ " ZDC "
					cQry += "WHERE ZDC.D_E_L_E_T_ = ' ' "
					cQry += "AND ZDC.ZDC_FILIAL = '"+cFilZDC+"' "
					cQry += "AND ZDC.ZDC_ORIXML  = '"+ZD3->ZD3_ORIPRD+"' "
					Iif(Select("WRKZDC")>0,WRKZDC->(dbCloseArea()),Nil)
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKZDC",.T.,.T.)
					WRKZDC->(dbGoTop())
	
					If WRKZDC->(!EoF())
						If !Empty(WRKZDC->ZDCORIPED)
							If ! ( Upper(Alltrim(SB1->B1_ORIGEM)) $ Upper(Alltrim(WRKZDC->ZDCORIPED)) )
								aRtCNFe := { .F. , "Origem do Produto "+Alltrim(SB1->B1_COD)+" divergente da tabela de-para - ZDC" }
								cTpErro := "F"
							EndIf
						Else
							aRtCNFe := { .F. , "De-Para Origem do Produto "+Alltrim(SB1->B1_COD)+" nao cadastrado" }
							cTpErro := "F"
						EndIf
					Else
						aRtCNFe := { .F. , "De-Para Origem do Produto "+Alltrim(SB1->B1_COD)+" nao cadastrado" }
						cTpErro := "F"
					EndIf
					WRKZDC->(dbCloseArea())

                EndIf
			EndIf
		EndIf

		//Valida De-Para Validacao Cst PIS Cofins (ZDE)
		If aRtCNFe[1]
			If cVld04 == "S" .And. !lTransf
				If !Empty(ZD3->ZD3_CSTPIS) .And. !Empty(ZD3->ZD3_CSTCOF)
				
					cQry := "SELECT "
					cQry += "ZDE.ZDE_PISPED AS ZDEPISPED, "
					cQry += "ZDE.ZDE_COFPED AS ZDECOFPED "
					cQry += "FROM " +cTblZDE+ " ZDE "
					cQry += "WHERE ZDE.D_E_L_E_T_ = ' ' "
					cQry += "AND ZDE.ZDE_FILIAL = '"+cFilZDE+"' "
					cQry += "AND ZDE.ZDE_TPPROD  = '"+SB1->B1_TIPO+"' "
					cQry += "AND ZDE.ZDE_GRTRIB  = '"+Alltrim(SB1->B1_GRTRIB)+"' "
					cQry += "AND ZDE.ZDE_PISXML = '"+ZD3->ZD3_CSTPIS+"' "
					cQry += "AND ZDE.ZDE_COFXML = '"+ZD3->ZD3_CSTCOF+"' "
	
					Iif(Select("WRKZDE")>0,WRKZDE->(dbCloseArea()),Nil)
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKZDE",.T.,.T.)
					WRKZDE->(dbGoTop())
	
					If WRKZDE->(!EoF())
						If !Empty(WRKZDE->ZDEPISPED)
							cCstPIS := WRKZDE->ZDEPISPED
						EndIf
						If !Empty(WRKZDE->ZDECOFPED)
							cCstCOF := WRKZDE->ZDECOFPED
						EndIf
					EndIf
					WRKZDE->(dbCloseArea())
	
					If Empty(cCstPIS)
						aRtCNFe := { .F. , "De-Para CST Pis "+Alltrim(ZD3->ZD3_CSTPIS)+" nao cadastrado" }
						cTpErro := "F"
					EndIf
					If Empty(cCstCOF)
						aRtCNFe := { .F. , "De-Para CST Cofins "+Alltrim(ZD3->ZD3_CSTCOF)+" nao cadastrado" }
						cTpErro := "F"
					EndIf

                EndIf    
			EndIf
		EndIf


		//Valida Pedido de Compras
		If aRtCNFe[1]

			If cVld05 == "S"
			
				lVldPC := .F.
				nSC7Rcn := 0

				//1a Validacao do PC: com o Item do Pedido Preenchido
				If !Empty(ZD3->ZD3_ITPEDC)

					cQry := "SELECT "
					cQry += "SC7.C7_NUM AS C7NUM, "
					cQry += "SC7.C7_ITEM AS C7ITEM, "
					cQry += "SC7.C7_CONAPRO AS C7CONAPRO, "
					cQry += "SC7.C7_PRODUTO AS C7PRODUTO, "
					cQry += "SC7.C7_RESIDUO AS C7RESIDUO, "
					cQry += "SC7.C7_UM AS C7UM, "
					cQry += "SC7.C7_SEGUM AS C7SEGUM, "
					cQry += "SC7.C7_QTSEGUM AS C7QTSEGUM, "
					cQry += "SC7.C7_PRECO AS C7PRECO, "
					cQry += "SC7.C7_QUANT AS C7QUANT, "
					cQry += "SC7.C7_QUJE AS C7QUJE, "
					cQry += "SC7.C7_CONAPRO AS C7RESIDUO, "
					cQry += "SC7.C7_TES AS C7TES, "
					cQry += "SC7.C7_COND AS C7COND, "
					cQry += "SC7.C7_IPI AS C7IPI, "
					cQry += "SC7.C7_PICM AS C7PICM, "
					cQry += "SC7.R_E_C_N_O_ AS C7RECNO "
					cQry += "FROM "+cTblSC7+" SC7 "
					cQry += "WHERE SC7.D_E_L_E_T_ = ' ' "
					cQry += "AND SC7.C7_FILIAL = '"+cFilSC7+"' "
					cQry += "AND SC7.C7_NUM = '"+ZD3->ZD3_NUMPED+"' "
					cQry += "AND SC7.C7_ITEM = '"+ZD3->ZD3_ITPEDC+"' "
					cQry += "AND SC7.C7_PRODUTO = '"+cCodProd+"' "
					cQry += "AND SC7.C7_FORNECE = '"+Alltrim(ZD3->ZD3_CODFOR)+"' "
					cQry += "AND SC7.C7_LOJA = '"+Alltrim(ZD3->ZD3_LOJFOR)+"' "
	
					Iif(Select("WRKSC7")>0,WRKSC7->(dbCloseArea()),Nil)
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKSC7",.T.,.T.)
					TcSetField("WRKSC7","C7QUANT","N",12,2)			
					TcSetField("WRKSC7","C7QUJE","N",12,2)			
					TcSetField("WRKSC7","C7QTSEGUM","N",12,2)			
					TcSetField("WRKSC7","C7RECNO","N",14,0)			
		
					WRKSC7->(dbGoTop())

					If WRKSC7->(!EoF())
						If !Empty(WRKSC7->C7NUM)
							nSC7Rcn := WRKSC7->C7RECNO
							cPCItem := WRKSC7->C7ITEM
                			lVldPc := .T.
      					EndIf
      				EndIf
                EndIf    

				//2a Validacao do PC: sem o Item do Pedido Preenchido
			    If !lVldPC
			    
			    	nSC7Rcn := 0

					Iif(Select("WRKSC7")>0,WRKSC7->(dbCloseArea()),Nil)
					cQry := "SELECT "
					cQry += "SC7.C7_NUM AS C7NUM, "
					cQry += "SC7.C7_ITEM AS C7ITEM, "
					cQry += "SC7.C7_CONAPRO AS C7CONAPRO, "
					cQry += "SC7.C7_PRODUTO AS C7PRODUTO, "
					cQry += "SC7.C7_RESIDUO AS C7RESIDUO, "
					cQry += "SC7.C7_UM AS C7UM, "
					cQry += "SC7.C7_SEGUM AS C7SEGUM, "
					cQry += "SC7.C7_QTSEGUM AS C7QTSEGUM, "
					cQry += "SC7.C7_PRECO AS C7PRECO, "
					cQry += "SC7.C7_QUANT AS C7QUANT, "
					cQry += "SC7.C7_QUJE AS C7QUJE, "
					cQry += "SC7.C7_CONAPRO AS C7RESIDUO, "
					cQry += "SC7.C7_TES AS C7TES, "
					cQry += "SC7.C7_COND AS C7COND, "
					cQry += "SC7.C7_IPI AS C7IPI, "
					cQry += "SC7.C7_PICM AS C7PICM, "
					cQry += "SC7.R_E_C_N_O_ AS C7RECNO "
					cQry += "FROM "+cTblSC7+" SC7 "
					cQry += "WHERE SC7.D_E_L_E_T_ = ' ' "
					cQry += "AND SC7.C7_FILIAL = '"+cFilSC7+"' "
					cQry += "AND SC7.C7_NUM = '"+ZD3->ZD3_NUMPED+"' "
					cQry += "AND SC7.C7_PRODUTO = '"+cCodProd+"' "
					cQry += "AND SC7.C7_FORNECE = '"+Alltrim(ZD3->ZD3_CODFOR)+"' "
					cQry += "AND SC7.C7_LOJA = '"+Alltrim(ZD3->ZD3_LOJFOR)+"' "
	
					Iif(Select("WRKSC7")>0,WRKSC7->(dbCloseArea()),Nil)
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKSC7",.T.,.T.)
					TcSetField("WRKSC7","C7QUANT","N",12,2)			
					TcSetField("WRKSC7","C7QUJE","N",12,2)			
					TcSetField("WRKSC7","C7QTSEGUM","N",12,2)			
					TcSetField("WRKSC7","C7RECNO","N",14,0)			
		
					WRKSC7->(dbGoTop())

					If WRKSC7->(!EoF())
						If !Empty(WRKSC7->C7NUM)
							nSC7Rcn := WRKSC7->C7RECNO
							cPCItem := WRKSC7->C7ITEM
                			lVldPc := .T.
						EndIf
					EndIf
				EndIf		
                
				If lVldPC
			
					If WRKSC7->(!EoF())

						If ( aRtCNFe[1] .And. !lTransf )
							If WRKSC7->C7PRODUTO <> cCodProd
								aRtCNFe := { .F. , "Divergencia na Amarracao Produto x Fornecedor. Item NF: "+Alltrim(ZD3->ZD3_ITEMNF)+" PC: "+Alltrim(WRKSC7->C7NUM)+" Item PC: "+Alltrim(WRKSC7->C7ITEM)+" Prod: "+Alltrim(WRKSC7->C7PRODUTO)}
								cTpErro := "E"
							EndIf
						EndIf

						If aRtCNFe[1]
							If WRKSC7->C7CONAPRO == "B"
								aRtCNFe := { .F. , "Pedido de compras bloqueado. PC: "+Alltrim(WRKSC7->C7NUM) }
								cTpErro := "E"
							EndIf
						EndIf

						If aRtCNFe[1]
							If WRKSC7->C7RESIDUO == "S"
								aRtCNFe := { .F. , "Pedido "+Alltrim(WRKSC7->C7NUM)+" finalizado por eliminacao de residuo" }
								cTpErro := "E"
							EndIf
						EndIf

						//Valida Unidade de Medida
						If ( aRtCNFe[1] .And. !lTransf )
	
							lPriUM := .F.
							lSegUM := .F.
							cUMProd := ""

							If Upper(Alltrim(ZD3->ZD3_UM)) == Upper(Alltrim(SB1->B1_UM))
								lPriUM := .T.
								cUMProd := Upper(Alltrim(SB1->B1_UM))
							EndIf
							If !lPriUM
								If Upper(Alltrim(ZD3->ZD3_UM)) == Upper(Alltrim(SB1->B1_SEGUM))
									lSegUM := .T.
									cUMProd := Upper(Alltrim(SB1->B1_SEGUM))
								EndIf
							EndIf

							If ( !lPriUM .And. !lSegUM )

								//Procura na tabela de-para (ZD5), pelo equivalente da primeira unidade de medida
								cQry := "SELECT ZD5.ZD5_UMP AS ZD5UMP "
								cQry += "FROM " +cTblZD5+ " ZD5 "
								cQry += "WHERE ZD5.D_E_L_E_T_ = ' ' "
								cQry += "AND UPPER(LTRIM(RTRIM(ZD5.ZD5_UMF))) = '"+Upper(Alltrim(ZD3->ZD3_UM))+"' "
								cQry += "AND UPPER(LTRIM(RTRIM(ZD5.ZD5_UMP))) = '"+Upper(Alltrim(SB1->B1_UM))+"' "
								                                                 
								Iif(Select("WRKAZD5")>0,WRKAZD5->(dbCloseArea()),Nil)
								dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKAZD5",.T.,.T.)
								WRKAZD5->(dbGoTop())
								
								If WRKAZD5->(!EoF())
									If !Empty(WRKAZD5->ZD5UMP)
										cUMProd := Upper(Alltrim(WRKAZD5->ZD5UMP))
										lPriUM := .T.
										lSegUM := .F.
									EndIf
								EndIf
								Iif(Select("WRKAZD5")>0,WRKAZD5->(dbCloseArea()),Nil)
								
								If Empty(cUMProd)

									//Procura na tabela de-para (ZD5), pelo equivalente da segunda unidade de medida
									cQry := "SELECT ZD5.ZD5_UMP AS ZD5UMP "
									cQry += "FROM " +cTblZD5+ " ZD5 "
									cQry += "WHERE ZD5.D_E_L_E_T_ = ' ' "
									cQry += "AND UPPER(LTRIM(RTRIM(ZD5.ZD5_UMF))) = '"+Upper(Alltrim(ZD3->ZD3_UM))+"' "
									cQry += "AND UPPER(LTRIM(RTRIM(ZD5.ZD5_UMP))) = '"+Upper(Alltrim(SB1->B1_SEGUM))+"' "
									                                                 
									Iif(Select("WRKBZD5")>0,WRKBZD5->(dbCloseArea()),Nil)
									dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKBZD5",.T.,.T.)
									WRKBZD5->(dbGoTop())
									
									If WRKBZD5->(!EoF())
										If !Empty(WRKBZD5->ZD5UMP)
											cUMProd := WRKBZD5->ZD5UMP
											lPriUM := .F.
											lSegUM := .T.
										EndIf
									EndIf
									Iif(Select("WRKBZD5")>0,WRKBZD5->(dbCloseArea()),Nil)

								EndIf

							EndIf

							If ( ( lPriUM .Or. lSegUm ) .And. !Empty(cUMProd) )
	
								nQtdNF 	:= 0
								nVlrUnit:= 0
							   	If lPriUM
							   		nQtdNF  := Round( ZD3->ZD3_QUANT, nDecD1QUA )
							   		nVlrUnit:= Round( ZD3->ZD3_VLRUNI, nDecD1VUN )
							   	ElseIf lSegUM
						        	If Empty(SB1->B1_CONV) .Or. Empty(SB1->B1_TIPCONV)
										aRtCNFe := { .F. , "Produto "+Alltrim(SB1->B1_COD)+" sem configuracao para 2a. unidade de medida. Corrija o cadastro do produto no Protheus. Item NF:"+Alltrim(ZD3->ZD3_ITEMNF)+"  /  Pedido:"+Alltrim(WRKSC7->C7NUM)+"-Item:"+Alltrim(WRKSC7->C7ITEM)+" Prod: "+Alltrim(WRKSC7->C7PRODUTO) }
									Else
										If SB1->B1_TIPCONV == "D"
											nQtdNF  := Round( ZD3->ZD3_QUANT * SB1->B1_CONV, nDecD1QUA )
											nVlrUnit:= Round( ZD3->ZD3_VLRUNI / SB1->B1_CONV, nDecD1VUN )
										ElseIf SB1->B1_TIPCONV == "M"
											nQtdNF  := Round( ZD3->ZD3_QUANT / SB1->B1_CONV, nDecD1QUA )
											nVlrUnit:= Round( ZD3->ZD3_VLRUNI * SB1->B1_CONV, nDecD1VUN )
										Else                                                                                                                                                                        
											aRtCNFe := { .F. , "Produto "+Alltrim(SB1->B1_COD)+" com configuracao invalida para 2a. unidade de medida. Corrija o cadastro. Item NF:"+Alltrim(ZD3->ZD3_ITEMNF)+"  /  Pedido:"+Alltrim(WRKSC7->C7NUM)+"-Item: "+Alltrim(WRKSC7->C7ITEM)+" Prod: "+Alltrim(WRKSC7->C7PRODUTO) }
										EndIf
						        	EndIf
							   	Else
									aRtCNFe := { .F. , "Produto "+Alltrim(SB1->B1_COD)+" com configuracao de unidade de medida invalida. Corrija o cadastro, ou o De-Para para unidade de medida." }
								EndIf

                            EndIf

						EndIf

						//Valida quantidade
						If aRtCNFe[1]
							If nQtdNF > 0
								If ( nQtdNF > ( WRKSC7->C7QUANT - WRKSC7->C7QUJE ) )
	 								aRtCNFe := { .F. , "A quantidade da NFe é maior que a disponível no pedido de compras. Item NF: "+Alltrim(ZD3->ZD3_ITEMNF)+"  /  Pedido:"+Alltrim(WRKSC7->C7NUM)+"-Item:"+Alltrim(WRKSC7->C7ITEM)+" Prod: "+Alltrim(WRKSC7->C7PRODUTO) }
									cTpErro := "E"
								EndIf
							Else
								aRtCNFe := { .F. , "Nao foi possivel determinar a quantidade do produto "+Alltrim(SB1->B1_COD)+". Verifique a 2a. unidade de medida" }
							EndIf
						EndIf

						//Valida Preco
						If ( aRtCNFe[1] .And. !lTransf )
							If nVlrUnit > Round( WRKSC7->C7PRECO, nDecD1VUN ) 
								aRtCNFe := { .F. , "O Preco do item está divergente do pedido de compras. Item NF: "+Alltrim(ZD3->ZD3_ITEMNF)+" PC: "+Alltrim(WRKSC7->C7NUM)+" Item PC: "+Alltrim(WRKSC7->C7ITEM)+" Prod: "+Alltrim(WRKSC7->C7PRODUTO) }
								cTpErro := "E"
							EndIf
						EndIf
						
						//Valida Total
						If ( aRtCNFe[1] .And. !lTransf )
							If Round( nVlrUnit * nQtdNF, nDecD1TOT ) > Round( WRKSC7->C7PRECO * nQtdNF, nDecD1TOT ) 
								aRtCNFe := { .F. , "O Valor Total do Item está divergente do pedido de compras. Item NF: "+Alltrim(ZD3->ZD3_ITEMNF)+" PC: "+Alltrim(WRKSC7->C7NUM)+" Item PC: "+Alltrim(WRKSC7->C7ITEM)+" Prod: "+Alltrim(WRKSC7->C7PRODUTO) }
								cTpErro := "E"
							EndIf
						EndIf

						If !Empty(WRKSC7->C7TES)
							cCodTES := WRKSC7->C7TES
						EndIf

						If Empty(cCondPg)
							If !Empty(WRKSC7->C7COND)
								cCondPg := WRKSC7->C7COND
							EndIf
						EndIf
						
						nAliqIPI := WRKSC7->C7IPI
						nAliqICM := WRKSC7->C7PICM
						
						If !Empty(cPcITem)
							If RecLock("ZD3",.F.)
								ZD3->ZD3_ITPCPR := cPcItem
								ZD3->(MsUnLock())
							Else
								aRtCNFe := { .F. , "Nao foi possivel atualizar o item do pedido de compra na tabela ZD3 (lock). Contacte o Administrador do Sistema." }
								cTpErro := "E"
							EndIf
						Else
							aRtCNFe := { .F. , "Item do Pedido de Compra Nao Encontrado" }
							cTpErro := "E"
						EndIf

					Else

						aRtCNFe := { .F. , "Pedido de Compra Nao Encontrado" }
						cTpErro := "E"

					EndIf

				Else

					aRtCNFe := { .F. , "Pedido de Compra Nao Encontrado" }
					cTpErro := "E"

				EndIf

				WRKSC7->(dbCloseArea())

                //Tratamento para Simples Nacional: alterar o ICMS do pedido de compras 
                //Pois o ICMS sera' carregado do pedido, na classificacao automatica
				If aRtCNFe[1]
					If cAcao == "C"
						If cVld10 == "S"

							If !Empty(ZD3->ZD3_CSOSN) //.And. ( ZD3->ZD3_PICM > 0 .And. ZD3->ZD3_VALICM > 0 )

								If SubStr(Alltrim(ZD3->ZD3_CSOSN),2,3) == "102"
									If ( ZD3->ZD3_PICM > 0 .Or. ZD3->ZD3_VALICM > 0 )
										aRtCNFe := { .F. , "ICMS calculado incorretamente para CST 102 - Simples Nacional" }
										cTpErro := "F"
									EndIf
								EndIf

								If aRtCNFe[1]
									If nSC7Rcn > 0
										dbSelectArea("SC7")
										SC7->(dbGoTo(nSC7Rcn))
										If SC7->(RecNo()) == nSC7Rcn
											If SC7->(RecLock("SC7",.F.))
												SC7->C7_TES := cTESSN
												SC7->C7_PICM := ZD3->ZD3_PICM
												SC7->C7_BASEICM := ZD3->ZD3_BASICM
												SC7->C7_VALICM := ZD3->ZD3_VALICM
												SC7->C7_VALIPI := ZD3->ZD3_VALIPI
												SC7->(MsUnLock())
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				If aRtCNFe[1]
					If Empty(cCodTES)
						aRtCNFe := { .F. , "TES nao informado no Pedido de Compras" }
						cTpErro := "F"
					EndIf
				EndIf
				
			EndIf
		EndIf	


		//Valida CST da TES, quando nao houver de-para de CFOP
		If aRtCNFe[1]
			If cVld06 == "S" // .And. !lTransf

				cQry := "SELECT SF4.F4_SITTRIB AS F4SITTRIB "
				cQry += "FROM "+cTblSF4+" SF4 "
				cQry += "WHERE SF4.D_E_L_E_T_ = ' ' "
				cQry += "AND SF4.F4_FILIAL = '"+cFilSF4+"' "
				cQry += "AND SF4.F4_CODIGO = '"+cCodTES+"' "

				Iif(Select("WRKSF4")>0,WRKSF4->(dbCloseArea()),Nil)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WRKSF4",.T.,.T.)
				WRKSF4->(dbGoTop())

				If WRKSF4->(!EoF())
					If !Empty(WRKSF4->F4SITTRIB)
						cCstICM := WRKSF4->F4SITTRIB
					Else
						aRtCNFe := { .F. , "Situacao Tributaria do ICMS nao informada no TES "+cCodTES+" do Pedido de Compras" }
						cTpErro := "F"
					EndIf
				Else
					aRtCNFe := { .F. , "Situacao Tributaria do ICMS nao informada no TES "+cCodTES+" do Pedido de Compras" }
					cTpErro := "F"
				EndIf
				WRKSF4->(dbCloseArea())
				
			EndIf

		EndIf
		
		// Valida Impostos Simples Nacional
		If aRtCNFe[1] .And. !Empty(ZD3->ZD3_CSOSN)
		
			cMsgErro := ""
		
			cCSOSN := SubStr(Alltrim(ZD3->ZD3_CSOSN),2,3)
			
			If cCSOSN == "101"
				If ZD3->ZD3_PICM <= 0 .Or. ZD3->ZD3_VALICM <= 0
					cMsgErro += "  - ICMS calculado incorretamente para CST 101 - Simples Nacional "+ CRLF
				EndIf
			EndIf
	
			If cCSOSN == "102"
				If ZD3->ZD3_PICM > 0 .Or. ZD3->ZD3_VALICM > 0
					cMsgErro += "  - ICMS calculado incorretamente para CST 102 - Simples Nacional "+ CRLF
				EndIf
			EndIf
	
			If cCSOSN == "201"
				If ZD3->ZD3_PICM > 0 .Or. ZD3->ZD3_VALICM > 0
					cMsgErro += "  - ICMS calculado incorretamente para CST 102 - Simples Nacional "+ CRLF
				EndIf
			EndIf
			
			If !Empty(cMsgErro)
				aRtCNFe  := { .F. , " Segue abaixo divergências de impostos. Item NF: "+AllTrim(ZD3->ZD3_ITEMNF)+" Prod: "+AllTrim(SB1->B1_COD)+ " " + CRLF + cMsgErro }
				cTpErro  := "F"
			EndIf
		EndIf
		
		//Valida Impostos Quando nao e Simples Nacional
		If aRtCNFe[1] .And. Empty(ZD3->ZD3_CSOSN)
			MaFisSave()
			MaFisEnd()
			
			cCodFor := PADR(ZD3->ZD3_CODFOR,TAMSX3("A1_COD")[1])
			cLojFor := PADR(ZD3->ZD3_LOJFOR,TAMSX3("A1_LOJA")[1])
				
			SA1->(dbSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA
			SA1->(dbSeek(xFilial("SA1")+cCodFor+cLojFor))
					
			MaFisIni(cCodFor, cLojFor, "F", "N", SA1->A1_TIPO, nil, nil, nil, nil, "MATA103", nil, nil, nil)
			
			SF4->(dbSetOrder(1))  // F4_FILIAL, F4_CODIGO.
			SF4->(dbSeek(xFilial("SF4")+cCodTES))
			
			cSitTrib := SF4->F4_SITTRIB
			
			MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, nQtdNF, nVlrUnit, 0, "", "", 0, 0, 0, 0, 0, ZD3->ZD3_VLRTOT, 0, SB1->(RECNO()), SF4->(RECNO()))
			nFisIt := 1
			
			// Aplica o IPI do Pedido de Compras para calculo
			MaFisAlt("IT_ALIQIPI", nAliqIPI, nFisIt)
			MaFisAlt("IT_ALIQICM", nAliqICM, nFisIt)
						
			nVlrMerc 	:= MaFisRet(nFisIt, "IT_VALMERC") 	// Valor da mercadoria
			
			nBaseICM 	:= MaFisRet(nFisIt, "IT_BASEICM") 	// Valor da Base de ICMS			
			nPICM 		:= MaFisRet(nFisIt, "IT_ALIQICM") 	// Aliquota de ICMS
			nValICM 	:= MaFisRet(nFisIt, "IT_VALICM") 	// Valor do ICMS Normal
			nBICMST 	:= MaFisRet(nFisIt, "IT_BASESOL") 	// Base do ICMS Solidario
			nAICMST 	:= MaFisRet(nFisIt, "IT_ALIQSOL") 	// Aliquota do ICMS Solidario
			nVICMST 	:= MaFisRet(nFisIt, "IT_VALSOL") 	// Valor do ICMS Solidario
			nBIPI 		:= MaFisRet(nFisIt, "IT_BASEIPI") 	// Valor da Base do IPI
			nPIPI 		:= MaFisRet(nFisIt, "IT_ALIQIPI") 	// Aliquota de IPI
			nValIPI 	:= MaFisRet(nFisIt, "IT_VALIPI") 	// Valor do IPI
			nBPIS 		:= MaFisRet(nFisIt, "IT_BASEPIS") 	// Base de calculo do PIS
			nAPIS 		:= MaFisRet(nFisIt, "IT_ALIQPIS") 	// Aliquota de calculo do PIS
			nVPIS 		:= MaFisRet(nFisIt, "IT_VALPIS") 	// Valor do PIS
			nBCOF 		:= MaFisRet(nFisIt, "IT_BASECOF") 	// Base de calculo do COFINS
			nACOF 		:= MaFisRet(nFisIt, "IT_ALIQCOF") 	// Aliquota de calculo do COFINS
			nVCOF 		:= MaFisRet(nFisIt, "IT_VALCOF") 	// Valor do COFINS
			
			// PIS e COFINS via apuracao
			nBPIS2  	:= MaFisRet(nFisIt, "IT_BASEPS2") 	// Base de calculo do PIS 2
			nAPIS2 		:= MaFisRet(nFisIt, "IT_ALIQPS2") 	// Aliquota de calculo do PIS 2
			nVPIS2 		:= MaFisRet(nFisIt, "IT_VALPS2") 	// Valor do PIS 2
			nBCOF2 		:= MaFisRet(nFisIt, "IT_BASECF2") 	// Base de calculo do COFINS 2
			nACOF2 		:= MaFisRet(nFisIt, "IT_ALIQCF2") 	// Aliquota de calculo do COFINS 2
			nVCOF2 		:= MaFisRet(nFisIt, "IT_VALCF2") 	// Valor do COFINS 2
			
			// Limpa item da função fiscal, pois o acumulo de itens vai degradando a performance.
			MaFisClear()
			
			// Limpa e restaura as funções fiscais.
			MaFisEnd()
			MaFisRestore()
			
			cMsgErro := ""
						
			If ZD3->ZD3_BASICM <> nBaseICM
				cMsgErro += "  - Valor da Base de ICMS divergente: XML ("+AllTrim(Transform(ZD3->ZD3_BASICM, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nBaseICM, "@E 999,999.99"))+") "+ CRLF
			EndIf
			
			If ZD3->ZD3_PICM <> nPICM
				cMsgErro += "  - Aliquota de ICMS divergente: XML ("+AllTrim(Transform(ZD3->ZD3_PICM, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nPICM, "@E 999,999.99"))+") "+ CRLF
			EndIf
			
			If ZD3->ZD3_VALICM <> nValICM
				cMsgErro += "  - Valor do ICMS Normal divergente: XML ("+AllTrim(Transform(ZD3->ZD3_VALICM, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nValICM, "@E 999,999.99"))+") "+ CRLF
			EndIf
						
			If ZD3->ZD3_BICMST > 0
				If ZD3->ZD3_BICMST <> nBICMST
					cMsgErro += "  - Base do ICMS Solidario divergente: XML ("+AllTrim(Transform(ZD3->ZD3_BICMST, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nBICMST, "@E 999,999.99"))+") "+ CRLF
				EndIf
				
				If ZD3->ZD3_AICMST <> nAICMST
					cMsgErro += "  - Aliquota do ICMS Solidario divergente: XML ("+AllTrim(Transform(ZD3->ZD3_AICMST, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nAICMST, "@E 999,999.99"))+") "+ CRLF
				EndIf
					
				If ZD3->ZD3_VICMST <> nVICMST
					cMsgErro += "  - Valor do ICMS Solidario divergente: XML ("+AllTrim(Transform(ZD3->ZD3_VICMST, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nVICMST, "@E 999,999.99"))+") "+ CRLF
				EndIf
			ElseIf nBICMST > 0 .And. !(cSitTrib == "60")
				cMsgErro += "  - Operação com Substituto Tributário: Divergência CST ("+cSitTrib+") "+ CRLF				
			EndIf
						
			If ZD3->ZD3_BASIPI > 0
				If ZD3->ZD3_BASIPI <> nBIPI
					cMsgErro += "  - Valor da Base do IPI divergente: XML ("+AllTrim(Transform(ZD3->ZD3_BASIPI, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nBIPI, "@E 999,999.99"))+") "+ CRLF
				EndIf
			EndIf
			
			If ZD3->ZD3_VALIPI <> nValIPI
				cMsgErro += "  - Valor do IPI divergente: XML ("+AllTrim(Transform(ZD3->ZD3_VALIPI, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nValIPI, "@E 999,999.99"))+") "+ CRLF
			EndIf
			
			If ZD3->ZD3_PIPI <> nPIPI
				cMsgErro += "  - Aliquota de IPI divergente: XML ("+AllTrim(Transform(ZD3->ZD3_PIPI, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform(nPIPI, "@E 999,999.99"))+") "+ CRLF
			EndIf
			
			If ZD3->ZD3_BPIS > nBPIS2
				cMsgErro += "  - Base de calculo do PIS divergente: XML ("+AllTrim(Transform(ZD3->ZD3_BPIS, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform((nBPIS2 - nVICMST - nValIPI), "@E 999,999.99"))+") "+ CRLF
			EndIf
			
			If ZD3->ZD3_BCOF > nBCOF2
				cMsgErro += "  - Base de calculo do COFINS divergente: XML ("+AllTrim(Transform(ZD3->ZD3_BCOF, "@E 999,999.99"))+") x Calculado ("+AllTrim(Transform((nBCOF2 - nVICMST - nValIPI), "@E 999,999.99"))+") "+ CRLF
			EndIf
			
			If !Empty(cMsgErro)
				aRtCNFe  := { .F. , " Segue abaixo divergências de impostos. Item NF: "+AllTrim(ZD3->ZD3_ITEMNF)+" Prod: "+AllTrim(SB1->B1_COD)+ " " + CRLF + cMsgErro }
				cTpErro  := "F"
			EndIf
		EndIf

		//Se Classificacao, ja' monta o array de itens
		If aRtCNFe[1]

			If cAcao == "C"
		
				aLiNFe  := {}

				If lTransf
					cItemNF := StrZero(Val(ZD3->ZD3_ITEMNF),2)
				Else
					cItemNF := ZD3->ZD3_ITEMNF
				EndIf

                If cMdClass == "1"
					aAdd( aLiNFe, { "D1_ITEM"	, cItemNF				, Nil				, nPD1ITEM } )
					aAdd( aLiNFe, { "D1_COD"	, SB1->B1_COD			, Nil				, nPD1COD } )
					aAdd( aLiNFe, { "D1_TES"	, cCodTES				, Nil				, nPD1TES } )
					aAdd( aLiNFe, { "D1_PEDIDO"	, ZD3->ZD3_NUMPED		, "AllWaysTrue()"	, nPD1PEDIDO } )
					aAdd( aLiNFe, { "D1_ITEMPC"	, ZD3->ZD3_ITPCPR 		, "AllWaysTrue()"	, nPD1ITEMPC } )
	   			Else				
					aAdd( aLiNFe, { "D1_ITEM"	, cItemNF				, Nil				, nPD1ITEM } )
					aAdd( aLiNFe, { "D1_COD"	, SB1->B1_COD			, Nil				, nPD1COD } )
					aAdd( aLiNFe, { "D1_UM"		, Iif(Empty(cUMProd),SB1->B1_UM,cUMProd)	, Nil, nPD1UM } )
					aAdd( aLiNFe, { "D1_QUANT"	, nQtdNF				, Nil				, nPD1QUANT } )
					aAdd( aLiNFe, { "D1_VUNIT"	, nVlrUnit				, Nil				, nPD1VUNIT } )
					aAdd( aLiNFe, { "D1_TOTAL"	, ZD3->ZD3_VLRTOT		, Nil				, nPD1TOTAL } )
					If lTransf
						aAdd( aLiNFe, { "D1_X_CLF"	, "TRN"		, Nil				, nPD1XCLF } )
					EndIf
					If !Empty(ZD3->ZD3_VALIPI)
						aAdd( aLiNFe, { "D1_VALIPI"	, ZD3->ZD3_VALIPI	, .F.				, nPD1VALIPI } )
					EndIf
					If !Empty(ZD3->ZD3_PICM)
						aAdd( aLiNFe, { "D1_PICM"	, ZD3->ZD3_PICM	, .F.					, nPD1PICM } )
					EndIf
					If !Empty(ZD3->ZD3_BASICM)
						aAdd( aLiNFe, { "D1_BASEICM"	, ZD3->ZD3_BASICM	, .F.			, nPD1BASEICM } )
					EndIf
					If !Empty(ZD3->ZD3_VALICM)
						aAdd( aLiNFe, { "D1_VALICM"	, ZD3->ZD3_VALICM	, .F.				, nPD1VALICM } )
					EndIf
					If !Empty(cCodTES)
						aAdd( aLiNFe, { "D1_TES"	, cCodTES			, Nil				, nPD1TES } )
					EndIf
					If !Empty(cCFOP)
						aAdd( aLiNFe, { "D1_CF"		, cCFOP				, Nil				, nPD1CF } )
					EndIf
					If !Empty(cOriPrd) .And. !Empty(cCstICM)
						aAdd( aLiNFe, { "D1_CLASFIS", cOriPrd + cCstICM	, Nil				, nPD1CLASFIS } )
					EndIf
					If !Empty(ZD3->ZD3_NUMPED)
						aAdd( aLiNFe, { "D1_PEDIDO"	, ZD3->ZD3_NUMPED	, Nil				, nPD1PEDIDO } )
					EndIf
					If !Empty(ZD3->ZD3_ITPCPR)
						aAdd( aLiNFe, { "D1_ITEMPC"	, ZD3->ZD3_ITPCPR	, Nil				, nPD1ITEMPC } )
					EndIf
					If !Empty(ZD3->ZD3_FCICOD)
						aAdd( aLiNFe, { "D1_FCICOD"	, ZD3->ZD3_FCICOD	, Nil				, nPD1FCICOD } )
					EndIf

					aAdd( aLiNFe, { "AUTDELETA" , "N" , Nil , "999999" } )

				EndIf

				aSort(aLiNFe,,,{|x,y| x[4] < y[4] })
				aAdd( aItNFe, aLiNFe )

			EndIf

		EndIf

		WKXZD3->(dbSkip())

	EndDo
	WKXZD3->(dbCloseArea())

EndIf


If aRtCNFe[1]
	If cVld07 == "S"
		If Empty(cCodNat)
			aRtCNFe := {.F.,"Codigo da natureza nao preechido no cadastro deste fornecedor"}
			cTpErro := "E"
		EndIf
	EndIf
EndIf


If aRtCNFe[1]
	If cVld08 == "S"
		If Empty(cCondPG)
			aRtCNFe := {.F.,"Condicao de pagamento nao preenchida no Pedido de Compras"}
			cTpErro := "E"
		EndIf
	EndIf
EndIf


If aRtCNFe[1]
	If cVld09 == "S" .And. !lTransf

		cQry := "SELECT "
		cQry += "ZD4.ZD4_VENCTO AS ZD4VENCTO, "
		cQry += "ZD4.ZD4_VALOR AS ZD4VALOR "
		cQry += "FROM "+cTblZD4+" ZD4 "
		cQry += "WHERE ZD4.D_E_L_E_T_ = ' ' "
		cQry += "AND ZD4.ZD4_FILIAL = '"+cFilZD4+"' "
		cQry += "AND ZD4.ZD4_CHVNFE = '"+cChvNFe+"' "
		cQry += "ORDER BY ZD4.ZD4_VENCTO"

		Iif(Select("WKXZD4")>0,WKXZD4->(dbCloseArea()),Nil)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKXZD4",.T.,.T.)
		TcSetField("WKXZD4","ZD4VENCTO","D",8,0)			
		TcSetField("WKXZD4","ZD4VALOR","N",12,2)			
		WKXZD4->(dbGoTop())

		While WKXZD4->(!EoF())
			aAdd( aPgNF, { WKXZD4->ZD4VENCTO , WKXZD4->ZD4VALOR } )
			nPgNF += WKXZD4->ZD4VALOR
			WKXZD4->(dbSkip())
		EndDo
		WKXZD4->(dbCloseArea())
		
		If Len(aPgNF) > 0

			aPgPC := Condicao( nPgNF, cCondPg,, dEmisNF  )

			If Len(aPgPC) <> Len(aPgNF)
				aRtCNFe[1] := .F.
				aRtCNFe[2] += "A quantidade de parcelas esta diferente do pedido de compras"+Chr(10)+Chr(13)
				cTpErro := "E"
			Else
				For nNx := 1 to Len(aPgPC)
					If cMdCPG == "1" 
						If aPgPC[nNx,1] > aPgNF[nNx,1]
							If aRtCNFe[1]
								aRtCNFe[1] := .F.
								aRtCNFe[2] := "A data da "+Alltrim(Str(nNx))+"a parcela esta diferente do pedido de compras (menor)"
							EndIf
						EndIf
					EndIf
					If cMdCPG == "2" 
						If aPgPC[nNx,1] < aPgNF[nNx,1]
							If aRtCNFe[1]
								aRtCNFe[1] := .F.
								aRtCNFe[2] := "A data da "+Alltrim(Str(nNx))+"a parcela esta diferente do pedido de compras (maior)"
							EndIf
						EndIf
					EndIf
					If cMdCPG == "3" 
						If aPgPC[nNx,1] <> aPgNF[nNx,1]
							If aRtCNFe[1]
								aRtCNFe[1] := .F.
								aRtCNFe[2] := "A data da "+Alltrim(Str(nNx))+"a parcela esta diferente do pedido de compras"
							EndIf
						EndIf
					EndIf
					If aPgPC[nNx,2] <> aPgNF[nNx,2]
						If aRtCNFe[1]
							aRtCNFe[1] := .F.
							aRtCNFe[2] := "O valor da "+Alltrim(Str(nNx))+"a parcela esta diferente do pedido de compras"
						EndIf
					EndIf
				Next nNx
			EndIf
		EndIf
	EndIf

EndIf


//Procede a classificacao da NFe, deve estar posicionado no SF1
If cAcao == "C"

	If aRtCNFe[1]
	
		If Empty(cCondPg)
			cCondPG := SuperGetMV("MV_CONDPAD",,"001")
		EndIf
	
		If ( Len(aItNFe) > 0 .And. nSF1Rcn > 0 )
		
			dbSelectArea("SF1")
			SF1->(dbSetOrder(1))
			SF1->(dbGoTo(nSF1Rcn))
	
			If !Empty(SF1->F1_TIPO)
				aAdd( aCbNFe, { "F1_TIPO" 		, SF1->F1_TIPO 					, Nil	, POSICIONE("SX3",2,"F1_TIPO" 		, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_FORMUL)
				aAdd( aCbNFe, { "F1_FORMUL" 	, SF1->F1_FORMUL 				, Nil	, POSICIONE("SX3",2,"F1_FORMUL" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_DOC)
				aAdd( aCbNFe, { "F1_DOC" 		, SF1->F1_DOC 					, Nil	, POSICIONE("SX3",2,"F1_DOC" 		, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_SERIE)
				aAdd( aCbNFe, { "F1_SERIE" 		, SF1->F1_SERIE 				, Nil	, POSICIONE("SX3",2,"F1_SERIE" 		, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_EMISSAO)
				aAdd( aCbNFe, { "F1_EMISSAO" 	, SF1->F1_EMISSAO 				, Nil	, POSICIONE("SX3",2,"F1_EMISSAO" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_DESPESA)
				aAdd( aCbNFe, { "F1_DESPESA" 	, SF1->F1_DESPESA 				, Nil	, POSICIONE("SX3",2,"F1_DESPESA" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_FORNECE)
				aAdd( aCbNFe, { "F1_FORNECE" 	, SF1->F1_FORNECE 				, Nil	, POSICIONE("SX3",2,"F1_FORNECE" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_LOJA)
				aAdd( aCbNFe, { "F1_LOJA" 		, SF1->F1_LOJA 					, Nil	, POSICIONE("SX3",2,"F1_LOJA" 		, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_ESPECIE)
				aAdd( aCbNFe, { "F1_ESPECIE" 	, SF1->F1_ESPECIE 				, Nil	, POSICIONE("SX3",2,"F1_ESPECIE" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_COND)
				aAdd( aCbNFe, { "F1_COND" 		, cCondPg 						, Nil	, POSICIONE("SX3",2,"F1_COND" 		, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_DESCONT)
				aAdd( aCbNFe, { "F1_DESCONT" 	, SF1->F1_DESCONT 				, Nil	, POSICIONE("SX3",2,"F1_DESCONT" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_SEGURO)
				aAdd( aCbNFe, { "F1_SEGURO" 	, SF1->F1_SEGURO 				, Nil	, POSICIONE("SX3",2,"F1_SEGURO" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_FRETE)
				aAdd( aCbNFe, { "F1_FRETE" 		, SF1->F1_FRETE 				, Nil	, POSICIONE("SX3",2,"F1_FRETE" 		, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_VALMERC)
				aAdd( aCbNFe, { "F1_VALMERC" 	, SF1->F1_VALMERC 				, Nil	, POSICIONE("SX3",2,"F1_VALMERC" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_VALBRUT)
				aAdd( aCbNFe, { "F1_VALBRUT" 	, SF1->F1_VALBRUT 				, Nil	, POSICIONE("SX3",2,"F1_VALBRUT" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_MOEDA)
				aAdd( aCbNFe, { "F1_MOEDA" 		, SF1->F1_MOEDA 				, Nil	, POSICIONE("SX3",2,"F1_MOEDA" 		, "X3_ORDEM") } )
			EndIf
			If !Empty(SF1->F1_TXMOEDA)
				aAdd( aCbNFe, { "F1_TXMOEDA" 	, SF1->F1_TXMOEDA 				, Nil	, POSICIONE("SX3",2,"F1_TXMOEDA" 	, "X3_ORDEM") } )
			EndIf
			If !Empty(cCodNat)
				aAdd( aCbNFe, { "E2_NATUREZ"	, cCodNat						, Nil	, Alltrim(Str(9999)) } )
			EndIf
	
			aSort(aCbNFe,,,{|x,y| x[4] < y[4] })
		
			Begin Transaction
		
				lMsErroAuto := .F.
				
				MsExecAuto( {|x,y,z| MATA103(x,y,z) }, aCbNFe, aItNFe, 4, .F.)
		
				If lMsErroAuto
					If !lInJb
						Mostraerro()
					EndIf
					aRtCNFe:= {.F.,"Erro ao classificar pre-nota"}
					cTpErro := "F"
					DisarmTransaction()
					ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: MsExecAuto")
				Else
					aRtCNFe:= {.T.,"NFe Classificada"}
				EndIf
			
			End Transaction	

        Else

			aRtCNFe := {.F.,"Erro ao classificar pre-nota. Verifique itens."}
			cTpErro := "F"

		EndIf
	
	EndIf

EndIf


//Se validou tudo corretamente, complementa retorno para gerar a pre-nota
If cAcao == "V"

	If aRtCNFe[1]
		aAdd(aRtCNFe, cSiglaUF)
		aAdd(aRtCNFe, cCondPG)
	EndIf

Else
	If !aRtCNFe[1]
		If Empty(cTpErro)
			cTpErro := "F"
		EndIf
		aAdd(aRtCNFe, cSiglaUF)
		aAdd(aRtCNFe, cTpErro)
	EndIf
EndIf

RestArea(aAreaZDE)
RestArea(aAreaZDC)
RestArea(aAreaZDB)
RestArea(aAreaZDA)
RestArea(aAreaZD3)
RestArea(aAreaZD2)
RestArea(aAreaSA5)
RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAtuArea)

Return(aRtCNFe)



User Function AlfExcMv()
Local cQry := ""

If !Empty(ZDH->ZDH_CHAVE)

	If MsgYesNo("Exclui movimentacao da NFe selecionada ?")

		cQry := "UPDATE SC7010 SET C7_QUJE = 0, C7_QTDACLA = 0 WHERE LTRIM(RTRIM(C7_FILIAL))+LTRIM(RTRIM(C7_NUM)) IN "
		cQry += "( SELECT DISTINCT LTRIM(RTRIM(ZD3_FILIAL))+LTRIM(RTRIM(ZD3_NUMPED)) FROM ZD3010 WHERE ZD3_CHVNFE = '"+ZDH->ZDH_CHAVE+"' )"
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM SD1010 WHERE R_E_C_N_O_ IN "
		cQry += "(SELECT DISTINCT D1.R_E_C_N_O_ AS D1RECNO FROM SD1010 D1 WHERE D1.D1_FILIAL + D1.D1_DOC + D1.D1_SERIE + D1.D1_FORNECE + D1.D1_LOJA + D1.D1_FORMUL IN "
		cQry += "(SELECT F1.F1_FILIAL+F1.F1_DOC+F1.F1_SERIE+F1.F1_FORNECE+F1.F1_LOJA+F1.F1_FORMUL FROM SF1010 F1 WHERE F1.F1_CHVNFE = '"+ZDH->ZDH_CHAVE+"' ) ) "
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM SFT010 WHERE FT_FILIAL + FT_NFISCAL + FT_SERIE + FT_CLIEFOR IN "
		cQry += "(SELECT F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE FROM SF1010 WHERE F1_CHVNFE = '"+ZDH->ZDH_CHAVE+"' ) "
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM SF3010 WHERE F3_FILIAL + F3_NFISCAL + F3_SERIE + F3_CLIEFOR IN "
		cQry += "(SELECT F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE FROM SF1010 WHERE F1_CHVNFE = '"+ZDH->ZDH_CHAVE+"' ) "
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM SE2010 WHERE LTRIM(RTRIM(E2_FILIAL)) + LTRIM(RTRIM(E2_NUM)) + LTRIM(RTRIM(E2_FORNECE)) IN "
		cQry += "(SELECT DISTINCT LTRIM(RTRIM(F1_FILIAL)) + LTRIM(RTRIM(F1_DOC)) + LTRIM(RTRIM(F1_FORNECE)) FROM SF1010 WHERE F1_CHVNFE = '"+ZDH->ZDH_CHAVE+"' ) "
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM SF1010 WHERE F1_CHVNFE = '"+ZDH->ZDH_CHAVE+"'"
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM ZD2010 WHERE ZD2_CHVNFE = '"+ZDH->ZDH_CHAVE+"'"
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM ZD3010 WHERE ZD3_CHVNFE = '"+ZDH->ZDH_CHAVE+"'"
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM ZD4010 WHERE ZD4_CHVNFE = '"+ZDH->ZDH_CHAVE+"'"
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		cQry := "DELETE FROM ZDH010 WHERE ZDH_CHAVE = '"+ZDH->ZDH_CHAVE+"'"
		Iif(TcSqlExec(cQry)<>0,Alert(TcSqlError()),Nil)

		Alert("Fim da Exclusao do movimento da NFe")

	EndIf

EndIf

Return(Nil)


User Function AlfAcLg()
LjMsgRun("Aguarde... Processando Legendas..." ,,{||PrcLgZDH()})
MsgInfo("Fim do Processamento")
Return(Nil)


Static Function PrcLgZDH()

Local cQry := ""
Local cLeg := ""
Local cMsg := ""
Local aAtuArea := GetArea()
Local aZDHArea := ZDH->(GetArea())

cQry := "SELECT "
cQry += "F1.F1_DOC AS F1DOC, "
cQry += "F1.F1_STATUS AS F1STATUS, "
cQry += "ZDH.R_E_C_N_O_ AS ZDHRECNO, "
cQry += "ZDH.ZDH_STATUS, "
cQry += "ZDH.ZDH_CHAVE "
cQry += "FROM "+RetSqlName("ZDH")+" ZDH "
cQry += "LEFT OUTER JOIN "+RetSqlName("SF1")+" F1 ON "
cQry += "F1.D_E_L_E_T_ = ZDH.D_E_L_E_T_ "
cQry += "AND F1.F1_FILIAL = ZDH.ZDH_FILIAL "
cQry += "AND F1_CHVNFE = ZDH.ZDH_CHAVE "
cQry += "WHERE ZDH.D_E_L_E_T_ = ' ' "
cQry += "AND ZDH.ZDH_CHAVE <> '' "
cQry += "ORDER BY ZDH.R_E_C_N_O_"

Iif(Select("WKZDHF1")>0,WKZDHF1->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"WKZDHF1",.T.,.T.)
TcSetField("WKZDHF1","ZDHRECNO","N",14,0)
WKZDHF1->(dbGoTop())

While WKZDHF1->(!EoF())

	cLeg := ""
	cMsg := ""
	
	If ( !Empty(WKZDHF1->F1DOC) .And. Empty(WKZDHF1->F1STATUS) )
		cLeg := "G"
		cMsg := "Pre-nota gerada"	
	ElseIf ( !Empty(WKZDHF1->F1DOC) .And. !Empty(WKZDHF1->F1STATUS) )
		cLeg := "C"
		cMsg := "NFe Classificada"	
	Else
		cLeg := "E"
		cMsg := "Erro ao gerar pre-nota"	
	EndIf

	cQry := "UPDATE "+RetSqlName("ZDH")+" SET ZDH_STATUS = '"+cLeg+"', ZDH_MSGERR = '"+cMsg+"' "
	cQry += "WHERE D_E_L_E_T_ = ' ' AND R_E_C_N_O_ = "+Alltrim(Str(WKZDHF1->ZDHRECNO))

	If TcSqlExec(cQry) <> 0
		Alert(TcSqlError())
	EndIf

	WKZDHF1->(dbSkip())
EndDo
WKZDHF1->(dbCloseArea())

RestArea(aZDHArea)
RestArea(aAtuArea)

Return(Nil)
