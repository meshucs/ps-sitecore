function InstallSitecore(
    [PsObject]$PARAMS
) {

    $InstancePrefix = $PARAMS.SitecorePrefix + "_xp"

    $GlobalInstallParams = @{         
        InstallPrefix                       = $InstancePrefix    
        InstallVersion                      = $PARAMS.SitecoreInstallationVersion
        InstallVersionRoot                  = $PARAMS.SitecoreIntallationRoot            
        SitecoreAdminPassword               = $PARAMS.SitecoreAdminPassword
        LicenseFile                         = $PARAMS.SitecoreLicensePath  
        SolrUrl                             = "https://" + $PARAMS.SolrHost + ":" + $PARAMS.SolrPort + "/solr"   
        SolrRoot                            = $PARAMS.SolrRoot
        SolrService                         = $PARAMS.SolrVersion  
        SqlDbPrefix                         = $PARAMS.SitecorePrefix 
        SqlServer                           = $PARAMS.SQLServer
        SqlAdminUser                        = $PARAMS.SQLAdminUser
        SqlAdminPassword                    = $PARAMS.SQLPassword 
        DeployToElasticPoolName             = $PARAMS.ElasticPool     
        ClientSecret                        = $PARAMS.SitecoreClientSecret
        SkipDatabaseInstallation            = $PARAMS.SkipDatabaseInstallation 
        SitePhysicalRoot                    = $PARAMS.SitecorePhysicalRoot  
        SitecoreCertificateName             = $InstancePrefix
        SitecoreRootCertificateName         = $InstancePrefix + "_ROOT"
        SitecoreXConnectCertificateName     = $InstancePrefix + ".collection"
        SitecoreXconnectRootCertificateName = $InstancePrefix + ".collection_ROOT"      
        SitecoreIdsCertificateName          = $InstancePrefix + ".ids"
        SitecoreIdsRootCertificateName      = $InstancePrefix + ".ids_ROOT"
        SitecoreCM                          = "$InstancePrefix.cm"
        SitecoreCD                          = "$InstancePrefix.cd"
        SitecoreProcessing                  = "$InstancePrefix.prc"
        SitecoreConnectRef                  = "$InstancePrefix.refData" 
        SitecoreConnectCollection           = "$InstancePrefix.collection" 
        SitecoreConnectCollectionSearch     = "$InstancePrefix.search" 
        SitecoreMarketingReporting          = "$InstancePrefix.marketingReporting"
        SitecoreMarketingAutomation         = "$InstancePrefix.marketingAutomation"
        SitecoreCortexProcessingEngine      = "$InstancePrefix.cortexProcessingEngine"
        SitecoreCortexReportingEngine       = "$InstancePrefix.cortextReportingEngine"
        SitecoreIdentityServer              = "$InstancePrefix.ids"
    }
   
    # Move to install root location here target packages are stored.     
    Push-Location $SCInstallRoot

    # Install Marketing Engine
    InstallMarketingEngine -PARAMS $GlobalInstallParams

    # Install Identity Server
    InstallIdentityServer -PARAMS $GlobalInstallParams

    #Install Sitecore XP
    InstallXP -PARAMS $GlobalInstallParams

}

function InstallXP(
    [PsObject]$PARAMS
) {

    $XpSolrSitecoreParams = @{
        Path        = (Join-Path $PARAMS.InstallVersionRoot sitecore-solr.json)
        SolrUrl     = $PARAMS.SolrUrl
        SolrRoot    = $PARAMS.SolrRoot
        SolrService = $PARAMS.SolrService
        BaseConfig  = "_default_102"
        CorePrefix  = $PARAMS.InstallPrefix
    }

    $XpCertParams = @{
        Path             = (Join-Path $PARAMS.InstallVersionRoot createcert.json)
        CertificateName  = $PARAMS.SitecoreCertificateName
        RootCertFileName = $PARAMS.SitecoreRootCertificateName
    }

    $XpContentManagementParams = @{
        Path                                 = (Join-Path $PARAMS.InstallVersionRoot sitecore-XP1-cm.json)  
        Package                              = (Join-Path $PARAMS.InstallVersionRoot  "Sitecore * rev. * (OnPrem)_cm.scwdp.zip")  
        LicenseFile                          = $PARAMS.LicenseFile     
        SqlDbPrefix                          = $PARAMS.SqlDbPrefix
        SSLCert                              = $PARAMS.SitecoreCertificateName
        XConnectCert                         = $PARAMS.SitecoreXConnectCertificateName
        SiteName                             = $PARAMS.SitecoreCM
        SitePhysicalRoot                     = $PARAMS.SitePhysicalRoot        
        SitecoreAdminPassword                = $PARAMS.SitecoreAdminPassword
        SqlAdminUser                         = $PARAMS.SqlAdminUser
        SqlAdminPassword                     = $PARAMS.SqlAdminPassword
        SqlServer                            = $PARAMS.SQLServer     
        SolrCorePrefix                       = $PARAMS.InstallPrefix 
        SolrUrl                              = $PARAMS.SolrUrl
        ProcessingService                    = "https://" + $PARAMS.SitecoreProcessing
        XConnectCollectionService            = "https://" + $PARAMS.SitecoreConnectCollection
        XConnectCollectionSearchService      = "https://" + $PARAMS.SitecoreConnectCollectionSearch
        XConnectReferenceDataService         = "https://" + $PARAMS.SitecoreConnectRef
        MarketingAutomationOperationsService = "https://" + $PARAMS.SitecoreMarketingAutomation
        MarketingAutomationReportingService  = "https://" + $PARAMS.SitecoreMarketingReporting
        CortexReportingService               = "https://" + $PARAMS.SitecoreCortexReportingEngine
        CortexProcessingService              = "https://" + $PARAMS.SitecoreCortexProcessingEngine
        SitecoreIdentityAuthority            = "https://" + $PARAMS.SitecoreIdentityServer
        SkipDatabaseInstallation             = $PARAMS.SkipDatabaseInstallation      
        DeferSolrUpdate                      = $true
    }

    $XpContentDeliveryParams = @{
        Path                                 = (Join-Path $PARAMS.InstallVersionRoot sitecore-XP1-cd.json)  
        Package                              = (Join-Path $PARAMS.InstallVersionRoot  "Sitecore * rev. * (OnPrem)_cd.scwdp.zip")  
        LicenseFile                          = $PARAMS.LicenseFile     
        SqlDbPrefix                          = $PARAMS.SqlDbPrefix
        SSLCert                              = $PARAMS.SitecoreCertificateName
        XConnectCert                         = $PARAMS.SitecoreXConnectCertificateName
        SiteName                             = $PARAMS.SitecoreCD
        SitePhysicalRoot                     = $PARAMS.SitePhysicalRoot
        SqlServer                            = $PARAMS.SQLServer
        SolrCorePrefix                       = $PARAMS.InstallPrefix
        XConnectCollectionService            = "https://" + $PARAMS.SitecoreConnectCollection
        XConnectReferenceDataService         = "https://" + $PARAMS.SitecoreConnectRef
        MarketingAutomationOperationsService = "https://" + $PARAMS.SitecoreMarketingAutomation
        MarketingAutomationReportingService  = "https://" + $PARAMS.SitecoreMarketingReporting
        SitecoreIdentityAuthority            = "https://" + $PARAMS.SitecoreIdentityServer
    }
       

    $XpProcessingParams = @{
        Path                      = (Join-Path $PARAMS.InstallVersionRoot sitecore-XP1-prc.json)  
        Package                   = (Join-Path $PARAMS.InstallVersionRoot  "Sitecore * rev. * (OnPrem)_prc.scwdp.zip")  
        LicenseFile               = $PARAMS.LicenseFile     
        SqlDbPrefix               = $PARAMS.SqlDbPrefix
        SSLCert                   = $PARAMS.SitecoreCertificateName
        XConnectCert              = $PARAMS.SitecoreXConnectCertificateName
        SiteName                  = $PARAMS.SitecoreProcessing
        SitePhysicalRoot          = $PARAMS.SitePhysicalRoot
        SqlAdminUser              = $PARAMS.SqlAdminUser
        SqlAdminPassword          = $PARAMS.SqlAdminPassword 
        SqlServer                 = $PARAMS.SQLServer      
        XConnectCollectionService = "https://" + $PARAMS.SitecoreConnectCollection       
        SkipDatabaseInstallation  = $PARAMS.SkipDatabaseInstallation
       
    }

    # Deploy Solr Sitecore Schema     
    Install-SitecoreConfiguration @XpSolrSitecoreParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Sitecore Certificates
    Install-SitecoreConfiguration @XpCertParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy XP CM
    Install-SitecoreConfiguration @XpContentManagementParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy XP CD
    Install-SitecoreConfiguration @XpContentDeliveryParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log   

    # Deploy XP Processing
    Install-SitecoreConfiguration @XpProcessingParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

}

function InstallIdentityServer(
    [PsObject]$PARAMS
) {

    $IdsCertParams = @{
        Path             = (Join-Path $PARAMS.InstallVersionRoot createcert.json)
        CertificateName  = $PARAMS.SitecoreIdsCertificateName
        RootCertFileName = $PARAMS.SitecoreIdsRootCertificateName
    }

    $IdsParams = @{
        Path                 = (Join-Path $PARAMS.InstallVersionRoot IdentityServer.json)   
        Package              = (Join-Path $PARAMS.InstallVersionRoot  "Sitecore.IdentityServer * rev. * (OnPrem)_identityserver.scwdp.zip")    
        SitecoreIdentityCert = $PARAMS.SitecoreIdsCertificateName
        LicenseFile          = $PARAMS.LicenseFile
        SiteName             = $PARAMS.SitecoreIdentityServer
        SitePhysicalRoot     = $PARAMS.SitePhysicalRoot      
        SqlDbPrefix          = $PARAMS.SqlDbPrefix
        SqlServer            = $PARAMS.SQLServer
        PasswordRecoveryUrl  = "https://" + $PARAMS.SitecoreCM
        AllowedCorsOrigins   = "https://" + $PARAMS.SitecoreCM
        ClientSecret         = $PARAMS.ClientSecret
    }

    # Deploy Identity Server Certificate
    Install-SitecoreConfiguration @IdsCertParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Identity Server 
    Install-SitecoreConfiguration @IdsParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

}



function InstallMarketingEngine(
    [PsObject]$PARAMS
) {

    $MaEngineCertParams = @{
        Path             = (Join-Path $PARAMS.InstallVersionRoot createcert.json)
        CertificateName  = $PARAMS.SitecoreXConnectCertificateName
        RootCertFileName = $PARAMS.SitecoreIdsRootCertificateName
    }   

    $MaEngineSolrParams = @{
        Path        = (Join-Path $PARAMS.InstallVersionRoot xconnect-solr.json)
        SolrUrl     = $PARAMS.SolrUrl
        SolrRoot    = $PARAMS.SolrRoot
        SolrService = $PARAMS.SolrService
        BaseConfig  = "_default_101"
        CorePrefix  = $PARAMS.InstallPrefix
    }

    $MaXconnectParams = @{
        Path                     = (Join-Path $PARAMS.InstallVersionRoot xconnect-xp1-collection.json)  
        Package                  = (Join-Path $PARAMS.InstallVersionRoot "Sitecore * rev. * (OnPrem)_xp1collection.scwdp.zip")    
        LicenseFile              = $PARAMS.LicenseFile    
        SiteName                 = $PARAMS.SitecoreConnectCollection
        SitePhysicalRoot         = $PARAMS.SitePhysicalRoot
        SSLCert                  = $PARAMS.SitecoreXConnectCertificateName
        XConnectCert             = $PARAMS.SitecoreXConnectCertificateName
        SqlDbPrefix              = $PARAMS.SqlDbPrefix
        SqlServer                = $PARAMS.SQLServer
        SqlAdminUser             = $PARAMS.SqlAdminUser
        SqlAdminPassword         = $PARAMS.SqlAdminPassword
        SkipDatabaseInstallation = $PARAMS.SkipDatabaseInstallation        

    }

    $MaXconnectSearchParams = @{
        Path             = (Join-Path $PARAMS.InstallVersionRoot xconnect-xp1-collectionsearch.json)  
        Package          = (Join-Path $PARAMS.InstallVersionRoot "Sitecore * rev. * (OnPrem)_xp1collectionsearch.scwdp.zip")    
        LicenseFile      = $PARAMS.LicenseFile    
        SiteName         = $PARAMS.SitecoreConnectCollectionSearch
        SitePhysicalRoot = $PARAMS.SitePhysicalRoot
        SSLCert          = $PARAMS.SitecoreXConnectCertificateName
        XConnectCert     = $PARAMS.SitecoreXConnectCertificateName
        SqlDbPrefix      = $PARAMS.SqlDbPrefix
        SqlServer        = $PARAMS.SQLServer
        SolrUrl          = $PARAMS.SolrUrl 
        SolrCorePrefix   = $PARAMS.InstallPrefix
        DeferStart       = $true
    }

    $MaXconnectCortexReportingParams = @{
        Path                     = (Join-Path $PARAMS.InstallVersionRoot xconnect-xp1-CortexReporting.json)  
        Package                  = (Join-Path $PARAMS.InstallVersionRoot "Sitecore * rev. * (OnPrem)_xp1cortexreporting.scwdp.zip")   
        LicenseFile              = $PARAMS.LicenseFile    
        SiteName                 = $PARAMS.SitecoreCortexReportingEngine
        SitePhysicalRoot         = $PARAMS.SitePhysicalRoot
        SSLCert                  = $PARAMS.SitecoreXConnectCertificateName
        XConnectCert             = $PARAMS.SitecoreXConnectCertificateName
        SqlDbPrefix              = $PARAMS.SqlDbPrefix
        SqlServer                = $PARAMS.SQLServer
        SqlAdminUser             = $PARAMS.SqlAdminUser
        SqlAdminPassword         = $PARAMS.SqlAdminPassword
        SkipDatabaseInstallation = $PARAMS.SkipDatabaseInstallation       
    }

    $MaXconnectCortexProcessingParams = @{
        Path                      = (Join-Path $PARAMS.InstallVersionRoot xconnect-xp1-CortexProcessing.json)  
        Package                   = (Join-Path $PARAMS.InstallVersionRoot "Sitecore * rev. * (OnPrem)_xp1cortexprocessing.scwdp.zip")   
        LicenseFile               = $PARAMS.LicenseFile    
        SiteName                  = $PARAMS.SitecoreCortexProcessingEngine
        SitePhysicalRoot          = $PARAMS.SitePhysicalRoot
        SSLCert                   = $PARAMS.SitecoreXConnectCertificateName
        XConnectCert              = $PARAMS.SitecoreXConnectCertificateName
        SqlDbPrefix               = $PARAMS.SqlDbPrefix
        SqlServer                 = $PARAMS.SQLServer
        SqlAdminUser              = $PARAMS.SqlAdminUser
        SqlAdminPassword          = $PARAMS.SqlAdminPassword 
        XConnectCollectionService = "https://" + $PARAMS.SitecoreConnectCollection
        XConnectSearchService     = "https://" + $PARAMS.SitecoreConnectCollectionSearch 
        SkipDatabaseInstallation  = $PARAMS.SkipDatabaseInstallation  
        DeferStart                = $true
    }
    
    $MaXconnectMarketingAutomationParams = @{
        Path                            = (Join-Path $PARAMS.InstallVersionRoot xconnect-xp1-MarketingAutomation.json)  
        Package                         = (Join-Path $PARAMS.InstallVersionRoot "Sitecore * rev. * (OnPrem)_xp1marketingautomation.scwdp.zip")   
        LicenseFile                     = $PARAMS.LicenseFile    
        SiteName                        = $PARAMS.SitecoreMarketingAutomation
        SitePhysicalRoot                = $PARAMS.SitePhysicalRoot
        SSLCert                         = $PARAMS.SitecoreXConnectCertificateName
        XConnectCert                    = $PARAMS.SitecoreXConnectCertificateName
        SqlDbPrefix                     = $PARAMS.SqlDbPrefix
        SqlServer                       = $PARAMS.SQLServer
        SqlAdminUser                    = $PARAMS.SqlAdminUser
        SqlAdminPassword                = $PARAMS.SqlAdminPassword
        XConnectReferenceDataService    = "https://" + $PARAMS.SitecoreConnectRef  
        XConnectCollectionService       = "https://" + $PARAMS.SitecoreConnectCollection
        XConnectCollectionSearchService = "https://" + $PARAMS.SitecoreConnectCollectionSearch     
        DeferStart                      = $true 
    }     

    $MaXconnectMarketingAutomationReportingParams = @{
        Path                     = (Join-Path $PARAMS.InstallVersionRoot xconnect-xp1-MarketingAutomationReporting.json)  
        Package                  = (Join-Path $PARAMS.InstallVersionRoot "Sitecore * rev. * (OnPrem)_xp1marketingautomationreporting.scwdp.zip")   
        LicenseFile              = $PARAMS.LicenseFile    
        SiteName                 = $PARAMS.SitecoreMarketingReporting
        SitePhysicalRoot         = $PARAMS.SitePhysicalRoot
        SSLCert                  = $PARAMS.SitecoreXConnectCertificateName
        XConnectCert             = $PARAMS.SitecoreXConnectCertificateName
        SqlDbPrefix              = $PARAMS.SqlDbPrefix
        SqlServer                = $PARAMS.SQLServer
    }

  
    $MaXconnectRefDataParams = @{
        Path                     = (Join-Path $PARAMS.InstallVersionRoot xconnect-xp1-ReferenceData.json)  
        Package                  = (Join-Path $PARAMS.InstallVersionRoot "Sitecore * rev. * (OnPrem)_xp1referencedata.scwdp.zip")   
        LicenseFile              = $PARAMS.LicenseFile    
        SiteName                 = $PARAMS.SitecoreConnectRef
        SitePhysicalRoot         = $PARAMS.SitePhysicalRoot
        SSLCert                  = $PARAMS.SitecoreXConnectCertificateName
        XConnectCert             = $PARAMS.SitecoreXConnectCertificateName
        SqlDbPrefix              = $PARAMS.SqlDbPrefix
        SqlServer                = $PARAMS.SQLServer
        SqlAdminUser             = $PARAMS.SqlAdminUser
        SqlAdminPassword         = $PARAMS.SqlAdminPassword
        SkipDatabaseInstallation = $PARAMS.SkipDatabaseInstallation      
    }

    
    # Deploy Marketing Engine/XConnect Certificate    
    Install-SitecoreConfiguration @MaEngineCertParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Marketing Engine/Solr Collection
    Install-SitecoreConfiguration @MaEngineSolrParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Marketing Engine/Xconnect
    Install-SitecoreConfiguration @MaXconnectParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Marketing Engine/Xconnect Search
    Install-SitecoreConfiguration @MaXconnectSearchParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Marketing Engine/Cortex Reporting
    Install-SitecoreConfiguration @MaXconnectCortexReportingParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Marketing Engine/Cortex Processing
    Install-SitecoreConfiguration @MaXconnectCortexProcessingParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Marketing Engine Automation
    Install-SitecoreConfiguration @MaXconnectMarketingAutomationParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Marketing Engine Reporting
    Install-SitecoreConfiguration @MaXconnectMarketingAutomationReportingParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log

    # Deploy Marketing Engine Reference Data
    Install-SitecoreConfiguration @MaXconnectRefDataParams *>&1 -verbose | Tee-Object XP1-SingleDeveloper.log


}



function ManageConsoleOutput([string]$message, [boolean]$log = $false) {
    write-host "   ###    $message    ###   " -BackgroundColor DarkBlue -ForegroundColor White

}


function ManageRegistry([string]$registryPath, [string]$registryKey, [string]$registryValue, [string]$action = 'install') {

    $registryFqn = "$registryPath\$registryKey"

    if ($action.ToLower() -eq 'install') {

        $_registry = (Get-ItemProperty $registryPath).PSObject.Properties.Name -Contains $registryKey


        if (($_registry -eq $null) -or ($_registry.Length -eq 0)) {
            ManageConsoleOutput -message "Deploying registry: $registryFqn."
            New-ItemProperty $registryPath -Name $registryKey -Value $registryValue
        }
        else {
            ManageConsoleOutput -message "Registry already deployed: $registryFqn."
        }
    
        Get-ItemProperty -Path $registryPath -Name $registryKey
    }

    if ($action.ToLower() -eq 'delete') { 
        Remove-ItemProperty $registryPath -Name $registryKey
    
    }

}

function ManagePsModule([string]$copyFrom, [string]$copyTo, [string]$mode = "copy") {

    if ($mode.ToLower() -eq 'copy') {

        $desitnation = Test-Path $copyTo -isValid
        if ($desitnation -eq $false) {
            ManageConsoleOutput -message "Deploying $copyFrom to $copyTo."
            Get-ChildItem $copyFrom -Recurse | Unblock-File
            Copy-Item (Join-Path $copyFrom "*") $CopyTo -Exclude (Get-ChildItem $copyTo) -Force 
        }
        else { 
            Write-host `n
            ManageConsoleOutput -message "The module has already been deployed: $copyTo."
        }
    }


    if ($mode.ToLower() -eq 'delete') {


    }

}

function InstallScXDep([string]$file, [string]$storage = "C:\scx10\Sources\Server\", [string]$mode = "LOCAL") {

    $DataStamp = get-date -Format yyyyMMddTHHmmss       
    $logFile = 'C:\scx10\logs\{0}-{1}-{2}.log' -f 'scx10x-installer', $FILE, $DataStamp

    # Build filename and check if it exists 

    $FILENAME = $STORAGE + $FILE

    $FILESEARCH = Test-Path -Path $FILENAME -PathType Leaf    

    if ($FILESEARCH) {

        $FILE = Get-Item -Path $FILENAME

        Write-Output -InputObject $FILE

        $MSIArguments = @(
            "/i"
        ('"{0}"' -f $FILE)
            "/qn"
            "/norestart"
            "/L*v"
            $logFile
        ) 
        # Switch for remote or local installation command

        switch ($MODE) {
            'LOCAL' {
                Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow                     
            }
            'REMOTE' {

                # may need to derive and pass the computer name when it is remote

                Invoke-Command -ComputerName DISA-scx10-poc -ScriptBlock {
                    Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
                }                    
            }
        }  

    } 

    ELSE {

        Write-Host "Error: could not find " -NoNewline
        Write-Output -InputObject $FILE
    }
}


function ManageServerFeatures([string]$action = "", [bool]$skip = $false) {

    if (!$skip) {
        switch ($action) {
            'install' {
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServerRole
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServer
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-CommonHttpFeatures
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpErrors
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpRedirect
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ApplicationDevelopment
                Enable-WindowsOptionalFeature -online -NoRestart -FeatureName NetFx4Extended-ASPNET45
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-NetFxExtensibility45
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HealthAndDiagnostics
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpLogging
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-LoggingLibraries
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-RequestMonitor
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpTracing
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Security
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-RequestFiltering
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Performance
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServerManagementTools
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-IIS6ManagementCompatibility
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Metabase
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ManagementConsole
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-BasicAuthentication
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WindowsAuthentication
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-StaticContent
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-DefaultDocument
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebSockets
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ApplicationInit
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ISAPIExtensions
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ISAPIFilter
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpCompressionStatic
                Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ASPNET45
            } 
            'uninstall' {
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServerRole
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServer
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-CommonHttpFeatures
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpErrors
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpRedirect
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ApplicationDevelopment
                Disable-WindowsOptionalFeature -online -NoRestart -FeatureName NetFx4Extended-ASPNET45
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-NetFxExtensibility45
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HealthAndDiagnostics
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpLogging
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-LoggingLibraries
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-RequestMonitor
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpTracing
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Security
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-RequestFiltering
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Performance
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServerManagementTools
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-IIS6ManagementCompatibility
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Metabase
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ManagementConsole
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-BasicAuthentication
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WindowsAuthentication
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-StaticContent
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-DefaultDocument
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebSockets
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ApplicationInit
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ISAPIExtensions
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ISAPIFilter
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpCompressionStatic
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ASPNET45
            }
        } 
    }
}
