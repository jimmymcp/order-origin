pageextension 50200 "Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addlast(General)
        {
            field("Order Origin Code"; Rec."Order Origin Code")
            {
                ApplicationArea = All;
            }
        }
    }
}