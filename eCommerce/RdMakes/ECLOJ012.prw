#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

Static cDirImp	:= "/ecommerce/"

/**************************************************************************/
/*/{Protheus.doc} ECLOJ012
    @description Processa as vendas ecommerce 
    @type  Function
    @author Bernard M. Margarido
    @since 28/05/2019
/*/
/**************************************************************************/
User Function ECLOJ012()
Local _aArea    := GetArea()

Local _cAlias   := ""

Local _lContinua:= .T.

Private cArqLog	:= ""	

Private _lJob   := IIF(Isincallstack("U_ECLOJM04"),.T.,.F.)

//------------------------------+
// Inicializa Log de Integracao |
//------------------------------+
MakeDir(cDirImp)
cArqLog := cDirImp + "ECLOJ012" + cEmpAnt + cFilAnt + ".LOG"
ConOut("")	
LogExec(Replicate("-",80))
LogExec("INICIA PROCESSAMENTO DE PEDIDO ECOMMERCE - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())


//--------------------------+
// Consulta pedidos na fila |
//--------------------------+
_cAlias := GetNextAlias()
If !EcLoj012Qry(_cAlias)
    LogExec("NAO EXISTEM DADOS PARA SEREM PROCESSADOS.")
    (_cAlias)->( dbCloseArea() )
    _lContinua := .F.
EndIf

//------------------------------+
// Processa as vendas eCommerce |
//------------------------------+
If _lContinua

    //---------------------------------------+
    // Seleciona tabela de pedidos eCommerce |
    //---------------------------------------+
    dbSelectArea("WSA")
    WSA->( dbSetOrder(1) )

    //--------------------------------------+
    // Inicia processo de pedidos eCommerce |
    //--------------------------------------+
    dbSelectArea(_cAlias)
    (_cAlias)->( dbGoTop() )

    While (_cAlias)->( !Eof() )
        //--------------------+
        // Posiciona registro |
        //--------------------+
        WSA->( dbGoTo((_cAlias)->RECNOWSA) )
            
        //-----------------------------+
        // Pagamento pendente/aprovado |
        //-----------------------------+
        If WSA->WSA_CODSTA $ "001/002" .And. Empty(WSA->WSA_NUMSL1)
            LogExec("==> INICIO ORCAMENTO ECOMMERCE " + WSA->WSA_NUM + "DATA/HORA: " + dToc( Date() ) + " AS " + Time() )
                Begin Transaction 
                    EcLoj012Orc()
                End Transaction    
            LogExec("==> FIM ORCAMENTO ECOMMERCE " + WSA->WSA_NUM + "DATA/HORA: " + dToc( Date() ) + " AS " + Time() )
        //----------------------------------------+    
        // Libera pedidos com bloqueio de estoque |
        //----------------------------------------+
        ElseIf WSA->WSA_CODSTA $ "002/004" .And. !Empty(WSA->WSA_NUMSC5)
            LogExec("==> INICIO LIBERACAO ORCAMENTO ECOMMERCE " + WSA->WSA_NUM + "DATA/HORA: " + dToc( Date() ) + " AS " + Time() )
                Begin Transaction 
                    //------------------------+
                    // Libera pedido de Venda | 
                    //------------------------+
                    If EcLoj012Lib(WSA->WSA_NUMSC5)
                        U_GrvStaEc(WSA->WSA_NUMECO,"011")
                    Else
                        U_GrvStaEc(WSA->WSA_NUMECO,"004")
                    EndIf
                End Transaction   
            LogExec("==> FIM LIBERACAO ORCAMENTO ECOMMERCE " + WSA->WSA_NUM + "DATA/HORA: " + dToc( Date() ) + " AS " + Time() )
        //-----------+
        // Cancelado |
        //-----------+
        ElseIf WSA->WSA_CODSTA $ "008"
            LogExec("==> INICIO CANCELAMENTO ORCAMENTO ECOMMERCE " + WSA->WSA_NUM + "DATA/HORA: " + dToc( Date() ) + " AS " + Time() )
                //EcLoj012Can()
            LogExec("==> FIM CANCELAMENTO ORCAMENTO ECOMMERCE " + WSA->WSA_NUM + "DATA/HORA: " + dToc( Date() ) + " AS " + Time() )
        EndIf
        (_cAlias)->( dbSkip() )
    EndDo

EndIf

LogExec("FINALIZA PROCESSAMENTO DE PEDIDO ECOMMERCE - DATA/HORA: "+DTOC(DATE())+" AS "+TIME())
LogExec(Replicate("-",80))
ConOut("")


RestArea(_aArea)
Return Nil

/**************************************************************************/
/*/{Protheus.doc} EcLoj012Orc
    @description Realiza a grava��o / atualiza��o do pedido e-Commerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/05/2019
    @version version
/*/
/**************************************************************************/
Static Function EcLoj012Orc()
Local _aArea        := GetArea()

Local _aCabec       := {}
Local _aItem        := {}
Local _aItems       := {}
Local _aPgtos       := {}
Local _aParcela     := {}

Local _cSerCPF      := GetNewPar("EC_SERWEB","ECO") 
Local _cPDVWeb      := GetNewPar("EC_PDVWEB","0001")
Local _cOperador    := GetNewPar("EC_PDVOPE","C01")    
Local _cDocPed      := ""
Local _cReserva     := ""
Local _cNumLJ       := ""
Local _cTipo        := "LJ"

Local _nParc        := 0
Local _nPNumCart    := 0
Local _nPAutoriz    := 0
Local _nPAdmin      := 0
Local _nPDtaTef     := 0
Local _nPDocTef     := 0
Local _nPNsuTef     := 0
Local _nValDesc     := 0

Private nTTipo      := TamSx3("C0_TIPO")[1] 
Private nTNumCl     := TamSx3("L1_XNUMECL")[1]  

Private lMsErroAuto := .F.
Private lAutomatoX  := .T.
                    
//----------------+
// Valida cliente |
//----------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
If !SA1->( dbSeek(xFilial("SA1") + WSA->WSA_CLIENT + WSA->WSA_LOJA) )
    LogExec("CLIENTE " + WSA->WSA_CLIENT + "/" + WSA->WSA_LOJA  + " N�O LOCALIZADO")
    RestArea(_aArea)
    Return Nil
Endif

//----------------------------------+
// Valida se cliente est� bloqueado |
//----------------------------------+
If SA1->A1_MSBLQL == "1"
    LogExec("CLIENTE " + RTrim(SA1->A1_NOME)  + " BLOQUEADO PARA USO.")
    RestArea(_aArea)
    Return Nil
EndIf

//-----------------------------------+
// Valida itens do pedido e-Commerce |
//-----------------------------------+
dbSelectArea("WSB")
WSB->( dbSetOrder(1) )
If !WSB->( dbSeek(xFilial("WSB") + WSA->WSA_NUM) )
    LogExec("ITENS DO PEDIDO ECOMMERCE " + WSA->WSA_NUMECO + " NAO LOCALIZADO.")
    RestArea(_aArea)
    Return Nil
EndIf

//----------------------+
// Valida numero docped |
//----------------------+
EcLoj012D(_cSerCPF,@_cDocPed)

//----------------------------------+
// Numero do Or�amento no Siga Loja |
//----------------------------------+
_cNumLJ := GetSxENum("SL1","L1_NUM")

dbSelectArea("SL1")
SL1->( dbSetOrder(1) )
While SL1->( dbSeek(xFilial("SL1") + _cNumLJ) )
    ConfirmSx8()
    _cNumLJ := GetSxeNum("SL1","L1_NUM","",1)
EndDo

//--------------------------------+
// Posiciona tabela de pre�o loja |
//--------------------------------+
dbSelectArea("SB0")
SB0->( dbSetOrder(1) )


While WSB->( !Eof() .And. xFilial("WSB") + WSA->WSA_NUM == WSB->WSB_FILIAL + WSB->WSB_NUM )
    
    //-----------------------------+
    // Valida se tem pre�o na loja |
    //-----------------------------+
    If WSB->WSB_VRUNIT > 0.01
        If !SB0->( dbSeek(xFilial("SB0") + WSB->WSB_PRODUT) )
            RecLock("SB0",.T.)
                SB0->B0_FILIAL  := xFilial("SB0")
                SB0->B0_COD     := WSB->WSB_PRODUT
                SB0->B0_PRV1	:= WSB->WSB_VRUNIT
            SB0->( MsUnLock() )
        Else
            RecLock("SB0",.F.)
                SB0->B0_PRV1	:= WSB->WSB_VRUNIT
            SB0->( MsUnLock() )
        EndIf
    EndIf

    //------------------+
    // Cria array itens | 
    //------------------+
    _aItem      := {}
    _nValDesc   := 0 //Max((WSB->WSB_PRCTAB -  WSB->WSB_VRUNIT  ) * WSB->WSB_QUANT ,0)
    aAdd( _aItem, {"LR_PRODUTO"	, WSB->WSB_PRODUT										, Nil })
	aAdd( _aItem, {"LR_ITEM"	, WSB->WSB_ITEM  									    , Nil })
	aAdd( _aItem, {"LR_DESCRI"	, WSB->WSB_DESCRI										, Nil })
	aAdd( _aItem, {"LR_QUANT"	, WSB->WSB_QUANT 									    , Nil })
	aAdd( _aItem, {"LR_VRUNIT"	, WSB->WSB_VRUNIT										, Nil })
	aAdd( _aItem, {"LR_VLRITEM"	, WSB->WSB_VLRITE										, Nil })
	aAdd( _aItem, {"LR_UM"		, WSB->WSB_UM    										, Nil })
	//aAdd( _aItem, {"LR_DESC"	, WSB->WSB_DESC 	    							    , Nil })
    aAdd( _aItem, {"LR_DESC"	, 0                 								    , Nil })
	aAdd( _aItem, {"LR_VALDESC"	, _nValDesc         									, Nil })
    aAdd( _aItem, {"LR_TES"	    , WSB->WSB_TES	    									, Nil })
	aAdd( _aItem, {"LR_SERIE"	, _cSerCPF			    								, Nil })
	aAdd( _aItem, {"LR_PDV"		, _cPDVWeb												, Nil })
	aAdd( _aItem, {"LR_TABELA"	, WSB->WSB_TABELA					   					, Nil })
	aAdd( _aItem, {"LR_EMISSAO"	, WSB->WSB_EMISSA										, Nil })
	//aAdd( _aItem, {"LR_PRCTAB"	, WSB->WSB_PRCTAB										, Nil })
    aAdd( _aItem, {"LR_PRCTAB"	, WSB->WSB_VRUNIT										, Nil })
	aAdd( _aItem, {"LR_VEND"	, WSA->WSA_VEND                 					    , Nil })
	aAdd( _aItem, {"LR_FDTENTR"	, WSB->WSB_FDTENT										, Nil })
	aAdd( _aItem, {"LR_DOCPED"	, _cDocPed												, Nil })
	aAdd( _aItem, {"LR_SERPED"	, _cSerCPF							    				, Nil })
	aAdd( _aItem, {"LR_VALFRE"  , 0						                    		    , Nil })
	//aAdd( _aItem, {"LR_DESCPRO" , 0 						                    		, Nil })
	aAdd( _aItem, {"LR_LOCAL"   , WSB->WSB_LOCAL       			    				    , Nil })
    aAdd( _aItem, {"LR_ENTREGA" , "3"                  			    				    , Nil })

    //---------------------------+
    // Valida reserva do produto | 
    //---------------------------+ 
    //EcLoj012Res(WSA->WSA_NUMECO,WSA->WSA_NUMECL,WSB->WSB_PRODUT,WSB->WSB_QUANT)
    
    
    aAdd(_aItems,_aItem)

    WSB->( dbSkip() )
EndDo

//------------+
// Pagamentos | 
//------------+
dbSelectArea("WSC")
WSC->( dbSetOrder(1) )
If !WSC->( dbSeeK(xFilial("WSC") + WSA->WSA_NUM) )
    LogExec("PAGAMENTOS DO PEDIDO ECOMMERCE " + WSA->WSA_NUMECO + " NAO LOCALIZADO.")
    RestArea(_aArea)
    Return Nil
Endif

While WSC->( !Eof() .And. xFilial("WSC") + WSA->WSA_NUM == WSC->WSC_FILIAL + WSC->WSC_NUM)

    _aPgtos := {}

    aAdd(_aPgtos, {"L4_DATA"		, WSC->WSC_DATA  			, Nil })
	aAdd(_aPgtos, {"L4_VALOR"		, WSC->WSC_VALOR 			, Nil })
	aAdd(_aPgtos, {"L4_FORMA"		, WSC->WSC_FORMA 			, Nil })
	aAdd(_aPgtos, {"L4_ADMINIS"	    , RTrim(WSC->WSC_ADMINI)	, Nil })
	aAdd(_aPgtos, {"L4_NUMCART"	    , WSC->WSC_NUMCAR			, Nil })
	aAdd(_aPgtos, {"L4_DATATEF"	    , WSC->WSC_DATATE   	    , Nil })
	aAdd(_aPgtos, {"L4_HORATEF"	    , WSC->WSC_HORATE   		, Nil })
	aAdd(_aPgtos, {"L4_DOCTEF"	    , WSC->WSC_DOCTEF			, Nil })
	aAdd(_aPgtos, {"L4_NSUTEF"	    , WSC->WSC_NSUTEF			, Nil })
	aAdd(_aPgtos, {"L4_AUTORIZ"	    , WSC->WSC_AUTORI			, Nil })
	aAdd(_aPgtos, {"L4_INSTITU"	    , WSC->WSC_INSTIT			, Nil })
	aAdd(_aPgtos, {"L4_MOEDA"		, 1						    , Nil })
	aAdd(_aPgtos, {"L4_FORMPG"	    , WSC->WSC_FORMPG			, Nil })
	aAdd(_aPgtos, {"L4_VENDTEF"	    , WSC->WSC_VENDTE		    , Nil })
	aAdd(_aPgtos, {"L4_FORMAID"	    , "1"					    , Nil })
    aAdd(_aPgtos, {"L4_XTID"	    , WSC->WSC_TID  			, Nil })

    aAdd(_aParcela,aClone(_aPgtos))

    WSC->( dbSkip() )
EndDo

//-----------+
// Cabe�alho |
//-----------+
aAdd( _aCabec,	{"LQ_NUM"       , _cNumLJ                                       , Nil })
aAdd( _aCabec,	{"LQ_VEND"		, WSA->WSA_VEND				                    , Nil })
aAdd( _aCabec,	{"LQ_CLIENTE"	, SA1->A1_COD									, Nil })
aAdd( _aCabec,	{"LQ_LOJA"		, SA1->A1_LOJA									, Nil })
aAdd( _aCabec,	{"LQ_TIPOCLI"	, SA1->A1_TIPO									, Nil })
aAdd( _aCabec,	{"LQ_VLRTOT"	, WSA->WSA_VALMER								, Nil })
//aAdd( _aCabec,	{"LQ_DESCONT"	, WSA->WSA_DESCON								, Nil })
aAdd( _aCabec,	{"LQ_DESCONT"	, 0             								, Nil })
aAdd( _aCabec,	{"LQ_VLRLIQ"	, WSA->WSA_VALMER								, Nil })
aAdd( _aCabec,	{"LQ_DTLIM"		, WSA->WSA_DTLIM 		    					, Nil })
aAdd( _aCabec,	{"LQ_PDV"		, _cPDVWeb										, Nil })
aAdd( _aCabec,	{"LQ_VALBRUT"	, WSA->WSA_VALMER								, Nil })
aAdd( _aCabec,	{"LQ_VALMERC"	, WSA->WSA_VALMER 								, Nil })
aAdd( _aCabec,	{"LQ_TIPO"		, "P"											, Nil })
aAdd( _aCabec,	{"LQ_DESCNF"	, 0												, Nil })
aAdd( _aCabec,	{"LQ_OPERADO"	, _cOperador                       				, Nil })
aAdd( _aCabec,	{"LQ_FORMA"		, WSA->WSA_FORMA 								, Nil })
aAdd( _aCabec,	{"LQ_FORMPG"	, WSA->WSA_FORMPG								, Nil })
aAdd( _aCabec,	{"LQ_EMISSAO"	, WSA->WSA_EMISSA 								, Nil })
aAdd( _aCabec,	{"LQ_IMPRIME"	, "1N"											, Nil })
aAdd( _aCabec,	{"LQ_DATATEF"	, WSA->WSA_DATATE								, Nil })
aAdd( _aCabec,	{"LQ_HORA"		, WSA->WSA_HORA  	    						, Nil })
aAdd( _aCabec,	{"LQ_OPERACA"	, ""											, Nil })
aAdd( _aCabec,	{"LQ_SITUA"		, "AG"              							, Nil })
aAdd( _aCabec,	{"LQ_MOEDA"		, 1												, Nil })
aAdd( _aCabec,	{"LQ_ENDCOB"	, SA1->A1_ENDCOB								, Nil })
aAdd( _aCabec,	{"LQ_ENDENT"	, WSA->WSA_ENDENT								, Nil })
aAdd( _aCabec,	{"LQ_TPFRET"	, IIF(WSA->WSA_FRETE > 0 ,"2","0")  			, Nil })
aAdd( _aCabec,	{"LQ_BAIRROC"	, SA1->A1_BAIRROC								, Nil })
aAdd( _aCabec,	{"LQ_CEPC"		, SA1->A1_CEPC									, Nil })
aAdd( _aCabec,	{"LQ_MUNC"		, SA1->A1_MUNC									, Nil })
aAdd( _aCabec,	{"LQ_ESTC"		, SA1->A1_ESTC									, Nil })
aAdd( _aCabec,	{"LQ_BAIRROE"	, WSA->WSA_BAIRRE								, Nil })
aAdd( _aCabec,	{"LQ_CEPE"		, WSA->WSA_CEPE  								, Nil })
aAdd( _aCabec,	{"LQ_MUNE"		, WSA->WSA_MUNE  								, Nil })
aAdd( _aCabec,	{"LQ_ESTE"		, WSA->WSA_ESTE  								, Nil })
aAdd( _aCabec,	{"LQ_FRETE"		, WSA->WSA_FRETE    							, Nil })
aAdd( _aCabec,	{"LQ_DESPESA"   , WSA->WSA_DESPES    							, Nil })
aAdd( _aCabec,	{"LQ_TRANSP"	, WSA->WSA_TRANSP								, Nil })
aAdd( _aCabec,	{"LQ_DOCPED"	, ""    										, Nil })
aAdd( _aCabec,	{"LQ_SERPED"	, _cSerCPF				                        , Nil })
aAdd( _aCabec,	{"LQ_CGCCLI"	, SA1->A1_CGC								    , Nil })
aAdd( _aCabec,	{"LQ_RECISS"    ," "								            , Nil })
aAdd( _aCabec,	{"LQ_TIPODES"   ,"0"								            , Nil })
aAdd( _aCabec,	{"LQ_XNUMECO"	, WSA->WSA_NUMECO								, Nil })
aAdd( _aCabec,	{"LQ_XNUMECL"	, WSA->WSA_NUMECL								, Nil })
aAdd( _aCabec,	{"LQ_XCELULA"	, WSA->WSA_CELULA								, Nil })
aAdd( _aCabec,	{"LQ_XCODSTA"	, WSA->WSA_CODSTA								, Nil })
aAdd( _aCabec,	{"LQ_XCOMPLE"	, WSA->WSA_COMPLE								, Nil })
aAdd( _aCabec,	{"LQ_XDDD01"	, WSA->WSA_DDD01 								, Nil })
aAdd( _aCabec,	{"LQ_XDDDCEL"	, WSA->WSA_DDDCEL								, Nil })
aAdd( _aCabec,	{"LQ_XDESTAT"	, WSA->WSA_DESTAT								, Nil })
aAdd( _aCabec,	{"LQ_XENDNUM"	, WSA->WSA_ENDNUM								, Nil })
aAdd( _aCabec,	{"LQ_XIDENDE"	, WSA->WSA_IDENDE								, Nil })
aAdd( _aCabec,	{"LQ_XNOMDES"	, WSA->WSA_NOMDES								, Nil })
aAdd( _aCabec,	{"LQ_XREFEN"	, WSA->WSA_REFEN 								, Nil })
aAdd( _aCabec,	{"LQ_XOBSECO"	, WSA->WSA_OBSECO								, Nil })
aAdd( _aCabec,	{"LQ_XTEL01"	, WSA->WSA_TEL01 								, Nil })
aAdd( _aCabec,	{"LQ_XTRACKI"	, WSA->WSA_TRACKI								, Nil })
aAdd( _aCabec,	{"LQ_XVLBXPV"	, WSA->WSA_VLBXPV								, Nil })
aAdd( _aCabec,  {"AUTRESERVA"   ,"000001"                                       , Nil })

//------------------------+
// Processa ExecAuto Loja |
//------------------------+
If Len(_aCabec) > 0 .And. Len(_aItems) > 0 .And. Len(_aParcela) > 0
    LogExec("INICIO EXECAUTO DATA " + dToc( Date()) + " HORA " + Time() )
    SetFunName("LOJA701")
	nModulo     := 12
    lMsErroAuto := .F.

    //---------------+
    // Ajusta totais |
    //---------------+
    EcLoj12Tot(_aCabec,_aParcela)

    //-----------------------------+
    // Ajusta Array com dicionario |
    //-----------------------------+    
    /*
    _aCabec     := FWVetByDic( _aCabec, "SLQ" )
    _aItems     := FWVetByDic( _aItems, "SLR", .T. )
    _aParcela   := FWVetByDic( _aParcela, "SL4", .T. )
    */

    MsExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},_aCabec,_aItems,_aParcela)
    
    If lMsErroAuto
        If _lJob
            cSL1Log	:= "SL1" + WSA->WSA_NUM + DToS(dDataBase) + Left(Time(),2) + SubStr(Time(),4,2) + Right(Time(),2)+".LOG"
            //----------------+
            // Cria diretorio |
            //----------------+ 
            MakeDir("/erros/")
            MostraErro("/erros/",cSL1Log)
            
        Else
            MostraErro()
        EndIf  

        //----------------------+
        // Restaura a numera��o |
        //----------------------+  
        RollBackSX8()
    Else

        //----------------------+
        // Confirma a numera��o |
        //----------------------+
        ConfirmSx8()

        //---------------------------+
        // Valida Reserva do Produto |
        //---------------------------+
        dbSelectArea("SC0")
        SC0->( dbSetOrder(4) )
        If SC0->( dbSeek(xFilial("SC0") + PadR(_cTipo,nTTipo) + PadR(WSA->WSA_NUMECL,nTNumCl)) )
            _cReserva := "S"
        EndIf

        //----------------------------------+
        // Atualiza dados Or�amento inicial |
        //----------------------------------+
        RecLock("WSA",.F.)
            WSA->WSA_NUMSL1 := SL1->L1_NUM
        WSA->( MsUnLock() )

        //--------------------+
        // Atualiza dados SL1 |
        //--------------------+
        dbSelectArea("SL1")
        SL1->( dbSetOrder(1) )
        SL1->( dbSeek(xFilial("SL1") + SL1->L1_NUM) )
        RecLock("SL1",.F.)
            SL1->L1_SITUA   := "RX"
            SL1->L1_PDV		:= _cPDVWeb
            SL1->L1_DOCPED	:= _cDocPed
            SL1->L1_SERPED  := _cSerCPF
            SL1->L1_STATUS	:= "F"
            SL1->L1_TIPO    := "P"
            SL1->L1_INDPRES := "1"
            //If !Empty(_cReserva)
            SL1->L1_RESERVA := _cReserva
            //EndIf

        SL1->( MsUnLock() )
        
        //----------------+
        // Atualiza Itens |
        //----------------+
        dbSelectArea("SL2")
        SL2->( dbSetOrder(1) )
        If SL2->( dbSeek(xFilial("SL2") + SL1->L1_NUM) )
            While SL2->( !Eof() .And. xFilial("SL2") + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM )

                RecLock("SL2",.F.)
                    
                    If SL2->L2_ITEM == "01" .And. WSA->WSA_FRETE > 0
                        SL2->L2_VALFRE  := WSA->WSA_FRETE                        
                    EndIf

                    SL2->L2_DOCPED	:= _cDocPed
                    SL2->L2_SERPED  := _cSerCPF
                    SL2->L2_ENTREGA := "3"
                    If !Empty(_cReserva)
                        If SC0->( dbSeek(xFilial("SC0") + PadR(_cTipo,nTTipo) + PadR(WSA->WSA_NUMECL,nTNumCl) + SL2->L2_PRODUTO) )
                            SL2->L2_FILRES  := SC0->C0_FILIAL
                            SL2->L2_RESERVA := SC0->C0_NUM
                            SL2->L2_ENTREGA := "3"
                        EndIf
                    EndIf

                SL2->( MsUnLock() )

                SL2->( dbSkip() )
            EndDo
        EndIf
        
        //---------------------+
        // Atualiza pagamentos |
        //---------------------+
        dbSelectArea("SL4")
        SL4->( dbSetOrder(1) )
        If SL4->( dbSeek(xFilial("SL4") + SL1->L1_NUM) )
            While SL4->( !Eof() .And. xFilial("SL4") + SL1->L1_NUM == SL4->L4_FILIAL + SL4->L4_NUM )

                //-------------------------+
                // Calcula Proxima Parcela |
                //-------------------------+
                _nParc++

                //--------------------------------------------------+
                // Posiciona campos para atualiza��o dos pagamentos |
                //--------------------------------------------------+
                _nPNumCart      := aScan(_aParcela[_nParc],{|x| RTrim(x[1]) == RTrim("L4_NUMCART")})
                _nPAutoriz      := aScan(_aParcela[_nParc],{|x| RTrim(x[1]) == RTrim("L4_AUTORIZ")})
                _nPAdmin        := aScan(_aParcela[_nParc],{|x| RTrim(x[1]) == RTrim("L4_ADMINIS")})
                _nPDtaTef       := aScan(_aParcela[_nParc],{|x| RTrim(x[1]) == RTrim("L4_DATATEF")}) 
                _nPDocTef       := aScan(_aParcela[_nParc],{|x| RTrim(x[1]) == RTrim("L4_DOCTEF")})
                _nPNsuTef       := aScan(_aParcela[_nParc],{|x| RTrim(x[1]) == RTrim("L4_NSUTEF")})
                _nPTId          := aScan(_aParcela[_nParc],{|x| RTrim(x[1]) == RTrim("L4_XTID")})

                //----------------------------------------------+
                // Realiza a atualiza��o dos dados de pagamento |
                //----------------------------------------------+
                RecLock("SL4",.F.)
                    SL4->L4_NUMCART := _aParcela[_nParc][_nPNumCart][2]
                    SL4->L4_AUTORIZ := _aParcela[_nParc][_nPAutoriz][2]
                    SL4->L4_ADMINIS := _aParcela[_nParc][_nPAdmin][2]
                    SL4->L4_DATATEF := _aParcela[_nParc][_nPDtaTef][2]
                    SL4->L4_DOCTEF  := _aParcela[_nParc][_nPDocTef][2]
                    SL4->L4_NSUTEF  := _aParcela[_nParc][_nPNsuTef][2]
                    SL4->L4_XTID    := _aParcela[_nParc][_nPTId][2]
                SL4->( MsUnLock() )

                SL4->( dbSkip() )
            EndDo
        EndIf
    EndIf
    
    LogExec("FIM EXECAUTO DATA " + dToc( Date()) + " HORA " + Time() )

EndIf

RestArea(_aArea)
Return Nil

/**************************************************************************/ 
/*/{Protheus.doc} EcLoj12Tot
    @description Ajusta totais do pedido 
    @type  Static Function
    @author Bernard M. Margarido
    @since 22/07/2019
    @version 1.0
/*/
/**************************************************************************/
Static Function EcLoj12Tot(_aCabec,_aParcela)
Local _nPTotal  := aScan(_aCabec,{|x| RTrim(x[1]) == "LQ_VLRTOT"})
Local _nPDesc   := aScan(_aCabec,{|x| RTrim(x[1]) == "LQ_DESCONT"})
Local _nPFrete  := aScan(_aCabec,{|x| RTrim(x[1]) == "LQ_FRETE"})
Local _nPTParc  := 0

Local _nValor   := 0
Local _nDesc    := 0
Local _nFrete   := 0
Local _nTotParc := 0
Local _nTotCab  := 0
Local _nDif     := 0
Local _nX       := 0

//-------------------+
// Valores cabe�alho |
//-------------------+
_nValor := _aCabec[_nPTotal][2]
_nFrete := _aCabec[_nPFrete][2]
_nDesc  := _aCabec[_nPDesc][2]
_nTotCab:=  ( _nValor + _nFrete ) - (_nDesc)

For _nX := 1 To Len(_aParcela)
     _nPTParc := aScan(_aParcela[_nX],{|x| RTrim(x[1]) == "L4_VALOR"})
    _nTotParc += _aParcela[_nX][_nPTParc][2]
Next _nX

_nDif := _nTotCab - _nTotParc

If _nTotCab > _nTotParc
    _aCabec[_nPDesc][2] := _nDesc + _nDif
ElseIf _nTotCab < _nTotParc
    _aCabec[_nPDesc][2] := _nDesc - IIF(_nDif < 0, (_nDif * -1),_nDif)
Endif

Return Nil

/**************************************************************************/
/*/{Protheus.doc} EcLoj012Lib()
    @description Libera pedidos com bloqueio de saldo
    @type  Static Function
    @author Bernard M. Margarido
    @since 02/08/2020
/*/
/**************************************************************************/
Static Function EcLoj012Lib(_cNumPv)
Local _aArea        := GetArea()

Local _aCabec       := {}
Local _aRegSC6      := {}

Local _nVlrLiber    := 0
Local _nValTot      := 0
Local _nQtdLib      := 0

Local _lRet         := .T.
Local _lBloq        := .F.

Private lMsErroAuto := .F.

aAdd(_aCabec, { "C5_FILIAL", xFilial("SC5") , Nil   })
aAdd(_aCabec, { "C5_NUM"   , _cNumPv        , Nil   })

//------------------+
// Seleciona pedido | 
//------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//---------------+
// Seleciona TES | 
//---------------+
dbSelectArea("SF4")
SF4->( dbSetOrder(1) )

//---------------------------+
// Seleciona itens liberados | 
//---------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//--------------------------------------+
// Posiciona itens do pedido e-Commerce |
//--------------------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )
SC6->( dbSeek(xFilial("SC6") + _cNumPv))
While SC6->( !Eof() .And. xFilial("SC6") + _cNumPv == SC6->C6_FILIAL + SC6->C6_NUM )
    //--------------------------+
    // Atualiza Total do pedido | 
    //--------------------------+
    _nValTot += SC6->C6_VALOR

    //---------------+
    // Posiciona TES | 
    //---------------+
	SF4->( MsSeek( xFilial("SF4") + SC6->C6_TES ) )
    
    //------------------+
    // Reserva registro |
    //------------------+
    If SC5->( RecLock("SC5",.F.) )

		_nQtdLib := IIF(SC6->C6_QTDLIB == 0,SC6->C6_QTDVEN,SC6->C6_QTDLIB)
		
		//---------------------------------+
		// Recalcula a Quantidade Liberada |
		//---------------------------------+
		SC6->( RecLock("SC6",.F.) )
		
		//---------------------------+
		// Libera por Item de Pedido |
		//---------------------------+
		Begin Transaction
			SC6->C6_QTDLIB := IIF(SC6->C6_QTDLIB == 0,SC6->C6_QTDVEN,SC6->C6_QTDLIB) 
            /*
            //--------------------------------+    
            // Valida se item j� foi liberado | 
            //--------------------------------+    
			If SC9->( dbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM))

                //----------------------+        
                // Salva valor liberado | 
                //----------------------+    
				_nVlrLiber := SC6->C6_VALOR

                //-------------+
                // Salva Recno | 
                //-------------+
                _aRegSC6    := {}
				aAdd(_aRegSC6, SC6->(RecNo()))

                //------------------+
				// Posiciona pedido |
                //------------------+
				SC5->( dbSeek(xFilial("SC5") + SC6->C6_NUM ) )

                //----------------------------------------------------------------------------+    
				// Caso possuir o chamo a fun��o de valida��o de cabecario do pedido de venda |
                //----------------------------------------------------------------------------+
				MaAvalSC5("SC5",3,.F.,.F.,,,,,,SC9->C9_PEDIDO,_aRegSC6,.T.,.F.,@_nVlrLiber)		
				
                //--------------------------------------------------------------------+
                // A libera��o do credito � for�ada pois o pagamento j� foi realizado |
                //--------------------------------------------------------------------+
				RecLock("SC9",.F.)
				    SC9->C9_BLCRED := "  "
				SC9->( MsUnlock() )			

                If !_lBloq
                    _lBloq  := IIF(!Empty(SC9->C9_BLEST) .Or. SC9->C9_BLEST <> "10", .T., .F.)
                EndIf
			Else*/						
                //------------------------------------------------------------------------------+ 
				// Libera��o do Credito/estoque do pedido de venda mais informa��es ver fatxfun |
                //------------------------------------------------------------------------------+ 
				MaLibDoFat( SC6->(RecNo()),_nQtdLib,.T.,.T.,.F.,.F.,.F.,.F.)	
			//EndIf 											
			
		End Transaction
	EndIf
	
	SC5->( MsUnLock() )
	SC6->( MsUnLock() )

    SC6->( dbSkip() )
EndDo

//--------------------------------------------------------------------------+
// Verifica se existe bloqueio de cr�dito ou estoque, se existir desbloqueia|
//--------------------------------------------------------------------------+
MaLiberOk( { _cNumPv } )
SC5->(dbSeek(xFilial("SC5") + _cNumPv) )
If !lMsErroAuto .And. !_lBloq
	_lRet   := .T.
Else
    LogExec("ERRO AO LIBERAR PEDIDO " + _cNumPv)
	//MostraErro("/erros/" + "SC5_LIB" + _cNumPv )
	_lRet   := .F.
EndIf

RestArea(_aArea)
Return _lRet

/**************************************************************************/
/*/{Protheus.doc} EcLoj012Qry
    @description Consulta pedidos eCommerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/05/2019
    @version version
/*/
/**************************************************************************/
Static Function EcLoj012Qry(_cAlias)
Local _cQuery   := ""
Local _cCodSta  := GetNewPar("EC_STAPROC","001/002/004")
Local _lRet     := .T.

//---------------------------+
// Formata para condi��o SQL |
//---------------------------+
_cCodSta:= FormatIn(_cCodSta,"/") 

_cQuery := " SELECT " + CRLF
_cQuery += "    WSA.R_E_C_N_O_ RECNOWSA " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "    " + RetSqlName("WSA") + " WSA " + CRLF 
_cQuery += " WHERE " + CRLF
_cQuery += "    WSA.WSA_FILIAL = '" + xFilial("WSB") + "' AND  " + CRLF
_cQuery += "    WSA.WSA_CODSTA IN " + _cCodSta + " AND " + CRLF
_cQuery += "    ( WSA.WSA_NUMSL1 = '' OR WSA.WSA_NUMSL1 <> '' ) AND " + CRLF 
_cQuery += "    WSA.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->( Eof() )
    _lRet := .F.
EndIf

Return _lRet

/*********************************************************************************/
/*/{Protheus.doc} EcLoj012Res
    @description Valida se existe reserva para o pedido eCommerce
    @type  Static Function
    @author Bernard M. Margarido
    @since 13/06/2019
    @version version
/*/
/*********************************************************************************/
Static Function EcLoj012Res(_cOrderId,_cOrderCli,_cCodProd,_nQtdItem)
Local _aArea        := GetArea()
Local aOperacao		:= {}
Local aLote			:= {}

Local _cCodRes		:= ""
Local _cClient		:= "ECOMM"
Local _cTipo        := "LJ" 
Local _cLocal		:= GetNewPar("EC_ARMVEND")

Local _nTPedCli     := TamSx3("WSA_NUMECL")[1]
Local _nTProd       := TamSx3("B1_COD")[1]
Local _nSaldoSb2    := 0

Local _dDtReser	    := GetNewPar("EC_DTVLDRE","01/01/2049")

Local _lRet         := .T.
Local _lGerou		:= .F.

//-----------------------+
// Identificador da LOJA | 
//-----------------------+
M->AUTRESERVA  := "000001"

//--------------------------+
// Valida se existe reserva |
//--------------------------+
dbSelectArea("SC0")
SC0->( dbSetOrder(3) )
If SC0->( dbSeek(xFilial("SC0") + _cTipo + PadR(_cOrderCli,_nTPedCli) + _cCodProd) )
    RestArea(_aArea)
    Return .T.
EndIf

//----------------------------------------+	
// Valida se produto tem armzem de venda  |
//----------------------------------------+
_aAreaSB2 := SB2->( GetArea() )
    dbSelectArea("SB2")
    SB2->( dbSetOrder(1) )
    If !SB2->( dbSeek(xFilial("SB2") + _cCodProd + _cLocal) )
        CriaSb2(_cCodProd,_cLocal)
    EndIf
    //-------------------------+
    // Valida saldo do produto | 
    //-------------------------+
    _nSaldoSb2 := SaldoSB2()

    If _nSaldoSb2 <= 0
        RestArea(_aArea)
        Return .F.
    EndIf
RestArea(_aAreaSB2)


//------------------------------+
// Inicia a grava��o da reserva |
//------------------------------+
aOperacao 	:= {1, _cTipo, _cOrderCli, _cClient, xFilial("SC0"), "Reserva eCommerce:" + _cOrderCli}
aLote   	:= {"" , "" , "", ""}
_cCodRes	:= GetSxeNum("SC0","C0_NUM")

_lGerou		:= a430Reserv(	aOperacao						,;			// Array contendo dados da reserva
                            _cCodRes						,;			// Numero da Reserva
                            PadR(_cCodProd, _nTProd)		,;			// Produto 
                            _cLocal							,;			// Armazem  
                            _nQtdItem						,;			// Saldo
                            aLote,,							)			// Lote 
If _lGerou
    //--------------------+
    // Confirma numera��o |
    //--------------------+
    ConfirmSx8()
    
    //-----------------------+
    // Posiciona Pre Empenho |
    //-----------------------+
    SC0->( dbSetOrder(4) )
    SC0->( dbSeek(xFilial("SC0") + _cTipo + PadR(_cOrderCli,_nTPedCli) + _cCodProd))
        
    //---------------------------------------------+
    // Validas e Reserva foi realizada com sucesso |
    //---------------------------------------------+
    If ( SC0->C0_PRODUTO == Padr(RTrim(_cCodProd),_nTProd) ) .And. ( _cOrderCli $ SC0->C0_OBS ) .And. ( SC0->C0_NUM == _cCodRes )
        RecLock("SC0",.F.)
            SC0->C0_QUANT  -= _nQtdItem
            SC0->C0_QTDPED += _nQtdItem
            SC0->C0_VALIDA := IIF(ValType(_dDtReser) == "C",cTod(_dDtReser),_dDtReser)
        SC0->(MsUnLock())

        LogExec("RESERVA " + _cCodRes + " EFETUADA COM SUCESSO.")

    Else
        
        //-----------------------------------+
        // Desarma Transacao em caso de erro |
        //-----------------------------------+
        RollBackSx8()
        LogExec("ERRO AO GERAR RESERVA " + _cCodRes + " .")	
    EndIf
Else
    //-----------------------------------+
    // Desarma Transacao em caso de erro |
    //-----------------------------------+
    RollBackSx8()
    LogExec("ERRO AO GERAR RESERVA" + _cCodRes + " .")	
       
EndIf

RestArea(_aArea)
Return _lRet

/*********************************************************************************/
/*/{Protheus.doc} EcLoj012D
    @description Valida numero do DocPed
    @type  Static Function
    @author Bernard M Margarido
    @since 16/10/2023
    @version version
/*/
/*********************************************************************************/
Static Function EcLoj012D(_cSerCPF,_cDocPed)
Local _aArea := GetArea() 

//--------------------+
// Gera Numero DocPed |
//--------------------+
_cDocPed := GetSxeNum("SE1","E1_NUM")

dbSelectArea("SE1")
SE1->( dbSetOrder(1) )
While SE1->( dbSeek(xFilial("SE1") + _cSerCPF + _cDocPed) )
    ConfirmSx8()
    _cDocPed := GetSxeNum("SE1","E1_NUM","",1)
EndDo	

dbSelectArea("SL1")
SL1->( dbSetOrder(11) )
While SL1->( dbSeek(xFilial("SL1") + _cSerCPF + _cDocPed) )
    ConfirmSx8()
    _cDocPed := GetSxeNum("SE1","E1_NUM","",1)
EndDo	

RestArea(_aArea)
Return Nil 

/*********************************************************************************/
/*/{Protheus.doc} LogExec
    @description Grava Log do processo 
    @author SYMM Consultoria
    @since 26/01/2017
    @version undefined
    @type function
/*/
/*********************************************************************************/
Static Function LogExec(cMsg)
	CONOUT(cMsg)
	LjWriteLog(cArqLog,cMsg)
Return .T.
