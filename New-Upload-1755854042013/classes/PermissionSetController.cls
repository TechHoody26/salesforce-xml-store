public with sharing class PermissionSetController {
    
    @AuraEnabled(cacheable=true)
    public static List<Permission_Set_admn__c> getPermissionSets() {
        try {
            List<Permission_Set_admn__c> permissionSets = [
                SELECT Id, Name, API_Name__c, Description__c, License__c, Namespace_Prefix__c, 
                       Session_Activation_Required__c, Permission_Set_Groups_Added_To__c,
                       Profile__c, Profile__r.Name,
                       CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name
                FROM Permission_Set_admn__c 
                ORDER BY Name ASC
            ];
            

            
            return permissionSets;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving permission sets: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPermissionSetsPaginated(Integer pageNumber, Integer pageSize, String searchTerm, String sortBy, String sortDirection) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            
            // Build the base query without ORDER BY for counting
            String baseQuery = 'SELECT Id, Name, API_Name__c, Description__c, License__c, Namespace_Prefix__c, ' +
                             'Session_Activation_Required__c, Permission_Set_Groups_Added_To__c, ' +
                             'Profile__c, Profile__r.Name, ' +
                             'CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name ' +
                             'FROM Permission_Set_admn__c';
            
            // Add WHERE clause if search term exists
            List<String> whereConditions = new List<String>();
            if (String.isNotBlank(searchTerm)) {
                String searchPattern = '%' + searchTerm + '%';
                whereConditions.add('(Name LIKE :searchPattern OR API_Name__c LIKE :searchPattern OR Description__c LIKE :searchPattern OR License__c LIKE :searchPattern OR Namespace_Prefix__c LIKE :searchPattern)');
            }
            
            if (!whereConditions.isEmpty()) {
                baseQuery += ' WHERE ' + String.join(whereConditions, ' AND ');
            }
            
            // Get total count first (without ORDER BY)
            String countQuery = baseQuery.replace('SELECT Id, Name, API_Name__c, Description__c, License__c, Namespace_Prefix__c, Session_Activation_Required__c, Permission_Set_Groups_Added_To__c, Profile__c, Profile__r.Name, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name', 'SELECT COUNT()');
            Integer totalRecords = Database.countQuery(countQuery);
            
            // Add ORDER BY for the main query
            if (String.isNotBlank(sortBy)) {
                String direction = (sortDirection == 'desc') ? 'DESC' : 'ASC';
                baseQuery += ' ORDER BY ' + sortBy + ' ' + direction;
            } else {
                baseQuery += ' ORDER BY Name ASC';
            }
            
            // Add LIMIT and OFFSET for pagination
            Integer offset = (pageNumber - 1) * pageSize;
            baseQuery += ' LIMIT :pageSize OFFSET :offset';
            
            // Execute the paginated query
            List<Permission_Set_admn__c> permissionSets = Database.query(baseQuery);
            
            // Calculate pagination info
            Integer totalPages = (totalRecords + pageSize - 1) / pageSize;
            
            // Prepare result
            result.put('records', permissionSets);
            result.put('totalRecords', totalRecords);
            result.put('totalPages', totalPages);
            result.put('currentPage', pageNumber);
            result.put('pageSize', pageSize);
            result.put('hasNextPage', pageNumber < totalPages);
            result.put('hasPreviousPage', pageNumber > 1);
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving paginated permission sets: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deletePermissionSets(List<Id> permissionSetIds) {
        try {
            List<Permission_Set_admn__c> permissionSetsToDelete = [
                SELECT Id FROM Permission_Set_admn__c 
                WHERE Id IN :permissionSetIds
            ];
            
            if (!permissionSetsToDelete.isEmpty()) {
                delete permissionSetsToDelete;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting permission sets: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Permission_Set_admn__c> searchPermissionSets(String searchTerm) {
        try {
            String searchPattern = '%' + searchTerm + '%';
            return [
                SELECT Id, Name, API_Name__c, Description__c, License__c, Namespace_Prefix__c, 
                       Session_Activation_Required__c, Permission_Set_Groups_Added_To__c,
                       Profile__c, Profile__r.Name,
                       CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name
                FROM Permission_Set_admn__c 
                WHERE Name LIKE :searchPattern 
                   OR API_Name__c LIKE :searchPattern 
                   OR Description__c LIKE :searchPattern 
                   OR License__c LIKE :searchPattern
                   OR Namespace_Prefix__c LIKE :searchPattern
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving permission sets: ' + e.getMessage());
        }
    }
    
}