public with sharing class TC_ConnectToOrgController {
    
    public static Map<String, Object> errorMap;
    
    /*
     * @method: getGroupList
     * @param : NA
     * @lastModified :Aman Daseda/20-Jan-2020
     * @Description: This method is use to get details of adminified usergroup
     * @return: Map<String,Object> resultMap
     */
    @AuraEnabled
    public static Map<String, Object> getGroupList() {
        Map<String, Object> resultMap = new Map<String, Object>();
        errorMap = new Map<String, Object>();
        
        try {
            List<TC_Adminified_UserGroup__c> groupList = [
                SELECT Id, TC_Group_Name__c, TC_Named_Credential__c, TC_Adminified_Organisation__c, 
                       TC_Adminified_User__c, TC_User_Organization_Name__c, TC_Is_Named_Credential__c
                FROM TC_Adminified_UserGroup__c 
                ORDER BY TC_Group_Name__c
            ];
            
            List<String> groupNames = new List<String>();
            for (TC_Adminified_UserGroup__c groups : groupList) {
                if (String.isNotBlank(groups.TC_Group_Name__c)) {
                    groupNames.add(groups.TC_Group_Name__c);
                }
            }
            
            // Add default groups if no custom groups exist
            if (groupNames.isEmpty()) {
                groupNames.add('Default Group');
                groupNames.add('Sales Group');
                groupNames.add('Support Group');
                groupNames.add('Admin Group');
            }
            
            resultMap.put('status', 'success');
            resultMap.put('message', 'Groups retrieved successfully');
            resultMap.put('data', groupNames);
            
        } catch (Exception ex) {
            resultMap.put('status', 'fail');
            resultMap.put('message', 'Error retrieving groups: ' + ex.getMessage());
            resultMap.put('data', new List<String>{'Default Group', 'Sales Group', 'Support Group', 'Admin Group'});
            errorMap.put('message', ex.getMessage());
            errorMap.put('cause', ex.getCause());
            errorMap.put('lineNumber', ex.getLineNumber());
            errorMap.put('typeName', ex.getTypeName());
            errorMap.put('stackTraceString', ex.getStackTraceString());
            errorMap.put('origin', 'tc_getGroupList');
            errorMap.put('is_FrontEnd', false);
            errorMap.put('className', 'TC_ConnectToOrgController');
            errorMap.put('methodName', 'getGroupList()');
        }
        
        return resultMap;
    }
    
    /*
     * @method: addNewOrganization
     * @param : String namedCredential, String orgType,String orgAlias,String groupName
     * @lastModified :Aman Daseda/20-Jan-2020
     * @Description: This method is use to add new adminified org
     * @return:  Map<String,Object> resultMap
     */
    @AuraEnabled
    public static Map<String, Object> addNewOrganization(String namedCredential, String orgType, String orgAlias, String groupName) {
        Map<String, Object> resultMap = new Map<String, Object>();
        errorMap = new Map<String, Object>();
        String orgId = '';
        Boolean alreadyExist = false;
        String getOrgId = '';
        String namespace = '';
        
        try {
            // Validate input parameters
            if (String.isBlank(namedCredential) || String.isBlank(orgType) || String.isBlank(orgAlias) || String.isBlank(groupName)) {
                resultMap.put('status', 'fail');
                resultMap.put('message', 'Please fill all required details');
                resultMap.put('data', null);
                errorMap.put('status', 'fail');
                errorMap.put('userMessage', 'Please fill all required details');
                return resultMap;
            }
            
            // Get company information
            Map<String, Object> resultObj = TC_Util.getCompanyInformationByNamedCredential(namedCredential);
            if (resultObj != null && resultObj.get('status') == 'success') {
                getOrgId = String.valueOf(resultObj.get('getOrgId'));
                if (resultObj.get('namespace') != null) {
                    namespace = String.valueOf(resultObj.get('namespace'));
                }
            }
            
            // Check if organization already exists
            List<TC_Adminified_Organization__c> orgList = [
                SELECT Id, TC_Organization_ID__c 
                FROM TC_Adminified_Organization__c 
                WHERE TC_Organization_ID__c = :getOrgId 
                LIMIT 1
            ];
            
            if (orgList != null && orgList.size() > 0) {
                orgId = orgList[0].Id;
                List<TC_Snapshot__c> snapshot = [
                    SELECT Id, TC_Adminified_Organization__c 
                    FROM TC_Snapshot__c 
                    WHERE TC_Adminified_Organization__c = :orgList[0].Id 
                    LIMIT 1
                ];
                if (snapshot != null && snapshot.size() > 0) {
                    alreadyExist = true;
                }
            } else {
                // Create new organization
                TC_Adminified_Organization__c admnOrg = new TC_Adminified_Organization__c();
                admnOrg.TC_Organization_Type__c = orgType;
                admnOrg.TC_Organization_ID__c = getOrgId;
                
                insert admnOrg;
                orgId = admnOrg.Id;
                resultMap.put('status', 'success');
                resultMap.put('message', 'Organization created successfully');
                resultMap.put('data', 'orgId');
            }

            // Create user group if organization exists
            if (String.isNotBlank(orgId)) {
                TC_Adminified_UserGroup__c userGrp = new TC_Adminified_UserGroup__c();
                userGrp.TC_Group_Name__c = groupName;
                userGrp.TC_Named_Credential__c = namedCredential;
                userGrp.TC_Adminified_Organisation__c = orgId;
                userGrp.TC_Adminified_User__c = UserInfo.getUserId();
                userGrp.TC_User_Organization_Name__c = orgAlias;
                userGrp.TC_Is_Named_Credential__c = alreadyExist;

                insert userGrp;
                
                Map<String, Object> responseMap = new Map<String, Object>();
                responseMap.put('userGrpId', userGrp.Id);
                responseMap.put('msg', alreadyExist);
                
                resultMap.put('status', 'success');
                resultMap.put('message', 'Group created successfully');
                resultMap.put('data', responseMap);
            }
            
        } catch (Exception ex) {
            resultMap.put('status', 'fail');
            resultMap.put('message', 'Error: ' + ex.getMessage());
            resultMap.put('data', null);
            errorMap.put('message', ex.getMessage());
            errorMap.put('cause', ex.getCause());
            errorMap.put('lineNumber', ex.getLineNumber());
            errorMap.put('typeName', ex.getTypeName());
            errorMap.put('stackTraceString', ex.getStackTraceString());
            errorMap.put('origin', 'tc_addNewOrganization');
            errorMap.put('is_FrontEnd', false);
            errorMap.put('className', 'TC_ConnectToOrgController');
            errorMap.put('methodName', 'addNewOrganization()');
        }
        
        return resultMap;
    }
}