namespace DefaultPublisher.ALProject1;
using Microsoft.Sales.Document;
using System.Utilities;

pageextension 90103 ABCTSalesOrder extends "Sales Order"
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
        }
    }


}