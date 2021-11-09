#Include "rwmake.Ch"
#INCLUDE "PROTHEUS.CH"
#Include 'XMLXFUN.CH'
#Include 'TBICONN.CH'
#INCLUDE "TopConn.Ch"
#INCLUDE "Fileio.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XBLQCLIFT ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 31/07/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Bloqueia Clientes que não compram a mais de um ano.        ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function XBLQCLIFT

Local cLinha 	:= ""
Local _cDados	:= {}
Local nTamCli	:= 0
Local Nx		:= 0
Local cCodCli	:= ""
Local nTamLoj	:= 0
Local cLojCli	:= ""
Local cQuery	:= ""
Local dDataBlq	:= dDataBase - 365
Local dEmissao	:= ""

Private cDir    := "SERVIDOR\" //colocar função para retornar Drive
Private clArqx  := cGetFile ('*.CSV|*.CSV','Bloqueia clientes que não compram a mais de um ano',1,cDir ,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY,.T., .T.)

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
	If Substr(Alltrim(UPPER(aLinha[1])),1,6) == "A1_COD" //Cabeçalho do arquivo
		FT_FSKIP(1)
		Loop
	Endif
	
	aAdd(_cDados,{aLinha[1],;//A1_COD
	aLinha[2]})//A1_LOJA

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
	
	If DbSeek(xFilial("SA1") + cCodCli + cLojCli)
		
		If Select("TRBSA1") > 0
			TRBSA1->(DbCloseArea())
		Endif
		cQuery	:= " SELECT MAX(F2_EMISSAO) AS MAXEMI FROM "+RetSqlname("SF2")+" AS SF2 (NOLOCK) "
		cQuery	+= " WHERE F2_CLIENTE = '"+cCodCli+"'
		cQuery	+= " AND F2_LOJA = '"+cLojCli+"'
		cQuery	+= " AND F2_TIPO = 'N' "
		cQuery	+= " AND D_E_L_E_T_ = '' "
		PLSQUERY(cQuery,"TRBSA1")

		If Select("TRBSA1") > 0
			dEmissao	:= TRBSA1->MAXEMI
			TRBSA1->(DbCloseArea())
		Else
			TRBSA1->(DbCloseArea())
		Endif
		
		dEmissao	:= sTod(dEmissao)
		
		If dEmissao < dDataBlq
		RecLock("SA1",.F.)
		SA1->A1_ATIVO	:=  "N"
		SA1->A1_MSBLQL	:=  "1"
		SA1->A1_XBLQFIN	:=  "1"
		SA1->A1_XBLQFIS	:=  "1"
		SA1->(MsUnlock())
		Endif
	Endif
Next

Msginfo("Manutenção finalizada com sucesso!!!","XBLQCLIFT")

Return()
