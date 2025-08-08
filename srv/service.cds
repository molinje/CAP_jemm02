using {com.logaligroup as entities} from '../db/schema';
// Servicios externos:
using {API_BUSINESS_PARTNER as cloud} from './external/API_BUSINESS_PARTNER';
//using {API_BUSINESS_PARTNER_CLUD as onpremise} from './external/API_BUSINESS_PARTNER_CLUD';

service LogaliGroup {

    // para Boton de adicionar o restar inventario
    type dialog {
        option : String(10); //Add or Discount
        amount : Integer;
    }

    entity Products         as projection on entities.Products;
    entity ProductDetails   as projection on entities.ProductDetails;
    entity Suppliers        as projection on entities.Suppliers;
    entity Contacts         as projection on entities.Contacts;
    entity Reviews          as projection on entities.Reviews;
    entity Sales            as projection on entities.Sales;

    // Accion de tipo Enlazadas a la Entidad Inventories
    entity Inventories      as projection on entities.Inventories
        actions {
            
            // edmJson se usa para indicar que la accion esta disponible
            // solo si el producto esta activo
            @Core.OperationAvailable: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'in/product/IsActiveEntity'},
                    false
                ]},
                false,
                true
            ]}}
            // este SideEffects nos permite indicar que la accion
            // setStock tiene efectos secundarios sobre la entidad product
            // y que se actualizara el campo quantity del inventario
            @Common                 : {SideEffects: {
                $Type           : 'Common.SideEffectsType',
                TargetProperties: ['in/quantity'],
                TargetEntities  : [in.product],
            }, }


            /**
             * Action to set stock number
             * @param option: 'Add' or 'Discount'
             * @param amount: Amount to add or discount
             */
            action setStock(in: $self,
                            option: dialog:option,
                            amount: dialog:amount)
        };

    /**Code List */
    entity Status           as projection on entities.Status;
    entity Options          as projection on entities.Options;

    /** Value Helps */
    entity VH_Categories    as projection on entities.Categories;
    entity VH_SubCategories as projection on entities.SubCategories;
    entity VH_Departments   as projection on entities.Departments;

      /** Entidades externas */
    entity CBusinessPartner as projection on cloud.A_BusinessPartner {
        key BusinessPartner as ID,
            FirstName as FirstName,
            LastName as LastName
    };

    entity CSuppliers as projection on cloud.A_Supplier {
        Supplier as ID,
        SupplierName as SupplierName,
        SupplierFullName as FullName
    };

 

}
