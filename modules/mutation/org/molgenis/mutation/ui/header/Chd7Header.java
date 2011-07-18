/* Date:        March 17, 2011
 * Template:	PluginScreenJavaTemplateGen.java.ftl
 * generator:   org.molgenis.generators.ui.PluginScreenJavaTemplateGen 3.3.3
 * 
 * THIS FILE IS A TEMPLATE. PLEASE EDIT :-)
 */

package org.molgenis.mutation.ui.header;

import org.molgenis.framework.db.Database;
import org.molgenis.framework.ui.EasyPluginController;
import org.molgenis.framework.ui.FreemarkerView;
import org.molgenis.framework.ui.ScreenController;

public class Chd7Header extends EasyPluginController<Chd7HeaderModel>
{

	private static final long serialVersionUID = 6224612078995632056L;

	public Chd7Header(String name, ScreenController<?> parent)
	{
		super(name, null, parent);
		this.setModel(new Chd7HeaderModel(this));
		this.setView(new FreemarkerView("Chd7Header.ftl", getModel()));
	}

	@Override
	public String getCustomHtmlHeaders()
	{
		String cssFormat = "<link rel=\"stylesheet\" style=\"text/css\" type=\"text/css\" href=\"%s\">\n";
		String jsFormat = "<script src=\"%s\" type=\"text/javascript\" language=\"javascript\"></script>";
		String headers = "";
		
//		cp res/css/colors.css generated-res/css
//		cp res/css/data.css generated-res/css
//		cp res/css/main.css generated-res/css
//		cp res/css/menu.css generated-res/css
//		cp res/scripts/all.js generated-res/scripts
//		cp res/img/*.jpg generated-res/img

		headers += String.format(cssFormat, "res/displaytag/css/displaytag.css");
		//headers += String.format(cssFormat, "res/displaytag/css/screen.css");
		//headers += String.format(cssFormat, "res/displaytag/css/site.css");
		headers += String.format(cssFormat, "res/css/col7a1/colors.css");
		headers += String.format(cssFormat, "res/css/col7a1/data.css");
		//headers += String.format(cssFormat, "res/css/main.css");
		//headers += String.format(cssFormat, "res/css/menu.css");
		headers += String.format(jsFormat, "res/scripts/all.js");
		
		return headers;
	}

	@Override
	public void reload(Database db)
	{
		//nothing to do here
	}
}
