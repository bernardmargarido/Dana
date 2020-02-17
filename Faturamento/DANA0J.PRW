#include "rwmake.ch" 

User Function DANA0J()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ±±
±±³Funcao    ³ Dana0J   ³ Autor ³ FERNANDO A.PACHECO    ³ Data ³ 22/05/01        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  ±±
±±³Descricao ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  ±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Todas as variaveis PRIVATE.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/


_clie := M->C5_CLIENTE
_loj  := M->C5_LOJACLI
_SUFR := GetAdvFval("SA1","A1_SUFRAMA",xFilial("SA1") + _clie+_loj, 1) 
_CODM := GetAdvFval("SA1","A1_CODMUN",xFilial("SA1") + _clie+_loj, 1)
_CALS := GetAdvFval("SA1","A1_CALCSUF",xFilial("SA1") + _clie+_loj, 1) 
_ATIV := GetAdvFval("SA1","A1_ATIVO",xFilial("SA1") + _clie+_loj, 1) 
_retorno := M->C5_NATNOTA

If !empty(_sufr)
   if !empty(_codm) .and. _cals == "S"
      _retorno := "ZF"
      //MSGBOX("Cliente Zona Franca, mensagem esta sendo atualizada com a inscricao do cliente!","Alert")
   endif
Endif             

If _ATIV == "N"
   _retorno := "  "
   MSGBOX("Cliente nao esta ativo !!!!","Favor verificar !","ALERT")
   M->C5_CLIENTE := "  "
   M->C5_LOJACLI := "  "
Endif
 

Return(_retorno)
