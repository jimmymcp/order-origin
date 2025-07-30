tableextension 50201 "Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
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