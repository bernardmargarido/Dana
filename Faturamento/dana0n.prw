/*
#include "rwmake.ch"  

User Function DANA0N()

AXCADASTRO("SZH","TES AUTOMATICA",".T.","ExistChav('SZH',M->ZH_CODNAT,1)")
RETURN
*/       

#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DANA0N   � Autor � Clayton Martins    � Data �  23/12/2010 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Armaz�ns					                      ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Orthoneuro.                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function DANA0N()

//Local cVldAlt := ".T." 		// --> Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
//Local cVldExc := ".T." 		// --> Validacao para permitir a exclusao.  Pode-se utilizar ExecBlock.

Local aAreaAtu := GetArea()

//Private cString := "SZH"

dbSelectArea("SZH")
dbSetOrder(1)			

AxCadastro("SZH","TES AUTOMATICA")

RestArea(aAreaAtu)

Return(.T.)