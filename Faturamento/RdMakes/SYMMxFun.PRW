#Include "Protheus.ch"
#Include "TbiConn.ch"

//-- Funcao que realiza a substituicao de acentos em caracteres
USer Function SYACENTO(cTexto, lUpper)

Local nCount := 0 					//Contador para ser utilizado no FOR.
Local z      := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis.                                              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local aAcentos := {}

If ValType(cTexto) <> "C"
	Return(cTexto)
EndIf

If lUpper == Nil
	lUpper := .T.
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Carrega os acentos e respectivos caracteres substitutos.              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
AADD(aAcentos, {"蓀呻", "a"})
AADD(aAcentos, {"좇쳇", "A"})
AADD(aAcentos, {"郵�",  "e"})
AADD(aAcentos, {"�훗",  "E"})
AADD(aAcentos, {"漿�",  "i"})
AADD(aAcentos, {"蠱�",  "I"})
AADD(aAcentos, {"寀朮", "o"})
AADD(aAcentos, {"塘略", "O"})
AADD(aAcentos, {"鋏�",  "u"})
AADD(aAcentos, {"粕�",  "U"})
AADD(aAcentos, {"�",    "c"})
AADD(aAcentos, {"�",    "C"})
AADD(aAcentos, {"�",    "N"})
AADD(aAcentos, {"�",    "n"})

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Troca os caracteres caso encontre acentos.								�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
For nCount := 1 to Len(aAcentos)
	For z := 1 to Len(aAcentos[nCount][1])
		cTexto := StrTran(cTexto, SubStr(aAcentos[nCount][1], z, 1), aAcentos[nCount][2])
	Next z
Next nCount

Return( If(lUpper, Upper(cTexto), cTexto) )

//-- Retira caracteres especiais de campos pre-formatados (CEP, CNPJ, etc)
User Function SYFORMAT(cTexto, cCpo, lFormata, cTipo)

Local cAux     := ""
Local nI       := 0     
Local cAcentos := "蓀呻좇쳇郵偉훗漿貯勍寀朮塘略鋏蒿昴聆難"
Local cOutros  := "?!:,./\|@#$%& "

Default lFormata := .F.     
Default cTipo    := "N" 
                                                      
Do Case
	Case cTipo == "N"
		For nI := 1 To Len(cTexto)                   
			If (ASC( SubStr(cTexto, nI, 1) ) >= 48) .And. (ASC( SubStr(cTexto, nI, 1) ) <= 57)
				cAux += SubStr(cTexto, nI, 1)
			EndIf
		Next nI                                        
		
	Case cTipo == "C"
		For nI := 1 To Len(cTexto)                   
			If (ASC( SubStr(cTexto, nI, 1) ) >= 48)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 57)  .Or.; 
			   (ASC( SubStr(cTexto, nI, 1) ) >= 65)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 90)  .Or.;
			   (ASC( SubStr(cTexto, nI, 1) ) >= 97)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 122) 
				If (SubStr(cTexto, nI, 1) $ Alltrim(cOutros)) .Or. (SubStr(cTexto, nI, 1) $ Alltrim(cAcentos))
				If SubStr(cTexto, nI, 1) == "&"
					cAux += "e"
					Else
						cAux += SubStr(cTexto, nI, 1)
					EndIf
				Else
					cAux += SubStr(cTexto, nI, 1)
				EndIf
			EndIf
		Next nI                                        
EndCase		

If lFormata
	cAux := PadR(AllTrim(cAux), TamSx3(cCpo)[01])
EndIf

Return cAux

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿝otina    쿞tr2Array � Autor � Julio Cesar           � Data � 14/11/05 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Converte uma string para array.                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
User Function Str2Array(cString, cDelim, cStr)

Local aReturn := {}
Local cAux    := cString 
Local nPos    := 0
Local nI      := 0

Default cDelim := ";"
Default cStr   := ""

While At(cDelim, cAux) > 0
	nPos := At(cDelim, cAux)
	AAdd(aReturn, SubStr(cAux, 1, nPos-1))
	cAux := SubStr(cAux, nPos+1)
End
AAdd(aReturn, cAux)

If !Empty(cStr)
	For nI := 1 To Len(aReturn)
		aReturn[nI] := StrTran(aReturn[nI], cStr, " ")
		aReturn[nI] := AllTrim(aReturn[nI])
	Next nI
EndIf

Return(aReturn)         

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿞yEnterCpo 튍utor  � Julio Cesar       � Data �  05/23/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Simula a operacao de Input em um determinado campo do      볍�
굇�          � aCols.                                                     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Farnell                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
User Function SyEnterCpo(cCampo, ValorDoCampo, nLin)

Local cVarAtu  := ReadVar()
Local lRet     := .T.
Local cPrefixo := "M->"
Local bValid

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� A variavel __ReadVar e padrao do sistema, ela identifica o campo atualmente posicionado. �
//� Mude o conteudo desta variavel para disparar as validacoes e gatilhos do novo campo.     �
//� Nao esquecer de voltar o conteudo original no final desta funcao.                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
__ReadVar := cPrefixo+cCampo

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Valoriza o campo atual "Simulado".                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
&(cPrefixo+cCampo) := ValorDoCampo

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Carrega validacoes do campo.                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
SX3->( dbSetOrder(2) )
SX3->( dbSeek(cCampo) )
bValid := "{|| "+IIF(!Empty(SX3->X3_VALID),Rtrim(SX3->X3_VALID)+IIF(!Empty(SX3->X3_VLDUSER),".And.",""),"")+Rtrim(SX3->X3_VLDUSER)+" }"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Executa validacoes do campo.                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
lRet := Eval( &(bValid) )

IF lRet
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Executa gatilhos do campo.                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	SX3->(DbSetOrder(2))
	SX3->(DbSeek(cCampo))
	IF ExistTrigger(cCampo)
		RunTrigger(2,nLin)
	EndIF
EndIF

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Retorna __ReadVar com o valor original.             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
__ReadVar := cVarAtu

n := nLin

Return lRet

/*BEGINDOC                 
Fun豫o...: SyRepImg(cStr1, cStr2, nNum1, cStr3, cStr4)
Descri豫o: Fun豫o que permite a manipula豫o de imagens no reposit�rio de imagens do Protheus
           
Par�metros Recebidos:
cStr1 => Opera豫o que ser� realizada no reposit�rio de imagens:
1 - Extra豫o de uma imagem do reposit�rio

cStr2 => No caso da extra豫o indica qual � o alias que possui o campo ??_BITMAP, para que o conte�do
         seja passado como par�metro para o m�todo respons�vel pela opera豫o.
         
nNum1 => N�mero do recno do alias informado no par�metro cStr2
cStr3 => Nome que ser� utilizado para grava豫o da figura extra�da do reposit�rio em disco
cStr4 => Path para grava豫o da figura extra�da do reposit�rio            

Retorno:
lRet  => Determina se a opera豫o solicitada foi realizada com sucesso (.T. )ou n�o (.F.)
ENDDOC*/    
User Function SyRepImg(cOperacao, cAlias, nRec, cArq, cPath)

Local oDLG        := Nil                   
Local oRepository := Nil
Local cCpo        := "" 
Local cNewPath    := ""

Local aPath       := {}

Local nI          := 0 

Local lRet        := .T.

Private bDialogInit := {|| }

/*/
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Monta Dialogo "Escondido" para possibilitar a importacao  das�
� imagens													   �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
DEFINE MSDIALOG oDlg FROM 0,0 TO 0,0 PIXEL
	/*/
	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	� Cria um Objeto do Tipo Repositorio						   �
	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
	@ 000,000 REPOSITORY oRepository SIZE 0,0 OF oDlg      
	
	Do Case
		Case cOperacao == "1"   
			// Seleciona area passada como parametro
			dbSelectArea(cAlias)                    
			
			// Posiciona no registro informado como parametro
			dbGoTo(nRec)                                     
			
			// Determina qual eh o campo de BitMap
			cCpo := Iif(Left(cAlias,1)=="S", Right(cAlias, 2)+"_BITMAP", cAlias+"_BITMAP")
			                       
			// Caso exista o campo de BitMap realiza tratamento para grava-lo em algum diretorio			                                                                              
			If FieldPos(cCpo) <> 0 
				If !Empty(cPath)
					aPath := U_Str2Array(cPath, "\")
					For nI := 1 To Len(aPath)
						If !Empty(aPath[nI])
							cNewPath += "\"+aPath[nI]
							MakeDir(cNewPath)
						EndIf
					Next nI
				EndIf
				lRET := oRepository:Extract(FieldGet(FieldPos(cCpo)), cNewPath+"\"+cArq)
			EndIf                                                            
	End Case
	/*/
	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	� Efetiva a importacao da imagem     						   �
	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
	bDialogInit	:= {|| oRepository:lStretch := .T. , oDlg:End() , oRepository := NIL , oDlg:= NIL }

/*/
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Ativa e Fecha o Dialogo									   �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit )

Return lRet   

/*BEGINDOC                 
Fun豫o...: SendMail(cStr1, cStr2, cStr3, cStr4, aArray1)
Descri豫o: Fun豫o que realiza o envio de e-mails
           
Par�metros Recebidos:
cStr1   => Endere�o do e-mail de origem
cStr2   => Endere�o do e-mail de destino
cStr3   => Assunto do e-mail
cStr4   => Texto do corpo do e-mail
aArray1 => Array contendo os paths e nomes dos arquivos que ser�o atachados ao e-mail

Retorno:
lOK  => Determina se o e-mail foi enviado com sucesso ou n�o
        .T. -> Array enviado com sucesso
        .F. -> Erro no envio do e-mail
ENDDOC*/
User Function SendMail(cFrom, cTo, cSubject, cBody, aFiles)
                 
Local cCONTA   := GetMV("MV_RELACNT")
Local cSERVER  := GetMV("MV_RELSERV")
Local cPass    := GetMV("MV_RELAPSW")
Local cAtt     := ""
Local lResult  := .F.
Local lConnect := .F.
Local aTo      := U_Str2Array(cTO, ";")                 
Local nI       := 0

Default aFiles:= {}                                                                                  

// Tratamento para anexos ao e-mail
If !Empty(aFiles)
	If Type("aFiles") == "A"
		For nI := 1 To Len(aFiles)       
			cAtt += aFiles[nI]+","
		Next nI
		cAtt := SubStr(cAtt, 1, Len(cAtt)-1)
	Else
		cAtt := aFiles
	EndIf
EndIf
	
// Abre conexao para envio de Email 
CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPass RESULT lConnect

If !lConnect
	GET MAIL ERROR cError
EndIf

// Verifica se eh necessario realizar a autenticacao no servidor de e-mails
If lConnect .And. GetMV("MV_RELAUTH")
	lConnect := MailAuth(cConta,cPass)
	If !lConnect
		DISCONNECT SMTP SERVER
	Endif
Endif          

If lConnect
	For nI := 1 To Len(aTO)
		If Empty(aTO[nI])
			Loop
		EndIf
		
		// Envia e-mail
		If !Empty(cAtt)
			SEND MAIL FROM cFrom TO aTO[nI] SUBJECT cSubject BODY cBody ATTACHMENT cAtt RESULT lResult
		Else           
			SEND MAIL FROM cFrom TO aTO[nI] SUBJECT cSubject BODY cBody RESULT lResult	
		EndIf
		
		If !lResult          
			GET MAIL ERROR cError
			Exit
		EndIf
	Next nI
EndIf
                
If lConnect
	DISCONNECT SMTP SERVER
EndIf

Return lResult

//-- Funcao que le o arquivo padrao de configura豫o dos webservices
User Function SyCfgWebSr()

Local aRET    := {.T., "", ""}

Local cFile   := "WEBSERVICES.CFG"
Local cBuffer := ""

Local nHdl    := 0
        
// Abre o arquivo de configura豫o do webservice
nHdl := FOpen(cFile)
If nHdl < 0
	nHdl := MSFCreate(cFile)
	If nHdl < 0
		ConOut("Nao foi possivel a criacao do arquivo "+cFile+". Execucao de webservices nao permitida.")
		aRET[1] := .F.
		Return aRET
	Else
		FWrite(nHdl, ".T., 99, 01")
		FClose(nHdl) 
		               
		aRET[1] := .T.
		aRET[2] := "99"
		aRET[3] := "01"
	EndIf
Else 
	FRead(nHdl, @cBuffer, 15)
	aRET := U_Str2Array(cBuffer, ",")
	
	If AllTrim(aRET[1]) == ".T."
		aRET[1] := .T.
	ElseIf AllTrim(aRET[1]) == ".F."
		aRET[1] := .F.
	EndIf
	
	aRET[2] := AllTrim(aRET[2])
	aRET[3] := AllTrim(aRET[3])
EndIf

Return aRET


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴箇袴袴袴袴藁袴袴袴藁袴袴袴袴袴袴袴袴袴袴箇袴袴藁袴袴袴袴袴袴敲굇
굇튡rograma  튥YAHEAD 튍utor  튣icardo Camargo     � Data �  08/06/04   볍�
굇勁袴袴袴袴誥袴袴袴袴袴姦袴袴袴姦袴袴袴袴袴袴袴袴袴菰袴袴袴姦袴袴袴袴袴袴묽�
굇튒esc.     튝onta aHeader com par�metrios                               볍�
굇�          �                                                            볍�
굇勁袴袴袴袴誥袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � GAV-Interno                                                볍�
굇훤袴袴袴袴菰袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
User Function SYMAHEAD(cAlias, aFields, lSoCpos)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Par�metros da fun豫o:                                                   �
//�   cAlias  -> Alias da tabela                                            �
//�   aFields -> Array  com campos que nao devem ser desconsiderados        �
//�   lSoCpos -> L�gico que determina que o retorno vir� tb os campos       �
//�                                                                         �
//� Retorno da funcao                                                       �
//�   Array formado por: array com o aHeader, quant. de campos usados e a   �
//�                      matriz s� com os campos, quando solicitado         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local aHead 	:= {}
Local aCampos   := {}
Local cOldAlias := Alias()
Local aSavSX3 	:= { SX3->( IndexOrd() ), SX3->( RecNo() ) }
Local nUsad	  	:= 0
     
//Ajusta os parametros necess�rios com suas op寤es default
Default aFields := {} 
Default lSoCpos := .F.

// Seta a �rea do SX3, �ndice e executa o seek no cAlias
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)

//Loop para montagem do aHeader
do while SX3->( ! Eof() ) .And. SX3->X3_ARQUIVO == cAlias
	if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. ascan( aFields, alltrim(X3_CAMPO) ) == 0
        //Verifica se o retorno ter� os campos
		if lSoCpos
			aadd( aCampos, alltrim( SX3->X3_CAMPO ) )
		endif     
		
		aadd( aHead, { alltrim( 	X3Titulo() ), 	;
				 		SX3->X3_CAMPO,  			;
						SX3->X3_PICTURE,	 		;
						SX3->X3_TAMANHO,			;
						SX3->X3_DECIMAL,			;
						SX3->X3_VALID,  			;
						SX3->X3_USADO,  			;
						SX3->X3_TIPO,   			;
						SX3->X3_NIVEL,				;
						SX3->X3_CONTEXT, 			;
						SX3->X3_F3})

		nUsad ++
	endif
	
	dbSelectArea("SX3")
	dbSkip()
enddo

//Restaura o ambiente do SX3 e a �rea selecionada anteriormente
dbSetOrder( aSavSX3[ 1 ] )
dbGoto( aSavSX3[ 2 ] )
dbSelectArea( cOldAlias )

Return { aHead, nUsad, aCampos }

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴錮袴袴袴錮袴袴袴袴袴袴袴袴袴袴佶袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿞YACOLS 쿌utor  쿝icardo Camargo     � Data �  08/06/04   볍�
굇픔컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴떡�
굇튒esc.     쿘onta aCols                                                 볍�
굇�          �                                                            볍�
굇픔컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴떡�
굇튧so       � GAV-Interno                                                볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/                       
User Function SYACOLS(cAlias, aHead, nOpc, nOrd, cChave, bCond, bLinha, lQuery)

#define _X3CONTEXTO		10

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Par�metros da fun豫o:                                                   �
//�   cAlias -> Alias da tabela                                             �
//�   aHead  -> Matriz com o cabe�alho de campos (aHeader)                  �
//�   nOpc   -> Segue a mesma l�gica das op寤es da matriz aRotina           �
//�   nOrd   -> Ordem do �ndice de cAlias                                   �
//�   cChave -> Chave para o seek de posicionamento em cAlias               �
//�   bCond  -> Condi豫o do `do while`                                      �
//�   bLinha -> Condi豫o de filtro (sele豫o) de registros                   �
//�   lQuery -> Variavel Logica que indica se o alias � uma query           �
//�                                                                         �
//� Retorno da funcao                                                       �
//�   Array com:                                                            �
//�   Elemento [1] - array do aCols                                         �
//�   Elemento [2] - array dos recnos da tabela                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Local aCols   := {}
Local aRecnos := {}
Local nLoop   := 0
Local nHead   := len( aHead )
Local aAreaAux:= {}
Local aAreaAtu:= GetArea()
Local cVarTmp

//Ajusta os parametros necess�rios com suas op寤es default
Default cAlias 	:= Alias()
Default nOpc	:= 3
Default nOrd   	:= 1
Default cChave 	:= ""
Default bCond  	:= {|| .T. }
Default bLinha	:= {|| .T. }
Default lQuery	:= .F.

// Armazena area original do arquivo a ser utilizado na montagem do aCols
aAreaAux := (cAlias)->(GetArea())

if ! nOpc == 3 // Inclus�o
	Dbselectarea(cAlias)                                          
	if lQuery
		DbGoTop()
	else
		Dbsetorder(nOrd)
		Dbseek(cChave)
	endif
	
	//Monta o aCols
	do while !eof() .and. eval( bCond )
		if eval(bLinha)
			aadd( aCols, {} )
			for nLoop := 1 to nHead
				//Verifica se o campo � apenas virtual
				if aHead[ nLoop, _X3CONTEXTO ] == "V"
					cVarTmp := CriaVar( aHead[ nLoop ][ 2 ] )
				else
					cVarTmp := FieldGet( FieldPos( aHead[ nLoop, 2] ) )
				endif
				
				//Acrescenta dados � matriz
				aadd( aCols[ len(aCols) ], cVarTmp )
			next nLoop
			
			//Acrescenta a aCols a vari�vel l�gica de controle de dele豫o da linha
			aadd( aCols[ len(aCols) ], .F. )
			
			//Acrescenta a aRecnos o n�mero do registro
			if lQuery
				aadd( aRecnos, (cAlias)->R_E_C_N_O_)
			else
				aadd( aRecnos, (cAlias)->( recno() ) )
			endif
		endif
		(cAlias)->( dbskip() )
	enddo
else
	aadd( aCols, {} )
	for nLoop := 1 to nHead
		aadd( aCols[ len(aCols) ], CriaVar(aHead[nLoop, 2] ) )
	next nLoop
	
	aadd( aCols[ len( aCols) ], .F.)
	aadd( aRecnos, {} )
endif

// Restaura area original do arquivo utilizado na montagem do aCols
RestArea(aAreaAux)

// Restaura area orignal da entrada da rotina
RestArea(aAreaAtu)

Return { aCols, aRecnos }

//-- Retorna o path e nome de um arquivo selecionado
User Function SyFile(cTipoArq, cTitulo)

Local cRET := ""

cRET := cGetFile(cTipoArq, cTitulo,,, .F., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE, .T.)
&(ReadVar()) := cRET

Return .T.

//-- Inclui linha em branco no aCols
User Function SyLAcols(aCols, aHeader)

Local nI := 0
                                  
// Insere uma linha no acols
AAdd(aCols, Array(Len(aHeader)+1) )

For nI := 1 To Len(aHeader)
	aCols[Len(aCols)][nI] := CriaVar(aHeader[nI,2], .T.)
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
Next nI

Return

//-- 
User Function SyHora(dData, cHr1, cHr2)

Local aRET := (dData, "")

Local vHora1 := Val(Left(cHr1, 2))
Local vMin1  := Val(SubStr(cHr1, 4, 2))
Local vSeg1  := Val(Right(cHr1, 2))

Local vHora2 := Val(Left(cHr2, 2))
Local vMin2  := Val(SubStr(cHr2, 4, 2))
Local vSeg2  := Val(Right(cHr2, 2))

Local vHora  := 0
Local vMin   := 0
local vSeg   := 0

If (vSeg1 + vSeg2) >= 60
	vSeg := 0
	vMin1+= 1
Else
 	vSeg := vSeg1 + vSeg2
EndIf
	
If (vMin1 + vMin2) >= 60
	vMin  := 0
	vHora1+= 1
Else
 	vMin := vMin1 + vMin2
EndIf
             
If (vHora1 + vHora2) >= 24
	vHora := 0
	dData += 1
Else
 	vHora := vHora1 + vHora2
EndIf

aRET := {dData, StrZero(vHora,2)+":"+StrZero(vMin,2)+":"+StrZero(vSeg,2)}

Return aRET

//-- Cria campos para enchoice auto-contida
User Function SyCriaCpo(aCampos, nOpc)

Local aAcho := {}

Local nI    := 0

Local cValid:= ""

Local bValid:= {|| }


For nI := 1 To Len(aCampos)
	SX3->( dbSetOrder(2) )
	SX3->( dbSeek(aCampos[nI]) )                     
	     
	// Cria expressao de validacao
	cValid := ""
	If !Empty(SX3->X3_VALID)
		cValid += AllTrim(SX3->X3_VALID)
	EndIf
	
	If !Empty(SX3->X3_VLDUSER)	        
		If !Empty(cValid)
			cValid += " .And. "
		EndIf
		cValid += AllTrim(SX3->X3_VLDUSER)
	EndIf
                 
	If !Empty(cValid)                 
    	bValid:= &("{|| "+AllTrim(cValid)+"}")         
 	Else                                               
 		bValid:= &("{|| AlwaysTrue() }")         
 	EndIf                           
 	
 	If !Empty(SX3->X3_WHEN)
		bWhen := &("{|| "+AllTrim(SX3->X3_WHEN)+"}")
	Else
		bWhen := &("{|| AlwaysTrue() }")		
	EndIf

	// Cria array que sera utilizado pela Enchoice                                                                 
	Aadd(aAcho,{SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
	    PesqPict(Left(aCampos[nI],3), aCampos[nI]), bValid,;
		X3Obrigat(SX3->X3_CAMPO), SX3->X3_NIVEL, SX3->X3_RELACAO, SX3->X3_F3,;
		bWhen, SX3->X3_VISUAL=="V", .F., AllTrim(SX3->X3_CBOX),;
        SX3->X3_FOLDER, nOpc<>3, SX3->X3_PICTVAR})
    
    // Cria variaveis de memoria
	If nOpc == 3
		_SetOwnerPrvt(Trim(aCampos[nI]), CriaVar(Trim(aCampos[nI]),.T.))
	Else        
		_SetOwnerPrvt(Trim(aCampos[nI]), FieldGet(FieldPos(aCampos[nI])))                                                                
	EndIf
Next nI

Return aAcho