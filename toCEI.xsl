<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:cei="http://www.monasterium.net/NS/cei" exclude-result-prefixes="xs math" version="3.0">
    <xsl:template match="/">
        <cei:cei>
            <cei:teiHeader>
                <cei:fileDesc>
                    <cei:titleStmt>
                        <cei:title> </cei:title>
                        <cei:author/>
                    </cei:titleStmt>
                    <cei:publicationStmt>
                        <cei:p/>
                    </cei:publicationStmt>
                    <cei:sourceDesc>
                        <cei:p/>
                    </cei:sourceDesc>
                </cei:fileDesc>
            </cei:teiHeader>
            <cei:text>
                <cei:group>
                    <xsl:apply-templates/>
                </cei:group>
            </cei:text>
        </cei:cei>
    </xsl:template>
    <xsl:template match="urkunde">
        <xsl:choose>
            <xsl:when test="teildokumente">
                <xsl:apply-templates select="teildokumente/ueberlieferungseinheit"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="charter-contents"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="ueberlieferungseinheit[1]">
        <xsl:call-template name="charter-contents"/>
    </xsl:template>
    <xsl:template match="ueberlieferungseinheit[position() != 1]">
        <xsl:call-template name="charter-contents">
            <xsl:with-param name="main-charter-ref" select="..//signatur/text()"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="charter-contents">
        <xsl:param name="main-charter-ref"/>
        <cei:text type="charter">
            <cei:front>
                <cei:sourceDesc>
                    <xsl:if test="ueberlieferung/druck or ueberlieferung/literatur_regest">
                      <cei:sourceDescRegest>
                          <xsl:apply-templates select="ueberlieferung/druck"/>
                          <xsl:apply-templates select="ueberlieferung/literatur_regest"/>
                      </cei:sourceDescRegest>
                    </xsl:if>
                </cei:sourceDesc>
            </cei:front>
            <cei:body>
                <xsl:choose>
                    <xsl:when test="ueberlieferung/signatur">
                        <xsl:apply-templates select="ueberlieferung/signatur"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <cei:idno>
                            <xsl:value-of select="$main-charter-ref"/>
                        </cei:idno>
                    </xsl:otherwise>
                </xsl:choose>
                <cei:chDesc>
                    <xsl:apply-templates select="regest"/>
                    <cei:issued>
                        <xsl:apply-templates select="datum"/>
                        <xsl:apply-templates select="ausstellungsort"/>
                    </cei:issued>
                    <cei:witnessOrig>
                        <xsl:call-template name="images">
                            <xsl:with-param name="signatur" select="ueberlieferung/signatur/text()"
                            />
                        </xsl:call-template>
                        <cei:archIdentifier>
                            <cei:institution>Humboldt-Universität zu Berlin</cei:institution>
                        </cei:archIdentifier>
                        <cei:physicalDesc>
                            <cei:material>Pergament</cei:material>
                            <xsl:apply-templates select="ueberlieferung/beschreibstoff"/>
                            <xsl:apply-templates select="ueberlieferung/erhaltungszustand"/>
                        </cei:physicalDesc>
                        <cei:auth>
                            <xsl:call-template name="seal-data"/>
                            <xsl:apply-templates select="ueberlieferung/zeugen"/>
                        </cei:auth>
                    </cei:witnessOrig>
                    <cei:diplomaticAnalysis>
                        <xsl:apply-templates select="vermerk"/>
                        <xsl:apply-templates select="ueberlieferung/besonderheit"/>
                        <xsl:apply-templates select="datierungsvermerk"/>
                    </cei:diplomaticAnalysis>
                    <xsl:apply-templates select="ueberlieferung/sprache"/>
                </cei:chDesc>
            </cei:body>
            <cei:back>
                <cei:class>
                    <xsl:if test="$main-charter-ref">
                        <xsl:value-of
                            select="concat('Diese Urkunde ist ein Transfix (VID #71) inseriert in: ', $main-charter-ref, '.1')"
                        />
                    </xsl:if>
                </cei:class>
            </cei:back>
        </cei:text>
    </xsl:template>
    <xsl:template match="signatur">
        <cei:idno id="{./text()}">
            <xsl:apply-templates/>
        </cei:idno>
    </xsl:template>
    <xsl:template match="regest">
        <cei:abstract>
            <xsl:apply-templates/>
        </cei:abstract>
    </xsl:template>
    <xsl:template match="datum">
        <cei:date value="{replace(@iso/data(), '-', '')}">
            <xsl:apply-templates/>
        </cei:date>
    </xsl:template>
    <xsl:template match="ausstellungsort">
        <cei:placeName>
            <xsl:apply-templates/>
        </cei:placeName>
    </xsl:template>
    <xsl:template name="seal-data">
        <cei:sealDesc>
            <xsl:value-of select="ueberlieferung/beglaubigungsform"/>
            <xsl:if test="ueberlieferung/beglaubigungsform and ueberlieferung/siegel">
                <xsl:text>; </xsl:text>
            </xsl:if>
            <xsl:value-of select="ueberlieferung/siegel"/>
        </cei:sealDesc>
    </xsl:template>
    <xsl:template match="druck | literatur_regest">
        <cei:bibl>
            <xsl:apply-templates/>
        </cei:bibl>
    </xsl:template>
    <xsl:template match="erhaltungszustand">
        <cei:condition>
            <xsl:apply-templates/>
        </cei:condition>
    </xsl:template>
    <xsl:template match="zeugen">
        <cei:subscriptio>
            <xsl:apply-templates/>
        </cei:subscriptio>
    </xsl:template>
    <xsl:template match="beschreibstoff">
        <cei:dimensions>
            <xsl:value-of select="substring-after(text(), 'Pergament ')"/>
        </cei:dimensions>
    </xsl:template>
    <xsl:template match="sprache">
        <cei:lang_MOM>
            <xsl:apply-templates/>
        </cei:lang_MOM>
    </xsl:template>
    <xsl:template match="datierungsvermerk">
        <cei:quoteOriginaldatierung>
            <xsl:apply-templates/>
        </cei:quoteOriginaldatierung>
    </xsl:template>
    <xsl:template match="besonderheit | vermerk">
        <cei:p>
            <xsl:apply-templates/>
        </cei:p>
    </xsl:template>
    <xsl:template match="footnote">
        <cei:note>
            <xsl:value-of select="ancestor::urkunde/anmerkungen/anmerkung[@nr = current()]/text()"/>
        </cei:note>
    </xsl:template>
    <xsl:template name="images">
        <xsl:param name="signatur"/>
        <xsl:variable name="record"
            select="doc('records.xml')/records/record[titles/title[contains(text(), concat('Urkunde ', $signatur, ','))]]"/>
        <xsl:variable name="access-no" select="$record/accession-num/text()"/>
        <xsl:variable name="image-no" select="xs:int($record/pages/text())"/>
        <xsl:for-each select="1 to $image-no">
            <cei:figure>
                <cei:graphic
                    url="https://www.digi-hub.de/viewer/api/v1/records/{$access-no}/files/images/0000000{position()}.tif/full/!1000,1000/0/default.jpg"
                />
            </cei:figure>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
<!--TODO-->
<!--include URL like https://www.digi-hub.de/viewer/image/1602679020380/1/-->
<!--//cei:condition/cei:note checken, da ist was faul-->
