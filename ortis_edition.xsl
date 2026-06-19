<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat" />

  <!-- =========================================================
     ROOT TEMPLATE
     ========================================================= -->
  <xsl:template match="/">
    <html lang="it">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>
          <xsl:value-of select="//tei:titleStmt/tei:title" />
        </title>
        <style><xsl:call-template name="css"/></style>
      </head>
      <body>

        <header class="page-header">
          <h1>
            <xsl:value-of select="//tei:titleStmt/tei:title" />
          </h1>
          <p class="author"> di <xsl:value-of
              select="//tei:titleStmt/tei:author/tei:persName/tei:forename" />
          <xsl:text> </xsl:text>
          <xsl:value-of
              select="//tei:titleStmt/tei:author/tei:persName/tei:surname" />
          </p>
          <p class="edition-info"> Digital edition edited by <xsl:value-of
              select="//tei:editionStmt/tei:respStmt/tei:persName/tei:forename" />
          <xsl:text> </xsl:text>
          <xsl:value-of
              select="//tei:editionStmt/tei:respStmt/tei:persName/tei:surname" /> — <xsl:value-of
              select="//tei:editionStmt/tei:edition/tei:date" />
          </p>
        </header>

        <!-- ======= CONTROLS: choose which versions to show side by side ======= -->
        <section class="controls">
          <p class="controls-label">Compare the versions (select one or more: base text, Gt, Z, L):
</p>
          <div class="controls-buttons">
            <label class="wit-toggle-label">
              <input type="checkbox" class="wit-toggle" value="base" checked="checked" />
              <span class="wit-badge wit-badge-base">base</span>
              <span class="wit-date">(base text)</span>
            </label>
            <xsl:for-each select="//tei:listWit/tei:witness">
              <label class="wit-toggle-label">
                <input type="checkbox" class="wit-toggle" value="{@xml:id}" />
                <span class="wit-badge wit-badge-{@xml:id}">
                  <xsl:value-of select="@xml:id" />
                </span>
                <span class="wit-date">(<xsl:value-of select="tei:date" />)</span>
              </label>
            </xsl:for-each>
          </div>
          <p class="controls-hint"> Text passages marked with a red dotted border and a superscript
    number <span class="example-ref">
              <sup>n</sup>
            </span> refer to the critical apparatus displayed below.
    Personal names and place names are clickable and provide additional information. </p>
          <div class="legend">
            <span class="legend-item"><span class="legend-swatch legend-person"></span> People</span>
            <span class="legend-item"><span class="legend-swatch legend-place"></span> Places</span>
          </div>
        </section>

        <!-- ======= TEXT COLUMNS: testo base + one per witness ======= -->
        <div class="columns" id="columns">
          <div class="column" data-witness="base">
            <h2 class="column-title">
              <span class="wit-badge wit-badge-base">base</span>
            <xsl:text> </xsl:text>(base text) </h2>
            <div class="column-text">
              <xsl:apply-templates select="//tei:text/tei:body" mode="wit">
                <xsl:with-param name="witness" select="'base'" />
              </xsl:apply-templates>
            </div>
          </div>
          <xsl:for-each select="//tei:listWit/tei:witness">
            <xsl:variable name="wid" select="@xml:id" />
          <div class="column hidden-col"
              data-witness="{$wid}">
              <h2 class="column-title">
                <span class="wit-badge wit-badge-{$wid}">
                  <xsl:value-of select="$wid" />
                </span>
              <xsl:text> </xsl:text> (<xsl:value-of
                  select="tei:date" />) </h2>
              <div class="column-text">
                <xsl:apply-templates select="//tei:text/tei:body" mode="wit">
                  <xsl:with-param name="witness" select="$wid" />
                </xsl:apply-templates>
              </div>
            </div>
          </xsl:for-each>
        </div>

        <!-- ======= CRITICAL APPARATUS: fixed panel at the bottom ======= -->
        <section class="apparatus" id="apparatus">
          <div class="apparatus-header" id="apparatus-header" role="button" tabindex="0"
            aria-expanded="true">
            <span>Apparato critico</span>
            <span class="apparatus-toggle" aria-hidden="true">▾</span>
          </div>
          <div class="apparatus-body" id="apparatus-body">
            <ol>
              <xsl:for-each select="//tei:app[tei:rdg]">
                <xsl:variable name="n"><xsl:number level="any" count="tei:app[tei:rdg]" /></xsl:variable>
              <li
                  id="app-{$n}">
                  <span class="apparatus-num">[<xsl:value-of select="$n" />]</span>
                  <xsl:if test="tei:lem">
                    <span class="apparatus-entry">
                      <xsl:call-template name="wit-badges">
                        <xsl:with-param name="wits" select="translate(tei:lem/@wit,'#','')" />
                      </xsl:call-template>
                      <xsl:text> </xsl:text>
                      <xsl:choose>
                        <xsl:when test="tei:lem/tei:lb and not(normalize-space(tei:lem))">
                          <span class="apparatus-text">a capo</span>
                        </xsl:when>
                        <xsl:when test="tei:lem/node()">
                          <span class="apparatus-text">
                            <xsl:apply-templates select="tei:lem/node()" mode="apparatus" />
                          </span>
                        </xsl:when>
                        <xsl:otherwise><em class="apparatus-omitted">om.</em></xsl:otherwise>
                      </xsl:choose>
                    </span>
                  </xsl:if>
                  <xsl:for-each select="tei:rdg">
                    <span class="apparatus-entry">
                      <xsl:call-template name="wit-badges">
                        <xsl:with-param name="wits" select="translate(@wit,'#','')" />
                      </xsl:call-template>
                      <xsl:text> </xsl:text>
                      <xsl:choose>
                        <xsl:when test="tei:lb and not(normalize-space(.))">
                          <span class="apparatus-text">a capo</span>
                        </xsl:when>
                        <xsl:when test="node()">
                          <span class="apparatus-text">
                            <xsl:apply-templates select="node()" mode="apparatus" />
                          </span>
                        </xsl:when>
                        <xsl:otherwise><em class="apparatus-omitted">om.</em></xsl:otherwise>
                      </xsl:choose>
                    </span>
                  </xsl:for-each>
                </li>
              </xsl:for-each>
            </ol>
          </div>
        </section>

        <!-- ======= ENTITY INFO PANEL (populated by JS on click) ======= -->
        <aside id="entity-panel" class="entity-panel" hidden="hidden">
          <button type="button" id="entity-panel-close" aria-label="Chiudi">×</button>
          <div id="entity-panel-content"></div>
        </aside>

        <footer class="page-footer">
          <p>
            <xsl:value-of select="//tei:availability/tei:p" />
          </p>
        </footer>

        <script>
        <xsl:text>var ENTITIES = {</xsl:text>
        <xsl:for-each select="//tei:listPerson/tei:person | //tei:listPlace/tei:place">
            <xsl:text>"</xsl:text><xsl:value-of select="@xml:id" /><xsl:text>": {</xsl:text>
            <xsl:text>"name": "</xsl:text><xsl:value-of
              select="translate(normalize-space((tei:persName|tei:placeName)[1]), '&quot;', '')" /><xsl:text>", </xsl:text>
            <xsl:text>"type": "</xsl:text><xsl:choose>
              <xsl:when test="local-name()='person'">persona</xsl:when>
              <xsl:otherwise>luogo</xsl:otherwise>
            </xsl:choose><xsl:text>", </xsl:text>
            <xsl:text>"occupation": "</xsl:text><xsl:value-of
              select="translate(normalize-space(tei:occupation), '&quot;', '')" /><xsl:text>", </xsl:text>

  <xsl:text>"link": "</xsl:text>
  <xsl:choose>
              <xsl:when test="@sameAs">
                <xsl:value-of select="@sameAs" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@source" />
              </xsl:otherwise>
            </xsl:choose>
  <xsl:text>"</xsl:text>

  <xsl:text>}</xsl:text>

  <xsl:if
              test="position() != last()">
              <xsl:text>,</xsl:text>
            </xsl:if>

          </xsl:for-each>

<xsl:text>};</xsl:text>

<xsl:call-template name="js"/>
</script>
      </body>
    </html>
  </xsl:template>


  <!-- =========================================================
     MODE "wit": render the document as seen by ONE witness.
     Each container template just forwards the $witness param.
     ========================================================= -->

  <xsl:template match="tei:body" mode="wit">
    <xsl:param name="witness" />
  <xsl:apply-templates mode="wit">
      <xsl:with-param name="witness" select="$witness" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="tei:div1" mode="wit">
    <xsl:param name="witness" />
  <section class="div1 div1-{@type}">
      <xsl:apply-templates mode="wit">
        <xsl:with-param name="witness" select="$witness" />
      </xsl:apply-templates>
    </section>
  </xsl:template>

  <xsl:template match="tei:div2[@type='epistola']" mode="wit">
    <xsl:param name="witness" />
  <article class="epistola" id="lettera-{@n}-{$witness}">
      <h3 class="epistola-num">Lettera <xsl:value-of select="@n" /></h3>
      <xsl:apply-templates mode="wit">
        <xsl:with-param name="witness" select="$witness" />
      </xsl:apply-templates>
    </article>
  </xsl:template>

  <xsl:template match="tei:head" mode="wit">
    <xsl:param name="witness" />
  <xsl:choose>
      <xsl:when test="parent::tei:div1[@type='part']">
        <h2 class="part-title">
          <xsl:apply-templates mode="wit">
            <xsl:with-param name="witness" select="$witness" />
          </xsl:apply-templates>
        </h2>
      </xsl:when>
      <xsl:otherwise>
        <h2>
          <xsl:apply-templates mode="wit">
            <xsl:with-param name="witness" select="$witness" />
          </xsl:apply-templates>
        </h2>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:p" mode="wit">
    <xsl:param name="witness" />
  <p>
      <xsl:apply-templates mode="wit">
        <xsl:with-param name="witness" select="$witness" />
      </xsl:apply-templates>
    </p>
  </xsl:template>

  <xsl:template match="tei:opener" mode="wit">
    <xsl:param name="witness" />
  <div class="opener">
      <xsl:apply-templates mode="wit">
        <xsl:with-param name="witness" select="$witness" />
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="tei:dateline" mode="wit">
    <xsl:param name="witness" />
  <p class="dateline">
      <xsl:apply-templates mode="wit">
        <xsl:with-param name="witness" select="$witness" />
      </xsl:apply-templates>
    </p>
  </xsl:template>

  <xsl:template match="tei:closer" mode="wit">
    <xsl:param name="witness" />
  <div class="closer">
      <xsl:apply-templates mode="wit">
        <xsl:with-param name="witness" select="$witness" />
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="tei:signed" mode="wit">
    <xsl:param name="witness" />
  <p class="signed">
      <xsl:apply-templates mode="wit">
        <xsl:with-param name="witness" select="$witness" />
      </xsl:apply-templates>
    </p>
  </xsl:template>

  <!-- inline elements in mode "wit" simply delegate to the shared
     named templates (defined below, used also in default mode) -->
  <xsl:template match="tei:hi" mode="wit"><xsl:call-template name="render-hi" /></xsl:template>
  <xsl:template match="tei:lb" mode="wit"><xsl:call-template name="render-lb" /></xsl:template>
  <xsl:template match="tei:pb" mode="wit"><xsl:call-template name="render-pb" /></xsl:template>
  <xsl:template match="tei:persName" mode="wit"><xsl:call-template name="render-persname" /></xsl:template>
  <xsl:template match="tei:placeName" mode="wit"><xsl:call-template name="render-placename" /></xsl:template>
  <xsl:template match="tei:foreign" mode="wit"><xsl:call-template name="render-foreign" /></xsl:template>

  <!-- =========================================================
     MODE "wit": tei:app
     Pick the reading (lem or rdg) valid for $witness and render
     its content in DEFAULT mode. If the locus has variants
     (i.e. at least one rdg), append a small numbered reference
     to the critical apparatus below.
     ========================================================= -->
  <xsl:template match="tei:app" mode="wit">
    <xsl:param name="witness" />
  <xsl:variable name="reading"
      select="(tei:lem | tei:rdg)[contains(concat(' ', translate(@wit,'#',''), ' '), concat(' ', $witness, ' '))]" />
  <xsl:choose>
      <xsl:when test="tei:rdg">
        <xsl:variable name="n"><xsl:number level="any" count="tei:app[tei:rdg]" /></xsl:variable>
      <xsl:variable
          name="tag">
          <xsl:choose>
            <xsl:when test="tei:lem/tei:p or tei:rdg/tei:p">div</xsl:when>
            <xsl:otherwise>span</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
      <xsl:element
          name="{$tag}">
          <xsl:attribute name="class">app-locus</xsl:attribute>
        <xsl:choose>
            <xsl:when test="$witness='base'">
              <xsl:if test="tei:lem/node()">
                <xsl:apply-templates select="tei:lem/node()" />
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$reading and $reading[1]/node()">
                <xsl:apply-templates select="$reading[1]/node()" />
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        <sup
            class="app-ref">
            <a href="#app-{$n}" title="Vedi apparato critico, nota {$n}">[<xsl:value-of select="$n" />
    ]</a>
          </sup>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$witness='base'">
            <xsl:if test="tei:lem/node()">
              <xsl:apply-templates select="tei:lem/node()" />
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$reading and $reading[1]/node()">
              <xsl:apply-templates select="$reading[1]/node()" />
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- =========================================================
     DEFAULT MODE: used inside the chosen reading of a tei:app
     when rendering the running text columns (preserves italics,
     persName/placeName entities, line breaks, etc.)
     ========================================================= -->

  <xsl:template match="tei:p"><p>
      <xsl:apply-templates />
    </p></xsl:template>

  <xsl:template match="tei:hi" name="render-hi">
    <xsl:choose>
      <xsl:when test="@rend='italic'"><em>
          <xsl:apply-templates />
        </em></xsl:when>
      <xsl:when test="@rend='bold'"><strong>
          <xsl:apply-templates />
        </strong></xsl:when>
      <xsl:otherwise><span class="hi">
          <xsl:apply-templates />
        </span></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:lb" name="render-lb">
    <br />
  </xsl:template>

  <xsl:template match="tei:pb" name="render-pb">
    <span class="pb" title="Inizio pagina {@n} dell'edizione di riferimento">
      <xsl:text>[p. </xsl:text>
      <xsl:value-of select="@n" />
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:foreign" name="render-foreign">
    <span class="foreign" lang="{@xml:lang}">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- persName / placeName: become clickable "entities" when they
     reference a person/place described in the teiHeader -->
  <xsl:template match="tei:persName" name="render-persname">
    <xsl:variable name="id" select="substring-after(@ref,'#')" />
  <xsl:choose>
      <xsl:when test="@ref and //tei:listPerson/tei:person[@xml:id=$id]">
        <span class="entity entity-person" data-entity="{$id}" tabindex="0" role="button">
          <xsl:apply-templates />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="persName-plain">
          <xsl:apply-templates />
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:placeName" name="render-placename">
    <xsl:variable name="id" select="substring-after(@ref,'#')" />
  <xsl:choose>
      <xsl:when test="@ref and //tei:listPlace/tei:place[@xml:id=$id]">
        <span class="entity entity-place" data-entity="{$id}" tabindex="0" role="button">
          <xsl:apply-templates />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="placeName-plain">
          <xsl:apply-templates />
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- =========================================================
     MODE "apparatus": plain, normalized text for the critical
     apparatus panel. No italics/bold, no nested <p> blocks, no
     visual line-breaks: everything reads as a single flat
     sentence. A line-break in the source is made explicit with
     a " / " marker instead of an actual line break, so every
     entry stays fully readable on one or few wrapped lines.
     Entities (persName/placeName) stay clickable and colored.
     ========================================================= -->

  <xsl:template match="tei:p" mode="apparatus">
    <xsl:if test="position() &gt; 1"><xsl:text> </xsl:text></xsl:if>
  <xsl:apply-templates
      mode="apparatus" />
  </xsl:template>

  <xsl:template match="tei:hi" mode="apparatus">
    <xsl:apply-templates mode="apparatus" />
  </xsl:template>

  <xsl:template match="tei:lb" mode="apparatus">
    <xsl:text> / </xsl:text>
  </xsl:template>

  <xsl:template match="tei:pb" mode="apparatus">
    <!-- page breaks are not meaningful inside an apparatus entry -->
  </xsl:template>

  <xsl:template match="tei:foreign" mode="apparatus">
    <xsl:apply-templates mode="apparatus" />
  </xsl:template>

  <xsl:template match="tei:persName" mode="apparatus">
    <xsl:variable name="id" select="substring-after(@ref,'#')" />
  <xsl:choose>
      <xsl:when test="@ref and //tei:listPerson/tei:person[@xml:id=$id]">
        <span class="entity entity-person" data-entity="{$id}" tabindex="0" role="button">
          <xsl:apply-templates mode="apparatus" />
        </span>
      </xsl:when>
      <xsl:otherwise><xsl:apply-templates mode="apparatus" /></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:placeName" mode="apparatus">
    <xsl:variable name="id" select="substring-after(@ref,'#')" />
  <xsl:choose>
      <xsl:when test="@ref and //tei:listPlace/tei:place[@xml:id=$id]">
        <span class="entity entity-place" data-entity="{$id}" tabindex="0" role="button">
          <xsl:apply-templates mode="apparatus" />
        </span>
      </xsl:when>
      <xsl:otherwise><xsl:apply-templates mode="apparatus" /></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- any other/unforeseen element: just keep its text content -->
  <xsl:template match="*" mode="apparatus">
    <xsl:apply-templates mode="apparatus" />
  </xsl:template>

  <xsl:template match="text()" mode="apparatus">
    <xsl:value-of select="normalize-space(.)" />
  <xsl:text> </xsl:text>
  </xsl:template>


  <!-- =========================================================
     Helper: render a list of witness sigla ("L Z Gt", already
     stripped of '#') as small colored badges
     ========================================================= -->
  <xsl:template name="wit-badges">
    <xsl:param name="wits" />
  <xsl:variable name="trimmed" select="normalize-space($wits)" />
  <xsl:if
      test="$trimmed">
      <xsl:choose>
        <xsl:when test="contains($trimmed,' ')">
          <span class="wit-badge wit-badge-{substring-before($trimmed,' ')}">
            <xsl:value-of select="substring-before($trimmed,' ')" />
          </span>
        <xsl:call-template
            name="wit-badges">
            <xsl:with-param name="wits" select="substring-after($trimmed,' ')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <span class="wit-badge wit-badge-{$trimmed}">
            <xsl:value-of select="$trimmed" />
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>


  <!-- =========================================================
     CSS
     ========================================================= -->
  <xsl:template name="css">
    <xsl:text disable-output-escaping="yes"><![CDATA[:root { --col-base: #5a3d8a; --col-L: #8a6d3b; --col-Z: #2f6f9e;
    --col-Gt: #9c4f4f; --col-person: #c0392b; --col-place: #2e7d32; } body { font-family: "Palatino Linotype", "Book Antiqua", Georgia, serif; max-width: 1200px; margin: 0 auto; padding: 1.5em;
    padding-bottom: 5em; line-height: 1.7; color: #2b2520; background: #fdfbf6; } .page-header {
    text-align: center; border-bottom: 2px solid #8a6d3b; padding-bottom: 1em; margin-bottom: 1em; }
    .page-header h1 { font-variant: small-caps; letter-spacing: .05em; margin-bottom: .2em; }
    .author { font-style: italic; margin: .2em 0; } .edition-info { font-size: .85em; color:
    #6b6258; } /* ---- controls ---- */ .controls { background: #f3ecdd; border: 1px solid #d8cdb6;
    border-radius: 6px; padding: .8em 1.2em; margin-bottom: 1.5em; font-size: .9em; }
    .controls-label { font-weight: bold; margin: 0 0 .4em 0; } .controls-buttons { display: flex;
    gap: 1.2em; flex-wrap: wrap; margin-bottom: .5em; } .wit-toggle-label { cursor: pointer;
    display: inline-flex; align-items: center; gap: .35em; font-size: 1em; } .wit-toggle { width:
    1.1em; height: 1.1em; cursor: pointer; } .wit-date { color: #6b6258; font-size: .85em; }
    .controls-hint { margin: .4em 0 0 0; color: #6b6258; } .controls-hint .entity { padding: 0
    .15em; } .example-ref { color: #c0392b; } .wit-badge { display: inline-block; min-width: 1.4em;
    text-align: center; font-weight: bold; font-size: .78em; padding: .05em .35em; border-radius:
    4px; color: #fff; line-height: 1.4; } .wit-badge-base { background: var(--col-base); }
    .wit-badge-L { background: var(--col-L); } .wit-badge-Z { background: var(--col-Z); }
    .wit-badge-Gt { background: var(--col-Gt); } .legend { display: flex; gap: 1.5em; margin-top:
    .6em; flex-wrap: wrap; } .legend-item { display: inline-flex; align-items: center; gap: .4em;
    font-size: .9em; color: #6b6258; } .legend-swatch { display: inline-block; width: .9em; height:
    .9em; border-radius: 3px; border-bottom: 3px solid; } .legend-person { border-bottom-color:
    var(--col-person); background: rgba(192,57,43,.08); } .legend-place { border-bottom-color:
    var(--col-place); background: rgba(46,125,50,.08); } /* ---- columns ---- */ .columns { display:
    flex; gap: 1.5em; align-items: flex-start; } .column { flex: 1 1 100%; min-width: 0; max-width:
    100%; } .column.hidden-col { display: none; } .columns.comparison-mode .column { flex: 1 1 0; }
    .column-title { text-align: center; border-bottom: 2px solid #8a6d3b; padding-bottom: .3em;
    margin-bottom: .6em; } .columns.comparison-mode .column-text { max-height: 65vh; overflow-y:
    auto; border: 1px solid #d8cdb6; border-radius: 6px; padding: 0 1em; } .div1-frontespizio {
    text-align: center; margin: 2em 0; } .div1-frontespizio p { margin: .3em 0; font-variant:
    small-caps; letter-spacing: .1em; } .div1-dedica { border-top: 1px solid #d8cdb6; padding-top:
    1.5em; margin-top: 1.5em; } .part-title { text-align: center; margin-top: 2.5em; } .epistola {
    margin: 2.5em 0; padding-top: 1em; border-top: 1px dashed #d8cdb6; } .epistola-num { text-align:
    center; font-variant: small-caps; letter-spacing: .1em; color: #8a6d3b; } .dateline {
    text-align: right; font-style: italic; } .signed { text-align: right; font-variant: small-caps;
    letter-spacing: .08em; } .pb { font-size: .7em; color: #b0a690; vertical-align: super; margin: 0
    .2em; } /* ---- clickable entities ---- */ .entity { cursor: pointer; border-bottom: 2px solid;
    border-radius: 2px; transition: background-color .15s; } .entity-person { border-bottom-color:
    var(--col-person); } .entity-place { border-bottom-color: var(--col-place); }
    .entity-person:hover, .entity-person:focus { background: rgba(192,57,43,.12); outline: none; }
    .entity-place:hover, .entity-place:focus { background: rgba(46,125,50,.12); outline: none; } /*
    ---- apparatus references in the running text ---- */ .app-locus { border-bottom: 1px dotted
    #c0392b; } .app-ref a { text-decoration: none; color: #c0392b; font-size: .75em; margin-left:
    .05em; } .apparatus { position: fixed; left: 0; right: 0; bottom: 0; background: #fdfbf6;
    border-top: 2px solid #8a6d3b; box-shadow: 0 -4px 16px rgba(0,0,0,.12); z-index: 80; max-height:
    45vh; display: flex; flex-direction: column; } .apparatus-header { display: flex;
    justify-content: space-between; align-items: center; padding: .6em 1.5em; cursor: pointer;
    font-weight: bold; font-variant: small-caps; letter-spacing: .08em; color: #8a6d3b; background:
    #f3ecdd; user-select: none; flex-shrink: 0; } .apparatus-toggle { transition: transform .2s; }
    .apparatus.collapsed .apparatus-toggle { transform: rotate(180deg); } .apparatus-body {
    overflow-y: auto; padding: .8em 1.5em 1.2em; } .apparatus.collapsed .apparatus-body { display:
    none; } .apparatus ol { padding-left: 1.4em; margin: 0; } .apparatus li { margin-bottom: .7em; }
    .apparatus li.highlight { background: #fff4cc; } .apparatus-num { font-weight: bold; color:
    #8a6d3b; margin-right: .3em; } .apparatus-entry { margin-right: 1.2em; display: inline-block; }
    .apparatus-text { font-style: italic; white-space: normal; } .apparatus-omitted { color: #999; }
    /* ---- entity info panel ---- */ .entity-panel { position: fixed; top: 1.2em; right: 1.2em;
    max-width: 320px; background: #fff; border: 1px solid #c9bfa8; border-radius: 8px; box-shadow: 0
    6px 20px rgba(0,0,0,.18); padding: 1em 1.2em; z-index: 100; } .entity-panel[hidden] { display:
    none; } .entity-panel h4 { margin: 0 0 .3em 0; } .entity-panel p { margin: .3em 0; font-size:
    .9em; } .entity-occupation { color: #6b6258; font-style: italic; } #entity-panel-close {
    position: absolute; top: .2em; right: .5em; border: none; background: none; font-size: 1.2em;
    cursor: pointer; color: #6b6258; } .page-footer { margin-top: 2em; padding-top: 1em; border-top:
    1px solid #d8cdb6; font-size: .8em; color: #6b6258; } @media (max-width: 800px) {
    .columns.comparison-mode { flex-direction: column; } .columns.comparison-mode .column-text {
    max-height: none; overflow: visible; } } ]]></xsl:text></xsl:template>


  <!-- =========================================================
     JAVASCRIPT
     ========================================================= -->
  <xsl:template name="js"> document.addEventListener('DOMContentLoaded', function () { /* ---- fixed
    critical apparatus panel ---- */ var apparatus = document.getElementById('apparatus'); var
    apparatusHeader = document.getElementById('apparatus-header'); var apparatusBody =
    document.getElementById('apparatus-body'); function setApparatusCollapsed(collapsed) {
    apparatus.classList.toggle('collapsed', collapsed);
    apparatusHeader.setAttribute('aria-expanded', collapsed ? 'false' : 'true'); }
    apparatusHeader.addEventListener('click', function () {
    setApparatusCollapsed(!apparatus.classList.contains('collapsed')); });
    apparatusHeader.addEventListener('keydown', function (e) { if (e.key === 'Enter' || e.code ===
    'Space') { e.preventDefault();
    setApparatusCollapsed(!apparatus.classList.contains('collapsed')); } });
    document.querySelectorAll('.app-ref a').forEach(function (a) { a.addEventListener('click',
    function (e) { e.preventDefault(); var id = this.getAttribute('href').slice(1); var target =
    document.getElementById(id); if (!target) return; setApparatusCollapsed(false);
    target.scrollIntoView({ block: 'nearest' }); target.classList.add('highlight');
    setTimeout(function () { target.classList.remove('highlight'); }, 1500); }); }); /* ---- entity
    info panel ---- */ var panel = document.getElementById('entity-panel'); var panelContent =
    document.getElementById('entity-panel-content'); var closeBtn =
    document.getElementById('entity-panel-close'); function showEntity(id) { var info =
    ENTITIES[id]; if (!info) return; var html = '&lt;h4&gt;' + info.name + '&lt;/h4&gt;'; if
    (info.type === 'persona') { html += '&lt;p class="entity-occupation"&gt;Personaggio&lt;/p&gt;';
    } else { html += '&lt;p class="entity-occupation"&gt;Luogo&lt;/p&gt;'; } if (info.occupation)
    html += '&lt;p&gt;' + info.occupation + '&lt;/p&gt;'; if (info.note) html += '&lt;p&gt;' +
    info.note + '&lt;/p&gt;'; if (info.link) html += `<p>
      <a href="${info.link}" target="_blank" rel="noopener">External Link ↗</a>
    </p>`;
    panelContent.innerHTML = html; panel.removeAttribute('hidden'); }
    document.querySelectorAll('.entity').forEach(function (el) { el.addEventListener('click',
    function (e) { e.stopPropagation(); showEntity(this.getAttribute('data-entity')); });
    el.addEventListener('keydown', function (e) { if (e.key === 'Enter' || e.code === 'Space') {
    e.preventDefault(); showEntity(this.getAttribute('data-entity')); } }); });
    closeBtn.addEventListener('click', function () { panel.setAttribute('hidden', 'hidden'); });
    document.addEventListener('click', function (e) { if (!panel.hasAttribute('hidden') &amp;&amp;
    !panel.contains(e.target)) { panel.setAttribute('hidden', 'hidden'); } }); /* ---- witness
    column toggles ---- */ var checkboxes =
    Array.prototype.slice.call(document.querySelectorAll('.wit-toggle')); var columnsEl =
    document.getElementById('columns'); function updateColumns() { var checked =
    checkboxes.filter(function (c) { return c.checked; }); if (checked.length === 0) {
    checkboxes[0].checked = true; checked = [checkboxes[0]]; } var visible = checked.map(function
    (c) { return c.value; }); document.querySelectorAll('.column').forEach(function (col) { if
    (visible.indexOf(col.getAttribute('data-witness')) !== -1) { col.classList.remove('hidden-col');
    } else { col.classList.add('hidden-col'); } }); columnsEl.classList.toggle('comparison-mode',
    visible.length > 1); } checkboxes.forEach(function (c) { c.addEventListener('change',
    updateColumns); }); updateColumns(); /* ---- synchronized scrolling between columns (comparison
    mode) ---- */ var syncing = false; document.querySelectorAll('.column-text').forEach(function
    (col) { col.addEventListener('scroll', function () { if (syncing ||
    !columnsEl.classList.contains('comparison-mode')) return; syncing = true; var range =
    col.scrollHeight - col.clientHeight; var ratio = range &gt; 0 ? col.scrollTop / range : 0;
    document.querySelectorAll('.column-text').forEach(function (other) { if (other !== col) { var
    otherRange = other.scrollHeight - other.clientHeight; other.scrollTop = ratio * otherRange; }
    }); syncing = false; }); }); }); </xsl:template>

</xsl:stylesheet>