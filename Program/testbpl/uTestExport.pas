unit uTestExport;

interface

uses Classes, SysUtils, uRegPluginIntf, uTestPlugin;

procedure InstallPackage;                                   //��װ��
procedure UnInstallPackage;                                 //ж�ذ�
procedure RegisterPlugIn(Reg: IRegPlugin);                  //ע����

exports
  InstallPackage,
  UnInstallPackage,
  RegisterPlugIn;

implementation

procedure InstallPackage;
begin

end;

procedure UnInstallPackage;
begin

end;

procedure RegisterPlugIn(Reg: IRegPlugin);                  //ע����
begin
  Reg.RegisterPluginClass(TTestPlugin);
end;

initialization

finalization

end.

