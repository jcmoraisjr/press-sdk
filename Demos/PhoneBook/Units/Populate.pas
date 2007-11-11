unit Populate;

{$I PhoneBook.inc}

interface

uses
  PressSubject;

procedure PopulatePhoneBook(AList: TPressObjectList);

implementation

uses
  ContactBO;

procedure PopulatePhoneBook(AList: TPressObjectList);
var
  VPerson: TPerson;
  VCompany: TCompany;
  VPhone: TPhone;
  VCity: TCity;
begin
  VPerson := TPerson.Create;
  AList.Add(VPerson);
  VPerson.Id := '1';  // this is not necessary, used because of the retrieve, some lines below
  VPerson.Name := 'Joe Smith';
  VPerson.NickName := 'Joe';
  VPerson.Address.Street := 'Epitacio Pessoa';
  VPerson.Address.Zip := '13091-595';
  VCity := TCity.Create;
  VPerson.Address.City := VCity;
  VCity.Release;
  VCity.Id := '2';  // same
  VCity.Name := 'Campinas';
  VCity.State := 'SP';
  VCity.Store;
  VPerson.Store;

  VPerson := TPerson.Create;
  AList.Add(VPerson);
  VPerson.Name := 'Jane Lee';
  VPerson.NickName := 'Jane';
  VPerson.Address.Street := 'Mal. Deodoro';
  VPerson.Address.Zip := '30150-110';
  VCity := TCity.Create;
  VPerson.Address.City := VCity;
  VCity.Release;
  VCity.Name := 'Belo Horizonte';
  VCity.State := 'MG';
  VCity.Store;
  VPhone := VPerson.Phones.Add;
  VPhone.Number := '1213-6798';
  VPhone.PhoneType := ptPhone;
  VPhone := VPerson.Phones.Add;
  VPhone.Number := '9866-2122';
  VPhone.PhoneType := ptMobile;
  VPerson.Store;

  VCompany := TCompany.Create;
  AList.Add(VCompany);
  VCompany.Name := 'Press Software Ltda.';
  VCompany.Contact := TPerson.Retrieve('1');
  VCompany.Contact.Release;  // Retrieve will increase the reference count, release will avoid memory leak
  VCompany.Address.Street := 'XV de Novembro';
  VCompany.Address.Zip := '13106-026';
  VCompany.Address.City := TCity.Retrieve('2');
  VCompany.Address.City.Release;  // same
  VPhone := VCompany.Phones.Add;
  VPhone.Number := '2213-2100';
  VPhone.PhoneType := ptPhone;
  VPhone := VCompany.Phones.Add;
  VPhone.Number := '2213-2128';
  VPhone.PhoneType := ptFax;
  VCompany.Store;
end;

end.
