package org.molgenis.fieldtypes;

import org.molgenis.framework.ui.html.HtmlInput;
import org.molgenis.framework.ui.html.HtmlInputException;
import org.molgenis.framework.ui.html.IntInput;
import org.molgenis.model.MolgenisModelException;

public class IntField extends FieldType
{
	@Override
	public String getJavaPropertyType() throws MolgenisModelException
	{
		return "Integer";
	}
	
	@Override
	public String getJavaAssignment(String value)
	{
		if(value == null || value.equals("")) return "null";
		return ""+Integer.parseInt(value);
	}
	
	@Override
	public String getJavaPropertyDefault()
	{
		return getJavaAssignment(f.getDefaultValue());
	}
	
	@Override
	public String getMysqlType() throws MolgenisModelException
	{
		return "INTEGER";
	}
	
	public String getJavaSetterType() throws MolgenisModelException
	{
		return "Int";
	}

	@Override
	public String getHsqlType()
	{
		return "INT";
	}
	@Override
	public String getXsdType()
	{
		return "int";
	}

	@Override
	public String getFormatString()
	{
		return "%d";
	}

	@Override
	public HtmlInput createInput(String name, String xrefEntityClassName) throws HtmlInputException
	{
		return new IntInput(name);
	}

	@Override
	public String getCppPropertyType() throws MolgenisModelException
	{
		return "int";
	}
	
	@Override
	public String getCppJavaPropertyType()
	{
		return "Ljava/lang/Integer;";
	}
}
