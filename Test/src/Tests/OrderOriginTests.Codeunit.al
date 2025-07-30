codeunit 50251 "Order Origin Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Location: Record Location;
        LibraryOrderOrigin: Codeunit "Library - Order Origin";
        LibrarySales: Codeunit "Library - Sales";
        Assert: Codeunit Assert;
        Initialized: Boolean;

    [Test]
    procedure OrderOriginCodeIsNotCopiedToQuote()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
    begin
        //[GIVEN] a customer with an order origin code
        Init();
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Order Origin Code", LibraryOrderOrigin.CreateOrderOriginCode());
        Customer.Modify();

        //[WHEN] creating a quote with that customer as the sell-to customer
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, SalesHeader."Document Type"::Quote, '', '', 1, '', 0D);

        //[THEN] the order origin code is left blank
        Assert.AreEqual('', SalesHeader."Order Origin Code", 'Expected the order origin code to have been left blank');
    end;

    [Test]
    procedure OrderOriginIsCopiedFromCustomerToSalesOrder()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        //[GIVEN] a customer with an order origin code
        Init();
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Order Origin Code", LibraryOrderOrigin.CreateOrderOriginCode());
        Customer.Modify();

        //[WHEN] creating a sales order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        //[THEN] order origin is copied to the sales order
        Assert.AreEqual(Customer."Order Origin Code", SalesHeader."Order Origin Code", 'Expected order origin code to have been copied to the sales order');
    end;

    [Test]
    procedure OrderOriginIsCopiedFromCustomerToSalesCreditMemo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        //[GIVEN] a customer with an order origin code
        Init();
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Order Origin Code", LibraryOrderOrigin.CreateOrderOriginCode());
        Customer.Modify();

        //[WHEN] creating a sales credit memo
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", Customer."No.");

        //[THEN] order origin is copied to the sales order
        Assert.AreEqual(Customer."Order Origin Code", SalesHeader."Order Origin Code", 'Expected order origin code to have been copied to the sales credit memo');
    end;

    [Test]
    procedure ReleasingSalesOrderWithoutOrderOriginThrowsError()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        //[GIVEN] a sales order without an order origin code

        //[WHEN] releasing the order

        //[THEN] an error is thrown
    end;

    [Test]
    procedure ReleasingSalesOrderWithOrderOrigin()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        //[GIVEN] a sales order without an order origin code
        Init();
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, '', '', 1, '', 0D);
        SalesHeader.Validate("Order Origin Code", LibraryOrderOrigin.CreateOrderOriginCode());
        SalesHeader.Modify();

        //[WHEN] releasing the order
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        //[THEN] no error is thrown
    end;

    [Test]
    procedure PostingSalesOrderCopiesOrderOriginToSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        //[GIVEN] a sales order with an order origin code
        Init();
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, '', '', 10, Location.Code, 0D);
        SalesHeader.Validate("Order Origin Code", LibraryOrderOrigin.CreateOrderOriginCode());
        SalesHeader.Modify();

        //[WHEN] invoicing the sales order
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        //[THEN] the order origin is copied to the posted sales invoice
        Assert.AreEqual(SalesHeader."Order Origin Code", SalesInvoiceHeader."Order Origin Code", 'Expected the order origin code to have been copied to the posted sales invoice');
    end;

    [Test]
    procedure OrderOriginCodeIsClearedAfterCopySalesDocument()
    var
        SalesHeader, NewSalesHeader : Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        //[GIVEN] a sales order with an order origin code
        Init();
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, '', '', 1, '', 0D);
        SalesHeader.Validate("Order Origin Code", LibraryOrderOrigin.CreateOrderOriginCode());
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        //[WHEN] copying the sales order to a new sales order
        LibrarySales.CreateSalesHeader(NewSalesHeader, NewSalesHeader."Document Type"::Order, SalesHeader."Sell-to Customer No.");
        LibrarySales.CopySalesDocument(NewSalesHeader, Enum::"Sales Document Type From"::Order, SalesHeader."No.", true, true);

        //[THEN] the order origin code of the new order is blank
        Assert.AreEqual('', NewSalesHeader."Order Origin Code", 'Expected the Order Origin Code to have been set to blank on the new order');
    end;

    [Test]
    procedure PostCorrectiveCreditAndCreateNewInvoice()
    var
        SalesHeader, NewSalesHeader : Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        //[GIVEN] a sales order, posted to a sales invoice
        Init();
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, '', '', 1, Location.Code, 0D);
        SalesHeader.Validate("Order Origin Code", LibraryOrderOrigin.CreateOrderOriginCode());
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        //[WHEN] creating a corrective credit memo
        CorrectPostedSalesInvoice.CancelPostedInvoiceCreateNewInvoice(SalesInvoiceHeader, NewSalesHeader);

        //[THEN] the corrective credit memo has the same order origin code as the original invoice
        SalesCrMemoHeader.SetRange("Applies-to Doc. Type", SalesCrMemoHeader."Applies-to Doc. Type"::Invoice);
        SalesCrMemoHeader.SetRange("Applies-to Doc. No.", SalesInvoiceHeader."No.");
        SalesCrMemoHeader.FindFirst();
        Assert.AreEqual(SalesCrMemoHeader."Order Origin Code", SalesInvoiceHeader."Order Origin Code", 'Expected the order origin code to have been copied from the original invoice');
    end;

    local procedure Init()
    var
        LibraryWhse: Codeunit "Library - Warehouse";
    begin
        if Initialized then
            exit;

        LibraryOrderOrigin.Init();
        LibraryWhse.CreateLocationWithInventoryPostingSetup(Location);
        Commit();
    end;
}