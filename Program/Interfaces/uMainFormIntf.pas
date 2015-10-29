unit uMainFormIntf;

interface

uses Forms, Classes, Graphics, uFactoryFormIntf;

type
  //主窗口实现的接口
  IMainForm = interface
    ['{C3DF922D-4AA5-4874-B0A3-72699DA671C8}']
    function CreateMenu(const Path: string; MenuClick: TNotifyEvent): TObject; //创建普通菜单
    procedure CloseFom(AFormIntf: IFormIntf; var ACanClose: Boolean);
  end;

implementation

end.

