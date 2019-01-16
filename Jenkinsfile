properties([
	parameters([
		string (name: 'branchNmae', defaultValue: 'master', description: 'Branch to get the tests from')
	])
])

def isFailed = false
def branch = params.branchName
currentBuild.description = "Branch: $branch"

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
	
	
}

catchError
{
	isFailed = true
	stage('Run Tests')
	{
		parallel FirstTest:{
			node('master'){
				bat '"C:/consoleRunner/NUnit.Console-3.9.0/nunit3-console" HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1/bin/Debug/HWAdvancedSeleniumPt1.dll --where cat==fake'
			}
		}, SecondTest: {
			node('Slave'){
				bat '"C:/consoleRunner/NUnit.Console-3.9.0/nunit3-console" HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1/bin/Debug/HWAdvancedSeleniumPt1.dll --where cat==good'
			}
		}
		
	}
	isFailed = false
}

node('master')
{
	stage('Reporting')
    {
       
    }
}