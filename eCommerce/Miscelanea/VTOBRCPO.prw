#INCLUDE "PROTHEUS.CH"

/**************************************************************************/
/*/{Protheus.doc} nomeFunction
    @description Retorna campos obrigatorios 
    @type  Function
    @author Bernard M. Margarido
    @since 18/02/2020
/*/
/**************************************************************************/
User Function VTOBRCPO()
Local _aArea    := GetArea()

Private _cAlias     := ""
Private _oExcel     := Nil
Private _oExcelApp  := Nil
_cAlias := FWInputBox("Informe a tabela","")

FwMsgRun(,{|_oSay| VtoBrCpoA(_oSay)},"Aguarde....","Gerando arquivo...")

RestArea(_aArea)
Return Nil

/**************************************************************************/
/*/{Protheus.doc} VtoBrCpoA
    @description Gerar arquivo Excel com os campos da uma tabela 
    @type  Static Function
    @author Bernard M. Margarido
    @since 18/02/2020
/*/
/**************************************************************************/
Static Function VtoBrCpoA(_oSay)
Local _aArea        := GetArea()

Local _cPath        := RTrim(GetTempPath())
Local _cXLS         := RTrim(FunName()) + "_" + _cAlias + ".xls"
Local _cNameSheet   := "TABELA_" + _cAlias
Local _cNameTab     := ""

_oSay:cCaption := "Selecionando registros " + _cAlias
ProcessMessages()

dbSelectArea("SX2")
SX2->( dbSetOrder(1) )
SX2->(dbSeek(_cAlias))
_cNameTab := RTrim(X2Nome())

_oExcel:= FwMsExcel():New()
_oExcel:AddworkSheet(_cNameSheet)
_oExcel:AddTable(_cNameSheet,_cNameTab)

_oExcel:AddColumn(_cNameSheet,_cNameTab,"Campo",1,1)
_oExcel:AddColumn(_cNameSheet,_cNameTab,"Tipo",1,1)
_oExcel:AddColumn(_cNameSheet,_cNameTab,"Tamanho",1,1)
_oExcel:AddColumn(_cNameSheet,_cNameTab,"Decimal",1,1)
_oExcel:AddColumn(_cNameSheet,_cNameTab,"Titulo",1,1)
_oExcel:AddColumn(_cNameSheet,_cNameTab,"ComboBox",1,1)
_oExcel:AddColumn(_cNameSheet,_cNameTab,"Obrigatorio",1,1)

//------------------+
// Posiciona tabela | 
//------------------+
dbSelectArea("SX3")
SX3->( dbSetOrder(1) )
SX3->( dbSeek(_cAlias) )
While SX3->( !Eof() .And. SX3->X3_ARQUIVO == _cAlias )   
    _oSay:cCaption := "Criando linhas " + _cAlias + " Campo " + SX3->X3_CAMPO
    ProcessMessages()

    _oExcel:AddRow( _cNameSheet,;
                    _cNameTab,;
                    {  RTrim(SX3->X3_CAMPO)    ,;
                       SX3->X3_TIPO            ,;
                       SX3->X3_TAMANHO         ,;
                       SX3->X3_DECIMAL         ,;
                       RTrim(SX3->X3_TITULO)   ,;
                       RTrim(SX3->X3_CBOX)     ,;
                       IIF(X3Obrigat(SX3->X3_CAMPO),"Sim","Não")})
    SX3->( dbSkip() )
EndDo

_oSay:cCaption := "Gerando Excel " + _cXLS
ProcessMessages()

_oExcel:Activate()
_oExcel:GetXMLFile(_cXLS)
//_oExcel:DeActivate()

CpyS2T( _cXLS , _cPath, .T. )
ShellExecute("open", _cPath + _cXLS, "", _cPath, 3 )

/*
_oExcelApp := MsExcel():New()
_oExcelApp:WorkBooks:Open(_cPath + _cXLS) // Abre a planilha
_oExcelApp:SetVisible(.T.)
*/
RestArea(_aArea)
Return .T.