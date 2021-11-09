#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'DBTREE.CH'
#INCLUDE 'PCPA108.CH'

STATIC cEmpRet := "  "
//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA108
Consulta das sugestões de transferência

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Function PCPA108()
   Local cQuery       := ""
   Local cAlias       := GetNextAlias()
   Local aEmp         := {}
   Local a108Jobs     := {}
   Local nI           := 0
   Local aCampos      := {}
   Local cStartPath   := GetSrvProfString("Startpath","")
   Local nHandle      := 0
   Local lContinua    := .T.

   Private lConsulta  := .F.
   Private cProdDe    := ""
   Private cProdAte   := ""
   Private cEmpOrgDe  := ""
   Private cEmpOrgAte := ""
   Private cEmpDstDe  := ""
   Private cEmpDstAte := ""
   Private cNumMrpDe  := ""
   Private cNumMrpAte := ""
   Private cLastNode  := ""
   Private cNrMrp     := ""
   Private cEmpOrg    := ""
   Private cFilOrg    := ""
   Private cEmpDst    := ""
   Private cFilDst    := ""
   Private cProduto   := ""
   Private cScSolic   := ""
   Private cItemSc    := ""
   Private cItGrdSc   := ""
   Private cLastMrp   := ""
   Private aTamanhos  := FWGetDialogSize(oMainwnd)
   Private aTabNames  := {}
   Private aTrans     := {}
   Private aSolic     := {}
   Private aFornec    := {}
   Private aProduto   := {}
   Private aOrdens    := {}
   Private aEmpresas  := {}
   Private aOpSc      := {}
   Private aOrdensDst := {}
   Private oDlg, oPnlPai, oLayer, oPnlTree, oPnlDados
   Private oTree, oPnlTran, oPnlSolic, oPnlFornec, oBrwTrans
   Private oBrwSolic, oBrwFornec, oBrwProd, oLayerCent
   Private oPnlEsq, oPnlCentr, oPnlDir, oPnlBaixo
   Private oBrwOrdens, oBrwEmpres, oPnlEmp, oPnlOrdens, oBrwOPSC
   Private oBrwOpDst, oPnlOpOrg, oPnlOpDst

   /*
   +-------------- Arrays utilizados na folder Transferência ---------------------+
   +                                                                              +
   +--Array aTabNames                                                             +
   +------------------------------------------------------------------------------+
   + aTabNames[nI,1] - Empresa       "99"                                         +
   + aTabNames[nI,2] - Filial        "01"                                         +
   + aTabNames[nI,3] - Tabela        "SC1"                                        +
   + aTabNames[nI,4] - Nome tabela   "SC1990"                                     +
   + aTabNames[nI,5] - Filtro filial "01"                                         +
   +                                                                              +
   +--Array aTrans                                                                +
   +------------------------------------------------------------------------------+
   + aTrans[nI,1] - Empresa Origem  - "99/01"                                     +
   + aTrans[nI,2] - Produto         - "SKATE"                                     +
   + aTrans[nI,3] - Descricao       - "DESCRIÇÃO DO SKATE"                        +
   + aTrans[nI,4] - Quant. trans    - "500"                                       +
   + aTrans[nI,5] - Empresa Destino - "98/01"                                     +
   + aTrans[nI,6] - Flag para controlar a cor da linha - .T./.F.                  +
   +                                                                              +
   +--Array aSolic                                                                +
   +------------------------------------------------------------------------------+
   + aSolic[nI,1] - Empresa     - "99/01"                                         +
   + aSolic[nI,2] - Numero SC   - "000555"                                        +
   + aSolic[nI,3] - Item da SC  - "0001"                                          +
   + aSolic[nI,4] - Item grade  - "001"                                           +
   + aSolic[nI,5] - Qt tran     - "500"                                           +
   + aSolic[nI,6] - Data sc     - "11/09/2001"                                    +
   + aSolic[nI,7] - Situação    - "Não atendido/Atendido parcial/Atendido total"  +
   + aSolic[nI,8] - Qt Movto    - "100"                                           +
   + aSolic[nI,9] - Num OP Pai  - '00000101001'                                   +
   + aSolic[nI,9] - Flag para controlar a cor da linha - .T./.F.                  +
   +                                                                              +
   +--Array aFornec                                                               +
   +------------------------------------------------------------------------------+
   + aFornec[nI,1]  - Empresa         - "99/01"                                   +
   + aFornec[nI,2]  - OP              - "000001"                                  +
   + aFornec[nI,3]  - SC              - "000444"                                  +
   + aFornec[nI,4]  - Sequencia       - "001"                                     +
   + aFornec[nI,5]  - Item            - "01"                                      +
   + aFornec[nI,6]  - Item grade      - "001"                                     +
   + aFornec[nI,7]  - Quant OP/SC     - "500"                                     +
   + aFornec[nI,8]  - Quant estoque   - "100"                                     +
   + aFornec[nI,9]  - Quant Trans    - "100"                                      +
   + aFornec[nI,10] - Data transf     - "20/10/2010"                              +
   + aFornec[nI,11] - Flag para controlar a cor da linha - .T./.F.                +
   +                                                                              +
   +--------------- Fim Arrays utilizados na folder Transferência ----------------+
   +                                                                              +
   +--------------- Arrays utilizados na folder Centralizar ----------------------+
   +                                                                              +
   +--Array aProduto                                                              +
   +------------------------------------------------------------------------------+
   + aProduto[nI,1] - Código do produto    - "SKATE"                              +
   + aProduto[nI,2] - Descrição do produto - "DESCRIÇÃO DO SKATE"                 +
   +                                                                              +
   +--Array aOrdens                                                               +
   +------------------------------------------------------------------------------+
   + aOrdens[nI,1] - Empresa/Filial - "99/01 - TESTE/FILIAL01"                    +
   + aOrdens[nI,2] - OP             - "00001101001"                               +
   + aOrdens[nI,3] - SC             - "000111"                                    +
   + aOrdens[nI,4] - Quantidade     - "100"                                       +
   + aOrdens[nI,5] - Situacao       - "Firme/Prevista"                            +
   + aOrdens[nI,6] - Empresa        - "99" (controle interno)                     +
   + aOrdens[nI,7] - Filial         - "01" (controle interno)                     +
   +                                                                              +
   +--Array aEmpresas                                                             +
   +------------------------------------------------------------------------------+
   + aEmpresas[nI,1] - Empresa  - "99/01"                                         +
   + aEmpresas[nI,2] - Empresa  - "99" (controle interno)                         +
   + aEmpresas[nI,3] - Filial   - "01" (controle interno)                         +
   +                                                                              +
   +--Array aOpSc                                                                 +
   +------------------------------------------------------------------------------+
   + aOpSc[nI,1] - OP    - "00000102001"                                          +
   + aOpSc[nI,2] - SC    - "000111"                                               +
   + aOpSc[nI,3] - Quant - "500"                                                  +
   +                                                                              +
   +--Array aOrdensDst                                                            +
   +------------------------------------------------------------------------------+
   + aOrdensDst[nI,1] - Tipo            - "OP/SC"                                 +
   + aOrdensDst[nI,2] - Empresa origem  - "99/01"                                 +
   + aOrdensDst[nI,3] - Doc. origem     - "00000101001"                           +
   + aOrdensDst[nI,4] - Empresa destino - "98/01"                                 +
   + aOrdensDst[nI,5] - Doc. destino    - "00000201001"                           +
   + aOrdensDst[nI,6] - Quantidade      - "100"                                   +
   + aOrdensDst[nI,7] - Flag para controlar a cor da linha - .T./.F.              +
   +                                                                              +
   +--------------- Fim Arrays utilizados na folder Centralizar ------------------+
   +------------------------------------------------------------------------------+

   +-------------------------------------------------
   + mv_par01 - De produto?                         +
   + mv_par02 - Até produto?                        +
   + mv_par03 - Empresa origem de?                  +
   + mv_par04 - Empresa origem até?                 +
   + mv_par05 - Empresa destino de?                 +
   + mv_par06 - Empresa destino até?                +
   + mv_par07 - Número MRP de?                      +
   + mv_par08 - Número MRP até?                     +
   ------------------------------------------------*/
   
   /*
      Se já existir outro usuário executando o programa, executa permitindo somente consultar, bloqueando as operações de
      Centralizar, Alterar quantidades e excluir a tabela SOU.
   */
   nHandle := FCreate(cStartPath+"PCPA108.job")
   If nHandle < 0
      lConsulta := .T.
      Help( ,, 'PCPA108',, STR0051, 1, 0 )//"Este programa já está sendo executado por outro usuário, somente a consulta será habilitada."
   Else
      lConsulta := .F.
   EndIf

   /*
      Busca as empresas e carrega o nome da tabela e o campo filial de cada empresa
      para ser mais rápido nas validações da folder Centralizar.
      Só abre a tela quando finalizar os Jobs.
      Jobs iniciados nesta função, e a validação de termino é feita dentro da função PCPA108MTL, antes de fazer o Activate da tela.
   */

   cQuery := " SELECT DISTINCT SOR.OR_EMP, SOR.OR_FILEMP "
   cQuery +=  " FROM " + RetSqlName("SOR") + " SOR "
   
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   While (cAlias)->(!Eof())
      aAdd(aEmp,{(cAlias)->(OR_EMP),(cAlias)->(OR_FILEMP)})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   For nI := 1 To Len(aEmp)
      cNomJob := "A108EMP"+AllTrim(aEmp[nI,1])+AllTrim(aEmp[nI,2])
      PutGlbValue(cNomJob,"0")
      GlbUnLock()
      aAdd(a108Jobs,{cNomJob,aEmp[nI,1],aEmp[nI,2]})
      StartJob("A108VerEmp",GetEnvServer(),.F.,aEmp[nI,1],aEmp[nI,2],cNomJob)
   Next nI

   lContinua := lerPar()
   If lContinua
      If !lConsulta
         criaTemp()
      EndIf
   
      PCPA108MTL(a108Jobs)
   EndIf
   
   If !lConsulta
      FClose(nHandle)
   EndIf
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} lerPar
Faz a leitura dos parâmetros do pergunte PCPA108

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function lerPar()
   Local nRet := .T.

   nRet := Pergunte("PCPA108")
   If nRet
      cProdDe    := mv_par01
      cProdAte   := mv_par02
      cEmpOrgDe  := mv_par03
      cEmpOrgAte := mv_par04
      cEmpDstDe  := mv_par05
      cEmpDstAte := mv_par06
      cNumMrpDe  := mv_par07
      cNumMrpAte := mv_par08
   EndIf
Return nRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA108MTL
Monta a tela de consulta

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Function PCPA108MTL(a108Jobs)
   Local aButtons   := {}
   Local aTitles    := {STR0052,STR0053} //"Transferência"/"Centralizar"
   Local aPages     := {"HEADR1","HEADR2"}
   Local nI         := 0
   Local nRetry_0   := 0
   Local nRetry_1   := 0
   Local cTabName   := ""
   Local cFiltroFil := ""
   Local cTitulo    := ""
   Local oFolder
   
   If lConsulta
      cTitulo := AllTrim(STR0001) + STR0054 //"Consulta Sugestões de transferência (Somente consulta)"
   Else
      cTitulo := STR0001 //"Consulta Sugestões de transferência"
   EndIf

   oDlg := MSDialog():New( aTamanhos[1],aTamanhos[2],aTamanhos[3],aTamanhos[4],cTitulo,,,.F.,,,,,,.T.,,,.T. )

   //Cria o painel principal
   oPnlPai := TPanel():New(01,01,,oDlg,,,,,,,,.T.,.T.)
   oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

   //Cria o Folder
   oFolder := TFolder():New(0,0,aTitles,aPages,oPnlPai,,,,.T.,.F.,oPnlPai:nClientWidth*0.5,(oPnlPai:nClientHeight*0.5)-40,)  //Transferência  //Centralizar

   //INICIO FOLDER TRANSFERÊNCIAS
   //Cria o Layer
   oLayer := FWLayer():New()
   oLayer:Init(oFolder:aDialogs[1],.T.)

   oLayer:addCollumn("ColunaTree",22,.F.)
   oLayer:addCollumn("ColunaDado",78,.F.)

   oLayer:addWindow("ColunaTree",'C1_Win01',STR0002,100,.T.,.F.,{|| },,{|| }) //"Empresas"
   oLayer:addWindow("ColunaDado",'C2_Win01',STR0003,33,.T.,.F.,{|| },,{|| }) //"Transferências"
   oLayer:addWindow("ColunaDado",'C2_Win02',STR0004,34,.T.,.F.,{|| },,{|| }) //"Solicitante"
   oLayer:addWindow("ColunaDado",'C2_Win03',STR0005,33,.T.,.F.,{|| },,{|| }) //"Fornece"

   oPnlTree := oLayer:getWinPanel("ColunaTree",'C1_Win01')
   oLayer:setColSplit("ColunaTree",CONTROL_ALIGN_RIGHT,,{|| })
   
   oPnlTran  := oLayer:getWinPanel("ColunaDado",'C2_Win01')
   oPnlSolic := oLayer:getWinPanel("ColunaDado",'C2_Win02')
   oPnlFornec:= oLayer:getWinPanel("ColunaDado",'C2_Win03')
   
   criaTree()
   gridTrans()
   gridSolic()
   gridFornec()
   //FIM FOLDER TRANSFERÊNCIAS

   //INICIO FOLDER CENTRALIZAR
   oLayerCent := FWLayer():New()
   oLayerCent:Init(oFolder:aDialogs[2],.T.)

   oLayerCent:addCollumn("TUDO",100,.F.)

   oLayerCent:addWindow("TUDO",'C1_Win01',STR0034,40,.T.,.F.,{|| },,{|| }) //"Produtos"
   oLayerCent:addWindow("TUDO",'C1_Win02',STR0055,60,.T.,.F.,{|| },,{|| }) //"OP/SC"

   oPnlBaixo := TPanel():New(0,0,,oLayerCent:getWinPanel("TUDO",'C1_Win02'),,,,,,,,.T.,.T.)
   oPnlBaixo:Align := CONTROL_ALIGN_ALLCLIENT

   oPnlEsq := tPanel():New(0,0,"",oPnlBaixo,,,,,,(oPnlBaixo:nClientWidth/2)*0.6,oPnlBaixo:nClientHeight/2)
   oPnlEsq:Align := CONTROL_ALIGN_LEFT

   oPnlOpOrg := tPanel():New(0,0,"",oPnlEsq,,,,,,(oPnlEsq:nClientWidth/2),(oPnlEsq:nClientHeight/2)*0.5)
   oPnlOpOrg:Align := CONTROL_ALIGN_TOP

   oPnlOpDst := tPanel():New((oPnlEsq:nClientHeight/2)*0.5,0,"",oPnlEsq,,,,,,(oPnlEsq:nClientWidth/2),(oPnlEsq:nClientHeight/2)*0.5)
   oPnlOpDst:Align := CONTROL_ALIGN_LEFT

   oPnlCentr := tPanel():New(0,(oPnlBaixo:nClientWidth/2)*0.6,"",oPnlBaixo,,,,,,(oPnlBaixo:nClientWidth/2)*0.04,oPnlBaixo:nClientHeight/2)
   oPnlCentr:Align := CONTROL_ALIGN_LEFT

   oPnlDir := tPanel():New(0,(oPnlBaixo:nClientWidth/2)*0.64,"",oPnlBaixo,,,,,,(oPnlBaixo:nClientWidth/2)*0.36,oPnlBaixo:nClientHeight/2)
   oPnlDir:Align := CONTROL_ALIGN_LEFT
   
   oPnlEmp := tPanel():New(0,0,"",oPnlDir,,,,,,(oPnlDir:nClientWidth/2),(oPnlDir:nClientHeight/2)*0.5)
   oPnlEmp:Align := CONTROL_ALIGN_TOP

   oPnlOrdens := tPanel():New((oPnlDir:nClientHeight/2)*0.5,0,"",oPnlDir,,,,,,(oPnlDir:nClientWidth/2),(oPnlDir:nClientHeight/2)*0.5)
   oPnlOrdens:Align := CONTROL_ALIGN_LEFT

   gridProd(oLayerCent:getWinPanel("TUDO",'C1_Win01'))
   gridOpOrig()
   gridOpDst()
   btnTroca()
   gridEmpres()
   gridOPSC()
   //FIM FOLDER CENTRALIZAR
   If !lConsulta
      aAdd(aButtons,{'OK',{|| PCPA108ATU() }, STR0080}) //"Salvar"
   EndIf
   aAdd(aButtons,{'FILTRO',{|| novoFiltro() },STR0006})    // Consulta
   aAdd(aButtons,{'RELATORIO',{|| PCPA108REL()},STR0007}) // Relatório
   If !lConsulta
      aAdd(aButtons,{'EXCLUI',{|| excluiSou()},STR0008})    // Excluir
   EndIf

   //Faz a busca dos dados.
   Processa( {|| buscaDados(.T.) }, STR0036 /*"Aguarde..."*/, STR0038/*"Executando consulta..."*/,.F.)

   //Verifica o job de retorno dos nomes de tabelas e filiais
   For nI := 1 To Len(a108Jobs)
      While .T.
         Do Case
         Case GetGlbValue(a108Jobs[nI,1]) == '0'
            If nRetry_0 > 50
               //Conout(Replicate("-",65))
               //Conout("Nao foi possivel realizar a subida da thread "+a108Jobs[nI,1]) //"Nao foi possivel realizar a subida da thread "
               //Conout(Replicate("-",65))
               Final("Nao foi possivel realizar a subida da thread "+a108Jobs[nI,1]) //"Nao foi possivel realizar a subida da thread "
             Else
               nRetry_0 ++
            EndIf
         
         //Tratamento para erro de conexao
         Case GetGlbValue(a108Jobs[nI,1]) == '10'
            If nRetry_1 > 10
               //Conout(Replicate("-",65))
               //Conout("Erro de conexao na thread "+a108Jobs[nI,1])   //"Erro de conexao na thread "
               //Conout("Numero de tentativas excedido")               // "Numero de tentativas excedido"
               //Conout(Replicate("-",65))
               Final("Erro de conexao na thread "+a108Jobs[nI,1])    //"Erro de conexao na thread "
            Else
               //Inicializa variavel global de controle de Job
               PutGlbValue(a108Jobs[nI,1],"0")
               GlbUnLock()
               
               //Reiniciar thread
               //Conout(Replicate("-",65))
               //Conout("Erro de conexao na thread "+a108Jobs[nI,1])         //"Erro de conexao na thread "
               //Conout("Reiniciando a thread : "+a108Jobs[nI,1])
               //Conout("Tentativa numero: "+StrZero(nRetry_1,2)) //"Tentativa numero: "
               //Conout(Replicate("-",65))
               StartJob("A108VerEmp",GetEnvServer(),.F.,a108Jobs[nI,2],a108Jobs[nI,3],a108Jobs[nI,1])
            EndIf
            nRetry_1 ++
         
         Case GetGlbValue(a108Jobs[nI,1]) == '20'
            //Conout(Replicate("-",65))
            //Conout("Erro na execucao da thread"+a108Jobs[nI,1])         //"Erro na execucao da thread"
            //Conout(Replicate("-",65))
            Final("Erro na execucao da thread "+a108Jobs[nI,1])
         
         Case GetGlbValue(a108Jobs[nI,1]) == '30'
            //Conout(Replicate("-",65))                             
            //Conout("PCPA108: Erro de aplicacao na thread " + a108Jobs[nI,1])          
            //Conout(Replicate("-",65))                                
            
            //Atualiza o log de processamento             
            Final("PCPA108: Erro de aplicacao na thread"+GetGlbValue(AllTrim(AllTrim(a108Jobs[nI,1])+"ERRO")))

         //THREAD PROCESSADA CORRETAMENTE
         Case GetGlbValue(a108Jobs[nI,1]) == '3'
            //Conout("Job "+ a108Jobs[nI,1] +" executado com sucesso.")
            cTabName   := GetGlbValue(a108Jobs[nI,1]+"C1NM")
            cFiltroFil := GetGlbValue(a108Jobs[nI,1]+"C1FL")
            aAdd(aTabNames,{a108Jobs[nI,2],a108Jobs[nI,3],"SC1",cTabName,cFiltroFil})
            cTabName   := GetGlbValue(a108Jobs[nI,1]+"C2NM")
            cFiltroFil := GetGlbValue(a108Jobs[nI,1]+"C2FL")
            aAdd(aTabNames,{a108Jobs[nI,2],a108Jobs[nI,3],"SC2",cTabName,cFiltroFil})
            ClearGlbValue (a108Jobs[nI,1])
            Exit
         EndCase
         Sleep(500)
      End
   Next nI

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End()},{|| fechaProg(oDlg)},,aButtons,/*nRecno*/,/*cAlias*/,.F.,.F.,.F.,.F.,.F.) CENTERED
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} fechaProg
Função executada na ação Cancelar do menu

@author Lucas Konrad França
@since 10/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function fechaProg(oDialog)
   Local lContinua := .T.
   If !lConsulta .And. verAlterac()
      lContinua := MsgYesNo(STR0056,STR0057) //"Foram realizadas alterações nas informações consultadas, deseja continuar e descartar as alterações?","Continua?"
   EndIf
   If lContinua
      oDialog:End()
   EndIf
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} criaTree
Monta a tree da tela de consulta

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function criaTree()
   oTree := DbTree():New( 0, 0, (aTamanhos[3]/2), ((aTamanhos[4]/2)*0.2), oPnlTree , , , .T. )

   oTree:Align    := CONTROL_ALIGN_ALLCLIENT
   oTree:bChange := {|| ChangeTree()}
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} novoFiltro
Refaz a consulta com novos filtros

@author Lucas Konrad França
@since 10/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function novoFiltro()
   Local lContinua := .T.
   If !lConsulta .And. verAlterac()
      lContinua := MsgYesNo(STR0056,STR0057) //"Foram realizadas alterações nas informações consultadas, deseja continuar e descartar as alterações?","Continua?"
   EndIf

   If lContinua
      If lerPar()
         If !lConsulta
            limpaTemp()
         EndIf
         
         Processa( {|| buscaDados(.T.) },STR0036 /*"Aguarde..."*/, STR0038/*"Executando consulta..."*/,.F.)
      EndIf
   EndIf
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} verAlterac
Verifica se foi realizada alguma alteração nas informações consultadas.

@author Lucas Konrad França
@since 10/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function verAlterac()
   Local cQuery := ""
   Local aArea  := GetArea()
   Local cAlias := GetNextAlias()
   Local lRet   := .F.
   
   cQuery := " SELECT COUNT(*) TOTAL "
   cQuery +=   " FROM ( SELECT EMPORIG "
   cQuery +=            " FROM A108QT "
   cQuery +=          " UNION ALL "
   cQuery +=          " SELECT EMPORIG "
   cQuery +=            " FROM A108DC ) t"

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   If (cAlias)->(!Eof()) .And. (cAlias)->(TOTAL) > 0
      lRet := .T.
   EndIf

   (cAlias)->(dbCloseArea())

   RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} ChangeTree
Evento de mudança da tree

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function ChangeTree()
   
   If !Empty(oTree:CurrentNodeId) .And. cLastNode != oTree:CurrentNodeId .And. SubStr(oTree:CurrentNodeId,1,4) == "item"
      cLastNode := oTree:CurrentNodeId
      cNrMrp  := SubStr(oTree:CurrentNodeId,5,6)
      cEmpOrg := SubStr(oTree:CurrentNodeId,11,2)
      cFilOrg := SubStr(oTree:CurrentNodeId,14,Len(AllTrim(oTree:CurrentNodeId))-13)
      cargaTrans()
   EndIf
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} gridTrans
Monta a grid para exibição dos dados de transferência.

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function gridTrans()
   Local aHeaders := {}
   Local aAlter   := {}
   Local nX       := 0
   Local cTitulo  := ""
   Local nTamanho := 0
   Local nDecimal := 0
   Local cValid   := ""

   cTitulo  := STR0009 //"Origem"
   nTamanho := 15
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_FILORIG",GetSx3Cache("OU_FILORIG",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_FILORIG",'X3_USADO'),GetSx3Cache("OU_FILORIG",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_FILORIG",'X3_CONTEXT')})

   cTitulo  := STR0010 //"Produto"
   nTamanho := GetSx3Cache("OU_PROD",'X3_TAMANHO')
   nDecimal := GetSx3Cache("OU_PROD",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_PROD",GetSx3Cache("OU_PROD",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_PROD",'X3_USADO'),GetSx3Cache("OU_PROD",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_PROD",'X3_CONTEXT')})

   cTitulo  := STR0011 //"Descrição do produto"
   nTamanho := GetSx3Cache("B1_DESC",'X3_TAMANHO')
   nDecimal := GetSx3Cache("B1_DESC",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"B1_DESC",GetSx3Cache("B1_DESC",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("B1_DESC",'X3_USADO'),GetSx3Cache("B1_DESC",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("B1_DESC",'X3_CONTEXT')})

   cTitulo  := STR0012 //"Qtd. Transf."
   nTamanho := GetSx3Cache("OU_QTPROD",'X3_TAMANHO')
   nDecimal := GetSx3Cache("OU_QTPROD",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_QTPROD",GetSx3Cache("OU_QTPROD",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_QTPROD",'X3_USADO'),GetSx3Cache("OU_QTPROD",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_QTPROD",'X3_CONTEXT')})

   cTitulo  := STR0013 //"Destino"
   nTamanho := 15
   nDecimal := GetSx3Cache("OU_FILDEST",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_FILDEST",GetSx3Cache("OU_FILDEST",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_FILDEST",'X3_USADO'),GetSx3Cache("OU_FILDEST",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_FILDEST",'X3_CONTEXT')})

   aAdd(aTrans, Array(Len(aHeaders)+1))
   For nX := 1 To Len(aHeaders)
      aTrans[Len(aTrans)][nX] := CriaVar(aHeaders[nX][2])
   Next nX
   aTrans[Len(aTrans)][Len(aHeaders)+1] := .F.

   oBrwTrans := MsNewGetDados():New(001,001,oPnlTran:nClientHeight*0.50,oPnlTran:nClientWidth*0.50,GD_UPDATE,,,,aAlter,0,1000,,,"AllwaysFalse",oPnlTran,aHeaders,aTrans,{|| cargaSolic(),oBrwTrans:Refresh()})
   oBrwTrans:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oBrwTrans:oBrowse:lUseDefaultColors := .F.
   oBrwTrans:oBrowse:SetBlkBackColor({|| GETDCLR(oBrwTrans:aCols,oBrwTrans:nAt)})
   oBrwTrans:oBrowse:SetBlkColor( { || RGB(0,0,0) } )
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} gridSolic
Monta a grid para exibição dos dados de transferência do solicitante.

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function gridSolic()
   Local aHeaders := {}
   Local aAlter   := {}
   Local nX       := 0
   Local cTitulo  := ""
   Local nTamanho := 0
   Local nDecimal := 0
   Local cValid   := ""

   If !lConsulta
      aAlter := {'OU_SITUACA','OU_QTMOVTO'}
   EndIf

   cTitulo  := STR0014 //"Empresa/Filial"
   nTamanho := 15
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_FILORIG",GetSx3Cache("OU_FILORIG","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_FILORIG","X3_USADO"),GetSx3Cache("OU_FILORIG","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_FILORIG","X3_CONTEXT")})  

   cTitulo  := STR0015 //"Solicitação Compra"
   nTamanho := GetSx3Cache("OU_SCSOLIC","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_SCSOLIC","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_SCSOLIC",GetSx3Cache("OU_SCSOLIC","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_SCSOLIC","X3_USADO"),GetSx3Cache("OU_SCSOLIC","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_SCSOLIC","X3_CONTEXT")})  

   cTitulo  := GetSx3Cache("OU_ITEMSC","X3_TITULO")
   nTamanho := GetSx3Cache("OU_ITEMSC","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_ITEMSC","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_ITEMSC",GetSx3Cache("OU_ITEMSC","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_ITEMSC","X3_USADO"),GetSx3Cache("OU_ITEMSC","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_ITEMSC","X3_CONTEXT")})  

   cTitulo  := GetSx3Cache("OU_ITGRDSC","X3_TITULO")
   nTamanho := GetSx3Cache("OU_ITGRDSC","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_ITGRDSC","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_ITGRDSC",GetSx3Cache("OU_ITGRDSC","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_ITGRDSC","X3_USADO"),GetSx3Cache("OU_ITGRDSC","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_ITGRDSC","X3_CONTEXT")})  

   cTitulo  := STR0016 //"Quantidade"
   nTamanho := GetSx3Cache("OU_QTPROD","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_QTPROD","X3_DECIMAL")
   cValid   := GetSx3Cache("OU_QTPROD","X3_VALID")
   aAdd(aHeaders,{cTitulo,"OU_QTPROD",GetSx3Cache("OU_QTPROD","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_QTPROD","X3_USADO"),GetSx3Cache("OU_QTPROD","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_QTPROD","X3_CONTEXT")})  

   cTitulo  := STR0017 //"Data necess"
   nTamanho := GetSx3Cache("OU_DTTRANS","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_DTTRANS","X3_DECIMAL")
   cValid   := GetSx3Cache("OU_DTTRANS","X3_VALID")
   aAdd(aHeaders,{cTitulo,"OU_DTTRANS","",nTamanho,nDecimal,cValid,GetSx3Cache("OU_DTTRANS","X3_USADO"),GetSx3Cache("OU_DTTRANS","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_DTTRANS","X3_CONTEXT")})  

   cTitulo  := GetSx3Cache("OU_SITUACA","X3_TITULO")
   nTamanho := GetSx3Cache("OU_SITUACA","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_SITUACA","X3_DECIMAL")
   cValid   := "a108VldCpo(M->OU_SITUACA)"
   aAdd(aHeaders,{cTitulo,"OU_SITUACA",GetSx3Cache("OU_SITUACA","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_SITUACA","X3_USADO"),GetSx3Cache("OU_SITUACA","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_SITUACA","X3_CONTEXT")})  

   cTitulo  := GetSx3Cache("OU_QTMOVTO","X3_TITULO")
   nTamanho := GetSx3Cache("OU_QTMOVTO","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_QTMOVTO","X3_DECIMAL")
   cValid   := "a108VldCpo(M->OU_QTMOVTO)"
   aAdd(aHeaders,{cTitulo,"OU_QTMOVTO",GetSx3Cache("OU_QTMOVTO","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_QTMOVTO","X3_USADO"),GetSx3Cache("OU_QTMOVTO","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_QTMOVTO","X3_CONTEXT")})  

	/*Ordem Pai*/
   cTitulo  := STR0081
   nTamanho := GetSx3Cache("C1_OP","X3_TAMANHO")
   nDecimal := GetSx3Cache("C1_OP","X3_DECIMAL")
   cValid   := "a108VldCpo(M->OU_QTMOVTO)"
	aAdd(aHeaders,{cTitulo,"C1_OP",GetSx3Cache("C1_OP","X3_PICTURE"),nTamanho,nDecimal,GetSx3Cache("C1_OP","X3_VALID"),GetSx3Cache("C1_OP","X3_USADO"),GetSx3Cache("C1_OP","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("C1_OP","X3_CONTEXT")})

   aAdd(aSolic, Array(Len(aHeaders)+2))
   For nX := 1 To Len(aHeaders)
      aSolic[Len(aSolic)][nX] := CriaVar(aHeaders[nX][2])
   Next nX
   aSolic[Len(aSolic)][Len(aHeaders)+1] := .F.
   aSolic[Len(aSolic)][Len(aHeaders)+2] := .F.

   oBrwSolic := MsNewGetDados():New(001,001,oPnlSolic:nClientHeight*0.50,oPnlSolic:nClientWidth*0.50,GD_UPDATE,,,,aAlter,0,1000,,,"AllwaysFalse",oPnlSolic,aHeaders,aSolic,{|| changeSolic(oBrwSolic:nAt),oBrwSolic:Refresh()})
   oBrwSolic:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oBrwSolic:oBrowse:lUseDefaultColors := .F.
   oBrwSolic:oBrowse:SetBlkBackColor({|| GETDCLR(oBrwSolic:aCols,oBrwSolic:nAt)})
   oBrwSolic:oBrowse:SetBlkColor( { || RGB(0,0,0) } )
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} GETDCLR
Monta a cor da linha selecionada na grid Fornece

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function GETDCLR(aLinha,nLinha)
Local nCor2 := RGB(191,213,231)
Local nCor3 := 16777215 // Branco - RGB(255,255,255)
Local nRet := nCor3
If aLinha[nLinha][Len(aLinha[nLinha])]
     nRet := nCor2
Else
     nRet := nCor3
Endif
Return nRet

//-----------------------------------------------------------------
/*/{Protheus.doc} gridFornec
Monta a grid para exibição dos dados de transferência do fornecedor.

@author Lucas Konrad França
@since 07/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function gridFornec()
   Local aHeaders := {}
   Local aAlter   := {}
   Local nX       := 0
   Local cTitulo  := ""
   Local nTamanho := 0
   Local nDecimal := 0
   Local cValid   := ""

   cTitulo  := STR0014 //"Empresa/Filial"
   nTamanho := 15
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_FILORIG",GetSx3Cache("OU_FILORIG","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_FILORIG","X3_USADO"),GetSx3Cache("OU_FILORIG","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_FILORIG","X3_CONTEXT")})

   cTitulo  := STR0018 //"Ordem produção"
   nTamanho := GetSx3Cache("OU_OPPROD","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_OPPROD","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_OPPROD",GetSx3Cache("OU_OPPROD","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_OPPROD","X3_USADO"),GetSx3Cache("OU_OPPROD","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_OPPROD","X3_CONTEXT")})

   cTitulo  := STR0015 //"Solicitação compra"
   nTamanho := GetSx3Cache("OU_SCSOLIC","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_SCSOLIC","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_SCSOLIC",GetSx3Cache("OU_SCSOLIC","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_SCSOLIC","X3_USADO"),GetSx3Cache("OU_SCSOLIC","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_SCSOLIC","X3_CONTEXT")})

   cTitulo  := STR0019 //"Sequência"
   nTamanho := GetSx3Cache("OU_C2SEQ","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_C2SEQ","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_C2SEQ",GetSx3Cache("OU_C2SEQ","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_C2SEQ","X3_USADO"),GetSx3Cache("OU_C2SEQ","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_C2SEQ","X3_CONTEXT")})

   cTitulo  := STR0020 //"Item"
   nTamanho := GetSx3Cache("OU_ITEMOP","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_ITEMOP","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_ITEMOP",GetSx3Cache("OU_ITEMOP","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_ITEMOP","X3_USADO"),GetSx3Cache("OU_ITEMOP","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_ITEMOP","X3_CONTEXT")})

   cTitulo  := STR0021 //"Item"
   nTamanho := GetSx3Cache("OU_ITGRDOP","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_ITGRDOP","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_ITGRDOP",GetSx3Cache("OU_ITGRDOP","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_ITGRDOP","X3_USADO"),GetSx3Cache("OU_ITGRDOP","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_ITGRDOP","X3_CONTEXT")})

   cTitulo  := STR0058 //"'Qtd. OP/SC'"
   nTamanho := GetSx3Cache("OU_QTPROD","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_QTPROD","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_QTPROD",GetSx3Cache("OU_QTPROD","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_QTPROD","X3_USADO"),GetSx3Cache("OU_QTPROD","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_QTPROD","X3_CONTEXT")})

   cTitulo  := STR0059 //'Qtd. Estoque'
   nTamanho := GetSx3Cache("OU_QTEST","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_QTEST","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_QTEST",GetSx3Cache("OU_QTEST","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_QTEST","X3_USADO"),GetSx3Cache("OU_QTEST","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_QTEST","X3_CONTEXT")})

   cTitulo  := STR0060 //'Qtd. Transferência'
   nTamanho := GetSx3Cache("OU_QTMOVTO","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_QTMOVTO","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_QTMOVTO",GetSx3Cache("OU_QTMOVTO","X3_PICTURE"),nTamanho,nDecimal,cValid,GetSx3Cache("OU_QTMOVTO","X3_USADO"),GetSx3Cache("OU_QTMOVTO","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_QTMOVTO","X3_CONTEXT")})

   cTitulo  := STR0023 //'Dt transferência'
   nTamanho := GetSx3Cache("OU_DTTRANS","X3_TAMANHO")
   nDecimal := GetSx3Cache("OU_DTTRANS","X3_DECIMAL")
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_DTTRANS","",nTamanho,nDecimal,cValid,GetSx3Cache("OU_DTTRANS","X3_USADO"),GetSx3Cache("OU_DTTRANS","X3_TIPO"), /*SX3->x3_arquivo*/, GetSx3Cache("OU_DTTRANS","X3_CONTEXT")})

   aAdd(aFornec, Array(Len(aHeaders)+1))
   For nX := 1 To Len(aHeaders)
      aFornec[Len(aFornec)][nX] := CriaVar(aHeaders[nX][2])
   Next nX
   aFornec[Len(aFornec)][Len(aHeaders)+1] := .F.

   oBrwFornec := MsNewGetDados():New(001,001,oPnlFornec:nClientHeight*0.50,oPnlFornec:nClientWidth*0.50,GD_UPDATE,,,,aAlter,0,1000,,,"AllwaysFalse",oPnlFornec,aHeaders,aFornec,{|| changeColor(oBrwFornec:nAt,oBrwFornec),oBrwFornec:Refresh()})
   oBrwFornec:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oBrwFornec:oBrowse:lUseDefaultColors := .F.
   oBrwFornec:oBrowse:SetBlkBackColor({|| GETDCLR(oBrwFornec:aCols,oBrwFornec:nAt)})
   oBrwFornec:oBrowse:SetBlkColor( { || RGB(0,0,0) } )
Return Nil

Static Function changeColor(nLinha,oBrowse)
   Local nI := 0

   //Flag para mudar a cor da linha selecionada
   For nI := 1 To Len(oBrowse:aCols)
      oBrowse:aCols[nI,Len(oBrowse:aCols[nI])] := .F.
   Next nI
   oBrowse:aCols[nLinha,Len(oBrowse:aCols[nLinha])] := .T.
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA108SM0
Consulta específica dos grupos de empresa.

@author Lucas Konrad França
@since 13/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Function PCPA108SM0()
   Local aCpos := {}
   Local oDlg
   Local oLbx
   
   SM0->(dbGotop())
   While !SM0->(EOF())
      If !SM0->(Deleted()) .And. aScan(aCpos,{|x| x[1] == AllTrim(SM0->M0_CODIGO)}) == 0
            aAdd(aCpos, {AllTrim(SM0->M0_CODIGO),AllTrim(SM0->M0_NOME)})
      EndIf
      SM0->(dbSkip())
   End

   DEFINE MSDIALOG oDlg TITLE STR0024 FROM 0,0 TO 240,500 PIXEL//"Grupo de Empresas"

   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0025,STR0026  SIZE 230,95 OF oDlg PIXEL//"Empresa","Desc Empresa"

   oLbx:SetArray( aCpos )
   oLbx:bLine      := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
   oLbx:bLDblClick := {|| oDlg:End(), cEmpRet := oLbx:aArray[oLbx:nAt,1] }

   DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), cEmpRet := oLbx:aArray[oLbx:nAt,1])  ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} a108RetEmp
Função de retorno da consulta específica dos grupos de empresa.

@author Lucas Konrad França
@since 13/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Function a108RetEmp()
Return cEmpRet

//-----------------------------------------------------------------
/*/{Protheus.doc} gridProd
Cria a grid de produtos da folder Centraliza

@param oPanel - Painel onde a grid será criada.

@author Lucas Konrad França
@since 02/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function gridProd(oPanel)
   Local aHeaders  := {}
   Local aColSizes := {}
   
   If Len(aProduto) < 1
      aAdd(aProduto,{'',''})
   EndIf

   aAdd(aHeaders,STR0061) //Código
   aAdd(aColSizes,100)
   aAdd(aHeaders,STR0062) // Descrição
   aAdd(aColSizes,65)

   oBrwProd := TCBrowse():New(01,01,300,150,/*bLine*/,aHeaders,aColSizes,oPanel,,,,/*bChange*/{|| buscaDocum() },,,,,,,,,,.T.,,,,.T.,.T. )
   oBrwProd:Align := CONTROL_ALIGN_ALLCLIENT

   oBrwProd:SetArray(aProduto)
   oBrwProd:bLine := {||{ aProduto[oBrwProd:nAT,1],;
                          aProduto[oBrwProd:nAt,2]}}
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} gridOpOrig
Cria a grid de OPs/SCs da folder Centraliza

@author Lucas Konrad França
@since 03/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function gridOpOrig()
   Local aHeaders := {}
   Local aAlter   := {}
   Local nX       := 0
   Local cTitulo  := ""
   Local nTamanho := 0
   Local nDecimal := 0
   Local cValid   := ""
   Local nTamNum  := TamSX3("C2_NUM")[1]
   Local nTamItm  := TamSX3("C2_ITEM")[1]
   Local nTamSeq  := TamSX3("C2_SEQUEN")[1]

   cTitulo  := STR0014 //"Empresa/Filial"
   nTamanho := 30
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_FILORIG",GetSx3Cache("OU_FILORIG",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_FILORIG",'X3_USADO'),GetSx3Cache("OU_FILORIG",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_FILORIG",'X3_CONTEXT')})

   cTitulo  := STR0018 //"Ordem produção"
   nTamanho := nTamNum+nTamItm+nTamSeq
   nDecimal := GetSx3Cache("OU_OPPROD",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_OPPROD",GetSx3Cache("OU_OPPROD",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_OPPROD",'X3_USADO'),GetSx3Cache("OU_OPPROD",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_OPPROD",'X3_CONTEXT')})

   cTitulo  := STR0015 //"Solicitação compra"
   nTamanho := GetSx3Cache("OU_SCSOLIC",'X3_TAMANHO')
   nDecimal := GetSx3Cache("OU_SCSOLIC",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_SCSOLIC",GetSx3Cache("OU_SCSOLIC",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_SCSOLIC",'X3_USADO'),GetSx3Cache("OU_SCSOLIC",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_SCSOLIC",'X3_CONTEXT')})

   cTitulo  := STR0016 //"Quantidade"
   nTamanho := GetSx3Cache("OU_QTPROD",'X3_TAMANHO')
   nDecimal := GetSx3Cache("OU_QTPROD",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_QTPROD",GetSx3Cache("OU_QTPROD",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_QTPROD",'X3_USADO'),GetSx3Cache("OU_QTPROD",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_QTPROD",'X3_CONTEXT')})

   cTitulo  := STR0045 //"Situação"
   nTamanho := GetSx3Cache("C2_TPOP",'X3_TAMANHO')
   nDecimal := GetSx3Cache("C2_TPOP",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"C2_TPOP",GetSx3Cache("C2_TPOP",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("C2_TPOP",'X3_USADO'),GetSx3Cache("C2_TPOP",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("C2_TPOP",'X3_CONTEXT')})

   aAdd(aOrdens, Array(Len(aHeaders)+3))
   For nX := 1 To Len(aHeaders)
      aOrdens[Len(aOrdens)][nX] := CriaVar(aHeaders[nX][2])
   Next nX
   aOrdens[Len(aOrdens)][Len(aHeaders)+1] := ' '
   aOrdens[Len(aOrdens)][Len(aHeaders)+2] := ' '
   aOrdens[Len(aOrdens)][Len(aHeaders)+3] := .F.

   oBrwOrdens := MsNewGetDados():New(001,001,oPnlOpOrg:nClientHeight*0.50,oPnlOpOrg:nClientWidth*0.50,GD_UPDATE,,,,aAlter,0,1000,,,"AllwaysFalse",oPnlOpOrg,aHeaders,aOrdens,{|| changeColor(oBrwOrdens:nAt,oBrwOrdens),oBrwOrdens:Refresh()})
   oBrwOrdens:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oBrwOrdens:oBrowse:lUseDefaultColors := .F.
   oBrwOrdens:oBrowse:SetBlkBackColor({|| GETDCLR(oBrwOrdens:aCols,oBrwOrdens:nAt)})
   oBrwOrdens:oBrowse:SetBlkColor( { || RGB(0,0,0) } )
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} gridOpDst
Cria a grid de OPs/SCs da folder Centraliza

@author Lucas Konrad França
@since 22/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function gridOpDst()
   Local aHeaders := {}
   Local aAlter   := {}
   Local nX       := 0
   Local cTitulo  := ""
   Local nTamanho := 0
   Local nDecimal := 0
   Local cValid   := ""
   Local nTamNum  := TamSX3("C2_NUM")[1]
   Local nTamItm  := TamSX3("C2_ITEM")[1]
   Local nTamSeq  := TamSX3("C2_SEQUEN")[1]

   cTitulo  := STR0075 //"Tipo"
   nTamanho := 2
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OQ_FILEMP",GetSx3Cache("OQ_FILEMP",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OQ_FILEMP",'X3_USADO'),GetSx3Cache("OQ_FILEMP",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OQ_FILEMP",'X3_CONTEXT')})

   cTitulo  := STR0076  //"Empresa origem"
   nTamanho := 14
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OQ_EMP",GetSx3Cache("OQ_EMP",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OQ_EMP",'X3_USADO'),GetSx3Cache("OQ_EMP",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OQ_EMP",'X3_CONTEXT')})

   cTitulo  := STR0078 //"Doc. origem"
   nTamanho := 12
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OQ_DOC",GetSx3Cache("OQ_DOC",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OQ_DOC",'X3_USADO'),GetSx3Cache("OQ_DOC",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OQ_DOC",'X3_CONTEXT')})

   cTitulo  := STR0077//"Empresa destino"
   nTamanho := 14
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OR_EMP",GetSx3Cache("OR_EMP",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OR_EMP",'X3_USADO'),GetSx3Cache("OR_EMP",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OR_EMP",'X3_CONTEXT')})

   cTitulo  := STR0079 //"Doc. destino"
   nTamanho := 12
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OQ_DOCKEY",GetSx3Cache("OQ_DOCKEY",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OQ_DOCKEY",'X3_USADO'),GetSx3Cache("OQ_DOCKEY",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OQ_DOCKEY",'X3_CONTEXT')})

   cTitulo  := STR0033 //"Quantidade"
   nTamanho := GetSx3Cache("OQ_QUANT",'X3_TAMANHO')
   nDecimal := GetSx3Cache("OQ_QUANT",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OQ_QUANT",GetSx3Cache("OQ_QUANT",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OQ_QUANT",'X3_USADO'),GetSx3Cache("OQ_QUANT",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OQ_QUANT",'X3_CONTEXT')})

   aAdd(aOrdensDst, Array(Len(aHeaders)+1))
   For nX := 1 To Len(aHeaders)
      aOrdensDst[Len(aOrdensDst)][nX] := CriaVar(aHeaders[nX][2])
   Next nX
   aOrdensDst[Len(aOrdensDst)][Len(aHeaders)+1] := .F.

   oBrwOpDst := MsNewGetDados():New(001,001,oPnlOpDst:nClientHeight*0.50,oPnlOpDst:nClientWidth*0.50,GD_UPDATE,,,,aAlter,0,1000,,,"AllwaysFalse",oPnlOpDst,aHeaders,aOrdensDst,{|| changeColor(oBrwOpDst:nAt,oBrwOpDst),oBrwOpDst:Refresh()})
   oBrwOpDst:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oBrwOpDst:oBrowse:lUseDefaultColors := .F.
   oBrwOpDst:oBrowse:SetBlkBackColor({|| GETDCLR(oBrwOpDst:aCols,oBrwOpDst:nAt)})
   oBrwOpDst:oBrowse:SetBlkColor( { || RGB(0,0,0) } )
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} btnTroca
Cria a grid de Empresas da folder Centraliza

@author Lucas Konrad França
@since 03/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function btnTroca()

   @ 25, 10 BTNBMP oBtUp01 Resource "RIGHT"  Size 29,29 Pixel Of oPnlCentr Noborder Pixel Action moveDoc("ADD")
   oBtUp01:cToolTip := STR0063 // "Adicionar selecionado"
   @ 60, 10 BTNBMP oBtUp02 Resource "LEFT"   Size 29,29 Pixel Of oPnlCentr Noborder Pixel Action moveDoc("RMV")
   oBtUp02:cToolTip := STR0064 //"Remover selecionado"
   @ 95, 10 BTNBMP oBtUp03 Resource "PGNEXT" Size 29,29 Pixel Of oPnlCentr Noborder Pixel Action moveDoc("ADDALL")
   oBtUp03:cToolTip := STR0065 //"Adicionar todos"
   @ 130, 10 BTNBMP oBtUp04 Resource "PGPREV" Size 29,29 Pixel Of oPnlCentr Noborder Pixel Action moveDoc("RMVALL")
   oBtUp04:cToolTip := STR0066 //"Remover todos"

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} moveDoc
Movimenta as ops/scs entre as empresas

@param cFuncao - Identifica qual operação está sendo feita.

@author Lucas Konrad França
@since 09/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function moveDoc(cFuncao)
   Local nLinDoc  := oBrwOrdens:nAt
   Local nLinOpSc := oBrwOPSC:nAt
   Local lAlterou := .F.
   Local nI       := 0
   
   If !lConsulta
      If cFuncao == "ADD"
         If validaDoc(nLinDoc,.T.)
            insereDoc(nLinDoc)
            lAlterou := .T.
         EndIf
      EndIf
      If cFuncao == "ADDALL"
         For nI := 1 To Len(aOrdens)
            If validaDoc(nI,.F.)
               insereDoc(nI)
               lAlterou := .T.
            EndIf
         Next nI
      EndIf
      If cFuncao == "RMV"
         deletaDoc(nLinOpSc)
         lAlterou := .T.
      EndIf
      If cFuncao == "RMVALL"
         For nI := 1 To Len(aOpSc)
            deletaDoc(nI)
         Next nI
         lAlterou := .T.
      EndIf

      If lAlterou
         buscaDocum()
      EndIf
   EndIf
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} insereDoc
Insere um documento na temp de documentos movimentados

@param nLinDoc - Linha da grid Documentos

@author Lucas Konrad França
@since 10/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function insereDoc(nLinDoc)
   Local cQuery   := ""
   Local aArea    := GetArea()
   Local cAlias   := GetNextAlias()
   Local nRec     := 0
   Local nLinDest := oBrwEmpres:nAt
   Local nLinPrd  := oBrwProd:nAt
   Local nRet     := 0

   cQuery := " SELECT MAX(R_E_C_N_O_) REC "
   cQuery +=   " FROM A108DC "

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   If (cAlias)->(!Eof())
      nRec := (cAlias)->(REC) + 1
   Else
      nRec := 1
   EndIf

   cQuery := " INSERT INTO A108DC(EMPORIG, "
   cQuery +=                    " FILORIG, "
   cQuery +=                    " EMPDEST, "
   cQuery +=                    " FILDEST, "
   cQuery +=                    " PRODUTO, "
   cQuery +=                    " NUMOP, "
   cQuery +=                    " NUMSC, "
   cQuery +=                    " QUANT, "
   cQuery +=                    " R_E_C_N_O_) "
   cQuery +=            " VALUES('"+aOrdens[nLinDoc,6]+"', "
   cQuery +=                    "'"+aOrdens[nLinDoc,7]+"', "
   cQuery +=                    "'"+aEmpresas[nLinDest,2]+"', "
   cQuery +=                    "'"+aEmpresas[nLinDest,3]+"', "
   cQuery +=                    "'"+aProduto[nLinPrd,1]+"', "
   cQuery +=                    "'"+aOrdens[nLinDoc,2]+"', "
   cQuery +=                    "'"+aOrdens[nLinDoc,3]+"', "
   cQuery +=                        cValToChar(aOrdens[nLinDoc,4])+", "
   cQuery +=                        cValToChar(nRec) + " ) "

   If TCSQLExec(cQuery) < 0
      Alert(TCSQLError())
   EndIf

   RestArea(aArea)
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} insereDoc
Deleta um documento na temp de documentos movimentados

@author Lucas Konrad França
@since 10/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function deletaDoc(nLinOpSc)
   Local nLinEmp  := oBrwEmpres:nAt
   Local nLinProd := oBrwProd:nAt
   Local cSql     := ""
   Local aArea    := GetArea()

   cSql := " DELETE FROM A108DC "
   cSql +=  " WHERE EMPDEST = '" + aEmpresas[nLinEmp,2] + "' "
   cSql +=    " AND FILDEST = '" + aEmpresas[nLinEmp,3] + "' "
   cSql +=    " AND PRODUTO = '" + aProduto[nLinProd,1] + "' "
   cSql +=    " AND NUMOP   = '" + aOpSc[nLinOpSc,1] + "' "
   cSql +=    " AND NUMSC   = '" + aOpSc[nLinOpSc,2] + "' "
   
   If TCSQLExec(cSql) < 0
      Alert(TCSQLError())
   EndIf
   RestArea(aArea)
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} validaDoc
Valida se a op/sc pode ser movimentada entre as empresas

@param nLinDoc    - Linha da grid Documentos
@param lExibeMens - Indica se a função irá exibir as mensagens de erro

@author Lucas Konrad França
@since 09/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function validaDoc(nLinDoc,lExibeMens)
   Local nLinDest := oBrwEmpres:nAt
   Local nLinPrd  := oBrwProd:nAt
   Local cDoc     := ""
   Local lRet     := .T.
   Local cEmpBkp  := cEmpAnt
   Local cFilBkp  := cFilAnt
   Local cTpDoc   := ""
   Local cTable   := ""
   Local cNum     := ""
   Local nQuJe    := 0

   If Empty(aOrdens[nLinDoc,2])
      cDoc   := STR0068 /*"SC "*/+aOrdens[nLinDoc,3]
      cTable := "SC1"
      cNum   := aOrdens[nLinDoc,3]
   Else
      cDoc   := STR0067/*"OP "*/+aOrdens[nLinDoc,2]
      cTable := "SC2"
      cNum   := aOrdens[nLinDoc,2]
   EndIf

   If Empty(cNum)
      lRet := .F.
   EndIf

   //Verifica se está enviando para a mesma empresa/filial
   If lRet .And. AllTrim(aEmpresas[nLinDest,2]) == AllTrim(aOrdens[nLinDoc,6]) .And. AllTrim(aEmpresas[nLinDest,3]) == AllTrim(aOrdens[nLinDoc,7])
      If lExibeMens
         Alert(STR0069+AllTrim(cDoc)+STR0070) //"Empresa origem e destino da OP/SC XXX iguais, distribuição não permitida."
      EndIf
      lRet := .F.
   EndIf

   If lRet .And. aOrdens[nLinDoc,5] != "P" //Prevista
      If lExibeMens
         Alert(AllTrim(cDoc)+STR0071) //" com situação diferente de 'Prevista', distribuição não permitida.")
      EndIf
      lRet := .F.
   EndIf
   
   //Valida quandidade produzida (QUJE)
   If lRet
      nQuJe := valDoc(cTable,aOrdens[nLinDoc,6],aOrdens[nLinDoc,7],cNum,"QUJE")
      If nQuJe != 0
         If lExibeMens
            Alert(AllTrim(cDoc)+STR0072) //" já movimentada, distribuição não permitida.")
         EndIf
         lRet := .F.
      EndIf
   EndIf
   
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} gridEmpres
Cria a grid de Empresas da folder Centraliza

@author Lucas Konrad França
@since 03/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function gridEmpres()
   Local aHeaders  := {}
   Local aColSizes := {}
   
   aAdd(aHeaders,"Destino") //Código
   aAdd(aColSizes,50)

   cargaEmp()

   oBrwEmpres := TCBrowse():New(01,01,300,150,/*bLine*/,aHeaders,aColSizes,oPnlEmp,,,,/*bChange*/{|| buscaOPSC() },,,,,,,,,,.T.,,,,.T.,.T. )
   oBrwEmpres:Align := CONTROL_ALIGN_ALLCLIENT

   oBrwEmpres:SetArray(aEmpresas)
   oBrwEmpres:bLine := {||{ aEmpresas[oBrwEmpres:nAT,1]}}
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} cargaEmp
Carrega a grid de Empresas da folder Centraliza

@author Lucas Konrad França
@since 03/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function cargaEmp()
   Local cQuery    := ""
   Local cAlias    := GetNextAlias()
   Local cEmp      := ""
   aEmpresas := {}

   cQuery := " SELECT DISTINCT SOR.OR_EMP, "
   cQuery +=        " SOR.OR_FILEMP "
   cQuery +=   " FROM " + RetSqlName("SOR") + " SOR "
   cQuery +=  " WHERE SOR.OR_PROD BETWEEN '" + cProdDe   + "' AND '" + cProdAte   + "' "
   cQuery +=  " ORDER BY SOR.OR_EMP, SOR.OR_FILEMP "
   cQuery := ChangeQuery(cQuery)
   
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   While !(cAlias)->(Eof())
      cEmp := AllTrim((cAlias)->(OR_EMP)) + "/" + AllTrim((cAlias)->(OR_FILEMP)) + " - " +;
              AllTrim(FWEmpName((cAlias)->(OR_EMP))) + " / " + AllTrim(FWFilialName((cAlias)->(OR_EMP),(cAlias)->(OR_FILEMP),1))
      aAdd(aEmpresas,{cEmp, (cAlias)->(OR_EMP), (cAlias)->(OR_FILEMP)})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())
   If Len(aEmpresas) < 1
      aAdd(aEmpresas,{'','',''})
   EndIf
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} gridOPSC
Cria a grid de SCs e OPs

@author Lucas Konrad França
@since 09/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function gridOPSC()
   Local aHeaders := {}
   Local aAlter   := {}
   Local nX       := 0
   Local cTitulo  := ""
   Local nTamanho := 0
   Local nDecimal := 0
   Local cValid   := ""
   Local nTamNum  := TamSX3("C2_NUM")[1]
   Local nTamItm  := TamSX3("C2_ITEM")[1]
   Local nTamSeq  := TamSX3("C2_SEQUEN")[1]

   cTitulo  := STR0018 //"Ordem produção"
   nTamanho := nTamNum+nTamItm+nTamSeq
   nDecimal := 0
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_OPPROD",GetSx3Cache("OU_OPPROD",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_OPPROD",'X3_USADO'),GetSx3Cache("OU_OPPROD",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_OPPROD",'X3_CONTEXT')})

   cTitulo  := STR0015 //"Solicitação compra"
   nTamanho := GetSx3Cache("OU_SCSOLIC",'X3_TAMANHO')
   nDecimal := GetSx3Cache("OU_SCSOLIC",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_SCSOLIC",GetSx3Cache("OU_SCSOLIC",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_SCSOLIC",'X3_USADO'),GetSx3Cache("OU_SCSOLIC",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_SCSOLIC",'X3_CONTEXT')})

   cTitulo  := STR0016 //"Quantidade"
   nTamanho := GetSx3Cache("OU_QTPROD",'X3_TAMANHO')
   nDecimal := GetSx3Cache("OU_QTPROD",'X3_DECIMAL')
   cValid   := ""
   aAdd(aHeaders,{cTitulo,"OU_QTPROD",GetSx3Cache("OU_QTPROD",'X3_PICTURE'),nTamanho,nDecimal,cValid,GetSx3Cache("OU_QTPROD",'X3_USADO'),GetSx3Cache("OU_QTPROD",'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache("OU_QTPROD",'X3_CONTEXT')})

   aAdd(aOpSc, Array(Len(aHeaders)+1))
   For nX := 1 To Len(aHeaders)
      aOpSc[Len(aOpSc)][nX] := CriaVar(aHeaders[nX][2])
   Next nX
   aOpSc[Len(aOpSc)][Len(aHeaders)+1] := .F.
   
   oBrwOPSC := MsNewGetDados():New(001,001,oPnlOrdens:nClientHeight*0.50,oPnlOrdens:nClientWidth*0.50,GD_UPDATE,,,,aAlter,0,1000,,,"AllwaysFalse",oPnlOrdens,aHeaders,aOpSc,{|| changeColor(oBrwOPSC:nAt,oBrwOPSC),oBrwOPSC:Refresh()})
   oBrwOPSC:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oBrwOPSC:oBrowse:lUseDefaultColors := .F.
   oBrwOPSC:oBrowse:SetBlkBackColor({|| GETDCLR(oBrwOPSC:aCols,oBrwOPSC:nAt)})
   oBrwOPSC:oBrowse:SetBlkColor( { || RGB(0,0,0) } )
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} buscaDados
Executa a consulta

@author Lucas Konrad França
@since 13/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function buscaDados(lExibe)
   Local cQuery     := ""
   Local cAlias     := GetNextAlias()
   Local cAliasTree := GetNextAlias()
   Local cAliasReg  := GetNextAlias()
   Local cNumMrp    := ""
   Local cItem      := ""
   Local lFirst     := .T.
   Local cFirstCarg := ""
   Local aTree      := {}
   Local nTotal     := 0

   oTree:Reset()
   
   aTrans     := {}
   aSolic     := {}
   aFornec    := {}
   aProduto   := {}
   aOrdens    := {}
   aOpSc      := {}
   aOrdensDst := {}

   If lExibe
      cQuery := " SELECT COUNT(*) TOTAL "
      cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ "
      cQuery +=  " WHERE SOQ.OQ_ALIAS = 'TRA' "
      cQuery +=    " AND (SOQ.OQ_EMP  BETWEEN '" + cEmpOrgDe + "' AND '" + cEmpOrgAte + "' "
      cQuery +=     " OR  SOQ.OQ_EMP  BETWEEN '" + cEmpDstDe + "' AND '" + cEmpDstAte + "' )"
      cQuery +=    " AND SOQ.OQ_PROD  BETWEEN '" + cProdDe   + "' AND '" + cProdAte   + "' "
      cQuery +=    " AND SOQ.OQ_NRMRP BETWEEN '" + cNumMrpDe + "' AND '" + cNumMrpAte + "' "

      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
      If (cAlias)->(TOTAL) > 0
         //Help( ,, 'PCPA108',, STR0074, 1, 0 ) //"Foi realizada a distribuição de ordens, os dados apresentados pelo MRP não correspondem ao cenário atual das OPs/SCs."
         //AVISO("Aviso",STR0074,{"Ok"},1)
         DlgAlert(STR0074)
      EndIf
      (cAlias)->(dbCloseArea())
   EndIf


   //Busca o total para barra de progresso.
   cQuery := " SELECT COUNT(*) COUNTREG "
   cQuery +=   " FROM " + RetSqlName("SOU") + " SOU "
   cQuery +=  " WHERE SOU.OU_PROD    BETWEEN '" + cProdDe   + "' AND '" + cProdAte   + "' "
   cQuery +=    " AND SOU.OU_EMPORIG BETWEEN '" + cEmpOrgDe + "' AND '" + cEmpOrgAte + "' "
   cQuery +=    " AND SOU.OU_EMPDEST BETWEEN '" + cEmpDstDe + "' AND '" + cEmpDstAte + "' "
   cQuery +=    " AND SOU.OU_NRMRP   BETWEEN '" + cNumMrpDe + "' AND '" + cNumMrpAte + "' "
   cQuery +=    " AND SOU.D_E_L_E_T_ = ' ' "
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasReg,.T.,.T.)
   nTotal := (cAliasReg)->(COUNTREG)
   (cAliasReg)->(dbCloseArea())
   ProcRegua(nTotal)

   cQuery := " SELECT DISTINCT SOU.OU_NRMRP, "
   cQuery +=                 " SOU.OU_EMPORIG, "
   cQuery +=                 " SOU.OU_FILORIG "
   cQuery +=   " FROM " + RetSqlName("SOU") + " SOU "
   cQuery +=  " WHERE SOU.OU_PROD    BETWEEN '" + cProdDe   + "' AND '" + cProdAte   + "' "
   cQuery +=    " AND SOU.OU_EMPORIG BETWEEN '" + cEmpOrgDe + "' AND '" + cEmpOrgAte + "' "
   cQuery +=    " AND SOU.OU_EMPDEST BETWEEN '" + cEmpDstDe + "' AND '" + cEmpDstAte + "' "
   cQuery +=    " AND SOU.OU_NRMRP   BETWEEN '" + cNumMrpDe + "' AND '" + cNumMrpAte + "' "
   cQuery +=    " AND SOU.D_E_L_E_T_ = ' ' "
   cQuery +=  " ORDER BY 1, 2, 3 "

   cQuery := ChangeQuery(cQuery)
   
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTree,.T.,.F.)
   While !(cAliasTree)->(Eof())      
      IncProc()
      If AllTrim(cNumMrp) != (cAliasTree)->(OU_NRMRP)
         aAdd(aTree,{"00",;
                     "nrmrp"+(cAliasTree)->(OU_NRMRP),;
                     "",;
                     (cAliasTree)->(OU_NRMRP),;
                     'FOLDER5',;
                     'FOLDER6'})
         cNumMrp := (cAliasTree)->(OU_NRMRP)
      EndIf
      cItem := AllTrim((cAliasTree)->(OU_EMPORIG))+"/"+AllTrim((cAliasTree)->(OU_FILORIG))
      If lFirst
         cFirstCarg := "item"+(cAliasTree)->(OU_NRMRP)+cItem
         lFirst     := .F.
      EndIf
      aAdd(aTree,{"01",;
                  "item"+(cAliasTree)->(OU_NRMRP)+cItem,;
                  "",;
                  cItem,;
                  'PCPIMG16',;
                  'PCPIMG16'})

      (cAliasTree)->(dbSkip())
   End
   (cAliasTree)->(dbCloseArea())
   If Len(aTree) > 0
      oTree:PTSendTree( aTree )
      oTree:CurrentNodeId := cFirstCarg
      oTree:PTRefresh()
      cLastNode := ""
      ChangeTree()

      buscaCentr()
   Else
      aAdd(aProduto,{'',''})
      Help( ,, 'PCPA108',, STR0027, 1, 0 )//"Não existem dados para serem exibidos."
   EndIf

Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} buscaDocum
Executa a consulta da folder Centralizar, grid de documentos

@author Lucas Konrad França
@since 09/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function buscaDocum()
   Local nLinha    := oBrwProd:nAt
   Local cQuery    := ""
   Local cOp       := ""
   Local cSc       := ""
   Local cEmp      := ""
   Local cAlias    := GetNextAlias()
   Local cSituac   := ""
   Local cAliasSOQ := ""
   Local cBanco    := AllTrim(TcGetDB())

   aOrdens := {}

   cQuery := " SELECT SOQ.OQ_EMP, "
   cQuery +=        " SOQ.OQ_FILEMP, "
   cQuery +=        " CASE SOQ.OQ_ALIAS "
   cQuery +=        "        WHEN 'TRA' THEN SOQ.OQ_DOCKEY "
   cQuery +=        "        ELSE SOQ.OQ_DOC "
   cQuery +=        "     END DOC, "
   cQuery +=        "     CASE SOQ.OQ_ALIAS "
   cQuery +=        "        WHEN 'TRA' THEN SOQ.OQ_ITEM "
   cQuery +=        "        ELSE SOQ.OQ_ALIAS "
   cQuery +=        "     END ALIASSOQ, "
   cQuery +=        " SOQ.OQ_QUANT "
   cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ "
   cQuery +=  " WHERE SOQ.OQ_PROD = '" + aProduto[nLinha,1] + "' "
   cQuery +=    " AND SOQ.OQ_ALIAS IN ('SC1','SC2','TRA') "
   If !lConsulta
      cQuery +=    " AND NOT EXISTS ( "
      cQuery +=              " SELECT 1 "
      cQuery +=                " FROM A108DC "
      cQuery +=               " WHERE EMPORIG = SOQ.OQ_EMP "
      cQuery +=                 " AND FILORIG = SOQ.OQ_FILEMP "
      cQuery +=                 " AND PRODUTO = SOQ.OQ_PROD "
      cQuery +=                 " AND ((NUMOP  = SOQ.OQ_DOC "
      cQuery +=                 "   OR  NUMSC  = SOQ.OQ_DOC) "
      cQuery +=                 "   AND SOQ.OQ_ALIAS IN('SC1','SC2') "
      cQuery +=                 "   OR (NUMOP  = SOQ.OQ_DOCKEY "
      cQuery +=                 "   OR  NUMSC  = SOQ.OQ_DOCKEY) "
      cQuery +=                 "   AND SOQ.OQ_ALIAS = 'TRA') ) "
   EndIf
   cQuery += " AND NOT EXISTS ( "
   cQuery +=           " SELECT 1 "
   cQuery +=             " FROM " + RetSqlName("SOQ") + " SOQTRA "
   cQuery +=            " WHERE SOQTRA.OQ_ALIAS = 'TRA' "
   If cBanco=="MSSQL"
      cQuery +=              " AND SOQTRA.OQ_DOC   = (SOQ.OQ_EMP+SOQ.OQ_FILEMP+SOQ.OQ_DOC) )"
   Else
      cQuery +=              " AND SOQTRA.OQ_DOC   = (SOQ.OQ_EMP||SOQ.OQ_FILEMP||SOQ.OQ_DOC) )"
   EndIf
   //Faz o filtro para não trazer um documento que não existe mais.
   //O documento que não existe mais acontece quando a mesma OP é alterada mais de uma vez de empresa.
   //Ex: OP 00010101001 está na empresa 99/01, e é alterada para a empresa 98/01. Neste processo gerou a OP 00020201001 
   //na empresa 98/01 e excluiu a op 00010101001 na empresa 99/01.
   //Caso a OP 00020201001 seja alterada de empresa, irá entrar na situação que o SQL está tratando.
   cQuery += " AND NOT EXISTS ( SELECT 1 "
   cQuery +=                    " FROM "+ RetSqlName("SOQ") + " SOQDUP "
   cQuery +=                   " WHERE SOQDUP.OQ_PROD = SOQ.OQ_PROD "
   If cBanco=="MSSQL"
      cQuery +=                  " AND SOQDUP.OQ_DOC  = (SOQ.OQ_EMP+SOQ.OQ_FILEMP+SOQ.OQ_DOCKEY) )"
   Else
      cQuery +=                  " AND SOQDUP.OQ_DOC  = (SOQ.OQ_EMP||SOQ.OQ_FILEMP||SOQ.OQ_DOCKEY) )"
   EndIf
   cQuery +=  " ORDER BY 1,2,3 "
   
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.F.)
   While (cAlias)->(!Eof())
      Do Case
         Case AllTrim((cAlias)->(ALIASSOQ)) == "SC"
            cAliasSOQ := "SC1"
         Case AllTrim((cAlias)->(ALIASSOQ)) == "OP"
            cAliasSOQ := "SC2"
         Otherwise
            cAliasSOQ := (cAlias)->(ALIASSOQ)
      EndCase

      If cAliasSOQ == "SC1"
         cOp := ""
         cSc := (cAlias)->(DOC)
      Else
         cOp := (cAlias)->(DOC)
         cSc := ""
      EndIf

      cEmp := AllTrim((cAlias)->(OQ_EMP)) + "/" + AllTrim((cAlias)->(OQ_FILEMP)) + " - " +;
              AllTrim(FWEmpName((cAlias)->(OQ_EMP))) + " / " + AllTrim(FWFilialName((cAlias)->(OQ_EMP),(cAlias)->(OQ_FILEMP),1))
      cSituac := valDoc(cAliasSOQ,(cAlias)->(OQ_EMP), (cAlias)->(OQ_FILEMP),(cAlias)->(DOC),"TPOP")
      aAdd(aOrdens,{ cEmp, cOp, cSc, (cAlias)->(OQ_QUANT), cSituac, (cAlias)->(OQ_EMP), (cAlias)->(OQ_FILEMP),.F.})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   If Len(aOrdens) < 1
      aAdd(aOrdens,{'','','',0,' ','','',.T.})
   EndIf
   aOrdens[1,8] := .T.
   oBrwOrdens:SetArray(aOrdens)
   oBrwOrdens:ForceRefresh()
   oBrwOrdens:GoTo(1)
   oBrwOrdens:nAt := 1
   buscaOPSC()
   buscaOPTRA()
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} valDoc
Busca o valor de um campo da SC1 ou SC2

@param cTabela - Identifica qual a tabela que irá fazer a busca (SC1,SC2)
@param cEmp    - Empresa que irá fazer a busca
@param cFil    - Filial que irá fazer a busca
@param cDoc    - Número do documento
@param cCampo  - Campo que irá retornar.

@author Lucas Konrad França
@since 09/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function valDoc(cTabela,cEmp,cFil,cDoc,cCampo)
   Local cRet      := ""
   Local cAlias    := GetNextAlias()
   Local cQuery    := ""
   Local cNumOp    := ""
   Local cItemOp   := ""
   Local cSeqOp    := ""
   Local aArea     := GetArea()
   Local nPos      := 0
   Local nTamNum   := TamSX3("C2_NUM")[1]
   Local nTamItm   := TamSX3("C2_ITEM")[1]
   Local nTamSeq   := TamSX3("C2_SEQUEN")[1]

   nPos := aScan(aTabNames,{|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(cEmp)+AllTrim(cFil)+AllTrim(cTabela) })
   If nPos > 0
      If Alltrim(cTabela) == "SC2"
         cNumOp  := SubStr(cDoc,1,nTamNum)
         cItemOp := SubStr(cDoc,nTamNum+1,nTamItm)
         cSeqOp  := SubStr(cDoc,nTamNum+nTamItm+1,nTamSeq)
         
         cQuery := " SELECT SC2.C2_"+cCampo+" CAMPO "
         cQuery +=   " FROM " + aTabNames[nPos,4] + " SC2 "
         cQuery +=  " WHERE SC2.C2_FILIAL  = '" + aTabNames[nPos,5] + "' "
         cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
         cQuery +=    " AND SC2.C2_NUM     = '" + cNumOp  + "' "
         cQuery +=    " AND SC2.C2_ITEM    = '" + cItemOp + "' "
         cQuery +=    " AND SC2.C2_SEQUEN  = '" + cSeqOp  + "' "
      Else
         cQuery := " SELECT SC1.C1_"+cCampo+" CAMPO "
         cQuery +=   " FROM " + aTabNames[nPos,4] + " SC1 "
         cQuery +=  " WHERE SC1.C1_FILIAL  = '" + aTabNames[nPos,5] + "' "
         cQuery +=    " AND SC1.D_E_L_E_T_ = ' ' "
         cQuery +=    " AND SC1.C1_NUM     = '" + cDoc + "' "
      EndIf
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

      If (cAlias)->(!Eof())
         cRet := (cAlias)->(CAMPO)
      EndIf
      (cAlias)->(dbCloseArea())
   EndIf
   RestArea(aArea)
Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} buscaCentr
Executa a consulta da folder Centralizar

@author Lucas Konrad França
@since 03/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function buscaCentr()
   Local cQuery := ""
   Local cAlias := GetNextAlias()

   aProduto := {}

   cQuery := " SELECT DISTINCT SOQ.OQ_PROD, "
   cQuery +=        " SB1.B1_DESC, "
   cQuery +=        " SOQ.OQ_NRMRP "
   cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ "
   cQuery +=   " LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 ON "
   cQuery +=                   " SB1.B1_COD = SOQ.OQ_PROD "
   cQuery +=  " WHERE SOQ.OQ_PROD BETWEEN '" + cProdDe   + "' AND '" + cProdAte   + "' "
   cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
   cQuery +=    " AND SOQ.OQ_PROD    <> ' ' "
   cQuery +=    " AND SOQ.OQ_ALIAS IN ('SC1','SC2','TRA') "
   cQuery +=  " ORDER BY SOQ.OQ_PROD "
   
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.F.)
   While (cAlias)->(!Eof())
      aAdd(aProduto,{(cAlias)->(OQ_PROD),(cAlias)->(B1_DESC)})
      cLastMrp := (cAlias)->(OQ_NRMRP)
      (cAlias)->(dbSKip())
   End
   (cAlias)->(dbCloseArea())
   If Len(aProduto) < 1
      aAdd(aProduto,{'',''})
   EndIf
   oBrwProd:SetArray(aProduto)
   oBrwProd:bLine := {||{ aProduto[oBrwProd:nAT,1],;
                          aProduto[oBrwProd:nAt,2]}}
   oBrwProd:GoTop()
   oBrwProd:Refresh()
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} buscaOPSC
Busca as OPS/SCS que já foram selecionadas para centralizar.

@author Lucas Konrad França
@since 09/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function buscaOPSC()
   Local cQuery  := ""
   Local cAlias  := GetNextAlias()
   Local nLinEmp := oBrwEmpres:nAt
   Local nLinPrd := oBrwProd:nAt
   aOpSc := {}
   If !lConsulta
      cQuery := " SELECT NUMOP, NUMSC, QUANT "
      cQuery +=   " FROM A108DC "
      cQuery +=  " WHERE EMPDEST = '" + aEmpresas[nLinEmp,2] + "' "
      cQuery +=    " AND FILDEST = '" + aEmpresas[nLinEmp,3] + "' "
      cQuery +=    " AND PRODUTO = '" + aProduto[nLinPrd,1] + "' "

      cQuery := ChangeQuery(cQuery)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

      While (cAlias)->(!Eof())
         aAdd(aOpSc,{(cAlias)->(NUMOP), (cAlias)->(NUMSC), (cAlias)->(QUANT),.F. })
         (cAlias)->(dbSkip())
      End
      (cAlias)->(dbCloseArea())
      If Len(aOpSc) < 1
         aAdd(aOpSc,{'','',0,.F.})
      EndIf
   Else
      aAdd(aOpSc,{'','',0,.F.})
   EndIf
   aOpSc[1,4] := .T.
   oBrwOPSC:SetArray(aOpSc)
   oBrwOPSC:ForceRefresh()
   oBrwOPSC:GoTo(1)
   oBrwOPSC:nAt := 1
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} buscaOPTRA
Busca as OPS/SCS que já foram centralizadas.

@author Lucas Konrad França
@since 22/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function buscaOPTRA()
   Local nLinha    := oBrwProd:nAt
   Local cQuery    := ""
   Local cOp       := ""
   Local cSc       := ""
   Local cEmp      := ""
   Local cAlias    := GetNextAlias()
   Local cSituac   := ""
   Local cTab      := ""

   aOrdensDst := {}

   cQuery := " SELECT SOQ.OQ_EMP, "
   cQuery +=        " SOQ.OQ_FILEMP, "
   cQuery +=        " SOQ.OQ_DOCKEY, "
   cQuery +=        " SOQ.OQ_DOC, "
   cQuery +=        " SOQ.OQ_ITEM, "
   cQuery +=        " SOQ.OQ_QUANT "
   cQuery +=   " FROM " + RetSqlName("SOQ") + " SOQ "
   cQuery +=  " WHERE SOQ.OQ_PROD  = '" + aProduto[nLinha,1] + "' "
   cQuery +=    " AND SOQ.OQ_ALIAS = 'TRA' "
   cQuery +=  " ORDER BY 1,2,3 "
   
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.F.)
   While (cAlias)->(!Eof())
      If AllTrim((cAlias)->(OQ_ITEM)) == "SC"
         cTab := "SC1"
      Else
         cTab := "SC2"
      EndIf
      If (cAlias)->(OQ_ITEM) == "OP"
         cTipo := STR0067 //"OP"
      Else
         cTipo := STR0068 //"SC"
      EndIf

      cEmp     := SubStr((cAlias)->(OQ_DOC),1,2)
      cFil     := SubStr((cAlias)->(OQ_DOC),3,12)
      cDocOrig := SubStr((cAlias)->(OQ_DOC),15,30)

      cEmpOrig := AllTrim(cEmp) + '/' + AllTrim(cFil)

      cEmpDest := AllTrim((cAlias)->(OQ_EMP)) + "/" + AllTrim((cAlias)->(OQ_FILEMP))
      cDocDest := (cAlias)->(OQ_DOCKEY)

      nQuant := (cAlias)->(OQ_QUANT)
            
      aAdd(aOrdensDst,{cTipo, cEmpOrig, cDocOrig, cEmpDest, cDocDest, nQuant,.F.})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   If Len(aOrdensDst) < 1
      aAdd(aOrdensDst,{'','','','','',0,.T.})
   EndIf
   aOrdensDst[1,7] := .T.
   oBrwOpDst:SetArray(aOrdensDst)
   oBrwOpDst:ForceRefresh()
   oBrwOpDst:GoTo(1)
   oBrwOpDst:nAt := 1
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} cargaTrans
Executa a consulta das transferências.

@author Lucas Konrad França
@since 13/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function cargaTrans()
   Local cQuery     := ""
   Local cAliasTran := ""
   
   If Empty(cNrMrp) .Or. Empty(cEmpOrg) .Or. Empty(cFilOrg)
      Return Nil
   EndIf
   cAliasTran := GetNextAlias()
   aTrans := {}

   cQuery := " SELECT SOU.OU_PROD, "
   cQuery +=        " SB1.B1_DESC, "
   cQuery +=        " SUM(SOU.OU_QTEST+SOU.OU_QTPROD) QTTRAN, "
   cQuery +=        " SOU.OU_EMPDEST, "
   cQuery +=        " SOU.OU_FILDEST "
   cQuery +=   " FROM " + RetSqlName("SOU") + " SOU, "
   cQuery +=              RetSqlName("SB1") + " SB1 "
   cQuery +=  " WHERE SOU.OU_NRMRP   = '" + cNrMrp + "' "
   cQuery +=    " AND SOU.OU_EMPORIG = '" + cEmpOrg + "' "
   cQuery +=    " AND SOU.OU_FILORIG = '" + cFilOrg + "' "
   cQuery +=    " AND SOU.OU_PROD    = SB1.B1_COD "
   cQuery +=    " AND SOU.OU_PROD    BETWEEN '" + cProdDe   + "' AND '" + cProdAte   + "' "
   cQuery +=    " AND SOU.OU_EMPDEST BETWEEN '" + cEmpDstDe + "' AND '" + cEmpDstAte + "' "
   cQuery +=    " AND SOU.D_E_L_E_T_ = ' ' "
   cQuery +=  " GROUP BY SOU.OU_PROD, "
   cQuery +=           " SB1.B1_DESC, "
   cQuery +=           " SOU.OU_EMPDEST, "
   cQuery +=           " SOU.OU_FILDEST "
   cQuery +=  " ORDER BY 1, 2, 4, 5 "

   cQuery := ChangeQuery(cQuery)
   
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTran,.T.,.F.)
   While !(cAliasTran)->(Eof())      
      aAdd(aTrans, {AllTrim(cEmpOrg)+"/"+AllTrim(cFilOrg),;
                    (cAliasTran)->(OU_PROD),;
                    (cAliasTran)->(B1_DESC),;
                    (cAliasTran)->(QTTRAN),;
                    AllTrim((cAliasTran)->(OU_EMPDEST))+"/"+AllTrim((cAliasTran)->(OU_FILDEST)),;
                    .F.})
      (cAliasTran)->(dbSkip())
   End
   (cAliasTran)->(dbCloseArea())
   If Len(aTrans) < 1
      aAdd(aTrans,{'','','',0,'',.F.})
   EndIf

   oBrwTrans:SetArray(aTrans)
   oBrwTrans:ForceRefresh()
   oBrwTrans:GoTop()

   cargaSolic()
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} cargaSolic
Executa a consulta das solicitações.

@author Lucas Konrad França
@since 13/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function cargaSolic()
   Local nLinha     := oBrwTrans:nAt
   Local nI         := 0
   Local cQuery     := ""
   Local cAliasSoli := ""
   Local cNumOp     := "" 
   Local cEmpresa   := cEmpAnt
   Local cFilialAtu := cFilAnt
   Local cDataSc    := ""
   Local lPrepTbl   := .F.

   For nI := 1 To Len(oBrwTrans:aCols)
      oBrwTrans:aCols[nI,Len(oBrwTrans:aCols[nI])] := .F.
   Next nI
   oBrwTrans:aCols[nLinha,Len(oBrwTrans:aCols[nLinha])] := .T.

   If Empty(cNrMrp) .Or. Empty(cEmpOrg) .Or. Empty(cFilOrg) .Or. nLinha < 1
      Return Nil
   EndIf
   
   cEmpDst  := SubStr(aTrans[nLinha,5],1,2)
   cFilDst  := SubStr(aTrans[nLinha,5],4,Len(aTrans[nLinha,5])-3)
   cProduto := aTrans[nLinha,2]   

   If Empty(cEmpDst) .Or. Empty(cFilDst) .Or. Empty(cProduto)
      Return Nil
   EndIf
   
   cAliasSoli := GetNextAlias()
   
   aSolic := {}

   cQuery := "SELECT SOU.OU_EMPORIG, "
   cQuery +=       " SOU.OU_FILORIG, "
   cQuery +=       " SOU.OU_EMPDEST, "
   cQuery +=       " SOU.OU_FILDEST, "
   cQuery +=       " SOU.OU_NRMRP, "
   cQuery +=       " SOU.OU_PROD, "
   cQuery +=       " SOU.OU_SCSOLIC, "
   cQuery +=       " SOU.OU_ITEMSC, "
   cQuery +=       " SOU.OU_ITGRDSC, "
   If !lConsulta
      cQuery +=       " CASE WHEN (SELECT COUNT(*) "
      cQuery +=                    " FROM A108QT "
      cQuery +=                   " WHERE A108QT.NRMRP   = SOU.OU_NRMRP "
      cQuery +=                     " AND A108QT.EMPORIG = SOU.OU_EMPORIG "
      cQuery +=                     " AND A108QT.FILORIG = SOU.OU_FILORIG "
      cQuery +=                     " AND A108QT.EMPDEST = SOU.OU_EMPDEST "
      cQuery +=                     " AND A108QT.FILDEST = SOU.OU_FILDEST "
      cQuery +=                     " AND A108QT.PRODUTO = SOU.OU_PROD "
      cQuery +=                     " AND A108QT.NUMSC   = SOU.OU_SCSOLIC "
      cQuery +=                     " AND A108QT.ITEMSC  = SOU.OU_ITEMSC "
      cQuery +=                     " AND A108QT.ITGRDSC = SOU.OU_ITGRDSC) > 0 "
      cQuery +=            " THEN "
      cQuery +=                " (SELECT SITUAC "
      cQuery +=                    " FROM A108QT "
      cQuery +=                   " WHERE A108QT.NRMRP   = SOU.OU_NRMRP "
      cQuery +=                     " AND A108QT.EMPORIG = SOU.OU_EMPORIG "
      cQuery +=                     " AND A108QT.FILORIG = SOU.OU_FILORIG "
      cQuery +=                     " AND A108QT.EMPDEST = SOU.OU_EMPDEST "
      cQuery +=                     " AND A108QT.FILDEST = SOU.OU_FILDEST "
      cQuery +=                     " AND A108QT.PRODUTO = SOU.OU_PROD "
      cQuery +=                     " AND A108QT.NUMSC   = SOU.OU_SCSOLIC "
      cQuery +=                     " AND A108QT.ITEMSC  = SOU.OU_ITEMSC "
      cQuery +=                     " AND A108QT.ITGRDSC = SOU.OU_ITGRDSC) "
      cQuery +=            " ELSE "
      cQuery +=              " SOU.OU_SITUACA "
      cQuery +=       " END OUSITUAC, "
      cQuery +=       " CASE WHEN (SELECT COUNT(*) "
      cQuery +=                    " FROM A108QT "
      cQuery +=                   " WHERE A108QT.NRMRP   = SOU.OU_NRMRP "
      cQuery +=                     " AND A108QT.EMPORIG = SOU.OU_EMPORIG "
      cQuery +=                     " AND A108QT.FILORIG = SOU.OU_FILORIG "
      cQuery +=                     " AND A108QT.EMPDEST = SOU.OU_EMPDEST "
      cQuery +=                     " AND A108QT.FILDEST = SOU.OU_FILDEST "
      cQuery +=                     " AND A108QT.PRODUTO = SOU.OU_PROD "
      cQuery +=                     " AND A108QT.NUMSC   = SOU.OU_SCSOLIC "
      cQuery +=                     " AND A108QT.ITEMSC  = SOU.OU_ITEMSC "
      cQuery +=                     " AND A108QT.ITGRDSC = SOU.OU_ITGRDSC) > 0 "
      cQuery +=            " THEN "
      cQuery +=                " (SELECT SUM(QUANT) "
      cQuery +=                    " FROM A108QT "
      cQuery +=                   " WHERE A108QT.NRMRP   = SOU.OU_NRMRP "
      cQuery +=                     " AND A108QT.EMPORIG = SOU.OU_EMPORIG "
      cQuery +=                     " AND A108QT.FILORIG = SOU.OU_FILORIG "
      cQuery +=                     " AND A108QT.EMPDEST = SOU.OU_EMPDEST "
      cQuery +=                     " AND A108QT.FILDEST = SOU.OU_FILDEST "
      cQuery +=                     " AND A108QT.PRODUTO = SOU.OU_PROD "
      cQuery +=                     " AND A108QT.NUMSC   = SOU.OU_SCSOLIC "
      cQuery +=                     " AND A108QT.ITEMSC  = SOU.OU_ITEMSC "
      cQuery +=                     " AND A108QT.ITGRDSC = SOU.OU_ITGRDSC) "
      cQuery +=            " ELSE "
      cQuery +=              " SUM(SOU.OU_QTMOVTO) "
      cQuery +=       " END QTMOVTO, "
   Else
      cQuery +=       " SOU.OU_SITUACA OUSITUAC, "
      cQuery +=       " SUM(SOU.OU_QTMOVTO) QTMOVTO, "
   EndIf
   cQuery +=       " SUM(SOU.OU_QTPROD+SOU.OU_QTEST) QTTRAN "
   cQuery +=  " FROM " + RetSqlName("SOU") + " SOU "
   cQuery += " WHERE SOU.OU_FILIAL  = '" + xFilial("SOU") + "' "
   cQuery +=   " AND SOU.OU_PROD    = '" + cProduto + "' "
   cQuery +=   " AND SOU.OU_NRMRP   = '" + cNrMrp + "' "
   cQuery +=   " AND SOU.OU_EMPORIG = '" + cEmpOrg + "' "
   cQuery +=   " AND SOU.OU_FILORIG = '" + cFilOrg + "' "
   cQuery +=   " AND SOU.OU_EMPDEST = '" + cEmpDst + "' "
   cQuery +=   " AND SOU.OU_FILDEST = '" + cFilDst + "' "
   cQuery +=   " AND SOU.D_E_L_E_T_ = ' ' "
   cQuery += " GROUP BY SOU.OU_EMPORIG, "
   cQuery +=          " SOU.OU_FILORIG, "
   cQuery +=          " SOU.OU_EMPDEST,  "
   cQuery +=          " SOU.OU_FILDEST, "
   cQuery +=          " SOU.OU_NRMRP, "
   cQuery +=          " SOU.OU_PROD, "
   cQuery +=          " SOU.OU_SCSOLIC, "
   cQuery +=          " SOU.OU_ITEMSC,  "
   cQuery +=          " SOU.OU_ITGRDSC,  "
   cQuery +=          " SOU.OU_SITUACA "
   cQuery += " ORDER BY SOU.OU_EMPDEST,"
   cQuery +=          " SOU.OU_FILDEST, "
   cQuery +=          " SOU.OU_SCSOLIC, "
   cQuery +=          " SOU.OU_ITEMSC, "
   cQuery +=          " SOU.OU_ITGRDSC, "
   cQuery +=          " SOU.OU_SITUACA "

   cQuery := ChangeQuery(cQuery)
   
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSoli,.T.,.F.)
   While !(cAliasSoli)->(Eof())
      cDataSc := getValSc1(cEmpDst, cFilDst,(cAliasSoli)->(OU_SCSOLIC),(cAliasSoli)->(OU_ITEMSC),(cAliasSoli)->(OU_ITGRDSC),"C1_DATPRF")
      cNumOp  := getValSc1(cEmpDst, cFilDst,(cAliasSoli)->(OU_SCSOLIC),(cAliasSoli)->(OU_ITEMSC),(cAliasSoli)->(OU_ITGRDSC),"C1_OP")

      aAdd(aSolic,{(cAliasSoli)->(OU_EMPDEST)+"/"+(cAliasSoli)->(OU_FILDEST),;
                   (cAliasSoli)->(OU_SCSOLIC),;
                   (cAliasSoli)->(OU_ITEMSC),;
                   (cAliasSoli)->(OU_ITGRDSC),;
                   (cAliasSoli)->(QTTRAN),;
                   cDataSc,;
                   (cAliasSoli)->(OUSITUAC),;
                   (cAliasSoli)->(QTMOVTO),;
                   cNumOp,;
                   .F.,.F.})
      (cAliasSoli)->(dbSkip())
   End
   
   (cAliasSoli)->(dbCloseArea())
   IF Len(aSolic) < 1
      aAdd(aSolic,{'','','','',0,'','1',0,'',.F.,.F.})
   EndIf
   oBrwSolic:SetArray(aSolic)
   oBrwSolic:ForceRefresh()
   oBrwSolic:GoTo(1)
   oBrwSolic:nAt := 1
   changeSolic(1)
   oBrwSolic:Refresh()
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} getValSc1
Busca um valor da Ordem de compra (SC1)

@param cEmp		- Empresa que contem a SC
@param cFil		- Filial que contem a Sc
@param cNum		- Número da SC
@param cItem		- Item da SC
@param cItemGrd	- Item grade da SC
@param cCampo		- Campo que terá seu valor retornado

@author Lucas Konrad França
@since 10/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static function getValSc1(cEmp, cFil,cNum,cItem,cItemGrd,cCampo)
   Local xRet      := ""
   Local cAlias    := GetNextAlias()
   Local cQuery    := ""
   Local aArea     := GetArea()
   Local nPos      := 0

   nPos := aScan(aTabNames,{|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(cEmp)+AllTrim(cFil)+"SC1" })
   If nPos > 0
      cQuery := " SELECT SC1." + AllTrim(cCampo) + " CAMPO "
      cQuery +=   " FROM " + aTabNames[nPos,4] + " SC1 "
      cQuery +=  " WHERE SC1.C1_FILIAL  = '" + aTabNames[nPos,5] + "' "
      cQuery +=    " AND SC1.D_E_L_E_T_ = ' ' "
      cQuery +=    " AND SC1.C1_NUM     = '" + cNum + "' "
      cQuery +=    " AND SC1.C1_ITEM    = '" + cItem + "' "
      cQuery +=    " AND SC1.C1_ITEMGRD = '" + cItemGrd + "' "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

      If (cAlias)->(!Eof())
         If AllTrim(cCampo) == "C1_DATPRF"
            xRet := StoD((cAlias)->(CAMPO))
         Else
            xRet := (cAlias)->(CAMPO)
         EndIf
      EndIf
      (cAlias)->(dbCloseArea())
   EndIf
   RestArea(aArea)
Return xRet

//-----------------------------------------------------------------
/*/{Protheus.doc} changeSolic
Executada no evento change da grid Solicitante

@author Lucas Konrad França
@since 14/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function changeSolic(nLinha)
   Local nI := 0

   //Flag para mudar a cor da linha selecionada
   For nI := 1 To Len(oBrwSolic:aCols)
      oBrwSolic:aCols[nI,Len(oBrwSolic:aCols[nI])] := .F.
   Next nI
   oBrwSolic:aCols[nLinha,Len(oBrwSolic:aCols[nLinha])] := .T.
   //oBrwSolic:Refresh()

   cScSolic := oBrwSolic:aCols[nLinha,2]
   cItemSc  := oBrwSolic:aCols[nLinha,3]
   cItGrdSc := oBrwSolic:aCols[nLinha,4]
   cargaForn(nLinha)
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} cargaForn
Faz a busca das OP's

@author Lucas Konrad França
@since 14/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function cargaForn(nLinha)
   Local cQuery   := ""
   Local cAliasOp := ""
   
   Local cEmpFil  := ""
   Local cNumOp   := ""
   Local cNumSc   := ""
   Local cSeq     := ""
   Local cItem    := ""
   Local cItemGrd := ""
   Local nQtdProd := 0
   Local nQtdEst  := 0
   Local dData    := DATE()

   If Empty(cNrMrp) .Or. Empty(cEmpOrg) .Or. Empty(cFilOrg) .Or. ;
      Empty(cEmpDst) .Or. Empty(cFilDst) .Or. Empty(cProduto) .Or. nLinha < 1 .Or. ;
      Empty(cScSolic) .Or. Empty(cItemSc)
      Return Nil
   EndIf
   
   cAliasOp := GetNextAlias()
   aFornec  := {}

   cQuery := "SELECT SOU.OU_EMPORIG, "
   cQuery +=       " SOU.OU_FILORIG, "
   cQuery +=       " SOU.OU_OPPROD, "
   cQuery +=       " SOU.OU_C2SEQ, "
   cQuery +=       " SOU.OU_ITEMOP, "
   cQuery +=       " SOU.OU_ITGRDOP, "
   cQuery +=       " SOU.OU_QTPROD, "
   cQuery +=       " SOU.OU_QTEST, "
   cQuery +=       " SOU.OU_DTTRANS "
   cQuery +=  " FROM " + RetSqlName("SOU") + " SOU "
   cQuery += " WHERE SOU.OU_NRMRP   = '" + cNrMrp + "' "
   cQuery +=   " AND SOU.OU_EMPORIG = '" + cEmpOrg + "' "
   cQuery +=   " AND SOU.OU_FILORIG = '" + cFilOrg + "' "
   cQuery +=   " AND SOU.OU_EMPDEST = '" + cEmpDst + "' "
   cQuery +=   " AND SOU.OU_FILDEST = '" + cFilDst + "' "
   cQuery +=   " AND SOU.OU_PROD    = '" + cProduto + "' "
   cQuery +=   " AND SOU.OU_SCSOLIC = '" + cScSolic + "' "
   cQuery +=   " AND SOU.OU_ITEMSC  = '" + cItemSc + "' "
   cQuery +=   " AND SOU.OU_ITGRDSC = '" + cItGrdSc + "' "
   cQuery +=   " AND SOU.D_E_L_E_T_ = ' ' "
   cQuery += " ORDER BY 1,2,3,4,5,6 "
   
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOp,.T.,.F.)
   While !(cAliasOp)->(Eof())
      cEmpFil  := AllTrim((cAliasOp)->(OU_EMPORIG))+"/"+AllTrim((cAliasOp)->(OU_FILORIG))
      cSeq     := (cAliasOp)->(OU_C2SEQ)
      cItem    := (cAliasOp)->(OU_ITEMOP)
      cItemGrd := (cAliasOp)->(OU_ITGRDOP)
      nQtdProd := (cAliasOp)->(OU_QTPROD)
      nQtdEst  := (cAliasOp)->(OU_QTEST)
      dData    := StoD((cAliasOp)->(OU_DTTRANS))
      If AllTrim((cAliasOp)->(OU_C2SEQ)) == "SC"
         cNumSc := (cAliasOp)->(OU_OPPROD)
         cNumOp := ""
         cSeq   := ""
         nQtOpSc := valDoc("SC1",cEmpOrg,cFilOrg,(cAliasOp)->(OU_OPPROD),"QUANT")
      Else
         cNumOp := (cAliasOp)->(OU_OPPROD)
         cNumSc := ""
         nQtOpSc := valDoc("SC2",cEmpOrg,cFilOrg,(cAliasOp)->(AllTrim(OU_OPPROD)+AllTrim(OU_ITEMOP)+AllTrim(OU_C2SEQ)),"QUANT")
      EndIf
      If Empty(nQtOpSc)
         nQtOpSc := 0
      EndIf
      aAdd(aFornec,{cEmpFil,cNumOp,cNumSc,cSeq,cItem,cItemGrd,nQtOpSc,nQtdEst,nQtdProd,dData,.F.})
      (cAliasOp)->(dbSkip())
   End
   (cAliasOp)->(dbCloseArea())
   If Len(aFornec) < 1
      aAdd(aFornec,{'','','','','','',0,0,0,'',.F.})
   EndIf
   oBrwFornec:SetArray(aFornec)
   oBrwFornec:ForceRefresh()
   oBrwFornec:GoTop()
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} excluiSou
Realiza a exclusão da tabela SOU

@author Lucas Konrad França
@since 15/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function excluiSou()
   Local cMrpDe    := ""
   Local cMrpAte   := ""
   Local nRet      := 0
   Local lContinua := .T.
   
   If verAlterac()
      lContinua := MsgYesNo(STR0056,STR0057) //"Foram realizadas alterações nas informações consultadas, deseja continuar e descartar as alterações?","Continua?"
   EndIf

   If lContinua
      If Pergunte("PCPA108A")
         
         cMrpDe  := mv_par01
         cMrpAte := mv_par02

         nRet := execDel(cMrpDe,cMrpAte)
         If nRet < 0
            Help( ,, 'PCPA108',, STR0028+TCSQLError(), 1, 0 )// "Ocorreram erros ao executar a exclusão: " + ERROR
         Else
            MsgInfo(STR0029,STR0008) //"Exclusão efetuada com sucesso."
            limpaTemp()
            Processa( {|| buscaDados() }, STR0036/*"Aguarde..."*/, STR0038,.F.) //"Executando consulta..."
         EndIf
      EndIf
   EndIf
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} execDel
Executa a exclusão da tabela SOU.

@param cMrpDe  - Número do MRP Fnício para exclusão
@param cMrpAte - Número do MRP Fim para exclusão

@author Lucas Konrad França
@since 15/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function execDel(cMrpDe,cMrpAte)
   Local cQuery := ""
   
   If cMrpDe == Nil
      cMrpDe := CriaVar("OU_NRMRP")
   EndIf
   If cMrpAte == Nil
      cMrpAte := CriaVar("OU_NRMRP")
   EndIf

   cQuery := " DELETE FROM " + RetSqlName("SOU")
   cQuery +=  " WHERE OU_NRMRP BETWEEN '" + cMrpDe + "' AND '" + cMrpAte + "' "

   nRet := TCSQLExec(cQuery)
Return nRet

//-----------------------------------------------------------------
/*/{Protheus.doc} criaTemp
Cria a tabela temporária para controle dos campos Situação e Qtd Movto

@author Lucas Konrad França
@since 15/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function criaTemp()
   Local aCampos := {}

   AADD(aCampos,{"NRMRP"  ,"C",TamSX3("OU_NRMRP")[1],0})
   AADD(aCampos,{"EMPORIG","C",TamSX3("OU_EMPORIG")[1],0})
   AADD(aCampos,{"FILORIG","C",TamSX3("OU_FILORIG")[1],0})
   AADD(aCampos,{"EMPDEST","C",TamSX3("OU_EMPDEST")[1],0})
   AADD(aCampos,{"FILDEST","C",TamSX3("OU_FILDEST")[1],0})
   AADD(aCampos,{"PRODUTO","C",TamSX3("OU_PROD")[1],0})
   AADD(aCampos,{"NUMSC"  ,"C",TamSX3("OU_SCSOLIC")[1],0})
   AADD(aCampos,{"ITEMSC" ,"C",TamSX3("OU_ITEMSC")[1],0})
   AADD(aCampos,{"ITGRDSC","C",TamSX3("OU_ITGRDSC")[1],0})
   AADD(aCampos,{"SITUAC" ,"C",1,0})
   AADD(aCampos,{"QUANT"  ,"N",TamSX3("OU_QTPROD")[1],TamSX3("OU_QTPROD")[2]})
   
   //Exclui a tabela caso ja exista
   TCDelFile("A108QT")
   //Cria a tabela
   DbCreate("A108QT",aCampos,"TOPCONN")

   aCampos := {}

   AADD(aCampos,{"EMPORIG","C",TamSX3("OQ_EMP")[1],0})
   AADD(aCampos,{"FILORIG","C",TamSX3("OQ_FILEMP")[1],0})
   AADD(aCampos,{"EMPDEST","C",TamSX3("OQ_EMP")[1],0})
   AADD(aCampos,{"FILDEST","C",TamSX3("OQ_FILEMP")[1],0})
   AADD(aCampos,{"PRODUTO","C",TamSX3("B1_COD")[1],0})
   AADD(aCampos,{"NUMOP","C",TamSX3("OQ_DOC")[1],0})
   AADD(aCampos,{"NUMSC","C",TamSX3("OQ_DOC")[1],0})
   AADD(aCampos,{"QUANT","N",TamSX3("C2_QUANT")[1],TamSX3("C2_QUANT")[2]})

   //Exclui a tabela caso ja exista
   TCDelFile("A108DC")
   //Cria a tabela
   DbCreate("A108DC",aCampos,"TOPCONN")
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} insereTemp
Insere/Atualiza um registro da tabela temporária

@param cNumMrp   - Número de processamento do MRP
@param cEmpOrig  - Empresa origem da solicitação
@param cFilOrig  - Filial origem da solicitação
@param cEmpDest  - Empresa destino da solicitação
@param cFilDest  - Filial destino da solicitação
@param cProduto  - Produto a ser transferido
@param cNumSc    - Solicitação de compra da transferência
@param cItmSc    - Item da SC da transferência
@param cItmGrdSc - Item grade da SC da transferência
@param cSituac   - Situação (1=Não atendido;2=Atendido parcialmente;3=Atendido total)
@param nQuant    - Quantidade

@author Lucas Konrad França
@since 15/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function insereTemp(cNumMrp,cEmpOrig,cFilOrig,cEmpDest,cFilDest,cProd,cNumSc,cItmSc,cItmGrdSc,cSituac,nQuant)
   Local cQuery     := ""
   Local cNextAlias := GetNextAlias()
   Local nRecno     := 0
   Local nRet       := 0

   If lConsulta
      Return .T.
   EndIf

   cQuery := " SELECT COUNT(*) COUNTQTD "
   cQuery +=   " FROM A108QT "
   cQuery +=  " WHERE NRMRP   = '" + cNumMrp   + "' "
   cQuery += "    AND EMPORIG = '" + cEmpOrig  + "' "
   cQuery += "    AND FILORIG = '" + cFilOrig  + "' "
   cQuery += "    AND EMPDEST = '" + cEmpDest  + "' "
   cQuery += "    AND FILDEST = '" + cFilDest  + "' "
   cQuery += "    AND PRODUTO = '" + cProd     + "' "
   cQuery += "    AND NUMSC   = '" + cNumSc    + "' "
   cQuery += "    AND ITEMSC  = '" + cItmSc    + "' "
   cQuery += "    AND ITGRDSC = '" + cItmGrdSc + "' "

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
   nCount := (cNextAlias)->(COUNTQTD)
   //(cNextAlias)->(dbCloseArea())

   If nCount < 1
      
      cQuery := " SELECT MAX(R_E_C_N_O_) REC "
      cQuery +=   " FROM A108QT "
      
      cNextAlias := GetNextAlias()
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
      nRecno := (cNextAlias)->(REC)
      //(cNextAlias)->(dbCloseArea())
      nRecno++
      
      If cSituac == Nil
         cSituac := "1"
      EndIf
      If nQuant == Nil
         nQuant := 0
      EndIf

      //Faz a inclusão, pois ainda não existe o registro
      cQuery := " INSERT INTO A108QT(NRMRP, "
      cQuery +=                    " EMPORIG, "
      cQuery +=                    " FILORIG, "
      cQuery +=                    " EMPDEST, "
      cQuery +=                    " FILDEST, "
      cQuery +=                    " PRODUTO, "
      cQuery +=                    " NUMSC, "
      cQuery +=                    " ITEMSC, "
      cQuery +=                    " ITGRDSC, "
      cQuery +=                    " SITUAC, "
      cQuery +=                    " QUANT, "
      cQuery +=                    " R_E_C_N_O_) "
      cQuery +=           " VALUES('"  + cNumMrp   + "', "
      cQuery +=                   " '" + cEmpOrig  + "', "
      cQuery +=                   " '" + cFilOrig  + "', "
      cQuery +=                   " '" + cEmpDest  + "', "
      cQuery +=                   " '" + cFilDest  + "', "
      cQuery +=                   " '" + cProd     + "', "
      cQuery +=                   " '" + cNumSc    + "', "
      cQuery +=                   " '" + cItmSc    + "', "
      cQuery +=                   " '" + cItmGrdSc + "', "
      cQuery +=                   " '" + cSituac   + "', "
      cQuery +=                   "  " + cValToChar(nQuant) + " , "
      cQuery +=                   "  " + Str(nRecno) + " ) "
      
      nRet := TCSQLExec(cQuery)
      If nRet < 0
         Alert(TCSQLError())
      EndIf
   Else
      //Já existe o registro, apenas atualiza a quantidade e a situação
      cQuery := " UPDATE A108QT "
      If cSituac != Nil
         cQuery +=    " SET SITUAC = '" + cSituac + "' "
      Else
         cQuery +=    " SET QUANT  = "  + cValToChar(nQuant)
      EndIf
      cQuery +=  " WHERE NRMRP   = '" + cNumMrp   + "' "
      cQuery += "    AND EMPORIG = '" + cEmpOrig  + "' "
      cQuery += "    AND FILORIG = '" + cFilOrig  + "' "
      cQuery += "    AND EMPDEST = '" + cEmpDest  + "' "
      cQuery += "    AND FILDEST = '" + cFilDest  + "' "
      cQuery += "    AND PRODUTO = '" + cProd     + "' "
      cQuery += "    AND NUMSC   = '" + cNumSc    + "' "
      cQuery += "    AND ITEMSC  = '" + cItmSc    + "' "
      cQuery += "    AND ITGRDSC = '" + cItmGrdSc + "' "
      nRet := TCSQLExec(cQuery)
      If nRet < 0
         Alert(TCSQLError())
      EndIf
   EndIf

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} a108VldCpo
Validação dos campos. Insere registro na tabela temporária da quantidade.

@author Lucas Konrad França
@since 15/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Function a108VldCpo(uPar)
   Local nQuant  := 0
   Local cSituac := ""
   
   If ValType(uPar) == "N"
      cSituac := Nil
      nQuant  := uPar
   Else
      cSituac := uPar
      nQuant  := Nil
   EndIf
   
   insereTemp(cNrMrp,cEmpOrg,cFilOrg,cEmpDst,cFilDst,cProduto,cScSolic,cItemSc,cItGrdSc,cSituac,nQuant)

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA108ATU
Atualiza as informações da tabela SOU

@author Lucas Konrad França
@since 30/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Function PCPA108ATU()
   Local cSql := ""

   If !lConsulta
      Processa( {|| atuTrans() }, STR0036/*"Aguarde..."*/, STR0037,.F.) //"Atualizando informações das transferências..."
      Processa( {|| atuOrdens() }, STR0036/*"Aguarde..."*/, STR0073,.F.) //"Atualizando OPs/SCs"
      
      cSql := " DELETE FROM A108QT "
      TCSQLExec(cSql)

      cSql := " DELETE FROM A108DC "
      TCSQLExec(cSql)

      Processa( {|| buscaDados(.F.) }, STR0036 /*"Aguarde..."*/, STR0038/*"Executando consulta..."*/,.F.)
   EndIf
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} atuTrans
Atualiza as informações da tabela SOU

@author Lucas Konrad França
@since 30/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function atuTrans()
   Local cQuery    := ""
   Local cAlias    := GetNextAlias()
   Local cAliasSou := "BUSCSOU"
   Local nTotal    := 0
   Local nQtdTran  := 0
   Local nQuant    := 0
   Local nI        := 0

   cQuery := " SELECT COUNT(*) COUNTREC "
   cQuery +=   " FROM A108QT "
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   nTotal := (cAlias)->(COUNTREC)
   (cAlias)->(dbCloseArea())
   
   //Seta o valor total da régua
   ProcRegua(nTotal)
   cAlias := GetNextAlias()

   cQuery := " SELECT NRMRP, "  
   cQuery +=        " EMPORIG, "
   cQuery +=        " FILORIG, "
   cQuery +=        " EMPDEST, "
   cQuery +=        " FILDEST, "
   cQuery +=        " PRODUTO, "
   cQuery +=        " NUMSC, "  
   cQuery +=        " ITEMSC, " 
   cQuery +=        " ITGRDSC, "
   cQuery +=        " SITUAC, " 
   cQuery +=        " QUANT "
   cQuery +=  " FROM A108QT "
   
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   While !(cAlias)->(Eof())
      IncProc()
      nQtdTran := 0

      cQuery := "SELECT COUNT(*) COUNTREG "
      cQuery +=  " FROM " + RetSqlName("SOU") + " SOU "
      cQuery += " WHERE SOU.OU_FILIAL  = '" + xFilial("SOU")      + "' "
      cQuery +=   " AND SOU.OU_NRMRP   = '" + (cAlias)->(NRMRP)   + "' "
      cQuery +=   " AND SOU.OU_EMPORIG = '" + (cAlias)->(EMPORIG) + "' "
      cQuery +=   " AND SOU.OU_FILORIG = '" + (cAlias)->(FILORIG) + "' "
      cQuery +=   " AND SOU.OU_EMPDEST = '" + (cAlias)->(EMPDEST) + "' "
      cQuery +=   " AND SOU.OU_FILDEST = '" + (cAlias)->(FILDEST) + "' "
      cQuery +=   " AND SOU.OU_PROD    = '" + (cAlias)->(PRODUTO) + "' "
      cQuery +=   " AND SOU.OU_SCSOLIC = '" + (cAlias)->(NUMSC)   + "' "
      cQuery +=   " AND SOU.OU_ITEMSC  = '" + (cAlias)->(ITEMSC)  + "' "
      cQuery +=   " AND SOU.OU_ITGRDSC = '" + (cAlias)->(ITGRDSC) + "' "
      cQuery +=   " AND SOU.D_E_L_E_T_ = ' ' "
      
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSou,.T.,.T.)
      nRegSou := (cAliasSou)->(COUNTREG)
      (cAliasSou)->(dbCloseArea())

      cQuery := "SELECT SOU.R_E_C_N_O_ SOUREC "
      cQuery +=  " FROM " + RetSqlName("SOU") + " SOU "
      cQuery += " WHERE SOU.OU_FILIAL  = '" + xFilial("SOU")      + "' "
      cQuery +=   " AND SOU.OU_NRMRP   = '" + (cAlias)->(NRMRP)   + "' "
      cQuery +=   " AND SOU.OU_EMPORIG = '" + (cAlias)->(EMPORIG) + "' "
      cQuery +=   " AND SOU.OU_FILORIG = '" + (cAlias)->(FILORIG) + "' "
      cQuery +=   " AND SOU.OU_EMPDEST = '" + (cAlias)->(EMPDEST) + "' "
      cQuery +=   " AND SOU.OU_FILDEST = '" + (cAlias)->(FILDEST) + "' "
      cQuery +=   " AND SOU.OU_PROD    = '" + (cAlias)->(PRODUTO) + "' "
      cQuery +=   " AND SOU.OU_SCSOLIC = '" + (cAlias)->(NUMSC)   + "' "
      cQuery +=   " AND SOU.OU_ITEMSC  = '" + (cAlias)->(ITEMSC)  + "' "
      cQuery +=   " AND SOU.OU_ITGRDSC = '" + (cAlias)->(ITGRDSC) + "' "
      cQuery +=   " AND SOU.D_E_L_E_T_ = ' ' "
      cQuery += " ORDER BY SOU.OU_QTEST DESC, SOU.OU_QTPROD "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSou,.T.,.T.)

      While !(cAliasSou)->(Eof())
         SOU->(dbGoTo((cAliasSou)->(SOUREC)))
         RecLock("SOU",.F.)
            SOU->OU_SITUACA := (cAlias)->(SITUAC)
            If nRegSou == 1
               SOU->OU_QTMOVTO := (cAlias)->(QUANT)
            Else
               SOU->OU_QTMOVTO := 0
            EndIf
         MsUnLock()
         (cAliasSou)->(dbSkip())
      End
      nI := 1
      //Se existe mais de um registro, primeiro atualiza somente a situação de todos os registros, depois atualiza a quantidade.
      //Deve utilizar primeiro a quantidade de estoque.
      If nRegSou > 1
         (cAliasSou)->(dbGoTop())
         While !(cAliasSou)->(Eof()) .And. nQuant < (cAlias)->(QUANT)
            SOU->(dbGoTo((cAliasSou)->(SOUREC)))
            If SOU->(OU_QTEST) > SOU->(OU_QTMOVTO)
               If nI == nRegSou
                  nQuant := (cAlias)->(QUANT) - nQtdTran
               Else
                  If SOU->(OU_QTMOVTO)+((cAlias)->(QUANT)-nQtdTran) <= SOU->(OU_QTEST)
                     nQuant := (cAlias)->(QUANT)-nQtdTran
                  Else
                     nQuant := SOU->(OU_QTEST) - SOU->(OU_QTMOVTO)
                  EndIf
               EndIf
            Else
               If nI == nRegSou
                  nQuant := (cAlias)->(QUANT) - nQtdTran
               Else
                  If SOU->(OU_QTMOVTO)+((cAlias)->(QUANT)-nQtdTran) <= SOU->(OU_QTPROD)
                     nQuant := (cAlias)->(QUANT)-nQtdTran
                  Else
                     nQuant := SOU->(OU_QTPROD) - SOU->(OU_QTMOVTO)
                  EndIf
               EndIf
            EndIf
            nQtdTran += nQuant
            RecLock("SOU",.F.)
               SOU->OU_QTMOVTO := nQuant
            MsUnLock()
            nI++
            (cAliasSou)->(dbSkip())
         End
      EndIf
      (cAliasSou)->(dbCloseArea())
      (cAlias)->(dbSkip())
   End
   If Select(cAliasSou) > 0
      (cAliasSou)->(dbCloseArea())
   EndIf
   If Select(cAlias) > 0
      (cAlias)->(dbCloseArea())
   EndIf
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} atuOrdens
Atualiza as OPs/SCs de acordo com a centralização realizada

@author Lucas Konrad França
@since 15/06/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function atuOrdens()
   Local cQuery    := ""
   Local cAlias    := GetNextAlias()
   Local cNomJob   := ""
   Local aEmp      := {}
   Local aJobs     := {}
   Local nI        := 0
   Local nRetry_0  := 0
   Local nRetry_1  := 0
   Local lErro     := .F.

   cQuery := " SELECT DISTINCT EMPORIG EMPRESA, "
   cQuery +=        " FILORIG FILIAL "
   cQuery +=   " FROM A108DC "
   cQuery +=  " UNION "
   cQuery += " SELECT DISTINCT EMPDEST EMPRESA, "
   cQuery +=        " FILDEST FILIAL "
   cQuery +=   " FROM A108DC "

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   While (cAlias)->(!Eof())
      aAdd(aEmp ,{ (cAlias)->(EMPRESA),;
                   (cAlias)->(FILIAL) })
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   ProcRegua(Len(aEmp)*2)
   PutGlbValue("A108PROCESS","PROCESSANDO")
   GlbUnLock()
   
   For nI := 1 To Len(aEmp)
      cNomJob := "A108ATUORD"+AllTrim(aEmp[nI,1])+AllTrim(aEmp[nI,2])
      aAdd(aJobs,{cNomJob,aEmp[nI,1],aEmp[nI,2]})
      
      PutGlbValue(cNomJob,"0")
      GlbUnLock()
      
      StartJob("A108AtuOrd",GetEnvServer(),.F.,aEmp[nI,1],aEmp[nI,2],cNomJob,aTabNames,cLastMrp,__cUserId)
      IncProc()
   Next nI

   For nI := 1 To Len(aJobs)
      IncProc()
      While .T.
         Do Case
         Case GetGlbValue(aJobs[nI,1]) == '0'
            If nRetry_0 > 50
               //Conout(Replicate("-",65))
               //Conout("Nao foi possivel realizar a subida da thread "+aJobs[nI,1]) //"Nao foi possivel realizar a subida da thread "
               //Conout(Replicate("-",65))
               Final("Nao foi possivel realizar a subida da thread "+aJobs[nI,1]) //"Nao foi possivel realizar a subida da thread "
             Else
               nRetry_0 ++
            EndIf
         
         //Tratamento para erro de conexao
         Case GetGlbValue(aJobs[nI,1]) == '10'
            If nRetry_1 > 10
               //Conout(Replicate("-",65))
               //Conout("Erro de conexao na thread "+aJobs[nI,1])   //"Erro de conexao na thread "
               //Conout("Numero de tentativas excedido")               // "Numero de tentativas excedido"
               //Conout(Replicate("-",65))
               Final("Erro de conexao na thread "+aJobs[nI,1])    //"Erro de conexao na thread "
            Else
               //Inicializa variavel global de controle de Job
               PutGlbValue(aJobs[nI,1],"0")
               GlbUnLock()
               
               //Reiniciar thread
               //Conout(Replicate("-",65))
               //Conout("Erro de conexao na thread "+aJobs[nI,1])         //"Erro de conexao na thread "
               //Conout("Reiniciando a thread : "+aJobs[nI,1])
               //Conout("Tentativa numero: "+StrZero(nRetry_1,2)) //"Tentativa numero: "
               //Conout(Replicate("-",65))
               StartJob("A108VerEmp",GetEnvServer(),.F.,aJobs[nI,2],aJobs[nI,3],aJobs[nI,1])
            EndIf
            nRetry_1 ++
         
         Case GetGlbValue(aJobs[nI,1]) == '20'
            //Conout(Replicate("-",65))
            //Conout("Erro na execucao da thread"+aJobs[nI,1])         //"Erro na execucao da thread"
            //Conout(Replicate("-",65))
            Final("Erro na execucao da thread "+aJobs[nI,1])
         
         Case GetGlbValue(aJobs[nI,1]) == '30'
            //Conout(Replicate("-",65))                             
            //Conout("PCPA108: Erro de aplicacao na thread " + aJobs[nI,1])          
            //Conout(Replicate("-",65))                                
            
            //Atualiza o log de processamento             
            Final("PCPA108: Erro de aplicacao na thread"+GetGlbValue(AllTrim(AllTrim(aJobs[nI,1])+"ERRO")))

         //THREAD PROCESSADA CORRETAMENTE
         Case GetGlbValue(aJobs[nI,1]) == '3'
            //Conout("Job "+ aJobs[nI,1] +" executado com sucesso.")
            ClearGlbValue (aJobs[nI,1])
            Exit
         EndCase
         Sleep(500)
      End
      If !Empty(GetGlbValue(cNomJob+"ERRO"))
         lErro := .T.
         cErro := GetGlbValue(cNomJob+"ERRO")
      EndIf
   Next nI
   If lErro
      PutGlbValue("A108PROCESS","ERRO")
   Else
      PutGlbValue("A108PROCESS","FIM")
   EndIf
   GlbUnLock()

   If lErro
      Aviso("Erro",cErro,{"OK"},3)
   EndIf

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA108REL
Inicia a geração do relatório

@author Lucas Konrad França
@since 30/04/2015
@version 1.0
/*/
//-----------------------------------------------------------------
Function PCPA108REL()
   Local oReport 
   
   //Variáveis utilizadas para impressão do relatório
   Private cCol1      := ""
   Private nQuant     := 0
   Private cNumOP     := ""
   Private cSituacao  := ""
   Private cNumSC     := ""
   Private cItemSC    := ""
   Private cDestino   := ""
   Private nQtMovto   := ""
   Private cUnderline := ""

   oReport := ReportDef()
   oReport:PrintDialog()
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc}
Definição do relatório

@author Lucas Konrad França
@since 30/04/2015
@version 1.0         
/*/ 
//----------------------------------------------------------
Static Function ReportDef()
   Local oReport, oSection, oCell
   Local cTitle := OemToAnsi(STR0035) //Sugestões de transferência

   //-- Criacao do componente de impressao
   oReport := TReport():New('PCPA108',cTitle,'PCPA108',{|oReport| ReportPrint(oReport)},STR0035) //'Sugestões de transferência'
    
   oReport:SetLandscape()

   //Seção cabeçalho
   oSection := TRSection():New(oReport,cTitle) 

   //Celula do cabeçalho
   TRCell():New(oSection,"",,"_"+Space(11)+STR0010/*Produto*/,,57,.F.,{|| cCol1}) // (Num MRP) OU (Empresa/Filial - Descrição) OU (Produto)
   TRCell():New(oSection,"",,STR0033,X3Picture("OU_QTPROD"),TamSx3("OU_QTPROD")[1],.F.,{|| nQuant}) //Quantidade
   TRCell():New(oSection,"",,STR0018,X3Picture("OU_OPPROD"),TamSx3("OU_OPPROD")[1]+TamSx3("OU_ITEMOP")[1]+TamSx3("OU_C2SEQ")[1],.F.,{|| cNumOP}) //Ordem produção
   TRCell():New(oSection,"",,STR0048,,43,.F.,{|| cDestino}) //Destino
   TRCell():New(oSection,"",,STR0047,X3Picture("OU_SCSOLIC"),TamSx3("OU_SCSOLIC")[1]+3,.F.,{|| cNumSC}) //Num SC
   TRCell():New(oSection,"",,STR0046,X3Picture("OU_ITEMSC"),TamSx3("OU_ITEMSC")[1]+3,.F.,{|| cItemSC}) //Item SC
   TRCell():New(oSection,"",,STR0045,,21,.F.,{|| cSituacao}) //Situação
   TRCell():New(oSection,"",,STR0044,X3Picture("OU_QTMOVTO"),TamSx3("OU_QTMOVTO")[1],.F.,{|| nQtMovto}) //Qtd movto
   TRCell():New(oSection,"",,STR0043,,35,.F.,{|| cUnderline}) //"Atendimento"

Return oReport

//----------------------------------------------------------
/*/{Protheus.doc}
Impressão do relatório

@author Lucas Konrad França
@since 30/04/2015
@version 1.0         
/*/ 
//----------------------------------------------------------
Static Function ReportPrint(oReport)
   Local oSection   := oReport:Section(1)
   Local cQuery     := ""
   Local cQueryCnt  := ""
   Local cAliasOu   := GetNextAlias()
   Local cAliasCnt  := GetNextAlias()
   Local cMrpBkp    := ""
   Local cEmpBkp    := ""
   Local cFilBkp    := ""
   Local cStrMrp    := STR0032
   Local cDataBkp   := StoD("19000101")
   Local cNumMrp    := ""
   Local cFilOrigem := ""
   Local cEmpOrigem := ""
   Local cDesOrigem := ""
   Local cFilDestin := ""
   Local cEmpDestin := ""
   Local cDesDestin := ""
   Local cDatTrans  := ""
   Local nTotal     := 0

   cProdDe    := mv_par01
   cProdAte   := mv_par02
   cEmpOrgDe  := mv_par03
   cEmpOrgAte := mv_par04
   cEmpDstDe  := mv_par05
   cEmpDstAte := mv_par06
   cNumMrpDe  := mv_par07
   cNumMrpAte := mv_par08

   cStrMrp := Padr(cStrMrp,Len(STR0031) -1,".")
   cStrMrp += ": "

   cQuery := " SELECT SOU.OU_NRMRP, "
   cQuery +=        " SOU.OU_EMPORIG, "
   cQuery +=        " SOU.OU_FILORIG, "
   cQuery +=        " SOU.OU_EMPDEST, "
   cQuery +=        " SOU.OU_FILDEST, "
   cQuery +=        " SOU.OU_DTTRANS, "
   cQuery +=        " SOU.OU_PROD, "
   cQuery +=        " SB1.B1_DESC, "
   cQuery +=        " SOU.OU_OPPROD, "
   cQuery +=        " SOU.OU_C2SEQ, "
   cQuery +=        " SOU.OU_ITEMOP, "
   cQuery +=        " SOU.OU_SCSOLIC, "
   cQuery +=        " SOU.OU_ITEMSC, "
   cQuery +=        " SOU.OU_ITGRDSC, "
   If !lConsulta
      cQuery +=       " CASE WHEN (SELECT COUNT(*) "
      cQuery +=                    " FROM A108QT "
      cQuery +=                   " WHERE A108QT.NRMRP   = SOU.OU_NRMRP "
      cQuery +=                     " AND A108QT.EMPORIG = SOU.OU_EMPORIG "
      cQuery +=                     " AND A108QT.FILORIG = SOU.OU_FILORIG "
      cQuery +=                     " AND A108QT.EMPDEST = SOU.OU_EMPDEST "
      cQuery +=                     " AND A108QT.FILDEST = SOU.OU_FILDEST "
      cQuery +=                     " AND A108QT.PRODUTO = SOU.OU_PROD "
      cQuery +=                     " AND A108QT.NUMSC   = SOU.OU_SCSOLIC "
      cQuery +=                     " AND A108QT.ITEMSC  = SOU.OU_ITEMSC "
      cQuery +=                     " AND A108QT.ITGRDSC = SOU.OU_ITGRDSC) > 0 "
      cQuery +=            " THEN "
      cQuery +=                " (SELECT SITUAC "
      cQuery +=                    " FROM A108QT "
      cQuery +=                   " WHERE A108QT.NRMRP   = SOU.OU_NRMRP "
      cQuery +=                     " AND A108QT.EMPORIG = SOU.OU_EMPORIG "
      cQuery +=                     " AND A108QT.FILORIG = SOU.OU_FILORIG "
      cQuery +=                     " AND A108QT.EMPDEST = SOU.OU_EMPDEST "
      cQuery +=                     " AND A108QT.FILDEST = SOU.OU_FILDEST "
      cQuery +=                     " AND A108QT.PRODUTO = SOU.OU_PROD "
      cQuery +=                     " AND A108QT.NUMSC   = SOU.OU_SCSOLIC "
      cQuery +=                     " AND A108QT.ITEMSC  = SOU.OU_ITEMSC "
      cQuery +=                     " AND A108QT.ITGRDSC = SOU.OU_ITGRDSC) "
      cQuery +=            " ELSE "
      cQuery +=              " SOU.OU_SITUACA "
      cQuery +=       " END OUSITUAC, "
      cQuery +=       " CASE WHEN (SELECT COUNT(*) "
      cQuery +=                    " FROM A108QT "
      cQuery +=                   " WHERE A108QT.NRMRP   = SOU.OU_NRMRP "
      cQuery +=                     " AND A108QT.EMPORIG = SOU.OU_EMPORIG "
      cQuery +=                     " AND A108QT.FILORIG = SOU.OU_FILORIG "
      cQuery +=                     " AND A108QT.EMPDEST = SOU.OU_EMPDEST "
      cQuery +=                     " AND A108QT.FILDEST = SOU.OU_FILDEST "
      cQuery +=                     " AND A108QT.PRODUTO = SOU.OU_PROD "
      cQuery +=                     " AND A108QT.NUMSC   = SOU.OU_SCSOLIC "
      cQuery +=                     " AND A108QT.ITEMSC  = SOU.OU_ITEMSC "
      cQuery +=                     " AND A108QT.ITGRDSC = SOU.OU_ITGRDSC) > 0 "
      cQuery +=            " THEN "
      cQuery +=                " (SELECT QUANT "
      cQuery +=                    " FROM A108QT "
      cQuery +=                   " WHERE A108QT.NRMRP   = SOU.OU_NRMRP "
      cQuery +=                     " AND A108QT.EMPORIG = SOU.OU_EMPORIG "
      cQuery +=                     " AND A108QT.FILORIG = SOU.OU_FILORIG "
      cQuery +=                     " AND A108QT.EMPDEST = SOU.OU_EMPDEST "
      cQuery +=                     " AND A108QT.FILDEST = SOU.OU_FILDEST "
      cQuery +=                     " AND A108QT.PRODUTO = SOU.OU_PROD "
      cQuery +=                     " AND A108QT.NUMSC   = SOU.OU_SCSOLIC "
      cQuery +=                     " AND A108QT.ITEMSC  = SOU.OU_ITEMSC "
      cQuery +=                     " AND A108QT.ITGRDSC = SOU.OU_ITGRDSC) "
      cQuery +=            " ELSE "
      cQuery +=              " SOU.OU_QTMOVTO "
      cQuery +=       " END QTMOVTO, "
   Else
      cQuery +=       " SOU.OU_SITUACA OUSITUAC, "
      cQuery +=       " SOU.OU_QTMOVTO QTMOVTO, "
   EndIf
   cQuery +=        " SUM(SOU.OU_QTPROD+SOU.OU_QTEST) QUANT "
   cQuery +=   " FROM " + RetSqlName("SOU") + " SOU "
   cQuery +=          " LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 "
   cQuery +=          " ON SB1.B1_COD = SOU.OU_PROD "
   cQuery +=  " WHERE SOU.OU_PROD    BETWEEN '" + cProdDe   + "' AND '" + cProdAte   + "' "
   cQuery +=    " AND SOU.OU_EMPORIG BETWEEN '" + cEmpOrgDe + "' AND '" + cEmpOrgAte + "' "
   cQuery +=    " AND SOU.OU_EMPDEST BETWEEN '" + cEmpDstDe + "' AND '" + cEmpDstAte + "' "
   cQuery +=    " AND SOU.OU_NRMRP   BETWEEN '" + cNumMrpDe + "' AND '" + cNumMrpAte + "' "
   cQuery +=    " AND SOU.D_E_L_E_T_ = ' ' "
   cQuery +=  " GROUP BY SOU.OU_NRMRP, "
   cQuery +=        " SOU.OU_EMPORIG, "
   cQuery +=        " SOU.OU_FILORIG, "
   cQuery +=        " SOU.OU_EMPDEST, "
   cQuery +=        " SOU.OU_FILDEST, "
   cQuery +=        " SOU.OU_DTTRANS, "
   cQuery +=        " SOU.OU_PROD, "
   cQuery +=        " SB1.B1_DESC, "
   cQuery +=        " SOU.OU_OPPROD, "
   cQuery +=        " SOU.OU_C2SEQ, "
   cQuery +=        " SOU.OU_ITEMOP, "
   cQuery +=        " SOU.OU_SCSOLIC, "
   cQuery +=        " SOU.OU_ITEMSC, "
   cQuery +=        " SOU.OU_SITUACA, "
   cQuery +=        " SOU.OU_QTMOVTO, "
   cQuery +=        " SOU.OU_ITGRDSC "
   
   cQueryCnt := " SELECT COUNT(*) TOTAL FROM (" + cQuery + " ) t"
   cQueryCnt := ChangeQuery(cQueryCnt)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasCnt,.T.,.T.)
   nTotal := (cAliasCnt)->(TOTAL)
   (cAliasCnt)->(dbCloseArea())

   oReport:SetMeter(nTotal)

   cQuery +=  " ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 "
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOu,.T.,.T.)
   
   oSection:Init()
   While (cAliasOu)->(!Eof())
      oReport:IncMeter()
      //Imprime o número do MRP
      cNumMrp    := (cAliasOu)->(OU_NRMRP)
      nQuant     := Nil
      cNumOP     := Nil
      cNumSC     := Nil
      cItemSC    := Nil
      cDestino   := Nil
      cSituacao  := Nil
      nQtMovto   := Nil
      cUnderline := Nil

      If cMrpBkp != cNumMrp
         oReport:ThinLine()
         oReport:SkipLine(1)
         cCol1  := cStrMrp+cNumMrp // "MRP...: "
         oSection:PrintLine()
         cMrpBkp := cNumMrp
         cEmpOrigem := ""
         cFilOrigem := ""
      EndIf

      //Imprime a Empresa/Filial
      cEmpOrigem := (cAliasOu)->(OU_EMPORIG)
      cFilOrigem := (cAliasOu)->(OU_FILORIG)
      If cEmpBkp != cEmpOrigem .Or. cFilBkp != cFilOrigem
         cDesOrigem := AllTrim(FWEmpName(cEmpOrigem)) + " / " + AllTrim(FWFilialName(cEmpOrigem,cFilOrigem,1))
         cCol1  := STR0031+" "+ AllTrim(cEmpOrigem) + "/" + AllTrim(cFilOrigem) + " - " + AllTrim(cDesOrigem) //Empresa
         oReport:SkipLine(1)
         oSection:PrintLine()
         cEmpBkp  := cEmpOrigem
         cFilBkp  := cFilOrigem
         cDataBkp := StoD("19000101")
      EndIf
      //Imprime a data de transferência
      cDatTrans := StoD((cAliasOu)->(OU_DTTRANS))
      If cDataBkp != cDatTrans
         cCol1 := Space(Len(STR0031)+1)+STR0030+" "+ DtoC(cDatTrans) //"Data movimento: "
         oSection:PrintLine()
         cDataBkp := cDatTrans
      EndIf

      //Produto
      cCol1 := Space(12) + AllTrim((cAliasOu)->(OU_PROD)) + " - " + (cAliasOu)->(B1_DESC)
      
      //Quantidade
      nQuant := (cAliasOu)->(QUANT)
      
      //Ordem de produção
      cNumOP  := AllTrim((cAliasOu)->(OU_OPPROD))+AllTrim((cAliasOu)->(OU_ITEMOP))+AllTrim((cAliasOu)->(OU_C2SEQ))
      
      If Empty(cNumOP) 
         cNumOP := STR0042 //"ESTOQUE"
      EndIf

      //Solicitação de compra
      cNumSC  := (cAliasOu)->(OU_SCSOLIC)
      cItemSC := (cAliasOu)->(OU_ITEMSC)

      //Empresa de destino
      cEmpDestin := (cAliasOu)->(OU_EMPDEST)
      cFilDestin := (cAliasOu)->(OU_FILDEST)
      cDesDestin := AllTrim(FWEmpName(cEmpDestin)) + " / " + AllTrim(FWFilialName(cEmpDestin,cFilDestin,1))
      cDestino   := AllTrim(cEmpDestin) + "/" + AllTrim(cFilDestin) + " - " + AllTrim(cDesDestin) 
      
      //Situação e quantidade de movimento.
      nQtMovto   := (cAliasOu)->(QTMOVTO)
      Do Case 
         Case (cAliasOu)->(OUSITUAC) == "1"
            cSituacao := STR0039 //"Não atendido"
         Case (cAliasOu)->(OUSITUAC) == "2"
            cSituacao := STR0041 //"Atendido parcialmente"
         Case (cAliasOu)->(OUSITUAC) == "3"
            cSituacao := STR0040 //"Atendido total"
         Otherwise
            cSituacao := STR0039 //"Não atendido"
      EndCase
      
      cUnderline := "_________________________________________________________________"

      //Imprime a linha
      oSection:PrintLine()
      (cAliasOu)->(dbSkip())
   End
   oSection:Finish()
   (cAliasOu)->(dbCloseArea())
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} limpaTemp
Limpa as tabelas temporarias do programa.

@author Lucas Konrad França
@since 10/06/2015
@version 1.0         
/*/ 
//----------------------------------------------------------
Static Function limpaTemp()
   Local cSql  := ""
   Local aArea := GetArea()

   cSql := " DELETE FROM A108QT "
   If TCSQLExec(cSql) < 0
      Alert(TCSQLError())
   EndIf

   cSql := " DELETE FROM A108DC "
   If TCSQLExec(cSql) < 0
      Alert(TCSQLError())
   EndIf

   RestArea(aArea)
Return Nil

Static Function DlgAlert(cMsg)
   DEFINE MSDIALOG oDlgAlert TITLE "AVISO" FROM 0,0 TO 150,350 PIXEL

   @ 015,005 SAY oMsg VAR cMsg OF oDlgAlert SIZE 165,70 FONT (TFont():New('Arial', nil, -12, .T.,)) PIXEL

   @ 60,73 BUTTON oBtn PROMPT "OK"  SIZE 30,11 ACTION {||oDlgAlert:End()} OF oDlgAlert PIXEL 

   ACTIVATE MSDIALOG oDlgAlert CENTER
Return Nil

/*

----------------------------------------
 FUNÇÕES EXECUTADAS VIA JOB
----------------------------------------

*/
//----------------------------------------------------------
/*/{Protheus.doc} A108VerEmp
Carrega o nome das tabelas SC1 e SC2 e o seu campo filial.

@param cEmp - Empresa
@param cFil - Filial 
@param cNomJob - Controle dos jobs executados.

@author Lucas Konrad França
@since 10/06/2015
@version 1.0         
/*/ 
//----------------------------------------------------------
Function A108VerEmp(cEmp,cFil,cNomJob)
   Local cTabName   := ""
   Local cFiltroFil := ""

   //Variáveis para tratar as exceções
   Private bError      := { |e| oError := e }
   Private bErrorBlock := ErrorBlock( bError )
   Private oError

   BEGIN SEQUENCE
      //STATUS 1 - Iniciando execucao do Job
      PutGlbValue(cNomJob, "1" )
      GlbUnLock()
   END SEQUENCE 
   If ValType(oError) != "U"
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao iniciar a execucao do Job.") //"Erro ao iniciar a execucao do Job."
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue(cNomJob, "10" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
      //Seta job para nao consumir licensas
      RpcSetType(3)
      
      //Seta job para empresa filial desejada
      RpcSetEnv(cEmp,cFil,,,'EST')
      
      //STATUS 2 - Conexao efetuada com sucesso
      PutGlbValue(cNomJob, "2" )
      GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao efetuar a conexão.")
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue(cNomJob, "20" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
      cTabName   := RetSqlName("SC1")
      cFiltroFil := xFilial("SC1")
      PutGlbValue(cNomJob+"C1NM", cTabName )
      GlbUnLock()
      PutGlbValue(cNomJob+"C1FL", cFiltroFil )
      GlbUnLock()
      
      cTabName   := RetSqlName("SC2")
      cFiltroFil := xFilial("SC2")
      PutGlbValue(cNomJob+"C2NM", cTabName )
      GlbUnLock()
      PutGlbValue(cNomJob+"C2FL", cFiltroFil )
      GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao efetuar o processamento do Job.") //"Erro ao efetuar o processamento do Job."
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue(cNomJob, "30" )
      PutGlbValue(cNomJob+"ERRO", oError:Description + oError:ErrorStack )
      GlbUnLock()
      Return
   EndIf

   //STATUS 3 - Processamento efetuado com sucesso
   PutGlbValue(cNomJob,"3")
   GlbUnLock()
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} A108AtuOrd
Atualiza as OPs/SCs

@param cEmp     - Empresa
@param cFil     - Filial 
@param cNomJob  - Controle dos jobs executados.
@param aTabelas - Array com o nome das tabelas SC1 e SC2

@author Lucas Konrad França
@since 16/06/2015
@version 1.0         
/*/ 
//----------------------------------------------------------
Function A108AtuOrd(cEmp,cFil,cNomJob,aTabelas,cLastMrp,cUsuario)
   Local cQuery    := ""
   Local cAlias    := ""
   Local cAliasDoc := "GETDOC"
   Local cAliasSc  := "SC1OP"
   Local aCab      := {}
   Local aItem     := {}
   Local aRecSC1   := {}
   Local aErroAuto := {}
   Local nTamNum   := 0
   Local nTamItm   := 0
   Local nTamSeq   := 0
   Local nTamFil   := 0
   Local nRecSC1   := 0
   Local nI        := 0
   Local nX        := 0
   Local cNumOld   := ""
   Local cItemOld  := ""
   Local cSeqOld   := ""
   Local cNumNovo  := ""
   Local cItemNovo := ""
   Local cSeqNovo  := ""
   Local cOpSc1    := ""
   Local cDoc      := ""
   Local cNewDoc   := ""
   Local cPresel   := ""
   Local cLogErro  := ""

   //Variáveis para tratar as exceções
   Private bError      := { |e| oError := e }
   Private bErrorBlock := ErrorBlock({|e| a108errblk(e)}) //ErrorBlock( bError )
   Private oError
   
   Private lMsErroAuto := .F.
   Private lAutoErrNoFile := .T.

   BEGIN SEQUENCE
      //STATUS 1 - Iniciando execucao do Job
      PutGlbValue(cNomJob, "1" )
      PutGlbValue(cNomJob+"ERRO", "")
      GlbUnLock()
   END SEQUENCE 
   If ValType(oError) != "U"
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao iniciar a execucao do Job.") //"Erro ao iniciar a execucao do Job."
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue(cNomJob, "10" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
      //Seta job para nao consumir licensas
      RpcSetType(3)
      
      //Seta job para empresa filial desejada
      RpcSetEnv(cEmp,cFil,,,'EST')
      
      //STATUS 2 - Conexao efetuada com sucesso
      PutGlbValue(cNomJob, "2" )
      GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao efetuar a conexão.")
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue(cNomJob, "20" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
      cUserName := UsrRetName(cUsuario)
      SetFunName("PCPA108")
      nTamNum   := TamSX3("C2_NUM")[1]
      nTamItm   := TamSX3("C2_ITEM")[1]
      nTamSeq   := TamSX3("C2_SEQUEN")[1]
      nTamFil   := TamSX3("OQ_FILEMP")[1]
      
      //Abre a transação
      BeginTran()

      //Realiza o cancelamento das ordens.
      cAlias := GetNextAlias()
      cQuery := " SELECT PRODUTO, "
      cQuery +=        " NUMOP, "
      cQuery +=        " NUMSC "
      cQuery +=   " FROM A108DC "
      cQuery +=  " WHERE EMPORIG = '" + cEmp + "' "
      cQuery +=    " AND FILORIG = '" + cFil + "' "
      cQuery +=  " ORDER BY 2 DESC "

      cQuery := ChangeQuery(cQuery)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

      While (cAlias)->(!Eof())
         aCab        := {}
         aItem       := {}
         aRecSC1     := {}

         lMsErroAuto := .F.
         cOpSc1      := ""
         nRecSC1     := 0
         //Se o NUMOP estiver vazio, então é uma SC.
         If Empty((cAlias)->(NUMOP))
            dbSelectArea("SC1")
            SC1->(dbSetOrder(1))
            If SC1->(dbSeek(xFilial("SC1")+AllTrim((cAlias)->(NUMSC))))
               aCab := {{"C1_NUM", SC1->C1_NUM, Nil}}
               aItem := {{{"C1_ITEM",SC1->C1_ITEM,Nil}}}
               nRecSC1 := SC1->(Recno())
               If !Empty(SC1->C1_OP)
                  cOpSc1 := SC1->C1_OP
                  RecLock("SC1",.F.)
                     SC1->C1_OP := ""
                  MsUnLock()
               EndIf
               lMsErroAuto := .F.
               MSExecAuto({|v,x,y| MATA110(v,x,y)},aCab,aItem,5)
               If lMsErroAuto
                  If !Empty(cOpSc1)
                     SC1->(dbGoTo(nRecSC1))
                     RecLock("SC1",.F.)
                        SC1->C1_OP := cOpSc1
                     MsUnLock()
                  EndIf
                  //Conout("Verificar inconsistencia de rotina automatica em Distribuicao - arquivo : "+NomeAutoLog())
                  DisarmTransaction()
                  aErroAuto := GetAutoGRLog()
                  For nX := 1 To Len(aErroAuto)
                     cLogErro += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nX], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|")
                  Next nX
                  PutGlbValue(cNomJob+"ERRO",cLogErro)
                  Exit
               EndIf
            EndIf
         Else
            dbSelectArea("SC2")
            SC2->(dbSetOrder(1))
            If SC2->(dbSeek(xFilial("SC2")+AllTrim((cAlias)->(NUMOP))))
               aCab := {{"C2_NUM"      ,SC2->C2_NUM    ,Nil},;
                        {'C2_ITEM'     ,SC2->C2_ITEM   ,Nil},;
                        {'C2_SEQUEN'   ,SC2->C2_SEQUEN ,Nil},;
                        {'C2_ITEMGRD'  ,SC2->C2_ITEMGRD,Nil}}

               cQuery := " SELECT SC1.R_E_C_N_O_ RECSC1, "
               cQuery +=        " SC1.C1_OP "
               cQuery +=   " FROM " + RetSqlName("SC1") + " SC1 "
               cQuery +=  " WHERE SC1.C1_FILIAL  = '" + xFilial("SC1") + "' "
               cQuery +=    " AND SC1.C1_OP      = '" + AllTrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN) + "' "
               cQuery +=    " AND SC1.D_E_L_E_T_ = ' ' "
 
               cQuery := ChangeQuery(cQuery)

               dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSc,.T.,.T.)

               While (cAliasSc)->(!Eof())
                  aAdd(aRecSC1,{(cAliasSc)->(RECSC1),(cAliasSc)->(C1_OP)})
                  SC1->(dbGoTo((cAliasSc)->(RECSC1)))
                  RecLock("SC1",.F.)
                     SC1->C1_OP := ""
                  MsUnLock()
                  (cAliasSc)->(dbSkip())
               End
               (cAliasSc)->(dbCloseArea())
               lMsErroAuto := .F.
               MSExecAuto({|x,Y| Mata650(x,Y)},aCab,5)
               If lMsErroAuto
                  For nI := 1 To Len(aRecSC1)
                     SC1->(dbGoTo(aRecSC1[nI,1]))
                     RecLock("SC1",.F.)
                        SC1->C1_OP := aRecSC1[nI,2]
                     MsUnLock()
                  Next nI
                  //Conout("Verificar inconsistencia de rotina automatica em Distribuicao - arquivo : "+NomeAutoLog())
                  DisarmTransaction()
                  aErroAuto := GetAutoGRLog()
                  For nX := 1 To Len(aErroAuto)
                     cLogErro += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nX], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|")
                  Next nX
                  PutGlbValue(cNomJob+"ERRO",cLogErro)
                  Exit
               EndIf
            EndIf
         EndIf
         (cAlias)->(dbSkip())
      End

      (cAlias)->(dbCloseArea())
      
      If !lMsErroAuto
         //Gera as novas ordens
         cAlias := GetNextAlias()
   
         cQuery := " SELECT PRODUTO, "
         cQuery +=        " NUMOP, "
         cQuery +=        " NUMSC, "
         cQuery +=        " QUANT, "
         cQuery +=        " EMPORIG, "
         cQuery +=        " FILORIG "
         cQuery +=   " FROM A108DC "
         cQuery +=  " WHERE EMPDEST = '" + cEmp + "' "
         cQuery +=    " AND FILDEST = '" + cFil + "' "
         cQuery +=  " ORDER BY 1, 2, 3 "
         cQuery := ChangeQuery(cQuery)
   
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   
         While (cAlias)->(!Eof())
            aCab    := {}
            aItem   := {}
            cNewDoc := ""
            //Se o NUMOP estiver vazio, então é uma SC.
            If Empty((cAlias)->(NUMOP))
               nPos := aScan(aTabelas,{|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim((cAlias)->(EMPORIG))+;
                                                                                        AllTrim((cAlias)->(FILORIG))+"SC1" })
               If nPos > 0
                  cQuery := " SELECT SC1.C1_EMISSAO, "
                  cQuery +=        " SC1.C1_FORNECE, "
                  cQuery +=        " SC1.C1_LOJA, "
                  cQuery +=        " SC1.C1_SOLICIT, "
                  cQuery +=        " SC1.C1_ITEM, "
                  cQuery +=        " SC1.C1_PRODUTO, "
                  cQuery +=        " SC1.C1_LOCAL, "
                  cQuery +=        " SC1.C1_DATPRF, "
                  cQuery +=        " SC1.C1_TPOP, "
                  cQuery +=        " SC1.C1_CC, "
                  cQuery +=        " SC1.C1_GRUPCOM, "
                  cQuery +=        " SC1.C1_OBS, "
                  cQuery +=        " SC1.C1_LOJA "
                  cQuery +=   " FROM " + aTabelas[nPos,4] + " SC1 "
                  cQuery +=  " WHERE SC1.C1_FILIAL = '" + aTabelas[nPos,5] + "' "
                  cQuery +=    " AND SC1.C1_NUM    = '" + (cAlias)->(NUMSC) + "' "
                  cQuery +=    " AND SC1.C1_SEQMRP = '" + cLastMrp + "' "
   
                  cQuery := ChangeQuery(cQuery)
                  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDoc,.T.,.T.)
                  If (cAliasDoc)->(!Eof())
                     aCab:={{"C1_EMISSAO" ,StoD((cAliasDoc)->(C1_EMISSAO)) ,Nil},; // Data de Emissao
                            {"C1_FORNECE" ,(cAliasDoc)->(C1_FORNECE) ,Nil},; // Fornecedor
                            {"C1_LOJA"    ,(cAliasDoc)->(C1_LOJA)    ,Nil},; // Loja do Fornecedor
                            {"C1_SOLICIT" ,(cAliasDoc)->(C1_SOLICIT) ,Nil}}
   
                     aItem:={{{"C1_ITEM"   ,(cAliasDoc)->(C1_ITEM)   ,Nil},; //Numero do Item
                              {"C1_PRODUTO",(cAliasDoc)->(C1_PRODUTO),Nil},; //Codigo do Produto
                              {"C1_QUANT"  ,(cAlias)->(QUANT)        ,Nil},; //Quantidade
                              {"C1_LOCAL"  ,(cAliasDoc)->(C1_LOCAL)  ,Nil},; //Armazem
                              {"C1_DATPRF" ,StoD((cAliasDoc)->(C1_DATPRF)) ,Nil},; //Data
                              {"C1_TPOP"   ,(cAliasDoc)->(C1_TPOP)   ,Nil},; // Tipo SC
                              {"C1_CC"     ,(cAliasDoc)->(C1_CC)     ,Nil},; //Centro de Custos
                              {"C1_GRUPCOM",(cAliasDoc)->(C1_GRUPCOM),Nil},; //Grupo de Compras
                              {"C1_SEQMRP" ,cLastMrp                 ,Nil},; //Numero da Programacao do MRP
                              {"C1_OBS"    ,(cAliasDoc)->(C1_OBS)    ,Nil},; //Observacao
                              {"AUTVLDCONT","N"                      ,Nil},;
                              {"C1_ORIGEM","PCPA108"                      ,Nil},;
                              {"C1_FORNECE",(cAliasDoc)->(C1_FORNECE),Nil},; //Fornecedor
                              {"C1_LOJA"   ,(cAliasDoc)->(C1_LOJA)   ,Nil}}} //Loja do Fornecedor
                     lMsErroAuto := .F.
                     MSExecAuto({|v,x,y| MATA110(v,x,y)},aCab,aItem,3)
                     If lMsErroAuto
                        DisarmTransaction()
                        aErroAuto := GetAutoGRLog()
                        For nX := 1 To Len(aErroAuto)
                           cLogErro += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nX], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|")
                        Next nX
                        PutGlbValue(cNomJob+"ERRO",cLogErro)
                        Exit
                     EndIf
                     cNewDoc := SC1->C1_NUM
                  EndIf
                  (cAliasDoc)->(dbCloseArea())
               EndIf
            Else
               nPos := aScan(aTabelas,{|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim((cAlias)->(EMPORIG))+;
                                                                                        AllTrim((cAlias)->(FILORIG))+"SC2" })
               If nPos > 0
                  cNumOld  := SubStr((cAlias)->(NUMOP),1,nTamNum)
                  cItemOld := SubStr((cAlias)->(NUMOP),nTamNum+1,nTamItm)
                  cSeqOld  := SubStr((cAlias)->(NUMOP),nTamNum+nTamItm+1,nTamSeq)
   
                  cQuery := " SELECT SC2.C2_DATPRI, "
                  cQuery +=        " SC2.C2_DATPRF, "
                  cQuery +=        " SC2.C2_LOCAL, "
                  cQuery +=        " SC2.C2_QUANT, "
                  cQuery +=        " SC2.C2_QTSEGUM, "
                  cQuery +=        " SC2.C2_UM, "
                  cQuery +=        " SC2.C2_CC, "
                  cQuery +=        " SC2.C2_SEGUM, "
                  cQuery +=        " SC2.C2_REVISAO, "
                  cQuery +=        " SC2.C2_TPOP, "
                  cQuery +=        " SC2.C2_EMISSAO, "
                  cQuery +=        " SC2.C2_OPC, "
                  cQuery +=        " SC2.C2_SEQMRP, "
                  cQuery +=        " SC2.C2_IDENT, "
                  cQuery +=        " SC2.C2_BATCH, "
                  cQuery +=        " SC2.C2_PRIOR "
                  cQuery +=  " FROM " + aTabelas[nPos,4] + " SC2 "
                  cQuery += " WHERE SC2.C2_NUM     = '" + cNumOld + "' "
                  cQuery +=   " AND SC2.C2_ITEM    = '" + cItemOld + "' "
                  cQuery +=   " AND SC2.C2_SEQUEN  = '" + cSeqOld + "' "
                  cQuery +=   " AND SC2.C2_SEQMRP  = '" + cLastMrp + "' "
                  cQuery +=   " AND SC2.C2_PRODUTO = '" + (cAlias)->(PRODUTO) + "' "
                  cQuery +=   " AND SC2.C2_FILIAL  = '" + aTabelas[nPos,5] + "' "
                  
                  cQuery := ChangeQuery(cQuery)
   
                  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDoc,.T.,.T.)
                  
                  If (cAliasDoc)->(!Eof())
                     cNumNovo  := GetNumSc2()
                     cItemNovo := "01"
                     cSeqNovo  := StrZero(1,nTamSeq)
                     cNewDoc := cNumNovo+cItemNovo+cSeqNovo
                     aCab := {{'C2_NUM'      ,cNumNovo                        ,"A710ValNum()"},;
                              {'C2_ITEM'     ,cItemNovo                       ,"A710ValNum()"},;
                              {'C2_SEQUEN'   ,cSeqNovo                        ,"A710ValNum()"},;
                              {'C2_PRODUTO'  ,(cAlias)->(PRODUTO)             ,NIL},;
                              {'C2_LOCAL'    ,(cAliasDoc)->(C2_LOCAL)         ,NIL},;
                              {'C2_QUANT'    ,(cAliasDoc)->(C2_QUANT)         ,NIL},;
                              {'C2_QTSEGUM'  ,(cAliasDoc)->(C2_QTSEGUM)       ,NIL},;
                              {'C2_UM'       ,(cAliasDoc)->(C2_UM),NIL}       ,;
                              {'C2_CC'       ,(cAliasDoc)->(C2_CC),NIL}       ,;
                              {'C2_SEGUM'    ,(cAliasDoc)->(C2_SEGUM)         ,NIL},;
                              {'C2_DATPRI'   ,StoD((cAliasDoc)->(C2_DATPRI))  ,NIL},;
                              {'C2_DATPRF'   ,StoD((cAliasDoc)->(C2_DATPRF))  ,NIL},;
                              {'C2_REVISAO'  ,(cAliasDoc)->(C2_REVISAO),NIL}  ,;
                              {'C2_TPOP'     ,(cAliasDoc)->(C2_TPOP),NIL}     ,;
                              {'C2_EMISSAO'  ,dDataBase                       ,NIL},;
                              {'C2_OPC'      ,(cAliasDoc)->(C2_OPC)           ,NIL},;
                              {'C2_SEQMRP'   ,(cAliasDoc)->(C2_SEQMRP)        ,Nil},;
                              {'C2_IDENT'    ,(cAliasDoc)->(C2_IDENT)         ,Nil},;
                              {'C2_BATCH'    ,(cAliasDoc)->(C2_BATCH)         ,NIL},;
                              {'C2_PRIOR'    ,(cAliasDoc)->(C2_PRIOR)         ,NIL},;
                              {'AUTEXPLODE'  ,'N'                             ,NIL}}
                     lMsErroAuto := .F.
                     msExecAuto({|x,Y| Mata650(x,Y)},aCab,3)
                     If lMsErroAuto
                        DisarmTransaction()
                        aErroAuto := GetAutoGRLog()
                        For nX := 1 To Len(aErroAuto)
                           cLogErro += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nX], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|")
                        Next nX
                        PutGlbValue(cNomJob+"ERRO",cLogErro)
                        Exit
                     EndIf
                  EndIf
                  (cAliasDoc)->(dbCloseArea())
               EndIf
            EndIf
            If Empty((cAlias)->(NUMOP))
               cDoc := (cAlias)->(EMPORIG)+(cAlias)->(FILORIG)+(cAlias)->(NUMSC)
            Else
               cDoc := (cAlias)->(EMPORIG)+(cAlias)->(FILORIG)+(cAlias)->(NUMOP)
            EndIf
            dbSelectArea("SOQ")
            SOQ->(dbSetOrder(4))
            If !SOQ->(dbSeek(xFilial("SOQ")+cEmpAnt+PadR(cFilAnt,nTamFil)+"TRA"+cDoc))
               RecLock("SOQ",.T.)
                  SOQ->OQ_FILIAL := xFilial("SOQ")
                  SOQ->OQ_EMP    := cEmpAnt
                  SOQ->OQ_FILEMP := cFilAnt
                  SOQ->OQ_DTOG   := DATE()
                  SOQ->OQ_PERMRP := "001"
                  SOQ->OQ_NRMRP  := cLastMrp
                  SOQ->OQ_NRLV   := "01"
                  SOQ->OQ_PROD   := (cAlias)->(PRODUTO)
                  SOQ->OQ_ALIAS  := "TRA"
                  SOQ->OQ_TPRG   := "2"
                  SOQ->OQ_DOC    := cDoc
                  SOQ->OQ_DOCKEY := cNewDoc
                  If Empty((cAlias)->(NUMOP))
                     SOQ->OQ_ITEM := "SC"
                  Else
                     SOQ->OQ_ITEM := "OP"
                  EndIf
                  SOQ->OQ_QUANT := (cAlias)->(QUANT)
               MsUnLock()
            EndIf
            (cAlias)->(dbSkip())
         End
      EndIf
   END SEQUENCE
   If ValType(oError) != "U"
      DisarmTransaction()
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao efetuar o processamento do Job.") //"Erro ao efetuar o processamento do Job."
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue(cNomJob, "30" )
      PutGlbValue(cNomJob+"ERRO", oError:Description + oError:ErrorStack )
      GlbUnLock()
      Return
   EndIf

   //STATUS 3 - Processamento efetuado com sucesso
   PutGlbValue(cNomJob,"3")
   GlbUnLock()
   
   //Se não ocorreu nenhum erro, aguarda todas as threads finalizarem o processamento, e se não ocorreu nenhum
   //erro em nenhuma thread, faz o commit das informações.
   If !lMsErroAuto
      //Enquanto as Threads estiverem processando, aguarda.
      While GetGlbValue("A108PROCESS") == "PROCESSANDO"
         Sleep(1000)
      End
      If GetGlbValue("A108PROCESS") == "FIM"
         EndTran()
      Else
         DisarmTransaction()
      EndIf
   EndIf
Return Nil

Function a108errblk(e)
   //conout(Replicate("-",70) + CHR(10) + AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack) + CHR(10) + Replicate("-",70))
BREAK