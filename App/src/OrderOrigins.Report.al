report 50201 "Order Origins"
{
    Caption = 'Order Origins';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Word;
    WordLayout = 'src/OrderOrigins.Report.docx';

    dataset
    {
        dataitem(OrderOrigin; "Order Origin")
        {
            column(Code; Code)
            {
            }
            column(Description; Description)
            {
            }
        }
    }
}
