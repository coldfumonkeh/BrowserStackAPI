<!---
Name: BrowserStackAPI.cfc
Author: Matt Gifford (http://www.mattgifford.co.uk)
Date: 7th February 2014
Purpose:
	A ColdFusion wrapper to interact with the Browser Stack REST API.
	http://www.browserstack.com/automate/rest-api
--->
<cfcomponent output="false">

	<cfproperty name="username" 	type="string" default="" />
	<cfproperty name="automate_key" type="string" default="" />
	
	<cffunction name="init" access="public" output="false" hint="The constructor method for the CFC.">
		<cfargument name="username" 	required="true" type="string" hint="The username." />
		<cfargument name="automate_key" required="true" type="string" hint="The automate API key." />
			<cfset setUserName(username) />
			<cfset setAutomateKey(automate_key) />
			<cfset variables.apiEndpoint = 'https://www.browserstack.com/automate/' />
		<cfreturn this />
	</cffunction>

	<!--- MUTATORS / SETTERS --->
	<cffunction name="setUserName" access="private" output="false" hint="I set the username value.">
		<cfargument name="username" required="true" type="string" hint="The username." />
			<cfset variables.username = arguments.username />
	</cffunction>

	<cffunction name="setAutomateKey" access="private" output="false" hint="I set the automate_key value.">
		<cfargument name="automate_key" required="true" type="string" hint="The automate API key." />
			<cfset variables.automate_key = arguments.automate_key />
	</cffunction>

	<!--- ACCESSORS / GETTERS --->
	<cffunction name="getUserName" access="private" output="false" hint="I get the username value.">
			<cfreturn variables.username />
	</cffunction>

	<cffunction name="getAutomateKey" access="private" output="false" hint="I get the automate_key value.">
		<cfreturn variables.automate_key />
	</cffunction>

	<cffunction name="getAPIEndpoint" access="private" output="false" hint="I get the API endpoint base value.">
		<cfreturn variables.apiEndpoint />
	</cffunction>

	<!--- START API METHODS --->

	<!--- STATUS --->

	<cffunction name="checkStatus" access="public" output="false" hint="Obtain more information about your group's automate plan including the maximum number of parallel sessions allowed and the number of parallel sessions currently running.">
		<cfargument name="parseResults"	required="false" type="boolean" default="false" hint="A boolean value to determine if the output data is parsed or returned as a string" />
		<cfreturn handleReturnFormat(makeCall('plan'), arguments.parseResults) />
	</cffunction>

	<!--- PROJECTS --->

	<cffunction name="getProjects" access="public" output="false" hint="Projects are organizational structures for builds. You can query the projects associated with your username and access key.">
		<cfargument name="parseResults"	required="false" type="boolean" default="false" hint="A boolean value to determine if the output data is parsed or returned as a string" />
		<cfreturn handleReturnFormat(makeCall('projects'), arguments.parseResults) />
	</cffunction>

	<cffunction name="getProjectByID" access="public" output="false" hint="Once the list of projects is available, more specific information about a specific project can be queried using project id.">
		<cfargument name="projectid"	required="true"		type="string" 						hint="The ID of the project." />
		<cfargument name="parseResults"	required="false" 	type="boolean" 	default="false" 	hint="A boolean value to determine if the output data is parsed or returned as a string" />
		<cfreturn handleReturnFormat(makeCall('projects/#arguments.projectid#'), arguments.parseResults) />
	</cffunction>

	<!--- BUILDS --->

	<cffunction name="getBuilds" access="public" output="false" hint="Builds are organizational structures for tests. You can query the builds associated with your username and access key.">
		<cfargument name="limit"		required="false" 	type="numeric" 	default="10"		hint="An optional parameter to set the maximum number of results to return." />
		<cfargument name="filter"		required="false" 	type="string" 	default=""			hint="In order to view a subset of results, you can use the filter parameter to refine your results. The three values the parameter takes are running, done and failed." />
		<cfargument name="parseResults"	required="false" 	type="boolean" 	default="false" 	hint="A boolean value to determine if the output data is parsed or returned as a string" />
			<cfset var stuParams = {'limit' = arguments.limit, 'filter' = arguments.filter} />
		<cfreturn handleReturnFormat(makeCall('builds', stuParams), arguments.parseResults) />
	</cffunction>

	<!--- SESSIONS --->

	<cffunction name="getBuildSessions" access="public" output="false" hint="To retrieve a list of sessions under a particular build, query the server with the build id.">
		<cfargument name="buildid"		required="true"		type="string" 						hint="The ID of the build." />
		<cfargument name="limit"		required="false" 	type="numeric" 	default="10"		hint="An optional parameter to set the maximum number of results to return." />
		<cfargument name="filter"		required="false" 	type="string" 	default=""			hint="In order to view a subset of results, you can use the filter parameter to refine your results. The three values the parameter takes are running, done and failed." />
		<cfargument name="parseResults"	required="false" 	type="boolean" 	default="false" 	hint="A boolean value to determine if the output data is parsed or returned as a string" />
			<cfset var stuParams = {'limit' = arguments.limit, 'filter' = arguments.filter} />
		<cfreturn handleReturnFormat(makeCall('builds/#arguments.buildid#/sessions', stuParams), arguments.parseResults) />
	</cffunction>

	<cffunction name="getSessionByID" access="public" output="false" hint="Query a particular session using the session id.">
		<cfargument name="sessionid"	required="true"		type="string" 						hint="The ID of the session." />
		<cfargument name="parseResults"	required="false" 	type="boolean" 	default="false" 	hint="A boolean value to determine if the output data is parsed or returned as a string" />
		<cfreturn handleReturnFormat(makeCall('sessions/#arguments.sessionid#'), arguments.parseResults) />
	</cffunction>

	<cffunction name="getSessionLogs" access="public" output="false" hint="Retrieve the logs for a particular session using the session id.">
		<cfargument name="buildid"		required="true"		type="string" 						hint="The ID of the build." />
		<cfargument name="sessionid"	required="true"		type="string" 						hint="The ID of the session." />
		<cfreturn handleReturnFormat(makeCall('builds/#arguments.buildid#/sessions/#arguments.sessionid#/logs'), false) />
	</cffunction>

	<!--- BROWSERS --->
	<cffunction name="getBrowsers" access="public" output="false" hint="You can get a list of desired capabilities for both desktop and mobile browsers. It returns a flat hash in the format [:os, :os_version, :browser, :browser_version, :device].">
		<cfreturn handleReturnFormat(makeCall('browsers'), false) />
	</cffunction>	

	<!--- END API METHODS --->

	<!--- START UTILS --->

	<cffunction name="makeCall" access="private" output="false" hint="I make a GET request to the API.">
		<cfargument name="endpoint_method" 	required="true" 	type="string" 							hint="The partial path to the required method endpoint." />
		<cfargument name="parameters" 		required="false" 	type="struct" default="#structNew()#" 	hint="A struct of values to send to the API request as additional parameters." />
			<cfset var strAPIURL = getAPIEndpoint() & arguments.endpoint_method & '.json' & buildParamString(arguments.parameters) />
			<cfhttp url="#strAPIURL#" method="GET" username="#getUserName()#" password="#getAutomateKey()#" />
		<cfreturn cfhttp.FileContent />
	</cffunction>

	<cffunction name="handleReturnFormat" access="private" output="false" hint="I handle how the data is returned based upon the provided format">
		<cfargument name="data" 		required="true" 	type="string" 					hint="The data returned from the API." />
		<cfargument name="parseResults"	required="false" 	type="boolean" default="false" 	hint="A boolean value to determine if the output data is parsed or returned as a string" />
			<cfif arguments.parseResults>
				<cfreturn DeserializeJSON(arguments.data) />
			<cfelse>
				<cfreturn arguments.data.toString() />
			</cfif>
		<cfabort>
	</cffunction>

	<cffunction name="buildParamString" access="private" output="false" returntype="String" hint="I loop through a struct to convert to query params for the URL">
		<cfargument name="argScope" required="true" type="struct" hint="I am the struct containing the method params" />
			<cfset var strURLParam 	= '' />
			<cfloop collection="#arguments.argScope#" item="local.key">
				<cfif len(arguments.argScope[key])>
					<cfif listLen(strURLParam)>
						<cfset strURLParam = strURLParam & '&' />
					</cfif>
					<cfset strURLParam = strURLParam & lcase(key) & '=' & arguments.argScope[key] />
				</cfif>
			</cfloop>
			<cfif len(strURLParam)>
				<cfset strURLParam = '?' & strURLParam />
			</cfif>
		<cfreturn strURLParam />
	</cffunction>

	<!--- END UTILS --->

</cfcomponent>