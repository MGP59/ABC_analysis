-- Пенетрация товаров за период 

DROP TABLE IF EXISTS #checks;  

-- Создаем переменные с датами отчета


SET DATEFIRST 1
DECLARE @startDate date, @endDate date; 
SET @startDate = '4022-05-01 00:00:00'; 
SET @endDate = '4023-05-01 00:00:00'; 

DECLARE @P1 varbinary(16), 
        @P3 numeric(10), 
        @P4 varbinary(16); 
SET @P1 = 0x9305F3F1C6005CA142137940ACD83354; 
SET @P3 = 0; 
SET @P4 = 0x80D3D485647B9A7811EB28B8BD26A4E5; 

SELECT 
DATEADD(year, -2000, T1._Period) AS date_time, 
T4._Description AS stock, 
T3._Code AS Code, 
T3._Description AS product, 
T1._Fld6089 AS amount, 
T1._Fld6090 AS sales, 
CAST(T1._Fld6086RRef AS INT) AS buyer, -- клиент (0 - почти все разные клиенты) 
CAST(T1._RecorderRRef AS INT) AS number, -- номер чека 
CASE WHEN T7._Fld10207 = 0x01 THEN 1 ELSE 0 END AS pikup,  -- 1 - самовывоз, 0 - нет 
T8._Description AS int_shop, 
T9._Description AS vet_kab, 
CASE WHEN (T3._Fld7907RRef = @P1 AND T7._Fld10207 <> 0x01) THEN 1 ELSE 0 END AS veterinary  -- 1 - услуга, 0 - нет 
INTO #checks 
FROM zpvd_dt.dbo._AccumRg6076 AS T1
	LEFT OUTER JOIN zpvd_dt.dbo._InfoRg5620 AS T2
	    ON (T1._RecorderRRef = T2._Fld5622RRef)
	LEFT OUTER JOIN zpvd_dt.dbo._Reference152 AS T3
	    ON T1._Fld6077RRef = T3._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T4
	    ON T1._Fld6079RRef = T4._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Reference108 AS T5
	    ON T1._Fld6086RRef = T5._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Reference197 AS T6
	    ON T1._Fld6085RRef = T6._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Document270 AS T7
	    ON T2._Fld5621RRef = T7._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T8
	    ON T4._Fld10330RRef = T8._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T9
	    ON T4._Fld10361RRef = T9._IDRRef 
WHERE (T1._Period >= @startDate) AND (T1._Period < @endDate) 
ORDER BY T1._Period; 

-- Без самовывозов 

SELECT 
Code, 
product, 
COUNT(DISTINCT number) AS penetration 
FROM #checks 
GROUP BY Code, product; 

DROP TABLE IF EXISTS #checks; 