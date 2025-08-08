const cds = require('@sap/cds');
require('dotenv').config();
module.exports = class LogaliGroup extends cds.ApplicationService {
    async init() {
        // Importamos las entidades que vamos a utilizar en el servicio, deben ser 
        // entidades que esten definidas en el archivo  service.cds
        const { Products, Inventories, CBusinessPartner, CSuppliers } = this.entities;

        const cloud = await cds.connect.to("API_BUSINESS_PARTNER");
        const onpremise = await cds.connect.to("API_BUSINESS_PARTNER_CLUD");

         this.on('READ', CBusinessPartner, async (req)=>{
            return await cloud.tx(req).send({
                query: req.query,
                headers: {
                    apikey : process.env.APIKEY
                }
            })
        });

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

        // En una promesa el req.data es el objeto que se esta creando,
        // por lo que se puede modificar directamente el objeto req.data para agregar los valores por defecto
        // Esto es util solo con escenarios 1 a 1.
        // En una promesa el req.params para las acciones nos retorna los ID de los productos que se estan modificando,
        // por lo que se puede utilizar para obtener los datos de los productos que se estan modific
        this.on('setStock', async (req) => {
            //console.log(req.params);
            //console.log(req.data);
            const productId = req.params[0].ID;
            const inventoryId = req.params[1].ID;
            // Leemos la cantidad actual del inventario para el producto seleccionado
            // y la almacenamos en la variable amount
            const amount = await SELECT.one.from(Inventories).columns('quantity').where({ ID: inventoryId });
            let newAmount = 0;
            // Si se selecciono la opcion A, se suma la cantidad al inventario,
            if (req.data.option === 'A') {
                console.log("Estoy dentro");
                // Se calcula nuevo amount sumando la cantidad actual del inventario con la cantidad que se esta agregando
                // Si el nuevo amount es mayor a 100, se actualiza el estado del producto
                newAmount = amount.quantity + req.data.amount;
                if (newAmount > 100) {
                    await UPDATE(Products).set({ statu_code: 'InStock' }).where({ ID: productId });
                }
                // Se actualiza la cantidad del inventario con el nuevo amount
                await UPDATE(Inventories).set({ quantity: newAmount }).where({ ID: inventoryId });

                return req.info(200, `The amount ${req.data.amount} has benn added to the inventory`);
            } else if (req.data.amount > amount.quantity) {
                return req.error(400, `There is no availability for the requested quantity`);
            } else {
                newAmount = amount.quantity - req.data.amount;

                if (newAmount > 0 && newAmount <= 100) {
                    await UPDATE(Products).set({ statu_code: 'LowAvailability' }).where({ ID: productId });
                } else if (newAmount === 0) {
                    await UPDATE(Products).set({ statu_code: 'OutOfStock' }).where({ ID: productId });
                }

                await UPDATE(Inventories).set({ quantity: newAmount }).where({ ID: inventoryId });
                return req.info(200, `The amount ${req.data.amount} has benn removed form the inventory`);
            }

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