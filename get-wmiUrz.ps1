﻿
function get-wmiUrz {
<#
.Synopsis
   Pobieranie informacji o komputerach i urządzeniach z Windows.
.DESCRIPTION
   Narzędzie odpytuje urządzenia przez WMI. Przydatne do inwentaryzacji sprzętu, zainstalowanego oprogramowania, również na urządzeniach z Windows Embedded i POSReady.
.PARAMETER computername
   Jeden lub więcej Hostname lub IP odpytywanej maszyny. 
.PARAMETER credential
   Poświadczenia
.PARAMETER soft
   Możemy odpytać urządzenie o zainstalowane oprogramowanie. Domyślnie pomijane. Akceptuje wieloznaczniki.
.EXAMPLE
   get-wmiUrz -computername Host1
.EXAMPLE
   get-wmiUrz -computername (Get-content .\ListaIP.txt) -credential Administrator -soft 'Mettler Toledo*' | ConvertTo-Csv -NoTypeInformation > .\wagiInwentarz.csv
.EXAMPLE 
   Get-content .\ListaIP.txt | get-wmiUrz | where {$_."FreeRAM[MB]" -lt 100}
.EXAMPLE
   get-wmiUrz localhost -soft * | select -ExpandProperty Oprogramowanie
.NOTES
   Część modułu PBFunkcje.
   https://github.com/piotrbanas/pbfunkcje.git
   Autor: piotrbanas@xper.pl
#>
param(
        [parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   HelpMessage='Poproszę nazwę kompa.')]
        [Alias('Hostname','cn')]
        [string[]]$computername,
        [System.Management.Automation.CredentialAttribute()]$credential,
        [string]$soft = $null
    )
    BEGIN {}

    PROCESS {
    foreach ($computer in $computername) {
        try {
            $ping = Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue
            $os = Get-WmiObject -ComputerName $computer -ClassName win32_operatingsystem -ErrorAction Stop -Credential $credential
            $cs = Get-WmiObject -ComputerName $computer -ClassName win32_computersystem -ErrorAction Stop -Credential $credential
            $cpu = Get-WmiObject -ComputerName $computer -Class win32_processor -ErrorAction Stop -Credential $credential
            $bs = Get-WmiObject -ComputerName $computer -ClassName win32_bios -ErrorAction Stop -Credential $credential
            if ($soft) {
            $so = Get-WmiObject -ComputerName $computer -ClassName win32_Product -ErrorAction Stop -Credential $credential | Where-Object Name -like $Soft
            }
            
            $properties = [ordered]@{Host = $computer
                            Nazwa = $os.CSName
                            Status = $cs.Status
                            'Ping[ms]' = $ping.ResponseTime
                            Organizacja = $os.Organization
                            NazwaOS = $os.Caption
                            WersjaOS = $os.Version
                            ServicePack = $os.CSDVersion
                            DataInstOS = [Management.ManagementDateTimeConverter]::ToDateTime($os.InstallDate)
                            Producent = $cs.Manufacturer
                            Model = $cs.Model
                            BIOS = $bs.Name
                            DataBios = [Management.ManagementDateTimeConverter]::ToDateTime($bs.ReleaseDate)
                            ProducentBIOS = $bs.Mnufacturer
                            Procesor = $cpu.Name
                            Architektura = $cs.SystemType
                            Oprogramowanie = $so.Name
                            Boot = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
                            Domain = $cs.Domain
                            Rdzenie = $cs.NumberOfProcessors
                            'RAM[MB]' = $os.TotalVisibleMemorySize/1kb -as [Int]
                            'FreeRAM[MB]' = $os.FreePhysicalMemory/1kb -as [int]
                            'FreePageFile[MB]' = $os.FreeSpaceInPagingFiles/1kb -as [int]
                            }
   
        } catch {
   
            $properties = [ordered]@{Host = $computer
                            Nazwa = $null
                            Status = 'BŁĄD'
                            'Ping[ms]' = $ping.ResponseTime
                            Organizacja = $null
                            NazwaOS = $null
                            WersjaOS = $null
                            ServicePack = $null
                            DataInstOS = $null
                            Producent = $nullr
                            Model = $null
                            BIOS = $null
                            DataBios = $null
                            ProducentBIOS = $null
                            Procesor = $null
                            Architektura = $null
                            Oprogramowanie = $null
                            Boot = $null
                            Domain = $null
                            Rdzenie = $null
                            'RAM[MB]' = $null
                            'FreeRAM[MB]' = $null
                            'FreePageFile[MB]' = $null
                            }
        } finally {               
   
            $obj = New-Object -TypeName PSObject -Property $properties
            Write-Output $obj
        }
        }
    }
    END {}
    }
