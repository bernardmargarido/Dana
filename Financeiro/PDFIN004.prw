#Include "Protheus.ch"
#Include "rwmake.ch"
/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � PDFIN004  � Autor � Clayton Martins   � Data � 31/08/2018  ���
��+----------+------------------------------------------------------------���
���Descri��o � Apresenta valor bruto no campo E2_XVALBRU - Contas pagar.  ���
��+----------+------------------------------------------------------------���
���Uso       � PERFUMES DANA    					                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function PDFIN004()

Local nRet	:= 0   

nRet	:= POSICIONE("SF1",1,SE2->(E2_FILORIG+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),"F1_VALBRUT")

Return(nRet)