-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF (OBJECT_ID('tempdb..#DB_logins') IS NOT NULL) 
DROP TABLE #DB_logins



create table #DB_logins(
	 LoginName		varchar(max)
	,is_disabled	int	
	,ds_is_disabled	varchar(max)
			)


IF (OBJECT_ID('tempdb..#DB_USers') IS NOT NULL) 
DROP TABLE #DB_USers



create table #DB_USers(
	 DBName		varchar(max)
	,UserName	varchar(max)
			)


-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
-- Captura Logins Desabilitados | is_disabled = 1
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


insert into #DB_logins
select 
        convert(varchar(max),c.name)
	   , is_disabled
	   , case when is_disabled = 1 then 'Desabilitado'
			  when is_disabled = 0 then 'Habilitado'
		  end as ds_is_disabled
  from sys.server_permissions				A	WITH(NOLOCK)
    JOIN sys.server_principals				B	WITH(NOLOCK)	ON	A.grantee_principal_id = B.principal_id
    LEFT JOIN sys.syslogins				C	WITH(NOLOCK)	ON	B.sid = C.sid	 
where is_disabled = 1  
 and not c.name like '%#%' 
  ORDER BY c.name 


select * 
  from #DB_logins



-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
-- Verifica  se o Usuario na base de dados
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

 
INSERT #DB_USers
EXEC sp_MSforeachdb 
	'
use [?]
SELECT ''?'' AS DB_Name,
	   l.LoginName as UserName
  from #DB_logins l
 where  exists ( select * 
					  from sys.sysusers u
					 where u.name = l.LoginName
					)


'


SELECT @@servername
	 
	,'USE [' + DBNAME + ']' 
	+ ' DROP USER [' + username + ']' as UserName
	 
FROM #DB_USers user1
GROUP BY DBName
	    ,UserName
	 
ORDER BY username

 
 
 -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
