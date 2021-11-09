#INCLUDE "TBICONN.CH"
#INCLUDE "PCPA107.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWCOMMAND.CH"
#DEFINE _CRLF CHR(13)+CHR(10)
#DEFINE _NEWLINE chr(13)+chr(13)


Static lA710SINI     := ExistBlock("A710SINI")
Static lA710REV      := ExistBlock("A710REV")
Static lPeMT710EXP   := ExistBlock("MT710EXP")
Static lM710Qtde     := ExistBlock("M710QTDE")
Static lA710PAR      := ExistBlock("A710PAR")
Static lUsaMOpc      := If(SuperGetMv('MV_REPGOPC',.F.,"N") == "S",.T.,.F.)
Static lGeraTrans    := SuperGetMv('MV_MRPGETR',.F.,"1")
Static lGestEmp      := fIsCorpManage()
Static cDadosProd    := Alltrim(SuperGetMV("MV_ARQPROD",.F.,"SB1"))     // Projeto Implementacao de campos MRP e FANTASM no SBZ
Static lIsADVPR

STATIC lPCPREVATU	   := FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
/*
   lGeraTrans: 1 -> Não gera transferência
               2 -> Cria as sugestões de transferência (SOU)
               3 -> Gera as transferências (MATA311)
*/

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} PCPA107
MRP Multi-empresa

@author Lucas Konrad França
@since 13/11/2014
@version P12
@obs Programa cópia do MATA712, alterado para considerar multi-empresas.
/*/
/*-------------------------------------------------------------------*/
Function PCPA107(lParBatch, aParAuto)

Static cUsrAtu

//Inicializa variáveis locais
Local cSavAlias   := Alias()
Local cVarQ       := ""
Local cVarQ2      := ""
Local cCapital    := ""
Local cStrTipo    := ""
Local cStrGrupo   := ""
Local cUsrAtu     := ""
Local cFunName    := FunName()
Local nOk         := 0
Local nzz         := 0
Local nInd        := 0
Local nI          := 0
Local aRetPar     := {}
Local aTreeProc   := {}
Local bBlNewProc  := {|oCenterPanel|A107MCond(@cStrTipo,@cStrGrupo),PCPA107INP(lPedido,lVisualiza,cStrTipo,cStrGrupo,oCenterPanel)}
Local lUsaNewPrc  := UsaNewPrc()
Local lOkExec     := .T.
Local lVisualiza  := .F.
Local lError   := .F.
Local aTipos        := {}

//Inicializa variáveis de interface
Local oUsado,oChk,oChk2,oChk3,oQual,oQual2,oPer,oChkQual,lQual,oChkQual2,lQual2

//Inicializa variáveis private
PRIVATE nQuantPer    := 030
PRIVATE nUsado    := 1
PRIVATE nTamTipo711  := TamSX3("B1_TIPO")[1]
PRIVATE nTamGr711    := TamSX3("B1_GRUPO")[1]
PRIVATE nRecZero     := 1
PRIVATE oOk          := LoadBitmap( GetResources(), "LBOK")
PRIVATE oNo          := LoadBitmap( GetResources(), "LBNO")
PRIVATE aLogMRP710   := {}
PRIVATE A711Tipo     := {}
PRIVATE A711Grupo    := {}
PRIVATE aPergs711    := {}
PRIVATE aAuto        := aClone(aParAuto)
PRIVATE lGeraPI      := GETMV("MV_GERAPI")
PRIVATE lDigNumOp    := .F.
PRIVATE lPedido      := .F.
PRIVATE lLogMRP      := .F.
PRIVATE cCadastro    := STR0001  //"MRP"
PRIVATE cPictB2Local := PesqPict("SB2","B2_LOCAL")
PRIVATE cPictB2Qatu  := PesqPict("SB2","B2_QATU")
PRIVATE cPictB2QNPT  := PesqPict("SB2","B2_QNPT")
PRIVATE cPictB2QTNP  := PesqPict("SB2","B2_QTNP")
PRIVATE cPictD7QTDE  := PesqPict("SD7","D7_QTDE")
PRIVATE cPictDDSaldo := PesqPict("SDD","DD_SALDO")
PRIVATE cAliasSOR    := "SOR"
PRIVATE cAliasSOT    := "SOT"

//Verifica a permissao do programa em relacao aos modulos
PRIVATE lBatch       := lParBatch # Nil .And. lParBatch

//Verifica se mostra logs em tela
PRIVATE lMsHelpAuto  := !(SuperGetMv("MV_HELPMRP",NIL,.T.))
PRIVATE lMostraErro  := .F.

PRIVATE aOpcoes[2][7]
PRIVATE aFilAlmox
PRIVATE aAlmoxNNR

//TES saida e entrada para geração da solicitação de transferência (MATA311) carregados na função a107CarEmp
PRIVATE cTesEntr := ""
PRIVATE cTesSaid := ""

PRIVATE aEmpCent := A107CarEmp(cEmpAnt, cFilAnt)

//Salva a empresa e filial logada, para utilização durante o processamento
PRIVATE cEmpBkp := cEmpAnt
PRIVATE cFilBkp := cFilAnt

PRIVATE cIntgPPI := "1" // Integração de OP's com o PPI através do MRP. 1 = Não integra; 2 = Gera pendência; 3 = Integra;

If !LockByName("MRPEXCL",.T.,.T.,.T.)
	Help( ,, 'PCPA107',, STR0184, 1, 0 ) //"O MRP já está sendo processado por outro usuário. Aguarde o término do processamento para executar o MRP novamente."
	Return
EndIf

cUser   := IF(cUser == NIL,RetCodUsr(),cUser)
cUsrAtu := cUser

If AMIIn(10,44,4)
   If Len(aEmpCent) < 1
      Help( ,, 'PCPA107',, STR0162, 1, 0 ) //"Não é permitido executar o MRP multi-empresa nesta empresa e filial."
      Return
   EndIf
   If !(Len(aEmpCent) == 1 .And. ;
        AllTrim(aEmpCent[1,1]) == AllTrim(cEmpAnt) .And. ;
        AllTrim(aEmpCent[1,2]) == AllTrim(cFilAnt))
      If !vldParTran()
         Return
      EndIf
   EndIf

   //Inicializa o log de processamento
   ProcLogIni({},"PCPA107")

   //Atualiza o log de processamento
   ProcLogAtu("INICIO")

   //Cria as tabelas para controle dos grupos, tipo e locais
   PCPA107TMP()

   //Monta a Tabela de Tipos
   aTipos := FWGetSX5("02")
   For nI := 1 To Len(aTipos)
      cCapital := OemToAnsi(Capital(aTipos[nI,4]))
      AADD(A711Tipo,{.T.,SubStr(aTipos[nI,3],1,nTamTipo711)+" - "+cCapital})
   Next nI

   //Monta a Tabela de Grupos
   dbSelectArea("SBM")
   dbSeek(xFilial("SBM"))
   AADD(A711Grupo,{.T.,Criavar("B1_GRUPO",.F.)+" - "+STR0003}) //"Grupo em Branco"
   Do While (BM_FILIAL == xFilial("SBM")) .AND. !Eof()
      cCapital := OemToAnsi(Capital(BM_DESC))
      AADD(A711Grupo,{.T.,SubStr(BM_GRUPO,1,nTamGr711)+" - "+cCapital})
      dbSkip()
   EndDo
   dbCloseArea()

   //------------------------------------------------------------------------------------//
   // MV_PAR01    ->  tipo de alocacao           1-p/ fim          2-p/inicio            //
   // MV_PAR02    ->  Geracao de SC.             1-p/OPs           2-p/necess.           //
   // MV_PAR03    ->  Geracao de OP PIS          1-p/OPs           2-p/necess.           //
   // MV_PAR04    ->  Periodo p/Gerar OP/SC      1-Junto           2-Separado            //
   // MV_PAR05    ->  PV/PMP De  Data                                                    //
   // MV_PAR06    ->  PV/PMP Ate Data                                                    //
   // MV_PAR07    ->  Inc. Num. OP               1- Item           2- Numero             //
   // MV_PAR08    ->  De Local                   1- Sim            2- Nao                //
   // MV_PAR09    ->  Ate Local                  1- Sim            2- Nao                //
   // MV_PAR10    ->  Gera OPs / SCs             1- Firme          2- Prevista           //
   // MV_PAR11    ->  Apaga OPs/SCs Previstas    1- Sim            2- Nao                //
   // MV_PAR12    ->  Considera Sab.?Dom.?       1- Sim            2- Nao                //
   // MV_PAR13    ->  Considera OPs Suspensas    1- Sim            2- Nao                //
   // MV_PAR14    ->  Considera OPs Sacrament    1- Sim            2- Nao                //
   // MV_PAR15    ->  Recalcula Niveis   ?       1- Sim            2- Nao                //
   // MV_PAR16    ->  Gera OPs Aglutinadas       1- Sim            2- Nao                //
   // MV_PAR17    ->  Pedidos de Venda Coloca    1- Subtrai        2- Nao Subtrai        //
   // MV_PAR18    ->  Considera Sld Estoque      1- Atual          2- Calcest            //
   // MV_PAR19    ->  Ao atingir Estoque Maximo? 1-Qtde. Original  2- Ajusta Est. Max    //
   // MV_PAR20    ->  Qtd. nossa Poder 3         1- Soma           2- Ignora             //
   // MV_PAR21    ->  Qtd. 3§ nosso Poder        1- Subtrai        2- Ignora             //
   // MV_PAR22    ->  Saldo rejeitado pelo CQ    1-Subtrai         2- Nao Subtrai        //
   // MV_PAR23    ->  PV/PMP De  Documento                                               //
   // MV_PAR24    ->  PV/PMP Ate Documento                                               //
   // MV_PAR25    ->  Saldo bloqueado            1-Subtrai         2- Nao Subtrai        //
   // MV_PAR26    ->  Considera Est. Seguranca   1-Sim     2-Nao   3- So necessidade.    //
   // MV_PAR27    ->  Ped. Venda Bloq. Credito?  1-Sim             2- Nao                //
   // MV_PAR28    ->  Mostra dados resumidos  ?  1-Sim             2- Nao                //
   // MV_PAR29    ->  Detalha lotes vencidos  ?  1-Sim             2- Nao                //
   // MV_PAR30    ->  Pedidos de Venda Fatura    1- Subtrai        2- Nao Subtrai        //
   // MV_PAR31    ->  Considera Ponto de Pedido  1- Sim            2- Nao                //
   // MV_PAR32    ->  Gera tabela necessidades   1- Sim            2- Nao                //
   // MV_PAR33    ->  Data inicial Ped Faturados                                         //
   // MV_PAR34    ->  Data final Ped Faturados                                           //
   //------------------------------------------------------------------------------------//

   //Ponto de entrada para alterar a parametrizacao inicial do MRP
   If lA710PAR
      aRetPar := ExecBlock("A710PAR",.F.,.F.,{nUsado,nQuantPer,a711Tipo,a711Grupo,lPedido})
      If Len(aRetPar[1]) == 5
         For nInd :=1 to Len(aRetPar[1])
            //Valida os valores numericos
            If nInd == 1
               If ValType(aRetPar[1][nInd]) # "N"
                  lOkExec:=.F.
                  Exit
               Else
                  If aRetPar[1][nInd] < 1 .Or. aRetPar[1][nInd] > 7
                     lOkExec := .F.
                     Exit
                  EndIf
               EndIf
            //Valida os valores numericos
            ElseIf nInd == 2
               If ValType(aRetPar[1][nInd]) # "N"
                  lOkExec:=.F.
                  Exit
               EndIf
            //Valida os valores array
            ElseIf nInd == 3 .Or. nInd == 4
               //Valida o conteudo dos arrays
               If ValType(aRetPar[1][nInd]) == "A"
                  For nzz:=1 to Len(aRetPar[1][nInd])
                     If ValType(aRetPar[1][nInd,nzz,1]) # "L" .Or. ValType(aRetPar[1][nInd,nzz,2]) # "C"
                        lOkExec:=.F.
                        Exit
                     EndIf
                  Next nzz
               Else
                  lOkExec:=.F.
                  Exit
               EndIf
            //Valida o valor logico
            ElseIf nInd == 5 .And. ValType(aRetPar[1][nInd]) # "L"
               lOkExec:=.F.
               Exit
            EndIf
         Next nInd

         //Assume valores retornados pelo ponto de entrada
         If lOkExec
            nUsado   :=aRetPar[1][1]
            nQuantPer:=aRetPar[1][2]
            a711Tipo :=aRetPar[1][3]
            a711Grupo:=aRetPar[1][4]
            lPedido  :=aRetPar[1][5]
         EndIf
      EndIf
   EndIf

   If !lBatch
      If lUsaNewPrc
         aAdd(aTreeProc,{OemToAnsi(STR0004),{|oCenterPanel|A107MontPer(oCenterPanel)},"filtro1"})
         aAdd(aTreeProc,{OemToAnsi(STR0005),{|oCenterPanel|A107MontVis(oCenterPanel,@lVisualiza)},"watch"})

         tNewProcess():New("PCPA107",OemToAnsi(STR0001),bBlNewProc,OemToAnsi(STR0006)+_NEWLINE+OemToAnsi(STR0007)+_NEWLINE+OemToAnsi(STR0008),"MTA712",aTreeProc)
      Else
         DEFINE MSDIALOG oDlg TITLE cCadastro From 145,0 To 445,628 OF oMainWnd PIXEL
         @ 10,15 TO 129,115 LABEL STR0009 OF oDlg  PIXEL //"Periodicidade do MRP"
         @ 25,20 RADIO oUsado VAR nUsado 3D SIZE 70,10 PROMPT  OemToAnsi(STR0010),; //"Periodo Diário"
                                                               OemToAnsi(STR0011),; //"Periodo Semanal"
                                                               OemToAnsi(STR0012),; //"Periodo Quinzenal"
                                                               OemToAnsi(STR0013),; //"Periodo Mensal"
                                                               OemToAnsi(STR0014),; //"Periodo Trimestral"
                                                               OemToAnsi(STR0015),; //"Periodo Semestral"
                                                               OemToAnsi(STR0016) OF oDlg PIXEL //"Periodos Diversos"
         @ 102,020 Say OemToAnsi(STR0017) SIZE 60,10 OF oDlg PIXEL //"Quantidade de Periodos:"
         @ 102,085 MSGET nQuantPer Picture "999" Valid Positivo() .And. NaoVazio() SIZE 15,10 OF oDlg PIXEL
         @ 10,130 TO 129,300 LABEL "" OF oDlg PIXEL
         @ 16,135 CHECKBOX oChk  VAR lPedido PROMPT OemToAnsi(STR0018) SIZE 85, 10 OF oDlg PIXEL ;oChk:oFont := oDlg:oFont //"Considera Pedidos em Carteira"
         @ 26,135 CHECKBOX oChk2 VAR lLogMRP PROMPT OemToAnsi(STR0019) SIZE 85, 10 OF oDlg PIXEL ;oChk2:oFont := oDlg:oFont   //"Log de eventos do MRP"
         @ 36,135 CHECKBOX oChkQual VAR lQual  PROMPT OemToAnsi(STR0020) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(a711Tipo , {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.)) //"Inverter Selecao"
         @ 47,130 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0021)  SIZE 78,081 ON DBLCLICK (A711Tipo:=CA107Troca(oQual:nAt,A711Tipo),oQual:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual,oOk,oNo,@A711Tipo) NoScroll OF oDlg PIXEL   //"Tipos de Material"
         oQual:SetArray(A711Tipo)
         oQual:bLine := { || {If(A711Tipo[oQual:nAt,1],oOk,oNo),A711Tipo[oQual:nAt,2]}}
         @ 37,226 CHECKBOX oChkQual2 VAR lQual2 PROMPT OemToAnsi(STR0020) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(a711Grupo, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}),oQual2:Refresh(.F.)) //"Inverter Selecao"
         @ 47,221 LISTBOX oQual2 VAR cVarQ2 Fields HEADER "",OemToAnsi(STR0022)  SIZE 78,081 ON DBLCLICK (A711Grupo:=CA107Troca(oQual2:nAt,A711Grupo),oQual2:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual2,oOk,oNo,@A711Grupo) NoScroll OF oDlg  PIXEL   //"Grupos de Material"
         oQual2:SetArray(A711Grupo)
         oQual2:bLine := { || {If(A711Grupo[oQual2:nAt,1],oOk,oNo),A711Grupo[oQual2:nAt,2]}}
         DEFINE SBUTTON FROM 134,180 TYPE 5 ACTION (Pergunte("MTA712",.T.),A107FilAlm(.T.)) ENABLE OF oDlg
         DEFINE SBUTTON FROM 134,210 TYPE 15 ACTION (nOk:=1,oDlg:End(),lVisualiza:=.T.) ENABLE OF oDlg
         DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION (PCP107OK(@nOK,A711Tipo,A711Grupo),IIf(nOk=1,oDlg:End(),)) ENABLE OF oDlg
         DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
         ACTIVATE MSDIALOG oDlg CENTERED
      EndIf
   Else
      nUsado    := aAuto[1]
      nQuantPer := aAuto[2]
      If ValType(aAuto[3]) == "L"
         lPedido   := aAuto[3]
      Endif
      If ValType(aAuto[4]) == "A"
         a711Tipo := aAuto[4]
      Endif
      If ValType(aAuto[5]) == "A"
         a711Grupo := aAuto[5]
      Endif
      If ValType(aAuto[7]) == "L"
         lLogMRP := aAuto[7]
      EndIf
      nOk := 1
   Endif

   If nOk = 1
      If !lBatch
         //Atualiza as coordenadas da Janela Principal
         oMainWnd:CoorsUpdate()
      EndIf
      If !lUsaNewPrc
            A107MCond(@cStrTipo,@cStrGrupo)
            If !lVisualiza
               A107VldTbl(@lError)
            EndIf
            SetFunName(cFunName)
            If lError
               nOk := 1
               Return .F.
            EndIf
            __cUserId := cUsrAtu

            //Não está sendo utilizada a função Processa, pois quando é alterada a empresa, a barra de progresso deixa de funcionar.
            A107Proc("1",{lPedido,lVisualiza,cStrTipo,cStrGrupo},lBatch)
      EndIf
   Endif
   DeleteObject(oOk)
   DeleteObject(oNo)

   //Atualiza o log de processamento
   ProcLogAtu("FIM")
EndIf

dbSelectArea(cSavAlias)
cEmpAnt := cEmpBkp
cFilAnt := cFilBkp
UnLockByName("MRPEXCL",.T.,.T.,.T.)
RETURN

/*------------------------------------------------------------------------//
//Programa: A107FilAlm
//Autor:    Andre Anjos
//Data:     20/08/12
//Descricao:   Filtra armazens por range quando MV_MRPFILA ativo.
//Parametros:  lSeleciona: indica se abre tela de selecao.
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107FilAlm(lSeleciona)
Local aDados  := {}
Local oDlg    := NIL
Local oBrw     := NIL
Local nInd     := 0
Local cAlmDe  := If(lSeleciona,mv_par08,aPergs711[8])
Local cAlmAte := If(lSeleciona,mv_par09,aPergs711[9])
Local cSql     := ""
local n
Default lSeleciona := .F.

//Empresa Logada
NNR->(dbSetOrder(1))
NNR->(dbSeek(xFilial("NNR")))
While !NNR->(EOF()) .And. NNR->NNR_FILIAL == xFilial("NNR")
	If NNR->NNR_CODIGO >= cAlmDe .And. NNR->NNR_CODIGO <= cAlmAte .And. NNR->NNR_MRP # '2'
    	aAdd(aDados,{.T.,CEMPANT,CFILANT,NNR->NNR_CODIGO,NNR->NNR_DESCRI})
	EndIf
	NNR->(dbSkip())
End

   cEmpBkp  := cEmpAnt
   cFilBkp  := cFilAnt 
   
   //DEMAIS EMP / FILIAIS

   For n := 1 to Len(AEMPCENT)
            
      A107AltEmp(AEMPCENT[n][1],AEMPCENT[n][2]) 
      
      NNR->(dbSetOrder(1))
      NNR->(dbSeek(xFilial("NNR")))
      While !NNR->(EOF()) .And. NNR->NNR_FILIAL == xFilial("NNR")
         If NNR->NNR_CODIGO >= cAlmDe .And. NNR->NNR_CODIGO <= cAlmAte .And. NNR->NNR_MRP # '2'
            aAdd(aDados,{.T.,AEMPCENT[n][1],AEMPCENT[n][2],NNR->NNR_CODIGO,NNR->NNR_DESCRI})
         EndIf
         NNR->(dbSkip())
      End

   Next n 

   A107AltEmp(cEmpBkp,cFilBkp) 


If SuperGetMV("MV_MRPFILA",.F.,.F.)
   If lSeleciona .And. !Empty(aDados)
      oDlg := MSDialog():New(0,0,280,390,STR0023,,,,,,,,oMainWnd,.T.) //Seleção de armazéns
      oDlg:nStyle := DS_MODALFRAME
      oDlg:lEscClose := .F.
      TSay():Create(oDlg,{|| STR0024},05,05,,,,,,.T.,,,200,10) //Selecione os armazéns cujos saldos devem ser considerados no cálculo MRP:
      oBrw := TWBrowse():New(20,05,190,100,{|| {If(aDados[oBrw:nAt,1],oOk,oNo),aDados[oBrw:nAt,2],aDados[oBrw:nAt,3],aDados[oBrw:nAt,4],aDados[oBrw:nAt,5]}},{"","Empresa","Filial",RetTitle("NNR_CODIGO"),RetTitle("NNR_DESCRI")},,oDlg,,,,,{|| aDados[oBrw:nAt,1] := !aDados[oBrw:nAt,1],oBrw:Refresh()},,,,,,,,,.T.)
      oBrw:SetArray(aDados)
      oBrw:bLine := {|| {If(aDados[oBrw:nAt,1],oOk,oNo),aDados[oBrw:nAt,2],aDados[oBrw:nAt,3],aDados[oBrw:nAt,4],aDados[oBrw:nAt,5]}}
      TButton():Create(oDlg,125,5,STR0025,{|| oDlg:End()},70,10,,,,.T.) //Confirmar
      oDlg:Activate(,,,.T.)
   EndIf
EndIf

//Limpa a tabela
cSql := " DELETE FROM SOQNNR "
TCSQLExec(cSql)

aAlmoxNNR := {}
For nInd := 1 TO Len(aDados)
   If aDados[nInd][1] == .T.
      Aadd(aAlmoxNNR,{aDados[nInd][2]})

      //Insere na tabela
      cSql := " INSERT INTO SOQNNR (NR_LOCAL,NR_EMP,NR_FILIAL, R_E_C_N_O_) VALUES ('" + aDados[nInd][4] + "'," +"'" + aDados[nInd][2]  + "',"+"'" + aDados[nInd][3]  + "',"+ Str(nInd) + ") "
      TCSQLExec(cSql)
   EndIf
Next nInd

Return

/*------------------------------------------------------------------------//
//Programa: CA107Troca
//Autor:    Rodrigo de Almeida Sartorio
//Data:     20/08/12
//Descricao:   Troca marcador entre x e branco
//Parametros:  nIt      - Linha onde o click do mouse ocorreu
//          aArray   - Array com as opcoes para selecao
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function CA107Troca(nIt,aArray)

aArray[nIt,1] := !aArray[nIt,1]

Return aArray

/*------------------------------------------------------------------------//
//Programa: PCP107OK
//Autor:    Rodrigo de Almeida Sartorio
//Data:     20/08/12
//Descricao:   Confirmacao antes de executar o MRP
//Parametros:  nOk         - Variavel numerica com o retorno
//          a711Tipo - Array com os tipos disponiveis para selecao
//          a711Grupo   - Array com os grupos disponiveis para selecao
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PCP107OK(nOK,A711Tipo,A711Grupo)

Local aButtons := {STR0026, STR0027, STR0028} //"Log Ativo","Log Inativo","Cancelar"
Local nRet     := 0
Local lRet     := .T.
Local nAcho1   := Ascan(A711Tipo,{|x| x[1] == .T.})
Local nAcho2   := Ascan(A711Grupo,{|x| x[1] == .T.})
Local nI       := 0
Local cBkpEmp  := cEmpAnt
Local cBkpFil  := cFilAnt
If nAcho1 = 0 .Or. nAcho2 = 0
   Help(" ",1,"A711MENU")
   lRet := .F.
EndIf

If ExistBlock( "MTA710AP" )
   lRet := ExecBlock("MTA710AP",.F.,.F.)
   If ValType(lRet) <> "L"
      lRet:=.T.
   EndIf
Endif

/*
   Verifica se existe uma thread da integração das ordens de produção do MRP em execução.
   se estiver, não deixa realizar o processamento.
*/
If lRet
	For nI := 1 To Len(aEmpCent)
		NGPrepTBL({{"SOD",1},{"SOE",1}},aEmpCent[nI][1],AllTrim(aEmpCent[ni][2]))
		If PCPIntgPPI()
			//Busca o parâmetro de integração de OP's com o PPI.
			cIntgPPI := PCPIntgMRP()
			If cIntgPPI != "1"
			   cValue := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2]))
			   If !Empty(cValue) .And. (cValue != "3" .And. cValue != "30")
			      MsgInfo(STR0181,STR0030) //"A integração das ordens de produção com o Totvs MES ainda está em processamento. Execução do MRP não permitida neste momento." "Atenção"
			      lRet := .F.
			      Exit
			   EndIf
			EndIf
		EndIf
	Next nI
	NGPrepTBL({{"SOD",1},{"SOE",1}},cBkpEmp,cBkpFil)
EndIf

If lRet
   lRet := IIf(MsgYesNo(OemToAnsi(STR0029),OemToAnsi(STR0030)),nOk:=1,nOk:=2) //"Confirma o MRP?
EndIf

If lLogMrp .And. lRet == 1
   nRet := Aviso(STR0030,STR0031,aButtons) //"O log de eventos está ativo e isto aumentará o tempo de processamento da rotina. Como deseja prosseguir?"
   If nRet == 2
      lLogMrp := .F.
   ElseIf nRet == 3
      nOk := 2
   Endif
EndIf

Return lRet

/*------------------------------------------------------------------------//
//Programa: A107MCond
//Autor:    Lucas Konrad França
//Data:     01/12/2013
//Descricao:   Rotina que monta condicao default da projecao, strings de
//            filtro para tipos e grupos e array aPergs711
//Parametros:  cStrTipo - String de tipo de produto
//          cStrGrupo   - String de grupo de produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107MCond(cStrTipo,cStrGrupo)
Local nZ       := 0
Local cInsert := ""

//Monta condicao default da projecao
For nz:=1 to 7
   If nUsado = nz
      aOpcoes[1][nz] := "x"
   Else
      aOpcoes[1][nz] := " "
   EndIf
Next nz
aOpcoes[2][1] := nQuantPer  // Numero de Periodos

//Move A711Tipo para aStrTipo
cStrTipo := Criavar("B1_TIPO",.f.)+"|"
FOR nZ:=1 TO LEN(A711Tipo)
   If A711Tipo[nZ,1]
      //Inclui na tabela
      cInsert := " INSERT INTO SOQTTP (TP_TIPO, R_E_C_N_O_) VALUES ('" + SubStr(A711Tipo[nZ,2],1,nTamTipo711) + "'," + Str(nZ) + ") "
      TCSQLExec(cInsert)
      cStrTipo += SubStr(A711Tipo[nZ,2],1,nTamTipo711)+"|"
   EndIf
Next nZ

//Move A711Grupo para aStrGrupo
FOR nZ:=1 TO LEN(A711Grupo)
   If A711Grupo[nZ,1]
      //Inclui na tabela
      cInsert := " INSERT INTO SOQTGR (GR_GRUPO, R_E_C_N_O_) VALUES ('" + SubStr(A711Grupo[nZ,2],1,nTamGr711) + "'," + Str(nZ) + ") "
      TCSQLExec(cInsert)
      cStrGrupo += SubStr(A711Grupo[nZ,2],1,nTamGr711)+"|"

   EndIf
Next nZ

//Alimenta array aPergs711 com os dados do SX1
Pergunte("MTA712",.F.)
aPergs711 := Array(34)
For nZ := 1 To Len(aPergs711)
   aPergs711[nZ] := &("mv_par"+StrZero(nZ,2))
Next nZ

//Filtra armazens conforme MV_MRPFILA e NNR_MRP
If aAlmoxNNR == NIL
   A107FilAlm(.F.)
EndIf

Return

/*------------------------------------------------------------------------//
//Programa: PCPA107INP
//Autor:    Lucas Konrad França
//Data:     20/11/2014
//Descricao:   Funcao que dispara todo processo de montagem da interface
//Parametros:  lPedido     - Indica se considera pedidos de venda no MRP
//             lVisualiza     - Indica se esta utilizando visualizacao do MRP
//             cStrTipo    - String com tipos a serem processados
//             cStrGrupo      - String com grupos a serem processados
//             oCenterPanel   - Objeto do painel da tela
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PCPA107INP(lPedido,lVisualiza,cStrTipo,cStrGrupo,oCenterPanel)
//Variaveis array
Local aStru2         := {}
Local aOpc           := {}
Local aListaJob      := {}
Local aParamJob      := {}
Local aThreads       := {}
Local aJobAux        := {}
Local aButtons       := {}
Local aADDButtons    := {}
Local aCampos        := {}
Local aTamQuant      := TamSX3("B2_QFIM")
Local aPages         := {"HEADER","HEADER"}
Local aTitles        := {STR0032,STR0033} //"Dados"###Legenda
Local aSize          := MsAdvSize()
Local aEmpresas      := {}

//Variaveis lógicas
Local M710Niv        := .F.
Local lAtvFilTmp     := .F.
Local lParResu       := .F.
Local lThreads       := .F.
Local lConsSusp      := aPergs711[13] == 1
Local lConsSacr      := aPergs711[14] == 1
Local lCalcNivelEstr := aPergs711[15] == 1
Local lPedBloc       := aPergs711[27] == 1
Local lFlatMode      := FlatMode()
Local lA710SQL       := ExistBlock("A710SQL")
Local lM710NOPC      := ExistBlock("M710NOPC")
Local lExistBB1      := ExistBlock("A710FILALM")
Local lExistBB2      := ExistBlock("MT710B2")
Local lConsPreRe     := SuperGetMV("MV_MRPSCRE",.F.,.T.) == .T.
Local lMRPCINQ       := SuperGetMV("MV_MRPCINQ",.F.,.F.)
Local lAllTp         := Ascan(A711Tipo,{|x| x[1] == .F.}) == 0
Local lAllGrp        := Ascan(A711Grupo,{|x| x[1] == .F.}) == 0
Local lShAlt         := If(ExistBlock("M710ShAlt"),execblock('M710SHAlt',.F.,.F.),.F.)
Local lVerTipo       := Ascan(A711Tipo,{|x| x[1] == .F.}) == 0
Local lVerGrupo      := Ascan(A711Grupo,{|x| x[1] == .F.}) == 0
Local lProcSC4       := .T.

//Variaveis char
Local cAliasTop      := ""
Local cAliasDoc      := GetNextAlias()
Local cMsgAviso      := ""
Local cMsgPontP      := ""
Local cBotFun        := ""
Local cTopFun        := ""
Local cQueryB1       := ""
Local cFileJob       := ""
Local cComp1         := CriaVar("C6_BLQ")
Local cComp2         := "N"+Space(Len(cComp1)-1)
Local cNumOpDig      := Criavar("C2_NUM",.F.)
Local cOpc711Vaz     := CriaVar("C2_OPC",.F.)
Local cRev711Vaz     := CriaVar("B1_REVATU",.F.)
Local cStartPath     := GetSrvProfString("Startpath","")
Local cTxtEstSeg     := RetTitle("B1_ESTSEG")
Local cTxtPontPed    := RetTitle("B1_EMIN")
Local cRevisao       := Nil
Local cQuery         := ""
Local cSelOpc        := SuperGetMv('MV_SELEOPC',.F.,'N')

//Variaveis date
Local dInicio        := dDataBase

//Variaveis numéricas
Local z              := 0
Local nCount         := 0
Local nz             := 0
Local nx             := 0
Local nSaldo         := 0
Local nEstSeg        := 0
Local nQtdAviso      := 0
Local nPontoPed      := 0
Local nQtdPontP      := 0
Local i              := 0
Local nRetry_0       := 0
Local nRetry_1       := 0
Local nHandle        := 0
Local nPoLin         := 0
Local nLin           := 0
Local nInd           := 0
Local nCol           := aSize[5]-300
Local nPeriodos      := aOpcoes[2][1]
Local nQtd           := 20
Local nTamFil        := TamSX3("OQ_FILEMP")[1]

Local DatFim

//Variaveis do tipo objeto
Local oFont,oDlg,oBmp,oMenu1,oMenu2

//Variaveis PRIVATE
PRIVATE bChange      := {|| Nil }
PRIVATE c711NumMRP   := ""
PRIVATE cIndSB6      := ""
PRIVATE nIndSB6      := ""
PRIVATE cMT710B2     := ""
PRIVATE cProdDetSld  := ""
PRIVATE cFilNess     := ""
PRIVATE cAlmoxd      := aPergs711[8]
PRIVATE cAlmoxa      := aPergs711[9]
PRIVATE cPictQuant   := PesqPictQt("B2_QFIM",aTamQuant[1]+2)
PRIVATE cPictLOCAL   := PesqPict("SB2","B2_LOCAL")
PRIVATE cPictQATU    := PesqPict("SB2","B2_QATU")
PRIVATE cPictQNPT    := PesqPict("SB2","B2_QNPT")
PRIVATE cPictQTNP    := PesqPict("SB2","B2_QTNP")
PRIVATE cPictQTDE    := PesqPict("SD7","D7_QTDE")
PRIVATE cPictSALDO   := PesqPict("SDD","DD_SALDO")
PRIVATE cSelPer      := cSelPerSC :=""
PRIVATE cSelF        := cSelFSC :=""
PRIVATE cFilSB1Old   := SB1->(DbFilter())
PRIVATE cAliasView   := ""
PRIVATE aPeriodos    := {}
PRIVATE aDiversos    := {}
PRIVATE aDbTree      := {}
PRIVATE a711SvAlias  := {}
PRIVATE aTotais      := {{}}
PRIVATE aRecScOp     := {}
PRIVATE aTransEst    := {}
Private aSldUsado    := {}
Private aProcMRP     := {}
PRIVATE aEnch[11]
PRIVATE lAtvFilNes   := .F.
PRIVATE lVerSldSOR   := .T.
PRIVATE lAddTree     := .T.
PRIVATE lDiasHl      := .T.
PRIVATE lDiasHf      := .T.
PRIVATE nTipo        := 0
PRIVATE nTop         := If(lBatch,0,oMainWnd:nTop)
PRIVATE nLeft        := If(lBatch,0,oMainWnd:nLeft+5)
PRIVATE nBottom      := If(lBatch,0,oMainWnd:nBottom-30)
PRIVATE nRight       := If(lBatch,0,oMainWnd:nRight-10)
PRIVATE nOldEnch     := 1
PRIVATE nLdTmTrans   := 0
PRIVATE oFolder, oSay1, oSay2
PRIVATE oSayEmp      := Nil
PRIVATE aDelOpsPPI      := {}

//Variaveis do tipo objeto
PRIVATE oTreeM711,oPanelM711,oScrollM711,oBrwDet

DEFAULT lVisualiza := .F.

//Conout(Replicate("#",70))
//Conout("###--INICIO DO PROCESSAMENTO DO MRP MULTIEMPRESAS.")
//Conout("###--DATA:" + DtoC(Date()))
//Conout("###--HORA:" + TIME())
//Conout(Replicate("#",70))
If lPedido .Or. aPergs711[30] == 1
   nQtd++
EndIf
If aPergs711[1] == 2
   nQtd++
EndIf
If lLogMRP
   nQtd++
EndIf

aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nz := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. ( aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nz,1],aEmpCent[nz,2],aEmpCent[nz,3]})
   EndIf
Next nz

//Conout(Replicate("#",70))
//Conout("###--INICIO PROCESSAMENTO CALCULO MRP MULTIEMPRESAS.")
//Conout("###--DATA:" + DtoC(Date()))
//Conout("###--HORA:" + TIME())
//Conout("#####--EMPRESA/FILIAL")
//For nz := 1 To Len(aEmpresas)
	//Conout("#####--"+aEmpresas[nz,1]+"/"+aEmpresas[nz,2])
//Next nz
//Conout(Replicate("#",70))

nCount := (Len(aEmpCent)+1) * nQtd
nCount++
A107ProTot(nCount)

ProcLogAtu("MENSAGEM","Inicio calculo MRP","Inicio calculo MRP")

A107ProInc()
If SuperGetMv('MV_A710THR',.F.,1) > 1
   lThreads := .T.
Endif

A107GrvTm(oCenterPanel,STR0034) //"Inicio do Processamento."

If !lVisualiza
   PCPA107Ctb(aEmpresas)
EndIf

If UsaNewPrc()
   nLin := aSize[7]-55
Else
   nLin := aSize[7]
EndIf
nLin += 10
//Definicao dos botoes da rotina
aadd(aButtons,{'LOCALIZA'  ,{|| (A107Pesq())},STR0035} ) //"Pesquisa Produto"
aadd(aButtons,{'RELATORIO' ,{|| (lAtvFilTmp := lAtvFilNes, If(lAtvFilTmp,P107FilNec(.T.),.T.),PCPR107(.T.),If(lAtvFilTmp,P107FilNec(.T.),.T.))},STR0036}) //"Imprime MRP"
aadd(aButtons,{'BMPTRG'    ,{|| (lAtvFilTmp := lAtvFilNes, If(lAtvFilTmp,P107FilNec(.T.),.T.),A107Gera(@cNumOpDig,cStrTipo,cStrGrupo,oCenterPanel),If(lAtvFilTmp,P107FilNec(.T.),.T.),Eval(bChange)) },STR0037} ) //"Geracao de OPs/SCs"

//Define tipo de consulta de produto
If aPergs711[28]==1 .And. !lBatch
   MENU oMenu2 POPUP
      MENUITEM STR0038 ACTION (A107ExpTre(),Eval(bChange)) //"Expande Detalhes"
      MENUITEM STR0039 ACTION (A107ShPrd(),Eval(bChange))   //"Dados do Produto"
   ENDMENU

   aadd(aButtons,{'VERNOTA',{|| If(lFlatMode,oMenu2:Activate(500,47,oDlg),oMenu2:Activate(220,30,oDlg)) },STR0039})
Else
   aadd(aButtons,{'VERNOTA',{|| (A107ShPrd(),Eval(bChange)) },STR0039}) //"Dados do Produto"
EndIf

If lShAlt
   aadd(aButtons,{'SDUCOUNT' ,{|| P107ShAlt() },'Alternativos'})
EndIf

aadd(aButtons,{'FILTRO',{|| If(lFlatMode,oMenu1:Activate(nCol,nLin,oDlg),oMenu1:Activate(445,30,oDlg))},STR0040,STR0041}) //"Mostra somente as necessidades" //'Filtro'
aadd(aButtons,{'FORM',{|| A107ViewSld(aFilAlmox)},STR0042}) //"Det.Saldo"

//Executa ponto de entrada para montar array com botoes a serem apresentados na tela
If (ExistBlock( "M710BUT" ) )
   aADDButtons := ExecBlock("M710BUT",.F.,.F.)
   If ValType(aADDButtons) == "A"
      For i := 1 to Len(aADDButtons)
         AADD(aButtons,aADDButtons[i])
      Next i
   EndIf
Endif

//Caso gere o Log habilita o botao de consulta
If lLogMRP
   AADD(aButtons,{'DESTINOS' ,{|| (A107ShLog(),Eval(bChange))},STR0019,STR0043}) //"Log de eventos do MRP" //"Log"
EndIf

AADD(aButtons,{'FILTRO',{|| A107CLKBRW()}, "Saldo detalhado"})
AADD(aButtons,{'FILTRO',{|| A107DETSAL()}, "Saldo detalhado períodos"})

If !lVisualiza
   //Verifica os dados para montar/visualizar arquivos do MRP
   For i:= 1 to 7
      If aOpcoes[1][i] = "x"
         nTipo := i
      EndIf
   Next i

   //Monta as datas de acordo com os parametros
   A107AtuPeriodo(lVisualiza,@nTipo,@dInicio,@aPeriodos,aOpcoes,aStru2)
EndIf

If lVisualiza
   //Recupera parametrizacao gravada no ultimo processamento
   dbSelectArea("SOQ")
   dbSetOrder(2)
   dbSeek(xFilial("SOQ")+cEmpAnt+PadR(cFilAnt,nTamFil)+"PAR")
   While SOQ->OQ_ALIAS == "PAR"
      nTipo       := SOQ->OQ_NRRGAL
      dInicio     := SOQ->OQ_DTOG
      nPeriodos   := SOQ->OQ_QUANT
      aOpcoes[2,1]:= SOQ->OQ_QUANT

      //Verifica se o exibe os dados resumido de acordo com o ultimo calculo
      If nTipo == 7
         AADD(aDiversos,CTOD(Alltrim(SOQ->OQ_OPC)))
      EndIf

      //NUMERO DO MRP
      c711NumMRP := SOQ->OQ_NRMRP
      dbSkip()
   EndDo

   If nTipo == 7
      //Correcao do array adiversos
      aDiversos := ASORT(aDiversos)
      //Transforma data em caracter
      For i := 1 to Len(aDiversos)
         aDiversos[i] := DTOC(aDiversos[i])
      Next i
   EndIf

   //Monta as datas de acordo com os parametros
   A107AtuPeriodo(lVisualiza,@nTipo,@dInicio,@aPeriodos,aOpcoes,aStru2)
   A107GrvTm(oCenterPanel,STR0044)

   cQuery := " SELECT COUNT(*) TOTAL "
   cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ "
   cQuery +=  " WHERE SOQ.OQ_ALIAS = 'TRA'"

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDoc,.T.,.T.)

   If (cAliasDoc)->(TOTAL) > 0
      //Help( ,, 'PCPA107',, STR0173, 1, 0 ) //"Foi realizada a distribuição de ordens, os dados apresentados pelo MRP não correspondem ao cenário atual das OPs/SCs.",
      AVISO(STR0203,STR0173,{"Ok"},1) //AVISO 
   EndIf
   (cAliasDoc)->(dbCloseArea())

Else
   If (oCenterPanel <> Nil)
      oCenterPanel:SetRegua2(7)//oito processamentos
   EndIf
   // Grava as informacoes do processamento no arquivo SOQ colocando informacoes
   // que garantam que o registro nao ira aparecer
   // Alias PAR                                -> OQ_ALIAS
   // Tipo utilizado                           -> OQ_NRRGAL
   // Data inicial                             -> OQ_DTOG
   // Numero de periodos                       -> OQ_QUANT
   // Para periodos variaveis data em caracter -> OQ_OPC
   // Opca Resumido ("1" Sim / "2" Nao)        -> OQ_ITEM

   criaItProd()

   //Job para verificar onde cada produto é produzido
   PutGlbValue("A107ProdPr","0")
   GlbUnLock()
   A107ProInc()
   //Dispara thread para Stored Procedure
   StartJob("A107ProdPr",GetEnvServer(),A107ADVPR(),aEmpresas)

   If nTipo != 7
      A107CriSOQ(aPeriodos[1],/*02*/,/*03*/,/*04*/,"PAR",nTipo,/*07*/,Alltrim(Str(aPergs711[28])),/*09*/,nPeriodos,"1",.F.,/*13*/,/*14*/,.F.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,"01",/*27*/,aEmpresas)
   Else
      For i:=1 to Len(aDiversos)
         A107CriSOQ(dDatabase,/*02*/,aDiversos[i],/*04*/,"PAR",nTipo,/*07*/,Alltrim(Str(aPergs711[28])),/*09*/,Len(aPeriodos),"1",.F.,aPergs711[28]==1,/*14*/,.F.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,"01",/*27*/,aEmpresas)
      Next
   EndIf
   A107GrvTm(oCenterPanel,STR0045) //"Termino da Montagem do Arquivo de Trabalho."

   //Apaga OPs/SCs/AEs previstas                                  ³
   If aPergs711[11] == 1
      nCount := 0
      Do While (nCount <= Len(aEmpCent))
         If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
            Exit
         EndIf
         If nCount > 0
            A107AltEmp(aEmpCent[nCount][1], aEmpCent[nCount][2])
         EndIf
         If PCPIntgPPI()
            //Busca o parâmetro de integração de OP's com o PPI.
            cIntgPPI := PCPIntgMRP()
         EndIf
         //Conout("Apagando SC/OP previstas, Empresa: '"+cEmpAnt+"' Filial: '"+cFilAnt+"'")
         nCount++
         aProcMRP := {}
         aDelOpsPPI := {}
         MTApagaPre(,,,,,oCenterPanel,.T.)
         If lGeraTrans == "3" .And. Len(aProcMRP) > 0
            apagaNNT(aProcMRP)
         EndIf
         A107GrvTm(oCenterPanel,STR0046) //"Termino da delecao das OPs e SCs Previstas."
         If cIntgPPI != "1"
            //Inicia a thread para rodar a integração das OP's excluidas.
            StartJob("A107IntPPI",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,c711NumMRP,cIntgPPI,__cUserId,aDelOpsPPI,.T.)

            //Neste ponto, apenas valida se conseguiu subir a thread.
            //após subir a thread, deixa executando e antes de fechar o MRP é feita a validação da thread em execução.
            //Apenas vai fechar o MRP quando terminar o processamento da thread.
            While .T.
               Do Case
                  //TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
                  Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '0'
                     If nRetry_0 > 50
                        //Conout(Replicate("-",65))
                        //Conout("A107: "+ "Não foi possivel realizar a subida da thread 'A107IntPPI'")
                        //Conout(Replicate("-",65))

                        //Atualiza o log de processamento
                        ProcLogAtu("MENSAGEM","Não foi possivel realizar a subida da thread 'A107IntPPI'","Não foi possivel realizar a subida da thread 'A107IntPPI'")
                        Final(STR0185 )//"Não foi possivel realizar a subida da thread 'A107IntPPI'"
                     Else
                        nRetry_0 ++
                     EndIf

                  //TRATAMENTO PARA ERRO DE CONEXAO
                  Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '10'
                     If nRetry_1 > 5
                        //Conout(Replicate("-",65))
                        //Conout("PCPA107: Erro de conexao na thread 'A107IntPPI'")
                        //Conout("Numero de tentativas excedidas")
                        //Conout(Replicate("-",65))

                        //Atualiza o log de processamento
                        ProcLogAtu("MENSAGEM","PCPA107: Erro de conexao na thread 'A107IntPPI'","PCPA107: Erro de conexao na thread 'A107IntPPI'")
                        Final(STR0186) //"PCPA107: Erro de conexao na thread 'A107IntPPI'"
                     Else 
                        //Inicializa variavel global de controle de Job
                        PutGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt),"0")
                        GlbUnLock()

                        //Reiniciar thread
                        //Conout(Replicate("-",65))
                        //Conout("PCPA107: Erro de conexao na thread 'A107IntPPI'")
                        //Conout("Tentativa numero: "      + StrZero(nRetry_1,2))
                        //Conout(Replicate("-",65))

                        //Atualiza o log de processamento
                        ProcLogAtu("MENSAGEM","Reiniciando a thread : A107IntPPI","Reiniciando a thread : A107IntPPI")

                        //Dispara thread para Stored Procedure
                        StartJob("A107IntPPI",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,c711NumMRP,cIntgPPI,__cUserId)
                     EndIf
                     nRetry_1++

                     //TRATAMENTO PARA ERRO DE APLICACAO
                     Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '20'
                        //Conout(Replicate("-",65))
                        //Conout("PCPA107: Erro ao efetuar a conexão na thread 'A107IntPPI'")
                        //Conout(Replicate("-",65))

                        //Atualiza o log de processamento
                        ProcLogAtu("MENSAGEM","PCPA107: Erro ao efetuar a conexão na thread 'A107IntPPI'","PCPA107: Erro ao efetuar a conexão na thread 'A107IntPPI'")
                        Final(STR0187) //"PCPA107: Erro ao efetuar a conexão na thread 'A107IntPPI'"
                     
                     Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '2'
                        //Thread iniciou processamento, continua a execução do programa.
                        //Conout("PCPA107: Thread A107IntPPI iniciou o processamento.")
                        Exit
                     
                     Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '3'
                        //Já finalizou o processamento.
                        Exit
                     
                     Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '30'
                        //Já finalizou o processamento. mas com erros.
                        //Conout(GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)+"ERRO"))
                        Exit
                  EndCase
               Sleep(500)
            End
         EndIf
      EndDo
      If nCount > 1
         //Volta para a empresa logada.
         A107AltEmp(cEmpBkp, cFilBkp)
      EndIf
   EndIf
   A107ProInc()
   //Atualiza Niveis das Estruturas
   If ExistBlock ("M710NIV")
      M710Niv := ExecBlock("M710NIV",.F.,.F.)
      If ValType(M710NIV) != "L"
         M710Niv := .F.
      EndIf
   EndIf

   If M710Niv .Or. (GetMV("MV_NIVALT") == "S"  .and. lCalcNivelEstr)
      MA320Nivel(Nil,.t.,.f.)
      A107GrvTm(oCenterPanel,STR0047) //"Termino do Recalculo dos Niveis das Estruturas."
   EndIf

   //Monta Saldo Inicial por MULT-THREAD
   //Atualiza o log de processamento
   ProcLogAtu("MENSAGEM","Iniciando Montagem do Saldo Inicial","Iniciando Montagem do Saldo Inicial")
   //Conout("Iniciando montagem do saldo inicial.")

   nRetry_0 := 0
   nRetry_1 := 1
   //Verifica o JOB de verificação dos itens produzidos.
   While .T.
      Do Case
      Case GetGlbValue("A107ProdPr") == '0'
         If nRetry_0 > 50
            //Conout(Replicate("-",65))
            //Conout(STR0050+"A107ProdPr") //"Nao foi possivel realizar a subida da thread "
            //Conout(Replicate("-",65))
            Final(STR0050+"A107ProdPr") //"Nao foi possivel realizar a subida da thread "
          Else
            nRetry_0 ++
         EndIf

      //Tratamento para erro de conexao
      Case GetGlbValue("A107ProdPr") == '10'
         If nRetry_1 > 10
            //Conout(Replicate("-",65))
            //Conout(STR0051+"A107ProdPr")   //"Erro de conexao na thread "
            //Conout(STR0052)               // "Numero de tentativas excedido"
            //Conout(Replicate("-",65))
            Final(STR0051+"A107ProdPr")    //"Erro de conexao na thread "
         Else
            //Inicializa variavel global de controle de Job
            PutGlbValue("A107ProdPr","0")
            GlbUnLock()

            //Reiniciar thread
            //Conout(Replicate("-",65))
            //Conout(STR0051+"A107ProdPr")         //"Erro de conexao na thread "
            //Conout(STR0053+"A107ProdPr")
            //Conout(STR0054+StrZero(nRetry_1,2)) //"Tentativa numero: "
            //Conout(Replicate("-",65))
            StartJob("A107ProdPr",GetEnvServer(),A107ADVPR(),aEmpresas)
         EndIf
         nRetry_1 ++

      Case GetGlbValue("A107ProdPr") == '20'
         //Conout(Replicate("-",65))
         //Conout(STR0055+"A107ProdPr")         //"Erro na execucao da thread"
         //Conout(Replicate("-",65))
         Final(STR0055+"A107ProdPr")

      Case GetGlbValue("A107ProdPr") == '30'
            //Conout(Replicate("-",65))
            //Conout("PCPA107: Erro de aplicacao na thread ")
            //Conout(Replicate("-",65))

            //Atualiza o log de processamento
            ProcLogAtu("MENSAGEM","PCPA107: Erro de aplicacao na thread","PCPA107: Erro de aplicacao na thread")
            Final(STR0188 +GetGlbValue(AllTrim("A107ProdPrERRO")))

      //THREAD PROCESSADA CORRETAMENTE
      Case GetGlbValue("A107ProdPr") == '3'
         //Conout("Job A107ProdPr executado com sucesso.")
         Exit
      EndCase
      Sleep(1000)
   End

   //Calcula Quebra por Threads
   aThreads := PCPA107TB1(@cQueryB1)
   ProcRegua(((Len(aThreads)*2) + 8))
   nCount := 0
   Do While (nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. AllTrim(aEmpCent[1,1]) == AllTrim(cEmpBkp) .And. AllTrim(aEmpCent[1,2]) == AllTrim(cFilBkp)
         Exit
      EndIf
      //Abre as Threads do saldo inicial.
      If nCount > 0
         cEmpAnt := aEmpCent[nCount][1]
         cFilAnt := aEmpCent[nCount][2]
      EndIf
      nCount++
      A107ProInc()
      For nX := 1 to Len(aThreads)

         //Inicializa variavel global de controle de thread
         cJobAux := "c107P" + cEmpAnt + cFilAnt + StrZero(nX,2)
         PutGlbValue(cJobAux,"0")
         GlbUnLock()

         //Atualiza o log de processamento
         ProcLogAtu("MENSAGEM","Iniciando Montagem do Saldo Inicial - Thread:" + StrZero(nX,2),"Iniciando Montagem do Saldo Inicial - Thread:" + StrZero(nX,2))

         //Dispara thread para Stored Procedure
         StartJob("A107JOBINI",GetEnvServer(),A107ADVPR() ,cEmpAnt,cFilAnt,aThreads[nX,1],StrZero(nX,2),aPeriodos,aPergs711,c711NumMrp,cStrTipo,cStrGrupo,cTxtEstSeg,cRev711Vaz,lExistBB1,lExistBB2,lM710NOPC,lLogMRP,cTxtPontPed,aAlmoxNNR,nTipo,{cPictLOCAL,cPictQATU,cPictQNPT,cPictQTNP,cPictQTDE,cPictSALDO},cSelOpc,aEmpresas,nUsado)
      Next nX
   EndDo
   cEmpAnt := cEmpBkp
   cFilAnt := cFilBkp
   nCount := 0
   Do While (nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. AllTrim(aEmpCent[1,1]) == AllTrim(cEmpBkp) .And. AllTrim(aEmpCent[1,2]) == AllTrim(cFilBkp)
         Exit
      EndIf
      If nCount > 0
         cEmpAnt := aEmpCent[nCount][1]
         cFilAnt := aEmpCent[nCount][2]
      EndIf
      nCount++
      A107ProInc()
      //Controle de Seguranca para MULTI-THREAD
      For nX := 1 to Len(aThreads)

         //Inicializa variavel global de controle de thread
         cJobAux :="c107P"+cEmpAnt+cFilAnt+StrZero(nX,2)

         While .T.
            Do Case
               //TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
               Case GetGlbValue(cJobAux) == '0'
                  If nRetry_0 > 50
                     //Conout(Replicate("-",65))
                     //Conout("PCPA107: "+ "Não foi possivel realizar a subida da thread" + " " + StrZero(nX,2))
                     //Conout(Replicate("-",65))

                     //Atualiza o log de processamento
                     ProcLogAtu("MENSAGEM","Não foi possivel realizar a subida da thread","Não foi possivel realizar a subida da thread") //"Não foi possivel realizar a subida da thread"
                     Final(STR0189) //"Não foi possivel realizar a subida da thread"
                  Else
                     nRetry_0 ++
                  EndIf

               //TRATAMENTO PARA ERRO DE CONEXAO
               Case GetGlbValue(cJobAux) == '10'
                  If nRetry_1 > 5
                     //Conout(Replicate("-",65))
                     //Conout("PCPA107: Erro de conexao na thread")
                     //Conout("Thread numero : " + StrZero(nX,2) )
                     //Conout("Numero de tentativas excedidas")
                     //Conout(Replicate("-",65))

                     //Atualiza o log de processamento
                     ProcLogAtu("MENSAGEM","PCPA107: Erro de conexao na thread","PCPA107: Erro de conexao na thread")
                     Final(STR0190) //"PCPA107: Erro de conexao na thread"
                  Else
                     //Inicializa variavel global de controle de Job
                     PutGlbValue(cJobAux,"0")
                     GlbUnLock()

                     //Reiniciar thread
                     //Conout(Replicate("-",65))
                     //Conout("PCPA107: Erro de conexao na thread")
                     //Conout("Tentativa numero: "      +StrZero(nRetry_1,2))
                     //Conout("Reiniciando a thread : "+StrZero(nX,2))
                     //Conout(Replicate("-",65))

                     //Atualiza o log de processamento
                     ProcLogAtu("MENSAGEM","Reiniciando a thread : " + StrZero(nX,2),"Reiniciando a thread : " + StrZero(nX,2))

                     //Dispara thread para Stored Procedure
                     StartJob("A107JOBINI",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aThreads[nX,1],StrZero(nX,2),aPeriodos,aPergs711,c711NumMrp,cStrTipo,cStrGrupo,cTxtEstSeg,cRev711Vaz,lExistBB1,lExistBB2,lM710NOPC,lLogMRP,cTxtPontPed,aAlmoxNNR,nTipo,{cPictLOCAL,cPictQATU,cPictQNPT,cPictQTNP,cPictQTDE,cPictSALDO},cSelOpc,aEmpresas,nUsado)
                  EndIf
                  nRetry_1 ++

               //TRATAMENTO PARA ERRO DE APLICACAO
               Case GetGlbValue(cJobAux) == '20'
                  //Conout(Replicate("-",65))
                  //Conout("PCPA107: Erro ao efetuar a conexão na thread ")
                  //Conout("Thread numero : "+StrZero(nX,2))
                  //Conout(Replicate("-",65))

                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","PCPA107: Erro ao efetuar a conexão na thread","PCPA107: Erro ao efetuar a conexão na thread")
                  Final(STR0191) //PCPA107: Erro ao efetuar a conexão na thread

               Case GetGlbValue(cJobAux) == '30'
                  //Conout(Replicate("-",65))
                  //Conout("PCPA107: Erro de aplicacao na thread ")
                  //Conout("Thread numero : "+StrZero(nX,2))
                  //Conout(Replicate("-",65))

                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","PCPA107: Erro de aplicacao na thread","PCPA107: Erro de aplicacao na thread")
                  
                  AVISO( STR0179, STR0180 + AllTrim(cJobAux) + "." + CHR(10) + GetGlbValue(AllTrim(cJobAux)+"ERRO"), {"Ok"}, 3)//"ERRO" # "Ocorreram erros no processamento da thread "
                  Final(STR0188) //"PCPA107: Erro de aplicacao na thread"

               //THREAD PROCESSADA CORRETAMENTE
               Case GetGlbValue(cJobAux) == '3'
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino da Montagem do Saldo Inicial - Thread:" + StrZero(nX,2),"Termino da Montagem do Saldo Inicial - Thread:" + StrZero(nX,2))
                  Exit
            EndCase
            Sleep(1000)
         End
      Next nX
   EndDo
   cEmpAnt := cEmpBkp
   cFilAnt := cFilBkp
   //Atualiza LOG
   ProcLogAtu("MENSAGEM","Fim Montagem do Saldo Inicial","Fim Montagem do Saldo Inicial")
   //Conout("Fim montagem do saldo inicial.")

   //Job Estoque de segurança e Ponto de pedido.
   //Atualiza o log de processamento
   ProcLogAtu("MENSAGEM","Iniciando Montagem do Estoque de segurança/Ponto pedido","Iniciando Montagem do Estoque de segurança/Ponto pedido")
   PutGlbValue("A107PPEstS","0")
   GlbUnLock()
   //Dispara thread para Stored Procedure
   StartJob("A107PPEstS",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aPeriodos,aPergs711,c711NumMrp,cStrTipo,cStrGrupo,cTxtEstSeg,lExistBB1,lExistBB2,cTxtPontPed,aAlmoxNNR,nTipo,cRev711Vaz,{cPictLOCAL,cPictQATU,cPictQNPT,cPictQTNP,cPictQTDE,cPictSALDO},aEmpresas,lVerGrupo,lVerTipo,nUsado,aEmpCent,cDadosProd)

   While .T.
      Do Case
         //TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
         Case GetGlbValue("A107PPEstS") == '0'
            If nRetry_0 > 50
               //Conout(Replicate("-",65))
               //Conout("PCPA107: "+ "Não foi possivel realizar a subida da thread 'A107PPEstS'")
               //Conout(Replicate("-",65))

               //Atualiza o log de processamento
               ProcLogAtu("MENSAGEM","Não foi possivel realizar a subida da thread 'A107PPEstS'","Não foi possivel realizar a subida da thread 'A107PPEstS'") //"Não foi possivel realizar a subida da thread"
               Final(STR0192) //"Não foi possivel realizar a subida da thread 'A107PPEstS'"
            Else
               nRetry_0 ++
            EndIf

         //TRATAMENTO PARA ERRO DE CONEXAO
         Case GetGlbValue("A107PPEstS") == '10'
            If nRetry_1 > 5
               //Conout(Replicate("-",65))
               //Conout("PCPA107: Erro de conexao na thread 'A107PPEstS'")
               //Conout("Thread numero : " + StrZero(nX,2) )
               //Conout("Numero de tentativas excedidas")
               //Conout(Replicate("-",65))

               //Atualiza o log de processamento
               ProcLogAtu("MENSAGEM","PCPA107: Erro de conexao na thread 'A107PPEstS'","PCPA107: Erro de conexao na thread 'A107PPEstS'")
               Final(STR0193) //"PCPA107: Erro de conexao na thread 'A107PPEstS'"
            Else
               //Inicializa variavel global de controle de Job
               PutGlbValue("A107PPEstS","0")
               GlbUnLock()

               //Reiniciar thread
               //Conout(Replicate("-",65))
               //Conout("PCPA107: Erro de conexao na thread 'A107PPEstS'")
               //Conout("Tentativa numero: "      +StrZero(nRetry_1,2))
               //Conout("Reiniciando a thread : "+StrZero(nX,2))
               //Conout(Replicate("-",65))

               //Atualiza o log de processamento
               ProcLogAtu("MENSAGEM","Reiniciando a thread : " + StrZero(nX,2),"Reiniciando a thread : " + StrZero(nX,2))

               //Dispara thread para Stored Procedure
               StartJob("A107PPEstS",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aPeriodos,aPergs711,c711NumMrp,cStrTipo,cStrGrupo,cTxtEstSeg,lExistBB1,lExistBB2,cTxtPontPed,aAlmoxNNR,nTipo,cRev711Vaz,{cPictLOCAL,cPictQATU,cPictQNPT,cPictQTNP,cPictQTDE,cPictSALDO},aEmpresas,lVerGrupo,lVerTipo,nUsado,aEmpCent,cDadosProd)
            EndIf
            nRetry_1 ++

         //TRATAMENTO PARA ERRO DE APLICACAO
         Case GetGlbValue("A107PPEstS") == '20'
            //Conout(Replicate("-",65))
            //Conout("PCPA107: Erro ao efetuar a conexão na thread 'A107PPEstS'")
            //Conout("Thread numero : "+StrZero(nX,2))
            //Conout(Replicate("-",65))

            //Atualiza o log de processamento
            ProcLogAtu("MENSAGEM","PCPA107: Erro ao efetuar a conexão na thread 'A107PPEstS'","PCPA107: Erro ao efetuar a conexão na thread 'A107PPEstS'")
            Final(STR0194) //PCPA107: Erro ao efetuar a conexão na thread 'A107PPEstS'

         Case GetGlbValue("A107PPEstS") == '30'
            //Conout(Replicate("-",65))
            //Conout("PCPA107: Erro de aplicacao na thread 'A107PPEstS'")
            //Conout("Thread numero : "+StrZero(nX,2))
            //Conout(Replicate("-",65))

            //Atualiza o log de processamento
            ProcLogAtu("MENSAGEM","PCPA107: Erro de aplicacao na thread 'A107PPEstS'","PCPA107: Erro de aplicacao na thread 'A107PPEstS'")
            AVISO( STR0179, STR0180 + "A107PPEstS." + CHR(10) + GetGlbValue("A107PPEstSERRO"), {"Ok"}, 3)//"ERRO" ## "Ocorreram erros no processamento da thread "
            Final(STR0195) //"PCPA107: Erro de aplicacao na thread 'A107PPEstS'"

         //THREAD PROCESSADA CORRETAMENTE
         Case GetGlbValue("A107PPEstS") == '3'
            //Atualiza o log de processamento
            ProcLogAtu("MENSAGEM","Termino da Montagem do Estoque de segurança/Ponto pedido","Termino da Montagem do Estoque de segurança/Ponto pedido")
            Exit
      EndCase
      Sleep(1000)
   End

   nCount := 0

   Do While (nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
         Exit
      EndIf
      If nCount > 0
         cEmpAnt := aEmpCent[nCount][1]
         cFilAnt := aEmpCent[nCount][2]
      EndIf
      nCount++
      A107ProInc()
      ///*---------------INICIO JOBSC1-----------------*/
      //Monta Solicitacoes de Compra
      cAliasTop := "BUSCASC1"+cEmpAnt+cFilAnt
      DatFim    := PCPA107DtF()

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Iniciando Processamento SC1","Iniciando Processamento SC1")
      //Conout("Iniciando processamento SC1 - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")
      PutGlbValue("A107JobC1"+cEmpAnt+cFilAnt,"0")
      GlbUnLock()

      //Parametros para o Job
      aParamJob := {c711NumMRP,nTipo,aPeriodos,aPergs711,cStrTipo,cStrGrupo,cAliasTop,cAlmoxd,cAlmoxa,cQueryB1,lA710Sql,cOpc711Vaz,cRev711Vaz,lLogMrp,lConsPreRe,aAlmoxNNR,DatFim,aEmpresas,nUsado,aFilAlmox}

      AADD(aListaJob,{"A107JobC1"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

      //Processa thread
      StartJob("A107JobC1",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1)

      /*---------------INICIO JOBSC7-----------------*/
      //Monta Pedidos de Compra
      cAliasTop := "BUSCASC7"+cEmpAnt+cFilAnt

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Iniciando Processamento SC7","Iniciando Processamento SC7")
      //Conout("Iniciando processamento SC7 - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")

      //Inicializa variavel global de controle de thread
      PutGlbValue("A107JobC7"+cEmpAnt+cFilAnt,"0")
      GlbUnLock()

      //Parametros para o Job
      aParamJob := {c711NumMRP,nTipo,aPeriodos,aPergs711,cStrTipo,cStrGrupo,cAliasTop,cAlmoxd,cAlmoxa,cQueryB1,lA710Sql,cOpc711Vaz,cRev711Vaz,lLogMRP,aAlmoxNNR,DatFim,aEmpresas,nUsado,aFilAlmox}

      AADD(aListaJob,{"A107JobC7"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

      //Processa thread
      StartJob("A107JobC7",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1)

      /*---------------INICIO JOBSC2-----------------*/
      //Monta Ordens de Producao
      cAliasTop := "BUSCASC2"+cEmpAnt+cFilAnt

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Iniciando Processamento SC2","Iniciando Processamento SC2")
      //Conout("Iniciando processamento SC2 - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")

      //Inicializa variavel global de controle de thread
      PutGlbValue("A107JobC2"+cEmpAnt+cFilAnt,"0")
      GlbUnLock()

      //Parametros para o Job
      aParamJob := {c711NumMRP,nTipo,aPeriodos,cStrTipo,cStrGrupo,cAliasTop,cAlmoxd,cAlmoxa,cQueryB1,lA710Sql,lConsSusp,lConsSacr,lLogMRP,aPergs711,aAlmoxNNR,DatFim,aEmpresas,nUsado,aFilAlmox}

      AADD(aListaJob,{"A107JobC2"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

      //Processa thread
      StartJob("A107JobC2",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1,lUsaMOpc)

      /*---------------INICIO JOBSD4-----------------*/
      //Monta Empenhos
      cAliasTop := "BUSCASD4"+cEmpAnt+cFilAnt

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Iniciando Processamento SD4","Iniciando Processamento SD4")
      //Conout("Iniciando processamento SD4 - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")

      //Inicializa variavel global de controle de thread
      PutGlbValue("A107JobD4"+cEmpAnt+cFilAnt,"0")
      GlbUnLock()

      //Parametros para o Job
      aParamJob := {c711NumMRP,nTipo,aPeriodos,aPergs711,cStrTipo,cStrGrupo,cAliasTop,cAlmoxd,cAlmoxa,cQueryB1,lA710Sql,cRev711Vaz,lLogMRP,aAlmoxNNR,A711Grupo,lMRPCINQ,DatFim,aEmpresas,nUsado,aFilAlmox}

      AADD(aListaJob,{"A107JobD4"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

      //Processa thread
      StartJob("A107JobD4",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1)

      /*---------------INICIO JOBSC6-----------------*/
      //Monta Pedidos de Venda
      lProcSC4 := aPergs711[1] == 1 .And. (aPergs711[30] == 1 .Or. aPergs711[17] == 1)
      If lPedido .Or. lProcSC4
         cAliasTop := "BUSCASC6"+cEmpAnt+cFilAnt

         //Atualiza o log de processamento
         ProcLogAtu("MENSAGEM","Iniciando Processamento SC6","Iniciando Processamento SC6")
         //Conout("Iniciando processamento SC6 - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")

         //Inicializa variavel global de controle de thread
         PutGlbValue("A107JobC6"+cEmpAnt+cFilAnt,"0")
         GlbUnLock()

         //Parametros para o Job
         aParamJob := {c711NumMRP,nTipo,aPeriodos,aPergs711,cStrTipo,cStrGrupo,cAliasTop,cAlmoxd,cAlmoxa,cQueryB1,lA710Sql,lPedBloc,cComp1,cComp2,lProcSC4,cRev711Vaz,lLogMRP,lPedido,aAlmoxNNR,DatFim,aEmpresas,nUsado,aFilAlmox}

         AADD(aListaJob,{"A107JobC6"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

         //Processa thread
         StartJob("A107JobC6",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1,lUsaMOpc)
      EndIf

      /*---------------INICIO JOBAFJ-----------------*/
      //Monta Empenhos para projetos
      cAliasTop := "BUSCAAFJ"+cEmpAnt+cFilAnt

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Iniciando Processamento AFJ","Iniciando Processamento AFJ")
      //Conout("Iniciando processamento AFJ - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")

      //Inicializa variavel global de controle de thread
      PutGlbValue("A107JobAFJ"+cEmpAnt+cFilAnt,"0")
      GlbUnLock()

      //Parametros para o Job
      aParamJob := {c711NumMRP,nTipo,aPeriodos,cStrTipo,cStrGrupo,cAliasTop,cQueryB1,lA710Sql,cOpc711Vaz,cRev711Vaz,lLogMRP,aPergs711,DatFim,aEmpresas,nUsado,aAlmoxNNR,aFilAlmox}

      AADD(aListaJob,{"A107JobAFJ"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

      //Processa thread
      StartJob("A107JobAFJ",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1)

      /*---------------INICIO JOBSC4 e JOBSHC-----------------*/
      //Monta Previsoes de Venda. Só processa caso nao tenha processado junto dos pedidos de venda.
      If aPergs711[1] == 1 .And. !lProcSC4
         cAliasTop := "BUSCASC4"+cEmpAnt+cFilAnt

         //Atualiza o log de processamento
         ProcLogAtu("MENSAGEM","Iniciando Processamento SC4","Iniciando Processamento SC4")
         //Conout("Iniciando processamento SC4 - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")

         //Inicializa variavel global de controle de thread
         PutGlbValue("A107JobC4"+cEmpAnt+cFilAnt,"0")
         GlbUnLock()

         //Parametros para o Job
         aParamJob := {c711NumMRP,nTipo,aPeriodos,cStrTipo,cStrGrupo,cAliasTop,cAlmoxd,cAlmoxa,cQueryB1,ACLONE(aPergs711),.T.,{{}},cRev711Vaz,aAlmoxNNR,lA710Sql,DatFim,aEmpresas,nUsado,aFilAlmox}

         AADD(aListaJob,{"A107JobC4"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

         //Processa thread
         StartJob("A107JobC4",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1,lUsaMOpc)
      ElseIf aPergs711[1] == 2
         //Monta Plano Mestre de Producao
         cAliasTop := "BUSCASHC"+cEmpAnt+cFilAnt

         //Atualiza o log de processamento
         ProcLogAtu("MENSAGEM","Iniciando Processamento SHC","Iniciando Processamento SHC")
         //Conout("Iniciando processamento SHC - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")

         //Inicializa variavel global de controle de thread
         PutGlbValue("A107JobHC"+cEmpAnt+cFilAnt,"0")
         GlbUnLock()

         //Parametros para o Job
         aParamJob := {c711NumMRP,nTipo,aPeriodos,cStrTipo,cStrGrupo,cAliasTop,cQueryB1,ACLONE(aPergs711),cRev711Vaz,DatFim,aEmpresas,nUsado,aAlmoxNNR,aFilAlmox}

         AADD(aListaJob,{"A107JobHC"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

         //Processa thread
         StartJob("A107JobHC",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1,lUsaMOpc)
      EndIf

      /*---------------INICIO JOBSB8-----------------*/
      //Monta Lotes Vencidos
      If aPergs711[29] == 1
         cAliasTop := "BUSCASB8"+cEmpAnt+cFilAnt

         //Conout("Iniciando processamento SB8 - Empresa: '" + cEmpAnt + "' Filial: '"+cFilAnt+"'.")

         //Inicializa variavel global de controle de thread
         PutGlbValue("A107JobB8"+cEmpAnt+cFilAnt,"0")
         GlbUnLock()

         //Parametros para o Job
         aParamJob := {c711NumMRP,nTipo,aPeriodos,cStrTipo,cStrGrupo,cAliasTop,cQueryB1,ACLONE(aPergs711),cRev711Vaz,aAlmoxNNR,aEmpresas,nUsado,aFilAlmox}

         AADD(aListaJob,{"A107JobB8"+cEmpAnt+cFilAnt,aParamJob,Seconds()})

         //Processa thread
         StartJob("A107JobB8",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aParamJob,nRetry_1)
      EndIf
   EndDo
   cEmpAnt := cEmpBkp
   cFilAnt := cFilBkp
   nCount := 0

   Do While (nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
         Exit
      EndIf
      If nCount > 0
         cEmpAnt := aEmpCent[nCount][1]
         cFilAnt := aEmpCent[nCount][2]
      EndIf
      nCount++
      A107ProInc()
      For i:=1 to Len(aListaJob)
         //Analise das Threads em Execucao
         nRetry_0 := 0
         nRetry_1 := 1
         If AllTrim(aListaJob[i,1]) == AllTrim("A107JobC1"+cEmpAnt+cFilAnt)
            A107ProInc()
         ElseIf AllTrim(aListaJob[i,1]) == AllTrim("A107JobC7"+cEmpAnt+cFilAnt)
            A107ProInc()
         ElseIf AllTrim(aListaJob[i,1]) == AllTrim("A107JobC2"+cEmpAnt+cFilAnt)
            A107ProInc()
         ElseIf AllTrim(aListaJob[i,1]) == AllTrim("A107JobD4"+cEmpAnt+cFilAnt)
            A107ProInc()
         ElseIf AllTrim(aListaJob[i,1]) == AllTrim("A107JobC6"+cEmpAnt+cFilAnt)
            A107ProInc()
         ElseIf AllTrim(aListaJob[i,1]) == AllTrim("A107JobAFJ"+cEmpAnt+cFilAnt)
            A107ProInc()
         ElseIf AllTrim(aListaJob[i,1]) == AllTrim("A107JobC4"+cEmpAnt+cFilAnt)
            A107ProInc()
         ElseIf AllTrim(aListaJob[i,1]) == AllTrim("A107JobHC"+cEmpAnt+cFilAnt)
            A107ProInc()
         EndIf
         While .T.
            Do Case
            Case GetGlbValue(aListaJob[i,1]) == '0'
               If nRetry_0 > 50
                  //Conout(Replicate("-",65))
                  //Conout(STR0050+aListaJob[i,1]) //"Nao foi possivel realizar a subida da thread "
                  //Conout(Replicate("-",65))
                  Final(STR0050+aListaJob[i,1]) //"Nao foi possivel realizar a subida da thread "
                Else
                  nRetry_0 ++
               EndIf

            //Tratamento para erro de conexao
            Case GetGlbValue(aListaJob[i,1]) == '10'
               If nRetry_1 > 10
                  //Conout(Replicate("-",65))
                  //Conout(STR0051+aListaJob[i,1])   //"Erro de conexao na thread "
                  //Conout(STR0052)               // "Numero de tentativas excedido"
                  //Conout(Replicate("-",65))
                  Final(STR0051+aListaJob[i,1])    //"Erro de conexao na thread "
               Else
                  //Inicializa variavel global de controle de Job
                  PutGlbValue(aListaJob[i,1],"0")
                  GlbUnLock()

                  //Reiniciar thread
                  //Conout(Replicate("-",65))
                  //Conout(STR0051+aListaJob[i,1])         //"Erro de conexao na thread "
                  //Conout(STR0053+aListaJob[i,1])
                  //Conout(STR0054+StrZero(nRetry_1,2)) //"Tentativa numero: "
                  //Conout(Replicate("-",65))
                  StartJob(aListaJob[i,1],GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,aListaJob[i,2],nRetry_1)
               EndIf
               nRetry_1 ++

            Case GetGlbValue(aListaJob[i,1]) == '20'
               //Conout(Replicate("-",65))
               //Conout(STR0055+aListaJob[i,1])         //"Erro na execucao da thread"
               //Conout(Replicate("-",65))
               Final(STR0055+aListaJob[i,1])

            Case GetGlbValue(aListaJob[i,1]) == '30'
                  //Conout(Replicate("-",65))
                  //Conout("PCPA107: Erro de aplicacao na thread ")
                  //Conout("Thread numero : "+StrZero(nX,2))
                  //Conout(Replicate("-",65))

                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","PCPA107: Erro de aplicacao na thread","PCPA107: Erro de aplicacao na thread")
                  AVISO( STR0179, STR0180 + AllTrim(aListaJob[i,1]) + "." + CHR(10) + GetGlbValue(AllTrim(aListaJob[i,1])+"ERRO"), {"Ok"}, 3)//"ERRO" ## "Ocorreram erros no processamento da thread "
                  Final(STR0188 + aListaJob[i,1]) //"PCPA107: Erro de aplicacao na thread "

            //THREAD PROCESSADA CORRETAMENTE
            Case GetGlbValue(aListaJob[i,1]) == '3'
               If aListaJob[i,1] == "A107JobC1"
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino Processamento SC1","Termino Processamento SC1")
                  //Conout("Termino Processamento SC1. Empresa: " + AllTrim(cEmpAnt) + ". Filial: " + AllTrim(cFilAnt))
               ElseIf aListaJob[i,1] == "A107JobC7"
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino Processamento SC7","Termino Processamento SC7")
                  //Conout("Termino Processamento SC7. Empresa: " + AllTrim(cEmpAnt) + ". Filial: " + AllTrim(cFilAnt))
               ElseIf aListaJob[i,1] == "A107JobC2"
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino Processamento SC2","Termino Processamento SC2")
                  //Conout("Termino Processamento SC2. Empresa: " + AllTrim(cEmpAnt) + ". Filial: " + AllTrim(cFilAnt))
               ElseIf aListaJob[i,1] == "A107JobD4"
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino Processamento SD4","Termino Processamento SD4")
                  //Conout("Termino Processamento SD4. Empresa: " + AllTrim(cEmpAnt) + ". Filial: " + AllTrim(cFilAnt))
               ElseIf aListaJob[i,1] == "A107JobC6"
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino Processamento SC6","Termino Processamento SC6")
                  //Conout("Termino Processamento SC6. Empresa: " + AllTrim(cEmpAnt) + ". Filial: " + AllTrim(cFilAnt))
               ElseIf aListaJob[i,1] == "A107JobAFJ"
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino Processamento AFJ","Termino Processamento AFJ")
                  //Conout("Termino Processamento AFJ. Empresa: " + AllTrim(cEmpAnt) + ". Filial: " + AllTrim(cFilAnt))
               ElseIf aListaJob[i,1] == "A107JobC4"
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino Processamento SC4","Termino Processamento SC4")
                  //Conout("Termino Processamento SC4. Empresa: " + AllTrim(cEmpAnt) + ". Filial: " + AllTrim(cFilAnt))
               ElseIf aListaJob[i,1] == "A107JobHC"
                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Termino Processamento SHC","Termino Processamento SHC")
                  //Conout("Termino Processamento SHC. Empresa: " + AllTrim(cEmpAnt) + ". Filial: " + AllTrim(cFilAnt))
               EndIf
               Exit
            EndCase
            Sleep(1000)
         End
      Next i
   EndDo
   //Volta para a empresa logada. (não é necessário utilizar o RpcSetEnv, pois foi realizado o processamento por Job.
   cEmpAnt := cEmpBkp
   cFilAnt := cFilBkp
   //Verifica se existe saldo para atender o estoque de segurança
   //If aPergs711[26] == 1
      //a107AtuSeg()
   //EndIf
   nCount := 0
   Do While (nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
         Exit
      EndIf
      If nCount > 0
         A107AltEmp(aEmpCent[nCount][1], aEmpCent[nCount][2])
      EndIf
      nCount++
      A107ClNes(/*01*/,oCenterPanel,.F.)
   EndDo
   //lVerSldSOR := .F.
   //Volta para a empresa logada inicialmente.
   If nCount > 1
      A107AltEmp(cEmpBkp, cFilBkp)
   EndIf

   nCount := 0
   Do While (nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
         Exit
      EndIf
      If nCount > 0
         A107AltEmp(aEmpCent[nCount][1], aEmpCent[nCount][2])
      EndIf
      nCount++

      If aPergs711[1] == 2
         //Atualiza o log de processamento
         ProcLogAtu("MENSAGEM","Iniciando Explosao PMP","Iniciando Explosao PMP")

         A107ProInc()
         //Explode estrutura dos produtos que tiveram PMP
         PCPA107EHC(cStrTipo,cStrGrupo,oCenterPanel)

         //Atualiza o log de processamento
         ProcLogAtu("MENSAGEM","Fim Explosao PMP","Fim Explosao PMP")
      EndIf

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Iniciando recalculo necessidades","Iniciando recalculo necessidades")
      A107ProInc()

      //Chama funcao que recalcula saldo - ANTES DA EXPLOSAO DE ESTRUTURA
      A107ClNes(/*01*/,oCenterPanel,.F.)

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Fim recalculo necessidades","Fim recalculo necessidades")

      ProcLogAtu("MENSAGEM","Inicio da Explosao da Estrutura","Inicio da Explosao da Estrutura")
      A107ProInc()

      //Explode estrutura e calcula necessidade por PRODUTO
      PCPA107MAT(oCenterPanel)

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Termino da Explosao da Estrutura","Termino da Explosao da Estrutura")
   EndDo

   //Volta para a empresa logada inicialmente.
   If nCount > 1
      A107AltEmp(cEmpBkp, cFilBkp)
   EndIf

   nCount := 0
   //Necessidades do Plano Mestre
   If aPergs711[1] == 2
      Do While (nCount <= Len(aEmpCent))
         If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
            Exit
         EndIf
         //Verifica o PMP dos produtos que não possuem estrutura na empresa em que o PMP foi criado.
         If nCount > 0
            A107NesPmp(aEmpCent[nCount][1], aEmpCent[nCount][2],cStrTipo, cStrGrupo,oCenterPanel)
         Else
            A107NesPmp(cEmpAnt,cFilAnt,cStrTipo, cStrGrupo,oCenterPanel)
         EndIf
         nCount++
      EndDo
      //Retorna para a empresa logada
      If AllTrim(cEmpBkp) != AllTrim(cEmpAnt) .Or. AllTrim(cFilBkp) != AllTrim(cFilAnt)
         A107AltEmp(cEmpBkp, cFilBkp)
      EndIf
   EndIf

   //Gera as necessidades para as outras empresas.
   //Primeiro processa ponto de pedido e estoque de segurança.
   nCount := 0
   Do While(nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
         Exit
      EndIf
      If nCount > 0
         A107AltEmp(aEmpCent[nCount][1], aEmpCent[nCount][2])
      EndIf
      A107ClNes(/*01*/,oCenterPanel,.F.)
      A107ProInc()
      If nCount > 0
         A107NesEmp(aEmpCent[nCount][1], aEmpCent[nCount][2], cStrTipo, cStrGrupo, oCenterPanel, ,cTxtPontPed, cTxtEstSeg, .T.)
      Else
         A107NesEmp(cEmpAnt, cFilAnt, cStrTipo, cStrGrupo, oCenterPanel, ,cTxtPontPed, cTxtEstSeg, .T.)
      EndIf
      nCount++
   EndDo
   nCount := 0
   //Retorna para a empresa logada
   If AllTrim(cEmpBkp) != AllTrim(cEmpAnt) .Or. AllTrim(cFilBkp) != AllTrim(cFilAnt)
      A107AltEmp(cEmpBkp, cFilBkp)
   EndIf
   Do While(nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
         Exit
      EndIf
      If nCount > 0
         A107AltEmp(aEmpCent[nCount][1], aEmpCent[nCount][2])
      EndIf
      //Conout("Processando necessidades para a empresa '"+AllTrim(cEmpAnt)+"' e filial '"+AllTrim(cFilAnt)+"'.")
      A107ClNes(/*01*/,oCenterPanel,.F.)
      A107ProInc()
      If nCount > 0
         A107NesEmp(aEmpCent[nCount][1], aEmpCent[nCount][2], cStrTipo, cStrGrupo, oCenterPanel, ,cTxtPontPed, cTxtEstSeg, .F.)
      Else
         A107NesEmp(cEmpAnt, cFilAnt, cStrTipo, cStrGrupo, oCenterPanel, ,cTxtPontPed, cTxtEstSeg, .F.)
      EndIf
      nCount++
   EndDo
   //Retorna para a empresa logada
   If AllTrim(cEmpBkp) != AllTrim(cEmpAnt) .Or. AllTrim(cFilBkp) != AllTrim(cFilAnt)
      A107AltEmp(cEmpBkp, cFilBkp)
   EndIf

   //Avalia eventos do log do MRP
   If lLogMRP
      A107ProInc()
      PCPA107LOG()
   EndIf
EndIf

//Variaveis com a periodicidade de geracao de OPs e SCs.
cSelPer := cSelPerSC:=Replicate("û",Len(aPeriodos))
If aPergs711[10] == 1
   cSelF := cSelFSC := Replicate("û",Len(aPeriodos))
Else
   cSelF := cSelFSC := Replicate(" ",Len(aPeriodos))
EndIf

//Executa ponto de entrada
If (ExistBlock("MTA710"))
   ExecBlock("MTA710",.F.,.F.)
EndIf

//Cria variavel "inclui" e "altera" para nao gerar erro de inicialializador padrao.
If Type("Inclui") == "U"
   Private Inclui := .F.
EndIf
If Type("ALTERA") == "U"
   Private ALTERA := .F.
EndIf

//Conout(Replicate("#",70))
//Conout("###--FIM PROCESSAMENTO CALCULO MRP MULTIEMPRESAS.")
//Conout("###--DATA:" + DtoC(Date()))
//Conout("###--HORA:" + TIME())
//Conout(Replicate("#",70))

A107GrvTm(oCenterPanel,STR0056) //"Inicio da montagem de tela."

//Monta arquivo com TREE e consulta de DADOS
If !lBatch
   A107ProInc()

   DEFINE FONT oFont NAME "Arial" SIZE 0, -10
   DEFINE MSDIALOG oDlg TITLE cCadastro + " - " + STR0057 + " " + c711NumMRP OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight

   //Cria Variaveis PRIVATE nessa funcao
   SB1->(RegToMemory("SB1",.F.))
   SC1->(RegToMemory("SC1",.F.))
   SC7->(RegToMemory("SC7",.F.))
   SC2->(RegToMemory("SC2",.F.))
   SHC->(RegToMemory("SHC",.F.))
   SD4->(RegToMemory("SD4",.F.))
   SC6->(RegToMemory("SC6",.F.))
   SC4->(RegToMemory("SC4",.F.))
   AFJ->(RegToMemory("AFJ",.F.))

   //Definicao de Menu para o botao de Filtro
   MENU oMenu1 POPUP
      MENUITEM STR0040 ACTION (P107FilNec(.T.),Eval(bChange),oTreeM711:Refresh()) //"Mostra somente as necessidades"
      MENUITEM STR0213 ACTION (P107FilNec(.F.), oTreeM711:Refresh()) //Limpar Filtro
	MENUITEM STR0058 ACTION (P107FilGen(),Eval(bChange),oTreeM711:Refresh()) //"Filtrar Produtos"
      //MENUITEM STR0058 ACTION (M710FilGen(),Eval(bChange),oTreeM711:Refresh()) //"Filtrar Produtos"   /////VOLTAR AQUI/////
   ENDMENU

   //Folder do Tree e dos dados
   oFolder := TFolder():New(30,0,aTitles,aPages,oDlg,,,, .T., .F.,((nRight-nLeft)/2)+5,nBottom-nTop-30,)  //Dados  / Legenda
   oFolder:aDialogs[1]:oFont := oDlg:oFont

   //Definicao do objeto SAY para descricao do produto
   @ 0,3 Say oSay1 Prompt "" Size 125,10 OF oFolder:aDialogs[1] Pixel
   @ 5,3 Say oSay2 Prompt "" Size 125,8 OF oFolder:aDialogs[1] Pixel
   oSay1:SetColor(CLR_HRED,GetSysColor(15))
   oSay2:SetColor(CLR_HRED,GetSysColor(15))

   oSayEmp := TSay():New(09,03,{||' '},oFolder:aDialogs[1],,oFont,,,,.T.,,,200,20)

   //Panel com dados
   oPanelM711 := TPanel():New(0,165,'',oFolder:aDialogs[1],oDlg:oFont,.T.,.T.,,,(nRight-nLeft)/2-164,((nBottom-nTop)/2)-30,.T.,.T. )

   //Cria o array dos campos para o browse
   AADD(aCampos,{"TEXTO","",STR0059,30}) //"Tipo"
   AADD(aCampos,{"PRODSHOW","",STR0060,LEN(SOR->OR_PROD)}) //"Produtos"
   AADD(aCampos,{"OPCSHOW","",STR0061,LEN(SOR->OR_OPCORD)}) //"Opcionais"
   AADD(aCampos,{"REVSHOW","",STR0062,4}) //"Revisao"
   For nInd := 1 to Len(aPeriodos)
      AADD(aCampos,{"PER"+StrZero(nInd,3),cPictQuant,DtoC(aPeriodos[nInd]),aTamQuant[1]+5})
   Next nInd

   //Monta o arquivo para a tela.
   cAliasView := PCPA107MVW(.T.,"CRIATAB")

   If UsaNewPrc()
      nBottom := nBottom-32
   EndIf

   //Monta browse de todos os produtos
   nOldEnch := 1
   aEnch[nOldEnch] := MaMakeBrow(oPanelM711,cAliasView,{0,0,(nRight-nLeft)/2-164,((nBottom-nTop)/2)-50},,.F.,aCampos,,cTopFun,cBotFun,NIL,NIL,2)

   //Informacoes da Legenda
   nPoLin:=10
   @ nPoLin,08 BITMAP oBmp RESNAME "PMSEDT4" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
   @ nPoLin,23 SAY STR0060 Of oFolder:aDialogs[2] Size 50,50 Pixel
   If lShAlt
      @ 20,08 BITMAP oBmp RESNAME "PMSEDT2" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
      @ 20,23 SAY STR0197 Of oFolder:aDialogs[2] Size 100,50 Pixel //'Produto com Alternativos' 
      nPoLin:=20
   EndIF
   @ nPoLin+10,08 BITMAP oBmp RESNAME "PMSEDT3" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
   @ nPoLin+10,23 SAY STR0063 Of oFolder:aDialogs[2] Size 50,50 Pixel
   @ nPoLin+20,08 BITMAP oBmp RESNAME "PMSEDT1" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
   @ nPoLin+20,23 SAY STR0064 Of oFolder:aDialogs[2] Size 50,50 Pixel
   @ nPoLin+30,08 BITMAP oBmp RESNAME "PMSDOC" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
   @ nPoLin+30,23 SAY STR0065 Of oFolder:aDialogs[2] Size 50,50 Pixel
   @ nPoLin+40,08 BITMAP oBmp RESNAME "relacionamento_direita" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
   @ nPoLin+40,23 SAY STR0066 Of oFolder:aDialogs[2] Size 150,50 Pixel

   //Definicao do objeto tree
   oTreeM711 := dbTree():New(16,2,((nBottom-nTop)/2)-50,164,oFolder:aDialogs[1],,,.T.)
   oTreeM711:bChange := {|| PA107DlgV(@aEnch,{0,0,((nBottom-nTop)/2)-50,((nRight-nLeft)/2)-164},@nOldEnch,oSay1,cAliasView,oSay2),Eval(bChange)}
   oTreeM711:SetFont(oFont)
   oTreeM711:lShowHint:= .F.

   //Monta Tree
   PA107Tree(aPergs711[28]==1,oCenterPanel,.F.,lVisualiza)

   //Atualiza LOG
   ProcLogAtu("MENSAGEM","Fim calculo MRP","Fim calculo MRP")

   // Refaz browse com informacoes de todos os produtos
   oPanelM711:Refresh()
   oPanelM711:Show()

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||fechaTela(oDlg)},{||fechaTela(oDlg)},,aButtons))
   Release Object oTreeM711

   (cAliasView)->(dbCloseArea())
Endif

//SFCDelTab(cAliasView)

//Fecha arquivos utilizados
If lBatch .And. ValType(aAuto[6]) == "L" .And. aAuto[6]
   If Len(aAuto) >= 8 .And. ValType(aAuto[8]) == "C"
      cNumOpDig := aAuto[8]
   Endif
   A107Gera(@cNumOpDig,cStrTipo,cStrGrupo,oCenterPanel)
Endif

//Retira o semaforo de uso exclusivo da operacao
UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)

Return

Static Function fechaTela(oDlg)
Local cValue := ""
Local cTotal := 0
Local cCount := 0
Local nI     := 0
Local cBkpEmp := cEmpAnt
Local cBkpFil := cFilAnt
Local lFecha  := .T.
/*
   Verifica se existe uma thread da integração das ordens de produção do MRP em execução.
   se estiver, não deixa realizar o processamento.
*/

For nI := 1 To Len(aEmpCent)
	NGPrepTBL({{"SOD",1},{"SOE",1}},aEmpCent[nI][1],AllTrim(aEmpCent[ni][2]))
	If PCPIntgPPI()
		//Busca o parâmetro de integração de OP's com o PPI.
		cIntgPPI := PCPIntgMRP()
		If cIntgPPI != "1"
			cValue := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2]))
			cTotal := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2])+"TOTAL")
			cCount := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2])+"COUNT")
			If !Empty(cValue) .And. (cValue != "3" .And. cValue != "30")
				MsgInfo(STR0182+CHR(13)+CHR(10)+ " " + STR0080 + " " + cCount + STR0098 + cTotal,STR0030) //"A integração das ordens de produção com o Totvs MES ainda está em processamento, por favor aguarde." \n Ordem de produção XXX de XXX" "Atenção"
				lFecha := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next nI

NGPrepTBL({{"SOD",1},{"SOE",1}},cBkpEmp,cBkpFil)

If lFecha
	oDlg:End()
EndIf

Return 

/*------------------------------------------------------------------------//
//Programa: A107NesEmp
//Autor:    Lucas Konrad França
//Data:     20/11/14
//Descricao:   Gera as necessidades para as empresas.
//Parametros:  cEmp         - Empresa que contém as necessidades de compra
//             cFil         - Filial que contém as necessidades de compra
//             cStrTipo     - String com os tipos a serem processados
//             cStrGrupo    - String com os grupos a serem processados
//             oCenterPanel - Objeto do painel de processamento
//             cTxtPontPed  - Texto do label do ponto de pedido.
//             cTxtEstSeg   - Texto do label do estoque de segurança.
//             lEstPP       - Indica se será processado somente ponto de pedido e estoque de segurança.
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107NesEmp(cEmp, cFil, cStrTipo, cStrGrupo, oCenterPanel, cProduto, cTxtPontPed, cTxtEstSeg, lEstPP)
Local cQuery        := ""
Local cAliasNes     := GetNextAlias()
Local cProd         := ""
Local cOpc          := ""
Local cRevisao      := ""
Local nX            := 0
Local nSaldo        := 0
Local nSaldoGeral   := 0
Local nQtdTran      := 0
Local nQuant        := 0
Local aAreaNes      := {}
Local aSOT          := {}
Local aRecProcOT    := {}
Local aRecProcOQ    := {}
Local aRet          := {}
Local nSaldoLote    := 0
Local nPontoPed     := 0
Local nQtdPP        := 0
Local lOk           := .T.
Local cInsert       := ' '

Default cProduto    := Nil
A107ProInc()
If AllTrim(cEmp) != AllTrim(cEmpAnt) .Or. AllTrim(cFil) != AllTrim(cFilAnt)
   //Realiza a troca da empresa.
   A107AltEmp(cEmp, cFil)
EndIf
A107ProInc()

TCSQLExec(" DELETE FROM PROCOT ")	
TCSQLExec(" DELETE FROM PROCOQ ")	

While .T.
   cQuery := ""
   //Busca os produtos que estão com saldo negativo.
   If !lEstPP
      cQuery := "SELECT SOR.R_E_C_N_O_ RECNOSOR, "
      cQuery +=       " SOT.R_E_C_N_O_ RECNOSOT, "
      cQuery +=       " SOR.OR_NRLV, "
      cQuery +=       " 'SOR' TIPO "
      cQuery +=  " FROM " + RetSqlName("SOT") + " SOT, "
      cQuery +=             RetSqlName("SOR") + " SOR "
      cQuery += " WHERE SOT.OT_FILIAL = '" + xFilial("SOT") + "' "
      cQuery +=   " AND SOR.OR_FILIAL = '" + xFilial("SOR") + "' "
      cQuery +=   " AND SOR.OR_EMP    = '" + cEmp + "' "
      cQuery +=   " AND SOR.OR_FILEMP = '" + cFil + "' "
      cQuery +=   " AND SOT.OT_RGSOR  = SOR.R_E_C_N_O_ "
      cQuery +=   " AND SOT.OT_QTSALD < 0 "
      cQuery +=   " AND SOT.D_E_L_E_T_ = ' ' "
      cQuery +=   " AND SOR.D_E_L_E_T_ = ' ' "
      //cQuery +=   " AND SOT.R_E_C_N_O_ NOT IN (SELECT OS_SOTDEST FROM " + RetSqlName("SOS") + " )"

      If cProduto != Nil
         cQuery += " AND SOR.OR_PROD = '" + cProduto + "' "
      EndIf
      
      cQuery += " AND SOT.R_E_C_N_O_ NOT IN (SELECT RECNO FROM PROCOT) "
      
      /*
      If Len(aRecProcOT) >= 1
         cQuery += " AND SOT.R_E_C_N_O_ NOT IN ("
         For nX := 1 To Len(aRecProcOT)
            If nX > 1
               cQuery += ", " + cValToChar(aRecProcOT[nX])
            Else
               cQuery += cValToChar(aRecProcOT[nX])
            EndIf
         Next nX
         cQuery += ") "
      EndIf
      */
   Else
      //Busca os registros de ponto de pedido e estoque de segurança, caso esteja parametrizado estoque de segurança 'SÓ NECESSIDADE'.
      cQuery += "SELECT SOQ.R_E_C_N_O_ RECNOSOR, "
      cQuery += "       SOQ.R_E_C_N_O_ RECNOSOT, "
      cQuery += "       SOQ.OQ_NRLV, "
      cQuery += "       'SOQ' TIPO "
      cQuery += "  FROM " + RetSqlName("SOQ") + " SOQ "
      cQuery += " WHERE SOQ.OQ_EMP    = '" + cEmp + "' "
      cQuery += "   AND SOQ.OQ_FILEMP = '" + cFil + "' "
      cQuery += "   AND SOQ.OQ_PERMRP = '001' "
      cQuery += "   AND SOQ.OQ_ALIAS  = 'SB1' "
      If aPergs711[26] == 3
         //Busca estoque de segurança e ponto de pedido
         cQuery += " AND ( SOQ.OQ_DOC = '"+ cTxtPontPed +"' "
         cQuery +=  " OR   SOQ.OQ_DOC = '"+ cTxtEstSeg  +"' )"
      Else
         //Busca ponto de pedido
         cQuery += "   AND SOQ.OQ_DOC    = '"+ cTxtPontPed +"' "
      EndIf
      
      cQuery += " AND SOQ.R_E_C_N_O_ NOT IN (SELECT RECNO FROM PROCOQ) "
      
      /*
      If Len(aRecProcOQ) >= 1
         cQuery += " AND SOQ.R_E_C_N_O_ NOT IN ("
         For nX := 1 To Len(aRecProcOQ)
            If nX > 1
               cQuery += ", " + cValToChar(aRecProcOQ[nX])
            Else
               cQuery += cValToChar(aRecProcOQ[nX])
            EndIf
         Next nX
         cQuery += ") "
      EndIf
      */
   EndIf
   cQuery += " ORDER BY 3 "

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNes,.T.,.T.)

   aAreaNes := GetArea()
   A107ProInc()
   aSOT := {}
   While !(cAliasNes)->(Eof())
      aAdd(aSOT,{(cAliasNes)->(RECNOSOR),;
      	         (cAliasNes)->(RECNOSOT),;
      	         (cAliasNes)->(TIPO)})
      (cAliasNes)->(dbSkip())
   End

   (cAliasNes)->(dbCloseArea())

   A107ProInc()
   If Len(aSot) < 1
      Exit
   EndIf
   For nX := 1 To Len(aSOT)
      nPontoPed := 0
      nQtdPP    := 0

      If AllTrim(aSOT[nX,3]) == "SOR"
         SOR->(dbGoTo(aSOT[nX,1]))
         SOT->(dbGoTo(aSOT[nX,2]))
         
         //aAdd(aRecProcOT,aSOT[nX,2])
         cInsert := " INSERT INTO PROCOT (RECNO, R_E_C_N_O_) VALUES ("+ cValToChar(aSOT[nX,2])+","+ cValToChar(aSOT[nX,2])+" ) "
		 TCSQLExec(cInsert)

         cProd := SOR->(OR_PROD)

         If cDadosProd == "SBZ"
            If aPergs711[31] == 1
               SB1->(MsSeek(xFilial("SB1") + cProd))
               nPontoPed := RetFldProd(SB1->B1_COD,"B1_EMIN")
               If !Empty(nPontoPed)
                  nQtdPP := nPontoPed + 1
                  nQtdPP := nQtdPP * -1
               EndIf
            EndIf
         EndIf

         nSaldo := SOT->(OT_QTSALD) + nQtdPP
      Else
         SOQ->(dbGoTo(aSOT[nX,1]))
         SOR->(dbSetOrder(1))
         If SOR->(dbSeek(xFilial("SOR")+SOQ->(OQ_EMP+OQ_FILEMP+OQ_PROD+OQ_NRRV)))
            If SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+SOQ->OQ_PERMRP))
               //aAdd(aRecProcOQ,SOQ->(Recno()))
               cInsert := " INSERT INTO PROCOQ (RECNO, R_E_C_N_O_) VALUES ("+ cValToChar(SOQ->(Recno()))+", "+ cValToChar(SOQ->(Recno()))+" ) "        
		 	   TCSQLExec(cInsert)
		 
               aSOT[nX,1] := SOR->(Recno())
               aSOT[nX,2] := SOT->(Recno())

               cProd := SOR->(OR_PROD)

               nSaldo := SOT->(OT_QTNECE)*-1
            Else
               Loop
            EndIf
         Else
            Loop
         EndIf
      EndIf

      cOpc        := SOR->(OR_OPC)
      cRevisao    := SOR->(OR_NRRV)
      nSaldoGeral := a107SldSum(SOR->(OR_PROD), SOT->(OT_PERMRP),.T.)
      nLdTmTrans := 0
      dbSelectArea("SB5")
      SB5->(dbSetOrder(1))
      If SB5->(dbSeek(xFilial("SB5")+cProd))
         nLdTmTrans := SB5->B5_LEADTR
      EndIf

      //Possui saldo em alguma empresa, irá fazer a solicitação de transferência, e se necessário
      //irá criar tambem as necessidades de produção.
      If nSaldoGeral > nSaldo
         nQuant   := nSaldo
         nQtdTran := A107TraPrd(cEmp, cFil, SOR->(OR_PROD), nSaldo * -1, SOT->(OT_PERMRP), aSOT[nX,2],.T.)
         //Se o saldo total não for atendido somente pelas transferências, irá gerar as necessidades de produção
         If nSaldoGeral < 0 .Or. nQtdTran == 0 .Or. nQtdTran < ABS(nQuant) .Or. (aSOT[nX,3] == "SOQ" .And. nQuant < 0 .And. nQuant*-1 > nQtdTran)
            A107NesOP(cProd, (nSaldo+nQtdTran), cStrTipo, cStrGrupo, cOpc, cRevisao, aSOT[nX,2], oCenterPanel, .T., .F.)
         EndIf
      Else
         //Não possui saldo em outras empresas, irá gerar as necessidades de produção
         aRet := A107NesOP(cProd, nSaldo, cStrTipo, cStrGrupo, cOpc, cRevisao, aSOT[nX,2], oCenterPanel, .F., .F.)
         //aRet[1] == Indicador que gerou a necessidade de produção
         //aRet[2] == Quantidade de necessidade que gerou. (Pode ser alterada, se o produto possuir alternativos.)
         If aRet[1]
            SOT->(dbGoTo(aSOT[nX,2]))
            Reclock("SOT",.F.)
            SOT->OT_QTSALD := SOT->OT_QTSALD + (aRet[2]*(-1))
            nSaldoLote := A711Lote((aRet[2]*-1),cProd)
            nSaldoLote := nSaldoLote*-1
            SOT->OT_QTTRAN := SOT->OT_QTTRAN + (nSaldoLote*(-1))
            SOT->OT_QTNECE := SOT->OT_QTNECE - (nSaldoLote*(-1))
            MsUnlock()
            a107CriSOV(SOT->(Recno()),aRet[2]*-1,cProd,"S")
         EndIf
      EndIf
   Next nX
End
A107ProInc()
Return

/*--------------------------------------------------------------------------------//
//Programa: A107NesPmp
//Autor:    Lucas Konrad França
//Data:     21/07/15
//Descricao:   Gera as necessidades de produção do PMP para as outras empresas.
               Verifica somente os produtos que não possuem estrutura na empresa atual.
//Parametros:  cEmp         - Código da empresa
//             cFil         - Código da filial
//             cStrTipo     - String com os tipos a serem processados
//             cStrGrupo    - String com os grupos a serem processados
//             oCenterPanel - Objeto do painel de processamento
//Uso:      PCPA107
//--------------------------------------------------------------------------------*/
Function A107NesPmp(cEmp,cFil,cStrTipo,cStrGrupo,oCenterPanel)
   Local cQuery  := ""
   Local cAlias  := "PMPEMP"
   Local nI      := 0
   Local nQtLote := 0
   Local aDados  := {}
   Local aRet    := {}

   Local OQPROD   := 1
   Local OQNRRV   := 2
   Local OQQUANT  := 3
   Local OQOPC    := 4
   Local SOQ_REC  := 5

   Private lForcRecal := .T.

   If AllTrim(cEmp) != AllTrim(cEmpAnt) .Or. AllTrim(cFil) != AllTrim(cFilAnt)
      //Realiza a troca da empresa.
      A107AltEmp(cEmp, cFil)
   EndIf

   cQuery := " SELECT SOQ.R_E_C_N_O_ SOQREC "
   cQuery +=   " FROM " + RetSqlName("SOQ")+ " SOQ "
   cQuery +=  " WHERE SOQ.OQ_FILIAL = '" + xFilial("SOQ") + "' "
   cQuery +=    " AND SOQ.OQ_ALIAS  = 'SHC' "
   cQuery +=    " AND SOQ.OQ_EMP    = '" + cEmp + "'"
   cQuery +=    " AND SOQ.OQ_FILEMP = '" + cFil + "'"
   cQuery +=    " AND NOT EXISTS ( SELECT 1 "
   cQuery +=                       " FROM " + RetSqlName("SG1") + " SG1 "
   cQuery +=                      " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
   cQuery +=                        " AND SG1.D_E_L_E_T_ = ' ' "
   cQuery +=                        " AND SG1.G1_COD     = SOQ.OQ_PROD )"
   cQuery += "  ORDER BY " + SqlOrder(SOQ->(IndexKey(2)))

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   While !(cAlias)->(Eof())
      SOQ->(dbGoTo((cAlias)->(SOQREC)))
      aAdd(aDados,{SOQ->(OQ_PROD),;
                   SOQ->(OQ_NRRV),;
                   SOQ->(OQ_QUANT),;
                   SOQ->(OQ_OPC),;
                   SOQ->(Recno())})

      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   For nI := 1 To Len(aDados)
      //aRet[1] == Indicador que gerou a necessidade de produção
      //aRet[2] == Quantidade de necessidade que gerou. (Pode ser alterada, se o produto possuir alternativos.)
      aRet := A107NesOP(aDados[nI,OQPROD], (aDados[nI,OQQUANT]*-1), cStrTipo, cStrGrupo, aDados[nI,OQOPC], aDados[nI,OQNRRV], aDados[nI,SOQ_REC], oCenterPanel, .F.,.T.)
      If aRet[1]
         SOQ->(dbGoTo(aDados[nI,SOQ_REC]))
         dbSelectArea("SOR")
         SOR->(dbSetOrder(1))
         If SOR->(dbSeek(xFilial("SOR")+SOQ->OQ_EMP+SOQ->OQ_FILEMP+SOQ->OQ_PROD+SOQ->OQ_NRRV))
            dbSelectArea("SOT")
            SOT->(dbSetOrder(1))
            If SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+SOQ->OQ_PERMRP))
               nQtLote := A711Lote(aRet[2]*-1,aDados[nI,OQPROD])
               RecLock("SOT",.F.)
                  SOT->OT_QTENTR -= aRet[2]*-1
                  SOT->OT_QTTRAN += nQtLote
               MsUnLock()
               a107CriSOV(SOT->(Recno()),aRet[2]*-1,aDados[nI,OQPROD],"S")
            EndIf
         EndIf
      EndIf
   Next nI
Return

/*--------------------------------------------------------------------------------//
//Programa: A107NesOP
//Autor:    Lucas Konrad França
//Data:     26/11/14
//Descricao:   Gera as necessidades de produção para as outras empresas.
//Parametros:  cProd        - Produto que será utilizado para gerar a necessidade de produção
//             nSaldo       - Saldo para geração da necessidade
//             cStrTipo     - String com os tipos a serem processados
//             cStrGrupo    - String com os Grupos a serem processados
//             cOpc         - Opcional da tabela SOR
//             cRevisao     - Revisão da estrutura
//             nRecOrig     - RECNO da tabela SOT que solicitou a necessidade de produção
//             oCenterPanel - Objeto do painel de processamento
//             lAtualiza    - Identificador para atualizar informações da SOQ
//             lPmp         - Identifica se está chamado para uma demanda do PMP
//Uso:      PCPA107
//--------------------------------------------------------------------------------*/
Function A107NesOP(cProd, nSaldo, cStrTipo, cStrGrupo, cOpc, cRevisao, nRecOrig, oCenterPanel, lAtualiza, lPmp)
Local nI         := 0
Local lRet       := .F.
Local lAltSEst   := .T.
Local lCalcula   := .T.
Local cEmp       := cEmpAnt
Local cFil       := cFilAnt
Local cPeriodo   := ""
Local cTipo      := ""
Local cOpc       := ""
Local cRevisao   := ""
Local aRetEmp    := {}
Local nSaldoLote := 0
Local aEmpresas  := {}
Local nTamFil    := TamSX3("OQ_FILEMP")[1]
Local nNeceBkp   := 0
Local nNeceAtu   := 0
Local nRecSOT    := 0

aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nI := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nI,1],aEmpCent[nI,2],aEmpCent[nI,3]})
   EndIf
Next nI

//Se for do PMP, o nRecOrig é o RECNO da tabela SOQ. Faz a busca do RECNO da tabela SOT
If lPmp
   SOQ->(dbGoTo(nRecOrig))
   nRecOrig := 0
   dbSelectArea("SOR")
   SOR->(dbSetOrder(1))
   If SOR->(dbSeek(xFilial("SOR")+SOQ->OQ_EMP+SOQ->OQ_FILEMP+SOQ->OQ_PROD+SOQ->OQ_NRRV))
      dbSelectArea("SOT")
      SOT->(dbSetOrder(1))
      If SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+SOQ->OQ_PERMRP))
         nRecOrig := SOT->(Recno())
      EndIf
   EndIf
EndIf

SOT->(dbGoTo(nRecOrig))
cPeriodo := SOT->OT_PERMRP
SOR->(dbGoTo(SOT->(OT_RGSOR)))
cOpc     := SOR->OR_OPC
cRevisao := SOR->OR_NRRV
//Avalia se o produto eh utilizado na tabela SGI como original ou alternativo
If A107ExSGI(cProd)
   // Avalia se o produto não foi utilizado como alternativo em data futura e troca
   A107AvSldA(cProd,StrZero(Val(cPeriodo)-1,3),SOR->OR_NRRV,cStrTipo,cStrGrupo,aPeriodos[Val(cPeriodo)],.T.)
   nSaldo := A107SldSOT(cProd,cPeriodo,cOpc,cRevisao,cNivel,,.F.)
EndIf
If nSaldo < 0
   //Verifica se o produto possui estrutura.
   dbSelectArea("SG1")
   SG1->(dbSetOrder(1))
   If !(SG1->(dbSeek(xFilial("SG1")+cProd)))
      //Item não possui estrutura nesta empresa, realiza a busca nas outras empresas.
      aRetEmp := verItProd(cProd)
      If aRetEmp[1] != Nil .And. aRetEmp[2] != Nil
         nSaldoLote := A711Lote((nSaldo*-1),cProd)
         nSaldoLote := nSaldoLote * -1
         nSaldo     := nSaldoLote

         If lAtualiza
            SOT->(dbGoTo(nRecOrig))
            Reclock("SOT",.F.)
            SOT->OT_QTSALD := SOT->OT_QTSALD + (nSaldo * -1)
            SOT->OT_QTTRAN := SOT->OT_QTTRAN + (nSaldoLote * -1)
            SOT->OT_QTNECE := SOT->OT_QTNECE - (nSaldoLote * -1)
            MsUnlock()
            a107CriSOV(SOT->(Recno()),nSaldoLote*-1,cProd,"S")
         EndIf

         dbSelectArea("SOR")
         SOR->(dbSetOrder(1))
         SOR->(dbSeek(xFilial("SOR")+aRetEmp[1]+PadR(aRetEmp[2],nTamFil)+cProd))

         dbSelectArea("SOT")
         SOT->(dbSetOrder(1))
         SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+cPeriodo))

         nSaldoIni := SOT->OT_QTSLES
         nNeceBkp  := SOT->OT_QTNECE
         nRecSOT   := SOT->(Recno())

         A107AltEmp(aRetEmp[1], aRetEmp[2])
         //Encontrou a estrutura.
         //Atualiza o saldo como Entrada para o produto, na filial onde ele possui estrutura.
         If lPmp
            cTipo    := "2"
            lAltSEst := .F.
            lCalcula := .T.
         Else
            cTipo    := "4"
            lAltSEst := .T.
            lCalcula := .F.
         EndIf
         A107CriSOR(cProd,cOpc,cRevisao,/*04*/,cPeriodo,(nSaldoLote*(-1)),cTipo,"SG1",.T.,cStrTipo,cStrGrupo,.F.,/*13*/,nRecOrig,nSaldoIni,/*16*/,nSaldoLote,lAltSEst,aEmpresas)
         SOT->(dbGoTo(nRecSOT))
         If lPmp
            nNeceAtu := nSaldoLote*-1
            nNeceBkp := 0
            a107CriSOV(SOT->(Recno()),nNeceAtu,cProd,"N")
         Else
            nNeceAtu := SOT->OT_QTNECE
         EndIf
         //Explode a estrutura do produto.
         A107ExplEs(cProd,cOpc,cRevisao,nNeceAtu-nNeceBkp,cPeriodo,cStrTipo,cStrGrupo,/*08*/,lCalcula,.T.,.T.)
         //Volta a empresa
         A107AltEmp(cEmp, cFil)
         lRet := .T.
      EndIf
   EndIf
EndIf
Return {lRet,nSaldo}

/*--------------------------------------------------------------------------------//
//Programa: insertSOS
//Autor:    Lucas Konrad França
//Data:     24/11/14
//Descricao:   Insere o registro na tabela de controle dos saldos já processados (SOS).
//Parametros:  nRecO  - R_E_C_N_O_ de origem da tabela SOT
//             nRecD  - R_E_C_N_O_ de destino da tabela SOT
//             nQtd   - Quantidade movimentada
//             cTipo  - Tipo do movimento: 1 = Estoque, 2 = Produção
//Uso:      PCPA107
//--------------------------------------------------------------------------------*/
Static function insertSOS(nRecO, nRecD, nQtd, cTipo)
Local aAreaBkp := GetArea()

If nQtd < 0
   nQtd := nQtd*-1
EndIf
//Verifica se já existe registro, se ja existir somente atualiza a quantidade
dbSelectArea("SOS")
SOS->(dbSetOrder(1))
If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nRecO)),10)+PadR(AllTrim(Str(nRecD)),10)+cTipo))
   RecLock("SOS",.F.)
      SOS->OS_QUANT := OS_QUANT += nQtd
   MsUnLock()
Else
   RecLock("SOS",.T.)
      SOS->OS_FILIAL  := xFilial("SOS")
      SOS->OS_SOTORIG := nRecO
      SOS->OS_SOTDEST := nRecD
      SOS->OS_QUANT   := nQtd
      SOS->OS_TIPO    := cTipo
   MsUnLock()
EndIf

RestArea(aAreaBkp)
Return

/*--------------------------------------------------------------------------------//
//Programa: A107TraPrd
//Autor:    Lucas Konrad França
//Data:     21/11/14
//Descricao:   Faz a solicitação de transferência de um produto entre as empresas.
//Parametros:  cEmp    - Empresa que receberá o saldo.
//             cFil    - Filial que receberá o saldo.
//             cProd   - Produto que será transferido.
//             nQtd    - Quantidade a ser transferida.
//             cPerMrp - Período do MRP
//             nRecSOT - RECNO da SOT que está recebendo o saldo.
//             lVerSld - Indicador para verificar o saldo utilizado nos próximos períodos
//             lEstSeg - Indica se está transferindo para atender o estoque de segurança. 
//                       Nesse caso, cria a tabela SOQ identificando a quantidade utilizada para estoque de segurança na empresa.
//Uso:      PCPA107
//--------------------------------------------------------------------------------*/
Function A107TraPrd(cEmp, cFil, cProd, nQtd, cPerMrp, nRecSOT, lVerSld, lEstSeg, cMsgSOQ, cTipos, cGrupos)
Local cQuery     := ""
Local cNextAlias := ""
Local cNextPer   := ""
Local cBkpEmp    := ""
Local cBkpFil    := ""
Local nI         := 0
Local nZ         := 0
Local nSaldo     := 0
Local nSaldoIni  := 0
Local nSldFinal  := 0
Local nQtdBkp    := 0
Local nQtdSOT    := 0
Local nQtdTran   := 0
Local nQtUsada   := 0
Local nRecSOR    := 0
Local nQtdLote   := 0
Local nPontoPed  := 0
Local nQtdPP     := 0
Local nEstSeg    := 0
Local nNovoSaldo := 0
Local aEmpresas  := {}
Local lGerou     := .F.

Default lEstSeg := .F.
Default cMsgSOQ := ""
Default cTipos  := ""
Default cGrupos := ""

aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nz := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nz,1],aEmpCent[nz,2],aEmpCent[nz,3]})
   EndIf
Next nz

//Verifica ponto de pedido
If cDadosProd != "SBZ" //Se utiliza a SBZ, faz a busca do ponto de pedido quando encontrar algum saldo.
   If aPergs711[31] == 1
      SB1->(MsSeek(xFilial("SB1") + cProd))
      nPontoPed := RetFldProd(SB1->B1_COD,"B1_EMIN")
      If !Empty(nPontoPed)
         nQtdPP := nPontoPed + 1
      EndIf
   EndIf
EndIf

//Busca o saldo do produto nas empresas.
For nI := 1 To Len(aEmpresas) //Busca seguindo a prioridade das empresas
   lGerou := .F.
   cQuery := "SELECT SOT.OT_QTSALD, "
   cQuery +=       " SOT.R_E_C_N_O_ SOTREC, "
   cQuery +=       " SOT.OT_PERMRP, "
   cQuery +=       " SOR.OR_PROD, "
   cQuery +=       " SOR.OR_EMP, "
   cQuery +=       " SOR.OR_FILEMP "
   cQuery +=  " FROM " + RetSqlName("SOT") + " SOT, "
   cQuery +=             RetSqlName("SOR") + " SOR "
   cQuery += " WHERE SOT.OT_FILIAL = '" + xFilial("SOT") + "' "
   cQuery +=   " AND SOR.OR_FILIAL = '" + xFilial("SOR") + "' "
   cQuery +=   " AND SOR.OR_EMP    = '" + aEmpresas[nI][1] + "' "
   cQuery +=   " AND SOR.OR_FILEMP = '" + aEmpresas[nI][2] + "' "
   cQuery +=   " AND SOT.OT_RGSOR  = SOR.R_E_C_N_O_ "
   cQuery +=   " AND SOT.OT_PERMRP = '" + cPerMrp + "' "
   cQuery +=   " AND SOT.OT_QTSALD > 0 "
   cQuery +=   " AND SOT.D_E_L_E_T_ = ' ' "
   cQuery +=   " AND SOR.D_E_L_E_T_ = ' ' "
   cQuery +=   " AND SOT.OT_RGSOR IN (SELECT DISTINCT SOR.R_E_C_N_O_ "
   cQuery +=                          " FROM " + RetSqlName("SOR") + " SOR "
   cQuery +=                         " WHERE SOR.OR_PROD = '" + cProd + "' "
   cQuery +=                           " AND SOR.OR_FILIAL = '" + xFilial("SOR") + "' "
   cQuery +=                           " AND SOR.OR_EMP    = '" + aEmpresas[nI][1] + "' "
   cQuery +=                           " AND SOR.OR_FILEMP = '" + aEmpresas[nI][2] + "' "
   cQuery +=                           " AND SOR.D_E_L_E_T_ = ' ' ) "

   cQuery := ChangeQuery(cQuery)

   cNextAlias := GetNextAlias()
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
   If (cNextAlias)->(OT_QTSALD) <= 0 .Or. ;
      (AllTrim(cEmp) == AllTrim((cNextAlias)->(OR_EMP)) .And. AllTrim(cFil) == AllTrim((cNextAlias)->(OR_FILEMP)))
      (cNextAlias)->(dbCloseArea())
      Loop
   EndIf

   //Se já ocorreu uma transferência da filial ORIGEM para a filial DESTINO, descarta este registro.
   dbSelectArea("SOS")
   SOS->(dbSetOrder(1))
   If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nRecSOT)),10)+PadR(AllTrim(Str((cNextAlias)->(SOTREC))),10) ))
      If SOS->OS_QUANT > 0
         (cNextAlias)->(dbCloseArea())
         Loop
      EndIf
   EndIf

   nEstSeg := 0
   nQtdPP  := 0

   cBkpEmp := cEmpAnt
   cBkpFil := cFilAnt
   NGPrepTBL({{"SBZ",1},{"SB1",1}},aEmpresas[nI][1],AllTrim(aEmpresas[ni][2]))

   //Se utiliza a SBZ, faz a busca do ponto de pedido
   /*If cDadosProd == "SBZ"
      nEstSeg := 0
      nQtdPP  := 0

      //Prepara a tabela SBZ para a filial onde existe o saldo.
      cBkpEmp := cEmpAnt
      cBkpFil := cFilAnt
      NGPrepTBL({{"SBZ",1}},aEmpresas[nI][1],AllTrim(aEmpresas[ni][2]))

      If aPergs711[31] == 1
         SB1->(MsSeek(xFilial("SB1") + cProd))
         nPontoPed := RetFldProd(SB1->B1_COD,"B1_EMIN")
         If !Empty(nPontoPed)
            nQtdPP := nPontoPed + 1
         EndIf
      EndIf

      If aPergs711[26] == 3
         nEstSeg := buscaEstSeg(SB1->B1_COD,aEmpresas)
      EndIf
      //Restaura a tabela SBZ para a filial original.
      NGPrepTBL({{"SBZ",1}},cBkpEmp,AllTrim(cBkpFil))

   EndIf*/

   If aPergs711[31] == 1
      SB1->(MsSeek(xFilial("SB1") + cProd))
      nPontoPed := RetFldProd(SB1->B1_COD,"B1_EMIN")
      If !Empty(nPontoPed)
         nQtdPP := nPontoPed + 1
      EndIf
   EndIf

   If aPergs711[26] == 3
      nEstSeg := buscaEstSeg(cProd,aEmpresas)
   EndIf

   //Restaura a tabela SBZ para a filial original.
   NGPrepTBL({{"SBZ",1},{"SB1",1}},cBkpEmp,AllTrim(cBkpFil))

   If lVerSld
      nQtUsada := verSldMrp((cNextAlias)->(OR_PROD),(cNextAlias)->(OT_PERMRP),aEmpresas[nI][1],aEmpresas[ni][2],.F.)
   Else
      nQtUsada := 0
   EndIf
   nSaldo := (cNextAlias)->(OT_QTSALD) - nQtd - nQtUsada - nQtdPP - nEstSeg

   If nSaldo >= 0
      //A quantidade é atendida com o saldo existente na empresa
      insertSOS((cNextAlias)->(SOTREC), nRecSOT, nQtd, "1")
      insSldMrp((cNextAlias)->(OR_PROD),(cNextAlias)->(OT_PERMRP),nQtd,aEmpresas[nI][1],aEmpresas[nI][2])
      SOT->(dbGoTo((cNextAlias)->(SOTREC)))
      nSaldoIni := SOT->OT_QTSLES
      nRecSOR := SOT->OT_RGSOR
      nQtdSOT := SOT->OT_QTSALD
      Reclock("SOT",.F.)
      SOT->OT_QTSALD := SOT->OT_QTSALD - nQtd
      If SOT->OT_QTSLES >= nQtd .And. SOT->OT_PERMRP != "001"
         SOT->OT_QTSLES := SOT->OT_QTSLES - nQtd
      EndIf
      SOT->OT_QTTRAN := SOT->OT_QTTRAN + (nQtd*(-1))
      MsUnlock()

      SOT->(dbGoTo(nRecSOT))
      nQtdBkp  := SOT->OT_QTSALD
      nQtdLote := A107Lote(nQtd,cProd)
      Reclock("SOT",.F.)
      SOT->OT_QTSALD := SOT->OT_QTSALD + nQtd
      SOT->OT_QTTRAN := SOT->OT_QTTRAN + nQtd
      SOT->OT_QTNECE := SOT->OT_QTNECE - nQtdLote
      MsUnlock()
      a107CriSOV(SOT->(Recno()),nQtd,cProd,"S")
      atuNeces(SOT->(Recno()),nQtd,"N")
      nQtdTran += nQtd

      A107AltEmp(aEmpresas[nI][1], aEmpresas[nI][2])

      SOR->(dbGoTo(nRecSOR))
      SB1->(dbSetOrder(1))
      SB1->(dbSeek(xFilial("SB1")+cProd))
      
      If lEstSeg
         //A107CriSOQ(aPeriodos[1],cProd,SOR->(OR_OPC),SB1->B1_REVATU,"SB1",SB1->(Recno()),cMsgSOQ,/*08*/,/*09*/,nQtd,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cTipos,cGrupos,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas)
      EndIf
      
      A107Recalc(cProd,SOR->(OR_OPC),SOR->(OR_NRRV),cPerMrp,nSaldoIni,/*06*/,nRecSOR,/*08*/,aEmpresas)
      A107AltEmp(cEmp, cFil)
      SOT->(dbGoTo(nRecSOT))
      SOR->(dbGoTo(SOT->OT_RGSOR))
      //Calcula os próximos periodos, pois pode existir diferença de saldo
      If SOT->OT_QTNECE == 0
         nSldFinal := Iif(SOT->OT_QTSALD<0,SOT->OT_QTSALD*-1,SOT->OT_QTSALD)
      Else
         nSldFinal := SOT->OT_QTNECE - Iif(SOT->OT_QTSALD<0,SOT->OT_QTSALD*-1,SOT->OT_QTSALD)
      EndIf
      cNextPer  := StrZero(Val(cPerMrp)+1,3)
      If Val(cNextPer) <= Len(aPeriodos)
         A107Recalc(cProd,SOR->(OR_OPC),SOR->(OR_NRRV),cNextPer,nSldFinal,/*06*/,SOT->OT_RGSOR,/*08*/,aEmpresas)
      EndIf
      Exit
   Else
      //A quantidade não é atendida com o saldo existente na empresa.
      SOT->(dbGoTo((cNextAlias)->(SOTREC)))
      nRecSOR := SOT->OT_RGSOR
      nQtdSOT := SOT->OT_QTSALD
      If nQtdSOT - nQtUsada - nQtdPP - nEstSeg > 0
         nQtdSOT := nQtdSOT - nQtUsada - nQtdPP - nEstSeg
         nQtd := nQtd - nQtdSOT
         insertSOS((cNextAlias)->(SOTREC), nRecSOT, nQtdSOT, "1")
         insSldMrp((cNextAlias)->(OR_PROD),(cNextAlias)->(OT_PERMRP),nQtdSOT,aEmpresas[nI][1],aEmpresas[nI][2])
         Reclock("SOT",.F.)
         SOT->OT_QTSALD := SOT->OT_QTSALD-nQtdSOT
         SOT->OT_QTTRAN := SOT->OT_QTTRAN + (nQtdSOT*(-1))
         MsUnlock()
         nNovoSaldo := SOT->OT_QTSLES
         SOT->(dbGoTo(nRecSOT))
         Reclock("SOT",.F.)
         SOT->OT_QTSALD := SOT->OT_QTSALD + nQtdSOT
         SOT->OT_QTTRAN := SOT->OT_QTTRAN + nQtdSOT
         SOT->OT_QTNECE := SOT->OT_QTNECE - nQtdSOT //A107Lote(nQtdSOT,cProd)
         MsUnlock()
         a107CriSOV(SOT->(Recno()),nQtdSOT,cProd,"S")
         atuNeces(SOT->(Recno()),nQtdSOT,"N")
         nQtdTran += nQtdSOT
         A107AltEmp(aEmpresas[nI][1], aEmpresas[nI][2])

         SB1->(dbSetOrder(1))
         SB1->(dbSeek(xFilial("SB1")+cProd))

         If lEstSeg
            //A107CriSOQ(aPeriodos[1],cProd,SOR->(OR_OPC),SB1->B1_REVATU,"SB1",SB1->(Recno()),cMsgSOQ,/*08*/,/*09*/,nQtdSOT,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cTipos,cGrupos,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas)
         EndIf

         SOR->(dbGoTo(nRecSOR))
         A107Recalc(cProd,SOR->(OR_OPC),SOR->(OR_NRRV),cPerMrp,nNovoSaldo,/*06*/,nRecSOR,/*08*/,aEmpresas)
         A107AltEmp(cEmp, cFil)
         SOT->(dbGoTo(nRecSOT))
         SOR->(dbGoTo(SOT->OT_RGSOR))
         //Calcula os próximos periodos, pois pode existir diferença de saldo
         nSldFinal := SOT->OT_QTNECE - Iif(SOT->OT_QTSALD<0,SOT->OT_QTSALD*-1,SOT->OT_QTSALD)
         cNextPer  := StrZero(Val(cPerMrp)+1,3)
         If Val(cNextPer) <= Len(aPeriodos)
            A107Recalc(cProd,SOR->(OR_OPC),SOR->(OR_NRRV),cNextPer,nSldFinal,/*06*/,SOT->OT_RGSOR,/*08*/,aEmpresas)
         EndIf
         lGerou := .T.
      EndIf
   EndIf
   If Select(cNextAlias) > 0
      (cNextAlias)->(dbCloseArea())
   EndIf
Next nI

Return nQtdTran

/*------------------------------------------------------------------------//
//Programa: a107SldSum
//Autor:    Lucas Konrad França
//Data:     21/11/14
//Descricao:   Busca o saldo sumarizado do produto em todas as empresas.
//Parametros:  cProd   - Produto a ser verificado.
//             cPerMrp - Período do MRP
//             lPositivo - Buscar somente os saldos que sejam > 0
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function a107SldSum(cProd, cPerMrp, lPositivo, cOpc, mOpc)
Local cQuery     := ""
Local nSaldo     := 0
Local aAreaBkp   := GetArea()
Local cNextAlias := GetNextAlias()
Local aRecnos    := {}
Local nI         := 0
Default cOpc := ""
Default mOpc := ""

If !Empty(cOpc) .Or. !Empty(mOpc)
   cQuery := " SELECT DISTINCT SOR.R_E_C_N_O_ RECSOR "
   cQuery +=   " FROM " + RetSqlName("SOR") + " SOR "
   cQuery +=  " WHERE SOR.OR_PROD = '" + cProd + "' "
   cQuery +=    " AND SOR.OR_FILIAL = '" + xFilial("SOR") + "' "
   cQuery +=    " AND SOR.D_E_L_E_T_ = ' ' "
   
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
   While (cNextAlias)->(!Eof())
   	SOR->(dbGoTo((cNextAlias)->(RECSOR)))
   	
   	If (!Empty(cOpc) .And. SOR->OR_OPC == cOpc) .Or. (!Empty(mOpc) .And. SOR->OR_MOPC == mOpc)
   		aAdd(aRecnos, SOR->(Recno()))
   	EndIf   	
   	(cNextAlias)->(dbSkip())
   End
   (cNextAlias)->(dbCloseArea())
   If Len(aRecnos) > 0
      cNextAlias := GetNextAlias()
   EndIf
EndIf

If ((!Empty(cOpc) .Or. !Empty(mOpc)) .And. Len(aRecnos) > 0) .Or. (Empty(cOpc) .And. Empty(mOpc))
   cQuery := "SELECT SUM(SOT.OT_QTSALD) SALDO"
   cQuery +=  " FROM " + RetSqlName("SOT") + " SOT "
   cQuery += " WHERE SOT.OT_FILIAL = '" + xFilial("SOT") + "' "
   cQuery +=   " AND SOT.D_E_L_E_T_ = ' ' "
   cQuery +=   " AND SOT.OT_PERMRP  = '" + cPerMrp + "' "
   If lPositivo
      cQuery += " AND SOT.OT_QTSALD > 0 "
   EndIf
   If Len(aRecnos) > 0 .And. (!Empty(cOpc) .Or. !Empty(mOpc))
      cQuery +=   " AND SOT.OT_RGSOR IN ("
      For nI := 1 To Len(aRecnos)
         If nI > 1
            cQuery += ","
         EndIf
         cQuery += cValToChar(aRecnos[nI])
      Next nI 
      cQuery += ")"
   Else
      cQuery +=   " AND SOT.OT_RGSOR IN (SELECT DISTINCT SOR.R_E_C_N_O_ "
      cQuery +=                          " FROM " + RetSqlName("SOR") + " SOR "
      cQuery +=                         " WHERE SOR.OR_PROD = '" + cProd + "' "
      cQuery +=                           " AND SOR.OR_FILIAL = '" + xFilial("SOR") + "' "
      cQuery +=                           " AND SOR.D_E_L_E_T_ = ' ' ) "
   EndIf
   
   cQuery := ChangeQuery(cQuery)
   
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
   nSaldo := (cNextAlias)->(SALDO)
   (cNextAlias)->(dbCloseArea())
EndIf

RestArea(aAreaBkp)
Return nSaldo

/*------------------------------------------------------------------------//
//Programa: A107GrvTm
//Autor:    Felipe Nunes de Toledo
//Data:     27/12/07
//Descricao:   Grava um log com os principais processos do MRP
//Parametros:  ExpO1 - Objeto tNewProcess
//          ExpC2 - Texto a ser gravado no log
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107GrvTm(oMainPainel, cTexto)

If (oMainPainel <> Nil) .And. !Empty(cTexto)
   oMainPainel:SaveLog(ctexto)
EndIf

Return Nil

/*------------------------------------------------------------------------//
//Programa: PCPA107Ctb
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Limpa a tabela de necessidades por filial.
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PCPA107Ctb(aEmpresas)
Local cDelete := ""
Local nI      := 0
//Delete diretamente o registro, pois anteriormente o programa fazia dbDelete e após isso um Pack para limpar
//For nI := 1 To Len(aEmpresas)
//   cDelete := " DELETE FROM "+RetFullName("SHF",aEmpresas[nI,1])
//   cDelete += " WHERE HF_FILIAL      = '"+xFilial("SHF")+"' "
//   cDelete +=   " AND HF_FILNEC      = '"+aEmpresas[nI,2]+"' "
//   TCSQLExec(cDelete)
//Next nI
cDelete := " DELETE FROM "+RetSqlName("SOQ")
cDelete += " WHERE OQ_FILIAL = '"+xFilial("SOQ")+"' "
TCSQLExec(cDelete)

cDelete := " DELETE FROM "+RetSqlName("SOR")
cDelete += " WHERE OR_FILIAL = '"+xFilial("SOR")+"' "
TCSQLExec(cDelete)

cDelete := " DELETE FROM "+RetSqlName("SOS")
cDelete += " WHERE OS_FILIAL = '"+xFilial("SOS")+"' "
TCSQLExec(cDelete)

cDelete := " DELETE FROM "+RetSqlName("SOT")
cDelete += " WHERE OT_FILIAL = '"+xFilial("SOT")+"' "
TCSQLExec(cDelete)

cDelete := " DELETE FROM "+RetSqlName("SOV")
cDelete += " WHERE OV_FILIAL = '"+xFilial("SOV")+"' "
TCSQLExec(cDelete)

//Numero do mrp
c711NumMRP:=GetMV("MV_NEXTMRP")
PutMV("MV_NEXTMRP",Soma1(Substr(c711NumMRP,1,Len(SC2->C2_SEQMRP))))

Return

/*------------------------------------------------------------------------//
//Programa: A107Pesq
//Autor:    Rodrigo de A. Sartorio
//Data:     21/08/02
//Descricao:   Pesquisa por um determinado produto + opcional
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107Pesq()
Local cPrd711Vaz     := CriaVar("B1_COD",.F.)
Local cOpc711Vaz     := CriaVar("C2_OPC",.F.)
Local cRev711Vaz     := CriaVar("B1_REVATU",.F.)
Local cPesq          := cPrd711Vaz+cOpc711Vaz+cRev711Vaz
Local oDlg,lCancel   := .F.
Local cOldCargo      := oTreeM711:GetCargo()
Local nPos

DEFINE MSDIALOG oDlg TITLE STR0035 From 145,0 To 270,400 OF oMainWnd PIXEL
@ 10,15 TO 40,185 LABEL STR0067 OF oDlg PIXEL   //"Produto + Opcional a Pesquisar "
@ 20,20 MSGET cPesq Picture "@!S25" OF oDlg PIXEL
DEFINE SBUTTON FROM 50,131 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 50,158 TYPE 2 ACTION (oDlg:End(),lCancel:=.T.) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg

//Pesquisa no tree o conteudo digitado
If !lCancel .And. !Empty(cPesq)
   nPos := AsCan(aDbTree,{|x| x[1]+x[2]+x[3]==cPesq})
   If !Empty(nPos) .And. !oTreeM711:TreeSeek("01"+aDbTree[nPos,7]+StrZero(0,12))
      oTreeM711:TreeSeek(cOldCargo)
   Else
      Eval(oTreeM711:bChange)
   EndIf
EndIf

Return

/*------------------------------------------------------------------------//
//Programa: A107ShPrd
//Autor:    Rodrigo de A. Sartorio
//Data:     11/12/02
//Descricao:   Mostra os dados do produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107ShPrd()
Local nPos     := AsCan(aDbTree,{|x| x[7]==SubStr(oTreeM711:GetCargo(),3,12)})
Local cProduto:= IIf(Empty(nPos),Space(15),aDbTree[nPos,1])
Local aArea := GetArea()

dbSelectArea("SB1")
dbSetOrder(1)
If MSSeek(xFilial("SB1")+cProduto)
   cCadastro:=cCadastro+" - "+STR0039
   AxVisual("SB1",SB1->(Recno()),1)
   cCadastro := STR0001
EndIf
RestArea(aArea)

Return

/*------------------------------------------------------------------------//
//Programa: A107ViewSld
//Autor:    Erike Yuri da Silva
//Data:     20/10/05
//Descricao:   Visualizador do Detalhamento de saldos em estoque do produto
//Parametros:  aFilAlmox - Array com os armazéns filtrados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107ViewSld(aFilAlmox)
Local aViewB2 := {}
Local aSaldos := {}
Local oDlg,oBold,oListBox

DbSelectArea("SB1")
DbSetOrder(1)
MsSeek(xFilial("SB1")+cProdDetSld)

aSaldos := A107DSaldo(cProdDetSld,/*02*/,@aFilAlmox,.T.,aViewB2,/*06*/,/*07*/,/*08*/,/*09*/)

If Empty(aViewB2)
   Aviso(STR0030,STR0068,{STR0069},2) //"Atencao"###"Nao exitem informacoes a serem visualizadas. Verifique se o produto foi selecionado no Tree."###"Voltar"
Else
   DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
   DEFINE MSDIALOG oDlg FROM 000,000  TO 350,600 TITLE STR0070 Of oMainWnd PIXEL  //"Detalhamento do Saldo em Estoque Disponivel no Calculo do MRP"
      @ 023,004 To 24,296 Label "" of oDlg PIXEL
      @ 113,004 To 114,296 Label "" of oDlg PIXEL
      oListBox := TWBrowse():New( 30,2,297,69,,{RetTitle("B2_LOCAL"),RetTitle("B2_QATU"),RetTitle("B2_QNPT"),RetTitle("B2_QTNP"),STR0071,STR0072,STR0073},{17,55,55,55,55,55},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //"Qtd.Rej.CQ"###"Qtd.Bloqueada por Lote"###"Sld.Disponivel"
      oListBox:SetArray(aViewB2)
      oListBox:bLine := { || aViewB2[oListBox:nAT]}
      @ 004,010 SAY SM0->M0_CODIGO+"/"+FWGETCODFILIAL+" - "+SM0->M0_FILIAL+"/"+SM0->M0_NOME  Of oDlg PIXEL SIZE 245,009
      @ 014,010 SAY Alltrim(cProdDetSld)+ " - "+SB1->B1_DESC Of oDlg PIXEL SIZE 245,009 FONT oBold
      @ 104,010 SAY STR0074 Of oDlg PIXEL SIZE 30 ,9 FONT oBold  //"TOTAL "

      @ 120,007 SAY STR0075 of oDlg PIXEL //"Quantidade Disponivel    "
      @ 119,075 MsGet aSaldos[1] Picture PesqPict("SB2","B2_QATU") of oDlg PIXEL SIZE 070,009 When .F.

      @ 120,155 SAY RetTitle("B2_QNPT") of oDlg PIXEL
      @ 119,223 MsGet aSaldos[2] Picture PesqPict("SB2","B2_QEMP") of oDlg PIXEL SIZE 070,009 When .F.

      @ 135,007 SAY RetTitle("B2_QTNP") of oDlg PIXEL
      @ 134,075 MsGet aSaldos[3] Picture PesqPict("SB2","B2_QATU") of oDlg PIXEL SIZE 070,009 When .F.

      @ 135,155 SAY STR0071 of oDlg PIXEL  //"Qtd.Rej.CQ"
      @ 134,223 MsGet aSaldos[4] Picture PesqPict("SB2","B2_SALPEDI") of oDlg PIXEL SIZE 070,009 When .F.

      @ 150,007 SAY STR0072 of oDlg PIXEL
      @ 149,075 MsGet aSaldos[5] Picture PesqPict("SDD","DD_SALDO") of oDlg PIXEL SIZE 070,009 When .F.

      @ 160,244  BUTTON STR0069 SIZE 045,010  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL   //"Voltar"
   ACTIVATE MSDIALOG oDlg CENTERED
EndIf
Return

/*------------------------------------------------------------------------//
//Programa: A107AtuPeriodo
//Autor:    Ricardo Prandi
//Data:     18/09/2013
//Descricao:   Funcao responsavel pela atualizacao de periodos e criação
//            da aPeriodos
//Parametros:  ExpL1 : Indica se o MRP sera executado em modo visualizacao
//          ExpN1 : Indica o tipo de periodo escolhido pelo operador
//          ExpD1 : Data de inicio dos periodos
//          ExpA1 : Array com os periodos que serao retornados por refer
//          ExpA2 : Array com parametros (opcoes)
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107AtuPeriodo(lVisualiza,nTipo,dInicio,aPeriodos,aOpcoes)
Local cForAno  := ""
Local nPosAno  := 0
Local nTamAno  := 0
Local i        := 0
Local nY2T        := If(__SetCentury(),2,0)

DEFAULT lVisualiza := .F.

If __SetCentury()
   nPosAno := 1
   nTamAno := 4
   cForAno := "ddmmyyyy"
Else
   nPosAno := 3
   nTamAno := 2
   cForAno := "ddmmyy"
Endif

//Monta a data de inicio de acordo com os parametros
If (nTipo == 2)                         // Semanal
   While Dow(dInicio)!=2
      dInicio--
   end
ElseIf (nTipo == 3) .or. (nTipo == 4)   // Quinzenal ou Mensal
   dInicio:= CtoD("01/"+Substr(DtoS(dInicio),5,2)+Substr(DtoC(dInicio),6,3+nY2T),cForAno)
ElseIf (nTipo == 5)                     // Trimestral
   If Month(dInicio) < 4
      dInicio := CtoD("01/01/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
   ElseIf (Month(dInicio) >= 4) .and. (Month(dInicio) < 7)
      dInicio := CtoD("01/04/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
   ElseIf (Month(dInicio) >= 7) .and. (Month(dInicio) < 10)
      dInicio := CtoD("01/07/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
   ElseIf (Month(dInicio) >=10)
      dInicio := CtoD("01/10/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
   EndIf
ElseIf (nTipo == 6)                     // Semestral
   If Month(dInicio) <= 6
      dInicio := CtoD("01/01/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
   Else
      dInicio := CtoD("01/07/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
   EndIf
EndIf

//Monta as datas de acordo com os parametros
If nTipo != 7
   For i := 1 to aOpcoes[2][1]
      dInicio := A107NextUtil(dInicio,aPergs711)
      AADD(aPeriodos,dInicio)
      If nTipo == 1
         dInicio ++
      ElseIf nTipo == 2
         dInicio += 7
      ElseIf nTipo == 3
         dInicio := StoD(If(Substr(DtoS(dInicio),7,2)<"15",Substr(DtoS(dInicio),1,6)+"15",;
                         If(Month(dInicio)+1<=12,Str(Year(dInicio),4)+StrZero(Month(dInicio)+1,2)+"01",;
                         Str(Year(dInicio)+1,4)+"0101")),cForAno)
      ElseIf nTipo == 4
         dInicio := CtoD("01/"+If(Month(dInicio)+1<=12,StrZero(Month(dInicio)+1,2)+;
                         "/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
      ElseIf nTipo == 5
         dInicio := CtoD("01/"+If(Month(dInicio)+3<=12,StrZero(Month(dInicio)+3,2)+;
                         "/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
      ElseIf nTipo == 6
         dInicio := CtoD("01/"+If(Month(dInicio)+6<=12,StrZero(Month(dInicio)+6,2)+;
                         "/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
      EndIf
   Next i
ElseIf nTipo == 7
   //Seleciona periodos variaveis se nao for visualizacao
   If !lVisualiza
      A107Diver()
   EndIf
   For i:=1 to Len(aDiversos)
      AADD(aPeriodos, StoD(DtoS(CtoD(aDiversos[i])),cForAno) )
   Next
Endif

//Ponto de entrada customizacoes na atualizacoes de periodos
If ExistBlock("A710PERI")
   aPeriodos := ExecBlock("A710PERI", .F., .F., aPeriodos )
EndIf

Return

/*------------------------------------------------------------------------//
//Programa: A107NextUtil
//Autor:    Marcelo Iuspa
//Data:     02/02/04
//Descricao:   Retorna proxima segunda se data for sab/dom e parametro
//            de considera sabado/domingo estiver como NAO
//Parametros:  dData     - Data a ser avaliada
//          aPergs711 - Array com as perguntas a serem consideradas
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107NextUtil(dData,aPergs711,lSoma)
Local dDataOld := dData
Local dDataNew := dData
Local lWeekend := aPergs711[12] == 1 //Considera Sab.Dom

Default lSoma := .T.

If !lWeekend .And. Dow(dData) == 7
   If lSoma
		dData += 2
	Else
		dData -= 1
	EndIf
ElseIf !lWeekend .And. Dow(dData) == 1
   If lSoma
		dData += 1
	Else
		dData -= 2
	EndIf
Endif

dDataNew := dData

// Ponto de entrada para alterar a data a ser considerada nos documentos.
If ExistBlock("A710DTUTIL")
   dData := ExecBlock("A710DTUTIL",.F.,.F.,{dData, lWeekend, dDataOld, .F.})
   If ValType(dData) != "D"
      dData := dDataNew
   EndIf
EndIf

Return(dData)

/*------------------------------------------------------------------------//
//Programa: A107Diver
//Autor:    Rodrigo A. Sartorio
//Data:     30/08/02
//Descricao:   Seleciona Periodos para opcao de apresentacao diversos
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107Diver()
Local nTamArray   := Len(aDiversos)
Local dInicio     := dDataBase
Local lConsSabDom := aPergs711[12] == 1
Local nI          := 0
Local nOpca    := 1
Local cVarQ       := "  "
Local cTitle      := OemToAnsi(STR0076)   //"Seleção de periodos Variaveis"
Local aBack    := {}
//Variaveis do tipo objeto
Local oQual,oDlg,oGet

//Verifica se ainda nao foi criado o Array com as datas, ou se o numero de dias foi
//alterado. Se nao foi criado sugere as datas com a opcao de diario
If Len(aDiversos) == 0 .Or. aOpcoes[2][1] != Len(aDiversos)
   If aOpcoes[2][1] > Len(aDiversos)
      If Len(aDiversos) == 0
         //O inicio do array e a database
         dInicio := STOD(DTOS(dDataBase),"ddmmyy")
      Else
         //Caso tenha sido aumentado o numero de dias ele mantem os dados que ja existiam e cria
         //os novos dias a partir da ultima data do array
         dInicio := cTod(aDiversos[Len(aDiversos)],"ddmmyy")
      EndIf
      For nI := 1 to (aOpcoes[2][1] - nTamArray)
         AADD(aDiversos,dToc(dInicio))
         dInicio ++
         While !lConsSabDom .And. ( DOW(dInicio) == 1 .or. DOW(dInicio) == 7 )
            dInicio++
         End
      Next
   Else
      //Caso tenha sido diminuido o numero de dias apaga os dias a mais (do fim para o comeco) e mantem os dados digitados
      For nI:=Len(aDiversos) to (aOpcoes[2][1]+1) Step -1
         aDel(aDiversos,nI)
         Asize(aDiversos,nTamArray-1)
         nTamArray:=Len(aDiversos)
      Next
   EndIf
EndIf

aBack := aClone(aDiversos)

//Monta a tela
DEFINE MSDIALOG oDlg TITLE cTitle From 145,70 To 350,400 OF oMainWnd PIXEL
@ 10,13 TO 80,152 LABEL "" OF oDlg  PIXEL
@ 20,18 LISTBOX oQual VAR cVarQ Fields HEADER OemToAnsi(STR0016) SIZE 65,55 NOSCROLL ON DBLCLICK oGet:SetFocus() OF oDlg PIXEL
@ 30,90 Say OemToAnsi(STR0077) SIZE 25,10 OF oDlg PIXEL
oQual:SetArray(aDiversos)
oQual:bLine := { || {aDiversos[oQual:nAt]} }
@ 40,90 MSGET oGet VAR aDiversos[oQual:nAt] Picture "99/99/99" + If(__SetCentury(),"99","") Valid A107VDiver(oQual:nAT,aDiversos[oQual:nAt],@oQual,@oGet) SIZE 40,10 OF oDlg PIXEL
DEFINE SBUTTON FROM 86,042 TYPE 1 ACTION (nOpca:=2,oDlg:End()) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 86,069 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
ACTIVATE MSDIALOG oDlg
If nOpca = 1
   aDiversos:={}
   aDiversos:=ACLONE(aBack)
EndIf

Return

/*------------------------------------------------------------------------//
//Programa: A107VDiver
//Autor:    Rodrigo A. Sartorio
//Data:     30/08/02
//Descricao:   Validacao da digitacao do periodo
//Parametros:  nOpt      = numero da linha que esta sendo editada
//          cDiversos = conteudo do array antes do get
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107VDiver(nOpt,cDiversos,oQual,oGet)
Local lRet           := .T.
Local lConsSabDom    := aPergs711[12] == 1
Local nI             := 0

//Nao permite que o usuario digite uma data que seja sabado ou domingo
If !lConsSabDom .And. DOW(cTod(aDiversos[nOpt])) == 1 .Or. DOW(cTod(aDiversos[nOpt])) == 7
   aDiversos[nOpt]:=cDiversos
   lRet := .F.
EndIf
//Nao permite que o usuario digite uma data menor ou igual a anterior,enviando um help e retornando ao valor anterior.
If nOpt != 1
   If cTod(aDiversos[nOpt]) <= cTod(aDiversos[nOpt - 1])
      aDiversos[nOpt]:=cDiversos
      lRet := .F.
   EndIf
EndIf
//Verifica se a data alterada é maior ou igual a proxima e refaz as datas a partir da data digitada ate o fim. So nao entra
//nesta opcao quando a data alterada for a ultima
If nOpt < Len(aDiversos)
   If cTod(aDiversos[nOpt + 1]) <= cTod(aDiversos[nOpt])
      dInicio:= StoD(DtoS(cTod(aDiversos[nOpt])),"ddmmyy")
      For nI:=nOpt+1 to Len(aDiversos)
         dInicio ++
         While !lConsSabDom .And. (DOW(dInicio) == 1 .or. DOW(dInicio) == 7)
            dInicio++
         End
         aDiversos[ni] := dToc(dInicio)
      Next
   EndIf
EndIf
If lRet
   oQual:SetArray(aDiversos)
   oQual:Refresh()
   oQual:SetFocus()
Else
   oGet:SetFocus()
   oGet:Refresh()
EndIf

Return lRet

/*------------------------------------------------------------------------//
//Programa: A107CriSOQ
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Cria registros no arquivo de detalhe do MRP
//Parametros:  01.dDataOri       - Data da necessidade do material
//             02.cProduto       - Produto
//             03.cOpc           - Opcional
//             04.cRevisao       - Revisao Estrutura
//             05.cAliasMov      - Alias do movimento
//             06.nRecno         - Registro
//             07.cDoc           - Documento
//             08.cItem          - Item do Documento
//             09.cDocKey        - Documento Chave para ligacao
//             10.nQuant         - Quantidade
//             11.cTipo711       - Indica o tipo de movimento nos arquivo SHA/SH5
//             12.lAddTree       - Adiciona registro no tree
//             13.lRevisao       - Indica se utiliza controle de revisoes
//             14.cAliasTop      - Alias do banco em SQL
//             15.lCalcula       - Indica se recalcula apos inclusao
//             16.lInJob         - Identifica que foi chamado por JOB
//             17.aParPeriodos   - Array com periodos (utilizado em job)
//             18.nParTipo       - Tipo de calculo (utilizado em job)
//             19.cPar711Num     - Numero do processamento do MRP
//             20.cStrTipo       - String com tipos a serem processados
//             21.cStrGrupo      - String com grupos a serem processados
//             22.nPrazoEnt      - Prazo de entrega
//             23.cProdOri       - Produto original (no caso de alternativos)
//             24.aOpc           - Array de opcionais
//             25.mOpc           - Array origem dos opcionais
//             26.cNivelEstr     - Nivel da estrutura
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107CriSOQ(dDataOri,cProduto,cOpc,cRevisao,cAliasMov,nRecno,cDoc,cItem,cDocKey,nQuant,cTipo711,lAddTree,lRevisao,cAliasTop,lCalcula,lInJob,aParPeriodos,nParTipo,cPar711Num,cStrTipo,cStrGrupo,nPrazoEnt,cProdOri,aOpc,mOpc,cNivelEstr,nRecOrig,aEmpresas,lSbz)

Local cRev711Vaz     := CriaVar("B1_REVATU",.F.)
Local i              := 0
Local nAchouTot      := 0
Local nRec           := 0
Local lGeraSOR       := .T.
Local cAliasEst      := ""
Local cAliasSB1		:= ''
Local nRecSOR        := 0
Local nRecSOQ        := 0
Local aAreaBkp       := {}
Local cPeriodo       := "" //A650DtoPer(dDataOri,aParPeriodos,nParTipo,cProduto,nQuant)
Local lMRPCINQ    := SuperGetMV("MV_MRPCINQ",.F.,.F.)
//Setando valores padrões
Default lRevisao     := .T.
Default lCalcula     := .F.
Default lInJob       := .F.
Default cAliasTop    := "SB1"
Default cStrTipo     := ""
Default cStrGrupo    := ""
Default cProdOri     := ""
Default cNivelEstr   := ""
Default cOpc         := ""
Default mOpc         := ""
Default nPrazoEnt    := 0
Default aOpc         := {}
Default nRecOrig     := -1
Default aEmpresas    := {}
Default lSbz         := .F.

IF cAliasMov != "PAR"

	cAliasSB1 := GetNextAlias()

	//if !lAllTp .OR. !lAllTp
		// Verificar se produto está no filtro de tipo e grupo - same
		cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName("SB1") + " SB1 " 
		cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = '" + cProduto + "' "
	
		//Filtra os tipos
		//If !lAllTp
			cQuery += " AND SB1.B1_TIPO IN (SELECT TP_TIPO FROM SOQTTP) "
		//EndIf
	
		//Filtro os grupos
		If /*!lAllGrp .And.*/ lMRPCINQ
			cQuery += " AND SB1.B1_GRUPO IN (SELECT GR_GRUPO FROM SOQTGR) "
		EndIf
	   
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
	   
		IF (cAliasSB1)->TOTAL == 0
			(cAliasSB1)->(dbCloseArea())
			
			Return
		Else
			(cAliasSB1)->(dbCloseArea())
		Endif
	   
		
	//Endif
Endif

If IsInCallStack("A107GERAOP") .And. cProduto == cProdTran .And. nDiaLtTran != 0
   cPeriodo := A650DtoPer(dDataOri+nDiaLtTran,aParPeriodos,nParTipo,cProduto,nQuant)
Else
   cPeriodo := A650DtoPer(dDataOri,aParPeriodos,nParTipo,cProduto,nQuant)
EndIf

//So soma no tree caso nao seja resumido
lAddTree := lAddTree .And. aPergs711[28]==2
If cDoc == RetTitle("B1_EMIN") .And. Len(aEmpresas) > 0
   cAliasEst := GetNextAlias()
   cQuery := " SELECT COUNT(*) TOTAL" +;
               " FROM OQPROD " +;
              " WHERE PROD = '" + cProduto + "'" +;
                " AND TIPO = 'PP'"
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEst,.T.,.T.)

   If (lSbz .Or. ((cAliasEst)->(TOTAL) == 0 .And. a107EstSeg(cProduto,aEmpresas,.F.)))
      nRec := buscaRec()
      cQuery := "INSERT INTO OQPROD (PROD, " +;
                                   " TIPO, " +;
                                   " EMPRESA, " +;
                                   " FILIAL, " +;
                                   " R_E_C_N_O_) " +;
                        " VALUES ('" + cProduto + "', " +;
                                " 'PP', " +;
                                " '" + cEmpAnt + "', " +;
                                " '" + cFilAnt + "', " +;
                                " '" + Str(nRec) + "')"
      TCSQLExec(cQuery)
      (cAliasEst)->(dbCloseArea())
   Else
   	(cAliasEst)->(dbCloseArea())
      Return
   EndIf
EndIf
//Considera numero do processamento do MRP passado como parametro
If ValType(cPar711Num) == "C"
   c711NumMRP := cPar711Num
EndIf

//Verificar se usa a revisão
If !A107TrataRev()
   cRevisao := Space(Len(SB1->B1_REVATU))
   lRevisao := .F.
Endif

//Verifica se o movimento esta dentro do periodo
If !Empty(cPeriodo)
   //Se o nivel não foi passado no parametro, busca da tabela SG1
   If Empty(cNivelEstr)
      SG1->(dbSetOrder(1))
      cNivelEstr := IIf(SG1->(dbSeek(xFilial("SG1")+cProduto)),SG1->G1_NIV,"99")
   EndIf

   If Len(aOpc) > 0 .And. Array2Str(aOpc,.F.) != Nil
      mOpc := Array2Str(aOpc,.F.)
   EndIf

   //Grava somente opcionais utilizados nesse produto, de acordo com a estrutura.
   If /*Empty(cOpc) .And.*/ !Empty(mOpc) .And. !Empty(cProduto)
      If Empty(cStrTipo) .And. Type('a711Tipo') == "A"
         For i := 1 To Len(a711Tipo)
            If a711Tipo[i,1]
               cStrTipo += SubStr(a711Tipo[i,2],1,nTamTipo711)+"|"
            EndIf
         Next i
      EndIf

      If Empty(cStrGrupo) .And. Type('a711Grupo') == "A"
         cStrGrupo := Criavar("B1_GRUPO",.f.)+"|"
         For i := 1 To Len(a711Grupo)
            If a711Grupo[i,1]
               cStrGrupo += SubStr(a711Grupo[i,2],1,nTamGr711)+"|"
            EndIf
         Next i
      EndIf

      cGrupos := A107EstOpc(cProduto,MontaOpc(mOpc),Nil,Nil,cStrTipo,cStrGrupo)
      cOpc := IIf(Empty(cGrupos),"",A107AvlOpc(MontaOpc(mOpc,cProduto,cNivelEstr),cGrupos))
   EndIf

   If cAliasMov != "PAR"
      aAreaBkp := GetArea()
      cAliasEst := "VERESTRUT"
      cQuery := " SELECT SOQ.R_E_C_N_O_ RECSOQ "
      cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ "
      cQuery +=  " WHERE SOQ.OQ_FILIAL = '" + xFilial("SOQ") + "' "
      cQuery +=    " AND SOQ.OQ_EMP    = '" + cEmpAnt + "' "
      cQuery +=    " AND SOQ.OQ_FILEMP = '" + cFilAnt + "' "
      //cQuery +=    " AND SOQ.OQ_DTOG   = '" + DtOs(SomaPrazo(dDataOri,-nPrazoEnt)) + "' "
      cQuery +=    " AND SOQ.OQ_DTOG   = '" + DtOs(IIF(cAliasMov = 'SOR',A107NextUtil(dDataOri,aPergs711,.F.),SomaPrazo(dDataOri,-nPrazoEnt))) + "' "
      cQuery +=    " AND SOQ.OQ_NRMRP  = '" + c711NumMRP + "' "
      cQuery +=    " AND SOQ.OQ_PROD   = '" + cProduto + "' "
      cQuery +=    " AND SOQ.OQ_NRRV   = '" + cRevisao + "' "
      cQuery +=    " AND SOQ.OQ_OPCORD = '" + cOpc + "' "
      cQuery +=    " AND SOQ.OQ_ALIAS  = '" + cAliasMov + "' "
      cQuery +=    " AND SOQ.OQ_DOC    = '" + cDoc + "' "
      If cAliasMov == "SHC"
         cQuery += " AND SOQ.OQ_NRRGAL = " + cValToChar(nRecno)
      EndIf
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEst,.T.,.T.)
      If !(cAliasEst)->(Eof())
         nRecSOQ := (cAliasEst)->(RECSOQ)
      Else
         nRecSOQ := 0
      EndIf
      (cAliasEst)->(dbCloseArea())
      RestArea(aAreaBkp)
   Else
      nRecSOQ := 0
   EndIf

   If nRecSOQ < 1
      //Adiciona registros na tabela de objetos
      dbSelectArea("SOQ")
      Reclock("SOQ",.T.)
      SOQ->OQ_FILIAL := xFilial("SOQ")
      SOQ->OQ_EMP    := cEmpAnt
      SOQ->OQ_FILEMP := cFilAnt
      //SOQ->OQ_DTOG   := SomaPrazo(dDataOri,-nPrazoEnt)
      SOQ->OQ_DTOG   := IIF(cAliasMov = 'SOR',A107NextUtil(dDataOri,aPergs711,.F.),SomaPrazo(dDataOri,-nPrazoEnt))
      SOQ->OQ_PERMRP := cPeriodo
      SOQ->OQ_PROD   := cProduto
      SOQ->OQ_ALIAS  := cAliasMov
      SOQ->OQ_DOC    := cDoc
      SOQ->OQ_DOCKEY := cDocKey
      SOQ->OQ_ITEM   := cItem
      SOQ->OQ_NRLV   := cNivelEstr
      SOQ->OQ_QUANT  := nQuant
      SOQ->OQ_TPRG   := cTipo711
      SOQ->OQ_NRMRP  := c711NumMRP
      If lRevisao
         SOQ->OQ_NRRV := cRevisao
      Else
         SOQ->OQ_DOCREV := cRevisao
      Endif
      SOQ->OQ_PRODOG := cProdOri
      SOQ->OQ_OPC    := mOpc
      SOQ->OQ_OPCORD := cOpc
      If nRecno == 0
         SOQ->OQ_NRRGAL := nRecZero
         nRecZero ++
      Else
         SOQ->OQ_NRRGAL := nRecno
      EndIf
      MsUnlock()
      nRecSOQ := SOQ->(Recno())
   Else
      SOQ->(dbGoTo(nRecSOQ))
      RecLock("SOQ",.F.)
         SOQ->OQ_QUANT += nQuant
      MsUnLock()
   EndIf
   If !Empty(cProduto) .And. !Empty(cTipo711)
      If !lInJob .And. lAddTree .And. !lBatch
         //Adiciona registro em array totalizador utilizado no TREE

         If Len(aTotais[Len(aTotais)]) > 4095
            AADD(aTotais,{})
         EndIf

         For i := 1 to Len(aTotais[1])
            if aTotais[1,i,1] == SOQ->OQ_PROD+SOQ->OQ_OPCORD+SOQ->OQ_NRRV .And. aTotais[1,i,2] == SOQ->OQ_PERMRP .And. aTotais[1,i,3] == SOQ->OQ_ALIAS
               nAchouTot := i
            Else
               nAchouTot := 0
               loop
            EndIf
            If nAchouTot != 0
               aTotais[1,nAchouTot,4] += SOQ->OQ_QUANT
               Exit
            EndIf
         Next i

         If nAchouTot == 0
            AADD(aTotais[Len(aTotais)],{SOQ->OQ_PROD + SOQ->OQ_OPCORD + SOQ->OQ_NRRV,SOQ->OQ_PERMRP,SOQ->OQ_ALIAS,SOQ->OQ_QUANT})
         EndIf
         A107AdTree(.F.,{{SOQ->OQ_PROD,SOQ->OQ_OPCORD,SOQ->OQ_NRRV,SOQ->OQ_ALIAS,SOQ->OQ_TPRG,SOQ->OQ_DOC,StrZero(SOQ->(Recno()),12),SOQ->OQ_DOCREV}},aPergs711[28]==1)
      EndIf
      //Cria registro na tabela SOR
      If Type("lAlteraOQ") == "L"
         If lAlteraOQ == .F.
            lGeraSOR := .F.
         EndIf
      EndIf
      If lGeraSOR
         nRecSOR := A107CriSOR(cProduto,cOpc,If(lRevisao,cRevisao, cRev711Vaz),cNivelEstr,cPeriodo,nQuant,cTipo711,cAliasTop,lCalcula,cStrTipo,cStrGrupo,.F.,mOpc,nRecOrig,/*nSaldoIni*/,/*16*/,nRecSOQ,/*18*/,aEmpresas)
         If nRecSOQ != 0 .And. cAliasMov == "SOR" .And. nRecSOR != 0
            SOQ->(dbGoTo(nRecSOQ))
            RecLock("SOQ",.F.)
               SOQ->OQ_NRRGAL := nRecSOR
            MsUnLock()
         EndIf
      EndIf
   EndIf
   If cAliasMov != "PAR" .And. Select(cAliasEst) > 0
      (cAliasEst)->(dbCloseArea())
   EndIf
EndIf

Return

/*------------------------------------------------------------------------//
//Programa: A107TrataRev
//Autor:    Marcelo Iuspa
//Data:     22/06/04
//Descricao:   Retorna se existe campos especificos para tratamento de
//          revisao na Previsao de Venda e Plano Mestre Producao
//          Campos: HC_REVISAO e C4_REVISAO
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107TrataRev()
Static lTrataRev := Nil

If lTrataRev == Nil
   If lA710REV
      lTrataRev := ExecBlock("A710REV",.F.,.F.)
      If ValType(lTrataRev) # "L"
         lTrataRev := .F.
      EndIf
   Else
      lTrataRev := .F.
   EndIf
Endif

Return(lTrataRev)

/*------------------------------------------------------------------------//
//Programa: A107CriSOR
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Cria registros no arquivo de totais do MRP
//Parametros:  01.cProduto       - Produto
//             02.cOpc           - Opcional
//             03.cRevisao       - Revisao Estrutura
//             04.cNivelEstr     - Nivel do produto
//             05.cPeriodo       - Periodo
//             06.nQuant         - Quantidade
//             07.cTipo711       - 1-Sld Inicial 2-Entrada 3-Saida 5-Saida Relacionada
//             08.cAliasTop      - Alias do banco em SQL
//             09.lCalcula       - Indica se recalcula apos inclusao
//             10.cStrTipo       - String com tipos a serem processados
//             11.cStrGrupo      - String com grupos a serem processados
//             12.lVerRev        - Indica se refaz a verificação da revisão
//             13.mOpc           - Memo de opcionais
//             14.nRecOrig       - RECNO da tabela SOT que originou a necessidade de produção.
//             15.nSaldoIni      - Saldo inicial do produto
//             16.nRecSOQ        - RECNO da tabela SOQ
//             17.nQtTrans       - Quantidade de transferência a ser considerada.
//Observacao:  Tipos de Registro
//                1 Saldo Inicial
//                2 Entrada
//                3 Saida
//                4 Saida pela Estrutura
//                5 Saldo
//                6 Necessidade
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107CriSOR(cProduto,cOpc,cRevisao,cNivelEstr,cPeriodo,nQuant,cTipo711,cAliasTop,lCalcula,cStrTipo,cStrGrupo,lVerRev,mOpc,nRecOrig,nSaldoIni,nRecSOQ,nQtTrans,lAltSEst,aEmpresas)
Local cGrupos        := ""
Local cSeek          := ""
Local nRecSOR        := 0
Local lExiste        := .F.
Local nRecSOT        := 0
Local nQtProd        := 0
Local nPontoPed      := 0
Local nQtdPP         := 0
Local nEstSeg        := 0
Local nSaldoAtu      := 0
Local nQtdSaldo      := 0
Local cQuery         := ''
Local cAliasSB1      := GetNextAlias()
Local lMRPCINQ    := SuperGetMV("MV_MRPCINQ",.F.,.F.)

//Seta valores padrões para os argumentos
DEFAULT cPeriodo     := "001"
DEFAULT cNivelEstr   := ""
DEFAULT cTipo711     := ""
DEFAULT cAliasTop    := "SB1"
DEFAULT cStrTipo     := ""
DEFAULT cStrGrupo    := ""
DEFAULT cOpc         := ""
DEFAULT mOpc         := ""
DEFAULT lCalcula     := .F.
DEFAULT lVerRev      := .T.
DEFAULT nRecOrig     := -1
DEFAULT nSaldoIni    := Nil
DEFAULT nRecSOQ      := 0
DEFAULT nQtTrans     := 0
DEFAULT lAltSEst       := .F.

If lVerRev
   If !A107TrataRev()
      cRevisao := Space(Len(SB1->B1_REVATU))
   Endif
EndIf

//if !lAllTp .OR. !lAllTp
	// Verificar se produto está no filtro de tipo e grupo - same
	cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName("SB1") + " SB1 " 
	cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = '" + cProduto + "' "

	//Filtra os tipos
	//If !lAllTp
		cQuery += " AND SB1.B1_TIPO IN (SELECT TP_TIPO FROM SOQTTP) "
	//EndIf

	//Filtro os grupos
	If /*!lAllGrp .And.*/ lMRPCINQ
		cQuery += " AND SB1.B1_GRUPO IN (SELECT GR_GRUPO FROM SOQTGR) "
	EndIf
   
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
   
	IF (cAliasSB1)->TOTAL == 0
		(cAliasSB1)->(dbCloseArea())
	
		Return
	Else
		(cAliasSB1)->(dbCloseArea())
	Endif
//Endif

//Se o nivel não foi passado no parametro, busca da tabela SG1
If Empty(cNivelEstr)
   SG1->(dbSetOrder(1))
   cNivelEstr := IIf (SG1->(dbSeek(xFilial("SG1")+cProduto)),SG1->G1_NIV,"99")
EndIf

If /*Empty(cOpc) .And. */ !Empty(mOpc) .And. !Empty(cProduto)
   cGrupos := A107EstOpc(cProduto,MontaOpc(mOpc),Nil,Nil,cStrTipo,cStrGrupo)
   cOpc := IIf(Empty(cGrupos),"",A107AvlOpc(MontaOpc(mOpc,cProduto,cNivelEstr),cGrupos))
EndIf


//Se não existir registro para o primeiro tipo, não vai existir para o restante, então não precisa verificar novamente
//Caso exista, é necessário verificar para pegar o R_E_C_N_O_ da SOR
lExiste := PCPA107EOR(cProduto,cOpc,cRevisao)

//Inclui registros caso necessario
If !lExiste
   //Insere na SOR
   dbSelectArea("SOR")
   Reclock("SOR",.T.)
   SOR->OR_FILIAL := xFilial("OR")
   SOR->OR_EMP    := cEmpAnt
   SOR->OR_FILEMP := cFilAnt
   SOR->OR_PROD   := cProduto
   SOR->OR_OPC    := cOpc
   SOR->OR_NRRV   := cRevisao
   SOR->OR_NRLV   := cNivelEstr
   SOR->OR_NRMRP  := c711NumMRP
   SOR->OR_MOPC   := mOpc
   SOR->OR_OPCORD := cOpc
   MsUnlock()
   nRecSOR := SOR->(RecNo())
   SOR->(dbCloseArea())

   //Insere na SOT
   dbSelectArea("SOT")
   Reclock("SOT",.T.)
   SOT->OT_FILIAL  := xFilial("SOT")
   SOT->OT_NRMRP   := c711NumMRP
   SOT->OT_RGSOR   := nRecSOR
   SOT->OT_PERMRP  := cPeriodo
   SOT->OT_QTSLES  := IIf(cTipo711 == '1',nQuant,0)
   SOT->OT_QTENTR  := IIf(cTipo711 == '2',nQuant,0)
   SOT->OT_QTSAID  := IIf(cTipo711 == '3',nQuant,0)
   SOT->OT_QTSEST  := IIf(cTipo711 == '4',nQuant,0)
   SOT->OT_QTSALD  := IIf(cTipo711 == '5',nQuant,0)
   SOT->OT_QTNECE  := IIf(cTipo711 == '6',nQuant,0)

   If nRecOrig > -1
      SOT->OT_QTTRAN := Iif(nQtTrans <> 0, nQtTrans, (nQuant * -1) )
   Else
      SOT->OT_QTTRAN := 0
   EndIf
   If cTipo711 == '7'
      SOT->OT_QTTRAN := nQuant
   EndIf
   MsUnlock()
   If cTipo711 == '7'
      a107CriSOV(SOT->(Recno()),nQuant,cProduto,"S")
   EndIf
   nRecSOT := SOT->(RecNo())
   SOT->(dbCloseArea())
   nQtdSaldo := 0
Else
   dbSelectArea("SOT")
   SOT->(dbSetOrder(1))
   nRecSOR := (cAliasSOR)->(SORREC)
   cSeek := xFilial("SOT")+STR((cAliasSOR)->(SORREC),10,0)+cPeriodo
   If SOT->(dbSeek(cSeek))
      nRecSOT := SOT->(RecNo())
      If lVerSldSOR
         SOT->(dbGoTo(nRecSOT))
         nQtdSaldo := SOT->OT_QTSLES + SOT->OT_QTENTR
         nQtdSaldo -= SOT->OT_QTSEST
         nQtdSaldo -= SOT->OT_QTSAID
         If aPergs711[31] == 1
            If verPontPed(cProduto)
               SB1->(MsSeek(xFilial("SB1") + cProduto))
               nPontoPed := RetFldProd(SB1->B1_COD,"B1_EMIN")
               If !Empty(nPontoPed)
                  nQtdPP := nPontoPed + 1
                  nQtdSaldo := nQtdSaldo - nQtdPP
               EndIf
            Else
               nQtdPP    := 0
               nPontoPed := 0
            EndIf
         EndIf
         If aPergs711[26] == 3
            nEstSeg := buscaEstSeg(cProduto,aEmpresas)
            nQtdSaldo := nQtdSaldo - nEstSeg
         EndIf

         If nQtdSaldo < 0
            nQtdSaldo := 0
         EndIf
      Else
         nQtdSaldo := 0
      EndIf
      Reclock("SOT",.F.)
      Do Case
         Case cTipo711 == '1'
            SOT->OT_QTSLES += nQuant
         Case cTipo711 == '2'
            SOT->OT_QTENTR += nQuant
         Case cTipo711 == '3'
            SOT->OT_QTSAID += nQuant
         Case cTipo711 == '4'
            SOT->OT_QTSEST += nQuant
         Case cTipo711 == '5'
            SOT->OT_QTSALD += nQuant
         Case cTipo711 == '6'
            SOT->OT_QTNECE += nQuant
         Case cTipo711 == '7'
            SOT->OT_QTTRAN += nQuant
      EndCase
      If nRecOrig > -1
         SOT->OT_QTTRAN += Iif(nQtTrans <> 0, nQtTrans, (nQuant * -1) )
      EndIf
      MsUnlock()
      If cTipo711 == '7'
         a107CriSOV(SOT->(Recno()),nQuant,cProduto,"S")
      EndIf
      If Type("lAtuNec") == "L" .And. lAtuNec
         atuNeces(SOT->(Recno()),nQuant,"N")
      EndIf
      (cAliasSOT)->(dbCloseArea())
   Else
      Reclock("SOT",.T.)
      SOT->OT_FILIAL  := xFilial("SOT")
      SOT->OT_NRMRP   := c711NumMRP
      SOT->OT_RGSOR   := (cAliasSOR)->(SORREC)
      SOT->OT_PERMRP  := cPeriodo
      SOT->OT_QTSLES  := IIf(cTipo711 == '1',nQuant,0)
      SOT->OT_QTENTR  := IIf(cTipo711 == '2',nQuant,0)
      SOT->OT_QTSAID  := IIf(cTipo711 == '3',nQuant,0)
      SOT->OT_QTSEST  := IIf(cTipo711 == '4',nQuant,0)
      SOT->OT_QTSALD  := IIf(cTipo711 == '5',nQuant,0)
      SOT->OT_QTNECE  := IIf(cTipo711 == '6',nQuant,0)

      If nRecOrig > -1
         SOT->OT_QTTRAN := Iif(nQtTrans <> 0, nQtTrans, (nQuant * -1) )
      Else
         SOT->OT_QTTRAN := 0
      EndIf
      If cTipo711 == '7'
         SOT->OT_QTTRAN := nQuant
      EndIf
      MsUnlock()
      nRecSOT := SOT->(RecNo())
      If cTipo711 == '7'
         a107CriSOV(nRecSOT,nQuant,cProduto,"S")
      EndIf
      SOT->(dbCloseArea())
      nQtdSaldo := 0
   EndIf
EndIf

If nRecOrig > -1
   insertSOS(nRecSOT, nRecOrig, Iif(nQtTrans <> 0, nQtTrans, nQuant), "2")
   //insertSOS(nRecSOT, nRecOrig, nQuant, "1")
EndIf

If lAltSEst
   SOT->(dbGoTo(nRecSOT))
   RecLock("SOT",.F.)
      SOT->OT_QTSEST := SOT->OT_QTSEST - nQuant
   MsUnLock()
EndIf

If lCalcula
   If nSaldoIni == Nil
      SOT->(dbGoTo(nRecSOT))
      nSaldoIni := SOT->(OT_QTSLES)
   EndIf
   A107Recalc(cProduto,cOpc,cRevisao,cPeriodo,nSaldoIni,/*06*/,nRecSOR,/*08*/,aEmpresas)
EndIf

If cTipo711 == '3' .Or. cTipo711 == '4' .Or. cTipo711 == '6' .Or. (cTipo711 == '1' .And. nQuant < 0 .And. IsInCallStack('A107JobIni'))
   SOT->(dbGoTo(nRecSOT))
   If SOT->OT_QTSALD <> 0
      If cTipo711 == '1'
         nQtProd   := SOT->OT_QTNECE
         nSaldoAtu := 0
      Else
         nQtProd := nQuant-nQtdSaldo
         nSaldoAtu := SOT->OT_QTSALD
      EndIf
      
      If nUsado != 1
         If SOT->OT_QTTRAN < 0
            nQtProd := A107Lote(nQtProd,cProduto)
         Else
            nQtProd := A711Lote(nQtProd,cProduto)
         EndIf
         nQtProd := A711NecMax(cProduto, nSaldoAtu, nQtProd)
      EndIf
   Else
      If SOT->OT_QTSALD == 0 .And. SOT->OT_QTNECE > 0 .And. aPergs711[26] == 3 .And. buscaEstSeg(cProduto,aEmpresas) == SOT->OT_QTNECE
         nQtProd := nQuant-nQtdSaldo
      Else
         nQtProd := 0
      EndIf
   EndIf
   a107CriSOV(nRecSOT,nQtProd,cProduto,"N")
EndIf

If Select(cAliasSOR) > 0
	(cAliasSOR)->(dbCloseArea())
EndIf

Return nRecSOR

/*------------------------------------------------------------------------//
//Programa: atuNeces
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Cria registros no arquivo de totais do MRP
//Parametros:  01.nRec       - Registro SOT
//             02.nQtd       - Quantidade
//             03.cTrans     - Indicador transferência
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function atuNeces(nRec,nQtd,cTrans)
Local cQuery  := ""
Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local nRecNec := 0
Local nQtdNec := 0

If Type("nRecSov") == "N" .And. nRecSov != 0 .And. nSotBkp == nRec
   nRecNec := nRecSov
Else
   If cTrans $ 'NE'
      cQuery := " SELECT SOV.R_E_C_N_O_ RECSOV, "
      cQuery +=        " SOV.OV_QUANT "
      cQuery +=   " FROM " + RetSqlName("SOV") + " SOV "
      cQuery +=  " WHERE SOV.OV_RECSOT = " + Str(nRec)
      cQuery +=    " AND SOV.OV_TRANS  = '" + cTrans + "' "
      cQuery +=    " AND SOV.OV_QUANT  = " + Str(nQtd)
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

      If !(cAlias)->(Eof())
         nRecNec := (cAlias)->(RECSOV)
         nQtdNec := (cAlias)->(OV_QUANT)
         nQtdNec -= nQtd
      Else
         (cAlias)->(dbCloseArea())
         cAlias := GetNextAlias()
         cQuery := " SELECT SOV.R_E_C_N_O_ RECSOV, "
         cQuery +=        " SOV.OV_QUANT "
         cQuery +=   " FROM " + RetSqlName("SOV") + " SOV "
         cQuery +=  " WHERE SOV.OV_RECSOT = " + Str(nRec)
         cQuery +=    " AND SOV.OV_TRANS  = '" + cTrans + "' "
         cQuery +=  " ORDER BY SOV.OV_QUANT "
         cQuery := ChangeQuery(cQuery)
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
         If !(cAlias)->(Eof())
            nRecNec := (cAlias)->(RECSOV)
            nQtdNec := (cAlias)->(OV_QUANT)
            nQtdNec -= nQtd
         EndIf
      EndIf
      (cAlias)->(dbCloseArea())
   Else
      SOV->(dbGoTo(nRec))
      nRecNec := nRec
      nQtdNec := SOV->(OV_QUANT)
      nQtdNec -= nQtd
   EndIf
EndIf
If nRecNec > 0
   If nQtdNec <= 0
      cQuery := " DELETE FROM " + RetSqlName("SOV")
      cQuery +=  " WHERE R_E_C_N_O_ = " + Str(nRecNec)
      nRet := TCSQLExec(cQuery)
   Else
      cQuery := " UPDATE " + RetSqlName("SOV")
      cQuery +=    " SET OV_QUANT   = " + Str(nQtdNec)
      cQuery +=  " WHERE R_E_C_N_O_ = " + Str(nRecNec)
      nRet := TCSQLExec(cQuery)
   EndIf
EndIf

RestArea(aArea)
Return

/*------------------------------------------------------------------------//
//Programa: a107CriSOV
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Insere registro na tabela SOV - necessidades
//Parametros:  1. nRecSOT  - Recno da tabela SOT
//             2. nQtProd  - Quantidade da necessidade
//             3. cProduto - Código do produto
//             4. cTrans   - Indicador de transferência entre empresas/filiais
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function a107CriSOV(nRecSOT,nQtProd,cProduto,cTrans)
Local cQuery := ""
Local aArea  := GetArea()
Local cAlias := GetNextAlias()
Local nSeq   := 0
Local aRet   := {}
Local lGera  := .T.

If cTrans == "N"
   aRet := verItProd(cProduto)

   If aRet[1] != Nil .And. aRet[2] != Nil
      If AllTrim(aRet[1]) != AllTrim(cEmpAnt) .Or. AllTrim(aRet[2]) != AllTrim(cFilAnt)
         lGera := .F.
      EndIf
   EndIf
EndIf

If lGera .And. nQtProd > 0
   //Realiza o lockByName para não dar conflito de sequência quando estiver sendo
   //executado em Job.
   If LockByName("INSERTSOV",.F.,.F.)
	   cQuery := " SELECT MAX(SOV.OV_SEQ) SEQSOV "
	   cQuery +=   " FROM " + RetSqlName("SOV") + " SOV "
	   cQuery := ChangeQuery(cQuery)
	   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	   nSeq := (cAlias)->(SEQSOV)
	   nSeq++
	   (cAlias)->(dbCloseArea())
	
	   RecLock("SOV",.T.)
	     SOV->OV_FILIAL := xFilial("SOV")
	     SOV->OV_RECSOT := nRecSOT
	     SOV->OV_QUANT  := nQtProd
	     SOV->OV_TRANS  := cTrans
	     SOV->OV_SEQ    := nSeq
	   MsUnLock()
	   UnLockByName("INSERTSOV",.F.,.F.)
	EndIf
EndIf
RestArea(aArea)
Return

/*------------------------------------------------------------------------//
//Programa: PCPA107EOR
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Retorna se já existe o registro na SOR
//Parametros:  1. cProduto - Código do produto
//             2. cOpc     - Memo de opcionais
//             3. cRevisao - Revisão da estrutura
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PCPA107EOR(cProduto,cOpc,cRevisao)
Local lRet  := .F.
Local cSql  := ""
Local aArea := GetArea()

If Len(cOpc) > 200
   cOpc := Substr(cOpc,1,200)
EndIf

cAliasSOR := "EXISTESOR"
cSql := " SELECT SOR.R_E_C_N_O_ SORREC"
cSql +=   " FROM " + RetSqlName("SOR") + " SOR "
cSql +=  " WHERE OR_FILIAL  = '" + xFilial("SOR") + "' "
cSql +=    " AND OR_EMP     = '" + cEmpAnt + "'"
cSql +=    " AND OR_FILEMP  = '" + cFilAnt + "'"
cSql +=    " AND D_E_L_E_T_ = ' ' "
If !Empty(cProduto)
   cSql += " AND OR_PROD = '" + cProduto + "' "
EndIf
If !Empty(cOpc)
   cSql += " AND OR_OPCORD = '" + cOpc + "' "
EndIf
If !Empty(cRevisao)
   cSql += " AND OR_NRRV = '" + cRevisao + "' "
EndIf

cSql := ChangeQuery(cSql)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSOR,.T.,.T.)

lRet := IIf((cAliasSOR)->(Eof()),.F., .T.)
RestArea(aArea)

/*
	Não fazer o dbCloseArea da área cAliasSOR nesta função. o DbCloseArea é executado na função A107CriSOR.
*/

Return lRet

Static Function criaItProd()
   Local aProduto := {}
   Local nTamFil    := TamSX3("OQ_FILEMP")[1]

   AADD(aProduto,{"COD"    ,"C",TamSX3("B1_COD")[1],0})
   AADD(aProduto,{"EMPRESA","C",Len(cEmpAnt),0})
   AADD(aProduto,{"FILIAL" ,"C",nTamFil,0})

   lOk := TCDelFile("ITPROD")

   DbCreate("ITPROD",aProduto,"TOPCONN")
Return Nil

/*------------------------------------------------------------------------//
//Programa: PCPA107TMP
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Cria as tabelas para controle de grupos e tipos de produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PCPA107TMP()
Local lOk        := .T.
Local aTipo      := {}
Local aGrupo     := {}
Local aLocal     := {}
Local aTransf    := {}
Local aProd      := {}
Local aProduto   := {}
Local aSldMrp    := {}
Local aSOSBkp    := {}
Local aRecProcOT := {}
Local aRecProcOQ := {} 
Local nTamFil    := TamSX3("OQ_FILEMP")[1]
Local aTamQuant  := TamSX3("OT_QTSALD")

AADD(aTipo,{"TP_TIPO","C",02,0})

AADD(aGrupo,{"GR_GRUPO","C",TamSX3("BM_GRUPO")[1],0})

//AADD(aLocal,{"NR_LOCAL","C",02,0})
cTipLoc  := TamSx3('NNR_CODIGO')[1]
cTAMEMP  := LEN(cEmpAnt)

AADD(aLocal,{"NR_LOCAL","C",cTipLoc,0})
AADD(aLocal,{"NR_EMP","C",cTAMEMP,0})
AADD(aLocal,{"NR_FILIAL","C",FWSizeFilial(),0})

AADD(aTransf,{"RECNO","N",10,0})

AADD(aRecProcOT,{"RECNO","N",10,0})
AADD(aRecProcOQ,{"RECNO","N",10,0})

AADD(aProd,{"PROD"   ,"C",TamSX3("B1_COD")[1],0})
AADD(aProd,{"TIPO"   ,"C",2,0}) //PP - Ponto Pedido, ES - Estoque segurança
AADD(aProd,{"EMPRESA","C",Len(cEmpAnt),0})
AADD(aProd,{"FILIAL" ,"C",nTamFil,0})

//AADD(aProduto,{"COD"    ,"C",TamSX3("B1_COD")[1],0})
//AADD(aProduto,{"EMPRESA","C",Len(cEmpAnt),0})
//AADD(aProduto,{"FILIAL" ,"C",nTamFil,0})

AADD(aSldMrp,{"PROD"    ,"C",TamSX3("B1_COD")[1],0})
AADD(aSldMrp,{"PERMRP"  ,"C",3,0})
AADD(aSldMrp,{"QUANT"   ,"N",aTamQuant[1],aTamQuant[2]})
AADD(aSldMrp,{"EMPORIG" ,"C",Len(cEmpAnt),0})
AADD(aSldMrp,{"FILORIG" ,"C",nTamFil,0})

AADD(aSOSBkp,{"FILIAL" ,"C",nTamFil,0})
AADD(aSOSBkp,{"SOTORIG","N",10,0})
AADD(aSOSBkp,{"SOTDEST","N",10,0})
AADD(aSOSBkp,{"QUANT"  ,"N",aTamQuant[1],aTamQuant[2]})
AADD(aSOSBkp,{"TIPO"   ,"C",1,0})

lOk := TCDelFile("SOQTTP")
lOk := TCDelFile("SOQTGR")
lOk := TCDelFile("SOQNNR")
lOk := TCDelFile("OQPROD")
//lOk := TCDelFile("ITPROD")
lOk := TCDelFile("SLDMRP")
lOk := TCDelFile("SOSBKP")
lOk := TCDelFile("SOSBKP2")

lOk := TCDelFile("PROCOT")
lOk := TCDelFile("PROCOQ")

DbCreate("SOQTTP",aTipo,"TOPCONN")
DbCreate("SOQTGR",aGrupo,"TOPCONN")
DbCreate("SOQNNR",aLocal,"TOPCONN")
DbCreate("OQPROD",aProd,"TOPCONN")
//DbCreate("ITPROD",aProduto,"TOPCONN")
DbCreate("SLDMRP",aSldMrp,"TOPCONN")
DbCreate("SOSBKP",aSOSBkp,"TOPCONN")
DbCreate("SOSBKP2",aSOSBkp,"TOPCONN")

DbCreate("PROCOT",aRecProcOT,"TOPCONN")
DbCreate("PROCOQ",aRecProcOQ,"TOPCONN")

Return

/*------------------------------------------------------------------------//
//Programa: A107DSaldo
//Autor:    Ricardo Prandi
//Data:     20/09/2013
//Descricao:   Detalhamento do Saldo em Estoque do MRP
//Parametros:  01.cProduto       - Produto
//             02.nSaldo         - Variavel que retornara por passagem de parametro o saldo em estoque do produto
//             03.aFilAlmox      - Variavel de controle para customizacao
//             04.lViewDetalhe   - Permite visualizar gera detalhamento do saldo
//             05.aViewB2        - Array com detalhamento dos saldos por local
//             06.nEstSeg        - Variavel que retornara por passagem de parametro o estoque de segurança do produto
//             07.cAliasSB1      - Alias da tabela SB1
//             08.aEmpresas      - Array com as empresas de execução do MRP
//             09.lSeguranca     - Indicador para considerar ou não o estoque de segurança
//             10.lSbz           - Indica se está utilizando a tabela SBZ para este registro (A107PPEstS).
//Retorno:     Array com os saldos do produto aglutinados por armazem
//                [1] Saldo Disponivel
//                [2] QTD NOSSO EM TERCEIROS
//                [3] QTD TECEIROS EM NOSSO PODER
//                [4] SALDO REJEITADO PELO CQ
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107DSaldo(cProduto,nSaldo,aFilAlmox,lViewDetalhe,aViewB2,nEstSeg,cAliasSB1,aEmpresas,lSeguranca,lSbz)
Local nSldLocPos  := 0
Local nSldNs3     := 0
Local nSld3Ns     := 0
Local nSldRejCQ   := 0
Local nSldSDD     := 0
Local nSldPE      := 0
Local nSldGeral   := 0
Local nInd        := 0
Local nRec        := 0
Local cQuery      := ""
Local cAliasEst   := ""
Local aRetSldTot  := {0,0,0,0,0}     //Retorno dos saldos totalizados quando eh visualizado os detalhes
Local lEstSeg     := aPergs711[26] == 1
Local aAreaSB1    := SB1->(GetArea())

Default nSaldo       := 0
Default aFilAlmox    := Nil
Default lViewDetalhe := .F.
Default aViewB2      := {}
Default cAliasSB1    := "SB1"
Default aEmpresas    := aClone(aEmpCent)
Default lSeguranca   := .T.
Default lSbz         := .F.

//Calcula estoque de segurança
If lEstSeg .And. lSeguranca
   cAliasEst := GetNextAlias()
   cQuery := " SELECT COUNT(*) TOTAL" +;
               " FROM OQPROD " +;
              " WHERE PROD = '" + cProduto + "'" +;
                " AND TIPO = 'ES'"
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEst,.T.,.T.)

   If (lSbz .Or. ((cAliasEst)->(TOTAL) == 0 .And. a107EstSeg(cProduto,aEmpresas,.F.)))
      SB1->(MsSeek(xFilial("SB1")+cProduto))
      nEstSeg := CalcEstSeg(RetFldProd(cProduto,"B1_ESTFOR"))

      If nEstSeg > 0 .And. !A107VLOPC(cProduto, "", {}, "", "", , ,.F. , 1 )
         nEstSeg := 0
      EndIf

      nSldGeral := a107SldSum(cProduto, "001",.T.)
      If nSldGeral < nEstSeg
         nSaldo  -= nEstSeg
         nRec := buscaRec()
         cQuery := "INSERT INTO OQPROD (PROD, " +;
                                      " TIPO, " +;
                                      " EMPRESA, " +;
                                      " FILIAL, " +;
                                      " R_E_C_N_O_) " +;
                           " VALUES ('" + cProduto + "', " +;
                                   " 'ES', " +;
                                   " '" + cEmpAnt + "', " +;
                                   " '" + cFilAnt + "', " +;
                                   " '" + Str(nRec) + "')"
         TCSQLExec(cQuery)
      EndIf
   EndIf
   (cAliasEst)->(dbCloseArea())
EndIf

nSldNs3 := 0
nSld3Ns := 0

cAliasEst := "VEREST"
cQuery := " SELECT SB2.B2_FILIAL, " +;
                 " SB2.B2_COD, " +;
                 " SB2.B2_LOCAL, " +;
                 " SB2.B2_QATU, " +;
                 " SB2.B2_QNPT, " +;
                 " SB2.B2_QTNP " +;
            " FROM " + RetSqlName("SB2") + " SB2 " +;
           " WHERE SB2.B2_FILIAL = '" + xFilial("SB2") + "' " +;
             " AND SB2.B2_COD    = '" + cProduto + "' " +;
             " AND SB2.B2_LOCAL >= '" + cAlmoxd + "' " +;
             " AND SB2.B2_LOCAL <= '" + cAlmoxa + "' " +;
             " AND D_E_L_E_T_    = ' ' "

If aAlmoxNNR # Nil
   cQuery += " AND SB2.B2_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR 
   cQuery += " WHERE  NR_EMP = '"+cEmpAnt +"'" 
   cQuery += " AND  NR_FILIAL = '"+cFILAnt +"'" 
   cQuery += " ) "
EndIf

If aFilAlmox # Nil
   cQuery += " AND SB2.B2_LOCAL IN ('"+Criavar("B2_LOCAL",.F.)+"' "
   For nInd := 1 to Len(aFilAlmox)
      cQuery += ",'"+aFilAlmox[nInd]+"' "
   Next nInd
   cQuery += ") "
EndIf

cQuery += " ORDER BY B2_FILIAL, "
cQuery +=          " B2_COD, "
cQuery +=          " B2_LOCAL "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEst,.F.,.F.)

While !(cAliasEst)->(Eof())
   If cMT710B2 # Nil .And. !&(cMT710B2) .And. cMT710B2 # ""
        dbSkip()
        Loop
   Endif


   nSldLocPos  := 0
   nSldLocPos  := If(aPergs711[18]==1,(cAliasEst)->B2_QATU,CalcEst((cAliasEst)->B2_COD,(cAliasEst)->B2_LOCAL,aPeriodos[1]+1)[1]) - A107LotVnc(cProduto,aPeriodos[1],(cAliasEst)->B2_LOCAL)
   nSaldo      += nSldLocPos
   If lViewDetalhe
      aAdd(aViewB2,{TransForm((cAliasEst)->B2_LOCAL,cPictB2Local),; //[1] LOCAL
                  TransForm(nSldLocPos,cPictB2Qatu),;               //[2] SALDO ATUAL OU POR MOVIMENTO
                  "-",;                                             //[3] QTD NOSSO EM TERCEIROS
                  "-",;                                             //[4] QTD TECEIROS EM NOSSO PODER
                  "-",;                                             //[5] SALDO REJEITADO PELO CQ
                  "-",;                                             //[6] SALDO BLOQUEADO POR LOTE
                  NIL})                                             //[7] SALDO A SER CONSIDERADO
   EndIf

   //Considera quantidade nossa em poder de terceiro
   If aPergs711[18] == 1 .And. aPergs711[20] == 1
      nSaldo += (cAliasEst)->B2_QNPT
      If lViewDetalhe
         nSldLocPos     += (cAliasEst)->B2_QNPT
         aRetSldTot[2] += (cAliasEst)->B2_QNPT
         aViewB2[Len(aViewB2),3] := TransForm((cAliasEst)->B2_QNPT,cPictB2QNPT)
      EndIf
   EndIf

   //Considera quantidade de terceiro em nosso poder
   If aPergs711[18] == 1 .And. aPergs711[21] == 1
      nSaldo -= (cAliasEst)->B2_QTNP
      If lViewDetalhe
         nSldLocPos  -= (cAliasEst)->B2_QTNP
         aRetSldTot[3] += (cAliasEst)->B2_QTNP
         aViewB2[Len(aViewB2),4] := TransForm((cAliasEst)->B2_QTNP,cPictB2QTNP)
      EndIf
   EndIf

   //Saldo em CQ
   If aPergs711[22] == 1
      nSldRejCQ   := A107QtdCQ((cAliasEst)->B2_COD, (cAliasEst)->B2_LOCAL, aPeriodos[1]+1)
      nSaldo       -= nSldRejCQ
      If lViewDetalhe
         nSldLocPos     -= nSldRejCQ
         aRetSldTot[4] += nSldRejCQ
         aViewB2[Len(aViewB2),5] := TransForm(nSldRejCQ,cPictD7QTDE)
      EndIf
   Endif

   //Saldo bloqueado
   If aPergs711[25] == 1
      nSldSDD := A107QtdDD((cAliasEst)->B2_COD, (cAliasEst)->B2_LOCAL)
      nSaldo  -= nSldSDD
      If lViewDetalhe
         nSldLocPos     -= nSldSDD
         aRetSldTot[5] += nSldSDD
         aViewB2[Len(aViewB2),6] := TransForm(nSldSDD,cPictDDSaldo)
      EndIf
   Endif

   //Calcula o saldo se MV_PAR18 = 2 e se teve algum filtro de locais.
   If (aFilAlmox # Nil .Or. cMT710B2 # Nil .Or. aAlmoxNNR # Nil) .And. aPergs711[18] == 2
      If Empty(aViewB2)
         aAdd(aViewB2,{"*",TransForm(nSaldo,cPictB2Qatu),"-",TransForm(nSld3Ns,cPictB2QTNP),"-","-",TransForm(nSaldo,cPictB2Qatu)})
      Else
         aViewB2[Len(aViewB2),1] := "*"
      EndIf

      //Considera quantidade nossa em poder de terceiro
      If aPergs711[20] == 1
         nSldNs3 := SaldoTerc((cAliasEst)->B2_COD, (cAliasEst)->B2_LOCAL, "T", aPeriodos[1]+1, (cAliasEst)->B2_LOCAL)[1]
         nSaldo    += nSldNs3
         If lViewDetalhe
            nSldLocPos  += nSldNs3
            aRetSldTot[2] += nSldNs3
            aViewB2[Len(aViewB2),3] := TransForm(nSldNs3,cPictB2QNPT)
         EndIf
      Endif

      //Considera quantidade de terceiro em nosso poder
      If aPergs711[21] == 1
         nSld3Ns := SaldoTerc((cAliasEst)->B2_COD, (cAliasEst)->B2_LOCAL, "D", aPeriodos[1]+1, (cAliasEst)->B2_LOCAL)[1]
         nSaldo    -= nSld3Ns
         If lViewDetalhe
            nSldLocPos  -= nSld3Ns
            aRetSldTot[3]  += nSld3Ns
            aViewB2[Len(aViewB2),4] := TransForm(nSld3Ns,cPictB2QTNP)
         EndIf
      Endif
   Endif

   //Se está consultando para visualizar, atualiza array
   If lViewDetalhe
      aRetSldTot[1]  += nSldLocPos
      aViewB2[Len(aViewB2),7] := TransForm(nSldLocPos,cPictB2Qatu)
   EndIf

   //Próximo registro
   (cAliasEst)->(dbSkip())
End

(cAliasEst)->(dbCloseArea())

nSld3Ns := 0
nSldNs3 := 0

//Calcula o saldo se MV_PAR18 = 2 e se não há filtros para os locais
If aPergs711[18] == 2 .And. aFilAlmox == Nil .And. cMT710B2 # Nil .And. aAlmoxNNR == Nil
   //Considera quantidade nossa em poder de terceiro
   If aPergs711[20] == 1
      nSldNs3 := SaldoTerc(cProduto, cAlmoxd, "T", aPeriodos[1]+1, cAlmoxa)[1]
      nSaldo    += nSldNs3
      If lViewDetalhe
         aRetSldTot[2]  += nSldNs3
         aRetSldTot[1]  := nSaldo
         aAdd(aViewB2,{"*",TransForm(nSaldo,cPictB2Qatu),TransForm(nSldNs3,cPictB2QNPT),"-","-","-",TransForm(nSaldo,cPictB2Qatu)})
      EndIf
   Endif

   //Considera quantidade de terceiro em nosso poder
   If aPergs711[21] == 1
      nSld3Ns := SaldoTerc(cProduto, cAlmoxd, "D", aPeriodos[1]+1, cAlmoxa)[1]
      nSaldo    -= nSld3Ns
      If lViewDetalhe
         aRetSldTot[3]  += nSld3Ns
         aRetSldTot[1]  := nSaldo
         If Empty(aViewB2)
            aAdd(aViewB2,{"*",TransForm(nSaldo,cPictB2Qatu),"-",TransForm(nSld3Ns,cPictB2QTNP),"-","-",TransForm(nSaldo,cPictB2Qatu)})
         Else
            aViewB2[Len(aViewB2),4] := TransForm(nSld3Ns,cPictB2QTNP)
            aViewB2[Len(aViewB2),7] := TransForm(nSaldo,cPictB2Qatu)
         EndIf
      EndIf
   Endif
Endif

If lA710SINI
   nSldPE := ExecBlock("A710SINI",.F.,.F.,{cProduto,nSaldo})
   If ValType(nSldPE) == "N"
      nSaldo := nSldPE
   EndIf
EndIf

RestArea(aAreaSB1)

Return aClone(aRetSldTot)

/*------------------------------------------------------------------------//
//Programa: buscaRec
//Autor:    Lucas Konrad França
//Data:     28/01/2015
//Descricao:   Busca o próximo recno da tabela temporaria OQPROD
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function buscaRec()
   Local cQuery := ""
   Local nRec   := 0
   Local cAlias := GetNextAlias()

   cQuery := "SELECT MAX(R_E_C_N_O_) REC "
   cQuery +=  " FROM OQPROD "

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   nRec := (cAlias)->(REC)
   nRec++
   (cAlias)->(dbCloseArea())
Return nRec

/*------------------------------------------------------------------------//
//Programa: a107EstSeg
//Autor:    Lucas Konrad França
//Data:     28/01/2015
//Descricao:   Verifica se o estoque de segurança/ponto de pedido
//             do produto irá ser utilizado na empresa corrente.
//Parametros:  01.cProduto       - Produto
//             02.aEmp           - Empresas cadastradas como centralizadas.
//             03.lRetEmp        - Indica se irá retornar a empresa que irá
//                                 utilizar o estoque de segurança
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function a107EstSeg(cProduto,aEmp,lRetEmp)
   Local lRet     := .F.
   Local lAchou   := .F.
   Local cEmpresa := cEmpAnt
   Local cFiliBkp := cFilAnt
   Local nI       := 0
   Local aArea    := GetArea()
   Local aEmpRet  := {}
   Local aRetEmp  := {}

   If cDadosProd == "SBZ"
      dbSelectArea("SBZ")
      SBZ->(dbSetOrder(1))
      If SBZ->(dbSeek(xFilial("SBZ")+cProduto))
         aEmpRet := {cEmpAnt, cFilAnt}
      Else
         aEmpRet := verItProd(cProduto)
      EndIf
   Else
      aEmpRet := verItProd(cProduto)
   EndIf

   If aEmpRet[1] != Nil .And. aEmpRet[2] != Nil
      If AllTrim(aEmpRet[1]) == AllTrim(cEmpAnt) .And. AllTrim(aEmpRet[2]) == AllTrim(cFilAnt)
         lRet := .T.
      Else
         lRet := .F.
      EndIf
      If lRetEmp
         aAdd(aRetEmp,aEmpRet[1])
         aAdd(aRetEmp,aEmpRet[2])
      EndIf
   Else
      //Percorre as empresas já ordenadas pela prioridade.
      For nI := 1 To Len(aEmp)
         NGPrepTBL({{"SG1",1}},aEmp[nI][1],AllTrim(aEmp[nI][2]))
         dbSelectArea("SG1")
         SG1->(dbSetOrder(2))
         If SG1->(dbSeek(xFilial("SG1")+cProduto))
            //Se é utilizado em outra empresa como componente, não gera o estoque de segurança na empresa corrente.
            If AllTrim(aEmp[nI][1]) == AllTrim(cEmpresa) .And. AllTrim(aEmp[nI][2]) == AllTrim(cFiliBkp)
               lAchou := .F.
            Else
               lAchou := .T.
            EndIf
            Exit
         EndIf
      Next nI
      NGPrepTBL({{"SG1",1}},cEmpresa,AllTrim(cFiliBkp))
      //Se o item não é utilizado em nenhuma outra empresa, gera o estoque de segurança na empresa principal.
      If !lAchou
         If AllTrim(aEmp[1][1]) == AllTrim(cEmpAnt) .And. AllTrim(aEmp[1][2]) == AllTrim(cFilAnt) 
            lRet := .T.
         Else
         	lRet := .F.
         EndIf
         If lRetEmp
            aAdd(aRetEmp,aEmp[1][1])
            aAdd(aRetEmp,aEmp[1][2])
         EndIf
      EndIf
      If lAchou .And. lRetEmp
         aAdd(aRetEmp,aEmp[nI,1])
         aAdd(aRetEmp,aEmp[nI,2])
      EndIf
      RestArea(aArea)
   EndIf
Return Iif(lRetEmp,aRetEmp,lRet)

/*------------------------------------------------------------------------//
//Programa: A107LotVnc
//Autor:    Andre Anjos
//Data:     09/10/08
//Descricao:   Calcula o saldo de lotes vencidos, conforme MV_LOTVENC
//Parametros:  01.cProduto       - Produto
//             02.dData       - Data de referência
//             03.cLocal         - Local da verificação
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107LotVnc(cProduto,dData,cLocal)
Local aArea     := GetArea()
Local lConsVenc := SuperGetMV("MV_LOTVENC",.F.,"N")=="S"
Local nQtde     := 0
Local cLocCQ    := Substr(SuperGetMV("MV_CQ",.F.,"98"),1,2)
Local cFiltro   := ""
Local cArqTrb   := ""
Local nPos      := 0
Local nInd       := 0

DEFAULT cLocal := ""

If !lConsVenc .And. Rastro(cProduto)
   nPos := aScan(aPeriodos,dData)

   cArqTrb := "LOTVNC"
   cFiltro += " SELECT SUM(B8_SALDO) AS B8_SALDO " +;
               " FROM " +RetSQLName("SB8") +;
              " WHERE B8_FILIAL  = '" +xFilial("SB8") + "' " +;
                " AND B8_PRODUTO = '" +cProduto +"' " +;
                " AND B8_LOCAL  >= '" +aPergs711[8] +"' " +;
                " AND B8_LOCAL  <= '" +aPergs711[9] +"' " +;
                " AND B8_SALDO   > 0 " +;
                " AND D_E_L_E_T_ = ' ' "

   If aPergs711[22] == 1 //ja e tratado indiretamente na A107QtdCQ
      cFiltro += " AND B8_LOCAL <> '" +cLocCQ +"' "
   EndIf

   If cLocal <> ""
      cFiltro += " AND B8_LOCAL = '" +cLocal+ "' "
   EndIf

   If nPos == 1
      cFiltro += " AND B8_DTVALID > '20000101' "
      cFiltro += " AND B8_DTVALID < '" +DToS(dData) +"' "
   Else
      cFiltro += " AND B8_DTVALID >= '" +DToS(aPeriodos[nPos-1]) +"' "
      cFiltro += " AND B8_DTVALID  < '" +DToS(dData) +"' "
   EndIf

   If aAlmoxNNR # Nil
      cFiltro += " AND B8_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR "
      cFiltro += " WHERE  NR_EMP = '"+cEmpAnt +"'" 
      cFiltro += " AND  NR_FILIAL = '"+cFILAnt +"'" 
      cFiltro += " ) "
   EndIf

   If aFilAlmox # Nil
      cFiltro += " AND B8_LOCAL IN ('"+Criavar("B8_LOCAL",.F.)+"' "
      For nInd := 1 to Len(aFilAlmox)
         cFiltro += ",'"+aFilAlmox[nInd]+"' "
      Next nInd
      cFiltro += ") "
   EndIf

   cFiltro := ChangeQuery(cFiltro)
   dbUseArea(.T.,"TOPCONN",TCGenQry(,,cFiltro),cArqTrb,.F.,.T.)

   nQtde += (cArqTrb)->B8_SALDO

   (cArqTrb)->(dbCloseArea())
   RestArea(aArea)
EndIf

Return(nQtde)

/*------------------------------------------------------------------------//
//Programa: A107QtdCQ
//Autor:    Ricardo Prandi
//Data:     23/09/2013
//Descricao:   Calcula o saldo rejeitado do produto no almoxarifado de CQ
//Parametros:  01.cProduto       - Produto
//             02.cLocal         - Local da verificação
//             03.dData       - Data de referência
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107QtdCQ(cProduto, cLocal, dData)
Local nQtde    := 0
Local cQuery   := ""
Local cArqTrb  := "BUSCACQ"
Local aOldArea := GetArea()

Default dData  := dDataBase
Default cLocal := GetMv("MV_CQ")

cQuery := " SELECT SD7.D7_FILIAL, " +;
                 " SD7.D7_PRODUTO, " +;
                 " SD7.D7_NUMSEQ, " +;
                 " SD7.D7_NUMERO, " +;
                 " SD7.D7_TIPO, " +;
                 " SD7.D7_QTDE, " +;
                 " SD7.D7_FORNECE, " +;
                 " SD7.D7_LOJA, " +;
                 " SD7.D7_DOC, " +;
                 " SD7.D7_SERIE " +;
           " FROM " + RetSQLName("SD7") + " SD7 " +;
          " WHERE SD7.D7_FILIAL   = '" + xFilial("SB8") + "' " +;
            " AND SD7.D7_PRODUTO  = '" + cProduto + "' " +;
            " AND SD7.D7_LOCDEST  = '" + cLocal + "' " +;
            " AND SD7.D7_DATA     < '" + dTos(dData) + "' " +;
            " AND SD7.D7_ESTORNO <> 'S' " +;
            " AND SD7.D_E_L_E_T_  = ' ' " +;
          " ORDER BY SD7.D7_FILIAL, " +;
                   " SD7.D7_PRODUTO, " +;
                   " SD7.D7_NUMSEQ, " +;
                   " SD7.D7_NUMERO "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cArqTrb,.F.,.T.)

Do While !(cArqTrb)->(Eof())
   If (cArqTrb)->D7_TIPO == 2    //Rejeitada
      If (cArqTrb)->D7_QTDE > 0
         nQtde += A107AbDev((cArqTrb)->D7_FORNECE,(cArqTrb)->D7_LOJA,(cArqTrb)->D7_DOC,(cArqTrb)->D7_SERIE,(cArqTrb)->D7_QTDE)
      Endif
   ElseIf (cArqTrb)->D7_TIPO == 6  //Estorno da Liberacao
      nQtde += (cArqTrb)->D7_QTDE
   Endif
   (cArqTrb)->(dbSkip())
EndDo

(cArqTrb)->(dbCloseArea())

RestArea(aOldArea)

Return(nQtde)

/*------------------------------------------------------------------------//
//Programa: A107AbDev
//Autor:    Sergio S. Fuzinaka
//Data:     18.09.09
//Descricao:   Retorna a Quantidade, subtraindo as quantidades das Notas
//          Fiscais de Devolucao de Compras
//Parametros:  01.cFornece       - Fornecedor
//             02.cLoja       - Loja
//          03.cDoc        - Documento
//          04.cSerie         - Serio da nota fiscal
//          05.nQtdD7         - Quantidade
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107AbDev(cFornece,cLoja,cDoc,cSerie,nQtdD7)
Local nQtde    := 0
Local nQtDev      := 0
Local cAliasTop   := "BUSCAABDEV"

BeginSql Alias cAliasTop
SELECT SUM(D2_QUANT) QTDEV
  FROM %table:SD2% SD2
 WHERE SD2.D2_FILIAL  = %xFilial:SD2%
   AND SD2.D2_TIPO    = 'D'
   AND SD2.D2_CLIENTE = %Exp:cFornece%
   AND SD2.D2_LOJA    = %Exp:cLoja%
   AND SD2.D2_NFORI   = %Exp:cDoc%
   AND SD2.D2_SERIORI = %Exp:cSerie%
   AND SD2.%NotDel%
EndSql
nQtDev := (cAliasTop)->QTDEV

nQtde := IIf(nQtdD7 >= nQtDev,nQtdD7 - nQtDev,nQtdD7)

(cAliasTop)->(dbCloseArea())

Return nQtde

/*------------------------------------------------------------------------//
//Programa: A107QtdDD
//Autor:    Ricardo Prandi
//Data:     23/09/2013
//Descricao:   Calcula o saldo bloqueado do produto no arquivo SDD
//Parametros:  01.cProduto       - Produto
//             02.cLocal         - Local da verificação
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107QtdDD(cProduto, cLocal)
Local cArqTrb := "BUSCADD"
Local nQtde    := 0
Local aOldArea := GetArea()

BeginSql Alias cArqTrb
SELECT SUM(DD_SALDO) QTSALDO
  FROM %table:SDD% SDD
 WHERE SDD.DD_FILIAL  = %xFilial:SD2%
   AND SDD.DD_PRODUTO = %Exp:cProduto%
   AND SDD.DD_LOCAL   = %Exp:cLocal%
   AND SDD.DD_MOTIVO <> 'VV'
   AND SDD.%NotDel%
EndSql
nQtde += (cArqTrb)->QTSALDO

(cArqTrb)->(dbCloseArea())
RestArea(aOldArea)
Return (nQtde)

/*------------------------------------------------------------------------//
//Programa: A107CriaLOG
//Autor:    Rodrigo Sartorio
//Data:     27/08/03
//Descricao:   Avalia as informacoes relacioandas ao evento e caso o log
//          do MRP esteja ativo alimenta o arquivo de LOG do sistema
//Parametros:  01.cEvento        - Codigo do Evento que deve ser avaliado
//             02.cProduto       - Codigo do produto que deve ser avaliado
//          03.aDados         - Array com os dados utilizados na avaliacao do evento informado
//          04.lLogMRP        - Indica se irá gravar o LOG
//          05.c711NumMrp     - Número do MRP
//Uso:      PCPA107
//------------------------------------------------------------------------//
Evento 001 - Saldo em estoque inicial menor que zero
   aDados[1] - Saldo inicial do Produto
Evento 002 - Atrasar o evento
   aDados[1] - Data original
   aDados[2] - Numero do Documento
   aDados[3] - Item ou outro dado complementar do documento
   aDados[4] - Alias do documento
   aDados[5] - Data para atrasar
Evento 003 - Adiantar o evento
   aDados[1] - Data original
   aDados[2] - Numero do Documento
   aDados[3] - Item ou outro dado complementar do documento
   aDados[4] - Alias do documento
   aDados[5] - Data para atrasar
Evento 004 - Data de necessidade invalida - Data anterior a database
   aDados[1] - Codigo do produto que gerou a necessidade
   aDados[2] - Quantidade da necessidade
   aDados[3] - Data calculada
Evento 005 - Data de necessidade invalida - Data posterior ao prazo maximo do MRP
   aDados[1] - Codigo do produto que gerou a necessidade
   aDados[2] - Quantidade da necessidade
   aDados[3] - Data calculada
Evento 006 - Documento planejado em atraso
   aDados[1] - Data planejada do evento
   aDados[2] - Numero do Documento
   aDados[3] - Item ou outro dado complementar do documento
   aDados[4] - Alias do documento
Evento 007 - Cancelar o documento
   aDados[1] - Data do documento
   aDados[2] - Numero do Documento
   aDados[3] - Item ou outro dado complementar do documento
   aDados[4] - Alias do documento
Evento 008 - Saldo em estoque maior ou igual ao estoque maximo
   aDados[1] - Estoque maximo
   aDados[2] - Saldo em estoque
   aDados[3] - Data do periodo
   aDados[4] - Alias do documento
Evento 009 - Saldo em estoque menor ou igual ao ponto de pedido
   aDados[1] - Ponto de pedido
   aDados[2] - Saldo em estoque
aDados[3] - Data do periodo
aDados[4] - Alias do documento
//------------------------------------------------------------------------*/
Function A107CriaLOG(cEvento,cProduto,aDados,lLogMRP,c711NumMrp)
LOCAL aArea          := GetArea()
LOCAL aDescEventos   := {}
LOCAL aDocs       := {}
LOCAL aTamSB2        := {}
LOCAL nAcho       := 0
LOCAL nAchoDoc    := 0
LOCAL cDocumento     := ""
LOCAL cTexto         := ""
LOCAL cItem       := ""
LOCAL cArquivo    := ""
LOCAL cCodOri        := ""

// Array contendo a descricao dos documentos
AADD(aDocs,{"SC1",STR0078})
AADD(aDocs,{"SC7",STR0079})
AADD(aDocs,{"SC2",STR0080})
AADD(aDocs,{"SHC",STR0081})
AADD(aDocs,{"SD4",STR0082})
AADD(aDocs,{"SC6",STR0083})
AADD(aDocs,{"SC4",STR0084})
AADD(aDocs,{"AFJ",STR0085})
AADD(aDocs,{"ENG",STR0086})
AADD(aDocs,{"SB1",STR0087})
AADD(aDocs,{"SBP",STR0088})

// Array contendo o codigo dos eventos e a descricao relacionada
AADD(aDescEventos,{"001",OemToAnsi(STR0089)}) //"Saldo em estoque inicial menor que zero. Saldo "
AADD(aDescEventos,{"002",OemToAnsi(STR0090)}) //"Atrasar o documento "
AADD(aDescEventos,{"003",OemToAnsi(STR0091)}) //"Adiantar o documento "
AADD(aDescEventos,{"004",OemToAnsi(STR0092)}) //"Data de necessidade invalida - Data anterior a database do calculo. Produto origem da necessidade "
AADD(aDescEventos,{"005",OemToAnsi(STR0093)}) //"Data de necessidade invalida - Data posterior a data limite do calculo. Produto origem da necessidade "
AADD(aDescEventos,{"006",OemToAnsi(STR0094)}) //"Documento planejado em atraso. Planejado para "
AADD(aDescEventos,{"007",OemToAnsi(STR0095)}) //"Cancelar o documento "
AADD(aDescEventos,{"008",OemToAnsi(STR0096)}) //"Saldo em estoque maior que o estoque maximo "
AADD(aDescEventos,{"009",OemToAnsi(STR0097)}) //"Saldo em estoque menor ou igual ao ponto de pedido "

// Verifica se o evento esta cadastrado
nAcho := ASCAN(aDescEventos,{|x| x[1] == cEvento})

// Busca posicao do alias de acordo com o evento
// Eventos sem alias devem ser adicionados nesta condicao
If !(cEvento $ "001*004*005")
   nAchoDoc := aScan(aDocs,{|x| x[1] == aDados[4]})
EndIf

// So avalia eventos se o LOG do MRP estiver ativo
If lLogMRP .And. nAcho > 0
   aTamSB2 := TamSX3("B2_QATU")

   If cEvento == "001" .And. QtdComp(aDados[1]) < QtdComp(0)
      cTexto := aDescEventos[nAcho,2] +AllTrim(Str(aDados[1],aTamSB2[1],aTamSB2[2]))
   ElseIf cEvento == "002"
      cTexto := aDescEventos[nAcho,2] +AllTrim(aDados[2]) +If(!Empty(aDados[3])," / " +AllTrim(aDados[3]),"") +" - "
      cTexto += aDocs[nAchoDoc,2] +OemToAnsi(STR0098) +DTOC(aDados[1]) +OemToAnsi(STR0099)+DTOC(aDados[5]) //" de "###" para "
      cDocumento := aDados[2]
      cItem := aDados[3]
      cArquivo := aDados[4]
   ElseIf cEvento == "003"
      cTexto := aDescEventos[nAcho,2] +AllTrim(aDados[2]) +If(!Empty(aDados[3])," / " +AllTrim(aDados[3]),"") +" - "
      cTexto +=aDocs[nAchoDoc,2] +OemToAnsi(STR0098)+DTOC(aDados[1])+OemToAnsi(STR0099)+DTOC(aDados[5]) //" de "###" para "
      cDocumento := aDados[2]
      cItem := aDados[3]
      cArquivo := aDados[4]
   ElseIf cEvento == "004"
      cCodOri := aDados[1]
      If aDados[3] < aPeriodos[1]
         cTexto := aDescEventos[nAcho,2] +AllTrim(aDados[1]) +STR0100 +AllTrim(Str(aDados[2],aTamSB2[1],aTamSB2[2])) //" Quantidade "
      ElseIf aDados[3] > aPeriodos[Len(aPeriodos)]
         cEvento := "005"
         nAcho := ASCAN(aDescEventos,{|x| x[1] == cEvento})
         cTexto := aDescEventos[nAcho,2] +AllTrim(aDados[1]) +STR0100 +AllTrim(Str(aDados[2],aTamSB2[1],aTamSB2[2])) //" Quantidade "
      EndIf
   ElseIf cEvento == "006" .And. aDados[1] < dDataBase
      cTexto := aDescEventos[nAcho,2] +DTOC(aDados[1]) +"." +AllTrim(aDados[2]) +If(!Empty(aDados[3])," / " +AllTrim(aDados[3]),"")
      cTexto += " - " +aDocs[nAchoDoc,2]
      cDocumento := aDados[2]
      cItem := aDados[3]
      cArquivo := aDados[4]
   ElseIf cEvento == "007" .And. aDados[4] # "SBP"
      cTexto := aDescEventos[nAcho,2] +AllTrim(aDados[2]) +If(!Empty(aDados[3])," / " +AllTrim(aDados[3]),"")
      cTexto += " - " +aDocs[nAchoDoc,2] +OemToAnsi(STR0101) +DTOC(aDados[1]) +OemToAnsi(STR0102) //" Data Original "###" pois seu saldo nao sera utilizado em nenhum periodo"
      cDocumento := aDados[2]
      cItem := aDados[3]
      cArquivo := aDados[4]
   ElseIf cEvento == "008"
      cTexto := aDescEventos[nAcho,2] +OemToAnsi(STR0103) +AllTrim(Str(aDados[1],aTamSB2[1],aTamSB2[2])) +" "+OemToAnsi(STR0042)
      cTexto += AllTrim(Str(aDados[2],aTamSB2[1],aTamSB2[2])) +OemToAnsi(STR0104) +DToC(aDados[3]) +" - " +aDocs[nAchoDoc,2]
      cArquivo := aDados[4]
   ElseIf cEvento == "009"
      cTexto := aDescEventos[nAcho,2] +OemToAnsi(STR0105) +AllTrim(Str(aDados[1],aTamSB2[1],aTamSB2[2])) +" "+OemToAnsi(STR0042)
      cTexto += AllTrim(Str(aDados[2],aTamSB2[1],aTamSB2[2])) +OemToAnsi(STR0104) +DToC(aDados[3]) +" - " +aDocs[nAchoDoc,2]
      cArquivo := aDados[4]
   EndIf

   If !Empty(cTexto)
      Reclock("SHG",.T.)
      SHG->HG_FILIAL := xFilial("SHG")
      SHG->HG_SEQMRP := c711NumMRP
      SHG->HG_COD    := cProduto
      SHG->HG_CODLOG := cEvento
      SHG->HG_LOGMRP := cTexto
      SHG->HG_DOC    := AllTrim(cDocumento)
      SHG->HG_ITEM   := AllTrim(cItem)
      SHG->HG_ALIAS  := cArquivo
      SHG->HG_CODORI := cCodOri
      MsUnlock()
   EndIf
EndIf

RestArea(aArea)

Return

/*------------------------------------------------------------------------//
//Programa: MontaOpc
//Autor:    Anieli Rodrigues
//Data:     02/01/2013
//Descricao:   Monta String com o codigo do opcional (Campo C6_MOPC)
//Parametros:  01.cMopc - Conteudo do campo memo a ser transformado
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function MontaOpc(cMOpc,cProd,cNivelEstr)
Local cRet    := "" 
Local aAux    := {} 
Local nI      := 0
Local nNivel  := 0
Local nTamPrd := TamSX3("B1_COD")[1]
Local nTamSeq := TamSX3("G1_TRT")[1]

Default cProd      := ""
Default cNivelEstr := ""

If !Empty(aAux := STR2Array(cMOpc,.F.)) 
	If !Empty(cProd) .And. !Empty(cNivelEstr)
		nNivel := Iif(ValType(cNivelEstr)=="N",cNivelEstr,Val(cNivelEstr))
		If nNivel <= 1
			nPos := 1
		Else
			nPos := nTamPrd + ((nTamPrd+nTamSeq)*(nNivel-2)) + 1
		EndIf
		
		if lUsaMOpc 
			For nI := 1 To Len(aAux)
				If cProd $ SubStr(aAux[nI,1],nPos,Len(aAux[nI,1])) .And. Len(SubStr(aAux[nI,1],nPos,Len(aAux[nI,1]))) != nTamPrd+nTamSeq
					cRet += aAux[nI,2] + "/"
				EndIf
			Next nI
		else
			For nI := 1 To Len(aAux)
			    If at(aAux[nI,2],cRet) == 0 
			    	cRet += aAux[nI,2] + "/"
			    endif
			Next nI
		endif
	Else
		aEval(aAux,{|x| cRet += x[2]})
	EndIf 
Endif 

If Len(cRet) == 0
   cRet := AllTrim(cMOpc)
EndIf

Return cRet

/*------------------------------------------------------------------------//
//Programa: A107EstOpc
//Autor:    Rodrigo de A. Sartorio
//Data:     29/08/02
//Descricao:   Funcao recursiva para verificar opcionais utilizados
//Parametros:  01.cProduto    = Codigo do produto a ser explodido
//          02.cOpcionais = Opcionais utilizados
//          03.lRecursiva  = Indica se a função será recursiva
//          04.lRetOpc  = Indica se irá retornar para os opcionais
//          05.cStrTipo = String dos tipos de itens selecionados
//          06.cStrGrupo   = String dos grupos de itens selecionados
//          07.lMATA650 = Indica se o programa está sendo chamado do MATA650
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107EstOpc(cProduto,cOpcionais,lRecursiva,lRetOpc,cStrTipo,cStrGrupo,lMATA650)
Local aArea := GetArea()
Local cRetGr   := ""
Local i     := 0
Local aRegs := {}
Local aRegGr   := {}

Default lRecursiva := .T.
Default lRetOpc    := .F.
Default cStrTipo   := ""
Default cStrGrupo  := ""
Default lMATA650   := .F.

If !Empty(cOpcionais) .And. !Empty(cProduto)
   //Posiciona no produto desejado
   dbSelectArea("SG1")
   dbSetOrder(1)
   dbSeek(xFilial("SG1")+cProduto)
   While !Eof() .And. G1_FILIAL+G1_COD == xFilial("SG1")+cProduto
      //Verifica quais grupos de opcionais sao utilizados na estrutura do produto original.
      If !Empty(SG1->G1_GROPC)
         If Empty(AsCan(aRegGr,{|x| x==SG1->G1_GROPC + If(lRetOpc, SG1->G1_OPC, "")}))
            aadd(aRegGr,SG1->G1_GROPC + If(lRetOpc, SG1->G1_OPC, ""))
         EndIf
      Else
         //Caso nao tenha opcionais neste nivel, guarda o registro para pesquisar em niveis inferiores
         AADD(aRegs,{SG1->(Recno()),SG1->G1_NIV})
      EndIf
      dbSelectArea("SG1")
      dbSkip()
   Enddo

   ASORT(aRegGr,,,{|x,y| x < y})
   For i:=1 To Len(aRegGr)
      cRetGr+=If(lRetOpc .And. !Empty(cRetGr),"/","")+aRegGr[i]
   Next i

   If lRecursiva
      ASORT(aRegs,,,{|x,y| x[2] < y[2]})
      //Varre o array para que sejam selecionados os itens restantes
      For i:=1 to Len(aRegs)
         SG1->(dbGoto(aRegs[i,1]))
         cRetGr += A107EstOpc(SG1->G1_COMP,cOpcionais,NIL,If(lMATA650,.T.,NIL),cStrTipo,cStrGrupo,lMATA650)
      Next I
   Endif
EndIf

RestArea(aArea)

Return cRetGr

/*------------------------------------------------------------------------//
//Programa: A107AvlOpc
//Autor:    Rodrigo de A. Sartorio
//Data:     29/08/02
//Descricao:   Funcao para verificar opcionais utilizados
//Parametros:  01.ExpC1 = Codigo do produto a ser explodido
//          02.ExpC2 = Grupos de opcionais utilizados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107AvlOpc(cOpcArq,cGrupos)
Local cOpc711Vaz  := CriaVar("C2_OPC",.F.)
Local cRetOpc     := ""
Local cGrScan     := ""
Local nTamGrupo   := Len(SG1->G1_GROPC)
Local nTamItGr    := Len(SG1->G1_OPC)
Local aArea    := GetArea()

cOpcArq := "/" + cOpcArq

While !Empty(cGrupos)
   //Obtem o grupo a ser pesquisado
   cGrScan := Substr(cGrupos,1,nTamGrupo)
   //Retira grupo a ser pesquisado da lista de grupos originais
   cGrupos := Substr(cGrupos,nTamGrupo+1)
   //Procura grupo no campo de opcionais do arquivo
   nString := AT("/"+cGrScan,cOpcArq)
   If nString > 0 .And. !(Substr(cOpcArq,nString+1,nTamGrupo+nTamItGr+1) $ cRetOpc)
      cRetOpc += Substr(cOpcArq,nString+1,nTamGrupo+nTamItGr+1)
   EndIf
End

RestArea(aArea)
cRetOpc := cRetOpc+Space(Len(cOpc711Vaz)-Len(cRetOpc))

Return cRetOpc

/*------------------------------------------------------------------------//
//Programa: PCPA107EHC
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Explode estrutura dos registros de plano mestre de produção
//Parametros:  cStrTipo     - String com os tipos de itens
//             cStrGrupo    - String com os grupos dos itens
//             oCenterPanel - Objeto do painel de processamento
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PCPA107EHC(cStrTipo,cStrGrupo,oCenterPanel)
Local cQuery      := ""
Local mOpc        := ""
Local cOpc        := ""
Local cAliasTop   := "ESTSHC"
Local nRecno      := 0
Local nI          := 0
Local lMT710EXP   := .T.
Local aDados      := {}
Local OQFILIAL    := 1
Local OQPROD      := 2
Local OQNRRV      := 3
Local OQQUANT     := 4
Local OQDTOG      := 5
Local OQNRRGAL    := 6
Local SOQREC      := 7

cQuery := " SELECT SOQ.OQ_FILIAL, "
cQuery +=        " SOQ.OQ_PROD, "
cQuery +=        " SOQ.OQ_NRRV, "
cQuery +=        " SOQ.OQ_QUANT, "
cQuery +=        " SOQ.OQ_DTOG, "
cQuery +=        " SOQ.OQ_NRRGAL, "
cQuery +=        " SOQ.R_E_C_N_O_ SOQREC "
cQuery +=   " FROM " + RetSqlName("SOQ")+ " SOQ "
cQuery +=  " WHERE SOQ.OQ_FILIAL = '" + xFilial("SOQ") + "' "
cQuery +=    " AND SOQ.OQ_ALIAS  = 'SHC' "
cQuery +=    " AND SOQ.OQ_EMP    = '" + cEmpAnt + "'"
cQuery +=    " AND SOQ.OQ_FILEMP = '" + cFilAnt + "'"
cQuery += "  ORDER BY " + SqlOrder(SOQ->(IndexKey(2)))

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SOQ->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})

dbSelectArea(cAliasTop)

While !Eof()
   aAdd(aDados,{(cAliasTop)->OQ_FILIAL,;
                (cAliasTop)->OQ_PROD,;
                (cAliasTop)->OQ_NRRV,;
                (cAliasTop)->OQ_QUANT,;
                (cAliasTop)->OQ_DTOG,;
                (cAliasTop)->OQ_NRRGAL,;
                (cAliasTop)->SOQREC})
   (cAliasTop)->(dbSkip())
End
(cAliasTop)->(dbCloseArea())

For nI := 1 To Len(aDados)
   If (oCenterPanel != Nil)
      oCenterPanel:IncRegua1(OemToAnsi(STR0106))
   EndIf
   nRecno := aDados[nI,OQNRRGAL]

   SHC->(DbGoTo(nRecno))
   cOpc := SHC->HC_OPC
   If Empty(SHC->HC_MOPC)
      mOpc := SHC->HC_OPC
   Else
      mOpc := SHC->HC_MOPC
   EndIf

   If Empty((aOpc := Str2Array(mOpc,.F.)))
      aOpc := {}
   EndIf

   If lPeMT710EXP
      lMT710EXP := ExecBlock("MT710EXP",.F.,.F.,{aDados[nI,OQPROD],mOpc,aDados[nI,OQNRRV],aDados[nI,OQQUANT]})
      If ValType(lMT710EXP) # "L"
         lMT710EXP := .T.
      EndIf
   EndIf

   If lMT710EXP
      A107ExplEs(aDados[nI,OQPROD],cOpc,aDados[nI,OQNRRV],aDados[nI,OQQUANT],A650DtoPer(aDados[nI,OQDTOG]),cStrTipo,cStrGrupo,aOpc,.F.,.T.,,,,1)
   EndIf
Next nI

A107GrvTm(oCenterPanel,STR0107) //"Termino da Explosao da Estrutura dos Itens relacionados ao Plano Mestre de Producao - SHC."

If (oCenterPanel <> Nil)
   oCenterPanel:IncRegua2()
EndIf

Return

/*------------------------------------------------------------------------//
//Programa: A107ExplEs
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Explode a estrutura do produto no MRP
//Parametros:  01.cProduto       - Codigo do produto a ser explodido
//             02.cOpcionais     - Grupos de opcionais utilizados
//             03.cRevisao       - Revisao Estrutura
//             04.nQuant         - Quantidade base a ser explodida
//             05.cPeriodo       - Periodo da necessidade do produto
//             06.cParStrTipo    - String com tipos a serem processados
//             07.cParStrGrupo   - String com grupos a serem processados
//             08.aOpc           - Array de opcionais
//             09.lRecalc        - Indica se vai recalcular as necessidades
//             10.lCalcula       - Indica se calcula após a inclusão
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107ExplEs(cProduto,cOpcionais,cRevisao,nQuant,cPeriodo,cParStrTipo,cParStrGrupo,aOpc,lRecalc,lCalcula,lExpRec,cDoc,cProdFan,nNivExpl)
Local lAllTp      := Ascan(A711Tipo,{|x| x[1] == .F.}) == 0
Local lAllGrp     := Ascan(A711Grupo,{|x| x[1] == .F.}) == 0
Local lExplode    := .T.
Local dDataNes    := dDataBase
Local nQuantItem  := 0
Local nSaldoMP    := 0
Local nQuantParc  := 0
Local nPrazoEnt   := CalcPrazo(cProduto,nQuant,,,.F.,aPeriodos[Val(cPeriodo)])
Local nZ          := 0
Local nI          := 0
Local nRecSot     := 0
Local nRecSor     := 0
Local nSotDest    := 0
Local nSaldoIni   := 0
Local nSldGeral   := 0
Local nSorDest    := 0
Local nQtdTran    := 0
Local nQtUsada    := 0
Local nSldSOT     := 0
Local nEntrTrans  := 0
Local nSaidTrans  := 0
Local nSotTran    := 0
Local nTamFil     := TamSX3("OQ_FILEMP")[1]
Local nEstSeg     := 0
Local nPontoPed   := Nil
Local nQtdPP      := 0
Local cRev711Vaz  := CriaVar("B1_REVATU",.F.)
Local cQuery      := ""
Local cAliasSG1   := ""
Local cAliasSB1   := ""
Local cTipoEst    := ""
Local cStrTipo    := ""
Local cStrGrupo   := ""
Local cNivel      := "99"
Local cEmpresa    := cEmpAnt
Local cFili       := cFilAnt
Local cPerSld     := "001"
Local lCompNeg    := .F.
Local lMT710EXP   := .T.
Local lMRPCINQ    := SuperGetMV("MV_MRPCINQ",.F.,.F.)
Local lAchou      := .F.
Local lFantasma   := .F.
Local lRecalcPer  := .F.
Local aEmpresas   := {}
Local aDados      := {}
Local aCompon     := {}
Local aRet        := {}
Local aRetEmp     := {}
Local cRelac    := Nil

Local G1FILIAL    := 1
Local G1COD       := 2
Local G1COMP      := 3
Local G1POTENCI   := 4
Local G1GROPC     := 5
Local G1OPC       := 6
Local G1INI       := 7
Local G1FIM       := 8
Local G1PERDA     := 9
Local G1FIXVAR    := 10
Local G1TRT       := 11
Local G1REVINI    := 12
Local G1REVFIM    := 13
Local G1QUANT     := 14
Local BCREVATU    := 15
Local BCTIPODEC   := 16
Local B1REVATU    := 17
Local B1QBP       := 18
Local BCFILIAL    := 19
Local BCCOD       := 20
Local BCFANTASM   := 21
Local BCEMIN      := 22
Local B1FILIAL    := 23
Local B1COD       := 24
Local B1OPC       := 25
Local B1QB        := 26
Local lFRecal     := Iif(Type("lForcRecal") == "L" .And. lForcRecal == .T.,.T.,.F.)
local lCpRevSBZ      // VALIDA CAMPO DE REV. FILIAL SBZ BZ_REVATU
local aAreaSBZ    := {}
Local mOpc        := ""
Local cGrupos     := ""
Private lAlteraOQ := .T.

Default aOpc      := {}
Default lRecalc   := .T.
Default lCalcula  := .F.
Default lExpRec   := .F.
//Default nRecOrig  := -1
Default cDoc      := Nil
Default cProdFan  := Nil
Default nNivExpl  := 0


  aAreaSBZ := SBZ->(GETAREA())
  dbSelectArea("SBZ")
  lCpRevSBZ   := FieldPos("BZ_REVATU") > 0
  RestArea(aAreaSBZ)

aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nI := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nI,1],aEmpCent[nI,2],aEmpCent[nI,3]})
   EndIf
Next nI
If ValType(cParStrTipo) == "C"
   cStrTipo := cParStrTipo
EndIf

If ValType(cParStrGrupo) == "C"
   cStrGrupo := cParStrGrupo
EndIf

nPrazoEnt += nLdTmTrans
nLdTmTrans := 0

//Verifica se o movimento esta dentro do periodo
If !Empty(cPeriodo)
   dDataNes := aPeriodos[Val(cPeriodo)]

   cAliasSG1 := GetNextAlias()
   cAliasSB1 := cAliasSG1
   cQuery := " SELECT SG1.G1_FILIAL, " +;
                    " SG1.G1_COD, " +;
                    " SG1.G1_COMP, " +;
                    " SG1.G1_POTENCI, " +;
                    " SG1.G1_GROPC, " +;
                    " SG1.G1_OPC, " +;
                    " SG1.G1_INI, " +;
                    " SG1.G1_FIM, " +;
                    " SG1.G1_PERDA, " +;
                    " SG1.G1_FIXVAR, " +;
                    " SG1.G1_TRT, " +;
                    " SG1.G1_REVINI, " +;
                    " SG1.G1_REVFIM, " +;
                    " SG1.G1_QUANT, " +;
                    " SB1C.B1_REVATU BC_REVATU, " +;
                    " SB1C.B1_TIPODEC BC_TIPODEC, " +;
                    " SB1P.B1_REVATU B1_REVATU, " +;
                    " SB1P.B1_QBP B1_QBP, "

   If cDadosProd == "SBZ"
      cQuery += " ISNULL(SBZC.BZ_FILIAL ,SB1C.B1_FILIAL)  BC_FILIAL, " +;
                " ISNULL(SBZC.BZ_COD    ,SB1C.B1_COD)     BC_COD, " +;
                " ISNULL(SBZC.BZ_FANTASM,SB1C.B1_FANTASM) BC_FANTASM, " +;
                " ISNULL(SBZC.BZ_EMIN   ,SB1C.B1_EMIN)    BC_EMIN, " +;
                " ISNULL(SBZP.BZ_FILIAL ,SB1P.B1_FILIAL)  B1_FILIAL, " +;
                " ISNULL(SBZP.BZ_COD    ,SB1P.B1_COD)     B1_COD, " +;
                " ISNULL(SBZP.BZ_OPC    ,SB1P.B1_OPC)     B1_OPC, " +;
                " ISNULL(SBZP.BZ_QB     ,SB1P.B1_QB)      B1_QB "
   Else
      cQuery += " SB1C.B1_FILIAL BC_FILIAL, " +;
                " SB1C.B1_COD BC_COD, " +;
                " SB1C.B1_FANTASM BC_FANTASM, " +;
                " SB1C.B1_EMIN BC_EMIN, " +;
                " SB1P.B1_FILIAL B1_FILIAL, " +;
                " SB1P.B1_COD B1_COD, " +;
                " SB1P.B1_OPC B1_OPC, " +;
                " SB1P.B1_QB B1_QB "
   EndIf

   If cDadosProd == "SBZ"
      cQuery += " FROM " + RetSqlName("SG1") + " SG1, " +; //estrutura
                           RetSqlName("SB1") + " SB1C " +; //produto linkado com o componente
                           " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZC " +;
                           "   ON SBZC.BZ_FILIAL  = '" + xFilial("SBZ") + "' " +;
                           "  AND SBZC.D_E_L_E_T_ = ' ' " +;
                           "  AND SBZC.BZ_COD     = SB1C.B1_COD, " +;
                           RetSqlName("SB1") + " SB1P " +; //produto linkado com o pai
                           " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZP " +;
                           "   ON SBZP.BZ_FILIAL = '" + xFilial("SBZ") + "' " +;
                           "  AND SBZP.D_E_L_E_T_ = ' ' " +;
                           "  AND SBZP.BZ_COD    = SB1P.B1_COD "
   Else
      cQuery += " FROM " + RetSqlName("SG1") + " SG1, "  +;//estrutura
                           RetSqlName("SB1") + " SB1C, " +;//produto linkado com o componente
                           RetSqlName("SB1") + " SB1P "    //produto linkado com o pai
   EndIf

   cQuery +=  " WHERE SG1.G1_FILIAL   = '" + xFilial("SG1") + "' " +;
                " AND SB1C.B1_FILIAL  = '" + xFilial("SB1") + "' " +;
                " AND SB1P.B1_FILIAL  = '" + xFilial("SB1") + "' " +;
                " AND SG1.G1_COMP     = SB1C.B1_COD " +;
                " AND SG1.G1_COD      = SB1P.B1_COD " +;
                " AND SG1.G1_COD      = '" + cProduto + "' " +;
                " AND SB1C.B1_MRP     = 'S' " +;
                " AND SB1P.B1_MSBLQL  <> '1' "+;
      			    " AND SB1C.B1_MSBLQL  <> '1' "+;
                " AND SG1.D_E_L_E_T_  = ' ' " +;
                " AND SB1C.D_E_L_E_T_ = ' ' " +;
                " AND SB1P.D_E_L_E_T_ = ' ' "

   //Filtra os tipos
   If !lAllTp
      cQuery += " AND SB1C.B1_TIPO IN (SELECT TP_TIPO FROM SOQTTP) "
   EndIf

   //Filtro os grupos
   If !lAllGrp .And. lMRPCINQ
      cQuery += " AND SB1C.B1_GRUPO IN (SELECT GR_GRUPO FROM SOQTGR) "
   End If

   cQuery += " ORDER BY " + SqlOrder(SG1->(IndexKey(1)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSG1,.T.,.T.)
   dbSelectArea(cAliasSG1)

   While !Eof()
      aAdd(aDados,{(cAliasSG1)->(G1_FILIAL),;
                   (cAliasSG1)->(G1_COD),;
                   (cAliasSG1)->(G1_COMP),;
                   (cAliasSG1)->(G1_POTENCI),;
                   (cAliasSG1)->(G1_GROPC),;
                   (cAliasSG1)->(G1_OPC),;
                   (cAliasSG1)->(G1_INI),;
                   (cAliasSG1)->(G1_FIM),;
                   (cAliasSG1)->(G1_PERDA),;
                   (cAliasSG1)->(G1_FIXVAR),;
                   (cAliasSG1)->(G1_TRT),;
                   (cAliasSG1)->(G1_REVINI),;
                   (cAliasSG1)->(G1_REVFIM),;
                   (cAliasSG1)->(G1_QUANT),;
                   IIF(lPCPREVATU , PCPREVATU((cAliasSG1)->BC_COD), (cAliasSG1)->BC_REVATU),;
                   (cAliasSG1)->(BC_TIPODEC),;
                   IIF(lPCPREVATU , PCPREVATU((cAliasSG1)->B1_COD), (cAliasSG1)->B1_REVATU),;
                   (cAliasSG1)->(B1_QBP),;
                   (cAliasSG1)->(BC_FILIAL),;
                   (cAliasSG1)->(BC_COD),;
                   (cAliasSG1)->(BC_FANTASM),;
                   (cAliasSG1)->(BC_EMIN),;
                   (cAliasSG1)->(B1_FILIAL),;
                   (cAliasSG1)->(B1_COD),;
                   (cAliasSG1)->(B1_OPC),;
                   (cAliasSG1)->(B1_QB),;
                   (cAliasSG1)->(B1_FILIAL),;
                   (cAliasSG1)->(B1_COD),;
                   (cAliasSG1)->(B1_OPC),;
                   (cAliasSG1)->(B1_QB)})
      (cAliasSG1)->(dbSkip())
   End
   (cAliasSG1)->(dbCloseArea())
   cAliasSG1 := Nil
   cAliasSB1 := Nil
      
   For nI := 1 To Len(aDados)
      cAliasSG1 := GetNextAlias()
      cAliasSB1 := cAliasSG1

      cQuery := " SELECT SG1.G1_FILIAL, " +;
                       " SG1.G1_COD, " +;
                       " SG1.G1_COMP, " +;
                       " SG1.G1_POTENCI, " +;
                       " SG1.G1_GROPC, " +;
                       " SG1.G1_OPC, " +;
                       " SG1.G1_INI, " +;
                       " SG1.G1_FIM, " +;
                       " SG1.G1_PERDA, " +;
                       " SG1.G1_FIXVAR, " +;
                       " SG1.G1_TRT, " +;
                       " SG1.G1_REVINI, " +;
                       " SG1.G1_REVFIM, " +;
                       " SG1.G1_QUANT, " +;
                       " SB1C.B1_REVATU BC_REVATU, " +;
                       " SB1C.B1_TIPODEC BC_TIPODEC, " +;
                       " SB1P.B1_REVATU B1_REVATU, " +;
                       " SB1P.B1_QBP B1_QBP, "

      If cDadosProd == "SBZ"
         cQuery += " ISNULL(SBZC.BZ_FILIAL ,SB1C.B1_FILIAL)  BC_FILIAL, " +;
                   " ISNULL(SBZC.BZ_COD    ,SB1C.B1_COD)     BC_COD, " +;
                   " ISNULL(SBZC.BZ_FANTASM,SB1C.B1_FANTASM) BC_FANTASM, " +;
                   " ISNULL(SBZC.BZ_EMIN   ,SB1C.B1_EMIN)    BC_EMIN, " +;
                   " ISNULL(SBZP.BZ_FILIAL ,SB1P.B1_FILIAL)  B1_FILIAL, " +;
                   " ISNULL(SBZP.BZ_COD    ,SB1P.B1_COD)     B1_COD, " +;
                   " ISNULL(SBZP.BZ_OPC    ,SB1P.B1_OPC)     B1_OPC, " +;
                   " ISNULL(SBZP.BZ_QB     ,SB1P.B1_QB)      B1_QB "
                    
                    If lCpRevSBZ
                    cQuery +=  ", ISNULL(SBZC.BZ_REVATU,SB1C.B1_REVATU  )BC_REVATU, "+;
                               " ISNULL(SBZP.BZ_REVATU,SB1C.B1_REVATU )BZ_REVATU "
                   ENDIF
                   
      Else
         cQuery += " SB1C.B1_FILIAL BC_FILIAL, " +;
                   " SB1C.B1_COD BC_COD, " +;
                   " SB1C.B1_FANTASM BC_FANTASM, " +;
                   " SB1C.B1_EMIN BC_EMIN, " +;
                   " SB1P.B1_FILIAL B1_FILIAL, " +;
                   " SB1P.B1_COD B1_COD, " +;
                   " SB1P.B1_OPC B1_OPC, " +;
                   " SB1P.B1_QB B1_QB "
      EndIf

      If cDadosProd == "SBZ"
         cQuery += " FROM " + RetSqlName("SG1") + " SG1, " +; //estrutura
                              RetSqlName("SB1") + " SB1C " +; //produto linkado com o componente
                              " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZC " +;
                              "   ON SBZC.BZ_FILIAL = '" + xFilial("SBZ") + "' " +;
                              "  AND SBZC.D_E_L_E_T_ = ' ' " +;
                              "  AND SBZC.BZ_COD    = SB1C.B1_COD, " +;
                              RetSqlName("SB1") + " SB1P " +; //produto linkado com o pai
                              " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZP " +;
                              "   ON SBZP.BZ_FILIAL = '" + xFilial("SBZ") + "' " +;
                              "  AND SBZP.D_E_L_E_T_ = ' ' " +;
                              "  AND SBZP.BZ_COD    = SB1P.B1_COD "
      Else
         cQuery += " FROM " + RetSqlName("SG1") + " SG1, "  +;//estrutura
                              RetSqlName("SB1") + " SB1C, " +;//produto linkado com o componente
                              RetSqlName("SB1") + " SB1P "    //produto linkado com o pai
      EndIf

      cQuery +=  " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
      cQuery +=    " AND SB1C.B1_FILIAL = '" + xFilial("SB1") + "' "
      cQuery +=    " AND SB1P.B1_FILIAL = '" + xFilial("SB1") + "' "
      cQuery +=    " AND SG1.G1_COMP    = SB1C.B1_COD "
      cQuery +=    " AND SG1.G1_COD     = SB1P.B1_COD "
      cQuery +=    " AND SG1.G1_COD     = '" + cProduto + "' "
      cQuery +=    " AND SB1C.B1_MRP    = 'S' "
      cQuery +=    " AND SG1.D_E_L_E_T_ = ' ' "
      cQuery +=    " AND SG1.G1_FILIAL   = '" + aDados[nI,G1FILIAL]  + "' "
      cQuery +=    " AND SG1.G1_COD      = '" + aDados[nI,G1COD]     + "' "
      cQuery +=    " AND SG1.G1_COMP     = '" + aDados[nI,G1COMP]    + "' "
      cQuery +=    " AND SG1.G1_POTENCI  = "  + Str(aDados[nI,G1POTENCI])
      cQuery +=    " AND SG1.G1_GROPC    = '" + aDados[nI,G1GROPC]   + "' "
      cQuery +=    " AND SG1.G1_OPC      = '" + aDados[nI,G1OPC]     + "' "
      cQuery +=    " AND SG1.G1_INI      = '" + aDados[nI,G1INI]     + "' "
      cQuery +=    " AND SG1.G1_FIM      = '" + aDados[nI,G1FIM]     + "' "
      cQuery +=    " AND SG1.G1_PERDA    = "  + Str(aDados[nI,G1PERDA])
      cQuery +=    " AND SG1.G1_FIXVAR   = '" + aDados[nI,G1FIXVAR]  + "' "
      cQuery +=    " AND SG1.G1_TRT      = '" + aDados[nI,G1TRT]     + "' "
      cQuery +=    " AND SG1.G1_REVINI   = '" + aDados[nI,G1REVINI]  + "' "
      cQuery +=    " AND SG1.G1_REVFIM   = '" + aDados[nI,G1REVFIM]  + "' "
      cQuery +=    " AND SG1.G1_QUANT    = "  + Str(aDados[nI,G1QUANT])
      
      IF lPCPREVATU .AND. lCpRevSBZ // CONTROLA REVISAO 
      cQuery += " AND (SBZC.BZ_REVATU     = '" + aDados[nI,BCREVATU]      + "' "
      cQuery +=  " OR  SBZC.BZ_REVATU     IS NULL AND SB1C.B1_REVATU      = '" + aDados[nI,BCREVATU]       + "') "

      cQuery += " AND (SBZP.BZ_REVATU    = '" + aDados[nI,B1REVATU]       + "' "
      cQuery +=  " OR  SBZP.BZ_REVATU    IS NULL AND SB1P.B1_REVATU      = '" + aDados[nI,B1REVATU]        + "') "
      Else
        cQuery +=    " AND SB1C.B1_REVATU  = '" + aDados[nI,BCREVATU]  + "' "
        cQuery +=    " AND SB1P.B1_REVATU  = '" + aDados[nI,B1REVATU]  + "' "
      ENDIF
      cQuery +=    " AND SB1C.B1_TIPODEC = '" + aDados[nI,BCTIPODEC] + "' "
      cQuery +=    " AND SB1P.B1_QBP     = '" + Str(aDados[nI,B1QBP]) + "' "
      cQuery +=    " AND SB1P.D_E_L_E_T_ = ' ' "
      cQuery +=    " AND SB1C.D_E_L_E_T_ = ' ' "
      If cDadosProd == "SBZ"
         cQuery += " AND (SBZC.BZ_FILIAL  = '" + aDados[nI,BCFILIAL]  + "' "
         cQuery +=  " OR  SBZC.BZ_FILIAL  IS NULL AND SB1C.B1_FILIAL  = '" + aDados[nI,BCFILIAL]   + "') "
         cQuery += " AND (SBZC.BZ_COD     = '" + aDados[nI,BCCOD]     + "' "
         cQuery +=  " OR  SBZC.BZ_COD     IS NULL AND SB1C.B1_COD     = '" + aDados[nI,BCCOD]      + "') "
         cQuery += " AND (SBZC.BZ_FANTASM = '" + aDados[nI,BCFANTASM] + "' "
         cQuery +=  " OR  SBZC.BZ_FANTASM IS NULL AND SB1C.B1_FANTASM = '" + aDados[nI,BCFANTASM]  + "') "
         cQuery += " AND (SBZC.BZ_EMIN    = '" + Str(aDados[nI,BCEMIN]) + "' "
         cQuery +=  " OR  SBZC.BZ_EMIN    IS NULL AND SB1C.B1_EMIN    = '" + Str(aDados[nI,BCEMIN]) + "') "
         cQuery += " AND (SBZP.BZ_FILIAL  = '" + aDados[nI,B1FILIAL]  + "' "
         cQuery +=  " OR  SBZP.BZ_FILIAL  IS NULL AND SB1P.B1_FILIAL  = '" + aDados[nI,B1FILIAL]   + "') "
         cQuery += " AND (SBZP.BZ_COD     = '" + aDados[nI,B1COD]     + "' "
         cQuery +=  " OR  SBZP.BZ_COD     IS NULL AND SB1P.B1_COD     = '" + aDados[nI,B1COD]      + "') "
         cQuery += " AND (SBZP.BZ_OPC     = '" + aDados[nI,B1OPC]     + "' "
         cQuery +=  " OR  SBZP.BZ_OPC     IS NULL AND SB1P.B1_OPC     = '" + aDados[nI,B1OPC]      + "') "
         cQuery += " AND (SBZP.BZ_QB      = '" + Str(aDados[nI,B1QB]) + "' "
         cQuery +=  " OR  SBZP.BZ_QB      IS NULL AND SB1P.B1_QB      = '" + Str(aDados[nI,B1QB])       + "') "
      Else
         cQuery += " AND SB1C.B1_FILIAL  = '" + aDados[nI,BCFILIAL]  + "' "
         cQuery += " AND SB1C.B1_COD     = '" + aDados[nI,BCCOD]     + "' "
         cQuery += " AND SB1C.B1_FANTASM = '" + aDados[nI,BCFANTASM] + "' "
         cQuery += " AND SB1C.B1_EMIN    = '" + Str(aDados[nI,BCEMIN]) + "' "
         cQuery += " AND SB1P.B1_FILIAL  = '" + aDados[nI,B1FILIAL]  + "' "
         cQuery += " AND SB1P.B1_COD     = '" + aDados[nI,B1COD]     + "' "
         cQuery += " AND SB1P.B1_OPC     = '" + aDados[nI,B1OPC]     + "' "
         cQuery += " AND SB1P.B1_QB      = '" + Str(aDados[nI,B1QB]) + "' "
      EndIf

      //Filtra os tipos
      If !lAllTp
         cQuery += " AND SB1C.B1_TIPO IN (SELECT TP_TIPO FROM SOQTTP) "
      EndIf

      //Filtro os grupos
      If !lAllGrp .And. lMRPCINQ
         cQuery += " AND SB1C.B1_GRUPO IN (SELECT GR_GRUPO FROM SOQTGR) "
      End If

      cQuery += " ORDER BY " + SqlOrder(SG1->(IndexKey(1)))
      cQuery := ChangeQuery(cQuery)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSG1,.T.,.T.)
      dbSelectArea(cAliasSG1)
      lAchou := .T.

      mOpc := ""
      If Len(aOpc) > 0
         If Empty((mOpc := Array2Str(aOpc,.F.))) 
            mOpc := ""
         EndIf
      EndIf

      dbSelectArea("SG1")
      If dbSeek(xFilial("SG1")+aDados[nI,G1COMP])
         cTipoEst := "F"
         cNivel   := SG1->G1_NIV
      Else
         cTipoEst := "C"
         cNivel   := "99"
      EndIf
      
      If !Empty(mOpc) .And. !Empty(cProduto)
         cGrupos := A107EstOpc(cProduto,MontaOpc(mOpc),Nil,Nil,cStrTipo,cStrGrupo)
         cOpcionais := IIf(Empty(cGrupos),"",A107AvlOpc(MontaOpc(mOpc,cProduto,Iif(nNivExpl==0,cNivel,nNivExpl)),cGrupos))
      EndIf 

      //Calcula quantidade
      nQuantItem := ExplEstr(nQuant,dDataNes-nPrazoEnt,cOpcionais,cRevisao,/*05*/,/*06*/,/*07*/,cAliasSG1,cAliasSB1,.T.)
      //Calcula decimais
      Do Case
         Case (aDados[nI,BCTIPODEC] == "A")
            nQuantItem := Round(nQuantItem,0)
         Case (aDados[nI,BCTIPODEC] == "I")
            nQuantItem := Int(nQuantItem) + If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
         Case (aDados[nI,BCTIPODEC] == "T")
            nQuantItem := Int(nQuantItem)
      EndCase
      If (QtdComp(nQuantItem) == QtdComp(0))
         dbSkip()
         (cAliasSg1)->(dbCloseArea())
         Loop
      EndIf
      lCompNeg := QtdComp(nQuantItem,.T.) < QtdComp(0,.T.)
      //Calcula potencia
      If !Empty(aDados[nI,G1POTENCI]) .And. PotencLote(aDados[nI,G1COMP]) .And. QtdComp(nQuantItem) > QtdComp(0)
         nQuantItem := nQuantItem * (aDados[nI,G1POTENCI]/100)
      EndIf

      aAdd(aCompon,{aDados[nI,G1COMP],nQuantItem})
      If aDados[nI,BCFANTASM] == "S" .Or. (cTipoEst == "F" .And. !lGeraPI)
         If lPEMT710EXP
            lMT710EXP := ExecBlock("MT710EXP",.F.,.F.,{aDados[nI,G1COMP],cOpcionais,cRevisao,nQuantItem})
            If ValType(lMT710EXP) # "L"
               lMT710EXP := .T.
            EndIf
         EndIf

         If lMT710EXP
            A107ExplEs(aDados[nI,G1COMP],cOpcionais,cRevisao,nQuantItem,A650DtoPer(SomaPrazo(dDataNes,-nPrazoEnt)),cStrTipo,cStrGrupo,/*08*/,.T.,lCalcula,lExpRec,,aDados[nI,G1COD],nNivExpl + 1)
         EndIf
      ElseIf QtdComp(nQuantItem,.T.) # QtdComp(0,.T.)
         //Ponto de Entrada M710QTDE - Necessidade do Produto
         If lM710Qtde
            nQtdRet := ExecBlock( "M710QTDE", .F., .F., {cProduto, nQuantItem, dDataNes} )
            If ValType(nQtdRet) == "N"
               nQuantItem := nQtdRet
            EndIf
         EndIf

         If !verPontPed(aDados[nI,G1COMP])
            aDados[nI,BCEMIN] := 0
         EndIf
         //Avalia saldo do componente para verificar alternativos
         nSaldoMP := A107SldSOT(aDados[nI,G1COMP],cPeriodo,Space(Len(aDados[nI,G1GROPC]+aDados[nI,G1OPC])),aDados[nI,B1REVATU],cNivel,aDados[nI,BCEMIN],lRecalc)
         nQtUsada := verSldMrp(aDados[nI,G1COMP], cPeriodo,cEmpAnt,cFilAnt,.F.)
         nSaldoMp -= nQtUsada
         nSaldoMp -= (Iif(aDados[nI,BCEMIN]<>0,aDados[nI,BCEMIN]+1,0))
         //Verifica estoque de segurança
         If aPergs711[26] == 3
            nEstSeg := buscaEstSeg(aDados[nI,G1COMP],aEmpresas)
            nSaldoMp -= nEstSeg
         EndIf
         If nSaldoMp > 0
            cPerSld := A650DtoPer(SomaPrazo(dDataNes,-nPrazoEnt),,,aDados[nI,G1COMP],Iif(nSaldoMp>nQuantItem,nQuantItem,nSaldoMp))
            insSldMrp(aDados[nI,G1COMP], cPerSld, Iif(nSaldoMp>nQuantItem,nQuantItem,nSaldoMp),cEmpAnt,cFilAnt)
         Else
            nSaldoMp := 0
         EndIf
         
         cRelac := Nil
         //Gera SOQ para uso do saldo (seja parcial ou integral)
         If (lCompNeg .Or. (nQuantItem > 0 .And. nSaldoMP > 0))
            //Quantidade a gerar no SOQ
            nQuantParc := If(lCompNeg,nQuantItem,Min(nSaldoMP,nQuantItem))

            //Gera log MRP e SH5
            A107CriaLOG("004",aDados[nI,G1COMP],{aDados[nI,G1COD],nQuantParc,SomaPrazo(dDataNes,-nPrazoEnt)},lLogMRP,c711NumMrp)
            lRecalcPer := lCalcula
            If lCalcula
               aRetEmp := verItProd(aDados[nI,G1COMP])
               If (aRetEmp[1] != Nil .And. aRetEmp[2] != Nil) .And.;
                  (AllTrim(aRetEmp[1]) != AllTrim(cEmpAnt) .Or. AllTrim(aRetEmp[2]) != AllTrim(cFilAnt))
                  If nSaldoMp < nQuantItem
                     lRecalcPer := .F.
                  EndIf
               EndIf
            EndIf
            cRelac := cValToChar(nRecZero)
            A107CriSOQ(SomaPrazo(dDataNes,-nPrazoEnt),aDados[nI,G1COMP],/*03*/,cRevisao,If(lCompNeg,"ENG","SOR"),0,Iif(cProdFan != Nil,cProdFan,aDados[nI,G1COD]),/*08*/,cRelac,ABS(nQuantParc),If(lCompNeg,"2","4"),.F.,/*13*/,/*14*/,lRecalcPer,.T.,/*17*/,/*18*/,/*19*/,cParStrTipo,cParStrGrupo,nPrazoEnt,/*23*/,aOpc,cOpcionais,cNivel,/*27*/,aEmpresas)
            //Avalia se o produto eh utilizado na tabela SGI como original ou alternativo
            If A107ExSGI(aDados[nI,G1COMP])
               // Avalia se o produto não foi utilizado como alternativo em data futura e troca
               A107AvSldA(aDados[nI,G1COMP],cPeriodo,cRev711Vaz,cParStrTipo,cParStrGrupo,SomaPrazo(dDataNes,-nPrazoEnt),.F.)
            EndIf
         EndIf

         //Se nao componente negativo e ficou saldo a gerar na SH5, tenta usar componentes
         If !lCompNeg .And. nSaldoMP < nQuantItem
            //Quantidade a procurar os alternativos
            nQuantParc := nQuantItem - Max(nSaldoMP,0)
            If IsInCallStack("A107NesOP")
               lVerAllEmp := .T.
            Else
               lVerAllEmp := .F.
            EndIf
            //Avalia existencia de saldo e possivel utilizacao de alternativos (SGI)
            nQuantItem := A107VerAlt(aDados[nI,G1COMP],aDados[nI,G1COD],cPeriodo,nQuantParc,cParStrTipo,cParStrGrupo,cRev711Vaz,dDataNes,nPrazoEnt,cOpcionais,cAliasSG1,lRecalc,lVerAllEmp)

            //-- Gera Log MRP e SH5 da sobra (o que nao atendeu por alternativo)
            If nQuantItem > 0
               A107CriaLOG("004",aDados[nI,G1COMP],{aDados[nI,G1COMP],nQuantItem,SomaPrazo(dDataNes,-nPrazoEnt)},lLogMRP,c711NumMrp)
               lRecalcPer := lCalcula
               If lCalcula
                  aRetEmp := verItProd(aDados[nI,G1COMP])
                  If (aRetEmp[1] != Nil .And. aRetEmp[2] != Nil) .And.;
                     (AllTrim(aRetEmp[1]) != AllTrim(cEmpAnt) .Or. AllTrim(aRetEmp[2]) != AllTrim(cFilAnt))
                     If lFRecal
                        lRecalcPer := .T.
                     Else
                        lRecalcPer := .F.
                     EndIf
                  EndIf
               EndIf
               If IsInCallStack("a107NesOP")
                  nSldGeral := a107SldSum(aDados[nI,G1COMP],cPeriodo,.F.)
               EndIf
               
               A107CriSOQ(SomaPrazo(dDataNes,-nPrazoEnt),aDados[nI,G1COMP],/*(cAliasSG1)->(G1_GROPC+G1_OPC)03*/,cRevisao,"SOR",0,Iif(cProdFan != Nil,cProdFan,aDados[nI,G1COD]),/*08*/,cRelac,nQuantItem,"4",.F.,/*13*/,/*14*/,lRecalcPer,.T.,/*17*/,/*18*/,/*19*/,cParStrTipo,cParStrGrupo,nPrazoEnt,/*23*/,aOpc,/*(IIF(Len((cAliasSG1)->(G1_GROPC+G1_OPC)) > 0," ",*/cOpcionais/*))*/,cNivel,/*27*/,aEmpresas)
               
               If nSldGeral > 0 .And. IsInCallStack("a107NesOP")
                  dbSelectArea("SOR")
                  SOR->(dbSetOrder(1))
                  SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+aDados[nI,G1COMP]))
                  nRecSor := SOR->(Recno())
                  
                  dbSelectArea("SOT")
                  SOT->(dbSetOrder(1))
                  SOT->(dbSeek(xFilial("SOT")+STR(nRecSor,10,0)+cPeriodo))
                  nRecSot := SOT->(Recno())
                  nQtdTran := A107TraPrd(cEmpAnt, cFilAnt, aDados[nI,G1COMP], Iif(nQuantItem>nSldGeral,nSldGeral,nQuantItem), cPeriodo, nRecSot,.T.)
                  nQuantItem := nQuantItem - nQtdTran
               EndIf
            EndIf
            If lExpRec
               lExplode := .T.
               nSldGeral := a107SldSum(aDados[nI,G1COMP],cPeriodo,.F.)
               nQtUsada  := verSldMrp(aDados[nI,G1COMP],cPeriodo,cEmpAnt,cFilAnt,.F.)
               If nSldGeral < 0
                  lExplode := .T.
               Else
                  If nSldGeral - nQtUsada >= nQuantItem
                     lExplode := .F.
                     If IsInCallStack("a107NesOP") .And. nQuantItem > 0
                     	dbSelectArea("SOR")
                        SOR->(dbSetOrder(1))
                        SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+aDados[nI,G1COMP]))
                        nRecSor := SOR->(Recno())
                        
                        dbSelectArea("SOT")
                        SOT->(dbSetOrder(1))
                        SOT->(dbSeek(xFilial("SOT")+STR(nRecSor,10,0)+cPeriodo))
                        nRecSot := SOT->(Recno())
                        A107TraPrd(cEmpAnt, cFilAnt, aDados[nI,G1COMP], nQuantItem, cPeriodo, nRecSot,.T.)
                     EndIf
                  EndIf
               EndIf
               If lExplode
                  A107ExplEs(aDados[nI,G1COMP],cOpcionais,cRevisao,nQuantItem,A650DtoPer(SomaPrazo(dDataNes,-nPrazoEnt)),cStrTipo,cStrGrupo,/*08*/,.T.,lCalcula,lExpRec,,,nNivExpl +1)
               EndIf
            EndIf
         EndIf
      EndIf
      If cAliasSg1 != Nil .And. Select(cAliasSg1) > 0
         (cAliasSg1)->(dbCloseArea())
         cAliasSg1 := Nil
         cAliasSb1 := Nil
      EndIf
   Next nI

   //Se não achou estrutura, faz a busca nas outras empresas para fazer a explosão
   If lAchou == .F. .And. lExpRec
      aRetEmp := verItProd(cProduto)
      If aRetEmp[1] != Nil .And. aRetEmp[2] != Nil .And. AllTrim(cEmpAnt) != AllTrim(aRetEmp[1]) .And. AllTrim(cFilAnt) != AllTrim(aRetEmp[2])
         If RetFldProd(cProduto,"B1_FANTASM") # "S"
            dbSelectArea("SOR")
            SOR->(dbSetOrder(1))
            SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto))
            nRecSor := SOR->(Recno())

            dbSelectArea("SOT")
            SOT->(dbSetOrder(1))
            SOT->(dbSeek(xFilial("SOT")+STR(nRecSor,10,0)+cPeriodo))
            nRecSot := SOT->(Recno())
            lFantasma := .F.
         Else
            lFantasma := .T.
         EndIf

         If !lFantasma
            nSldGeral := a107SldSum(cProduto, cPeriodo,.F.)
            nQtUsada := verSldMrp(cProduto, cPeriodo,cEmpAnt,cFilAnt,.F.)
            nSldGeral := nSldGeral - nQtUsada

            nEstSeg   := 0
            nPontoPed := Nil
            nEstSeg   := 0

            //Verifica estoque de segurança
            If aPergs711[26] == 3
               nEstSeg := buscaEstSeg(cProduto,aEmpresas)
            EndIf

            //Verifica ponto de pedido
            If aPergs711[31] == 1
               If verPontPed(cProduto)
                  If Empty(nPontoPed)
                     SB1->(MsSeek(xFilial("SB1") + cProduto))
                     nPontoPed := RetFldProd(SB1->B1_COD,"B1_EMIN")
                  EndIf
                  If !Empty(nPontoPed)
                     nQtdPP := nPontoPed + 1
                  EndIf
               Else
                  nQtdPP    := 0
                  nPontoPed := Nil
               EndIf
            EndIf

            If !lRecalcPer
               nSldSOT := SOT->OT_QTSLES + SOT->OT_QTENTR - SOT->OT_QTSAID - SOT->OT_QTSEST - nQtdPP - nEstSeg
               nSaidTrans := 0
               nEntrTrans := 0
               nSotTran := SOT->(Recno())
               //Busca as saidas de transferência
               dbSelectArea("SOS")
               SOS->(dbSetOrder(2))
               If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nSotTran)),10)))
                  While SOS->OS_SOTORIG == nSotTran
                     nSaidTrans += SOS->OS_QUANT
                     SOS->(dbSkip())
                  EndDo
               EndIf

               //Busca as entradas de transferência
               dbSelectArea("SOS")
               SOS->(dbSetOrder(3))
               If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nSotTran)),10)))
                  While SOS->OS_SOTDEST == nSotTran
                     nEntrTrans += SOS->OS_QUANT
                     SOS->(dbSkip())
                  EndDo
               EndIf
               nSldSOT += nEntrTrans
               nSldSOT -= nSaidTrans
            Else
               nSldSOT := SOT->OT_QTSALD - nQtdPP - nEstSeg
            EndIf

            If nSldGeral > nSldSOT
               //Recalcula o produto, para garantir que os dados estão integros.
               A107Recalc(cProduto,cOpcionais,cRevisao,cPeriodo,nSldSOT,/*06*/,SOT->OT_RGSOR,/*08*/,aEmpresas)
               //Faz a transferência do saldo.
               nQtdTran := A107TraPrd(cEmpAnt, cFilAnt, cProduto, nSldSOT * -1, cPeriodo, nRecSot,.T.)
               nQuant -= nQtdTran
            EndIf
         EndIf
         If nQuant > 0
            dbSelectArea("SG1")
            nQuant := A711Lote(nQuant,cProduto)
            nLdTmTrans := 0

            dbSelectArea("SB5")
            SB5->(dbSetOrder(1))
            If SB5->(dbSeek(xFilial("SB5")+cProduto))
               nLdTmTrans := SB5->B5_LEADTR
            EndIf

            A107AltEmp(aRetEmp[1], aRetEmp[2])
            nSorDest := 0
            nSotDest := 0
            nSaldoIni:= 0
            If !lFantasma
               dbSelectArea("SOR")
               SOR->(dbSetOrder(1))
               If SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto))
                  nSorDest := SOR->(Recno())

                  dbSelectArea("SOT")
                  SOT->(dbSetOrder(1))
                  If SOT->(dbSeek(xFilial("SOT")+STR(nSorDest,10,0)+cPeriodo))
                     nSotDest := SOT->(Recno())
                     nSaldoIni:= SOT->OT_QTSLES
                  EndIf
               EndIf
               A107CriSOR(cProduto,cOpcionais,cRevisao,/*04*/,cPeriodo,nQuant,"4","SG1",.T.,cParStrTipo,cParStrGrupo,.F.,/*13*/,nRecSot,nSaldoIni,,,.T.,aEmpresas)
               nSaldoIni := 0
            EndIf
            aRet := A107ExplEs(cProduto,cOpcionais,cRevisao,nQuant,cPeriodo,cParStrTipo,cParStrGrupo,aOpc,lRecalc,lCalcula,lExpRec,,,nNivExpl + 1)
            If !lFantasma .And. (nSorDest == 0 .Or. nSotDest == 0)
               dbSelectArea("SOR")
               SOR->(dbSetOrder(1))
               SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto))
               nSorDest := SOR->(Recno())

               dbSelectArea("SOT")
               SOT->(dbSetOrder(1))
               SOT->(dbSeek(xFilial("SOT")+STR(nSorDest,10,0)+cPeriodo))
               nSotDest := SOT->(Recno())
            EndIf

            A107AltEmp(cEmpresa, cFili)

            If !lFantasma
               SOT->(dbGoTo(nRecSot))
               Reclock("SOT",.F.)
               SOT->OT_QTTRAN := SOT->OT_QTTRAN + nQuant
               MsUnlock()
               a107CriSOV(SOT->(Recno()),nQuant,cProduto,"S")
               nSaldoIni := SOT->(OT_QTSLES)
               A107Recalc(cProduto,cOpcionais,cRevisao,cPeriodo,nSaldoIni,/*06*/,SOT->OT_RGSOR,/*08*/,aEmpresas)
            Else
               //Se o item pai for fantasma, gera a SOT dos componentes para receber a transferência (SOU).
               For nI := 1 To Len(aRet)
                  lExiste := .F.
                  dbSelectArea("SOR")
                  SOR->(dbSetOrder(1))
                  If SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+aRet[nI,1]))
                     lExiste := .T.
                  EndIf

                  A107CriSOR(aRet[nI,1],cOpcionais,cRevisao,/*04*/,cPeriodo,aRet[nI,2],"7","SG1",.T.,cParStrTipo,cParStrGrupo,.F.,/*13*/,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)

                  dbSelectArea("SOR")
                  SOR->(dbSetOrder(1))
                  SOR->(dbSeek(xFilial("SOR")+aRetEmp[1]+PadR(aRetEmp[2],nTamFil)+aRet[nI,1]))
                  nRecSor := SOR->(Recno())

                  dbSelectArea("SOT")
                  SOT->(dbSetOrder(1))
                  SOT->(dbSeek(xFilial("SOT")+STR(nRecSor,10,0)+cPeriodo))
                  nRecSot := SOT->(Recno())
                  nSaldoIni := SOT->OT_QTSALD
                  RecLock("SOT",.F.)
                     SOT->OT_QTTRAN += (aRet[nI,2]*-1)
                     SOT->OT_QTSEST -= aRet[nI,2]
                  MsUnLock()

                  //A107Recalc(aRet[nI,1],cOpcionais,cRevisao,cPeriodo,nSaldoIni,/*06*/,nRecSor,/*08*/,aEmpresas)

                  dbSelectArea("SOR")
                  SOR->(dbSetOrder(1))
                  SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+aRet[nI,1]))
                  nSorDest := SOR->(Recno())

                  dbSelectArea("SOT")
                  SOT->(dbSetOrder(1))
                  SOT->(dbSeek(xFilial("SOT")+STR(nSorDest,10,0)+cPeriodo))
                  nSotDest := SOT->(Recno())
                  If !lExiste
                     RecLock("SOT",.F.)
                        SOT->OT_QTNECE -= ABS(aRet[nI,2])
                        SOT->OT_QTSALD += ABS(aRet[nI,2])
                        SOT->OT_QTSEST += ABS(aRet[nI,2])
                     MsUnLock()
                  Else
                     RecLock("SOT",.F.)
                        SOT->OT_QTSEST += ABS(aRet[nI,2])
                     MsUnLock()
                  EndIf
                  insertSOS(nRecSot, nSotDest, aRet[nI,2], "2")
               Next nI
            EndIf
            cAliasSg1 := Nil
         EndIf
      EndIf
   EndIf
   If cAliasSg1 != Nil .And. Select(cAliasSg1) > 0
      (cAliasSg1)->(dbCloseArea())
   EndIf
EndIf

Return aCompon

/*------------------------------------------------------------------------//
//Programa: verItProd
//Autor:    Lucas Konrad França
//Data:     19/02/2015
//Descricao:   Retorna a empresa em que o produto é produzido.
//Parametros:  01.cProduto       - Codigo do produto a ser verificado
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function verItProd(cProduto)
Local aRet   := {}
Local cQuery := ""
Local aArea  := GetArea()
Local cAlias := GetNextAlias()

cQuery := " SELECT EMPRESA,FILIAL "
cQuery +=   " FROM ITPROD "
cQuery +=  " WHERE COD = '" + cProduto + "' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
dbSelectArea(cAlias)

IF !(cAlias)->(Eof())
   aAdd(aRet,(cAlias)->(EMPRESA))
   aAdd(aRet,(cAlias)->(FILIAL))
Else
   aAdd(aRet,Nil)
   aAdd(aRet,Nil)
EndIf

(cAlias)->(dbCloseArea())
RestArea(aArea)
Return aRet

/*------------------------------------------------------------------------//
//Programa: A107SldSOT
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Retorna o saldo de um produto em determinado periodo pela projecao do MRP
//Parametros:  01.cProduto       - Codigo do produto a ser explodido
//             02.cPeriodo       - Periodo da necessidade do produto
//             03.cOpc           - Lista de opcionais
//             04.cRevisao       - Revisão da estrutura do item
//             05.cNivel         - Nivel do item
//             06.nPontoPed      - Ponto de pedido
//             07.lRecalc        - Indica se vai recalcular as necessidades
//             08.cParEmp        - Empresa onde será verificado o saldo
//             09.cParFil        - Filial onde será verificado o saldo
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107SldSOT(cProduto,cPeriodo,cOpc,cRevisao,cNivel,nPontoPed,lRecalc,cParEmp,cParFil)
Local nRet      := 0
Local cSeek     := ""
Local aEmpresas := {}
Local nZ        := 0
Local nQtTrans  := 0
Local nTamFil   := TamSX3("OQ_FILEMP")[1]
Local cEmp      := cEmpAnt
Local cFil      := cFilAnt
Local aAreaSOQ  := SOQ->(GetArea())
Local aAreaSOR  := SOR->(GetArea())
Local aAreaSOT  := SOT->(GetArea())
Default lRecalc := .T.
Default cParEmp := cEmpAnt
Default cParFil := cFilAnt

aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nZ := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nZ,1],aEmpCent[nZ,2],aEmpCent[nZ,3]})
   EndIf
Next nZ

cRevisao := If(!Empty(cRevisao) .And. A107TrataRev(),cRevisao,CriaVar("B1_REVATU",.F.))
cOpc     := PadR(cOpc,Len(SOR->OR_OPCORD))

dbSelectArea("SOR")
dbSetOrder(3)
cSeek := xFilial("SOR")+cParEmp+PadR(cParFil,nTamFil)+cProduto+IIF(LEN(cOpc)>200,Substr(cOpc,1,200),cOpc)+cRevisao
dbSeek(cSeek)

If lRecalc
   cEmpAnt := cParEmp
   cFilAnt := cParFil
   //Recalcula saldo para garantir integridade
   A107Recalc(cProduto,cOpc,cRevisao,/*04*/,/*05*/,/*06*/,SOR->(RecNo()),nPontoPed,aEmpresas)
   cEmpAnt := cEmp
   cFilAnt := cFil
EndIf

SOT->(dbSetOrder(1))
cSeek := xFilial("SOT")+STR(SOR->(RecNo()),10,0)+cPeriodo

If !SOT->(dbSeek(cSeek))
   nRet := 0
Else
   If SOT->OT_QTTRAN < 0
      nQtTrans := ABS(SOT->OT_QTTRAN)
   EndIf
   nRet := (SOT->OT_QTSLES-nQtTrans) + SOT->OT_QTENTR - SOT->OT_QTSAID - SOT->OT_QTSEST
EndIf

SOQ->(RestArea(aAreaSOQ))
SOR->(RestArea(aAreaSOR))
SOT->(RestArea(aAreaSOT))

Return nRet

/*------------------------------------------------------------------------//
//Programa: A107Recalc
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Rotina para recalcular saldos e necessidades do produto
//Parametros:  01.cProduto       - Produto a ser recalculado
//             02.cOpc           - Opcional do produto a ser recalculado
//             03.cRevisao       - Revisao do produto relacionada ao movimento
//             04.cPeriodo       - Periodo inicial do recalculo
//             05.nNovoSalIni    - Novo saldo inicial do produto no periodo inicial
//             06.lInJob         - Indica se está em JOB
//             07.nRecNoSOQ      - Numero do registro na tabela do MRP
//             08.nPontoPed      - Ponto de pedido
//             09.aEmpresas      - Array com as empresas do processamento
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107Recalc(cProduto,cOpc,cRevisao,cPeriodo,nNovoSalIni,lInJob,nRecNoSOQ,nPontoPed,aEmpresas)
Local nEntrada       := 0
Local nSaida         := 0
Local nSaldoAtu      := 0
Local nNecessidade   := 0
Local nSaidaEstr     := 0
Local nEstSeg        := 0
Local nEstSegAux     := 0
Local nHFSALDO       := 0
Local nQtNece        := 0
Local nQtNeceBkp     := 0
Local nLotVnc        := 0
Local nTotSaida      := 0
Local nQtdPP         := 0  //CH TRAAXW
Local nQtdPPAux      := 0
Local nTamProd       := TamSX3("HF_PRODUTO")[1]
Local nQtUsada       := 0
Local nQuant         := 0
Local nSldAux        := 0
Local nSldBkp        := 0
Local nNesBkp        := 0
Local nSldGeral      := 0
Local w              := 0
Local cSeek          := ""
Local nQtdNec  := 0
Local nSldAtuBkp := 0
Local cQuery   := ""
Local cAliasNec := ""
Local nQtdCalc  := 0
Local cNivelEstr := "99"
Local aAreaSG1 := SG1->(GetArea())

Local nTamFil        := TamSX3("OQ_FILEMP")[1]

DEFAULT cPeriodo     := "001"
DEFAULT nNovoSalIni  := 0
DEFAULT lInJob       := .F.
DEFAULT nPontoPed    := 0
DEFAULT nRecNoSOQ    := 0

If Empty(nRecNoSOQ)
   dbSelectArea("SOR")
   dbSetOrder(1)
   dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto+cRevisao)
   nRecNoSOQ := SOR->(Recno())
EndIf

SG1->(dbSetOrder(1))
cNivelEstr := IIf (SG1->(dbSeek(xFilial("SG1")+cProduto)),SG1->G1_NIV,"99")
SG1->(RestArea(aAreaSG1))

nTotSaida := 0
//Verifica estoque de segurança
If aPergs711[26] == 3
   nEstSeg := buscaEstSeg(cProduto,aEmpresas)
   nEstSegAux := nEstSeg
EndIf

//Verifica ponto de pedido
If aPergs711[31] == 1
   If verPontPed(cProduto)
      If Empty(nPontoPed)
         SB1->(MsSeek(xFilial("SB1") + cProduto))
         nPontoPed := RetFldProd(SB1->B1_COD,"B1_EMIN")
      EndIf
      If !Empty(nPontoPed)
         //nPontoPed++            //CH TRAAXW
         nQtdPP := nPontoPed + 1  //CH TRAAXW
      EndIf
   Else
      nQtdPP := 0
      nPontoPed := 0
   EndIf
EndIf

nQtdPPAux := nQtdPP

If aPergs711[26] == 3 .Or. aPergs711[31] == 1
   If !A107VLOPC(cProduto, "", {}, "", "", , ,.F. , 1 )
      nQtdPP     := 0
      nPontoPed  := 0
      nQtdPPAux  := 0
      nEstSeg    := 0
      nEstSegAux := 0
   EndIf
EndIf

//Apos gravar registro recalcula todos periodos posteriores
For w := Val(cPeriodo) To Len(aPeriodos)
   nEntrada   := 0
   nSaida     := 0
   nSaidaEstr := 0
   nLotVnc    := A107LotVnc(cProduto,aPeriodos[w])
   nSaidTrans := 0
   nEntrTrans := 0
   nSldBkp    := 0
   nNesBkp    := 0
   nQtNeceBkp := 0
   nSldGeral  := 0
   nEstSeg    := nEstSegAux
   nQtdPP     := nQtdPPAux

   //Verifica o consumo dos lotes vencidos com o total de saídas do produto.
   If nLotVnc <= nTotSaida
      nTotSaida   -= nLotVnc
      nLotVnc  := 0
   Else
      nLotVnc  -= nTotSaida
      nTotSaida   := 0
   EndIf

   //Se o total do lote vencido foi maior que o saldo incial, zera
   If nLotVnc <= nNovoSalIni
      nNovoSalIni -= nLotVnc
   Else
      nNovoSalIni := 0
   EndIf

   dbSelectArea("SOT")
   dbSetOrder(1)

   cSeek := xFilial("SOT")+STR(nRecNoSOQ,10,0)+StrZero(w,3)
   dbSeek(cSeek)

   If !Eof()
      //Pega o valor do saldo inicial em estoque
      If w == 1 //Val(cPeriodo)
         nNovoSalIni := SOT->OT_QTSLES
      Else
         If Reclock("SOT",.F.,,,lInJob)
            SOT->OT_QTSLES := nNovoSalIni
            MsUnlock()
         EndIf
      EndIf

      nQtNeceBkp := SOT->OT_QTNECE

      //Obtem Entradas
      nEntrada += SOT->OT_QTENTR

      //Obtem Saidas
      nSaida += SOT->OT_QTSAID
      nTotSaida += nSaida

      //Obtem Saidas pela Estrutura
      nSaidaEstr += SOT->OT_QTSEST
      nTotSaida += nSaidaEstr

      //Obtem transferências
      /*
         Buscar na SOS as quantidades que está recebendo/enviando em transferências.
         Calcular a entrada/saida de transferência na 'nSaldoAtu'
      */
      nRecSOT := SOT->(Recno())
      //Busca as saidas de transferência
      dbSelectArea("SOS")
      SOS->(dbSetOrder(2))
      If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nRecSOT)),10)))
         While SOS->OS_SOTORIG == nRecSOT
            nSaidTrans += SOS->OS_QUANT
            SOS->(dbSkip())
         EndDo
      EndIf

      //Busca as entradas de transferência
      dbSelectArea("SOS")
      SOS->(dbSetOrder(3))
      If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nRecSOT)),10)))
         While SOS->OS_SOTDEST == nRecSOT
            nEntrTrans += SOS->OS_QUANT
            SOS->(dbSkip())
         EndDo
      EndIf

      nQtUsada := verSldMrp(cProduto, StrZero(w,3),cEmpAnt,cFilAnt,.F.)
      nSldAux  := nNovoSalIni - nQtUsada
      If nNovoSalIni >= 0 .And. nSldAux < 0
         nSldAux := 0
      EndIf
      //Se utilizou a quantidade do estoque de segurança ou do ponto de pedido
      //em um próximo período, desconsidera esses valores no período que está sendo calculado,
      //pois será calculado no período em que utilizou o saldo.
      /*If nQtUsada == nEstSeg
         nEstSeg := 0
      Else
         nEstSeg := nEstSegAux
      EndIf
      If nQtUsada == nQtdPPAux
         nQtdPP := 0
      Else
         nQtdPP := nQtdPPAux
      EndIf*/
      //Calcula Saldo Atual e Necessidade
      nSaldoAtu := nSldAux + nEntrada - nSaida - nSaidaEstr
      nSldBkp   := nNovoSalIni + nEntrada - nSaida - nSaidaEstr

      nSaldoAtu += nEntrTrans
      nSldBkp   += nEntrTrans
      nSaldoAtu -= nSaidTrans
      nSldBkp   -= nSaidTrans

      //Calcula necessidade
      nHFSALDO := nNovoSalIni

      If nEstSeg+nQtdPP == nSldBkp .And. verSldMrp(cProduto, StrZero(w,3),cEmpAnt,cFilAnt,.T.) == 0
         nSaldoAtu := nSldBkp
      EndIf
      //Calcula necessidade e saldo inicial do proximo periodo
      If QtdComp(nSaldoAtu - (nEstSeg + nQtdPP)) < QtdComp(0)  //CH TRAAXW
         If nSaidTrans > 0
            nNecessidade := A107Lote(ABS((nEstSeg+nQtdPP)- nSaldoAtu),cProduto)
            If nEstSeg > 0 .Or. nQtdPP > 0
               If nSaldoAtu > 0 .And. ABS((nEstSeg+nQtdPP)- nSaldoAtu) == nNecessidade
                  nNesBkp := nNecessidade
               Else
                  nNesBkp := A711Lote(ABS(nSaldoAtu),cProduto)
               EndIf
               If nNesBkp != nNecessidade
                  nSldGeral := a107SldSum(cProduto, StrZero(w,3),.F.)
                  nSldGeral := nSldGeral - nSaida - nSaidaEstr
                  If (nSldGeral - nQtUsada >= nEstSeg+nQtdPP .And. nSaldoAtu > 0) .Or. (nNesBkp-nSldBkp >= nEstSeg+nQtdPP .And. nSldBkp > 0)
                     nNecessidade := nNesBkp
                  EndIf
               EndIf
            EndIf
         Else
            nNecessidade := A711Lote(ABS((nEstSeg+nQtdPP)- nSaldoAtu),cProduto)
            If nEstSeg > 0 .Or. nQtdPP > 0
               If nSaldoAtu > 0 .And. ABS((nEstSeg+nQtdPP)- nSaldoAtu) == nNecessidade
                  nNesBkp := nNecessidade
               Else
                  nNesBkp := A711Lote(ABS(nSaldoAtu),cProduto)
               EndIf
               If nNesBkp != nNecessidade
                  nSldGeral := a107SldSum(cProduto, StrZero(w,3),.T.)
                  nSldGeral := nSldGeral - nSaida - nSaidaEstr
                  If (nSldGeral - nQtUsada >= nEstSeg+nQtdPP .And. nSaldoAtu > 0) .Or. (nNesBkp-nSldBkp >= nEstSeg+nQtdPP .And. nSldBkp > 0)
                     nNecessidade := nNesBkp
                  EndIf
               EndIf
            EndIf
         EndIf
         nNecessidade := A711NecMax(cProduto, nSaldoAtu, nNecessidade)
         If nEstSeg > 0 .Or. nQtdPP > 0
            nNesBkp   := A711NecMax(cProduto, nSaldoAtu, nNesBkp)
         EndIf
         nSaldoAtu := nSldBkp
         nNovoSalIni  := nNecessidade + nSaldoAtu
         
         If aPergs711[16] == 2 .And. !IsInCallStack("PCP107OPSC") .And. ;
            ((cNivelEstr == "99" .And. aPergs711[2] == 1) .Or. (cNivelEstr <> "99" .And. aPergs711[3] == 1))
            //Se estiver parametrizado para não aglutinar as ordens e gerar op/sc POR OP, calcula a qtd separada, 
            //por cada saída de estrutura, para considerar corretamente as políticas de estoque de acordo com as ops/scs que serão geradas.
            SOQ->(dbSetOrder(1))
            If SOQ->(dbSeek(xFilial("SOQ")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto+cRevisao+StrZero(w,3)+"4"))
               nNecessidade := 0
               nSldAtuBkp := nSaldoAtu
               
               nSaldoAtu += nSaida // Desconta as saídas, pois elas serão calculadas separadamente depois.
               
               cAliasNec := GetNextAlias()
               cQuery := " SELECT SUM(SOQ.OQ_QUANT) QTDSOQ, SOQ.OQ_DOC, SOQ.OQ_DOCKEY "
               cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ " 
               cQuery +=  " WHERE SOQ.OQ_FILIAL = '"+xFilial("SOQ")+"' "
               cQuery +=    " AND SOQ.OQ_EMP    = '"+cEmpAnt+"'"
               cQuery +=    " AND SOQ.OQ_FILEMP = '"+cFilAnt+"'"
               cQuery +=    " AND SOQ.OQ_PROD   = '"+cProduto+"' "
               cQuery +=    " AND SOQ.OQ_NRRV   = '"+cRevisao+"' "
               cQuery +=    " AND SOQ.OQ_PERMRP = '"+StrZero(w,3)+"' "
               cQuery +=    " AND SOQ.OQ_TPRG   = '4' "
               cQuery +=  " GROUP BY SOQ.OQ_DOC, SOQ.OQ_DOCKEY "

               cQuery := ChangeQuery(cQuery)

               dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNec,.T.,.T.)
               While (cAliasNec)->(!Eof())
                  nSaldoAtu += (cAliasNec)->(QTDSOQ)
                  //Se a necessidade atual calculada, menos o saldo anterior for maior que 0, é porquê a necessidade
                  //já atende todas as demandas do período, e não é mais necessário gerar saldos.
                  If nNecessidade-ABS(nSldAtuBkp) >= 0
                     (cAliasNec)->(dbSkip())
                     Loop
                  EndIf

                  nQtdCalc := (cAliasNec)->(QTDSOQ) - Iif(nSaldoAtu-(nEstSeg+nQtdPP)>0,nSaldoAtu-(nEstSeg+nQtdPP),0) 
                  If nQtdCalc < 0
                     nQtdCalc := 0
                  EndIf

                  nQtdNec := A711Lote(ABS(nQtdCalc),cProduto)  //CH TRAAXW
                  nQtdNec := A711NecMax(cProduto, ABS(nQtdCalc), nQtdNec)

                  nNecessidade += nQtdNec
                  (cAliasNec)->(dbSkip())
               End

               (cAliasNec)->(DbCloseArea())
               dbSelectArea("SOT")
               //Recalcula as quantidades que não são de saídas de estrutura.
               If nSaldoAtu >= (nEstSeg+nQtdPP)
                  nQtdNec := 0
               Else
                  nQtdNec := ABS((nEstSeg+nQtdPP)- nSaldoAtu)
               EndIf
               nSaldoAtu := nSldAtuBkp

               SOQ->(dbSeek(xFilial("SOQ")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto+cRevisao+StrZero(w,3)))
               While SOQ->(!Eof()) .And. ;
                     SOQ->(OQ_FILIAL+OQ_EMP+OQ_FILEMP+OQ_PROD+OQ_NRRV+OQ_PERMRP) == xFilial("SOQ")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto+cRevisao+StrZero(w,3)
                  If ! SOQ->OQ_TPRG $ " 1245"
                     nQtdNec += SOQ->OQ_QUANT
                  EndIf
                  SOQ->(dbSkip())
               End
               If nQtdNec != 0 .And. nNecessidade-ABS(nSaldoAtu) < 0
                  nQtdNec := A711Lote(nQtdNec,cProduto)  //CH TRAAXW
                  nNecessidade += nQtdNec
               EndIf
               nNovoSalIni := nNecessidade+nSaldoAtu
            EndIf
         EndIf
         
      Else
         nSaldoAtu := nSldBkp
         nNecessidade := 0
         nNovoSalIni  := nSaldoAtu
      EndIf

      If Reclock("SOT",.F.,,,lInJob)
         SOT->OT_QTSALD := nSaldoAtu
         SOT->OT_QTNECE := nNecessidade
         MsUnlock()
      EndIf

      //Se existia uma necessidade de estoque de segurança/ponto pedido
      //que foi suprida por um saldo em estoque, atualiza a tabela SOV
      If nQtNeceBkp > nNecessidade .And. (nEstSeg != 0 .Or. nQtdPP != 0) .And. !IsInCallStack("PCP107OPSC")
         nQuant := nQtNeceBkp - nNecessidade
         atuNeces(SOT->(Recno()),nQuant,"E")
      EndIf
      If nQtNeceBkp > nNecessidade .And. !IsInCallStack("PCP107OPSC") .And. lVerSldSOR
         nQuant := nQtNeceBkp - nNecessidade
         atuNeces(SOT->(Recno()),nQuant,"N")
      EndIf
   Else
      //Pega o valor do saldo inicial em estoque
      If w == 1
         nNovoSalIni := 0
      EndIf

      //Obtem Entradas
      nEntrada += 0

      //Obtem Saidas
      nSaida += 0
      nTotSaida += nSaida

      //Obtem Saidas pela Estrutura
      nSaidaEstr += 0
      nTotSaida += nSaidaEstr

      nQtUsada := verSldMrp(cProduto, StrZero(w,3),cEmpAnt,cFilAnt,.F.)
      nSldAux  := nNovoSalIni - nQtUsada
      If nNovoSalIni > 0 .And. nSldAux < 0
         nSldAux := 0
      EndIf

      //Calcula Saldo Atual e Necessidade
      nSaldoAtu := nNovoSalIni + nEntrada - nSaida - nSaidaEstr
      nSldBkp   := nSldAux + nEntrada - nSaida - nSaidaEstr

      //Calcula necessidade
      nHFSALDO := nNovoSalIni

      nNesBkp    := 0

      If QtdComp(nSaldoAtu - (nEstSeg + nQtdPP)) < QtdComp(0)  //CH TRAAXW
         nNecessidade := A711Lote(ABS((nEstSeg+nQtdPP)- nSaldoAtu),cProduto)  //CH TRAAXW
         nNecessidade := A711NecMax(cProduto, nSaldoAtu, nNecessidade)
         If nEstSeg > 0 .Or. nQtdPP > 0
            If nSaldoAtu > 0 .And. ABS((nEstSeg+nQtdPP)- nSaldoAtu) == nNecessidade
               nNesBkp := nNecessidade
            Else
               nNesBkp := A711Lote(ABS(nSaldoAtu),cProduto)
            EndIf
            nNesBkp   := A711NecMax(cProduto, nSaldoAtu, nNesBkp)
            If nNesBkp != nNecessidade
               nSldGeral := a107SldSum(cProduto, StrZero(w,3),.F.)
               nSldGeral := nSldGeral - nSaida - nSaidaEstr
               nQtUsada  := verSldMrp(cProduto, StrZero(w,3),cEmpAnt,cFilAnt,.F.)
               If (nSldGeral - nQtUsada >= nEstSeg+nQtdPP) .Or. (nNesBkp-nSldBkp >= nEstSeg+nQtdPP .And. nSldBkp > 0)
                  nNecessidade := nNesBkp
               EndIf
            EndIf
         EndIf
         nNovoSalIni := nNecessidade + nSaldoAtu
      Else
         nNecessidade:=0
         nNovoSalIni :=nSaldoAtu
      EndIf

      If Reclock("SOT",.T.,,,lInJob)
         SOT->OT_FILIAL  := xFilial("SOT")
         SOT->OT_NRMRP   := c711NumMRP
         SOT->OT_RGSOR   := nRecNoSOQ
         SOT->OT_PERMRP  := StrZero(w,3)
         SOT->OT_QTSLES  := nNovoSalIni
         SOT->OT_QTENTR  := nEntrada
         SOT->OT_QTSAID  := nSaida
         SOT->OT_QTSEST  := nSaidaEstr
         SOT->OT_QTSALD  := nSaldoAtu
         SOT->OT_QTNECE  := nNecessidade
         SOT->OT_QTTRAN  := 0

         MsUnlock()
      EndIf
   EndIf

   If (nEstSeg > 0 .Or. nQtdPP > 0) .And. nNesBkp != nNecessidade .And. nEstSeg+nQtdPP > nNovoSalIni
      nQtNece := ABS(ABS(nNesBkp) - ABS(nNecessidade))
      If !existNec(SOT->(Recno()),nQtNece,"E")
         a107CriSOV(SOT->(Recno()),nQtNece,cProduto,"E")
      EndIf
   EndIf

Next w

Return

/*------------------------------------------------------------------------//
//Programa: A107ExSGI
//Autor:    Anieli Rodrigues
//Data:     26/10/12
//Descricao:   Verifica se um produto existe como Produto Original
//          ou como Produto Alternativo na tabela SGI
//Parametros:  cProduto: codigo do produto a ser buscado na tabela
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107ExSGI(cProduto)
Local aArea       := GetArea()
Local lRet     := .F.
Local cQuery      := ""

//Avalia se o produto eh alternativo ou possui algum alternativo
cAlias := "AVALT"
cQuery := " SELECT COUNT(*) nCount " +;
            " FROM " + RetSqlName("SGI") + " SGI " +;
           " WHERE (SGI.GI_FILIAL  = '" + xFilial("SGI") + "') " +;
             " AND (SGI.GI_PRODORI = '" + cProduto + "' " +;
             "  OR  SGI.GI_PRODALT = '" + cProduto + "') " +;
             " AND SGI.D_E_L_E_T_  = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
If (cAlias)->nCount < 1
   lRet := .F.
Else
   lRet := .T.
EndIf

(cAlias)->(DbCloseArea())
RestArea(aArea)

Return lRet

/*------------------------------------------------------------------------//
//Programa: A107VerAlt
//Autor:    Ricardo Prandi
//Data:     01/10/2013
//Descricao:   Verifica se ha produtos alternativos para substituicao na
//          geracao de necessidades.
//Parametros:  01.cProd       - Codigo do produto a ser buscado na tabela
//          02.cProdPai       - Codigo do item pai
//          03.cPeriodo       - Número do periodo
//          04.nQuantItem     - Quantidade do item
//          05.cParStrTipo    - String de tipos do item
//          06.cParStrGrupo   - String de grupos do item
//          07.cRev711Vaz     - Revisão vazio
//          08.dDataNes       - Data da necessidade
//          09.nPrazoEnt      - Prazo de entrega
//          10.cOpcionais     - Opcionais
//          11.cAliasSG1      - Alias da SG1
//          12.lRecalc        - Indica se vai recalcular as necessidades
//          13.lVerAllEmp     - Indica se irá verificar todas as empresas
//          13.cParEmp        - Empresa que será verificado o saldo do alternativo
//          14.cParFil        - Filial que será verificado o saldo do alternativo
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107VerAlt(cProd,cProdPai,cPeriodo,nQuantItem,cParStrTipo,cParStrGrupo,cRev711Vaz,dDataNes,nPrazoEnt,cOpcionais,cAliasSG1,lRecalc,lVerAllEmp,cParEmp,cParFil)
Local nSldAlt      := 0
Local nSldMp       := 0
Local nQtdAlter    := 0
Local nZ           := 0
Local nI           := 0
Local nRecSOT      := 0
Local cQuery       := ""
Local cAliasSGI    := "BUSCASGI"
Local cPerSOT      := ""
Local cEmp         := ""
Local cFil         := ""
Local cProdSG1     := ""
Local cGrOpcSG1    := ""
Local cOpcSG1      := ""
Local nQtPontPed   := 0
Local aEmpresas    := {}
Local aSGI         := {}
Local aProcEmp     := {}
Local aAreaSOQ     := SOQ->(GetArea())
Local lBkpSldSOR   := .F.

Local GIFILIAL     := 1
Local GIPRODORI    := 2
Local GIPRODALT    := 3
Local GITIPOCON    := 4
Local GIFATOR      := 5
Local B1REVATU     := 6
Local B1EMIN       := 7

Default cAliasSG1  := "SG1"
Default lRecalc    := .T.
Default lVerAllEmp := .F.
Default cParEmp    := cEmpAnt
Default cParFil    := cFilAnt

//Parâmetro para verificar o saldo dos alternativos em todas as empresas.
//Se .T., irá verificar primeiro o saldo na empresa atual, e depois nas demais empresas
//do MRP respeitando a prioridade.
If lVerAllEmp
   aAdd(aProcEmp,{cParEmp, cParFil})
   If AllTrim(cEmpBkp) != AllTrim(cParEmp) .Or. AllTrim(cFilBkp) != AllTrim(cParFil)
      aAdd(aProcEmp,{cEmpBkp, cFilBkp})
   EndIf
   For nZ := 1 To Len(aEmpCent)
      If aScan(aProcEmp, {|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(aEmpCent[nZ,1])+AllTrim(aEmpCent[nZ,2]) }) < 1
         aAdd(aProcEmp,{aEmpCent[nZ,1],aEmpCent[nZ,2]})
      EndIf
   Next nZ
Else
   aAdd(aProcEmp,{cParEmp, cParFil})
EndIf

//Array utilizado na função do recálculo, para verificação do estoque de segurança.
aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nZ := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nZ,1],aEmpCent[nZ,2],aEmpCent[nZ,3]})
   EndIf
Next nZ

If ValType(cParStrTipo) == "C"
   cStrTipo := cParStrTipo
EndIf

cQuery := " SELECT SGI.GI_FILIAL, "
cQuery +=        " SGI.GI_PRODORI, "
cQuery +=        " SGI.GI_PRODALT, "
cQuery +=        " SGI.GI_TIPOCON, "
cQuery +=        " SGI.GI_FATOR, "
cQuery +=        " SB1.B1_REVATU, "
cQuery +=        " SB1.B1_COD, "
If cDadosProd == "SBZ"
   cQuery +=     " ISNULL(SBZ.BZ_EMIN, SB1.B1_EMIN ) B1_EMIN "
   cQuery += " FROM " + RetSqlName("SGI") + " SGI, " + RetSqlName("SB1") + " SB1 "
   cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ "
   cQuery += "   ON SBZ.BZ_FILIAL  = '" + xFilial("SBZ") + "' "
   cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' "
   cQuery += "  AND SBZ.BZ_COD     = SB1.B1_COD "
Else
   cQuery +=     " SB1.B1_EMIN "
   cQuery += " FROM " + RetSqlName("SGI") + " SGI, " + RetSqlName("SB1") + " SB1 "
EndIf
cQuery +=  " WHERE SGI.GI_FILIAL  = '" + xFilial("SGI") + "' "
cQuery +=    " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
cQuery +=    " AND SGI.GI_PRODALT = SB1.B1_COD "
cQuery +=    " AND SGI.GI_PRODORI = '" + cProd + "' "
cQuery +=    " AND SGI.GI_MRP     = 'S' "
cQuery +=    " AND SB1.B1_MRP     = 'S' "
cQuery +=    " AND SGI.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSGI,.T.,.T.)
dbSelectArea(cAliasSGI)

While !(cAliasSGI)->(Eof())
   aAdd(aSGI,{(cAliasSGI)->(GI_FILIAL),;
              (cAliasSGI)->(GI_PRODORI),;
              (cAliasSGI)->(GI_PRODALT),;
              (cAliasSGI)->(GI_TIPOCON),;
              (cAliasSGI)->(GI_FATOR),;
              IIF(lPCPREVATU , PCPREVATU((cAliasSGI)->B1_COD), (cAliasSGI)->B1_REVATU),;
              (cAliasSGI)->(B1_EMIN)})
   (cAliasSGI)->(dbSkip())
End

(cAliasSGI)->(dbCloseArea())

For nZ := 1 To Len(aProcEmp)
   cParEmp := aProcEmp[nZ,1]
   cParFil := aProcEmp[nZ,2]
   For nI := 1 To Len(aSGI)
      If nQuantItem <= 0
         Exit
      EndIf
      If verPontPed(aSGI[nI,GIPRODALT])
         nQtPontPed := aSGI[nI,B1EMIN]
      Else
         nQtPontPed := 0
      EndIf
      //Converte a quantidade faltante conforme fator do alternativo
      If aSGI[nI,GITIPOCON] == "M"
         nQtdAlter := (nQuantItem - Max(nSldMp,0)) * aSGI[nI,GIFATOR]
      Else
         nQtdAlter := (nQuantItem - Max(nSldMp,0)) / aSGI[nI,GIFATOR]
      EndIf

      //Obtem saldo do produto alternativo no periodo analisado
      nSldAlt := A107SldSOT(aSGI[nI,GIPRODALT],cPeriodo,cOpcionais,aSGI[nI,B1REVATU],/*05*/,nQtPontPed,lRecalc,cParEmp,cParFil)

      //Se tem saldo do alternativo, o utiliza
      If Min(nQtdAlter,nSldAlt) > 0
         //Gera Log MRP e SH5 da quantidade utilizada do alternativo
         aDados := {cProdSG1,Min(nQtdAlter,nSldAlt),SomaPrazo(dDataNes,-nPrazoEnt)}

         A107CriaLOG("004",aSGI[nI,GIPRODALT],aDados,lLogMRP,c711NumMrp)
         lBkpSldSOR := lVerSldSOR
         lVerSldSOR := .T.

         A107CriSOQ(SomaPrazo(dDataNes,-nPrazoEnt),aSGI[nI,GIPRODALT],cGrOpcSG1+cOpcSG1,aSGI[nI,B1REVATU],"SOR",0,cProdPai,/*08*/,/*09*/,Min(nQtdAlter,nSldAlt),"4",.F.,/*13*/,/*14*/,.F.,.T.,/*17*/,/*18*/,/*19*/,cParStrTipo,cParStrGrupo,/*22*/,cProd,/*24*/,cOpcionais,/*26*/,/*27*/,aEmpresas)
         lVerSldSOR := lBkpSldSOR
         //Se a empresa/filial onde existe o saldo do alternativo for diferente da empresa
         //onde está a necessidade, já faz a transferência do produto.
         If AllTrim(cParEmp) != AllTrim(cEmpAnt) .Or. AllTrim(cParFil) != AllTrim(cFilAnt)
            cPerSOT := SOT->(OT_PERMRP)
            nRecSOT := SOT->(Recno())
            cEmp := cEmpAnt
            cFil := cFilAnt
            a107AltEmp(cParEmp,cParFil)
            A107TraPrd(cEmp, cFil, aSGI[nI,GIPRODALT], Min(nQtdAlter,nSldAlt), cPerSOT, nRecSOT,.F.)
            a107AltEmp(cEmp,cFil)
         EndIf
         //Recalcula saldo do alternativo consumido
         A107Recalc(aSGI[nI,GIPRODALT],cOpcionais,If(A107TrataRev(),aSGI[nI,B1REVATU],cRev711Vaz),/*04*/,/*05*/,/*06*/,/*07*/,nQtPontPed,aEmpresas)

         //Avalia se o alternativo nao foi utilizado em data futura e troca
         A107AvSldA(aSGI[nI,GIPRODALT],cPeriodo,cRev711Vaz,cParStrTipo,cParStrGrupo,dDataNes,.F.,cParEmp,cParFil)

         //Volta nQuantItem com o saldo nao atendido
         If aSGI[nI,GITIPOCON] == "M"
            nQuantItem -= Min(nQtdAlter,nSldAlt) / aSGI[nI,GIFATOR]
         Else
            nQuantItem -= Min(nQtdAlter,nSldAlt) * aSGI[nI,GIFATOR]
         EndIf
      EndIf
   Next nI
   If nQuantItem <= 0
      Exit
   EndIf
Next nZ
SOQ->(RestArea(aAreaSOQ))
Return nQuantItem

/*------------------------------------------------------------------------//
//Programa: A107ClNes
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Rotina para recalcular necessidades produto a produto
//Parametros:  01.cNivEst        - Nivel da estrutura para recalculo das necessidades
//             02.oCenterPanel   - Objeto da tela de processamento
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107ClNes(cNivEst,oCenterPanel,lCalcFirst)
Local cJobAux     := ""
Local aThreads    := {}
Local aJobAux     := {}
Local nRetry_0    := 0
Local nRetry_1    := 0
Local nPontPed    := 0
Local nX          := 0
Local cStartPath  := ""
Local lThrSeq     := .F.
Local cOpc        := Space(Len(SOR->OR_OPC))
Local lThreads    := .F.
Local cQuery      := ""
Local cAliasTop   := ""
Local aEmpresas   := {}

Default lCalcFirst := .F.

aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nX := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nX,1],aEmpCent[nX,2],aEmpCent[nX,3]})
   EndIf
Next nX

If SuperGetMv('MV_A710THR',.F.,1) > 1
   lThreads := .T.
Endif

If lThreads
   //Diretorio do servidor protheus
   cStartPath := GetSrvProfString("Startpath","")
   //Habilita processamento de thread em sequencia
   lThrSeq    := SuperGetMV("MV_THRSEQ",.F.,.F.)
   //Calcula Quebra por Threads
   aThreads := PCPA107TRT(cNivEst)
   ProcRegua(Len(aThreads))

   For nX := 1 to Len(aThreads)

      //Adiciona o nome do arquivo de Job no array aJobAux
      aAdd(aJobAux,{StrZero(nX,2)})

      //Inicializa variavel global de controle de thread
      cJobAux := "c107P"+cEmpAnt+cFilAnt+StrZero(nX,2)
      PutGlbValue(cJobAux,"0")
      GlbUnLock()

      //Atualiza o log de processamento
      ProcLogAtu("MENSAGEM","Iniciando de Recalculo das Necessidades - Thread:" + StrZero(nX,2),"Iniciando de Recalculo das Necessidades - Thread:" + StrZero(nX,2))

      //Dispara thread para Stored Procedure
      StartJob("A107JobNes",GetEnvServer(),lThrSeq,cEmpAnt,cFilAnt,aThreads[nX,1],StrZero(nX,2),aPeriodos,aPergs711,aAlmoxNNR,c711NumMrp,aFilAlmox,lCalcFirst,aEmpresas)
   Next nX

   //Controle de Seguranca para MULTI-THREAD
   For nX :=1 to Len(aThreads)

      //Inicializa variavel global de controle de thread
      cJobAux := "c107P"+cEmpAnt+cFilAnt+StrZero(nX,2)

      While .T.
         Do Case
            //TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
            Case GetGlbValue(cJobAux) == '0'
               If nRetry_0 > 50
                  //Conout(Replicate("-",65))
                  //Conout("PCPA107: "+ "Não foi possivel realizar a subida da thread" + " " + StrZero(nX,2))
                  //Conout(Replicate("-",65))

                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Não foi possivel realizar a subida da thread","Não foi possivel realizar a subida da thread")
                  Final(STR0189) // "Não foi possivel realizar a subida da thread"
               Else
                  nRetry_0 ++
               EndIf

            //TRATAMENTO PARA ERRO DE CONEXAO
            Case GetGlbValue(cJobAux) == '10'
               If nRetry_1 > 5
                  //Conout(Replicate("-",65))
                  //Conout("PCPA107: Erro de conexao na thread")
                  //Conout("Thread numero : " + StrZero(nX,2) )
                  //Conout("Numero de tentativas excedidas")
                  //Conout(Replicate("-",65))

                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","PCPA107: Erro de conexao na thread de procedures","PCPA107: Erro de conexao na thread")
                  Final(STR0190) //"PCPA107: Erro de conexao na thread"
               Else
                  //Inicializa variavel global de controle de Job
                  PutGlbValue(cJobAux,"0")
                  GlbUnLock()

                  //Reiniciar thread
                  //Conout(Replicate("-",65))
                  //Conout("PCPA107: Erro de conexao na thread")
                  //Conout("Tentativa numero: "      +StrZero(nRetry_1,2))
                  //Conout("Reiniciando a thread : "+StrZero(nX,2))
                  //Conout(Replicate("-",65))

                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","Reiniciando a thread : "+StrZero(nX,2),"Reiniciando a thread : "+StrZero(nX,2))

                  //Dispara thread para Stored Procedure
                  StartJob("A107JobNes",GetEnvServer(),lThrSeq,cEmpAnt,cFilAnt,aThreads[nX,1],StrZero(nX,2),aPeriodos,aPergs711,aAlmoxNNR,c711NumMrp,aFilAlmox,lCalcFirst,aEmpresas)
               EndIf
               nRetry_1 ++

            //TRATAMENTO PARA ERRO DE CONEXÃO
            Case GetGlbValue(cJobAux) == '20'
               //Conout(Replicate("-",65))
               //Conout("PCPA107: Erro ao efetuar a conexão na thread ")
               //Conout("Thread numero : "+StrZero(nX,2))
               //Conout(Replicate("-",65))

               //Atualiza o log de processamento
               ProcLogAtu("MENSAGEM","PCPA107: Erro ao efetuar a conexão na thread","PCPA107: Erro ao efetuar a conexão na thread")
               Final(STR0196) //"PCPA107: Erro ao efetuar a conexão na thread"

            //TRATAMENTO PARA ERRO DE APLICACAO
            Case GetGlbValue(cJobAux) == '30'
               //Conout(Replicate("-",65))
               //Conout("PCPA107: Erro de aplicacao na thread ")
               //Conout("Thread numero : "+StrZero(nX,2))
               //Conout(Replicate("-",65))

               //Atualiza o log de processamento
               ProcLogAtu("MENSAGEM","PCPA107: Erro de aplicacao na thread","PCPA107: Erro de aplicacao na thread")
               Final(STR0188) //"PCPA107: Erro de aplicacao na thread"

            //THREAD PROCESSADA CORRETAMENTE
            Case GetGlbValue(cJobAux) == '3'
               //Atualiza o log de processamento
               ProcLogAtu("MENSAGEM","Termino do Recalculo das Necessidades - Thread:" + StrZero(nX,2),"Termino do Recalculo das Necessidades - Thread:" + StrZero(nX,2))
               Exit
         EndCase
         Sleep(1000)
      End
   Next nX
Else
   //Verifica todos produtos utilizados
   cAliasTop := "RECNECES"

   If cDadosProd == "SBZ"
      cQuery += " SELECT DISTINCT SOR.OR_PROD OR_PROD, " +;
                                " SOR.OR_NRRV OR_NRRV, " +;
                                " ISNULL(BZ_EMIN,B1_EMIN) B1_EMIN, " +;
                                " SOR.R_E_C_N_O_ SORREC " +;
                  " FROM " + RetSqlName("SOR") + " SOR, " +;
                           RetSqlName("SOT") + " SOT, " +;
                           RetSqlName("SB1") + " SB1 " +;
                           " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ  " +;
                             " ON SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"' " +;
                              " AND SBZ.BZ_COD     = SB1.B1_COD " +;
                              " AND SBZ.D_E_L_E_T_ = ' ' " +;
                 " WHERE SOR.OR_FILIAL   = '" + xFilial("SOR") + "' " +;
                   " AND SOT.OT_FILIAL   = '" + xFilial("SOT") + "' " +;
                   " AND SB1.B1_FILIAL   = '" + xFilial("SB1") + "' " +;
                   " AND SOR.R_E_C_N_O_   = SOT.OT_RGSOR " +;
                   " AND SOR.OR_PROD     = SB1.B1_COD " +;
                   " AND SOR.OR_EMP      = '" + cEmpAnt + "'" +;
                   " AND SOR.OR_FILEMP   = '" + cFilAnt + "'" +;
                   " AND (SOT.OT_QTNECE <> 0 " +;
                   "  OR  SOT.OT_QTSAID <> 0 " +;
                   "  OR  SOT.OT_QTSALD <> 0 " +;
                   "  OR  SOT.OT_QTSEST <> 0 " +;
                   "  OR  SOT.OT_QTENTR <> 0 " +;
                   "  OR  SOT.OT_QTSLES <> 0 " +;
                   "  OR  ISNULL(BZ_EMIN,B1_EMIN) <> 0) "

      If !Empty(cNivEst)
         cQuery += " AND SOR.OR_NRLV = '" + cNivEst + "' "
      EndIf

      cQuery +=   " ORDER BY SOR.OR_PROD, " +;
                          " SOR.OR_NRRV, " +;
                          " SOR.R_E_C_N_O_ "
   Else
      cQuery += " SELECT DISTINCT SOR.OR_PROD OR_PROD, " +;
                                " SOR.OR_NRRV OR_NRRV, " +;
                                " SB1.B1_EMIN B1_EMIN, " +;
                                " SOR.R_E_C_N_O_ SORREC " +;
                  " FROM " + RetSqlName("SOR") + " SOR, " +;
                           RetSqlName("SOT") + " SOT, " +;
                           RetSqlName("SB1") + " SB1 " +;
                 " WHERE SOR.OR_FILIAL   = '" + xFilial("SOR") + "' " +;
                   " AND SOT.OT_FILIAL   = '" + xFilial("SOT") + "' " +;
                   " AND SB1.B1_FILIAL   = '" + xFilial("SB1") + "' " +;
                   " AND SOR.R_E_C_N_O_  = SOT.OT_RGSOR " +;
                   " AND SOR.OR_PROD     = SB1.B1_COD " +;
                   " AND SOR.OR_EMP      = '" + cEmpAnt + "'" +;
                   " AND SOR.OR_FILEMP   = '" + cFilAnt + "'" +;
                   " AND (SOT.OT_QTNECE <> 0 " +;
                   "  OR  SOT.OT_QTSAID <> 0 " +;
                   "  OR  SOT.OT_QTSALD <> 0 " +;
                   "  OR  SOT.OT_QTSEST <> 0 " +;
                   "  OR  SOT.OT_QTENTR <> 0 " +;
                   "  OR  SOT.OT_QTSLES <> 0 " +;
                   "  OR  B1_EMIN        <> 0) "

      If !Empty(cNivEst)
         cquery += " AND SOR.OR_NRLV = '" + cNivEst + "' "
      EndIf

      cQuery +=   " ORDER BY SOR.OR_PROD, " +;
                          " SOR.OR_NRRV, " +;
                          " SB1.B1_EMIN, " +;
                          " SOR.R_E_C_N_O_ "
   EndIf

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   dbSelectArea(cAliasTop)

   If (oCenterPanel == Nil)
      ProcRegua((cAliasTop)->(RecCount()))
   Else
      oCenterPanel:SetRegua1((cAliasTop)->(LastRec()))
   EndIf
   dbGotop()

   While !Eof()
      If (oCenterPanel != Nil)
         oCenterPanel:IncRegua1(OemToAnsi(STR0108))
      EndIf

      nRecno := SORREC
      SOR->(DbGoTo(nRecno))
      cOpc := SOR->OR_OPC
      If verPontPed((cAliasTop)->OR_PROD)
         nPontPed := (cAliasTop)->B1_EMIN
      Else
         nPontPed := 0
      EndIf
      A107Recalc((cAliasTop)->OR_PROD,cOpc,(cAliasTop)->OR_NRRV,/*04*/,/*05*/,/*06*/,(cAliasTop)->SORREC,nPontPed,aEmpresas)
      dbSelectArea(cAliasTop)
      dbSkip()
   Enddo

   (cAliasTop)->(dbCloseArea())
Endif

If (oCenterPanel<>Nil)
   oCenterPanel:IncRegua2()
EndIf

Return

/*------------------------------------------------------------------------//
//Programa: PCPA107MAT
//Autor:    Lucas Konrad França
//Data:     20/11/2014
//Descricao:   Rotina que irá processar nivel a nivel os itens
//Parametros:  01.oCenterPanel   - Objeto da tela de processamento
//             02.cStrTipo    - String com os tipos do item
//             03.cStrGrupo      - String com os grupos do item
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function PCPA107MAT(oCenterPanel,cStrTipo,cStrGrupo)
Local cAliasTop   := ""
Local cQuery      := ""
Local cOpc        := ""
Local cNivMax     := 1
Local nInd        := 0
Local nRecNo      := 0
Local nz          := 0
Local nI          := 0
Local nSldGeral   := 0
Local nQtUsada    := 0
Local nEstSeg     := 0
Local nPontoPed   := 0
Local nQtdPP      := 0
Local nNecess     := 0
Local nPos        := 0
Local lMT710EXP   := .T.
Local lExplode    := .T.
Local aNegEst     := {}
Local aOpc        := {}
Local mOpc        := ""
Local aDados      := {}
Local aEmpresas   := {}

Local ORPROD      := 1
Local ORNRRV      := 2
Local OTPERMRP    := 3
Local OTQTNECE    := 4
Local B1REVATU    := 5
Local SORREC      := 6
Local OTQTSALD    := 7

aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nI := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nI,1],aEmpCent[nI,2],aEmpCent[nI,3]})
   EndIf
Next nI

//Busca o nivel máximo
cAliasTop := "BUSCANIV"

cQuery := "SELECT MAX(SG1.G1_NIV) NIVMAX"
cQuery +=  " FROM " + RetSqlName("SG1") + " SG1 "
cQuery += " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "'"
cQuery +=   " AND SG1.G1_NIV     <> '99'"
cQuery +=   " AND SG1.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
dbSelectArea(cAliasTop)

cNivMax := (cAliasTop)->NIVMAX

dbCloseArea()

//Seta regua
If (oCenterPanel == Nil)
   ProcRegua(VAL(cNivMax))
Else
   oCenterPanel:SetRegua1(VAL(cNivMax))
EndIf

//Percorre os níveis para calcular os componentes
For nInd := 1 to VAL(cNivMax)
   //Atualiza o log de processamento
   ProcLogAtu("MENSAGEM","Inicio nivel " + STR(nInd),"Inicio nivel " + STR(nInd))

   //Calcula as necessidades. Se for o primeiro nivel, não é necessário, pois já calculou antes de entrar nessa função
   If nInd # 1
      A107ClNes(StrZero(nInd,2,0),oCenterPanel,.F.)
   EndIf

   //Incrementa regua
   If (oCenterPanel != Nil)
      oCenterPanel:IncRegua1(OemToAnsi(STR0108))
   EndIf

   //Busca os itens por nivel para calcular as necessidades
   cAliasTop := "BUSCAEST"
   cQuery := " SELECT SOR.OR_PROD, " +;
                    " SOR.OR_NRRV, " +;
                    " SOT.OT_PERMRP, " +;
                    " SOT.OT_QTNECE, " +;
                    " SOT.OT_QTSALD, " +;
                    " SB1.B1_REVATU, " +;
                    " SB1.B1_COD, " +;
                    " SOR.R_E_C_N_O_ SORREC " +;
               " FROM " + RetSqlName("SOR") + " SOR, " +;
                          RetSqlName("SOT") + " SOT, " +;
                          RetSqlName("SB1") + " SB1 " +;
              " WHERE SOR.OR_FILIAL  = '" + xFilial("SOR") + "' " +;
                " AND SOT.OT_FILIAL  = '" + xFilial("SOT") + "' " +;
                " AND SB1.B1_FILIAL   = '" + xFilial("SB1") + "' " +;
                " AND SOR.R_E_C_N_O_  = SOT.OT_RGSOR " +;
                " AND SOR.OR_PROD    = SB1.B1_COD " +;
                " AND SOR.OR_NRLV    = '" + StrZero(nInd,2,0) + "' " +;
                " AND SOT.OT_QTNECE  > 0 " +;
                " AND SOR.OR_EMP     = '" + cEmpAnt + "'" +;
                " AND SOR.OR_FILEMP  = '" + cFilAnt + "'" +;
                " AND SB1.D_E_L_E_T_ = ' ' " +;
              " ORDER BY SOT.OT_PERMRP "
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   dbSelectArea(cAliasTop)

   aDados := {}

   While !Eof()
      aAdd(aDados,{(cAliasTop)->OR_PROD, ;
                   (cAliasTop)->OR_NRRV, ;
                   (cAliasTop)->OT_PERMRP, ;
                   (cAliasTop)->OT_QTNECE, ;
                   IIF(lPCPREVATU , PCPREVATU((cAliasTop)->B1_COD), (cAliasTop)->B1_REVATU)/*(cAliasTop)->B1_REVATU*/, ;
                   (cAliasTop)->SORREC, ;
                   (cAliasTop)->OT_QTSALD})
      //Próximo registro
      dbSelectArea(cAliasTop)
      dbSkip()
   End
   //Fecha Alias
   (cAliasTop)->(dbCloseArea())

   For nI := 1 To Len(aDados)
      //Pega o RecNo para o opcional
      nRecno := aDados[nI,SORREC]
      //Busca o opcional, pois não é possível colocar campo MEMO na query
      dbSelectArea("SOR")
      SOR->(DbGoTo(nRecno))
      cOpc := SOR->OR_OPC
      mOpc := SOR->OR_MOPC

      //Verifica PE para explodir estrutura
      If lPeMT710EXP
         lMT710EXP := ExecBlock("MT710EXP",.F.,.F.,{aDados[nI,ORPROD],cOpc,aDados[nI,ORNRRV],aDados[nI,OTQTNECE]})
         If ValType(lMT710EXP) # "L"
            lMT710EXP := .T.
         EndIf
      EndIf
      lExplode := .T.
      nSldGeral := a107SldSum(aDados[nI,ORPROD],aDados[nI,OTPERMRP],.T.,cOpc,mOpc)
      nPos := aScan(aSldUsado, {|x| x[1] == aDados[nI,ORPROD] })
      If nPos > 0
         nQtUsada := aSldUsado[nPos,2]
      Else
         nQtUsada := 0
      EndIf
      If nSldGeral-nQtUsada < 0
         lExplode := .T.
      Else
         If aPergs711[26] == 3
            nEstSeg := buscaEstSeg(aDados[nI,ORPROD],aEmpresas)
         EndIf

         //Verifica ponto de pedido
         If aPergs711[31] == 1
            If verPontPed(aDados[nI,ORPROD])
               If Empty(nPontoPed)
                  SB1->(MsSeek(xFilial("SB1") + aDados[nI,ORPROD]))
                  nPontoPed := RetFldProd(SB1->B1_COD,"B1_EMIN")
               EndIf
               If !Empty(nPontoPed)
                  //nPontoPed++            //CH TRAAXW
                  nQtdPP := nPontoPed + 1  //CH TRAAXW
               EndIf
            Else
               nQtdPP := 0
            EndIf
         EndIf
         If (nSldGeral-nQtUsada-nQtdPP-nEstSeg) >= aDados[nI,OTQTNECE]
            lExplode := .F.
            If nPos > 0
               aSldUsado[nPos,2] += aDados[nI,OTQTNECE]
            Else
               aAdd(aSldUsado,{aDados[nI,ORPROD],aDados[nI,OTQTNECE]})
            EndIf
         EndIf
      EndIf
      //Explode estrutura
      If lMT710EXP .And. lExplode
         If (nSldGeral-nQtUsada) > aDados[nI,OTQTSALD]
            nNecess := aDados[nI,OTQTNECE]
            /*If nSldGeral-nQtUsada == 0
               aDados[nI,OTQTNECE] := ABS((nSldGeral-nQtUsada) - aDados[nI,OTQTSALD]) + nQtdPP
            Else
               aDados[nI,OTQTNECE] := ABS((aDados[nI,OTQTSALD]-nEstSeg) + (nSldGeral-nQtUsada))
            EndIf
            aDados[nI,OTQTNECE] := A711Lote(ABS(aDados[nI,OTQTNECE]),aDados[nI,ORPROD])*/
            If nPos > 0
               aSldUsado[nPos,2] += (nNecess-aDados[nI,OTQTNECE])
            Else
               aAdd(aSldUsado,{aDados[nI,ORPROD],(nNecess-aDados[nI,OTQTNECE])})
            EndIf
         EndIf
         //Verifica se é subproduto
         aNegEst := IsNegEstr(aDados[nI,ORPROD],aPeriodos[VAL(aDados[nI,OTPERMRP])],aDados[nI,OTQTNECE])
         If aNegEst[1]
            SB1->(MsSeek(xFilial("SB1")+aNegEst[2]))
            For nz := 1 To aNegEst[5]
               A107CriSOQ(aPeriodos[VAL(aDados[nI,OTPERMRP])],aNegEst[2],aNegEst[3],IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SBP",0,aDados[nI,ORPROD],/*08*/,/*09*/,aNegEst[4],"2",.F.,.T.,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,mOpc,/*26*/,/*27*/,aEmpresas)
               A107ExplEs(aNegEst[2],aNegEst[3],IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,aNegEst[4],aDados[nI,OTPERMRP],cStrTipo,cStrGrupo,/*08*/,.T.,.F.,,,,nInd)
            Next nz
         Else
            //Decompoe os opcionais
            If (aOpc := Str2Array(mOpc,.F.)) == Nil
               aOpc := {}
            EndIf

            //Explode estrutura
            A107ExplEs(aDados[nI,ORPROD],cOpc,aDados[nI,ORNRRV],aDados[nI,OTQTNECE],aDados[nI,OTPERMRP],cStrTipo,cStrGrupo,aOpc,.F.,.T.,,,,nInd)
         EndIf
      EndIf
   Next nI

   //Atualiza LOG
   ProcLogAtu("MENSAGEM","Fim nivel " + STR(nInd),"Fim nivel " + STR(nInd))
Next nInd

//Atualiza LOG
ProcLogAtu("MENSAGEM","Inicio recalculo necessidade nivel 99","Inicio recalculo necessidade nivel 99")

//Recalcula as necessidades do nivel 99
A107ClNes("99",oCenterPanel,.F.)

//Atualiza LOG
ProcLogAtu("MENSAGEM","Fim recalculo necessidade nivel 99","Fim recalculo necessidade nivel 99")

A107GrvTm(oCenterPanel,STR0109) //"Termino do Calculo das Necessidade."

Return

/*-------------------------------------------------------------------------/
//Programa: PCPA107MVW
//Autor:    Lucas Konrad França
//Data:     25/11/2014
//Descricao:   Monta o arquivo temporário da SOR e SOT para mostrar em tela
//Parametros:  aCampos - Array de campos (por referência)
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function PCPA107MVW(lGroup,cAliasTab)
Local cCriaTrab   := ""
Local cQuery      := ""
Local cProdAnt    := ""
Local cOpcAnt     := ""
Local cRevAnt     := ""
Local cNameIdx    := ""
//Local cAliasTab   := "CRIATAB"
Local cAliasTop   := "BUSCADADOS"
Local nInd        := 0
Local nIndProd    := 0
Local nQtTran     := 0
Local aTamQuant   := TamSX3("B2_QFIM")
Local aRecNo      := {}
Local aFields     := {}
Local nTamFil     := TamSX3("OQ_FILEMP")[1]

//Autaliza LOG
ProcLogAtu("MENSAGEM","Inicio montagem arquivo de trabalho","Inicio montagem arquivo de trabalho")

//Cria o array dos campos para o arquivo
AADD(aFields,{"TIPO","C",1,0})
AADD(aFields,{"TEXTO","C",30,0})
AADD(aFields,{"PRODUTO","C",LEN(SOR->OR_PROD),0})
AADD(aFields,{"PRODSHOW","C",LEN(SOR->OR_PROD),0})
AADD(aFields,{"OPCIONAL","C",LEN(SOR->OR_OPCORD),0})
AADD(aFields,{"OPCSHOW","C",LEN(SOR->OR_OPCORD),0})
AADD(aFields,{"REVISAO","C",4,0})
AADD(aFields,{"REVSHOW","C",4,0})
AADD(aFields,{"MRP","C",6,0}) //TREXG3
If !lGroup
   AADD(aFields,{"EMPRESA","C",2,0})
   AADD(aFields,{"FILIAL","C",nTamFil,0})
EndIf

For nInd := 1 to Len(aPeriodos)
   AADD(aFields,{"PER"+StrZero(nInd,3),"N",aTamQuant[1],aTamQuant[2]})
Next nInd


//Pega o nome para o arquivo temporario
cCriaTrab := cAliasTab
	
//Se já estiver em uso, só exclui os dados
If Select(cAliasTab) > 0
   cSql := " DELETE FROM " + cAliasTab
   TCSQLExec(cSql)
   
else // Senão cria a tabela no banco
   TCDelFile(cAliasTab)
   DbCreate(cCriaTrab,aFields,"TOPCONN")
   DbUseArea(.T.,"TOPCONN",cCriaTrab,cAliasTab,.T.,.F.)

  //Cria o nome para indice
   cNameIdx := FileNoExt(cCriaTrab+'i')
   DBCreateIndex(cNameIdx,'PRODUTO+OPCIONAL+REVISAO')
   
Endif  
	

If lGroup
   cQuery := " SELECT SOR.OR_PROD, " +;
                    " SOR.OR_OPCORD, " +;
                    " SOR.OR_NRRV, " +;
                    " SOR.OR_NRMRP, " +;
                    " SOT.OT_PERMRP, " +;
                    " SUM(SOT.OT_QTSLES) OT_QTSLES, " +;
                    " SUM(SOT.OT_QTENTR) OT_QTENTR, " +;
                    " SUM(SOT.OT_QTSAID) OT_QTSAID, " +;
                    " SUM(SOT.OT_QTSEST) OT_QTSEST, " +;
                    " SUM(SOT.OT_QTSALD) OT_QTSALD, " +;
                    " SUM(SOT.OT_QTNECE) OT_QTNECE " +;
               " FROM " + RetSqlName("SOR") + " SOR, " +;
                          RetSqlName("SOT") + " SOT " +;
              " WHERE SOR.OR_FILIAL   = '" + xFilial("SOR") + "' " +;
                " AND SOT.OT_FILIAL   = '" + xFilial("SOT") + "' " +;
                " AND SOR.R_E_C_N_O_  = SOT.OT_RGSOR " +;
                " AND (SOT.OT_QTNECE <> 0 " +;
                "  OR  SOT.OT_QTSAID <> 0 " +;
                "  OR  SOT.OT_QTSALD <> 0 " +;
                "  OR  SOT.OT_QTSEST <> 0 " +;
                "  OR  SOT.OT_QTENTR <> 0 " +;
                "  OR  SOT.OT_QTSLES <> 0 " +;
                "  OR  SOT.OT_QTTRAN <> 0 ) "+;
              " GROUP BY SOR.OR_PROD, " +;
                       " SOR.OR_OPCORD, " +;
                       " SOR.OR_NRRV, " +;
                       " SOR.OR_NRMRP, " +;
                       " SOT.OT_PERMRP " +;
              " ORDER BY SOR.OR_PROD, " +;
                       " SOR.OR_OPCORD, " +;
                       " SOR.OR_NRRV, " +;
                       " SOR.OR_NRMRP, " +;
                       " SOT.OT_PERMRP "
Else
   cQuery := " SELECT SOR.OR_EMP, " +;
                    " SOR.OR_FILEMP, "+;
                    " SOR.OR_PROD, " +;
                    " SOR.OR_OPCORD, " +;
                    " SOR.OR_NRRV, " +;
                    " SOR.OR_NRMRP, " +;
                    " SOT.OT_PERMRP, " +;
                    " SOT.OT_QTSLES, " +;
                    " SOT.OT_QTENTR, " +;
                    " SOT.OT_QTSAID, " +;
                    " SOT.OT_QTSEST, " +;
                    " SOT.OT_QTSALD, " +;
                    " SOT.OT_QTNECE " +;
               " FROM " + RetSqlName("SOR") + " SOR, " +;
                          RetSqlName("SOT") + " SOT " +;
              " WHERE SOR.OR_FILIAL   = '" + xFilial("SOR") + "' " +;
                " AND SOT.OT_FILIAL   = '" + xFilial("SOT") + "' " +;
                " AND SOR.R_E_C_N_O_  = SOT.OT_RGSOR " +;
                " AND (SOT.OT_QTNECE <> 0 " +;
                "  OR  SOT.OT_QTSAID <> 0 " +;
                "  OR  SOT.OT_QTSALD <> 0 " +;
                "  OR  SOT.OT_QTSEST <> 0 " +;
                "  OR  SOT.OT_QTENTR <> 0 " +;
                "  OR  SOT.OT_QTSLES <> 0 " +;
                "  OR  SOT.OT_QTTRAN <> 0 ) "+;
              " ORDER BY SOR.OR_EMP, " +;
                       " SOR.OR_FILEMP, " +;
                       " SOR.OR_PROD, " +;
                       " SOR.OR_OPCORD, " +;
                       " SOR.OR_NRRV, " +;
                       " SOR.OR_NRMRP, " +;
                       " SOT.OT_PERMRP "
EndIf
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
dbSelectArea(cAliasTop)

While !Eof()
   nInd := VAL((cAliasTop)->OT_PERMRP)
   nQtTran := QtdTransf((cAliasTop)->OR_PROD,(cAliasTop)->OR_OPCORD,(cAliasTop)->OR_NRRV,(cAliasTop)->OT_PERMRP)
   //Se mudar o item, grava novo registro
   If cProdAnt # (cAliasTop)->OR_PROD .Or. cOpcAnt # (cAliasTop)->OR_OPCORD .Or. cRevAnt # (cAliasTop)->OR_NRRV
      cProdAnt    := (cAliasTop)->OR_PROD
      cOpcAnt     := (cAliasTop)->OR_OPCORD
      cRevAnt     := (cAliasTop)->OR_NRRV
      aRecNo      := {}

      //Grava Saldo inicial
      RecLock(cAliasTab,.T.)
      (cAliasTab)->TIPO     := '1'
      (cAliasTab)->TEXTO    := STR0110
      (cAliasTab)->PRODUTO  := (cAliasTop)->OR_PROD
      (cAliasTab)->PRODSHOW := (cAliasTop)->OR_PROD
      (cAliasTab)->OPCIONAL := (cAliasTop)->OR_OPCORD
      (cAliasTab)->OPCSHOW  := (cAliasTop)->OR_OPCORD
      (cAliasTab)->REVISAO  := (cAliasTop)->OR_NRRV
      (cAliasTab)->REVSHOW  := (cAliasTop)->OR_NRRV
      (cAliasTab)->MRP      := (cAliasTop)->OR_NRMRP //TREXG3
      If !lGroup
         (cAliasTab)->EMPRESA := (cAliasTop)->OR_EMP
         (cAliasTab)->FILIAL  := (cAliasTop)->OR_FILEMP
      EndIf
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTSLES
      MsUnLock(cAliasTab)

      AADD(aRecNo,{(cAliasTab)->(RecNo())})

      //Grava Entradas
      RecLock(cAliasTab,.T.)
      (cAliasTab)->TIPO     := '2'
      (cAliasTab)->TEXTO := STR0063
      (cAliasTab)->PRODUTO  := (cAliasTop)->OR_PROD
      (cAliasTab)->OPCIONAL := (cAliasTop)->OR_OPCORD
      (cAliasTab)->REVISAO  := (cAliasTop)->OR_NRRV
      If !lGroup
         (cAliasTab)->EMPRESA := (cAliasTop)->OR_EMP
         (cAliasTab)->FILIAL  := (cAliasTop)->OR_FILEMP
      EndIf
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTENTR
      MsUnLock(cAliasTab)

      AADD(aRecNo,{(cAliasTab)->(RecNo())})

      //Grava Saida
      RecLock(cAliasTab,.T.)
      (cAliasTab)->TIPO     := '3'
      (cAliasTab)->TEXTO := STR0064
      (cAliasTab)->PRODUTO  := (cAliasTop)->OR_PROD
      (cAliasTab)->OPCIONAL := (cAliasTop)->OR_OPCORD
      (cAliasTab)->REVISAO  := (cAliasTop)->OR_NRRV
      If !lGroup
         (cAliasTab)->EMPRESA := (cAliasTop)->OR_EMP
         (cAliasTab)->FILIAL  := (cAliasTop)->OR_FILEMP
      EndIf
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTSAID
      MsUnLock(cAliasTab)

      AADD(aRecNo,{(cAliasTab)->(RecNo())})

      //Grava Saida por estrutura
      RecLock(cAliasTab,.T.)
      (cAliasTab)->TIPO     := '4'
      (cAliasTab)->TEXTO := STR0111
      (cAliasTab)->PRODUTO  := (cAliasTop)->OR_PROD
      (cAliasTab)->OPCIONAL := (cAliasTop)->OR_OPCORD
      (cAliasTab)->REVISAO  := (cAliasTop)->OR_NRRV
      If !lGroup
         (cAliasTab)->EMPRESA := (cAliasTop)->OR_EMP
         (cAliasTab)->FILIAL  := (cAliasTop)->OR_FILEMP
      EndIf
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTSEST
      MsUnLock(cAliasTab)

      AADD(aRecNo,{(cAliasTab)->(RecNo())})

      //Grava Saldo final
      RecLock(cAliasTab,.T.)
      (cAliasTab)->TIPO     := '5'
      (cAliasTab)->TEXTO := STR0112
      (cAliasTab)->PRODUTO  := (cAliasTop)->OR_PROD
      (cAliasTab)->OPCIONAL := (cAliasTop)->OR_OPCORD
      (cAliasTab)->REVISAO  := (cAliasTop)->OR_NRRV
      If !lGroup
         (cAliasTab)->EMPRESA := (cAliasTop)->OR_EMP
         (cAliasTab)->FILIAL  := (cAliasTop)->OR_FILEMP
      EndIf
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTSALD
      MsUnLock(cAliasTab)

      AADD(aRecNo,{(cAliasTab)->(RecNo())})

      //Grava Necessidades
      RecLock(cAliasTab,.T.)
      (cAliasTab)->TIPO     := '6'
      (cAliasTab)->TEXTO := STR0113
      (cAliasTab)->PRODUTO  := (cAliasTop)->OR_PROD
      (cAliasTab)->OPCIONAL := (cAliasTop)->OR_OPCORD
      (cAliasTab)->REVISAO  := (cAliasTop)->OR_NRRV
      If !lGroup
         (cAliasTab)->EMPRESA := (cAliasTop)->OR_EMP
         (cAliasTab)->FILIAL  := (cAliasTop)->OR_FILEMP
      EndIf
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTNECE
      MsUnLock(cAliasTab)

      AADD(aRecNo,{(cAliasTab)->(RecNo())})

      //Transferências de estoque
      RecLock(cAliasTab,.T.)
      (cAliasTab)->TIPO     := '7'
      (cAliasTab)->TEXTO := STR0157
      (cAliasTab)->PRODUTO  := (cAliasTop)->OR_PROD
      (cAliasTab)->OPCIONAL := (cAliasTop)->OR_OPCORD
      (cAliasTab)->REVISAO  := (cAliasTop)->OR_NRRV
      If !lGroup
         (cAliasTab)->EMPRESA := (cAliasTop)->OR_EMP
         (cAliasTab)->FILIAL  := (cAliasTop)->OR_FILEMP
      EndIf
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := nQtTran
      MsUnLock(cAliasTab)

      AADD(aRecNo,{(cAliasTab)->(RecNo())})
   Else
      dbSelectArea(cAliasTab)
      (cAliasTab)->(dbGoTo(aRecNo[1][1]))

      RecLock(cAliasTab,.F.)
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTSLES
      MsUnLock(cAliasTab)

      (cAliasTab)->(dbGoTo(aRecNo[2][1]))

      RecLock(cAliasTab,.F.)
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTENTR
      MsUnLock(cAliasTab)

      (cAliasTab)->(dbGoTo(aRecNo[3][1]))

      RecLock(cAliasTab,.F.)
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTSAID
      MsUnLock(cAliasTab)

      (cAliasTab)->(dbGoTo(aRecNo[4][1]))

      RecLock(cAliasTab,.F.)
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTSEST
      MsUnLock(cAliasTab)

      (cAliasTab)->(dbGoTo(aRecNo[5][1]))

      RecLock(cAliasTab,.F.)
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTSALD
      MsUnLock(cAliasTab)

      (cAliasTab)->(dbGoTo(aRecNo[6][1]))

      RecLock(cAliasTab,.F.)
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := (cAliasTop)->OT_QTNECE
      MsUnLock(cAliasTab)

      (cAliasTab)->(dbGoTo(aRecNo[7][1]))

      RecLock(cAliasTab,.F.)
      (cAliasTab)->&("PER"+StrZero(nInd,3)) := nQtTran
      MsUnLock(cAliasTab)
   EndIf

   dbSelectArea(cAliasTop)
   dbSkip()
End

(cAliasTab)->(DbGoTop())

(cAliasTop)->(dbCloseArea())

//Autaliza LOG
ProcLogAtu("MENSAGEM","Fim montagem arquivo de trabalho","Fim montagem arquivo de trabalho")

Return cAliasTab

/*-------------------------------------------------------------------------/
//Programa: QtdTransf
//Autor:    Lucas Konrad França
//Data:     02/12/2014
//Descricao:   Busca o saldo total que foi transferido para o produto.
//Parametros:  01.cProd        - Produto para realizar a busca
//             02.cOpcOrd      - Opcional ordem
//             03.cRevisao     - Revisão
//             04.cPeriodo     - Periodo do mrp
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function QtdTransf(cProd,cOpcOrd,cRevisao,cPeriodo)
   Local cQuery    := ""
   Local aArea     := GetArea()
   Local cAlias    := GetNextAlias()
   Local nQtdTrans := 0

   cQuery := " SELECT SUM(SOT.OT_QTTRAN) OT_QTTRAN "
   cQuery +=   " FROM " + RetSQLName("SOT") + " SOT, "
   cQuery +=              RetSqlName("SOR") + " SOR "
   cQuery +=  " WHERE SOT.OT_FILIAL  = '" + xFilial("SOT") + "' "
   cQuery +=    " AND SOR.OR_FILIAL  = '" + xFilial("SOR") + "' "
   cQuery +=    " AND SOR.R_E_C_N_O_ = SOT.OT_RGSOR "
   cQuery +=    " AND SOR.OR_PROD    = '" + cProd + "' "
   cQuery +=    " AND SOR.OR_OPCORD  = '" + cOpcOrd + "' "
   cQuery +=    " AND SOR.OR_NRRV    = '" + cRevisao + "' "
   cQuery +=    " AND SOT.OT_PERMRP  = '" + cPeriodo + "' "
   cQuery +=    " AND SOT.OT_QTTRAN  > 0"

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   nQtdTrans := (cAlias)->(OT_QTTRAN)
   (cAlias)->(dbCloseArea())
   RestArea(aArea)
Return nQtdTrans

/*-------------------------------------------------------------------------/
//Programa: PA107Tree
//Autor:    Lucas Konrad França
//Data:     25/11/2014
//Descricao:   Funcao que monta o Tree do MRP
//Parametros:  01.lResumido      - Indica se apresenta os dados resumidos
//             02.oCenterPanel   - Objeto do painel de progress bar
//             03.lFilNeces      - Indica se filtra apenas produtos com necessidades
//             04.lVisualiza     - Indica se é visualização ou processo
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PA107Tree(lResumido,oCenterPanel,lFilNeces,lVisualiza)
Local nAchouTot   := 0
Local i           := 0
Local nX          := 0
Local nY          := 0
Local nPos        := 0
Local nRetry_0    := 0
Local nRetry_1    := 0
Local nHd1        := 0
Local nHd2        := 0
Local lInJob      := SuperGetMv('MV_A710THR',.F.,1) > 1
Local cStartPath  := GetSrvProfString("Startpath","")
Local cJobFile    := ""
Local cJobAux     := ""
Local cFileTotal  := ""
Local cFileTree   := ""
Local cLinha      := ""
Local aNewTotal   := {}
Local aNewDbTree  := {}
Local aThreads    := {}
Local aJobAux     := {}
Local lThrSeq     := SuperGetMV("MV_THRSEQ",.F.,.F.)
Local nTamProd    := TamSX3("OQ_PROD")[1]
Local nTamOpc     := TamSX3("OQ_OPCORD")[1]
Local nTamRev     := TamSX3("B1_REVATU")[1]
Local nTamCod     := nTamProd+nTamOpc+nTamRev
Local nTamDocRev  := Len(SC2->C2_REVISAO)
Local nTamDoc     := TamSX3("OQ_DOC")[1]
Local nTamRecno   := 12
Local nTamPer     := 3
Local nTamAlias   := 3
Local nTamTipo    := 1
Local cAliasTop   := ""
Local cQuery      := ""
Local nRecno      := 0

Default lResumido  := .F.
Default lFilNeces  := .F.
Default lVisualiza := .F.

aDbTree := {}

//Atualiza o log de processamento
ProcLogAtu("MENSAGEM","Iniciando Montagem do Tree do MRP","Iniciando Montagem do Tree do MRP")


//Verifica todos produtos utilizados pelo arquivo de resumo ou de detalhe
If lResumido
   //Grava dados resumidos
   cAliasTop := "MONTATREE"
   cQuery := " SELECT DISTINCT SOR.OR_PROD, " +;
                     " SOR.OR_OPCORD, " +;
                     " SOR.OR_NRRV, " +;
                     " SOR.OR_EMP, " +;
                     " SOR.OR_FILEMP, "+;
                     " SOR.R_E_C_N_O_ SORREC " +;
                " FROM " + RetSqlName("SOR") + " SOR, " +;
                           RetSqlName("SOT") + " SOT " +;
               " WHERE SOR.OR_FILIAL   = '" + xFilial("SOR") + "' " +;
                 " AND SOT.OT_FILIAL   = '" + xFilial("SOT") + "' " +;
                 " AND SOR.R_E_C_N_O_   = SOT.OT_RGSOR "

    If lFilNeces
      cQuery += " AND SOT.OT_QTNECE <> 0 "
    Else
      cQuery += " AND (SOT.OT_QTNECE <> 0 " +;
                "  OR  SOT.OT_QTSAID <> 0 " +;
                "  OR  SOT.OT_QTSALD <> 0 " +;
                "  OR  SOT.OT_QTSEST <> 0 " +;
                "  OR  SOT.OT_QTENTR <> 0 " +;
                "  OR  SOT.OT_QTSLES <> 0) "
   EndIf
   cQuery += " ORDER BY SOR.OR_PROD, " +;
                      " SOR.OR_OPCORD, " +;
                      " SOR.OR_NRRV "

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   dbSelectArea(cAliasTop)

   If (oCenterPanel==Nil)
      ProcRegua(LastRec())
   Else
      oCenterPanel:SetRegua1((cAliasTop)->(LastRec()))
   EndIf

   While !Eof()
      If (oCenterPanel!=Nil)
         oCenterPanel:IncRegua1(OemToAnsi(STR0106))
      EndIf
           
      AADD(aDbTree,{(cAliasTop)->OR_PROD,(cAliasTop)->OR_OPCORD,(cAliasTop)->OR_NRRV,"","","",StrZero((cAliasTop)->(Recno()),12),""})

      dbSkip()
   End
   If (oCenterPanel<>Nil)
      oCenterPanel:IncRegua2()
   EndIf

   (cAliasTop)->(dbCloseArea())
Else
   //Zera os valores para recalculo do produto posicionado
   aTotais := {{}}

   If lFilNeces
      cAliasTop := "FILTRATREE"
      cQuery := " SELECT DISTINCT SOQ.R_E_C_N_O_ SOQREC " +;
                   " FROM " + RetSqlName("SOQ") + " SOQ, " +;
                              RetSqlName("SOR") + " SOR, " +;
                              RetSqlName("SOT") + " SOT  " +;
                  " WHERE SOQ.OQ_FILIAL  = '" + xFilial("SOQ") + "' " +;
                    " AND SOR.OR_FILIAL  = '" + xFilial("SOR") + "' " +;
                    " AND SOT.OT_FILIAL  = '" + xFilial("SOT") + "' " +;
                    " AND SOQ.OQ_PROD    = SOR.OR_PROD " +;
                    " AND SOQ.OQ_OPCORD  = SOR.OR_OPCORD " +;
                    " AND SOQ.OQ_NRRV    = SOR.OR_NRRV " +;
                    " AND SOR.R_E_C_N_O_ = SOT.OT_RGSOR " +;
                    " AND SOT.OT_QTNECE  > 0 " +;
                    " AND SOQ.OQ_EMP     = SOR.OR_EMP " +;
                    " AND SOQ.OQ_FILEMP  = SOR.OR_FILEMP "
      cQuery := ChangeQuery(cQuery)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
      dbSelectArea(cAliasTop)
   Else
      dbSelectArea("SOQ")
      dbSetOrder(1)
      dbSeek(xFilial("SOQ"))
      cAliasTop := "SOQ"
   EndIf
   //Busca os dados detalhados, todos os registros da SOQ

   If (oCenterPanel==Nil)
      ProcRegua(LastRec())
   Else
      oCenterPanel:SetRegua1((cAliasTop)->(LastRec()))
   EndIf

   While !Eof() //.And. (OQ_FILIAL = xFilial("SOQ"))
      If (oCenterPanel!=Nil)
         oCenterPanel:IncRegua1(OemToAnsi(STR0106))
      EndIf

      If lFilNeces
         SOQ->(dbGoTo((cAliasTop)->SOQREC))
      EndIf

      If SOQ->OQ_ALIAS # "PAR" .And. SOQ->OQ_ALIAS # "TRA"
         // Estrutura do array
         // Produto
         // Opcional
         // Revisao
         // Alias
         // Tipo
         // Documento
         // Recno
         // DocRev

         AADD(aDbTree,{SOQ->OQ_PROD,SOQ->OQ_OPCORD,SOQ->OQ_NRRV,SOQ->OQ_ALIAS,SOQ->OQ_TPRG,SOQ->OQ_DOC,StrZero(SOQ->(Recno()),12),SOQ->OQ_DOCREV})

         //Adiciona registro em array totalizador utilizado no TREE
         If Len(aTotais[Len(aTotais)]) > 4095
            AADD(aTotais,{})
         EndIf
         For i := 1 to Len(aTotais[1])
            if aTotais[1,i,1] == SOQ->OQ_PROD+SOQ->OQ_OPCORD+SOQ->OQ_NRRV .And. aTotais[1,i,2] == SOQ->OQ_PERMRP .And. aTotais[1,i,3] == SOQ->OQ_ALIAS
               nAchouTot := i
            else
               nAchouTot := 0
               loop
            EndIf
            If nAchouTot != 0
               aTotais[1,nAchouTot,4] += SOQ->OQ_QUANT
               Exit
            EndIf
         Next i

         If nAchouTot == 0
            AADD(aTotais[Len(aTotais)],{SOQ->OQ_PROD + SOQ->OQ_OPCORD + SOQ->OQ_NRRV,SOQ->OQ_PERMRP,SOQ->OQ_ALIAS,SOQ->OQ_QUANT})
         EndIf
      EndIf

      If lFilNeces
         dbSelectArea(cAliasTop)
      EndIf

      dbSkip()
   End
   If lFilNeces
      (cAliasTop)->(dbCloseArea())
   Else
      SOQ->(dbCloseArea())
   EndIf

   If (oCenterPanel<>Nil)
      oCenterPanel:IncRegua2()
   EndIf
EndIf

A107GrvTm(oCenterPanel,STR0114) //"Termino da Montagem da Arvore de Produtos (Tree)."
ASORT(aDbTree,,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5]})
A107AdTree(.T.,aDbTree,lResumido)
A107GrvTm(oCenterPanel,STR0115) //"FIM - Termino da Montagem da Tela"

//Atualiza o log de processamento
ProcLogAtu("MENSAGEM","Termino da Montagem Tree do MRP","Termino da Montagem Tree do MRP")

Return

/*-------------------------------------------------------------------------/
//Programa: A107AdTree
//Autor:    Lucas Konrad França
//Data:     25/11/2014
//Descricao:   Rotina para incluir documento do arquivo SH5 no tree do MRP
//Parametros:  01.lTodosDados - Indica inclusao de multiplos itens no TREE
//             02.aDadosTree     - Array com dados organizados para inclusao no TREE
//             03.lResumido      - Monta Array resumido somente com os produtos
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107AdTree(lTodosDados,aDadosTree,lResumido)
Local aTexto      := {}
Local cOldCargo   := "" //oTreeM711:GetCargo()
Local cOldAlias   := ""
Local nz       := 0
Local nPos        := 0
Local cProduto := ""
Local cOpc        := ""
Local cRevisao := ""
Local cDadosPrd   := ""
Local cDadosArq   := ""
Local cImg     := ""
Local clegen      := ""
Local lShAlt      := If(ExistBlock("M710ShAlt"),execblock('M710SHAlt',.F.,.F.),.F.)

DEFAULT lTodosDados := .F.
DEFAULT lResumido   := .F.

If !lAddTree
   Return
EndIf

cOldCargo := oTreeM711:GetCargo()

AADD(aTexto,{"SC1",STR0078}) //"Solicitacao de Compra"
AADD(aTexto,{"SC7",STR0079}) //"Pedido de Compra / Autorizacao de Entrega"
AADD(aTexto,{"SC2",STR0080}) //"Ordem de Producao"
AADD(aTexto,{"SHC",STR0081}) //"Plano Mestre de Producao"
AADD(aTexto,{"SD4",STR0082}) //"Empenho"
AADD(aTexto,{"SC6",STR0083}) //"Pedido de Venda"
AADD(aTexto,{"SC4",STR0084}) //"Previsao de Venda"
AADD(aTexto,{"AFJ",STR0085}) //"Empenhos para Projeto"
AADD(aTexto,{"SOR",STR0116}) //"Necessidade Estrutura"
AADD(aTexto,{"ENG",STR0086}) //"Subproduto Estrutura"
AADD(aTexto,{"SB1",STR0117}) //"Cadastro de Produto"
AADD(aTexto,{"SB8",STR0118}) //"Lotes Vencidos"
AADD(aTexto,{"SBP",STR0088}) //"Nec. Subproduto"

//Incrementa os dados do array no tree - SEMPRE CONTEM DADOS DE UM UNICO PRODUTO
If !lTodosDados
   // Estrutura do array
   // 01 Produto
   // 02 Opcional
   // 03 Revisao
   // 04 Alias
   // 05 Tipo
   // 06 Documento
   // 07 Recno
   // 08 DocRev
   For nz := 1 to Len(aDadosTree)
      //Incluir produto caso necessario e muda a legenda se o produto tiver alternativo, se Tem SGI e PE M710ShAlt = T
         cLegen := 'PMSEDT4'
       If lShAlt
         dbSelectArea("SGI")
         dbSetOrder(1)
         If MSSeek(xFilial("SGI")+aDadosTree[nz,1])
            cLegen := 'PMSEDT2'
         EndIf
      endIf
      nPos := ASCAN(aDbTree,{|x| x[1] == aDadosTree[nz,1]})

      If Empty(nPos)
         oTreeM711:AddItem(AllTrim(aDadosTree[nz,1])+If(Empty(aDadosTree[nz,2]),""," / "+Alltrim(aDadosTree[nz,2])) + A107StrRev(aDadosTree[nz,3]),"01"+aDadosTree[nz,7]+StrZero(0,12),cLegen,cLegen,,,2)
         cDadosPrd:=aDadosTree[nz,7]+StrZero(0,12)
      Else
         cDadosPrd:=aDbTree[nPos,7]+StrZero(0,12)
      EndIf

      If !lResumido
         //Inclui tipo de arquivo caso necessario
         nPos := ASCAN(aDbTree,{|x| x[1]+x[4] == aDadosTree[nz,1]+aDadosTree[nz,4]})
         If Empty(nPos)
            cDadosArq := aDadosTree[nz,7]+aDadosTree[nz,4]
         Else
            cDadosArq := aDbTree[nPos,7]+aDbTree[nPos,4]
         EndIf

         //Pesquisa no TREE tipo de arquivo
         If !oTreeM711:TreeSeek("02"+cDadosArq)
            //Posiciona no TREE produto
            oTreeM711:TreeSeek("01"+cDadosPrd)
            //Coloca tipo de arquivo - TREE
            oTreeM711:AddItem(aTexto[Ascan(aTexto,{ |x| x[1] == aDadosTree[nz,4]}),2],"02"+aDadosTree[nz,7]+aDadosTree[nz,4],If(aDadosTree[nz,5]=="2","PMSEDT3","PMSEDT1"),If(aDadosTree[nz,5]=="2","PMSEDT3","PMSEDT1"),,,2)
         EndIf

         //Posiciona tipo de arquivo - TREE
         oTreeM711:TreeSeek("02"+cDadosArq)
         SOQ->(dbGoTo(Val(aDadosTree[nz,7])))
         If aDadosTree[nz,5]$"23" .And. If(aDadosTree[nz,4]=="ENG",!Empty(SOQ->OQ_DOCKEY),aDadosTree[nz,4]#"SBP")
            cImg := "PMSDOC"
         Else
            cImg := "relacionamento_direita"
         EndIf

         If !oTreeM711:TreeSeek("03"+aDadosTree[nz,7]+aDadosTree[nz,7])
            //Coloca documento - TREE
            oTreeM711:AddItem(AllTrim(aDadosTree[nz,6])+A107StrRev(aDadosTree[nz,8]),"03"+aDadosTree[nz,7]+aDadosTree[nz,7],cImg,cImg,,,2)
         EndIf
      EndIf

      nPos:=ASCAN(aDbTree,{|x| x[7] == aDadosTree[nz,7]})

      //Adiciona no array do tree
      If Empty(nPos)
         AADD(aDbTree,aDadosTree[nz])
      EndIf
   Next nz

   oTreeM711:TreeSeek(cOldCargo)
Else //Inclui todos os itens no tree
   //Monta tree na primeira vez
   oTreeM711:BeginUpdate()
   oTreeM711:Reset()
   oTreeM711:EndUpdate()
   // Estrutura do array
   // Produto
   // Opcional
   // Alias
   // Revisao
   // Tipo
   // Documento
   // Recno
   For nz := 1 to Len(aDadosTree)
      // Muda a legenda se o produto tiver alternativo, se tem SGI e se PE M710ShAlt = T
         cLegen := 'PMSEDT4'
         If lShAlt
         dbSelectArea("SGI")
         dbSetOrder(1)
         If MSSeek(xFilial("SGI")+aDadosTree[nz,1])
            cLegen := 'PMSEDT2'
         EndIf
      EndIF

      //Verifica se mudou o produto ou se é o primeiro produto
      If cProduto+cOpc+cRevisao # aDadosTree[nz,1]+aDadosTree[nz,2]+aDadosTree[nz,3]
         If Empty(cProduto+cOpc+cRevisao)
            //Coloca titulo no TREE
            oTreeM711:AddTree(STR0060+" / "+STR0061+Space(80),.T.,,,cLegen,cLegen,"00"+aDadosTree[nz,7]+StrZero(0,12))
         Else
            //Encerra tree do produto
            oTreeM711:EndTree()
         EndIf

         cProduto  := aDadosTree[nz,1]
         cOpc      := aDadosTree[nz,2]
         cRevisao  := aDadosTree[nz,3]
         cOldAlias := ""

         //Adiciona Produto no TREE
         oTreeM711:AddTree(AllTrim(cProduto)+If(Empty(cOpc),""," / "+Alltrim(cOpc)) + A107StrRev(cRevisao),.T.,,,cLegen,cLegen,"01"+aDadosTree[nz,7]+StrZero(0,12))
      EndIf

      //Verifica se mudou o tipo de arquivo totalizado
      If !lResumido
         If cOldAlias # aDadosTree[nz,4]
            cOldAlias := aDadosTree[nz,4]
            //Adiciona na TREE
            oTreeM711:AddTree(aTexto[Ascan(aTexto,{ |x| x[1] == aDadosTree[nz,4]}),2],.T.,,,If(aDadosTree[nz,5]=="2","PMSEDT3","PMSEDT1"),If(aDadosTree[nz,5]=="2","PMSEDT3","PMSEDT1"),"02"+aDadosTree[nz,7]+aDadosTree[nz,4])
         EndIf

         //Posiciona para buscar DOCKEY
         SOQ->(dbGoTo(Val(aDadosTree[nz,7])))

         //Verifica condição do DOCKEY
         If aDadosTree[nz,5]$"23" .And. If(aDadosTree[nz,4]=="ENG",!Empty(SOQ->OQ_DOCKEY),aDadosTree[nz,4]#"SBP")
            cImg := "PMSDOC"
         Else
            cImg := "relacionamento_direita"
         EndIf

         //Adiciona na TREE
         oTreeM711:AddTreeItem(AllTrim(aDadosTree[nz,6])+A107StrRev(aDadosTree[nz,8]),cImg,cImg,"03"+aDadosTree[nz,7]+aDadosTree[nz,7])

         If (nz < Len(aDadosTree) .And. ((aDadosTree[nz+1,4] # cOldAlias) .Or. (cProduto+cOpc+cRevisao # aDadosTree[nz+1,1]+aDadosTree[nz+1,2]+aDadosTree[nz+1,3]))) .Or. nz == Len(aDadosTree)
            //Encerra tree do tipo de arquivo qdo muda de tipo de arquivo ou muda de produto
            oTreeM711:EndTree()
         EndIf
      EndIf
   Next nz

   If Len(aDadosTree) > 0
      // Encerra tree do produto
      oTreeM711:EndTree()
      // Encerra tree inteiro
      oTreeM711:EndTree()
   EndIf
EndIf

Return

/*-------------------------------------------------------------------------/
//Programa: PA107DlgV
//Autor:    Lucas Konrad França
//Data:     25/11/2014
//Descricao:   Funcao que mostra as informacoes detalhadas da consulta
//Parametros:  01.aEnch    - Array com os objetos a serem apresentados
//             02.aPos     - Array com as coordenadas utilizadas na apresentacao
//             03.nOldEnch - Variavel com o objeto anteriormente apresentado
//             04.oSay1    - Objeto com a descricao do produto
//             05.cAliasTab   - Passa o Alias da tabela de resultados
//             06.oSay2    - Objeto com a descricao do produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PA107DlgV(aEnch,aPos,nOldEnch,oSay1,cAliasTab, oSay2)
Local cTipo711 := SubStr(oTreeM711:GetCargo(),1,2)
Local nRecno      := Val(SubStr(oTreeM711:GetCargo(),3,12))
Local cAliasPos   := ''
Local cEmpresa    := cEmpAnt
Local cFiliBkp    := cFilAnt
Local aTamQuant   := TamSX3("B2_QFIM")
Local lOneColumn  := If(aPos[4]-aPos[2]>312,.F.,.T.)
Local aTexto      := {}
Local aAdPeriodos := {}
Local aTextoVazio := Array(Len(aPeriodos))
Local i           := 0
Local z           := 0
Local nInd        := 0
Local nPosAlias   := 0
Local w           := 0
Local nPosTree    := 0
Local nAchouTot   := 0
Local aCampos     := {}
Local aAreaBkp    := GetArea()
Local desc1
Local desc2

PRIVATE cProdShow := ''
PRIVATE cOpcShow  := ''
PRIVATE cRevisao  := ''
PRIVATE cBotFun   := ''
PRIVATE cTopFun   := ''
PRIVATE aRotina   := {{" "," ", 0 , 2}}

//Possiciona array do tree
nPosTree := AsCan(aDbTree,{|x| x[7]==SubStr(oTreeM711:GetCargo(),3,12)})

//Inicializa variaveis
If nPosTree > 0
   cAliasPos   := aDbTree[nPosTree,4]
   cProdShow   := aDbTree[nPosTree,1]
   cOpcShow := IIf(LEN(aDbTree[nPosTree,2]) > 200,Substr(aDbTree[nPosTree,2],1,200),aDbTree[nPosTree,2])
   cRevisao := aDbTree[nPosTree,3]

   //Preenche descricao do produto
   if Len((Posicione('SB1',1,xFilial('SB1')+cProdShow,"B1_DESC"))) > 30
      desc1 := SubStr((Posicione('SB1',1,xFilial('SB1')+cProdShow,"B1_DESC")),1,30)
      desc2 := SubStr((Posicione('SB1',1,xFilial('SB1')+cProdShow,"B1_DESC")),31,20)
      oSay1:SetText(desc1)
      oSay2:SetText(desc2)
   else
      oSay1:SetText(Posicione('SB1',1,xFilial('SB1')+cProdShow,"B1_DESC"))
   End if

   //Atualiza com o produto posicionado
   cProdDetSld := cProdShow
Else
   cTipo711 := "00"
EndIf

//Monta Numero de Colunas de acordo com numero de periodos
AFILL(aTextoVazio,"")

MsFreeObj(@oPanelM711 , .T.)
MsFreeObj(@oScrollM711, .T.)
oSayEmp:SetText("")
oSayEmp:CtrlRefresh()
//SCROLL BOX com texto vazio ou totalizador por tipo de documento
If cTipo711 == "00"
   //Limpa conteudo de variavel
   cProdDetSld := ""

   oSay1:SetText("")
   oPanelM711:Hide()

   //Cria o array dos campos para o browse
   aCampos := {{"TEXTO","",STR0059,20}} //"Tipo"
   AADD(aCampos,{"PRODSHOW","",STR0060,LEN(SOR->OR_PROD)}) //"Produtos"
   AADD(aCampos,{"OPCSHOW","",STR0061,LEN(SOR->OR_OPCORD)}) //"Opcionais"
   AADD(aCampos,{"REVSHOW","",STR0062,4}) //"Revisao"

   For nInd := 1 to Len(aPeriodos)
      AADD(aCampos,{"PER"+StrZero(nInd,3),cPictQuant,DtoC(aPeriodos[nInd]),aTamQuant[1]+2})
   Next i

   dbSelectArea(cAliasTab)

   //Monta browse de todos os produtos
   nOldEnch := 1
   aEnch[nOldEnch] := MaMakeBrow(oPanelM711,cAliasTab,{aPos[1],aPos[2],aPos[4],aPos[3]-5},,.F.,aCampos,,cTopFun,cBotFun,NIL,NIL,2)

   // Refaz browse com informacoes de todos os produtos
   oPanelM711:Refresh()
   oPanelM711:Show()
ElseIf cTipo711 == "01"
   oPanelM711:Hide()

   //Monta array com os campos a serem utilizados no Browse
   cBotFun   := PutAspas(cProdShow+cOpcShow+cRevisao)
   cTopFun   := PutAspas(cProdShow+cOpcShow+cRevisao)

   aCampos:={{"TEXTO","",STR0059,20}} //"Tipo"
   For i := 1 to Len(aPeriodos)
      AADD(aCampos,{"PER"+StrZero(i,3),cPictQuant,DtoC(aPeriodos[i]),aTamQuant[1]+2})
   Next i

   dbSelectArea(cAliasTab)

   //Monta browse referente a esse produto
   nOldEnch := 1
   aEnch[nOldEnch] := MaMakeBrow(oPanelM711,cAliasTab,{aPos[1],aPos[2],aPos[4],aPos[3]-5},,.F.,aCampos,,cTopFun,cBotFun,NIL,{|| A107CLKBRW()},1)

   oBrwDet := aEnch[nOldEnch]

   //Posiciona no primeiro registro desse produto
   (cAliasTab)->(dbSeek(cProdShow+cOpcShow+cRevisao))

   //Posiciona no primeiro registro
   (cAliasTab)->(dbGotop())

   //Refaz browse com informacoes desse produto
   oPanelM711:Refresh()
   oPanelM711:Show()
ElseIf cTipo711 == "02"
   //Procura totalizadores por tipo de documento para esse produto+opcional
   aAdPeriodos := ACLONE(aTextoVazio)

   //Coloca na primeira coluna texto
   aAdPeriodos[1] := STR0119 //"Totais"
   AADD(aTexto,aAdPeriodos)
   aAdPeriodos := ACLONE(aTextoVazio)

   //Coloca data nas colunas
   For w := 1 to Len(aPeriodos)
      aAdPeriodos[w] := DTOC(aPeriodos[w])
   Next w

   AADD(aTexto,aAdPeriodos)
   aAdPeriodos := ACLONE(aTextoVazio)

   //Monta os valores de acordo com os periodos
   For z := 1 to Len(aPeriodos)
      For i:=1 to Len(aTotais)
         nAchouTot:=ASCAN(aTotais[i],{ |x| x[1] == cProdShow+cOpcShow+cRevisao .And. x[2] == StrZero(z,3) .And. x[3] == cAliasPos})
         If nAchouTot != 0
            aAdPeriodos[z] := Transform(aTotais[i,nAchouTot,4],cPictQuant)
            Exit
         Else
            aAdPeriodos[z] := Transform(0, cPictQuant)
         EndIf
      Next i
   Next z

   AADD(aTexto,aAdPeriodos)
   aAdPeriodos := ACLONE(aTextoVazio)

   //Coloca na primeira coluna texto
   aAdPeriodos[1] := STR0120 //"Data Limite para Compra / Producao"
   AADD(aTexto,aAdPeriodos)
   aAdPeriodos := ACLONE(aTextoVazio)

   //Coloca data limite nas colunas de acordo com as datas especificadas
   For z := 1 to Len(aPeriodos)
      For i := 1 to Len(aTotais)
         nAchouTot := ASCAN(aTotais[i],{ |x| x[1] == cProdShow + cOpcShow + cRevisao .And. x[2] == StrZero(z,3) .And. x[3] == cAliasPos})
         If nAchouTot != 0
            aAdPeriodos[z] := DTOC(SomaPrazo(aPeriodos[z], - CalcPrazo(cProdShow,aTotais[i,nAchouTot,4],,,.F.,aPeriodos[z])))
            Exit
         Else
            aAdPeriodos[z] := ""
         EndIf
      Next i
   Next z

   AADD(aTexto,aAdPeriodos)

   MatScrDisp(aTexto,@oScrollM711,@oPanelM711,{aPos[1],aPos[2],Round(aPos[3],0)-5,aPos[4]},NIL,{{2,CLR_RED},{4,CLR_GREEN}})
   nOldEnch := 2
   aEnch[nOldEnch]:=oScrollM711
ElseIf cTipo711 == "03" //Detalhe dos documentos
   //Monta MSMGET para apresentar dados detalhados
   dbSelectArea("SOQ")
   MsGoto(nRecno)

   cAliasPos := SOQ->OQ_ALIAS
   nRecPos   := SOQ->OQ_NRRGAL

   //Necessidade relacionada a estrutura
   If cAliasPos == "SOR"
      aTexto := {{STR0066,SOQ->OQ_DOC}}

      oSayEmp:SetText(STR0149+": "+SOQ->OQ_EMP+"/"+SOQ->OQ_FILEMP)
      oSayEmp:CtrlRefresh()

      AADD(aTexto,{lTrim(STR0113),Str(SOQ->OQ_QUANT,aTamQuant[1],aTamQuant[2])})
      AADD(aTexto,{STR0077,DTOC(aPeriodos[Val(SOQ->OQ_PERMRP)])})

      MatScrDisp(aTexto,@oScrollM711,@oPanelM711,{aPos[1],aPos[2],Round(aPos[3],0)-5,aPos[4]},{{1,CLR_RED}})
      nOldEnch := 3
      aEnch[nOldEnch] := oScrollM711
   ElseIf cAliasPos $ "ENG/SBP"  //Quantidade negativa na estrutura
      aTexto := {{STR0086,SOQ->OQ_DOC}}

      AADD(aTexto,{lTrim(STR0100),Str(SOQ->OQ_QUANT,aTamQuant[1],aTamQuant[2])})
      AADD(aTexto,{STR0077,DTOC(aPeriodos[Val(SOQ->OQ_PERMRP)])})

      MatScrDisp(aTexto,@oScrollM711,@oPanelM711,{aPos[1],aPos[2],Round(aPos[3],0)-3,aPos[4]},{{1,CLR_RED}})
      nOldEnch := 3
      aEnch[nOldEnch] := oScrollM711
   /*ElseIf cAliasPos == "SB1" .And. SBZ->(DbSeek(xFilial("SBZ")+SB1->B1_COD))
      nRecPos := Recno()
      NGPrepTBL({{"SBZ",1}},SOQ->OQ_EMP,SOQ->OQ_FILEMP)
      oSayEmp:SetText(STR0149+": "+SOQ->OQ_EMP+"/"+SOQ->OQ_FILEMP)
      oSayEmp:CtrlRefresh()
      RegToMemory("SBZ",.F.)
      MsMGet():New("SBZ",nRecPos,1,,,,,{aPos[1],aPos[2],Round(aPos[3],0)-3,aPos[4]},,3,,,,oPanelM711,,,lOneColumn)
   Else //MSMGET com detalhe do documento
      //Se o registro é de outra empresa, prepara a tabela da outra empresa para a leitura.
      NGPrepTBL({{cAliasPos,1}},SOQ->OQ_EMP,SOQ->OQ_FILEMP)
      oSayEmp:SetText(STR0149+": "+SOQ->OQ_EMP+"/"+SOQ->OQ_FILEMP)
      oSayEmp:CtrlRefresh()
      dbSelectArea(cAliasPos)
      dbGoto(nRecPos)
      RegToMemory(cAliasPos,.F.)
      MsMGet():New(cAliasPos,nRecPos,1,,,,,{aPos[1],aPos[2],Round(aPos[3],0)-3,aPos[4]},,3,,,,oPanelM711,,,lOneColumn)
   EndIf*/
   Else
      If cAliasPos == "SB1"
         NGPrepTBL({{"SBZ",1}},SOQ->OQ_EMP,AllTrim(SOQ->OQ_FILEMP))
         If cDadosProd == "SBZ" .And. SBZ->(DbSeek(xFilial("SBZ")+SB1->B1_COD))
            nRecPos := Recno()
            //NGPrepTBL({{"SBZ",1}},SOQ->OQ_EMP,SOQ->OQ_FILEMP)
            oSayEmp:SetText(STR0149+": "+SOQ->OQ_EMP+"/"+SOQ->OQ_FILEMP)
            oSayEmp:CtrlRefresh()
            RegToMemory("SBZ",.F.)
            MsMGet():New("SBZ",nRecPos,1,,,,,{aPos[1],aPos[2],Round(aPos[3],0)-3,aPos[4]},,3,,,,oPanelM711,,,lOneColumn)
         Else
            //Se o registro é de outra empresa, prepara a tabela da outra empresa para a leitura.
            NGPrepTBL({{cAliasPos,1}},SOQ->OQ_EMP,AllTrim(SOQ->OQ_FILEMP))
            oSayEmp:SetText(STR0149+": "+SOQ->OQ_EMP+"/"+SOQ->OQ_FILEMP)
            oSayEmp:CtrlRefresh()
            dbSelectArea(cAliasPos)
            dbGoto(nRecPos)
            RegToMemory(cAliasPos,.F.)
            MsMGet():New(cAliasPos,nRecPos,1,,,,,{aPos[1],aPos[2],Round(aPos[3],0)-3,aPos[4]},,3,,,,oPanelM711,,,lOneColumn)
         EndIf
      Else //MSMGET com detalhe do documento
         //Se o registro é de outra empresa, prepara a tabela da outra empresa para a leitura.
         NGPrepTBL({{cAliasPos,1}},SOQ->OQ_EMP,AllTrim(SOQ->OQ_FILEMP))
         oSayEmp:SetText(STR0149+": "+SOQ->OQ_EMP+"/"+SOQ->OQ_FILEMP)
         oSayEmp:CtrlRefresh()
         dbSelectArea(cAliasPos)
         dbGoto(nRecPos)
         RegToMemory(cAliasPos,.F.)
         MsMGet():New(cAliasPos,nRecPos,1,,,,,{aPos[1],aPos[2],Round(aPos[3],0)-3,aPos[4]},,3,,,,oPanelM711,,,lOneColumn)
      EndIf
   EndIf
EndIf

Return

/*-------------------------------------------------------------------------/
//Programa: A107Gera
//Autor:    Rodrigo de Almeida Sartorio
//Data:     22.08.02
//Descricao:   Gera OP/SC de acordo com os Periodos Selecionados
//Parametros:  01.cNumOpDig - Numero da Op inicial a ser digitado pelo usuario
//          02.cStrTipo  - String com tipos a serem processados
//          03.cStrGrupo - String com grupos a serem processados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107Gera(cNumOpDig,cStrTipo,cStrGrupo,oCenterPanel)
Local aSays    := {}
Local aButtons := {}
Local nOpca    := 0
Local nCount   := 0
Local nI       := 0
Local lOpMax99 := .T.
Local nRetry_0  := 0
Local nRetry_1  := 0
Local cValue    := ""
Local cTotal    := ""
Local cCount    := ""
Local cBkpEmp   := cEmpBkp
Local cBkpFil   := cFilBkp

If AllTrim(cEmpAnt) != AllTrim(cEmpBkp) .Or. AllTrim(cFilAnt) != AllTrim(cFilBkp)
	A107AltEmp(cEmpBkp, cFilBkp)
EndIf

AADD(aSays,OemToAnsi(STR0121))
AADD(aSays,OemToAnsi(STR0122))
AADD(aSays,OemToAnsi(STR0123))
AADD(aButtons, { 1,.T.,{|o| nOpcA:= 1,If(MsgYesNo(OemToAnsi(STR0124),OemToAnsi(STR0030)),o:oWnd:End(),nOpcA:=2) } } )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

If aPergs711[4] == 2
   AADD(aButtons, { 5,.T.,{|o| cSelPerSC:=A107SelPer(cSelPerSc,STR0125,"SC",@cNumOpDig,@lOpMax99,@cSelFSC) }} )
   AADD(aButtons, { 5,.T.,{|o| cSelPer:=A107SelPer(cSelPer,STR0126,"OP",@cNumOpDig,@lOpMax99,@cSelF) }} )
Else
   AADD(aButtons, { 5,.T.,{|o| cSelPerSC:=cSelPer:=A107SelPer(cSelPer,STR0125+" / "+STR0126,"SCOP",@cNumOpDig,@lOpMax99,@cSelF) }} )
EndIf

If !lBatch
   For nI := 1 To Len(aEmpCent)
      NGPrepTBL({{"SOD",1},{"SOE",1}},aEmpCent[nI][1],AllTrim(aEmpCent[ni][2]))
      If PCPIntgPPI()
         //Busca o parâmetro de integração de OP's com o PPI.
         cIntgPPI := PCPIntgMRP()
         If cIntgPPI != "1"
            cValue := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2]))
            cTotal := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2])+"TOTAL")
            cCount := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2])+"COUNT")
            If !Empty(cValue) .And. (cValue != "3" .And. cValue != "30")
               MsgInfo(STR0183+CHR(13)+CHR(10)+ STR0080 + " " + cCount + STR0098 + cTotal,STR0030) //"A integração da exclusão de ordens de produção previstas com o Totvs MES ainda está em processamento, por favor aguarde." \n "Ordem de produção " XXX de XXX "Atenção"
               NGPrepTBL({{"SOD",1},{"SOE",1}},cBkpEmp,cBkpFil)
               Return Nil
            EndIf
         EndIf
      EndIf
   Next nI
   NGPrepTBL({{"SOD",1},{"SOE",1}},cBkpEmp,cBkpFil)
   FormBatch(STR0030,aSays,aButtons,,200,450)
Else
   For nI := 1 To Len(aEmpCent)
      NGPrepTBL({{"SOD",1},{"SOE",1}},aEmpCent[nI][1],AllTrim(aEmpCent[ni][2]))
      If PCPIntgPPI()
         //Busca o parâmetro de integração de OP's com o PPI.
         cIntgPPI := PCPIntgMRP()
         If cIntgPPI != "1"
             cValue := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2]))
            While !Empty(cValue) .And. (cValue != "3" .And. cValue != "30")
               Sleep(500)
               cValue := GetGlbValue("A107IntPPI"+aEmpCent[nI][1]+AllTrim(aEmpCent[ni][2]))
            End
         EndIf
      EndIf
   Next nI
   NGPrepTBL({{"SOD",1},{"SOE",1}},cBkpEmp,cBkpFil)
   nOpca := 1
Endif

lDigNumOp := !Empty(cNumOpDig)

If nOpca == 1
   //Seta variável para não atualizar a tree neste momento
   lAddTree := .F.
   //Conout(Replicate("#",70))
   //Conout("###--INICIO PROCESSAMENTO GERACAO DE OP/SC MRP MULTIEMPRESAS.")
   //Conout("###--DATA:" + DtoC(Date()))
   //Conout("###--HORA:" + TIME())
   //Conout(Replicate("#",70))
   //Emite OP's e SC's
   A107Proc("2", {cNumOpDig,lOpMax99,cStrTipo,cStrGrupo,oCenterPanel},lBatch)
   //Conout(Replicate("#",70))
   //Conout("###--FIM PROCESSAMENTO GERACAO DE OP/SC MRP MULTIEMPRESAS.")
   //Conout("###--DATA:" + DtoC(Date()))
   //Conout("###--HORA:" + TIME())
   //Conout(Replicate("#",70))
EndIf

Return Nil

/*-------------------------------------------------------------------------/
//Programa: A107OPSC
//Autor:    Lucas Konrad França
//Data:     19/12/2014
//Descricao:   Gera OP/SC de acordo com os Periodos Selecionados
//Parametros:  01.cNumOpDig - Numero da Op inicial a ser digitado pelo usuario
//             02.cStrTipo  - String com tipos a serem processados
//             03.cStrGrupo - String com grupos a serem processados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107OPSC(cNumOpDig,lOpMax99,cStrTipo,cStrGrupo,oCenterPanel)
   Local nCount     := 0
   Local cAliasTop  := ""
   Local cQueryCnt  := ""
   Local nQtd       := 0
   Local cSql       := ""
   Local lMT710OPSC := ExistBlock("MTA710OPSC")
   Private aPmpProc := {}
   //Insere os dados na tabela de BKP da SOS.
   //Esta tabela é utilizada para não alterar as informações da tabela SOS durante a geração da tabela SOU
   //São utilizadas duas tabelas, uma para a criação da tabela SOU, e outra para a criação da tabela NNS/NNT.
   //É necessário a utilização da tabela temporária, pois para gerar a SOU/NNS/NNT é preciso alterar os registros
   //da tabela SOS durante o processamento.

   cSql := " DELETE FROM SOSBKP "
   If TCSQLExec(cSql) < 0
      Alert(TCSQLError())
   EndIf

   cSql := " DELETE FROM SOSBKP2 "
   If TCSQLExec(cSql) < 0
      Alert(TCSQLError())
   EndIf

   cSql := " INSERT INTO SOSBKP (FILIAL, SOTORIG, SOTDEST, QUANT, TIPO, R_E_C_N_O_) "
   cSql +=   " SELECT SOS.OS_FILIAL, "
   cSql +=          " SOS.OS_SOTORIG, "
   cSql +=          " SOS.OS_SOTDEST, "
   cSql +=          " SOS.OS_QUANT, "
   cSql +=          " SOS.OS_TIPO, "
   cSql +=          " SOS.R_E_C_N_O_ "
   cSql +=    " FROM " + RetSqlName("SOS") + " SOS "

   If TCSQLExec(cSql) < 0
      Alert(TCSQLError())
   EndIf

   cSql := " INSERT INTO SOSBKP2 (FILIAL, SOTORIG, SOTDEST, QUANT, TIPO, R_E_C_N_O_) "
   cSql +=   " SELECT SOS.OS_FILIAL, "
   cSql +=          " SOS.OS_SOTORIG, "
   cSql +=          " SOS.OS_SOTDEST, "
   cSql +=          " SOS.OS_QUANT, "
   cSql +=          " SOS.OS_TIPO, "
   cSql +=          " SOS.R_E_C_N_O_ "
   cSql +=    " FROM " + RetSqlName("SOS") + " SOS "

   If TCSQLExec(cSql) < 0
      Alert(TCSQLError())
   EndIf

   If aPergs711[1] == 2
      cAliasTop := "COUNTSHC"
      cQueryCnt := " SELECT COUNT(*) HC_COUNT " +;
                     " FROM " + RetSqlName("SOQ") + " SOQ, " +;
                                RetSqlName("SHC") + " SHC, " +;
                                RetSqlName("SB1") + " SB1 " +;
                    " WHERE SOQ.OQ_FILIAL  = '" + xFilial("SOQ") + "' " +;
                      " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " +;
                      " AND SOQ.OQ_NRRGAL  = SHC.R_E_C_N_O_ " +;
                      " AND SOQ.OQ_PROD    = SB1.B1_COD " +;
                      " AND SOQ.OQ_ALIAS   = 'SHC' " +;
                      " AND SOQ.OQ_QUANT   > 0 " +;
                      " AND SHC.HC_OP      = ' ' " +;
                      " AND SOQ.D_E_L_E_T_ = ' ' "
         cQueryCnt := ChangeQuery(cQueryCnt)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasTop,.T.,.T.)
      dbSelectArea(cAliasTop)

      nQtd := (cAliasTop)->(HC_COUNT)
      (cAliasTop)->(dbCloseArea())
   EndIf
   cAliasTop := "COUNTOPSC"
   cQueryCnt := " SELECT COUNT(*) OPSC_COUNT " +;
               " FROM " + RetSqlName("SOR") + " SOR, " +;
                          RetSqlName("SOT") + " SOT, " +;
                          RetSqlName("SB1") + " SB1 " +;
              " WHERE SOR.OR_FILIAL   = '" + xFilial("SOR") + "' " +;
                " AND SOT.OT_FILIAL   = '" + xFilial("SOT") + "' " +;
                " AND SB1.B1_FILIAL    = '" + xFilial("SB1") + "' " +;
                " AND SOR.R_E_C_N_O_   = SOT.OT_RGSOR " +;
                " AND SOR.OR_PROD      = SB1.B1_COD " +;
                " AND EXISTS (SELECT 1 " +;
                              " FROM " + RetSqlName("SOT") + " SOTB " +;
                             " WHERE SOTB.OT_FILIAL = '" + xFilial("SOT") + "' " +;
                               " AND SOTB.OT_RGSOR  = SOR.R_E_C_N_O_ " +;
                               " AND SOTB.OT_QTNECE > 0) "
   cQueryCnt := ChangeQuery(cQueryCnt)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasTop,.T.,.T.)
   dbSelectArea(cAliasTop)

   nQtd += (cAliasTop)->(OPSC_COUNT)
   (cAliasTop)->(dbCloseArea())
   nQtd += Len(aEmpCent)
   nQtd++

   A107ProTot(nQtd)
   delSldMrp()
   Do While (nCount <= Len(aEmpCent))
      If Len(aEmpCent) == 1 .And. nCount == 1 .And. alltrim(aEmpCent[1,1]) == alltrim(cEmpBkp) .And. alltrim(aEmpCent[1,2]) == alltrim(cFilBkp)
         Exit
      EndIf
      If nCount > 0
         A107AltEmp(aEmpCent[nCount][1], aEmpCent[nCount][2])
      EndIf
      nCount++

      If PCPIntgPPI()
         //Busca o parâmetro de integração de OP's com o PPI.
         cIntgPPI := PCPIntgMRP()
      EndIf
     
      PCP107OPSC(cNumOpDig,lOpMax99,cStrTipo,cStrGrupo)

      //Inicia thread para integrar as ordens de produção com o PPI.
      If cIntgPPI != "1"
         StartJob("A107IntPPI",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,c711NumMRP,cIntgPPI,__cUserId)

         //Neste ponto, apenas valida se conseguiu subir a thread.
         //após subir a thread, deixa executando e antes de fechar o MRP é feita a validação da thread em execução.
         //Apenas vai fechar o MRP quando terminar o processamento da thread.
         While .T.
            Do Case
               //TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
               Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '0'
                  If nRetry_0 > 50
                     //Conout(Replicate("-",65))
                     //Conout("PCPA107: "+ "Não foi possivel realizar a subida da thread 'A107IntPPI'")
                     //Conout(Replicate("-",65))

                     //Atualiza o log de processamento
                     ProcLogAtu("MENSAGEM","Não foi possivel realizar a subida da thread 'A107IntPPI'","Não foi possivel realizar a subida da thread 'A107IntPPI'")
                     Final(STR0185) //"Não foi possivel realizar a subida da thread 'A107IntPPI'"
                  Else
                     nRetry_0 ++
                  EndIf

               //TRATAMENTO PARA ERRO DE CONEXAO
               Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '10'
                  If nRetry_1 > 5
                     //Conout(Replicate("-",65))
                     //Conout("PCPA107: Erro de conexao na thread 'A107IntPPI'")
                     //Conout("Numero de tentativas excedidas")
                     //Conout(Replicate("-",65))

                     //Atualiza o log de processamento
                     ProcLogAtu("MENSAGEM","PCPA107: Erro de conexao na thread 'A107IntPPI'","PCPA107: Erro de conexao na thread 'A107IntPPI'")
                     Final(STR0186) //"PCPA107: Erro de conexao na thread 'A107IntPPI'"
                  Else
                     //Inicializa variavel global de controle de Job
                     PutGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt),"0")
                     GlbUnLock()

                     //Reiniciar thread
                     //Conout(Replicate("-",65))
                     //Conout("PCPA107: Erro de conexao na thread 'A107IntPPI'")
                     //Conout("Tentativa numero: "      + StrZero(nRetry_1,2))
                     //Conout(Replicate("-",65))

                     //Atualiza o log de processamento
                     ProcLogAtu("MENSAGEM","Reiniciando a thread : A107IntPPI","Reiniciando a thread : A107IntPPI")

                     //Dispara thread para Stored Procedure
                     StartJob("A107IntPPI",GetEnvServer(),A107ADVPR(),cEmpAnt,cFilAnt,c711NumMRP,cIntgPPI,__cUserId)
                  EndIf
                  nRetry_1++

               //TRATAMENTO PARA ERRO DE APLICACAO
               Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '20'
                  //Conout(Replicate("-",65))
                  //Conout("PCPA107: Erro ao efetuar a conexão na thread 'A107IntPPI'")
                  //Conout(Replicate("-",65))

                  //Atualiza o log de processamento
                  ProcLogAtu("MENSAGEM","PCPA107: Erro ao efetuar a conexão na thread 'A107IntPPI'","PCPA107: Erro ao efetuar a conexão na thread 'A107IntPPI'")
                  Final(STR0187) //"PCPA107: Erro ao efetuar a conexão na thread 'A107IntPPI'"
               
               Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '2'
                  //Thread iniciou processamento, continua a execução do programa.
                  //Conout("PCPA107: Thread A107IntPPI iniciou o processamento.")
                  Exit
               
               Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '3'
                  //Já finalizou o processamento.
                  Exit
                  
               Case GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)) == '30'
                  //Já finalizou o processamento. mas com erros.
                  //Conout(GetGlbValue("A107IntPPI"+cEmpAnt+AllTrim(cFilAnt)+"ERRO"))
                  Exit
            EndCase
            Sleep(500)
         End
      EndIf

      //Ponto de Entrada apos criacao de OPs/SCs
      If lMT710OPSC
         ExecBlock("MTA710OPSC",.F.,.F.,{cNumOpdig})
      EndIf
   EndDo
   //Volta para a empresa corrente
   If nCount > 0
      A107AltEmp(cEmpBkp,cFilBkp)
   EndIf

   //Gera as solicitações de transferência
   If lGeraTrans == "3"
      //Conout(Replicate("#",70))
      //Conout("###--Iniciando geracao das Solicitacoes de Transferencia.")
      //Conout("###--DATA:" + DtoC(Date()))
      //Conout("###--HORA:" + TIME())
      //Conout(Replicate("#",70))
      a107criNNT()
      //Conout(Replicate("#",70))
      //Conout("###--Fim geracao das Solicitacoes de Transferencia.")
      //Conout("###--DATA:" + DtoC(Date()))
      //Conout("###--HORA:" + TIME())
      //Conout(Replicate("#",70))
   EndIf

   //Seta a variável para realizar a atualização da tree
   lAddTree := .T.

   //Somente atualiza a tree se não esta executando em modo batch
   If !lBatch
      //Apaga o arquivo antigo da tree
      FErase( AllTrim(oTreeM711:carqTree)+".DBF" )
      cAliasView := PCPA107MVW(.T.,"CRIATAB")
      //Inicializa o "alias" da tree para que seja criado um novo.
      oTreeM711:carqTree := ""
      //Carrega os dados da tree novamente.
      PA107Tree(aPergs711[28]==1,oCenterPanel,.F.,.F.)
   EndIf
Return Nil

/*-------------------------------------------------------------------------/
//Programa: A107SelPer
//Autor:    Rodrigo de Almeida Sartorio
//Data:     22.08.02
//Descricao:   Seleciona periodo para geracao de OPs/SCs
//Parametros:  01.cPer      - Variavel com os periodos marcados/desmarcados
//          02.cTitulo   - Titulo a ser apresentado na DIALOG
//          03.cTipo711  - Tipo da Selecao - OP / SC / OP e SC
//          04.cNumOpDig - Numero da Op inicial a ser digitado pelo usuario
//          05.lOpMax99  - Indica se o maximo de itens por op e 99
//          06.cTpOP     - Tipo da OP
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107SelPer(cPer,cTitulo,cTipo711,cNumOpDig,lOpMax99,cTpOP)
Local lOp         := "OP" $ cTipo711
Local lOpMaxDig   := lOpMax99
Local aAlterGDa   := {}
Local aHeaderPER  := {}
Local aColsPER    := {}
Local nOpca       := 0
Local nI          := 0
Local cNumOpGet   := cNumOpDig
Local cTitle      := OemToAnsi(STR0129+cTitulo) //"Periodos para geracao de "
Local cSelPer     := ""
Local nSelec      := 1
Local dDatDe   := dDataBase
Local dDatAte  := dDataBase
//Variaveis tipo objeto
Local oGetPer,oDlgPer

//Divide cabeçalho
oSize := FwDefSize():New()
oSize:SetWindowSize({000,000,300,350})
oSize:AddObject("NUMERO",100,80,.T.,.T.) //Dimensionavel
oSize:AddObject("OP"    ,100,20,.T.,.T.) //Dimensionavel
oSize:lProp := .T. //Proporcional
oSize:aMargins := {3,3,3,3} //Espaco ao lado dos objetos 0, entre eles 3
//Dispara os calculos
oSize:Process()

Aadd(aHeaderPER,{" " ,;
                 "CHKOK"   ,;
                 "@BMP",;
                 1,;
                 0,;
                 "",;
                 "",;
                 "",;
                 "",;
                 "",;
                 "",;
                 "",;
                 ""})

Aadd(aHeaderPER,{STR0198,; //Periodos
                 "PERMRP",;
               "@!",;
                 10,;
                 0,;
                 "",;
                 "",;
                 "D",;
                 "",;
                 "",;
                 "",;
                 "",;
                 ""})

Aadd(aHeaderPER,{STR0059,; //TIPO
                "C2_TPOP",;
                 "@!",;
                 1,;
                 0,;
                 "Pertence('12')",;
                 "",;
                 "C",;
                 "",;
                 "",;
                 STR0130,; // "1=Firme;2=Previsto"
                 "",;
                 ""})

AADD(aAlterGDa,"C2_TPOP")

AADD(aAlterGDa,"CHKOK")

For nI:=1 to Len(aPeriodos)
   AADD(aColsPER,{If(Substr(cPer,nI,1)=="û",oOk,oNo),DTOC(aPeriodos[nI]),If(Substr(cTpOP,nI,1)=="û","1","2"),.F.})
Next nI

//Verifica se seleciona OP
If lOP .And. Empty(cNumOpGet)
   cNumOpGet := CRIAVAR("C2_NUM",.F.)
EndIf

DEFINE MSDIALOG oDlgPer TITLE cTitle FROM 000,000 TO 410,350 OF oMainWnd PIXEL

oGetPer := MsNewGetDados():New(oSize:GetDimension("NUMERO","LININI"),oSize:GetDimension("NUMERO","COLINI"),;
                               oSize:GetDimension("NUMERO","LINEND"),oSize:GetDimension("NUMERO","COLEND"),;
                            3,"AllwaysTrue","AllwaysTrue",/*cIniCpos*/,aAlterGDa,/*nFreeze*/,990,/*cFieldOk*/, /*cSuperDel*/,;
                               "AllwaysFalse", oDlgPer, @aHeaderPER, @aColsPER)
oGetPer:SetEditLine(.F.)
oGetPer:AddAction("CHKOK",{||If(oGetPer:aCols[oGetPer:nAT,1] == oOk,oNo,oOk)})
oGetPer:lInsert := .F.

oTButMarDe := TButton():New(oSize:GetDimension("NUMERO","LININI")+1,oSize:GetDimension("NUMERO","COLINI")+1,,;
                            oDlgPer,{|| AT107IMarc(@oGetPer)},16,10,,,.F.,.T.,.F.,,.F.,,,.F.)

@ oSize:GetDimension("OP","LININI")+2,oSize:GetDimension("OP","COLINI") Say OemtoAnsi(STR0131) SIZE 100,7 OF oDlgPer PIXEL
@ oSize:GetDimension("OP","LININI")  ,oSize:GetDimension("OP","COLINI")+15 MSGET dDatDe PICTURE "99/99/99" SIZE 50,09 OF oDlgPer PIXEL
@ oSize:GetDimension("OP","LININI")+2,oSize:GetDimension("OP","COLINI")+80 Say OemtoAnsi(STR0132) SIZE 100,7 OF oDlgPer PIXEL
@ oSize:GetDimension("OP","LININI")  ,oSize:GetDimension("OP","COLINI")+100 MSGET dDatAte PICTURE "99/99/99" SIZE 50,09 OF oDlgPer PIXEL

@ oSize:GetDimension("OP","LININI")+15,oSize:GetDimension("OP","COLINI") RADIO oRdx VAR nSelec SIZE 70,10 PROMPT  OemToAnsi(STR0133),OemToAnsi(STR0134)
@ oSize:GetDimension("OP","LININI")+35,oSize:GetDimension("OP","COLINI") BUTTON STR0135 SIZE 055,010 ACTION A107Reprog(@oGetPer,nSelec,dDatDe,dDatAte) OF oDlgPer PIXEL

If lOP
   @ oSize:GetDimension("OP","LININI")+55,oSize:GetDimension("OP","COLINI") Say OemtoAnsi(STR0136) SIZE 100,7 OF oDlgPer PIXEL   //"Numero Inicial p/geracao"
   @ oSize:GetDimension("OP","LININI")+53,oSize:GetDimension("OP","COLINI")+100 MSGET cNumOpGet SIZE 50,09 OF oDlgPer PIXEL
   @ oSize:GetDimension("OP","LININI")+70,oSize:GetDimension("OP","COLINI") CHECKBOX oChk VAR lOPMaxDig PROMPT OemToAnsi(STR0137) SIZE 85, 10 OF oDlgPer PIXEL //"Maximo de 99 itens por OP"
   oChk:oFont := oDlgPer:oFont
EndIf

ACTIVATE MSDIALOG oDlgPer ON INIT EnchoiceBar(oDlgPer,{||nOpca:=2,oDlgPer:End()},{||oDlgPer:End()}) CENTERED

If nOpca = 2
   If lOp
      lOpMax99 := lOpMaxDig
      If Empty(cNumOpGet)
         cNumOpDig := GetNumSc2()
      Else
         cNumOpDig := cNumOpGet
      EndIf
   EndIf

   For nI:=1 to Len(oGetPer:aCols)
      If oGetPer:aCols[nI][1] == oOk
         If nI == 1
            cSelPer :="û"
         Else
            cSelPer :=cSelPer+"û"
         EndIf
      Else
         If nI == 1
            cSelPer :=" "
         Else
            cSelPer :=cSelPer+" "
         EndIf
      EndIf

      If oGetPer:aCols[nI][3] == "1"
         If nI == 1
            cTpOP :="û"
         Else
            cTpOP :=cTpOP+"û"
         EndIf
      Else
         If nI == 1
            cTpOP :=" "
         Else
            cTpOP :=cTpOP+" "
         EndIf
      EndIf
   Next nI
   cPer := cSelPer
EndIf

Return cPer

/*-------------------------------------------------------------------------/
//Programa: PCP107OPSC
//Autor:    Lucas Konrad França
//Data:     11/12/2014
//Descricao:   Rotina de controle da emissao de OP's e SC's
//Parametros:  01.cNumOpDig - Numero da Op inicial a ser digitado pelo usuario
//          02.lOpMax99  - Indica se o maximo de itens por op e 99
//          03.cStrTipo  - String com tipos a serem processados
//          04.cStrGrupo - String com grupos a serem processados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function PCP107OPSC(cNumOpDig,lOpMax99,cStrTipo,cStrGrupo)
Local cNumOP      := ""
Local cProduto    := ""
Local cOpcional   := ""
Local cOpcOri     := ""
Local cAliasTop   := ""
Local cAliasSov   := "GETSOV"
Local cQuery      := ""
Local mOpc        := ""
Local cItemOP     := "01"
Local cNivelSOQ   := "00"
Local cRevisao    := CriaVar("B1_REVATU",.F.)
Local nNumOPSC    := ""
Local nSequenOP   := 1
Local nPer        := 0
Local nRec        := 0
Local zxy         := 0
Local nRecPMP     := 0
Local nZ          := 0
Local nAglu       := 0
Local nBkpI       := 0
Local nPrimDt     := 0
Local nAgluMrp    := 0
Local nQtTran     := 0
Local nT          := 0
Local nSldDest    := 0
Local nEntrTrans  := 0
Local nTamFil     := TamSX3("OQ_FILEMP")[1]
Local lA650CCF    := ExistBlock("A650CCF")
Local lVerSld     := .F.
Local lCarregou   := .F.
Local lPmp        := .F.
Local aSH5FixR    := {}
Local aQuant      := {}
Local aRetEmp     := {}
Local aEmpresas   := {}

PRIVATE INCLUI    := .F.
PRIVATE ALTERA    := .F.
PRIVATE aUsoSH5   := {}
PRIVATE lAlteraOQ := .T.
PRIVATE nRecSov   := 0
PRIVATE nSotBkp   := 0

aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
For nZ := 1 To Len(aEmpCent)
   If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
      aAdd(aEmpresas,{aEmpCent[nZ,1],aEmpCent[nZ,2],aEmpCent[nZ,3]})
   EndIf
Next nZ

Pergunte("MTA650",.F.)
mv_par03 := aPergs711[08]
mv_par04 := aPergs711[09]

//Obtem numero da proxima OP
dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial("SC2")+AllTrim(cNumOpDig))
cNumOp := If(!Empty(cNumOpDig) .And. Eof(),cNumOpDig, GetNumSc2())

//Quando utiliza PMP gera Ordens de Producao pela SOQ. Apos gerar as OPs do PMP deve considerar as demais necessidades.
//O PMP tem a particularidade de gerar OPs mesmo que o saldo do produto exista, por isso sua utilizacao por empresas
//que produzem para estoque.
If aPergs711[1] == 2
   //Atualiza o log de processamento
   ProcLogAtu("MENSAGEM","Iniciando Geração de OPs/SCs PMP","Iniciando Geração de OPs/SCs PMP")

   cAliasTop := "BUSCASHC"
   cQuery := " SELECT SOQ.OQ_PROD, " +;
                    " SOQ.OQ_NRRV, " +;
                    " SOQ.OQ_QUANT, " +;
                    " SOQ.OQ_NRRGAL, " +;
                    " SOQ.OQ_PERMRP, " +;
                    " SOQ.OQ_NRLV, " +;
                    " SB1.B1_CONTRAT, " +;
                    " SB1.B1_TIPO, " +;
                    " SB1.B1_APROPRI, " +;
                    " SB1.B1_LOCPAD, " +;
                    " SB1.B1_PROC, " +;
                    " SB1.B1_LOJPROC, " +;
                    " SB1.B1_CC, " +;
                    " SOQ.R_E_C_N_O_ SOQREC, " +;
                    " 'SOQ' ORIG " +;
               " FROM " + RetSqlName("SOQ") + " SOQ, " +;
                          RetSqlName("SHC") + " SHC, " +;
                          RetSqlName("SB1") + " SB1 " +;
              " WHERE SOQ.OQ_FILIAL  = '" + xFilial("SOQ") + "' " +;
                " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " +;
                " AND SOQ.OQ_NRRGAL  = SHC.R_E_C_N_O_ " +;
                " AND SOQ.OQ_PROD    = SB1.B1_COD " +;
                " AND SOQ.OQ_ALIAS   = 'SHC' " +;
                " AND SOQ.OQ_QUANT   > 0 " +;
                " AND SOQ.OQ_EMP     = '" + cEmpAnt + "'" +;
                " AND SOQ.OQ_FILEMP  = '" + cFilAnt + "'" +;
                " AND SHC.HC_OP      = ' ' " +;
                " AND SOQ.D_E_L_E_T_ = ' ' " +;
            " UNION " +;
            " SELECT SOR.OR_PROD    OQ_PROD, " +;
                   " SOR.OR_NRRV    OQ_NRRV, " +;
                   " SOV.OV_QUANT   OQ_QUANT, " +;
                   " 0              OQ_NRRGAL, " +;
                   " SOT.OT_PERMRP  OQ_PERMRP, " +;
                   " SOR.OR_NRLV    OQ_NRLV, " +;
                   " SB1.B1_CONTRAT B1_CONTRAT, " +;
                   " SB1.B1_TIPO    B1_TIPO, " +;
                   " SB1.B1_APROPRI B1_APROPRI, " +;
                   " SB1.B1_LOCPAD  B1_LOCPAD, " +;
                   " SB1.B1_PROC    B1_PROC, " +;
                   " SB1.B1_LOJPROC B1_LOJPROC, " +;
                   " SB1.B1_CC      B1_CC, " +;
                   " SOV.OV_RECSOT  SOQREC, " +;
                   " 'SOV'          ORIG " +;
             "  FROM " + RetSqlName("SOV") + " SOV, " +;
                         RetSqlName("SOT") + " SOT, " +;
                         RetSqlName("SOR") + " SOR, " +;
                         RetSqlName("SB1") + " SB1  " +;
             " WHERE SOV.OV_RECSOT = SOT.R_E_C_N_O_ " +;
             "   AND SOT.OT_RGSOR  = SOR.R_E_C_N_O_ " +;
             "   AND SOV.OV_TRANS  = 'N' " +;
             "   AND SOR.OR_EMP    = '" + cEmpAnt + "'" +;
             "   AND SOR.OR_FILEMP = '" + cFilAnt + "'" +;
             "   AND SB1.B1_FILIAL = ' ' " +;
             "   AND SOR.OR_PROD   = SB1.B1_COD " +;
             "   AND SOV.OV_RECSOT IN (SELECT SOS.OS_SOTORIG " +;
                                       " FROM " + RetSqlName("SOS") + " SOS " +;
                                      " WHERE SOS.OS_SOTDEST IN ( SELECT SOT1.R_E_C_N_O_ " +;
                                                                  " FROM " + RetSqlName("SOT") + " SOT1 " +;
                                                                 " WHERE SOT1.OT_RGSOR IN ( SELECT SOR1.R_E_C_N_O_ " +;
                                                                                            " FROM " + RetSqlName("SOR") + " SOR1, " +;
                                                                                                       RetSqlName("SOQ") + " SOQ1 " +;
                                                                                           " WHERE ((SOR1.OR_EMP  != SOR.OR_EMP " +;
                                                                                             " AND SOR1.OR_FILEMP != SOR.OR_FILEMP) " +;
                                                                                              " OR (SOR1.OR_EMP   != SOR.OR_EMP " +;
                                                                                             " AND SOR1.OR_FILEMP = SOR.OR_FILEMP) " +;
                                                                                              " OR (SOR1.OR_EMP   = SOR.OR_EMP " +;
                                                                                             " AND SOR1.OR_FILEMP != SOR.OR_FILEMP)) " +;
                                                                                             " AND SOQ1.OQ_ALIAS  = 'SHC' " +;
                                                                                             " AND SOQ1.OQ_PROD   = SOR1.OR_PROD " +;
                                                                                             " AND SOQ1.OQ_EMP    = SOR1.OR_EMP " +;
                                                                                             " AND SOQ1.OQ_FILEMP = SOR1.OR_FILEMP ))) "
   cQuery += " ORDER BY OQ_NRLV "
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   dbSelectArea(cAliasTop)

   While !(cAliasTop)->(Eof())
      lCarregou := .F.
      lPmp := .T.

      //Se o produto é comprado nesta empresa, verifica se é produzido em outra.
      //Se for produzido em outra empresa, ignora o PMP desta empresa, e irá gerar a OP na empresa onde é produzido.
      dbSelectArea("SG1")
      SG1->(dbSetOrder(1))
      If !SG1->(dbSeek(xFilial("SG1")+(cAliasTop)->OQ_PROD))
         aRetEmp := verItProd((cAliasTop)->OQ_PROD)
         If aRetEmp[1] != Nil .And. aRetEmp[2] != Nil
            If AllTrim(aRetEmp[1]) != AllTrim(cEmpAnt) .Or. AllTrim(aRetEmp[2]) != AllTrim(cFilAnt)
               (cAliasTop)->(dbSkip())
               Loop
            EndIf
         EndIf
      EndIf

      If (cAliasTop)->(ORIG) == "SOV"
         dbSelectArea("SOS")
         SOS->(dbSetOrder(2))
         If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str((cAliasTop)->(SOQREC))),10)))
            While !SOS->(Eof()) .And. SOS->OS_SOTORIG == (cAliasTop)->(SOQREC)
               SOT->(dbGoTo(SOS->(OS_SOTDEST)))
               SOR->(dbGoTo(SOT->(OT_RGSOR)))
               cQuery := " SELECT SOQ.OQ_NRRGAL, "
               cQuery +=        " SOQ.OQ_QUANT, "
               cQuery +=        " SOQ.R_E_C_N_O_ SOQREC, "
               cQuery +=        " SOQ.OQ_NRLV "
               cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ "
               cQuery +=  " WHERE SOQ.OQ_FILIAL = '" + xFilial("SOQ") + "' "
               cQuery +=    " AND SOQ.OQ_ALIAS  = 'SHC' "
               cQuery +=    " AND SOQ.OQ_EMP    = '" + SOR->(OR_EMP) + "' "
               cQuery +=    " AND SOQ.OQ_FILEMP = '" + SOR->(OR_FILEMP) + "' "
               cQuery +=    " AND SOQ.OQ_PROD   = '" + SOR->(OR_PROD) + "' "
               cQuery +=    " AND SOQ.OQ_PERMRP = '" + SOT->(OT_PERMRP) + "' "
               cQuery +=    " AND SOQ.OQ_NRRV   = '" + SOR->(OR_NRRV) + "' "
               cQuery := ChangeQuery(cQuery)

               dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSov,.T.,.T.)
               If !(cAliasSov)->(Eof())
                  lCarregou := .T.
                  nRecPMP   := (cAliasSov)->(OQ_NRRGAL)
                  nLoteQtd  := (cAliasSov)->(OQ_QUANT)
                  cProduto  := SOR->OR_PROD
                  nRec      := (cAliasSov)->(SOQREC)
                  cRevisao  := SOR->OR_NRRV
                  nPer      := Val(SOT->OT_PERMRP)
                  dbSelectArea("SG1")
                  SG1->(dbSetOrder(1))
                  cNivelSOQ := IIf(SG1->(dbSeek(xFilial("SG1")+cProduto)),SG1->G1_NIV,"99")
                  cTipo711  := IIF(cNivelSOQ = '99',"C","F")
                  (cAliasSov)->(dbCloseArea())
                  Exit
               Else
                  (cAliasSov)->(dbCloseArea())
                  SOS->(dbSkip())
               EndIf
            End
            If !lCarregou
               (cAliasTop)->(dbSkip())
               Loop
            EndIf
         Else
            (cAliasTop)->(dbSkip())
            Loop
         EndIf
      EndIf

      A107ProInc()
      If !lCarregou
         //Produto do PMP
         cProduto := (cAliasTop)->OQ_PROD

         //Registro do SHC
         nRecPMP := (cAliasTop)->OQ_NRRGAL

         nRec := (cAliasTop)->SOQREC
         //Revisao
         cRevisao := (cAliasTop)->OQ_NRRV

         //Quantidade do PMP
         nLoteQtd := (cAliasTop)->OQ_QUANT

         //Periodo
         nPer := Val((cAliasTop)->OQ_PERMRP)

         //Verifica o tipo
         cTipo711 := IIF((cAliasTop)->OQ_NRLV = '99',"C","F")

         cNivelSOQ := (cAliasTop)->(OQ_NRLV)
      EndIf
      If aScan(aPmpProc,{|x| x == nRec }) > 0
         (cAliasTop)->(dbSkip())
         Loop
      EndIf
      aAdd(aPmpProc,nRec)
      //Opcionais do PMP
      SOQ->(dbGoTo(nRec))
      mOpc := SOQ->OQ_OPC
      cOpcional := SOQ->OQ_OPCORD

      If (cAliasTop)->(ORIG) == "SOV"
         dbSelectArea("SOR")
         SOR->(dbSetOrder(1))
         If SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto+cRevisao ))
            dbSelectArea("SOT")
            SOT->(dbSetOrder(1))
            If SOT->(dbSeek(xFilial("SOT")+STR(SOR->(Recno()),10,0)+(cAliasTop)->OQ_PERMRP))
               nRec := SOT->(Recno())
               lPmp := .F.
            EndIf
         EndIf
      EndIf
      A107CriSOR(cProduto,cOpcional,cRevisao,cNivelSOQ,(cAliasTop)->OQ_PERMRP,-nLoteQtd,"2",cAliasTop,/*09*/,cStrTipo,cStrGrupo,.F.,/*13*/,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)

      //Executa execblock para verificar se produto sera fabricado ou comprado
      If lA650CCF
         cOldTipo := cTipo711
         cTipo711 := ExecBlock("A650CCF",.F.,.F.,{cProduto,cTipo711,aPeriodos[nPer]})
         If !(ValType(cTipo711) == "C") .Or. !(cTipo711 $ "FCI")
            cTipo711 := cOldtipo
         EndIf
      EndIf

      dbSelectArea("SOT")
      SOT->(dbSetOrder(1))
      If SOT->(dbSeek(xFilial("SOT")+STR(nRec,10,0)+StrZero(nPer,3)))
         nQtTran := SOT->OT_QTTRAN
         If nQtTran > 0
            lAlteraOQ := .F.
            nNumOPSC := buscaRelSc(nRec)
            A107GeraSC(nPer,nQtTran,cProduto,cAliasTop,nRec,lPmp,nNumOPSC)
            lAlteraOQ := .T.
         EndIf
      EndIf

      If cTipo711 == "C"
         //Se for nivel 99, gera SC
         If ((aPergs711[04] == 1 .And. Substr(cSelPer,nPer,1) == "û") .Or. (aPergs711[04] == 2 .And. Substr(cSelPerSC,nPer,1) == "û")) .AND. A107VerHl(aPeriodos[nPer],cProduto)
            A107GeraSC(nPer,nLoteQtd,cProduto,cAliasTop,nRec,lPmp)

            //Atualiza o status do plano mestre de produção para executado.
            dbSelectArea("SHC")
            dbGoto(nRecPMP)
            RecLock("SHC",.F.)
            SHC->HC_STATUS := "E"
            MsUnlock()
         EndIf
      ElseIf cTipo711 == "F"
         //Se for nivel <> 99, gera OP
         If Substr(cSelPer,nPer,1) == "û" .AND. A107VerHl(aPeriodos[nPer],cProduto)
            A107GeraOP(@cNumOP,cItemOP,nSequenOP,nPer,nLoteQtd,cProduto,cOpcional,cRevisao,lOpMax99,mOpc,nRec,lPmp)

            //Atualiza numero da OP no arquivo de PMP
            If (cAliasTop)->(ORIG) != "SOV"
               dbSelectArea("SHC")
               dbGoto(nRecPMP)
               RecLock("SHC",.F.)
               SHC->HC_STATUS := "E"
               SHC->HC_OP     := cNumOp+cItemOP+StrZero(nSequenOP,3,0)
               MsUnlock()
            EndIf

            //Incrementa numeracao da OP
            If aPergs711[07] == 1
               cItemOP:=Soma1(cItemOp)
               If cItemOP > "99" .And. lOpMax99
                  If lDigNumOp
                     cNumOp := Soma1(cNumOp)
                  Else
                     cNumOp := GetNumSc2()
                  Endif
                  cItemOP := "01"
                  nSequenOp := 1
               EndIf
            Else
               If lDigNumOp
                  cNumOp := Soma1(cNumOp)
               Else
                  cNumOp := GetNumSc2()
               Endif
               cItemOP := "01"
               nSequenOp := 1
            EndIf
         EndIf
      EndIf

      //If (cAliasTop)->(ORIG) == "SOV" .And. !lPmp
      //   atuNeces(nRec,nLoteQtd,"N")
      //EndIf

      dbSelectArea(cAliasTop)
      dbSkip()
   End

   (cAliasTop)->(dbCloseArea())

   //Atualiza o log de processamento
   ProcLogAtu("MENSAGEM","Fim Geração de OPs/SCs PMP","Fim Geração de OPs/SCs PMP")
EndIf

//Atualiza o log de processamento
ProcLogAtu("MENSAGEM","Iniciando Geração de OPs/SCs","Iniciando Geração de OPs/SCs")
A107ProInc()

cAliasTop := "GERAOPSC"
cQuery := " SELECT SOR.OR_PROD, "
cQuery +=        " SOR.OR_OPCORD, "
cQuery +=        " SOR.OR_NRRV, "
cQuery +=        " SOR.OR_NRLV, "
cQuery +=        " SOT.OT_PERMRP, "
If aPergs711[16] == 2 .And. nUsado == 1
   cQuery +=     " ISNULL(SOV.OV_QUANT, SOT.OT_QTNECE) QTNECE, "
   cQuery +=     " ISNULL(SOV.R_E_C_N_O_, 0) RECSOV, "
Else
   cQuery +=     " SOT.OT_QTNECE, "
EndIf
cQuery +=        " SB1.B1_CONTRAT, "
cQuery +=        " SB1.B1_TIPO, "
cQuery +=        " SB1.B1_APROPRI, "
cQuery +=        " SB1.B1_LOCPAD, "
cQuery +=        " SB1.B1_PROC, "
cQuery +=        " SB1.B1_LOJPROC, "
cQuery +=        " SB1.B1_CC, "
cQuery +=        " SOR.R_E_C_N_O_ SORREC, "
cQuery +=        " SOT.R_E_C_N_O_ SOTREC "
cQuery +=   " FROM " + RetSqlName("SOR") + " SOR, "
cQuery +=              RetSqlName("SB1") + " SB1, "
cQuery +=              RetSqlName("SOT") + " SOT "
If aPergs711[16] == 2 .And. nUsado == 1
   cQuery += " LEFT OUTER JOIN " + RetSqlName("SOV") + " SOV ON "
   cQuery +=                   " SOT.R_E_C_N_O_ = SOV.OV_RECSOT "
   cQuery +=               " AND (SOV.OV_TRANS   = 'N' "
   cQuery +=                 " OR SOV.OV_TRANS   = 'E') "
EndIf
cQuery +=  " WHERE SOR.OR_FILIAL   = '" + xFilial("SOR") + "' "
cQuery +=    " AND SOT.OT_FILIAL   = '" + xFilial("SOT") + "' "
cQuery +=    " AND SB1.B1_FILIAL    = '" + xFilial("SB1") + "' "
cQuery +=    " AND SOR.R_E_C_N_O_   = SOT.OT_RGSOR "
cQuery +=    " AND SOR.OR_PROD      = SB1.B1_COD "
cQuery +=    " AND SOR.OR_EMP       = '" + cEmpAnt + "' "
cQuery +=    " AND SOR.OR_FILEMP    = '" + cFilAnt + "' "
cQuery +=    " AND EXISTS (SELECT 1 "
cQuery +=                  " FROM " + RetSqlName("SOT") + " SOTB "
cQuery +=                 " WHERE SOTB.OT_FILIAL = '" + xFilial("SOT") + "' "
cQuery +=                   " AND SOTB.OT_RGSOR  = SOR.R_E_C_N_O_ "
cQuery +=                   " AND (SOTB.OT_QTNECE > 0 "
cQuery +=                    " OR  SOTB.OT_QTTRAN > 0)) "
If aPergs711[16] == 2 .And. nUsado == 1
   cQuery += " ORDER BY SOR.OR_NRLV, " +;
                      " SOR.OR_FILIAL, " +;
                      " SOT.OT_PERMRP, " +;
                      " SOR.OR_PROD, " +;
                      " SOR.OR_OPCORD, " +;
                      " QTNECE "
Else
   cQuery += " ORDER BY SOR.OR_NRLV, " +;
                      " SOR.OR_FILIAL, " +;
                      " SOR.OR_PROD, " +;
                      " SOR.OR_OPCORD, " +;
                      " SOT.OT_PERMRP, " +;
                      " SOT.OT_QTNECE "
EndIf
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
dbSelectArea(cAliasTop)

//Gera OP's para todos os periodos da projecao
While !(cAliasTop)->(Eof())
   A107ProInc()
   aQuant := {}
   //Periodo
   nPer := Val((cAliasTop)->OT_PERMRP)

   nRec := (cAliasTop)->SOTREC

   cTipo711 := IIf((cAliasTop)->OR_NRLV = "99","C","F")

   //Executa execblock para verificar se produto sera fabricado ou comprado
   If lA650CCF
      cOldTipo := cTipo711
      cTipo711 := ExecBlock("A650CCF",.F.,.F.,{cProduto,cTipo711,aPeriodos[nPer]})
      If !(ValType(cTipo711) == "C") .Or. !(cTipo711 $ "FCI")
         cTipo711:=cOldtipo
      EndIf
   EndIf
   If cTipo711 = "C" .And. ((aPergs711[04] == 1 .And. Substr(cSelPer,nPer,1) # "û") .Or. (aPergs711[04] == 2 .And. Substr(cSelPerSC,nPer,1) # "û"))
      dbSelectArea(cAliasTop)
      dbSkip()
      loop
   EndIf

   If cTipo711 == "F" .And. Substr(cSelPer,nPer,1) # "û"
      dbSelectArea(cAliasTop)
      dbSkip()
      loop
   EndIf
   If Select("SC2") < 1
      SC2->(dbCloseArea())
   EndIf
   If (aPergs711[04] == 1 .And. Substr(cSelPer,nPer,1) == "û") .Or. aPergs711[04] == 2
      //Produto
      cProduto := (cAliasTop)->OR_PROD
      //Opcional
      SOR->(dbGoTo((cAliasTop)->SORREC))
      cOpcional := SOR->OR_OPC
      cOpcOri := SOR->OR_MOPC

      //Revisao
      cRevisao := (cAliasTop)->OR_NRRV
      If aPergs711[16] == 2 .And. nUsado == 1
         nRecSov := (cAliasTop)->(RECSOV)
      EndIf
      aSH5FixR := {}
      nSotBkp := (cAliasTop)->SOTREC

      //Posiciona na SOT para pegar possiveis atualizações de saldo e necessidade
      SOT->(dbGoTo((cAliasTop)->SOTREC))

      //Busca as entradas de transferência
      nEntrTrans := 0
      dbSelectArea("SOS")
      SOS->(dbSetOrder(3))
      If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(SOT->(Recno()))),10)))
         While SOS->OS_SOTDEST == SOT->(Recno())
            nEntrTrans += SOS->OS_QUANT
            SOS->(dbSkip())
         EndDo
      EndIf

      If SOT->OT_QTNECE == 0 .And. nEntrTrans == 0
         dbSelectArea(cAliasTop)
         dbSkip()
         Loop
      EndIf
      If aPergs711[16] == 1 .Or. nUsado != 1
         nLoteQtd:= SOT->OT_QTNECE
      Else
         If (cAliasTop)->(RECSOV) > 0
            nLoteQtd := buscaQtdNe((cAliasTop)->(RECSOV))
         Else
            nLoteQtd:= SOT->OT_QTNECE
         EndIf
      EndIf

      If aPergs711[16] == 2 .And. nUsado == 1
         aQuant := buscaTran((cAliasTop)->(SOTREC))
         nQtTran := Len(aQuant)
         ASORT(aQuant,,,{|x,y| x[1] < y[1]})
      Else
         nQtTran := SOT->OT_QTTRAN
      EndIf

      //Realiza aglutinacao dos periodos  gerado no MRP conforme definido no campo B5_AGLUMRP
      nAgluMrp := Val(Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_AGLUMRP"))

      //Somente executa se a aglutinacao do MRP for menor que a aglutinacao do produto
      If (nUsado < nAgluMrp) .OR. (nUsado==7)
         If A107Periodo(aPeriodos[nPer],If(nPer==Len(aPeriodos),SToD(''),aPeriodos[nPer+1]),nAgluMrp)
            nAglu := nAglu + nLoteQtd

            If !Empty(nLoteQtd) .And. Empty(nPrimDt)
               nPrimDt := nPer
            EndIf

            //Ajusta datas das saidas dos filhos
            SOQ->(dbSetOrder(4))
            If QtdComp(nLoteQtd) > QtdComp(0) .AND. nPrimDt <> nPer
               aAreaBkp := SOQ->(GetArea())
               If !lUsaMOpc
                  SOQ->(dbSeek(xFilial("SOQ")+cEmpAnt+PadR(cFilAnt,nTamFil)+"SOR"+PadR(cProduto,TamSX3("B1_COD")[1])+DTOS(aPeriodos[nPer])))
               EndIf

               While !SOQ->(EOF()) .AND. cEmpAnt+PadR(cFilAnt,nTamFil)+"SOR"+PadR(cProduto,TamSX3("B1_COD")[1])+DTOS(aPeriodos[nPer])== SOQ->(OQ_EMP+OQ_FILEMP+OQ_ALIAS+OQ_DOC+DTOS(PQ_DTOG))
                  Reclock("SOQ",.F.)
                  SOQ->OQ_DTOG := aPeriodos[nPrimDt]
                  SOQ->(MsUnLock()) //Confirma e finaliza a operação

                  SOT->(dbSetOrder(1))

                  SOT->(dbSeek(xFilial("SOT")+STR((cAliasTop)->SORREC,10,0)+StrZero(nPer,3)))
                  Reclock("SOT",.F.)
                  SOT->OT_QTSAID -= SOQ->OQ_QUANT
                  SOT->(MsUnLock()) //Confirma e finaliza a operação

                  SOT->(dbSeek(xFilial("SOT")+STR((cAliasTop)->SORREC,10,0)+StrZero(nPrimDt,3)))
                  Reclock("SOT",.F.)
                  SOT->OT_QTSAID += SOQ->OQ_QUANT
                  SOT->(MsUnLock()) //Confirma e finaliza a operação

                  //Recalcula valores do SHA
                  A107Recalc(SOQ->OQ_PROD,SOQ->OQ_OPCORD,SOQ->OQ_NRRV,nPrimDt,/*05*/,/*06*/,(cAliasTop)->SORREC,/*08*/,aEmpresas)
                  A107Recalc(SOQ->OQ_PROD,SOQ->OQ_OPCORD,SOQ->OQ_NRRV,nPer,/*05*/,/*06*/,(cAliasTop)->SORREC,/*08*/,aEmpresas)
                  SOQ->(dbSkip())
               End
            EndIf
         Else
            nLoteQtd := nAglu + nLoteQtd
            nAglu := 0
            nBkpI := nPer
            If !Empty(nPrimDt)
               nPer := nPrimDt
            EndIf
         EndIf
      EndIf

      //Soma ao lote de producao/compra quantidades originadas pelo indicador SBP (Subproduto) quando subproduto for
      //variavel (fixo deve gerar OP's separadas            |
      dbSelectArea("SOQ")
      dbSetOrder(3)
      dbSeek(xFilial("SOQ")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto+"SBP")

      While !EOF() .And. OQ_EMP+OQ_FILEMP+OQ_PROD+OQ_ALIAS == cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto+"SBP"
         If AllTrim(OQ_PERMRP) == StrZero(nPer,3) .And. cOpcional == OQ_OPCORD .And. cRevisao == OQ_NRRV
            SG1->(dbSeek(xFilial("SG1")+SOQ->(OQ_PROD+OQ_DOC)))

            If SG1->G1_FIXVAR $ " V"
               nLoteQtd += OQ_QUANT
            Else
               aAdd(aSH5FixR,Recno())
            EndIf
            A107CriSOR(cProduto,OQ_OPCORD,OQ_NRRV,OQ_NRLV,OQ_PERMRP,-OQ_QUANT,"2",/*08*/,/*09*/,cStrTipo,cStrGrupo,.F.,/*13*/,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
         EndIf
         dbSkip()
      End
      If RetFldProd(SB1->B1_COD,"B1_FANTASM") # "S" .And. nQtTran > 0
         //Gera as solicitações de compra para as transferências.
         If aPergs711[16] == 2 .And. nUsado == 1
            nSldDest := 0
            lVerSld  := .F.
            dbSelectArea("SOS")
            SOS->(dbSetOrder(3))
            If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nRec)),10)))
               While SOS->OS_SOTDEST == nRec
                  nSldDest += SOS->OS_QUANT
                  SOS->(dbSkip())
               End
               lVerSld := .T.
            EndIf

            nNumOPSC := buscaRelSc(nRec)

            For nT := 1 To Len(aQuant)
               aQtdes := CalcLote(cProduto,aQuant[nT,1],"C")
               aQtdes := A711LotMax(cProduto, aQuant[nT,1], aQtdes)
               lAlteraOQ := .F.
               ASORT(aQtdes,,,{|x,y| x < y})
               For zxy := 1 to Len(aQtdes)
                  If lVerSld
                     If nSldDest - aQtdes[zxy] < 0
                        aQtdes[zxy] := nSldDest
                        nSldDest    := 0
                     Else
                        nSldDest -= aQtdes[zxy]
                     EndIf
                  EndIf
                  A107GeraSC(nPer,aQtdes[zxy],cProduto,cAliasTop,nRec,.F.,nNumOPSC)
                  atuNeces(aQuant[nT,2],aQtdes[zxy],"S")
                  aQuant[nT,1] -= aQtdes[zxy]
                  If lVerSld .And. nSldDest <= 0
                     Exit
                  EndIf
               Next zxy
               lAlteraOQ := .T.
            Next nT
         Else
            nSldDest := 0
            lVerSld  := .F.
            dbSelectArea("SOS")
            SOS->(dbSetOrder(3))
            If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nRec)),10)+"1"))
               While SOS->OS_SOTDEST == nRec
                  nSldDest += SOS->OS_QUANT
                  SOS->(dbSkip())
               End
               lVerSld := .T.
            EndIf
            aQtdes := CalcLote(cProduto,nQtTran,"C")
            aQtdes := A711LotMax(cProduto, nQtTran, aQtdes)
            lAlteraOQ := .F.

            nNumOPSC := buscaRelSc(nRec)

            For zxy := 1 to Len(aQtdes)
               If lVerSld
                  If nSldDest - aQtdes[zxy] < 0
                     aQtdes[zxy] := nSldDest
                     nSldDest    := 0
                  Else
                     nSldDest -= aQtdes[zxy]
                  EndIf
               EndIf
               A107GeraSC(nPer,aQtdes[zxy],cProduto,cAliasTop,nRec,.F.,nNumOPSC)
               nQtTran -= aQtdes[zxy]
               If lVerSld .And. nSldDest <= 0
                  Exit
               EndIf
            Next zxy
            lAlteraOQ := .T.
         EndIf
      EndIf
      If (QtdComp(nLoteQtd) > QtdComp(0) .Or. !Empty(aSH5FixR)) .And. RetFldProd(cProduto,"B1_FANTASM") # "S" .And. !IsProdMod(cProduto)
         If cTipo711 == "C"
            If (aPergs711[04] == 1 .And. Substr(cSelPer,nPer,1) == "û") .Or. (aPergs711[04] == 2 .And. Substr(cSelPerSC,nPer,1) == "û")
               //Quebras as quantidades das SCs
               aQtdes := CalcLote(cProduto,nLoteQtd,"C")
               aQtdes := A711LotMax(cProduto, nLoteQtd, aQtdes)
               For zxy := 1 to Len(aQtdes)
                  A107GeraSC(nPer,aQtdes[zxy],cProduto,cAliasTop,nRec,.F.)
               Next zxy
            EndIf
         ElseIf cTipo711 == "F"
            If Substr(cSelPer,nPer,1) == "û"
               //Gera OP's para necessidade SBP quando subproduto fixo
               For nZ := 1 to Len(aSH5FixR)
                  SOQ->(dbGoTo(aSH5FixR[nZ]))
                  aQtdes := CalcLote(cProduto,SOQ->OQ_QUANT,"F")
                  aQtdes := A711LotMax(cProduto,OQ->OQ_QUANT,aQtdes)
                  ASORT(aQtdes,,,{|x,y| x < y})
                  For zxy := 1 To Len(aQtdes)
                     A107GeraOP(@cNumOP,cItemOP,nSequenOP,nPer,aQtdes[zxy],cProduto,SOQ->OQ_OPCORD,SOQ->OQ_NRRV,lOpMax99,cOpcOri,nRec,.F.)

                     //Incrementa numeracao da OP
                     If aPergs711[07] == 1
                        cItemOP := Soma1(cItemOp)

                        If cItemOP > "99" .And. lOpMax99
                           If lDigNumOp
                              cNumOp := Soma1(cNumOp)
                           Else
                              cNumOp := GetNumSc2()
                           Endif

                           cItemOP := "01"
                           nSequenOp := 1
                        EndIf
                     Else
                        If lDigNumOp
                           cNumOp := Soma1(cNumOp)
                        Else
                           cNumOp := GetNumSc2()
                        Endif

                        cItemOP := "01"
                        nSequenOp := 1
                     EndIf
                  Next zxy
               Next nZ

               aQtdes := CalcLote(cProduto,nLoteQtd,"F")
               aQtdes := A711LotMax(cProduto,nLoteQtd,aQtdes)

               For zxy:=1 to Len(aQtdes)
                  A107GeraOP(@cNumOP,cItemOP,nSequenOP,nPer,aQtdes[zxy],cProduto,cOpcional,cRevisao,lOpMax99,cOpcOri,nRec,.F.)

                  // Incrementa numeracao da OP
                  If aPergs711[07] == 1
                     cItemOP:=Soma1(cItemOp)

                     If cItemOP > "99" .And. lOpMax99
                        If lDigNumOp
                           cNumOp := Soma1(cNumOp)
                        Else
                           cNumOp := GetNumSc2()
                        Endif
                        cItemOP := "01"
                        nSequenOp := 1
                     EndIf
                  Else
                     If lDigNumOp
                        cNumOp := Soma1(cNumOp)
                     Else
                        cNumOp := GetNumSc2()
                     Endif

                     cItemOP := "01"
                     nSequenOp := 1
                  EndIf
               Next zxy
            EndIf
         EndIf
      EndIf
   Endif
   If !Empty(nBkpI)
      nPer    := nBkpI
      nPrimDt := 0
      nBkpI   := 0
   EndIf
   dbSelectArea(cAliasTop)
   dbSkip()
End

(cAliasTop)->(dbCloseArea())

//Recalcula as necessidades do nivel 99
A107ClNes("99",,.T.)

PCPA107MVW(.T.,"CRIATAB")

If lMostraErro
   If lBatch
      //Conout(STR0138+NomeAutoLog()) //"Verificar inconsistencia de rotina automatica em MRP - arquivo : "
   Else
      Mostraerro()
   EndIf
EndIf

Return

/*------------------------------------------------------------------------//
//Programa: buscaTran
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Busca as quantidades de transferência
//Parametros:  nRecSot - Registro da tabela SOT
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function buscaTran(nRecSot)
Local cQuery := ""
Local aArea  := GetArea()
Local cAlias := GetNextAlias()
Local aRet   := {}

cQuery := " SELECT SOV.OV_QUANT, "
cQuery +=        " SOV.R_E_C_N_O_ RECSOV"
cQuery +=   " FROM " + RetSqlName("SOV") + " SOV "
cQuery +=  " WHERE SOV.OV_RECSOT = " + Str(nRecSot)
cQuery +=    " AND SOV.OV_TRANS  = 'S' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
While !(cAlias)->(Eof())
   aAdd(aRet,{(cAlias)->(OV_QUANT),(cAlias)->(RECSOV)})
   (cAlias)->(dbSkip())
End
(cAlias)->(dbCloseArea())
RestArea(aArea)
Return aRet

/*------------------------------------------------------------------------//
//Programa: buscaQtdNe
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Busca a quantidade necessária de um produto
//Parametros:  nRec - Registro da tabela SOV
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function buscaQtdNe(nRec)
Local aArea  := GetArea()
Local nQtd   := 0

SOV->(dbGoTo(nRec))
nQtd := SOV->(OV_QUANT)

If nQtd == Nil
   nQtd := 0
EndIf

RestArea(aArea)
Return nQtd

/*-------------------------------------------------------------------------/
//Programa: A107GeraSC
//Autor:    Rodrigo de A. Sartorio
//Data:     27/08/02
//Descricao:   Rotina de geracao de SC's
//Parametros:  01.nPeriodo  - Periodo para geracao de SCs
//          02.nQuant    - Quantidade a ser gerada na SC
//          03.cProduto  - Produto a ser gerado na SC
//          04.cAliasTop - Alias do produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107GeraSC(nPeriodo,nQuant,cProduto,cAliasTop,nRecno,lPmp,nNumOPSC)
Local nNewQtdBx := 0
Local nI        := 0
Local aCampos   := {}
Local aRetPE    := {}

Default cAliasTop := "SB1"
Default nNumOPSC  := ""

//Verifica se o produto tem contrato de parceria, se nao, gera solic.Compra. Se sim, gera Autor. de Entrega
If (cAliasTop)->B1_CONTRAT $ "N "
   A107GravC1(nPeriodo,nQuant,cProduto,/*04*/,/*05*/,/*06*/,cAliasTop,nRecno, lPmp,nNumOPSC)
Else
   If ExistBlock("A710QtdBx")
      //Ponto de Entrada para manipular quantidade a ser entregue pelo contrato de parceria
      If ValType(nNewQtdBx := ExecBlock("A710QtdBx",.F.,.F., {nQuant,nPeriodo,aPeriodos[nPeriodo]})) == "N" .And. nNewQtdBx <= nQuant
         nQuant := nNewQtdBx
      Endif
   EndIf

   aAdd(aCampos,{"DATPRF",aPeriodos[nPeriodo]})
   aAdd(aCampos,{"SEQMRP",c711NumMRP})
   aAdd(aCampos,{"TPOP",  A107VerHf(aPeriodos[nPeriodo],cProduto)})
   aAdd(aCampos,{"USER",  RetCodUsr()})
	
   If ExistBlock("A712CNTSC1")
      //Ponto de Entrada para manipular quantidade a ser entregue pelo contrato de parceria
      aRetPE := ExecBlock("A712CNTSC1",.F.,.F.,{cProduto,nQuant,aCampos})
      If Valtype(aRetPE) == "A"
         For nI := 1 To Len(aRetPE)
            If aScan(aCampos,{|x| x[1] == aRetPE[nI,1]}) < 1
               aAdd(aCampos,aRetPE[nI])
            EndIf
         Next nI
      EndIf
   EndIf
   MatGeraAE(cProduto,nQuant,aCampos,"PCPA107")
EndIf

Return

/*-------------------------------------------------------------------------/
//Programa: A107GravC1
//Autor:    Rodrigo de A. Sartorio
//Data:     27/08/02
//Descricao:   Rotina de gravacao SC's
//Parametros:  01.nPeriodo  - Periodo para geracao de SCs
//          02.nQuant    - Quantidade a ser gerada na SC
//          03.cProduto  - Produto a ser gerado na SC
//          04.lAutEnt   - Indica se produto gera AUTORIZACAO DE ENTREGA
//          05.lSemData  - Indica se produto tem Contrato de Parceria fora
//                       da data - > Fora da Data do Contrato
//          06.lSemQuant - Indica se produto tem Contrato de Parceria sem
//                       quantidade - > Quantidade Esgotada
//          07.cAliasTop - Alias do produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107GravC1(nPeriodo,nQuant,cProduto,lAutEnt,lSemData,lSemQuant,cAliasTop,nRec, lPmp,nNumOPSC)
Static cUser
Static lExeBloC1

Local aCab     := {}
Local aItem    := {}
Local cItem    := StrZero(1,Len(SC1->C1_ITEM),0)
Local cTextoObs   := ""
Local cLocal   := ""
Local aRetPE   := {}
Local cRevisao := Space(3)
Local aParam      := {aPeriodos[nPeriodo],nQuant, cProduto}

Private lMsErroAuto  := .F.
Default lAutEnt   := .F.
Default lSemData  := .F.
Default lSemQuant := .F.
Default cAliasTop := "SB1"
Default nNumOPSC  := ""

lExeBloC1 := If(lExeBloC1==NIL,ExistBlock("A711CSC1"),lExeBloC1)

//PE para tratamento se deve ou não incluir a SC. Se retornar F não inclui a SC.
If (ExistBlock("MT711VLSC"))
   lRet:= Execblock ("MT711VLSC",.F.,.F.,aParam)
   If !lRet
      Return
   EndIf
EndIf

cUser:= IF(cUser == NIL,RetCodUsr(),cUser)

//Nao gera para mao de obra e tipo = "BN" (Beneficiamento)
If !IsProdMod(cProduto) .And. ((cAliasTop)->B1_TIPO != "BN" .Or. ((cAliasTop)->B1_TIPO == "BN" .And. MatBuyBN()))
   If lAutEnt
      If lSemData
         cTextoObs := STR0139 //"FORA DA DATA CONTR. PARCERIA"
      ElseIf lSemQuant
         cTextoObs := STR0140 //"QUANT. DO CONTRATO ESGOTADA"
      Else
         cTextoObs := STR0141 //"SEM CONTRATO DE PARCERIA"
      EndIf
   EndIf

   dbSelectArea("SOS")
   SOS->(dbSetOrder(3))
   If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nRec)),10)))
      If SOS->(OS_QUANT) == nQuant
         cTextoObs += STR0157 //"Transferências de estoque"
      EndIf
   EndIf

   //Verifica se o produto eh intermediario e se deve ou nao considerar o armazem de processo na geracao de SCs.
   If (cAliasTop)->B1_APROPRI == "I" .And. GetMV("MV_GRVLOCP",.F.,.T.)
      cLocal := GETMV("MV_LOCPROC")
   Else
      cLocal   := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
   EndIf

   aCab:={{"C1_EMISSAO",dDataBase            ,Nil},; // Data de Emissao
         {"C1_FORNECE" ,SB1->B1_PROC         ,Nil},; // Fornecedor
         {"C1_LOJA"    ,SB1->B1_LOJPROC      ,Nil},; // Loja do Fornecedor
         {"C1_SOLICIT" ,CriaVar("C1_SOLICIT"),Nil},;
         {"MRPME"      ,"S"                  ,Nil},;
         {"PERIODO"    ,StrZero(nPeriodo,3)  ,Nil},;
         {"RECNO"      ,nRec                 ,Nil},;
         {"PMP"        ,lPmp                 ,Nil}}    //Indica se é o MRP Multi-empresa

   aItem:={{{"C1_ITEM"  ,cItem                                     ,Nil},; //Numero do Item
           {"C1_PRODUTO",cProduto                                  ,Nil},; //Codigo do Produto
           {"C1_QUANT"  ,nQuant                                    ,Nil},; //Quantidade
           {"C1_LOCAL"  ,cLocal                                    ,Nil},; //Armazem
           {"C1_DATPRF" ,aPeriodos[nPeriodo]                       ,Nil},; //Data
           {"C1_TPOP"   ,A107VerHf(aPeriodos[nPeriodo],cProduto)   ,Nil},; // Tipo SC
           {"C1_CC"     ,SB1->B1_CC                                ,Nil},; //Centro de Custos
           {"C1_GRUPCOM",MaRetComSC(SB1->B1_COD,UsrRetGrp(),cUser) ,Nil},; //Grupo de Compras
           {"C1_SEQMRP" ,c711NumMRP                                ,Nil},; //Numero da Programacao do MRP
           {"C1_OBS"    ,cTextoObs                                 ,Nil},; //Observacao
           {"AUTVLDCONT","N"                                       ,Nil},;
           {"C1_FORNECE",SB1->B1_PROC                              ,Nil},; //Fornecedor
           {"C1_LOJA"   ,SB1->B1_LOJPROC                           ,Nil},; //Loja do Fornecedor
           {"MRPME"     ,"S"                                       ,Nil},; //Indica se é o MRP Multi-empresa
           {"C1_OP"     ,nNumOPSC                                  ,Nil}}} //Número da OP referente a esta SC. Somente quando for SC de transferência.
   cRevisao := Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_VERSAO")
   AAdd(aTail(aItem),{"C1_REVISAO",cRevisao,NIL})

   If lExeBloC1
      aRetPE :=ExecBlock("A711CSC1",.f.,.f.,ACLONE(aItem))
      If Valtype(aRetPE) == "A"
         aItem:=ACLONE(aRetPE)
      EndIf
   EndIf

   MSExecAuto({|v,x,y,z| MATA110(v,x,y,z)},aCab,aItem,3,.T.)

   //Mostra Erro na geracao de Rotinas automaticas
   If lMsErroAuto
      lMostraErro:= .t.
   EndIf
EndIf

Return

/*-------------------------------------------------------------------------/
//Programa: A107GeraOP
//Autor:    Rodrigo de A. Sartorio
//Data:     27/08/02
//Descricao:   Rotina de gravacao SC's
//Parametros:  01.cNumOP     - Numero da Op a ser gerada
//          02.cItem      - Item da OP a ser gerada
//          03.nSequen    - Sequencia da OP a ser gerada
//          04.nPeriodo   - Periodo para a geracao da OP
//          05.nQuant     - Quantidade da OP a ser gerada
//          06.cProduto   - Produto da OP a ser gerada
//          07.cOpcionais - Opcionais da OP a ser gerada
//          08.cRevisao   - Revisao da estrutura
//          09.lOpMax99   - Indica o numero maximo de itens
//          10.mOpc       - Memo de opcionais
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107GeraOP(cNumOp,cItem,nSequen,nPeriodo,nQuant,cProduto,cOpcionais,cRevisao,lOpMax99,mOpc,nRecno,lPmp)
Static lM711SC2

Local aMata650  :={}
Local aArea     := GetArea()
Local dPeriodo  := aPeriodos[nPeriodo]
Local nQuant2UM := ConvUm(cProduto,nQuant,0,2)
Local nPrazo    := CalcPrazo(cProduto,nQuant,,,.F.,dPeriodo)
Local aRetPE    := {}
Local nLtTran   := 0
Local cEmp      := ""
Local cFil      := ""
Local cEmpresa  := cEmpAnt
Local cFilibkp  := cFilAnt

Private lMsErroAuto := .F.
Private nDiaLtTran  := 0
Private cProdTran   := cProduto

lM711SC2 := If(lM711SC2==NIL,ExistBlock("M711SC2"),lM711SC2)

//Verifica se é uma OP para transferência
dbSelectArea("SOS")
SOS->(dbSetOrder(2))
If SOS->(dbSeek(xFilial("SOS")+PadR(AllTrim(Str(nRecno)),10)+"2"))
   SOT->(dbGoTo(SOS->OS_SOTDEST))
   SOR->(dbGoTo(SOT->OT_RGSOR))
   cEmp := SOR->OR_EMP
   cFil := SOR->OR_FILEMP
   NGPrepTBL({{"SB5",1}},cEmp,AllTrim(cFil))
   dbSelectArea("SB5")
   SB5->(dbSetOrder(1))
   If SB5->(dbSeek(xFilial("SB5")+cProduto))
      nDiaLtTran := SB5->B5_LEADTR
      nPrazo += nDiaLtTran
   EndIf
   NGPrepTBL({{"SB5",1}},cEmpresa,AllTrim(cFilibkp))
EndIf
RestArea(aArea)
//Obtem numero da proxima OP
dbSelectArea("SC2")
dbSetOrder(1)

While dbSeek(xFilial("SC2")+AllTrim(cNumOp)+cItem)
   //Incrementa numeracao da OP
   If aPergs711[07] == 1
      cItem:=Soma1(cItem)
      If cItem > "99" .And. lOpMax99
         If lDigNumOp
            cNumOp := Soma1(cNumOp)
         Else
            cNumOp := GetNumSc2()
         Endif
         cItem   := "01"
         nSequen := 1
      EndIf
   Else
      If lDigNumOp
         cNumOp := Soma1(cNumOp)
      Else
         cNumOp := GetNumSc2()
      Endif
      cItem := "01"
      nSequen := 1
   EndIf
End

//Monta array para utilizacao da Rotina Automatica
aMata650 := {{'C2_NUM'      ,cNumOp,"A710ValNum()"},;
             {'C2_ITEM'     ,cItem,"A710ValNum()"},;
             {'C2_SEQUEN'   ,StrZero(nSequen,Len(SC2->C2_SEQUEN)),"A710ValNum()"},;
             {'C2_PRODUTO'  ,cProduto,NIL},;
             {'C2_LOCAL'    ,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),NIL},;
             {'C2_QUANT'    ,nQuant,NIL},;
             {'C2_QTSEGUM'  ,nQuant2UM,NIL},;
             {'C2_UM'       ,SB1->B1_UM ,NIL},;
             {'C2_CC'       ,SB1->B1_CC ,NIL},;
             {'C2_SEGUM'    ,SB1->B1_SEGUM,NIL},;
             {'C2_DATPRI'   ,SomaPrazo(dPeriodo, - nPrazo),NIL},;
             {'C2_DATPRF'   ,dPeriodo-nDiaLtTran,NIL},;
             {'C2_REVISAO'  ,If(A107TrataRev(),cRevisao,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/),NIL},;
             {'C2_TPOP'     ,A107VerHf(dPeriodo,cProduto),NIL},;
             {'C2_EMISSAO'  ,dDataBase,NIL},;
             {'C2_OPC'      ,cOpcionais,NIL},;
             {'C2_SEQMRP'   ,c711NumMRP,Nil},;
             {'C2_IDENT'    ,"P",Nil},;
             {'MRP'         ,'S',NIL},;
             {'AUTEXPLODE'  ,'S',NIL},;
             {'MRPME'       ,'S',NIL},;
             {'PERIODO'     ,StrZero(nPeriodo,3),Nil},;
             {'RECNO'       ,nRecno,Nil},;
             {'C2_MOPC'     ,mOpc,NIL},;
             {'PMP'         ,lPmp,Nil}}

//P.E. utilizado para manipular o Array aMata650, antes da geracao da Ordem de Producao.
If lM711SC2
   aRetPE := ExecBlock("M711SC2",.f.,.f.,ACLONE(aMata650))
   If Valtype(aRetPE) == "A"
      aMata650 := ACLONE(aRetPE)
   EndIf
EndIf

//Chamada da rotina automatica
msExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)

//Mostra Erro na geracao de Rotinas automaticas
If lMsErroAuto
   lMostraErro:= .t.
EndIf

Return

/*-------------------------------------------------------------------------/
//Programa: A107Periodo
//Autor:    Leonardo Quintania
//Data:     27/10/11
//Descricao:   Verifica peridiocidade para aglutinacao.
//Parametros:  01.dDatRef - Data de referência
//          02.dData   - Próximo dia
//          03.nTipo   - Tipo de aglutinação
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107Periodo(dDatRef,dData,nTipo)
Local lRet := .F.
Local nMes := 0

Default nTipo := 1

Do Case
   Case nTipo == 0 .OR. nTipo == 1 // Pelo Programa
   Case nTipo == 2 // Diario

   Case nTipo == 3 // Semanal
      If Dow(dDatRef) != 1
         lRet := .T.
      EndIf
   Case nTipo == 4 // Quinzenal
      If (Day(dDatRef)<=15) == (Day(dData)<=15)
         lRet := .T.
      EndIf
   Case nTipo == 5 // Mensal
      If Month(dDatRef) == Month(dData)
         lRet := .T.
      EndIf
   Case nTipo == 6 // Trimestral
      nRef := Month(dDatRef)
      nMes := Month(dData)
      If nRef >=1 .and. nRef <= 3
         If nMes >= 1 .and. nMes <= 3
            lRet := .T.
         EndIf
      ElseIf nRef >=4 .and. nRef <= 6
         If nMes >=4 .and. nMes <= 6
            lRet := .T.
         EndIf
      ElseIf nRef >=7 .and. nRef <= 9
         If nMes >=7 .and. nMes <= 9
            lRet := .T.
         EndIf
      ElseIf nRef >=10 .and. nRef <= 12
         If nMes >=10 .and. nMes <= 12
            lRet := .T.
         EndIf
      EndIf
   Case nTipo == 7 // Semestral
      If (Month(dDatRef)<=6) == (Month(dData)<=6)
         lRet := .T.
      EndIf
EndCase

Return lRet

/*-------------------------------------------------------------------------/
//Programa: PCPA107TB1
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Dividir os itens por threads a serem executadas em paralelo
//Parametros:  cQueryB1 - Filtro de itens (parametro por referencia
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PCPA107TB1(cQueryB1)
Local aThreads    := {}
Local aProdutos   := {}
Local nX          := 0
Local nY          := 0
Local nInicio     := 0
Local nRegProc    := 0
Local nThreads    := SuperGetMv('MV_A710THR',.F.,1)
Local cAliasSB1   := "ITENSTHR"
Local cQuery      := ""
Local cQueryX1    := ""
Local cA710Fil    := ""
Local lAllTp      := Ascan(A711Tipo,{|x| x[1] == .F.}) == 0
Local lA710SQL    := ExistBlock("A710SQL")
Local lAllGrp     := Ascan(A711Grupo,{|x| x[1] == .F.}) == 0
Local lMRPCINQ    := SuperGetMV("MV_MRPCINQ",.F.,.F.)

If nThreads <= 0
   nThreads := 10
EndIf

//Projeto Implementeacao de campos MRP e FANTASM no SBZ
If cDadosProd == "SBZ"
   //Query principal de itens
   cQuery := " SELECT SB1.B1_COD " +;
               " FROM "+RetSqlName("SB1")+" SB1 Left Outer Join "+RetSqlName("SBZ")+" SBZ " +;
                 " ON BZ_FILIAL = '"+xFilial("SBZ")+"' " +;
                " AND BZ_COD    = B1_COD AND SBZ.D_E_L_E_T_ = ' ' " +;
              " WHERE "
      //Query com a clausula WHERE
   cQueryX1 := "      SB1.B1_FILIAL='"+xFilial("SB1")+"' "
   cQueryX1 += "  AND ISNULL(BZ_FANTASM, B1_FANTASM) <> 'S' "
   cQueryX1 += "  AND ISNULL(BZ_MRP,     B1_MRP    ) IN (' ','S') "
   cQueryX1 += "  AND SB1.B1_MSBLQL  <> '1' "
   cQueryX1 += "  AND SB1.D_E_L_E_T_ = ' ' "
Else
   //Query principal de itens
   cQuery := " SELECT B1_COD " +;
               " FROM "+RetSqlName("SB1")+" SB1 " +;
              " WHERE "
      //Query com a clausula WHERE
   cQueryX1 := "     SB1.B1_FILIAL   = '"+xFilial("SB1") +"' "
   cQueryX1 += " AND SB1.B1_FANTASM <> 'S' "
   cQueryX1 += " AND SB1.D_E_L_E_T_  = ' ' "
   cQueryX1 += " AND SB1.B1_MRP     IN (' ','S')"
   cQueryX1 += " AND SB1.B1_MSBLQL  <> '1' "
Endif

//Query com o filtro para os JOBS
cQueryB1 := "  AND SB1.B1_FILIAL   = '"+xFilial("SB1")+"' "
cQueryB1 += "  AND SB1.B1_FANTASM <> 'S' "
cQueryB1 += "  AND SB1.D_E_L_E_T_  = ' ' "
cQueryB1 += "  AND SB1.B1_MRP     IN (' ','S')"
cQueryB1 += "  AND SB1.B1_MSBLQL  <> '1' "

//Caso não tenha sido selecionado todos, coloca TIPOS na QUERY
If !lAllTp
   cQueryX1 += " AND SB1.B1_TIPO IN (SELECT TP_TIPO FROM SOQTTP) "
   cQueryB1 += " AND SB1.B1_TIPO IN (SELECT TP_TIPO FROM SOQTTP) "
EndIf

//Caso não tenha sido selecionado todos e o parametro estiver marcado, coloca os GRUPOS na QUERY
If !lAllGrp .And. lMRPCINQ
   cQueryX1 += " AND SB1.B1_GRUPO IN (SELECT GR_GRUPO FROM SOQTGR) "
   cQueryB1 += " AND SB1.B1_GRUPO IN (SELECT GR_GRUPO FROM SOQTGR) "
End If

cQuery:= ChangeQuery(cQuery + cQueryX1)

If lA710SQL
   cA710Fil := ExecBlock("A710SQL", .F., .F., {"SB1", cQuery})
   If ValType(cA710Fil) == "C"
      cQuery := cA710Fil
   Endif
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
aEval(SB1->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasSB1,x[1],x[2],x[3],x[4]),Nil)})

Do While (cAliasSB1)->(!Eof())
   aAdd(aProdutos,(cAliasSB1)->B1_COD)
   (cAliasSB1)->(dbSkip())
EndDo

//Verifica Limite Maximo de 30 Threads
If nThreads > 30
   nThreads := 30
EndIf

//Analisa a quantidade de Threads X nRegistros
If Len(aProdutos) == 0
   aThreads := {}
ElseIf Len(aProdutos) < nThreads
   aThreads := ARRAY(1)       // Processa somente em uma thread
Else
   aThreads := ARRAY(nThreads) // Processa com o numero de threads informada
EndIf

//Calcula o registro original de cada thread e aciona thread gerando arquivo de fila.
For nX:=1 to Len(aThreads)
   aThreads[nX] := {{},1}

   //Registro inicial para processamento
   nInicio := IIf( nX == 1 , 1 , aThreads[nX-1,2]+1 )

   //Quantidade de registros a processar
   nRegProc += IIf( nX == Len(aThreads) , Len(aProdutos) - nRegProc, Int(Len(aProdutos)/Len(aThreads)) )

   aThreads[nX,2] := nRegProc

   For nY := nInicio To nRegProc
      aAdd(aThreads[nX,1],aProdutos[nY])
   Next nY
Next nX

//Encerra cAliasSB1
dbSelectArea(cAliasSB1)
dbCloseArea()

Return aThreads

/*-------------------------------------------------------------------------/
//Programa: PCPA107TRT
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Dividir os itens por threads a serem executadas em paralelo
//Parametros:  cQueryB1 - Nivel da estrutura a ser processado
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function PCPA107TRT(cNivEst)
Local cAliasTop   := "RECNECEST"
Local cQuery      := ""
Local cOpc        := ""
Local aProdutos   := {}
Local aItens      := {}
Local aThreads    := {}
Local nRecno      := 0
Local nY       := 0
Local nX       := 0
Local nInicio     := 0
Local nRegProc    := 0
Local nThreads    := SuperGetMv('MV_A710THR',.F.,1)
Local nPontPed    := 0

//Verifica todos produtos utilizados
cQuery := " SELECT DISTINCT SOR.OR_PROD OR_PROD, "
cQuery +=        " SOR.OR_NRRV OR_NRRV, "
If cDadosProd == "SBZ"
   cQuery +=     " ISNULL(SBZ.BZ_EMIN, SB1.B1_EMIN) B1_EMIN, "
Else
   cQuery +=     " SB1.B1_EMIN B1_EMIN, "
EndIf
cQuery +=        " SOR.R_E_C_N_O_ SORREC "
cQuery +=   " FROM " + RetSqlName("SOR") + " SOR, "
cQuery +=              RetSqlName("SOT") + " SOT, "
cQuery +=              RetSqlName("SB1") + " SB1 "
If cDadosProd == "SBZ"
   cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ  "
   cQuery +=   " ON SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"' "
   cQuery +=  " AND SBZ.BZ_COD     = SB1.B1_COD "
   cQuery +=  " AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery +=  " WHERE SOR.OR_FILIAL    = '" + xFilial("SOR") + "' "
cQuery +=    " AND SOT.OT_FILIAL    = '" + xFilial("SOT") + "' "
cQuery +=    " AND SB1.B1_FILIAL    = '" + xFilial("SB1") + "' "
cQuery +=    " AND SOR.R_E_C_N_O_   = SOT.OT_RGSOR "
cQuery +=    " AND SOR.OR_PROD     = SB1.B1_COD "
cQuery +=    " AND SOR.OR_EMP      = '" + cEmpAnt + "'"
cQuery +=    " AND SOR.OR_FILEMP   = '" + cFilAnt + "'"
cQuery +=    " AND (SOT.OT_QTNECE <> 0 "
cQuery +=    "  OR  SOT.OT_QTSAID <> 0 "
cQuery +=    "  OR  SOT.OT_QTSALD <> 0 "
cQuery +=    "  OR  SOT.OT_QTSEST <> 0 "
cQuery +=    "  OR  SOT.OT_QTENTR <> 0 "
cQuery +=    "  OR  SOT.OT_QTSLES <> 0 "
If cDadosProd == "SBZ"
   cQuery += "  OR  ISNULL(BZ_EMIN,B1_EMIN) <> 0) "
Else
   cQuery += "  OR  B1_EMIN       <> 0) "
EndIf

If !Empty(cNivEst)
   cQuery += " AND SOR.OR_NRLV = '" + cNivEst + "' "
EndIf

cQuery +=   " ORDER BY SOR.OR_PROD, "
cQuery +=            " SOR.OR_NRRV, "
If cDadosProd == "SBZ"
   cQuery +=         " ISNULL(SBZ.BZ_EMIN,SB1.B1_EMIN), "
Else
   cQuery +=         " SB1.B1_EMIN, "
EndIf
cQuery +=            " SOR.R_E_C_N_O_ "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
dbSelectArea(cAliasTop)

While !Eof()
   nRecno := SORREC
   SOR->(DbGoTo(nRecno))
   cOpc := SOR->OR_OPC

   If verPontPed((cAliasTop)->OR_PROD)
      nPontPed := (cAliasTop)->B1_EMIN
   Else
      nPontPed := 0
   EndIf

   aItens := {}
   aAdd(aItens,{(cAliasTop)->OR_PROD,cOpc,(cAliasTop)->OR_NRRV,(cAliasTop)->SORREC,nPontPed})
   aAdd(aProdutos,aItens)

   dbSkip()
EndDo

(cAliasTop)->(dbCloseArea())

//Verifica Limite Maximo de 30 Threads
If nThreads > 30
   nThreads := 30
EndIf

//Analisa a quantidade de Threads X nRegistros
If Len(aProdutos) == 0
   aThreads := {}
ElseIf Len(aProdutos) < nThreads
   aThreads := ARRAY(1)       // Processa somente em uma thread
Else
   aThreads := ARRAY(nThreads)   // Processa com o numero de threads informada
EndIf

//Calcula o registro original de cada thread e aciona thread gerando arquivo de fila.
For nX := 1 to Len(aThreads)
   aThreads[nX] := {{},1}

   //Registro inicial para processamento
   nInicio := IIf(nX == 1,1,aThreads[nX-1,2]+1)

   //Quantidade de registros a processar
   nRegProc += IIf(nX == Len(aThreads),Len(aProdutos) - nRegProc,Int(Len(aProdutos)/Len(aThreads)))

   aThreads[nX,2] := nRegProc
   For nY := nInicio To nRegProc
      aAdd(aThreads[nX,1],aProdutos[nY,1])
   Next nY

Next nX

Return aThreads

/*-------------------------------------------------------------------------/
//Programa: A107StrRev
//Autor:    Marcelo Iuspa
//Data:     28/06/04
//Descricao:   Retorna STRING com numero da revisao caso esteja em uso
//Parametros:  01.cRevisao   - Revisao utilizada
//          02.cStrAntes  - Texto usado antes
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107StrRev(cRevisao, cStrAntes)
Local cRet := ""

If A107TrataRev() .And. ! Empty(cRevisao)
   Default cStrAntes := " "
   cRet := cStrAntes + STR0062 + ": " + cRevisao
Endif

Return(cRet)

/*-------------------------------------------------------------------------/
//Programa: A107MontPer
//Autor:    Andre Anjos
//Data:     12/12/07
//Descricao:   Monta o painel para selecao da peridiocidade
//Parametros:  oCenterPanel - Objeto do painel
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107MontPer(oCenterPanel)
Local oUsado,oChk,oChk2,oChkQual,oChkQual2,oQual,oQual2
Local lQual,lQual2

@ 10,10 TO 125,115 LABEL OemToAnsi(STR0009) OF oCenterPanel  PIXEL //"Periodicidade do MRP"
@ 25,20 RADIO oUsado VAR nUsado 3D SIZE 70,10 PROMPT  OemToAnsi(STR0010),; //"Per¡odo Di rio"
OemToAnsi(STR0011),; //"Per¡odo Semanal"
OemToAnsi(STR0012),; //"Per¡odo Quinzenal"
OemToAnsi(STR0013),; //"Per¡odo Mensal"
OemToAnsi(STR0014),; //"Per¡odo Trimestral"
OemToAnsi(STR0015),; //"Per¡odo Semestral"
OemToAnsi(STR0016) OF oCenterPanel PIXEL  //"Per¡odos Diversos"
@ 102,020 Say OemToAnsi(STR0017) SIZE 60,10 OF oCenterPanel PIXEL //"Quantidade de Per¡odos:"
@ 100,085 MSGET nQuantPer Picture "999" SIZE 15,10 OF oCenterPanel PIXEL

@ 10,130 TO 125,400 LABEL OemToAnsi(STR0041) OF oCenterPanel PIXEL //"Filtro"
//Tipo
@ 25,150 CHECKBOX oChkQual VAR lQual  PROMPT OemToAnsi(STR0020) SIZE 50, 10 OF oCenterPanel PIXEL ON CLICK (AEval(a711Tipo , {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.)) //"Inverter Selecao"
oQual := TCBrowse():New(35,150,100,81,,,,oCenterPanel,,,,,{||A711Tipo:=CA711Troca(oQual:nAt,A711Tipo),oQual:Refresh()},,,,,,,.T.,,.T.,,.F.,,)
oQual:SetArray(a711Tipo)

oQual:AddColumn(TCColumn():New("",{|| If(a711Tipo[oQual:nAt,1],oOk,oNo)},,,,"LEFT",,.T.,.F.,,,,.T.,))
oQual:AddColumn(TCColumn():New(OemToAnsi(STR0021),{|| a711Tipo[oQual:nAt,2]},,,,"LEFT",,.F.,.F.,,,,.F.,))
oQual:Refresh()

//Grupo
@ 25,280 CHECKBOX oChkQual2 VAR lQual2 PROMPT OemToAnsi(STR0020) SIZE 50, 10 OF oCenterPanel PIXEL ON CLICK (AEval(a711Grupo, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}),oQual2:Refresh(.F.)) //"Inverter Selecao"
oQual2 := TCBrowse():New(35,280,100,81,,,,oCenterPanel,,,,,{||a711Grupo:=CA711Troca(oQual2:nAt,A711Grupo),oQual2:Refresh()},,,,,,,.T.,,.T.,,.F.,,)
oQual2:SetArray(a711Grupo)

oQual2:AddColumn(TCColumn():New("",{|| If(a711Grupo[oQual2:nAt,1],oOk,oNo)},,,,"LEFT",,.T.,.F.,,,,.T.,))
oQual2:AddColumn(TCColumn():New(OemToAnsi(STR0022),{|| a711Grupo[oQual2:nAt,2]},,,,"LEFT",,.F.,.F.,,,,.F.,))
oQual2:Refresh()

@ 135,10 TO 180,400 LABEL OemToAnsi(STR0061) OF oCenterPanel PIXEL //"Opcionais"
@ 150,20 CHECKBOX oChk  VAR lPedido PROMPT OemToAnsi(STR0018) SIZE 85, 10 OF oCenterPanel PIXEL ;oChk:oFont := oCenterPanel:oFont   //"Considera Pedidos em Carteira"
@ 160,20 CHECKBOX oChk2 VAR lLogMRP PROMPT OemToAnsi(STR0019) SIZE 85, 10 OF oCenterPanel PIXEL ;oChk2:oFont := oCenterPanel:oFont  //"Log de eventos do MRP"

Return

/*-------------------------------------------------------------------------/
//Programa: A107MontVis
//Autor:    Andre Anjos
//Data:     29/04/08
//Descricao:   Monta o painel para visualizacao da ultima exececucao do MRP
//Parametros:  oCenterPanel - Objeto do painel
//          lVisualiza   - Indica o tipo de visualização
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107MontVis(oCenterPanel,lVisualiza)
Local oSay1, oSay2, oSay3, oCheck
Local cProgra  := ""
Local aSize    := MsAdvSize()
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := {}
Local aObjects    := {}

AADD(aObjects,{450,20,.T.,.T.,.F.})
aPosObj:=MsObjSize(aInfo,aObjects)

oSay1:= tSay():New(10,10,{|| OemToAnsi(STR0142+" "+STR0143)},oCenterPanel,,,,,,.T.,,,aPosObj[1,4]-200,aPosObj[1,3])
oSay2:= tSay():New(45,10,{|| OemToAnsi(STR0144)},oCenterPanel,,,,,,.T.,,,aPosObj[1,4]-200,aPosObj[1,3])
oCheck := TCheckBox():New(60,10,OemToAnsi(STR0145),{|| lVisualiza},oCenterPanel,100,210,,;
         {|| lVisualiza:=!lVisualiza},,,,,,.T.,,,) //Ativar visualização

dbSelectArea("SOR")
dbSetOrder(1)
dbGotop()

If !Eof()
   cProgra := AllTrim(SOR->OR_NRMRP)
   dbCloseArea()
   oSay2:= tSay():New(45,75,{|| cProgra},oCenterPanel,,,,,,.T.,,,aPosObj[1,4]-200,aPosObj[1,3])
   oCheck:Enable()
Else
   oSay2:= tSay():New(45,75,{|| OemToAnsi(STR0146)},oCenterPanel,,,,,,.T.,CLR_RED,,aPosObj[1,4]-200,aPosObj[1,3])
   oCheck:Disable()
EndIf

Return

/*-------------------------------------------------------------------------/
//Programa: P107FilNec
//Autor:    Ricardo Prandi
//Data:     16/10/2013
//Descricao:   Ativa Filtro exibindo somente os produtos com necessidade
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function P107FilNec(lFiltro)

      if lFiltro 
            PA107Tree(aPergs711[28]==1,/*02*/,.T.)
            lAtvFilNes := .T.
      Else
            PA107Tree(.F.,,.F.,.F.)
      EndIf

Return .T.

/*-------------------------------------------------------------------------/
//Programa: AT107IMarc
//Autor:    Leonardo Quintania
//Data:     09/05/2012
//Descricao:   Marca todas as linhas com evento de clique no cabeçalho do browse
//Parametros:  oBrowse - Objeto do browse
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function AT107IMarc(oBrowse)
Local aChks         :={}

aEval(oBrowse:aCols, {|x| aAdd(aChks,If(x[1]==oOK,.T.,.F.))})

If aScan(aChks, {|x| !x }) > 0
   aEval(@oBrowse:aCols, {|x| x[1] := oOK})
Else
   aEval(@oBrowse:aCols, {|x| x[1] := oNO})
EndIf

oBrowse:Refresh()

Return

/*-------------------------------------------------------------------------/
//Programa: A107Reprog
//Autor:    Cleber Maldonado
//Data:     25/05/2012
//Descricao:   Reprograma as opções Firme/Prevista na tela períodos para geração de SC's / OP's
//Parametros:  Param1 - Objeto com os períodos do MRP
//          Param2 - Numero da opção selecionada (Firme/Prevista)
//          Param3 - Data de inicio para reprogramar opções
//          Param4 - Data limite para reprogramar opções
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107Reprog(oGetPer,nSelec,dDatDe,dDatAte)
Local nX := 1

For nX := 1 To Len(oGetPer:aCols)
   If CTOD(oGetPer:aCols[nX,2]) >= dDatde .and. CTOD(oGetPer:aCols[nX,2]) <= dDatAte
      oGetPer:aCols[nX,3] := Alltrim(Str(nSelec))
   Endif
Next nX

Return .T.

/*-------------------------------------------------------------------------/
//Programa: A107VerHl
//Autor:    Leonardo Quintania
//Data:     20/12/11
//Descricao:   Verifica se o produto informado possui Horizonte Liberacao
//Parametros:  dDatPrf  - Data de referencia
//          cProduto - Codigo do produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107VerHl(dDatPrf,cProduto)
Local nDiasHf := Posicione("SB5",1,xFilial("SB5")+AllTrim(cProduto),"B5_DIASHL")
Local lGera := .T.

If !Empty(nDiasHf)
   If (dDatPrf <= (dDataBase + nDiasHf))
      lGera:= .T.
   Else
      lGera:= .F.
   EndIf
EndIf

Return lGera

/*-------------------------------------------------------------------------/
//Programa: A107VerHf
//Autor:    Leonardo Quintania
//Data:     20/12/11
//Descricao:   Verifica se o produto informado possui Horizonte Firme
//Parametros:  dDatPrf  - Data de referencia
//          cProduto - Codigo do produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107VerHf(dDatPrf,cProduto)
Local nDiasHf  := Posicione("SB5",1,xFilial("SB5")+AllTrim(cProduto),"B5_DIASHF")
Local cTpOp    := If(aPergs711[10] == 1,"F","P")
Local cTpOpPar := ""
Local i        := aScan(aPeriodos,{|x| x == dDatPrf})
Local cFC      := "C"

SG1->(dbSetOrder(1))
If SG1->(dbSeek(xFilial("SG1")+cProduto))
   cFC := "F"
EndIf

If ExistBlock("A650CCF")
   cFC := ExecBlock("A650CCF",.F.,.F.,{cProduto,cTipo711,dDatPrf})
   If ValType(cFC) # "C"
      cFC := If(SG1->(dbSeek(xFilial("SG1")+cProduto)),"F","C")
   EndIf
EndIf

cTpOpPar := If(aPergs711[04] == 1 .Or. cFC == "F",cSelF,cSelFSC)

If !Empty(nDiasHf)
   If (dDatPrf <= (dDataBase + nDiasHf))
      cTpOp:= "F"
   Else
      cTpOp:= "P"
   EndIf
ElseIf Substr(cTpOpPar,i,1) == "û"
    cTpOp:= "F"
Else
   cTpOp:= "P"
EndIf

Return cTpOp

/*-------------------------------------------------------------------------/
//Programa: PCPA107LCK
//Autor:    Ricardo Prandi
//Data:     23/10/2013
//Descricao:   Cria semaforo para as tabelas
//Parametros:  lInJob - Indica se veio de JOB
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function PCPA107LCK(lInJob)
Local nTentativa := 0

Default lInJob := .F.

While !LockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
   nTentativa ++
   If nTentativa > 10000
      ProcLogAtu("MENSAGEM","Limite de tentativas ultrapassado.","Limite de tentativas ultrapassado.")
      Exit
   EndIf
End

Return .T.

/*-------------------------------------------------------------------------/
//Programa: PCPA107LOG
//Autor:    Lucas Konrad França
//Data:     25/11/2014
//Descricao:   Monta LOG de processamento do MRP
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function PCPA107LOG()
Local cQuery      := ""
Local cAliasTop   := "MONTALOG"
Local nRegAnt     := 0
Local nAcho       := 0
Local nz          := 0
Local z           := 0
Local nSaldo      := 0
Local nB1Emin     := 0
Local nB1Emax     := 0
Local lCalcula    := .F.
Local lLog008     := .F.
Local lLog009     := .F.
Local lVoltaSaldo := .F.
Local aSaldos     := {}
Local aDados      := {}

//Atualiza o log de processamento
ProcLogAtu("MENSAGEM","Iniciando montagem do Log MRP","Iniciando montagem do Log MRP")

cQuery := " SELECT SOR.OR_PROD, "
cQuery +=        " SOR.OR_EMP, "
cQuery +=        " SOR.OR_FILEMP, "
cQuery +=        " SOT.OT_PERMRP, "
cQuery +=        " SOT.OT_QTSLES, "
cQuery +=        " SOT.OT_QTENTR, "
cQuery +=        " SOT.OT_QTSAID, "
cQuery +=        " SOT.OT_QTSEST, "
cQuery +=        " SOT.OT_QTSALD, "
cQuery +=        " SOT.OT_QTNECE, "
If cDadosProd == "SBZ"
   cQuery +=     " ISNULL(SBZ.BZ_EMIN, SB1.B1_EMIN) B1_EMIN, "
   cQuery +=     " ISNULL(SBZ.BZ_EMAX, SB1.B1_EMAX) B1_EMAX, "
Else
   cQuery +=     " SB1.B1_EMIN, "
   cQuery +=     " SB1.B1_EMAX, "
EndIf
cQuery +=        " SOR.R_E_C_N_O_ SORREC "
cQuery +=   " FROM " + RetSqlName("SOR") + " SOR, "
cQuery +=              RetSqlName("SOT") + " SOT, "
cQuery +=              RetSqlName("SB1") + " SB1 "
If cDadosProd == "SBZ"
   cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ  "
   cQuery +=   " ON SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"' "
   cQuery +=  " AND SBZ.BZ_COD     = SB1.B1_COD "
   cQuery +=  " AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery +=  " WHERE SOR.OR_FILIAL   = '" + xFilial("SOR") + "' "
cQuery +=    " AND SOT.OT_FILIAL   = '" + xFilial("SOT") + "' "
cQuery +=    " AND SB1.B1_FILIAL   = '" + xFilial("SB1") + "' "
cQuery +=    " AND SOR.R_E_C_N_O_  = SOT.OT_RGSOR "
cQuery +=    " AND SOR.OR_PROD     = SB1.B1_COD "
cQuery +=    " AND SB1.D_E_L_E_T_   = ' ' "
cQuery +=    " AND EXISTS (SELECT 1 "
cQuery +=                  " FROM " + RetSqlName("SOT") + " SOTA, "
cQuery +=                 " WHERE SOTA.OT_FILIAL   = '" + xFilial("SOT") + "' "
cQuery +=                   " AND SOTA.OT_RGSOR    = SOR.R_E_C_N_O_ "
cQuery +=                   " AND (SOTA.OT_QTNECE <> 0 "
cQuery +=                   "  OR  SOTA.OT_QTSAID <> 0 "
cQuery +=                   "  OR  SOTA.OT_QTSALD <> 0 "
cQuery +=                   "  OR  SOTA.OT_QTSEST <> 0 "
cQuery +=                   "  OR  SOTA.OT_QTENTR <> 0 "
cQuery +=                   "  OR  SOTA.OT_QTSLES <> 0)) "
cQuery +=  " ORDER BY SOR.R_E_C_N_O_, "
cQuery +=           " SOT.OT_PERMRP "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

While !Eof()
   If nRegAnt <> (cAliasTop)->SORREC
      If nRegAnt <> 0
         lCalcula := .T.
      Else
         nRegAnt := (cAliasTop)->SORREC
      EndIf
   EndIf

   If !lCalcula
      AADD(aSaldos,{((cAliasTop)->OT_QTSAID + (cAliasTop)->OT_QTSEST),(cAliasTop)->OT_QTSALD})
      If verPontPed((cAliasTop)->OR_PROD)
         nB1Emin := (cAliasTop)->B1_EMIN
      Else
         nB1Emin := 0
      EndIf
      nB1Emax := (cAliasTop)->B1_EMAX
      dbSkip()
   EndIf

   If lCalcula .Or. Eof()
      lLog008 := .T.
      lLog009 := .T.
      lCalcula := .F.
      SOR->(dbGoto(nRegAnt))

      For nz := 1 to Len(aPeriodos)
         nSaldo := aSaldos[nz,2]

         If QtdComp(nSaldo) > QtdComp(0)
            //Reativa a exibicao do log pois o saldo voltou
            If nSaldo > nB1Emin
               lLog009 := .T.
            EndIf

            //Verifica se atingiu ponto de pedido
            If lLog009 .And. nB1Emin > 0 .And. QtdComp(nSaldo) <= QtdComp(nB1Emin)
               A107CriaLOG("009",SOR->OR_PROD,{nB1Emin,nSaldo,aPeriodos[nz],"SB1"},lLogMRP,c711NumMrp)
               //Desativa a exibicao do log para os periodos seguintes.
               lLog009 := .F.
            EndIf

            //Reativa a exibicao do log pois o saldo voltou
            If nSaldo <= nB1Emax
               lLog008 := .T.
            EndIf

            //Verifica se atingiu estoque maximo
            If lLog008 .And. nB1Emax > 0 .And. QtdComp(nSaldo) > QtdComp(nB1Emax)
               A107CriaLOG("008",SOR->OR_PROD,{nB1Emax,nSaldo,aPeriodos[nz],"SB1"},lLogMRP,c711NumMrp)
               lLog008 := .F.
            EndIf

            //Le os movimentos e grava as quantidades de maneira analitica no array aDados
            aDados:={}
            dbSelectArea("SOQ")
            dbSetOrder(5)

            If dbSeek(xFilial("SOR")+SOR->OR_EMP+SOR->OR_FILEMP+SOR->OR_PROD+SOR->OR_OPCORD+SOR->OR_NRRV+StrZero(nz,3))
               While !Eof() .AND. xFilial("SOR")+SOR->OR_EMP+SOR->OR_FILEMP+SOR->OR_PROD+SOR->OR_OPCORD+SOR->OR_NRRV+StrZero(nz,3)+"2" == xFilial("SOQ")+OQ_EMP+OQ_FILEMP+OQ_PROD+OQ_OPCORD+OQ_NRRV+OQ_PERMRP+OQ_TPRG                     // ARRAY CONTENDO QUANTIDADE, REGISTRO E IDENTIFICADOR SE JA FOI MARCADO
                  //PARA ATRASO
                  AADD(aDados,{OQ_QUANT,Recno(),.F.})
                  dbSkip()
               End

               //Ordena registros pela quantidade
               ASORT(aDados,,,{|x,y| x[1] < y[1]})
            EndIf

            For z := nz + 1 To Len(aPeriodos)
               //Se tem saida verifica quais movimentos podem ser atrasados
               While (QtdComp(aSaldos[z,1]) > QtdComp(0)) .And. (QtdComp(aSaldos[z,2]) <= QtdComp(0))
                  nAcho := Ascan(aDados,{|x| x[3] == .F. .And. x[1] <= aSaldos[z,1]})

                  If nAcho > 0
                     SOQ->(dbGoto(aDados[nAcho,2]))
                     A107CriaLOG("002",SOQ->OQ_PROD,{SOQ->OQ_DTOG,SOQ->OQ_DOC,SOQ->OQ_ITEM,SOQ->OQ_ALIAS,aPeriodos[z]},lLogMRP,c711NumMrp)
                     aSaldos[z,1] -= aDados[nAcho,1]
                     aDados[nAcho,3] := .T.
                  Else
                     Exit
                  EndIf
               End
            Next z

            //Verifica todos movimentos que podem ser cancelados pois nao tem saida subsequente
            If QtdComp(nSaldo) > QtdComp(0)
               While .T.
                  lVoltaSaldo := .F.
                  nAcho := Ascan(aDados,{|x| x[3] == .F.})

                  If nAcho > 0
                     aDados[nAcho,3] := .T.

                     If QtdComp(aDados[nAcho,1]) <= QtdComp(nSaldo)
                        SOQ->(dbGoto(aDados[nAcho,2]))

                        //Verifica se existe necessidade anterior ao periodo
                        For z := nz to 1 Step -1
                           If QtdComp(aSaldos[z,2]) < QtdComp(0)
                              lVoltaSaldo := .T.
                              A107CriaLOG("003",SOQ->OQ_PROD,{SOQ->OQ_DTOG,SOQ->OQ_DOC,SOQ->OQ_ITEM,SOQ->OQ_ALIAS,aPeriodos[z]},lLogMRP,c711NumMrp)
                           EndIf
                        Next z

                        //Caso nao tenha necessidade anterior ao periodo identifica que evento pode ser cancelado
                        If !lVoltaSaldo
                           A107CriaLOG("007",SOQ->OQ_PROD,{SOQ->OQ_DTOG,SOQ->OQ_DOC,SOQ->OQ_ITEM,SOQ->OQ_ALIAS},lLogMRP,c711NumMrp)
                        EndIf

                        //Retira o saldo de todos os periodos subsequentes
                        For z := nz to Len(aSaldos)
                           aSaldos[z,2]-=aDados[nAcho,1]
                        Next z

                        //Retira o saldo
                        nSaldo-=aDados[nAcho,1]
                     EndIf
                  Else
                     Exit
                  EndIf
               End
            EndIf
         EndIf
      Next nz
      DbSelectArea(cAliasTop)
      nRegAnt := (cAliasTop)->SORREC
      aSaldos := {}

      AADD(aSaldos,{((cAliasTop)->OT_QTSAID + (cAliasTop)->OT_QTSEST),(cAliasTop)->OT_QTSALD})
      If verPontPed((cAliasTop)->OR_PROD)
         nB1Emin := (cAliasTop)->B1_EMIN
      Else
         nB1Emin := 0
      EndIf
      nB1Emax := (cAliasTop)->B1_EMAX
      dbSkip()
   EndIf
End

(cAliasTop)->(dbCloseArea())

//Atualiza o log de processamento
ProcLogAtu("MENSAGEM","Termino da montagem do Log MRP","Termino da montagem do Log MRP")

Return

/*-------------------------------------------------------------------------/
//Programa: A107ShLog
//Autor:    Rodrigo A Sartorio
//Data:     15/09/03
//Descricao:   Mostra os dados do LOG do MRP para o produto posicionado
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107ShLog()
Local aArea    := GetArea()
Local cCargo      := oTreeM711:GetCargo()
Local nPos        := AsCan(aDbTree,{|x| x[7]==SubStr(cCargo,3,12)})
Local cProduto := Iif(Empty(nPos),Space(15),aDbTree[nPos,1])
Local cCadastro   := OemToAnsi(STR0068) //"Log de eventos do MRP"
Local oDlg
Local oGetd
Local aObjects   := {}
Local aPosObj    := {}
Local aSize      := MsAdvSize()
Local aInfo      := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local cSeek      := xFilial("SHG")+c711NumMRP
Local bSeekWhile := { || SHG->HG_FILIAL+SHG->HG_SEQMRP } //Condicao While para montar o aCols
Local aNoFields  := {}

Private aHeader  := {}
Private aCols    := {}
Private aRotina  := {{ "","",0,1},; //"Pesquisar"
                  { "","",0,2}}  //"Visualizar"

//Verifica se consulta LOG total ou do produto
If !Empty(cProduto) .And. (Substr(cCargo,1,2) <> "00")
   aNoFields  := {"HG_COD"}
   cCadastro  += " - "+cProduto
   cSeek      += cProduto
   bSeekWhile := { || SHG->HG_FILIAL+SHG->HG_SEQMRP+SHG->HG_COD }
EndIf

//Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
FillGetDados(1,'SHG',1,cSeek,bSeekWhile,,aNoFields,,,,,,,,,)

//Caso possua informacoes apresenta GETDADOS com as Informaçoes
If Len(aCols) > 0
   // Array com objetos utilizados
   AADD(aObjects,{70,70,.T.,.T.,.F.})
   aPosObj:=MsObjSize(aInfo,aObjects)
   DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
   oGetd := MsGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],1)
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
EndIf

RestArea(aArea)

Return

//---------------------------------------------------------------/
// função para retornar a data fim a ser considerar no MRP
// Autor: Lucas Pereira
// Data: 20/02/2014
// Uso: P107JCTB
//---------------------------------------------------------------/
Function PCPA107DtF()
Local dFimProj

If Len(aPeriodos) > 1 .And. nTipo # 1 .And. nTipo # 7 .And. nTipo # 2 .And. nTipo # 3
   
  IF nTipo == 4
		dFimProj := LastDay(aPeriodos[Len(aPeriodos)])
	Else
		dFimProj := aPeriodos[Len(aPeriodos)] + (aPeriodos[Len(aPeriodos)] - aPeriodos[Len(aPeriodos)-1])
  Endif
   
   If nTipo == 4 .And. Month(dFimProj-30)==2
      nSomaDia := 30- Day(CTOD("01/03/"+Substr(Str(Year(aPeriodos[Len(aPeriodos)-1]),4),3,2))-1)
      dFimProj := aPeriodos[Len(aPeriodos)] + (aPeriodos[Len(aPeriodos)] - aPeriodos[Len(aPeriodos)-1])+nSomaDia
   EndIf
Else
   If nTipo == 1 .or. nTipo == 7    // Projecao Diaria ou Periodos Variaveis
      dFimProj := aPeriodos[Len(aPeriodos)]
   ElseIf nTipo == 2 // Projecao Semanal
      dFimProj := aPeriodos[Len(aPeriodos)] + 6
   ElseIf nTipo == 3 // Projecao Quinzenal
      dFimProj := CtoD(If(Substr(DtoC(aPeriodos[Len(aPeriodos)]),1,2)="01","15"+Substr(DtoC(aPeriodos[Len(aPeriodos)]),3,6),;
         "01/"+If(Month(aPeriodos[Len(aPeriodos)])+1<=12,StrZero(Month(aPeriodos[Len(aPeriodos)])+1,2)+"/"+;
         SubStr(DtoC(aPeriodos[Len(aPeriodos)]),7,4),"01/"+Substr(Str(Year(aPeriodos[Len(aPeriodos)])+1,4),3,2))),"ddmmyy")
   ElseIf nTipo == 4 // Projecao Mensal
      dFimProj := CtoD("01/"+If(Month(aPeriodos[Len(aPeriodos)])+1<=12,StrZero(Month(aPeriodos[Len(aPeriodos)])+1,2)+;
         "/"+Substr(Str(Year(aPeriodos[Len(aPeriodos)]),4),3,2),"01/"+Substr(Str(Year(aPeriodos[Len(aPeriodos)])+1,4),3,2)),"ddmmyy")
   ElseIf nTipo == 5 // Projecao Trimestral
      dFimProj := CtoD("01/"+If(Month(aPeriodos[Len(aPeriodos)])+3<=12,StrZero(Month(aPeriodos[Len(aPeriodos)])+3,2)+;
         "/"+Substr(Str(Year(aPeriodos[Len(aPeriodos)]),4),3,2),"01/"+Substr(Str(Year(aPeriodos[Len(aPeriodos)])+1,4),3,2)),"ddmmyy")
   ElseIf nTipo == 6 // Projecao Semestral
      dFimProj := CtoD("01/"+If(Month(aPeriodos[Len(aPeriodos)])+6<=12,StrZero(Month(aPeriodos[Len(aPeriodos)])+6,2)+;
         "/"+Substr(Str(Year(aPeriodos[Len(aPeriodos)]),4),3,2),"01/"+Substr(Str(Year(aPeriodos[Len(aPeriodos)])+1,4),3,2)),"ddmmyy")
   EndIf
EndIf

Return dFimProj

/*-------------------------------------------------------------------------/
//Programa: PCPA104LCK
//Autor:    Ricardo Prandi
//Data:     23/10/2013
//Descricao:   Cria semaforo para as tabelas
//Parametros:  lInJob - Indica se veio de JOB
//Uso:      MATA712
//------------------------------------------------------------------------*/
Function PCPA104LCK(lInJob)
Local nTentativa := 0

Default lInJob := .F.

While !LockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
   nTentativa ++
   If nTentativa > 10000
      ProcLogAtu("MENSAGEM","Limite de tentativas ultrapassado.","Limite de tentativas ultrapassado.")
      Exit
   EndIf
End

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ CA711Troca                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 21/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Troca marcador entre x e branco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³nIt        Linha onde o click do mouse ocorreu              ³±±
±±³           ³aArray     Array com as opcoes para selecao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ PCPA107                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CA711Troca(nIt,aArray)
aArray[nIt,1] := !aArray[nIt,1]
Return aArray

//---------------------------------------------------------------------------------------------
//Corrige o valor pelo tamanho do field
//---------------------------------------------------------------------------------------------
Static Function CorValFld(cValue,cField)
Return AllTrim(cValue) + Space(TamSX3(cField)[1] - Len(AllTrim(cValue)))
//-----------------------------------------------------------------
/*/{Protheus.doc} A107CarEmp
Carga das empresas centralizadas.

@param cGrupo       -> Empresa centralizadora
@param cFil         -> Filial centralizadora
@return aEmpresas   -> Array com as empresas centralizadas.
                         aEmpresas[1][1] = Código da empresa centralizada
                         aEmpresas[1][2] = Filial da empresa centralizada
                         aEmpresas[1][3] = Prioridade no grupo MRP
@author  Lucas Konrad França
@since      12/11/2014
@version    P12
/*/
//-----------------------------------------------------------------
Function A107CarEmp(cGrupo, cFil)
   Local cEmpresa  := ""
   Local cUnid     := ""
   Local aInfFil   := {}
   Local aEmpresas := {}
   Local nTamEmp   := Len(FWSM0Layout(cEmpAnt,1))
   Local nTamUNeg  := Len(FWSM0Layout(cEmpAnt,2))
   Local nTamFil   := Len(FWSM0Layout(cEmpAnt,3))
   Local nTamSM0   := FWSizeFilial(cEmpAnt)

   If lGestEmp
      aInfFil := FWArrFilAtu(cGrupo,cFil)
      cEmp  := aInfFil[SM0_EMPRESA]
      cUnid := aInfFil[SM0_UNIDNEG]
      cFil  := aInfFil[SM0_FILIAL]

      dbSelectArea("SOO")
      SOO->(dbSetOrder(2))
      If !SOO->(dbSeek(xFilial("SOO")+CorValFld(cGrupo,"OO_CDEPCZ")+CorValFld(cEmp,"OO_EMPRCZ")+CorValFld(cUnid,"OO_UNIDCZ")+CorValFld(cFil,"OO_CDESCZ")))
         //Não é uma empresa centralizadora.
         //Verifica se é uma empresa centralizada, se for, não deve permitir executar este MRP.
         dbSelectArea("SOP")
         SOP->(dbSetOrder(4))
         If !SOP->(dbSeek(xFilial("SOP")+CorValFld(cGrupo,"OP_CDEPGR")+CorValFld(cEmp,"OP_EMPRGR")+CorValFld(cUnid,"OP_UNIDGR")+CorValFld(cFil,"OP_CDESGR")))
            //Não é uma empresa centralizadora nem uma empresa centralizada, executa o MRP para a empresa logada.
            aAdd(aEmpresas,{AllTrim(cEmpAnt),AllTrim(cFilAnt),1})
         EndIf
      Else
         cTesEntr := SOO->OO_TE
         cTesSaid := SOO->OO_TS
         //É uma empresa centralizadora, faz a empresa das empresas centralizadas
         dbSelectArea("SOP")
         SOP->(dbSetOrder(3))
         If (SOP->(dbSeek(xFilial("SOP")+CorValFld(cGrupo,"OP_CDEPCZ")+CorValFld(cEmp,"OP_EMPRCZ")+CorValFld(cUnid,"OP_UNIDCZ")+CorValFld(cFil,"OP_CDESCZ"))))
            While ( !SOP->(Eof())           .And.;
                     AllTrim(SOP->OP_CDEPCZ) == AllTrim(cGrupo) .And. ;
                     AllTrim(SOP->OP_CDESCZ) == AllTrim(cFil)   .And. ;
                     AllTrim(SOP->OP_EMPRCZ) == AllTrim(cEmp)   .And. ;
                     AllTrim(SOP->OP_UNIDCZ) == AllTrim(cUnid) )
               aAdd(aEmpresas,{AllTrim(SOP->OP_CDEPGR),;
                               Padr(SOP->OP_EMPRGR,nTamEmp) + Padr(SOP->OP_UNIDGR,nTamUneg) + Padr(SOP->OP_CDESGR,nTamFil),;
                               SOP->OP_NRPYGR})
               SOP->(dbSkip())
            EndDo
            //Ordena as empresas pela prioridade
            aSort(aEmpresas,,,{|x,y| x[3] < y[3]})
         EndIf
      EndIf
   Else
      dbSelectArea("SOO")
      SOO->(dbSetOrder(1))
      If !SOO->(dbSeek(xFilial("SOO")+cGrupo+PadR(cFil,nTamFil)))
         //Não é uma empresa centralizadora.
         //Verifica se é uma empresa centralizada, se for, não deve permitir executar este MRP.
         dbSelectArea("SOP")
         SOP->(dbSetOrder(2))
         If !SOP->(dbSeek(xFilial("SOP")+cGrupo+PadR(cFil,nTamFil)))
            //Não é uma empresa centralizadora nem uma empresa centralizada, executa o MRP para a empresa logada.
            aAdd(aEmpresas,{AllTrim(cEmpAnt),AllTrim(cFilAnt),1})
         EndIf
      Else
         //É uma empresa centralizadora, faz a empresa das empresas centralizadas
         dbSelectArea("SOP")
         SOP->(dbSetOrder(1))
         If (SOP->(dbSeek(xFilial("SOP")+cGrupo+PadR(cFil,nTamFil))))
            While ( !SOP->(Eof())           .And.;
                     AllTrim(SOP->OP_CDEPCZ) == AllTrim(cGrupo) .And. ;
                     AllTrim(SOP->OP_CDESCZ) == AllTrim(cFil) )
               aAdd(aEmpresas,{AllTrim(SOP->OP_CDEPGR),;
                               AllTrim(SOP->OP_CDESGR),;
                               SOP->OP_NRPYGR})
               SOP->(dbSkip())
            EndDo
            //Ordena as empresas pela prioridade
            aSort(aEmpresas,,,{|x,y| x[3] < y[3]})
         EndIf
      EndIf
   EndIf
Return aEmpresas

//-----------------------------------------------------------------
/*/{Protheus.doc} A107AltEmp
Realiza a troca da empresa logada.

@param cEmp            -> Empresa que será logada.
@param cFil            -> Filial que será logada.
@author  Lucas Konrad França
@since      13/11/2014
@version    P12
/*/
//-----------------------------------------------------------------
Function A107AltEmp(cEmp, cFil)
   Static cUser
   Local cGrupo   := ""
   Local lUmGrupo := .F.
   Local nI       := 0

   //Local cHora := TIME()

   //Bkp das variáveis que perdem a referência ao alterar a empresa
   Local cUsrAtu
   Local cFunName
   Local cTypeRpc
   Local oAppBkp
   Local oSearchBkp
   Local cAcessoBkp
   Local cArqTabBkp
   Local cArqRelBkp
   Local cUsuariBkp
   Local cNivelBkp
   Local cInternBkp
   Local cModuloBkp
   Local nModuloBkp
   Local cVersaoBkp
   Local cUsernmBkp
   Local cCredenBkp
   Local __cCredenB
   Local nUsrAcsBkp
   Local nTdataBkp

   If Type("aEmpCent") != "U"
      lUmGrupo := .T.
      cGrupo := aEmpCent[1,1]
      For nI := 1 To Len(aEmpCent)
         If AllTrim(cGrupo) != AllTrim(aEmpCent[nI,1]) .Or. AllTrim(cGrupo) != AllTrim(cEmpAnt)
            lUmGrupo := .F.
         EndIf
      Next nI
   EndIf

   If lUmGrupo
      cFilAnt := AllTrim(cFil)
   EndIf

   If !lUmGrupo .And. !Empty(cEmp) .And. !Empty(cFil)
      cEmp := AllTrim(cEmp)
      cFil := AllTrim(cFil)
      If AllTrim(cEmp) == AllTrim(cEmpAnt)
         cFilAnt := cFil
      Else
         //Salva os valores de BKP
         cUser       := IF(cUser == NIL,RetCodUsr(),cUser)
         cUsrAtu     := cUser
         cTypeRpc    := RPCGetType()
         oAppBkp     := oApp
         If Type("__oSearch") != "U"
            oSearchBkp  := __oSearch
         EndIf
         cAcessoBkp  := cAcesso
         cArqTabBkp  := cArqTab
         cArqRelBkp  := cArqRel
         cUsuariBkp  := cUsuario
         cNivelBkp   := cNivel
         cInternBkp  := __cInternet
         cModuloBkp  := cModulo
         nModuloBkp  := nModulo
         cVersaoBkp  := cVersao
         cUsernmBkp  := cUsername
         If Type("cCredential") != "U"
            cCredenBkp  := cCredential
         EndIf
         If Type("__cCredential") != "U"
            __cCredenB := __cCredential 
         EndIf
         nUsrAcsBkp  := __nUserAcs
         nTdataBkp   := nTdata
         cFunName    := FunName()

         RpcClearEnv()
         DBCloseAll()
         RpcSetType(3)
         RpcSetEnv(cEmp, cFil,,,'PCP',cFunName)

         //Seta os valores de BKP novamente
         oApp        := oAppBkp
         If Type("__oSearch") != "U"
            __oSearch   := oSearchBkp
         EndIf
         cAcesso     := cAcessoBkp
         cArqTab     := cArqTabBkp
         cArqRel     := cArqRelBkp
         cUsuario    := cUsuariBkp
         cNivel      := cNivelBkp
         __cInternet := cInternBkp
         cModulo     := cModuloBkp
         nModulo     := nModuloBkp
         cVersao     := cVersaoBkp
         cUsername   := cUsernmBkp
         If Type("cCredential") != "U"
            cCredential := cCredenBkp
         EndIf
         If Type("__cCredential") != "U"
            __cCredential := __cCredenB  
         EndIf
         __nUserAcs  := nUsrAcsBkp
         nTdata      := nTdataBkp
         cUser       := cUsrAtu
         __cUserId   := cUsrAtu
         SetFunName(cFunName)

         If Type("LMSHELPAUTO") == "L"
            LMSHELPAUTO := .F.
         EndIf

         If Type("LMSFINALAUTO") == "L"
            LMSFINALAUTO := .F.
         EndIf

         RpcSetType(cTypeRpc)
      EndIf
   EndIf
   //Conout("Tempo de execução da a107AltEmp: " + ELAPTIME(cHora,TIME()))

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} A107CLKBRW
Exibe detalhadamente os saldos do produto selecionado.

@author  Lucas Konrad França
@since      02/12/2014
@version    P12
/*/
//-----------------------------------------------------------------
Function A107CLKBRW()
Local cTipo711 := SubStr(oTreeM711:GetCargo(),1,2)
Local cData    := ""
Local cPeriodo := ""
Local cProd    := ""
Local cTitle   := ""
Local cBlock   := ""
Local cOpc     := ""
Local nColPos  := 0
Local nPeriodo := 0
Local nPosTree := 0
Local nI       := 0
Local aDados   := {}
Local aCampos  := {}
Local aSizes   := {}
Local aAreaSOR := SOR->(GetArea())
Local aAreaSOT := SOT->(GetArea())
Local oDlgSld
Local bColor

Private oBrwSldPer

//Possiciona array do tree
nPosTree := AsCan(aDbTree,{|x| x[7]==SubStr(oTreeM711:GetCargo(),3,12)})
cProd    := aDbTree[nPosTree,1]
cOpc     := aDbTree[nPosTree,2]
If cTipo711 != "01"
   //Help( ,, 'PCPA107',, STR0158, 1, 0 ) //"Opção não disponível."
   MsgInfo(STR0158,STR0030)
   SOT->(RestArea(aAreaSOT))
   SOR->(RestArea(aAreaSOR))
   Return .T.
EndIf

nColPos := oBrwDet:ColPos()

If nColPos < 1
   //Help( ,, 'PCPA107',, STR0161, 1, 0 ) //"Selecione a coluna de período.""
   MsgInfo(STR0161,STR0030)
   SOT->(RestArea(aAreaSOT))
   SOR->(RestArea(aAreaSOR))
   Return .T.
EndIf

cData := oBrwDet:aColumns[nColPos]:cheading
nPeriodo := aScan(aPeriodos,{|x| DTOC(x) == cData})

If nPeriodo < 1
   //Help( ,, 'PCPA107',, STR0160, 1, 0 ) //"Erro ao buscar o período selecionado."
   MsgInfo(STR0160,STR0030)
   SOT->(RestArea(aAreaSOT))
   SOR->(RestArea(aAreaSOR))
   Return .T.
EndIf

cPeriodo := StrZero(nPeriodo,3)
cTitle := AllTrim(cProd) + " - " + cData

DEFINE MSDIALOG oDlgSld TITLE cTitle FROM 0,0 TO 350,800 PIXEL

oPanel:= tPanel():Create(oDlgSld,01,01,,,,,,,401,156)
//Cria o array dos campos para o browse
aCampos := {STR0059} //"Tipo"
aSizes  := {80}
cargaEmp(cProd, cPeriodo, @aCampos, @aSizes, cOpc)

aDados := PCPA107MVD(cProd, cPeriodo, cOpc)

If Len(aDados) < 1
   //Help( ,, 'PCPA107',, STR0159, 1, 0 ) //"Não existe saldo no período selecionado."
   MsgInfo(STR0159,STR0030)
   SOT->(RestArea(aAreaSOT))
   SOR->(RestArea(aAreaSOR))
Else
   // Cria Browse
   oBrwSldPer := TCBrowse():New( 0 , 0, 400, 155,,;
                              aCampos,aSizes,;
                              oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   
   oBrwSldPer:nFreeze := 1
   
   // Seta vetor para a browse
   oBrwSldPer:SetArray(aDados)
   cBlock := "{"
   
   For nI := 1 To Len(aCampos)
      If nI > 1
         cBlock += ", "
      EndIf
      cBlock += " aDados[oBrwSldPer:nAt," + Str(nI) + "] "
   Next nI
   
   cBlock += "}"
   
   oBrwSldPer:bLine := {|| &(cBlock)}
   
   oPanel:Refresh()
   oPanel:Show()
   
   @ 160,305 BUTTON STR0164/*"Detalhes transferência"*/ SIZE 065, 011 PIXEL OF oDlgSld ACTION (detalTrans(oBrwSldPer:ColPos(),cProd,cData,cPeriodo))
   DEFINE SBUTTON FROM 160,373 TYPE 1 ACTION (oDlgSld:End()) ENABLE OF oDlgSld
   ACTIVATE DIALOG oDlgSld CENTERED
EndIf

SOT->(RestArea(aAreaSOT))
SOR->(RestArea(aAreaSOR))

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} detalTrans
Exibe detalhadamente as transferências de estoque do produto em um
período

@param nColPos  -> Indica a coluna selecionada
@param cProduto -> Código do produto
@param cData    -> Data do período
@param cPeriodo -> Número do período

@author  Lucas Konrad França
@since   20/05/2015
@version P12
/*/
//-----------------------------------------------------------------
Static Function detalTrans(nColPos, cProduto, cData, cPeriodo)
   Local oDlgDetTr, oEmpFil, oProduto, oDat, oEntr, oSaid
   Local oBrwEntr, oLblEstE, oLblPrdE, oLblTotE
   Local oBrwSaid, oLblEstS, oLblPrdS, oLblTotS
   Local cEmpFil   := oBrwSldPer:aHeaders[nColPos]
   Local aEmpFil   := STRTOKARR(AllTrim(cEmpFil),"/")
   Local cEmp      := aEmpFil[1]
   Local cFil      := aEmpFil[2]
   Local aHeaders  := {}
   Local aColSizes := {}
   Local aEntradas := {}
   Local aSaidas   := {}
   Local nTotEstE  := 0
   Local nTotPrdE  := 0
   Local nTotE     := 0
   Local nTotEstS  := 0
   Local nTotPrdS  := 0
   Local nTotS     := 0
   Local nI        := 0

   aAdd(aHeaders,STR0165) //"Quantidade"
   aAdd(aColSizes,80)
   aAdd(aHeaders,STR0166) //"Tipo"
   aAdd(aColSizes,65)

   DEFINE MSDIALOG oDlgDetTr TITLE STR0164/*"Detalhes transferência"*/ FROM 0,0 TO 415,540 PIXEL

   @ 05,05 Say STR0167 Of oDlgDetTr Pixel //"Empresa/Filial:"
   @ 03,41 MSGET oEmpFil VAR cEmpFil SIZE 40,8 OF oDlgDetTr PIXEL NO BORDER WHEN .F.

   @ 05,85 Say STR0039+":" Of oDlgDetTr Pixel //"Produto:"
   @ 03,108 MSGET oProduto VAR cProduto SIZE 80,8 OF oDlgDetTr PIXEL NO BORDER WHEN .F.

   @ 05,192 Say STR0077+":" Of oDlgDetTr Pixel //"Data:"
   @ 03,208 MSGET oDat VAR cData SIZE 60,8 OF oDlgDetTr PIXEL NO BORDER WHEN .F.

   //Grid entradas
   oEntr:= tGroup():New(13,05,100,267,STR0063,oDlgDetTr,,,.T.) //'Entradas'

   aEntradas := verDetTran(cProduto, cPeriodo, cEmp, cFil, 'E')

   If Len(aEntradas) < 1
      aAdd(aEntradas,{0,''})
   Else
      For nI := 1 To Len(aEntradas)
         If aEntradas[nI,2] == STR0168 //Estoque
            nTotEstE += aEntradas[nI,1]
         Else
            nTotPrdE += aEntradas[nI,1]
         EndIf
      Next nI
      nTotE := nTotEstE + nTotPrdE
   EndIf

   oBrwEntr := TCBrowse():New(20,07,190,76,/*bLine*/,aHeaders,aColSizes,oEntr,,,,/*bChange*/{|| },,,,,,,,,,.T.,,,,.T.,.T. )

   oBrwEntr:SetArray(aEntradas)
   oBrwEntr:bLine := {||{ aEntradas[oBrwEntr:nAT,1],;
                          aEntradas[oBrwEntr:nAt,2]}}

   oLblEstE := TSay():New(20,200,{||STR0170+cValToChar(nTotEstE)},oEntr,,,,,,.T.,,,200,20) //'Total estoque: '
   oLblPrdE := TSay():New(30,200,{||STR0171+cValToChar(nTotPrdE)},oEntr,,,,,,.T.,,,200,20) //'Total produção: '
   oLblTotE := TSay():New(40,200,{||STR0172+cValToChar(nTotE)},oEntr,,,,,,.T.,,,200,20)  //'Total geral: '

   //Grid saidas
   oSaid:= tGroup():New(102,05,190,267,STR0064/*'Saidas'*/,oDlgDetTr,,,.T.)
   aSaidas := verDetTran(cProduto, cPeriodo, cEmp, cFil, 'S')
   If Len(aSaidas) < 1
      aAdd(aSaidas,{0,''})
   Else
      For nI := 1 To Len(aSaidas)
         If aSaidas[nI,2] == STR0168 //Estoque
            nTotEstS += aSaidas[nI,1]
         Else
            nTotPrdS += aSaidas[nI,1]
         EndIf
      Next nI
      nTotS := nTotEstS + nTotPrdS
   EndIf

   oBrwSaid := TCBrowse():New(109,07,190,76,/*bLine*/,aHeaders,aColSizes,oSaid,,,,/*bChange*/{|| },,,,,,,,,,.T.,,,,.T.,.T. )

   oBrwSaid:SetArray(aSaidas)
   oBrwSaid:bLine := {||{ aSaidas[oBrwSaid:nAT,1],;
                          aSaidas[oBrwSaid:nAt,2]}}

   oLblEstS := TSay():New(109,200,{||STR0170+cValToChar(nTotEstS)},oSaid,,,,,,.T.,,,200,20) //'Total estoque: '
   oLblPrdS := TSay():New(119,200,{||STR0171+cValToChar(nTotPrdS)},oSaid,,,,,,.T.,,,200,20) //'Total produção: '
   oLblTotS := TSay():New(129,200,{||STR0172+cValToChar(nTotS)},oSaid,,,,,,.T.,,,200,20)    //'Total geral: '

   DEFINE SBUTTON FROM 193,241 TYPE 1 ACTION (oDlgDetTr:End()) ENABLE OF oDlgDetTr
   ACTIVATE DIALOG oDlgDetTr CENTERED
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} verDetTran
Busca as informações detalhadas da transferência

@param cProduto -> Código do produto
@param cPeriodo -> Número do período
@param cEmp     -> Empresa
@param cFil     -> Filial
@param cTipo    -> 'E': Entradas, 'S': Saidas

@author  Lucas Konrad França
@since   20/05/2015
@version P12
/*/
//-----------------------------------------------------------------
Static Function verDetTran(cProduto, cPeriodo, cEmp, cFil, cTipo)
   Local cQuery   := ""
   Local cAlias   := GetNextAlias()
   Local aDados   := {}
   Local cDesTipo := ""
   cQuery := " SELECT SOS.OS_QUANT, "
   cQuery +=        " SOS.OS_TIPO "
   cQuery +=   " FROM " + RetSqlName("SOR") + " SOR, "
   cQuery +=              RetSqlName("SOT") + " SOT, "
   cQuery +=              RetSqlName("SOS") + " SOS "
   cQuery +=  " WHERE SOT.OT_FILIAL  = '" + xFilial("SOT") + "' "
   cQuery +=    " AND SOR.OR_FILIAL  = '" + xFilial("SOR") + "' "
   cQuery +=    " AND SOS.OS_FILIAL  = '" + xFilial("SOS") + "' "
   cQuery +=    " AND SOR.R_E_C_N_O_ = SOT.OT_RGSOR "
   cQuery +=    " AND SOR.OR_PROD    = '" + cProduto + "' "
   cQuery +=    " AND SOT.OT_PERMRP  = '" + cPeriodo + "' "
   cQuery +=    " AND SOR.OR_EMP     = '" + cEmp + "' "
   cQuery +=    " AND SOR.OR_FILEMP  = '" + cFil + "' "
   If cTipo = 'E'
      cQuery += " AND SOS.OS_SOTDEST = SOT.R_E_C_N_O_ "
   Else
      cQuery += " AND SOS.OS_SOTORIG = SOT.R_E_C_N_O_ "
   EndIf
   cQuery += " ORDER BY 2"

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   dbSelectArea(cAlias)
   While !Eof()
      If (cAlias)->(OS_TIPO) == '1'
         cDesTipo := STR0168//"Estoque"
      Else
         cDesTipo := STR0169//"Produção"
      EndIf
      aAdd(aDados,{(cAlias)->(OS_QUANT),;
                   cDesTipo})
      (cAlias)->(dbSkip())
   End
Return aDados

//-----------------------------------------------------------------
/*/{Protheus.doc} A107DETSAL
Exibe detalhadamente os saldos do produto selecionado em todos os períodos.

@author  Lucas Konrad França
@since      04/12/2014
@version    P12
/*/
//-----------------------------------------------------------------
Function A107DETSAL()
Local cTipo711 := SubStr(oTreeM711:GetCargo(),1,2)
Local cProd    := ""
Local cTitle   := ""
Local cTexto   := ""
Local cBlock   := ""
Local cOpc     := ""
Local nPosTree := 0
Local nI       := 0
Local aDados   := {}
Local aCampos  := {}
Local aEmp     := {}
Local aSizes   := {}
Local aAreaSOR := SOR->(GetArea())
Local aAreaSOT := SOT->(GetArea())
Local oDlgSld, oBrwSld, oScrollPnl, oPanelAux, oSay, oFont

//Possiciona array do tree
nPosTree := AsCan(aDbTree,{|x| x[7]==SubStr(oTreeM711:GetCargo(),3,12)})
cProd    := aDbTree[nPosTree,1]
cOpc     := aDbTree[nPosTree,2]

If cTipo711 != "01"
   //Help( ,, 'PCPA107',, STR0158, 1, 0 ) //"Opção não disponível."
   MsgInfo(STR0158,STR0030)
   SOR->(RestArea(aAreaSOR))
   SOT->(RestArea(aAreaSOT))
   Return .T.
EndIf

cTitle := AllTrim(cProd)

//Busca as informações a serem exibidas
aDados := buscaDet(cProd,@aEmp,cOpc)

//Cria o array dos campos para o browse
aAdd(aCampos,STR0059) //"Tipo"
aAdd(aSizes,80)

For nI := 1 To Len(aPeriodos)
   aAdd(aCampos,DToC(aPeriodos[nI]))
   aAdd(aSizes,50)
Next nI

DEFINE DIALOG oDlgSld TITLE cTitle FROM 0,0 TO 350,800 PIXEL

oScrollPnl := TScrollBox():New(oDlgSld,01,01,156,401,.T.,.F.,.T.)

oFont := TFont():New('Helvetica',,14,.T.,.T.)

oPanelAux := tPanel():Create(oScrollPnl,00,00,,,,,,RGB(91, 101, 107),80,14)
oSay:= TSay():Create(oPanelAux,{||STR0149},01,01,,oFont,,,,,,,200,20)
oSay:SetCSS( "TSay{ color: #FFFFFF; }" )

nRow := 15
oFont := TFont():New('Helvetica',,30,.T.,.T.)
For nI := 1 To Len(aEmp)
   oPanelAux := tPanel():Create(oScrollPnl,nRow,00,,,,,,RGB(91, 101, 107),80,58.5)
   cTexto := aEmp[nI][1] + "/" + aEmp[nI][2]
   cBlock := "TSay():Create(oPanelAux,{|| '"+cTexto+"' },20,01,,oFont,,,,,,,200,20)"
   oSay := &(cBlock)
   oSay:SetCSS( "TSay{ color: #FFFFFF; }" )
   nRow += 59.5
Next nI
nRow += 10
// Cria Browse
oBrwSld := TCBrowse():New( 0 , 80, 311, nRow,,;
                           aCampos,aSizes,;
                           oScrollPnl,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.F.,.F. )

oBrwSld:nFreeze := 1

// Seta vetor para a browse
oBrwSld:SetArray(aDados)
cBlock := "{"

For nI := 1 To Len(aCampos)
   If nI > 1
      cBlock += ", "
   EndIf
   cBlock += " aDados[oBrwSld:nAt," + Str(nI) + "] "
Next nI

cBlock += "}"

oBrwSld:bLine := {|| &(cBlock)}
oBrwSld:GoBottom()
oBrwSld:GoTop()
oScrollPnl:Refresh()
oScrollPnl:Show()

DEFINE SBUTTON FROM 160,373 TYPE 1 ACTION (oDlgSld:End()) ENABLE OF oDlgSld
ACTIVATE DIALOG oDlgSld CENTERED

SOR->(RestArea(aAreaSOR))
SOT->(RestArea(aAreaSOT))

Return .T.

/*-------------------------------------------------------------------------/
//Programa: buscaDet
//Autor:    Lucas Konrad França
//Data:     05/12/2014
//Descricao:   Busca o saldo detalhado do produto em todos os periodos
//Parametros:  cProd - Produto
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function buscaDet(cProd, aEmp, cOpc)
Local cQuery      := ""
Local cEmpresa    := ""
Local cFil        := ""
Local cAlias      := GetNextAlias()
Local nI          := 0
Local nX          := 0
Local nAux        := 0
Local nPos        := 0
Local aDados      := {}
Local aSaldos     := {}
Local aStrings    := {STR0110,STR0063,STR0064,STR0111,STR0112,STR0113,STR0157}
Local aAux        := {}

cQuery := " SELECT SOR.OR_EMP, "
cQuery +=        " SOR.OR_FILEMP, "
cQuery +=        " SOT.OT_QTSLES, "
cQuery +=        " SOT.OT_QTENTR, "
cQuery +=        " SOT.OT_QTSAID, "
cQuery +=        " SOT.OT_QTSEST, "
cQuery +=        " SOT.OT_QTSALD, "
cQuery +=        " SOT.OT_QTNECE, "
cQuery +=        " SOT.OT_QTTRAN, "
cQuery +=        " SOT.OT_PERMRP, "
cQuery +=        " SOR.R_E_C_N_O_ RECSOR "
cQuery +=   " FROM " + RetSqlName("SOR") + " SOR, "
cQuery +=              RetSqlName("SOT") + " SOT "
cQuery +=  " WHERE SOT.OT_FILIAL  = '" + xFilial("SOT") + "' "
cQuery +=    " AND SOR.OR_FILIAL  = '" + xFilial("SOR") + "' "
cQuery +=    " AND SOR.R_E_C_N_O_ = SOT.OT_RGSOR "
cQuery +=    " AND SOR.OR_PROD    = '" + cProd + "' "
cQuery +=  " ORDER BY SOR.OR_EMP, SOR.OR_FILEMP, SOT.OT_PERMRP "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
dbSelectArea(cAlias)

While !(cAlias)->(Eof())
   SOR->(dbGoTo((cAlias)->(RECSOR)))
   If AllTrim(cOpc) == AllTrim(SOR->OR_OPC)
      IF AllTrim((cAlias)->(OR_EMP)) # AllTrim(cEmpresa) .Or. AllTrim((cAlias)->(OR_FILEMP)) # AllTrim(cFil)
         cEmpresa := (cAlias)->(OR_EMP)
         cFil     := (cAlias)->(OR_FILEMP)
      
         aAdd(aEmp,{cEmpresa,cFil})
      EndIf
      aAdd(aSaldos,{(cAlias)->(OT_QTSLES),;
                    (cAlias)->(OT_QTENTR),;
                    (cAlias)->(OT_QTSAID),;
                    (cAlias)->(OT_QTSEST),;
                    (cAlias)->(OT_QTSALD),;
                    (cAlias)->(OT_QTNECE),;
                    (cAlias)->(OT_QTTRAN),;
                    (cAlias)->(OT_PERMRP),;
                    (cAlias)->(OR_EMP),;
                    (cAlias)->(OR_FILEMP)})
   EndIf
   (cAlias)->(dbSkip())
End

If Len(aSaldos) > 0
   For nI := 1 To Len(aEmp)
      For nX := 1 To 7
         aAux := {}
         aAdd(aAux,aStrings[nX])
         For nAux := 1 To Len(aPeriodos)
            nPos := aScan(aSaldos,{|x| x[9] == aEmp[nI,1] .And. x[10] == aEmp[nI,2] .And. x[8] == StrZero(nAux,3) })
            If nPos > 0
               aAdd(aAux,aSaldos[nPos,nX])
            Else
               aAdd(aAux,0)
            EndIf
         Next nAux
         If Len(aAux) > 0
            aAdd(aDados,aAux)
         EndIf
      Next nX
   Next nI
EndIf

Return aDados

/*-------------------------------------------------------------------------/
//Programa: cargaEmp
//Autor:    Lucas Konrad França
//Data:     03/12/2014
//Descricao:   Carrega as empresas que possuem saldo do produto
//Parametros:  aCampos - Array de campos (por referência)
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function cargaEmp(cProd, cPeriodo, aCampos, aSizes, cOpc)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local aTamQuant   := TamSX3("OT_QTSALD")

cQuery := " SELECT SOR.R_E_C_N_O_ RECSOR "
cQuery +=   " FROM " + RetSqlName("SOR") + " SOR, "
cQuery +=              RetSqlName("SOT") + " SOT "
cQuery +=  " WHERE SOT.OT_FILIAL  = '" + xFilial("SOT") + "' "
cQuery +=    " AND SOR.OR_FILIAL  = '" + xFilial("SOR") + "' "
cQuery +=    " AND SOR.R_E_C_N_O_ = SOT.OT_RGSOR "
cQuery +=    " AND SOR.OR_PROD    = '" + cProd + "' "
cQuery +=    " AND SOT.OT_PERMRP  = '" + cPeriodo + "' "
cQuery +=    " AND (SOT.OT_QTSLES <> 0 "
cQuery +=     " OR  SOT.OT_QTENTR <> 0 "
cQuery +=     " OR  SOT.OT_QTSAID <> 0 "
cQuery +=     " OR  SOT.OT_QTSEST <> 0 "
cQuery +=     " OR  SOT.OT_QTSALD <> 0 "
cQuery +=     " OR  SOT.OT_QTNECE <> 0 "
cQuery +=     " OR  SOT.OT_QTTRAN <> 0) "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
While !(cAlias)->(Eof())
   SOR->(dbGoTo((cAlias)->(RECSOR)))
   If AllTrim(cOpc) == AllTrim(SOR->OR_OPC)
      If aScan(aCampos,{|x| x == SOR->OR_EMP+"/"+SOR->OR_FILEMP}) < 1
         aAdd(aCampos,SOR->OR_EMP+"/"+SOR->OR_FILEMP)
         aAdd(aSizes,60)
      EndIf
   EndIf
   (cAlias)->(dbSkip())
End
aSort(aCampos,2)
/*
cQuery := " SELECT DISTINCT SOR.OR_EMP, "
cQuery +=        " SOR.OR_FILEMP "
cQuery +=   " FROM " + RetSqlName("SOR") + " SOR, "
cQuery +=              RetSqlName("SOT") + " SOT "
cQuery +=  " WHERE SOT.OT_FILIAL  = '" + xFilial("SOT") + "' "
cQuery +=    " AND SOR.OR_FILIAL  = '" + xFilial("SOR") + "' "
cQuery +=    " AND SOR.R_E_C_N_O_ = SOT.OT_RGSOR "
cQuery +=    " AND SOR.OR_PROD    = '" + cProd + "' "
cQuery +=    " AND SOT.OT_PERMRP  = '" + cPeriodo + "' "
cQuery +=    " AND (SOT.OT_QTSLES <> 0 "
cQuery +=     " OR  SOT.OT_QTENTR <> 0 "
cQuery +=     " OR  SOT.OT_QTSAID <> 0 "
cQuery +=     " OR  SOT.OT_QTSEST <> 0 "
cQuery +=     " OR  SOT.OT_QTSALD <> 0 "
cQuery +=     " OR  SOT.OT_QTNECE <> 0 "
cQuery +=     " OR  SOT.OT_QTTRAN <> 0) "
cQuery +=  " ORDER BY SOR.OR_EMP, SOR.OR_FILEMP "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
While !(cAlias)->(Eof())
   aAdd(aCampos,(cAlias)->(OR_EMP)+"/"+(cAlias)->(OR_FILEMP))
   aAdd(aSizes,60)
   (cAlias)->(dbSkip())
End
*/
Return

/*-------------------------------------------------------------------------/
//Programa: PCPA107MVD
//Autor:    Lucas Konrad França
//Data:     03/12/2014
//Descricao:   Monta o arquivo temporário da SOR e SOT para mostrar em tela
//Parametros:  aCampos - Array de campos (por referência)
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function PCPA107MVD(cProd, cPeriodo, cOpc)
Local cQuery      := ""
Local cAlias      := GetNextAlias()
Local nI          := 0
Local nX          := 0
Local aDados      := {}
Local aSaldos     := {}
Local aStrings    := {STR0110,STR0063,STR0064,STR0111,STR0112,STR0113,STR0157}
Local aAux        := {}

cQuery := " SELECT SOR.OR_EMP, "
cQuery +=        " SOR.OR_FILEMP, "
cQuery +=        " SOT.OT_QTSLES, "
cQuery +=        " SOT.OT_QTENTR, "
cQuery +=        " SOT.OT_QTSAID, "
cQuery +=        " SOT.OT_QTSEST, "
cQuery +=        " SOT.OT_QTSALD, "
cQuery +=        " SOT.OT_QTNECE, "
cQuery +=        " SOT.OT_QTTRAN, "
cQuery +=        " SOR.R_E_C_N_O_ RECSOR "
cQuery +=   " FROM " + RetSqlName("SOR") + " SOR, "
cQuery +=              RetSqlName("SOT") + " SOT "
cQuery +=  " WHERE SOT.OT_FILIAL  = '" + xFilial("SOT") + "' "
cQuery +=    " AND SOR.OR_FILIAL  = '" + xFilial("SOR") + "' "
cQuery +=    " AND SOR.R_E_C_N_O_ = SOT.OT_RGSOR "
cQuery +=    " AND SOR.OR_PROD    = '" + cProd + "' "
cQuery +=    " AND SOT.OT_PERMRP  = '" + cPeriodo + "' "
cQuery +=    " AND (SOT.OT_QTSLES <> 0 "
cQuery +=     " OR  SOT.OT_QTENTR <> 0 "
cQuery +=     " OR  SOT.OT_QTSAID <> 0 "
cQuery +=     " OR  SOT.OT_QTSEST <> 0 "
cQuery +=     " OR  SOT.OT_QTSALD <> 0 "
cQuery +=     " OR  SOT.OT_QTNECE <> 0 "
cQuery +=     " OR  SOT.OT_QTTRAN <> 0) "
cQuery +=  " ORDER BY SOR.OR_EMP, SOR.OR_FILEMP "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
dbSelectArea(cAlias)

While !(cAlias)->(Eof())
   SOR->(dbGoTo((cAlias)->(RECSOR)))
   If AllTrim(SOR->OR_OPC) == AllTrim(cOpc)
      aAdd(aSaldos,(cAlias)->(OT_QTSLES))
      aAdd(aSaldos,(cAlias)->(OT_QTENTR))
      aAdd(aSaldos,(cAlias)->(OT_QTSAID))
      aAdd(aSaldos,(cAlias)->(OT_QTSEST))
      aAdd(aSaldos,(cAlias)->(OT_QTSALD))
      aAdd(aSaldos,(cAlias)->(OT_QTNECE))
      aAdd(aSaldos,(cAlias)->(OT_QTTRAN))
   EndIf
   (cAlias)->(dbSkip())
End

If Len(aSaldos) > 0
   aAux := 1
   For nI := 1 To 7
      aAux := {}
      aAux := {aStrings[nI]}
      For nX := nI To Len(aSaldos) Step 7
         aAdd(aAux,aSaldos[nX])
      Next nX
      aAdd(aDados,aAux)
   Next nI
EndIf
Return aDados

/*-------------------------------------------------------------------------/
//Programa: A107Proc
//Autor:    Lucas Konrad França
//Data:     17/12/2014
//Descricao:   Cria a barra de progresso e executa a função PCPA107INP
//Parametros:  cTipo  - Identifica a função que será executada.
                        1 - PCPA107INP
                        2 - A107OPSC
               aDados - Array com os dados a serem passados por parâmetro para as funções.
               lSemTela - Identifica que é execução sem tela.
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107Proc(cTipo, aDados, lSemTela)
Local oDlgMet, oSayMtr

Default lSemTela := .F.

Private nMeter := 0
Private oMeter

If lSemTela
   If cTipo == "1"
      PCPA107INP(aDados[1],aDados[2],aDados[3],aDados[4])
   Else
      A107OPSC(aDados[1],aDados[2],aDados[3],aDados[4],aDados[5])
   EndIf
Else
   DEFINE MSDIALOG oDlgMet FROM 0,0 TO 5,60 TITLE STR0199 //"Processando" 

      oSayMtr := tSay():New(10,10,{||STR0200 },oDlgMet,,,,,,.T.,,,220,20) //"Processando, aguarde..."
      oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlgMet,220,10,,.T.) // cria a régua

   ACTIVATE MSDIALOG oDlgMet CENTERED ON INIT(iif(cTipo=="1",PCPA107INP(aDados[1],aDados[2],aDados[3],aDados[4]),;
                                                            A107OPSC(aDados[1],aDados[2],aDados[3],aDados[4],aDados[5])),oDlgMet:End())
EndIf
Return

/*-------------------------------------------------------------------------/
//Programa: A107ProInc
//Autor:    Lucas Konrad França
//Data:     17/12/2014
//Descricao:   Incrementa um elemento na barra de progresso
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107ProInc()

   If Type("oMeter") != "U"
      nMeter++
      oMeter:Set(nMeter)
      oMeter:Refresh()
      SysRefresh()
   EndIf

Return

/*-------------------------------------------------------------------------/
//Programa: A107ProTot
//Autor:    Lucas Konrad França
//Data:     17/12/2014
//Descricao:   Seta o total da barra de progresso
//Parametros:  nTotal - Total para ser setado na barra de progresso
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107ProTot(nTotal)
   If Type("oMeter") != "U"
      oMeter:SetTotal(nTotal)
      SysRefresh()
   EndIf
Return

/*-------------------------------------------------------------------------/
//Programa: atuSosBkp
//Autor:    Lucas Konrad França
//Data:     22/05/2015
//Descricao:   Atualiza a tabela bkp da SOS
//Parametros:  nRecBkp - Recno da tabela SOSBKP
//             nQuant  - Quantidade a ser diminuida
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function atuSosBkp(nRecBkp,nQuant)
   Local cSql   := ""

   cSql := " UPDATE SOSBKP "
   cSql +=    " SET QUANT = QUANT - " + cValToChar(nQuant)
   cSql +=  " WHERE R_E_C_N_O_ = " + cValToChar(nRecBkp)

   TCSQLExec(cSql)
Return

/*---------------------------------------------------------------------------------------------------------/
//Programa: A107CriSOU
//Autor:    Lucas Konrad França
//Data:     07/01/2015
//Descricao:   Cria a tabela SOU - Sugestão de transferência
//Parametros:  cScOp    - Indica se está gerando uma 'OP' ou uma 'SC'
//             nRecno   - RECNO (SOT ou SOQ) que está gerando a OP/SC. Quando for PMP, será o RECNO da SOQ.
//             lPmp     - Indica se está gerando através do PMP.
//             nDoc     - Indica o número da OP ou da SC.
//             nSeq     - Indica a sequência da ordem de produção.
//             cItem    - Indica o item da OP/SC
//             cItemGrd - Indica o item grade da OP/SC
//             nQuant   - Indica a quantidade da produção/compra.
//             cPeriodo - Periodo do MRP.
//             dData    - Data da OP/SC
//             cProduto - Código do produto
//Uso:      PCPA107
//--------------------------------------------------------------------------------------------------------*/
Function A107CriSOU(cScOp,nRecno, lPmp, nDoc, nSeq, cItem, cItemGrd, nQuant, cPeriodo, dData, cProduto)
   Local aArea      := GetArea()
   Local nQtEst     := 0
   Local nQtProd    := 0
   Local nQtTotal   := 0
   Local nQtOp      := nQuant
   Local nPos       := 0
   Local nPosSos    := 0
   Local nOp        := 0
   Local nQtSkip    := 0
   Local nNumSc     := 0
   Local nI         := 0
   Local nQtTot     := 0
   Local nQtOrigem  := 0
   Local nQtDestino := 0
   Local nRecSOS    := 0
   Local cItemOp    := ""
   Local cItemSc    := ""
   Local cItGrdOp   := ""
   Local cItGrdSc   := ""
   Local cEmpDest   := ""
   Local cFilDest   := ""
   Local cEmpOrig   := ""
   Local cFilOrig   := ""
   Local cQuery     := ""
   Local cAlias     := "CRIASOU"
   Local cAliasBKP  := "SOSBKP"
   Local cAliasAux  := "SOSAUX"
   Local lGerou     := .F.
   Local lAdd       := .F.
   Local lOrigem    := .T.
   Local lContinua  := .T.
   Default nSeq     := ""

   //Cria a tabela SOU
   If lGeraTrans == "2" .Or. lGeraTrans == "3"
      If lPmp
         //Se está gerando a partir do plano mestre, posiciona no registro da SOT correspondente,
         //pois o Recno recebido é o da tabela SOQ
         SOQ->(dbGoTo(nRecno))
         nRecno := 0
         dbSelectArea("SOR")
         SOR->(dbSetOrder(1))
         If SOR->(dbSeek(xFilial("SOR")+SOQ->OQ_EMP+SOQ->OQ_FILEMP+SOQ->OQ_PROD+SOQ->OQ_NRRV))
            dbSelectArea("SOT")
            SOT->(dbSetOrder(1))
            If SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+cPeriodo))
               nRecno := SOT->(Recno())
            EndIf
         EndIf
      EndIf

      If cScOp == "SC"
         cQuery := " SELECT SOSBKP.SOTDEST, "
         cQuery +=        " SOSBKP.SOTORIG, "
         cQuery +=        " SOSBKP.QUANT, "
         cQuery +=        " SOSBKP.R_E_C_N_O_ SOSREC "
         cQuery +=   " FROM SOSBKP , "
         cQuery +=          RetSqlName("SOT") + " SOT "
         cQuery +=  " WHERE SOSBKP.QUANT   > 0 "
         cQuery +=    " AND SOSBKP.TIPO    = '1' "
         cQuery +=    " AND SOSBKP.SOTDEST = SOT.R_E_C_N_O_ "
         cQuery +=    " AND SOT.R_E_C_N_O_  = " + Str(nRecno)

         cQuery := ChangeQuery(cQuery)

         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
         dbSelectArea(cAlias)

         If !(cAlias)->(Eof())
            If aScan(aTransEst,{|x| x[1] == (cAlias)->(SOSREC)}) < 1 .And. nQuant <= (cAlias)->(QUANT)
               //Busca a empresa/filial destino
               SOT->(dbGoTo((cAlias)->(SOTDEST)))
               SOR->(dbGoTo(SOT->OT_RGSOR))
               cEmpDest := SOR->OR_EMP
               cFilDest := SOR->OR_FILEMP

               //Busca a empresa/filial origem
               SOT->(dbGoTo((cAlias)->(SOTORIG)))
               SOR->(dbGoTo(SOT->OT_RGSOR))
               cEmpOrig := SOR->OR_EMP
               cFilOrig := SOR->OR_FILEMP

               If (cAlias)->(QUANT) >= nQuant
                  nQtEst := nQuant
               Else
                  nQtEst := (cAlias)->(QUANT)
               EndIf
               //Gera a SOU somente como saldo de estoque.
               RecLock("SOU",.T.)
                  SOU->OU_FILIAL  := xFilial("SOU")
                  SOU->OU_EMPORIG := cEmpOrig
                  SOU->OU_FILORIG := cFilOrig
                  SOU->OU_EMPDEST := cEmpDest
                  SOU->OU_FILDEST := cFilDest
                  SOU->OU_PROD    := cProduto
                  SOU->OU_NRMRP   := c711NumMRP
                  SOU->OU_OPPROD  := ""
                  SOU->OU_SCSOLIC := nDoc
                  SOU->OU_ITEMOP  := ""
                  SOU->OU_ITEMSC  := cItem
                  SOU->OU_ITGRDOP := ""
                  SOU->OU_ITGRDSC := cItemGrd
                  SOU->OU_C2SEQ   := ""
                  SOU->OU_DTTRANS := dData
                  SOU->OU_QTPROD  := 0
                  SOU->OU_QTEST   := nQtEst
                  SOU->OU_SITUACA := '1'
                  SOU->OU_QTMOVTO := 0
               MsUnlock()
               aAdd(aTransEst,{(cAlias)->(SOSREC),(cAlias)->(QUANT)})
               lGerou := .T.
               atuSosBkp((cAlias)->(SOSREC),nQtEst)
            EndIf
         EndIf
         (cAlias)->(dbCloseArea())
         If !lGerou
            cQuery := " SELECT SOTORIG "
            cQuery +=   " FROM SOSBKP "
            cQuery +=  " WHERE FILIAL  = '" + xFilial("SOS") + "' "
            cQuery +=    " AND SOTDEST = " + cValToChar(nRecno)
            cQuery +=    " AND TIPO    = '2' "
            cQuery := ChangeQuery(cQuery)
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBKP,.T.,.T.)
            dbSelectArea(cAliasBKP)
            If !(cAliasBKP)->(Eof())
               //Se achar, é porque já gerou a OP desta SC, somente recupera o número da OP para atualizar a tabela SOU.
               nPos := 1
               While nQuant > 0 .And. nPos > 0
                  nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == (cAliasBKP)->(SOTORIG) .And. x[Iif(x[2]=="OP",9,8)] == nQuant })
                  If nPos < 1
                     nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == (cAliasBKP)->(SOTORIG) })
                  EndIf
                  If nPos > 0 .And. aRecScOp[nPos,3] > 0 .And. nQuant > 0
                     If aRecScOp[nPos,2]=='OP'
                        nRecSou := aRecScOp[nPos,3]
                        SOU->(dbGoTo(nRecSou))
                        If Empty(SOU->OU_SCSOLIC)
                           RecLock("SOU",.F.)
                              SOU->OU_SCSOLIC := nDoc
                              SOU->OU_ITEMSC  := cItem
                              SOU->OU_ITGRDSC := cItemGrd
                              //Sempre usa menor quantidade na SOU.
                              If SOU->OU_QTPROD > nQuant
                                 SOU->OU_QTPROD := nQuant
                              EndIf
                           MsUnLock()
                        Else

                           //Busca a empresa/filial origem
                           SOT->(dbGoTo((cAliasBKP)->(SOTORIG)))
                           SOR->(dbGoTo(SOT->OT_RGSOR))
                           cEmpOrig := SOR->OR_EMP
                           cFilOrig := SOR->OR_FILEMP

                           //Busca a empresa/filial destino
                           SOT->(dbGoTo(nRecno))
                           SOR->(dbGoTo(SOT->OT_RGSOR))
                           cEmpDest := SOR->OR_EMP
                           cFilDest := SOR->OR_FILEMP

                           nNumSc   := nDoc
                           cItemSc  := cItem
                           cItGrdSc := cItemGrd
                           nOp      := SOU->OU_OPPROD
                           cItemOp  := SOU->OU_ITEMOP
                           cItGrdOp := SOU->OU_ITGRDOP
                           nSeq     := SOU->OU_C2SEQ
                           //cEmpOrig := SOU->OU_EMPORIG
                           //cFilOrig := SOU->OU_FILORIG
                           //cEmpDest := SOU->OU_EMPDEST
                           //cFilDest := SOU->OU_FILDEST
                           dData    := SOU->OU_DTTRANS

                           RecLock("SOU",.T.)
                              SOU->OU_FILIAL  := xFilial("SOU")
                              SOU->OU_EMPORIG := cEmpOrig
                              SOU->OU_FILORIG := cFilOrig
                              SOU->OU_EMPDEST := cEmpDest
                              SOU->OU_FILDEST := cFilDest
                              SOU->OU_PROD    := cProduto
                              SOU->OU_NRMRP   := c711NumMRP
                              SOU->OU_OPPROD  := nOp
                              SOU->OU_SCSOLIC := nNumSc
                              SOU->OU_ITEMOP  := cItemOp
                              SOU->OU_ITEMSC  := cItemSc
                              SOU->OU_ITGRDOP := cItGrdOp
                              SOU->OU_ITGRDSC := cItGrdSc
                              SOU->OU_C2SEQ   := nSeq
                              SOU->OU_DTTRANS := dData
                              SOU->OU_QTPROD  := nQuant
                              SOU->OU_QTEST   := 0
                              SOU->OU_SITUACA := '1'
                              SOU->OU_QTMOVTO := 0
                           MsUnlock()
                        EndIf
                        lGerou := .T.
                        aRecScOp[nPos,9] -= nQuant
                        If aRecScOp[nPos,9] <= 0
                           aDel(aRecScOp,nPos)
                           aSize(aRecScOp,Len(aRecScOp)-1)
                        EndIf
                     Else
                        lOrigem := verOrigem(nRecno)
                        nRecSou := aRecScOp[nPos,3]
                        SOU->(dbGoTo(nRecSou))
                        If lOrigem
                           nNumSc   := SOU->(OU_SCSOLIC)
                           cItemSc  := SOU->(OU_ITEMSC)
                           cItGrdSc := SOU->(OU_ITGRDSC)
                           nOp      := nDoc
                           cItemOp  := cItem
                           cItGrdOp := cItemGrd
                        Else
                           nNumSc   := nDoc
                           cItemSc  := cItem
                           cItGrdSc := cItemGrd
                           nOp      := SOU->(OU_SCSOLIC)
                           cItemOp  := SOU->(OU_ITEMSC)
                           cItGrdOp := SOU->(OU_ITGRDSC)
                        EndIf

                        RecLock("SOU",.F.)
                           SOU->OU_OPPROD  := nOp
                           SOU->OU_ITEMOP  := cItemOp
                           SOU->OU_ITGRDOP := cItGrdOp
                           SOU->OU_SCSOLIC := nNumSc
                           SOU->OU_ITEMSC  := cItemSc
                           SOU->OU_ITGRDSC := cItGrdSc
                           SOU->OU_C2SEQ   := 'SC'
                        MsUnLock()

                        lGerou := .T.
                        aDel(aRecScOp,nPos)
                        aSize(aRecScOp,Len(aRecScOp)-1)
                     EndIf
                     nQuant -= SOU->OU_QTPROD
                  Else
                     If nQuant > 0
                        lAdd := .T.
                        aAdd(aRecScOp,{nRecno,cScOp,0,nDoc,cItem,cItemGrd,.F.,nQuant})
                        nPos := 0
                     EndIf
                  EndIf
               End
            EndIf
         EndIf
      Else
         If !lGerou
            cQuery := " SELECT SOTDEST "
            cQuery +=   " FROM SOSBKP "
            cQuery +=  " WHERE FILIAL  = '" + xFilial("SOS") + "' "
            cQuery +=    " AND SOTORIG = " + cValToChar(nRecno)
            cQuery +=    " AND TIPO    = '2' "
            cQuery := ChangeQuery(cQuery)
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBKP,.T.,.T.)
            dbSelectArea(cAliasBKP)
            If !(cAliasBKP)->(Eof())
               //Se achar, é porque já gerou a SC desta OP, somente recupera o número da OP para atualizar a tabela SOU.
               nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == (cAliasBKP)->(SOTDEST) .And. x[2] == "SC" .And. x[Iif(x[2]=="OP",9,8)] == nQuant})
               If nPos < 1
                  nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == (cAliasBKP)->(SOTDEST) .And. x[2] == "SC" })
               EndIf
               If nPos > 0 .And. aRecScOp[nPos,3] > 0
                  nRecSou := aRecScOp[nPos,3]
                  SOU->(dbGoTo(nRecSou))
                  If Empty(SOU->OU_OPPROD)
                     RecLock("SOU",.F.)
                        SOU->OU_OPPROD  := nDoc
                        SOU->OU_C2SEQ   := nSeq
                        SOU->OU_ITEMOP  := cItem
                        SOU->OU_ITGRDOP := cItemGrd
                        If SOU->OU_QTPROD > nQuant
                           SOU->OU_QTPROD := nQuant
                        EndIf
                     MsUnLock()
                  Else
                     nNumSc   := SOU->OU_SCSOLIC
                     cItemSc  := SOU->OU_ITEMSC
                     cItGrdSc := SOU->OU_ITGRDSC
                     nOp      := nDoc
                     cItemOp  := cItem
                     cItGrdOp := cItemGrd
                     cEmpOrig := SOU->OU_EMPORIG
                     cFilOrig := SOU->OU_FILORIG
                     cEmpDest := SOU->OU_EMPDEST
                     cFilDest := SOU->OU_FILDEST
                     dData    := SOU->OU_DTTRANS
                     nQuant   := SOU->OU_QTPROD

                     //Busca a empresa/filial origem
                     SOT->(dbGoTo(nRecno))
                     SOR->(dbGoTo(SOT->OT_RGSOR))
                     cEmpOrig := SOR->OR_EMP
                     cFilOrig := SOR->OR_FILEMP

                     //Busca a empresa/filial destino
                     SOT->(dbGoTo((cAliasBKP)->(SOTDEST)))
                     SOR->(dbGoTo(SOT->OT_RGSOR))
                     cEmpDest := SOR->OR_EMP
                     cFilDest := SOR->OR_FILEMP

                     RecLock("SOU",.T.)
                        SOU->OU_FILIAL  := xFilial("SOU")
                        SOU->OU_EMPORIG := cEmpOrig
                        SOU->OU_FILORIG := cFilOrig
                        SOU->OU_EMPDEST := cEmpDest
                        SOU->OU_FILDEST := cFilDest
                        SOU->OU_PROD    := cProduto
                        SOU->OU_NRMRP   := c711NumMRP
                        SOU->OU_OPPROD  := nOp
                        SOU->OU_SCSOLIC := nNumSc
                        SOU->OU_ITEMOP  := cItemOp
                        SOU->OU_ITEMSC  := cItemSc
                        SOU->OU_ITGRDOP := cItGrdOp
                        SOU->OU_ITGRDSC := cItGrdSc
                        SOU->OU_C2SEQ   := nSeq
                        SOU->OU_DTTRANS := dData
                        SOU->OU_QTPROD  := nQuant
                        SOU->OU_QTEST   := 0
                        SOU->OU_SITUACA := '1'
                        SOU->OU_QTMOVTO := 0
                     MsUnlock()
                  EndIf
                  lGerou := .T.
                  aRecScOp[nPos,8] -= nQuant
                  If aRecScOp[nPos,8] <= 0
                     aDel(aRecScOp,nPos)
                     aSize(aRecScOp,Len(aRecScOp)-1)
                  EndIf
               Else
                  lAdd   := .T.
                  aAdd(aRecScOp,{nRecno,cScOp,0,nDoc,nSeq,cItem,cItemGrd,.F.,nQuant})
               EndIf
            EndIf
         EndIf
      EndIf
      If Select(cAliasBKP) > 0
         (cAliasBKP)->(dbCloseArea())
      EndIf

      nQtEst  := 0
      nQtProd := nQuant

      SOT->(dbGoTo(nRecno))
      If !lGerou
         nQtOrigem  := sldSosBkp(nRecno,'O')
         nQtDestino := sldSosBkp(nRecno,'D')
         If nQtOrigem <> 0 .Or. nQtDestino <> 0
            //Busca qual é o registro que irá receber o saldo desta produção/transferência.
            cQuery := " SELECT QUANT, "
            cQuery +=        " SOTDEST, "
            cQuery +=        " SOTORIG, "
            cQuery +=        " TIPO, "
            cQuery +=        " R_E_C_N_O_ SOSREC "
            cQuery +=   " FROM SOSBKP "
            cQuery +=  " WHERE FILIAL  = '" + xFilial("SOS") + "' "
            cQuery +=    " AND SOTORIG = " + cValToChar(nRecno)
            cQuery +=    " AND TIPO    = '2' "
            cQuery +=    " AND QUANT   > 0 "
            cQuery +=    " AND QUANT   = " + cValToChar(nQuant)
            cQuery := ChangeQuery(cQuery)
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBKP,.T.,.T.)
            dbSelectArea(cAliasBKP)
            If (cAliasBKP)->(Eof())
               (cAliasBKP)->(dbCloseArea())
               cQuery := " SELECT QUANT, "
               cQuery +=        " SOTDEST, "
               cQuery +=        " SOTORIG, "
               cQuery +=        " TIPO, "
               cQuery +=        " R_E_C_N_O_ SOSREC "
               cQuery +=   " FROM SOSBKP "
               cQuery +=  " WHERE FILIAL  = '" + xFilial("SOS") + "' "
               cQuery +=    " AND SOTORIG = " + cValToChar(nRecno)
               cQuery +=    " AND TIPO    = '2' "
               cQuery +=    " AND QUANT   > 0 "
               cQuery := ChangeQuery(cQuery)
               dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBKP,.T.,.T.)
               dbSelectArea(cAliasBKP)
            EndIf
            If !(cAliasBKP)->(Eof())
               If (cAliasBKP)->(QUANT) > 0
                  nRecDest := (cAliasBKP)->(SOTDEST)
                  nPosSos := aScan(aTransEst,{|x| x[1] == (cAliasBKP)->(SOSREC) })

                  If nPosSos > 0
                     If aTransEst[nPosSos,2] < nQtOp
                        (cAliasBKP)->(dbSkip())
                        nQtSkip := 1
                        lContinua := .T.
                        While lContinua
                           If !(cAliasBKP)->(Eof())
                              If aScan(aTransEst,{|x| x[1] == (cAliasBKP)->(SOSREC) .And. x[2] >= nQtOp }) > 0
                                 (cAliasBKP)->(dbSkip())
                                 nQtSkip++
                                 Loop
                              Else
                                 aAdd(aTransEst,{(cAliasBKP)->(SOSREC),(cAliasBKP)->(QUANT)})
                                 nRecDest := (cAliasBKP)->(SOTDEST)
                                 nPosSos := Len(aTransEst)
                                 Exit
                              EndIf
                           Else
                              (cAliasBKP)->(dbSkip(-nQtSkip))
                              Exit
                           EndIf
                           (cAliasBKP)->(dbSkip())
                        End
                     EndIf
                  Else
                     aAdd(aTransEst,{(cAliasBKP)->(SOSREC),(cAliasBKP)->(QUANT)})
                     nPosSos := Len(aTransEst)
                  EndIf

                  //Busca a empresa/filial destino
                  SOT->(dbGoTo(nRecDest))
                  SOR->(dbGoTo(SOT->OT_RGSOR))
                  cEmpDest := SOR->OR_EMP
                  cFilDest := SOR->OR_FILEMP

                  If cScOp == "SC"
                     nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "OP" .And. x[Iif(x[2]=="OP",9,8)] == nQuant})
                     If nPos < 1
                        nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "OP"})
                     EndIf
                     If nPos > 0
                        nOp      := aRecScOp[nPos,4]
                        cItemOp  := aRecScOp[nPos,6]
                        cItGrdOp := aRecScOp[nPos,7]
                        nSeq     := aRecScOp[nPos,5]
                        If nQtProd > aRecScOp[nPos,9]
                           nQtProd := aRecScOp[nPos,9]
                        EndIf
                     Else
                        nOp      := ""
                        cItemOp  := ""
                        cItGrdOp := ""
                        nSeq     := ""
                     EndIf
                     If nPos <= 0
                        nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "SC" .And. x[Iif(x[2]=="OP",9,8)] == nQuant})
                        If nPos < 1
                           nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "SC"})
                        EndIf
                        If nPos > 0
                           nOp      := nDoc
                           cItemOp  := cItem
                           cItGrdOp := cItemGrd
                           nSeq     := "SC"
                           nNumSc   := aRecScOp[nPos,4]
                           cItemSc  := aRecScOp[nPos,5]
                           cItGrdSc := aRecScOp[nPos,6]
                           If nQtProd > aRecScOp[nPos,8]
                              nQtProd := aRecScOp[nPos,8]
                           EndIf
                        Else
                           nNumSc   := nDoc
                           cItemSc  := cItem
                           cItGrdSc := cItemGrd
                        EndIf
                     Else
                        nNumSc   := nDoc
                        cItemSc  := cItem
                        cItGrdSc := cItemGrd
                     EndIf
                  Else
                     nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "SC" .And. x[Iif(x[2]=="OP",9,8)] == nQuant})
                     If nPos < 1
                        nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "SC" })
                     EndIf
                     If nPos > 0
                        nNumSc   := aRecScOp[nPos,4]
                        cItemSc  := aRecScOp[nPos,5]
                        cItGrdSc := aRecScOp[nPos,6]
                        If nQtProd > aRecScOp[nPos,8]
                           nQtProd := aRecScOp[nPos,8]
                        EndIf
                     Else
                        nNumSc   := ""
                        cItemSc  := ""
                        cItGrdSc := ""
                     EndIf
                     nOp      := nDoc
                     cItemOp  := cItem
                     cItGrdOp := cItemGrd
                  EndIf

                  //Insere registro na tabela de Sugestão de transferência.
                  RecLock("SOU",.T.)
                     SOU->OU_FILIAL  := xFilial("SOU")
                     SOU->OU_EMPORIG := cEmpAnt
                     SOU->OU_FILORIG := cFilAnt
                     SOU->OU_EMPDEST := cEmpDest
                     SOU->OU_FILDEST := cFilDest
                     SOU->OU_PROD    := cProduto
                     SOU->OU_NRMRP   := c711NumMRP
                     SOU->OU_OPPROD  := nOp
                     SOU->OU_SCSOLIC := nNumSc
                     SOU->OU_ITEMOP  := cItemOp
                     SOU->OU_ITEMSC  := cItemSc
                     SOU->OU_ITGRDOP := cItGrdOp
                     SOU->OU_ITGRDSC := cItGrdSc
                     SOU->OU_C2SEQ   := nSeq
                     SOU->OU_DTTRANS := dData
                     SOU->OU_QTPROD  := nQtProd
                     SOU->OU_QTEST   := nQtEst
                     SOU->OU_SITUACA := '1'
                     SOU->OU_QTMOVTO := 0
                  MsUnlock()
                  nRecSou := SOU->(Recno())
                  If cScOp == "OP"
                     If !Empty(nNumSc)
                        nQuant -= nQtProd
                     EndIf
                  Else
                     If !Empty(nOp)
                        nQuant -= nQtProd
                     EndIf
                  EndIf
                  If nPosSos > 0
                     aTransEst[nPosSos,2] -= nQtProd
                  EndIf
                  If lAdd
                     If nQuant <= 0 .And. nPos > 0
                        aDel(aRecScOp,Len(aRecScOp))
                        aSize(aRecScOp,Len(aRecScOp)-1)
                     Else
                        aRecScOp[Len(aRecScOp),3] := nRecSou
                        If aRecScOp[Len(aRecScOp),2] == "OP"
                           aRecScOp[Len(aRecScOp),9] := nQuant
                        Else
                           aRecScOp[Len(aRecScOp),8] := nQuant
                        EndIf
                     EndIf
                  Else
                     If AllTrim(cScOp) == "SC"
                        aAdd(aRecScOp,{nRecno,cScOp,nRecSou,nDoc,cItem,cItemGrd,.F.,nQuant})
                     Else
                        aAdd(aRecScOp,{nRecno,cScOp,nRecSou,nDoc,nSeq,cItem,cItemGrd,.F.,nQuant})
                     EndIf
                  EndIf
                  atuSosBkp((cAliasBKP)->(SOSREC),nQtProd)
                  If nPos > 0
                     aDel(aRecScOp,nPos)
                     aSize(aRecScOp,Len(aRecScOp)-1)
                  EndIf

                  lContinua := Iif(nQuant > 0, .T., .F.)

                  cQuery := " SELECT QUANT, "
                  cQuery +=        " SOTDEST, "
                  cQuery +=        " SOTORIG, "
                  cQuery +=        " TIPO, "
                  cQuery +=        " R_E_C_N_O_ SOSREC "
                  cQuery +=   " FROM SOSBKP "
                  cQuery +=  " WHERE FILIAL  = '" + xFilial("SOS") + "' "
                  cQuery +=    " AND SOTORIG = " + cValToChar(nRecno)
                  cQuery +=    " AND TIPO    = '2' "
                  cQuery +=    " AND QUANT   > 0 "
                  cQuery := ChangeQuery(cQuery)
                  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAux,.T.,.T.)
                  dbSelectArea(cAliasAux)
                  While (cAliasAux)->(!Eof()) .And. nQuant > 0
                     nRecDest := (cAliasAux)->(SOTDEST)
                     SOT->(dbGoTo(nRecDest))
                     SOR->(dbGoTo(SOT->OT_RGSOR))
                     cEmpDest := SOR->OR_EMP
                     cFilDest := SOR->OR_FILEMP
                     nQtTot   := (cAliasAux)->(QUANT)
                     While lContinua .And. nQtTot > 0
                        nQtProd := nQuant
                        If cScOp == "SC"
                           nNumSc   := nDoc
                           cItemSc  := cItem
                           cItGrdSc := cItemGrd

                           nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "OP" .And. x[Iif(x[2]=="OP",9,8)] == nQuant})
                           If nPos < 1
                              nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "OP"})
                           EndIf
                           If nPos > 0
                              nOp      := aRecScOp[nPos,4]
                              cItemOp  := aRecScOp[nPos,6]
                              cItGrdOp := aRecScOp[nPos,7]
                              nSeq     := aRecScOp[nPos,5]
                           Else
                              nOp      := ""
                              cItemOp  := ""
                              cItGrdOp := ""
                              nSeq     := ""
                              nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "SC" .And. x[Iif(x[2]=="OP",9,8)] == nQuant})
                              If nPos < 1
                                 nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "SC"})
                              EndIf
                              If nPos > 0
                                 nOp      := nDoc
                                 cItemOp  := cItem
                                 cItGrdOp := cItemGrd
                                 nSeq     := "SC"
                                 nNumSc   := aRecScOp[nPos,4]
                                 cItemSc  := aRecScOp[nPos,5]
                                 cItGrdSc := aRecScOp[nPos,6]
                                 If nQtProd > aRecScOp[nPos,8]
                                    nQtProd := aRecScOp[nPos,8]
                                 EndIf
                              EndIf
                           EndIf
                        Else
                           nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "SC" .And. x[Iif(x[2]=="OP",9,8)] == nQuant})
                           If nPos < 1
                              nPos := aScan(aRecScOp,{|x| x != Nil .And. x[1] == nRecDest .And. x[2] == "SC"})
                           EndIf
                           If nPos > 0
                              nNumSc   := aRecScOp[nPos,4]
                              cItemSc  := aRecScOp[nPos,5]
                              cItGrdSc := aRecScOp[nPos,6]
                              nQtProd  := aRecScOp[nPos,8]
                           Else
                              nNumSc   := ""
                              cItemSc  := ""
                              cItGrdSc := ""
                           EndIf
                           nOp      := nDoc
                           cItemOp  := cItem
                           cItGrdOp := cItemGrd
                        EndIf
                        If nPos > 0
                           //Insere registro na tabela de Sugestão de transferência.
                           RecLock("SOU",.T.)
                              SOU->OU_FILIAL  := xFilial("SOU")
                              SOU->OU_EMPORIG := cEmpAnt
                              SOU->OU_FILORIG := cFilAnt
                              SOU->OU_EMPDEST := cEmpDest
                              SOU->OU_FILDEST := cFilDest
                              SOU->OU_PROD    := cProduto
                              SOU->OU_NRMRP   := c711NumMRP
                              SOU->OU_OPPROD  := nOp
                              SOU->OU_SCSOLIC := nNumSc
                              SOU->OU_ITEMOP  := cItemOp
                              SOU->OU_ITEMSC  := cItemSc
                              SOU->OU_ITGRDOP := cItGrdOp
                              SOU->OU_ITGRDSC := cItGrdSc
                              SOU->OU_C2SEQ   := nSeq
                              SOU->OU_DTTRANS := dData
                              SOU->OU_QTPROD  := nQtProd
                              SOU->OU_QTEST   := nQtEst
                              SOU->OU_SITUACA := '1'
                              SOU->OU_QTMOVTO := 0
                           MsUnlock()
                           nRecSou := SOU->(Recno())
                           If lAdd
                              aRecScOp[Len(aRecScOp),3] := nRecSou
                           Else
                              If AllTrim(cScOp) == "SC"
                                 aAdd(aRecScOp,{nRecno,cScOp,nRecSou,nDoc,cItem,cItemGrd,.F.,nQuant})
                              Else
                                 aAdd(aRecScOp,{nRecno,cScOp,nRecSou,nDoc,nSeq,cItem,cItemGrd,.F.,nQuant})
                              EndIf
                           EndIf
                           If nPosSos > 0
                              aTransEst[nPosSos,2] -= nQtProd
                           EndIf
                           nQtTot -= nQtProd
                           nQuant -= nQtProd
                           atuSosBkp((cAliasAux)->(SOSREC),nQtProd)
                           If nPos > 0
                              aDel(aRecScOp,nPos)
                              aSize(aRecScOp,Len(aRecScOp)-1)
                           EndIf
                        Else
                           lContinua := .F.
                        EndIf
                     EndDo
                     (cAliasAux)->(dbSkip())
                  EndDo
                  (cAliasAux)->(dbCloseArea())
               EndIf
            EndIf
         EndIf
      EndIf
      If Select(cAliasBKP) > 0
         (cAliasBkp)->(dbCloseArea())
      EndIf
      RestArea(aArea)
   EndIf
Return

/*-------------------------------------------------------------------------/
//Programa: a107criNNT
//Autor:    Lucas Konrad França
//Data:     20/07/2015
//Descricao: Função para criação das tabelas NNT e NNS (MATA311)
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function a107criNNT()
   Local cQuery     := ""
   Local cBkpFilial := cFilAnt
   Local cAliasQry  := GetNextAlias()
   Local nI         := 0
   Local nPos       := 0
   Local dDataTran  := Date()
   Local aArea      := GetArea()
   Local aCposCab   := {}
   Local aCposDet   := {}
   Local aAux       := {}
   Local aErro      := {}
   Local aAllErro   := {}
   Local lRet       := .T.
   Local lAux       := .T.
   Local oAux, oModel, oStruct

   cQuery := " SELECT SORORIG.OR_PROD, "
   cQuery +=        " SB1.B1_UM, "
   cQuery +=        " SB1.B1_LOCPAD, "
   cQuery +=        " SOTORIG.OT_PERMRP, "
   cQuery +=        " SOS.SOTORIG RECORIG,  "
   cQuery +=        " SORORIG.OR_FILEMP FILORIG, "
   cQuery +=        " SOS.SOTDEST RECDEST,  "
   cQuery +=        " SORDEST.OR_FILEMP FILDEST, "
   cQuery +=        " SUM(SOS.QUANT) QUANT "
   cQuery +=   " FROM SOSBKP2 SOS, "
   cQuery +=          RetSqlName("SOR") + " SORORIG, "
   cQuery +=          RetSqlName("SOR") + " SORDEST, "
   cQuery +=          RetSqlName("SOT") + " SOTORIG, "
   cQuery +=          RetSqlName("SOT") + " SOTDEST, "
   cQuery +=          RetSqlName("SB1") + " SB1 "
   cQuery +=  " WHERE SOS.SOTORIG      = SOTORIG.R_E_C_N_O_ "
   cQuery +=    " AND SOTORIG.OT_RGSOR = SORORIG.R_E_C_N_O_ "
   cQuery +=    " AND SOS.SOTDEST      = SOTDEST.R_E_C_N_O_ "
   cQuery +=    " AND SOTDEST.OT_RGSOR = SORDEST.R_E_C_N_O_ "
   cQuery +=    " AND SORORIG.OR_PROD  = SB1.B1_COD "
   cQuery +=    " AND SB1.D_E_L_E_T_   = ' ' "
   cQuery +=    " AND SOS.QUANT        > 0 "
   cQuery +=  " GROUP BY SORORIG.OR_PROD, "
   cQuery +=  "          SB1.B1_UM, "
   cQuery +=  "          SB1.B1_LOCPAD, "
   cQuery +=  "          SOTORIG.OT_PERMRP, "
   cQuery +=  "          SOS.SOTORIG, "
   cQuery +=  "          SORORIG.OR_FILEMP, "
   cQuery +=  "          SOS.SOTDEST, "
   cQuery +=  "          SORDEST.OR_FILEMP "

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

   //Instancia o Model do MATA311
   oModel := FwLoadModel("MATA311")

   While !(cAliasQry)->(Eof())
      dDataTran := aPeriodos[Val((cAliasQry)->(OT_PERMRP))]
      cFilAnt := AllTrim((cAliasQry)->(FILORIG))
      //Campos do cabeçalho
      aCposCab := {}
      aAdd(aCposCab,{"NNS_DATA"  ,dDataTran})
      aAdd(aCposCab,{"NNS_STATUS","1"})
      aAdd(aCposCab,{"NNS_CLASS" ,"1"})

      //Campos detalhe
      aAux := {}
      aAdd(aAux,{"NNT_FILORI", AllTrim((cAliasQry)->(FILORIG)) })
      aAdd(aAux,{"NNT_PROD"  , (cAliasQry)->(OR_PROD) })
      aAdd(aAux,{"NNT_UM"    , (cAliasQry)->(B1_UM) })
      aAdd(aAux,{"NNT_LOCAL" , (cAliasQry)->(B1_LOCPAD) })
      aAdd(aAux,{"NNT_POTENC", 0 })
      aAdd(aAux,{"NNT_QUANT" , (cAliasQry)->(QUANT) })
      aAdd(aAux,{"NNT_QTSEG" , 0 })
      aAdd(aAux,{"NNT_FILDES", AllTrim((cAliasQry)->(FILDEST)) })
      aAdd(aAux,{"NNT_PRODD" , (cAliasQry)->(OR_PROD) })
      aAdd(aAux,{"NNT_UMD"   , (cAliasQry)->(B1_UM) })
      aAdd(aAux,{"NNT_LOCLD" , (cAliasQry)->(B1_LOCPAD) })
      aAdd(aAux,{"NNT_TS"    , cTesSaid })
      aAdd(aAux,{"NNT_TE"    , cTesEntr })
      aAdd(aAux,{"NNT_OBS"   , "MRP " + AllTrim(c711NumMRP) })

      aCposDet := {}
      aAdd(aCposDet,aAux)

      aAux := {}

      dbSelectArea("NNS")
      dbSetOrder(1)
      dbSelectArea("NNT")
      dbSetOrder(1)

      //Seta operação de Inclusão
      oModel:SetOperation(3)
      //Ativa o modelo
      oModel:Activate()

      //Instancia o modelo referente ao cabeçalho
      oAux := oModel:GetModel( 'NNSMASTER' )
      //Obtem a estrutura de dados do cabeçalho
      oStruct := oAux:GetStruct()

      aAux := oStruct:GetFields()
      lRet := .T.
      For nI := 1 To Len(aCposCab)
         // Verifica se os campos passados existem na estrutura do cabeçalho
         If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposCab[nI][1] ) } ) ) > 0
            // É feita a atribuição do dado ao campo do Model do cabeçalho
            If !( lAux := oModel:SetValue( 'NNSMASTER', aCposCab[nI][1],aCposCab[nI][2] ) )
               // Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
               // o método SetValue retorna .F.
               lRet := .F.
               Exit
            EndIf
         EndIf
      Next nI

      If lRet
         // Instanciamos apenas a parte do modelo referente aos dados do item
         oAux := oModel:GetModel( 'NNTDETAIL' )
         // Obtemos a estrutura de dados do item
         oStruct := oAux:GetStruct()
         aAux := oStruct:GetFields()

         For nI := 1 To Len( aCposDet[1] )
            // Verifica se os campos passados existem na estrutura de item
            If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposDet[1][nI][1] ) } ) ) > 0
               If !( lAux := oModel:SetValue( 'NNTDETAIL', aCposDet[1][nI][1], aCposDet[1][nI][2] ) )
                  // Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
                  // o método SetValue retorna .F.
                  lRet := .F.
                  Exit
               EndIf
            EndIf
         Next
      EndIf

      If lRet
         // Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
         // neste momento os dados não são gravados, são somente validados.
         If ( lRet := oModel:VldData() )
            // Se os dados foram validados faz-se a gravação efetiva dos
            // dados (commit)
            oModel:CommitData()

            //Atualiza a tabela SOSBKP
            cQuery := " UPDATE SOSBKP2 "
            cQuery +=    " SET QUANT = 0 "
            cQuery +=  " WHERE SOTORIG = " + cValToChar((cAliasQry)->(RECORIG))
            cQuery +=    " AND SOTDEST = " + cValToChar((cAliasQry)->(RECDEST))

            If TCSQLExec(cQuery) < 0
               Alert(TCSQLError())
            EndIf
         EndIf
      EndIf
      If !lRet
         // Se os dados não foram validados obtemos a descrição do erro para gerar
         // LOG ou mensagem de aviso
         aErro := {}
         aErro := oModel:GetErrorMessage()
         // A estrutura do vetor com erro é:
         // [1] identificador (ID) do formulário de origem
         // [2] identificador (ID) do campo de origem
         // [3] identificador (ID) do formulário de erro
         // [4] identificador (ID) do campo de erro
         // [5] identificador (ID) do erro
         // [6] mensagem do erro
         // [7] mensagem da solução
         // [8] Valor atribuído
         // [9] Valor anterior

         //Se está rodando em batch, monta o log, caso contrário, alimenta o array para mostrar o erro
         //posteriormente.
         If !lBatch
            aAdd(aAllErro,{(cAliasQry)->(OR_PROD),;
                           AllTrim((cAliasQry)->(FILORIG)),;
                           AllTrim((cAliasQry)->(FILDEST)),;
                           aErro})
         Else
            AutoGrLog(  STR0204 + ' [' + AllToChar( aErro[1] ) + ']' ) //"Id do formulário de origem:"
            AutoGrLog(  STR0205 + ' [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem: "
            AutoGrLog(  STR0206 + ' [' + AllToChar( aErro[3] ) + ']' ) //"Id do formulário de erro: "
            AutoGrLog(  STR0207 + ' [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro: "
            AutoGrLog(  STR0208 + ' [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro: " 
            AutoGrLog(  STR0209 + ' [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro: "
            AutoGrLog(  STR0210 + ' [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solução: "
            AutoGrLog(  STR0211 + ' [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribuído: "
            AutoGrLog(  STR0212 + ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior: "
            MostraErro()
         EndIf
      EndIf
      // Desativamos o Model
      oModel:DeActivate()
      (cAliasQry)->(dbSkip())
   End
   cFilAnt := cBkpFilial

   If Len(aAllErro) > 0
      verErroNNS(aAllErro)
   EndIf

   RestArea(aArea)
Return

/*-------------------------------------------------------------------------/
//Programa: verErroNNS
//Autor:    Lucas Konrad França
//Data:     21/12/2015
//Descricao: Exibe os erros que ocorreram durante a criação das solicitações de transferência
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function verErroNNS(aErros)
   Local oDlg, oPanel, oBrwErr
   Local aCampos := {}
   Local aSizes  := {}
   Local nI      := {}

   aSort(aErros,,,{|x,y| x[1] < y[1]})

   MsgInfo(STR0174,STR0030) //"Ocorreram erros durante a geração das solicitações de transferência." / "Atenção"

   dbSelectArea("SB1")
   SB1->(dbSetOrder(1))
   For nI := 1 To Len(aErros)
      If SB1->(dbSeek(xFilial("SB1")+aErros[nI,1]))
         aErros[nI,1] := AllTrim(aErros[nI,1]) + " - " + SB1->B1_DESC
      EndIf
      aErros[nI,2] := AllTrim(aErros[nI,2]) + " - " + FWFilialName(cEmpAnt,aErros[nI,2])
      aErros[nI,3] := AllTrim(aErros[nI,3]) + " - " + FWFilialName(cEmpAnt,aErros[nI,3])
   Next nI

   DEFINE MSDIALOG oDlg TITLE STR0175 FROM 0,0 TO 350,800 PIXEL //"Erros solicitação de transferência"

   oPanel := tPanel():Create(oDlg,01,01,,,,,,,401,156)
   //Cria o array dos campos para o browse
   aCampos := {STR0039,STR0176,STR0177} //"Produto" / "Filial origem" / "Filial destino"
   aSizes  := {140, 90, 90}

   // Cria Browse
   oBrwErr := TCBrowse():New( 0 , 0, 400, 155,,;
                              aCampos,aSizes,;
                              oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   oBrwErr:bLDblClick := {|| detalErro(oBrwErr:nAt,aErros)}
   // Seta vetor para a browse
   oBrwErr:SetArray(aErros)
   oBrwErr:bLine := {||{ aErros[oBrwErr:nAT,1],;
                         aErros[oBrwErr:nAt,2],;
                         aErros[oBrwErr:nAt,3]}}
   oPanel:Refresh()
   oPanel:Show()

   @ 160,305 BUTTON STR0178 SIZE 065, 011 PIXEL OF oDlg ACTION (detalErro(oBrwErr:nAt,aErros)) //"Detalhes do erro"
   DEFINE SBUTTON FROM 160,373 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg
   ACTIVATE DIALOG oDlg CENTERED
Return

Static Function detalErro(nLinha,aErros)
   AutoGrLog( STR0204 + ' [' + AllToChar( aErros[nLinha,4,1] ) + ']' )   //"Id do formulário de origem:" 
   AutoGrLog( STR0205 + ' [' + AllToChar( aErros[nLinha,4,2] ) + ']' )   //"Id do campo de origem: " 	
   AutoGrLog( STR0206 + ' [' + AllToChar( aErros[nLinha,4,3] ) + ']' )   //"Id do formulário de erro: " 	
   AutoGrLog( STR0207 + ' [' + AllToChar( aErros[nLinha,4,4] ) + ']' )   //"Id do campo de erro: " 		
   AutoGrLog( STR0208 + ' [' + AllToChar( aErros[nLinha,4,5] ) + ']' )   //"Id do erro: " + ' [' 		
   AutoGrLog( STR0209 + ' [' + AllToChar( aErros[nLinha,4,6] ) + ']' )   //"Mensagem do erro: " 			
   AutoGrLog( STR0210 + ' [' + AllToChar( aErros[nLinha,4,7] ) + ']' )   //"Mensagem da solução: " 		
   AutoGrLog( STR0211 + ' [' + AllToChar( aErros[nLinha,4,8] ) + ']' )   //"Valor atribuído: " 			
   AutoGrLog( STR0212 + ' [' + AllToChar( aErros[nLinha,4,9] ) + ']' )  //"Valor anterior: "			
  
   MostraErro()
Return

/*-------------------------------------------------------------------------/
//Programa: sldSosBkp
//Autor:    Lucas Konrad França
//Data:     27/05/2015
//Descricao: Busca o saldo de entrada/saida na tabela SOSBKP
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function sldSosBkp(nRecno,cTipo)
   Local aArea  := GetArea()
   Local cQuery := ""
   Local cAlias := GetNextAlias()
   Local nSaldo := 0

   cQuery := " SELECT SUM(QUANT) TOTAL "
   cQuery +=   " FROM SOSBKP "
   If cTipo == "O"
      cQuery += " WHERE SOTORIG = " + cValToChar(nRecno)
   Else
      cQuery += " WHERE SOTDEST = " + cValToChar(nRecno)
   EndIf

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   If !(cAlias)->(Eof())
      nSaldo := (cAlias)->(TOTAL)
   EndIf
   (cAlias)->(dbCloseArea())
   RestArea(aArea)
Return nSaldo

/*-------------------------------------------------------------------------/
//Programa: verOrigem
//Autor:    Lucas Konrad França
//Data:     27/05/2015
//Descricao: Verifica se um registro da SOT é origem de transferência
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function verOrigem(nRecno)
   Local cQuery := ""
   Local aArea  := GetArea()
   Local cAlias := GetNextAlias()
   Local lRet   := .T.

   cQuery := " SELECT COUNT(*) TOTAL "
   cQuery +=   " FROM SOSBKP "
   cQuery +=  " WHERE SOTORIG = " + cValToChar(nRecno)

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   If (cAlias)->(TOTAL) > 0
      lRet := .T.
   Else
      lRet := .F.
   EndIf
   (cAlias)->(dbCloseArea())
   RestArea(aArea)
Return lRet

/*-------------------------------------------------------------------------/
//Programa: A107ExpTre
//Autor:    Lucas Konrad França
//Data:     02/02/2015
//Descricao:   Rotina que expande o no  do produto corrente no tree
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107ExpTre()
Local cOldCargo   := oTreeM711:GetCargo()
Local nRecno      := Val(SubStr(cOldCargo,3,12))
Local cProdExpl   := CriaVar("OQ_PROD",.F.)
Local cOpcExpl := CriaVar("OQ_OPCORD",.F.)
Local cRevisao := CriaVar("OQ_NRRV",.F.)
Local nI          := 0
Local aDadosEnvio := {}
Local cAliasTop   := "EXPTREE"

//Possiciona array do tree
If nRecno > 0
   //Posiciona no registro correto
   DbSelectArea("SOQ")
   DbSetOrder(5)
   DbGoto(nRecno)

   cProdExpl   := OQ_PROD
   cOpcExpl := OQ_OPCORD
   cRevisao := OQ_NRRV

   cQuery := " SELECT DISTINCT SOQ.OQ_PROD, " +;
                             " SOQ.OQ_OPCORD, " +;
                             " SOQ.OQ_NRRV, " +;
                             " SOQ.OQ_PERMRP, " +;
                             " SOQ.OQ_ALIAS, " +;
                             " SOQ.OQ_QUANT, " +;
                             " SOQ.OQ_DOC, " +;
                             " SOQ.OQ_TPRG, " +;
                             " SOQ.OQ_DOCREV, " +;
                             " SOQ.OQ_NRRGAL, " +;
                             " SOQ.OQ_FILIAL, " +;
                             " SOQ.R_E_C_N_O_ SOQREC " +;
                " FROM " + RetSqlName("SOQ") + " SOQ " +;
               " WHERE SOQ.OQ_FILIAL   = '" + xFilial("SOQ") + "' " +;
                 " AND SOQ.OQ_PROD     = '" + cProdExpl + "' " +;
                 " AND SOQ.OQ_OPCORD   = '" + cOpcExpl + "' " +;
                 " AND SOQ.OQ_NRRV     = '" + cRevisao + "' " +;
               " ORDER BY SOQ.OQ_FILIAL, " +;
                        " SOQ.OQ_PROD, " +;
                        " SOQ.OQ_OPCORD, " +;
                        " SOQ.OQ_NRRV, " +;
                        " SOQ.OQ_ALIAS, " +;
                        " SOQ.OQ_NRRGAL "

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   dbSelectArea(cAliasTop)

   //Zera os valores para recalculo do produto posicionado
   While (cAliasTop)->(!Eof() .And. OQ_PROD+OQ_OPCORD+OQ_NRRV == cProdExpl+cOpcExpl+cRevisao)
      For nI := 1 to Len(aTotais)
         nAchouTot := ASCAN(aTotais[nI],{|x| x[1] == OQ_PROD+OQ_OPCORD+OQ_NRRV .And. x[2] == OQ_PERMRP .And. x[3] == OQ_ALIAS})
         If nAchouTot != 0
            aTotais[nI,nAchouTot,4] := 0
            Exit
         EndIf
      Next nI
      (cAliasTop)->(DbSkip())
   Enddo

   dbGoTop()

   //Alimenta Tree somente para o produto posicionado
   While (cAliasTop)->(!Eof() .And. OQ_PROD+OQ_OPCORD+OQ_NRRV == cProdExpl+cOpcExpl+cRevisao)
      //Adiciona registro em array totalizador utilizado no TREE  ³
      If Len(aTotais[Len(aTotais)]) > 4095
         AADD(aTotais,{})
      EndIf
      For nI := 1 to Len(aTotais)
         nAchouTot := ASCAN(aTotais[nI],{|x| x[1] == OQ_PROD+OQ_OPCORD+OQ_NRRV .And. x[2] == OQ_PERMRP .And. x[3] == OQ_ALIAS})
         If nAchouTot != 0
            aTotais[nI,nAchouTot,4] += OQ_QUANT
            Exit
         EndIf
      Next i
      If nAchouTot ==0
         AADD(aTotais[Len(aTotais)],{OQ_PROD+OQ_OPCORD+OQ_NRRV,OQ_PERMRP,OQ_ALIAS,OQ_QUANT})
      EndIf
      // Estrutura do array
      // Produto
      // Opcional
      // Revisao
      // Alias
      // Tipo
      // Documento
      // Recno
      // DocRev
      //                  01              02          03               04             05         06           07                         08
      AADD(aDadosEnvio,{(cAliasTop)->OQ_PROD,(cAliasTop)->OQ_OPCORD,(cAliasTop)->OQ_NRRV,(cAliasTop)->OQ_ALIAS,(cAliasTop)->OQ_TPRG,(cAliasTop)->OQ_DOC,StrZero((cAliasTop)->SOQREC,12),(cAliasTop)->OQ_DOCREV})
      (cAliasTop)->(DbSkip())
   End

   (cAliasTop)->(dbCloseArea())
EndIf
A107AdTree(.F.,aDadosEnvio,.F.)
Return

/*----------------------------------------------------------------------------/
//Programa:   verPontPed
//Autor:      Lucas Konrad França
//Data:       18/02/2015
//Parametros: cProduto - Código do produto
//Descricao:  Verifica se deve ser considerado o ponto de pedido para o produto
//            na empresa logada.
//Uso:        PCPA107
//----------------------------------------------------------------------------*/
Static Function verPontPed(cProduto)
Local lRet   := .F.
Local cQuery := ""
Local aArea  := GetArea()
Local cAlias := GetNextAlias()

cQuery := " SELECT COUNT(*) TOTAL "
cQuery +=   " FROM OQPROD "
cQuery +=  " WHERE TIPO    = 'PP' "
cQuery +=    " AND EMPRESA = '" + cEmpAnt  + "' "
cQuery +=    " AND FILIAL  = '" + cFilAnt  + "' "
cQuery +=    " AND PROD    = '" + cProduto + "' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
If (cAlias)->(TOTAL) > 0
   lRet := .T.
Else
   lRet := .F.
EndIf
(cAlias)->(dbCloseArea())
RestArea(aArea)
Return lRet

/*-------------------------------------------------------------------------/
//Programa: A107VldTbl
//Autor:    Lucas Konrad França
//Data:     02/04/2015
//Descricao:   Exibe uma popup com mensagem.
//Parametros:  lError  - Variável de erro por referência
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107VldTbl(lError)
Local oDlgMsg, oSayMsg

If lBatch
   PCPA106GEM(@lError,.T.)
else
   DEFINE MSDIALOG oDlgMsg FROM 0,0 TO 5,30 TITLE "MRP"

      oSayMsg := tSay():New(10,10,{||STR0163},oDlgMsg,,,,,,.T.,,,220,20)

   ACTIVATE MSDIALOG oDlgMsg CENTERED ON INIT (PCPA106GEM(@lError,.T.),oDlgMsg:End())
EndIF

Return Nil

/*-------------------------------------------------------------------------/
//Programa: A107Lote
//Autor:    Lucas Konrad França
//Data:     08/04/2015
//Descricao:   Função adaptada da A711Lote - Devolve a quantidade
//             considerendo lote econ.,min e toler.
//Parametros:  nQtdTotal - Quantidade a ser considerada
//             cProduto  - Produto a ser pesquisado
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function A107Lote(nQtdTotal,cProduto)
   Local cAlias  := Alias(),aQtdesF:={},aQtdesC:={},nx
   Local nQtdAtu := nQtdTotal
   Local nQtdF := 0, nQtdC := 0
   aQtdesF := CalcLote(cProduto,nQtdTotal,"F")
   aQtdesC := CalcLote(cProduto,nQtdTotal,"C")

   nQtdTotal:=0
   For nX := 1 to Len(aQtdesF)
       nQtdF+= aQtdesF[nX]
   Next
   For nX := 1 to Len(aQtdesC)
       nQtdC+= aQtdesC[nX]
   Next
   If nQtdF > nQtdC
      nQtdTotal := nQtdF
   Else
      nQtdTotal := nQtdC
   EndIf
   dbSelectArea(cAlias)
Return nQtdTotal

/*-------------------------------------------------------------------------/
//Programa: buscaEstSeg
//Autor:    Lucas Konrad França
//Data:     28/04/2015
//Descricao:   Retorna a quantidade de estoque de segurança, considerando
//             a prioridade das empresas
//Parametros:  cProduto  - Código do produto
//             aEmpresas - Array com as empresas
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function buscaEstSeg(cProduto,aEmpresas)
   Local aArea     := GetArea()
   Local nEstSeg   := 0
   Local nz        := 0

   If Len(aEmpresas) < 1
      aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
      For nz := 1 To Len(aEmpCent)
         If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
            aAdd(aEmpresas,{aEmpCent[nz,1],aEmpCent[nz,2],aEmpCent[nz,3]})
         EndIf
      Next nz
   EndIf
   If a107EstSeg(cProduto,aEmpresas,.F.)
      SB1->(MsSeek(xFilial("SB1")+cProduto))
      nEstSeg := CalcEstSeg(RetFldProd(cProduto,"B1_ESTFOR"))
   EndIf
   RestArea(aArea)
Return nEstSeg

/*-------------------------------------------------------------------------/
//Programa: existNec
//Autor:    Lucas Konrad França
//Data:     28/04/2015
//Descricao:   Verifica se já existe a necessidade
//Parametros:  nRecSot - RECNO da tabela SOT
//             nQtNece - Quantidade da necessidade
//             cTrans  - Indicador da tabela SOV
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function existNec(nRecSot,nQtNece,cTrans)
   Local cQuery := ""
   Local aArea  := GetArea()
   Local cAlias := GetNextAlias()
   Local lRet   := .F.

   cQuery := " SELECT COUNT(*) TOTAL "
   cQuery +=   " FROM " + RetSqlName("SOV") + " SOV "
   cQuery +=  " WHERE SOV.OV_RECSOT = " + Str(nRecSot)
   cQuery +=    " AND SOV.OV_TRANS  = '" + cTrans + "' "
   cQuery +=    " AND SOV.OV_QUANT  = " + Str(nQtNece)
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   If (cAlias)->(TOTAL) > 0
      lRet := .T.
   EndIf
   (cAlias)->(dbCloseArea())

   RestArea(aArea)
Return lRet

/*-------------------------------------------------------------------------/
//Programa: insSldMrp
//Autor:    Lucas Konrad França
//Data:     06/05/2015
//Descricao:   Insere novo registro na tabela de saldos utilizados no MRP
//Parametros:  cProduto   - Código do produto
//             cPeriodo   - Periodo que será utilizado o saldo
//             nQuant     - Quantidade utilizada
//             cEmpOrigem - Empresa origem (que disponibilizou o saldo)
//             cFilOrigem - Filial origem (que disponibilizou o saldo)
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function insSldMrp(cProduto, cPeriodo, nQuant, cEmpOrigem, cFilOrigem)
   Local nRec   := 0
   Local aArea     := GetArea()
   Local cAlias := GetNextAlias()
   Local cQuery := ""

   //Se executa o MRP em somente 1 empresa, não é necessário utilizar esta tabela.
   If Len(aEmpCent) == 1 .And. aEmpCent[1,1] == cEmpBkp .And. aEmpCent[1,2] == cFilBkp
      Return Nil
   EndIf

   cQuery := " SELECT MAX(R_E_C_N_O_) MAXREC "
   cQuery +=   " FROM SLDMRP "
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   If (cAlias)->(!EOF())
      nRec := (cAlias)->(MAXREC)
   Else
      nRec := 0
   EndIf
   nRec++
   (cAlias)->(dbCloseArea())
   cQuery := " INSERT INTO SLDMRP(PROD, PERMRP, QUANT, EMPORIG, FILORIG, R_E_C_N_O_) "
   cQuery +=             " VALUES('"+cProduto+"', "
   cQuery +=                     "'"+cPeriodo+"', "
   cQuery +=                      cValToChar(nQuant) + ","
   cQuery +=                     "'"+cEmpOrigem+"', "
   cQuery +=                     "'"+cFilOrigem+"', "
   cQuery +=                      cValToChar(nRec) + " )"
   TCSQLExec(cQuery)
   RestArea(aArea)
Return Nil

/*-------------------------------------------------------------------------/
//Programa: verSldMrp
//Autor:    Lucas Konrad França
//Data:     06/05/2015
//Descricao:   Verifica se o saldo pode ser utilizado no periodo.
//Parametros:  cProduto   - Código do produto
//             cPeriodo   - Periodo que será utilizado o saldo
//             cEmpOrigem - Empresa origem (que disponibilizou o saldo)
//             cFilOrigem - Filial origem (que disponibilizou o saldo)
//             lPeriodo   - Indica se o saldo será verificado no período passado por
//                          parâmetro, ou nos próximos períodos.
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function verSldMrp(cProduto, cPeriodo, cEmpOrigem, cFilOrigem, lPeriodo)
   Local cQuery    := ""
   Local aArea     := GetArea()
   Local cAlias    := GetNextAlias()
   Local nQtd      := 0

   cQuery := " SELECT SUM(QUANT) TOTQTD "
   cQuery +=   " FROM SLDMRP "
   cQuery +=  " WHERE PROD    = '" + cProduto + "' "
   If lPeriodo
      cQuery +=    " AND PERMRP  = '" + cPeriodo + "' "
   Else
      cQuery +=    " AND PERMRP  > '" + cPeriodo + "' "
   EndIf
   cQuery +=    " AND EMPORIG = '" + cEmpOrigem + "' "
   cQuery +=    " AND FILORIG = '" + cFilOrigem + "' "
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   If (cAlias)->(!EOF())
      nQtd := (cAlias)->(TOTQTD)
   EndIf
   (cAlias)->(dbCloseArea())
   RestArea(aArea)
Return nQtd

/*-------------------------------------------------------------------------/
//Programa: delSldMrp
//Autor:    Lucas Konrad França
//Data:     08/05/2015
//Descricao:   Limpa a tabela de saldos do MRP
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function delSldMrp()
   Local cSql := ""

   cSql := " DELETE FROM SLDMRP "
   TCSQLExec(cSql)
Return Nil

/*-------------------------------------------------------------------------/
//Programa: a107AtuSeg
//Autor:    Lucas Konrad França
//Data:     02/06/2015
//Descricao: Verifica se existe saldo para atender as necessidades de estoque de segurança/ponto pedido
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function a107AtuSeg()
   Local cQuery     := ""
   Local aArea      := GetArea()
   Local cAlias     := GetNextAlias()
   Local cTxtEstSeg := RetTitle("B1_ESTSEG")
   Local cTxtPonPed := RetTitle("B1_EMIN")
   Local nSaldo     := 0
   Local nQuant     := 0
   Local nz         := 0
   Local aEmpresas  := {}
   Local aRecalc    := {}
   Local cEmpresa   := cEmpAnt
   Local cFilia     := cFilAnt
   Local nTamFil    := TamSX3("OQ_FILEMP")[1]
   Local lEncontrou := .F.

   aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
   For nz := 1 To Len(aEmpCent)
      If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
         aAdd(aEmpresas,{aEmpCent[nz,1],aEmpCent[nz,2],aEmpCent[nz,3]})
      EndIf
   Next nz

   cQuery := " SELECT SOQ.OQ_EMP, SOQ.OQ_FILEMP, SOQ.OQ_PROD, SOQ.OQ_QUANT "
   cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ "
   cQuery +=  " WHERE SOQ.OQ_ALIAS = 'SB1' "
   cQuery +=    " AND SOQ.OQ_DOC = '"+cTxtEstSeg+"' "
   cQuery +=    " AND SOQ.OQ_PERMRP = '001' "

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   While (cAlias)->(!Eof())
      lEncontrou := .F.
      nQuant := (cAlias)->OQ_QUANT
      nSaldo := a107SldSum((cAlias)->(OQ_PROD),"001",.T.)
      If nSaldo > 0
         For nz := 1 To Len(aEmpresas)
            If AllTrim((cAlias)->(OQ_EMP)) == AllTrim(aEmpresas[nz,1]) .And. AllTrim((cAlias)->(OQ_FILEMP)) == AllTrim(aEmpresas[nz,2])
               Loop
            EndIf
            dbSelectArea("SOR")
            SOR->(dbSetOrder(1))
            If SOR->(dbSeek(xFilial("SOR")+aEmpresas[nz,1]+PadR(aEmpresas[nz,2],nTamFil)+(cAlias)->(OQ_PROD)))
               dbSelectArea("SOT")
               SOT->(dbSetOrder(1))
               If SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+"001"))
                  If SOT->OT_QTSALD > 0
                     lEncontrou := .T.
                     If SOT->OT_QTSALD >= nQuant
                        RecLock("SOT",.F.)
                           SOT->OT_QTSLES := SOT->OT_QTSLES - nQuant
                        MsUnLock()
                        nQuant := 0
                     Else
                        RecLock("SOT",.F.)
                           SOT->OT_QTSLES := SOT->OT_QTSLES - SOT->OT_QTSALD
                        MsUnlock()
                        nQuant := nQuant - SOT->OT_QTSALD
                     EndIf
                     aAdd(aRecalc,{aEmpresas[nz,1],;
                                   aEmpresas[nz,2],;
                                   (cAlias)->(OQ_PROD),;
                                   SOT->(Recno())})
                  EndIf
               EndIf
            EndIf
            If nQuant <= 0
               Exit
            EndIf
         Next nz
         If lEncontrou
            dbSelectArea("SOR")
            SOR->(dbSetOrder(1))
            If SOR->(dbSeek(xFilial("SOR")+(cAlias)->(OQ_EMP)+(cAlias)->(OQ_FILEMP)+(cAlias)->(OQ_PROD)))
               dbSelectArea("SOT")
               SOT->(dbSetOrder(1))
               If SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+"001"))
                  nQuant := nQuant *-1
                  RecLock("SOT",.F.)
                     SOT->OT_QTSLES := nQuant
                  MsUnlock()
                  A107Recalc((cAlias)->(OQ_PROD),SOR->(OR_OPC),SOR->(OR_NRRV),"001",SOT->OT_QTSLES,/*06*/,SOT->OT_RGSOR,/*08*/,aEmpresas)
               EndIf
            EndIf
         EndIf
      EndIf
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())
   aSort(aRecalc,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
   For nz := 1 To Len(aRecalc)
      If AllTrim(aRecalc[nz,1]) != AllTrim(cEmpresa) .Or. AllTrim(aRecalc[nz,2]) != AllTrim(cFilia)
         A107AltEmp(aRecalc[nz,1], aRecalc[nz,2])
      EndIf
      SOT->(dbGoTo(aRecalc[nz,4]))
      SOR->(dbGoTo(SOT->OT_RGSOR))
      A107Recalc(aRecalc[nz,3],SOR->(OR_OPC),SOR->(OR_NRRV),"001",SOT->OT_QTSLES,/*06*/,SOT->OT_RGSOR,/*08*/,aEmpresas)
   Next nz
   If AllTrim(cEmpAnt) != AllTrim(cEmpBkp) .Or. AllTrim(cFilAnt) != AllTrim(cFilBkp)
      A107AltEmp(cEmpBkp, cFilBkp)
   EndIf

   RestArea(aArea)
Return Nil

/*-------------------------------------------------------------------------/
//Programa: vldParTran
//Autor:    Lucas Konrad França
//Data:     20/07/2015
//Descricao: Verifica se a parametrização está correta.
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Static Function vldParTran()
   Local lRet   := .T.
   Local nI     := 0
   Local cGrupo := ""

   If ! lGeraTrans $ "123"
      Help( ,, 'PCPA107',, "Parâmetro 'MV_MRPGETR' configurado incorretamente, favor verificar.", 1, 0 )
      lRet := .F.
   EndIf

   If lRet .And. lGeraTrans == "3"
      If !lGestEmp
         Help( ,, 'PCPA107',, "Verificar parâmetro 'MV_MRPGETR'. Configuração '3 - Gera transferência' disponível somente com Gestão de empresas ativado.", 1, 0 )
         lRet := .F.
      EndIf
      If lRet
         cGrupo := aEmpCent[1,1]
         For nI := 1 To Len(aEmpCent)
            If AllTrim(cGrupo) != AllTrim(aEmpCent[nI,1]) .Or. AllTrim(cGrupo) != AllTrim(cEmpAnt)
               lRet := .F.
               Help( ,, 'PCPA107',, "Verificar parâmetro 'MV_MRPGETR'. Configuração '3 - Gera transferência' permitida somente quando existir apenas um grupo de empresas cadastrado no 'Cadastro empresa centralizadora'.", 1, 0 )
               Exit
            EndIf
         Next nI
      EndIf
      If lRet
         If Empty(cTesEntr) .Or. Empty(cTesSaid)
            lRet := .F.
            Help( ,, 'PCPA107',, "Verificar TES Entrada/Saída no cadastro de empresas centralizadoras.", 1, 0 )
         EndIf
      EndIf
   EndIf
Return lRet

/*------------------------------------------------------------------------//
//Programa: A107AvSldA
//Autor:          Ricardo Prandi
//Data:           30/04/2015
//Descricao:      Funcao utilizada para avaliar se o saldo do alternativo foi
//                consumido em data futura, avaliando a existencia de outrO
//                alternativo para substituicao
//Parametros:     01.cProdAlt     - Codigo do produto alternativo a ser avaliado
//                02.cPeriodo     - Periodo inicial da avaliação
//                03.cRev711Vaz   - Revisao Estrutura
//                04.cParStrTipo  - String com tipos a serem processados
//                05.cParStrGrupo - String com tipos os grupos a serem processados
//                06.dDataNes     - Data da necessidade
//                07.lVerEmp      - Verifica se existe o alternativo nas outras empresas
//                08.cParEmp      - Empresa que será verificado o saldo
//                09.cParFil      - Filial que será verificado o saldo
//Uso:            PCPA107
//------------------------------------------------------------------------*/
Static Function A107AvSldA(cProdAlt,cPeriodo,cRev711Vaz,cParStrTipo,cParStrGrupo,dDataNes,lVerEmp,cParEmp,cParFil)
Local nSaldo      := 0
Local nQuant      := 0
Local nQuantParc  := 0
Local nQtdConv    := 0
Local nNewPer     := 0
Local nTamFil     := TamSX3("OQ_FILEMP")[1]
Local nCount      := 0
Local cProdTroca  := ""
Local cDocTroca   := ""
Local cEmpAtu     := cEmpAnt
Local cFilAtu     := cFilAnt
Local cSql        := ""
Local dDataTroca  := dDataBase
Local aAreaSB1    := SB1->(GetArea())
Local aAreaSGI    := SGI->(GetArea())
Local aAreaSOQ    := SOQ->(GetArea())
Local aAreaSOR    := SOR->(GetArea())
Local aAreaSOT    := SOT->(GetArea())
Local aAreaSG1    := SG1->(GetArea())
Local aEmpresas   := {}
Local aSB1Aux     := {}
Local aSOQAux     := {}
Local lMudou      := .F.

Default cParEmp   := cEmpAnt
Default cParFil   := cFilAnt

If lVerEmp
   aAdd(aEmpresas,{cEmpBkp,cFilBkp,0})
   For nCount := 1 To Len(aEmpCent)
      If Len(aEmpCent) > 1 .Or. ( Len(aEmpCent) == 1 .And. (aEmpCent[1,1] != cEmpBkp .Or. aEmpCent[1,2] != cFilBkp ) )
         aAdd(aEmpresas,{aEmpCent[nCount,1],aEmpCent[nCount,2],aEmpCent[nCount,3]})
      EndIf
   Next nCount
Else
   aAdd(aEmpresas,{cParEmp,cParFil,0})
EndIf

SB1->(dbSetOrder(1))
SGI->(dbSetOrder(1))
SOR->(dbSetOrder(1))

For nNewPer := Val(cPeriodo)+1 To Len(aPeriodos)
   cPeriodo := StrZero(nNewPer,3)

   //Posiciona no cadastro do produto
   SB1->(dbSeek(xFilial("SB1")+cProdAlt))

   //Verifica saldo do produto alternativo no periodo.
   nSaldo := A107SldSOT(cProdAlt,cPeriodo,CriaVar("OQ_OPCORD"),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,/*05*/,/*06*/,/*07*/,cParEmp,cParFil)

   If nSaldo < 0
      SOQ->(DbSetOrder(1))
      SOQ->(MsSeek(xFilial("SOQ")+cParEmp+PadR(cParFil,nTamFil)+cProdAlt+If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz)+cPeriodo+"4"))

      While nSaldo < 0 .And. !SOQ->(EOF()) .And. SOQ->(OQ_EMP+OQ_FILEMP+OQ_PROD+OQ_NRRV+OQ_PERMRP+OQ_TPRG) == ;
                              cParEmp+PadR(cParFil,nTamFil)+cProdAlt+If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz)+cPeriodo+"4"

         lMudou  := .F.
         aSOQAux := {}
         aSB1Aux := {}
         //Se a saida é do produto principal
         If Empty(SOQ->OQ_PRODOG)
            //Procura disponibilidade do saldo utilizado nos produtos alternativos ja fazendo a troca
            nCount := 1
            While nCount <= Len(aEmpresas) .And. nSaldo != 0
               //Quantidade a trocar
               nQuantParc := Min(SOQ->OQ_QUANT,Abs(nSaldo))
               aSB1Aux := SB1->(GetArea())
               nQuant := A107VerAlt(cProdAlt,SOQ->OQ_DOC,cPeriodo,nQuantParc,cParStrTipo,cParStrGrupo,cRev711Vaz,SOQ->OQ_DTOG,0,CriaVar("OQ_OPCORD"),/*11*/,/*12*/,.F.,aEmpresas[nCount,1],aEmpresas[nCount,2])
               SB1->(RestArea(aSB1Aux))
               //Trocou saida inteira por alternativos
               If nQuant == 0
                  //Remove saida da linha de saidas da estrutura
                  SOR->(dbSeek(xFilial("SOR")+cParEmp+PadR(cParFil,nTamFil)+cProdAlt+If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz)))

                  SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+cPeriodo))
                  RecLock("SOT",.F.)
                  SOT->OT_QTSEST -= SOQ->OQ_QUANT
                  SOT->(MsUnLock())

                  //Remove saida
                  cSql := " DELETE FROM " + RetSqlName("SOQ")
                  cSql +=  " WHERE R_E_C_N_O_ = " + cValToChar(SOQ->(Recno()))
                  TCSQLExec(cSql)
                  cEmpAnt := cParEmp
                  cFilAnt := cParFil
                  //Recalcula saldo do produto no periodo
                  a107Recalc(cProdAlt,CriaVar("OQ_OPCORD"),If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz),/*04*/,/*05*/,/*06*/,SOR->(RecNo()),RetFldProd(SB1->B1_COD,"B1_EMIN"),aEmpresas)
                  cEmpAnt := cEmpAtu
                  cFilAnt := cFilAtu
               Else
                  If nQuant < SOQ->OQ_QUANT .And. nQuant > 0 .And. nQuant != nQuantParc //Trocou parte da saida por alternativos
                     //-- Diminui saida da linha de saidas da estrutura
                     SOR->(dbSeek(xFilial("SOR")+cParEmp+PadR(cParFil,nTamFil)+cProdAlt+If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz)))

                     SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+cPeriodo))
                     RecLock("SOT",.F.)
                     SOT->OT_QTSEST -= SOQ->OQ_QUANT - nQuant
                     SOT->(MsUnLock())

                     //Diminui saida do registro de necessidade
                     RecLock("SOQ",.F.)
                     SOQ->OQ_QUANT := nQuant
                     SOQ->(MsUnLock())

                     cEmpAnt := cParEmp
                     cFilAnt := cParFil
                     //Recalcula saldo do produto no periodo
                     a107Recalc(cProdAlt,CriaVar("OQ_OPCORD"),If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz),/*04*/,/*05*/,/*06*/,SOR->(RecNo()),SB1->B1_EMIN,aEmpresas)
                     cEmpAnt := cEmpAtu
                     cFilAnt := cFilAtu
                  EndIf
               EndIf
               nSaldo := A107SldSOT(cProdAlt,cPeriodo,,CriaVar("OQ_OPCORD"),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,/*06*/,/*07*/,cParEmp,cParFil)
               nCount++
            End

            //Se trocou de empresa, volta para a que estava anteriormente.
            If AllTrim(cEmpAtu) != AllTrim(cEmpAnt) .Or. AllTrim(cFilAtu) != AllTrim(cFilAnt)
               aSOQAux := SOQ->(GetArea())
               aSB1Aux := SB1->(GetArea())
               a107AltEmp(cEmpAtu,cFilAtu)
               SOQ->(RestArea(aSOQAux))
               SB1->(RestArea(aSB1Aux))
            EndIf
         Else
            //Quantidade a trocar
            nQuantParc := Min(SOQ->OQ_QUANT,Abs(nSaldo))

            //Se a saida e de produto alternativo de algum principal, posiciona SB1 no produto origem
            SB1->(dbSeek(xFilial("SB1")+SOQ->OQ_PRODOG))

            //Posiciona SGI no registro da mp orinigal para pegar o fator de conversao
            SGI->(dbSeek(xFilial("SGI")+SOQ->OQ_PRODOG))

            While !SGI->(EOF()) .And. SGI->(GI_FILIAL+GI_PRODORI) == xFilial("SGI")+SOQ->OQ_PRODOG
               If SGI->GI_PRODALT == cProdAlt
                  Exit
               EndIf

               SGI->(dbSkip())
            End

            If SGI->GI_TIPOCON == "M"
                 nQtdConv := nQuantParc / SGI->GI_FATOR
            Else
                 nQtdConv := nQuantParc * SGI->GI_FATOR
            EndIf

            //Procura disponibilidade do saldo utilizado nos produtos alternativos ja fazendo a troca
            nQuant := A107VerAlt(SOQ->OQ_PRODOG,SOQ->OQ_DOC,cPeriodo,nQtdConv,cParStrTipo,cParStrGrupo,cRev711Vaz,SOQ->OQ_DTOG,0,CriaVar("OQ_OPCORD"))

            //Trocou saida inteira por alternativo ou principal
            If nQuantParc == SOQ->OQ_QUANT
               //Remove saida da linha de saidas da estrutura
               SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProdAlt+If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz)))

               SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+cPeriodo))
               RecLock("SOT",.F.)
               SOT->OT_QTSEST -= SOQ->OQ_QUANT
               SOT->(MsUnLock())

               cProdTroca := SOQ->OQ_PRODOG
               dDataTroca := SOQ->OQ_DTOG
               cDocTroca  := SOQ->OQ_DOC

               //Remove saida
               cSql := " DELETE FROM " + RetSqlName("SOQ")
               cSql +=  " WHERE R_E_C_N_O_ = " + cValToChar(SOQ->(Recno()))
               TCSQLExec(cSql)

               //Recalcula saldo do produto no periodo
               a107Recalc(cProdAlt,CriaVar("OQ_OPCORD"),If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz),/*04*/,/*05*/,/*06*/,SOR->(RecNo()),SB1->B1_EMIN,aEmpresas)
            ElseIf nQuantParc < SOQ->OQ_QUANT //Trocou parte da saida por alternativos
                  //Diminui saida da linha de saidas da estrutura
                  SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProdAlt+If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz)))

                  SOT->(dbSeek(xFilial("SOT")+PadR(AllTrim(Str(SOR->(Recno()))),10)+cPeriodo))
                  RecLock("SOT",.F.)
                  SOT->OT_QTSEST -= nQuantParc
                  SOT->(MsUnLock())

                  //Diminui saida do registro de necessidade
                  RecLock("SOQ",.F.)
                  SOQ->OQ_QUANT -= nQuantParc
                  SOQ->(MsUnLock())

                  //Recalcula saldo do produto no periodo
                  a107Recalc(cProdAlt,CriaVar("OQ_OPCORD"),If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz),/*04*/,/*05*/,/*06*/,SOR->(RecNo()),RetFldProd(SB1->B1_COD,"B1_EMIN"),aEmpresas)
            EndIf
            //Gera saida do principal, ja que nao encontrou outros alternativos
            If nQuant > 0
               aDados := {SOQ->OQ_PROD,nQuant,SOQ->OQ_DTOG}
               A107CriaLOG("004",SOQ->OQ_PRODOG,aDados,lLogMRP,c711NumMrp)
               A107CriSOQ(SOQ->OQ_DTOG,  SOQ->OQ_PRODOG,CriaVar("OQ_OPCORD")  ,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SOR",0,Padr(SOQ->OQ_DOC,Len(SG1->G1_COD)),/*08*/,/*09*/,nQuant,"4",.F.,/*13*/,/*14*/,.F.,.T.,/*17*/,/*18*/,/*19*/,cParStrTipo,cParStrGrupo,/*22*/,SOQ->OQ_PRODOG,/*24*/,/*25*/,/*26*/)

               //Recalcula saldo do produto no periodo
               a107Recalc(cProdTroca,CriaVar("OQ_OPCORD"),If(A107TrataRev(),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,cRev711Vaz),/*04*/,/*05*/,/*06*/,SOR->(RecNo()),RetFldProd(SB1->B1_COD,"B1_EMIN"),aEmpresas)

               //-- Avalia se o produto nao foi utilizado em data futura e troca se necessário
               A107AvSldA(cProdTroca,A650DtoPer(dDataTroca),cRev711Vaz,cParStrTipo,cParStrGrupo,dDataTroca)
            EndIf
         EndIf

         //-- Atualiza saldo do produto
         nSaldo := A107SldSOT(cProdAlt,cPeriodo,,CriaVar("OQ_OPCORD"),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/)

         SOQ->(dbSkip())
      EndDo
   EndIf
Next nNewPer

//Se trocou de empresa, volta para a que estava anteriormente.
If AllTrim(cEmpAtu) != AllTrim(cEmpAnt) .Or. AllTrim(cFilAtu) != AllTrim(cFilAnt)
   a107AltEmp(cEmpAtu,cFilAtu)
EndIf

SB1->(RestArea(aAreaSB1))
SOQ->(RestArea(aAreaSOQ))
SOR->(RestArea(aAreaSOR))
SOT->(RestArea(aAreaSOT))
SGI->(RestArea(aAreaSGI))
SG1->(RestArea(aAreaSG1))

Return

Function A107RetVld(cProduto, dEntrega, cTipo)

Local cPeriodo := A650DtoPer(dEntrega)
Local aSavAre  := GetArea()
Local nNeces   := 0
Local nTamFil  := TamSX3("OQ_FILEMP")[1]

SOR->(dbSetOrder(1))

If SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+cProduto))
   SOT->(dbSetOrder(1))
   If SOT->(dbSeek(xFilial("SOT")+STR(SOR->(RecNo()),10)+cPeriodo))
      Do Case
         Case cTipo == '1'
            nNeces := SOT->OT_QTSLES
         Case cTipo == '2'
            nNeces := SOT->OT_QTENTR
         Case cTipo == '3'
            nNeces := SOT->OT_QTSAID
         Case cTipo == '4'
            nNeces := SOT->OT_QTSEST
         Case cTipo == '5'
            nNeces := SOT->OT_QTSALD
         Case cTipo == '6'
            nNeces := SOT->OT_QTNECE
      End Case
   EndIf
EndIf

Return nNeces

/*------------------------------------------------------------------------//
//Programa: apagaNNT
//Autor:          Lucas Konrad França
//Data:           10/12/2015
//Descricao:      Exclui a tabela NNT gerada para as ordens previstas que foram excluidas.
//Uso:            PCPA107
//------------------------------------------------------------------------*/
Static Function apagaNNT()
   Local nI         := 0
   Local cQuery     := ""
   Local cAliasQry  := "BUSCANNST"
   Local cFilialAux := cFilAnt
   Local aArea      := GetArea()
   Local aErro      := {}
   Local oModelNNS
   /*
      aProcMRP[nI][1] - SEQMRP
      aProcMRP[nI][2] - PRODUTO
      aProcMRP[nI][3] - QTD
   */
   dbSelectArea("NNS")
   dbSelectArea("NNT")
   For nI := 1 To Len(aProcMRP)

      cQuery := " SELECT NNS.R_E_C_N_O_ RECNNS, "
      cQuery +=        " NNT.R_E_C_N_O_ RECNNT "
      cQuery +=   " FROM " + RetSqlName("NNS") + " NNS, "
      cQuery +=              RetSqlName("NNT") + " NNT "
      cQuery +=  " WHERE NNS.D_E_L_E_T_ = ' ' "
      cQuery +=    " AND NNT.D_E_L_E_T_ = ' ' "
      cQuery +=    " AND NNT.NNT_COD    = NNS.NNS_COD "
      cQuery +=    " AND NNT.NNT_PROD   = '" + AllTrim(aProcMRP[nI][2]) + "' "
      cQuery +=    " AND NNT.NNT_OBS    = 'MRP " + AllTrim(aProcMRP[nI][1]) + "' "
      cQuery +=    " AND NNT.NNT_FILDES = '" + AllTrim(cFilAnt) + "' "
      cQuery +=  " ORDER BY 1 "

      cQuery := ChangeQuery(cQuery)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

      If !(cAliasQry)->(Eof())
         NNS->(dbGoTo((cAliasQry)->(RECNNS)))
         NNT->(dbGoTo((cAliasQry)->(RECNNT)))

         cFilAnt := NNT->(NNT_FILORI)

         oModelNNS := FWLoadModel('MATA311')

         If NNT->(NNT_QUANT) - aProcMRP[nI][3] <= 0
            oModelNNS:SetOperation(5)
            oModelNNS:Activate()
         Else
            oModelNNS:SetOperation(4)
            oModelNNS:Activate()

            oModelNNT := oModelNNS:GetModel( "NNTDETAIL" )
            oModelNNT:SeekLine( { {"NNT_PROD", aProcMRP[nI][2] } } )
            oModelNNT:SetValue( "NNT_QUANT", oModelNNT:GetValue('NNT_QUANT') - aProcMRP[nI][3] )
         EndIf

         if oModelNNS:VldData()
            oModelNNS:CommitData()
         Else
            aErro := oModelNNS:GetErrorMessage()
            //Conout(aErro[6])
         Endif
         oModelNNS:DeActivate()

         cFilAnt := cFilialAux
      EndIf

      (cAliasQry)->(dbCloseArea())

   Next nI
   RestArea(aArea)
Return

Static Function buscaRelSc(nRec)
   Local cNumOp   := ""
   Local cQuery   := ""
   Local cAliasC2 := GetNextAlias()
   Local aAreaSOT := SOT->(GetArea())
   Local aAreaSOQ := SOQ->(GetArea())
   Local aAreaSOR := SOR->(GetArea())

   SOT->(dbGoTo(nRec))
   SOR->(dbGoTo(SOT->(OT_RGSOR)))
   SOQ->(dbSetOrder(5))
   If SOQ->(dbSeek(xFilial("SOQ")+SOR->(OR_EMP+OR_FILEMP+OR_PROD+OR_OPCORD+OR_NRRV)+SOT->(OT_PERMRP)+PadR(AllTrim(Str(SOR->(Recno()))),10)))
      If !Empty(SOQ->OQ_DOC)
         cQuery := " SELECT SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN "
         cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
         cQuery +=  " WHERE SC2.D_E_L_E_T_ = ' ' "
         cQuery +=    " AND SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
         cQuery +=    " AND SC2.C2_PRODUTO = '" + AllTrim(SOQ->(OQ_DOC)) + "' "
         cQuery +=    " AND SC2.C2_SEQMRP  = '" + c711NumMRP + "' "

         cQuery := ChangeQuery(cQuery)
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasC2,.T.,.T.)

         If !(cAliasC2)->(Eof())
            cNumOp := (cAliasC2)->(C2_NUM+C2_ITEM+C2_SEQUEN)
         EndIf
         (cAliasC2)->(dbCloseArea())
      EndIf
   EndIf

   SOT->(RestArea(aAreaSOT))
   SOQ->(RestArea(aAreaSOQ))
   SOR->(RestArea(aAreaSOR))
Return cNumOp

/*-------------------------------------------------------------------------/
//Função:	 P107ShAlt
//Autor:	 Nilton MK
//Data:		 11/06/2012
//Descricao: Mostra produtos alternativos    
//Uso: 		 MATA712
//------------------------------------------------------------------------*/
Function P107ShAlt()
Local nPos	   := AsCan(aDbTree,{|x| x[7]==SubStr(oTreeM711:GetCargo(),3,12)})
Local cProduto := IIf(Empty(nPos),Space(15),aDbTree[nPos,1])
Local aArea    := GetArea()

Local oDlg,oBold,oListBox
Local aViewSGI:= {}

dbSelectArea("SGI")
dbSetOrder(1)
If MSSeek(xFilial("SGI")+cProduto)
	While !Eof() .And. GI_FILIAL+GI_PRODORI == xFilial("SGI")+cProduto
	    aadd(aViewSGI,{SGI->GI_PRODORI,GI_PRODALT,GI_FATOR,GI_MRP})
		dbSkip()
	Enddo
EndIf

If Empty(aViewSGI)
	Aviso(STR0030 ,STR0201,{STR0069},2)
	// "Atenção"  ,"Produto selecionado no tree não tem alternativos. Selecione um produto identificado com legenda."  , Voltar
Else
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg FROM 000,000  TO 250,400 TITLE STR0202 +cProduto Of oMainWnd PIXEL //Lista de produtos alternativos de
		oListBox := TWBrowse():New( 25,2,200,69,,{RetTitle("GI_PRODORI"),RetTitle("GI_PRODALT"),RetTitle("GI_FATOR"),RetTitle("GI_MRP"),,,},{17,55,55,55,55,55},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:SetArray(aViewSGI)
		oListBox:bLine := { || aViewSGI[oListBox:nAT]}
		@ 110,144  BUTTON STR0109 SIZE 045,010  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL   //"Voltar"
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

RestArea(aArea)

RETURN



/*/{Protheus.doc} A107VLOPC
//VALIDA SE TEM OPCIONAS E SE OPCIONAIS ESTA COMO OBRIGATORIO
--copiado fo fonte sigacusb.prx funcao e adaptado para função A107VLOPC
@author thiago.zoppi
@since 10/05/2018
@version 1.0 /*/
Function A107VLOPC(cProduto,cRet,aRetorOpc,cProdPai,cProdAnt,cProg,cOpcMarc,lVisual,nNivel,nQtd,dDataVal,cRevisao,lPreEstr,cProdPaOpc)

	Local aArea		:=GetArea()

	Local nAcho		:=0
	Local nString	:=0
	Local i			:=0
	Local nOpca		:=1
	Local aGrupos	:={}
	Local aRegs		:={}
	Local cOpcionais:="" // Variavel utilizada para retorno da string
	Local nTamDif	:=(Len(SGA->GA_OPC)+Len(SGA->GA_DESCOPC)+13)-(Len(SGA->GA_GROPC)+Len(SGA->GA_DESCGRP)+3)
	Local lOpcPadrao:= SuperGetMV("MV_REPGOPC",.F.,"N") == "N"

	Local aOpcionais	:={}
	Local aOpcionAUX 	:={}
	Local lRet      	:=.T.
	Local oDlg,oOpc,cOpc
	Local nQuantItem	:= 1
	Local cOpcSele 		:= ""
	Local cOpcComp 		:= ""
	Local cOpcDefa 		:= ""
	Local lOpcDefa 		:= .F.

	Default cProg 	 :=""
	Default cOpcMarc :=""
	Default lVisual  :=.F.
	Default nQtd     :=0
	Default dDataVal :=dDataBase
	Default lPreEstr :=.F.
	Default cProdPaOpc := cProduto

	cProduto := PadR(cProduto,Len(SB1->B1_COD))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao exista cria array que registra todos os niveis da estrutura    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("aRetorOpc") <> "A"
		aRetorOpc:={}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do array dos opcionais                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 1 Marcado (.T. ou .F.)
	// 2 Titulo("0") ou Item("1")
	// 3 Item Opcional+Descricao Opcional
	// 4 Grupo de Opcionais
	// 5 Registro no SG1
	// 6 Nivel no SG1
	// 7 Recno do SG1
	// 8 Componente Ok (.T.) ou Vencido (.F.)
	// 9 Codigo do componente
	//10 Default ?

	If Empty(cOpcDefa)
		dbSelectArea("SB1")
		dbSetOrder(1)
		lAchouB1 := MsSeek(xFilial("SB1")+cProduto)
		If lAchouB1
			cOpcDefa := SB1->B1_OPC
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre a estrutura do produto                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(IIf(lPreEstr,"SGG","SG1"))
	dbSetOrder(1)
	dbSeek(xFilial()+cProduto)
	Do While !Eof() .And. IIf(lPreEstr,SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cProduto,SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto)
		If !Empty(IIf(lPreEstr,SGG->GG_GROPC,SG1->G1_GROPC)) .And. !Empty(IIf(lPreEstr,SGG->GG_OPC,SG1->G1_OPC))

			cOpcArq := If(lPreEstr,SGG->GG_GROPC+SGG->GG_OPC,SG1->G1_GROPC+SG1->G1_OPC)

			If (!Empty(cOpcDefa) .And. !Empty(cOpcArq) .And. !(cOpcArq $ cOpcDefa)) .Or. (Empty(cOpcDefa) .Or. Empty(cOpcArq))
				lOpcDefa := .F.
			Else
				lOpcDefa := .T.
			EndIf

			// Caso ja tenha opcionais preenchidos, pesquisa se nao ‚ o grupo
			// atual
			If !Empty(cRet)
				// Verifica se ‚ a primeira posicao
				If Substr(cRet,1,Len(SGA->GA_GROPC)) == IIf(lPreEstr,SGG->GG_GROPC,SG1->G1_GROPC)
					nString:=1
				Else
					// Procura grupo no campo de opcionais default
					nString:=AT("/"+IIf(lPreEstr,SGG->GG_GROPC,SG1->G1_GROPC),cRet)
				EndIf
				If nString > 0 .And. lOpcPadrao
					cOpcSele := SubStr(cRet,Iif(nString==1,1,nString+1),Len(SGA->GA_GROPC)+Len(SGA->GA_OPC))
					cOpcComp := IIf(lPreEstr,SGG->GG_GROPC+SGG->GG_OPC,SG1->G1_GROPC+SG1->G1_OPC)

					//somente incluir se o opcional do componente for o opcional selecionado
					If cOpcSele == cOpcComp
						If SGA->(dbSeek(xFilial("SGA")+IIf(lPreEstr,SGG->GG_GROPC+SGG->GG_OPC,SG1->G1_GROPC+SG1->G1_OPC)))
							// Verifica se o grupo ja foi incluido
							nAcho:=ASCAN(aGrupos,IIf(lPreEstr,SGG->GG_GROPC,SG1->G1_GROPC))
							//Valida datas e revisao
							If !Empty(nQtd)
								nQuantItem := Round(ExplEstr(nQtd,dDataVal,"",cRevisao,,lPreEstr,,,,,,.T.,.F.),TamSX3("D4_QUANT")[2])
							EndIf
							If nAcho == 0
								AADD(aGrupos,IIf(lPreEstr,SGG->GG_GROPC,SG1->G1_GROPC))
								// Adiciona titulo ao array
								AADD(aOpcionAUX,{.F.,"0",SGA->GA_GROPC+" - "+SGA->GA_DESCGRP+Space(nTamDif),SGA->GA_GROPC,SGA->(Recno()),IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),QtdComp(nQuantItem)>QtdComp(0),IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP),lOpcDefa})
							EndIf

							// Verifica se o grupo ja foi digitado neste nivel
							nAcho:=ASCAN(aOpcionAUX,{ |x| x[2] == "1" .And. x[4] == SGA->GA_GROPC .And. x[5] == SGA->(Recno())})
							If nAcho == 0
								// Adiciona item ao array
								AADD(aOpcionAUX,{.T.,;
								"1",;
								SGA->GA_OPC+" - "+SGA->GA_DESCOPC,;
								SGA->GA_GROPC,;
								SGA->(Recno()),;
								IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),;
								IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),;
								QtdComp(nQuantItem)!=QtdComp(0),;
								IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP),;
								lOpcDefa})
							Else
								// Verifica se o grupo e produto ja foi digitado neste nivel
								nAcho:=ASCAN(aOpcionAUX,{ |x| x[2] == "1" .And. x[4] == SGA->GA_GROPC .And. x[5] == SGA->(Recno()) .And. x[9] == SG1->G1_COMP })
								If nAcho == 0
									// Adiciona item ao array
									If SG1->G1_INI > dDataBase .Or. SG1->G1_FIM < dDataBase
										AADD(aOpcionAUX,{.T.,"1",SGA->GA_OPC+" - "+SGA->GA_DESCOPC,SGA->GA_GROPC,SGA->(Recno()),IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),QtdComp(nQuantItem,.T.)>QtdComp(0,.T.),IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP),lOpcDefa})
									Else
										AADD(aOpcionAUX,{.T.,"1",SGA->GA_OPC+" - "+SGA->GA_DESCOPC,SGA->GA_GROPC,SGA->(Recno()),IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),.T.,IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP),lOpcDefa})
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					dbSkip()
					Loop
				EndIf
			EndIf
			If SGA->(dbSeek(xFilial("SGA")+IIf(lPreEstr,SGG->GG_GROPC+SGG->GG_OPC,SG1->G1_GROPC+SG1->G1_OPC)))
								
				// Verifica se o grupo ja foi incluido
				nAcho:=ASCAN(aGrupos,IIf(lPreEstr,SGG->GG_GROPC,SG1->G1_GROPC))
				//Valida datas e revisao
				If !Empty(nQtd)
					nQuantItem := Round(ExplEstr(nQtd,dDataVal,"",cRevisao,,lPreEstr,,,,,,.T.,.F.),TamSX3("D4_QUANT")[2])
				EndIf
				If nAcho == 0
					AADD(aGrupos,IIf(lPreEstr,SGG->GG_GROPC,SG1->G1_GROPC))
					// Adiciona titulo ao array
					AADD(aOpcionais,{.F.,"0",SGA->GA_GROPC+" - "+SGA->GA_DESCGRP+Space(nTamDif),SGA->GA_GROPC,SGA->(Recno()),IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),QtdComp(nQuantItem)!=QtdComp(0),IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP),lOpcDefa})
					AADD(aOpcionAUX,aClone(aTail(aOpcionais)))
				EndIf

				// Verifica se o grupo ja foi digitado neste nivel
				nAcho:=ASCAN(aOpcionais,{ |x| x[2] == "1" .And. x[4] == SGA->GA_GROPC .And. x[5] == SGA->(Recno())})
				If nAcho == 0
					// Adiciona item ao array
					AADD(aOpcionais,{OpcSelec(cOpcMarc, SGA->GA_GROPC+SGA->GA_OPC, cProdAnt, IIf(lPreEstr,SGG->GG_COMP+SGG->GG_TRT,SG1->G1_COMP+SG1->G1_TRT)),;
					"1",;
					SGA->GA_OPC+" - "+SGA->GA_DESCOPC,;
					SGA->GA_GROPC,;
					SGA->(Recno()),;
					IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),;
					IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),;
					QtdComp(nQuantItem)!=QtdComp(0),;
					IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP),;
					lOpcDefa})

					AADD(aOpcionAUX,aClone(aTail(aOpcionais)))
				Else
					// Verifica se o grupo e produto ja foi digitado neste nivel
					nAcho:=ASCAN(aOpcionAUX,{ |x| x[2] == "1" .And. x[4] == SGA->GA_GROPC .And. x[5] == SGA->(Recno()) .And. x[7] == IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())) })
					If nAcho == 0
						// Adiciona item ao array
						If SG1->G1_INI > dDataBase .Or. SG1->G1_FIM < dDataBase
							AADD(aOpcionAUX,{SGA->GA_GROPC+SGA->GA_OPC $ cOpcMarc,"1",SGA->GA_OPC+" - "+SGA->GA_DESCOPC,SGA->GA_GROPC,SGA->(Recno()),IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),QtdComp(nQuantItem,.T.)>QtdComp(0,.T.),IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP),lOpcDefa})
							nAcho:=ASCAN(aOpcionais,{ |x| x[2] == "1" .And. x[4] == SGA->GA_GROPC .And. x[5] == SGA->(Recno())})
							If nAcho > 0
								aOpcionais[nAcho,8] := .T.
							EndIf
						Else
							AADD(aOpcionAUX,{SGA->GA_GROPC+SGA->GA_OPC $ cOpcMarc,"1",SGA->GA_OPC+" - "+SGA->GA_DESCOPC,SGA->GA_GROPC,SGA->(Recno()),IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),.T.,IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP),lOpcDefa})
							nAcho:=ASCAN(aOpcionais,{ |x| x[2] == "1" .And. x[4] == SGA->GA_GROPC .And. x[5] == SGA->(Recno())})
							If nAcho > 0
								aOpcionais[nAcho,8] := .T.
							EndIf
						EndIf
					Else
						If QtdComp(nQuantItem,.T.)!=QtdComp(0,.T.)
							aOpcionAUX[nAcho,8] := .T.
							nAcho:=ASCAN(aOpcionais,{ |x| x[2] == "1" .And. x[4] == SGA->GA_GROPC .And. x[5] == SGA->(Recno())})
							If nAcho > 0
								aOpcionais[nAcho,8] := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			// Caso nao tenha opcionais neste nivel, guarda o registro para
			// pesquisar em niveis inferiores
			AADD(aRegs,{IIf(lPreEstr,SGG->(Recno()),SG1->(Recno())),IIf(lPreEstr,SGG->GG_NIV+SGG->GG_COMP,SG1->G1_NIV+SG1->G1_COMP),IIf(lPreEstr,SGG->GG_COMP,SG1->G1_COMP)})
		EndIf
		dbSkip()
	EndDo

	If Len(aOpcionais) > 0
	nOpca:=0
		
		IF (ASCAN(aOpcionais,{|x| x[8]})) > 0

			If	A107OpcOk(cProduto,aOpcionais,aGrupos,@aRegs,@cOpcionais,,,cRet, cProdPaOpc)
				nOpcA := 1
			Endif 	

		Else
			nOpcA := 1
		EndIf

	Else
		nOpcA := 1
	EndIf

	RestArea(aArea)
Return nOpcA == 1


/*/{Protheus.doc} A107OpcOk
//VALIDA GRUPO NOS CAMPOS DE OPCIONAIS
--copiado do fonte sigacusb.prx e adaptado para função  A107OpcOk
@author thiago.zoppi
@since 10/05/2018
@version 1.0

/*/
Function A107OpcOk(cProduto,aArray,aGrupos,aRegs,cOpcionais,cProg,aOpcionAUX,cOpcMark, cProdPaOpc)
LOCAL nAcho:=0,nString:=0,i, i1
LOCAL lRet:=.T.
LOCAL aTam:=TAMSX3("GA_OPC")
LOCAL cDefault:=""
LOCAL cBackOpc:=cOpcionais
Local aArea := GetArea()
Local lObrigat := .T.
Local cOpcSB1  := ""
Local lOpcPadrao:= SuperGetMV("MV_REPGOPC",.F.,"N") == "N"

Default cOpcMark := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se todos grupos tiveram um item selecionado ou possuem³
	//³opcional default cadastrado no SB1                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB1->(dbSetOrder(1))
	For i:=1 to Len(aGrupos)
		lObrigat := .T.
		nAcho := IIF(ASCAN(aArray,{|x| x[4] == aGrupos[i] .And. x[8]}) != 0,ASCAN(aArray,{|x| x[4] == aGrupos[i] .And. x[1]}),1)
		// Pesquisa no array se grupo nao teve item marcado
		//nAcho:=ASCAN(aArray,{|x| x[4] == aGrupos[i] .And. x[1]})
		// Caso nao achou item marcado procura opcional default
		If nAcho == 0
			If SGA->(dbSeek(xFilial("SGA")+aGrupos[i]))
				lObrigat := Iif(SGA->GA_OBG=="0",.F.,.T.)
			EndIf

			If lObrigat .And. SB1->(dbSeek(xFilial("SB1")+cProdPaOpc))
				//cOpcSB1 := Iif(Empty(SB1->B1_MOPC),SB1->B1_OPC,SB1->B1_MOPC)
				cOpcSB1 := SB1->B1_OPC
				If !Empty(cOpcSB1)
					// Verifica se o grupo esta na primeira posicao
					If Substr(cOpcSB1,1,Len(SGA->GA_GROPC)) == aGrupos[i]
						nString:=1
					Else
						// Procura grupo nas posicoes seguintes
						nString:=AT("/"+aGrupos[i],cOpcSB1)
					EndIf
					If nString > 0
						nString:=IF(nString=1,1,nString+1)
						cDefault:=Substr(cOpcSB1,nString,Len(SGA->GA_GROPC+SGA->GA_OPC))
						nAcho:=0
						nAcho:=ASCAN(aArray,{|x| Substr(x[3],1,Len(SGA->GA_OPC)) == Substr(cDefault,Len(SGA->GA_GROPC)+1) })
						If nAcho > 0
							cOpcionais+=cDefault+"/"
						EndIf
					EndIf
				EndIf
				// Caso nao achou o grupo no campo de opcionais default
				If nString <=0 .Or. nAcho <= 0
					If lObrigat
						lRet := .F.
						exit
					EndIf				
				
				EndIf
			EndIf
		 endif 	
	Next i


RestArea(aArea)
Return lRet


/*/{Protheus.doc} A107Autom
// Seta o valor da FLAG, para identificar que o MRP está sendo executado pela automação de testes (ADVPR)
@param lFlag	- Lógico. .T. - Execução pela automação de testes. .F. - Execução padrão.
@author Michelle.ramos
@since 17/09/2018
@version 1.0
/*/
Function A107Autom(lFlag)
	lIsADVPR := lFlag
Return
/*/{Protheus.doc} A107ADVPR
// Retorna a FLAG para identificar se o MRP está sendo executado pela automação de testes (ADVPR)
@author lucas.franca
@since 17/09/2018
@return lIsAdvpr	- Lógico. Se .T., o MRP está sendo executado pela automação de testes (ADVPR)
@version 1.0
/*/
Function A107ADVPR()
Return Iif(lIsADVPR==Nil,.F.,lIsADVPR)


/*/{Protheus.doc} P107FilGen
// Ativa e define o filtro do produtos 
@since 18/10/2018
@version 1.0
/*/
Static Function P107FilGen()
Local nI
Local cFilSB1	 := ""
Local cFilSOQ	 := ""
Local cExpFiltro := SB1->(BuildExpr("SB1") )
Local aProdAux	 := {}
Local lContinua	 := .T.

If Empty(cExpFiltro)
	//Restaura situalcao anterior  
	If Empty(cFilSB1Old)
		SB1->(DBClearFilter())
	Else
		SB1->(DBClearFilter())
		SB1->(dbSetFilter({|| &cFilSB1Old}, cFilSB1Old))
	EndIf
	SOQ->(DBClearFilter())
	PA107Tree(aPergs711[28]==1,/*02*/,/*.T.*/)
	lAtvFilNes	:= .F.
	lContinua	:= .F.
EndIf

If lContinua
	SB1->(dbSetFilter({|| &cExpFiltro}, cExpFiltro))
	SB1->(DbGotop())
	While SB1->(!Eof())
		If Empty(AsCan(aProdAux,{|x| x == SB1->B1_COD}))
			Aadd(aProdAux,SB1->B1_COD)
			cFilSB1 += SB1->B1_COD+"|"
		EndIf
		SB1->(DbSkip())
	EndDo

	//Restaura situacao anterior
	If Empty(cFilSB1Old)
		SB1->(DBClearFilter())
	Else
		SB1->(DBClearFilter())
		SB1->(dbSetFilter({|| &cFilSB1Old}, cFilSB1Old))
	EndIf
EndIf

If lContinua .And. Empty(aProdAux)
	lContinua := .F.
EndIf

If lContinua
	//Filtra a tabela SOQcom base na tabela SB1.
	cFilSOQ := 'OQ_PROD $ "'+cFilSB1+'"'
	SOQ->(dbSetFilter({|| &cFilSOQ}, cFilSOQ))
	PA107Tree(aPergs711[28]==1,,)
EndIf
Return