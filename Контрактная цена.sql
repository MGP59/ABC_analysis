-- Контрактная цена

-- Создаем переменные с датами отчета
DROP TABLE IF EXISTS #Price, #Price_Zakup, #TPrice; 

SET DATEFIRST 1
DECLARE @startDate date; 
SET @startDate = '4023-05-01 00:00:00:00'; 

DECLARE @P1 varbinary(16), 
        @P2 varbinary(16); 
SET @P1 = 0x9D75003048DC4E8A11E174C703FF7D3B; 
SET @P2 = 0xB3CE001195C2174A11DA5B231945798A; 

-- Цена за штуку товара 

SELECT 
T4._Period, 
T4._Fld23028RRef, 
T4._Fld23031 AS price 
INTO #Price 
FROM db_upp82_new.dbo._InfoRg23026 AS T4 
LEFT OUTER JOIN db_upp82_new.dbo._Reference159 AS T5 
    ON T4._Fld23028RRef = T5._IDRRef 
WHERE (T4._Fld23027RRef = @P1) AND (T4._Period <= @startDate); 

-- Цена за штуку товара закупочная 

SELECT
T1.Fld5589RRef, 
T1.Fld5592_ AS price 
INTO #Price_Zakup 
FROM (
    SELECT
    T4._Fld5589RRef AS Fld5589RRef, 
    T4._Fld5592 AS Fld5592_
    FROM (
        SELECT 
        T3._Fld5589RRef AS Fld5589RRef, 
        T3._Fld5590RRef AS Fld5590RRef,
        T3._Fld5591RRef AS Fld5591RRef, 
        MAX(T3._Period) AS MAXPERIOD_
        FROM zpvd_dt.dbo._InfoRg5588 AS T3 
        WHERE T3._Period <= @startDate AND T3._Active = 0x01 AND ((T3._Fld5591RRef = @P2)) 
        GROUP BY T3._Fld5589RRef, T3._Fld5590RRef, T3._Fld5591RRef 
		) AS T2 
INNER JOIN zpvd_dt.dbo._InfoRg5588 AS T4 
ON T2.Fld5589RRef = T4._Fld5589RRef AND T2.Fld5590RRef = T4._Fld5590RRef AND T2.Fld5591RRef = T4._Fld5591RRef AND T2.MAXPERIOD_ = T4._Period) AS T1; 

SELECT 
DATEADD(year, -2000, T6._Period) AS date_time, 
T4._Code AS Code, 
T4._Description AS product, 
CASE WHEN T6.price IS NOT NULL THEN T6.price ELSE P.price END AS price  -- установленная цена товара, если нет - то закупочная цена 
INTO #TPrice 
FROM (
	SELECT 
	T2._Fld5888RRef AS Fld5888RRef, 
	T2._Fld5886RRef AS Fld5886RRef, 
	CAST(SUM(T2._Fld5891) AS NUMERIC(27, 3)) AS Fld5891Balance_ 
	FROM zpvd_dt.dbo._AccumRgT5895 AS T2 
	WHERE (T2._Period = @startDate) AND (T2._Fld5891 <> 0) 
	GROUP BY T2._Fld5888RRef, T2._Fld5886RRef 
	HAVING (CAST(SUM(T2._Fld5891) AS NUMERIC(27, 3))) <> 0.0 
	) AS T1 
LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T3 
	ON T1.Fld5888RRef = T3._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference152 AS T4 
	ON T1.Fld5886RRef = T4._IDRRef 
LEFT OUTER JOIN #Price_Zakup AS P 
	ON T1.Fld5886RRef = P.Fld5589RRef 
OUTER APPLY (                                   -- Присоединение цены с условием, что цена должна быть объявлена раньше
	SELECT TOP (1) T6.price, T6._Period  
	FROM #Price AS T6 
	WHERE (T6._Period <= @startDate) AND (T6._Fld23028RRef = T4._IDRRef) 
	ORDER BY T6._Period DESC 
	) AS T6 

SELECT 
Code, 
product, 
MAX(date_time) AS LastDate, 
AVG(last_price) AS price 
FROM (
    SELECT 
	Code, 
	product, 
	date_time, 
	FIRST_VALUE(price) OVER (PARTITION BY Code,product ORDER BY date_time DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS last_price 
    FROM #TPrice ) AS LastPrice 
GROUP BY Code, product; 

DROP TABLE IF EXISTS #Price, #Price_Zakup, #TPrice; 