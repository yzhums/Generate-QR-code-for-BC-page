pageextension 50101 CustomerListExt extends "Customer Card"
{
    actions
    {
        addafter("Sent Emails")
        {
            action(OpenCustomerCard)
            {
                Caption = 'Open Customer Card';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = Open;
                trigger OnAction()
                begin
                    Hyperlink(GetUrl(ClientType::Current, CompanyName, ObjectType::Page, Page::"Customer Card", Rec));
                end;
            }

            action(CustomerCardBarCode)
            {
                Caption = 'Customer Card Barcodes';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = Report;

                trigger OnAction()
                var
                    RepCustomerCardBarCode: Report CustomerCardBarCode;
                begin
                    RepCustomerCardBarCode.AssignBarcodeURL(Rec."No.", Rec.Name, GetUrl(ClientType::Current, CompanyName, ObjectType::Page, Page::"Customer Card", Rec));
                    RepCustomerCardBarCode.Run();
                end;
            }
        }
    }
}

report 50100 CustomerCardBarCode
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    Caption = 'Customer Card Barcodes';
    RDLCLayout = 'CustCardBarcodes.rdl';
    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";

            column(CustomerNo; CustomerNo)
            {
            }
            column(CustomerName; CustomerName)
            {
            }
            column(BarcodeURL; BarcodeURL)
            {
            }
            column(QRCode; QRCode)
            {
            }
            trigger OnAfterGetRecord()
            begin
                GenerateQRCode();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(URL)
                {
                    field(BarcodeURL; BarcodeURL)
                    {
                        Caption = 'Barcode URL';
                        ApplicationArea = All;
                        MultiLine = true;
                        Editable = false;
                    }
                    field(CustomerNo; CustomerNo)
                    {
                        Caption = 'Customer No.';
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(CustomerName; CustomerName)
                    {
                        Caption = 'Customer Name';
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            CustomerNo := Customer."No.";
            CustomerName := Customer.Name;
        end;
    }

    var
        QRCode: Text;
        BarcodeURL: Text;
        CustomerNo: Code[20];
        CustomerName: Text[100];

    local procedure GenerateQRCode()
    var
        BarcodeSymbology2D: Enum "Barcode Symbology 2D";
        BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
        BarcodeString: Text;
    begin
        BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
        BarcodeSymbology2D := Enum::"Barcode Symbology 2D"::"QR-Code";
        QRCode := BarcodeFontProvider2D.EncodeFont(BarcodeURL, BarcodeSymbology2D);
    end;

    procedure AssignBarcodeURL(CustNo: Code[20]; CustName: text[100]; NewBarcodeURL: Text)
    begin
        Customer."No." := CustNo;
        Customer.Name := CustName;
        BarcodeURL := NewBarcodeURL;
    end;
}
