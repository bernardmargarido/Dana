#include "rwmake.ch"       
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"                                                                            
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DWDFPC    ¦Autor ¦ Clayton Martins    ¦ Data ¦ 28/06/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Workflow de Pedido de Compras.                             ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Perfumes Dana						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function DNWFPC()

Conout("["+DtoC(Date())+" "+Time()+"]: Iniciando Processo de Envio de E-mail para Aprovação de Pedidos de Compra " )

U_WKFPC(1)  		// 1 - ENVIO PC PARA APROVADORES

Conout("["+DtoC(Date())+" "+Time()+"]: Finalizando Processo de Envio de E-mail para Aprovação de Pedidos de Compra " )

Return
   	
User Function WKFPC(_nOpc, oProcess)
	
Local _lProcesso := .F.
Local _cFilial, _cChaveSCR
Local _cAprov    	:= "" , cObs 		:= ""
Local nTotal    	:= 0 , 	cGrupo	 	:= "" , lLiberou	:= .F.
Local i, j, _cItem
Local _nRecnoSCR 	:= 0

Private _aReturn
Private _aWF 	:= {}   
Private _aSC7   := {}
Private _aSCR   := {}

DO 	CASE 

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1 - Prepara os pedidos a serem enviados para aprovacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

	CASE _nOpc == 1

		Conout("1 - Prepara os pedidos a serem enviados para aprovacao")
		Conout("1 - EmpFil:" + cEmpAnt + cFilAnt)
		
	  	_cQuery := ""
	  	_cQuery += " SELECT"
	  	_cQuery += " CR_FILIAL," 
	  	_cQuery += " CR_TIPO,"   
	  	_cQuery += " CR_NUM,"
	  	_cQuery += " CR_NIVEL," 
	  	_cQuery += " CR_TOTAL," 
	  	_cQuery += " CR_USER,"   
	  	_cQuery += " CR_APROV,"   
	  	_cQuery += " CR_XDTLIM,"
	  	_cQuery += " CR_XHRLIM"
	  	_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
	  	_cQuery += " WHERE "
	  	_cQuery += "     CR_FILIAL = '" + xFilial("SCR") + "'"
	  	_cQuery += " AND CR_TIPO = 'PC'" 
	  	_cQuery += " AND CR_STATUS = '02'"  						// Em aprovacao
	  	_cQuery += " AND CR_XDTLIM  <= '" + DTOS(MSDATE()) + "'"	// Data Limite
	  	_cQuery += " AND CR_WF = ' '"
	  	_cQuery += " AND SCR.D_E_L_E_T_ = ' '"
	  	_cQuery += " ORDER BY"
	  	_cQuery += " CR_FILIAL," 
	  	_cQuery += " CR_NUM,"
	  	_cQuery += " CR_NIVEL,"
	  	_cQuery += " CR_USER"
	  	
		TcQuery _cQuery New Alias "TMP"
		
		dbGotop()    
		_aSCR   := {}
		
		While !TMP->(Eof())
			_cFilial   := TMP->CR_FILIAL
			_cTipo     := TMP->CR_TIPO
			_cNumPC    := TMP->CR_NUM
			_cAprov    := TMP->CR_USER

			Aadd(_aSCR, {_cFilial,_cTipo,_cNumPC,_cAprov})

			TMP->(DBSkip())           
		End
			
		dbSelectArea("TMP")
		dbCloseArea()

		If Len(_aSCR) > 0
			For i := 1 to Len(_aSCR)
				DBSelectarea("SCR")
				DBSetOrder(2)
				DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4])

				DBSelectArea("SC7")
				DBSetOrder(1)
				DBSeek(xFilial("SC7")+Substr(_aSCR[i][3],1,6))

				IF EMPTY(SC7->C7_APROV)
					DBSelectarea("SCR")
					DBSetOrder(2)
					IF DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4])
						Reclock("SCR",.F.)
						SCR->CR_WF			:= "1" 		 // Status 1 - envio para aprovadores / branco-nao houve envio
			  			SCR->CR_XWFID		:= "N/D"	 // Rastreabilidade
						MSUnlock()
					ENDIF	
				ELSE 	                 
//						_nRecnoSCR := SCR->(Recno())
					_aWF	 		:= U_EnviaPC(SCR->CR_FILIAL, SCR->CR_NUM, SCR->CR_USER , SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) , SCR->CR_TOTAL, SCR->CR_XDTLIM, SCR->CR_XHRLIM, _nOpc)
					If Len(_aWF) >  0
						_lProcesso 	:= .T.
						DBSelectarea("SCR")
						DBSetOrder(2)
						If SCR->(DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4]))
							Reclock("SCR",.F.)
							SCR->CR_WF			:= IIF(EMPTY(_aWF[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
			  				SCR->CR_XWFID		:= _aWF[1]		// Rastreabilidade
							SCR->CR_XDTLIM		:= _aWF[2]		// Data Limite
							SCR->CR_XHRLIM		:= _aWF[3]		// Hora Limite
							MSUnlock()     
						Endif
					Endif			
				ENDIF
			Next i
		End
		
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³2 - Processa O RETORNO DO EMAIL                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
	CASE _nOPC	== 2

		Conout("2 - Processa O RETORNO DO EMAIL")
		Conout("2 - EmpFil:" + cEmpAnt + cFilAnt)

		Conout("2 - Semaforo Vermelho" )
		nWFPC2 		:= U_Semaforo("WFPC2")

		//Abre a primeira empresa
		RpcSetType(3)
		
		If FindFunction('WFPREPENV')
			WfPrepENV(cEmpAnt, cFilAnt)
		Else
			Prepare Environment Empresa cEmpAnt Filial cFilAnt
		EndIf    

		__cChaveSCR	:= oProcess:oHtml:RetByName("CHAVE")
		_cAprov    	:= alltrim(oProcess:oHtml:RetByName("CR_USER"))
		_cChaveSCR	:= Padr(__cChaveSCR,60)+_cAprov
		cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))
		cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
		cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))

		oProcess:Finish() // FINALIZA O PROCESSO
		
		Conout("2 - cFilAnt    :" + cFilAnt)
		Conout("2 - __cChaveSCR:" + __cChaveSCR)
		Conout("2 - Opc        :" + cOpc)
		Conout("2 - Obs        :" + cObs)
		Conout("2 - WFId       :" + cWFID)
		Conout("2 - _cAprov    :" + _cAprov)
//			conout("2 - _cChaveSCR :" + _cChaveSCR)

		IF cOpc $ "S|N"  // Aprovacao S-Sim N-Nao
			// Posiciona na tabela de Alcadas 
			DBSelectArea("SCR")
			DBSetOrder(2)
			DBSeek(__cChaveSCR)  // BR153301PC000014                                      000000
			IF !FOUND()  
				Conout("2 - Processo nao encontrado : Not Found")
				Conout("2 - Semaforo Verde" )
				U_Semaforo(nWFPC2)
				Return .T.
			Endif
			If ALLTRIM(SCR->CR_XWFID) <> ALLTRIM(cWFID)
				Conout("2 - Processo nao encontrado :" + cWFID + " Processo atual :" + SCR->CR_XWFID)
				Conout("2 - Semaforo Verde" )
				U_Semaforo(nWFPC2)
				Return .T.
			ENDIF
			
			Reclock("SCR",.F.)
			SCR->CR_WF		:= "2"			// Status 2 - respondido
			MSUnlock()
			
			If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS$"03#04#05"
				conout("2 - Processo ja respondido via sistema :" + cWFID)
				conout("2 - Semaforo Verde" )
				U_Semaforo(nWFPC2)             
				conout("2 - 1" )
				Return .T.
			EndIf

			// Verifica se o pedido de compra esta aprovado
			// Se estiver, finaliza o processo
			dbSelectArea("SC7")
			dbSetOrder(1)
			SC7->(dbSeek(xFilial("SC7")+LEFT(SCR->CR_NUM,6)))

			IF SC7->C7_CONAPRO <> "B"  // NAO ESTIVER BLOQUEADO
				conout("2C - Processo ja respondido via sistema :" + cWFID)
				conout("2C - Semaforo Verde" )
				U_Semaforo(nWFPC2)
				conout("2 - 2" )
				Return .T.
			ENDIF

			// REPosiciona na tabela de Alcadas 
			DBSelectArea("SCR")
			DBSetOrder(2)
			DBSeek(__cChaveSCR)
			
			// verifica quanto a saldo de alçada para aprovação				
			// Se valor do pedido estiver dentro do limite Maximo e minimo 
			// Do aprovador , utiliza o controle de saldos, caso contrário nao
			// faz o tratamento como vistador.

			nTotal := SCR->CR_TOTAL
			
			lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,SCR->CR_APROV,,SC7->C7_APROV,,,,,cObs},msdate(),If(cOpc=="S",4,6))
			
			conout("2 - Liberado :" + IIF(lLiberou, "Sim", "Nao"))

			_lProcesso := .T.
			
			If lLiberou
				dbSelectArea("SC7")
				dbSetOrder(1)
				dbSeek(xFilial("SC7")+LEFT(SCR->CR_NUM,6))
		        While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == SCR->CR_FILIAL+LEFT(SCR->CR_NUM,6)
	                Reclock("SC7",.F.)
	                SC7->C7_CONAPRO 	:= "L"
	                MsUnlock()
	                dbSkip()
		        EndDo
			EndIf
		EndIf				

		conout("2 - Semaforo Verde" )
		U_Semaforo(nWFPC2)

		//Chama os envios de alerta
		U_WKFPC(3)  		// 3 - ENVIO PC ITENS APROVADOS PARA COMPRADOR
		U_WKFPC(4)  		// 4 - ENVIO PC ITENS REPROVADOS PARA COMPRADOR
		U_DNWFPC()			//Chama novos envios

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³3 - Envia resposta de pedido aprovado para o comprador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

	CASE _nOpc == 3

		RpcSetType(3)
		
		If FindFunction('WFPREPENV')
			WfPrepENV(cEmpAnt, cFilAnt)
		Else
			Prepare Environment Empresa cEmpAnt Filial cFilAnt
		EndIf    

		__cChaveSCR	:= oProcess:oHtml:RetByName("CHAVE")
		_cAprov    	:= alltrim(oProcess:oHtml:RetByName("CR_USER"))
		_cChaveSCR	:= Padr(__cChaveSCR,60)+_cAprov
		cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))
		cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
		cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))

		oProcess:Finish() // FINALIZA O PROCESSO	     
		
		DBSelectArea("SCR")
		DBSetOrder(2)
		DBSeek(__cChaveSCR)

		conout("3 - Envia resposta de pedido APROVADO para o comprador")
		conout("3 - EmpFil:" + cEmpAnt + cFilAnt)
	  	_cQuery := ""
	  	_cQuery += " SELECT DISTINCT "
	  	_cQuery += " C7_FILIAL," 
	  	_cQuery += " C7_NUM,"
	  	_cQuery += " C7_TIPO,"   
	  	_cQuery += " C7_USER"   
	  	_cQuery += " FROM " + RetSqlName("SC7") + " SC7"
	  	_cQuery += " WHERE SC7.D_E_L_E_T_ <> '*'"
	  	_cQuery += " AND C7_NUM   = '" + SCR->CR_NUM + "'"
	  	_cQuery += " AND C7_FILIAL   = '" + xFilial("SC7") + "'"
		_cQuery += " AND C7_TIPO=1 "				 	// 1-Pedido de compra 
		_cQuery += " AND C7_CONAPRO='L' "				// Liberado
		_cQuery += " AND C7_APROV <> '      ' "			// Grupo Aprovador
	  	_cQuery += " AND C7_XWF <> '1'"	      			// 1 Enviado EMAIL
	  	_cQuery += " ORDER BY"
	  	_cQuery += " C7_FILIAL," 
	  	_cQuery += " C7_NUM"
		TcQuery _cQuery New Alias "TMP"	

		dbGotop()
		_aSCR   := {}
		
		While !TMP->(Eof())
			_cFilial    := TMP->C7_FILIAL
			_cTipoDoc   := Iif(TMP->C7_TIPO = 1,"PC","AE")
			_cNum    	:= TMP->C7_NUM   
			_cUser 		:= TMP->C7_USER
			Aadd(_aSCR, {_cFilial,_cTipoDoc,_cNum, _cUser})
			TMP->(DBSkip())           
		End

		dbSelectArea("TMP")
		dbCloseArea()

		If Len(_aSCR) > 0
			For i := 1 to Len(_aSCR)
				DBSelectarea("SCR")
				DBSetOrder(1)
				DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3],.T.)
				_lAchou  := .F.
				_lAprov	:= .F.
				_cChave	:= ''
				_nTotal	:= 0
				While !SCR->(EOF()) 					.AND. ;
    		   	SCR->CR_FILIAL		== _aSCR[i][1]  	.AND. ;
      			SCR->CR_TIPO 	    == _aSCR[i][2]		.AND. ;
        		SCR->CR_NUM         == Padr(_aSCR[i][3],50)
	        		IF SCR->CR_STATUS == '03' .AND. !EMPTY(SCR->CR_LIBAPRO)   // SOMENTE CASO APROVADO
	    				_cChave	:= SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)
    					_lAprov	:= .T.
						_lAchou  := .T.        				
    					_nTotal	:= SCR->CR_TOTAL
    				ENDIF
	        		SCR->(DBSkip())
					IF !_lAchou
						DBSelectarea("SC7")
						DBSetOrder(1)
						IF DBSeek(_aSCR[i][1]+_aSCR[i][3])
							While C7_FILIAL == _aSCR[i][1] .AND. C7_NUM == _aSCR[i][3] .and. !SC7->(Eof())
								Reclock("SC7",.F.)
								SC7->C7_XWF			:= "1"   	                        // Status 1 - envio email
				  				SC7->C7_XWFID		:= "N/D"   									// Rastreabilidade
								MSUnlock()
								SC7->(DbSkip())                       
							Enddo
						ENDIF
					ENDIF
					_nRecnoSCR := SCR->(Recno())
		    		IF _lAprov
		    			__cChaveSCR	:= oProcess:oHtml:RetByName("CHAVE")
						// REPosiciona na tabela de Alcadas 
						DBSelectArea("SCR")
						DBSetOrder(2)
						DBSeek(__cChaveSCR)
						_aSCR[i][3]	:= SCR->CR_NUM
						_aWF:= U_EnviaPC(_aSCR[i][1], _aSCR[i][3], _aSCR[i][4] , _cChave, _nTotal, ctod('  /  /  '), '     ',_nOpc)
						SCR->(dbGoto(_nRecnoSCR))
						If Len(_aWF) > 0 
							_lProcesso 	:= .T.
	
							DBSelectarea("SC7")
							DBSetOrder(1)
							IF DBSeek(_aSCR[i][1]+_aSCR[i][3])
								While C7_FILIAL == _aSCR[i][1] .AND. C7_NUM == _aSCR[i][3] .and. !SC7->(Eof())
									conout("EnvPCFor - While SC7" )						
									Reclock("SC7",.F.)
									SC7->C7_XWF			:= IIF(EMPTY(_aWF[1]), " ", "1")   	// Status 1 - envio email / branco -nao enviado
						  			SC7->C7_XWFID		:= _aWF[1]							// Rastreabilidade
									MSUnlock() 
									SC7->(DbSkip())
								Enddo	
							ENDIF
						END
					ENDIF
				Enddo
			Next i
		END

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³4 - Envia resposta de pedido bloqueado para o comprador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
	CASE _nOpc == 4

		conout("4 - Envia resposta de pedido bloqueado para o comprador")
		conout("4 - EmpFil:" + cEmpAnt + cFilAnt)
		
	  	_cQuery := ""
	  	_cQuery += " SELECT"
	  	_cQuery += " CR_FILIAL," 
	  	_cQuery += " CR_TIPO,"   
	  	_cQuery += " CR_NUM,"    
	  	_cQuery += " CR_NIVEL," 
	  	_cQuery += " CR_TOTAL," 
	  	_cQuery += " CR_USER,"   
	  	_cQuery += " CR_APROV"    
	  	_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
	  	_cQuery += " WHERE SCR.D_E_L_E_T_ <> '*'"
	  	_cQuery += " AND CR_FILIAL = '" + xFilial("SCR") + "'"
	  	_cQuery += " AND CR_LIBAPRO <> '      '" 							// Seleciona o Aprovador que reprovou
	  	_cQuery += " AND CR_STATUS = '04'"                          // REPROVADO
	  	_cQuery += " AND (CR_TIPO = 'PC' OR CR_TIPO = 'AE')"                            // PEDIDO DE COMPRA
	  	_cQuery += " AND CR_WF <> '1'"	      					    	// 1-Enviado
//		  	_cQuery += " AND CR_NUM = '012135'"
	  	
	  	_cQuery += " ORDER BY"
	  	_cQuery += " CR_FILIAL," 
	  	_cQuery += " CR_NUM,"
	  	_cQuery += " CR_NIVEL,"
	  	_cQuery += " CR_USER"
	  	
		TcQuery _cQuery New Alias "TMP"
	                            
		dbGotop()
		_aSCR   := {}

		While !TMP->(Eof())
			_cFilial   := TMP->CR_FILIAL
			_cTipo     := TMP->CR_TIPO
			_cNumPC    := TMP->CR_NUM
			_cAprov    := TMP->CR_USER

			Aadd(_aSCR, {_cFilial,_cTipo,_cNumPC,_cAprov})

			TMP->(DBSkip())           
		End

		dbSelectArea("TMP")
		dbCloseArea()

		If Len(_aSCR) > 0
			For i := 1 to Len(_aSCR)
				DBSelectarea("SCR")
				DBSetOrder(2)
				DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4])

				DBSelectArea("SC7")
				DBSetOrder(1)
				DBSeek(xFilial("SC7")+Substr(_aSCR[i][3],1,6))

				IF EMPTY(SC7->C7_APROV)
					DBSelectarea("SCR")
					DBSetOrder(2)
					IF DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4])
						Reclock("SCR",.F.)
						SCR->CR_WF			:= "1" 		 	// Status 1 - envio para aprovadores / branco-nao houve envio
			  			SCR->CR_XWFID		:= "N/D"		   // Rastreabilidade
						MSUnlock()
					ENDIF	
				ELSE 				

					_aWF	 		:= U_EnviaPC(SCR->CR_FILIAL, SCR->CR_NUM, SC7->C7_USER , SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV) , SCR->CR_TOTAL, ctod('  /  /  '), '     ', _nOpc)
	
					DBSelectarea("SCR")
					DBSetOrder(2)
					If SCR->(DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4]))
						Reclock("SCR",.F.)
						SCR->CR_WF			:= IIF(EMPTY(_aWF[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
			  			SCR->CR_XWFID		:= _aWF[1]							// Rastreabilidade
						MSUnlock()
					ENDIF
				ENDIF		
				_lProcesso := .T.
			Next i								
		End
		
END CASE			

IF 	_lProcesso 
	conout(" Mensagem processada " )
ELSE
	conout(" Nao houve processamento")
ENDIF	
				
RETURN
	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EnviaPC   ºAutor  ³Microsiga           º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER Function EnviaPC(_cFilial,_cNum, _cUser, _cChave, _nTotal, _dDTLimit, _cHRLimit, _nOpc)
//	Local _cHttp		:= GetNewPar("MV_WFDHTTP", "http://189.20.203.131:9898")

	Local _cTo	   		:= IIF(_nOpc == 1, _cUser , UsrRetMail(_cUser))
	Local _cEmail		:= UsrRetMail(_cUser)
	Local _cNome		:= UsrFullName(_cUser)
	Local _nDD   	  	:= GetNewPar("MV_WFTODD", 0)		// TimeOut - Dias
	Local _cTimeOut		:= GetNewPar("MV_WFTOPC","24:00")
	Local _dDataLib		:= IIF( !EMPTY(_dDTLimit), _dDTLimit, MSDATE() )
	Local _cHoraLib		:= IIF( !EMPTY(_cHRLimit), _cHRLimit, LEFT(TIME(),5) )
	Local _nTimeOut  	:= (_nDD * 24) + VAL(LEFT(_cTimeOut,2)) + (VAL(RIGHT(_cTimeOut,2))/60) 
	Local _nVrSC		:= 0
    Local _cUnidReq		:= ""  
    Local _aAreaSM0		:= {}

	Local _nVALMERC		:= 0
	Local _nVALIPI		:= 0
	Local _nFRETE		:= 0
	Local _nSEGURO		:= 0
	Local _nDESCONTO	:= 0   
	Local _nDESPESA		:= 0   	
	Local _nVALTOT		:= 0
	Local _lPedidos		:= .F.
	Local _lCotacao 	:= .F.
	Local _lSolics 		:= .F.
    Local _cTipoDoc		:= ''
   	Local _lRateio 		:= .F.
	Local j
	Local cPathHTML     := GetMV("MV_PATHHTM",,"\WORKFLOW\HTML\")
	Local cServWKF      := GetMV("MV_WFDHTTP",,"http://187.94.58.102:1346") + "/emp" + SM0->M0_CODIGO + "/wfpc/"
	Local cPathFile     := "\workflow\emp"+cEmpAnt+"\wfpc\"
	Local cIpServ		:= "http://187.94.58.102:1346/emp" + SM0->M0_CODIGO + "/wfpc/"

	_aTimeOut	:= U_GetTimeOut(_nTimeOut,_dDATALIB,_cHoraLib)
	Private _aPedidos:= {}       
	Private oHtml

	//------------------- VALIDACAO
	_lError := .F.

	DbSelectArea("SC7")

	If Empty(_cTo)
		aMsg := {}
		cTitle  := "Administrador do Workflow : NOTIFICACAO" 
		aADD(aMsg , REPLICATE('*',80) )
		aADD(aMsg , Dtoc(MSDate()) + " - " + Time() + ' * Ocorreu um ERRO no envio da mensagem :' )
		aADD(aMsg , "Pedido de Compra No: " + _cNum + " Filial : " + cFilAnt + " Usuario : " + UsrRetName(_cUser) )
		aADD(aMsg , "Campo EMAIL do cadastro de usuario NAO PREENCHIDO" )
		aADD(aMsg , REPLICATE('*',80) )
		
		_lError := .T.
	Endif
                  
	IF _lError
		U_NotifyAdm(cTitle, aMsg)
		_aReturn := {}
		AADD(_aReturn, "")
		AADD(_aReturn, _aTimeOut[1])
		AADD(_aReturn, _aTimeOut[2])
		
		RETURN _aReturn
	ENDIF

	// ----- FIM DA VALIDACAO
              
//	_cChaveSCR	:= PADR(_cFilial + 'PC' + _cNum,60) 
//					SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)
	_cChaveSCR	:= PADR(Substr(_cChave,1,12),60)
	_cNum 		:= PADR(ALLTRIM(_cNum),6)

	DBSelectArea("SCR")
	DBSetOrder(2)
	DBSeek(_cChave)

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(cEmpAnt+cFilAnt)
	
	DBSelectArea("SC7")
	DBSetOrder(1)
	DBSeek(_cFilial+_cNum)

    DBSELECTAREA("SC3")
	DBSetOrder(1)
	DBSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC))     

	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
	_cFornece := SC7->C7_FORNECE
	_cLojaFor := SC7->C7_LOJA

	DBSelectArea("SE4")
	DBSetOrder(1)
	DBSeek(xFilial("SE4")+SC7->C7_COND)

	DBSelectArea("SAL")
	DBSetOrder(3)
	DBSeek(xFilial("SAL")+SC7->C7_APROV+SCR->CR_APROV)

	_cVersao := ""
	DBSelectArea("SCY")
	DBSetOrder(1)
	DBSeek(_cFilial+_cNum) 
	
	While SCY->CY_FILIAL + SCY->CY_NUM == _cFilial+_cNum .AND. !SCY->(EOF())
		_cVersao := Alltrim(SCY->CY_VERSAO)
		SCY->(DbSkip())
	Enddo

	_cTipoDoc	:= Iif(SC7->C7_TIPO = 1,"PC","AE")
	
	DO CASE 
	//-------------------------------------------------------- INICIO PROCESSO WORKFLOW
		CASE _nOpc == 1		// Envio de email para aprovacao
			oProcess          	:= TWFProcess():New( "000001", "Envio Aprovacao PC :" + _cFilial + "/" +  TRIM(_cNum) )
			oProcess:NewTask( "Envio PC : "+_cFilial + _cNum, "\WORKFLOW\HTML\WF_PCAPROV_DN.HTM" )
			oProcess:bReturn  	:= "U_WKFPC(2)"

			oProcess:cTo      	:= _cTo
			oProcess:UserSiga	:= _cUser
		 	oHtml     			:= oProcess:oHTML

			DBSelectArea("SM0")
			DBSetOrder(1)
			DBSeek(cEmpAnt+SC7->C7_FILENT)

			oHtml:ValByName( "CFILANT"	   , xFilial("SCR"))
			oHtml:ValByName( "CHAVE"	   , _cChave)
			oHtml:ValByName( "WFID"		   , oProcess:fProcessId)
			oHtml:ValByName( "OBS"		   , "" )

			//Cabecalho
			oHtml:ValByName( "AMBIENTE"		, Iif(GetEnvServer() == "CTS97A","",""))
			oHtml:ValByName( "C7_FILIAL"	, SM0->M0_FILIAL )
			oHtml:ValByName( "C7_TIPO"		, Iif(_cTipoDoc == "PC","Pedido de Compra","Delivery Authorization") )    
			oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )    
			oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
			oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER))
			oHtml:ValByName( "A2_NOME"		, SA2->A2_NOME + " " + SA2->A2_COD)
			oHtml:ValByName( "A2_EMAIL"		, SA2->A2_EMAIL)
			oHtml:ValByName( "E4_DESCRI"    , SE4->E4_DESCRI)

			//-------------------------------------------------------------
			// ALIMENTA A TELA DE ITENS DO PEDIDO DE COMPRA
			//-------------------------------------------------------------
			
			While !SC7->(EOF()) .AND. SC7->C7_FILIAL == _cFilial .AND. SC7->C7_NUM == _cNum
		
		        DBSELECTAREA("SB1")
				DBSetOrder(1)
				DBSeek(xFilial("SB1")+SC7->C7_PRODUTO)
				
		        DBSELECTAREA("SC1")
				DBSetOrder(1)
				DBSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC)) 
				
		        DBSELECTAREA("SC3")
				DBSetOrder(1)
				DBSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC))     
				    
				
				AAdd( (oHtml:ValByName( "t.1" )), SC7->C7_ITEM)
				AAdd( (oHtml:ValByName( "t.2" )), SC7->C7_PRODUTO)
				AAdd( (oHtml:ValByName( "t.3" )), Alltrim(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_DESC")) + Iif(!Empty(SC7->C7_OBS )     ," - Obs: "  + Alltrim(SC7->C7_OBS),"") )
				AAdd( (oHtml:ValByName( "t.4"  )), SB1->B1_UM)
				AAdd( (oHtml:ValByName( "t.5"  )), Alltrim(TRANSFORM(SC7->C7_QUANT 					,'@E 999,999,999,999.99')))
				AAdd( (oHtml:ValByName( "t.6"  )), Alltrim(TRANSFORM(SC7->C7_PRECO 					,'@E 999,999,999,999.99')))  
				AAdd( (oHtml:ValByName( "t.7"  )), Alltrim(TRANSFORM(SC7->C7_IPI   					,'@E 99.99'				)))
				AAdd( (oHtml:ValByName( "t.8"  )), Alltrim(TRANSFORM(SC7->C7_TOTAL+SC7->C7_VALIPI 	,'@E 999,999,999,999.99')))
				AAdd( (oHtml:ValByName( "t.9"  )), SC7->C7_DATPRF)
				//AAdd( (oHtml:ValByName( "t.10" )), Alltrim(TRANSFORM(SB1->B1_UPRC  					,'@E 999,999,999,999.99')))
		
				_nVALMERC		:= _nVALMERC +  SC7->C7_TOTAL
				_nVALIPI		:= _nVALIPI  +  SC7->C7_VALIPI
				_nFRETE			:= _nFRETE   +  SC7->C7_VALFRE
				_nSEGURO		:= _nSEGURO  +  SC7->C7_SEGURO
				_nDESPESA		:= _nDESPESA +  SC7->C7_DESPESA  
				_nDESCONTO		:= _nDESCONTO+  SC7->C7_VLDESC  
				_nVALTOT		:= _nVALMERC  + (_nVALIPI + _nFRETE + _nSEGURO + _nDESPESA - _nDESCONTO)
			
				Aadd(_aPedidos,{SC7->C7_ITEM, SC7->C7_PRODUTO} )
		
				SC7->(dbSkip()) 
			Enddo
		
			oHtml:ValByName( "C7_VALMERC"	, Alltrim(TRANSFORM(_nValmerc 			,'@E 9,999,999,999,999.99')))
			oHtml:ValByName( "C7_VALBRU"    , Alltrim(TRANSFORM(_nValmerc+_nVALIPI 	,'@E 9,999,999,999,999.99')))
			oHtml:ValByName( "FRETE"	    , Alltrim(TRANSFORM(_nFRETE 			,'@E 9,999,999,999,999.99')))
			oHtml:ValByName( "SEGURO"   	, Alltrim(TRANSFORM(_nSeguro 			,'@E 9,999,999,999,999.99')))
			oHtml:ValByName( "DESPESA"   	, Alltrim(TRANSFORM(_nDespesa  			,'@E 9,999,999,999,999.99')))
			oHtml:ValByName( "DESCONTO" 	, Alltrim(TRANSFORM(_nDesconto			,'@E 9,999,999,999,999.99')))
			oHtml:ValByName( "VALTOT"		, Alltrim(TRANSFORM(_nVALTOT			,'@E 9,999,999,999,999.99')))

	//  	Imprimir as cotacoes para este item 
		    _aSC8 := {}
			_cSelCot := "SELECT * FROM "+RetSqlName('SC7')+" SC7, "+RetSqlName('SC8')+" SC8"
			_cSelCot += " WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"' "
			_cSelCot += " AND SC8.C8_FILIAL   = '"+xFilial("SC8")+"' "
		    _cSelCot += " AND SC7.C7_NUM = '"+_cNum+"' "
		    _cSelCot += " AND SC7.C7_NUMCOT = SC8.C8_NUM"
		    _cSelCot += " AND SC7.C7_PRODUTO = SC8.C8_PRODUTO"
		    _cSelCot += " AND SC7.C7_NUMSC   = SC8.C8_NUMSC"
		    _cSelCot += " AND SC7.C7_ITEMSC  = SC8.C8_ITEMSC"    
			_cSelCot += " AND SC7.D_E_L_E_T_ = ' '" 
		    _cSelCot += " AND SC8.D_E_L_E_T_ = ' '"
			_cSelCot += " ORDER BY SC7.C7_ITEM, SC7.C7_PRODUTO"
			_cSelCot := ChangeQuery(_cSelCot)
			TCQUERY _cSelCot NEW ALIAS "C7C8"
			TCSETFIELD("C7C8","C8_PRECO"  ,"N",14,4)
			TCSETFIELD("C7C8","C8_VALIPI"  ,"N",14,2)
			DBSELECTAREA("C7C8")
			dbGoTop()
			
			While !Eof()
				DbSelectArea("SA2")
				DBSetOrder(1)
				DbSeek( xFilial("SA2")+C7C8->(C8_FORNECE+C8_LOJA) )
				DBSelectArea("SE4")
				DBSetOrder(1)
				DBSeek(xFilial("SE4")+C7C8->C8_COND)
			    Aadd( _aSC8, {C7C8->C7_ITEM, ;
			    			SA2->A2_NOME        , ;
			    			DtoC(StoD(C7C8->C8_DATPRF)) , ;
			    			SE4->E4_DESCRI        , ;
			    			C7C8->C8_CONTATO      , ;
			    			TRANSFORM(C7C8->C8_QUANT,'@E 999,999,999,999.99'), ;
			    			TRANSFORM(C7C8->C8_PRECO,'@E 999,999,999,999.99')  , ;
			    			C7C8->C8_NUMPED       , ;
			    			TRANSFORM(C7C8->C8_ALIIPI ,'@E 99.99')     , ;
			    			TRANSFORM((C7C8->C8_PRECO + (C7C8->C8_PRECO * C7C8->C8_ALIIPI / 100)) * C7C8->C8_QUANT,  '@E 999,999,999,999.99'),;
			    		    C7C8->C8_NUM, ;
			    		    C7C8->C8_ITEM, ;
			    		    C7C8->C8_PRODUTO,;
			    		    C7C8->C8_FORNECE, ;
			    		    C7C8->C8_LOJA;		    			  
			    			   } )
				_lCotacao := .t.
				DbSelectArea('C7C8')
				DbSkip()	
			EndDo
			dbCloseArea() 
		    dbSelectArea("SC8")	
			// Deve-se tambem testar se houve cotacao para o pedido:
			If !_lCotacao
				// #FF0000
	//	 		_cExibe  := "<p><font color='#FF0000'>*** Nao foi gerada concorrencia para este pedido de compra ***</font></p>"
		 		_cExibe  := "<p><font color='#FF0000'>*** Nao foi gerada concorrencia para este pedido de compra ***</font></p>"
				AAdd( (oHtml:ValByName( "tc.1"  )), "" )
				AAdd( (oHtml:ValByName( "tc.2"  )), "" )
				AAdd( (oHtml:ValByName( "tc.3"  )), "" )
				AAdd( (oHtml:ValByName( "tc.4"  )), "" )
				AAdd( (oHtml:ValByName( "tc.5"  )), "" ) 
				AAdd( (oHtml:ValByName( "tc.6"  )), "" )
				AAdd( (oHtml:ValByName( "tc.7"  )), "" )
				AAdd( (oHtml:ValByName( "tc.9"  )), "" )
				AAdd( (oHtml:ValByName( "tc.10" )), "" )
	//			AAdd( (oHtml:ValByName( "tc.11"  )), "" )
				
			Else	
			    Asort(_aSC8,,, { |x,y| x[1]+x[7] < y[1]+y[7] } )
		   		_cItem := ""
			    For j := 1 To Len(_aSC8)   
			        If Alltrim((_aSC8[j][7])) <> "0,00"
				        If _aSC8[j][8] # "XXXXXX" // Cotacao XXXXXX = Perdedora
							_cExibe1 := "<p><font color='#0000FF'>"+_aSC8[j][1]+"</font></p>"
							_cExibe2 := "<p><font color='#0000FF'>"+_aSC8[j][2]+"</font></p>"
							_cExibe3 := "<p><font color='#0000FF'>"+_aSC8[j][3]+"</font></p>"
							_cExibe4 := "<p><font color='#0000FF'>"+_aSC8[j][4]+"</font></p>"
							_cExibe5 := "<p><font color='#0000FF'>"+_aSC8[j][5]+"</font></p>"
							_cExibe6 := "<p><font color='#0000FF'>"+_aSC8[j][6]+"</font></p>"
							_cExibe7 := "<p><font color='#0000FF'>"+_aSC8[j][7]+"</font></p>"
							_cExibe9 := "<p><font color='#0000FF'>"+_aSC8[j][9]+"</font></p>"
			 				_cExibe10:= "<p><font color='#0000FF'>"+_aSC8[j][10]+"</font></p>"
	//		 				_cExibe11:= "<p><font color='#0000FF'>"+_aSC8[j][16]+"</font></p>"
							AAdd( (oHtml:ValByName( "tc.1" )), Iif(_cItem = _aSC8[j][1],"",_cExibe1) )
							AAdd( (oHtml:ValByName( "tc.2" )), _cExibe2 )
							AAdd( (oHtml:ValByName( "tc.3" )), _cExibe3 )
							AAdd( (oHtml:ValByName( "tc.4" )), _cExibe4 )
							AAdd( (oHtml:ValByName( "tc.5" )), _cExibe5 )
							AAdd( (oHtml:ValByName( "tc.6" )), _cExibe6 )
							AAdd( (oHtml:ValByName( "tc.7" )), _cExibe7 )
							AAdd( (oHtml:ValByName( "tc.9" )), _cExibe9 )
							AAdd( (oHtml:ValByName( "tc.10" )), _cExibe10 )
	//						AAdd( (oHtml:ValByName( "tc.11" )), _cExibe11 )
						Else
							AAdd( (oHtml:ValByName( "tc.1" )), Iif(_cItem = _aSC8[j][1],"",_aSC8[j][1] ))
							AAdd( (oHtml:ValByName( "tc.2" )), _aSC8[j][2] )
							AAdd( (oHtml:ValByName( "tc.3" )), _aSC8[j][3] )
							AAdd( (oHtml:ValByName( "tc.4" )), _aSC8[j][4] )
							AAdd( (oHtml:ValByName( "tc.5" )), _aSC8[j][5] )
							AAdd( (oHtml:ValByName( "tc.6" )), _aSC8[j][6] )
							AAdd( (oHtml:ValByName( "tc.7" )), _aSC8[j][7] )
							AAdd( (oHtml:ValByName( "tc.9" )), _aSC8[j][9] )
							AAdd( (oHtml:ValByName( "tc.10" )), _aSC8[j][10] )
	//						AAdd( (oHtml:ValByName( "tc.11" )), _aSC8[j][16] )
						EndIf 
						_cItem := _aSC8[j][1]	
					Endif
				Next
			EndIf

			oProcess:cTo      		:= nil
			oProcess:NewVersion(.T.)
			oHtml     				:= oProcess:oHTML
			oProcess:nEncodeMime := 0
			cMailID := oProcess:Start(cPathFile)   //Faz a gravacao do e-mail no cPath

			cHtmlFile  := cMailId + ".htm"

			If File(cPathFile + cHtmlFile)

				cHtmlFile	:= cIpServ + cHtmlFile
				cHtml:= WKF01Texto(_cNome,_cNum,cHtmlFile)

				//Monta o email de link para enviar ao aprovador
				If _cTipoDoc == "PC"
					cSubject := "Aprovação Pedido de compra - filial:"+_cFilial+" / Numero: "+_cNum
				Else
					cSubject := "Aprovação Autorização de Entrega - Filial:"+_cFilial+" / Numero: "+_cNum
				Endif

				U_XEnvEmail(cSubject,cHtml,_cEmail)
			EndIf

			// ARRAY DE RETORNO
			_aReturn := {}
			AADD(_aReturn, oProcess:fProcessId)
			AADD(_aReturn, _aTimeOut[3])
			AADD(_aReturn, _aTimeOut[4])

			conout("_aReturn[1]: "+ _aReturn[1])

		CASE _nOpc == 3		// Envio de email Aprovacao para solicitante

			SC7->(dbSetOrder(1))
			SC7->(dbSeek(xFilial("SC7")+TRIM(_cNum)))
			cNome   := UsrFullName(SC7->C7_USER)
			cEmail  := UsrRetMail(SC7->C7_USER) 
			cSubject:= "Pedido de compra aprovado" 
			
			cHtml:= '<html>'
			//cHtml+= '<img border="0" src="https://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg">'//cHtml+= '<img border="0" src="https://uploads.consultaremedios.com.br/factories/logo/original/logo-dana-consulta-remedios.jpg">'
			cHtml+= '<td style="text-align: center; width: 15%;" height="53"> 
			cHtml+= '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
			cHtml+= '<br><p align="left"><span lang="pt-br"><font face="Arial" size="3">Dear ' + cNome + ',</font></span></p>' 
			cHtml+= '<br><br>'
			cHtml+= '<p align="left"><span lang="pt-br"><font face="Arial" size="3">Numero do pedido ' + _cNum + " - Filial :" + cFilAnt + " Fornecedor: " + SA2->A2_NOME + ' foi aprovado por ' + UsrFullName(SCR->CR_USER) + '.</font></span></p>'		 
			cHtml+= '<br><br><br><p align="left"><span lang="pt-br"><font face="Arial" size="1">Workflow TOTVS by CMERPCONSULTING</font></span></p>'		 
			cHtml+= '</html>'
		
			U_XEnvEmail(cSubject,cHtml,cEmail)

			_aReturn := {}
			AADD(_aReturn, "")
			AADD(_aReturn, "")
			AADD(_aReturn, "")

		CASE _nOpc == 4		// Envio de email Reprovado para solicitante
			SC7->(dbSetOrder(1))
			SC7->(dbSeek(xFilial("SC7")+TRIM(_cNum)))
			cNome   := UsrFullName(SC7->C7_USER)
			cEmail  := UsrRetMail(SC7->C7_USER) 
			cSubject:= "Pedido de compra reprovado" 
			
			cHtml:= '<html>'
			//cHtml+= '<img border="0" src="https://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg">'//cHtml+= '<img border="0" src="https://uploads.consultaremedios.com.br/factories/logo/original/logo-dana-consulta-remedios.jpg">'
			cHtml+= '<td style="text-align: center; width: 15%;" height="53"> 
			cHtml+= '<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
			cHtml+= '<br><p align="left"><span lang="pt-br"><font face="Arial" size="3">Dear ' + cNome + ',</font></span></p>' 
			cHtml+= '<br><br>'
			cHtml+= '<p align="left"><span lang="pt-br"><font face="Arial" size="3">O Pedido de compra ' + _cNum + " - Filial :" + cFilAnt + " Fornecedor: " + SA2->A2_NOME + ' foi reprvado por: ' + UsrFullName(SCR->CR_USER) + '.</font></span></p>'		 
			cHtml+= '<br><br><br><p align="left"><span lang="pt-br"><font face="Arial" size="1">Workflow TOTVS by CMERPCONSULTING</font></span></p>'		 
			cHtml+= '</html>'
		
			U_XEnvEmail(cSubject,cHtml,cEmail)

			_aReturn := {}
			AADD(_aReturn, "")
			AADD(_aReturn, "")
			AADD(_aReturn, "")
	
	ENDCASE


Return _aReturn

Static Function WKF01Texto(cNome,cDocto,cLink)
Local cHtml:= ""

cHtml+= '<!-- saved from url=(0022)http://internet.e-mail -->'
cHtml+= '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
cHtml+= '<html>'
cHtml+= '<head>'
cHtml+= '<title>&gt;&gt;&gt;Workflow - Notifica&ccedil;&atilde;o &lt;&lt;&lt;</title>'
cHtml+= '<style>'
cHtml+= 'TR.1 { font-size: 8pt;}'
cHtml+= 'TD { font-size: 8pt; }'
cHtml+= '.Mini {'
cHtml+= '	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
cHtml+= '</style>'
cHtml+= '</head>'
cHtml+= '<body bgproperties="fixed" style="background-color: rgb(255, 255, 255);">'
cHtml+= '<form action="mailto:%WFMailTo%" method="post" name="form1">'
cHtml+= '	<table style="width: 100%; height: 23px; border-collapse:collapse" border="0" cellpadding="0"'
cHtml+= '		cellspacing="0" hspace="0" bordercolor="#111111">'
cHtml+= '		<tbody>'
cHtml+= '			<tr>'
cHtml+= '				<td bgcolor="#ffffff" height="80" width="88%" style="border-style: none; border-width: medium">'
cHtml+= '				<span lang="pt-br"> '
cHtml+= '				<p style="line-height:100%"><font color="#000000" face="Arial" size="4">Workflow </font></span></p>'
cHtml+= '				<p style="line-height:100%"><font face="Arial" size="4">Pedido de compra pendente aprovação</font></p></td>'
cHtml+= '				<td bgcolor="#ffffff" height="80" width="12%" style="border-style: none; border-width: medium"></td>'
//cHtml+= '				<img border="0" src="https://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg">'//cHtml+= '				<img border="0" src="https://uploads.consultaremedios.com.br/factories/logo/original/logo-dana-consulta-remedios.jpg">'// //cHtml+= '				<img border="0" src="https://uploads.consultaremedios.com.br/factories/logo/original/logo-dana-consulta-remedios.jpg"></td>'
cHtml+= '				<td style="text-align: center; width: 15%;" height="53"> 
cHtml+= '				<img border="0" src="http://187.94.58.102:1346/emp01/wfpc/Logo_Dana.jpg"></td>
cHtml+= ' 			</tr>'
cHtml+= '		</tbody>'
cHtml+= '	</table>'
cHtml+= '<TABLE border=0 cellPadding=0 cellSpacing=0 width=100% style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10pt">'
cHtml+= '	<TD bgColor=#0000FF bordercolor="#2D2DCB" style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10pt">'
cHtml+= '	<IMG height=3 src="file:///E|/Work_Afip/pic_invis.gif" width=1></TD>'
cHtml+= '</TABLE>'

cHtml+= '<table bordercolorlight="#DFEFFF" bgcolor="#f2f4f7" border="0" width="100%" height="75">'
cHtml+= '    <tbody>'
cHtml+= '		<tr>'
cHtml+= '			<td valign="top"><span lang="pt-br"><font face="Arial" size="3"><br>Dear ' + cNome + ',</font></span><font size="3"> </font>'
cHtml+= '				<p align="center"><span lang="pt-br"><font face="Arial" size="3">O pedido de compra abaixo aguarda sua aprovação:</font></span></p>'		 
cHtml+= '				<p align="center"><a href="' + cLink + '" style="color: #2d2dcb">'
cHtml+= '				<font size="4" face="Arial">Numero do Pedido de compra ' + cDocto + '</font></a></p>'
cHtml+= '				<br>'
cHtml+= '			</td>'
cHtml+= '		</tr>'
cHtml+= '    </tbody>'
cHtml+= '</table>'
cHtml+= '</form>'

cHtml+= '<table border="0" width="100%">'
cHtml+= '	<tr>'
cHtml+= '		<td class="Mini">Workflow TOTVS by CMERPCONSULTING</td>'
cHtml+= '	</tr>'
cHtml+= '</table>'
cHtml+= '</body>'
cHtml+= '</html>'
 
Return(cHtml)
