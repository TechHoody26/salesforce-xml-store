/**
* @Author: Praveen Malviya
* @Date: 2025-06-13
* @Description: POLN-374 Handles RMA orders, asset swaps, SKU checks, and updates to defective assets.
*/

public class RMAOrderHandler {
    public static Order CreateOrderWithOrderLines(Id rmaId) {
        
        Order clonedOrder;
        if (rmaId == null) {
            System.debug('Error: RMA ID cannot be null.');
            return null;
        }
        try {
            //Fetch the RMA record
            RMA__c rma;
            try {
                rma = [
                    SELECT Id,Name, Order_Type__c, Order_Type_Code__c, Status__c, Serial_Number__c, SFDC_Order__c, Case_RMA__c,
                    Ship_to_Customer__c,Ship_to_contact__c,Ship_to_Address__c,To_be_Installed_At__c FROM RMA__c WHERE Id = :rmaId LIMIT 1
                ];  
            } catch (Exception e) {
                System.debug('Error: No RMA record found for ID' + rmaId);
                errorLogException(
                    'RMA__c', 
                    'RMAOrderHandler', 
                    'CreateOrderWithOrderLines', 
                    'rmaId => '+rmaId, 
                    'Error: No RMA record found for ID'
                );
                return null;
            }
            // Validate RMA Status
            if (rma.Status__c != 'Submitted') {
                System.debug('RMA is not Submitted.');
                return null;
            }
            
            RMA_Order_Type__mdt orderTypes = [
                SELECT 
                MasterLabel, Label, QualifiedApiName, Order_SubType__c 
                FROM 
                RMA_Order_Type__mdt 
                WHERE 
                QualifiedApiName =: rma.Order_Type__c 
                LIMIT 1
            ];
            
            Asset defAsset = [
                SELECT 
                Id,Service_Level__c, Asset_Deal_Type__c,SBQQ__OrderProduct__r.Order.Alvo_Bill_To_Address__c, Order_Number__c, SBQQ__OrderProduct__r.OrderId
                FROM 
                Asset 
                WHERE 
                Name =: rma.Serial_Number__c 
                Limit 1
            ];
            
            List<Order> originalOrders = [SELECT Id,Alvo_Deal_Type__c FROM Order WHERE OrderNumber =: defAsset.Order_Number__c];
            
            //  Create the new Order
            clonedOrder = new Order();
            clonedOrder.Status = 'Draft';
            clonedOrder.Type = 'RMA';
            clonedOrder.AccountId = rma.Ship_to_Customer__c;
            clonedOrder.PoNumber = rma.Name;
            clonedOrder.Sub_Type__c = orderTypes.Order_SubType__c;
            clonedOrder.RMA_Order_Id__c = rma.Id;
            clonedOrder.Case__c = rma.Case_RMA__c;
            clonedOrder.Serial__c = defAsset.Id;
            clonedOrder.Alvo_Primary_Contact__c = rma.Ship_to_contact__c;
            clonedOrder.Alvo_Technical_Point_of_Contact__c = rma.Ship_to_contact__c;
            clonedOrder.Alvo_Ship_To_Address__c  =  rma.Ship_to_Address__c;
            clonedOrder.EffectiveDate = Date.today();
            clonedOrder.Requested_Activation_Date__c = Date.today();
            clonedOrder.Alvo_Bill_To_Address__c = defAsset.SBQQ__OrderProduct__r.Order.Alvo_Bill_To_Address__c;       
            clonedOrder.Legal_Entity__c ='US_Legal_Entity';
            clonedOrder.Order_OM_DL__c  =   'rvbd-om@riverbed.com';
            clonedOrder.Pricebook2Id    =   getPriceBookId();
            clonedOrder.RecordTypeId    =   System.Label.RMA_Order_RecordType_Id;
            clonedOrder.Alvo_Overall_Screening_Results__c = 'Pass';
            clonedOrder.Alvo_Deal_Type__c =originalOrders.isEmpty()?'':originalOrders[0].Alvo_Deal_Type__c;
            clonedOrder.Original_Order__c = originalOrders.isEmpty()?null:originalOrders[0].Id;
            
            
            try {
                insert clonedOrder;
                rma.SFDC_Order__c = clonedOrder.Id;
                rma.Status__c = 'Order Created - Not Activated';
                update rma;
                System.debug('New Order created with ID:' + clonedOrder.Id);
            } catch (DmlException e) {
                System.debug('Error creating Order:' + e.getMessage());
                errorLogException(
                    'RMA__c', 
                    'RMAOrderHandler', 
                    'CreateOrderWithOrderLines', 
                    rma.Name, 
                    e.getMessage()
                );
                return null;
            }
            
            //Fetch associated RMA Order Lines
            List<RMA_Order_Line__c> rmaOrderLines = [
                SELECT 
                Id, Product__c, Qty__c, Item_Type__c, Line_Type__c, Product__r.Consumable__c, Product__r.RVBD_Inventory__c,SKU__c,Base_Item__c
                FROM 
                RMA_Order_Line__c 
                WHERE 
                RMA_Order__c = :rmaId
            ];
            system.debug('rmaOrderLines ->>>> '+rmaOrderLines);
            if (rmaOrderLines.isEmpty()){
                System.debug('No Order Lines found for the given RMA.');
                return clonedOrder;
            }
            Set<String> skuProductCodes = new Set<String>();
            
            for (RMA_Order_Line__c line : rmaOrderLines) {
                if (line.SKU__c != null) {
                    skuProductCodes.add(line.SKU__c);
                }
            }
            
            List<Product2> skuProductList = [SELECT Id,name,ProductCode FROM Product2 where ProductCode IN :  skuProductCodes];
            // Create a map with ProductCode as the key and Id as the value
            Map<String, Id> productCodeToIdMap = new Map<String, Id>();
            
            for (Product2 prod : skuProductList) {
                productCodeToIdMap.put(prod.ProductCode, prod.Id);
            }
            
            //Create Order Items from RMA Order Lines
            List<OrderItem> orderItems = new List<OrderItem>();
            for (RMA_Order_Line__c line : rmaOrderLines){
                if(productCodeToIdMap.get(line.SKU__c) != null){
                    Id pricebookEntryId = getPricebookEntryId(productCodeToIdMap.get(line.SKU__c));
                    System.debug('Product:' + line.Product__c + 'Product sku:' + productCodeToIdMap.get(line.SKU__c) + ', PricebookEntryId:' + pricebookEntryId);
                    
                    if (pricebookEntryId != null){
                        Decimal unitPrice = getProductPrice(pricebookEntryId);
                        if (unitPrice == null) {
                            System.debug('No Unit price found for Product:' + line.Product__c);
                            continue;
                        }
                        
                        if(line.Line_Type__c == 'Order'){
                            orderItems.add(new OrderItem(
                                OrderId = clonedOrder.Id,
                                Product2Id = productCodeToIdMap.get(line.SKU__c),
                                Quantity = line.Qty__c,
                                PricebookEntryId = pricebookEntryId,
                                UnitPrice = unitPrice,
                                RMA_Order_Line__c = line.ID,
                                Alvo_Ship_To_Address__c=rma.Ship_to_Address__c
                            ));
                        }else{
                            if(checkServiceLevel(rma,line,defAsset)) {
                                orderItems.add(new OrderItem(
                                    OrderId = clonedOrder.Id,
                                    Product2Id = productCodeToIdMap.get(line.SKU__c),
                                    Quantity = -line.Qty__c,
                                    PricebookEntryId = pricebookEntryId,
                                    UnitPrice = unitPrice,
                                    RMA_Order_Line__c = line.ID,
                                    Alvo_Ship_To_Address__c=rma.Ship_to_Address__c
                                ));
                            }
                        }
                    } else {
                        System.debug('Skipping OrderItem for Product:' + getPricebookEntryId(productCodeToIdMap.get(line.SKU__c)) + '(No Pricebook Entry).');
                    }
                }
                
            }
            if (!orderItems.isEmpty()){
                try {
                    insert orderItems;
                    System.debug('OItems ::: '+orderItems);
                    System.debug('Order Items created successfully.');
                    clonedOrder.Status = 'Activated';
                    rma.Status__c = 'Order Created - Activated';
                    update clonedOrder;
                    update rma;
                    
                } catch (DmlException e) {
                    System.debug('Error creating Order Items:' + e.getMessage());
                    errorLogException(
                        'RMA__c', 
                        'RMAOrderHandler', 
                        'CreateOrderWithOrderLines', 
                        rma.Name, 
                        e.getMessage()
                    );
                }
            }
            return clonedOrder;
        } catch (Exception e) {
            System.debug('Unexpected Error:' + e.getMessage());
            errorLogException(
                'RMA__c', 
                'RMAOrderHandler', 
                'CreateOrderWithOrderLines', 
                rmaId, 
                e.getMessage()
            );
            return null;
        }
    }
    
    public static Id getPriceBookId(){
        Pricebook2 pb = [Select Id, Name from Pricebook2 where Name = 'Alluvio Price Book' and IsActive = true];
        return pb.Id;
    }
    
    //Method for Swapping Asset
    public static void swapAsset(Map<Id, Order> assetToOrderMap) {        
        
        Set<Id> assetIds = assetToOrderMap.keySet();
        
        System.debug('AssetIds::>>>>'+assetIds);
        System.debug('Mappp::>>>>'+assetToOrderMap);
        
        Set<Id> rmaIds = new Set<Id>();
        for(Order ord : assetToOrderMap.values()) {
            rmaIds.add(ord.RMA_Order_Id__c);
            System.debug('ord Id => '+ord.Id);
        }
        
        Map<Id, RMA__c> rmaRecords = new Map<Id, RMA__c> (
            [
                SELECT 
                Id, Name, Case_RMA__c, RMA_Header_Id__c, RMA_Order_Number__c, SFDC_Header_ID__c, New_Token_Serial_Number__c, 
                Token_Status__c, RCA_Requested__c, Is_Task__c, Processed_Flag__c, Status__c, Order_Type_Code__c, Additional_Notification__c, 
                Configuration__c, Customer_Number__c, Customer_Ref_number__c, Customer_requested_date_time__c, Install_at_Address__c, IOR_status__c, 
                Problem_description__c, RIOS__c, Saturday_Delivery__c, Serial_Number__c, SFDC_contact_email__c, Cold_Spare_Check_box__c, Mobile__c, 
                Order_Type__c, Custom_Preconfig_Contract_Mfg__c, Problem_Code__c, Return_Instructions_email__c, To_be_Installed_At__c, Engineer_Email__c, 
                NS_Return_Order__c, NS_RMA_Order__c, Service_Provider__c, Ship_to_Customer__c, Shipping_Method__c, Spare_Unit_Serial_number__c, SMS_Option__c, 
                Coverage__c, Contract_Service_Type__c, Logistics_Provider__c, Ship_to_Address__c, Ship_to_contact__c, Owner__c, Timezone__c, Country__c, 
                SFDC_Order__c,
                (
                    SELECT 
                    Id, Name, RMA_Order__c, Qty__c, Product__c, Line_Type__c, NS_Product_Id__c, Item_Type__c,Base_Item__c,
                    Product__r.ProductCode,Product__r.RVBD_Inventory__c,Product__r.Consumable__c
                    FROM 
                    RMA_Order_Lines__r 
                    WHERE 
                    Line_Type__c = 'Return')
                FROM 
                RMA__c 
                WHERE 
                Id in: rmaIds
            ]
        );
        
        System.debug('rmaRecords ? => '+rmaRecords.keySet());
        
        Set<Id> addresseSet = new Set<Id>();
        
        Map<String,String> defectiveToSpareUnitAssetMap = new Map<String,String>();
        Map<String,String> SpareUnitToDefectiveAssetMap = new Map<String,String>();
        Map<Id, RMA_Order_Line__c> rmaLineMap = new Map<Id, RMA_Order_Line__c>();
        
        Set<String> DefAndSpareUnitAssetNames = new Set<String>();
        for(RMA__c rmaRec : rmaRecords.values()) {
            System.debug('rmaRec number ==> '+rmaRec.Name);
            rmaLineMap.put(rmaRec.Id,rmaRec.RMA_Order_Lines__r[0]);
            addresseSet.add(rmaRec.Ship_to_Address__c);
            addresseSet.add(rmaRec.To_be_Installed_At__c);
            
            defectiveToSpareUnitAssetMap.put(rmaRec.Serial_Number__c,rmaRec.Spare_Unit_Serial_number__c);
            DefAndSpareUnitAssetNames.add(rmaRec.Spare_Unit_Serial_number__c);
            DefAndSpareUnitAssetNames.add(rmaRec.Serial_Number__c);
            if(rmaRec.Cold_Spare_Check_box__c == true){
                SpareUnitToDefectiveAssetMap.put(rmaRec.Spare_Unit_Serial_number__c,rmaRec.Serial_Number__c);
            }
        }
        
        Map<String,Asset> DefAndSpareUnitAssetsMap = new Map<String,Asset>();
        
        List<Asset> assets = [SELECT ID,Name FROM Asset WHERE Name in: DefAndSpareUnitAssetNames];
        System.debug('DefAndSpareUnitAssetNames::>>>>'+DefAndSpareUnitAssetNames);
        System.debug('defectiveToSpareUnitAssetMap ==> '+ defectiveToSpareUnitAssetMap);
        System.debug('Assets::>>>>'+assets);
        for(Asset assetRec : assets) {
            DefAndSpareUnitAssetsMap.put(assetRec.Name,assetRec);
        }
        System.debug('DefAndSpareUnitAssetsMap::>>>>'+DefAndSpareUnitAssetsMap);        
        
        Map<Id, RVBD_Addresses__c > addresseMap = new Map<Id, RVBD_Addresses__c >([
            select 
            Id, Name, Alvo_Account__c, Alvo_Active__c, Alvo_Address_1__c, Alvo_Address_2__c, Alvo_Address_3__c, 
            Alvo_City__c, Alvo_Country__c, Alvo_County__c, Alvo_Oracle_Address_Id__c, Alvo_Org_Id__c, Alvo_Postal_Code__c, 
            Alvo_Primary__c, Alvo_State__c, Alvo_Type__c, NS_Last_Sync__c, Name_of_the_Address__c, Netsuite_ID__c, RVBD_Revenue_Code__c, 
            VAT_ID__c, Legal_Entity__c, Billing_Email_Addresses__c, X18_Character_Address_ID__c, Resale_RVBD_Rev_Code__c 
            from 
            RVBD_Addresses__c 
            where id in : addresseSet
        ]);
        
        Map<String,Asset> soldSpareAssetRecordsMap = new Map<String,Asset>();
        
        for(Asset assetRec : [Select Id, Name,Defective_Asset__c, IB_Status__c from Asset where Name in: SpareUnitToDefectiveAssetMap.keySet()]) {
            soldSpareAssetRecordsMap.put(assetRec.Name,assetRec);
        }
        
        /*if (assetIds == null || assetIds.isEmpty()) {
return;
}*/
        //Query parent assets
        List<Asset> parentAssets = [
            SELECT 
            ID, Contract__c, Contract__r.Pricebook2Id, Product2Id,Product2.Name, Contract__r.Account.id, Contract__r.SBQQ__Opportunity__r.id,
            AccountId, ParentId, RootAssetId,ProductCode, ProductFamily, ProductDescription,IsCompetitorProduct, CurrencyIsoCode, Name, Price, 
            Quantity, Description, StockKeepingUnit,HasLifecycleManagement, SupportStartDate__c, Asset_Owner__c, Contract_Creation_Date__c,Contract_Number__c, 
            Support_End_Date__c, SKU__c, Short_Name__c, Current_Location_Name__c,Ship_To_State__c, Ship_To_Postal_Code__c, Ship_To_Name__c, Ship_To_Country__c, 
            Ship_To_City__c,Installed_At_Address_Confirmed__c, Registered__c, Opportunity__c, Order_Number__c, PO_Number__c,Contract_Level__c,
            Calculated_Contract_Status__c, Asset_Status__c, Sysdump_Identifier__c,Sysdump_URL__c,Asset_Status_TEXT__c,Support_Provider__c,Contract_Customer__c, 
            RMA_Requested__c,Chassis_Type__c, Contract_Owner__c, End_Customer__c, Auto_Eval__c, Opportunity_Close_Date__c,Date_Comparison__c, 
            Opportunity_Owner_Region__c, Account_Most_Recent_Partner__c,Opportunity_Owner_GEO__c, X18_Character_Account_ID__c, Account_Status__c, Parent_Asset__c,
            RVBD_Product_Family__c, Account_Owner_Region__c, Is_My_Alignment__c, Account_Owner_GEO__c,Billing_Address_State__c, Estimated_Refresh_Amt__c, 
            Opportunity_Trial_Program__c, D_B_County__c,Base_Sku__c, Force_Sync__c, Refresh_EvalEndDate__c, Service_Name__c, Product_Sub_Family__c,
            Billing_Address_City__c, Last_Xirrus_Sync_Pending__c, Xirrus_Support_End_Date__c,Xirrus_Sync_Required__c, ProductName__c, IsDelete_Xirrus__c, 
            SBQQ__BillingFrequency__c,SBQQ__BillingType__c, SBQQ__Bundle__c, SBQQ__BundledQuantity__c, SBQQ__Bundled__c,SBQQ__ChargeType__c, SBQQ__CombineKey__c, 
            SBQQ__ComponentDiscountedByPackage__c,SBQQ__CurrentSubscription__c, SBQQ__DistributorDiscount__c, SBQQ__DynamicOptionId__c,SBQQ__FromServiceCloud__c,
            SBQQ__LatestQuoteLine__c, SBQQ__ListPrice__c, SBQQ__Number__c,SBQQ__OptionLevel__c, SBQQ__OptionType__c, SBQQ__OrderProduct__c, SBQQ__OriginalUnitCost__c,
            SBQQ__PricingMethod__c, SBQQ__ProductOption__c, SBQQ__QuoteLine__c, SBQQ__RegularPrice__c,SBQQ__RequiredByProduct__c, SBQQ__RequiredBySubscription__c, 
            SBQQ__RootId__c,AVA_SFCPQ__SalesTaxAmount__c, Is_SaaS_Portfolio__c, Alvo_Alluvio_Serial_Number__c,Alvo_Asset_Quantity__c,Alvo_Asset_Start_Date__c, 
            Alvo_Purchase_Token__c, AssetStatus__c, Deal_Type__c,Primary_Contact_Email__c, Primary_Contact_Name__c, Reprocess_Provisioning__c,
            Trigger_Provisioning_callout__c, Provisioning_Action__c, Alvo_Contract_URL__c,Alvo_Contract_Number__c, Alvo_Send_Provisioning_Email__c,
            Alvo_Asset_Suspension_Date__c,Alvo_Asset_Unsubscribe__c, X15_digit_Account_Id__c, Asset_Deal_Type__c,End_Customer_18_Character_ID__c, 
            Account_Eligibility__c, Child_Assets__c, Is_Migrated_Asset__c, Is_SerialNumber_Updated__c, Is_Serializable__c,ATNY_SaaSSyncRequired__c, 
            ATNY_SaaS_Reprocess__c, ATNY_Sent_Provisioning_Email__c,KS_Lic_Status__c, KS_Send_Email__c,Level_6_Family__c, Support_End_Date_Template__c,
            Support_Start_Date_Template__c,Defective_Asset__c,NS_Temp_Sync_Complete__c,Service_Level__c,Alvo_Installed_At_Address__c, IB_Status__c
            FROM 
            Asset 
            WHERE 
            Id in : assetIds          
        ];
        
        //Custom metadata for Asset query
        //Midas_RMA_Setting__mdt assetMeta = Midas_RMA_Setting__mdt.getInstance('AssetQuery');
        //String soqlQuery = assetMeta.Asset_Fields_to_Query__c;
        //List<Asset> parentAssets =  Database.query(soqlQuery);
        
        //Query child assets of the given parent assets
        List<Asset> childAssetList = [
            SELECT id,name,SerialNumber,ProductCode,ParentId,RootAssetId,IB_Status__c,Defective_Asset__c 
            FROM asset 
            WHERE ParentId IN: assetIds            
        ];
        
        //Clone the parent assets
        List<Asset> clonedParents = new List<Asset>();
        Map<Id, Asset> oldToNewParentIdMap = new Map<Id, Asset>();
        
        for (Asset original : parentAssets) {
            
            if(checkAssetCreation(original,rmaRecords,rmaLineMap,assetToOrderMap)){
                System.debug('Create Line => '+original.Service_Level__c);
                // New/Replacement Asset Creation
                Asset clonedAsset = original.clone(false, true, false, false);
                Id shipToAddressId = rmaRecords.get(assetToOrderMap.get(original.Id).RMA_Order_Id__c).Ship_to_Address__c;
                Id toBeInstalledAtAddressId = rmaRecords.get(assetToOrderMap.get(original.Id).RMA_Order_Id__c).To_be_Installed_At__c;
                System.debug('shipToAddressId => '+shipToAddressId);
                
                if(rmaRecords.get(assetToOrderMap.get(original.Id).RMA_Order_Id__c).Cold_Spare_Check_box__c) {
                    System.debug('Cold_Spare_Check_box__c =>'+rmaRecords.get(assetToOrderMap.get(original.Id).RMA_Order_Id__c).Cold_Spare_Check_box__c);
                    clonedAsset.Name = clonedAsset.Name + ' - RMA';
                    clonedAsset.IB_Status__c = 'Sold - Spare';
                    clonedAsset.Deal_Type__c = 'RMA_ORDER';
                    clonedAsset.RMA_Order__c = (Id)(assetToOrderMap.get(original.Id).RMA_Order_Id__c);
                    clonedAsset.Order_Number__c = assetToOrderMap.get(original.Id).OrderNumber;
                    clonedAsset.Ship_To_Address_1__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Address_1__c : '';
                    clonedAsset.Ship_To_Address_2__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Address_2__c : '';
                    clonedAsset.Ship_To_Address_3__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Address_3__c : '';
                    clonedAsset.Ship_To_City__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_City__c : '';
                    clonedAsset.Ship_To_Country__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Country__c : '';
                    clonedAsset.Ship_To_Name__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Name : '';
                    clonedAsset.Ship_To_Postal_Code__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Postal_Code__c : '';
                    clonedAsset.Ship_To_State__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_State__c : '';
                    
                    clonedAsset.Installed_At_Address_1__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Address_1__c : '';
                    clonedAsset.Installed_At_Address_2__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Address_2__c : '';
                    clonedAsset.Installed_At_Address_3__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Address_3__c : ''; 
                    clonedAsset.Installed_At_City__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_City__c : '';
                    clonedAsset.Installed_At_Country__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Country__c : '';
                    clonedAsset.Installed_At_Name__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Name : '';
                    clonedAsset.Installed_At_Postal_Code__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Postal_Code__c : '';
                    clonedAsset.Installed_At_State__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_State__c : '';
                    
                    clonedAsset.Alvo_Installed_At_Address__c = toBeInstalledAtAddressId;

                } else {
                    System.debug('Cold_Spare_Check_box__c =>'+rmaRecords.get(assetToOrderMap.get(original.Id).RMA_Order_Id__c).Cold_Spare_Check_box__c);
                    //POLN-899 Changes Made By Praveen Malviya 23-05-2025
                    clonedAsset.Name = clonedAsset.Name + ' - RMA';     
                    clonedAsset.Defective_Asset__c = original.Id;
                  //clonedAsset.IB_Status__c = 'Replacement';
                    clonedAsset.IB_Status__c = (original.IB_Status__c != 'Sold - HW SUBSCR' && original.IB_Status__c != 'Under Evaluation') ? 'Replacement' : original.IB_Status__c;
                    clonedAsset.Deal_Type__c = 'RMA_ORDER';
                    clonedAsset.NS_Temp_Sync_Complete__c = FALSE;
                    clonedAsset.KS_Lic_Status__c = 'Sync required';
                    clonedAsset.RMA_Order__c = (Id)(assetToOrderMap.get(original.Id).RMA_Order_Id__c);
                    clonedAsset.Order_Number__c = assetToOrderMap.get(original.Id).OrderNumber;
                    clonedAsset.Ship_To_Address_1__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Address_1__c : '';
                    clonedAsset.Ship_To_Address_2__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Address_2__c : '';
                    clonedAsset.Ship_To_Address_3__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Address_3__c : '';
                    clonedAsset.Ship_To_City__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_City__c : '';
                    clonedAsset.Ship_To_Country__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Country__c : '';
                    clonedAsset.Ship_To_Name__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Name : '';
                    clonedAsset.Ship_To_Postal_Code__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_Postal_Code__c : '';
                    clonedAsset.Ship_To_State__c = addresseMap.get(shipToAddressId) != null ? addresseMap.get(shipToAddressId).Alvo_State__c : '';
                    
                    clonedAsset.Installed_At_Address_1__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Address_1__c : '';
                    clonedAsset.Installed_At_Address_2__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Address_2__c : '';
                    clonedAsset.Installed_At_Address_3__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Address_3__c : ''; 
                    clonedAsset.Installed_At_City__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_City__c : '';
                    clonedAsset.Installed_At_Country__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Country__c : '';
                    clonedAsset.Installed_At_Name__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Name : '';
                    clonedAsset.Installed_At_Postal_Code__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_Postal_Code__c : '';
                    clonedAsset.Installed_At_State__c = addresseMap.get(toBeInstalledAtAddressId) != null ? addresseMap.get(toBeInstalledAtAddressId).Alvo_State__c : '';
                    
                    clonedAsset.Alvo_Installed_At_Address__c = toBeInstalledAtAddressId;

                }
                clonedParents.add(clonedAsset);
                // Will map after insert when Ids are generated
            }else{
                System.debug('Do not create line => '+original.Service_Level__c);
            }
            
            
        }
        
        if (!clonedParents.isEmpty()) {
            try{
                insert clonedParents;
            } catch(Exception e){
                errorLogException(
                    'RMA__c', 
                    'RMAOrderHandler', 
                    'swapAsset', 
                    'rmaId => '+rmaIds, 
                    e.getMessage()
                );
            }
            System.debug('clonedParents >>> '+ clonedParents.size());
            
            // Map original parent Ids to new cloned asset Ids
            for (Integer i = 0; i < parentAssets.size(); i++) {
                oldToNewParentIdMap.put(parentAssets[i].Id, clonedParents[i]);
            }
            
            //Re-parent child assets to the newly cloned parents
            Asset clonedAsset;
            for (Asset childAsset : childAssetList) {
                if (oldToNewParentIdMap.containsKey(childAsset.ParentId)) {
                    clonedAsset = oldToNewParentIdMap.get(childAsset.ParentId);
                    
                    if(rmaRecords.get(assetToOrderMap.get(childAsset.ParentId).RMA_Order_Id__c).Cold_Spare_Check_box__c) {
                        childAsset.ParentId = soldSpareAssetRecordsMap.get(
                            rmaRecords.get(
                                assetToOrderMap.get(childAsset.ParentId).RMA_Order_Id__c
                            ).Spare_Unit_Serial_number__c
                        ).Id;
                        //childAsset.IB_Status__c = 'Replacement';
                        childAsset.IB_Status__c = soldSpareAssetRecordsMap.get(
                            rmaRecords.get(
                                assetToOrderMap.get(childAsset.ParentId).RMA_Order_Id__c
                            ).Spare_Unit_Serial_number__c
                        ).IB_Status__c;
                        
                    } else {
                        childAsset.ParentId = clonedAsset.Id;
                        childAsset.IB_Status__c = clonedAsset.IB_Status__c;
                    }
                }
            }
            
            if (!childAssetList.isEmpty()) {
                try{
                    update childAssetList;
                }catch(Exception e){
                    errorLogException(
                        'RMA__c', 
                        'RMAOrderHandler', 
                        'swapAsset', 
                        'rmaId => '+rmaIds, 
                        e.getMessage()
                    );
                }
            }
            
            //Update original parent assets → set Unit__c to new clone's name
            for (Asset original : parentAssets) {
                Asset cloneOriginalAsset = oldToNewParentIdMap.get(original.Id);
                String IB_STATUS = (original.Service_Level__c != null && original.Service_Level__c.contains('EHRS')) ? 'Replaced - No Return' : 'Replaced';
                //'EHRS' is the service level for EHRS. '
                if (cloneOriginalAsset != null) {
                    if(rmaRecords.get(assetToOrderMap.get(original.Id).RMA_Order_Id__c).Cold_Spare_Check_box__c) {
                        System.debug('original.Replacement_Asset__c::>>>>'+DefAndSpareUnitAssetsMap.get(original.Name).Id);
                        
                        original.RMA_Order__c = (Id)(assetToOrderMap.get(original.Id).RMA_Order_Id__c);
                        original.Replacement_Asset__c = DefAndSpareUnitAssetsMap.get(defectiveToSpareUnitAssetMap.get(original.Name)).Id;
                        //original.Replacement_Unit__c = original.Replacement_Asset__c;
                        original.IB_Status__c = IB_STATUS;
                    } else {
                        original.RMA_Order__c = (Id)(assetToOrderMap.get(original.Id).RMA_Order_Id__c);
                        original.Replacement_Asset__c = cloneOriginalAsset.Id;
                        //original.Replacement_Unit__c = original.Replacement_Asset__c;
                        original.IB_Status__c = IB_STATUS;
                        original.NS_Temp_Sync_Complete__c = FALSE;
                    }
                }
            }
            System.debug('parentAssets:::>>>> '+parentAssets);
            System.debug('ClonedParentAssets:::>>>>> '+clonedParents);
            System.debug('childAssetList::::>>>> '+childAssetList);
            
            //update parentAssets;
            
            if(!soldSpareAssetRecordsMap.isEmpty()){
                List<Asset> soldSpareAssetsforUpdate = new List<Asset>();
                for(Asset soldSpareAsset : soldSpareAssetRecordsMap.values()) {
                    soldSpareAsset.IB_Status__c = 'Replacement';
                    soldSpareAsset.Defective_Asset__c = DefAndSpareUnitAssetsMap.get(SpareUnitToDefectiveAssetMap.get(soldSpareAsset.Name)).Id;
                    //soldSpareAsset.Defective_Asset__c = DefAndSpareUnitAssetsMap.get(soldSpareAsset.Name).Id;
                    soldSpareAssetsforUpdate.add(soldSpareAsset);
                }
                try{
                    update soldSpareAssetsforUpdate;
                }catch(Exception e){
                    errorLogException(
                        'RMA__c', 
                        'RMAOrderHandler', 
                        'swapAsset', 
                        'rmaId => '+rmaIds, 
                        e.getMessage()
                    );
                }
            }
            
            
            Set<Id> orderIds = new Set<Id>();
            for(Id assetId : assetToOrderMap.keySet()) {
                orderIds.add(assetToOrderMap.get(assetId).id);
            }
            
            Map<Id, Asset> defAssetMap = new Map<Id, Asset>(parentAssets);
            Map<Id, OrderItem> orderIdToOrderItemMap = new Map<Id, OrderItem>();
            Map<Id, OrderItem> orderIdToOrderItemMapForReturn = new Map<Id, OrderItem>();
            
            List<OrderItem> orderedItems = [
                SELECT 
                Id, OrderId, RMA_Order_Line__r.Line_Type__c,RMA_Order_Line__r.Item_Type__c, Quantity
                FROM 
                OrderItem
                WHERE 
                OrderId IN :orderIds
            ];
            
            for (OrderItem oi : orderedItems) {
                if (!orderIdToOrderItemMap.containsKey(oi.OrderId) && oi.RMA_Order_Line__r.Line_Type__c == 'Order') {
                    orderIdToOrderItemMap.put(oi.OrderId, oi);
                }
                if(!orderIdToOrderItemMapForReturn.containsKey(oi.OrderId) && oi.RMA_Order_Line__r.Line_Type__c == 'Return'){
                    orderIdToOrderItemMapForReturn.put(oi.OrderId, oi);
                }
            }
            
            List<Asset> updateAssetOI = new List<Asset>(); 
            
            for (Id originalAssetId : assetToOrderMap.keySet()) {
                Id orderId = assetToOrderMap.get(originalAssetId).Id;
                OrderItem matchingOI = orderIdToOrderItemMap.get(orderId);
                OrderItem matchingOIForDefAsset = orderIdToOrderItemMapForReturn.get(orderId);
                Asset newCloneAsset = oldToNewParentIdMap.get(originalAssetId);
                Asset defAsset = defAssetMap.get(originalAssetId);
                
                if (matchingOI != null && newCloneAsset != null) {
                    newCloneAsset.SBQQ__OrderProduct__c = matchingOI.Id;
                    defAsset.SBQQ__OrderProduct__c = (matchingOIForDefAsset != null) ? matchingOIForDefAsset.Id : defAsset.SBQQ__OrderProduct__c;
                    defAsset.SBQQ__CurrentSubscription__c = Null;
                    defAsset.Renewed_Subscription__c = NULL;
                    defAsset.SBQQ__RequiredBySubscription__c = NULL;
                    defAsset.SBQQ__LatestQuoteLine__c = Null;
                    defAsset.SBQQ__QuoteLine__c = Null;
                    defAsset.SBQQ__SubscriptionQuoteLine__c = Null;
                    updateAssetOI.add(newCloneAsset);
                    updateAssetOI.add(defAsset);
                }
            }
            
            try{
                update updateAssetOI;
            }catch(Exception e){
                errorLogException(
                    'RMA__c', 
                    'RMAOrderHandler', 
                    'swapAsset', 
                    'rmaId => '+rmaIds, 
                    e.getMessage()
                );
            }
            System.debug('ClonedAssets Second:::>>>>> '+clonedParents);
        }
    }
    
    //Asset creation check
    public static Boolean checkAssetCreation(Asset original,Map<Id, RMA__c> rmaRecords,Map<Id, RMA_Order_Line__c> rmaLineMap,Map<Id, Order> assetToOrderMap){
        
        Id rmaID = (assetToOrderMap.get(original.Id).RMA_Order_Id__c !=null) ? assetToOrderMap.get(original.Id).RMA_Order_Id__c : null;
        
        if(rmaID != null && rmaLineMap.get(rmaID).Item_Type__c == 'Unit' || rmaLineMap.get(rmaID).Base_Item__c == TRUE){
            return TRUE;            
        }else{
            //No Asset creation
            return FALSE;
        }
    }
    
    //EHR and EHRS check for Order Product
    public static Boolean checkServiceLevel(RMA__c rma,RMA_Order_Line__c line,Asset defAsset){
        //List<String> noLineForPartProductList = new List<String>{'Component', 'FIPS','Disk','Memory'};
        String noLineForPartProductString = System.Label.RMA_Exclude_Inventory_Item_For_Return_Line;
        List<String> noLineForPartProductList = noLineForPartProductString.split(',');
        Boolean lineForPartProduct = TRUE;
        
        String rvbdInventory = (line.Product__r.RVBD_Inventory__c != null ) ? line.Product__r.RVBD_Inventory__c : '';
        Boolean isConsumable = line.Product__r.Consumable__c;
        for (String keyword : noLineForPartProductList) {
            if (rvbdInventory.contains(keyword)) {
                lineForPartProduct = FALSE;
                break;
            }
        }
        
        System.debug('lineForPartProduct : ' + lineForPartProduct);
        
        if(defAsset.Service_Level__c != null && (defAsset.Service_Level__c.contains('EHR') || defAsset.Service_Level__c.contains('EHRS'))){
            if(defAsset.Service_Level__c.contains('EHRS')){
                //No Line creation 
                return FALSE;
            }else{
                //EHR Block
                
                if(line.Item_Type__c != 'Unit' &&  (lineForPartProduct == FALSE || isConsumable == TRUE)){
                    // IF item.category IN [Component, FIPS, Disk, Memory]: Or item.DFF_Consumable == "CONSUMABLE"
                    //     RETURN_LINE = FALSE
                    return FALSE;  
                }else{
                    //Create Return line
                    return TRUE;
                }	
            }
        }
        if(isConsumable){
            return FALSE;
        }
        
        return TRUE;
    }
    //Method to get Pricebook Entry Id
    private static Id getPricebookEntryId(Id productId) {
        try {
            PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :productId AND IsActive = true AND Pricebook2.Name= 'Alluvio Price Book'];
            return pbEntry.Id;
        } catch (Exception e) {
            System.debug('No active Pricebook Entry found for Product:' + productId);
            return null;
        }
    }
    
    private static Decimal getProductPrice(Id pricebookEntryId) {
        try {
            PricebookEntry pbEntry = [SELECT UnitPrice FROM PricebookEntry WHERE Id = :pricebookEntryId LIMIT 1];
            System.debug('Found Unit Price::: ' + pbEntry.UnitPrice + ' for PricebookEntryId:' + pricebookEntryId);
            return pbEntry.UnitPrice;
        } catch (Exception e) {
            System.debug('No Unit Price found for PricebookEntryId:' + pricebookEntryId);
            return null;
        }
    }
    
    //Method to check if SKU is valid for the given RMA
    public static Boolean checkValidSKU(Id rmaId){
        if(rmaId != null || rmaId != ''){
            //Fetch associated RMA Order Lines
            List<RMA_Order_Line__c> rmaOrderLines = [
                SELECT 
                Id, Product__c, Qty__c, Item_Type__c, Line_Type__c, Product__r.Consumable__c, Product__r.RVBD_Inventory__c,SKU__c,Base_Item__c
                FROM 
                RMA_Order_Line__c 
                WHERE 
                RMA_Order__c = :rmaId
            ];
            
            system.debug('rmaOrderLines ->>>> '+rmaOrderLines);
            if (rmaOrderLines.isEmpty()){
                System.debug('No Order Lines found for the given RMA.');
                return FALSE;
            }
            Set<String> skuProductCodes = new Set<String>();
            
            for (RMA_Order_Line__c line : rmaOrderLines) {
                if (line.SKU__c != null) {
                    skuProductCodes.add(line.SKU__c);
                }
            }
            
            List<Product2> skuProductList = [SELECT Id,name,ProductCode FROM Product2 where ProductCode IN :  skuProductCodes];
            
            Boolean skuIsValid = skuProductList.isEmpty() != true ? TRUE : FALSE;
            
            return skuIsValid;
        }
        return FALSE;
    }
    
   //Method for Updating the defective Asset Replacement Unit, this method run after update
    public static void updateDefectiveAssetSerialNumber(List<Asset> newAssetList, Map<Id, Asset> oldAssetMap) {
        Set<Id> updateDefectiveAssetSN = new Set<Id>();
        for (Asset replacementAsset : newAssetList) {
            if(replacementAsset.NS_Fulfillment_ID__c != null && replacementAsset.NS_Fulfillment_ID__c != oldAssetMap.get(replacementAsset.Id).NS_Fulfillment_ID__c){
                updateDefectiveAssetSN.add(replacementAsset.Defective_Asset__c);
            }
        }
        
        if(!updateDefectiveAssetSN.isEmpty()){
            List<Asset> defAssetList = [SELECT Id,Name,Replacement_Unit__c,Replacement_Asset__r.Name FROM Asset where Id in :updateDefectiveAssetSN];
            for(Asset defAsset : defAssetList){
                defAsset.Replacement_Unit__c = defAsset.Replacement_Asset__r.Name;
            }
            try{
                update defAssetList;
            }catch(Exception e){
                errorLogException(
                    'RMA__c', 
                    'RMAOrderHandler', 
                    'updateDefectiveAssetSerialNumber', 
                    ' ', 
                    e.getMessage()
                );
            }
            
        }
           
    }
    
    //Method for log errors in Error Log object
    public static void errorLogException(String objName, String className, String methodName, String recordId, String exceptionDetails){
        
        Error_Log__c exp = new Error_Log__c();
        exp.Object__c = objName;
        exp.Class_Name__c = className;
        exp.Method_Name__c = methodName;
        exp.Record_Id__c = recordId;
        exp.Exception_Details__c = exceptionDetails;
        insert exp;
    }
}