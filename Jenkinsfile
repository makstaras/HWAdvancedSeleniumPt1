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
        bat '"C:/nuget.exe" restore HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1.sln'
    }
	
	stage('Build Solution')
    {
        bat '"C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/MSBuild/15.0/Bin/MSBuild.exe" HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1.sln'
    }
	
	stage('Copy Artifacts')
	{
		bat "(robocopy HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1/bin/Debug $buildArtifactsFolder /MIR /XO) ^& IF %ERRORLEVEL% LEQ 1 exit 0"
		
	}
}

catchError
{
	isFailed = true
	stage('Run Tests')
	{
		parallel FirstTest:{
			node('master'){
				RunUnitTests("$buildArtifactsFolder/HWAdvancedSeleniumPt1.dll", "--where cat==fake", "TestResult1.xml")
			}
		}, SecondTest: {
			node('Slave'){
				RunUnitTests("$buildArtifactsFolder/HWAdvancedSeleniumPt1.dll", "--where cat==good", "TestResult2.xml")
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
		nunit testResultPattern: 'TestResult1.xml, TestResult2.xml'
		
    }
}