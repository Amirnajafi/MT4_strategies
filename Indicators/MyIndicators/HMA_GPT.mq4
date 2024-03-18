//+------------------------------------------------------------------+
//|                                                     HMA_GPT.mq4 |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property strict

// Indicator parameters
input int period = 14;   // Period for HMA calculation

// Indicator buffers
double ExtHMABuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    IndicatorBuffers(1);
    SetIndexBuffer(0, ExtHMABuffer);
    SetIndexStyle(0, DRAW_LINE);
    SetIndexLabel(0, "HMA");

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[]) {
    int begin = prev_calculated - 1;

    if(begin < 0)
        begin = MathMax(0, rates_total - 1);

    for(int i = begin; i >= 0; i--)
        ExtHMABuffer[i] = HMA(i, rates_total, close);

    return (rates_total);
}

//+------------------------------------------------------------------+
//| Hull Moving Average                                             |
//+------------------------------------------------------------------+
double HMA(int index, int total, const double &price[]) {
    double wmaf    = WMA(index, period / 2, price);
    double wmasqrt = MathSqrt(period);
    double result  = 2 * wmaf - WMA(index, period, price);
    return result;
}

//+------------------------------------------------------------------+
//| Weighted Moving Average                                         |
//+------------------------------------------------------------------+
double WMA(int index, int period, const double &price[]) {
    double numerator   = 0;
    double denominator = 0;

    for(int i = 0; i < period; i++) {
        numerator   += (price[index - i] * (i + 1));
        denominator += (i + 1);
    }

    return (numerator / denominator);
}
//+------------------------------------------------------------------+
