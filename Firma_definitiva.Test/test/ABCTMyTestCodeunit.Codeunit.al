codeunit 90120 ABCTMyTestCodeunit
{

    Subtype = Test;

    [Test]
    procedure UploadSignatureToShipmentTest()
    var
        ShipmentHeader: Record "Sales Shipment Header";
        TempBlob: Codeunit "Temp Blob";
        SignatureHelper: Codeunit ABCTShipmentSignatureHelper;
        OutStr: OutStream;
        InStr: InStream;
    begin
        // [Given] Preparación del entorno
        ShipmentHeader.FindFirst(); // Usa el primer albarán existente para la prueba
        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText('FakeSignatureData'); // Simula una firma

        // [When] Acción: se guarda la firma
        TempBlob.CreateInStream(InStr);
        SignatureHelper.SetSignatureFromBlob(ShipmentHeader, TempBlob);

        // [Then] Verificación: comprobar que se ha guardado correctamente
        ShipmentHeader.Get(ShipmentHeader."No.");
        ShipmentHeader.CalcFields(ABCTShipmentSignature);

        IfErrorTxt := 'La firma no se ha guardado correctamente';
        AssertThat.IsTrue(ShipmentHeader.ABCTShipmentSignature.HasValue, IfErrorTxt);
    end;

    var
        AssertThat: Codeunit "Library Assert";
        ExpectedValue: Variant;
        ActualValue: Variant;
        IfErrorTxt: Text;

}