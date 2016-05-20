public class JobSearch {
    
    public list<Job_Search_Fields__c> jsFields {get; set;}
    public String inputFieldsHTML {get; set;}
    public Job_Search_Pagination_Fields__c settingPaginationDetails{get; set;}
    public ProfileDomainName__c profileDomainCustomSetting {get; set;}
    public String profileDomain{ get; set; }
    //public String jsonDomainName { get; set; }
    public String jsonStrPageDetails {get; set;}
    public Community_Web_Content__c communityWebContent{get; set;}

    public JobSearch() {
        jsFields = queryCustomSetting();
        inputFieldsHTML = createInputFieldsHTML(jsFields);
        settingPaginationDetails = Job_Search_Pagination_Fields__c.getall().values().get(0);
        jsonStrPageDetails = JSON.serialize(settingPaginationDetails);
        //profileDomain = ProfileDomainName__c.getall().values().get(0);
        profileDomainCustomSetting = UtilityGeneral.getProfileDomainName();
        profileDomain = profileDomainCustomSetting.DomainName__c;
        
         //Static section
        communityWebContent = new Community_Web_Content__c();
        communityWebContent = UtilityGeneral.getWebContent(ApexPages.CurrentPage().getUrl());
    }

    public list<Job_Search_Fields__c>  queryCustomSetting()
    {
        return [select Id, Name, Field_Label__c, Field_Name__c, Field_Order__c, Section_Label__c, 
            Section_Order__c, Field_Type__c, Picklist_Values__c 
            from Job_Search_Fields__c order by Section_Order__c, Field_Order__c];
    }

    public String createFieldHTML(String fieldType, String fieldName, String fieldLabel, String pickListValues)
    {
        String html = '';
        if(fieldType=='picklist')
        {
            html = '<div class="ds_inputFieldWrapper"><div class="ds_inputField">';
            html = html + '<select id="'+fieldName+'" name="'+fieldName+'">';
            html = html + '<option value="">'+fieldLabel+'</option>';
            for(String value : pickListValues.split(';'))
            {
                html = html + '<option value="'+value+'">'+value+'</option>';
            }
            html = html + '</select></div></div>';
        }
        else if(fieldType=='checkbox')
        {
            html = '<div class="ds_inputFieldWrapper"><div class="ds_inputField"><input id="'+fieldName+'" type="checkbox" name="'+fieldName+'" /><span class="ds_inputFielLabel">'+fieldLabel+'</span></div></div>';
        }
        else
        {
            html = '<div class="ds_inputFieldWrapper"><div class="ds_inputField"><input id="'+fieldName+'" type="text" name="'+fieldName+'" placeholder="'+fieldLabel+'"/></div></div>';
        }

        return html;
    }

    public String createInputFieldsHTML(list<sObject> fields)
    {
        
        String html = '';
        Boolean firstTime = true;
        Boolean firstSection = true;
        String oldSectionOrder = '';
        for(sObject field : fields)
        {
            String picklistValuesString = String.ValueOf(field.get('Picklist_Values__c'));
            if(String.ValueOf(field.get('Picklist_Values__c'))!=null && 
               String.ValueOf(field.get('Picklist_Values__c')).startsWith('Community_Web_Content__c.'))
            {
                picklistValuesString = CommunityContentHelper.getContent(String.ValueOf(field.get('Picklist_Values__c')));
            }

            String inputFiledHTML = createFieldHTML(String.ValueOf(field.get('Field_Type__c')), String.ValueOf(field.get('Field_Name__c')), String.ValueOf(field.get('Field_Label__c')), picklistValuesString);
            if(firstTime)
            {
                html = html + '<div class="firstSection"><div class="ds_header">Job Search</div><div>';
                oldSectionOrder = String.ValueOf(field.get('Section_Order__c'));
                firstTime = false;
            }
            if(oldSectionOrder==String.ValueOf(field.get('Section_Order__c')))
            {
                html = html + inputFiledHTML;
            }
            if(firstSection && oldSectionOrder!=String.ValueOf(field.get('Section_Order__c')))
            {
                html = html + '</div><div class="ds_buttons"><input type="button" value="Search" onClick="acfsObj.runSearch(0,0)"></input><a onClick="acfsObj.clearfields()">Clear All</a></div></div><div class="ds_Collapsible"><div class="ds_SectionHeader"><h2>'+String.ValueOf(field.get('Section_Label__c'))+'</h2></div><div>'+inputFiledHTML;
                firstSection = false;
            }
            else if(!firstSection && oldSectionOrder!=String.ValueOf(field.get('Section_Order__c')))
            {
                html = html + '</div></div><div class="ds_Collapsible"><div class="ds_SectionHeader"><h2>'+String.ValueOf(field.get('Section_Label__c'))+'</h2></div><div>'+inputFiledHTML;
            }
            oldSectionOrder = String.ValueOf(field.get('Section_Order__c'));
        }
        html = html + '</div></div>';
        return html;
    } 
}