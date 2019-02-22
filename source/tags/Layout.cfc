component extends="lucee.core.ajax.AjaxBase" output="no"  {
	
	variables._SUPPORTED_JSLIB = 'jquery';
	variables.supported_types = 'tab'; 
	variables.children = [];
	variables.instance.ajaxBinder = createObject('component','lucee.core.ajax.AjaxBinder').init();
	
	<!--- Meta data --->
	this.metadata.attributetype="fixed";
	this.metadata.hint="";
    this.metadata.attributes={
		type:			{required:true,type:"string",hint=""},
		name:			{required:false,type:"string",default:"_cf_layout_#randRange(1,999999999)#",hint=""},
		style:      	{required:false,type:"string",default:"",hint=""},
		jsLib:  		{required:false,type:"string",default:"jquery",hint=""},
		
		/* tab only */
		tabHeight : 	{required:false,type:"numeric",default:50,hint=""},
		tabsselect :	{required:false,type:"string",default:"",hint=""},
		tabsadd : 		{required:false,type:"string",default:"",hint=""},
		tabsremove :	{required:false,type:"string",default:"",hint=""},
		tabsenable :	{required:false,type:"string",default:"",hint=""},
		tabsdisable : 	{required:false,type:"string",default:"",hint=""},
		tabsload : 		{required:false,type:"string",default:"",hint=""}
	}

	public function init(required boolean hasEndTag, component parent )returntype="void"{
		var js = "";
		variables.hasEndTag = arguments.hasEndTag;
		<!---Cflayout cannot be empty --->
		if (not variables.hasEndTag){
			throw (message="Tag cflayout must have at least one cflayoutarea child tag.");
		}
		super.init();
	}
	
	public function onStartTag(struct attributes,struct caller)output="yes" returntype="boolean" {
		
		var js = "";
		variables.attributes = arguments.attributes;

		<!--- be sure library is supported ( if not we do not have resources to load ) --->
		if (listfind(variables._SUPPORTED_JSLIB,attributes.jsLib) eq 0){

			throw( message="The js library [#attributes.jsLib#] is not supported for tag CFLAYOUT. Supported libraries are [#variables._SUPPORTED_JSLIB#]");
		}

		if (listFindNoCase(variables.supported_types,attributes.type) eq 0){

			throw( message="type [#attributes.type#] is not a valid value. Valid types are are : #variables.supported_types#");
		}
		
		<!--- do Attributes Check --->
		doAttributesCheck(attributes);
		
		<!--- Load Resources --->
		if( not structKeyExists(request,'Lucee_Ajax_Layout_#attributes.type#')){

		savecontent variable="js"{
			<script type='text/javascript'>Lucee.Ajax.importTag('CFLAYOUT-#uCase(attributes.type)#','#attributes.jsLib#');</script>
		}
		htmlhead text="#js#";
		request['Lucee_Ajax_Layout_#attributes.type#'] = 'loaded';
		}
	    return variables.hasEndTag;
	}

	public any function onEndTag(struct attributes,struct caller,string generatedContent)returntype="boolean" {
		silent{
			var children = getChildren();
			var style = attributes.style;

			<!--- Cflayout cannot be empty --->
			if (arrayIsEmpty(children)){
				throw (message="Tag cflayout must have at least one cflayoutarea child tag.");
			}
		}
		switch(attributes.type)       
			case "tab":
				tab = dotab(argumentCollection = arguments);
				break;
			writeOutput("<div id="#attributes.name#" style="#style#">#tab##</div>");
		return false;
	}

	public function doBind(struct attributes,struct caller)returntype="void" {
		silent{
			var js = "";
			var bind = getAjaxBinder().parseBind(attributes.bind);
			if (not structKeyExists(attributes,'id') or not len(trim(attributes.id))){
				attributes.id = 'lucee_#randRange(1,99999999)#';
			}
			bind['bindTo'] = attributes.id ;
			bind['listener'] = "Lucee.Ajax.innerHtml";
			bind['errorHandler'] = attributes.onBindError;
			rand = "_Lucee_Bind_#randRange(1,99999999)#";
		}
		savecontent variable="js"{
			writeOutput("
				<script type='text/javascript'>
					#rand# = function(){
						Lucee.Bind.register('#attributes.id#',#serializeJson(bind)#,#attributes.bindOnLoad#);
					}		
					Lucee.Events.subscribe(#rand#,'onLoad');	
				</script>	
			")
			writeHeader(js,'#rand#');
		}
		<!--- Private --->	
		<!--- getAjaxBinder --->

		public function getAjaxBinder()output="false" returntype="ajaxBinder" access="private" {
			return variables.instance.ajaxBinder;
		}
	}
}	