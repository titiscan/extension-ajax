component extends = "lucee.core.ajax.AjaxBase" {
	variables._SUPPORTED_JSLIB = 'jquery';
	variables.supported_types = 'tab'; 
	variables.children = [];
	variables.instance.ajaxBinder = createObject('component','lucee.core.ajax.AjaxBinder').init();
	// Meta data
	this.metadata.attributetype = "fixed";
	this.metadata.hint = "";
	this.metadata.attributes = [
		"type":			{required:true, type:"string",hint=""},
		"name":			{required:false, type:"string",default:"_cf_layout_#randRange(1,999999999)#",hint=""},
		"style":		{required:false, type:"string",default:"",hint=""},
		"jsLib":  		{required:false, type:"string",default:"jquery",hint=""},
	/* tab only */
		"tabHeight" : 	{required:false, type:"numeric",default:50,hint=""},
		"tabsSelect" :	{required:false, type:"string",default:"",hint=""},
		"tabsAdd" : 		{required:false, type:"string",default:"",hint=""},
		"tabsRemove" :	{required:false, type:"string",default:"",hint=""},
		"tabsEnable" :	{required:false, type:"string",default:"",hint=""},
		"tabsDisable" : 	{required:false, type:"string",default:"",hint=""},
		"tabsLoad" : 		{required:false, type:"string",default:"",hint=""}
	];
	/**
	* Invoked after tag is constructed.
	* @parent The parent cfc custom tag, if there is one.
	*/
	public void function init(required boolean hasEndTag, component parent ){
		var js = "";
		variables.hasEndTag = arguments.hasEndTag;
		// cflayout cannot be empty
		if (not variables.hasEndTag){
			throw (message = "Tag cflayout must have at least one cflayoutarea child tag.");
		}
		super.init();
	}
	public boolean function onStartTag(struct attributes,struct caller) {
		var js = "";
		variables.attributes = arguments.attributes;
		// be sure library is supported ( if not we do not have resources to load ) 
		if (listfind(variables._SUPPORTED_JSLIB,attributes.jsLib) eq 0){
			throw( message="The js library [#attributes.jsLib#] is not supported for tag CFLAYOUT. Supported libraries are [#variables._SUPPORTED_JSLIB#]");
		}
		if (listFindNoCase(variables.supported_types,attributes.type) eq 0){
			throw( message="type [#attributes.type#] is not a valid value. Valid types are are : #variables.supported_types#");
		}
		// do Attributes Check 
		doAttributesCheck(attributes);
		// Load Resources 
		if( not structKeyExists(request,'Lucee_Ajax_Layout_#attributes.type#')){
			js &= ('
				<script type = "text/javascript">Lucee.Ajax.importTag("CFLAYOUT-#uCase(attributes.type)#","#attributes.jsLib#");</script>
			');
			htmlhead text = "#js#";
			request['Lucee_Ajax_Layout_#attributes.type#'] = 'loaded';
		}
		return variables.hasEndTag;
	}
	public boolean function onEndTag(struct attributes,struct caller,string generatedContent) {
		var children = getChildren();
		var style = attributes.style;
		// cflayout cannot be empty 
		if (arrayIsEmpty(children)){
			throw (message = "Tag cflayout must have at least one cflayoutarea child tag.");
		}
		switch(attributes.type) {
			case "tab":
			tab = dotab(argumentCollection = arguments);
		}
			writeOutput('<div id="#attributes.name#" style="#style#">#tab#</div>');
		return false;
	}
	// attributes 
	public struct function getAtttributes() {
		return variables.Atttributes;
	}
	public any function getAttribute(required string key) {
		return variables.attributes[key];
	}
	// children
	public array function getChildren() {
		return variables.children;
	}
	// addChild
	public void function addChild(required layoutarea child) {
		children = getchildren();
		children.add(arguments.child);
	}
	// private
	// doAttributesCheck
	private void function doAttributesCheck(struct attributes) {
		switch( attributes.type){
			case "tab":
			break;
		}
	}
	private string function doTab(struct attributes,struct caller, string generatedContent) {
		js = "";
		var tab = "";
		var rand = "_Lucee_Layout_#randRange(1,99999999)#";
		var selected = "";
		var disabled = "" ;
		var binds = [];
		var bind = {};
		var options = [];
		var opt = {};
		var layoutOptions = {};
		 // make the html
		tab &= '<ul></ul>'
			cfloop (array = getChildren(),index = 'child'){
				tab &= '<div id="#child.getAttribute('name')#">#child.getGeneratedContent()#</div>';
			}
		// append js to head
		js &= '<script type="text/javascript">
		_cf_layout_#rand# = function() {
			Lucee.Layout.initializeTabLayout("#attributes.name#",#serializeJson(attributes)#);'
			cfloop (array = getChildren(),index = 'child'){
				var randArea = 'cf_layout_tab_bind_#randRange(1,99999999)#';
				if (len(child.getAttribute('source'))){
					var	bind = {};
					var	bind = getAjaxBinder().parseBind('url:' & child.getAttribute('source'));
					var	bind['bindTo'] = child.getAttribute('name');	
					var	bind['listener'] = 'Lucee.Ajax.innerHtml';
					var	bind['errorHandler'] = child.getAttribute('onBindError');
				}
				var	opt = {};
				var	opt['refreshOnActivate'] = child.getAttribute('refreshOnActivate');
				var	opt['selected'] = child.getAttribute('selected');
				var	opt['disabled'] = child.getAttribute('disabled');
				var	opt['overflow'] = child.getAttribute('overflow');
				var	opt['style'] = '#child.getAttribute('style')#';
				var	opt['tabHeight'] = attributes.tabHeight;
				if (len(child.getAttribute('source'))){
					var opt['bind'] = '#randArea#';
				}	
				if (len(child.getAttribute('source'))){
					js &= "Lucee.Bind.register('#randArea#',#serializeJson(bind)#,false);";
				}
				js &= "Lucee.Layout.createTab('#attributes.name#','#child.getAttribute("name")#','#child.getAttribute("title")#','',#serializeJson(opt)#);";					
			}
		
		js &= "}
		Lucee.Events.subscribe(_cf_layout_#rand#,'onLoad');
		</script>";
		writeHeader(js,'_cf_layout_#rand#')
		return stripwhitespace(tab);
	}
	// getAjaxBinder
	private ajaxBinder function getAjaxBinder() {
		return variables.instance.ajaxBinder;
	}
}