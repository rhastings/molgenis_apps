package org.molgenis.lifelines;


import org.molgenis.Molgenis;


public class lifelinesGenerate
{
	public static void main(String[] args) throws Exception
	{
		new Molgenis("apps/lifelines/org/molgenis/lifelines/lifelines.molgenis.properties").generate();
	}
}