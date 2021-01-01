/***********************************************************************************************
 * @author           srnandan
 * @date             20/September/2019
 * @group            AirBP
 * @description      controller class used in aura component to display customized page layout
 *                   based on sobject

 * history
 * 20/September/2019  srnandan      Created 
 ************************************************************************************************/
public with sharing class AITM_PageLayoutForm {
    /**
     * @description gets Page Layout Metadata for the pagelayoutname, fields to be display passed
     * @param  pageLayoutName of type String
     * @param  fieldsArray of type String[]
     * @return PageLayout
     */
    @AuraEnabled
    public static PageLayout getPageLayoutMetadata(String pageLayoutName,String[] fieldsArray ) {
        
        List<String> componentNameList = new List<String>{pageLayoutName};
        if (String.isBlank(pageLayoutName)) {
            return new PageLayout();
        }

        List<Metadata.Metadata> layouts =  Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        

        if (layouts.size() == 1) {
            return new PageLayout((Metadata.Layout) layouts[0],fieldsArray);
        }
        return new PageLayout();
    }

    /**
     * @description page layout wrapper class
     */
    public inherited sharing class PageLayout {
        @AuraEnabled
        public List<PageLayoutSection> sections { get; set; }
        /**
         * @description default constructor
         */
        public PageLayout() {
            Sections = new List<PageLayoutSection>();
        }

        /**
         * @description overloaded constructor
         */
        public PageLayout(Metadata.Layout layout,String[] fieldsArray) {
            this();
			
            for (Metadata.LayoutSection section : layout.layoutSections) {
                if (section.style != Metadata.LayoutSectionStyle.CustomLinks) {   
                    sections.add(new PageLayoutSection(section,fieldsArray));
                }
            }
        }
    }
    
    /**
     * @description PageLayoutSection wrapper class
     */
    public inherited sharing class PageLayoutSection {
        @AuraEnabled
        public List<PageLayoutSectionColumn> columns { get; set; }

        @AuraEnabled
        public String label { get; set; }

        /**
         * @description overloaded constructor
         */
        public PageLayoutSection(Metadata.LayoutSection section,String[] fieldsArray) {
            columns = new List<PageLayoutSectionColumn>();
            label = section.label;

            for (Metadata.LayoutColumn column : section.layoutColumns) {
                columns.add(new PageLayoutSectionColumn(column,fieldsArray));
            }
			
        }
    }

    /**
     * @description PageLayoutSectionColumn wrapper class
     */
    public inherited sharing class PageLayoutSectionColumn {

        @AuraEnabled
        public List<PageLayoutField> fields { get; set; }

        /**
         * @description overloaded constructor
         */
        public PageLayoutSectionColumn(Metadata.LayoutColumn column,String[] fieldsArray) {
            fields = new List<PageLayoutField>();
            if (column.layoutItems == null) {
                return;
            }

            for (Metadata.LayoutItem item : column.layoutItems) {
                fields.add(new PageLayoutField(item,fieldsArray));
            }
			
        }
    }

    /**
     * @description PageLayoutField wrapper class
     */
    public inherited sharing class PageLayoutField {

        @AuraEnabled
        public String apiName { get; set; }
        /**
         * @description overloaded constructor
         */
        public PageLayoutField(Metadata.LayoutItem item,String[] fieldsArray) {
            if(fieldsArray.contains(item.field)){
                apiName = item.field;
            }
        }	
    }
}