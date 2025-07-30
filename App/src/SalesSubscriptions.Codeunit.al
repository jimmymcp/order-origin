codeunit 50200 "Sales Subscriptions"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', false, false)]
    local procedure OnAfterInitRecord(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if not SalesHeaderRequiresOrderOrigin(SalesHeader) then
            exit;

        if Customer.Get(SalesHeader."Sell-to Customer No.") then
            SalesHeader.Validate("Order Origin Code", Customer."Order Origin Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeaderRequiresOrderOrigin(SalesHeader) then
            exit;

        // SalesHeader.TestField("Order Origin Code");
    end;

    local procedure SalesHeaderRequiresOrderOrigin(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(SalesHeader."Document Type" in ["Sales Document Type"::Order, "Sales Document Type"::"Credit Memo"]);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesDocument', '', false, false)]
    local procedure OnAfterCopySalesDocument(var ToSalesHeader: Record "Sales Header")
    begin
        ToSalesHeader.Validate("Order Origin Code", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnAfterCreateCorrectiveSalesCrMemo', '', false, false)]
    local procedure OnAfterCreateCorrectiveSalesCrMemo(SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header")
    begin
        // SalesHeader.Validate("Order Origin Code", SalesInvoiceHeader."Order Origin Code");
    end;
}