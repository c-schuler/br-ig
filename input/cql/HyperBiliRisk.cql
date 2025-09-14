library "HyperBiliRisk" version '1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "LOINC": 'http://loinc.org'
code "Total bilirubin": '1975-2' from "LOINC" display 'Bilirubin.total [Mass/volume] in Serum or Plasma'
code "Direct bilirubin": '1968-7' from "LOINC" display 'Bilirubin.direct [Mass/volume] in Serum or Plasma'
code "Indirect bilirubin": '1971-1' from "LOINC" display 'Bilirubin.indirect [Mass/volume] in Serum or Plasma'
code "TcB (skin) bilirubin": '58941-6' from "LOINC" display 'Bilirubin [Mass/volume] in Skin'

context Patient

define "Is Guidance Recommended?":
  true

define "Determine Score":
  20

define TotalBiliObs:
  [Observation: code in { "Total bilirubin" }] O
    where O.status in { 'final', 'amended', 'corrected' }
      and O.value is Quantity

define DirectBiliObs:
  [Observation: code in { "Direct bilirubin" }] O
    where O.status in { 'final', 'amended', 'corrected' }
      and O.value is Quantity

define IndirectBiliObs:
  [Observation: code in { "Indirect bilirubin" }] O
    where O.status in { 'final', 'amended', 'corrected' }
      and O.value is Quantity

define LatestTotalBili: First( TotalBiliObs O sort by effective desc )
define LatestDirectBili: First( DirectBiliObs O sort by effective desc )
define LatestIndirectBili: First( IndirectBiliObs O sort by effective desc )