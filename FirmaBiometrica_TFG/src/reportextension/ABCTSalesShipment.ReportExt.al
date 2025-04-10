reportextension 70111 ABCTSalesShipment extends "Standard Sales - Shipment"
{

    dataset
    {
        add(Header)
        {

            column(ABCTShipmentSignature; ABCTShipmentSignature)
            {
                IncludeCaption = false;
            }
        }
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            begin
                Header.CalcFields(ABCTShipmentSignature);
            end;
        }
    }

    rendering
    {

        layout(ABCTShipmentLayout)
        {
            Type = Word;
            Caption = 'Sales Shipment with Signature';
            Summary = 'Shipment confirmation including customer signature';
            LayoutFile = './src/report/layout/ABCTStandardSalesShipment.docx';
        }
    }

}


