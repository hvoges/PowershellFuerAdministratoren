# Powershell-Beispiele zum Vortrag "Powershell ohne Emotionen"
# Erstellt von Holger Voges
# Netz-Weise IT-Schulungen
# Freundallee 13a
# 30173 Hannover

# Teil 1:
# Kompatibilität mit der Kommandozeile
# ------------------------------------

# Die meisten Kommandozeilen-Befehle lassen sich auch direkt in der
# Powershell ausführen. Dafür sind meist Aliase (Verweise auf die
# entsprechenden Powershell-Befehle) oder Funktionen implementiert, 
# die die Kompatibilität herstellen

Dir C:\Windows
mkdir c:\Temp
rd c:\temp
man
ls
ipconfig /all

# einfache Commandlets einsetzen
# ------------------------------
# Viele Commandlets funktionieren durch Eingabe des Befehls ohne weitere 
# Optionen

# Anzeigen der laufenden Prozesse ( = tasklist.exe)
Get-Process

# alle verfügbaren Befehle anzeigen
get-command
# und die Powershell-Hilfe aufrufen
get-help
# die Hilfe muß ab Powershell 3.0 erst einmal aktualisiert werden - dafür
# werden Admin-Rechte benötigt
Update-Help

# Alle installierten Dienste und Ihren Status anzeigen
Get-Service

# Installierte Updates anzeigen
Get-HotFix

# Drucker anzeigen
Get-Printer

# Alle Windows-Treiber einsetzen - hier werden schon 2 Parameter eingesetzt 
Get-WindowsDriver -Online -all

# Benötigt Hyper-V: Alle registrierten virtuellen Maschinen anzeigen
Get-VM

# Die verfügbaren Netzwerk-Schnittstellen auflisten
Get-NetIPInterface
# Und alle IP-Adressen (ipV4 und ipV6)
Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp

# Parameter einsetzen
# -------------------
# Parameter übergeben dem Commandlet weitere Optionen. Parameter werden immer mit 
# einem -<Parametername> <Argument> angegeben, wobei nicht alle Paramter ein Argument
# haben, wie man an den obigen Beispielen (-online, -all) schon gesehen hat.
# Es handelt sich dann um Schalter (ein/aus) bzw. Switch-Parameter



# Dienste konfigurieren und beenden
Set-Service -Name wuauserv -StartupType Disabled
Stop-Service -Name wuauserv

# Mit Netzwerk-Schnittstellen und IP-Adressen arbeiten
# Alle Netzwerk-Schnittstellen ausgeben, die keine Verbindung haben
Get-NetIPInterface -ConnectionState Disconnected
# Alle Netzwerkschnittstellen ausgeben, die DHCP-aktiviert sind
Get-NetIPInterface -Dhcp Enabled
# Die Netzwerkschnittstelle ausgeben, der Name 'Lan-Verbindung' lautet
Get-NetIPInterface -InterfaceAlias 'Ethernet'
# Alle ipV4-Adresse ausgeben
Get-NetIPAddress -AddressFamily IPv4
# IP-Adresse setzen 
New-NetIPAddress -IPAddress 10.10.100.10 -PrefixLength 16 -DefaultGateway 10.10.255.254 -InterfaceAlias "Ethernet"
# Auf DHCP setzen
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Enabled -PassThru | Set-DnsClientServerAddress -ResetServerAddresses
# IP-Adresse per Pipeline setzen
Get-NetIPInterface -Dhcp Enabled -AddressFamily IPv4 -ConnectionState Connected | 
    New-NetIPAddress -IPAddress 10.10.100.10 -PrefixLength 16 -DefaultGateway 10.10.255.254 |
    Set-DnsClientServerAddress -ServerAddresses 10.10.0.200,10.10.0.201
# Default wiederherstellen
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Enabled -PassThru | Set-DnsClientServerAddress -ResetServerAddresses
Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -Confirm:$false

# Alle installierten UWP-Apps deinstallieren
Get-AppxPackage | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Out-GridView -PassThru | Remove-AppxProvisionedPackage -Online
Get-AppxPackage | Where-Object Name -eq "Microsoft.MicrosoftOfficeHub"
Get-AppxPackage | Select-Object -Property Name,PackageFamilyName
Get-AppxPackage | Out-GridView
Get-AppxPackage | Out-GridView -PassThru | Export-Csv -Path C:\Temp\appsToRemove.csv -Delimiter ";" -Encoding UTF8

Import-Csv -Delimiter ";" -Path C:\Temp\appsToRemove.csv | Where-Object Name -eq "Microsoft.XboxGamingOverlay" | Remove-AppxPackage
Get-AppxPackage | Out-GridView -PassThru | Export-Clixml -Path C:\Temp\appsToRemove.xml
Import-Clixml -Path C:\Temp\appsToRemove.xml | Where-Object Name -eq "Microsoft.XboxGamingOverlay" | Remove-AppxPackage
Get-AppxPackage | ConvertTo-Json | Out-File -FilePath C:\Temp\apps.json
Get-VM | ConvertTo-Html -PreContent "<h1>Meine VMs</h1>" | Out-File -FilePath C:\Temp\vms.html
Get-Vm | ConvertTo-Csv -Delimiter ";" -NoTypeInformation | Out-File -FilePath C:\Temp\myvms.csv -Encoding utf8

Get-Service | Where-Object Status -in "running","stopped"
Get-ChildItem -Path C:\Windows | 
    Where-Object Length -gt 1MB | 
    Export-CSV -Path c:\temp\files.csv -Encoding UTF8 -Delimiter ";"
get-command get*task*
Get-ScheduledTask | Export-Csv -Path C:\Temp\tasks.csv -Delimiter ";" -Encoding UTF8
Get-Process | Select-Object -Property * -first 1
Get-Process | Select-Object -Property path


# Webseiten abrufen mit Invoke-Webrequest
Invoke-WebRequest -Uri www.netz-weise.de
Invoke-WebRequest -Uri www.netz-weise.de | Select-Object -Property links
$Website = Invoke-WebRequest -Uri www.netz-weise.de
$Website.Links
(Invoke-WebRequest -Uri www.netz-weise.de).Links
((Invoke-WebRequest -Uri www.netz-weise.de).Links).href

# Arbeiten mit dem Eventlog
# Aus dem Application-Log alle Fehler auflisten
Get-EventLog -LogName Application -EntryType Error -After '2020-03-25 17:00' -Before '2020-04-01' -Message "*com*"
# und die Fehler ausgeben - verwendet die Pipeline
Get-EventLog -LogName Application | Out-GridView

Get-WinEvent -ListLog *Power*
Get-WinEvent -LogName "Windows Powershell" | Out-GridView
Get-WinEvent -FilterHashtable @{ 
                                 Logname="*Hyper*"
                                 Providername="Microsoft-Windows-Hyper-V-Compute"
                                 ID=2008
                                 Level=4 
                               } 
# ID = EventID; Level=4: Information
# https://docs.microsoft.com/de-de/powershell/scripting/samples/creating-get-winevent-queries-with-filterhashtable?view=powershell-5.1

# Mit Umgebungsvariablen arbeiten
# Über $env:<Umgebungsvariablenname> greifen sie auf Umgebungsvariablen zu
$env:COMPUTERNAME

# Mit Pfaden arbeiten
# Mit Test-Path könnenSie überprüfen, ob ein Pfad existiert. Test-Path liefert
# true oder false zurück
test-path C:\windows\notepad.exe
# Mit -Pathtype Container oder -Pathtype Leaf können Sie festlegen, dass der
# angegebene Pfad ein Ordner oder eine Leaf-Objekt sein soll. Wir reden hier von
# Contain und Leaf, weil Test-Path auch z.B. mit der Registry funktioniert.
test-path 'C:\Program Files\7-Zip' -PathType Container 

# Split-Path kann Pfade auftrennen
split-path -Path C:\Windows\System32 -Parent
split-path -Path C:\Windows\System32 -Leaf 
# Und join-path erstellt einen Pfad
join-path -Path 'C:\Program Files\' -ChildPath '\HolgerSoft'
'C:\program Files' + 'HolgerSoft'

# Auf Objekteigenschaften zurückgreifen
# -------------------------------------
# Wenn Sie auf die Eigenschaften der Objekte zurück greifen möchten, die Powershell
# Ihnen liefert, stellen Sie entweder den Befehl in Klammern und geben die Eigenschaft 
# an, die Sie aufrufen wollen, um nur diesen einen Wert zurück zu geben:
(Get-NetIPAddress -AddressFamily IPv4).IPAddress

# Oder Sie verwenden die Pipeline - siehe nächstes Beispiel

# Mit der Pipeline arbeiten
# -------------------------
# Die Pipeline funktioniert ähnlich wie die Pipeline in der Windows-Kommandozeile oder
# der Unix-Shell, ist aber ungleich leistungsfähiger, da Powershell mit Objekten und
# nicht mit Text arbeitet.
# Mit dem |-Zeichen wird die Ausgabe an das nächste Cmdlet zur Weiterverareitung weiter
# gegeben

# Virtuelle Festplatten verwalten
# -------------------------------
# eine neue virtuelle Festplatte anlegen
new-vhd -Path D:\Hyper-V\Festplatte.vhdx -SizeBytes 50GB -Dynamic
# eine Differenz-Datei zur neuen Festplatte anlegen
new-vhd -Path D:\Hyper-V\Festplatte_diff.vhdx -ParentPath D:\Hyper-V\Festplatte.vhdx
# und schließlich die virtuelle Festplatte zur Verfügung stellen:
Mount-vhd -Path D:\Hyper-V\Festplatte_diff.vhdx 

# Alle virtuelle Maschinen stoppen
get-vm | stop-VM

$VhdPath = "E:\Hyper-V\demo\Virtual Hard Disks\system.vhdx"
New-VM -Name Demo -MemoryStartupBytes 2GB -NewVHDPath $VhdPath -NewVHDSizeBytes 60GB -SwitchName NAT -Path E:\Hyper-V\demo | 
    Set-VM -AutomaticCheckpointsEnabled $false
New-VMSwitch -SwitchName Private -SwitchType Private
Get-VM | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName Nat

# Alle Netzwerkprofile auf "private Netzwerk" umstellen
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# ---------------------------------
# Arbeiten mit dem Active Directory
# ---------------------------------
# Abrufen aller User im AD
Get-ADUser -filter *

# ADUser bearbeiten - s. Beispiel oben
Get-ADUser -Filter * | Set-ADUser -City 'Hannover'

# Den Ort aller Benutzer auf "Hannover" setzen - verwendet die Pipeline
# mehr zur Pipeline später
Get-ADUser -filter * | Set-ADUser -city 'Hannover'
# Alle gesperrten Benutzerkonten anzeigen
Search-ADAccount -LockedOut 
Search-ADAccount -LockedOut | Out-GridView
Search-ADAccount -LockedOut | Out-GridView -PassThru | Unlock-ADAccount




