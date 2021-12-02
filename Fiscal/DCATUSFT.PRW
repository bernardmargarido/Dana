#Include "rwmake.Ch"
#INCLUDE "PROTHEUS.CH"
#Include 'XMLXFUN.CH'
#Include 'TBICONN.CH'
#INCLUDE "TopConn.Ch"
#INCLUDE "Fileio.ch"
/*/
_________________________________________________________________________
+-----------------------------------------------------------------------+
Programa  � DCATUSFT � Autor � Clayton Martins   � Data �  06/03/2020 
+----------+------------------------------------------------------------
Descrição � Atualização itens Livro Fiscal.          
+----------+------------------------------------------------------------
Uso       � DANA COSMÉTICOS						                      
+-----------------------------------------------------------------------+
/*/
User Function DCATUSFT

Local cLinha 	:= ""
Local _cDados	:= {}
Local Nx		:= 1

Private nTotReg	:= 0
Private cDir    := "SERVIDOR\" //colocar fun��o para retornar Drive
Private clArqx  := cGetFile ('*.CSV|*.CSV','Atualiza Dados Livros Fiscais - SFT',1,cDir ,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY,.T., .T.)

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
	If Substr(Alltrim(UPPER(aLinha[1])),1,9) == "FT_FILIAL" //Cabe�alho do arquivo
		FT_FSKIP(1)
		Loop
	Endif

	aAdd(_cDados,{aLinha[1],;//FT_FILIAL
	aLinha[2],;//FT_ENTRADA
	PADR(aLinha[3],9),;//FT_NFISCAL
	PADR(aLinha[4],3),;//FT_SERIE
	PADR(aLinha[5],6),;//FT_CLIEFOR
	PADR(aLinha[6],2),;//FT_LOJA
	aLinha[7],;//FT_CFOP
	PADR(aLinha[8],15),;//FT_PRODUTO
	aLinha[9],;//FT_VALCONT
	aLinha[10],;//FT_OBSERV
	aLinha[11],;//FT_TIPOMOV
	PADR(aLinha[12],4),;//FT_ITEM  //STRZERO(VAL(aLinha[12]),4),;//FT_ITEM
	StrTran(aLinha[13],",","."),;//FT_BASEPIS
	StrTran(aLinha[14],",","."),;//FT_ALIQPIS
	StrTran(aLinha[15],",","."),;//FT_VALPIS
	StrTran(aLinha[16],",","."),;//FT_BASECOF
	StrTran(aLinha[17],",","."),;//FT_ALIQCOF
	StrTran(aLinha[18],",","."),;//FT_VALCOF
	aLinha[19],;//FT_CSTPIS
	aLinha[20]})//FT_CSTCOF

	ProcessMessages()
	FT_FSKIP(1)
Enddo

FT_FUSE()//Fecha Arquivo.

For Nx := 1 to Len(_cDados)
	DbSelectArea("SFT")
	DbSetOrder(1)//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
	If DBseek(_cDados[Nx][1] + _cDados[Nx][11] + _cDados[Nx][4] + _cDados[Nx][3] + _cDados[Nx][5] + _cDados[Nx][6] + _cDados[Nx][12] + _cDados[Nx][8])
		RecLock("SFT",.F.)
		SFT->FT_BASEPIS		:= Val(_cDados[Nx][13])
		SFT->FT_ALIQPIS		:= Val(_cDados[Nx][14])
		SFT->FT_VALPIS		:= Val(_cDados[Nx][15])
		SFT->FT_BASECOF		:= Val(_cDados[Nx][16])
		SFT->FT_ALIQCOF		:= Val(_cDados[Nx][17])
		SFT->FT_VALCOF		:= Val(_cDados[Nx][18])
		SFT->FT_CSTPIS		:= _cDados[Nx][19]
		SFT->FT_CSTCOF		:= _cDados[Nx][20]
		SFT->(MsUnlock())
		nTotReg	+= 1
	Endif
Next

nTotReg	:= cValTochar(nTotReg)

Msginfo("Manutencao finalizada com sucesso. Total de registros atualizados: "+ nTotReg,"DCATUSFT")

Return()
