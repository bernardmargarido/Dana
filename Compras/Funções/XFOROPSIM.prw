#Include 'Protheus.ch'
/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � XFOROPSIM �Autor � Clayton Martins    � Data � 30/07/2017  ���
��+----------+------------------------------------------------------------���
���Descri��o �Mensagem para alertar que fornecedor � Optante pelo Simples.���
��+----------+------------------------------------------------------------���
���Uso       � Perfumes Dana						                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function XFOROPSIM()

Local lRet	:= .T.

If ALLTRIM(FUNNAME()) == "MATA103"
	//If M->F1_TIPO <> "D"//Devolu��o
		DbSelectArea("SA2")
		DbSetOrder(1)
		If DbSeek(xFilial("SA2") + CA100FOR + CLOJA)
			If SA2->A2_SIMPNAC == "1"//Optante pelo Simples
				MsgAlert("A T E N � � O - Fornecedor Optante pelo Simples!!!","XFOROPSIM")
			Endif
		Endif
	//Endif
Endif


Return(lRet)