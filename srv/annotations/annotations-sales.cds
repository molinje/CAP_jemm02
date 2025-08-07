using {LogaliGroup as service} from '../service';

annotate service.Sales with {
    monthCode     @title: 'Month Code'  @Common.IsCalendarMonth;
    month         @title: 'Month'       @Common.IsCalendarMonth;
    year          @title: 'Year'        @Common.IsCalendarYear;
    quantitySales @title: 'Quantity Sales';
};

annotate service.Sales with @(
    Analytics.AggregatedProperty #sum: {
        Name: 'Sales',
        AggregationMethod : 'sum',
        AggregatableProperty : quantitySales,
        ![@Common.Label] : 'Sales'
    },
    Aggregation.ApplySupported: {
        Transformations : [
            'aggregate',
            'topcount',
            'bottomcount',
            'identity',
            'concat',
            'groupby',
            'filter',
            'top',
            'skip',
            'orderby',
            'search',
        ],
        GroupableProperties: [
            'month',
            'year'
        ],
        AggregatableProperties : [
            {
                $Type : 'Aggregation.AggregatablePropertyType',
                Property : quantitySales
            }
        ]
    },
    UI.Chart  : {
        $Type : 'UI.ChartDefinitionType',
        ChartType : #Line,
        DynamicMeasures : [
            '@Analytics.AggregatedProperty#sum',
        ],
        Dimensions:[ year, month]
    },
);