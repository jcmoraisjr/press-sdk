unit ReportItemEditPresenter;

{$I PhoneBook.inc}

interface

uses
  PressMVPModel, CustomEditPresenter;

type
  TReportItemEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
    class function InternalModelClass: TPressMVPObjectModelClass; override;
  end;

implementation

uses
  PressReportModel, ReportItemEdit, ReportItemEditModel;

{ TReportItemEditPresenter }

procedure TReportItemEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Caption', 'CaptionEdit');
  CreateSubPresenter('Visible', 'VisibleCheckBox');
  BindCommand(TDesignReportCommand, 'DesignButton');
end;

class function TReportItemEditPresenter.InternalModelClass: TPressMVPObjectModelClass;
begin
  Result := TReportItemEditModel;
end;

initialization
  TReportItemEditPresenter.RegisterFormPresenter(
   TPressDefaultReportItem, TReportItemEditForm);

end.
