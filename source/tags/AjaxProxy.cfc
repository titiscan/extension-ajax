component extends = "lucee.core.ajax.AjaxBase" {
	variables.instance.proxyHelper = createObject('component','lucee.core.ajax.AjaxProxyHelper').init();
	variables.instance.ajaxBinder = createObject('component','lucee.core.ajax.AjaxBinder').init();
	// Meta data 
	this.metadata.hint = "Creates a JavaScript proxy for a component, for use in an AJAX client. Alternatively, creates a proxy for a single CFC method, JavaScript function, or URL that is bound to one or more control attribute values.";
	this.metadata.attributetype = "fixed";
	this.metadata.attributes = {
		cfc:		{required:false,type:"string",default:"",hint = "the CFC for which to create a proxy. You must specify a dot-delimited path to the CFC. The path can be absolute or relative to location of the CFML page. For example, if the myCFC CFC is in the cfcs subdirectory of the Luceex page, specify cfcs.myCFC. On UNIX based systems, the tag searches first for a file whos name or path corresponds to the specified name or path, but is in all lower case. If it does not find it, Luceex then searches for a file name or path that coresponds to the attribute value exactly, with identical character casing."},
		jsclassname:{required:false,type:"string",default:"",hint = "The name to use for the JavaScript proxy class."},
		bind:		{required:false,type:"string",default:"",hint = "A bind expression that specifies a CFC method, JavaScript function, or URL to call. Cannot be used with the cfc attribute."},
		onError:	{required:false,type:"string",default:"",hint = "The name of a JavaScript function to invoke when a bind, specified by the bind attribute fails. The function must take two arguments: an error code and an error message."},
		onSuccess:	{required:false,type:"string",default:"",hint = "The name of a JavaScript function to invoke when a bind, specified by the bind attribute succeeds. The function must take one argument, the bind function return value. If the bind function is a CFC function, the return value is automatically converted to a JavaScript variable before being passed to the onSuccess function."},
		extends:	{required:false,type:"boolean",default:true,hint = "If true force ajaxproxy to look for remote methods in the cfc extensions chain. Any remote method found will be added to the proxy object. This atrribute cannot be used with a bind attribute."},
		methods:	{required:false,type:"string",default:"",hint = "Comma delimited list of methods name. If exists only the method ( if remote ) specified will be exposed in the proxy object."}
	};
	/**
	* Invoked after tag is constructed
	* @parent The parent cfc custom tag, if there is one.
	*/
	public void function init(required boolean hasEndTag,component parent) {
		super.init();
	}
	public boolean function onStartTag(struct attributes,struct caller) {
		var hasCFC = len(trim(attributes.cfc));
		var hasBind = len(trim(attributes.bind));
		if (hasCFC and hasBind){
			throw (message = "you can not use attribute [cfc] and attribute [bind] at the same time");
		}else if (not hasCFC and not hasBind){
			throw (message = "you must define at least one of the following attributes [cfc,bind]");
		}
		if(hasCFC){
			if (len(trim(attributes.onError))){
				throw (message = "in this context attribute [onError] is not allowed");
			}else if (len(trim(attributes.onSuccess))){
				throw (message = "in this context attribute [onSuccess] is not allowed");
			}
			doCFC(argumentCollection:arguments);
		}
		else{
			if (len(trim(attributes.jsclassname))){
				throw (message = "in this context attribute [jsclassname] is not allowed");
			}else if (len(trim(attributes.methods))){
				throw (message = "in this context attribute [methods] is not allowed");
			}
			doBind(argumentCollection:arguments);
		}
		return false;
	}
	public void function doCFC(struct attributes,struct caller) {
		var ph = getProxyHelper();
		var js = "";
		// CONVERT CFC PATH TO REALTIVE PATH.
		// Relative path need to be craeted and passed to js proxy object to perform ajax calls.
		// Es: mypath.components.mycfc  TO /mypath/components/mycfc.cfc
		cfcPath = ph.classToPath(attributes.cfc);
		// get the cfc metadatas filtered by remote access only.
		meta = ph.parseMetaData(attributes.cfc,attributes.methods,attributes.extends);
		js &= '
			<script type="text/javascript">
				var _Lucee_#attributes.jsclassname# = Lucee.ajaxProxy.init("#cfcPath#","#attributes.jsClassName#");
		';
		cfloop (array = meta.functions,index = 'method') {
			var args = ph.getArguments(method.parameters);
			var argsJson = ph.argsToJsMode(args);
			js &= "
				_Lucee_#attributes.jsclassname#.prototype.#method.name# = function(#args#){
					return Lucee.ajaxProxy.invokeMethod(this,'#method.name#',{#argsJson#});
				};
			";
		}
		js &= '</script>';
		writeHeader(js,'_Lucee_#attributes.jsclassname#');
	}
	public void function doBind(struct attributes,struct caller) {
		bind = getAjaxBinder().parseBind(bindExpr = attributes.bind,listener = attributes.onSuccess,errorHandler = attributes.onError);
		rand = "_Lucee_Bind_#randRange(1,99999999)#";
		js &= '<script type="text/javascript">';
		#rand# = function(){
			js &= "Lucee.Bind.register('_Lucee_Bind_#randRange(1,99999999)#',#serializeJson(bind)#)";
		}
		js &= "Lucee.Events.subscribe(#rand#,'onLoad');</script>";
		writeHeader(js,'#rand#');
	}
	// Private
	// getProxyHelper
	private ajaxProxyHelper function getProxyHelper() {
		return variables.instance.proxyHelper;
	}
	// getAjaxBinder
	private ajaxBinder function getAjaxBinder(param) {
		return variables.instance.ajaxBinder
	}
}