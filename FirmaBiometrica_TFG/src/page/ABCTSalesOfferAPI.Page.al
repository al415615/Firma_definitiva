page 70101 ABCTSalesOfferAPI
{
    PageType = API;
    Caption = 'Api For Sales Offers';
    APIPublisher = 'publisherName';
    APIGroup = 'abct';
    APIVersion = 'v1.0';
    ODataKeyFields = SystemId;
    EntityName = 'salesOffer';
    EntitySetName = 'salesOffers';
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = filter("Sales Document Type"::Quote));
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(no; Rec."No.")
                {

                }
                field(documentType; Rec."Document Type")
                {

                }
                field(customerNo; Rec."Sell-to Customer No.")
                {

                }
                field(customerName; Rec."Sell-to Customer Name")
                {

                }
                field(documentDate; Rec."Document Date")
                {

                }
                field(postingDate; Rec."Posting Date")
                {

                }
                field(status; Rec."Status")
                {

                }
                field(email; Rec.ABCTSalesEmail)
                {

                }
                field(signatureBase64; Rec.ABCTSalesSignature)
                {

                }
                field(customerImage; ABCTCustomerImageBase64)
                {

                }
                field(systemID; Rec.SystemId)
                {

                }
            }
        }
    }

    procedure GetSignatureBase64(): Text
    var
        Base64: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        if Rec.ABCTSalesSignature.HasValue then begin
            Rec.CalcFields(ABCTSalesSignature);
            Rec.ABCTSalesSignature.CreateInStream(InStr);
            exit(Base64.ToBase64(InStr));
        end;
        exit('');
    end;


    var
        ABCTCustomerImageBase64: Text;

    trigger OnAfterGetRecord()
    var
        MediaRec: Record "Tenant Media";
        Base64: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        Clear(ABCTCustomerImageBase64);

        if Rec.ABCTCustomerImage.HasValue then
            if MediaRec.Get(Rec.ABCTCustomerImage.MediaId) then begin
                MediaRec.CalcFields(Content);
                MediaRec.Content.CreateInStream(InStr);
                ABCTCustomerImageBase64 := Base64.ToBase64(Instr);
            end;

    end;

}