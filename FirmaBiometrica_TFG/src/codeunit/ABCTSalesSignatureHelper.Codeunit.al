codeunit 90140 ABCTSalesSignatureHelper
{

    procedure SetSignatureFromBlob(var SalesHeader: Record "Sales Header"; TempBlob: Codeunit "Temp Blob")

    var
        RecRef: RecordRef;
        FieldId_ABCTSalesSignature: Integer;

    begin
        FieldId_ABCTSalesSignature := 90102;
        RecRef.GetTable(SalesHeader);
        TempBlob.ToRecordRef(RecRef, FieldId_ABCTSalesSignature);
        RecRef.SetTable(SalesHeader);
    end;

}