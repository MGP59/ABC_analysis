-- Поставщики 

SELECT 
T1._Code AS Code, 
T1._Description AS product, 
T2._Description AS purveyor 
FROM zpvd_dt.dbo._Reference152 AS T1 
LEFT OUTER JOIN zpvd_dt.dbo._Reference112 AS T2 
    ON T1._Fld7954RRef = T2._IDRRef; 