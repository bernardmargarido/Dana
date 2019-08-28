#INCLUDE "RWMAKE.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"

User Function JOBM330()

Local lCPParte 	:= .F. //-- Define que n�o ser� processado o custo em partes
Local lBat 		:= .T. //-- Define que a rotina ser� executada em Batch
Local aListaFil := {} //-- Carrega Lista com as Filiais a serem processadas
Local cCodFil 	:= '' //-- C�digo da Filial a ser processada
Local cNomFil 	:= '' //-- Nome da Filial a ser processada
Local cCGC 		:= '' //-- CGC da filial a ser processada
Local aParAuto 	:= {} //-- Carrega a lista com os 21 par�metros

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" M�DULO "EST" TABLES "AF9","SB1","SB2","SB3","SB8","SB9","SBD","SBF","SBJ","SBK","SC2","SC5","SC6","SD1","SD2","SD3","SD4","SD5","SD8","SDB","SDC","SF1","SF2","SF4","SF5","SG1","SI1","SI2","SI3","SI5","SI6","SI7","SM2","ZAX","SAH","SM0","STL"
Conout("In�cio da execu��o do JOBM330")
//-- Adiciona filial a ser processada
DbSelectArea("SM0")
DbSeek(cEmpAnt)
Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
	cCodFil := SM0->M0_CODFIL
	cNomFil := SM0->M0_FILIAL
	cCGC := SM0->M0_CGC
	If cCodFil == "05"//Vinhedo
		//-- Adiciona a filial na lista de filiais a serem processadas
		Aadd(aListaFil,{.T.,cCodFil,cNomFil,cCGC,.F.,})
	EndIf
	dbSkip()
EndDo
//-- Executa a rotina de rec�lculo do custo m�dio
MATA330(lBat,aListaFil,lCPParte, aParAuto)
ConOut("T�rmino da execu��o do JOBM330")

Return
