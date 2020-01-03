#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cDirImp	:= "/sigep/"

/************************************************************************/
/*/{Protheus.doc} SIGM004

@description Envio de PLP para SIGEP 

@author Bernard M. Margarido
@since 09/02/2017
@version undefined

@type function
/*/
/************************************************************************/
User Function SIGM004(cNumDoc,cSerie,cOrderId,aFaixaEtq,cXmlPlp)
Local lRet		:= .T.

Private cArqLog	:= ""	

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirImp)
cArqLog := cDirImp + "LISTAGEMDEPOSTAGEM" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA INTEGRACAO SIGEP - LISTAGEMDEPOSTAGEM - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())

//-----------------------------------------+
// Inicia processo de envio das categorias |
//-----------------------------------------+
Processa({|| lRet := SIGM04PLP(cNumDoc,cSerie,cOrderId,aFaixaEtq,cXmlPlp) },"Aguarde...","Enviando postagem para SIGEP.")

LogExec("FINALIZA INTEGRACAO SIGEP - LISTAGEMDEPOSTAGEM - DATA/HORA: " + DTOC(DATE()) + " AS " + TIME())
LogExec(Replicate("-",80))
ConOut("")
	
Return lRet

/************************************************************************************/
/*/{Protheus.doc} SIGM04PLP

@description Realiza o envio de postagem SIGEP 

@author Bernard M. Margarido
@since 07/02/2017
@version undefined

@type function
/*/
/************************************************************************************/
Static Function SIGM04PLP(cNumDoc,cSerie,cOrderId,aFaixaEtq,cXmlPlp)
Local aArea		:= GetArea()

Local lRet		:= .T.

Local cAlias	:= GetNextAlias()
Local cUsuario	:= GetNewPar("VI_USERSIG","sigep")
Local cSenha	:= GetNewPar("VI_PASSSIG","n5f9t8")
Local cUrlSigep	:= GetNewPar("VI_URLSIGE","https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente")
Local cCartaoPos:= GetNewPar("VI_IDCARTA","0057018901")
 
Local nIdPlpCli	:= 0
Local nFxEtq	:= 0

Local oWsSigep	:= Nil

Private oResp	:= Nil
Private aFaixa	:= {}

//--------------------------+
// Instancia a classe SIGEP |
//--------------------------+
oWsSigep := WSSigep():New

//-------------------------+
// Parametros BuscaCliente |
//-------------------------+
oWsSigep:_Url				:= cUrlSigep
oWsSigep:cXml				:= cXmlPlp
oWsSigep:nIdPlpCliente		:= Val(cNumDoc) + Val(cSerie)
oWsSigep:cCartaoPostagem	:= cCartaoPos
oWsSigep:cUsuario 			:= cUsuario
oWsSigep:cSenha 			:= cSenha
aFaixa						:= aClone(aFaixaEtq)

//----------------------------------------------+
// Posiciona tabela de faixa de etiquetas SIGEP |
//----------------------------------------------+ 
dbSelectArea("SZ1")
SZ1->( dbSetOrder(3))

//----------------------------+
// Posiciona tabela PLP SIGEP |
//----------------------------+
dbSelectArea("SZ8")
SZ8->( dbSetOrder(1))

//---------------------+
// Posiciona Orcamento |
//---------------------+
dbSelectArea("SL1")
SL1->( dbOrderNickName("PEDIDOECO") )

//------------------------------------+
// Envia registro de PLP para o SIGEP |
//------------------------------------+		
WsdlDbgLevel(1)
If oWsSigep:fechaPlpVariosServicos()
	lRet	:= .T.
	//------------------------------------------+
	// Valida se PLP foi registrada com sucesso |
	//------------------------------------------+
	If ValType(oResp) == "O"
		If ValType(oResp:_NS2_FechaPlpVariosServicosResponse:_Return:Text) == "C" .And. !Empty(oResp:_NS2_FechaPlpVariosServicosResponse:_Return:Text)
				
			//---------------------+
			// Atualiza Tabela PLP |
			//---------------------+
			If Len(aFaixaEtq) > 0
				For nFxEtq := 1 To Len(aFaixaEtq)
					
					If SZ8->( dbSeek(xFilial("SZ8") + aFaixaEtq[nFxEtq][2]) )
						RecLock("SZ8",.F.)
							SZ8->Z8_PLPID := oResp:_NS2_FechaPlpVariosServicosResponse:_Return:Text
							SZ8->Z8_STATUS:= "04"
						SZ8->( MsUnLock() )	
					EndIf
					
					//---------------------+
					// Posiciona Orcamento |
					//---------------------+					
					SL1->( dbSeek(xFilial("SL1") + SZ8->Z8_NUMECO) )
					
					//-----------------------------+
					// Atualiza faixa de etiquetas |
					//-----------------------------+
					If SZ1->( dbSeek(xFilial("SZ1") + SL1->L1_DOC + SL1->L1_SERIE) )
						RecLock("SZ1",.F.)
							SZ1->Z1_PLPID := oResp:_NS2_FechaPlpVariosServicosResponse:_Return:Text
						SZ1->( MsUnLock() )	
					EndIf
					
				Next nFxEtq
			EndIf
			LogExec("PLP GERADO COM SUCESSO." )
		Else
			lRet	:= .F.
			LogExec("ERRO AO GERAR PLP " )
		EndIf
	Else
		lRet	:= .F.
		LogExec("ERRO AO GERAR PLP ETIQUETAS " + GetWscError() )
	EndIf
Else
	LogExec("ERRO AO GERAR PLP " + GetWscError() )
	lRet := .F.
EndIf

//------------------------------+
// Caso de erro no envio da PLP |
//------------------------------+
If !lRet 
	//---------------------+
	// Atualiza Tabela PLP |
	//---------------------+
	If Len(aFaixaEtq) > 0
		For nFxEtq := 1 To Len(aFaixaEtq)
			SZ8->( dbSetOrder(1))
			If SZ8->( dbSeek(xFilial("SZ8") + aFaixaEtq[nFxEtq][2]) )
				RecLock("SZ8",.F.)
					SZ8->Z8_STATUS:= "03"
				SZ8->( MsUnLock() )	
			EndIf
		Next nFxEtq
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*********************************************************************************/
/*/{Protheus.doc} SigM04Xml

@description Cria XML de Remetente 

@author Bernard M. Margarido
@since 09/02/2017
@version undefined

@param cNumDoc		, characters	, Numedo do Documemto de saida
@param cSerie		, characters	, Serie da Nota Fiscal de Saida
@param cOrderId		, characters	, Numero do Pedido e-Commerce

@type function
/*/
/*********************************************************************************/
User Function SigM04XR(cNumDoc,cSerie,cOrderId)
Local aArea		:= GetArea()

Local cIdCartao	:= GetNewPar("VI_IDCARTA","0057018901")
Local cCodCont	:= GetNewPar("VI_CODCONT","9912208555")
Local cCodAdm	:= GetNewPar("VI_CODADM","13424386")
Local cServPost	:= ""
Local cXml		:= ""

Local nAltura	:= 50
Local nLargura	:= 30
Local nCompr	:= 60

//------------------------------+
// Valida o serviço de Postagem | 
//------------------------------+
cServPost := SL1->L1_XSERPOS

cXml += SigM04Mtn("tipo_arquivo","Postagem")
cXml += SigM04Mtn("versao_arquivo","2.3")

cXml += '<plp>'
cXml += SigM04Mtn("id_plp")
cXml += SigM04Mtn("valor_global")
cXml += SigM04Mtn("mcu_unidade_postagem")
cXml += SigM04Mtn("nome_unidade_postagem")
cXml += SigM04Mtn("cartao_postagem",cIdCartao)
cXml += '</plp>'

cXml += '<remetente>'
cXml += SigM04Mtn("numero_contrato",Alltrim(cCodCont))
cXml += SigM04Mtn("numero_diretoria","14")
cXml += SigM04Mtn("codigo_administrativo",cCodAdm)
cXml += SigM04Mtn("nome_remetente",SubStr(Alltrim(SM0->M0_NOMECOM),1,50),.T.)
If At(",",SM0->M0_ENDCOB) > 0 
	cXml += SigM04Mtn("logradouro_remetente",SubStr(Alltrim(SM0->M0_ENDCOB),1,At(",",SM0->M0_ENDCOB) - 1),.T.)
	cXml += SigM04Mtn("numero_remetente",SubStr(Alltrim(SM0->M0_ENDCOB),At(",",SM0->M0_ENDCOB) + 1))
Else
	cXml += SigM04Mtn("logradouro_remetente",Alltrim(SM0->M0_ENDCOB),.T.)
	cXml += SigM04Mtn("numero_remetente","S/N")
EndIf	

cXml += SigM04Mtn("complemento_remetente",Alltrim(SM0->M0_COMPCOB),.T.)
cXml += SigM04Mtn("bairro_remetente",Alltrim(SM0->M0_BAIRCOB),.T.)
cXml += SigM04Mtn("cep_remetente",Alltrim(SM0->M0_CEPCOB))
cXml += SigM04Mtn("cidade_remetente",Alltrim(SM0->M0_CIDCOB),.T.)
cXml += SigM04Mtn("uf_remetente",SM0->M0_ESTCOB)
cXml += SigM04Mtn("telefone_remetente",Alltrim(u_SyFormat(SM0->M0_TEL,"A1_TEL",.T.,"C")),.T.)
cXml += SigM04Mtn("fax_remetente")
cXml += SigM04Mtn("email_remetente")
cXml += '</remetente>'

cXml += SigM04Mtn("forma_pagamento")

RestArea(aArea)
Return cXml

/*********************************************************************************/
/*/{Protheus.doc} SigM04Xml

@description Cria XML de postagem 

@author Bernard M. Margarido
@since 09/02/2017
@version undefined

@param cNumDoc		, characters	, Numedo do Documemto de saida
@param cSerie		, characters	, Serie da Nota Fiscal de Saida
@param cOrderId		, characters	, Numero do Pedido e-Commerce

@type function
/*/
/*********************************************************************************/
User Function SigM04XP(cNumDoc,cSerie,cOrderId,cCodEmb)
Local aArea		:= GetArea()

Local cIdCartao	:= GetNewPar("VI_IDCARTA","0057018901")
Local cCodCont	:= GetNewPar("VI_CODCONT","9912208555")
Local cCodAdm	:= GetNewPar("VI_CODADM","08082650")
Local cServPost	:= ""
Local cXml		:= ""
Local cEndDest	:= ""

Local nAltura	:= 0 
Local nLargura	:= 0
Local nCompr	:= 0

//------------------------------+
// Valida o serviço de Postagem | 
//------------------------------+
dbSelectArea("SZ0")
SZ0->( dbSetOrder(2) )
If SZ0->( dbSeek(xFilial("SZ0") + SL1->L1_XSERPOS) )
	cServPost := SZ0->Z0_CODSERV
EndIf

//---------------------+
// Posiciona Embalagem | 
//---------------------+	
dbSelectArea("SZ9")
SZ9->( dbSetOrder(1))
SZ9->( dbSeek(xFilial("SZ9") + cCodEmb) )
nAltura		:= SZ9->Z9_ALTURA   
nLargura	:= SZ9->Z9_LARGURA
nCompr		:= SZ9->Z9_COMPRI

cXml += '<objeto_postal>'
cXml += SigM04Mtn("numero_etiqueta",Alltrim(SL1->L1_XTRACKI))
cXml += SigM04Mtn("codigo_objeto_cliente")
cXml += SigM04Mtn("codigo_servico_postagem",Alltrim(cServPost))
cXml += SigM04Mtn("cubagem","0,00")
cXml += SigM04Mtn("peso",RetPrcUni(SL1->L1_PBRUTO,"L1_PBRUTO"))
cXml += SigM04Mtn("rt1")
cXml += SigM04Mtn("rt2")

cXml += '<destinatario>'
cXml += SigM04Mtn("nome_destinatario",SubStr(SL1->L1_XNOMDES,1,50),.T.)
cXml += SigM04Mtn("telefone_destinatario",Alltrim(SL1->L1_XDDD01) + Alltrim(SL1->L1_XTEL01),.T.)
cXml += SigM04Mtn("celular_destinatario")
cXml += SigM04Mtn("email_destinatario")

cXml += SigM04Mtn("logradouro_destinatario",SubStr(SL1->L1_ENDENT,1,50),.T.)
cXml += SigM04Mtn("complemento_destinatario")
cXml += SigM04Mtn("numero_end_destinatario",IIF(Empty(SL1->L1_XENDNUM),"S/N",Alltrim(SL1->L1_XENDNUM)),.T.)

cXml += '</destinatario>'

cXml += '<nacional>'
cXml += SigM04Mtn("bairro_destinatario",Alltrim(SL1->L1_BAIRROE),.T.)
cXml += SigM04Mtn("cidade_destinatario",Alltrim(SL1->L1_MUNE),.T.)
cXml += SigM04Mtn("uf_destinatario",SL1->L1_ESTE)
cXml += SigM04Mtn("cep_destinatario",Alltrim(SL1->L1_CEPE),.T.)
cXml += SigM04Mtn("codigo_usuario_postal")
cXml += SigM04Mtn("centro_custo_cliente")
cXml += SigM04Mtn("numero_nota_fiscal",Alltrim(Str(Val(cNumDoc))))
cXml += SigM04Mtn("serie_nota_fiscal",cSerie)
cXml += SigM04Mtn("valor_nota_fiscal")
cXml += SigM04Mtn("natureza_nota_fiscal")
cXml += SigM04Mtn("descricao_objeto","",.T.)
cXml += SigM04Mtn("valor_a_cobrar","0,00")
cXml += '</nacional>'
cXml += '<servico_adicional>'
cXml += SigM04Mtn("codigo_servico_adicional","025")
cXml += SigM04Mtn("valor_declarado")
cXml += "</servico_adicional>"
cXml += "<dimensao_objeto>"
cXml += SigM04Mtn("tipo_objeto","002")
cXml += SigM04Mtn("dimensao_altura",RetPrcUni(nAltura,"DIMENSAO"))
cXml += SigM04Mtn("dimensao_largura",RetPrcUni(nLargura,"DIMENSAO"))
cXml += SigM04Mtn("dimensao_comprimento",RetPrcUni(nCompr,"DIMENSAO"))
cXml += SigM04Mtn("dimensao_diametro","0")
cXml += '</dimensao_objeto>'
cXml += SigM04Mtn("data_postagem_sara")
cXml += SigM04Mtn("status_processamento","0")
cXml += SigM04Mtn("numero_comprovante_postagem")
cXml += SigM04Mtn("valor_cobrado")
cXml += '</objeto_postal>'

RestArea(aArea)
Return cXml

/************************************************************************/
/*/{Protheus.doc} SigM04Mtn

@description Rottina cria as TAGS de Postagem

@author Bernard M. Margarido
@since 09/02/2017
@version undefined
@param cTagName			, characters	, Nome da TAG
@param xConteud			, characters	, Conteudo da Tag
@param lCData			, logical		, Se utiliza a TAG CDATA
@type function
/*/
/************************************************************************/
Static Function SigM04Mtn(cTagName,xConteud,lCData)
Local 	cTagXml	:= ""

Default xConteud:= ""
Default lCData 	:= .F.

//-----------------------------------+
// Valida o tipo do conteudo passado |
//-----------------------------------+
If ValType(xConteud) == "N"
	xConteud := StrTran(Alltrim(Str(xConteud)),".",",")
ElseIf ValType(xConteud) == "D"
	xConteud := dToC(xConteud)
EndIf

If lCData .And. !Empty(xConteud)
	cTagXml := "<" + cTagName + "><![CDATA[" + xConteud + "]]></" + cTagName + ">"
ElseIf !lCData .And. !Empty(xConteud)
	cTagXml := "<" + cTagName + ">" + xConteud + "</" + cTagName + ">"
ElseIf Empty(xConteud) 
	cTagXml := "<" + cTagName + "/>"
EndIf

Return cTagXml
/*******************************************************************/
/*/{Protheus.doc} RetPrcUni

@description Formata valor para envio ao eCommerce

@author Bernard M. Margarido
@since 13/02/2017
@version undefined

@param nVlrUnit, numeric, descricao

@type function
/*/
/*******************************************************************/
Static Function RetPrcUni(nVlrUnit,cCpoDec) 
Local nDecimal	:= IIF(cCpoDec == "DIMENSAO",0,TamSx3(cCpoDec)[2])
Local cValor	:= ""
Local cVlrUnit	:= Alltrim(Str(nVlrUnit))
Local aValor	:= {}

If At(".",cVlrUnit) > 0
	aValor := Separa(cVlrUnit,".")
	If cCpoDec == "DIMENSAO"
		cValor := aValor[1] + aValor[2]
	Else
		cValor := aValor[1] + PadR(aValor[2],nDecimal,"0")
	EndIf	
Else
	cValor := cVlrUnit
EndIf

Return cValor
/*********************************************************************************/
/*/{Protheus.doc} LogExec

@description Grava Log do processo 

@author SYMM Consultoria
@since 26/01/2017
@version undefined

@param cMsg, characters, descricao

@type function
/*/

/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.