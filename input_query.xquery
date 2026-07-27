xquery version "3.1";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

let $charters := doc('urkundensammlung.xml')/urkundensammlung/urkunde
let $records := doc('records.xml')/xml/records/record

let $nos :=
    for $record in $records
    return substring-before(substring-after($record/titles/title, 'Urkunde '), ',')

for $charter in $charters
return $charter//signatur