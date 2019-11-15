#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} AlfSfz03()
    (long_description)
    Rotina para descompactar o retorno dos WS da SEFAZ em formato gzip
    @type  Function
    @author user:   
    @since date:    02/10/2017
    @version version
    @param param, param_type, param_descr
    @return cTarget
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AlfSfz03(cString, cTag, cMetodo, cSchema, lWs)
    Local cSource   	:= Decode64(cString)
    Local nSourceLen	:= Len(cSource)
    Local cTarget		:= ""  
        
    Local oXML			:= Nil
    Local cXML			:= '<?xml version="1.0" encoding="ISO-8859-1"?>'
    Local cError		:= ""
    Local cWarning		:= ""

    Default	cMetodo 	:= ""

    If GzStrDecomp( cSource, nSourceLen, @cTarget )
        Conout(cTarget)
        If !Empty(cTag)
            If Upper(cMetodo) == Upper("nfeDistDFeInteresse")
                cXML	+= cTarget      
                oXML	:= XmlParser( cXml, "_", @cError, @cWarning)
                If oXML != Nil .And. cTag == "chNfe"
                    If Upper("resNFe") $ Upper(cSchema)
                        cTarget	:=oXML:_RESNFE:_CHNFE:TEXT
                    ElseIf Upper("resEvento") $ Upper(cSchema)
                        Conout("Linha 40")				
                        cTarget	:=oXML:_RESEVENTO:_CHNFE:TEXT
                    ElseIf Upper("procEventoNFE") $ Upper(cSchema)
                        Conout("Linha 44")				
                        cTarget	:=oXML:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT			
                    EndIf
                ElseIf oXML != Nil .And. cTag == "dhRecbto"
                    If Upper("resNFe") $ Upper(cSchema)
                        Conout("Linha 49")					
                        cTarget	:=SubStr(oXML:_RESNFE:_DHRECBTO:TEXT,1,4)+SubStr(oXML:_RESNFE:_DHRECBTO:TEXT,6,2)+SubStr(oXML:_RESNFE:_DHRECBTO:TEXT,9,2)
                        Conout("DATA: "+cTarget)
                    EndIf                                                           
                ElseIf oXML != Nil .And. cTag == "cSitNFe"
                    If Upper("resNFe") $ Upper(cSchema)		
                        cTarget	:=oXML:_RESNFE:_CSITNFE:TEXT
                    Else
                        Conout("Linha 58 EXTXML. Tag cSitNFe não encontrada no retorno.")
                    EndIf				
                ElseIf oXML != Nil .And. cTag == "XML"
                    cTarget := cXml
                    Conout("Linha 49")				
                EndIf
            ElseIf Empty(cMetodo)
                Conout("Linha 52")
                cXML	+= cTarget      
                oXML	:= XmlParser( cXml, "_", @cError, @cWarning)		
                If oXML != Nil .And. cTag == "TagsEvento"
                    cTarget := oXML:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT + "|" + oXML:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_TPEVENTO:TEXT
                    Conout("Linha 58")
                EndIf
            EndIf        		
        EndIf
    Else                 
        Conout("Linha 63")
        Conout("ERRO")
    EndIf

Return cTarget