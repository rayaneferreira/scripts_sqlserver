     /* :::::::::::::::::::::::::::::::::::::::::::::::::::
	NÃO PODE TER CONEXÕES ATIVAS 
	::::::::::::::::::::::::::::::::::::::::::::::::::: */ 

	DECLARE @DATABASE VARCHAR(MAX)= 'DetachAtach'
		    

	SET NOCOUNT ON 


	DECLARE @SPID AS VARCHAR(5)
	
	IF(OBJECT_ID('TEMPDB..#PROCESSOS') IS NOT NULL) 
	DROP TABLE #PROCESSOS

	
	SELECT CAST(SPID AS VARCHAR(5))SPID
			 INTO #PROCESSOS  
	  FROM MASTER.DBO.SYSPROCESSES A 
			 JOIN MASTER.DBO.SYSDATABASES B ON A.DBID = B.DBID
	 WHERE B.NAME = @DATABASE

	WHILE (SELECT COUNT(*) FROM #PROCESSOS) >0
	BEGIN
		SET @SPID = (SELECT TOP 1 SPID FROM #PROCESSOS) 
		EXEC ('KILL ' +  @SPID)
		PRINT 'KILL ' +  @SPID

	 DELETE FROM #PROCESSOS WHERE SPID = @SPID
	END



/* :::::::::::::::::::::::::::::::::::::::::::::::::::
	ALTERA O STATUS DA DATABASE PARA OFFLINE
	:::::::::::::::::::::::::::::::::::::::::::::::::::*/ 
	USE MASTER 
	ALTER DATABASE   DetachAtach SET OFFLINE 
 

/* :::::::::::::::::::::::::::::::::::::::::::::::::::
	IDENTIFICA NOME, CAMINHO E STATUS ATUAL DA BASE 
	:::::::::::::::::::::::::::::::::::::::::::::::::::*/ 


	SELECT F.NAME, 
			 F.PHYSICAL_NAME,
			 D.STATE_DESC  into #LOCAL_ANTERIOR
	  FROM SYS.DATABASES D 
			 JOIN SYS.MASTER_FILES F ON D.DATABASE_ID = F.DATABASE_ID 
	 WHERE F.DATABASE_ID = DB_ID('DetachAtach');
 
 
	SELECT * 
	  FROM #LOCAL_ANTERIOR
 
/* :::::::::::::::::::::::::::::::::::::::::::::::::::*/
--  MODIFICA O CAMINHO DOS ARQUIVO. INFORME O NOVO CAMINHO
/* :::::::::::::::::::::::::::::::::::::::::::::::::::*/
  
	 ALTER DATABASE DetachAtach MODIFY FILE ( NAME = 'DetachAtach', FILENAME = 'C:\TEMP\DetachAtach.mdf'    )  		
	 
 
	-- Caso exista arquivo NDF
	ALTER DATABASE DetachAtach   MODIFY FILE ( NAME = 'DetachAtach_01' , FILENAME = 'C:\TEMP\\DetachAtach_01.ndf' ) 
 
 

 	-- DETACH arquivo de LOG
	ALTER DATABASE DetachAtach MODIFY FILE ( NAME = DetachAtach_log, FILENAME = 'C:\TEMP\\DetachAtach_log.ldf')


/* :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */
	
	-- ANTES DE COLOCAR A BASE ONLINE CERTIFIQUE QUE OS ARQUIVOS ESTÃO NO NOVO DESTINO.  
	SELECT F.NAME, 
			 F.PHYSICAL_NAME,
			 D.STATE_DESC  
	  FROM SYS.DATABASES D 
			 JOIN SYS.MASTER_FILES F ON D.DATABASE_ID = F.DATABASE_ID 
	 WHERE F.DATABASE_ID = DB_ID('DetachAtach');
   

	-- COLOCA BASE ONLINE
	ALTER DATABASE DetachAtach SET ONLINE 
	 


/* :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

 
 2º Opção para desanexar e anexar um banco.
 
 -- DESANEXANDO ( também não pode haver conexões na base. 
USE master;  
GO  
EXEC sp_detach_db @dbname = N'DetachAtach';  
GO 


-- Vai "Criar"  a base novamente no NOVO local, mesmo procedimento do ALTER DATABASE MODIFY FILE 
--ANEXANDO
CREATE DATABASE DetachAtach   
    ON (FILENAME = 'C:\SQL2019\MSSQL\MSSQL15.MSSQLSERVER\MSSQL\DATA\DetachAtach1.mdf'),
	   (FILENAME = 'C:\SQL2019\MSSQL\MSSQL15.MSSQLSERVER\MSSQL\DATA\DetachAtach2.ndf'),
	   (FILENAME = 'C:\SQL2019\MSSQL\MSSQL15.MSSQLSERVER\MSSQL\DATA\DetachAtach3.ndf'),
	   (FILENAME = 'C:\SQL2019\MSSQL\MSSQL15.MSSQLSERVER\MSSQL\DATA\DetachAtach_log.ldf') 
    FOR ATTACH;  
GO  
 
 
 
  
 
