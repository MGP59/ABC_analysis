WITH DirectReports(Name, _Description, Code, _IDRRef, ProductLevel, Sort, Folder) 
AS (SELECT CONVERT(VARCHAR(255), e._Description), 
        e._Description, 
		e._Code, 
        e._IDRRef,
        1,
        CONVERT(VARCHAR(255), e._Description), 
		e._Folder 
    FROM zpvd_dt.dbo._Reference152 AS e
    WHERE _ParentIDRRef = 0x00000000000000000000000000000000   -- Идентификатор отсутствия родителя
    UNION ALL 
    SELECT 
	    CONVERT(VARCHAR(255), REPLICATE ('|    ' , ProductLevel) + e._Description), 
        e._Description, 
		e._Code, 
        e._IDRRef, 
        ProductLevel + 1,
        CONVERT (VARCHAR(255), RTRIM(Sort) + '|    ' + e._Description), 
		e._Folder 
    FROM zpvd_dt.dbo._Reference152 AS e
    JOIN DirectReports AS d ON e._ParentIDRRef = d._IDRRef
    ) 
SELECT 
ROW_NUMBER() OVER (ORDER BY Sort) AS number, 
Sort, 
_Description AS product_, 
Code, 
ProductLevel, 
--LEAD(ProductLevel, 1,0) OVER (ORDER BY Sort) - ProductLevel AS heading, 
CASE WHEN Folder = 0x00 THEN 1 
    WHEN Folder = 0x01 THEN 0 END AS heading 
FROM DirectReports 
ORDER BY Sort; 