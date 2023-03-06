Disconnect-VIServer * -confirm:$false -force -ErrorAction SilentlyContinue
#Введи адрес Vcenter
Write-Host "Введи IP Vcenter" -ForegroundColor Green
#Читаю адрес Vcenter
$Vcenter = Read-Host 
#Пишу адрес Vcenter в скрипт
Write-Output = $Vcenter
#Подключаюсь к Vcenter под УЗ
Connect-VIServer $Vcenter -ErrorAction Stop

#указываем txt файл где вписываем список VM
$vmList = Get-Content -Path "E:\list.txt"

function PowerOffVM {
    $power = Get-VM $VM | Select-Object -Property PowerState
    if ((Get-VM $VM).PowerState -eq "PoweredOn") {  
        do {
        Stop-VMGuest $VM -Confirm:$false -ErrorAction SilentlyContinue
        Get-VM $VM | Select-Object -Property Name,PowerState
        Start-Sleep -Seconds (5) 
        }
        
        until (((Get-VM $VM).PowerState) -eq "Poweredoff" ) 
    
    }

  
    else {
        Write-Host "$VM в статусе $power" -ForegroundColor Yellow
    }
}
function PowerOnVM {
    $power = Get-VM $VM | Select-Object -Property PowerState
    
        if  ((Get-VM $VM).PowerState -eq "PoweredOff")  { 
            do { 
            Start-VM $VM -ErrorAction SilentlyContinue
            Start-Sleep -Seconds (3)
            }
            until (((Get-VM $VM ).PowerState) -eq "PoweredOn" ) 
        }
        else { 
        Write-Host "$VM в статусе $power" 
        }
    
}

Write-Host " Что будем делать с $vmlist?
--Power_On - Press ( on ) ,
--Power_Off - Press ( off ) ,"
$targetaction = Read-Host "Your choise?"

if ($targetaction -eq "off") { 
    Write-Host = "Выключаю!" -ForegroundColor Green
    foreach ($vmName in $vmList) {
        $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
        PowerOffVM $vm
        Write-Host "Выключил" -ForegroundColor Green
        }
    Write-Host "Выключились" -ForegroundColor Green
    } 
elseif ($targetaction -eq "on") {
    Write-Host = "Отправляю включать!" -ForegroundColor Red
    foreach ($vmName in $vmList) { 
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    PowerOnVM $vm
    }
}
#
