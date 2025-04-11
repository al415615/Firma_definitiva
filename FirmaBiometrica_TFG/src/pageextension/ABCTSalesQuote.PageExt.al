namespace DefaultPublisher.ALProject1;
using Microsoft.Sales.Document;
using System.IO;
using System.Utilities;

pageextension 90101 ABCTSalesQuote extends "Sales Quote"
{
    layout
    {
        addLast(General)
        {
            field(ABCTSalesEmail; Rec.ABCTSalesEmail)
            {
                ApplicationArea = All;
                ShowMandatory = true;
            }
            field(ABCTSalesSignature; Rec.ABCTSalesSignature)
            {
                ApplicationArea = All;
                ShowMandatory = true;
            }

            field(ABCTCustomerImage; Rec.ABCTCustomerImage)
            {
                ApplicationArea = All;
                ShowMandatory = true;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(ABCTUploadSignature)
            {
                ApplicationArea = All;
                Caption = 'Upload Signature', Comment = 'Importar firma';
                Image = Import;
                ToolTip = 'Specifies the action oof uploading the signature', Comment = 'Especifica la acción de importar la firma';

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    ABCTSignatureHelper: Codeunit ABCTSalesSignatureHelper;
                    InStr: InStream;
                    OutStr: OutStream;
                    FileName: Text;

                begin
                    FileName := CopyStr('SalesOrder_' + Format(Rec."No.") + '.pdf', 1, 250);
                    UploadIntoStream('Upload Signature', '', '', FileName, InStr);
                    TempBlob.CreateOutStream(OutStr);
                    CopyStream(OutStr, InStr);

                    // Assign the content from the TempBlob to the Blob 
                    ABCTSignatureHelper.SetSignatureFromBlob(Rec, TempBlob);
                    Rec.Modify(true);
                end;
            }

            action(ABCTPrintQuotePDF)
            {
                Caption = 'Print PDF';
                ApplicationArea = All;
                Image = Print;
                ToolTip = 'Specifies Action To Print';

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileManagement: Codeunit "File Management";

                    RecRef: RecordRef;

                    Parameters: Text;
                    ReportParameters: Text;
                    Outstream: OutStream;

                begin
                    Parameters := '<?xml version="1.0" standalone="yes"?><ReportParameters name="Standard Sales - Quote" id="1304"><Options><Field name="LogInteraction">false</Field><Field name="ArchiveDocument">false</Field></Options><DataItems><DataItem name="Header">VERSION(1) SORTING(Field1,Field3) WHERE(Field3=1(%1))</DataItem></DataItems></ReportParameters>';

                    ReportParameters := Report.RunRequestPage(Report::"Standard Sales - Quote");

                    RecRef.GetTable(Rec);

                    TempBlob.CreateOutStream(Outstream);
                    Report.SaveAs(Report::"Standard Sales - Quote", ReportParameters, ReportFormat::Pdf, Outstream, RecRef);

                    FileManagement.BLOBExport(TempBlob, 'SalesQuote_' + Rec."No." + '.pdf', true);
                end;
            }
        }
    }
}
