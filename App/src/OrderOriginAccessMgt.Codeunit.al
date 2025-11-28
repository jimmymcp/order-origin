codeunit 50201 "Order Origin Access Mgt."
{
    procedure HasUserOrderOriginSetup(UserID: Code[50]): Boolean
    var
        UserOrderOrigin: Record "User Order Origin";
    begin
        UserOrderOrigin.SetRange("User ID", UserID);
        exit(not UserOrderOrigin.IsEmpty());
    end;

    procedure IsOrderOriginAllowed(UserID: Code[50]; OrderOriginCode: Code[10]): Boolean
    var
        UserOrderOrigin: Record "User Order Origin";
    begin
        if not HasUserOrderOriginSetup(UserID) then
            exit(true);

        UserOrderOrigin.SetRange("User ID", UserID);
        UserOrderOrigin.SetRange("Order Origin Code", OrderOriginCode);
        exit(not UserOrderOrigin.IsEmpty());
    end;

    procedure FilterOrderOrigins(var OrderOrigin: Record "Order Origin")
    var
        UserOrderOrigin: Record "User Order Origin";
        UserID: Code[50];
        OrderOriginFilter: Text;
    begin
        UserID := CopyStr(UserId(), 1, MaxStrLen(UserID));
        if not HasUserOrderOriginSetup(UserID) then
            exit;

        UserOrderOrigin.SetRange("User ID", UserID);
        if UserOrderOrigin.FindSet() then
            repeat
                if OrderOriginFilter <> '' then
                    OrderOriginFilter += '|';
                OrderOriginFilter += UserOrderOrigin."Order Origin Code";
            until UserOrderOrigin.Next() = 0;

        if OrderOriginFilter = '' then
            OrderOrigin.SetFilter(Code, '''')
        else
            OrderOrigin.SetFilter(Code, OrderOriginFilter);
    end;
}
