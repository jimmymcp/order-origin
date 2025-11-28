tableextension 50202 "Sales Header" extends "Sales Header"
{
    fields
    {
        field(50100; "Order Origin Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Origin Code';
            TableRelation = "Order Origin";

            trigger OnLookup()
            var
                OrderOrigin: Record "Order Origin";
                OrderOriginAccessMgt: Codeunit "Order Origin Access Mgt.";
            begin
                OrderOriginAccessMgt.FilterOrderOrigins(OrderOrigin);
                if Page.RunModal(Page::"Order Origins", OrderOrigin) = Action::LookupOK then
                    Validate("Order Origin Code", OrderOrigin.Code);
            end;
        }
    }
}