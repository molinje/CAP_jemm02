using {LogaliGroup as service} from '../service';

annotate service.VH_Categories with {
    @title : 'Categories'
    ID @Common: {
        Text : category,
        TextArrangement : #TextOnly
    }
};