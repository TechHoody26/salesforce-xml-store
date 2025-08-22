/**
 * @description Utility class to set up Named Credential for SOAP API testing
 * @author AI Assistant
 * @version 1.0
 */
public class NamedCredentialSetup {
    
    /**
     * @description Debug method to check Named Credential configuration
     * @param namedCredentialName The name of the Named Credential to check
     */
    public static void debugNamedCredential(String namedCredentialName) {
        try {
            System.debug('=== NamedCredentialSetup.debugNamedCredential START ===');
            
            List<NamedCredential> creds = [
                SELECT Id, DeveloperName, MasterLabel, Endpoint, PrincipalType
                FROM NamedCredential 
                WHERE DeveloperName = :namedCredentialName
            ];
            
            if (creds.isEmpty()) {
                System.debug('❌ Named Credential not found: ' + namedCredentialName);
                return;
            }
            
            NamedCredential cred = creds[0];
            System.debug('Named Credential Details:');
            System.debug('  - ID: ' + cred.Id);
            System.debug('  - DeveloperName: ' + cred.DeveloperName);
            System.debug('  - MasterLabel: ' + cred.MasterLabel);
            System.debug('  - Endpoint: ' + cred.Endpoint);
            System.debug('  - PrincipalType: ' + cred.PrincipalType);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error debugging Named Credential: ' + e.getMessage());
        }
    }
    
    /**
     * @description Tests the Named Credential with better error handling
     * @param namedCredentialName The name of the Named Credential to test
     * @return Boolean True if test successful, false otherwise
     */
    public static Boolean testNamedCredential(String namedCredentialName) {
        try {
            System.debug('=== NamedCredentialSetup.testNamedCredential START ===');
            System.debug('Testing Named Credential: ' + namedCredentialName);
            
            // Test getting available credentials
            List<String> credentials = ProfileDataController.getAvailableNamedCredentials();
            System.debug('Available Named Credentials: ' + credentials);
            
            if (!credentials.contains(namedCredentialName)) {
                System.debug('❌ Named Credential not found in available list');
                return false;
            }
            
            System.debug('✅ Named Credential found in available list');
            
            // Test profile fetching with detailed error handling
            try {
                List<ProfileDataService.ProfileWrapper> profiles = ProfileDataController.getProfiles(namedCredentialName);
                System.debug('Profiles found: ' + (profiles != null ? profiles.size() : 0));
                
                if (profiles != null && !profiles.isEmpty()) {
                    System.debug('✅ Profile fetching successful!');
                    System.debug('First profile: ' + profiles[0].Name);
                    System.debug('First profile license: ' + profiles[0].UserLicense);
                    return true;
                } else {
                    System.debug('⚠️ No profiles found or error occurred');
                    return false;
                }
            } catch (AuraHandledException e) {
                System.debug(LoggingLevel.ERROR, 'AuraHandledException: ' + e.getMessage());
                return false;
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'General Exception: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
                return false;
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error testing Named Credential: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return false;
        }
    }
    
    /**
     * @description Lists all available Named Credentials
     */
    public static void listAllNamedCredentials() {
        try {
            System.debug('=== NamedCredentialSetup.listAllNamedCredentials START ===');
            
            List<NamedCredential> allCreds = [
                SELECT Id, DeveloperName, MasterLabel, Endpoint, PrincipalType
                FROM NamedCredential 
                ORDER BY MasterLabel
            ];
            
            System.debug('All Named Credentials (' + allCreds.size() + ' found):');
            for (NamedCredential cred : allCreds) {
                System.debug('  - ' + cred.DeveloperName + ' (' + cred.MasterLabel + ')');
                System.debug('    Endpoint: ' + cred.Endpoint);
                System.debug('    PrincipalType: ' + cred.PrincipalType);
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error listing Named Credentials: ' + e.getMessage());
        }
    }
    
    /**
     * @description Provides setup instructions for creating Named Credentials manually
     */
    public static void showSetupInstructions() {
        System.debug('=== NamedCredentialSetup.showSetupInstructions START ===');
        System.debug('📋 MANUAL SETUP INSTRUCTIONS:');
        System.debug('');
        System.debug('1. Go to Setup → Security → Named Credentials');
        System.debug('2. Click "New"');
        System.debug('3. Fill in the following:');
        System.debug('   - Label: "Current Org"');
        System.debug('   - Name: "Current_Org" (auto-generated)');
        System.debug('   - URL: Your org URL (e.g., https://your-instance.salesforce.com)');
        System.debug('   - Identity Type: "Named Principal"');
        System.debug('   - Authentication Protocol: "OAuth 2.0"');
        System.debug('   - Generate Authorization Header: ✅ Checked');
        System.debug('4. Click "Save"');
        System.debug('');
        System.debug('5. Also add Remote Site Settings:');
        System.debug('   - Go to Setup → Security → Remote Site Settings');
        System.debug('   - Click "New Remote Site"');
        System.debug('   - Remote Site Name: "Current_Org"');
        System.debug('   - Remote Site URL: Your org URL');
        System.debug('   - Active: ✅ Checked');
        System.debug('   - Click "Save"');
        System.debug('');
        System.debug('6. After setup, run: NamedCredentialSetup.testNamedCredential("Current_Org")');
        System.debug('=== NamedCredentialSetup.showSetupInstructions END ===');
    }
    
    /**
     * @description Complete test process for existing Named Credentials
     * @return Boolean True if everything works, false otherwise
     */
    public static Boolean testExistingNamedCredentials() {
        try {
            System.debug('=== NamedCredentialSetup.testExistingNamedCredentials START ===');
            
            // List all available credentials
            listAllNamedCredentials();
            
            // Get available credentials from ProfileDataController
            List<String> credentials = ProfileDataController.getAvailableNamedCredentials();
            System.debug('Available credentials from ProfileDataController: ' + credentials);
            
            if (credentials.isEmpty()) {
                System.debug('❌ No Named Credentials available');
                showSetupInstructions();
                return false;
            }
            
            // Test the first available credential
            String firstCredential = credentials[0];
            System.debug('Testing first available credential: ' + firstCredential);
            
            Boolean testResult = testNamedCredential(firstCredential);
            System.debug('Test result for ' + firstCredential + ': ' + testResult);
            
            return testResult;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in testExistingNamedCredentials: ' + e.getMessage());
            return false;
        }
    }
}