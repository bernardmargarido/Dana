#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE IMP_SITTRIB		01
#DEFINE IMP_BASEICM		02
#DEFINE IMP_VALICM		03
#DEFINE IMP_PICM		04
#DEFINE IMP_BICMST		05
#DEFINE IMP_AICMST		06
#DEFINE IMP_VICMST		07
#DEFINE IMP_MVA			08
#DEFINE IMP_BASIPI		09
#DEFINE IMP_VALIPI		10
#DEFINE IMP_PIPI		11
#DEFINE IMP_BPIS		12
#DEFINE IMP_APIS		13
#DEFINE IMP_VPIS		14
#DEFINE IMP_BCOF		15
#DEFINE IMP_ACOF		16
#DEFINE IMP_VCOF		17

/***********************************************************************         
* Autor     
* Descrição Rotina para Entrada de Dados da Nota
* Data      16/10/2017
***********************************************************************/
User Function AlfSfz06(cNotaShema, oXMLFile)
Local cError   := ""
Local cWarning := ""
Local cTipoXML := ""
Local aNotas   := {}
Local cQry     := ""
Local nX		:= 0
Local cPsqNFe := SuperGetMV("AF_PXMLNFE",,"N")
Default oXMLFile := Nil  //XML obtido a partir da opcao "Selecionar Arquivo"
PRIVATE oXMLNF  := Nil

If cPsqNFe <> "S"
	Return
EndIf

If oXMLFile <> Nil
	oXMLNF :=  oXMLFile
Else
	//Parei aqui: esta' trazendo a NFe resumida, quando feito o download da Sefaz
	oXMLNF :=  XMLParser( cNotaShema, "_", @cError,@cWarning)
EndIf

If TYPE("oXMLNF:_NFEPROC:_NFE:_INFNFE:_DET") == "A"
	aNotas := oXMLNF:_NFEPROC:_NFE:_INFNFE:_DET
ElseIf TYPE("oXMLNF:_NFEPROC:_NFE:_INFNFE:_DET") == "O"
	AADD( aNotas, oXMLNF:_NFEPROC:_NFE:_INFNFE:_DET )
EndIf

If Len(aNotas) > 0

	cChvNFE	 := oXMLNF:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
	cTipoXML := "PROCNFE"
	
	For nX:=1 To Len(aNotas)
		
		If Upper(cTipoXML) == "PROCNFE" // Mercadoria
			DbSelectArea("ZD2")
			ZD2->(DbSetOrder(2))
			 // ZD2_FILIAL+ZD2_CHVNFE
			If ZD2->(!DbSeek(xFilial("ZD2")+cChvNFE))
				ProcNFE(oXMLNF, cNotaShema)
			EndIf
		ElseIf cTipoXML == "PROCCTE" // Conhecimento de Transporte
			DbSelectArea("ZD7")
			DbSetOrder(2) // ZD7_FILIAL+ZD7_CHVCTE
			If !DbSeek(xFilial("ZD7")+cChvNFE)
				ProcCTE(oXMLNF)
			EndIf
			
		EndIf
	Next nX
	// Grava Arquivo XML
	GrvXML(cNotaShema,cChvNFE)
Else
	ConOut( "Não existe notas a serem importado")
EndIf

// Gerando as Pré-Notas
if Len(aNotas) > 0
	cQry := MntQry(cChvNFE)
	u_LoadZD2(cQry)
Endif

Return

/***********************************************************************
* Autor     
* Descrição Rotina para Gerar as Pré-Notas
* Data      19/10/2017
***********************************************************************/
User Function LoadZD2(pQry, pJOB)
Local aAreaZ := GetArea()
Local aRetNF := {}
Local cPsqNFe := SuperGetMV("AF_PXMLNFE",,"N")


If SELECT("TMPZ") > 0
	TMPZ->( dbCloseArea() )
Endif

TcQuery pQry New Alias "TMPZ"

While TMPZ->( !Eof() )

	aRetNF := U_AlfChkChv(TMPZ->ZD2_CHVNFE)

	If ( !aRetNF[1] .And. !aRetNF[2] )
		If cPsqNFe == "S"
			GrvPreNota( TMPZ->ZD2_CHVNFE, TMPZ->ZD2_NUMNF, TMPZ->ZD2_SERIE )
		EndIf
	Else
		If !pJob
			If aRetNF[1]
				MsgInfo("Pre-Nota Gerada")
			EndIf
			If aRetNF[2]
				MsgInfo("NFe Classificada")
			EndIf
		EndIf
	EndIF
	TMPZ->( dbSkip() )
EndDo

If SELECT("TMPZ") > 0
	TMPZ->( dbCloseArea() )
Endif

RestArea( aAreaZ )

Return


/***********************************************************************
* Autor     
* Descrição Rotina para carregamento dos arquivos de XML de Entrada
* Data      16/10/2017
***********************************************************************/
Static Function ProcNFE(oNota, cNotaShema)

Local aAreaAtu := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaZD2 := ZD2->(GetArea())
Local aAreaZD3 := ZD3->(GetArea())
Local aAreaZD4 := ZD4->(GetArea())

Local aItens 	:= {}
Local aParcelas	:= {}
Local aNFE		:= {}
Local nItem

Local nTamNF 	:= TAMSX3("D1_DOC")[1]
Local nTamItem 	:= TAMSX3("D1_ITEM")[1]
Local cTQry := ""
Local lRet := .T.
Local cNumPC := ""

Private aSitTrib 	:= &(SuperGetMV("AF_XMLSTNO",,'{"00","10","20","30","40","41","50","51","60","70","90","PART"}'))
Private aSitSN 		:= &(SuperGetMV("AF_XMLSTSN",,'{"101","102","103","201","202","203","300","400","500","900"}'))
Private oNFXML := oNota
Private oTotalNFe
Private oProduto
Private cNmForn := oNFXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT

cFinNfe 	:= oNFXML:_NFEPROC:_NFE:_INFNFE:_IDE:_FINNFE:TEXT
cNumNF 		:= StrZero(Val(oNFXML:_NFEPROC:_NFE:_INFNFE:_IDE:_nNF:TEXT),nTamNF)
cSerie 		:= oNFXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
dEmissao	:= SToD(StrTran(SubStr(oNFXML:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10),'-'))
cChaveNFE 	:= oNFXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
cCNPJForn 	:= oNFXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
cNatOper 	:= oNFXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
lSimples 	:= AllTrim(oNFXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CRT:TEXT) == "1"

// Validando se existe o CNPJ do fornecedor
cTQry := "SELECT ISNULL(A2.R_E_C_N_O_,0) AS A2RECNO "
cTQry += "FROM "+RetSqlName("SA2")+" A2 "
cTQry += "WHERE A2.D_E_L_E_T_ = ' ' "
//cTQry += "AND A2.A2_FILIAL = '"+xFilial("SA2")+"' "
cTQry += "AND A2.A2_CGC = '"+Alltrim(cCNPJForn)+"' "
cTQry += "AND A2.A2_MSBLQL <> '1'"
Iif(Select("WKXSA2")>0,WKXSA2->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cTQry),"WKXSA2",.T.,.T.)
TcSetField("WKXSA2","A2RECNO","N",14,0)
WKXSA2->(dbGoTop())

If WKXSA2->(!EoF())
	If WKXSA2->A2RECNO > 0
		lRet := .T.
		SA2->(dbGoTo(WKXSA2->A2RECNO))
	Else
		lRet := .F.
	EndIf
EndIf
WKXSA2->(dbCloseArea())

If lRet
	cCodForn 	:= SA2->A2_COD
	cLjForn 	:= SA2->A2_LOJA
	cUFForn 	:= SA2->A2_EST
	cNumFor     := SA2->A2_NOME
Else
	cCodForn 	:= CriaVar("A2_COD",.F.)
	cLjForn 	:= CriaVar("A2_LOJA",.F.)
	cUFForn 	:= CriaVar("A2_EST",.F.)
	cNumFor     := CriaVar("A2_NOME",.F.)
	// Adicionar Log - Fornecedor não localizado
	cMsgError := "Fornecedor não localizado"
	Conout(cMsgError)
EndIf

cCNPJDest := oNFXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
aNFE := { cChaveNFE, cNumNF, cNmForn,'','I',cNumNF}


u_GrvControle(aNFE, cNotaShema)

RecLock("ZD2",.T.)
REPLACE ZD2_FILIAL	WITH xFilial("ZD2")
REPLACE ZD2_NUMNF	WITH cNumNF
REPLACE ZD2_SERIE	WITH StrZero(Val(cSerie),3)
REPLACE ZD2_EMISSA 	WITH dEmissao
REPLACE ZD2_CHVNFE 	WITH cChaveNFE
REPLACE ZD2_CNPJFO	WITH cCNPJForn
REPLACE ZD2_CODFOR	WITH cCodForn
REPLACE ZD2_LOJFOR	WITH cLjForn
REPLACE ZD2_UFFORN	WITH cUFForn
REPLACE ZD2_CNPJDE	WITH cCNPJDest
REPLACE ZD2_DTLOG 	WITH DATE()
REPLACE ZD2_HRLOG 	WITH TIME()
REPLACE ZD2_STATUS 	WITH "A"
REPLACE ZD2_FINNFE 	WITH cFinNfe
REPLACE ZD2_NATOPE 	WITH cNatOper

If TYPE("oNFXML:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT") == "C"
	REPLACE ZD2_INFCPL 	WITH oNFXML:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT
EndIf

If TYPE("oNFXML:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT") == "C"
	REPLACE ZD2_INFADF 	WITH oNFXML:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT
EndIf

//Obs.: corrigir gravacao dos totais
If TYPE("oNFXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT") == "C"
	oTotalNFe := oNFXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT
EndIf

If Type("oTotalNFe") <> "U"	
	REPLACE ZD2_VBC 	WITH Val(oTotalNFe:_VBC:TEXT)
	REPLACE ZD2_VICMS 	WITH Val(oTotalNFe:_VICMS:TEXT)
	REPLACE ZD2_VDESON	WITH Val(oTotalNFe:_VICMSDESON:TEXT)
	REPLACE ZD2_VBCST 	WITH Val(oTotalNFe:_VBCST:TEXT)
	REPLACE ZD2_VST 	WITH Val(oTotalNFe:_VST:TEXT)
	REPLACE ZD2_VPROD 	WITH Val(oTotalNFe:_VPROD:TEXT)
	REPLACE ZD2_VFRETE 	WITH Val(oTotalNFe:_VFRETE:TEXT)
	REPLACE ZD2_VSEG 	WITH Val(oTotalNFe:_VSEG:TEXT)
	REPLACE ZD2_VDESC 	WITH Val(oTotalNFe:_VDESC:TEXT)
	REPLACE ZD2_VII 	WITH Val(oTotalNFe:_VII:TEXT)
	REPLACE ZD2_VIPI 	WITH Val(oTotalNFe:_VIPI:TEXT)
	REPLACE ZD2_VPIS 	WITH Val(oTotalNFe:_VPIS:TEXT)
	REPLACE ZD2_VCONFI 	WITH Val(oTotalNFe:_VCOFINS:TEXT)
	REPLACE ZD2_VOUTRO 	WITH Val(oTotalNFe:_VOUTRO:TEXT)
	REPLACE ZD2_VNF 	WITH Val(oTotalNFe:_VNF:TEXT)
EndIf
	
If TYPE("oTotalNFe:_VTOTTRIB:TEXT") == "C"
	REPLACE ZD2_VTRIB 	WITH Val(oTotalNFe:_VTOTTRIB:TEXT)
EndIf

ZD2->(MsUnlock())

If TYPE("oNFXML:_NFEPROC:_NFE:_INFNFE:_DET") == "A"
	aItens := oNFXML:_NFEPROC:_NFE:_INFNFE:_DET
ElseIf TYPE("oNFXML:_NFEPROC:_NFE:_INFNFE:_DET") == "O"
	AADD( aItens, oNFXML:_NFEPROC:_NFE:_INFNFE:_DET )
EndIf

nTotal := Len(aItens)

For nItem := 1 To nTotal
	
	oEmitente 	:= oNFXML:_NFEPROC:_NFE:_INFNFE:_EMIT
	oImposto 	:= aItens[nItem]
	aImpostos 	:= RetImpostos()
	
	oProduto := aItens[nItem]:_PROD
	
	RecLock("ZD3",.T.)
	REPLACE ZD3_FILIAL	WITH xFilial("ZD3")
	REPLACE ZD3_NUMNF	WITH cNumNF
	REPLACE ZD3_SERIE	WITH StrZero(Val(cSerie),3)
	REPLACE ZD3_CNPJFO	WITH cCNPJForn
	REPLACE ZD3_CODFOR	WITH cCodForn
	REPLACE ZD3_LOJFOR	WITH cLjForn
	REPLACE ZD3_CHVNFE	WITH cChaveNFE
	REPLACE ZD3_ITEMNF 	WITH StrZero(Val(aItens[nItem]:_nItem:TEXT),nTamItem)
	REPLACE ZD3_PRDFOR	WITH oProduto:_cProd:TEXT
	REPLACE ZD3_EANFOR	WITH oProduto:_cEAN:TEXT
	REPLACE ZD3_DESFOR	WITH oProduto:_xProd:TEXT
	REPLACE ZD3_NCMFOR	WITH oProduto:_NCM:TEXT
	REPLACE ZD3_CFOP	WITH oProduto:_CFOP:TEXT
	REPLACE ZD3_UM		WITH oProduto:_uCom:TEXT
	REPLACE ZD3_QUANT	WITH VAL(oProduto:_qCom:TEXT)
	REPLACE ZD3_VLRUNI	WITH VAL(oProduto:_vUnCom:TEXT)
	REPLACE ZD3_VLRTOT	WITH VAL(oProduto:_vProd:TEXT)
	REPLACE ZD3_SLDNF	WITH VAL(oProduto:_qCom:TEXT)
	if TYPE("oProduto:_MED:_nLOTE:TEXT")=="C"
		If ZD3->(FieldPos("ZD3_LOTECT")) > 0
			REPLACE ZD3_LOTECT WITH oProduto:_MED:_nLOTE:TEXT
		EndIf
	EndIf
	if TYPE("oProduto:_MED:_dFAB:TEXT")=="C"
		If ZD3->(FieldPos("ZD3_DTFABR")) > 0
			REPLACE ZD3_DTFABR WITH SToD(StrTran(oProduto:_MED:_dFAB:TEXT,'-'))
		EndIf
	EndIF
	if TYPE("oProduto:_MED:_dVAL:TEXT")=="C"
		If ZD3->(FieldPos("ZD3_DTVALI")) > 0
			REPLACE ZD3_DTVALI WITH SToD(StrTran(oProduto:_MED:_dVAL:TEXT,'-'))
		EndIf
	EndIf
	If TYPE("oProduto:_xPed:TEXT") == "C"
		REPLACE ZD3_NUMPED	WITH oProduto:_xPed:TEXT
		If Empty(cNumPC)
			cNumPC := oProduto:_xPed:TEXT
		EndIf
	EndIf
	If TYPE("oProduto:_nItemPed:TEXT") == "C"
		REPLACE ZD3_ITPEDC	WITH StrZero(Val(oProduto:_nItemPed:TEXT),4)
	EndIf
	If TYPE("oProduto:_nFCI:TEXT") == "C"
		REPLACE ZD3_FCICOD	WITH oProduto:_nFCI:TEXT
	EndIf

	REPLACE ZD3_PRODP	WITH ""
	If lSimples
		REPLACE ZD3_CSOSN 	WITH aImpostos[IMP_SITTRIB]
	Else
		REPLACE ZD3_CST 	WITH aImpostos[IMP_SITTRIB]
	EndIf
	
	REPLACE ZD3_ORIPRD 	WITH SubStr(aImpostos[IMP_SITTRIB],1,1)
	If lSimples
		REPLACE ZD3_BASICM 	WITH VAL(oProduto:_vProd:TEXT) + IIF(TYPE("oProduto:_vFrete:TEXT") == "C",VAL(oProduto:_vFrete:TEXT),0)
	Else
		REPLACE ZD3_BASICM 	WITH aImpostos[IMP_BASEICM]
	EndIf
	REPLACE ZD3_PICM 	WITH aImpostos[IMP_PICM]
	REPLACE ZD3_VALICM 	WITH aImpostos[IMP_VALICM]
	REPLACE ZD3_BICMST 	WITH aImpostos[IMP_BICMST]
	REPLACE ZD3_AICMST 	WITH aImpostos[IMP_AICMST]
	REPLACE ZD3_VICMST 	WITH aImpostos[IMP_VICMST]
	REPLACE ZD3_MVA 	WITH aImpostos[IMP_MVA]
	REPLACE ZD3_BASIPI 	WITH aImpostos[IMP_BASIPI]
	REPLACE ZD3_PIPI 	WITH aImpostos[IMP_PIPI]
	REPLACE ZD3_VALIPI 	WITH aImpostos[IMP_VALIPI]
	REPLACE ZD3_BPIS 	WITH aImpostos[IMP_BPIS]
	REPLACE ZD3_APIS 	WITH aImpostos[IMP_APIS]
	REPLACE ZD3_VPIS 	WITH aImpostos[IMP_VPIS]
	REPLACE ZD3_BCOF 	WITH aImpostos[IMP_BCOF]
	REPLACE ZD3_ACOF 	WITH aImpostos[IMP_ACOF]
	REPLACE ZD3_VCOF 	WITH aImpostos[IMP_VCOF]
	//REPLACE ZD3_CSTPIS 	WITH aImpostos[6]
	//REPLACE ZD3_CSTCOF 	WITH aImpostos[6]
		
	If ZD3->(FieldPos("ZD3_VFRETE")) > 0
		If TYPE("oProduto:_vFrete:TEXT") == "C"
			REPLACE ZD3_VFRETE WITH VAL(oProduto:_vFrete:TEXT)
		EndIf
	EndIf
	
	If ZD3->(FieldPos("ZD3_VDESC")) > 0
		If TYPE("oProduto:_vDesc:TEXT") == "C"
			REPLACE ZD3_VDESC WITH VAL(oProduto:_vDesc:TEXT)
		EndIf
	EndIf
	
	ZD3->(MsUnlock())
	
Next nItem

If TYPE("oNFXML:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP") == "A"
	aParcelas := oNFXML:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP
ElseIf TYPE("oNFXML:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP") == "O"
	AADD( aParcelas, oNFXML:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP )
EndIf

nTotal := Len(aParcelas)

For nItem := 1 To nTotal
	
	dVencto	:= SToD(StrTran(SubStr(aParcelas[nItem]:_dVenc:TEXT,1,10),'-'))
	nDias 	:= dVencto - dEmissao
	
	RecLock("ZD4",.T.)
	REPLACE ZD4_FILIAL	WITH xFilial("ZD4")
	REPLACE ZD4_CHVNFE	WITH cChaveNFE
	REPLACE ZD4_VENCTO	WITH dVencto
	REPLACE ZD4_VALOR	WITH VAL(aParcelas[nItem]:_vDup:TEXT)
	REPLACE ZD4_DIAS	WITH nDias
	REPLACE ZD4_NUMDUP	WITH aParcelas[nItem]:_nDup:TEXT
	MsUnlock()
	
Next nItem

If !Empty(cNumPC)
	dbSelectArea("ZDH")
	If FieldPOS("ZDH_NUMPC") > 0
		TcSqlExec("UPDATE "+RetSqlName("ZDH")+" SET ZDH_NUMPC = '"+cNumPC+"' WHERE D_E_L_E_T_ = ' ' AND ZDH_FILIAL = '"+cFilAnt+"' AND ZDH_CHAVE = '"+cChaveNFE+"'")
	EndIf
EndIf

U_AlfAtStNF( cChaveNFE, "G", "XML incluido no monitor" ) //Atualiza tabela de controle de NSU

RestArea(aAreaZD4)
RestArea(aAreaZD3)
RestArea(aAreaZD2)
RestArea(aAreaSA2)
RestArea(aAreaAtu)

Return



/*****************************************************************************
* Autor         Valdemir José Rabelo
* Descricao     Rotina para gravação da Pré-Nota (NFE)
* Data          16/10/2017
******************************************************************************/
Static Function GrvPreNota( cChvNFE, cNumNF, cSerie, pJob )
Local aArea 		:= GetArea()
Local aAreaSF1 		:= SF1->(GetArea())
Local aAreaSD1 		:= SD1->(GetArea())
Local aAreaSB1 		:= SB1->(GetArea())
Local aAreaZD2 		:= ZD2->(GetArea())
Local aAreaZD3 		:= ZD3->(GetArea())
Local nNx			:= 0
Local lRet 			:= .T.
Local lTransf		:= .F.
Local aCbSF1 		:= {}
Local aLiSD1 		:= {}
Local aItSD1 		:= {}
Local aNFe			:= {}
Local cCondPg 		:= GetMv("MV_CONDPAD")
Local cItemNF		:= ""
Local cPagPC 		:= ""
Local nNx 			:= 0
Local nNy 			:= 0
Local aPedidos 		:= {}
Local cFilCent		:= GetMv("MV_01FILCE",,"010021")
Local aRetVld		:= {}
Local _cError		:= {}
Local cMdGrvPNF		:= SuperGetMV("AF_MDGRVPN",,"")
Local cToGrvPNF		:= SuperGetMV("AF_MAILGPN",,"")
Local cSubj			:= ""
Local cBody			:= ""
Local cTTQry		:= ""
Private	lMsErroAuto := .F.
Private	lMsHelpAuto	:= .T.
Default pJOB		:= .F.

dbSelectArea("ZD2")
ZD2->(dbSetOrder(3))
If !ZD2->(dbSeek(cChvNFe))
	lRet := .F.
	aNFE := { cChvNFE, cNumNF, "","NFe nao encontrada na tabela ZD2", 'E' , '' }
EndIf
	

If lRet

	ConOut("Monitor XML - Gera Pre Nota Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+cChvNFe+" - MSG: inicio da geracao")
	aRetVld := U_ALFCLNFE( cChvNFe , "V" )
	If aRetVld[1]
		lRet := .T.
	Else
		lRet := .F.
		aNFE := { cChvNFE, cNumNF, "",aRetVld[2], 'E' , '' }
		ConOut("Monitor XML - Gera Pre Nota Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+cChvNFe+" - ERRO (validacao): "+aRetVld[2])
	EndIf
EndIf


//Monta arrays de cabecalho e itens
If lRet
	
	AADD( aCbSF1, {"F1_FILIAL" 	, xFilial("SF1")	, NIL, POSICIONE("SX3",2,"F1_FILIAL","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_TIPO"  	, "N"				, NIL, POSICIONE("SX3",2,"F1_TIPO","X3_ORDEM")		} )
	AADD( aCbSF1, {"F1_FORMUL" 	, "N"				, NIL, POSICIONE("SX3",2,"F1_FORMUL","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_DOC" 	, ZD2->ZD2_NUMNF	, NIL, POSICIONE("SX3",2,"F1_DOC","X3_ORDEM")		} )
	AADD( aCbSF1, {"F1_SERIE"	, StrZero(Val(ZD2->ZD2_SERIE),3),NIL,POSICIONE("SX3",2,"F1_SERIE","X3_ORDEM")} )
	AADD( aCbSF1, {"F1_EMISSAO"	, ZD2->ZD2_EMISSA	, NIL, POSICIONE("SX3",2,"F1_EMISSAO","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_FORNECE"	, ZD2->ZD2_CODFOR	, NIL, POSICIONE("SX3",2,"F1_FORNECE","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_LOJA"	, ZD2->ZD2_LOJFOR	, NIL, POSICIONE("SX3",2,"F1_LOJA","X3_ORDEM")		} )
	AADD( aCbSF1, {"F1_ESPECIE"	, "SPED"			, NIL, POSICIONE("SX3",2,"F1_ESPECIE","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_EST"		, aRetVld[3]		, NIL, POSICIONE("SX3",2,"F1_EMISSAO","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_COND"	, aRetVld[4]		, NIL, POSICIONE("SX3",2,"F1_COND","X3_ORDEM")		} )
	AADD( aCbSF1, {"F1_CHVNFE"	, ZD2->ZD2_CHVNFE	, NIL, POSICIONE("SX3",2,"F1_CHVNFE","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_DTDIGIT"	, DATE()			, NIL, POSICIONE("SX3",2,"F1_DTDIGIT","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_VALMERC"	, ZD2->ZD2_VPROD	, NIL, POSICIONE("SX3",2,"F1_VALMERC","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_VALBRUT"	, ZD2->ZD2_VNF		, NIL, POSICIONE("SX3",2,"F1_VALBRUT","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_DESCONT"	, ZD2->ZD2_VDESC	, NIL, POSICIONE("SX3",2,"F1_DESCONT","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_VALIPI"	, ZD2->ZD2_VIPI		, NIL, POSICIONE("SX3",2,"F1_VALIPI","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_VALICM"	, ZD2->ZD2_VICMS	, NIL, POSICIONE("SX3",2,"F1_VALICM","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_VALPIS"	, ZD2->ZD2_VICMS	, NIL, POSICIONE("SX3",2,"F1_VALICM","X3_ORDEM")	} )
	AADD( aCbSF1, {"F1_FRETE"	, ZD2->ZD2_VFRETE	, NIL, POSICIONE("SX3",2,"F1_FRETE","X3_ORDEM")	} )
	
	ASort(aCbSF1,,,{|x,y|x[4] < y[4]})
	
	dbSelectArea("ZD3")
	dbSetOrder(1)
	dbSeek(xFilial("ZD3")+cChvNFE)
	While ( ZD3->(!EOF()) .And. xFilial("ZD3")+cChvNFE == ZD3->ZD3_FILIAL+ZD3->ZD3_CHVNFE )

		If SubStr(Alltrim(ZD3->ZD3_CNPJFO),1,8) == SubStr(Alltrim(SM0->M0_CGC),1,8)
			lTransf := .T.
		EndIf
		
		aLiSD1   := {}

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))

		If lTransf
			If !SB1->(dbSeek(xFilial("SB1")+Upper(Alltrim(ZD3->ZD3_PRDFOR))))
				lRet := .F.
			EndIf
		Else
			cTTQry := "SELECT DISTINCT "
			cTTQry += "A.A5_PRODUTO, "
			cTTQry += "B.B1_UM, "
			cTTQry += "ISNULL(B.R_E_C_N_O_,0) AS B1RECNO "
			cTTQry += "FROM "
			cTTQry += RetSqlName("SA5")+" A, "
			cTTQry += RetSqlName("SB1")+" B "
			cTTQry += "WHERE A.D_E_L_E_T_ <> '*' "
			cTTQry += "AND A.A5_FILIAL = '"+xFilial("SA5")+"' "
			cTTQry += "AND A.A5_FORNECE = '"+ZD3->ZD3_CODFOR+"' "
			cTTQry += "AND A.A5_LOJA = '"+ZD3->ZD3_LOJFOR+"' "
			cTTQry += "AND A.A5_CODPRF = '"+Upper(Alltrim(ZD3->ZD3_PRDFOR))+"' "
			cTTQry += "AND B.D_E_L_E_T_ <> '*' "
			cTTQry += "AND B.B1_FILIAL = '"+xFilial("SB1")+"' "
			cTTQry += "AND B.B1_COD = A.A5_PRODUTO"
	
			Iif(Select("WKA5B1")>0,WKA5B1->(dbCloseArea()),Nil)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cTTQry),"WKA5B1",.T.,.T.)
			TcSetField("WKA5B1","B1RECNO","N",14,0)
			WKA5B1->(dbGoTop())
	
			If WKA5B1->(!Eof())	
				If WKA5B1->B1RECNO > 0
				    SB1->(dbGoTo(WKA5B1->B1RECNO))
				Else
					lRet := .F.
				EndIf
			EndIf
			WKA5B1->(dbCloseArea())

		EndIf

		If lRet

            If lTransf
            	cItemNF := StrZero(Val(ZD3->ZD3_ITEMNF),2)
	        Else
            	cItemNF := ZD3->ZD3_ITEMNF
         	EndIf
			
			If cMdGrvPNF == "R"
				
				AADD( aLiSD1, {"D1_FILIAL" 	, xFilial("SD1") 	, NIL, POSICIONE("SX3",2,"F1_FILIAL","X3_ORDEM")	} )
				AADD( aLiSD1, {"D1_DOC" 	, ZD3->ZD3_NUMNF	, NIL, POSICIONE("SX3",2,"D1_DOC","X3_ORDEM")		} )
				AADD( aLiSD1, {"D1_SERIE" 	, StrZero(Val(ZD3->ZD3_SERIE),3),NIL,POSICIONE("SX3",2,"D1_SERIE","X3_ORDEM")} )
				AADD( aLiSD1, {"D1_FORNECE"	, ZD3->ZD3_CODFOR	, NIL, POSICIONE("SX3",2,"D1_FORNECE","X3_ORDEM")	} )
				AADD( aLiSD1, {"D1_LOJA"	, ZD3->ZD3_LOJFOR	, NIL, POSICIONE("SX3",2,"D1_LOJA","X3_ORDEM")		} )
				AADD( aLiSD1, {"D1_EMISSAO"	, ZD2->ZD2_EMISSA	, NIL, POSICIONE("SX3",2,"D1_EMISSAO","X3_ORDEM")	} )
				AADD( aLiSD1, {"D1_DTDIGIT"	, Date()			, NIL, POSICIONE("SX3",2,"D1_DTDIGIT","X3_ORDEM")	} )
				AADD( aLiSD1, {"D1_GRUPO"	, SB1->B1_GRUPO		, NIL, POSICIONE("SX3",2,"D1_GRUPO","X3_ORDEM")		} )
				AADD( aLiSD1, {"D1_TIPO"	, "N"				, NIL, POSICIONE("SX3",2,"D1_TIPO","X3_ORDEM")		} )
				AADD( aLiSD1, {"D1_DTVALID"	, Date()			, NIL, POSICIONE("SX3",2,"D1_DTVALID","X3_ORDEM")	} )
				AADD( aLiSD1, {"D1_FORMUL"	, "N"				, NIL, POSICIONE("SX3",2,"D1_FORMUL","X3_ORDEM")	} )
	
			EndIf
	
			AADD( aLiSD1, {"D1_ITEM" 	, cItemNF									, NIL, POSICIONE("SX3",2,"D1_ITEM","X3_ORDEM")		} )
			AADD( aLiSD1, {"D1_COD" 	, SB1->B1_COD								, "AllwaysTrue()", POSICIONE("SX3",2,"D1_COD","X3_ORDEM")		} )
			AADD( aLiSD1, {"D1_UM" 		, SB1->B1_UM								, NIL, POSICIONE("SX3",2,"D1_UM","X3_ORDEM")		} )
			AADD( aLiSD1, {"D1_QUANT" 	, ZD3->ZD3_QUANT							, NIL, POSICIONE("SX3",2,"D1_QUANT","X3_ORDEM")		} )
			AADD( aLiSD1, {"D1_VUNIT" 	, ZD3->ZD3_VLRUNI 							, NIL, POSICIONE("SX3",2,"D1_VUNIT","X3_ORDEM")		} )
			AADD( aLiSD1, {"D1_TOTAL" 	, Round((ZD3->ZD3_QUANT*ZD3->ZD3_VLRUNI),2), NIL, POSICIONE("SX3",2,"D1_TOTAL","X3_ORDEM")		} )
			AADD( aLiSD1, {"D1_LOCAL" 	, SB1->B1_LOCPAD 							, NIL, POSICIONE("SX3",2,"D1_CONTA","X3_ORDEM")		} )
			AADD( aLiSD1, {"D1_CONTA" 	, SB1->B1_CONTA 							, NIL, POSICIONE("SX3",2,"D1_LOCAL","X3_ORDEM")		} )
	 		AADD( aLiSD1, {"D1_PEDIDO" 	, ZD3->ZD3_NUMPED 							, "AllwaysTrue()", POSICIONE("SX3",2,"D1_PEDIDO","X3_ORDEM")	} )
	 		AADD( aLiSD1, {"D1_ITEMPC" 	, ZD3->ZD3_ITPCPR 							, "AllwaysTrue()", POSICIONE("SX3",2,"D1_ITEMPC","X3_ORDEM")	} )
	 		AADD( aLiSD1, {"D1_FCICOD" 	, ZD3->ZD3_FCICOD 							, "AllwaysTrue()", POSICIONE("SX3",2,"D1_FCICOD","X3_ORDEM")	} )
			ASort(aLiSD1,,,{|x,y|x[4] < y[4]})
				
			AADD( aItSD1, aLiSD1 )

		EndIf	

		dbSelectArea("ZD3")
		ZD3->(DbSkip())

	EndDo
	
EndIf


//Gravacao da Pre-Nota, via MsExecAuto ou RecLock 
If lRet .And. ( Len(aItSD1) > 0 .And. Len(aCbSF1) > 0 )

	Begin Transaction

	If cMdGrvPNF == "R"
	
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))
		If RecLock("SF1",.T.)

			For nNx := 1 to Len(aCbSF1)
				SF1->(&(Alltrim(aCbSF1[nNx,1]))) := aCbSF1[nNx,2]
			Next nNx
			SF1->(MsUnLock())
				 
			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			If RecLock("SD1",.T.)
				For nNx := 1 to Len(aItSD1)
					For nNY := 1 to Len(aItSD1[nNx])
						SD1->(&(Alltrim(aItSD1[nNx,nNy,1]))) := aItSD1[nNx,nNy,2]
					Next nNy
				Next nNx
				SD1->(MsUnLock())
			Else
		    	lRet := .F.
				aNFE := { ZD2->ZD2_CHVNFE, cNumNF, "","Erro na gravacao - SD1", 'E' , '' }	
			EndIf

	    Else

	    	lRet := .F.
			aNFE := { cChvNFE, cNumNF, "","Erro na gravacao - SF1", 'E' , '' }
	    
	    EndIf
	    
	Else
		
		lMsErroAuto := .F.
		lMsHelpAuto	:= .T.
		
		MsExecAuto( {|x,y,z| MATA140(x,y,z) }, aCbSF1, aItSD1, 3, .F.)
		
		If lMsErroAuto
	
	        FwMakeDir("\ErrorLog\")
	   		_cError:= Mostraerro("\ErrorLog\")
	        lRet := .F.
			aNFE := { cChvNFE, cNumNF, "",_cError, 'E' , '' }
			
		EndIf
		
	EndIf
	
	If !lRet

		DisarmTransaction()

	EndIf
	
	End Transaction
	
EndIf


If Len(aNFE) > 0 

	U_GrvControle(aNFE,'')
	
	cSubj := "Monitor XML - Erro ao Gerar Pré-Nota "+Alltrim(ZD2->ZD2_NUMNF)+" - "+Alltrim(ZDH->ZDH_FORNEC)
	cBody += '</p><font face="Arial">Prezado(a):</font></p>'
	cBody += '</p><font face="Arial"></font></p>'
	cBody += '</p><font face="Arial">O XML da NFe '+Alltrim(ZD2->ZD2_NUMNF)+' - '+Alltrim(ZDH->ZDH_FORNEC)+' foi importado para o Monitor XML, porem nao foi possivel gerar a Pre-Nota, pelo motivo abaixo:</font></p>'
	cBody += '</p><font face="Arial"> </font></p>'
	cBody += '</p><font face="Arial">'+Alltrim(aNFe[4])+'</font></p>'
	cBody += '</p><font face="Arial"></font></p>'
	cBody += '</p><font face="Arial">Obs.: está é uma mensagem automática gerada pelo sistema Protheus, não responda este e-mail.</font></p>'

	U_DNEnvEMail( Nil, cToGrvPNF, cSubj, cBody)
	ConOut("Monitor XML - Gera Pre Nota Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+cChvNFe+" - ERRO: "+aNFe[4])

Else
	ConOut("Monitor XML - Gera Pre Nota Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+cChvNFe+" - MSG: pre-nota gerada")
EndIf


If !pJob .And. IsInCallStack("U_ALFSFZ04")

	If lRet
		aNFE := { cChvNFE, cNumNF, "","Pre-Nota incluida","G",""}
		U_GrvControle(aNFE,'')
		U_AlfAtStNF( cChvNFE, "G", "Pre-Nota incluida" ) //Atualiza tabela de controle de NSU
		MsgInfo("Pre-Nota incluída com sucesso")
	Else
		U_AlfAtStNF( cChvNFE, "E", Alltrim(aNFe[4]) , "Pre-Nota" ) //Atualiza tabela de controle de NSU
		Alert("A pré-nota não será gerada: "+Alltrim(aNFE[4]),"Atenção!!!")
	EndIf
Endif

ConOut("Monitor XML - Gera Pre Nota Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+cChvNFe+" - MSG: fim da geracao da pre-nota")

RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAreaZD3)
RestArea(aAreaZD2)
RestArea(aAreaSB1)
RestArea(aArea)


Return(lRet)




/*****************************************************************************
* Autor         Valdemir José Rabelo
* Descricao     Rotina para carregamento dos arquivos de XML de Entrada.
* Data          16/10/2017
******************************************************************************/
/*
Static Function ProcCTE(oNota)

Local aAreaAtu := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaZD7 := ZD7->(GetArea())
Local aAreaZD8 := ZD8->(GetArea())

Local aCHVNFE 	:= {}
Local dEntNFE
Local nItem

Local nTamNF 	:= TAMSX3("D1_DOC")[1]
Local nTamItem 	:= TAMSX3("D1_ITEM")[1]

cNumNF 		:= StrZero(Val(oNota:_CTEPROC:_CTE:_INFCTE:_IDE:_nCT:TEXT),nTamNF)
cSerie 		:= oNota:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT
dEmissao	:= SToD(StrTran(SubStr(oNota:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,1,10),'-'))
cChvCTE 	:= oNota:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT
cCNPJForn 	:= oNota:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
nVlrFrete 	:= Val(oNota:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)

DbSelectArea("SA2")
DbSetOrder(3) // A2_FILIAL+A2_CGC
If DbSeek(xFilial("SA2")+cCNPJForn)
cCodForn 	:= SA2->A2_COD
cLjForn 	:= SA2->A2_LOJA
cUFForn 	:= SA2->A2_EST
Else
cCodForn 	:= CriaVar("A2_COD",.F.)
cLjForn 	:= CriaVar("A2_LOJA",.F.)
cUFForn 	:= CriaVar("A2_EST",.F.)
EndIf

cCNPJDest := oNota:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT

RecLock("ZD7",.T.)
REPLACE ZD7_FILIAL	WITH xFilial("ZD7")
REPLACE ZD7_NUMNF	WITH cNumNF
REPLACE ZD7_SERIE	WITH cSerie
REPLACE ZD7_EMISSA 	WITH dEmissao
REPLACE ZD7_CHVCTE 	WITH cChvCTE
REPLACE ZD7_CNPJFO	WITH cCNPJForn
REPLACE ZD7_CODFOR	WITH cCodForn
REPLACE ZD7_LOJFOR	WITH cLjForn
REPLACE ZD7_UFFORN	WITH cUFForn
REPLACE ZD7_CNPJDE	WITH cCNPJDest
REPLACE ZD7_DTLOG 	WITH DATE()
REPLACE ZD7_HRLOG 	WITH TIME()
REPLACE ZD7_STATUS 	WITH "A"
REPLACE ZD7_VLRFRE 	WITH nVlrFrete
MsUnlock()

//oNota:_CTEPROC:_CTE:_INFCTE:__INFCTENORM:_INFDOC:_INFNFE
If TYPE("oNota:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE") == "A"
aCHVNFE := oNota:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE
ElseIf TYPE("oNota:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE") == "O"
AADD( aCHVNFE, oNota:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE )
EndIf

nTotal := Len(aCHVNFE)

For nItem := 1 To nTotal
RecLock("ZD8",.T.)
REPLACE ZD8_FILIAL	WITH xFilial("ZD8")
REPLACE ZD8_CHVCTE	WITH cChvCTE
REPLACE ZD8_CHVNFE	WITH aCHVNFE[nItem]:_CHAVE:TEXT

If VldEntNFE(aCHVNFE[nItem]:_CHAVE:TEXT,@dEntNFE)
REPLACE ZD8_DTENTR WITH dEntNFE
REPLACE ZD8_HRENTR WITH TIME()
EndIf
MsUnlock()
Next nItem

// Valida se todas as NFE atrealada foram dada entrada
If U_XML03VCTE(cChvCTE)
// Gera pre-nota da CTE
U_XML03GCTE(cChvCTE)
EndIf

RestArea(aAreaZD8)
RestArea(aAreaZD7)
RestArea(aAreaSA2)
RestArea(aAreaAtu)

Return
*/

/*****************************************************************************
* Autor         Valdemir José Rabelo
* Descricao     Rotina para carregamento dos arquivos de XML de Entrada.
* Data          16/10/2017
*****************************************************************************/
Static Function RetImpostos()

Local aImpostos := Array(IMP_VCOF)
Local nLenSit 	:= 0
Local nY		:= 0
Local cSitTrib 	:= ""
Local nBaseICM 	:= 0
Local nValICM 	:= 0
Local nPICM 	:= 0
Local nBICMST 	:= 0
Local nAICMST 	:= 0
Local nVICMST 	:= 0
Local nMVA 		:= 0
Local nBIPI 	:= 0
Local nValIPI 	:= 0
Local nPIPI 	:= 0
Local nBPIS 	:= 0
Local nAPIS 	:= 0
Local nVPIS 	:= 0
Local nBCOF 	:= 0
Local nACOF 	:= 0
Local nVCOF 	:= 0

Private nPrivate2 := 0

If Type("oImposto:_Imposto") <> "U"
	If Type("oImposto:_Imposto:_ICMS") <> "U"
		nLenSit := Len(aSitTrib)
		For nY := 1 To nLenSit
			nPrivate2 := nY
			If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]) <> "U"
				If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBC:TEXT") <> "U"
					nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBC:TEXT"))
					nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_PICMS:TEXT"))
					nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_vICMS:TEXT"))
				ElseIf Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_MOTDESICMS") <> "U"
					If &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_CST:TEXT") == "40"
						nPICM   := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_MOTDESICMS:TEXT"))
						nValICM := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_vICMSDESON:TEXT"))
					EndIf
				EndIf
				
				cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_ORIG:TEXT")
				cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_CST:TEXT")
								
				If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_vBCST:TEXT") <> "U"
					nBICMST := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_vBCST:TEXT"))
					nAICMST := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_pICMSST:TEXT"))
					nVICMST := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_vICMSST:TEXT"))
				EndIf
			EndIf
		Next nY
		
		//Tratamento para o ICMS para optantes pelo Simples Nacional
		If Type("oEmitente:_CRT") <> "U" .And. oEmitente:_CRT:TEXT == "1"
			nLenSit := Len(aSitSN)
			For nY := 1 To nLenSit
				If nValICM == 0
					nPrivate2 := nY
					If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2])<>"U"
						nBaseICM := 0
						If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_VCREDICMSSN:TEXT")<>"U"
							nValICM := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_VCREDICMSSN:TEXT"))
						EndIf
						If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_PCREDSN:TEXT")<>"U"
							nPICM := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_PCREDSN:TEXT"))
						EndIf
						cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_ORIG:TEXT")
						cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_CSOSN:TEXT")
								
						If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_vBCST:TEXT") <> "U"
							nBICMST := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_vBCST:TEXT"))
							nAICMST := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_pICMSST:TEXT"))
							nVICMST := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_vICMSST:TEXT"))
						EndIf
					EndIf
				EndIf
			Next nY
		EndIf
	EndIf
	
	If Type("oImposto:_Imposto:_IPI")<>"U"
		If Type("oImposto:_Imposto:_IPI:_IPITrib:_vBC:TEXT")<>"U"
			nBIPI := Val(oImposto:_Imposto:_IPI:_IPITrib:_vBC:TEXT)
		EndIf
		If Type("oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT")<>"U"
			nPIPI := Val(oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
		EndIf
		If Type("oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT")<>"U"
			nValIPI := Val(oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
		EndIf
	EndIf
	
	If Type("oImposto:_Imposto:_PIS")<>"U"
		If Type("oImposto:_Imposto:_PIS:_PISAliq:_vBC:TEXT")<>"U"
			nBPIS := Val(oImposto:_Imposto:_PIS:_PISAliq:_vBC:TEXT)
		EndIf
		If Type("oImposto:_Imposto:_PIS:_PISAliq:_pPIS:TEXT")<>"U"
			nAPIS := Val(oImposto:_Imposto:_PIS:_PISAliq:_pPIS:TEXT)
		EndIf
		If Type("oImposto:_Imposto:_PIS:_PISAliq:_vPIS:TEXT")<>"U"
			nVPIS := Val(oImposto:_Imposto:_PIS:_PISAliq:_vPIS:TEXT)
		EndIf
	EndIf
	
	If Type("oImposto:_Imposto:_COFINS")<>"U"
		If Type("oImposto:_Imposto:_COFINS:_COFINSAliq:_vBC:TEXT")<>"U"
			nBCOF := Val(oImposto:_Imposto:_COFINS:_COFINSAliq:_vBC:TEXT)
		EndIf
		If Type("oImposto:_Imposto:_COFINS:_COFINSAliq:_pCOFINS:TEXT")<>"U"
			nACOF := Val(oImposto:_Imposto:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
		EndIf
		If Type("oImposto:_Imposto:_COFINS:_COFINSAliq:_vCOFINS:TEXT")<>"U"
			nVCOF := Val(oImposto:_Imposto:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
		EndIf
	EndIf
EndIf

aImpostos[IMP_SITTRIB] 	:= cSitTrib
aImpostos[IMP_BASEICM] 	:= nBaseICM
aImpostos[IMP_VALICM] 	:= nValICM
aImpostos[IMP_PICM] 	:= nPICM

aImpostos[IMP_BICMST] 	:= nBICMST
aImpostos[IMP_AICMST] 	:= nAICMST
aImpostos[IMP_VICMST] 	:= nVICMST
aImpostos[IMP_MVA] 		:= nMVA

aImpostos[IMP_BASIPI] 	:= nBIPI
aImpostos[IMP_VALIPI] 	:= nValIPI
aImpostos[IMP_PIPI] 	:= nPIPI

aImpostos[IMP_BPIS] 	:= nBPIS
aImpostos[IMP_APIS] 	:= nAPIS
aImpostos[IMP_VPIS] 	:= nVPIS

aImpostos[IMP_BCOF] 	:= nBCOF
aImpostos[IMP_ACOF] 	:= nACOF
aImpostos[IMP_VCOF] 	:= nVCOF
	
Return aImpostos



/*****************************************************************************
* Autor         Valdemir José Rabelo
* Descricao     Grava XML em pasta fisica
* Data          23/10/2017
*****************************************************************************/
Static Function GrvXML(pSchema, pChave)
Local cDIR := "\XML"
Local cArqChv := pChave+".xml"
Local aArea   := GetArea()

FWMakeDir( cDIR )

if !File(cDir+'\'+cArqChv)
	nHandle := fCreate(cDir+'\'+cArqChv)
	If fError() <> 0
		lRet := .F.
		Alert("Erro na gravacao do XML")
	Else
		fWrite(nHandle, pSchema)
		fClose(nHandle)
		lRet := .T.
	Endif
Endif

RestArea( aArea )

Return


/*/{Protheus.doc} nomeStaticFunction
(long_description)
Grava os registros de controle da importação
@type  Static Function
@author Valdemir José
@since 23/10/2017
@version version
@param param, param_type, param_descr
@return returno,return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function GrvControle(aDados, cNotaShema)
Local aAreaZDH 	  := GetArea()
Local lAdic	   	  := .F.
Local cChave   	  := aDados[1]
Local cNUMNF   	  := aDados[2]
Local cFornecedor := aDados[3]
Local cMsgError	  := aDados[4]
Local cStatus	  := aDados[5]
Local cF1DOC	  := aDados[6]

dbSelectArea("ZDH")
dbSetOrder(1)
lAdic := (!dbSeek(xFilial("ZDH")+cChave))

RecLock("ZDH",lAdic)
if lAdic			// NOVO REGISTRO
	ZDH->ZDH_FILIAL := XFILIAL("ZDH")
	ZDH->ZDH_ID 	:= PRXID()
	ZDH->ZDH_CHAVE  := cChave
	ZDH->ZDH_NUMNF  := cNUMNF
	ZDH->ZDH_DTIMPO := dDatabase
	ZDH->ZDH_HRIMPO := LEFT(TIME(),8)
	ZDH->ZDH_FORNEC := cFornecedor
endif
ZDH->ZDH_STATUS := cStatus
ZDH->ZDH_MSGERR := cMsgError
ZDH->ZDH_F1DOC  := cF1DOC
if !Empty(cNotaShema)
	ZDH->ZDH_SCHEMA := cNotaShema
Endif
ZDH->(MsUnlock())

RestArea( aAreaZDH )

Return


/*/{Protheus.doc} PRXID()
(long_description)
Busca o Proxima Sequencia do ID
@type  Static Function
@author user	Valdemir José
@since date		23/10/2017
@version version
@param param, param_type, param_descr
@return returno,return_type, PRXID()turn_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PRXID()
Local nRET := 1
Local aAreaZDH := GetArea()

dbSelectArea("ZDH")
dbSetOrder(2)
While dbSeek( xFilial("ZDH")+Alltrim(Str(nRET)) )
	nRET += 1
EndDo

RestArea( aAreaZDH )

Return nRET


/***********************************************************************
* Autor     Valdemir José
* Descrição Rotina para carregamento dos dados da Tabela Customizada
* Data      16/10/2017
***********************************************************************/
Static Function MntQry(cChvNFE)
Local cQry := "SELECT * " + CRLF
cQry += "FROM " + RETSQLNAME("ZD2") + " ZD2 " + CRLF
cQry += "WHERE D_E_L_E_T_ = '' " + CRLF
cQry += " AND ZD2_CHVNFE='" +cChvNFE+ "' " + CRLF
cQry += " AND ZD2_STATUS='A' " + CRLF
Return(cQry)
