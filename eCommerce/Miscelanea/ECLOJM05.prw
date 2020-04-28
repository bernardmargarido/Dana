#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/******************************************************************************************/
/*/{Protheus.doc} nomeFunction
    @description JOB - Faturamento automatico nota fiscal e-commerce
    @type  Function
    @author Bernard M. Margarido
    @since 16/09/2019
/*/
/******************************************************************************************/
User Function EcLojM05(_cEmp,_cFil)
Local _aArea        := GetArea()

Private _lJob       := IIF(Isincallstack("U_ECLOJ010"),.F.,.T.) 

Private _oProcess   := Nil

//------------------+
// Mensagem console |
//------------------+
CoNout("<< ECLOJM05 >> - INICIO " + dTos( Date() ) + " - " + Time() )

//-----------------------+
// Abre empresa / filial | 
//-----------------------+
If _lJob
    RpcSetType(3)
	RpcSetEnv(_cEmp, _cFil,,,'FAT')
EndIf

//----------------------------------+
// Faturamento automatico eCommerce |
//----------------------------------+
CoNout("<< EcLojM05A >> - INICIO FATURAMENTO AUTOMATICO " + dTos( Date() ) + " - " + Time() )
    If _lJob
        EcLojM05A()
    Else
        _oProcess:= MsNewProcess():New( {|| EcLojM05A()},"Aguarde...","Faturando pedidos e-Commerce" )
		_oProcess:Activate()
    EndIf
CoNout("<< EcLojM05A >> - FIM FATURAMENTO AUTOMATICO " + dTos( Date() ) + " - " + Time() )


//------------------------+
// Fecha empresa / filial |
//------------------------+
If _lJob
    RpcClearEnv()
EndIf    

CoNout("<< ECLOJM05 >> - FIM " + dTos( Date() ) + " - " + Time() )

RestArea(_aArea)
Return Nil

/******************************************************************************************/
/*/{Protheus.doc} nomeStaticFunction
    @description Valida pedidos e-Commerce a serem faturados 
    @type  Static Function
    @author Bernard M. Margarido
    @since 16/09/2019
/*/
/******************************************************************************************/
Static Function EcLojM05A()
Local _aArea        := GetArea()
Local aPvlNfs	    := {}
Local _aNotas	    := {}
Local _aNfGerada    := {}

Local _cAlias       := GetNextAlias()
Local _cNota        := ""
Local _cSerie       := GetNewPar("EC_SERIENF")

Local _nX           := 0
Local _nToReg       := 0
Local _nTDoc        := TamSx3("F2_DOC")[1]
Local _nTSerie      := TamSx3("F2_SERIE")[1]
Local _nItemNf	    := a460NumIt(_cSerie)
Local _nCalAcrs   	:= 1	
Local _nArredPrcLis	:= 1

Local _lBlqEst      := .F.
Local _lBlqCred     := .F.
Local _lRet			:= .F.
Local _lMostraCtb	:= .F.
Local _lAglutCtb	:= .F.
Local _lCtbOnLine	:= .F.
Local _lCtbCusto	:= .F.
Local _lReajuste	:= .F.
Local _lECF			:= .F.

Local _dDataMoe		:= Nil
//----------------------------------------------+
// Consulta pedidos e-Commerce para faturamento |
//----------------------------------------------+
If !EcLojM05Qry(_cAlias,@_nToReg)
    CoNout("<< ECLOJM05 >> - NAO EXISTEM NOVOS PEDIDOS A SEREM FATURADOS.")
    RestArea(_aArea)
    Return .F.
EndIf

//-----------------------------+
// Pedido de Venda - Cabe�alho |
//-----------------------------+
dbSelectArea("SC5")
SC5->( dbSetOrder(1) )

//-------------------------+
// Pedido de Venda - Itens |
//-------------------------+
dbSelectArea("SC6")
SC6->( dbSetOrder(1) )

//----------------------------------+
// Pedido de Venda - Itens Liberado |
//----------------------------------+
dbSelectArea("SC9")
SC9->( dbSetOrder(1) )

//-----------------------+
// Condi��o de Pagamento |
//-----------------------+
dbSelectArea("SE4")
SE4->( dbSetOrder(1) )

//----------+
// Produtos |
//----------+
dbSelectArea("SB1")
SB1->( dbSetOrder(1) )

//---------+
// Estoque |
//---------+
dbSelectArea("SB2")
SB2->( dbSetOrder(1) )

//--------------------------+
// Tipos de Entrada e Saida |
//--------------------------+
dbSelectArea("SF4")
SF4->( dbSetOrder(1) )

//-----------------------------------+
// Processa notas pedidos e-Commerce |
//-----------------------------------+
If !_lJob
    _oProcess:SetRegua1(_nToReg)
EndIf

While (_cAlias)->( !Eof() )

    //------------------+
    // Posiciona pedido |
    //------------------+
    SC5->( dbGoTo((_cAlias)->RECNOSC5) )

    _cNota      := ""
    aPvlNfs     := {}    
    _aNotas     := {}
    _aNfGerada  := {}

    CoNout("<< ECLOJM05 >> - INICIA FATURAMENTO PEDIDO " + SC5->C5_NUM + " ID ECOMMERCE " + SC5->C5_XNUMECO + " DATA " + dToc(Date())  + " HORA " + Time() + " .")

    If !_lJob
        _oProcess:IncRegua1("PEDIDO ECOMMERCE " + RTrim(SC5->C5_XNUMECO) )
    EndIf 

    //---------------------------+
    // Posiciona Itens liberados |
    //---------------------------+
    SC9->( dbSeek(xFilial("SC9") + SC5->C5_NUM) )
	While SC9->( !Eof() .And. xFilial("SC9") + SC5->C5_NUM == SC9->C9_FILIAL + SC9->C9_PEDIDO )

        //----------------------------------------+
		// Valida se est� com bloqueio de estoque | 
		//----------------------------------------+
		If ( SC9->C9_BLEST <> "10" ) .AND. !Empty(SC9->C9_BLEST)
            CoNout("<< ECLOJM05 >> - PEDIDO " + SC5->C5_NUM + " ID ECOMMERCE " + SC5->C5_XNUMECO + " PRODUTO " + SC9->C9_PRODUTO + " SEM SALDO EM ESTOQUE.")
			_lBlqEst := .T.
			Exit
		EndIf
					
		//----------------------------------------+
		// Valida se est� com bloqueio de credito | 
		//----------------------------------------+			
		If (SC9->C9_BLCRED <> "10") .AND. !Empty(SC9->C9_BLCRED)
            CoNout("<< ECLOJM05 >> - PEDIDO " + SC5->C5_NUM + " ID ECOMMERCE " + SC5->C5_XNUMECO + " PRODUTO " + SC9->C9_PRODUTO + " SEM CREDITO.")
			_lBlqCred := .T.
			Exit
		EndIf

        //--------------------------+
		// Posiciona Item do Pedido |   
		//--------------------------+
		SC6->( dbSetOrder(1) )
		SC6->( dbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO) )

        //---------------------------------+
		// Posiciona Condi��o de Pagamento |   
		//---------------------------------+
		SE4->( dbSetOrder(1) )
		SE4->( dbSeek(xFilial("SE4") + SC5->C5_CONDPAG) )

		//-------------------+
		// Posiciona Produto |   
		//-------------------+
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek(xFilial("SB1") + SC9->C9_PRODUTO) )

		//------------------------------+
		// Posiciona Estoque de Produto |   
		//------------------------------+
		SB2->( dbSetOrder(1) )
		SB2->( dbSeek(xFilial("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL) )

		//---------------+
		// Posiciona Tes |   
		//---------------+
		SF4->( dbSetOrder(1) )
		SF4->( dbSeek(xFilial("SF4") + SC6->C6_TES) )

        //----------------------------------+
        // Adiciona itens a serem faturados |
        //----------------------------------+
		aAdd(aPvlNfs,{ 	SC9->C9_PEDIDO,;
						SC9->C9_ITEM,;
						SC9->C9_SEQUEN,;
						SC9->C9_QTDLIB,;
						SC9->C9_PRCVEN,;
						SC9->C9_PRODUTO,;
						.F.,;
						SC9->(RecNo()),;
						SC5->(RecNo()),;
						SC6->(RecNo()),;
						SE4->(RecNo()),;
						SB1->(RecNo()),;
						SB2->(RecNo()),;
						SF4->(RecNo())})


        SC9->( dbSkip() )
    EndDo

    //----------------------------------------------+
	// Exibe parametros para gera��o da Nota Fiscal |
	//----------------------------------------------+
	If !_lBlqCred .And. !_lBlqEst .And. Len(aPvlNfs) > 0

        //---------------------------+
        // Cria array de notas vazio |
        //---------------------------+
		aAdd(_aNotas,{})

        //----------------------------------------------------+
        // Separa notas caso ultrapasse maximo total de itens |  
        //----------------------------------------------------+
		For _nX := 1 To Len(aPvlNfs)
			If Len(_aNotas[Len(_aNotas)]) >= _nItemNf
				aAdd(_aNotas,{})
			EndIf
			aAdd(_aNotas[Len(_aNotas)], aClone(aPvlNfs[_nX] ))
		Next _nX
		
        //-----------------------+
        // Gera notas e-Commerce |
        //-----------------------+
		For _nX := 1 To Len(_aNotas)	
            _cNota := MaPvlNfs(_aNotas[_nX],_cSerie,_lMostraCtb,_lAglutCtb,_lCtbOnLine,_lCtbCusto,_lReajuste,_nCalAcrs,_nArredPrcLis,.F.,_lECF,,,,,,_dDataMoe)
            _cSerie:= PadR(_cSerie,_nTSerie)
			aAdd(_aNfGerada,PadR(_cNota,_nTDoc))
		Next _nX

        //----------------------+
        // Valida notas geradas |
        //----------------------+
        dbSelectArea("SF2")
        SF2->( dbSetOrder(1) )

        For _nX := 1 To Len(_aNfGerada)	
            If Empty(_aNfGerada[_nX])
                CoNout("<< ECLOJM05 >> - ERRO AO GERAR A NOTA PEDIDO " + SC5->C5_NUM + " ID ECOMMERCE " + SC5->C5_XNUMECO + " NOTA NAO GERADA.")            
            Else
			    If !SF2->( dbSeek(xFilial("SF2") + _aNfGerada[_nX] + PadR(_cSerie,_nTSerie)) )
                    CoNout("<< ECLOJM05 >> - NOTA " + _aNfGerada[_nX] + " SERIE " + _cSerie + " NAO LOCALIZADA PARA O PEDIDO " + SC5->C5_NUM + " ID ECOMMERCE " + SC5->C5_XNUMECO + " .")
                EndIf
            EndIf
        Next _nX
	EndIf

    CoNout("<< ECLOJM05 >> - FINALIZA FATURAMENTO PEDIDO " + SC5->C5_NUM + " ID ECOMMERCE " + SC5->C5_XNUMECO + " DATA " + dToc(Date())  + " HORA " + Time() + " .")
    (_cAlias)->( dbSkip() )
EndDo

//----------------------------+
// Encerra arquivo temporario |
//----------------------------+
(_cAlias)->( dbCloseArea() )
RestArea(_aArea)
Return Nil

/******************************************************************************************/
/*/{Protheus.doc} EcLojM05Qry
    @description Consulta pedidos e-commerce aptos a serem faturados 
    @type  Static Function
    @author Bernard M. Margarido
    @since 23/09/2019
/*/
/******************************************************************************************/
Static Function EcLojM05Qry(_cAlias,_nToReg)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	C5.C5_NUM, " + CRLF
_cQuery += "	C5.C5_XNUMECO, " + CRLF
_cQuery += "	C5.R_E_C_N_O_ RECNOSC5 " + CRLF
_cQuery += " FROM " + CRLF 
_cQuery += "	" + RetSqlName("WSA") + " WSA " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("SL1") + " L1 ON L1.L1_FILIAL = WSA.WSA_FILIAL AND L1.L1_FILRES = WSA.WSA_FILIAL AND L1.L1_ORCRES = WSA.WSA_NUMSL1 AND L1.D_E_L_E_T_ = '' " + CRLF  
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " C5 ON C5.C5_FILIAL = WSA.WSA_FILIAL AND C5.C5_NUM = L1.L1_PEDRES AND C5.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC9") + " C9 ON C9.C9_FILIAL = WSA.WSA_FILIAL AND C9.C9_PEDIDO = C5.C5_NUM AND C9.C9_NFISCAL = '' AND C9.C9_BLEST = '' AND C9.C9_BLCRED = '' AND C9.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	WSA.WSA_FILIAL = '" + xFilial("WSA") + "' AND " + CRLF
_cQuery += "	WSA.WSA_DOC = '' AND " + CRLF
_cQuery += "	WSA.WSA_SERIE = '' AND " + CRLF
_cQuery += "	WSA.WSA_ENVLOG = '2' AND " + CRLF
_cQuery += "	WSA.WSA_CODSTA = '011' AND " + CRLF
_cQuery += "	WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += " GROUP BY C5.C5_NUM,C5.C5_XNUMECO,C5.R_E_C_N_O_  "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg

dbSelectArea(_cAlias)
(_cAlias)->( dbGoTop() )

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() ) 
   Return .F.
EndIf

Return .T.