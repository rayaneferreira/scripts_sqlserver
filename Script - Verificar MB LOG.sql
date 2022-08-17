/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Verifica % usado do log com base no tamanho atual 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/ 
use vistarquivos
 dbcc sqlperf(logspace);
    
 with log as (
 select a.name
       ,a.database_id
       ,a.collation_name
       ,a.recovery_model_desc
       ,a.log_reuse_wait_desc 
   from sys.databases a
  where a.database_id = DB_ID()
   ) , MB as 
   (
  select 
		a.database_id
		,a.File_id      as ID
        ,a.name
        ,substring(a.physical_name,0,4) as Local 
	    ,CAST(CAST(a.size AS DECIMAL(19, 0)) *8 / 1024     AS DECIMAL(10, 2)) as   InicialSizeMB
		,CAST(cast(b.total_log_size_in_bytes  as decimal (19,0))/1024/1024 AS DECIMAL(10, 2))as AtualSizeMB 
		,CAST(CAST(a.max_size AS DECIMAL(19, 0)) *8 / 1024 AS DECIMAL(10, 2)) Max_sizeMB
		,CAST(CAST(a.growth AS DECIMAL(19, 0)) *8 / 1024   AS DECIMAL(10, 2)) GrowthMB
		,a.type
		,a.type_desc
		,a.physical_name
   from sys.master_files a
        full outer join sys.dm_db_log_space_usage b on a.database_id = b.database_id
  where a.database_id = DB_ID()
      ),
	  volume as 
	  (
SELECT DISTINCT
    VS.volume_mount_point [Montagem] ,
    VS.logical_volume_name AS [Volume] ,
    CAST(CAST(VS.total_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Total (GB)] ,
    CAST(CAST(VS.available_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Espaço Disponível (GB)] ,
    CAST(( CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [Espaço Disponível ( % )] ,
    CAST(( 100 - CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [Espaço em uso ( % )]
FROM
    sys.master_files AS MF
    CROSS APPLY [sys].[dm_os_volume_stats](MF.database_id, MF.file_id) AS VS
WHERE
    CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 < 100

	)
	select  b.name
           ,b. Local 
	       ,b.InicialSizeMB
		   ,b.AtualSizeMB
		   ,b.Max_sizeMB
		 -- ,b.Max_sizeMB - b.AtualSizeMB 
		   ,b.GrowthMB
		   ,c.[Total (GB)]  
		   ,c.[Espaço Disponível (GB)]
		   ,c.[Espaço Disponível ( % )]
		   ,type_desc
		   ,physical_name
		   ,collation_name
	       ,recovery_model_desc
		   ,log_reuse_wait_desc 
	  from log a
	       inner join mb b on a.database_id = b.database_id 
		   inner join  volume c on b.Local = c.Montagem
		   WHERE type_desc ='LOG'











/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Verifica a escrita no log 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
 select a.name
       ,a.database_id
       ,a.collation_name
       ,a.recovery_model_desc
       ,a.log_reuse_wait_desc  -- escrita atual no log
   from sys.databases a

/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Verifica o tamanho dos log's em MB e o diretorio 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
 
 select 
		 File_id      as ID
        ,name
        ,substring(physical_name,0,4) as Local 
	    ,CAST(CAST(size AS DECIMAL(19, 0)) *8 / 1024 AS DECIMAL(10, 2))   SizeMB
		,CAST(CAST(max_size AS DECIMAL(19, 0)) *8 / 1024 AS DECIMAL(10, 2)) Max_sizeMB
		,CAST(CAST(growth AS DECIMAL(19, 0)) *8 / 1024 AS DECIMAL(10, 2)) GrowthMB
		,type
		,type_desc
		,physical_name
   from sys.master_files 
  where type = 1
       
/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Espaço disponivel em DISCO 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/

SELECT DISTINCT
    VS.volume_mount_point [Montagem] ,
    VS.logical_volume_name AS [Volume] ,
    CAST(CAST(VS.total_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Total (GB)] ,
    CAST(CAST(VS.available_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Espaço Disponível (GB)] ,
    CAST(( CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [Espaço Disponível ( % )] ,
    CAST(( 100 - CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [Espaço em uso ( % )]
FROM
    sys.master_files AS MF
    CROSS APPLY [sys].[dm_os_volume_stats](MF.database_id, MF.file_id) AS VS
WHERE
    CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 < 100;
	
/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Verificar transações ativas na base 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
	
	SELECT
    A.session_id,
    A.transaction_id,
    C.name AS database_name,
    B.database_transaction_begin_time,
    (CASE B.database_transaction_type
        WHEN 1 THEN 'Read/write transaction'
        WHEN 2 THEN 'Read-only transaction'
        WHEN 3 THEN 'System transaction'
    END) AS database_transaction_type,
    (CASE B.database_transaction_state
        WHEN 1 THEN 'The transaction has not been initialized.'
        WHEN 3 THEN 'The transaction has been initialized but has not generated any log records.'
        WHEN 4 THEN 'The transaction has generated log records.'
        WHEN 5 THEN 'The transaction has been prepared.'
        WHEN 10 THEN 'The transaction has been committed.'
        WHEN 11 THEN 'The transaction has been rolled back.'
        WHEN 12 THEN 'The transaction is being committed. In this state the log record is being generated, but it has not been materialized or persisted.'
    END) AS database_transaction_state,
    B.database_transaction_log_record_count
FROM
    sys.dm_tran_session_transactions A
    JOIN sys.dm_tran_database_transactions B ON A.transaction_id = B.transaction_id
    JOIN sys.databases C ON B.database_id = C.database_id 