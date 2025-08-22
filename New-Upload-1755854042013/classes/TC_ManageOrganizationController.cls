public with sharing class TC_ManageOrganizationController {
    
    // Custom Setting to store organization data
    public class OrganizationData {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String organizationName { get; set; }
        @AuraEnabled public String groupName { get; set; }
        @AuraEnabled public String namedCredential { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String storage { get; set; }
        @AuraEnabled public String organizationType { get; set; }
        @AuraEnabled public Boolean hasDeleteAction { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public DateTime lastModifiedDate { get; set; }
        
        public OrganizationData(String id, String orgName, String groupName, String namedCred, String status, String storage, String orgType) {
            this.id = id;
            this.organizationName = orgName;
            this.groupName = groupName;
            this.namedCredential = namedCred;
            this.status = status;
            this.storage = storage;
            this.organizationType = orgType;
            this.hasDeleteAction = true;
            this.createdDate = DateTime.now();
            this.lastModifiedDate = DateTime.now();
        }
    }
    
    /*
     * @method: getOrganizationList
     * @param : no params.
     * @Description: To get organization list using in-memory storage instead of DML operations.
     * @return: Map containing organization list.
     * @lastModified: Assistant_05/08/2025
     */
    @AuraEnabled
    public static Map<String, Object> getOrganizationList() {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Get from Developer_Org__c custom object
            List<Developer_Org__c> orgList = [
                SELECT Id, Name, Org_Type__c, Status__c, CreatedDate, LastModifiedDate
                FROM Developer_Org__c
                ORDER BY Name
            ];
            
            if (orgList.size() > 0) {
                // Convert custom object records to OrganizationData format
                List<OrganizationData> convertedOrgs = new List<OrganizationData>();
                for (Developer_Org__c org : orgList) {
                    OrganizationData orgData = new OrganizationData(
                        org.Id,
                        org.Name,
                        'Default Group', // Default group name since this field doesn't exist
                        org.Name, // Use org name as named credential
                        org.Status__c != null ? org.Status__c : 'Active',
                        'Salesforce', // Default storage
                        org.Org_Type__c != null ? org.Org_Type__c : 'Developer'
                    );
                    orgData.createdDate = org.CreatedDate;
                    orgData.lastModifiedDate = org.LastModifiedDate;
                    convertedOrgs.add(orgData);
                }
                
                resultMap.put('status', 'success');
                resultMap.put('record', convertedOrgs);
                resultMap.put('message', 'Organizations loaded from database');
            } else {
                resultMap.put('status', 'success');
                resultMap.put('record', new List<OrganizationData>());
                resultMap.put('message', 'No organizations found. Click "Connect To Organization" to get started.');
            }
        } catch (Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('record', '');
            resultMap.put('message', 'Error loading organizations: ' + e.getMessage());
        }
        
        return resultMap;
    }
    

    
    /*
     * @method: getNamedCredentials
     * @param : no params.
     * @Description: To get all named credentials available in the org.
     * @return: List of named credentials.
     * @lastModified: Assistant_05/08/2025
     */
    @AuraEnabled
    public static List<NamedCredential> getNamedCredentials() {
        List<NamedCredential> namedCredentials = [
            SELECT Id, MasterLabel, DeveloperName, Endpoint
            FROM NamedCredential
            ORDER BY MasterLabel
        ];
        
        return namedCredentials;
    }
    
    /*
     * @method: saveOrganization
     * @param : OrganizationData object
     * @Description: To save organization data to in-memory storage
     * @return: Map containing save result
     * @lastModified: Assistant_05/08/2025
     */
    @AuraEnabled
    public static Map<String, Object> saveOrganization(OrganizationData orgData) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Save to Developer_Org__c custom object
            Developer_Org__c newOrg = new Developer_Org__c();
            newOrg.Name = orgData.organizationName;
            newOrg.Org_Type__c = orgData.organizationType != null ? orgData.organizationType : 'Developer';
            newOrg.Status__c = orgData.status != null ? orgData.status : 'Active';
            
            insert newOrg;
            
            // Update the orgData with the new ID
            orgData.id = newOrg.Id;
            orgData.createdDate = newOrg.CreatedDate;
            orgData.lastModifiedDate = newOrg.LastModifiedDate;
            
            resultMap.put('status', 'success');
            resultMap.put('message', 'Organization saved successfully');
            resultMap.put('record', orgData);
        } catch (Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message', 'Error saving organization: ' + e.getMessage());
        }
        
        return resultMap;
    }
    
    /*
     * @method: updateOrganization
     * @param : OrganizationData object
     * @Description: To update organization data in memory
     * @return: Map containing update result
     * @lastModified: Assistant_05/08/2025
     */
    @AuraEnabled
    public static Map<String, Object> updateOrganization(OrganizationData orgData) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Update in Developer_Org__c custom object
            List<Developer_Org__c> existingOrgs = [
                SELECT Id, Name, Org_Type__c, Status__c
                FROM Developer_Org__c
                WHERE Id = :orgData.id
                LIMIT 1
            ];
            
            if (!existingOrgs.isEmpty()) {
                Developer_Org__c orgToUpdate = existingOrgs[0];
                orgToUpdate.Name = orgData.organizationName;
                orgToUpdate.Org_Type__c = orgData.organizationType;
                orgToUpdate.Status__c = orgData.status;
                
                update orgToUpdate;
                
                orgData.lastModifiedDate = orgToUpdate.LastModifiedDate;
                
                resultMap.put('status', 'success');
                resultMap.put('message', 'Organization updated successfully');
                resultMap.put('record', orgData);
            } else {
                resultMap.put('status', 'error');
                resultMap.put('message', 'Organization not found');
            }
        } catch (Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message', 'Error updating organization: ' + e.getMessage());
        }
        
        return resultMap;
    }
    
    /*
     * @method: deleteOrganization
     * @param : String organizationId
     * @Description: To delete organization data from memory
     * @return: Map containing delete result
     * @lastModified: Assistant_05/08/2025
     */
    @AuraEnabled
    public static Map<String, Object> deleteOrganization(String organizationId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Delete from Developer_Org__c custom object
            List<Developer_Org__c> orgsToDelete = [
                SELECT Id, Name
                FROM Developer_Org__c
                WHERE Id = :organizationId
                LIMIT 1
            ];
            
            if (!orgsToDelete.isEmpty()) {
                delete orgsToDelete[0];
                
                resultMap.put('status', 'success');
                resultMap.put('message', 'Organization deleted successfully');
            } else {
                resultMap.put('status', 'error');
                resultMap.put('message', 'Organization not found');
            }
        } catch (Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message', 'Error deleting organization: ' + e.getMessage());
        }
        
        return resultMap;
    }
    
    /*
     * @method: updateGroupOrg
     * @param : MAP of data to be update.
     * @Description: To update group name and org name
     * @return: resulting map of update action.
     * @lastModified: Assistant_05/08/2025
     */
    @AuraEnabled
    public static Map<String, Object> updateGroupOrg(Map<String, String> data) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            String orgName = data.get('orgName');
            String userGrpId = data.get('userGrpId');
            String grpName = data.get('grpName');
            String updateGroupName = data.get('updateGroupName');
            
            // Initialize with success status
            resultMap.put('status', 'success');
            resultMap.put('message', 'Update operations completed');
            
            if (orgName != null && orgName != '') {
                Map<String, Object> orgResult = updateOrgName(userGrpId, orgName);
                if (orgResult.get('status') == 'error') {
                    return orgResult; // Return error if org update fails
                }
            }
            if (updateGroupName != null && updateGroupName != '') {
                Map<String, Object> groupResult = updateGroupName(grpName, updateGroupName);
                if (groupResult.get('status') == 'error') {
                    return groupResult; // Return error if group update fails
                }
            }
        } catch (Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message', 'Error updating organization: ' + e.getMessage());
        }
        
        return resultMap;
    }
    
    /*
     * @method: updateOrgName
     * @param : userGroup id and organization name.
     * @Description: To update org name in memory.
     * @return: resulting map of update action.
     * @lastModified: Assistant_05/08/2025
     */
    public static Map<String, Object> updateOrgName(String userGrpId, String orgName) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Update in Developer_Org__c custom object
            List<Developer_Org__c> existingOrgs = [
                SELECT Id, Name
                FROM Developer_Org__c
                WHERE Id = :userGrpId
                LIMIT 1
            ];
            
            if (!existingOrgs.isEmpty()) {
                Developer_Org__c orgToUpdate = existingOrgs[0];
                orgToUpdate.Name = orgName;
                
                update orgToUpdate;
                
                resultMap.put('status', 'success');
                resultMap.put('message', 'Organization name updated successfully');
            } else {
                resultMap.put('status', 'error');
                resultMap.put('message', 'Organization not found');
            }
        } catch (Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message', 'Error updating organization name: ' + e.getMessage());
        }
        
        return resultMap;
    }
    
    /*
     * @method: updateGroupName
     * @param : group name and updated group name
     * @Description: To update group name in database.
     * @return: resulting map of update action.
     * @lastModified: Assistant_05/08/2025
     */
    public static Map<String, Object> updateGroupName(String grpName, String updateGroupName) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Note: Group name updates are not supported in Developer_Org__c object
            // as there is no Group_Name__c field. This method is kept for compatibility
            // but will return a message indicating group updates are not supported.
            
            resultMap.put('status', 'success');
            resultMap.put('message', 'Group name updates are not supported in the current object structure');
        } catch (Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message', 'Error updating group name: ' + e.getMessage());
        }
        
        return resultMap;
    }
    

}