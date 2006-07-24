unit MainPresenter;

interface

uses
  PressMVPPresenter;

type
  TMainPresenter = class(TPressMVPMainFormPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

uses
  PressMVPCommand, ObjectModel, Main, MainModel;

{ TMainPresenter }

procedure TMainPresenter.InitPresenter;
begin
  inherited;
  CreateQueryItemsPresenter(
   'ItemsStringGrid', 'Name(240);Address.City.Name(160)', TMainModel);
  BindCommand(TPressMVPExecuteQueryCommand, 'QuerySpeedButton');
  CreateSubPresenter('Name', 'NameQueryEdit');
end;

initialization
  TMainPresenter.RegisterFormPresenter(TMainQuery, TMainForm);
  PressAssignMainPresenterClass(TMainPresenter);

end.
