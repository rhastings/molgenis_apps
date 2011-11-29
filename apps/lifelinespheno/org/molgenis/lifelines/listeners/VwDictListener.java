//package org.molgenis.lifelines.listeners;
//
//import java.util.LinkedHashMap;
//import java.util.Map;
//
//import javax.persistence.EntityManager;
//
//import org.molgenis.framework.db.Database;
//import org.molgenis.framework.db.DatabaseException;
//import org.molgenis.organization.Investigation;
//import org.molgenis.pheno.Measurement;
//import org.molgenis.protocol.Protocol;
//import org.molgenis.util.Tuple;
//
//
//
///**
// * This listener creates Measurement for each field and Protocol for each table in VW_DICT
// * 
// * TABNAAM
//GROEP
//VELDNR
//VELD -> Measurement.name
//VLDTYPE -> Measurement.dataType
//OMSCHR -> Measurement.description
//
// * @author jorislops
// *
// */
//public class VwDictListener extends ImportTupleListener {
//
//	private Map<String, Protocol> protocols = new LinkedHashMap<String, Protocol>();
//	
//	private final Investigation investigation;
//	
//	public VwDictListener(Investigation investigation, String name, Database db) {
//		super(name, db);
//		this.investigation = investigation;
//	}
//
//	@Override
//	public void handleLine(int line_number, Tuple tuple) throws Exception {
//		
//		String protocolName = tuple.getString("TABNAAM");
//		
//		//create new protocol if not yet known
//		Protocol p = protocols.get(protocolName);
//		if(p == null)
//		{
//			p = new Protocol();
//			p.setName(protocolName);
//			//p.setInvestigation_Id(investigationId);
//			p.setInvestigation(investigation);
//			protocols.put(protocolName, p);
//		}
//		
//		Measurement m = new Measurement();
//		m.setName(tuple.getString("VELD"));
//		m.setDataType( tuple.getString("VLDTYPE")  );
//		m.setDescription(tuple.getString("OMSCHR"));
//		
//		p.getFeatures().add(m);
//	}
//	
//	public void commit() throws DatabaseException
//	{
//		EntityManager em = db.getEntityManager();
//		em.getTransaction().begin();
//		for(Protocol p : protocols.values()) {
//			em.persist(p);
//		}		
//		em.flush();
//		em.getTransaction().commit();
//	}
//
//	public Map<String, Protocol> getProtocols() {
//		return protocols;
//	}
//}
