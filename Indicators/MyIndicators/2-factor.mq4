//+------------------------------------------------------------------+
//|                                                    MA ribbon.mq4 |
//|                                               mladenfx@gmail.com |
//|                                                                  |
//| original idea by Jose Silva                                      |
//| Ma Channel Ribbon filled Modified by Steven                      |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Crimson
#property indicator_color2 Blue
#property indicator_color3 DarkBlue
#property indicator_color4 FireBrick
#property indicator_color5 DarkGreen
#property indicator_color6 Aqua
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 15
#property indicator_width4 15
#property indicator_width5 5
#property indicator_width6 5
//
//
//
//
//

extern int    MaFastPeriod    = 9;
extern int    MaFastMethod    = MODE_EMA;
extern int    MaFastPrice     = PRICE_MEDIAN;
extern int    MaMediumPeriod  = 36;
extern int    MaMediumMethod  = MODE_EMA;
extern int    MaMediumPrice   = PRICE_MEDIAN;
extern int    MaHighPeriod    = 36;
extern int    MaHighMethod    = MODE_EMA;
extern int    MaHighPrice     = PRICE_HIGH;
extern int    MaLowPeriod     = 36;
extern int    MaLowMethod     = MODE_EMA;
extern int    MaLowPrice      = PRICE_LOW;
extern int    SignalSize      = 15;
extern int    Corner          = 3;
extern int    ShiftToTheLeft  = 100;
extern double ShiftToTheRight = 100;

bool   AlertOn       = false;
bool   ShowArrows    = true;
int    ArrowWidth    = 1;
color  ArrowsUpColor = Green;
color  ArrowsDnColor = Red;
bool   DisplaySignal = true;
bool   BackDaysHL    = true;
int    BackDays      = 1;
color  HighLevel     = Red;
color  MediumLevel   = DimGray;
color  LowLevel      = LimeGreen;
int    LineWidth     = 0;
double LineStyle     = 2;

//
//
//

double   buffer1[];
double   buffer2[];
double   buffer3[];
double   buffer4[];
double   buffer5[];
double   buffer6[];
double   buffer7[];
int      Trend = 0, SignalCandle = 0;
bool     AlertOnClosedCandle = 1;
datetime LastAlert           = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init() {
    SetIndexBuffer(0, buffer5);
    SetIndexBuffer(1, buffer6);
    SetIndexBuffer(2, buffer3);
    SetIndexStyle(2, DRAW_HISTOGRAM);
    SetIndexBuffer(3, buffer4);
    SetIndexStyle(3, DRAW_HISTOGRAM);
    SetIndexBuffer(4, buffer1);
    SetIndexBuffer(5, buffer2);
    SetIndexBuffer(6, buffer7);

    ObjectCreate("mMyLine", OBJ_TREND, 0, 0, 0, 0, 0);
    ObjectSet("mMyLine", OBJPROP_STYLE, LineStyle);
    ObjectSet("mMyLine", OBJPROP_TIME1, Time[ShiftToTheLeft]);
    ObjectSet("mMyLine", OBJPROP_TIME2, Time[0] + PERIOD_M1 * 240 * ShiftToTheRight);
    ObjectSet("mMyLine", OBJPROP_WIDTH, LineWidth);
    ObjectSet("mMyLine", OBJPROP_COLOR, HighLevel);
    ObjectSet("mMyLine", OBJPROP_RAY, false);
    ObjectSet("mMyLine", OBJPROP_BACK, true);

    ObjectCreate("mMyLine3", OBJ_TREND, 0, 0, 0, 0, 0);
    ObjectSet("mMyLine3", OBJPROP_STYLE, LineStyle);
    ObjectSet("mMyLine3", OBJPROP_TIME1, Time[ShiftToTheLeft]);
    ObjectSet("mMyLine3", OBJPROP_TIME2, Time[0] + PERIOD_M1 * 240 * ShiftToTheRight);
    ObjectSet("mMyLine3", OBJPROP_WIDTH, LineWidth);
    ObjectSet("mMyLine3", OBJPROP_COLOR, MediumLevel);
    ObjectSet("mMyLine3", OBJPROP_RAY, false);
    ObjectSet("mMyLine3", OBJPROP_BACK, true);

    ObjectCreate("mMyLine2", OBJ_TREND, 0, 0, 0, 0, 0);
    ObjectSet("mMyLine2", OBJPROP_STYLE, LineStyle);
    ObjectSet("mMyLine2", OBJPROP_TIME1, Time[ShiftToTheLeft]);
    ObjectSet("mMyLine2", OBJPROP_TIME2, Time[0] + PERIOD_M1 * 240 * ShiftToTheRight);
    ObjectSet("mMyLine2", OBJPROP_WIDTH, LineWidth);
    ObjectSet("mMyLine2", OBJPROP_COLOR, LowLevel);
    ObjectSet("mMyLine2", OBJPROP_RAY, false);
    ObjectSet("mMyLine2", OBJPROP_BACK, true);

    if(AlertOnClosedCandle)
        SignalCandle = 1;
    return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int deinit() {

    Comment("");
    if(ShowArrows) {
        for(int i = ObjectsTotal() - 1; i >= 0; i--) {
            if(StringFind(ObjectName(i), "MARibbon") > -1)
                ObjectDelete(ObjectName(i));
        }
    }
    ObjectDelete("Comment");
    ObjectDelete("Trade");
    ObjectDelete("mMyLine");
    ObjectDelete("mMyLine2");
    ObjectDelete("mMyLine3");
    return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start() {
    int counted_bars = IndicatorCounted();
    int limit, i;

    if(counted_bars < 0)
        return (-1);
    if(counted_bars > 0)
        counted_bars--;
    limit = Bars - counted_bars;

    //

    for(i = limit; i >= 0; i--) {
        buffer1[i] = iHMA(MaFastPeriod, i);
        buffer2[i] = iHMA(MaMediumPeriod, i);
        buffer5[i] = iHMA(MaHighPeriod, i);
        buffer6[i] = iHMA(MaLowPeriod, i);
        buffer3[i] = buffer1[i];
        buffer4[i] = buffer2[i];

        if(buffer1[i + SignalCandle] > buffer5[i + SignalCandle] && buffer1[i + 1 + SignalCandle] <= buffer5[i + 1 + SignalCandle] && Trend < 1) {
            Trend = 1;
            if(ShowArrows)
                DrawArrow(i + SignalCandle, buffer5[i + SignalCandle], ArrowsUpColor, 233, false);

        } else if(buffer1[i + SignalCandle] < buffer6[i + SignalCandle] && buffer1[i + 1 + SignalCandle] >= buffer6[i + 1 + SignalCandle] && Trend > -1) {
            Trend = -1;
            if(ShowArrows)
                DrawArrow(i + SignalCandle, buffer6[i + SignalCandle], ArrowsDnColor, 234, true);
        }
        buffer7[i] = Trend;
    }
    if(buffer1[SignalCandle] > buffer5[SignalCandle] && buffer1[SignalCandle + 1] <= buffer5[SignalCandle + 1] && LastAlert != Time[0]) {
        LastAlert = Time[0];
        if(AlertOn)
            Alert("MA Channel Buy Alert! - " + Symbol() + "[" + Period() + "m]");
    } else if(buffer1[SignalCandle] < buffer6[SignalCandle] && buffer1[SignalCandle + 1] >= buffer6[SignalCandle + 1] && LastAlert != Time[0]) {
        LastAlert = Time[0];
        if(AlertOn)
            Alert("MA Channel Sell Alert! - " + Symbol() + "[" + Period() + "m]");
    }
    string OPstr;
    color  OPclr;
    if(buffer1[i + SignalCandle] > buffer5[i + SignalCandle]) {
        OPstr = "BUY";
        OPclr = Green;
    } else

        if(buffer1[i + SignalCandle] < buffer6[i + SignalCandle]) {
        OPstr = "SELL";
        OPclr = Red;
    } else {
        OPstr = "NO TRADE";
        OPclr = Yellow;
    }

    if(DisplaySignal == true) {
        ObjectCreate("Trade", OBJ_LABEL, 0, 0, 0);
        ObjectSetText("Trade", OPstr, SignalSize, "Arial Bold", OPclr);
        ObjectSet("Trade", OBJPROP_CORNER, Corner);
        ObjectSet("Trade", OBJPROP_XDISTANCE, 20);
        ObjectSet("Trade", OBJPROP_YDISTANCE, 20);
    }
    if(BackDaysHL == true) {
        double mH = 0, mL = 0, mM = 0;

        mH = iHigh(NULL, 1440, iHighest(NULL, 1440, MODE_HIGH, BackDays, 1));
        mL = iLow(NULL, 1440, iLowest(NULL, 1440, MODE_LOW, BackDays, 1));
        mM = mL + (mH - mL) / 2;
        ObjectSet("mMyLine", OBJPROP_PRICE1, mH);
        ObjectSet("mMyLine", OBJPROP_PRICE2, mH);
        ObjectSet("mMyLine2", OBJPROP_PRICE1, mL);
        ObjectSet("mMyLine2", OBJPROP_PRICE2, mL);
        ObjectSet("mMyLine3", OBJPROP_PRICE1, mM);
        ObjectSet("mMyLine3", OBJPROP_PRICE2, mM);
    }
    return (0);
}
void DrawArrow(int i, double ma, color theColor, int theCode, bool up) {
    string name = "MARibbon:" + Time[i];
    double gap  = 3.0 * iATR(NULL, 0, 10, i) / 4.0;
    ObjectCreate(name, OBJ_ARROW, 0, Time[i], 0);
    ObjectSet(name, OBJPROP_ARROWCODE, theCode);
    ObjectSet(name, OBJPROP_COLOR, theColor);
    ObjectSet(name, OBJPROP_WIDTH, ArrowWidth);
    if(up)
        ObjectSet(name, OBJPROP_PRICE1, ma + gap);
    else
        ObjectSet(name, OBJPROP_PRICE1, ma - gap);
    return;
}

double iHMA(int period, int shift) {
    double value = iCustom(NULL, 0, "myIndicators\\HMA", PERIOD_CURRENT, period, 0, shift);
    return value;
}