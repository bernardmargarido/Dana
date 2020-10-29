/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ DANETQ   º Autor ³ Caroline Cazela    º Data ³ 14/08/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Impressão de etiqueta GFE                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Dana Perfumes                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
Modelo Arquivo .BAT executado para impressão:
C:

CD\

CD ETIQUETAS

PRINT TS.TXT
*/

User Function DANETQ()

Processa({||U_FATR001A() }, "Aguarde! Imprimindo Etiquetas do Produto...")

Return( Nil )

User function FATR001A()

Local _cCR		:= Chr(13)+Chr(10) 	/* Caracter CARRIAGE RETURN ou ENTER */
Local _oPrn
Local _nQuant	:= 1
Local _cCR  	:= Chr(13)+Chr(10) 	/* Caracter CARRIAGE RETURN ou ENTER */
Local _cPorta 	:= "LPT1"
Local cPerg 	:= 'DANETQ'
Local _cQuery 	:= ""
Local _cAlias	:= GetNextAlias()
Local nX	   	:= 0

AjustaSx1(cPerg)
If !Pergunte(cPerg, .T.)
	Return
Endif

_oPrn := FCREATE( "c:\etiquetas\ts.txt" )

If _oPrn == -1
	MsgStop('Erro de abertura : FERROR '+str(ferror(),4))
	fclose(_oPrn) // Fecha arquivo
	return
Endif

_cQuery	:= " SELECT "
_cQuery	+= "    F2_DOC AS NUMNF,"
_cQuery	+= "    F2_SERIE AS SERIE,"
_cQuery	+= "    F2_CLIENTE AS CODCLI,"
_cQuery	+= "    F2_LOJA AS LJF2,"
_cQuery	+= "    F2_TRANSP AS CODTR,"
_cQuery	+= "    A1_COD AS CODCLE,"
_cQuery	+= "    A1_NOME AS CLNOM,"
_cQuery	+= "    A1_EST AS EST,"
_cQuery	+= "    A1_MUN AS MUN,"
_cQuery	+= "    A1_LOJA AS LJA1,"
_cQuery	+= "    A4_COD AS TRCOD, "
_cQuery	+= "    A4_NOME AS TRNOM "
_cQuery	+= " FROM "
_cQuery +=      RetSqlName( "SF2" ) + " SF2 "
_cQuery	+= " INNER JOIN "
_cQuery +=      RetSqlName( "SA1" ) + " SA1 "
_cQuery += " ON SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA"
_cQuery	+= " LEFT JOIN "
_cQuery +=      RetSqlName( "SA4" ) + " SA4 "
_cQuery += "  ON SA4.A4_COD = SF2.F2_TRANSP"
_cQuery	+= " WHERE "
_cQuery	+= "    SF2.D_E_L_E_T_     = '' AND "
_cQuery	+= "    SA1.D_E_L_E_T_     = '' AND "
_cQuery	+= "    SA4.D_E_L_E_T_     = '' AND "
_cQuery	+= "    SF2.F2_FILIAL      = '" + xFilial( "SF2" ) + "' AND "
_cQuery	+= "    SA1.A1_FILIAL      = '" + xFilial( "SA1" ) + "' AND "
_cQuery	+= "    SA4.A4_FILIAL      = '" + xFilial( "SA4" ) + "' AND "
_cQuery	+= "    SF2.F2_DOC         = '" + ALLTRIM(MV_PAR01) + "' AND "
_cQuery	+= "    SF2.F2_SERIE       = '" + ALLTRIM(MV_PAR02) + "'"
_cQuery	+= " ORDER BY "
_cQuery += "   SF2.F2_DOC, F2_SERIE "
_cQuery	:= changeQuery(_cQuery)
DbUseArea( .T., "TOPCONN", TCGenQry(,,_cQuery), _cAlias, .F., .F. )

If MV_PAR04 == 0
	While !(_cAlias)->(Eof())
		For nX := 1 to MV_PAR03
			If Empty((_cAlias)->TRNOM)
				AjustaSx1(cPerg)
			EndIF
			FWRITE( _oPrn, "^XA" + _cCR )
			FWRITE( _oPrn, "^MMT" + _cCR )
			FWRITE( _oPrn, "^PW800" + _cCR ) //largura da etiqueta
			FWRITE( _oPrn, "^LL0400" + _cCR ) // comprimento etiqueta
			FWRITE( _oPrn, "^LS0" + _cCR )
			
			//Imprime dados
			FWRITE( _oPrn, "^FT5,46^A0N,38,60^FH\^FD" + " " + SUBSTR((_cAlias)->CLNOM,1,25) + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,200^A0N,41,50^FH\^FD" + " " +  SUBSTR((_cAlias)->MUN,1,24) + "/" + Alltrim((_cAlias)->EST) + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,250^A0N,41,60^FH\^FD" + " " +  "NF:" + (_cAlias)->NUMNF + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,300^A0N,41,50^FH\^FD" + " " +  "VOLUME:" + Strzero(nX,4) + "  " + Strzero(MV_PAR03,4) + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,300^A0N,41,30^FH\^FD" +"                                                                    "+Dtoc(dDataBase) + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,384^A0N,41,60^FH\^FD" + " " +  "TR-" + SUBSTR((_cAlias)->TRNOM,1,15) + "^FS" + _cCR )

			
			//Imprime o Codigo de Barra
			FWRITE( _oPrn, "^FO200,080^BY2,1^BC,60,N,N^FD" + Alltrim((_cAlias)->NUMNF) + Alltrim(Strzero(nX,4)) + "^FS" + _cCR )
			FWRITE( _oPrn, "^PQ1,0,1,Y"+ _cCR )
			FWRITE( _oPrn, "^XZ"+ _cCR )
		Next nX
		(_cAlias)->(DbSkip())
	End
Else
	While !(_cAlias)->(Eof())
		For nX := 1 to MV_PAR04
			If Empty((_cAlias)->TRNOM)
				AjustaSx1(cPerg)
			EndIF
			FWRITE( _oPrn, "^XA" + _cCR )
			FWRITE( _oPrn, "^MMT" + _cCR )
			FWRITE( _oPrn, "^PW800" + _cCR ) //largura da etiqueta
			FWRITE( _oPrn, "^LL0400" + _cCR ) // comprimento etiqueta
			FWRITE( _oPrn, "^LS0" + _cCR )

			//Imprime dados
			FWRITE( _oPrn, "^FT5,46^A0N,38,60^FH\^FD" + SUBSTR((_cAlias)->CLNOM,1,25) + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,200^A0N,41,50^FH\^FD" + SUBSTR((_cAlias)->MUN,1,24) + "/" + Alltrim((_cAlias)->EST) + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,250^A0N,41,60^FH\^FD" + "NF:" + (_cAlias)->NUMNF + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,300^A0N,41,50^FH\^FD" + "PALET:" + Strzero(nX,4) + "  " + Strzero(MV_PAR04,4) +"  VOL:" + "  " + Strzero(MV_PAR03,4) + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,384^A0N,41,60^FH\^FD" + "TR-" + SUBSTR((_cAlias)->TRNOM,1,15) + "^FS" + _cCR )
			FWRITE( _oPrn, "^FT5,384^A0N,41,30^FH\^FD" +"                                                                    "+Dtoc(dDataBase) + "^FS" + _cCR )
			
			//Imprime o Codigo de Barra
			FWRITE( _oPrn, "^FO200,080^BY2,1^BC,60,N,N^FD" + Alltrim((_cAlias)->NUMNF) + Alltrim(Strzero(nX,4)) + "^FS" + _cCR )
			FWRITE( _oPrn, "^PQ1,0,1,Y"+ _cCR )
			FWRITE( _oPrn, "^XZ"+ _cCR )

		Next nX
		(_cAlias)->(DbSkip())
	End
EndIf
FCLOSE( _oPrn )

Return( Nil )


// Ajusta as perguntas
Static Function AjustaSx1(cPerg)

Local aAreaSx1	:= SX1->(GetArea())
SX1->(DbSetOrder(1))
cPerg := PADR(UPPER(cPerg),10)

If !SX1->(DbSeek(cPerg))
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "01"
	SX1->X1_PERGUNT	:= "Nota"
	SX1->X1_PERSPA	:= "Nota"
	SX1->X1_PERENG	:= "Nota"
	SX1->X1_VARIAVL	:= "MV_CH1"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= 9
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR01"
	SX1->X1_F3		:= ""
	SX1->(MsUnlock())
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "02"
	SX1->X1_PERGUNT	:= "Serie"
	SX1->X1_PERSPA	:= "Serie"
	SX1->X1_PERENG	:= "Serie"
	SX1->X1_VARIAVL	:= "MV_CH2"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= 3
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR02"
	SX1->X1_F3		:= ""
	SX1->(MsUnlock())
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "03"
	SX1->X1_PERGUNT	:= "Volumes"
	SX1->X1_PERSPA	:= "Volumes"
	SX1->X1_PERENG	:= "Volumes"
	SX1->X1_VARIAVL	:= "MV_CH3"
	SX1->X1_TIPO	:= "N"
	SX1->X1_TAMANHO	:= 4
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR03"
	SX1->X1_F3		:= ""
	SX1->(MsUnlock())
	
	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= cPerg
	SX1->X1_ORDEM	:= "04"
	SX1->X1_PERGUNT	:= "Palets"
	SX1->X1_PERSPA	:= "Palets"
	SX1->X1_PERENG	:= "Palets"
	SX1->X1_VARIAVL	:= "MV_CH4"
	SX1->X1_TIPO	:= "N"
	SX1->X1_TAMANHO	:= 4
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR04"
	SX1->X1_F3		:= ""
	SX1->(MsUnlock())
Endif

RestArea(aAreaSX1)

Return
