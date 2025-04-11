codeunit 90143 ABCTShipmentSignatureHelper
{
    Permissions = tabledata "Sales Shipment Header" = M;

    procedure SetSignatureFromBlob(var SalesShipmentHeader: Record "Sales Shipment Header"; TempBlob: Codeunit "Temp Blob")
    var
        RecRef: RecordRef;
        FieldId_ABCTShipmentSignature: Integer;

    begin
        FieldId_ABCTShipmentSignature := 90103;
        RecRef.GetTable(SalesShipmentHeader);
        TempBlob.ToRecordRef(RecRef, FieldId_ABCTShipmentSignature);
        //RecRef.SetTable(SalesShipmentHeader);
        RecRef.Modify(true);


    end;
}