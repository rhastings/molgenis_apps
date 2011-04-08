<#setting number_format="#"/>
<#include "GeneratorHelper.ftl">
<#include "HsqlHelper.ftl">
<#--#####################################################################-->
<#--                                                                   ##-->
<#--         START OF THE OUTPUT                                       ##-->
<#--                                                                   ##-->
<#--#####################################################################-->
<#-- Generate a table for each concrete class (so, not abstract) -->
<#list entities as entity>
	<#if !entity.isAbstract()>
	DROP TABLE ${SqlName(entity)} IF EXISTS;
	CREATE CACHED TABLE ${SqlName(entity)} (
	<#list dbFields(entity) as f>
		<#if f_index != 0>, </#if><@compress single_line=true>
		${SqlName(f)} ${hsql_type(model,f)}
		<#if f.getDefaultValue()?exists && f.getDefaultValue() != "" && f.type != "text" && f.type != "blob"> DEFAULT <#if f.type == "bool" || f.type == "int">${f.getDefaultValue()}<#else>'${f.getDefaultValue()}'</#if></#if>
		<#if f.auto && f.type == "int"> GENERATED BY DEFAULT AS IDENTITY </#if>	
		<#if !f.nillable> NOT NULL</#if>	
		</@compress>
	
	</#list>
	<#list entity.getKeys() as key>
	<#if key_index == 0>
		, PRIMARY KEY(${csv(key.fields)})
	<#else>
		, UNIQUE(${csv(key.fields)})
	</#if>
	</#list>
	);
	</#if>
</#list>
<#-- Alter the tables to contain the contraining keys we can do so now because the other tables exists -->
<#list entities as entity>
<#--
<#list entity.getIndices() as i>
	CREATE INDEX ${SqlName(i)} ON ${SqlName(entity)} (${csv(i.fields)})
</#list>
-->
<#if !entity.isAbstract()>
	<#list dbFields(entity) as f>
	<#if f.type == "xref">
		ALTER TABLE ${SqlName(entity)} ADD FOREIGN KEY (${SqlName(f)}) REFERENCES ${SqlName((f.xrefEntity))} (${SqlName(f.xrefField)}) ON DELETE CASCADE;
	</#if>
	</#list>
	<#if entity.hasAncestor()>
		ALTER TABLE ${SqlName(entity)} ADD FOREIGN KEY (${SqlName(pkey(entity))}) REFERENCES ${SqlName(entity.getAncestor())} (${SqlName(pkey(entity))}) ON DELETE CASCADE;
	</#if>
</#if>
</#list>
<#--need innodb to support transactions. Do not change! If you need MyISAM, we can make this an generator option-->
<#--http://www.mysql.org/doc/refman/5.1/en/multiple-tablespaces.html for one file per table innodb-->
