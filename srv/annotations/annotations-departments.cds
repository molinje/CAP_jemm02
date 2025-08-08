using {LogaliGroup as service} from '../service';

annotate service.VH_Departments with {
    ID @title : 'Departments' @Common : { 
        Text : department,
        TextArrangement : #TextOnly
     }
};