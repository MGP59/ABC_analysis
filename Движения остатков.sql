-- Движения остатков начиная с начала предыдущего года 

-- Создаем переменные с датами отчета 

SET DATEFIRST 1
DECLARE @startDate datetime2(3), @endDate datetime2(3); 
SET @startDate = '4022-01-01 00:00:00:00' 
SET @endDate = '4023-01-01 00:00:00:00' 

DECLARE @P1 varbinary(16), 
        @P2 datetime2(3), 
        @P3 varbinary(16); 
SET @P1 = 0x9D75003048DC4E8A11E174C703FF7D3B; 
SET @P2 = '4022-10-01 00:00:00'; 
SET @P3 = 0xB3CE001195C2174A11DA5B231945798A; 

SELECT 
DATEADD(year, -2000, T1._Period) AS date_time, 
T3._Description AS stock, 
T4._Description AS product, 
CASE WHEN T1._RecordKind = 0.0 THEN T1._Fld5901 ELSE -T1._Fld5901 END AS amount 
FROM zpvd_dt.dbo._AccumRg5896 AS T1 
LEFT OUTER JOIN zpvd_dt.dbo._InfoRg3791 AS T2 
    ON T1._Fld5898RRef = T2._Fld3795RRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference190 AS T3 
    ON T2._Fld3794RRef = T3._IDRRef 
LEFT OUTER JOIN zpvd_dt.dbo._Reference152 AS T4 
    ON T2._Fld3792RRef = T4._IDRRef 
WHERE (T1._Period >= @startDate) AND (T1._Period < @endDate) 
    AND (T3._Description NOT IN ('9. З-Центр Виртуальный','АЛФАВИТ','БРАК','9. З-Центр Виртуальный','7. З-Центр Бокситовый','4.ЗАПОВЕДНИК-ЦЕНТР','11. З-Центр Сибирский тракт 2 Лицензия',' 6. Заповедник транзитный',' 4.ЗАПОВЕДНИК виртуальный',' 5.ЗАПОВЕДНИК склад','Заповедник-Центр брак','Интернет Магазин ЕКБ ЗЦ','Омск Мира 96 Дискаунтер ДРО','ИМ брак ЕКБ ЗЦ','ИМ брак СПБ ЗЦ','ИМ брак ТЮМЕНЬ','Интернет магазин ОМСК ДРО','Интернет магазин ПЕРМЬ ЗЦ','Интернет магазин СПБ ЗЦ',' Интернет магазин СПБ ЗЦ','Интернет магазин ТЮМЕНЬ ЗЦ')); 
