#include "rwmake.ch"  
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±
±³SISTEMA   ³ Protheus 11   ³ MODULO ³ Faturamento ³ PROGRAMA ³ DANA14.PRX   ³±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³FINALIDADE³ RELACAO DE NOTAS FISCAL POR REPRESENTANTE                      ³±
±³          ³                                                                ³±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³AUTOR     ³ Wilson Santos³ DATA ³ Mai/99   ³ OBS ³ Compilar com o RDMAKE   ³±
±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³               R E G I S T R O S   D E   A L T E R A € å E S               ³±
±ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³  DATA  ³   AUTOR  ³               A  L  T  E  R  A  €  Ç  O               ³±
±³03/02/15³Adalberto ³Inclusao do campo DATASAIDA existente no banco de dados³±
±³        ³          ³do sistema Compress de frete. Foi feita uma query para ³±
±³        ³          ³buscar no banco FRETEDANA, tabelas DBRELCARGANFS e     ³±
±³        ³          ³DBRELCARGA.                                            ³±
±³        ³          ³Alterei tambem as perguntas DANA14, inserindo a opcao  ³±
±³        ³          ³F3 para o parametro VENDEDOR.                          ³±
±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DANA14()   

SetPrvt("CALIASANT,CSAVCOR,LI,CBCONT,CBTXT,CANTES")
SetPrvt("WNREL,TAMANHO,CARACTER,M_PAG,TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,CSTRING,NTIPO,NLASTKEY,NCNTIMPR")
SetPrvt("NOMEPROG,CPERG,ARETURN,CTITULO,CSAVSCR1,CSAVCUR1")
SetPrvt("CSAVROW1,CSAVCOL1,CSAVCOR1,ADBF,CDBF,CCHAVE")
SetPrvt("CCABEC1,CCABEC2,CVENDEDOR,CNOMEVEND,NQTDNF,NVLMERC")
SetPrvt("NVLIPI,NVLTOTAL,NGQTDNF,NGVLMERC,NGVLIPI,NGVLTOTAL")
SetPrvt("NQTDNFF,NVLMERCF,NVLIPIF,NVLTOTALF,NGQTDNFF,NGVLMERCF")
SetPrvt("NGVLIPIF,NGVLTOTALF,_XPEDIDO,")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Todas as variaveis PRIVATE.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasAnt	:= Alias()
Li			:= 100
CbCont		:= 0
CbTxt		:= Space( 10 )
cAntes		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis  de controle da tela padrao SIGA relatorios      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel		:= "DANA14"
Tamanho 	:= "G"
Limite  	:= 220
Caracter  	:= 15
m_pag		:= 1
Titulo		:= "RELACAO DE NOTAS FISCAIS - POR REPRESENTANTE"
cDesc1		:= "Emissao da relacao de Notas Fiscais por representante."
cDesc2		:= ""
cDesc3		:= ""
cString 	:= "SF2"
nTipo		:= 0
nLastkey	:= 0
nCntImpr	:= 0
nomeprog	:= "DANA14"
cPerg		:= "DANA14    "
aReturn		:= { "Branco", 1,"Administracao", 1, 2, 1, "",1 }
cTitulo		:= Titulo
nTotVarejo  := 0 
nTotAtacado := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//³ mv_par01 = Da  Data                        D, 8              ³
//³ mv_par02 = Ate Data                        D, 8              ³
//³ mv_par03 = Do  Vendedor                    C, 6              ³
//³ mv_par04 = Ate Vendedor                    C, 6              ³
//³ mv_par05 = Ordem Vend+Cli/Vend+Nota        N, 1              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte( "DANA14    " , .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)
If LastKey() == 27 .or. nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .or. nLastKey == 27
   Return
Endif

Rptstatus({|| Relato14()},Titulo)

Return



Static Function Relato14()  

Local dDtSaidaComp 	:= CTOD("//")
Local _cNota		:= ""
Local _cSerie		:= ""
Local _cCodCli		:= ""
Local _Loja			:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aDBF	:= {}
aAdd( aDBF , { "VENDEDOR"	, "C" , 06 , 00 } )
aAdd( aDBF , { "FILIA"		, "C" , 02 , 00 } )
aAdd( aDBF , { "CLIFOR"		, "C" , 01 , 00 } )
aAdd( aDBF , { "CLIENTE"	, "C" , 06 , 00 } )
aAdd( aDBF , { "LOJA"     	, "C" , 02 , 00 } )
aAdd( aDBF , { "NOTA"     	, "C" , 06 , 00 } )
aAdd( aDBF , { "SERIE"		, "C" , 03 , 00 } )
aAdd( aDBF , { "TITULO"		, "C" , 06 , 00 } )
aAdd( aDBF , { "EMISSAO"	, "D" , 08 , 00 } )
aAdd( aDBF , { "VLMERC"		, "N" , 16 , 02 } )
aAdd( aDBF , { "VLIPI"		, "N" , 16 , 02 } )
aAdd( aDBF , { "VLICM"		, "N" , 16 , 02 } )
aAdd( aDBF , { "VLTOT"		, "N" , 16 , 02 } )
aAdd( aDBF , { "TRTOT"		, "N" , 16 , 02 } )
aAdd( aDBF , { "RMTOT"		, "N" , 16 , 02 } )
aAdd( aDBF , { "BOTOT"		, "N" , 16 , 02 } )
aAdd( aDBF , { "DVTOT"		, "N" , 16 , 02 } )
aAdd( aDBF , { "TIPO"     	, "C" , 01 , 00 } )
aAdd( aDBF , { "CONHEC"		, "C" , 10 , 00 } )
aAdd( aDBF , { "DTSAIDA"	, "D" , 08 , 00 } )
aAdd( aDBF , { "NAOENT"		, "C" , 40 , 00 } )
aAdd( aDBF , { "DTSAIDA2"	, "D" , 08 , 00 } )

cDBF	:= CriaTrab( aDBF , .T. )
DbUseArea( .T. ,, cDBF , "TR" , .F. )

cDBF		:= CriaTrab( NIL , .F. )
If mv_par05 == 1
	cChave	:= "VENDEDOR + CLIENTE + LOJA + NOTA + SERIE"
Else
	cChave	:= "VENDEDOR + NOTA + SERIE + CLIENTE + LOJA"
EndIf
IndRegua( "TR" , cDBF , cChave , , , "Indexando TR.." )


SA1->( DbSetOrder( 1 ) )
SA2->( DbSetOrder( 1 ) )
SA3->( DbSetOrder( 1 ) )

// Notas de Sa¡da

DbSelectArea( "SF2" )
cChave		:= "DtoS( SF2->F2_EMISSAO )"
cDBF		:= CriaTrab( NIL , .F. )
IndRegua( "SF2" , cDBF , cChave , , , "Indexando SF2.." )
SF2->( DbSeek( DtoS( mv_par01 ) , .t. ) )

SetRegua( SF2->( LastRec() ) )

While !SF2->( Eof() ) .and. SF2->F2_EMISSAO <= mv_par02 .and. LastKey() != 27 .And. LastKey() != 286 
	InKey()

	IncRegua()

    If SF2->F2_FILIAL <> "04" .AND. SF2->F2_FILIAL <> "05"
    	SF2->( DbSkip() )
       	Loop
	EndIf
    
    If SF2->F2_EMISSAO <  mv_par01 .or. SF2->F2_EMISSAO >  mv_par02
       	SF2->( DbSkip() )
       	Loop
	EndIf
   
	If SF2->F2_VEND1 < mv_par03 .or. SF2->F2_VEND1 > mv_par04
      	SF2->( DbSkip() )
      	Loop
	EndIf 
    
    aArea := GetArea("SFT")
    bCFOPRestrita := .F.
    DbSelectArea("SFT")
    dbSetOrder(6)
    DbSeek(xFilial("SFT")+"S"+SF2->F2_DOC+SF2->F2_SERIE)
    
    While SFT->(!Eof()) .and. (SFT->FT_NFISCAL = SF2->F2_DOC .and. SFT->FT_SERIE = SF2->F2_SERIE)
        
        if(AllTrim(SFT->FT_CFOP) $ "5949/5920")
            bCFOPRestrita := .T.
        Endif
           
    	SFT->(DbSkip())
    Enddo               
    
    SFT->(dbCloseArea())                       
    RestArea(aArea)
    
    If  bCFOPRestrita  
      	SF2->( DbSkip() )
      	Loop
	EndIf
   
	If SF2->F2_TIPO <> "N"  
      	SF2->( DbSkip() )
      	Loop
	EndIf
 
	If SF2->F2_TIPO <> "N"  
      	SF2->( DbSkip() )
      	Loop
	EndIf
   
    dbSelectArea("SC6")
    dbSetOrder(4)
	if dbSeek(xFilial("SC6")+SF2->F2_DOC+SF2->F2_SERIE)
    	_XPEDIDO := SC6->C6_NUM

     	If Empty(_XPEDIDO)
       		If dbSeek("04"+SF2->F2_DOC+SF2->F2_SERIE)
          		While SC6->(!Eof()) .and. SF2->(F2_FILIAL+F2_DOC+F2_SERIE) == SC6->(C6_FILIAL+C6_NOTA+C6_SERIE)
             		If SF2->(F2_CLIENTE+F2_LOJA) == SC6->(C6_CLI+C6_LOJA)
                		_XPEDIDO := SC6->C6_NUM
                		Exit
             		Endif   
             		SC6->(dbSkip())
          		Enddo
       		Endif    
       		If dbSeek("05"+SF2->F2_DOC+SF2->F2_SERIE)
          		While SC6->(!Eof()) .and. SF2->(F2_FILIAL+F2_DOC+F2_SERIE) == SC6->(C6_FILIAL+C6_NOTA+C6_SERIE)
             		If SF2->(F2_CLIENTE+F2_LOJA) == SC6->(C6_CLI+C6_LOJA)
                		_XPEDIDO := SC6->C6_NUM
                		Exit
             		Endif   
             		SC6->(dbSkip())
          		Enddo
       		Endif   
     	Endif
    Endif                                                 
    
	_tpBon := Posicione("SC5",1,xFilial("SC5")+_xpedido,"C5_NATNOTA")  
	
	//Rotina paga pegar a data de saida da nota no sistema COMPRESS
	_cNota 	:= SF2->F2_DOC
	_cSerie := SF2->F2_SERIE
	_cCodCli:= SF2->F2_CLIENTE
	_Loja	:= SF2->F2_LOJA	
	//dDtSaidaComp := DtSaidaComp(_cNota,_cSerie,_cCodCli,_Loja)
   
	DbSelectArea( "TR" )
	RecLock( "TR" , .T. )

   	TR->VENDEDOR  := SF2->F2_VEND1
   	TR->CLIFOR	  := IIF( SF2->F2_TIPO $ "D" , "F" , "C" )
   	TR->CLIENTE	  := SF2->F2_CLIENTE
   	TR->FILIA     := SF2->F2_FILIAL
   	TR->LOJA      := SF2->F2_LOJA
   	TR->NOTA      := SF2->F2_DOC
   	TR->SERIE     := SF2->F2_SERIE
   	TR->CONHEC    := SF2->F2_NUMCONH
   	TR->DTSAIDA   := SF2->F2_DTSAIDA
   	TR->DTSAIDA2  := dDtSaidaComp
   	TR->NAOENT    := SF2->F2_NAOENTR
   	TR->TITULO    := _XPEDIDO                                           
   	TR->EMISSAO	  := SF2->F2_EMISSAO
   	TR->VLMERC	  := TR->VLMERC + SF2->F2_VALMERC + SF2->F2_DESCZFR
   
   	TR->VLIPI     := TR->VLIPI  + SF2->F2_VALIPI
   	TR->VLICM     := TR->VLICM  + SF2->F2_VALICM
   	If Alltrim(_tpBon) $ "BS/TS/BT/SM/TZ/SY/TB"
      	TR->TIPO      := "T" //
	Endif    

   	If Alltrim(_tpBon) $ "RM/RP/RZ/MK/RE/SO/PM"
      	TR->TIPO      := "R" //
	Endif    

   	If Alltrim(_tpBon) $ "BO/BZ/SB/BP/BV/SV/BC/SZ/ZB"
      	TR->TIPO      := "B" //
	Endif    
	
    If Alltrim(_tpBon) $ "VE/ST/SU/EX/CE/ZS/ZF/VS/VC/SC/SP/VP/ZP/CL/SE/SS/ZV/ZT" .OR. Empty(_tpBon)
      TR->TIPO      := "V" //
	Endif    

	If TR->TIPO == "V"
		TR->VLTOT     := TR->VLTOT  + ( SF2->F2_VALBRUT)
	Elseif TR->TIPO == "B"              
	    TR->BOTOT     := TR->BOTOT  + ( SF2->F2_VALBRUT)
  	Elseif TR->TIPO == "T"
	    TR->TRTOT     := TR->TRTOT  + ( SF2->F2_VALBRUT)
	Elseif TR->TIPO == "R"
	    TR->RMTOT     := TR->RMTOT  + ( SF2->F2_VALBRUT)
	Endif
	TR->( MsUnLock() )

	DbSelectArea( "SF2" )
	SF2->( DbSkip() ) 
	
EndDo

// Notas de Devolucao

DbSelectArea( "SF1" )
cChave	:= "DtoS( SF1->F1_DTDIGIT )"
cDBF		:= CriaTrab( NIL , .F. )
IndRegua( "SF1" , cDBF , cChave , , , "Indexando SF1.." )
SF1->( DbSeek( DtoS( mv_par01 ) , .t. ) )

SetRegua( SF1->( LastRec() ) )

While !SF1->( Eof() ) .and. SF1->F1_DTDIGIT <= mv_par02 .and. ;
	LastKey() != 27 .and. LastKey() != 286

	IncRegua()

	If SF1->F1_FILIAL <> "04" .AND. SF1->F1_FILIAL <> "05"				// Devolucao
		SF1->( DbSkip() )
		Loop
	EndIf

    If SF1->F1_DTDIGIT < mv_par01 .or. SF1->F1_DTDIGIT > mv_par02
       SF1->( DbSkip() )
       Loop
	EndIf
    
	If Alltrim(SF1->F1_TIPO) <> "D"				// Devolucao
		SF1->( DbSkip() )
		Loop
	EndIf

	SA1->( DbSeek( xFILIAL( "SA1" ) + SF1->F1_FORNECE + SF1->F1_LOJA ) )

	If SA1->A1_VEND < mv_par03 .or. SA1->A1_VEND > mv_par04
		SF1->( DbSkip() )
		Loop
	EndIf
    _XPEDIDO := " "
    //_XPEDIDO := GetAdvFVal("SC6","C6_NUM",xFilial("SC6")+SF1->F1_NFORIG+SF1->F1_SERORIG,4)
//////*/
    _XBONIF := "  "      
    _DValMerc := _DValIpi := _DValIcm := _BValMerc := _BValIpi := _BValIcm := 0
    _XCred    := " "
    dbSelectArea("SD1")
    dbSetOrder(1)
    dbGoTop()
    dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
    _flagd := .f.

	While SD1->(!EOF()) .and. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
    	_YNFORI  := SD1->D1_NFORI
       	_YSERORI := SD1->D1_SERIORI
       	_XBONIF  := SUBSTR(SD1->D1_CF,2,2)
       	_XCRED   := GetAdvFVal("SF4","F4_DUPLIC",xFilial("SF4")+SD1->D1_TES,1)
       	_XESTQ   := GetAdvFVal("SF4","F4_ESTOQUE",xFilial("SF4")+SD1->D1_TES,1)
       	If Alltrim(SD1->D1_TIPO) <> "D"				// Devolucao
        	SD1->( DbSkip() )
		    Loop
	    EndIf
       	If _XCred == "S"// .and.  _XESTQ == "S"
        	_flagd := .t.
          	_DValMerc := _DValMerc + SD1->D1_TOTAL
          	_DValIpi  := _DValIpi  + SD1->D1_VALIPI
          	_DValIcm  := _DValIcm  + SD1->D1_VALICM
       	Endif
       	SD1->(dbSkip())
	Enddo   
///////*/
	If (_DValMerc+_DValIpi+_DValIcm) > 0 .and. _flagd
   		DbSelectArea( "TR" )
	   	RecLock( "TR" , .T. )
	   	TR->VENDEDOR	:= SA1->A1_VEND
	   	TR->CLIFOR	:= IIF( SF1->F1_TIPO $ "D" , "C" , "F" )
	   	TR->CLIENTE	:= SF1->F1_FORNECE
	   	TR->FILIA   	:= SF1->F1_FILIAL
	   	TR->LOJA		:= SF1->F1_LOJA
	   	TR->NOTA		:= SF1->F1_DOC
	   	TR->SERIE	:= SF1->F1_SERIE
	   	TR->TITULO	:= "DEVOL."
	   	TR->EMISSAO	:= SF1->F1_DTDIGIT
	   	TR->VLMERC	:= TR->VLMERC + ( _DValMerc * -1 ) //SF1->F1_VALMERC * -1 )
	   	TR->VLIPI	:= TR->VLIPI  + ( _DValIpi  * -1 ) //SF1->F1_VALIPI  * -1 )
	   	TR->VLICM	:= TR->VLICM  + ( _DValIcm  * -1 ) //SF1->F1_VALICM  * -1 )
       	TR->TIPO     := "D"
       	TR->DVTOT	:= TR->DVTOT  + ( ( _DValMerc + _DValIpi ) * -1 ) //SF1->F1_VALMERC + SF1->F1_VALIPI ) * -1 )
	   	TR->( MsUnLock() )
    Endif

	DbSelectArea( "SF1" )
	SF1->( DbSkip() )
	
EndDo

cCabec1 := "CODIGO     RAZAO SOCIAL                              RAMO  NOTA/SERIE   NUMERO     DATA       DATA       NUMERO          VALOR DA           VALOR           VALOR        DATA SAIDA"
cCabec2 := "CLIENTE                                                                 PEDIDO   EMISSAO      SAIDA   CONHECIMENTO     MERCADORIA             IPI           TOTAL        COMPRESS"
*******     XXXXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX    XXXXXX/XX    XXXXXX   XX/XX/XX   XX/XX/XX   XXXXXXXXXX   99,999,999.99   99,999,999.99   99,999,999.99
//          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//                    1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22  16        17        18        19        20        21        22
DbSelectArea( "TR" )
TR->( DbGoTop() )

SetRegua( TR->( RecCount() ) )

Store 0 to nGQtdNF , nGVLMERC  , nGVLIPI  , nGVLTOTAL
Store 0 to nGQtdNFF, nGVLMERCF , nGVLIPIF , nGVLTOTALF
Store 0 to nGQtdBO , nGVLMEBO  , nGVLIBO  , nGVLTOTBO
Store 0 to nGQtdBOF, nGVLMEBOF , nGVLIBOF , nGVLTOTBOF
Store 0 to nGQtdDV , nGVLMEDV  , nGVLIDV  , nGVLTOTDV
Store 0 to nGQtdDVF, nGVLMEDVF , nGVLIDVF , nGVLTOTDVF
Store 0 to nGQtdTR , nGVLMETR  , nGVLITR  , nGVLTOTTR
Store 0 to nGQtdTRD, nGVLMETRD , nGVLITRD , nGVLTOTTRD
Store 0 to nGQtdRM , nGVLMERM  , nGVLIRM  , nGVLTOTRM
Store 0 to nGQtdREM, nGVLMEREM , nGVLIREM , nGVLTOTREM

While !TR->( Eof() ) .and. LastKey() != 27 .and. LastKey() != 286
   //InKey()
	cVendedor	:= TR->VENDEDOR
	cNomeVend	:= IIF( SA3->( DbSeek( xFILIAL( "SA3" ) + TR->VENDEDOR ) ) , SA3->A3_NOME , "*** NAO CADASTRADO ***" )
	LI				:= 100
	Store 0 to nQtdNF , nVLMERC  , nVLIPI  , nVLTOTAL  , nDVTOT  , nBOTOT  , nQtdBo , nQtdDv
	Store 0 to nQtdNFF, nVLMERCF , nVLIPIF , nVLTOTALF , nDVTOTF , nBOTOTF
	Store 0 to nQtdBO , nVLMEBO  , nVLIBO  , nVLTOTBO  , nDVTBO  , nBOTOT 
	Store 0 to nQtdBOF, nVLMEBOF , nVLIBOF , nVLTOTBOF , nDVTBOF , nBOTBOF
	Store 0 to nQtdDV , nVLMEDV  , nVLIDV  , nVLTOTDV  , nDVTDV  , nDVTOT 
	Store 0 to nQtdDVF, nVLMEDVF , nVLIDVF , nVLTOTDVF , nDVTDVF , nDVTOTF
	Store 0 to nQtdTR , nVLMETR  , nVLITR  , nVLTOTTR  , nDVTTR  , nTRTOT 
	Store 0 to nQtdTRD, nVLMETRD , nVLITRD , nVLTOTTRD , nDVTTRD , nTRTOTF
	Store 0 to nQtdRM , nVLMERM  , nVLIRM  , nVLTOTRM  , nDVTRM  , nRMTOT 
	Store 0 to nQtdREM, nVLMEREM , nVLIREM , nVLTOTREM , nDVTREM , nRMTOTF

	While !TR->( Eof() ) .and. TR->VENDEDOR == cVendedor .and. ;
		LastKey() != 27 .and. LastKey() != 286
      //InKey()

		IncRegua()

		If Li > 43
			Li	:= Cabec( cTitulo , cCabec1 , cCabec2 , NomeProg , Tamanho , Caracter )
			LI	:= LI + 1
            @ LI , 000 PSAY "REPRESENTANTE : " + AllTrim( cVendedor ) + Space( 03 ) + cNomeVend
			LI	:= LI + 2
		EndIf

      	@ LI , 000 PSAY AllTrim( TR->CLIENTE ) + "/" + TR->LOJA

		If TR->CLIFOR == "C"
			SA1->( DbSeek( xFILIAL( "SA1" ) + TR->CLIENTE + TR->LOJA ) )
         	@ LI , 011 PSAY Left( SA1->A1_NOME , 40 )
         	@ LI , 053 PSAY Alltrim( SA1->A1_RAMO)
		Else
			SA2->( DbSeek( xFILIAL( "SA2" ) + TR->CLIENTE + TR->LOJA ) )
         	@ LI , 011 PSAY Left( SA2->A2_NOME , 40 )
         	@ LI , 053 PSAY "XX"
		EndIf

      	@ LI , 059 PSAY TR->NOTA + "/" + TR->SERIE
      	@ LI , 070 PSAY TR->TITULO
      	//@ LI , 072 PSAY TR->TIPO
      	@ LI , 081 PSAY TransForm( TR->EMISSAO , "" )
      	@ LI , 092 PSAY TransForm( TR->DTSAIDA , "" )
      	@ LI , 103 PSAY CONHEC
      	@ LI , 116 PSAY TransForm( TR->VLMERC  , "@E 99,999,999.99" )
      	@ LI , 132 PSAY TransForm( TR->VLIPI   , "@E 99,999,999.99" )
      	If TR->TIPO == "V"
        	@ LI , 148 PSAY TransForm( TR->VLTOT   , "@E 99,999,999.99" )
      	ElseIf TR->TIPO == "B"
         	@ LI , 148 PSAY TransForm( TR->BOTOT   , "@E 99,999,999.99" )
      	ElseIf TR->TIPO == "D"
         	@ LI , 148 PSAY TransForm( TR->DVTOT   , "@E 99,999,999.99" )
      	ElseIf TR->TIPO == "T"
         	@ LI , 148 PSAY TransForm( TR->TRTOT   , "@E 99,999,999.99" )
      	ElseIf TR->TIPO == "R"
         	@ LI , 148 PSAY TransForm( TR->RMTOT   , "@E 99,999,999.99" )
      	Endif   
      	@ LI , 170 PSAY TransForm( TR->DTSAIDA2 , "" )
      	LI := LI + 1

    // Total Geral por Representante
		If TR->TIPO == "V"
        	nQtdNF	:= nQtdNF	+ 1
	      	nVLMERC	:= nVLMERC  + TR->VLMERC
		   	nVLIPI	:= nVLIPI   + TR->VLIPI 
		   	nVLTOTAL	:= nVLTOTAL + TR->VLTOT 
			// Total Geral
  		   	nGQtdNF	 := nGQtdNF	+ 1
		   	nGVLMERC := nGVLMERC  + TR->VLMERC 
		   	nGVLIPI	 := nGVLIPI   + TR->VLIPI
		   	nGVLTOTAL:= nGVLTOTAL + TR->VLTOT
      	Elseif TR->TIPO == "B"
         	nQtdBO	 := nQtdBO	+ 1
	      	nVLMEBO	 := nVLMEBO  + TR->VLMERC
		   	nVLIBO	 := nVLIBO   + TR->VLIPI 
		   	nVLTOTBO := nVLTOTBO + TR->BOTOT
			// Total Geral
  		   	nGQtdBO	 := nGQtdBO	+ 1
		   	nGVLMEBO := nGVLMEBO  + TR->VLMERC
		   	nGVLIBO	 := nGVLIBO   + TR->VLIPI 
		   	nGVLTOTBO:= nGVLTOTBO + TR->BOTOT
      	Elseif TR->TIPO == "D"
         	nQtdDV	 := nQtdDV	+ 1
	      	nVLMEDV	 := nVLMEDV  + TR->VLMERC
		   	nVLIDV	 := nVLIDV   + TR->VLIPI 
		   	nVLTOTDV := nVLTOTDV + TR->DVTOT 
			// Total Geral
  		   	nGQtdDV	 := nGQtdDV	+ 1
		   	nGVLMEDV := nGVLMEDV  + TR->VLMERC
		   	nGVLIDV	 := nGVLIDV   + TR->VLIPI 
		   	nGVLTOTDV:= nGVLTOTDV + TR->DVTOT
      	Elseif TR->TIPO == "R"
         	nQtdRM	 := nQtdRM	+ 1
	      	nVLMERM	 := nVLMERM  + TR->VLMERC
		   	nVLIRM	 := nVLIRM   + TR->VLIPI 
		   	nVLTOTRM  := nVLTOTRM + TR->RMTOT 
			// Total Geral
  		   	nGQtdRM	 := nGQtdRM + 1
		   	nGVLMERM  := nGVLMERM  + TR->VLMERC
		   	nGVLIRM	 := nGVLIRM   + TR->VLIPI 
		   	nGVLTOTRM := nGVLTOTRM + TR->RMTOT
      	Elseif TR->TIPO == "T"
         	nQtdTR	 := nQtdTR	+ 1
	      	nVLMETR	 := nVLMETR  + TR->VLMERC
		   	nVLITR	 := nVLITR   + TR->VLIPI 
		   	nVLTOTTR := nVLTOTTR + TR->TRTOT 
			// Total Geral
  		   	nGQtdTR	 := nGQtdTR	+ 1
		   	nGVLMETR := nGVLMETR  + TR->VLMERC
		   	nGVLITR	 := nGVLITR   + TR->VLIPI 
		   	nGVLTOTTR:= nGVLTOTTR + TR->TRTOT
      	Endif  
		If !Empty( TR->TITULO )

			If TR->TIPO == "V"
			// Total Geral Faturado por Representante
		    	nQtdNFF		:= nQtdNFF   + 1
			    nVLMERCF	    := nVLMERCF  + TR->VLMERC
			    nVLIPIF		:= nVLIPIF   + TR->VLIPI
			    nVLTOTALF	:= nVLTOTALF + TR->VLTOT
				// Total Geral Faturado
               	nGQtdNFF     := nGQtdNFF   + 1
               	nGVLMERCF    := nGVLMERCF  + TR->VLMERC
			    nGVLIPIF	    := nGVLIPIF   + TR->VLIPI
               	nGVLTOTALF   := nGVLTOTALF + TR->VLTOT
			Elseif TR->TIPO == "D"
				// Total Geral Devolucao por Representante
               	nQtdDVF    := nQtdDVF   + 1
			    nVLMEDVF	    := nVLMEDVF  + TR->VLMERC
			    nVLIDVF		:= nVLIDVF   + TR->VLIPI
			    nVLTOTDVF	:= nVLTOTDVF + TR->DVTOT
				// Total Geral Devolucao
               	nGQtdDVF     := nGQtdDVF   + 1
 			    nGVLMEDVF	:= nGVLMEDVF  + TR->VLMERC
			    nGVLIDVF	    := nGVLIDVF   + TR->VLIPI
			    nGVLTOTDVF	:= nGVLTOTDVF + TR->DVTOT
			Elseif TR->TIPO == "B"
				// Total Geral Bonificacao por Representante
		        nQtdBOF		:= nQtdBOF   + 1
			    nVLMEBOF	    := nVLMEBOF  + TR->VLMERC
			    nVLIBOF		:= nVLIBOF   + TR->VLIPI
			    nVLTOTBOF	:= nVLTOTBOF + TR->BOTOT
				// Total Geral Bonificacao
   			   	nGQtdBOF	    := nGQtdBOF   + 1
 			    nGVLMEBOF	:= nGVLMEBOF  + TR->VLMERC
			    nGVLIBOF	    := nGVLIBOF   + TR->VLIPI
			    nGVLTOTBOF	:= nGVLTOTBOF + TR->BOTOT
			Elseif TR->TIPO == "R"
				// Total Geral Bonificacao por Representante
		        nQtdREM		:= nQtdREM   + 1
			    nVLMEREM	   := nVLMEREM  + TR->VLMERC
			    nVLIREM		:= nVLIREM   + TR->VLIPI
			    nVLTOTREM	:= nVLTOTREM + TR->RMTOT
				// Ttal Geral Bonificacao
   			   	nGQtdREM	    := nGQtdREM   + 1
 			    nGVLMEREM	:= nGVLMEREM  + TR->VLMERC
			    nGVLIREM	    := nGVLIREM   + TR->VLIPI
			    nGVLTOTREM	:= nGVLTOTREM + TR->RMTOT
			Elseif TR->TIPO == "T"
				// Total Geral Bonificacao por Representante
		        nQtdTRD		:= nQtdTRD   + 1
			    nVLMETRD	    := nVLMETRD  + TR->VLMERC
			    nVLITRD		:= nVLITRD   + TR->VLIPI
			    nVLTOTTRD	:= nVLTOTTRD + TR->TRTOT
				// Total Geral Bonificacao
   			   	nGQtdTRD	    := nGQtdTRD   + 1
 			    nGVLMETRD	:= nGVLMETRD  + TR->VLMERC
			    nGVLITRD	    := nGVLITRD   + TR->VLIPI
			    nGVLTOTTRD	:= nGVLTOTTRD + TR->TRTOT
         	Endif
		EndIf         
		
		if(Val(SA1->A1_RAMO) > 10 .AND. Val(SA1->A1_RAMO) < 16  .AND. (TR->TIPO == "V")  )
			nTotVarejo  += TR->VLMERC
		Else
		   	nTotAtacado += TR->VLMERC
		Endif 
			
		TR->( DbSkip() )
	EndDo

	// LI	:= LI + 1
   	@ LI , 000 PSAY Replicate( "-" , 220 )

   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nQtdNF , 5 )
   	@ LI , 020 PSAY PadL( "TOTAL DE VENDAS DO REPRESENTANTE -->> " + cVendedor , 084 )
   	@ LI , 111 PSAY TransForm( nVLMERC  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nVLIPI   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nVLTOTAL , "@E 99,999,999.99" )

   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nQtdDV , 5 )
   	@ LI , 020 PSAY PadL( "TOTAL DE DEVOLUCAO DO REPRESENTANTE -->> " + cVendedor , 084 )
   	@ LI , 111 PSAY TransForm( nVLMEDV  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nVLIDV   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nVLTOTDV , "@E 99,999,999.99" )

   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nQtdNF - nQtdDV , 5 )
   	@ LI , 020 PSAY PadL( "TOTAL LIQUIDO DO REPRESENTANTE -->> " + cVendedor , 084 )
   	@ LI , 111 PSAY TransForm( nVLMERC + nVLMEDV  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nVLIPI + nVLIDV  , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nVLTOTAL + nVLTOTDV, "@E 99,999,999.99" )

   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nQtdBO , 5 )
   	@ LI , 020 PSAY PadL( "TOTAL BONIFICACAO DO REPRESENTANTE -->> " + cVendedor , 084 )
   	@ LI , 111 PSAY TransForm( nVLMEBO  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nVLIBO   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nVLTOTBO , "@E 99,999,999.99" )

   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nQtdTR , 5 )
   	@ LI , 020 PSAY PadL( "TOTAL BONIF. CAMPANHA REPRESENTANTE -->> " + cVendedor , 084 )
   	@ LI , 111 PSAY TransForm( nVLMETR  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nVLITR   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nVLTOTTR , "@E 99,999,999.99" )
   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nQtdRM , 5 )
   	@ LI , 020 PSAY PadL( "TOT. REM. MOSTRUARIO  REPRESENTANTE -->> " + cVendedor , 084 )
   	@ LI , 111 PSAY TransForm( nVLMERM  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nVLIRM   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nVLTOTRM , "@E 99,999,999.99" )

   	LI	:= LI + 1

   	//@ LI , 000 PSAY "Qtd. NF's -> " + Str( nQtdNFF , 5 )
   	@ LI , 020 PSAY PadL( "TOTAL FATURADO NO VAREJO (10 Á 16) -->> ", 084 )
   	@ LI , 111 PSAY TransForm( nTotVarejo  , "@E 99,999,999.99" )   
    LI	:= LI + 1
     
    nTotVarejo := 0 

   	//@ LI , 000 PSAY "Qtd. NF's -> " + Str( nQtdNFF , 5 )
   	@ LI , 020 PSAY PadL( "TOTAL FATURADO NO ATACADO (50 Á 55) -->> ", 084 )
   	@ LI , 111 PSAY TransForm( nTotAtacado  , "@E 99,999,999.99" )
   
   	nTotAtacado := 0 

EndDo

If LastKey() == 27 .or. Lastkey() == 286
	LI	:= LI+2
   	@ LI , 00 PSAY PadC( "***  RELATORIO CANCELADO PELO OPERADOR  ***" , 220 )
Else
   	Li := Cabec( cTitulo , cCabec1 , cCabec2 , NomeProg , Tamanho , Caracter )
   	LI := LI + 3

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nGQtdNFF , 5 )
   	@ LI , 020 PSAY PadR( "TOTAL FATURADO -->>" , 084 )
   	@ LI , 111 PSAY TransForm( nGVLMERCF  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nGVLIPIF   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nGVLTOTALF , "@E 99,999,999.99" )
   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nGQtdDV , 5 )
   	@ LI , 020 PSAY PadR( "TOTAL GERAL DEVOLUCAO -->" , 084 )
   	@ LI , 111 PSAY TransForm( nGVLMEDV  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nGVLIDV   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nGVLTOTDV , "@E 99,999,999.99" )

   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nGQtdNF - nGQtdDV , 5 )
   	@ LI , 020 PSAY PadR( "TOTAL GERAL LIQUIDO  -->> " , 084 )
   	@ LI , 111 PSAY TransForm( nGVLMERC + nGVLMEDV  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nGVLIPI + nGVLIDV  , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nGVLTOTAL + nGVLTOTDV, "@E 99,999,999.99" )

   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nGQtdBO , 5 )
   	@ LI , 020 PSAY PadR( "TOTAL GERAL BONIFICACAO -->> ", 084 )
   	@ LI , 111 PSAY TransForm( nGVLMEBO  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nGVLIBO   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nGVLTOTBO , "@E 99,999,999.99" )

   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nGQtdTR , 5 )
   	@ LI , 020 PSAY PadR( "TOTAL GERAL CAMPANHA... -->> ", 084 )
   	@ LI , 111 PSAY TransForm( nGVLMETR  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nGVLITR   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nGVLTOTTR , "@E 99,999,999.99" )
   	LI	:= LI + 1

   	@ LI , 000 PSAY "Qtd. NF's -> " + Str( nGQtdRM , 5 )
   	@ LI , 020 PSAY PadR( "TOTAL GERAL REM. MOSTR. -->> ", 084 )
   	@ LI , 111 PSAY TransForm( nGVLMERM  , "@E 99,999,999.99" )
   	@ LI , 127 PSAY TransForm( nGVLIRM   , "@E 99,999,999.99" )
   	@ LI , 143 PSAY TransForm( nGVLTOTRM , "@E 99,999,999.99" )
EndIf

Roda( CbCont , CbTxt , Tamanho )

If aReturn[ 5 ] == 1
	Set Device to Screen
	Set Printer To 
	OurSpool(wnrel)
EndIf

MS_FLUSH()

DbSelectArea( "TR" )
TR->( DbCloseArea() )

DbSelectArea( "SF1" )
dbSetOrder(1)
//RetIndex()

DbSelectArea( "SF2" )
dbSetOrder(1)
//RetIndex()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna a Integridade dos Dados de Entrada.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//SetColor( cSavCor )
dbSelectArea( cAliasAnt )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±
±³SISTEMA   ³ Protheus 11   ³ MODULO ³ Faturamento ³ PROGRAMA ³ DtSaidaComp  ³±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³FINALIDADE³ Rotina que vai buscar no banco do dados do sistema COMPRESS a  ³±
±³          ³ data de saida da nota efetivamente.                            ³±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³AUTOR     ³ Adalberto    ³ DATA ³03/02/2015³ OBS ³                         ³±
±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³               R E G I S T R O S   D E   A L T E R A € å E S               ³±
±ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³  DATA  ³   AUTOR  ³               A  L  T  E  R  A  €  A  O               ³±
±³        ³          ³                                                       ³±
±³        ³          ³                                                       ³±
±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DtSaidaComp(_cNota,_cSerie,_cCodCli,_cLoja)

Local dDtSaida := CTOD("//") 
Local cQuery 	:= ""
Local cLinha	:= CHR(13) + CHR(10) 

cQuery := "SELECT     " 																			+ cLinha
cQuery += "	REL1.Numero, REL1.Saida, REL2.NF, REL2.Serie, REL2.Codcli, REL2.Loja, REL2.Relcarga" 	+ cLinha
cQuery += "FROM         " 																			+ cLinha
cQuery += "	FRETEDANA.dbo.DBRELCARGA AS REL1 INNER JOIN" 											+ cLinha
cQuery += "		FRETEDANA.dbo.DBRELCARGANFS AS REL2 ON REL1.Numero = REL2.Relcarga" 				+ cLinha
cQuery += "WHERE     " 																				+ cLinha
cQuery += "	(REL2.NF = '" + _cNota + "') " 															+ cLinha
cQuery += "	AND (REL2.Serie = '" + _cSerie + "') " 													+ cLinha
cQuery += "	AND (REL2.Codcli = '" + _cCodCli + "') " 												+ cLinha
cQuery += "	AND (REL2.Loja = '" + _cLoja + "')" 													+ cLinha  
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRBCOM", .F., .T.)

TRBCOM->(dbGoTop())

If !TRBCOM->(Eof())
	dDtSaida := TRBCOM->Saida
Endif

TRBCOM->(dbCloseArea())

Return(dDtSaida)