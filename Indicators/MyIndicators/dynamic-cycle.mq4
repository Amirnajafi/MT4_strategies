#property copyright ""
#property link ""
#property description ""
#property description ""
#property strict

#property indicator_separate_window

#property indicator_buffers 4
#property indicator_color1 clrGold
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrGray
#property indicator_color4 clrGray

#property indicator_width1 2
#property indicator_width2 2

#property indicator_levelcolor clrMediumOrchid

enum enum1 {
    Prc,   // Current price
    ST     // Super Trend price
};

enum enum2 {
    DCE,   // DCE
    DCEs   // DCE smoothed
};
//+------------------------------------------------------------------+
extern string             a01           = "";            // ___ Параметры DCE _____________
extern int                Period1       = 34;            // Период 1
extern int                Period2       = 22;            // Период 2
extern int                Period3       = 18;            // Период 3
extern int                Period4       = 33;            // Период 4
extern int                Period5       = 29;            // Период 5
extern int                Period6       = 14;            // Период 6
extern ENUM_APPLIED_PRICE Price         = PRICE_CLOSE;   // Тип цены
extern int                Signal_Period = 3;             // Период сглаживания
extern ENUM_MA_METHOD     Signal_Method = MODE_SMA;      // Метод расчета для сглаживания
extern enum1              DCE_Pr        = ST;            // Расчет DCE по:
//+------------------------------------------------------------------+
extern string             a02           = "";   // ___ Параметры Super Trend _______
extern int                CCIperiod     = 50;   // Период CCI
extern int                ATRperiod     = 5;    // Период ATR
extern ENUM_APPLIED_PRICE applied_price = 5;    // Тип цены
//+------------------------------------------------------------------+
extern string a03          = "";     // ___ Параметры BB _______________
extern enum2  BB_on_DCE_MA = DCE;    // Расчет ВВ по:
extern int    BB_Period    = 89;     // Период ВВ
extern double BB_Deviation = 1.62;   // Девиация ВВ
extern int    History      = 1000;   // Глубина истории
//+------------------------------------------------------------------+
extern string a04            = "";   // ___ Параметры уровней __________
extern double levelOb        = 0;    //
extern double levelOs        = 0;    //
extern double extremelevelOb = 0;    //
extern double extremelevelOs = 0;    //
//+------------------------------------------------------------------+
extern string a05                 = "";             // ___ Параметры оповещения _______
extern bool   alertsOn            = true;           //
extern bool   alertsOnObOs        = false;          //
extern bool   alertsOnExtremeObOs = true;           //
extern bool   alertsOnCurrent     = false;          //
extern bool   alertsMessage       = true;           //
extern bool   alertsSound         = true;           //
extern bool   alertsEmail         = false;          //
extern bool   alertsNotify        = false;          //
extern string soundfile           = "alert2.wav";   //
//+------------------------------------------------------------------+
extern string a06              = "";            // ___ Параметры стрелок ___________
extern bool   arrowsVisible    = true;          //
extern string arrowsIdentifier = "DCE_BB>i<";   // ID объектов индикатора
extern double arrowsUpperGap   = 0.1;           //
extern double arrowsLowerGap   = 0.1;           //
//+------------------------------------------------------------------+
extern bool  arrowsOnObOs      = true;           //
extern color arrowsObOsUpColor = clrLimeGreen;   //
extern color arrowsObOsDnColor = clrRed;         //
extern int   arrowsObOsUpCode  = 241;            //
extern int   arrowsObOsDnCode  = 242;            //
extern int   arrowsObOsUpSize  = 1;              //
extern int   arrowsObOsDnSize  = 1;              //
//+------------------------------------------------------------------+
extern bool  arrowsOnExtremeObOs      = true;               //
extern color arrowsExtremeObOsUpColor = clrDeepSkyBlue;     //
extern color arrowsExtremeObOsDnColor = clrPaleVioletRed;   //
extern int   arrowsExtremeObOsUpCode  = 159;                //
extern int   arrowsExtremeObOsDnCode  = 159;                //
extern int   arrowsExtremeObOsUpSize  = 5;                  //
extern int   arrowsExtremeObOsDnSize  = 5;                  //
//+------------------------------------------------------------------+
double Map[];
double signal[];
double band_up[];
double band_dn[];
double trend1[];
double trend2[];
double prices[];
int    maxPeriod;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init() {
    IndicatorBuffers(7);

    SetIndexBuffer(0, Map);
    SetIndexBuffer(1, signal);
    SetIndexBuffer(2, band_up);
    SetIndexBuffer(3, band_dn);
    SetIndexBuffer(4, trend1);
    SetIndexBuffer(5, trend2);
    SetIndexBuffer(6, prices);

    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);
    SetIndexStyle(2, DRAW_LINE);
    SetIndexStyle(3, DRAW_LINE);

    SetLevelValue(0, levelOb);
    SetLevelValue(1, levelOs);
    SetLevelValue(2, extremelevelOb);
    SetLevelValue(3, extremelevelOs);

    maxPeriod = MathMax(Period1, Period2);
    maxPeriod = MathMax(Period3, maxPeriod);
    maxPeriod = MathMax(Period4, maxPeriod);
    maxPeriod = MathMax(Period5, maxPeriod);
    maxPeriod = MathMax(Period6, maxPeriod);
    maxPeriod = MathMax(BB_Period, maxPeriod);

    return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit() {
    deleteArrows();
    return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() {
    int i, idx;
    int counted = IndicatorCounted();
    if(counted < 0)
        return (-1);
    if(counted > 0)
        counted--;
    int limit = MathMin(MathMax(Bars - counted, maxPeriod), Bars - maxPeriod);
    if(limit > History)
        limit = History;
    // if (limit < 10) limit = 10;
    //+------------------------------------------------------------------+

    if(DCE_Pr == Prc) {
        for(i = limit; i >= 0; i--)
            prices[i] = iMA(NULL, 0, 1, 0, MODE_SMA, Price, i) * 100000;
    } else {
        for(i = limit; i >= 0; i--) {
            double cciTrend = iCCI(NULL, 0, CCIperiod, applied_price, i);
            prices[i]       = prices[i + 1];

            if(cciTrend > 0)
                prices[i] = MathMax(Low[i] - iATR(NULL, 0, ATRperiod, i), prices[i + 1]);
            if(cciTrend < 0)
                prices[i] = MathMin(High[i] + iATR(NULL, 0, ATRperiod, i), prices[i + 1]);
        }
    }

    for(i = limit; i >= 0; i--)
        Map[i] = (icTma(Period2, i) - icTma(Period1, i) + icTma(Period4, i) - icTma(Period3, i) + icTma(Period6, i) - icTma(Period5, i));

    for(idx = limit; idx >= 0; idx--)
        signal[idx] = iMAOnArray(Map, 0, Signal_Period, 0, Signal_Method, idx);

    for(idx = limit; idx >= 1; idx--) {
        if(BB_on_DCE_MA) {
            band_up[idx] = iBandsOnArray(Map, 0, BB_Period, BB_Deviation, 0, MODE_UPPER, idx);
            band_dn[idx] = iBandsOnArray(Map, 0, BB_Period, BB_Deviation, 0, MODE_LOWER, idx);
        } else {
            band_up[idx] = iBandsOnArray(signal, 0, BB_Period, BB_Deviation, 0, MODE_UPPER, idx);
            band_dn[idx] = iBandsOnArray(signal, 0, BB_Period, BB_Deviation, 0, MODE_LOWER, idx);
        }
        if(Map[idx] > levelOb && Map[idx] > band_up[idx] && CheckLinesCrossing(false, idx))
            trend1[idx - 1] = -1;
        if(Map[idx] < levelOs && Map[idx] < band_dn[idx] && CheckLinesCrossing(true, idx))
            trend1[idx - 1] = 1;
        if(Map[idx] > extremelevelOb && Map[idx] > band_up[idx] && CheckLinesCrossing(false, idx))
            trend2[idx - 1] = -1;
        if(Map[idx] < extremelevelOs && Map[idx] < band_dn[idx] && CheckLinesCrossing(true, idx))
            trend2[idx - 1] = 1;

        if(arrowsVisible) {
            ObjectDelete(arrowsIdentifier + ":1:" + TimeToStr(Time[idx]));
            ObjectDelete(arrowsIdentifier + ":2:" + TimeToStr(Time[idx]));
            string lookFor = arrowsIdentifier + ":" + TimeToStr(Time[idx]);
            ObjectDelete(lookFor);
            if(arrowsOnObOs) {
                if(trend1[idx] == 1)
                    drawArrow("1", 0.5, idx, arrowsObOsUpColor, arrowsObOsUpCode, arrowsObOsUpSize, false);
                if(trend1[idx] == -1)
                    drawArrow("1", 0.5, idx, arrowsObOsDnColor, arrowsObOsDnCode, arrowsObOsDnSize, true);
            }
            if(arrowsOnExtremeObOs) {
                if(trend2[idx] == 1)
                    drawArrow("2", 1, idx, arrowsExtremeObOsUpColor, arrowsExtremeObOsUpCode, arrowsExtremeObOsUpSize, false);
                if(trend2[idx] == -1)
                    drawArrow("2", 1, idx, arrowsExtremeObOsDnColor, arrowsExtremeObOsDnCode, arrowsExtremeObOsDnSize, true);
            }
        }
    }

    if(alertsOn) {
        int whichBar;
        if(alertsOnCurrent)
            whichBar = 0;
        else
            whichBar = 1;

        static datetime time1 = 0;
        static string   mess1 = "";
        if(alertsOnObOs) {
            if(trend1[whichBar] == 1)
                doAlert(time1, mess1, whichBar, " пересечение зоны перепроданности");   //"crossing oversold");
            if(trend1[whichBar] == -1)
                doAlert(time1, mess1, whichBar, " пересечение зоны перекупленности");   //"crossing overbought");
        }
        static datetime time2 = 0;
        static string   mess2 = "";
        if(alertsOnExtremeObOs) {
            if(trend2[whichBar] == 1)
                doAlert(time2, mess2, whichBar, "пересечение экстремальной перепроданность");   //"crossing extreme oversold");
            if(trend2[whichBar] == -1)
                doAlert(time2, mess2, whichBar, "пересечение экстремальной перекупленности");   //""crossing extreme overbought");
        }
    }
    return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime TimeBr = 0;

void doAlert(datetime &previousTime, string &previousAlert, int forBar, string doWhat) {
    string message;

    if((previousAlert != doWhat || previousTime != Time[forBar]) && TimeBr != Time[forBar]) {
        previousAlert = doWhat;
        previousTime  = Time[forBar];
        TimeBr        = Time[forBar];

        message = StringConcatenate(Symbol(), " ", _Period, " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " DCE_BB ", doWhat);
        if(alertsMessage)
            Alert(message);
        if(alertsNotify)
            SendNotification(message);
        if(alertsEmail)
            SendMail(StringConcatenate(Symbol(), " DCE_BB "), message);
        if(alertsSound)
            PlaySound(soundfile);
    }
}
//+------------------------------------------------------------------+
//|  tma modif. by Genry. + Correct 28jul2017                        |
//+------------------------------------------------------------------+
double icTma(int period, int i) {
    int    j, k;
    double sumw = (period + 1);
    double sum  = sumw * Close[i];   //(period+1)*prices[i];

    for(j = 1, k = period; j < period; j++, k--) {
        sumw += k;
        sum  += k * Close[i + j];   // prices[i+j]*k;
        if(j <= i) {
            sum  += Close[i - j] * k;
            sumw += k;
        }   // { sum  += prices[i-j]*k;  sumw += k; }
    }
    return (sum / sumw);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(string nameAdd, double gapMul, int i, color theColor, int theCode, int theWidth, bool up) {
    string name = arrowsIdentifier + ":" + nameAdd + ":" + TimeToStr(Time[i]);
    double gap  = iATR(NULL, 0, 20, i) * gapMul;

    ObjectCreate(name, OBJ_ARROW, 0, Time[i], 0);
    ObjectSet(name, OBJPROP_ARROWCODE, theCode);
    ObjectSet(name, OBJPROP_COLOR, theColor);
    ObjectSet(name, OBJPROP_WIDTH, theWidth);
    if(up)
        ObjectSet(name, OBJPROP_PRICE1, High[i] + arrowsUpperGap * gap);
    else
        ObjectSet(name, OBJPROP_PRICE1, Low[i] - arrowsLowerGap * gap);
    WindowRedraw();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteArrows() {
    string lookFor       = arrowsIdentifier + ":";
    int    lookForLength = StringLen(lookFor);
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objectName = ObjectName(i);
        if(StringSubstr(objectName, 0, lookForLength) == lookFor)
            ObjectDelete(objectName);
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckLinesCrossing(bool IsBuySign, int i) {
    double RedLine1  = Map[i - 1];
    double RedLine2  = Map[i];
    double BlueLine1 = signal[i - 1];
    double BlueLine2 = signal[i];

    if(IsBuySign && RedLine1 > BlueLine1 && RedLine2 < BlueLine2 && RedLine1 < EMPTY_VALUE && BlueLine1 < EMPTY_VALUE)
        return (true);
    if(!IsBuySign && RedLine1 < BlueLine1 && RedLine2 > BlueLine2 && RedLine1 < EMPTY_VALUE && BlueLine1 < EMPTY_VALUE)
        return (true);
    return (false);
}
//+------------------------------------------------------------------+