unit ReportGroupEditPresenter;

{$I PhoneBook.inc}

interface

uses
  CustomEditPresenter;

type
  TReportGroupEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

uses
  PressReportModel, ReportGroupEdit;

{ TReportGroupEditPresenter }

procedure TReportGroupEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Reports', 'ReportsStringGrid',
   'Caption(160);Visible(32)');
end;

initialization
  TReportGroupEditPresenter.RegisterFormPresenter(
   TPressDefaultReportGroup, TReportGroupEditForm);

end.
