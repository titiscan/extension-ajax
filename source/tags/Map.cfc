component name = "Map" extends = "mapping-tag.lucee.core.ajax.AjaxBase"{
	variables.instance._SUPPORTED_MAP_TYPES  = 'map,satellite,hybrid,terrain';
	variables.instance._SUPPORTED_TYPES_CONTROL  = 'none,basic,advanced';
	variables.instance._SUPPORTED_ZOOM_CONTROL  = 'none,small,large,large3d,small3d';
	variables.instance.ajaxBinder = createObject('component','mapping-tag.lucee.core.ajax.AjaxBinder').init();
	variables.children = [];
	// Meta data
	this.metadata.attributetype = "fixed";
	this.metadata.attributes = [
		"name":				{required:false,type:"string",default:"_cfmap_#randRange(1,9999999)#"},
		"onLoad" : 			{required:false,type:"string",default:""},
		"onNotFound" : 		{required:false,type:"string",default:""},
		"onError" :		 	{required:false,type:"string",default:""},
		"centerAddress" : 	{required:false,type:"string",default:""},
		"centerLatitude" : 	{required:false,type:"string",default:""},
		"centerLongitude" : 	{required:false,type:"string",default:""},
		"height" : 			{required:false,type:"numeric",default:400},
		"width" : 			{required:false,type:"numeric",default:400},
		"zoomLevel" :   		{required:false,type:"numeric",default:3},
		"overview"  :         {required:false,type:"boolean",default:false},
		"showScale"  :        {required:false,type:"boolean",default:false},	
		"type" :				{required:false,type:"string",default:"map"},
		"showCenterMarker" :  {required:false,type:"boolean",default:true},
		"markerWindowContent":{required:false,type:"string",default:""},
		"tip" :				{required:false,type:"string",default:""},
		"typeControl" : 		{required:false,type:"string",default:"basic"},
		"zoomControl" : 		{required:false,type:"string",default:"small"},
		"continuousZoom" :    {required:false,type:"boolean",default:true},
		"doubleClickZoom" :	{required:false,type:"boolean",default:true},
		"markerColor" : 	    {required:false,type:"string",default:''},
		"markerIcon" : 	    {required:false,type:"string",default:''}	
	];
	/** 
	* Invoked after tag is constructed.
	* @parent The parent cfc custom tag, if there is one.
	*/
	public void function init(required boolean hasEndTag, component parent) {
		var js = "";
		var str = {};
		var mappings = getPageContext().getApplicationContext().getMappings();
		variables.hasEndTag = arguments.hasEndTag;
		super.init();
		js &= ('
			<script type="text/javascript">
				Lucee.Ajax.importTag("CFMAP",null,"google","#variables.instance.LUCEEJSSRC#");
			</script>
		');
		writeHeader(js,'_cf_map_import');
	} 
	public boolean function onStartTag(struct attributes, struct caller) {
		variables.attributes = arguments.attributes;
		// checks
		if(attributes.centeraddress eq "" and (attributes.centerlatitude eq "" or attributes.centerlongitude eq "")){
			throw message = "Attributes [centeraddress] or  [centerlatitude and centerlongitude] are required.";
		}
		if(not listFindNoCase(variables.instance._SUPPORTED_TYPES_CONTROL,attributes.typecontrol)){
			throw message = "Attributes [typecontrol] supported values are [#variables.instance._SUPPORTED_TYPES_CONTROL#].";
		}
		if(not listFindNoCase(variables.instance._SUPPORTED_MAP_TYPES,attributes.type)){
			throw message = "Attributes [type] supported values are [#variables.instance._SUPPORTED_MAP_TYPES#].";
		}
		if(not listFindNoCase(variables.instance._SUPPORTED_ZOOM_CONTROL,attributes.zoomcontrol)){
			throw message = "Attributes [zoomcontrol] supported values are [#variables.instance._SUPPORTED_ZOOM_CONTROL#].";
		}
		if(len(attributes.markercolor) and len(attributes.markercolor) neq 6){
			throw message = "Attribute [markercolor] must be in hexadecimal format es : FF0000.";
		}
		writeOutput('<div id="#attributes.name#" style="height:#attributes.height#px;width:#attributes.width#px;"</div>');
		if(not variables.hasEndTag){ }
		return variables.hasEndTag;
	}
	public boolean function onEndTag(struct attributes,struct caller,string generatedContent) {
		doMap(argumentCollection = arguments);
		return false;	
	}
	//  children   
	public array function getChildren() {
		return variables.children;
	}
	//	addChild	
	public void function addChild(required mapitem child) {
		children = getchildren();
		children.add(arguments.child);
	}
	//   attributes   
	public struct function getAtttributes() {
		return variables.attributes;
	}
	public any function getAttribute(required string key) {
		return variables.attributes[key];
	}
	//doMap
	public void function doMap(struct attributes, struct caller) {
		var js = "";
		var rand = "_Lucee_Map_#randRange(1,99999999)#";
		var options = duplicate(attributes);
		var children = getChildren();
		structDelete(options,'name');
		js &= '<script type = "text/javascript">';
		#rand#_on_Load = function(){
			Lucee.Map.init('#attributes.name#',#this.serializeJsonSafe(options)#);
			cfloop (array = children,index='child'){
				js &= "Lucee.Map.addMarker('#attributes.name#',#serializeJsonSafe(child.getAtttributes())#)";
			}	
		}		
		js &= "Lucee.Events.subscribe(#rand#_on_Load,'onLoad');</script>";
		writeHeader(js,'#rand#');
	}
	private string function serializeJsonSafe(required str) {
		var rtn = {};
			cfloop (collection = str,item = "local.k") {
			rtn[lcase(k)] = str[k];
		}
		return serializeJson(rtn);
	}
}