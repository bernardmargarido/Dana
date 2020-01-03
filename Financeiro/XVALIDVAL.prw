#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XVALIDVAL ¦   Autor ¦ Clayton Martins ¦ Data ¦ 18/04/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Valida valor do título com valor do código de barras.      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦  Uso     ¦ PERFUMES DANA						                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function XVALIDVAL
Local nValTit	:= 0
Local nValcod   := 0
Local nValcb    := 0
Local cBanco	:= 0
Local lRet		:= .T.
	                       
IF FUNNAME() == "FINA050" .OR. FUNNAME() == "FINA750"
	cBanco:= SUBSTR(M->E2_LINDIG,1,3)
	IF !Empty(M->E2_FORMPAG)
		IF !EMPTY(M->E2_LINDIG)
			IF Len(M->E2_LINDIG) == 48 //.And. SUBSTR(M->E2_LINDIG,1,1) <> "8"
				IF cBanco $"001/033/104/151/237/318/341/356/399/409/477/637/655/745"
					nValCod	:= SUBSTR(M->E2_LINDIG,38,10)
					nValCb 	:= SUBSTR(M->E2_LINDIG,38,8)+ "." +SUBSTR(M->E2_LINDIG,46,2)
					nValTit	:= STRZERO((M->E2_VALOR*100),10,0)
					IF nValCod <> nValTit
						MsgInfo("O Valor do Título:" + TransForm(M->E2_VALOR,'@E 9999,999.99') +" R$    "+ "Não está igual ao valor do Boleto:" +" R$ "+ TransForm(Val(nValCb),'@E 9999,999.99'),"A T E N Ç Ã O")
					Endif	
				EndIF
			EndIf
		EndIF
	Endif
Endif

Return(lRet)
