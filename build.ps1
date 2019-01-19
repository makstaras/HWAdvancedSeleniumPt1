#Requires -Version 5.0

param
(
    [Parameter()]
    [String[]] $TaskList = @("RestorePackages", "Build", "CopyArtifacts"),
    
	# Also add following parameters: 
    #   Configuration
    #   Platform
    #   OutputPath
    # And use these parameters inside BuildSolution function while calling for MSBuild.
    # Use /p swith to pass the parameter. For example:
    #   MSBuild.exe src/Solution.sln /p:Configuration=$Configuration
    # More info here: https://docs.microsoft.com/en-us/visualstudio/msbuild/common-msbuild-project-properties?view=vs-2017
	
	
	
	[String] $OutputPath,
	
	[String] $Platform,
    
	
    [String] $BuildArtifactsFolder = "C:/consoleRunner/BuildPackagesFromPipeline/$BUILD_ID",

	[Parameter(Mandatory)]
	[String] $Configuration = "Debug"
)

$NugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$NugetExe = Join-Path $PSScriptRoot "nuget.exe"
# Define additional variables here (MSBuild path, etc.)
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
    # NuGet.exe call here
	& $NugetExe
}

Function BuildSolution()
{
    Write-Output "Building '$Solution' solution..."
    # MSBuild.exe call here
	& $MSBuild $Solution
	#$MSBuild HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1.sln /p:Configuration=$Configuration
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

    # Copy all files from $SourceFolder to $DestinationFolder
    #
    # Useful commands:
    #   Test-Path - check if path exists
    #   Remove-Item - remove folders/files
    #   New-Item - create folder/file
    #   Get-ChildItem - gets items from specified path
    #   Copy-Item - copies item into destination folder
    #
    #     NOTE: you can chain methods using pipe (|) symbol. For example:
    #           Get-ChildItem ... | Copy-Item ...
    #
    #           which will get items (Get-ChildItem) and will copy them (Copy-Item) to the target folder
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
        CopyBuildArtifacts "YOUR FOLDER WITH BUILT DLLS" "$BuildArtifactsFolder"
    }
}