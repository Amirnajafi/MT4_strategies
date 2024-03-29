//+------------------------------------------------------------------------------------------------------------------+
//+ [Knowledge of the ancients]                           \!/                                  [!!!-MT4 X-XARDFX-38] +
//+                                                      (ò ó)                                     [Update-20190305] +
//+-------------------------------------------------o0o---(_)---o0o--------------------------------------------------+
#property copyright "Welcome to the World of Forex"
#property description "Let light shine out of darkness and illuminate your world"
#property description "and with this freedom leave behind your cave of denial"
#property indicator_chart_window
#property indicator_buffers 32
#define Version "XARDFX-38"
string ID="Xard>",tFx,TFx="Current time frame",TimeFrame="Current time frame";
//+------------------------------------------------------------------------------------------------------------------+
#include <WinUser32.mqh>
extern int TrendLinePeriod = 7;
extern string Indicator = Version;
extern string STR00                      = "<<<==== [00] Chart Settings ====>>>";
enum menuupdatemode     {UpdatePerSecond,UpdatePerMilliseconds};
extern menuupdatemode UpdateMode         = UpdatePerSecond;
   extern int UpdateEveryXseconds        = 1, UpdateEveryXmilliseconds = 1;
  extern bool AutoRefresh                = false;
  extern ENUM_TIMEFRAMES RefreshPeriod   = PERIOD_M15; int hWindow=0,oldBars=0;
  extern bool AutoArrangeChart           = true,cleanChart = false;
 extern color chartBackgroundColor       = C'162,162,162', chartForegroundColor = clrBlack,
              chartGridColor             = clrDimGray,
              chartBarUpColor            = clrBlue,   chartBarDownColor = clrRed,
              chartBullCandleColor       = clrBlue,chartBearCandleColor = clrRed,
              chartLineGraphColor        = clrNONE,     charttradeEntryColor = clrLimeGreen,
              chartAskLineColor          = clrOrangeRed,charttradeLevelColor = clrOrangeRed;
//+------------------------------------------------------------------------------------------------------------------+
       string STR01                      = "<<<==== [01] TMA1 Settings ====>>>";
         bool showTMA1                   = true;
          int TMA1per                    = 28,TMA1atr=100;
       double TMA1atrMulti               = 2.618;
       double TMA1[],TMA1up[],TMA1dn[],TMA1bandUp[],TMA1bandDn[];
//+------------------------------------------------------------------------------------------------------------------+
       string STR02                      = "<<<==== [02] TMA2 Settings ====>>>";  
         bool showTMA2                   = true, Extrapolate=true;
          int TMA2per                    = 28,TMA2atr=100;
       ENUM_APPLIED_PRICE TMA2price      = PRICE_WEIGHTED;
       double TMA2atrMulti               = 2.618;
       double TMA2[],TMA2up[],TMA2dn[],TMA2bandUp[],TMA2bandDn[];   double slope[],trend1[],trend2[];
//+------------------------------------------------------------------------------------------------------------------+
       string STR03                      = "<<<==== [03] Ribbon Settings ====>>>";
         bool showRIBBON                 = true; 
          int barWidth                   = 4;  double MA1[],MA2[],MA3[],MA4[];
        color RibColUP                   = C'30,144,255',RibColDN=C'255,85,160',LineCol=C'120,140,120';
//+------------------------------------------------------------------------------------------------------------------+
       string STR04                      = "<<<==== [04] Semafor Settings ====>>>";
         bool showSemafor                = true;
          int Period2                    = 34, Period3 = 84;
       string DevStep2="0,5",DevStep3="0,5"; color cU,cD;
          int S2size=4,S3size=5,S2kod=108,S3kod=162; int HPeriod,ZPeriod,Dev2,Dev3,Stp2,Stp3;
       double HPup[],HPdn[],ZPup[],ZPdn[],ZZdelta,ZZPoint,deltaPips=0.05;
//+------------------------------------------------------------------------------------------------------------------+
       string STR05                      = "<<<==== [05] Open Line Settings ====>>>";
         bool showOpenline               = true;
       double TimeShiftMins=0,BufPOL,POLb[],POL0[],POL1[],VAL; int tFrame=0; datetime StartTime;
//+------------------------------------------------------------------------------------------------------------------+
       string STR06                      = "<<<==== [06] HA Settings ====>>>";
         bool showHA                     = false;
        color cBullish                   = clrBlue,cBearish=clrRed;
       double haOpen[],haClose[],haHighLow[],haLowHigh[]; int getChartScale=WRONG_VALUE;
//+------------------------------------------------------------------------------------------------------------------+
       string STR07                      = "<<<==== [07] Trend Line Settings ====>>>";
         bool showTREND                  = true; 
        color TRENDbgdclr                = C'100,100,100',
              TRENDupclr                 = clrDeepSkyBlue,
              TRENDdnclr                 = clrViolet;
          int TRENDper                   = TrendLinePeriod,
              TRENDtf                    = 0,
              TRENDshft                  = 0,
              TRENDmode                  = MODE_SMMA,
              TRENDtype                  = PRICE_CLOSE;
         bool returnBars,calculateTREND; double TREND[],TRENDbgd[],TRENDdna[],TRENDdnb[],trend[],ccitrend[];
//+------------------------------------------------------------------------------------------------------------------+
       string STR08                      = "<<<==== [08] InfoBOX Settings ====>>>";
         bool showINFOBOX                = true,showSpotLight=true;
        color PanelBackColor             = C'40,40,40',PanelForeColor=C'20,20,20',PanelBorderColor=C'120,120,120';
          int PanelBorderWidth           = 1,InfoBoxCorner=1,Window=0; int posLR=6,posUD=-20,tsize=19;
        color Boxbgd                     = C'30,40,50',Panelcol=clrSnow;
       double DecNos,CLOSE,myPoint,mPoint,OpenToday,CloseToday,ADR1,ADR5,ADR10,ADR20,ADRavg;
       double SetPoint(){if(Digits<4) mPoint=0.01; else mPoint=0.0001; return(mPoint);}
        color textcolUP=clrSnow,textcolDN=clrSnow,textcolWT=clrSnow,Panetpgd2=C'40,50,60';
#define RedLight -1
#define OverBoughtLight 0
#define OverSoldLight 1
#define GreenLight 2
#define OrangeLight 3
#define PowerFailure -999
//+------------------------------------------------------------------------------------------------------------------+
       string STR09                      = "<<<==== [09] Symbol Header Settings ====>>>";
         bool showSymbolHeader           = true;  int LR=310,UD=-10,HDRsize=50;
//+------------------------------------------------------------------------------------------------------------------+
       string STR10                      = "<<<==== [10] Xmath Settings ====>>>";
         bool showXmath                  = true;
  double dmml=0,dvtl=0,sumx=0,v1x=0,v2x=0,mn=0,mx=0,x1=0,x2=0,x3=0,x4=0,x5=0,x6=0,y1=0,y2=0,y3=0,y4=0,y5=0,y6=0,
   tx=0,octave=0,fractal=0,rangex=0,finalH=0,finalL=0,mmlx[13];  string ln_txt[13],ln_tx[13],buff_str="";
   int Px=64,StepBackx=0,bn_v1x=0,bn_v2x=0,OctLinesCnt=13,mml_thk=8,mml_clr[13],mml_shft=3,nTime=0,CurPeriod=0,
   nDigits=0,frametemp=0,f=0,gb=0,gbT=0,mP=0,lperiod=0,d=0,ts=0,mml_wdth[13];
//+------------------------------------------------------------------------------------------------------------------+
       string STR11                      = "<<<==== [11] Bid Ratio Settings ====>>>";
         bool showD1                     = true;
          int BuyRatio                   = 90, SellRatio = 10;
          int fontsize1=16;  double D1pct; color clrD1pct,clrPAIR=clrGray; int X=0,Y=0;
//+------------------------------------------------------------------------------------------------------------------+
extern string STR12                      = "<<<==== [12] Alerts Settings ====>>>";
  extern bool alertsOn                   = true;
  extern bool alertsOnStopLight          = true;
  extern bool alertsOnCurrent            = true;
  extern bool alertsMessage              = true;
  extern bool alertsSound                = false;
  extern bool alertsNotify               = true;
  extern bool alertsEmail                = false;
       string soundFile                  = "alert2.wav";
//+------------------------------------------------------------------------------------------------------------------+
   bool calculateValue;  string FontType="Arial Black",SymPair="",indicatorFileName;
   double data1;  int timeFrame,BarsCount=1000,Type,Type2,win,FontSize=14,FontSize2=12,pipsize;
//+----OnInit Function-----------------------------------------------------------------------------------------------+
   int OnInit(){if(UpdateMode == UpdatePerSecond) EventSetTimer(UpdateEveryXseconds); else
   if(UpdateMode == UpdatePerMilliseconds) EventSetMillisecondTimer(UpdateEveryXmilliseconds);
//+------------------------------------------------------------------------------------------------------------------+
   if(AutoArrangeChart){ChartSetInteger(0,CHART_COLOR_BACKGROUND,chartBackgroundColor);
                        ChartSetInteger(0,CHART_COLOR_FOREGROUND,chartForegroundColor);
                        ChartSetInteger(0,CHART_COLOR_GRID,chartGridColor);
                        ChartSetInteger(0,CHART_COLOR_CHART_UP,chartBarUpColor);
                        ChartSetInteger(0,CHART_COLOR_CHART_DOWN,chartBarDownColor);
                        ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,chartBullCandleColor);
                        ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,chartBearCandleColor);
                        ChartSetInteger(0,CHART_COLOR_CHART_LINE,chartLineGraphColor);
                        ChartSetInteger(0,CHART_COLOR_VOLUME,charttradeEntryColor);
                        ChartSetInteger(0,CHART_COLOR_ASK,chartAskLineColor);
                        ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,charttradeLevelColor);
                        ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
                        ChartSetInteger(0,CHART_SHIFT,true);
                        ChartSetInteger(0,CHART_SHOW_OHLC,false);
                        ChartSetInteger(0,CHART_SHOW_GRID,false);}
//+------------------------------------------------------------------------------------------------------------------+   
   int Buffers=32,Buf=-1;  IndicatorBuffers(Buffers);  TMA2per=MathMax(TMA2per,1);
   if(TimeFrame==0 || TimeFrame<Period()) TimeFrame=Period();  timeFrame=stringToTimeFrame(TimeFrame);
   IndicatorDigits(Digits); IndicatorShortName(ID); win=WindowFind(ID);
//+------------------------------------------------------------------------------------------------------------------+
   if(AutoRefresh)  hWindow=WindowHandle(Symbol(),Period());  oldBars=iBars(NULL,RefreshPeriod);
//+------------------------------------------------------------------------------------------------------------------+
   if(showRIBBON)         Type=DRAW_HISTOGRAM; else Type=DRAW_NONE;
   Buf+=1; SetIndexBuffer(Buf,MA1);       
   Buf+=1; SetIndexBuffer(Buf,MA2);       
   Buf+=1; SetIndexBuffer(Buf,MA3);       
   Buf+=1; SetIndexBuffer(Buf,MA4);       fSetBuffers();
   if(showTMA1)           Type=DRAW_LINE; else Type=DRAW_NONE;
   Buf+=1; SetIndexBuffer(Buf,TMA1);       SetIndexStyle(Buf,DRAW_NONE);        SetIndexDrawBegin(Buf,TMA1per);
   Buf+=1; SetIndexBuffer(Buf,TMA1bandUp); SetIndexStyle(Buf,Type,0,1,clrRed);  SetIndexDrawBegin(Buf,TMA1per);
   Buf+=1; SetIndexBuffer(Buf,TMA1bandDn); SetIndexStyle(Buf,Type,0,1,clrRed);  SetIndexDrawBegin(Buf,TMA1per);
   if(showTMA2)           Type=DRAW_LINE; else Type=DRAW_NONE;
   Buf+=1; SetIndexBuffer(Buf,TMA2);       SetIndexStyle(Buf,DRAW_NONE);        SetIndexDrawBegin(Buf,TMA2per);
   Buf+=1; SetIndexBuffer(Buf,TMA2up);     SetIndexStyle(Buf,DRAW_NONE);        SetIndexDrawBegin(Buf,TMA2per);
   Buf+=1; SetIndexBuffer(Buf,TMA2dn);     SetIndexStyle(Buf,DRAW_NONE);        SetIndexDrawBegin(Buf,TMA2per);
   Buf+=1; SetIndexBuffer(Buf,TMA2bandUp); SetIndexStyle(Buf,Type,0,2,clrSnow); SetIndexDrawBegin(Buf,TMA2per);
   Buf+=1; SetIndexBuffer(Buf,TMA2bandDn); SetIndexStyle(Buf,Type,0,2,clrSnow); SetIndexDrawBegin(Buf,TMA2per);
   Buf+=1; SetIndexBuffer(Buf,slope);      SetIndexStyle(Buf,DRAW_NONE);
   Buf+=1; SetIndexBuffer(Buf,trend1);     SetIndexStyle(Buf,DRAW_NONE);
   Buf+=1; SetIndexBuffer(Buf,trend2);     SetIndexStyle(Buf,DRAW_NONE);
//+------------------------------------------------------------------------------------------------------------------+
   if(showSemafor)        ZZPoint=getPoint(true);  ZZdelta=deltaPips*ZZPoint;  int CDev=0,CSt=0,Mass[],C=0;
   if(Period2>0) HPeriod=MathCeil(Period2*Period()); else HPeriod=0; 
   if(Period3>0) ZPeriod=MathCeil(Period3*Period()); else ZPeriod=0;
//+------------------------------------------------------------------------------------------------------------------+
   if(Period2>0){cU=clrSnow; cD=clrSnow; Type=DRAW_ARROW;
   Buf+=1; SetIndexBuffer(Buf,HPup);      SetIndexStyle(Buf,Type,0,S2size,cU); 
           SetIndexArrow(Buf,S2kod);      SetIndexEmptyValue(Buf,0.0);  
   Buf+=1; SetIndexBuffer(Buf,HPdn);      SetIndexStyle(Buf,Type,0,S2size,cD);
           SetIndexArrow(Buf,S2kod);      SetIndexEmptyValue(Buf,0.0);}
//+------------------------------------------------------------------------------------------------------------------+
   if(showSemafor)
   if(Period3>0){cU=clrBlue; cD=clrRed; Type=DRAW_ARROW;
   Buf+=1; SetIndexBuffer(Buf,ZPup);      SetIndexStyle(Buf,Type,0,S3size,cU);
            SetIndexArrow(Buf,S3kod);     SetIndexEmptyValue(Buf,0.0);
   Buf+=1; SetIndexBuffer(Buf,ZPdn);      SetIndexStyle(Buf,Type,0,S3size,cD);
            SetIndexArrow(Buf,S3kod);     SetIndexEmptyValue(Buf,0.0);}
//+------------------------------------------------------------------------------------------------------------------+
   if(IntFromStr(DevStep2,C,Mass)==1){Stp2=Mass[1]; Dev2=Mass[0];}
   if(IntFromStr(DevStep3,C,Mass)==1){Stp3=Mass[1]; Dev3=Mass[0];}
//+------------------------------------------------------------------------------------------------------------------+
   if(showOpenline)       Type=DRAW_LINE; else Type=DRAW_NONE; if(Period()>=PERIOD_W1) Type=DRAW_NONE;
   Buf+=1; SetIndexBuffer(Buf,POLb);      SetIndexStyle(Buf,Type,0,3+2,clrBlack);
   Buf+=1; SetIndexBuffer(Buf,POL0);      SetIndexStyle(Buf,Type,0,3,clrYellow);
   Buf+=1; SetIndexBuffer(Buf,POL1);      SetIndexStyle(Buf,Type,0,3,clrAqua);
//+------------------------------------------------------------------------------------------------------------------+
   if(showHA)             Type=DRAW_HISTOGRAM; else Type=DRAW_NONE;
   Buf+=1; SetIndexBuffer(Buf,haLowHigh); SetIndexEmptyValue(Buf,0); SetIndexStyle(Buf,Type,0,1,cBearish);
	Buf+=1; SetIndexBuffer(Buf,haHighLow); SetIndexEmptyValue(Buf,0); SetIndexStyle(Buf,Type,0,1,cBullish);
	Buf+=1; SetIndexBuffer(Buf,haOpen);    SetIndexEmptyValue(Buf,0);
	Buf+=1; SetIndexBuffer(Buf,haClose);   SetIndexEmptyValue(Buf,0); fSetBuffers();
//+------------------------------------------------------------------------------------------------------------------+
   if(showTREND)          Type=DRAW_LINE; else Type=DRAW_NONE;
   Buf+=1; SetIndexBuffer(Buf,TRENDbgd);  SetIndexDrawBegin(Buf,TRENDper+1);
   Buf+=1; SetIndexBuffer(Buf,TREND);     SetIndexDrawBegin(Buf,TRENDper+1);
   Buf+=1; SetIndexBuffer(Buf,TRENDdna);  SetIndexDrawBegin(Buf,TRENDper+1);
   Buf+=1; SetIndexBuffer(Buf,TRENDdnb);  SetIndexDrawBegin(Buf,TRENDper+1);
   Buf+=1; SetIndexBuffer(Buf,trend);     SetIndexStyle(Buf,DRAW_NONE); fSetBuffers();
//+------------------------------------------------------------------------------------------------------------------+
   Buf+=1; SetIndexBuffer(Buf,ccitrend);  SetIndexStyle(Buf,DRAW_NONE);
   if(Buffers != Buf+1) Print("*******Buffer MisMatch!!!   ",Buffers," ",Buf);
   for(int Bufx=0;Bufx<indicator_buffers;Bufx++){SetIndexLabel(Bufx,NULL);}
//+------------------------------------------------------------------------------------------------------------------+
   if(SymPair=="") SymPair=Symbol(); myPoint=SetPoint();
        if(StringFind  (Symbol(),"JPY",0) != -1)   DecNos=2;
   else if(StringSubstr(Symbol(),0,5)=="UKOil")    DecNos=2;
   else if(StringSubstr(Symbol(),0,6)=="BTCUSD")   DecNos=1;
   else if(StringSubstr(Symbol(),0,7)=="CHINA50")  DecNos=0;
   else if(StringSubstr(Symbol(),0,6)=="US2000")   DecNos=1;
   else if(StringSubstr(Symbol(),0,5)=="US500")    DecNos=1;
   else if(StringSubstr(Symbol(),0,6)=="ETHUSD")   DecNos=2;
   else if(StringSubstr(Symbol(),0,6)=="LTCUSD")   DecNos=3;
   else if(StringSubstr(Symbol(),0,6)=="USOUSD")   DecNos=3;
   else if(StringSubstr(Symbol(),0,6)=="SPX500")   DecNos=1;
   else if(StringSubstr(Symbol(),0,8)=="USDOLLAR") DecNos=3;
   else if(StringSubstr(Symbol(),0,5)=="JP225")    DecNos=0;
   else if(StringSubstr(Symbol(),0,4)=="HK50")     DecNos=0;
   else if(StringSubstr(Symbol(),0,5)=="UK100")    DecNos=0;
   else if(StringSubstr(Symbol(),0,7)=="FTSE100")  DecNos=1;
   else if(StringSubstr(Symbol(),0,6)=="XAUUSD")   DecNos=1;
   else if(StringSubstr(Symbol(),0,6)=="XAGUSD")   DecNos=3;
   else if(StringSubstr(Symbol(),0,6)=="USDMXN")   DecNos=3;
   else if(StringSubstr(Symbol(),0,6)=="NDX100")   DecNos=1;
   else if(StringSubstr(Symbol(),0,4)=="WS30")     DecNos=0; else DecNos=4;
   if(SymPair=="") SymPair=Symbol();
        if(StringFind  (Symbol(),"JPY",0) != -1)   pipsize=10;
   else if(StringSubstr(Symbol(),0,8)=="USDOLLAR") pipsize=10;
   else if(StringSubstr(Symbol(),0,6)=="BTCUSD")   pipsize=100;
   else if(StringSubstr(Symbol(),0,7)=="CHINA50")  pipsize=100;
   else if(StringSubstr(Symbol(),0,6)=="LTCUSD")   pipsize=1;
   else if(StringSubstr(Symbol(),0,6)=="ASX200")   pipsize=100;
   else if(StringSubstr(Symbol(),0,4)=="HK50")     pipsize=100;
   else if(StringSubstr(Symbol(),0,5)=="JP225")    pipsize=100;
   else if(StringSubstr(Symbol(),0,6)=="USDTRY")   pipsize=100;
   else if(StringSubstr(Symbol(),0,5)=="UK100")    pipsize=100;
   else if(StringSubstr(Symbol(),0,7)=="FTSE100")  pipsize=100;
   else if(StringSubstr(Symbol(),0,6)=="USDMXN")   pipsize=100;
   else if(StringSubstr(Symbol(),0,6)=="XAUUSD")   pipsize=10;
   else if(StringSubstr(Symbol(),0,6)=="XAGUSD")   pipsize=1;
   else if(StringSubstr(Symbol(),0,4)=="WS30")     pipsize=100;
   else if(StringSubstr(Symbol(),0,6)=="NDX100")   pipsize=100; else pipsize=10;
//+----Xmath---------------------------------------------------------------------------------------------------------+
   switch(Period()){
   case    1: Px=15360;  tx=10; break;   case    5: Px=3072; tx=20; break;
   case   15: Px=1024;   tx=20; break;   case   30: Px=512;  tx=20; break;
   case   60: Px=256;    tx=50; break;   case  240: Px=64;   tx=50; break;
   case 1440:            tx=50; break;   case 10080:         tx=50; break;  default:  tx=50; break;}
   ln_txt[0] ="                               [-2/8] "; mml_wdth[0] =0; ln_tx[0] =""; mml_clr[0]=clrSnow;
   ln_txt[1] ="                               [-1/8] "; mml_wdth[1] =0; ln_tx[1] =""; mml_clr[1]=clrSnow;
   ln_txt[2] ="                               [0/8] ";  mml_wdth[2] =0; ln_tx[2] =""; mml_clr[2]=clrSnow;
   ln_txt[3] ="                               [1/8] ";  mml_wdth[3] =0; ln_tx[3] =""; mml_clr[3]=clrSnow;
   ln_txt[4] ="                               [2/8] ";  mml_wdth[4] =0; ln_tx[4] =""; mml_clr[4]=clrSnow;
   ln_txt[5] ="                               [3/8] ";  mml_wdth[5] =0; ln_tx[5] =""; mml_clr[5]=clrSnow;
   ln_txt[6] ="                               [4/8] ";  mml_wdth[6] =0; ln_tx[6] =""; mml_clr[6]=clrSnow;
   ln_txt[7] ="                               [5/8] ";  mml_wdth[7] =0; ln_tx[7] =""; mml_clr[7]=clrSnow;
   ln_txt[8] ="                               [6/8] ";  mml_wdth[8] =0; ln_tx[8] =""; mml_clr[8]=clrSnow;
   ln_txt[9] ="                               [7/8] ";  mml_wdth[9] =0; ln_tx[9] =""; mml_clr[9]=clrSnow;
   ln_txt[10]="                               [8/8] ";  mml_wdth[10]=0; ln_tx[10]=""; mml_clr[10]=clrSnow; mml_shft=0;
   ln_txt[11]="                               [+1/8] "; mml_wdth[11]=0; ln_tx[11]=""; mml_clr[11]=clrSnow;  mml_thk=3;
   ln_txt[12]="                               [+2/8] "; mml_wdth[12]=0; ln_tx[12]=""; mml_clr[12]=clrSnow;
   indicatorFileName = WindowExpertName();
   calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
   returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
   timeFrame         = stringToTimeFrame(TimeFrame);  return(INIT_SUCCEEDED);}//End OnInit
//+----deinit Function-----------------------------------------------------------------------------------------------+
   void deinit(){ int reason; switch(reason){
      case REASON_CHARTCHANGE :
      case REASON_RECOMPILE   :
      case REASON_CLOSE       : break;
                      default : {
   for(int i=0;i<OctLinesCnt;i++){buff_str="mmlx"+i;
   ObjectDelete(buff_str); buff_str = "mml_txtx"+i; ObjectDelete(buff_str);}            
      CleanUpAisle1(ID); string lookFor = ID+":"; int lookForLength = StringLen(lookFor);
   for(int io=ObjectsTotal()-1; io>=0; io--){string objectName=ObjectName(io); 
   if(StringSubstr(objectName,0,lookForLength)==lookFor) ObjectDelete(objectName);}}}}
//+------------------------------------------------------------------------------------------------------------------+
   class CFix { } ExtFix;
//+----OnCalculate Function------------------------------------------------------------------------------------------+
   int OnCalculate(const int rates_total,
                   const int prev_calculated,
                   const datetime &time[],
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[],
                   const long &tick_volume[],
                   const long &volume[],
                   const int &spread[]){fSetBuffers();
//+------------------------------------------------------------------------------------------------------------------+
   if(AutoRefresh){if(oldBars<iBars(NULL,RefreshPeriod) && hWindow!=0){int message;
   switch(Period()){case     1: message= 33137; break;
                    case     5: message= 33138; break;
                    case    15: message= 33139; break;
                    case    30: message= 33140; break;
                    case    60: message= 33135; break;
                    case   240: message= 33136; break;
                    case  1440: message= 33134; break;
                    case 10080: message= 33141; break;
                       default: message= 33137; break;}
   PostMessageA (hWindow,WM_COMMAND,33141,0);   // switch to weekly TF
   PostMessageA (hWindow,WM_COMMAND,message,0); // switch to original TF
   oldBars=iBars(NULL,RefreshPeriod);}}//End AutoRefresh
   int counted_bars=IndicatorCounted();
   int i,j,k,limit; double ld_Range;
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--; limit=MathMin(Bars-counted_bars+TMA2per,Bars-1);
   if(returnBars){TMA2[0] = limit+1; return(0);}
//+---TMA1 Function--------------------------------------------------------------------------------------------------+
   for (i=limit; i>=0; i--){
          TMA1[i] = EMPTY_VALUE;
        TMA1up[i] = EMPTY_VALUE;
        TMA1dn[i] = EMPTY_VALUE;
          TMA1[i] = iMA(NULL,0,TMA1per,0,MODE_LWMA,PRICE_CLOSE,i);
         ld_Range = iATR(NULL,0,TMA1atr,i+10);
    TMA1bandUp[i] = TMA1[i+1] + (ld_Range * TMA1atrMulti);
    TMA1bandDn[i] = TMA1[i+1] - (ld_Range * TMA1atrMulti);}
//+---TMA2 Function--------------------------------------------------------------------------------------------------+
   if(calculateValue || timeFrame==Period()){
   if(slope[limit]==-1) CleanPoint(limit,TMA2up,TMA2dn);
   for(i=limit;i>=0;i--){
   if(Extrapolate || (!Extrapolate && i>TMA2per)){
            double sum  = (TMA2per+1)*iMA(NULL,0,1,0,MODE_SMA,TMA2price,i);
            double sumw = (TMA2per+1);
   for(j=1, k=TMA2per; j<=TMA2per; j++, k--){
             sum  += k*iMA(NULL,0,1,0,MODE_SMA,TMA2price,i+j);
             sumw += k;
   if(j<=i){ sum  += k*iMA(NULL,0,1,0,MODE_SMA,TMA2price,i-j);
             sumw += k;}}
   double range = iATR(NULL,0,TMA2atr,i+10)*TMA2atrMulti;
            TMA2[i] = sum/sumw;  
      TMA2bandUp[i] = TMA2[i]+range;
      TMA2bandDn[i] = TMA2[i]-range;} else {
            TMA2[i] = TMA2[i+1];  
      TMA2bandUp[i] = TMA2bandUp[i+1];  
      TMA2bandDn[i] = TMA2bandDn[i+1];}         
          TMA2up[i] = EMPTY_VALUE;
          TMA2dn[i] = EMPTY_VALUE;
           slope[i] = slope[i+1];
          trend1[i] = 0;
          trend2[i] = trend2[i+1];
   if(TMA2[i]> TMA2[i+1]) slope[i] = 1;
   if(TMA2[i]< TMA2[i+1]) slope[i] =-1;
   //if(High[i]   > TMA2bandUp[i])    trend1[i] = 1;
   //if(Low[i]    < TMA2bandDn[i])    trend1[i] =-1;
   if(Close[i]  > TMA2bandUp[i])    trend2[i] = 1;
   if(Close[i]  < TMA2bandDn[i])    trend2[i] =-1;
   if(slope[i]==-1) PlotPoint(i,TMA2up,TMA2dn,TMA2);}
//+---Ribbon Function------------------------------------------------------------------------------------------------+
   for(i=0; i<limit; i++){
   if(TMA1bandUp[i]>TMA2bandUp[i]){MA2[i]=TMA1bandUp[i];MA1[i]=TMA2bandUp[i];MA4[i]=EMPTY_VALUE;MA3[i]=EMPTY_VALUE;}
   if(TMA1bandDn[i]<TMA2bandDn[i]){MA4[i]=TMA1bandDn[i];MA3[i]=TMA2bandDn[i];MA2[i]=EMPTY_VALUE;MA1[i]=EMPTY_VALUE;}}
//+---Semafor Function-----------------------------------------------------------------------------------------------+
   if(Period2>0) CountZZ(HPup,HPdn,Period2,Dev2,Stp2);
   if(Period3>0) CountZZ(ZPup,ZPdn,Period3,Dev3,Stp3);
//+---Open Line Function---------------------------------------------------------------------------------------------+
   double XardPer; if(Period()<=PERIOD_H1){XardPer=PERIOD_D1;}   if(Period()>=PERIOD_H4){XardPer=PERIOD_W1;}
   if(Bars<=3) return(0); int ExtCountedBars=IndicatorCounted(); if(ExtCountedBars<0) return(-1); limit=Bars-2; 
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1; int pos2,index; pos2=limit; while(pos2>=0){
   if(tFrame<10){index=iBarShift(NULL,XardPer,Time[pos2],false);} 
    else {index=iBarShift(NULL,XardPer,BofYr(Time[pos2]),false);}
   BufPOL=iMA(Symbol(),0,2,0,MODE_SMMA,PRICE_CLOSE,pos2); VAL=iOpen(NULL,XardPer,index);
   POL0[pos2]=VAL; POL1[pos2]=VAL; POLb[pos2]=POL0[pos2]; if((VAL>BufPOL)){POL1[pos2]=EMPTY_VALUE;}pos2--;}
//+---Xmath Function-------------------------------------------------------------------------------------------------+
   bn_v1x =  Lowest(NULL,0, MODE_LOW,Px+StepBackx,0);
   bn_v2x = Highest(NULL,0,MODE_HIGH,Px+StepBackx,0);  v1x = Low[bn_v1x];  v2x = High[bn_v2x];
//+------------------------------------------------------------------------------------------------------------------+
   if(v2x<=250000   && v2x>25000)    fractal=100000;  if(v2x<=25000    && v2x>2500)     fractal=10000;
   if(v2x<=2500     && v2x>250)      fractal=1000;    if(v2x<=250      && v2x>25)       fractal=100;
   if(v2x<=25       && v2x>12.5)     fractal=12.5;    if(v2x<=12.5     && v2x>6.25)     fractal=12.5;
   if(v2x<=6.25     && v2x>3.125)    fractal=6.25;    if(v2x<=3.125    && v2x>1.5625)   fractal=3.125;
   if(v2x<=1.5625   && v2x>0.390625) fractal=1.5625;  if(v2x<=0.390625 && v2x>0)        fractal=0.1953125;
//+------------------------------------------------------------------------------------------------------------------+
   rangex=(v2x-v1x); sumx=MathFloor(MathLog(fractal/rangex)/MathLog(2)); octave=fractal*(MathPow(0.5,sumx)); 
   mn=MathFloor(v1x/octave)*octave; if((mn+octave+(octave*0.3333))>v2x) mx=mn+octave; else mx=mn+(2*octave);
//+------------------------------------------------------------------------------------------------------------------+
   if((v1x>=(3*(mx-mn)/16+mn)) && (v2x<=(9*(mx-mn)/16+mn))) x2=mn+(mx-mn)/2; else x2=0;
   if((v1x>=(mn-(mx-mn)/8)) && (v2x<=(5*(mx-mn)/8+mn)) && (x2 == 0)) x1=mn+(mx-mn)/2; else x1=0;
   if((v1x>=(mn+7*(mx-mn)/16)) && (v2x<=(13*(mx-mn)/16+mn))) x4=mn+3*(mx-mn)/4; else x4=0;
   if((v1x>=(mn+3*(mx-mn)/8)) && (v2x<=(9*(mx-mn)/8+mn)) && (x4==0)) x5=mx; else x5=0;
   if((v1x>=(mn+(mx-mn)/8)) && (v2x<=(7*(mx-mn)/8+mn)) && (x1==0) && (x2==0) && (x4==0) && (x5==0)) 
      x3 = mn+3*(mx-mn)/4; else x3=0;  if((x1+x2+x3+x4+x5)==0) x6=mx; else x6=0;   finalH=x1+x2+x3+x4+x5+x6;
   if(x1>0) y1=mn; else y1=0;  if(x2>0) y2=mn+(mx-mn)/4; else y2=0;  if(x3>0) y3=mn+(mx-mn)/4; else y3=0;
   if(x4>0) y4=mn+(mx-mn)/2; else y4=0;   if(x5>0) y5=mn+(mx-mn)/2; else y5=0;
   if((finalH>0) && ((y1+y2+y3+y4+y5)==0)) y6=mn; else y6=0;   finalL = y1+y2+y3+y4+y5+y6;  
//+------------------------------------------------------------------------------------------------------------------+
   double xo = (finalH-finalL),xmm = xo/8;
   for(f=0; f<OctLinesCnt; f++){mmlx[f] = 0;}  dmml=(finalH-finalL)/8;  mmlx[0]=(finalL-dmml*2);
   for(f=1; f<OctLinesCnt; f++){mmlx[f] = mmlx[f-1] + dmml;}
   for(f=0; f<OctLinesCnt; f++){buff_str = "mmlx"+f; buff_str = "mml_txtx"+f; ObjectDelete(buff_str);
   if(showXmath){ 
    ObjectCreate(buff_str,OBJ_TEXT, 0, Time[mml_shft], mml_shft);
   ObjectSetText(buff_str,ln_txt[f]+DoubleToStr(mmlx[f],DecNos)+ln_tx[f],12,"MV Boli",mml_clr[f]);
       ObjectSet(buff_str,OBJPROP_BACK,1);  ObjectMove(buff_str,0,Time[mml_shft+0],mmlx[f]+Point*tx);}}//End Xmath
//+------------------------------------------------------------------------------------------------------------------+
   int countedbars=prev_calculated; if(countedbars<0) return(-1); if(countedbars>0) countedbars--;
   limit=MathMin(rates_total-countedbars,rates_total-1);
//+----HA Function---------------------------------------------------------------------------------------------------+
   int i_Bar = fmax(1, rates_total - prev_calculated + (prev_calculated > 0));
	if(prev_calculated == 0){i_Bar--;
		  if(Open[i_Bar] < Close[i_Bar]) {
		haLowHigh[i_Bar] =   Low[i_Bar];
		haHighLow[i_Bar] =  High[i_Bar];} else {
		haLowHigh[i_Bar] =  High[i_Bar];
		haHighLow[i_Bar] =   Low[i_Bar];}
		   haOpen[i_Bar] =  Open[i_Bar];
		  haClose[i_Bar] = Close[i_Bar];}
//+----
	double d_Open,d_Close,d_High,d_Low;
	i_Bar = fmin(rates_total - 2,i_Bar);
	while(i_Bar-- >0) {
	 d_Open = (haOpen[i_Bar + 1] + haClose[i_Bar + 1]) / 2;
	d_Close = (Open[i_Bar] + High[i_Bar] + Low[i_Bar] + Close[i_Bar]) / 4;
	 d_High = fmax(High[i_Bar], fmax(d_Open, d_Close));
	  d_Low = fmin(Low[i_Bar], fmin(d_Open, d_Close));
//+----
	if(d_Open < d_Close){
		haLowHigh[i_Bar] = d_Low;
		haHighLow[i_Bar] = d_High;} else {
		haLowHigh[i_Bar] = d_High;
		haHighLow[i_Bar] = d_Low;}
		   haOpen[i_Bar] = d_Open;
		  haClose[i_Bar] = d_Close;} //End HA
//+---Trend Function-------------------------------------------------------------------------------------------------+
   if(returnBars){TREND[0]=limit+1; return(0);} if(calculateTREND || timeFrame == Period()){
   if(!calculateTREND && trend[limit]==-1) CleanPoint(limit,TRENDdna,TRENDdnb); 
   for(i=limit;i>=0;i--){TRENDdna[i]=EMPTY_VALUE;  TRENDdnb[i]=EMPTY_VALUE; trend[i]=trend[i+1];
                   if(Close[i]>iMA(Symbol(),TRENDtf,TRENDper,TRENDshft,TRENDmode,PRICE_HIGH,i+1)) trend[i]= 1;
                   if(Close[i]<iMA(Symbol(),TRENDtf,TRENDper,TRENDshft,TRENDmode,PRICE_LOW, i+1)) trend[i]=-1;
   if(trend[i]==-1)   TREND[i]=iMA(Symbol(),TRENDtf,TRENDper,TRENDshft,TRENDmode,TRENDtype,i+1);
                else  TREND[i]=iMA(Symbol(),TRENDtf,TRENDper,TRENDshft,TRENDmode,TRENDtype,i+1);
   if(!calculateTREND && trend[i]==-1) PlotPoint(i,TRENDdna,TRENDdnb,TREND); TRENDbgd[i]=TREND[i];}}//End Trend
//+---ccitrend Function----------------------------------------------------------------------------------------------+
   for(i=0; i<=limit; i++){ccitrend[i]=iCCI(NULL,0,28,PRICE_TYPICAL,i);}
//+---Alert Function-------------------------------------------------------------------------------------------------+
   for(i=limit;i>=0;i--){
   if(trend[i]== 1 && TMA1bandDn[i]<TMA2bandDn[i] && ccitrend[i]>=0.){trend1[i]= 1;}
   if(trend[i]==-1 && TMA1bandUp[i]>TMA2bandUp[i] && ccitrend[i]<-0.){trend1[i]=-1;}}
//+---InfoBOX Display------------------------------------------------------------------------------------------------+
   int LightButp=Determine_StopLight(); Show_TrafficLights(LightButp); if(showINFOBOX){
   iPanel(ID+"Xard0",4,129,"g",70,"Webdings",Panelcol); iPanel(ID+"Xard1",4,212,"g",70,"Webdings",Panelcol);
   iPanel(ID+"Xard2",4,236,"g",70,"Webdings",Panelcol);
   iPanel(ID+"Xard3",9,134,"g",62,"Webdings",Boxbgd);   iPanel(ID+"Xard4",9,216,"g",62,"Webdings",Boxbgd);
//+------------------------------------------------------------------------------------------------------------------+
   double ydayhigh=iHigh(Symbol(),PERIOD_D1,1), ydaylow=iLow(Symbol(),PERIOD_D1,1);
   double spd=(MarketInfo(SymPair,MODE_BID)); string MarketPrice=DoubleToStr(Bid,Digits-1);
   if(spd>=1 && spd<=9.99)         int spx=+13; else if(spd>=0 && spd<=0.9999)      spx=+12;
   else if(spd>=10 && spd<=99.99)      spx=+13; else if(spd>=100 && spd<=999.99)    spx=+12;
   else if(spd>=1000 && spd<=9999.99)  spx=+12; else if(spd>=10000 && spd<=99999.99)spx=+14;
   iPanel(ID+"Xard5",spx,155,DoubleToStr(MarketInfo(SymPair,MODE_BID),DecNos),16,"Arial Black",clrAqua);
//+------------------------------------------------------------------------------------------------------------------+
   double sprd=(Ask-Bid)/myPoint; if(sprd>=1 && sprd<=9.99) int spdx=-1; else if(sprd>=10 && sprd<=99.99)spdx=-3; 
   else if(sprd>=100 && sprd<=999.99)spdx=-6; iPanel(ID+"Xard6",18+spdx,179,"SPD:"+
   DoubleToStr((Ask-Bid)*MathPow(10,Digits)/pipsize,1),12,"Consolas Bold",Snow); Show_Timer(); RefreshRates();
//+------------------------------------------------------------------------------------------------------------------+
   string OPEN=""; OpenToday=iOpen(SymPair,1440,0); OPEN=(DoubleToStr(OpenToday,DecNos)); 
   string PIPS=""; CLOSE=iClose(SymPair,1440,0); PIPS=DoubleToStr((CLOSE-OpenToday)/Point/pipsize,0); 
   color cPIPS; if(CLOSE>=OpenToday){cPIPS=clrAqua;} if(CLOSE<OpenToday){cPIPS=clrViolet;}
   iPanel(ID+"Xard8",13,134,StringSubstr(SymPair,0,7),18,"Impact",clrWhite);
   iPanel(ID+"Xard9",12,211,"Daily Open",10,"Arial Black",cPIPS); iPanel(ID+"Xard10",21,224,OPEN,13,FontType,cPIPS);
   iPanel(ID+"Xard11",52,246,"P2Op",10,"Arial Bold",clrSnow); iPanel(ID+"Xard12",14,246,PIPS,11,"Arial Bold",cPIPS);
//+------------------------------------------------------------------------------------------------------------------+
   string HILO=""; double HiToday=iHigh(NULL,1440,0),LoToday=iLow(NULL,1440,0);
   HILO=DoubleToStr((HiToday-LoToday)/Point/pipsize,0); iPanel(ID+"Xard13",52,263,"HiLo",10,"Arial Bold",clrSilver);
                                                        iPanel(ID+"Xard14",14,263, HILO ,11,"Arial Bold",clrSilver);
//+---ADR------------------------------------------------------------------------------------------------------------+
   ADR1=0; ADR5=0; ADR10=0; ADR20=0; ADRavg=0; int a,b,c; int ypos=0;
                             ADR1=(iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1));
   for(a=1;a<= 5;a++)  ADR5= ADR5+(iHigh(NULL,PERIOD_D1,a)-iLow(NULL,PERIOD_D1,a));
   for(b=1;b<=10;b++) ADR10=ADR10+(iHigh(NULL,PERIOD_D1,b)-iLow(NULL,PERIOD_D1,b));
   for(c=1;c<=20;c++) ADR20=ADR20+(iHigh(NULL,PERIOD_D1,c)-iLow(NULL,PERIOD_D1,c));
   ADR5=ADR5/5;  ADR10=ADR10/10;  ADR20=ADR20/20;  ADRavg=(((ADR1+ADR5+ADR10+ADR20)/4))/Point/pipsize;
   double avYest=(iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1))/Point/pipsize; color colorDAV=LimeGreen;
   if(ADRavg>avYest){colorDAV=DarkOrange;} iPanel(ID+"Xard15",52,280,"D.Avg",10,"Arial Bold",clrSnow);
   iPanel(ID+"Xard16",14,280,DoubleToStr(ADRavg,0),11,"Arial Bold",colorDAV);}//EO InfoBox
//+---Symbol Header Function-----------------------------------------------------------------------------------------+
   color SymClr=clrGray; if(Close[0]>OpenToday){SymClr=clrDodgerBlue;} if(Close[0]<OpenToday){SymClr=C'238,130,238';}
   if(showSymbolHeader){color Sbg=clrSnow;//C'161,161,161';
   iOBOS(ID+"ObOs1",LR+1,UD+1,StringSubstr(SymPair,0,8),HDRsize,"Arial Black",Sbg);
   iOBOS(ID+"ObOs2",LR+0,UD+0,StringSubstr(SymPair,0,8),HDRsize,"Arial Black",SymClr);}//End Symboltext
//+---BidRatio Function----------------------------------------------------------------------------------------------+
   if(showD1){if((iHigh(SymPair,PERIOD_D1,0)-iLow(SymPair,PERIOD_D1,0)!=0))
   D1pct=100.0*((iClose(SymPair,PERIOD_D1,0)-iLow(SymPair,PERIOD_D1,0))/
   (iHigh(SymPair,PERIOD_D1,0)-iLow(SymPair,PERIOD_D1,0))); else D1pct=0.0;
   clrD1pct=clrGray; if(D1pct<=SellRatio){clrD1pct=clrRed;} if(D1pct>=BuyRatio){clrD1pct=clrLime;}
   iPanel(ID+"Xard21",15,300,DoubleToStr(D1pct,0)+"%",18,"Arial Bold",clrD1pct);}
//+------------------------------------------------------------------------------------------------------------------+
      manageAlerts();  return(0);}
   for(i=limit;i>=0;i--) if(slope[i]==-1) PlotPoint(i,TMA2up,TMA2dn,TMA2);  return(rates_total);}
//+---Timer Function-------------------------------------------------------------------------------------------------+
   void Show_Timer(){double rx; int mt,s; mt=Time[0]+Period()*60-CurTime(); rx=mt/60.0; s=mt%60; mt=(mt-mt%60)/60;
   if(showINFOBOX){iPanel(ID+"Xard7",13,192,mt+":"+s,13,"Arial Black",clrLime);}}
//+------------------------------------------------------------------------------------------------------------------+
   void manageAlerts(){if(!calculateValue && alertsOn){if(alertsOnCurrent)
   int whichBar = 0; else whichBar = 1; 
       whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      static datetime time2 = 0;  static string   mess2 = "";
   if(alertsOnStopLight && trend1[whichBar] != trend1[whichBar+1]){
   if(trend1[whichBar] ==  1) doAlert(time2,mess2,whichBar,"BUY");
   if(trend1[whichBar] == -1) doAlert(time2,mess2,whichBar,"SELL");}}}
//+------------------------------------------------------------------------------------------------------------------+
   void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat){string msg;
   if(previousAlert != doWhat || previousTime != Time[forBar]){previousAlert = doWhat;  previousTime = Time[forBar];
   msg=StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," @ ",
       TimeToStr(TimeLocal(),TIME_MINUTES),"  StopLight is a ",doWhat);
   if(alertsMessage) Alert(msg);  if(alertsNotify)  SendNotification(msg);
   if(alertsEmail)   SendMail(StringConcatenate(Symbol()," "),msg);  if(alertsSound)   PlaySound("alert2.wav");}}
//+------------------------------------------------------------------------------------------------------------------+
   void CleanPoint(int i,double& first[],double& second[]){
   if((second[i]!=EMPTY_VALUE) && (second[i+1]!=EMPTY_VALUE)) second[i+1]=EMPTY_VALUE;
   else if((first[i]!=EMPTY_VALUE) && (first[i+1]!=EMPTY_VALUE) && (first[i+2]==EMPTY_VALUE)) first[i+1]=EMPTY_VALUE;}
//+------------------------------------------------------------------------------------------------------------------+
   void PlotPoint(int i,double& first[],double& second[],double& from[]){ if(first[i+1]==EMPTY_VALUE){
   if(first[i+2]==EMPTY_VALUE){ first[i]=from[i]; first[i+1]=from[i+1]; second[i]=EMPTY_VALUE;} else {
   second[i]=from[i]; second[i+1]=from[i+1]; first[i]=EMPTY_VALUE;}} else {first[i]=from[i]; second[i]=EMPTY_VALUE;}}
//+------------------------------------------------------------------------------------------------------------------+
   string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
   int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};
//+------------------------------------------------------------------------------------------------------------------+
   int stringToTimeFrame(string tfs){ tfs=stringUpperCase(tfs);  for(int i=ArraySize(iTfTable)-1; i>=0; i--)
   if(tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));  return(Period());}
//+------------------------------------------------------------------------------------------------------------------+
   string timeFrameToString(int tf){
   for(int i=ArraySize(iTfTable)-1;i>=0;i--)  if(tf==iTfTable[i]) return(sTfTable[i]); return("");}
//+------------------------------------------------------------------------------------------------------------------+
   string stringUpperCase(string str){ string s=str; for(int length=StringLen(str)-1; length>=0; length--){
   int tchar=StringGetChar(s,length); if((tchar>96 && tchar<123) || (tchar>223 && tchar<256))
   s=StringSetChar(s,length,tchar-32); else if(tchar>-33 && tchar<0) s=StringSetChar(s,length,tchar+224);} return(s);}
//+--- Semafor ------------------------------------------------------------------------------------------------------+
   int CountZZ(double& ZZBufUp[],double& ZZBufDn[],int ExtDepth,int ExtDeviation,int ExtBackstep){
   int shiftZZ,back,lasthighpos,lastlowpos; double val,res,curlow,curhigh,lasthigh,lastlow;
   for(shiftZZ=Bars-ExtDepth; shiftZZ>=0; shiftZZ--){val=Low[iLowest(NULL,0,MODE_LOW,ExtDepth,shiftZZ)];
   if(val==lastlow) val=0.0;  else {lastlow=val;
   if((Low[shiftZZ]-val)>(ExtDeviation*ZZPoint)) val=0.0;  else {
   for(back=1; back<=ExtBackstep; back++){res=ZZBufUp[shiftZZ+back];
   if(res!=0.0) res=res+ZZdelta;  if((res!=0.0)&&(res>val)) ZZBufUp[shiftZZ+back]=0.0;}}} 
   if(val==0.0) ZZBufUp[shiftZZ]=0.0; else ZZBufUp[shiftZZ]=val-ZZdelta;
   val=High[iHighest(NULL,0,MODE_HIGH,ExtDepth,shiftZZ)];
   if(val==lasthigh) val=0.0;  else { lasthigh=val;
   if((val-High[shiftZZ])>(ExtDeviation*ZZPoint)) val=0.0; else {
   for(back=1; back<=ExtBackstep; back++){ res=ZZBufDn[shiftZZ+back];
   if(res!=0.0) res=res-ZZdelta;  if((res!=0.0)&&(res<val)) ZZBufDn[shiftZZ+back]=0.0;}}} 
   if(val==0.0) ZZBufDn[shiftZZ]=0.0; else ZZBufDn[shiftZZ]=val+ZZdelta;}
//+--- Semafor final cutting ----------------------------------------------------------------------------------------+ 
   lasthigh=-1;  lasthighpos=-1;  lastlow=-1;  lastlowpos=-1;
   for(shiftZZ=Bars-ExtDepth; shiftZZ>=0; shiftZZ--){ curlow=ZZBufUp[shiftZZ];
   if( curlow != 0.0)  curlow =  curlow+ZZdelta;     curhigh=ZZBufDn[shiftZZ];
   if(curhigh != 0.0) curhigh = curhigh-ZZdelta;  if((curlow==0.0)&&(curhigh==0.0)) continue;
   if(curhigh!=0.0){if(lasthigh>0.0){ if(lasthigh<curhigh) ZZBufDn[lasthighpos]=0.0; else ZZBufDn[shiftZZ]=0.0;}
   if(lasthigh<curhigh || lasthigh<0.0){lasthigh=curhigh; lasthighpos=shiftZZ;} lastlow=-1;}
   if(curlow!=0.0){if(lastlow>0.0){   if(lastlow>curlow) ZZBufUp[lastlowpos]=0.0; else ZZBufUp[shiftZZ]=0.0;}
   if((curlow<lastlow)||(lastlow<0.0)){lastlow=curlow; lastlowpos=shiftZZ;} lasthigh=-1;}}
   for(shiftZZ=Bars-1;shiftZZ>=0;shiftZZ--){if(shiftZZ>=Bars-ExtDepth)ZZBufUp[shiftZZ]=0.0; else {break;}} return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   int Str2Massive(string VStr,int& MCount,int& VMass[]){int val=StrToInteger(VStr); if(val>0){MCount++;
   int mc=ArrayResize(VMass,MCount); if(mc==0)return(-1); VMass[MCount-1]=val; return(1);} else return(0);} 
//+------------------------------------------------------------------------------------------------------------------+
   int IntFromStr(string ValStr,int& MCount, int& VMass[]){if(StringLen(ValStr)==0) return(-1);
   string SS=ValStr; int NP=0; string CS; MCount=0; ArrayResize(VMass,MCount);
   while(StringLen(SS)>0){NP=StringFind(SS,",");
   if(NP>0){CS=StringSubstr(SS,0,NP); SS=StringSubstr(SS,NP+1,StringLen(SS));} else {
   if(StringLen(SS)>0){CS=SS; SS="";}} if(Str2Massive(CS,MCount,VMass)==0){return(-2);}} return(1);}
//+------------------------------------------------------------------------------------------------------------------+
   double getPoint(bool custommode){string symbol=Symbol();  double point = MarketInfo(symbol,MODE_POINT);
   int pluspos = StringFind(symbol,"+",0);  int minuspos = StringFind(symbol,"-",0);
   if(pluspos>0) symbol=StringSubstr(symbol,0,pluspos); else if(minuspos>0) symbol=StringSubstr(symbol,0,minuspos);
   if(point<0.000000001) point=MarketInfo(symbol,MODE_POINT);  if(! custommode) return(point); else {
   if(symbol=="NOKJPY"||symbol=="SEKJPY"||symbol=="GBPDKK"||symbol=="GBPNOK"||symbol=="USDSKK"||symbol=="XAG") 
   point=MarketInfo(symbol,MODE_POINT);
      else if (StringFind(symbol,"JPY",3) == 3 || symbol == "XAUUSD") point = 0.01;
      else if (StringFind(symbol,"USD",0) >= 0
            || StringFind(symbol,"EUR",0) >= 0
            || StringFind(symbol,"GBP",0) >= 0
            || StringFind(symbol,"CAD",0) >= 0
            || StringFind(symbol,"NZD",0) >= 0) point = 0.0001;}
   if(point<0.000000001) point=Point; if(point<0.000000001) point=0.01; return(point);}//end of getPoint
//+------------------------------------------------------------------------------------------------------------------+
   datetime BofYr(datetime T){return (StrToTime(TimeYear(T)+".1.1 00:00"));}
//+------------------------------------------------------------------------------------------------------------------+
   void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam){
	if(id==CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam,OBJPROP_TYPE)==OBJ_BUTTON){
   if(StringFind(sparam,ID+":back:"  ,0)==0) ObjectSet(sparam,OBJPROP_STATE,false); 
	if(IsStopped()) return; fSetBuffers();} OnInit();}
//+------------------------------------------------------------------------------------------------------------------+
   void fSetBuffers(){int iChartScale = int(ChartGetInteger(0,CHART_SCALE));
	if(getChartScale == iChartScale) return;
	getChartScale = iChartScale; int iWidth=0; switch(iChartScale){
		case 0: iWidth = 1; break;
		case 1: iWidth = 1; break;
		case 2: iWidth = 2; break;
		case 3: iWidth = 4; break;
		case 4: iWidth = 7; break;
		case 5: iWidth =14; break;}
	if(showRIBBON)         Type=DRAW_HISTOGRAM; else Type=DRAW_NONE;
   SetIndexStyle(0,Type,0,iWidth,RibColUP);
   SetIndexStyle(1,Type,0,iWidth,RibColDN);
   SetIndexStyle(2,Type,0,iWidth,RibColUP);
   SetIndexStyle(3,Type,0,iWidth,RibColDN);
	if(showHA)             Type=DRAW_HISTOGRAM; else Type=DRAW_NONE;
	SetIndexStyle(24,Type,0,iWidth,cBearish);
	SetIndexStyle(25,Type,0,iWidth,cBullish);
	if(showTREND)          Type=DRAW_LINE; else Type=DRAW_NONE;
	SetIndexStyle(26,Type,0,iWidth+4,TRENDbgdclr);
	SetIndexStyle(27,Type,0,iWidth+2,TRENDupclr);
	SetIndexStyle(28,Type,0,iWidth+2,TRENDdnclr);
	SetIndexStyle(29,Type,0,iWidth+2,TRENDdnclr);	ChartRedraw();}
//+---StopLight Function---------------------------------------------------------------------------------------------+
	int Determine_StopLight(){int xpos=18,ypos=66;if(showSpotLight){if(!IsConnected())return(PowerFailure);
   if(trend[0]== 1 && TMA1bandDn[0]<TMA2bandDn[0] && ccitrend[0]>=0.){
   z(ID+"tls0102");ObjectDelete(ID+"tls0103");
   makeSTOP(ID+"tls0101",xpos+4,ypos+2,"BUY", tsize,FontType,textcolUP);return(GreenLight);}
   if(trend[0]==-1 && TMA1bandUp[0]>TMA2bandUp[0] && ccitrend[0]<-0.){
   ObjectDelete(ID+"tls0101");ObjectDelete(ID+"tls0103");
   makeSTOP(ID+"tls0102",xpos-2,ypos+2,"SELL",tsize,FontType,textcolDN);return(RedLight);}
   ObjectDelete(ID+"tls0101");ObjectDelete(ID+"tls0102");
   makeSTOP(ID+"tls0103",xpos-3,ypos+2,"WAIT",tsize,FontType,textcolWT);return(OrangeLight);} return(PowerFailure);}
//+------------------------------------------------------------------------------------------------------------------+
   void Show_TrafficLights(int TrafficLight){color cStopLights[3]; switch(TrafficLight){
   case GreenLight:     cStopLights[0]=clrGreen;                    Color_Chart(GreenLight); break;
   case OrangeLight:    cStopLights[0]=clrOrange;                  Color_Chart(OrangeLight); break;
   case RedLight:       cStopLights[0]=C'238,130,238';                Color_Chart(RedLight); break;
   case PowerFailure:   cStopLights[0]=Panetpgd2; break;   default:cStopLights[0]=Panetpgd2; break;}
//+------------------------------------------------------------------------------------------------------------------+
   if(showSpotLight){double OpToday=iOpen(NULL,1440,0); color Panetpgd1=C'80,90,100';
   if(Close[0]>OpToday){Panetpgd1=clrLime;} else Panetpgd1=clrDeepPink;
   makeTLS(ID+"tls0001",5,31); ObjectSetText(ID+"tls0001","g",70,"Webdings",Panelcol);
   makeTLS(ID+"tls0004",8,35); ObjectSetText(ID+"tls0004","n",65,"Webdings",Panetpgd1); for(int is=0;is<1;is++){
   makeTLS(ID+"tls00"+(is+4),13,40+is*92); ObjectSetText(ID+"tls00"+(is+4),"n",58,"Webdings",cStopLights[is]);}}}
//+------------------------------------------------------------------------------------------------------------------+
   void makeSTOP(string tls1,int x,int y,string Text,int fontSize,string Font,color Color){
           ObjectDelete(tls1); ObjectCreate(tls1,OBJ_LABEL,Window,0,0);
              ObjectSet(tls1,OBJPROP_CORNER,InfoBoxCorner);
              ObjectSet(tls1,OBJPROP_XDISTANCE,x-1+posLR);
              ObjectSet(tls1,OBJPROP_YDISTANCE,y+3+posUD);
              ObjectSet(tls1,OBJPROP_BACK,false);
          ObjectSetText(tls1,Text,tsize,FontType,Color);}
//+------------------------------------------------------------------------------------------------------------------+
   void makeTLS(string tls2,int x,int y){ObjectCreate(tls2,OBJ_LABEL,Window,0,0);
             ObjectSet(tls2,OBJPROP_CORNER,InfoBoxCorner);
             ObjectSet(tls2,OBJPROP_XDISTANCE,x-1+posLR);
             ObjectSet(tls2,OBJPROP_YDISTANCE,y+9+posUD);}
//+------------------------------------------------------------------------------------------------------------------+
   void iPanel(string tls3,int x,int y,string Text,int fontSize,string Font,color Color){
         ObjectCreate(tls3,OBJ_LABEL,Window,0,0);
            ObjectSet(tls3,OBJPROP_CORNER,InfoBoxCorner);
            ObjectSet(tls3,OBJPROP_XDISTANCE,x+posLR);
            ObjectSet(tls3,OBJPROP_YDISTANCE,y+2+posUD);
            ObjectSet(tls3,OBJPROP_BACK,false);
        ObjectSetText(tls3,Text,fontSize,Font,Color);}
//+------------------------------------------------------------------------------------------------------------------+
   void iOBOS(string tls4,int x,int y,string Text,int fontSize,string Font,color Color){
        ObjectCreate(tls4,OBJ_LABEL,0,0,0);
           ObjectSet(tls4,OBJPROP_CORNER,0);
           ObjectSet(tls4,OBJPROP_XDISTANCE,x);
           ObjectSet(tls4,OBJPROP_YDISTANCE,y);
           ObjectSet(tls4,OBJPROP_BACK,false);
       ObjectSetText(tls4,Text,fontSize,Font,Color);}
//+------------------------------------------------------------------------------------------------------------------+
   void Color_Chart(int signal){static color LastColor;color Color=C'20,20,40';if(Color==LastColor)return;
   LastColor=Color; ChartSetInteger(0,CHART_COLOR_BACKGROUND,Color); ChartRedraw(0);}
//+----Clean Chart Function------------------------------------------------------------------------------------------+
   void CleanUpAisle1(string nature){int obj_total= ObjectsTotal(); for(int il=obj_total; il>=0; il--){
   string name=ObjectName(il); if(StringSubstr(name,0,5)==(nature)) ObjectDelete(name);}}//End CleanUpAisle1
//+----END OF FILE---------------------------------------------------------------------------------------------------+