#include "Totvs.ch"     
#Include "AP5Mail.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � BOLFUNC  �Autor  �Wheber Bogdanavicius� Data �  07/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Biblioteca de fun��es para utiliza��o nos boletos          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Boletoes Maurano                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/              

User Function MMBolDDA(cClix,cLjx)
Local y		:= 0
Local lRet 	:= .F.

//Wheber 23/09/2015 -- Tratamento para permitir usuarios do grupo 000001 (Imprime boleto DDA) para permitir impress�o mesmo que o cliente seja DDA.
//Wheber 23/10/2015 -- Solicitado pelo marcelo para apenas avisar que o cliente � configurado em DDA, pois com a parada do processo existiam
//-------------------- inconsistencias no processo.

cGrpDDA := GetNewPar('MV_GRPDDA','000001')
_aGrupos  := {}
PswOrder(1)                              
If PswSeek(__cUserId,.T.)
	_daduser := pswret(1)
    For y := 1 to Len(_dadUser[01,10])
    	AADD(_aGrupos,{_dadUser[01,10,y]}) 
    Next	
Endif       

If aScan(_aGrupos,{|aX| ax[1] == cGrpDDA } ) > 0
	Return(.F.)
EndIf

dbSelectArea('SA1')
dbSetOrder(1)
dbSeek(xFilial('SA1')+cClix+cLjx)

/*
If SA1->A1_USADDA == '1'
	MsgInfo('Cliente '+AllTrim(SA1->A1_NOME)+' Utiliza DDA, portanto n�o � necess�ria a impress�o de boleto para o mesmo.','Controle de Boletos')//
EndIf
*/
Return(lRet)                                    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MMSelNotas  �Autor  �Marcelo Celi Marques� Data � 08/04/15  ���
�������������������������������������������������������������������������͹��
���Desc.     �	Seleciona titulos para boletos.							    ���
�������������������������������������������������������������������������͹��
���Uso       � Grupo Maurano Maurano                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MMSelNfBol(cSerie,cNfi,cNff,cBanco)
Local oDlg
Local oLbx     
Local oBmp
Local oBmp1
Local nX			:= 0
Local nOpc			:= 1
Local nOpca			:= 0
Local aNotas 		:= {}
Local aTitBack		:= {}
Local aRet 			:= {}
Local aArea			:= GetArea()
Local aAreaSE1		:= SE1->(GetArea())		                    
Local lReimprime	:= .F.
Local lNovas		:= .F.
Local oOk 			:= LoadBitmap( GetResources(), "LBOK" )
Local oNo 			:= LoadBitmap( GetResources(), "LBNO" )
Local oVerde 		:= LoadBitmap( GetResources(), "BR_VERDE" )
Local oVermelho		:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Local lRunDblClick 	:= .T.
Local lNewBol		:= (cBanco $ '341|001|033|399|') // Douglas Telles - 11.05.2016 - Adaptacao temporaria para boletos novos ja em producao
Local cNumBol		:= ""

dbSelectArea("SE1")
SE1->( dbSetOrder(1) )
SE1->( dbSeek(xFilial("SE1") + cSERIE + cNfi,.T.) )
cParcela:=SE1->E1_PARCELA

// Wheber Bogdanavicius - 07/08/2015
If U_MMBolDDA(SE1->E1_CLIENTE,SE1->E1_LOJA)
	aNotas := {}	
Else
			
	While !SE1->( Eof() ) .AND. Val(SE1->E1_NUM) >= Val(cNfi) .AND. Val(SE1->E1_NUM) <= Val(cNff) //.AND. SE1->E1_TIPO == "NF "
		/*
		If SE1->E1_PORTADO != cBanco .Or. SE1->E1_PREFIXO <> cSerie
			SE1->(DbSkip())
			Loop
		Endif
		*/
		If SE1->E1_PREFIXO <> cSerie
			SE1->(DbSkip())
			Loop
		Endif
   		 If RTrim(SE1->E1_TIPO) == "NF"
   		 	If lNewBol
   		 		cNumBol := SE1->E1_NUMBCO
   		 		If cBanco $ '341|033|399|745|604|041|422|246|104|237'
   		 			cNumBol := SubStr(cNumBol,1,Len(AllTrim(cNumBol))-1)
   		 		EndIf
   		 		aAdd(aNotas,{.F.,If(!Empty(cNumBol),"S","N"),SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,cNumBol,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NOMCLI})
   		 	Else
   		 		cNumBol := SE1->E1_NUMBCO
   		 		aAdd(aNotas,{.F.,If(!Empty(cNumBol),"S","N"),SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,cNumBol,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NOMCLI})
   		 	EndIf
		EndIf
		SE1->(DbSkip())
	EndDo
Endif

aTitBack := aClone(aNotas)

If Len(aNotas) > 0
	DEFINE MSDIALOG oDlg TITLE "Sele��o de Titulos para Boleto" FROM 0,0 to 240,580 PIXEL
	
	oPanel1 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,,070,070,.F.,.F. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
			
	oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,,(oDlg:NCLIENTHEIGHT)/2,25,.F.,.F. )
	oPanel2:Align := CONTROL_ALIGN_TOP
	
	@ 00,2 LISTBOX oLbx VAR cVar Fields 	HEADER 	"","",;                            
													SE1->(RetTitle("E1_PREFIXO")),	;
													SE1->(RetTitle("E1_NUM")),		;
													SE1->(RetTitle("E1_PARCELA")),	;
													SE1->(RetTitle("E1_TIPO")),		;
													SE1->(RetTitle("E1_NUMBCO")),	;
													SE1->(RetTitle("E1_CLIENTE")),	;
													SE1->(RetTitle("E1_LOJA")),		;
													SE1->(RetTitle("A1_NOME"))		;
											COLSIZES 	5,5,						;
														Tamsx3("E1_PREFIXO")[1]+3,	;
											 			Tamsx3("E1_NUM")[1]+5,		;
											 			Tamsx3("E1_PARCELA")[1]+3,	;
											 			Tamsx3("E1_TIPO")[1]+3,		; 
											 			Tamsx3("E1_NUMBCO")[1]+10,	;										 			
											 			Tamsx3("E1_CLIENTE")[1]+3,	;
											 			Tamsx3("E1_LOJA")[1]+3,		; 
											 			Tamsx3("A1_NOME")[1]+3		;
											SIZE (oPanel1:NCLIENTWIDTH)/2-4, (opanel1:NCLIENTHEIGHT)/2-25 ON DBLCLICK (aTitBack:=TrocaTit(oLbx:nAt,aTitBack),oLbx:Refresh()) NOSCROLL  OF oPanel1 PIXEL			
	oLbx:SetArray(aTitBack)
	oLbx:bLine := { || {if(aTitBack[oLbx:nAt,1],oOk,oNo),if(aTitBack[oLbx:nAt,2]<>"S",oVerde,oVermelho),aTitBack[oLbx:nAt,3],aTitBack[oLbx:nAt,4],aTitBack[oLbx:nAt,5],aTitBack[oLbx:nAt,6],aTitBack[oLbx:nAt,7],aTitBack[oLbx:nAt,8],aTitBack[oLbx:nAt,9],aTitBack[oLbx:nAt,10]}}
	oLbx:bHeaderClick := {|oObj,nCol| If(lRunDblClick .And. nCol==1, aEval(aTitBack, {|e| e[1] := !e[1]}),Nil), lRunDblClick := !lRunDblClick, oLbx:Refresh()}
	                                                                                   
	@ 02,05 BITMAP oBmp  		RESNAME "BR_VERDE" SIZE 16,16 NOBORDER 	OF oPanel2 PIXEL
	@ 02,15	Say "N�o Gerados"	OF oPanel2 PIXEL 
		
	@ 10,05 BITMAP oBmp1 		RESNAME "BR_VERMELHO"  SIZE 16,16 NOBORDER 	OF oPanel2 PIXEL
	@ 10,15	Say "J� Gerados"	OF oPanel2 PIXEL 
	
	@ 02,70 RADIO nOpc ITEMS "Gerar novo boleto","Reimpress�o de boleto" PIXEL SIZE 400,10 OF oPanel2 Pixel 
	
	Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End() },{ || If(MsgYesNo("Confirma o abandono da rotina de impress�o de boletos?"),(nOpca := 0,oDlg:End()),.T.)}) Center 
	                      
	If nOpc==1
		lReimprime := .F.
	Else
		lReimprime := .T.
	EndIf	                      
	                             
	aNotas 	:= Aclone(aTitBack)
	If nOpcA==1
		For nX:=1 to Len(aNotas)
			If aNotas[nX,01]
				aAdd(aRet,{If(aNotas[nX,02]=="S" .And. lReimprime,"R","G"),aNotas[nX,03],aNotas[nX,04],aNotas[nX,05]})
				If aNotas[nX,02]<>"S"
					lNovas := .T.
				EndIf	
			EndIf	
	    Next nX
	EndIf
	
	If Len(aRet)>0
		If lReimprime
			cMsg := "As notas marcadas para reimpress�o n�o ser�o gerados novos boletos, somente impressas como segundas vias."
			If lNovas
				cMsg += " Por�m as notas marcadas sem boleto ser�o considerados novos boletos."
			EndIf                                                                            
		Else         
			cMsg := "Todas as notas marcadas ser�o gerados novos boletos."
		EndIf		
		nOpcB := Aviso("Confirma a impress�o dos boletos??",;
		cMsg,{'Sim', 'Cancelar'},3)		
		If nOpcB<>1
			aRet := {}
		EndIf	
	EndIf
EndIf

SE1->(RestArea(aAreaSE1))
RestArea(aArea)

Return aRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    � TrocaTit   � Autor � Marcelo Celi Marques � Data �08/04/2015���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Fun��o para marcar ou desmarcar todos os titulos.		    ��� 
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � TrocaTit(ExpN1,ExpA1)	                                    ���
���������������������������������������������������������������������������Ĵ��
��� Parametros� ExpN1 -> Posic�o do cursor na listbox.					    ��� 
��� 		  � ExpA1 -> Array contendo os titulos a serem marcad/desmarc.  ���
���������������������������������������������������������������������������Ĵ��
��� Retornos  � ExpA1 -> Array contendo os titulos marcados/desmarcados.	���
���������������������������������������������������������������������������Ĵ��
��� Uso       � Grupo Maurano Maurano                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function TrocaTit(nIt,aArray)
aArray[nIt,1] := !aArray[nIt,1]
Return aArray                          

User Function MMBolMail(cEmail,cAnexo,aInfo)

Private cSrv  := GetMv("MV_RELSERV") // Servidor Smtp
Private cMail := GetMv("MV_RELACNT") // email@dominio.com.br
Private cPass := GetMv("MV_RELPSW")  // Senha
Private lAuth := GetMv("MV_RELAUTH") // Requer autenticacao?

cSrv  := 'mail.ita.locamail.com.br:587'
cMAil := 'nfegrupomaurano@maurano.com.br'
cPass := 'maurano2009'

CONNECT SMTP SERVER cSrv ACCOUNT cMail PASSWORD cPass RESULT lResult

lOk := MailAuth(cMail,cPass)

If !lOk
	lOk := QAGetMail()
EndIf

//Efetua a leitura do anexo...
nHdl := fOpen(cAnexo)
cBuffer := '' 
nBuffer := fRead(nHdl,cBuffer,99999)

GET MAIL ERROR cError

cBody := ' Boleto Enviado via Sistema referente ao t�tulo ' + AllTrim(aInfo[1]) /*+ '/' + AllTrim(aInfo[2])*/
/*If !Empty(aInfo[3])
	cBody += ' Parcela ' + aInfo[3]
EndIf*/
cBody += ' Na Empresa ' + aInfo[4] + chr(13) + Chr(10)
cBody += 'Favor n�o responder esse e-mail.' + Chr(13) + Chr(10)

//APENAS PARA TESTE!!!!!--------------
//cBody += ' TESTE ---> Enviado para: ' + cEmail
//------------------------------------

SEND MAIL FROM 'boletos@maurano.com.br' TO cEmail SUBJECT 'Envio de Boletos' BODY cBody ATTACHMENT cAnexo  RESULT lResult 
//APENAS PARA TESTE!!!!!--------------
//SEND MAIL FROM 'boletos@maurano.com.br' TO 'douglas.telles@symm.com.br' SUBJECT 'Envio de Boletos' BODY cBody ATTACHMENT cAnexo RESULT lResult 
//------------------------------------

DISCONNECT SMTP SERVER

FClose(nHdl)

Return()    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MMVLDMAIL �Autor �Wheber Bogdanavicius� Data �  10/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para validar o campo de E-Mail                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Boletoes Maurano                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/              
User Function MMVldMail(cMailX)

Local lRet := .T.

If Empty(cMailX)
	lRet := .F.
	MsgInfo('Campo de E-Mail precisa estar preenchido','Valida��o de E-Mail')
EndIf 

If At("@", cMailX ) == 0 .Or. At(".", cMailX ) == 0
	lRet := .F.
	MsgInfo('Campo de E-Mail precisa conter um formato v�lido.','Valida��o de E-Mail')
EndIf 

Return(lRet)              

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MMSNDBOL �Autor  �Wheber Bogdanavicius� Data �  10/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para enviar boleto por  E-Mail                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Boletoes Maurano                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/       
User Function MMSNDBOL(cMAil,cBol,aInfo)

Local lExp := .F.

cMail := allTrim(cMail)       

If MsgYesNo('Gera arquivo para envio ?') 
	If U_MMVldMail(cMail)
		cFileExp := "\treport\Boleto_" + cBol + Replace(Time(),':','')+".html"
		lExp := oPrn:SaveAsHtml(cFileExp)
		If lExp
			MsgRun('Enviando Boleto por e-mail','Envio de Boleto',{|| U_MMBolMail(cMail, cFileExp, aInfo)})
		Else	
			MsgInfo('Falha ao gerar o arquivo do boleto')
		EndIf 
	EndIf
EndIf  

Return()

User Function Mod11(cStr,nMultIni,nMultFim)
Local i, nModulo := 0, cChar, nMult

nMultIni := Iif( nMultIni==Nil,2,nMultIni )
nMultFim := Iif( nMultFim==Nil,9,nMultFim )
nMult := nMultIni
cStr := AllTrim(cStr)

For i := Len(cStr) to 1 Step -1
	cChar := Substr(cStr,i,1)
	If isAlpha( cChar )
		Help(" ", 1, "ONLYNUM")
		Return .f.
	End
	nModulo += Val(cChar)*nMult
	nMult:= IIf(nMult==nMultfim,2,nMult+1)
Next
nRest := nModulo % 11
nRest := IIf(nRest==0 .or. nRest==1,0,11-nRest)
Return(Str(nRest,1))

/*/{Protheus.doc} BolSx1
Ajusta a pergunta apresentada na reimpress�o do boleto.
@author Douglas Telles
@since 11/05/2016
@version 1.0
@return cPerg, Grupo de perguntas ajustado
/*/
User Function BolSx1()
	Local cPerg		:= "ZZBOLE"
	Local aHlp01		:= {"Nota inicial a ser considerada na","filtragem dos dados."}
	Local aHlp02		:= {"Nota final a ser considerada na","filtragem dos dados."}
	Local aHlp03		:= {"C�digo do banco a ser considerado","na filtragem dos dados"}
	Local aHlp04		:= {"Prefixo da nota a ser considerada","na filtragem dos dados"}
	Local aHlp05		:= {"Sim = Envia Boleto por e-mail ao","cliente.","N�o = N�o envia boleto."}

	PutSx1(cPerg,"01","Nota Inicial"		,'','',"MV_CH1","C",06,0,0,"G","","","","","MV_PAR01",""	,"","","",""		,"","","","","","","","","","","",aHlp01,{},{},"")
	PutSx1(cPerg,"02","Nota Final"			,'','',"MV_CH2","C",06,0,0,"G","","","","","MV_PAR02",""	,"","","",""		,"","","","","","","","","","","",aHlp02,{},{},"")
	PutSx1(cPerg,"03","Banco"				,'','',"MV_CH3","C",03,0,0,"G","","","","","MV_PAR03",""	,"","","",""		,"","","","","","","","","","","",aHlp03,{},{},"")
	PutSx1(cPerg,"04","Prefixo"				,'','',"MV_CH4","C",03,0,0,"G","","","","","MV_PAR04",""	,"","","",""		,"","","","","","","","","","","",aHlp04,{},{},"")
	PutSx1(cPerg,"05","Envia Por E-Mail"	,'','',"MV_CH5","N",01,0,1,"C","","","","","MV_PAR05","Sim"	,"","","","N�o"	,"","","","","","","","","","","",aHlp05,{},{},"")


Return (cPerg)