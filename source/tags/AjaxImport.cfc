component extends="lucee.core.ajax.AjaxBase" output="no"  {
	
	variables.tags = 'CFAJAXPROXY,CFDIV,CFWINDOW,CFMAP,CFMENU';
	
	<!--- Meta data --->
    this.metadata.hint="Controls the JavaScript files that are imported for use on pages that use Luceex AJAX tags and features.";
	this.metadata.attributetype="fixed";
    this.metadata.attributes={
		scriptSrc:	{required:false,type:"string",default:"",hint="Specifies the URL, relative to the web root, of the directory that contains the JavaScript files used used by Lucee."},
		tags:       {required:false,type:"string",default:"",hint="A comma-delimited list of tags or tag-attribute combinations for which to import the supporting JavaScript files on this page."},
		cssSrc:     {required:false,type:"string",default:"",hint="Specifies the URL, relative to the web root, of the directory that contains the CSS files used by AJAX features"},
		adapter:    {required:false,type:"string",default:"",hint=""},
		params :    {required:false,type:"struct",default:{},hint=""}
	}

	public function init(required boolean hasEndTag,component parent)returntype="void" hint="invoked after tag is constructed" {
		return;
	}

	public function onStartTag(struct attributes,struct caller)returntype="boolean" {
		silent{
			var opts = {};
			<!--- init the base ajax class --->
			if (len(attributes.scriptSrc)){
				opts['scriptSrc'] = attributes.scriptSrc; 
			}
			if (len(attributes.cssSrc)){
				opts['cssSrc'] = attributes.cssSrc; 
			}
			if (len(attributes.adapter)){
				opts['adapter'] = attributes.adapter;
			}
			<!--- TODO: remove this when lucee bug is solved --->
			if( not structKeyExists(attributes,'params')){
				attributes.params = struct(); 
			}
			opts.params = attributes.params;
		}	
      	super.init(argumentCollection:opts);
      	silent{
			<!--- check --->
			loop list="#attributes.tags#",index="el"{
				if (listFindNoCase(variables.tags,el) eq 0){
					throw (message="tag [#el#] is not a valid value. Valid tag names are [#variables.tags#]"); 
				}
			}
      	}
        doImport(argumentCollection=arguments);
        return false;
	}

	public function doImport(struct attributes,struct caller) {
		<!---
		---->var js = "";
		if (len(attributes.tags)){
			savecontent variable="js"{
				writeOutput("
					<script type='text/javascript'>
					<cfloop list='#attributes.tags#' index='el'>
						Lucee.Ajax.importTag('#el#');
					</cfloop>
					</script>	
				")
			}	
		}
	}
}	