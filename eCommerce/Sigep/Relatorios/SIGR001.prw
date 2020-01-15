#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF 		CHR(13) + CHR(10)
#DEFINE MAXMENLIN  	015     // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     	003     // Máximo de dados adicionais por página

/********************************************************************************/
/*/{Protheus.doc} SIGR001

@description Realiza a impressao das etiquetas Vizcaya

@author Bernard M. Margarido
@since 08/03/2017
@version undefined

@type function
/*/
/********************************************************************************/
User Function SIGR001()
	Local oDlg
	
	Local cCadastro	:= "Impressao Etiqueta Correios"
	Local cPerg		:= "ETQRAST"

	Local aTitEtq	:= {"","","Documento","Serie","Cod. Eco","Num. Eco","Codigo","Loja","Nome","REG"}
	Local aTamEtq	:= {05,05,35,20,30,30,30,15,100,20}
	Local aSize 	:= MsAdvSize()
	
	Local oFont1	:= TFont():New( "Fw Microsiga",,10,,.T.,,,,.F.,.F. )
	Local oFont2	:= TFont():New( "Fw Microsiga",,11,,.T.,,,,.F.,.F. )
	Local oOk     	:= LoadBitmap( GetResources(), "LBOK")
	Local oNo      	:= LoadBitmap( GetResources(), "LBNO")
	
	Local nOpcA		:= 0
	Local nEtq		:= 0
	
	Local lEndCli	:= .T.

	Private cNumSc5	:= ""
	Private cDest 	:= "" 
	Private cEndD 	:= ""
	Private cCepD 	:= ""
	Private cBairD	:= ""
	Private cMunD 	:= ""
	Private cUfD 	:= ""
	Private cDoc  	:= ""
	Private cSerie	:= ""
	Private cChave	:= ""
	Private cTrack  := ""
	Private cPorta	:= ""
	Private cBusca	:= ""
	Private cPesqTwb:= Space(20)	
	Private nReg	:= 0
	Private aNotas	:= {}
	Private aPesqCbx:= {"Documento","Cod. Eco","Num Eco.","Cliente"}
	
	Private oGet1 		:= Nil
	Private oGet2 		:= Nil
	Private oGet3 		:= Nil
	Private oGet4 		:= Nil
	Private oGet5 		:= Nil
	Private oGet6 		:= Nil
	Private oGet7 		:= Nil
	Private oGet8		:= Nil 
	Private oCbx01		:= Nil
		
	//------------------------+
	// Rotina gera parametros |
	//------------------------+
	AjustaSx1(cPerg)
	
	//--------------------+
	// Tela de Parametros |
	//--------------------+
	If !Pergunte(cPerg,.T.)
		Return .F. 	
	EndIf
	
	//--------------+
	// Cria Browser |
	//--------------+
	If !SigR01Array()
		MsgStop("Não foram encontrados dados para serem exibidos. Favor verificar o paramentro informado","Vizcaya - e-Commerce")
		Return .T.
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6]-163,aSize[5]-634 of oMainWnd PIXEL
	
		//--------------+
		// Painel Layer |
		//--------------+
		oFwLayer := FwLayer():New()
		oFwLayer:Init(oDlg ,.F.)
	
		//------------+
		// 1o. Painel |   
		//------------+
		oFWLayer:addLine("LINITETQ",050, .T.)
		oFWLayer:addCollumn( "COLITETQ",100, .T. , "LINITETQ")
		oFWLayer:addWindow( "COLITETQ", "WINENT", "Etiquetas", 100, .F., .T., , "LINITETQ") 
		oPanel := oFWLayer:GetWinPanel("COLITETQ","WINENT","LINITETQ")
		
		oTwBrowse := TWBrowse():New(000,000,328,062,,aTitEtq,aTamEtq,oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oTwBrowse:SetArray(aNotas)
		oTwBrowse:bLine := {|| {IIF(aNotas[oTwBrowse:nAt,1],oOk,oNo),;
								aNotas[oTwBrowse:nAt,2],;
								aNotas[oTwBrowse:nAt,3],;
								aNotas[oTwBrowse:nAt,4],;
								aNotas[oTwBrowse:nAt,5],;
								aNotas[oTwBrowse:nAt,6],;
								aNotas[oTwBrowse:nAt,7],;
								aNotas[oTwBrowse:nAt,8],;
								aNotas[oTwBrowse:nAt,9],;
								aNotas[oTwBrowse:nAt,10]}}	
								
		oTwBrowse:bChange 		:= { || nReg := aNotas[oTwBrowse:nAt,10],SigR01End(oTwBrowse,oTwBrowse:nAt)}
		oTwBrowse:bLDblClick 	:= { || ListOkNo(oTwBrowse,aNotas) }								
		
		oGrp:= TGroup():New(064,000,074,120,'',oPanel,,,.T.)
		@ 065,004 BITMAP oBmp1 ResName "BR_VERDE" OF oPanel Size 10,10 NoBorder When .F. Pixel 
		@ 065,016 SAY "Impressao" OF oPanel Color CLR_BLACK,CLR_WHITE PIXEL
		
		@ 065,061 BITMAP oBmp1 ResName "BR_VERMELHO" OF oPanel Size 10,10 NoBorder When .F. Pixel 
		@ 065,073 SAY "Reimpressao" OF oPanel Color CLR_BLACK,CLR_WHITE PIXEL
		
		//-------------------+
		// Combo de Pesquisa | 
		//-------------------+
		oCbx01 := TComboBox():New(064,122,{ |u| If( PCount() > 0, cBusca := u, cBusca )}	,aPesqCbx	,050,010,oPanel,,,,,,.T.,,,,,,,,,"cBusca","Busca Por:")
		oGet8  := TGet():New( 064, 204, {|u| IIF(PCount() > 0, cPesqTwb := u, cPesqTwb)} 	,oPanel		,090,008,"@!",,,,,,,.T.,,,,,,,.F.,,,"cPesqTwb",,,,.T.,,,)
		oBtnPmp:= TBtnBmp2():New(125,590,023,023,"PESQUISA",,,,{|| SigR01Pesq(cBusca,cPesqTwb,aNotas,oTwBrowse) },oPanel,"Pesquisa")
		
		//------------+
		// 2o. Painel |   
		//------------+
		oFWLayer:addLine("LIDADETQ",045, .T.)
		oFWLayer:addCollumn( "CODADETQ",100, .T. , "LIDADETQ")
		oFWLayer:addWindow( "CODADETQ", "WINENT", "Dados Etiqueta", 100, .F., .T., , "LIDADETQ") 
		oPanel2 := oFWLayer:GetWinPanel("CODADETQ","WINENT","LIDADETQ")
	
		oGet1 := TGet():New( 001, 001, {|u| IIF(PCount() > 0, cDest  := u, cDest )} 	, oPanel2, 150, 008,,,,,,,,.T.,,,,,,,.T.,,"","cDest",,,,,,,"Destinatario",1)
		oGet2 := TGet():New( 001, 160, {|u| IIF(PCount() > 0, cCepD  := u, cCepD )} 	, oPanel2, 040, 008,PesqPict("SA1","A1_CEP"),,,,,,,.T.,,,,,,,.T.,,"","cCepD",,,,,,,"CEP",1)
		oGet3 := TGet():New( 001, 210, {|u| IIF(PCount() > 0, cUfD  := u, cUfD )} 		, oPanel2, 020, 008,,,,,,,,.T.,,,,,,,.T.,,"","cUfD",,,,,,,"UF",1)
		oGet4 := TGet():New( 020, 001, {|u| IIF(PCount() > 0, cEndD  := u, cEndD )} 	, oPanel2, 150, 008,,,,,,,,.T.,,,,,,,.T.,,"","cEndD",,,,,,,"Endereço",1)
		oGet5 := TGet():New( 020, 160, {|u| IIF(PCount() > 0, cBairD  := u, cBairD )} 	, oPanel2, 060, 008,,,,,,,,.T.,,,,,,,.T.,,"","cBairD",,,,,,,"Bairro",1)
		oGet6 := TGet():New( 020, 230, {|u| IIF(PCount() > 0, cMunD  := u, cMunD )} 	, oPanel2, 060, 008,,,,,,,,.T.,,,,,,,.T.,,"","cMunD",,,,,,,"Municipio",1)
		oGet7 := TGet():New( 038, 001, {|u| IIF(PCount() > 0, cTrack  := u, cTrack)} 	, oPanel2, 080, 008,,,,,,,,.T.,,,,,,,.T.,,"","cTrack",,,,,,,"Rastreio",1)
						
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , {|| nOpcA := 1, oDlg:End() } , {|| oDlg:End() } )
	
	If nOpcA == 1
		For nEtq := 1 To Len(aNotas)
			If aNotas[nEtq][1]
				PrtEtqDesp(aNotas[nEtq],nEtq)
			EndIf	
		Next nEtq	
	EndIF	
	
Return Nil

/*********************************************************************************/
/*/{Protheus.doc} ListOkNo

@description Realiza a marcação das etiquetas que serã impressas

@author Bernard M. Margarido
@since 13/03/2017
@version undefined
@param oList		, object	, descricao
@param aLista		, array		, descricao
@type function
/*/
/*********************************************************************************/
Static Function ListOkNo(oList,aLista)
Local nI		:= 0
Local lRet		:= .T.

aLista[oList:nAt,1]:= !aLista[oList:nAt,1]
If !aLista[oList:nAt,1]
	aLista[1,1]:= .F.
EndIf

oList:Refresh()

Return (lRet)

/*********************************************************************************/
/*/{Protheus.doc} SigR01End

@description Atualiza dados de entrega

@author Bernard M. Margarido
@since 09/03/2017
@version undefined

@param oTwBrowse	, object	, descricao
@param nLinha		, numeric	, descricao

@type function
/*/
/*********************************************************************************/
Static Function SigR01End(oTwBrowse,nLinha)
Local aArea	:= GetARea()

SL1->( dbGoto(aNotas[nLinha][10]) )

cDest 	:= Capital(Alltrim(SL1->L1_XNOMDEST))
cEndD 	:= Capital(Alltrim(SL1->L1_ENDENT)) + ", " + Alltrim(SL1->L1_XENDNUM)
cCepD 	:= SL1->L1_CEPE
cBairD	:= Capital(Alltrim(SL1->L1_BAIRROE))
cMunD 	:= Capital(Alltrim(SL1->L1_MUNE))
cUfD  	:= Alltrim(SL1->L1_ESTE)
cTrack	:= Alltrim(SL1->L1_XTRACKI)

oGet1:Refresh()
oGet2:Refresh()
oGet3:Refresh()
oGet4:Refresh()
oGet5:Refresh()
oGet6:Refresh()
oGet7:Refresh()

RestArea(aArea)
Return .T.

/*************************************************************************************/
/*/{Protheus.doc} SigR01Pesq

@description Realiza a pesquisa das etiquetas

@author Bernard M. Margarido
@since 24/04/2017
@version undefined
@param cBusca		, characters, descricao
@param cPesqTwb		, characters, descricao
@param aNotas		, array		, descricao
@param oTwBrowse	, object	, descricao
@type function
/*/
/*************************************************************************************/
Static Function SigR01Pesq(cBusca,cPesqTwb,aNotas,oTwBrowse)
Local nPPesq	:= 0

If Alltrim(cBusca) == "Documento"
	nPPesq := aScan(aNotas,{|x| Alltrim(x[3]) == Alltrim(cPesqTwb)})
ElseIf Alltrim(cBusca) == "Cod. Eco"
	nPPesq := aScan(aNotas,{|x| Alltrim(x[5]) == Alltrim(cPesqTwb)})
ElseIf Alltrim(cBusca) == "Num Eco." 
	nPPesq := aScan(aNotas,{|x| Alltrim(x[6]) == Alltrim(cPesqTwb)})
ElseIf Alltrim(cBusca) == "Cliente"
	nPPesq := aScan(aNotas,{|x| Alltrim(x[7]) == Alltrim(cPesqTwb)})
EndIf

oTwBrowse:nAt := nPPesq
oTwBrowse:Refresh()

Return .T.

/**********************************************************************************/
/*/{Protheus.doc} PrtEtqDesp

@description Realiza a impressao da etiqueta

@author Bernard M. Margarido
@since 09/03/2017
@version undefined

@type function
/*/
/**********************************************************************************/
Static Function PrtEtqDesp(aEtq,nArq)
	Local aArea		:= GetArea()
	Local cPorta	:= "LPT1" 
	Local cEtq		:= ""
	Local cSelo		:= ""
	Local cTransp 	:= ""
		
	Local nVolume	:= 0
	Local nHandle	:= 0	
	Local nCompl	:= 0
	Local nLComp	:= 0
	Local _nX		:= 0
	
	Local aComple	:= {}
	
	//---------------------+
	// Posiciona Orçamento |
	//---------------------+
	dbSelectArea("SL1")
	SL1->( dbGoTo(aEtq[10]) )
	
	//-------------------------+
	// Posiciona serviço SIGEP |
	//-------------------------+
	dbSelectArea("SZ0")
	SZ0->( dbSetOrder(2) )
	If !SZ0->( dbSeek(xFilial("SZ0") + SL1->L1_XSERPOS) )
		MsgStop("Transportadora não localizada.","Totvs")
		Return .T.
	EndIf	
	
	//---------------------------------+
	// Descrição do meio de transporte |
	//---------------------------------+
	cTransp := Alltrim(SZ0->Z0_DESCRI)
	
	//---------------------+
	// Marca como impressa |
	//---------------------+
	RecLock("SL1",.F.)
		SL1->L1_MIDIA := "IMP"
	SL1->( MsUnLock() )
		
	//-------------------------------+
	// Pega Imagem da Transportadora |
	// 001336 - ESEDEX				 |
	// 001360 - SEDEX                |
	// 001357 - PAC                  |
	//-------------------------------+
	If At("SEDEX",cTransp) > 0 
		cSelo := '^FO20,20^GFA,2205,2205,21,,'
		cSelo += '::X0JF,U01NF8,T03PFC,S03IFEJ07IFC,R03FFEN07FFC,Q01FFCP03FF8,Q0FF8R03FF,P03FCT03FC,'
		cSelo += 'O01FEV07F8,O07FX0FE,N01FCX03F8,N07Fg0FE,N0FCg03F,M03FgH0FC,M0FCgH03F,L01FgJ0F8,L03EgJ07C,'
		cSelo += 'L0F8gJ01F,K01F001FF03IFCIF00KFE03F0F8,K03C007FFC3IFCIFC0KFE07F03C,K07800IFC7IFCJF0JF7F0FE01E,'
		cSelo += 'K0F001IFE7IFCJF1JF3F1FC00F,J01E001F07E7IF9JF9IFE3F1F80078,J03C003F07E7E001F83F9F8003FBFI03C,'
		cSelo += 'J078003F8007E001F83F9F8001FFEI01E,J0FI03FF80FE001F81F9F8001FFEJ0F,I01EI03FFE0JF1F81FBIFC0FFCJ078,'
		cSelo += 'I03CI01IF8JF3F81FBIFC0FF8J03C,I078J0IF8JF3F03FBIFC0FF8J01E,I07K03FFCIFE3F03F3IF81FF8K0E,I0EL07FDFC003F03F3FI03FFCK07,'
		cSelo += '001EK081FDF8003F07F7FI07FFCK078,001CJ0FC0FDF8007F07E7EI07EFCK038,0038J0FC1F9F8007E1FE7EI0FCFEK01C,0038J0FE3F9IFE7IFC7IFDF87EK01C,'
		cSelo += '007K0JF3IFE7IF87KF87FL0E,007K07FFE3IFE7IF0LF07FL0E,00EK03FFC3IFEIFC0KFE03F8K07,00EL0FEgL07,01CgT038,'
		cSelo += '::018gT018,038gT01C,::03gV0C,:07gV0E,:::07K01980C0673118233818238F0F38K0E,07K0265926944B2C44A98422410848K0E,'
		cSelo += '07K026402A97710840ACB84229086L0E,07K03DC04A91F90C412CA4423E6C18K0E,03L04408E90C9244228A442216844K0C,03K039C1E2E7713887B89C43C10F78K0C,'
		cSelo += '038gT01C,:::01CgT038,::00EJ038E787073FE1C8AF1CF0839E39CI07,00EJ02494809C891528A8B2898051452I07,'
		cSelo += '007J022B48096092568A8A3994052451I0E,007J022B6809389E568A8A1F3C39E471I0E,0038I022944098892528A8A2926012451001C,'
		cSelo += '0038I03CF787178915E72F1E8A201139E001C,001CgR038,001EgR078,I0EM03F8gH07,I07M01FBgH0E,I078L01IF1E7A1EF2087F84L01E,'
		cSelo += 'I03CM0F7C12020033082046L03C,I01EM06FE1A42102308204AL078,J0EM03FF1A42104788204EL07,J07J01FE3FF13C2008488205BL0E,'
		cSelo += 'J078I03FE3FF1FFBIF8CF2391K01E,J03EI07FC7FC0E2V07C,J01FI0FF8FF81801F879C7C31F87C00F8,K07801FF1FF81803FCF39FE33FCFC00E,'
		cSelo += 'K03C03FF1FF030060CC7187370CCI0C,K01C03FEJ0300606C63833606E,L0803FDJ0300606C63FF360678,N01FB8I0380606C63FF36061C,'
		cSelo += 'O0F3CI018060CC6180360E0C,O077CJ0E271CC61C4339IC,O02FEJ07F3F8C60FC31F8FC,P07FJ01C0E0C203820E03,,:::::::::^FS'
	ElseIf At("SEDEX HOJE",cTransp) > 0		
		cSelo := '^FO20,20^GFA,2415,2415,23,,::::Y01IFE,W03NF,V07PF8,U07RF8,T07TF8,S03LF8007LF,R01JFEM01JFE,R07IFCP0JF8,Q01IFCR0IFE,'
		cSelo += 'Q0IFCT0IFC,P03FFEU01IF,P07FF8V07FF8,O01FFCX0FFE,O07FFY03FF8,O0FFCg0FFC,N03FFgG03FF,N07FCgH0FF8,M01FFgI03FE,M03FEgI01FF,'
		cSelo += 'M07F8gJ07F8,M0FFgK03FC,L01FEK01F80IF1FE00IF1E07C1FE,L03F8K07FE1IF1FFC0IF1F0F807F,L07FL0FFE1IF1FFE0IF1F1F803F8,L0FEK01F1F1FFE1FFE1IF0FBF001FC,'
		cSelo += 'K01FC03I01F0F1E003E1F1FI07FEI0FE,K03F81FE001F801E003E1F1FI07FCI07F,K07F03FFI0FF03FFC3E1F1FFE03F8I03F8,K07E078FI0FF83FFC3C1F3FFE03FJ01F8,'
		cSelo += 'K0FC0F878003FC3FFC7C1F3FFC07FK0FC,J01F80IFBF00FE3E007C1F3EI0FFK07E,J03F80IFBF043E3C007C3E3CI0FFK07F,J03F00F003F3C1E7C007C3E3C001FF8J03F,'
		cSelo += 'J07E00FJ03E3E7FFC7FFC7FFC3E7CJ01F8,J07E00F9F003FFC7FFCIF87FFC7C7CJ01F8,J0FC007FE001FF87FFCIF07FFCFC3EK0FC,J0F8001F8I07F07FFCFFC07FFDF83EK07C,'
		cSelo += 'I01F8gR07E,I01FgS03E,:I03FgS03F,I03EgS01F,:I07EgS01F8,I07CgT0F8,:::I0F8gT07C,:::I0F8J0330180CE6230467030471E1E7K07C,'
		cSelo += 'I0F8J04CB24D2896588953084482109K07C,I0F8J04C80552EE210815970845210CK07C,I0F8J07B809523F218825948847CD83K07C,I0F8K08811D2192488451488442D088J07C,'
		cSelo += 'I07CJ07383C5CEE2710F713887821EFK0F8,I07CgT0F8,::I07EgS01F8,I03EgS01F,:I03FgS01F,I01FJ071CF0E0E7FC3915E39E1073C738003E,I01FJ049290139122A5151651300A28A4003E,'
		cSelo += 'I01F8I04569012C124AD151473280A48A2007E,J0F8I0456D012713CAD15143E7873C8E2007C,J0FCI045288131124A51514524C0248A200FC,J07EI079EF0E2F122BCE5E3D14402273C00F8,'
		cSelo += 'J07EgQ01F8,J03FM07FgH03F,J03F8L03FAgG07F,J01F8L03F7gG07E,K0FCL01FFE3CF43DE410FF08L0FC,K07EM0CFC2404006610408CK01F8,K07FM05FE34842046104094K03F8,K03F8L07FE3FC4208F10409CK07F,'
		cSelo += 'K01FCI07FC7FC2FE401091040B6K0FE,L0FEI0FF8FFE3FF7IF19E4722J01FC,L07FI0FF8FF83803E0E39F0C3C1F003F8,L03F801FF1FF03007F1E73F8CFF3F007F,L01FC03FE3FE0600E198C70IC33I03E,'
		cSelo += 'M0FC07FC3FC0600C198C60ED81B8003C,M07803FCJ0600C0D8C7FED819E0018,M03001FBJ0300C0D8C7FED8187,P01F78I0300C198C600DC1818,Q0EFCI01C4E398C300CE713,'
		cSelo += 'Q04FEJ0FE7F18C1F8C7E3F,R0FEJ0381C10C0F0C1C0E,,::::::::^FS'
	ElseIf At("PAC",cTransp) > 0
		cSelo := '^FO20,20^GFA,2394,2394,21,,::001gSFE,007gTF8,01FgS03E,03CgT0F,03gU03,07gU038,06gU018,0EgU01C,0CgV0C,:0CP03FCJ06K0FFQ0C,0CP07FFCI0EJ03FFCP0C,'
		cSelo += '0CP07IFI0FJ07FFEP0C,0CP07IF801FI01IFCP0C,0CP07IFC01FI01FE3CP0C,0CP07C0FC01F8003FS0C,0CP07C07E03F8007ES0C,0CP07C03E03F8007CS0C,0CP07C03E07FC00FCS0C,'
		cSelo += '0CP07C03E07BC00F8S0C,0CP07C03E07BE00F8S0C,0CP07C07E0F9E00F8S0C,0CP07C07C0F1E01FT0C,0CP07C1FC1F1F01FT0C,0CP07IF81F0F01FT0C,0CP07IF01E0F81FT0C,0CP07FFE03E0F81FT0C,'
		cSelo += '0CP07FF803E0780FT0C,0CP07CI07E07C0F8S0C,0CP07CI07IFC0F8S0C,0CP07CI07IFE0F8S0C,0CP07CI0JFE07CS0C,0CP07CI0JFE07E004P0C,0CP07CI0F801F07F00EP0C,0CP07C001F001F03IFEP0C,'
		cSelo += '0CP07C001F001F81JFP0C,0CP07C003FI0F80IFEP0C,0CP07C003EI0F803FF8P0C,0CgI07CQ0C,0CgV0C,::::::::::::::::::0CK0330180CE6230467030471E1E7L0C,0CK04CB24D2896588953084482109L0C,'
		cSelo += '0CK04C80552EE210815970845210CL0C,0CK07B809523F218825948847CD83L0C,0CL08811D2192488451488442D088K0C,0CK07383C5CEE2710F713887821EFL0C,0CgV0C,::::::0CK071CF0E0E7FC3915E39E1073C738J0C,'
		cSelo += '0CK049290139122A5151651300A28A4J0C,0CK04569012C124AD151473280A48A2J0C,0CK0456D012713CAD15143E7873C8E2J0C,0CK045288131124A51514524C0248A2J0C,0CK079EF0E2F122BCE5E3D14402273CJ0C,0CgV0C,'
		cSelo += ':::0CP071E3CF43DE410FF08O0C,0CP04902404006610408CO0C,0CP045024842046104094O0C,0CP04583484208F10409CO0C,0CP0450220401091040B2O0C,0CP079E3CF7IF09E4722O0C,0CgV0C,:0CQ03EgI0C,0CQ01ECgH0C,'
		cSelo += '0CR0DEgH0C,:0CR03FgH0C,0CP0FE7F0F8Y0C,0EO01FCFE180CK01Q01C,06O01F9FC301F3BBE67CFO018,07O03F1F82031I236C68O038,03O03FI02021A27F682EO03,03CN03E8003021A27F6827O0F,01FN01DC001031A2206C618M03E,'
		cSelo += '007MFE0BE001FBF223E67CF1NF8,001MFE03EI070C220C23861MFE,,:::::::^FS'
	Endif		
	
	//-------------------------+
	// Quantidade de Etiquetas |
	//-------------------------+
	nVolume := IIF(SL1->L1_VOLUME == 0,1,SL1->L1_VOLUME)
		
	For _nX := 1 To nVolume
		
		//-----------------+
		// Codigo etiqueta |
		//-----------------+
		cEtq := '^XA' + CRLF
		cEtq += '^FX IMPRESSAO ETIQUETAS CORREIOS VIZCAYA ^FS' + CRLF
		cEtq += cSelo + CRLF
		cEtq += '^FO40,180^ADN,26,10^FDNF: ' + Alltrim(Str(Val(SL1->L1_DOC))) + '^FS' + CRLF
		cEtq += '^FO300,180^ADN,26,10^FDPEDIDO: ' + Alltrim(Str(Val(SL1->L1_XNUMECL))) + ' ^FS' + CRLF
		cEtq += '^FO600,180^ADN,26,10^FDPeso(g): ' + RetPrcUni(SL1->L1_PBRUTO,"L1_PBRUTO") + '^FS' + CRLF
		cEtq += '^FO300,220^ADN,26,10^FD' + Alltrim(SL1->L1_XTRACKI) + '^FS' + CRLF
		cEtq += '^FO140,240^BY3^BCN,130,N,N^FD' + Alltrim(SL1->L1_XTRACKI) + '^FS' + CRLF
		cEtq += '^FO40,390^ADN,26,10^FDNome Legivel:^FS' + CRLF
		cEtq += '^FO195,410^GB390,000,2^FS' + CRLF
		cEtq += '^FO40,430^ADN,26,10^FDDocumento:^FS' + CRLF 
		cEtq += '^FO330,430^ADN,26,10^FDRubrica:^FS' + CRLF
		cEtq += '^FO40,450^GB730,400,2^FS' + CRLF
		cEtq += '^FO40,450^GB165,30,30^FS' + CRLF
		cEtq += '^FO47,457^ADN,26,10^FR^FDDESTINATARIO:^FS' + CRLF 
		cEtq += '^FO440,457^ADN,26,10^FDVolume: ' + Alltrim(Str(_nX)) + "/" + Alltrim(Str(nVolume)) + '^FS' + CRLF
		cEtq += '^FO87,487^ADN,26,10^FD' + Alltrim(SL1->L1_XNOMDEST) + '^FS' + CRLF
		cEtq += '^FO87,517^ADN,26,10^FD' + Alltrim(SL1->L1_ENDENT) + ", " + Alltrim(SL1->L1_XENDNUM) + '^FS' + CRLF
		cEtq += '^FO87,547^ADN,26,10^FD' + Alltrim(SL1->L1_BAIRROE)+ '^FS' + CRLF
		//cEtq += '^FO47,543^ADN,26,10^FD' + Alltrim(SL1->L1_XCOMPLE) + '^FS' + CRLF
		cEtq += '^FO87,597^ADN,26,10^FD' + Transform(SL1->L1_CEPE,PesqPict("SA1","A1_CEP")) + ' ' + Alltrim(SL1->L1_MUNE) + '/' + Alltrim(SL1->L1_ESTE) + ' ^FS' + CRLF
		cEtq += '^FO87,627^BY3^BCN,110,N,N^FD' + Alltrim(SL1->L1_CEPE) + '^FS' + CRLF
		//cEtq += '^FO500,597^AØN,26,10^FDAR ^FS' + CRLF
		//cEtq += '^FO500,657^ADN,26,10^FDObs: ' + Alltrim(SL1->L1_XCOMPLE) + ' ^FS'  + CRLF
		aComple := MFatR02Me(Alltrim(SL1->L1_XCOMPLE))
		If Len(aComple) > 0
		 	nLComp	:= 657
			For nCompl := 1 To Len(aComple)
				If nCompl == 1
					cEtq += '^FO500,' + Alltrim(Str(nLComp)) + '^ADN,26,10^FDObs: ' + Alltrim(aComple[nCompl]) + ' ^FS'  + CRLF
				Else
					cEtq += '^FO500,' + Alltrim(Str(nLComp)) + '^ADN,26,10^FD     ' + Alltrim(aComple[nCompl]) + ' ^FS'  + CRLF
				EndIf	
				nLComp := nLComp + 30 
			Next nCompl	
		Else	
			cEtq += '^FO500,657^ADN,26,10^FDObs: ^FS'  + CRLF
		EndIf	
		cEtq += '^FO40,860^ADN,26,10^FDRemetente: ^FS' + CRLF
		cEtq += '^FO40,890^ADN,26,10^FD' + Alltrim(SM0->M0_NOMECOM) + ' - VIZCAYA^FS' + CRLF
		cEtq += '^FO40,920^ADN,26,10^FD' + Alltrim(SM0->M0_ENDCOB) + '^FS' + CRLF
		cEtq += '^FO40,950^ADN,26,10^FD' + Alltrim(SM0->M0_COMPCOB) + '^FS' + CRLF
		cEtq += '^FO40,980^ADN,26,10^FD' + Alltrim(SM0->M0_BAIRCOB) + '^FS' + CRLF
		cEtq += '^FO40,1010^ADN,26,10^FD' + Alltrim(SM0->M0_CEPCOB) + ' ' + Capital(Alltrim(SM0->M0_CIDCOB)) + ' - ' + SM0->M0_ESTCOB + '^FS' + CRLF
		cEtq += '^XZ'
		
		//--------------------------------+
		// Inicia a Impressao da Etiqueta |
		//--------------------------------+
		MscbPrinter("ZEBRA",cPorta,,,,,,,,,.T.)
				
		//-------------------------------+
		// Desativa Status da Impressora |
		//-------------------------------+
		//MscbChkStatus(.F.) 
	
		//----------------------------+
		// Ativa Status da Impressora |
		//----------------------------+
		MscbChkStatus(.T.)
	
		//-------------------------------+
		// Desativa Status da Impressora |
		//-------------------------------+
		//MscbChkStatus(.F.)
		
		//-------------------------------------+
		// Inicializa a montagem da impressora |
		//-------------------------------------+
		MscbBegin(1,3) 
		
		MSCBWrite(cEtq)
				
		//---------------------------------+
		// Finaliza a Imagem da Impressora |
		//---------------------------------+
		MscbEnd()
		
		//Aviso('',cEtq,{"Ok"},3)
		
	Next nVol		       
		
	//----------------------------------------+
	// Encerra a comunicacao com a Impressora |
	//----------------------------------------+
	MscbClosePrinter()
			
	RestArea(aArea)
Return Nil

/************************************************************************************/
/*/{Protheus.doc} SigR01Array

@description Seleciona as Notas conforme parametros. 

@author Bernard M. Margarido
@since 09/03/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function SigR01Array()
Local aArea		:= GetArea()
Local cAlias	:= GetNextAlias()
Local cQuery	:= ""

cQuery := "	SELECT " + CRLF 
cQuery += "		L1.L1_DOC, " + CRLF
cQuery += "		L1.L1_SERIE, " + CRLF
cQuery += "		L1.L1_XNUMECO, " + CRLF
cQuery += "		L1.L1_XNUMECL, " + CRLF
cQuery += "		L1.L1_CLIENTE, " + CRLF
cQuery += "		L1.L1_LOJA, " + CRLF
cQuery += "		L1.L1_MIDIA, " + CRLF
cQuery += "		A1.A1_NOME, " + CRLF
cQuery += "		L1.R_E_C_N_O_ RECNOSL1 " + CRLF
cQuery += "	FROM " + CRLF 
cQuery += "		" + RetSqlName("SL1") + " L1 " + CRLF
cQuery += "		INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = L1.L1_CLIENTE AND A1.A1_LOJA = L1.L1_LOJA AND A1.D_E_L_E_T_ = '' " + CRLF
cQuery += "		INNER JOIN " + RetSqlName("SZ8") + " Z8 ON Z8.Z8_FILIAL = '" + xFilial("SZ8") + "' AND Z8.Z8_NUMECO = L1.L1_XNUMECO AND Z8.Z8_STATUS = '04' AND Z8.D_E_L_E_T_ = '' " + CRLF
cQuery += "	WHERE " + CRLF
cQuery += "		L1.L1_FILIAL = '" + xFilial("SL1") + "' AND " + CRLF
cQuery += "		L1.L1_DOC <> '' AND " + CRLF 
cQuery += "		L1.L1_SERIE <> '' AND "

//-----------+
// Impressao |
//-----------+
If mv_par01 == 1 
	cQuery += "		L1.L1_MIDIA = '' AND " + CRLF
//-------------+	
// Reimpressao |
//-------------+	
ElseIf mv_par01 == 2
	cQuery += "		L1.L1_MIDIA = 'IMP' AND " + CRLF
EndIf	
cQuery += "		L1.D_E_L_E_T_ = '' " + CRLF
cQuery += "	ORDER BY L1.L1_XNUMECL DESC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->( Eof() )
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
	Return .F.
EndIf

aNotas := {}

While (cAlias)->( !Eof() )

	aAdd(aNotas,{ .F.								,;	// 1 . Marca se imprime nota
				  SigR01Cor((cAlias)->L1_MIDIA)		,; 	// 2 . Legenda Etiqueta
				  (cAlias)->L1_DOC					,;	// 3 . Numero da Nota Fiscal 
				  (cAlias)->L1_SERIE				,;	// 4 . Serie da Nota Fiscal
				  (cAlias)->L1_XNUMECO				,;	// 5 . Numero Pedido Cliente
				  (cAlias)->L1_XNUMECL				,; 	// 6 . Numero do Pedido e-Commerce
				  (cAlias)->L1_CLIENTE				,;	// 7 . Codigo do Cliente
				  (cAlias)->L1_LOJA					,;	// 8 . Loja do Cliente
				  (cAlias)->A1_NOME					,;	// 9 . Nome do Cliente
				  (cAlias)->RECNOSL1 				})	//10 . Registro
	
	(cAlias)->( dbSkip() )
EndDo

RestArea(aArea)
Return .T.

/************************************************************************************/
/*/{Protheus.doc} SigR01Cor

@description Retorna legenda da impressao

@author Bernard M. Margarido
@since 09/03/2017
@version undefined

@param cMidia	, characters	, descricao

@type function
/*/
/************************************************************************************/
Static Function SigR01Cor(cMidia)
Local aArea	:= GetArea()

Local oNewPrt	  	:= LoadBitmap( GetResources(),"BR_VERDE")		// Bitmap 	
Local oReimp  		:= LoadBitmap( GetResources(),"BR_VERMELHO")	// Bitmap
Local oRet			:= Nil

If Empty(cMidia)
	oRet := oNewPrt
Else
	oRet := oReimp
EndIf
 
Return oRet

/*******************************************************************/
/*/{Protheus.doc} RetPrcUni

@description Formata valor para envio ao eCommerce

@author Bernard M. Margarido
@since 13/02/2017
@version undefined

@param nVlrUnit, numeric, descricao

@type function
/*/
/*******************************************************************/
Static Function RetPrcUni(nVlrUnit,cCpoDec) 
Local nDecimal	:= TamSx3(cCpoDec)[2]
Local cValor	:= ""
Local cVlrUnit	:= Alltrim(Str(nVlrUnit))
Local aValor	:= {}

If At(".",cVlrUnit) > 0
	aValor := Separa(cVlrUnit,".")
	cValor := aValor[1] + PadR(aValor[2],nDecimal,"0")
Else
	cValor := cVlrUnit + StrZero(0,nDecimal)
EndIf

Return cValor

/******************************************************************************/
/*/{Protheus.doc} MFatR02Me

@description Formata campo memo pra impressão

@author Bernard M. Margarido

@since 07/06/2017
@version undefined

@param cMemo, characters, descricao

@type function
/*/
/******************************************************************************/
Static Function MFatR02Me(cMemo)
Local aMensagem	:= {}
Local nLin		:= 1
cAux := cMemo
While !Empty(cAux)
	If nLin <= MAXMSG
		aAdd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	Else
		cAux := ""
	EndIf
	nLin++	
EndDo

Return aMensagem

/***************************************************************************************************/
/*/{Protheus.doc} EspacoAt

@description Pega uma posição (nTam) na string cString, e retorna o caractere de espaço anterior.

@author TOTVS

@since 07/06/2017
@version undefined

@param cString, characters, descricao
@param nTam, numeric, descricao

@type function
/*/
/***************************************************************************************************/
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

//--------------------------------------------------------------------------+
// Caso a posição (nTam) for maior que o tamanho da string, ou for um valor |
// inválido, retorna 0.                                                     |
//--------------------------------------------------------------------------+ 
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

//-------------------------------------------------------------------------+
// Procura pelo caractere de espaço anterior a posição e retorna a posição |
// dele.                                                                   |
//-------------------------------------------------------------------------+
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

//--------------------------------------------------------------+
// Caso não encontre nenhum caractere de espaço, é retornado 0. |
//--------------------------------------------------------------+
nRetorno := 0

Return nRetorno

/************************************************************************************/
/*/{Protheus.doc} AjustaSx1

@description Cria parametros do relatorio

@author Bernard M. Margarido
@since 09/03/2017
@version undefined
@param cPerg		, characters, Codigo do parametros
@type function
/*/
/*************************************************************************************/
Static Function AjustaSx1(cPerg)

	Local aHlpPor01 := {"Tipo de Etiqueta"}
	
	PutSx1(cPerg, "01", "Tp. de Etiqueta?", "Tp. de Etiqueta?", "Tp. de Etiqueta?", "MV_CH1", "C", 1, 0, 0, "C",,"   ", , , "MV_PAR01", "Impressao ", , , , "Reimpressao", , , , "Ambos", , , , , , , , aHlpPor01, aHlpPor01, aHlpPor01)
	
Return .T.

