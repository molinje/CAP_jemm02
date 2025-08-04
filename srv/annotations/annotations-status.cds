using {LogaliGroup as service} from '../service';

annotate service.Status with {
    code @title : 'Statu Name'
    @Common : { 
        Text : name,
        TextArrangement : #TextOnly
     }
};