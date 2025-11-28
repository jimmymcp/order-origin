table 50201 "User Order Origin"
{
    DataClassification = CustomerContent;
    Caption = 'User Order Origin';
    DrillDownPageId = "User Order Origins";
    LookupPageId = "User Order Origins";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(2; "Order Origin Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Origin Code';
            TableRelation = "Order Origin";
        }
    }

    keys
    {
        key(PK; "User ID", "Order Origin Code")
        {
            Clustered = true;
        }
    }
}
