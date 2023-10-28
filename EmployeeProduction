--
--DECLARE @start AS DATETIME
--DECLARE @end AS DATETIME
--DECLARE @pcid AS INT
--DECLARE @state AS INT

--SET @start = '9-6-2023'
--SET @end = '9-7-2023'
--SET @state = '27'
--SET @pcid = '30'


SELECT CONVERT(DATE,th.WorkComplete) [WorkDay]
, th.EmployeeID, 
SUM(rd.Feet) [Feet]
, th.ProfitCenterID
,th.DLSID
,CASE WHEN (r.ReleasedRouteMiles) IS NULL THEN 0 ELSE r.ReleasedRouteMiles END AS ReleasedRouteMiles

	INTO #feet
	FROM TicketHistory th (NOLOCK)
	JOIN dbo.tblResponseDetail rd (NOLOCK) ON th.TicketHistoryID=rd.TicketID
	JOIN dbo.Employee e (NOLOCK) ON th.EmployeeID = e.EmployeeID
	JOIN dbo.ProfitCenter pc (NOLOCK) ON th.ProfitCenterID = pc.ProfitCenterID
	JOIN dbo.State s (NOLOCK) ON pc.StateID = s.StateID
	--JOIN dbo.DLS dls (NOLOCK) ON dls.DLSID = th.DLSID
	JOIN dbo.DLSRoute r (NOLOCK) ON r.DLSID = th.DLSID

	WHERE th.WorkComplete BETWEEN @start AND dbo.DatetoEndofDay(@end)
	AND th.ProfitCenterID IN (@pcid)
	AND s.StateID IN (@state)
	AND th.DeletedDate IS NULL
	AND rd.DeletedDate IS NULL
	AND r.DeletedDate IS NULL
	AND isnull(rd.IsSystem,0) = 0

	GROUP BY CONVERT(DATE,th.WorkComplete), th.EmployeeID, th.ProfitCenterID, th.DLSID, r.ReleasedRouteMiles
	ORDER BY WorkDay, th.EmployeeID

	-------------------

	--SELECT * FROM #feet ORDER BY EMployeeID, WorkDay

	--DROP TABLE #feet

	SELECT f.EmployeeID, f.WorkDay, ProfitCenterID, SUM(Feet) [Feet], SUM(ReleasedRouteMiles) [ReleasedRouteMiles]
	INTO #feet2
	FROM #feet f
	GROUP BY f.WorkDay, f.EmployeeID, ProfitCenterID
	ORDER BY EMployeeID, WorkDay


-------------
----Mileage--   
-------------

--DECLARE @start AS DATETIME
--DECLARE @end AS DATETIME
--DECLARE @pcid AS INT
--DECLARE @state AS INT

--SET @start = '9-6-2023'
--SET @end = '9-7-2023'
--SET @state = '27'
--SET @pcid = '30'

	---adds row numbers, 1 equals the first entry by the employee per day
	SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeID, CONVERT(DATE, CreatedDate) ORDER BY CreatedDate) AS rn,
VehicleInformationID, EmployeeID, VehicleNumber, Mileage, CreatedDate
INTO #temp1
FROM dbo.EmployeeVehicleHistory (NOLOCK)
WHERE CreatedDate BETWEEN @start and DATEADD(DAY, 7, dbo.DatetoEndofDay(@end))
---need to grab extra days of information incase a long weekend or vacation sine last odometer check in

--removes entries that were not the first entry of the day
SELECT * 
INTO #temp2
FROM #temp1
WHERE rn = '1'

--introduces row number to represent the number of entries made by employee in the previous temp table
SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY CreatedDate) AS EmpDateID,
EmployeeID,
VehicleNumber,
Mileage,
CreatedDate
INTO #temp3
FROM #temp2

--joins temp3 on itself with a lagged element to calculate for mileage the previous day
SELECT t.EmployeeID, t.VehicleNumber, --t.CreatedDate, t.Mileage [Mog],
--tt.CreatedDate [lagdate], tt.Mileage [log],
CONVERT(DATE, tt.CreatedDate) [Mileage Date],
CASE WHEN (t.Mileage - tt.Mileage) > 750 OR (t.Mileage - tt.Mileage) < 0 THEN NULL
ELSE (t.Mileage - tt.Mileage) END [Mileage]
INTO #temp4
FROM #temp3 t
JOIN #temp3 tt
ON tt.EmployeeId = t.EmployeeId AND tt.VehicleNumber = t.VehicleNumber 
AND tt.EmpDateID + 1 =  t.EmpDateID

----------------------


--DECLARE @start AS DATETIME
--DECLARE @end AS DATETIME
--DECLARE @pcid AS INT
--DECLARE @state AS INT

--SET @start = '9-6-2023'
--SET @end = '9-7-2023'
--SET @state = '27'
--SET @pcid = '30'

SELECT pc.ProfitCenterShortDesc
, s.StateCode
, CONVERT(DATE,p.WorkDay) [WorkDay]
, e.FirstName + ' ' + e.LastName [Employee]
, e.EmployeeID
, p.TicketCount
, p.UtilityCount
, p.DailyPay
, p.DailyRevenue
--, p.EffectiveLaborHours
,p.ActualHoursSQI [ActualHours]
,f.Feet [Feet]
,m.Mileage
,f.ReleasedRouteMiles [ReleasedRouteMiles]
,
CASE 
    WHEN p.DailyPay = 0 THEN 0 -- Handle division by zero by returning 0
    ELSE p.DailyRevenue / p.DailyPay
    END AS RevenueToPayRatio

	FROM Production p (NOLOCK) 
	JOIN Employee e (NOLOCK) ON p.EmployeeID = e.EmployeeID
	JOIN dbo.ProfitCenter pc (NOLOCK) ON p.ProfitCenterID = pc.ProfitCenterID
	JOIN dbo.State s (NOLOCK) ON pc.StateID = s.StateID
    JOIN #feet2 f ON f.EmployeeID = e.EmployeeID AND p.WorkDay = f.WorkDay --AND p.ProfitCenterID = r.ProfitCenterID
	LEFT JOIN #temp4 m ON p.EmployeeID = m.EmployeeID AND CONVERT(DATE, p.WorkDay) = m.[Mileage Date]
	--JOIN dbo.DLS dls ON dls.EmployeeID = f.EmployeeID AND dls.ReleaseDate = f.WorkDay
	--JOIN dbo.DLSRoute r ON f.DLSID = r.DLSID

	WHERE p.WorkDay BETWEEN @start AND dbo.DatetoEndofDay(@end)
	AND p.ProfitCenterID IN (@pcid)
	AND p.EffectiveLaborHours <> 0
	AND f.Feet IS NOT NULL
	AND f.Feet <> 0
	--AND r.DeletedDate IS NULL
	--AND r.ReleasedRouteMiles IS NOT NULL

	--GROUP BY pc.ProfitCenterShortDesc, s.StateCode, e.FirstName + ' ' + e.LastName, p.WorkDay, e.EmployeeID, 
	--p.DailyPay, p.DailyRevenue, p.ActualHoursSQI,  p.TicketCount, p.UtilityCount, --f.Feet,
	-- m.Mileage
	ORDER BY s.StateCode, pc.ProfitCenterShortDesc, e.FirstName + ' ' + e.LastName, p.WorkDay ASC, RevenueToPayRatio DESC


	------------------
DROP TABLE #temp1
DROP TABLE #temp2
DROP TABLE #temp3
DROP TABLE #temp4
DROP TABLE #feet2
DROP TABLE #feet
