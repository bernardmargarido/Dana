#include "rwmake.ch"       
/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MT120GOK  �Autor � Clayton Martins    � Data � 28/06/2018  ���
��+----------+------------------------------------------------------------���
���Descri��o � Chama a rotina de execucao do workflow.                    ���
��+----------+------------------------------------------------------------���
���Uso       � Perfumes Dana						                      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MT120GOK()

Local cPedido    :=  PARAMIXB[1] // Numero do Pedido
Local lInclui    :=  PARAMIXB[2] // Inclus�o
Local lAltera    :=  PARAMIXB[3] // Altera��o
Local lExclusao  :=  PARAMIXB[4] // Exclus�o

If lInclui
	LjMsgRun("Enviando Pedido de Compra para Aprova��o","Workflow",{||U_DNWFPC()})
Endif

Return