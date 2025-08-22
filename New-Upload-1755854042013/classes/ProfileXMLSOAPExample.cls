/**
 * @description Example class demonstrating SOAP-integrated Profile XML processing
 * @author AI Assistant
 * @version 1.0
 * @description This class shows how to use the ProfileXMLSOAPBridge to process
 * Profile XML from SOAP API calls instead of static XML input
 */
public class ProfileXMLSOAPExample {
    
    /**
     * @description Demonstrates complete SOAP-integrated profile processing workflow
     * @param namedCredential The named credential to use for authentication
     * @param profileName The name of the profile to process
     */
    public static void demonstrateSOAPIntegration(String namedCredential, String profileName) {
        try {
            System.debug('=== SOAP-Integrated Profile Processing Demonstration ===');
            System.debug('Profile: ' + profileName);
            System.debug('Named Credential: ' + namedCredential);
            
            // Step 1: Validate SOAP connection
            System.debug('Step 1: Validating SOAP connection...');
            Map<String, Object> validationResult = ProfileXMLSOAPBridge.validateSOAPConnection(namedCredential);
            
            if (validationResult.get('status') != 'success') {
                System.debug('❌ SOAP connection validation failed: ' + validationResult.get('message'));
                return;
            }
            
            System.debug('✅ SOAP connection validated successfully');
            System.debug('Available Profiles: ' + validationResult.get('profileCount'));
            
            // Step 2: Process single profile from SOAP
            System.debug('Step 2: Processing profile from SOAP...');
            Map<String, Object> processingResult = ProfileXMLSOAPBridge.processProfileFromSOAP(namedCredential, profileName);
            
            if (processingResult.get('status') == 'success') {
                System.debug('✅ Profile processed successfully');
                System.debug('Processing Steps:');
                List<String> steps = (List<String>) processingResult.get('processingSteps');
                for (String step : steps) {
                    System.debug('  - ' + step);
                }
                
                // Display parsed data summary
                ProfileXMLDataManager.ProfileData parsedData = (ProfileXMLDataManager.ProfileData) processingResult.get('parsedData');
                if (parsedData != null) {
                    System.debug('Parsed Data Summary:');
                    System.debug('  - Application Visibilities: ' + parsedData.applicationVisibilities.size());
                    System.debug('  - User Permissions: ' + parsedData.userPermissions.size());
                    System.debug('  - Object Permissions: ' + parsedData.objectPermissions.size());
                    System.debug('  - Field Permissions: ' + parsedData.fieldPermissions.size());
                    System.debug('  - Tab Visibilities: ' + parsedData.tabVisibilities.size());
                }
                
                // Display storage result
                Map<String, Object> storageResult = (Map<String, Object>) processingResult.get('storageResult');
                if (storageResult != null) {
                    System.debug('Storage Result:');
                    System.debug('  - Status: ' + storageResult.get('status'));
                    System.debug('  - Method: ' + storageResult.get('storageMethod'));
                    System.debug('  - Message: ' + storageResult.get('message'));
                }
                
            } else {
                System.debug('❌ Profile processing failed: ' + processingResult.get('message'));
            }
            
            System.debug('=== SOAP-Integrated Profile Processing Demonstration Completed ===');
            
        } catch (Exception e) {
            System.debug('❌ Error in SOAP integration demonstration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * @description Demonstrates bulk profile processing from SOAP
     * @param namedCredential The named credential to use for authentication
     * @param profileNames List of profile names to process
     */
    public static void demonstrateBulkSOAPProcessing(String namedCredential, List<String> profileNames) {
        try {
            System.debug('=== Bulk SOAP-Integrated Profile Processing Demonstration ===');
            System.debug('Total Profiles: ' + profileNames.size());
            System.debug('Named Credential: ' + namedCredential);
            
            // Process multiple profiles
            Map<String, Object> bulkResult = ProfileXMLSOAPBridge.processMultipleProfilesFromSOAP(namedCredential, profileNames);
            
            if (bulkResult.get('status') == 'completed') {
                System.debug('✅ Bulk processing completed successfully');
                System.debug('Summary:');
                System.debug('  - Total Profiles: ' + bulkResult.get('totalProfiles'));
                System.debug('  - Success Count: ' + bulkResult.get('successCount'));
                System.debug('  - Error Count: ' + bulkResult.get('errorCount'));
                System.debug('  - Message: ' + bulkResult.get('message'));
                
                // Display individual profile results
                List<Map<String, Object>> profileResults = (List<Map<String, Object>>) bulkResult.get('profileResults');
                if (profileResults != null) {
                    System.debug('Individual Profile Results:');
                    for (Map<String, Object> profileResult : profileResults) {
                        String status = (String) profileResult.get('status');
                        String name = (String) profileResult.get('profileName');
                        String message = (String) profileResult.get('message');
                        
                        System.debug('  - ' + name + ': ' + status + ' - ' + message);
                    }
                }
                
            } else {
                System.debug('❌ Bulk processing failed: ' + bulkResult.get('message'));
            }
            
            System.debug('=== Bulk SOAP-Integrated Profile Processing Demonstration Completed ===');
            
        } catch (Exception e) {
            System.debug('❌ Error in bulk SOAP processing demonstration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * @description Demonstrates processing all available profiles from SOAP
     * @param namedCredential The named credential to use for authentication
     * @param maxProfiles Maximum number of profiles to process
     */
    public static void demonstrateCompleteSOAPProcessing(String namedCredential, Integer maxProfiles) {
        try {
            System.debug('=== Complete SOAP-Integrated Profile Processing Demonstration ===');
            System.debug('Max Profiles: ' + maxProfiles);
            System.debug('Named Credential: ' + namedCredential);
            
            // Process all available profiles
            Map<String, Object> completeResult = ProfileXMLSOAPBridge.processAllProfilesFromSOAP(namedCredential, maxProfiles);
            
            if (completeResult.get('status') == 'completed') {
                System.debug('✅ Complete processing finished successfully');
                System.debug('Summary:');
                System.debug('  - Total Profiles: ' + completeResult.get('totalProfiles'));
                System.debug('  - Message: ' + completeResult.get('message'));
                
                // Display processing result details
                Map<String, Object> processingResult = (Map<String, Object>) completeResult.get('processingResult');
                if (processingResult != null) {
                    System.debug('Processing Details:');
                    System.debug('  - Status: ' + processingResult.get('status'));
                    System.debug('  - Success Count: ' + processingResult.get('successCount'));
                    System.debug('  - Error Count: ' + processingResult.get('errorCount'));
                }
                
            } else {
                System.debug('❌ Complete processing failed: ' + completeResult.get('message'));
            }
            
            System.debug('=== Complete SOAP-Integrated Profile Processing Demonstration Completed ===');
            
        } catch (Exception e) {
            System.debug('❌ Error in complete SOAP processing demonstration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * @description Demonstrates getting profile XML for manual processing
     * @param namedCredential The named credential to use for authentication
     * @param profileName The name of the profile to get XML for
     */
    public static void demonstrateXMLRetrieval(String namedCredential, String profileName) {
        try {
            System.debug('=== Profile XML Retrieval Demonstration ===');
            System.debug('Profile: ' + profileName);
            System.debug('Named Credential: ' + namedCredential);
            
            // Get profile XML for manual processing
            Map<String, Object> xmlResult = ProfileXMLSOAPBridge.getProfileXMLForManualProcessing(namedCredential, profileName);
            
            if (xmlResult.get('status') == 'success') {
                System.debug('✅ Profile XML retrieved successfully');
                System.debug('XML Details:');
                System.debug('  - Profile Name: ' + xmlResult.get('profileName'));
                System.debug('  - XML Length: ' + xmlResult.get('xmlLength') + ' characters');
                System.debug('  - Message: ' + xmlResult.get('message'));
                
                // Check if parsing was successful
                Boolean hasParsedData = (Boolean) xmlResult.get('hasParsedData');
                if (hasParsedData) {
                    System.debug('  - Parsed Data: Available');
                    ProfileXMLDataManager.ProfileData parsedData = (ProfileXMLDataManager.ProfileData) xmlResult.get('parsedData');
                    if (parsedData != null) {
                        System.debug('    * Application Visibilities: ' + parsedData.applicationVisibilities.size());
                        System.debug('    * User Permissions: ' + parsedData.userPermissions.size());
                        System.debug('    * Object Permissions: ' + parsedData.objectPermissions.size());
                        System.debug('    * Field Permissions: ' + parsedData.fieldPermissions.size());
                    }
                } else {
                    System.debug('  - Parsed Data: Not available');
                    System.debug('    * Parse Error: ' + xmlResult.get('parseError'));
                }
                
                // Now you can use the XML with existing ProfileXML classes manually
                System.debug('Manual Processing Options:');
                System.debug('  1. Use ProfileXMLDataManager.parseAndStoreProfile() for parsing only');
                System.debug('  2. Use ProfileXMLMasterManager.parseAndStoreProfile() for full storage');
                System.debug('  3. Use ProfileXMLProcessor.processProfileXML() for legacy storage');
                
            } else {
                System.debug('❌ Profile XML retrieval failed: ' + xmlResult.get('message'));
            }
            
            System.debug('=== Profile XML Retrieval Demonstration Completed ===');
            
        } catch (Exception e) {
            System.debug('❌ Error in XML retrieval demonstration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * @description Demonstrates SOAP processing capabilities summary
     * @param namedCredential The named credential to use for authentication
     */
    public static void demonstrateCapabilitiesSummary(String namedCredential) {
        try {
            System.debug('=== SOAP Processing Capabilities Summary ===');
            System.debug('Named Credential: ' + namedCredential);
            
            // Get capabilities summary
            Map<String, Object> summaryResult = ProfileXMLSOAPBridge.getSOAPProcessingSummary(namedCredential);
            
            if (summaryResult.get('status') == 'success') {
                System.debug('✅ Capabilities summary retrieved successfully');
                System.debug('Summary Details:');
                System.debug('  - Current Credential: ' + summaryResult.get('currentCredential'));
                
                // Display processing capabilities
                List<String> capabilities = (List<String>) summaryResult.get('processingCapabilities');
                if (capabilities != null) {
                    System.debug('  - Processing Capabilities:');
                    for (String capability : capabilities) {
                        System.debug('    * ' + capability);
                    }
                }
                
                // Display profile summary
                Map<String, Object> profileSummary = (Map<String, Object>) summaryResult.get('profileSummary');
                if (profileSummary != null) {
                    System.debug('  - Profile Summary:');
                    System.debug('    * Status: ' + profileSummary.get('status'));
                    if (profileSummary.get('summary') != null) {
                        Map<String, Object> summary = (Map<String, Object>) profileSummary.get('summary');
                        System.debug('    * Total Profiles: ' + summary.get('totalProfiles'));
                        System.debug('    * Custom Profiles: ' + summary.get('customProfiles'));
                        System.debug('    * Standard Profiles: ' + summary.get('standardProfiles'));
                    }
                }
                
                // Display available credentials
                List<String> availableCredentials = (List<String>) summaryResult.get('availableCredentials');
                if (availableCredentials != null) {
                    System.debug('  - Available Credentials:');
                    for (String credential : availableCredentials) {
                        System.debug('    * ' + credential);
                    }
                }
                
            } else {
                System.debug('❌ Capabilities summary failed: ' + summaryResult.get('message'));
            }
            
            System.debug('=== SOAP Processing Capabilities Summary Completed ===');
            
        } catch (Exception e) {
            System.debug('❌ Error in capabilities summary demonstration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * @description Main demonstration method that runs all examples
     * @param namedCredential The named credential to use for authentication
     * @param profileName The name of the profile to process
     */
    public static void runCompleteDemonstration(String namedCredential, String profileName) {
        try {
            System.debug('🚀 Starting Complete SOAP-Integrated Profile XML Demonstration');
            System.debug('=============================================================');
            
            // Run all demonstrations
            demonstrateCapabilitiesSummary(namedCredential);
            System.debug('');
            
            demonstrateSOAPIntegration(namedCredential, profileName);
            System.debug('');
            
            demonstrateXMLRetrieval(namedCredential, profileName);
            System.debug('');
            
            // Demonstrate bulk processing with a few profiles
            List<String> sampleProfiles = new List<String>{profileName};
            demonstrateBulkSOAPProcessing(namedCredential, sampleProfiles);
            System.debug('');
            
            // Demonstrate complete processing (limited to 5 profiles for demo)
            demonstrateCompleteSOAPProcessing(namedCredential, 5);
            System.debug('');
            
            System.debug('🎉 Complete SOAP-Integrated Profile XML Demonstration Finished');
            System.debug('=============================================================');
            
        } catch (Exception e) {
            System.debug('❌ Error in complete demonstration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
}