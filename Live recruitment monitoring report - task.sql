-- live recruitment monitoring report, displaying all appts and whether patients were consented during these appts

--HospitalNumberMother
--age at assessment 
--date of booking 
--appt date 
--which appt it is 
--edd 
--ethnicity -
--difficult speaking english 
--post code 
--gestation at appt
--outcome of consent 

USE [TestSQL]
GO


WITH APPT AS (

SELECT	 HospitalNumberMother, Event_Date, PREGNANCY_ID, '16-Week Appoinment' as [Antenatal Appointment]
FROM	 [BHTS-DATAWH2].Information.[research].[MATERNITY_REPORT_BIB_ANTENATAL_16_WEEK_APPOINTMENT_PART1]

UNION ALL

SELECT   HospitalNumberMother, Event_Date, Pregnancy_id, '28-Week Appoinment' as [Antenatal Appointment]
FROM     [BHTS-DATAWH2].Information.[research].[MATERNITY_REPORT_BIB_ANTENATAL_28_WEEK_APPOINTMENT_PART1]

UNION ALL

SELECT   MotherHospitalNumber, Event_Date, Pregnancy_id, '31-Week Appoinment' as [Antenatal Appointment]
FROM    [BHTS-DATAWH2].Information.[research].[MATERNITY_REPORT_BIB_ANTENATAL_31_WEEK_APPOINTMENT_PART1]

UNION ALL

SELECT   HospitalNumberMother, Event_Date, PREGNANCY_ID, '34-Week Appoinment' as [Antenatal Appointment]
FROM	[BHTS-DATAWH2].Information.[research].[MATERNITY_REPORT_BIB_ANTENATAL_34_WEEK_APPOINTMENT_PART1]

UNION ALL

SELECT   HospitalNumberMother, Event_Date, Pregnancy_id, '36-Week Appoinment' as [Antenatal Appointment]
FROM	[BHTS-DATAWH2].Information.[research].[MATERNITY_REPORT_BIB_ANTENATAL_36_WEEK_APPOINTMENT_PART1]

UNION ALL

SELECT   HospitalNumberMother, Event_Date, Pregnancy_id, '40-Week Appoinment' as [Antenatal Appointment]
FROM	[BHTS-DATAWH2].Information.[research].[MATERNITY_REPORT_BIB_ANTENATAL_40_WEEK_APPOINTMENT_PART1]

UNION ALL


SELECT   HospitalNumberMother, Event_Date, Pregnancy_id, 'Additional Appoinment' as [Antenatal Appointment]
FROM	[BHTS-DATAWH2].Information.[research].[MATERNITY_REPORT_BIB_ANTENATAL_ADDITIONAL_ROUTINE_APPOINTMENT_PART1]

)
, Appt_Deduped as (
SELECT * FROM 
(
select ROW_NUMBER() OVER (PARTITION BY HospitalNumberMother, Pregnancy_id, Event_Date ORDER BY HospitalNumberMother, Event_Date ) as Sqnce, *
FROM APPT
) TT

where Sqnce=1
)

--Select * from  Appt_Deduped 

, BookingCte as (
SELECT * FROM
(
select ROW_NUMBER () OVER (PARTITION BY HospitalNumberMother, Pregnancy_ID ORDER BY Date_Of_Booking, Spoken_Language_Ability_Understands_English) as Sqnce, *
FROM [BHTS-RESEARCH2].WHMATERNITY.[dbo].[CernerAntenatalBookings]
) TT

WHERE Sqnce = 1
)


, ConsentCte as (

SELECT * FROM
(
select ROW_NUMBER() OVER (PARTITION BY HospitalNumberMother, Pregnancy_id, FORM_DT_TM ORDER BY  HospitalNumberMother, FORM_DT_TM DESC) as Sqnce, *
FROM [BHTS-RESEARCH2].WHMATERNITY.[dbo].[CernerMaternityEligible_BiB4All]
)TT

Where Sqnce=1
)

--SELECT * FROM ConsentCte 

SELECT
		 a.HospitalNumberMother,a.Pregnancy_ID, 
		 c.Date_Of_Booking, c.Date_Of_Birth, c.Postcode, c.Ethnic_Category, 
		 c.Spoken_Language_Ability_Understands_English, c.Estimated_Due_Date,
		 a.Event_Date as [Appointment Date],
		 a.[Antenatal Appointment],
		 DATEDIFF(YY, c.Date_Of_Birth,a.Event_Date) as [Age at Assessment],
		 b.CONSENT_GIVEN as [Consent at Assessment],
		 DATEDIFF(WEEK,c.Date_Of_Booking,a.Event_Date) + c.Recorded_Gestation as [Gestation at Assessment]


FROM Appt_Deduped  as a
left join ConsentCte as b
on a.Event_Date = left(b.FORM_DT_TM, 10) AND a.HospitalNumberMother=b.HospitalNumberMother AND a.Pregnancy_id = b.PREGNANCY_ID

left join BookingCte as c
on a.PREGNANCY_ID = c.Pregnancy_ID AND a.HospitalNumberMother=c.HospitalNumberMother
ORDER BY a.HospitalNumberMother,a.PREGNANCY_ID;





		 
		
		



		

		





