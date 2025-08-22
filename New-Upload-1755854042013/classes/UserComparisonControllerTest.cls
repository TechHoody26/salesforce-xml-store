@isTest
private class UserComparisonControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test users
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@test.com',
            Username = 'testuser1@test.com.test',
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        
        User testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@test.com',
            Username = 'testuser2@test.com.test',
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        
        insert new List<User>{testUser1, testUser2};
    }
    
    @isTest
    static void testGetOrganizations() {
        Test.startTest();
        List<UserComparisonController.OrganizationWrapper> orgs = UserComparisonController.getOrganizations();
        Test.stopTest();
        
        System.assertNotEquals(null, orgs, 'Organizations should not be null');
        System.assert(orgs.size() > 0, 'Should return at least one organization');
        
        UserComparisonController.OrganizationWrapper org = orgs[0];
        System.assertNotEquals(null, org.Name, 'Organization name should not be null');
        System.assertNotEquals(null, org.Id, 'Organization ID should not be null');
    }
    
    @isTest
    static void testGetUsers() {
        String orgId = [SELECT Id FROM Organization LIMIT 1].Id;
        
        Test.startTest();
        List<UserComparisonController.UserWrapper> users = UserComparisonController.getUsers(orgId);
        Test.stopTest();
        
        System.assertNotEquals(null, users, 'Users should not be null');
        System.assert(users.size() > 0, 'Should return at least one user');
        
        // Verify user data structure
        UserComparisonController.UserWrapper user = users[0];
        System.assertNotEquals(null, user.Name, 'User name should not be null');
        System.assertNotEquals(null, user.Id, 'User ID should not be null');
        System.assertNotEquals(null, user.Email, 'User email should not be null');
    }
    
    @isTest
    static void testGetUserCount() {
        String orgId = [SELECT Id FROM Organization LIMIT 1].Id;
        
        Test.startTest();
        Integer userCount = UserComparisonController.getUserCount(orgId);
        Test.stopTest();
        
        System.assertNotEquals(null, userCount, 'User count should not be null');
        System.assert(userCount > 0, 'Should return a positive user count');
    }
    
    @isTest
    static void testGetUserDetails() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser1@test.com' LIMIT 1];
        
        Test.startTest();
        UserComparisonController.UserDetailsWrapper details = UserComparisonController.getUserDetails(testUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, details, 'User details should not be null');
        System.assertNotEquals(null, details.permissions, 'Permissions should not be null');
        System.assertNotEquals(null, details.access, 'Access should not be null');
        System.assert(details.permissions.size() > 0, 'Should return at least one permission');
        System.assert(details.access.size() > 0, 'Should return at least one access item');
    }
    
    @isTest
    static void testGetUserDetailsWithInvalidId() {
        Test.startTest();
        try {
            UserComparisonController.getUserDetails('invalid-id');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error loading user details'), 'Should contain error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testWrapperClasses() {
        // Test OrganizationWrapper
        UserComparisonController.OrganizationWrapper org = new UserComparisonController.OrganizationWrapper('Test Org', 'test-id', 'Test Description');
        System.assertEquals('Test Org', org.Name);
        System.assertEquals('test-id', org.Id);
        System.assertEquals('Test Description', org.Description);
        
        // Test UserPermission
        UserComparisonController.UserPermission permission = new UserComparisonController.UserPermission('Test Permission', true);
        System.assertEquals('Test Permission', permission.PermissionName);
        System.assertEquals(true, permission.IsGranted);
        
        // Test UserAccess
        UserComparisonController.UserAccess access = new UserComparisonController.UserAccess('Test Access', false);
        System.assertEquals('Test Access', access.AccessName);
        System.assertEquals(false, access.HasAccess);
    }
}