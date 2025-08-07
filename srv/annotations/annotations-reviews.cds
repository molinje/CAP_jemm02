using {LogaliGroup as service} from '../service';

annotate service.Reviews with {
    rating   @title: 'Rating';
    date @title: 'Date';
    user @title: 'User';
    reviewText @title: 'Review Text';
};

/* Tabla para mostrar los reviews de cada producto*/
annotate service.Reviews with @(

    UI.HeaderInfo: {
        $Type : 'UI.HeaderInfoType',
        TypeName : 'Review',
        TypeNamePlural : 'Reviews',
     
        Title : {
            $Type : 'UI.DataField',
            Value : product.productName,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : product.product
        }
    },

    UI.LineItem: [
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target : '@UI.DataPoint',
            Label : 'Rating',
            ![@HTML5.CssDefaults] : {
                $Type : 'HTML5.CssDefaultsType',
                width : '10rem'
            },
        },
        {
            $Type : 'UI.DataField',
            Value : date,
        },
        {
            $Type : 'UI.DataField',
            Value : user,
            Label : 'User'
        },
        {
            $Type : 'UI.DataField',
            Value : reviewText
        }
    ],
    UI.DataPoint  : {
        $Type : 'UI.DataPointType',
        Value : rating,
        Visualization : #Rating
    },
// Grupo de campos para colocar en la pagina del Objeto review
    UI.FieldGroup #Reviews :{
        $Type: 'UI.FieldGroupType',

        Data: [
            {
                $Type: 'UI.DataFieldForAnnotation',
                Target: '@UI.DataPoint',
                Label: 'Rating'
            },
            {
                $Type: 'UI.DataField',
                Value: date,
                Label: 'Date'
            },
            {
                $Type: 'UI.DataField',
                Value: user,
                Label: 'User'
            },
            {
                $Type: 'UI.DataField',
                Value: reviewText,
                Label: 'Review Text'
            }
        ]
    },
    // Faceta es la que finalmente imprime los grupos de campos en la pagina del Objeto

    UI.Facets: [
        {
            $Type: 'UI.ReferenceFacet', 
            ID: 'Reviews',      
            Target: '@UI.FieldGroup#Reviews',
            Label: 'Reviews',
        }
    ]
);