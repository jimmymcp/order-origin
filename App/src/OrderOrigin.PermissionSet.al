permissionset 50200 "Order Origin"
{
    Permissions = tabledata "Order Origin" = RIMD,
        tabledata "User Order Origin" = RIMD,
        table "Order Origin" = X,
        table "User Order Origin" = X,
        codeunit "Sales Subscriptions" = X,
        codeunit "Order Origin Access Mgt." = X,
        page "Order Origins" = X,
        page "User Order Origins" = X;
}