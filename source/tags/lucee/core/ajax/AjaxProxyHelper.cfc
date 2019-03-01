component {
	// Constructor
    public ajaxProxyHelper function init() {
		return this;
  	} 
	// Public
	public string function classToPath(required string cfcClass) {
		var cfcPath = reReplace(arguments.cfcClass,'\.','/','All');
		cfcPath = '/' & cfcPath & '.cfc';
		// Support context roots different from '/', ie '/myLucee'
		if (getContextRoot() neq '/'){
			cfcPath = getContextRoot() & cfcPath;
		}
		return cfcPath;
	}
	public struct function parseMetadata(required string cfc,string methods = '',boolean extends = 'false') {
		var result = {};
		var access = "";
		local.cfc = replaceNoCase((listDeleteAt(CGI.SCRIPT_NAME, listFindNoCase(CGI.SCRIPT_NAME, listLast(CGI.SCRIPT_NAME, "/"), "/"), "/") & "/" & arguments.cfc), "/", ".", "All");
		if(fileExists(expandPath(replaceNoCase(local.cfc, '.', '/', 'all')) & '.cfc')) {
			var meta = getComponentMetadata(local.cfc);
		}else{
			var meta = getComponentMetadata(arguments.cfc);
		}
		result.functions = createObject('java','java.util.ArrayList').init();
		if (structKeyExists(meta,'FUNCTIONS')){
			var methods = filterFunction(meta.functions,arguments.methods);
			result.functions.addAll(methods);
		}
		if (arguments.extends){
			addExtendedFunctions(meta.extends,result.functions,arguments.methods);
		}
		return result;	
	}
	public void function addExtendedFunctions(required struct meta,required array functions,string methods = "") {
		var i = "";
	 	if(arguments.meta['name'] neq 'WEB-INF.cftags.component' and arguments.meta['name'] neq 'lucee.component'){
			if(structkeyExists(arguments.meta,'functions')){
				arr = filterFunction(arguments.meta.functions,arguments.methods);
				arguments.functions.addAll(arr);
			}	
			if(structkeyExists(arguments.meta,'extends')){
				addExtendedFunctions(arguments.meta.extends,arguments.functions,arguments.methods);
			}	
		}
	}
	public string function isDuplicateFunction(required array result,required string name) {
		var resp = false;
		var item = "";
		cfloop (array = "#arguments.result#",index = "item"){
			if (item.name eq arguments.name){
				return true;
				break;
			}
		}
		return resp;
	}
	public array function filterFunction(required array functions, string methods="") {
		var result = arrayNew(1);
		var method = "";
		cfloop (array = "#arguments.functions#",index = "method"){		
			if(structKeyExists(method,'access')){
				if(method.access eq 'remote'){
					if(listLen(arguments.methods)){
						if(listFindnocase(arguments.methods,method.name) gt 0){
							result.add(method);
						}	
					}else{
						result.add(method);
					}
				}
			}
		}
		return result;
	}
	public string function getArguments(required array argsArray) {
		var result = "";
		cfloop (array = "#arguments.argsArray#",index = "arg"){
			result = listAppend(result,trim(arg.name));
		}
		return result;
	}
	public string function argsToJsMode(required string args) {
		var result = "";
		cfloop (list = "#arguments.args#",index = "arg"){
			result = listAppend(result,'#trim(arg)#:#trim(arg)#');
		}
		return result;
	}
}