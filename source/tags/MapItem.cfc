component name = "Mapitem"{
	// Meta data 
	this.metadata.attributetype = "fixed";
	this.metadata.attributes = {
		name:      	    {required:false,type:"string",default:""},
		address:      	{required:false,type:"string",default:""},
		latitude:     	{required:false,type:"string",default:""},
		longitude : 	{required:false,type:"string",default:""},
		tip:		    {required:false,type:"string",default:""},
		markerwindowcontent:	{required:false,type:"string",default:""},
		markercolor : 	    {required:false,type:"string",default:''},
		markericon : 	    {required:false,type:"string",default:''}
	};
	/**
	* Invoked after tag is constructed
	* @parent The parent cfc custom tag, if there is one.
	*/
	public void function init(required boolean hasEndTag, component parent) {
		variables.hasEndTag = arguments.hasEndTag;
		variables.parent = arguments.parent;
	}
	public boolean function onStartTag(struct attributes,struct caller) {
		var parent = getParent();
		variables.attributes = arguments.attributes;
		if(not len(attributes.address) and (not len(attributes.latitude) or not len(attributes.longitude))){
			throw (message = "Attributes [address] is required if [longitude and latitude] are not provided.");
		}
		// if name is not passed use the parent one 
		if(not len(attributes.name)){
			attributes.name = parent.getAttribute('name');
		}
		// If there is no end tag add the attributes to tee parent collection 
		parent.addChild(this);
		return variables.hasEndTag;
	}
	// parent   
	public map function getparent() {
		return variables.parent;
	}
	// attributes   
	public struct function getAtttributes() {
		return variables.attributes;
	}
	public any function getAttribute(required string key) {
		return variables.attributes[key];
	}
}