#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/******************************************************************************/
/*/{Protheus.doc} DLOGA001
    @description Cadastro de clientes operador logistico 
    @type  Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/******************************************************************************/
User Function DLOGA001()
Private _nOldLen := SetVarNameLen(255) 
Private _oBrowse := Nil 

//------------------------------------+
// Instanciamento da Classe FWMBrowse |
//------------------------------------+
_oBrowse := FWMBrowse():New()
//-----------------+
// Alias utilizado |
//-----------------+
_oBrowse:SetAlias("XT1")
//-------------------+
// Adiciona Legendas |
//-------------------+
_oBrowse:AddLegend( "XT1_STATUS == '1'", "GREEN"    , "Ativo" )
_oBrowse:AddLegend( "XT1_STATUS == '2'", "RED"      , "Inativo" )
//------------------+
// Titulo do Browse |
//------------------+
_oBrowse:SetDescription('DLOG - Cliente logistico')
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
Local _oStruXT1     := Nil
Local _oStruXT2		:= Nil
Local _oStruXT3     := Nil

Local _bCommit      := {|_oModel| DLogA01Com(_oModel)}
//-----------------+
// Monta Estrutura |
//-----------------+
_oStruXT1   := FWFormStruct(1,"XT1")
_oStruXT2	:= FWFormStruct(1,"XT2")
_oStruXT3   := FWFormStruct(1,"XT3")

//--------------------+
// Gatillho campo CGC |
//--------------------+
_oStruXT1:AddTrigger( 	'XT1_CGC' 	/*cIdField*/ ,;
                        'XT1_IDLOG'	/*cTargetIdField*/ ,;  
                        { || .T. } /*bPre*/ ,;
                        { || DlogA01S("9",TamSx3("XT1_IDLOG")[1]) } /*bSetValue*/ )

//-------+
// Model |
//-------+
_oModel 	:= MPFormModel():New('DLOGA_01', /*bPreValid*/ , /*_bPosValid*/ , _bCommit , /*_bCancel*/ )
_oModel:SetDescription('DLOG - Cliente Logistico')

//-----------------+
// Adiciona campos | 
//-----------------+
_oModel:addFields('XT1_01',,_oStruXT1)
_oModel:addFields('XT2_01','XT1_01',_oStruXT2)
_oModel:SetRelation( 'XT2_01', { { 'XT2_FILIAL', 'xFilial( "XT2" )' }, { 'XT2_IDLOG', 'XT1_IDLOG' } }, XT2->( IndexKey( 1 ) ) )

//------------------------+
// Chave primaria produto | 
//------------------------+
_oModel:SetPrimaryKey({"XT1_FILIAL","XT1_IDLOG","XT1_CGC"})

//------------------------------+
// Produto X Campos Especificos |
//------------------------------+
_oModel:AddGrid("XT3_01", "XT1_01" /*cOwner*/, _oStruXT3 , /*_bLiOk */ , /*_bPosOk*/ , /*_bPre*/ , /*_bPost*/, /*_bColor*/)
_oModel:SetRelation( "XT3_01" , { { "XT3_FILIAL" , 'xFilial("XT3")' }, { "XT3_IDLOG" , "XT1_IDLOG" } } , XT3->( IndexKey( 1 ) ) )

//-------------------------------------------+
// Liga o controle de nao repeticao de linha |
//-------------------------------------------+
_oModel:GetModel( "XT3_01" ):SetUniqueLine( {"XT3_FILIAL","XT3_CODIGO","XT3_IDLOG"} )


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
Local _oStrViewXT1	:= Nil
Local _oStrViewXT2	:= Nil
Local _oStrViewXT3  := Nil

Local _nOldLen      := SetVarNameLen(255) 

//-------------------------+
// Carrega Modelo de Dados | 
//-------------------------+
_oModel := FWLoadModel("DLOGA001")

//--------------------------------------+
// Cria a estrutura a ser usada na View |
//--------------------------------------+
_oStrViewXT1	:= FWFormStruct( 2,'XT1') 
_oStrViewXT2	:= FWFormStruct( 2,'XT2') 
_oStrViewXT3    := FWFormStruct( 2,'XT3') 

//---------------------+
// Instancia Interface |
//---------------------+
_oView	:= FWFormView():New()
_oView:SetModel(_oModel)
_oView:SetDescription('DLOG - Cliente Logistico')

//---------------------+
// View das estruturas |
//---------------------+
_oView:AddField('XT1_FORM' 	, _oStrViewXT1 , 'XT1_01' )
_oView:AddField('XT2_FORM' 	, _oStrViewXT2 , 'XT2_01' )
_oView:AddGrid('XT3_GRID'	, _oStrViewXT3 , 'XT3_01' )

//------------------------------------------------------------+
// Criar "box" horizontal para receber algum elemento da view |
//------------------------------------------------------------+
_oView:CreateHorizontalBox( 'SUP_01' , 050 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'MEI_01' , 005 ,,, /*'PASTAS'*/, /*'ABA01'*/ )
_oView:CreateHorizontalBox( 'INF_01' , 045 ,,, /*'PASTAS'*/, /*'ABA01'*/ )

_oView:CreateVerticalBox( 'ESQ_S1'   ,047 , 'INF_01' )
_oView:CreateVerticalBox( 'MEI_S1'   ,006 , 'INF_01' )
_oView:CreateVerticalBox( 'DIR_S1'   ,047 , 'INF_01' )

//--------------+
// Panel Botoes | 
//--------------+
_oView:AddOtherObject("VIEW_BTN", {|_oPanel| DlogA01Btn(_oPanel)})   

_oView:SetOwnerView('XT1_FORM'	    ,'SUP_01')
_oView:SetOwnerView('XT2_FORM'	    ,'ESQ_S1')
_oView:SetOwnerView('XT3_GRID'	    ,'DIR_S1')
_oView:SetOwnerView('VIEW_BTN'	    ,'MEI_S1')

//------------------------+
// Titulo componente GRID |
//------------------------+
_oView:EnableTitleView('XT1_FORM','Dados Cliente Logistico')
_oView:EnableTitleView('XT2_FORM','Configuração de Acesso - Cliente Logistico')
_oView:EnableTitleView('XT3_GRID','Armazens Utilizados - Cliente Logistico')

//-------------------+
// Adicionando botão | 
//-------------------+
//_oView:AddUserButton( 'Visualiza NF-e', 'CLIPS', {|_oView| U_BSFATA07() } )

Return _oView 

/************************************************************************************/
/*/{Protheus.doc} DlogA01Btn
	@description Botão para gerar senha
	@author Bernard M. Margarido
	@since 10/08/2017
	@version undefined
/*/
/************************************************************************************/
Static Function DlogA01Btn(_oPanel)

_oBtn1 := TButton():New( 025, 003, "Gera Senha"       , _oPanel, {|| DlogA01S() }, 050, 012,,,,.T.,,,,,,)
_oBtn2 := TButton():New( 040, 003, "Copia Senha"      , _oPanel, {|| DlogA01C(1) }, 050, 012,,,,.T.,,,,,,)
_oBtn2 := TButton():New( 055, 003, "Copia IDLog"      , _oPanel, {|| DlogA01C(2) }, 050, 012,,,,.T.,,,,,,)

Return Nil 


/************************************************************************************/
/*/{Protheus.doc} DlogA01S
    @description Gera senha para acesso as API's
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/************************************************************************************/
Static Function DlogA01S(_cType,_nSize)
Local _aArea    := GetArea()

Local _oRandom  := FWDelphiRandom():New()
Local _oView    := FWViewActive()
Local _oModel   := FwModelActive()
Local _oModelXT1:= _oModel:GetModel("XT1_01") 
Local _oModelXT2:= _oModel:GetModel("XT2_01") 

Local _xRet 

Default _cType  := "F"
Default _nSize  := TamSx3("XT2_SENHA")[1]

_oRandom:RandSeed(Seconds())
_xRet := SubRandMask(_oRandom,_cType,_nSize)

If _cType == "F"
    _oModelXT2:SetValue("XT2_SENHA",_xRet)
Else
    _oModelXT1:SetValue("XT1_IDLOG",_xRet)
EndIf

_oView:Refresh()

RestArea(_aArea)
Return _xRet 

/************************************************************************************/
/*/{Protheus.doc} SubRandMask
    @description Gera senha para acesso as API's
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/************************************************************************************/
Static function SubRandMask(_oRandom,_cType,_nSize)
Local _nChar
Local _cChar
Local _nX    
Local _cPass := ""

For _nX := 1 To _nSize 
	If _cType == "F"
		_nChar := _oRandom:Random(126)
		_cChar := CHR(_nChar)
		While !(isAlpha(_cChar) .oR. isDigit(_cChar)) //Tiramos os caracteres inicias da ASCII, pois pode gerar algum problema
			_nChar := _oRandom:Random(126)		
			_cChar := CHR(_nChar)
		End
		_cPass += Chr(_nChar)
	ElseIf _cType == 'a'
		_nChar := _oRandom:Random(126)
		_cChar := CHR(_nChar)
		While !(isAlpha(_cChar) .And. _cChar $ 'qwertyuiopasdfghjklzxcvbnm') 
			_nChar := _oRandom:Random(126)		
			_cChar := CHR(_nChar)
		End	
		_cPass += Chr(_nChar)
	ElseIf _cType == 'A'
		_nChar := _oRandom:Random(126)
		_cChar := CHR(_nChar)
		While (isAlpha(_cChar) .And. _cChar $ 'qwertyuiopasdfghjklzxcvbnm') 
			_nChar := _oRandom:Random(126)		
			_cChar := CHR(_nChar)
		End	
		_cPass += Chr(_nChar)	
	ElseIf _cType == '9'
		_nChar := _oRandom:Random(126)
		_cChar := CHR(_nChar)
		While !(isDigit(_cChar)) 
			_nChar := _oRandom:Random(126)		
			_cChar := CHR(_nChar)
		End
		_cPass += Chr(_nChar)
	Endif
Next _nX
Return _cPass

/************************************************************************************/
/*/{Protheus.doc} DlogA01C
    @description Copia senha 
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/************************************************************************************/
Static Function DlogA01C(_nType)
Local _oView    := FWViewActive()
Local _oModel   := FwModelActive()
Local _oModelXT1:= _oModel:GetModel("XT1_01") 
Local _oModelXT2:= _oModel:GetModel("XT2_01") 

If _nType == 1
    CopytoClipboard(_oModelXT2:GetValue("XT2_SENHA"))
ElseIf _nType == 2  
    CopytoClipboard(_oModelXT1:GetValue("XT1_IDLOG"))
EndIf

Return Nil 

/************************************************************************************/
/*/{Protheus.doc} DLogA01Com
    @description Valida dados pós gravação
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/************************************************************************************/
Static Function DLogA01Com(_oModel)
Local _aArea        := GetArea()

Local _lRet         := .T.

Local _nX           := 0
Local _oModelNNR    := Nil 
Local _oModelXT1    := _oModel:GetModel("XT1_01") 
Local _oModelXT3    := _oModel:GetModel("XT3_01") 

FwFormCommit(_oModel)

//--------------+
// Gera Cliente |
//--------------+
If _oModelXT1:GetValue("XT1_GERCLI") .And. Empty(_oModelXT1:GetValue("XT1_CODCLI"))
    FwMsgRun(,{|| _lRet := DLogA01D(1,_oModel)}, "Aguarde...", "Incluindo Cliente")
EndIf

//-----------------+
// Gera Fornecedor |
//-----------------+
If _oModelXT1:GetValue("XT1_GERFOR") .And. Empty(_oModelXT1:GetValue("XT1_CODFOR"))
    FwMsgRun(,{|| _lRet := DLogA01D(2,_oModel)}, "Aguarde...", "Incluindo Fornecedor")
EndIf

//-----------------------------------------+
// Atualiza armazem para cliente logistico |
//-----------------------------------------+
dbSelectArea("NNR")
NNR->( dbSetOrder(2) )
For _nX := 1 To _oModelXT3:Length()

    //-----------------+
    // Posiciona linha |
    //-----------------+
    _oModelXT3:GoLine(_nX)

    //------------------------------------------------------+
    // Valida se já existe armazem para o cliente logistico |
    //------------------------------------------------------+
    If !NNR->( dbSeek(xFilial("NNR") + _oModelXT1:GetValue("XT1_IDLOG") + _oModelXT3:GetValue("XT3_CODIGO")))

        //------------------------------+
        // Inicia a gravação do Armazem | 
        //------------------------------+
        _oModelNNR  := FwLoadModel('AGRA045')	 
        _oModelNNR:SetOperation(MODEL_OPERATION_INSERT) 
	    _oModelNNR:Activate()
        _oModel_NNR := _oModelNNR:GetModel("NNRMASTER")	
        _oModel_NNR:SetValue("NNR_FILIAL"   , xFilial("NNR"))
        _oModel_NNR:SetValue("NNR_CODIGO"   , _oModelXT3:GetValue("XT3_CODIGO"))
        _oModel_NNR:SetValue("NNR_DESCRI"   , _oModelXT3:GetValue("XT3_DESCRI"))
        _oModel_NNR:SetValue("NNR_TIPO"     , _oModelXT3:GetValue("XT3_TIPO"))
        _oModel_NNR:SetValue("NNR_XIDLOG"   , _oModelXT3:GetValue("XT3_IDLOG"))

        _oModelNNR:VldData()
        _oModelNNR:CommitData()	
        _oModelNNR:DeActivate()
        _oModelNNR:Destroy()	
        _oModelNNR := Nil

    EndIf

Next _nX
RestArea(_aArea)
Return _lRet 

/************************************************************************************/
/*/{Protheus.doc} DLogA01D
    @description Realiza a criação do cliente/fornecedor logistico
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/11/2020
/*/
/************************************************************************************/
Static Function DLogA01D(_nType,_oModel)
Local _cCodigo      := ""
Local _cLoja        := ""
Local _cAtivo       := "S"
Local _cClassif     := "001"    

Local _nFatorPr     := 1
Local _nOpcA        := 4

Local _lRet         := .T.

Local _aArray       := {}

Local _oModelXT1    := _oModel:GetModel("XT1_01") 

Private lMsErroAuto := .F.

//--------------+
// Gera cliente |
//--------------+
If _nType == 1
    dbSelectArea("SA1")
    SA1->( dbSetOrder(1) )
    
    If Empty(_oModelXT1:GetValue("XT1_CODCLI")) .And. Empty(_oModelXT1:GetValue("XT1_LOJCLI"))  
        _cCodigo    := GetSxeNum("SA1","A1_COD")
        _cLoja	    := "01"
        While SA1->( dbSeek(xFilial("SA1") +_cCodigo + _cLoja ) )
            ConfirmSx8()
            _cCodigo	:= GetSxeNum("SA1","A1_COD","",1)
        EndDo	
        _nOpcA  := 3
    Else
        _cCodigo    := _oModelXT1:GetValue("XT1_CODCLI")
        _cLoja	    := _oModelXT1:GetValue("XT1_LOJCLI")
        SA1->( dbSeek(xFilial("SA1") + _cCodigo + _cLoja ) )
        _nOpcA      := 4
	EndIf
    //--------------------------------------+
    // Cria Array para cadastro de clientes |
    //--------------------------------------+
    aAdd(_aArray ,	{"A1_FILIAL"	,	xFilial("SA1")							,	Nil	})
    aAdd(_aArray ,	{"A1_COD"		,	_cCodigo								,	Nil	})
    aAdd(_aArray ,	{"A1_LOJA"		,	_cLoja									,	Nil	})
    aAdd(_aArray ,	{"A1_PESSOA"	,	"J" 									,	Nil	})
    aAdd(_aArray ,	{"A1_NOME"		,	_oModelXT1:GetValue("XT1_NOME")			,	Nil	})
    aAdd(_aArray ,	{"A1_NREDUZ"	,	_oModelXT1:GetValue("XT1_NREDUZ")		,	Nil	})
    aAdd(_aArray ,	{"A1_END"		,	_oModelXT1:GetValue("XT1_END")          ,	Nil	})
	aAdd(_aArray ,	{"A1_EST"		,	_oModelXT1:GetValue("XT1_EST") 		    ,	Nil	})
	aAdd(_aArray ,	{"A1_COD_MUN"	,	_oModelXT1:GetValue("XT1_CODMUN") 		,	Nil	})
	aAdd(_aArray ,	{"A1_MUN"		,	_oModelXT1:GetValue("XT1_MUN")			,	Nil	})
	aAdd(_aArray ,	{"A1_BAIRRO"	,	_oModelXT1:GetValue("XT1_BAIRRO")		,	Nil	})
	aAdd(_aArray ,	{"A1_CEP"		,	_oModelXT1:GetValue("XT1_CEP")			,	Nil	})
    aAdd(_aArray ,	{"A1_ENDCOB"	,	_oModelXT1:GetValue("XT1_END")			,	Nil	})
    aAdd(_aArray ,	{"A1_ESTCOB"	,	_oModelXT1:GetValue("XT1_EST")			,	Nil	})
    aAdd(_aArray ,	{"A1_MUNCOB"	,	_oModelXT1:GetValue("XT1_MUN")			,	Nil	})
    aAdd(_aArray ,	{"A1_BAIRROC"	,	_oModelXT1:GetValue("XT1_BAIRRO")		,	Nil	})
    aAdd(_aArray ,	{"A1_CEPCOB"	,	_oModelXT1:GetValue("XT1_CEP")			,	Nil	})  
    aAdd(_aArray ,	{"A1_ENDENT"	,	_oModelXT1:GetValue("XT1_END")			,	Nil	})
    aAdd(_aArray ,	{"A1_ESTE"		,	_oModelXT1:GetValue("XT1_EST")			,	Nil	})
    aAdd(_aArray ,	{"A1_MUNE"		,	_oModelXT1:GetValue("XT1_MUN")			,	Nil	})
    aAdd(_aArray ,	{"A1_BAIRROE"	,	_oModelXT1:GetValue("XT1_BAIRRO")		,	Nil	})
    aAdd(_aArray ,	{"A1_CEPE"		,	_oModelXT1:GetValue("XT1_CEP")			,	Nil	})
    aAdd(_aArray ,	{"A1_TIPO"		,	"R"								        ,	Nil	})
    aAdd(_aArray ,	{"A1_DDD"		,	_oModelXT1:GetValue("XT1_DDD")			,	Nil	})
    aAdd(_aArray ,	{"A1_TEL"		,	_oModelXT1:GetValue("XT1_TEL")			,	Nil	})
    aAdd(_aArray ,	{"A1_PAIS"		,	_oModelXT1:GetValue("XT1_PAIS")			,	Nil	})
    aAdd(_aArray ,	{"A1_CGC"		,	_oModelXT1:GetValue("XT1_CGC")			,	Nil	})
    aAdd(_aArray ,	{"A1_EMAIL"		,	_oModelXT1:GetValue("XT1_EMAIL")		,	Nil	})
    aAdd(_aArray ,	{"A1_DTNASC"	,	_oModelXT1:GetValue("XT1_DTNASC")		,	Nil	})
    aAdd(_aArray ,	{"A1_CLIENTE"	,	"S"										,	Nil	})
    aAdd(_aArray ,	{"A1_CONTRIB"	,	"2"								        ,	Nil	})  
    aAdd(_aArray ,	{"A1_INSCR"	    ,	_oModelXT1:GetValue("XT1_INSCR")		,	"AllWaysTrue()"	})
    aAdd(_aArray ,  {"A1_CODPAIS"	,   "01058"									,	Nil	})
    aAdd(_aArray ,  {"A1_ATIVO"     ,   _cAtivo                                 ,   Nil })
    aAdd(_aArray ,  {"A1_CLASSIF"   ,   _cClassif                               ,   Nil })
    aAdd(_aArray ,  {"A1_FATORPR"   ,   _nFatorPr                               ,   Nil })
    aAdd(_aArray ,  {"A1_XIDLOGI"   ,   _oModelXT1:GetValue("XT1_IDLOG")        ,   Nil })

//-----------------+
// Gera Fornecedor | 
//-----------------+
ElseIf _nType == 2
    dbSelectArea("SA2")
    SA2->( dbSetOrder(1) )
    If Empty(_oModelXT1:GetValue("XT1_CODFOR")) .And. Empty(_oModelXT1:GetValue("XT1_LOJFOR"))  
        _cCodigo    := GetSxeNum("SA2","A2_COD")
        _cLoja	    := "01"
        While SA2->( dbSeek(xFilial("SA2") +_cCodigo + _cLoja ) )
            ConfirmSx8()
            _cCodigo	:= GetSxeNum("SA2","A2_COD","",1)
        EndDo	
        _nOpcA  := 3 
    Else
        _cCodigo    := _oModelXT1:GetValue("XT1_CODFOR")
        _cLoja	    := _oModelXT1:GetValue("XT1_LOJFOR")
        SA2->( dbSeek(xFilial("SA2") +_cCodigo + _cLoja ) )
        _nOpcA      := 4   
	EndIf

    //--------------------------------------+
    // Cria Array para cadastro de clientes |
    //--------------------------------------+
    aAdd(_aArray ,	{"A2_FILIAL"	,	xFilial("SA1")							,	Nil	})
    aAdd(_aArray ,	{"A2_COD"		,	_cCodigo								,	Nil	})
    aAdd(_aArray ,	{"A2_LOJA"		,	_cLoja									,	Nil	})
    aAdd(_aArray ,	{"A2_NOME"		,	RTrim(_oModelXT1:GetValue("XT1_NOME"))	,	Nil	})
    aAdd(_aArray ,	{"A2_NREDUZ"	,	RTrim(_oModelXT1:GetValue("XT1_NREDUZ")),	Nil	})
    aAdd(_aArray ,	{"A2_END"		,	RTrim(_oModelXT1:GetValue("XT1_END"))   ,	Nil	})
	aAdd(_aArray ,	{"A2_EST"		,	_oModelXT1:GetValue("XT1_EST") 		    ,	Nil	})
	aAdd(_aArray ,	{"A2_COD_MUN"	,	_oModelXT1:GetValue("XT1_CODMUN") 		,	Nil	})
	aAdd(_aArray ,	{"A2_MUN"		,	RTrim(_oModelXT1:GetValue("XT1_MUN"))	,	Nil	})
	aAdd(_aArray ,	{"A2_BAIRRO"	,	RTrim(_oModelXT1:GetValue("XT1_BAIRRO")),	Nil	})
	aAdd(_aArray ,	{"A2_CEP"		,	_oModelXT1:GetValue("XT1_CEP")			,	Nil	})
    aAdd(_aArray ,	{"A2_TIPO"		,	"J"								        ,	Nil	})
    aAdd(_aArray ,	{"A2_DDD"		,	_oModelXT1:GetValue("XT1_DDD")			,	Nil	})
    aAdd(_aArray ,	{"A2_TEL"		,	_oModelXT1:GetValue("XT1_TEL")			,	Nil	})
    aAdd(_aArray ,	{"A2_PAIS"		,	_oModelXT1:GetValue("XT1_PAIS")			,	Nil	})
    aAdd(_aArray ,	{"A2_CGC"		,	_oModelXT1:GetValue("XT1_CGC")			,	Nil	})
    aAdd(_aArray ,	{"A2_EMAIL"		,	RTrim(_oModelXT1:GetValue("XT1_EMAIL"))	,	Nil	})
    aAdd(_aArray ,	{"A2_INSCR"	    ,	_oModelXT1:GetValue("XT1_INSCR")		,	"AllWaysTrue()"	})
    aAdd(_aArray ,  {"A2_CODPAIS"	,   "01058"									,	Nil	})
    aAdd(_aArray ,  {"A2_XIDLOGI"   ,   _oModelXT1:GetValue("XT1_IDLOG")        ,   Nil }) 

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
        _aArray := FWVetByDic(_aArray, "SA2")
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
        RecLock("XT1",.F.)
            If _nType == 1
                XT1->XT1_CODCLI := SA1->A1_COD
                XT1->XT1_LOJCLI := SA1->A1_LOJA
            Else
                XT1->XT1_CODFOR := SA2->A2_COD
                XT1->XT1_LOJFOR := SA2->A2_LOJA
            EndIf
        XT1->( MsUnlock() )

        //-------------+
        // Atualiza ID |
        //-------------+
        

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
//Local _aRotina := {}

//_aRotina := FwMVCMenu('DLOGA001')

Return FwMVCMenu('DLOGA001') //_aRotina