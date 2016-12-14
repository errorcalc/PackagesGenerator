{******************************************************************************}
{                             PackagesGenerator                                }
{                             ErrorSoft(c) 2016                                }
{                                                                              }
{                     More beautiful things: errorsoft.org                     }
{                                                                              }
{                 https://github.com/errorcalc/PackagesGenerator/              }
{                                                                              }
{           Absolutely free for Open Source and Non Commercial projects.       }
{    Please contact me for information on purchasing the commercial license.   }
{                $10 for individual developers, $50 for company.               }
{                   Email: dr.enter256@gmail.com for contacts.                 }
{******************************************************************************}
program PackagesGenerator;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Gen in 'Gen.pas',
  WinApi.Windows;

const
  Coord: TCoord = (x: 80; y: 2048);

begin
  try
    SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
    Generate;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      if not FindCmdLineSwitch('skip', True) then
      begin
        Writeln('Press any key...');
        Readln;
      end;
    end;
  end;
end.
