unit PersonEditPresenter;

{$I PhoneBook.inc}

interface

uses
  ContactEditPresenter;

type
  TPersonPresenter = class(TContactEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

uses
  ObjectModel, PersonEdit;

{ TPersonPresenter }

procedure TPersonPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('NickName', 'NickNameEdit');
end;

initialization
  TPersonPresenter.RegisterFormPresenter(TPerson, TPersonEditForm);

end.
