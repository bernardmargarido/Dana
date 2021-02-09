#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPINV    ºAutor  ³Clayton Martins     º Data ³  10/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição.³ Importa um arquivo .CSV para a tabela SB7 - Lançamento de  º±±
±±º          ³ Inventário.												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Orthoneuro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/* ORDEM PADRÃO PARA COLUNAS DO ARQUIVO .CSV
|----------------------------------------------------------------------------------------------------------------------------|
|    1   |    2    |      3     |   4   |  5   |       6         |     7     |       8        |    9     |        10         |
| -------|---------|------------|-------|------|-----------------|-----------|----------------|----------|-------------------|
| FILIAL | PRODUTO | QUANTIDADE | LOCAL | LOTE | DATA INVENTARIO | DOCUMENTO | DATA DE VALID. | CONTAGEM | MOTIVO INVENTÁRIO |
| ---------------------------------------------------------------------------------------------------------------------------|
*/

User Function IMPINV()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaração das variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local oDlg                       

Private cArquivo
Private cPathImp

//+-----------------------------------+
//| Montagem da tela de processamento.|
//+-----------------------------------+

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Importa Lançamento de Inventário") ;
FROM 000,000 TO 200,400 PIXEL

@ 005,005 TO 095,195 OF oDlg PIXEL
@ 010,020 Say " Este programa ira importa um aquivo CSV , para gravar  " OF oDlg PIXEL
@ 018,020 Say " dados na tabela de Lançamento de Inventário.		   " OF oDlg PIXEL


TGet():New(40,008,bSetGet(cArquivo),oDlg,100,010,,,,,,,,.T.,,,,,,,.T.)
TBtnBmp2():New(80,213,026,026,"SDUOPEN",,,,{|| cArquivo := getDirFile()},oDlg,"Seleciona diretório")

DEFINE SBUTTON FROM 070, 030 TYPE 1 ;
ACTION ( Iif(Empty(cArquivo),Alert("Informe o diretório !"),(IMPORTAR(cArquivo),oDlg:End()) ) ) ENABLE OF oDlg

DEFINE SBUTTON FROM 070, 070 TYPE 2 ;
ACTION (oDlg:End()) ENABLE OF oDlg

ACTIVATE DIALOG oDlg CENTERED

Return Nil

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |getDirFileºAutor  ³ Clayton Martins    º Data ³  10/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Localizar o arquivo especifico a ser aberto.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Orthoneuro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function getDirFile()
Local cPath
Local cTipoArq		:= "*.CSV"
Local cDir 			:= ""
Local cArquivo

cPath := cGetFile('*.CSV',"Selecione o diretório do aquivo",1,cDir,.F.)//,nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY),.T.,.T.)

cDir := Iif(Empty(cPath), cDir, cPath)

cPathImp := SubStr(cDir,1,RAT("\",cDir))

Return cDir

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PROSIMPO  ºAutor  ³                    º Data ³  10/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Orthoneuro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static Function IMPORTAR(cArquivo)
Begin Transaction
Processa({|| fIncSCT(cArquivo)}, "Aguarde incluindo registros na base de dados ...")
End Transaction
Return()


Static Function fIncSCT(cArquivo)
Local cVend		:= ""
Local dDatam	:= Ctod("  /  /    ")
Local cProd		:= ""
Local nQuant	:= ""
Local nValor	:= ""
Local cContag	:= ""
Local cRastro	:= ""
Local dDtValid  := CTOD("  /  /    ")
Local lFilial	:= .F.
Local aFiliais	:= {}
Local nX        := 0
Local aArea := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSB8 := SB8->(GetArea())
Local aAreaSB7 := SB7->(GetArea())

Private _lRet 	:= .F.

If !Empty(xFilial("SB7"))
	lFilial	:= .T.
EndIf

// *** ABRIR ARQUIVO DE TEXTO. cArq É O PATH COMPLETO DO ARQ.
If !FILE(AllTrim(cArquivo))
	MsgBox("Arquivo informado nao foi encontrado, Verifique diretorio ou nome do arquivo")
	Return()
EndIf

If (nHa := FT_FUse(AllTrim(cArquivo)))== -1
	MsgBox("Arquivo vazio!!")
	Return()
EndIf

FT_FGOTOP()
nTotReg := FT_FLastRec() //ProcRegua( FT_FLastRec() )    // *** FT_FLastRec() RETORNA A ULTIMA LINHA DO ARQ
FT_FGOTOP()
ProcRegua(nTotReg)

cSeq := "000"
nReg := 1

While !FT_FEOF()
	
	cLinha := FT_FReadLn()
	aDados := Separa(cLinha,";")
	
	If UPPER(Alltrim(aDados[01])) == "FILIAL"
		FT_FSkip()
		Loop
	Endif
	
	cFilTrat := Alltrim( aDados[01])
	cFilTrat := StrTran(cFilTrat,"'","")
	cFilTrat := StrZero(Val(cFilTrat),2)
	
	IncProc( "Regis	tro: " + StrZero(nReg,5) + " # Total: " + StrZero(nTotReg,5) )	
	
	If Alltrim(SM0->M0_CODFIL) == Alltrim(cFilTrat)
		
		cCod := Padr( aDados[02],15)
		cCod := StrTran(cCod,"'","")
		
		nQuant := Alltrim( aDados[03])
		nQuant := StrTran(nQuant,".", ",")		
		nQuant := Val(nQuant)		
		
		cLocal := Alltrim( aDados[04])
		cLocal := StrTran(cLocal,"'","")		

		cLote  := Padr( aDados[05],10)
		cLote  := StrTran(cLote,"'","")		
		
		dData  := Alltrim( aDados[06])
		dData  := StrTran(dData,"'","")
		dData  := CTOD(dData)
						                    
		cDoc   := Padr( aDados[07],9)
		cDoc   := StrTran(cDoc,"'","")		

		cContag  := Padr( aDados[08],3)
		cContag  := StrTran(cContag,"'","")								
								
		cMotiv   := Alltrim( aDados[09])
		cMotiv   := StrTran(cMotiv,"'","")		
        
		//Verifica se Produto Existe no cadastro de produtos.
	    DBSelectArea("SB1")
   		DBSetOrder(1) //B1_COD + B1_DESC
    	IF !DBSeek(xFilial("SB1") + cCod)
    		MSGALERT("O Produto " + Alltrim(cCod) + " não foi localizado.")
       		FT_FSkip()
       		Loop
    	Endif     	

		//Verifica se utiliza controle de Lote
		cRastro:= POSICIONE("SB1",1,xFilial("SB1") + cCod,"B1_RASTRO")
        IF cRastro == "L"        
	        //Analise se Lote é Válido na Tabela de Saldos Por Lote.
		    DBSelectArea("SB8")
	   		DBSetOrder(3) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	    	IF !DBSeek(xFilial("SB8")+cCod+cLocal+cLote)
	    		MSGALERT("O Lote " + Alltrim(cLote) + " do Produto " + Alltrim(cCod) + "não foi localizado na tabela de Saldos por Lote.")
	       		FT_FSkip()
	       		Loop
	    	Endif     	
			dDtValid:= POSICIONE("SB8",3,xFilial("SB8")+cCod+cLocal+cLote,"B8_DTVALID")
			//Verifica se Já Existe o Número de Documento no sistema.
			DbSelectArea("SB7")
			//DbOrderNickName("XNUMDOCINV")
			dbSetOrder(3)
	    	IF DBSeek(xFilial("SB7") + cDoc + cCod + cLocal )
	    		MSGALERT("Esse Documento " + cDoc + " já existe no sistema, ajuste o numero do Documento para realizar a importação novamente.")
	    		FClose(nHa)
	    		Return()
			Endif    		    			
					
			If RecLock("SB7",.T.)
				SB7->B7_FILIAL	:= xFilial("SB7")
				SB7->B7_COD		:= cCod
				SB7->B7_QUANT   := nQuant
				SB7->B7_TIPO    := POSICIONE("SB1",1,xFilial("SB1") + cCod,"B1_TIPO")
				SB7->B7_LOCAL   := cLocal
				SB7->B7_LOTECTL := cLote
				SB7->B7_DATA    := dData			
				SB7->B7_DOC     := cDoc
				SB7->B7_DTVALID := dDtValid
				SB7->B7_CONTAGE := cContag
				//SB7->B7_MOTINVE := cMotiv
				MsUnlock()
			EndIf
		Else	
			//Verifica se Já Existe o Número de Documento no sistema.
			DbSelectArea("SB7")
			//DbOrderNickName("XNUMDOCINV")
			dbSetOrder(3)
	    	IF DBSeek(xFilial("SB7") + cDoc + cCod + cLocal )
	    		MSGALERT("Esse Documento " + cDoc + " já existe no sistema, ajuste o numero do Documento para realizar a importação novamente.")
	    		FClose(nHa)
	    		Return()
			Endif    		    			
			dDtValid  := CTOD("  /  /    ")							
			If RecLock("SB7",.T.)
				SB7->B7_FILIAL	:= xFilial("SB7")
				SB7->B7_COD		:= cCod
				SB7->B7_QUANT   := nQuant
				SB7->B7_TIPO    := POSICIONE("SB1",1,xFilial("SB1") + cCod,"B1_TIPO")
				SB7->B7_LOCAL   := cLocal
				SB7->B7_LOTECTL := cLote
				SB7->B7_DATA    := dData			
				SB7->B7_DOC     := cDoc
				SB7->B7_DTVALID := dDtValid
				SB7->B7_CONTAGE := cContag
				//SB7->B7_MOTINVE := cMotiv
				MsUnlock()
			EndIf
		Endif			
	EndIf
	
	nReg++
	FT_FSkip()
Enddo

RestArea(AareaSB1)
RestArea(AareaSB8)
RestArea(AareaSB7)

FClose(nHa)

Return()