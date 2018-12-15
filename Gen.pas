{******************************************************************************}
{                             PackagesGenerator                                }
{                             ErrorSoft(c) 2018                                }
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
unit Gen;

interface

procedure Generate;

implementation

uses
  System.IniFiles, System.SysUtils, System.Classes, System.Generics.Collections, System.RegularExpressionsCore,
  System.RegularExpressions;

const
  sDelimiter = '===============================================================================';
  sLiteDelimiter = '-------------------------------------------------------------------------------';
  sTitle =
'{****************************************************************************}' + sLineBreak +
'{                            PackagesGenerator                               }' + sLineBreak +
'{                     ErrorSoft(c) Peter Sokolov, 2018                       }' + sLineBreak +
'{                                                                            }' + sLineBreak +
'{                    More beautiful things: errorsoft.org                    }' + sLineBreak +
'{                                                                            }' + sLineBreak +
'{               https://github.com/errorcalc/PackagesGenerator/              }' + sLineBreak +
'{                                                                            }' + sLineBreak +
'{          Absolutely free for Open Source and Non Commercial projects.      }' + sLineBreak +
'{   Please contact me for information on purchasing the commercial license.  }' + sLineBreak +
'{               $10 for individual developers, $50 for company.              }' + sLineBreak +
'{                  Email: dr.enter256@gmail.com for contacts.                }' + sLineBreak +
'{****************************************************************************}';
  sVer = 'ErrorSoft PackagesGenerator for Delphi, v0.8 Alpha';

var
  Ini: TMemIniFile;
  HideOutput: Boolean = False;

function GetConfigFile: string;
begin
  if ParamCount >= 2 then
    if ParamStr(1).ToLower = '-config' then
      if IsRelativePath(ParamStr(2)) then
        Exit(GetCurrentDir + '\' + ParamStr(2))
      else
        Exit(ParamStr(2));
    // else
    //   raise EProgrammerNotFound.Create('Bad command line!');

  Result := GetCurrentDir + '\PackagesGenerator.ini';
end;

procedure Print(Text: string; Level: Byte = 0);
begin
  if HideOutput then
    Exit;
  Writeln(''.PadRight(Level * 2), Text);
end;

procedure ProcessDpk(F: TStrings; Ver: string; Base, Gen: string);
const
  Files = '.*in.*''.+''';
  OneFile  = '''.*''';
  LibSuffix = '.*\{\$LIBSUFFIX.*\}';
  AnyDirrective = '\{\$.*\}';

var
  p: Integer;
  I: Integer;
  NameFrom, NameTo: string;
begin
  // search 'contains'
  p := -1;
  for I := 0 to F.Count - 1 do
    if F[I].IndexOf('contains') <> -1 then
    begin
      p := I;
    end;
  // replace file names
  if p <> -1 then
    for I := p to F.Count - 1 do
      if TRegEx.IsMatch(F[I], Files) then
      begin
        NameTo := ExtractRelativePath(Gen, Base + TRegEx.Match(F[I], OneFile, [roIgnoreCase]).Value.DeQuotedString(''''));
        NameFrom := TRegEx.Match(F[I], OneFile, [roIgnoreCase]).Value.DeQuotedString('''');
        F[I] := F[I].Replace(NameFrom, NameTo);
        Print('Replace: ' + NameFrom + ' -> ' + NameTo, 2);
      end;

  // search 'requires'
  for I := P downto 0 do
    if F[I].IndexOf('requires') <> -1 then
    begin
      p := I;
    end;
  // add libsuffix
  if p <> -1 then
  begin
    for I := p downto 0 do
    begin
      if TRegEx.IsMatch(F[I], LibSuffix, [roIgnoreCase]) then
      begin
        Print('Replace: ' + F[I] + ' -> ' + '{$LIBSUFFIX ''' + Ver + '''}', 2);
        F[I] := '{$LIBSUFFIX ''' + Ver + '''}';
        Exit;
      end;
    end;
    for I := p downto 0 do
    begin
      if TRegEx.IsMatch(F[I], AnyDirrective, [roIgnoreCase]) then
      begin
        F.Insert(I + 1, '{$LIBSUFFIX ''' + Ver + '''}');
        Print('Insert: ' + F[I + 1], 2);
        Exit;
      end;
    end;
  end;

  // hrm... error
  raise EParserError.Create('Bad dpk file!');
end;

procedure ProcessGroupproj(F: TStrings; Files: TStrings; Ver: string; Base, Gen, SuperBase: string);
const
  dproj = '".*\.dproj\s*"';
var
  I: Integer;
  NameFrom, NameTo, s: string;
  IsFound: Boolean;
begin

  for I := 0 to F.Count - 1 do
  begin
    if TRegEx.IsMatch(F[I], '".*"', [roIgnoreCase]) then
    begin
      IsFound := False;
      // include files
      for s in Files do
        if TRegEx.IsMatch(F[I], '"\s*' + TPerlRegEx.EscapeRegExChars(s) + '\s*"', [roIgnoreCase]) then
        begin
          NameTo := ExtractRelativePath(Gen, Base +
            TRegEx.Match(F[I], '"\s*' + TPerlRegEx.EscapeRegExChars(s) + '\s*"', [roIgnoreCase]).Value.DeQuotedString('"'));
          NameFrom := TRegEx.Match(F[I], '"\s*' + TPerlRegEx.EscapeRegExChars(s) + '\s*"', [roIgnoreCase]).Value.DeQuotedString('"');
          F[I] := F[I].Replace(NameFrom, NameTo);
          Print('Replace: ' + NameFrom + ' -> ' + NameTo, 2);
          IsFound := True;
          Break;
        end;
      // deinclude files
      if not IsFound and TRegEx.IsMatch(F[I], dproj, [roIgnoreCase]) then
      begin
        NameTo := ExtractRelativePath(Gen, SuperBase +
          TRegEx.Match(F[I], dproj, [roIgnoreCase]).Value.DeQuotedString('"'));
        NameFrom := TRegEx.Match(F[I], dproj, [roIgnoreCase]).Value.DeQuotedString('"');
        F[I] := F[I].Replace(NameFrom, NameTo);
        Print('Replace: ' + NameFrom + ' -> ' + NameTo, 2);
      end;
    end;
  end;
end;

procedure ProcessDproj(F: TStrings; Ver: string; Base, Gen: string);
  function GenDllSuffix: string;
  begin
    Result := '<DllSuffix>' + Ver + '</DllSuffix>';
  end;

const
  DllSuffix = '< *DllSuffix *>.*< */ *DllSuffix *>';
  PropertyGroup = '< *PropertyGroup +Condition *= *"''\$ *\( *Base *\) *'' *! *= *'' *'' *" *>';
  EndPropertyGroup = '< */ *PropertyGroup *>';
  IncludeFiles = '(Include *= *".*\.(pas|inc) *"|RcItem\s*Include\s*=\s*".*")';
  ReplaceFile = '(".*\.(pas|inc) *"|".*")';

var
  I, J: Integer;
  FromName, ToName: string;
  RxDll, RxFile, RxPG: TRegEx;
  IsBadFile: Boolean;

begin
  RxDll := TRegEx.Create(DllSuffix, [roIgnoreCase]);
  RxFile := TRegEx.Create(IncludeFiles, [roIgnoreCase]);
  RxPG := TRegEx.Create(PropertyGroup, [roIgnoreCase]);

  IsBadFile := True;
  I := 0;
  while I < F.Count do
  begin
    if RxFile.IsMatch(F[I]) then
    begin
      ToName := ExtractRelativePath(Gen, Base +
        TRegEx.Match(F[I], ReplaceFile, [roIgnoreCase]).Value.DeQuotedString('"'));
      FromName := TRegEx.Match(F[I], ReplaceFile, [roIgnoreCase]).Value.DeQuotedString('"');
      F[I] := F[I].Replace(FromName, ToName);
      Print('Replace: ' + FromName + ' -> ' + ToName, 2);
    end else
    if RxDll.IsMatch(F[I]) then
    begin
      Print('Replace: ' + RxDll.Match(F[I]).Value + ' -> ' + GenDllSuffix, 2);
      F[I] := F[I].Replace(RxDll.Match(F[I]).Value, GenDllSuffix);
    end else
    if RxPG.IsMatch(F[I]) then
    begin
      for J := I to F.Count - 1 do
      begin
        if RxDll.IsMatch(F[J]) then
        begin
          Print('Replace: ' + RxDll.Match(F[J]).Value + ' -> ' + GenDllSuffix, 2);
          F[J] := F[J].Replace(RxDll.Match(F[J]).Value, GenDllSuffix);
          IsBadFile := False;
          break;
        end else
        if TRegEx.IsMatch(F[J], EndPropertyGroup, [roIgnoreCase]) then
        begin
          F.Insert(J, '        ' + GenDllSuffix);
          Print('Insert: ' + GenDllSuffix, 2);
          IsBadFile := False;
          break;
        end;
      end;
      I := J;
    end;
    Inc(I);
  end;

  if IsBadFile then
    raise EParserError.Create('Bad dproj file!');
end;

procedure Generate;
var
  BaseDir, GenDir, s, ext, Dir, Suffix, FileName: string;
  Files, F, Temp: TStringList;
  Versions: TDictionary<string, string>;
  I: Integer;
  GroupAbove: Boolean;
begin
  if FindCmdLineSwitch('hide', True) then
    HideOutput := True;

  Print(sVer);
  Print(sTitle);
  Print(sDelimiter);

  Print('Config File: ' + Ini.FileName);

  // Folders
  BaseDir := Ini.ReadString('Folders', 'Base', GetCurrentDir);
  if IsRelativePath(BaseDir) then
    BaseDir := ExpandFileName(GetCurrentDir + '\' + IncludeTrailingPathDelimiter(BaseDir));
  BaseDir := IncludeTrailingPathDelimiter(BaseDir);
  GenDir := Ini.ReadString('Folders', 'Gen', GetCurrentDir);
  if IsRelativePath(GenDir) then
    GenDir := ExpandFileName(GetCurrentDir + '\' + IncludeTrailingPathDelimiter(GenDir));
  GenDir := IncludeTrailingPathDelimiter(GenDir);

  GroupAbove := Ini.ReadString('Folders', 'GroupAbove', 'False').ToLower = 'true';
  Print(sDelimiter);
  Print('Folders:');
  Print(sLiteDelimiter);
  Print('Base: ' + BaseDir);
  Print('Gen: ' + GenDir);
  Print('GroupAbove: ' + GroupAbove.ToString);

  Versions := nil;
  Files := TStringList.Create;
  try
    // Versions
    Print(sDelimiter);
    Print('Versions:');
    Print(sLiteDelimiter);
    Versions := TDictionary<string, string>.Create;
    Temp := TStringList.Create;
    try
      Ini.ReadSection('Versions', Temp);
      for s in Temp do
      begin
        Versions.Add(s, Ini.ReadString('Versions', s, ''));
        Print(s + ' = ' + Versions[s]);
      end;
    finally
      Temp.Free;
    end;

    // Files
    Print(sDelimiter);
    Print('Processing files:');
    Print(sDelimiter);
    Ini.ReadSectionValues('Files', Files);
    for I := 0 to Files.Count - 1 do
    begin
      Print(sDelimiter);
      Print(Files[I] + ':');
      Print(sLiteDelimiter);
      F := TStringList.Create;
      try
        for s in Versions.Keys do
        begin
          Print(s + '(' + Files[I] + '):');
          F.LoadFromFile(BaseDir + Files[I]);

          ext := ExtractFileExt(Files[I]).ToLower;
          // process
          if ext = '.dpk' then
            ProcessDpk(F, Versions[s], BaseDir, GenDir + s + '\')
          else if ext = '.groupproj' then
            if GroupAbove then
              ProcessGroupproj(F, Files, s, GenDir + s + '\', GenDir, BaseDir)
            else
              ProcessGroupproj(F, Files, s, GenDir + s + '\', GenDir + s + '\', BaseDir)
          else if ext = '.dproj' then
            ProcessDproj(F, Versions[s], BaseDir, GenDir + s + '\');

          if (ext <> '.groupproj') or (GroupAbove = False) then
          begin
            Dir := GenDir + s + '\';
            Suffix := '';
          end else
          begin
            Dir := GenDir;
            Suffix := s;
          end;

          FileName := Dir + Files[I].Substring(0, Files[I].Length - ExtractFileExt(Files[I]).Length) + Suffix +
            ExtractFileExt(Files[I]);

          if not DirectoryExists(ExtractFilePath(FileName)) then
            ForceDirectories(ExtractFilePath(FileName));

          F.SaveToFile(FileName);

          Print('Done, Saved as: "' + ExtractRelativePath(GenDir, FileName) + '"', 1);
          Print('---', 1);
        end;
      finally
        F.Free;
      end;
    end;

  finally
    Files.Free;
    Versions.Free;
  end;

  Writeln('All files was processed!');

  if not FindCmdLineSwitch('skip', True) then
  begin
    Writeln('Press any key...');
    Readln;
  end;
end;

initialization
  try
    Ini := TMemIniFile.Create(GetConfigFile);
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Halt;
    end;
  end;

finalization;
  Ini.Free;

end.
