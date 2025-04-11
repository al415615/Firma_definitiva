codeunit 90135 ABCTShipmentSignatureProcessor
{


    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure ProcessSignatureFlow(var Rec: Record "Sales Shipment Header"; RunTrigger: Boolean)
    var
        Processor: Codeunit ABCTSalesShipmentProcessor;
    begin
        if not RunTrigger then
            exit;
        if Rec.ABCTShipmentSignature.HasValue and (Rec.ABCTShipmentEmail <> '') then
            Processor.RunCompleteProcess(Rec);


    end;

}