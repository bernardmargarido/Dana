#include "rwmake.ch" 

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ  ��
���Funcao    � Dana0F   � Autor � FERNANDO A.PACHECO    � Data � 22/05/01        ���
������������������������������������������������������������������������������Ĵ  ��
���Descricao � Este gatilho atualiza o arquivo Auditor SZB, para toda inclusao   ���
���          � e ou alteracao realizada no arquivo de cliente, campos A1_CLASSIF ���
���          � A1_FATORPR                                                        ���
������������������������������������������������������������������������������Ĵ  ��
��� Uso      � Gen�rico                                                          ���
��������������������������������������������������������������������������������  ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
//��������������������������������������������������������������Ŀ
//� Define Todas as variaveis PRIVATE.                           �
//����������������������������������������������������������������
User Function DANA0F()
_xret  := 0

if M->A1_FATORPR > 1
   Return(_xret)
endif  

/*
If inclui          
   if M->A1_FATORPR > 1
      Return(_xret)
   endif   
   dbSelectArea("SZB")
   RecLock("SZB",.T.)
      SZB->ZB_CODCLI  := M->A1_COD
      SZB->ZB_LOJA    := M->A1_LOJA
      SZB->ZB_FATOR   := M->A1_FATORPR
      SZB->ZB_CLASSIF := M->A1_CLASSIF
      SZB->ZB_DATALT  := DATE()
      SZB->ZB_HORALT  := TIME()+"IN"
      SZB->ZB_USUARIO := substr(cUsuario,7,15)
   MsUnLock()
   _xret := M->A1_FATORPR
Endif

If altera
   if M->A1_FATORPR > 1
      Return(_xret)
   endif   
   dbSelectArea("SZB")
   RecLock("SZB",.t.)
      SZB->ZB_CODCLI  := SA1->A1_COD
      SZB->ZB_LOJA    := SA1->A1_LOJA
      SZB->ZB_FATOR   := M->A1_FATORPR
      SZB->ZB_CLASSIF := SA1->A1_CLASSIF
      SZB->ZB_DATALT  := DATE()
      SZB->ZB_HORALT  := TIME()+"AL"
      SZB->ZB_USUARIO := substr(cUsuario,7,15)
   MsUnLock()
   _xret := M->A1_FATORPR
Endif
dbSelectArea("SA1")
*/
Return(_XRET)
