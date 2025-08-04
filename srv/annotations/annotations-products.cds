using {LogaliGroup as service} from '../service';
using from './annotations-suppliers';
using from './annotations-productdetails.cds';
using from './annotations-reviews';

annotate service.Products with {
    product     @title            : 'Product';
    productName @title            : 'Product Name';
    category    @title            : 'Category';
    subCategory @title            : 'Subcategory';
    statu       @title            : 'Statu';
    rating      @title            : 'Rating';
    supplier    @title            : 'Supplier';
    price       @title: 'Price'  @Measures.ISOCurrency: currency;
    currency    @Common.IsCurrency: true;
};

annotate service.Products with {

    statu       @Common: {
        Text           : statu.name,
        TextArrangement: #TextOnly,
    };
    category    @Common: {
        Text           : category.category,
        TextArrangement: #TextOnly,
        ValueListWithFixedValues, // Esta propiedad me permite seleccionar solo un valor en el filtro de este campo
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'VH_Categories',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: category_ID,
                ValueListProperty: 'ID'
            }]
        },

    };
    subCategory @Common: {
        Text           : subCategory.subCategory,
        TextArrangement: #TextOnly,
        // Filtro para Subcategory, este filtro necesita un parametro de entrada, y es la categoria , esto
        // para mostrar solo valores de un ID de categia
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'VH_SubCategories',
            Parameters    : [
                // Parametro para Filtro
                {
                    $Type            : 'Common.ValueListParameterIn',
                    LocalDataProperty: category_ID,
                    ValueListProperty: 'category_ID',
                },
                // Parametro para decirle donde almacenar el registro seleccionado
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: subCategory_ID,
                    ValueListProperty: 'ID'
                }
            ]
        }

    };
    //    Auyuda de busqueda para Supplier
    supplier    @Common: {
        Text           : supplier.supplierName,
        TextArrangement: #TextOnly,
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Suppliers',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: supplier_ID, // En que campo de la entidad products se va a almacenar el campo seleccionado
                ValueListProperty: 'ID' // Campo que se va a tomar para guardar en supplier_ID
            }],
        },
    };

};


annotate service.Products with @(

    // Cabecera del Listado
    UI.HeaderInfo                     : {
        $Type         : 'UI.HeaderInfoType',
        TypeName      : 'Product',
        TypeNamePlural: 'Products',
        // Titulo y descripción de la pagina a la que se navega cuando
        // se pasa a navegar a un objeto o item del listado
        Title         : {
            $Type: 'UI.DataField',
            Value: productName
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: product
        }
    },

    Capabilities.FilterRestrictions   : {
        $Type                       : 'Capabilities.FilterRestrictionsType',
        FilterExpressionRestrictions: [{
            $Type             : 'Capabilities.FilterExpressionRestrictionType',
            Property          : product,
            AllowedExpressions: 'SearchExpression'
        }]
    },

    //   Filtros del reporte
    UI.SelectionFields                : [
        product,
        productName,
        supplier_ID,
        category_ID,
        subCategory_ID,
        statu_code
    ],

    UI.LineItem                       : [
        {
            $Type: 'UI.DataField',
            Value: product,
        },
        {
            $Type                : 'UI.DataField',
            Value                : productName,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            },
        },

        {
            $Type                : 'UI.DataField',
            Value                : category_ID,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '8rem',
            },
        },
        {
            $Type                : 'UI.DataField',
            Value                : subCategory_ID,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '8rem',
            },
        },

        {
            $Type                : 'UI.DataField',
            Value                : statu_code,
            Criticality          : statu.criticality,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '9rem',
            },
        },
        {
            $Type                : 'UI.DataFieldForAnnotation',
            Target               : '@UI.DataPoint',
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            },
        },
        {
            $Type: 'UI.DataField',
            Value: price,
        }

    ],

    UI.DataPoint                      : {
        $Type        : 'UI.DataPointType',
        Visualization: #Rating,
        Value        : rating
    },

    // Grupos de campos para ubicar en el header de la pagina del Objeto o del item al cual Navegamos

    UI.FieldGroup #SupplierAndCategory: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: supplier_ID
            },

            {
                $Type: 'UI.DataField',
                Value: category_ID
            },
            {
                $Type: 'UI.DataField',
                Value: subCategory_ID
            }
        ]
    },

    UI.FieldGroup #ProductDescription : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: description
        }]
    },

      UI.FieldGroup #Statu              : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type                  : 'UI.DataField',
            Value                  : statu_code,
            Criticality            : statu.criticality,
            Label                  : '',
          /*  ![@Common.FieldControl]: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'IsActiveEntity'},
                    false
                ]},
                1,
                3
            ]}} */
        }]
    },
    UI.FieldGroup #Price              : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: price,
            Label: ''
        }]
    },

    UI.HeaderFacets                   : [

        // aqui se asocian los FieldGroup anteriormente creados para mostrarlos como facetas  
        // en el Headerinfo de la pagina del objeto al que se navego 
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#SupplierAndCategory',
            ID    : 'SupplierAndCategory'
        },

        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#ProductDescription',
            ID    : 'ProductDescription',
            Label : 'Product Description'
        },

         {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#Statu',
            ID    : 'ProductStatu',
            Label : 'Availability'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#Price',
            ID    : 'Price',
            Label : 'Price'
        }

    ],

     UI.Facets                         : [
        {
            $Type : 'UI.CollectionFacet',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target: 'supplier/@UI.FieldGroup#Supplier',
                    Label : 'Information'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Target: 'supplier/contact/@UI.FieldGroup#Contact',
                    Label : 'Contact Person'
                }
            ],
            Label : 'Supplier Information'
        },

        // FieldGroup de ProductsDetail, 'detail' escomo esta definido en la entity Products en db/schema.cds
        {
            $Type : 'UI.ReferenceFacet',
            Target: 'detail/@UI.FieldGroup',
            Label : 'Product Information',
            ID    : 'ProductInformation'
        },

         {
            $Type : 'UI.ReferenceFacet',
            Target: 'toReviews/@UI.LineItem',
            Label : 'Reviews',
            ID    : 'Reviews'
        },

       
      
    ]



);
