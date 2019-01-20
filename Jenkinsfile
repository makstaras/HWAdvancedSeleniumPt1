properties([
	parameters([
		string (name: 'branchName', defaultValue: 'master', description: 'Branch to get the tests from')
	])
])

def isFailed = false
def branch = params.branchName
def buildArtifactsFolder = "C:/consoleRunner/BuildPackagesFromPipeline/$BUILD_ID"
currentBuild.description = "Branch: $branch"

def RunUnitTests(String pathToDll, String condition, String reportName)
{
	try
	{
		bat "C:/consoleRunner/NUnit.Console-3.9.0/nunit3-console.exe $pathToDll $condition --result=$reportName"
	}
	finally
	{
		stash name: reportName, includes: reportName
	}
}

node('master') {
    stage('Checkout')
    {
        git branch: branch, url: "https://github.com/makstaras/HWAdvancedSeleniumPt1.git"
    }
    
    stage('Restore NuGet Stage')
    {
        powershell ".\\build.ps1 RestoreNuGetPackages"
	}
	
	stage('Build Solution')
    {
		powershell ".\\build.ps1 BuildSolution"
	}
	
	stage('Copy Artifacts')
	{
		powershell ".\\build.ps1 CopyBuildArtifacts"
	
	}
}

catchError
{
	isFailed = true
	stage('Run Tests')
	{
		parallel FirstTest:{
			node('master'){
				RunUnitTests("C:/consoleRunner/BuildPackagesFromPipeline/new/HWAdvancedSeleniumPt1.dll", "--where cat==fake", "TestResult1.xml")
			}
		}, SecondTest: {
			node('Slave'){
				RunUnitTests("C:/consoleRunner/BuildPackagesFromPipeline/new/HWAdvancedSeleniumPt1.dll", "--where cat==good", "TestResult2.xml")
			}
		}
		
	}
	isFailed = false
}

node('master')
{
	stage('Reporting')
    {
		unstash "TestResult1.xml"
		unstash "TestResult2.xml"
		
		archiveArtifacts '*.xml'
		nunit testResultsPattern: 'TestResult1.xml, TestResult2.xml'
		
    }
}