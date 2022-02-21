<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="ddi:instance:3_3 XMLSchema33/instance.xsd"
    xmlns:d="ddi:datacollection:3_3" xmlns:l="ddi:logicalproduct:3_3" xmlns:r="ddi:reusable:3_3"
    exclude-result-prefixes="xs xd d l r"
    version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="ddi-file"/>
    <xsl:param name="ddi" select="doc($ddi-file)"/>

    <xd:doc >
        <xd:desc>
            <xd:p>Template de racine, on applique les templates de tous les enfants</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template de base pour tous les éléments et tous les attributs, on recopie
                simplement en sortie</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="table:table[@table:name='Suivi']/table:table-row[2]/table:table-cell[text:p][last()]/text:p">
        <xsl:copy>
            <xsl:value-of select="substring-before(tokenize(base-uri($ddi), '/')[last()],'.')"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="table:table[@table:name='Variables Pogues']/table:table-row[2]">
        <xsl:copy-of select="."/>
        <xsl:apply-templates select="$ddi//l:VariableScheme/l:Variable[r:ID = $ddi//l:VariableGroup/r:VariableReference/r:ID]"/>
    </xsl:template>

    <xsl:template match="table:table[@table:name='Listes de codes']/table:table-row[1]">
        <xsl:copy-of select="."/>
        <xsl:apply-templates select="$ddi//l:CodeListScheme/l:CodeList[r:ID = $ddi//l:VariableRepresentation/r:CodeRepresentation/r:CodeListReference/r:ID]"/>
    </xsl:template>

    <xsl:template match="table:table[@table:name='Tab dynamiques']/table:table-row[1]">
        <xsl:copy-of select="."/>
        <xsl:apply-templates select="$ddi//d:QuestionGrid[d:GridDimension/d:Roster]"/>
    </xsl:template>
    

    <xsl:template match="l:Variable">
        <table:table-row table:style-name="ro1">
            <table:table-cell office:value-type="string" calcext:value-type="string">
                <text:p><xsl:value-of select="l:VariableName/r:String"/></text:p>
            </table:table-cell>
            <xsl:choose>
                <xsl:when test="r:SourceParameterReference">
                    <table:table-cell office:value-type="string" calcext:value-type="string">
                        <text:p><xsl:value-of select="'collecte'"/></text:p>
                    </table:table-cell>
                    <table:table-cell office:value-type="string" calcext:value-type="string">
                        <text:p><xsl:value-of select="'Non'"/></text:p>
                    </table:table-cell>
                </xsl:when>
                <xsl:when test="l:VariableRepresentation/r:ProcessingInstructionReference">
                    <table:table-cell office:value-type="string" calcext:value-type="string">
                        <text:p><xsl:value-of select="'calculée'"/></text:p>
                    </table:table-cell>
                    <table:table-cell office:value-type="string" calcext:value-type="string">
                        <text:p><xsl:value-of select="'Non'"/></text:p>
                    </table:table-cell>
                </xsl:when>
                <xsl:otherwise>
                    <table:table-cell office:value-type="string" calcext:value-type="string">
                        <text:p><xsl:value-of select="'personnalisation'"/></text:p>
                    </table:table-cell>
                    <table:table-cell office:value-type="string" calcext:value-type="string">
                        <text:p><xsl:value-of select="'Oui'"/></text:p>
                    </table:table-cell>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="module-id">
                <xsl:choose>
                    <xsl:when test="r:SourceParameterReference">
                        <xsl:apply-templates select="$ddi//*[d:ControlConstructReference/r:ID = $ddi//d:QuestionConstruct[r:QuestionReference/r:ID = current()/r:QuestionReference/r:ID]/r:ID]" mode="module"/>
                    </xsl:when>
                    <xsl:when test="l:VariableRepresentation/r:ProcessingInstructionReference">
                        <xsl:apply-templates select="$ddi//*[r:ID = $ddi//d:GenerationInstruction[r:ID = current()//r:ProcessingInstructionReference/r:ID]
                                                                                                 /d:ControlConstructReference/r:ID]" mode="module"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$module-id !=''">
                    <table:table-cell office:value-type="string" calcext:value-type="string">
                        <text:p>
                            <xsl:value-of select="$ddi//d:Sequence[r:ID=$module-id]/d:ConstructName/r:String[@xml:lang='fr-FR']"/>
                        </text:p>
                    </table:table-cell>
                    <table:table-cell office:value-type="string" calcext:value-type="string">
                        <text:p>
                            <xsl:value-of select="$module-id"/>
                        </text:p>
                    </table:table-cell>
                </xsl:when>
                <xsl:otherwise>
                    <table:table-cell table:number-columns-repeated="2"/>
                </xsl:otherwise>
            </xsl:choose>
            <table:table-cell office:value-type="string" calcext:value-type="string">
                <text:p>
                    <xsl:value-of select="$ddi//l:VariableGroup[contains(l:TypeOfVariableGroup,'Loop') and r:VariableReference/r:ID = current()/r:ID]/l:VariableGroupName/r:String"/>
                </text:p>
            </table:table-cell>
            <xsl:apply-templates select="l:VariableRepresentation/*" mode="representation"/>
            <table:table-cell table:number-columns-repeated="2"/>
            <table:table-cell>
                <text:p><xsl:value-of select="r:Label/r:Content[@xml:lang='fr-FR']"/></text:p>
            </table:table-cell>
        </table:table-row>
    </xsl:template>

    <xsl:template match="*" mode="module">
        <xsl:choose>
            <xsl:when test="d:TypeOfSequence='module'">
                <xsl:value-of select="r:ID"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$ddi//*[d:ControlConstructReference/r:ID = current()/r:ID
                                                  or d:ThenConstructReference/r:ID = current()/r:ID]" mode="module"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="l:VariableRepresentation/r:NumericRepresentation" mode="representation">
        <table:table-cell office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="'Numérique'"/></text:p>
        </table:table-cell>
        <table:table-cell table:style-name="Default" office:value-type="string" calcext:value-type="string">
            <text:p>
                <xsl:choose>
                    <xsl:when test="@decimalPositions">
                        <xsl:value-of select="@decimalPositions"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </text:p>
        </table:table-cell>
        <table:table-cell table:style-name="Default" office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="r:NumberRange/r:Low"/></text:p>
        </table:table-cell>
        <table:table-cell table:style-name="Default" office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="r:NumberRange/r:High"/></text:p>
        </table:table-cell>
        <table:table-cell table:number-columns-repeated="2"/>
    </xsl:template>

    <xsl:template match="l:VariableRepresentation/r:NumericRepresentationReference" mode="representation">
        <table:table-cell office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="'Numérique'"/></text:p>
        </table:table-cell>
        <table:table-cell table:style-name="Default" office:value-type="string" calcext:value-type="string">
            <text:p>
                <xsl:choose>
                    <xsl:when test="descendant::*/@decimalPositions">
                        <xsl:value-of select="descendant::*[@decimalPositions][1]/@decimalPositions"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </text:p>
        </table:table-cell>
        <table:table-cell table:style-name="Default" office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="descendant::r:NumberRange[1]/r:Low"/></text:p>
        </table:table-cell>
        <table:table-cell table:style-name="Default" office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="descendant::r:NumberRange[1]/r:High"/></text:p>
        </table:table-cell>
        <table:table-cell table:number-columns-repeated="2"/>
    </xsl:template>

    <xsl:template match="l:VariableRepresentation/r:TextRepresentation" mode="representation">
        <table:table-cell office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="'Texte'"/></text:p>
        </table:table-cell>
        <table:table-cell table:number-columns-repeated="3"/>
        <table:table-cell table:style-name="Default" office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="@maxLength"/></text:p>
        </table:table-cell>
        <table:table-cell/>
    </xsl:template>

    <xsl:template match="l:VariableRepresentation/r:CodeRepresentation" mode="representation">
        <table:table-cell office:value-type="string" calcext:value-type="string">
            <text:p>
                <xsl:choose>
                    <xsl:when test="descendant::r:CodeReference/r:ID='INSEE-COMMUN-CL-Booleen-1'">
                        <xsl:value-of select="'Booléen'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'Code'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </text:p>
        </table:table-cell>
        <table:table-cell table:number-columns-repeated="4"/>
        <table:table-cell table:style-name="Default" office:value-type="string" calcext:value-type="string">
            <xsl:if test="not(descendant::r:CodeReference/r:ID='INSEE-COMMUN-CL-Booleen-1')">
                <text:p><xsl:value-of select="$ddi//l:CodeListScheme/l:CodeList[r:ID = current()/r:CodeListReference/r:ID]/r:Label/r:Content[@xml:lang='fr-FR']"/></text:p>
            </xsl:if>
        </table:table-cell>
    </xsl:template>

    <xsl:template match="l:VariableRepresentation/r:DateTimeRepresentation" mode="representation">
        <table:table-cell office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="'Date'"/></text:p>
        </table:table-cell>
        <table:table-cell table:number-columns-repeated="5"/>
    </xsl:template>

    <xsl:template match="l:VariableRepresentation/r:DateTimeRepresentationReference" mode="representation">
        <table:table-cell office:value-type="string" calcext:value-type="string">
            <text:p><xsl:value-of select="'Date'"/></text:p>
        </table:table-cell>
        <table:table-cell table:number-columns-repeated="5"/>
    </xsl:template>

    <xsl:template match="l:CodeListScheme/l:CodeList">
        <xsl:param name="list-name" select="r:Label/r:Content[@xml:lang='fr-FR']"/>
        <xsl:apply-templates select="l:Code | $ddi//l:CodeListScheme/l:CodeList[r:ID = current()/r:CodeListReference/r:ID]">
            <xsl:with-param name="list-name" select="$list-name"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="l:Code">
        <xsl:param name="list-name"/>
        <table:table-row table:style-name="ro1">
            <table:table-cell office:value-type="string" calcext:value-type="string">
                <text:p><xsl:value-of select="$list-name"/></text:p>
            </table:table-cell>
            <table:table-cell office:value-type="string" calcext:value-type="string">
                <text:p><xsl:value-of select="r:Value"/></text:p>
            </table:table-cell>
            <table:table-cell office:value-type="string" calcext:value-type="string">
                <text:p><xsl:value-of select="$ddi//l:CategoryScheme/l:Category[r:ID = current()/r:CategoryReference/r:ID]/r:Label/r:Content[@xml:lang='fr-FR']"/></text:p>
            </table:table-cell>
        </table:table-row>
    </xsl:template>

    <xsl:template match="d:QuestionGrid">
        <table:table-row table:style-name="ro1">
            <table:table-cell office:value-type="string" calcext:value-type="string">
                <text:p><xsl:value-of select="d:QuestionGridName/r:String"/></text:p>
            </table:table-cell>
            <table:table-cell office:value-type="string" calcext:value-type="string">
                <text:p><xsl:value-of select="d:GridDimension/d:Roster/@maximumAllowed"/></text:p>
            </table:table-cell>
        </table:table-row>
    </xsl:template>

</xsl:stylesheet>