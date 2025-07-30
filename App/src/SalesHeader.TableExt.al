tableextension 50202 "Sales Header" extends "Sales Header"
{
    fields
    {
        field(50100; "Order Origin Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Origin Code';
            TableRelation = "Order Origin";
        }
    }
}