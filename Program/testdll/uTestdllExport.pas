unit uTestdllExport;

interface

uses Classes, SysUtils, uRegPluginIntf, uTestdllPlugin;

procedure InstallPackage;                                   //��װ��
procedure UnInstallPackage;                                 //ж�ذ�
procedure RegisterPlugIn(Reg: IRegPlugin);                  //ע����

implementation

procedure InstallPackage;
begin

end;

procedure UnInstallPackage;
begin

end;

procedure RegisterPlugIn(Reg: IRegPlugin);                  //ע����
begin
  Reg.RegisterPluginClass(TTestdllPlugin);
end;

initialization

finalization

end.

