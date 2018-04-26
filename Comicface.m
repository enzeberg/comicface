function varargout = Comicface(varargin)
% COMICFACE MATLAB code for Comicface.fig
%      COMICFACE, by itself, creates a new COMICFACE or raises the existing
%      singleton*.
%
%      H = COMICFACE returns the handle to a new COMICFACE or the handle to
%      the existing singleton*.
%
%      COMICFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMICFACE.M with the given input arguments.
%
%      COMICFACE('Property','Value',...) creates a new COMICFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Comicface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Comicface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Comicface

% Last Modified by GUIDE v2.5 21-Mar-2016 20:24:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Comicface_OpeningFcn, ...
                   'gui_OutputFcn',  @Comicface_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Comicface is made visible.
function Comicface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Comicface (see VARARGIN)

% Choose default command line output for Comicface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Comicface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Comicface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%------暂不考虑弹出对话框提醒用户是否要保存处理后的图片，因为那涉及的代码似乎更加复杂，我对matlab知之甚少-----------
%若四个坐标轴中存在图像，就全部清除，简单干脆
  leftImage=getimage(handles.axes1);
  rightImage=getimage(handles.axes2);
  if ~isempty(leftImage)
      cla(handles.axes1);
      cla(handles.axes4);
  end
  if ~isempty(rightImage)
      cla(handles.axes2,'reset');
      cla(handles.axes3,'reset');
  end
%-------------------------------------------------------------------------
  [filename,pathname]=uigetfile({'*.jpg;*.jpeg;*.png;*.gif;*.tif','All Image Files';'*.*','All Files'},...
      'Pick a picture');
  if isequal(filename,0)%if user cancels to choose a photo
      return;
  else
      fullpath=fullfile(pathname,filename);
  end
  
  im=imread(fullpath);
  red=im(:,:,1);green=im(:,:,2);blue=im(:,:,3);
  m=size(im,1);n=size(im,2);
  %//////////////////////////////////////
  axes(handles.axes1);
  image(im);
  set(handles.axes1,'units','pixels');
  pos1=get(handles.axes1,'pos');
  pos1(3:4)=[n,m];
  set(handles.axes1,'pos',pos1);
  set(gca,'Xtick',[]);set(gca,'Ytick',[]);%让坐标系在显示图像时不显示刻度线，（初始时以设为不显示刻度线）
  %//////////////////////////////////////////////
  
  %start entering the important parts
  [hasFace,scatteredBBStructs,unifiedBBStructs]=faceDetection(im);
  if hasFace==1
      %//////////////////////////////////////////
      axes(handles.axes2);
      image(im);
      set(handles.axes2,'units','pixels');
      pos2=get(handles.axes2,'pos');
      pos2(3:4)=[n,m];
      set(handles.axes2,'pos',pos2);
      set(gca,'Xtick',[]);set(gca,'Ytick',[]);
      hold on;
      %/////////////////////////////////////////////////
      
      for k=1:length(scatteredBBStructs)
          scatteredBBMat=cell2mat(struct2cell(scatteredBBStructs{k}));
          rectangle('Position',scatteredBBMat,'EdgeColor','g');
      end
      %////////////
      axes(handles.axes3);
      image(im);
      set(handles.axes3,'units','pixels');
      pos3=get(handles.axes3,'pos');
      pos3(3:4)=[n m];
      set(handles.axes3,'pos',pos3);
      set(gca,'Xtick',[]);set(gca,'Ytick',[]);
      hold on;
      %///////////
      faces={};%其会保存所有的人脸区域的彩色图像
      for k=1:length(unifiedBBStructs);
          unifiedBBMat=cell2mat(struct2cell(unifiedBBStructs{k}));
          rectangle('Position',unifiedBBMat,'EdgeColor','b');
          hangStart=unifiedBBMat(2)+0.5;
          lieStart=unifiedBBMat(1)+0.5;
          hangStop=hangStart+unifiedBBMat(4);
          lieStop=lieStart+unifiedBBMat(3);
          hangRange=hangStart:hangStop;
          lieRange=lieStart:lieStop;
          faceRed=red(hangRange,lieRange);
          faceGreen=green(hangRange,lieRange);
          faceBlue=blue(hangRange,lieRange);
          face=cat(3,faceRed,faceGreen,faceBlue);
          faces{length(faces)+1}=face;
      end

    
  end
  %---------------------
  %start do image processing
  A=unifyColorFunc(im,1);% A将是处理后得到的最终图像
  A=linearContrastStretch(A);
  %以上两条就是该程序图像处理的主要内容，下面只有当检测出人脸时才会执行
  if hasFace==1%若图像中存在人脸就把人脸对应的区域“还原”，即人脸区域也被unifyColorFunc作用了，现将之前保存的人脸区域“贴回来”
      Ared=A(:,:,1);
      Agreen=A(:,:,2);
      Ablue=A(:,:,3);
      for k=1:length(unifiedBBStructs)
          unifiedBBMat=cell2mat(struct2cell(unifiedBBStructs{k}));
          hangStart=unifiedBBMat(2)+0.5;
          lieStart=unifiedBBMat(1)+0.5;
          hangStop=hangStart+unifiedBBMat(4);
          lieStop=lieStart+unifiedBBMat(3);
          hangRange=hangStart:hangStop;
          lieRange=lieStart:lieStop;
          face=faces{k};
          face=hazyImage(face);
          face=linearContrastStretch(face);
          Ared(hangRange,lieRange)=face(:,:,1);
          Agreen(hangRange,lieRange)=face(:,:,2);
          Ablue(hangRange,lieRange)=face(:,:,3);
      end
      A=cat(3,Ared,Agreen,Ablue);
  end
  %////////////////////////////////////////////////////
  axes(handles.axes4);
  image(A);
  set(handles.axes4,'units','pixels');
  pos4=get(handles.axes4,'pos');
  pos4(3:4)=[n m];
  set(handles.axes4,'pos',pos4);
  set(gca,'Xtick',[]);set(gca,'Ytick',[]);
  %//////////////////////////////////////////////////////
  


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result=getimage(handles.axes4);
if ~isempty(result)%如果第四个坐标轴中有图像
    [filename,pathname]=uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
        '*.*','All Files' },'Save the processed image');
    if ~isequal(filename,0)%如果用户选择了路径并设定了文件名称
        str=strcat(pathname,filename);
        pix=getframe(handles.axes4);
        imwrite(pix.cdata,str,'jpg');
    end
end

    

