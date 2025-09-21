-- Последняя цена продаж без самовывозов

-- Создаем переменные с датами отчета

DROP TABLE IF EXISTS #SalesNoPickups; 

SET DATEFIRST 1
DECLARE @startDate date, @endDate date; 
SET @startDate = '4022-05-01 00:00:00'; 
SET @endDate = '4023-05-01 00:00:00'; 

DECLARE @P1 varbinary(16), 
        @P14 varbinary(16), 
        @P15 nvarchar(4000), 
        @P16 varbinary(16), 
        @P17 nvarchar(4000), 
        @P18 varbinary(16), 
        @P19 nvarchar(4000), 
        @P20 varbinary(16), 
        @P21 nvarchar(4000), 
        @P22 nvarchar(4000), 
        @P23 numeric(10), 
        @P24 numeric(10), 
        @P39 varbinary(16), 
        @P40 nvarchar(4000), 
        @P41 nvarchar(4000), 
        @P44 varbinary(16); 
SET @P1 = 0x9305F3F1C6005CA142137940ACD83354; 
SET @P14 = 0xB0378B21101D5C174AD924DA2935BEB7; 
SET @P15 = 'ПродажаОпт'; 
SET @P16 = 0xB81D4F90AA654E50436B62A76E8F75D2; 
SET @P17 = 'ПродажаРозница'; 
SET @P18 = 0xBE4733B7E3B9ABB14A3FB49211FE404A; 
SET @P19 = 'ВозвратРозница'; 
SET @P20 = 0xB3049882DD725C2D46ADD8423DF0AD67; 
SET @P21 = 'ВозвратОпт'; 
SET @P22 = ''; 
SET @P23 = 1; 
SET @P24 = 0; 
SET @P39 = 0xB0378B21101D5C174AD924DA2935BEB7; 
SET @P40 = ''; 
SET @P41 = 'Розничный покупатель'; 
SET @P44 = 0x9F3C003048DC4E8A11E14645D5396800; 

SELECT 
DATEADD(year, -2000, T1._Period) AS date_time, 
CASE 
    WHEN (T1._Fld5968RRef = @P14) THEN @P15 
	WHEN (T1._Fld5968RRef = @P16) THEN @P17 
	WHEN (T1._Fld5968RRef = @P18) THEN @P19 
	WHEN (T1._Fld5968RRef = @P20) THEN @P21 
	ELSE @P22 
	END AS type_of_operation, 
CASE 
	WHEN (T5._Fld7907RRef = @P1 AND T7._Fld10207 <> 0x01) AND (T11._Description IS NOT NULL) THEN T11._Description 
	ELSE T6._Description 
	END AS stock,  -- торговая точка без самовывоза 
T5._Code AS Code, 
T5._Description AS product, 
CASE WHEN T7._Fld10207 = 0x01 THEN @P23 ELSE @P24 END AS pickup,  -- самовывоз (0 - нет, 1 - да) 
CASE 
	WHEN (T5._Fld7907RRef = @P1 AND T7._Fld10207 <> 0x01) AND (T11._Description IS NOT NULL) THEN T11._Description 
	ELSE T10._Description 
	END AS stock_int,  -- торговая точка с самовывозом 
T11._Description AS vet_kab, 
CASE WHEN (T5._Fld7907RRef = @P1 AND T7._Fld10207 <> 0x01) THEN 1 ELSE 0 END AS veterinary,  -- 1 - услуга, 0 - нет 
T1._Fld5969 AS amount, 
T1._Fld5971 AS price, 
T1._Fld5970 AS sales, 
COALESCE(T1._Fld5970 / NULLIF(T1._Fld5969,0), 0) AS retail_price, 
CASE WHEN (T1._Fld5968RRef = @P39) THEN CASE WHEN T9._Description IS NULL THEN @P40 ELSE T9._Description END ELSE @P41 END AS agent 
INTO #SalesNoPickups 
FROM zpvd_dt.dbo._AccumRg5963 AS T1 
LEFT OUTER JOIN zpvd_dt.dbo._Reference110 AS T2 
ON T1._Fld5964RRef = T2._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._InfoRg3791 AS T3 
LEFT OUTER JOIN zpvd_dt.dbo._Reference110 AS T4 
ON T3._Fld3795RRef = T4._IDRRef 
ON (T2._IDRRef = T4._IDRRef) 
LEFT OUTER JOIN zpvd_dt.dbo._Reference152 AS T5 
ON T3._Fld3792RRef = T5._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T6 
ON T1._Fld10334RRef = T6._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Document270 AS T7 
ON T1._RecorderTRef = 0x0000010E AND T1._RecorderRRef = T7._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference84 AS T8 
ON T1._Fld5967RRef = T8._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference112 AS T9 
ON T8._OwnerIDRRef = T9._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T10 
ON T3._Fld3794RRef = T10._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T11 
ON T6._Fld10361RRef = T11._IDRRef 
WHERE (T1._Period BETWEEN @startDate AND @endDate) AND (T5._Fld7900RRef <> @P44) AND (T6._Description IS NOT NULL); 

-- Без самовывозов 

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
    FIRST_VALUE(retail_price) OVER (PARTITION BY Code,product ORDER BY date_time DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS last_price 
    FROM #SalesNoPickups 
    WHERE agent NOT IN ('СИМБИО-УРАЛ ООО', 'Афина ООО', 'Нью Винд ТД ООО', 'ВЕСТЕРН ТД ООО', 'ВЭН- ПРЕМЬЕР ООО', 'Никоненко Д.В. ИП', 'Епифанов М.Ю.  ИП') 
        AND stock NOT IN (' 6. Заповедник транзитный','11. З-Центр Сибирский тракт 2 Лицензия','Интернет Магазин ЕКБ ЗЦ','Омск Мира 96 Дискаунтер ДРО','ИМ брак ЕКБ ЗЦ','ИМ брак СПБ ЗЦ','ИМ брак ТЮМЕНЬ','Интернет магазин ОМСК ДРО','Интернет магазин ПЕРМЬ ЗЦ','Интернет магазин СПБ ЗЦ','Интернет магазин ТЮМЕНЬ ЗЦ') 
) AS TLast 
GROUP BY Code, product; 

DROP TABLE IF EXISTS #SalesNoPickups; 