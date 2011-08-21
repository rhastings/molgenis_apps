package test;

import org.molgenis.framework.db.Database;
import org.openqa.selenium.server.RemoteControlConfiguration;
import org.openqa.selenium.server.SeleniumServer;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import plugins.emptydb.emptyDatabase;
import app.servlet.MolgenisServlet;
import boot.RunStandalone;

import com.thoughtworks.selenium.DefaultSelenium;
import com.thoughtworks.selenium.HttpCommandProcessor;
import com.thoughtworks.selenium.Selenium;

public class AnimaldbSeleniumTest
{
	
	Selenium selenium;
	Integer sleepTime = 1000;
	String pageLoadTimeout = "30000";
	//String storagePath = new File(".").getAbsolutePath() + File.separator + "tmp_selenium_test_data";

	@BeforeClass
	public void start() throws Exception
	{
		
		int webserverPort = Helper.getAvailablePort(11000, 100);
		
		String seleniumUrl = "http://localhost:" + webserverPort + "/";
		String seleniumHost = "localhost";
		String seleniumBrowser = "firefox";
		int seleniumPort = Helper.getAvailablePort(9080, 100);
	
		RemoteControlConfiguration rcc = new RemoteControlConfiguration();
		rcc.setSingleWindow(true);
		rcc.setPort(seleniumPort);

		try
		{
			SeleniumServer server = new SeleniumServer(false, rcc);
			server.boot();
		}
		catch (Exception e)
		{
			throw new IllegalStateException("Cannot start selenium server: ", e);
		}

		HttpCommandProcessor proc = new HttpCommandProcessor(seleniumHost, seleniumPort, seleniumBrowser, seleniumUrl);
		selenium = new DefaultSelenium(proc);
		selenium.start();
		
		//Helper.deleteDatabase();
		new emptyDatabase(new MolgenisServlet().getDatabase(), true);
		
		new RunStandalone(webserverPort);
	}

	@Test
	public void startup() throws InterruptedException
	{
		selenium.open("/molgenis_apps/molgenis.do");
		selenium.waitForPageToLoad(pageLoadTimeout);
//		Assert.assertEquals(selenium.getTitle(), "AnimalDB");
//		Assert.assertTrue(selenium.isTextPresent("Welcome"));
//		Assert.assertEquals(selenium.getText("link=R api"), "R api");
		sleepHelper("startup");
	}

	@Test
	public void login() throws InterruptedException
	{
//		selenium.click("id=UserLogin_tab_button");
//		selenium.waitForPageToLoad(pageLoadTimeout);
//		Assert.assertEquals(selenium.getText("link=Register"), "Register");
//		selenium.type("id=username", "admin");
//		selenium.type("id=password", "admin");
//		selenium.click("id=Login");
//		selenium.waitForPageToLoad(pageLoadTimeout);
//		
//		//note: page now redirects to the Home screen ('auth_redirect' in properties)
//		//note2: REDIRECT BROKEN, DISABLED ATM
//		selenium.click("id=ClusterDemo_tab_button");
//		selenium.waitForPageToLoad(pageLoadTimeout);
//
//		sleepHelper("login");
	}
	
	@AfterClass(alwaysRun=true)
	public void stop() throws Exception
	{
		selenium.stop();
		
		//added to fix TestDatabase which runs after this one...
		//see comment in TestDatabase!
		new emptyDatabase(new MolgenisServlet().getDatabase(), false);
		
		//Helper.deleteStorage();
		//Helper.deleteDatabase();
	}
	
	private void sleepHelper(String who) throws InterruptedException
	{
		System.out.println(who + " done, now sleeping for " + sleepTime + " msec");
		Thread.sleep(sleepTime);
	}

}