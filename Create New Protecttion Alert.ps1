
New-ProtectionAlert -Name "MalwareDetected" -Category ThreatManagement -NotifyUser "aman@dellsp.onmicrosoft.com","admin@dellsp.onmicrosoft.com" -ThreatType Activity -Operation FileMalwareDetected -Description "Custom alert policy Notifies admins when malicious files are detected in SharePoint Online, OneDrive" -AggregationType None
