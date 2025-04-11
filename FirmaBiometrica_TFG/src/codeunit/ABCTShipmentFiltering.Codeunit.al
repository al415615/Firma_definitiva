codeunit 90136 ABCTShipmentFiltering
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Get Shipment", OnBeforeInsertInvoiceLineFromShipmentLine, '', false, false)]
    local procedure PreventUnSignedShipments(SalesShptHeader: Record "Sales Shipment Header")
    begin
        // add Filter
        SalesShptHeader.SetFilter(ABCTShipmentSignature, '<>''''');
    end;
}