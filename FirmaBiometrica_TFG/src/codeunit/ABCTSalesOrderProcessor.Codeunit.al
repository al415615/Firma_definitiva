codeunit 70112 ABCTSalesOrderProcessor
{
    procedure RunCompleteProcess(SalesHeader: Record "Sales Header")
    var
        // vars
        SalesOrder: Record "Sales Header";
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
        if SalesHeader.ABCTSalesEmail = '' then
            exit;
        if IsBlobEmpty(SalesHeader) then
            exit;

        // create the order from the offer
        //if not CreateSalesOrderFromHeader(SalesHeader, SalesOrder) then
        if not ConvertQuoteToOrderManually(SalesHeader, SalesOrder) then
            Error('Failed to create Sales Order from Sales Header');

        // create the parameters or filters to save the pdf
        SalesOrder.CalcFields(ABCTSalesSignature);
        RecRef.GetTable(SalesOrder);

        RecRef.Field(SalesHeader.FieldNo("No.")).SetRange(SalesOrder."No.");
        Parameters := '<?xml version="1.0" standalone="yes"?><ReportParameters name="Standard Sales - Order Conf." id="1305"><Options><Field name="LogInteraction">false</Field><Field name="ArchiveDocument">false</Field></Options><DataItems><DataItem name="Header">VERSION(1) SORTING(Field1,Field3) WHERE(Field1=CONST(%1))</DataItem></DataItems></ReportParameters>';
        FinalParameters := StrSubstNo(Parameters, SalesOrder."No.");

        TempBlob.CreateOutStream(OutStream);
        Report.SaveAs(Report::"Standard Sales - Order Conf.", '', ReportFormat::Pdf, OutStream, RecRef);

        // compose the email

        Subject :=
            'Order Confirmed';

        Body :=
            'Dear customer,<br><br>' +
            'Please find your signed order confirmation attached.<br><br>' +
            'Thank you for your business.';

        // send the email
        EmailMessage.Create(SalesHeader.ABCTSalesEmail, Subject, Body, true);
        TempBlob.CreateInStream(InStream);
        //Temporary because the api will send us back a Base64 already, SAVE THE METHOD
        Base64EncodedPdf := Base64.ToBase64(InStream);
        FileName := 'SalesOrder_' + SalesOrder."No." + '.pdf';
        EmailMessage.AddAttachment(FileName, 'application/pdf', Base64EncodedPdf);
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);

        //SalesHeader.Delete(false);
    end;

    local procedure IsBlobEmpty(SalesHeader: Record "Sales Header"): Boolean
    var
        InStream: InStream;
    begin
        if SalesHeader.ABCTSalesSignature.HasValue then begin
            SalesHeader.ABCTSalesSignature.CreateInStream(InStream);
            exit(InStream.EOS());
        end;
        exit(true);
    end;

    /*
        local procedure CreateSalesOrderFromHeader(var SalesHeader: Record "Sales Header"; var SalesOrder: Record "Sales Header"): Boolean
        var
            SalesHeaderToSalesOrder: Codeunit "Sales-Quote to Order";
            ReleaseSalesOrder: Codeunit "Sales Manual Release";
        begin
            SalesHeaderToSalesOrder.SetHideValidationDialog(false);
            if SalesHeaderToSalesOrder.Run(SalesHeader) then begin
                SalesHeaderToSalesOrder.GetSalesOrderHeader(SalesOrder);

                // change the status to Released
                if SalesOrder.Status <> SalesOrder.Status::Released then
                    ReleaseSalesOrder.Run(SalesOrder);

                exit(true);
            end;
            exit(false);
        end;
     */

    local procedure ConvertQuoteToOrderManually(var SalesQuote: Record "Sales Header"; var SalesOrder: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesOrderLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        //NoSeriesRec: Record "No. Series";
        NoSeriesMgt: Codeunit "No. Series";
        NoSeriesCode: Code[20];
        NewOrderNo: Code[20];
        NextLineNo: Integer;
    begin
        // 1. Get setup
        SalesSetup.Get();

        // 2. Create header of the order
        NoSeriesCode := SalesSetup."Order Nos.";
        NewOrderNo := NoSeriesMgt.GetNextNo(NoSeriesCode);
        SalesOrder.Init();
        SalesOrder."Document Type" := SalesOrder."Document Type"::Order;
        SalesOrder."No." := NewOrderNo;
        SalesOrder.Validate("Sell-to Customer No.", SalesQuote."Sell-to Customer No.");
        SalesOrder."Bill-to Customer No." := SalesQuote."Bill-to Customer No.";
        SalesOrder."Posting Date" := SalesQuote."Posting Date";
        SalesOrder."Order Date" := SalesQuote."Document Date";
        SalesOrder."Requested Delivery Date" := SalesQuote."Requested Delivery Date";
        SalesOrder."Shipment Method Code" := SalesQuote."Shipment Method Code";
        SalesOrder."Location Code" := SalesQuote."Location Code";
        SalesOrder."Shortcut Dimension 1 Code" := SalesQuote."Shortcut Dimension 1 Code";
        SalesOrder."Shortcut Dimension 2 Code" := SalesQuote."Shortcut Dimension 2 Code";
        SalesOrder."ABCTSalesEmail" := SalesQuote."ABCTSalesEmail";
        TransferSignature(SalesQuote, SalesOrder);
        SalesOrder.Insert(true);


        // 3. Copy lines from offer to order
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Quote);
        SalesLine.SetRange("Document No.", SalesQuote."No.");

        if SalesLine.FindSet() then begin
            NextLineNo := 10000;
            repeat
                SalesOrderLine.Init();
                SalesOrderLine."Document Type" := SalesOrderLine."Document Type"::Order;
                SalesOrderLine."Document No." := SalesOrder."No.";
                SalesOrderLine."Line No." := NextLineNo;

                // Copy fields
                SalesOrderLine.Validate("Type", SalesLine."Type");
                SalesOrderLine.Validate("No.", SalesLine."No.");
                SalesOrderLine.Validate("Quantity", SalesLine."Quantity");
                SalesOrderLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                SalesOrderLine."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
                SalesOrderLine."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
                SalesOrderLine."Description" := SalesLine."Description";
                SalesOrderLine.Insert(true);

                NextLineNo += 10000;
            until SalesLine.Next() = 0;
        end;

        // 4. Change status to released
        SalesOrder.Status := SalesOrder.Status::Released;
        SalesOrder.Modify(true);

        exit(true);
    end;

    local procedure TransferSignature(FromHeader: Record "Sales Header"; var ToHeader: Record "Sales Header")
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        if FromHeader.ABCTSalesSignature.HasValue then begin
            FromHeader.ABCTSalesSignature.CreateInStream(InStr);
            ToHeader.ABCTSalesSignature.CreateOutStream(OutStr);
            CopyStream(OutStr, InStr);
            //ToHeader.Modify(true);
        end;
    end;

    /*
        local procedure ConvertBlobToBase64(var SalesHeader: Record "Sales Header"): Text
        var
            Base64: Codeunit "Base64 Convert";
            InStream: InStream;
            Base64string: Text;
        begin
            if not SalesHeader.ABCTSalesSignature.HasValue then
                exit('');
            SalesHeader.ABCTSalesSignature.CreateInStream(InStream);
            Base64string := Base64.ToBase64(InStream);
            exit(Base64string);
        end;
    */
}