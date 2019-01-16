node('master') {
    stage('Checkout')
    {
        git "https://github.com/makstaras/HWAdvancedSeleniumPt1.git"
    }
    
    stage('Restore NuGet Stage')
    {
        bat '"C:\\nuget.exe" restore HWAdvancedSeleniumPt1/HWAdvancedSeleniumPt1.sln'
    }
}