#Requires -Version 5.0

param
(
    [Parameter()]
    [String[]] $TaskList = @("RestorePackages", "Build", "CopyArtifacts"),
   
	[String] $OutputPath="HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1/bin/Debug/",	
	[String] $Platform="Any CPU",
	[Parameter(Mandatory)]
    [String] $Configuration = "Debug",
	
    [String] $BuildArtifactsFolder = "C:/consoleRunner/BuildPackagesFromPipeline/$BUILD_ID"
)

$NugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$NugetExe = Join-Path $PSScriptRoot "nuget.exe"

$MSBuild = "C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/MSBuild/15.0/Bin/MSBuild.exe"
$Solution = "HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1.sln"

Function DownloadNuGet()
{
    if (-Not (Test-Path $NugetExe)) 
    {
        Write-Output "Installing NuGet from $NugetUrl..."
        Invoke-WebRequest $NugetUrl -OutFile $NugetExe -ErrorAction Stop
    }
}

Function RestoreNuGetPackages()
{
    DownloadNuGet
    Write-Output 'Restoring NuGet packages...'
	& $NugetExe
}

Function BuildSolution()
{
    Write-Output "Building '$Solution' solution..."
	& $MSBuild $Solution /p:Configuration=$Configuration /p:Platform=$Platform /p:OutputPath=$OutputPath
}

Function CopyBuildArtifacts()
{
    param
    (
        [Parameter(Mandatory)]
        [String] $SourceFolder,
        [Parameter(Mandatory)]
        [String] $DestinationFolder
    )

	Write-Output "Copying items into $DestinationFolder..."
	if (& Test-Path $DestinationFolder)
	{
		Write-Output "removing"
		& Remove-Item $DestinationFolder
	}
	Write-Output "creation"
	& new-item -path "C:/consoleRunner/BuildPackagesFromPipeline/" -name "new" -type directory
	Write-Output "reviewing"
	& Get-ChildItem $SourceFolder 
	Write-Output "destination"
	& Copy-Item $SourceFolder -destination $DestinationFolder
}

foreach ($Task in $TaskList) {
    if ($Task.ToLower() -eq 'restorepackages')
    {
        RestoreNuGetPackages
    }
    if ($Task.ToLower() -eq 'build')
    {
        BuildSolution
    }
    if ($Task.ToLower() -eq 'copyartifacts')
    {
        CopyBuildArtifacts "HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1/bin/Debug/*.*" "C:/consoleRunner/BuildPackagesFromPipeline/new/"
    }
}