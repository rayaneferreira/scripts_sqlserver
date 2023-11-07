


############### Baixar Cumulative Update do Sqlserver ( Informar link de download )  ############### 
# INFORME A URL DO CUMULATIVE UPDATE AQUI !!!

$url = "https://download.microsoft.com/download/3/6/d/36d7d582-e40b-42c2-b1c2-69de56f191eb/SQLServer2019-KB5029378-x64.exe"
 
$filename = [System.IO.Path]::GetFileName($url)
  
$destino = 'C:\temp\' + $filename  


$verificafile = Test-Path -Path $destino
 
 if ($verificafile){
 $getdate = Get-Date
 write-output "
   $getdate 
   Arquivo ja Existe ..: $verificafile" | Out-File -FilePath  "C:\Temp\output.txt"     -Append } 

   else {

 write-output "
   Arquivo Nao Existe ..: $verificafile"  
 
$getdate = Get-Date 
 write-output "
	$getdate 
    Entao Realiza Download em ..: $destino" | Out-File -FilePath  "C:\Temp\output.txt"     -Append
   
    Invoke-WebRequest -Uri $url -OutFile $destino
    }

  

####################################################################################################



$hostName = $env:COMPUTERNAME
 
 
####################################################################################################

#Captura Nome dos Servicos em Running para Pausar
if ( $ServicesSQL = Get-Service | Where-Object { $_.DisplayName -like "SQL*" }  | where Status -eq "Running" ) {  

$ServicesSQL > "c:\temp\output_services_run.txt" 


    if ( $ServiceAgent = Get-Service | Where-Object { $_.Name -like "SQLAgent*" -or $_.Name -like "SQL*Agent*" }| where Status -eq "Running"  )  {  
    
        foreach ($ServiceAgent in $ServiceAgent) {
        
            $ServiceAgentDisplayName = $ServiceAgent.DisplayName
            net stop $ServiceAgentDisplayName
	    
$getdate = Get-Date
write-output "******************************************
$getdate 
*** Stop Service Agent...: $ServiceAgentDisplayName" | Out-File -FilePath  "C:\Temp\output.txt"     -Append
        }    
    }


   
    if ( $ServiceIntegration = Get-Service | Where-Object { $_.DisplayName -like "*Integration*" }  | where Status -eq "Running"  )  {  
    
        foreach ($ServiceIntegration in $ServiceIntegration) {
        
            $ServiceIntegrationDisplayName = $ServiceIntegration.DisplayName
            net stop $ServiceIntegrationDisplayName
	    
$getdate = Get-Date 
write-output "******************************************
$getdate 
*** Stop Service Integration...: $ServiceIntegrationDisplayName"  | Out-File -FilePath  "C:\Temp\output.txt"     -Append
        }    
    }

    

    if ( $ServicesSQL = Get-Service | Where-Object { $_.DisplayName -like "SQL*" }  | where Status -eq "Running" ) {
    
        #Pausar TODOS Servicos do SQL SERVER 
        foreach ($ServicesSQL in $ServicesSQL) {
            
            $DisplayName = $ServicesSQL.DisplayName
            net stop $DisplayName
	    
$getdate = Get-Date
write-output "******************************************
$getdate 
*** Stop Service...: $DisplayName " | Out-File -FilePath  "C:\Temp\output.txt"     -Append
	    }
    }    
 }

####################################################################################################
 


$ServicesStop = Get-Service | Where-Object { $_.DisplayName -like "SQL*" }   
$ServicesStop > "c:\temp\output_services_stop.txt"


####################################################################################################

if ( (Get-Service | Where-Object { $_.Name -like "MSSQL$*" -or $_.Name -like "MSSQLS*"  }).count -gt 1){

$getdate = Get-Date
write-output "
$getdate 
******************************************
Construindo o Prompt Comando de Update pra AllInstances...
******************************************"   | Out-File -FilePath  "C:\Temp\output.txt"     -Append

    $comando = "$destino /quiet   /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances"
            
    Invoke-Expression -Command $comando
 
    Start-Sleep 100

 if ( (Get-Process -Name 'sqlserver*').count -gt 0){
      
       
    
        while ( (Get-Process -Name 'sqlserver*').count -gt 0) {
        
        

        write-output "***** Update em Execucao...***** "
        
            if ( (Get-Process -Name 'sqlserver*').count -eq 0){
       
            $countprocess = $false
            $getdate = Get-Date
            write-output "
			$getdate 
            ******************************************
            Reiniciando Computador...
            ******************************************" | Out-File -FilePath  "C:\Temp\output.txt"     -Append
            
            Restart-Computer
            }
        }
    }
   

 }
 
 
 
 
####################################################################################################

   
if ( (Get-Service | Where-Object { $_.Name -like "MSSQL$*" -or $_.Name -like "MSSQLS*"  }).count -eq 1){

    $IdentificaInstancia = Get-Service | Where-Object { $_.Name -like "MSSQL$*" -or $_.Name -like "MSSQLS*" }
 
    $instanceName = $IdentificaInstancia.Name -replace "MSSQL\$"
$getdate = Get-Date
write-output "
$getdate 
******************************************
*** Nome da Instancia ..:  $instanceName"  | Out-File -FilePath  "C:\Temp\output.txt"     -Append

    $comando = "$destino /quiet  /Action=Patch  /InstanceName=$instanceName /IAcceptSQLServerLicenseTerms"
            
    Invoke-Expression -Command $comando
 
    Start-Sleep 100
    
    if ( (Get-Process -Name 'sqlserver*').count -gt 0){
      
       
    
        while ( (Get-Process -Name 'sqlserver*').count -gt 0) {
        
        write-host "***** Update em Execucao...***** " 
        
		Start-Sleep 100
		$getdate = Get-Date
        write-output "
		$getdate 
		***** Update em Execucao...***** " | Out-File -FilePath  "C:\Temp\output.txt"     -Append
        
            if ( (Get-Process -Name 'sqlserver*').count -eq 0){
       
            $countprocess = $false
            

            write-host "
            ******************************************
            Reiniciando Computador...
            ******************************************"


			$getdate = Get-Date
            write-output "
			$getdate 
            ******************************************
            Reiniciando Computador...
            ******************************************" | Out-File -FilePath  "C:\Temp\output.txt"     -Append
            
            Restart-Computer
			
            }
        }
    }       

 }    