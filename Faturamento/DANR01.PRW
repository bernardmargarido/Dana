#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ DANR01   บ Autor ณ Caroline Cazela    บ Data ณ 23/07/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressใo de relat๓rio de romaneio do pedido de venda      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Dana Perfumes                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function DANR01()

Processa({||U_DAR001() }, "Aguarde! Imprimindo PickList...")

Return( Nil )


User Function DAR001()

Local cPerg 		:= 'PIC01'

Private cPedido		:= ""
Private nLinha     	:= 0
Private nValBrut	:= 0
Private nMsgNota	:= ""
Private oFont16N,oFont16,oFont14N,oFont12N,oFont10N,oFont14,oFont12,oFont10,oFont08N
Private _limpr	 	:= .T.
Private cBitmap	 	:= "\system\LGMID.png"
Private oFontTit	:= oFont08N
Private nFol		:= 0
Private _cAlias 	:= GetNextAlias()
Private nContPag	:= 0
Private nQtdPag		:= 0

oFont16N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oFont16 	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
oFont14N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
oFont14 	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
oFont12		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
oFont12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont08N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
oFont06N	:= TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
oFont05		:= TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)

_nColIni := 0050
_nColFin := 0500

AjustaSx1(cPerg)
If !Pergunte(cPerg, .T.)
	Return
Endif

If !ExistDir("C:\temp\")
	MontaDir("C:\temp\")
EndIf

_cArquivo	:= "PickList_" + StrTran(Time(),":","") + ".pdf"
Ferase("C:\temp\"+_cArquivo)

oPrint := FwMSPrinter():New(_cArquivo,6,.F.,,.T.)
oPrint:SetResolution(72)			// Default
oPrint:SetLandscape() 				// SetLandscape() ou SetPortrait()
oPrint:SetPaperSize(9)				// A4 210mm x 297mm  620 x 876
oPrint:SetMargin(10,10,10,10)		// < nLeft>, < nTop>, < nRight>, < nBottom>
oPrint:cPathPDF:= "C:\temp\"
oPrint:SetViewPdf(_limpr)
oPrint:StartPage()   				// Inicia uma nova pแgina
oBrush  := TBrush():New(,(0,0,0))
oBrush2 := TBrush():New(,CLR_GRAY) // Pinta a linha de cinza

DbSelectArea("SF2") //Posiciona na tabela de notas fiscais
DbSetOrder(1)
DbSeek(xFilial("SF2") + SF2->F2_DOC + SF2->F2_SERIE )
//DbSeek(xFilial("SF2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA )
If 	Select("TMP") > 0
	TMP->( DbCloseArea())
EndIf

//Query de dados do relat๓rio
_cQuery	:= " SELECT "
_cQuery	+= "       F2_DOC AS DOC, "
_cQuery	+= "       F2_SERIE AS SERIE, "
_cQuery	+= "       F2_CLIENTE AS F2COD, "
_cQuery	+= "       F2_LOJA AS F2LOJA, "
_cQuery	+= "       F2_VALBRUT AS VALBRUT, "
_cQuery	+= "       F2_PBRUTO AS PESOBRUT, "
_cQuery	+= "       F2_TRANSP AS TRANSP, "
_cQuery	+= "       F2_EMISSAO AS DTEMISS, "
_cQuery	+= "       F2_XNUMECO AS ECOMMERCE, "
_cQuery	+= "       D2_COD AS D2PRD, "
_cQuery	+= "       D2_QUANT AS QUANT, "
_cQuery	+= "       D2_PEDIDO AS PEDIDO, "
_cQuery	+= "       D2_ITEMPV AS ITEMPV, "
_cQuery	+= "       A1_COD AS CODCLI, "
_cQuery	+= "       A1_LOJA AS LOJA, "
_cQuery	+= "       A1_NOME AS NOMCLI, "
_cQuery	+= "       A1_MUN AS MUN, "
_cQuery	+= "       A1_EST AS EST, "
_cQuery	+= "       A4_COD AS CODTR, "
_cQuery	+= "       A4_NOME AS NOMETR, "
_cQuery	+= "       B1_COD AS CODPRD, "
_cQuery	+= "       B1_DESC AS DESCPRD,  "
_cQuery	+= "       B1_QTDPCXA AS QTDPCXA  "
_cQuery	+= " FROM "
_cQuery +=      RetSqlName( "SF2" ) + " SF2 "
_cQuery	+= " INNER JOIN "
_cQuery +=      RetSqlName( "SD2" ) + " SD2 "
_cQuery += " ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA "
_cQuery	+= " INNER JOIN "
_cQuery +=      RetSqlName( "SB1" ) + " SB1 "
_cQuery += " ON SB1.B1_COD = SD2.D2_COD "
_cQuery	+= " INNER JOIN "
_cQuery +=      RetSqlName( "SA1" ) + " SA1 "
_cQuery += " ON SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA "
_cQuery	+= " INNER JOIN "
_cQuery +=      RetSqlName( "SA4" ) + " SA4 "
_cQuery += " ON SA4.A4_COD = SF2.F2_TRANSP "
_cQuery	+= " WHERE "
_cQuery	+= "    SD2.D2_DOC BETWEEN '" + ALLTRIM(MV_PAR01) + "' AND '" + ALLTRIM(MV_PAR02) + "' AND "
_cQuery	+= "    SD2.D2_SERIE    = '" + ALLTRIM(MV_PAR03) + "' AND "
_cQuery	+= "    SD2.D2_PEDIDO BETWEEN '" + ALLTRIM(MV_PAR04) + "' AND '" + ALLTRIM(MV_PAR05) + "' AND "
_cQuery	+= "    SF2.F2_FILIAL      = '" + xFilial( "SF2" ) + "' AND "
_cQuery	+= "    SD2.D2_FILIAL      = '" + xFilial( "SD2" ) + "' AND "
_cQuery	+= "    SA1.A1_FILIAL      = '" + xFilial( "SA1" ) + "' AND "
_cQuery	+= "    SA4.A4_FILIAL      = '" + xFilial( "SA4" ) + "' AND "
_cQuery	+= "    SB1.B1_FILIAL      = '" + xFilial( "SB1" ) + "' AND "
_cQuery	+= "    SF2.D_E_L_E_T_	   = '' AND "
_cQuery	+= "    SD2.D_E_L_E_T_     = '' AND "
_cQuery	+= "    SA1.D_E_L_E_T_     = '' AND "
_cQuery	+= "    SB1.D_E_L_E_T_     = '' AND "
_cQuery	+= "    SA4.D_E_L_E_T_     = '' "
_cQuery	+= " ORDER BY "
_cQuery += "   SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SB1.B1_COD "
_cQuery	:= changeQuery(_cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry(,,_cQuery), _cAlias, .F., .F. )

CABECA() //Cabecalho
ITENS()  //ITENS
RODAPE() //RODAPE

If nLinha > 570  //Quebra de pแgina quando encher a primeira e quando mudar o n๚mero da nota e pedido
	oPrint:EndPage()
	oPrint:StartPage()
	CABECA()
Endif
oPrint:Preview()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ Cabeca          บAutorณ Caroline Cazela            บ Data ณ 23/07/2018 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Imprime cabecalho do Relatorio                                         บฑฑ
ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CABECA()	// Montagem do Cabe็alho Retrato

nFol:= nFol+1

If nContPag == 0
	CONTPAGNF()
Else
	nContPag += 1
Endif

// Primeira Box
oPrint:SayBitmap(0030,0030,cBitmap,0115,0075)
If Empty((_cAlias)->ECOMMERCE)
	oPrint:Say (0080,0250,"Rela็ใo de Pick-List - Quantidade por Caixa",oFont16N) //Titulo
Else
	oPrint:Say (0080,0250,"Rela็ใo de Pick-List - Quantidade por Unidade",oFont16N) //Titulo
Endif
oPrint:Say(0075,0650,"PมG.:"+" "+cvaltochar(nFol) +"    "+ DTOC(Date())+"    "+  Time(),oFont14)//Pag

If !(_cAlias)->(Eof())
	nValBrut := (_cAlias)->VALBRUT
	nMsgNota := Posicione("SC5",1,xFilial("SC5")+(_cAlias)->PEDIDO,"C5_MENNOTA")
	
	oPrint:Say (0110,0032,"Cliente:",oFont16N)
	oPrint:Say (0110,0072,Alltrim((_cAlias)->F2COD) + "/" + Alltrim((_cAlias)->F2LOJA) + " " + Alltrim((_cAlias)->NOMCLI),oFont16 ) // C๓digo/Loja Nome do Cliente
	
	oPrint:Say (0130,0032,"Cidade:",oFont16N)
	oPrint:Say (0130,0072,Alltrim((_cAlias)->MUN) + "/" + Alltrim((_cAlias)->EST) ,oFont16 )// Cidade/UF
	oPrint:Say (0130,0410,"Emissใo:",oFont16N)
	oPrint:Say (0130,0460,DTOC(STOD((_cAlias)->DTEMISS)),oFont16 ) // Data de Emissao
	
	oPrint:Say (0150,0032,"Nota:",oFont16N)
	oPrint:Say (0150,0062,(_cAlias)->DOC,oFont16 )//Numero da nota Fiscal
	oPrint:Say (0150,0410,"Pedido:",oFont16N)
	oPrint:Say (0150,0450,(_cAlias)->PEDIDO,oFont16 )// Numero do pedido
	
	oPrint:Say (0170,0032,"Transportadora:",oFont16N)
	oPrint:Say (0170,0120,(_cAlias)->NOMETR,oFont16 ) // Nome da transportadora
	oPrint:Say (0170,0410,"Peso Bruto:",oFont16N)
	oPrint:Say (0170,0475,cvaltochar(Transform((_cAlias)->PESOBRUT,"@E 999999.99")),oFont16 )// Peso bruto total da nota
	oPrint:Say(0170,0650,"Pแgina NF:"+" "+cvaltochar(nContPag) +"/"+ cvaltochar(nQtdPag),oFont14)	

	BuzzBox(0100,0030,0180,0800) //(_nLinIni,_nColIni,_nLinFin,_nColFin)
	
Endif
nLinha := 180

BuzzBox(nlinha,0030,nlinha+0012,0800)	//	15o. Box Equipamento  Qtde   Peso          VL Base     Valor Total
oPrint:FillRect({nlinha+0001,0030,nlinha+0011,0800 },oBrush2)	// Pinta o Box do Cabecalho da Cor cinza claro
oPrint:Say (nlinha+0009,0032,"Produto",oFont16N )
oPrint:Say (nlinha+0009,0150,"Qtde",oFont16N )
oPrint:Say (nlinha+0009,0280,"Descri็ใo",oFont16N )
incrementa()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ Itens           บAutorณ Caroline Cazela            บ Data ณ 23/07/2018 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Imprime lista de itens do Relatorio                                    บฑฑ
ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ITENS()	// Montagem da listagem de itens

Local NX		:= 0
Local nQtdB1	:= 0
Local nQuant	:= 0
Local cQuery	:= ""

nLinha	+= 3
cPedido	:= (_cAlias)->PEDIDO
cDoc	:= (_cAlias)->DOC

While !(_cAlias)->(Eof())
	
	If (_cAlias)->PEDIDO != cPedido .OR. (_cAlias)->DOC != cDoc
		RODAPE()
		cPedido := (_cAlias)->PEDIDO
		cDoc	:= (_cAlias)->DOC
		oPrint:EndPage()
		oPrint:StartPage()
		nContPag	:= 0
		CABECA()
	Endif
	
	If nLinha > 420  //Quebra de pแgina quando encher a primeira
		oPrint:EndPage()
		oPrint:StartPage()
		CABECA()
	Endif
	
	nLinha	+= 1
	nQtdB1	:= (_cAlias)->QTDPCXA
	nQuant	:= 0
	If Empty((_cALias)->ECOMMERCE)
		If nQtdB1 > 1
			nQuant	:= (_cAlias)->QUANT / nQtdB1
		Else
			nQuant	:= (_cAlias)->QUANT
		Endif
	Else
		nQuant	:= (_cAlias)->QUANT
	Endif

	BuzzBox(nlinha,0030,nlinha+0013,0800)	//	Box Dados
	oPrint:Say (nlinha+000010,0032,(_cAlias)->D2PRD,oFont16 )
	oPrint:Say (nlinha+000010,0150,Alltrim(Transform(nQuant,"@E 99999999")),oFont16N )
	oPrint:Say (nlinha+000010,0280,Substr( (_cAlias)->DESCPRD,1,45),oFont16 )
	incrementa()
	nLinha += 2
	
	(_cAlias)->(DbSkip())
End

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ Rodape          บAutorณ Caroline Cazela            บ Data ณ 23/07/2018 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Imprime Rodape do Relatorio                                            บฑฑ
ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RODAPE()	// Montagem do Rodap้ Retrato

nLinha := 420
BuzzBox(nLinha,0550,nLinha+0040,0700) // Box Assinaturas Separado
oPrint:Say (nLinha+0008,0551,"SEPARADO POR",oFont10N )
oPrint:Say (nLinha+0027,0561,"__________________________",oFont10N )
oPrint:Say (nLinha+0035,0580,"ASSINATURA",oFont10N )

BuzzBox(nLinha,0550,nLinha+0080,0700) // Box Assinaturas Recontado
oPrint:Say (nLinha+0048,0551,"RECONTADO POR",oFont10N )
oPrint:Say (nLinha+0067,0561,"__________________________",oFont10N )
oPrint:Say (nLinha+0075,0580,"ASSINATURA",oFont10N )

BuzzBox(nLinha,0700,nLinha+0080,0800) // Box Volumes
oPrint:Say (nLinha+0008,0701,"VOLUME(S)",oFont10N )

incrementa()
incrementa()
incrementa()
incrementa()
incrementa()
incrementa()
incrementa()
incrementa()
incrementa()
SC5->(DbSelectArea("SC5"))
SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SC5")+(_cAlias)->PEDIDO))

BuzzBox(nLinha,0030,nLinha+0060,0800) // Box TotalGeral
oPrint:Say (nLinha+0008,0031,"Observa็๕es:",oFont10N )
oPrint:Say (nLinha+0018,0031,substr(nMsgNota,1,150),oFont10 )
oPrint:Say (nLinha+0028,0031,substr(nMsgNota,151,300),oFont10 )
oPrint:Say (nLinha+0038,0031,substr(nMsgNota,301,450),oFont10 )
oPrint:Say (nLinha+0048,0031,substr(nMsgNota,451,600),oFont10 )
oPrint:Say (nLinha+0058,0031,substr(nMsgNota,601,750),oFont10 )

oPrint:Say (nLinha+0008,0700,"Total da Nota",oFont10N )
oPrint:Say (nLinha+0018,0700,Alltrim(Transform(nValBrut,"@E 999,999,999.99")),oFont10 )
incrementa()
incrementa()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ BuzzBox         บAutorณ Silvio Cazela              บ Data ณ 24/04/2013 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Desenha um Box Sem Preenchimento                                       บฑฑ
ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function BuzzBox(_nLinIni,_nColIni,_nLinFin,_nColFin) // < nRow>, < nCol>, < nBottom>, < nRight>

oPrint:Line( _nLinIni,_nColIni,_nLinIni,_nColFin,CLR_BLACK, "-2")
oPrint:Line( _nLinFin,_nColIni,_nLinFin,_nColFin,CLR_BLACK, "-2")
oPrint:Line( _nLinIni,_nColIni,_nLinFin,_nColIni,CLR_BLACK, "-2")
oPrint:Line( _nLinIni,_nColFin,_nLinFin,_nColFin,CLR_BLACK, "-2")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณIncrementa       บAutorณ Caroline Cazela            บ Data ณ 12/08/2014 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Incrementa linhas em branco                                            บฑฑ
ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function incrementa()

nlinha+=10

IF nlinha>570
	oPrint:EndPage()
	oPrint:StartPage()
	nFol:= nFol+1
	
	// Primeira Box
	oPrint:SayBitmap(0030,0030,cBitmap,0115,0075)
	oPrint:Say (0080,0250,"Rela็ใo de Pick-List - Quantidade por Caixa",oFont16N) //Titulo
	oPrint:Say(0075,0650,"PมG.:"+" "+cvaltochar(nFol),oFont14)//Pag
	//BuzzBox(0030,0030,0100,0800)
	
	/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
	ฑฑบPrograma ณ  BuzzBox        บAutorณ Caroline Cazela            บ Data ณ 23/07/2018 บฑฑ
	ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
	ฑฑบDescricaoณ Imprime cabecalho do Relatorio                                         บฑฑ
	ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
	If !(_cAlias)->(Eof())
		oPrint:Say (0110,0032,"Cliente:",oFont16N)
		oPrint:Say (0110,0072,Alltrim((_cAlias)->F2COD) + "/" + Alltrim((_cAlias)->F2LOJA) + " " + Alltrim((_cAlias)->NOMCLI),oFont16 ) // C๓digo/Loja Nome do Cliente
		
		oPrint:Say (0130,0032,"Cidade:",oFont16N)
		oPrint:Say (0130,0072,Alltrim((_cAlias)->MUN) + "/" + Alltrim((_cAlias)->MUN),oFont16 )// Cidade/UF
		oPrint:Say (0130,0410,"Emissใo:",oFont16N)
		oPrint:Say (0130,0460,DTOC(STOD((_cAlias)->DTEMISS)),oFont16 ) // Data de Emissao
		
		oPrint:Say (0150,0032,"Nota:",oFont16N)
		oPrint:Say (0150,0062,(_cAlias)->DOC,oFont16 )//Numero da nota Fiscal
		oPrint:Say (0150,0410,"Pedido:",oFont16N)
		oPrint:Say (0150,0450,(_cAlias)->PEDIDO,oFont16 )// Numero do pedido
		
		oPrint:Say (0170,0032,"Transportadora:",oFont16N)
		oPrint:Say (0170,0120,(_cAlias)->NOMETR,oFont16 ) // Nome da transportadora
		oPrint:Say (0170,0410,"Peso Bruto:",oFont16N)
		oPrint:Say (0170,0475,cvaltochar(Transform((_cAlias)->PESOBRUT,"@E 999999.9999")),oFont16 )// Peso bruto total da nota
		
		BuzzBox(0100,0030,0180,0800) //(_nLinIni,_nColIni,_nLinFin,_nColFin)
		
	Endif
	
	/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
	ฑฑบPrograma ณ  BuzzBox        บAutorณ Caroline Cazela            บ Data ณ 23/07/2018 บฑฑ
	ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
	ฑฑบDescricaoณ Imprime dados do relatorio                                             บฑฑ
	ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
	nLinha := 180
	
	BuzzBox(nlinha,0030,nlinha+0012,0800)	//	15o. Box Equipamento  Qtde   Peso          VL Base     Valor Total
	oPrint:FillRect({nlinha+0001,0030,nlinha+0011,0800 },oBrush2)	// Pinta o Box do Cabecalho da Cor cinza claro
	oPrint:Say (nlinha+0009,0032,"Produto",oFont16N )
	oPrint:Say (nlinha+0009,0200,"Qtde",oFont16N )
	oPrint:Say (nlinha+0009,0280,"Descri็ใo",oFont16N )
	incrementa()
	nLinha += 3
	//nlinha:= 0100
ENDIF

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ Cabeca          บAutorณ Caroline Cazela            บ Data ณ 26/04/2013 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Ajustar perguntas na sx1			                                     บฑฑ
ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

// Ajusta as perguntas
Static Function AjustaSx1(cPerg)

Local aAreaSx1	:= SX1->(GetArea())
SX1->(DbSetOrder(1))
cPerg := PADR(UPPER(cPerg),10)

If !SX1->(DbSeek(cPerg))
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "01"
	SX1->X1_PERGUNT	:= "Nota de"
	SX1->X1_PERSPA	:= "Nota de"
	SX1->X1_PERENG	:= "Nota de"
	SX1->X1_VARIAVL	:= "MV_CH1"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("F2_DOC")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR01"
	SX1->X1_F3		:= "SF2"
	SX1->(MsUnlock())
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "02"
	SX1->X1_PERGUNT	:= "Nota ate"
	SX1->X1_PERSPA	:= "Nota ate"
	SX1->X1_PERENG	:= "Nota ate"
	SX1->X1_VARIAVL	:= "MV_CH2"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("F2_DOC")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR02"
	SX1->X1_F3		:= "SF2"
	SX1->(MsUnlock())
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "03"
	SX1->X1_PERGUNT	:= "Serie"
	SX1->X1_PERSPA	:= "Serie"
	SX1->X1_PERENG	:= "Serie"
	SX1->X1_VARIAVL	:= "MV_CH3"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("F2_SERIE")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR03"
	SX1->(MsUnlock())
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "04"
	SX1->X1_PERGUNT	:= "Pedido de"
	SX1->X1_PERSPA	:= "Pedido de"
	SX1->X1_PERENG	:= "Pedido de"
	SX1->X1_VARIAVL	:= "MV_CH4"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("C5_NUM")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR04"
	SX1->X1_F3		:= "SC5"
	SX1->(MsUnlock())
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "05"
	SX1->X1_PERGUNT	:= "Pedido ate"
	SX1->X1_PERSPA	:= "Pedido ate"
	SX1->X1_PERENG	:= "Pedido ate"
	SX1->X1_VARIAVL	:= "MV_CH5"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("C5_NUM")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR05"
	SX1->X1_F3		:= "SC5"
	SX1->(MsUnlock())
Endif

RestArea(aAreaSX1)

Return



Static Function CONTPAGNF

Local aArea		:= GetArea()
Local cNumNF	:= (_cAlias)->DOC

nContPag	:= 1

If Select("TRBSD2") > 0
	TRBSD2->(DbCloseArea())
Endif

cQuery	:= " SELECT COUNT(*) AS 'TOTIT' FROM " + RetSqlName("SD2") + " SD2 (NOLOCK) "
cQuery	+= " WHERE D2_DOC = '"+cNumNF+"' "
cQuery	+= " AND D2_FILIAL = '"+cFilAnt+"' "
cQuery	+= " AND SD2.D_E_L_E_T_ = '' "
PLSQUERY(cQuery,"TRBSD2")

/*----------------------------------------------------------------------\
| Cแlcula quantidade de pแginas pode nota, total de 18 itens por pแgina |
\----------------------------------------------------------------------*/
If Select("TRBSD2") > 0
	If TRBSD2->TOTIT > 0
		If INT(TRBSD2->TOTIT / 18) > 0
			nQtdPag	:= INT(TRBSD2->TOTIT / 18)
			If MOD(TRBSD2->TOTIT , 18) > 0
				nQtdPag	:= nQtdPag + 1
			Endif
		Else
			nQtdPag	:= 1
		Endif
	Endif
	TRBSD2->(DbCloseArea())
Endif

RestArea(aArea)

Return()
