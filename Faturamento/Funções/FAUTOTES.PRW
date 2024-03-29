#INCLUDE "PROTHEUS.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� FUNCAO   � FAUTOTES � AUTOR � Evandro dos Santos    � DATA � 24.08.12   ���
���������������������������������������������������������������������������Ĵ��
��� DESCRICAO� Verifica se a Natureza tem aliquota especial                 ���
���������������������������������������������������������������������������Ĵ��
��� USO      � Faturamento - Perfumes Dana                                  ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
���              �        �      �                                          ���
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

User Function FAutoTes(cFil,cNatNota,cProd,cCliente,cLoja)

Local clTes  := ''
Local clNatz := ''
Local clAlqEsp := ''

clNatz   :=  SUBSTR(U_SCHNATNOTA(cFil,cNatNota,cProd,cCliente,cLoja),1,2)
clAlqEsp :=  SUBSTR(U_SCHNATNOTA(cFil,cNatNota,cProd,cCliente,cLoja),3,2)

If clAlqEsp == '25'
	clTes := Posicione('SZH',1,xFilial('SZH')+clNatz,'ZH_TES25')
ElseIf clAlqEsp == '18'
	clTes := Posicione('SZH',1,xFilial('SZH')+clNatz,'ZH_TES18')
Else
	clTes := Posicione('SZH',1,xFilial('SZH')+clNatz,'ZH_TES')
EndIf

If Empty(clTes)
	clTes	:= "750"
Endif

If Alltrim(xFilial('SZH')) $"06/07"
	clTes	:= "501"
Endif


Return (clTes)
