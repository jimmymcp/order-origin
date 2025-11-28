page 50201 "User Order Origins"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "User Order Origin";
    Caption = 'User Order Origins';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Order Origin Code"; Rec."Order Origin Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
