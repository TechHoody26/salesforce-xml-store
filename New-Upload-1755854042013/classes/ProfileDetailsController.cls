public with sharing class ProfileDetailsController {
    
    @AuraEnabled(cacheable=true)
    public static Profile_admn__c getProfileDetails(Id profileId) {
        try {
            return [
                SELECT Id, Name, Is_Custom__c, User_License__c, Description__c,
                       CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name
                FROM Profile_admn__c
                WHERE Id = :profileId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving profile details: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Object_Permission_admn__c> getObjectPermissions(Id profileId) {
        try {
            return [
                SELECT Id, Name, Object_Name__c, Read__c, Create__c, Edit__c,
                       View_All__c, Modify_All__c, CreatedDate
                FROM Object_Permission_admn__c
                WHERE Profile__c = :profileId
                ORDER BY Object_Name__c ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving object permissions: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Permission_Set_admn__c> getPermissionSets(Id profileId) {
        try {
            // Note: Permission_Set_admn__c doesn't have a Profile__c lookup field
            // Returning all permission sets for now
            return [
                SELECT Id, Name, CreatedDate
                FROM Permission_Set_admn__c
                ORDER BY Name ASC
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving permission sets: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Permission_Set_Group_admn__c> getPermissionSetGroups(Id profileId) {
        try {
            // Note: Permission_Set_Group_admn__c doesn't have a Profile__c lookup field
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