component extends = "lucee.core.ajax.AjaxBase"{
	variables._SUPPORTED_JSLIB = 'jquery,ext';
	variables.instance.ajaxBinder = createObject('component','lucee.core.ajax.AjaxBinder').init();
	// Meta data
	this.metadata.attributetype = "fixed";
	this.metadata.hint = "Creates a pop-up window in the browser. Does not create a separate browser pop-up instance.";
	this.metadata.attributes = {
		name:			{required:false,type:"string",default:"_cf_window_#randRange(1,999999999)#",hint:""},
		title:      	{required:false,type:"string",default:"",hint:""},
		source:			{required:false,type:"string",default:"",hint:""},
		onBindError:	{required:false,type:"string",default:"",hint:""},
		modal:      	{required:false,type:"boolean",default:false,hint:""},
		refreshOnShow: 	{required:false,type:"boolean",default:false,hint:""},
		width:  		{required:false,type:"numeric",default:500,hint:""},
		height:			{required:false,type:"numeric",default:300,hint:""},
		minWidth:  		{required:false,type:"numeric",default:150,hint:""},
		minHeight:		{required:false,type:"numeric",default:150,hint:""},
		initShow:   	{required:false,type:"boolean",default:false,hint:""},
		resizable:  	{required:false,type:"boolean",default:true,hint:""},
		draggable:  	{required:false,type:"boolean",default:true,hint:""},
		onBindError:	{required:false,type:"string",default:"",hint:""},
		jsLib:  		{required:false,type:"string",default:"jquery",hint:""},
		x:		        {required:false,type:"numeric",default:-1,hint:""},
		y:		        {required:false,type:"numeric",default:-1,hint:""},
		buttons:        {required:false,type:"string",default:"{}",hint:""}
	};
	/**
	* Invoked after tag is constructed.
	* @parent The parent cfc custom tag, if there is one.
	*/
	public void function init(required boolean hasEndTag, component parent) {
		var js = "";
		variables.hasEndTag = arguments.hasEndTag;
		super.init();
	} 
	public boolean function onStartTag(struct attributes, struct caller) {
		//Be sure library is supported ( if not we do not have resources to load ) 
		if(listfind(variables._SUPPORTED_JSLIB,attributes.jsLib) eq 0){
			throw (message = "The js library [#attributes.jsLib#] is not supported for tag CFWINDOW. Supported libraries are [#variables._SUPPORTED_JSLIB#]");
		}
		if (not structKeyExists(request,'Lucee_Ajax_Window')){
			js &= ('<script type = "text/javascript">Lucee.Ajax.importTag("CFWINDOW","#attributes.jsLib#");</script>');
			htmlhead text = "#js#";
			request.Lucee_Ajax_Window = 'loaded';
		}
		//checks 
		var hasRefreshOnShow = attributes.refreshOnShow;
		var hasSource = len(trim(attributes.source));
		if(not hasSource){
			if(hasRefreshOnShow){
				throw (message = "in this context attribute [hasRefreshOnShow] is not allowed");
			}
		}
		doWindow(argumentCollection = arguments);
		writeOutput('<div id = "#attributes.name#">');
		if(not variables.hasEndTag){
			writeOutput('</div>');
		}
		return variables.hasEndTag;
	}
	public boolean function onEndTag(struct attributes, struct caller, string generatedContent) {
		writeOutput('#arguments.generatedContent#</div>');
		return false;
	}
	//doWindow
	public void function doWindow(struct attributes,struct caller) {
		var js = "";
		var rand = "_Lucee_Win_#randRange(1,99999999)#";
		var bind = getAjaxBinder().parseBind('url:' & attributes.source);
		bind['bindTo'] = attributes.name;
		bind['listener'] = "Lucee.Ajax.innerHtml";
		bind['errorHandler'] = attributes.onBindError;
		js &= "<script type='text/javascript'>";
		#rand#_on_Load = function() {
			if (len(attributes.source)){Lucee.Bind.register('#rand#',#serializeJson(bind)#,false);}
			js &= "Lucee.Window.create('#attributes.name#','#attributes.title#','#attributes.source#',{modal:#attributes.modal#,refreshOnShow:#attributes.refreshOnShow#,resizable:#attributes.resizable#,draggable:#attributes.draggable#,width:#attributes.width#,height:#attributes.height#,minWidth:#attributes.minWidth#,minHeight:#attributes.minHeight#,initShow:#attributes.initShow#,x:#attributes.x#,y:#attributes.y#,buttons:#attributes.buttons#};";
			if (len(attributes.source)){,'#rand#'};
		}		
		js &= "Lucee.Events.subscribe(#rand#_on_Load,'onLoad');</script>";
		writeHeader(js,'#rand#');
	}
	// Private 
	// getAjaxBinder
	private ajaxBinder function getAjaxBinder() {
		return variables.instance.ajaxBinder;
	}
}