USE [MimirMaster]
GO
/****** Object:  StoredProcedure [dbo].[PROC_InsertTransactionAndBalance]    Script Date: 5/6/2015 7:56:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TV
-- Create date: 2015-05-06
-- Description:	inserts records into Transaction and Balance, for Insurance and Patient
-- =============================================
ALTER PROCEDURE [dbo].[PROC_InsertTransactionAndBalance] 
	-- Add the parameters for the stored procedure here
	@DateEnc Date,
	@EncounterID uniqueidentifier,
	@PatientId uniqueidentifier, 
	@ProviderId Uniqueidentifier,
	@PatientInsuranceId uniqueidentifier,
	@DateInsPaid	Date,
	@DatePatPaid	Date,
	@ChargeAmount	smallmoney,
	@InsAdjAm		smallmoney
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Find Copay Amount
DECLARE @Copay smallmoney
Set @Copay = (Select InsPl.Copay
		From InsurancePlan Inspl
		JOIN PatientInsurance PatIns ON PatIns.PlanId=Inspl.Id
		Where PatIns.PatientId=@PatientId)
	
	
--- Insurance Transaction 1: Charging the Insurance (InsurTr1)


	DECLARE @InsurTr1 Table (
		   [Identific]	uniqueidentifier
           ,[Date]	date
           ,[EncounterId]			uniqueidentifier
           ,[PatientId]				uniqueidentifier
           ,[ProviderId]			uniqueidentifier
           ,[PatientInsuranceId]	uniqueidentifier
           ,[AppliesToPayer]		varchar(20)
           ,[TransactionType]		varchar(20)
           ,[Amount]				smallmoney
			)

	DECLARE @InsurTr1Id uniqueidentifier
	   
	INSERT INTO [dbo].[Transaction]
           ([Date]
           ,[EncounterId]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[TransactionType]
           ,[Amount])
	 OUTPUT INSERTED.* INTO @InsurTr1
     VALUES
           (@DateEnc
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'primary insurance'
           ,'Insurance charged'
           ,@ChargeAmount-@Copay)		   
	
	Set @InsurTr1Id = (Select Identific from @InsurTr1);
		
	INSERT INTO [dbo].[Balance]
           ([Date]
           ,[IsCurrent]
           ,[EncounterID]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[Amount]
           ,[TransactionId])
     VALUES
           (@DateEnc
           ,'0'
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'primary insurance'
           ,@ChargeAmount-@Copay
           ,@InsurTr1Id)
	

--- Insurance Transaction 2: The Insurance adjusts (InsurTr2)

	DECLARE @InsurTr2 Table (
		   [Identific]	uniqueidentifier
           ,[Date]	date
           ,[EncounterId]			uniqueidentifier
           ,[PatientId]				uniqueidentifier
           ,[ProviderId]			uniqueidentifier
           ,[PatientInsuranceId]	uniqueidentifier
           ,[AppliesToPayer]		varchar(20)
           ,[TransactionType]		varchar(20)
           ,[Amount]				smallmoney
			)
	DECLARE @InsurTr2Id uniqueidentifier
	   
	INSERT INTO [dbo].[Transaction]
           ([Date]
           ,[EncounterId]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[TransactionType]
           ,[Amount])
	 OUTPUT INSERTED.* INTO @InsurTr2
     VALUES
           (@DateInsPaid
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'primary insurance'
           ,'Insurance adjustment'
           ,-@InsAdjAm)	
		   
		Set @InsurTr2Id = (Select Identific from @InsurTr2);
		
	INSERT INTO [dbo].[Balance]
           ([Date]
           ,[IsCurrent]
           ,[EncounterID]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[Amount]
           ,[TransactionId])
     VALUES
           (@DateInsPaid
           ,'0'
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'primary insurance'
           ,@ChargeAmount-@Copay-@InsAdjAm
           ,@InsurTr2Id)	   
		   
		   
	--- Insurance Transaction 3: The Insurance pays (InsurTr3)

	DECLARE @InsurTr3 Table (
		   [Identific]	uniqueidentifier
           ,[Date]	date
           ,[EncounterId]			uniqueidentifier
           ,[PatientId]				uniqueidentifier
           ,[ProviderId]			uniqueidentifier
           ,[PatientInsuranceId]	uniqueidentifier
           ,[AppliesToPayer]		varchar(20)
           ,[TransactionType]		varchar(20)
           ,[Amount]				smallmoney
			)
	DECLARE @InsurTr3Id uniqueidentifier
	   
	INSERT INTO [dbo].[Transaction]
           ([Date]
           ,[EncounterId]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[TransactionType]
           ,[Amount])
	 OUTPUT INSERTED.* INTO @InsurTr3
     VALUES
           (@DateInsPaid
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'primary insurance'
           ,'Insurance payment'
           ,-(@ChargeAmount-@Copay-@InsAdjAm))	
		   
		Set @InsurTr3Id = (Select Identific from @InsurTr3);
		
	INSERT INTO [dbo].[Balance]
           ([Date]
           ,[IsCurrent]
           ,[EncounterID]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[Amount]
           ,[TransactionId])
     VALUES
           (@DateInsPaid
           ,'0'
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'primary insurance'
           ,@ChargeAmount-@Copay-@InsAdjAm
           ,@InsurTr3Id)		   
		   
--- Patient Transaction 1: Charging the Patient Copay (PatTr1)

	DECLARE @PatTr1 Table (
		   [Identific]	uniqueidentifier
           ,[Date]	date
           ,[EncounterId]			uniqueidentifier
           ,[PatientId]				uniqueidentifier
           ,[ProviderId]			uniqueidentifier
           ,[PatientInsuranceId]	uniqueidentifier
           ,[AppliesToPayer]		varchar(20)
           ,[TransactionType]		varchar(20)
           ,[Amount]				smallmoney
			)
	DECLARE @PatTr1Id uniqueidentifier
	   
	INSERT INTO [dbo].[Transaction]
           ([Date]
           ,[EncounterId]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[TransactionType]
           ,[Amount])
	 OUTPUT INSERTED.* INTO @PatTr1
     VALUES
           (@DateEnc
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'patient'
           ,'Copay Charged'
           ,@Copay)	
		   
		Set @PatTr1Id = (Select Identific from @PatTr1);
		
	INSERT INTO [dbo].[Balance]
           ([Date]
           ,[IsCurrent]
           ,[EncounterID]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[Amount]
           ,[TransactionId])
     VALUES
           (@DateEnc
           ,'0'
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'patient'
           ,@Copay
           ,@PatTr1Id)	   
		   
--- Patient Transaction 2: the Patient pays Copay (PatTr2)

	DECLARE @PatTr2 Table (
		   [Identific]	uniqueidentifier
           ,[Date]	date
           ,[EncounterId]			uniqueidentifier
           ,[PatientId]				uniqueidentifier
           ,[ProviderId]			uniqueidentifier
           ,[PatientInsuranceId]	uniqueidentifier
           ,[AppliesToPayer]		varchar(20)
           ,[TransactionType]		varchar(20)
           ,[Amount]				smallmoney
			)
	DECLARE @PatTr2Id uniqueidentifier
	   
	INSERT INTO [dbo].[Transaction]
           ([Date]
           ,[EncounterId]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[TransactionType]
           ,[Amount])
	 OUTPUT INSERTED.* INTO @PatTr2
     VALUES
           (@DatePatPaid
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'patient'
           ,'Copay paid'
           ,-@Copay)	
		   
		Set @PatTr2Id = (Select Identific from @PatTr2);
		
	INSERT INTO [dbo].[Balance]
           ([Date]
           ,[IsCurrent]
           ,[EncounterID]
           ,[PatientId]
           ,[ProviderId]
           ,[PatientInsuranceId]
           ,[AppliesToPayer]
           ,[Amount]
           ,[TransactionId])
     VALUES
           (@DatePatPaid
           ,'0'
           ,@EncounterId
           ,@PatientId
           ,@ProviderId
           ,@PatientInsuranceId
           ,'patient'
           ,@Copay-@Copay
           ,@PatTr2Id)	   		   
		   
		   
END

