# PackagesGenerator
PackagesGenerator for Delphi - Automatic Generator Package files for multiple versions of Delphi.

## What is it
PackagesGenerator for Delphi

If you are writing a components for Delphi, then you know how difficult it is to maintain multiple versions of Delphi.
Usually you get a lot of almost identical **dpk**, **dproj**, **groupproj** files for different versions of Delphi,  
**For example:**  
```
MyComponents_XE2.groupproj  
MyComponents_XE2.dpk  
MyComponents_XE2.dproj  
MyComponentsDesign_XE2.dpk  
MyComponentsDesign_XE2.dproj  
MyComponents_XE3.groupproj   
MyComponents_XE3.dpk  
MyComponents_XE3.dproj  
MyComponentsDesign_XE3.dpk  
MyComponentsDesign_XE3.dproj  
...  
MyComponentsDesign_RX12Athens.dproj
```
**Tiring create these files manually, also you can make mistakes.**  

ErrorSoft PackagesGenerator can solve this problem!  
The PackagesGenerator itself generates the necessary files, doing the necessary internal changes (LIBSUFFUX, contains ...).

**Сonversion parameters are set in the INI file (Example):**  
```
[Folders]  
Base=Source\  <- the path to the original files  
Gen=Packages\ <- the path to the generated files     
GroupAbove=True 
  
[Versions]  
RX12Athens=290
RX11Alexandria=280
RX10Sydney=270
RX10Rio=260
RX10Tokyo=250
RX10Berlin=240
RX10Seattle=230
XE8=220
XE7=210
XE6=200
XE5=190
XE4=180
XE3=170
XE2=160
  
[Files]  
MyComponents.groupproj  
MyComponentsDesign.dpk  
MyComponents.dpk  
MyComponentsDesign.dproj    
MyComponents.dproj  
```
**This ini and PackagesGenerator generate all necessary files!**

## Command Line parameters

### -config "path to ini file"
* If not specified, will be selected **PackagesGenerator.ini** from the current directory
* This option must be the first

### -hide
* Hide output

### -skip
* Close program after completely done

## Example:
For example see https://github.com/errorcalc/FreeEsVclComponents, "Packages" dir.

## License:

This project has three licenses, you can select one of three license:

1) Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License.  
That means that you can use the product for non commercial purposes.  
(example: Personal use, Study, Open Source,...)  

2) GNU GPL v3: https://www.gnu.org/licenses/gpl.html, only for opensource projects uses GNU GPL license

3) ErrorSoft PackagesGenerator Commercial license.(see LICENSE.TXT)    
$10 for individual developers, $50 for company.   
Email: dr.enter256@gmail.com for contacts.  
