component name = "ajaxBase" {
	// Instance vars
	variables.instance = {};
	//	Resources location ( can be overwritten )
	variables.instance.SCRIPTSRC = "/mapping-tag/lucee/core/ajax/JSLoader.cfc?method=get&lib=";
	variables.instance.CSSSRC = "/mapping-tag/lucee/core/ajax/css/";
	variables.instance.LOADERSRC = "/mapping-tag/lucee/core/ajax/loader/loading.gif.cfm";
	//	Lucee js library location 
	variables.instance.LUCEEJSSRC = "/mapping-tag/lucee/core/ajax/JSLoader.cfc?method=get&lib=";
	// Default to current context, can be overridden on init
	if (getContextRoot() neq "/"){
		variables.instance.SCRIPTSRC = getContextRoot() & variables.instance.SCRIPTSRC;
		variables.instance.CSSSRC = getContextRoot() & variables.instance.CSSSRC;
		variables.instance.LOADERSRC = getContextRoot() & variables.instance.LOADERSRC;
		variables.instance.LUCEEJSSRC = getContextRoot() & variables.instance.LUCEEJSSRC;
	}
	// Constructor
	public void function init(string scriptSrc = "#variables.instance.SCRIPTSRC#", string cssSrc = "#variables.instance.CSSSRC#",
		string loaderSrc = "#variables.instance.LOADERSRC#" , string adapter = "",struct params = {}) {
		var js = "";
		if(arguments.cssSrc neq variables.instance.CSSSRC){
			variables.instance.isCustomCss = true;
		}
		js &= '<script type="text/javascript">
				var _cf_ajaxscriptsrc = "#arguments.scriptsrc#";
				var _cf_ajaxcsssrc = "#arguments.cssSrc#";
				var _cf_loadingtexthtml = <div style="text-align: center;"><img src="#arguments.loadersrc#"/></div>;
				var _cf_params = #serializeJson(arguments.params)#;
			</script>
			<script type="text/javascript" src="#variables.instance.LUCEEJSSRC#LuceeAjax"></script>
		';
		if (len(arguments.adapter)){
			js &= '<script type="text/javascript" src="#arguments.adapter#"></script>';
		}
		writeHeader(js,'Lucee-Ajax-Core');	
	}
	// Write Header
	/**
	* writes data to html header but only once
	*/
	public void function writeHeader(required string text, required string id) {
		try {
			htmlhead action = "read" variable = "local.head";
		}
		// throws exception when already flushed or action read is not supported
		catch(e) {
			echo(trim(text));
			return;
		}
		if(!find(id,head)) {
			htmlhead action = "append" text = " <!---#id#---> #trim(text)#";
		}
	}
	// StripWhiteSpace
	public string function stripWhiteSpace(string str = "") {
		return trim(reReplaceNoCase(arguments.str,"(</?.*?\b[^>]*>)[\s]{1,}|[\r]{1,}(</?.*?\b[^>]*>)","\1#chr(13)##chr(10)#\2","All"));
	}
}