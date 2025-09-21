-- Остаток на дату: 

DECLARE @P1 datetime2(3), 
        @P2 numeric(10), 
        @P3 numeric(10), 
        @P4 numeric(10), 
        @P5 numeric(10), 
        @P6 datetime2(3), 
        @P7 datetime2(3), 
        @P8 varbinary(16); 

SET @P1 = '5999-11-01 00:00:00'; 
SET @P2 = 0; 
SET @P6 = '4022-05-01 00:00:00';  -- Дата, на которую смотрим остаток 
SET @P7 = '5999-11-01 00:00:00'; 
SET @P8 = 0x903600155D72671E11ED33EB2E33A1C1; 

SELECT 
DATEADD(year, -2000, @P6) AS date_time, 
T6._Code AS Code, 
T6._Description AS product, 
T7._Description AS stock, 
T1.Fld5901Balance_ AS amount, 
T1.Fld5902Balance_ AS sales 
FROM ( 
	SELECT 
	T2.Fld5898RRef AS Fld5898RRef, 
	CAST(SUM(T2.Fld5901Balance_) AS NUMERIC(33, 3)) AS Fld5901Balance_, 
	CAST(SUM(T2.Fld5902Balance_) AS NUMERIC(33, 2)) AS Fld5902Balance_ 
	FROM ( 
		SELECT 
		T3._Fld5898RRef AS Fld5898RRef, 
		CAST(SUM(T3._Fld5901) AS NUMERIC(27, 3)) AS Fld5901Balance_, 
		CAST(SUM(T3._Fld5902) AS NUMERIC(27, 2)) AS Fld5902Balance_ 
		FROM zpvd_dt.dbo._AccumRgT5919 AS T3 
		WHERE T3._Period = @P1 AND (T3._Fld5901 <> @P2 OR T3._Fld5902 <> @P2) AND (T3._Fld5901 <> @P2 OR T3._Fld5902 <> @P2) 
		GROUP BY T3._Fld5898RRef 
		HAVING (CAST(SUM(T3._Fld5901) AS NUMERIC(27, 3))) <> 0.0 OR (CAST(SUM(T3._Fld5902) AS NUMERIC(27, 2))) <> 0.0 

		UNION ALL 

		SELECT 
		T4._Fld5898RRef AS Fld5898RRef, 
		CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld5901 ELSE T4._Fld5901 END) AS NUMERIC(21, 3)) AS NUMERIC(27, 3)) AS Fld5901Balance_, 
		CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld5902 ELSE T4._Fld5902 END) AS NUMERIC(21, 2)) AS NUMERIC(27, 2)) AS Fld5902Balance_ 
		FROM zpvd_dt.dbo._AccumRg5896 AS T4 
		WHERE (T4._Period >= @P6) AND (T4._Period < @P7) AND (T4._Active = 0x01) 
		GROUP BY T4._Fld5898RRef 
		HAVING (CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld5901 ELSE T4._Fld5901 END) AS NUMERIC(21, 3)) AS NUMERIC(27, 3))) <> 0.0 
				OR (CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld5902 ELSE T4._Fld5902 END) AS NUMERIC(21, 2)) AS NUMERIC(27, 2))) <> 0.0 
		) AS T2 
	GROUP BY T2.Fld5898RRef 
	HAVING (CAST(SUM(T2.Fld5901Balance_) AS NUMERIC(33, 3))) <> 0.0 OR (CAST(SUM(T2.Fld5902Balance_) AS NUMERIC(33, 2))) <> 0.0 
) AS T1 
INNER JOIN zpvd_dt.dbo._InfoRg3791 AS T5 
    ON (T1.Fld5898RRef = T5._Fld3795RRef) 
LEFT OUTER JOIN zpvd_dt.dbo._Reference152 AS T6 
    ON T5._Fld3792RRef = T6._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T7 
    ON T5._Fld3794RRef = T7._IDRRef 
WHERE T7._Description NOT IN ('9. З-Центр Виртуальный','АЛФАВИТ','БРАК','9. З-Центр Виртуальный','7. З-Центр Бокситовый','4.ЗАПОВЕДНИК-ЦЕНТР','11. З-Центр Сибирский тракт 2 Лицензия',' 6. Заповедник транзитный',' 4.ЗАПОВЕДНИК виртуальный',' 5.ЗАПОВЕДНИК склад','Заповедник-Центр брак','Интернет Магазин ЕКБ ЗЦ','Омск Мира 96 Дискаунтер ДРО','ИМ брак ЕКБ ЗЦ','ИМ брак СПБ ЗЦ','ИМ брак ТЮМЕНЬ','Интернет магазин ОМСК ДРО','Интернет магазин ПЕРМЬ ЗЦ','Интернет магазин СПБ ЗЦ',' Интернет магазин СПБ ЗЦ','Интернет магазин ТЮМЕНЬ ЗЦ'); 
