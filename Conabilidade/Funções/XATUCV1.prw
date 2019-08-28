#INCLUDE "PROTHEUS.CH"
#Include 'XMLXFUN.CH'
#Include 'TBICONN.CH'
#INCLUDE "TopConn.Ch"
#INCLUDE "Fileio.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XATUCV1   ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 10/05/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importa arquivo .CSV Orçamento contábil 2018.              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function XATUCV1

Local cLinha 	:= ""
Local _cDados	:= {}
Local nValJan	:= 0
Local nValFev	:= 0
Local nValMar	:= 0
Local nValAbr	:= 0
Local nValMai	:= 0
Local nValJun	:= 0
Local nValJul	:= 0
Local nValAgo	:= 0
Local nValSet	:= 0
Local nValOut	:= 0
Local nValNov	:= 0
Local nValDez	:= 0
Local cCV1Seq	:= "0001"
Local cDir		:= "SERVIDOR\" //colocar função para retornar Drive
Local clArqx	:= cGetFile ('*.CSV|*.CSV','Importa Orçamento contábil na tabela CV1',1,cDir ,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY,.T., .T.)

If Empty(clArqx)
	Return
Endif

FT_FUSE(clArqx)
FT_FGOTOP()
cLinha := FT_FREADLN()

While (!FT_FEOF())
	cLinha := " "
	cLinha := FT_FREADLN()
	aLinha := {}
	aLinha := Separa(cLinha,";")
	If Substr(Alltrim(UPPER(aLinha[1])),1,5) == "CONTA" //Cabeçalho do arquivo
		FT_FSKIP(1)
		Loop
	Endif
	aAdd(_cDados,{aLinha[1],;//CONTA
	aLinha[2],;//DESC. CONTA
	aLinha[3],;//VAL JAN
	aLinha[4],;//VAL FEV
	aLinha[5],;//VAL MAR
	aLinha[6],;//VAL ABR
	aLinha[7],;//VAL MAI
	aLinha[8],;//VAL JUN
	aLinha[9],;//VAL JUL
	aLinha[10],;//VAL AGO
	aLinha[11],;//VAL SET
	aLinha[12],;//VAL OUT
	aLinha[13],;//VAL NOV
	aLinha[14]})//VAL DEZ
	ProcessMessages()
	FT_FSKIP(1)
Enddo

FT_FUSE()//Fecha Arquivo.

For Nx := 1 to Len(_cDados)	
	DbSelectArea("CV1")
	DbSetOrder(1)//CV1_FILIAL+CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA+CV1_SEQUEN+CV1_PERIOD
	
	nValJan	:= StrTran(_cDados[Nx][3],".","")
	nValJan	:= StrTran(nValJan,",",".")
	nValFev	:= StrTran(_cDados[Nx][4],".","")
	nValFev	:= StrTran(nValFev,",",".")
	nValMar	:= StrTran(_cDados[Nx][5],".","")
	nValMar	:= StrTran(nValMar,",",".")
	nValAbr	:= StrTran(_cDados[Nx][6],".","")
	nValAbr	:= StrTran(nValAbr,",",".")
	nValMai	:= StrTran(_cDados[Nx][7],".","")
	nValMai	:= StrTran(nValMai,",",".")
	nValJun	:= StrTran(_cDados[Nx][8],".","")
	nValJun	:= StrTran(nValJun,",",".")
	nValJul	:= StrTran(_cDados[Nx][9],".","")
	nValJul	:= StrTran(nValJul,",",".")
	nValAgo	:= StrTran(_cDados[Nx][10],".","")
	nValAgo	:= StrTran(nValAgo,",",".")
	nValSet	:= StrTran(_cDados[Nx][11],".","")
	nValSet	:= StrTran(nValSet,",",".")
	nValOut	:= StrTran(_cDados[Nx][12],".","")
	nValOut	:= StrTran(nValOut,",",".")
	nValNov	:= StrTran(_cDados[Nx][13],".","")
	nValNov	:= StrTran(nValNov,",",".")
	nValDez	:= StrTran(_cDados[Nx][14],".","")
	nValDez	:= StrTran(nValDez,",",".")

	//Janeiro
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "01"
	CV1->CV1_DTINI	:= CTOD("01/01/2018")
	CV1->CV1_DTFIM	:= CTOD("31/01/2018")
	CV1->CV1_VALOR	:= Val(nValJan)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())

	//Fevereiro
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "02"
	CV1->CV1_DTINI	:= CTOD("01/02/2018")
	CV1->CV1_DTFIM	:= CTOD("28/02/2018")
	CV1->CV1_VALOR	:= Val(nValFev)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())

	//Março
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "03"
	CV1->CV1_DTINI	:= CTOD("01/03/2018")
	CV1->CV1_DTFIM	:= CTOD("31/03/2018")
	CV1->CV1_VALOR	:= Val(nValMar)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())	
	
	//Abril
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "04"
	CV1->CV1_DTINI	:= CTOD("01/04/2018")
	CV1->CV1_DTFIM	:= CTOD("30/04/2018")
	CV1->CV1_VALOR	:= Val(nValAbr)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())	
	
	//Maio
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "05"
	CV1->CV1_DTINI	:= CTOD("01/05/2018")
	CV1->CV1_DTFIM	:= CTOD("31/05/2018")
	CV1->CV1_VALOR	:= Val(nValMai)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())	
	
	//Junho
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "06"
	CV1->CV1_DTINI	:= CTOD("01/06/2018")
	CV1->CV1_DTFIM	:= CTOD("30/06/2018")
	CV1->CV1_VALOR	:= Val(nValJun)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())
	
	//Julho
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "07"
	CV1->CV1_DTINI	:= CTOD("01/07/2018")
	CV1->CV1_DTFIM	:= CTOD("31/07/2018")
	CV1->CV1_VALOR	:= Val(nValJul)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())

	//Agosto
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "08"
	CV1->CV1_DTINI	:= CTOD("01/08/2018")
	CV1->CV1_DTFIM	:= CTOD("31/08/2018")
	CV1->CV1_VALOR	:= Val(nValAgo)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())	

	//Setembro
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "09"
	CV1->CV1_DTINI	:= CTOD("01/09/2018")
	CV1->CV1_DTFIM	:= CTOD("30/09/2018")
	CV1->CV1_VALOR	:= Val(nValSet)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())	

	//Outubro
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "10"
	CV1->CV1_DTINI	:= CTOD("01/10/2018")
	CV1->CV1_DTFIM	:= CTOD("31/10/2018")
	CV1->CV1_VALOR	:= Val(nValOut)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())	
	
	//Novembro
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "11"
	CV1->CV1_DTINI	:= CTOD("01/11/2018")
	CV1->CV1_DTFIM	:= CTOD("30/11/2018")
	CV1->CV1_VALOR	:= Val(nValNov)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())	
	
	//Dezembro
	RecLock("CV1",.T.)
	CV1->CV1_FILIAL	:= xFilial("CV1")
	CV1->CV1_ORCMTO	:= "2018"
	CV1->CV1_DESCRI	:= "ORCAMENTO CONTAS 2018"
	CV1->CV1_STATUS	:= "1"
	CV1->CV1_CALEND	:= "018"
	CV1->CV1_MOEDA	:= "01"
	CV1->CV1_REVISA	:= "001"
	CV1->CV1_SEQUEN	:= cCV1Seq
	CV1->CV1_CT1INI	:= _cDados[Nx][1]//Conta
	CV1->CV1_CT1FIM	:= _cDados[Nx][1]
	CV1->CV1_CTTINI	:= ""
	CV1->CV1_CTTFIM	:= ""
	CV1->CV1_CTDINI	:= ""
	CV1->CV1_CTDFIM	:= ""
	CV1->CV1_CTHINI	:= ""
	CV1->CV1_CTHFIM	:= ""
	CV1->CV1_PERIOD	:= "12"
	CV1->CV1_DTINI	:= CTOD("01/12/2018")
	CV1->CV1_DTFIM	:= CTOD("31/12/2018")
	CV1->CV1_VALOR	:= Val(nValDez)
	CV1->CV1_APROVA	:= "alberto.filizzola"
	CV1->(MsUnLock())
	
	cCV1Seq	:=Soma1(cCV1Seq)
Next

Msginfo("Importação finalizada com sucesso!!!","XATUCV1")

Return()
