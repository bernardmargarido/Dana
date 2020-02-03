#include "RWMAKE.CH"       
#include "TOPCONN.CH" 
#include "APWIZARD.CH"                      
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UPD011A   ºAutor  ³FSW RESULTAR	      º Data ³  07/12/2015 ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Compatibilizar de Dicionario de Dados.			          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FSW TOTVS CASCAVEL                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    

***--------------------***
User Function UPD011A()
***--------------------***

Local oNo 			:= LoadBitmap(GetResources(), "LBNO"  )
Local oOk 			:= LoadBitmap(GetResources(), "LBTIK" )
Local cArqEmp 		:= "SIGAMAT.EMP"
Local nModulo		:= 97
Local __cInterNet 	:= Nil
Local hEnter 		:= CHR(10) + CHR(13)
Local lChkTWiz 		:= .F. 
Local lChkIWiz 		:= .F.
Local lEmpenho		:= .F.
Local lAtuMnu		:= .F.
Local oWizard
Local nPanel
Local oLbxWiz
Local oChkTWiz
Local oChkIWiz 

Private lBackup		:= .F. 
Private aWiz 		:= {{.F.,"",""}}
Private aArqUpd		:= {}
Private cTexto		:= ""          
Private lLinux		:= ("LINUX" $ Upper(GetSrvInfo()[2]))
Private cDirUPD		:= IF( lLinux, "/fsw999/upd011/a/"   , "\fsw999\upd011\a\"    )
Private cDirDADOS	:= IF( lLinux, cDirUPD + "dados/"    , cDirUPD + "dados\"     )
Private cDirBKP		:= IF( lLinux, cDirUPD + "backup_sx/", cDirUPD + "backup_sx\" )
Private lChkTrigg	:= .T.
Private lChkUpdate	:= .F.
Private cTabTrigg	:= ""
Private lTemErro	:= .F.
Private lDicBd 		:= MPDicInDB()

Public cProjFSW		:= SUBSTR(ALLTRIM(PROCNAME()),6,5)

***-------------------------------------------------***
/*VARIAVEIS REFERETE AO CONSUMO DOS SX´S
-- DEVEM SER DEFINIDAS AS TABELAS A CONSUMIR - VALIDAR */
***-------------------------------------------------***  
Public b00101SX1 := UPDNUMREGS("SX1",.T.) //SX1 - PERGUNTAS
Public b00101SX2 := UPDNUMREGS("SX2",.T.) //SX2 - TABELAS
Public b00101SX3 := UPDNUMREGS("SX3",.T.) //SX3 - CAMPOS
Public b00101SX6 := UPDNUMREGS("SX6",.T.) //SX6 - PARAMETROS
Public b00101SX7 := UPDNUMREGS("SX7",.T.) //SX7 - GATILHOS
Public b00101SXA := UPDNUMREGS("SXA",.T.) //SXA - PASTAS
Public b00101SXB := UPDNUMREGS("SXB",.T.) //SXB - CONSULTA PADRAO
Public b00101SIX := UPDNUMREGS("SIX",.T.) //SIX - INDICES
Public b00101HLP := UPDNUMREGS("HELP",.T.) //HELP DE CAMPOS
Public b00101OK	 := .T. //VARIAVEL QUE VALIDA SE ESTAO TODOS OS ARQUIVOS EXISTENTES

b00101OK := !( !b00101SX1 .and. !b00101SX2 .and. !b00101SX3 .and. !b00101SX6 .and. !b00101SX7 .and. !b00101SXA .and. !b00101SXB .and. !b00101SIX .and. !b00101HLP )
If !b00101OK
	MSGHELP( "UPDATE", "Nenhum arquivo *.DTC foi localizado no caminho:"+ Chr(13)+Chr(10) + cDirDADOS, ;
			 "Verifique a documentação Boletim Técnico e aplique o Pacote novamente." )
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia declaração do Wizard e seus componentes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VALIDA LIBERACAO DO PACOTE NO CLIENTE          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If ! U_M999B01("VLDPACOTE","010A")
//	Return()
//ENDIF

cDescricao := "Este assistente tem por objetivo compatibilizar o Dicionário de Dados referente a aplicação"+ CRLF
cDescricao += "do PLUG-IN para integração com o SIM3G / MASTERSALES contendo serviços para:"+ CRLF
cDescricao += "- EXPORTACAO DE CADASTROS"+ CRLF
cDescricao += "- IMPORTACAO DE PEDIDOS"+ CRLF

DEFINE WIZARD oWizard TITLE "Wizard" HEADER "Atualização Dicionário de Dados" MESSAGE "Webservice Integração MASTERSALES" TEXT cDescricao PANEL	NEXT {|| .T.} FINISH {|| .T.}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta itens do segundo PANEL do Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard HEADER "Empresas Utilizadas" MESSAGE "Selecione abaixo as empresas em que deseja aplicar as atualizações" PANEL;
	BACK {|| oWizard:nPanel := 2, .T.} NEXT {|| If(Ascan(aWiz,{|x| x[1] == .T.}) == 0,(MSGALERT("Nenhuma empresa foi selecionada - Para continuar deverá estar selecionando as empresas","ATENCAO"),.F.),.T.)} EXEC {||lChkTWiz:=.F., .T.}
	
		@ 010, 010 TO 125,280 OF oWizard:oMPanel[2] PIXEL                                                  
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama função responsavel pela carga das empresas existentes            ³
		//³no ambiente para que o usuario possa selecionar em quais deseja aplicar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aWiz := EMPLOAD()                            

		@ 018, 020 LISTBOX oLbxWiz FIELDS HEADER "","Codigo","Descrição"  SIZE 171, 88 ON DBLCLICK (aWiz[oLbxWiz:nAt,1] := !aWiz[oLbxWiz:nAt,1],If(!aWiz[oLbxWiz:nAt,1],lChkTWiz := .F., ),oLbxWiz:Refresh(.f.),ApSxVerChk(@lChkTWiz,@aWiz,@oLbxWiz,@oChkTWiz)) OF oWizard:oMPanel[2] PIXEL 	
		oLbxWiz:SetArray(aWiz)
		oLbxWiz:bLine := {|| {If(aWiz[oLbxWiz:nAt,1],oOK,oNO),aWiz[oLbxWiz:nAt,2], aWiz[oLbxWiz:nAt,3]}}
	    oLbxWiz:bRClicked := { || AEVAL(aWiz,{|x|x[1]:=!x[1]}),oLbxWiz:Refresh(.F.) }
    
		@ 040, oLbxWiz:nWidth/2 + 40 CHECKBOX oChkTWiz VAR lChkTWiz PROMPT "Marcar Todos" SIZE 62, 10 OF oWizard:oMPanel[2] PIXEL
		oChkTWiz:blClicked := {|| AEval( aWiz,{|x,y| x[1] := lChkTWiz , If(lChkTWiz, (lChkIWiz := .F.,oChkIWiz:Refresh()), )})}    
	
		@ 070, oLbxWiz:nWidth/2 + 40 CHECKBOX oChkIWiz VAR lChkIWiz PROMPT "Inverter Marca" SIZE 62, 10 OF oWizard:oMPanel[2] PIXEL
		oChkIWiz:blClicked := {|| AEval( aWiz,{|x,y| x[1] := !x[1]}), lChkTWiz := (Ascan(aWiz,{|x|!x[1]}) == 0), oChkTWiz:Refresh()}    


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄA¿
	//³Seta itens do terceiro PANEL do Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAÙ
	CREATE PANEL oWizard HEADER "Parâmetros" MESSAGE "Configure as opções para aplicação do Pacote:" PANEL;
	BACK {|| oWizard:nPanel := 3, .T.} NEXT {|| .T.} EXEC {|| .T.}
   		
		@ 010, 010 TO 125,280 OF oWizard:oMPanel[3] PIXEL 
		                                                  
		@ 018, 020 CHECKBOX oChkTrigg VAR lChkTrigg PROMPT "Criar TRIGGER e campos customizados para controle de alterações - DELTA" SIZE 200,10 OF oWizard:oMPanel[3] PIXEL 
		
		@ 028, 020 CHECKBOX oChkUpdate VAR lChkUpdate PROMPT "Executar UPDATE no campo 'Integração SIM3G = SIM' nos cadastros" SIZE 200,10 OF oWizard:oMPanel[3] PIXEL 


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄA¿
	//³Seta itens do quarto PANEL do Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAÙ
	CREATE PANEL oWizard HEADER "Executando" MESSAGE "Ao confirmar o procedimento o UPDATE será iniciado nas empresas selecionadas" PANEL;
	BACK {|| oWizard:nPanel := 3, .T.} NEXT {|| .T.} EXEC {|| .T.}
                                                                                                        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta mensagem reforçando os procedimentos que o usuario deve³
		//³adotar antes de confirmar a execução do update de atualização³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTexto := "Atenção," + hEnter 
		cTexto += hEnter
		cTexto += "Antes de confirmar a execução dos procedimentos para " 
		cTexto += "compatibilização do Dicionário de Dados, certifique-se "
		cTexto += "de que foram realizados os seguintes procedimentos: "
		cTexto += hEnter
		cTexto += "    - Backup do banco de dados do ambiente"
		cTexto += hEnter
		cTexto += "    - Backup dos arquivos do dicionário de dados (SX)"
		cTexto += hEnter
		cTexto += "    - Backup do arquivo de configuração de empresas (SIGAMAT.EMP)"
		cTexto += hEnter
		
		oMGet1     := TMultiGet():New( 018,020,{|u|if(Pcount()>0,cTexto:=u,cTexto)},oWizard:oMPanel[4],250,088,,,CLR_BLACK,CLR_GRAY,,.T.,"",,,.F.,.F.,.T.,,,.F.,,)                                                 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Seta itens do quinto PANEL do Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	CREATE PANEL oWizard HEADER "Finalizando" MESSAGE "O UPDATE esta sendo executado nas empresas selecionadas..." PANEL;
	BACK {|| oWizard:nPanel := 3, .T.}  FINISH {|| .T. } EXEC {|| .T., PROCUPD(), cTexto := IIF(b00101OK,"Processo de Atualização Finalizado!!!","Processo não executado!")}
                                             
 		oMGet2     := TMultiGet():New( 018,020,{|u|if(Pcount()>0,cTexto:=u,cTexto)},oWizard:oMPanel[5],250,088,,,CLR_BLACK,CLR_GRAY,,.T.,"",,,.F.,.F.,.T.,,,.F.,,)                                                                                                          
//		oWizard:oDlg:lEscClose := .F.
		
		
ACTIVATE WIZARD oWizard CENTERED 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza declaração do Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                 
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ApSxVerChk  ºAutor  ³FSW Resultar	       º Data ³  13/05/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função de verificação das empresas selecionadas para aplica º±±
±±º          ³ção da atualização                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW			                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                             
***----------------------------------------------***
Static Function ApSxVerChk(lChkTudo,aAlias,oLbx,oChk)
***----------------------------------------------***
Local nI               
Local nCount := 0   
Local nSize
Local lChkTudo

nSize := len(aAlias)

For nI := 1 to nSize
	If !aAlias[nI,1] 
		nCount++
	EndIf
Next                                             

If nCount > 0
	lChkTudo := .F.
Else
	lChkTudo := .T.
EndIf
oLbx:Refresh()
oChk:Refresh()                                      

Return lChkTudo 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0Ex³ Autor ³FSW Resultar		    ³ Data ³13/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FSW				                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/             
***------------------------***
Static Function MyOpenSM0Ex()
***------------------------***
                  
Local lOpen := .F. 
Local nLoop := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza 20 testes de exclusividade no ambiente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := 1 To 20
	//dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. )
	OpenSm0Excl() 
	If !Empty( Select( "SM0" ) ) 
		lOpen := .T. 
		//dbSetIndex("SIGAMAT.IND") 
		Exit	
	EndIf
	Sleep( 500 ) 
Next nLoop 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄi
//³Caso após os testes não tenha obtido acesso exclusivo,³
//³alerta o usuario através de mensagem                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄi
If !lOpen
	MSGALERT("Não foi possivel obter acesso exclusivo ao ambiente - Não é possivel efetuar os procedimentos sem acesso exclusivo ao ambiente","ATENCAO")
EndIf                                 

Return lOpen                       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EMPLOAD  ºAutor  ³FSW Resultar	       º Data ³  13/05/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsavel por efetuar analise/carga das empresas   º±±
±±º          ³disponiveis no ambiente para aplicação do update            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW			                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
***---------------------***
Static Function EMPLOAD()
***---------------------***

Local aEmps	:= {}             
Local cEmp  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica exclusividade no acesso ao ambiente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MyOpenSm0Ex()
	dbSelectArea("SM0")
	dbGotop()		
	While SM0->(!EOF())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Adiciona ao array as empresas não deletadas do sigamat.emp³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If (cEmp <> SM0->M0_CODIGO .AND. !SM0->(DELETED()))
			aAdd( aEmps, {.F., SM0->M0_CODIGO, UPPER(SM0->M0_NOME), SM0->(RECNO())})
			cEmp := SM0->M0_CODIGO
		ENDIF
		SM0->( dBSkip( ) )
	End
Endif                                     
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o array com as empresas disponiveis no ambiente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return aEmps


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
0±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UPDProc   ³ Autor ³FSW Resultar           ³ Data ³13/05/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de processamento da gravacao das alterações no      ³±±
±±           ³ dicionario de dados do ambiente selecionado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FSW				                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
***----------------------***
Static Function UPDProc(lEnd)
***----------------------***

Local lRet		:= .T.
Local lOpen     := .F.
Local cTexto    := ''
Local cFile     := ""
Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Local cCodigo   := "DM"                          
Local hEnter	:= CHR(13) + CHR(10)
Local nRecno    := 0
Local nX		:= 0
Local nI        := 0
Local nEmpApl	:= 0
Local aRecnoSM0 := {}    
Local cTextAux  := ""
Local cTextSIX  := ""
Local cTextSX1  := ""
Local cTextSX2  := ""
Local cTextSX3  := ""
Local cTextSX6  := ""
Local cTextSX7  := ""
Local cTextSXA  := ""
Local cTextSXB  := ""
Local cTextTRG  := ""
Local cTextTAB	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia procedimentos para garantir o acesso exclusivo ao ambiente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
dbSetOrder(1)
dbGotop()
cEmp := ""
While !Eof()
	If (cEmp <> SM0->M0_CODIGO .AND. !SM0->(DELETED()))
		Aadd(aRecnoSM0,SM0->(RECNO()))
		cEmp := SM0->M0_CODIGO
	EndIf
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Checa exclusividade do ambiente para cada empresa/filial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nI := 1 To Len(aRecnoSM0)
	SM0->(dbGoto(aRecnoSM0[nI]))
	RpcSetType(2)
	RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	RpcClearEnv()
	If !( lOpen := MyOpenSm0Ex() )
		Exit
	EndIf
Next nI


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Executa procedimentos para obter o numero total de ³
//³empresas nas quais o modulo será aplicado          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
For nI := 1 To Len(aWiz)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄr
	//³Caso o item do array posicionado seja .T. significa que a empresa³
	//³foi selecionada para aplicação então incremente nEmpApl          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄr
	If aWiz[nI][1]
		nEmpApl++
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta regua de processamento com a quantidade de empresas obtidas  ³
//³anteriormente as quais será aplicado								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_oProcess:SetRegua2(nEmpApl)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esta em modo exclusivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOpen              
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia laço para todas as empresas existentes no ambiente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aWiz) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP
		//³Caso a empresa posicionada tenha sido selecionada para aplicação    ³
		//³dos procedimentos, executa os mesmos, caso contrario passa a proxima³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP
		If aWiz[nI][1]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Prepara o ambiente (SXs) para a empresa posionada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			SM0->(dbGoto(aWiz[nI][4]))
			RpcSetType(2)
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicia carga da variavel referente ao controle de log³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTexto += Replicate("-",128) + hEnter
			cTexto += "EMPRESA : " + SM0->M0_CODIGO +" "+ SM0->M0_NOME + hEnter	
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Incrementa barra de status referente a empresa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_oProcess:IncRegua2("Atualizando Empresa " + SM0->M0_CODIGO + " - " + SM0->M0_CODFIL)
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Função de Atualização do Dicionario de Indices (SIX)³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			IF b00101SIX 
				cTextSIX  := UPDAtuSIX()
				cTexto    += cTextSIX 
			ENDIF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Função de Atualização do Dicionario de Tabelas (SX2)³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			IF b00101SX1
				cTextSX1  := UPDAtuSX1() 
				cTexto 	  += cTextSX1
			ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Função de Atualização do Dicionario de Tabelas (SX2)³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			IF b00101SX2
				cTextSX2  := UPDAtuSX2() 
				cTexto 	  += cTextSX2
			ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Função de Atualização do Dicionario de Campos (SX3)³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			IF b00101SX3
				cTextSX3 := UPDAtuSX3()
				cTexto   += cTextSX3
			ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Função de Atualização do Dicionario de Parametros (SX6)³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			IF b00101SX6	
				cTextSX3 := UPDAtuSX6()
			   	cTexto   += cTextSX3
			ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Função de Atualização do Dicionario de Gatilhos (SX7)³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			IF b00101SX7			
				cTextSX7 := UPDAtuSX7()
			   	cTexto   += cTextSX7
			ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Função de Atualização do Dicionario de Pastas (SXA)³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			IF b00101SXA			
				cTextSXA := UPDAtuSXA()
				cTexto   += cTextSXA
			ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Função de Atualização do Dicionario de Consultas Padrões (SXB)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF b00101SXB	
				cTextSXB := UPDAtuSXB()
			   	cTexto   += cTextSXB
			ENDIF			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa procedimentos de atualização no banco de dados das tabelas envolvidas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			__SetX31Mode(.F.)
			For nX := 1 To Len(aArqUpd)
				If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				EndIf
				ConOut("X31UpdTable: "+ aArqUpd[nx])
				X31UpdTable(aArqUpd[nx])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Caso ocorra algum erro emite mensagem ao usuario³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				If __GetX31Error()
					Alert(__GetX31Trace())
					Alert("Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.")
					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				EndIf
			Next nX
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizacao dos campos ??_X_SIM3G no banco de dados  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lChkUpdate
				cTextTAB := UPDAtuTab()
			  	cTexto   += cTextTAB
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criação de TRIGGER para alteração de registros       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lChkTrigg
				cTextTRG := UPD011X(cEmpAnt,cFilAnt)
			   	cTexto   += cTextTRG
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Elimina preparação do ambiente e chega exclusividade ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RpcClearEnv()
			If !( lOpen := MyOpenSm0Ex() )
				Exit
			EndIf
		EndIf
		
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finalizando os procedimentos de atualização em todas as empresas³
	//³selecionadas, apresenta log do processo ao usuario              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOpen 
		If EMPTY(ALLTRIM(cTextSIX)) .AND. EMPTY(ALLTRIM(cTextSX1)) .AND. EMPTY(ALLTRIM(cTextSX2)) .AND. EMPTY(ALLTRIM(cTextSX3)) .AND. ;
		EMPTY(ALLTRIM(cTextSX6)) .AND. EMPTY(ALLTRIM(cTextSX7)) .AND. EMPTY(ALLTRIM(cTextSXA)) .AND. EMPTY(ALLTRIM(cTextSXB)) .AND. ;
		EMPTY(ALLTRIM(cTextTRG)) .AND. EMPTY(ALLTRIM(cTextTAB))
			cTextAux := hEnter+"NENHUMA INFORMACAO ATUALIZADA - PACOTE APLICADO ANTERIORMENTE"+hEnter
		Else
			cTextAux := ""
		EndIF
		
		If ! lTemErro
			cTitulo := "ATUALIZAÇÃO CONCLUIDA"
			cTexto  := "LOG DA ATUALIZAÇÃO" + hEnter + cTexto + cTextAux
		Else
			cTitulo := "ATUALIZAÇÃO CONTÉM ERROS"
			cTexto  := "LOG DA ATUALIZAÇÃO - CONTÉM ERROS" + hEnter + cTexto + cTextAux
		Endif
		
		__cFileLog := GetSrvProfString("Rootpath","") + cDirUPD
		__cFileLog += "UPD011A_"+ GravaData(Date(),.F.,8) +"_"+ Substr(Time(),1,2) + Substr(Time(),4,2) +".LOG"
		ConOut(__cFileLog)
		MemoWrite(__cFileLog,cTexto)
		
		DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
		DEFINE MSDIALOG oDlg TITLE cTitulo From 3,0 to 340,417 PIXEL
			@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Finaliza atualização do ambiente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Return lRet
                    



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³UPDAtuSIX      Autor ³FSW Resultar          ³ Data ³13/05/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de processamento do arquivo de indices SIX	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FSW				                             			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***--------------------***
Static Function UPDAtuSIX()  
***--------------------***

Local cTextAux	:= ""          
Local hEnter    := chr(13)+chr(10)
Local lAtualiza	:= .F.
Local cNickName	:= ""
Local lAchou	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SIX	 que possui todas as tabelas 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    

cAliasTmp := "SIX"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS +"six"+ ALLTRIM(cProjFSW)+".dtc", "SIX"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SIX"+ALLTRIM(cProjFSW))  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta para manipulação a tabela SIX da empresa logada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
dbSelectArea("SIX")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH
//³Seta tamanho da regua de processamento com base no numero   ³
//³de itens a serem aplicados existentes nas tabelas auxiliares³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH
_oProcess:SetRegua1(nProcessa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia laço de verificação + adição dos indices					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SIX"+ALLTRIM(cProjFSW))
dbGoTop()
While !EOF()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Adiciona a tabela somente se a mesma ainda não existir					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()	
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Busca pelo NICKNAME do índice se houver, caso contrário busca pela ORDEM  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    cNickName := &("SIX"+ALLTRIM(cProjFSW)+"->NICKNAME")
    lAchou := .F.
	If ! Empty(cNickName)
		dbSeek(&("SIX"+ALLTRIM(cProjFSW)+"->INDICE") )
		While ! SIX->(EOF()) .and. SIX->INDICE == &("SIX"+ALLTRIM(cProjFSW)+"->INDICE")
			If Alltrim(SIX->NICKNAME) == Alltrim( cNickName )
				lAchou := .T.
				Exit
			Endif
			SIX->(dbSkip())
		Enddo
		
	Else
		lAchou := dbSeek( &("SIX"+ALLTRIM(cProjFSW)+"->INDICE") + &("SIX"+ALLTRIM(cProjFSW)+"->ORDEM") )
	Endif
	
	If !lAchou
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa verificações de geração de Log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAtualiza 
			cTextAux += hEnter
			cTextAux += "     ADICIONADOS OS INDICES: " 
			cTextAux += hEnter
			cTextAux += hEnter
			lAtualiza := .T.    
			If lBackup
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa procedimentos de backup do SX que esta sendo manipulado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MAKEDIR( cDirBKP )
				MAKEDIR( cDirBKP + "empresa"+cEmpAnt )
				_cArqDest := cDirBKP + "\empresa" + cEmpAnt + "\bkp_six" + cEmpAnt + "0.dtc"
				If lLinux
					_cArqDest := StrTran(_cArqDest,"\","/")
				Endif
				Copy to &_cArqDest VIA "CTREECDX"   
			EndIf               
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca a próxima ordem para incluir      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cOrdem := fProxOrd( &("SIX"+ALLTRIM(cProjFSW)+"->INDICE") )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Efetua atualização do item³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		RECLOCK("SIX", .T.)
		    SIX->INDICE		:= &("SIX"+ALLTRIM(cProjFSW)+"->INDICE")
		    SIX->ORDEM		:= cOrdem
		    SIX->CHAVE		:= &("SIX"+ALLTRIM(cProjFSW)+"->CHAVE")
		    SIX->DESCRICAO	:= &("SIX"+ALLTRIM(cProjFSW)+"->DESCRICAO")
		    SIX->DESCSPA	:= &("SIX"+ALLTRIM(cProjFSW)+"->DESCSPA")
		    SIX->DESCENG	:= &("SIX"+ALLTRIM(cProjFSW)+"->DESCENG")
		    SIX->PROPRI		:= &("SIX"+ALLTRIM(cProjFSW)+"->PROPRI")
		    SIX->F3			:= &("SIX"+ALLTRIM(cProjFSW)+"->F3")
		    SIX->NICKNAME	:= &("SIX"+ALLTRIM(cProjFSW)+"->NICKNAME")
		    SIX->SHOWPESQ	:= &("SIX"+ALLTRIM(cProjFSW)+"->SHOWPESQ")
		SIX->(MSUNLOCK())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona nome da tabela para posterior atualização ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If aScan(aArqUpd, {|x| x == SIX->INDICE }) == 0
			AADD(aArqUpd, SIX->INDICE)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona a chave do indice adicionado ao SIX a variavel do arquivo de LOG ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTextAux += "     " + &("SIX"+ALLTRIM(cProjFSW)+"->CHAVE")
		cTextAux += hEnter
	EndIf    
	dbSelectArea("SIX"+ALLTRIM(cProjFSW))
	dbSkip()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ„
	//³Atualiza barra de status do SIX³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProcess:IncRegua1("Atualizando Dicionário de Indices (SIX)")
End                 

SLEEP(5000)
cTextAux += hEnter

Return cTextAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³UPDAtuSX1      Autor ³FSW Resultar          ³ Data ³15/07/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de processamento do arquivo de parametros SX1	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FSW				                             			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***--------------------***
Static Function UPDAtuSX1()  
***--------------------***

Local cTextAux	:= ""          
Local hEnter    := chr(13)+chr(10)
Local lAtualiza	:= .F.
Local aVetAlt   := {}
Local xLog

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SX1	                            				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    

cAliasTmp := "SX1"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS + "sx1"+ALLTRIM(cProjFSW)+".dtc", "SX1"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SX1"+ALLTRIM(cProjFSW))  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta para manipulação a tabela SX1 da empresa logada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
dbSelectArea("SX1")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH
//³Seta tamanho da regua de processamento com base no numero   ³
//³de itens a serem aplicados existentes nas tabelas auxiliares³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH
_oProcess:SetRegua1(nProcessa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia laço de verificação                       				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX1"+ALLTRIM(cProjFSW))
dbGoTop()
While !EOF()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Adiciona campo somente se o mesmo ainda não existir					 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	dbSelectArea("SX1")
	dbSetOrder(1)
	dbGoTop()	
	If dbSeek(&("SX1"+ALLTRIM(cProjFSW)+"->X1_GRUPO") + &("SX1"+ALLTRIM(cProjFSW)+"->X1_ORDEM"))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Efetua atualização do item³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		RECLOCK("SX1", .F.)
		    SX1->X1_TAMANHO := &("SX1"+ALLTRIM(cProjFSW)+"->X1_TAMANHO")
		    SX1->X1_F3		:= &("SX1"+ALLTRIM(cProjFSW)+"->X1_F3")
		    SX1->X1_VALID   := &("SX1"+ALLTRIM(cProjFSW)+"->X1_VALID")
		SX1->(MSUNLOCK())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona a chave do indice adicionado ao SX1 a variavel do arquivo de LOG ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aVetAlt,{"     " + &("SX1"+ALLTRIM(cProjFSW)+"->X1_GRUPO") + "/" + &("SX1"+ALLTRIM(cProjFSW)+"->X1_ORDEM")+hEnter})		

	EndIf    
	
	dbSelectArea("SX1"+ALLTRIM(cProjFSW))
	dbSkip()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ„
	//³Atualiza barra de status do SX1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProcess:IncRegua1("Atualizando Dicionário de Indices (SX1)")
EndDo


//LOG DE ALTERACOES
For xLog := 1 To Len(aVetAlt)
	If xLog == 1
		cTextAux += hEnter
		cTextAux += "     ALTERADOS CAMPOS SX1: "  
		cTextAux += hEnter
		cTextAux += hEnter	
	EndIf                 
	
	cTextAux += aVetAlt[xLog][1]
Next xLog

SLEEP(5000)
cTextAux += hEnter

Return cTextAux



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³UPDAtuSX2      Autor ³FSW Resultar          ³ Data ³13/05/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de processamento da SX2                 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FSW				                         				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
***--------------------***
Static Function UPDAtuSX2()                                                
***--------------------***

Local lAtualiza	:= .F.
Local cTextAux 	:= ""
Local hEnter    := chr(13)+chr(10)
Local cPath     


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SX2 que possui todas as tabelas					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasTmp := "SX2"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS + "sx2"+ALLTRIM(cProjFSW)+".dtc", "SX2"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SX2"+ALLTRIM(cProjFSW))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta para manipulação a tabela SX2 da empresa logada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
dbSelectArea("SX2")
dbSetOrder(1)
cPath	:= SX2->X2_PATH

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia laço de verificação + adição das tabelas					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2"+ALLTRIM(cProjFSW))
dbGoTop()
While !EOF()
	dbSelectArea("SX2")
	dbGoTop()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Adiciona a tabela somente se a mesma ainda não existir					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !dbSeek(&("SX2"+ALLTRIM(cProjFSW)+"->X2_CHAVE"))
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica geração de Log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAtualiza  
			cTextAux += hEnter
			cTextAux += "     ADICIONADO AS TABELAS: "  
			cTextAux += hEnter
			cTextAux += hEnter
			lAtualiza := .T.        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa procedimentos de backup do SX que esta sendo manipulado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBackup
				MAKEDIR( cDirBKP )
				MAKEDIR( cDirBKP + "empresa"+cEmpAnt )
				_cArqDest := cDirBKP + "\empresa" + cEmpAnt + "\bkp_sx2" + cEmpAnt + "0.dtc"
				If lLinux
					_cArqDest := StrTran(_cArqDest,"\","/")
				Endif
				Copy to &_cArqDest VIA "CTREECDX"   
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza atualização do item³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RECLOCK("SX2", .T.)
  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona item ao array auxiliar para posterior atualização no banco de dados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AADD(aArqUpd, &("SX2"+ALLTRIM(cProjFSW)+"->X2_CHAVE"))
		    
		    SX2->X2_CHAVE   := &("SX2"+ALLTRIM(cProjFSW)+"->X2_CHAVE")
		    SX2->X2_PATH    := cPath
		    SX2->X2_ARQUIVO := &("SX2"+ALLTRIM(cProjFSW)+"->X2_CHAVE") + cEmpAnt + "0"
		    SX2->X2_NOME	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_NOME")
		    SX2->X2_NOMESPA	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_NOMESPA")
		    SX2->X2_NOMEENG	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_NOMEENG")
		    SX2->X2_ROTINA	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_ROTINA")
		    SX2->X2_MODO	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_MODO")
		    SX2->X2_DELET	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_DELET")
		    SX2->X2_TTS		:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_TTS")
		    SX2->X2_UNICO	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_UNICO")
		    SX2->X2_PYME	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_PYME")
		    SX2->X2_MODULO	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_MODULO")
		    SX2->X2_DISPLAY	:= &("SX2"+ALLTRIM(cProjFSW)+"->X2_DISPLAY")
		SX2->(MSUNLOCK())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona o Alias da tabela adicionada ao SX2 do ambiente na variavel do arquivo de LOG³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTextAux += "     " + &("SX2"+ALLTRIM(cProjFSW)+"->X2_CHAVE")
		cTextAux += hEnter
	EndIf   
	dbSelectArea("SX2"+ALLTRIM(cProjFSW))
	dbSkip()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ„
	//³Atualiza barra de status do SX2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProcess:IncRegua1("Atualizando Dicionário de Tabelas (SX2)")
End                                                          

SLEEP(5000)
cTextAux += IIF(!EMPTY(cTextAux),hEnter,cTextAux)

Return cTextAux                             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³UPDAtuSX3      Autor ³FSW Resultar	      ³ Data ³13/05/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de processamento do SX3                 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FSW				                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
***-------------------***
Static Function UPDAtuSX3() 
***-------------------***                        

Local cTextAux	:= ""
Local cHelp		:= ""          
Local i			:= 0           
Local nAux		:= 1       
Local nCont		:= 0
Local aHelp		:= {}
Local hEnter    := chr(13)+chr(10)
Local cOrdem	:= "00"
Local lAtualiza	:= .F.       
Local i         := 1 
Local nAux		:= 0
Local lVerifica := .T.
Local aVetInc   := {}            
Local aVetAlt   := {}
Local xLog

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SX3 que possui todas os campos 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "SX3"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS + "sx3"+ALLTRIM(cProjFSW)+".dtc", "SX3"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SX3"+ALLTRIM(cProjFSW))           
                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar HELP que possui todas os Helps de campos 				    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "HELP"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

IF b00101HLP
	dbUseArea(.T., "CTREECDX", cDirDADOS +"help"+ALLTRIM(cProjFSW)+".dtc", "HELP"+ALLTRIM(cProjFSW), .F., .F.)
	dbSelectArea("HELP"+ALLTRIM(cProjFSW))  
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta para manipulação a tabela SX3 da empresa logada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbGoTop())     
    
cTabTrigg := ""
aArqUpd	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia laço de verificação + adição dos campos						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasFSW := "SX3"+ALLTRIM(cProjFSW)
dbSelectArea(cAliasFSW)
dbGoTop()
While !EOF()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄt
	//³Valida se cria ou não o campo de controle dos registros EXPORTADOS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄt
	If ! lChkTrigg .and. ("_X_EXPO" $ (cAliasFSW)->X3_CAMPO )
		ConOut("--- Campo ignorado "+ (cAliasFSW)->X3_CAMPO )
		(cAliasFSW)->(dbSkip())
		_oProcess:IncRegua1()
		Loop
	Endif
	
	// Armazena a tabela para criação das Triggers no final do processo
	If lChkTrigg .and. ("_X_EXPO" $ (cAliasFSW)->X3_CAMPO )
		If ! ( (cAliasFSW)->X3_ARQUIVO $ cTabTrigg )
			cTabTrigg += (cAliasFSW)->X3_ARQUIVO  + "/"
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄt
	//³Pega ultima ordem existente para o Alias do item³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄt
	cOrdem	:= "00"	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(dbGoTop()) 	
    dbSeek(&("SX3"+ALLTRIM(cProjFSW)+"->X3_ARQUIVO"))
    While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == &("SX3"+ALLTRIM(cProjFSW)+"->X3_ARQUIVO")
        cOrdem := SX3->X3_ORDEM
    	SX3->(dbSkip())                                                                          
    End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Adiciona o campo somente se o mesmo ainda não existir					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	SX3->(dbGoTop()) 
	If !SX3->(dbSeek(&("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO")))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza variavel de controle do arquivo de log adicionando informacoes especificas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAtualiza
			lAtualiza := .T.  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa procedimentos de backup do SX que esta sendo manipulado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBackup
				MAKEDIR( cDirBKP )
				MAKEDIR( cDirBKP + "empresa"+cEmpAnt )
				_cArqDest := cDirBKP + "\empresa" + cEmpAnt + "\bkp_sx3" + cEmpAnt + "0.dtc"
				If lLinux
					_cArqDest := StrTran(_cArqDest,"\","/")
				Endif
				Copy to &_cArqDest VIA "CTREECDX"   
			EndIf
		EndIf  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incrementa o valor de ordem para a obter o valor da ordem do novo campo no SX3³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cOrdem	:= Soma1(cOrdem, 2)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega o Help do campo da tabela auxiliar de Helps e efetua tratativas necessario para adicionar o mesmo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF b00101HLP 
			dbSelectArea("HELP"+ALLTRIM(cProjFSW))  
			dbGoTop()
			While !EOF()
			    If &("HELP"+ALLTRIM(cProjFSW)+"->HELP_CAMPO") == &("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO")
			   	 	aHelp := STRTOKARR(&("HELP"+ALLTRIM(cProjFSW)+"->HELP_HELP"), CHR(13))
			   	 	For i := 1 to Len(aHelp)
			   	 		nCont := Len(aHelp[i])
			   	 		cHelp := SUBSTR(aHelp[i], 1, nCont) + SPACE(1) 
			   	 		aHelp[i] := cHelp
			   	 	Next i	                              
			   	 	cHelp := ""   
			   	 	i     := 1 
					nAux  := Len(aHelp) 
					lVerifica := .T.
			   	 	
			   	 	While lVerifica
			   	 		If i <= Len(aHelp)
					   	 	If Len(ALLTRIM(aHelp[i])) == 0
						   	 	//Deleta o item do array
								ADEL(aHelp, i)  
								i := 1                  
								// Reorganiza o array
								ASIZE(aHelp,(nAux - 1))    
								nAux := Len(aHelp)     
							Else
								i++
							EndIf
						Else
							exit
						EndIf
					End
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o help do campo o qual esta sendo incluido³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   		PUTHELP("P"+&("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO"), aHelp, aHelp, aHelp, .F.)
			   		aHelp	:= {}                                       
			   		nAux	:= 1
			   		exit                   
			    EndIf   
			    dbSelectArea("HELP"+ALLTRIM(cProjFSW))
				dbSkip()
			End	
        ENDIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona o alias da tabela a qual pertence o campo para atualização posteriormente no banco de dados caso a tabela já exista no banco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aArqUpd, &("SX3"+ALLTRIM(cProjFSW)+"->X3_ARQUIVO"))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua a atualização do novo item no SX3 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RECLOCK("SX3", .T.)
		    SX3->X3_ARQUIVO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_ARQUIVO")
		    SX3->X3_ORDEM	:= cOrdem 
		    SX3->X3_CAMPO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO")
		    SX3->X3_TIPO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TIPO")
		    SX3->X3_TAMANHO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TAMANHO")
		    SX3->X3_DECIMAL	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_DECIMAL")
		    SX3->X3_TITULO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITULO")
		    SX3->X3_TITSPA	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITSPA")
		    SX3->X3_TITENG	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITENG")
		    SX3->X3_DESCRIC	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCRIC")
		    SX3->X3_DESCSPA	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCSPA")
		    SX3->X3_DESCENG	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCENG")
		    SX3->X3_PICTURE	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_PICTURE")
		    SX3->X3_VALID	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_VALID")
		    SX3->X3_USADO	:= IIF(lDicBD, X3TREATUSO(&("SX3"+ALLTRIM(cProjFSW)+"->X3_USADO")), &("SX3"+ALLTRIM(cProjFSW)+"->X3_USADO"))
		    SX3->X3_RELACAO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_RELACAO")
		    SX3->X3_F3		:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_F3")
		    SX3->X3_NIVEL	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_NIVEL")
		    SX3->X3_RESERV	:= IIF(lDicBD, X3RESERV(&("SX3"+ALLTRIM(cProjFSW)+"->X3_RESERV")), &("SX3"+ALLTRIM(cProjFSW)+"->X3_RESERV"))
		    SX3->X3_CHECK	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_CHECK")
		    SX3->X3_TRIGGER	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TRIGGER")
		    SX3->X3_PROPRI	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_PROPRI")
		    SX3->X3_BROWSE	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_BROWSE")
		    SX3->X3_VISUAL	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_VISUAL")
		    SX3->X3_CONTEXT	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_CONTEXT")
		    SX3->X3_OBRIGAT := IIF(lDicBD, X3TREATOBRIGAT(&("SX3"+ALLTRIM(cProjFSW)+"->X3_OBRIGAT")), &("SX3"+ALLTRIM(cProjFSW)+"->X3_OBRIGAT"))
		    SX3->X3_VLDUSER	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_VLDUSER")
		    SX3->X3_CBOX	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_CBOX")
		    SX3->X3_CBOXSPA	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_CBOXSPA")
		    SX3->X3_CBOXENG	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_CBOXENG")
		    SX3->X3_PICTVAR	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_PICTVAR")
		    SX3->X3_WHEN	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_WHEN")
		    SX3->X3_INIBRW	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_INIBRW")
		    SX3->X3_GRPSXG	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_GRPSXG")
		    SX3->X3_FOLDER	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_FOLDER")
		    SX3->X3_PYME	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_PYME")
		    SX3->X3_CONDSQL	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_CONDSQL")
		    SX3->X3_CHKSQL	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_CHKSQL")
		    SX3->X3_IDXSRV	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_IDXSRV")
		    SX3->X3_ORTOGRA	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_ORTOGRA")
		    SX3->X3_IDXFLD	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_IDXFLD")
		    SX3->X3_TELA	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TELA")
		SX3->(MSUNLOCK()) 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona o campo adicionado ao SX3 do ambiente na variavel do arquivo de LOG³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		AADD(aVetInc,{"     " + &("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO")+hEnter})						                                                 
		
		cOrdem := "00"
	Else                 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona o alias da tabela a qual pertence o campo para atualização posteriormente no banco de dados caso a tabela já exista no banco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aArqUpd, &("SX3"+ALLTRIM(cProjFSW)+"->X3_ARQUIVO"))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua a atualização do novo item no SX3 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF SX3->X3_TAMANHO # &("SX3"+ALLTRIM(cProjFSW)+"->X3_TAMANHO") .OR. SX3->X3_DECIMAL	# &("SX3"+ALLTRIM(cProjFSW)+"->X3_DECIMAL") .OR. ;
		   SX3->X3_TITULO # &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITULO") .OR. SX3->X3_TITSPA # &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITSPA") .OR. ;
		   SX3->X3_TITENG # &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITENG") .OR. SX3->X3_DESCRIC # &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCRIC") .OR. ;
		   SX3->X3_DESCSPA # &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCSPA") .OR. SX3->X3_DESCENG	# &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCENG") .OR. ;
		   SX3->X3_PICTURE # &("SX3"+ALLTRIM(cProjFSW)+"->X3_PICTURE") .OR. SX3->X3_USADO # &("SX3"+ALLTRIM(cProjFSW)+"->X3_USADO") .OR. ;
		   SX3->X3_F3 # &("SX3"+ALLTRIM(cProjFSW)+"->X3_F3") .OR. SX3->X3_NIVEL	# &("SX3"+ALLTRIM(cProjFSW)+"->X3_NIVEL") .OR. ;
		   SX3->X3_TRIGGER # &("SX3"+ALLTRIM(cProjFSW)+"->X3_TRIGGER") .OR. SX3->X3_BROWSE # &("SX3"+ALLTRIM(cProjFSW)+"->X3_BROWSE") .OR. ;
		   SX3->X3_VISUAL # &("SX3"+ALLTRIM(cProjFSW)+"->X3_VISUAL") .OR. SX3->X3_OBRIGAT # &("SX3"+ALLTRIM(cProjFSW)+"->X3_OBRIGAT") .OR. ;
		   SX3->X3_VLDUSER # &("SX3"+ALLTRIM(cProjFSW)+"->X3_VLDUSER") .OR. SX3->X3_GRPSXG # &("SX3"+ALLTRIM(cProjFSW)+"->X3_GRPSXG") .OR. ;
		   SX3->X3_FOLDER # &("SX3"+ALLTRIM(cProjFSW)+"->X3_FOLDER")
		
			RECLOCK("SX3", .F.)
			    SX3->X3_TAMANHO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TAMANHO")
			    SX3->X3_DECIMAL	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_DECIMAL")
			    SX3->X3_TITULO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITULO")
			    SX3->X3_TITSPA	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITSPA")
			    SX3->X3_TITENG	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TITENG")
			    SX3->X3_DESCRIC	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCRIC")
			    SX3->X3_DESCSPA	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCSPA")
			    SX3->X3_DESCENG	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_DESCENG")
			    SX3->X3_PICTURE	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_PICTURE")
			    SX3->X3_USADO	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_USADO")
			    SX3->X3_F3		:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_F3")
			    SX3->X3_NIVEL	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_NIVEL")
			    SX3->X3_TRIGGER	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_TRIGGER")
			    SX3->X3_BROWSE	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_BROWSE")
			    SX3->X3_VISUAL	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_VISUAL")
			    SX3->X3_OBRIGAT	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_OBRIGAT")
			    SX3->X3_VLDUSER	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_VLDUSER")
			    SX3->X3_GRPSXG	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_GRPSXG")
			    SX3->X3_FOLDER	:= &("SX3"+ALLTRIM(cProjFSW)+"->X3_FOLDER")
			SX3->(MSUNLOCK()) 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona o campo adicionado ao SX3 do ambiente na variavel do arquivo de LOG³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			AADD(aVetAlt,{"     " + &("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO")+hEnter})		
			
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega o Help do campo da tabela auxiliar de Helps e efetua tratativas necessario para adicionar o mesmo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF b00101HLP
				dbSelectArea("HELP"+ALLTRIM(cProjFSW)) 
				dbGoTop()
				While !EOF()
				    If &("HELP"+ALLTRIM(cProjFSW)+"->HELP_CAMPO") == &("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO")
				   	 	aHelp := STRTOKARR(&("HELP"+ALLTRIM(cProjFSW)+"->HELP_HELP"), CHR(13))
				   	 	For i := 1 to Len(aHelp)
				   	 		nCont := Len(aHelp[i])
				   	 		cHelp := SUBSTR(aHelp[i], 1, nCont) + SPACE(1) 
				   	 		aHelp[i] := cHelp
				   	 	Next i	                              
				   	 	cHelp := ""   
				   	 	i     := 1 
						nAux  := Len(aHelp) 
						lVerifica := .T.
				   	 	
				   	 	While lVerifica
				   	 		If i <= Len(aHelp)
						   	 	If Len(ALLTRIM(aHelp[i])) == 0
							   	 	//Deleta o item do array
									ADEL(aHelp, i)  
									i := 1                  
									// Reorganiza o array
									ASIZE(aHelp,(nAux - 1))    
									nAux := Len(aHelp)     
								Else
									i++
								EndIf
							Else
								exit
							EndIf
						End
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o help do campo o qual esta sendo incluido³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				   		PUTHELP("P"+&("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO"), aHelp, aHelp, aHelp, .F.)
				   		aHelp	:= {}                                       
				   		nAux	:= 1
				   		exit                   
				    EndIf          
				    dbSelectArea("HELP"+ALLTRIM(cProjFSW))
					dbSkip()
				End	
			EndIf
		ENDIF
	EndIf   
	dbSelectArea("SX3"+ALLTRIM(cProjFSW))
	dbSkip()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ„
	//³Atualiza barra de status do SX3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProcess:IncRegua1("Atualizando Dicionário de Campos (SX3)")
End     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fecha as tabelas auxiliares utilizadas no processo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "SX3"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

cAliasTmp := "HELP"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

SLEEP(5000)

//LOG DE INCLUSAO
For xLog := 1 To Len(aVetInc)
	If xLog == 1
		cTextAux += hEnter
		cTextAux += "     ADICIONADOS OS CAMPOS: "  
		cTextAux += hEnter
		cTextAux += hEnter	
	EndIf                 
	
	cTextAux += aVetInc[xLog][1]
Next xLog

//LOG DE ALTERACOES
For xLog := 1 To Len(aVetAlt)
	If xLog == 1
		cTextAux += hEnter
		cTextAux += "     ATUALIZADOS OS CAMPOS: "  
		cTextAux += hEnter
		cTextAux += hEnter	
	EndIf                 
	
	cTextAux += aVetAlt[xLog][1]
Next xLog

cTextAux += IIF(!EMPTY(cTextAux),hEnter+hEnter,cTextAux)

Return cTextAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UPDAtuSX6  ºAutor  ³FSW Resultar       º Data ³  13/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsavel pela atualização de paramentros (SX6)    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW				                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***--------------------***
Static Function UPDAtuSX6()                                                
***--------------------***

Local lAtualiza	:= .F.
Local lInclui	:= .F.
Local lAltera	:= .F.
Local cTextAux 	:= ""
Local hEnter    := chr(13)+chr(10)
Local cPath                     
Local cOrdem      
Local aVetInc   := {}            
Local aVetAlt   := {}
Local bGravOk	:= .F.
Local xLog

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SX6 que contem todos os gatilhos de campos 					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "SX6"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS +"sx6"+ALLTRIM(cProjFSW)+".dtc", "SX6"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SX6"+ALLTRIM(cProjFSW))  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta para manipulação o SX6 da empresa logada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
dbSetOrder(1)       


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa procedimentos de backup do SX que esta sendo manipulado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lBackup
	MAKEDIR( cDirBKP )
	MAKEDIR( cDirBKP + "empresa"+cEmpAnt )
	_cArqDest := cDirBKP + "\empresa" + cEmpAnt + "\bkp_sx6" + cEmpAnt + "0.dtc"
	If lLinux
		_cArqDest := StrTran(_cArqDest,"\","/")
	Endif
	Copy to &_cArqDest VIA "CTREECDX"                            
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa laço o qual aplicará todos os parametros ³
//³no SXB da empresa logada  					    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6"+ALLTRIM(cProjFSW))
dbGoTop()
While !EOF()
    lInclui := .T.
    lAltera := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
	//³Verifica se o parametro a ser incluido já existe no ambiente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
	dbSelectArea("SX6")
    dbSetorder(1)
    dbGoTop() 
    If dbSeek(&("SX6"+ALLTRIM(cProjFSW)+"->X6_FIL") + &("SX6"+ALLTRIM(cProjFSW)+"->X6_VAR"))
    	lInclui := .F.
    	lAltera := .T.    	
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o parametro somente se o mesmo não existir³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lInclui .Or. lAltera
		//Analisa se houve alteração		
		IF lAltera       
			IF SX6->X6_FIL # &("SX6"+ALLTRIM(cProjFSW)+"->X6_FIL") .OR. SX6->X6_VAR # &("SX6"+ALLTRIM(cProjFSW)+"->X6_VAR") .OR. ;
				SX6->X6_TIPO # &("SX6"+ALLTRIM(cProjFSW)+"->X6_TIPO") .OR. SX6->X6_DESCRIC # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DESCRIC") .OR. ;
				SX6->X6_DSCSPA # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCSPA") .OR. SX6->X6_DSCENG # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCENG") .OR. ;
				SX6->X6_DESC1 # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DESC1") .OR. SX6->X6_DSCSPA1 # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCSPA1") .OR. ;
				SX6->X6_DSCENG1	# &("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCENG1") .OR. SX6->X6_DESC2 # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DESC2") .OR. ;
				SX6->X6_DSCSPA2 # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCSPA2") .OR. SX6->X6_DSCENG2 # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCENG2") .OR. ;
				SX6->X6_PROPRI # &("SX6"+ALLTRIM(cProjFSW)+"->X6_PROPRI") .OR. ;
				SX6->X6_PYME # &("SX6"+ALLTRIM(cProjFSW)+"->X6_PYME") .OR.	SX6->X6_VALID # &("SX6"+ALLTRIM(cProjFSW)+"->X6_VALID") .OR. ;
				SX6->X6_INIT # &("SX6"+ALLTRIM(cProjFSW)+"->X6_INIT") .OR.	SX6->X6_DEFPOR # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DEFPOR") .OR. ;
				SX6->X6_DEFSPA # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DEFSPA") .OR. SX6->X6_DEFENG # &("SX6"+ALLTRIM(cProjFSW)+"->X6_DEFENG")             
				bGravOk := .T.
			ELSE
				bGravOk := .F.			
			ENDIF
		ELSE
			bGravOk := .T.
		ENDIF     
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄX
		//³Efetua atualização no SX6 do parametro posicionado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄX

		IF bGravOk
			RECLOCK("SX6", IIF(lAltera,.F.,.T.))		    
			    SX6->X6_FIL		:= 	&("SX6"+ALLTRIM(cProjFSW)+"->X6_FIL")
			    SX6->X6_VAR		:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_VAR")
			    SX6->X6_TIPO	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_TIPO")
			    SX6->X6_DESCRIC :=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DESCRIC")
			    SX6->X6_DSCSPA	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCSPA")
			    SX6->X6_DSCENG	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCENG")
			    SX6->X6_DESC1	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DESC1")
			    SX6->X6_DSCSPA1	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCSPA1")
			    SX6->X6_DSCENG1	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCENG1")
			    SX6->X6_DESC2	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DESC2")
			    SX6->X6_DSCSPA2	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCSPA2")
			    SX6->X6_DSCENG2	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DSCENG2")
				if !lAltera
					SX6->X6_CONTEUD	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_CONTEUD")
					SX6->X6_CONTSPA	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_CONTSPA")
					SX6->X6_CONTENG	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_CONTENG")
				endif
				SX6->X6_PROPRI	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_PROPRI")
				SX6->X6_PYME	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_PYME")
				SX6->X6_VALID	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_VALID")
				SX6->X6_INIT	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_INIT")
				SX6->X6_DEFPOR	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DEFPOR")
				SX6->X6_DEFSPA	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DEFSPA")
				SX6->X6_DEFENG	:=	&("SX6"+ALLTRIM(cProjFSW)+"->X6_DEFENG")
			SX6->(MSUNLOCK())
			
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registra parametro na variavel de controle do log ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF lAltera
				AADD(aVetAlt,{"     " + &("SX6"+ALLTRIM(cProjFSW)+"->X6_VAR")+hEnter})		
			ELSE 
				AADD(aVetInc,{"     " + &("SX6"+ALLTRIM(cProjFSW)+"->X6_VAR")+hEnter})				
			EndIf
        EndIf
	EndIf                                        
	
	dbSelectArea("SX6"+ALLTRIM(cProjFSW))
	dbSkip()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ„
	//³Atualiza barra de status do SX6³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProcess:IncRegua1("Atualizando Dicionário de Parametros (SX6)")
End                                                          

//LOG DE INCLUSAO
For xLog := 1 To Len(aVetInc)
	If xLog == 1
		cTextAux += hEnter
		cTextAux += "     ADICIONADOS OS PARAMETROS: "  
		cTextAux += hEnter
		cTextAux += hEnter	
	EndIf                 
	
	cTextAux += aVetInc[xLog][1]
Next xLog

//LOG DE ALTERACOES
For xLog := 1 To Len(aVetAlt)
	If xLog == 1
		cTextAux += hEnter
		cTextAux += "     ALTERADOS OS PARAMETROS: "  
		cTextAux += hEnter
		cTextAux += hEnter	
	EndIf                 
	
	cTextAux += aVetAlt[xLog][1]
Next xLog


SLEEP(5000)
cTextAux += IIF(!EMPTY(cTextAux),hEnter,cTextAux)

Return cTextAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UPDAtuSX7  ºAutor  ³FSW Resultar		º Data ³  13/05/14    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de atualização do SX7 (Gatilhos de campos).          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW			                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                 
***----------------------***
Static Function UPDAtuSX7()  
***----------------------***                                              

Local lAtualiza	:= .F.
Local lInclui	:= .F.
Local cTextAux 	:= ""
Local hEnter    := chr(13)+chr(10)
Local cPath                     
Local cOrdem      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SX7FS0001 que contem todos os gatilhos de campos					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "SX7"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS +"sx7"+ALLTRIM(cProjFSW)+".dtc", "SX7"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SX7"+ALLTRIM(cProjFSW))  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta para manipulação o SX7 da empresa logada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX7")
dbSetOrder(1)       


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa laço o qual aplicará todos os gatilhos ³
//³no SX7 da empresa logada  					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX7"+ALLTRIM(cProjFSW))
dbGoTop()
While !EOF()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega proxima sequencia valida para gatilho do campo posicionado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dbSelectArea("SX7")
    dbSetorder(1)
    dbGoTop()
    If dbSeek(&("SX7"+ALLTRIM(cProjFSW)+"->X7_CAMPO"))
    	While (SX7->(!EOF()) .AND. SX7->X7_CAMPO == &("SX7"+ALLTRIM(cProjFSW)+"->X7_CAMPO"))   
			cOrdem := SX7->X7_SEQUENC   
			SX7->(dbSkip())
		End                    
		cOrdem := SOMA1(cOrdem)
    Else
    	cOrdem := STRZERO(1, 3)
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se já existe gatilho para o campo, caso exista, verifica³
	//³se o mesmo possui a mesma regras e o mesmo contra dominio        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX7")
    dbSetorder(1)
    dbGoTop() 
    lInclui := .F.
    If dbSeek(&("SX7"+ALLTRIM(cProjFSW)+"->X7_CAMPO"))
    	While (SX7->(!EOF()) .AND. SX7->X7_CAMPO == &("SX7"+ALLTRIM(cProjFSW)+"->X7_CAMPO"))   
			If (SX7->X7_REGRA != &("SX7"+ALLTRIM(cProjFSW)+"->X7_REGRA") .OR. SX7->X7_CDOMIN != &("SX7"+ALLTRIM(cProjFSW)+"->X7_CDOMIN"))
			   lInclui := .T.    
			Else
				lInclui := .F. 
				exit
			EndIf 
			SX7->(dbSkip())		
		End                    
	Else
		lInclui := .T.
    EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o gatilho posicionado na tabela auxiliar somente se o mesmo nao existir no SX7 da empresa logada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lInclui

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica atualização do log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAtualiza  
			cTextAux += hEnter
			cTextAux += "     ADICIONADOS OS GATILHOS: "  
			cTextAux += hEnter
			cTextAux += hEnter
			lAtualiza := .T.
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa procedimentos de backup do SX que esta sendo manipulado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBackup
				MAKEDIR( cDirBKP )
				MAKEDIR( cDirBKP + "empresa"+cEmpAnt )
				_cArqDest := cDirBKP + "\empresa" + cEmpAnt + "\bkp_sx7" + cEmpAnt + "0.dtc"
				If lLinux
					_cArqDest := StrTran(_cArqDest,"\","/")
				Endif
				Copy to &_cArqDest VIA "CTREECDX"                            
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetuado atualização do item posicionado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RECLOCK("SX7", .T.)		    
		    SX7->X7_CAMPO   := &("SX7"+ALLTRIM(cProjFSW)+"->X7_CAMPO")
			SX7->X7_SEQUENC	:= cOrdem
			SX7->X7_REGRA	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_REGRA")
			SX7->X7_CDOMIN	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_CDOMIN")
			SX7->X7_TIPO	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_TIPO")
			SX7->X7_SEEK	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_SEEK")
			SX7->X7_ALIAS	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_ALIAS")
			SX7->X7_ORDEM	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_ORDEM")
			SX7->X7_CHAVE	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_CHAVE")
			SX7->X7_CONDIC	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_CONDIC")
			SX7->X7_PROPRI	:= &("SX7"+ALLTRIM(cProjFSW)+"->X7_PROPRI")
		SX7->(MSUNLOCK())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registra gatilho na variavel de controle do log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTextAux += "     " + &("SX7"+ALLTRIM(cProjFSW)+"->X7_CAMPO") + "  " + &("SX7"+ALLTRIM(cProjFSW)+"->X7_SEQUENCIA") + "  " + SUBSTR(&("SX7"+ALLTRIM(cProjFSW)+"->X7_REGRA"), 1, 35)
		cTextAux += hEnter
	EndIf   
	dbSelectArea("SX7"+ALLTRIM(cProjFSW))
	dbSkip()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ„
	//³Atualiza barra de status do SX7³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProcess:IncRegua1("Atualizando Dicionário de Gatilhos (SX7)")
End                                                          
           
SLEEP(5000)
cTextAux += IIF(!EMPTY(cTextAux),hEnter,cTextAux)

Return cTextAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UPDAtuSXA  ºAutor  ³FSW Resultar       º Data ³  13/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função de atualização dos folders (SXA)                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW			                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***--------------------***
Static Function UPDAtuSXA()                                                
***--------------------***

Local lAtualiza	:= .F.
Local lInclui	:= .F.
Local cTextAux 	:= ""
Local hEnter    := chr(13)+chr(10)
Local cPath                     
Local cOrdem	:= "0"      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SXA que contem todos os gatilhos de campos					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "SXA"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS +"sxa"+ALLTRIM(cProjFSW)+".dtc", "SXA"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SXA"+ALLTRIM(cProjFSW))  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta para manipulação o SXA da empresa logada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SXA")
dbSetOrder(1)       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa laço o qual aplicará todos os gatilhos ³
//³no SXB da empresa logada  					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SXA"+ALLTRIM(cProjFSW))
dbGoTop()
While !EOF()
    	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona a pasta posicionada na tabela auxiliar somente se a mesma nao existir no SXA da empresa logada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lInclui := .T.
	dbSelectArea("SXA")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(&("SXA"+ALLTRIM(cProjFSW)+"->XA_ALIAS"))
		While (SXA->(!EOF()) .AND. SXA->XA_ALIAS == &("SXA"+ALLTRIM(cProjFSW)+"->XA_ALIAS"))
			If SXA->XA_DESCRIC == &("SXA"+ALLTRIM(cProjFSW)+"->XA_DESCRIC")
				lInclui := .F.			   
				exit
			Else
				cOrdem := SXA->XA_ORDEM
			EndIf 				           
			SXA->(dbSkip())
		End
	EndIf
	If lInclui
		cOrdem := SOMA1(cOrdem)                  
		
		If !lAtualiza  
			cTextAux += hEnter
			cTextAux += "     ADICIONADOS OS FOLDERS: "  
			cTextAux += hEnter
			cTextAux += hEnter
			lAtualiza := .T.
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa procedimentos de backup do SX que esta sendo manipulado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBackup
				MAKEDIR( cDirBKP )
				MAKEDIR( cDirBKP + "empresa"+cEmpAnt )
				_cArqDest := cDirBKP + "\empresa" + cEmpAnt + "\bkp_sxa" + cEmpAnt + "0.dtc"
				If lLinux
					_cArqDest := StrTran(_cArqDest,"\","/")
				Endif
				Copy to &_cArqDest VIA "CTREECDX"                            
			EndIf
		EndIf
		
		RECLOCK("SXA", .T.)		    
		    SXA->XA_ALIAS	:= &("SXA"+ALLTRIM(cProjFSW)+"->XA_ALIAS")
			SXA->XA_ORDEM	:= cOrdem
			SXA->XA_DESCRIC	:= &("SXA"+ALLTRIM(cProjFSW)+"->XA_DESCRIC")
			SXA->XA_DESCSPA	:= &("SXA"+ALLTRIM(cProjFSW)+"->XA_DESCSPA")
			SXA->XA_DESCENG	:= &("SXA"+ALLTRIM(cProjFSW)+"->XA_DESCENG")
			SXA->XA_PROPRI	:= &("SXA"+ALLTRIM(cProjFSW)+"->XA_PROPRI")
		SXA->(MSUNLOCK())   
		
		cOrdem	:= "0"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registra gatilho na variavel de controle do log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTextAux += "     " + &("SXA"+ALLTRIM(cProjFSW)+"->XA_ALIAS") + "  " + &("SXA"+ALLTRIM(cProjFSW)+"->XA_ORDEM") + "  " + UPPER(&("SXA"+ALLTRIM(cProjFSW)+"->XA_DESCRIC"))
		cTextAux += hEnter
	EndIf   
	dbSelectArea("SXA"+ALLTRIM(cProjFSW))
	dbSkip()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ„
	//³Atualiza barra de status do SXA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProcess:IncRegua1("Atualizando Dicionário de Folders (SXA)") 
End                                                          

SLEEP(5000)
cTextAux += IIF(!EMPTY(cTextAux),hEnter,cTextAux)

Return cTextAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UPDAtuSXB  ºAutor  ³FSW Resultar       º Data ³  13/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsavel pela atualização de consultas padrões    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW			                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
***--------------------***
Static Function UPDAtuSXB()
***--------------------***                                                

Local lAtualiza	:= .F.
Local lInclui	:= .F.
Local cTextAux 	:= ""
Local hEnter    := chr(13)+chr(10)
Local cPath                     
Local cOrdem      
Local cConsulta := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SXB que contem todos os gatilhos de campos					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "SXB"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS +"sxb"+ALLTRIM(cProjFSW)+".dtc", "SXB"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SXB"+ALLTRIM(cProjFSW))  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta para manipulação o SXB da empresa logada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SXB")
dbSetOrder(1)       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa laço o qual aplicará todos os gatilhos ³
//³no SXB da empresa logada  					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SXB"+ALLTRIM(cProjFSW))
dbGoTop()
While !EOF()
	If !(cConsulta == &("SXB"+ALLTRIM(cProjFSW)+"->XB_ALIAS"))
		dbSelectArea("SXB")
	    dbSetorder(1)
	    dbGoTop() 
	    lInclui := .F.
	    If !dbSeek(&("SXB"+ALLTRIM(cProjFSW)+"->XB_ALIAS"))
	    	lInclui := .T. 
	    	cConsulta := &("SXB"+ALLTRIM(cProjFSW)+"->XB_ALIAS")
	    	
	    	If !lAtualiza  
				cTextAux += hEnter
				cTextAux += "     ADICIONADO AS CONSULTAS PADROES: "  
				cTextAux += hEnter
				cTextAux += hEnter
				lAtualiza := .T.
			
				//
				//Executa procedimentos de backup do SX que esta sendo manipulado
				//
				If lBackup
					MAKEDIR( cDirBKP )
					MAKEDIR( cDirBKP + "empresa"+cEmpAnt )
					_cArqDest := cDirBKP + "\empresa" + cEmpAnt + "\bkp_sxb" + cEmpAnt + "0.dtc"
					If lLinux
						_cArqDest := StrTran(_cArqDest,"\","/")
					Endif
					Copy to &_cArqDest VIA "CTREECDX"                            
				EndIf
			EndIf 
		Else
			cConsulta := NIL
	    EndIf
	    
	    If cConsulta != Nil
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registra consulta padrao na variavel de controle do log³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTextAux += "     " + cConsulta 
			cTextAux += hEnter
	    EndIf
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o a consulta padrão posicionada na tabela auxiliar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lInclui			
		RECLOCK("SXB", .T.)		    
			SXB->XB_ALIAS		:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_ALIAS")
			SXB->XB_TIPO		:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_TIPO")
			SXB->XB_SEQ			:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_SEQ")
			SXB->XB_COLUNA		:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_COLUNA")
			SXB->XB_DESCRI		:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_DESCRI")
			SXB->XB_DESCSPA		:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_DESCSPA")
			SXB->XB_DESCENG		:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_DESCENG")
			SXB->XB_CONTEM		:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_CONTEM")
			SXB->XB_WCONTEM		:= &("SXB"+ALLTRIM(cProjFSW)+"->XB_WCONTEM")
		SXB->(MSUNLOCK())
	EndIf   
	dbSelectArea("SXB"+ALLTRIM(cProjFSW))
	dbSkip()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ„
	//³Atualiza barra de status do SXB³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProcess:IncRegua1("Atualizando Dicionário de Consultas Padrões (SXB)")
End                                                          
           
SLEEP(5000)
cTextAux += IIF(!EMPTY(cTextAux),hEnter,cTextAux)

Return cTextAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PROCUPD   ºAutor  ³FSW Resultar        º Data ³  13/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsavel por executar a função de aplicação do    º±±
±±º          ³Dicionario de Dados através de apresentaçao em componente   º±±
±±º          ³ MsNewProcess para que o usuario possa estar acompanhando   º±±
±±º          ³a execução do UPDATE							  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW				                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        
***-----------------***
Static Function PROCUPD()
***-----------------***                                     
Private nProcessa := 0

IF b00101SX1
	nProcessa += UPDNUMREGS("SX1",.F.)
ENDIF
IF b00101SX2
	nProcessa += UPDNUMREGS("SX2",.F.)
ENDIF
IF b00101SX3
	nProcessa += UPDNUMREGS("SX3",.F.)
ENDIF
IF b00101SX6
	nProcessa += UPDNUMREGS("SX6",.F.)
ENDIF
IF b00101SX7
	nProcessa += UPDNUMREGS("SX7",.F.)
ENDIF                           
IF b00101SXA
	nProcessa += UPDNUMREGS("SXA",.F.)
ENDIF                           
IF b00101SXB
	nProcessa += UPDNUMREGS("SXB",.F.)
ENDIF                           
IF b00101SIX
	nProcessa += UPDNUMREGS("SIX",.F.)
ENDIF       

IF b00101OK
	_oProcess := MsNewProcess():New({|| UPDProc()},"Atualizando Dicionário de Dados","Abrindo Arquivos",.F.)
	_oProcess:Activate ()                                                        
ENDIF

Return b00101OK

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UPDNUMREGS   ºAutor  ³FSW Resultarr      º Data ³  13/05/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsavel por retornar o numero de registros exis- º±±
±±º          ³tentes na tabela auxiliar repassada como parametro          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW			                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***----------------------------***
Static Function UPDNUMREGS(cItem,bRetVld)
***----------------------------***

Local nRegs := 0       
Local xRet
Local cDir	:= cDirDADOS

cItem := cItem + ALLTRIM(cProjFSW)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica existencia do arquivo fisico	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Select( cItem ) > 0
	DbSelectArea( cItem )
	DbCloseArea( )
EndIf

IF FILE(UPPER(cDir + cItem + ".dtc")) .OR. FILE(LOWER(cDir + cItem + ".dtc"))
	dbUseArea(.T., "CTREECDX", cDir + cItem + ".dtc", cItem, .F., .F.)       
	dbSelectArea(cItem)  
	                               
	IF bRetVld
		xRet := .T.
	ELSE
		xRet := (cItem)->(RECCOUNT())  		
	ENDIF	
ELSE
	b00101OK := .F.              
	IF !bRetVld
		MSGALERT("Arquivo não encontrado: "+LOWER(cDir + cItem + ".dtc"))	
	ELSE
		xRet := .F.
	ENDIF
ENDIF     

If Select( cItem ) > 0
	DbSelectArea( cItem )
	DbCloseArea( )
EndIf

Return xRet

 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PROCHELP  ºAutor  ³FSW Resultar	     º Data ³  20/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina responsavel por analisar o SX3 o qual contem os   º±±
±±º          ³campos com base na relação dos mesmos procura na base e     º±±
±±º          ³adiciona a uma nova tabela (arquivo) auxiliar o help de 	  º±±
±±º          ³todos os campos presentes no SX3, serao utilizados		  º±± 
±±º          ³para criação dos campos do UPD.							  º±±
±±º          ³															  º±±   
±±º          ³															  º±±
±±º          ³OBSERVAÇÃO: O MESMO DEVE SER EXECUTADO PELO REMOTE EM MODO  º±±
±±º          ³EXCLUSIVO													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW				                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Static Function PROCHELP()
                                                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura da tabela HELP1 a qual será criada com os helps dos campos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aStru	:= {{'HELP_CAMPO', 'C', 10, 0}, {'HELP_HELP', 'C', 950, 0} }
Local n		:= 0  
Local cHelp	:= ""
Local aHelp	:= {}
Local i

Public cProjFSW		:= SUBSTR(ALLTRIM(PROCNAME()),6,5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
//³Cria a nova tabela no RootPath do ambiente, ou seja, \Protheus_Data\³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC 
dbCreate(cDirDADOS + 'help'+ALLTRIM(cProjFSW)+'.dtc', aStru,'CTREECDX') 
Use cDirDADOS + 'help'+ALLTRIM(cProjFSW)+'.dtc' Via 'CTREECDX' New 

dbSelectArea("HELP"+ALLTRIM(cProjFSW))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega a tabela auxiliar SX3 que possui todas os campos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "SX3"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

dbUseArea(.T., "CTREECDX", cDirDADOS + "sx3"+ALLTRIM(cProjFSW)+".dtc", "SX3"+ALLTRIM(cProjFSW), .F., .F.)
dbSelectArea("SX3"+ALLTRIM(cProjFSW))    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta variaveis necessarias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
__TTSINUSE := .F.  
__TTSPUSH	:= {}
__CLOGSIGA	:= "NNNNNNN" 
CARQHLP	:= "SIGAHLP.HLP" 
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄd¿
//³Inicia a busca/gravacao dos Helps de campos conforme todos os campos existentes no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄdÙ
dbSelectArea("SX3"+ALLTRIM(cProjFSW))
dbGoTop()
While !EOF()
	RECLOCK("HELP"+ALLTRIM(cProjFSW), .T.)
    	&("HELP"+ALLTRIM(cProjFSW)+"->HELP_CAMPO") := &("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO")
    	&("HELP"+ALLTRIM(cProjFSW)+"->HELP_HELP")  := AP5GETHELP(&("SX3"+ALLTRIM(cProjFSW)+"->X3_CAMPO"))
	
		aHelp := STRTOKARR(&("HELP"+ALLTRIM(cProjFSW)+"->HELP_HELP"), CHR(10))		
		cHelp := ""      

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicia uma regra de tratamento no Help obtido do campo para eliminar trechos repetidos e ³
		//³tambem sequencia de espaços em branco.                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		i   := 2     
		j 	:= 1
		nAux  := Len(aHelp) 
		lVerifica := .T.

   	 	While lVerifica
   	 		If i <= Len(aHelp)
		   	 	If (((aHelp[i] $ aHelp[j])  .AND. (i != j)) .OR. (Len(ALLTRIM(aHelp[i])) == 0))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Deleta o item do array³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					ADEL(aHelp, i)              
					j++       
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Reorganiza o array³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ASIZE(aHelp,(nAux - 1))    
					nAux := Len(aHelp)  
					If i > nAux
						exit
					Else
						i := 1
					EndIf   
				Else
					i++
				EndIf
			Else
				exit
			EndIf
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o help do campo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i := 1 To Len(aHelp)    
			cHelp += aHelp[i]
		Next i

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atribui o help do campo pronto ao campo da tabela onde o mesmo será gravado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		&("HELP"+ALLTRIM(cProjFSW)+"->HELP_HELP")  := cHelp

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Confirma a gravação do help na tabela HELP e avanca para o proximo campo existente no SX3³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("HELP"+ALLTRIM(cProjFSW))
		MSUNLOCK()  
		dbSelectArea("SX3"+ALLTRIM(cProjFSW))
		dbSkip()
End                                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fecha as tabelas utilizadas/manipuladas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasTmp := "SX3"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

cAliasTmp := "HELP"+ALLTRIM(cProjFSW)
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	DbCloseArea( )
EndIf

Alert("HELPS FINALIZADO")

Return Nil  
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MSGHELP      ºAutor  ³FSW Resultarº     Data ³  13/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de apresentação de tela estilo (HELP) do Protheus.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FSW			                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±± 
±±ºParametros³cTitulo   = Titulo o qual será apresentado na tela          º±±
±± 			 ³cProblema = Descrição do problema validado				  º±±
±±			 ³cSolucao  = Descrição da solução para o problema validado   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        
***----------------------------------------------------***
Static Function MSGHELP( pcTitulo, pcProblema, pcSolucao )
***----------------------------------------------------***
Local cAux		:= ""
Local aSvKeys   := GetKeys()  
Local cTema     := GetTheme()
Local oFont     := TFont():New("",, -14,, .T.) 
Local oDlgHLP     
Local oPanel   
Local oSProbA
Local oSSoluA     
Local oSProbB
Local oSSoluB         
                                                                              
Tone()
ShowHelpDlg( TRANSFORM(pcTitulo, "@!"),  {pcProblema}, 5, {pcSolucao}, 5)

RestKeys( aSvKeys , .T. )

Return Nil 



***----------------------------------------------------***
Static Function UPD011X(cEmp,cFil)
***----------------------------------------------------***
Local hEnter    := chr(13)+chr(10)
Local cMsg 		:= +hEnter
Local aTabelas 	:= {}
Local cTab 		:= ""
Local cStatement	:= ""
Local nHndBD 		:= 0
Local i
Local lDB2  		:= "DB2" $ TCGetDB()
Local lSQL  		:= "MSSQL" $ TCGetDB()
Local lORA  		:= "ORACLE" $ TCGetDB()

Default cEmp := ""
Default cFil := ""

ConOut("UPD011X - INICIO")

ConOut("Empresa/Filial: "+ cEmp +"/"+ cFil )
If Empty(cEmp + cFil)
	Return(cMsg)
Endif

If ! ( lDB2 .or. lSQL .or. lORA )
	MsgStop("Banco de Dados nao tratado para Trigger! "+ TCGetDB() )
	cMsg += "Banco de Dados nao tratado para Trigger! "+ TCGetDB() +hEnter
	Return(cMsg)
Else
	cMsg += TCGetDB() +hEnter +hEnter
Endif

cMsg += "Criando Trigger nas tabelas: "+ cTabTrigg +hEnter
ConOut(cMsg)

aTabelas := Separa(cTabTrigg,"/",.F.)

For i := 1 to Len(aTabelas)
	
	cTab := RetSqlName(aTabelas[i])
	ConOut("-> Tabela "+ cTab )
	cMsg += "-> Tabela: "+ cTab +" "
	
	cNomeTrigg := "TG_"+ cTab
	cNomeCampo := IF( Substr(cTab,1,1)=="S", Substr(cTab,2,2), Substr(cTab,1,3)) +"_X_EXPO"
	cStatement := ""
	
	Do Case
	Case lDB2
		
		If ! TemTrigger(cNomeTrigg,"DB2")
			//cStatement += "CREATE OR REPLACE TRIGGER "+ cNomeTrigg +" " + hEnter
			cStatement += "CREATE TRIGGER "+ cNomeTrigg +" " + hEnter
			cStatement += "BEFORE UPDATE ON "+ RetSqlName(aTabelas[i]) +" " + hEnter
			cStatement += "REFERENCING NEW AS N OLD AS O " + hEnter
			cStatement += "FOR EACH ROW MODE DB2SQL " + hEnter
			cStatement += "WHEN (O."+ cNomeCampo +" = 'S') " + hEnter
			cStatement += " SET  N."+ cNomeCampo +" = ' ' " + hEnter
		Else
			cMsg += "TRIGGER JA EXISTE" +hEnter
			ConOut("   TRIGGER JA EXISTE")
		Endif
		
	Case lSQL
		
		DelTrigger(cNomeTrigg,"SQL")
		
		cStatement += "CREATE TRIGGER "+ cNomeTrigg +" " 					+ hEnter
		cStatement += "ON "+ cTab +" FOR UPDATE AS " 						+ hEnter
		cStatement += "BEGIN " 												+ hEnter
		cStatement += "	IF @@ROWCOUNT = 0 RETURN " 							+ hEnter
		//Trata especifidade SA1
		If Substr(cTab,1,3) == "SA1"
			cStatement += "	IF NOT UPDATE(A1_FILIAL) AND NOT UPDATE(A1_COD) AND NOT UPDATE(A1_LOJA) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_NOME) AND NOT UPDATE(A1_NREDUZ) AND NOT UPDATE(A1_PESSOA) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_END) AND NOT UPDATE(A1_ENDCOB) AND NOT UPDATE(A1_ENDENT) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_BAIRRO) AND NOT UPDATE(A1_BAIRROC) AND NOT UPDATE(A1_BAIRROE) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_COMPLEM) AND NOT UPDATE(A1_TIPO) AND NOT UPDATE(A1_EST) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_ESTC) AND NOT UPDATE(A1_ESTE) AND NOT UPDATE(A1_CEP) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_CEPC) AND NOT UPDATE(A1_CEPE) AND NOT UPDATE(A1_COD_MUN) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_CODMUNE) AND NOT UPDATE(A1_MUN) AND NOT UPDATE(A1_REGIAO) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_DDD) AND NOT UPDATE(A1_DDI) AND NOT UPDATE(A1_TEL) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_FAX) AND NOT UPDATE(A1_TELEX) AND NOT UPDATE(A1_CONTATO) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_CGC) AND NOT UPDATE(A1_RG) AND NOT UPDATE(A1_PFISICA) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_INSCR) AND NOT UPDATE(A1_INSCRM) AND NOT UPDATE(A1_INSCRUR) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_PAIS) AND NOT UPDATE(A1_DTNASC) AND NOT UPDATE(A1_EMAIL) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_HPAGE) AND NOT UPDATE(A1_CNAE) AND NOT UPDATE(A1_MSBLQL) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_VEND) AND NOT UPDATE(A1_TPFRET) AND NOT UPDATE(A1_TRANSP) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_COND) AND NOT UPDATE(A1_RISCO) AND NOT UPDATE(A1_LC) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_LCFIN) AND NOT UPDATE(A1_VENCLC) AND NOT UPDATE(A1_TABELA) AND " + hEnter
			cStatement += "	 NOT UPDATE(A1_OBSERV) AND NOT UPDATE(A1_GRPVEN) AND NOT UPDATE(A1_DTCAD) AND  " + hEnter
			cStatement += "	 NOT UPDATE(A1_HRCAD) AND NOT UPDATE(A1_CALCSUF)  RETURN " + hEnter  
		EndIf
		cStatement += "	DECLARE @old VARCHAR(1) " 							+ hEnter
		cStatement += "	SELECT  @old = ["+ cNomeCampo +"] FROM DELETED " 	+ hEnter
		cStatement += "	DECLARE @id INT " 									+ hEnter
		cStatement += "	SELECT  @id = [R_E_C_N_O_] FROM INSERTED " 			+ hEnter
		cStatement += "	UPDATE "+ cTab    +" "								+ hEnter
		cStatement += "	SET    "+ cNomeCampo +" = ' ' " 					+ hEnter
		cStatement += "	WHERE  "+ cTab    +".R_E_C_N_O_ = @id "				+ hEnter
		cStatement += "	AND @old = 'S' " 									+ hEnter
		cStatement += "END;" 												+ hEnter
		
	Case lORA
		
		cStatement += "CREATE OR REPLACE TRIGGER "+ cNomeTrigg +" "	+ hEnter
		cStatement += "BEFORE UPDATE " 								+ hEnter
		cStatement += "ON " + RetSqlName(aTabelas[i]) +" " 			+ hEnter
		cStatement += "REFERENCING NEW AS NEW OLD AS OLD " 			+ hEnter
		cStatement += "FOR EACH ROW"								+ hEnter
			
		//Trata especifidade SA1
		If Substr(cTab,1,3) == "SA1"
			
			cStatement += "BEGIN " 																			+ hEnter
			cStatement += "	IF UPDATING('A1_FILIAL') OR UPDATING('A1_COD') OR UPDATING('A1_LOJA') OR " 		+ hEnter
			cStatement += "	 UPDATING('A1_NOME') OR UPDATING('A1_NREDUZ') OR UPDATING('A1_PESSOA') OR " 	+ hEnter
			cStatement += "	 UPDATING('A1_END') OR UPDATING('A1_ENDCOB') OR UPDATING('A1_ENDENT') OR " 		+ hEnter
			cStatement += "	 UPDATING('A1_BAIRRO') OR UPDATING('A1_BAIRROC') OR UPDATING('A1_BAIRROE') OR " + hEnter
			cStatement += "	 UPDATING('A1_COMPLEM') OR UPDATING('A1_TIPO') OR UPDATING('A1_EST') OR " 		+ hEnter
			cStatement += "	 UPDATING('A1_ESTC') OR UPDATING('A1_ESTE') OR UPDATING('A1_CEP') OR " 			+ hEnter
			cStatement += "	 UPDATING('A1_CEPC') OR UPDATING('A1_CEPE') OR UPDATING('A1_COD_MUN') OR " 		+ hEnter
			cStatement += "	 UPDATING('A1_CODMUNE') OR UPDATING('A1_MUN') OR UPDATING('A1_REGIAO') OR " 	+ hEnter
			cStatement += "	 UPDATING('A1_DDD') OR UPDATING('A1_DDI') OR UPDATING('A1_TEL') OR " 			+ hEnter
			cStatement += "	 UPDATING('A1_FAX') OR UPDATING('A1_TELEX') OR UPDATING('A1_CONTATO') OR " 		+ hEnter
			cStatement += "	 UPDATING('A1_CGC') OR UPDATING('A1_RG') OR UPDATING('A1_PFISICA') OR " 		+ hEnter
			cStatement += "	 UPDATING('A1_INSCR') OR UPDATING('A1_INSCRM') OR UPDATING('A1_INSCRUR') OR " 	+ hEnter
			cStatement += "	 UPDATING('A1_PAIS') OR UPDATING('A1_DTNASC') OR UPDATING('A1_EMAIL') OR " 		+ hEnter
			cStatement += "	 UPDATING('A1_HPAGE') OR UPDATING('A1_CNAE') OR UPDATING('A1_MSBLQL') OR " 		+ hEnter
			cStatement += "	 UPDATING('A1_VEND') OR UPDATING('A1_TPFRET') OR UPDATING('A1_TRANSP') OR " 	+ hEnter
			cStatement += "	 UPDATING('A1_COND') OR UPDATING('A1_RISCO') OR UPDATING('A1_LC') OR " 			+ hEnter
			cStatement += "	 UPDATING('A1_LCFIN') OR UPDATING('A1_VENCLC') OR UPDATING('A1_TABELA') OR " 	+ hEnter
			cStatement += "	 UPDATING('A1_OBSERV') OR UPDATING('A1_GRPVEN') OR UPDATING('A1_DTCAD') OR  " 	+ hEnter
			cStatement += "	 UPDATING('A1_HRCAD') OR UPDATING('A1_CALCSUF')  THEN " 						+ hEnter  				
			cStatement +=		":NEW."+ cNomeCampo +" := ' '; "											+ hEnter
			cStatement += " END IF; "																		+ hEnter
			cStatement += "END; "	 																		+ hEnter
			
		Else
			
			//Demais tabelas
			cStatement += "WHEN (OLD."+ cNomeCampo +" = 'S' ) "		+ hEnter
			cStatement += "BEGIN "									+ hEnter
			cStatement += ":NEW."+ cNomeCampo +" := ' '; " 			+ hEnter			
			cStatement += "END; "	 								+ hEnter					
		Endif		
		
	EndCase
	
	If ! Empty(cStatement)
		If (TCSQLExec(cStatement) < 0)
			ConOut( TCSQLError() )
			MsgStop( TCSQLError() )
			cMsg += hEnter + TCSQLError()
			Exit
		Else
			cMsg += " OK "+ hEnter
		EndIf
	Endif
Next i

ConOut("UPD011X - FIM")

Return(cMsg)



Static Function TemTrigger(cNomeTrigg, cDB)

Local	lRet	:= .F.
Local	aArea	:= GetArea()
Local	cSql	:= ""

Do Case
	Case cDB == "DB2"
		cSql := "SELECT COUNT(*) QTD "
		cSql += "FROM SYSIBM.SYSTRIGGERS "
		cSql += "WHERE NAME = '"+ cNomeTrigg +"' "
		
	Case cDB == "SQL"
		cSql := "SELECT COUNT(*) QTD FROM sys.objects WHERE type = 'TR' and name = '"+ cNomeTrigg +"';"
		
	Case cDB == "ORA"
	
EndCase

If ! Empty(cSql)
	TCQUERY cSql NEW ALIAS "SQLTRG"
	If SQLTRG->QTD > 0
		lRet := .T.
	Endif
	dbCloseArea("SQLTRG")
Endif
RestArea(aArea)

Return(lRet)



Static Function DelTrigger(cNomeTrigg, cDB)

Local	lRet	:= .F.
Local	cSql	:= ""

Do Case
	Case cDB == "DB2"
		ConOut("Excluindo a TRIGGER - ADMINISTRADOR."+ cNomeTrigg)
		cSql := "DROP TRIGGER ADMINISTRADOR."+ cNomeTrigg
		
	Case cDB == "SQL"
		
		ConOut("Excluindo a TRIGGER - "+ cNomeTrigg)
		cSql := "IF OBJECT_ID ('["+ cNomeTrigg +"]', 'TR') IS NOT NULL "
		cSql += "  DROP TRIGGER ["+ cNomeTrigg +"];"
		
	Case cDB == "ORA"
		ConOut("Excluindo a TRIGGER - "+ cNomeTrigg)
		cSql := "DROP TRIGGER "+ cNomeTrigg
EndCase

If ! Empty(cSql)
	If (TCSQLExec(cSql) < 0)
		ConOut( TCSQLError() )
		MsgStop( TCSQLError() )
	Else
		conout("Excluido TRIGGER "+ cNomeTrigg +" com sucesso")
		lRet := .T.
	EndIf
Endif

Return(lRet)



Static Function UPDAtuTab()
Local cQuery	:= ""
Local hEnter	:= CHR(13) + CHR(10)
Local cMsg		:= ""

cMsg := hEnter + "Executando UPDATE nos campos ??_X_SIM3G = 'S' nas tabelas: "+ hEnter
ConOut(cMsg)

//Atualizacao tabela SA1
cQuery := ""
cQuery := " UPDATE " + RetSQLName("SA1") 
cQuery += " SET "
cQuery += "		A1_X_SIM3G = 'S' "
cQuery += " WHERE "
cQuery += "		D_E_L_E_T_ = ' ' "

If ! Empty(cQuery)
	If (TCSQLExec(cQuery) < 0)
		ConOut( TCSQLError() )
		cMsg += "  UPDATE SA1 - ERRO: "+ TCSQLError()+ hEnter
		lTemErro := .T.
	Else
		cMsg += "  UPDATE SA1 - OK "+ hEnter
	EndIf
Endif


//Atualizacao tabela SA3
cQuery := ""
cQuery := " UPDATE " + RetSQLName("SA3") 
cQuery += " SET "
cQuery += "		A3_X_SIM3G = 'S' "
cQuery += " WHERE "
cQuery += "		D_E_L_E_T_ = ' ' "

If ! Empty(cQuery)
	If (TCSQLExec(cQuery) < 0)
		ConOut( TCSQLError() )
		cMsg += "  UPDATE SA3 - ERRO: "+ TCSQLError()+ hEnter
		lTemErro := .T.
	Else
		cMsg += "  UPDATE SA3 - OK "+ hEnter
	EndIf
Endif


//Atualizacao tabela SB1
cQuery := " UPDATE " + RetSQLName("SB1") 
cQuery += " SET "
cQuery += "		B1_X_SIM3G = 'S' "
cQuery += " WHERE "
cQuery += "		D_E_L_E_T_ = ' ' "

If ! Empty(cQuery)
	If (TCSQLExec(cQuery) < 0)
		ConOut( TCSQLError() )
		cMsg += "  UPDATE SB1 - ERRO: "+ TCSQLError()+ hEnter
		lTemErro := .T.
	Else
		cMsg += "  UPDATE SB1 - OK "+ hEnter
	EndIf
Endif	


//Atualizacao tabela SBM
cQuery := ""
cQuery := " UPDATE " + RetSQLName("SBM") 
cQuery += " SET "
cQuery += "		BM_X_SIM3G = 'S' "
cQuery += " WHERE "
cQuery += "		D_E_L_E_T_ = ' ' "

If ! Empty(cQuery)
	If (TCSQLExec(cQuery) < 0)
		ConOut( TCSQLError() )
		cMsg += "  UPDATE SBM - ERRO: "+ TCSQLError()+ hEnter
		lTemErro := .T.
	Else
		cMsg += "  UPDATE SBM - OK "+ hEnter
	EndIf
Endif


//Atualizacao tabela DA0
cQuery := ""
cQuery := " UPDATE " + RetSQLName("DA0") 
cQuery += " SET "
cQuery += "		DA0_X_SIM3 = 'S' "
cQuery += " WHERE "
cQuery += "		D_E_L_E_T_ = ' ' "

If ! Empty(cQuery)
	If (TCSQLExec(cQuery) < 0)
		ConOut( TCSQLError() )
		cMsg += "  UPDATE DA0 - ERRO: "+ TCSQLError()+ hEnter
		lTemErro := .T.
	Else
		cMsg += "  UPDATE DA0 - OK "+ hEnter
	EndIf
Endif


//Atualizacao tabela DA1
cQuery := ""
cQuery := " UPDATE " + RetSQLName("DA1") 
cQuery += " SET "
cQuery += "		DA1_X_SIM3 = 'S' "
cQuery += " WHERE "
cQuery += "		D_E_L_E_T_ = ' ' "

If ! Empty(cQuery)
	If (TCSQLExec(cQuery) < 0)
		ConOut( TCSQLError() )
		cMsg += "  UPDATE DA1 - ERRO: "+ TCSQLError()+ hEnter
		cMsg += hEnter + TCSQLError()
		lTemErro := .T.
	Else
		cMsg += "  UPDATE DA1 - OK "+ hEnter
	EndIf
Endif


//Atualizacao tabela NNR
cQuery := ""
cQuery := " UPDATE " + RetSQLName("NNR") 
cQuery += " SET "
cQuery += "		NNR_X_SIM3 = 'S' "
cQuery += " WHERE "
cQuery += "		D_E_L_E_T_ = ' ' "

If ! Empty(cQuery)
	If (TCSQLExec(cQuery) < 0)
		ConOut( TCSQLError() )
		cMsg += "  UPDATE NNR - ERRO: "+ TCSQLError()+ hEnter
		lTemErro := .T.
	Else
		cMsg += "  UPDATE NNR - OK "+ hEnter
	EndIf
Endif


//Atualizacao tabela SE4
cQuery := ""
cQuery := " UPDATE " + RetSQLName("SE4") 
cQuery += " SET "
cQuery += "		E4_X_SIM3G = 'S' "
cQuery += " WHERE "
cQuery += "		D_E_L_E_T_ = ' ' "

If ! Empty(cQuery)
	If (TCSQLExec(cQuery) < 0)
		ConOut( TCSQLError() )
		cMsg += "  UPDATE SE4 - ERRO: "+ TCSQLError()+ hEnter
		lTemErro := .T.
	Else
		cMsg += "  UPDATE SE4 - OK "+ hEnter
	EndIf
Endif

cMsg += hEnter
ConOut(hEnter)

Return( cMsg )



Static Function fProxOrd( cTab )

Local cRet  	:= "0"
Local aAreaSIX	:= SIX->(GetArea())

If ! empty(cTab)
	SIX->( dbSetOrder(1) )
	SIX->( dbSeek(cTab) )
	While ! SIX->( EOF() ) .and. SIX->INDICE == cTab
		cRet := SIX->ORDEM
		SIX->( dbSkip() )
	Enddo
	RestArea(aAreaSIX)
Endif
cRet := Soma1(cRet)

Return(cRet)



//********************************************************************
// Função específica para atualizar a TRIGGER de uma ou mais tabelas
// cTabelas: informe o alias das tabelas (Ex: SA1/SA2)
// cEmp: informe o código da empresa (Ex: 01)
// U_UPD011T("SA1","01")
User Function UPD011T(cTabelas,cEmp)

Local lDB2  		:= "DB2" $ TCGetDB()
Local lSQL  		:= "MSSQL" $ TCGetDB()
Local lORA  		:= "ORACLE" $ TCGetDB()
Local aTabelas		:= {}
Local cTab 			:= ""
Local cNomeTrigg	:= ""
Local cNomeCampo	:= ""
Local cStatement	:= ""
Local i

Default cEmp     := cEmpAnt
Default cTabelas := ""

ConOut("UPD011T - Atualiza Trigger especifica")
If Empty(cEmp)
	MsgInfo("- Empresa nao informada")
	conout("- Empresa nao informada")
	Return
Endif
If Empty(cTabelas)
	MsgInfo("- Tabela nao informada")
	conout("- Tabela nao informada")
	Return
Endif

ConOut("- Empresa: "+ cEmp )
ConOut("- Tabelas: "+ cTabelas )

//If lSQL
	aTabelas := Separa(cTabelas,"/",.F.)

	For i := 1 to Len(aTabelas)
		
		cTab := Alltrim(aTabelas[i]) + cEmp +"0"
		cNomeTrigg := "TG_"+ cTab
		cNomeCampo := IF( Substr(cTab,1,1)=="S", Substr(cTab,2,2), Substr(cTab,1,3)) +"_X_EXPO"
		cStatement := ""
		
		Do Case
		Case lDB2
			
		Case lSQL
			DelTrigger(cNomeTrigg,"SQL")
			cStatement += "CREATE TRIGGER "+ cNomeTrigg +" " 					+ CRLF
			cStatement += "ON "+ cTab +" FOR UPDATE AS " 						+ CRLF
			cStatement += "BEGIN " 												+ CRLF
			cStatement += "	IF @@ROWCOUNT = 0 RETURN " 							+ CRLF
			
			//Trata especifidade SA1
			If Substr(cTab,1,3) == "SA1"
				cStatement += "	IF NOT UPDATE(A1_FILIAL) AND NOT UPDATE(A1_COD) AND NOT UPDATE(A1_LOJA) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_NOME) AND NOT UPDATE(A1_NREDUZ) AND NOT UPDATE(A1_PESSOA) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_END) AND NOT UPDATE(A1_ENDCOB) AND NOT UPDATE(A1_ENDENT) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_BAIRRO) AND NOT UPDATE(A1_BAIRROC) AND NOT UPDATE(A1_BAIRROE) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_COMPLEM) AND NOT UPDATE(A1_TIPO) AND NOT UPDATE(A1_EST) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_ESTC) AND NOT UPDATE(A1_ESTE) AND NOT UPDATE(A1_CEP) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_CEPC) AND NOT UPDATE(A1_CEPE) AND NOT UPDATE(A1_COD_MUN) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_CODMUNE) AND NOT UPDATE(A1_MUN) AND NOT UPDATE(A1_REGIAO) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_DDD) AND NOT UPDATE(A1_DDI) AND NOT UPDATE(A1_TEL) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_FAX) AND NOT UPDATE(A1_TELEX) AND NOT UPDATE(A1_CONTATO) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_CGC) AND NOT UPDATE(A1_RG) AND NOT UPDATE(A1_PFISICA) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_INSCR) AND NOT UPDATE(A1_INSCRM) AND NOT UPDATE(A1_INSCRUR) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_PAIS) AND NOT UPDATE(A1_DTNASC) AND NOT UPDATE(A1_EMAIL) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_HPAGE) AND NOT UPDATE(A1_CNAE) AND NOT UPDATE(A1_MSBLQL) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_VEND) AND NOT UPDATE(A1_TPFRET) AND NOT UPDATE(A1_TRANSP) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_COND) AND NOT UPDATE(A1_RISCO) AND NOT UPDATE(A1_LC) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_LCFIN) AND NOT UPDATE(A1_VENCLC) AND NOT UPDATE(A1_TABELA) AND " + CRLF
				cStatement += "	 NOT UPDATE(A1_OBSERV) AND NOT UPDATE(A1_GRPVEN) AND NOT UPDATE(A1_DTCAD) AND  " + CRLF
				cStatement += "	 NOT UPDATE(A1_HRCAD) AND NOT UPDATE(A1_CALCSUF)  RETURN " + CRLF  
			EndIf
			cStatement += "	DECLARE @old VARCHAR(1) " 							+ CRLF
			cStatement += "	SELECT  @old = ["+ cNomeCampo +"] FROM DELETED " 	+ CRLF
			cStatement += "	DECLARE @id INT " 									+ CRLF
			cStatement += "	SELECT  @id = [R_E_C_N_O_] FROM INSERTED " 			+ CRLF
			cStatement += "	UPDATE "+ cTab    +" "								+ CRLF
			cStatement += "	SET    "+ cNomeCampo +" = ' ' " 					+ CRLF
			cStatement += "	WHERE  "+ cTab    +".R_E_C_N_O_ = @id "				+ CRLF
			cStatement += "	AND @old = 'S' " 									+ CRLF
			cStatement += "END;" 												+ CRLF
			
		Case lORA
			ConOut( "Criando Trigger no banco Oracle" )
			
			DelTrigger(cNomeTrigg,"ORA")
			
			cStatement += "CREATE OR REPLACE TRIGGER "+ cNomeTrigg +" "	+ CRLF
			cStatement += "BEFORE UPDATE " 								+ CRLF
			cStatement += "ON " + cTab +" " 							+ CRLF
			cStatement += "REFERENCING NEW AS NEW OLD AS OLD " 			+ CRLF
			cStatement += "FOR EACH ROW"								+ CRLF
			
			//Trata especifidade SA1
			If Substr(cTab,1,3) == "SA1"
			
				cStatement += "BEGIN " 									+ CRLF
				cStatement += "	IF UPDATING('A1_FILIAL') OR UPDATING('A1_COD') OR UPDATING('A1_LOJA') OR " 		+ CRLF
				cStatement += "	 UPDATING('A1_NOME') OR UPDATING('A1_NREDUZ') OR UPDATING('A1_PESSOA') OR " 	+ CRLF
				cStatement += "	 UPDATING('A1_END') OR UPDATING('A1_ENDCOB') OR UPDATING('A1_ENDENT') OR " 		+ CRLF
				cStatement += "	 UPDATING('A1_BAIRRO') OR UPDATING('A1_BAIRROC') OR UPDATING('A1_BAIRROE') OR " + CRLF
				cStatement += "	 UPDATING('A1_COMPLEM') OR UPDATING('A1_TIPO') OR UPDATING('A1_EST') OR " 		+ CRLF
				cStatement += "	 UPDATING('A1_ESTC') OR UPDATING('A1_ESTE') OR UPDATING('A1_CEP') OR " 			+ CRLF
				cStatement += "	 UPDATING('A1_CEPC') OR UPDATING('A1_CEPE') OR UPDATING('A1_COD_MUN') OR " 		+ CRLF
				cStatement += "	 UPDATING('A1_CODMUNE') OR UPDATING('A1_MUN') OR UPDATING('A1_REGIAO') OR " 	+ CRLF
				cStatement += "	 UPDATING('A1_DDD') OR UPDATING('A1_DDI') OR UPDATING('A1_TEL') OR " 			+ CRLF
				cStatement += "	 UPDATING('A1_FAX') OR UPDATING('A1_TELEX') OR UPDATING('A1_CONTATO') OR " 		+ CRLF
				cStatement += "	 UPDATING('A1_CGC') OR UPDATING('A1_RG') OR UPDATING('A1_PFISICA') OR " 		+ CRLF
				cStatement += "	 UPDATING('A1_INSCR') OR UPDATING('A1_INSCRM') OR UPDATING('A1_INSCRUR') OR " 	+ CRLF
				cStatement += "	 UPDATING('A1_PAIS') OR UPDATING('A1_DTNASC') OR UPDATING('A1_EMAIL') OR " 		+ CRLF
				cStatement += "	 UPDATING('A1_HPAGE') OR UPDATING('A1_CNAE') OR UPDATING('A1_MSBLQL') OR " 		+ CRLF
				cStatement += "	 UPDATING('A1_VEND') OR UPDATING('A1_TPFRET') OR UPDATING('A1_TRANSP') OR " 	+ CRLF
				cStatement += "	 UPDATING('A1_COND') OR UPDATING('A1_RISCO') OR UPDATING('A1_LC') OR " 			+ CRLF
				cStatement += "	 UPDATING('A1_LCFIN') OR UPDATING('A1_VENCLC') OR UPDATING('A1_TABELA') OR " 	+ CRLF
				cStatement += "	 UPDATING('A1_OBSERV') OR UPDATING('A1_GRPVEN') OR UPDATING('A1_DTCAD') OR  " 	+ CRLF
				cStatement += "	 UPDATING('A1_HRCAD') OR UPDATING('A1_CALCSUF')  THEN " 						+ CRLF  				
				cStatement +=		":NEW."+ cNomeCampo +" := ' '; "											+ CRLF
				cStatement += " END IF; "																		+ CRLF
				cStatement += "END; "	 																		+ CRLF
			
			Else
			
				//Demais tabelas
				cStatement += "WHEN (OLD."+ cNomeCampo +" = 'S' ) "		+ CRLF
				cStatement += "BEGIN "									+ CRLF
				cStatement += ":NEW."+ cNomeCampo +" := ' '; " 			+ CRLF			
				cStatement += "END; "	 								+ CRLF					
			Endif
			
			
		EndCase
		
		If ! Empty(cStatement)
			ConOut("- Criando TRIGGER - "+ cNomeTrigg)
			If (TCSQLExec(cStatement) < 0)
				ConOut( TCSQLError() )
				MsgStop( TCSQLError() )			
				Exit
			Else
				ConOut("- TRIGGER criada com sucesso - "+ cNomeTrigg)
			EndIf
		Endif
	Next i
//Else
//	conout("- Banco de dados nao eh MSSQL")
//Endif
ConOut("UPD011T - FIM")

Return

