<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:cei="http://www.monasterium.net/NS/cei" exclude-result-prefixes="xs math" version="3.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
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
                <xsl:apply-templates select="teildokumente/*"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="charter-contents"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*[parent::teildokumente][1]">
        <xsl:call-template name="charter-contents"/>
    </xsl:template>
    <xsl:template match="*[parent::teildokumente][position() != 1]">
        <xsl:call-template name="charter-contents">
            <xsl:with-param name="main-charter-ref" select="../rahmenurkunde/ueberlieferung/signatur/text()"/>
            <xsl:with-param name="position" select="position()"/>
            <xsl:with-param name="sub-charter-type" select="@type/data()"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="charter-contents">
        <xsl:param name="main-charter-ref"/>
        <xsl:param name="position" as="xs:integer?" select="()"/>
        <xsl:param name="sub-charter-type"/>
        <xsl:variable name="sub-charter-ref" select="concat($main-charter-ref, '.', $position - 1)"/>
        <xsl:variable name="signatur" select="ueberlieferung/signatur/text()"/>
        <xsl:variable name="record" select="doc('records.xml')/records/record[titles/title[contains(text(), concat('Urkunde ', $signatur, ','))]]"/>
        <xsl:variable name="metadata-entry" select="doc('urkundensammlung_metadaten.xml')/tei:TEI/tei:text/tei:body/tei:table/tei:row[tei:cell[@n='1'][text() = concat('Urk. ', $signatur)]]"/>
        <xsl:variable name="main-char-record" select="doc('records.xml')/records/record[titles/title[contains(text(), concat('Urkunde ', $main-charter-ref, ','))]]"/>
        <xsl:variable name="effective-record" select="if ($record) then $record else $main-char-record"/>
        <xsl:variable name="access-no" select="$effective-record/accession-num/text()"/>
        <cei:text type="charter">
            <cei:front>
                <cei:sourceDesc>
                    <cei:sourceDescRegest>
                        <cei:bibl>
                            <xsl:choose>
                                <xsl:when test="contains(document-uri(/), 'aberle')">
                                    <xsl:text>Aberle, Johanna, und Ina Prescher. Die Urkundensammlung des Historischen Seminars der Friedrich-Wilhelms-Universität zu Berlin, heute in der Universitätsbibliothek der Humboldt-Universität, Zweigbibliothek Geschichte. Inventar: Sammlungsgeschichte, -beschreibung und Regesten der Urkunden nordalpiner Provenienz. Schriftenreihe der Universitätsbibliothek der Humboldt-Universität zu Berlin 60. Humboldt-Universität zu Berlin, Universitätsbibliothek der Humboldt-Universität, 1997. </xsl:text>
                                    <cei:ref target='https://doi.org/10.18452/5011'>https://doi.org/10.18452/5011</cei:ref>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Müller, Harald, Michael Brauer, Uta Kirchner, Andrea Kutschke, Constanze Trapp, und Kordula Wolf. Die Urkundensammlung des Historischen Seminars der Friedrich-Wilhelms-Universität zu Berlin. Teil 2: Regesten der Urkunden nichtdeutscher Provenienz. Schriftenreihe der Universitätsbibliothek der Humboldt-Universität zu Berlin 62. Humboldt-Universität zu Berlin, Universitätsbibliothek der Humboldt-Universität, 2007. </xsl:text>
                                    <cei:ref target='https://doi.org/10.18452/5018'>https://doi.org/10.18452/5018</cei:ref>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="$metadata-entry/tei:cell[@n='8']/normalize-space()">
                                <xsl:text>, Seite digitalisiert unter: </xsl:text>
                                <cei:ref target="{$metadata-entry/tei:cell[@n='8']/text()}">
                                    <xsl:value-of select="$metadata-entry/tei:cell[@n='8']/text()"/>
                                </cei:ref>
                            </xsl:if>
                        </cei:bibl>
                        <xsl:apply-templates select="ueberlieferung/druck"/>
                        <xsl:apply-templates select="ueberlieferung/literatur_regest"/>
                  </cei:sourceDescRegest>
                </cei:sourceDesc>
            </cei:front>
            <cei:body>
                <xsl:choose>
                    <xsl:when test="ueberlieferung/signatur">
                        <xsl:apply-templates select="ueberlieferung/signatur"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <cei:idno>
                            <xsl:attribute name="id" select="$sub-charter-ref"/>
                            <xsl:value-of select="concat( 'Urk. ', $sub-charter-ref)"/>
                        </cei:idno>
                    </xsl:otherwise>
                </xsl:choose>
                <cei:chDesc>
                    <xsl:variable name="description-tokens" select="tokenize(ueberlieferung/beschreibung/text(), '; ')"/>
                    <cei:abstract>
                        <xsl:apply-templates select="regest"/>
                        <xsl:if test="ueberlieferung/zeugen">
                            <xsl:text> | Zeugen: </xsl:text>
                        </xsl:if>
                        <xsl:apply-templates select="ueberlieferung/zeugen"/>
                    </cei:abstract>
                    <cei:issued>
                        <xsl:apply-templates select="datum"/>
                        <xsl:apply-templates select="ausstellungsort"/>
                    </cei:issued>
                    <cei:witnessOrig>
                       <cei:traditioForm>
                           <xsl:choose>
                               <xsl:when test="$sub-charter-type = 'transfix'">
                                   <xsl:value-of select="concat('Diese Urkunde ist ein Transfix (VID #71) in Urk. ', $main-charter-ref)"/>
                               </xsl:when>
                               <xsl:when test="$sub-charter-type = 'insert'">
                                   <xsl:value-of select="concat('Diese Urkunde ist ein Insert (VID #65) in Urk. ', $main-charter-ref)"/>
                               </xsl:when>
                               <xsl:when test="ancestor::urkunde/teildokumente">
                                   <xsl:text>Teildokumente dieser Rahmenurkunde: </xsl:text>
                                   <xsl:for-each select="ancestor::urkunde/teildokumente/teildokument">
                                       <xsl:value-of select="concat($signatur, '.', position())"/>
                                       <xsl:if test="position() != last()">, </xsl:if>
                                   </xsl:for-each>
                               </xsl:when>
                            </xsl:choose>
                       </cei:traditioForm>
                        <xsl:call-template name="images">
                            <xsl:with-param name="record" select="$effective-record"/>
                            <xsl:with-param name="access-no" select="$access-no"/>
                            <xsl:with-param name="sub-charter-ref" select="$sub-charter-ref"/>
                        </xsl:call-template>
                        <cei:archIdentifier>
                            <cei:settlement>Berlin</cei:settlement>
                            <cei:institution>Universitätsbibliothek der Humboldt-Universität zu Berlin, Abteilung Historische Sammlungen</cei:institution>
                            <xsl:choose>
                                <xsl:when test="ueberlieferung/signatur">
                                    <xsl:apply-templates select="ueberlieferung/signatur"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <cei:idno>
                                        <xsl:value-of select="concat('Urk. ', $main-charter-ref)"/>
                                    </cei:idno>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:call-template name="charter-link">
                                <xsl:with-param name="access-no" select="$access-no"/>
                            </xsl:call-template>
                        </cei:archIdentifier>
                        <cei:physicalDesc>
                            <cei:material>
                                <xsl:choose>
                                    <xsl:when test="contains(document-uri(/), 'aberle')">
                                        <xsl:text>Pergament</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="tokenize(ueberlieferung/beschreibung, ', ')[1]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </cei:material>
                            <cei:dimensions>
                                <xsl:choose>
                                    <xsl:when test="contains(document-uri(/), 'aberle')">
                                        <xsl:value-of select="substring-after(string-join(ueberlieferung/erhaltungszustand//text()), 'Pergament ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="tokenize(ueberlieferung/beschreibung, ', ')[3]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </cei:dimensions>
                            <xsl:apply-templates select="ueberlieferung/erhaltungszustand"/>
                            <xsl:if test="contains(document-uri(/), 'mueller')">
                                <cei:condition>
                                    <xsl:value-of select="$description-tokens[2]"/>
                                </cei:condition>
                            </xsl:if>
                        </cei:physicalDesc>
                        <xsl:apply-templates select="ueberlieferung/rueckvermerke"/>
                        <cei:auth>
                            <xsl:call-template name="seal-data"/>
                            <xsl:apply-templates select="dokumentform"/>
                            <xsl:apply-templates select="ueberlieferung/unterschriften"/>
                            <xsl:apply-templates select="ueberlieferung/notar"/>
                        </cei:auth>
                    </cei:witnessOrig>
                    <cei:diplomaticAnalysis>
                        <xsl:apply-templates select="vermerk"/>
                        <xsl:apply-templates select="ueberlieferung/besonderheit"/>
                        <xsl:apply-templates select="datierungsvermerk"/>
                        <xsl:apply-templates select="ueberlieferung/schreiber"/>
                        <xsl:if test="contains(document-uri(/), 'mueller')">
                            <cei:rubrum>
                                <xsl:value-of select="$description-tokens[contains(., 'Rückvermerk')]"/>
                            </cei:rubrum>
                        </xsl:if>
                    </cei:diplomaticAnalysis>
                    <cei:lang_MOM>
                        <xsl:choose>
                            <xsl:when test="contains(document-uri(/), 'aberle')">
                                <xsl:apply-templates select="ueberlieferung/sprache"/>
                            </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tokenize(ueberlieferung/beschreibung, ', ')[2]"/>
                        </xsl:otherwise>
                        </xsl:choose>
                    </cei:lang_MOM>
                </cei:chDesc>
            </cei:body>
            <cei:back>
                <cei:class>
                    <xsl:choose>
                        <xsl:when test="$sub-charter-type = 'transfix'">
                            <xsl:value-of select="concat('Diese Urkunde ist ein Transfix (VID #71) in Urk. ', $main-charter-ref)"/>
                        </xsl:when>
                        <xsl:when test="$sub-charter-type = 'insert'">
                            <xsl:value-of select="concat('Diese Urkunde ist ein Insert (VID #65) in Urk. ', $main-charter-ref)"/>
                        </xsl:when>
                    </xsl:choose>
                </cei:class>
            </cei:back>
        </cei:text>
    </xsl:template>
    <xsl:template match="signatur">
        <cei:idno id="{./text()}">
            <xsl:value-of select="concat('Urk. ', text())"/>
        </cei:idno>
    </xsl:template>
    <xsl:template match="regest">
        <xsl:apply-templates/>
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
        <xsl:if test="ueberlieferung/beglaubigungsform">
            <cei:sealDesc>
                <xsl:value-of select="ueberlieferung/beglaubigungsform"/>
                <xsl:if test="ueberlieferung/beglaubigungsform and ueberlieferung/siegel">
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:value-of select="ueberlieferung/siegel"/>
            </cei:sealDesc></xsl:if>
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
        <xsl:apply-templates/>
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
    <xsl:template match="dokumentform">
        <cei:sealDesc>
            <xsl:apply-templates/>
        </cei:sealDesc>
    </xsl:template>
    <xsl:template match="unterschriften">
        <cei:subscriptio>
            <xsl:apply-templates/>
        </cei:subscriptio>
    </xsl:template>
    <xsl:template match="notar">
        <cei:notariusDesc>
            <xsl:apply-templates/>
        </cei:notariusDesc>
    </xsl:template>
    <xsl:template match="rueckvermerke">
        <cei:rubrum>
            <xsl:apply-templates/>
        </cei:rubrum>
    </xsl:template>
    <xsl:template match="schreiber">
        <cei:scriptDesc>
            <cei:scribe>
                <xsl:apply-templates/>
            </cei:scribe>
        </cei:scriptDesc>
    </xsl:template>
    <xsl:template match="footnote">
        <cei:note>
            <xsl:value-of select="ancestor::urkunde/anmerkungen/anmerkung[@nr = current()]/text()"/>
        </cei:note>
    </xsl:template>
    <xsl:template name="images">
        <xsl:param name="record"/>
        <xsl:param name="access-no"/>
        <xsl:param name="sub-charter-ref"/>
        <xsl:variable name="image-no" select="xs:int($record/pages/text())"/>
        <xsl:choose>
            <xsl:when test="$sub-charter-ref and $sub-charter-ref = '42.1'">
                <cei:figure>
                    <cei:graphic
                        url="https://www.digi-hub.de/viewer/api/v1/records/1597844174761/files/images/00000001.tif/2750,2500,2000,2000/max/210/default.jpg"
                    />
                </cei:figure>
            </xsl:when>
            <xsl:when test="$sub-charter-ref and $sub-charter-ref = '42.2'">
                <cei:figure>
                    <cei:graphic
                        url="https://www.digi-hub.de/viewer/api/v1/records/1597844174761/files/images/00000001.tif/1850,2500,2000,2000/max/210/default.jpg"
                    />
                </cei:figure>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="1 to $image-no">
                    <cei:figure>
                        <cei:graphic
                            url="https://www.digi-hub.de/viewer/api/v1/records/{$access-no}/files/images/0000000{position()}.tif/full/max/0/default.jpg"
                        />
                    </cei:figure>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="charter-link">
        <xsl:param name="access-no"/>
        <cei:ref>
            <xsl:attribute name="target">
                <xsl:value-of select="concat('https://www.digi-hub.de/viewer/image/', $access-no)"/>
            </xsl:attribute>
        </cei:ref>
    </xsl:template>
</xsl:stylesheet>
