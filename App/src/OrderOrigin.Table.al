table 50200 "Order Origin"
{
    DataClassification = CustomerContent;
    Caption = 'Order Origin';
    DrillDownPageId = "Order Origins";
    LookupPageId = "Order Origins";

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; "Description"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}