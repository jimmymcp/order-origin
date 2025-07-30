codeunit 50250 "Library - Order Origin"
{
    procedure Init()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        WhseSetup: Record "Warehouse Setup";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        if not SalesSetup.Get() then
            SalesSetup.Insert();

        if SalesSetup."Order Nos." = '' then
            SalesSetup."Order Nos." := LibraryERM.CreateNoSeriesCode();

        if SalesSetup."Invoice Nos." = '' then
            SalesSetup."Invoice Nos." := LibraryERM.CreateNoSeriesCode();

        if SalesSetup."Posted Invoice Nos." = '' then
            SalesSetup."Posted Invoice Nos." := LibraryERM.CreateNoSeriesCode();

        if SalesSetup."Posted Shipment Nos." = '' then
            SalesSetup."Posted Shipment Nos." := LibraryERM.CreateNoSeriesCode();

        SalesSetup.Modify(true);

        if not WhseSetup.Get() then
            WhseSetup.Insert();

        if WhseSetup."Whse. Ship Nos." = '' then
            WhseSetup."Whse. Ship Nos." := LibraryERM.CreateNoSeriesCode();

        WhseSetup.Modify();

        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
    end;

    procedure CreateOrderOrigin(var OrderOrigin: Record "Order Origin")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        OrderOrigin.Code := LibraryUtility.GenerateRandomCode(OrderOrigin.FieldNo(Code), Database::"Order Origin");
        OrderOrigin.Description := OrderOrigin.Code;
        OrderOrigin.Insert(true);
    end;

    procedure CreateOrderOriginCode(): Code[20]
    var
        OrderOrigin: Record "Order Origin";
    begin
        CreateOrderOrigin(OrderOrigin);
        exit(OrderOrigin.Code);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Inventory", 'OnAfterCreateItem', '', false, false)]
    local procedure OnAfterCreateItem(var Item: Record Item)
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GeneralPostingSetup2: Record "General Posting Setup";
        Location: Record Location;
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        GeneralPostingSetup.SetRange("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        if GeneralPostingSetup.FindFirst() then
            if not GeneralPostingSetup2.Get('', Item."Gen. Prod. Posting Group") then begin
                GeneralPostingSetup2 := GeneralPostingSetup;
                GeneralPostingSetup2."Gen. Bus. Posting Group" := '';
                GeneralPostingSetup2.Insert();
            end;

        if Location.FindSet() then
            repeat
                LibraryInventory.UpdateInventoryPostingSetup(Location);
            until Location.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Sales", 'OnAfterCreateCustomer', '', false, false)]
    local procedure OnAfterCreateCustomer(var Customer: Record Customer)
    var
        GenPostingSetup: Record "General Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        GenPostingSetup.SetRange("Gen. Bus. Posting Group", Customer."Gen. Bus. Posting Group");
        GenPostingSetup.SetFilter("Sales Credit Memo Account", '%1', '');
        if GenPostingSetup.FindSet() then
            repeat
                GenPostingSetup.Validate("Sales Credit Memo Account", LibraryERM.CreateGLAccountNo());
                GenPostingSetup.Validate("Purch. Credit Memo Account", LibraryERM.CreateGLAccountNo());
                GenPostingSetup.Modify(true);
            until GenPostingSetup.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Purchase", 'OnAfterCreateVendor', '', false, false)]
    local procedure OnAfterCreateVendor(var Vendor: Record Vendor)
    var
        GenPostingSetup: Record "General Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        GenPostingSetup.SetRange("Gen. Bus. Posting Group", Vendor."Gen. Bus. Posting Group");
        GenPostingSetup.SetFilter("Sales Credit Memo Account", '%1', '');
        if GenPostingSetup.FindSet() then
            repeat
                GenPostingSetup.Validate("Sales Credit Memo Account", LibraryERM.CreateGLAccountNo());
                GenPostingSetup.Validate("Purch. Credit Memo Account", LibraryERM.CreateGLAccountNo());
                GenPostingSetup.Modify(true);
            until GenPostingSetup.Next() = 0;
    end;
}