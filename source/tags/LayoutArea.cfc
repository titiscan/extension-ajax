component name = "LayoutArea"  {
	variables['generatedContent'] = "";
	// Meta data
	this.metadata.attributetype = "fixed";
    this.metadata.attributes = {
		name:      		{required:false,type:"string",default:"_cf_layout_#randRange(1,999999999)#"},
		title:     		{required:false,type:"string",default:""},
		selected : 		{required:false,type:"Boolean",default:"false"},
		disabled : 		{required:false,type:"Boolean",default:"false"},
		source:			{required:false,type:"string",default:""},
		onBindError:	{required:false,type:"string",default:""},
		refreshOnActivate: {required:false,type:"Boolean",default:"false"},
		style:			{required:false,type:"string",default:""},
		overflow:		{required:false,type:"string",default:"auto"}
	};
	/**
	* Invoked after tag is constructed
	* @parent The parent cfc custom tag, if there is one.
	*/
	public void function init(required boolean hasEndTag,component parent) {
		variables.hasEndTag = arguments.hasEndTag;
      	variables.parent = arguments.parent;
    }  
  	public boolean function onStartTag(struct attributes,struct caller) {
  		var parent = getParent();
 		variables.attributes = arguments.attributes;
		if( parent.getAttribute('type') eq 'tab' and attributes.title eq "") {
			throw( message = "Attributes [title] is required for a tab layoutarea.");
		}
		// If there is no end tag add the attributes to tee parent collection.
		if (not variables.hasEndTag){
			parent.addChild(this);
		}
		return variables.hasEndTag;
  	}
  	public boolean function onEndTag(struct attributes,struct caller, string generatedContent) {
  		var parent = getParent();
	 	variables['generatedContent'] = arguments.generatedContent;
		parent.addChild(this);
		return false;
  	}
 	// parent   
  	public layout function getparent() {
  	 	return variables.parent;
  	}
  	// getGeneratedContent
  	public string function getGeneratedContent() {
  	 	return variables.generatedContent;
  	}
  	// attributes   
 	public struct function getAtttributes() {
 	 	return variables.atttributes;
 	}
 	public any function getAttribute(required string key) {
 		return  variables.attributes[key];
 	}
}	
