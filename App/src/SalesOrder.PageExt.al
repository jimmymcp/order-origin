pageextension 50201 "Sales Order" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("Order Origin Code";Rec."Order Origin Code")
            {
                ApplicationArea = All;
            }
        }
    }
}