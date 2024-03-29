#Include "protheus.ch" 
#include "rwmake.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
//--------------------------------------------------------------------
/*/{Protheus.doc} XDNALTSA1
Manuten��o cadastro de clientes.
@author TOTVS Protheus
@since  
/*/
//--------------------------------------------------------------------
User Function XDNALTSA1()

Local lRet		:= .T.
Local cUsuFin	:= ""
Local cCodUsu	:= ""
Local cNomUsr   := ""

Private cConta	:= AllTrim(GetMv("MV_XMAIFIN"))
Private cMsgCam := ""
Private cPulaLin:= Chr(13) + Chr(10)
Private cDescAbt:= ""
Private cLimCred:= ""

Return .T.

cUsuFin	:= GETMV("MV_XFINSA1")
cCodUsu	:= __cUserID  //RetCodUsr()
cNomUsr := PswChave(RetCodUsr())

If ALTERA 
    If !cCodUsu $cUsuFin
        If MsgYesNo("Caso confirme a manuten��o nesse campo. O cadastro ser� bloqueado e ser� enviado um e-mail informando o departamento financeiro! Confirma a Manuten��o?","XDNALTSA1")
            M->A1_MSBLQL    := "1"
            M->A1_XBLQFIN   := "1"
            cCodSA1	:= M->A1_COD
            cLojSA1	:= M->A1_LOJA
            cNomSA1	:= M->A1_NOME
            If M->A1_DESCABT <> SA1->A1_DESCABT
                dbSelectArea('SX3')
                SX3->(dbSetOrder(2))
                SX3->(dbSeek("A1_DESCABT"))
                cDescAbt:= TransForm(SA1->A1_DESCABT,'@E 99')
                cMsgCam += "Manuten��o no campo " +Alltrim(X3TITULO())+ cPulaLin
                cMsgCam += "Conte�do anterior: "+ cDescAbt + cPulaLin
                cMsgCam += "Conte�do ap�s manuten��o: "+ cValToChar(M->A1_DESCABT) + cPulaLin
                cMsgCam += "Operador: " + cNomUsr + cPulaLin
            Endif
            if M->A1_LC <> SA1->A1_LC
                dbSelectArea('SX3')
                SX3->(dbSetOrder(2))
                SX3->(dbSeek("A1_LC"))
                cLimCred:= TransForm(SA1->A1_LC,'@E 9999,999.99')
                cMsgCam += "Manuten��o no campo " +Alltrim(X3TITULO())+ cPulaLin
                cMsgCam += "Conte�do anterior: "+ cLimCred + cPulaLin
                cMsgCam += "Conte�do ap�s manuten��o: "+ cValToChar(M->A1_LC) + cPulaLin
                cMsgCam += "Operador: " + cNomUsr + cPulaLin
                cMsgCam += "Operador: " + cNomUsr + cPulaLin
            Endif
            if M->A1_RISCO <> SA1->A1_RISCO
                dbSelectArea('SX3')
                SX3->(dbSetOrder(2))
                SX3->(dbSeek("A1_RISCO"))
                cMsgCam += "Manuten��o no campo " +Alltrim(X3TITULO())+ cPulaLin
                cMsgCam += "Conte�do anterior: "+ SA1->A1_RISCO + cPulaLin
                cMsgCam += "Conte�do ap�s manuten��o: "+ M->A1_RISCO + cPulaLin
                cMsgCam += "Operador: " + cNomUsr + cPulaLin
            Endif
            if M->A1_VENCLC <> SA1->A1_VENCLC
                dbSelectArea('SX3')
                SX3->(dbSetOrder(2))
                SX3->(dbSeek("A1_VENCLC"))
                cMsgCam += "Manuten��o no campo " +Alltrim(X3TITULO())+ cPulaLin
                cMsgCam += "Conte�do anterior: "+ DTOS(SA1->A1_VENCLC) + cPulaLin
                cMsgCam += "Conte�do ap�s manuten��o: "+ DTOS(M->A1_VENCLC) + cPulaLin
                cMsgCam += "Operador: " + cNomUsr + cPulaLin
            Endif
            /*+---------------------------------+
            | Cabe�alho E-mail				    |
            +---------------------------------+*/
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
            cTable += '<TR><TD CLASS=S_A width="100%"><P align=center><B>Manuten��o no cadastrado cliente, aguardando libera��o Financeiro</B></P></TD></TR>'
            cTable += '</TBODY>'
            cTable += '</TABLE>'
            cTable += "<table border='1' width='100%'>"
            cTable += "<tr>"
            cTable += "<td>C�digo		</td>"
            cTable += "<td>Loja			</td>"
            cTable += "<td>Nome			</td>"
            cTable += "</tr>"
            /*+---------------------------------+
            | Itens do E-mail.				    |
            +---------------------------------+*/
            cTable += "<tr>"
            cTable += "<td style='align:left'>" 	+cCodSA1					+"</td>"
            cTable += "<td style='align:left'>" 	+cLojSA1					+"</td>"
            cTable += "<td style='align:left'>" 	+cNomSA1		 			+"</td>"
            cTable += "</tr>"
            cTable += "</table>"
            
            cTable+= '<td style="text-align: center; width: 15%;" height="53">
            cTable+= '<img border="0" src="http://181.41.175.59:1866/emp01/wfpc/Logo_Dana.jpg"></td>
            cTable+= '<br><br><br><p align="left"><span lang="pt-br"><font face="Arial" size="3">'+cMsgCam+'</font></span></p>'
            cTable+= '<br><br><br><p align="left"><span lang="pt-br"><font face="Arial" size="1">Destinat�rios: '+cConta+'</font></span></p>'
            cTable+= '<br><br><br><p align="left"><span lang="pt-br"><font face="Arial" size="1">DANA COSM�TICOS</font></span></p>'
            cTable+= '</html>'
            
            cMsg := '<html>'   //Monta corpo do e-mail em HTML
            cMsg += '<head>'
            cMsg += '<title></title>'
            cMsg += '</head>'
            cMsg += '<BODY>'
            cMsg +=	cTable
            cMsg +=	'<br/>'
            cMsg += '</BODY>'
            cMsg += '</html>'
            
            cSubject	:= "O cadastro de cliente "+Alltrim(cNomSA1)+", ser� bloqueado, aguardando analise e libera��o do financeiro!"
            U_XEnvEmail(cSubject,cMsg,cConta)
        Else    
            M->A1_DESCABT   := SA1->A1_DESCABT
            M->A1_LC        := SA1->A1_LC
            M->A1_RISCO     := SA1->A1_RISCO
            M->A1_VENCLC    := SA1->A1_VENCLC
            lRet    := .F.
        Endif
    Endif
Endif

Return(lRet)
