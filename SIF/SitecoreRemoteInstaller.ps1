param(
    [string]$version = '10.2',
    [string]$prefix = 'scx102_SIF',
    [string]$path = 'C:\inetpub\wwwroot\',
    [string]$bit = '64',
    [string]$solrPort = '9101',
    [string]$solrHost = 'localhost',
    [string]$solrPath = '',
    [bool]$skipServices = $false,
    [bool]$install = $false,
    [bool]$uninstall = $false
)

Set-ExecutionPolicy Bypass -Scope Process

# Install Version
$scxVersion = $version

# General Settings
$scxPrefix = $prefix
$scxAdminPassword = "b"
$scXSitePhysicalRoot = $path

# SQL Server Settings
$scXSqlServer = ""
$scXSqlAdminUser = ""
$scXSqlAdminPassword = ""

# Add Solr Settings
$scxSolrPort = $solrPort
$scxSolrHost = $solrHost
$scXSolrRoot = ""

#Configure bit for environment
$scxDepBit = $bit

#registry path definitions 
$WebDeployRegistryPath = "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3"
$DacFxDependenciesKey = "DacFxDependenciesPath"
$DacFxKey = "DacFxPath"
$DacFxDependenciesPath = "C:\Program Files (x86)\Microsoft SQL Server\130\SDK\Assemblies\"
$DacFxPath = "C:\Program Files\Microsoft SQL Server\140\DAC\bin\"

#Path management, do not change
$scxDepPsModulePath = (Join-Path $PSScriptRoot Sources\PS\Modules)
$scxDepResourcePath = (Join-Path $PSScriptRoot Sources\Sitecore\Installer\$scxVersion\)
$scxSIFBasePath = (Join-Path $PSScriptRoot Sources\Sitecore\SitecoreInstallFramework)
$scxFundamentalsPath = (Join-Path $PSScriptRoot Sources\Sitecore\SitecoreFundamentals)
$scxDepExe = (Join-Path $PSScriptRoot Sources\Server\exe\)
$scxDepEXEBit = (Join-Path $PSScriptRoot Sources\Server\exe\x$scxDepBit\)
$scxDepMSI = (Join-Path $PSScriptRoot Sources\Server\msi\)
$scxDepMSIBit = (Join-Path $PSScriptRoot Sources\Server\msi\x$scxDepBit\)
$scxDepDotNetHostingVersion = '';
$scxDepWebDeploy = '';

# Organize version specifics

switch ($scxDepBit) {
    '64' {
        
        $scxDepWebDeploy = "WebDeploy_amd64_en-US.msi"
    }
    '86' {
       
        $scxDepWebDeploy = "WebDeploy_x86_en-US"    
    }
}

# Get Version Specific Installers

switch ($scxVersion) {
    '10.1' {
        $scxDepDotNetHostingVersion = 'dotnet-hosting-2.1.23-win.exe'
        $scXSolrRoot = (Join-Path $PSScriptRoot Solr-8.4.0\)
    }
    '10.2' {
        $scxDepDotNetHostingVersion = 'dotnet-hosting-3.1.16-win.exe'
        $scXSolrRoot = (Join-Path $PSScriptRoot Solr-8.8.2\)    
    }
}

if($solrPath -ne "")  {
    $scXSolrRoot = $solrPath
   }


# Build configuration object
$scxInstallParams = @{
    SitecoreInstallationVersion = $scxVersion
    SitecoreIntallationRoot     = $scxDepResourcePath
    SitecorePrefix              = $scxPrefix
    SitecoreAdminPassword       = $scxAdminPassword
    SitecorePhysicalRoot        = $scXSitePhysicalRoot
    SitecoreLicensePath         = (Join-Path $scxDepResourcePath License)
    SQLServer                   = $scXSqlServer
    SQLUser                     = $scXSqlAdminUser
    SQLPassword                 = $scXSqlAdminPassword
    SolrPort                    = $scxSolrPort
    SolrHost                    = $scxSolrHost
    SolrVersion                 = $scxSolrVersion
    SolrRoot                    = $scXSolrRoot
}

. (Join-Path $PSScriptRoot SitecoreWebDepInstaller.ps1)

if ($uninstall) { 
    ManageServerFeatures -action uninstall -skip $false
    ManagePsModule -copyFrom "$scxDepPsModulePath/PackageManagement" -copyTo "c:\Program Files\PackageManagement"  -action Delete
    ManagePsModule -copyFrom "$scxDepPsModulePath/SqlServer" -copyTo "C:\Program Files\WindowsPowerShell\Modules" -action Delete  
    ManageRegistry -registryPath $WebDeployRegistryPath -registryKey $DacFxDependenciesKey -registryValue $DacFxDependenciesPath -action Delete
    ManageRegistry -registryPath $WebDeployRegistryPath -registryKey $DacFxKey -registryValue $DacFxPath -action Delete
}


if ($install) {
    
    # . (Join-Path $PSScriptRoot SitecoreSolrCert.ps1)

    Write-host `n`n
    ManageConsoleOutput -message "Installing Sitecore using $bit bit dependencies."   

    ## Include Sitecore Installation Framework
    Write-host `n
    ManageConsoleOutput -message "Importing SIF at: $scxSIFBasePath."   
    Import-Module $scxSIFBasePath
    Write-host `n
    Get-Module  $scxSIFBasePath –ListAvailable

    ## Include Sitecore Fundamentals
    Write-host `n
    ManageConsoleOutput -message "Importing Sitecore Fundamentals at: $scxFundamentalsPath."  
    Import-Module $scxFundamentalsPath
    Write-host `n
    Get-Module  $scxFundamentalsPath –ListAvailable

    ## Ensure Deploy Package Management
    Write-host `n
    ManagePsModule -copyFrom "$scxDepPsModulePath/PackageManagement" -copyTo "c:\Program Files\PackageManagement" -action Copy
    Import-Module PackageManagement
    Write-host `n
    Get-Module PackageManagement –ListAvailable

    ## Ensure Deploy SqlServer
    Write-host `n
    ManagePsModule -copyFrom "$scxDepPsModulePath/SqlServer" -copyTo "C:\Program Files\WindowsPowerShell\Modules" -action Copy 
    Import-Module SqlServer
    Write-host `n 
    Get-Module SqlServer –ListAvailable      

    #IIS and Asp Hosting
    InstallScXDep -STORAGE $scxDepMSI -FILE iisexpress_amd64_en-US.msi
    InstallScXDep -STORAGE $scxDepEXE -FILE $scxDepDotNetHostingVersion 

    #Web Deployers
    InstallScXDep -STORAGE $scxDepMSI -FILE $scxDepWebDeploy
    InstallScXDep -STORAGE $scxDepMSI -FILE WebPlatformInstaller_x64_en-US.msi

    # SMO Objects - Microsoft® SQL Server® 2016 Service Pack 2 Feature Pack
    # https://www.microsoft.com/en-us/download/confirmation.aspx?id=56833
    InstallScXDep -STORAGE $scxDepMSIBit -FILE SqlDom.msi
    InstallScXDep -STORAGE $scxDepMSIBit -FILE SQLSysClrTypes.msi
    InstallScXDep -STORAGE $scxDepMSIBit -FILE SharedManagementObjects.msi  
    InstallScXDep -STORAGE $scxDepMSIBit -FILE PowerShellTools.msi

    #https://www.microsoft.com/en-us/download/details.aspx?id=56508
    InstallScXDep -STORAGE $scxDepMSIBit -FILE DacFramework.msi

    # Redistributable    
    InstallScXDep -STORAGE $scxDepEXEBit -FILE vc_redist.x$scxDepBit.exe
    InstallScXDep -STORAGE $scxDepEXE -FILE ndp48-x86-x64-allos-enu.exe

    Write-host `n

    if((Test-Path $WebDeployRegistryPath -PathType Container) -eq $true) {

        ManageRegistry -registryPath $WebDeployRegistryPath -registryKey $DacFxDependenciesKey -registryValue $DacFxDependenciesPath
        ManageRegistry -registryPath $WebDeployRegistryPath -registryKey $DacFxKey -registryValue $DacFxPath

    } else {

        ManageConsoleOutput -message "An error occured. WebDeploy regisry does not exist: $WebDeployRegistryPath."
        ManageConsoleOutput -message "Closing Installer." 
        Exit(1) 
    }

    # Install server features
    ManageServerFeatures -action "install" -skip $skipServices

    #Install Sitecore
    InstallXPISitecore -PARAMS $scxInstallParams
}