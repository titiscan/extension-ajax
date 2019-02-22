component {
	<!--- Constructor ------------------------------------------------------------------------->
    public function init() output="no" returntype="ajaxProxyHelper"{
		return this;
  	} 
	<!--- Public ------------------------------------------------------------------------------>
	public function classToPath(required string cfcClass) returntype = "string"{
		var cfcPath = reReplace(arguments.cfcClass,'\.','/','All');
		cfcPath = '/' & cfcPath & '.cfc';
		<!--- Support context roots different from '/', ie '/myLucee' --->
		if (getContextRoot() neq '/'){
			cfcPath = getContextRoot() & cfcPath;
		}
		return cfcPath;
	}
	
	public function parseMetadata(required string cfc,string methods='',boolean extends = "false") returntype="struct"{
		var result = {};
		var access = "";
		local.cfc = replaceNoCase((listDeleteAt(CGI.SCRIPT_NAME, listFindNoCase(CGI.SCRIPT_NAME, listLast(CGI.SCRIPT_NAME, "/"), "/"), "/") & "/" & arguments.cfc), "/", ".", "All");
		if(fileExists(expandPath(replaceNoCase(local.cfc, '.', '/', 'all')) & '.cfc')){
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
	
	public function addExtendedFunctions(required struct meta,required array functions,string methods = "") returntype="void"{
		var i = "";
		  
	 	if(arguments.meta['name'] neq 'WEB-INF.cftags.component ' and arguments.meta['name'] neq 'lucee.component'){
			if(structkeyExists(arguments.meta,'functions')){
				arr = filterFunction(arguments.meta.functions,arguments.methods);
				arguments.functions.addAll(arr);
			}	
			if(structkeyExists(arguments.meta,'extends')){
				addExtendedFunctions(arguments.meta.extends,arguments.functions,arguments.methods);
			}	
		}
	}
	
	public function isDuplicateFunction(required array result,required string name) returntype="string"{
		var resp = false;
		var item = "";
		loop array="#arguments.result#" ,index="item"{
			if (item.name eq arguments.name){
				return true;
				break;
			}
		}
		return resp;
	}
	
	public function filterFunction(required array functions, string methods="") returntype="array"{
		var result = arrayNew(1);
		var method = "";
		loop array="#arguments.functions#" ,index="method"{		
			if(structKeyExists(method,'access')){
				if(method.access eq 'remote'){
					if(listLen(arguments.methods)){
						if(listFindnocase(arguments.methods,method.name) gt 0){
							result.add(method);
						}else{result.add(method);}
					}	
				}
			}
		}
		return result;
	}
	
	public function getArguments(required array argsArray) returntype="string" output="false"{
		var result = "";
		loop array="#arguments.argsArray#" ,index="arg"{
			result = listAppend(result,trim(arg.name));
		}
		return result;
	}
	
	public function argsToJsMode(required string args) returntype="string" output="false"{
		var result = "";
		loop list="#arguments.args#" ,index="arg"{
			result = listAppend(result,'#trim(arg)#:#trim(arg)#');
		}
		return result;
	}
}