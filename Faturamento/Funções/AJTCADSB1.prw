#INCLUDE "PROTHEUS.CH"
#Include 'XMLXFUN.CH'
#Include 'TBICONN.CH'
#INCLUDE "TopConn.Ch"
#INCLUDE "Fileio.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AJTCADSB1 ¦ Autor ¦ Clayton Martins   ¦ Data ¦ 01/10/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importa arquivo .CSV para ajustar de Produtos.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function AJTCADSB1

Local cLinha 	:= ""
Local _cDados	:= {}

Private cDir    := "SERVIDOR\" //colocar função para retornar Drive
Private clArqx  := cGetFile ('*.CSV|*.CSV','Ajusta campos no cadstro de Produtos',1,cDir ,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY,.T., .T.)

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
	If Substr(Alltrim(aLinha[1]),1,3) == "COD" //Cabeçalho do arquivo
		FT_FSKIP(1)
		Loop
	Endif
	
	aAdd(_cDados,{aLinha[1],;//B1_COD
	aLinha[2],;//B1_XMARCA
	aLinha[3],;//B1_XCATEGO
	aLinha[4]})//B1_XAPLICA
	
	ProcessMessages()
	FT_FSKIP(1)
Enddo

FT_FUSE()//Fecha Arquivo.

For Nx := 1 to Len(_cDados)
	DbSelectArea("SB1")
	DbSetOrder(1)//B1_FILIAL+B1_COD
	If DbSeek("05"+ _cDados[Nx][1])
		RecLock("SB1",.F.)
		SB1->B1_XMARCA	:= _cDados[Nx][2]
		SB1->B1_XCATEGO	:= _cDados[Nx][3]
		SB1->B1_XAPLICA	:= _cDados[Nx][4]
		SB1->(MsUnlock())		
	Endif
Next

Msginfo("Manutenção finalizada com sucesso!!!","AJTCADSB1")

Return()
