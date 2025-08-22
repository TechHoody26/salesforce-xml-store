public with sharing class admf_QueueableController implements Queueable, Database.AllowsCallouts {
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new TC_MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
    String adminifiedOrgId;
    String namedCredential;
    public static Map<String, String> errorMap = new Map<String, String>();

    public admf_QueueableController(String adminifiedOrgId, String namedCredential) {
        this.adminifiedOrgId = adminifiedOrgId;
        this.namedCredential = namedCredential;
        System.debug('Current User Id - admf_QueueableController - ' + UserInfo.getUserId());
    }

    public void execute(QueueableContext context) {
        try {
            TC_MetadataService.MetadataPort service = admf_MetadataAPI.createService(this.namedCredential);
            TC_MetadataService.RetrieveRequest request = new TC_MetadataService.RetrieveRequest();
            request.singlePackage = true;
            request.packageNames = null;
            request.specificFiles = null;
            request.apiVersion = METADATA_API_VERSION;
            request.unpackaged = new TC_MetadataService.Package_x();
            request.unpackaged.types = new List<TC_MetadataService.PackageTypeMembers>();
            List<String> customObjectMembers = new List<String>();
            for (Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()) {
                Schema.DescribeSObjectResult describeSObjectResultObj = objTyp.getDescribe();
                String name = objTyp.getDescribe().getName();
                if (!name.contains('__c') && !name.containsignorecase('history') && !name.containsignorecase('tag') && !name.containsignorecase('share') && !name.containsignorecase('feed')) {
                    customObjectMembers.add(name);
                }
            }
            customObjectMembers.add('*');
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('CustomObject', customObjectMembers));
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('PermissionSet', new List<String>{ '*' }));  
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('Profile', new List<String>{ '*' }));  
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('Layout', new List<String>{ '*' }));  
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('CustomTab', new List<String>{ '*' }));  
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('ExternalDataSource', new List<String>{ '*' }));  
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('ApexClass', new List<String>{ '*' }));  
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('CustomApplication', new List<String>{ '*' }));  
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('ApexPage', new List<String>{ '*' }));  
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('NamedCredential', new List<String>{ '*' }));
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('Settings', new List<String>{ '*' }));
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('CustomPermission', new List<String>{ '*' }));
            request.unpackaged.types.add(admf_MetadataAPI.getPackageTypeMembers('Flow', new List<String>{ '*' }));
            TC_MetadataService.AsyncResult asyncResult = service.retrieve(request);
            String asyncId = '';
            if (asyncResult.Id != '' && asyncResult.Id != null) {
                asyncId = asyncResult.Id;
                 system.debug('asyncResult.Id: '+asyncResult.Id);
                insertMetadataLog(asyncResult.Id, this.adminifiedOrgId);

            }            
            System.debug('Async ID stored: ' + asyncId);
            System.debug('Metadata retrieval simulation completed successfully');
            
        } catch (Exception e) {
            System.debug('Error in metadata retrieval: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            
            // Store error information
            errorMap.put('error', e.getMessage());
            errorMap.put('stackTrace', e.getStackTraceString());
        }
    }
    
    public static void insertMetadataLog(String asyncId, String orgId) {
        TC_Metadata_Logs__c metadataLog = new TC_Metadata_Logs__c(Async_Id__c = asyncId, Is_Completed__c = false,Developer_Org__c =orgId);
        insert metadataLog;
        
    }
}