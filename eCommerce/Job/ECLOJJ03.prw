#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE DESTIN 1
#DEFINE ENDERE 2
#DEFINE NUMERO 3
#DEFINE IBGE   4
#DEFINE ESTADO 5
#DEFINE MUNICI 6
#DEFINE BAIRRO 7
#DEFINE CEP    8
#DEFINE TELEF1 9
#DEFINE TELEF2 10
#DEFINE CELULA 11
#DEFINE REFERE 12
#DEFINE COMPLE 13
#DEFINE IDENDE 14
#DEFINE CONTAT 15

/**************************************************************************************************/
/*/{Protheus.doc} ECLOJJ03
    @description JOB - Integra novos clientes B2B 
    @type  Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
User Function ECLOJJ03(aParam)
Local _cEmpJob := IIF(ValType(aParam) == "U", "01", aParam[1])  
Local _cFilJob := IIF(ValType(aParam) == "U", "05", aParam[2])

Private _lJob  := IsBlind()

Private _aEMail:= {}

FWLogMsg( "INFO",,"ECLOJJ03","","","","INICIO INTEGRAÇÃO DE CLIENTES B2B " + DTOC( DATE() ) + " AS " + TIME(),,,)

If _lJob
    RPCSetType(3)
    RPCSetEnv(_cEmpJob,_cFilJob)
        EcLojJ03A()
    RpcClearEnv()    
Else 
    FwMsgRun(,{|_oSay| EcLojJ03A(@_oSay)}, "Aguarde...","Validando novos clientes B2B.")
EndIf 

//----------------------------------+
// Envia e-Mail com o Logs de Erros |
//----------------------------------+
If Len(_aEMail) > 0
    u_AEcoMail("B2B","CLIENTES - B2B",_aEMail)
EndIf

FWLogMsg( "INFO",,"ECLOJJ03","","","","FIM INTEGRAÇÃO DE CLIENTES B2B " + DTOC( DATE() ) + " AS " + TIME(),,,)

Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03A
    @description JOB - Valida se existem novos clientes na fila de integração 
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function EcLojJ03A(_oSay)
Local _aArea        := GetArea()

Local _cAlias       := ""
Local _cDocumentID  := ""
Local _cUserId      := ""

Local _oDadosCL     := Nil 
Local _oDadosAD     := Nil 

Local _lCliente     := .F.
Local _lEnderecos   := .F.
Local _lOk          := .F.

Default _oSay       := Nil 

//--------------------------+
// Consulta novos registros |
//--------------------------+
If !EcLojJ03B(@_cAlias)
    FWLogMsg( "INFO",,"ECLOJJ03","","","","NAO EXISTEM DADOS PARA SEREM PROCESSADOS.",,,)
    RestArea(_aArea)
    Return .F.
EndIf 

//-------------------------------+
// Processa fila de clientes B2B |
//-------------------------------+
While (_cAlias)->( !Eof() )

    //-------------------------------------+
    // XTF - Posiciona registro pelo Recno |
    //-------------------------------------+
    XTF->( dbGoTo((_cAlias)->RECNOXTF) )   
    
    //---------------------+
    // Parametros processo | 
    //---------------------+
    _cDocumentID    := RTrim(XTF->XTF_DOCID)
    _cUserId        := ""
    _lCliente       := .F.
    _lEnderecos     := .F.
    _lOk            := .F.
    _oDadosCL       := Nil 
    _oDadosAD       := Nil 

    If !_lJob 
        _oSay:cCaption := "Integrando dados documentID " + RTrim(XTF->XTF_DOCID)
        Processmessages() 
    EndIf 

    FWLogMsg( "INFO",,"ECLOJJ03","","","","INTEGRANDO DADOS DOCUMENTID " + RTrim(XTF->XTF_DOCID),,,)

    //-------------------------------+
    // Localizar cliente master data |
    //-------------------------------+
    EcLojJ03C(_cDocumentID,@_cUserId,@_oDadosCL,@_lCliente)

    //--------------------------------+
    // Localizar endereço master data |
    //--------------------------------+
    If _lCliente
        EcLojJ03D(_cDocumentID,_cUserId,@_oDadosAD,@_lEnderecos)
    EndIf 

    //-------------------------------+
    // Realiza a inclusao do cliente |
    //-------------------------------+
    If _lCliente .And. _lEnderecos
        EcLojJ03E(_cDocumentID,_oDadosCL,_oDadosAD,@_lOk)
    EndIf 

    //--------------------------+
    // Atualiza fila de cliente | 
    //--------------------------+
    If _lOk
        RecLock("XTF",.F.)
            XTF->XTF_DATA := FwTimeStamp(3,Date())
        XTF->( MsUnLock() )
    EndIf 

    (_cAlias)->( dbSkip() )
EndDo 

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03B
    @description Consulta clientes na fila de integração
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
/*/
/**************************************************************************************************/
Static Function EcLojJ03B(_cAlias)
Local _cQuery   := ""

_cQuery := " SELECT " + CRLF
_cQuery += "    R_E_C_N_O_ RECNOXTF " + CRLF
_cQuery += " FROM " + CRLF 
_cQuery += "    " + RetSqlName("XTF") + " " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "    XTF_FILIAL = '" + xFilial("XTF") + "' AND " + CRLF
_cQuery += "    XTF_DATA = '' AND " + CRLF
_cQuery += "    D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
    (_cAlias)->( dbCloseArea() ) 
    Return .F.
EndIf 

Return .T.

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03C
    @description Realzia a consulta do cliente no Master Data
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function EcLojJ03C(_cDocumentID,_cUserId,_oDadosCL,_lCliente)
Local _oMD  := MasterData():New() 

_oMD:cId    := _cDocumentID
_oMD:cMetodo:= "GET"
If _oMD:Customer()
    _lCliente := .T.
    _oDadosCL := JSonObject():New() 
    _oDadosCL:FromJson(_oMD:cJSonRet)
    _cUserId := _oDadosCL[1]['id']
    FWLogMsg( "INFO",,"ECLOJJ03","","","","CLIENTE B2B LOCALIZADO " + _cUserId,,,)
Else
    _lCliente := .F.
    _oDadosCL := Nil 
    FWLogMsg( "INFO",,"ECLOJJ03","","","","ERRO AO INTEGRAR CLIENTE B2B " + _oMD:cError ,,,)
    aAdd(_aEMail,{_cDocumentID, RTrim(_oMD:cError)})
EndIf 


Return Nil 

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03D
    @description Realiza a consulta dos endereços dos clientes
    @type  Static Function
    @author Bernard M Margarido 
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function EcLojJ03D(_cDocumentID,_cUserId,_oDadosAD,_lEnderecos)
Local _oMD  := MasterData():New() 

_oMD:cId    := _cUserId
_oMD:cMetodo:= "GET"
If _oMD:Address()
    _lEnderecos := .T.
    _oDadosAD   := JSonObject():New() 
    _oDadosAD:FromJson(_oMD:cJSonRet)
    FWLogMsg( "INFO",,"ECLOJJ03","","","","ENDERECOS CLIENTE B2B LOCALIZADO " + _oMD:cError ,,,)
Else
    _lEnderecos := .F.
    _oDadosAD   := Nil 
    FWLogMsg( "INFO",,"ECLOJJ03","","","","ERRO AO INTEGRAR ENDERECOS CLIENTE B2B " + _oMD:cError ,,,)
    aAdd(_aEMail,{_cDocumentID, RTrim(_oMD:cError)})
EndIf 

Return Nil 

/**************************************************************************************************/
/*/{Protheus.doc} EcLojJ03E
    @description Insere cliente na base de dados Dana
    @type  Static Function
    @author Bernard M Margarido
    @since 30/06/2023
    @version version
/*/
/**************************************************************************************************/
Static Function EcLojJ03E(_cDocumentID,_oDadosCL,_oDadosAD,_lOk)
Local _aArea            := GetArea() 
Local _aCliente         := {}

Local _cCMunDef	        := GetNewPar("EC_CMUNDE","99999")
Local _cCnpj		    := ""
Local _cCodCli	        := ""
Local _cLoja		    := ""
Local _cNomeCli	        := ""
Local _cTpPess	        := ""   
Local _cTipoCli	        := ""
Local _cContrib	        := ""
Local _cContato	        := "" 
Local _cInscE	        := ""
Local _cEnd		        := ""
Local _cNumEnd	        := ""
Local _cBairro	        := ""
Local _cMun		        := ""
Local _cCep		        := ""
Local _cEst		        := ""
Local _cCodMun	        := ""
Local _cEndC		    := ""
Local _cNumEndC	        := ""
Local _cBairroC	        := ""
Local _cMunC		    := ""
Local _cCepC		    := ""
Local _cEstC		    := ""
Local _cEndE		    := ""
Local _cNumEndE	        := ""
Local _cBairroE	        := ""
Local _cMunE		    := ""
Local _cCepE		    := ""
Local _cEstE		    := "" 
Local _cAtivo           := "S"
Local _cTpCli           := "5"
Local _cTpFret          := "F"
Local _cSuframa         := "N"
Local _cBaseRed         := "N"
Local _cCond            := "001"
Local _cLeadFat         := "2"
Local _cRegEsp          := "2"
Local _cClassif         := "001"    
Local _cAceSaldo        := "2"
Local _cFimPPe          := "2"

Local _nX               := 0 
Local _nLeadTi          := 1
Local _nFatorPr         := 1
Local _nOpcA            := 0
Local _nTCGC            := TamSx3("A1_CGC")[1]
Local _nTCodCli         := TamSx3("A1_COD")[1]
Local _nTTel            := TamSx3("A1_TEL")[1]
Local _nTContato		:= TamSx3("A1_CONTATO")[1]

Local _oCliente         := _oDadosCL[1]
Local _oEndereco        := _oDadosAD

Private lMsErroAuto     := .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile 	:= .T.

//---------------------+
// Cnpj/Cpf do cliente |
//---------------------+    
If _oCliente['isCorporate']
	_cCnpj 	:= PadR(u_ECFORMAT(_oCliente['corporateDocument'],"A1_CGC",.T.),_nTCGC)
	_cTpPess := "J"
	_cTipoCli:= "R"
Else
	_cCnpj 	:= PadR(u_ECFORMAT(_oCliente['document'],"A1_CGC",.T.),_nTCGC) 
	_cTpPess := "F"
	_cTipoCli:= "F"	  
EndIf	

//----------------------------------------------------------+
// Valida se cliente ja existe na base de dados do Protheus |
//----------------------------------------------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(3) )
If SA1->( dbSeek(xFilial("SA1") + _cCnpj ) )
	_cCodCli := SA1->A1_COD
	_cLoja	:= SA1->A1_LOJA
	_nOpcA 	:= 4

    FWLogMsg( "INFO",,"ECLOJJ03","","","","ATUALIZACAO DO CLIENTE " + RTRIM(SA1->A1_NOME) ,,,)

Else
	_cCodCli    := GetSxeNum("SA1","A1_COD")
	_cLoja	    := "01"
	SA1->( dbSetOrder(1) )
	While SA1->( dbSeek(xFilial("SA1") + PadR(_cCodCli,_nTCodCli) + _cLoja ) )
		ConfirmSx8()
		_cCodCli    := GetSxeNum("SA1","A1_COD","",1)
	EndDo	
	_nOpcA := 3

    FWLogMsg( "INFO",,"ECLOJJ03","","","","INCLUINDO NOVO CLIENTE B2B." ,,,)

EndIf

//--------------------------+
// Dados passados pela Vtex |
//--------------------------+ 
If _oCliente['isCorporate']
	_cNomeCli	:= IIF(_nOpcA == 3,	Alltrim(u_ECACENTO(_oCliente['corporateName'],.T.))	                                                    , SA1->A1_NOME 		) 
	_cNReduz	:= IIF(_nOpcA == 3,	Alltrim(u_ECACENTO(_oCliente['tradeName'],.T.))		                                                    , SA1->A1_NREDUZ	)
	_cContato	:= IIF(_nOpcA == 3,	PadR(u_ECACENTO(_oCliente['firstName'],.T.) + " " + u_ECACENTO(_oCliente['lastName'],.T.),_nTContato)   , SA1->A1_CONTATO	)	
	_cDdd01		:= IIF(_nOpcA == 3,	SubStr(_oCliente['businessPhone'],4,2)							                                        , SA1->A1_DDD		)
	_cTel01		:= IIF(_nOpcA == 3,	StrTran(SubStr(_oCliente['businessPhone'],6,_nTTel)," ","")		                                        , SA1->A1_TEL		)
	_cInscE		:= IIF(_nOpcA == 3,	IIF( Type("_oCliente['stateInscription']") <> "U", Upper(_oCliente['stateInscription']), "ISENTO")	    , SA1->A1_INSCR		)

    If _nOpcA == 3
        If ValType(_cInscE) == "U" .Or. Alltrim(_cInscE) == "ISENTO"  
            _cContrib := "2"
        Else 
            _cContrib := "1"
        EndIf 
    Else 
        _cContrib := SA1->A1_CONTRIB
    EndIf 

Else	
	
	_cNomeCli	:= IIF(_nOpcA == 3,	Alltrim(u_ECACENTO(_oCliente['firstName'],.T.)) + " " + Alltrim(u_ECACENTO(_oCliente['lastName'],.T.))	, SA1->A1_NOME 		)
	_cNReduz	:= IIF(_nOpcA == 3,	Alltrim(u_ECACENTO(_oCliente['firstName'],.T.)) + " " + Alltrim(u_ECACENTO(_oCliente['lastName'],.T.))	, SA1->A1_NREDUZ	)
	_cDdd01		:= IIF(_nOpcA == 3,	SubStr(_oCliente['phone'],4,2)										                                    , SA1->A1_DDD		)
	_cTel01		:= IIF(_nOpcA == 3,	SubStr(_oCliente['phone'],6,_nTTel) 								                                    , SA1->A1_TEL		)
	_cContrib	:= IIF(_nOpcA == 3,	"2"																                                        , SA1->A1_CONTRIB	)
	_cNomeCli	:= Alltrim(_cNomeCli)
	_cNReduz	:= Alltrim(_cNReduz)

EndIf

_cEmail			:= IIF(_nOpcA == 3,	Alltrim(_oCliente['email'])										                                        , SA1->A1_EMAIL		)

//----------------+
// Dados Endereço |
//----------------+
_aEndRes	:= {}
_aEndCob	:= {}
_aEndEnt	:= {}
EcRetEnd(_oEndereco,@_aEndRes,@_aEndCob,@_aEndEnt)

//-----------+
// Enderecos |
//-----------+
If Len(_aEndRes) > 0 
	_cEnd		:= _aEndRes[ENDERE]
	_cNumEnd	:= _aEndRes[NUMERO]
	_cBairro	:= _aEndRes[BAIRRO]
	_cMun		:= _aEndRes[MUNICI]	
	_cCep		:= _aEndRes[CEP]
	_cEst		:= _aEndRes[ESTADO]
	_cCodMun	:= _aEndRes[IBGE]
ElseIf Len(_aEndEnt) > 0		
	_cEnd		:= _aEndEnt[ENDERE]
	_cNumEnd	:= _aEndEnt[NUMERO]
	_cBairro	:= _aEndEnt[BAIRRO]
	_cMun		:= _aEndEnt[MUNICI]	
	_cCep		:= _aEndEnt[CEP]
	_cEst		:= _aEndEnt[ESTADO]
	_cCodMun	:= _aEndEnt[IBGE]
EndIf

//----------------------+
// Endereco de Cobranca | 
//----------------------+
If Len(_aEndCob) > 0	
	_cEndC		:= _aEndCob[ENDERE]
	_cNumEndC	:= _aEndCob[NUMERO]
	_cBairroC	:= _aEndCob[BAIRRO]
	_cMunC		:= _aEndCob[MUNICI]
	_cCepC		:= _aEndCob[CEP]
	_cEstC		:= _aEndCob[ESTADO]
ElseIf Len(_aEndRes) > 0
	_cEndC		:= _aEndRes[ENDERE]
	_cNumEndC	:= _aEndRes[NUMERO]
	_cBairroC	:= _aEndRes[BAIRRO]
	_cMunC		:= _aEndRes[MUNICI]
	_cCepC		:= _aEndRes[CEP]
	_cEstC		:= _aEndRes[ESTADO]	
EndIf

//---------------------+
// Endereco de Entrega |
//---------------------+
If Len(_aEndEnt) > 0		
	_cEndE		:= _aEndEnt[ENDERE]
	_cNumEndE	:= _aEndEnt[NUMERO]
	_cBairroE	:= _aEndEnt[BAIRRO]
	_cMunE		:= _aEndEnt[MUNICI]
	_cCepE		:= _aEndEnt[CEP]
	_cEstE		:= _aEndEnt[ESTADO]
ElseIf Len(_aEndRes) > 0
	_cEndE		:= _aEndRes[ENDERE]
	_cNumEndE	:= _aEndRes[NUMERO]
	_cBairroE	:= _aEndRes[BAIRRO]
	_cMunE		:= _aEndRes[MUNICI]
	_cCepE		:= _aEndRes[CEP]
	_cEstE		:= _aEndRes[ESTADO]
EndIf

//--------------------------------------+
// Cria Array para cadastro de clientes |
//--------------------------------------+
aAdd(_aCliente , {"A1_FILIAL"    ,   xFilial("SA1")							,	Nil	})
aAdd(_aCliente , {"A1_COD"		,	_cCodCli								,	Nil	})
aAdd(_aCliente , {"A1_LOJA"		,	_cLoja									,	Nil	})
aAdd(_aCliente , {"A1_PESSOA"	,	_cTpPess								,	Nil	})
aAdd(_aCliente , {"A1_NOME"		,	_cNomeCli								,	Nil	})
aAdd(_aCliente , {"A1_NREDUZ"	,	_cNReduz								,	Nil	})

If _nOpcA == 3
	aAdd(_aCliente , {"A1_END"		,	_cEnd + ", " + _cNumEnd				,	Nil	})
	aAdd(_aCliente , {"A1_EST"		,	_cEst								,	Nil	})
	aAdd(_aCliente , {"A1_COD_MUN"	,	_cCodMun							,	Nil	})
	aAdd(_aCliente , {"A1_MUN"		,	_cMun								,	Nil	})
	aAdd(_aCliente , {"A1_BAIRRO"	,	_cBairro							,	Nil	})
	aAdd(_aCliente , {"A1_CEP"		,	_cCep								,	Nil	})
EndIf	

aAdd(_aCliente , {"A1_ENDCOB"	,	_cEndC + ", " + _cNumEndC				,	Nil	})
aAdd(_aCliente , {"A1_ESTCOB"	,	_cEstC									,	Nil	})
aAdd(_aCliente , {"A1_MUNCOB"	,	_cMunC									,	Nil	})
aAdd(_aCliente , {"A1_BAIRROC"	,	_cBairroC								,	Nil	})
aAdd(_aCliente , {"A1_CEPCOB"	,	_cCepC									,	Nil	})  
aAdd(_aCliente , {"A1_ENDENT"	,	_cEndE + ", " + _cNumEndE				,	Nil	})
aAdd(_aCliente , {"A1_ESTE"		,	_cEstE									,	Nil	})
aAdd(_aCliente , {"A1_MUNE"		,	_cMunE									,	Nil	})
aAdd(_aCliente , {"A1_BAIRROE"	,	_cBairroE								,	Nil	})
aAdd(_aCliente , {"A1_CEPE"		,	_cCepE									,	Nil	})
aAdd(_aCliente , {"A1_TIPO"		,	_cTipoCli								,	Nil	})
aAdd(_aCliente , {"A1_DDD"		,	_cDdd01									,	Nil	})
aAdd(_aCliente , {"A1_TEL"		,	_cTel01									,	Nil	})
aAdd(_aCliente , {"A1_PAIS"		,	"105"									,	Nil	})
aAdd(_aCliente , {"A1_CGC"		,	_cCnpj									,	Nil	})
aAdd(_aCliente , {"A1_EMAIL"	,	_cEmail								    ,	Nil	})
aAdd(_aCliente , {"A1_DTNASC"	,	dDataBase								,	Nil	})
aAdd(_aCliente , {"A1_CONTRIB"	,	_cContrib								,	Nil	})  
aAdd(_aCliente , {"A1_CONTATO"	,	_cContato								,	Nil	})  

//---------------------------+
// Valida Inscricao estadual |
//---------------------------+
If _oCliente['isCorporate']
  	If !IE(_cInscE,_aEndRes[ESTADO],.F.)
		FWLogMsg( "INFO",,"ECLOJJ03","","","","INSCRICAO ESTADUAL INVALIDA PARA O ESTADO " + _aEndRes[ESTADO] ,,,)
        aAdd(_aEMail,{_cDocumentID, "INSCRICAO ESTADUAL INVALIDA PARA O ESTADO " + _aEndRes[ESTADO]})
		RestArea(aArea)
		Return .F.
	EndIf
EndIf	
	
//-----------------------------------------------+
// Grava Incsrição estadual para pessoa Juridica |
//-----------------------------------------------+
If _oCliente['isCorporate']
	aAdd(_aCliente , {"A1_INSCR"	,	Alltrim(_cInscE)						,	"AllWaysTrue()"	})
Else
	aAdd(_aCliente , {"A1_INSCR"	,	Alltrim("ISENTO")						,	"AllWaysTrue()"	})
EndIf

//----------------------------------------------+
// Caso pedido de venda seja outros             |
// o cliente será criado com risco de credito E |
//----------------------------------------------+
aAdd(_aCliente , {"A1_RISCO"	 ,   "E" 									 ,	Nil	})
aAdd(_aCliente , {"A1_CODPAIS"	 ,   "01058"								 ,	Nil	})
aAdd(_aCliente , {"A1_XMAILEC"	 ,   _cEmail								 ,	Nil	})
aAdd(_aCliente , {"A1_ATIVO"     ,   _cAtivo                                 ,  Nil })
aAdd(_aCliente , {"A1_XTIPCLI"   ,   _cTpCli                                 ,  Nil })
aAdd(_aCliente , {"A1_TPFRET"    ,   _cTpFret                                ,  Nil })
aAdd(_aCliente , {"A1_CALCSUF"   ,   _cSuframa                               ,  Nil })
aAdd(_aCliente , {"A1_BASERED"   ,   _cBaseRed                               ,  Nil })
aAdd(_aCliente , {"A1_COND"      ,   _cCond                                  ,  Nil })
aAdd(_aCliente , {"A1_XLEADFA"   ,   _cLeadFat                               ,  Nil })
aAdd(_aCliente , {"A1_XLEADTI"   ,   _nLeadTi                                ,  Nil })
aAdd(_aCliente , {"A1_XREGESP"   ,   _cRegEsp                                ,  Nil })
aAdd(_aCliente , {"A1_CLASSIF"   ,   _cClassif                               ,  Nil })
aAdd(_aCliente , {"A1_XACESAL"   ,   _cAceSaldo                              ,  Nil })
aAdd(_aCliente , {"A1_FATORPR"   ,   _nFatorPr                               ,  Nil })
aAdd(_aCliente , {"A1_XFIMPPE"   ,   _cFimPPe                                ,  Nil })

//--------------------------+
// Ordena pela ordem do SX3 |
//--------------------------+
_aCliente := FWVetByDic(_aCliente, "SA1")

If Len(_aCliente) > 0 
    lMsErroAuto             := .F.

    If MA030IsMVC()
        SetFunName('CRMA980')
        MSExecAuto( { |x, y| CRMA980(x,y) },  _aCliente, _nOpcA )
    Else
        SetFunName('MATA030')
        MsExecAuto({|x,y| Mata030(x,y)}, _aCliente, _nOpcA)
    EndIf

    If lMsErroAuto
        
        RollBackSx8()

        _aErro 	    := GetAutoGrLog()
        _cError     := ""
        _lOk        := .F.
        For _nX := 1 To Len(_aErro)
            _cError += _aErro[_nX] + CRLF
        Next nX

        FWLogMsg( "INFO",,"ECLOJJ03","","","","ERRO: " + _cError ,,,)

        aAdd(_aEMail,{_cDocumentID, "ERRO: " + _cError})

    Else 

        //-----------------------------+
		// Reseta variavel da ExecAuto |
		//-----------------------------+
		ConfirmSx8()

        _lOk    := .T.

		//----------------------------------------+
		// Grava endereço de entrega nos contatos |
		//----------------------------------------+
		If Len(_aEndEnt) > 0 .Or. Len(_aEndRes) > 0
			EcLojJ03G(_cCodCli,_cLoja,_cNomeCli,IIF(Len(_aEndEnt) > 0, _aEndEnt, _aEndRes))
		Endif
		
		//------------------------------------+
		// Envia e-Mail com erro de municipio |
		//------------------------------------+	
		If Rtrim(_cCodMun) == RTrim(_cCMunDef)
			u_AEcMailC("B2B","CLIENTES - B2B",_cCnpj,_cNomeCli)
		EndIf
		
		//--------------------+
		// Desloqueia Cliente |
		//--------------------+
		RecLock("SA1",.F.)
			SA1->A1_MSBLQL := "2"
		SA1->( MsUnLock() )

        FWLogMsg( "INFO",,"ECLOJJ03","","","","CLIENTE " + _cCodCli + " LOJA " + _cLoja + " INSERIDO COM SUCESSO. "  ,,,)

    EndIf 

EndIf 

RestArea(_aArea)
Return Nil 

/***************************************************************************************/
/*/{Protheus.doc} EcRetEnd
	@description Valida os endereços cadastrados pelo o cliente
	@author Bernard M. Margarido
	@since 30/01/2017
	@version undefined
	@type function
/*/
/***************************************************************************************/
Static Function EcRetEnd(_oEndereco,aEndRes,aEndCob,aEndEnt)

Local _nX		:= 0

//-------------------+
// Tipos de Endereco |
// 1 - Residencial   |
// 2 - Entrega       |
// 3 - Cobranca      |
//-------------------+
	
//------------------------+
// Valida tipo  de Objeto |
//------------------------+
If ValType(_oEndereco) == "O" 
	If SubStr(Upper(_oEndereco['addressType']),1,3) == "RES"
		aEndRes := EcLoadEnd(_oEndereco)
	ElseIf SubStr(Upper(_oEndereco['addressType']),1,3) == "COB"
		aEndEnt := EcLoadEnd(_oEndereco)
	ElseIf SubStr(Upper(_oEndereco['addressType']),1,3) == "COM"
		aEndCob := EcLoadEnd(_oEndereco)
	ElseIf SubStr(Upper(_oEndereco['addressType']),1,3) == "IND"
		aEndRes := EcLoadEnd(_oEndereco)
	EndIf	
ElseIf ValType(_oEndereco) == "J" .And. Len(_oEndereco) > 0 
	For _nX := 1 To Len(_oEndereco)
		If SubStr(Upper(_oEndereco[_nX]['addressType']),1,3) == "RES"
			aEndRes := EcLoadEnd(_oEndereco[_nX])
		ElseIf SubStr(Upper(_oEndereco[_nX]['addressType']),1,3) == "COB"
			aEndEnt := EcLoadEnd(_oEndereco[_nX])
		ElseIf SubStr(Upper(_oEndereco[_nX]['addressType']),1,3) == "COM"
			aEndCob := EcLoadEnd(_oEndereco[_nX])
		ElseIf SubStr(Upper(_oEndereco[_nX]['addressType']),1,3) == "IND"
			aEndRes := EcLoadEnd(_oEndereco[_nX])
		EndIf
	Next _nX
EndIf

Return .T.

/****************************************************************************/
/*/{Protheus.doc} EcLoadEnd
	@description Carrega os enderecos cadastrados
	@author Bernard M. Margarido
	@since 30/01/2017
	@version undefined
	@type function
/*/
/****************************************************************************/
Static Function EcLoadEnd(_oEndereco)
Local _aRet			:= {}
Local _cMunicipio	:= ""
Local _cEstado		:= ""
Local _cComplem		:= ""
Local _cPais		:= ""
Local _cBairro		:= ""
Local _cNumero		:= ""
Local _cCep			:= ""
Local _cDesti		:= ""
Local _cReferen		:= ""
Local _cEnd			:= ""
Local _cIdEnd		:= ""

//------------------------------------+
// Acerta endereço no padrao protheus |
//------------------------------------+
_cMunicipio	:= IIF(ValType(_oEndereco['city']) <> "U", AllTrim(u_ECACENTO(_oEndereco['city'],.T.)), "")
If ValType(_oEndereco['state']) <> "U" .And. Len(Alltrim(_oEndereco['state'])) > 2
	_cEstado 	:= EcLojJ03F(_oEndereco['state'])
Else 
	_cEstado	:= IIF(ValType(_oEndereco['state']) <> "U", Upper(_oEndereco['state']), "")
EndIf 

_cComplem	:= IIF(ValType(_oEndereco['complement']) <> "U", AllTrim(u_ECACENTO(_oEndereco['complement'],.T.)), "")
_cPais		:= IIF(ValType(_oEndereco['country']) <> "U", _oEndereco['country'], "")
_cBairro	:= IIF(ValType(_oEndereco['neighborhood']) <> "U", AllTrim(u_ECACENTO(_oEndereco['neighborhood'],.T.)), "")
_cNumero	:= IIF(ValType(_oEndereco['number']) <> "U", _oEndereco['number'], "")
_cCep		:= IIF(ValType(_oEndereco['postalCode']) <> "U", u_ECFORMAT(_oEndereco['postalCode'],"A1_CEP",.T.), "")
_cDesti		:= IIF(ValType(_oEndereco['receiverName']) <> "U", AllTrim(u_ECACENTO(_oEndereco['receiverName'],.T.)), "")
_cReferen	:= IIF(ValType(_oEndereco['reference']) <> "U", AllTrim(u_ECACENTO(_oEndereco['reference'],.T.)), "")
_cEnd		:= IIF(ValType(_oEndereco['street']) <> "U", AllTrim(u_ECACENTO(_oEndereco['street'],.T.)), "")
_cIdEnd		:= IIF(ValType(_oEndereco['id']) <> "U", _oEndereco['id'], "")
_cContato	:= IIF(ValType(_oEndereco['receiverName']) <> "U", AllTrim(u_ECACENTO(_oEndereco['receiverName'],.T.)), "")

_aRet 		:= Array(15) 

_cIbge		:= EcCodMun(_cEstado,_cMunicipio) 
		
_aRet[DESTIN]	:= _cDesti
_aRet[ENDERE]	:= _cEnd 
_aRet[NUMERO]	:= _cNumero
_aRet[IBGE]		:= _cIbge
_aRet[ESTADO]	:= _cEstado
_aRet[MUNICI]	:= _cMunicipio
_aRet[BAIRRO]	:= IIF(Empty(_cBairro), "S/BAIRRO", _cBairro)
_aRet[CEP]		:= _cCep
_aRet[TELEF1]	:= ""
_aRet[TELEF2]	:= ""
_aRet[CELULA]	:= ""
_aRet[REFERE]	:= _cReferen
_aRet[COMPLE]	:= _cComplem
_aRet[IDENDE]	:= _cIdEnd
_aRet[CONTAT]	:= _cContato

Return _aRet

/***********************************************************************************/
/*/{Protheus.doc} EcLojJ03F
	@description Retorna sigla do estoque de acordo com o nome
	@type  Static Function
	@author Bernard M Margarido
	@since 11/10/2022
	@version version
/*/
/***********************************************************************************/
Static Function EcLojJ03F(_cEstado)
Local _cNome := FWNoAccent(Upper(DecodeUTF8(_cEstado)))
Local _cQuery:= ""
Local _cAlias:= ""
Local _cUF 	 := ""

_cQuery := " SELECT " + CRLF
_cQuery += "	X5_CHAVE " + CRLF
_cQuery += " FROM " + CRLF
_cQuery += "	" + RetSqlName("SX5") + " " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += "	X5_TABELA = '12' AND " + CRLF
_cQuery += "	X5_DESCRI LIKE '%" + _cNome + "%' AND " + CRLF
_cQuery += "	D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

_cUF 	:= PadR((_cAlias)->X5_CHAVE,_nTEst)

Return _cUF 

/***********************************************************************************/
/*/{Protheus.doc} EcCodMun
	@description Retorna codigo do municipio
	@author Bernard M. Margarido
	@since 30/01/2017
	@version undefined
	@type function
/*/
/***********************************************************************************/
Static Function EcCodMun(_cEstado,_cMunicipio)
Local _aArea		:= GetARea()

Local _cAlias	    := GetNextAlias()
Local _cQuery	    := ""
Local _cIbge		:= ""
Local _cCMunDef	    := GetNewPar("EC_CMUNDE","99999")

Local _lAtMunDef    := GetNewPar("EC_ATMUNDE",.T.)

If At("(",_cMunicipio) > 0
	_cMunicipio := SubStr(_cMunicipio,1,At("(",_cMunicipio) -1)
EndIf

If At("'",_cMunicipio) > 0
	_cMunicipio := StrTran(_cMunicipio,"'","''")
EndIf

//-----------------------------+
// Cosulta codigo de municipio |
//-----------------------------+
_cQuery := "	SELECT " + CRLF 
_cQuery += "		CC2_CODMUN " + CRLF 
_cQuery += "	FROM " + CRLF 
_cQuery += "		" + RetSqlName("CC2") + CRLF   
_cQuery += "	WHERE " + CRLF 
_cQuery += "		CC2_FILIAL = '" + xFilial("CC2") + "' AND " + CRLF 
_cQuery += "		CC2_EST = '" + _cEstado + "' AND " + CRLF 
_cQuery += "		CC2_MUN = '" + _cMunicipio + "' AND " + CRLF 
_cQuery += "		D_E_L_E_T_ <> '*' " 

_cAlias := MPSysOpenQuery(_cQuery)

If (_cAlias)->( Eof() )
	If _lAtMunDef
		dbSelectArea("CC2")
		CC2->( dbSetOrder(1) )
		If CC2->( dbSeek(xFilial("CC2") + _cEstado + _cCMunDef) )
			_cIbge	:= CC2->CC2_CODMUN
		Else
			//-------------------------+
			// Grava Municipio Default |
			//-------------------------+
			RecLock("CC2",.T.)
				CC2->CC2_FILIAL := xFilial("CC2")
				CC2->CC2_EST   	:= cEstado
				CC2->CC2_CODMUN	:= _cCMunDef
				CC2->CC2_MUN   	:= cMunicipio
				CC2->CC2_MDEDMA	:= CriaVar("CC2_MDEDMA",.F.)
				CC2->CC2_MDEDSR	:= CriaVar("CC2_MDEDSR",.F.)
				CC2->CC2_PERMAT	:= CriaVar("CC2_PERMAT",.F.)
				CC2->CC2_PERSER	:= CriaVar("CC2_PERSER",.F.)
				CC2->CC2_DTRECO	:= CriaVar("CC2_DTRECO",.F.)
				CC2->CC2_CDSIAF	:= CriaVar("CC2_CDSIAF",.F.)
				CC2->CC2_CPOM  	:= CriaVar("CC2_CPOM  ",.F.)
				CC2->CC2_TPDIA 	:= CriaVar("CC2_TPDIA ",.F.)
				CC2->CC2_CODANP	:= CriaVar("CC2_CODANP",.F.)
			CC2->( MsUnLock() )
			_cIbge	:= _cCMunDef
		EndIf
		
	EndIf
Else
	_cIbge := (_cAlias)->CC2_CODMUN
EndIf

(_cAlias)->( dbCloseArea() )	

RestArea(_aArea)
Return _cIbge 

/*******************************************************************************************/
/*/{Protheus.doc} EcLojJ03G
	@description Grava endereço de entrega nos contatos
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function EcLojJ03G(cCodCli,cLoja,cNomeCli,aEndEnt)
Local _aArea	:= GetArea()

Local _lGrava	:= .T.

Local _cEnd		:= ""
Local _cNumEnd	:= ""
Local _cBairro	:= ""
Local _cMun		:= ""
Local _cCep		:= ""
Local _cEst		:= ""
Local _cCodMun	:= ""
Local _cNumSU5	:= ""
Local _cIdEnd	:= ""
Local _cContato	:= ""

Local _nRecnoSU5:= 0

//-------------------+
// Posiciona Cliente |
//-------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1") + cCodCli + cLoja) )

_cEnd		:= aEndEnt[ENDERE]
_cNumEnd	:= aEndEnt[NUMERO]
_cBairro	:= aEndEnt[BAIRRO]
_cMun		:= aEndEnt[MUNICI]	
_cCep		:= aEndEnt[CEP]
_cEst		:= aEndEnt[ESTADO]
_cCodMun	:= aEndEnt[IBGE]
_cIdEnd		:= aEndEnt[IDENDE]
_cContato	:= aEndEnt[CONTAT]

_nRecnoSU5 	:= QryContato(_cCep)
			
//----------------------------+
// Posiciona dados do contato |
//----------------------------+
If _nRecnoSU5 > 0

	SU5->( dbGoTo(_nRecnoSU5) )
	_cNumSU5:= SU5->U5_CODCONT
	_lGrava	:= .F.

Else

	dbSelectArea("SU5")
	SU5->( dbSetOrder(1) )
	_cNumSU5 := GetSxeNum("SU5","U5_CODCONT")
	While SU5->( dbSeek(xFilial("SU5") + _cNumSU5 ) )
		ConfirmSx8()
		_cNumSU5 := GetSxeNum("SU5","U5_CODCONT")
	EndDo
	_lGrava := .T.

EndIf

//------------------+
// Atualiza Contato |
//------------------+	
RecLock("SU5",_lGrava)
	SU5->U5_FILIAL	:= xFilial("SU5")
	SU5->U5_CODCONT := _cNumSU5
	SU5->U5_CONTAT  := RTrim(_cContato)
	SU5->U5_EMAIL   := RTrim(SA1->A1_EMAIL)
	SU5->U5_CPF		:= RTrim(SA1->A1_CGC)
	SU5->U5_END		:= _cEnd + ", " + _cNumEnd
	SU5->U5_BAIRRO	:= _cBairro
	SU5->U5_MUN		:= _cMun
	SU5->U5_EST		:= _cEst
	SU5->U5_CEP		:= _cCep
	SU5->U5_DDD		:= RTrim(SA1->A1_DDD)
	SU5->U5_FONE	:= RTrim(SA1->A1_TEL)
	SU5->U5_CELULAR := RTrim(SA1->A1_TEL)
	SU5->U5_ATIVO	:= "1"
	SU5->U5_STATUS	:= "2"
	SU5->U5_XIDEND	:= _cIdEnd
	SU5->U5_MSBLQL	:= "2"
SU5->(MsUnLock())

//-----------------------------+
// Amarração Contato X Cliente |
//-----------------------------+
dbSelectArea("AC8")
AC8->( dbSetOrder(1) )
If !AC8->( dbSeek(xFilial("AC8") + _cNumSU5 + "SA1" + xFilial("SA1") + cCodCli + cLoja ) )
	RecLock("AC8",.T.)
		AC8->AC8_FILIAL := xFilial("AC8")
		AC8->AC8_FILENT	:= xFilial("SA1")
		AC8->AC8_ENTIDA := "SA1"
		AC8->AC8_CODENT	:= cCodCli + cLoja
		AC8->AC8_CODCON	:= _cNumSU5
	AC8->( MsUnLock() )	
EndIf 
		
//-------------------+
// Atualiza Endereço |
// Entrega			 |
//-------------------+	
EcLojJ03H(_cNumSU5,aEndEnt)


RestArea(_aArea)
Return Nil

/*******************************************************************************************/
/*/{Protheus.doc} QryContato
	@description Valida se já existe contato salvo
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function QryContato(_cCep)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local nRecno := 0		

cQuery := "	SELECT " + CRLF
cQuery += "		U5.R_E_C_N_O_ RECNOSU5 " + CRLF
cQuery += "	FROM " + CRLF
cQuery += "		" + RetSqlName("SU5") + " U5 " + CRLF 
cQuery += "	WHERE " + CRLF
cQuery += "		U5.U5_FILIAL = '" + xFilial("SU5") + "' AND " + CRLF
cQuery += "		U5.U5_CEP = '" + _cCep + "' AND " + CRLF
cQuery += "		U5.D_E_L_E_T_ = '' " + CRLF

cAlias := MPSysOpenQuery(cQuery)

nRecno := (cAlias)->RECNOSU5 

(cAlias)->( dbCloseArea() )

Return nRecno

/*******************************************************************************************/
/*/{Protheus.doc} EcLojJ03H
	@description Grava dados de entrega AGA
	@type  Static Function
	@author Bernard M. Margarido
	@since 22/05/2019
/*/
/*******************************************************************************************/
Static Function EcLojJ03H(_cNumSU5,aEndEnt)
Local _cCodEnd	:= ""
Local _cEnd		:= ""
Local _cNumEnd	:= ""
Local _cBairro	:= ""
Local _cMun		:= ""
Local _cCep		:= ""
Local _cEst		:= ""
Local _cCodMun	:= ""
Local _cIdEnd	:= ""

Local _lGrava	:= .F.

_cEnd		:= aEndEnt[ENDERE]
_cNumEnd	:= aEndEnt[NUMERO]
_cBairro	:= aEndEnt[BAIRRO]
_cMun		:= aEndEnt[MUNICI]	
_cCep		:= aEndEnt[CEP]
_cEst		:= aEndEnt[ESTADO]
_cCodMun	:= aEndEnt[IBGE]
_cIdEnd		:= aEndEnt[IDENDE]

//---------------------------+
// Valida se existe endereço |
//---------------------------+
_lGrava := AEcoVldAga(_cIdEnd)

If _lGrava
	_cCodEnd := GetSxeNum("AGA","AGA_CODIGO")
	While AGA->( dbSeek(xFilial("AGA") + _cCodEnd ) )
		ConfirmSx8()
		_cCodEnd := GetSxeNum("AGA","AGA_CODIGO")
	EndDo
	RecLock("AGA", _lGrava)
		AGA->AGA_FILIAL := xFilial("AGA")
		AGA->AGA_CODIGO	:= _cCodEnd
		AGA->AGA_ENTIDA	:= "SU5"					
		AGA->AGA_CODENT	:= _cNumSU5
		AGA->AGA_XIDEND	:= _cIdEnd
		AGA->AGA_TIPO 	:= "2"
		AGA->AGA_PADRAO	:= "1"
		AGA->AGA_END	:= _cEnd + ", " + _cNumEnd
		AGA->AGA_BAIRRO	:= _cBairro
		AGA->AGA_MUNDES	:= _cMun
		AGA->AGA_MUN    := _cCodMun
		AGA->AGA_EST	:= _cEst
		AGA->AGA_CEP	:= _cCep
		AGA->AGA_PAIS	:= "105"  
	AGA->(MsUnLock())
EndIf	
	
Return Nil

/*******************************************************************************************/
/*/{Protheus.doc} AEcoVldAga
	@description Valida se endereço já está cadastrado 
	@type  Static Function
	@author Bernard M. Margarido
	@since 27/05/2019
/*/
/*******************************************************************************************/
Static Function AEcoVldAga(_cIdEnd)
Local _aArea 	:= GetArea()

Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""

Local _lRet		:= .T.

_cQuery	:= " SELECT " + CRLF 
_cQuery	+= "	AGA.AGA_CODIGO " + CRLF
_cQuery	+= " FROM " + CRLF
_cQuery	+= "	" + RetSqlName("AGA") + " AGA " + CRLF 
_cQuery	+= " WHERE " + CRLF
_cQuery	+= "	AGA.AGA_FILIAL = '" + xFilial("AGA") + "' AND " + CRLF 
_cQuery	+= "	AGA.AGA_XIDEND = '" + _cIdEnd + "' AND " + CRLF
_cQuery	+= "	AGA.D_E_L_E_T_ = '' "

_cAlias := MPSysOpenQuery(_cQuery)

If !Empty((_cAlias)->AGA_CODIGO)
	_lRet := .F.
EndIf

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return _lRet 
