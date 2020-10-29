#include "Protheus.ch"
User Function TesteF1Dana()
	Private cCadastro
	Private aRotina

 	cCadastro := "Dados NF"
	aRotina := {{"Dados NF" ,"U_PeDanaSF1",0,4}}; 
				
	MBrowse(6, 1, 22, 75, "SF2") 

return                                


User Function PeDanaSF1(cAlias, nReg, nOpc)

	Local oPanel01
	Local oPanel02     
	Local oBut1
	Local oBut2       
    
    Local oDlg         
                                   
    Local cCliente  := POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")      
    Local cCodTrans := SF2->F2_TRANSP
    Local cTransp	:= POSICIONE("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")
    Local nQtdVol	:= SF2->F2_VOLUME1
    Local cEspecie	:= SF2->F2_ESPECI1
    Local cSUFRAMA  := POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_SUFRAMA")                      
    Local lSUFRAMA 	:= !Empty(cSUFRAMA)
//    Local dDtSaida  := dDatabase
    Local dDtSaida  := SF2->F2_DTDANFE
          
    Local lOk := .F.                          
    
    Local aPeso 
    /*
    If Empty(cEspecie)
    	cEspecie:= "CXS   "
    Endif
    */
    cEspecie:= "CXS   "
        	
	cSUFRAMA := SF2->F2_SUFRAMA

	   	If Empty(dDtSaida)     //Data de Saída impressa na Danfe
		    dDtsaida := dDatabase
		    Else
		    dDtsaida := SF2->F2_DTDANFE
        Endif

	DEFINE FONT oFnt15 NAME "ARIAL" SIZE 0,-15 BOLD                           
	DEFINE FONT oFnt20 NAME "ARIAL" SIZE 0,-20 BOLD 
    
    
    DEFINE MSDIALOG oDlg TITLE "Informações Nota Fiscal" FROM 000,000 TO 550,780 of oMainWnd PIXEL
			
		
		oPanel01 := TPanel():New(0,0, , oDlg,oFnt20, .T.,,,RGB(250,255,250), 5, 70, .T.)
	 	oPanel01:Align := CONTROL_ALIGN_TOP
	  	oPanel02 := TPanel():New(0,0, , oDlg,oFnt15, .T.,,,RGB(250,255,250), 30,40 , .T.)
	  	oPanel02:Align := CONTROL_ALIGN_ALLCLIENT	
	                                                                       
	   	//Panel 01
	   	@ 020,020 SAY "NF:" of oPanel01 Pixel        
	   	@ 020,060 SAY SF2->F2_DOC of oPanel01 Pixel
	   	@ 020,120 SAY "Série:" of oPanel01 Pixel
	   	@ 020,160 SAY SF2->F2_SERIE of oPanel01 Pixel
	   	@ 040,020 SAY "Cliente:" of oPanel01 Pixel                
	   	@ 040,060 SAY cCliente of oPanel01 Pixel                                                            
	   	
	   	
	   	//Panel 02  
	   	@ 020,020 SAY "Cód. Transp.:" of oPanel02 Pixel
	   	@ 020,090 MsGet cCodTrans Size 060,010 F3 "SA4" Valid ValidTrans(cCodTrans,@cTransp) of oPanel02 Pixel 
	   	@ 050,020 SAY "Transportadora:" of oPanel02 Pixel
	   	@ 050,090 MsGet cTransp Size 200,010 When .F. of  oPanel02 Pixel 
	   	@ 080,020 SAY "Qtde Volumes:" of oPanel02 Pixel
	   	@ 080,090 MsGet nQtdVol Size 060,010 Picture PesqPict("SF2","F2_VOLUME1") of oPanel02 Pixel 
	   	@ 110,020 SAY "Espécie:" of oPanel02 Pixel                                                  
	   	@ 110,090 MsGet cEspecie Size 060,010 /*Picture PesqPict("SF2","F2_ESPECIE1")*/ Valid ValiEspecie(cEspecie) of oPanel02 Pixel 
	   	@ 140,020 SAY "PIN Suframa:"  of oPanel02 Pixel
	   	@ 140,090 MsGet cSUFRAMA Size 060,010 When lSUFRAMA of oPanel02 Pixel  
	   	@ 170,020 SAY "Data Saída:" of oPanel02 Pixel                                                  
	   	@ 170,090 MsGet dDtSaida Size 060,010 Picture Substr(Strzero(Day(dDtSaida),2,0) ,1,2)+"/"+Substr(Strzero(Month(dDtSaida),2,0) ,1,2)+"/"+Substr(Strzero(Year(dDtSaida),4,0) ,1,4) of oPanel02 Pixel 	   	
	    
	                                                                        
  		DEFINE SBUTTON oBut1 FROM 250, 320 TYPE 2 ACTION ( oDlg:End() )  ENABLE of oDlg  //Cancel
		DEFINE SBUTTON oBut2 FROM 250, 280 TYPE 1 ACTION ( lOk := .T., oDlg:End() )  ENABLE of oDlg //Ok
	   
	ACTIVATE MSDIALOG oDlg CENTERED
                                                                      
    If lOk
    	If ApMsgYesNo("Deseja alterar os dados da nota fiscal?")
    		
    		aPeso := CalcPeso()
    		
    		RecLock("SF2",.F.)
    			SF2->F2_TRANSP	:= cCodTrans      
    			SF2->F2_VOLUME1 := nQtdVol      
    			SF2->F2_ESPECI1 := UPPER(cEspecie)
    			SF2->F2_SUFRAMA := cSUFRAMA
    			SF2->F2_DTDANFE := dDtsaida
    		SF2->(MsUnlock())
    	EndIf 	
    EndIf 

return                                                        

Static Function	ValidTrans(cCod,cTrans) 
	
	SA4->(dbSetOrder(1))
	If SA4->(dbSeek(xFilial("SA4")+cCod)) .Or. Empty(cCod)   
		cTrans := SA4->A4_NOME
		return .T.
	Else
		Alert("Transportadora não encontrada.")
	EndIf
	
return .F. 
                  
Static Function ValiEspecie(cEspecie)
	Local nX
	Local nASCII
	
	cEspecie := Alltrim(UPPER(cEspecie))
	           
	For nX := 1 to len(cEspecie)
		nASCII := ASC(SubStr(cEspecie,nX,1))
		If nASCII < 65 .OR. nASCII > 90
			Alert("O campo especie deve conter apenas caracteres.")
			return .F.
		EndIf
	Next    

return .T.

Static Function CalcPeso()
	Local aAux := {0,0}
	Local aSB1 := SB1->(GetArea())    
    Local aSD2 := SD2->(GetArea())
    Local cFilSD2 := xFilial("SD2")     
    Local nPLiqui := 0
    Local nPBruto := 0	
    
    SD2->(dbSetOrder(3))
    SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE ))
                                                                  
    SB1->(dbSetOrder(1))
                                    
    While SD2->(!EOF()) .AND. SD2->D2_FILIAL == cFilSD2 .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE
        If SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
	    	nPLiqui := SB1->B1_PESO
	    	nPBruto := SB1->B1_PESBRU
		Else //Apenas, por ventura, para nao dar erro no código, se o produto está no SD2 existe no SB1
			nPLiqui := 0
			nPBruto := 0                                                      
		EndIf
		
		aAux[1] += nPLiqui * SD2->D2_QUANT
		aAux[2] += nPBruto * SD2->D2_QUANT
		
		SD2->(dbSkip())
	EndDo
	
	RestArea(aSB1)
	RestArea(aSD2)
return aClone(aAux)                   


