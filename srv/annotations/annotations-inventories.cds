using {LogaliGroup as service} from '../service';

annotate service.Inventories with {
    stockNumber  @title: 'Stock Number'  @Common.FieldControl: #ReadOnly;
    department   @title: 'Department';
    min          @title: 'Minimun'       @Common.FieldControl: #ReadOnly;
    max          @title: 'Maximun'       @Common.FieldControl: #ReadOnly;
    target       @title: 'Target';
    quantity     @title: 'Quantity'      @Measures.Unit      : baseUnit  @Common.FieldControl: #ReadOnly;
    baseUnit     @title: 'Base Unit'     @Common.IsUnit                  @Common.FieldControl: #ReadOnly;
};

/* Anotación para que en el departamento se muestre el nombre
del departamento y no el ID  y para colocar ayuda de Busqueda*/
annotate service.Inventories with {
    department @Common: {
        Text           : department.department,
        TextArrangement: #TextOnly,
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'VH_Departments',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: department_ID,
                ValueListProperty: 'ID'
            }]
        }
    }
};


annotate service.Inventories with @(
    Common.SemanticKey: [stockNumber],
    UI.HeaderInfo     : {
        $Type         : 'UI.HeaderInfoType',
        TypeName      : 'Inventory',
        TypeNamePlural: 'Inventories',
        Title         : {
            $Type: 'UI.DataField',
            Value: product.productName,
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: product.product
        }
    },
    UI.LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: stockNumber
        },
        {
            $Type: 'UI.DataField',
            Value: department_ID
        },
        {
            $Type                : 'UI.DataFieldForAnnotation',
            Target               : '@UI.Chart#Bullet',
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem'
            },
        },
        {
            $Type: 'UI.DataField',
            Value: quantity
        },
    /*
    {
        $Type : 'UI.DataFieldForAction',
        Action : 'LogaliGroup.setStock',
        Label : 'Set Stock',
        Inline : true
    }
    */
    ],

    UI.DataPoint      : {
        $Type                 : 'UI.DataPointType',
        Value                 : target,
        MinimumValue          : min,
        MaximumValue          : max,
        CriticalityCalculation: {
            $Type                 : 'UI.CriticalityCalculationType',
            ImprovementDirection  : #Maximize,
            ToleranceRangeLowValue: 200,
            DeviationRangeLowValue: 100
        },
    },
    UI.Chart #Bullet  : {
        $Type            : 'UI.ChartDefinitionType',
        ChartType        : #Bullet,
        Measures         : [ // Measures = Es igual a la parte numerica
        target],
        MeasureAttributes: [{
            $Type    : 'UI.ChartMeasureAttributeType',
            DataPoint: '@UI.DataPoint',
            Measure  : target
        }]
    },
  UI.FieldGroup     : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: stockNumber
            },
            {
                $Type: 'UI.DataField',
                Value: department_ID
            },
            {
                $Type: 'UI.DataField',
                Value: min
            },
            {
                $Type: 'UI.DataField',
                Value: max
            },
            {
                $Type: 'UI.DataField',
                Value: target
            },
            {
                $Type: 'UI.DataField',
                Value: quantity
            }
        ]
    },
    UI.Facets         : [{
        $Type : 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup',
        Label : 'Inventory Information',
        ID    : 'InventoryInformation'
    }]
);
