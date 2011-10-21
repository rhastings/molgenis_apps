/**
 * @author Jessica Lundberg
 * @author Erik Roos
 * @date Feb 24, 2011
 * 
 * This class is the model for the ApplyProtocolPlugin
 */
package org.molgenis.protocol;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.molgenis.framework.db.Database;
import org.molgenis.framework.db.DatabaseException;
import org.molgenis.pheno.Code;
import org.molgenis.pheno.Measurement;
import org.molgenis.pheno.ObservationTarget;

import commonservice.CommonService;

public class ApplyProtocolPluginModel {

	private List<Measurement> featuresList = new ArrayList<Measurement>();
	private List<Integer> targetsIdList = new ArrayList<Integer>();
	private List<String> targetList = new ArrayList<String>();
	private List<String> fullTargetList = new ArrayList<String>();
	private List<String> batchesList = new ArrayList<String>();
	private int protocolId;
	private boolean newProtocolApplication = false;
	private boolean timeInfo = false;
	private boolean allValues = false;
	private int userId = -1;
	private List<Integer> investigationIds;
	private Map<Measurement, List<Code>> codeMap = new HashMap<Measurement, List<Code>>();
	private Map<Measurement, List<String>> codeMapString = new HashMap<Measurement, List<String>>();
	private Map<Measurement, List<ObservationTarget>> panelMap = new HashMap<Measurement, List<ObservationTarget>>();
	private Map<Measurement, String> typeMap = new HashMap<Measurement, String>();
	private ApplyProtocolService service;
	
	public ApplyProtocolPluginModel() {
	}
	
	public void setService(ApplyProtocolService service) {
		this.service = service;
	}

	public void setFeaturesLists(List<Measurement> featuresList) throws DatabaseException, ParseException {
		this.featuresList = featuresList;
		
		for (Measurement m : featuresList) {
			codeMap.put(m, service.getAllCodesForFeature(m.getName()));
			
			codeMapString.put(m, service.getAllCodesForFeatureAsStrings(m.getName()));
			
			String panelLabel = m.getPanelLabelAllowedForRelation();
			panelMap.put(m, service.getAllMarkedPanels(panelLabel, investigationIds));
			
			String observationTargetType = "ObservationTarget";
			if (m.getTargettypeAllowedForRelation() != null) {
				int entityId = m.getTargettypeAllowedForRelation_Id();
				observationTargetType = service.getEntityName(entityId);
			}
			typeMap.put(m, observationTargetType);
		}
	}
	
	public List<Code> getAllCodesForFeature(Measurement measurement) {
		return codeMap.get(measurement);
	}
	
	public List<String> getAllCodesForFeatureAsStrings(Measurement measurement) {
		return codeMapString.get(measurement);
	}
	
	public List<ObservationTarget> getAllPanelsForFeature(Measurement measurement) {
		return panelMap.get(measurement);
	}
	
	public String getTargettypeAllowedForRelation(Measurement measurement) {
		return typeMap.get(measurement);
	}

	public List<Measurement> getFeaturesList() {
		return featuresList;
	}

	public List<Integer> getTargetsIdList() {
		return targetsIdList;
	}

	public void setProtocolId(int protocolId) {
	    this.protocolId = protocolId;
	}

	public int getProtocolId() {
	    return protocolId;
	}

	public void setNewProtocolApplication(boolean newProtocolApplication) {
		this.newProtocolApplication = newProtocolApplication;
	}

	public boolean isNewProtocolApplication() {
		return newProtocolApplication;
	}

	public void setTimeInfo(boolean timeInfo) {
		this.timeInfo = timeInfo;
	}

	public boolean isTimeInfo() {
		return timeInfo;
	}

	public void setTargetList(List<String> targetList) {
		this.targetList = targetList;
	}
	
	public List<String> getTargetList() {
		return targetList;
	}
	
	public void setBatchesList(List<String> batchesList) {
		this.batchesList = batchesList;
	}

	public List<String> getBatchesList() {
		return batchesList;
	}

	public void setFullTargetList(List<String> fullTargetList) {
		this.fullTargetList = fullTargetList;
	}

	public List<String> getFullTargetList() {
		return fullTargetList;
	}

	public void setUserAndInvestigationIds(int userId) {
		this.userId = userId;
		this.investigationIds = service.getWritableUserInvestigationIds(userId);
	}

	public int getUserId() {
		return userId;
	}
	
	public int getOwnInvestigationId() {
		return service.getOwnUserInvestigationId(userId);
	}
	
	public List<Integer> getInvestigationIds() {
		return investigationIds;
	}
	
	public Database getDatabase() {
		return service.getDatabase();
	}

	public void setAllValues(boolean allValues) {
		this.allValues = allValues;
	}

	public boolean isAllValues() {
		return allValues;
	}
}