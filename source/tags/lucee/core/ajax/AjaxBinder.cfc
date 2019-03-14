component {
	variables._LUCEE_AJAX_ALLOWED_BINDS = "cfc|javascript|url";
	variables._LUCEE_AJAX_DEFAULT_BINDING_EVENT = "change";
	variables._LUCEE_AJAX_ALLOWED_BINDING_EVENTS = "change|keyup|mousedown|none";
	variables._LUCEE_JS_BIND_HANDLER = 'Lucee.Bind.jsBindHandler';
	variables._LUCEE_CFC_BIND_HANDLER = 'Lucee.Bind.cfcBindHandler';
	variables._LUCEE_URL_BIND_HANDLER = 'Lucee.Bind.urlBindHandler';
	variables.instance.proxyHelper = createObject('component','ajaxProxyHelper').init();
	// Constructor
	public ajaxBinder function init() {
		return this;
	}
	public array function parseParameters(required string bindExpr) {
		var local = structNew();
		local.result = arrayNew(1);
		local.params = reFindNoCase('\(.*\)',arguments.bindExpr,1,true);
		if(local.params.len[1] gt 0){
			local.params = mid(arguments.bindExpr,local.params.pos[1] + 1,local.params.len[1] -2 );
		}else{
			throw( message="No parameters found in the bind expression #arguments.bindExpr#",type="cfajaxproxy.noParameterFound" );
		}
		cfloop (list = local.params,index = "i",delimiters = ","){
			local.param = "";
			local.event = "";
			local.containerid = "";
			local.label = "";
			//look for label
			local.matchlabel = reFindNoCase('\w*=',i,1,true);
			if(local.matchlabel.len[1] gt 0){
				// update the index value removing the label
				local.label = mid(i,local.matchlabel.pos[1],local.matchlabel.len[1] - 1);
				i = right(i,(len(i) - local.matchlabel.len[1]));
			}
			local.param = rereplace(i,'\{|\}','','All');
			// search for specific event
			local.event = reFindNoCase('(@)+(#_LUCEE_AJAX_ALLOWED_BINDING_EVENTS#)',local.param,1,true);
			if(local.event.len[1] gt 0){
				local.event = listLast(local.param,'@');
				local.param = listFirst(local.param,'@');
			}else{
				local.event = _LUCEE_AJAX_DEFAULT_BINDING_EVENT;
			}
			// check is passed an id of a dom container
			if(listLen(local.param,':') eq 2){
				local.containerId = listGetAt(local.param,1,':');
				local.param = listGetAt(local.param,2,':');
			}
			local.bind = arrayNew(1);
			local.bind.add(local.param);
			local.bind.add(local.event);
			local.bind.add(local.containerId);
			// if no label refer to the dom name attribute
			if(local.label eq ""){
				local.label = local.param;
			}	
			local.bind.add(local.label);
			local.result.add(local.bind);
		}
		return local.result;
	}
	public struct function parseBind(required string bindExpr,string listener = '',required string errorHandler = '') {
		var local = structNew();
		local.hasParams = true;
		local.result = structNew();
		local.result['bindExpr'] = [];
		// check if exists abc:
		local.bindType = reFindNoCase('(#_LUCEE_AJAX_ALLOWED_BINDS#)\:',arguments.bindExpr,1,true);
		if(local.bindType.len[1] gt 0){
			local.bindType = mid(arguments.bindExpr,local.bindType.pos[1],local.bindType.len[1] - 1);
		}else{
			throw(message = "The Bind expression #arguments.bindExpr# is not supported.",type = "cfajaxproxy.BindExpressionNOtSupported");
		}
		// javascript
		if(local.bindType eq 'javascript'){
			local.jsFunction = reFindNoCase(':\w*\(',arguments.bindExpr,1,true);
			if(local.jsFunction.len[1] gt 0){
				local.jsFunction = mid(arguments.bindExpr,local.jsFunction.pos[1] + 1,local.jsFunction.len[1] -2);
			}else{
				throw (message = "The Bind expression #arguments.bindExpr# is not supported.",type = "cfajaxproxy.BindExpressionNOtSupported");
			}
			arguments.listener = local.jsFunction;
			local.result['handler'] = _LUCEE_JS_BIND_HANDLER;
		}
		// cfc
		if(local.bindType eq 'cfc'){
			local.cfcString = reFindNoCase(':.*\(',arguments.bindExpr,1,true);
			if( local.cfcString.len[1] gt 0){
				local.cfcString = mid(arguments.bindExpr,local.cfcString.pos[1] + 1,local.cfcString.len[1] -2);
				local.len = listlen(local.cfcString,'.');
				local.result['method'] = listGetAt(local.cfcString,local.len,'.');
				local.result['url'] = listDeleteAt(local.cfcString,local.len,'.');
				local.result['url'] = variables.instance.proxyHelper.classToPath(local.result['url']);
			}else{
				throw(message = "The Bind expression #arguments.bindExpr# is not supported.", type = "cfajaxproxy.BindExpressionNOtSupported");
			}
			local.result['handler'] = _LUCEE_CFC_BIND_HANDLER;
		}
		// url
		if(local.bindType eq 'url'){
			if( refind('\?',arguments.bindExpr,1,false) eq 0 ){
				local.hasParams = false;
				local.result['url'] = rereplace(arguments.bindExpr,'url:','','one') & '?';
			}
			if (local.hasParams){
				local.url = reFindNoCase(':.*\?',arguments.bindExpr,1,true);
				if (local.url.len[1] gt 0){
					local.result['url'] = mid(arguments.bindExpr,local.url.pos[1] + 1,local.url.len[1] -2 );
				}else{
					throw(message = "The Bind expression #arguments.bindExpr# is not supported.",type = "cfajaxproxy.BindExpressionNOtSupported");
				}
				// Alter the bind Expression to fit the parseParameters 
				local.queryString = reFindNoCase('\?.*',arguments.bindExpr,1,true);
				local.queryString = mid(arguments.bindExpr,local.queryString.pos[1] + 1, local.queryString.len[1] -1);
				// Looks for normal quesry string parameters that are not bindings and keep them with url
				local.qs = "";
				local.binds = "";
				cfloop (list = local.queryString,index = "local.item",delimiters = "&"){
					if( find("{",local.item) eq 0){
						local.qs = listAppend(local.qs,local.item,"&");
					}else{
						local.binds = listAppend(local.binds,local.item,"&");
					}
				}
				// add qs to url
				local.result["url"] = "#local.result["url"]#?#local.qs#";
				arguments.bindExpr = reReplace('(' & local.binds &')','&',',','All');
			}
			local.result['handler'] = _LUCEE_URL_BIND_HANDLER;
		}	
		local.result['listener'] = arguments.listener;
		local.result['errorHandler'] = arguments.errorHandler;
		// prevent operation if we already have assured there are no params to check
		if(local.hasParams){
			local.result['bindExpr'] = parseParameters(arguments.bindExpr);
		}
		return local.result;
	}
}