codeunit 50252 "User Order Origin Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryOrderOrigin: Codeunit "Library - Order Origin";
        Assert: Codeunit Assert;

    [Test]
    procedure UserWithNoSetupSeesAllOrderOrigins()
    var
        OrderOrigin: Record "Order Origin";
        OrderOriginAccessMgt: Codeunit "Order Origin Access Mgt.";
        OriginalCount: Integer;
    begin
        //[GIVEN] a user with no User Order Origin setup and some order origins exist
        LibraryOrderOrigin.CreateOrderOrigin(OrderOrigin);
        OrderOrigin.Reset();
        OriginalCount := OrderOrigin.Count();

        //[WHEN] filtering order origins for the user
        OrderOriginAccessMgt.FilterOrderOrigins(OrderOrigin);

        //[THEN] all order origins are visible
        Assert.AreEqual(OriginalCount, OrderOrigin.Count(), 'User with no setup should see all order origins');
    end;

    [Test]
    procedure UserWithSetupSeesOnlyAllowedOrderOrigins()
    var
        OrderOrigin1: Record "Order Origin";
        OrderOrigin2: Record "Order Origin";
        OrderOrigin: Record "Order Origin";
        UserOrderOrigin: Record "User Order Origin";
        OrderOriginAccessMgt: Codeunit "Order Origin Access Mgt.";
    begin
        //[GIVEN] two order origins and user setup for only one of them
        LibraryOrderOrigin.CreateOrderOrigin(OrderOrigin1);
        LibraryOrderOrigin.CreateOrderOrigin(OrderOrigin2);

        UserOrderOrigin."User ID" := GetCurrentUserID();
        UserOrderOrigin."Order Origin Code" := OrderOrigin1.Code;
        UserOrderOrigin.Insert();

        //[WHEN] filtering order origins for the user
        OrderOrigin.Reset();
        OrderOriginAccessMgt.FilterOrderOrigins(OrderOrigin);

        //[THEN] only the allowed order origin is visible
        Assert.AreEqual(1, OrderOrigin.Count(), 'User should only see allowed order origins');
        Assert.IsTrue(OrderOrigin.Get(OrderOrigin1.Code), 'Allowed order origin should be visible');

        // Cleanup
        UserOrderOrigin.Delete();
    end;

    [Test]
    procedure HasUserOrderOriginSetupReturnsFalseWhenNoSetup()
    var
        OrderOriginAccessMgt: Codeunit "Order Origin Access Mgt.";
        UserID: Code[50];
    begin
        //[GIVEN] a user ID with no setup
        UserID := 'NONEXISTENTUSER';

        //[WHEN] checking if user has order origin setup
        //[THEN] returns false
        Assert.IsFalse(OrderOriginAccessMgt.HasUserOrderOriginSetup(UserID), 'Should return false when no setup exists');
    end;

    [Test]
    procedure HasUserOrderOriginSetupReturnsTrueWhenSetupExists()
    var
        OrderOrigin: Record "Order Origin";
        UserOrderOrigin: Record "User Order Origin";
        OrderOriginAccessMgt: Codeunit "Order Origin Access Mgt.";
    begin
        //[GIVEN] a user with order origin setup
        LibraryOrderOrigin.CreateOrderOrigin(OrderOrigin);
        UserOrderOrigin."User ID" := GetCurrentUserID();
        UserOrderOrigin."Order Origin Code" := OrderOrigin.Code;
        UserOrderOrigin.Insert();

        //[WHEN] checking if user has order origin setup
        //[THEN] returns true
        Assert.IsTrue(OrderOriginAccessMgt.HasUserOrderOriginSetup(UserOrderOrigin."User ID"), 'Should return true when setup exists');

        // Cleanup
        UserOrderOrigin.Delete();
    end;

    [Test]
    procedure IsOrderOriginAllowedReturnsTrueWhenNoSetup()
    var
        OrderOrigin: Record "Order Origin";
        OrderOriginAccessMgt: Codeunit "Order Origin Access Mgt.";
    begin
        //[GIVEN] an order origin and a user with no setup
        LibraryOrderOrigin.CreateOrderOrigin(OrderOrigin);

        //[WHEN] checking if order origin is allowed for user with no setup
        //[THEN] returns true (all origins allowed when no setup)
        Assert.IsTrue(OrderOriginAccessMgt.IsOrderOriginAllowed('NONEXISTENTUSER', OrderOrigin.Code), 'Should return true when no setup exists');
    end;

    [Test]
    procedure IsOrderOriginAllowedReturnsTrueWhenAllowed()
    var
        OrderOrigin: Record "Order Origin";
        UserOrderOrigin: Record "User Order Origin";
        OrderOriginAccessMgt: Codeunit "Order Origin Access Mgt.";
    begin
        //[GIVEN] a user with order origin setup for a specific origin
        LibraryOrderOrigin.CreateOrderOrigin(OrderOrigin);
        UserOrderOrigin."User ID" := GetCurrentUserID();
        UserOrderOrigin."Order Origin Code" := OrderOrigin.Code;
        UserOrderOrigin.Insert();

        //[WHEN] checking if that order origin is allowed
        //[THEN] returns true
        Assert.IsTrue(OrderOriginAccessMgt.IsOrderOriginAllowed(UserOrderOrigin."User ID", OrderOrigin.Code), 'Should return true when order origin is allowed');

        // Cleanup
        UserOrderOrigin.Delete();
    end;

    [Test]
    procedure IsOrderOriginAllowedReturnsFalseWhenNotAllowed()
    var
        OrderOrigin1: Record "Order Origin";
        OrderOrigin2: Record "Order Origin";
        UserOrderOrigin: Record "User Order Origin";
        OrderOriginAccessMgt: Codeunit "Order Origin Access Mgt.";
    begin
        //[GIVEN] a user with order origin setup for one origin
        LibraryOrderOrigin.CreateOrderOrigin(OrderOrigin1);
        LibraryOrderOrigin.CreateOrderOrigin(OrderOrigin2);
        UserOrderOrigin."User ID" := GetCurrentUserID();
        UserOrderOrigin."Order Origin Code" := OrderOrigin1.Code;
        UserOrderOrigin.Insert();

        //[WHEN] checking if a different order origin is allowed
        //[THEN] returns false
        Assert.IsFalse(OrderOriginAccessMgt.IsOrderOriginAllowed(UserOrderOrigin."User ID", OrderOrigin2.Code), 'Should return false when order origin is not allowed');

        // Cleanup
        UserOrderOrigin.Delete();
    end;

    local procedure GetCurrentUserID(): Code[50]
    begin
        exit(CopyStr(UserId(), 1, 50));
    end;
}
