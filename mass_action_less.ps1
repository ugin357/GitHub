##Write-Host "Disconnect from any  VC";
##Disconnect-VIServer * -confirm:$false -force -ErrorAction SilentlyContinue
#Введи адрес Vcenter
Write-Host "Введи IP Vcenter" -ForegroundColor Green
#Читаю адрес Vcenter
$Vcenter = Read-Host 
#Пишу адрес Vcenter в скрипт
Write-Output = $Vcenter
#Подключаюсь к Vcenter под УЗ
Connect-VIServer $Vcenter -ErrorAction Stop

function PowerOffVM {

$power = Get-VM $VM

Stop-VMGuest $VM -ErrorAction SilentlyContinue -Confirm:$false
Sleep -Seconds (3)
    
    if ((Get-VM $VM.PowerState) -eq "Poweredoff" ) {
    Write-Host "Выключилась" -ForegroundColor Green
    Get-VM $VM | select -Property Name,PowerState
    } -ErrorAction SilentlyContinue

    else { Write-Host "Скоро выключится" -ForegroundColor Yellow | Out-Null
    Get-VM $VM | select -Property Name,PowerState
    }
} 

function PowerOnVM {
Start-VM $VM -ErrorAction SilentlyContinue
Sleep -Seconds (3)
Write-Host "
Включилась
" -ForegroundColor Green
Get-VM $VM | select Name,PowerState
} 




#Спрашиваю про ВМ
Write-Host "Какую ВМ ищем?"
#Узнаю имя ВМ
$VM = Read-Host
#Получаю список всех ВМ
Get-VM $VM -ErrorAction Stop

#Узнаю какое действие хочет выполнить пользователь
#Write-Host "что будем делать?"
Write-Host "[===========================================================]" -ForegroundColor Green
Write-Host " Что будем делать?:  
    --Power_On - Press ( on ) ,
    --Power_Off - Press ( off ) ,
    --Reboot - Press ( reboot ) ,
    --Delete_VM - Press ( delete VM ),
    --Edit_Cpu_VM - Press - ( editcpu ),
    --Edit_Ram_VM - Press - ( editram ),
    --Get_Info - Press - ( info )," -foregroundcolor DarkMagenta;
Write-Host "[===========================================================]" -ForegroundColor Green
#задаю переменную $targetaction
$targetaction = Read-Host "Your choise?" 

##Выбор действия
#включить\выключить\удалить
if ($targetaction -eq "on") { 
Write-Host = "Включаю!" -ForegroundColor Green
PowerOnVM $VM 
} elseif ($targetaction -eq "off") {
Write-Host = "Выключаю!" -ForegroundColor Red
PowerOffVM $VM 
} elseif ($targetaction -eq "reboot") {
Write-Host = "Ребутаю!" -ForegroundColor Red
Restart-VM $VM 
}
elseif ($targetaction -eq "delete VM") {
Write-Host = "!!!Ты уверен?!!!" -ForegroundColor Red
$check_del = Read-Host " "Yes" or "No" ?"    
    if ($check_del -eq "yes") {
    PowerOffVM $VM -WhatIf:$true -force Continue;
    Write-Host = "!!!УДАЛЯЮ!!!" -ForegroundColor Red
    Remove-VM $VM -DeletePermanently
    }
    else {
    Write-Host = "!!!Не ломай инфру!!!" -ForegroundColor Yellow
    }
}

elseif ($targetaction -eq "info") {
Write-Host "Инфа по VM!" -ForegroundColor Green
Get-VM $VM | select Name,PowerState,NumCpu,MemoryGB,Folder,CreateDate,Id,ProvisionedSpaceGB,UsedSpaceGB 
}

elseif ($targetaction -eq "editcpu") {
Write-Host = "$VM will be off" -ForegroundColor Red
Write-Host = "Please Enter Target CPU" -ForegroundColor DarkMagenta
$targetCpu = Read-Host "Enter Target CPU"
PowerOffVM $VM 
Get-VM $VM Set-VM -NumCpu $targetCpu -Confirm:$false 
Write-Host = "Start VM?" -ForegroundColor DarkMagenta
$chose = Read-Host "Start VM?" 
    
    if ($chose -eq "yes") {
    PowerOnVM $VM
    Write-Host "Включаю" -ForegroundColor Green
    }
    elseif ($chose -eq "no") {
    Write-Host "Смотри сам" -ForegroundColor Green
    }
    else {
    Write-Host "Ничего не понял, оставил выключеным, если надо будет - сам включишь" -ForegroundColor Yellow
    }
    
} 

elseif ($targetaction -eq "editram") {
Write-Host = "$VM will be off" -ForegroundColor Red
Write-Host = "Please Enter Target Ram" -ForegroundColor DarkMagenta
$targetRam = Read-Host "Enter Target RAM"
PowerOffVM $VM
Get-VM $VM Set-VM -MemoryGb $targetRam -Confirm:$false 
Write-Host = "Start VM?" -ForegroundColor DarkMagenta
$chose = Read-Host "Start VM?" -ForegroundColor DarkMagenta
    
    if ($chose -eq "yes") {
    PowerOnVM $VM
    Write-Host "Включаю" -ForegroundColor Green
    }
    elseif ($chose -eq "no") {
    Write-Host "Смотри сам" -ForegroundColor Green
    }

else {
        Write-Host "Ничего не понял, оставил выключеным, если надо будет - сам включишь" -ForegroundColor Yellow
    }
    <# Action when this condition is true #>
}

else {
Write-Host "Ничего не понял, иди спать пожалуйста" -ForegroundColor Yellow
}
#
#