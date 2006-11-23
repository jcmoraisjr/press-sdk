unit CompanyEditPresenter;

{$I PhoneBook.inc}

interface

uses
  ContactEditPresenter;

type
  TCompanyPresenter = class(TContactEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

uses
  ObjectModel, CompanyEdit;

{ TCompanyPresenter }

procedure TCompanyPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Contact', 'ContactComboBox', 'Name');
end;

initialization
  TCompanyPresenter.RegisterFormPresenter(TCompany, TCompanyEditForm);

end.
