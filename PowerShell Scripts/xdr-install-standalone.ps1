$ProgressPreference = 'SilentlyContinue'
        $distributionIDs = @{
            'Windows 10+ & Server 2012+' = 'd6dfa4a7ef5247c99b08d0c044266392'
            'Windows 7, 8, and Server 2008R2 [CE]' = 'a72ddaba42c8417ba177fddd6ff8b991'
        }
        $portalFQDN = ''
        $apiID = '6'
        $apiKey = ''

        # .NET Dependencies
        $ndps = @{
            '6.1.7601.0' = '\\isilon-data.bhcs.pvt\Svrteam\Software\xdrfiles\NDP451-KB2858728-x86-x64-AllOS-ENU.exe' # 7 SP1
            '6.2.9200.0' = '\\isilon-data.bhcs.pvt\Svrteam\Software\xdrfiles\NDP451-KB2858728-x86-x64-AllOS-ENU.exe' # 8 & 12
            '6.3.9600.0' = '\\isilon-data.bhcs.pvt\Svrteam\Software\xdrfiles\NDP451-KB2858728-x86-x64-AllOS-ENU.exe' # 8.1 & 12 R2
        }

        # Azure Code Signing dependencies
        $msuss = @{
            '6.2.9200.0' = @( # 8 & 12
                '\\isilon-data.bhcs.pvt\Svrteam\Software\xdrfiles\windows8-rt-kb5006732-x64_2114b7510d1c2bf61e92f18c03516d55c34ade48.msu' # Windows Server 2012
            )
            '6.3.9600.0' = @( # 8.1 & 12 R2
                '\\isilon-data.bhcs.pvt\Svrteam\Software\xdrfiles\windows8.1-kb5006729-x64_5f228dd572d5607d8c0e41d695fcf2e4404e56fb.msu' # Windows Server 2012 R2
            )
        }

        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

        # Download and Install Dependencies
        if ($ndp = $ndps.([System.Environment]::OSVersion.Version -as [string])) {
            $ndpFile = [IO.Path]::Combine($env:Temp, $ndp.Segments[-1])

            Copy-Item -Force $ndp -Destination $ndpFile
            #Invoke-WebRequest $ndp.AbsoluteUri -Outfile $ndpFile


            $process = @{
                FilePath = $ndpFile
                ArgumentList = '/quiet /AcceptEULA /norestart'
                Wait = $true
            }
            Start-Process @process
        }

        if ($msus = $msuss.([System.Environment]::OSVersion.Version -as [string])) {
            foreach ($msu in $msus) {
                $msuFile = [IO.Path]::Combine($env:Temp, $msu.Segments[-1])

                Copy-Item -Force $msu -Destination $msuFile
                ##Invoke-WebRequest $msu.AbsoluteUri -Outfile $msuFile

                $process = @{
                    FilePath = 'wusa.exe'
                    ArgumentList = '"{0}" /quiet /norestart' -f $msuFile
                    Wait = $true
                }
                Start-Process @process
            }
        }

        # Set MSI URL
        $packageType = if ([System.Environment]::Is64BitOperatingSystem) {
            'x64'
        } else {
            'x86'
        }

        switch (([System.Environment]::OSVersion.Version -as [string])) {
            {$_ -in '6.1.7601.0', '6.2.9200.0', '6.3.9600.0'} {
                # 7 SP1
                # 8 & 12
                # 8.1 & 12 R2
                if ($PSVersionTable.OS -like 'Microsoft Windows Server 2012*') {
                    $distributionID = $distributionIDs.'Windows 10+ & Server 2012+'
                } else {
                    $distributionID = $distributionIDs.'Windows 7, 8, and Server 2008R2 [CE]'
                }
            }
            Default {
                # Win 10 +
                # Win Server 2016 +
                $distributionID = $distributionIDs.'Windows 10+ & Server 2012+'
            }
        }

        # Get XDR MSI URL
        $headers = @{
            'Content-Type' = 'application/json'
            'x-xdr-auth-id' = $apiID
            'Authorization' = $apiKey
        }
        $get_dist_url = @{
            Uri = 'https://api-{0}/public_api/v1/distributions/get_dist_url' -f $portalFQDN
            Method = 'POST'
            Headers = $headers
            Body = @{
                request_data = @{
                    distribution_id = $distributionID
                    package_type = $packageType
                }
            } | ConvertTo-Json
        }
        $result = Invoke-RestMethod @get_dist_url

        # Download XDR MSI
        $webRequest = @{
            Uri = $result.reply.distribution_url
            OutFile = "${env:Temp}\XDR.msi"
            Method = 'POST'
            Headers = $headers
        }

        $xdrOutFile = "${env:Temp}\XDR.msi"

        #Copy-Item '\\isilon-data.bhcs.pvt\Svrteam\Software\xdrfiles\XDR.msi' -Destination $xdrOutFile
        Invoke-WebRequest @webRequest

        #create Temp folder

        $folderpath = "C:\XDR"

        if(!(Test-Path $folderpath -PathType Container)){
            
            New-Item -ItemType Directory -Force -Path $folderpath

        }

        Copy-Item "$env:Temp\XDR.msi" -Destination "$folderpath\XDR.msi"

        # Install
        $process = @{
            FilePath = 'msiexec.exe'
            ArgumentList = ('/qn /i "C:\XDR\XDR.msi" ENDPOINT_TAGS="POV,viaAnsible" /norestart /log "C:\XDR\XDR.msi.log"')
            Wait = $true
        }
        Start-Process @process

        # Check if XDR is installed
        $CortexInstalled = ""
        if (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Cortex XDR*" }) {
            $CortexInstalled = "YES"
        }
        else {
            $CortexInstalled = "INSTALLATION FAILED"
        }
        Write-Host $CortexInstalled