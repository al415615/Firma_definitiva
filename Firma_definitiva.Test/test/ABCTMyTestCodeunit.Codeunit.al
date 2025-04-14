codeunit 90120 ABCTMyTestCodeunit
{

    Subtype = Test;

    [Test]
    // Valid Scenario
    procedure StoreOfferSignatureSuccessfully();
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Record "Sales Header";
        MediaRecord: Record "Tenant Media";
        Customer: Record Customer;
        CustomerNo: Code[20];

    begin
        // [Given] Setup

        CustomerNo := 'TestCust01';

        if Customer.Get(CustomerNo) then
            Customer.Delete();


        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'Cliente Test Firma';
        Customer."Payment Terms Code" := 'C';
        Customer."Payment Method Code" := 'GIRO';
        Customer."Customer Posting Group" := 'NAC';
        Customer."Gen. Bus. Posting Group" := 'NAC';
        Customer.Insert(true);

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
        SalesHeader."No." := 'PRUEBA1';
        SalesHeader."Sell-to Customer No." := CustomerNo;
        SalesHeader.ABCTSalesEmail := 'al415615@uji.es';
        SalesHeader.Insert();

        MediaRecord.FindFirst();
        MediaRecord.CalcFields(Content);

        // [When] Save on the BLOB field of the offer
        SalesHeader.ABCTSalesSignature := MediaRecord.Content;

        SalesHeader.Modify(true);

        // [Then] Verify that the BLOB field is not empty on the Order!

        SalesOrder.SetRange("Document Type", SalesOrder."Document Type"::Order);
        SalesOrder.SetRange("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        SalesOrder.FindLast();

        SalesOrder.CalcFields(ABCTSalesSignature);
        ExpectedValue := true;
        ActualValue := SalesOrder.ABCTSalesSignature.HasValue;
        IfErrorTxt := 'La firma no se guardó correctamente en el campo Blob.';

        AssertThat.AreEqual(ExpectedValue, ActualValue, IfErrorTxt);
    end;


    [Test]
    // IS: Invalid Scenario, no email
    procedure StoreOfferSignatureInvalidEmail();
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Record "Sales Header";
        MediaRecord: Record "Tenant Media";
        Customer: Record Customer;
        CustomerNo: Code[20];

    begin
        // [Given] Setup

        CustomerNo := 'TestCust01';

        if Customer.Get(CustomerNo) then
            Customer.Delete();


        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'Cliente Test Firma';
        Customer."Payment Terms Code" := 'C';
        Customer."Payment Method Code" := 'GIRO';
        Customer."Customer Posting Group" := 'NAC';
        Customer."Gen. Bus. Posting Group" := 'NAC';
        Customer.Insert(true);

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
        SalesHeader."No." := 'PRUEBA2';
        SalesHeader."Sell-to Customer No." := CustomerNo;
        SalesHeader.ABCTSalesEmail := '';
        SalesHeader.Insert();

        MediaRecord.FindFirst();
        MediaRecord.CalcFields(Content);

        // [When] Save on the BLOB field of the offer
        SalesHeader.ABCTSalesSignature := MediaRecord.Content;

        SalesHeader.Modify(true);

        // [Then] Verify that the BLOB field is not empty on the Order!

        SalesOrder.SetRange("Document Type", SalesOrder."Document Type"::Order);
        SalesOrder.SetRange("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        ActualValue := SalesOrder.Count > 0;


        IfErrorTxt := 'La firma no se guardó correctamente en el campo Blob.';

        AssertThat.AreEqual(ExpectedValue, ActualValue, IfErrorTxt);
    end;

    [Test]
    // IS: Invalid Scenario, no email
    procedure StoreOfferSignatureInvalidSignature();
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Record "Sales Header";
        Customer: Record Customer;
        OutStr: OutStream;
        CustomerNo: Code[20];

    begin
        // [Given] Setup

        CustomerNo := 'TestCust01';

        if Customer.Get(CustomerNo) then
            Customer.Delete();


        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'Cliente Test Firma';
        Customer."Payment Terms Code" := 'C';
        Customer."Payment Method Code" := 'GIRO';
        Customer."Customer Posting Group" := 'NAC';
        Customer."Gen. Bus. Posting Group" := 'NAC';
        Customer.Insert(true);

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
        SalesHeader."No." := 'PRUEBA3';
        SalesHeader."Sell-to Customer No." := CustomerNo;
        SalesHeader.ABCTSalesEmail := 'al415615@uji.es';
        SalesHeader.Insert();



        // [When] Save on the BLOB field EMPTY
        SalesHeader.CalcFields(ABCTSalesSignature);
        SalesHeader.ABCTSalesSignature.CreateOutStream(OutStr);

        SalesHeader.Modify(true);

        // [Then] Verify that the BLOB field is not empty on the Order!

        SalesOrder.SetRange("Document Type", SalesOrder."Document Type"::Order);
        SalesOrder.SetRange("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        ActualValue := SalesOrder.Count > 0;


        IfErrorTxt := 'La firma no se guardó correctamente en el campo Blob.';

        AssertThat.AreEqual(ExpectedValue, ActualValue, IfErrorTxt);
    end;


    [Test]
    // Valid Scenario
    procedure StoreShipmentSignatureSuccessfully();
    var
        ShipmentHeader: Record "Sales Shipment Header";
        MediaRecord: Record "Tenant Media";


    begin

        // [Given] A shipment that already exists
        ShipmentHeader.FindFirst();

        MediaRecord.FindFirst();
        MediaRecord.CalcFields(Content);

        // [When] Save on the BLOB field of the offe
        ShipmentHeader.ABCTShipmentSignature := MediaRecord.Content;
        ShipmentHeader.Modify(true);

        ShipmentHeader.Get(ShipmentHeader."No."); // Reload to see if the signature is on the field
        ShipmentHeader.CalcFields(ABCTShipmentSignature);

        // [Then] 
        ExpectedValue := true;
        ActualValue := ShipmentHeader.ABCTShipmentSignature.HasValue;
        IfErrorTxt := 'La firma no se ha guardado correctamente en el campo BLOB del albarán.';
        AssertThat.AreEqual(ExpectedValue, ActualValue, IfErrorTxt);
    end;

    [Test]
    // IS: Invalid Scenario, no signature
    procedure StoreShipmentSignatureInvalidSignature();
    var
        ShipmentHeader: Record "Sales Shipment Header";




    begin

        // [Given] A shipment that already exists
        ShipmentHeader.FindFirst(); // First Shipment found

        // [When] Save on the BLOB field of the offe
        Clear(ShipmentHeader.ABCTShipmentSignature);
        ShipmentHeader.Modify(true);


        ShipmentHeader.Get(ShipmentHeader."No."); // Reload to see if the signature is on the field
        ShipmentHeader.CalcFields(ABCTShipmentSignature);

        // [Then] 
        ExpectedValue := false;
        ActualValue := ShipmentHeader.ABCTShipmentSignature.HasValue;
        IfErrorTxt := 'Se ha guardado una firma en el campo BLOB del albarán.';
        AssertThat.AreEqual(ExpectedValue, ActualValue, IfErrorTxt);
    end;


    var
        AssertThat: Codeunit "Library Assert";
        ExpectedValue: Variant;
        ActualValue: Boolean;
        IfErrorTxt: Text;

}