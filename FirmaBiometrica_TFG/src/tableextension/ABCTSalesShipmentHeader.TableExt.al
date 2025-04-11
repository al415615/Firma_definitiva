namespace DefaultPublisher.ALProject1;
using Microsoft.Sales.Document;
using System.Text;
using System.Utilities;
using System.Email;
using System.IO;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using System.Environment;


tableextension 90101 ABCTSalesShipmentHeader extends "Sales Shipment Header"
{
    fields
    {
        field(90101; ABCTShipmentEmail; Text[100])
        {
            Caption = 'Sales Email', Comment = 'Email del cliente';
            Tooltip = 'Specifies the sales contact email address.', Comment = 'Especifica el email de contacto del cliente';
            ExtendedDatatype = Email;
            DataClassification = CustomerContent;
        }

        field(90103; ABCTShipmentSignature; BLOB)
        {
            Caption = 'Customer Signature', Comment = 'Firma del cliente';
            Tooltip = 'Specifies the customer’s signature as an image.', Comment = 'Especifica la firma del cliente';
            SubType = Bitmap;
            DataClassification = CustomerContent;

        }

        field(90105; ABCTCustomerImage; Media)
        {
            Caption = 'Customer Image', Comment = 'Foto de perfil del cliente';
            Tooltip = 'Specifies the customer’s image.', Comment = 'Especifica la foto de perfil del cliente';
            DataClassification = CustomerContent;
        }

    }


    trigger OnInsert()
    var
        Customer: Record Customer;
        TenantMedia: Record "Tenant Media";
        InStr: InStream;
    begin

        if Customer.Get(Rec."Sell-to Customer No.") and Customer.Image.HasValue then begin

            // Obtain the original content
            TenantMedia.Get(Customer.Image.MediaId);
            TenantMedia.CalcFields(Content);
            TenantMedia.Content.CreateInStream(InStr);

            Rec.ABCTCustomerImage.ImportStream(InStr, 'image/png');
        end;
    end;
}
