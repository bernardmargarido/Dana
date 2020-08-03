#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "REPORT.CH" 

#DEFINE CRLF CHR(13) + CHR(10)
#DEFINE CLR_BLACK RGB(0,0,0)
#DEFINE CLR_WITHE RGB(255,255,255)

#DEFINE TAM_A4 9

/********************************************************************************/
/*/{Protheus.doc} SIGR003
    @description Realiza a impressao das etiquetas SIGEP
    @author Bernard M. Margarido
    @since 08/03/2017
    @version undefined
    @type function
/*/
/********************************************************************************/
User Function SIGR003(_cPLPDe,_cPLPAte)
Local _cPerg 		:= "SIGR03"

Private _lJob		:= IIF(Isincallstack("U_ECLOJM06"),.T.,.F.)

Private _oProcess   := Nil

Default _cPLPDe		:= ""
Default _cPLPAte	:= ""

//------------------------------+
// Cria Parametros do relatorio |
//------------------------------+
AjustaSx1(_cPerg)

If Pergunte(_cPerg,.T.)
	_oProcess:= MsNewProcess():New( {|| SigR03Prt(_cPLPDe,_cPLPAte)},"Dana Cosmeticos - eCommerce","Aguarde ... Imprimindo Etiquetas." )
    _oProcess:Activate()
EndIf
	
Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigR03Prt
    @description Realiza a impressao de etiquetas
    @author Bernard M. Margarido
    @since 07/04/2017
    @version undefined
    @type function
/*/
/**********************************************************************************/
Static Function SigR03Prt(_cPLPDe,_cPLPAte)
Local _cAlias			:= GetNextAlias()
Local _cPath 	        := AllTrim(GetTempPath())
Local _cBat             := "SIGR003.bat"
Local _cCmdBat          := ""
Local _cPasta	        := "\ETIQUETAS\"
Local _cPorta           := "LPT1"
Local _cArquivo         := ""
Local _cCodPlp			:= ""
Local _cDoc				:= ""
Local _cSerie			:= ""
Local _cPedido			:= ""
Local _cCodEtq			:= ""
Local _cDest			:= ""
Local _cEndDest			:= ""
Local _cBairro			:= ""
Local _cMunicipio		:= ""
Local _cCep				:= ""
Local _cUF				:= ""
Local _cObs				:= ""
Local _cDTMatrix		:= ""
Local _cPlpID			:= ""
Local _cCodServ			:= ""
Local _cTelDest			:= ""
Local _cEtq             := ""
Local _cTotEtq          := ""

Local _nVolume			:= 0
Local _nPeso			:= 0 
Local _nToReg			:= 0
Local _nValor			:= 0
Local _nX				:= 0

//-----------------------------+
// Consulta PLP a ser impressa |
//-----------------------------+
If !Sigr03Qry(_cAlias,_cPLPDe,_cPLPAte,@_nToReg)
	MsgStop("Não foram encontrados dados para serem processados. Favor Verificar os parametros.","Dana Cosmeticos - eCommerce")
	(_cAlias)->( dbCloseArea() )
	Return Nil
EndIf


//---------------------------------------+
// Coordendas para linha inicial e final |
//---------------------------------------+
_oProcess:SetRegua1( _nToReg )
While (_cAlias)->( !Eof() )
    
    _cCodPlp 	:= (_cAlias)->ZZ2_CODIGO
    
    _cArquivo   := RTrim(_cCodPlp) + "-" + cValToChar(_nX) + "_" + DToS(Date()) + "-" + StrTran( Time(),":") + ".prn"
    _cCmdBat    := "REM Run shell as admin" + CRLF
    _cCmdBat    += "TYPE " + _cPath + _cArquivo + " >" + _cPorta

    //------------------+    
    // Cria arquivo bat |
    //------------------+
    SigR03Bat(_cPath,_cBat,_cCmdBat)

    _oProcess:IncRegua1("Etiquetas PLP " + _cCodPlp +  " .")
    
    _oProcess:SetRegua2( -1 )
    While (_cAlias)->( !Eof() .And. _cCodPlp == (_cAlias)->ZZ2_CODIGO )
    
        For _nX := 1 To Int((_cAlias)->C5_VOLUME1)

            //------------------+	
            // Imprime etiqueta |
            //------------------+
            _cEtq       := ""
            _cPlpID		:= (_cAlias)->ZZ2_PLPID
            _cDoc		:= (_cAlias)->WSA_DOC
            _cSerie		:= (_cAlias)->WSA_SERIE
            _cPedido	:= (_cAlias)->C5_NUM
            _cCodEtq	:= (_cAlias)->ZZ4_CODETQ	
            _cDest		:= (_cAlias)->WSA_NOMDES
            _cEndDest	:= (_cAlias)->WSA_ENDENT
            _cBairro	:= (_cAlias)->WSA_BAIRRE
            _cMunicipio	:= (_cAlias)->WSA_MUNE
            _cCep		:= (_cAlias)->WSA_CEPE
            _cUF		:= (_cAlias)->WSA_ESTE
            _cObs		:= (_cAlias)->WSA_COMPLE
            _cCodServ	:= (_cAlias)->ZZ0_CODSER
            _cDescSer	:= (_cAlias)->ZZ0_DESCRI
            _cTelDest	:= (_cAlias)->WSA_TEL01
            _cDTMatrix	:= ""
            _nValor		:= (_cAlias)->WSA_VLRTOT
            _nVolume	:= _nX
            _nPeso		:= IIF((_cAlias)->C5_PBRUTO > 0, (_cAlias)->C5_PBRUTO * 1000, 100) 
            
            _oProcess:IncRegua2(" Imprimindo Etiqueta pedido " + _cPedido + " .")

            SigR03Etq(	_cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,;
                        _cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,;
                        _cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,;
                        _nValor,_nVolume,_nPeso,@_cEtq)
            
            If !Empty(_cEtq)
                _cTotEtq += _cEtq 
            EndIf
            
        Next _nX
        (_cAlias)->( dbSkip() )
    EndDo

    _nHandle := FCREATE(_cPasta + _cArquivo)
    FWRITE(_nHandle, _cTotEtq)
    FCLOSE(_nHandle)

    __CopyFile(_cPasta + _cArquivo, _cPath + _cArquivo)

    FErase(_cPasta + _cArquivo)

    //_nErro := WinExec("cmd /c copy " + _cPath + _cArquivo + " " + _cPorta + " /Y")
    _nErro := WinExec(_cPath + _cBat)

    If _nErro == 0
        MsgInfo("Enviado arquivo para impressão com sucesso.")
    Else
        MsgStop("Falha ao enviar arquivo para impressão. Erro de OS = " + cValToChar(_nErro))
    EndIf

EndDo

Return Nil

/**********************************************************************************/
/*/{Protheus.doc} SigR03Etq
    @description Imprime etiqueta zebra
    @author Bernard M. Margarido
    @since 07/04/2017
    @version undefined
    @type function
/*/
/**********************************************************************************/
Static Function SigR03Etq(	_cPlpID,_cDoc,_cSerie,_cPedido,_cTelDest,;
							_cCodEtq,_cDest,_cEndDest,_cBairro,_cMunicipio,;
							_cCep,_cUF,_cObs,_cCodServ,_cDescSer,_cDTMatrix,;
							_nValor,_nVolume,_nPeso,_cEtq)

Local _cCodCont		:= GetNewPar("EC_CODCONT")
Local _cNomeRem		:= ""
Local _cEndCob		:= ""
Local _cMunCob		:= ""
Local _cBairCob		:= ""
Local _cEstCob		:= ""
Local _cCepCob		:= ""
Local _cCompCob		:= ""
Local _cImgSigep	:= ""

//--------------------+
// Dados do Remetente |
//--------------------+
//--------------------+
_cNomeRem		:= Capital(RTrim(SM0->M0_NOMECOM))
_cEndCob		:= Capital(RTrim(SM0->M0_ENDCOB))
_cMunCob		:= Capital(RTrim(SM0->M0_CIDCOB))
_cBairCob		:= Capital(RTrim(SM0->M0_BAIRCOB))
_cCompCob		:= Capital(RTrim(SM0->M0_COMPCOB))
_cEstCob		:= SM0->M0_ESTCOB
_cCepCob		:= SM0->M0_CEPCOB

//---------------------------+
// Logo serviço PAC ou Sedex |
//---------------------------+
If At("SEDEX",_cDescSer) > 0
	_cImgSigep 	:= '~DG001.GRF,05376,024,,:::::::::::::::::::g0151510,,X0N540,,U015R50,,U0545454545454544,,S015V50,,S045H545H545H545H5455,,Q015g50,,Q054545454545454545454544,,P015gH540,,P0gK50,,O0gM5,,O0545454545454545454545454545,,N0gO50,,M01545H545H545H545H545H545H545H50,,M0gP54,,M05454545454545454545454545454544,,L015gP5,,L0gR540,,K015gR50,,K014545454545454545454545454545454544,,K0gT54,,K045H545H545H545H545H545H545H545H5454,,J015gT5,,J045454545454545454545454545454545454540,,J0gW50,,J0gV540,,I015gV50,,I0145454545454545454545454545454545454540,,I015gV54,,I0H545H545H545H545H545H545H545H545H545H54,,I0gY5,,I0545454545454545454545454545454545454544,,H015gX5,,I0gY5,,H015gX5,,I0545454545454545454545454545454545454545,,H015gX5,,H015545H545H545H545H545H545H545H545H545H54,,H015gX5,,I0545454545454545454545454545454545454545,,H015U5H1010115U5,,H015R540P0T5,,H015Q5T015Q5,,I0545454545440V054545454545,,H015N510X015N5,,H015545H54540gG0I545H54,,H015L5gJ015L5,,I054545440gJ05454545,,H015K5gL015K5,,H015I540gM015J5,,H015I5gP015I5,,I054540gP04545,,H015H5gR015H5,,H015540gR0H54,,H01550gS0155,,I0540gT045,,H0150gU015,,H0140gV05,,H0140gV01,,hG01,,H010,,::::::Y0H1J50,,X0N540,,W0Q5,,V045454545454540,,U015R50,,U0H545H545H545H54,,T0V540,,T0454545454545454540,,S0X54,,S0X54,,R015X5,,R04545454545454545454540,,Q015g50,,Q01545H545H545H545H545H50,,Q015g50,,Q054545454545454545454544,,P015gH5,,Q0gH54,,P015gH5,,Q054545454545454545454545,,P015gH5,,P015545H545H545H545H545H54,,P015gH5,,::::::::::::::::::::::::::::::' + CRLF
ElseIf At("PAC",_cDescSer) > 0
	_cImgSigep 	:= '~DG001.GRF,04608,024,,:::::::::::::::::::::::::gI0JA8,gH0L540,g02ANA,g015N5,Y0AEAEAEAEAEAE8,X015Q54,X0UA0,W015T50,W0EAEAEAEAEAEAEAEAA,V015V5,V0YA0,U015X50,U0IAEAHAEAHAEAHAEAHAE8,U0g54,T02AgA,T015g5,T0AEAEAEAEAEAEAEAEAEAEAEA8,S015gH50,S02AgHA8,S0gJ54,S0AEAEAEAEAEAEAEAEAEAEAEAEA80,R015gJ5,R02AgJA80,R0gL540,R0AEAEAEAEAEAEAEAEAEAEAEAEAEA8,Q015gL50,Q02AgLA8,Q0gN50,Q0IAEAHAEAHAEAHAEAHAEAHAEAHAEA,P015gM54,P02AgNA,P015gN5,P0AEAEAEAEAEAEAEAEAEAEAEAEAEAEAE80,P0gP540,P0gQA0,O015gO540,O02EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAE8,O015gP50,O02AgPA8,O0gR50,O0EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAE,O0gR54,O0gSA,N015gR5,N02AEAHAEAHAEAHAEAHAEAHAEAHAEAHAEAHA80,N015gR5,N02AgRA80,N015gR5,N0AEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAE80,N0gT540,N0gUA0,N0gT540,N0EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAE0,N0gT540,N0gUA0,M015gT50,M02AEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA8,M015gT50,M02AgTA8,M015gT50,M02AAEAHAEAHAEAHAEAHAEAHAEAHAEAHAEAHAE8,M0gV50,M02AgTA8,M015gT50,M0EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA8,M0gV54,M02AgTA8,M0gV50,M0AEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAE8,M0gV54,M0gVA8,M0gV54,M0EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAC,M0gV54,M0gWA,M0gV54,M0IAEAHAEAHAEAHAEAHAEAHAEAHAEAHAEAHAE8,M0gV54,M02AgTA8,M0gV50,M0EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA8,M0gV54,M02AgTA8,M015gT50,M02EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAE8,M015gT50,M02AgTA8,M015gT50,M02AEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA8,M015gT50,M02AgTA0,M015gT50,N0HAEAHAEAHAEAHAEAHAEAHAEAHAEAHAEAHAE0,N0gT540,N0gUA0,N0gT540,N0AEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA0,N0gT540,N02AgRA80,N015gR5,N02AEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA80,N015gR5,N02AgRA,N015gQ54,O0EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAE,O0gR54,O0gSA,O0gR50,O02EAHAEAHAEAHAEAHAEAHAEAHAEAHAEAA8,O015gP50,O02AgPA0,P0gP540,P0AEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA0,P0gP540,P02AgNA80,P015gN5,P02AEAEAEAEAEAEAEAEAEAEAEAEAEAEA80,Q0gN54,Q0gOA,Q015gL50,Q0HAEAEAEAEAEAEAEAEAEAEAEAEAEA8,Q015gK540,R0gMA0,R0gL5,R0HAEAHAEAHAEAHAEAHAEAHAEAHA80,R015gJ5,S0gKA,S0gJ50,S0HAEAEAEAEAEAEAEAEAEAEAEA8,S015gG540,T0gIA0,T015g5,T02AEAEAEAEAEAEAEAEAEAEA80,U0g54,U02AXA8,V0X540,V0AEAEAEAEAEAEAEAEAE80,W0V54,W0WA,W015S540,X0JAEAHAEAHAEA80,Y0R54,Y02APA0,g015N5,gG0HAEAEAEA8,gI0I5H4,gJ0H2,,::::::::::::::::::' + CRLF
EndIf

//---------------+
// Dados Etiqueta|
//---------------+
_cEtq := '^XA~TA000~JSN^LT0^MNM^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ' + CRLF
_cEtq += '~DG000.GRF,04608,036,,:::::::::::::::::::::::::::::Y0101,Y08A8,W0L54,W02A2A2A0,U015N50,V0NA80,T015O54,U0A2A2A2A2H28,S015J51515I5,T0IA80J0IA,S0I540K015540,S02A20M0H280,R015540M01550,S0A80O0A80,R0H540O0H50,R0H2Q0H20,Q01550H0H5L0H50,R0A80H0HA80K0A8,Q0150H01550K0154,Q02A0I02A0L0A0,Q0H5I01550K0154,Q0A80H02A80L0A8,P0150I0H540L0540K0I5Q050N0H540,Q0A0I02A0M0280K02A280O020M0J20,P0150H01550L01540J0K5J0150H0H540K015I50,P0280I0HAN0A80J0A80M0A0H0HA80K02A80,P0540H01540L01540I0H540L0H5H015540J0154,P020I02A0N0A0J020N0H2H0H2A0L0A0,O0150I0H540L01540H01540010J0H5H0I5K01550H050,P0A0I02A0N0A80H02A0I080I0280080A0K0A80H080,O0140I0H5N01540H0540H0H5J054014150J0H5I0154,U0H2O0280H0A0I0H2J028020220J0280H0H20,O0140H01550M015401550H01550H0150050550I01550H0H50,U0A80N0A800A80I0A80I0A8080280J0A0I0HA0,T0H540M0H5H01540H0H540H0150140540I0540H01540,T0H2O02A0H0A0I02A0J0A020020J0280H0H2A0,T0H5O0H5H0H5I01550I015050150I01540H0H540H010,T02A0N0HAH0A80I0HAK0A0800A0J0A0I02A80I08,T0540N0H501540H0I5J054140150I0H5I015540H014,T0280N0A200A0I0I2J02020H020I02A0J02,S01540M01551550H015540H0154500550H01550H05150I050,T0A80N0HA8AA0I08280I0A8A00280I0A80H020A,S0150N0K540H054540H0I5400540H01540014150I040,S02A0N0H2A2A0I020280H0H2J020I02A0J0H2,S0H5K015M5400151540015H5I054001550H054150H05,S0280J0HAH8HAH0280H080A80H08AA0H0A80H08A0H0A00A0H02,S054005J5415400540054050H051550H0540055400150540H04,S020H0H2J0H280020H0200A0H02020I020H02020020022,R015K510H0H5401500150150015154001500151501540550150,S0A8AA0K02A8002802800A80080A80H0A80080800A00280080,R015H540K0H5I0540540054050550I0540500405400540140,R0H2A0M02A0I08020H028020220I02002002020H0H202,Q015H5M01550H015540015H540550I0I54001550H01515,R0A80M02A80J080I02AA00280I02AA0I0A80I0HA8,Q0H540M0H5Q01540050J01540I040J0H50,Q0A280M0H2,O015H5N01550T010L010P01,P0A0A80L02A8,O054050M0H50,O0200A0M02A0,N0150150L01540gH010,O080080L02A,N0140140L0540gL04,O080O020,N014010L0H5L0I101H1011001I1H0100150101H101H10110,O080N0A80,O040M0H540U040H040H040H040R04,O020M020,O050L0150M010H01010110I04101H1H0401010H01010110,P080K0280,O0140J0H5Y0404040L040R04,P020J020,O015H515H5P01010101010101001001100501010101010101,Q02AHA8,R0H540,,::::::::::::::::::::::' + CRLF
_cEtq += _cImgSigep  
_cEtq += '^XA' + CRLF
_cEtq += '^MMT' + CRLF
_cEtq += '^PW807' + CRLF
_cEtq += '^LL1207' + CRLF
_cEtq += '^LS0' + CRLF
_cEtq += '^FT0,128^XG000.GRF,1,1^FS' + CRLF
_cEtq += '^FT576,224^XG001.GRF,1,1^FS' + CRLF
_cEtq += '^FT31,274^A0N,25,24^FH\^FDNF: ' + RTrim(_cDoc) + '-' + _cSerie + '^FS' + CRLF
_cEtq += '^FT280,274^A0N,25,24^FH\^FDContrato: ' + _cCodCont + '^FS' + CRLF
_cEtq += '^FT579,274^A0N,25,24^FH\^FDVolume: ' + cValToChar(_nVolume) + '^FS' + CRLF
_cEtq += '^FT31,307^A0N,25,24^FH\^FDPedido: ' + _cPedido + '^FS' + CRLF
_cEtq += '^FT579,307^A0N,25,24^FH\^FDPeso(g): ' + cValToChar(_nPeso) + '^FS' + CRLF
_cEtq += '^FT31,341^A0N,25,24^FH\^FDPLP: ' + _cPlpID + '^FS' + CRLF
_cEtq += '^BY4,3,133^FT86,536^BCN,,Y,Y' + CRLF
_cEtq += '^FD>:' + SubStr(_cCodEtq,1,3) + '>5' + SubStr(_cCodEtq,4,8) + '>6' + SubStr(_cCodEtq,12,2) + '^FS' + CRLF
_cEtq += '^FT31,576^A0N,28,28^FH\^FDRecebedor: ^FS' + CRLF
_cEtq += '^FO175,572^GB581,0,4^FS' + CRLF
_cEtq += '^FT31,616^A0N,28,28^FH\^FDAssinatura:^FS' + CRLF
_cEtq += '^FO175,608^GB249,0,4^FS' + CRLF
_cEtq += '^FT435,616^A0N,28,28^FH\^FDDocumento:^FS' + CRLF
_cEtq += '^FO584,611^GB166,0,4^FS' + CRLF
_cEtq += '^FO31,643^GB736,298,4^FS' + CRLF
_cEtq += '^FT42,680^A0N,37,36^FH\^FDDestinat\A0rio^FS' + CRLF
_cEtq += '^FT58,720^A0N,25,24^FH\^FD' + Capital(RTrim(_cDest))  + '^FS' + CRLF
_cEtq += '^FT58,753^A0N,25,24^FH\^FD' + Capital(RTrim(_cEndDest)) + '^FS' + CRLF
_cEtq += '^FT58,786^A0N,25,24^FH\^FD' + Capital(RTrim(_cBairro)) + '^FS' + CRLF
_cEtq += '^FT58,819^A0N,25,24^FH\^FD' + RTrim(_cCep) +'^FS' + CRLF
_cEtq += '^FT275,819^A0N,25,24^FH\^FD'+ Capital(RTrim(_cMunicipio)) + "/" + _cUF + '^FS' + CRLF
_cEtq += '^BY2,3,87^FT58,914^BCN,,N,N' + CRLF
_cEtq += '^FD>;' + RTrim(_cCep) +'^FS' + CRLF
_cEtq += '^FT31,977^A0N,25,24^FH\^FDRemetente: ^FS' + CRLF
_cEtq += '^FT170,977^A0N,25,24^FH\^FD' + _cNomeRem + '^FS' + CRLF
_cEtq += '^FT31,1010^A0N,25,24^FH\^FD' + _cEndCob + '^FS' + CRLF
_cEtq += '^FT31,1043^A0N,25,24^FH\^FD' + _cBairCob + '^FS' + CRLF
_cEtq += '^FT31,1076^A0N,25,24^FH\^FD' + _cCompCob + '^FS' + CRLF
_cEtq += '^FT31,1109^A0N,25,24^FH\^FD' + _cCepCob + '^FS' + CRLF
_cEtq += '^FT201,1109^A0N,25,24^FH\^FD' + _cMunCob + "/" + _cEstCob + '^FS' + CRLF
_cEtq += '^LRY^FO34,646^GB241,0,38^FS^LRN' + CRLF
_cEtq += '^PQ1,0,1,Y^XZ' + CRLF
_cEtq += '^XA^ID000.GRF^FS^XZ' + CRLF
_cEtq += '^XA^ID001.GRF^FS^XZ' + CRLF

Return _cEtq

/**********************************************************************************/
/*/{Protheus.doc} SigR03DtMat
	@description Monta codigo Data Matrix
	@type  Static Function
	@author Bernard M. Margarido
	@since 20/01/2020
/*/
/**********************************************************************************/
Static Function SigR03DtMat(_cCep,_cCepCob,_cCodEtq,_cEndDest,_cEndCob,_cCodCartao,_cCodServ,_cObs,_nValor)
Local _cNumDest	:= ""
Local _cNumCob	:= ""
Local _cDigCep	:= ""
Local _cIDV		:= "51"
Local _cServAdd	:= "250000000000"
Local _cAgrup	:= "00"
Local _cTel		:= "000000000000"
Local _cLatid	:= "-00.000000"

//-------------------------+
// Numero endereço destino | 
//-------------------------+
_cNumDest	:= SigR03DtA(_cEndDest)
_cNumCob	:= SigR03DtA(_cEndCob)	
_cDigCep	:= SigR03DtB(_cCepCob)	

//--------------------------+
// Formata codigo DT Matrix |
//--------------------------+
_cCodDtMatrix	:= _cCep
_cCodDtMatrix	+= _cNumDest
_cCodDtMatrix	+= _cCepCob
_cCodDtMatrix	+= _cNumCob
_cCodDtMatrix	+= _cNumCob
_cCodDtMatrix	+= _cDigCep
_cCodDtMatrix	+= _cIDV
_cCodDtMatrix	+= RTrim(_cCodEtq)
_cCodDtMatrix	+= _cServAdd
_cCodDtMatrix	+= _cCodCartao
_cCodDtMatrix	+= _cCodServ
_cCodDtMatrix	+= _cAgrup
_cCodDtMatrix	+= _cNumDest
_cCodDtMatrix	+= SubStr(_cObs,1,20)
_cCodDtMatrix	+= cValToChar(_nValor * 100)
_cCodDtMatrix	+= _cTel
_cCodDtMatrix	+= _cLatid
_cCodDtMatrix	+= _cLatid
_cCodDtMatrix	+= "|"
_cCodDtMatrix	+= Space(30)


Return _cCodDtMatrix

/*****************************************************************************************/
/*/{Protheus.doc} SigR03DtA
	@description Valida numero do endereço de destino e remetente
	@type  Static Function
	@author Bernard M. Margarido
	@since 20/01/2020
/*/
/*****************************************************************************************/
Static Function SigR03DtA(_cEnd)
Local _cNum		:= ""
Local _cAlfaMa	:= "A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/X/W/Y/Z"
Local _cAlfaMi	:= "a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/w/x/y/z"

If At(",",_cEnd) > 0
	_cNum	:= Padl(Alltrim(SubStr(_cEnd, At(",",_cEnd) + 1)),5,"0")
	If _cNum $ _cAlfaMa .Or. _cNum $ _cAlfaMi
		_cNum	:= "00000"
	EndIf
Else
	_cNum	:= "00000"
EndIf

Return _cNum

/**********************************************************************************/
/*/{Protheus.doc} SigR03DtB
	@description Calcula digito verificador para CEP do remetente
	@type  Static Function
	@author Bernard M. Margarido
	@since 20/01/2020
/*/
/**********************************************************************************/
Static Function SigR03DtB(_cCepCob)	

Local _nX		:= 0
Local _nSCep	:= 0
Local _nResult	:= 0

For _nX := 1 To Len(_cCepCob)
	_nSCep += Val(SubStr(_cCepCob,_nX,1))
Next _nX

If Mod(_nSCep,10) <> 0
	_nResult := 20 - _nSCep
Else
	_nResult := 10 - _nSCep
EndIF

Return cValToChar(_nResult)

/**********************************************************************************/
/*/{Protheus.doc} Sigr03Qry
	@description Consulta etiquetas ser impressa
	@author Bernard M. Margarido
	@since 07/04/2017
	@version undefined
	@type function
/*/
/**********************************************************************************/
Static Function Sigr03Qry(_cAlias,_cPLPDe,_cPLPAte,_nToReg)
Local _cQuery := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	ZZ2.ZZ2_CODIGO, " + CRLF
_cQuery += "	ZZ2.ZZ2_PLPID, " + CRLF
_cQuery += "	ZZ4.ZZ4_CODETQ, " + CRLF
_cQuery += "	WSA.WSA_NOMDES, " + CRLF
_cQuery += "	WSA.WSA_ENDENT, " + CRLF
_cQuery += "	WSA.WSA_BAIRRE, " + CRLF
_cQuery += "	WSA.WSA_MUNE, " + CRLF
_cQuery += "	WSA.WSA_CEPE, " + CRLF
_cQuery += "	WSA.WSA_ESTE, " + CRLF
_cQuery += "	WSA.WSA_COMPLE, " + CRLF
_cQuery += "	WSA.WSA_DOC, " + CRLF
_cQuery += "	WSA.WSA_SERIE, " + CRLF
_cQuery += "	SC5.C5_NUM, " + CRLF
_cQuery += "	SC5.C5_VOLUME1, " + CRLF
_cQuery += "	SC5.C5_PBRUTO, " + CRLF
_cQuery += "	WSA.WSA_VLRTOT, " + CRLF
_cQuery += "	WSA.WSA_TEL01, " + CRLF
_cQuery += "	ZZ0.ZZ0_CODSER, " + CRLF	 
_cQuery += "	ZZ0.ZZ0_DESCRI " + CRLF	 
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("ZZ2") + " ZZ2 " + CRLF 
_cQuery += "	INNER JOIN " + RetSqlName("ZZ4") + " ZZ4 ON ZZ4.ZZ4_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ4.ZZ4_CODIGO = ZZ2.ZZ2_CODIGO AND ZZ4.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("WSA") + " WSA ON WSA.WSA_FILIAL = ZZ4.ZZ4_FILIAL AND WSA.WSA_NUMECO = ZZ4.ZZ4_NUMECO AND WSA.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("ZZ0") + " ZZ0 ON ZZ0.ZZ0_FILIAL = ZZ2.ZZ2_FILIAL AND ZZ0.ZZ0_IDSER = ZZ4.ZZ4_CODSPO AND ZZ0.D_E_L_E_T_ = '' " + CRLF
_cQuery += "	INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = WSA.WSA_FILIAL AND SC5.C5_NUM = WSA.WSA_NUMSC5 AND SC5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	ZZ2.ZZ2_FILIAL = '" + xFilial("ZZ2") + "' AND " + CRLF
_cQuery += "	ZZ2.ZZ2_CODIGO BETWEEN '" + _cPLPDe + "' AND '" + _cPLPAte + "' AND " + CRLF
_cQuery += "	ZZ2.ZZ2_STATUS = '04' AND " + CRLF
_cQuery += "	ZZ2.D_E_L_E_T_= '' " + CRLF
_cQuery += " ORDER BY ZZ2.ZZ2_CODIGO "
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
Count To _nToReg

dbSelectArea(_cAlias)
(_cAlias)->(dbGoTop() )

If (_cAlias)->( Eof() )
	(_cAlias)->( dbCloseArea() )
	Return .F.
EndIf

Return .T.

/***************************************************************************************/
/*/{Protheus.doc} SigR03Bat
    @description Cria arquivo bat para impressao de etiquetas 
    @author Bernard M. Maragrido
    @since 05/04/2017
    @version undefined
    @type function
/*/
/***************************************************************************************/
Static Function SigR03Bat(_cPath,_cBat,_cCmdBat)
Local __nHdl    := 0

If File(_cPath + _cBat )
	fErase(_cPath + _cBat )
EndIf
__nHdl := MSFCreate(_cPath + _cBat )
FSeek(__nHdl,0,0)
FWrite(__nHdl, _cCmdBat + CRLF, Len(_cCmdBat) + 2)
FClose(__nHdl)

Return Nil

/***************************************************************************************/
/*/{Protheus.doc} AjustaSx1
    @description Cria parametros para processamento da PLP
    @author Bernard M. Maragrido
    @since 05/04/2017
    @version undefined
    @type function
/*/
/***************************************************************************************/
Static Function AjustaSx1(_cPerg)
Local aArea 	:= GetArea()
Local aPerg 	:= {}

Local _nX		:= 0
Local nTPerg    := Len( SX1->X1_GRUPO )
Local nTSeq     := Len( SX1->X1_ORDEM )

SX1->( dbSetOrder(1) )

aAdd(aPerg, {_cPerg, "01", "Impressora", "MV_CH1", "C", TamSX3("CB5_CODIGO")[1], 0, "G"	, "MV_PAR01", "CB5","","","",""})

For _nX := 1 To Len(aPerg)
	
	If  !SX1->( dbSeek(  PadR(aPerg[_nX][1], nTPerg) + PadR(aPerg[_nX][2],nTSeq) ) )		
		RecLock("SX1",.T.)
			Replace X1_GRUPO   with aPerg[_nX][01]
			Replace X1_ORDEM   with aPerg[_nX][02]
			Replace X1_PERGUNT with aPerg[_nX][03]
			Replace X1_VARIAVL with aPerg[_nX][04]
			Replace X1_TIPO	   with aPerg[_nX][05]
			Replace X1_TAMANHO with aPerg[_nX][06]
			Replace X1_PRESEL  with aPerg[_nX][07]
			Replace X1_GSC	   with aPerg[_nX][08]
			Replace X1_VAR01   with aPerg[_nX][09]
			Replace X1_F3	   with aPerg[_nX][10]
			Replace X1_DEF01   with aPerg[_nX][11]
			Replace X1_DEF02   with aPerg[_nX][12]
			Replace X1_DEF03   with aPerg[_nX][13]
			Replace X1_DEF04   with aPerg[_nX][14]
	
		SX1->( MsUnlock() )
	EndIf
Next _nX

RestArea( aArea )
	
Return Nil	