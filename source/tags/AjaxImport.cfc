component extends = "lucee.core.ajax.AjaxBase" output = "no"  {
	variables.tags = 'CFAJAXPROXY,CFDIV,CFWINDOW,CFMAP,CFMENU';
	//Meta data
    this.metadata.hint = "Controls the JavaScript files that are imported for use on pages that use Luceex AJAX tags and features.";
	this.metadata.attributetype = "fixed";
    this.metadata.attributes = {
		scriptSrc:	{required:false,type:"string",default:"",hint = "Specifies the URL, relative to the web root, of the directory that contains the JavaScript files used used by Lucee."},
		tags:       {required:false,type:"string",default:"",hint = "A comma-delimited list of tags or tag-attribute combinations for which to import the supporting JavaScript files on this page."},
		cssSrc:     {required:false,type:"string",default:"",hint = "Specifies the URL, relative to the web root, of the directory that contains the CSS files used by AJAX features"},
		adapter:    {required:false,type:"string",default:"",hint = ""},
		params :    {required:false,type:"struct",default:{},hint = ""}
	};
	/**
	* Invoked after tag is constructed.
	* @parent The parent cfc custom tag, if there is one.
	*/	
	public void function init(required boolean hasEndTag,component parent){}

	public boolean function onStartTag(struct attributes,struct caller) {
		var opts = {};
		// init the base ajax class
		if (len(attributes.scriptSrc)){
			opts['scriptSrc'] = attributes.scriptSrc; 
		}
		if (len(attributes.cssSrc)){
			opts['cssSrc'] = attributes.cssSrc; 
		}
		if (len(attributes.adapter)){
			opts['adapter'] = attributes.adapter;
		}
		// TODO: remove this when lucee bug is solved
		if(not structKeyExists(attributes,'params')){
			attributes.params = struct(); 
		}
		opts.params = attributes.params;
      	super.init(argumentCollection:opts);
		// check
		cfloop (list = "#attributes.tags#",index = "el"){
			if (listFindNoCase(variables.tags,el) eq 0){
				throw (message = "tag [#el#] is not a valid value. Valid tag names are [#variables.tags#]"); 
			}
		}
        doImport(argumentCollection = arguments);
        return false;
	}
	public void function doImport(struct attributes,struct caller) {
		var js = "";
		if (len(attributes.tags)){
			js &= "
				<script type='text/javascript'>;
			";
			cfloop (list='#attributes.tags#',index='el'){
				js &= "Lucee.Ajax.importTag('#el#')";
			};
			js &= "</script>";
			writeHeader(js,'_import_#el#');
		}
	}
}	