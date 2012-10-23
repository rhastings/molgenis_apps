<#setting number_format="#"/>
<#include "GeneratorHelper.ftl">
<#--#####################################################################-->
<#--                                                                   ##-->
<#--         START OF THE OUTPUT                                       ##-->
<#--                                                                   ##-->
<#--#####################################################################-->
/*
 * Created by: ${generator}
 * Date: ${date}
 */

package ${package}.servlet;

import java.io.File;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import org.molgenis.framework.security.Login;
import org.molgenis.framework.db.Database;
import org.molgenis.framework.ui.ApplicationController;
import org.molgenis.framework.server.AbstractMolgenisServlet;
import org.apache.commons.dbcp.BasicDataSource;
import org.molgenis.framework.server.TokenFactory;
import org.molgenis.util.EmailService;
import org.molgenis.util.SimpleEmailService;
<#if generate_BOT>
import java.io.IOException;
import ircbot.IRCHandler;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import generic.JavaCompiler;
import generic.JavaCompiler.CompileUnit;
</#if>
<#if db_mode = 'standalone'>
import org.apache.commons.dbcp.BasicDataSource;
import org.molgenis.framework.db.DatabaseException;
<#else>
import ${package}.DatabaseFactory;
import javax.servlet.ServletContext;
import org.molgenis.framework.db.jdbc.JndiDataSourceWrapper;
</#if>

@Deprecated
public class MolgenisServlet extends AbstractMolgenisServlet
{
	private static final long serialVersionUID = 3141439968743510237L;

	public MolgenisServlet() {
		this.usedOptions = new UsedMolgenisOptions();
	}
	
	protected Database createDatabase() {
		try
		{
		<#if databaseImp = 'jpa'>
			return DatabaseFactory.create();	
		<#else>
			//The datasource is created by the servletcontext	
			<#if db_mode != 'standalone'>
			//DEPRECATED: NOW HANDLED BY FRONTCONTROLLER
			//ServletContext sc = MolgenisContextListener.getInstance().getContext();
			//DataSource dataSource = (DataSource)sc.getAttribute("DataSource");
			
			//DEPRECATED: BUT HOTFIX TO GET IT WORKING FOR MYSQL
			BasicDataSource data_src = new BasicDataSource();
			data_src.setDriverClassName("${db_driver}");
			data_src.setUsername("${db_user}");
			data_src.setPassword("${db_password}");
			data_src.setUrl("${db_uri}");
			data_src.setMaxActive(8);
			data_src.setMaxIdle(4);
			DataSource dataSource = (DataSource)data_src;
			return DatabaseFactory.create(dataSource, new File("${db_filepath}"));
			<#else>
			BasicDataSource data_src = new BasicDataSource();
			data_src.setDriverClassName("${db_driver}");
			data_src.setUsername("${db_user}");
			data_src.setPassword("${db_password}");
			data_src.setUrl("${db_uri}"); // a path within the src folder?
			data_src.setMaxIdle(10);
			data_src.setMaxWait(1000);
		
			DataSource dataSource = (DataSource)data_src;
			Database db = new ${package}.JDBCDatabase(dataSource, new File("${db_filepath}"));
			return db;			
			</#if>
		</#if>
		}
		catch (Exception e)
		{
			e.printStackTrace();
			throw new RuntimeException();
		}
	}

	public Database getDatabase() throws Exception
	{
		return super.getDatabase();
	}
	
	<#if generate_BOT>

	public void service(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException{
		ServletConfig s = getServletConfig();
		IRCHandler bot;
		if((bot = (IRCHandler) s.getServletContext().getAttribute("bot")) == null){
			Thread t = new Thread(){
				public void run(){	
					JavaCompiler j = new JavaCompiler();
					CompileUnit source = j.newCompileUnit("handwritten\\webserver\\","buildBOT\\");
					source.addDependencies(new String[]{"handwritten\\webserver\\","WebContent\\WEB-INF\\lib\\pircbot.jar"});
					source.setMainClass("ircbot.IRCHandler");
					source.setCustomJarName("WebContent/dist/Bot");
					j.CompileTarget(source);
				}
			};
			t.start();
		
			s.getServletContext().setAttribute("bot", bot = new IRCHandler());
			new Thread(bot).start();
			System.err.println("Started a bot");
		}else{
			System.err.println("Found the bot");
		}
		super.service(request, response);
	}

	</#if>

	public Login createLogin( Database db, HttpServletRequest request ) throws Exception
	{
		Login login = (Login)request.getSession().getAttribute("login");
		if(login == null) {
			<#if auth_redirect != ''>
			login = new ${loginclass}(db, "${auth_redirect}", new TokenFactory()); //has use in FrontController, added here for backwards compatibility
			<#else>
			login = new ${loginclass}(db, new TokenFactory());
			</#if>			
			request.getSession().setAttribute("login", login);
		}
		db.setLogin(login);
		return login;	
	}

	public ApplicationController createUserInterface( Login userLogin )
	{
		<#if db_mode != 'standalone'>
		ApplicationController app = null;
		try {
			final Database dbForController = this.getDatabase();
			//enhance the ApplicationController with a method to getDatabase 
			app = new ApplicationController( usedOptions, userLogin)
			{
				private static final long serialVersionUID = 6962189567229247434L;
			
				@Override
				public Database getDatabase()
				{
					return dbForController;
				}
			};
			app.getModel().setLabel("${model.label}");
			app.getModel().setVersion("${version}");
		} catch (Exception e) {
			e.printStackTrace();
		}
		<#else>
		//enhance the ApplicationController with a method to getDatabase 
		ApplicationController app = new ApplicationController( usedOptions, userLogin)
		{
			private static final long serialVersionUID = 6962189567229247434L;
		
			@Override
			public Database getDatabase()
			{
				BasicDataSource data_src = new BasicDataSource();
				data_src.setDriverClassName("${db_driver}");
				data_src.setUsername("${db_user}");
				data_src.setPassword("${db_password}");
				data_src.setUrl("${db_uri}"); // a path within the src folder?
				data_src.setMaxIdle(10);
				data_src.setMaxWait(1000);
				DataSource dataSource = (DataSource)data_src;
				Database db;
				try
				{
					db = new app.JDBCDatabase(dataSource, new File("./data/"));
					return db;
				}
				catch (DatabaseException e)
				{
					e.printStackTrace();
					return null;
				}
				
			}
		};
		app.getModel().setLabel("${model.label}");
		app.getModel().setVersion("${version}");
		</#if>
		
<#if mail_smtp_user != '' && mail_smtp_au != ''>
		EmailService service = new SimpleEmailService();
		service.setSmtpFromAddress("${mail_smtp_from}");	
		service.setSmtpProtocol("${mail_smtp_protocol}");
		service.setSmtpHostname("${mail_smtp_hostname}");
		service.setSmtpPort(${mail_smtp_port});
		service.setSmtpUser("${mail_smtp_user}");
		service.setSmtpAu("${mail_smtp_au}");	
		app.setEmailService(service);
</#if>
		
<#list model.userinterface.children as subscreen>
<#assign screentype = Name(subscreen.getType().toString()?lower_case) />
		new ${package}.ui.${JavaName(subscreen)}${screentype}<#if screentype == "Form">Controller</#if>(app);
</#list>
		return app;
	}
	
	public static String getMolgenisVariantID()
	{
		return "${model.name}";
	}	
	
<#if generate_soap>
	@Override
	public Object getSoapImpl() throws Exception
	{
		return new ${package}.servlet.SoapApi((Database)getDatabase());
	}
</#if>
}
