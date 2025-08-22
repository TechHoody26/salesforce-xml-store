public with sharing class PermissionSetDetailsController {
    
    @AuraEnabled(cacheable=true)
    public static Permission_Set_admn__c getPermissionSetDetails(Id permissionSetId) {
        try {
            return [
                SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name
                FROM Permission_Set_admn__c
                WHERE Id = :permissionSetId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving permission set details: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Object_Permission_admn__c> getObjectPermissions(Id permissionSetId) {
        try {
            // Note: Object_Permission_admn__c doesn't have a Permission_Set__c lookup field
            // Returning all object permissions for now
            return [
                SELECT Id, Name, Object_Name__c, Read__c, Create__c, Edit__c,
                       View_All__c, Modify_All__c, CreatedDate
                FROM Object_Permission_admn__c
                ORDER BY Object_Name__c ASC
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving object permissions: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Profile_admn__c> getProfiles(Id permissionSetId) {
        try {
            // Note: Profile_admn__c doesn't have a Permission_Set__c lookup field
            // Returning all profiles for now
            return [
                SELECT Id, Name, Is_Custom__c, User_License__c, CreatedDate
                FROM Profile_admn__c
                ORDER BY Name ASC
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving profiles: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Permission_Set_Group_admn__c> getPermissionSetGroups(Id permissionSetId) {
        try {
            // Note: Permission_Set_Group_admn__c doesn't have a Permission_Set__c lookup field
            // Returning all permission set groups for now
            return [
                SELECT Id, Name, CreatedDate
                FROM Permission_Set_Group_admn__c
                ORDER BY Name ASC
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving permission set groups: ' + e.getMessage());
        }
    }
}