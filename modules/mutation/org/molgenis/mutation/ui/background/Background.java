/* Date:        February 23, 2010
 * Template:	PluginScreenJavaTemplateGen.java.ftl
 * generator:   org.molgenis.generators.ui.PluginScreenJavaTemplateGen 3.3.2-testing
 * 
 * THIS FILE IS A TEMPLATE. PLEASE EDIT :-)
 */

package org.molgenis.mutation.ui.background;

import org.molgenis.framework.db.Database;
import org.molgenis.framework.ui.PluginModel;
import org.molgenis.framework.ui.ScreenController;
import org.molgenis.mutation.service.MutationService;
import org.molgenis.mutation.service.PatientService;
import org.molgenis.mutation.vo.BackgroundSummaryVO;
import org.molgenis.util.Entity;
import org.molgenis.util.Tuple;


public class Background extends PluginModel<Entity>
{

	private static final long serialVersionUID = -5551425852519199587L;
	private MutationService mutationService;
	private PatientService patientService;
	private BackgroundSummaryVO backgroundSummaryVO;

	public Background(String name, ScreenController<?> parent)
	{
		super(name, parent);
	}

	@Override
	public String getViewName()
	{
		return "org_molgenis_mutation_ui_background_Background";
	}

	@Override
	public String getViewTemplate()
	{
		return "org/molgenis/mutation/ui/background/Background.ftl";
	}

	@Override
	public void handleRequest(Database db, Tuple request)
	{
	}

	@Override
	public void reload(Database db)
	{
		try
		{
			this.mutationService     = MutationService.getInstance(db);
			this.patientService      = PatientService.getInstance(db);
			this.backgroundSummaryVO = new BackgroundSummaryVO();
			this.backgroundSummaryVO.setNumMutations(this.mutationService.getNumMutations());
			this.backgroundSummaryVO.setNumPatients(this.patientService.getNumPatients());
			this.backgroundSummaryVO.setNumPatientsUnpub(this.patientService.getNumUnpublishedPatients());
			this.backgroundSummaryVO.setPhenotypeCountHash(this.patientService.getPhenotypeCounts());
		}
		catch(Exception e)
		{
			//...
		}
	}
	
	@Override
	public boolean isVisible()
	{
		return true;
	}
	
	public BackgroundSummaryVO getBackgroundSummaryVO()
	{
		return this.backgroundSummaryVO;
	}
}
