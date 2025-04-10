page 70102 ABCTSalesShipmentAPI
{
    PageType = API;
    Caption = 'Api For Sales Shipments';
    APIPublisher = 'publisherName';
    APIGroup = 'abct';
    APIVersion = 'v1.0';
    ODataKeyFields = SystemId;
    EntityName = 'salesShipment';
    EntitySetName = 'salesShipments';
    SourceTable = "Sales Shipment Header";
    DelayedInsert = true;
    Permissions = tabledata "Sales Shipment Header" = RMID,
                tabledata "Sales Shipment Line" = R;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(no; Rec."No.")
                {

                }
                field(orderNo; Rec."Order No.")
                {

                }
                field(sellToCustomerNo; Rec."Sell-to Customer No.")
                {

                }
                field(customerName; Rec."Sell-to Customer Name")
                {

                }
                field(postingDate; Rec."Posting Date")
                {

                }
                field(abctShipmentEmail; Rec.ABCTShipmentEmail)
                {

                }
                field(abctShipmentSignatureBase64; Rec.ABCTShipmentSignature)
                {

                }
                field(customerImage; ABCTCustomerImageBase64)
                {

                }
                field(systemID; Rec.SystemId)
                {

                }
                field(abctShipSign; ABCTSignatureBase64)
                {

                }
            }
        }
    }

    var
        ABCTCustomerImageBase64: Text;
        ABCTSignatureBase64: Text;

    trigger OnAfterGetRecord()
    var
        MediaRec: Record "Tenant Media";
        Base64: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        Clear(ABCTCustomerImageBase64);
        Clear(ABCTSignatureBase64);

        if Rec.ABCTCustomerImage.HasValue then
            if MediaRec.Get(Rec.ABCTCustomerImage.MediaId) then begin
                MediaRec.CalcFields(Content);
                MediaRec.Content.CreateInStream(InStr);
                ABCTCustomerImageBase64 := Base64.ToBase64(Instr);
            end;

        if Rec.ABCTShipmentSignature.HasValue then begin
            Rec.CalcFields(ABCTShipmentSignature);
            Rec.ABCTShipmentSignature.CreateInStream(InStr);
            ABCTSignatureBase64 := Base64.ToBase64(InStr);
        end;

    end;


}
