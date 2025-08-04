using {LogaliGroup as service} from '../service';

annotate service.Reviews with {
    rating   @title: 'Rating';
    date @title: 'Date';
    user @title: 'User';
    reviewText @title: 'Review Text';
};

/* Tabla para mostrar los reviews de cada producto*/
annotate service.Reviews with @(
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
    }
);