<#setting number_format="#"/>
<#include "GeneratorHelper.ftl">
package ${package}.servlet;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.sql.DataSource;

public final class MolgenisContextListener implements ServletContextListener
{
	// singleton we can use from everywhere
	private static MolgenisContextListener _instance;

	private ServletContext context = null;

	@Override
	public void contextInitialized(ServletContextEvent sce)
	{
		try
		{
			context = sce.getServletContext();

			Context initContext = new InitialContext();
			// for tomcat
			Context envContext = (Context) initContext.lookup("java:/comp/env");
			// for glassfish
			// Context envContext = (Context)initContext.lookup("");
			DataSource dsource = (DataSource) envContext
					.lookup("${db_jndiname}");

			context.setAttribute("DataSource", dsource);

			_instance = this;
		}
		catch (NamingException ex)
		{
			Logger.getLogger(MolgenisContextListener.class.getName()).log(Level.SEVERE,
					null, ex);
		}
	}

	@Override
	public void contextDestroyed(ServletContextEvent sce)
	{
		context.removeAttribute("DataSource");
		context = null;
	}

	// now, provide an static method to allow access from anywere on the code:
	public static MolgenisContextListener getInstance()
	{
		return _instance;
	}
	
	public ServletContext getContext()
	{
		return context;
	}
}