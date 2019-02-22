component name="Mapitem"{
	<!--- Meta data --->
	this.metadata.attributetype="fixed";
	this.metadata.attributes={
		name:      	    {required:false,type:"string",default:""},
		address:      	{required:false,type:"string",default:""},
		latitude:     	{required:false,type:"string",default:""},
		longitude : 	{required:false,type:"string",default:""},
		tip:		    {required:false,type:"string",default:""},
		markerwindowcontent:	{required:false,type:"string",default:""},
		markercolor : 	    {required:false,type:"string",default:''},
		markericon : 	    {required:false,type:"string",default:''}
	};
	public function init(required boolean hasEndTag, component parent) output="no" returntype="void"{
		variables.hasEndTag = arguments.hasEndTag;
		variables.parent = arguments.parent;
	}
	public function onStartTag(struct attributes,struct caller) output="yes" returntype="boolean"{
		var parent = getParent();
		variables.attributes = arguments.attributes;
		if(not len(attributes.address) and (not len(attributes.latitude) or not len(attributes.longitude))){
			throw message="Attributes [address] is required if [longitude and latitude] are not provided.";
		}
		<!--- if name is not passed use the parent one ---> 
		if(not len(attributes.name)){
			attributes.name = parent.getAttribute('name');
		}
		<!--- If there is no end tag add the attributes to tee parent collection --->
		parent.addChild(this);
		return variables.hasEndTag;
	}
	<!---   parent   --->
	public function getparent() output="false" returntype="map"{
		return variables.parent;
	}
	<!---   attributes   --->
	public function getAtttributes() access="public" output="false" returntype="struct"{
		return variables.attributes;
	}
	public function getAttribute(required string key) output="false" access="public" returntype="any"{
		return variables.attributes[key];
	}
}