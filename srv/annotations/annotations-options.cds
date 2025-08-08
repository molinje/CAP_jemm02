using {LogaliGroup as service} from '../service';

// Annotations para Options en la ventana de dialogo de setStock
//este annotation es para que cuando se seleccione un valor de la lista de opciones
//se muestre el nombre de la opcion y no el ID
annotate service.Options with {
    code @title : 'Options' @Common: {
        Text : name,
        TextArrangement : #TextOnly
    }
};

// Annotations para el dialogo de setStock, 
// @mandatory indica que el campo es obligatorio
// @title indica el titulo que se mostrara en la ventana de dialogo
annotate service.dialog with {
    option @title: 'Option' @mandatory;
    amount @title : 'Amount' @mandatory;
};

// annotate para el campo option del dialogo de setStock
// @Common indica que se usara una lista de valores para el campo option
// y se define la coleccion de Options como la lista de valores
// y se definen los parametros de la lista de valores   
annotate service.dialog with {
    option @Common: {
        ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Options',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : option,
                    ValueListProperty : 'code',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name'
                }
            ]
        },

    }
};