#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
               

//Chamar do Schedule
User Function AlfScCLP(xParm)

U_AlfCLPJB( xParm[1] , xParm[2] )

Return(Nil)



//Executa do SmartClient
User Function ALFRUNCLP()

Local oBt1 := Nil 
Local oBt2 := Nil  
Local oGtEmp := Nil 
Local oGtFil := Nil
Local oSay1 := Nil
Local oSay2 := Nil
Local oDg1 := Nil
Local lGo := .F.
Local cGtEmp := "                           "
Local cGtFil := "                           "

DEFINE MSDIALOG oDg1 TITLE "ALFJBCLP - Execução sob Demanda" FROM 000, 000  TO 085, 450 COLORS 0, 16777215 PIXEL

    @ 007, 005 SAY oSay1 PROMPT "Empresa" SIZE 025, 007 OF oDg1 COLORS 0, 16777215 PIXEL
    @ 005, 032 MSGET oGtEmp VAR cGtEmp Valid(!Empty(cGtEmp)) SIZE 060, 010 OF oDg1 COLORS 0, 16777215 PIXEL
    @ 006, 134 SAY oSay2 PROMPT "Filial" SIZE 017, 007 OF oDg1 COLORS 0, 16777215 PIXEL
    @ 004, 156 MSGET oGtFil VAR cGtFil Valid(!Empty(cGtEmp)) SIZE 060, 010 OF oDg1 COLORS 0, 16777215 PIXEL
    @ 023, 004 BUTTON oBt1 PROMPT "Executa" SIZE 098, 012 OF oDg1 ACTION (lGo:=.T.,oDg1:End()) PIXEL
    @ 023, 119 BUTTON oBt2 PROMPT "Sair" SIZE 098, 012 OF oDg1 ACTION (lGo:=.F.,oDg1:End()) PIXEL

ACTIVATE MSDIALOG oDg1 CENTERED

If lGo

	If ( Empty(Alltrim(cGtEmp)) .And. Empty(Alltrim(cGtFil)) )
		Alert("Empresa / Filial invalidos")
	Else
		dbUseArea(,,"SIGAMAT.EMP","SM0",.T.,.F.)
		dbSetIndex( "SIGAMAT.IND" )
		dbSelectArea("SM0")
		If SM0->(dbSeek(Alltrim(cGtEmp)+Alltrim(cGtFil)))
			MsgRun ("Aguarde... Classificando Pre-Notas - Emp "+Alltrim(cGtEmp)+" Fil "+Alltrim(cGtFil), "Aguarde", {||U_AlfCLPJB( Alltrim(cGtEmp) , Alltrim(cGtFil) )} )
			MsgInfo("Fim do processamento - Empresa "+Alltrim(cGtEmp)+" Filial "+Alltrim(cGtFil))
		Else
			Alert("Empresa / Filial nao consta do cadastro de empresas")
		EndIf
	EndIf

EndIf

Return(Nil)



User Function AlfCLPJB( cEmpJb , cFilJb )

Local cXQry := ""
Local cNmJb := "ALFJBCLP" + Alltrim(cEmpJb) + Alltrim(cFilJb)
Local cStMon := ""

PREPARE ENVIRONMENT EMPRESA cEmpJb FILIAL cFilJb TABLES "SX2", "SX5", "SX6", "ZDH", "ZD2", "ZD3", "SF1", "SD1", "SC7", "SA2", "SB1", "SA5"

U_ALFVCXML()

cStMon := SuperGetMV("AF_CLPSTMN",,"'G'")

ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: inicio job ALFJBCLP")

If LockByName( cNmJb , .T. , .T. )

	cXQry := "SELECT "
	cXQry += "ISNULL(ZDH.R_E_C_N_O_,0) AS ZDHRECNO "
	cXQry += "FROM "+RetSqlName("ZDH")+" ZDH (NOLOCK) "
	cXQry += "WHERE ZDH.D_E_L_E_T_ = ' ' "
	cXQry += "AND ZDH.ZDH_FILIAL = '"+cFilJb+"' "
	cXQry += "AND ZDH.ZDH_STATUS IN ("+cStMon+") "
	cXQry += "AND ZDH.ZDH_CHAVE <> '' "
	cXQry += "ORDER BY R_E_C_N_O_ DESC"

	Iif(Select("WKXZDH")>0,WKXZDH->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cXQry),"WKXZDH",.T.,.T.)
	TcSetField("WKXZDH","ZDHRECNO","N",14,0)
	WKXZDH->(dbGoTop())

	If WKXZDH->(!EoF())
		dbSelectArea("ZDH")
		While WKXZDH->(!EoF())
			If WKXZDH->ZDHRECNO > 0
				ZDH->(dbGoTo(WKXZDH->ZDHRECNO))
				If ZDH->(RecNo()) == WKXZDH->ZDHRECNO
					U_Alf04CPN( .T. )
				Else
					ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+"ERRO: nao foi possivel localizar registro "+Alltrim(Str(WKXZDH->ZDHRECNO))+" da tabela ZDH")
				EndIf
			EndIf
			WKXZDH->(dbSkip())
		EndDo
	EndIf
	WKXZDH->(dbCloseArea())

	UnLockByName( cNmJb , .T. , .T. )

Else

	ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - ERRO: job "+cNmJb+" ja em execucao")

EndIf

ConOut("Monitor XML - Classif. Emp "+cEmpAnt+" Fil "+cFilAnt+" "+DtoC(Date())+" "+Time()+" "+ZDH->ZDH_CHAVE+" - MSG: fim job ALFJBCLP")

RESET ENVIRONMENT

Return(Nil)
