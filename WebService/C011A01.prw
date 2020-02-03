#include "PROTHEUS.CH"
#include "FWMVCDef.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �C011A01   � Autor �FSW TOTVS CASCAVEL     � Data � 12/09/2018 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Rotina Autom�tica para INCLUS�O de Contratos de Parceria.    ���
���          � Baseada na rotina padr�o: FATA400.PRX                        ���
���          � Tabelas: ADA e ADB                                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �TOTVS CASCAVEL                                                ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
User Function C011A01(xAutoCab,xAutoItens,nOpcAuto)

Private lA01Auto	:= xAutoCab <> nil .and. xAutoItens <> nil
Private aAutoCab	:= {}
Private aAutoItens	:= {}
//Private aRotina 	:= FWLoadMenuDef("FATA400")

dbSelectArea("ADA")
If lA01Auto
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	fInclui("ADA",0,nOpcAuto)
Endif

Return



/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �fInclui   � Autor �FSW TOTVS CASCAVEL     � Data � 14/09/2018 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para inclus�o de Contrato de Parceria via rotina      ���
���          � autom�tica EnchAuto() e MsGetDAuto()                         ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias do arquivo                                      ���
���          � ExpN2: Registro do Arquivo                                   ���
���          � ExpN3: Opcao da MBrowse                                      ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �TOTVS CASCAVEL                                                ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function fInclui(cAlias,nReg,nOpcx)

Local nX        := 0
Local nUsado    := 0
Local nSaveSx8  := GetSx8Len()

Private aTela[0][0]
Private aGets[0]
Private aHeader := {}
Private aCols   := {}
Private N       := 1
Private ALTERA := .F.
Private INCLUI := .T.

//���������������������������������Ŀ
//� Inicializa os dados da Enchoice �
//�����������������������������������
RegToMemory("ADA",.T.,.T.)

//���������������������������������Ŀ
//� Montagem do aheader             �
//�����������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("ADB")
While ! Eof() .and. SX3->X3_ARQUIVO == "ADB"
	If ( X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL )
		nUsado++
		aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_ARQUIVO ,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

//���������������������������������Ŀ
//� Montagem do acols               �
//�����������������������������������
aAdd(aCols,Array(nUsado+1))
For nX := 1 To nUsado
	aCols[1][nX] := CriaVar(aHeader[nX][2])
	If ( AllTrim(aHeader[nX][2]) == "ADB_ITEM" )
		aCols[1][nX] := "01"
	EndIf
Next nX
aCols[1][nUsado+1] := .F.

//���������������������������������Ŀ
//� Rotina autom�tica               �
//�����������������������������������
If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},nOpcX) .and. MsGetDAuto(aAutoItens,{|| fLinOk() },{|| Ft400TudOk() },aAutoCab)
	
	//���������������������������������Ŀ
	//� Efetua a grava��o               �
	//�����������������������������������
	Begin Transaction
		If Ft400Grava(1)
			EvalTrigger()
			While (GetSx8Len() > nSaveSx8)
				ConfirmSx8()
			EndDo
		Else
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			EndDo
		EndIf
	End Transaction
EndIf

Return



/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �fLinOK    � Autor �FSW TOTVS CASCAVEL     � Data � 14/09/2018 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para valida��o de LINHAOK da Getdados                 ���
���          � Baseada na fun��o padr�o Ft400LinOk(oGetd)                   ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �TOTVS CASCAVEL                                                ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function fLinOK()

Local lRetorno 	:= .T.
Local nPTes    	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ADB_TES"   })
Local nPTesCob 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ADB_TESCOB"})
Local nPosPrd  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ADB_CODPRO"})
Local nPosLocal	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ADB_LOCAL" })
Local nUsado   	:= Len(aHeader)

//������������������������������������Ŀ
//� Verifica os campo obrigatorios     �
//��������������������������������������
lRetorno := MaCheckCols(aHeader,aCols,N)

If lRetorno
	//����������������������������������Ŀ
	//� Verifica a permissao do armazem. �
	//������������������������������������
	lRetorno := MaAvalPerm(3,{aCols[n][nPosLocal],aCols[n][nPosPrd]})
	
	//����������������������������������Ŀ
	//� Verifica a integridade das TES   �
	//������������������������������������
	If lRetorno .And. !aCols[n][nUsado+1]
		If aCols[n][nPTesCob] == aCols[n][nPTes]
			Help(" ",.F.,"FT400LITES")
			lRetorno := .F.		
		EndIf
	EndIf
	
	//Ft400Rodap(oGetd) <-- Objeto oGetd n�o existe
	
	//����������������������������������������Ŀ
	//� Ponto de entrada na validacao da linha �
	//������������������������������������������
	If lRetorno
		If ExistBlock("FT400LOK")
			lRetorno := ExecBlock( "FT400LOK", .F.,.F.)
		Endif
	EndIf
EndIf

Return(lRetorno)



/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �C011A01T  � Autor �FSW TOTVS CASCAVEL     � Data � 14/09/2018 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para teste de inclus�o via rotina autom�tica          ���
���          �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �TOTVS CASCAVEL                                                ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
User Function C011A01T()

//����������������������������������������Ŀ
//� Adiciona campos do cabe�alho           �
//������������������������������������������
aCabec := {}
aAdd(aCabec, {"ADA_EMISSA", dDataBase 											, Nil})
aAdd(aCabec, {"ADA_CODCLI", PADR(AllTrim("000001"  ), TamSX3("ADA_CODCLI")[1])	, Nil})
aAdd(aCabec, {"ADA_LOJCLI", PADR(AllTrim("04"      ), TamSX3("ADA_LOJCLI")[1])	, Nil})
aAdd(aCabec, {"ADA_CONDPG", PADR(AllTrim("005"     ), TamSX3("ADA_CONDPG")[1])	, Nil})
aAdd(aCabec, {"ADA_VEND1" , PADR(AllTrim("000003"  ), TamSX3("ADA_VEND1" )[1])	, Nil})
aAdd(aCabec, {"ADA_VEND2" , PADR(AllTrim("000004"  ), TamSX3("ADA_VEND2" )[1])	, Nil})
aAdd(aCabec, {"ADA_FILENT", PADR(AllTrim("0101"    ), TamSX3("ADA_FILENT")[1])	, Nil})
aAdd(aCabec, {"ADA_TPFRET", "S"                                             	, Nil})
aAdd(aCabec, {"ADA_MOEDA" , 1                                                	, Nil})
aAdd(aCabec, {"ADA_CODSAF", PADR(AllTrim("17/18"   ), TamSX3("ADA_CODSAF")[1])	, Nil})
aAdd(aCabec, {"ADA_X_NSIM", PADR(AllTrim("291"     ), TamSX3("ADA_X_NSIM")[1])	, Nil})
aAdd(aCabec, {"ADA_XNATUR", PADR(AllTrim("11001"   ), TamSX3("ADA_XNATUR")[1])	, Nil})
aAdd(aCabec, {"ADA_XTIPCT", PADR(AllTrim("V"       ), TamSX3("ADA_XTIPCT")[1])	, Nil})
aAdd(aCabec, {"ADA_XDTENT", dDatabase+1											, Nil})

//����������������������������������������Ŀ
//� Adiciona campos dos itens              �
//������������������������������������������
aItens := {}

aItem := {}
aAdd(aItem, {"ADB_ITEM"  , StrZero( 01, TamSX3("ADB_ITEM")[1] )					, Nil})
aAdd(aItem, {"ADB_CODPRO", PADR(AllTrim("PA151000001"), TamSX3("ADB_CODPRO")[1]), Nil})
aAdd(aItem, {"ADB_LOCAL" , "10"  												, Nil})
aAdd(aItem, {"ADB_QUANT" , 40.00 												, Nil})
aAdd(aItem, {"ADB_PRCVEN",  5.00    											, Nil})
aAdd(aItem, {"ADB_TES"   , "501"												, Nil})
aAdd(aItem, {"ADB_XEMBAL", PADR(AllTrim("03"), TamSX3("ADB_XEMBAL")[1])			, Nil})
aAdd(aItem, {"ADB_XTSI"  , PADR(AllTrim("ST"), TamSX3("ADB_XTSI")[1])			, Nil})
aAdd(aItem, {"ADB_XHECTA", 1.00     											, Nil})
aAdd(aItens, aItem)
/*
aItem := {}
aAdd(aItem, {"ADB_ITEM"  , StrZero( 02, TamSX3("ADB_ITEM")[1] )					, Nil})
aAdd(aItem, {"ADB_CODPRO", PADR(AllTrim("000002"), TamSX3("ADB_CODPRO")[1])		, Nil})
aAdd(aItem, {"ADB_QUANT" , 2000.00    											, Nil})
aAdd(aItem, {"ADB_PRCVEN", 23.00     											, Nil})
aAdd(aItem, {"ADB_TES"   , PADR(AllTrim("503")   , TamSX3("ADB_TES"   )[1])		, Nil})
aAdd(aItens, aItem)
*/
//����������������������������������������Ŀ
//� Executa rotina autom�tica de inclus�o  �
//������������������������������������������
Private lMsErroAuto := .F.

U_C011A01(aCabec,aItens,3)

If ! lMsErroAuto
	MsgInfo("OK")
Else
	MostraErro()
Endif

Return


