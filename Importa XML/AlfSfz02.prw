#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBSRV.CH"


/*/{Protheus.doc} AlfSfz02()
Rotina para captura informações do Certificado Digital na tabela ZZL
@type  Function
@author user:   
@since date:    02/10/2017
@version version
@param param, param_type, param_descr
@return returno,return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function AlfSfz02(cCNPJ, cPathCert, cPathPKey, cPassword )

Local lRet := .F.
Local cArqPFX := ""
Local cArqPKey := ""
Local cArqPEM := ""
Local cTxtQry := ""
Local cPathCam := ""
Local cTxtPass := ""

cTxtQry := "SELECT "
cTxtQry += "ZDG.ZDG_CONTA AS ZDGCONTA, "
cTxtQry += "ZDG.ZDG_PCERT AS ZDGPCERT, "
cTxtQry += "ZDG.ZDG_PSS AS ZDGPSS, "
cTxtQry += "ZDG.ZDG_PKEY AS ZDGPKEY, "
cTxtQry += "ZDG.ZDG_CAMPEM AS ZDGCAMPEM, "
cTxtQry += "ZDG.ZDG_ARQCER AS ZDGARQCER "

//OBS.: esta' chumbado o nome da tabela, pois ha' erro ao executar RetSqlName() e xFilial() para a tabela ZDG
cTxtQry += "FROM "+RetSqlName("ZDG")+" ZDG WHERE ZDG.D_E_L_E_T_ <> '*' "
cTxtQry += "AND ZDG.ZDG_FILIAL = '"+xFilial("ZDG")+"' "
cTxtQry += "AND ZDG.ZDG_CONTA = '"+cCNPJ+"' "

Iif(Select("WRKXZDG")>0,WRKXZDG->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cTxtQry),"WRKXZDG",.T.,.T.)
WRKXZDG->(dbGoTop())

If WRKXZDG->(!EoF())
	cPassword	:= Alltrim(WRKXZDG->ZDGPSS)
	cPathCam	:= Alltrim(WRKXZDG->ZDGCAMPEM)
	cArqPEM		:= Alltrim(WRKXZDG->ZDGPCERT)
	cArqPFX		:= Alltrim(WRKXZDG->ZDGARQCER)
	cArqPKey	:= Alltrim(WRKXZDG->ZDGPKEY)
EndIf
WRKXZDG->(dbCloseArea())

If ( !Empty(cPassword) .And. !Empty(cPathCam) .And. !Empty(cArqPEM) .And. !Empty(cArqPFX) .And. !Empty(cArqPKey) )
	lRet := .T.
	cTxtPass  := Alltrim( RC4Crypt(Alltrim(cPassword) ,"731296548", .F.))
	cPassword := cTxtPass
	cPathCert := cPathCam + cArqPEM
	cPathPKey := cPathCam + cArqPKey
Else
	lRet := .F.
EndIf

Return(lRet)