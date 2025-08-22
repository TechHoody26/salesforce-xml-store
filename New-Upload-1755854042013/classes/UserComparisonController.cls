public with sharing class UserComparisonController {
    
    @AuraEnabled(cacheable=true)
    public static List<OrganizationWrapper> getOrganizations() {
        try {
            // For now, we'll return the current org as the only organization
            // In a real implementation, you would query connected orgs or use callouts
            List<OrganizationWrapper> orgs = new List<OrganizationWrapper>();
            
            // Get current org info - using the Organization sObject
            List<Organization> orgList = [SELECT Id, Name, InstanceName FROM Organization LIMIT 1];
            if (!orgList.isEmpty()) {
                Organization org = orgList[0];
                orgs.add(new OrganizationWrapper(org.Name, org.Id, 'Current Organization'));
            }
            
            return orgs;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading organizations: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<UserWrapper> getUsers(String orgId) {
        try {
            List<UserWrapper> users = new List<UserWrapper>();
            List<User> userList = [
                SELECT Id, Name, Email, Username, Profile.Name, UserRole.Name, 
                       Manager.Name, IsActive, LastModifiedDate, Profile.Id, UserRole.Id,
                       FirstName, LastName, CompanyName, Department, Title,
                       Phone, MobilePhone, TimeZoneSidKey, UserType, EmployeeNumber, 
                       LastLoginDate, CreatedDate
                FROM User 
                WHERE IsActive = true 
                ORDER BY Name
            ];
            for (User u : userList) {
                users.add(new UserWrapper(
                    u.Name,
                    u.Id,
                    u.Email,
                    u.Username,
                    u.Profile?.Name,
                    u.UserRole?.Name,
                    u.Manager?.Name,
                    u.IsActive,
                    u.LastModifiedDate.format(),
                    u.FirstName,
                    u.LastName,
                    u.CompanyName,
                    u.Department,
                    u.Title,
                    u.Phone,
                    u.MobilePhone,
                    u.TimeZoneSidKey,
                    u.UserType,
                    u.EmployeeNumber,
                    u.LastLoginDate,
                    u.CreatedDate
                ));
            }
            System.debug('Total users found: ' + users.size());
            return users;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading users: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getUserCount(String orgId) {
        try {
            // Query count of active users
            Integer userCount = [
                SELECT COUNT() 
                FROM User 
                WHERE IsActive = true
            ];
            
            System.debug('User count: ' + userCount);
            return userCount;
        } catch (Exception e) {
            throw new AuraHandledException('Error getting user count: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static UserDetailsWrapper getUserDetails(String userId) {
        try {
            UserDetailsWrapper details = new UserDetailsWrapper();
            
            // Query the specific user with related data
            User user = [
                SELECT Id, Name, Email, Username, Profile.Name, UserRole.Name, 
                       Manager.Name, IsActive, LastModifiedDate, Profile.Id, UserRole.Id
                FROM User 
                WHERE Id = :userId
                LIMIT 1
            ];
            
            details.permissions = new List<UserPermission>();
            details.access = new List<UserAccess>();
            
            // Get user permissions from Profile
            if (user.Profile != null) {
                List<Profile> profileWithPermissions = [
                    SELECT Id, Name, 
                           PermissionsViewSetup, PermissionsCustomizeApplication, 
                           PermissionsModifyAllData, PermissionsViewAllData,
                           PermissionsManageUsers
                    FROM Profile 
                    WHERE Id = :user.Profile.Id
                    LIMIT 1
                ];
                
                if (!profileWithPermissions.isEmpty()) {
                    Profile p = profileWithPermissions[0];
                    details.permissions.add(new UserPermission('View Setup and Configuration', p.PermissionsViewSetup));
                    details.permissions.add(new UserPermission('Customize Application', p.PermissionsCustomizeApplication));
                    details.permissions.add(new UserPermission('Modify All Data', p.PermissionsModifyAllData));
                    details.permissions.add(new UserPermission('View All Data', p.PermissionsViewAllData));
                    details.permissions.add(new UserPermission('Manage Users', p.PermissionsManageUsers));
                    details.permissions.add(new UserPermission('Manage Roles and Profiles', false));
                    details.permissions.add(new UserPermission('Manage Connected Apps', false));
                    details.permissions.add(new UserPermission('Manage Custom Settings', false));
                }
            }
            
            // Mock user access (in a real implementation, you would query actual app access)
            details.access.add(new UserAccess('Sales App', true));
            details.access.add(new UserAccess('Service App', true));
            details.access.add(new UserAccess('Marketing App', false));
            details.access.add(new UserAccess('Analytics App', true));
            details.access.add(new UserAccess('Community Access', false));
            details.access.add(new UserAccess('Mobile Access', true));
            
            return details;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading user details: ' + e.getMessage());
        }
    }
    
    // Wrapper classes for data transfer
    public class OrganizationWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public String Id;
        @AuraEnabled public String Description;
        
        public OrganizationWrapper(String name, String id, String description) {
            this.Name = name;
            this.Id = id;
            this.Description = description;
        }
    }
    
    public class UserWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public String Id;
        @AuraEnabled public String Email;
        @AuraEnabled public String Username;
        @AuraEnabled public String ProfileName;
        @AuraEnabled public String RoleName;
        @AuraEnabled public String ManagerName;
        @AuraEnabled public Boolean IsActive;
        @AuraEnabled public String LastModifiedDate;
        @AuraEnabled public String FirstName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String CompanyName;
        @AuraEnabled public String Department;
        @AuraEnabled public String Title;
        @AuraEnabled public String Phone;
        @AuraEnabled public String MobilePhone;
        @AuraEnabled public String TimeZoneSidKey;
        @AuraEnabled public String UserType;
        @AuraEnabled public String EmployeeNumber;
        @AuraEnabled public DateTime LastLoginDate;
        @AuraEnabled public DateTime CreatedDate;
        
        public UserWrapper(String name, String id, String email, String username, String profileName, String roleName, String managerName, Boolean isActive, String lastModifiedDate, String firstName, String lastName, String companyName, String department, String title, String phone, String mobilePhone, String timeZoneSidKey, String userType, String employeeNumber, DateTime lastLoginDate, DateTime createdDate) {
            this.Name = name;
            this.Id = id;
            this.Email = email;
            this.Username = username;
            this.ProfileName = profileName;
            this.RoleName = roleName;
            this.ManagerName = managerName;
            this.IsActive = isActive;
            this.LastModifiedDate = lastModifiedDate;
            this.FirstName = firstName;
            this.LastName = lastName;
            this.CompanyName = companyName;
            this.Department = department;
            this.Title = title;
            this.Phone = phone;
            this.MobilePhone = mobilePhone;
            this.TimeZoneSidKey = timeZoneSidKey;
            this.UserType = userType;
            this.EmployeeNumber = employeeNumber;
            this.LastLoginDate = lastLoginDate;
            this.CreatedDate = createdDate;
        }
    }
    
    public class UserDetailsWrapper {
        @AuraEnabled public List<UserPermission> permissions;
        @AuraEnabled public List<UserAccess> access;
    }
    
    public class UserPermission {
        @AuraEnabled public String PermissionName;
        @AuraEnabled public Boolean IsGranted;
        
        public UserPermission(String permissionName, Boolean isGranted) {
            this.PermissionName = permissionName;
            this.IsGranted = isGranted;
        }
    }
    
    public class UserAccess {
        @AuraEnabled public String AccessName;
        @AuraEnabled public Boolean HasAccess;
        
        public UserAccess(String accessName, Boolean hasAccess) {
            this.AccessName = accessName;
            this.HasAccess = hasAccess;
        }
    }
}