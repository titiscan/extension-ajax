component extends = "lucee.core.ajax.AjaxBase" output = "no" {
	variables.instance.ajaxBinder = createObject('component','lucee.core.ajax.AjaxBinder').init();
	// Meta data
    this.metadata.hint = "Creates an HTML tag with specified contents and lets you to use bind expressions to dynamically control the tag contents.";
	this.metadata.attributetype = "fixed";
    this.metadata.attributes = {
		id:			{required:false,type:"string",default:"",hint = "The HTML ID attribute value to assign to the generated container tag."},
		bindOnLoad: {required:false,type:"boolean",default:true,hint = "- true (executes the bind attribute expression when first loading the tag. 
		- false (does not execute the bind attribute expression until the first bound event)
		To use this attribute, you must also specify a bind attribute"},
		bind:		{required:false,type:"string",hint = "A bind expression that returns the container contents. Note: If a CFML page specified in this attribute contains tags that use AJAX features, such as cfform, cfgrid, and cfwindow, you must use a tag on the page with the tag. For more information, see cfajaximport."},
		onBindError:{required:false,type:"string",default:"",hint = "The name of a JavaScript function to execute if evaluating a bind expression results in an error. The function must take two attributes: an HTTP status code and a message."},
		tagName:	{required:false,type:"string",default:"div",hint = "The HTML container tag to create."}
	};
	/**
	* Invoked after tag is constructed.
	* @parent The parent cfc custom tag, if there is one.
	*/
	public void function init(required boolean hasEndTag,component parent){
		variables.hasEndTag = arguments.hasEndTag;
		super.init();
	}
	public boolean function onStartTag(struct attributes, struct caller) {
		// check 
    	var hasBindError = len(trim(attributes.onBindError));
        if( hasBindError){
        	if (IsDefined("attributes.bind") and not len(trim(attributes.bind))){
        		throw( message = "in this context attribute [onBindError] is not allowed");
        	}
        }
        // Don't bind if the argument is not provided, just render the tag.
		// Function doBind will validate the bind expression if provided.
        if (IsDefined("attributes.bind")){
        	doBind(argumentCollection = arguments);
		}
		writeOutput('<#attributes.tagname# id="#attributes.id#">');
		if( not variables.hasEndTag){
			writeOutput('</#attributes.tagname#>');
		}
	    return variables.hasEndTag;
	}
	public boolean function onEndTag(struct attributes,struct caller, string generatedContent){
		writeOutput('#arguments.generatedContent# </#attributes.tagname#>;');
		return false;
	}
	public void function doBind(struct attributes,struct caller){
		var js = "";
		var bind = getAjaxBinder().parseBind(attributes.bind);
		if(not structKeyExists(attributes,'id') or not len(trim(attributes.id))){
			attributes.id = 'lucee_#randRange(1,99999999)#';
		}
		bind['bindTo'] = attributes.id;
		bind['listener'] = "Lucee.Ajax.innerHtml";
		bind['errorHandler'] = attributes.onBindError;
		rand = "_Lucee_Bind_#randRange(1,99999999)#";
		js="<script type='text/javascript'>"
		#rand# = function(){
			js &= "Lucee.Bind.register('#attributes.id#',#serializeJson(bind)#,#attributes.bindOnLoad#)";
		}		
		js &= "Lucee.Events.subscribe(#rand#,'onLoad');</script>";
		writeHeader(js,'#rand#');
	}
	// Private
	// getAjaxBinder
	private ajaxBinder function getAjaxBinder() {
		return variables.instance.ajaxBinder;
	}
}
