namespace DefaultPublisher.ALProject1;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.Utilities;

pageextension 90102 ABCTPostedSalesShipment extends "Posted Sales Shipment"
{



    layout
    {
        addLast(General)
        {
            field(ABCTSalesEmail; Rec.ABCTShipmentEmail)
            {
                ApplicationArea = All;
                ShowMandatory = true;
                Caption = 'Customer email';
                Editable = true;
            }
            field(ABCTShipmentSignature; Rec.ABCTShipmentSignature)
            {
                ApplicationArea = All;
                ShowMandatory = true;
                Caption = 'Customer Signature';
                Editable = true;
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
                    //SalesOrder: Record "Sales Header";
                    TempBlob: Codeunit "Temp Blob";
                    ABCTSignatureHelper: Codeunit ABCTShipmentSignatureHelper;
                    InStr: InStream;
                    OutStr: OutStream;
                    FileName: Text;

                begin
                    FileName := CopyStr('Shipment_' + Format(Rec."No.") + '.pdf', 1, 250);
                    UploadIntoStream('Upload Signature', '', '', FileName, InStr);
                    TempBlob.CreateOutStream(OutStr);
                    CopyStream(OutStr, InStr);

                    // Assign the content from the TempBlob to the Blob 
                    ABCTSignatureHelper.SetSignatureFromBlob(Rec, TempBlob);

                end;
            }
        }
    }



}