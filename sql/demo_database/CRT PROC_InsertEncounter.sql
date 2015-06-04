-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TV
-- Create date: 2015-05-06
-- Description:	inserts records into Encounter
-- =============================================
CREATE PROCEDURE PROC_InsertEncounterAndCRPAndICD 
	-- Add the parameters for the stored procedure here
	@Date Date,
	@PatientId uniqueidentifier, 
	@ProviderId Uniqueidentifier,
	@BillingProviderId uniqueidentifier,
	@OrgId uniqueidentifier,
	@AccountId uniqueidentifier = NULL,
	@CPTCode varchar(10) = NUll,
	@ICDCode varchar(10) = NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MyTable Table (
		[Identific]		uniqueidentifier,
		[Date]			Date,
		[PatientId]		uniqueidentifier,
		[ProvId]		uniqueidentifier,
		[BillingProvId]	uniqueidentifier,
		[OrgId]			uniqueidentifier,
		[AccountId]		uniqueidentifier NULL
			)
	DECLARE @Identifier uniqueidentifier 

    INSERT INTO  [dbo].[Encounter] ([Date],[PatientId],[ProvId],[BillingProvId],[OrgId])
	OUTPUT INSERTED.* INTO @MyTable
	VALUES (@Date, @PatientId, @ProviderId, @BillingProviderId, @OrgId);
	
	Set @Identifier = (Select Identific from @MyTable);

	INSERT INTO [dbo].[EncounterCPT] ([EncounterId], [Code], [CodeSystemVersion], [IsEvalManag])
	VALUES (@Identifier, @CPTCode, 'CPT-4, 2014', '1')
	
	INSERT INTO [dbo].[EncounterDxCode] ([EncounterId], [Code], [CodeSystemVersion])
	VALUES (@Identifier, @ICDCode, 'ICD-9 2014' )
	
END
GO
