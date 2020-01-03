#Include "Protheus.Ch"
#Include "TopConn.Ch"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F380CPOS ¦   Autor ¦ Clayton Martins  ¦ Data ¦ 10/05/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Posição das colunas na rotina de Conciliação bancária.     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ 										                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function F380CPOS

aCampos	 := { { "E5_OK"  		 ,, "Rec." },; //"Rec."
{ "E5_FILIAL"    ,, "Filial" },; 		 //"Filial"
{ "E5_DATA"	     ,, "DT Movimento"},; //"DT Movimento"
{ "E5_DTDISPO"   ,, "DT Disponível"},; 		 //"DT Disponivel"
{ "E5_VALOR"     ,, "Vlr. Movimen.",PesqPict("SE5","E5_VALOR",19)},; //"Vlr. Movimen."
{ "E5_NATUREZ"   ,, "Natureza"},; //"Natureza"
{ "E5_BENEF"     ,, "Beneficiario"},; //"Benefici rio"
{ "E5_HISTOR"    ,, "Historico"},; //"Hist¢rico"
{ "E5_NUMERO"    ,, "Numero"},;  //"Número"
{ "E5_DOCUMEN"   ,, "Documento"},; //"Documento"
{ "E5_BANCO"     ,, "Banco"},; //"Banco"
{ "E5_AGENCIA"   ,, "Agencia"},; //"Agˆncia"
{ "E5_CONTA"     ,, "Conta"},; //"Conta"
{ "E5_NUMCHEQ"   ,, "Num. Cheque"},; //"Num. Cheque"
{ "E5_VENCTO"    ,, "Vencimento"},; //"Vencimeto"
{ "E5_RECPAG"    ,, "Rec/Pag"},; //"Rec/Pag"
{ "E5_CREDITO"   ,, "Cta Credito"},;  //"Cta Cr‚dito"
{ "E5_PREFIXO"   ,, "Prefixo"},;  //"Prefixo"
{ "E5_PARCELA"   ,, "Parcela"},;  //"Parcela"
{ "E5_TIPO" 	 ,, "Tipo"},;   //"Tipo"
{ "E5_MOEDA"     ,, "Numerario"},; //"Numer rio"
{ "E5_CLIFOR"	 ,, "Cli/For"},;  //"Cli/For"
{ "E5_LOJA" 	 ,, "Loja"}} //"Loja"

Return(aCampos)
