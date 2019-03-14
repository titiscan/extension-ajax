<cfscript>
	/**
	* Causes the specified JavaScript function to run when the page loads.
	* @functionname The name of the function to run when the page loads.
	*/
	public any function ajaxOnLoad(functionname){
		if (len(arguments.functionname)){
			//load js lib if required
			ajaximport;
			//subscribe to the onload event
			writeOutput('<script type="text/javascript">Lucee.Events.subscribe(arguments.functionname,"onLoad");</script>');
		}
	}
</cfscript>