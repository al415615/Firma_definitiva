reportextension 90110 ABCTSalesOrder extends "Standard Sales - Order Conf."
{

    dataset
    {
        add(Header)
        {
            column(ABCTSalesSignature; "ABCTSalesSignature")
            {
                IncludeCaption = false;
            }
        }
    }

    rendering
    {

        layout(CustomerOrdersPrintLayout)
        {
            Type = Word;
            Caption = 'Sale Order Report';
            Summary = 'Detailed report of customer order with amounts.';
            LayoutFile = './src/report/layout/ABCTStandardSalesOrderConf.docx';
        }
    }


}


