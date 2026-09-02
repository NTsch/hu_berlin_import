xquery version "3.1";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

(:validates the given charter(s) against the CEI schema:)

<result>{

(:validate single charter:)
(:let $charter := doc(xmldb:encode('/db/mom-data/metadata.charter.saved/tag:www.monasterium.net,2011:#charter#AT-StiAL#LambachOSB#1454_VIII_20.xml'))
:)
(:validate collection:)
for $charter in doc('/db/niklas/import/hu_berlin/cei_aberle_prescher_urkundensammlung.xml')//cei:text[@type='charter']
(:where contains($charter/base-uri(), '1000'):)
let $xml := <cei:cei>{$charter}</cei:cei>
let $schema := doc('/db/XRX.src/mom/app/cei/xsd/cei.xsd')
let $valrep := validation:jaxv-report($xml, $schema, 'http://www.w3.org/XML/XMLSchema/v1.1')
return if ($valrep//status = 'invalid') then <validationResult><charterUri>{base-uri($charter)}</charterUri>{$valrep}</validationResult>
else ()

}</result>