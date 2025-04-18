namespace DefaultPublisher.ALProject1;
using Microsoft.Sales.Document;
using System.Text;
using Microsoft.Sales.Customer;
using System.Utilities;
using System.Email;
using System.IO;
using System.Environment;


tableextension 90100 ABCTSalesHeader extends "Sales Header"
{
    fields
    {
        field(90101; ABCTSalesEmail; Text[100])
        {
            Caption = 'Sales Email', Comment = 'ESP="Email del cliente"';
            Tooltip = 'Specifies the sales contact email address.', Comment = 'ESP="Especifica el email de contacto del cliente"';
            ExtendedDatatype = Email;
            DataClassification = CustomerContent;
        }


        field(90102; ABCTSalesSignature; BLOB)
        {
            Caption = 'Customer Signature', Comment = 'ESP="Firma del cliente"';
            Tooltip = 'Specifies the customer’s signature as an image.', Comment = 'ESP="Especifica la firma del cliente"';
            SubType = Bitmap;
            DataClassification = CustomerContent;

        }
        field(90104; ABCTCustomerImage; Media)
        {
            Caption = 'Customer Image', Comment = 'ESP="Foto de perfil del cliente"';
            Tooltip = 'Specifies the customer’s image.', Comment = 'ESP="Especifica la foto de perfil del cliente"';
            DataClassification = CustomerContent;
        }

    }


    trigger OnInsert()
    var
        Customer: Record Customer;
        TenantMedia: Record "Tenant Media";
        InStr: InStream;
    begin
        if Rec."Document Type" = Rec."Document Type"::Quote then
            if Customer.Get(Rec."Sell-to Customer No.") and Customer.Image.HasValue then begin

                // Obtain the original content
                TenantMedia.Get(Customer.Image.MediaId);
                TenantMedia.CalcFields(Content);
                TenantMedia.Content.CreateInStream(InStr);

                Rec.ABCTCustomerImage.ImportStream(InStr, 'image/png');
            end;
    end;


}

