public with sharing class ProfileController {
    
    @AuraEnabled(cacheable=true)
    public static List<Profile_admn__c> getProfiles() {
        try {
            return [
                SELECT Id, Name, Is_Custom__c, User_License__c, Description__c,
                       CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name
                FROM Profile_admn__c 
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving profiles: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProfilesPaginated(Integer pageNumber, Integer pageSize, String searchTerm, String sortBy, String sortDirection) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            
            // Build the base query without ORDER BY for counting
            String baseQuery = 'SELECT Id, Name, Is_Custom__c, User_License__c, Description__c, ' +
                             'CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name ' +
                             'FROM Profile_admn__c';
            
            // Add WHERE clause if search term exists
            List<String> whereConditions = new List<String>();
            if (String.isNotBlank(searchTerm)) {
                String searchPattern = '%' + searchTerm + '%';
                whereConditions.add('(Name LIKE :searchPattern OR User_License__c LIKE :searchPattern OR Description__c LIKE :searchPattern)');
            }
            
            if (!whereConditions.isEmpty()) {
                baseQuery += ' WHERE ' + String.join(whereConditions, ' AND ');
            }
            
            // Get total count first (without ORDER BY)
            String countQuery = baseQuery.replace('SELECT Id, Name, Is_Custom__c, User_License__c, Description__c, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name', 'SELECT COUNT()');
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
            List<Profile_admn__c> profiles = Database.query(baseQuery);
            
            // Calculate pagination info
            Integer totalPages = (totalRecords + pageSize - 1) / pageSize;
            
            // Prepare result
            result.put('records', profiles);
            result.put('totalRecords', totalRecords);
            result.put('totalPages', totalPages);
            result.put('currentPage', pageNumber);
            result.put('pageSize', pageSize);
            result.put('hasNextPage', pageNumber < totalPages);
            result.put('hasPreviousPage', pageNumber > 1);
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving paginated profiles: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteProfiles(List<Id> profileIds) {
        try {
            List<Profile_admn__c> profilesToDelete = [
                SELECT Id FROM Profile_admn__c 
                WHERE Id IN :profileIds
            ];
            
            if (!profilesToDelete.isEmpty()) {
                delete profilesToDelete;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting profiles: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Profile_admn__c> searchProfiles(String searchTerm) {
        try {
            String searchPattern = '%' + searchTerm + '%';
            return [
                SELECT Id, Name, Is_Custom__c, User_License__c, Description__c,
                       CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name
                FROM Profile_admn__c 
                WHERE Name LIKE :searchPattern 
                   OR User_License__c LIKE :searchPattern 
                   
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error searching profiles: ' + e.getMessage());
        }
    }
}