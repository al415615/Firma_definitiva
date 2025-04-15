namespace DefaultPublisher.ALProject1;
using Microsoft.Sales.Document;
using System.Text;
using System.Utilities;
using System.Email;
using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using System.Environment;


tableextension 90103 ABCTSalesOfferLine extends "Sales Line"
{
    fields
    {

        field(90105; ABCTItemImage; Guid)
        {
            Caption = 'Item Image', Comment = 'ESP="Imagen del artículo"';
            Tooltip = 'Specifies the item’s image.', Comment = 'ESP="Especifica la imagen del artículo"';
            DataClassification = CustomerContent;
        }

    }

    trigger OnInsert()
    var
        Item: Record Item;
    begin
        if Item.Get(Rec."No.") and (Item.Picture.Count > 0) then
            Rec.ABCTItemImage := Item.Picture.Item(1);
    end;

}
