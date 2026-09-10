xquery version "3.1";
declare namespace cei = "http://www.monasterium.net/NS/cei";
declare boundary-space strip;
declare option exist:serialize "indent=no";

(: enter all charters into a CEI corpus file :)

(: recursively strip whitespace-only text nodes from copied content,
   leaving all other text (including surrounding non-whitespace text) untouched :)
declare function local:strip-ws($nodes as node()*) as node()* {
    for $n in $nodes
    return
        typeswitch ($n)
            case element() return
                element {node-name($n)} {
                    $n/@*,
                    local:strip-ws($n/node())
                }
            case text() return
                if (normalize-space($n) = '') then () else $n
            default return $n
};

let $charters := 
    for $charter in doc('hu_berlin/cei_aberle_prescher_urkundensammlung.xml')//cei:text[@type='charter']
    order by $charter/cei:body/cei:idno
    return local:strip-ws($charter)

return
<cei:cei xmlns:cei="http://www.monasterium.net/NS/cei"
         xmlns:exslt="http://exslt.org/common">
   <cei:teiHeader>
      <cei:fileDesc>
         <cei:titleStmt>
            <cei:title></cei:title>
            <cei:author></cei:author>
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
    <cei:group>{$charters}</cei:group>
   </cei:text>
</cei:cei>