#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออ`ออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณX011A01   บAutor  ณFSW TOTVS CASCAVEL   บ Data ณ 23/04/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina centralizadora das fun็๕es customizadas referente ao บฑฑ
ฑฑบ          ณProcesso sim3g					                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTOTVS                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function X011A01(cFuncao,xParam1,xParam2,xParam3,xParam4,xParam5,xParam6,xParam7,xParam8,xParam9)

Local xRet	:= nil

Do Case
	Case Upper(Alltrim(cFuncao)) == "CONSOLE"
		xRet := GeraLog(xParam1,xParam2)
		
	Case Upper(Alltrim(cFuncao)) == "PARSESQL"
		xRet := fParseSQL(xParam1,xParam2,xParam3)
		
	Case Upper(Alltrim(cFuncao)) == "FILSQL"
		xRet := fGetFiltPE(xParam1,xParam2)
		
	Case Upper(Alltrim(cFuncao)) == "FILDEL"
		xRet := fFilDel(xParam1,xParam2)
		
	Case Upper(Alltrim(cFuncao)) == "CMPESPEC"
		xRet := fPECpoEsp(xParam1,xParam2)
		
	Case Upper(Alltrim(cFuncao)) == "CMPEXP"
		xRet := fRetCpoExp(xParam1,xParam2)
		
	Case Upper(Alltrim(cFuncao)) == "UPDEXP"
		xRet := fAtuExpo(xParam1,xParam2,xParam3)
		
	Case Upper(Alltrim(cFuncao)) == "CP1252"
		xRet := fCP1252(xParam1,xParam2)

	Case Upper(Alltrim(cFuncao)) == "PARSECPO"
		xRet := fParseCpo(xParam1)
		
	Case Upper(Alltrim(cFuncao)) == "CPOADIC"
		xRet := fCPOADIC(@xParam1,@xParam2)

	Case Upper(Alltrim(cFuncao)) == "LOGIN"
		xRet := .T.
		
EndCase

Return(xRet)





//******************************************************************************
// Fun็ใo para gerar uma mensagem no Console do Server
//******************************************************************************
Static Function GeraLog(cTxt)

Default cTxt	:= ""

//CONOUT( "[WSSIM3G] - "+ Alltrim(cTxt) )
CONOUT( "[WSSIM3G "+ DTOC(Date()) +" "+ Time() +"] "+ FwNoAccent(cTxt) )

Return .t.

//******************************************************************************
// Fun็ใo para converter uma lista de CAMPOS e VALORES
// em uma expressใo de filtro para clแusula WHERE/SQL
//******************************************************************************
Static Function fParseSQL(cCAMPO,cVALOR,cTAB)

Local cRet  	:= ""
Local cSep  	:= "#"
Local cSepFaixa	:= "-"
Local cSepLista := ";"
Local aCampo	:= {}
Local aValor	:= {}
Local aFaixa	:= {}
Local nCnt1, nCnt2

DEFAULT cCAMPO  := ""	// Ex: A1_FILIAL#A1_COD#A1_LOJA
DEFAULT cVALOR  := ""	// Ex: 0001#123456   #0001
DEFAULT cTAB    := ""	// Ex: SA1

If cCAMPO <> "" .and. cVALOR <> ""
	aCampo := Separa(cCAMPO,cSep)
	aValor := Separa(cVALOR,cSep)
	
	For nCnt1 := 1 to Len(aCampo)
		
		// Valida se o campo existe na tabela informada
		cCampo := Alltrim(aCampo[nCnt1])
		If ! Empty(cTAB) .and. &(cTAB)->( FieldPos(cCampo) ) == 0
			conout("fParseSQL: Campo nao existe! "+ cTAB +"->"+ cCampo)
			Loop
		Endif

		If nCnt1 <= Len(aValor)
			If ! Empty(cRet)
				cRet += " AND "
			Endif
			
			// Se hแ faixa de valores "0000-0999"
			If (AT( cSepFaixa, aValor[nCnt1] ) > 0)
				aFaixa	:= Separa(aValor[nCnt1], cSepFaixa)
				
				// Se passou apenas um '-'
				If (Len(aFaixa) < 1)
					Exit
				EndIf
				cRet 	+= Alltrim(aCampo[nCnt1]) +" BETWEEN '"+ aFaixa[1] +"' AND '"+ aFaixa[2] +"'"

			// Se hแ uma lista de valores "01;02;10;20;50"
			ElseIf (AT( cSepLista, aValor[nCnt1] ) > 0)
				aFaixa	:= Separa(aValor[nCnt1], cSepLista)
				
				// Se passou apenas um ';'
				If (Len(aFaixa) < 1)
					Exit
				EndIf

				cRet	+= Alltrim(aCampo[nCnt1]) + " IN ('" + aFaixa[1] + "' "
				For nCnt2 := 2 to Len(aFaixa)
					cRet	+= ", '"+ aFaixa[nCnt2] +"' "
				Next nCnt2
				cRet		+= ")"
				
			// Caso contrแrio utiliza o operador padrใo
			Else	
				cRet += Alltrim(aCampo[nCnt1]) +" = '"+ aValor[nCnt1] +"'"			
			EndIf 
		Else
			Exit
		Endif
	Next nCnt1
Endif

Return(cRet)

//******************************************************************************
// Fun็ใo para converter uma lista de CAMPOS e VALORES
// em uma expressใo de filtro para clแusula WHERE/SQL
//******************************************************************************
Static Function fGetFiltPE(cMETODO)

Local cRet  	:= ""

DEFAULT cMETODO  := ""

If !Empty(cMETODO) .and. ExistBlock("PES011A1")
	cRet := ExecBlock("PES011A1",.F.,.F., { Upper(cMETODO) })
	If Valtype(cRet) == 'C'
		cRet := Alltrim(cRet)
	Else
		cRet := ""
	EndIf
Endif

Return(cRet)



//******************************************************************************
// Fun็ใo para retornar filtro de registros DELETADOS x NAO DELETADOS
// Valida a tag INOPCAO:
// DELTA     	Retorna NรO DELETADOS + DELETADOS (nใo valida D_E_L_E_T_)
// FULL      	Retorna somente NรO DELETADOS (valida D_E_L_E_T_ = ' ')
// FULL#DELET	Retorna NรO DELETADOS + DELETADOS (nใo valida D_E_L_E_T_)
//******************************************************************************
Static Function fFilDel(cTab,cOpcao)

Local cRet  	:= ""

Default cTab	:= ""
Default cOpcao	:= ""

If !Empty(cTab)
	cOpcao := Upper(Alltrim(cOpcao))
	If "FULL" $ cOpcao
		If "DELET" $ cOpcao
			cRet := ""	//cTab + ".D_E_L_E_T_ = '*' "
		Else
			cRet := cTab + ".D_E_L_E_T_ = ' ' "
		Endif
	Endif
Endif

Return(cRet)



//******************************************************************************
// Fun็ใo Ponto de Entrada para retornar campos especํficos do Cliente
// Deve retornar um array bi-dimensional no formato:
// Ex:  { { "C5_X_CPO1", "Valor1" }, { "C5_X_CPO2", 123.45 }, { "C5_X_CPO3", dDataBase } }
// O ALIAS da tabela deve estar posicionado do m้todo que faz a chamada
//******************************************************************************
Static Function fPECpoEsp(cMETODO)

Local aArea 	:= GetArea()
Local aRet  	:= {}
Local aCpos 	:= {}
Local nCnt1

DEFAULT cMETODO  := ""

If !Empty(cMETODO) .and. ExistBlock("PES011A3")
	aCpos := ExecBlock("PES011A3",.F.,.F., { Upper(cMETODO) })
	
	If Valtype(aCpos) == 'A'
		
		For nCnt1 := 1 to Len(aCpos)
			
			cNomeCpo  := Alltrim(aCpos[nCnt1][1])
			xConteudo := aCpos[nCnt1][2]
			
			If ! Empty(cNomeCpo)
		
				Do Case
					Case ValType(xConteudo) == "C"
						aAdd(aRet, { cNomeCpo, xConteudo } )
						
					Case ValType(xConteudo) == "N"
						aAdd(aRet, { cNomeCpo, Alltrim(Str(xConteudo)) } )
						
					Case ValType(xConteudo) == "D"
						xConteudo := DTOS(xConteudo)
						xConteudo := Substr(xConteudo,1,4) +"-"+ Substr(xConteudo,5,2) +"-"+ Substr(xConteudo,7,2)
						aAdd(aRet, { cNomeCpo, xConteudo } )
						
					Case ValType(xConteudo) == "M"
						aAdd(aRet, { cNomeCpo, Alltrim(xConteudo) } )
						
					Case ValType(xConteudo) == "L"
						aAdd(aRet, { cNomeCpo, IF(xConteudo,"S","N") } )
						
				EndCase
			Endif
		Next nCnt1
	EndIf
Endif
RestArea(aArea)

Return(aRet)


//******************************************************************************
// Fun็ใo para validar o campo de controle de registro EXPORTADO (S/N),
// verificando a exist๊ncia do mesmo na tabela e retornando o nome do campo. 
//******************************************************************************
Static Function fRetCpoExp(cTab,cOpc)	//ex: "CC2_X_EXPO", "A1_X_EXPO "

Local cCampo 	:= ""
Local lExpTudo	:= cOpc <> NIL .And. ("FULL" $ Upper(Alltrim(cOpc)))

DEFAULT cTab	:= ""

If ! lExpTudo .and. ! Empty(cTab)
	cCampo := IF( Substr(cTab,1,1)=="S", Substr(cTab,2,2)+"_X_EXPO", cTab+"_X_EXPO" )
	SX3->(dbSetOrder(2))
	If ! SX3->(dbSeek( cCampo ))
		cCampo := ""
	Endif
Endif

Return(cCampo)


//******************************************************************************
// Fun็ใo para atualizar o campo de controle de registro EXPORTADO = S
//******************************************************************************
Static Function fAtuExpo(cTab,cCpo,nRec)

Local aArea	 := GetArea()
Local cQuery := ""
DEFAULT cTab  := ""
DEFAULT cCpo  := ""
DEFAULT nRec  := 0

If ! Empty(cTab) .and. ! Empty(cCpo) .and. nRec > 0
	cQuery := " UPDATE " + RetSqlName(cTab)
	cQuery += " SET "+cCpo+" = 'S' "
	cQuery += " WHERE  R_E_C_N_O_ = "+ALLTRIM(STR(nRec))+" "
	cQuery += " AND "+cCpo+" <> 'S' "
	TCSQLEXEC(cQuery)
Endif

RestArea(aArea)

Return


//******************************************************************************
// Fun็ใo para validar caracteres ASCII especiais nใo existentes na tabela CP1252
// http://tdn.totvs.com/display/tec/EncodeUTF8
// ASCII 129, 141, 143, 144, 157
//******************************************************************************
Static Function fCP1252(cTexto)

cTexto := Alltrim(cTexto)
cTexto := StrTran(cTexto,chr(129),"u")
cTexto := StrTran(cTexto,chr(141),"i")
cTexto := StrTran(cTexto,chr(143),"A")
cTexto := StrTran(cTexto,chr(144),"E")
cTexto := StrTran(cTexto,chr(157),"Y")

Return(cTexto)


//******************************************************************************
// Fun็ใo para separar nomes de campos em uma String e retonar um Array
//******************************************************************************
static function fParseCpo(cCampos)

local aRet := {}

if cCampos <> nil .and. ValType(cCampos) == "C"
	aRet := Separa(cCampos,"#",.F.)
endif

return(aRet)


//******************************************************************************
// Fun็ใo para incluir campos adicionais no vetor de campos especํficos
//******************************************************************************
static function fCPOADIC(aCpoEspec,aCpoAdic)

local xConteudo
local i
local cAux
local aAux

if ! empty(aCpoAdic) .and. aCpoEspec <> nil
	for i := 1 to len(aCpoAdic)
		if FieldPos(aCpoAdic[i]) > 0
			
			if aScan(aCpoEspec, {|x| alltrim(x[1]) == alltrim(aCpoAdic[i]) }) == 0
				xConteudo := &(aCpoAdic[i])
				do case
					case ValType(xConteudo) == "D"
						xConteudo := if(! empty(xConteudo), Transform(dtos(xConteudo),"@R 9999-99-99"),"")
					case ValType(xConteudo) == "N"
						xConteudo := alltrim(str(xConteudo))
					case ValType(xConteudo) == "L"
						xConteudo := if(xConteudo,"T","F")
				endcase
				aAdd( aCpoEspec, { aCpoAdic[i], xConteudo } )
			endif
			
		else
			// Tratamento especํfico para campo MEMO Virtual
			// B1_OBS:B1_CODOBS -> Primeiro campo ้ o Memo virtual, segundo campo ้ a refer๊ncia real
			cAux := alltrim(aCpoAdic[i])
			if At(":",cAux) > 1 .and. At(":",cAux) < len(cAux)
				aAux := Separa(cAux,":")
				if FieldPos(aAux[2]) > 0
					aAdd( aCpoEspec, { aAux[1],  MSMM( &(aAux[2]) ) } )
				endif
			endif
		endif
	next i
endif

return(aCpoEspec)

