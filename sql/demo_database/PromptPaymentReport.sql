USE DemoStandard;
GO
CREATE VIEW vw_PromptPayReport
as
SELECT PAT.PatientName as [Patient Name], PAT.DateOfBirth as [Date of Birth], PIns.PolicyNumber as [Health Insurance Policy No],
CAST(Enc.Date as date) as [EncounterDate], CHG.EncounterId, 
CAST(CHG.Date as date) as [Date Charged], CHG.Amount as [Charged by Provider], 
ADJ.Amount as [Adjustment by Insurance], 
PAY.Amount as [Payment by Insurance], CAST(PAY.Date as date) as [Date Paid],
(ADJ.Amount/CHG.Amount*100) as [Adjustment Percent], DATEDIFF(day,CHG.Date,PAY.Date) as [Days until Payment],
InsP.Planname as [Insurance Plan]

FROM
(SELECT Date, EncounterId, Amount, PatientInsuranceId 
from [Transaction]  
WHERE TransactionType='Insurance charged') as CHG

LEFT JOIN
(SELECT Date, EncounterId, Amount
from  
[Transaction]  
WHERE TransactionType='Insurance adjustment') as ADJ on CHG.EncounterId=ADJ.EncounterId

JOIN
(SELECT Date, EncounterId, Amount
from [Transaction]  
WHERE TransactionType='Insurance payment') as PAY on CHG.EncounterId=PAY.EncounterId

JOIN PatientInsurance PIns on PIns.Id=CHG.PatientInsuranceId
JOIN Encounter ENC on ENC.Id=CHG.EncounterId
JOIN vw_PatientInfo PAT on Enc.PatientId=PAT.PatientId
JOIN Provider PRV on PRV.Id=Enc.ProvId
JOIN InsurancePlan InsP on InsP.Id=PIns.PlanId
WHERE InsP.PlanName not like 'Patient%'