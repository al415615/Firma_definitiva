codeunit 70114 ABCTSalesShipmentProcessor
{
    Permissions = tabledata "Sales Shipment Header" = RMID,
                tabledata "Sales Shipment Line" = R;

    procedure RunCompleteProcess(SalesShipmentHeader: Record "Sales Shipment Header")
    var
        // vars 
        TempBlob: Codeunit "Temp Blob";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Base64: Codeunit "Base64 Convert";
        //FileManagement: Codeunit "File Management";
        RecRef: RecordRef;
        InStream: InStream;
        OutStream: OutStream;
        FileName: Text[250];
        Subject: Text;
        Body: Text;
        //Base64Signature: Text;
        Base64EncodedPdf: Text;
        Parameters: Text;
        FinalParameters: Text;
    begin
        // verify that the fields are not empty
        if SalesShipmentHeader.ABCTShipmentEmail = '' then
            exit;
        if IsBlobEmpty(SalesShipmentHeader) then
            exit;

        // create the parameters or filters to save the pdf

        RecRef.GetTable(SalesShipmentHeader);

        RecRef.Field(SalesShipmentHeader.FieldNo("No.")).SetRange(SalesShipmentHeader."No.");

        Parameters := '<?xml version="1.0" standalone="yes"?><ReportParameters name="Standard Sales - Order Conf." id="1305"><Options><Field name="LogInteraction">false</Field><Field name="ArchiveDocument">false</Field></Options><DataItems><DataItem name="Header">VERSION(1) SORTING(Field1,Field3) WHERE(Field1=CONST(%1))</DataItem></DataItems></ReportParameters>';
        FinalParameters := StrSubstNo(Parameters, SalesShipmentHeader."No.");

        TempBlob.CreateOutStream(OutStream);
        Report.SaveAs(Report::"Standard Sales - Shipment", '', ReportFormat::Pdf, OutStream, RecRef);

        // compose the email

        Subject :=
            'Sales Shipment Confirmed';

        Body :=
            'Dear customer,<br><br>' +
            'Please find your signed shipment confirmation attached.<br><br>' +
            'Thank you for your business.';

        // send the email
        EmailMessage.Create(SalesShipmentHeader.ABCTShipmentEmail, Subject, Body, true);
        TempBlob.CreateInStream(InStream);
        //TODO: Temporary because the api will send us back a Base64 already, SAVE THE METHOD
        Base64EncodedPdf := Base64.ToBase64(InStream);
        FileName := 'SalesShipment_' + SalesShipmentHeader."No." + '.pdf';
        EmailMessage.AddAttachment(FileName, 'application/pdf', Base64EncodedPdf);
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);


    end;

    local procedure IsBlobEmpty(SalesShipmentHeader: Record "Sales Shipment Header"): Boolean
    var
        InStream: InStream;
    begin
        if SalesShipmentHeader.ABCTShipmentSignature.HasValue then begin
            SalesShipmentHeader.ABCTShipmentSignature.CreateInStream(InStream);
            exit(InStream.EOS());
        end;
        exit(true);
    end;


}