tableextension 50200 Customer extends Customer
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

            trigger OnValidate()
            var
                WillNotRemoveFromOpenDocsLbl: Label 'The %1 will not be removed from any existing documents for this customer.', Comment = '%1 = order origin caption';
            begin
                if "Order Origin Code" = '' then begin
                    if GuiAllowed then
                        Message(WillNotRemoveFromOpenDocsLbl, FieldCaption("Order Origin Code"));
                end
                else
                    UpdateOrderOriginCodeOnRelatedCustomers();
            end;
        }
    }

    trigger OnModify()
    begin
        if xRec."Order Origin Code" <> '' then
            if Rec."Order Origin Code" <> xRec."Order Origin Code" then
                UpdateOrderOriginOnOpenDocuments();
    end;

    local procedure UpdateOrderOriginCodeOnRelatedCustomers()
    var
        Customer: Record Customer;
        ConfirmMgt: Codeunit "Confirm Management";
        UpdateOrderOriginOnRelatedCustomersLbl: Label 'Do you want to update %1 on %2 related customer(s)?', Comment = '%1 = order origin caption, %2 = number of related customers';
    begin
        Customer.SetRange("Bill-to Customer No.", "No.");
        if not Customer.IsEmpty() then
            if ConfirmMgt.GetResponse(StrSubstNo(UpdateOrderOriginOnRelatedCustomersLbl, FieldCaption("Order Origin Code"), Customer.Count()), false) then begin
                Customer.FindSet();
                repeat
                    Customer.Validate("Order Origin Code", "Order Origin Code");
                until Customer.Next() = 0;
            end;
    end;

    local procedure UpdateOrderOriginOnOpenDocuments()
    var
        SalesHeader: Record "Sales Header";
        ConfirmMgt: Codeunit "Confirm Management";
        UpdateOrderOriginOnDocsLbl: Label 'Do you want to update %1 on open documents?', Comment = '%1 = order origin code caption';
    begin
        if not ConfirmMgt.GetResponse(StrSubstNo(UpdateOrderOriginOnDocsLbl, Rec.FieldCaption("Order Origin Code")), false) then
            exit;

        SalesHeader.SetRange("Sell-to Customer No.", "No.");
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Validate("Order Origin Code", "Order Origin Code");
                SalesHeader.Modify();
            until SalesHeader.Next() = 0;
    end;
}