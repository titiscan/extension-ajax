component name="LayoutArea"  {

	variables['generatedContent'] = "";
	<!--- Meta data --->
	this.metadata.attributetype="fixed";
    this.metadata.attributes=;
		name:      		{required:false,type:"string",default:"_cf_layout_#randRange(1,999999999)#"},
		title:     		{required:false,type:"string",default:""},
		selected : 		{required:false,type:"Boolean",default:"false"},
		disabled : 		{required:false,type:"Boolean",default:"false"},
		source:			{required:false,type:"string",default:""},
		onBindError:	{required:false,type:"string",default:""},
		refreshOnActivate: {required:false,type:"Boolean",default:"false"},
		style:			{required:false,type:"string",default:""},
		overflow:		{required:false,type:"string",default:"auto"}
	}

	public any function init(required boolean hasEndTag,component parent)output="no" returntype="void" {
		variables.hasEndTag = arguments.hasEndTag;
      	variables.parent = arguments.parent;
    }  

  	public function onStartTag(struct attributes,struct caller)output="yes" returntype="boolean" {
  		
  		var parent = getParent();
	 		variables.attributes = arguments.attributes;
	   			
			if( parent.getAttribute('type') eq 'tab' and attributes.title eq ""){
				throw( message="Attributes [title] is required for a tab layoutarea.");
			}
			<!--- If there is no end tag add the attributes to tee parent collection --->
			if (not variables.hasEndTag){
				parent.addChild(this);
			}
  			return variables.hasEndTag;
  	}
      	      	
  	public function onEndTag(struct attributes,struct caller, string generatedContent)output="yes" returntype="boolean" {
  		var parent = getParent();
	 	variables['generatedContent'] = arguments.generatedContent;
		parent.addChild(this);
		return false;
  	}

 	<!---   parent   --->
  	public function getparent()access="public" output="false" returntype="layout" {
  	 	return variables.parent;
  	}

  	<!---getGeneratedContent--->
  	public function getGeneratedContent(param) {
  	 	return variables.generatedContent;
  	}

  	<!---   attributes   --->
 	public function getAtttributes(param) {
 	 	return variables.atttributes;
 	}

 	public function getAttribute(required string key)output="false" access="public" returntype="any" {
 		return  variables.attributes[key];
 	}
}	
