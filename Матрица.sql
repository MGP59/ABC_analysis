-- Ассортиментная матрица товаров по форматам магазинов: 

DROP TABLE IF EXISTS #Period; 

SELECT 
T1._Period, 
T2._Description, 
CASE WHEN T4._Description IS NOT NULL THEN T4._Description ELSE T2._Description END AS format_TT, 
T5._Code AS Code, 
T5._Description AS product, 
FIRST_VALUE(T1._Fld9856) OVER (PARTITION BY T2._Description,T5._Description ORDER BY T1._Period DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS amount  -- Последнее количество
INTO #Period 
FROM zpvd_dt.dbo._InfoRg9852 AS T1 
    LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T2 
    LEFT OUTER JOIN zpvd_dt.dbo._Reference211 AS T3 
        ON T2._Fld8630RRef = T3._IDRRef 
        ON (T3._Fld9064RRef = T1._Fld9853RRef) 
    LEFT OUTER JOIN zpvd_dt.dbo._Reference72 AS T4 
        ON T1._Fld9853RRef = T4._IDRRef 
    LEFT OUTER JOIN zpvd_dt.dbo._Reference152 AS T5 
        ON T1._Fld9855RRef = T5._IDRRef 
WHERE T4._Marked <> 0x01 AND T5._Marked <> 0x01 
    AND T2._Description IS NOT NULL 
    AND T5._Description IS NOT NULL 
	AND T5._Description <> '0'; 

SELECT 
Code, 
product, 
SUM(amount) AS sum_amount 
FROM (
    SELECT 
    format_TT, 
    product, 
	Code, 
    MIN(amount) AS amount 
    FROM 
    #Period 
    GROUP BY format_TT, product, Code 
	) AS T1 
GROUP BY product, Code; 

DROP TABLE IF EXISTS #Period; 