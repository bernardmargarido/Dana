#include "rwmake.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA030TOK ¦ Autor ¦ Clayton Martins    ¦ Data ¦ 03/09/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de entrada para bloquear clientes para analise do    ¦¦¦
¦¦¦          ¦ departamento fiscal.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PERFUMES DANA    					                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function MA030TOK()

Local lRet	 		:= .T.
Local aAreaSA1		:= SA1->(GetArea())

//Local cCodSA1		:= ""
//Local cLojSA1		:= ""
//Local cNomSA1		:= ""
//Local cSubject		:= ""
//Local cTable		:= ""
//Local cMsg			:= ""

Local _lECommerce	:= IIF(Isincallstack("U_AECOI011"),.T.,.F.)
Local _lMRP			:= IIF(Isincallstack("U_DNMRPA01") .Or. Isincallstack("U_DNMRPA02"),.T.,.F.)

Private cConta		:= AllTrim(GetMv("MV_XBLQSA1"))//renata.rigo@perfumesdana.com.br;eguillen@perfumesdana.com.br
Private cConta2		:= AllTrim(GetMv("MV_XMAISA1"))//renata.rigo@perfumesdana.com.br;alessandra@perfumesdana.com.br;eguillen@perfumesdana.com.br

If _lECommerce .Or. _lMRP
	RestArea(aAreaSA1)
	Return .T.
EndIf

/*
If INCLUI
	Msginfo("O cadastro de cliente será bloqueado, aguardando analise e liberação dos departamentos fiscal/financeiro!","MA030TOK")
	
	cCodSA1	:= M->A1_COD
	cLojSA1	:= M->A1_LOJA
	cNomSA1	:= M->A1_NOME
	
	//+---------------------------------+
	//| Cabeçalho E-mail				|
	//+---------------------------------+
	cTable := '<STYLE>'
	cTable += 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
	cTable += 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
	cTable += 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
	cTable += 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
	cTable += '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
	cTable += 'FORM {MARGIN: 0px}'
	cTable += '.S_A  {FONT-SIZE: 28px; VERTICAL-ALIGN: top; WIDTH: 100%; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: center}'
	cTable += '.S_B  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF99; TEXT-ALIGN: left}  '
	cTable += '.S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left}  '
	cTable += '.S_D  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left}  '
	cTable += '.S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
	cTable += '</STYLE>'
	cTable += '<TABLE style="COLOR: rgb(0,0,0)" width="100%" border=1>'
	cTable += '<TBODY>'
	cTable += '<TR><TD CLASS=S_A width="100%"><P align=center><B>Cliente cadastrado, aguardando liberação Fiscal/Financeiro</B></P></TD></TR>'
	cTable += '</TBODY>'
	cTable += '</TABLE>'
	cTable += "<table border='1' width='100%'>"
	cTable += "<tr>"
	cTable += "<td>Código		</td>"
	cTable += "<td>Loja			</td>"
	cTable += "<td>Nome			</td>"
	cTable += "</tr>"
	
	//+---------------------------------+
	//| Itens do E-mail.				  |
	//+---------------------------------+

	cTable += "<tr>"
	cTable += "<td style='align:left'>" 	+cCodSA1					+"</td>"
	cTable += "<td style='align:left'>" 	+cLojSA1					+"</td>"
	cTable += "<td style='align:left'>" 	+cNomSA1		 			+"</td>"
	cTable += "</tr>"
	cTable += "</table>"
	
	cMsg := '<html>'   //Monta corpo do e-mail em HTML
	cMsg += '<head>'
	cMsg += '<title></title>'
	cMsg += '</head>'
	cMsg += '<BODY>'
	cMsg +=	cTable
	cMsg +=	'<br/>'
	cMsg += '</BODY>'
	cMsg += '</html>'
	
	cSubject	:= "O cadastro de cliente "+Alltrim(cNomSA1)+", será bloqueado, aguardando analise e liberação dos departamentos fiscal/financeiro!"
	If M->A1_XBLQFIN == "1" .Or. M->A1_XBLQFIN == "1"
		U_XEnvEmail(cSubject,cMsg,cConta)
	Endif
	
EndIf

If ALTERA
	If M->A1_XBLQFIN == "2" .And. M->A1_XBLQFIN == "2"
		If SA1->A1_MSBLQL == "1"//Bloqueado
			If M->A1_MSBLQL <> "1"//Desbloqueado
				
				Msginfo("Cadastro liberado pelos departamentos Fiscal/Financeiro!","MA030TOK")
				
				cCodSA1	:= SA1->A1_COD
				cLojSA1	:= SA1->A1_LOJA
				cNomSA1	:= SA1->A1_NOME
				
				//---------------------------------+
				// Cabeçalho E-mail				   |
				//---------------------------------+
				cTable := '<STYLE>'
				cTable += 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
				cTable += 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
				cTable += 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
				cTable += 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
				cTable += '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
				cTable += 'FORM {MARGIN: 0px}'
				cTable += '.S_A  {FONT-SIZE: 28px; VERTICAL-ALIGN: top; WIDTH: 100%; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: center}'
				cTable += '.S_B  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF99; TEXT-ALIGN: left}  '
				cTable += '.S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left}  '
				cTable += '.S_D  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left}  '
				cTable += '.S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
				cTable += '</STYLE>'
				cTable += '<TABLE style="COLOR: rgb(0,0,0)" width="100%" border=1>'
				cTable += '<TBODY>'
				cTable += '<TR><TD CLASS=S_A width="100%"><P align=center><B>Cadastro de cliente liberado</B></P></TD></TR>'
				cTable += '</TBODY>'
				cTable += '</TABLE>'
				cTable += "<table border='1' width='100%'>"
				cTable += "<tr>"
				cTable += "<td>Código		</td>"
				cTable += "<td>Loja			</td>"
				cTable += "<td>Nome			</td>"
				cTable += "</tr>"
				
				//---------------------------------
				// Itens do E-mail.				   |
				//---------------------------------
				cTable += "<tr>"
				cTable += "<td style='align:left'>" 	+cCodSA1					+"</td>"
				cTable += "<td style='align:left'>" 	+cLojSA1					+"</td>"
				cTable += "<td style='align:left'>" 	+cNomSA1		 			+"</td>"
				cTable += "</tr>"
				cTable += "</table>"
				
				cMsg := '<html>'   //Monta corpo do e-mail em HTML
				cMsg += '<head>'
				cMsg += '<title></title>'
				cMsg += '</head>'
				cMsg += '<BODY>'
				cMsg +=	cTable
				cMsg +=	'<br/>'
				cMsg += '</BODY>'
				cMsg += '</html>'
				
				cSubject	:= "O cadastro de cliente "+Alltrim(cNomSA1)+", foi liberado pelos departamentos fiscal e financeiro!"
				
				U_XEnvEmail(cSubject,cMsg,cConta2)
			Endif
		Endif
	Endif
EndIf
*/
//-----------------------------+
// Atualiza dados da alteração |
//-----------------------------+
RecLock("SA1",.F.)
	SA1->A1_XDTALT	:= dDatabase
	SA1->A1_XHRALT	:= Time()
SA1->( MsUnLock() )
	
RestArea(aAreaSA1)
Return lRet
