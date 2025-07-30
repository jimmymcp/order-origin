tableextension 50203 "Sales Invoice Header" extends "Sales Invoice Header"
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