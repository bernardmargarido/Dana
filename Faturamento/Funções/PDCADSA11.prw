#INCLUDE "PROTHEUS.CH"
#Include 'XMLXFUN.CH'
#Include 'TBICONN.CH'
#INCLUDE "TopConn.Ch"
#INCLUDE "Fileio.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PDCADSA11 ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 10/05/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importa arquivo .CSV para ajustar o cadastro d clientes.   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PDCADSA11

Local cLinha 	:= ""
Local _cDados	:= {}
Local nTamCli	:= 0
Local cCodCli	:= ""
Local nTamLoj	:= 0
Local cLojCli	:= ""
Local nValLim	:= ""

Private cDir    := "SERVIDOR\" //colocar função para retornar Drive
Private clArqx  := cGetFile ('*.CSV|*.CSV','Ajusta campos no cadstro de cliente',1,cDir ,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY,.T., .T.)

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
	If Substr(Alltrim(aLinha[1]),1,6) == "A1_COD" //Cabeçalho do arquivo
		FT_FSKIP(1)
		Loop
	Endif
	

	aAdd(_cDados,{aLinha[1],;//A1_COD
	aLinha[2],;//A1_LOJA
	aLinha[3],;//A1_XCOMER
	aLinha[4],;//A1_DDD
	aLinha[5],;//A1_TEL
	aLinha[6],;//A1_EMAIL
	aLinha[7],;//A1_XCONFIN
	aLinha[8],;//A1_XTELFIN
	aLinha[9],;//A1_XEMAILF
	aLinha[10],;//A1_XEMAILL
	aLinha[11],;//A1_XCONLOG
	aLinha[12],;//A1_HORECE
	aLinha[13],;//A1_XMSGDTR
	aLinha[14],;//A1_XPALETI
	aLinha[15]})//A1_XAGENDA

	ProcessMessages()
	FT_FSKIP(1)
Enddo

FT_FUSE()//Fecha Arquivo.

For Nx := 1 to Len(_cDados)
	DbSelectArea("SA1")
	DbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA
	nTamCli	:= Len(_cDados[Nx][1])
	nTamCli	:= 6 - nTamCli
	If nTamCli > 0
		cCodCli	:= _cDados[Nx][1] + Space(nTamCli)
	Else
		cCodCli	:= _cDados[Nx][1]
	Endif
	
	nTamLoj	:= Len(_cDados[Nx][2])
	nTamLoj	:= 2 - nTamLoj
	If nTamLoj > 0
		cLojCli	:= _cDados[Nx][2] + Space(nTamLoj)
	Else
		cLojCli	:= _cDados[Nx][2]
	Endif
	nValLim	:= Strtran(_cDados[Nx][3],".","")
	nValLim	:= Strtran(nValLim,",",".")
	nValLim	:= Val(nValLim)
	
	If DbSeek(xFilial("SA1") + cCodCli + cLojCli)
		RecLock("SA1",.F.)
		SA1->A1_XECOMER	:= _cDados[Nx][3]
		SA1->A1_DDD		:= _cDados[Nx][4]
		SA1->A1_TEL		:= _cDados[Nx][5]
		SA1->A1_EMAIL	:= _cDados[Nx][6]
		SA1->A1_XCONFIN	:= _cDados[Nx][7]
		SA1->A1_XTELFIN	:= _cDados[Nx][8]
		SA1->A1_XEMAILF	:= _cDados[Nx][9]
		SA1->A1_XEMAILL	:= _cDados[Nx][10]
		SA1->A1_XCONLOG	:= _cDados[Nx][11]
		SA1->A1_XHORECE	:= _cDados[Nx][12]
		SA1->A1_XMSGDTR	:= _cDados[Nx][13]
		SA1->A1_XPALETI	:= _cDados[Nx][14]
		SA1->A1_XAGENDA	:= _cDados[Nx][15]
		SA1->(MsUnlock())
	Endif
Next

Msginfo("Manutenção finalizada com sucesso!!!","PDCADSA11")

Return()
