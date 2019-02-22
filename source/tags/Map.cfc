component name="Map" extends="mapping-tag.lucee.core.ajax.AjaxBase"{
	variables.instance._SUPPORTED_MAP_TYPES  = 'map,satellite,hybrid,terrain';
	variables.instance._SUPPORTED_TYPES_CONTROL  = 'none,basic,advanced';
	variables.instance._SUPPORTED_ZOOM_CONTROL  = 'none,small,large,large3d,small3d';
	variables.instance.ajaxBinder = createObject('component','mapping-tag.lucee.core.ajax.AjaxBinder').init();
	variables.children = [];
	<!--- Meta data --->
	this.metadata.attributetype="fixed";
	this.metadata.attributes={
		name:				{required:false,type:"string",default:"_cfmap_#randRange(1,9999999)#"},
		onLoad : 			{required:false,type:"string",default:""},
		onNotFound : 		{required:false,type:"string",default:""},
		onError :		 	{required:false,type:"string",default:""},
		centeraddress : 	{required:false,type:"string",default:""},
		centerlatitude : 	{required:false,type:"string",default:""},
		centerlongitude : 	{required:false,type:"string",default:""},
		height : 			{required:false,type:"numeric",default:400},
		width : 			{required:false,type:"numeric",default:400},
		zoomlevel :   		{required:false,type:"numeric",default:3},
		overview  :         {required:false,type:"boolean",default:false},
		showscale  :        {required:false,type:"boolean",default:false},
		type :				{required:false,type:"string",default:"map"},
		showcentermarker :  {required:false,type:"boolean",default:true},
		markerwindowcontent:{required:false,type:"string",default:""},
		tip :				{required:false,type:"string",default:""},
		typecontrol : 		{required:false,type:"string",default:"basic"},
		zoomcontrol : 		{required:false,type:"string",default:"small"},
		continuouszoom :    {required:false,type:"boolean",default:true},
		doubleclickzoom :	{required:false,type:"boolean",default:true},
		markercolor : 	    {required:false,type:"string",default:''},
		markericon : 	    {required:false,type:"string",default:''}
	};
	 
	public function init(required boolean hasEndTag, component parent) output="no" returntype="void"{
		var js = "";
		var str = {};
		var mappings = getPageContext().getApplicationContext().getMappings();
				
		variables.hasEndTag = arguments.hasEndTag;
		super.init();
		savecontent variable="js"{
			writeOutput('<script type="text/javascript">
				Lucee.Ajax.importTag("CFMAP",null,"google","#variables.instance.LUCEEJSSRC#");
				</script>
				');
		}
		writeHeader(js,'_cf_map_import');
	} 
	
	public function onStartTag(struct attributes, struct caller) output="yes" returntype="boolean"{
		variables.attributes = arguments.attributes;
		<!--- checks --->
		if(attributes.centeraddress eq "" and (attributes.centerlatitude eq "" or attributes.centerlongitude eq "")){
			throw message="Attributes [centeraddress] or  [centerlatitude and centerlongitude] are required.";
		}

		if(not listFindNoCase(variables.instance._SUPPORTED_TYPES_CONTROL,attributes.typecontrol)){
			throw message="Attributes [typecontrol] supported values are [#variables.instance._SUPPORTED_TYPES_CONTROL#].";
		}

		if(not listFindNoCase(variables.instance._SUPPORTED_MAP_TYPES,attributes.type)){
			throw message="Attributes [type] supported values are [#variables.instance._SUPPORTED_MAP_TYPES#].";
		}

		if(not listFindNoCase(variables.instance._SUPPORTED_ZOOM_CONTROL,attributes.zoomcontrol)){
			throw message="Attributes [zoomcontrol] supported values are [#variables.instance._SUPPORTED_ZOOM_CONTROL#].";
		}
		
		if(len(attributes.markercolor) and len(attributes.markercolor) neq 6){
			throw message="Attribute [markercolor] must be in hexadecimal format es : FF0000.";
		}
		
		writeOutput("<div id='#attributes.name#' style='height:#attributes.height#px;width:#attributes.width#px'</div>");
		
		if(not variables.hasEndTag){
			
		}
		return variables.hasEndTag;
	}

	public function onEndTag(struct attributes,struct caller,string generatedContent) output="yes" returntype="boolean"{
		doMap(argumentCollection=arguments);
		return false;	
	}
	<!---  children   --->
	public function getChildren() access="public" output="false" returntype="array"{
		return variables.children;
	}
	<!---	addChild	--->
	public function addChild(required mapitem child) output="false" access="public" returntype="void"{
		children = getchildren();
		children.add(arguments.child);
	}
	<!---   attributes   --->
	public function getAtttributes() access="public" output="false" returntype="struct"{
		return variables.attributes;
	}

	public function getAttribute(required string key) output="false" access="public" returntype="any"{
		return variables.attributes[key];
	}
	<!---doMap--->		   
	public function doMap(struct attributes, struct caller) output="no" returntype="void"{
		var js = "";
		var rand = "_Lucee_Map_#randRange(1,99999999)#";
		
		var options = duplicate(attributes);
		var children = getChildren();
		structDelete(options,'name');
		savecontent variable="js"{writeOutput("
		<script type="text/javascript">
		#rand#_on_Load = function(){
			Lucee.Map.init('#attributes.name#',#this.serializeJsonSafe(options)#);
			<cfloop array="#children#" index="child">Lucee.Map.addMarker('#attributes.name#',#serializeJsonSafe(child.getAtttributes())#);</cfloop>
		}		
		Lucee.Events.subscribe(#rand#_on_Load,'onLoad');
		</script>
		");}
		writeHeader(js,'#rand#');
	}
	public function serializeJsonSafe(required str) output="false" access="private" returntype="string"{
		 var rtn={};
			 loop collection="#str#" item="local.k" {
			 rtn[lcase(k)]=str[k];
		}
		return serializeJson(rtn);
	}
}