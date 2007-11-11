program SimpleOPF;

uses
  FastMM4,
  Forms,
  PressApplication,
  MainFrm in '..\..\Units\MainFrm.pas' {MainForm},
  PersonBO in '..\..\Units\PersonBO.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  PressApp.Run;
end.
