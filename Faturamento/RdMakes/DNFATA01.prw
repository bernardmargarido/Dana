#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/***************************************************************************/
/*/{Protheus.doc} DNFATA01
    @description Regras para filial de faturamento
    @type  Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/***************************************************************************/
User Function DNFATA01()
Private _oBrowse	:= Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("ZZ6")
_oBrowse:SetDescription('Regras Filial de Faturamento')
_oBrowse:SetCacheView(.F.)
_oBrowse:SetMenuDef('DNFATA01')
_oBrowse:Activate()

Return .T.

/***************************************************************************/
/*/{Protheus.doc} ModelDef
    @description Modelo de dados, estrutura dos dados e modelo de negocio
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/***************************************************************************/
Static Function ModelDef()

    Local _oModel   := Nil
    Local _oStruZZ6 := Nil   

    _oStruZZ6 := FWFormStruct( 1, "ZZ6" )

    _oStruZZ6:AddTrigger( 	'ZZ6_LOJA' 	/*cIdField*/ ,;
					 	    'ZZ6_NOME'	/*cTargetIdField*/ ,;  
					 	    { || .T. } /*bPre*/ ,;
					 	    { |_oModel| Padr( Posicione("SA1",1,xFilial("SA1") + _oModel:GetValue('ZZ6_CODCLI') + _oModel:GetValue('ZZ6_LOJA'),'A1_NOME'), TamSx3("A1_NOME")[1] ) } /*bSsetValue*/ )

    _oStruZZ6:AddTrigger( 	'ZZ6_CODMUN' 	/*cIdField*/ ,;
					 	    'ZZ6_MUN'	/*cTargetIdField*/ ,;  
					 	    { || .T. } /*bPre*/ ,;
					 	    { |_oModel| Padr( Posicione("CC2",3,xFilial("CC2") + _oModel:GetValue('ZZ6_CODMUN'),'CC2_MUN'), TamSx3("CC2_MUN")[1] ) } /*bSetValue*/ )


    _oModel := MPFormModel():New( "ZZ6_00",,{|_oModel| PosVldMdl(_oModel)},, /*bCancel*/ ) 
    _oModel:AddFields( 'ZZ6MASTER',,_oStruZZ6)      
    
    _oModel:SetDescription( "Regra Filial de Faturamento" )	
    _oModel:GetModel( 'ZZ6MASTER' ):SetDescription(  "Regra Filial de Faturamento"  )
   
    _oModel:SetPrimaryKey({"ZZ6_FILIAL","ZZ6_CODCLI","ZZ6_LOJA","ZZ6_EST","ZZ6_CODMUN","ZZ6_FILFAT"})  
                
    _oModel:SetActivate()
     
Return _oModel 

/***************************************************************************/
/*/{Protheus.doc} ModelDef
    @description Modelo de dados, estrutura dos dados e modelo de negocio
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/***************************************************************************/
Static Function ViewDef()     
    Local _oModel   := Nil
    Local _oStruZZ6 := Nil
    Local _oView    := Nil
    
    _oModel   := FwLoadModel("DNFATA01")
    _oStruZZ6 := FWFormStruct( 2, "ZZ6")

    _oView := FwFormView():New()
    _oView:SetModel(_oModel)     
    
    _oView:AddField('ZZ6VIEW', _oStruZZ6 , 'ZZ6MASTER')

    _oView:CreateHorizontalBox('CORPO', 100)
    _oView:SetOwnerView('ZZ6VIEW','CORPO')

    _oView:EnableTitleView('ZZ6VIEW',"Regra Filial de Faturamento") 

Return _oView 

/***************************************************************************/
/*/{Protheus.doc} DNFATA01C
    @description Copia registro
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/***************************************************************************/
Static Function DNFATA01C()
Local _aArea        := GetArea()
Local _cTitulo      := "Copia"
Local _cPrograma    := "DNFATA01"
Local _nOperation   := MODEL_OPERATION_INSERT

//---------------------------+		
// Carrega o modelo de dados |
//---------------------------+
_oModel := FWLoadModel(_cPrograma)
_oModel:SetOperation(_nOperation) // Inclusao
_oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

//-------------------------------+	
// Setando os campos do registro |
//-------------------------------+
_oModel:SetValue("ZZ6MASTER","ZZ6_EST"      , ZZ6->ZZ6_EST)
_oModel:SetValue("ZZ6MASTER","ZZ6_CODMUN"   , ZZ6->ZZ6_CODMUN)
_oModel:SetValue("ZZ6MASTER","ZZ6_MUN"      , ZZ6->ZZ6_MUN)
_oModel:SetValue("ZZ6MASTER","ZZ6_FILFAT"   , ZZ6->ZZ6_FILFAT)

//----------------------------------------------------+    
// Executando a visualizao dos dados para manipulacao |
//----------------------------------------------------+
_nRet := FWExecView( _cTitulo , _cPrograma, _nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, _oModel )

_oModel:DeActivate()

//---------------------------+
// Se a copia for confirmada |
//---------------------------+
If _nRet == 0
    Help( ,, 'Help',, 'Copia confirmada!', 1, 0 ) 
EndIf

RestArea(_aArea)
Return _oModel

/***************************************************************************/
/*/{Protheus.doc} DNFATA01A
    @description Realiza a atualização das tabelas nos clientes
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/***************************************************************************/
Static Function DNFATA01A()
Local _aArea     := GetArea()
Local _aParam   := {}
Local _aRet     := {}
Local _cUFIni   := CriaVar("A1_EST",.F.)
Local _cUFFim   := CriaVar("A1_EST",.F.)

//--------------------+
// Filtros para Query |
//--------------------+
aAdd( _aParam, {1,"UF De"     ,_cUFIni   ,PesqPict("SA1","A1_EST")     ,"","12","",060,.F.})
aAdd( _aParam, {1,"UF Ate"    ,_cUFFim   ,PesqPict("SA1","A1_EST")     ,"","12","",060,.F.})

If ParamBox(_aParam,"Informe os Parametros",@_aRet,,,,,,,,.T.)
 
    _cUFIni  := _aRet[1]
    _cUFFim  := _aRet[2]
 
    FWMsgRun(, {|| DnFatA01T(_cUFIni, _cUFFim) }, "Processando", "Atualizando regras para os clientes...")
EndIf

RestArea(_aArea)
Return .T.

/***************************************************************************/
/*/{Protheus.doc} DnFatA01T
    @description Atualiza tabela de preço clientes
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/***************************************************************************/
Static Function DnFatA01T(_cUFIni, _cUFFim)
Local _aArea    := GetArea()
Local _cAlias   := ""
Local _cQuery   := ""
Local _cFilFat  := ""

Local _nX       := 0    

Local _aClientes:= {}
Local _aFilFat  := {}

Local lRet      := .T.

_cQuery := " SELECT "+ CRLF
_cQuery += "     SA1.R_E_C_N_O_  RECNOSA1 "+ CRLF
_cQuery += " FROM " 
_cQuery += "     " + RetSqlName("SA1") + " SA1 (NOLOCK) "+ CRLF
_cQuery += " WHERE "+ CRLF
_cQuery += "     SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF

If !Empty(_cUFIni) .Or. !Empty(_cUFFim)
    _cQuery += "     AND SA1.A1_EST BETWEEN '" + _cUFIni + "' AND '" + _cUFFim + "' "+ CRLF
EndIf
_cQuery += "     AND SA1.A1_PESSOA = 'J' " + CRLF
_cQuery += "     AND SA1.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY SA1.A1_COD ,SA1.A1_LOJA "+ CRLF

_cAlias := MPSysOpenQuery(_cQuery)

// Posiciona - Tabela de Clientes
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )

If (_cAlias)->( !Eof())

	While (_cAlias)->( !Eof())

        
        SA1->( dbGoTo((_cAlias)->RECNOSA1) )

        _aFilFat := DnFatA01D(.F., .F.)
        
        If Len(_aFilFat) == 0

            aAdd( _aClientes, { SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME, "", "Nao localizado regra para este cliente" } )

            _cFilFat := CriaVar("A1_TABELA",.F.)

        ElseIf Len(_aFilFat) == 1

            _cFilFat := _aFilFat[1][1]

            If !(SA1->A1_TABELA == _cFilFat)            
                aAdd( _aClientes, { SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME,_cFilFat, "Atualizado com sucesso" } )
            EndIf
            
        Else

            _cFilFat := ""
            For _nX := 1 To Len(_aFilFat)
                _cFilFat += IIF(_nX>1,",","") + _aFilFat[_nX][1]
            Next _nX

            aAdd( _aClientes, { SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME,"", "Cliente com regras conflitantes: " + _cFilFat } )

            _cFilFat := CriaVar("A1_TABELA",.F.)

        EndIf

        RecLock("SA1",.F.)
            SA1->A1_XFILFAT  := IIF(Empty(_aFilFat[1][2]),SA1->A1_XFILFAT,_aFilFat[1][1])
        SA1->( MsUnlock() )

        (_cAlias)->( dbSkip())
    EndDo

    //----------------+
    // Gera Relatorio |
    //----------------+
    fSalvArq(_aClientes)

Else
    MsgStop("Nao ha dados para atualizar os itens!!!","Nao Processado")
EndIf

(_cAlias)->( dbCloseArea() )

RestArea(_aArea)
Return lRet

/***************************************************************************/
/*/{Protheus.doc} DnFatA01D
    @description Busca filial de faturamento para clientes
    @type  Static Function
    @author Bernard M. Margarido
    @since 28/10/2020
/*/
/***************************************************************************/
Static Function DnFatA01D(_lProspect,_lVarMem)
Local _aArea        := GetArea()
Local _aAreaSA1     := SA1->(GetArea())
Local _aFilFat     := {}

Local _cAliasT      := ""
Local _cQuery       := ""
Local _cEstado      := ""

Local _nRanking     := 0

Default _lVarMem    := .F.
Default _lProspect  := .F.


_cEstado    := IIF(_lVarMem , M->A1_EST        , SA1->A1_EST)
_cCodMun    := IIF(_lVarMem , M->A1_COD_MUN    , SA1->A1_COD_MUN)

_cQuery := " SELECT " + CRLF
_cQuery += "     ZZ6_FILFAT " + CRLF 
_cQuery += "     ,ZZ6_EST " + CRLF 
_cQuery += "     ,ZZ6_CODMUN " + CRLF 
_cQuery += "     ,(NIVEL01+NIVEL02) AS RANKING " + CRLF
_cQuery += " FROM ( " + CRLF
_cQuery += "     SELECT " + CRLF
_cQuery += "         ZZ6_FILFAT " + CRLF
_cQuery += "         ,ZZ6_EST " + CRLF 
_cQuery += "         ,ZZ6_CODMUN " + CRLF 
_cQuery += "         ,(CASE WHEN ZZ6_EST = '" + _cEstado + "'   THEN 1 ELSE 0 END) AS NIVEL01 " + CRLF
_cQuery += "         ,(CASE WHEN ZZ6_CODMUN = '" + _cCodMun + "'  THEN 1 ELSE 0 END) AS NIVEL02 " + CRLF
_cQuery += "     FROM " + RetSqlName("ZZ6") + " ZZ6 (NOLOCK) " + CRLF
_cQuery += "     WHERE " + CRLF
_cQuery += "         ZZ6_FILIAL = '" + xFilial("ZX9") + "' " + CRLF
_cQuery += "         AND (ZZ6_EST = '**'		OR ZZ6_EST    = '" + _cEstado + "'  ) " + CRLF
_cQuery += "         AND (ZZ6_CODMUN = '** '    OR ZZ6_CODMUN = '" + _cCodMun + "' ) " + CRLF
_cQuery += "         AND ZZ6.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ) TAB " + CRLF
_cQuery += " ORDER BY (NIVEL01+NIVEL02) DESC " + CRLF

_cAliasT := MPSysOpenQuery(_cQuery)

If (_cAliasT)->( Eof() )
    _aFilFat     := {{"","",0}}
Else
    While (_cAliasT)->(!Eof())

        If (_cAliasT)->RANKING < _nRanking 
            EXIT
        EndIf
            
        aAdd( _aFilFat, {  PadR((_cAliasT)->ZZ6_FILFAT,TamSx3("DA1_CODTAB")[1]),;
                            (_cAliasT)->RANKING } )

        _nRanking := (_cAliasT)->RANKING

        (_cAliasT)->( dbSkip() )
    EndDo
EndIf

(_cAliasT)->( dbCloseArea() )

RestArea(_aAreaSA1)
RestArea(_aArea)

Return _aFilFat

//-------------------------------------------------------------------
/*/{Protheus.doc} fSalvArq
Rotina para gerar relatorio de log.

@author  Wilson A. Silva Jr
@since   30/03/2020
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function fSalvArq(_aClientes)

Private cDesc1      := 'Atualizacao de Tabela de Preço dos Clientes'
Private cDesc2      := ''
Private cDesc3      := ''
Private Cabec1      := ''
Private Cabec2      := ''
Private aOrd        := {}
Private Titulo      := 'Relatorio de Atualizacao de Tabela de Preço dos Clientes'
Private aMeses      := {}
Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ''
Private Limite      := 132
Private Tamanho     := 'M'
Private NomeProg    := 'ImpComPrd'
Private nTipo       := 18
Private aReturn     := { 'Zebrado', 1, 'Administracao', 2, 1, 1, '', 1}
Private nLastKey    := 0
Private Cbcont      := 00
Private m_pag       := 01
Private wnrel       := 'ImpComPrd'

oReport := ReportDef(_aClientes)
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Rotina para gerar relatorio de log.

@author  Wilson A. Silva Jr
@since   30/03/2020
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ReportDef(_aClientes)

Local oReport
Local oSection1

oReport := TReport():New("DNFATA01","LOG de Atualizacao dos Clientes","",{ |oReport| ReportPrint(oReport,_aClientes)},"Imprime LOG com as informações da atualizacao de clientes.")
oReport:SetLandScape(.T.)

oSection1 := TRSection():New(oReport,"Log de Atualizacao",{})

TRCell():New(oSection1,"CODCLI",,"Codigo"       ,,,.F.,)
TRCell():New(oSection1,"LOJCLI",,"Loja"         ,,,.F.,)
TRCell():New(oSection1,"NOMCLI",,"Nome"         ,,TamSx3("A1_NOME")[1],.F.,)
TRCell():New(oSection1,"GRPANT",,"Filial Fat." ,,,.F.,)
TRCell():New(oSection1,"MENSAG",,"Mensagem"     ,,180,)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Rotina para gerar relatorio de log.

@author  Wilson A. Silva Jr
@since   30/03/2020
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, _aClientes)

Local oSection1 := oReport:Section(1)
Local nX

oReport:SetMeter(Len(_aClientes))

oSection1:Init()

For nX := 1 To Len(_aClientes)

    oReport:IncMeter()
	
    oSection1:Cell("CODCLI"):SetBlock( {|| _aClientes[nX][1] } )
	oSection1:Cell("LOJCLI"):SetBlock( {|| _aClientes[nX][2] } )
	oSection1:Cell("NOMCLI"):SetBlock( {|| _aClientes[nX][3] } )
	oSection1:Cell("GRPANT"):SetBlock( {|| _aClientes[nX][4] } )
	oSection1:Cell("MENSAG"):SetBlock( {|| _aClientes[nX][5] } )
	
	oSection1:PrintLine()
Next nX

oSection1:Finish()

Return .T.

/***************************************************************************/
/*/{Protheus.doc} PosVldMdl
    @description Valida modelo após a confirmação
    @type  Static Function
    @author Bernard M. Margarido
    @since 11/09/2020
/*/
/***************************************************************************/
Static Function PosVldMdl(_oModel)

Return .T.

/***************************************************************************/
/*/{Protheus.doc} MenuDef
    @description Menu especifico regras tabelas de preço
    @type  Static Function
    @author Bernard M. Margarido
    @since 11/09/2020
/*/
/***************************************************************************/
Static Function MenuDef()
Local _aRotina := {}  // Recebe o Array de Rotinas
	
	ADD OPTION _aRotina TITLE 'Visualizar'          ACTION 'VIEWDEF.DNFATA01'                   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION _aRotina TITLE 'Incluir'             ACTION 'VIEWDEF.DNFATA01'                   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION _aRotina TITLE 'Alterar'             ACTION 'VIEWDEF.DNFATA01'                   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION _aRotina TITLE 'Excluir'             ACTION 'VIEWDEF.DNFATA01'                   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION _aRotina TITLE 'Atualiza Clientes'   ACTION 'StaticCall(DNFATA01,DNFATA01A)'     OPERATION 8     ACCESS 0 //OPERATION 8
    ADD OPTION _aRotina TITLE 'Copiar'              ACTION 'StaticCall(DNFATA01,DNFATA01C)'     OPERATION 9     ACCESS 0 //Rotina Copiar 

Return _aRotina

