/**
 * @description User Management Controller for LWC
 */
public with sharing class UserManagementController {
    
    /**
     * @description Get all users from the org
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUsers() {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            List<User> users = [
                SELECT Id, Name, Username, Email, FirstName, LastName, 
                       Title, Department, Phone, IsActive, Profile.Name,
                       LastLoginDate, CreatedDate, LastModifiedDate
                FROM User 
                WHERE IsActive = true 
                ORDER BY Name
                LIMIT 100
            ];
            
            List<Map<String, Object>> userList = new List<Map<String, Object>>();
            for(User u : users) {
                userList.add(new Map<String, Object>{
                    'Id' => u.Id,
                    'Name' => u.Name,
                    'Username' => u.Username,
                    'Email' => u.Email,
                    'FirstName' => u.FirstName,
                    'LastName' => u.LastName,
                    'Title' => u.Title,
                    'Department' => u.Department,
                    'Phone' => u.Phone,
                    'IsActive' => u.IsActive,
                    'ProfileName' => u.Profile.Name,
                    'LastLoginDate' => u.LastLoginDate != null ? u.LastLoginDate.format() : 'Never',
                    'CreatedDate' => u.CreatedDate.format(),
                    'LastModifiedDate' => u.LastModifiedDate.format()
                });
            }
            
            result.put('status', 'success');
            result.put('data', userList);
            result.put('message', 'Users retrieved successfully');
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Get user details by ID
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUserDetails(String userId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            if (String.isBlank(userId)) {
                result.put('status', 'error');
                result.put('message', 'User ID is required');
                return result;
            }
            
            User user = [
                SELECT Id, Name, Username, Email, FirstName, LastName, 
                       Title, Department, Phone, IsActive, Profile.Name,
                       LastLoginDate, CreatedDate, LastModifiedDate,
                       CompanyName, EmployeeNumber, TimeZoneSidKey, UserType
                FROM User 
                WHERE Id = :userId
                LIMIT 1
            ];
            
            Map<String, Object> userData = new Map<String, Object>{
                'Id' => user.Id,
                'Name' => user.Name,
                'Username' => user.Username,
                'Email' => user.Email,
                'FirstName' => user.FirstName,
                'LastName' => user.LastName,
                'Title' => user.Title,
                'Department' => user.Department,
                'Phone' => user.Phone,
                'IsActive' => user.IsActive,
                'ProfileName' => user.Profile.Name,
                'LastLoginDate' => user.LastLoginDate != null ? user.LastLoginDate.format() : 'Never',
                'CreatedDate' => user.CreatedDate.format(),
                'LastModifiedDate' => user.LastModifiedDate.format(),
                'CompanyName' => user.CompanyName,
                'EmployeeNumber' => user.EmployeeNumber,
                'TimeZoneSidKey' => user.TimeZoneSidKey,
                'UserType' => user.UserType
            };
            
            result.put('status', 'success');
            result.put('data', userData);
            result.put('message', 'User details retrieved successfully');
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Search users by name or email
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> searchUsers(String searchTerm) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            if (String.isBlank(searchTerm)) {
                return getUsers();
            }
            
            String searchPattern = '%' + searchTerm + '%';
            List<User> users = [
                SELECT Id, Name, Username, Email, FirstName, LastName, 
                       Title, Department, Phone, IsActive, Profile.Name,
                       LastLoginDate, CreatedDate, LastModifiedDate
                FROM User 
                WHERE IsActive = true 
                AND (Name LIKE :searchPattern OR Email LIKE :searchPattern OR Username LIKE :searchPattern)
                ORDER BY Name
                LIMIT 50
            ];
            
            List<Map<String, Object>> userList = new List<Map<String, Object>>();
            for(User u : users) {
                userList.add(new Map<String, Object>{
                    'Id' => u.Id,
                    'Name' => u.Name,
                    'Username' => u.Username,
                    'Email' => u.Email,
                    'FirstName' => u.FirstName,
                    'LastName' => u.LastName,
                    'Title' => u.Title,
                    'Department' => u.Department,
                    'Phone' => u.Phone,
                    'IsActive' => u.IsActive,
                    'ProfileName' => u.Profile.Name,
                    'LastLoginDate' => u.LastLoginDate != null ? u.LastLoginDate.format() : 'Never',
                    'CreatedDate' => u.CreatedDate.format(),
                    'LastModifiedDate' => u.LastModifiedDate.format()
                });
            }
            
            result.put('status', 'success');
            result.put('data', userList);
            result.put('message', 'Search completed successfully');
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Update user details
     */
    @AuraEnabled
    public static Map<String, Object> updateUser(String userId, String firstName, String lastName, String email, String title, String department, String phone) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            if (String.isBlank(userId)) {
                result.put('status', 'error');
                result.put('message', 'User ID is required');
                return result;
            }
            
            User userToUpdate = new User(
                Id = userId,
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Title = title,
                Department = department,
                Phone = phone
            );
            
            update userToUpdate;
            
            result.put('status', 'success');
            result.put('message', 'User updated successfully');
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Reset user password
     */
    @AuraEnabled
    public static Map<String, Object> resetPassword(String userId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            if (String.isBlank(userId)) {
                result.put('status', 'error');
                result.put('message', 'User ID is required');
                return result;
            }
            
            System.resetPassword(userId, true);
            
            result.put('status', 'success');
            result.put('message', 'Password reset email sent successfully');
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        
        return result;
    }
}