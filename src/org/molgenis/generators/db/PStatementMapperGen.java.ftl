<#include "GeneratorHelper.ftl">
<#function convertToJdbc field>
	<#if field.type='date'>
		<#return "new java.sql.Date(e.get"+JavaName(field)+"().getTime())">
	<#elseif field.type='datetime'>
		<#return "new java.sql.Timestamp(e.get"+JavaName(field)+"().getTime())">
	<#--postgresql doesn't have enum, instead we use a custom type-->
	<#elseif field.type="enum" && db_driver?contains("postgresql")>
		<#return "new EnumObject(\"enum_"+name(entity)?lower_case+"_"+name(field)?lower_case+"\", e.get"+JavaName(field)+"())">
	<#elseif field.type = "xref" || field.type = "mref">
		<#return "e.get"+JavaName(field)+"_"+JavaName(field.xrefField)+"()">		
	<#else>
		<#return "e.get"+JavaName(field)+"()">
	</#if>
</#function>
<#function pstmtSetter field>
	<#if field.type = 'enum' && db_driver?contains("postgresql")>
		<#return "setObject">
	<#else>
		<#return "setObject">
	</#if>
</#function>

<#--#####################################################################-->
<#--                                                                   ##-->
<#--         START OF THE OUTPUT                                       ##-->
<#--                                                                   ##-->
<#--#####################################################################-->
/* File:        ${model.getName()}/model/${entity.getName()}.java
 * Copyright:   GBIC 2000-${year?c}, all rights reserved
 * Date:        ${date}
 * Template:	${template}
 * generator:   ${generator} ${version}
 *
 * Using "subclass per table" strategy
 *
 * THIS FILE HAS BEEN GENERATED, PLEASE DO NOT EDIT!
 */

package ${package};

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.TreeMap;
import java.text.ParseException;

import org.molgenis.framework.db.Database;
import org.molgenis.framework.db.DatabaseException;
import org.molgenis.framework.db.QueryRule;
import org.molgenis.framework.db.QueryRule.Operator;
import org.molgenis.framework.db.jdbc.JDBCDatabase;
import org.molgenis.framework.db.jdbc.AbstractJDBCMapper;
import org.molgenis.fieldtypes.*;

<#list allFields(entity) as f><#if f.type == "file">
import org.apache.commons.io.FileUtils;
<#break>
</#if></#list>

<#list allFields(entity) as f><#if f.type == "mref" || f.type="xref">

<#break>
</#if></#list>
import ${entity.getNamespace()}.${JavaName(entity)};
<#if entity.hasAncestor()>
import ${entity.getAncestor().getNamespace()}.${JavaName(entity.getAncestor())};
import ${entity.getAncestor().getNamespace()}.db.${JavaName(entity.getAncestor())}Mapper;
</#if>
<#list allFields(entity) as f>
	<#if f.type=="xref" || f.type=="mref">
	<#assign xref_entity = f.getXrefEntity()>
import ${xref_entity.getNamespace()}.${JavaName(xref_entity)};
	<#if f.type=="mref">
	<#assign mref_entity = model.getEntity(f.getMrefName())>
import ${mref_entity.getNamespace()}.${JavaName(mref_entity)};
	</#if>
	</#if>
	
</#list>
public class ${JavaName(entity)}Mapper extends AbstractJDBCMapper<${JavaName(entity)}>
{	
<#if db_driver?contains("postgresql") && allFields(entity,"enum")?size &gt; 0>
	//postgresql specific issue with enums: they are special objects.
	private static class EnumObject extends org.postgresql.util.PGobject
	{
		String enumValue = null;
		String enumType = null;
		public EnumObject(String enumType, String enumValue)
		{
			this.setType(enumType);
			this.enumValue = enumValue;
		}
		
		public String getValue()
		{
			return enumValue;
		}		
	}
</#if>

<#include "MapperCommons.subclass_per_table.java.ftl">	
	
	@Override
	public int executeAdd(List<? extends ${JavaName(entity)}> entities) throws DatabaseException
	{	
		<#if entity.hasAncestor()>
		//add superclass first
		this.getDatabase().getMapperFor(${entity.ancestor.namespace}.${JavaName(entity.ancestor)}.class).executeAdd(entities);
		</#if>
	
		Connection conn = getDatabase().getConnection();
		PreparedStatement pstmt = null;
		try
		{
			pstmt = conn.prepareStatement("INSERT INTO ${name(entity)} (<#list addFields(entity) as f>${name(f)}<#if f_has_next>,</#if></#list>) VALUES (<#list addFields(entity) as f>?<#if f_has_next>,</#if></#list>)");
			int updatedRows = 0;
			
			for( ${JavaName(entity)} e : entities )	
			{	
<#list addFields(entity) as f>	
				//${f}
				//if(e.get${JavaName(f)}() == null) pstmt.setNull(${f_index + 1},Types.${SqlType(model,f)});	
				if(e.get${JavaName(f)}<#if f.type="xref" || f.type="mref">_${JavaName(f.xrefField)}</#if>() == null) pstmt.setNull(${f_index + 1},Types.OTHER);
				else pstmt.${pstmtSetter(f)}(${f_index + 1},${convertToJdbc(f)});
</#list>
	
				updatedRows += pstmt.executeUpdate();
				
				//retrieve autogenerated keys
<#list dbFields(entity) as f><#if f.auto && f.type="int">
<#if db_driver == "org.hsqldb.jdbcDriver">
				Statement keyStmt = conn.createStatement();
				ResultSet rs = keyStmt.executeQuery("CALL IDENTITY()");
				rs.next();
				e.set${JavaName(f)}(rs.getInt(1));
				rs.close();
				JDBCDatabase.closeStatement(keyStmt);
<#else>
				getGeneratedKeys(entities, pstmt, 0);
</#if></#if></#list>						
			}					
		
			return updatedRows;
		} catch (SQLException sqlEx) {
                    throw new DatabaseException(sqlEx);
                }
		finally
		{
			JDBCDatabase.closeStatement(pstmt);
		}
	}

	@Override
	public int executeUpdate(List<? extends ${JavaName(entity)}> entities) throws DatabaseException
	{
		<#if entity.hasAncestor()>
		//add superclass first
		this.getDatabase().getMapperFor(${entity.ancestor.namespace}.${JavaName(entity.ancestor)}.class).executeUpdate(entities);
		</#if>
		
		Connection conn = getDatabase().getConnection();
		PreparedStatement pstmt = null;
		try
		{
			pstmt = conn.prepareStatement("UPDATE ${name(entity)} SET <#list updateFields(entity) as f>${name(f)}=?<#if f_has_next>,</#if></#list> WHERE <#list keyFields(entity) as f>${f.name}=?<#if f_has_next> AND </#if></#list>");
			int updatedRows = 0;	
			
			for( ${JavaName(entity)} e : entities )	
			{	
<#assign index = 1>		
<#list updateFields(entity) as f>	
				//${f}
				//if(e.get${JavaName(f)}() == null) pstmt.setNull(${index},Types.${SqlType(model,f)}); 
				if(e.get${JavaName(f)}<#if f.type="xref" || f.type="mref">_${JavaName(f.xrefField)}</#if>() == null) pstmt.setNull(${index},Types.OTHER);
				else pstmt.${pstmtSetter(f)}(${index},${convertToJdbc(f)});
<#assign index = index+1>				
</#list>
<#list keyFields(entity) as f>
				//where ${f}
				//if(e.get${JavaName(f)}() == null) pstmt.setNull(${index},Types.${SqlType(model,f)});
				if(e.get${JavaName(f)}<#if f.type="xref" || f.type="mref">_${JavaName(f.xrefField)}</#if>() == null) pstmt.setNull(${index},Types.OTHER);
				else pstmt.${pstmtSetter(f)}(${index},${convertToJdbc(f)});			
<#assign index = index+1>				
</#list>	
				updatedRows += pstmt.executeUpdate();
			}					
	
			return updatedRows;
		} catch (SQLException sqlEx) {
                    throw new DatabaseException(sqlEx);
                }
		finally
		{
                    JDBCDatabase.closeStatement(pstmt);
		}
	}

	@Override
	public int executeRemove(List<? extends ${JavaName(entity)}> entities) throws DatabaseException
	{
		Connection conn = getDatabase().getConnection();
		PreparedStatement pstmt = null;
		int updatedRows = 0;
		try
		{
			pstmt = conn.prepareStatement("DELETE FROM ${name(entity)} WHERE <#list keyFields(entity) as f>${name(f)}=?<#if f_has_next> AND </#if></#list>");
					
			for( ${JavaName(entity)} e : entities )	
			{	
<#list keyFields(entity) as f>
				//${f}
				//if(e.get${JavaName(f)}() == null) pstmt.setNull(${f_index + 1},Types.${SqlType(model,f)}); 
				if(e.get${JavaName(f)}<#if f.type="xref" || f.type="mref">_${JavaName(f.xrefField)}</#if>() == null) pstmt.setNull(${f_index + 1},Types.OTHER);
				else pstmt.${pstmtSetter(f)}(${f_index + 1},${convertToJdbc(f)});
</#list>	
				updatedRows += pstmt.executeUpdate();
			}
		} 
		catch (SQLException sqlEx) 
		{
			throw new DatabaseException(sqlEx);
        } 
        finally
		{
			JDBCDatabase.closeStatement(pstmt);
		}
		
		<#if entity.hasAncestor()>
		//add superclass first
		this.getDatabase().getMapperFor(${entity.ancestor.namespace}.${JavaName(entity.ancestor)}.class).executeRemove(entities);
		</#if>
		
		return updatedRows;
	}


<#include "MapperFileAttachments.java.ftl">
<#include "MapperMrefs.java.ftl"/>
}