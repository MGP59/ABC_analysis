-- Штрих-коды товаров 

SELECT 
T1._Code AS Code, 
T1._Description AS product, 
STRING_AGG(CONVERT(NVARCHAR(max), T2._Fld5628), ';') AS barcodes 
FROM zpvd_dt.dbo._Reference152 AS T1 
LEFT OUTER JOIN zpvd_dt.dbo._InfoRg5624 AS T2 
    ON T1._IDRRef = T2._Fld5625RRef 
GROUP BY T1._Code, T1._Description; 