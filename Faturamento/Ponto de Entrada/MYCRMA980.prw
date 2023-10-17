//Bibliotecas
#Include "Totvs.ch"
#INCLUDE "PROTHEUS.CH"
  
/*/{Protheus.doc} User Function CRMA980
Novo cadastro de Clientes
@author Atilio
@since 13/07/2023
@version 1.0
@obs Codigo gerado automaticamente pelo Autumn Code Maker
     *-------------------------------------------------*
     Por se tratar de um p.e. em MVC, salve o nome do 
     arquivo diferente, por exemplo, CRMA980_pe.prw 
 admin    *-----------------------------------------------*
     A documentacao de como fazer o p.e. esta disponivel em https://tdn.totvs.com/pages/releaseview.action?pageId=208345968 
@see http://autumncodemaker.com
/*/
User Function CRMA980()

Local aArea := FWGetArea()
Local aParam := PARAMIXB 
Local xRet := .T.
Local oObj := Nil
Local cIdPonto := ""
Local cIdModel := ""
    
//Se tiver parametros
If aParam != Nil
        
    //Pega informacoes dos parametros
    oObj := aParam[1]
    cIdPonto := aParam[2]
    cIdModel := aParam[3]
      
    //Na validacao total do formulario 
    If cIdPonto == "FORMPOS" .And. cIdModel == "SA1MASTER"
        xRet := u_MA030TOK()

    //Apos a gravacao total do modelo e dentro da transacao 
    ElseIf cIdPonto == "MODELCOMMITTTS"
        nOper := oObj:nOperation

        If nOper == 3
            u_M030INC()
        ElseIf nOper == 5
            u_M030EXC()
        EndIf

    //Na validação do modelo de dados (pode impedir o usuário de abrir a tela) 
    /*
    ElseIf cIdPonto == "MODELVLDACTIVE"
        nOper := oObj:nOperation

        If nOper == 5
            xRet := u_M030DEL()
        EndIf

    //Após a gravação total do modelo e fora da transação 
    ElseIf cIdPonto == "MODELCOMMITNTTS"
        nOper := oObj:nOperation

        If nOper == 4
            u_M030PALT()
        EndIf
            
    //Para a inclusao de botoes na ControlBar 
    ElseIf cIdPonto == "BUTTONBAR"
        aMenuUsr := u_MA030BUT()
        xRet     := {}

        For nAtual := 1 To Len(aMenuUsr)
            aAdd(xRet, {"* " + aMenuUsr[nAtual][4], "", aMenuUsr[nAtual][2], ""})
        Next
    */
    EndIf
        
EndIf
    
FWRestArea(aArea)

Return xRet

/*/{Protheus.doc} User Function CRM980MDEF
Novo ponto de entrada para adicionar rotinas no novo cadastro de clientes (CRMA980)
@type  Function
@author Atilio
@since 15/10/2022
@see https://tdn.totvs.com/pages/releaseview.action?pageId=604230458
/*/
/*
User Function CRM980MDEF()

Local aArea := FWGetArea()
Private aRotina := {}
u_MA030ROT()

FWRestArea(aArea)

Return aRotina
*/
/*/{Protheus.doc} User Function CRM980BFil
Ponto de Entrada que adiciona filtro do Browse na tela de clientes substituindo o MA030BRW
@type  Function
@author Atilio
@since 15/10/2022
@see https://tdn.totvs.com/display/public/PROT/PE+CRM980BFil+Adiciona+filtro+no+browse+do+cadastro+de+clientes
/*/
/*
User Function CRM980BFil()

Local aArea   := FWGetArea()
Local cFiltro := ""

//Exemplo
//cFiltro := "SA1->A1_VEND == 'XXXXXXX'"

FWRestArea(aArea)

Return cFiltro
*/
