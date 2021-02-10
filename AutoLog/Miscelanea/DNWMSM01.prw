#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#DEFINE CRLF CHR(13) + CHR(10)

Static _cDirRaiz    := "/wms/"

/******************************************************************************/
/*/{Protheus.doc} DNWMSM01
    @descrption JOB - Processa pedidos saldos
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
User Function DNWMSM01(aParam)
Local _aArea        := GetArea()

Private _lJob       := IIF( ValType(aParam) == "A", .T., .F.)

Private _oProcess   := Nil

//------------------+
// Mensagem console |
//------------------+
CoNout("<< DNWMSM01 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//---------------------------------+
// Cria diretorios caso nao exista |
//---------------------------------+
MakeDir(_cDirRaiz)

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(aParam[1], aParam[2],,,'FAT')
EndIf

//----------------------------+
// Integração Danfe eCommerce |
//----------------------------+
CoNout("<< DNWMSM01 >> - INICIO PROCESSO PEDIDOS SALDO " + dTos( Date() ) + " - " + Time() )
    If _lJob
        DnWmsM01a()
    Else
        _oProcess:= MsNewProcess():New( {|| DnWmsM01a()},"Aguarde...","Criando pedidos saldos" )
		_oProcess:Activate()
    EndIf
CoNout("<< DNWMSM01 >> - FIM PROCESSO PEDIDOS SALDO " + dTos( Date() ) + " - " + Time() )


//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< DNWMSM01 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return .T.

/******************************************************************************/
/*/{Protheus.doc} DNWMSM01A
    @descrption Processa pedidos saldos
    @type  Function
    @author Bernard M. Margarido
    @since 28/08/2019
    @version version
/*/
/******************************************************************************/
Static Function DnWmsM01a()
Local _aArea    := GetArea()

Local _cAlias   := GetNextAlias()
Local _cFilAux	:= cFilAnt
Local _cPedido  := ""
Local _cCodCli  := ""
Local _cLoja    := ""

Local _nTotReg  := 0
Local _nVlrSaldo:= 0

Local _lResiduo := .F.
Local _lSaldo   := .F.  
Local _lPedido  := .F.

//----------------------------+
// Consulta pedidos com saldo |
//----------------------------+
If !DnWmsQry(_cAlias,@_nTotReg)
    CoNout("<< DNWMSM01 >> - NAO EXISTEM DADOS PARA SEREM PROCESSADOS.")
    RestArea(_aArea)
    Return Nil
EndIf

//------------------+
// Pedidos de Venda |
//------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//------------------+
// Processa pedidos |
//------------------+
If !_lJob
    _oProcess:SetRegua1( _nTotReg )
EndIf

While (_cAlias)->( !Eof() )

	//------------------------+
	// Posiciona Filial atual |
	//------------------------+
	If cFilAnt <> (_cAlias)->C5_FILIAL 
		cFilAnt 	:= (_cAlias)->C5_FILIAL
		_cFilAux	:= cFilAnt
	EndIf

    //------------------+
    // Posiciona pedido |
    //------------------+
    SC5->( dbGoTo((_cAlias)->RECNOSC5) )

	If !_lJob
       _oProcess:IncRegua1("PEDIDO SALDO " + SC5->C5_NUM +  " .")
    EndIf

    CoNout("<< DNWMSM01 >> - VALIDANDO SALDO PEDIDO " + SC5->C5_NUM + " .")

    _cPedido    := SC5->C5_NUM
    _cCodCli    := SC5->C5_CLIENTE
    _cLoja      := SC5->C5_LOJACLI

    _lSaldo := DnApi07O(_nVlrSaldo) 
    
    If _lSaldo
        _lPedido := DnApi07Q(_cPedido,_cCodCli,_cLoja)
    Endif

    //-----------------+
    // Elimina residuo | 
    //-----------------+
    If _lSaldo .And. _lPedido
        _lResiduo := DnApi07R(_cPedido)
    ElseIf !_lSaldo
        _lResiduo := DnApi07R(_cPedido)
    EndIf
    
    If _lResiduo
        RecLock("SC5",.F.)
            SC5->C5_XRESIDU := "3"
        SC5->( MsUnLock() )
    EndIf 
    (_cAlias)->( dbSkip() )
EndDo

//-------------------------+
// Restaura a filial atual |
//-------------------------+
cFilAnt := _cFilAux

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return Nil

/*************************************************************************************/
/*/{Protheus.doc} DnaApi07O

@description Valida se pedido atingiu limite para gerar um novo pedido 

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnApi07O(_nVlrSaldo)
Local _aArea	:= GetArea()

Local _nVlrRes	:= 0

Local _lRet		:= .F.

//---------------------------+
// Posiciona itens do pedido |
//---------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If SC6->( dbSeek(xFilial("SC6") + SC5->C5_NUM) )
	//------------------+
	// Processa pedidos |
	//------------------+
	If !_lJob
		_oProcess:SetRegua2( SC6->( RecCount()) )
	EndIf

	While SC6->( !Eof() .And. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM )
		If !_lJob
       		_oProcess:IncRegua2("VALIDANDO SALDO ITEM " + SC6->C6_ITEM +  " PRODUTO " + Rtrim(SC6->C6_PRODUTO) + " .")
    	EndIf
		_nVlrRes += ( SC6->C6_PRCVEN * SC6->C6_XQTDRES )
		SC6->( dbSkip() )
	EndDo
EndIf

If _nVlrRes >= _nVlrSaldo
	_lRet := .T.
EndIf

RestArea(_aArea)
Return _lRet 

/*************************************************************************************/
/*/{Protheus.doc} DnApi07Q

@description Cria novo pedido com saldo

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnApi07Q(_cPedido,_cCodCli,_cLoja)
Local _aArea		:= GetArea()

Local _cNumPV		:= ""
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

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->(dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1") + _cCodCli + _cLoja) )
_dDtEntreg := DaySum(Date(),SA1->A1_XDIASSL)
_dDtEntreg := DataValida(_dDtEntreg,.T.)

_cNumPV	:= CriaVar("C5_NUM",.T.)

If !_lJob
	_oProcess:IncRegua1("GERANDO PEDIDO SALDO " + _cNumPV +  " .")
EndIf

//----------------+
// Cria cabeçalho |
//----------------+
//aAdd(_aCabec,{"C5_FILIAL"	,	xFilial("SC5")				,		Nil})
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
	//------------------+
	// Processa pedidos |
	//------------------+
	If !_lJob
		_oProcess:SetRegua2( SC6->( RecCount()) )
	EndIf
	While SC6->( !Eof() .And. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM )
	
		_aItem		:= {}
		
		//-------------------------+
		// Somente itens com saldo | 
		//-------------------------+
		If SC6->C6_XQTDRES > 0 .And. Empty(SC6->C6_NOTA)

			If !_lJob
       			_oProcess:IncRegua2("PEDIDO ITEM " + SC6->C6_ITEM +  " PRODUTO " + Rtrim(SC6->C6_PRODUTO) + " .")
    		EndIf	

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
CoNout("<< DNWMSM01 >> - GERANDO PEDIDO SALDO " + _cNumPV + " .")
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
		MostraErro("/wms/logs/",_cArqLog)
		DisarmTransaction()
        CoNout("<< DNWMSM01 >> - ERRO AO GERAR PEDIDO SALDO " + _cNumPV + " .")
	Else
        CoNout("<< DNWMSM01 >> - PEDIDO SALDO " + _cNumPV + " GERADO COM SUCESSO.")
		_lRet := .T.	
		ConfirmSx8()
	EndIf
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
Static Function DnApi07R(_cPedido)
Local _aArea	:= GetArea()
Local _lRet     := .T.

//---------------------+
// Regra processamento | 
//---------------------+
If !_lJob
	_oProcess:IncRegua1("ELIMINANDO RESIDUO PEDIDO " + _cPedido +  " .")
EndIf

//----------------------+
// Cria Itens do Pedido | 
//----------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
If SC6->( dbSeek(xFilial("SC6") + _cPedido) )
	While SC6->( !Eof() .And. xFilial("SC6") + _cPedido == SC6->C6_FILIAL + SC6->C6_NUM )

		//------------------+
		// Processa pedidos |
		//------------------+
		If !_lJob
			_oProcess:SetRegua2( SC6->( RecCount()) )
		EndIf

		If ( SC6->C6_QTDVEN - SC6->C6_QTDENT ) > 0 
            CoNout("<< DNWMSM01 >> - ELIMINANDO RESIDUO PEDIDO " + _cPedido + " ITEM " + SC6->C6_ITEM + " PRODUTO " + SC6->C6_PRODUTO + " .")
			If !_lJob
				_oProcess:IncRegua2("ELIMINANDO RESIDUO PEDIDO " + _cPedido + " ITEM " + SC6->C6_ITEM + " PRODUTO " + SC6->C6_PRODUTO + " .")
			EndIf
			Pergunte("MTA500",.F.)
		    	_lRet := MaResDoFat(,.T.,.F.,,MV_PAR12 == 1,MV_PAR13 == 1)
		    Pergunte("MTA410",.F.)
		EndIf
		SC6->( dbSkip() )
	EndDo

	SC6->( MaLiberOk({_cPedido},.T.) )

EndIf

RestArea(_aArea)
Return _lRet

/*************************************************************************************/
/*/{Protheus.doc} DnWmsQry

@description Consulta pedidos com saldos 

@author Bernard M. Margarido
@since 20/11/2018
@version 1.0

@type function
/*/
/*************************************************************************************/
Static Function DnWmsQry(_cAlias,_nTotReg)
Local _cQuery   := ""
Local _cFilWMS  := FormatIn(GetNewPar("DN_FILWMS","05,06"),",")

_cQuery := " SELECT " + CRLF 
_cQuery += "	TOP 1 " + CRLF 
_cQuery += "    C5.C5_FILIAL, " + CRLF
_cQuery += "	C5.C5_NUM, " + CRLF
_cQuery += "	C5.C5_CLIENTE, " + CRLF
_cQuery += "	C5.C5_LOJACLI, " + CRLF
_cQuery += "	C5.R_E_C_N_O_ RECNOSC5 " + CRLF
_cQuery += " FROM " + CRLF 
_cQuery += "	" + RetSqlName("SC5") + " C5 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	C5.C5_FILIAL IN" + _cFilWMS + " AND " + CRLF
_cQuery += "	C5.C5_XRESIDU = '2' AND " + CRLF
_cQuery += "	C5.C5_XENVWMS = '3' AND " + CRLF
_cQuery += "	C5.C5_XPVSLD = '' AND " + CRLF
_cQuery += "	C5.C5_NUM NOT IN( " + CRLF
_cQuery += "						SELECT " + CRLF
_cQuery += "							SC5.C5_XPVSLD " + CRLF
_cQuery += "						FROM " + CRLF	
_cQuery += "							" + RetSqlName("SC5") + " SC5 " + CRLF 
_cQuery += "						WHERE " + CRLF
_cQuery += "							SC5.C5_FILIAL = C5.C5_FILIAL AND " + CRLF
_cQuery += "							SC5.C5_CLIENTE = C5.C5_CLIENTE AND " + CRLF
_cQuery += "							SC5.C5_LOJACLI = C5.C5_LOJACLI " + CRLF
_cQuery += "					) AND " + CRLF
_cQuery += "	C5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY C5.C5_FILIAL,C5.C5_NUM "	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nTotReg

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (cAlias)->( Eof() )
	CoNout("<< DNWMSM01 >> - NAO EXISTEM DADOS PARA SEREM ENVIADOS.")
	(cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.