#include "rwmake.ch"       
/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MT120APV  �Autor � Clayton Martins    � Data � 10/09/2018  ���
��+----------+------------------------------------------------------------���
���Descri��o � Gera SCR/Worflow apenas para alguns tipos de produtos.     ���
��+----------+------------------------------------------------------------���
���Uso       � Perfumes Dana						                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MT120APV()

Local cGrupo	:= SY1->Y1_GRAPROV
Local cTipoSB1	:= ""
Local cTpB1MV	:= AllTrim(GetMv("MV_XTIPOB1"))

If !Empty(SC7->C7_PRODUTO)
	cTipoSB1	:= Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TIPO")
	If !(cTipoSB1 $cTpB1MV)
		cGrupo	:=""//N�o gera al�ada
	Endif
EndIf	

Return(cGrupo)