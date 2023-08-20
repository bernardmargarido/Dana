#include "rwmake.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ±±
±±³Funcao    ³ Dana0F   ³ Autor ³ FERNANDO A.PACHECO    ³ Data ³ 22/05/01        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  ±±
±±³Descricao ³ Este gatilho atualiza o arquivo Auditor SZB, para toda inclusao   ³±±
±±³          ³ e ou alteracao realizada no arquivo de cliente, campos A1_CLASSIF ³±±
±±³          ³ A1_FATORPR                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  ±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Todas as variaveis PRIVATE.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function DANA0F()
_xret  := 0
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
Return(_XRET)
