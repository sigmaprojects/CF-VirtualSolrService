<!---
	Author:		Don Quist
	Version:	1?
	Description:
		I just needed a way to index and simple search collections of different types. 
		Works for me - use / distribute / change at will (I suggest this especially for the Search method).
	https://github.com/sigmaprojects/CF-VirtualSolrService
	
	Credit to Raymond Camden - Based nearly all of this on his examples.
	http://www.raymondcamden.com/index.cfm/2009/8/20/Simple-ColdFusion-9-ORMSolr-Example
--->
<cfcomponent output="false" displayname="VirtualSolrService">

	<cffunction name="init" output="false">
		<cfargument name="collection" type="string" required="true">
		<cfset variables.collection = arguments.collection>
		<cfreturn this />
	</cffunction>

	<cffunction name="search" access="public" output="false" returntype="query">
		<cfargument name="title" type="string" required="true" />
		<cfargument name="custom1" type="string" required="false" />
		<cfargument name="custom2" type="string" required="false" />
		<cfargument name="custom3" type="string" required="false" />
		<cfargument name="custom4" type="string" required="false" />
		<cfset var criteria = "" />
		<cfset var r = "" />
		<cfset var results = "" />

		<cfsavecontent variable="criteria">
			<cfoutput>
			<cfif len(trim(arguments.title))>
				'#lcase(arguments.title)#'
			</cfif>
			<cfif structKeyExists(arguments,'custom1') && len(trim(arguments.custom1))>
				custom1:#arguments.custom1#
			</cfif>
			<cfif structKeyExists(arguments,'custom2') && len(trim(arguments.custom2))>
				custom2:#arguments.custom2#
			</cfif>
			<cfif structKeyExists(arguments,'custom3') && len(trim(arguments.custom3))>
				custom3:#arguments.custom3#
			</cfif>
			<cfif structKeyExists(arguments,'custom4') && len(trim(arguments.custom4))>
				custom4:#arguments.custom4#
			</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfif len(trim(criteria))>
			<cfsearch collection="#variables.collection#" criteria="#criteria#" name="results" status="r" suggestions="always" contextPassages="2">
			<cfreturn results />
		</cfif>
		<cfreturn queryNew('null') />
	</cffunction>

	<cffunction name="reindex" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="key" type="string" required="true" />
		<cfargument name="body" type="string" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="custom1" type="string" required="false" />
		<cfargument name="custom2" type="string" required="false" />
		<cfargument name="custom3" type="string" required="false" />
		<cfargument name="custom4" type="string" required="false" />
		
		<cfcollection action="list" name="collections" engine="solr">
		<cfif !listFindNoCase(valueList(collections.name), variables.collection)>
			<cfcollection action="create" collection="#variables.collection#" engine="solr" path="#variables.collection#">
		</cfif>
		<!--- nuke-a-duke --->
		<cfindex collection="#variables.collection#" action="purge">
		
		<cfif isQuery(arguments.data)>
			<cfset var q = arguments.data />
		<cfelseif IsArray(arguments.data)>
			<cfset var q = entityToQuery(arguments.data) />
		<cfelse>
			<cfthrow type="VirtualSolrService.ReIndex.BadQuery" message="ReIndex will only accept data that either is, or can be converted to a query" />
		</cfif>

		<!--- add to collection using the most convoluted process imaginable --->
			
		<cfif !structKeyExistS(arguments,'custom1') && !structKeyExistS(arguments,'custom2') && !structKeyExistS(arguments,'custom3') && !structKeyExistS(arguments,'custom4')>
			<cfindex action="update" query="q" collection="#variables.collection#" body="#arguments.body#" title="#arguments.title#" key="#arguments.key#" />
			<cfreturn />
		</cfif>

		<cfif !structKeyExistS(arguments,'custom2') && !structKeyExistS(arguments,'custom3') && !structKeyExistS(arguments,'custom4')>
			<cfindex action="update" query="q" collection="#variables.collection#" body="#arguments.body#" title="#arguments.title#" key="#arguments.key#" custom1="#arguments.custom1#" />
			<cfreturn />
		</cfif>

		<cfif !structKeyExistS(arguments,'custom3') && !structKeyExistS(arguments,'custom4')>
			<cfindex action="update" query="q" collection="#variables.collection#" body="#arguments.body#" title="#arguments.title#" key="#arguments.key#" custom1="#arguments.custom1#" custom2="#arguments.custom2#" />
			<cfreturn />
		</cfif>

		<cfif !structKeyExistS(arguments,'custom4')>
			<cfindex action="update" query="q" collection="#variables.collection#" body="#arguments.body#" title="#arguments.title#" key="#arguments.key#" custom1="#arguments.custom1#" custom2="#arguments.custom2#" custom3="#arguments.custom3#" />
			<cfreturn />
		</cfif>
		
		<cfindex action="update" query="q" collection="#variables.collection#" body="#arguments.body#" title="#arguments.title#" key="#arguments.key#" custom1="#arguments.custom1#" custom2="#arguments.custom2#" custom3="#arguments.custom3#" custom4="#arguments.custom4#" />
		<cfreturn />
	</cffunction>


	<cffunction name="delete" access="public" output="false" returntype="void">
		<cfargument name="key" type="any" required="true" />
		<cfindex collection="#variables.collection#" action="delete" key="#arguments.key#" type="custom">
		<cfreturn />
	</cffunction>


	<cffunction name="update" access="public" output="false" returntype="void">
		<cfargument name="key" type="any" required="true" />
		<cfargument name="body" type="string" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="custom1" type="string" required="false" />
		<cfargument name="custom2" type="string" required="false" />
		<cfargument name="custom3" type="string" required="false" />
		<cfargument name="custom4" type="string" required="false" />
		<!---
			I just want to leave a note here;
			This is so GGRRR - first there is no cfscript method for cfindex,
			secondly - you cannot effectively use argumentCollection on cfindex,
			thirdly - what the hell is wrong with Adobe, custom1, custom2, custom3?  DEFINE CUSTOM KEYS TO MAKE THIS USEFUL, AND DO NOT LIMIT THEM TO AN ARBITRARY NUMBER! 
		--->
		<cfif !structKeyExistS(arguments,'custom1') && !structKeyExistS(arguments,'custom2') && !structKeyExistS(arguments,'custom3') && !structKeyExistS(arguments,'custom4')>
			<cfindex action="update" type="custom" collection="#variables.collection#" key="#arguments.key#" body="#arguments.body#" title="#arguments.title#" />
			<cfreturn />
		</cfif>
		
		<cfif !structKeyExistS(arguments,'custom2') && !structKeyExistS(arguments,'custom3') && !structKeyExistS(arguments,'custom4')>
			<cfindex action="update" type="custom" collection="#variables.collection#" key="#arguments.key#" body="#arguments.body#" title="#arguments.title#" custom1="#arguments.custom1#" />
			<cfreturn />
		</cfif>
		
		<cfif !structKeyExistS(arguments,'custom3') && !structKeyExistS(arguments,'custom4')>
			<cfindex action="update" type="custom" collection="#variables.collection#" key="#arguments.key#" body="#arguments.body#" title="#arguments.title#" custom1="#arguments.custom1#" custom2="#arguments.custom2#" />
			<cfreturn />
		</cfif>
		
		<cfif !structKeyExistS(arguments,'custom4')>
			<cfindex action="update" type="custom" collection="#variables.collection#" key="#arguments.key#" body="#arguments.body#" title="#arguments.title#" custom1="#arguments.custom1#" custom2="#arguments.custom2#" custom3="#arguments.custom3#" />
			<cfreturn />
		</cfif>
		
		<cfindex action="update" type="custom" collection="#variables.collection#" key="#arguments.key#" body="#arguments.body#" title="#arguments.title#" custom1="#arguments.custom1#" custom2="#arguments.custom2#" custom3="#arguments.custom3#" custom4="#arguments.custom4#" />
		<cfreturn />
	</cffunction> 


	<cffunction name="hasIndex" access="public" output="false" returntype="boolean">
		<cfset var collections = '' />
		<cfcollection action="list" name="collections" engine="solr">
		<cfif !listFindNoCase(valueList(collections.name), variables.collection)>
			<cfreturn false />
		</cfif>
		<cfreturn true />
	</cffunction>


</cfcomponent>