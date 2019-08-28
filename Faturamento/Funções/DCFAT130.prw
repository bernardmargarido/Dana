#Include "Protheus.Ch"
/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � DCFAT130   � Autor � Clayton Martins   � Data � 08/01/2019 ���
��+----------+------------------------------------------------------------���
���Descri��o � Gatilho campo C5_TIPOCLI                                   ���
��+----------+------------------------------------------------------------���
���Uso       � DANA COSM�TICOS    					                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function DCFAT130()

	Local cRet	:= ""

	If M->C5_TIPO$"D/B" 
		cRet := "F"
	Else
		cRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+C5_LOJACLI,"A1_TIPO")
	Endif

Return(cRet)