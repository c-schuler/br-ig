library "HyperBiliRisk" version '1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "LOINC": 'http://loinc.org'
code "Total bilirubin": '1975-2' from "LOINC" display 'Bilirubin.total [Mass/volume] in Serum or Plasma'
code "Direct bilirubin": '1968-7' from "LOINC" display 'Bilirubin.direct [Mass/volume] in Serum or Plasma'
code "Indirect bilirubin": '1971-1' from "LOINC" display 'Bilirubin.indirect [Mass/volume] in Serum or Plasma'
code "TcB (skin) bilirubin": '58941-6' from "LOINC" display 'Bilirubin [Mass/volume] in Skin'
code "Gestational age": '11884-4' from "LOINC" display 'Gestational age Estimated'

context Patient

define "Baby Age in Hours":
  difference in hours between FHIRHelpers.ToDate(Patient.birthDate) and FHIRHelpers.ToDateTime(LatestTotalBili.effective as FHIR.dateTime)

define "Gestational Age in Weeks":
  First([Observation: code in { "Gestational age" }] O
    where O.status in { 'final', 'amended', 'corrected' }
      and O.value is Quantity
    sort by effective desc
  ).value as Quantity

define "Phototherapy Threshold":
  case
    when "Gestational Age in Weeks".value < 35 then null
    else
      case
        when "Baby Age in Hours" < 96 then (0.125 * "Baby Age in Hours") + (5 + (0.5 * ("Gestational Age in Weeks".value - 35)))
        else 17 + (0.5 * ("Gestational Age in Weeks".value - 35))
      end
  end

define "Is Guidance Recommended?":
  "Phototherapy Threshold" is not null and (LatestTotalBili.value as Quantity).value > "Phototherapy Threshold"

define "Determine Score":
  case
    when "Gestational Age in Weeks".value < 35 then 'guidance not applicable for <35 weeks gestation'
    when "Is Guidance Recommended?" then 'phototherapy recommended'
    else 'no specific recommendation'
  end

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