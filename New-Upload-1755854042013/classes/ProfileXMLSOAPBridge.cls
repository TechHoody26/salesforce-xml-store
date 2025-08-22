/**
 * @description Bridge class that integrates SOAP API calls with existing ProfileXML functionality
 * @author AI Assistant
 * @version 1.0
 * @description This class connects the ProfileDataService SOAP functionality with the existing
 * ProfileXML classes, allowing them to process XML from SOAP responses instead of static input
 */
public with sharing class ProfileXMLSOAPBridge {
    
    /**
     * @description Fetches profile XML from SOAP and processes it using existing ProfileXML classes
     * @param namedCredential The named credential to use for authentication
     * @param profileName The name of the profile to fetch and process
     * @return Map<String, Object> Result containing processing status and data
     * @throws AuraHandledException If any error occurs during the process
     */
    @AuraEnabled
    public static Map<String, Object> processProfileFromSOAP(String namedCredential, String profileName) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Validate inputs
            if (String.isBlank(namedCredential) || String.isBlank(profileName)) {
                throw new AuraHandledException('Named Credential and Profile Name are required');
            }
            
            System.debug('=== Starting SOAP-Integrated Profile Processing ===');
            System.debug('Profile: ' + profileName);
            System.debug('Named Credential: ' + namedCredential);
            
            // Step 1: Fetch XML from SOAP API
            System.debug('Step 1: Fetching XML from SOAP API...');
            String profileXml = ProfileDataService.getProfileCompleteXML(namedCredential, profileName);
            
            if (String.isBlank(profileXml)) {
                throw new AuraHandledException('Empty XML response received from SOAP API');
            }
            
            System.debug('Step 1 Complete: XML fetched successfully');
            System.debug('XML Length: ' + profileXml.length() + ' characters');
            
            // Step 2: Parse XML using existing ProfileXMLDataManager
            System.debug('Step 2: Parsing XML using ProfileXMLDataManager...');
            ProfileXMLDataManager.ProfileData parsedData = ProfileXMLDataManager.parseAndStoreProfile(profileXml, profileName);
            
            System.debug('Step 2 Complete: XML parsed successfully');
            System.debug('Parsed Data Summary:');
            System.debug('  - Application Visibilities: ' + parsedData.applicationVisibilities.size());
            System.debug('  - User Permissions: ' + parsedData.userPermissions.size());
            System.debug('  - Object Permissions: ' + parsedData.objectPermissions.size());
            System.debug('  - Field Permissions: ' + parsedData.fieldPermissions.size());
            System.debug('  - Tab Visibilities: ' + parsedData.tabVisibilities.size());
            
            // Step 3: Store data using existing ProfileXMLMasterManager (if custom objects exist)
            System.debug('Step 3: Attempting to store data using ProfileXMLMasterManager...');
            Map<String, Object> storageResult = attemptDataStorage(profileXml, profileName);
            
            // Step 4: Prepare result
            result.put('status', 'success');
            result.put('profileName', profileName);
            result.put('xmlData', profileXml);
            result.put('parsedData', parsedData);
            result.put('storageResult', storageResult);
            result.put('message', 'Profile successfully processed from SOAP API');
            result.put('processingSteps', new List<String>{
                'SOAP XML Fetch: Success',
                'XML Parsing: Success',
                'Data Storage: ' + (storageResult.get('status') == 'success' ? 'Success' : 'Partial - ' + storageResult.get('message'))
            });
            
            System.debug('=== SOAP-Integrated Profile Processing Completed Successfully ===');
            
        } catch (AuraHandledException e) {
            result.put('status', 'error');
            result.put('message', 'AuraHandledException: ' + e.getMessage());
            result.put('errorType', 'AuraHandledException');
            System.debug('Error in SOAP-Integrated processing: ' + e.getMessage());
            throw e;
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', 'Unexpected error: ' + e.getMessage());
            result.put('errorType', 'Exception');
            result.put('stackTrace', e.getStackTraceString());
            System.debug('Unexpected error in SOAP-Integrated processing: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error processing profile from SOAP: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Processes multiple profiles from SOAP API
     * @param namedCredential The named credential to use for authentication
     * @param profileNames List of profile names to process
     * @return Map<String, Object> Result containing processing status and data for all profiles
     */
    @AuraEnabled
    public static Map<String, Object> processMultipleProfilesFromSOAP(String namedCredential, List<String> profileNames) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Validate inputs
            if (String.isBlank(namedCredential) || profileNames == null || profileNames.isEmpty()) {
                throw new AuraHandledException('Named Credential and Profile Names are required');
            }
            
            System.debug('=== Starting Bulk SOAP-Integrated Profile Processing ===');
            System.debug('Total Profiles to Process: ' + profileNames.size());
            System.debug('Named Credential: ' + namedCredential);
            
            List<Map<String, Object>> profileResults = new List<Map<String, Object>>();
            Integer successCount = 0;
            Integer errorCount = 0;
            
            for (String profileName : profileNames) {
                try {
                    System.debug('Processing profile: ' + profileName);
                    Map<String, Object> profileResult = processProfileFromSOAP(namedCredential, profileName);
                    profileResults.add(profileResult);
                    
                    if (profileResult.get('status') == 'success') {
                        successCount++;
                    } else {
                        errorCount++;
                    }
                    
                } catch (Exception e) {
                    System.debug('Error processing profile ' + profileName + ': ' + e.getMessage());
                    Map<String, Object> errorResult = new Map<String, Object>{
                        'status' => 'error',
                        'profileName' => profileName,
                        'message' => 'Error: ' + e.getMessage(),
                        'errorType' => 'ProcessingError'
                    };
                    profileResults.add(errorResult);
                    errorCount++;
                }
            }
            
            // Prepare bulk result
            result.put('status', 'completed');
            result.put('totalProfiles', profileNames.size());
            result.put('successCount', successCount);
            result.put('errorCount', errorCount);
            result.put('profileResults', profileResults);
            result.put('message', 'Bulk processing completed. ' + successCount + ' successful, ' + errorCount + ' errors');
            
            System.debug('=== Bulk SOAP-Integrated Profile Processing Completed ===');
            System.debug('Success: ' + successCount + ', Errors: ' + errorCount);
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', 'Error in bulk processing: ' + e.getMessage());
            result.put('errorType', 'BulkProcessingError');
            System.debug('Error in bulk SOAP-Integrated processing: ' + e.getMessage());
            throw new AuraHandledException('Error in bulk profile processing: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Fetches and processes all available profiles from SOAP API
     * @param namedCredential The named credential to use for authentication
     * @param maxProfiles Maximum number of profiles to process (default 20)
     * @return Map<String, Object> Result containing processing status and data for all profiles
     */
    @AuraEnabled
    public static Map<String, Object> processAllProfilesFromSOAP(String namedCredential, Integer maxProfiles) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Validate input
            if (String.isBlank(namedCredential)) {
                throw new AuraHandledException('Named Credential is required');
            }
            
            // Set default max profiles if not provided
            if (maxProfiles == null || maxProfiles <= 0) {
                maxProfiles = 20;
            }
            
            System.debug('=== Starting Complete SOAP-Integrated Profile Processing ===');
            System.debug('Max Profiles: ' + maxProfiles);
            System.debug('Named Credential: ' + namedCredential);
            
            // Step 1: Get list of available profiles
            System.debug('Step 1: Getting list of available profiles...');
            List<ProfileDataService.ProfileWrapper> availableProfiles = ProfileDataService.getProfilesViaSOAP(namedCredential, maxProfiles);
            
            if (availableProfiles == null || availableProfiles.isEmpty()) {
                result.put('status', 'warning');
                result.put('message', 'No profiles found to process');
                result.put('totalProfiles', 0);
                return result;
            }
            
            System.debug('Step 1 Complete: Found ' + availableProfiles.size() + ' profiles');
            
            // Step 2: Extract profile names
            List<String> profileNames = new List<String>();
            for (ProfileDataService.ProfileWrapper profile : availableProfiles) {
                if (String.isNotBlank(profile.Name)) {
                    profileNames.add(profile.Name);
                }
            }
            
            System.debug('Step 2 Complete: Extracted ' + profileNames.size() + ' profile names');
            
            // Step 3: Process all profiles
            System.debug('Step 3: Processing all profiles...');
            Map<String, Object> processingResult = processMultipleProfilesFromSOAP(namedCredential, profileNames);
            
            // Step 4: Prepare complete result
            result.put('status', 'completed');
            result.put('totalProfiles', profileNames.size());
            result.put('processingResult', processingResult);
            result.put('message', 'Complete profile processing finished. Processed ' + profileNames.size() + ' profiles');
            
            System.debug('=== Complete SOAP-Integrated Profile Processing Finished ===');
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', 'Error in complete profile processing: ' + e.getMessage());
            result.put('errorType', 'CompleteProcessingError');
            System.debug('Error in complete SOAP-Integrated processing: ' + e.getMessage());
            throw new AuraHandledException('Error in complete profile processing: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Attempts to store profile data using existing ProfileXMLMasterManager
     * @param profileXml The profile XML to store
     * @param profileName The name of the profile
     * @return Map<String, Object> Result of storage attempt
     */
    private static Map<String, Object> attemptDataStorage(String profileXml, String profileName) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Try to use ProfileXMLMasterManager to store the data
            ProfileXMLMasterManager.parseAndStoreProfile(profileXml, profileName);
            
            result.put('status', 'success');
            result.put('message', 'Profile data successfully stored using ProfileXMLMasterManager');
            result.put('storageMethod', 'ProfileXMLMasterManager');
            
        } catch (Exception e) {
            // If ProfileXMLMasterManager fails, try ProfileXMLProcessor as fallback
            try {
                ProfileXMLProcessor.processProfileXML(profileXml);
                
                result.put('status', 'partial');
                result.put('message', 'Profile data stored using ProfileXMLProcessor fallback. ProfileXMLMasterManager failed: ' + e.getMessage());
                result.put('storageMethod', 'ProfileXMLProcessor');
                result.put('fallbackReason', 'ProfileXMLMasterManager failed: ' + e.getMessage());
                
            } catch (Exception fallbackError) {
                result.put('status', 'failed');
                result.put('message', 'Both storage methods failed. MasterManager: ' + e.getMessage() + '. Processor: ' + fallbackError.getMessage());
                result.put('storageMethod', 'None');
                result.put('masterManagerError', e.getMessage());
                result.put('processorError', fallbackError.getMessage());
            }
        }
        
        return result;
    }
    
    /**
     * @description Gets profile XML from SOAP and returns it for manual processing
     * @param namedCredential The named credential to use for authentication
     * @param profileName The name of the profile to fetch
     * @return Map<String, Object> Result containing the XML data
     */
    @AuraEnabled
    public static Map<String, Object> getProfileXMLForManualProcessing(String namedCredential, String profileName) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Validate inputs
            if (String.isBlank(namedCredential) || String.isBlank(profileName)) {
                throw new AuraHandledException('Named Credential and Profile Name are required');
            }
            
            // Fetch XML from SOAP API
            String profileXml = ProfileDataService.getProfileCompleteXML(namedCredential, profileName);
            
            if (String.isBlank(profileXml)) {
                throw new AuraHandledException('Empty XML response received from SOAP API');
            }
            
            result.put('status', 'success');
            result.put('profileName', profileName);
            result.put('xmlData', profileXml);
            result.put('xmlLength', profileXml.length());
            result.put('message', 'Profile XML retrieved successfully for manual processing');
            
            // Also provide parsed data for reference
            try {
                ProfileXMLDataManager.ProfileData parsedData = ProfileXMLDataManager.parseAndStoreProfile(profileXml, profileName);
                result.put('parsedData', parsedData);
                result.put('hasParsedData', true);
            } catch (Exception parseError) {
                result.put('hasParsedData', false);
                result.put('parseError', parseError.getMessage());
            }
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', 'Error retrieving profile XML: ' + e.getMessage());
            result.put('errorType', 'XMLRetrievalError');
            throw new AuraHandledException('Error retrieving profile XML: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Validates SOAP connection and returns available profiles
     * @param namedCredential The named credential to validate
     * @return Map<String, Object> Validation result and available profiles
     */
    @AuraEnabled
    public static Map<String, Object> validateSOAPConnection(String namedCredential) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Validate input
            if (String.isBlank(namedCredential)) {
                throw new AuraHandledException('Named Credential is required');
            }
            
            System.debug('=== Validating SOAP Connection ===');
            System.debug('Named Credential: ' + namedCredential);
            
            // Test SOAP connection
            Boolean isValid = ProfileDataService.validateNamedCredential(namedCredential);
            
            if (!isValid) {
                result.put('status', 'error');
                result.put('message', 'SOAP connection validation failed');
                result.put('isValid', false);
                return result;
            }
            
            // Get available profiles
            List<ProfileDataService.ProfileWrapper> availableProfiles = ProfileDataService.getProfilesViaSOAP(namedCredential, 10);
            
            result.put('status', 'success');
            result.put('isValid', true);
            result.put('message', 'SOAP connection validated successfully');
            result.put('availableProfiles', availableProfiles);
            result.put('profileCount', availableProfiles != null ? availableProfiles.size() : 0);
            
            System.debug('=== SOAP Connection Validation Successful ===');
            System.debug('Available Profiles: ' + (availableProfiles != null ? availableProfiles.size() : 0));
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', 'Error validating SOAP connection: ' + e.getMessage());
            result.put('isValid', false);
            result.put('errorType', 'ValidationError');
            System.debug('Error in SOAP connection validation: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Gets a summary of SOAP-integrated processing capabilities
     * @param namedCredential The named credential to use
     * @return Map<String, Object> Summary of processing capabilities
     */
    @AuraEnabled
    public static Map<String, Object> getSOAPProcessingSummary(String namedCredential) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Validate input
            if (String.isBlank(namedCredential)) {
                throw new AuraHandledException('Named Credential is required');
            }
            
            // Get profile summary
            Map<String, Object> profileSummary = ProfileDataController.getProfileSummaryEnhanced(namedCredential);
            
            // Get available named credentials
            List<String> availableCredentials = ProfileDataService.getAvailableNamedCredentials();
            
            result.put('status', 'success');
            result.put('profileSummary', profileSummary);
            result.put('availableCredentials', availableCredentials);
            result.put('currentCredential', namedCredential);
            result.put('processingCapabilities', new List<String>{
                'SOAP XML Fetching',
                'XML Parsing via ProfileXMLDataManager',
                'Data Storage via ProfileXMLMasterManager',
                'Fallback Storage via ProfileXMLProcessor',
                'Bulk Profile Processing',
                'Real-time SOAP Integration'
            });
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', 'Error getting SOAP processing summary: ' + e.getMessage());
            result.put('errorType', 'SummaryError');
        }
        
        return result;
    }
}