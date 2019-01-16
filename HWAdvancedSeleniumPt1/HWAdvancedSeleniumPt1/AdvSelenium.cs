using System;
using System.IO;
using System.Linq;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Interactions;

namespace HWAdvancedSeleniumPt1
{
    [TestFixture]
    public class AdvSelenium
    {
        IWebDriver driver;

        [OneTimeSetUp]
        public void OneTimeSetUp()
        {
            //Using -headless only for Chrome browser
            var options = new ChromeOptions();
            options.AddArguments
                (
                    "-headless"
                );

            var browserType = TestContext.Parameters.Get("Browser", "Chrome").ToString();
            if (browserType == "Chrome") driver = new ChromeDriver(options);
            else if (browserType == "Firefox") driver = new FirefoxDriver();
            else if (browserType == "IE") driver = new InternetExplorerDriver();
            else throw new NotImplementedException("Seems there is no other browsers");
        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {
            driver.Quit();
        }

        [Test, Category("fake")]
        public void FakeTest()
        {
            Assert.True(true);
        }

        [Test, Category("good")]
        public void TakeScreenShotOnLeafground()
        {
            driver.Navigate().GoToUrl($"http://www.leafground.com/home.html");
            driver.Manage().Window.Maximize();
            driver.Manage().Timeouts().ImplicitWait = TimeSpan.FromSeconds(2);

            //Open “HyperLink” page in new tab
            new Actions(driver).KeyDown(Keys.Control).Click(driver.FindElement(By.LinkText("HyperLink"))).Perform();
            driver.SwitchTo().Window(driver.WindowHandles.Last());
            Assert.That(driver.Title, Is.EqualTo("TestLeaf - Interact with HyperLinks"));

            //Hover on “Go to Home Page” link
            new Actions(driver).MoveToElement(driver.FindElement(By.XPath("//*[@id='contentblock']/section/div[1]/div/div/a")))
                .Perform();
            
            //Take a screenshot and save it somewhere
            var screenshot = ((ITakesScreenshot)driver).GetScreenshot();
            var destinationPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop) + @"\HWTarasMaksymiv";
            string curentDateTime = string.Format("{0:yyyy-MM-dd_hh-mm-ss}", DateTime.Now);
            System.IO.Directory.CreateDirectory(destinationPath);
            var screenshotPath = Path.Combine(destinationPath, curentDateTime + ".png");
            screenshot.SaveAsFile(screenshotPath);
            TestContext.AddTestAttachment(screenshotPath);

            //Close the tab
            driver.Close();

            //Switch to first tab
            driver.SwitchTo().Window(driver.WindowHandles[0]);
        }

        [Test, Category("good")]
        public void UsingFrameAndDragDrop()
        {
            driver.Navigate().GoToUrl($"https://jqueryui.com/demos/");
            driver.Manage().Window.Maximize();
            driver.Manage().Timeouts().ImplicitWait = TimeSpan.FromSeconds(2);

            //Navigate to “Droppable” demo(Interactions section)
            By droppableDemo = By.XPath("//*[@id='content']/ul[1]/li[2]/a");
            driver.FindElement(droppableDemo).Click();
            driver.SwitchTo().Window(driver.WindowHandles.Last());

            //Switch to frame
            By firstFrame = By.ClassName("demo-frame");
            driver.SwitchTo().Frame(driver.FindElement(firstFrame));

            //Drag & Drop the small box into a big one
            var draggable = driver.FindElement(By.Id("draggable"));
            var droppable = driver.FindElement(By.Id("droppable"));
            var actions = new Actions(driver);
            actions.DragAndDrop(draggable, droppable).Perform();

            //Verify that big box now contains text “Dropped!”
            Assert.That(droppable.Text, Is.EqualTo("Dropped!"));
        }
    }
}
