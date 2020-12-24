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

Local _nX		:= 0

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
cHtml += '					<td class=s_t width="100%" colspan="13"><p align=center><b>Itens Pré Nota</b></p></td>'
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

/**************************************************************************************/
/*/{Protheus.doc} DnMailPV
    @description Envia e-mail divergencia de pre notas de saida 
    @type  Function
    @author Bernard M. Margarido
    @since 22/10/2019
/*/
/**************************************************************************************/
User Function DnMailNS(_cNota,_cSerie,_cCodCli,_cLoja,_aDiverg)
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

//-------------------------------+
// Pre Nota de Venda - Cabeçalho |
//-------------------------------+
dbSelectArea("SF2")
SF2->( dbSetOrder(1) )

//----------------------------+
// Pre Nota de Venda - Itens  | 
//----------------------------+
dbSelectArea("SD2")
SD2->( dbSetOrder(3) )

//-------------------+
// Posiciona Produto |
//-------------------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//-----------------------------+
// Adiciona dados do cabeçalho |
//-----------------------------+
If !SF2->( dbSeek(xFilial("SF2") + _cDoc + _cSerie + _cCodCli + _cLoja) )
	RestArea(aArea)
	Return .F.
EndIf

//---------------------+
// Valida Tipo de Nota | 
//---------------------+
If SF2->F2_TIPO == "N"

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
cHtml += '	                     <p align=center><b>Pré Nota de Venda - Divergência Separação WMS</b></p>'
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
cHtml += '                      <p align=center><b>Dados Pré Nota de Venda</b></p>'
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
cHtml += '					<td class=s_u colspan = "2"><b>Numero\Serie:</b> ' + ' ' + SF2->F2_DOC + '\' + SF2->F2_SERIE + '</td>'
cHtml += '					<td class=s_u colspan = "2"><b>Emissão:</b>' + ' ' + dToC(SF2->F2_EMISSAO) + '</td>'
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

For _nX := 1 To Len(_aDiverg)
	
	//------------------------+
	// Posiciona Item da Nota | 
	//------------------------+
	SD2->( dbSeek(xFilial("SD2") + _cNota + _cSerie + _cCodCli  + _cLoja + _aDiverg[_nX][2] + _aDiverg[_nX][1]) )
			
	//-------------------+
	// Posiciona Produto |
	//-------------------+
	SB1->( dbSeek(xFilial("SB1") + _aDiverg[_nX][2]) )
	
	cHtml += '				<tr>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SD2->D2_ITEM + '</td>'
	cHtml += '					<td class=s_u colspan = "2"><b></b>' + SD2->D2_COD + '</td>'
	cHtml += '					<td class=s_u colspan = "7"><b></b>' + SB1->B1_DESC + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(SD2->D2_QUANT)) + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + AllTrim(Str(_aDiverg[_nX][3])) + '</td>'
	cHtml += '					<td class=s_u colspan = "1"><b></b>' + SD2->D2_LOCAL + '</td>'
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

/*************************************************************************************/
/*/{Protheus.doc} DnApi07Q

@description Cria novo pedido com saldo

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
User Function DnWmsM02(_cFilial,_cPedido,_cCodCli,_cLoja,_lTela)
Local _aArea		:= GetArea()

Local _cNumPV		:= ""
Local _cFilAux		:= cFilAnt

Local _aCpoCopy		:= {"C5_FILIAL","C5_NUM","C5_EMISSAO","C5_NOTA",;
						"C5_SERIE","C5_OS","C5_PEDEXP","C5_DTLANC",;
						"C5_LIBEROK","C5_PEDANT","C5_XENVWMS","C5_XDTALT",;
						"C5_XHRALT","C5_XRESIDU","C5_XSEQLIB","C5_XPEDPAI",;
						"C5_XTOTLIB","C5_XHORA","C5_VLRPED","C5_XPVSLD"}

Local _nX			:= 0
Local _nItem        := 1

Local _lRet			:= .T.

Local _dDtEntreg	:= Nil

Local _aStrSC5		:= SC5->( DbStruct() )
Local _aCabec		:= {}
Local _aItem		:= {}
Local _aItems		:= {}

Private lMsErroAuto	:= .F.

Default _lTela		:= .F.

//------------------------+
// Posiciona filial atual | 
//------------------------+
If _cFilial <> cFilAnt
	cFilAnt := _cFilial
EndIf

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->(dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1") + _cCodCli + _cLoja) )
_dDtEntreg := DaySum(Date(),SA1->A1_XDIASSL)
_dDtEntreg := DataValida(_dDtEntreg,.T.)

_cNumPV	:= CriaVar("C5_NUM",.T.)

//----------------+
// Cria cabeçalho |
//----------------+
aAdd(_aCabec,{"C5_NUM"		,	_cNumPV						,		Nil})
aAdd(_aCabec,{"C5_TIPO"		, 	SC5->C5_TIPO				,		Nil})
aAdd(_aCabec,{"C5_CLIENTE"	, 	SC5->C5_CLIENTE				,		Nil})
aAdd(_aCabec,{"C5_LOJACLI"	, 	SC5->C5_LOJACLI				,		Nil})
aAdd(_aCabec,{"C5_TIPOCLI"	, 	SC5->C5_TIPOCLI				,		Nil})
aAdd(_aCabec,{"C5_CONDPAG"	, 	SC5->C5_CONDPAG				,		Nil})
aAdd(_aCabec,{"C5_EMISSAO"	,	CriaVar("C5_EMISSAO",.T.)	,		Nil})
aAdd(_aCabec,{"C5_XPVSLD"	,	_cPedido					,		Nil})
aAdd(_aCabec,{"C5_XENVWMS"	,	"1"							,		Nil})
aAdd(_aCabec,{"C5_XDTALT"	,	Date()						,		Nil})
aAdd(_aCabec,{"C5_XHRALT"	,	Time()						,		Nil})
aAdd(_aCabec,{"C5_XRESIDU"	,	"X"							,		Nil})
aAdd(_aCabec,{"C5_XHORA"	,	Time()						,		Nil})
aAdd(_aCabec,{"C5_ENTREG"	,	_dDtEntreg					,		Nil})

//----------------------+
// Cria Itens do Pedido | 
//----------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If SC6->( dbSeek(xFilial("SC6") + SC5->C5_NUM) )
	
	While SC6->( !Eof() .And. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM )
	
		_aItem		:= {}
		
		//-------------------------+
		// Somente itens com saldo | 
		//-------------------------+
		If SC6->C6_XQTDRES > 0 .And. Empty(SC6->C6_NOTA)

		    aAdd(_aItem,{"C6_ITEM"	    ,	StrZero(_nItem,2)	,	Nil})    
			aAdd(_aItem,{"C6_PRODUTO"	,	SC6->C6_PRODUTO	    ,	Nil})
			aAdd(_aItem,{"C6_UM"		,	SC6->C6_UM		    ,	Nil})
			aAdd(_aItem,{"C6_QTDVEN"	,	SC6->C6_XQTDRES	    ,	Nil})
			aAdd(_aItem,{"C6_PRUNIT"	,	SC6->C6_PRUNIT	    ,	Nil})
			If SC6->C6_DESCONT > 0
				aAdd(_aItem,{"C6_PRCVEN"	,	SC6->C6_PRUNIT	,	Nil})
			Else
				aAdd(_aItem,{"C6_PRCVEN"	,	SC6->C6_PRCVEN	,	Nil})
			EndIf	
			aAdd(_aItem,{"C6_DESCONT"	,	SC6->C6_DESCONT	    ,	Nil})
			aAdd(_aItem,{"C6_TES"		,	SC6->C6_TES		    ,	Nil})
			aAdd(_aItem,{"C6_LOCAL"		,	SC6->C6_LOCAL	    ,	Nil})
			aAdd(_aItem,{"C6_NATNOTA"	,	SC6->C6_NATNOTA	    ,	Nil})
			
            _nItem++
			aAdd(_aItems,_aItem)

		EndIf	

		SC6->( dbSkip() )
	EndDo
EndIf

//------------------+
// Cria novo pedido |
//------------------+
CoNout("<< DNWMSM02 >> - GERANDO PEDIDO SALDO " + _cNumPV + " .")
If Len(_aCabec) > 0 .And. Len(_aItems) > 0
	lMsErroAuto := .F.

	_aCabec	:= FWVetByDic( _aCabec, "SC5", .F. ) 
	_aItems	:= FWVetByDic( _aItems, "SC6", .T. )

	MSExecAuto({|x,y,z| MATA410(x,y,z)},_aCabec,_aItems,3)

	If lMsErroAuto
		RollBackSx8()
		MakeDir("/wms/")
		MakeDir("/wms/logs/")
		_cArqLog	:= "SC5_SALDO" + _cNumPV + " " + DToS( Date() ) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2)+".LOG"
		_lRet		:= .F.	
		If _lTela
			MsgAlert("ERRO AO GERAR PEDIDO SALDO " + _cNumPV + " .")
			MostraErro()
		Else
			MostraErro("/wms/logs/",_cArqLog)
			DisarmTransaction()
		Endif
        CoNout("<< DNWMSM02 >> - ERRO AO GERAR PEDIDO SALDO " + _cNumPV + " .")
		
	Else
        CoNout("<< DNWMSM02 >> - PEDIDO SALDO " + _cNumPV + " GERADO COM SUCESSO.")
		_lRet := .T.	
		
		If _lTela
			MsgAlert("PEDIDO SALDO " + _cNumPV + " GERADO COM SUCESSO.")
		EndIf

		ConfirmSx8()
	EndIf
EndIf

//-----------------------+
// Restaura Filial Atual | 
//-----------------------+
If _cFilAux <> cFilAnt 
	cFilAnt := _cFilAux
EndIf

RestArea(_aArea)
Return _lRet

/*************************************************************************************/
/*/{Protheus.doc} DnaApi07E

@description Processa retorno da conferencia separação pedido de venda

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
User Function DnWmsM03(_cPedido)
Local _aArea	:= GetArea()
Local _lRet     := .T.

//----------------------+
// Cria Itens do Pedido | 
//----------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If SC6->( dbSeek(xFilial("SC6") + _cPedido) )
	While SC6->( !Eof() .And. xFilial("SC6") + _cPedido == SC6->C6_FILIAL + SC6->C6_NUM )

		If ( SC6->C6_QTDVEN - SC6->C6_QTDENT ) > 0 
            CoNout("<< DNWMSM03 >> - ELIMINANDO RESIDUO PEDIDO " + _cPedido + " ITEM " + SC6->C6_ITEM + " PRODUTO " + SC6->C6_PRODUTO + " .")
			Pergunte("MTA500",.F.)
		    	_lRet := MaResDoFat(,.T.,.F.,,MV_PAR12 == 1,MV_PAR13 == 1)
		    Pergunte("MTA410",.F.)
		EndIf
		SC6->( dbSkip() )
	EndDo
EndIf

SC6->( MaLiberOk({_cPedido},.T.) )

//-----------------------+
// Atualiza dados pedido |
//-----------------------+
If _lRet 
	RecLock("SC5",.F.)
		SC5->C5_XRESIDU := "3"
	SC5->( MsUnLock() )
EndIf

RestArea(_aArea)
Return _lRet