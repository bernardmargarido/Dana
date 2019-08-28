#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static aBitMaps := {}
Static cBitmap	:= Space(30)

/************************************************************
{Protheus.doc} ECLJM001
@description retorna imagem status pedido e-commerce

@author Bernard M. Margarido
@since 06/07/2016
@version 1

@type function
*************************************************************/
User Function ECLJM001()
	Local aArea			:= GetArea()
	Local aSize			:= MsAdvSize()

	Local nOpcA			:= 0

	Local oDlg			:= Nil

	Local aButtons		:= {}

	Private cDirArq		:= GetSrvProfString("StartPath","")
	Private cNomArq		:= "aecosta.eco"
	
	Private aHeaderBit 	:= {}
	Private aColsBit 	:= {}
	Private aAlterGda	:= {}
	
	Private oMsGBit		:= Nil
	
	//----------------------------+
	// Cria arquivo com os status |	
	//----------------------------+
	If !File(cDirArq + cNomArq)
		aEcoCriaArq()
	EndIf
	
	//---------------------------------+
	// Cria Header e aCols das Imagens |	
	//---------------------------------+
	aEcoHead()

	//---------------------------------------+
	// Cria botão para inserir novos bitmaps |
	//---------------------------------------+
	aAdd( aButtons, { 'PRINT03'  , {|| aEcoBitNew() }, "Inserir novo status" } )

	DEFINE MSDIALOG oDlg TITLE "Status eCommerce" From aSize[7],0 to aSize[6] - 188 ,aSize[5] - 689 of oMainWnd PIXEL //STYLE nOr(WS_VISIBLE,WS_POPUP)//375,615

	//--------------+
	// Painel Layer |
	//--------------+
	oFwLayer := FwLayer():New()
	oFwLayer:Init(oDlg,.F.)

	//------------+
	// 1o. Painel |   
	//------------+
	oFWLayer:addLine("BITMAP",090, .T.)
	oFWLayer:addCollumn( "COLBIT",100, .T. , "BITMAP")
	oFWLayer:addWindow( "COLBIT", "WINENT", "Imagens Repositorio", 100, .F., .F., , "BITMAP") 
	oPanel1 := oFWLayer:GetWinPanel("COLBIT","WINENT","BITMAP")

	oMsGBit	:= MsNewGetDados():New(000,000,000,000,0,/*cLinOk*/,/*cTudoOk1*/,/*cIniCpos*/,/*aAlterGda*/,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,oPanel1,aHeaderBit,aColsBit)
	oMsGBit:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar( oDlg , {|| nOpcA := 1 , oDlg:End() } , {|| oDlg:End() } ,,aButtons )

	If nOpcA == 1
		cBitmap := aColsBit[oMsGBit:nAt][2]
	EndIf

	RestArea(aArea)
Return .T.

/*****************************************************
{Protheus.doc} aEcoHead

@description Cria array com as imagens  

@author Bernard M. Margarido
@since 06/07/2016
@version 1

@type function
******************************************************/
Static Function aEcoHead()
	Local aArea		:= GetArea()

	Local nHdlArq	:= 0
    Local _nPBitMap := 0

	Local cLiArq	:= ""
	
	aHeaderBit		:= {}
	aColsBit		:= {}
	
	aAdd(aHeaderBit,{'Imagem'		,'IMAGEM'	,'@BMP'	,01	,0,'' ,'û','C','' ,'' } )
	aAdd(aHeaderBit,{'Nome IMG'		,'NOMIMG'	,'@!'	,30	,0,'' ,'û','C','' ,'' } )

	Aadd(aAlterGda,aHeaderBit[1,2])
	Aadd(aAlterGda,aHeaderBit[2,2])

	nHdlArq  := Ft_Fuse(cDirArq + cNomArq)

	If nHdlArq <= 0
		MsgStop('Erro ao Abrir arquivo de status.')
		RestArea(aArea)
		Return Nil
	EndIf

	//-----------------------------+
	// Posiciona Inicio do Arquivo |
	//-----------------------------+
	Ft_FGoTop()
	While !Ft_FEof()
		cLiArq := Ft_FReadLn()
		If Empty(cLiArq)
			Ft_FSkip(1)
			Loop
		EndIf
		aSepara := Separa(Embaralha(cLiArq,1),";")
		aAdd(aBitMaps,{aSepara[1],aSepara[2]})
		Ft_FSkip(1)
	EndDo
	Ft_Fuse()

	For nBmp := 1 To Len(aBitMaps)
        _nPBitMap := aScan(aColsBit,{|x| Rtrim(x[2]) == Rtrim(aBitMaps[nBmp][2])})
        If _nPBitMap == 0
            aAdd(aColsBit,Array(Len(aHeaderBit)+1))
            For nHead := 1 To Len(aHeaderBit)	
                aColsBit[Len(aColsBit)][nHead] := aBitMaps[nBmp][nHead]
            Next nHead
            aColsBit[Len(aColsBit)][Len(aHeaderBit)+1] := .F.
        EndIf
	Next nBmp

	RestArea(aArea)
Return Nil

/***************************************************************
{Protheus.doc} aEcoCriaArq
@description Cria Arquivo com os Status do e-Commerce
@author Bernard M. Margarido
@since 07/07/2016
@version 1
@param cDirArq, characters, descricao
@param cNomArq, characters, descricao
@type function
***************************************************************/
Static Function aEcoCriaArq()
	Local aArea		:= GetArea()
	Local aStatus 	:= {}

	Local nHdl		:= 0

	aAdd(aStatus,{"BR_VERDE","BR_VERDE"})
	aAdd(aStatus,{"BR_AMARELO","BR_AMARELO"})
	aAdd(aStatus,{"BR_BRANCO","BR_BRANCO"})      
	aAdd(aStatus,{"BR_CINZA","BR_CINZA"})       
	aAdd(aStatus,{"BR_CANCEL","BR_CANCEL"})      
	aAdd(aStatus,{"BR_PINK","BR_PINK"})        
	aAdd(aStatus,{"BR_MARROM","BR_MARROM"})      
	aAdd(aStatus,{"BR_ROXO","BR_ROXO"})        
	aAdd(aStatus,{"BR_VERMELHO","BR_VERMELHO"})    
	aAdd(aStatus,{"BR_PRETO","BR_PRETO"})       
	aAdd(aStatus,{"BR_LARANJA","BR_LARANJA"})     
	aAdd(aStatus,{"BR_AZUL","BR_AZUL"})

	nHdl := FCreate(cDirArq + cNomArq)
	If nHdl < 0 
		MsgStop('Erro ao criar arquivo ' + Str(Ferror()),'')
	EndIf

	For nStat := 1 To Len(aStatus)
		FWrite(nHdl,Embaralha(aStatus[nStat][1] + ";" + aStatus[nStat][2],0) + CRLF)
	Next nStat

	//-------------------------------+
	// Fecha arquivo apos a gravação |
	//-------------------------------+
	FClose(nHdl)

	RestArea(aArea)
Return .T.


/********************************************************************
{Protheus.doc} aEcoBitNew

@description Grava novo status no e-Commerce.

@author Bernard M. Margarido
@since 28/07/2016
@version undefined

@type function
********************************************************************/
Static Function aEcoBitNew()
	Local aArea 	:= GetArea()
	Local aSize		:= MsAdvSize()

	Local nOpcX		:= 0
	Local nRadio	:= 0

	Local oDlg		:= Nil 

	Private aHeadNew:= {}
	Private aColsNew:= {}	
	Private aBitmap	:= {}

	aNewBit()

	DEFINE MSDIALOG oDlg TITLE "Novo Status" From aSize[7],0 to aSize[6] - 188 ,aSize[5] - 689 of oMainWnd PIXEL //STYLE nOr(WS_VISIBLE,WS_POPUP)//375,615
	//--------------+
	// Painel Layer |
	//--------------+
	oFwLayer := FwLayer():New()
	oFwLayer:Init(oDlg,.F.)

	//------------+
	// 1o. Painel |   
	//------------+
	oFWLayer:addLine("NOMEBIT",45, .T.)

	//-----------------------------+
	// 1o. Coluna - Tipo de Imagem |   
	//-----------------------------+
	oFWLayer:addCollumn( "COLTPIMG"	,30, .T. , "NOMEBIT")
	oFWLayer:addWindow( "COLTPIMG"	, "WINENT", "Escolha Tipo de Imagem", 100, .F., .F., , "NOMEBIT")
	oPanel1 := oFWLayer:GetWinPanel("COLTPIMG","WINENT","NOMEBIT")

	//---------------------+
	// 2o. Coluna - Imagem |   
	//---------------------+
	oFWLayer:addCollumn( "COLIMG"	,70, .T. , "NOMEBIT")
	oFWLayer:addWindow( "COLIMG"	, "WINENT", "Imagem", 100, .F., .F., , "NOMEBIT")
	oPanel2:= oFWLayer:GetWinPanel("COLIMG","WINENT","NOMEBIT")

	//------------+
	// 2o. Painel |   
	//------------+
	oFWLayer:addLine("BITMAP",51, .T.)
	oFWLayer:addCollumn( "COLBIT",100, .T. , "BITMAP")
	oFWLayer:addWindow( "COLBIT", "WINENT", "Imagens", 100, .F., .F., , "BITMAP") 
	oPanel3 := oFWLayer:GetWinPanel("COLBIT","WINENT","BITMAP")

	//---------------------+
	// Objeto Radio Button |
	//---------------------+
	oRadio 			:= TRadMenu():New(001,001,{"*.BMP","*.PNG","*.JPG"},{|u|Iif( PCount() == 0,nRadio, nRadio:=u )}, oPanel1,,/*bChange*/,/*nClrText*/,/*nClrPane*/,/*cMsg*/,,/*bWhen*/,100,100,/*bValid*/,,,/*lPixel*/, /*lHoriz*/ )
	oRadio:bSetGet  := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
	oRadio:bChange	:= {|| aEcoLoad(nRadio,oBmp,oMsGNew) }
	oRadio:Align 	:= CONTROL_ALIGN_ALLCLIENT 	

	//---------------+
	// Objeto Imagem |
	//---------------+
	oBmp 			:= TBitmap():New(001,001,200,200,aColsNew[1][1],/*cBmpFile*/,/*lNoBorder*/,oPanel2,/*bLClicked*/,/*bRClicked*/,/*lScroll*/,/*lStretch*/,/*oCursor*/,,,/*bWhen*/,/*lPixel*/,/*bValid*/,,,)
	oBmp:lAutoSize 	:= .T.
	oBmp:Refresh()
	oBmp:Align 		:= CONTROL_ALIGN_ALLCLIENT

	//--------------+
	// Objeto Itens |
	//--------------+
	oMsGNew	:= MsNewGetDados():New(000,000,000,000,0,/*cLinOk*/,/*cTudoOk1*/,/*cIniCpos*/,/*aAlterGda*/,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,oPanel3,aHeadNew,aColsNew)
	oMsGNew:bChange := {|| aEcoBitLoad(oMsGNew,oBmp)}
	oMsGNew:Refresh()
	oMsGNew:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar( oDlg , {|| nOpcX := 1 , oDlg:End() } , {|| oDlg:End() } )
	
	//------------------------+
	// Grava Imagem escolhida |
	//------------------------+
	
	If nOpcX == 1
	
		//------------------------+
		// Abre arquivo de Imagem |
		//------------------------+
		nHdl := fOpen(cDirArq + cNomArq , FO_READWRITE + FO_SHARED )
		If nHdl < 0 
			MsgStop('Erro ao criar arquivo ' + Str(Ferror()),'')
			RestArea(aArea)
			Return .T.
		EndIf
		
		//------------------------------+
		// Grava nova imagem no arquivo |
		//------------------------------+	
		FSeek(nHdl,0,FS_END)
		FWrite(nHdl,Embaralha(SubStr(oMsGNew:aCols[oMsGNew:nAt][1],1,Rat(".",oMsGNew:aCols[oMsGNew:nAt][1]) -1 ) + ";" + SubStr(oMsGNew:aCols[oMsGNew:nAt][1],1,Rat(".",oMsGNew:aCols[oMsGNew:nAt][1]) -1 ),0) + CRLF)
		
		//-------------------------------+
		// Fecha arquivo apos a gravação |
		//-------------------------------+
		FClose(nHdl)
		
		// -----------------------------+
		// Atualiza tela com a nova Cor |
		// -----------------------------+
		aEcoHead()
		
		oMsGBit:aCols := {}	
		oMsGBit:Refresh()
		
		oMsGBit:aCols := aClone(aColsBit)
		oMsGBit:Refresh()
		 
	EndIf

	RestArea(aArea)
Return .T.

/*****************************************************
{Protheus.doc} aEcoHead

@description Cria array com as imagens  

@author Bernard M. Margarido
@since 06/07/2016
@version 1

@type function
******************************************************/
Static Function aNewBit()
	Local aArea		:= GetArea()

	Local nHdlArq	:= 0

	Local cLiArq	:= ""

	//--------------+
	// Reseta Array |
	//--------------+
	aHeadNew := {}
	aColsNew := {}

	//---------------------+
	// Cria Header e Acols |
	//---------------------+
	aAdd(aHeadNew,{'Nome IMG'		,'NOMIMG'	,'@!'	,40	,0,'' ,'û','C','' ,'' } )

	If Len(aBitMap) > 0 
		For nBmp := 1 To Len(aBitMap)

			aAdd(aColsNew,Array(Len(aHeadNew)+1))
			For nHead := 1 To Len(aHeadNew)	
				aColsNew[Len(aColsNew)][nHead] := aBitMap[nBmp]
			Next nHead
			aColsNew[Len(aColsNew)][Len(aHeadNew)+1] := .F.

		Next nBmp
	Else

		aAdd(aColsNew,Array(Len(aHeadNew)+1))
		For nHead := 1 To Len(aHeadNew)	
			aColsNew[Len(aColsNew)][nHead] := ""
		Next nHead
		aColsNew[Len(aColsNew)][Len(aHeadNew)+1] := .F.

	EndIf

	RestArea(aArea)
Return Nil


/******************************************************************
{Protheus.doc} aEcoBitLoad

@description Carrega imagem escolhida

@author Bernard M. Margarido

@since 28/07/2016
@version undefined

@param oMsGNew, object, Objeto GetDados
@param oBmp, object, Objeto Imagem

@type function
******************************************************************/
Static Function aEcoBitLoad(oMsGNew,oBmp)

	oBmp:Load(oMsGNew:aCols[oMsGNew:nAt][1])
	oBmp:lAutoSize 	:= .T. 
	oBmp:Refresh()

Return .T. 


/********************************************************************
{Protheus.doc} aEcoLoad

@description Carrega imagens conforme opção escolhida

@author Bernard M, Margarido

@since 28/07/2016
@version undefined
@param nRadio	, numeric	, opção escolhida
@param oBmp		, object	, Objeto Imagem
@param oMsGNew	, object	, Obejeto da GetDados
@type function

********************************************************************/
Static Function aEcoLoad(nRadio,oBmp,oMsGNew)

	If nRadio == 1 
		aBitmap 		:= GetResArray("*.BMP")
	ElseIf nRadio == 2
		aBitmap 		:= GetResArray("*.PNG")
	ElseIf nRadio == 3
		aBitmap 		:= GetResArray("*.JPG")
	EndIf	

	//-------------------------------------+
	// Carrega aCols com a Opção escolhida |
	//-------------------------------------+
	aNewBit()

	//--------------------------------------+
	// Atualiza GetDados com os novos Itens |
	//--------------------------------------+
	oMsGNew:aCols := aClone(aColsNew)
	oMsGNew:Refresh()

	//---------------------------+
	// Atualiza Imagem escolhida |
	//---------------------------+
	oBmp:Load(oMsGNew:aCols[oMsGNew:nAt][1])
	oBmp:Refresh()

Return .T.

/***********************************************************
{Protheus.doc} ABitRet
@description Retorna status selecionado

@author Bernard M. Margarido
@since 07/07/2016
@version 1

@type function
************************************************************/
User Function ABitRet()
Return cBitmap