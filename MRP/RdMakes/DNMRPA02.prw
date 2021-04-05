#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*****************************************************************************************************/
/*/{Protheus.doc} DNMRPA02
    @description Cadastro de Filiais de Abastecimento
    @type  Function
    @author Bernard M. Margarido
    @since 29/03/2021
/*/
/*****************************************************************************************************/
User Function DNMRPA02()
Private _nOldLen := SetVarNameLen(255) 
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()
//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("XT5")
//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "XT5_STATUS == '1'", "GREEN"    , "Ativo" )
_oBrowse:AddLegend( "XT5_STATUS == '2'", "RED"      , "Inativo" )
//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('MRP - Filais de Abastecimento')
//--------------------+
// Ativação do Browse |
//--------------------+
_oBrowse:Activate()
SetVarNameLen(_nOldLen)
Return Nil 

/************************************************************************************/
/*/{Protheus.doc} ModelDef
@description  Modelo de dados, estrutura dos dados e modelo de negocio
@author Bernard M. Margarido
@since 10/08/2017
@version undefined
@type function
/*/
/************************************************************************************/
Static Function ModelDef()
Local _oModel		:= Nil
Local _oStruXT5     := FWFormStruct(1,"XT5")

Local _bCommit      := {|_oModel| DnMrp02A(_oModel)}

//--------------------+
// Gatilho Nome Filial|
//--------------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'/*cIdField*/ ,;
                        'XT5_NOME'  /*cTargetIdField*/ ,;  
                        { || .T. }  /*bPre*/ ,;
                        { |_oModel| Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_NOME") } /*bSetValue*/ )

//-----------------+
// Gatilho Nome CGC|
//-----------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'/*cIdField*/ ,;
                        'XT5_CGC'   /*cTargetIdField*/ ,;  
                        { || .T. }  /*bPre*/ ,;
                        { |_oModel| Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_CGC") } /*bSetValue*/ )

//--------------------+
// Gatilho Nome Filial|
//--------------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'    /*cIdField*/ ,;
                        'XT5_INSCR'     /*cTargetIdField*/ ,;  
                        { || .T. }      /*bPre*/ ,;
                        { |_oModel| Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_INSC") } /*bSetValue*/ )

//--------------------+
// Gatilho Nome Filial|
//--------------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'/*cIdField*/ ,;
                        'XT5_END'   /*cTargetIdField*/ ,;  
                        { || .T. }  /*bPre*/ ,;
                        { |_oModel| RTrim(Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_ENDCOB")) } /*bSetValue*/ )

//--------------------+
// Gatilho Nome Filial|
//--------------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'    /*cIdField*/ ,;
                        'XT5_BAIRRO'    /*cTargetIdField*/ ,;  
                        { || .T. }      /*bPre*/ ,;
                        { |_oModel| RTrim(Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_BAIRCOB")) } /*bSetValue*/ )

//--------------------+
// Gatilho Nome Filial|
//--------------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'/*cIdField*/ ,;
                        'XT5_MUN'   /*cTargetIdField*/ ,;  
                        { || .T. }  /*bPre*/ ,;
                        { |_oModel| RTrim(Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_CIDCOB")) } /*bSetValue*/ )

//--------------------+
// Gatilho Nome Filial|
//--------------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'/*cIdField*/ ,;
                        'XT5_EST'   /*cTargetIdField*/ ,;  
                        { || .T. }  /*bPre*/ ,;
                        { |_oModel| RTrim(Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_ESTCOB")) } /*bSetValue*/ )

//--------------------+
// Gatilho Nome Filial|
//--------------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'/*cIdField*/ ,;
                        'XT5_CEP'  /*cTargetIdField*/ ,;  
                        { || .T. }  /*bPre*/ ,;
                        { |_oModel| Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_CEPCOB") } /*bSetValue*/ )

//--------------------+
// Gatilho Nome Filial|
//--------------------+
_oStruXT5:AddTrigger( 	'XT5_CODFIL'    /*cIdField*/ ,;
                        'XT5_CODMUN'    /*cTargetIdField*/ ,;  
                        { || .T. }      /*bPre*/ ,;
                        { |_oModel| SubStr(Posicione("SM0",1, FwFldGet("XT5_CODEMP") + _oModel:GetValue("XT5_CODFIL"), "M0_CODMUN"),3) } /*bSetValue*/ )

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('DNMRPA_02', /*bPreValid*/ , /*_bPosValid*/ , _bCommit , /*_bCancel*/ )
_oModel:SetDescription('MRP - Filiais de Abastecimento')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('XT5_01',,_oStruXT5)

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({"XT5_FILIAL","XT5_ID","XT5_CGC"})

Return _oModel

/************************************************************************************/
/*/{Protheus.doc} ViewDef
    @description Cria interface com o usuario
    @author Bernard M. Margarido
    @since 10/08/2017
    @version undefined
    @type function
/*/
/************************************************************************************/
Static Function ViewDef() 
Local _oView        
Local _oModel
Local _oStrViewXT5	:= Nil

Local _nOldLen      := SetVarNameLen(255) 

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("DNMRPA02")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewXT5	:= FWFormStruct( 2,'XT5') 

//-----------------+
// Grupo de Campos | 
//-----------------+
_oStrViewXT5:AddGroup("GRP_ID"      , "ID/Status","",2)
_oStrViewXT5:AddGroup("GRP_DADOS"   , "Dados Empresa","",2)
_oStrViewXT5:AddGroup("GRP_CLIFOR"  , "Cliente/Fornecedor","",2)
_oStrViewXT5:AddGroup("GRP_DIAS"    , "Dias Abastecimento","",2)

//-----------------------+
// Agrupamento de campos |
//-----------------------+
_oStrViewXT5:SetProperty("XT5_ID"       , MVC_VIEW_GROUP_NUMBER, "GRP_ID")
_oStrViewXT5:SetProperty("XT5_STATUS"   , MVC_VIEW_GROUP_NUMBER, "GRP_ID")

_oStrViewXT5:SetProperty("XT5_CODEMP"   , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_CODFIL"   , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_NOME"     , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_CGC"      , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_INSCR"    , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_END"      , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_BAIRRO"   , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_MUN"      , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_EST"      , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_CEP"      , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")
_oStrViewXT5:SetProperty("XT5_CODMUN"   , MVC_VIEW_GROUP_NUMBER, "GRP_DADOS")

_oStrViewXT5:SetProperty("XT5_GERACL"   , MVC_VIEW_GROUP_NUMBER, "GRP_CLIFOR")
_oStrViewXT5:SetProperty("XT5_CODCLI"   , MVC_VIEW_GROUP_NUMBER, "GRP_CLIFOR")
_oStrViewXT5:SetProperty("XT5_LOJCLI"   , MVC_VIEW_GROUP_NUMBER, "GRP_CLIFOR")
_oStrViewXT5:SetProperty("XT5_GERAFO"   , MVC_VIEW_GROUP_NUMBER, "GRP_CLIFOR")
_oStrViewXT5:SetProperty("XT5_CODFOR"   , MVC_VIEW_GROUP_NUMBER, "GRP_CLIFOR")
_oStrViewXT5:SetProperty("XT5_LOJFOR"   , MVC_VIEW_GROUP_NUMBER, "GRP_CLIFOR")

_oStrViewXT5:SetProperty("XT5_DIAS"     , MVC_VIEW_GROUP_NUMBER, "GRP_DIAS")

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('MRP - Filiais de Abastecimento')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XT5_FORM' 	, _oStrViewXT5 , 'XT5_01' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'ALLCLIENT' , 100 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:SetOwnerView('XT5_FORM'	    ,'ALLCLIENT')

Return _oView 

/************************************************************************************/
/*/{Protheus.doc} DnMrp02A
    @description Valida dados pós gravação
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/************************************************************************************/
Static Function DnMrp02A(_oModel)
Local _aArea        := GetArea()

Local _lRet         := .T.

Local _oModelXT5    := _oModel:GetModel("XT5_01") 

//--------------------+
// Grava dados modelo |
//--------------------+
FwFormCommit(_oModel)

//--------------+
// Gera Cliente |
//--------------+
If _oModelXT5:GetValue("XT5_GERACL") .And. Empty(_oModelXT5:GetValue("XT5_CODCLI"))
    FwMsgRun(,{|| _lRet := DnMrpA02B(1,_oModel)}, "Aguarde...", "Incluindo Cliente")
EndIf

//-----------------+
// Gera Fornecedor |
//-----------------+
If _oModelXT5:GetValue("XT5_GERAFO") .And. Empty(_oModelXT5:GetValue("XT5_CODFOR"))
    FwMsgRun(,{|| _lRet := DnMrpA02B(2,_oModel)}, "Aguarde...", "Incluindo Fornecedor")
EndIf

RestArea(_aArea)
Return _lRet 

/************************************************************************************/
/*/{Protheus.doc} DnMrpA02B
    @description Realiza a criação do cliente/fornecedor logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/************************************************************************************/
Static Function DnMrpA02B(_nType,_oModel)
Local _cCodigo      := ""
Local _cLoja        := ""
Local _cAtivo       := "S"
Local _cClassif     := "001"    

Local _nFatorPr     := 1
Local _nOpcA        := 4

Local _lRet         := .T.

Local _aArray       := {}

Local _oModelXT5    := _oModel:GetModel("XT5_01") 
Local _oCliFor      := Nil 

Private lMsErroAuto := .F.

//--------------+
// Gera cliente |
//--------------+
If _nType == 1

    dbSelectArea("SA1")
    SA1->( dbSetOrder(1) )
    
    If Empty(_oModelXT5:GetValue("XT5_CODCLI")) .And. Empty(_oModelXT5:GetValue("XT5_LOJCLI"))  
        _oCliFor := DNMRPC01():New()
        _oCliFor:_cAlias    := "SA1"
        _oCliFor:_cCGC      := _oModelXT5:GetValue("XT5_CGC")
        
        If _oCliFor:SetCodLoja()
            _cCodigo := _oCliFor:_cCodigo
            _cLoja   := _oCliFor:_cLoja
        EndIf
        _nOpcA  := 3
    EndIf

    //--------------------------------------+
    // Cria Array para cadastro de clientes |
    //--------------------------------------+
    aAdd(_aArray ,	{"A1_FILIAL"	,	xFilial("SA1")							,	Nil	})
    aAdd(_aArray ,	{"A1_COD"		,	_cCodigo								,	Nil	})
    aAdd(_aArray ,	{"A1_LOJA"		,	_cLoja									,	Nil	})
    aAdd(_aArray ,	{"A1_PESSOA"	,	"J" 									,	Nil	})
    aAdd(_aArray ,	{"A1_NOME"		,	_oModelXT5:GetValue("XT5_NOME")			,	Nil	})
    aAdd(_aArray ,	{"A1_NREDUZ"	,	_oModelXT5:GetValue("XT5_NOME") 		,	Nil	})
    aAdd(_aArray ,	{"A1_END"		,	_oModelXT5:GetValue("XT5_END")          ,	Nil	})
	aAdd(_aArray ,	{"A1_EST"		,	_oModelXT5:GetValue("XT5_EST") 		    ,	Nil	})
	aAdd(_aArray ,	{"A1_COD_MUN"	,	_oModelXT5:GetValue("XT5_CODMUN") 		,	Nil	})
	aAdd(_aArray ,	{"A1_MUN"		,	_oModelXT5:GetValue("XT5_MUN")			,	Nil	})
	aAdd(_aArray ,	{"A1_BAIRRO"	,	_oModelXT5:GetValue("XT5_BAIRRO")		,	Nil	})
	aAdd(_aArray ,	{"A1_CEP"		,	_oModelXT5:GetValue("XT5_CEP")			,	Nil	})
    aAdd(_aArray ,	{"A1_ENDCOB"	,	_oModelXT5:GetValue("XT5_END")			,	Nil	})
    aAdd(_aArray ,	{"A1_ESTCOB"	,	_oModelXT5:GetValue("XT5_EST")			,	Nil	})
    aAdd(_aArray ,	{"A1_MUNCOB"	,	_oModelXT5:GetValue("XT5_MUN")			,	Nil	})
    aAdd(_aArray ,	{"A1_BAIRROC"	,	_oModelXT5:GetValue("XT5_BAIRRO")		,	Nil	})
    aAdd(_aArray ,	{"A1_CEPCOB"	,	_oModelXT5:GetValue("XT5_CEP")			,	Nil	})  
    aAdd(_aArray ,	{"A1_ENDENT"	,	_oModelXT5:GetValue("XT5_END")			,	Nil	})
    aAdd(_aArray ,	{"A1_ESTE"		,	_oModelXT5:GetValue("XT5_EST")			,	Nil	})
    aAdd(_aArray ,	{"A1_MUNE"		,	_oModelXT5:GetValue("XT5_MUN")			,	Nil	})
    aAdd(_aArray ,	{"A1_BAIRROE"	,	_oModelXT5:GetValue("XT5_BAIRRO")		,	Nil	})
    aAdd(_aArray ,	{"A1_CEPE"		,	_oModelXT5:GetValue("XT5_CEP")			,	Nil	})
    aAdd(_aArray ,	{"A1_TIPO"		,	"R"								        ,	Nil	})
    aAdd(_aArray ,	{"A1_DDD"		,	""                          			,	Nil	})
    aAdd(_aArray ,	{"A1_TEL"		,	""                          			,	Nil	})
    aAdd(_aArray ,	{"A1_PAIS"		,	"105"                       			,	Nil	})
    aAdd(_aArray ,	{"A1_CGC"		,	_oModelXT5:GetValue("XT5_CGC")			,	Nil	})
    aAdd(_aArray ,	{"A1_EMAIL"		,	""                              		,	Nil	})
    aAdd(_aArray ,	{"A1_DTNASC"	,	dDataBase                       		,	Nil	})
    aAdd(_aArray ,	{"A1_CLIENTE"	,	"S"										,	Nil	})
    aAdd(_aArray ,	{"A1_CONTRIB"	,	"2"								        ,	Nil	})  
    aAdd(_aArray ,	{"A1_INSCR"	    ,	_oModelXT5:GetValue("XT5_INSCR")		,	"AllWaysTrue()"	})
    aAdd(_aArray ,  {"A1_CODPAIS"	,   "01058"									,	Nil	})
    aAdd(_aArray ,  {"A1_ATIVO"     ,   _cAtivo                                 ,   Nil })
    aAdd(_aArray ,  {"A1_CLASSIF"   ,   _cClassif                               ,   Nil })
    aAdd(_aArray ,  {"A1_FATORPR"   ,   _nFatorPr                               ,   Nil })
    
//-----------------+
// Gera Fornecedor | 
//-----------------+
ElseIf _nType == 2
    
    dbSelectArea("SA2")
    SA2->( dbSetOrder(1) )
    
    If Empty(_oModelXT5:GetValue("XT5_CODFOR")) .And. Empty(_oModelXT5:GetValue("XT5_LOJFOR"))  
        _oCliFor := DNMRPC01():New()
        _oCliFor:_cAlias    := "SA1"
        _oCliFor:_cCGC      := _oModelXT5:GetValue("XT5_CGC")
        
        If _oCliFor:SetCodLoja()
            _cCodigo := _oCliFor:_cCodigo
            _cLoja   := _oCliFor:_cLoja
        EndIf
        _nOpcA  := 3 
	EndIf

    //--------------------------------------+
    // Cria Array para cadastro de clientes |
    //--------------------------------------+
    aAdd(_aArray ,	{"A2_FILIAL"	,	xFilial("SA1")							,	Nil	})
    aAdd(_aArray ,	{"A2_COD"		,	_cCodigo								,	Nil	})
    aAdd(_aArray ,	{"A2_LOJA"		,	_cLoja									,	Nil	})
    aAdd(_aArray ,	{"A2_NOME"		,	RTrim(_oModelXT5:GetValue("XT5_NOME"))	,	Nil	})
    aAdd(_aArray ,	{"A2_NREDUZ"	,	RTrim(_oModelXT5:GetValue("XT5_NOME"))  ,	Nil	})
    aAdd(_aArray ,	{"A2_END"		,	RTrim(_oModelXT5:GetValue("XT5_END"))   ,	Nil	})
	aAdd(_aArray ,	{"A2_EST"		,	_oModelXT5:GetValue("XT5_EST") 		    ,	Nil	})
	aAdd(_aArray ,	{"A2_COD_MUN"	,	_oModelXT5:GetValue("XT5_CODMUN") 		,	Nil	})
	aAdd(_aArray ,	{"A2_MUN"		,	RTrim(_oModelXT5:GetValue("XT5_MUN"))	,	Nil	})
	aAdd(_aArray ,	{"A2_BAIRRO"	,	RTrim(_oModelXT5:GetValue("XT5_BAIRRO")),	Nil	})
	aAdd(_aArray ,	{"A2_CEP"		,	_oModelXT5:GetValue("XT5_CEP")			,	Nil	})
    aAdd(_aArray ,	{"A2_TIPO"		,	"J"								        ,	Nil	})
    aAdd(_aArray ,	{"A2_DDD"		,	""	                            		,	Nil	})
    aAdd(_aArray ,	{"A2_TEL"		,	""			                            ,	Nil	})
    aAdd(_aArray ,	{"A2_PAIS"		,	"105"			                        ,	Nil	})
    aAdd(_aArray ,	{"A2_CGC"		,	_oModelXT5:GetValue("XT5_CGC")			,	Nil	})
    aAdd(_aArray ,	{"A2_EMAIL"		,	""	                                    ,	Nil	})
    aAdd(_aArray ,	{"A2_INSCR"	    ,	_oModelXT5:GetValue("XT5_INSCR")		,	"AllWaysTrue()"	})
    aAdd(_aArray ,  {"A2_CODPAIS"	,   "01058"									,	Nil	})

EndIf

//-------------------+
// Processa ExecAuto | 
//-------------------+
If Len(_aArray) > 0
    
    lMsErroAuto := .F.  

    //-------------------+
    // Processa Clientes |
    //-------------------+
    If _nType == 1

        _aArray := FWVetByDic(_aArray, "SA1")
        MsExecAuto({|x,y| Mata030(x,y)}, _aArray, _nOpcA)

    //-----------------------+
    // Processa fornecedores |
    //-----------------------+
    Else
        _aArray := FWVetByDic(_aArray, "SA2")
        MsExecAuto({|x,y| Mata020(x,y)}, _aArray, _nOpcA)
    EndIf 

    //---------------+
    // Erro gravação | 
    //---------------+
    If lMsErroAuto
        //-------------------+
        // Retorna numeração |
        //-------------------+
        RollBackSx8()

        //----------------------+
        // Mostra erro ExecAuto | 
        //----------------------+
        MostraErro()

        //-------------------------------+
        // Desarma controle de transação | 
        //-------------------------------+
        DisarmTransaction()
        _lRet := .F.

    //----------------------+
    // Gravação com sucesso | 
    //----------------------+
    Else
        ConfirmSx8()
        
        If _nType == 1
            _oModelXT5:SetValue("XT5_CODCLI",SA1->A1_COD)
            _oModelXT5:SetValue("XT5_LOJCLI",SA1->A1_LOJA)       
        Else
            _oModelXT5:SetValue("XT5_CODFOR",SA2->A2_COD)    
            _oModelXT5:SetValue("XT5_LOJFOR",SA2->A2_LOJA)   
        EndIf
        /*
        RecLock("XT5",.F.)
            If _nType == 1
                XT5->XT5_CODCLI := SA1->A1_COD
                XT5->XT5_LOJCLI := SA1->A1_LOJA
            Else
                XT5->XT5_CODFOR := SA2->A2_COD
                XT5->XT5_LOJFOR := SA2->A2_LOJA
            EndIf
        XT5->( MsUnlock() )
    */
        _lRet := .T.
    EndIf

EndIf

Return _lRet 

/************************************************************************************/
/*/{Protheus.doc} MenuDef
	@description Menu padrao para manutencao do cadastro
	@author Bernard M. Margarido
	@since 10/08/2017
	@version undefined
/*/
/************************************************************************************/
Static Function MenuDef()
Return FwMVCMenu('DNMRPA02') //_aRotina
