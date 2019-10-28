#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/**************************************************************************************/
/*/{Protheus.doc} DnMailPV
    @description Envia e-mail divergencia de pedidos de venda
    @type  Function
    @author Bernard M. Margarido
    @since 22/10/2019
/*/
/**************************************************************************************/
User Function DnMailPV(_cPedido,_cCodCli,_cLoja,_aDiverg)
Local _aArea    := GetArea()

Local cServer	:= GetMv("MV_RELSERV")
Local cUser		:= GetMv("MV_RELAUSR")
Local cPassword := GetMv("MV_RELAPSW")
Local cFrom		:= GetMv("MV_RELACNT")

Local cMail		:= GetNewPar("DN_MAILWMS","bernard.modesto@alfaerp.com.br;bernard.margarido@gmail.com")
Local cTitulo	:= "Dana - Divergencia separação."
Local cHtml		:= ""

Local _nX		:= 0

Local lEnviado	:= .F.
Local lOk		:= .F.
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)

//---------------------------------+
// Posiciona Cabeçalho da Pre Nota |
//---------------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//-----------------------------+
// Posiciona Itens da Pre Nota | 
//-----------------------------+
//dbSelectArea("SC9")
//SC9->( dbSetOrder(1) )

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//-----------------------------+
// Adiciona dados do cabeçalho |
//-----------------------------+
If !SC5->( dbSeek(xFilial("SC5") + _cPedido) )
	RestArea(aArea)
	Return .F.
EndIf

//---------------------+
// Valida Tipo de Nota | 
//---------------------+
If SC5->C5_TIPO == "N"

	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	SA1->( dbSeek(xFilial("SA1") + _cCodCli + _cLoja) )

	_cCliFor	:= SA1->A1_COD
	_cLoja		:= SA1->A1_LOJA
	_cNReduz	:= SA1->A1_NREDUZ

Else

	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2") + _cCodCli + _cLoja) )

	_cCliFor	:= SA2->A2_COD
	_cLoja		:= SA2->A2_LOJA
	_cNReduz	:= SA2->A2_NREDUZ 

EndIf

cHtml := '<html>'
cHtml += '	<head>'
cHtml += '		<title>Workflow - Integrações WMS</title>'
cHtml += '		<style>'
cHtml += '          {font-family: arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '         	#div {font-family: arial, helvetica, sans-serif; font-size: 10pt;background-color: #000000}'
cHtml += '         	#table {font-family: arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '         	#td {font-family:arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '         	.mini {font-family:arial, helvetica, sans-serif; font-size: 10px}'
cHtml += '         	#form {margin: 0px}'
cHtml += '         	.s_aa {font-size: 28px; vertical-align: top; width: 20%; color: #ffffff; font-family: arial, helvetica, sans-serif;'
cHtml += '         	background-color: #ffffff; text-align: left}'
cHtml += '         	.s_a  {font-size: 28px; vertical-align: center; width: 80%; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #ffffff; text-align: left}'
cHtml += '         	.s_b  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #ffff99; text-align: left}'		
cHtml += '         	.s_c  {font-size: 12px; vertical-align: top; width: 05% ; color: #ffffff; font-family: arial, helvetica, sans-serif; background-color: #6baccf; text-align: left}'			
cHtml += '         	.s_d  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #e8e8e8; text-align: left}'			
cHtml += '         	.s_o  {font-size: 12px; vertical-align: top; width: 05% ; font-family: arial, helvetica, sans-serif; text-align: left}'
cHtml += '         	.s_t  {font-size: 16px; vertical-align: top; width: 100%; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #e8e8e8; text-align: center}'
cHtml += '         	.s_u  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; text-align: left}'
cHtml += '		</style>'
cHtml += '	</head>'
cHtml += '	<body>'
cHtml += '		<table id="div" width="100%" border=0>'
cHtml += '          <tbody>'
cHtml += '               <tr>'
cHtml += '	               	<td class=s_aa width="50%">'
cHtml += '	                     <img src="https://danacosmeticos.vteximg.com.br/arquivos/dana-logo-002.png">'
cHtml += '	                </td>'	
cHtml += '	                <td class=s_a width="50%">'
cHtml += '	                     <p align=center><b>Pedido de Venda - Divergência Separação WMS</b></p>'
cHtml += '	                </td>'
cHtml += '               </tr>'
cHtml += '            </tbody>'
cHtml += '		</table>'
cHtml += '		<table width="100%" cellspacing=0 border=0>'
cHtml += '          <tbody>'
cHtml += '              <tr>'
cHtml += '            	    <td></td>'
cHtml += '              </tr>'
cHtml += '              <tr>'
cHtml += '            	    <td></td>'	
cHtml += '              </tr>'				
cHtml += '              <tr>'
cHtml += '                  <td class=s_t width="100%">'
cHtml += '                      <p align=center><b>Dados Pedido de Venda</b></p>'
cHtml += '                  </td>'
cHtml += '              </tr>'
cHtml += '              <tr>'
cHtml += '            	    <td></td>'
cHtml += '              </tr>'
cHtml += '              <tr>'
cHtml += '            	    <td></td>'	
cHtml += '              </tr>'				
cHtml += '            </tbody>'
cHtml += '		</table>'
cHtml += '		<table style="width: 100%; height: 26px" cellspacing=0 border=1>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '					<td class=s_u colspan = "2"><b>Numero:</b> ' + ' ' + SC5->C5_NUM + '</td>'
cHtml += '					<td class=s_u colspan = "2"><b>Emissão:</b>' + ' ' + dToC(SC5->C5_EMISSAO) + '</td>'
cHtml += '				</tr>'
cHtml += '				<tr>'
cHtml += '					<td class=s_u colspan = "7"><b>Cliente:</b>' + ' ' + _cCliFor + ' - ' + _cLoja + ' '   + _cNReduz + '</td>'
cHtml += '				</tr>'
cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<table width="100%" cellspacing=0 border=0>'
cHtml += '			<tbody>'
cHtml += '              <tr>'
cHtml += '                  <td></td>'
cHtml += '              </tr>'
cHtml += '              <tr>'
cHtml += '                  <td></td>'
cHtml += '              </tr>'					
cHtml += '				<tr>'
cHtml += '					<td class=s_t width="100%"><p align=center><b>Itens Pedido</b></p></td>'
cHtml += '				</tr>'
cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<table style="width: 100%; height: 26px" cellspacing=0 border=1>'
cHtml += '			<tbody>'
cHtml += '				<tr>'  					
cHtml += '					<td class=s_u colspan = "1"><b>Item</b></td>'
cHtml += '					<td class=s_u colspan = "2"><b>Produto</b></td>'
cHtml += '					<td class=s_u colspan = "7"><b>Descricao</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Qtd. Nota</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Qtd. Conf.</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Armazem</b></td>'
cHtml += '				</tr>'

//-----------------+
// Itens liberados | 
//-----------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

For _nX := 1 To Len(_aDiverg)
	
	//------------------------+
	// Posiciona Item da Nota | 
	//------------------------+
	SC9->( dbSeek(xFilial("SC9") + _cPedido + _aDiverg[_nX][1] ) )
		
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB1->( dbSeek(xFilial("SB1") + _aDiverg[_nX][2]) )
	
	cHtml += '				<tr>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SC9->C9_ITEM + '</td>'
	cHtml += '					<td class=s_u colspan = "2"><b></b>' + SC9->C9_PRODUTO + '</td>'
	cHtml += '					<td class=s_u colspan = "7"><b></b>' + SB1->B1_DESC + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(SC9->C9_QTDLIB)) + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(_aDiverg[_nX][3])) + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SC9->C9_LOCAL + '</td>'
	cHtml += '				</tr>'
	
Next _nX	

cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<p>Workflow enviado automaticamente pelo Protheus - Dana Cosméticos</p>'
cHtml += '	</body>'
cHtml += '</html>'

//-------------------------------------------------------------+
// Verifica usuario e senha para conectar no servidor de saida |
//-------------------------------------------------------------+
CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPassword RESULT lOk

//---------------------------+
// Autentica usuario e senha |
//---------------------------+
If lRelauth
	lOk := MailAuth(cUser,cPassword)
EndIf	

//--------------------------------------------------------------+
// Verifica se conseguiu conectar no servidor de saida e valida |
// se conseguiu atenticar para enviar o e-mail                  |
//--------------------------------------------------------------+
If lOk
	SEND MAIL FROM cFrom TO cMail SUBJECT cTitulo BODY cHtml RESULT lEnviado 
Else
	Conout("Erro ao Conectar ! ")
Endif			

If lEnviado
	Conout("E-Mail Enviado com sucesso ")
Else                            
	GET MAIL ERROR cError
	Conout("Erro ao enviar e-mail --> " + cError)	
EndIf	

//---------------------------------+
// Disconecta do servidor de saida |
//---------------------------------+
DISCONNECT SMTP SERVER

RestArea(_aArea)
Return lEnviado

/**************************************************************************************/
/*/{Protheus.doc} DnMailNf
    @description Envia e-mail divergencia de pre notas de entrada
    @type  Function
    @author Bernard M. Margarido
    @since 22/10/2019
/*/
/**************************************************************************************/
User Function DnMailNf(_cNota,_cSerie,_cCodFor,_cLojafor,_aDiverg)
Local aArea		:= GetArea()

Local cServer	:= GetMv("MV_RELSERV")
Local cUser		:= GetMv("MV_RELAUSR")
Local cPassword := GetMv("MV_RELAPSW")
Local cFrom		:= GetMv("MV_RELACNT")

Local cMail		:= GetNewPar("DN_MAILWMS","bernard.modesto@alfaerp.com.br;bernard.margarido@gmail.com")
Local cTitulo	:= "Dana - Divergencia recebimento."
Local cHtml		:= ""

Local lEnviado	:= .F.
Local lOk		:= .F.
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)

//---------------------------------+
// Posiciona Cabeçalho da Pre Nota |
//---------------------------------+
dbSelectArea("SF1")
SF1->( dbSetOrder(1) )

//-----------------------------+
// Posiciona Itens da Pre Nota | 
//-----------------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//-----------------------------+
// Adiciona dados do cabeçalho |
//-----------------------------+
If !SF1->( dbSeek(xFilial("SF1") + _cNota + _cSerie + _cCodFor + _cLojafor) )
	RestArea(aArea)
	Return .F.
EndIf

//---------------------+
// Valida Tipo de Nota | 
//---------------------+
If SF1->F1_TIPO == "N"
	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA) )
	_cCliFor	:= SA2->A2_COD
	_cLoja		:= SA2->A2_LOJA
	_cNReduz	:= SA2->A2_NREDUZ
Else
	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	SA1->( dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA) )
	_cCliFor	:= SA1->A1_COD
	_cLoja		:= SA1->A1_LOJA
	_cNReduz	:= SA1->A1_NREDUZ 
EndIf

cHtml := '<html>'
cHtml += '	<head>'
cHtml += '		<title>Workflow - Integrações WMS</title>'
cHtml += '		<style>'
cHtml += '          {font-family: arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '         	#div {font-family: arial, helvetica, sans-serif; font-size: 10pt;background-color: #000000;}'
cHtml += '         	#table {font-family: arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '         	#td {font-family:arial, helvetica, sans-serif; font-size: 10pt}'
cHtml += '         	.mini {font-family:arial, helvetica, sans-serif; font-size: 10px}'
cHtml += '         	#form {margin: 0px}'
cHtml += '         	.cab{font-family: arial, helvetica, sans-serif; font-size: 10pt; border-bottom: 2px solid #000;}'
cHtml += '         	.s_aa {font-size: 28px; vertical-align: top; width: 20%; color: #ffffff; font-family: arial, helvetica, sans-serif;' 
cHtml += '         	background-color: #ffffff; text-align: left}'
cHtml += '         	.s_a  {font-size: 28px; vertical-align: center; width: 80%; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #ffffff; text-align: left}'
cHtml += '         	.s_b  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #ffff99; text-align: left}'
cHtml += '         	.s_c  {font-size: 12px; vertical-align: top; width: 05% ; color: #ffffff; font-family: arial, helvetica, sans-serif; background-color: #6baccf; text-align: left}'
cHtml += '         	.s_d  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #e8e8e8; text-align: left}'
cHtml += '         	.s_o  {font-size: 12px; vertical-align: top; width: 05% ; font-family: arial, helvetica, sans-serif; text-align: left}'
cHtml += '         	.s_t  {font-size: 16px; vertical-align: top; width: 100%; color: #000000; font-family: arial, helvetica, sans-serif; background-color: #e8e8e8; text-align: center; }'
cHtml += '         	.s_u  {font-size: 12px; vertical-align: top; width: 05% ; color: #000000; font-family: arial, helvetica, sans-serif; text-align: left}'
cHtml += '		</style>'
cHtml += '	</head>'
cHtml += '	<body>'
cHtml += '		<table class=cab width="100%" border=0>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '	               	<td class=s_aa width="50%">'
cHtml += '	                     <img src="https://danacosmeticos.vteximg.com.br/arquivos/dana-logo-002.png">'
cHtml += '	                </td>'	
cHtml += '	                <td class=s_a width="50%">'
cHtml += '	                     <p align=center><b>Pré Nota de Entrada - Divergência Recebimento WMS</b></p>'
cHtml += '	                </td>'
cHtml += '               </tr>'
cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '      <br>'
cHtml += '		<table width="100%" cellspacing=0 border=1>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '					<td class=s_t width="100%" colspan="14"><p align=center><b>Dados da Pré Nota</b></p></td>'
cHtml += '				</tr>'
cHtml += '			</tbody>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '					<td class=s_u colspan = "1"><b>Documento:</b> ' + ' ' + SF1->F1_DOC + '</td>'
cHtml += '					<td class=s_u colspan = "4"><b>Serie:</b> ' + ' ' + SF1->F1_SERIE +  '</td> '
cHtml += '					<td class=s_u colspan = "2"><b>Emissão:</b>' + ' ' + FsDateConv(SF1->F1_EMISSAO,"DDMMYYYY") + '</td>'
cHtml += '				</tr>'
cHtml += '				<tr>'
cHtml += '					<td class=s_u colspan = "7"><b>Fornecedor:</b>' + ' ' + _cCliFor + ' - ' + _cLoja + ' '   + _cNReduz + '</td>'
cHtml += '				</tr>'
cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<br>'
cHtml += '		<table width="100%" cellspacing=0 border=1>'
cHtml += '			<tbody>'
cHtml += '				<tr>'
cHtml += '					<td class=s_t width="100%" colspan="13"><p align=center><b>Itens Pré Nota</b></p></td>
cHtml += '				</tr>'
cHtml += '				<tr>'  					
cHtml += '					<td class=s_u colspan = "1"><b>Item</b></td>'
cHtml += '					<td class=s_u colspan = "3"><b>Produto</b></td>'
cHtml += '					<td class=s_u colspan = "6"><b>Descricao</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Qtd. Nota</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Qtd. Conf.</b></td>'
cHtml += '					<td class=s_u colspan = "1"><b>Armazem</b></td>'
cHtml += '				</tr>'
//-------------------+
// Itens da Pré Nota | 
//-------------------+
dbSelectArea("SD1")
SD1->( dbSetOrder(1) )

For _nX := 1 To Len(_aDiverg)
	
	//------------------------+
	// Posiciona Item da Nota | 
	//------------------------+
	SD1->( dbSeek(xFilial("SD1") + _cNota + _cSerie + _cCodFor + _cLojafor +  _aDiverg[_nX][2] + _aDiverg[_nX][1] ))
	
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB1->( dbSeek(xFilial("SB1") + _aDiverg[_nX][2]) )
	
	cHtml += '				<tr>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SD1->D1_ITEM + '</td>'
	cHtml += '					<td class=s_u colspan = "3"><b></b>' + SD1->D1_COD + '</td>'
	cHtml += '					<td class=s_u colspan = "6"><b></b>' + SB1->B1_DESC + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(SD1->D1_QUANT)) + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(_aDiverg[_nX][3])) + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SD1->D1_LOCAL + '</td>'
	cHtml += '				</tr>'
	
Next _nX	

cHtml += '			</tbody>'
cHtml += '		</table>'
cHtml += '		<p>Workflow enviado automaticamente pelo Protheus - Dana Cosméticos</p>'
cHtml += '	</body>'
cHtml += '</html>'

//-------------------------------------------------------------+
// Verifica usuario e senha para conectar no servidor de saida |
//-------------------------------------------------------------+
CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPassword RESULT lOk

//---------------------------+
// Autentica usuario e senha |
//---------------------------+
If lRelauth
	lOk := MailAuth(cUser,cPassword)
EndIf	

//--------------------------------------------------------------+
// Verifica se conseguiu conectar no servidor de saida e valida |
// se conseguiu atenticar para enviar o e-mail                  |
//--------------------------------------------------------------+
If lOk
	SEND MAIL FROM cFrom TO cMail SUBJECT cTitulo BODY cHtml RESULT lEnviado 
Else
	Conout("Erro ao Conectar ! ")
Endif			

If lEnviado
	Conout("E-Mail Enviado com sucesso ")
Else                            
	GET MAIL ERROR cError
	Conout("Erro ao enviar e-mail --> " + cError)	
EndIf	

//---------------------------------+
// Disconecta do servidor de saida |
//---------------------------------+
DISCONNECT SMTP SERVER

RestArea(aArea)
Return lEnviado
