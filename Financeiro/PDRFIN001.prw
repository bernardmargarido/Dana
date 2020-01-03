#Include "RwMake.Ch"
#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PDRFIN001 ¦  Autor ¦ Clayton Martins  ¦ Data ¦ 23/09/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Relação de Títulos a Receber Baixados e em aberto por      ¦¦¦
¦¦¦          ¦ Vencimento Real.                                           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function PDRFIN001()

Local cPerg			:= Padr("PDRFIN001",10)
Local cTitulo		:= "Relação de Títulos Contas a Receber"
Local cDesc			:= "Relação de Títulos a Receber, Baixados e Abertos por Vencimento"
Private cTab        := CriaTrab(NIL,.F.)
Private oReport		:= Nil
Private nLin		:= 3200
Private oSection1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria Perguntas no Arquivo SX1.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OTAjustaSx1(cPerg)
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Construcao do objeto TReport.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("PDRFIN001",cTitulo,"PDRFIN001",{|oReport| PrintReport(oReport, oSection1)},cDesc)
oReport:SetLandscape()
oReport:lfooterVisible:=.F.
//-- Cria sessões
oSection1 := TRSection():New(oReport,"RELAÇÃO DE TÍTULOS A RECEBER",{"SE1","SA1","SE5","SA3"})
TRCell():New(oSection1,"cSeq","   ","Sequência",,15,/*lPixel*/,{|| cSeq  })
TRCell():New(oSection1,"cPre","   ","Prefixo",PesqPict("SE1","E1_PREFIXO"),3,/*lPixel*/,{|| cPre })
TRCell():New(oSection1,"cTit","   ","Numero",PesqPict("SE1","E1_NUM"),10,/*lPixel*/,{|| cTit })
TRCell():New(oSection1,"cPar","   ","Parcela",PesqPict("SE1","E1_PARCELA"),3,/*lPixel*/,{|| cPar })
TRCell():New(oSection1,"cCli","   ","Cliente",PesqPict("SE1","E1_CLIENTE"),10,/*lPixel*/,{|| cCli })
TRCell():New(oSection1,"cLoj","   ","Loja",PesqPict("SE1","E1_CLIENTE"),3,/*lPixel*/,{|| cLoj })
TRCell():New(oSection1,"cNom","   ","Nome",PesqPict("SE1","E1_CLIENTE"),10,/*lPixel*/,{|| cFor })
TRCell():New(oSection1,"cVen","   ","Vendedor",PesqPict("SA3","A3_NOME"),10,/*lPixel*/,{|| cVen })
TRCell():New(oSection1,"cGen","   ","Gerente",PesqPict("SA3","A3_NOME"),10,/*lPixel*/,{|| cGen })
TRCell():New(oSection1,"cCgc","   ","CNPJ/CPF",PesqPict("SA1","A1_CGC"),10,/*lPixel*/,{|| cCgc })
TRCell():New(oSection1,"cBan","   ","Banco",PesqPict("SE5","E5_BANCO"),10,/*lPixel*/,{|| cBan })
TRCell():New(oSection1,"cAge","   ","Agência",PesqPict("SE5","E5_AGENCIA"),15,/*lPixel*/,{|| cAge })
TRCell():New(oSection1,"cCon","   ","Conta Corrente",PesqPict("SE5","E5_CONTA"),15,/*lPixel*/,{|| cCon })
TRCell():New(oSection1,"cNat","   ","Natureza",PesqPict("SE1","E1_NATUREZ"),15,/*lPixel*/,{|| cNat })
TRCell():New(oSection1,"dEmi","   ","Dt Emissão",PesqPict("SE1","E1_EMISSAO"),25,/*lPixel*/,{|| dEmi })
TRCell():New(oSection1,"dVec","   ","Vencimento",PesqPict("SE1","E1_EMISSAO"),25,/*lPixel*/,{|| dVec })
TRCell():New(oSection1,"dVen","   ","Vencto. Real",PesqPict("SE1","E1_EMISSAO"),25,/*lPixel*/,{|| dVen })
TRCell():New(oSection1,"dBax","   ","Dt Baixa",PesqPict("SE1","E1_EMISSAO"),25,/*lPixel*/,{|| dBax })
TRCell():New(oSection1,"cRec","   ","Reconciliado",PesqPict("SE5","E5_RECONC"),5,/*lPixel*/,{|| cRec })
TRCell():New(oSection1,"nVal","   ","Valor",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],/*lPixel*/,{|| nVal })
TRCell():New(oSection1,"nVbx","   ","Valor Baixa",PesqPict("SE1","E1_VALLIQ"),TamSX3("E1_VALLIQ")[1],/*lPixel*/,{|| nVbx })
TRCell():New(oSection1,"nVsa","   ","Valor Saldo",PesqPict("SE1","E1_VALLIQ"),TamSX3("E1_VALLIQ")[1],/*lPixel*/,{|| nVsa })
TRCell():New(oSection1,"cHis","   ","Histórico",PesqPict("SE1","E1_HIST"),TamSX3("E1_HIST")[1],/*lPixel*/,{|| cHis })
TRCell():New(oSection1,"cMbx","   ","Motivo Bx.",PesqPict("SE5","E5_MOTBX"),TamSX3("E5_MOTBX")[1],/*lPixel*/,{|| cMbx })
TRCell():New(oSection1,"cTip","   ","Tipo Título",PesqPict("SE1","E1_TIPO"),TamSX3("E1_TIPO")[1],/*lPixel*/,{|| cTip })

oSection1:SetLeftMargin(0)
oReport:PrintDialog()
/*
If TCSQLEXEC("DROP TABLE " + cTab ) != 0
	Alert(TCSQLERROR())
	Return()
EndIf
*/
Return()
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RRECDIA  ¦   Autor ¦ Clayton Martins  ¦ Data ¦ 02/05/2014  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao que monta query com base nos parametros informados  ¦¦¦
¦¦¦          ¦ Pelo usuário.	                                          ¦¦¦
¦¦¦          ¦ Arquivos usados : SE1 - SA1.                               ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ 										                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function OTHMntQry()

Local cQry		:= ""
Local cNaturez  := ""
Local cAux1  := AllTrim(mv_par09)
Local nX1		:= 1
Local cAux2  := AllTrim(mv_par10)
Local nX2		:= 1
For nX1 := 1 To Len(cAux1)
	If Substr(cAux1,nX1,1) == ';' .And. (nX1 <> Len(cAux1)) .And. (nX1 <> 1)
		cNaturez += "','"
	Else
		cNaturez += Substr(cAux1,nX1,1)
	EndIf
Next nX1
For nX2 := 1 To Len(cAux2)
	If Substr(cAux2,nX2,1) == ';' .And. (nX2 <> Len(cAux2)) .And. (nX2 <> 1)
		cNaturez += "','"
	Else
		cNaturez += Substr(cAux2,nX2,1)
	EndIf
Next nX2

cQry += " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E1_PREFIXO ,E1_NUM , E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_BAIXA, E1_VALOR, E1_VALLIQ, E1_NATUREZ, E1_SALDO,E5_HISTOR, E1_TIPO, E5_RECONC, E5_MOTBX, E1_VEND1, E1_XGERENT, SE1.R_E_C_N_O_ AS RECSE1   "+CRLF
cQry += " FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "+CRLF
cQry += " LEFT JOIN " + RetSqlName("SE5") + " SE5 ON ( " + CRLF
cQry += " E5_FILIAL = E1_FILIAL " + CRLF
cQry += " AND E5_NUMERO = E1_NUM " + CRLF
cQry += " AND E5_PREFIXO = E1_PREFIXO " + CRLF
cQry += " AND E5_PARCELA = E1_PARCELA " + CRLF
cQry += " AND E5_CLIFOR = E1_CLIENTE " + CRLF
cQry += " AND E5_LOJA = E1_LOJA " + CRLF
cQry += " AND E5_TIPO = E1_TIPO " + CRLF
cQry += " AND E5_RECPAG = 'R' " + CRLF
cQry += " AND E5_SITUACA <> 'C' " + CRLF
cQry += " AND E5_TIPODOC NOT IN('ES','MT','AP','CM','CP','JR','DC','CA','TE','TR') " + CRLF
cQry += " AND SE5.D_E_L_E_T_ <> '*' " + CRLF
cQry += " ) " + CRLF
cQry += " WHERE E1_CLIENTE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' AND SE1.D_E_L_E_T_ = ' '" +CRLF
cQry += " AND E1_LOJA BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "'" +CRLF
cQry += " AND E1_EMISSAO BETWEEN '"+Dtos(MV_PAR05)+"' AND '"+Dtos(MV_PAR06) + "'" +CRLF
cQry += " AND E1_VENCREA BETWEEN '"+Dtos(MV_PAR07)+"' AND '"+Dtos(MV_PAR08) + "'" +CRLF
cQry += " AND E1_VEND1 BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' " +CRLF
cQry += " AND E1_XGERENT BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' " +CRLF

If mv_par11 == 2 //Baixados
	cQry += " AND E1_BAIXA <> '' AND E5_RECONC = ''  " + CRLF
Elseif 	mv_par11 == 3 //Conciliados
	cQry += " AND E1_BAIXA <> '' AND E5_RECONC = 'x' " + CRLF
Elseif 	mv_par11 == 4 //Abertos
	cQry += " AND E1_SALDO > 0 " + CRLF
	cQry += " AND E1_TIPO <> 'RA' " + CRLF
Else //Todos
	cQry += "" + CRLF
Endif

If !Empty(cNaturez)
	If mv_par12 == 1
		cQry +=  " AND E1_NATUREZ IN('" + cNaturez + "')  "+CRLF
	Elseif mv_par12 == 2
		cQry +=  " AND E1_NATUREZ NOT IN('" + cNaturez + "')  "+CRLF
	Endif
Endif

If TCSQLEXEC(cQry) != 0
	Alert(TCSQLERROR())
	Return()
EndIf

cQry += " ORDER BY E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VENCREA "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se area esta em uso.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria instancia de trabalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T., "TOPCONN", TCGenQry(,, cQry), "TRB1", .F., .T. )
TcSetField("TRB1","E1_EMISSAO" 	,"D",08,0)
TcSetField("TRB1","E1_VENCREA" 	,"D",08,0)
TcSetField("TRB1","E1_VENCTO" 	,"D",08,0)
TcSetField("TRB1","E1_BAIXA" 	,"D",08,0)

Return()

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RRECDIA  ¦   Autor ¦ Clayton Martins  ¦ Data ¦ 02/05/2014  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao que imprime o relatorio com base nos parametros in- ¦¦¦
¦¦¦          ¦ -formados pelo usuario.                                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ 										                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function PrintReport()

Local cNom		:= ""
Local cVen		:= ""
Local cGen		:= ""
Local cCgc		:= ""
Local cSeq		:= 001
Local cQueryZ	:= ""

OTHMntQry()
oReport:SetMeter(0)

DbSelectArea("TRB1")
TRB1->(DbGoTop())
If oReport:nDevice <> 3
	oSection1:Init()
EndIf

While TRB1->(!EOF())
	DbSelectArea("SE1")
	SE1->(DbGoto(TRB1->RECSE1))
	
	DbSelectArea("TRB1")
	
	oReport:IncMeter()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que verifica limite de linhas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DHVerPag("")
	If oReport:Cancel()
		oPrint:End()
	EndIf
	
	If Select("TRB3") > 0
		TRB3->(DbCloseArea())
	Endif
	
	cQueryZ= " SELECT A1_NOME NOME, A1_CGC CGC FROM " + RetSqlName("SA1") + " (NOLOCK) "
	cQueryZ+= " WHERE	A1_COD = '"+TRB1->E1_CLIENTE+"' "
	cQueryZ+= " 		AND A1_LOJA = '"+TRB1->E1_LOJA+"' "
	cQueryZ+= " ORDER BY R_E_C_N_O_ "
	PLSQUERY(cQueryZ,"TRB3")
	
	DbSelectArea("TRB3")
	TRB3->(DbGoTop())
	If TRB3->(!Eof())
		cNom	:= Alltrim(TRB3->NOME)
		cCgc	:= Alltrim(TRB3->CGC)
	EndIf
	TRB3->(DbCloseArea())
	
	cDescNat	:= Posicione("SED",1,XFILIAL("SED")+TRB1->E1_NATUREZ,"ED_DESCRIC")
	cVen		:= Posicione("SA3",1,xFilial("SA3")+TRB1->E1_VEND1,"A3_NOME")
	cGen		:= Posicione("SA3",1,xFilial("SA3")+TRB1->E1_XGERENT,"A3_NOME")
	
	//-- Sequencia
	oSection1:Cell("cSeq"):SetValue(cSeq)
	
	//-- Prefixo
	oSection1:Cell("cPre"):SetValue(TRB1->E1_PREFIXO)
	
	//-- Número do Título
	oSection1:Cell("cTit"):SetValue(TRB1->E1_NUM)
	
	//-- Parcela
	oSection1:Cell("cPar"):SetValue(TRB1->E1_PARCELA)
	
	//-- Cliente
	oSection1:Cell("cCli"):SetValue(TRB1->E1_CLIENTE)
	
	//-- Loja
	oSection1:Cell("cLoj"):SetValue(TRB1->E1_LOJA)
	
	//-- Nome
	oSection1:Cell("cNom"):SetValue(cNom)
	
	//-- Vendedor
	oSection1:Cell("cVen"):SetValue(Alltrim(TRB1->E1_VEND1) + " - " +Alltrim(cVen))
	
	//-- Gerente
	oSection1:Cell("cGen"):SetValue(Alltrim(TRB1->E1_XGERENT) + " - " +Alltrim(cGen))
	
	//-- Cliente/Loja/Nome
	oSection1:Cell("cCgc"):SetValue(cCgc)
	
	//-- Banco
	oSection1:Cell("cBan"):SetValue(TRB1->E5_BANCO)
	
	//-- Agência
	oSection1:Cell("cAge"):SetValue(TRB1->E5_AGENCIA)
	
	//-- Conta Corrente
	oSection1:Cell("cCon"):SetValue(TRB1->E5_CONTA)
	
	//-- Natureza
	oSection1:Cell("cNat"):SetValue(Alltrim(TRB1->E1_NATUREZ) + " - " +Alltrim(cDescNat))
	
	//-- Emissão
	oSection1:Cell("dEmi"):SetValue(SUBSTR(DTOS(TRB1->E1_EMISSAO),7,2) +"/"+ SUBSTR(DTOS(TRB1->E1_EMISSAO),5,2) +"/"+ SUBSTR(DTOS(TRB1->E1_EMISSAO),1,4))
	
	//-- Vencimento
	oSection1:Cell("dVec"):SetValue(SUBSTR(DTOS(TRB1->E1_VENCTO),7,2) +"/"+ SUBSTR(DTOS(TRB1->E1_VENCTO),5,2) +"/"+ SUBSTR(DTOS(TRB1->E1_VENCTO),1,4))
	
	//-- Vencimento Real
	oSection1:Cell("dVen"):SetValue(SUBSTR(DTOS(TRB1->E1_VENCREA),7,2) +"/"+ SUBSTR(DTOS(TRB1->E1_VENCREA),5,2) +"/"+ SUBSTR(DTOS(TRB1->E1_VENCREA),1,4))
	
	//-- Data Baixa
	oSection1:Cell("dBax"):SetValue(SUBSTR(DTOS(TRB1->E1_BAIXA),7,2) +"/"+ SUBSTR(DTOS(TRB1->E1_BAIXA),5,2) +"/"+ SUBSTR(DTOS(TRB1->E1_BAIXA),1,4))
	
	//-- Reconciliados
	oSection1:Cell("cRec"):SetValue(TRB1->E5_RECONC)
	
	//-- Valor
	oSection1:Cell("nVal"):SetValue(TRB1->E1_VALOR)
	
	//-- Valor Baixa
	oSection1:Cell("nVbx"):SetValue(TRB1->E1_VALLIQ)
	
	//-- Valor Baixa
	oSection1:Cell("nVsa"):SetValue(TRB1->E1_SALDO)
	
	//-- Histórico
	oSection1:Cell("cHis"):SetValue(TRB1->E5_HISTOR)
	
	//-- Motivo da Baixa
	oSection1:Cell("cMbx"):SetValue(TRB1->E5_MOTBX)
	
	//-- Tipo Título
	oSection1:Cell("cTip"):SetValue(TRB1->E1_TIPO)
	nLin+=50
	
	If oReport:nDevice <> 3
		oSection1:PrintLine()
	EndIf
	cSeq ++
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que verifica limite de linhas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DHVerPag()
	If oReport:Cancel()
		oPrint:End()
	EndIf
	nLin+=50
	TRB1->(DBSKIP())
Enddo
If oReport:nDevice <> 3
	oSection1:Finish()
EndIF

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Clayon Martins      º Data ³  31/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que verifica o limite de linhas impressas.           º±±
±±º          ³Caso ultrapasse pula de pagina.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³			                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DHVerPag()

If nLin > 9999999
	oReport:EndPage()
	oReport:StartPage()
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSx1 ºAutor  ³Caio Pereira        º Data ³  12/30/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que cria perguntas no arquivo Sx1.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 			                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OTAjustaSx1(cPerg)

xPutSx1( cPerg, "01", "Cliente de ?"				    ,"","","mv_ch1","C",06,0,0,"G","","SA1","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","SA1","","","","")
xPutSx1( cPerg, "02", "Loja de?"						,"","","mv_ch2","C",02,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","")
xPutSx1( cPerg, "03", "Cliente ate?"				    ,"","","mv_ch3","C",06,0,0,"G","","SA1","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","SA1","","","","")
xPutSx1( cPerg, "04", "Loja ate?"						,"","","mv_ch4","C",02,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","")
xPutSx1( cPerg, "05", "Dt Emissão dê?" 					,"","","mv_ch5","D",08,0,0,"G","","","","","mv_par05",,,,,,,,,,,,,,,,,{"Dt Venc Real Dê"	    ,"para considerar na","geração do relatório."},{},{} )
xPutSx1( cPerg, "06", "Dt Emissão até?"	 				,"","","mv_ch6","D",08,0,0,"G","","","","","mv_par06",,,,,,,,,,,,,,,,,{"Dt Venc Real Até"  	    ,"para considerar na","geração do relatório."},{},{} )
xPutSx1( cPerg, "07", "Dt Venc Real dê?" 				,"","","mv_ch7","D",08,0,0,"G","","","","","mv_par07",,,,,,,,,,,,,,,,,{"Dt Emissão Dê"	  		,"para considerar na","geração do relatório."},{},{} )
xPutSx1( cPerg, "08", "Dt Venc Real até?" 				,"","","mv_ch8","D",08,0,0,"G","","","","","mv_par08",,,,,,,,,,,,,,,,,{"Dt Emissão Até"  	    ,"para considerar na","geração do relatório."},{},{} )
xPutSx1( cPerg, "09", "Naturezas?"       				,"","","mv_ch9","C",90,0,0,"G","","","","","mv_par09",,,,,,,,,,,,,,,,,{"Naturezas?"  	        ,"Separar Natureza por ponto e Virgula Se estiver em braco","imprime todas naturezas."},{},{} )
xPutSx1( cPerg, "10", "Cont. Naturezas?"       			,"","","mv_cha","C",90,0,0,"G","","","","","mv_par10",,,,,,,,,,,,,,,,,{"Cont. Naturezas?"  	    ,"Separar Natureza por ponto e Virgula Se estiver em braco","imprime todas naturezas."},{},{} )
xPutSx1( cPerg, "11", "Títulos?"						,"","","mv_chb","N", 1,0,0,"C","","","","","mv_par11","Todos","Todos","Todos", ,"Baixados","Baixados","Baixados","Conciliados","Conciliados","Conciliados","Abertos","Abertos","Abertos","","","","","")
xPutSx1( cPerg, "12", "Consid Naurezas?"				,"","","mv_chc","N", 1,0,0,"C","","","","","mv_par12","Contem","Contem","Contem", ,"Nao contem","Nao Contem","Nao Contem","","","","","","","","","","","")
xPutSx1( cPerg, "13", "Vendedor de ?"				    ,"","","mv_chd","C",06,0,0,"G","","SA3","","","mv_par13","","","","","","","","","","","","","","","","","","","","","","SA3","","","","")
xPutSx1( cPerg, "14", "Vendedor Até ?"				    ,"","","mv_che","C",06,0,0,"G","","SA3","","","mv_par14","","","","","","","","","","","","","","","","","","","","","","SA3","","","","")
xPutSx1( cPerg, "15", "Gerente de ?"				    ,"","","mv_chf","C",06,0,0,"G","","SA3","","","mv_par15","","","","","","","","","","","","","","","","","","","","","","SA3","","","","")
xPutSx1( cPerg, "16", "Gerente Até ?"				    ,"","","mv_chg","C",06,0,0,"G","","SA3","","","mv_par16","","","","","","","","","","","","","","","","","","","","","","SA3","","","","")

Return(.T.)

/*-------------------------\
| Cria Perguntas - xPutSx1 |
\-------------------------*/
Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
cF3, cGrpSxg,cPyme,;
cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
cDef02,cDefSpa2,cDefEng2,;
cDef03,cDefSpa3,cDefEng3,;
cDef04,cDefSpa4,cDefEng4,;
cDef05,cDefSpa5,cDefEng5,;
aHelpPor,aHelpEng,aHelpSpa,cHelp)

Local aArea := GetArea()
Local cKey
Local lPort := .f.
Local lSpa := .f.
Local lIngl := .f.

cKey	:= "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
cPyme	:= Iif( cPyme	== Nil, " ", cPyme)
cF3		:= Iif( cF3		== NIl, " ", cF3)
cGrpSxg	:= Iif( cGrpSxg	== Nil, " ", cGrpSxg)
cCnt01	:= Iif( cCnt01	== Nil, "" , cCnt01)
cHelp	:= Iif( cHelp	== Nil, "" , cHelp)

dbSelectArea( "SX1" )
dbSetOrder( 1 )
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

If !( DbSeek( cGrupo + cOrdem ))
	cPergunt	:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
	cPerSpa		:= If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
	cPerEng		:= If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
	
	Reclock( "SX1" , .T. )
	
	Replace X1_GRUPO	With cGrupo
	Replace X1_ORDEM	With cOrdem
	Replace X1_PERGUNT	With cPergunt
	Replace X1_PERSPA	With cPerSpa
	Replace X1_PERENG	With cPerEng
	Replace X1_VARIAVL	With cVar
	Replace X1_TIPO		With cTipo
	Replace X1_TAMANHO	With nTamanho
	Replace X1_DECIMAL	With nDecimal
	Replace X1_PRESEL	With nPresel
	Replace X1_GSC		With cGSC
	Replace X1_VALID	With cValid
	Replace X1_VAR01	With cVar01
	Replace X1_F3		With cF3
	Replace X1_GRPSXG	With cGrpSxg
	
	If Fieldpos("X1_PYME") > 0
		If cPyme != Nil
			Replace X1_PYME With cPyme
		Endif
	Endif
	
	Replace X1_CNT01   With cCnt01
	If cGSC == "C"               // Mult Escolha
		Replace X1_DEF01   With cDef01
		Replace X1_DEFSPA1 With cDefSpa1
		Replace X1_DEFENG1 With cDefEng1
		
		Replace X1_DEF02   With cDef02
		Replace X1_DEFSPA2 With cDefSpa2
		Replace X1_DEFENG2 With cDefEng2
		
		Replace X1_DEF03   With cDef03
		Replace X1_DEFSPA3 With cDefSpa3
		Replace X1_DEFENG3 With cDefEng3
		
		Replace X1_DEF04   With cDef04
		Replace X1_DEFSPA4 With cDefSpa4
		Replace X1_DEFENG4 With cDefEng4
		
		Replace X1_DEF05   With cDef05
		Replace X1_DEFSPA5 With cDefSpa5
		Replace X1_DEFENG5 With cDefEng5
	Endif
	
	Replace X1_HELP With cHelp
	
	PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	
	MsUnlock()
Else	
	lPort	:= ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
	lSpa	:= ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
	lIngl	:= ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
	
	If lPort .Or. lSpa .Or. lIngl
		RecLock("SX1",.F.)
		If lPort
			SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
		EndIf
		If lSpa
			SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
		EndIf
		If lIngl
			SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
		EndIf
		SX1->(MsUnLock())
	EndIf
Endif

RestArea( aArea )

Return
