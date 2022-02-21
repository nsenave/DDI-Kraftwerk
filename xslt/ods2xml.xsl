<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    version="2.0" exclude-result-prefixes="#all">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet is used to transform fods into xml.</xd:p>
        </xd:desc>
    </xd:doc>

    <!-- The output file generated will be xml type -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="root" select="."/>
    <xsl:variable name="correspondance" as="node()">
        <Correspondance>
            <PoguesVariables label="Variables Pogues"/>
            <CodeLists label="Listes de codes"/>
            <NonPoguesVariables label="Variables hors Pogues"/>
            <DynamicArrays label="Tab dynamiques"/>
            <CalculatedVariables label="Variables calculées"/>
            <Checks label="Contrôles"/>
            <AutoCorrect label="Corrections automatiques"/>
            <DataSources label="Tables sources"/>
            <CommonGenericVariables label="Variables communes Généric"/>
            

            <VariableName label="Nom Variable"/>
            <Use label="Origine"/>
            <Use label="Utilisation"/>
            <Loop label="Nom Boucle"/>
            <External label="A initialiser"/>
            <Tab label="Nom Module"/>
            <Tab label="Module"/>
            <TabId label="Identifiant Module"/>
            <Format label="Format"/>
            <Decimal label="Nb décimales"/>
            <Minimum label="Minimum"/>
            <Maximum label="Maximum"/>
            <StringLength label="Longueur maximum"/>
            <CodeList label="Liste des codes"/>
            <CodeList label="Nom Liste"/>
            <Code label="Code"/>
            <CodeLabel label="Libellé"/>
            <DataSource label="Table source"/>
            <DataSource label="Nom table"/>
            <VariableSource label="Nom variable source"/>
            <VariableFormulaCondition label="Condition d’affectation d’une valeur à la variable"/>
            <VariableFormula label="Formule de la valeur à affecter à la variable"/>
            <Description label="Description"/>
            
            <Check label="Contrôle"/>
            <Flag label="Flag"/>
            <CheckMessage label="Message d’erreur"/>
            <Criticality label="Criticité"/>
            <CheckType label="Type Contrôle"/>
            <CheckFormula label="Condition de déclenchement de l’erreur"/>
            <Confirmable label="Confirmable"/>
            <ConfirmationVariable label="Variable confirmation"/>
            <ConfirmationFormula label="Formule confirmation"/>
            <LeadingVariable label="Variable directrice"/>
            <DisabledCheck label="Contrôle inactivé"/>
            <CheckComment label="Commentaire sur le contrôle"/>
            <AutoCorrection label="Identifiant correction"/>
            <AutoCorrectedVariable label="Variable collectée à corriger"/>
            <AutoCorrectingCheckFormula label="Condition de déclenchement de la correction"/>
            <AutoCorrectingFormula label="Formule de correction automatique"/>
            <DisabledCorrection label="Correction inactivée"/>
            <CorrectionComment label="Commentaire sur la correction"/>
            <DynamicArray label="Nom tableau"/>
            <MaxLines label="Nombre lignes maximum"/>
            <SourceOfId label="Variable identifiant dossier"/>
            <SourceOfLoopId label="Identifiant occurrence"/>
        </Correspondance>
    </xsl:variable>
    <xsl:variable name="disabled-labels">
        <DisabledLabels>
            <DisabledLabel>Supprimé</DisabledLabel>
            <DisabledLabel>Inactif</DisabledLabel>
        </DisabledLabels>
    </xsl:variable>

    <xsl:template match="/">
        <Root>
            <xsl:apply-templates select="//table:table[@table:name!='Généralités']"/>
        </Root>
    </xsl:template>
    
    <xsl:template match="table:table[@table:name='Suivi']">
        <Survey>
            <xsl:value-of select="table:table-row[2]/table:table-cell[4]"/>
        </Survey>
    </xsl:template>

    <xsl:template match="table:table">
        <Table>
            <xsl:attribute name="name" select="$correspondance//*[@label=current()/@table:name]/name()"/>
            <xsl:apply-templates select="table:table-row[position()>1]"/>
        </Table>
    </xsl:template>

    <xsl:template match="table:table-row[descendant::*[text() != '']]">
        <Row>
            <xsl:apply-templates select="table:table-cell[text:p/text()]"/>
        </Row>
    </xsl:template>
    <xsl:template match="table:table-row[not(descendant::*[text() != ''])]"/>

    <xsl:template match="table:table-cell">
        <xsl:variable name="table-name" select="ancestor::table:table/@table:name"/>
        <xsl:variable name="current-value">
            <xsl:for-each select="text:p">
                <xsl:if test="position()&gt;1">
                    <xsl:value-of select="'&#13;'"/>
                </xsl:if>
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="column-position" select="xs:integer(1 + count(preceding-sibling::table:table-cell[not(@table:number-columns-repeated)])
                                                                    + sum(preceding-sibling::table:table-cell/@table:number-columns-repeated))" as="xs:integer"/>
        <xsl:variable name="col-max" as="xs:integer">
            <xsl:choose>
                <xsl:when test="@table:number-columns-repeated">
                    <xsl:value-of select="$column-position+xs:integer(@table:number-columns-repeated)-1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$column-position"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$column-position to $col-max">
            <xsl:variable name="current-position" select="."/>
            <xsl:variable name="column-label" select="$root//table:table[@table:name = $table-name]/table:table-row[1]/table:table-cell[position()=$current-position]/text:p/text()"/>
            <xsl:choose>
                <xsl:when test="$column-label = ''">
                    <xsl:element name="col-{$current-position}">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$correspondance//*[@label=$column-label]">
                            <xsl:element name="{$correspondance//*[@label=$column-label]/name()}">
                                <xsl:value-of select="$current-value"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="{replace($column-label,' ','_')}">
                                <xsl:value-of select="$current-value"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
