
$PackageMediaRoot = Get-Item "master:/media library"
$MediaItems = $PackageMediaRoot.Axes.GetDescendants() | Where-Object {[int]$_.Fields["Size"].Value -gt 0} | Initialize-Item

[int]$PackageMediaSizeEstimate = 0

foreach($MediaItem in $MediaItems) {

    $PackageMediaSizeEstimate += [double]$MediaItem["Size"]/1024
}

$PackageMediaReportProps = @{
    InfoTitle = "Package Contents"
    InfoDescription = "Estimated Package Size: $_($PackageMediaSizeEstimate MB)"
    PageSize = 20
}


$MediaItems |
    Show-ListView @PackageMediaReportProps -Property @{Label="Name"; Expression={$_.DisplayName}},
        @{Label="Size %"; Expression={[Math]::Round(([double]$_.Size/1024)/$PackageMediaSizeEstimate, 3)}},
        @{Label="Path"; Expression={$_.ItemPath}}
