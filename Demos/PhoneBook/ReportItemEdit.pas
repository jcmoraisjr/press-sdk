unit ReportItemEdit;

{$I PhoneBook.inc}

interface

uses
  Classes, Controls, StdCtrls, ExtCtrls, CustomEdit, Buttons;

type
  TReportItemEditForm = class(TCustomEditForm)
    CaptionLabel: TLabel;
    CaptionEdit: TEdit;
    VisibleCheckBox: TCheckBox;
    DesignButton: TSpeedButton;
  end;

implementation

{$R *.DFM}

end.
