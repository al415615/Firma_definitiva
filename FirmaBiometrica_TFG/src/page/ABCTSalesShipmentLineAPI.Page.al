page 70104 ABCTSalesShipmentLineAPI
{
    PageType = API;
    Caption = 'Sales Shipment Line API';
    APIPublisher = 'publisherName';
    APIGroup = 'abct';
    APIVersion = 'v1.0';
    EntityName = 'shipmentLine';
    EntitySetName = 'shipmentLines';
    SourceTable = "Sales Shipment Line";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(documentNo; Rec."Document No.")
                {

                }
                field(lineNo; Rec."Line No.")
                {

                }
                field(type; Rec."Type")
                {

                }
                field(no; Rec."No.")
                {

                }
                field(description; Rec."Description")
                {

                }
                field(quantity; Rec."Quantity")
                {

                }
                field(unitOfMeasure; Rec."Unit of Measure Code")
                {

                }
                field(unitPrice; Rec."Unit Price")
                {

                }
                field(itemImage; ABCTItemImageBase64)
                {

                }
            }
        }
    }

    var
        ABCTItemImageBase64: Text;

    trigger OnAfterGetRecord()
    var
        MediaRec: Record "Tenant Media";
        Base64: Codeunit "Base64 Convert";
        InStr: InStream;
        EmptyGuid: Guid;
    begin
        Clear(ABCTItemImageBase64);

        if Rec.ABCTItemImage <> EmptyGuid then
            if MediaRec.Get(Rec.ABCTItemImage) then begin
                MediaRec.CalcFields(Content);
                MediaRec.Content.CreateInStream(InStr);
                ABCTItemImageBase64 := Base64.ToBase64(Instr);
            end;

    end;
}