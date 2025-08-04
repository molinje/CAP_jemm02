using {LogaliGroup as service} from '../service';

annotate service.VH_SubCategories with {
    @title : 'Sub-Categories'
    ID @Common: {
        Text : subCategory,
        TextArrangement : #TextOnly
    }
};