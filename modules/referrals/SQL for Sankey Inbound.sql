Use DemoStandard
Select DISTINCT COUNT (R.Id) OVER(PARTITION BY PInt.Lastname, PExt.LastName, R.Inbound, PlanName) as 'Count',r.Inbound, PInt.Lastname as ReferredFrom, PExt.LastName as ReferredTo, PExt.Specialty, InsP.PlanName, 'link' as LINK 
from Referral R
JOIN Provider PInt on R.IntProvID=PInt.Id
JOIN Provider PExt on R.ExtProvId=PExt.Id
JOIN Patient P on R.PatientId=P.Id
JOIN PatientInsurance PatI on P.id=PatI.Patientid
JOIN InsurancePlan InsP on InsP.Id=PatI.PlanId
WHERE R.DateInitiated BETWEEN <Parameters.Date From> AND <Parameters.Date To>
and r.Inbound='0'