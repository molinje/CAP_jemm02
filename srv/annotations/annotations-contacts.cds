using {LogaliGroup as service} from '../service';


/* Label para los campos de la entidad contacto*/
annotate service.Contacts with {
    fullName     @title: 'Full Name'     @Common.FieldControl: #ReadOnly;
    email        @title: 'Email'         @Common.FieldControl: #ReadOnly;
    phoneNumber  @title: 'Phone Number'  @Common.FieldControl: #ReadOnly;
};

/* FieldGroup de contacto que vamos a utilizar en las facetas de la pagina  del item donde navegamos*/
annotate service.Contacts with @(UI.FieldGroup #Contact: {
    $Type: 'UI.FieldGroupType',
    Data : [
        {
            $Type: 'UI.DataField',
            Value: fullName
        },
        {
            $Type: 'UI.DataField',
            Value: email
        },
        {
            $Type: 'UI.DataField',
            Value: phoneNumber
        }
    ]
});