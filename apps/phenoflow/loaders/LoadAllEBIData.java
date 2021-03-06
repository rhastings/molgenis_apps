package loaders;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.molgenis.Molgenis;
import org.molgenis.framework.db.Database;
import org.molgenis.framework.db.Database.DatabaseAction;
import org.molgenis.util.SimpleTuple;

import app.CsvImport;
import app.DatabaseFactory;
import app.JDBCDatabase;

public class LoadAllEBIData
{
	public static void main(String[] args) throws Exception
	{

		new Molgenis("apps/phenoflow/phenoflow.properties").updateDb(true);

		// recreate database
		Database db = DatabaseFactory.create("apps/phenoflow/phenoflow.properties");
		String directory;

		// Load dbGaP
		LoadDbGapDownloads.loadDbGaPData(db);

		// Europhenome
		directory = "../pheno_data/Europhenome2";

		CsvImport
				.importAll(new File(directory), db, new SimpleTuple(), null, DatabaseAction.ADD_IGNORE_EXISTING, "N/A");

		// MPD

		// need to preload measurements first, otherwise protocol
		// will complain it's missing them due to incorrect
		// autogenerated order

		List<String> list = new ArrayList<String>();
		list.add("investigation");
		list.add("ontologyterm");
		list.add("measurement");
		directory = "../pheno_data/MPD";
		CsvImport
				.importAll(new File(directory), db, new SimpleTuple(), list, DatabaseAction.ADD_IGNORE_EXISTING, "N/A");
		CsvImport
				.importAll(new File(directory), db, new SimpleTuple(), null, DatabaseAction.ADD_IGNORE_EXISTING, "N/A");

		System.out.println("Done");
	}
}
