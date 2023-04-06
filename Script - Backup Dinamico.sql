	
/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  Gerar Script de Backup Dinamico com Data e Hora. 
  Sendo necessario apenas editar o diretorio de armazenamento. 
  
  Obs: Com a opção COPY_ONLY definida, para não quebrar sequencia de backup feita por alguma ferramenta.
  
  
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/

 /*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- BACKUP FULL
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
DECLARE @SCRIPT VARCHAR(MAX)
DECLARE @SQL	VARCHAR(MAX)
DECLARE @DISK	VARCHAR(MAX)= 'L:\BKP\'

  SET @SCRIPT = ''
  SET @SQL    = ''


SELECT  @SCRIPT = '
  BACKUP DATABASE ' +    '['+a.NAME +']' +'
     TO DISK ='+ '''' + CONVERT(VARCHAR(MAX), @DISK)  + A.NAME + '_FULL_' + convert(varchar,getdate(),112) + '_' + replace(convert(varchar, getdate(), 108), ':', '')+ '.bak'+ ''''+  ' 
      WITH INIT, COPY_ONLY, COMPRESSION, STATS =  10,  NAME = ' +   '''' + CONVERT(VARCHAR(MAX), @DISK)  + A.NAME + '_FULL_' + convert(varchar,getdate(),112) + '_' + replace(convert(varchar, getdate(), 108), ':', '') + '.bak' +  ''''
      + ', DESCRIPTION =' +'''' + 'Backup Full' + ''''

,@SQL = @SQL + CHAR(13) + 'USE ' + '['+a.NAME +']'+ CHAR(13) + CHAR(13) + @SCRIPT + CHAR(13)
  FROM SYS.SYSDATABASES a
      left outer join sys.databases b on a.name = b.name
 WHERE   b.state_desc = 'online'
 /* and not  a.name  in ( 'master', 'msdb','master') */
 PRINT @SQL
 
 
 /*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- BACKUP DIFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
DECLARE @SCRIPT VARCHAR(MAX)
DECLARE @SQL VARCHAR(MAX)
DECLARE @DISK	VARCHAR(MAX)= 'L:\BKP\'


SET @SCRIPT = ''
SET @SQL    = ''
SELECT  @SCRIPT = '
  BACKUP DATABASE ' +    '['+a.NAME +']' +'
     TO DISK ='+ '''' +  CONVERT(VARCHAR(MAX), @DISK)   + A.NAME + '_DIFF_' + convert(varchar,getdate(),112) + '_' + replace(convert(varchar, getdate(), 108), ':', '') + '.bak'+''''+  ' 
      WITH DIFFERENTIAL,INIT, COMPRESSION,  NAME = ' +   '''' +'I:\Backup\'  + A.NAME + '_DIFF_' + convert(varchar,getdate(),112) + '_' + replace(convert(varchar, getdate(), 108), ':', '') + '.bak'+ ''''
      + ', DESCRIPTION =' +'''' + 'Backup Diff' + ''''

,@SQL = @SQL + CHAR(13) + 'USE ' + '['+a.NAME +']'+ CHAR(13) + CHAR(13) + @SCRIPT + CHAR(13)
  FROM SYS.SYSDATABASES a
      left outer join sys.databases b on a.name = b.name
 WHERE b.state_desc = 'online'
   and not a.name   In('tempdb', 'model', 'master', 'model')
   
   and b.recovery_model_desc = 'FULL'
 
 print @SQL
  
  
/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- BACKUP LOG
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
 
DECLARE @SCRIPT VARCHAR(MAX)
DECLARE @SQL VARCHAR(MAX)
DECLARE @DISK	VARCHAR(MAX)= 'L:\BKP\'

  SET @SCRIPT = ''
  SET @SQL    = ''

SELECT  @SCRIPT = '
  BACKUP LOG ' +    '['+a.NAME +']' +'
     TO DISK  ='+ '''' +  CONVERT(VARCHAR(MAX), @DISK)   + A.NAME + '_LOG_' + convert(varchar,getdate(),112) + '_' + replace(convert(varchar, getdate(), 108), ':', '') + '.bak'+ ''''+  ' 
      WITH INIT, COMPRESSION,  NAME = ' +   '''' +  CONVERT(VARCHAR(MAX), @DISK)  + A.NAME + '_LOG_' + convert(varchar,getdate(),112) + '_' + replace(convert(varchar, getdate(), 108), ':', '')  + '.bak'+ ''''
      + ', DESCRIPTION =' +'''' + 'Backup Log' + ''''
  
,@SQL = @SQL + CHAR(13) + 'USE ' + '['+a.NAME +']'+ CHAR(13) + CHAR(13) + @SCRIPT + CHAR(13)
  FROM SYS.SYSDATABASES a
       left outer join sys.databases b on a.name = b.name
 WHERE b.state_desc = 'online'
   and b.recovery_model_desc = 'FULL'
 print @SQL




