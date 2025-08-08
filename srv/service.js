const cds = require('@sap/cds');
module.exports = class LogaliGroup extends cds.ApplicationService {
    init() {
        // Importamos las entidades que vamos a utilizar en el servicio, deben ser 
        // entidades que esten definidas en el archivo  service.cds
        const { Products, Inventories } = this.entities;

        // Con el siguiente código puedo asegurar que cada vez que se vaya a crear un nuevo borrador de producto, se le asignen valores por defecto a los campos de detalle.
        // Esto es útil para evitar que los usuarios tengan que ingresar manualmente estos valores cada vez que creen un nuevo borrador de producto.
        // Además, se puede agregar lógica personalizada antes de crear un nuevo borrador, como establecer valores predeterminados o validar la entrada del usuario.
        // Este código se ejecuta antes de que se cree un nuevo borrador de producto.
        // Esto es util solo con escenarios 1 a 1.
        this.before('NEW', Products.drafts, async (req) => {
            console.log(req.data);
            req.data.detail ??= {
                baseUnit: 'EA',
                width: null,
                height: null,
                depth: null,
                weight: null,
                unitVolume: 'CM',
                unitWeight: 'KG',

            }
            // You can add custom logic here before creating a new draft
            // For example, you might want to set default values or validate input
        });

        this.before('NEW', Inventories.drafts, async (req) => {

            // Max actual stockNumber en la tabla Persistente Inventories           
            let result = await SELECT.one.from(Inventories).columns('max(stockNumber) as max');
             // Max actual stockNumber en la tabla Borrador InventoriesDrafts para el product_ID que se esta trabajando
            let result2 = await SELECT.one.from(Inventories.drafts).columns('max(stockNumber) as max').where({ product_ID: req.data.product_ID });
            
            // max es el valor de la tabla persistente, es un string, lo convertimos a entero
            let max = parseInt(result.max);
            // max2 es el valor de la tabla borradore, max2 es un string, lo convertimos a entero
            let max2 = parseInt(result2.max);
            let newMax = 0;
            // Si max es NaN, significa que no hay registros en la tabla persistente, por lo que asignamos 1
            
            
            

            // Si max2 es NaN, significa que no hay registros en la tabla borrador, por lo que asignamos max + 1
            if (isNaN(max2)) {
                newMax = max + 1;
            } else if (max < max2) { 
                // Si max es menor que max2, significa que hay registros en la tabla borrador, por lo que asignamos max2 + 1
                newMax = max2 + 1;
            } else {
                // Si max es mayor o igual que max2, significa que el Maximo valor ya esta en la tabla de persistencia,
                // por lo que asignamos max + 1
                newMax = max + 1;
            }

            req.data.stockNumber = newMax.toString();

        });

        /*
        this.on('READ', Products, async (req) => {
            const tx = cds.transaction(req);
            const products = await tx.read(Products).where({ IsActiveEntity: true });
            return products;
        });

        this.on('UPDATE', Products, async (req) => {
            const tx = cds.transaction(req);
            const updatedProduct = await tx.update(Products).set(req.data).where({ ID: req.data.ID });
            return updatedProduct;
        });
        */
        return super.init();
    }
}