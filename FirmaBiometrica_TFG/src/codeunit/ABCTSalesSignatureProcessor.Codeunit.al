codeunit 90131 ABCTSalesSignatureProcessor
{

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure ProcessSignatureFlow(var Rec: Record "Sales Header")
    var
        Processor: Codeunit ABCTSalesOrderProcessor;
    begin
        if Rec."Document Type" <> Rec."Document Type"::Quote then
            exit;
        if Rec.ABCTSalesSignature.HasValue and (Rec.ABCTSalesEmail <> '') then
            Processor.RunCompleteProcess(Rec);

    end;


}