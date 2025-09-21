-- Списания товаров 

SET DATEFIRST 1 
DECLARE @startDate datetime2(3), @endDate datetime2(3); 
SET @startDate = '4022-01-01 00:00:00'; 
SET @endDate = '4023-01-01 00:00:00'; 

SELECT 
T14._Description AS product, 
SUM(T1._Fld5901) AS sum_amount, 
SUM(T1._Fld5902) AS sum_price 
FROM zpvd_dt.dbo._AccumRg5896 AS T1 
	LEFT OUTER JOIN zpvd_dt.dbo._InfoRg3791 AS T2 
	    ON (T1._Fld5898RRef = T2._Fld3795RRef) 
	LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T3 
	    ON T2._Fld3794RRef = T3._IDRRef 
	LEFT OUTER JOIN zpvd_dt.dbo._Document238 AS T4 
	    ON T1._RecorderTRef = 0x000000EE AND T1._RecorderRRef = T4._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Document256 AS T5 
	    ON T1._RecorderTRef = 0x00000100 AND T1._RecorderRRef = T5._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Document298 AS T6 
	    ON T1._RecorderTRef = 0x0000012A AND T1._RecorderRRef = T6._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Document270 AS T7 
	    ON T1._RecorderTRef = 0x0000010E AND T1._RecorderRRef = T7._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Document276 AS T8 
	    ON T1._RecorderTRef = 0x00000114 AND T1._RecorderRRef = T8._IDRRef
	LEFT OUTER JOIN zpvd_dt.dbo._Chrc534 AS T9 
	    ON T4._Fld831RRef = T9._IDRRef 
	LEFT OUTER JOIN zpvd_dt.dbo._Chrc534 AS T10 
	    ON T5._Fld1281RRef = T10._IDRRef 
	LEFT OUTER JOIN zpvd_dt.dbo._Chrc534 AS T11 
	    ON T6._Fld2675RRef = T11._IDRRef 
	LEFT OUTER JOIN zpvd_dt.dbo._Chrc534 AS T12 
	    ON T7._Fld1777RRef = T12._IDRRef 
	LEFT OUTER JOIN zpvd_dt.dbo._Chrc534 AS T13 
	    ON T8._Fld1987RRef = T13._IDRRef 
	LEFT OUTER JOIN zpvd_dt.dbo._Reference152 AS T14 
	    ON T2._Fld3792RRef = T14._IDRRef 
WHERE (T1._Period >= @startDate) AND (T1._Period < @endDate) AND (T1._RecorderTRef = 0x0000012A) 
    AND (T11._Description IN ('L31 НЕ учитывать в ревизию Потери и порча товаров ЗА СЧЕТ ПРЕДПРИЯТИЯ','L31 Учитывать в ревизию Потери и порча товаров ЗА СЧЕТ ПРЕДПРИЯТИЯ','L32 Падеж животных и рыб ЗА СЧЕТ ПРЕДПРИЯТИЯ','L33 Падеж животных ЗА СЧЕТ ПРЕДПРИЯТИЯ','L36 Падеж рыб ЗА СЧЕТ ПРЕДПРИЯТИЯ')) 
GROUP BY T14._Description; 